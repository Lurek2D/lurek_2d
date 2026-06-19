//! This file owns `PostFxEffect`, the runtime state object that couples one effect kind with mutable parameters.
//! It stores the effect type, scalar parameter map, enable flag, optional shader id, and auto-uniform toggle.
//! Construction helpers cover built-in and custom effects, while accessors expose parameter reads, writes, and names.
//! Open this file when per-effect runtime semantics change; type catalogs, stacks, and image grouping live in siblings.

use super::contract::{PostFxDiagnostics, PostFxError, PostFxLimits};
use super::effect_type::PostFxEffectType;
use crate::log_msg;
use crate::runtime::log_messages::{FE01, FE02, FE03};
use std::collections::HashMap;
#[derive(Clone, Debug)]
/// Stores one post-processing effect instance and its runtime parameters.
pub struct PostFxEffect {
    /// Built-in or custom effect type driving shader selection.
    pub effect_type: PostFxEffectType,
    /// Scalar parameter map passed to the effect implementation.
    pub params: HashMap<String, f32>,
    /// Enables or disables this effect without removing it from a stack.
    pub enabled: bool,
    /// Renderer shader identifier used by custom effects.
    pub shader_id: Option<usize>,
    /// Requests automatic uniform population for this effect.
    pub auto_uniforms: bool,
}
impl PostFxEffect {
    /// Creates an enabled built-in effect with its default parameter set.
    pub fn new(effect_type: PostFxEffectType) -> Self {
        log_msg!(debug, FE01);
        Self {
            params: effect_type.default_params(),
            effect_type,
            enabled: true,
            shader_id: None,
            auto_uniforms: false,
        }
    }
    /// Creates an enabled custom effect bound to an explicit shader id.
    pub fn new_custom(shader_id: usize) -> Self {
        log_msg!(debug, FE02, "shader={}", shader_id);
        Self {
            effect_type: PostFxEffectType::Custom,
            params: HashMap::new(),
            enabled: true,
            shader_id: Some(shader_id),
            auto_uniforms: false,
        }
    }
    /// Creates a validated custom effect bound to a live shader id.
    pub fn new_custom_checked<F>(
        shader_id: usize,
        mut shader_exists: F,
    ) -> Result<Self, PostFxError>
    where
        F: FnMut(usize) -> bool,
    {
        if !shader_exists(shader_id) {
            return Err(PostFxError::InvalidCustomShaderId { shader_id });
        }
        Ok(Self::new_custom(shader_id))
    }
    /// Inserts or replaces one scalar effect parameter.
    pub fn set_parameter(&mut self, name: impl Into<String>, value: f32) {
        let name = name.into();
        log_msg!(trace, FE03, "{}={}", name, value);
        let _ = self.try_set_parameter(name, value);
    }
    /// Inserts or replaces one scalar effect parameter after validating it against the effect schema.
    pub fn try_set_parameter(
        &mut self,
        name: impl Into<String>,
        value: f32,
    ) -> Result<(), PostFxError> {
        self.try_set_parameter_with_limits(name, value, &PostFxLimits::default())
    }
    /// Inserts or replaces one scalar effect parameter using explicit validation limits.
    pub fn try_set_parameter_with_limits(
        &mut self,
        name: impl Into<String>,
        value: f32,
        limits: &PostFxLimits,
    ) -> Result<(), PostFxError> {
        let name = name.into();
        validate_param_name(&name, limits)?;
        if self.params.len() >= limits.max_param_count && !self.params.contains_key(&name) {
            return Err(PostFxError::ParameterCountExceeded {
                effect_name: self.get_type_name(),
                max_count: limits.max_param_count,
                actual: self.params.len() + 1,
            });
        }
        if let Some(schema) = self.effect_type.find_param_schema(&name) {
            schema.validate_value(self.get_type_name(), value)?;
        } else if self.is_built_in() && limits.strict_builtin_params {
            return Err(PostFxError::UnknownParameter {
                effect_name: self.get_type_name(),
                name,
            });
        } else if !value.is_finite() {
            return Err(PostFxError::NonFiniteParameter { name, value });
        }
        self.params.insert(name, value);
        Ok(())
    }
    /// Returns a scalar effect parameter or the caller-provided fallback.
    pub fn get_parameter(&self, name: &str, default: f32) -> f32 {
        self.params.get(name).copied().unwrap_or(default)
    }
    /// Returns whether a named scalar parameter is present.
    pub fn has_parameter(&self, name: &str) -> bool {
        self.params.contains_key(name)
    }
    /// Returns the sorted list of parameter names defined on this effect.
    pub fn get_parameter_names(&self) -> Vec<String> {
        let mut names: Vec<String> = self.params.keys().cloned().collect();
        names.sort();
        names
    }
    /// Returns the lowercase effect type name used by renderer-facing code.
    pub fn get_type_name(&self) -> &'static str {
        self.effect_type.name()
    }
    /// Returns the full validation report for the currently stored parameters.
    pub fn validate_params(&self) -> PostFxDiagnostics {
        self.validate_params_with_limits(&PostFxLimits::default())
    }
    /// Returns the full validation report for the currently stored parameters using explicit limits.
    pub fn validate_params_with_limits(&self, limits: &PostFxLimits) -> PostFxDiagnostics {
        let mut diagnostics = PostFxDiagnostics::default();
        if self.params.len() > limits.max_param_count {
            diagnostics.push_error(
                "parameter_count_exceeded",
                PostFxError::ParameterCountExceeded {
                    effect_name: self.get_type_name(),
                    max_count: limits.max_param_count,
                    actual: self.params.len(),
                },
            );
        }
        for (name, value) in &self.params {
            if let Err(error) = validate_param_name(name, limits) {
                diagnostics.push_error("parameter_name_too_long", error);
                continue;
            }
            match self.effect_type.find_param_schema(name) {
                Some(schema) => {
                    if let Err(error) = schema.validate_value(self.get_type_name(), *value) {
                        let code = match error {
                            PostFxError::NonFiniteParameter { .. } => "non_finite_parameter",
                            PostFxError::ParameterOutOfRange { .. } => "parameter_out_of_range",
                            PostFxError::ParameterNotIntegerLike { .. } => {
                                "parameter_not_integer_like"
                            }
                            _ => "invalid_parameter",
                        };
                        diagnostics.push_error(code, error);
                    }
                }
                None if self.is_built_in() && limits.strict_builtin_params => {
                    diagnostics.push_error(
                        "unknown_parameter",
                        PostFxError::UnknownParameter {
                            effect_name: self.get_type_name(),
                            name: name.clone(),
                        },
                    );
                }
                None if !value.is_finite() => {
                    diagnostics.push_error(
                        "non_finite_parameter",
                        PostFxError::NonFiniteParameter {
                            name: name.clone(),
                            value: *value,
                        },
                    );
                }
                None => {}
            }
        }
        diagnostics
    }
    /// Validates the custom shader binding, if this effect uses a custom pass.
    pub fn validate_custom_shader<F>(&self, mut shader_exists: F) -> Result<(), PostFxError>
    where
        F: FnMut(usize) -> bool,
    {
        if self.effect_type != PostFxEffectType::Custom {
            return Ok(());
        }
        let shader_id = self.shader_id.ok_or(PostFxError::MissingCustomShaderId)?;
        if shader_exists(shader_id) {
            Ok(())
        } else {
            Err(PostFxError::InvalidCustomShaderId { shader_id })
        }
    }
    /// Returns whether this effect uses a built-in effect type.
    pub fn is_built_in(&self) -> bool {
        self.effect_type != PostFxEffectType::Custom
    }
    /// Creates a built-in effect in the disabled state.
    pub fn new_disabled(effect_type: PostFxEffectType) -> Self {
        let mut e = Self::new(effect_type);
        e.enabled = false;
        e
    }
    /// Convenience alias for setting one scalar effect parameter.
    pub fn set_param(&mut self, name: impl Into<String>, value: f32) {
        self.set_parameter(name, value);
    }
    /// Convenience alias for fetching one scalar effect parameter with a fallback.
    pub fn get_param_or(&self, name: &str, default: f32) -> f32 {
        self.get_parameter(name, default)
    }
}

fn validate_param_name(name: &str, limits: &PostFxLimits) -> Result<(), PostFxError> {
    if name.len() > limits.max_param_name_len {
        return Err(PostFxError::ParameterNameTooLong {
            name: name.to_string(),
            max_len: limits.max_param_name_len,
        });
    }
    Ok(())
}
