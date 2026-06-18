//! This file owns `EntityId`, the typed wrapper around packed ECS entity handles passed across module boundaries.
//! It keeps call sites explicit while preserving cheap copy semantics and direct conversion to and from integers.
//! `new`, `raw`, `Display`, and numeric `From` impls make the wrapper usable in maps, logs, and Lua glue code.
//! Open it when public entity-handle semantics change; id packing and world storage live in sibling ECS files.

/// Unique identifier for an ECS entity.
///
/// # Fields
/// - `0`: Packed 32-bit entity identifier combining slot and generation.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub struct EntityId(pub u32);

impl EntityId {
    /// Create a new `EntityId` wrapping the given raw integer.
    pub fn new(id: u32) -> Self {
        Self(id)
    }
    /// Return the underlying raw entity identifier.
    pub fn raw(self) -> u32 {
        self.0
    }
}

impl std::fmt::Display for EntityId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}

impl From<u32> for EntityId {
    fn from(v: u32) -> Self {
        Self(v)
    }
}

impl From<EntityId> for u32 {
    fn from(id: EntityId) -> Self {
        id.0
    }
}

impl From<u64> for EntityId {
    fn from(v: u64) -> Self {
        Self(v as u32)
    }
}

impl From<EntityId> for u64 {
    fn from(id: EntityId) -> Self {
        id.0 as u64
    }
}
