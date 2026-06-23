//! Owns deterministic circular placement for cycle-heavy graphs, overviews, and equal-emphasis node sets.
//! Computes a chord-safe radius from real node sizes and spacing, then places sorted ids on one ring.
//! Keeps no graph traversal state; change this file only for ring geometry, radius, or ordering behavior.

use super::types::*;

/// Lay out nodes evenly around a circle using sorted node ids for deterministic output.
pub fn layout_circular(nodes: &[LayoutNode], config: &LayoutConfig) -> LayoutResult {
    if nodes.is_empty() {
        return LayoutResult::new(Vec::new());
    }

    let mut ordered = nodes.to_vec();
    ordered.sort_by_key(|node| node.id);

    let count = ordered.len();
    let max_w = ordered.iter().map(|node| node.width).fold(1.0, f64::max);
    let max_h = ordered.iter().map(|node| node.height).fold(1.0, f64::max);
    if count == 1 {
        ordered[0].x = config.margin;
        ordered[0].y = config.margin;
        return LayoutResult::new(ordered);
    }

    let spacing = config.h_spacing.max(config.v_spacing).max(1.0);
    let chord = (max_w.hypot(max_h) + spacing).max(1.0);
    let radius = if count == 2 {
        chord * 0.5
    } else {
        chord / (2.0 * (std::f64::consts::PI / count as f64).sin())
    }
    .max(config.v_spacing.max(1.0));
    let cx = config.margin + radius + max_w * 0.5;
    let cy = config.margin + radius + max_h * 0.5;

    for (index, node) in ordered.iter_mut().enumerate() {
        let angle =
            -std::f64::consts::FRAC_PI_2 + std::f64::consts::TAU * index as f64 / count as f64;
        node.x = cx + radius * angle.cos() - node.width * 0.5;
        node.y = cy + radius * angle.sin() - node.height * 0.5;
    }

    LayoutResult::new(ordered)
}
