//! Defines shared node, edge, config, and result structs consumed by every layout algorithm owner.
//! Owns common ids, positions, sizes, spacing policy, labels, and final bounding-box reporting.
//! Keeps builder helpers attached to the payload types that Lua bindings and Rust algorithms consume.
//! Provides rectangle overlap, positive size, and margin normalization helpers for quality cleanup.
//! Carries reusable layout data only; it does not choose tree, DAG, force, radial, or grid strategy.
//! Change this file when payload fields, shared spacing semantics, or result shape expectations move.

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

/// Return a positive finite node width.
pub(crate) fn node_width(node: &LayoutNode) -> f64 {
    finite_positive(node.width, 1.0)
}

/// Return a positive finite node height.
pub(crate) fn node_height(node: &LayoutNode) -> f64 {
    finite_positive(node.height, 1.0)
}

/// Return the largest side among all nodes.
pub(crate) fn max_node_side(nodes: &[LayoutNode]) -> f64 {
    nodes
        .iter()
        .map(|node| node_width(node).max(node_height(node)))
        .fold(1.0, f64::max)
}

/// Return true when two node rectangles overlap after adding `padding`.
pub(crate) fn nodes_overlap(a: &LayoutNode, b: &LayoutNode, padding: f64) -> bool {
    let padding = padding.max(0.0);
    a.x < b.x + node_width(b) + padding
        && a.x + node_width(a) + padding > b.x
        && a.y < b.y + node_height(b) + padding
        && a.y + node_height(a) + padding > b.y
}

/// Shift all nodes so the minimum x/y equals `margin`.
pub(crate) fn normalize_to_margin(nodes: &mut [LayoutNode], margin: f64) {
    if nodes.is_empty() {
        return;
    }
    let min_x = nodes
        .iter()
        .map(|node| node.x)
        .fold(f64::INFINITY, f64::min);
    let min_y = nodes
        .iter()
        .map(|node| node.y)
        .fold(f64::INFINITY, f64::min);
    let dx = margin - min_x;
    let dy = margin - min_y;
    for node in nodes {
        node.x += dx;
        node.y += dy;
    }
}

/// Relax overlapping node rectangles with deterministic pairwise separation.
pub(crate) fn relax_overlaps(
    nodes: &mut [LayoutNode],
    padding: f64,
    bounds: Option<(f64, f64)>,
    iterations: usize,
) {
    if nodes.len() < 2 {
        return;
    }
    let padding = padding.max(0.0);
    for _ in 0..iterations {
        let mut moved = false;
        for i in 0..nodes.len() {
            for j in (i + 1)..nodes.len() {
                let acx = nodes[i].x + node_width(&nodes[i]) * 0.5;
                let acy = nodes[i].y + node_height(&nodes[i]) * 0.5;
                let bcx = nodes[j].x + node_width(&nodes[j]) * 0.5;
                let bcy = nodes[j].y + node_height(&nodes[j]) * 0.5;
                let dx = acx - bcx;
                let dy = acy - bcy;
                let overlap_x =
                    (node_width(&nodes[i]) + node_width(&nodes[j])) * 0.5 + padding - dx.abs();
                let overlap_y =
                    (node_height(&nodes[i]) + node_height(&nodes[j])) * 0.5 + padding - dy.abs();
                if overlap_x <= 0.0 || overlap_y <= 0.0 {
                    continue;
                }
                let direction = if dx.abs() + dy.abs() < 0.001 {
                    if nodes[i].id <= nodes[j].id {
                        1.0
                    } else {
                        -1.0
                    }
                } else {
                    0.0
                };
                if overlap_x < overlap_y {
                    let sign = if direction != 0.0 {
                        direction
                    } else if dx >= 0.0 {
                        1.0
                    } else {
                        -1.0
                    };
                    let shift = overlap_x * 0.5;
                    nodes[i].x += sign * shift;
                    nodes[j].x -= sign * shift;
                } else {
                    let sign = if direction != 0.0 {
                        direction
                    } else if dy >= 0.0 {
                        1.0
                    } else {
                        -1.0
                    };
                    let shift = overlap_y * 0.5;
                    nodes[i].y += sign * shift;
                    nodes[j].y -= sign * shift;
                }
                moved = true;
            }
        }
        if let Some((width, height)) = bounds {
            for node in nodes.iter_mut() {
                node.x = node.x.clamp(0.0, (width - node_width(node)).max(0.0));
                node.y = node.y.clamp(0.0, (height - node_height(node)).max(0.0));
            }
        }
        if !moved {
            break;
        }
    }
}

fn finite_positive(value: f64, fallback: f64) -> f64 {
    if value.is_finite() && value > 0.0 {
        value
    } else {
        fallback
    }
}
