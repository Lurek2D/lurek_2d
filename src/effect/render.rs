//! Owns effect behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps effect data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
//! Defines how render data is validated, transformed, or stored before neighboring systems use it.
//! Owns effect behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on render behavior while Lua registration stays elsewhere.

use crate::effect::{PostFxDiagnostics, PostFxEffect, PostFxError, PostFxLimits, PostFxStack};
use crate::render::renderer::{PostFxPass, RenderCommand};

/// Resolved post-fx passes together with any planning diagnostics.
#[derive(Debug, Clone, Default)]
pub struct PostFxPassPlan {
    /// Passes that will be sent to the renderer when planning succeeds.
    pub passes: Vec<PostFxPass>,
    /// Validation or planning diagnostics gathered while resolving the stack.
    pub diagnostics: PostFxDiagnostics,
}

/// Render commands plus diagnostics for one stack planning step.
#[derive(Debug, Clone, Default)]
pub struct PostFxCommandPlan {
    /// Commands emitted for this stack, empty when validation blocks execution.
    pub commands: Vec<RenderCommand>,
    /// Validation or planning diagnostics gathered while building the commands.
    pub diagnostics: PostFxDiagnostics,
}

/// Render-command generation for post-effect capture and application.
impl PostFxStack {
    /// Builds the command that starts post-effect capture for a stack id.
    pub fn begin_capture_command(&self, stack_id: u64) -> RenderCommand {
        RenderCommand::BeginPostFx { stack_id }
    }
    /// Builds the command that ends post-effect capture for a stack id.
    pub fn end_capture_command(&self, stack_id: u64) -> RenderCommand {
        RenderCommand::EndPostFx { stack_id }
    }
    /// Builds the command that applies the captured stack output at the stack dimensions.
    pub fn apply_command(&self, stack_id: u64, passes: Vec<PostFxPass>) -> RenderCommand {
        RenderCommand::ApplyPostFx {
            stack_id,
            passes,
            width: self.width,
            height: self.height,
        }
    }
    /// Resolves enabled stack entries into explicit renderer pass descriptors.
    pub fn resolve_passes(
        &self,
        effect_registry: &[PostFxEffect],
        limits: &PostFxLimits,
    ) -> PostFxPassPlan {
        self.resolve_passes_with_shader_check(effect_registry, limits, |_| true)
    }
    /// Resolves enabled stack entries into explicit renderer pass descriptors with custom-shader validation.
    pub fn resolve_passes_with_shader_check<F>(
        &self,
        effect_registry: &[PostFxEffect],
        limits: &PostFxLimits,
        mut shader_exists: F,
    ) -> PostFxPassPlan
    where
        F: FnMut(usize) -> bool,
    {
        let mut plan = PostFxPassPlan {
            passes: Vec::new(),
            diagnostics: self.validate_against(effect_registry.len(), limits),
        };
        if plan.diagnostics.has_errors() {
            return plan;
        }

        for effect_idx in self.enabled_effects_iter() {
            let Some(effect) = effect_registry.get(effect_idx) else {
                plan.diagnostics.push_error(
                    "stale_effect_index",
                    PostFxError::StaleEffectIndex {
                        index: effect_idx,
                        effect_count: effect_registry.len(),
                    },
                );
                continue;
            };
            if !effect.enabled {
                continue;
            }

            let param_diagnostics = effect.validate_params_with_limits(limits);
            if !param_diagnostics.is_empty() {
                plan.diagnostics.extend(param_diagnostics);
            }
            if let Err(error) = effect.validate_custom_shader(&mut shader_exists) {
                plan.diagnostics.push_error("invalid_custom_shader", error);
                continue;
            }
            if plan.diagnostics.has_errors() {
                continue;
            }

            plan.passes.push(PostFxPass {
                effect_name: effect
                    .shader_id
                    .map(|id| format!("custom_{id}"))
                    .unwrap_or_else(|| effect.get_type_name().to_string()),
                params: effect.params.clone(),
                shader_id: effect.shader_id,
                auto_uniforms: effect.auto_uniforms,
            });
        }

        if plan.passes.is_empty() && self.enabled_effects_iter().next().is_some() {
            plan.diagnostics
                .push_error("empty_passes", PostFxError::EmptyPasses);
        }
        plan
    }
    /// Emits the capture and apply command sequence when the stack resolves into explicit passes.
    pub fn generate_render_commands(
        &self,
        stack_id: u64,
        effect_registry: &[PostFxEffect],
        limits: &PostFxLimits,
    ) -> PostFxCommandPlan {
        self.generate_render_commands_with_shader_check(stack_id, effect_registry, limits, |_| true)
    }
    /// Emits the capture and apply command sequence with explicit custom-shader validation.
    pub fn generate_render_commands_with_shader_check<F>(
        &self,
        stack_id: u64,
        effect_registry: &[PostFxEffect],
        limits: &PostFxLimits,
        shader_exists: F,
    ) -> PostFxCommandPlan
    where
        F: FnMut(usize) -> bool,
    {
        let pass_plan =
            self.resolve_passes_with_shader_check(effect_registry, limits, shader_exists);
        if pass_plan.diagnostics.has_errors() || pass_plan.passes.is_empty() {
            return PostFxCommandPlan {
                commands: Vec::new(),
                diagnostics: pass_plan.diagnostics,
            };
        }
        PostFxCommandPlan {
            commands: vec![
                self.begin_capture_command(stack_id),
                self.end_capture_command(stack_id),
                self.apply_command(stack_id, pass_plan.passes),
            ],
            diagnostics: pass_plan.diagnostics,
        }
    }
}
