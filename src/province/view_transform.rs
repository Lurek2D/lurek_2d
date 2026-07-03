//! Owns the province view transform implementation for the province subsystem and keeps related runtime rules local here.
//! Keeps province data, render helpers, and map-facing transforms so helpers stay close to invariants this file updates.
//! Defines how province view transform data is validated, transformed, or stored before neighboring systems consume it.
//! Separates province view transform behavior from Lua bindings, tests, and sibling owners so integration stays readable.

use crate::camera::{fit_content_to_screen, screen_to_content, zoom_offset_at};

/// Return (cam_x, cam_y, zoom) that fits the full map centred on screen; clamps zoom to ≥ 0.0001.
pub fn fit_camera_to_screen(
    map_w: u32,
    map_h: u32,
    pixel_size: f32,
    screen_w: f32,
    screen_h: f32,
) -> (f32, f32, f32) {
    fit_content_to_screen(map_w as f32, map_h as f32, pixel_size, screen_w, screen_h)
}
/// Convert a screen pixel coordinate to a floating-point map coordinate using camera offset and zoom; denom clamped to ≥ 0.0001.
pub fn screen_to_map(
    screen_x: f32,
    screen_y: f32,
    cam_x: f32,
    cam_y: f32,
    zoom: f32,
    pixel_size: f32,
) -> (f32, f32) {
    screen_to_content(screen_x, screen_y, cam_x, cam_y, zoom, pixel_size)
}
/// Convert a map coordinate to an integer cell (x, y); return None if out-of-bounds or non-finite.
pub fn map_to_cell(map_x: f32, map_y: f32, map_w: u32, map_h: u32) -> Option<(u32, u32)> {
    if !map_x.is_finite() || !map_y.is_finite() {
        return None;
    }
    let cell_x = map_x.floor();
    let cell_y = map_y.floor();
    if cell_x < 0.0 || cell_y < 0.0 {
        return None;
    }
    let x = cell_x as u32;
    let y = cell_y as u32;
    if x < map_w && y < map_h {
        Some((x, y))
    } else {
        None
    }
}
/// Return the new camera (x, y) after zooming from old_zoom to new_zoom keeping anchor_x/anchor_y stationary.
pub fn zoom_camera_at(
    anchor_x: f32,
    anchor_y: f32,
    cam_x: f32,
    cam_y: f32,
    old_zoom: f32,
    new_zoom: f32,
) -> (f32, f32) {
    zoom_offset_at(anchor_x, anchor_y, cam_x, cam_y, old_zoom, new_zoom)
}
