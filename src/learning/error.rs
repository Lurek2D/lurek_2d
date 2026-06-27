//! Owns the error taxonomy for the learning subsystem and keeps its rules local to this file.
//! Centers the implementation around LearningError, fmt, with helpers kept close to their invariants.
//! Defines how error data is validated, transformed, or stored before neighboring systems use it.
//! Owns learning behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on error behavior while Lua registration stays elsewhere.

use std::fmt;

/// Error returned by safe learning constructors, bounded helpers, and strict mutators.
#[derive(Debug, Clone, PartialEq)]
pub enum LearningError {
    /// A floating-point input was NaN or infinite.
    InvalidFloat { field: &'static str, value: f64 },
    /// A floating-point input was outside an inclusive range.
    ValueOutOfRange {
        field: &'static str,
        min: f64,
        max: f64,
        value: f64,
    },
    /// A count-based input was zero where at least one item is required.
    ZeroCount { field: &'static str },
    /// Checked arithmetic overflowed while computing an element or parameter count.
    CountOverflow { context: &'static str },
    /// A count-based input exceeded a configured ceiling.
    CountLimitExceeded {
        context: &'static str,
        count: usize,
        max: usize,
    },
    /// A tensor axis was zero where the learning tensor contract requires a positive size.
    ZeroDimension { context: &'static str, axis: usize },
    /// Tensor shape and flat data length did not agree.
    ShapeDataLenMismatch { expected: usize, actual: usize },
    /// A slice or table length did not match the exact size required by the API.
    InvalidLength {
        context: &'static str,
        expected: usize,
        actual: usize,
    },
    /// A caller referenced an index outside the valid range for the current owner.
    IndexOutOfBounds {
        context: &'static str,
        index: usize,
        len: usize,
    },
    /// A layered network topology is incompatible between adjacent layers.
    TopologyMismatch {
        layer_index: usize,
        previous_outputs: usize,
        current_inputs: usize,
    },
    /// The requested model input count did not match the model contract.
    InputCountMismatch { expected: usize, actual: usize },
    /// A serialized envelope declared a version this runtime does not understand.
    UnsupportedVersion { context: &'static str, version: u32 },
    /// An external parser or runtime returned a contextual error string.
    External {
        context: &'static str,
        detail: String,
    },
    /// A filesystem path escaped the configured sandbox root.
    SandboxViolation { path: String, root: String },
    /// A file exceeded the configured byte ceiling.
    FileTooLarge {
        path: String,
        bytes: u64,
        max_bytes: u64,
    },
}

impl fmt::Display for LearningError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::InvalidFloat { field, value } => {
                write!(
                    f,
                    "learning field '{}' must be finite, got {}",
                    field, value
                )
            }
            Self::ValueOutOfRange {
                field,
                min,
                max,
                value,
            } => write!(
                f,
                "learning field '{}' must be in [{}, {}], got {}",
                field, min, max, value
            ),
            Self::ZeroCount { field } => {
                write!(f, "learning field '{}' must be greater than zero", field)
            }
            Self::CountOverflow { context } => {
                write!(f, "{} count overflowed", context)
            }
            Self::CountLimitExceeded {
                context,
                count,
                max,
            } => write!(
                f,
                "{} count {} exceeds configured limit {}",
                context, count, max
            ),
            Self::ZeroDimension { context, axis } => {
                write!(f, "{} axis {} must be greater than zero", context, axis)
            }
            Self::ShapeDataLenMismatch { expected, actual } => write!(
                f,
                "tensor shape expects {} element(s), got {}",
                expected, actual
            ),
            Self::InvalidLength {
                context,
                expected,
                actual,
            } => write!(
                f,
                "{} length mismatch: expected {}, got {}",
                context, expected, actual
            ),
            Self::IndexOutOfBounds {
                context,
                index,
                len,
            } => write!(
                f,
                "{} index {} is out of bounds for length {}",
                context, index, len
            ),
            Self::TopologyMismatch {
                layer_index,
                previous_outputs,
                current_inputs,
            } => write!(
                f,
                "learning layer {} expects {} input(s) but previous layer outputs {} value(s)",
                layer_index, current_inputs, previous_outputs
            ),
            Self::InputCountMismatch { expected, actual } => write!(
                f,
                "learning model expects {} input tensor(s), got {}",
                expected, actual
            ),
            Self::UnsupportedVersion { context, version } => {
                write!(f, "{} uses unsupported version {}", context, version)
            }
            Self::External { context, detail } => write!(f, "{}: {}", context, detail),
            Self::SandboxViolation { path, root } => write!(
                f,
                "learning path '{}' is outside sandbox root '{}'",
                path, root
            ),
            Self::FileTooLarge {
                path,
                bytes,
                max_bytes,
            } => write!(
                f,
                "learning file '{}' requires {} byte(s), exceeding limit {}",
                path, bytes, max_bytes
            ),
        }
    }
}

impl std::error::Error for LearningError {}
