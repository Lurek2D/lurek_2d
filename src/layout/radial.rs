//! `src/layout/radial.rs` owns concentric breadth-first graph placement for hub-and-spoke and network-map views.
//! It provides a deterministic radial layout similar to Graphviz twopi, grouping nodes by hop distance from a root.
//! Edges are treated as undirected for level discovery so arbitrary graph data can still produce useful rings.
//! Rings use chord-safe radii and parent-angle ordering so dense branches avoid obvious overlap and crossings.
//! Read it when radial ring assignment, root handling, or disconnected fallback placement need to change.

use super::types::*;
use std::collections::{HashMap, HashSet, VecDeque};

/// Lay out a graph on concentric rings discovered by breadth-first distance from `root`.
pub fn layout_radial(
    nodes: &[LayoutNode],
    edges: &[LayoutEdge],
    root: NodeId,
    config: &LayoutConfig,
) -> LayoutResult {
    if nodes.is_empty() {
        return LayoutResult::new(Vec::new());
    }

    let mut ordered_ids: Vec<NodeId> = nodes.iter().map(|node| node.id).collect();
    ordered_ids.sort_unstable();
    ordered_ids.dedup();
    let node_set: HashSet<NodeId> = ordered_ids.iter().copied().collect();

    let mut adj: HashMap<NodeId, Vec<NodeId>> = ordered_ids
        .iter()
        .copied()
        .map(|id| (id, Vec::new()))
        .collect();
    for edge in edges {
        if node_set.contains(&edge.from) && node_set.contains(&edge.to) {
            adj.entry(edge.from).or_default().push(edge.to);
            adj.entry(edge.to).or_default().push(edge.from);
        }
    }
    for neighbors in adj.values_mut() {
        neighbors.sort_unstable();
        neighbors.dedup();
    }

    let start = if node_set.contains(&root) {
        root
    } else {
        ordered_ids[0]
    };
    let mut depth: HashMap<NodeId, usize> = HashMap::new();
    let mut queue = VecDeque::from([start]);
    depth.insert(start, 0);
    while let Some(id) = queue.pop_front() {
        let next_depth = depth[&id] + 1;
        for next in adj.get(&id).into_iter().flatten().copied() {
            if let std::collections::hash_map::Entry::Vacant(entry) = depth.entry(next) {
                entry.insert(next_depth);
                queue.push_back(next);
            }
        }
    }

    let fallback_depth = depth.values().copied().max().unwrap_or(0) + 1;
    for id in &ordered_ids {
        depth.entry(*id).or_insert(fallback_depth);
    }

    let max_depth = depth.values().copied().max().unwrap_or(0);
    let mut rings = vec![Vec::new(); max_depth + 1];
    for id in ordered_ids {
        rings[depth[&id]].push(id);
    }

    let node_map: HashMap<NodeId, &LayoutNode> = nodes.iter().map(|node| (node.id, node)).collect();
    let max_w = nodes.iter().map(|node| node.width).fold(1.0, f64::max);
    let max_h = nodes.iter().map(|node| node.height).fold(1.0, f64::max);
    let base_gap = config
        .v_spacing
        .max(max_node_side(nodes) + config.h_spacing.max(1.0));
    let mut ring_radii = vec![0.0f64; rings.len()];
    for ring_index in 1..rings.len() {
        let ring = &rings[ring_index];
        let largest = ring
            .iter()
            .filter_map(|id| node_map.get(id).copied())
            .map(|node| node_width(node).hypot(node_height(node)))
            .fold(max_w.max(max_h), f64::max);
        let chord = largest + config.h_spacing.max(1.0);
        let required = if ring.len() <= 1 {
            0.0
        } else {
            chord / (2.0 * (std::f64::consts::PI / ring.len() as f64).sin())
        };
        ring_radii[ring_index] = (ring_radii[ring_index - 1] + base_gap).max(required);
    }
    let radius = ring_radii.iter().copied().fold(0.0, f64::max);
    let cx = config.margin + radius + max_w * 0.5;
    let cy = config.margin + radius + max_h * 0.5;

    let mut result = Vec::with_capacity(nodes.len());
    let mut angle_by_id: HashMap<NodeId, f64> = HashMap::new();
    for (ring_index, ring) in rings.iter().enumerate() {
        if ring.is_empty() {
            continue;
        }
        let mut ordered_ring = ring.clone();
        if ring_index > 1 {
            ordered_ring.sort_by(|a, b| {
                let aa = neighbor_angle(*a, &adj, &angle_by_id).unwrap_or(*a as f64);
                let bb = neighbor_angle(*b, &adj, &angle_by_id).unwrap_or(*b as f64);
                aa.partial_cmp(&bb)
                    .unwrap_or(std::cmp::Ordering::Equal)
                    .then_with(|| a.cmp(b))
            });
        }
        for (index, id) in ordered_ring.iter().enumerate() {
            if let Some(original) = node_map.get(id).copied() {
                let mut node = original.clone();
                if ring_index == 0 {
                    node.x = cx - node.width * 0.5;
                    node.y = cy - node.height * 0.5;
                    angle_by_id.insert(*id, -std::f64::consts::FRAC_PI_2);
                } else {
                    let angle = -std::f64::consts::FRAC_PI_2
                        + std::f64::consts::TAU * index as f64 / ordered_ring.len() as f64;
                    let r = ring_radii[ring_index];
                    node.x = cx + r * angle.cos() - node.width * 0.5;
                    node.y = cy + r * angle.sin() - node.height * 0.5;
                    angle_by_id.insert(*id, angle);
                }
                result.push(node);
            }
        }
    }

    LayoutResult::new(result)
}

fn neighbor_angle(
    id: NodeId,
    adj: &HashMap<NodeId, Vec<NodeId>>,
    angle_by_id: &HashMap<NodeId, f64>,
) -> Option<f64> {
    let mut total_x = 0.0;
    let mut total_y = 0.0;
    let mut count = 0usize;
    for neighbor in adj.get(&id).into_iter().flatten() {
        if let Some(angle) = angle_by_id.get(neighbor) {
            total_x += angle.cos();
            total_y += angle.sin();
            count += 1;
        }
    }
    (count > 0).then(|| total_y.atan2(total_x))
}
