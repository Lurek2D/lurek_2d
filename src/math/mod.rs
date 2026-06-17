//! Core math module wiring the vector, matrix, shape, curve, and utility submodules. `math/mod` is the math module index, declaring `aabb_tree`, `bezier`, `circle`, `easing`, `facade`, and 12 more so agents can identify which files own each feature slice before opening implementation code.
//! Collects the primitives that other engine systems build on for motion, collision, and mapping. `src/math/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `aabb_tree::AabbTree`, `bezier::BezierCurve`, `circle::Circle`, `facade::{clamp, inverse_lerp, lerp, remap, sign, smoothstep}`, and 13 more centralized for the math subsystem.
//! Groups spatial structures with interpolation, geometry, and procedural helpers under one namespace. The file documents how math submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.
//! Keeps the public math surface compact while exposing the full foundation layer. Agents should read this index to choose the narrow owner file first, because it maps names such as `aabb_tree`, `bezier`, `circle`, `easing`, `facade`, and 12 more to concrete implementation responsibilities.
//! `math/mod` is the math module index, declaring `aabb_tree`, `bezier`, `circle`, `easing`, `facade`, and 12 more so agents can identify which files own each feature slice before opening implementation code.
//! `src/math/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `aabb_tree::AabbTree`, `bezier::BezierCurve`, `circle::Circle`, `facade::{clamp, inverse_lerp, lerp, remap, sign, smoothstep}`, and 13 more centralized for the math subsystem.

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

/// Walker-Vose alias-method loot table and pity tracker for O(1) random drops.
pub mod loot_table;
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

pub use crate::image::rect_packing::{PackedRect, RectPacker};
pub use loot_table::{sample_with_pity, LootEntry, LootTable, PityTracker};
pub use random::RandomGenerator;
pub use rect::Rect;
pub use spatial_hash::SpatialHash;
pub use spline::{CatmullRomSpline, HermiteSpline};
pub use transform::Transform;
pub use vec2::Vec2;
pub use vec3::Vec3;
pub use voronoi::{voronoi_from_points, VoronoiCell};

/// Backward-compat re-export: sphere moved to `crate::globe::sphere`.
pub use crate::globe::sphere;
