//! Renderer-owned CPU geometry primitives shared by software and segment paths.
//!
//! These helpers intentionally know only about RGBA pixel buffers and flat
//! triangles/segments.  Province identity, topology, styles, and map-space
//! policy remain in `province`; this module owns the final raster primitive
//! work used by the explicit segments backend and evidence capture.

/// Write one opaque RGBA pixel when the destination coordinate is in bounds.
pub(crate) fn put_pixel(
    pixels: &mut [u8],
    width: u32,
    height: u32,
    x: i32,
    y: i32,
    color: [u8; 4],
) {
    if x < 0 || y < 0 || x >= width as i32 || y >= height as i32 {
        return;
    }
    let idx = ((y as u32 * width + x as u32) * 4) as usize;
    pixels[idx..idx + 4].copy_from_slice(&color);
}

/// Alpha-blend one RGBA pixel when the destination coordinate is in bounds.
pub(crate) fn blend_pixel(
    pixels: &mut [u8],
    width: u32,
    height: u32,
    x: i32,
    y: i32,
    color: [u8; 4],
) {
    if x < 0 || y < 0 || x >= width as i32 || y >= height as i32 {
        return;
    }
    let idx = ((y as u32 * width + x as u32) * 4) as usize;
    let alpha = color[3] as f32 / 255.0;
    let inv = 1.0 - alpha;
    pixels[idx] = (color[0] as f32 * alpha + pixels[idx] as f32 * inv).round() as u8;
    pixels[idx + 1] = (color[1] as f32 * alpha + pixels[idx + 1] as f32 * inv).round() as u8;
    pixels[idx + 2] = (color[2] as f32 * alpha + pixels[idx + 2] as f32 * inv).round() as u8;
    pixels[idx + 3] = 255;
}

/// Smooth Hermite interpolation used by soft border shadows.
pub(crate) fn smoothstep(edge0: f32, edge1: f32, x: f32) -> f32 {
    let t = ((x - edge0) / (edge1 - edge0)).clamp(0.0, 1.0);
    t * t * (3.0 - 2.0 * t)
}

/// Distance from a point to a finite line segment.
pub(crate) fn distance_to_segment(px: f32, py: f32, x0: f32, y0: f32, x1: f32, y1: f32) -> f32 {
    let dx = x1 - x0;
    let dy = y1 - y0;
    let len_sq = dx * dx + dy * dy;
    if len_sq <= f32::EPSILON {
        return ((px - x0) * (px - x0) + (py - y0) * (py - y0)).sqrt();
    }
    let t = (((px - x0) * dx + (py - y0) * dy) / len_sq).clamp(0.0, 1.0);
    let qx = x0 + t * dx;
    let qy = y0 + t * dy;
    ((px - qx) * (px - qx) + (py - qy) * (py - qy)).sqrt()
}

/// Rasterize a stroked line segment into an RGBA buffer.
pub(crate) fn draw_thick_segment(
    pixels: &mut [u8],
    width: u32,
    height: u32,
    p0: (f32, f32),
    p1: (f32, f32),
    thickness: f32,
    color: [u8; 4],
) {
    let half = ((thickness - 1.0) * 0.5).max(0.0);
    let margin = half.ceil() as i32 + 1;
    let min_x = p0.0.min(p1.0).floor() as i32 - margin;
    let max_x = p0.0.max(p1.0).ceil() as i32 + margin;
    let min_y = p0.1.min(p1.1).floor() as i32 - margin;
    let max_y = p0.1.max(p1.1).ceil() as i32 + margin;
    for y in min_y..=max_y {
        for x in min_x..=max_x {
            let distance =
                distance_to_segment(x as f32 + 0.5, y as f32 + 0.5, p0.0, p0.1, p1.0, p1.1);
            if distance <= half + 0.5 {
                put_pixel(pixels, width, height, x, y, color);
            }
        }
    }
}

/// Rasterize one filled triangle into an integer-scaled map buffer.
#[allow(clippy::too_many_arguments)]
pub(crate) fn rasterize_triangle(
    pixels: &mut [u8],
    width: u32,
    height: u32,
    origin_x: u32,
    origin_y: u32,
    scale: u32,
    a: (f32, f32),
    b: (f32, f32),
    c: (f32, f32),
    color: [u8; 4],
) {
    let min_x = a.0.min(b.0).min(c.0).floor() as i32;
    let max_x = a.0.max(b.0).max(c.0).ceil() as i32;
    let min_y = a.1.min(b.1).min(c.1).floor() as i32;
    let max_y = a.1.max(b.1).max(c.1).ceil() as i32;
    for map_y in min_y..=max_y {
        for map_x in min_x..=max_x {
            if map_x < origin_x as i32 || map_y < origin_y as i32 {
                continue;
            }
            let px = (map_x - origin_x as i32) as u32;
            let py = (map_y - origin_y as i32) as u32;
            if px >= width / scale.max(1) || py >= height / scale.max(1) {
                continue;
            }
            let point = (map_x as f32 + 0.5, map_y as f32 + 0.5);
            if !point_in_triangle(point, a, b, c) {
                continue;
            }
            for sy in 0..scale {
                for sx in 0..scale {
                    let out_x = px * scale + sx;
                    let out_y = py * scale + sy;
                    let index = ((out_y * width + out_x) * 4) as usize;
                    pixels[index..index + 4].copy_from_slice(&color);
                }
            }
        }
    }
}

fn point_in_triangle(p: (f32, f32), a: (f32, f32), b: (f32, f32), c: (f32, f32)) -> bool {
    let ab = orientation(a, b, p);
    let bc = orientation(b, c, p);
    let ca = orientation(c, a, p);
    (ab >= -1.0e-5 && bc >= -1.0e-5 && ca >= -1.0e-5)
        || (ab <= 1.0e-5 && bc <= 1.0e-5 && ca <= 1.0e-5)
}

fn orientation(a: (f32, f32), b: (f32, f32), c: (f32, f32)) -> f32 {
    (b.0 - a.0) * (c.1 - a.1) - (b.1 - a.1) * (c.0 - a.0)
}
