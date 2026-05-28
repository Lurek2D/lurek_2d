//! Internal rasterisation utilities shared by all chart renderers.
//!
//! - Functions: `set_pixel`, `draw_line`, `draw_rect_filled`, `draw_circle_filled`, and 3 more.
//! - Uses: `charts`.

use crate::charts::config::ChartSeries;

/// Set a single pixel in the buffer to the given color.
///
/// Coordinates outside the buffer dimensions are silently ignored.
pub fn set_pixel(buffer: &mut [u8], width: u32, x: u32, y: u32, color: [f32; 4]) {
    let idx = ((y * width + x) * 4) as usize;
    if idx + 3 < buffer.len() {
        buffer[idx] = (color[0] * 255.0) as u8;
        buffer[idx + 1] = (color[1] * 255.0) as u8;
        buffer[idx + 2] = (color[2] * 255.0) as u8;
        buffer[idx + 3] = (color[3] * 255.0) as u8;
    }
}

/// Draw a line between two points using Bresenham's algorithm.
///
/// Floating-point endpoints are rounded to the nearest pixel.
#[allow(clippy::too_many_arguments)]
pub fn draw_line(
    buffer: &mut [u8],
    width: u32,
    height: u32,
    x0: f32,
    y0: f32,
    x1: f32,
    y1: f32,
    color: [f32; 4],
) {
    let mut ix0 = x0.round() as i32;
    let mut iy0 = y0.round() as i32;
    let ix1 = x1.round() as i32;
    let iy1 = y1.round() as i32;

    let dx = (ix1 - ix0).abs();
    let dy = -(iy1 - iy0).abs();
    let sx = if ix0 < ix1 { 1 } else { -1 };
    let sy = if iy0 < iy1 { 1 } else { -1 };
    let mut err = dx + dy;

    loop {
        if ix0 >= 0 && iy0 >= 0 && (ix0 as u32) < width && (iy0 as u32) < height {
            set_pixel(buffer, width, ix0 as u32, iy0 as u32, color);
        }
        if ix0 == ix1 && iy0 == iy1 {
            break;
        }
        let e2 = 2 * err;
        if e2 >= dy {
            err += dy;
            ix0 += sx;
        }
        if e2 <= dx {
            err += dx;
            iy0 += sy;
        }
    }
}

/// Draw a filled axis-aligned rectangle.
///
/// Pixels outside the buffer bounds are clipped.
pub fn draw_rect_filled(
    buffer: &mut [u8],
    width: u32,
    x: u32,
    y: u32,
    w: u32,
    h: u32,
    color: [f32; 4],
) {
    let height = buffer.len() as u32 / (width * 4);
    for row in y..y.saturating_add(h).min(height) {
        for col in x..x.saturating_add(w).min(width) {
            set_pixel(buffer, width, col, row, color);
        }
    }
}

/// Draw a filled circle using per-pixel distance test.
///
/// Pixels outside the buffer bounds are clipped.
pub fn draw_circle_filled(
    buffer: &mut [u8],
    width: u32,
    height: u32,
    cx: f32,
    cy: f32,
    radius: f32,
    color: [f32; 4],
) {
    let r2 = radius * radius;
    let min_x = ((cx - radius).floor() as i32).max(0) as u32;
    let max_x = ((cx + radius).ceil() as i32).min(width as i32 - 1).max(0) as u32;
    let min_y = ((cy - radius).floor() as i32).max(0) as u32;
    let max_y = ((cy + radius).ceil() as i32).min(height as i32 - 1).max(0) as u32;

    for py in min_y..=max_y {
        for px in min_x..=max_x {
            let dx = px as f32 - cx;
            let dy = py as f32 - cy;
            if dx * dx + dy * dy <= r2 {
                set_pixel(buffer, width, px, py, color);
            }
        }
    }
}

/// Fill the entire buffer with a single color.
pub fn fill_buffer(buffer: &mut [u8], color: [f32; 4]) {
    let r = (color[0] * 255.0) as u8;
    let g = (color[1] * 255.0) as u8;
    let b = (color[2] * 255.0) as u8;
    let a = (color[3] * 255.0) as u8;
    for chunk in buffer.chunks_exact_mut(4) {
        chunk[0] = r;
        chunk[1] = g;
        chunk[2] = b;
        chunk[3] = a;
    }
}

/// Compute the bounding range across all series.
///
/// Returns `(min_x, max_x, min_y, max_y)`. If no data points exist,
/// returns `(0.0, 1.0, 0.0, 1.0)` to avoid degenerate ranges.
pub fn auto_range(series: &[ChartSeries]) -> (f32, f32, f32, f32) {
    let mut min_x = f32::MAX;
    let mut max_x = f32::MIN;
    let mut min_y = f32::MAX;
    let mut max_y = f32::MIN;
    let mut has_data = false;

    for s in series {
        for &(x, y) in &s.data {
            has_data = true;
            if x < min_x {
                min_x = x;
            }
            if x > max_x {
                max_x = x;
            }
            if y < min_y {
                min_y = y;
            }
            if y > max_y {
                max_y = y;
            }
        }
    }

    if !has_data {
        return (0.0, 1.0, 0.0, 1.0);
    }

    // Prevent zero-size ranges.
    if (max_x - min_x).abs() < f32::EPSILON {
        max_x = min_x + 1.0;
    }
    if (max_y - min_y).abs() < f32::EPSILON {
        max_y = min_y + 1.0;
    }

    (min_x, max_x, min_y, max_y)
}

/// Map a data-space value to a screen-space pixel coordinate.
///
/// Linearly interpolates `value` from `[min, max]` to `[0, screen_size]`.
pub fn world_to_screen(value: f32, min: f32, max: f32, screen_size: f32) -> f32 {
    if (max - min).abs() < f32::EPSILON {
        return screen_size * 0.5;
    }
    (value - min) / (max - min) * screen_size
}
