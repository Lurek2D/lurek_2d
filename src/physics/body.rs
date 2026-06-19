//! This file owns `BodyType`, `BodyShape`, and `Body`, the authored body descriptor used before and during world use.
//! It stores simulation role, primitive shape, material settings, filters, pose, velocity, and optional extended geometry.
//! Constructors cover rectangles, circles, polygons, edges, and chains so tools and gameplay code share one body surface.
//! Geometry helpers expose bounding boxes plus local or world point conversion without requiring a live solver context.
//! This file is the boundary between authored rigid-body intent and the runtime world that simulates those bodies.
//! Open it when body payloads or authoring semantics change; stepping, queries, and zones live in sibling owners.

use crate::log_msg;
use crate::math::{Rect, Vec2};
use crate::physics::shape::Shape;
use crate::runtime::log_messages::{BD01, BD02, BD03};

use super::error::PhysicsError;
use super::limits::{validate_finite, validate_positive, validate_range, PhysicsLimits};

/// Simulation role of a physics body.
/// # Variants
/// - `Static`: no movement; collides with dynamic bodies.
/// - `Dynamic`: mass-based simulation; affected by forces and gravity.
/// - `Kinematic`: velocity-driven; not affected by forces.
/// - `Sensor`: non-colliding overlap detector.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum BodyType {
    /// No movement; collides with dynamic bodies.
    Static,
    /// Mass-based simulation; affected by forces and gravity.
    Dynamic,
    /// Velocity-driven; not affected by forces.
    Kinematic,
    /// Non-colliding overlap detector.
    Sensor,
}
/// Primitive collision shape baked into the body descriptor.
/// # Variants
/// - `Rect`: axis-aligned rectangle with explicit dimensions.
/// - `Circle`: circle with the given radius.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum BodyShape {
    /// Axis-aligned bounding box.
    Rect { width: f32, height: f32 },
    /// Circle of the given radius.
    Circle { radius: f32 },
}
/// Data-only description of a physics body passed to `World` for simulation.
/// # Fields
/// - `position`: world-space body center.
/// - `velocity`: linear velocity in world units per second.
/// - `mass`: body mass in kilograms.
/// - `body_type`: simulation role used by the solver.
/// - `shape`: primary primitive shape used for broad behavior.
/// - `restitution`: bounce coefficient.
/// - `layer`: collision layer membership mask.
/// - `mask`: collision interaction mask.
/// - `width`: cached AABB-equivalent width.
/// - `height`: cached AABB-equivalent height.
/// - `friction`: surface friction coefficient.
/// - `angle`: rotation in radians.
/// - `angular_velocity`: rotational velocity in radians per second.
/// - `shape_ext`: optional extended polygon/edge/chain geometry.
pub struct Body {
    /// World-space position.
    pub position: Vec2,
    /// Linear velocity in world units per second.
    pub velocity: Vec2,
    /// Body mass in kg.
    pub mass: f32,
    /// Simulation role.
    pub body_type: BodyType,
    /// Primary collision primitive.
    pub shape: BodyShape,
    /// Coefficient of restitution (bounciness) in 0.0..=1.0.
    pub restitution: f32,
    /// Bitmask for this body's collision category.
    pub layer: u32,
    /// Bitmask of which categories this body collides with.
    pub mask: u32,
    /// Width of the AABB-equivalent for the chosen shape.
    pub width: f32,
    /// Height of the AABB-equivalent for the chosen shape.
    pub height: f32,
    /// Coefficient of friction in 0.0..=1.0.
    pub friction: f32,
    /// Rotation in radians.
    pub angle: f32,
    /// Angular velocity in radians per second.
    pub angular_velocity: f32,
    /// Extended shape for polygon, edge, and chain bodies.
    pub shape_ext: Option<Shape>,
}
/// Construction and geometric helpers for `Body`.
impl Body {
    fn defaults_for_shape(
        shape: BodyShape,
        shape_ext: Option<Shape>,
        x: f32,
        y: f32,
        w: f32,
        h: f32,
        body_type: BodyType,
    ) -> Self {
        Self {
            position: Vec2::new(x, y),
            velocity: Vec2::ZERO,
            mass: 1.0,
            body_type,
            shape,
            restitution: 0.3,
            layer: 1,
            mask: 1,
            width: w,
            height: h,
            friction: 0.5,
            angle: 0.0,
            angular_velocity: 0.0,
            shape_ext,
        }
    }

    fn fallback_polygon_vertices() -> Vec<Vec2> {
        vec![
            Vec2::new(-0.5, -0.5),
            Vec2::new(0.5, -0.5),
            Vec2::new(0.0, 0.5),
        ]
    }

    fn fallback_chain_vertices() -> Vec<Vec2> {
        vec![Vec2::new(-0.5, 0.0), Vec2::new(0.5, 0.0)]
    }

    fn validate_material_defaults(
        body_type: BodyType,
        mass: f32,
        friction: f32,
        restitution: f32,
    ) -> Result<(), PhysicsError> {
        if body_type == BodyType::Dynamic {
            validate_positive("mass", f64::from(mass))?;
        }
        validate_range("friction", f64::from(friction), 0.0, 1.0)?;
        validate_range("restitution", f64::from(restitution), 0.0, 1.0)?;
        Ok(())
    }

    fn validate_common(x: f32, y: f32, body_type: BodyType) -> Result<(), PhysicsError> {
        validate_finite("x", f64::from(x))?;
        validate_finite("y", f64::from(y))?;
        Self::validate_material_defaults(body_type, 1.0, 0.5, 0.3)
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

    /// Validate the authored body payload against the shared physics safety contract.
    pub fn validate(&self, limits: &PhysicsLimits) -> Result<(), PhysicsError> {
        validate_finite("position.x", f64::from(self.position.x))?;
        validate_finite("position.y", f64::from(self.position.y))?;
        validate_finite("velocity.x", f64::from(self.velocity.x))?;
        validate_finite("velocity.y", f64::from(self.velocity.y))?;
        validate_finite("angle", f64::from(self.angle))?;
        validate_finite("angular_velocity", f64::from(self.angular_velocity))?;
        Self::validate_material_defaults(
            self.body_type,
            self.mass,
            self.friction,
            self.restitution,
        )?;
        if let Some(shape) = &self.shape_ext {
            match shape {
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
                    Self::validate_vertices(
                        "physics chain",
                        vertices,
                        min,
                        limits.max_chain_vertices,
                    )?;
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
                Shape::Rect { width, height } => {
                    validate_positive("width", f64::from(*width))?;
                    validate_positive("height", f64::from(*height))?;
                }
                Shape::Circle { radius } => {
                    validate_positive("radius", f64::from(*radius))?;
                }
            }
            return Ok(());
        }
        match self.shape {
            BodyShape::Rect { width, height } => {
                validate_positive("width", f64::from(width))?;
                validate_positive("height", f64::from(height))?;
            }
            BodyShape::Circle { radius } => {
                validate_positive("radius", f64::from(radius))?;
            }
        }
        Ok(())
    }

    /// Create a rectangular body using strict validation.
    pub fn try_new(
        x: f32,
        y: f32,
        w: f32,
        h: f32,
        body_type: BodyType,
    ) -> Result<Self, PhysicsError> {
        Self::validate_common(x, y, body_type)?;
        validate_positive("width", f64::from(w))?;
        validate_positive("height", f64::from(h))?;
        Ok(Self::defaults_for_shape(
            BodyShape::Rect {
                width: w,
                height: h,
            },
            None,
            x,
            y,
            w,
            h,
            body_type,
        ))
    }

    /// Create a rectangular body at `(x,y)` with explicit `(w,h)` dimensions.
    pub fn new(x: f32, y: f32, w: f32, h: f32, body_type: BodyType) -> Self {
        log_msg!(debug, BD01, "({},{})", x, y);
        Self::try_new(x, y, w, h, body_type).unwrap_or_else(|_| {
            let safe_x = if x.is_finite() { x } else { 0.0 };
            let safe_y = if y.is_finite() { y } else { 0.0 };
            let safe_w = if w.is_finite() { w.abs().max(1.0) } else { 1.0 };
            let safe_h = if h.is_finite() { h.abs().max(1.0) } else { 1.0 };
            Self::defaults_for_shape(
                BodyShape::Rect {
                    width: safe_w,
                    height: safe_h,
                },
                None,
                safe_x,
                safe_y,
                safe_w,
                safe_h,
                body_type,
            )
        })
    }

    /// Create a circular body using strict validation.
    pub fn try_new_circle(
        x: f32,
        y: f32,
        radius: f32,
        body_type: BodyType,
    ) -> Result<Self, PhysicsError> {
        Self::validate_common(x, y, body_type)?;
        validate_positive("radius", f64::from(radius))?;
        Ok(Self::defaults_for_shape(
            BodyShape::Circle { radius },
            None,
            x,
            y,
            radius * 2.0,
            radius * 2.0,
            body_type,
        ))
    }

    /// Create a circular body at `(x,y)` with the given `radius`.
    pub fn new_circle(x: f32, y: f32, radius: f32, body_type: BodyType) -> Self {
        log_msg!(debug, BD02, "({},{}) r={}", x, y, radius);
        Self::try_new_circle(x, y, radius, body_type).unwrap_or_else(|_| {
            let safe_x = if x.is_finite() { x } else { 0.0 };
            let safe_y = if y.is_finite() { y } else { 0.0 };
            let safe_radius = if radius.is_finite() {
                radius.abs().max(0.5)
            } else {
                0.5
            };
            Self::defaults_for_shape(
                BodyShape::Circle {
                    radius: safe_radius,
                },
                None,
                safe_x,
                safe_y,
                safe_radius * 2.0,
                safe_radius * 2.0,
                body_type,
            )
        })
    }

    /// Create a polygon body using strict validation.
    pub fn try_new_polygon(
        x: f32,
        y: f32,
        vertices: Vec<Vec2>,
        body_type: BodyType,
    ) -> Result<Self, PhysicsError> {
        Self::validate_common(x, y, body_type)?;
        let limits = PhysicsLimits::default();
        Self::validate_vertices("physics polygon", &vertices, 3, limits.max_polygon_vertices)?;
        if !Self::is_convex_polygon(&vertices) {
            return Err(PhysicsError::DegenerateGeometry {
                context: "physics polygon",
                detail: "polygon must be convex",
            });
        }
        if Self::polygon_area2(&vertices).abs() <= 1e-4 {
            return Err(PhysicsError::DegenerateGeometry {
                context: "physics polygon",
                detail: "polygon area must be non-zero",
            });
        }
        let (min_x, min_y, max_x, max_y) = Self::bounds_from_vertices(&vertices);
        let w = max_x - min_x;
        let h = max_y - min_y;
        Ok(Self::defaults_for_shape(
            BodyShape::Rect {
                width: w,
                height: h,
            },
            Some(Shape::Polygon { vertices }),
            x,
            y,
            w,
            h,
            body_type,
        ))
    }

    /// Create a polygon body at `(x,y)` from a vertex list; AABB derived from vertex bounds.
    pub fn new_polygon(x: f32, y: f32, vertices: Vec<Vec2>, body_type: BodyType) -> Self {
        log_msg!(debug, BD03, "({},{})", x, y);
        Self::try_new_polygon(x, y, vertices, body_type).unwrap_or_else(|_| {
            let safe_x = if x.is_finite() { x } else { 0.0 };
            let safe_y = if y.is_finite() { y } else { 0.0 };
            Self::defaults_for_shape(
                BodyShape::Rect {
                    width: 1.0,
                    height: 1.0,
                },
                Some(Shape::Polygon {
                    vertices: Self::fallback_polygon_vertices(),
                }),
                safe_x,
                safe_y,
                1.0,
                1.0,
                body_type,
            )
        })
    }

    /// Create an edge body using strict validation.
    pub fn try_new_edge(
        x: f32,
        y: f32,
        v1: Vec2,
        v2: Vec2,
        body_type: BodyType,
    ) -> Result<Self, PhysicsError> {
        Self::validate_common(x, y, body_type)?;
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
        let w = dx.abs().max(1.0);
        let h = dy.abs().max(1.0);
        Ok(Self::defaults_for_shape(
            BodyShape::Rect {
                width: w,
                height: h,
            },
            Some(Shape::Edge { v1, v2 }),
            x,
            y,
            w,
            h,
            body_type,
        ))
    }

    /// Create an edge (line segment) body from `v1` to `v2` anchored at `(x,y)`.
    pub fn new_edge(x: f32, y: f32, v1: Vec2, v2: Vec2, body_type: BodyType) -> Self {
        Self::try_new_edge(x, y, v1, v2, body_type).unwrap_or_else(|_| {
            let safe_x = if x.is_finite() { x } else { 0.0 };
            let safe_y = if y.is_finite() { y } else { 0.0 };
            Self::defaults_for_shape(
                BodyShape::Rect {
                    width: 1.0,
                    height: 1.0,
                },
                Some(Shape::Edge {
                    v1: Vec2::new(0.0, 0.0),
                    v2: Vec2::new(1.0, 0.0),
                }),
                safe_x,
                safe_y,
                1.0,
                1.0,
                body_type,
            )
        })
    }

    /// Create a chain body using strict validation.
    pub fn try_new_chain(
        x: f32,
        y: f32,
        vertices: Vec<Vec2>,
        closed: bool,
        body_type: BodyType,
    ) -> Result<Self, PhysicsError> {
        Self::validate_common(x, y, body_type)?;
        let limits = PhysicsLimits::default();
        let min = if closed { 3 } else { 2 };
        Self::validate_vertices("physics chain", &vertices, min, limits.max_chain_vertices)?;
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
        let (min_x, min_y, max_x, max_y) = Self::bounds_from_vertices(&vertices);
        let w = (max_x - min_x).max(1.0);
        let h = (max_y - min_y).max(1.0);
        Ok(Self::defaults_for_shape(
            BodyShape::Rect {
                width: w,
                height: h,
            },
            Some(Shape::Chain { vertices, closed }),
            x,
            y,
            w,
            h,
            body_type,
        ))
    }

    /// Create a chain (open or closed polyline) body anchored at `(x,y)`.
    pub fn new_chain(
        x: f32,
        y: f32,
        vertices: Vec<Vec2>,
        closed: bool,
        body_type: BodyType,
    ) -> Self {
        Self::try_new_chain(x, y, vertices, closed, body_type).unwrap_or_else(|_| {
            let safe_x = if x.is_finite() { x } else { 0.0 };
            let safe_y = if y.is_finite() { y } else { 0.0 };
            Self::defaults_for_shape(
                BodyShape::Rect {
                    width: 1.0,
                    height: 1.0,
                },
                Some(Shape::Chain {
                    vertices: Self::fallback_chain_vertices(),
                    closed: false,
                }),
                safe_x,
                safe_y,
                1.0,
                1.0,
                body_type,
            )
        })
    }

    /// Return the axis-aligned bounding box of this body in world space.
    pub fn bounding_box(&self) -> Rect {
        match self.shape {
            BodyShape::Rect { width, height } => Rect::new(
                self.position.x - width / 2.0,
                self.position.y - height / 2.0,
                width,
                height,
            ),
            BodyShape::Circle { radius } => Rect::new(
                self.position.x - radius,
                self.position.y - radius,
                radius * 2.0,
                radius * 2.0,
            ),
        }
    }

    /// Return true when this body's layer and mask are compatible with `other`.
    pub fn collides_with_layer(&self, other: &Body) -> bool {
        (self.layer & other.mask) != 0 && (other.layer & self.mask) != 0
    }

    /// Return the bounding box as `(x, y, width, height)` tuple.
    pub fn get_bounding_box(&self) -> (f32, f32, f32, f32) {
        let r = self.bounding_box();
        (r.x, r.y, r.width, r.height)
    }

    /// Return the body type as a static string slice.
    pub fn get_type(&self) -> &'static str {
        match self.body_type {
            BodyType::Static => "static",
            BodyType::Dynamic => "dynamic",
            BodyType::Kinematic => "kinematic",
            BodyType::Sensor => "sensor",
        }
    }

    /// Convert a local-space offset to world-space position accounting for body rotation.
    pub fn get_world_point(&self, local_x: f32, local_y: f32) -> (f32, f32) {
        let cos_a = self.angle.cos();
        let sin_a = self.angle.sin();
        let wx = self.position.x + local_x * cos_a - local_y * sin_a;
        let wy = self.position.y + local_x * sin_a + local_y * cos_a;
        (wx, wy)
    }

    /// Convert a world-space position to a local-space offset accounting for body rotation.
    pub fn get_local_point(&self, world_x: f32, world_y: f32) -> (f32, f32) {
        let dx = world_x - self.position.x;
        let dy = world_y - self.position.y;
        let cos_a = self.angle.cos();
        let sin_a = self.angle.sin();
        let lx = dx * cos_a + dy * sin_a;
        let ly = -dx * sin_a + dy * cos_a;
        (lx, ly)
    }
}
