//! Owns the gpu shape replay owner for the render subsystem and keeps its rules local to this file.
//! Centers the implementation around replay_compound_shape, with helpers kept close to their invariants.
//! Defines how gpu shape replay data is validated, transformed, or stored before neighboring systems use it.
//! Owns render behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on gpu shape replay behavior while Lua registration stays elsewhere.
//! Documents the boundary where render code accepts inputs, reports errors, or updates state.

use slotmap::SlotMap;

use crate::math::Mat3;
use crate::render::gpu_pipeline::GpuStencilMode;
use crate::render::gpu_renderer::GpuRenderer;
use crate::render::gpu_tess::{append_color_draw_range, normalize_scissor, push_thick_line};
use crate::render::gpu_types::{ColorVertex, PreparedDraw, RenderTargetId};
use crate::render::renderer::{BlendMode, DrawMode, PathSegment};
use crate::render::shader::Shader;
use crate::render::shape::{CompoundShape, ShapeCommand};
use crate::runtime::resource_keys::{CanvasKey, ShaderKey};

impl GpuRenderer {
    /// Replay a validated compound shape into the frame's flat-color buffers and prepared draws.
    #[allow(clippy::too_many_arguments)]
    pub(crate) fn replay_compound_shape(
        &self,
        shape: &CompoundShape,
        shape_transform: &Mat3,
        wireframe: bool,
        current_target: RenderTargetId,
        current_blend_mode: BlendMode,
        current_scissor: Option<(f32, f32, f32, f32)>,
        color_mask_bits: u32,
        active_shader: Option<ShaderKey>,
        stencil_mode: GpuStencilMode,
        stencil_reference: u8,
        canvases: &SlotMap<CanvasKey, crate::render::Canvas>,
        shaders: &SlotMap<ShaderKey, Shader>,
        all_color_verts: &mut Vec<ColorVertex>,
        all_color_idxs: &mut Vec<u32>,
        draws: &mut Vec<PreparedDraw>,
    ) {
        let mut shape_color = shape.current_color;
        let mut shape_line_width = shape.current_line_width;

        macro_rules! append_shape_color_range {
            ($idx_start:expr, $idx_end:expr) => {{
                let (target_width, target_height) =
                    self.target_dimensions(current_target, canvases);
                append_color_draw_range(
                    draws,
                    $idx_start,
                    $idx_end,
                    current_target,
                    current_blend_mode,
                    normalize_scissor(current_scissor, target_width, target_height),
                    color_mask_bits,
                    active_shader.filter(|key| shaders.contains_key(*key)),
                    stencil_mode,
                    stencil_reference,
                );
            }};
        }

        for shape_command in &shape.commands {
            match shape_command {
                ShapeCommand::SetColor(r, g, b, a) => {
                    shape_color = [*r, *g, *b, *a];
                }
                ShapeCommand::SetLineWidth(width) => {
                    shape_line_width = *width;
                }
                ShapeCommand::SetStrokeStyle(style) => {
                    shape_line_width = style.width;
                }
                ShapeCommand::SetColorRole(role) => {
                    shape_color = shape.palette_color(role);
                }
                ShapeCommand::Rectangle { mode, x, y, w, h } => {
                    let mode = if wireframe { &DrawMode::Line } else { mode };
                    let idx_start = all_color_idxs.len();
                    self.tess_rect(
                        all_color_verts,
                        all_color_idxs,
                        shape_transform,
                        shape_color,
                        mode,
                        *x,
                        *y,
                        *w,
                        *h,
                        shape_line_width,
                    );
                    append_shape_color_range!(idx_start, all_color_idxs.len());
                }
                ShapeCommand::RoundedRectangle {
                    mode,
                    x,
                    y,
                    w,
                    h,
                    rx,
                    ry,
                } => {
                    let mode = if wireframe { &DrawMode::Line } else { mode };
                    let idx_start = all_color_idxs.len();
                    self.tess_rounded_rect(
                        all_color_verts,
                        all_color_idxs,
                        shape_transform,
                        shape_color,
                        mode,
                        *x,
                        *y,
                        *w,
                        *h,
                        *rx,
                        *ry,
                        shape_line_width,
                    );
                    append_shape_color_range!(idx_start, all_color_idxs.len());
                }
                ShapeCommand::Circle { mode, x, y, r } => {
                    let mode = if wireframe { &DrawMode::Line } else { mode };
                    let segments =
                        crate::render::renderer::adaptive_circle_ellipse_segments(*r, *r);
                    let idx_start = all_color_idxs.len();
                    self.tess_ellipse(
                        all_color_verts,
                        all_color_idxs,
                        shape_transform,
                        shape_color,
                        mode,
                        *x,
                        *y,
                        *r,
                        *r,
                        segments,
                        shape_line_width,
                    );
                    append_shape_color_range!(idx_start, all_color_idxs.len());
                }
                ShapeCommand::Ellipse { mode, x, y, rx, ry } => {
                    let mode = if wireframe { &DrawMode::Line } else { mode };
                    let segments =
                        crate::render::renderer::adaptive_circle_ellipse_segments(*rx, *ry);
                    let idx_start = all_color_idxs.len();
                    self.tess_ellipse(
                        all_color_verts,
                        all_color_idxs,
                        shape_transform,
                        shape_color,
                        mode,
                        *x,
                        *y,
                        *rx,
                        *ry,
                        segments,
                        shape_line_width,
                    );
                    append_shape_color_range!(idx_start, all_color_idxs.len());
                }
                ShapeCommand::Triangle {
                    mode,
                    x1,
                    y1,
                    x2,
                    y2,
                    x3,
                    y3,
                } => {
                    let mode = if wireframe { &DrawMode::Line } else { mode };
                    let idx_start = all_color_idxs.len();
                    self.tess_triangle(
                        all_color_verts,
                        all_color_idxs,
                        shape_transform,
                        shape_color,
                        mode,
                        *x1,
                        *y1,
                        *x2,
                        *y2,
                        *x3,
                        *y3,
                        shape_line_width,
                    );
                    append_shape_color_range!(idx_start, all_color_idxs.len());
                }
                ShapeCommand::Polygon { mode, vertices } => {
                    let mode = if wireframe { &DrawMode::Line } else { mode };
                    let idx_start = all_color_idxs.len();
                    self.tess_polygon(
                        all_color_verts,
                        all_color_idxs,
                        shape_transform,
                        shape_color,
                        mode,
                        vertices,
                        shape_line_width,
                    );
                    append_shape_color_range!(idx_start, all_color_idxs.len());
                }
                ShapeCommand::Line { x1, y1, x2, y2 } => {
                    let idx_start = all_color_idxs.len();
                    push_thick_line(
                        all_color_verts,
                        all_color_idxs,
                        shape_transform,
                        shape_color,
                        *x1,
                        *y1,
                        *x2,
                        *y2,
                        shape_line_width,
                    );
                    append_shape_color_range!(idx_start, all_color_idxs.len());
                }
                ShapeCommand::Polyline { points } => {
                    if points.len() >= 4 {
                        let idx_start = all_color_idxs.len();
                        let mut i = 0;
                        while i + 3 < points.len() {
                            push_thick_line(
                                all_color_verts,
                                all_color_idxs,
                                shape_transform,
                                shape_color,
                                points[i],
                                points[i + 1],
                                points[i + 2],
                                points[i + 3],
                                shape_line_width,
                            );
                            i += 2;
                        }
                        append_shape_color_range!(idx_start, all_color_idxs.len());
                    }
                }
                ShapeCommand::Arc {
                    mode,
                    x,
                    y,
                    radius,
                    angle1,
                    angle2,
                    segments,
                } => {
                    let mode = if wireframe { &DrawMode::Line } else { mode };
                    let segs = if *segments == 0 { 32 } else { *segments };
                    let idx_start = all_color_idxs.len();
                    self.tess_arc(
                        all_color_verts,
                        all_color_idxs,
                        shape_transform,
                        shape_color,
                        mode,
                        *x,
                        *y,
                        *radius,
                        *angle1,
                        *angle2,
                        segs,
                        shape_line_width,
                    );
                    append_shape_color_range!(idx_start, all_color_idxs.len());
                }
                ShapeCommand::Point { x, y, size } => {
                    let radius = size.abs() * 0.5;
                    let segments =
                        crate::render::renderer::adaptive_circle_ellipse_segments(radius, radius);
                    let idx_start = all_color_idxs.len();
                    self.tess_ellipse(
                        all_color_verts,
                        all_color_idxs,
                        shape_transform,
                        shape_color,
                        &DrawMode::Fill,
                        *x,
                        *y,
                        radius,
                        radius,
                        segments,
                        shape_line_width,
                    );
                    append_shape_color_range!(idx_start, all_color_idxs.len());
                }
                ShapeCommand::Points { points, size } => {
                    if points.len() >= 2 {
                        let radius = size.abs() * 0.5;
                        let segments = crate::render::renderer::adaptive_circle_ellipse_segments(
                            radius, radius,
                        );
                        let idx_start = all_color_idxs.len();
                        for pair in points.chunks_exact(2) {
                            self.tess_ellipse(
                                all_color_verts,
                                all_color_idxs,
                                shape_transform,
                                shape_color,
                                &DrawMode::Fill,
                                pair[0],
                                pair[1],
                                radius,
                                radius,
                                segments,
                                shape_line_width,
                            );
                        }
                        append_shape_color_range!(idx_start, all_color_idxs.len());
                    }
                }
                ShapeCommand::Path {
                    segments,
                    mode,
                    close,
                    ..
                } => {
                    let mut points: Vec<f32> = Vec::new();
                    let mut first: Option<(f32, f32)> = None;
                    for segment in segments {
                        match segment {
                            PathSegment::MoveTo { x, y } => {
                                if !points.is_empty() && *close {
                                    if let Some((fx, fy)) = first {
                                        points.extend([fx, fy]);
                                    }
                                }
                                points.clear();
                                points.extend([*x, *y]);
                                first = Some((*x, *y));
                            }
                            PathSegment::LineTo { x, y } => points.extend([*x, *y]),
                            PathSegment::QuadTo { x, y, .. }
                            | PathSegment::CubicTo { x, y, .. } => points.extend([*x, *y]),
                        }
                    }
                    if points.len() >= 4 {
                        if *close {
                            if let Some((fx, fy)) = first {
                                points.extend([fx, fy]);
                            }
                        }
                        let idx_start = all_color_idxs.len();
                        let mode = if wireframe { &DrawMode::Line } else { mode };
                        self.tess_polygon(
                            all_color_verts,
                            all_color_idxs,
                            shape_transform,
                            shape_color,
                            mode,
                            &points,
                            shape_line_width,
                        );
                        append_shape_color_range!(idx_start, all_color_idxs.len());
                    }
                }
                ShapeCommand::Transformed {
                    commands,
                    transform,
                    palette,
                } => {
                    let nested = CompoundShape {
                        commands: commands.clone(),
                        current_color: shape_color,
                        current_line_width: shape_line_width,
                        current_stroke_style: shape.current_stroke_style.clone(),
                        palette: *palette,
                        revision: shape.revision,
                        compile_tolerance: shape.compile_tolerance,
                        compiled: None,
                    };
                    let nested_transform = *shape_transform * *transform;
                    self.replay_compound_shape(
                        &nested,
                        &nested_transform,
                        wireframe,
                        current_target,
                        current_blend_mode,
                        current_scissor,
                        color_mask_bits,
                        active_shader,
                        stencil_mode,
                        stencil_reference,
                        canvases,
                        shaders,
                        all_color_verts,
                        all_color_idxs,
                        draws,
                    );
                }
            }
        }
    }
}
