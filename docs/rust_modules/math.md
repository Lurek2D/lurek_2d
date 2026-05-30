# math

## General Info

- Module group: `Foundations`
- Source path: `src/math/`
- Binding: `src/lua_api/math_api.rs`
- Namespace: `lurek.math`
- Lua API surface: `99` functions, `19` types, `164` methods
- Rust test path(s): tests/rust/unit/math_tests.rs; inline tests in src/math/vec2.rs, src/math/vec3.rs, src/math/mat3.rs, src/math/rect.rs, src/math/bezier.rs, src/math/easing.rs, src/math/geometry.rs, src/math/noise_functions.rs, src/math/noise_generator.rs, src/math/polygon.rs, src/math/random.rs, src/math/spatial_hash.rs, src/math/transform.rs, src/math/tween.rs, src/math/voronoi.rs, src/math/mod.rs; sibling test file src/math/aabb_tree_tests.rs; inline tests in src/math/spline.rs
- Lua test path(s): tests/lua/unit/test_math.lua

## Summary

As the foundational leaf of the engine's dependency graph, it is imported and utilized by nearly every other subsystem. The core vector mathematics are handled by highly optimized `Vec2` and `Vec3` types, which offer a complete set of arithmetic operations, geometric helpers (dot, cross, normalize, distance), and angle conversions. Complex transformations are managed by the `Transform` struct, backed by a row-major 3x3 affine matrix (`Mat3`), facilitating chainable translation, rotation, scale, and shear operations.

Beyond basic vectors, the module implements a robust set of geometric primitives and intersection algorithms. `Rect` and `Circle` structs provide foundational AABB and radial collision checks. The `geometry` submodule extends this with advanced operations: signed polygon area (shoelace formula), centroid calculation, point-in-polygon ray casting, line and segment intersection, Ear-clipping triangulation, Sutherland-Hodgman polygon clipping, and Andrew's monotone chain convex hull generation. To accelerate geometric queries, the module provides dynamic spatial indexing structures: an `AabbTree` for broad-phase hierarchical queries and a `SpatialHash` for uniform grid lookups, scaling efficiently with entity density rather than raw count.

The module also excels in procedural generation and animation. It features a sophisticated `NoiseGenerator` offering Perlin, Simplex, and Worley (cellular) noise, layered with Fractional Brownian Motion (fBm) or turbulence for organic terrain synthesis. For animation, it provides an extensive library of over 50 named easing functions and multi-channel numeric interpolators via the `Tween` system. Pathing and curves are supported through `BezierCurve` (quadratic/cubic) and `CatmullRomSpline` implementations. Additionally, it handles deterministic, seedable random number generation (`RandomGenerator`) and texture atlas rectangle packing. This immense mathematical toolkit is entirely exposed to the scripting environment via the `lurek.math.*` API.

## Files

### [aabb_tree.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/math/aabb_tree.rs)

- Dynamic broad-phase spatial index for 2D world queries and overlap culling.
- Stores moving bounds in a hierarchy that stays tight as entries shift each frame.
- Serves fast insert, remove, move, and query flows for dynamic actors.
- Reuses nodes through an internal pool to reduce allocation churn.
- Chooses sibling branches with a cost heuristic that keeps the tree balanced.
- Answers rectangle, point, circle, and segment tests from one entry map.
- Exposes helper bound math so callers can combine and compare leaves efficiently.
- Fits game-style workloads where many objects move but only a subset interact.
- Gives predictable query latency for proximity, visibility, and broad-phase passes.
- Keeps the data model leaf-centric so Lua-side handles stay simple and stable.

### [bezier.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/math/bezier.rs)

- Flexible Bézier curve utility for smooth motion paths and procedural shaping.
- Supports dynamic control points, clamped evaluation, and partial-segment sampling.
- Provides tangent and derivative queries for orientation and velocity-aware effects.
- Can be transformed in place with translate, rotate, and scale operations.
- Designed for path authoring, easing-like shaping, and motion interpolation use cases.

### [circle.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/math/circle.rs)

- Circle primitive for radius-based collision and containment checks.
- Keeps radius non-negative and treats the center as the shape anchor.
- Answers point, circle, and AABB overlap queries for gameplay geometry.
- Includes area and perimeter helpers for higher-level math routines.

### [easing.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/math/easing.rs)

- Curated easing family for animation curves and tween response shaping.
- Covers the standard in, out, and in-out variants across common motion families.
- Handles edge clamping for curves that need explicit start and end behavior.
- Exposes name-based resolution for data-driven animation systems.
- Includes linear passthrough for identity interpolation.
- Keeps the API focused on normalized t in [0,1] inputs and outputs.
- Lets higher-level systems drive motion with consistent curve semantics.

### [facade.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/math/facade.rs)

- Small scalar helper layer for interpolation and numeric remapping.
- Groups lerp, inverse lerp, remap, smoothstep, clamp, and sign behavior.
- Operates on f32 values only and stays side-effect free.
- Acts as the lightweight math front door for common numeric tasks.

### [geometry.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/math/geometry.rs)

- Standalone geometry toolbox for flat coordinate math and polygon routines.
- Covers circle, segment, line, and point queries used by gameplay systems.
- Computes polygon area, centroid, convex hull, and point inclusion tests.
- Provides line rasterization for grid traversal and tile-based effects.
- Includes Delaunay triangulation helpers for procedural meshes and Voronoi prep.
- Uses f32 for engine-facing work and f64 where triangulation precision matters.
- Exposes plain free functions with no shape ownership or scene coupling.
- Serves as the shared low-level layer for collision, map, and generation code.

### [loot_table.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/math/loot_table.rs)

- Weighted loot sampling and pity tracking for deterministic drop systems.
- Uses the alias method for O(1) draws after an O(n) build step.
- Keeps the raw weight table and RNG state serializable for save files.
- Supports guaranteed outcomes once a pity threshold is reached.
- Lets callers combine normal sampling with tracked fail counters.
- Preserves fast runtime lookups without hiding the probability model.
- Fits reward tables, gacha-style drops, and event-driven item rolls.
- Restores exactly to the previous random state when deserialized.
- Keeps the core data structure simple enough for Lua-driven gameplay flows.
- Exposes predictable sampling behavior under both normal and pity paths.

### [mat3.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/math/mat3.rs)

- Row-major 3x3 matrix for 2D affine transforms and coordinate mapping.
- Builds identity, translation, rotation, scale, and shear matrices.
- Supports inversion and multiplication for transform composition.
- Maps points through a compact linear algebra core.
- Serves as the numeric backbone for higher-level 2D transform code.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/math/mod.rs)

- Core math module wiring the vector, matrix, shape, curve, and utility submodules.
- Collects the primitives that other engine systems build on for motion, collision, and mapping.
- Groups spatial structures with interpolation, geometry, and procedural helpers under one namespace.
- Keeps the public math surface compact while exposing the full foundation layer.

### [polygon.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/math/polygon.rs)

- Polygon toolkit for clipping, hull building, triangulation, and winding cleanup.
- Handles simple and concave shapes with routines aimed at gameplay geometry.
- Provides intersection and boolean-style operations for shape processing.
- Computes signed area and point-in-triangle tests for structural checks.
- Normalizes vertex order so downstream consumers can rely on consistent winding.
- Supplies the low-level machinery behind map, collision, and editor-style geometry flows.

### [random.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/math/random.rs)

- Seedable pseudo-random generator wrapper for deterministic gameplay and replay.
- Produces uniform integer, float, and Gaussian samples from one stateful source.
- Serializes and restores seed state so saves can resume the same sequence.
- Gives higher-level systems a simple random facade without exposing backend details.
- Fits any flow that needs reproducible chance, noise, or procedural variation.

### [rect.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/math/rect.rs)

- Axis-aligned rectangle helper for layout, bounds, and collision checks.
- Stores top-left position plus size under the engine's y-down convention.
- Supports containment, overlap, union, and bounding-box construction.
- Offers both corner-based and center-based creation paths.
- Acts as the basic 2D box type used across spatial code.

### [spatial_hash.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/math/spatial_hash.rs)

- Uniform-grid spatial hash for broad-phase collision and proximity search.
- Buckets moving bounds into cells so query cost follows local density, not world size.
- Supports insert, remove, update, and deduplicated multi-shape queries.
- Handles rectangle, circle, and segment probes with shared cell traversal logic.
- Uses slab-style segment tests for fast box intersection checks.
- Works best when many objects stay sparse across a large playfield.

### [spline.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/math/spline.rs)

- Multi-segment spline helper for smooth interpolation across control points.
- Bridges Catmull-Rom and Hermite style curve handling under one shape.
- Supports normalized sampling across full paths or individual segments.
- Tracks control points dynamically so paths can be edited at runtime.
- Useful for motion trails, camera rails, and other smooth route logic.

### [transform.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/math/transform.rs)

- Mutable 2D affine transform that accumulates position, rotation, scale, and shear.
- Wraps a 3x3 matrix so chained edits stay compact and composable.
- Exposes forward and inverse point mapping for world and local space conversion.
- Includes SRT decomposition for systems that need readable transform components.
- Bridges low-level matrix math with runtime spatial manipulation.

### [vec2.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/math/vec2.rs)

- Fundamental 2D float vector for position, velocity, direction, and offsets.
- Covers arithmetic, normalization, projection, and distance-style helpers.
- Adds rotation, reflection, and angle conversion support for gameplay math.
- Offers interpolation and unit-direction construction from radians.
- Serves as the common scalar pair used throughout the engine.

### [vec3.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/math/vec3.rs)

- 3D float vector for cross products, directions, and other compact spatial math.
- Provides arithmetic and geometric helpers for dot, cross, normalize, and reflection work.
- Supports projection, interpolation, distance, and length queries.
- Acts as the small 3D companion to the 2D math core.
- Useful for normals, ray direction math, and procedural inputs.

### [voronoi.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/math/voronoi.rs)

- Voronoi cell builder from 2D point sets using incremental Delaunay construction.
- Produces closed polygonal cells with stable point deduplication and cleanup.
- Relies on circumcircle predicates to drive triangulation updates.
- Extracts boundary edges and orders vertices counter-clockwise for each region.
- Handles coincident sites gracefully instead of failing the whole diagram.
- Gives procedural generation and spatial partitioning code a ready-made diagram source.
