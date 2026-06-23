//! `src/layout/dag.rs` lays out directed graphs in layers so flow direction, rank order, and dependency reading stay clear.
//! It owns layer assignment, cyclic fallback placement, barycenter ordering, and centered per-layer coordinates.
//! Shared `LayoutConfig` spacing and margins are applied here so DAG results align with the rest of the layout module.
//! This file is the layered-graph algorithm boundary; it does not own shared types, force simulation, or tree recursion.
//! Read it when rank construction, crossing reduction, deterministic fallback, or DAG coordinate rules need changes.

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

        barycenters.sort_by(|a, b| {
            a.1.partial_cmp(&b.1)
                .unwrap_or(std::cmp::Ordering::Equal)
                .then_with(|| a.0.cmp(&b.0))
        });
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
    let mut layer_widths = Vec::with_capacity(layers.len());
    let mut layer_heights = Vec::with_capacity(layers.len());

    for layer in layers {
        let mut width = 0.0f64;
        let mut height = 1.0f64;
        let mut count = 0usize;
        for &node_id in layer {
            if let Some(&node) = node_map.get(&node_id) {
                width += node_width(node);
                height = height.max(node_height(node));
                count += 1;
            }
        }
        if count > 1 {
            width += config.h_spacing.max(0.0) * (count - 1) as f64;
        }
        layer_widths.push(width);
        layer_heights.push(height);
    }
    let max_layer_width = layer_widths.iter().copied().fold(0.0, f64::max);
    let mut y = config.margin;

    for (layer_idx, layer) in layers.iter().enumerate() {
        let mut x = config.margin + (max_layer_width - layer_widths[layer_idx]).max(0.0) * 0.5;

        for &node_id in layer {
            if let Some(&original) = node_map.get(&node_id) {
                let mut node = original.clone();
                node.x = x;
                node.y = y + (layer_heights[layer_idx] - node_height(&node)) * 0.5;
                x += node_width(&node) + config.h_spacing.max(0.0);
                result.push(node);
            }
        }
        y += layer_heights[layer_idx] + config.v_spacing.max(0.0);
    }

    result
}
