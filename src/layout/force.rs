//! `src/layout/force.rs` computes force-directed graph layouts for cases where clustering matters more than strict rank.
//! It owns simulation, size-aware forces, cooling, bounded placement, initial seeding, and overlap cleanup.
//! `ForceConfig` lives here because iteration count, strengths, and area size are specific to this algorithm family.
//! This file outputs shared `LayoutResult` data but does not own node contracts, tree logic, or alignment cleanup.
//! Read it when graph spacing, convergence behavior, simulation cost, or force-tuning semantics need to change.

use super::types::*;
use std::collections::HashMap;

/// Configuration for force-directed layout.
#[derive(Debug, Clone)]
pub struct ForceConfig {
    /// Number of iterations to simulate.
    pub iterations: usize,
    /// Repulsion strength between nodes.
    pub repulsion: f64,
    /// Spring strength along edges.
    pub attraction: f64,
    /// Cooling factor per iteration (temperature decreases).
    pub cooling: f64,
    /// Area width for initial placement.
    pub area_width: f64,
    /// Area height for initial placement.
    pub area_height: f64,
}

impl Default for ForceConfig {
    fn default() -> Self {
        Self {
            iterations: 100,
            repulsion: 10000.0,
            attraction: 0.01,
            cooling: 0.95,
            area_width: 800.0,
            area_height: 600.0,
        }
    }
}

/// Applies force-directed layout to a graph.
pub fn layout_force(
    nodes: &[LayoutNode],
    edges: &[LayoutEdge],
    config: &ForceConfig,
) -> LayoutResult {
    if nodes.is_empty() {
        return LayoutResult::new(Vec::new());
    }

    let n = nodes.len();
    let id_to_idx: HashMap<NodeId, usize> =
        nodes.iter().enumerate().map(|(i, n)| (n.id, i)).collect();

    let cols = (n as f64).sqrt().ceil() as usize;
    let rows = n.div_ceil(cols);
    let max_w = nodes.iter().map(node_width).fold(1.0, f64::max);
    let max_h = nodes.iter().map(node_height).fold(1.0, f64::max);
    let usable_w = (config.area_width - max_w).max(1.0);
    let usable_h = (config.area_height - max_h).max(1.0);
    let mut positions: Vec<(f64, f64)> = nodes
        .iter()
        .enumerate()
        .map(|(i, _)| {
            let col = i % cols;
            let row = i / cols;
            (
                max_w * 0.5 + usable_w * (col as f64 + 0.5) / cols as f64,
                max_h * 0.5 + usable_h * (row as f64 + 0.5) / rows as f64,
            )
        })
        .collect();

    let ideal_dist = (config.area_width * config.area_height / n as f64)
        .sqrt()
        .max(max_node_side(nodes) + 8.0);
    let mut temperature = ideal_dist;

    for _ in 0..config.iterations {
        let mut displacements: Vec<(f64, f64)> = vec![(0.0, 0.0); n];

        // Repulsive forces (all pairs)
        for i in 0..n {
            for j in (i + 1)..n {
                let dx = positions[i].0 - positions[j].0;
                let dy = positions[i].1 - positions[j].1;
                let dist = (dx * dx + dy * dy).sqrt().max(0.01);
                let min_dist = ((node_width(&nodes[i]) + node_width(&nodes[j]))
                    .max(node_height(&nodes[i]) + node_height(&nodes[j]))
                    * 0.5)
                    .max(ideal_dist * 0.35);
                let overlap_boost = if dist < min_dist {
                    (min_dist - dist) * 0.25
                } else {
                    0.0
                };
                let force = config.repulsion / (dist * dist) + overlap_boost;
                let fx = dx / dist * force;
                let fy = dy / dist * force;
                displacements[i].0 += fx;
                displacements[i].1 += fy;
                displacements[j].0 -= fx;
                displacements[j].1 -= fy;
            }
        }

        // Attractive forces (edges)
        for edge in edges {
            if let (Some(&i), Some(&j)) = (id_to_idx.get(&edge.from), id_to_idx.get(&edge.to)) {
                let dx = positions[i].0 - positions[j].0;
                let dy = positions[i].1 - positions[j].1;
                let dist = (dx * dx + dy * dy).sqrt().max(0.01);
                let force = dist * config.attraction * edge.weight;
                let fx = dx / dist * force;
                let fy = dy / dist * force;
                displacements[i].0 -= fx;
                displacements[i].1 -= fy;
                displacements[j].0 += fx;
                displacements[j].1 += fy;
            }
        }

        // Apply displacements (capped by temperature)
        for i in 0..n {
            let (dx, dy) = displacements[i];
            let mag = (dx * dx + dy * dy).sqrt().max(0.01);
            let capped_mag = mag.min(temperature);
            positions[i].0 += dx / mag * capped_mag;
            positions[i].1 += dy / mag * capped_mag;

            let half_w = node_width(&nodes[i]) * 0.5;
            let half_h = node_height(&nodes[i]) * 0.5;
            let max_x = (config.area_width - half_w).max(half_w);
            let max_y = (config.area_height - half_h).max(half_h);
            positions[i].0 = positions[i].0.clamp(half_w, max_x);
            positions[i].1 = positions[i].1.clamp(half_h, max_y);
        }

        temperature *= config.cooling;
    }

    let mut result_nodes: Vec<LayoutNode> = nodes
        .iter()
        .enumerate()
        .map(|(i, n)| {
            let mut node = n.clone();
            node.x = positions[i].0 - node_width(&node) * 0.5;
            node.y = positions[i].1 - node_height(&node) * 0.5;
            node
        })
        .collect();
    relax_overlaps(
        &mut result_nodes,
        4.0,
        Some((config.area_width, config.area_height)),
        8,
    );

    LayoutResult::new(result_nodes)
}
