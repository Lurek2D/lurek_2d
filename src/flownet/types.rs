//! Shared type definitions for the flownet visual scripting graph.
//!
//! - `NodeId`, `PortId`, and `EdgeId` are newtype wrappers around `u32` for clarity.
//! - `PortKind` distinguishes input/output and the value type carried (number, bool, any).
//! - `NodeValue` is the runtime variant type flowing through edges at evaluation time.
//! - All types are `Clone + Debug + PartialEq` to support undo-redo snapshotting.

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
