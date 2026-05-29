//! Provides core ECS identifier wrappers used to pass entity handles across module boundaries.
//! Defines lightweight typed ids that keep call sites explicit while preserving compact storage.
//! Delivers a shared identity contract for indexing, mapping, and query-level interoperability.

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
