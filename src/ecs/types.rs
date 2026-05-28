//! Core ECS type aliases and ID newtypes: entity, component slot, and archetype key.
//!
//! - `EntityId` is a `u32` generation-stamped handle; 0 is the null entity.
//! - `ComponentSlot` is a dense index into a component storage array.
//! - `ArchetypeKey` is a sorted bitset of component type IDs identifying a layout.
//! - All types derive `Copy`, `Eq`, and `Hash` so they can be used as map keys.

/// Unique identifier for an ECS entity.
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
