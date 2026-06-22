//! Owns the raycaster overlay owner for the minimap subsystem and keeps its rules local to this file.
//! Keeps minimap data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
//! Defines how raycaster overlay data is validated, transformed, or stored before neighboring systems use it.
//! Owns minimap behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on raycaster overlay behavior while Lua registration stays elsewhere.
//! Documents the boundary where minimap code accepts inputs, reports errors, or updates state.
//! Use this file when changing raycaster overlay defaults, lifecycle handling, validation, or data ownership.

use super::types::{MinimapError, MinimapLimits};
use crate::raycaster::dda::Raycaster2D;
use crate::raycaster::lighting::{compute_lighting, PointLight};
use std::collections::HashSet;

/// A tile sample used to build a minimap view window centered on the player.
#[derive(Debug, Clone)]
pub struct MinimapTileSample {
    /// Grid X coordinate of this tile.
    pub x: u32,
    /// Grid Y coordinate of this tile.
    pub y: u32,
    /// True when this tile is a solid wall.
    pub blocked: bool,
    /// True when this tile has direct line-of-sight from the player.
    pub visible: bool,
    /// Accumulated RGB light at this tile's center.
    pub light: [f32; 3],
    /// Luminance (average of `light` channels) in 0.0..1.0.
    pub luma: f32,
}

/// Return true when the Bresenham grid path from `(x0,y0)` to `(x1,y1)` is unobstructed.
fn tile_line_of_sight(raycaster: &Raycaster2D, x0: i32, y0: i32, x1: i32, y1: i32) -> bool {
    raycaster.line_of_sight(
        x0 as f32 + 0.5,
        y0 as f32 + 0.5,
        x1 as f32 + 0.5,
        y1 as f32 + 0.5,
    )
}

/// Compute accumulated RGB light for the center of tile `(x, y)` using `compute_lighting`.
pub fn compute_tile_light(
    raycaster: &Raycaster2D,
    x: u32,
    y: u32,
    ambient: f32,
    lights: &[PointLight],
) -> [f32; 3] {
    if x >= raycaster.width() || y >= raycaster.height() {
        let a = ambient.clamp(0.0, 1.0);
        return [a, a, a];
    }
    let wx = x as f32 + 0.5;
    let wy = y as f32 + 0.5;
    let wall_at = |cx: i32, cy: i32| -> bool {
        cx < 0 || cy < 0 || raycaster.blocks_light_at(cx as u32, cy as u32)
    };
    compute_lighting(wx, wy, ambient, lights, &wall_at)
}

/// Return all `MinimapTileSample`s in a `radius`-tile square window centered on `(center_x, center_y)`.
pub fn build_minimap_tile_window(
    raycaster: &Raycaster2D,
    center_x: f32,
    center_y: f32,
    radius: u32,
    ambient: f32,
    lights: &[PointLight],
) -> Vec<MinimapTileSample> {
    let cx = center_x.floor() as i32;
    let cy = center_y.floor() as i32;
    let r = radius as i32;
    let mut out = Vec::new();
    for gy in (cy - r)..=(cy + r) {
        for gx in (cx - r)..=(cx + r) {
            if gx < 0 || gy < 0 {
                continue;
            }
            let ux = gx as u32;
            let uy = gy as u32;
            if ux >= raycaster.width() || uy >= raycaster.height() {
                continue;
            }
            let blocked = raycaster.is_blocked(ux, uy);
            let visible = tile_line_of_sight(raycaster, cx, cy, gx, gy);
            let light = compute_tile_light(raycaster, ux, uy, ambient, lights);
            let luma = ((light[0] + light[1] + light[2]) / 3.0).clamp(0.0, 1.0);
            out.push(MinimapTileSample {
                x: ux,
                y: uy,
                blocked,
                visible,
                light,
                luma,
            });
        }
    }
    out
}

/// Cast a FOV fan of `count` rays from `(ox, oy)` and collect all traversed tile coordinates.
#[allow(clippy::too_many_arguments)]
pub fn reveal_cells_from_rays(
    raycaster: &Raycaster2D,
    ox: f32,
    oy: f32,
    angle: f32,
    fov: f32,
    count: u32,
    max_dist: f32,
    step: f32,
) -> Vec<(u32, u32)> {
    if !ox.is_finite()
        || !oy.is_finite()
        || !angle.is_finite()
        || !fov.is_finite()
        || !max_dist.is_finite()
    {
        return Vec::new();
    }
    let step = step.max(0.05);
    let mut visited: HashSet<(u32, u32)> = HashSet::new();
    let mut cells = Vec::new();
    let add_cell =
        |visited: &mut HashSet<(u32, u32)>, cells: &mut Vec<(u32, u32)>, x: f32, y: f32| {
            if x.is_finite() && y.is_finite() && x >= 0.0 && y >= 0.0 {
                let gx = x.floor() as u32;
                let gy = y.floor() as u32;
                if gx < raycaster.width() && gy < raycaster.height() && visited.insert((gx, gy)) {
                    cells.push((gx, gy));
                }
            }
        };
    add_cell(&mut visited, &mut cells, ox, oy);
    let hits = raycaster.cast_rays(ox, oy, angle, fov, count, max_dist);
    for hit in hits {
        let dx = hit.hit_x - ox;
        let dy = hit.hit_y - oy;
        let dist = (dx * dx + dy * dy).sqrt();
        let steps = (dist / step).max(1.0).floor() as u32;
        for i in 0..=steps {
            let t = i as f32 / steps.max(1) as f32;
            add_cell(&mut visited, &mut cells, ox + dx * t, oy + dy * t);
        }
    }
    cells
}

/// Render a `view_radius`-tile minimap pixel grid centered on the player; return `(pixels, width, height)`.
#[allow(clippy::too_many_arguments)]
pub fn extract_minimap(
    raycaster: &Raycaster2D,
    player_x: f32,
    player_y: f32,
    player_angle: f32,
    view_radius: u32,
    cell_size: u32,
    wall_color: [u8; 4],
    floor_color: [u8; 4],
    player_color: [u8; 4],
) -> (Vec<u8>, u32, u32) {
    try_extract_minimap(
        raycaster,
        player_x,
        player_y,
        player_angle,
        view_radius,
        cell_size,
        wall_color,
        floor_color,
        player_color,
    )
    .expect("extract_minimap received invalid dimensions; use try_extract_minimap for fallible extraction")
}

/// Render a `view_radius`-tile minimap pixel grid centered on the player; return `(pixels, width, height)`.
#[allow(clippy::too_many_arguments)]
pub fn try_extract_minimap(
    raycaster: &Raycaster2D,
    player_x: f32,
    player_y: f32,
    player_angle: f32,
    view_radius: u32,
    cell_size: u32,
    wall_color: [u8; 4],
    floor_color: [u8; 4],
    player_color: [u8; 4],
) -> Result<(Vec<u8>, u32, u32), MinimapError> {
    if !player_x.is_finite() || !player_y.is_finite() {
        return Err(MinimapError::InvalidFloat {
            field: "player position",
        });
    }
    if !player_angle.is_finite() {
        return Err(MinimapError::InvalidFloat {
            field: "player angle",
        });
    }
    if cell_size == 0 {
        return Err(MinimapError::CellSizeZero);
    }
    let limits = MinimapLimits::default();
    if view_radius > limits.max_view_radius {
        return Err(MinimapError::PixelLimitExceeded {
            pixel_count: u64::from(view_radius),
            limit: u64::from(limits.max_view_radius),
        });
    }

    let diameter = view_radius
        .checked_mul(2)
        .and_then(|value| value.checked_add(1))
        .ok_or(MinimapError::PixelLimitExceeded {
            pixel_count: u64::MAX,
            limit: limits.max_display_pixels,
        })?;
    let pixel_w = diameter
        .checked_mul(cell_size)
        .ok_or(MinimapError::PixelLimitExceeded {
            pixel_count: u64::MAX,
            limit: limits.max_display_pixels,
        })?;
    let pixel_h = diameter
        .checked_mul(cell_size)
        .ok_or(MinimapError::PixelLimitExceeded {
            pixel_count: u64::MAX,
            limit: limits.max_display_pixels,
        })?;

    let pixel_count = u64::from(pixel_w).checked_mul(u64::from(pixel_h)).ok_or(
        MinimapError::PixelLimitExceeded {
            pixel_count: u64::MAX,
            limit: limits.max_display_pixels,
        },
    )?;
    if pixel_count > limits.max_display_pixels {
        return Err(MinimapError::PixelLimitExceeded {
            pixel_count,
            limit: limits.max_display_pixels,
        });
    }

    let byte_count = pixel_count
        .checked_mul(4)
        .ok_or(MinimapError::OutputByteLimitExceeded {
            byte_count: u64::MAX,
            limit: limits.max_output_bytes,
        })?;
    if byte_count > limits.max_output_bytes {
        return Err(MinimapError::OutputByteLimitExceeded {
            byte_count,
            limit: limits.max_output_bytes,
        });
    }

    let len = usize::try_from(byte_count).map_err(|_| MinimapError::OutputByteLimitExceeded {
        byte_count,
        limit: limits.max_output_bytes,
    })?;
    let mut pixels = vec![0u8; len];
    let player_cell_x = player_x.floor() as i32;
    let player_cell_y = player_y.floor() as i32;
    for vy in 0..diameter {
        for vx in 0..diameter {
            let cell_x = player_cell_x - view_radius as i32 + vx as i32;
            let cell_y = player_cell_y - view_radius as i32 + vy as i32;
            let is_wall = if cell_x >= 0 && cell_y >= 0 {
                raycaster.get_cell(cell_x as u32, cell_y as u32) > 0
            } else {
                false
            };
            let color = if is_wall { wall_color } else { floor_color };
            for py in 0..cell_size {
                for px in 0..cell_size {
                    let img_x = vx * cell_size + px;
                    let img_y = vy * cell_size + py;
                    let idx = ((img_y * pixel_w + img_x) * 4) as usize;
                    pixels[idx] = color[0];
                    pixels[idx + 1] = color[1];
                    pixels[idx + 2] = color[2];
                    pixels[idx + 3] = color[3];
                }
            }
        }
    }
    let center_px = view_radius * cell_size + cell_size / 2;
    let center_py = view_radius * cell_size + cell_size / 2;
    try_draw_player_arrow(
        &mut pixels,
        pixel_w,
        pixel_h,
        center_px,
        center_py,
        player_angle,
        cell_size.max(3),
        player_color,
    )?;
    Ok((pixels, pixel_w, pixel_h))
}

/// Draw a filled circle with a forward-direction line at `(center_x, center_y)` into a raw RGBA pixel slice.
#[allow(clippy::too_many_arguments)]
pub fn draw_player_arrow(
    pixels: &mut [u8],
    img_width: u32,
    img_height: u32,
    center_x: u32,
    center_y: u32,
    angle: f32,
    size: u32,
    color: [u8; 4],
) {
    let _ = try_draw_player_arrow(
        pixels, img_width, img_height, center_x, center_y, angle, size, color,
    );
}

/// Draw a filled circle with a forward-direction line at `(center_x, center_y)` into a raw RGBA pixel slice.
#[allow(clippy::too_many_arguments)]
pub fn try_draw_player_arrow(
    pixels: &mut [u8],
    img_width: u32,
    img_height: u32,
    center_x: u32,
    center_y: u32,
    angle: f32,
    size: u32,
    color: [u8; 4],
) -> Result<(), MinimapError> {
    if !angle.is_finite() {
        return Err(MinimapError::InvalidFloat {
            field: "player angle",
        });
    }
    let expected = u64::from(img_width)
        .checked_mul(u64::from(img_height))
        .and_then(|pixels_len| pixels_len.checked_mul(4))
        .ok_or(MinimapError::OutputByteLimitExceeded {
            byte_count: u64::MAX,
            limit: MinimapLimits::default().max_output_bytes,
        })?;
    if pixels.len() != expected as usize {
        return Err(MinimapError::InvalidImageBuffer {
            width: img_width,
            height: img_height,
            len: pixels.len(),
            expected: expected as usize,
        });
    }

    let half = size as f32 / 2.0;
    let radius = (half * 0.6).max(1.0);
    let r2 = radius * radius;
    for dy in -(radius as i32)..=(radius as i32) {
        for dx in -(radius as i32)..=(radius as i32) {
            if (dx * dx + dy * dy) as f32 <= r2 {
                let px = center_x as i32 + dx;
                let py = center_y as i32 + dy;
                if px >= 0 && py >= 0 && (px as u32) < img_width && (py as u32) < img_height {
                    let idx = ((py as u32 * img_width + px as u32) * 4) as usize;
                    pixels[idx] = color[0];
                    pixels[idx + 1] = color[1];
                    pixels[idx + 2] = color[2];
                    pixels[idx + 3] = color[3];
                }
            }
        }
    }
    let line_len = half;
    let tip_x = center_x as f32 + angle.cos() * line_len;
    let tip_y = center_y as f32 + angle.sin() * line_len;
    let steps = (line_len * 2.0) as i32;
    for i in 0..=steps {
        let t = i as f32 / steps.max(1) as f32;
        let lx = center_x as f32 + (tip_x - center_x as f32) * t;
        let ly = center_y as f32 + (tip_y - center_y as f32) * t;
        if !lx.is_finite() || !ly.is_finite() {
            continue;
        }
        let px = lx as i32;
        let py = ly as i32;
        if px >= 0 && py >= 0 && (px as u32) < img_width && (py as u32) < img_height {
            let idx = ((py as u32 * img_width + px as u32) * 4) as usize;
            pixels[idx] = color[0];
            pixels[idx + 1] = color[1];
            pixels[idx + 2] = color[2];
            pixels[idx + 3] = color[3];
        }
    }
    Ok(())
}
