//! Owns world-space layered-sky tile projection for the raycaster subsystem.
//! The helper subdivides projected ceiling-shaped tiles at texture seams so sky layers use
//! the same perspective and clamp-safe sampling rules as ordinary ceiling geometry.
//! It does not own map iteration, Lua parsing, texture sampling, or render-state restoration;
//! those boundaries remain in `build_scene`, `lua_api/raycaster_api.rs`, and the render paths.

use crate::math::Vec2;
use crate::raycaster::scene::{RaycasterSkyLayer, RaycasterSkyQuad};

const EPSILON: f32 = 1.0e-6;

#[derive(Debug, Clone, Copy)]
struct AxisSegment {
    t_start: f32,
    t_end: f32,
    uv_start: f32,
    uv_end: f32,
}

fn frac(value: f32) -> f32 {
    value.rem_euclid(1.0)
}

fn finite_or(value: f32, fallback: f32) -> f32 {
    if value.is_finite() {
        value
    } else {
        fallback
    }
}

/// Split one affine UV interval at integer texture boundaries.
fn split_axis(start: f32, end: f32) -> Vec<AxisSegment> {
    if !start.is_finite() || !end.is_finite() {
        return Vec::new();
    }
    let span = end - start;
    if span.abs() <= EPSILON {
        return Vec::new();
    }
    let forward = span > 0.0;
    let mut cursor = start;
    let mut segments = Vec::new();
    let mut guard = 0usize;
    while if forward {
        cursor < end - EPSILON
    } else {
        cursor > end + EPSILON
    } && guard < 32
    {
        let boundary = if forward {
            (cursor.floor() + 1.0).min(end)
        } else {
            (cursor.ceil() - 1.0).max(end)
        };
        let at_integer_start = frac(cursor).abs() <= EPSILON;
        let at_integer_end = frac(boundary).abs() <= EPSILON;
        let uv_start = if at_integer_start && !forward {
            1.0
        } else {
            frac(cursor)
        };
        let uv_end = if at_integer_end {
            if forward {
                1.0
            } else {
                0.0
            }
        } else {
            frac(boundary)
        };
        let t_start = (cursor - start) / span;
        let t_end = (boundary - start) / span;
        if (t_end - t_start).abs() > EPSILON && (uv_end - uv_start).abs() > EPSILON {
            segments.push(AxisSegment {
                t_start,
                t_end,
                uv_start,
                uv_end,
            });
        }
        cursor = boundary;
        guard += 1;
    }
    segments
}

fn bilerp(corners: [Vec2; 4], u: f32, v: f32) -> Vec2 {
    let top = corners[0] * (1.0 - u) + corners[1] * u;
    let bottom = corners[3] * (1.0 - u) + corners[2] * u;
    top * (1.0 - v) + bottom * v
}

fn bilerp_scalar(values: [f32; 4], u: f32, v: f32) -> f32 {
    let top = values[0] * (1.0 - u) + values[1] * u;
    let bottom = values[3] * (1.0 - u) + values[2] * u;
    top * (1.0 - v) + bottom * v
}

fn copy_phase(index: u8) -> [f32; 2] {
    let index = index as f32;
    [frac(index * 0.618_034), frac(index * 0.381_966)]
}

/// Project one elevated world-space tile into seam-safe render quads.
pub(crate) fn project_sky_tile(
    layer: &RaycasterSkyLayer,
    screen_corners: [Vec2; 4],
    corner_w: [f32; 4],
    world_corners: [Vec2; 4],
    camera_world: Vec2,
    time_seconds: f32,
    light: [f32; 4],
) -> Vec<RaycasterSkyQuad> {
    let scale_x = finite_or(layer.scale[0], 1.0);
    let scale_y = finite_or(layer.scale[1], 1.0);
    if scale_x.abs() <= EPSILON || scale_y.abs() <= EPSILON {
        return Vec::new();
    }
    let parallax = finite_or(layer.parallax, 1.0);
    let time = finite_or(time_seconds, 0.0);
    let offset = [
        finite_or(layer.offset[0], 0.0) + finite_or(layer.velocity[0], 0.0) * time,
        finite_or(layer.offset[1], 0.0) + finite_or(layer.velocity[1], 0.0) * time,
    ];
    let copies = layer.copies.min(8);
    if copies == 0 {
        return Vec::new();
    }

    let sample_world = |world: Vec2| world - camera_world * (1.0 - parallax);
    let mut result = Vec::new();
    for copy in 0..copies {
        let phase = copy_phase(copy);
        let uv_corners = world_corners.map(|world| {
            let sample = sample_world(world);
            Vec2::new(
                sample.x * scale_x + offset[0] + phase[0],
                sample.y * scale_y + offset[1] + phase[1],
            )
        });
        let horizontal = split_axis(uv_corners[0].x, uv_corners[1].x);
        let vertical = split_axis(uv_corners[0].y, uv_corners[3].y);
        for u_segment in &horizontal {
            for v_segment in &vertical {
                let u0 = u_segment.t_start;
                let u1 = u_segment.t_end;
                let v0 = v_segment.t_start;
                let v1 = v_segment.t_end;
                let corners = [
                    bilerp(screen_corners, u0, v0),
                    bilerp(screen_corners, u1, v0),
                    bilerp(screen_corners, u1, v1),
                    bilerp(screen_corners, u0, v1),
                ];
                let w = [
                    bilerp_scalar(corner_w, u0, v0),
                    bilerp_scalar(corner_w, u1, v0),
                    bilerp_scalar(corner_w, u1, v1),
                    bilerp_scalar(corner_w, u0, v1),
                ];
                let uvs = [
                    Vec2::new(u_segment.uv_start, v_segment.uv_start),
                    Vec2::new(u_segment.uv_end, v_segment.uv_start),
                    Vec2::new(u_segment.uv_end, v_segment.uv_end),
                    Vec2::new(u_segment.uv_start, v_segment.uv_end),
                ];
                let color = [
                    layer.tint[0] * light[0],
                    layer.tint[1] * light[1],
                    layer.tint[2] * light[2],
                    layer.tint[3] * light[3],
                ];
                result.push(RaycasterSkyQuad {
                    corners,
                    uvs,
                    corner_w: w,
                    texture_key: layer.texture_key,
                    color,
                    blend_mode: layer.blend_mode,
                });
            }
        }
    }
    result
}
