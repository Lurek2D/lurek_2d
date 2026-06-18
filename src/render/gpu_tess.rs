//! Converts high-level 2D draw shapes into GPU-ready vertices and indices for the hardware renderer pipeline.
//! Tessellates rectangles, circles, arcs, glyph quads, sprites, and meshes under one geometry conversion owner.
//! Adapts curve segment counts to screen-space radius so curved shapes stay smooth across different zoom levels.
//! Builds stroked lines as quads with explicit widths, supporting borders, outlines, and dashed style variants.
//! Packs position, uv, tint, and transform data into ColorVertex and TexVertex streams expected by GPU code.
//! Applies local transforms per vertex so nested coordinate systems do not need pre-flattened geometry upstream.
//! Computes scissor rectangles and culls out-of-bounds geometry to reduce wasted GPU work and visual artifacts.
//! Acts as the GPU tessellation boundary between front-end draw intent and raw vertex buffer contents.
//! Open this file when hardware path geometry, scissor math, or shape triangulation behaves incorrectly.

use super::GpuRenderer;
use crate::math::{Mat3, Vec2};
use crate::render::gpu_pipeline::{GeometryKind, GpuStencilMode};
use crate::render::gpu_shaders::ShaderUniformKind;
use crate::render::gpu_types::{
    ColorVertex, PreparedDraw, RenderTargetId, ScissorRect, TexRef, TexVertex,
};
use crate::render::renderer::{BlendMode, DrawMode};
use crate::render::shader::UniformValue;
use crate::runtime::resource_keys::ShaderKey;
use std::f32::consts::PI;

impl GpuRenderer {
    /// Tessellate a rectangle into flat-color vertices and indices.
    #[allow(clippy::too_many_arguments)]
    pub(crate) fn tess_rect(
        &self,
        cv: &mut Vec<ColorVertex>,
        ci: &mut Vec<u32>,
        t: &Mat3,
        color: [f32; 4],
        mode: &DrawMode,
        x: f32,
        y: f32,
        w: f32,
        h: f32,
        lw: f32,
    ) {
        match mode {
            DrawMode::Fill => {
                let pts = [
                    apply(t, x, y),
                    apply(t, x + w, y),
                    apply(t, x + w, y + h),
                    apply(t, x, y + h),
                ];
                push_quad_verts(cv, ci, &pts, color);
            }
            DrawMode::Line => {
                push_thick_line(cv, ci, t, color, x, y, x + w, y, lw);
                push_thick_line(cv, ci, t, color, x + w, y, x + w, y + h, lw);
                push_thick_line(cv, ci, t, color, x + w, y + h, x, y + h, lw);
                push_thick_line(cv, ci, t, color, x, y + h, x, y, lw);
            }
        }
    }
    /// Tessellate a rounded rectangle into flat-color vertices and indices.
    #[allow(clippy::too_many_arguments)]
    pub(crate) fn tess_rounded_rect(
        &self,
        cv: &mut Vec<ColorVertex>,
        ci: &mut Vec<u32>,
        t: &Mat3,
        color: [f32; 4],
        mode: &DrawMode,
        x: f32,
        y: f32,
        w: f32,
        h: f32,
        rx: f32,
        ry: f32,
        lw: f32,
    ) {
        let rx = rx.min(w * 0.5).max(0.0);
        let ry = ry.min(h * 0.5).max(0.0);
        const CORNER_SEGS: u32 = 8;
        let path = build_rounded_rect_path(x, y, w, h, rx, ry, CORNER_SEGS);
        match mode {
            DrawMode::Fill => {
                push_fan_fill(cv, ci, t, color, x + w * 0.5, y + h * 0.5, &path);
            }
            DrawMode::Line => {
                for i in 0..path.len() {
                    let j = (i + 1) % path.len();
                    push_thick_line(
                        cv, ci, t, color, path[i].0, path[i].1, path[j].0, path[j].1, lw,
                    );
                }
            }
        }
    }
    /// Tessellate an ellipse into flat-color vertices and indices.
    #[allow(clippy::too_many_arguments)]
    pub(crate) fn tess_ellipse(
        &self,
        cv: &mut Vec<ColorVertex>,
        ci: &mut Vec<u32>,
        t: &Mat3,
        color: [f32; 4],
        mode: &DrawMode,
        cx: f32,
        cy: f32,
        rx: f32,
        ry: f32,
        segs: u32,
        lw: f32,
    ) {
        match mode {
            DrawMode::Fill => {
                let base = cv.len() as u32;
                let c = apply(t, cx, cy);
                cv.push(ColorVertex {
                    position: [c.0, c.1],
                    color,
                });
                for i in 0..=segs {
                    let a = (i as f32 / segs as f32) * 2.0 * PI;
                    let p = apply(t, cx + rx * a.cos(), cy + ry * a.sin());
                    cv.push(ColorVertex {
                        position: [p.0, p.1],
                        color,
                    });
                }
                for i in 1..=segs {
                    ci.extend_from_slice(&[base, base + i, base + i + 1]);
                }
            }
            DrawMode::Line => {
                for i in 0..segs {
                    let a0 = (i as f32 / segs as f32) * 2.0 * PI;
                    let a1 = ((i + 1) as f32 / segs as f32) * 2.0 * PI;
                    push_thick_line(
                        cv,
                        ci,
                        t,
                        color,
                        cx + rx * a0.cos(),
                        cy + ry * a0.sin(),
                        cx + rx * a1.cos(),
                        cy + ry * a1.sin(),
                        lw,
                    );
                }
            }
        }
    }
    /// Tessellate a triangle into flat-color vertices and indices.
    #[allow(clippy::too_many_arguments)]
    pub(crate) fn tess_triangle(
        &self,
        cv: &mut Vec<ColorVertex>,
        ci: &mut Vec<u32>,
        t: &Mat3,
        color: [f32; 4],
        mode: &DrawMode,
        x1: f32,
        y1: f32,
        x2: f32,
        y2: f32,
        x3: f32,
        y3: f32,
        lw: f32,
    ) {
        match mode {
            DrawMode::Fill => {
                let base = cv.len() as u32;
                for &(px, py) in &[(x1, y1), (x2, y2), (x3, y3)] {
                    let p = apply(t, px, py);
                    cv.push(ColorVertex {
                        position: [p.0, p.1],
                        color,
                    });
                }
                ci.extend_from_slice(&[base, base + 1, base + 2]);
            }
            DrawMode::Line => {
                push_thick_line(cv, ci, t, color, x1, y1, x2, y2, lw);
                push_thick_line(cv, ci, t, color, x2, y2, x3, y3, lw);
                push_thick_line(cv, ci, t, color, x3, y3, x1, y1, lw);
            }
        }
    }
    /// Tessellate a polygon from a flat vertex array into flat-color geometry.
    #[allow(clippy::too_many_arguments)]
    pub(crate) fn tess_polygon(
        &self,
        cv: &mut Vec<ColorVertex>,
        ci: &mut Vec<u32>,
        t: &Mat3,
        color: [f32; 4],
        mode: &DrawMode,
        vertices: &[f32],
        lw: f32,
    ) {
        if vertices.len() < 6 {
            return;
        }
        let n = vertices.len() / 2;
        match mode {
            DrawMode::Fill => {
                let base = cv.len() as u32;
                for i in 0..n {
                    let p = apply(t, vertices[i * 2], vertices[i * 2 + 1]);
                    cv.push(ColorVertex {
                        position: [p.0, p.1],
                        color,
                    });
                }
                for i in 1..(n as u32 - 1) {
                    ci.extend_from_slice(&[base, base + i, base + i + 1]);
                }
            }
            DrawMode::Line => {
                for i in 0..n {
                    let j = (i + 1) % n;
                    push_thick_line(
                        cv,
                        ci,
                        t,
                        color,
                        vertices[i * 2],
                        vertices[i * 2 + 1],
                        vertices[j * 2],
                        vertices[j * 2 + 1],
                        lw,
                    );
                }
            }
        }
    }
    /// Tessellate an arc segment into flat-color vertices and indices.
    #[allow(clippy::too_many_arguments)]
    pub(crate) fn tess_arc(
        &self,
        cv: &mut Vec<ColorVertex>,
        ci: &mut Vec<u32>,
        t: &Mat3,
        color: [f32; 4],
        mode: &DrawMode,
        cx: f32,
        cy: f32,
        r: f32,
        a1: f32,
        a2: f32,
        segs: u32,
        lw: f32,
    ) {
        match mode {
            DrawMode::Fill => {
                let base = cv.len() as u32;
                let c = apply(t, cx, cy);
                cv.push(ColorVertex {
                    position: [c.0, c.1],
                    color,
                });
                for i in 0..=segs {
                    let a = a1 + (a2 - a1) * (i as f32 / segs as f32);
                    let p = apply(t, cx + r * a.cos(), cy + r * a.sin());
                    cv.push(ColorVertex {
                        position: [p.0, p.1],
                        color,
                    });
                }
                for i in 1..=segs {
                    ci.extend_from_slice(&[base, base + i, base + i + 1]);
                }
            }
            DrawMode::Line => {
                for i in 0..segs {
                    let a0 = a1 + (a2 - a1) * (i as f32 / segs as f32);
                    let a_next = a1 + (a2 - a1) * ((i + 1) as f32 / segs as f32);
                    push_thick_line(
                        cv,
                        ci,
                        t,
                        color,
                        cx + r * a0.cos(),
                        cy + r * a0.sin(),
                        cx + r * a_next.cos(),
                        cy + r * a_next.sin(),
                        lw,
                    );
                }
            }
        }
    }
}

/// Append a flat-color draw call — vertices and indices — to the frame-local draw list.
#[allow(clippy::too_many_arguments)]
pub(crate) fn append_color_draw(
    draws: &mut Vec<PreparedDraw>,
    all_verts: &mut Vec<ColorVertex>,
    all_idxs: &mut Vec<u32>,
    target: RenderTargetId,
    blend_mode: BlendMode,
    scissor: ScissorRect,
    color_mask_bits: u32,
    shader: Option<ShaderKey>,
    stencil_mode: GpuStencilMode,
    stencil_reference: u8,
    verts: Vec<ColorVertex>,
    idxs: Vec<u32>,
) {
    if idxs.is_empty() {
        return;
    }
    let base = all_verts.len() as u32;
    let idx_start = all_idxs.len() as u32;
    all_verts.extend_from_slice(&verts);
    all_idxs.extend(idxs.iter().map(|&idx| idx + base));
    draws.push(PreparedDraw {
        target,
        geometry: GeometryKind::Color,
        texture_ref: None,
        idx_start,
        idx_count: idxs.len() as u32,
        blend_mode,
        scissor,
        color_mask_bits,
        shader,
        stencil_mode,
        stencil_reference: stencil_reference as u32,
        static_geometry: None,
        instance_buffer: None,
        instance_start: 0,
        instance_count: 0,
    });
}
/// Append a textured draw call — vertices and indices — to the frame-local draw list.
#[allow(clippy::too_many_arguments)]
pub(crate) fn append_tex_draw(
    draws: &mut Vec<PreparedDraw>,
    all_verts: &mut Vec<TexVertex>,
    all_idxs: &mut Vec<u32>,
    target: RenderTargetId,
    texture_ref: TexRef,
    blend_mode: BlendMode,
    scissor: ScissorRect,
    color_mask_bits: u32,
    shader: Option<ShaderKey>,
    stencil_mode: GpuStencilMode,
    stencil_reference: u8,
    verts: Vec<TexVertex>,
    idxs: Vec<u32>,
) {
    if idxs.is_empty() {
        return;
    }
    let base = all_verts.len() as u32;
    let idx_start = all_idxs.len() as u32;
    all_verts.extend_from_slice(&verts);
    all_idxs.extend(idxs.iter().map(|&idx| idx + base));
    draws.push(PreparedDraw {
        target,
        geometry: GeometryKind::Texture,
        texture_ref: Some(texture_ref),
        idx_start,
        idx_count: idxs.len() as u32,
        blend_mode,
        scissor,
        color_mask_bits,
        shader,
        stencil_mode,
        stencil_reference: stencil_reference as u32,
        static_geometry: None,
        instance_buffer: None,
        instance_start: 0,
        instance_count: 0,
    });
}
/// Clamp and convert a float scissor rect to integer pixel bounds clamped to `[0, width/height]`.
pub fn normalize_scissor(
    rect: Option<(f32, f32, f32, f32)>,
    width: u32,
    height: u32,
) -> ScissorRect {
    rect.and_then(|(x, y, w, h)| {
        let left = x.max(0.0).floor() as u32;
        let top = y.max(0.0).floor() as u32;
        let right = (x + w).max(0.0).ceil() as u32;
        let bottom = (y + h).max(0.0).ceil() as u32;
        if right <= left || bottom <= top {
            return None;
        }
        let clamped_left = left.min(width);
        let clamped_top = top.min(height);
        let clamped_right = right.min(width);
        let clamped_bottom = bottom.min(height);
        if clamped_right <= clamped_left || clamped_bottom <= clamped_top {
            None
        } else {
            Some((
                clamped_left,
                clamped_top,
                clamped_right - clamped_left,
                clamped_bottom - clamped_top,
            ))
        }
    })
}
/// Encode `(R, G, B, A)` bool channel mask as a wgpu `ColorWrites` bitmask.
pub fn color_write_mask_bits(mask: (bool, bool, bool, bool)) -> u32 {
    let mut bits = 0;
    if mask.0 {
        bits |= wgpu::ColorWrites::RED.bits();
    }
    if mask.1 {
        bits |= wgpu::ColorWrites::GREEN.bits();
    }
    if mask.2 {
        bits |= wgpu::ColorWrites::BLUE.bits();
    }
    if mask.3 {
        bits |= wgpu::ColorWrites::ALPHA.bits();
    }
    bits
}
/// Reconstruct a `wgpu::ColorWrites` from a bitmask stored in a `PipelineKey`.
pub fn color_write_mask_from_bits(bits: u32) -> wgpu::ColorWrites {
    wgpu::ColorWrites::from_bits_truncate(bits)
}
/// Return the custom shader key for a draw call, suppressed to `None` during stencil writes.
pub(crate) fn shader_for_draw(draw: PreparedDraw) -> Option<ShaderKey> {
    if matches!(draw.stencil_mode, GpuStencilMode::Write(_)) {
        None
    } else {
        draw.shader
    }
}
/// Parse a filter-mode string `"linear"` or anything else → `Nearest`.
pub fn parse_filter_mode(value: &str) -> wgpu::FilterMode {
    match value {
        "linear" => wgpu::FilterMode::Linear,
        _ => wgpu::FilterMode::Nearest,
    }
}
/// Map a `UniformValue` to its `ShaderUniformKind` type tag.
pub(crate) fn uniform_kind(value: &UniformValue) -> ShaderUniformKind {
    match value {
        UniformValue::Float(_) => ShaderUniformKind::Float,
        UniformValue::Vec2(_) => ShaderUniformKind::Vec2,
        UniformValue::Vec3(_) => ShaderUniformKind::Vec3,
        UniformValue::Vec4(_) => ShaderUniformKind::Vec4,
        UniformValue::Int(_) => ShaderUniformKind::Int,
        UniformValue::Bool(_) => ShaderUniformKind::Bool,
    }
}
/// Serialize a `UniformValue` into a 16-byte std140-aligned buffer for a wgpu uniform upload.
pub fn uniform_bytes(value: &UniformValue) -> [u8; 16] {
    let mut bytes = [0u8; 16];
    match value {
        UniformValue::Float(v) => {
            bytes[..4].copy_from_slice(&v.to_ne_bytes());
        }
        UniformValue::Vec2(v) => {
            bytes[..8].copy_from_slice(bytemuck::cast_slice(v));
        }
        UniformValue::Vec3(v) => {
            bytes[..12].copy_from_slice(bytemuck::cast_slice(v));
        }
        UniformValue::Vec4(v) => {
            bytes.copy_from_slice(bytemuck::cast_slice(v));
        }
        UniformValue::Int(v) => {
            bytes[..4].copy_from_slice(&v.to_ne_bytes());
        }
        UniformValue::Bool(v) => {
            let raw = if *v { 1u32 } else { 0u32 };
            bytes[..4].copy_from_slice(&raw.to_ne_bytes());
        }
    }
    bytes
}

/// Applies a transform matrix to a 2D point and returns the transformed coordinates.
pub(crate) fn apply(t: &Mat3, x: f32, y: f32) -> (f32, f32) {
    let p = t.transform_point(Vec2 { x, y });
    (p.x, p.y)
}
/// Generate a thick line as a transformed quad from `(x1,y1)` to `(x2,y2)`.
#[allow(clippy::too_many_arguments)]
pub(crate) fn push_thick_line(
    cv: &mut Vec<ColorVertex>,
    ci: &mut Vec<u32>,
    t: &Mat3,
    color: [f32; 4],
    x1: f32,
    y1: f32,
    x2: f32,
    y2: f32,
    width: f32,
) {
    let dx = x2 - x1;
    let dy = y2 - y1;
    let len = (dx * dx + dy * dy).sqrt();
    if len < 1e-4 {
        return;
    }
    let hw = width * 0.5;
    let nx = -dy / len * hw;
    let ny = dx / len * hw;
    let pts = [
        apply(t, x1 + nx, y1 + ny),
        apply(t, x1 - nx, y1 - ny),
        apply(t, x2 - nx, y2 - ny),
        apply(t, x2 + nx, y2 + ny),
    ];
    push_quad_verts(cv, ci, &pts, color);
}
/// Push four pre-transformed corner positions as a two-triangle quad.
pub(crate) fn push_quad_verts(
    cv: &mut Vec<ColorVertex>,
    ci: &mut Vec<u32>,
    pts: &[(f32, f32); 4],
    color: [f32; 4],
) {
    let base = cv.len() as u32;
    for &(x, y) in pts {
        cv.push(ColorVertex {
            position: [x, y],
            color,
        });
    }
    ci.extend_from_slice(&[base, base + 1, base + 2, base, base + 2, base + 3]);
}
/// Fill a convex polygon as a triangle fan from a centre point.
pub(crate) fn push_fan_fill(
    cv: &mut Vec<ColorVertex>,
    ci: &mut Vec<u32>,
    t: &Mat3,
    color: [f32; 4],
    cx: f32,
    cy: f32,
    path: &[(f32, f32)],
) {
    if path.len() < 2 {
        return;
    }
    let base = cv.len() as u32;
    let c = apply(t, cx, cy);
    cv.push(ColorVertex {
        position: [c.0, c.1],
        color,
    });
    for &(px, py) in path {
        let p = apply(t, px, py);
        cv.push(ColorVertex {
            position: [p.0, p.1],
            color,
        });
    }
    let n = path.len() as u32;
    for i in 0..n {
        ci.extend_from_slice(&[base, base + 1 + i, base + 1 + (i + 1) % n]);
    }
}
/// Generate a rounded rectangle outline path as a series of arc-sampled points.
pub(crate) fn build_rounded_rect_path(
    x: f32,
    y: f32,
    w: f32,
    h: f32,
    rx: f32,
    ry: f32,
    segs: u32,
) -> Vec<(f32, f32)> {
    let mut pts = Vec::new();
    let corners = [
        (x + rx, y + ry, PI, 1.5 * PI),
        (x + w - rx, y + ry, 1.5 * PI, 2.0 * PI),
        (x + w - rx, y + h - ry, 0.0, 0.5 * PI),
        (x + rx, y + h - ry, 0.5 * PI, PI),
    ];
    for &(cx, cy, a_start, a_end) in &corners {
        for i in 0..=segs {
            let a = a_start + (a_end - a_start) * (i as f32 / segs as f32);
            pts.push((cx + rx * a.cos(), cy + ry * a.sin()));
        }
    }
    pts
}
/// Push a textured quad with position, rotation, scale, and origin offset.
#[allow(clippy::too_many_arguments)]
pub(crate) fn push_tex_quad(
    tv: &mut Vec<TexVertex>,
    ti: &mut Vec<u32>,
    t: &Mat3,
    tint: [f32; 4],
    x: f32,
    y: f32,
    rot: f32,
    sx: f32,
    sy: f32,
    ox: f32,
    oy: f32,
    w: f32,
    h: f32,
    u0: f32,
    v0: f32,
    u1: f32,
    v1: f32,
) {
    let local = [(0.0, 0.0), (w, 0.0), (w, h), (0.0, h)];
    let uv = [(u0, v0), (u1, v0), (u1, v1), (u0, v1)];
    let cos_r = rot.cos();
    let sin_r = rot.sin();
    let base = tv.len() as u32;
    for (i, &(lx, ly)) in local.iter().enumerate() {
        let sx2 = (lx - ox) * sx;
        let sy2 = (ly - oy) * sy;
        let rx = sx2 * cos_r - sy2 * sin_r + x;
        let ry = sx2 * sin_r + sy2 * cos_r + y;
        let (wx, wy) = apply(t, rx, ry);
        tv.push(TexVertex {
            position: [wx, wy],
            uv: [uv[i].0, uv[i].1],
            color: tint,
            w_depth: 1.0,
            _pad: [0.0; 3],
        });
    }
    ti.extend_from_slice(&[base, base + 1, base + 2, base, base + 2, base + 3]);
}
/// Push a textured quad defined by explicit corner positions and per-vertex W depths.
pub(crate) fn push_tex_quad_corners(
    tv: &mut Vec<TexVertex>,
    ti: &mut Vec<u32>,
    t: &Mat3,
    tint: [f32; 4],
    corners: &[crate::math::Vec2; 4],
    uvs: &[crate::math::Vec2; 4],
    corner_w: &[f32; 4],
) {
    let base = tv.len() as u32;
    for i in 0..4 {
        let (wx, wy) = apply(t, corners[i].x, corners[i].y);
        tv.push(TexVertex {
            position: [wx, wy],
            uv: [uvs[i].x, uvs[i].y],
            color: tint,
            w_depth: corner_w[i].max(0.001),
            _pad: [0.0; 3],
        });
    }
    ti.extend_from_slice(&[base, base + 1, base + 2, base, base + 2, base + 3]);
}
