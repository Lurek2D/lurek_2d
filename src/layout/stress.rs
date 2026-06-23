//! `src/layout/stress.rs` owns distance-preserving graph placement for topology-readable arbitrary graphs.
//! It provides a lightweight stress layout inspired by multidimensional scaling without keeping persistent solver state.
//! The algorithm computes graph distances, seeds positions on a circle, relaxes pairs, and clears overlaps.
//! Iteration count is capped through `StressConfig` so callers can choose stable output or fast 10 FPS refreshes.
//! Read it when graph-distance preservation, relaxation cost, or default stress tuning need to change.

use super::types::*;
use std::collections::{HashMap, HashSet, VecDeque};

/// Configuration for lightweight stress-based graph layout.
#[derive(Debug, Clone)]
pub struct StressConfig {
    /// Number of relaxation iterations to run.
    pub iterations: usize,
    /// Target edge length in layout units.
    pub edge_length: f64,
    /// Relaxation amount per pair per iteration.
    pub step: f64,
}

impl Default for StressConfig {
    fn default() -> Self {
        Self {
            iterations: 24,
            edge_length: 80.0,
            step: 0.08,
        }
    }
}

/// Lay out a graph by preserving shortest-path distances with bounded iterative relaxation.
pub fn layout_stress(
    nodes: &[LayoutNode],
    edges: &[LayoutEdge],
    config: &StressConfig,
) -> LayoutResult {
    if nodes.is_empty() {
        return LayoutResult::new(Vec::new());
    }

    let mut ordered = nodes.to_vec();
    ordered.sort_by_key(|node| node.id);
    let n = ordered.len();
    let id_to_idx: HashMap<NodeId, usize> = ordered
        .iter()
        .enumerate()
        .map(|(index, node)| (node.id, index))
        .collect();
    let node_set: HashSet<NodeId> = id_to_idx.keys().copied().collect();

    let mut adj = vec![Vec::<usize>::new(); n];
    for edge in edges {
        if node_set.contains(&edge.from) && node_set.contains(&edge.to) {
            let a = id_to_idx[&edge.from];
            let b = id_to_idx[&edge.to];
            adj[a].push(b);
            adj[b].push(a);
        }
    }
    for neighbors in &mut adj {
        neighbors.sort_unstable();
        neighbors.dedup();
    }

    let mut distances = vec![vec![usize::MAX; n]; n];
    for (start, row) in distances.iter_mut().enumerate() {
        row[start] = 0;
        let mut queue = VecDeque::from([start]);
        while let Some(current) = queue.pop_front() {
            let next_distance = row[current] + 1;
            for &next in &adj[current] {
                if row[next] == usize::MAX {
                    row[next] = next_distance;
                    queue.push_back(next);
                }
            }
        }
    }

    let max_w = ordered.iter().map(|node| node.width).fold(1.0, f64::max);
    let max_h = ordered.iter().map(|node| node.height).fold(1.0, f64::max);
    let seed_radius = (n as f64 * config.edge_length / std::f64::consts::TAU)
        .max(config.edge_length)
        .max(1.0);
    let mut positions: Vec<(f64, f64)> = (0..n)
        .map(|index| {
            let angle =
                -std::f64::consts::FRAC_PI_2 + std::f64::consts::TAU * index as f64 / n as f64;
            (seed_radius * angle.cos(), seed_radius * angle.sin())
        })
        .collect();

    let step = config.step.clamp(0.0, 0.5);
    for _ in 0..config.iterations {
        let mut delta = vec![(0.0, 0.0); n];
        for i in 0..n {
            for j in (i + 1)..n {
                let graph_distance = distances[i][j];
                let target = if graph_distance == usize::MAX {
                    config.edge_length * (n as f64).sqrt().max(2.0)
                } else {
                    config.edge_length * graph_distance.max(1) as f64
                };
                let dx = positions[j].0 - positions[i].0;
                let dy = positions[j].1 - positions[i].1;
                let dist = (dx * dx + dy * dy).sqrt().max(0.001);
                let adjust = (dist - target) / dist * step;
                let fx = dx * adjust;
                let fy = dy * adjust;
                delta[i].0 += fx;
                delta[i].1 += fy;
                delta[j].0 -= fx;
                delta[j].1 -= fy;
            }
        }
        for (position, (dx, dy)) in positions.iter_mut().zip(delta) {
            position.0 += dx;
            position.1 += dy;
        }
    }

    let min_x = positions
        .iter()
        .map(|(x, _)| *x)
        .fold(f64::INFINITY, f64::min);
    let min_y = positions
        .iter()
        .map(|(_, y)| *y)
        .fold(f64::INFINITY, f64::min);
    for (node, (x, y)) in ordered.iter_mut().zip(positions) {
        node.x = config.edge_length + x - min_x + max_w * 0.5;
        node.y = config.edge_length + y - min_y + max_h * 0.5;
    }
    relax_overlaps(&mut ordered, config.edge_length * 0.08, None, 6);
    normalize_to_margin(&mut ordered, config.edge_length.max(1.0));

    LayoutResult::new(ordered)
}
