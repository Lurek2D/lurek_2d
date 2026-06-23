//! Owns deterministic row-column placement for dense, disconnected, or topology-neutral node sets.
//! Scores candidate column counts using real node widths, row heights, area, and readable aspect ratio.
//! Ignores edges by design, making it a fast fallback when graph topology should not drive placement.
//! Change this file for packed-grid defaults, variable cell sizing, or deterministic ordering behavior.

use super::types::*;

/// Lay out nodes in a compact square-ish grid using sorted node ids.
pub fn layout_grid(nodes: &[LayoutNode], config: &LayoutConfig) -> LayoutResult {
    if nodes.is_empty() {
        return LayoutResult::new(Vec::new());
    }

    let mut ordered = nodes.to_vec();
    ordered.sort_by_key(|node| node.id);

    let cols = choose_grid_columns(&ordered, config);
    let rows = ordered.len().div_ceil(cols);
    let mut col_widths = vec![1.0f64; cols];
    let mut row_heights = vec![1.0f64; rows];

    for (index, node) in ordered.iter().enumerate() {
        let col = index % cols;
        let row = index / cols;
        col_widths[col] = col_widths[col].max(node_width(node));
        row_heights[row] = row_heights[row].max(node_height(node));
    }

    let mut x_offsets = vec![config.margin; cols];
    for col in 1..cols {
        x_offsets[col] = x_offsets[col - 1] + col_widths[col - 1] + config.h_spacing.max(0.0);
    }
    let mut y_offsets = vec![config.margin; rows];
    for row in 1..rows {
        y_offsets[row] = y_offsets[row - 1] + row_heights[row - 1] + config.v_spacing.max(0.0);
    }

    for (index, node) in ordered.iter_mut().enumerate() {
        let col = index % cols;
        let row = index / cols;
        node.x = x_offsets[col] + (col_widths[col] - node_width(node)) * 0.5;
        node.y = y_offsets[row] + (row_heights[row] - node_height(node)) * 0.5;
    }

    LayoutResult::new(ordered)
}

fn choose_grid_columns(nodes: &[LayoutNode], config: &LayoutConfig) -> usize {
    let count = nodes.len();
    let target_aspect = 1.6f64;
    let mut best_cols = 1usize;
    let mut best_score = f64::INFINITY;

    for cols in 1..=count {
        let rows = count.div_ceil(cols);
        let mut col_widths = vec![1.0f64; cols];
        let mut row_heights = vec![1.0f64; rows];
        for (index, node) in nodes.iter().enumerate() {
            let col = index % cols;
            let row = index / cols;
            col_widths[col] = col_widths[col].max(node_width(node));
            row_heights[row] = row_heights[row].max(node_height(node));
        }
        let width = col_widths.iter().sum::<f64>()
            + config.h_spacing.max(0.0) * cols.saturating_sub(1) as f64;
        let height = row_heights.iter().sum::<f64>()
            + config.v_spacing.max(0.0) * rows.saturating_sub(1) as f64;
        let aspect = width / height.max(1.0);
        let aspect_penalty = ((aspect - target_aspect).abs() / target_aspect).min(4.0);
        let score = width * height * (1.0 + aspect_penalty * 0.35);
        if score < best_score {
            best_score = score;
            best_cols = cols;
        }
    }

    best_cols
}
