//! Owns the input validation owner for the render subsystem and keeps its rules local to this file.
//! Keeps render data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
//! Defines how input validation data is validated, transformed, or stored before neighboring systems use it.
//! Owns render behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on input validation behavior while Lua registration stays elsewhere.
//! Documents the boundary where render code accepts inputs, reports errors, or updates state.
//! Use this file when changing input validation defaults, lifecycle handling, validation, or data ownership.
//! Keeps failure paths and edge cases near the render state that can explain them while keeping call sites explicit.
//! Preserves deterministic behavior by keeping input validation calculations explicit at their owner boundary.
//! Provides the local adaptation layer that lets callers avoid duplicating render rules while keeping call sites explicit.

use crate::math::Vec2;
use crate::render::renderer::{
    ParticleRenderShape, PathSegment, PhysicsDebugConfig, PhysicsDebugShape, PostFxPass,
    RenderCommand, RenderCommandCategory, SpineSlotDraw, TextSpan,
};
use crate::render::shape::{CompoundShape, ShapeCommand};
use std::fmt;

/// Upper bounds and scalar policies used while validating render commands before tessellation.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct RenderInputLimits {
    /// Maximum number of vertices or points accepted by one command.
    pub max_vertices_per_command: usize,
    /// Maximum requested curve segment count accepted by one command.
    pub max_segments_per_command: u32,
    /// Maximum number of post-processing passes accepted by one command.
    pub max_postfx_passes: usize,
}

impl Default for RenderInputLimits {
    fn default() -> Self {
        Self {
            max_vertices_per_command: 65_536,
            max_segments_per_command: 4_096,
            max_postfx_passes: 64,
        }
    }
}

/// Deterministic render input validation failure recorded before backend-specific work starts.
#[derive(Debug, Clone, PartialEq)]
pub enum RenderInputError {
    /// A scalar field was NaN or infinite.
    NonFinite { field: &'static str },
    /// A scalar field had to be greater than zero but was not.
    NonPositive { field: &'static str },
    /// A scalar field had to be zero or greater but was negative.
    Negative { field: &'static str },
    /// An RGBA channel or alpha-like value was outside the normalized 0..1 range.
    OutOfRange { field: &'static str },
    /// A flat point array had an odd number of coordinates.
    OddCoordinateCount { field: &'static str, len: usize },
    /// A command carried too many points, vertices, segments, or passes.
    TooMany {
        field: &'static str,
        len: usize,
        max: usize,
    },
    /// Parallel per-vertex arrays did not describe the same number of vertices.
    LengthMismatch {
        field: &'static str,
        expected: usize,
        actual: usize,
    },
}

impl fmt::Display for RenderInputError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::NonFinite { field } => write!(f, "{field} must be finite"),
            Self::NonPositive { field } => write!(f, "{field} must be greater than zero"),
            Self::Negative { field } => write!(f, "{field} must be zero or greater"),
            Self::OutOfRange { field } => write!(f, "{field} must be in the 0..1 range"),
            Self::OddCoordinateCount { field, len } => {
                write!(f, "{field} has odd coordinate count {len}")
            }
            Self::TooMany { field, len, max } => {
                write!(f, "{field} has {len} entries, maximum is {max}")
            }
            Self::LengthMismatch {
                field,
                expected,
                actual,
            } => write!(f, "{field} has {actual} entries, expected {expected}"),
        }
    }
}

impl std::error::Error for RenderInputError {}

/// Validation failure paired with the broad command owner bucket that produced it.
#[derive(Debug, Clone, PartialEq)]
pub struct CategorizedRenderInputError {
    /// Broad command owner bucket used for diagnostics and backend routing.
    pub category: RenderCommandCategory,
    /// Specific validation failure.
    pub error: RenderInputError,
}

impl fmt::Display for CategorizedRenderInputError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{:?} command: {}", self.category, self.error)
    }
}

impl std::error::Error for CategorizedRenderInputError {
    fn source(&self) -> Option<&(dyn std::error::Error + 'static)> {
        Some(&self.error)
    }
}

#[derive(Debug, Clone, Copy)]
struct TransformInput {
    x: f32,
    y: f32,
    rotation: f32,
    sx: f32,
    sy: f32,
    ox: f32,
    oy: f32,
}

/// Validate one render command against scalar, color, topology, and per-command count limits.
pub fn validate_render_command(
    command: &RenderCommand,
    limits: &RenderInputLimits,
) -> Result<(), RenderInputError> {
    use RenderCommand::*;

    match command {
        SetColor(r, g, b, a) => validate_color("SetColor", [*r, *g, *b, *a]),
        Rectangle { x, y, w, h, .. } => {
            validate_finite_many(&[("rectangle.x", *x), ("rectangle.y", *y)])?;
            validate_non_negative("rectangle.w", *w)?;
            validate_non_negative("rectangle.h", *h)
        }
        RoundedRectangle {
            x, y, w, h, rx, ry, ..
        } => {
            validate_finite_many(&[("rounded_rectangle.x", *x), ("rounded_rectangle.y", *y)])?;
            validate_non_negative("rounded_rectangle.w", *w)?;
            validate_non_negative("rounded_rectangle.h", *h)?;
            validate_non_negative("rounded_rectangle.rx", *rx)?;
            validate_non_negative("rounded_rectangle.ry", *ry)
        }
        Circle { x, y, r, .. } => {
            validate_finite_many(&[("circle.x", *x), ("circle.y", *y)])?;
            validate_non_negative("circle.r", *r)
        }
        Ellipse { x, y, rx, ry, .. } => {
            validate_finite_many(&[("ellipse.x", *x), ("ellipse.y", *y)])?;
            validate_non_negative("ellipse.rx", *rx)?;
            validate_non_negative("ellipse.ry", *ry)
        }
        Triangle {
            x1,
            y1,
            x2,
            y2,
            x3,
            y3,
            ..
        } => validate_finite_many(&[
            ("triangle.x1", *x1),
            ("triangle.y1", *y1),
            ("triangle.x2", *x2),
            ("triangle.y2", *y2),
            ("triangle.x3", *x3),
            ("triangle.y3", *y3),
        ]),
        Polygon { vertices, .. } => validate_flat_points("polygon.vertices", vertices, limits),
        Line { x1, y1, x2, y2 } => validate_finite_many(&[
            ("line.x1", *x1),
            ("line.y1", *y1),
            ("line.x2", *x2),
            ("line.y2", *y2),
        ]),
        Polyline { points } => validate_flat_points("polyline.points", points, limits),
        DrawImage { x, y, .. } => {
            validate_finite_many(&[("draw_image.x", *x), ("draw_image.y", *y)])
        }
        DrawImageEx {
            x,
            y,
            rotation,
            sx,
            sy,
            ox,
            oy,
            ..
        }
        | DrawCanvas {
            x,
            y,
            rotation,
            sx,
            sy,
            ox,
            oy,
            ..
        }
        | DrawMesh {
            x,
            y,
            rotation,
            sx,
            sy,
            ox,
            oy,
            ..
        }
        | DrawShape {
            x,
            y,
            rotation,
            sx,
            sy,
            ox,
            oy,
            ..
        } => validate_transform(
            "transform",
            TransformInput {
                x: *x,
                y: *y,
                rotation: *rotation,
                sx: *sx,
                sy: *sy,
                ox: *ox,
                oy: *oy,
            },
        ),
        DrawStaticGeometry {
            x,
            y,
            rotation,
            sx,
            sy,
            ..
        } => validate_finite_many(&[
            ("static_geometry.x", *x),
            ("static_geometry.y", *y),
            ("static_geometry.rotation", *rotation),
            ("static_geometry.sx", *sx),
            ("static_geometry.sy", *sy),
        ]),
        DrawMeshTransient {
            mesh,
            x,
            y,
            rotation,
            sx,
            sy,
            ox,
            oy,
        } => {
            mesh.validate()
                .map_err(|_| RenderInputError::OutOfRange { field: "mesh" })?;
            validate_transform(
                "mesh_transform",
                TransformInput {
                    x: *x,
                    y: *y,
                    rotation: *rotation,
                    sx: *sx,
                    sy: *sy,
                    ox: *ox,
                    oy: *oy,
                },
            )
        }
        DrawQuad {
            quad_x,
            quad_y,
            quad_w,
            quad_h,
            tex_w,
            tex_h,
            x,
            y,
            rotation,
            sx,
            sy,
            ox,
            oy,
            ..
        } => {
            validate_non_negative("draw_quad.quad_x", *quad_x)?;
            validate_non_negative("draw_quad.quad_y", *quad_y)?;
            validate_non_negative("draw_quad.quad_w", *quad_w)?;
            validate_non_negative("draw_quad.quad_h", *quad_h)?;
            validate_positive("draw_quad.tex_w", *tex_w)?;
            validate_positive("draw_quad.tex_h", *tex_h)?;
            validate_transform(
                "draw_quad.transform",
                TransformInput {
                    x: *x,
                    y: *y,
                    rotation: *rotation,
                    sx: *sx,
                    sy: *sy,
                    ox: *ox,
                    oy: *oy,
                },
            )
        }
        Print { x, y, scale, .. } => {
            validate_finite_many(&[("print.x", *x), ("print.y", *y)])?;
            validate_positive("print.scale", *scale)
        }
        PrintTransformed {
            x,
            y,
            rotation,
            sx,
            sy,
            ox,
            oy,
            scale,
            ..
        } => {
            validate_transform(
                "text_transform",
                TransformInput {
                    x: *x,
                    y: *y,
                    rotation: *rotation,
                    sx: *sx,
                    sy: *sy,
                    ox: *ox,
                    oy: *oy,
                },
            )?;
            validate_positive("text_transform.scale", *scale)
        }
        DrawRichText { spans, x, y, .. } => {
            validate_finite_many(&[("rich_text.x", *x), ("rich_text.y", *y)])?;
            for span in spans {
                validate_text_span(span)?;
            }
            Ok(())
        }
        DrawRichTextTransformed {
            spans,
            x,
            y,
            rotation,
            sx,
            sy,
            ox,
            oy,
            ..
        } => {
            validate_transform(
                "rich_text_transform",
                TransformInput {
                    x: *x,
                    y: *y,
                    rotation: *rotation,
                    sx: *sx,
                    sy: *sy,
                    ox: *ox,
                    oy: *oy,
                },
            )?;
            for span in spans {
                validate_text_span(span)?;
            }
            Ok(())
        }
        SetLineWidth(width) => validate_positive("line_width", *width),
        Translate { x, y } => validate_finite_many(&[("translate.x", *x), ("translate.y", *y)]),
        Rotate { angle } => validate_finite("rotate.angle", *angle),
        Scale { sx, sy } => validate_finite_many(&[("scale.sx", *sx), ("scale.sy", *sy)]),
        Shear { kx, ky } => validate_finite_many(&[("shear.kx", *kx), ("shear.ky", *ky)]),
        ApplyTransform { matrix } => validate_finite_slice("transform.matrix", matrix),
        Arc {
            x,
            y,
            radius,
            angle1,
            angle2,
            segments,
            ..
        } => {
            validate_finite_many(&[
                ("arc.x", *x),
                ("arc.y", *y),
                ("arc.angle1", *angle1),
                ("arc.angle2", *angle2),
            ])?;
            validate_non_negative("arc.radius", *radius)?;
            validate_segments("arc.segments", *segments, limits)
        }
        RegisterCanvas { width, height, .. } | ApplyPostFx { width, height, .. } => {
            if *width == 0 {
                return Err(RenderInputError::NonPositive { field: "width" });
            }
            if *height == 0 {
                return Err(RenderInputError::NonPositive { field: "height" });
            }
            if let ApplyPostFx { passes, .. } = command {
                validate_postfx_passes(passes, limits)?;
            }
            Ok(())
        }
        Points { points } => {
            validate_count("points", points.len(), limits.max_vertices_per_command)?;
            for &(x, y) in points {
                validate_finite_many(&[("point.x", x), ("point.y", y)])?;
            }
            Ok(())
        }
        SetPointSize(size) => validate_positive("point_size", *size),
        SetScissor(Some((x, y, w, h))) => {
            validate_finite_many(&[("scissor.x", *x), ("scissor.y", *y)])?;
            validate_non_negative("scissor.w", *w)?;
            validate_non_negative("scissor.h", *h)
        }
        PrintFormatted {
            x, y, limit, scale, ..
        } => {
            validate_finite_many(&[("formatted_text.x", *x), ("formatted_text.y", *y)])?;
            validate_positive("formatted_text.limit", *limit)?;
            validate_positive("formatted_text.scale", *scale)
        }
        DrawNineSlice {
            tex_w,
            tex_h,
            top,
            right,
            bottom,
            left,
            x,
            y,
            w,
            h,
            ..
        } => {
            validate_positive("nine_slice.tex_w", *tex_w)?;
            validate_positive("nine_slice.tex_h", *tex_h)?;
            validate_non_negative("nine_slice.top", *top)?;
            validate_non_negative("nine_slice.right", *right)?;
            validate_non_negative("nine_slice.bottom", *bottom)?;
            validate_non_negative("nine_slice.left", *left)?;
            validate_finite_many(&[("nine_slice.x", *x), ("nine_slice.y", *y)])?;
            validate_non_negative("nine_slice.w", *w)?;
            validate_non_negative("nine_slice.h", *h)
        }
        DrawParticleSystem { particles, .. } => {
            validate_count(
                "particles",
                particles.len(),
                limits.max_vertices_per_command,
            )?;
            for particle in particles {
                validate_finite_many(&[
                    ("particle.x", particle.x),
                    ("particle.y", particle.y),
                    ("particle.rotation", particle.rotation),
                    ("particle.local_x", particle.local_x),
                    ("particle.local_y", particle.local_y),
                    ("particle.velocity_x", particle.velocity_x),
                    ("particle.velocity_y", particle.velocity_y),
                    ("particle.normalized_age", particle.normalized_age),
                    ("particle.lifetime", particle.lifetime),
                ])?;
                validate_color(
                    "particle.color",
                    [particle.r, particle.g, particle.b, particle.a],
                )?;
                validate_non_negative("particle.size", particle.size)?;
                validate_non_negative("particle.lifetime", particle.lifetime)?;
                validate_particle_shape(&particle.shape)?;
                if let Some(quad) = particle.quad {
                    validate_non_negative("particle.quad_x", quad[0])?;
                    validate_non_negative("particle.quad_y", quad[1])?;
                    validate_non_negative("particle.quad_w", quad[2])?;
                    validate_non_negative("particle.quad_h", quad[3])?;
                }
                if let Some((w, h)) = particle.quad_tex_dims {
                    validate_positive("particle.quad_tex_w", w)?;
                    validate_positive("particle.quad_tex_h", h)?;
                }
            }
            Ok(())
        }
        DrawTexturedQuad {
            corners,
            uvs,
            corner_w,
            color,
            ..
        } => {
            validate_vec2_array("textured_quad.corner", corners)?;
            validate_vec2_array("textured_quad.uv", uvs)?;
            validate_finite_slice("textured_quad.corner_w", corner_w)?;
            validate_color("textured_quad.color", *color)
        }
        DrawQuadBezier {
            start,
            control,
            end,
            segments,
        } => {
            validate_vec2("quad_bezier.start", *start)?;
            validate_vec2("quad_bezier.control", *control)?;
            validate_vec2("quad_bezier.end", *end)?;
            validate_segments("quad_bezier.segments", *segments, limits)
        }
        DrawCubicBezier {
            start,
            c1,
            c2,
            end,
            segments,
        } => {
            validate_vec2("cubic_bezier.start", *start)?;
            validate_vec2("cubic_bezier.c1", *c1)?;
            validate_vec2("cubic_bezier.c2", *c2)?;
            validate_vec2("cubic_bezier.end", *end)?;
            validate_segments("cubic_bezier.segments", *segments, limits)
        }
        DrawPath { segments, .. } => {
            validate_count(
                "path.segments",
                segments.len(),
                limits.max_vertices_per_command,
            )?;
            for segment in segments {
                validate_path_segment(segment)?;
            }
            Ok(())
        }
        DrawGradientRect {
            x,
            y,
            w,
            h,
            color1,
            color2,
            ..
        } => {
            validate_finite_many(&[("gradient_rect.x", *x), ("gradient_rect.y", *y)])?;
            validate_non_negative("gradient_rect.w", *w)?;
            validate_non_negative("gradient_rect.h", *h)?;
            validate_color("gradient_rect.color1", *color1)?;
            validate_color("gradient_rect.color2", *color2)
        }
        DrawColoredPolygon {
            vertices, colors, ..
        } => {
            validate_flat_points("colored_polygon.vertices", vertices, limits)?;
            let vertex_count = vertices.len() / 2;
            if colors.len() != vertex_count {
                return Err(RenderInputError::LengthMismatch {
                    field: "colored_polygon.colors",
                    expected: vertex_count,
                    actual: colors.len(),
                });
            }
            for color in colors {
                validate_color("colored_polygon.color", *color)?;
            }
            Ok(())
        }
        DrawIsoCubeTile {
            screen_x,
            screen_y,
            half_w,
            half_h,
            depth,
            top_color,
            left_color,
            right_color,
            ..
        } => {
            validate_finite_many(&[
                ("iso_cube.screen_x", *screen_x),
                ("iso_cube.screen_y", *screen_y),
                ("iso_cube.depth", *depth),
            ])?;
            validate_non_negative("iso_cube.half_w", *half_w)?;
            validate_non_negative("iso_cube.half_h", *half_h)?;
            validate_color("iso_cube.top_color", *top_color)?;
            validate_color("iso_cube.left_color", *left_color)?;
            validate_color("iso_cube.right_color", *right_color)
        }
        DrawHexTile { cx, cy, size, .. } => {
            validate_finite_many(&[("hex.cx", *cx), ("hex.cy", *cy)])?;
            validate_non_negative("hex.size", *size)
        }
        PushSortKey(value) => validate_finite("sort_key", *value),
        DrawPhysicsDebug { shapes, config } => {
            validate_physics_config(config)?;
            validate_count(
                "physics_debug.shapes",
                shapes.len(),
                limits.max_vertices_per_command,
            )?;
            for shape in shapes {
                validate_physics_shape(shape, limits)?;
            }
            Ok(())
        }
        DrawSpineSkeleton { slots } => {
            validate_count("spine.slots", slots.len(), limits.max_vertices_per_command)?;
            for slot in slots {
                validate_spine_slot(slot)?;
            }
            Ok(())
        }
        DrawBevelRect {
            x,
            y,
            w,
            h,
            bevel_w,
            highlight,
            shadow,
            fill_color,
            ..
        } => {
            validate_finite_many(&[("bevel_rect.x", *x), ("bevel_rect.y", *y)])?;
            validate_non_negative("bevel_rect.w", *w)?;
            validate_non_negative("bevel_rect.h", *h)?;
            validate_non_negative("bevel_rect.bevel_w", *bevel_w)?;
            validate_color("bevel_rect.highlight", *highlight)?;
            validate_color("bevel_rect.shadow", *shadow)?;
            validate_color("bevel_rect.fill_color", *fill_color)
        }
        PushLayer { alpha, .. } => validate_unit_interval("layer.alpha", *alpha),
        DrawConvexFan {
            vertices,
            uvs,
            tint,
            ..
        } => {
            validate_count(
                "convex_fan.vertices",
                vertices.len(),
                limits.max_vertices_per_command,
            )?;
            if uvs.len() != vertices.len() {
                return Err(RenderInputError::LengthMismatch {
                    field: "convex_fan.uvs",
                    expected: vertices.len(),
                    actual: uvs.len(),
                });
            }
            for vertex in vertices {
                validate_vec2("convex_fan.vertex", *vertex)?;
            }
            for uv in uvs {
                validate_vec2("convex_fan.uv", *uv)?;
            }
            validate_color("convex_fan.tint", *tint)
        }
        DrawProvinceMap {
            viewport,
            screen_size,
            tint,
            province_tints,
            terrain_texture_scale,
            terrain_texture_strength,
            edge_gradient_color,
            edge_gradient_radius,
            edge_gradient_strength,
            edge_gradient_softness,
            province_border_color,
            coast_border_color,
            country_border_color,
            sea_border_darken,
            time,
            ..
        } => {
            validate_finite_slice("province_map.viewport", viewport)?;
            validate_positive("province_map.screen_w", screen_size[0])?;
            validate_positive("province_map.screen_h", screen_size[1])?;
            validate_color("province_map.tint", *tint)?;
            validate_count(
                "province_map.province_tints",
                province_tints.len(),
                limits.max_vertices_per_command,
            )?;
            for (_, color) in province_tints {
                validate_color("province_map.province_tint", *color)?;
            }
            validate_positive("province_map.terrain_texture_scale", *terrain_texture_scale)?;
            validate_unit_interval(
                "province_map.terrain_texture_strength",
                *terrain_texture_strength,
            )?;
            validate_color("province_map.edge_gradient_color", *edge_gradient_color)?;
            validate_non_negative("province_map.edge_gradient_radius", *edge_gradient_radius)?;
            validate_unit_interval(
                "province_map.edge_gradient_strength",
                *edge_gradient_strength,
            )?;
            validate_positive(
                "province_map.edge_gradient_softness",
                *edge_gradient_softness,
            )?;
            validate_color("province_map.province_border_color", *province_border_color)?;
            validate_color("province_map.coast_border_color", *coast_border_color)?;
            validate_color("province_map.country_border_color", *country_border_color)?;
            validate_unit_interval("province_map.sea_border_darken", *sea_border_darken)?;
            validate_finite("province_map.time", *time)
        }
        PushTransform
        | PopTransform
        | Origin
        | DrawBatch { .. }
        | SetBlendMode(_)
        | SetCanvas(_)
        | ResetCanvas(_)
        | SetScissor(None)
        | SetColorMask(..)
        | SetWireframe(_)
        | StencilBegin { .. }
        | StencilEnd
        | SetStencilTest(_)
        | SetShader(_)
        | SyncMesh { .. }
        | BeginPostFx { .. }
        | EndPostFx { .. }
        | BeginSortGroup { .. }
        | FlushSortGroup { .. }
        | PopLayer { .. }
        | InstancedDraw { .. } => Ok(()),
    }
}

/// Validate one render command and attach its broad owner bucket to any failure.
pub fn validate_render_command_with_category(
    command: &RenderCommand,
    limits: &RenderInputLimits,
) -> Result<(), CategorizedRenderInputError> {
    validate_render_command(command, limits).map_err(|error| CategorizedRenderInputError {
        category: command.category(),
        error,
    })
}

/// Validate a registered compound shape before replaying its nested commands in a backend.
pub fn validate_compound_shape(
    shape: &CompoundShape,
    limits: &RenderInputLimits,
) -> Result<(), RenderInputError> {
    validate_color("shape.current_color", shape.current_color)?;
    validate_positive("shape.current_line_width", shape.current_line_width)?;
    validate_count(
        "shape.commands",
        shape.commands.len(),
        limits.max_vertices_per_command,
    )?;
    for command in &shape.commands {
        validate_shape_command(command, limits)?;
    }
    Ok(())
}

fn validate_shape_command(
    command: &ShapeCommand,
    limits: &RenderInputLimits,
) -> Result<(), RenderInputError> {
    match command {
        ShapeCommand::SetColor(r, g, b, a) => validate_color("shape.color", [*r, *g, *b, *a]),
        ShapeCommand::SetLineWidth(width) => validate_positive("shape.line_width", *width),
        ShapeCommand::Rectangle { x, y, w, h, .. } => {
            validate_finite_many(&[("shape.rectangle.x", *x), ("shape.rectangle.y", *y)])?;
            validate_non_negative("shape.rectangle.w", *w)?;
            validate_non_negative("shape.rectangle.h", *h)
        }
        ShapeCommand::RoundedRectangle {
            x, y, w, h, rx, ry, ..
        } => {
            validate_finite_many(&[
                ("shape.rounded_rectangle.x", *x),
                ("shape.rounded_rectangle.y", *y),
            ])?;
            validate_non_negative("shape.rounded_rectangle.w", *w)?;
            validate_non_negative("shape.rounded_rectangle.h", *h)?;
            validate_non_negative("shape.rounded_rectangle.rx", *rx)?;
            validate_non_negative("shape.rounded_rectangle.ry", *ry)
        }
        ShapeCommand::Circle { x, y, r, .. } => {
            validate_finite_many(&[("shape.circle.x", *x), ("shape.circle.y", *y)])?;
            validate_non_negative("shape.circle.r", *r)
        }
        ShapeCommand::Ellipse { x, y, rx, ry, .. } => {
            validate_finite_many(&[("shape.ellipse.x", *x), ("shape.ellipse.y", *y)])?;
            validate_non_negative("shape.ellipse.rx", *rx)?;
            validate_non_negative("shape.ellipse.ry", *ry)
        }
        ShapeCommand::Triangle {
            x1,
            y1,
            x2,
            y2,
            x3,
            y3,
            ..
        } => validate_finite_many(&[
            ("shape.triangle.x1", *x1),
            ("shape.triangle.y1", *y1),
            ("shape.triangle.x2", *x2),
            ("shape.triangle.y2", *y2),
            ("shape.triangle.x3", *x3),
            ("shape.triangle.y3", *y3),
        ]),
        ShapeCommand::Polygon { vertices, .. } => {
            validate_flat_points("shape.polygon.vertices", vertices, limits)
        }
        ShapeCommand::Line { x1, y1, x2, y2 } => validate_finite_many(&[
            ("shape.line.x1", *x1),
            ("shape.line.y1", *y1),
            ("shape.line.x2", *x2),
            ("shape.line.y2", *y2),
        ]),
        ShapeCommand::Polyline { points } => {
            validate_flat_points("shape.polyline.points", points, limits)
        }
        ShapeCommand::Arc {
            x,
            y,
            radius,
            angle1,
            angle2,
            segments,
            ..
        } => {
            validate_finite_many(&[
                ("shape.arc.x", *x),
                ("shape.arc.y", *y),
                ("shape.arc.angle1", *angle1),
                ("shape.arc.angle2", *angle2),
            ])?;
            validate_non_negative("shape.arc.radius", *radius)?;
            validate_segments("shape.arc.segments", *segments, limits)
        }
    }
}

fn validate_transform(prefix: &'static str, input: TransformInput) -> Result<(), RenderInputError> {
    validate_finite_many(&[
        (prefix, input.x),
        (prefix, input.y),
        (prefix, input.rotation),
        (prefix, input.sx),
        (prefix, input.sy),
        (prefix, input.ox),
        (prefix, input.oy),
    ])
}

fn validate_text_span(span: &TextSpan) -> Result<(), RenderInputError> {
    validate_positive("text_span.scale", span.scale)
}

fn validate_postfx_passes(
    passes: &[PostFxPass],
    limits: &RenderInputLimits,
) -> Result<(), RenderInputError> {
    validate_count("postfx.passes", passes.len(), limits.max_postfx_passes)?;
    for pass in passes {
        for value in pass.params.values() {
            validate_finite("postfx.param", *value)?;
        }
    }
    Ok(())
}

fn validate_particle_shape(shape: &ParticleRenderShape) -> Result<(), RenderInputError> {
    match shape {
        ParticleRenderShape::Shrapnel { edges, .. } if *edges < 3 => {
            Err(RenderInputError::NonPositive {
                field: "particle.shrapnel_edges",
            })
        }
        ParticleRenderShape::Ray { aspect } => validate_positive("particle.ray_aspect", *aspect),
        ParticleRenderShape::Ring { thickness } => {
            validate_unit_interval("particle.ring_thickness", *thickness)
        }
        _ => Ok(()),
    }
}

fn validate_path_segment(segment: &PathSegment) -> Result<(), RenderInputError> {
    match segment {
        PathSegment::MoveTo { x, y } | PathSegment::LineTo { x, y } => {
            validate_finite_many(&[("path.x", *x), ("path.y", *y)])
        }
        PathSegment::QuadTo { cx, cy, x, y } => validate_finite_many(&[
            ("path.cx", *cx),
            ("path.cy", *cy),
            ("path.x", *x),
            ("path.y", *y),
        ]),
        PathSegment::CubicTo {
            cx1,
            cy1,
            cx2,
            cy2,
            x,
            y,
        } => validate_finite_many(&[
            ("path.cx1", *cx1),
            ("path.cy1", *cy1),
            ("path.cx2", *cx2),
            ("path.cy2", *cy2),
            ("path.x", *x),
            ("path.y", *y),
        ]),
    }
}

fn validate_physics_config(config: &PhysicsDebugConfig) -> Result<(), RenderInputError> {
    validate_color("physics.body_color", config.body_color)?;
    validate_color("physics.static_color", config.static_color)?;
    validate_color("physics.sleep_color", config.sleep_color)?;
    validate_color("physics.sensor_color", config.sensor_color)?;
    validate_positive("physics.line_width", config.line_width)
}

fn validate_physics_shape(
    shape: &PhysicsDebugShape,
    limits: &RenderInputLimits,
) -> Result<(), RenderInputError> {
    validate_finite_many(&[
        ("physics.x", shape.x),
        ("physics.y", shape.y),
        ("physics.angle", shape.angle),
    ])?;
    validate_non_negative("physics.half_w", shape.half_w)?;
    validate_non_negative("physics.half_h", shape.half_h)?;
    validate_count(
        "physics.hull_verts",
        shape.hull_verts.len(),
        limits.max_vertices_per_command,
    )?;
    for vertex in &shape.hull_verts {
        validate_finite_many(&[("physics.hull_x", vertex[0]), ("physics.hull_y", vertex[1])])?;
    }
    Ok(())
}

fn validate_spine_slot(slot: &SpineSlotDraw) -> Result<(), RenderInputError> {
    validate_vec2_array("spine.corner", &slot.corners)?;
    validate_vec2_array("spine.uv", &slot.uvs)?;
    validate_color("spine.color", slot.color)
}

fn validate_flat_points(
    field: &'static str,
    points: &[f32],
    limits: &RenderInputLimits,
) -> Result<(), RenderInputError> {
    if !points.len().is_multiple_of(2) {
        return Err(RenderInputError::OddCoordinateCount {
            field,
            len: points.len(),
        });
    }
    validate_count(field, points.len() / 2, limits.max_vertices_per_command)?;
    validate_finite_slice(field, points)
}

fn validate_vec2_array(field: &'static str, values: &[Vec2]) -> Result<(), RenderInputError> {
    for value in values {
        validate_vec2(field, *value)?;
    }
    Ok(())
}

fn validate_vec2(field: &'static str, value: Vec2) -> Result<(), RenderInputError> {
    validate_finite_many(&[(field, value.x), (field, value.y)])
}

fn validate_color(field: &'static str, color: [f32; 4]) -> Result<(), RenderInputError> {
    for value in color {
        validate_unit_interval(field, value)?;
    }
    Ok(())
}

fn validate_segments(
    field: &'static str,
    segments: u32,
    limits: &RenderInputLimits,
) -> Result<(), RenderInputError> {
    if segments > limits.max_segments_per_command {
        return Err(RenderInputError::TooMany {
            field,
            len: segments as usize,
            max: limits.max_segments_per_command as usize,
        });
    }
    Ok(())
}

fn validate_count(field: &'static str, len: usize, max: usize) -> Result<(), RenderInputError> {
    if len > max {
        return Err(RenderInputError::TooMany { field, len, max });
    }
    Ok(())
}

fn validate_finite_slice(field: &'static str, values: &[f32]) -> Result<(), RenderInputError> {
    for &value in values {
        validate_finite(field, value)?;
    }
    Ok(())
}

fn validate_finite_many(values: &[(&'static str, f32)]) -> Result<(), RenderInputError> {
    for &(field, value) in values {
        validate_finite(field, value)?;
    }
    Ok(())
}

fn validate_positive(field: &'static str, value: f32) -> Result<(), RenderInputError> {
    validate_finite(field, value)?;
    if value <= 0.0 {
        return Err(RenderInputError::NonPositive { field });
    }
    Ok(())
}

fn validate_non_negative(field: &'static str, value: f32) -> Result<(), RenderInputError> {
    validate_finite(field, value)?;
    if value < 0.0 {
        return Err(RenderInputError::Negative { field });
    }
    Ok(())
}

fn validate_unit_interval(field: &'static str, value: f32) -> Result<(), RenderInputError> {
    validate_finite(field, value)?;
    if !(0.0..=1.0).contains(&value) {
        return Err(RenderInputError::OutOfRange { field });
    }
    Ok(())
}

fn validate_finite(field: &'static str, value: f32) -> Result<(), RenderInputError> {
    if value.is_finite() {
        Ok(())
    } else {
        Err(RenderInputError::NonFinite { field })
    }
}
