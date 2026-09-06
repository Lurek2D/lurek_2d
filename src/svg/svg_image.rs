//! `src/svg/svg_image.rs` owns SVG parsing, normalized scene representation, and runtime rendering for SVG content.
//! It defines `SvgPath`, `SvgElement`, and `SvgImage`, keeping geometry, hierarchy state, and canvas handles together.
//! Raw SVG bytes are parsed here into a tree of groups and paths, then normalized into engine-owned element maps and IDs.
//! Element transforms, visibility, color overrides, and cached subtree canvases are managed here as runtime vector state.
//! Render submission also lives here, so parsed vector data emits `RenderCommand` sequences without a separate adapter.
//! Hierarchy queries, point flattening, bounds extraction, and adjacency detection are handled here for gameplay and tools.
//! Open this file when SVG parse policy, element state semantics, canvas caching, or vector rendering must change.
//! Neighboring systems matter here mainly at the math, render, and runtime boundaries that supply transforms and commands.
//! This file is the owner boundary for vector scene behavior; higher layers should treat it as the source of SVG state.

use crate::math::Vec2;
use crate::render::mesh::{Mesh, MeshDrawMode, MeshVertex};
use crate::render::renderer::{DrawMode, PathSegment, RenderCommand};
use crate::runtime::resource_keys::{CanvasKey, MeshKey};
use crate::runtime::SharedState;
use std::collections::HashMap;
use usvg::{NodeExt, TreeParsing};

/// Cached GPU mesh handle for one SVG path draw variant.
#[derive(Clone, Debug)]
pub struct SvgCachedMesh {
    /// Mesh resource registered in `SharedState.meshes`.
    pub mesh_key: MeshKey,
    /// RGBA color baked into the mesh vertices.
    pub color: [f32; 4],
    /// Stroke width baked into the mesh geometry. Fill meshes use `0.0`.
    pub stroke_width: f32,
}

/// Cached fill and stroke meshes for a parsed SVG path.
#[derive(Clone, Debug, Default)]
pub struct SvgPathMeshCache {
    /// Fill mesh cached from path geometry and current color.
    pub fill: Option<SvgCachedMesh>,
    /// Stroke mesh cached from path geometry, stroke width, and current color.
    pub stroke: Option<SvgCachedMesh>,
}

/// Represents a single path element (or shape normalized to path) in the SVG.
#[derive(Clone, Debug)]
pub struct SvgPath {
    pub segments: Vec<PathSegment>,
    pub fill_color: Option<[f32; 4]>,
    pub stroke_color: Option<[f32; 4]>,
    pub stroke_width: f32,
    pub mesh_cache: SvgPathMeshCache,
}

/// Represents an SVG group (<g>) or path (<path>) element inside the scene graph.
#[derive(Clone, Debug)]
pub struct SvgElement {
    pub id: String,
    pub is_group: bool,
    pub parent_id: Option<String>,
    pub child_ids: Vec<String>,

    // Original local transform parsed from SVG
    pub local_transform: [f32; 9], // 3x3 column-major matrix

    // Dynamic runtime overrides (mutated via Lua)
    pub visible: bool,
    pub color_override: Option<[f32; 4]>,
    pub translation: Vec2,
    pub rotation: f32,
    pub scale: Vec2,

    // Paths contained in this element (empty if group)
    pub paths: Vec<SvgPath>,
}

/// The root resource representing a parsed SVG vector document.
pub struct SvgImage {
    pub width: f32,
    pub height: f32,
    pub root_id: String,
    pub elements: HashMap<String, SvgElement>,
    pub cached_canvases: HashMap<String, CanvasKey>,
}

impl SvgImage {
    /// Parses an SVG file from raw bytes.
    pub fn from_bytes(bytes: &[u8], label: &str) -> Result<Self, String> {
        let opt = usvg::Options::default();
        let tree = usvg::Tree::from_data(bytes, &opt)
            .map_err(|e| format!("Failed to parse SVG '{}': {}", label, e))?;
        Ok(Self::from_usvg_tree(tree, label))
    }

    /// Converts an already parsed SVG tree into the engine's mutable vector scene.
    pub fn from_usvg_tree(tree: usvg::Tree, _label: &str) -> Self {
        let width = tree.size.width();
        let height = tree.size.height();

        let mut elements = HashMap::new();

        // Helper to convert usvg::Transform to [f32; 9] column-major
        let convert_transform = |t: &usvg::Transform| -> [f32; 9] {
            [t.sx, t.kx, 0.0, t.ky, t.sy, 0.0, t.tx, t.ty, 1.0]
        };

        // Recursive walker to build SvgElement hierarchy
        fn walk_node(
            node: &usvg::Node,
            parent_id: Option<String>,
            elements: &mut HashMap<String, SvgElement>,
            convert_transform: &dyn Fn(&usvg::Transform) -> [f32; 9],
        ) -> String {
            // Generate id if absent
            let id = if node.id().is_empty() {
                format!("node_{}", elements.len())
            } else {
                node.id().to_string()
            };

            let mut is_group = false;
            let mut child_ids = Vec::new();
            let mut paths = Vec::new();
            let mut local_transform = [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0]; // identity

            match &*node.borrow() {
                usvg::NodeKind::Group(ref g) => {
                    is_group = true;
                    local_transform = convert_transform(&g.transform);
                    for child in node.children() {
                        let cid = walk_node(&child, Some(id.clone()), elements, convert_transform);
                        child_ids.push(cid);
                    }
                }
                usvg::NodeKind::Path(ref p) => {
                    local_transform = convert_transform(&p.transform);

                    let mut fill_color = None;
                    if let Some(fill) = &p.fill {
                        if let usvg::Paint::Color(c) = &fill.paint {
                            fill_color = Some([
                                c.red as f32 / 255.0,
                                c.green as f32 / 255.0,
                                c.blue as f32 / 255.0,
                                fill.opacity.get(),
                            ]);
                        }
                    }

                    let mut stroke_color = None;
                    let mut stroke_width = 1.0;
                    if let Some(stroke) = &p.stroke {
                        if let usvg::Paint::Color(c) = &stroke.paint {
                            stroke_color = Some([
                                c.red as f32 / 255.0,
                                c.green as f32 / 255.0,
                                c.blue as f32 / 255.0,
                                stroke.opacity.get(),
                            ]);
                        }
                        stroke_width = stroke.width.get();
                    }

                    // Convert usvg segments to PathSegment
                    let mut segments = Vec::new();
                    for seg in p.data.segments() {
                        match seg {
                            usvg::tiny_skia_path::PathSegment::MoveTo(pt) => {
                                segments.push(PathSegment::MoveTo { x: pt.x, y: pt.y });
                            }
                            usvg::tiny_skia_path::PathSegment::LineTo(pt) => {
                                segments.push(PathSegment::LineTo { x: pt.x, y: pt.y });
                            }
                            usvg::tiny_skia_path::PathSegment::QuadTo(pt1, pt2) => {
                                segments.push(PathSegment::QuadTo {
                                    cx: pt1.x,
                                    cy: pt1.y,
                                    x: pt2.x,
                                    y: pt2.y,
                                });
                            }
                            usvg::tiny_skia_path::PathSegment::CubicTo(pt1, pt2, pt3) => {
                                segments.push(PathSegment::CubicTo {
                                    cx1: pt1.x,
                                    cy1: pt1.y,
                                    cx2: pt2.x,
                                    cy2: pt2.y,
                                    x: pt3.x,
                                    y: pt3.y,
                                });
                            }
                            usvg::tiny_skia_path::PathSegment::Close => {
                                // Handled at DrawPath level
                            }
                        }
                    }

                    paths.push(SvgPath {
                        segments,
                        fill_color,
                        stroke_color,
                        stroke_width,
                        mesh_cache: SvgPathMeshCache::default(),
                    });
                }
                _ => {}
            }

            elements.insert(
                id.clone(),
                SvgElement {
                    id: id.clone(),
                    is_group,
                    parent_id,
                    child_ids,
                    local_transform,
                    visible: true,
                    color_override: None,
                    translation: Vec2::new(0.0, 0.0),
                    rotation: 0.0,
                    scale: Vec2::new(1.0, 1.0),
                    paths,
                },
            );

            id
        }

        let root_node = tree.root;
        let root_id = walk_node(&root_node, None, &mut elements, &convert_transform);

        Self {
            width,
            height,
            root_id,
            elements,
            cached_canvases: HashMap::new(),
        }
    }

    /// Recursively submits render commands to draw the elements.
    pub fn render(&mut self, st: &mut SharedState) {
        // Render helper that applies transformations hierarchically
        fn render_element(svg: &mut SvgImage, element_id: &str, st: &mut SharedState) {
            let Some(el) = svg.elements.get(element_id) else {
                return;
            };
            if !el.visible {
                return;
            }
            let local_transform = el.local_transform;
            let translation = el.translation;
            let rotation = el.rotation;
            let scale = el.scale;
            let color_override = el.color_override;
            let child_ids = el.child_ids.clone();
            let cached_canvas = svg.cached_canvases.get(element_id).copied();

            st.render_commands.push(RenderCommand::PushTransform);

            // Apply original SVG transform
            st.render_commands.push(RenderCommand::ApplyTransform {
                matrix: local_transform,
            });

            // Apply runtime dynamic transform
            if translation.x != 0.0 || translation.y != 0.0 {
                st.render_commands.push(RenderCommand::Translate {
                    x: translation.x,
                    y: translation.y,
                });
            }
            if rotation != 0.0 {
                st.render_commands
                    .push(RenderCommand::Rotate { angle: rotation });
            }
            if scale.x != 1.0 || scale.y != 1.0 {
                st.render_commands.push(RenderCommand::Scale {
                    sx: scale.x,
                    sy: scale.y,
                });
            }

            // If a cached canvas exists for this element/group, draw it as a single quad instead of paths!
            if let Some(canvas_key) = cached_canvas {
                st.render_commands.push(RenderCommand::DrawCanvas {
                    canvas_key,
                    x: 0.0,
                    y: 0.0,
                    rotation: 0.0,
                    sx: 1.0,
                    sy: 1.0,
                    ox: 0.0,
                    oy: 0.0,
                });
            } else {
                // Otherwise, render geometry paths
                if let Some(el) = svg.elements.get_mut(element_id) {
                    for path in &mut el.paths {
                        if path.segments.is_empty() {
                            continue;
                        }

                        // Apply fill
                        if let Some(mut fill) = path.fill_color {
                            if let Some(over) = color_override {
                                fill = over;
                            }
                            if let Some(mesh_key) = ensure_fill_mesh(path, fill, st) {
                                st.render_commands.push(RenderCommand::DrawMesh {
                                    mesh_key,
                                    x: 0.0,
                                    y: 0.0,
                                    rotation: 0.0,
                                    sx: 1.0,
                                    sy: 1.0,
                                    ox: 0.0,
                                    oy: 0.0,
                                });
                            } else {
                                st.render_commands.push(RenderCommand::SetColor(
                                    fill[0], fill[1], fill[2], fill[3],
                                ));
                                st.render_commands.push(RenderCommand::DrawPath {
                                    segments: path.segments.clone(),
                                    mode: DrawMode::Fill,
                                    close: true,
                                    fill_rule: crate::render::shape::FillRule::NonZero,
                                    stroke: crate::render::shape::StrokeStyle::default(),
                                });
                            }
                        }

                        // Apply stroke
                        if let Some(mut stroke) = path.stroke_color {
                            if let Some(over) = color_override {
                                stroke = over;
                            }
                            if let Some(mesh_key) =
                                ensure_stroke_mesh(path, stroke, path.stroke_width, st)
                            {
                                st.render_commands.push(RenderCommand::DrawMesh {
                                    mesh_key,
                                    x: 0.0,
                                    y: 0.0,
                                    rotation: 0.0,
                                    sx: 1.0,
                                    sy: 1.0,
                                    ox: 0.0,
                                    oy: 0.0,
                                });
                            } else {
                                st.render_commands
                                    .push(RenderCommand::SetLineWidth(path.stroke_width));
                                st.render_commands.push(RenderCommand::SetColor(
                                    stroke[0], stroke[1], stroke[2], stroke[3],
                                ));
                                st.render_commands.push(RenderCommand::DrawPath {
                                    segments: path.segments.clone(),
                                    mode: DrawMode::Line,
                                    close: true,
                                    fill_rule: crate::render::shape::FillRule::NonZero,
                                    stroke: crate::render::shape::StrokeStyle {
                                        width: path.stroke_width,
                                        ..crate::render::shape::StrokeStyle::default()
                                    },
                                });
                            }
                        }
                    }
                }

                // Render children
                for child_id in &child_ids {
                    render_element(svg, child_id, st);
                }
            }

            st.render_commands.push(RenderCommand::PopTransform);
        }

        let root_id = self.root_id.clone();
        render_element(self, &root_id, st);
    }

    /// Computes the accumulated transform matrix of an element.
    pub fn get_element_accumulated_transform(&self, element_id: &str) -> Option<[f32; 9]> {
        let mut curr_id = element_id.to_string();
        let mut path_to_root = Vec::new();
        while let Some(el) = self.elements.get(&curr_id) {
            path_to_root.push(el);
            if let Some(ref p_id) = el.parent_id {
                curr_id = p_id.clone();
            } else {
                break;
            }
        }
        // Now walk from root down to the element to accumulate the transforms
        let mut mat = [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0]; // identity
        for el in path_to_root.iter().rev() {
            // Apply original SVG transform
            mat = mul_matrix(&mat, &el.local_transform);
            // Apply runtime dynamic transforms (TRS)
            mat = apply_trs(&mat, el.translation, el.rotation, el.scale);
        }
        Some(mat)
    }

    /// Recursively flattens Bezier path segments of the element (and its children) into a flat list of points.
    pub fn get_element_points(
        &self,
        element_id: &str,
        step_size: Option<f32>,
    ) -> Option<Vec<Vec2>> {
        let el = self.elements.get(element_id)?;
        let step = step_size.unwrap_or(5.0);
        let mut points = Vec::new();

        // Recursive helper to gather paths from this element and its descendants
        fn gather_points(
            svg: &SvgImage,
            el_id: &str,
            parent_mat: &[f32; 9],
            step: f32,
            points: &mut Vec<Vec2>,
        ) {
            let Some(el) = svg.elements.get(el_id) else {
                return;
            };
            if !el.visible {
                return;
            }

            // Compute transform for this element
            let mat = mul_matrix(parent_mat, &el.local_transform);
            let mat = apply_trs(&mat, el.translation, el.rotation, el.scale);

            for path in &el.paths {
                let mut current_pos = Vec2::new(0.0, 0.0);
                for seg in &path.segments {
                    match seg {
                        PathSegment::MoveTo { x, y } => {
                            let p = transform_point(&mat, Vec2::new(*x, *y));
                            points.push(p);
                            current_pos = Vec2::new(*x, *y);
                        }
                        PathSegment::LineTo { x, y } => {
                            let p = transform_point(&mat, Vec2::new(*x, *y));
                            points.push(p);
                            current_pos = Vec2::new(*x, *y);
                        }
                        PathSegment::QuadTo { cx, cy, x, y } => {
                            let p0 = current_pos;
                            let pc = Vec2::new(*cx, *cy);
                            let p1 = Vec2::new(*x, *y);

                            let d1 = (pc - p0).length();
                            let d2 = (p1 - pc).length();
                            let approx_len = d1 + d2;
                            let n = ((approx_len / step).ceil() as usize).max(2);
                            for i in 1..=n {
                                let t = i as f32 / n as f32;
                                let mt = 1.0 - t;
                                let pt = p0 * (mt * mt) + pc * (2.0 * mt * t) + p1 * (t * t);
                                points.push(transform_point(&mat, pt));
                            }
                            current_pos = p1;
                        }
                        PathSegment::CubicTo {
                            cx1,
                            cy1,
                            cx2,
                            cy2,
                            x,
                            y,
                        } => {
                            let p0 = current_pos;
                            let pc1 = Vec2::new(*cx1, *cy1);
                            let pc2 = Vec2::new(*cx2, *cy2);
                            let p1 = Vec2::new(*x, *y);

                            let d1 = (pc1 - p0).length();
                            let d2 = (pc2 - pc1).length();
                            let d3 = (p1 - pc2).length();
                            let approx_len = d1 + d2 + d3;
                            let n = ((approx_len / step).ceil() as usize).max(2);
                            for i in 1..=n {
                                let t = i as f32 / n as f32;
                                let mt = 1.0 - t;
                                let pt = p0 * (mt * mt * mt)
                                    + pc1 * (3.0 * mt * mt * t)
                                    + pc2 * (3.0 * mt * t * t)
                                    + p1 * (t * t * t);
                                points.push(transform_point(&mat, pt));
                            }
                            current_pos = p1;
                        }
                    }
                }
            }

            for child_id in &el.child_ids {
                gather_points(svg, child_id, &mat, step, points);
            }
        }

        // Compute base mat for starting element
        let mut parent_mat = [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0];
        if let Some(ref p_id) = el.parent_id {
            if let Some(pm) = self.get_element_accumulated_transform(p_id) {
                parent_mat = pm;
            }
        }

        gather_points(self, element_id, &parent_mat, step, &mut points);
        Some(points)
    }

    /// Automatically detects adjacency graph between elements matching the given prefix.
    #[allow(clippy::needless_range_loop)]
    pub fn get_adjacencies(
        &self,
        prefix: &str,
        epsilon: Option<f32>,
    ) -> HashMap<String, Vec<String>> {
        let eps = epsilon.unwrap_or(2.0);
        let mut adj: HashMap<String, Vec<String>> = HashMap::new();

        // 1. Gather all elements matching prefix and their points
        let mut target_elements = Vec::new();
        for (id, el) in &self.elements {
            if id.starts_with(prefix) && el.visible {
                if let Some(pts) = self.get_element_points(id, Some(5.0)) {
                    if !pts.is_empty() {
                        // Calculate bounding box
                        let mut min_x = f32::MAX;
                        let mut max_x = f32::MIN;
                        let mut min_y = f32::MAX;
                        let mut max_y = f32::MIN;
                        for p in &pts {
                            min_x = min_x.min(p.x);
                            max_x = max_x.max(p.x);
                            min_y = min_y.min(p.y);
                            max_y = max_y.max(p.y);
                        }
                        target_elements.push((id.clone(), pts, (min_x, max_x, min_y, max_y)));
                    }
                }
            }
        }

        // 2. Perform pairwise checks
        let count = target_elements.len();
        for i in 0..count {
            let (ref id_a, ref pts_a, bbox_a) = target_elements[i];
            for j in (i + 1)..count {
                let (ref id_b, ref pts_b, bbox_b) = target_elements[j];

                // Overlap check with epsilon margin
                if bbox_a.1 + eps < bbox_b.0 - eps
                    || bbox_b.1 + eps < bbox_a.0 - eps
                    || bbox_a.3 + eps < bbox_b.2 - eps
                    || bbox_b.3 + eps < bbox_a.2 - eps
                {
                    continue;
                }

                // Point-to-point distance check
                let mut is_adjacent = false;
                'outer: for p_a in pts_a {
                    for p_b in pts_b {
                        if (*p_a - *p_b).length_squared() <= eps * eps {
                            is_adjacent = true;
                            break 'outer;
                        }
                    }
                }

                if is_adjacent {
                    adj.entry(id_a.clone()).or_default().push(id_b.clone());
                    adj.entry(id_b.clone()).or_default().push(id_a.clone());
                }
            }
        }

        adj
    }

    /// Returns whether the flattened visible element polygon contains the given document-space point.
    pub fn contains_point(&self, element_id: &str, x: f32, y: f32) -> Option<bool> {
        let el = self.elements.get(element_id)?;
        if !el.visible {
            return Some(false);
        }
        let (min_x, min_y, max_x, max_y) = self.get_element_bounds(element_id)?;
        if x < min_x || x > max_x || y < min_y || y > max_y {
            return Some(false);
        }
        let points = self.get_element_points(element_id, Some(4.0))?;
        Some(point_in_polygon(Vec2::new(x, y), &points))
    }

    /// Returns the first visible element matching `prefix` whose polygon contains the point.
    pub fn get_element_at_point(&self, prefix: &str, x: f32, y: f32) -> Option<String> {
        let mut ids: Vec<&str> = self
            .elements
            .keys()
            .filter_map(|id| id.starts_with(prefix).then_some(id.as_str()))
            .collect();
        ids.sort_unstable();
        ids.into_iter()
            .find(|id| self.contains_point(id, x, y) == Some(true))
            .map(str::to_string)
    }

    /// Renders the target element/group to a GPU off-screen texture (Canvas) and caches its key.
    pub fn cache_to_canvas(
        &mut self,
        element_id: &str,
        w: u32,
        h: u32,
        st: &mut SharedState,
    ) -> Result<CanvasKey, String> {
        if !self.elements.contains_key(element_id) {
            return Err(format!("Element '{}' not found", element_id));
        }

        let canvas_key = st.canvases.insert(crate::render::Canvas::new(w, h));

        st.render_commands.push(RenderCommand::RegisterCanvas {
            canvas_key,
            width: w,
            height: h,
        });

        st.render_commands
            .push(RenderCommand::ResetCanvas(canvas_key));
        st.render_commands
            .push(RenderCommand::SetCanvas(Some(canvas_key)));

        fn draw_element_paths_only(svg: &SvgImage, el_id: &str, st: &mut SharedState) {
            let Some(el) = svg.elements.get(el_id) else {
                return;
            };
            if !el.visible {
                return;
            }

            st.render_commands.push(RenderCommand::PushTransform);
            st.render_commands.push(RenderCommand::ApplyTransform {
                matrix: el.local_transform,
            });

            if el.translation.x != 0.0 || el.translation.y != 0.0 {
                st.render_commands.push(RenderCommand::Translate {
                    x: el.translation.x,
                    y: el.translation.y,
                });
            }
            if el.rotation != 0.0 {
                st.render_commands
                    .push(RenderCommand::Rotate { angle: el.rotation });
            }
            if el.scale.x != 1.0 || el.scale.y != 1.0 {
                st.render_commands.push(RenderCommand::Scale {
                    sx: el.scale.x,
                    sy: el.scale.y,
                });
            }

            for path in &el.paths {
                if path.segments.is_empty() {
                    continue;
                }

                if let Some(mut fill) = path.fill_color {
                    if let Some(over) = el.color_override {
                        fill = over;
                    }
                    st.render_commands
                        .push(RenderCommand::SetColor(fill[0], fill[1], fill[2], fill[3]));
                    st.render_commands.push(RenderCommand::DrawPath {
                        segments: path.segments.clone(),
                        mode: DrawMode::Fill,
                        close: true,
                        fill_rule: crate::render::shape::FillRule::NonZero,
                        stroke: crate::render::shape::StrokeStyle::default(),
                    });
                }

                if let Some(mut stroke) = path.stroke_color {
                    if let Some(over) = el.color_override {
                        stroke = over;
                    }
                    st.render_commands
                        .push(RenderCommand::SetLineWidth(path.stroke_width));
                    st.render_commands.push(RenderCommand::SetColor(
                        stroke[0], stroke[1], stroke[2], stroke[3],
                    ));
                    st.render_commands.push(RenderCommand::DrawPath {
                        segments: path.segments.clone(),
                        mode: DrawMode::Line,
                        close: true,
                        fill_rule: crate::render::shape::FillRule::NonZero,
                        stroke: crate::render::shape::StrokeStyle {
                            width: path.stroke_width,
                            ..crate::render::shape::StrokeStyle::default()
                        },
                    });
                }
            }

            for child_id in &el.child_ids {
                draw_element_paths_only(svg, child_id, st);
            }

            st.render_commands.push(RenderCommand::PopTransform);
        }

        draw_element_paths_only(self, element_id, st);

        st.render_commands
            .push(RenderCommand::SetCanvas(st.active_canvas));

        self.cached_canvases
            .insert(element_id.to_string(), canvas_key);

        Ok(canvas_key)
    }

    /// Returns the document width and height as a tuple.
    pub fn get_dimensions(&self) -> (f32, f32) {
        (self.width, self.height)
    }

    /// Returns the total number of parsed elements (paths and groups) in this document.
    pub fn get_element_count(&self) -> usize {
        self.elements.len()
    }

    /// Returns the axis-aligned bounding box of a visible element as `(min_x, min_y, max_x, max_y)`.
    ///
    /// Flattens all descendant paths through `get_element_points` and wraps their point set
    /// in a tight AABB. Returns `None` when the element is not found or has no geometry.
    pub fn get_element_bounds(&self, element_id: &str) -> Option<(f32, f32, f32, f32)> {
        let pts = self.get_element_points(element_id, Some(5.0))?;
        if pts.is_empty() {
            return None;
        }
        let mut min_x = f32::MAX;
        let mut min_y = f32::MAX;
        let mut max_x = f32::MIN;
        let mut max_y = f32::MIN;
        for p in &pts {
            if p.x < min_x {
                min_x = p.x;
            }
            if p.y < min_y {
                min_y = p.y;
            }
            if p.x > max_x {
                max_x = p.x;
            }
            if p.y > max_y {
                max_y = p.y;
            }
        }
        Some((min_x, min_y, max_x, max_y))
    }

    /// Returns the current color override `[r, g, b, a]` for the element, or `None` if no override is set.
    pub fn get_element_color(&self, element_id: &str) -> Option<[f32; 4]> {
        self.elements.get(element_id)?.color_override
    }

    /// Returns the current visibility flag for the element, or `None` when the element is not found.
    pub fn get_element_visible(&self, element_id: &str) -> Option<bool> {
        Some(self.elements.get(element_id)?.visible)
    }

    /// Returns the current dynamic TRS state of the element as `(tx, ty, rotation, sx, sy)`.
    ///
    /// Values reflect any overrides applied via `set_element_transform`; they do not include
    /// the original SVG-embedded local transform.
    pub fn get_element_transform(&self, element_id: &str) -> Option<(f32, f32, f32, f32, f32)> {
        let el = self.elements.get(element_id)?;
        Some((
            el.translation.x,
            el.translation.y,
            el.rotation,
            el.scale.x,
            el.scale.y,
        ))
    }

    /// Resets the runtime translation, rotation, and scale of the element to identity.
    ///
    /// The original SVG-embedded local transform is not affected.
    /// Returns `Err` when the element ID is not found.
    pub fn reset_element_transform(&mut self, element_id: &str) -> Result<(), String> {
        let el = self
            .elements
            .get_mut(element_id)
            .ok_or_else(|| format!("Element '{}' not found", element_id))?;
        el.translation = Vec2::new(0.0, 0.0);
        el.rotation = 0.0;
        el.scale = Vec2::new(1.0, 1.0);
        Ok(())
    }

    /// Clears any color override set on the element, restoring original SVG path colors.
    ///
    /// Returns `Err` when the element ID is not found.
    pub fn reset_element_color(&mut self, element_id: &str) -> Result<(), String> {
        let el = self
            .elements
            .get_mut(element_id)
            .ok_or_else(|| format!("Element '{}' not found", element_id))?;
        el.color_override = None;
        Ok(())
    }

    /// Returns the parent element ID for the given element, or `None` when it is the root.
    ///
    /// Returns `None` also when the element ID is not found.
    pub fn get_element_parent(&self, element_id: &str) -> Option<String> {
        self.elements.get(element_id)?.parent_id.clone()
    }

    /// Returns the list of direct child element IDs for the given group element.
    ///
    /// Returns `None` when the element ID is not found. Returns an empty `Vec` for leaf elements.
    pub fn get_element_children(&self, element_id: &str) -> Option<Vec<String>> {
        Some(self.elements.get(element_id)?.child_ids.clone())
    }
}

// ----------------------------------------------------
// Matrix helper functions
// ----------------------------------------------------

fn ensure_fill_mesh(path: &mut SvgPath, color: [f32; 4], st: &mut SharedState) -> Option<MeshKey> {
    let segments = path.segments.clone();
    ensure_cached_mesh(&mut path.mesh_cache.fill, color, 0.0, st, || {
        build_fill_mesh(&segments, color)
    })
}

fn ensure_stroke_mesh(
    path: &mut SvgPath,
    color: [f32; 4],
    stroke_width: f32,
    st: &mut SharedState,
) -> Option<MeshKey> {
    let segments = path.segments.clone();
    ensure_cached_mesh(&mut path.mesh_cache.stroke, color, stroke_width, st, || {
        build_stroke_mesh(&segments, color, stroke_width)
    })
}

fn ensure_cached_mesh(
    cache: &mut Option<SvgCachedMesh>,
    color: [f32; 4],
    stroke_width: f32,
    st: &mut SharedState,
    build: impl FnOnce() -> Option<Mesh>,
) -> Option<MeshKey> {
    if let Some(cached) = cache {
        if cached.color == color
            && (cached.stroke_width - stroke_width).abs() <= f32::EPSILON
            && st.meshes.contains_key(cached.mesh_key)
        {
            return Some(cached.mesh_key);
        }
    }

    let mesh = build()?;
    if mesh.validate().is_err() {
        return None;
    }
    let mesh_key = if let Some(cached) = cache {
        if st.meshes.contains_key(cached.mesh_key) {
            if let Some(slot) = st.meshes.get_mut(cached.mesh_key) {
                *slot = mesh.clone();
            }
            cached.mesh_key
        } else {
            st.meshes.insert(mesh.clone())
        }
    } else {
        st.meshes.insert(mesh.clone())
    };
    st.render_commands
        .push(RenderCommand::SyncMesh { mesh_key, mesh });
    *cache = Some(SvgCachedMesh {
        mesh_key,
        color,
        stroke_width,
    });
    Some(mesh_key)
}

fn build_fill_mesh(segments: &[PathSegment], color: [f32; 4]) -> Option<Mesh> {
    let subpaths = flatten_subpaths(segments, 8);
    let mut vertices = Vec::new();
    for points in subpaths {
        if points.len() < 3 {
            continue;
        }
        let first = points[0];
        for idx in 1..points.len().saturating_sub(1) {
            push_mesh_vertex(&mut vertices, first, color);
            push_mesh_vertex(&mut vertices, points[idx], color);
            push_mesh_vertex(&mut vertices, points[idx + 1], color);
        }
    }
    (!vertices.is_empty()).then(|| Mesh::from_vertices(vertices, MeshDrawMode::Triangles))
}

fn build_stroke_mesh(segments: &[PathSegment], color: [f32; 4], stroke_width: f32) -> Option<Mesh> {
    let subpaths = flatten_subpaths(segments, 8);
    let mut vertices = Vec::new();
    let width = stroke_width.max(0.1);
    for points in subpaths {
        for pair in points.windows(2) {
            push_stroke_segment(&mut vertices, pair[0], pair[1], width, color);
        }
        if points.len() > 2 {
            push_stroke_segment(&mut vertices, *points.last()?, points[0], width, color);
        }
    }
    (!vertices.is_empty()).then(|| Mesh::from_vertices(vertices, MeshDrawMode::Triangles))
}

fn push_mesh_vertex(vertices: &mut Vec<MeshVertex>, point: Vec2, color: [f32; 4]) {
    vertices.push(MeshVertex {
        x: point.x,
        y: point.y,
        u: 0.0,
        v: 0.0,
        r: color[0],
        g: color[1],
        b: color[2],
        a: color[3],
    });
}

fn push_stroke_segment(
    vertices: &mut Vec<MeshVertex>,
    a: Vec2,
    b: Vec2,
    width: f32,
    color: [f32; 4],
) {
    let dx = b.x - a.x;
    let dy = b.y - a.y;
    let len = (dx * dx + dy * dy).sqrt();
    if len <= f32::EPSILON {
        return;
    }
    let half = width * 0.5;
    let nx = -dy / len * half;
    let ny = dx / len * half;
    let p0 = Vec2::new(a.x + nx, a.y + ny);
    let p1 = Vec2::new(b.x + nx, b.y + ny);
    let p2 = Vec2::new(b.x - nx, b.y - ny);
    let p3 = Vec2::new(a.x - nx, a.y - ny);
    push_mesh_vertex(vertices, p0, color);
    push_mesh_vertex(vertices, p1, color);
    push_mesh_vertex(vertices, p2, color);
    push_mesh_vertex(vertices, p0, color);
    push_mesh_vertex(vertices, p2, color);
    push_mesh_vertex(vertices, p3, color);
}

fn flatten_subpaths(segments: &[PathSegment], curve_steps: usize) -> Vec<Vec<Vec2>> {
    let mut subpaths = Vec::new();
    let mut current = Vec::new();
    let mut pen = Vec2::new(0.0, 0.0);
    for seg in segments {
        match *seg {
            PathSegment::MoveTo { x, y } => {
                if !current.is_empty() {
                    subpaths.push(current);
                    current = Vec::new();
                }
                pen = Vec2::new(x, y);
                current.push(pen);
            }
            PathSegment::LineTo { x, y } => {
                pen = Vec2::new(x, y);
                current.push(pen);
            }
            PathSegment::QuadTo { cx, cy, x, y } => {
                let start = pen;
                let control = Vec2::new(cx, cy);
                let end = Vec2::new(x, y);
                for idx in 1..=curve_steps {
                    let t = idx as f32 / curve_steps as f32;
                    let mt = 1.0 - t;
                    current.push(start * (mt * mt) + control * (2.0 * mt * t) + end * (t * t));
                }
                pen = end;
            }
            PathSegment::CubicTo {
                cx1,
                cy1,
                cx2,
                cy2,
                x,
                y,
            } => {
                let start = pen;
                let c1 = Vec2::new(cx1, cy1);
                let c2 = Vec2::new(cx2, cy2);
                let end = Vec2::new(x, y);
                for idx in 1..=curve_steps {
                    let t = idx as f32 / curve_steps as f32;
                    let mt = 1.0 - t;
                    current.push(
                        start * (mt * mt * mt)
                            + c1 * (3.0 * mt * mt * t)
                            + c2 * (3.0 * mt * t * t)
                            + end * (t * t * t),
                    );
                }
                pen = end;
            }
        }
    }
    if !current.is_empty() {
        subpaths.push(current);
    }
    subpaths
}

fn point_in_polygon(point: Vec2, polygon: &[Vec2]) -> bool {
    if polygon.len() < 3 {
        return false;
    }
    let mut inside = false;
    let mut j = polygon.len() - 1;
    for i in 0..polygon.len() {
        let pi = polygon[i];
        let pj = polygon[j];
        let crosses = (pi.y > point.y) != (pj.y > point.y);
        if crosses {
            let x_intersection = (pj.x - pi.x) * (point.y - pi.y) / (pj.y - pi.y) + pi.x;
            if point.x < x_intersection {
                inside = !inside;
            }
        }
        j = i;
    }
    inside
}

fn mul_matrix(a: &[f32; 9], b: &[f32; 9]) -> [f32; 9] {
    [
        a[0] * b[0] + a[3] * b[1] + a[6] * b[2],
        a[1] * b[0] + a[4] * b[1] + a[7] * b[2],
        a[2] * b[0] + a[5] * b[1] + a[8] * b[2],
        a[0] * b[3] + a[3] * b[4] + a[6] * b[5],
        a[1] * b[3] + a[4] * b[4] + a[7] * b[5],
        a[2] * b[3] + a[5] * b[4] + a[8] * b[5],
        a[0] * b[6] + a[3] * b[7] + a[6] * b[8],
        a[1] * b[6] + a[4] * b[7] + a[7] * b[8],
        a[2] * b[6] + a[5] * b[7] + a[8] * b[8],
    ]
}

fn apply_trs(m: &[f32; 9], t: Vec2, r: f32, s: Vec2) -> [f32; 9] {
    let cos = r.cos();
    let sin = r.sin();
    let trs = [
        cos * s.x,
        sin * s.x,
        0.0,
        -sin * s.y,
        cos * s.y,
        0.0,
        t.x,
        t.y,
        1.0,
    ];
    mul_matrix(m, &trs)
}

fn transform_point(m: &[f32; 9], p: Vec2) -> Vec2 {
    let nx = p.x * m[0] + p.y * m[3] + m[6];
    let ny = p.x * m[1] + p.y * m[4] + m[7];
    Vec2::new(nx, ny)
}
