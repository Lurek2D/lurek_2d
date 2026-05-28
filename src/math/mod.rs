//! Math primitives: Vec2, Vec3, Mat3, Rect, Circle, Transform.
//!
//! - Sub-modules: `aabb_tree`, `bezier`, `circle`, `easing`, and 12 more.

/// AABB broadphase spatial query tree.
pub mod aabb_tree;
/// Cubic bezier curve evaluation and sampling.
pub mod bezier;
/// Circle shape with intersection and containment queries.
pub mod circle;

/// Easing function table for animation and tween drivers.
pub mod easing;
/// Scalar math utilities: lerp, remap, clamp, sign, smoothstep, inverse_lerp.
pub mod facade;
/// Scalar geometric helpers: point-in-shape, closest-point, distance, intersection.
pub mod geometry;
/// 3x3 matrix for 2D affine transforms.
pub mod mat3;

/// Convex and concave polygon with area, centroid, and clipping helpers.
pub mod polygon;
/// Seeded pseudo-random number generator with distribution helpers.
pub mod random;
/// Axis-aligned rectangle with union, intersection, and split operations.
pub mod rect;
/// Uniform spatial hash grid for fast neighbour queries.
pub mod spatial_hash;
/// Catmull-Rom and Hermite splines with uniform-arc-length sampling.
pub mod spline;
/// 2D position/rotation/scale transform and hierarchy helpers.
pub mod transform;
/// 2D float vector with arithmetic, geometry, and angle operations.
pub mod vec2;
/// 3D float vector with cross product and component-wise arithmetic.
pub mod vec3;
/// Voronoi diagram builder and per-cell data.
pub mod voronoi;

pub use aabb_tree::AabbTree;
pub use bezier::BezierCurve;
pub use circle::Circle;
pub use facade::{clamp, inverse_lerp, lerp, remap, sign, smoothstep};
pub use geometry::*;
pub use mat3::Mat3;

pub use random::RandomGenerator;
pub use rect::Rect;
pub use crate::image::rect_packing::{PackedRect, RectPacker};
pub use spatial_hash::SpatialHash;
pub use spline::{CatmullRomSpline, HermiteSpline};
pub use transform::Transform;
pub use vec2::Vec2;
pub use vec3::Vec3;
pub use voronoi::{voronoi_from_points, VoronoiCell};

/// Backward-compat re-export: sphere moved to `crate::globe::sphere`.
pub use crate::globe::sphere;
