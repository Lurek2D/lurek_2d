# luna2d::math

_Source: `src/math/`_


Foundational math and value types for the Luna2D Baseline layer. This module is part of Luna2D's Baseline (`math` subsystem) — the leaf of the dependency graph with no Luna2D dependencies of its own. [`Color`] (`sRGB [f32; 4]`) lives here as a pure value type. It was moved from `src/graphics/srgb.rs` during the graphics-module-split session and is now the canonical color type for the entire engine. All public items are documented. See `docs/architecture.md` for tier context and the `luna.*` Lua API for the scripting interface.


## Types

### `BezierCurve`

A Bezier curve defined by control points. Uses De Casteljau's algorithm for evaluation. Minimum 2 control points required.


**Fields**

| Name | Type / Description |
|---|---|
| `control_points` | `Vec<Vec2>` |

#### Methods

##### `pub fn new(points: Vec<Vec2>) -> Self`

Create a new Bezier curve from control points.


**Parameters**

| Name | Type / Description |
|---|---|
| `points` | at least 2 `Vec2` control points defining the curve |

**Returns** `A `BezierCurve` with the given control points.`


**Panics** `Panics if fewer than 2 control points are provided.`


##### `pub fn evaluate(&self, t: f32) -> Vec2`

Evaluate the curve at parameter `t` using De Casteljau's algorithm.


**Parameters**

| Name | Type / Description |
|---|---|
| `t` | curve parameter in `[0.0, 1.0]`; 0 returns the first control point, 1 the last |

**Returns** `The point on the curve at `t`.`


##### `pub fn render(&self, segments: usize) -> Vec<Vec2>`

Render the curve as a polyline with the given number of segments.


**Parameters**

| Name | Type / Description |
|---|---|
| `segments` | number of line segments; clamped to at least 1 |

**Returns** `segments + 1` evenly-spaced `Vec2` points along the curve.`


##### `pub fn render_segment(&self, t_start: f32, t_end: f32, segments: usize) -> Vec<Vec2>`

Render a portion of the curve between `t_start` and `t_end`.


**Parameters**

| Name | Type / Description |
|---|---|
| `t_start` | start of the sub-curve parameter in `[0.0, 1.0]` |
| `t_end` | end of the sub-curve parameter in `[0.0, 1.0]` |
| `segments` | number of line segments; clamped to at least 1 |

**Returns** `segments + 1` `Vec2` points between `t_start` and `t_end`.`


##### `pub fn get_derivative(&self) -> BezierCurve`

Compute the derivative curve (one degree lower than the current curve).


**Returns** `A new `BezierCurve` representing the first derivative; useful for tangent direction queries.`


##### `pub fn get_control_point(&self, index: usize) -> Option<Vec2>`

Get a control point by 0-based index. This accessor incurs no allocation; call it freely in hot paths.


**Parameters**

| Name | Type / Description |
|---|---|
| `index` | 0-based control point index |

**Returns** `Some(Vec2)` if the index is in range, or `None` if out of bounds.`


##### `pub fn set_control_point(&mut self, index: usize, point: Vec2) -> bool`

Set a control point by 0-based index. Replaces the current control point value; callers hold responsibility for maintaining consistency with related fields.


**Parameters**

| Name | Type / Description |
|---|---|
| `index` | 0-based control point index |
| `point` | new position for the control point |

**Returns** `true` if the index was in range and the point was updated; `false` otherwise.`


##### `pub fn insert_control_point(&mut self, point: Vec2, index: Option<usize>)`

Insert a control point at a given index, or append if `index` is `None`.


**Parameters**

| Name | Type / Description |
|---|---|
| `point` | position of the new control point |
| `index` | 0-based insertion index; `None` appends at the end |

##### `pub fn remove_control_point(&mut self, index: usize) -> bool`

Remove a control point by 0-based index.


**Parameters**

| Name | Type / Description |
|---|---|
| `index` | 0-based index of the control point to remove |

**Returns** `false` if removal would leave fewer than 2 points, or if `index` is out of range.`


##### `pub fn get_control_point_count(&self) -> usize`

Get the number of control points. This accessor incurs no allocation; call it freely in hot paths.


**Returns** `Number of control points; always ≥ 2.`


##### `pub fn translate(&mut self, dx: f32, dy: f32)`

Translate all control points by `(dx, dy)`.


**Parameters**

| Name | Type / Description |
|---|---|
| `dx` | horizontal offset |
| `dy` | vertical offset |

##### `pub fn rotate(&mut self, angle: f32, ox: f32, oy: f32)`

Rotate all control points around a pivot `(ox, oy)` by `angle` radians.


**Parameters**

| Name | Type / Description |
|---|---|
| `angle` | rotation in radians |
| `ox` | pivot x coordinate |
| `oy` | pivot y coordinate |

##### `pub fn scale(&mut self, s: f32, ox: f32, oy: f32)`

Scale all control points around a pivot `(ox, oy)` by factor `s`.


**Parameters**

| Name | Type / Description |
|---|---|
| `s` | uniform scale factor |
| `ox` | pivot x coordinate |
| `oy` | pivot y coordinate |

##### `pub fn length(&self) -> f32`

Approximate the total arc length of the curve. Samples the curve at `100` equidistant parameter values and sums segment lengths. Accuracy improves with more control points that are closer together.


**Returns** `Approximate arc length in the same units as the control points.`


##### `pub fn get_interpolated_position(&self, t: f32) -> (f32, f32)`

Evaluate the curve position at parameter `t` and return it as an `(x, y)` tuple. Equivalent to `evaluate(t)` but returns a plain tuple for ergonomic Lua binding.


**Parameters**

| Name | Type / Description |
|---|---|
| `t` | curve parameter in `[0.0, 1.0]` |

**Returns** `(x, y)` position on the curve.`


##### `pub fn get_interpolated_angle(&self, t: f32) -> f32`

Return the angle of the curve tangent at parameter `t` in radians. Uses the first derivative curve to compute the tangent direction. Returns `0.0` when the tangent length is zero (degenerate curve section).


**Parameters**

| Name | Type / Description |
|---|---|
| `t` | curve parameter in `[0.0, 1.0]` |

**Returns** `Tangent angle in radians (`atan2(dy, dx)`).`


---

### `Color`

RGBA color stored as `f32` components in the range `[0.0, 1.0]`. Used everywhere the API accepts a color: `luna.graphics.setColor`, sprite tints, background color, etc.


**Fields**

| Name | Type / Description |
|---|---|
| `r` | Red channel, `[0.0, 1.0]` |
| `g` | Green channel, `[0.0, 1.0]` |
| `b` | Blue channel, `[0.0, 1.0]` |
| `a` | Alpha channel, `[0.0, 1.0]`; `1.0` = fully opaque |

#### Methods

##### `pub fn from_u8(r: u8, g: u8, b: u8, a: u8) -> Self`

Creates a color from `u8` RGBA components in `[0, 255]`, normalizing to `[0.0, 1.0]`.


**Parameters**

| Name | Type / Description |
|---|---|
| `r` | Red byte |
| `g` | Green byte |
| `b` | Blue byte |
| `a` | Alpha byte |

**Returns** `A new `Color` with components divided by 255.`


##### `pub fn to_u8(&self) -> (u8, u8, u8, u8)`

Converts the color to `u8` RGBA components, each in `[0, 255]`.


**Returns** `(u8, u8, u8, u8)` — `(red, green, blue, alpha)`.`


##### `pub fn to_rgb_u32(&self) -> u32`

Converts the color to a packed `u32` RGB value suitable for packed pixel buffers. Alpha is discarded. Bit layout: `0x00RRGGBB`.


**Returns** `u32` — Packed RGB value.`


---

### `Mat3`

A 3×3 column-major matrix used for 2D affine transforms (translation, rotation, scale). Used by `Camera::view_matrix` to combine position, rotation, and zoom into a single transform that maps world coordinates to screen coordinates.


**Fields**

| Name | Type / Description |
|---|---|
| `m` | 3×3 array of `f32` in row-major layout (`m[row][col]`) |

#### Methods

##### `pub fn identity() -> Self`

Returns the 3×3 identity matrix. Consult the module-level documentation for the broader usage context and preconditions.


**Returns** `Mat3` — Identity: no translation, no rotation, scale 1.`


##### `pub fn from_row_major(data: &[f32; 9]) -> Self`

Creates a `Mat3` from a flat 9-element array in row-major order.


**Parameters**

| Name | Type / Description |
|---|---|
| `data` | `&[f32; 9]` |

**Returns** `Self`.`


##### `pub fn from_translation(t: Vec2) -> Self`

Creates a translation matrix that moves points by `(t.x, t.y)`.


**Parameters**

| Name | Type / Description |
|---|---|
| `t` | Translation vector |

**Returns** `Mat3` — A pure translation matrix.`


##### `pub fn from_rotation(angle: f32) -> Self`

Creates a rotation matrix for a counter-clockwise rotation of `angle` radians.


**Parameters**

| Name | Type / Description |
|---|---|
| `angle` | Rotation in radians |

**Returns** `Mat3` — A pure rotation matrix.`


##### `pub fn from_shear(kx: f32, ky: f32) -> Self`

Creates a shear (skew) matrix. Returns a fully initialised instance with all fields set to their initial values.


**Parameters**

| Name | Type / Description |
|---|---|
| `kx` | Shear factor along the X axis |
| `ky` | Shear factor along the Y axis |

**Returns** `Mat3` — A pure shear matrix.`


##### `pub fn from_scale(scale: Vec2) -> Self`

Creates a non-uniform scale matrix with the given per-axis factors.


**Parameters**

| Name | Type / Description |
|---|---|
| `scale` | `Vec2` where `x` scales the X axis and `y` scales the Y axis |

**Returns** `Mat3` — A pure scale matrix.`


##### `pub fn inverse(&self) -> Self`

Compute the inverse of this 3×3 matrix. Consult the module-level documentation for the broader usage context and preconditions.


**Returns** `The inverse matrix, or the identity matrix if the determinant is ≈ 0.`


##### `pub fn transform_point(&self, p: Vec2) -> Vec2`

Applies the matrix transform to a 2D point using homogeneous coordinates.


**Parameters**

| Name | Type / Description |
|---|---|
| `p` | Input point in 2D space |

**Returns** `Vec2` — The transformed point.`


---

### `MapGenOptions`

Options for 2D noise map generation. Consult the module-level documentation for the broader usage context and preconditions.


**Fields**

| Name | Type / Description |
|---|---|
| `scale_x` | `f64` |
| `scale_y` | `f64` |
| `octaves` | `u32` |
| `lacunarity` | `f64` |
| `persistence` | `f64` |
| `kind` | `NoiseKind` |
| `fractal` | `FractalType` |
| `offset_x` | `f64` |
| `offset_y` | `f64` |
---

### `NoiseGenerator`

Seeded procedural noise generator. Consult the module-level documentation for the broader usage context and preconditions. Holds a 512-entry permutation table derived deterministically from the seed.  All noise methods are pure functions of the seed and coordinates — the same inputs always produce the same output.


**Fields**

| Name | Type / Description |
|---|---|
| `seed` | `u64` |
| `perm` | `[u8; 512]` |

#### Methods

##### `pub fn new(seed: u64) -> Self`

Creates a new generator with the given seed.


**Parameters**

| Name | Type / Description |
|---|---|
| `seed` | `u64` |

**Returns** `Self`.`


##### `pub fn set_seed(&mut self, seed: u64)`

Replaces the seed and rebuilds the permutation table.


**Parameters**

| Name | Type / Description |
|---|---|
| `seed` | `u64` |

##### `pub fn seed(&self) -> u64`

Returns the current seed. Consult the module-level documentation for the broader usage context and preconditions.


**Returns** `u64`.`


##### `pub fn perlin_1d(&self, x: f64) -> f64`

1D Perlin noise. Returns a value in approximately `[-1, 1]`.


**Parameters**

| Name | Type / Description |
|---|---|
| `x` | `f64` |

**Returns** `f64`.`


##### `pub fn perlin_2d(&self, x: f64, y: f64) -> f64`

2D Perlin noise. Returns a value in approximately `[-1, 1]`.


**Parameters**

| Name | Type / Description |
|---|---|
| `x` | `f64` |
| `y` | `f64` |

**Returns** `f64`.`


##### `pub fn perlin_3d(&self, x: f64, y: f64, z: f64) -> f64`

3D Perlin noise. Returns a value in approximately `[-1, 1]`.


**Parameters**

| Name | Type / Description |
|---|---|
| `x` | `f64` |
| `y` | `f64` |
| `z` | `f64` |

**Returns** `f64`.`


##### `pub fn perlin_4d(&self, x: f64, y: f64, z: f64, w: f64) -> f64`

4D Perlin noise. Returns a value in approximately `[-1, 1]`.


**Parameters**

| Name | Type / Description |
|---|---|
| `x` | `f64` |
| `y` | `f64` |
| `z` | `f64` |
| `w` | `f64` |

**Returns** `f64`.`


##### `pub fn simplex_1d(&self, x: f64) -> f64`

1D Simplex noise. Returns a value in approximately `[-1, 1]`.


**Parameters**

| Name | Type / Description |
|---|---|
| `x` | `f64` |

**Returns** `f64`.`


##### `pub fn simplex_2d(&self, x: f64, y: f64) -> f64`

2D Simplex noise. Returns a value in approximately `[-1, 1]`.


**Parameters**

| Name | Type / Description |
|---|---|
| `x` | `f64` |
| `y` | `f64` |

**Returns** `f64`.`


##### `pub fn simplex_3d(&self, x: f64, y: f64, z: f64) -> f64`

3D Simplex noise. Returns a value in approximately `[-1, 1]`.


**Parameters**

| Name | Type / Description |
|---|---|
| `x` | `f64` |
| `y` | `f64` |
| `z` | `f64` |

**Returns** `f64`.`


##### `pub fn worley_2d(&self, x: f64, y: f64, dist: DistType, f2: bool) -> f64`

2D Worley (cellular) noise. Returns a value in `[0, ~1]`. When `f2` is `false`, returns distance to nearest feature point. When `f2` is `true`, returns `F2 - F1` (cell border pattern).


**Parameters**

| Name | Type / Description |
|---|---|
| `x` | `f64` |
| `y` | `f64` |
| `dist` | `DistType` |
| `f2` | `bool` |

**Returns** `f64`.`


##### `pub fn worley_3d(&self, x: f64, y: f64, z: f64, dist: DistType, f2: bool) -> f64`

3D Worley (cellular) noise. Returns a value in `[0, ~1]`. When `f2` is `false`, returns distance to nearest feature point. When `f2` is `true`, returns `F2 - F1` (cell border pattern).


**Parameters**

| Name | Type / Description |
|---|---|
| `x` | `f64` |
| `y` | `f64` |
| `z` | `f64` |
| `dist` | `DistType` |
| `f2` | `bool` |

**Returns** `f64`.`


##### `pub fn fbm(&self, x: f64, y: f64, octaves: u32, lac: f64, pers: f64, kind: NoiseKind) -> f64`

Fractal Brownian motion — sum of octaves with decreasing amplitude.


**Parameters**

| Name | Type / Description |
|---|---|
| `x` | `f64` |
| `y` | `f64` |
| `octaves` | `u32` |
| `lac` | `f64` |
| `pers` | `f64` |
| `kind` | `NoiseKind` |

**Returns** `f64`.`


##### `pub fn warp_domain(&self, x: f64, y: f64, strength: f64) -> (f64, f64)`

Domain warping — offsets the input coordinates by noise, producing organic distortion. Returns the warped `(x, y)` pair.


**Parameters**

| Name | Type / Description |
|---|---|
| `x` | `f64` |
| `y` | `f64` |
| `strength` | `f64` |

**Returns** `(f64, f64)`.`


##### `pub fn generate_map(&self, width: u32, height: u32, opts: &MapGenOptions) -> Vec<f64>`

Generates a 2D noise map of `width * height` values using the given options. Values are stored in row-major order: `map[y * width + x]`.


**Parameters**

| Name | Type / Description |
|---|---|
| `width` | `u32` |
| `height` | `u32` |
| `opts` | `&MapGenOptions` |

**Returns** `Vec<f64>`.`


---

### `RandomGenerator`

Seedable random number generator exposed as a Lua object. Wraps `fastrand::Rng` with engine-compatible API for deterministic random number generation, normal distribution, and state management.


**Fields**

| Name | Type / Description |
|---|---|
| `rng` | `Rng` |
| `seed` | `u64` |

#### Methods

##### `pub fn new() -> Self`

Create a new generator with a random seed.


**Returns** `A `RandomGenerator` seeded from OS entropy.`


##### `pub fn with_seed(seed: u64) -> Self`

Create with a specific seed for deterministic sequences.


**Parameters**

| Name | Type / Description |
|---|---|
| `seed` | 64-bit seed; the same seed produces identical sequences |

**Returns** `A `RandomGenerator` with the given seed.`


##### `pub fn random(&mut self) -> f64`

Sample a uniform random value in `[0.0, 1.0)`.


**Returns** `A `f64` in the half-open interval `[0.0, 1.0)`.`


##### `pub fn random_int(&mut self, min: i64, max: i64) -> i64`

Sample a uniform random integer in `[min, max]` (inclusive).


**Parameters**

| Name | Type / Description |
|---|---|
| `min` | lower bound (inclusive) |
| `max` | upper bound (inclusive) |

**Returns** `A random `i64` in `[min, max]`; returns `min` if `min >= max`.`


##### `pub fn random_float(&mut self, min: f64, max: f64) -> f64`

Sample a uniform random float in `[min, max)`.


**Parameters**

| Name | Type / Description |
|---|---|
| `min` | lower bound (inclusive) |
| `max` | upper bound (exclusive) |

**Returns** `A `f64` uniformly distributed in `[min, max)`.`


##### `pub fn random_normal(&mut self, stddev: f64, mean: f64) -> f64`

Random number from normal (Gaussian) distribution using Box-Muller transform.


**Parameters**

| Name | Type / Description |
|---|---|
| `stddev` | standard deviation of the distribution |
| `mean` | mean (centre) of the distribution |

**Returns** `A `f64` sampled from N(mean, stddev²).`


##### `pub fn set_seed(&mut self, seed: u64)`

Set the seed, fully resetting the generator state.


**Parameters**

| Name | Type / Description |
|---|---|
| `seed` | new 64-bit seed |

##### `pub fn get_seed(&self) -> u64`

Get the seed that was used to initialise (or last reset) this generator.


**Returns** `The 64-bit seed value.`


##### `pub fn get_state(&self) -> String`

Serialise the generator state as a string for later restoration.


**Returns** `An opaque string that can be passed to `set_state()` to reproduce the same sequence.`


##### `pub fn set_state(&mut self, state: &str) -> Result<(), String>`

Restore the generator state from a previously serialised string.


**Parameters**

| Name | Type / Description |
|---|---|
| `state` | string previously returned by `get_state()` |

**Returns** `Ok(())` on success; `Err(String)` if the string cannot be parsed.`


---

### `Rect`

An axis-aligned rectangle defined by its top-left corner and dimensions. Used for AABB collision detection, UI layout, and camera viewport clipping.


**Fields**

| Name | Type / Description |
|---|---|
| `x` | X coordinate of the top-left corner |
| `y` | Y coordinate of the top-left corner |
| `width` | Width in pixels or world units |
| `height` | Height in pixels or world units |

#### Methods

##### `pub fn new(x: f32, y: f32, width: f32, height: f32) -> Self`

Creates a new `Rect` at `(x, y)` with the given `width` and `height`.


**Parameters**

| Name | Type / Description |
|---|---|
| `x` | Left edge X coordinate |
| `y` | Top edge Y coordinate |
| `width` | Rectangle width |
| `height` | Rectangle height |

**Returns** `A new `Rect`.`


##### `pub fn center(&self) -> Vec2`

Returns the center point of the rectangle.


**Returns** `Vec2` — The midpoint `(x + width/2, y + height/2)`.`


##### `pub fn area(&self) -> f32`

Returns the area of the rectangle. Consult the module-level documentation for the broader usage context and preconditions.


**Returns** `f32` — `width × height`.`


##### `pub fn contains(&self, point_x: f32, point_y: f32) -> bool`

Returns `true` if the given point lies within or on the boundary of the rectangle.


**Parameters**

| Name | Type / Description |
|---|---|
| `point_x` | X coordinate of the point to test |
| `point_y` | Y coordinate of the point to test |

**Returns** `bool` — `true` if the point is inside or on the edge.`


##### `pub fn intersects(&self, other: &Rect) -> bool`

Returns `true` if this rectangle overlaps with `other`. Touch (shared edge) is not considered an intersection; the overlap must be positive.


**Parameters**

| Name | Type / Description |
|---|---|
| `other` | The rectangle to test against |

**Returns** `bool` — `true` if the two rectangles have positive-area overlap.`


---

### `SpatialItem`

Entry in the spatial hash. Consult the module-level documentation for the broader usage context and preconditions.


**Fields**

| Name | Type / Description |
|---|---|
| `id` | `String` |
| `x` | `f32` |
| `y` | `f32` |
| `w` | `f32` |
| `h` | `f32` |
---

### `SpatialHash`

Spatial hash for AABB queries. Consult the module-level documentation for the broader usage context and preconditions. Divides the 2D plane into a uniform grid of square cells. Each item is inserted into every cell its bounding box overlaps, enabling fast broad-phase collision queries.


**Fields**

| Name | Type / Description |
|---|---|
| `cell_size` | `f32` |
| `items` | `HashMap<String` |
| `buckets` | `HashMap<(i32` |

#### Methods

##### `pub fn new(cell_size: f32) -> Self`

Creates an empty spatial hash with the given cell size.


**Returns** `Self`.`


**Parameters**

| Name | Type / Description |
|---|---|
| `cell_size` | Side length of each grid cell. Larger values mean fewer |

##### `pub fn cell_size(&self) -> f32`

Returns the cell size. Consult the module-level documentation for the broader usage context and preconditions.


**Returns** `f32`.`


##### `pub fn item_count(&self) -> usize`

Returns the number of items in the hash.


**Returns** `usize`.`


##### `pub fn insert(&mut self, id: String, x: f32, y: f32, w: f32, h: f32)`

Inserts an item with the given AABB. Consult the module-level documentation for the broader usage context and preconditions. If an item with the same `id` already exists it is replaced.


**Parameters**

| Name | Type / Description |
|---|---|
| `id` | `String` |
| `x` | `f32` |
| `y` | `f32` |
| `w` | `f32` |
| `h` | `f32` |

##### `pub fn remove(&mut self, id: &str)`

Removes an item by its ID. Consult the module-level documentation for the broader usage context and preconditions.


**Parameters**

| Name | Type / Description |
|---|---|
| `id` | `&str` |

##### `pub fn update(&mut self, id: String, x: f32, y: f32, w: f32, h: f32)`

Updates an existing item's AABB. Equivalent to remove + insert.


**Parameters**

| Name | Type / Description |
|---|---|
| `id` | `String` |
| `x` | `f32` |
| `y` | `f32` |
| `w` | `f32` |
| `h` | `f32` |

##### `pub fn clear(&mut self)`

Removes all items and clears all buckets.


##### `pub fn query_rect(&self, x: f32, y: f32, w: f32, h: f32) -> Vec<String>`

Returns the IDs of all items whose AABBs overlap the query rectangle.


**Parameters**

| Name | Type / Description |
|---|---|
| `x` | `f32` |
| `y` | `f32` |
| `w` | `f32` |
| `h` | `f32` |

**Returns** `Vec<String>`.`


##### `pub fn query_circle(&self, cx: f32, cy: f32, radius: f32) -> Vec<String>`

Returns the IDs of all items whose AABBs overlap the query circle. First queries the bounding rect, then filters by distance from the circle centre to the nearest point on each item's AABB.


**Parameters**

| Name | Type / Description |
|---|---|
| `cx` | `f32` |
| `cy` | `f32` |
| `radius` | `f32` |

**Returns** `Vec<String>`.`


##### `pub fn query_segment(&self, x1: f32, y1: f32, x2: f32, y2: f32) -> Vec<String>`

Returns the IDs of all items whose AABBs are intersected by a line Traverses cells along the segment and performs AABB–segment overlap tests on each candidate.


**Parameters**

| Name | Type / Description |
|---|---|
| `x1` | `f32` |
| `y1` | `f32` |
| `x2` | `f32` |
| `y2` | `f32` |

**Returns** `segment from `(x1, y1)` to `(x2, y2)`.`


---

### `Transform`

2D affine transform exposed as a Lua object. Wraps `Mat3` with chainable transformation methods matching the standard 2D transform API.


**Fields**

| Name | Type / Description |
|---|---|
| `matrix` | `Mat3` |

#### Methods

##### `pub fn new() -> Self`

Create an identity transform (no translation, rotation, or scale).


**Returns** `A `Transform` with identity matrix.`


##### `pub fn translate(&mut self, dx: f32, dy: f32) -> &mut Self`

Apply translation to the transform. Consult the module-level documentation for the broader usage context and preconditions.


**Parameters**

| Name | Type / Description |
|---|---|
| `dx` | horizontal offset |
| `dy` | vertical offset |

**Returns** `&mut Self` for method chaining.`


##### `pub fn rotate(&mut self, angle: f32) -> &mut Self`

Apply a rotation to the transform. Consult the module-level documentation for the broader usage context and preconditions.


**Parameters**

| Name | Type / Description |
|---|---|
| `angle` | rotation angle in radians |

**Returns** `&mut Self` for method chaining.`


##### `pub fn scale(&mut self, sx: f32, sy: f32) -> &mut Self`

Apply non-uniform scaling to the transform.


**Parameters**

| Name | Type / Description |
|---|---|
| `sx` | horizontal scale factor |
| `sy` | vertical scale factor |

**Returns** `&mut Self` for method chaining.`


##### `pub fn shear(&mut self, kx: f32, ky: f32) -> &mut Self`

Apply shear to the transform (standard convention).


**Parameters**

| Name | Type / Description |
|---|---|
| `kx` | horizontal shear factor |
| `ky` | vertical shear factor |

**Returns** `&mut Self` for method chaining.`


##### `pub fn reset(&mut self) -> &mut Self`

Reset the transform to the identity matrix.


**Returns** `&mut Self` for method chaining.`


##### `pub fn transform_point(&self, x: f32, y: f32) -> (f32, f32)`

Transform a point from local space to world space.


**Parameters**

| Name | Type / Description |
|---|---|
| `x` | local x coordinate |
| `y` | local y coordinate |

**Returns** `(world_x, world_y)` after applying this transform.`


##### `pub fn inverse_transform_point(&self, x: f32, y: f32) -> (f32, f32)`

Transform a point from world space back to local space.


**Parameters**

| Name | Type / Description |
|---|---|
| `x` | world x coordinate |
| `y` | world y coordinate |

**Returns** `(local_x, local_y)` after applying the inverse transform.`


##### `pub fn inverse(&self) -> Self`

Compute the inverse of this transform. Consult the module-level documentation for the broader usage context and preconditions.


**Returns** `A `Transform` that undoes this transform; composing them gives identity.`


##### `pub fn matrix(&self) -> &Mat3`

Get the internal matrix (for renderer integration).


**Returns** `A reference to the underlying `Mat3`.`


---

### `TweenValue`

A start-to-target value pair for interpolation.


**Fields**

| Name | Type / Description |
|---|---|
| `start` | `f64` |
| `target` | `f64` |
---

### `Tween`

Value interpolator using easing functions. Animates one or more values from start to target over a given duration, applying an easing curve to control the interpolation speed.


**Fields**

| Name | Type / Description |
|---|---|
| `duration` | `f64` |
| `easing_fn` | `fn(f32) -> f32` |
| `easing_name` | `String` |
| `clock` | `f64` |
| `values` | `Vec<TweenValue>` |

#### Methods

##### `pub fn new(duration: f64, easing_name: &str) -> Self`

Creates a new tween with the given duration and easing name. Falls back to linear if the easing name is not recognized.


**Parameters**

| Name | Type / Description |
|---|---|
| `duration` | `f64` |
| `easing_name` | `&str` |

**Returns** `Self`.`


##### `pub fn add_value(&mut self, start: f64, target: f64) -> usize`

Adds a value to interpolate. Returns the 0-based index.


**Parameters**

| Name | Type / Description |
|---|---|
| `start` | `f64` |
| `target` | `f64` |

**Returns** `usize`.`


##### `pub fn update(&mut self, dt: f64) -> bool`

Advances the clock by `dt` seconds. Returns `true` when the tween is complete.


**Parameters**

| Name | Type / Description |
|---|---|
| `dt` | `f64` |

**Returns** `bool`.`


##### `pub fn get_value(&self, index: usize) -> f64`

Returns the interpolated value at the given index.


**Parameters**

| Name | Type / Description |
|---|---|
| `index` | `usize` |

**Returns** `f64`.`


##### `pub fn get_all_values(&self) -> Vec<f64>`

Returns all interpolated values. This accessor incurs no allocation; call it freely in hot paths.


**Returns** `Vec<f64>`.`


##### `pub fn reset(&mut self)`

Resets the clock to 0. After this call the container is in the same state as immediately after construction.


##### `pub fn set_time(&mut self, t: f64)`

Sets the clock to a specific time, clamped to [0, duration].


**Parameters**

| Name | Type / Description |
|---|---|
| `t` | `f64` |

##### `pub fn is_complete(&self) -> bool`

Returns true if the tween has completed.


**Returns** `bool`.`


##### `pub fn value_count(&self) -> usize`

Returns the number of values in this tween.


**Returns** `usize`.`


##### `pub fn easing_name(&self) -> &str`

Returns the easing name. Consult the module-level documentation for the broader usage context and preconditions.


**Returns** `&str`.`


##### `pub fn duration(&self) -> f64`

Returns the duration. Consult the module-level documentation for the broader usage context and preconditions.


**Returns** `f64`.`


##### `pub fn clock(&self) -> f64`

Returns the current clock time. Consult the module-level documentation for the broader usage context and preconditions.


**Returns** `f64`.`


---

### `Vec2`

A 2D floating-point vector used throughout the engine for positions, velocities, and directions. Implements standard arithmetic operators (`+`, `-`, `*`, `/`, negation) and common geometric helpers. All operations are `Copy` — no references needed.


**Fields**

| Name | Type / Description |
|---|---|
| `x` | Horizontal component |
| `y` | Vertical component |

#### Methods

##### `pub fn new(x: f32, y: f32) -> Self`

Creates a new vector from `x` and `y` components.


**Parameters**

| Name | Type / Description |
|---|---|
| `x` | Horizontal component |
| `y` | Vertical component |

**Returns** `A new `Vec2`.`


##### `pub fn zero() -> Self`

Returns the zero vector `(0.0, 0.0)`. Consult the module-level documentation for the broader usage context and preconditions. Equivalent to `Vec2::ZERO`; provided for ergonomics.


**Returns** `Vec2::ZERO`.`


##### `pub fn splat(v: f32) -> Self`

Creates a vector with both components set to `v`.


**Parameters**

| Name | Type / Description |
|---|---|
| `v` | Value for both `x` and `y` |

**Returns** `Vec2 { x: v, y: v }`.`


##### `pub fn dot(self, other: Vec2) -> f32`

Returns the dot product of this vector and `other`.


**Parameters**

| Name | Type / Description |
|---|---|
| `other` | The second vector |

**Returns** `f32` — The scalar dot product.`


##### `pub fn length(self) -> f32`

Returns the Euclidean length (magnitude) of the vector.


**Returns** `f32` — `√(x² + y²)`.`


##### `pub fn length_squared(self) -> f32`

Returns the squared Euclidean length of the vector. Cheaper than `length` when only comparing magnitudes.


**Returns** `f32` — `x² + y²`.`


##### `pub fn normalize(self) -> Vec2`

Returns a unit vector in the same direction, or the original vector if its length is zero.


**Returns** `Vec2` — Normalized vector with length 1, or `self` if `length() == 0`.`


##### `pub fn distance(self, other: Vec2) -> f32`

Returns the Euclidean distance between this point and `other`.


**Parameters**

| Name | Type / Description |
|---|---|
| `other` | The target point |

**Returns** `f32` — Distance between the two points.`


##### `pub fn lerp(self, other: Vec2, t: f32) -> Vec2`

Linearly interpolates between `self` and `other` by factor `t`. `t = 0.0` returns `self`; `t = 1.0` returns `other`; values outside `[0, 1]` extrapolate.


**Parameters**

| Name | Type / Description |
|---|---|
| `other` | Target vector |
| `t` | Interpolation factor |

**Returns** `Vec2` — Interpolated vector.`


##### `pub fn angle(self) -> f32`

Returns the angle of the vector in radians, measured from the positive X axis.


**Returns** `f32` — Angle in radians using `atan2(y, x)`.`


##### `pub fn rotate(self, angle: f32) -> Vec2`

Returns a copy of this vector rotated by `angle` radians around the origin.


**Parameters**

| Name | Type / Description |
|---|---|
| `angle` | Rotation angle in radians |

**Returns** `Vec2` — The rotated vector.`


##### `pub fn perpendicular(self) -> Vec2`

Returns the perpendicular (normal) vector, rotated 90° counter-clockwise.


**Returns** `Vec2` — `(-y, x)`.`


##### `pub fn cross(self, other: Vec2) -> f32`

Returns the 2D cross product (perpendicular dot product) with `other`. This is the z-component of the 3D cross product when z=0. Positive if `other` is counter-clockwise from `self`, negative if clockwise.


**Parameters**

| Name | Type / Description |
|---|---|
| `other` | The second vector |

**Returns** `f32` — `self.x * other.y - self.y * other.x`.`


---


## Enums

### `DistType`

Distance metric for Worley noise. Consult the module-level documentation for the broader usage context and preconditions.


**Variants**

| Name | Type / Description |
|---|---|
| `Euclidean` | Euclidean variant |
| `Manhattan` | Manhattan variant |
| `Chebyshev` | Chebyshev variant |
---

### `NoiseKind`

Noise algorithm kind used by fractal combinators.


**Variants**

| Name | Type / Description |
|---|---|
| `Perlin` | Perlin variant |
| `Simplex` | Simplex variant |
---

### `FractalType`

Fractal type for multi-octave noise. Consult the module-level documentation for the broader usage context and preconditions.


**Variants**

| Name | Type / Description |
|---|---|
| `Fbm` | Fbm variant |
| `Ridged` | Ridged variant |
| `Turbulence` | Turbulence variant |
---


## Functions

### `pub fn gamma_to_linear(c: f32) -> f32`

Convert a single sRGB gamma-space color component to linear space. Input and output in `[0.0, 1.0]`. Uses the standard IEC 61966-2-1 sRGB transfer function.


**Parameters**

| Name | Type / Description |
|---|---|
| `c` | gamma-encoded sRGB channel value in `[0.0, 1.0]` |

**Returns** `Linear-light value in `[0.0, 1.0]`.`

---

### `pub fn linear_to_gamma(c: f32) -> f32`

Convert a single linear-space color component to sRGB gamma space. Input and output in `[0.0, 1.0]`. Uses the standard IEC 61966-2-1 sRGB inverse transfer function.


**Parameters**

| Name | Type / Description |
|---|---|
| `c` | linear-light channel value in `[0.0, 1.0]` |

**Returns** `Gamma-encoded sRGB value in `[0.0, 1.0]`.`

---

### `pub fn linear(t: f32) -> f32`

Linear interpolation — no easing. Consult the module-level documentation for the broader usage context and preconditions.


**Parameters**

| Name | Type / Description |
|---|---|
| `t` | normalised progress value in `[0.0, 1.0]` |

**Returns** `Eased output; typically in `[0.0, 1.0]` (may overshoot for elastic, back, and bounce curves).`

---

### `pub fn ease_in_quad(t: f32) -> f32`

Quadratic ease-in — starts slow, accelerates.


**Parameters**

| Name | Type / Description |
|---|---|
| `t` | normalised progress value in `[0.0, 1.0]` |

**Returns** `Eased output; typically in `[0.0, 1.0]` (may overshoot for elastic, back, and bounce curves).`

---

### `pub fn ease_out_quad(t: f32) -> f32`

Quadratic ease-out — starts fast, decelerates.


**Parameters**

| Name | Type / Description |
|---|---|
| `t` | normalised progress value in `[0.0, 1.0]` |

**Returns** `Eased output; typically in `[0.0, 1.0]` (may overshoot for elastic, back, and bounce curves).`

---

### `pub fn ease_in_out_quad(t: f32) -> f32`

Quadratic ease-in-out — slow start and end, fast middle.


**Parameters**

| Name | Type / Description |
|---|---|
| `t` | normalised progress value in `[0.0, 1.0]` |

**Returns** `Eased output; typically in `[0.0, 1.0]` (may overshoot for elastic, back, and bounce curves).`

---

### `pub fn ease_in_cubic(t: f32) -> f32`

Cubic ease-in — starts slow, accelerates sharply.


**Parameters**

| Name | Type / Description |
|---|---|
| `t` | normalised progress value in `[0.0, 1.0]` |

**Returns** `Eased output; typically in `[0.0, 1.0]` (may overshoot for elastic, back, and bounce curves).`

---

### `pub fn ease_out_cubic(t: f32) -> f32`

Cubic ease-out — starts fast, decelerates sharply.


**Parameters**

| Name | Type / Description |
|---|---|
| `t` | normalised progress value in `[0.0, 1.0]` |

**Returns** `Eased output; typically in `[0.0, 1.0]` (may overshoot for elastic, back, and bounce curves).`

---

### `pub fn ease_in_out_cubic(t: f32) -> f32`

Cubic ease-in-out — smooth S-curve. Consult the module-level documentation for the broader usage context and preconditions.


**Parameters**

| Name | Type / Description |
|---|---|
| `t` | normalised progress value in `[0.0, 1.0]` |

**Returns** `Eased output; typically in `[0.0, 1.0]` (may overshoot for elastic, back, and bounce curves).`

---

### `pub fn ease_in_quart(t: f32) -> f32`

Quartic ease-in — very slow start. Consult the module-level documentation for the broader usage context and preconditions.


**Parameters**

| Name | Type / Description |
|---|---|
| `t` | normalised progress value in `[0.0, 1.0]` |

**Returns** `Eased output; typically in `[0.0, 1.0]` (may overshoot for elastic, back, and bounce curves).`

---

### `pub fn ease_out_quart(t: f32) -> f32`

Quartic ease-out — very slow end. Consult the module-level documentation for the broader usage context and preconditions.


**Parameters**

| Name | Type / Description |
|---|---|
| `t` | normalised progress value in `[0.0, 1.0]` |

**Returns** `Eased output; typically in `[0.0, 1.0]` (may overshoot for elastic, back, and bounce curves).`

---

### `pub fn ease_in_out_quart(t: f32) -> f32`

Quartic ease-in-out — pronounced S-curve.


**Parameters**

| Name | Type / Description |
|---|---|
| `t` | normalised progress value in `[0.0, 1.0]` |

**Returns** `Eased output; typically in `[0.0, 1.0]` (may overshoot for elastic, back, and bounce curves).`

---

### `pub fn ease_in_sine(t: f32) -> f32`

Sinusoidal ease-in — gentle sine-based acceleration.


**Parameters**

| Name | Type / Description |
|---|---|
| `t` | normalised progress value in `[0.0, 1.0]` |

**Returns** `Eased output; typically in `[0.0, 1.0]` (may overshoot for elastic, back, and bounce curves).`

---

### `pub fn ease_out_sine(t: f32) -> f32`

Sinusoidal ease-out — gentle sine-based deceleration.


**Parameters**

| Name | Type / Description |
|---|---|
| `t` | normalised progress value in `[0.0, 1.0]` |

**Returns** `Eased output; typically in `[0.0, 1.0]` (may overshoot for elastic, back, and bounce curves).`

---

### `pub fn ease_in_out_sine(t: f32) -> f32`

Sinusoidal ease-in-out — gentle S-curve.


**Parameters**

| Name | Type / Description |
|---|---|
| `t` | normalised progress value in `[0.0, 1.0]` |

**Returns** `Eased output; typically in `[0.0, 1.0]` (may overshoot for elastic, back, and bounce curves).`

---

### `pub fn ease_in_expo(t: f32) -> f32`

Exponential ease-in — very slow start, rapid acceleration.


**Parameters**

| Name | Type / Description |
|---|---|
| `t` | normalised progress value in `[0.0, 1.0]` |

**Returns** `Eased output; typically in `[0.0, 1.0]` (may overshoot for elastic, back, and bounce curves).`

---

### `pub fn ease_out_expo(t: f32) -> f32`

Exponential ease-out — rapid start, very slow end.


**Parameters**

| Name | Type / Description |
|---|---|
| `t` | normalised progress value in `[0.0, 1.0]` |

**Returns** `Eased output; typically in `[0.0, 1.0]` (may overshoot for elastic, back, and bounce curves).`

---

### `pub fn ease_in_out_expo(t: f32) -> f32`

Exponential ease-in-out — sharp S-curve with exponential tails.


**Parameters**

| Name | Type / Description |
|---|---|
| `t` | normalised progress value in `[0.0, 1.0]` |

**Returns** `Eased output; typically in `[0.0, 1.0]` (may overshoot for elastic, back, and bounce curves).`

---

### `pub fn ease_in_elastic(t: f32) -> f32`

Elastic ease-in — spring-like overshoot at the start.


**Parameters**

| Name | Type / Description |
|---|---|
| `t` | normalised progress value in `[0.0, 1.0]` |

**Returns** `Eased output; typically in `[0.0, 1.0]` (may overshoot for elastic, back, and bounce curves).`

---

### `pub fn ease_out_elastic(t: f32) -> f32`

Elastic ease-out — spring-like overshoot at the end.


**Parameters**

| Name | Type / Description |
|---|---|
| `t` | normalised progress value in `[0.0, 1.0]` |

**Returns** `Eased output; typically in `[0.0, 1.0]` (may overshoot for elastic, back, and bounce curves).`

---

### `pub fn ease_out_bounce(t: f32) -> f32`

Bounce ease-out — simulates a bouncing ball landing.


**Parameters**

| Name | Type / Description |
|---|---|
| `t` | normalised progress value in `[0.0, 1.0]` |

**Returns** `Eased output; typically in `[0.0, 1.0]` (may overshoot for elastic, back, and bounce curves).`

---

### `pub fn ease_in_bounce(t: f32) -> f32`

Bounce ease-in — simulates a bouncing ball launching.


**Parameters**

| Name | Type / Description |
|---|---|
| `t` | normalised progress value in `[0.0, 1.0]` |

**Returns** `Eased output; typically in `[0.0, 1.0]` (may overshoot for elastic, back, and bounce curves).`

---

### `pub fn ease_in_back(t: f32) -> f32`

Back ease-in — pulls back before accelerating past the start.


**Parameters**

| Name | Type / Description |
|---|---|
| `t` | normalised progress value in `[0.0, 1.0]` |

**Returns** `Eased output; typically in `[0.0, 1.0]` (may overshoot for elastic, back, and bounce curves).`

---

### `pub fn ease_out_back(t: f32) -> f32`

Back ease-out — overshoots the target then settles back.


**Parameters**

| Name | Type / Description |
|---|---|
| `t` | normalised progress value in `[0.0, 1.0]` |

**Returns** `Eased output; typically in `[0.0, 1.0]` (may overshoot for elastic, back, and bounce curves).`

---

### `pub fn apply(name: &str, t: f32) -> Option<f32>`

Looks up an easing function by name and applies it to progress value `t`. Supported names (case-insensitive): `"linear"`, `"inQuad"`, `"outQuad"`, `"inOutQuad"`, `"inCubic"`, `"outCubic"`, `"inOutCubic"`, `"inQuart"`, `"outQuart"`, `"inOutQuart"`, `"inSine"`, `"outSine"`, `"inOutSine"`, `"inExpo"`, `"outExpo"`, `"inOutExpo"`, `"inElastic"`, `"outElastic"`, `"outBounce"`, `"inBounce"`, `"inBack"`, `"outBack"`.


**Parameters**

| Name | Type / Description |
|---|---|
| `name` | easing name string (case-insensitive) |
| `t` | normalised progress value in `[0.0, 1.0]` |

**Returns** `Some(f32)` with the eased value, or `None` if the name is unrecognised.`

---

### `pub fn angle_between(x1: f32, y1: f32, x2: f32, y2: f32) -> f32`

Returns the angle in radians from (x1, y1) to (x2, y2).


**Parameters**

| Name | Type / Description |
|---|---|
| `x1` | `f32` |
| `y1` | `f32` |
| `x2` | `f32` |
| `y2` | `f32` |

**Returns** `f32`.`

---

### `pub fn circle_contains_point(cx: f32, cy: f32, r: f32, px: f32, py: f32) -> bool`

Returns true if the point (px, py) is inside the circle centered at (cx, cy) with radius r.


**Parameters**

| Name | Type / Description |
|---|---|
| `cx` | `f32` |
| `cy` | `f32` |
| `r` | `f32` |
| `px` | `f32` |
| `py` | `f32` |

**Returns** `bool`.`

---

### `pub fn circle_intersects_circle(x1: f32, y1: f32, r1: f32, x2: f32, y2: f32, r2: f32) -> bool`

Returns true if two circles overlap. Consult the module-level documentation for the broader usage context and preconditions.


**Parameters**

| Name | Type / Description |
|---|---|
| `x1` | `f32` |
| `y1` | `f32` |
| `r1` | `f32` |
| `x2` | `f32` |
| `y2` | `f32` |
| `r2` | `f32` |

**Returns** `bool`.`

---

### `pub fn polygon_area(vertices: &[f32]) -> f32`

Computes the signed area of a polygon using the Shoelace formula. `vertices` is a flat array `[x0, y0, x1, y1, ...]`.


**Parameters**

| Name | Type / Description |
|---|---|
| `vertices` | `&[f32]` |

**Returns** `f32`.`

---

### `pub fn polygon_centroid(vertices: &[f32]) -> (f32, f32)`

Computes the centroid of a polygon. Consult the module-level documentation for the broader usage context and preconditions. `vertices` is a flat array `[x0, y0, x1, y1, ...]`.


**Parameters**

| Name | Type / Description |
|---|---|
| `vertices` | `&[f32]` |

**Returns** `(f32, f32)`.`

---

### `pub fn point_in_polygon(vertices: &[f32], px: f32, py: f32) -> bool`

Tests if a point is inside a polygon using the ray casting algorithm. `vertices` is a flat array `[x0, y0, x1, y1, ...]`.


**Parameters**

| Name | Type / Description |
|---|---|
| `vertices` | `&[f32]` |
| `px` | `f32` |
| `py` | `f32` |

**Returns** `bool`.`

---

### `pub fn bresenham(x1: i32, y1: i32, x2: i32, y2: i32) -> Vec<(i32, i32)>`

Bresenham line rasterization from (x1, y1) to (x2, y2). Returns all integer grid cells the line passes through.


**Parameters**

| Name | Type / Description |
|---|---|
| `x1` | `i32` |
| `y1` | `i32` |
| `x2` | `i32` |
| `y2` | `i32` |

**Returns** `Vec<(i32, i32)>`.`

---

### `pub fn convex_hull(points: &[f32]) -> Vec<f32>`

Computes the convex hull of a set of 2D points using Andrew's monotone chain algorithm. `points` is a flat array `[x0, y0, x1, y1, ...]`. Returns flat `[x0, y0, ...]`.


**Parameters**

| Name | Type / Description |
|---|---|
| `points` | `&[f32]` |

**Returns** `Vec<f32>`.`

---

### `pub fn perlin2d(x: f32, y: f32, seed: u32) -> f32`

Generates 2D Perlin noise at the given coordinates.


**Parameters**

| Name | Type / Description |
|---|---|
| `x` | X coordinate in noise space |
| `y` | Y coordinate in noise space |
| `seed` | numeric seed to vary the noise pattern |

**Returns** `A value in approximately `[-1.0, 1.0]`.`

---

### `pub fn simplex2d(x: f32, y: f32, seed: u32) -> f32`

Generates 2D Simplex noise at the given coordinates.


**Parameters**

| Name | Type / Description |
|---|---|
| `x` | X coordinate in noise space |
| `y` | Y coordinate in noise space |
| `seed` | numeric seed to vary the noise pattern |

**Returns** `A value in approximately `[-1.0, 1.0]`.`

---

### `pub fn simplex_noise_2d(x: f32, y: f32) -> f32`

Returns 2D simplex noise for the given coordinates using seed 0. Convenience wrapper around [`simplex2d`] with a fixed seed of `0`. Use [`NoiseGenerator::simplexNoise`] for seeded output.


**Parameters**

| Name | Type / Description |
|---|---|
| `x` | X coordinate in noise space |
| `y` | Y coordinate in noise space |

**Returns** `A value in approximately `[-1.0, 1.0]`.`

---

### `pub fn simplex_noise_3d(x: f32, y: f32, z: f32) -> f32`

Returns 3D simplex noise for the given coordinates using seed 0. Delegates to [`NoiseGenerator::simplex_3d`] with seed `0`.


**Parameters**

| Name | Type / Description |
|---|---|
| `x` | X coordinate in noise space |
| `y` | Y coordinate in noise space |
| `z` | Z coordinate in noise space |

**Returns** `A value in approximately `[-1.0, 1.0]`.`

---

### `pub fn fbm(x: f32, y: f32, seed: u32, octaves: u32, lacunarity: f32, gain: f32) -> f32`

Generates fractal Brownian motion noise by layering multiple octaves of Perlin noise.


**Parameters**

| Name | Type / Description |
|---|---|
| `x` | X coordinate in noise space |
| `y` | Y coordinate in noise space |
| `seed` | numeric seed |
| `octaves` | number of noise layers (1–8 typical) |
| `lacunarity` | frequency multiplier per octave (typical: 2.0) |
| `gain` | amplitude multiplier per octave (typical: 0.5) |

**Returns** `A value centred around `0.0` in approximately `[-1.0, 1.0]`.`

---

### `pub fn perlin3d(x: f32, y: f32, z: f32, seed: u32) -> f32`

Generates 3D Perlin noise at the given coordinates.


**Parameters**

| Name | Type / Description |
|---|---|
| `x` | X coordinate in noise space |
| `y` | Y coordinate in noise space |
| `z` | Z coordinate in noise space |
| `seed` | numeric seed to vary the noise pattern |

**Returns** `A value in approximately `[-1.0, 1.0]`.`

---

### `pub fn perlin4d(x: f32, y: f32, z: f32, w_coord: f32, seed: u32) -> f32`

Generates 4D Perlin noise at the given coordinates.


**Parameters**

| Name | Type / Description |
|---|---|
| `x` | X coordinate in noise space |
| `y` | Y coordinate in noise space |
| `z` | Z coordinate in noise space |
| `w_coord` | W coordinate in noise space |
| `seed` | numeric seed to vary the noise pattern |

**Returns** `A value in approximately `[-1.0, 1.0]`.`

---

### `pub fn triangulate(polygon: &[Vec2]) -> Result<Vec<[Vec2; 3]>, String>`

Triangulate a simple polygon using the ear-clipping algorithm.


**Parameters**

| Name | Type / Description |
|---|---|
| `polygon` | slice of `Vec2` vertices forming a simple (non-self-intersecting) polygon; |

**Returns** `Err(String)` — if triangulation fails (e.g. self-intersecting or degenerate input).`

---

### `pub fn is_convex(polygon: &[Vec2]) -> bool`

Check if a polygon is convex. This accessor incurs no allocation; call it freely in hot paths. Uses cross-product sign consistency at each vertex to determine convexity.


**Parameters**

| Name | Type / Description |
|---|---|
| `polygon` | slice of `Vec2` vertices |

**Returns** `true` if the polygon is convex; `false` if concave, self-intersecting, or fewer than 3 vertices.`

---
