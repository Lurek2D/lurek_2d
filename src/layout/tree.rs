//! `src/layout/tree.rs` lays out rooted hierarchies by recursively placing children and centering parents over spans.
//! It owns deterministic traversal, cycle fallback handling, subtree spans, and depth-based y placement.
//! Shared `LayoutConfig` spacing rules are applied here so hierarchy outputs stay compatible with other layout modes.
//! This file is the hierarchy-specific algorithm boundary; it does not own shared types or post-layout alignment passes.
//! Read it when parent-child ordering, subtree spacing, root fallback behavior, or tree coordinate rules need changes.

use super::types::*;
use std::collections::{HashMap, HashSet};

/// Lay out a tree rooted at `root`, keeping output deterministic even when the input graph is cyclic or disconnected.
pub fn layout_tree(
    nodes: &[LayoutNode],
    children: &HashMap<NodeId, Vec<NodeId>>,
    root: NodeId,
    config: &LayoutConfig,
) -> LayoutResult {
    if nodes.is_empty() {
        return LayoutResult::new(Vec::new());
    }

    let node_map: HashMap<NodeId, &LayoutNode> = nodes.iter().map(|n| (n.id, n)).collect();
    let mut ordered_ids: Vec<NodeId> = nodes.iter().map(|n| n.id).collect();
    ordered_ids.sort_unstable();
    ordered_ids.dedup();

    let mut traversal_roots = Vec::new();
    if node_map.contains_key(&root) {
        traversal_roots.push(root);
    }
    traversal_roots.extend(ordered_ids.iter().copied().filter(|id| *id != root));

    let mut positions: HashMap<NodeId, (f64, f64)> = HashMap::new();
    let mut spans = HashMap::new();
    let mut span_visiting = HashSet::new();
    let max_h = nodes.iter().map(node_height).fold(1.0, f64::max);
    let level_gap = max_h + config.v_spacing.max(0.0);
    let mut x_offset = config.margin;
    let mut place_visiting = HashSet::new();
    let mut state = TreeLayoutState {
        x_offset: &mut x_offset,
        children,
        node_map: &node_map,
        config,
        level_gap,
        spans: &mut spans,
        positions: &mut positions,
        span_visiting: &mut span_visiting,
        place_visiting: &mut place_visiting,
    };

    for node_id in traversal_roots {
        let span = state.compute_span(node_id);
        state.assign_positions(node_id, 0, *state.x_offset, span);
        *state.x_offset += span + config.h_spacing.max(0.0);
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
    node_map: &'a HashMap<NodeId, &'a LayoutNode>,
    config: &'a LayoutConfig,
    level_gap: f64,
    spans: &'a mut HashMap<NodeId, f64>,
    positions: &'a mut HashMap<NodeId, (f64, f64)>,
    span_visiting: &'a mut HashSet<NodeId>,
    place_visiting: &'a mut HashSet<NodeId>,
}

impl TreeLayoutState<'_> {
    /// Compute subtree span, treating cycle edges as leaf fallbacks.
    fn compute_span(&mut self, node_id: NodeId) -> f64 {
        if let Some(span) = self.spans.get(&node_id).copied() {
            return span;
        }
        let Some(node) = self.node_map.get(&node_id).copied() else {
            return 1.0;
        };
        if !self.span_visiting.insert(node_id) {
            return node_width(node);
        }
        let kids = self.valid_children(node_id);
        let child_span = if kids.is_empty() {
            0.0
        } else {
            let mut sum = 0.0;
            for child in &kids {
                sum += self.compute_span(*child);
            }
            sum + self.config.h_spacing.max(0.0) * kids.len().saturating_sub(1) as f64
        };
        let span = node_width(node).max(child_span);
        self.span_visiting.remove(&node_id);
        self.spans.insert(node_id, span);
        span
    }

    /// Recursively assign positions inside the precomputed subtree span.
    fn assign_positions(&mut self, node_id: NodeId, depth: usize, left: f64, span: f64) {
        if self.positions.contains_key(&node_id) {
            return;
        }
        let Some(node) = self.node_map.get(&node_id).copied() else {
            return;
        };
        if !self.place_visiting.insert(node_id) {
            self.place_node(node_id, left, depth, node);
            return;
        }
        let y = self.config.margin + depth as f64 * self.level_gap;
        let x = left + (span - node_width(node)).max(0.0) * 0.5;
        self.positions.insert(node_id, (x, y));

        let kids = self.valid_children(node_id);
        if !kids.is_empty() {
            let total_child_span = kids
                .iter()
                .map(|child| self.spans.get(child).copied().unwrap_or(1.0))
                .sum::<f64>()
                + self.config.h_spacing.max(0.0) * kids.len().saturating_sub(1) as f64;
            let mut child_left = left + (span - total_child_span).max(0.0) * 0.5;
            for child in kids {
                let child_span = self.spans.get(&child).copied().unwrap_or(1.0);
                self.assign_positions(child, depth + 1, child_left, child_span);
                child_left += child_span + self.config.h_spacing.max(0.0);
            }
        }
        self.place_visiting.remove(&node_id);
    }

    /// Place one node as a deterministic leaf fallback.
    fn place_node(&mut self, node_id: NodeId, left: f64, depth: usize, _node: &LayoutNode) {
        let y = self.config.margin + depth as f64 * self.level_gap;
        let x = left;
        self.positions.insert(node_id, (x, y));
    }

    fn valid_children(&self, node_id: NodeId) -> Vec<NodeId> {
        let mut kids = self.children.get(&node_id).cloned().unwrap_or_default();
        kids.retain(|child| *child != node_id && self.node_map.contains_key(child));
        kids.sort_unstable();
        kids.dedup();
        kids
    }
}
