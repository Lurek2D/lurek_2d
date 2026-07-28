<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/math.md or source docstrings instead. -->

# math

## TL;DR

- Provides vectors, matrices, spatial indexes (AABB tree and spatial hash), and polygon geometry.
- Supports splines, Bézier curves, tweens with easing, seedable randoms, and loot pity-trackers.
- Centralizes core mathematical formulas to guarantee consistent, drift-free engine behaviors.

## General Info

- Module group: `Foundations`
- Source path: `src/math`
- Binding: `src/lua_api/math_api.rs`
- Namespace: `lurek.math`
- Lua API surface: `100` functions, `20` types, `169` methods
- User-facing: `true`
- Plugin tier: `not_evaluated`

## Summary

- The `math` module is the engine's shared numerical and geometric foundation for users who need consistent rules for coordinates, shapes, transforms, interpolation, sampling, and spatial reasoning across many feature areas.
- Its primary role is standardization. When rendering, physics, pathfinding, camera logic, UI layout, procedural generation, and gameplay helpers all rely on the same vector, matrix, angle, and shape vocabulary, the rest of the engine can cooperate without hidden conversions or drifting assumptions.
- Core vector and matrix types provide the base language for position, direction, orientation, scale, projection, and composition. They are the primitives that let modules talk about where something is, how it is rotated, how it moves, and how one space maps into another.
- Geometry helpers extend the module beyond raw numbers into practical spatial entities such as rectangles, circles, polygons, bounds, overlap tests, distance checks, clipping helpers, and containment queries used across collision, UI, culling, and selection.
- Transform logic is another major category. Translation, rotation, scale, matrix composition, inversion, and coordinate-space conversion allow scripts and subsystems to move between local, world, map, and screen representations without ambiguous manual math.
- Curve, easing, interpolation, and value-shaping helpers matter because motion paths, camera rails, UI transitions, scripted effects, and numeric blending all depend on shared progression rules rather than bespoke formulas.
- Spatial indexing and applied algorithms broaden the module from calculation into organization, giving larger systems reusable structures and geometric building blocks for broad phases, region construction, and procedural workflows.
- That common layer is important because spatial bugs usually come from disagreement, not from missing arithmetic. If one system treats a rectangle as inclusive, another applies a different rotation convention, and a third projects coordinates with a slightly different transform order, the engine becomes hard to trust even when each local feature appears reasonable in isolation.
- The module therefore acts as an agreement surface as much as a utility library. It gives neighboring systems one place to inherit conventions for handedness, angle normalization, interpolation behavior, projection rules, and coordinate conversion semantics.
- For rendering-oriented code this means predictable transforms and projection helpers. For physics-adjacent code it means stable distances and shape math. For UI and tooling code it means reliable hit testing and viewport conversion.
- Curve support broadens the module from rigid geometry into authored motion and data shaping. Bézier curves, splines, and similar helpers give camera paths, animation support systems, road generation, region shaping, and tool previews a common language for smooth trajectories and contours.
- Broad-phase and indexing helpers give the module a structural role too. Large feature sets often need partitioning, bucketing, or neighborhood lookup before they can do more expensive per-object reasoning, and those patterns are easier to keep correct when they reuse engine-level math primitives and bounds semantics.
- Determinism is another reason the module matters. Tests, replays, serialized tools, and visual evidence workflows depend on math behavior that is reproducible enough to compare, inspect, and trust across runs.
- Sampling and value-shaping helpers belong here for the same reason: even small operations such as remapping, clamping, wrapping, and parameter evaluation become more reliable when they reuse one engine-wide numeric vocabulary.
- World generation and simulation tools also lean on this layer because geometric construction rarely stays confined to one subsystem. Voronoi-like helpers, region assembly, contour processing, and transform composition often need to interoperate with render views, province maps, physics queries, or camera framing.
- The module therefore acts as a substrate for both high-level and low-level work, and it gives tools and tests a deterministic numerical layer they can trust.
- Read `math` as the place where the engine standardizes numeric and geometric reasoning across the rest of the project for code, tools, and tests alike.

This module primarily collaborates with `globe`, `image`. Its responsibility should stay inside the Foundations group rather than absorb behavior owned by those neighbors.

## Ownership

- Canonical source: `src/math`
- Owning tier: `Foundations`
- Plugin tier: `not_evaluated`
- Lua binding owner: `src/lua_api/math_api.rs`
- Referenced engine modules: `globe`, `image`

## Imports

- `globe`: Imports or references `src/globe/`. Dependency stays inside `Foundations` and should remain acyclic.
- `image`: Imports or references `src/image/`. Cross-group dependency from `Foundations` into `Platform Services`.

## Source Files

### aabb_tree.rs

- This file owns the dynamic AABB tree used as a broad-phase index for rectangle, point, circle, and segment queries.
- `AabbEntry` stores the public leaf bounds, while `AabbTree` owns nodes, leaf indices, entry records, and the root.
- Insert, remove, and update stay here because node allocation, sibling choice, and upward refits define tree semantics.
- The internal `Node` and `NodeKind` types also belong here since branch-versus-leaf ownership is tree-local state.
- Surface-area sibling selection remains local because balancing decisions shape runtime query cost for moving actors.
- Circle and segment verification also belong here since broad-phase pruning and exact AABB tests share one boundary.
- Free-list reuse is part of this owner because node lifetime and allocation churn are concerns of the tree itself.
- Open it when broad-phase bounds logic changes; spatial hashes and shape helpers live in sibling math modules.

### bezier.rs

- This file owns the editable Bezier-curve model used for smooth paths, tangents, and sampled motion trajectories.
- `BezierCurve` stores its control-point list and provides evaluation, derivative, arc-length, and sampling helpers.
- Transform operations stay here because translating, rotating, or scaling points changes the owned curve geometry.
- Segment rendering and distance-based evaluation also belong here since they derive directly from the same curve data.
- Control-point insertion, removal, and mutation remain local because path editing is part of the curve's core contract.
- Open it when authored path semantics change; splines and easing families live in sibling math modules.

### circle.rs

- This file owns the 2D circle primitive used for containment, overlap tests, and simple numeric shape properties.
- `Circle` stores center and radius, while area, perimeter, center, and AABB helpers expose the owned geometry.
- Point and circle intersection checks stay here because distance-based circle semantics belong with the primitive.
- Open it when circle-shape behavior changes; rectangle, polygon, and geometry helper code live in siblings.

### easing.rs

- This file owns the library of named easing curves used to shape normalized animation and interpolation timing.
- Linear, polynomial, sine, exponential, elastic, bounce, back, and smooth-step families all live in one owner.
- Boundary clamping for exponential and elastic variants stays here because endpoint correctness is easing semantics.
- `apply`, `easing_names`, and `resolve_easing_fn` also belong here since name lookup is part of the public surface.
- The CSS-style `cubic_bezier` helper remains local because it evaluates one more timing curve under the same contract.
- This file provides pure scalar mappings only, not tween state, animation tracks, or scene-update orchestration.
- Open it when motion-curve semantics change; path geometry and transforms live in sibling math modules.

### facade.rs

- This file owns small scalar helpers such as lerp, remap, clamp, sign, smoothstep, and inverse_lerp.
- The functions stay together because they provide the tiny numeric facade reused across the wider math subsystem.
- They are pure f32 mappings, not vector types, geometry storage, or matrix-based transform owners.
- Open it when scalar helper semantics change; curves, shapes, and vector primitives live in sibling modules.

### geometry.rs

- This file owns standalone geometry routines for angles, intersections, rasterization, hulls, and polygon measures.
- Circle, line, segment, and point helpers stay here because they are free functions rather than shape-owned methods.
- Polygon area, centroid, point inclusion, and convex-hull utilities also belong here as shared flat-coordinate tools.
- Bresenham line stepping remains local because grid traversal is geometry support, not a rendering system concern.
- Delaunay triangulation also belongs here since it provides reusable mesh and Voronoi preparation over raw points.
- This file is the shared toolbox boundary, not the owner of rectangles, circles, vectors, or dynamic spatial indexes.
- Open it when low-level query semantics change; dedicated shape types and trees live in sibling math modules.

### loot_table.rs

- This file owns weighted loot sampling, alias-table construction, save-state restoration, and pity-drop tracking.
- `LootEntry` defines one drop, `LootTable` owns weights and sampling state, and `PityTracker` tracks miss streaks.
- Walker-Vose alias construction stays here because O(1) draw preparation is central to the table's runtime contract.
- Mutation helpers such as add, remove, merge, and set_weight also belong here since they invalidate built sampling data.
- Binary save and restore logic remain local because entries, alias arrays, and RNG state are owned by this structure.
- TOML loading also belongs here since serialized table definitions are part of the table's authoring-facing boundary.
- `sample_with_pity` remains local because guaranteed-drop forcing depends on both table sampling and pity state rules.
- Open it when drop-table semantics change; general RNG helpers live in `random.rs`, not in this file.

### mat3.rs

- This file owns the row-major 3x3 matrix used for 2D affine translation, rotation, scale, and shear math.
- `Mat3` stores matrix elements and exposes constructors, inversion, multiplication, and point transformation helpers.
- Affine constructors stay here because matrix layout and basis placement are local concerns of this linear type.
- Inverse and multiplication logic also belong here since composition semantics must stay with the matrix owner.
- Open it when 2D matrix behavior changes; high-level transform editing lives in `transform.rs` instead.

### mod.rs

- This module is the math index, exposing vectors, matrices, shapes, curves, random tools, and spatial data helpers.
- It wires together core geometry owners such as `vec2`, `vec3`, `rect`, `circle`, `polygon`, and `transform`.
- It also exports support systems such as `aabb_tree`, `spatial_hash`, `loot_table`, `random`, and `easing`.
- `mod.rs` owns visibility and reexport boundaries, not runtime state, so implementation ownership stays in siblings.
- Open this file to map where interpolation, bounds queries, triangulation, transforms, or weighted sampling are owned.
- `geometry.rs`, `polygon.rs`, and `voronoi.rs` cover free-function geometric analysis and derived cell construction.
- `vec2.rs`, `vec3.rs`, `mat3.rs`, and `transform.rs` cover reusable numeric primitives and affine composition.
- `aabb_tree.rs`, `spatial_hash.rs`, and `loot_table.rs` cover indexing, query acceleration, and weighted selection.

### polygon.rs

- This file owns polygon operations such as triangulation, convexity checks, clipping, and simple boolean-style edits.
- Ear clipping stays here because triangulation depends on polygon winding, ear tests, and point-in-triangle checks.
- Intersection, union, and difference helpers also belong here since they manipulate polygon contours directly.
- Convex-hull and winding normalization remain local because downstream polygon operations rely on consistent ordering.
- This file is about polygon contour processing, not free-form segment queries or dedicated rectangle primitives.
- Open it when polygon-topology semantics change; generic geometry helpers live in sibling math modules.

### random.rs

- This file owns the seedable random-generator wrapper used for deterministic integers, floats, normals, and dice rolls.
- `RandomGenerator` stores the backend RNG plus persisted seed so runtime sampling and save restoration share one owner.
- Dice helpers stay here because exploding, kept, advantaged, and summed rolls are just structured RNG consumers.
- State serialization also belongs here since replay-safe continuation is part of the generator's contract.
- Open it when generic RNG behavior changes; weighted loot policy lives in `loot_table.rs`, not here.

### rect.rs

- This file owns the axis-aligned rectangle primitive used for layout, bounds tests, and overlap computations.
- `Rect` stores position and size, while center, area, contains, intersect, union, and builders expose that geometry.
- Top-left and center-based constructors stay here because rectangle creation semantics belong to the shape owner.
- Point and rectangle overlap checks also remain local since they define how this primitive behaves in queries.
- Open it when rectangle semantics change; circles, polygons, and free geometry helpers live in sibling modules.

### spatial_hash.rs

- This file owns the uniform-grid spatial hash used to bucket AABBs for broad-phase neighbor and overlap searches.
- `SpatialItem` stores one registered box, while `SpatialHash` owns cell size, item storage, and bucket membership.
- Insert, remove, update, and clear stay here because bucket residency and cell-range mapping are local index rules.
- Rectangle, circle, and segment queries also belong here since they reuse one deduplicated bucket-traversal boundary.
- The slab-style segment-versus-AABB helper remains local because query correctness depends on the same grid owner.
- Open it when uniform-grid indexing changes; tree-based broad phase lives in `aabb_tree.rs` instead.

### spline.rs

- This file owns spline interpolation helpers for editable Catmull-Rom paths and single Hermite curve segments.
- `CatmullRomSpline` stores dynamic control points, while `HermiteSpline` stores endpoints and tangent vectors.
- Normalized full-path sampling stays here because segment selection and local parameter mapping are spline semantics.
- Point insertion and removal also belong here since runtime path editing is part of the Catmull-Rom owner contract.
- Open it when spline interpolation behavior changes; Bezier paths and easing curves live in sibling modules.

### transform.rs

- This file owns the mutable 2D affine transform wrapper that accumulates translation, rotation, scale, and shear.
- `Transform` stores one `Mat3` and exposes chainable editing, inversion, point mapping, and component construction.
- SRT-plus-origin assembly stays here because transform composition order is a policy of this higher-level wrapper.
- Inverse mapping and decomposition also belong here since world-to-local conversion uses the owned matrix directly.
- Open it when transform-editing semantics change; raw matrix algebra lives in `mat3.rs`, not in this file.

### vec2.rs

- This file owns the core 2D vector primitive used for positions, directions, offsets, and planar numeric operations.
- `Vec2` stores x and y, while constants and methods expose dot, length, normalization, rotation, and reflection.
- Operator overloads stay here because arithmetic semantics are part of the vector type, not external helper policy.
- Angle, cross, lerp, distance, and `from_angle` also belong here since they derive directly from one 2D vector model.
- This file is the shared 2D numeric backbone, not a transform owner, curve editor, or collision broad-phase system.
- Open it when 2D vector semantics change; 3D vectors, matrices, and shapes live in sibling math modules.

### vec3.rs

- This file owns the compact 3D vector primitive used for cross products, directions, and three-axis numeric math.
- `Vec3` stores x, y, and z, while methods expose dot, cross, length, normalization, projection, and reflection.
- Arithmetic operator overloads stay here because component-wise addition, scaling, and negation are type semantics.
- Interpolation and distance also belong here since they derive directly from the owned three-component vector model.
- Open it when 3D vector semantics change; 2D vectors, transforms, and polygons live in sibling math modules.

### voronoi.rs

- This file owns Voronoi-cell construction from 2D points using Bowyer-Watson Delaunay triangulation underneath.
- `VoronoiCell` stores one site and its circumcenter polygon, while local helpers manage triangles and edge keys.
- Duplicate-point filtering and super-triangle setup stay here because they are part of this file's build contract.
- Circumcenter ordering and deduplication also belong here since stable CCW cell vertices define the result surface.
- Open it when Voronoi cell semantics change; generic triangulation helpers live in sibling geometry modules.



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
- `lurek.math.newWrapSpace(min_x, min_y, width, height) -> LWrapSpace`: Creates a pure toroidal-coordinate helper without changing world, ECS, or physics state.
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

#### LWrapSpace Type

- Reusable toroidal-coordinate helper for Lua games that choose wraparound world rules.

##### Fields

- No documented fields.

##### Methods

- `LWrapSpace:delta(ax, ay, bx, by) -> number`: Returns the shortest signed toroidal displacement from point A to point B.
- `LWrapSpace:distance(ax, ay, bx, by) -> number`: Returns the shortest toroidal distance between two points.
- `LWrapSpace:type() -> string`: Returns this helper's type name.
- `LWrapSpace:typeOf(name) -> boolean`: Checks this helper against its public type names.
- `LWrapSpace:wrap(x, y) -> number`: Wraps a point into this half-open toroidal domain.

## Examples

- `content/examples/math.lua` (present)

## Architecture Links

- Intentionally empty.

## Notes

- No additional module-specific notes.
