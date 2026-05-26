//! Sugiyama layered layout algorithm for directed acyclic graphs.
//!
//! - `layout_dag(nodes, edges, config)` returns a `LayoutResult` with `(x, y)` positions.
//! - Phases: cycle removal, layer assignment, crossing minimisation, coordinate assignment.
//! - `DagConfig` controls node separation, layer height, and direction (top-down / LR).
//! - Output coordinates are in logical pixels; caller applies camera transform.
//! - Used by `lurek.layout.dag`; suitable for dependency trees and tech-tree UIs.

use super::types::*;
use std::collections::{HashMap, HashSet, VecDeque};

/// Lays out a directed acyclic graph using a layered approach.
///
/// Nodes are assigned to layers based on longest path from sources,
/// then positioned within each layer to minimize crossings.
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

/// Assigns layers based on longest path from source nodes.
fn assign_layers(nodes: &[LayoutNode], edges: &[LayoutEdge]) -> Vec<Vec<NodeId>> {
    let node_ids: HashSet<NodeId> = nodes.iter().map(|n| n.id).collect();
    let mut in_degree: HashMap<NodeId, usize> = node_ids.iter().map(|&id| (id, 0)).collect();
    let mut adj: HashMap<NodeId, Vec<NodeId>> = node_ids.iter().map(|&id| (id, Vec::new())).collect();

    for edge in edges {
        if node_ids.contains(&edge.from) && node_ids.contains(&edge.to) {
            adj.entry(edge.from).or_default().push(edge.to);
            *in_degree.entry(edge.to).or_insert(0) += 1;
        }
    }

    let mut layer_of: HashMap<NodeId, usize> = HashMap::new();
    let mut queue: VecDeque<NodeId> = in_degree
        .iter()
        .filter(|(_, &deg)| deg == 0)
        .map(|(&id, _)| id)
        .collect();

    for &id in &queue {
        layer_of.insert(id, 0);
    }

    while let Some(node) = queue.pop_front() {
        let current_layer = layer_of[&node];
        let neighbors = adj.get(&node).cloned().unwrap_or_default();
        for next in neighbors {
            let new_layer = current_layer + 1;
            let entry = layer_of.entry(next).or_insert(0);
            if new_layer > *entry {
                *entry = new_layer;
            }
            let deg = in_degree.get_mut(&next).unwrap();
            *deg -= 1;
            if *deg == 0 {
                queue.push_back(next);
            }
        }
    }

    let max_layer = layer_of.values().copied().max().unwrap_or(0);
    let mut layers: Vec<Vec<NodeId>> = vec![Vec::new(); max_layer + 1];
    for (&id, &layer) in &layer_of {
        layers[layer].push(id);
    }
    layers
}

/// Reduces crossings using barycenter heuristic (single pass).
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

/// Assigns x/y coordinates to nodes based on their layer and position.
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
