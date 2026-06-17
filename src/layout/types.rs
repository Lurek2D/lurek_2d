//! Defines the common data contract that every layout algorithm in this module reads and writes. `layout/types` delivers the shared type definitions and data contracts for the layout subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Encodes node identity, geometry hints, and mutable coordinates in a shape tuned for repeated transforms. The file owns or coordinates data contracts including `NodeId`, `LayoutNode`, `LayoutEdge`, `LayoutConfig`, `LayoutResult`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Represents graph relations with lightweight edge records that support directional and weighted workflows. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `with_size`, `with_label`, `with_weight`, `get`, `count` stays attached to the local data model and invariants.
//! Packages algorithm outputs into a uniform result container for renderer and tooling consumption. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

/// Unique node identifier (index-based for performance).
pub type NodeId = usize;

/// A node with position and size in layout space.
#[derive(Debug, Clone)]
pub struct LayoutNode {
    /// Unique identifier.
    pub id: NodeId,
    /// X position (computed by layout algorithm).
    pub x: f64,
    /// Y position (computed by layout algorithm).
    pub y: f64,
    /// Node width for spacing calculations.
    pub width: f64,
    /// Node height for spacing calculations.
    pub height: f64,
    /// Optional label for debugging.
    pub label: Option<String>,
}

impl LayoutNode {
    /// Creates a new node with default size at origin.
    pub fn new(id: NodeId) -> Self {
        Self {
            id,
            x: 0.0,
            y: 0.0,
            width: 1.0,
            height: 1.0,
            label: None,
        }
    }

    /// Sets the node size, returning self for chaining.
    pub fn with_size(mut self, width: f64, height: f64) -> Self {
        self.width = width;
        self.height = height;
        self
    }

    /// Sets the node label, returning self for chaining.
    pub fn with_label(mut self, label: impl Into<String>) -> Self {
        self.label = Some(label.into());
        self
    }
}

/// A directed edge between two nodes.
#[derive(Debug, Clone)]
pub struct LayoutEdge {
    /// Source node ID.
    pub from: NodeId,
    /// Target node ID.
    pub to: NodeId,
    /// Optional edge weight (used by some algorithms).
    pub weight: f64,
}

impl LayoutEdge {
    /// Creates a new edge with default weight 1.0.
    pub fn new(from: NodeId, to: NodeId) -> Self {
        Self {
            from,
            to,
            weight: 1.0,
        }
    }

    /// Sets the edge weight, returning self for chaining.
    pub fn with_weight(mut self, weight: f64) -> Self {
        self.weight = weight;
        self
    }
}

/// Configuration for layout spacing.
#[derive(Debug, Clone)]
pub struct LayoutConfig {
    /// Horizontal spacing between siblings.
    pub h_spacing: f64,
    /// Vertical spacing between layers/levels.
    pub v_spacing: f64,
    /// Margin around the layout.
    pub margin: f64,
}

impl Default for LayoutConfig {
    fn default() -> Self {
        Self {
            h_spacing: 50.0,
            v_spacing: 80.0,
            margin: 20.0,
        }
    }
}

/// Result of a layout computation.
#[derive(Debug, Clone)]
pub struct LayoutResult {
    /// Positioned nodes.
    pub nodes: Vec<LayoutNode>,
    /// Total bounding width.
    pub width: f64,
    /// Total bounding height.
    pub height: f64,
}

impl LayoutResult {
    /// Creates a result and computes bounding dimensions from node positions.
    pub fn new(nodes: Vec<LayoutNode>) -> Self {
        let width = nodes.iter().map(|n| n.x + n.width).fold(0.0f64, f64::max);
        let height = nodes.iter().map(|n| n.y + n.height).fold(0.0f64, f64::max);
        Self {
            nodes,
            width,
            height,
        }
    }

    /// Gets a positioned layout node by its ID.
    pub fn get(&self, id: NodeId) -> Option<&LayoutNode> {
        self.nodes.iter().find(|n| n.id == id)
    }

    /// Returns the number of positioned nodes.
    pub fn count(&self) -> usize {
        self.nodes.len()
    }
}
