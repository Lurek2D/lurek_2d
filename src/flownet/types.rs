//! Provides shared flownet identifier wrappers used to type node, edge, and item handles. `flownet/types` delivers the shared type definitions and data contracts for the flownet subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Encapsulates raw numeric ids in lightweight newtypes for clearer API contracts. The file owns or coordinates data contracts including `NodeId`, `EdgeId`, `ItemId`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Supports conversion and display behavior needed across simulation and tooling call paths. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `raw` stays attached to the local data model and invariants.
//! Delivers the common identity foundation for graph storage and cross-module interoperability. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

/// Unique identifier for a flownet graph node.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub struct NodeId(pub u64);

impl NodeId {
    /// Create a new `NodeId` wrapping the given raw integer.
    pub fn new(id: u64) -> Self {
        Self(id)
    }
    /// Return the underlying raw node identifier.
    pub fn raw(self) -> u64 {
        self.0
    }
}

impl std::fmt::Display for NodeId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}

impl From<u64> for NodeId {
    fn from(v: u64) -> Self {
        Self(v)
    }
}

impl From<NodeId> for u64 {
    fn from(id: NodeId) -> Self {
        id.0
    }
}

/// Unique identifier for a flownet graph edge.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub struct EdgeId(pub u64);

impl EdgeId {
    /// Create a new `EdgeId` wrapping the given raw integer.
    pub fn new(id: u64) -> Self {
        Self(id)
    }
    /// Return the underlying raw edge identifier.
    pub fn raw(self) -> u64 {
        self.0
    }
}

impl std::fmt::Display for EdgeId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}

impl From<u64> for EdgeId {
    fn from(v: u64) -> Self {
        Self(v)
    }
}

impl From<EdgeId> for u64 {
    fn from(id: EdgeId) -> Self {
        id.0
    }
}

/// Unique identifier for a flownet item (resource flowing through the network).
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub struct ItemId(pub u64);

impl ItemId {
    /// Create a new `ItemId` wrapping the given raw integer.
    pub fn new(id: u64) -> Self {
        Self(id)
    }
    /// Return the underlying raw item identifier.
    pub fn raw(self) -> u64 {
        self.0
    }
}

impl std::fmt::Display for ItemId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}

impl From<u64> for ItemId {
    fn from(v: u64) -> Self {
        Self(v)
    }
}

impl From<ItemId> for u64 {
    fn from(id: ItemId) -> Self {
        id.0
    }
}
