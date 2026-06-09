# math

## TL;DR

- Provides vectors, matrices, spatial indexes (AABB tree and spatial hash), and polygon geometry.
- Supports splines, Bézier curves, tweens with easing, seedable randoms, and loot pity-trackers.
- Centralizes core mathematical formulas to guarantee consistent, drift-free engine behaviors.

## General Info

- Module group: `Foundations`
- Source path: `src/math/`
- Binding: `src/lua_api/math_api.rs`
- Namespace: `lurek.math`
- Lua API surface: `99` functions, `19` types, `164` methods
- Rust test path(s): tests/rust/unit/math_tests.rs; inline tests in src/math/vec2.rs, src/math/vec3.rs, src/math/mat3.rs, src/math/rect.rs, src/math/bezier.rs, src/math/easing.rs, src/math/geometry.rs, src/math/noise_functions.rs, src/math/noise_generator.rs, src/math/polygon.rs, src/math/random.rs, src/math/spatial_hash.rs, src/math/transform.rs, src/math/tween.rs, src/math/voronoi.rs, src/math/mod.rs; sibling test file src/math/aabb_tree_tests.rs; inline tests in src/math/spline.rs
- Lua test path(s): tests/lua/unit/test_math.lua

## Summary

- This module gives users the shared numeric foundation used by movement, collision, rendering, AI, and procedural systems.
- Vec2 and Vec3 types provide common vector operations for positions, directions, and velocity calculations.
- Mat3 and transform utilities support 2D affine composition for translation, rotation, scale, and shear workflows.
- Scalar helpers cover clamp, remap, interpolation, inverse interpolation, and smoothstep-style value shaping.
- Easing utilities provide standardized motion curves for animation and UI transitions.
- Tween helpers support consistent timing math for value progression over runtime updates.
- Bézier and spline primitives support authored paths and smooth camera or object trajectories.
- Geometry helpers support line tests, segment queries, and circle interactions.
- Rectangle and circle primitives provide reliable containment and overlap checks.
- Polygon operations support hulls, winding, triangulation, and shape analysis use cases.
- Delaunay and Voronoi utilities support procedural region generation and spatial partition workflows.
- AABB tree support enables dynamic broad-phase spatial queries over moving entities.
- Spatial hash support enables efficient neighborhood and occupancy-style lookups.
- Both spatial indices are useful for reducing expensive all-to-all collision checks.
- Random utilities provide deterministic seeded generation for reproducible simulation and content workflows.
- Gaussian and uniform sampling helpers support varied procedural distributions.
- Loot table support implements weighted sampling with efficient runtime draws.
- Pity-tracking helpers support predictable reward behavior over repeated rolls.
- Math functions are designed to remain deterministic and side-effect free.
- This keeps subsystems aligned on shared numeric semantics.
- It reduces subtle divergence between physics, rendering, and gameplay calculations.
- The module is useful for both low-level engine code and high-level gameplay scripts.
- It supports debugging by making core geometric and numeric operations explicit and reusable.
- It improves maintainability by avoiding ad-hoc reimplementation of common formulas.
- Consistent helper APIs reduce cognitive load when switching between engine domains.
- Curve and interpolation features support expressive but controlled runtime motion.
- Spatial structures support scalability as world density and actor counts grow.
- Deterministic random support helps test reproducibility and save/load continuity.
- The module acts as a single source for core math contracts used throughout the project.
- Users can build advanced systems without importing separate math stacks.
- It bridges authored data and runtime simulation with consistent numeric behavior.
- It is especially valuable in projects with pathfinding, tactics, and procedural generation layers.
- Shared conventions improve cross-team collaboration and bug diagnosis.
- The practical result is fewer numeric edge-case regressions.
- It also improves performance by reusing optimized foundational primitives.
- Overall, this module is the backbone for reliable, composable engine mathematics.
- It underpins gameplay feel, simulation accuracy, and visual coherence.
- Users benefit from one coherent math vocabulary across all major subsystems.
- That coherence is critical for long-lived projects with many interacting systems.
- The module enables growth from simple prototypes to complex simulations.
- It keeps mathematical behavior predictable as feature complexity increases.
- In short, it is the engine's core quantitative infrastructure.

This module primarily collaborates with `globe`, `image`. Its responsibility should stay inside the Foundations group rather than absorb behavior owned by those neighbors.

## Imports

- `globe`: Imports or references `src/globe/`. Cross-group dependency from `Foundations` into `Feature Systems`.
- `image`: Imports or references `src/image/`. Cross-group dependency from `Foundations` into `Platform Services`.

## Files

### aabb_tree.rs

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

### bezier.rs

- Flexible Bézier curve utility for smooth motion paths and procedural shaping.
- Supports dynamic control points, clamped evaluation, and partial-segment sampling.
- Provides tangent and derivative queries for orientation and velocity-aware effects.
- Can be transformed in place with translate, rotate, and scale operations.
- Designed for path authoring, easing-like shaping, and motion interpolation use cases.

### circle.rs

- 2D circle geometry primitive with center point and non-negative radius clamped on construction for collision and containment tests.
- Implements point-in-circle, circle-circle intersection, and AABB containment queries using distance comparisons for gameplay geometry.
- Computes area and perimeter values for numerical analysis enabling physics-based interactions and spatial reasoning in game logic.
- Provides center accessor and bounding-box computation supporting rendering, camera framing, and spatial query integration.

### easing.rs

- Comprehensive easing function library supporting in/out/in-out variants across quadratic, cubic, quartic, sine, exponential, and elastic motion families.
- Implements normalized [0,1] input parameter curves producing normalized output ranges enabling composition into tween and animation systems.
- Handles edge clamping for exponential and elastic curves preventing invalid outputs at boundaries while supporting smooth S-curve acceleration patterns.
- Provides linear identity passthrough and symmetric in-out variants enabling data-driven animation selection from configuration files.
- Standardizes easing semantics across animation interpolation enabling consistent motion timing and response characteristics in gameplay animations.
- Supports all common Easing.net function families used by game engines and animation libraries for broad compatibility and predictable behavior.

### facade.rs

- Small scalar helper layer for interpolation and numeric remapping.
- Groups lerp, inverse lerp, remap, smoothstep, clamp, and sign behavior.
- Operates on f32 values only and stays side-effect free.
- Acts as the lightweight math front door for common numeric tasks.

### geometry.rs

- Standalone geometry toolbox for flat coordinate math and polygon routines.
- Covers circle, segment, line, and point queries used by gameplay systems.
- Computes polygon area, centroid, convex hull, and point inclusion tests.
- Provides line rasterization for grid traversal and tile-based effects.
- Includes Delaunay triangulation helpers for procedural meshes and Voronoi prep.
- Uses f32 for engine-facing work and f64 where triangulation precision matters.
- Exposes plain free functions with no shape ownership or scene coupling.
- Serves as the shared low-level layer for collision, map, and generation code.

### loot_table.rs

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

### mat3.rs

- Row-major 3x3 matrix for 2D affine transforms and coordinate mapping.
- Builds identity, translation, rotation, scale, and shear matrices.
- Supports inversion and multiplication for transform composition.
- Maps points through a compact linear algebra core.
- Serves as the numeric backbone for higher-level 2D transform code.

### mod.rs

- Core math module wiring the vector, matrix, shape, curve, and utility submodules.
- Collects the primitives that other engine systems build on for motion, collision, and mapping.
- Groups spatial structures with interpolation, geometry, and procedural helpers under one namespace.
- Keeps the public math surface compact while exposing the full foundation layer.

### polygon.rs

- Polygon toolkit for clipping, hull building, triangulation, and winding cleanup.
- Handles simple and concave shapes with routines aimed at gameplay geometry.
- Provides intersection and boolean-style operations for shape processing.
- Computes signed area and point-in-triangle tests for structural checks.
- Normalizes vertex order so downstream consumers can rely on consistent winding.
- Supplies the low-level machinery behind map, collision, and editor-style geometry flows.

### random.rs

- Seedable pseudo-random generator wrapper for deterministic gameplay and replay.
- Produces uniform integer, float, and Gaussian samples from one stateful source.
- Serializes and restores seed state so saves can resume the same sequence.
- Gives higher-level systems a simple random facade without exposing backend details.
- Fits any flow that needs reproducible chance, noise, or procedural variation.

### rect.rs

- Axis-aligned rectangle helper for layout, bounds, and collision checks.
- Stores top-left position plus size under the engine's y-down convention.
- Supports containment, overlap, union, and bounding-box construction.
- Offers both corner-based and center-based creation paths.
- Acts as the basic 2D box type used across spatial code.

### spatial_hash.rs

- Uniform-grid spatial hash for broad-phase collision and proximity search.
- Buckets moving bounds into cells so query cost follows local density, not world size.
- Supports insert, remove, update, and deduplicated multi-shape queries.
- Handles rectangle, circle, and segment probes with shared cell traversal logic.
- Uses slab-style segment tests for fast box intersection checks.
- Works best when many objects stay sparse across a large playfield.

### spline.rs

- Multi-segment spline helper for smooth interpolation across control points.
- Bridges Catmull-Rom and Hermite style curve handling under one shape.
- Supports normalized sampling across full paths or individual segments.
- Tracks control points dynamically so paths can be edited at runtime.
- Useful for motion trails, camera rails, and other smooth route logic.

### transform.rs

- Mutable 2D affine transform that accumulates position, rotation, scale, and shear.
- Wraps a 3x3 matrix so chained edits stay compact and composable.
- Exposes forward and inverse point mapping for world and local space conversion.
- Includes SRT decomposition for systems that need readable transform components.
- Bridges low-level matrix math with runtime spatial manipulation.

### vec2.rs

- Fundamental 2D float vector for position, velocity, direction, and offsets.
- Covers arithmetic, normalization, projection, and distance-style helpers.
- Adds rotation, reflection, and angle conversion support for gameplay math.
- Offers interpolation and unit-direction construction from radians.
- Serves as the common scalar pair used throughout the engine.

### vec3.rs

- 3D float vector for cross products, directions, and other compact spatial math.
- Provides arithmetic and geometric helpers for dot, cross, normalize, and reflection work.
- Supports projection, interpolation, distance, and length queries.
- Acts as the small 3D companion to the 2D math core.
- Useful for normals, ray direction math, and procedural inputs.

### voronoi.rs

- Voronoi cell builder from 2D point sets using incremental Delaunay construction.
- Produces closed polygonal cells with stable point deduplication and cleanup.
- Relies on circumcircle predicates to drive triangulation updates.
- Extracts boundary edges and orders vertices counter-clockwise for each region.
- Handles coincident sites gracefully instead of failing the whole diagram.
- Gives procedural generation and spatial partitioning code a ready-made diagram source.

## Lua API Ref

### Functions

- `lurek.math.Vec2(x, y) -> LVec2`: Creates a 2D vector. This function is exposed to Lua scripts.
- `lurek.math.Vec3(x, y, z) -> LVec3`: Creates a 3D vector. This function is exposed to Lua scripts.
- `lurek.math.aabbTree() -> LAabbTree`: Creates an empty AABB tree. This function is exposed to Lua scripts.
- `lurek.math.abs(x) -> number`: Returns absolute value. This function is exposed to Lua scripts.
- `lurek.math.acos(x) -> number`: Returns arccosine of a value. This function is exposed to Lua scripts.
- `lurek.math.angleBetween(x1, y1, x2, y2) -> number`: Returns the angle between two points.
- `lurek.math.applyEasing(name, t) -> number`: Applies a named easing function to a normalized value.
- `lurek.math.asin(x) -> number`: Returns arcsine of a value. This function is exposed to Lua scripts.
- `lurek.math.atan(y, x?) -> number`: Returns arctangent or two-argument arctangent.
- `lurek.math.atan2(y, x) -> number`: Returns two-argument arctangent.
- `lurek.math.bresenham(x1, y1, x2, y2) -> table`: Returns integer grid points along a Bresenham line.
- `lurek.math.catmullRom(points) -> LCatmullRom`: Creates a Catmull-Rom spline from point tables.
- `lurek.math.ceil(x) -> number`: Returns ceiling of a value. This function is exposed to Lua scripts.
- `lurek.math.circleContainsPoint(cx, cy, r, px, py) -> boolean`: Returns whether a circle contains a point.
- `lurek.math.circleIntersectsCircle(x1, y1, r1, x2, y2, r2) -> boolean`: Returns whether two circles intersect.
- `lurek.math.circleIntersectsLine(cx, cy, r, lx1, ly1, lx2, ly2) -> boolean`: Returns circle-line intersection state and hit points when present.
- `lurek.math.circleIntersectsSegment(cx, cy, r, sx1, sy1, sx2, sy2) -> boolean`: Returns circle-segment intersection state and hit points when present.
- `lurek.math.clamp(v, min, max) -> number`: Clamps a value to a range. This function is exposed to Lua scripts.
- `lurek.math.closestPointOnSegment(px, py, x1, y1, x2, y2) -> number`: Returns the closest point on a segment to an input point.
- `lurek.math.convexHull(pts) -> number[]`: Computes the convex hull for a flat point table.
- `lurek.math.cos(x) -> number`: Returns cosine of an angle. This function is exposed to Lua scripts.
- `lurek.math.cubicBezier(p1x, p1y, p2x, p2y, t) -> number`: Computes the CSS cubic-bezier Y value at input t (0..1).
- `lurek.math.deg(rad) -> number`: Converts radians to degrees. This function is exposed to Lua scripts.
- `lurek.math.delaunayTriangulate(pts) -> table`: Computes Delaunay triangles for a flat point table.
- `lurek.math.distance(x1, y1, x2, y2) -> number`: Returns Euclidean distance between two points.
- `lurek.math.distanceSq(x1, y1, x2, y2) -> number`: Returns squared Euclidean distance between two points.
- `lurek.math.easingNames() -> string[]`: Returns an array of all built-in easing function names.
- `lurek.math.exp(x) -> number`: Returns exponential of a value. This function is exposed to Lua scripts.
- `lurek.math.floor(x) -> number`: Returns floor of a value. This function is exposed to Lua scripts.
- `lurek.math.fmod(x, y) -> number`: Returns floating-point remainder.
- `lurek.math.hermite(p0x, p0y, p1x, p1y, m0x, m0y, m1x, m1y) -> LHermite`: Creates a Hermite spline from endpoints and tangents.
- `lurek.math.inBack(t) -> number`: Applies back ease-in. This function is exposed to Lua scripts.
- `lurek.math.inBounce(t) -> number`: Applies bounce ease-in. This function is exposed to Lua scripts.
- `lurek.math.inCubic(t) -> number`: Applies cubic ease-in. This function is exposed to Lua scripts.
- `lurek.math.inElastic(t) -> number`: Applies elastic ease-in. This function is exposed to Lua scripts.
- `lurek.math.inExpo(t) -> number`: Applies exponential ease-in. This function is exposed to Lua scripts.
- `lurek.math.inOutBack(t) -> number`: Applies back ease-in-out. This function is exposed to Lua scripts.
- `lurek.math.inOutBounce(t) -> number`: Applies bounce ease-in-out. This function is exposed to Lua scripts.
- `lurek.math.inOutCubic(t) -> number`: Applies cubic ease-in-out. This function is exposed to Lua scripts.
- `lurek.math.inOutElastic(t) -> number`: Applies elastic ease-in-out. This function is exposed to Lua scripts.
- `lurek.math.inOutExpo(t) -> number`: Applies exponential ease-in-out.
- `lurek.math.inOutQuad(t) -> number`: Applies quadratic ease-in-out. This function is exposed to Lua scripts.
- `lurek.math.inOutQuart(t) -> number`: Applies quartic ease-in-out. This function is exposed to Lua scripts.
- `lurek.math.inOutSine(t) -> number`: Applies sine ease-in-out. This function is exposed to Lua scripts.
- `lurek.math.inQuad(t) -> number`: Applies quadratic ease-in. This function is exposed to Lua scripts.
- `lurek.math.inQuart(t) -> number`: Applies quartic ease-in. This function is exposed to Lua scripts.
- `lurek.math.inSine(t) -> number`: Applies sine ease-in. This function is exposed to Lua scripts.
- `lurek.math.inverseLerp(a, b, v) -> number`: Returns the interpolation factor of a value between two bounds.
- `lurek.math.isConvex(pts) -> boolean`: Returns whether a flat polygon point table is convex.
- `lurek.math.lerp(a, b, t) -> number`: Linearly interpolates between two values.
- `lurek.math.lineIntersect(x1, y1, x2, y2, x3, y3, x4, y4) -> number`: Returns intersection point for two infinite lines when present.
- `lurek.math.linear(t) -> number`: Applies linear easing. This function is exposed to Lua scripts.
- `lurek.math.log(x, b?) -> number`: Returns natural logarithm or logarithm with a supplied base.
- `lurek.math.lootFromList(entries) -> LLootTable`: Creates a loot table from a Lua list of entry tables.
- `lurek.math.lootFromToml(path) -> LLootTable`: Loads a loot table from a TOML file path.
- `lurek.math.max(...) -> number`: Returns the largest supplied value.
- `lurek.math.min(...) -> number`: Returns the smallest supplied value.
- `lurek.math.newBezierCurve(points) -> LBezierCurve`: Creates a Bezier curve from a flat point table.
- `lurek.math.newCircle(x, y, radius) -> LCircle`: Creates a circle primitive. This function is exposed to Lua scripts.
- `lurek.math.newLootTable(opts?) -> LLootTable`: Creates a Walker-Vose alias-method loot table for O(1) weighted random sampling.
- `lurek.math.newPityTracker(target_id, threshold) -> LPityTracker`: Creates a pity tracker that primes after `threshold` consecutive misses of `target_id`.
- `lurek.math.newRandomGenerator(seed?) -> LRandomGenerator`: Creates a deterministic random generator with an optional seed.
- `lurek.math.newRectPacker(width, height, padding?) -> LRectPacker`: Creates a rectangle packer. This function is exposed to Lua scripts.
- `lurek.math.newSpatialHash(cell_size) -> LSpatialHash`: Creates a spatial hash index with a cell size.
- `lurek.math.newTransform(x?, y?, angle?, sx?, sy?, ox?, oy?, kx?, ky?) -> LTransform`: Creates a 2D transform. All components are optional; omitting all returns an identity transform.
- `lurek.math.newTween(duration, easing_name?) -> LTween`: Creates a tween with a duration and optional easing name.
- `lurek.math.outBack(t) -> number`: Applies back ease-out. This function is exposed to Lua scripts.
- `lurek.math.outBounce(t) -> number`: Applies bounce ease-out. This function is exposed to Lua scripts.
- `lurek.math.outCubic(t) -> number`: Applies cubic ease-out. This function is exposed to Lua scripts.
- `lurek.math.outElastic(t) -> number`: Applies elastic ease-out. This function is exposed to Lua scripts.
- `lurek.math.outExpo(t) -> number`: Applies exponential ease-out. This function is exposed to Lua scripts.
- `lurek.math.outQuad(t) -> number`: Applies quadratic ease-out. This function is exposed to Lua scripts.
- `lurek.math.outQuart(t) -> number`: Applies quartic ease-out. This function is exposed to Lua scripts.
- `lurek.math.outSine(t) -> number`: Applies sine ease-out. This function is exposed to Lua scripts.
- `lurek.math.pointInPolygon(pts, px, py) -> boolean`: Returns whether a point lies inside a polygon.
- `lurek.math.polygonArea(pts) -> number`: Computes signed area for a flat polygon point table.
- `lurek.math.polygonCentroid(pts) -> number`: Computes the centroid for a flat polygon point table.
- `lurek.math.polygonClip(pts, nx, ny, d) -> number[]`: Clips a flat polygon point table against a plane.
- `lurek.math.polygonDifference(a, b) -> number[]`: Returns polygon difference points for two polygon tables.
- `lurek.math.polygonIntersection(a, b) -> number[]`: Returns polygon intersection points for two polygon tables.
- `lurek.math.polygonUnion(a, b) -> number[]`: Returns polygon union points for two polygon tables.
- `lurek.math.pow(x, y) -> number`: Raises a value to a power. This function is exposed to Lua scripts.
- `lurek.math.rad(deg) -> number`: Converts degrees to radians. This function is exposed to Lua scripts.
- `lurek.math.random(a?, b?) -> number`: Returns a Lua math random value, optionally scaled to one or two bounds.
- `lurek.math.randomInt(lo, hi) -> integer`: Returns a Lua math random integer in an inclusive range.
- `lurek.math.rectFromCenter(cx, cy, w, h) -> number`: Creates a rectangle tuple from center coordinates and size.
- `lurek.math.rectUnion(x1, y1, w1, h1, x2, y2, w2, h2) -> number`: Returns the union rectangle for two rectangles.
- `lurek.math.remap(v, in_min, in_max, out_min, out_max) -> number`: Remaps a value from one range to another.
- `lurek.math.round(x) -> number`: Returns rounded value. This function is exposed to Lua scripts.
- `lurek.math.sampleWithPity(loot_table, pity) -> string`: Samples loot table with pity behavior: forced target when tracker is primed.
- `lurek.math.segmentIntersectsSegment(x1, y1, x2, y2, x3, y3, x4, y4) -> boolean`: Returns whether two segments intersect and their intersection point when present.
- `lurek.math.sign(v) -> number`: Returns the sign of a value. This function is exposed to Lua scripts.
- `lurek.math.sin(x) -> number`: Returns sine of an angle. This function is exposed to Lua scripts.
- `lurek.math.smoothstep(edge0, edge1, x) -> number`: Applies smoothstep interpolation between two edges.
- `lurek.math.sqrt(x) -> number`: Returns square root of a value. This function is exposed to Lua scripts.
- `lurek.math.tan(x) -> number`: Returns tangent of an angle. This function is exposed to Lua scripts.
- `lurek.math.triangulate(pts) -> table`: Triangulates a flat polygon point table.
- `lurek.math.vec2(x, y) -> LVec2`: Creates a 2D vector. This function is exposed to Lua scripts.
- `lurek.math.vec3(x, y, z) -> LVec3`: Creates a 3D vector. This function is exposed to Lua scripts.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LAabbTree Type

- Lua-side wrapper for an AABB tree spatial index.

##### Fields

- No documented fields.

##### Methods

- `LAabbTree:clear() -> nil`: Clears all items from the tree. This method is available to Lua scripts.
- `LAabbTree:contains(id) -> boolean`: Returns whether the tree contains an id.
- `LAabbTree:insert(id, min_x, min_y, max_x, max_y) -> nil`: Inserts an AABB by id. This method is available to Lua scripts.
- `LAabbTree:isEmpty() -> boolean`: Returns whether the tree has no items.
- `LAabbTree:len() -> integer`: Returns the number of items in the tree.
- `LAabbTree:query(min_x, min_y, max_x, max_y) -> integer[]`: Queries ids intersecting an AABB. This method is available to Lua scripts.
- `LAabbTree:queryPoint(x, y) -> integer[]`: Queries ids containing a point. This method is available to Lua scripts.
- `LAabbTree:remove(id) -> boolean`: Removes an AABB by id. This method is available to Lua scripts.
- `LAabbTree:type() -> string`: Returns the Lua-visible type name for this AABB tree handle.
- `LAabbTree:typeOf(name) -> boolean`: Returns whether this AABB tree handle matches a supported type name.
- `LAabbTree:update(id, min_x, min_y, max_x, max_y) -> boolean`: Updates an AABB by id. This method is available to Lua scripts.

#### LBezierCurve Type

- Lua-side wrapper for a Bezier curve.

##### Fields

- No documented fields.

##### Methods

- `LBezierCurve:evaluate(t) -> number`: Evaluates this curve at normalized parameter `t`.
- `LBezierCurve:evaluateAtDistance(distance, samples?) -> number`: Evaluates this curve at an approximate distance along the curve.
- `LBezierCurve:getControlPoint(index) -> number`: Returns a control point by one-based index.
- `LBezierCurve:getControlPointCount() -> integer`: Returns the number of control points in this curve.
- `LBezierCurve:getDerivative() -> LBezierCurve`: Returns the derivative curve for this Bezier curve.
- `LBezierCurve:insertControlPoint(x, y, index?) -> nil`: Inserts a control point, optionally before a one-based index.
- `LBezierCurve:length() -> number`: Returns the approximate curve length.
- `LBezierCurve:removeControlPoint(index) -> boolean`: Removes a control point by one-based index.
- `LBezierCurve:render(segments) -> table`: Returns sampled points along this curve.
- `LBezierCurve:rotate(angle, ox, oy) -> nil`: Rotates all control points around an origin.
- `LBezierCurve:scale(s, ox, oy) -> nil`: Scales all control points around an origin.
- `LBezierCurve:setControlPoint(index, x, y) -> boolean`: Sets a control point by one-based index.
- `LBezierCurve:translate(dx, dy) -> nil`: Translates all control points. This method is available to Lua scripts.
- `LBezierCurve:type() -> string`: Returns the Lua-visible type name for this Bezier curve handle.
- `LBezierCurve:typeOf(name) -> boolean`: Returns whether this Bezier curve handle matches a supported type name.

#### LBezierCurveRenderResult Type

- Generated result shape from @field tags.

##### Fields

- `x` (`number`): X.
- `y` (`number`): Y.

##### Methods

- No documented methods.

#### LCatmullRom Type

- Lua-side wrapper for a Catmull-Rom spline.

##### Fields

- No documented fields.

##### Methods

- `LCatmullRom:addPoint(x, y) -> nil`: Adds a point to the spline. This method is available to Lua scripts.
- `LCatmullRom:len() -> integer`: Returns the number of points in the spline.
- `LCatmullRom:removePoint(idx) -> number`: Removes a point by zero-based index and returns its coordinates.
- `LCatmullRom:sample(t) -> number`: Samples the spline at normalized parameter `t`.
- `LCatmullRom:sampleSegment(seg, t) -> number`: Samples one spline segment at local parameter `t`.
- `LCatmullRom:type() -> string`: Returns the Lua-visible type name for this spline handle.
- `LCatmullRom:typeOf(name) -> boolean`: Returns whether this spline handle matches a supported type name.

#### LCircle Type

- Lua-side wrapper for a circle primitive.

##### Fields

- No documented fields.

##### Methods

- `LCircle:aabb() -> number`: Returns this circle axis-aligned bounding box.
- `LCircle:area() -> number`: Returns this circle area. This method is available to Lua scripts.
- `LCircle:contains(px, py) -> boolean`: Returns whether this circle contains a point.
- `LCircle:intersects(other) -> boolean`: Returns whether this circle intersects another circle.
- `LCircle:perimeter() -> number`: Returns this circle perimeter. This method is available to Lua scripts.
- `LCircle:radius() -> number`: Returns this circle radius. This method is available to Lua scripts.
- `LCircle:type() -> string`: Returns the Lua-visible type name for this circle handle.
- `LCircle:typeOf(name) -> boolean`: Returns whether this circle handle matches a supported type name.
- `LCircle:x() -> number`: Returns this circle center x coordinate.
- `LCircle:y() -> number`: Returns this circle center y coordinate.

#### LHermite Type

- Lua-side wrapper for a Hermite spline.

##### Fields

- No documented fields.

##### Methods

- `LHermite:sample(t) -> number`: Samples the spline at normalized parameter `t`.
- `LHermite:type() -> string`: Returns the Lua-visible type name for this spline handle.
- `LHermite:typeOf(name) -> boolean`: Returns whether this spline handle matches a supported type name.

#### LLootTable Type

- Lua-side wrapper for a Walker-Vose alias-method loot table.

##### Fields

- No documented fields.

##### Methods

- `LLootTable:add(id, weight, meta?) -> nil`: Adds an entry to the table. Re-build is required before the next sample.
- `LLootTable:build() -> nil`: Rebuilds the alias table after mutations. Call before sampling.
- `LLootTable:entryCount() -> integer`: Returns the number of entries in the table.
- `LLootTable:merge(other) -> nil`: Merges entries from another loot table into this one.
- `LLootTable:remove(id) -> boolean`: Removes an entry by id. Returns true when found.
- `LLootTable:restore(blob) -> nil`: Restores loot table state from a blob produced by `save`.
- `LLootTable:sample() -> table`: Samples one entry in O(1), returning nil instead of a table when empty.
- `LLootTable:sampleN(n) -> table`: Samples n entries with replacement. Returns an array table.
- `LLootTable:sampleUnique(n) -> table`: Samples up to n unique entries (by id). Returns an array table.
- `LLootTable:save() -> string`: Serialises loot table state to a binary blob.
- `LLootTable:setSeed(seed) -> nil`: Sets the RNG seed. The alias table remains valid.
- `LLootTable:setWeight(id, weight) -> boolean`: Updates the weight of an existing entry. Returns true when found.
- `LLootTable:type() -> string`: Returns the Lua-visible type name.
- `LLootTable:typeOf(name) -> boolean`: Returns whether this handle matches the given type name.

#### LMathBresenhamResult Type

- Generated result shape from @field tags.

##### Fields

- `x` (`number`): X.
- `y` (`number`): Y.

##### Methods

- No documented methods.

#### LMathDelaunayTriangulateResult Type

- Generated result shape from @field tags.

##### Fields

- `[1]` (`integer`): First vertex index.
- `[2]` (`integer`): Second vertex index.
- `[3]` (`integer`): Third vertex index.

##### Methods

- No documented methods.

#### LMathTriangulateResult Type

- Generated result shape from @field tags.

##### Fields

- `[1]` (`number`): Point component (interleaved x,y pairs).

##### Methods

- No documented methods.

#### LPityTracker Type

- Lua-side wrapper for a pity tracker.

##### Fields

- No documented fields.

##### Methods

- `LPityTracker:counter() -> integer`: Returns the current miss counter used by pity-prime progression logic.
- `LPityTracker:export() -> string`: Compatibility alias for `save` that exports the same binary payload.
- `LPityTracker:import(blob) -> nil`: Compatibility alias for `restore`.
- `LPityTracker:isPrimed() -> boolean`: Returns true when the guaranteed drop is due.
- `LPityTracker:notice(result_id) -> boolean`: Notifies the tracker of a sample result id.
- `LPityTracker:reset() -> nil`: Resets the miss counter and clears primed guaranteed-drop state.
- `LPityTracker:restore(blob) -> nil`: Restores pity state from a blob produced by `save`.
- `LPityTracker:save() -> string`: Serialises pity state to a binary blob.
- `LPityTracker:type() -> string`: Returns the Lua-visible type name.
- `LPityTracker:typeOf(name) -> boolean`: Returns whether this handle matches the given type name.

#### LRandomGenerator Type

- Lua-side wrapper for a deterministic random generator.

##### Fields

- No documented fields.

##### Methods

- `LRandomGenerator:chance(probability) -> boolean`: Returns true with the given probability (0.0 = never, 1.0 = always).
- `LRandomGenerator:countSuccesses(count, sides, target) -> integer`: Rolls N dice and counts how many results are >= the target number.
- `LRandomGenerator:getSeed() -> integer`: Returns this generator seed. This method is available to Lua scripts.
- `LRandomGenerator:getState() -> string`: Returns this generator serialized state string.
- `LRandomGenerator:random() -> number`: Returns a random floating-point value from the generator.
- `LRandomGenerator:randomFloat(min, max) -> number`: Returns a random floating-point value in a range.
- `LRandomGenerator:randomInt(min, max) -> integer`: Returns a random integer in a range.
- `LRandomGenerator:randomNormal(stddev?, mean?) -> number`: Returns a normally distributed random value.
- `LRandomGenerator:roll(sides) -> integer`: Rolls a single die with the given number of sides.
- `LRandomGenerator:rollAdvantage(sides) -> integer`: Rolls two dice and returns the higher result (advantage mechanic).
- `LRandomGenerator:rollDisadvantage(sides) -> integer`: Rolls two dice and returns the lower result (disadvantage mechanic).
- `LRandomGenerator:rollExploding(count, sides) -> integer`: Rolls N exploding dice: when a die shows its maximum value, roll again and add.
- `LRandomGenerator:rollKeepHighest(count, sides, keep) -> integer`: Rolls N dice and returns the sum of the highest K results.
- `LRandomGenerator:rollKeepLowest(count, sides, keep) -> integer`: Rolls N dice and returns the sum of the lowest K results.
- `LRandomGenerator:rollN(count, sides) -> integer[]`: Rolls N dice with the given number of sides and returns all results.
- `LRandomGenerator:rollSum(count, sides) -> integer`: Rolls N dice and returns the sum of all results.
- `LRandomGenerator:setSeed(seed) -> nil`: Resets this generator to a seed value.
- `LRandomGenerator:setState(state) -> nil`: Restores this generator from a serialized state string.
- `LRandomGenerator:type() -> string`: Returns the Lua-visible type name for this random generator handle.
- `LRandomGenerator:typeOf(name) -> boolean`: Returns whether this random generator handle matches a supported type name.

#### LRectPacker Type

- Lua-side wrapper for a rectangle packer.

##### Fields

- No documented fields.

##### Methods

- `LRectPacker:clear() -> nil`: Clears packed rectangles from this packer.
- `LRectPacker:getPacked() -> table`: Returns packed rectangle records.
- `LRectPacker:occupancy() -> number`: Returns occupied area ratio. This method is available to Lua scripts.
- `LRectPacker:pack(w, h, id?) -> integer`: Attempts to pack a rectangle and returns its placement coordinates.

#### LRectPackerGetPackedResult Type

- Generated result shape from @field tags.

##### Fields

- `h` (`number`): Height.
- `id` (`integer?`): Optional identifier.
- `w` (`number`): Width.
- `x` (`number`): X.
- `y` (`number`): Y.

##### Methods

- No documented methods.

#### LSpatialHash Type

- Lua-side wrapper for a spatial hash index.

##### Fields

- No documented fields.

##### Methods

- `LSpatialHash:clear() -> nil`: Clears all items from the spatial hash.
- `LSpatialHash:getCellSize() -> number`: Returns the spatial hash cell size.
- `LSpatialHash:getItemCount() -> integer`: Returns the number of items in the spatial hash.
- `LSpatialHash:insert(id, x, y, w, h) -> nil`: Inserts an item rectangle into the spatial hash.
- `LSpatialHash:queryCircle(cx, cy, radius) -> integer[]`: Returns ids intersecting a query circle.
- `LSpatialHash:queryRect(x, y, w, h) -> integer[]`: Returns ids intersecting a query rectangle.
- `LSpatialHash:querySegment(x1, y1, x2, y2) -> integer[]`: Returns ids intersecting a query line segment.
- `LSpatialHash:remove(id) -> nil`: Removes an item from the spatial hash.
- `LSpatialHash:type() -> string`: Returns the Lua-visible type name for this spatial hash handle.
- `LSpatialHash:typeOf(name) -> boolean`: Returns whether this spatial hash handle matches a supported type name.
- `LSpatialHash:update(id, x, y, w, h) -> nil`: Updates an item rectangle in the spatial hash.

#### LTransform Type

- Lua-side wrapper for a 2D transform matrix.

##### Fields

- No documented fields.

##### Methods

- `LTransform:clone() -> LTransform`: Returns a copy of this transform. This method is available to Lua scripts.
- `LTransform:decompose() -> number`: Decomposes this transform into component values.
- `LTransform:getMatrix() -> number[]`: Returns this transform matrix as a flat array table.
- `LTransform:inverse() -> LTransform`: Returns this transform's inverse.
- `LTransform:inverseTransformPoint(x, y) -> number`: Transforms a point by this transform's inverse.
- `LTransform:reset() -> nil`: Resets this transform to identity.
- `LTransform:rotate(angle) -> nil`: Applies a rotation to this transform.
- `LTransform:scale(sx, sy?) -> nil`: Applies scale to this transform. This method is available to Lua scripts.
- `LTransform:setTransformation(x, y, angle?, sx?, sy?, ox?, oy?, kx?, ky?) -> nil`: Replaces this transform from position, rotation, scale, origin, and shear components.
- `LTransform:shear(kx, ky) -> nil`: Applies shear to this transform. This method is available to Lua scripts.
- `LTransform:transformPoint(x, y) -> number`: Transforms a point by this transform.
- `LTransform:translate(dx, dy) -> nil`: Applies a translation to this transform.
- `LTransform:type() -> string`: Returns the Lua-visible type name for this transform handle.
- `LTransform:typeOf(name) -> boolean`: Returns whether this transform handle matches a supported type name.

#### LTween Type

- Lua-side wrapper for numeric tween state.

##### Fields

- No documented fields.

##### Methods

- `LTween:addValue(start, target) -> integer`: Adds a value track to this tween. This method is available to Lua scripts.
- `LTween:getAllValues() -> number[]`: Returns all current tween values. This method is available to Lua scripts.
- `LTween:getClock() -> number`: Returns this tween clock time. This method is available to Lua scripts.
- `LTween:getDuration() -> number`: Returns this tween duration. This method is available to Lua scripts.
- `LTween:getEasingName() -> string`: Returns this tween easing function name.
- `LTween:getTime() -> number`: Returns this tween clock time. This method is available to Lua scripts.
- `LTween:getValue(index?) -> number`: Returns one tween value by one-based index or all values when no index is provided.
- `LTween:getValueCount() -> integer`: Returns the number of values animated by this tween.
- `LTween:isComplete() -> boolean`: Returns whether this tween is complete.
- `LTween:reset() -> nil`: Resets the tween clock to the beginning.
- `LTween:set(t) -> nil`: Sets this tween clock time. This method is available to Lua scripts.
- `LTween:setTime(t) -> nil`: Sets this tween clock time. This method is available to Lua scripts.
- `LTween:type() -> string`: Returns the Lua-visible type name for this tween handle.
- `LTween:typeOf(name) -> boolean`: Returns whether this tween handle matches a supported type name.
- `LTween:update(dt) -> boolean`: Advances the tween clock and returns whether it is complete.

#### LVec2 Type

- Represents the Lua-visible LVec2 object exposed by this module.

##### Fields

- `x` (`any`): Lua-visible field.
- `y` (`any`): Lua-visible field.

##### Methods

- `LVec2:angle() -> number`: Returns this vector angle. This method is available to Lua scripts.
- `LVec2:cross(other) -> number`: Returns the scalar 2D cross product with another vector.
- `LVec2:distance(other) -> number`: Returns distance to another vector.
- `LVec2:dot(other) -> number`: Returns the dot product with another vector.
- `LVec2:fromAngle(self, radians) -> LVec2`: Creates a unit vector from an angle.
- `LVec2:length() -> number`: Returns this vector length. This method is available to Lua scripts.
- `LVec2:lengthSquared() -> number`: Returns this vector squared length.
- `LVec2:lerp(other, t) -> LVec2`: Returns a vector interpolated toward another vector.
- `LVec2:normalize() -> LVec2`: Returns a normalized copy of this vector.
- `LVec2:normalized() -> LVec2`: Returns a normalized copy of this vector.
- `LVec2:perpendicular() -> LVec2`: Returns a perpendicular vector. This method is available to Lua scripts.
- `LVec2:reflect(normal) -> LVec2`: Returns this vector reflected around a normal vector.
- `LVec2:rotate(angle) -> LVec2`: Returns this vector rotated by an angle.
- `LVec2:type() -> string`: Returns the Lua-visible type name for this vector handle.
- `LVec2:typeOf(name) -> boolean`: Returns whether this vector handle matches a supported type name.
- `LVec2:x() -> number`: Returns this vector x component. This method is available to Lua scripts.
- `LVec2:y() -> number`: Returns this vector y component. This method is available to Lua scripts.

#### LVec3 Type

- Represents the Lua-visible LVec3 object exposed by this module.

##### Fields

- `x` (`any`): Lua-visible field.
- `y` (`any`): Lua-visible field.
- `z` (`any`): Lua-visible field.

##### Methods

- `LVec3:add(other) -> LVec3`: Returns the sum with another vector.
- `LVec3:cross(other) -> LVec3`: Returns the 3D cross product with another vector.
- `LVec3:distance(other) -> number`: Returns distance to another vector.
- `LVec3:dot(other) -> number`: Returns the dot product with another vector.
- `LVec3:length() -> number`: Returns this vector length. This method is available to Lua scripts.
- `LVec3:lengthSquared() -> number`: Returns this vector squared length.
- `LVec3:lerp(other, t) -> LVec3`: Returns a vector interpolated toward another vector.
- `LVec3:normalize() -> LVec3`: Returns a normalized copy of this vector.
- `LVec3:scale(s) -> LVec3`: Returns this vector multiplied by a scalar.
- `LVec3:splat(self, v) -> LVec3`: Creates a vector with all components set to one value.
- `LVec3:sub(other) -> LVec3`: Returns the difference from another vector.
- `LVec3:type() -> string`: Returns the Lua-visible type name for this vector handle.
- `LVec3:typeOf(name) -> boolean`: Returns whether this vector handle matches a supported type name.
