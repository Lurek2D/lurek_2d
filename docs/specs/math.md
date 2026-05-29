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

## Files

### aabb_tree.rs

- Dynamic AABB bounding-volume hierarchy for broad-phase 2D spatial queries.
- Insertion, removal, and in-place update of axis-aligned bounding boxes keyed by numeric id.
- Query primitives: rectangle overlap, point containment, circle overlap, and segment intersection.
- Surface-area heuristic descent for high-quality sibling selection on insert.
- Free-list node pool avoiding repeated allocation and fragmentation.
- Incremental bottom-up refit keeping ancestor bounds tight after mutations.
- Helper geometry routines: AABB area, merged bounds, box-box, box-circle, and box-segment tests.
- Leaf-centric design mapping each entry id to a single leaf node for O(1) lookup.
- Suitable for hundreds to low thousands of dynamic bodies at interactive frame rates.

### bezier.rs

- Arbitrary-degree Bézier curve with dynamic control-point list.
- Evaluation via Bernstein basis, clamped to `[0,1]`.
- Sampling helpers for full curves, sub-segments, and arc-length walks.
- First-derivative computation and tangent-angle extraction.
- Geometric transforms: translate, rotate, scale relative to an origin.
- Control-point CRUD with minimum-count safety.

### circle.rs

- Circle primitive defined by center + radius, clamped non-negative on construction.
- Point-containment, circle-circle intersection, and AABB queries.
- Area and perimeter helpers using `std::f32::consts::PI`.

### easing.rs

- Standard easing curves: quad, cubic, quart, sine, expo, elastic, bounce, back.
- Each family provides in, out, and in-out variants mapping `t∈[0,1]→[0,1]`.
- Boundary-clamped functions (expo, elastic) handle t≤0 and t≥1 explicitly.
- Name-based lookup via `apply` and `resolve_easing_fn` for string-driven tween systems.
- Linear passthrough for identity interpolation.

### facade.rs

- Scalar interpolation helpers: lerp, inverse_lerp, remap, smoothstep.
- Numeric utilities: clamp, sign.
- All functions operate on `f32` and are pure (no side effects).

### geometry.rs

- Circle queries: containment, circle-circle overlap, circle-line and circle-segment intersection with hit points.
- Polygon operations: signed area (shoelace), centroid, point-in-polygon (ray cast), convex hull (Andrew monotone chain).
- Segment and line utilities: segment-segment intersection, closest point on segment, infinite-line intersection.
- Grid rasterization: Bresenham line for integer cell traversal.
- Triangulation: Delaunay via Bowyer-Watson with super-triangle removal.
- Angle computation: atan2-based bearing between two points.
- All routines are standalone free functions operating on flat coordinate scalars or flat vertex arrays.
- f32 used for game-facing geometry; f64 used for Delaunay where precision matters.

### loot_table.rs

- Walker-Vose alias-method loot table and pity tracker.
- `LootTable` samples in O(1) using the alias method after an O(n) build.
- `PityTracker` counts misses and primes a guaranteed drop after `threshold` misses.
- `sample_with_pity` combines both: forces the tracked item when the pity is primed.
- Serialisation via `save` / `restore` round-trips the RNG state and all weights.

### mat3.rs

- Row-major 3×3 matrix type for 2D affine transformations.
- Factory constructors for identity, translation, rotation, scale, and shear.
- Inverse computation with degenerate-determinant fallback.
- Point transformation and matrix multiplication via `std::ops::Mul`.

### mod.rs

- Math primitives: Vec2, Vec3, Mat3, Rect, Circle, Transform.
- Spatial structures: AABB tree, spatial hash grid, rectangle bin-packing.
- Curves and interpolation: bezier, splines, tweens, easing functions, scalar helpers.

### polygon.rs

- Ear-clipping triangulation for simple polygons and convexity testing.
- Sutherland-Hodgman polygon clipping against arbitrary half-planes.
- Boolean-style polygon operations: intersection, union, and difference.
- Andrew monotone-chain convex hull and winding-order normalization.
- Internal helpers for signed area, point-in-triangle, and cross-product sign tests.

### random.rs

- Seedable pseudo-random number generator wrapping `fastrand` with save/restore support.
- Uniform integer, float, and Gaussian sampling primitives.
- Seed persistence via string serialisation for deterministic replay.

### rect.rs

- Axis-aligned rectangle defined by top-left corner and size (y-down convention).
- Containment, intersection, union, and bounding-box construction from point sets.
- Center-based and corner-based constructors for layout and collision use cases.

### spatial_hash.rs

- Uniform-grid spatial hashing for broad-phase 2D collision and proximity queries.
- AABB insert/remove/update with automatic cell-bucket management.
- Rectangle, circle, and segment query shapes with deduplication.
- Parametric slab-based segment-vs-AABB intersection test.
- O(1) cell lookup per query tile; scales with world density, not total item count.

### spline.rs

- Catmull-Rom multi-segment spline with dynamic control-point management.
- Hermite cubic segment defined by endpoints and tangents.
- Normalized parameter sampling across full spline or individual segments.

### transform.rs

- Accumulated 2D affine transform backed by a 3×3 matrix.
- Chainable translate, rotate, scale, and shear mutations.
- Forward and inverse point mapping plus SRT decomposition.

### vec2.rs

- 2D float vector type used for all position, direction, and velocity math.
- Arithmetic operators: add, sub, mul, div, negate, and assign variants.
- Geometric helpers: length, normalize, distance, dot, cross, perpendicular.
- Rotation, reflection, and angle conversion utilities.
- Linear interpolation and unit-direction construction from radians.

### vec3.rs

- 3D float vector for cross-product normals, raycasting directions, and noise inputs.
- Arithmetic ops (add, sub, mul, div, neg) and geometric helpers (dot, cross, normalize, reflect, project).
- Lerp, distance, and length utilities for interpolation and spatial queries.

### voronoi.rs

- Voronoi diagram generation from 2D point sets via Bowyer-Watson Delaunay triangulation.
- Circumcenter and circumcircle predicates for incremental insertion.
- Boundary-edge extraction and super-triangle cleanup.
- CCW vertex sorting and deduplication to produce closed polygonal cells.
- Input deduplication to handle coincident sites gracefully.

## Lua API Ref

- Binding: `src/lua_api/math_api.rs`
- Namespace: `lurek.math`

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

### Enums

- No documented module-level enums/constants.

### Types


#### LAabbTree Type


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


#### LCatmullRom Type


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


##### Fields

- No documented fields.

##### Methods

- `LHermite:sample`: Samples the spline at normalized parameter `t`.
- `LHermite:type`: Returns the Lua-visible type name for this spline handle.
- `LHermite:typeOf`: Returns whether this spline handle matches a supported type name.


#### LLootTable Type


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


#### LPityTracker Type


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


##### Fields

- No documented fields.

##### Methods

- `LRectPacker:clear`: Clears packed rectangles from this packer.
- `LRectPacker:getPacked`: Returns packed rectangle records.
- `LRectPacker:occupancy`: Returns occupied area ratio. This method is available to Lua scripts.
- `LRectPacker:pack`: Attempts to pack a rectangle and returns its placement coordinates.


#### LSpatialHash Type


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

## References

- `globe`: Imports or references `src/globe/`. Cross-group dependency from `Foundations` into `Feature Systems`.
- `image`: Imports or references `src/image/`. Cross-group dependency from `Foundations` into `Platform Services`.
