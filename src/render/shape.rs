//! Retained, GPU-friendly 2D shape assets.
//!
//! `CompoundShape` is deliberately split into two representations: a small, cloneable
//! command IR and an optional compiled flat-colour mesh.  Lua mutators only touch the IR
//! and bump `revision`; `compile` converts the IR once and the renderer can upload the
//! resulting mesh to a persistent GPU buffer.  This keeps authoring pleasant while making
//! the hot draw path an instanced indexed draw instead of per-frame tessellation.

use super::gpu_types::ColorVertex;
use super::renderer::{DrawMode, PathSegment};
use crate::math::{Mat3, Vec2};
use std::f32::consts::TAU;

/// Palette roles intentionally stay closed so built-in and user-authored shapes can share
/// deterministic material bindings.
pub const PALETTE_ROLES: [&str; 8] = [
    "background",
    "primary",
    "secondary",
    "accent",
    "outline",
    "highlight",
    "shadow",
    "emissive",
];

/// Maximum retained shape geometry accepted by the CPU compiler.
pub const MAX_SHAPE_VERTICES: usize = 1_000_000;
/// Maximum retained shape index count accepted by the CPU compiler.
pub const MAX_SHAPE_INDICES: usize = 3_000_000;
/// Maximum command count accepted by a retained shape.
pub const MAX_SHAPE_COMMANDS: usize = 65_536;

/// Fill winding rule used by native paths.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum FillRule {
    /// Winding number must be non-zero.
    NonZero,
    /// Odd/even nesting toggles fill state.
    EvenOdd,
}

/// Stroke cap style.  The compiler expands caps into ordinary triangles.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum StrokeCap {
    /// Stop exactly at the path endpoint.
    Butt,
    /// Add a semicircle at the endpoint.
    Round,
    /// Extend by half the stroke width.
    Square,
}

/// Stroke join style.  Miter falls back to bevel when the limit is exceeded.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum StrokeJoin {
    /// Extend the outside edges until they meet.
    Miter,
    /// Add a round fan at the join.
    Round,
    /// Clip the corner with a straight bevel.
    Bevel,
}

/// Native path stroke parameters.
#[derive(Debug, Clone, PartialEq)]
pub struct StrokeStyle {
    /// Width in local shape units.
    pub width: f32,
    /// Endpoint cap.
    pub cap: StrokeCap,
    /// Corner join.
    pub join: StrokeJoin,
    /// Miter cutoff, measured in multiples of `width`.
    pub miter_limit: f32,
    /// Alternating dash and gap lengths.  Empty means solid.
    pub dash: Vec<f32>,
    /// Offset into the dash pattern.
    pub dash_offset: f32,
}

impl Default for StrokeStyle {
    fn default() -> Self {
        Self {
            width: 1.0,
            cap: StrokeCap::Butt,
            join: StrokeJoin::Miter,
            miter_limit: 4.0,
            dash: Vec::new(),
            dash_offset: 0.0,
        }
    }
}

/// CPU geometry produced by `CompoundShape::compile`.
#[derive(Debug, Clone)]
pub struct CompiledShape {
    /// Indexed flat-colour vertices in shape-local coordinates.
    pub(crate) vertices: Vec<ColorVertex>,
    /// Triangle-list indices.
    pub(crate) indices: Vec<u32>,
    /// Axis-aligned bounds `(min_x, min_y, max_x, max_y)`.
    pub(crate) bounds: [f32; 4],
    /// Shape revision represented by this mesh.
    pub(crate) revision: u64,
    /// Curve flattening tolerance used to produce this mesh.
    pub(crate) tolerance: f32,
    /// Non-fatal compiler diagnostics.
    pub(crate) diagnostics: Vec<String>,
}

impl CompiledShape {
    /// Number of vertices in the compiled mesh.
    pub fn vertex_count(&self) -> usize {
        self.vertices.len()
    }

    /// Number of indices in the compiled mesh.
    pub fn index_count(&self) -> usize {
        self.indices.len()
    }
}

/// One drawing operation stored inside a `CompoundShape`.
#[derive(Debug, Clone)]
pub enum ShapeCommand {
    /// Set the active RGBA draw color.
    SetColor(f32, f32, f32, f32),
    /// Set the outline stroke width in pixels.
    SetLineWidth(f32),
    /// Set full stroke cap/join/dash style for subsequent strokes.
    SetStrokeStyle(StrokeStyle),
    /// Set the active semantic palette role.
    SetColorRole(String),
    /// Draw a filled or outlined axis-aligned rectangle.
    Rectangle {
        /// Fill or line mode.
        mode: DrawMode,
        /// Left edge.
        x: f32,
        /// Top edge.
        y: f32,
        /// Width.
        w: f32,
        /// Height.
        h: f32,
    },
    /// Draw a rounded rectangle.
    RoundedRectangle {
        /// Fill or line mode.
        mode: DrawMode,
        /// Left edge.
        x: f32,
        /// Top edge.
        y: f32,
        /// Width.
        w: f32,
        /// Height.
        h: f32,
        /// Horizontal radius.
        rx: f32,
        /// Vertical radius.
        ry: f32,
    },
    /// Draw a filled or outlined circle.
    Circle {
        /// Fill or line mode.
        mode: DrawMode,
        /// Center X.
        x: f32,
        /// Center Y.
        y: f32,
        /// Radius.
        r: f32,
    },
    /// Draw a filled or outlined ellipse.
    Ellipse {
        /// Fill or line mode.
        mode: DrawMode,
        /// Center X.
        x: f32,
        /// Center Y.
        y: f32,
        /// Horizontal radius.
        rx: f32,
        /// Vertical radius.
        ry: f32,
    },
    /// Draw a filled or outlined triangle.
    Triangle {
        /// Fill or line mode.
        mode: DrawMode,
        /// First vertex X.
        x1: f32,
        /// First vertex Y.
        y1: f32,
        /// Second vertex X.
        x2: f32,
        /// Second vertex Y.
        y2: f32,
        /// Third vertex X.
        x3: f32,
        /// Third vertex Y.
        y3: f32,
    },
    /// Draw a polygon from a flat `[x, y, ...]` list.
    Polygon {
        /// Fill or line mode.
        mode: DrawMode,
        /// Flat coordinate list.
        vertices: Vec<f32>,
    },
    /// Draw one stroked segment.
    Line {
        /// Start X.
        x1: f32,
        /// Start Y.
        y1: f32,
        /// End X.
        x2: f32,
        /// End Y.
        y2: f32,
    },
    /// Draw a stroked polyline.
    Polyline {
        /// Flat coordinate list.
        points: Vec<f32>,
    },
    /// Draw a circular arc or sector.
    Arc {
        /// Fill or line mode.
        mode: DrawMode,
        /// Center X.
        x: f32,
        /// Center Y.
        y: f32,
        /// Radius.
        radius: f32,
        /// Start angle in radians.
        angle1: f32,
        /// End angle in radians.
        angle2: f32,
        /// Requested segment count.
        segments: u32,
    },
    /// Draw one point as a small disc.
    Point {
        /// Center X.
        x: f32,
        /// Center Y.
        y: f32,
        /// Diameter in local units.
        size: f32,
    },
    /// Draw many points from a flat coordinate list.
    Points {
        /// Flat coordinate list.
        points: Vec<f32>,
        /// Diameter in local units.
        size: f32,
    },
    /// A path with multiple subpaths and curve verbs.
    Path {
        /// Path verbs.
        segments: Vec<PathSegment>,
        /// Fill or stroke mode.
        mode: DrawMode,
        /// Close open subpaths before filling/stroking.
        close: bool,
        /// Fill rule.
        fill_rule: FillRule,
        /// Stroke settings.
        stroke: StrokeStyle,
    },
    /// Snapshot of a child IR under a local transform.
    Transformed {
        /// Child command snapshot.
        commands: Vec<ShapeCommand>,
        /// Local transform applied before parent transforms.
        transform: Mat3,
        /// Palette snapshot used to resolve child role commands.
        palette: [[f32; 4]; 8],
    },
}

/// A named, replayable sequence of shape commands with an optional compiled mesh.
#[derive(Clone)]
pub struct CompoundShape {
    /// Ordered list of drawing commands that make up this shape.
    pub commands: Vec<ShapeCommand>,
    /// Most recently set draw color; persisted between replays.
    pub current_color: [f32; 4],
    /// Most recently set line width in pixels.
    pub current_line_width: f32,
    /// Current stroke cap/join/dash style.
    pub current_stroke_style: StrokeStyle,
    /// Closed semantic palette, stored as normalized RGBA values.
    pub palette: [[f32; 4]; 8],
    /// Monotonic revision invalidating compiled and uploaded geometry.
    pub revision: u64,
    /// Tolerance used when the renderer has to lazily recompile this shape.
    ///
    /// Keeping this separate from `compiled` means a mutation can invalidate
    /// the mesh without silently changing the author's selected tessellation
    /// quality on the next draw.
    pub(crate) compile_tolerance: f32,
    /// Compiled CPU geometry for `revision`, when warmed up.
    pub compiled: Option<CompiledShape>,
}

impl CompoundShape {
    /// Create an empty shape with white color, a 1 px line, and a useful default palette.
    pub fn new() -> Self {
        Self {
            commands: Vec::new(),
            current_color: [1.0, 1.0, 1.0, 1.0],
            current_line_width: 1.0,
            current_stroke_style: StrokeStyle::default(),
            palette: default_palette(),
            revision: 0,
            compile_tolerance: 0.1,
            compiled: None,
        }
    }

    /// Append a drawing command and invalidate any compiled geometry.
    pub fn push_command(&mut self, cmd: ShapeCommand) {
        // Keep one overflow marker in the IR so `compile()` can reject the
        // mutation atomically, while still bounding memory if an untrusted
        // caller keeps appending after the limit.
        if self.commands.len() <= MAX_SHAPE_COMMANDS {
            self.commands.push(cmd);
        }
        self.invalidate();
    }

    /// Remove all commands and reset mutable style state.
    pub fn clear(&mut self) {
        self.commands.clear();
        self.current_color = [1.0, 1.0, 1.0, 1.0];
        self.current_line_width = 1.0;
        self.current_stroke_style = StrokeStyle::default();
        self.palette = default_palette();
        self.compile_tolerance = 0.1;
        self.invalidate();
    }

    /// Return the number of commands, including nested child snapshots.
    pub fn command_count(&self) -> usize {
        self.commands.iter().map(command_count).sum()
    }

    /// Replace one semantic palette role and invalidate the retained mesh.
    pub fn set_palette_role(&mut self, role: &str, color: [f32; 4]) -> Result<(), String> {
        let index = role_index(role).ok_or_else(|| format!("unknown palette role '{role}'"))?;
        validate_color(color, "palette color")?;
        self.palette[index] = color;
        self.invalidate();
        Ok(())
    }

    /// Resolve a semantic role to its current color, falling back to white for malformed IR.
    pub fn palette_color(&self, role: &str) -> [f32; 4] {
        role_index(role)
            .map(|index| self.palette[index])
            .unwrap_or([1.0, 1.0, 1.0, 1.0])
    }

    /// Invalidate CPU/GPU-facing compiled data after any mutation.
    pub fn invalidate(&mut self) {
        self.revision = self.revision.wrapping_add(1);
        self.compiled = None;
    }

    /// Compile the command IR into deterministic indexed flat-colour geometry.
    pub fn compile(&mut self, tolerance: f32) -> Result<(), String> {
        if !tolerance.is_finite() || !(0.01..=2.0).contains(&tolerance) {
            return Err("shape curve tolerance must be finite and within 0.01..2.0".into());
        }
        if self.command_count() > MAX_SHAPE_COMMANDS {
            return Err(format!(
                "shape command count exceeds maximum of {MAX_SHAPE_COMMANDS}"
            ));
        }
        if self.compiled.as_ref().is_some_and(|compiled| {
            compiled.revision == self.revision && compiled.tolerance == tolerance
        }) {
            return Ok(());
        }
        let mut builder = ShapeBuilder::new(tolerance);
        compile_commands(
            &self.commands,
            Mat3::identity(),
            &mut builder,
            self.palette,
            self.current_color,
            self.current_line_width,
            self.current_stroke_style.clone(),
        )?;
        if builder.vertices.len() > MAX_SHAPE_VERTICES {
            return Err(format!(
                "shape vertices exceed maximum of {MAX_SHAPE_VERTICES}"
            ));
        }
        if builder.indices.len() > MAX_SHAPE_INDICES {
            return Err(format!(
                "shape indices exceed maximum of {MAX_SHAPE_INDICES}"
            ));
        }
        let bounds = builder.bounds.unwrap_or([0.0, 0.0, 0.0, 0.0]);
        self.compiled = Some(CompiledShape {
            vertices: builder.vertices,
            indices: builder.indices,
            bounds,
            revision: self.revision,
            tolerance,
            diagnostics: builder.diagnostics,
        });
        self.compile_tolerance = tolerance;
        Ok(())
    }

    /// Return bounds from compiled geometry or a conservative command scan.
    pub fn bounds(&self) -> [f32; 4] {
        if let Some(compiled) = &self.compiled {
            return compiled.bounds;
        }
        let mut builder = ShapeBuilder::new(0.1);
        let _ = compile_commands(
            &self.commands,
            Mat3::identity(),
            &mut builder,
            self.palette,
            self.current_color,
            self.current_line_width,
            self.current_stroke_style.clone(),
        );
        builder.bounds.unwrap_or([0.0, 0.0, 0.0, 0.0])
    }
}

/// Tessellate one immediate-mode path using the same retained-shape compiler.
///
/// Immediate paths still produce transient vertices by design, but sharing this
/// entry point keeps fill rules, curve flattening, holes, and stroke styles
/// identical to `LShape:path`.  Retained callers should use `CompoundShape::compile`
/// so the resulting buffers can stay resident on the GPU.
#[allow(clippy::too_many_arguments)]
pub(crate) fn tessellate_path(
    segments: &[PathSegment],
    mode: DrawMode,
    close: bool,
    fill_rule: FillRule,
    mut stroke: StrokeStyle,
    line_width: f32,
    transform: Mat3,
    color: [f32; 4],
    tolerance: f32,
) -> Result<(Vec<ColorVertex>, Vec<u32>), String> {
    if !tolerance.is_finite() || !(0.01..=2.0).contains(&tolerance) {
        return Err("path curve tolerance must be finite and within 0.01..2.0".into());
    }
    if !line_width.is_finite() || line_width < 0.0 {
        return Err("path line width must be finite and non-negative".into());
    }
    validate_color(color, "path color")?;
    if stroke.width <= 0.0 {
        stroke.width = line_width;
    }
    // Lyon is the primary path tessellator.  Keep the small deterministic
    // fallback below for dash patterns (which are intentionally expanded into
    // independent segments) and for malformed/degenerate paths so an invalid
    // immediate command never panics the render loop.
    if stroke.dash.is_empty() {
        if let Ok(geometry) = tessellate_path_with_lyon(
            segments,
            mode.clone(),
            close,
            fill_rule,
            &stroke,
            transform,
            color,
            tolerance,
        ) {
            return Ok(geometry);
        }
    }
    let mut builder = ShapeBuilder::new(tolerance);
    compile_commands(
        &[ShapeCommand::Path {
            segments: segments.to_vec(),
            mode,
            close,
            fill_rule,
            stroke,
        }],
        transform,
        &mut builder,
        default_palette(),
        color,
        line_width,
        StrokeStyle::default(),
    )?;
    Ok((builder.vertices, builder.indices))
}

#[allow(clippy::too_many_arguments)]
fn tessellate_path_with_lyon(
    segments: &[PathSegment],
    mode: DrawMode,
    close: bool,
    fill_rule: FillRule,
    stroke: &StrokeStyle,
    transform: Mat3,
    color: [f32; 4],
    tolerance: f32,
) -> Result<(Vec<ColorVertex>, Vec<u32>), String> {
    use lyon_path::math::point;
    use lyon_path::Path;
    use lyon_tessellation::{
        BuffersBuilder, FillOptions, FillRule as LyonFillRule, FillTessellator, FillVertex,
        LineCap, LineJoin, StrokeOptions, StrokeTessellator, StrokeVertex, VertexBuffers,
    };

    let mut builder = Path::builder();
    let mut active = false;
    for segment in segments {
        match segment {
            PathSegment::MoveTo { x, y } => {
                if active {
                    builder.end(close);
                }
                builder.begin(point(*x, *y));
                active = true;
            }
            PathSegment::LineTo { x, y } => {
                if !active {
                    return Err("path lineTo appears before moveTo".into());
                }
                builder.line_to(point(*x, *y));
            }
            PathSegment::QuadTo { cx, cy, x, y } => {
                if !active {
                    return Err("path quadTo appears before moveTo".into());
                }
                builder.quadratic_bezier_to(point(*cx, *cy), point(*x, *y));
            }
            PathSegment::CubicTo {
                cx1,
                cy1,
                cx2,
                cy2,
                x,
                y,
            } => {
                if !active {
                    return Err("path cubicTo appears before moveTo".into());
                }
                builder.cubic_bezier_to(point(*cx1, *cy1), point(*cx2, *cy2), point(*x, *y));
            }
        }
    }
    if active {
        builder.end(close);
    }
    if !active {
        return Ok((Vec::new(), Vec::new()));
    }
    let path = builder.build();
    let mut buffers: VertexBuffers<ColorVertex, u32> = VertexBuffers::new();
    match mode {
        DrawMode::Fill => {
            let options = FillOptions::default()
                .with_tolerance(tolerance)
                .with_fill_rule(match fill_rule {
                    FillRule::NonZero => LyonFillRule::NonZero,
                    FillRule::EvenOdd => LyonFillRule::EvenOdd,
                });
            FillTessellator::new()
                .tessellate_path(
                    &path,
                    &options,
                    &mut BuffersBuilder::new(&mut buffers, |vertex: FillVertex| {
                        let position = vertex.position();
                        let transformed = transform.transform_point(Vec2 {
                            x: position.x,
                            y: position.y,
                        });
                        ColorVertex {
                            position: [transformed.x, transformed.y],
                            color,
                        }
                    }),
                )
                .map_err(|error| format!("lyon fill tessellation failed: {error:?}"))?;
        }
        DrawMode::Line => {
            let options = StrokeOptions::default()
                .with_tolerance(tolerance)
                .with_line_width(stroke.width)
                .with_line_cap(match stroke.cap {
                    StrokeCap::Butt => LineCap::Butt,
                    StrokeCap::Round => LineCap::Round,
                    StrokeCap::Square => LineCap::Square,
                })
                .with_line_join(match stroke.join {
                    StrokeJoin::Miter => LineJoin::Miter,
                    StrokeJoin::Round => LineJoin::Round,
                    StrokeJoin::Bevel => LineJoin::Bevel,
                })
                .with_miter_limit(stroke.miter_limit);
            StrokeTessellator::new()
                .tessellate_path(
                    &path,
                    &options,
                    &mut BuffersBuilder::new(&mut buffers, |vertex: StrokeVertex| {
                        let position = vertex.position();
                        let transformed = transform.transform_point(Vec2 {
                            x: position.x,
                            y: position.y,
                        });
                        ColorVertex {
                            position: [transformed.x, transformed.y],
                            color,
                        }
                    }),
                )
                .map_err(|error| format!("lyon stroke tessellation failed: {error:?}"))?;
        }
    }
    Ok((buffers.vertices, buffers.indices))
}

impl Default for CompoundShape {
    fn default() -> Self {
        Self::new()
    }
}

fn default_palette() -> [[f32; 4]; 8] {
    [
        [0.08, 0.10, 0.14, 1.0],
        [0.82, 0.86, 0.92, 1.0],
        [0.42, 0.50, 0.62, 1.0],
        [0.95, 0.63, 0.18, 1.0],
        [0.08, 0.10, 0.14, 1.0],
        [1.0, 1.0, 1.0, 1.0],
        [0.18, 0.20, 0.28, 1.0],
        [0.35, 0.95, 0.92, 1.0],
    ]
}

/// Return the palette index for a closed role name.
pub fn role_index(role: &str) -> Option<usize> {
    PALETTE_ROLES
        .iter()
        .position(|candidate| *candidate == role)
}

/// Validate a normalized finite RGBA color.
pub fn validate_color(color: [f32; 4], label: &str) -> Result<(), String> {
    if color
        .iter()
        .any(|value| !value.is_finite() || !(0.0..=1.0).contains(value))
    {
        return Err(format!("{label} channels must be finite values in 0..1"));
    }
    Ok(())
}

fn command_count(command: &ShapeCommand) -> usize {
    match command {
        ShapeCommand::Transformed { commands, .. } => {
            1 + commands.iter().map(command_count).sum::<usize>()
        }
        _ => 1,
    }
}

struct ShapeBuilder {
    vertices: Vec<ColorVertex>,
    indices: Vec<u32>,
    bounds: Option<[f32; 4]>,
    tolerance: f32,
    diagnostics: Vec<String>,
}

impl ShapeBuilder {
    fn new(tolerance: f32) -> Self {
        Self {
            vertices: Vec::new(),
            indices: Vec::new(),
            bounds: None,
            tolerance,
            diagnostics: Vec::new(),
        }
    }

    fn color(&self, color: [f32; 4]) -> [f32; 4] {
        color
    }

    fn add_vertex(&mut self, point: [f32; 2], color: [f32; 4]) -> Result<u32, String> {
        if !point.iter().all(|value| value.is_finite()) {
            return Err("shape geometry contains a non-finite coordinate".into());
        }
        if self.vertices.len() >= MAX_SHAPE_VERTICES {
            return Err(format!(
                "shape vertices exceed maximum of {MAX_SHAPE_VERTICES}"
            ));
        }
        let index = u32::try_from(self.vertices.len())
            .map_err(|_| "shape vertex index exceeds u32 range".to_string())?;
        self.vertices.push(ColorVertex {
            position: point,
            color: self.color(color),
        });
        match &mut self.bounds {
            Some(bounds) => {
                bounds[0] = bounds[0].min(point[0]);
                bounds[1] = bounds[1].min(point[1]);
                bounds[2] = bounds[2].max(point[0]);
                bounds[3] = bounds[3].max(point[1]);
            }
            None => self.bounds = Some([point[0], point[1], point[0], point[1]]),
        }
        Ok(index)
    }

    fn add_triangle(
        &mut self,
        a: [f32; 2],
        b: [f32; 2],
        c: [f32; 2],
        color: [f32; 4],
    ) -> Result<(), String> {
        let base = self.vertices.len();
        let ia = self.add_vertex(a, color)?;
        let ib = self.add_vertex(b, color)?;
        let ic = self.add_vertex(c, color)?;
        if self.indices.len() > MAX_SHAPE_INDICES.saturating_sub(3) {
            self.vertices.truncate(base);
            return Err(format!(
                "shape indices exceed maximum of {MAX_SHAPE_INDICES}"
            ));
        }
        self.indices.extend([ia, ib, ic]);
        Ok(())
    }

    fn append_geometry(
        &mut self,
        vertices: Vec<ColorVertex>,
        indices: Vec<u32>,
    ) -> Result<(), String> {
        let total_vertices = self
            .vertices
            .len()
            .checked_add(vertices.len())
            .ok_or_else(|| "tessellated path vertex count overflow".to_string())?;
        let total_indices = self
            .indices
            .len()
            .checked_add(indices.len())
            .ok_or_else(|| "tessellated path index count overflow".to_string())?;
        if total_indices > MAX_SHAPE_INDICES
            || total_vertices > MAX_SHAPE_VERTICES
            || !indices.len().is_multiple_of(3)
        {
            return Err("tessellated path geometry exceeds the retained-shape limits".into());
        }
        if vertices.iter().any(|vertex| {
            vertex
                .position
                .iter()
                .chain(vertex.color.iter())
                .any(|value| !value.is_finite())
        }) {
            return Err("tessellated path geometry contains a non-finite value".into());
        }
        if indices
            .iter()
            .any(|&index| index as usize >= vertices.len())
        {
            return Err("tessellated path index references an invalid vertex".into());
        }
        let base = u32::try_from(self.vertices.len())
            .map_err(|_| "shape vertex index exceeds u32 range".to_string())?;
        for vertex in vertices {
            self.add_vertex(vertex.position, vertex.color)?;
        }
        for index in indices {
            self.indices.push(
                base.checked_add(index)
                    .ok_or_else(|| "shape index exceeds u32 range".to_string())?,
            );
        }
        Ok(())
    }

    fn add_polygon(
        &mut self,
        points: &[[f32; 2]],
        color: [f32; 4],
        mode: &DrawMode,
        stroke: &StrokeStyle,
        fill_rule: FillRule,
    ) -> Result<(), String> {
        if points.len() < 2 {
            return Ok(());
        }
        if matches!(mode, DrawMode::Fill) {
            let triangles = triangulate_polygon(points, fill_rule);
            for [a, b, c] in triangles {
                self.add_triangle(points[a], points[b], points[c], color)?;
            }
        } else {
            self.add_polyline(points, true, color, stroke)?;
        }
        Ok(())
    }

    /// Fill several closed subpaths while treating nested loops as holes.
    /// This is intentionally small and deterministic; it keeps the retained
    /// shape path contract useful without allocating a second scene graph.
    fn add_compound_fill(
        &mut self,
        subpaths: &[Vec<[f32; 2]>],
        color: [f32; 4],
        fill_rule: FillRule,
    ) -> Result<(), String> {
        let mut loops: Vec<Vec<[f32; 2]>> = subpaths
            .iter()
            .filter(|path| path.len() >= 3)
            .cloned()
            .collect();
        if loops.is_empty() {
            return Ok(());
        }
        // Split disjoint outers from nested holes using containment depth.
        // For non-zero winding, the largest loop is the stable outer fallback;
        // callers can still control orientation for ordinary single paths.
        let all_loops = loops.clone();
        let largest = loops
            .iter()
            .enumerate()
            .max_by(|(_, a), (_, b)| {
                polygon_signed_area(a)
                    .abs()
                    .total_cmp(&polygon_signed_area(b).abs())
            })
            .map(|(index, _)| index)
            .unwrap_or(0);
        let outer_reference = loops
            .get(largest)
            .cloned()
            .unwrap_or_else(|| loops[0].clone());
        let mut outers: Vec<Vec<[f32; 2]>> = Vec::new();
        let mut holes: Vec<Vec<[f32; 2]>> = Vec::new();
        for (index, path) in loops.drain(..).enumerate() {
            let sample = path[0];
            let mut depth = 0usize;
            for (other_index, other) in all_loops.iter().enumerate() {
                if index == other_index || other.len() < 3 {
                    continue;
                }
                if point_in_polygon(sample, other) {
                    depth += 1;
                }
            }
            let is_hole = match fill_rule {
                FillRule::EvenOdd => depth % 2 == 1,
                FillRule::NonZero => {
                    index != largest
                        && polygon_signed_area(&path).signum()
                            != polygon_signed_area(&outer_reference).signum()
                }
            };
            if is_hole {
                holes.push(path);
            } else {
                outers.push(path);
            }
        }
        if outers.is_empty() {
            return Ok(());
        }
        for mut outer in outers {
            let mut attached = Vec::new();
            for hole in &holes {
                if point_in_polygon(hole[0], &outer) {
                    attached.push(hole.clone());
                }
            }
            for hole in attached {
                outer = bridge_hole(&outer, &hole);
            }
            for [a, b, c] in triangulate_polygon(&outer, FillRule::NonZero) {
                self.add_triangle(outer[a], outer[b], outer[c], color)?;
            }
        }
        Ok(())
    }

    fn add_polyline(
        &mut self,
        points: &[[f32; 2]],
        closed: bool,
        color: [f32; 4],
        stroke: &StrokeStyle,
    ) -> Result<(), String> {
        if points.len() < 2 || stroke.width <= 0.0 {
            return Ok(());
        }
        // Closed paths produced by the path flattener may already repeat their
        // first point.  Remove that duplicate so joins are generated exactly
        // once and zero-length closing segments do not perturb the miter math.
        let mut clean = points.to_vec();
        if closed && clean.len() > 2 && clean.first() == clean.last() {
            clean.pop();
        }
        if clean.len() < 2 {
            return Ok(());
        }
        let end = if closed { clean.len() } else { clean.len() - 1 };
        for i in 0..end {
            let a = clean[i];
            let b = clean[(i + 1) % clean.len()];
            self.add_dashed_segment(a, b, color, stroke)?;
        }
        if !closed {
            match stroke.cap {
                StrokeCap::Square => {
                    self.add_cap(clean[0], clean[1], color, stroke, true)?;
                    self.add_cap(
                        clean[clean.len() - 1],
                        clean[clean.len() - 2],
                        color,
                        stroke,
                        true,
                    )?;
                }
                StrokeCap::Round => {
                    self.add_round_cap(clean[0], stroke.width * 0.5, color)?;
                    self.add_round_cap(clean[clean.len() - 1], stroke.width * 0.5, color)?;
                }
                StrokeCap::Butt => {}
            }
        }
        // Segment quads meet at the centerline, so miter and bevel joins need
        // an explicit outer wedge.  Only solid strokes are joined; a dashed
        // stroke intentionally keeps each dash independent.
        if stroke.dash.is_empty() && clean.len() >= 3 {
            let first = if closed { 0 } else { 1 };
            let last = if closed { clean.len() } else { clean.len() - 1 };
            for i in first..last {
                let previous = clean[(i + clean.len() - 1) % clean.len()];
                let current = clean[i % clean.len()];
                let next = clean[(i + 1) % clean.len()];
                self.add_join(previous, current, next, color, stroke)?;
            }
        }
        Ok(())
    }

    fn add_join(
        &mut self,
        previous: [f32; 2],
        current: [f32; 2],
        next: [f32; 2],
        color: [f32; 4],
        stroke: &StrokeStyle,
    ) -> Result<(), String> {
        let half = stroke.width * 0.5;
        let d1 = normalize([current[0] - previous[0], current[1] - previous[1]]);
        let d2 = normalize([next[0] - current[0], next[1] - current[1]]);
        if d1 == [0.0, 0.0] || d2 == [0.0, 0.0] {
            return Ok(());
        }
        let cross = d1[0] * d2[1] - d1[1] * d2[0];
        if cross.abs() <= 1e-5 {
            return Ok(());
        }
        let n1 = [-d1[1], d1[0]];
        let n2 = [-d2[1], d2[0]];
        let side = if cross > 0.0 { 1.0 } else { -1.0 };
        let a = [
            current[0] + n1[0] * half * side,
            current[1] + n1[1] * half * side,
        ];
        let b = [
            current[0] + n2[0] * half * side,
            current[1] + n2[1] * half * side,
        ];
        match stroke.join {
            StrokeJoin::Round => self.add_round_join(current, a, b, color, side, half),
            StrokeJoin::Bevel => self.add_triangle(current, a, b, color),
            StrokeJoin::Miter => {
                let denominator = d1[0] * d2[1] - d1[1] * d2[0];
                let delta = [b[0] - a[0], b[1] - a[1]];
                let t = (delta[0] * d2[1] - delta[1] * d2[0]) / denominator;
                let miter = [a[0] + d1[0] * t, a[1] + d1[1] * t];
                let miter_length =
                    ((miter[0] - current[0]).powi(2) + (miter[1] - current[1]).powi(2)).sqrt();
                if miter_length <= half * stroke.miter_limit.max(1.0) {
                    self.add_triangle(current, a, miter, color)?;
                    self.add_triangle(current, miter, b, color)
                } else {
                    self.add_triangle(current, a, b, color)
                }
            }
        }
    }

    fn add_round_join(
        &mut self,
        center: [f32; 2],
        a: [f32; 2],
        b: [f32; 2],
        color: [f32; 4],
        side: f32,
        radius: f32,
    ) -> Result<(), String> {
        let start = (a[1] - center[1]).atan2(a[0] - center[0]);
        let mut delta = (b[1] - center[1]).atan2(b[0] - center[0]) - start;
        if side > 0.0 {
            while delta < 0.0 {
                delta += TAU;
            }
        } else {
            while delta > 0.0 {
                delta -= TAU;
            }
        }
        let segments = ((delta.abs() * radius.max(1.0)) / self.tolerance.max(0.01))
            .ceil()
            .clamp(1.0, 64.0) as usize;
        let center_index = self.add_vertex(center, color)?;
        let mut previous_index = self.add_vertex(a, color)?;
        for step in 1..=segments {
            let angle = start + delta * step as f32 / segments as f32;
            let point = [
                center[0] + radius * angle.cos(),
                center[1] + radius * angle.sin(),
            ];
            let next_index = self.add_vertex(point, color)?;
            self.indices
                .extend([center_index, previous_index, next_index]);
            previous_index = next_index;
        }
        Ok(())
    }

    fn add_dashed_segment(
        &mut self,
        a: [f32; 2],
        b: [f32; 2],
        color: [f32; 4],
        stroke: &StrokeStyle,
    ) -> Result<(), String> {
        let dx = b[0] - a[0];
        let dy = b[1] - a[1];
        let length = (dx * dx + dy * dy).sqrt();
        if length <= f32::EPSILON {
            return Ok(());
        }
        if stroke.dash.is_empty() {
            return self.add_cap(a, b, color, stroke, false);
        }
        let mut distance = 0.0;
        let mut pattern_index = 0usize;
        let mut pattern_offset = stroke.dash_offset;
        let pattern_total: f32 = stroke.dash.iter().copied().sum();
        if !pattern_total.is_finite() || pattern_total <= 0.0 {
            return self.add_cap(a, b, color, stroke, false);
        }
        pattern_offset = pattern_offset.rem_euclid(pattern_total);
        while pattern_offset > stroke.dash[pattern_index] {
            pattern_offset -= stroke.dash[pattern_index];
            pattern_index = (pattern_index + 1) % stroke.dash.len();
        }
        let mut remaining_in_pattern = (stroke.dash[pattern_index] - pattern_offset).max(0.0);
        while distance < length - 1e-5 {
            let step = remaining_in_pattern.min(length - distance).max(1e-5);
            let t0 = distance / length;
            let t1 = (distance + step) / length;
            if pattern_index & 1 == 0 {
                let p0 = [a[0] + dx * t0, a[1] + dy * t0];
                let p1 = [a[0] + dx * t1, a[1] + dy * t1];
                self.add_cap(p0, p1, color, stroke, false)?;
            }
            distance += step;
            remaining_in_pattern -= step;
            if remaining_in_pattern <= 1e-5 {
                pattern_index = (pattern_index + 1) % stroke.dash.len();
                remaining_in_pattern = stroke.dash[pattern_index].max(1e-5);
            }
        }
        Ok(())
    }

    fn add_cap(
        &mut self,
        a: [f32; 2],
        b: [f32; 2],
        color: [f32; 4],
        stroke: &StrokeStyle,
        extend: bool,
    ) -> Result<(), String> {
        let mut a = a;
        let mut b = b;
        let dx = b[0] - a[0];
        let dy = b[1] - a[1];
        let length = (dx * dx + dy * dy).sqrt().max(f32::EPSILON);
        if extend || stroke.cap == StrokeCap::Square {
            let ex = dx / length * stroke.width * 0.5;
            let ey = dy / length * stroke.width * 0.5;
            a = [a[0] - ex, a[1] - ey];
            b = [b[0] + ex, b[1] + ey];
        }
        let nx = -dy / length * stroke.width * 0.5;
        let ny = dx / length * stroke.width * 0.5;
        self.add_triangle(
            [a[0] + nx, a[1] + ny],
            [b[0] + nx, b[1] + ny],
            [b[0] - nx, b[1] - ny],
            color,
        )?;
        self.add_triangle(
            [a[0] + nx, a[1] + ny],
            [b[0] - nx, b[1] - ny],
            [a[0] - nx, a[1] - ny],
            color,
        )?;
        Ok(())
    }

    fn add_round_cap(
        &mut self,
        center: [f32; 2],
        radius: f32,
        color: [f32; 4],
    ) -> Result<(), String> {
        let segments = circle_segments(radius, self.tolerance);
        let required_indices = (segments as usize).saturating_mul(3);
        if self.indices.len() > MAX_SHAPE_INDICES.saturating_sub(required_indices) {
            return Err(format!(
                "shape indices exceed maximum of {MAX_SHAPE_INDICES}"
            ));
        }
        let mut points = Vec::with_capacity(segments as usize);
        for i in 0..segments {
            let angle = TAU * i as f32 / segments as f32;
            points.push([
                center[0] + radius * angle.cos(),
                center[1] + radius * angle.sin(),
            ]);
        }
        let center_index = self.add_vertex(center, color)?;
        for i in 0..segments as usize {
            let a = self.add_vertex(points[i], color)?;
            let b = self.add_vertex(points[(i + 1) % points.len()], color)?;
            self.indices.extend([center_index, a, b]);
        }
        Ok(())
    }
}

fn compile_commands(
    commands: &[ShapeCommand],
    transform: Mat3,
    builder: &mut ShapeBuilder,
    palette: [[f32; 4]; 8],
    mut color: [f32; 4],
    mut line_width: f32,
    mut stroke_style: StrokeStyle,
) -> Result<(), String> {
    for command in commands {
        match command {
            ShapeCommand::SetColor(r, g, b, a) => color = [*r, *g, *b, *a],
            ShapeCommand::SetColorRole(role) => {
                if let Some(index) = role_index(role) {
                    color = palette[index];
                } else {
                    builder
                        .diagnostics
                        .push(format!("unknown palette role '{role}', using white"));
                    color = [1.0, 1.0, 1.0, 1.0];
                }
            }
            ShapeCommand::SetLineWidth(width) => line_width = *width,
            ShapeCommand::SetStrokeStyle(style) => {
                stroke_style = style.clone();
                line_width = style.width;
            }
            ShapeCommand::Rectangle { mode, x, y, w, h } => {
                let points = transformed_points(
                    &[[*x, *y], [*x + *w, *y], [*x + *w, *y + *h], [*x, *y + *h]],
                    transform,
                );
                builder.add_polygon(&points, color, mode, &stroke_style, FillRule::NonZero)?;
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
                let points = rounded_rect_points(*x, *y, *w, *h, *rx, *ry, 8);
                let points = transformed_points(&points, transform);
                builder.add_polygon(&points, color, mode, &stroke_style, FillRule::NonZero)?;
            }
            ShapeCommand::Circle { mode, x, y, r } => {
                let points = ellipse_points(*x, *y, *r, *r, circle_segments(*r, builder.tolerance));
                let points = transformed_points(&points, transform);
                builder.add_polygon(&points, color, mode, &stroke_style, FillRule::NonZero)?;
            }
            ShapeCommand::Ellipse { mode, x, y, rx, ry } => {
                let points = ellipse_points(
                    *x,
                    *y,
                    *rx,
                    *ry,
                    circle_segments((*rx).max(*ry), builder.tolerance),
                );
                let points = transformed_points(&points, transform);
                builder.add_polygon(&points, color, mode, &stroke_style, FillRule::NonZero)?;
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
                let points = transformed_points(&[[*x1, *y1], [*x2, *y2], [*x3, *y3]], transform);
                builder.add_polygon(&points, color, mode, &stroke_style, FillRule::NonZero)?;
            }
            ShapeCommand::Polygon { mode, vertices } => {
                let points = flat_points(vertices)?;
                let points = transformed_points(&points, transform);
                builder.add_polygon(&points, color, mode, &stroke_style, FillRule::NonZero)?;
            }
            ShapeCommand::Line { x1, y1, x2, y2 } => {
                let points = transformed_points(&[[*x1, *y1], [*x2, *y2]], transform);
                let mut style = stroke_style.clone();
                style.width = line_width;
                builder.add_polyline(&points, false, color, &style)?;
            }
            ShapeCommand::Polyline { points } => {
                let points = transformed_points(&flat_points(points)?, transform);
                let mut style = stroke_style.clone();
                style.width = line_width;
                builder.add_polyline(&points, false, color, &style)?;
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
                let count = (*segments).clamp(2, 2048) as usize;
                let mut points = Vec::with_capacity(count + 1);
                for i in 0..=count {
                    let t = i as f32 / count as f32;
                    let angle = *angle1 + (*angle2 - *angle1) * t;
                    points.push([*x + *radius * angle.cos(), *y + *radius * angle.sin()]);
                }
                if matches!(mode, DrawMode::Fill) {
                    let mut sector = Vec::with_capacity(points.len() + 1);
                    sector.push([*x, *y]);
                    sector.extend(points);
                    let sector = transformed_points(&sector, transform);
                    builder.add_polygon(&sector, color, mode, &stroke_style, FillRule::NonZero)?;
                } else {
                    let points = transformed_points(&points, transform);
                    let mut style = stroke_style.clone();
                    style.width = line_width;
                    builder.add_polyline(&points, false, color, &style)?;
                }
            }
            ShapeCommand::Point { x, y, size } => {
                let center = transform.transform_point(Vec2 { x: *x, y: *y });
                let radius = size.abs() * 0.5;
                builder.add_round_cap([center.x, center.y], radius, color)?;
            }
            ShapeCommand::Points { points, size } => {
                let flat = flat_points(points)?;
                for point in flat {
                    let center = transform.transform_point(Vec2 {
                        x: point[0],
                        y: point[1],
                    });
                    builder.add_round_cap([center.x, center.y], size.abs() * 0.5, color)?;
                }
            }
            ShapeCommand::Path {
                segments,
                mode,
                close,
                fill_rule,
                stroke,
            } => {
                let subpaths = flatten_path(segments, *close, builder.tolerance)?;
                let transformed: Vec<Vec<[f32; 2]>> = subpaths
                    .iter()
                    .map(|subpath| transformed_points(subpath, transform))
                    .collect();
                let mut style = stroke.clone();
                if style.width <= 0.0 {
                    style.width = line_width;
                }
                if style.dash.is_empty() {
                    if let Ok((vertices, indices)) = tessellate_path_with_lyon(
                        segments,
                        mode.clone(),
                        *close,
                        *fill_rule,
                        &style,
                        transform,
                        color,
                        builder.tolerance,
                    ) {
                        builder.append_geometry(vertices, indices)?;
                        continue;
                    }
                }
                if matches!(mode, DrawMode::Fill) && transformed.len() > 1 {
                    builder.add_compound_fill(&transformed, color, *fill_rule)?;
                } else {
                    for subpath in transformed {
                        builder.add_polygon(&subpath, color, mode, &style, *fill_rule)?;
                    }
                }
            }
            ShapeCommand::Transformed {
                commands: child,
                transform: child_transform,
                palette: child_palette,
            } => {
                compile_commands(
                    child,
                    transform * *child_transform,
                    builder,
                    *child_palette,
                    color,
                    line_width,
                    stroke_style.clone(),
                )?;
            }
        }
    }
    Ok(())
}

fn flat_points(values: &[f32]) -> Result<Vec<[f32; 2]>, String> {
    if values.len() < 2 || values.len() & 1 != 0 {
        return Err("shape points must contain an even number of coordinates".into());
    }
    if values.iter().any(|value| !value.is_finite()) {
        return Err("shape points must be finite".into());
    }
    Ok(values
        .chunks_exact(2)
        .map(|pair| [pair[0], pair[1]])
        .collect())
}

fn normalize(vector: [f32; 2]) -> [f32; 2] {
    let length = (vector[0] * vector[0] + vector[1] * vector[1]).sqrt();
    if length <= f32::EPSILON {
        [0.0, 0.0]
    } else {
        [vector[0] / length, vector[1] / length]
    }
}

fn transformed_points(points: &[[f32; 2]], transform: Mat3) -> Vec<[f32; 2]> {
    points
        .iter()
        .map(|point| {
            let result = transform.transform_point(Vec2 {
                x: point[0],
                y: point[1],
            });
            [result.x, result.y]
        })
        .collect()
}

fn circle_segments(radius: f32, tolerance: f32) -> u32 {
    let extent = radius.abs().max(1.0);
    (((TAU * extent) / tolerance.max(0.01)).ceil() as u32).clamp(12, 256)
}

fn ellipse_points(x: f32, y: f32, rx: f32, ry: f32, segments: u32) -> Vec<[f32; 2]> {
    (0..segments)
        .map(|index| {
            let angle = TAU * index as f32 / segments as f32;
            [x + rx * angle.cos(), y + ry * angle.sin()]
        })
        .collect()
}

fn rounded_rect_points(
    x: f32,
    y: f32,
    w: f32,
    h: f32,
    rx: f32,
    ry: f32,
    corner_segments: u32,
) -> Vec<[f32; 2]> {
    let rx = rx.abs().min(w.abs() * 0.5);
    let ry = ry.abs().min(h.abs() * 0.5);
    let mut points = Vec::with_capacity((corner_segments * 4) as usize);
    for (cx, cy, start) in [
        (x + w - rx, y + ry, -std::f32::consts::FRAC_PI_2),
        (x + w - rx, y + h - ry, 0.0),
        (x + rx, y + h - ry, std::f32::consts::FRAC_PI_2),
        (x + rx, y + ry, std::f32::consts::PI),
    ] {
        for step in 0..corner_segments {
            let angle = start
                + std::f32::consts::FRAC_PI_2 * step as f32 / (corner_segments - 1).max(1) as f32;
            points.push([cx + rx * angle.cos(), cy + ry * angle.sin()]);
        }
    }
    points
}

fn flatten_path(
    segments: &[PathSegment],
    close: bool,
    tolerance: f32,
) -> Result<Vec<Vec<[f32; 2]>>, String> {
    let mut result: Vec<Vec<[f32; 2]>> = Vec::new();
    let mut current: Option<Vec<[f32; 2]>> = None;
    let mut cursor = [0.0, 0.0];
    let mut start = [0.0, 0.0];
    for segment in segments {
        match segment {
            PathSegment::MoveTo { x, y } => {
                if let Some(mut path) = current.take() {
                    if close && path.len() > 1 && path.last() != Some(&start) {
                        path.push(start);
                    }
                    if path.len() >= 2 {
                        result.push(path);
                    }
                }
                cursor = [*x, *y];
                start = cursor;
                current = Some(vec![cursor]);
            }
            PathSegment::LineTo { x, y } => {
                let path = current.get_or_insert_with(|| vec![cursor]);
                path.push([*x, *y]);
                cursor = [*x, *y];
            }
            PathSegment::QuadTo { cx, cy, x, y } => {
                let start_point = cursor;
                let end = [*x, *y];
                let steps = curve_steps(start_point, [*cx, *cy], end, tolerance);
                let path = current.get_or_insert_with(|| vec![cursor]);
                for step in 1..=steps {
                    let t = step as f32 / steps as f32;
                    let mt = 1.0 - t;
                    path.push([
                        mt * mt * start_point[0] + 2.0 * mt * t * *cx + t * t * end[0],
                        mt * mt * start_point[1] + 2.0 * mt * t * *cy + t * t * end[1],
                    ]);
                }
                cursor = end;
            }
            PathSegment::CubicTo {
                cx1,
                cy1,
                cx2,
                cy2,
                x,
                y,
            } => {
                let start_point = cursor;
                let end = [*x, *y];
                let steps = curve_steps(start_point, [*cx1, *cy1], end, tolerance)
                    .max(curve_steps(start_point, [*cx2, *cy2], end, tolerance));
                let path = current.get_or_insert_with(|| vec![cursor]);
                for step in 1..=steps {
                    let t = step as f32 / steps as f32;
                    let mt = 1.0 - t;
                    path.push([
                        mt.powi(3) * start_point[0]
                            + 3.0 * mt.powi(2) * t * *cx1
                            + 3.0 * mt * t.powi(2) * *cx2
                            + t.powi(3) * end[0],
                        mt.powi(3) * start_point[1]
                            + 3.0 * mt.powi(2) * t * *cy1
                            + 3.0 * mt * t.powi(2) * *cy2
                            + t.powi(3) * end[1],
                    ]);
                }
                cursor = end;
            }
        }
    }
    if let Some(mut path) = current {
        if close && path.len() > 1 && path.last() != Some(&start) {
            path.push(start);
        }
        if path.len() >= 2 {
            result.push(path);
        }
    }
    if result.is_empty() {
        return Err("path must contain at least one moveTo/lineTo subpath".into());
    }
    Ok(result)
}

fn curve_steps(a: [f32; 2], c: [f32; 2], b: [f32; 2], tolerance: f32) -> usize {
    let length = ((c[0] - a[0]).powi(2) + (c[1] - a[1]).powi(2)).sqrt()
        + ((b[0] - c[0]).powi(2) + (b[1] - c[1]).powi(2)).sqrt();
    ((length / tolerance.max(0.01)).ceil() as usize).clamp(4, 256)
}

fn polygon_signed_area(points: &[[f32; 2]]) -> f32 {
    points
        .iter()
        .enumerate()
        .map(|(index, point)| {
            let next = points[(index + 1) % points.len()];
            point[0] * next[1] - next[0] * point[1]
        })
        .sum::<f32>()
        * 0.5
}

fn point_in_polygon(point: [f32; 2], polygon: &[[f32; 2]]) -> bool {
    if polygon.len() < 3 {
        return false;
    }
    let mut inside = false;
    let mut previous = polygon[polygon.len() - 1];
    for &current in polygon {
        let crosses = (current[1] > point[1]) != (previous[1] > point[1]);
        if crosses {
            let denominator = previous[1] - current[1];
            if denominator.abs() <= f32::EPSILON {
                previous = current;
                continue;
            }
            let x_at_y =
                (previous[0] - current[0]) * (point[1] - current[1]) / denominator + current[0];
            if point[0] < x_at_y {
                inside = !inside;
            }
        }
        previous = current;
    }
    inside
}

/// Join a hole to the nearest right-side outer vertex.  Ear clipping then
/// produces an indexed mesh whose triangles never cover the hole interior.
fn bridge_hole(outer: &[[f32; 2]], hole: &[[f32; 2]]) -> Vec<[f32; 2]> {
    if outer.len() < 3 || hole.len() < 3 {
        return outer.to_vec();
    }
    let hole_index = hole
        .iter()
        .enumerate()
        .max_by(|(_, a), (_, b)| a[0].total_cmp(&b[0]).then_with(|| a[1].total_cmp(&b[1])))
        .map(|(index, _)| index)
        .unwrap_or(0);
    let hole_point = hole[hole_index];
    let outer_index = outer
        .iter()
        .enumerate()
        .filter(|(_, point)| point[0] >= hole_point[0])
        .min_by(|(_, a), (_, b)| {
            let da = (a[0] - hole_point[0]).powi(2) + (a[1] - hole_point[1]).powi(2);
            let db = (b[0] - hole_point[0]).powi(2) + (b[1] - hole_point[1]).powi(2);
            da.total_cmp(&db)
        })
        .map(|(index, _)| index)
        .unwrap_or_else(|| {
            outer
                .iter()
                .enumerate()
                .max_by(|(_, a), (_, b)| a[0].total_cmp(&b[0]))
                .map(|(index, _)| index)
                .unwrap_or(0)
        });
    let mut merged = Vec::with_capacity(outer.len() + hole.len() + 2);
    for offset in 0..outer.len() {
        let index = (outer_index + offset) % outer.len();
        merged.push(outer[index]);
        if offset == 0 {
            merged.push(hole_point);
            for step in 1..=hole.len() {
                merged.push(hole[(hole_index + step) % hole.len()]);
            }
            merged.push(hole_point);
        }
    }
    merged
}

fn triangulate_polygon(points: &[[f32; 2]], _fill_rule: FillRule) -> Vec<[usize; 3]> {
    if points.len() < 3 {
        return Vec::new();
    }
    let mut indices: Vec<usize> = (0..points.len()).collect();
    if polygon_signed_area(points) < 0.0 {
        indices.reverse();
    }
    let mut triangles = Vec::with_capacity(points.len().saturating_sub(2));
    let mut guard = 0usize;
    while indices.len() > 2 && guard < points.len().saturating_mul(points.len()) {
        guard += 1;
        let mut ear_found = false;
        for i in 0..indices.len() {
            let prev = indices[(i + indices.len() - 1) % indices.len()];
            let current = indices[i];
            let next = indices[(i + 1) % indices.len()];
            if cross(points[prev], points[current], points[next]) <= 1e-6 {
                continue;
            }
            if indices.iter().any(|candidate| {
                *candidate != prev
                    && *candidate != current
                    && *candidate != next
                    && point_in_triangle(
                        points[*candidate],
                        points[prev],
                        points[current],
                        points[next],
                    )
            }) {
                continue;
            }
            triangles.push([prev, current, next]);
            indices.remove(i);
            ear_found = true;
            break;
        }
        if !ear_found {
            // Degenerate/self-intersecting input is kept drawable with a deterministic fan.
            for i in 1..indices.len().saturating_sub(1) {
                triangles.push([indices[0], indices[i], indices[i + 1]]);
            }
            break;
        }
    }
    triangles
}

fn cross(a: [f32; 2], b: [f32; 2], c: [f32; 2]) -> f32 {
    (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])
}

fn point_in_triangle(p: [f32; 2], a: [f32; 2], b: [f32; 2], c: [f32; 2]) -> bool {
    let c1 = cross(a, b, p);
    let c2 = cross(b, c, p);
    let c3 = cross(c, a, p);
    (c1 >= -1e-6 && c2 >= -1e-6 && c3 >= -1e-6) || (c1 <= 1e-6 && c2 <= 1e-6 && c3 <= 1e-6)
}
