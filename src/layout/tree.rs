//! Implements rooted hierarchy placement that keeps parent-child reading order clear and branch spacing compact.
//! Walks subtrees recursively to allocate horizontal extent before anchoring parent coordinates in stable positions.
//! Applies shared spacing controls to balance density and readability for branching structures of uneven depth.
//! Targets dialog flows and progression trees that require explicit structure with minimal manual cleanup.

use super::types::*;
use std::collections::{HashMap, HashSet};

/// Lay out a tree rooted at `root`, keeping output deterministic even when the input graph is cyclic or disconnected.
pub fn layout_tree(
    nodes: &[LayoutNode],
    children: &HashMap<NodeId, Vec<NodeId>>,
    root: NodeId,
    config: &LayoutConfig,
) -> LayoutResult {
    let widths: HashMap<NodeId, f64> = nodes.iter().map(|n| (n.id, n.width)).collect();
    let mut ordered_ids: Vec<NodeId> = nodes.iter().map(|n| n.id).collect();
    ordered_ids.sort_unstable();
    ordered_ids.dedup();

    let mut traversal_roots = Vec::new();
    if widths.contains_key(&root) {
        traversal_roots.push(root);
    }
    traversal_roots.extend(ordered_ids.iter().copied().filter(|id| *id != root));

    let mut positions: HashMap<NodeId, (f64, f64)> = HashMap::new();
    let mut x_offset = config.margin;
    let mut visiting = HashSet::new();

    for node_id in traversal_roots {
        assign_positions(
            node_id,
            0,
            &mut x_offset,
            children,
            &widths,
            config,
            &mut positions,
            &mut visiting,
        );
    }

    let result_nodes: Vec<LayoutNode> = nodes
        .iter()
        .map(|n| {
            let (x, y) = positions
                .get(&n.id)
                .copied()
                .unwrap_or((config.margin, config.margin));
            let mut node = n.clone();
            node.x = x;
            node.y = y;
            node
        })
        .collect();

    LayoutResult::new(result_nodes)
}

/// Recursively assign positions, treating cycle edges as deterministic leaf fallbacks.
fn assign_positions(
    node_id: NodeId,
    depth: usize,
    x_offset: &mut f64,
    children: &HashMap<NodeId, Vec<NodeId>>,
    widths: &HashMap<NodeId, f64>,
    config: &LayoutConfig,
    positions: &mut HashMap<NodeId, (f64, f64)>,
    visiting: &mut HashSet<NodeId>,
) -> f64 {
    if let Some((x, _)) = positions.get(&node_id).copied() {
        return x;
    }

    let y = config.margin + depth as f64 * config.v_spacing;
    if !visiting.insert(node_id) {
        return place_leaf(node_id, y, x_offset, widths, config, positions);
    }

    let mut kids = children.get(&node_id).cloned().unwrap_or_default();
    kids.retain(|child| *child != node_id);
    kids.sort_unstable();
    kids.dedup();

    let x = if kids.is_empty() {
        place_leaf(node_id, y, x_offset, widths, config, positions)
    } else {
        let child_positions: Vec<f64> = kids
            .into_iter()
            .map(|child| {
                assign_positions(
                    child,
                    depth + 1,
                    x_offset,
                    children,
                    widths,
                    config,
                    positions,
                    visiting,
                )
            })
            .collect();

        if child_positions.is_empty() {
            place_leaf(node_id, y, x_offset, widths, config, positions)
        } else {
            let center_x = (child_positions[0] + child_positions[child_positions.len() - 1]) / 2.0;
            positions.insert(node_id, (center_x, y));
            center_x
        }
    };

    visiting.remove(&node_id);
    x
}

/// Place one node as a leaf and advance the horizontal cursor.
fn place_leaf(
    node_id: NodeId,
    y: f64,
    x_offset: &mut f64,
    widths: &HashMap<NodeId, f64>,
    config: &LayoutConfig,
    positions: &mut HashMap<NodeId, (f64, f64)>,
) -> f64 {
    if let Some((x, _)) = positions.get(&node_id).copied() {
        return x;
    }

    let node_width = widths.get(&node_id).copied().unwrap_or(1.0);
    let x = *x_offset;
    positions.insert(node_id, (x, y));
    *x_offset += node_width + config.h_spacing;
    x
}
