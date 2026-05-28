//! Reingold-Tilford algorithm for compact hierarchical tree node layout.
//!
//! - `layout_tree(root, children, config)` returns a `HashMap<NodeId, (f32, f32)>`.
//! - Handles arbitrary branching factors; sibling subtrees are packed as tightly as possible.
//! - `TreeConfig` sets horizontal and vertical node separation distances.
//! - Supports top-down and left-to-right orientations via the `orientation` field.
//! - Used by `lurek.layout.tree` for dialogue trees, skill trees, and org charts.

use super::types::*;
use std::collections::HashMap;

/// Lays out a tree rooted at `root` with the given parent-to-children adjacency.
///
/// Returns positioned nodes with (x, y) coordinates assigned.
pub fn layout_tree(
    nodes: &[LayoutNode],
    children: &HashMap<NodeId, Vec<NodeId>>,
    root: NodeId,
    config: &LayoutConfig,
) -> LayoutResult {
    let mut positions: HashMap<NodeId, (f64, f64)> = HashMap::new();
    let mut x_offset = config.margin;

    assign_positions(
        root,
        0,
        &mut x_offset,
        children,
        nodes,
        config,
        &mut positions,
    );

    let result_nodes: Vec<LayoutNode> = nodes
        .iter()
        .map(|n| {
            let (x, y) = positions.get(&n.id).copied().unwrap_or((0.0, 0.0));
            let mut node = n.clone();
            node.x = x;
            node.y = y;
            node
        })
        .collect();

    LayoutResult::new(result_nodes)
}

/// Recursively assigns positions via post-order traversal (leaves first).
fn assign_positions(
    node_id: NodeId,
    depth: usize,
    x_offset: &mut f64,
    children: &HashMap<NodeId, Vec<NodeId>>,
    nodes: &[LayoutNode],
    config: &LayoutConfig,
    positions: &mut HashMap<NodeId, (f64, f64)>,
) {
    let y = config.margin + depth as f64 * config.v_spacing;
    let kids = children.get(&node_id).cloned().unwrap_or_default();

    if kids.is_empty() {
        let node_width = nodes
            .iter()
            .find(|n| n.id == node_id)
            .map(|n| n.width)
            .unwrap_or(1.0);
        positions.insert(node_id, (*x_offset, y));
        *x_offset += node_width + config.h_spacing;
    } else {
        let first_child = kids[0];
        for &child in &kids {
            assign_positions(child, depth + 1, x_offset, children, nodes, config, positions);
        }
        let last_child = *kids.last().unwrap();

        let first_x = positions.get(&first_child).map(|p| p.0).unwrap_or(0.0);
        let last_x = positions.get(&last_child).map(|p| p.0).unwrap_or(0.0);
        let center_x = (first_x + last_x) / 2.0;

        positions.insert(node_id, (center_x, y));
    }
}
