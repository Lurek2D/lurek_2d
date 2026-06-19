//! This file owns the shared post-effect validation contract: limits, parameter schemas, errors, and diagnostics.
//! It keeps post-fx safety policy centralized so effect instances, stacks, debug images, and Lua bindings agree.
//! Open this file when post-fx validation semantics, dimension ceilings, or diagnostic vocabulary need to change.

use std::fmt;

const INTEGER_LIKE_EPSILON: f32 = 0.0001;

/// Classifies whether a post-fx parameter accepts continuous or integer-like values.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PostFxParamKind {
    /// Any finite float in the allowed range is accepted.
    Float,
    /// Only whole-number values in the allowed range are accepted.
    Integer,
}

/// Describes one named parameter, its default value, and its accepted range.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct PostFxParamSchema {
    /// Canonical parameter name.
    pub name: &'static str,
    /// Default value used when an effect is created.
    pub default: f32,
    /// Minimum accepted value.
    pub min: f32,
    /// Maximum accepted value.
    pub max: f32,
    /// Whether the value is continuous or integer-like.
    pub kind: PostFxParamKind,
}

impl PostFxParamSchema {
    /// Creates a float parameter schema entry.
    pub const fn float(name: &'static str, default: f32, min: f32, max: f32) -> Self {
        Self {
            name,
            default,
            min,
            max,
            kind: PostFxParamKind::Float,
        }
    }

    /// Creates an integer-like parameter schema entry.
    pub const fn integer(name: &'static str, default: f32, min: f32, max: f32) -> Self {
        Self {
            name,
            default,
            min,
            max,
            kind: PostFxParamKind::Integer,
        }
    }

    /// Validates one candidate parameter value for a specific effect name.
    pub fn validate_value(&self, effect_name: &'static str, value: f32) -> Result<(), PostFxError> {
        if !value.is_finite() {
            return Err(PostFxError::NonFiniteParameter {
                name: self.name.to_string(),
                value,
            });
        }
        if value < self.min || value > self.max {
            return Err(PostFxError::ParameterOutOfRange {
                effect_name,
                name: self.name.to_string(),
                min: self.min,
                max: self.max,
                value,
            });
        }
        if matches!(self.kind, PostFxParamKind::Integer) && !is_integer_like(value) {
            return Err(PostFxError::ParameterNotIntegerLike {
                effect_name,
                name: self.name.to_string(),
                value,
            });
        }
        Ok(())
    }
}

fn is_integer_like(value: f32) -> bool {
    (value - value.round()).abs() <= INTEGER_LIKE_EPSILON
}

/// Error cases used by post-fx validation and command planning.
#[derive(Debug, Clone, PartialEq)]
pub enum PostFxError {
    /// Parameter values must be finite before they reach render uniforms.
    NonFiniteParameter {
        /// Parameter name.
        name: String,
        /// Invalid numeric value.
        value: f32,
    },
    /// Parameter names are bounded to avoid unbounded map growth.
    ParameterNameTooLong {
        /// Parameter name.
        name: String,
        /// Maximum accepted length.
        max_len: usize,
    },
    /// One effect exceeded the configured parameter count ceiling.
    ParameterCountExceeded {
        /// Effect name.
        effect_name: &'static str,
        /// Maximum accepted count.
        max_count: usize,
        /// Actual count seen on the effect.
        actual: usize,
    },
    /// Built-in effects reject unknown parameter names in strict mode.
    UnknownParameter {
        /// Effect name.
        effect_name: &'static str,
        /// Unknown parameter name.
        name: String,
    },
    /// Parameter values must stay within the documented schema range.
    ParameterOutOfRange {
        /// Effect name.
        effect_name: &'static str,
        /// Parameter name.
        name: String,
        /// Minimum accepted value.
        min: f32,
        /// Maximum accepted value.
        max: f32,
        /// Actual value.
        value: f32,
    },
    /// Integer-like parameters reject fractional values.
    ParameterNotIntegerLike {
        /// Effect name.
        effect_name: &'static str,
        /// Parameter name.
        name: String,
        /// Actual value.
        value: f32,
    },
    /// Width and height must both be positive.
    InvalidDimensions {
        /// Requested width.
        width: u32,
        /// Requested height.
        height: u32,
    },
    /// Width, height, or total area exceeded configured limits.
    DimensionsTooLarge {
        /// Requested width.
        width: u32,
        /// Requested height.
        height: u32,
        /// Maximum accepted width.
        max_width: u32,
        /// Maximum accepted height.
        max_height: u32,
        /// Maximum accepted area in pixels.
        max_pixels: u64,
    },
    /// `enabled.len()` no longer matches the number of stack effect slots.
    EnabledLengthMismatch {
        /// Number of effect slots.
        effect_count: usize,
        /// Number of enable flags.
        enabled_count: usize,
    },
    /// Stack entry points at a missing effect in the registry snapshot.
    StaleEffectIndex {
        /// Invalid effect index.
        index: usize,
        /// Number of available effects in the registry snapshot.
        effect_count: usize,
    },
    /// Duplicate stack entries were found under a warn/disallow policy.
    DuplicateEffectIndex {
        /// Duplicated effect index.
        index: usize,
    },
    /// Custom post-fx effects must reference a live shader id.
    InvalidCustomShaderId {
        /// Invalid runtime shader identifier.
        shader_id: usize,
    },
    /// A custom effect is missing its shader id.
    MissingCustomShaderId,
    /// An enabled stack resolved to no executable passes.
    EmptyPasses,
    /// Debug image rendering rejected an oversized target.
    DebugImageTooLarge {
        /// Requested width.
        width: u32,
        /// Requested height.
        height: u32,
        /// Maximum accepted width.
        max_width: u32,
        /// Maximum accepted height.
        max_height: u32,
        /// Maximum accepted area in pixels.
        max_pixels: u64,
    },
}

impl fmt::Display for PostFxError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::NonFiniteParameter { name, value } => {
                write!(f, "post-fx parameter '{name}' must be finite, got {value}")
            }
            Self::ParameterNameTooLong { name, max_len } => {
                write!(
                    f,
                    "post-fx parameter '{name}' exceeds the max name length of {max_len}"
                )
            }
            Self::ParameterCountExceeded {
                effect_name,
                max_count,
                actual,
            } => {
                write!(
                    f,
                    "post-fx effect '{effect_name}' has {actual} parameters, max is {max_count}"
                )
            }
            Self::UnknownParameter { effect_name, name } => {
                write!(
                    f,
                    "post-fx effect '{effect_name}' does not support '{name}'"
                )
            }
            Self::ParameterOutOfRange {
                effect_name,
                name,
                min,
                max,
                value,
            } => {
                write!(
                    f,
                    "post-fx parameter '{effect_name}.{name}' must stay in [{min}, {max}], got {value}"
                )
            }
            Self::ParameterNotIntegerLike {
                effect_name,
                name,
                value,
            } => {
                write!(
                    f,
                    "post-fx parameter '{effect_name}.{name}' must be integer-like, got {value}"
                )
            }
            Self::InvalidDimensions { width, height } => {
                write!(
                    f,
                    "post-fx dimensions must both be positive, got {width}x{height}"
                )
            }
            Self::DimensionsTooLarge {
                width,
                height,
                max_width,
                max_height,
                max_pixels,
            } => {
                write!(
                    f,
                    "post-fx dimensions {width}x{height} exceed limits {max_width}x{max_height} and {max_pixels} pixels"
                )
            }
            Self::EnabledLengthMismatch {
                effect_count,
                enabled_count,
            } => {
                write!(
                    f,
                    "post-fx stack effect count {effect_count} does not match enable flag count {enabled_count}"
                )
            }
            Self::StaleEffectIndex {
                index,
                effect_count,
            } => {
                write!(
                    f,
                    "post-fx stack references stale effect index {index} with only {effect_count} registered effects"
                )
            }
            Self::DuplicateEffectIndex { index } => {
                write!(f, "post-fx stack contains duplicate effect index {index}")
            }
            Self::InvalidCustomShaderId { shader_id } => {
                write!(f, "post-fx custom shader id {shader_id} is not registered")
            }
            Self::MissingCustomShaderId => {
                write!(f, "post-fx custom effect is missing its shader id")
            }
            Self::EmptyPasses => {
                write!(f, "post-fx stack resolved to zero executable passes")
            }
            Self::DebugImageTooLarge {
                width,
                height,
                max_width,
                max_height,
                max_pixels,
            } => {
                write!(
                    f,
                    "post-fx debug image {width}x{height} exceeds limits {max_width}x{max_height} and {max_pixels} pixels"
                )
            }
        }
    }
}

impl std::error::Error for PostFxError {}

/// Duplicate-stack policy used during validation and render planning.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PostFxDuplicatePolicy {
    /// Duplicates are accepted silently.
    Allow,
    /// Duplicates are accepted but reported as warnings.
    Warn,
    /// Duplicates invalidate the stack plan.
    Disallow,
}

/// Shared limits for parameter validation and render-target sizing.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct PostFxLimits {
    /// Maximum parameters stored on one effect.
    pub max_param_count: usize,
    /// Maximum parameter name length.
    pub max_param_name_len: usize,
    /// Maximum stack target width.
    pub max_stack_width: u32,
    /// Maximum stack target height.
    pub max_stack_height: u32,
    /// Maximum stack target area in pixels.
    pub max_stack_pixels: u64,
    /// Whether built-in effects reject unknown parameter names.
    pub strict_builtin_params: bool,
    /// Default duplicate policy used by stacks.
    pub duplicate_policy: PostFxDuplicatePolicy,
}

impl Default for PostFxLimits {
    fn default() -> Self {
        Self {
            max_param_count: 32,
            max_param_name_len: 48,
            max_stack_width: 8192,
            max_stack_height: 8192,
            max_stack_pixels: 67_108_864,
            strict_builtin_params: true,
            duplicate_policy: PostFxDuplicatePolicy::Warn,
        }
    }
}

impl PostFxLimits {
    /// Validates stack dimensions without altering the original request.
    pub fn validate_dimensions(&self, width: u32, height: u32) -> Result<(), PostFxError> {
        if width == 0 || height == 0 {
            return Err(PostFxError::InvalidDimensions { width, height });
        }
        let area = width as u64 * height as u64;
        if width > self.max_stack_width
            || height > self.max_stack_height
            || area > self.max_stack_pixels
        {
            return Err(PostFxError::DimensionsTooLarge {
                width,
                height,
                max_width: self.max_stack_width,
                max_height: self.max_stack_height,
                max_pixels: self.max_stack_pixels,
            });
        }
        Ok(())
    }

    /// Clamps legacy dimension requests into a safe executable range.
    pub fn sanitize_dimensions(&self, width: u32, height: u32) -> (u32, u32) {
        let mut width = width.clamp(1, self.max_stack_width);
        let mut height = height.clamp(1, self.max_stack_height);
        let area = width as u64 * height as u64;
        if area <= self.max_stack_pixels {
            return (width, height);
        }

        let scale = (self.max_stack_pixels as f64 / area as f64).sqrt();
        width = ((width as f64 * scale).floor() as u32).clamp(1, self.max_stack_width);
        height = ((height as f64 * scale).floor() as u32).clamp(1, self.max_stack_height);

        while width as u64 * height as u64 > self.max_stack_pixels {
            if width >= height && width > 1 {
                width -= 1;
            } else if height > 1 {
                height -= 1;
            } else {
                break;
            }
        }
        (width.max(1), height.max(1))
    }
}

/// Bounds for debug-image helper output.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct PostFxDebugImageLimits {
    /// Maximum debug image width.
    pub max_width: u32,
    /// Maximum debug image height.
    pub max_height: u32,
    /// Maximum debug image area in pixels.
    pub max_pixels: u64,
}

impl Default for PostFxDebugImageLimits {
    fn default() -> Self {
        Self {
            max_width: 4096,
            max_height: 4096,
            max_pixels: 16_777_216,
        }
    }
}

impl PostFxDebugImageLimits {
    /// Validates a debug-image allocation request.
    pub fn validate(&self, width: u32, height: u32) -> Result<(), PostFxError> {
        if width == 0 || height == 0 {
            return Err(PostFxError::InvalidDimensions { width, height });
        }
        let area = width as u64 * height as u64;
        if width > self.max_width || height > self.max_height || area > self.max_pixels {
            return Err(PostFxError::DebugImageTooLarge {
                width,
                height,
                max_width: self.max_width,
                max_height: self.max_height,
                max_pixels: self.max_pixels,
            });
        }
        Ok(())
    }
}

/// Severity attached to one post-fx diagnostic entry.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PostFxDiagnosticSeverity {
    /// Non-fatal issue.
    Warning,
    /// Fatal issue that blocks command generation.
    Error,
}

/// One diagnostic entry emitted by post-fx validation or render planning.
#[derive(Debug, Clone, PartialEq)]
pub struct PostFxDiagnostic {
    /// Severity level.
    pub severity: PostFxDiagnosticSeverity,
    /// Stable code used by tests and callers.
    pub code: &'static str,
    /// Structured error payload.
    pub error: PostFxError,
}

/// Collected post-fx diagnostics for one validation or planning step.
#[derive(Debug, Clone, Default, PartialEq)]
pub struct PostFxDiagnostics {
    entries: Vec<PostFxDiagnostic>,
}

impl PostFxDiagnostics {
    /// Builds a diagnostics set with one error entry.
    pub fn from_error(code: &'static str, error: PostFxError) -> Self {
        let mut diagnostics = Self::default();
        diagnostics.push_error(code, error);
        diagnostics
    }

    /// Appends one warning entry.
    pub fn push_warning(&mut self, code: &'static str, error: PostFxError) {
        self.entries.push(PostFxDiagnostic {
            severity: PostFxDiagnosticSeverity::Warning,
            code,
            error,
        });
    }

    /// Appends one error entry.
    pub fn push_error(&mut self, code: &'static str, error: PostFxError) {
        self.entries.push(PostFxDiagnostic {
            severity: PostFxDiagnosticSeverity::Error,
            code,
            error,
        });
    }

    /// Appends every entry from another diagnostics set.
    pub fn extend(&mut self, other: Self) {
        self.entries.extend(other.entries);
    }

    /// Returns every diagnostic entry.
    pub fn iter(&self) -> impl Iterator<Item = &PostFxDiagnostic> {
        self.entries.iter()
    }

    /// Returns whether no diagnostics were recorded.
    pub fn is_empty(&self) -> bool {
        self.entries.is_empty()
    }

    /// Returns whether at least one error entry was recorded.
    pub fn has_errors(&self) -> bool {
        self.entries
            .iter()
            .any(|entry| matches!(entry.severity, PostFxDiagnosticSeverity::Error))
    }

    /// Returns the number of diagnostic entries.
    pub fn len(&self) -> usize {
        self.entries.len()
    }
}

/// Auto-populated uniform names supported by post-fx custom passes.
pub const POSTFX_AUTO_UNIFORMS: &[&str] = &[
    "time",
    "resolution",
    "texel_size",
    "frame_index",
    "stack_index",
];
