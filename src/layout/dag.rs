//! Provides staged layered layout for directed graphs where flow direction and rank readability are primary goals. `layout/dag` delivers the dag implementation for the layout subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Organizes nodes into bands, reorders local neighborhoods to reduce crossings, and then assigns stable screen coordinates.
//! Applies spacing and margin policy from shared layout config so outputs align with other module strategies. Public callable behavior is centered on `layout_dag`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
//! Prefers deterministic structure over visual drift to keep dependency and progression maps legible across updates. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

use super::types::*;
use std::collections::{HashMap, HashSet, VecDeque};

/// Lay out a directed graph using a layered approach with deterministic fallback for invalid graphs.
pub fn layout_dag(
    nodes: &[LayoutNode],
    edges: &[LayoutEdge],
    config: &LayoutConfig,
) -> LayoutResult {
    if nodes.is_empty() {
        return LayoutResult::new(Vec::new());
    }

    let layers = assign_layers(nodes, edges);
    let ordered_layers = reduce_crossings(&layers, edges);
    let positioned = assign_coordinates(nodes, &ordered_layers, config);

    LayoutResult::new(positioned)
}

/// Assign layers from source nodes and keep cyclic/unresolved nodes in a deterministic fallback layer.
fn assign_layers(nodes: &[LayoutNode], edges: &[LayoutEdge]) -> Vec<Vec<NodeId>> {
    let mut node_ids: Vec<NodeId> = nodes.iter().map(|n| n.id).collect();
    node_ids.sort_unstable();
    node_ids.dedup();

    let node_set: HashSet<NodeId> = node_ids.iter().copied().collect();
    let mut in_degree: HashMap<NodeId, usize> = node_ids.iter().map(|&id| (id, 0)).collect();
    let mut adj: HashMap<NodeId, Vec<NodeId>> =
        node_ids.iter().map(|&id| (id, Vec::new())).collect();

    for edge in edges {
        if node_set.contains(&edge.from) && node_set.contains(&edge.to) {
            adj.entry(edge.from).or_default().push(edge.to);
            *in_degree.entry(edge.to).or_insert(0) += 1;
        }
    }

    for neighbors in adj.values_mut() {
        neighbors.sort_unstable();
        neighbors.dedup();
    }

    let mut layer_of: HashMap<NodeId, usize> = HashMap::new();
    let mut queue: VecDeque<NodeId> = node_ids
        .iter()
        .copied()
        .filter(|id| in_degree.get(id).copied().unwrap_or(0) == 0)
        .collect();

    for &id in &queue {
        layer_of.insert(id, 0);
    }

    while let Some(node) = queue.pop_front() {
        let current_layer = layer_of.get(&node).copied().unwrap_or(0);
        let neighbors = adj.get(&node).cloned().unwrap_or_default();
        for next in neighbors {
            let new_layer = current_layer + 1;
            let entry = layer_of.entry(next).or_insert(0);
            if new_layer > *entry {
                *entry = new_layer;
            }
            if let Some(deg) = in_degree.get_mut(&next) {
                *deg = deg.saturating_sub(1);
                if *deg == 0 {
                    queue.push_back(next);
                }
            }
        }
    }

    let fallback_layer = layer_of.values().copied().max().unwrap_or(0) + 1;
    for id in &node_ids {
        layer_of.entry(*id).or_insert(fallback_layer);
    }

    let max_layer = layer_of.values().copied().max().unwrap_or(0);
    let mut layers: Vec<Vec<NodeId>> = vec![Vec::new(); max_layer + 1];
    for id in node_ids {
        if let Some(layer) = layer_of.get(&id).copied() {
            layers[layer].push(id);
        }
    }
    layers
}

/// Reduce crossings using a single barycenter pass while preserving stable order for ties.
fn reduce_crossings(layers: &[Vec<NodeId>], edges: &[LayoutEdge]) -> Vec<Vec<NodeId>> {
    let mut result = layers.to_vec();

    for i in 1..result.len() {
        let prev_positions: HashMap<NodeId, usize> = result[i - 1]
            .iter()
            .enumerate()
            .map(|(pos, &id)| (id, pos))
            .collect();

        let mut barycenters: Vec<(NodeId, f64)> = result[i]
            .iter()
            .map(|&node| {
                let parents: Vec<usize> = edges
                    .iter()
                    .filter(|e| e.to == node)
                    .filter_map(|e| prev_positions.get(&e.from).copied())
                    .collect();
                let bc = if parents.is_empty() {
                    0.0
                } else {
                    parents.iter().sum::<usize>() as f64 / parents.len() as f64
                };
                (node, bc)
            })
            .collect();

        barycenters.sort_by(|a, b| a.1.partial_cmp(&b.1).unwrap_or(std::cmp::Ordering::Equal));
        result[i] = barycenters.into_iter().map(|(id, _)| id).collect();
    }

    result
}

/// Assign coordinates to nodes based on their layer and slot position.
fn assign_coordinates(
    nodes: &[LayoutNode],
    layers: &[Vec<NodeId>],
    config: &LayoutConfig,
) -> Vec<LayoutNode> {
    let node_map: HashMap<NodeId, &LayoutNode> = nodes.iter().map(|n| (n.id, n)).collect();
    let mut result = Vec::new();

    for (layer_idx, layer) in layers.iter().enumerate() {
        let y = config.margin + layer_idx as f64 * config.v_spacing;
        let mut x = config.margin;

        for &node_id in layer {
            if let Some(&original) = node_map.get(&node_id) {
                let mut node = original.clone();
                node.x = x;
                node.y = y;
                x += node.width + config.h_spacing;
                result.push(node);
            }
        }
    }

    result
}
