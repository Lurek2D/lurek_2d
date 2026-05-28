//! Post-processing utilities: snap node positions to a grid and centre in a bounding box.
//!
//! - Functions: `snap_to_grid`, `center_in_area`.

use super::types::*;

/// Snaps all node positions to the nearest grid point.
pub fn snap_to_grid(result: &mut LayoutResult, grid_size: f64) {
    for node in &mut result.nodes {
        node.x = (node.x / grid_size).round() * grid_size;
        node.y = (node.y / grid_size).round() * grid_size;
    }
    result.width = result
        .nodes
        .iter()
        .map(|n| n.x + n.width)
        .fold(0.0f64, f64::max);
    result.height = result
        .nodes
        .iter()
        .map(|n| n.y + n.height)
        .fold(0.0f64, f64::max);
}

/// Centers the layout within a given area.
pub fn center_in_area(result: &mut LayoutResult, area_width: f64, area_height: f64) {
    if result.nodes.is_empty() {
        return;
    }

    let min_x = result
        .nodes
        .iter()
        .map(|n| n.x)
        .fold(f64::INFINITY, f64::min);
    let min_y = result
        .nodes
        .iter()
        .map(|n| n.y)
        .fold(f64::INFINITY, f64::min);
    let max_x = result
        .nodes
        .iter()
        .map(|n| n.x + n.width)
        .fold(f64::NEG_INFINITY, f64::max);
    let max_y = result
        .nodes
        .iter()
        .map(|n| n.y + n.height)
        .fold(f64::NEG_INFINITY, f64::max);

    let layout_w = max_x - min_x;
    let layout_h = max_y - min_y;

    let offset_x = (area_width - layout_w) / 2.0 - min_x;
    let offset_y = (area_height - layout_h) / 2.0 - min_y;

    for node in &mut result.nodes {
        node.x += offset_x;
        node.y += offset_y;
    }

    result.width = area_width;
    result.height = area_height;
}
