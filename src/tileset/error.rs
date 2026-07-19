//! Defines the error vocabulary shared by tileset construction and metadata mutation.
//!
//! The tileset boundary reports these errors to Lua with the owning API name added by
//! the binding. Keeping the structured cases here prevents arithmetic, id, and limit
//! failures from becoming unrelated free-form strings across the subsystem.

use thiserror::Error;

/// Failure returned by validated tileset construction or metadata mutation.
///
/// # Variants
///
/// Variants distinguish field validation, local-id ownership, checked arithmetic,
/// and configured collection ceilings.
#[derive(Debug, Clone, PartialEq, Eq, Error)]
pub enum TilesetError {
    /// A value violates a documented field invariant.
    #[error("{field} {reason}")]
    InvalidValue {
        /// Field or logical path that failed validation.
        field: String,
        /// Short explanation of the violated invariant.
        reason: String,
    },
    /// A zero-based local tile id is not owned by the tileset.
    #[error("local tile id {local_tile_id} is outside 0..{tile_count}")]
    TileIdOutOfBounds {
        /// Invalid zero-based local id.
        local_tile_id: u32,
        /// Exclusive tile-count upper bound.
        tile_count: u32,
    },
    /// A global-id range would overflow `u32`.
    #[error("first gid {first_gid} plus tile count {tile_count} overflows u32")]
    GidRangeOverflow {
        /// First global tile id.
        first_gid: u32,
        /// Number of tiles in the range.
        tile_count: u32,
    },
    /// A checked atlas calculation overflowed.
    #[error("checked atlas arithmetic overflowed while calculating {field}")]
    ArithmeticOverflow {
        /// Calculation that overflowed.
        field: &'static str,
    },
    /// A collection or numeric dimension exceeds the owning limit.
    #[error("{resource} {requested} exceeds the tileset limit {maximum}")]
    LimitExceeded {
        /// Limited resource name.
        resource: &'static str,
        /// Requested amount.
        requested: u64,
        /// Allowed amount.
        maximum: u64,
    },
}

impl TilesetError {
    /// Construct a field-specific validation error without exposing enum details to callers.
    pub fn invalid(field: impl Into<String>, reason: impl Into<String>) -> Self {
        Self::InvalidValue {
            field: field.into(),
            reason: reason.into(),
        }
    }
}
