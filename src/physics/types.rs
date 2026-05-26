//! Core type definitions for the physics subsystem.
//!
//! - `BodyId` newtype wrapper for type-safe body identification across Lua and Rust layers.
//! - Implements `Copy`, `Hash`, and `Display`; converts to/from `usize` without allocation.

/// Unique identifier for a physics body.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub struct BodyId(pub usize);

impl BodyId {
    /// Creates a new BodyId from a raw usize.
    pub fn new(id: usize) -> Self { Self(id) }
    /// Returns the raw usize underlying value.
    pub fn raw(self) -> usize { self.0 }
}

impl std::fmt::Display for BodyId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}

impl From<usize> for BodyId {
    fn from(v: usize) -> Self { Self(v) }
}

impl From<BodyId> for usize {
    fn from(id: BodyId) -> Self { id.0 }
}
