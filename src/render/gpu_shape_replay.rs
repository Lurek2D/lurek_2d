//! Replays registered compound shapes into GPU flat-color draw buffers.
//! Keeps reusable `ShapeCommand` interpretation separate from the main frame orchestration loop.
//! Applies draw-time transforms, wireframe override, color state, line width, scissor, shader, and stencil state.
//! Emits prepared color draw ranges directly into caller-owned frame buffers without allocating per command.
//! Acts as the compound-shape replay boundary between shape assets and GPU tessellation helpers.
//! Open this file when `DrawShape` output differs from equivalent immediate-mode shape commands.

use slotmap::SlotMap;

use crate::math::Mat3;
use crate::render::gpu_pipeline::GpuStencilMode;
use crate::render::gpu_renderer::GpuRenderer;
use crate::render::gpu_tess::{append_color_draw_range, normalize_scissor, push_thick_line};
use crate::render::gpu_types::{ColorVertex, PreparedDraw, RenderTargetId};
use crate::render::renderer::{BlendMode, DrawMode};
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
            }
        }
    }
}
