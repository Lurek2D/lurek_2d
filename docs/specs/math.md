# math

## TL;DR

- The `math` module is the most pervasive Foundations tier component in Lurek2D, providing an expansive suite of 2D mathematics, geometry, procedural generation, and spatial utility types.

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

- Circle primitive for radius-based collision and containment checks.
- Keeps radius non-negative and treats the center as the shape anchor.
- Answers point, circle, and AABB overlap queries for gameplay geometry.
- Includes area and perimeter helpers for higher-level math routines.

### easing.rs

- Curated easing family for animation curves and tween response shaping.
- Covers the standard in, out, and in-out variants across common motion families.
- Handles edge clamping for curves that need explicit start and end behavior.
- Exposes name-based resolution for data-driven animation systems.
- Includes linear passthrough for identity interpolation.
- Keeps the API focused on normalized t in [0,1] inputs and outputs.
- Lets higher-level systems drive motion with consistent curve semantics.

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

- `lurek.math.Vec2`: Creates a 2D vector. This function is exposed to Lua scripts.
- `lurek.math.Vec3`: Creates a 3D vector. This function is exposed to Lua scripts.
- `lurek.math.aabbTree`: Creates an empty AABB tree. This function is exposed to Lua scripts.
- `lurek.math.abs`: Returns absolute value. This function is exposed to Lua scripts.
- `lurek.math.acos`: Returns arccosine of a value. This function is exposed to Lua scripts.
- `lurek.math.angleBetween`: Returns the angle between two points.
- `lurek.math.applyEasing`: Applies a named easing function to a normalized value.
- `lurek.math.asin`: Returns arcsine of a value. This function is exposed to Lua scripts.
- `lurek.math.atan`: Returns arctangent or two-argument arctangent.
- `lurek.math.atan2`: Returns two-argument arctangent.
- `lurek.math.bresenham`: Returns integer grid points along a Bresenham line.
- `lurek.math.catmullRom`: Creates a Catmull-Rom spline from point tables.
- `lurek.math.ceil`: Returns ceiling of a value. This function is exposed to Lua scripts.
- `lurek.math.circleContainsPoint`: Returns whether a circle contains a point.
- `lurek.math.circleIntersectsCircle`: Returns whether two circles intersect.
- `lurek.math.circleIntersectsLine`: Returns circle-line intersection state and hit points when present.
- `lurek.math.circleIntersectsSegment`: Returns circle-segment intersection state and hit points when present.
- `lurek.math.clamp`: Clamps a value to a range. This function is exposed to Lua scripts.
- `lurek.math.closestPointOnSegment`: Returns the closest point on a segment to an input point.
- `lurek.math.convexHull`: Computes the convex hull for a flat point table.
- `lurek.math.cos`: Returns cosine of an angle. This function is exposed to Lua scripts.
- `lurek.math.cubicBezier`: Computes the CSS cubic-bezier Y value at input t (0..1).
- `lurek.math.deg`: Converts radians to degrees. This function is exposed to Lua scripts.
- `lurek.math.delaunayTriangulate`: Computes Delaunay triangles for a flat point table.
- `lurek.math.distance`: Returns Euclidean distance between two points.
- `lurek.math.distanceSq`: Returns squared Euclidean distance between two points.
- `lurek.math.easingNames`: Returns an array of all built-in easing function names.
- `lurek.math.exp`: Returns exponential of a value. This function is exposed to Lua scripts.
- `lurek.math.floor`: Returns floor of a value. This function is exposed to Lua scripts.
- `lurek.math.fmod`: Returns floating-point remainder.
- `lurek.math.hermite`: Creates a Hermite spline from endpoints and tangents.
- `lurek.math.inBack`: Applies back ease-in. This function is exposed to Lua scripts.
- `lurek.math.inBounce`: Applies bounce ease-in. This function is exposed to Lua scripts.
- `lurek.math.inCubic`: Applies cubic ease-in. This function is exposed to Lua scripts.
- `lurek.math.inElastic`: Applies elastic ease-in. This function is exposed to Lua scripts.
- `lurek.math.inExpo`: Applies exponential ease-in. This function is exposed to Lua scripts.
- `lurek.math.inOutBack`: Applies back ease-in-out. This function is exposed to Lua scripts.
- `lurek.math.inOutBounce`: Applies bounce ease-in-out. This function is exposed to Lua scripts.
- `lurek.math.inOutCubic`: Applies cubic ease-in-out. This function is exposed to Lua scripts.
- `lurek.math.inOutElastic`: Applies elastic ease-in-out. This function is exposed to Lua scripts.
- `lurek.math.inOutExpo`: Applies exponential ease-in-out.
- `lurek.math.inOutQuad`: Applies quadratic ease-in-out. This function is exposed to Lua scripts.
- `lurek.math.inOutQuart`: Applies quartic ease-in-out. This function is exposed to Lua scripts.
- `lurek.math.inOutSine`: Applies sine ease-in-out. This function is exposed to Lua scripts.
- `lurek.math.inQuad`: Applies quadratic ease-in. This function is exposed to Lua scripts.
- `lurek.math.inQuart`: Applies quartic ease-in. This function is exposed to Lua scripts.
- `lurek.math.inSine`: Applies sine ease-in. This function is exposed to Lua scripts.
- `lurek.math.inverseLerp`: Returns the interpolation factor of a value between two bounds.
- `lurek.math.isConvex`: Returns whether a flat polygon point table is convex.
- `lurek.math.lerp`: Linearly interpolates between two values.
- `lurek.math.lineIntersect`: Returns intersection point for two infinite lines when present.
- `lurek.math.linear`: Applies linear easing. This function is exposed to Lua scripts.
- `lurek.math.log`: Returns natural logarithm or logarithm with a supplied base.
- `lurek.math.lootFromList`: Creates a loot table from a Lua list of entry tables.
- `lurek.math.lootFromToml`: Loads a loot table from a TOML file path.
- `lurek.math.max`: Returns the largest supplied value.
- `lurek.math.min`: Returns the smallest supplied value.
- `lurek.math.newBezierCurve`: Creates a Bezier curve from a flat point table.
- `lurek.math.newCircle`: Creates a circle primitive. This function is exposed to Lua scripts.
- `lurek.math.newLootTable`: Creates a Walker-Vose alias-method loot table for O(1) weighted random sampling.
- `lurek.math.newPityTracker`: Creates a pity tracker that primes after `threshold` consecutive misses of `target_id`.
- `lurek.math.newRandomGenerator`: Creates a deterministic random generator with an optional seed.
- `lurek.math.newRectPacker`: Creates a rectangle packer. This function is exposed to Lua scripts.
- `lurek.math.newSpatialHash`: Creates a spatial hash index with a cell size.
- `lurek.math.newTransform`: Creates a 2D transform. All components are optional; omitting all returns an identity transform.
- `lurek.math.newTween`: Creates a tween with a duration and optional easing name.
- `lurek.math.outBack`: Applies back ease-out. This function is exposed to Lua scripts.
- `lurek.math.outBounce`: Applies bounce ease-out. This function is exposed to Lua scripts.
- `lurek.math.outCubic`: Applies cubic ease-out. This function is exposed to Lua scripts.
- `lurek.math.outElastic`: Applies elastic ease-out. This function is exposed to Lua scripts.
- `lurek.math.outExpo`: Applies exponential ease-out. This function is exposed to Lua scripts.
- `lurek.math.outQuad`: Applies quadratic ease-out. This function is exposed to Lua scripts.
- `lurek.math.outQuart`: Applies quartic ease-out. This function is exposed to Lua scripts.
- `lurek.math.outSine`: Applies sine ease-out. This function is exposed to Lua scripts.
- `lurek.math.pointInPolygon`: Returns whether a point lies inside a polygon.
- `lurek.math.polygonArea`: Computes signed area for a flat polygon point table.
- `lurek.math.polygonCentroid`: Computes the centroid for a flat polygon point table.
- `lurek.math.polygonClip`: Clips a flat polygon point table against a plane.
- `lurek.math.polygonDifference`: Returns polygon difference points for two polygon tables.
- `lurek.math.polygonIntersection`: Returns polygon intersection points for two polygon tables.
- `lurek.math.polygonUnion`: Returns polygon union points for two polygon tables.
- `lurek.math.pow`: Raises a value to a power. This function is exposed to Lua scripts.
- `lurek.math.rad`: Converts degrees to radians. This function is exposed to Lua scripts.
- `lurek.math.random`: Returns a Lua math random value, optionally scaled to one or two bounds.
- `lurek.math.randomInt`: Returns a Lua math random integer in an inclusive range.
- `lurek.math.rectFromCenter`: Creates a rectangle tuple from center coordinates and size.
- `lurek.math.rectUnion`: Returns the union rectangle for two rectangles.
- `lurek.math.remap`: Remaps a value from one range to another.
- `lurek.math.round`: Returns rounded value. This function is exposed to Lua scripts.
- `lurek.math.sampleWithPity`: Samples loot table with pity behavior: forced target when tracker is primed.
- `lurek.math.segmentIntersectsSegment`: Returns whether two segments intersect and their intersection point when present.
- `lurek.math.sign`: Returns the sign of a value. This function is exposed to Lua scripts.
- `lurek.math.sin`: Returns sine of an angle. This function is exposed to Lua scripts.
- `lurek.math.smoothstep`: Applies smoothstep interpolation between two edges.
- `lurek.math.sqrt`: Returns square root of a value. This function is exposed to Lua scripts.
- `lurek.math.tan`: Returns tangent of an angle. This function is exposed to Lua scripts.
- `lurek.math.triangulate`: Triangulates a flat polygon point table.
- `lurek.math.vec2`: Creates a 2D vector. This function is exposed to Lua scripts.
- `lurek.math.vec3`: Creates a 3D vector. This function is exposed to Lua scripts.

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

- `LAabbTree:clear`: Clears all items from the tree. This method is available to Lua scripts.
- `LAabbTree:contains`: Returns whether the tree contains an id.
- `LAabbTree:insert`: Inserts an AABB by id. This method is available to Lua scripts.
- `LAabbTree:isEmpty`: Returns whether the tree has no items.
- `LAabbTree:len`: Returns the number of items in the tree.
- `LAabbTree:query`: Queries ids intersecting an AABB. This method is available to Lua scripts.
- `LAabbTree:queryPoint`: Queries ids containing a point. This method is available to Lua scripts.
- `LAabbTree:remove`: Removes an AABB by id. This method is available to Lua scripts.
- `LAabbTree:type`: Returns the Lua-visible type name for this AABB tree handle.
- `LAabbTree:typeOf`: Returns whether this AABB tree handle matches a supported type name.
- `LAabbTree:update`: Updates an AABB by id. This method is available to Lua scripts.

#### LBezierCurve Type

- Lua-side wrapper for a Bezier curve.

##### Fields

- No documented fields.

##### Methods

- `LBezierCurve:evaluate`: Evaluates this curve at normalized parameter `t`.
- `LBezierCurve:evaluateAtDistance`: Evaluates this curve at an approximate distance along the curve.
- `LBezierCurve:getControlPoint`: Returns a control point by one-based index.
- `LBezierCurve:getControlPointCount`: Returns the number of control points in this curve.
- `LBezierCurve:getDerivative`: Returns the derivative curve for this Bezier curve.
- `LBezierCurve:insertControlPoint`: Inserts a control point, optionally before a one-based index.
- `LBezierCurve:length`: Returns the approximate curve length.
- `LBezierCurve:removeControlPoint`: Removes a control point by one-based index.
- `LBezierCurve:render`: Returns sampled points along this curve.
- `LBezierCurve:rotate`: Rotates all control points around an origin.
- `LBezierCurve:scale`: Scales all control points around an origin.
- `LBezierCurve:setControlPoint`: Sets a control point by one-based index.
- `LBezierCurve:translate`: Translates all control points. This method is available to Lua scripts.
- `LBezierCurve:type`: Returns the Lua-visible type name for this Bezier curve handle.
- `LBezierCurve:typeOf`: Returns whether this Bezier curve handle matches a supported type name.

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

- `LCatmullRom:addPoint`: Adds a point to the spline. This method is available to Lua scripts.
- `LCatmullRom:len`: Returns the number of points in the spline.
- `LCatmullRom:removePoint`: Removes a point by zero-based index and returns its coordinates.
- `LCatmullRom:sample`: Samples the spline at normalized parameter `t`.
- `LCatmullRom:sampleSegment`: Samples one spline segment at local parameter `t`.
- `LCatmullRom:type`: Returns the Lua-visible type name for this spline handle.
- `LCatmullRom:typeOf`: Returns whether this spline handle matches a supported type name.

#### LCircle Type

- Lua-side wrapper for a circle primitive.

##### Fields

- No documented fields.

##### Methods

- `LCircle:aabb`: Returns this circle axis-aligned bounding box.
- `LCircle:area`: Returns this circle area. This method is available to Lua scripts.
- `LCircle:contains`: Returns whether this circle contains a point.
- `LCircle:intersects`: Returns whether this circle intersects another circle.
- `LCircle:perimeter`: Returns this circle perimeter. This method is available to Lua scripts.
- `LCircle:radius`: Returns this circle radius. This method is available to Lua scripts.
- `LCircle:type`: Returns the Lua-visible type name for this circle handle.
- `LCircle:typeOf`: Returns whether this circle handle matches a supported type name.
- `LCircle:x`: Returns this circle center x coordinate.
- `LCircle:y`: Returns this circle center y coordinate.

#### LHermite Type

- Lua-side wrapper for a Hermite spline.

##### Fields

- No documented fields.

##### Methods

- `LHermite:sample`: Samples the spline at normalized parameter `t`.
- `LHermite:type`: Returns the Lua-visible type name for this spline handle.
- `LHermite:typeOf`: Returns whether this spline handle matches a supported type name.

#### LLootTable Type

- Lua-side wrapper for a Walker-Vose alias-method loot table.

##### Fields

- No documented fields.

##### Methods

- `LLootTable:add`: Adds an entry to the table. Re-build is required before the next sample.
- `LLootTable:build`: Rebuilds the alias table after mutations. Call before sampling.
- `LLootTable:entryCount`: Returns the number of entries in the table.
- `LLootTable:merge`: Merges entries from another loot table into this one.
- `LLootTable:remove`: Removes an entry by id. Returns true when found.
- `LLootTable:restore`: Restores loot table state from a blob produced by `save`.
- `LLootTable:sample`: Samples one entry in O(1), returning nil instead of a table when empty.
- `LLootTable:sampleN`: Samples n entries with replacement. Returns an array table.
- `LLootTable:sampleUnique`: Samples up to n unique entries (by id). Returns an array table.
- `LLootTable:save`: Serialises loot table state to a binary blob.
- `LLootTable:setSeed`: Sets the RNG seed. The alias table remains valid.
- `LLootTable:setWeight`: Updates the weight of an existing entry. Returns true when found.
- `LLootTable:type`: Returns the Lua-visible type name.
- `LLootTable:typeOf`: Returns whether this handle matches the given type name.

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

- `LPityTracker:counter`: Returns the current miss counter used by pity-prime progression logic.
- `LPityTracker:export`: Compatibility alias for `save` that exports the same binary payload.
- `LPityTracker:import`: Compatibility alias for `restore`.
- `LPityTracker:isPrimed`: Returns true when the guaranteed drop is due.
- `LPityTracker:notice`: Notifies the tracker of a sample result id.
- `LPityTracker:reset`: Resets the miss counter and clears primed guaranteed-drop state.
- `LPityTracker:restore`: Restores pity state from a blob produced by `save`.
- `LPityTracker:save`: Serialises pity state to a binary blob.
- `LPityTracker:type`: Returns the Lua-visible type name.
- `LPityTracker:typeOf`: Returns whether this handle matches the given type name.

#### LRandomGenerator Type

- Lua-side wrapper for a deterministic random generator.

##### Fields

- No documented fields.

##### Methods

- `LRandomGenerator:chance`: Returns true with the given probability (0.0 = never, 1.0 = always).
- `LRandomGenerator:countSuccesses`: Rolls N dice and counts how many results are >= the target number.
- `LRandomGenerator:getSeed`: Returns this generator seed. This method is available to Lua scripts.
- `LRandomGenerator:getState`: Returns this generator serialized state string.
- `LRandomGenerator:random`: Returns a random floating-point value from the generator.
- `LRandomGenerator:randomFloat`: Returns a random floating-point value in a range.
- `LRandomGenerator:randomInt`: Returns a random integer in a range.
- `LRandomGenerator:randomNormal`: Returns a normally distributed random value.
- `LRandomGenerator:roll`: Rolls a single die with the given number of sides.
- `LRandomGenerator:rollAdvantage`: Rolls two dice and returns the higher result (advantage mechanic).
- `LRandomGenerator:rollDisadvantage`: Rolls two dice and returns the lower result (disadvantage mechanic).
- `LRandomGenerator:rollExploding`: Rolls N exploding dice: when a die shows its maximum value, roll again and add.
- `LRandomGenerator:rollKeepHighest`: Rolls N dice and returns the sum of the highest K results.
- `LRandomGenerator:rollKeepLowest`: Rolls N dice and returns the sum of the lowest K results.
- `LRandomGenerator:rollN`: Rolls N dice with the given number of sides and returns all results.
- `LRandomGenerator:rollSum`: Rolls N dice and returns the sum of all results.
- `LRandomGenerator:setSeed`: Resets this generator to a seed value.
- `LRandomGenerator:setState`: Restores this generator from a serialized state string.
- `LRandomGenerator:type`: Returns the Lua-visible type name for this random generator handle.
- `LRandomGenerator:typeOf`: Returns whether this random generator handle matches a supported type name.

#### LRectPacker Type

- Lua-side wrapper for a rectangle packer.

##### Fields

- No documented fields.

##### Methods

- `LRectPacker:clear`: Clears packed rectangles from this packer.
- `LRectPacker:getPacked`: Returns packed rectangle records.
- `LRectPacker:occupancy`: Returns occupied area ratio. This method is available to Lua scripts.
- `LRectPacker:pack`: Attempts to pack a rectangle and returns its placement coordinates.

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

- `LSpatialHash:clear`: Clears all items from the spatial hash.
- `LSpatialHash:getCellSize`: Returns the spatial hash cell size.
- `LSpatialHash:getItemCount`: Returns the number of items in the spatial hash.
- `LSpatialHash:insert`: Inserts an item rectangle into the spatial hash.
- `LSpatialHash:queryCircle`: Returns ids intersecting a query circle.
- `LSpatialHash:queryRect`: Returns ids intersecting a query rectangle.
- `LSpatialHash:querySegment`: Returns ids intersecting a query line segment.
- `LSpatialHash:remove`: Removes an item from the spatial hash.
- `LSpatialHash:type`: Returns the Lua-visible type name for this spatial hash handle.
- `LSpatialHash:typeOf`: Returns whether this spatial hash handle matches a supported type name.
- `LSpatialHash:update`: Updates an item rectangle in the spatial hash.

#### LTransform Type

- Lua-side wrapper for a 2D transform matrix.

##### Fields

- No documented fields.

##### Methods

- `LTransform:clone`: Returns a copy of this transform. This method is available to Lua scripts.
- `LTransform:decompose`: Decomposes this transform into component values.
- `LTransform:getMatrix`: Returns this transform matrix as a flat array table.
- `LTransform:inverse`: Returns this transform's inverse.
- `LTransform:inverseTransformPoint`: Transforms a point by this transform's inverse.
- `LTransform:reset`: Resets this transform to identity.
- `LTransform:rotate`: Applies a rotation to this transform.
- `LTransform:scale`: Applies scale to this transform. This method is available to Lua scripts.
- `LTransform:setTransformation`: Replaces this transform from position, rotation, scale, origin, and shear components.
- `LTransform:shear`: Applies shear to this transform. This method is available to Lua scripts.
- `LTransform:transformPoint`: Transforms a point by this transform.
- `LTransform:translate`: Applies a translation to this transform.
- `LTransform:type`: Returns the Lua-visible type name for this transform handle.
- `LTransform:typeOf`: Returns whether this transform handle matches a supported type name.

#### LTween Type

- Lua-side wrapper for numeric tween state.

##### Fields

- No documented fields.

##### Methods

- `LTween:addValue`: Adds a value track to this tween. This method is available to Lua scripts.
- `LTween:getAllValues`: Returns all current tween values. This method is available to Lua scripts.
- `LTween:getClock`: Returns this tween clock time. This method is available to Lua scripts.
- `LTween:getDuration`: Returns this tween duration. This method is available to Lua scripts.
- `LTween:getEasingName`: Returns this tween easing function name.
- `LTween:getTime`: Returns this tween clock time. This method is available to Lua scripts.
- `LTween:getValue`: Returns one tween value by one-based index or all values when no index is provided.
- `LTween:getValueCount`: Returns the number of values animated by this tween.
- `LTween:isComplete`: Returns whether this tween is complete.
- `LTween:reset`: Resets the tween clock to the beginning.
- `LTween:set`: Sets this tween clock time. This method is available to Lua scripts.
- `LTween:setTime`: Sets this tween clock time. This method is available to Lua scripts.
- `LTween:type`: Returns the Lua-visible type name for this tween handle.
- `LTween:typeOf`: Returns whether this tween handle matches a supported type name.
- `LTween:update`: Advances the tween clock and returns whether it is complete.

#### LVec2 Type

- Represents the Lua-visible LVec2 object exposed by this module.

##### Fields

- `x` (`any`): Lua-visible field.
- `y` (`any`): Lua-visible field.

##### Methods

- `LVec2:angle`: Returns this vector angle. This method is available to Lua scripts.
- `LVec2:cross`: Returns the scalar 2D cross product with another vector.
- `LVec2:distance`: Returns distance to another vector.
- `LVec2:dot`: Returns the dot product with another vector.
- `LVec2:fromAngle`: Creates a unit vector from an angle.
- `LVec2:length`: Returns this vector length. This method is available to Lua scripts.
- `LVec2:lengthSquared`: Returns this vector squared length.
- `LVec2:lerp`: Returns a vector interpolated toward another vector.
- `LVec2:normalize`: Returns a normalized copy of this vector.
- `LVec2:normalized`: Returns a normalized copy of this vector.
- `LVec2:perpendicular`: Returns a perpendicular vector. This method is available to Lua scripts.
- `LVec2:reflect`: Returns this vector reflected around a normal vector.
- `LVec2:rotate`: Returns this vector rotated by an angle.
- `LVec2:type`: Returns the Lua-visible type name for this vector handle.
- `LVec2:typeOf`: Returns whether this vector handle matches a supported type name.
- `LVec2:x`: Returns this vector x component. This method is available to Lua scripts.
- `LVec2:y`: Returns this vector y component. This method is available to Lua scripts.

#### LVec3 Type

- Represents the Lua-visible LVec3 object exposed by this module.

##### Fields

- `x` (`any`): Lua-visible field.
- `y` (`any`): Lua-visible field.
- `z` (`any`): Lua-visible field.

##### Methods

- `LVec3:add`: Returns the sum with another vector.
- `LVec3:cross`: Returns the 3D cross product with another vector.
- `LVec3:distance`: Returns distance to another vector.
- `LVec3:dot`: Returns the dot product with another vector.
- `LVec3:length`: Returns this vector length. This method is available to Lua scripts.
- `LVec3:lengthSquared`: Returns this vector squared length.
- `LVec3:lerp`: Returns a vector interpolated toward another vector.
- `LVec3:normalize`: Returns a normalized copy of this vector.
- `LVec3:scale`: Returns this vector multiplied by a scalar.
- `LVec3:splat`: Creates a vector with all components set to one value.
- `LVec3:sub`: Returns the difference from another vector.
- `LVec3:type`: Returns the Lua-visible type name for this vector handle.
- `LVec3:typeOf`: Returns whether this vector handle matches a supported type name.
