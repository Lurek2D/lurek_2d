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
    let mut state = TreeLayoutState {
        x_offset: &mut x_offset,
        children,
        widths: &widths,
        config,
        positions: &mut positions,
        visiting: &mut visiting,
    };

    for node_id in traversal_roots {
        state.assign_positions(node_id, 0);
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

/// Shared mutable state for deterministic tree placement.
struct TreeLayoutState<'a> {
    x_offset: &'a mut f64,
    children: &'a HashMap<NodeId, Vec<NodeId>>,
    widths: &'a HashMap<NodeId, f64>,
    config: &'a LayoutConfig,
    positions: &'a mut HashMap<NodeId, (f64, f64)>,
    visiting: &'a mut HashSet<NodeId>,
}

impl TreeLayoutState<'_> {
    /// Recursively assign positions, treating cycle edges as deterministic leaf fallbacks.
    fn assign_positions(&mut self, node_id: NodeId, depth: usize) -> f64 {
        if let Some((x, _)) = self.positions.get(&node_id).copied() {
            return x;
        }

        let y = self.config.margin + depth as f64 * self.config.v_spacing;
        if !self.visiting.insert(node_id) {
            return self.place_leaf(node_id, y);
        }

        let mut kids = self.children.get(&node_id).cloned().unwrap_or_default();
        kids.retain(|child| *child != node_id);
        kids.sort_unstable();
        kids.dedup();

        let x = if kids.is_empty() {
            self.place_leaf(node_id, y)
        } else {
            let mut child_positions = Vec::with_capacity(kids.len());
            for child in kids {
                child_positions.push(self.assign_positions(child, depth + 1));
            }

            if child_positions.is_empty() {
                self.place_leaf(node_id, y)
            } else {
                let center_x =
                    (child_positions[0] + child_positions[child_positions.len() - 1]) / 2.0;
                self.positions.insert(node_id, (center_x, y));
                center_x
            }
        };

        self.visiting.remove(&node_id);
        x
    }

    /// Place one node as a leaf and advance the horizontal cursor.
    fn place_leaf(&mut self, node_id: NodeId, y: f64) -> f64 {
        if let Some((x, _)) = self.positions.get(&node_id).copied() {
            return x;
        }

        let node_width = self.widths.get(&node_id).copied().unwrap_or(1.0);
        let x = *self.x_offset;
        self.positions.insert(node_id, (x, y));
        *self.x_offset += node_width + self.config.h_spacing;
        x
    }
}
