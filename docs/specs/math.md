# math

## TL;DR

- The `math` module is the most pervasive Foundations tier component in Lurek2D, providing an expansive suite of 2D mathematics, geometry, procedural generation, and spatial utility types.

## General Info

- Module group: `Foundations`
- Source path: `src/math/`
- Lua API path(s): `src/lua_api/math_api.rs`
- Primary Lua namespace: `lurek.math`
- Rust test path(s): tests/rust/unit/math_tests.rs; inline tests in src/math/vec2.rs, src/math/vec3.rs, src/math/mat3.rs, src/math/rect.rs, src/math/bezier.rs, src/math/easing.rs, src/math/geometry.rs, src/math/noise_functions.rs, src/math/noise_generator.rs, src/math/polygon.rs, src/math/random.rs, src/math/spatial_hash.rs, src/math/transform.rs, src/math/tween.rs, src/math/voronoi.rs, src/math/mod.rs; sibling test file src/math/aabb_tree_tests.rs; inline tests in src/math/spline.rs
- Lua test path(s): tests/lua/unit/test_math.lua

## Summary

 As the foundational leaf of the engine's dependency graph, it is imported and utilized by nearly every other subsystem. The core vector mathematics are handled by highly optimized `Vec2` and `Vec3` types, which offer a complete set of arithmetic operations, geometric helpers (dot, cross, normalize, distance), and angle conversions. Complex transformations are managed by the `Transform` struct, backed by a row-major 3x3 affine matrix (`Mat3`), facilitating chainable translation, rotation, scale, and shear operations.

Beyond basic vectors, the module implements a robust set of geometric primitives and intersection algorithms. `Rect` and `Circle` structs provide foundational AABB and radial collision checks. The `geometry` submodule extends this with advanced operations: signed polygon area (shoelace formula), centroid calculation, point-in-polygon ray casting, line and segment intersection, Ear-clipping triangulation, Sutherland-Hodgman polygon clipping, and Andrew's monotone chain convex hull generation. To accelerate geometric queries, the module provides dynamic spatial indexing structures: an `AabbTree` for broad-phase hierarchical queries and a `SpatialHash` for uniform grid lookups, scaling efficiently with entity density rather than raw count.

The module also excels in procedural generation and animation. It features a sophisticated `NoiseGenerator` offering Perlin, Simplex, and Worley (cellular) noise, layered with Fractional Brownian Motion (fBm) or turbulence for organic terrain synthesis. For animation, it provides an extensive library of over 50 named easing functions and multi-channel numeric interpolators via the `Tween` system. Pathing and curves are supported through `BezierCurve` (quadratic/cubic) and `CatmullRomSpline` implementations. Additionally, it handles deterministic, seedable random number generation (`RandomGenerator`) and texture atlas rectangle packing. This immense mathematical toolkit is entirely exposed to the scripting environment via the `lurek.math.*` API.

## Source Documentation

### `aabb_tree.rs`
- Dynamic AABB bounding-volume hierarchy for broad-phase 2D spatial queries.
- Insertion, removal, and in-place update of axis-aligned bounding boxes keyed by numeric id.
- Query primitives: rectangle overlap, point containment, circle overlap, and segment intersection.
- Surface-area heuristic descent for high-quality sibling selection on insert.
- Free-list node pool avoiding repeated allocation and fragmentation.
- Incremental bottom-up refit keeping ancestor bounds tight after mutations.
- Helper geometry routines: AABB area, merged bounds, box-box, box-circle, and box-segment tests.
- Leaf-centric design mapping each entry id to a single leaf node for O(1) lookup.
- Suitable for hundreds to low thousands of dynamic bodies at interactive frame rates.

### `bezier.rs`
- Arbitrary-degree Bézier curve with dynamic control-point list.
- Evaluation via Bernstein basis, clamped to [0,1].
- Sampling helpers for full curves, sub-segments, and arc-length walks.
- First-derivative computation and tangent-angle extraction.
- Geometric transforms: translate, rotate, scale relative to an origin.
- Control-point CRUD with minimum-count safety.

### `circle.rs`
- Circle primitive defined by center + radius, clamped non-negative on construction.
- Point-containment, circle-circle intersection, and AABB queries.
- Area and perimeter helpers using `std::f32::consts::PI`.

### `easing.rs`
- Standard easing curves: quad, cubic, quart, sine, expo, elastic, bounce, back.
- Each family provides in, out, and in-out variants mapping t∈[0,1]→[0,1].
- Boundary-clamped functions (expo, elastic) handle t≤0 and t≥1 explicitly.
- Name-based lookup via `apply` and `resolve_easing_fn` for string-driven tween systems.
- Linear passthrough for identity interpolation.

### `facade.rs`
- Scalar interpolation helpers: lerp, inverse_lerp, remap, smoothstep.
- Numeric utilities: clamp, sign.
- All functions operate on `f32` and are pure (no side effects).

### `geometry.rs`
- Circle queries: containment, circle-circle overlap, circle-line and circle-segment intersection with hit points.
- Polygon operations: signed area (shoelace), centroid, point-in-polygon (ray cast), convex hull (Andrew monotone chain).
- Segment and line utilities: segment-segment intersection, closest point on segment, infinite-line intersection.
- Grid rasterization: Bresenham line for integer cell traversal.
- Triangulation: Delaunay via Bowyer-Watson with super-triangle removal.
- Angle computation: atan2-based bearing between two points.
- All routines are standalone free functions operating on flat coordinate scalars or flat vertex arrays.
- f32 used for game-facing geometry; f64 used for Delaunay where precision matters.

### `mat3.rs`
- Row-major 3×3 matrix type for 2D affine transformations.
- Factory constructors for identity, translation, rotation, scale, and shear.
- Inverse computation with degenerate-determinant fallback.
- Point transformation and matrix multiplication via `std::ops::Mul`.

### `mod.rs`
- Math primitives: Vec2, Vec3, Mat3, Rect, Circle, Transform.
- Noise and procedural generation: Perlin, simplex, value noise, Voronoi diagrams.
- Spatial structures: AABB tree, spatial hash grid, rectangle bin-packing.
- Curves and interpolation: bezier, splines, tweens, easing functions, scalar helpers.

### `noise_functions.rs`
- Perlin noise helpers (2-D, 3-D, 4-D) with per-call seeding.
- Simplex noise (2-D, 3-D) with optional fixed seed.
- Fractional Brownian motion (fBm) layering multiple Perlin octaves.

### `noise_generator.rs`
- Seeded permutation-table noise generator supporting Perlin gradient noise in 1-D through 4-D dimensions.
- Simplex noise variants in 1-D, 2-D, and 3-D using skewed simplex grids for faster evaluation.
- Worley (cell/Voronoi) noise in 2-D and 3-D with selectable distance metrics: Euclidean, Manhattan, Chebyshev.
- Fractal layering strategies: fractional Brownian motion (fBm), ridged multifractal, and turbulence.
- Configurable heightmap generation producing row-major f64 arrays from combined multi-octave passes.
- Gradient contribution helpers mapping hash bytes to directional dot products in 1-D through 4-D.
- Smoothstep fade curve and linear interpolation primitives used across all Perlin evaluations.
- Deterministic cell hashing for reproducible procedural feature point placement from any u64 seed.
- Domain warping via Perlin displacement fields for organic terrain and texture distortion.
- MapGenOptions controlling scale, octaves, lacunarity, persistence, offset, algorithm, and fractal type.

### `polygon.rs`
- Ear-clipping triangulation for simple polygons and convexity testing.
- Sutherland-Hodgman polygon clipping against arbitrary half-planes.
- Boolean-style polygon operations: intersection, union, and difference.
- Andrew monotone-chain convex hull and winding-order normalization.
- Internal helpers for signed area, point-in-triangle, and cross-product sign tests.

### `random.rs`
- Seedable pseudo-random number generator wrapping `fastrand` with save/restore support.
- Uniform integer, float, and Gaussian sampling primitives.
- Seed persistence via string serialisation for deterministic replay.

### `rect.rs`
- Axis-aligned rectangle defined by top-left corner and size (y-down convention).
- Containment, intersection, union, and bounding-box construction from point sets.
- Center-based and corner-based constructors for layout and collision use cases.

### `rect_packing.rs`
- Shelf-first rectangle packing for texture atlas layout.
- Configurable atlas dimensions and uniform pixel padding between rects.
- Tracks occupancy ratio and returns placement coordinates in insertion order.

### `spatial_hash.rs`
- Uniform-grid spatial hashing for broad-phase 2D collision and proximity queries.
- AABB insert/remove/update with automatic cell-bucket management.
- Rectangle, circle, and segment query shapes with deduplication.
- Parametric slab-based segment-vs-AABB intersection test.
- O(1) cell lookup per query tile; scales with world density, not total item count.

### `sphere.rs`
- Sphere-surface coordinate helpers: latitude/longitude ↔ unit-sphere Vec3 conversion.
- Great-circle distance (Haversine) and arc interpolation between two geo-points.
- Ray-sphere intersection returning the nearest positive hit distance.
- Column-major 3×3 rotation matrices (axis-aligned X/Y/Z plus axial-tilt convenience).
- Matrix-vector and matrix-matrix multiplication for globe-view transforms.

### `spline.rs`
- Catmull-Rom multi-segment spline with dynamic control-point management.
- Hermite cubic segment defined by endpoints and tangents.
- Normalized parameter sampling across full spline or individual segments.

### `transform.rs`
- Accumulated 2D affine transform backed by a 3×3 matrix.
- Chainable translate, rotate, scale, and shear mutations.
- Forward and inverse point mapping plus SRT decomposition.

### `tween.rs`
- Multi-channel tween interpolator that drives values from start to target over a fixed duration.
- Easing resolution accepts both short names and `easeIn*`/`easeOut*` prefixed forms.
- Each tween holds an independent clock, supports reset, seek, and completion query.
- Channels are registered dynamically and interpolated per-frame via the resolved easing curve.
- Falls back to linear when an unknown easing name is provided.

### `vec2.rs`
- 2D float vector type used for all position, direction, and velocity math.
- Arithmetic operators: add, sub, mul, div, negate, and assign variants.
- Geometric helpers: length, normalize, distance, dot, cross, perpendicular.
- Rotation, reflection, and angle conversion utilities.
- Linear interpolation and unit-direction construction from radians.

### `vec3.rs`
- 3D float vector for cross-product normals, raycasting directions, and noise inputs.
- Arithmetic ops (add, sub, mul, div, neg) and geometric helpers (dot, cross, normalize, reflect, project).
- Lerp, distance, and length utilities for interpolation and spatial queries.

### `voronoi.rs`
- Voronoi diagram generation from 2D point sets via Bowyer-Watson Delaunay triangulation.
- Circumcenter and circumcircle predicates for incremental insertion.
- Boundary-edge extraction and super-triangle cleanup.
- CCW vertex sorting and deduplication to produce closed polygonal cells.
- Input deduplication to handle coincident sites gracefully.

## Types

- `AabbEntry` (`struct`, `aabb_tree.rs`): A single entry stored at a leaf node of the AABB tree.
- `AabbTree` (`struct`, `aabb_tree.rs`): A dynamic bounding-volume hierarchy for efficient AABB overlap queries.
- `BezierCurve` (`struct`, `bezier.rs`): Editable Bezier curve object for path sampling, tangents, and authorable curve manipulation. It supports both math-heavy tooling and Lua scripting use cases.
- `Circle` (`struct`, `circle.rs`): A circle defined by its centre and radius.
- `Mat3` (`struct`, `mat3.rs`): Affine 2D matrix for transform composition and point mapping. Higher-level transform code builds on this instead of rolling custom matrix math.
- `DistType` (`enum`, `noise_generator.rs`): Selects the distance metric used by Worley noise queries. This lets callers choose the visual character of cellular patterns without changing generator internals.
- `NoiseKind` (`enum`, `noise_generator.rs`): Selects the base noise family for generator and fractal operations. It keeps algorithm switching explicit at call sites.
- `FractalType` (`enum`, `noise_generator.rs`): Selects how multiple octaves are combined when generating layered noise. It distinguishes smooth FBM from ridged or turbulence-style outputs.
- `MapGenOptions` (`struct`, `noise_generator.rs`): Bundles the parameters for 2D map generation into one stable config object. It prevents wide argument lists in higher-level generation code.
- `NoiseGenerator` (`struct`, `noise_generator.rs`): Seeded procedural noise engine with multiple algorithms and fractal modes. It centralizes world-generation style noise work instead of scattering implementations.
- `RandomGenerator` (`struct`, `random.rs`): Deterministic RNG wrapper with seed and state control. It exists so engine code and Lua scripts can reproduce runs reliably.
- `Rect` (`struct`, `rect.rs`): Axis-aligned rectangle for cheap containment and overlap checks. It is the basic AABB type used by layout and collision-adjacent code.
- `PackedRect` (`struct`, `rect_packing.rs`): Placement record produced by runtime rectangle packing.
- `RectPacker` (`struct`, `rect_packing.rs`): Deterministic shelf-based runtime rectangle packer for atlas/UI layout.
- `SpatialItem` (`struct`, `spatial_hash.rs`): Stored record for an object indexed by `SpatialHash`. It keeps the query structure decoupled from any particular gameplay object type.
- `SpatialHash` (`struct`, `spatial_hash.rs`): Broad-phase query structure for coarse spatial lookup by AABB, circle, or segment. It is a utility index, not a full collision or physics system.
- `Mat3x3` (`struct`, `sphere.rs`): Column-major 3Ã—3 rotation matrix, used for camera orbit and axial tilt.
- `CatmullRomSpline` (`struct`, `spline.rs`): A Catmull-Rom spline through a sequence of control points.
- `HermiteSpline` (`struct`, `spline.rs`): A cubic Hermite spline segment defined by two endpoints and their tangents.
- `Transform` (`struct`, `transform.rs`): Mutable 2D transform object that exposes a script-friendly API over `Mat3`. It is the ergonomic surface for composition and point conversion.
- `TweenValue` (`struct`, `tween.rs`): Holds one start-target numeric pair inside a low-level tween. It is intentionally minimal and exists mainly to support `Tween`.
- `Tween` (`struct`, `tween.rs`): Low-level multi-channel numeric interpolator driven by easing functions and an internal clock. It does not own callbacks, sequences, or property animation workflows.
- `Vec2` (`struct`, `vec2.rs`): Core 2D vector used pervasively for positions, directions, offsets, and interpolation. It is the default math currency for most engine subsystems.
- `Vec3` (`struct`, `vec3.rs`): A 3D floating-point vector.
- `VoronoiCell` (`struct`, `voronoi.rs`): One cell of a Voronoi diagram.

## Functions

- `AabbTree::new` (`aabb_tree.rs`): Construct an empty AABB tree with no entries.
- `AabbTree::insert` (`aabb_tree.rs`): Insert or replace entry `id` with the given AABB, refitting the tree upward.
- `AabbTree::remove` (`aabb_tree.rs`): Remove entry `id`; returns `true` when the entry existed.
- `AabbTree::query` (`aabb_tree.rs`): Return ids of all entries whose AABB overlaps the given query box.
- `AabbTree::query_point` (`aabb_tree.rs`): Return ids of all entries whose AABB contains the point (x, y).
- `AabbTree::query_circle` (`aabb_tree.rs`): Return ids of all entries whose AABB overlaps the circle, verified with exact circle test.
- `AabbTree::query_segment` (`aabb_tree.rs`): Return ids of all entries whose AABB overlaps the segment, verified with exact slab test.
- `AabbTree::update` (`aabb_tree.rs`): Remove and re-insert entry `id` with updated bounds; returns `false` when id is not present.
- `AabbTree::contains` (`aabb_tree.rs`): Return true when entry `id` is currently stored in this tree.
- `AabbTree::len` (`aabb_tree.rs`): Return the number of entries currently stored.
- `AabbTree::is_empty` (`aabb_tree.rs`): Return true when the tree contains no entries.
- `AabbTree::clear` (`aabb_tree.rs`): Remove all entries and reset the node pool.
- `BezierCurve::new` (`bezier.rs`): Construct a Bézier curve from `points`; panics when fewer than 2 are supplied.
- `BezierCurve::evaluate` (`bezier.rs`): Evaluate the curve at parameter `t` (clamped to `[0,1]`) using Bernstein basis.
- `BezierCurve::render` (`bezier.rs`): Sample the full curve at `segments+1` evenly spaced parameter values.
- `BezierCurve::render_segment` (`bezier.rs`): Sample the curve between `t_start` and `t_end` at `segments+1` evenly spaced values.
- `BezierCurve::get_derivative` (`bezier.rs`): Return the first derivative curve as a new `BezierCurve` with degree reduced by one.
- `BezierCurve::get_control_point` (`bezier.rs`): Return the control point at `index`, or `None` when out of range.
- `BezierCurve::set_control_point` (`bezier.rs`): Set control point at `index`; returns `false` when out of range.
- `BezierCurve::insert_control_point` (`bezier.rs`): Insert `point` at `index`, or append when `index` is `None` or out of range.
- `BezierCurve::remove_control_point` (`bezier.rs`): Remove the control point at `index`; returns `false` when fewer than 3 points remain or index is out of range.
- `BezierCurve::get_control_point_count` (`bezier.rs`): Return the number of control points.
- `BezierCurve::translate` (`bezier.rs`): Translate all control points by `(dx, dy)`.
- `BezierCurve::rotate` (`bezier.rs`): Rotate all control points by `angle` radians around origin `(ox, oy)`.
- `BezierCurve::scale` (`bezier.rs`): Scale all control points by factor `s` relative to origin `(ox, oy)`.
- `BezierCurve::length` (`bezier.rs`): Return the approximate arc length via 100-sample numeric integration.
- `BezierCurve::get_interpolated_position` (`bezier.rs`): Return the evaluated point as `(x, y)` at parameter `t`.
- `BezierCurve::evaluate_at_distance` (`bezier.rs`): Return the point at arc-length `distance` from t=0 via `samples`-step linear walk.
- `BezierCurve::get_interpolated_angle` (`bezier.rs`): Return the tangent angle in radians at parameter `t` using the derivative curve.
- `Circle::new` (`circle.rs`): Construct a Circle; radius is clamped to >= 0.
- `Circle::center` (`circle.rs`): Return the center as a Vec2.
- `Circle::area` (`circle.rs`): Return π × r².
- `Circle::perimeter` (`circle.rs`): Return 2 × π × r.
- `Circle::contains` (`circle.rs`): Return true when `(px, py)` lies inside or on the boundary of this circle.
- `Circle::intersects` (`circle.rs`): Return true when this circle and `other` overlap (touching counts as intersection).
- `Circle::aabb` (`circle.rs`): Return the axis-aligned bounding box as `(min_x, min_y, max_x, max_y)`.
- `linear` (`easing.rs`): Linear interpolation — no easing.
- `ease_in_quad` (`easing.rs`): Quadratic ease-in — starts slow, accelerates.
- `ease_out_quad` (`easing.rs`): Quadratic ease-out — starts fast, decelerates.
- `ease_in_out_quad` (`easing.rs`): Quadratic ease-in-out — slow start and end, fast middle.
- `ease_in_cubic` (`easing.rs`): Cubic ease-in — starts slow, accelerates sharply.
- `ease_out_cubic` (`easing.rs`): Cubic ease-out — starts fast, decelerates sharply.
- `ease_in_out_cubic` (`easing.rs`): Cubic ease-in-out — smooth S-curve.
- `ease_in_quart` (`easing.rs`): Quartic ease-in — very slow start.
- `ease_out_quart` (`easing.rs`): Quartic ease-out — very slow end.
- `ease_in_out_quart` (`easing.rs`): Quartic ease-in-out — pronounced S-curve.
- `ease_in_sine` (`easing.rs`): Sinusoidal ease-in — gentle sine-based acceleration.
- `ease_out_sine` (`easing.rs`): Sinusoidal ease-out — gentle sine-based deceleration.
- `ease_in_out_sine` (`easing.rs`): Sinusoidal ease-in-out — gentle S-curve.
- `ease_in_expo` (`easing.rs`): Exponential ease-in — very slow start, rapid acceleration.
- `ease_out_expo` (`easing.rs`): Exponential ease-out — rapid start, very slow end.
- `ease_in_out_expo` (`easing.rs`): Exponential ease-in-out — sharp S-curve with exponential tails.
- `ease_in_elastic` (`easing.rs`): Elastic ease-in — spring-like overshoot at the start.
- `ease_out_elastic` (`easing.rs`): Elastic ease-out — spring-like overshoot at the end.
- `ease_in_out_elastic` (`easing.rs`): Elastic ease-in-out — spring-like overshoot at both ends.
- `ease_out_bounce` (`easing.rs`): Bounce ease-out — simulates a bouncing ball landing.
- `ease_in_bounce` (`easing.rs`): Bounce ease-in — simulates a bouncing ball launching.
- `ease_in_out_bounce` (`easing.rs`): Bounce ease-in-out — bouncing at both ends.
- `ease_in_back` (`easing.rs`): Back ease-in — pulls back before accelerating past the start.
- `ease_out_back` (`easing.rs`): Back ease-out — overshoots the target then settles back.
- `ease_in_out_back` (`easing.rs`): Back ease-in-out — pulls back at start, overshoots at end.
- `apply` (`easing.rs`): Looks up an easing function by name and applies it to progress value `t`.
- `resolve_easing_fn` (`easing.rs`): Return the function pointer for a named easing function; returns None when unrecognised.
- `lerp` (`facade.rs`): Linear interpolation between `a` and `b` by factor `t` in [0, 1].
- `remap` (`facade.rs`): Remap `v` from `[in_min, in_max]` to `[out_min, out_max]`.
- `clamp` (`facade.rs`): Clamp `v` to the range `[min, max]`.
- `sign` (`facade.rs`): Returns the sign of `v`: `1.0` if positive, `-1.0` if negative, `0.0` if zero.
- `smoothstep` (`facade.rs`): Hermite smooth interpolation between 0 and 1 when `x` is in `[edge0, edge1]`.
- `inverse_lerp` (`facade.rs`): Inverse linear interpolation: returns the `t` factor such that `lerp(a, b, t) ≈ v`.
- `angle_between` (`geometry.rs`): Returns the angle in radians from (x1, y1) to (x2, y2).
- `circle_contains_point` (`geometry.rs`): Returns true if the point (px, py) is inside the circle centered at (cx, cy) with radius r.
- `circle_intersects_circle` (`geometry.rs`): Returns true if two circles overlap.
- `circle_intersects_line` (`geometry.rs`): Line-circle intersection.
- `circle_intersects_segment` (`geometry.rs`): Segment-circle intersection.
- `polygon_area` (`geometry.rs`): Computes the signed area of a polygon using the Shoelace formula.
- `polygon_centroid` (`geometry.rs`): Computes the centroid of a polygon.
- `segment_intersects_segment` (`geometry.rs`): Tests if two line segments intersect.
- `closest_point_on_segment` (`geometry.rs`): Returns the closest point on a line segment to a given point.
- `point_in_polygon` (`geometry.rs`): Tests if a point is inside a polygon using the ray casting algorithm.
- `line_intersect` (`geometry.rs`): Infinite line intersection.
- `bresenham` (`geometry.rs`): Bresenham line rasterization from (x1, y1) to (x2, y2).
- `convex_hull` (`geometry.rs`): Computes the convex hull of a set of 2D points using Andrew's monotone chain algorithm.
- `delaunay_triangulate` (`geometry.rs`): Delaunay triangulation using the Bowyer-Watson algorithm.
- `Mat3::identity` (`mat3.rs`): Return the 3×3 identity matrix.
- `Mat3::from_row_major` (`mat3.rs`): Construct from a flat row-major 9-element slice.
- `Mat3::from_translation` (`mat3.rs`): Construct a pure translation matrix for offset `t`.
- `Mat3::from_rotation` (`mat3.rs`): Construct a pure rotation matrix for the given `angle` in radians.
- `Mat3::from_shear` (`mat3.rs`): Construct a shear matrix with horizontal factor `kx` and vertical factor `ky`.
- `Mat3::from_scale` (`mat3.rs`): Construct a non-uniform scale matrix from `scale`.
- `Mat3::inverse` (`mat3.rs`): Return the matrix inverse; returns identity when the determinant is near zero.
- `Mat3::transform_point` (`mat3.rs`): Apply this affine transform to a 2D point `p` and return the transformed point.
- `fade` (`noise_functions.rs`): Quintic fade curve for smooth interpolation: 6t^5 - 15t^4 + 10t^3.
- `perlin2d` (`noise_functions.rs`): Generates 2D Perlin noise at the given coordinates.
- `perlin3d` (`noise_functions.rs`): Generates 3D Perlin noise at the given coordinates.
- `perlin4d` (`noise_functions.rs`): Generates 4D Perlin noise at the given coordinates.
- `simplex2d` (`noise_functions.rs`): Generates 2D Simplex noise at the given coordinates.
- `simplex_noise_2d` (`noise_functions.rs`): Returns 2D simplex noise for the given coordinates using seed 0.
- `simplex_noise_3d` (`noise_functions.rs`): Returns 3D simplex noise for the given coordinates using seed 0.
- `fbm` (`noise_functions.rs`): Generates fractal Brownian motion noise by layering multiple octaves of Perlin noise.
- `NoiseGenerator::new` (`noise_generator.rs`): Construct a generator from `seed`, immediately building its permutation table.
- `NoiseGenerator::set_seed` (`noise_generator.rs`): Replace the current seed and rebuild the permutation table.
- `NoiseGenerator::seed` (`noise_generator.rs`): Return the current seed value.
- `NoiseGenerator::perlin_1d` (`noise_generator.rs`): Return 1-D Perlin noise in approximately `[-1, 1]`.
- `NoiseGenerator::perlin_2d` (`noise_generator.rs`): Return 2-D Perlin noise in approximately `[-1, 1]`.
- `NoiseGenerator::perlin_3d` (`noise_generator.rs`): Return 3-D Perlin noise in approximately `[-1, 1]`.
- `NoiseGenerator::perlin_4d` (`noise_generator.rs`): Return 4-D Perlin noise in approximately `[-1, 1]` via 16-corner trilinear interpolation.
- `NoiseGenerator::simplex_1d` (`noise_generator.rs`): Return 1-D Simplex noise in approximately `[-1, 1]`.
- `NoiseGenerator::simplex_2d` (`noise_generator.rs`): Return 2-D Simplex noise in approximately `[-1, 1]`.
- `NoiseGenerator::simplex_3d` (`noise_generator.rs`): Return 3-D Simplex noise in approximately `[-1, 1]`.
- `NoiseGenerator::worley_2d` (`noise_generator.rs`): Return 2-D Worley (cell) noise using `dist` metric; returns F2-F1 when `f2` is true.
- `NoiseGenerator::worley_3d` (`noise_generator.rs`): Return 3-D Worley (cell) noise using `dist` metric; returns F2-F1 when `f2` is true.
- `NoiseGenerator::fbm` (`noise_generator.rs`): Return amplitude-normalised fBm noise summing `octaves` layers of `kind`.
- `NoiseGenerator::ridged` (`noise_generator.rs`): Return amplitude-normalised ridged multifractal noise summing `octaves` inverted absolute layers.
- `NoiseGenerator::turbulence` (`noise_generator.rs`): Return amplitude-normalised turbulence noise summing `octaves` absolute-value layers.
- `NoiseGenerator::warp_domain` (`noise_generator.rs`): Apply domain warping using Perlin offsets, returning the displaced coordinate pair.
- `NoiseGenerator::generate_map` (`noise_generator.rs`): Generate a `width × height` heightmap using `opts`; returns row-major `f64` values in `[-1, 1]`.
- `NoiseGenerator::generate_map_compute` (`noise_generator.rs`): Alias for `generate_map`; future versions may dispatch to a compute shader.
- `triangulate` (`polygon.rs`): Triangulate a simple polygon using the ear-clipping algorithm.
- `is_convex` (`polygon.rs`): Check if a polygon is convex.
- `polygon_clip` (`polygon.rs`): Clip a polygon against a single half-plane using the Sutherland-Hodgman algorithm.
- `polygon_intersection` (`polygon.rs`): Clips polygon `subject` against the convex polygon `clip` using the Sutherland-Hodgman algorithm and returns the intersection region.
- `polygon_union` (`polygon.rs`): Returns an approximation of the union of two convex polygons by computing the convex hull of all their vertices.
- `polygon_difference` (`polygon.rs`): Returns an approximation of the difference `A - B` by clipping `A` against the **reversed** edges of `B` (i.e.
- `RandomGenerator::new` (`random.rs`): Construct a generator with an arbitrary unseeded initial state (seed stored as 0).
- `RandomGenerator::with_seed` (`random.rs`): Construct a generator from an explicit `seed`.
- `RandomGenerator::random` (`random.rs`): Return a uniform random `f64` in `[0.0, 1.0)`.
- `RandomGenerator::random_int` (`random.rs`): Return a uniform random integer in the closed range `[min, max]`; returns `min` when `min >= max`.
- `RandomGenerator::random_float` (`random.rs`): Return a uniform random `f64` in `[min, max)`.
- `RandomGenerator::random_normal` (`random.rs`): Return a Gaussian-distributed `f64` with `mean` and `stddev` using Box-Muller transform.
- `RandomGenerator::set_seed` (`random.rs`): Re-seed the generator, resetting both the stored seed and the RNG state.
- `RandomGenerator::get_seed` (`random.rs`): Return the seed last set via `with_seed` or `set_seed`.
- `RandomGenerator::get_state` (`random.rs`): Serialise the current seed to a string for save-file persistence.
- `RandomGenerator::set_state` (`random.rs`): Restore the seed from a previously serialised state string; returns error on parse failure.
- `Rect::new` (`rect.rs`): Construct a Rect from top-left position and size.
- `Rect::center` (`rect.rs`): Return the center point of this rectangle.
- `Rect::area` (`rect.rs`): Return the area (width × height).
- `Rect::contains` (`rect.rs`): Return true when `(point_x, point_y)` lies inside or on the boundary of this rect.
- `Rect::intersects` (`rect.rs`): Return true when this rect overlaps `other` (touching edges count as overlap).
- `Rect::intersect` (`rect.rs`): Return the overlapping region of `self` and `other`; returns zero-size rect when disjoint.
- `Rect::union` (`rect.rs`): Return the smallest rect that contains both `self` and `other`.
- `Rect::from_center` (`rect.rs`): Construct a rect centered at `(cx, cy)` with given `w` and `h`.
- `Rect::from_points` (`rect.rs`): Return the tight bounding rect around a slice of `(x, y)` points; returns zero rect for empty slice.
- `RectPacker::new` (`rect_packing.rs`): Construct a packer with the given atlas `width × height` and uniform `padding`.
- `RectPacker::pack` (`rect_packing.rs`): Place a `w × h` rectangle with optional `id` label; returns placement or `None` when no space remains.
- `RectPacker::clear` (`rect_packing.rs`): Remove all placed rects and reset shelves, keeping atlas dimensions unchanged.
- `RectPacker::packed_rects` (`rect_packing.rs`): Return a slice of all successfully placed rects in insertion order.
- `RectPacker::occupancy` (`rect_packing.rs`): Return the fraction `[0,1]` of the atlas area covered by placed rects, excluding padding.
- `RectPacker::size` (`rect_packing.rs`): Return the atlas dimensions as `(width, height)` in pixels.
- `RectPacker::padding` (`rect_packing.rs`): Return the uniform padding value used during packing.
- `SpatialHash::new` (`spatial_hash.rs`): Construct an empty hash with the given uniform `cell_size`.
- `SpatialHash::cell_size` (`spatial_hash.rs`): Return the world-space cell size.
- `SpatialHash::item_count` (`spatial_hash.rs`): Return the number of items currently registered.
- `SpatialHash::insert` (`spatial_hash.rs`): Register or replace item `id` with AABB `(x, y, w, h)`, inserting it into all overlapping cells.
- `SpatialHash::remove` (`spatial_hash.rs`): Remove item `id` from all grid cells and delete it.
- `SpatialHash::update` (`spatial_hash.rs`): Replace item `id`'s AABB; equivalent to `insert` (re-registers in new cells).
- `SpatialHash::clear` (`spatial_hash.rs`): Remove all items and clear all cell buckets.
- `SpatialHash::query_rect` (`spatial_hash.rs`): Return ids of all items whose AABB overlaps the query rectangle, deduplicated.
- `SpatialHash::query_circle` (`spatial_hash.rs`): Return ids of all items whose AABB overlaps the circle, verified by nearest-point distance.
- `SpatialHash::query_segment` (`spatial_hash.rs`): Return ids of all items whose AABB the segment (x1,y1)-(x2,y2) passes through, using a slab test.
- `Mat3x3::identity` (`sphere.rs`): Return the identity matrix.
- `Mat3x3::from_cols` (`sphere.rs`): Construct a matrix from three column arrays.
- `Mat3x3::mul_vec` (`sphere.rs`): Multiply this matrix by column vector `v`.
- `Mat3x3::mul_mat` (`sphere.rs`): Return the product of this matrix and `other`.
- `lat_lon_to_unit` (`sphere.rs`): Convert (latitude_deg, longitude_deg) on the unit sphere to a 3D unit vector.
- `unit_to_lat_lon` (`sphere.rs`): Inverse of `lat_lon_to_unit`.
- `great_circle_distance` (`sphere.rs`): Great-circle distance in radians between two lat/lon points on a unit sphere.
- `great_circle_path` (`sphere.rs`): Sample `n` points along the great circle between two lat/lon endpoints.
- `ray_sphere_intersect` (`sphere.rs`): Rayâ€“sphere intersection.
- `axial_tilt_mat` (`sphere.rs`): Rotation matrix around the X axis (axial-tilt convention).
- `rot_x` (`sphere.rs`): Rotation about the X axis by `angle_deg` degrees.
- `rot_y` (`sphere.rs`): Rotation about the Y axis (longitude / orbit yaw) by `angle_deg` degrees.
- `rot_z` (`sphere.rs`): Rotation about the Z axis by `angle_deg` degrees.
- `CatmullRomSpline::new` (`spline.rs`): Construct a spline from a Vec of `(x, y)` control points.
- `CatmullRomSpline::sample` (`spline.rs`): Sample the full spline at normalized parameter `t` in `[0,1]`, mapping to the appropriate segment.
- `CatmullRomSpline::sample_segment` (`spline.rs`): Sample segment `seg` at local parameter `t` in `[0,1]` using 4-point Catmull-Rom weights.
- `CatmullRomSpline::len` (`spline.rs`): Return the number of control points.
- `CatmullRomSpline::is_empty` (`spline.rs`): Return true when the spline has no control points.
- `CatmullRomSpline::add_point` (`spline.rs`): Append a control point to the end of the spline.
- `CatmullRomSpline::remove_point` (`spline.rs`): Remove and return the control point at `index`, or `None` when out of range.
- `HermiteSpline::new` (`spline.rs`): Construct a Hermite segment from endpoints `p0`, `p1` and tangents `m0`, `m1`.
- `HermiteSpline::sample` (`spline.rs`): Sample the segment at `t` in `[0,1]` using Hermite basis polynomials.
- `Transform::new` (`transform.rs`): Return an identity transform.
- `Transform::from_components` (`transform.rs`): Construct a transform from position, rotation, scale, origin offset, and shear components.
- `Transform::translate` (`transform.rs`): Post-multiply a translation by `(dx, dy)` and return `&mut self` for chaining.
- `Transform::rotate` (`transform.rs`): Post-multiply a rotation by `angle` radians and return `&mut self` for chaining.
- `Transform::scale` (`transform.rs`): Post-multiply a non-uniform scale by `(sx, sy)` and return `&mut self` for chaining.
- `Transform::shear` (`transform.rs`): Post-multiply a shear by `(kx, ky)` and return `&mut self` for chaining.
- `Transform::reset` (`transform.rs`): Reset to identity and return `&mut self` for chaining.
- `Transform::set_transformation` (`transform.rs`): Replace this transform with a fresh one built from the given SRT+origin+shear components.
- `Transform::transform_point` (`transform.rs`): Apply this transform to `(x, y)` and return the resulting point.
- `Transform::inverse_transform_point` (`transform.rs`): Apply the inverse of this transform to `(x, y)` and return the resulting point.
- `Transform::inverse` (`transform.rs`): Return a new transform that is the matrix inverse of this one.
- `Transform::matrix` (`transform.rs`): Return a reference to the underlying Mat3.
- `Transform::decompose` (`transform.rs`): Decompose into `(tx, ty, rotation_rad, sx, sy)`; shear is not separated.
- `Tween::new` (`tween.rs`): Create a new Tween with the given `duration` (seconds) and named easing; falls back to linear when name is unknown.
- `Tween::add_value` (`tween.rs`): Register a `(start, target)` channel and return its index.
- `Tween::update` (`tween.rs`): Advance the clock by `dt` seconds; returns true when the tween has completed.
- `Tween::get_value` (`tween.rs`): Return the interpolated value for channel `index`; returns 0.0 for out-of-range index.
- `Tween::get_all_values` (`tween.rs`): Return interpolated values for all registered channels.
- `Tween::reset` (`tween.rs`): Reset the clock to zero without clearing channels.
- `Tween::set_time` (`tween.rs`): Set the clock to a specific time `t`, clamped to `[0, duration]`.
- `Tween::is_complete` (`tween.rs`): Return true when the clock has reached or passed the duration.
- `Tween::value_count` (`tween.rs`): Return the number of registered value channels.
- `Tween::easing_name` (`tween.rs`): Return the easing name string this tween was constructed with.
- `Tween::duration` (`tween.rs`): Return the total duration in seconds.
- `Tween::clock` (`tween.rs`): Return the current elapsed clock time in seconds.
- `Vec2::new` (`vec2.rs`): Construct a new Vec2 from `x` and `y` components.
- `Vec2::zero` (`vec2.rs`): Return the zero vector; alias for `Vec2::ZERO`.
- `Vec2::splat` (`vec2.rs`): Construct a Vec2 with both components set to `v`.
- `Vec2::dot` (`vec2.rs`): Return the dot product of `self` and `other`.
- `Vec2::length` (`vec2.rs`): Return the Euclidean length of this vector.
- `Vec2::length_squared` (`vec2.rs`): Return the squared length; cheaper than `length()` when only comparison is needed.
- `Vec2::normalize` (`vec2.rs`): Return a unit-length copy; returns self unchanged when length is zero.
- `Vec2::distance` (`vec2.rs`): Return the Euclidean distance from `self` to `other`.
- `Vec2::lerp` (`vec2.rs`): Linearly interpolate from `self` to `other` by scalar `t`.
- `Vec2::angle` (`vec2.rs`): Return the angle of this vector in radians (atan2 of y over x).
- `Vec2::rotate` (`vec2.rs`): Return this vector rotated by `angle` radians counter-clockwise.
- `Vec2::perpendicular` (`vec2.rs`): Return the left-perpendicular vector (-y, x).
- `Vec2::cross` (`vec2.rs`): Return the 2D cross product (scalar z-component of the 3D cross product).
- `Vec2::from_angle` (`vec2.rs`): Return a unit direction vector for the given angle in radians.
- `Vec2::reflect` (`vec2.rs`): Return this vector reflected across a surface with the given unit `normal`.
- `Vec3::new` (`vec3.rs`): Construct a Vec3 from `x`, `y`, `z`.
- `Vec3::zero` (`vec3.rs`): Return the zero vector (0, 0, 0).
- `Vec3::one` (`vec3.rs`): Return the unit vector (1, 1, 1).
- `Vec3::splat` (`vec3.rs`): Construct a Vec3 with all components set to `v`.
- `Vec3::dot` (`vec3.rs`): Return the dot product of `self` and `other`.
- `Vec3::cross` (`vec3.rs`): Return the cross product of `self` × `other`.
- `Vec3::length` (`vec3.rs`): Return the Euclidean length of this vector.
- `Vec3::length_squared` (`vec3.rs`): Return the squared length; avoids a sqrt when only comparison is needed.
- `Vec3::normalize` (`vec3.rs`): Return a unit-length copy; returns zero vector when length is below 1e-7.
- `Vec3::lerp` (`vec3.rs`): Linearly interpolate from `self` to `other` by factor `t`.
- `Vec3::distance` (`vec3.rs`): Return the Euclidean distance from `self` to `other`.
- `Vec3::project` (`vec3.rs`): Return the projection of `self` onto `onto`; returns zero vector when `onto` is near-zero.
- `Vec3::reflect` (`vec3.rs`): Return this vector reflected across a surface with the given unit `normal`.
- `voronoi_from_points` (`voronoi.rs`): Compute the Voronoi diagram for `points`.

## Lua API Reference

- Binding path(s): `src/lua_api/math_api.rs`
- Namespace: `lurek.math`

### Module Functions
- `lurek.math.newRandomGenerator`: Creates a deterministic random generator with an optional seed.
- `lurek.math.newTransform`: Creates a 2D transform. All components are optional; omitting all returns an identity transform.
- `lurek.math.newBezierCurve`: Creates a Bezier curve from a flat point table.
- `lurek.math.newTween`: Creates a tween with a duration and optional easing name.
- `lurek.math.newSpatialHash`: Creates a spatial hash index with a cell size.
- `lurek.math.newNoiseGenerator`: Creates a procedural noise generator with an optional seed.
- `lurek.math.newRectPacker`: Creates a rectangle packer. This function is exposed to Lua scripts.
- `lurek.math.perlin2d`: Samples stateless 2D Perlin noise.
- `lurek.math.perlin3d`: Samples stateless 3D Perlin noise.
- `lurek.math.simplex2d`: Samples stateless 2D simplex noise.
- `lurek.math.fbm`: Samples stateless fractal Brownian motion noise.
- `lurek.math.applyEasing`: Applies a named easing function to a normalized value.
- `lurek.math.linear`: Applies linear easing. This function is exposed to Lua scripts.
- `lurek.math.inQuad`: Applies quadratic ease-in. This function is exposed to Lua scripts.
- `lurek.math.outQuad`: Applies quadratic ease-out. This function is exposed to Lua scripts.
- `lurek.math.inOutQuad`: Applies quadratic ease-in-out. This function is exposed to Lua scripts.
- `lurek.math.inCubic`: Applies cubic ease-in. This function is exposed to Lua scripts.
- `lurek.math.outCubic`: Applies cubic ease-out. This function is exposed to Lua scripts.
- `lurek.math.inOutCubic`: Applies cubic ease-in-out. This function is exposed to Lua scripts.
- `lurek.math.inQuart`: Applies quartic ease-in. This function is exposed to Lua scripts.
- `lurek.math.outQuart`: Applies quartic ease-out. This function is exposed to Lua scripts.
- `lurek.math.inOutQuart`: Applies quartic ease-in-out. This function is exposed to Lua scripts.
- `lurek.math.inSine`: Applies sine ease-in. This function is exposed to Lua scripts.
- `lurek.math.outSine`: Applies sine ease-out. This function is exposed to Lua scripts.
- `lurek.math.inOutSine`: Applies sine ease-in-out. This function is exposed to Lua scripts.
- `lurek.math.inExpo`: Applies exponential ease-in. This function is exposed to Lua scripts.
- `lurek.math.outExpo`: Applies exponential ease-out. This function is exposed to Lua scripts.
- `lurek.math.inOutExpo`: Applies exponential ease-in-out.
- `lurek.math.inElastic`: Applies elastic ease-in. This function is exposed to Lua scripts.
- `lurek.math.outElastic`: Applies elastic ease-out. This function is exposed to Lua scripts.
- `lurek.math.outBounce`: Applies bounce ease-out. This function is exposed to Lua scripts.
- `lurek.math.inBounce`: Applies bounce ease-in. This function is exposed to Lua scripts.
- `lurek.math.inBack`: Applies back ease-in. This function is exposed to Lua scripts.
- `lurek.math.outBack`: Applies back ease-out. This function is exposed to Lua scripts.
- `lurek.math.inOutElastic`: Applies elastic ease-in-out. This function is exposed to Lua scripts.
- `lurek.math.inOutBounce`: Applies bounce ease-in-out. This function is exposed to Lua scripts.
- `lurek.math.inOutBack`: Applies back ease-in-out. This function is exposed to Lua scripts.
- `lurek.math.triangulate`: Triangulates a flat polygon point table.
- `lurek.math.isConvex`: Returns whether a flat polygon point table is convex.
- `lurek.math.angleBetween`: Returns the angle between two points.
- `lurek.math.circleContainsPoint`: Returns whether a circle contains a point.
- `lurek.math.circleIntersectsCircle`: Returns whether two circles intersect.
- `lurek.math.circleIntersectsLine`: Returns circle-line intersection state and hit points when present.
- `lurek.math.circleIntersectsSegment`: Returns circle-segment intersection state and hit points when present.
- `lurek.math.closestPointOnSegment`: Returns the closest point on a segment to an input point.
- `lurek.math.convexHull`: Computes the convex hull for a flat point table.
- `lurek.math.delaunayTriangulate`: Computes Delaunay triangles for a flat point table.
- `lurek.math.lineIntersect`: Returns intersection point for two infinite lines when present.
- `lurek.math.pointInPolygon`: Returns whether a point lies inside a polygon.
- `lurek.math.polygonArea`: Computes signed area for a flat polygon point table.
- `lurek.math.polygonCentroid`: Computes the centroid for a flat polygon point table.
- `lurek.math.segmentIntersectsSegment`: Returns whether two segments intersect and their intersection point when present.
- `lurek.math.bresenham`: Returns integer grid points along a Bresenham line.
- `lurek.math.rad`: Converts degrees to radians. This function is exposed to Lua scripts.
- `lurek.math.deg`: Converts radians to degrees. This function is exposed to Lua scripts.
- `lurek.math.sin`: Returns sine of an angle. This function is exposed to Lua scripts.
- `lurek.math.cos`: Returns cosine of an angle. This function is exposed to Lua scripts.
- `lurek.math.tan`: Returns tangent of an angle. This function is exposed to Lua scripts.
- `lurek.math.asin`: Returns arcsine of a value. This function is exposed to Lua scripts.
- `lurek.math.acos`: Returns arccosine of a value. This function is exposed to Lua scripts.
- `lurek.math.atan`: Returns arctangent or two-argument arctangent.
- `lurek.math.atan2`: Returns two-argument arctangent.
- `lurek.math.sqrt`: Returns square root of a value. This function is exposed to Lua scripts.
- `lurek.math.abs`: Returns absolute value. This function is exposed to Lua scripts.
- `lurek.math.floor`: Returns floor of a value. This function is exposed to Lua scripts.
- `lurek.math.ceil`: Returns ceiling of a value. This function is exposed to Lua scripts.
- `lurek.math.round`: Returns rounded value. This function is exposed to Lua scripts.
- `lurek.math.exp`: Returns exponential of a value. This function is exposed to Lua scripts.
- `lurek.math.log`: Returns natural logarithm or logarithm with a supplied base.
- `lurek.math.pow`: Raises a value to a power. This function is exposed to Lua scripts.
- `lurek.math.min`: Returns the smallest supplied value.
- `lurek.math.max`: Returns the largest supplied value.
- `lurek.math.fmod`: Returns floating-point remainder.
- `lurek.math.distance`: Returns Euclidean distance between two points.
- `lurek.math.distanceSq`: Returns squared Euclidean distance between two points.
- `lurek.math.random`: Returns a Lua math random value, optionally scaled to one or two bounds.
- `lurek.math.randomInt`: Returns a Lua math random integer in an inclusive range.
- `lurek.math.simplexNoise`: Samples 2D or 3D simplex noise. This function is exposed to Lua scripts.
- `lurek.math.vec2`: Creates a 2D vector. This function is exposed to Lua scripts.
- `lurek.math.Vec2`: Creates a 2D vector. This function is exposed to Lua scripts.
- `lurek.math.vec3`: Creates a 3D vector. This function is exposed to Lua scripts.
- `lurek.math.Vec3`: Creates a 3D vector. This function is exposed to Lua scripts.
- `lurek.math.catmullRom`: Creates a Catmull-Rom spline from point tables.
- `lurek.math.hermite`: Creates a Hermite spline from endpoints and tangents.
- `lurek.math.lerp`: Linearly interpolates between two values.
- `lurek.math.remap`: Remaps a value from one range to another.
- `lurek.math.clamp`: Clamps a value to a range. This function is exposed to Lua scripts.
- `lurek.math.sign`: Returns the sign of a value. This function is exposed to Lua scripts.
- `lurek.math.smoothstep`: Applies smoothstep interpolation between two edges.
- `lurek.math.inverseLerp`: Returns the interpolation factor of a value between two bounds.
- `lurek.math.rectUnion`: Returns the union rectangle for two rectangles.
- `lurek.math.rectFromCenter`: Creates a rectangle tuple from center coordinates and size.
- `lurek.math.polygonClip`: Clips a flat polygon point table against a plane.
- `lurek.math.aabbTree`: Creates an empty AABB tree. This function is exposed to Lua scripts.
- `lurek.math.newCircle`: Creates a circle primitive. This function is exposed to Lua scripts.
- `lurek.math.polygonIntersection`: Returns polygon intersection points for two polygon tables.
- `lurek.math.polygonUnion`: Returns polygon union points for two polygon tables.
- `lurek.math.polygonDifference`: Returns polygon difference points for two polygon tables.
- `lurek.math.geometricVoronoi`: Builds Voronoi cells from a polygon-style point table. (alias: `voronoi` preserved for backward compatibility)

### `LAabbTree` Methods
- `LAabbTree:insert`: Inserts an AABB by id. This method is available to Lua scripts.
- `LAabbTree:remove`: Removes an AABB by id. This method is available to Lua scripts.
- `LAabbTree:query`: Queries ids intersecting an AABB. This method is available to Lua scripts.
- `LAabbTree:queryPoint`: Queries ids containing a point. This method is available to Lua scripts.
- `LAabbTree:update`: Updates an AABB by id. This method is available to Lua scripts.
- `LAabbTree:contains`: Returns whether the tree contains an id.
- `LAabbTree:len`: Returns the number of items in the tree.
- `LAabbTree:isEmpty`: Returns whether the tree has no items.
- `LAabbTree:clear`: Clears all items from the tree. This method is available to Lua scripts.
- `LAabbTree:type`: Returns the Lua-visible type name for this AABB tree handle.
- `LAabbTree:typeOf`: Returns whether this AABB tree handle matches a supported type name.

### `LBezierCurve` Methods
- `LBezierCurve:evaluate`: Evaluates this curve at normalized parameter `t`.
- `LBezierCurve:render`: Returns sampled points along this curve.
- `LBezierCurve:getDerivative`: Returns the derivative curve for this Bezier curve.
- `LBezierCurve:getControlPoint`: Returns a control point by one-based index.
- `LBezierCurve:setControlPoint`: Sets a control point by one-based index.
- `LBezierCurve:insertControlPoint`: Inserts a control point, optionally before a one-based index.
- `LBezierCurve:removeControlPoint`: Removes a control point by one-based index.
- `LBezierCurve:getControlPointCount`: Returns the number of control points in this curve.
- `LBezierCurve:length`: Returns the approximate curve length.
- `LBezierCurve:evaluateAtDistance`: Evaluates this curve at an approximate distance along the curve.
- `LBezierCurve:translate`: Translates all control points. This method is available to Lua scripts.
- `LBezierCurve:rotate`: Rotates all control points around an origin.
- `LBezierCurve:scale`: Scales all control points around an origin.
- `LBezierCurve:type`: Returns the Lua-visible type name for this Bezier curve handle.
- `LBezierCurve:typeOf`: Returns whether this Bezier curve handle matches a supported type name.

### `LCatmullRom` Methods
- `LCatmullRom:sample`: Samples the spline at normalized parameter `t`.
- `LCatmullRom:sampleSegment`: Samples one spline segment at local parameter `t`.
- `LCatmullRom:len`: Returns the number of points in the spline.
- `LCatmullRom:addPoint`: Adds a point to the spline. This method is available to Lua scripts.
- `LCatmullRom:removePoint`: Removes a point by zero-based index and returns its coordinates.
- `LCatmullRom:type`: Returns the Lua-visible type name for this spline handle.
- `LCatmullRom:typeOf`: Returns whether this spline handle matches a supported type name.

### `LCircle` Methods
- `LCircle:area`: Returns this circle area. This method is available to Lua scripts.
- `LCircle:perimeter`: Returns this circle perimeter. This method is available to Lua scripts.
- `LCircle:contains`: Returns whether this circle contains a point.
- `LCircle:intersects`: Returns whether this circle intersects another circle.
- `LCircle:aabb`: Returns this circle axis-aligned bounding box.
- `LCircle:x`: Returns this circle center x coordinate.
- `LCircle:y`: Returns this circle center y coordinate.
- `LCircle:radius`: Returns this circle radius. This method is available to Lua scripts.
- `LCircle:type`: Returns the Lua-visible type name for this circle handle.
- `LCircle:typeOf`: Returns whether this circle handle matches a supported type name.

### `LHermite` Methods
- `LHermite:sample`: Samples the spline at normalized parameter `t`.
- `LHermite:type`: Returns the Lua-visible type name for this spline handle.
- `LHermite:typeOf`: Returns whether this spline handle matches a supported type name.

### `LNoiseGenerator` Methods
- `LNoiseGenerator:perlin1d`: Samples 1D Perlin noise. This method is available to Lua scripts.
- `LNoiseGenerator:perlin2d`: Samples 2D Perlin noise. This method is available to Lua scripts.
- `LNoiseGenerator:perlin3d`: Samples 3D Perlin noise. This method is available to Lua scripts.
- `LNoiseGenerator:perlin4d`: Samples 4D Perlin noise. This method is available to Lua scripts.
- `LNoiseGenerator:simplex1d`: Samples 1D simplex noise. This method is available to Lua scripts.
- `LNoiseGenerator:simplex2d`: Samples 2D simplex noise. This method is available to Lua scripts.
- `LNoiseGenerator:simplex3d`: Samples 3D simplex noise. This method is available to Lua scripts.
- `LNoiseGenerator:worley2d`: Samples 2D Worley noise. This method is available to Lua scripts.
- `LNoiseGenerator:worley3d`: Samples 3D Worley noise. This method is available to Lua scripts.
- `LNoiseGenerator:fbm`: Samples fractal Brownian motion noise.
- `LNoiseGenerator:ridged`: Samples ridged fractal noise. This method is available to Lua scripts.
- `LNoiseGenerator:turbulence`: Samples turbulence fractal noise.
- `LNoiseGenerator:warpDomain`: Samples domain-warped noise coordinates.
- `LNoiseGenerator:generateMap`: Generates a noise map and returns it as a flat array table.
- `LNoiseGenerator:generateMapCompute`: Generates a noise map through the compute backend and returns it as a flat array table.
- `LNoiseGenerator:getSeed`: Returns this noise generator seed.
- `LNoiseGenerator:setSeed`: Sets this noise generator seed. This method is available to Lua scripts.
- `LNoiseGenerator:type`: Returns the Lua-visible type name for this noise generator handle.
- `LNoiseGenerator:typeOf`: Returns whether this noise generator handle matches a supported type name.

### `LRandomGenerator` Methods
- `LRandomGenerator:random`: Returns a random floating-point value from the generator.
- `LRandomGenerator:randomFloat`: Returns a random floating-point value in a range.
- `LRandomGenerator:randomInt`: Returns a random integer in a range.
- `LRandomGenerator:randomNormal`: Returns a normally distributed random value.
- `LRandomGenerator:getSeed`: Returns this generator seed. This method is available to Lua scripts.
- `LRandomGenerator:setSeed`: Resets this generator to a seed value.
- `LRandomGenerator:getState`: Returns this generator serialized state string.
- `LRandomGenerator:setState`: Restores this generator from a serialized state string.
- `LRandomGenerator:type`: Returns the Lua-visible type name for this random generator handle.
- `LRandomGenerator:typeOf`: Returns whether this random generator handle matches a supported type name.

### `LRectPacker` Methods
- `LRectPacker:pack`: Attempts to pack a rectangle and returns its placement coordinates.
- `LRectPacker:clear`: Clears packed rectangles from this packer.
- `LRectPacker:occupancy`: Returns occupied area ratio. This method is available to Lua scripts.
- `LRectPacker:getPacked`: Returns packed rectangle records.

### `LSpatialHash` Methods
- `LSpatialHash:insert`: Inserts an item rectangle into the spatial hash.
- `LSpatialHash:update`: Updates an item rectangle in the spatial hash.
- `LSpatialHash:remove`: Removes an item from the spatial hash.
- `LSpatialHash:clear`: Clears all items from the spatial hash.
- `LSpatialHash:queryRect`: Returns ids intersecting a query rectangle.
- `LSpatialHash:queryCircle`: Returns ids intersecting a query circle.
- `LSpatialHash:querySegment`: Returns ids intersecting a query line segment.
- `LSpatialHash:getCellSize`: Returns the spatial hash cell size.
- `LSpatialHash:getItemCount`: Returns the number of items in the spatial hash.
- `LSpatialHash:type`: Returns the Lua-visible type name for this spatial hash handle.
- `LSpatialHash:typeOf`: Returns whether this spatial hash handle matches a supported type name.

### `LTransform` Methods
- `LTransform:translate`: Applies a translation to this transform.
- `LTransform:rotate`: Applies a rotation to this transform.
- `LTransform:scale`: Applies scale to this transform. This method is available to Lua scripts.
- `LTransform:shear`: Applies shear to this transform. This method is available to Lua scripts.
- `LTransform:reset`: Resets this transform to identity.
- `LTransform:setTransformation`: Replaces this transform from position, rotation, scale, origin, and shear components.
- `LTransform:transformPoint`: Transforms a point by this transform.
- `LTransform:inverseTransformPoint`: Transforms a point by this transform's inverse.
- `LTransform:inverse`: Returns this transform's inverse.
- `LTransform:clone`: Returns a copy of this transform. This method is available to Lua scripts.
- `LTransform:getMatrix`: Returns this transform matrix as a flat array table.
- `LTransform:decompose`: Decomposes this transform into component values.
- `LTransform:type`: Returns the Lua-visible type name for this transform handle.
- `LTransform:typeOf`: Returns whether this transform handle matches a supported type name.

### `LTween` Methods
- `LTween:update`: Advances the tween clock and returns whether it is complete.
- `LTween:reset`: Resets the tween clock to the beginning.
- `LTween:getValue`: Returns one tween value by one-based index or all values when no index is provided.
- `LTween:getAllValues`: Returns all current tween values. This method is available to Lua scripts.
- `LTween:isComplete`: Returns whether this tween is complete.
- `LTween:getValueCount`: Returns the number of values animated by this tween.
- `LTween:getEasingName`: Returns this tween easing function name.
- `LTween:getDuration`: Returns this tween duration. This method is available to Lua scripts.
- `LTween:getTime`: Returns this tween clock time. This method is available to Lua scripts.
- `LTween:getClock`: Returns this tween clock time. This method is available to Lua scripts.
- `LTween:setTime`: Sets this tween clock time. This method is available to Lua scripts.
- `LTween:set`: Sets this tween clock time. This method is available to Lua scripts.
- `LTween:addValue`: Adds a value track to this tween. This method is available to Lua scripts.
- `LTween:type`: Returns the Lua-visible type name for this tween handle.
- `LTween:typeOf`: Returns whether this tween handle matches a supported type name.

### `LVec2` Methods
- `LVec2:dot`: Returns the dot product with another vector.
- `LVec2:length`: Returns this vector length. This method is available to Lua scripts.
- `LVec2:x`: Returns this vector x component. This method is available to Lua scripts.
- `LVec2:y`: Returns this vector y component. This method is available to Lua scripts.
- `LVec2:lengthSquared`: Returns this vector squared length.
- `LVec2:normalize`: Returns a normalized copy of this vector.
- `LVec2:normalized`: Returns a normalized copy of this vector.
- `LVec2:lerp`: Returns a vector interpolated toward another vector.
- `LVec2:distance`: Returns distance to another vector.
- `LVec2:angle`: Returns this vector angle. This method is available to Lua scripts.
- `LVec2:rotate`: Returns this vector rotated by an angle.
- `LVec2:perpendicular`: Returns a perpendicular vector. This method is available to Lua scripts.
- `LVec2:cross`: Returns the scalar 2D cross product with another vector.
- `LVec2:fromAngle`: Creates a unit vector from an angle.
- `LVec2:reflect`: Returns this vector reflected around a normal vector.
- `LVec2:type`: Returns the Lua-visible type name for this vector handle.
- `LVec2:typeOf`: Returns whether this vector handle matches a supported type name.

### `LVec3` Methods
- `LVec3:length`: Returns this vector length. This method is available to Lua scripts.
- `LVec3:lengthSquared`: Returns this vector squared length.
- `LVec3:normalize`: Returns a normalized copy of this vector.
- `LVec3:dot`: Returns the dot product with another vector.
- `LVec3:cross`: Returns the 3D cross product with another vector.
- `LVec3:lerp`: Returns a vector interpolated toward another vector.
- `LVec3:distance`: Returns distance to another vector.
- `LVec3:add`: Returns the sum with another vector.
- `LVec3:sub`: Returns the difference from another vector.
- `LVec3:scale`: Returns this vector multiplied by a scalar.
- `LVec3:splat`: Creates a vector with all components set to one value.
- `LVec3:type`: Returns the Lua-visible type name for this vector handle.
- `LVec3:typeOf`: Returns whether this vector handle matches a supported type name.

### Vec2 and Vec3 Construction and Usage

#### Constructors

| Function | Params | Returns |
|----------|--------|---------|
| `lurek.math.vec2(x, y)` | `x: number`, `y: number` | `LVec2` |
| `lurek.math.Vec2(x, y)` | same | `LVec2` (alias) |
| `lurek.math.vec3(x, y, z)` | `x: number`, `y: number`, `z: number` | `LVec3` |
| `lurek.math.Vec3(x, y, z)` | same | `LVec3` (alias) |

Fields are readable and writable directly on the handle: `v.x`, `v.y` (and `v.z` for `LVec3`).

#### LVec2 method signatures

| Method | Params | Returns | Notes |
|--------|--------|---------|-------|
| `v:length()` | — | `number` | Euclidean length. |
| `v:lengthSquared()` | — | `number` | Squared length; cheaper for comparisons. |
| `v:normalize()` | — | `LVec2` | Returns a new unit-length vector. |
| `v:dot(other)` | `other: LVec2` | `number` | Dot product. |
| `v:cross(other)` | `other: LVec2` | `number` | Scalar 2D cross product (z-component of 3D cross). |
| `v:distance(other)` | `other: LVec2` | `number` | Euclidean distance to `other`. |
| `v:lerp(other, t)` | `other: LVec2`, `t: number` | `LVec2` | Linear interpolation by factor `t ∈ [0,1]`. |
| `v:angle()` | — | `number` | Angle in radians (`atan2(y, x)`). |
| `v:rotate(angle)` | `angle: number` | `LVec2` | Rotated copy, `angle` in radians. |
| `v:perpendicular()` | — | `LVec2` | Left-perpendicular: returns `(-y, x)`. |
| `v:reflect(normal)` | `normal: LVec2` | `LVec2` | Reflection across a unit normal vector. |
| `v:fromAngle(radians)` | `radians: number` | `LVec2` | Static constructor: unit direction from angle. |

Arithmetic operators: `v1 + v2`, `v1 - v2`, `v * scalar`, `-v` (negate), `v1 == v2`.

```lua
local pos = lurek.math.vec2(100, 200)
local vel = lurek.math.vec2(3, -1)
pos = pos + vel                  -- move by velocity
local speed = vel:length()       -- scalar speed
local dir   = vel:normalize()    -- unit direction
local ahead = pos + dir * 50     -- point 50 units ahead
```

#### LVec3 method signatures

| Method | Params | Returns | Notes |
|--------|--------|---------|-------|
| `v:length()` | — | `number` | Euclidean length. |
| `v:lengthSquared()` | — | `number` | Squared length; cheaper for comparisons. |
| `v:normalize()` | — | `LVec3` | Returns a new unit-length vector. |
| `v:dot(other)` | `other: LVec3` | `number` | Dot product. |
| `v:cross(other)` | `other: LVec3` | `LVec3` | 3D cross product. |
| `v:distance(other)` | `other: LVec3` | `number` | Euclidean distance. |
| `v:lerp(other, t)` | `other: LVec3`, `t: number` | `LVec3` | Linear interpolation. |
| `v:add(other)` | `other: LVec3` | `LVec3` | Sum (also available as `v1 + v2`). |
| `v:sub(other)` | `other: LVec3` | `LVec3` | Difference (also `v1 - v2`). |
| `v:scale(s)` | `s: number` | `LVec3` | Scalar multiply (also `v * s`). |
| `v:splat(val)` | `val: number` | `LVec3` | Static constructor: all three components equal to `val`. |

Fields (readable and writable): `v.x`, `v.y`, `v.z`.

```lua
local normal = lurek.math.vec3(0, 1, 0)
local light  = lurek.math.vec3(1, 1, -1):normalize()
local intensity = normal:dot(light)   -- Lambertian diffuse factor
```

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- Keep this module reference synchronized with `src/math/` and any matching Lua bindings.
- Idea-file clarification: lightweight vector helpers already live at `lurek.math.vec2`/`lurek.math.Vec2` and `lurek.math.vec3`/`lurek.math.Vec3`. They return Lua-visible handles for position, direction, normal, interpolation, and distance math; they are not a separate broad linear-algebra namespace.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.

### New in 0.14.1

- `src/math/voronoi.rs` — Bowyer–Watson Delaunay triangulation and Voronoi dual.
  - `VoronoiCell { site: (f32, f32), vertices: Vec<(f32, f32)> }` — one cell per site.
  - `voronoi_from_points(points: &[(f32, f32)]) -> Vec<VoronoiCell>` — near-duplicate deduplication, CCW vertex ordering.
  - Lua: `lurek.math.geometricVoronoi({{x,y},…})` → `{{site={x,y}, vertices={{x,y},…}},…}`. (alias: `lurek.math.voronoi` preserved for backward compatibility)
  - Re-exported as `crate::math::VoronoiCell` and `crate::math::voronoi_from_points`.

### New in 0.15.0

**Free functions (scalar utilities)**
- `lurek.math.sign(v)` — Returns `1`, `-1`, or `0` based on the sign of `v`.
- `lurek.math.smoothstep(e0, e1, x)` — Hermite interpolation clamped to `[0, 1]`.
- `lurek.math.inverseLerp(a, b, v)` — Inverse of lerp: returns `t` such that `lerp(a, b, t) == v`.

**Rect constructors**
- `lurek.math.rectUnion(x1, y1, w1, h1, x2, y2, w2, h2)` — Returns the bounding union rect `x, y, w, h`.
- `lurek.math.rectFromCenter(cx, cy, w, h)` — Returns a rect whose centre is `(cx, cy)`, returning `x, y, w, h`.

**Vec2 additions**
- `Vec2.fromAngle(radians)` — Creates a unit Vec2 pointing in the given direction (class function).
- `Vec2:reflect(normal)` — Returns this vector reflected about the given unit normal Vec2.

**Vec3 additions**
- `Vec3.splat(v)` — Creates a Vec3 with all components equal to `v` (class function).

**Transform additions**
- `Transform:decompose()` — Returns five numbers `tx, ty, angle, scale_x, scale_y` extracted from the matrix.

**Easing additions**
- `lurek.math.inOutElastic(t)` — In-out elastic ease. Symmetric: `f(1-t) == 1 - f(t)`.
- `lurek.math.inOutBounce(t)` — In-out bounce ease.
- `lurek.math.inOutBack(t)` — In-out back (overshoot) ease.

**CatmullRomSpline mutations**
- `CatmullRomSpline:addPoint(x, y)` — Appends a control point to the spline.
- `CatmullRomSpline:removePoint(index)` — Removes the control point at the given 1-based index. Out-of-range is a no-op.

---

> **Note:** Color types have moved to the standalone `color` module. See [color.md](color.md).
