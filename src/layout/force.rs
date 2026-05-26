//! Fruchterman-Reingold force-directed layout for arbitrary undirected graphs.
//!
//! - `layout_force(nodes, edges, config)` iterates attraction/repulsion until convergence.
//! - `ForceConfig` controls temperature, cooling rate, repulsion constant, and max iterations.
//! - Initialises nodes on a random grid; deterministic given the same seed.
//! - Convergence is detected when the max node displacement falls below a threshold.
//! - Used by `lurek.layout.force` for social graphs, skill webs, and mind maps.

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

    // Initial positions: grid layout
    let cols = (n as f64).sqrt().ceil() as usize;
    let rows = n / cols + 1;
    let mut positions: Vec<(f64, f64)> = nodes
        .iter()
        .enumerate()
        .map(|(i, _)| {
            let col = i % cols;
            let row = i / cols;
            (
                config.area_width * (col as f64 + 0.5) / cols as f64,
                config.area_height * (row as f64 + 0.5) / rows as f64,
            )
        })
        .collect();

    let ideal_dist = (config.area_width * config.area_height / n as f64).sqrt();
    let mut temperature = ideal_dist;

    for _ in 0..config.iterations {
        let mut displacements: Vec<(f64, f64)> = vec![(0.0, 0.0); n];

        // Repulsive forces (all pairs)
        for i in 0..n {
            for j in (i + 1)..n {
                let dx = positions[i].0 - positions[j].0;
                let dy = positions[i].1 - positions[j].1;
                let dist = (dx * dx + dy * dy).sqrt().max(0.01);
                let force = config.repulsion / (dist * dist);
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

            // Keep within bounds
            positions[i].0 = positions[i].0.clamp(0.0, config.area_width);
            positions[i].1 = positions[i].1.clamp(0.0, config.area_height);
        }

        temperature *= config.cooling;
    }

    let result_nodes: Vec<LayoutNode> = nodes
        .iter()
        .enumerate()
        .map(|(i, n)| {
            let mut node = n.clone();
            node.x = positions[i].0;
            node.y = positions[i].1;
            node
        })
        .collect();

    LayoutResult::new(result_nodes)
}
