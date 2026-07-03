//! Owns the physics shape implementation for the physics subsystem and keeps related runtime rules local here.
//! Keeps body state, simulation helpers, and authored world contracts so helpers stay close to invariants this updates.
//! Defines how physics shape data is validated, transformed, or stored before neighboring systems consume it.
//! Separates physics shape behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where physics code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing physics shape defaults, lifecycle handling, validation, or data ownership rules.
//! Keeps failure paths and edge cases near the physics shape state that explains them instead of spreading rules outward.
//! Preserves deterministic behavior by keeping physics shape calculations explicit at their owning subsystem boundary.

use crate::image::ImageData;
use crate::math::Vec2;
use rapier2d::prelude::*;

use super::error::PhysicsError;
use super::limits::{validate_finite, validate_positive, validate_range, PhysicsLimits};

/// Options for deriving a collision shape from an image alpha mask.
#[derive(Debug, Clone, Copy)]
pub struct AlphaShapeOptions {
    /// Alpha channel threshold. Pixels with alpha >= threshold are considered solid.
    pub alpha_threshold: u8,
    /// Maximum polygon support vertices to emit when the mask is not circle-like or rectangular.
    pub max_vertices: usize,
    /// Maximum width/height aspect delta accepted when classifying a mask as a circle.
    pub circle_aspect_tolerance: f32,
    /// Maximum fill-ratio error from a filled circle accepted when classifying as a circle.
    pub circle_fill_tolerance: f32,
    /// Fill ratio above which the mask is treated as a rectangle.
    pub rectangle_fill_threshold: f32,
}
impl Default for AlphaShapeOptions {
    fn default() -> Self {
        Self {
            alpha_threshold: 8,
            max_vertices: 8,
            circle_aspect_tolerance: 0.2,
            circle_fill_tolerance: 0.18,
            rectangle_fill_threshold: 0.92,
        }
    }
}

/// Physics primitive shape used in `Body` and `StandaloneShape`.
/// # Variants
/// - `Rect`: axis-aligned box with width and height.
/// - `Circle`: circle with a radius.
/// - `Polygon`: convex polygon vertex list.
/// - `Edge`: single line segment.
/// - `Chain`: open or closed polyline.
#[derive(Debug, Clone, PartialEq)]
pub enum Shape {
    /// Axis-aligned box.
    Rect { width: f32, height: f32 },
    /// Circle.
    Circle { radius: f32 },
    /// Convex polygon (3-8 vertices).
    Polygon { vertices: Vec<Vec2> },
    /// Single line segment.
    Edge { v1: Vec2, v2: Vec2 },
    /// Open or closed polyline.
    Chain { vertices: Vec<Vec2>, closed: bool },
}
/// Conversion helpers for `Shape`.
impl Shape {
    fn bounds_from_vertices(vertices: &[Vec2]) -> (f32, f32, f32, f32) {
        let mut min_x = f32::INFINITY;
        let mut min_y = f32::INFINITY;
        let mut max_x = f32::NEG_INFINITY;
        let mut max_y = f32::NEG_INFINITY;
        for v in vertices {
            min_x = min_x.min(v.x);
            min_y = min_y.min(v.y);
            max_x = max_x.max(v.x);
            max_y = max_y.max(v.y);
        }
        (min_x, min_y, max_x, max_y)
    }

    fn local_rect_vertices(width: f32, height: f32) -> Vec<Vec2> {
        let hw = width / 2.0;
        let hh = height / 2.0;
        vec![
            Vec2::new(-hw, -hh),
            Vec2::new(hw, -hh),
            Vec2::new(hw, hh),
            Vec2::new(-hw, hh),
        ]
    }

    fn polygon_area2(vertices: &[Vec2]) -> f32 {
        let mut area = 0.0;
        for i in 0..vertices.len() {
            let a = vertices[i];
            let b = vertices[(i + 1) % vertices.len()];
            area += a.x * b.y - b.x * a.y;
        }
        area
    }

    fn is_convex_polygon(vertices: &[Vec2]) -> bool {
        if vertices.len() < 3 {
            return false;
        }
        let mut sign = 0.0f32;
        for i in 0..vertices.len() {
            let a = vertices[i];
            let b = vertices[(i + 1) % vertices.len()];
            let c = vertices[(i + 2) % vertices.len()];
            let abx = b.x - a.x;
            let aby = b.y - a.y;
            let bcx = c.x - b.x;
            let bcy = c.y - b.y;
            let cross = abx * bcy - aby * bcx;
            if cross.abs() <= 1e-5 {
                continue;
            }
            if sign == 0.0 {
                sign = cross.signum();
                continue;
            }
            if sign * cross < 0.0 {
                return false;
            }
        }
        sign != 0.0
    }

    fn validate_vertices(
        context: &'static str,
        vertices: &[Vec2],
        min: usize,
        max: usize,
    ) -> Result<(), PhysicsError> {
        if vertices.len() < min || vertices.len() > max {
            return Err(PhysicsError::InvalidVertexCount {
                context,
                count: vertices.len(),
                min,
                max,
            });
        }
        for vertex in vertices {
            validate_finite("vertex.x", f64::from(vertex.x))?;
            validate_finite("vertex.y", f64::from(vertex.y))?;
        }
        Ok(())
    }

    fn alpha_bounds(image: &ImageData, threshold: u8) -> Option<(u32, u32, u32, u32, usize)> {
        let mut min_x = u32::MAX;
        let mut min_y = u32::MAX;
        let mut max_x = 0;
        let mut max_y = 0;
        let mut count = 0usize;

        for y in 0..image.height() {
            for x in 0..image.width() {
                if image
                    .get_pixel(x, y)
                    .is_some_and(|(_, _, _, a)| a >= threshold)
                {
                    min_x = min_x.min(x);
                    min_y = min_y.min(y);
                    max_x = max_x.max(x);
                    max_y = max_y.max(y);
                    count += 1;
                }
            }
        }

        (count > 0).then_some((min_x, min_y, max_x, max_y, count))
    }

    fn alpha_support_polygon(
        image: &ImageData,
        threshold: u8,
        min_x: u32,
        min_y: u32,
        max_x: u32,
        max_y: u32,
        max_vertices: usize,
    ) -> Vec<Vec2> {
        let vertex_count = max_vertices.clamp(3, PhysicsLimits::default().max_polygon_vertices);
        let cx = (min_x as f32 + max_x as f32 + 1.0) * 0.5;
        let cy = (min_y as f32 + max_y as f32 + 1.0) * 0.5;
        let mut vertices = Vec::with_capacity(vertex_count);

        for i in 0..vertex_count {
            let angle = 2.0 * std::f32::consts::PI * (i as f32) / (vertex_count as f32);
            let dir_x = angle.cos();
            let dir_y = angle.sin();
            let mut best_dot = f32::NEG_INFINITY;
            let mut best = Vec2::new(0.0, 0.0);
            for y in min_y..=max_y {
                for x in min_x..=max_x {
                    if image
                        .get_pixel(x, y)
                        .is_some_and(|(_, _, _, a)| a >= threshold)
                    {
                        let px = x as f32 + 0.5 - cx;
                        let py = y as f32 + 0.5 - cy;
                        let dot = px * dir_x + py * dir_y;
                        if dot > best_dot {
                            best_dot = dot;
                            best = Vec2::new(px, py);
                        }
                    }
                }
            }
            if vertices.last().is_none_or(|prev: &Vec2| {
                (prev.x - best.x).abs() > 0.25 || (prev.y - best.y).abs() > 0.25
            }) {
                vertices.push(best);
            }
        }

        if vertices.len() > 1 {
            let first = vertices[0];
            let last = *vertices.last().unwrap();
            if (first.x - last.x).abs() <= 0.25 && (first.y - last.y).abs() <= 0.25 {
                vertices.pop();
            }
        }
        vertices
    }

    /// Approximate the alpha mask of an image as a simple physics shape.
    pub fn from_image_alpha(image: &ImageData, options: AlphaShapeOptions) -> Result<Self, String> {
        let (min_x, min_y, max_x, max_y, solid_pixels) =
            Self::alpha_bounds(image, options.alpha_threshold)
                .ok_or_else(|| "image alpha mask has no solid pixels".to_string())?;

        let width = (max_x - min_x + 1) as f32;
        let height = (max_y - min_y + 1) as f32;
        let area = width * height;
        if area <= 0.0 {
            return Err("image alpha mask has degenerate bounds".into());
        }

        let fill_ratio = solid_pixels as f32 / area;
        if fill_ratio >= options.rectangle_fill_threshold {
            return Ok(Self::Rect { width, height });
        }

        let aspect_delta = (width - height).abs() / width.max(height);
        let circle_fill = std::f32::consts::PI / 4.0;
        if aspect_delta <= options.circle_aspect_tolerance
            && (fill_ratio - circle_fill).abs() <= options.circle_fill_tolerance
        {
            return Ok(Self::Circle {
                radius: (width + height) * 0.25,
            });
        }

        let mut vertices = Self::alpha_support_polygon(
            image,
            options.alpha_threshold,
            min_x,
            min_y,
            max_x,
            max_y,
            options.max_vertices,
        );

        if vertices.len() < 3 || !Self::is_convex_polygon(&vertices) {
            vertices = Self::local_rect_vertices(width, height);
        }

        let shape = Self::Polygon { vertices };
        shape
            .validate(&PhysicsLimits::default())
            .map_err(|err| err.to_string())?;
        Ok(shape)
    }

    /// Return the shape vertices in local space when a finite vertex representation exists.
    pub fn vertices(&self) -> Option<Vec<Vec2>> {
        match self {
            Shape::Rect { width, height } => Some(Self::local_rect_vertices(*width, *height)),
            Shape::Polygon { vertices } | Shape::Chain { vertices, .. } => Some(vertices.clone()),
            Shape::Edge { v1, v2 } => Some(vec![*v1, *v2]),
            Shape::Circle { .. } => None,
        }
    }

    /// Return the local-space area used for density-to-mass approximations.
    pub fn area_estimate(&self) -> f32 {
        match self {
            Shape::Rect { width, height } => width * height,
            Shape::Circle { radius } => std::f32::consts::PI * radius * radius,
            Shape::Polygon { vertices } => Self::polygon_area2(vertices).abs() * 0.5,
            Shape::Chain { vertices, .. } => {
                let (min_x, min_y, max_x, max_y) = Self::bounds_from_vertices(vertices);
                ((max_x - min_x) * (max_y - min_y)).max(1.0)
            }
            Shape::Edge { v1, v2 } => ((v2.x - v1.x).hypot(v2.y - v1.y)).max(1.0),
        }
    }

    /// Validate this shape against the shared physics safety contract.
    pub fn validate(&self, limits: &PhysicsLimits) -> Result<(), PhysicsError> {
        match self {
            Shape::Rect { width, height } => {
                validate_positive("width", f64::from(*width))?;
                validate_positive("height", f64::from(*height))?;
            }
            Shape::Circle { radius } => {
                validate_positive("radius", f64::from(*radius))?;
            }
            Shape::Polygon { vertices } => {
                Self::validate_vertices(
                    "physics polygon",
                    vertices,
                    3,
                    limits.max_polygon_vertices,
                )?;
                if !Self::is_convex_polygon(vertices) {
                    return Err(PhysicsError::DegenerateGeometry {
                        context: "physics polygon",
                        detail: "polygon must be convex",
                    });
                }
                if Self::polygon_area2(vertices).abs() <= 1e-4 {
                    return Err(PhysicsError::DegenerateGeometry {
                        context: "physics polygon",
                        detail: "polygon area must be non-zero",
                    });
                }
            }
            Shape::Edge { v1, v2 } => {
                validate_finite("edge.v1.x", f64::from(v1.x))?;
                validate_finite("edge.v1.y", f64::from(v1.y))?;
                validate_finite("edge.v2.x", f64::from(v2.x))?;
                validate_finite("edge.v2.y", f64::from(v2.y))?;
                let dx = v2.x - v1.x;
                let dy = v2.y - v1.y;
                if dx * dx + dy * dy <= 1e-6 {
                    return Err(PhysicsError::DegenerateGeometry {
                        context: "physics edge",
                        detail: "edge length must be > epsilon",
                    });
                }
            }
            Shape::Chain { vertices, closed } => {
                let min = if *closed { 3 } else { 2 };
                Self::validate_vertices("physics chain", vertices, min, limits.max_chain_vertices)?;
                for pair in vertices.windows(2) {
                    let dx = pair[1].x - pair[0].x;
                    let dy = pair[1].y - pair[0].y;
                    if dx * dx + dy * dy <= 1e-6 {
                        return Err(PhysicsError::DegenerateGeometry {
                            context: "physics chain",
                            detail: "adjacent chain vertices must be separated",
                        });
                    }
                }
            }
        }
        Ok(())
    }

    /// Convert this shape to a rapier `ColliderBuilder`; return `None` for invalid inputs.
    pub(crate) fn to_rapier_collider(&self) -> Option<ColliderBuilder> {
        self.validate(&PhysicsLimits::default()).ok()?;
        match self {
            Shape::Rect { width, height } => {
                Some(ColliderBuilder::cuboid(*width / 2.0, *height / 2.0))
            }
            Shape::Circle { radius } => Some(ColliderBuilder::ball(*radius)),
            Shape::Polygon { vertices } => {
                let points: Vec<Vector> = vertices.iter().map(|v| Vector::new(v.x, v.y)).collect();
                ColliderBuilder::convex_hull(&points)
            }
            Shape::Edge { v1, v2 } => Some(ColliderBuilder::segment(
                Vector::new(v1.x, v1.y),
                Vector::new(v2.x, v2.y),
            )),
            Shape::Chain { vertices, closed } => {
                let mut points: Vec<Vector> =
                    vertices.iter().map(|v| Vector::new(v.x, v.y)).collect();
                if *closed {
                    points.push(points[0]);
                }
                Some(ColliderBuilder::polyline(points, None))
            }
        }
    }

    /// Parse a shape from a string type tag and flat argument list; `closed` applies to chains.
    pub fn from_parts(shape_type: &str, args: &[f32], closed: bool) -> Result<Self, String> {
        let limits = PhysicsLimits::default();
        let shape = match shape_type {
            "rectangle" => {
                if args.len() != 2 {
                    return Err("rectangle requires exactly w, h".into());
                }
                Shape::Rect {
                    width: args[0],
                    height: args[1],
                }
            }
            "circle" => {
                if args.len() != 1 {
                    return Err("circle requires exactly radius".into());
                }
                Shape::Circle { radius: args[0] }
            }
            "polygon" => {
                if args.len() < 6 {
                    return Err("polygon requires at least 3 vertex pairs".into());
                }
                if !args.len().is_multiple_of(2) {
                    return Err(PhysicsError::OddCoordinateCount {
                        context: "physics polygon",
                        count: args.len(),
                    }
                    .to_string());
                }
                let vertices = args
                    .chunks(2)
                    .map(|pair| Vec2::new(pair[0], pair[1]))
                    .collect();
                Shape::Polygon { vertices }
            }
            "edge" => {
                if args.len() != 4 {
                    return Err("edge requires exactly x1, y1, x2, y2".into());
                }
                Shape::Edge {
                    v1: Vec2::new(args[0], args[1]),
                    v2: Vec2::new(args[2], args[3]),
                }
            }
            "chain" => {
                if args.len() < 4 {
                    return Err("chain requires at least 2 vertex pairs".into());
                }
                if !args.len().is_multiple_of(2) {
                    return Err(PhysicsError::OddCoordinateCount {
                        context: "physics chain",
                        count: args.len(),
                    }
                    .to_string());
                }
                let vertices = args
                    .chunks(2)
                    .map(|pair| Vec2::new(pair[0], pair[1]))
                    .collect();
                Shape::Chain { vertices, closed }
            }
            _ => {
                return Err(format!(
                    "invalid shape type '{}': expected rectangle, circle, polygon, edge, or chain",
                    shape_type
                ))
            }
        };
        shape.validate(&limits).map_err(|err| err.to_string())?;
        Ok(shape)
    }

    /// Create a regular convex polygon with `sides` (clamped 3-8) inscribed in `radius`.
    pub fn regular_polygon(radius: f32, sides: u32) -> Self {
        let limits = PhysicsLimits::default();
        let clamped_radius = if radius.is_finite() {
            radius.abs().max(0.5)
        } else {
            0.5
        };
        let sides = sides.clamp(3, limits.max_polygon_vertices as u32);
        let mut vertices = Vec::with_capacity(sides as usize);
        for i in 0..sides {
            let angle = 2.0 * std::f32::consts::PI * (i as f32) / (sides as f32);
            vertices.push(Vec2::new(
                clamped_radius * angle.cos(),
                clamped_radius * angle.sin(),
            ));
        }
        Shape::Polygon { vertices }
    }
}
/// A `Shape` combined with material properties for standalone collision testing.
/// # Fields
/// - `shape`: underlying geometry.
/// - `density`: mass per area unit.
/// - `friction`: friction coefficient.
/// - `restitution`: bounce coefficient.
/// - `sensor`: whether overlap-only sensor behavior is enabled.
#[derive(Debug, Clone)]
pub struct StandaloneShape {
    /// Underlying geometry.
    pub shape: Shape,
    /// Mass per area unit.
    pub density: f32,
    /// Friction coefficient 0.0..=1.0.
    pub friction: f32,
    /// Restitution coefficient 0.0..=1.0.
    pub restitution: f32,
    /// When true, this shape detects overlaps without generating forces.
    pub sensor: bool,
}
/// Accessors for `StandaloneShape`.
impl StandaloneShape {
    /// Create a standalone shape with default material values.
    pub fn new(shape: Shape) -> Self {
        Self {
            shape,
            density: 1.0,
            friction: 0.5,
            restitution: 0.0,
            sensor: false,
        }
    }

    /// Validate the standalone shape and its material values.
    pub fn validate(&self, limits: &PhysicsLimits) -> Result<(), PhysicsError> {
        self.shape.validate(limits)?;
        validate_positive("density", f64::from(self.density))?;
        validate_range("friction", f64::from(self.friction), 0.0, 1.0)?;
        validate_range("restitution", f64::from(self.restitution), 0.0, 1.0)?;
        Ok(())
    }

    /// Return a static string label for the shape type.
    pub fn get_type(&self) -> &str {
        match &self.shape {
            Shape::Circle { .. } => "circle",
            Shape::Rect { .. } => "rectangle",
            Shape::Polygon { .. } => "polygon",
            Shape::Edge { .. } => "edge",
            Shape::Chain { .. } => "chain",
        }
    }

    /// Return the circle radius when the inner shape is a `Circle`; otherwise `None`.
    pub fn get_radius(&self) -> Option<f32> {
        if let Shape::Circle { radius } = &self.shape {
            Some(*radius)
        } else {
            None
        }
    }

    /// Return the local-space AABB as `(min_x, min_y, max_x, max_y)`.
    pub fn get_bounding_box(&self) -> (f32, f32, f32, f32) {
        match &self.shape {
            Shape::Circle { radius } => (-radius, -radius, *radius, *radius),
            Shape::Rect { width, height } => {
                let hw = width / 2.0;
                let hh = height / 2.0;
                (-hw, -hh, hw, hh)
            }
            Shape::Polygon { vertices } | Shape::Chain { vertices, .. } => {
                let mut min_x = f32::INFINITY;
                let mut min_y = f32::INFINITY;
                let mut max_x = f32::NEG_INFINITY;
                let mut max_y = f32::NEG_INFINITY;
                for v in vertices {
                    min_x = min_x.min(v.x);
                    min_y = min_y.min(v.y);
                    max_x = max_x.max(v.x);
                    max_y = max_y.max(v.y);
                }
                (min_x, min_y, max_x, max_y)
            }
            Shape::Edge { v1, v2 } => (
                v1.x.min(v2.x),
                v1.y.min(v2.y),
                v1.x.max(v2.x),
                v1.y.max(v2.y),
            ),
        }
    }
}
