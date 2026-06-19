//! Owns typed validation and safety errors shared by AI planners, steering, scoring, and Lua-facing helpers.
//! It keeps failure reasons explicit so AI owners can reject invalid numeric input, unsafe tree shapes, and bad budgets consistently.
//! Open it when AI callers need clearer diagnostics or when a new AI subsystem joins the shared validation contract.

use std::fmt;

/// Error returned by safe AI constructors, bounded helpers, and strict mutators.
#[derive(Debug, Clone, PartialEq)]
pub enum AiError {
    /// A floating-point input was NaN or infinite.
    InvalidFloat { field: &'static str, value: f64 },
    /// A floating-point input had to be non-negative but was below zero.
    NegativeValue { field: &'static str, value: f64 },
    /// A floating-point input had to be strictly positive but was zero or negative.
    NonPositiveValue { field: &'static str, value: f64 },
    /// A floating-point input was outside an inclusive range.
    ValueOutOfRange {
        field: &'static str,
        min: f64,
        max: f64,
        value: f64,
    },
    /// A count-based input exceeded a configured ceiling.
    CountLimitExceeded {
        context: &'static str,
        count: usize,
        max: usize,
    },
    /// A tree or recursive structure exceeded a configured depth ceiling.
    DepthLimitExceeded {
        context: &'static str,
        depth: usize,
        max: usize,
    },
    /// A configuration value or group was rejected for a specific reason.
    InvalidConfig {
        context: &'static str,
        detail: String,
    },
}

impl fmt::Display for AiError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::InvalidFloat { field, value } => {
                write!(f, "ai field '{}' must be finite, got {}", field, value)
            }
            Self::NegativeValue { field, value } => {
                write!(f, "ai field '{}' must be >= 0, got {}", field, value)
            }
            Self::NonPositiveValue { field, value } => {
                write!(f, "ai field '{}' must be > 0, got {}", field, value)
            }
            Self::ValueOutOfRange {
                field,
                min,
                max,
                value,
            } => write!(
                f,
                "ai field '{}' must be in [{}, {}], got {}",
                field, min, max, value
            ),
            Self::CountLimitExceeded {
                context,
                count,
                max,
            } => write!(f, "{} count {} exceeds configured limit {}", context, count, max),
            Self::DepthLimitExceeded {
                context,
                depth,
                max,
            } => write!(f, "{} depth {} exceeds configured limit {}", context, depth, max),
            Self::InvalidConfig { context, detail } => {
                write!(f, "{} configuration is invalid: {}", context, detail)
            }
        }
    }
}

impl std::error::Error for AiError {}
