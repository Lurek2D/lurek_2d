//! Shared layout types: nodes, edges, configuration structs, and result containers.
//!
//! - `LayoutNode` carries an ID and optional size hint for layout algorithms.
//! - `LayoutEdge` is a directed `(from, to)` pair with an optional weight.
//! - `LayoutResult` is the common return type: a `HashMap<NodeId, (f32, f32)>`.
//! - `LayoutConfig` base fields (padding, viewport size) are embedded in every algorithm config.

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
        let width = nodes
            .iter()
            .map(|n| n.x + n.width)
            .fold(0.0f64, f64::max);
        let height = nodes
            .iter()
            .map(|n| n.y + n.height)
            .fold(0.0f64, f64::max);
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
