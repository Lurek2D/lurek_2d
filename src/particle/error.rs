//! This file owns typed particle validation and safety errors used by strict constructors and bounded helpers.
//! It keeps failure reasons structured so config parsing, runtime limit checks, and strict mutators report the same contract.
//! Open it when particle callers need clearer diagnostics or when new safety ceilings are introduced.

use std::fmt;

/// Error returned by strict particle constructors, parsers, and bounded runtime helpers.
#[derive(Debug, Clone, PartialEq)]
pub enum ParticleError {
    /// Raw input exceeded the configured byte budget before parsing could continue.
    OversizedInput {
        /// Context string naming the parser or payload.
        context: &'static str,
        /// Requested byte count.
        bytes: usize,
        /// Configured ceiling.
        max_bytes: usize,
    },
    /// A count-based input exceeded a configured safety ceiling.
    CountLimitExceeded {
        /// Context string naming the rejected collection or budget.
        context: &'static str,
        /// Requested count.
        count: usize,
        /// Configured ceiling.
        max: usize,
    },
    /// Floating-point input was NaN or infinite.
    InvalidFloat {
        /// Field name that failed validation.
        field: &'static str,
        /// Rejected value.
        value: f64,
    },
    /// Structured config or runtime state violated the strict particle contract.
    InvalidConfig {
        /// Human-readable detail for the rejected field or invariant.
        detail: String,
    },
}

impl ParticleError {
    /// Build an `InvalidConfig` error from a message-like value.
    pub fn invalid_config(detail: impl Into<String>) -> Self {
        Self::InvalidConfig {
            detail: detail.into(),
        }
    }
}

impl fmt::Display for ParticleError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::OversizedInput {
                context,
                bytes,
                max_bytes,
            } => write!(
                f,
                "{} input uses {} bytes, exceeding limit {}",
                context, bytes, max_bytes
            ),
            Self::CountLimitExceeded {
                context,
                count,
                max,
            } => write!(
                f,
                "{} count {} exceeds configured limit {}",
                context, count, max
            ),
            Self::InvalidFloat { field, value } => {
                write!(
                    f,
                    "particle field '{}' must be finite, got {}",
                    field, value
                )
            }
            Self::InvalidConfig { detail } => write!(f, "{}", detail),
        }
    }
}

impl std::error::Error for ParticleError {}
