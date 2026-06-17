//! Provides render-command generation for post-effect capture and application flows. `effect/render` delivers the rendering adapter and draw-command integration for the effect subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Emits deterministic begin, end, and apply command sequences consumed by the renderer. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Delivers no-op behavior when stacks have no active effects to process. Public callable behavior is centered on no named public items, while method-level behavior such as `begin_capture_command`, `end_capture_command`, `apply_command`, `generate_render_commands` stays attached to the local data model and invariants.

use crate::effect::stack::PostFxStack;
use crate::render::renderer::RenderCommand;

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
    pub fn apply_command(&self, stack_id: u64) -> RenderCommand {
        RenderCommand::ApplyPostFx {
            stack_id,
            passes: Vec::new(),
            width: self.width,
            height: self.height,
        }
    }
    /// Emits the capture and apply command sequence when the stack has enabled effects.
    pub fn generate_render_commands(&self, stack_id: u64) -> Vec<RenderCommand> {
        if self.effects.is_empty() {
            return Vec::new();
        }
        let has_enabled = self.enabled.iter().any(|&e| e);
        if !has_enabled {
            return Vec::new();
        }
        vec![
            self.begin_capture_command(stack_id),
            self.end_capture_command(stack_id),
            self.apply_command(stack_id),
        ]
    }
}
