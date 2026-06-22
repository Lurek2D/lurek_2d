# Compute

## Purpose

Manages dense array math, linear algebra, and FFT transforms.

## When To Use

- Multidimensional arrays, element-wise operations, reductions, and in-place math make it practical to treat data as a structured computation surface instead of hand-written Lua loops over raw tables.
- Linear algebra, decompositions, and solver-style helpers extend that into simulation, optimization, and transform-oriented workloads where matrix logic must stay explicit and reusable.
- FFT, convolution, morphology, spatial processing, and statistics push the module beyond generic arithmetic, so image-like grids, signal data, and analytics pipelines can all live under one API surface.

## Minimal Example

From the `lurek.compute.newArray` example block:

```lua
do
    local spawn_weights = lurek.compute.newArray({4, 4}, "float32")
    spawn_weights:set(1, 1, 0.25)
    spawn_weights:set(4, 4, 0.75)
    local shape = shape_text(spawn_weights)
    compute_log("spawn weight grid=" .. shape .. " corners=" .. spawn_weights:get(1, 1) .. "/" .. spawn_weights:get(4, 4))
end
```

## Common Patterns

- Start with `lurek.compute.affine2d` when exploring this module.
- Start with `lurek.compute.fft` when exploring this module.
- Start with `lurek.compute.fftMagnitude` when exploring this module.
- Start with `lurek.compute.fromTable` when exploring this module.
- Start with `lurek.compute.gaussianKernel` when exploring this module.

## API Reference

- Full generated API reference: [docs/api/lurek.md](../api/lurek.md)
- Runnable example owner: `content/examples/compute.lua`

## Summary

- The `compute` module is the dense numeric workspace for users who want array-heavy processing, analysis, and transformation logic inside the engine.
- Multidimensional arrays, element-wise operations, reductions, and in-place math make it practical to treat data as a structured computation surface instead of hand-written Lua loops over raw tables.
- Linear algebra, decompositions, and solver-style helpers extend that into simulation, optimization, and transform-oriented workloads where matrix logic must stay explicit and reusable.
- FFT, convolution, morphology, spatial processing, and statistics push the module beyond generic arithmetic, so image-like grids, signal data, and analytics pipelines can all live under one API surface.
- Parallel thresholds and typed operations matter from a user perspective because the same script-facing module can scale from quick experimentation to heavier numeric workloads without changing conceptual models.
- The module is also a useful bridge for neighboring numeric systems such as image processing, signal work, procedural analysis, and learning-oriented workloads because they often need dense arrays before they need a more specialized domain API.
- Deterministic typed array behavior matters for tooling and tests as much as for performance. Users can prototype a transform interactively and still keep the same operations reproducible enough for validation or batch workflows.
- This gives the engine a practical middle layer between generic Lua tables and fully specialized numeric subsystems.
- Read `compute` as the engine feature that turns numerical data processing into a first-class runtime capability rather than an external preprocessing step.

This module is mostly self-contained inside the Foundations group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Functions

### `lurek.compute.affine2d`

Creates a 2D affine transform matrix.

```lua
lurek.compute.affine2d(tx, ty, angle_rad, sx, sy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tx` | number | Translation X component. |
| `ty` | number | Translation Y component. |
| `angle_rad` | number | Rotation angle in radians. |
| `sx` | number | Scale X component. |
| `sy` | number | Scale Y component. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New affine transform matrix array. |

**Example**

```lua
do
    local camera_move = lurek.compute.affine2d(10, 20, 0, 1, 1)
    local point = lurek.compute.fromTable({0, 0}, {1, 2})
    local moved = camera_move:transformPoints(point)
    local tx = moved:get(1, 1)
    compute_log("camera transform moved x from 0 to " .. tx .. " with tx=" .. camera_move:get(1, 3))
end
```

---

### `lurek.compute.fft`

Computes the FFT of real-valued samples.

```lua
lurek.compute.fft(samples)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `samples` | table | Array table of real-valued samples. |

**Returns**

| Type | Description |
|------|-------------|
| LComputeFftResult | Array table of complex pairs with `re` and `im` fields. |

**Example**

```lua
do
    local samples = {1, 0, -1, 0}
    local spectrum = lurek.compute.fft(samples)
    local bin = spectrum[2]
    local magnitude = math.abs(bin.re) + math.abs(bin.im)
    compute_log("looped pulse fft bins=" .. #spectrum .. " bin2_energy=" .. tostring(magnitude))
end
```

---

### `lurek.compute.fftMagnitude`

Computes FFT magnitudes for real-valued samples.

```lua
lurek.compute.fftMagnitude(samples)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `samples` | table | Array table of real-valued samples. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of magnitude values. |

**Example**

```lua
do
    local samples = {1, 0, -1, 0}
    local magnitudes = lurek.compute.fftMagnitude(samples)
    local peak = math.max(magnitudes[1], magnitudes[2], magnitudes[3], magnitudes[4])
    local dc = magnitudes[1]
    compute_log("fft magnitudes count=" .. #magnitudes .. " peak=" .. tostring(peak) .. " dc=" .. tostring(dc))
end
```

---

### `lurek.compute.fromTable`

Creates an array from a flat Lua table and optional shape.

```lua
lurek.compute.fromTable(data, shape, dtype)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | table | Array table of numeric values. |
| `shape?` | table | Optional array table of positive dimension sizes. |
| `dtype?` | string | Data type name; defaults to `float32`. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array handle containing table values. |

**Example**

```lua
do
    local loot_table = lurek.compute.fromTable({5, 8, 13, 21, 34, 55}, {2, 3})
    local shape = shape_text(loot_table)
    local rare_slot = loot_table:get(2, 2)
    local boss_slot = loot_table:get(2, 3)
    compute_log("loot matrix=" .. shape .. " rare=" .. rare_slot .. " boss=" .. boss_slot)
end
```

---

### `lurek.compute.gaussianKernel`

Creates a square Gaussian kernel array.

```lua
lurek.compute.gaussianKernel(size, sigma)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `size` | number | Kernel width and height. |
| `sigma` | number | Gaussian sigma value. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New Gaussian kernel array. |

**Example**

```lua
do
    local blur_kernel = lurek.compute.gaussianKernel(5, 1.0)
    local center = blur_kernel:get(3, 3)
    local total = blur_kernel:sum()
    local shape = shape_text(blur_kernel)
    compute_log("blur kernel=" .. shape .. " center=" .. center .. " sum=" .. total)
end
```

---

### `lurek.compute.getParThreshold`

Returns the global compute parallelism threshold.

```lua
lurek.compute.getParThreshold()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current parallel threshold. |

**Example**

```lua
do
    local threshold = lurek.compute.getParThreshold()
    local matrix = lurek.compute.newArray({32, 32})
    local size = matrix:getSize()
    local should_parallelize = size >= threshold
    compute_log("parallel threshold=" .. threshold .. " matrix_size=" .. size .. " parallel=" .. tostring(should_parallelize))
end
```

---

### `lurek.compute.ifft`

Computes the inverse FFT of complex frequency pairs.

```lua
lurek.compute.ifft(freqs)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `freqs` | table | Array table of complex pairs with `re` and `im` fields. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of reconstructed real-valued samples. |

**Example**

```lua
do
    local original = {1, 0, -1, 0}
    local spectrum = lurek.compute.fft(original)
    local rebuilt = lurek.compute.ifft(spectrum)
    local first = rebuilt[1]
    local drift = math.abs(first - original[1])
    compute_log("ifft rebuilt " .. #rebuilt .. " samples with first_sample_drift=" .. tostring(drift))
end
```

---

### `lurek.compute.newArray`

Creates a zero-filled array with the requested shape and data type.

```lua
lurek.compute.newArray(shape, dtype)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shape` | table | Array table of positive dimension sizes. |
| `dtype?` | string | Data type name; defaults to `float32`. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New zero-filled array handle. |

**Example**

```lua
do
    local spawn_weights = lurek.compute.newArray({4, 4}, "float32")
    spawn_weights:set(1, 1, 0.25)
    spawn_weights:set(4, 4, 0.75)
    local shape = shape_text(spawn_weights)
    compute_log("spawn weight grid=" .. shape .. " corners=" .. spawn_weights:get(1, 1) .. "/" .. spawn_weights:get(4, 4))
end
```

---

### `lurek.compute.ones`

Creates a one-filled array with the requested shape and data type.

```lua
lurek.compute.ones(shape, dtype)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shape` | table | Array table of positive dimension sizes. |
| `dtype?` | string | Data type name; defaults to `float32`. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New one-filled array handle. |

**Example**

```lua
do
    local flood_mask = lurek.compute.ones({2, 5}, "float32")
    local total = flood_mask:sum()
    local shape = shape_text(flood_mask)
    local edge = flood_mask:get(1, 5)
    compute_log("full flood mask=" .. shape .. " sum=" .. total .. " edge=" .. edge)
end
```

---

### `lurek.compute.range`

Creates a one-dimensional range array.

```lua
lurek.compute.range(start, stop, step, dtype)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `start` | number | First value in the range. |
| `stop` | number | Stop value for the range. |
| `step?` | number | Step size; defaults to 1.0. |
| `dtype?` | string | Data type name; defaults to `float32`. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New range array handle. |

**Example**

```lua
do
    local frame_marks = lurek.compute.range(0, 10, 2, "float32")
    local shape = shape_text(frame_marks)
    local total = frame_marks:getSize()
    local last = frame_marks:get(total)
    compute_log("frame checkpoints shape=" .. shape .. " count=" .. total .. " last=" .. last)
end
```

---

### `lurek.compute.rotate2dMatrix`

Creates a 2D rotation matrix from an angle in radians.

```lua
lurek.compute.rotate2dMatrix(angle_rad)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `angle_rad` | number | Rotation angle in radians. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New rotation matrix array. |

**Example**

```lua
do
    local facing_turn = lurek.compute.rotate2dMatrix(math.pi / 4)
    local row_x = facing_turn:get(1, 1)
    local row_y = facing_turn:get(1, 2)
    local shape = shape_text(facing_turn)
    compute_log("45 degree facing matrix=" .. shape .. " row=(" .. row_x .. "," .. row_y .. ")")
end
```

---

### `lurek.compute.setParThreshold`

Sets the global compute parallelism threshold and returns the previous value.

```lua
lurek.compute.setParThreshold(threshold)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `threshold` | number | New threshold; values below one are clamped to one. |

**Returns**

| Type | Description |
|------|-------------|
| number | Previous parallel threshold. |

**Example**

```lua
do
    local previous = lurek.compute.getParThreshold()
    local old_value = lurek.compute.setParThreshold(1024)
    local current = lurek.compute.getParThreshold()
    lurek.compute.setParThreshold(previous)
    compute_log("threshold changed from " .. old_value .. " to " .. current .. " and restored to " .. previous)
end
```

---

### `lurek.compute.zeros`

Creates a zero-filled array with the requested shape and data type.

```lua
lurek.compute.zeros(shape, dtype)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shape` | table | Array table of positive dimension sizes. |
| `dtype?` | string | Data type name; defaults to `float32`. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New zero-filled array handle. |

**Example**

```lua
do
    local occupancy = lurek.compute.zeros({3, 3})
    occupancy:set(2, 2, 1)
    local shape = shape_text(occupancy)
    local center = occupancy:get(2, 2)
    compute_log("empty occupancy map=" .. shape .. " center=" .. center)
end
```

---

## Module Fields

*No module-level fields documented.*

## Callbacks

*No callback parameters documented in this module.*

## Enums

*No module-specific enums documented.*

## Types

- [LArray](#larray)

## LArray

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LArray:abs`

Returns element-wise absolute values.

```lua
LArray:abs()
```

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing absolute values. |

**Example**

```lua
do
    local recoil_offsets = lurek.compute.fromTable({-3, -1, 2}, {3})
    local absolute_offsets = recoil_offsets:abs()
    local first = absolute_offsets:get(1)
    local third = absolute_offsets:get(3)
    compute_log("absolute recoil first=" .. first .. " third=" .. third)
end
```

---

#### `LArray:add`

Returns element-wise addition with an array or scalar.

```lua
LArray:add(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | Array or scalar number for element-wise operation. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing the addition result. |

**Example**

```lua
do
    local threat_scores = lurek.compute.fromTable({1, 2, 3}, {3})
    local danger_bonus = threat_scores:add(10)
    local original = threat_scores:get(1)
    local boosted = danger_bonus:get(1)
    compute_log("threat scores original=" .. original .. " boosted=" .. boosted)
end
```

---

#### `LArray:addInplace`

Adds another array into this array in place.

```lua
LArray:addInplace(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LArray](#larray) | Array with a compatible shape. |

**Example**

```lua
do
    local base_cost = lurek.compute.ones({3, 3})
    local swamp_penalty = lurek.compute.ones({3, 3})
    base_cost:addInplace(swamp_penalty)
    local center = base_cost:get(2, 2)
    compute_log("path cost after swamp penalty center=" .. center .. " total=" .. base_cost:sum())
end
```

---

#### `LArray:all`

Returns whether all elements are non-zero.

```lua
LArray:all()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when every element is non-zero. |

**Example**

```lua
do
    local alive_party = lurek.compute.fromTable({1, 2, 3}, {3})
    local all_alive = alive_party:all()
    local members = alive_party:getSize()
    local total = alive_party:sum()
    compute_log("party alive=" .. tostring(all_alive) .. " members=" .. members .. " total_hp_units=" .. total)
end
```

---

#### `LArray:any`

Returns whether any element is non-zero.

```lua
LArray:any()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when at least one element is non-zero. |

**Example**

```lua
do
    local trigger_mask = lurek.compute.fromTable({0, 0, 1}, {3})
    local any_active = trigger_mask:any()
    local all_active = trigger_mask:all()
    local total = trigger_mask:sum()
    compute_log("trigger mask any=" .. tostring(any_active) .. " all=" .. tostring(all_active) .. " sum=" .. total)
end
```

---

#### `LArray:argmax`

Returns the one-based flat index of the maximum value.

```lua
LArray:argmax()
```

**Returns**

| Type | Description |
|------|-------------|
| number | One-based index of the maximum element. |

**Example**

```lua
do
    local reward_score = lurek.compute.fromTable({5, 1, 8, 3}, {4})
    local best = reward_score:argmax()
    local values = reward_score:toTable()
    local score = values[best]
    compute_log("best reward index=" .. best .. " score=" .. score)
end
```

---

#### `LArray:argmin`

Returns the one-based flat index of the minimum value.

```lua
LArray:argmin()
```

**Returns**

| Type | Description |
|------|-------------|
| number | One-based index of the minimum element. |

**Example**

```lua
do
    local travel_cost = lurek.compute.fromTable({5, 1, 8, 3}, {4})
    local best = travel_cost:argmin()
    local values = travel_cost:toTable()
    local cost = values[best]
    compute_log("cheapest route index=" .. best .. " cost=" .. cost)
end
```

---

#### `LArray:bitwiseAnd`

Returns element-wise bitwise AND with another array.

```lua
LArray:bitwiseAnd(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LArray](#larray) | Array used as the right-hand operand. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing bitwise AND results. |

**Example**

```lua
do
    local flags_a = lurek.compute.fromTable({0xFF, 0x0F, 0xAA}, {3}, "int32")
    local flags_b = lurek.compute.fromTable({0x0F, 0x0F, 0x55}, {3}, "int32")
    local overlap = flags_a:bitwiseAnd(flags_b)
    local first = overlap:get(1)
    compute_log("shared permission mask first=" .. first .. " third=" .. overlap:get(3))
end
```

---

#### `LArray:bitwiseLShift`

Returns element-wise left shift by a bit count.

```lua
LArray:bitwiseLShift(amount)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `amount` | number | Bit count to shift left. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing shifted values. |

**Example**

```lua
do
    local palette_bits = lurek.compute.fromTable({1, 2, 4}, {3}, "int32")
    local boosted = palette_bits:bitwiseLShift(2)
    local first = boosted:get(1)
    local third = boosted:get(3)
    compute_log("palette bits shifted left first=" .. first .. " third=" .. third)
end
```

---

#### `LArray:bitwiseNot`

Returns element-wise bitwise NOT.

```lua
LArray:bitwiseNot()
```

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing bitwise NOT results. |

**Example**

```lua
do
    local solid_mask = lurek.compute.fromTable({0, 255}, {2}, "int32")
    local walkable_mask = solid_mask:bitwiseNot()
    local first = walkable_mask:get(1)
    local second = walkable_mask:get(2)
    compute_log("walkable mask first=" .. first .. " second=" .. second)
end
```

---

#### `LArray:bitwiseOr`

Returns element-wise bitwise OR with another array.

```lua
LArray:bitwiseOr(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LArray](#larray) | Array used as the right-hand operand. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing bitwise OR results. |

**Example**

```lua
do
    local room_a = lurek.compute.fromTable({0xF0, 0x0F}, {2}, "int32")
    local room_b = lurek.compute.fromTable({0x0F, 0xF0}, {2}, "int32")
    local merged = room_a:bitwiseOr(room_b)
    local first = merged:get(1)
    compute_log("merged room flags first=" .. first .. " second=" .. merged:get(2))
end
```

---

#### `LArray:bitwiseRShift`

Returns element-wise right shift by a bit count.

```lua
LArray:bitwiseRShift(amount)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `amount` | number | Bit count to shift right. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing shifted values. |

**Example**

```lua
do
    local packed_color = lurek.compute.fromTable({8, 16, 32}, {3}, "int32")
    local unpacked = packed_color:bitwiseRShift(2)
    local first = unpacked:get(1)
    local third = unpacked:get(3)
    compute_log("packed color shifted right first=" .. first .. " third=" .. third)
end
```

---

#### `LArray:bitwiseXor`

Returns element-wise bitwise XOR with another array.

```lua
LArray:bitwiseXor(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LArray](#larray) | Array used as the right-hand operand. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing bitwise XOR results. |

**Example**

```lua
do
    local old_state = lurek.compute.fromTable({0xFF, 0x00}, {2}, "int32")
    local new_state = lurek.compute.fromTable({0x0F, 0x0F}, {2}, "int32")
    local changed = old_state:bitwiseXor(new_state)
    local first = changed:get(1)
    compute_log("changed state mask first=" .. first .. " second=" .. changed:get(2))
end
```

---

#### `LArray:clamp`

Returns values clamped between minimum and maximum bounds.

```lua
LArray:clamp(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min` | number | Minimum allowed value. |
| `max` | number | Maximum allowed value. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing clamped values. |

**Example**

```lua
do
    local audio_levels = lurek.compute.fromTable({-5, 0, 3, 10, 15}, {5})
    local safe_levels = audio_levels:clamp(0, 10)
    local low = safe_levels:get(1)
    local high = safe_levels:get(5)
    compute_log("clamped audio levels low=" .. low .. " high=" .. high)
end
```

---

#### `LArray:clone`

Returns an independent deep copy of this array.

```lua
LArray:clone()
```

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array with copied data and shape. |

**Example**

```lua
do
    local source_weights = lurek.compute.ones({3, 3})
    local tuned_weights = source_weights:clone()
    tuned_weights:set(1, 1, 5)
    local original = source_weights:get(1, 1)
    compute_log("clone preserved source=" .. original .. " while tuned copy=" .. tuned_weights:get(1, 1))
end
```

---

#### `LArray:convolve1d`

Returns one-dimensional convolution with a kernel array.

```lua
LArray:convolve1d(kernel)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `kernel` | [LArray](#larray) | Kernel array used for convolution. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing convolution result. |

**Example**

```lua
do
    local signal = lurek.compute.fromTable({0, 1, 2, 3, 4}, {5})
    local kernel = lurek.compute.fromTable({1, 0, -1}, {3})
    local gradient = signal:convolve1d(kernel)
    local size = gradient:getSize()
    compute_log("1d gradient size=" .. size .. " center=" .. gradient:get(3))
end
```

---

#### `LArray:convolve2D`

Returns two-dimensional convolution with a kernel array.

```lua
LArray:convolve2D(kernel)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `kernel` | [LArray](#larray) | Kernel array used for convolution. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing convolution result. |

**Example**

```lua
do
    local lightmap = lurek.compute.zeros({5, 5})
    lightmap:set(3, 3, 1)
    local blur = lurek.compute.gaussianKernel(3, 1.0)
    local softened = lightmap:convolve2D(blur)
    compute_log("softened light center=" .. softened:get(3, 3) .. " neighbor=" .. softened:get(3, 2))
end
```

---

#### `LArray:correlate1d`

Returns one-dimensional correlation with a template array.

```lua
LArray:correlate1d(template)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `template` | [LArray](#larray) | Template array used for correlation. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing correlation result. |

**Example**

```lua
do
    local signal = lurek.compute.fromTable({0, 0, 1, 0, 0}, {5})
    local template = lurek.compute.fromTable({1}, {1})
    local match = signal:correlate1d(template)
    local center = match:get(3)
    compute_log("correlation match center=" .. center .. " size=" .. match:getSize())
end
```

---

#### `LArray:countNonZero`

Counts the number of non-zero elements in this array.

```lua
LArray:countNonZero()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Number of non-zero elements. |

**Example**

```lua
do
    local occupancy = lurek.compute.fromTable({0, 1, 0, 2, 3}, {5})
    local count = occupancy:countNonZero()
    local total = occupancy:getSize()
    local empty = total - count
    compute_log("occupied cells=" .. count .. " empty cells=" .. empty)
end
```

---

#### `LArray:covariance`

Returns covariance with another array.

```lua
LArray:covariance(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LArray](#larray) | Array used as the second variable. |

**Returns**

| Type | Description |
|------|-------------|
| number | Covariance value. |

**Example**

```lua
do
    local effort = lurek.compute.fromTable({1, 2, 3, 4, 5}, {5})
    local reward = lurek.compute.fromTable({2, 4, 6, 8, 10}, {5})
    local cov = effort:covariance(reward)
    local pairs = effort:getSize()
    compute_log("effort reward covariance=" .. cov .. " pairs=" .. pairs)
end
```

---

#### `LArray:cross2d`

Returns two-dimensional cross product with another vector.

```lua
LArray:cross2d(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LArray](#larray) | Vector array used as the second operand. |

**Returns**

| Type | Description |
|------|-------------|
| number | Scalar 2D cross product result. |

**Example**

```lua
do
    local facing = lurek.compute.fromTable({1, 0}, {2})
    local target = lurek.compute.fromTable({0, 1}, {2})
    local cross = facing:cross2d(target)
    local alignment = facing:dot(target)
    compute_log("2d cross=" .. cross .. " dot=" .. alignment)
end
```

---

#### `LArray:cumsum`

Returns cumulative sum over the flattened array.

```lua
LArray:cumsum()
```

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing cumulative sums. |

**Example**

```lua
do
    local xp_gains = lurek.compute.fromTable({1, 2, 3, 4}, {4})
    local total_xp = xp_gains:cumsum()
    local fourth = total_xp:get(4)
    local second = total_xp:get(2)
    compute_log("cumulative xp second=" .. second .. " fourth=" .. fourth)
end
```

---

#### `LArray:diff`

Returns finite differences over the flattened array.

```lua
LArray:diff(order)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `order?` | number | Difference order; defaults to 1. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing differences. |

**Example**

```lua
do
    local lap_times = lurek.compute.fromTable({1, 3, 6, 10}, {4})
    local deltas = lap_times:diff()
    local first = deltas:get(1)
    local second = deltas:get(2)
    compute_log("lap deltas first=" .. first .. " second=" .. second)
end
```

---

#### `LArray:dilate`

Returns morphological dilation with a radius.

```lua
LArray:dilate(radius)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `radius` | number | Dilation radius in cells. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing dilation result. |

**Example**

```lua
do
    local obstacle = lurek.compute.zeros({5, 5})
    obstacle:set(3, 3, 1)
    local clearance = obstacle:dilate(1)
    local near = clearance:get(2, 3)
    compute_log("clearance map near obstacle=" .. near .. " center=" .. clearance:get(3, 3))
end
```

---

#### `LArray:div`

Returns element-wise division with an array or scalar.

```lua
LArray:div(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | Array or scalar number for element-wise operation. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing the division result. |

**Example**

```lua
do
    local damage_ticks = lurek.compute.fromTable({10, 20, 30}, {3})
    local normalized = damage_ticks:div(10)
    local first = normalized:get(1)
    local third = normalized:get(3)
    compute_log("normalized damage first=" .. first .. " third=" .. third)
end
```

---

#### `LArray:divInplace`

Divides this array by another array in place.

```lua
LArray:divInplace(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LArray](#larray) | Array with a compatible shape. |

**Example**

```lua
do
    local frame_times = lurek.compute.fromTable({10, 20, 30, 40}, {2, 2})
    local sample_counts = lurek.compute.fromTable({2, 4, 5, 8}, {2, 2})
    frame_times:divInplace(sample_counts)
    local average = frame_times:get(1, 1)
    compute_log("frame time average first=" .. average .. " final=" .. frame_times:get(2, 2))
end
```

---

#### `LArray:dot`

Returns dot product with another array.

```lua
LArray:dot(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LArray](#larray) | Array used as the right-hand operand. |

**Returns**

| Type | Description |
|------|-------------|
| number | Dot product result. |

**Example**

```lua
do
    local input_x = lurek.compute.fromTable({1, 2, 3}, {3})
    local input_w = lurek.compute.fromTable({4, 5, 6}, {3})
    local score = input_x:dot(input_w)
    local dims = input_x:getDimensions()
    compute_log("neuron dot score=" .. score .. " vector_dims=" .. dims)
end
```

---

#### `LArray:eigenPower`

Estimates dominant eigenvalue and eigenvector using power iteration.

```lua
LArray:eigenPower(max_iter, tol)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `max_iter?` | number | Maximum iteration count; zero uses the engine default. |
| `tol?` | number | Convergence tolerance; zero uses the engine default. |

**Returns**

| Type | Description |
|------|-------------|
| LArrayEigenPowerResult | Table containing `value` and `vector` fields. |

**Example**

```lua
do
    local covariance = lurek.compute.fromTable({2, 1, 1, 2}, {2, 2})
    local dominant = covariance:eigenPower(100, 1e-6)
    local value = dominant.value
    local first = dominant.vector[1]
    compute_log("dominant eigen value=" .. value .. " vector1=" .. tostring(first))
end
```

---

#### `LArray:eq`

Returns element-wise equality comparison with an array or scalar.

```lua
LArray:eq(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | Array or scalar number for element-wise operation. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New mask array containing comparison results. |

**Example**

```lua
do
    local tile_ids = lurek.compute.fromTable({1, 2, 3, 2, 1}, {5})
    local door_mask = tile_ids:eq(2)
    local left = door_mask:get(2)
    local right = door_mask:get(4)
    compute_log("door mask marks left=" .. left .. " right=" .. right)
end
```

---

#### `LArray:erode`

Returns morphological erosion with a radius.

```lua
LArray:erode(radius)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `radius` | number | Erosion radius in cells. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing erosion result. |

**Example**

```lua
do
    local floor = lurek.compute.ones({5, 5})
    floor:set(1, 1, 0)
    local trimmed = floor:erode(1)
    local center = trimmed:get(2, 2)
    compute_log("eroded floor center=" .. center .. " corner=" .. trimmed:get(1, 1))
end
```

---

#### `LArray:eval`

Maps each element through a Lua expression compiled as `function(x) return expression end`.

```lua
LArray:eval(expr)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `expr` | string | Lua expression that can read the current element as `x`. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing expression results. |

**Example**

```lua
do
    local base_damage = lurek.compute.fromTable({1, 2, 3}, {3})
    local scripted = base_damage:eval("x * x + 1")
    local second = scripted:get(2)
    local third = scripted:get(3)
    compute_log("evaluated damage curve second=" .. second .. " third=" .. third)
end
```

---

#### `LArray:fill`

Fills this array in place with one value.

```lua
LArray:fill(val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `val` | number | Value written to every element. |

**Example**

```lua
do
    local fog_layer = lurek.compute.newArray({3, 3})
    fog_layer:fill(7)
    local center = fog_layer:get(2, 2)
    local total = fog_layer:sum()
    compute_log("fog layer fill center=" .. center .. " total=" .. total)
end
```

---

#### `LArray:floodFill`

Returns a flood-filled copy starting at a one-based row and column.

```lua
LArray:floodFill(row, col, val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `row` | number | One-based start row. |
| `col` | number | One-based start column. |
| `val` | number | Replacement value. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing flood-fill result. |

**Example**

```lua
do
    local region = lurek.compute.zeros({5, 5})
    region:set(1, 1, 1)
    region:set(1, 2, 1)
    local filled = region:floodFill(1, 1, 9)
    compute_log("flood fill propagated to second cell=" .. filled:get(1, 2) .. " seed=" .. filled:get(1, 1))
end
```

---

#### `LArray:get`

Reads an array element using one-based indices.

```lua
LArray:get(...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| — | — | @param ... number One-based indices, one per dimension. |

**Returns**

| Type | Description |
|------|-------------|
| number | Element value at the requested index. |

**Example**

```lua
do
    local damage_table = lurek.compute.fromTable({10, 20, 30, 40}, {2, 2})
    local melee = damage_table:get(1, 2)
    local ranged = damage_table:get(2, 1)
    local shape = shape_text(damage_table)
    compute_log("damage lookup from " .. shape .. " melee=" .. melee .. " ranged=" .. ranged)
end
```

---

#### `LArray:getDataType`

Returns the element data type name as a string.

```lua
LArray:getDataType()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Data type name such as `float32`. |

**Example**

```lua
do
    local heat_values = lurek.compute.newArray({2, 2}, "float32")
    heat_values:set(1, 2, 0.5)
    local dtype = heat_values:getDataType()
    local shape = shape_text(heat_values)
    compute_log("heat grid dtype=" .. dtype .. " shape=" .. shape .. " probe=" .. heat_values:get(1, 2))
end
```

---

#### `LArray:getDimensions`

Returns the number of array dimensions.

```lua
LArray:getDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Dimension count. |

**Example**

```lua
do
    local voxel_costs = lurek.compute.newArray({2, 3, 4})
    voxel_costs:set(2, 3, 4, 9)
    local dims = voxel_costs:getDimensions()
    local size = voxel_costs:getSize()
    compute_log("voxel cost tensor dims=" .. dims .. " size=" .. size .. " last=" .. voxel_costs:get(2, 3, 4))
end
```

---

#### `LArray:getRegion`

Returns a rectangular region from this array.

```lua
LArray:getRegion(row, col, rows, cols)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `row` | number | One-based start row. |
| `col` | number | One-based start column. |
| `rows` | number | Region row count. |
| `cols` | number | Region column count. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing the requested region. |

**Example**

```lua
do
    local dungeon = lurek.compute.range(1, 17, 1):reshape({4, 4})
    local room = dungeon:getRegion(2, 2, 2, 2)
    local shape = shape_text(room)
    local top_left = room:get(1, 1)
    compute_log("cropped room region=" .. shape .. " top_left=" .. top_left)
end
```

---

#### `LArray:getShape`

Returns the array shape as one-based dimension table.

```lua
LArray:getShape()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of dimension sizes. |

**Example**

```lua
do
    local visibility = lurek.compute.newArray({3, 4})
    visibility:set(1, 1, 1)
    local shape = visibility:getShape()
    local shape_name = tostring(shape[1]) .. "x" .. tostring(shape[2])
    compute_log("visibility grid shape=" .. shape_name .. " first=" .. visibility:get(1, 1))
end
```

---

#### `LArray:getSize`

Returns the total number of array elements.

```lua
LArray:getSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Element count. |

**Example**

```lua
do
    local chunk_cells = lurek.compute.newArray({5, 5})
    chunk_cells:set(3, 3, 7)
    local size = chunk_cells:getSize()
    local dims = chunk_cells:getDimensions()
    compute_log("chunk cell buffer size=" .. size .. " dims=" .. dims .. " center=" .. chunk_cells:get(3, 3))
end
```

---

#### `LArray:gt`

Returns element-wise greater-than comparison with an array or scalar.

```lua
LArray:gt(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | Array or scalar number for element-wise operation. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New mask array containing comparison results. |

**Example**

```lua
do
    local aggro = lurek.compute.fromTable({1, 5, 10}, {3})
    local alerted = aggro:gt(4)
    local second = alerted:get(2)
    local third = alerted:get(3)
    compute_log("alert mask medium=" .. second .. " high=" .. third)
end
```

---

#### `LArray:gte`

Returns element-wise greater-or-equal comparison with an array or scalar.

```lua
LArray:gte(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | Array or scalar number for element-wise operation. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New mask array containing comparison results. |

**Example**

```lua
do
    local loot_rarity = lurek.compute.fromTable({1, 5, 10}, {3})
    local rare_mask = loot_rarity:gte(5)
    local second = rare_mask:get(2)
    local third = rare_mask:get(3)
    compute_log("rare loot mask second=" .. second .. " third=" .. third)
end
```

---

#### `LArray:histogram`

Returns histogram bins for the array values.

```lua
LArray:histogram(bins, lo, hi)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bins` | number | Number of histogram bins. |
| `lo?` | number | Optional lower bound. |
| `hi?` | number | Optional upper bound. |

**Returns**

| Type | Description |
|------|-------------|
| LArrayHistogramResult | Array of bin tables with `lo`, `hi`, and `count` fields. |

**Example**

```lua
do
    local loot_rolls = lurek.compute.fromTable({1, 2, 3, 4, 5, 6, 7, 8}, {8})
    local bins = loot_rolls:histogram(4)
    local first = bins[1].count
    local last = bins[#bins].count
    compute_log("loot histogram bins=" .. #bins .. " first=" .. tostring(first) .. " last=" .. tostring(last))
end
```

---

#### `LArray:isOnGPU`

Returns whether this array is currently stored on the GPU.

```lua
LArray:isOnGPU()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | Always false for the current CPU-backed implementation. |

**Example**

```lua
do
    local nav_buffer = lurek.compute.ones({4, 4})
    nav_buffer:set(2, 3, 4)
    local on_gpu = nav_buffer:isOnGPU()
    local shape = shape_text(nav_buffer)
    compute_log("nav buffer shape=" .. shape .. " gpu_resident=" .. tostring(on_gpu))
end
```

---

#### `LArray:linsolve`

Solves a linear system using this matrix and a right-hand side array.

```lua
LArray:linsolve(b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `b` | [LArray](#larray) | Right-hand side array. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | Solution array. |

**Example**

```lua
do
    local matrix = lurek.compute.fromTable({2, 1, 5, 7}, {2, 2})
    local rhs = lurek.compute.fromTable({11, 13}, {2})
    local solution = matrix:linsolve(rhs)
    local x = solution:get(1)
    compute_log("linear solve x=" .. x .. " y=" .. solution:get(2))
end
```

---

#### `LArray:lt`

Returns element-wise less-than comparison with an array or scalar.

```lua
LArray:lt(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | Array or scalar number for element-wise operation. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New mask array containing comparison results. |

**Example**

```lua
do
    local stamina = lurek.compute.fromTable({1, 5, 10}, {3})
    local low_mask = stamina:lt(6)
    local first = low_mask:get(1)
    local third = low_mask:get(3)
    compute_log("low stamina mask first=" .. first .. " third=" .. third)
end
```

---

#### `LArray:lte`

Returns element-wise less-or-equal comparison with an array or scalar.

```lua
LArray:lte(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | Array or scalar number for element-wise operation. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New mask array containing comparison results. |

**Example**

```lua
do
    local cooldowns = lurek.compute.fromTable({1, 5, 10}, {3})
    local ready_mask = cooldowns:lte(5)
    local first = ready_mask:get(1)
    local third = ready_mask:get(3)
    compute_log("ready cooldown mask first=" .. first .. " third=" .. third)
end
```

---

#### `LArray:luDecompose`

Decomposes this matrix into LU data and permutation metadata.

```lua
LArray:luDecompose()
```

**Returns**

| Type | Description |
|------|-------------|
| LArrayLuDecomposeResult | Table containing `n`, `det_sign`, `perm`, and `lu_data` fields. |

**Example**

```lua
do
    local matrix = lurek.compute.fromTable({4, 3, 6, 3}, {2, 2})
    local lu = matrix:luDecompose()
    local perm0 = lu.perm[1]
    local sign = lu.det_sign
    compute_log("lu decomposition n=" .. lu.n .. " sign=" .. sign .. " perm1=" .. tostring(perm0))
end
```

---

#### `LArray:map`

Maps each element through a Lua function and returns a new array.

```lua
LArray:map(func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `func` | function | Function called with each element value and returning a number. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing mapped values. |

**Example**

```lua
do
    local base_damage = lurek.compute.fromTable({1, 4, 9}, {3})
    local doubled = base_damage:map(function(x) return x * 2 end)
    local second = doubled:get(2)
    local third = doubled:get(3)
    compute_log("mapped damage second=" .. second .. " third=" .. third)
end
```

---

#### `LArray:matmul`

Returns matrix multiplication of this array and another array.

```lua
LArray:matmul(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LArray](#larray) | Right-hand matrix array. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing matrix multiplication result. |

**Example**

```lua
do
    local basis = lurek.compute.fromTable({1, 2, 3, 4}, {2, 2})
    local transform = lurek.compute.fromTable({5, 6, 7, 8}, {2, 2})
    local combined = basis:matmul(transform)
    local top_left = combined:get(1, 1)
    compute_log("combined transform shape=" .. shape_text(combined) .. " top_left=" .. top_left)
end
```

---

#### `LArray:max`

Returns total maximum or a maximum array along a one-based axis.

```lua
LArray:max()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Scalar maximum when no axis is given. |

**Example**

```lua
do
    local threat_spikes = lurek.compute.fromTable({7, 2, 9, 1}, {4})
    local peak = threat_spikes:max()
    local index = threat_spikes:argmax()
    local total = threat_spikes:sum()
    compute_log("peak threat=" .. peak .. " index=" .. index .. " total=" .. total)
end
```

---

#### `LArray:mean`

Returns total mean or a mean array along a one-based axis.

```lua
LArray:mean()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Scalar mean when no axis is given. |

**Example**

```lua
do
    local frame_times = lurek.compute.fromTable({2, 4, 6, 8}, {4})
    local average = frame_times:mean()
    local low = frame_times:min()
    local high = frame_times:max()
    compute_log("frame time mean=" .. average .. " range=" .. low .. "-" .. high)
end
```

---

#### `LArray:min`

Returns total minimum or a minimum array along a one-based axis.

```lua
LArray:min()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Scalar minimum when no axis is given. |

**Example**

```lua
do
    local route_costs = lurek.compute.fromTable({7, 2, 9, 1}, {4})
    local best = route_costs:min()
    local index = route_costs:argmin()
    local total = route_costs:sum()
    compute_log("best route cost=" .. best .. " index=" .. index .. " total=" .. total)
end
```

---

#### `LArray:mul`

Returns element-wise multiplication with an array or scalar.

```lua
LArray:mul(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | Array or scalar number for element-wise operation. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing the multiplication result. |

**Example**

```lua
do
    local combo_hits = lurek.compute.fromTable({2, 3, 4}, {3})
    local scaled_hits = combo_hits:mul(3)
    local second = scaled_hits:get(2)
    local third = scaled_hits:get(3)
    compute_log("scaled combo hits second=" .. second .. " third=" .. third)
end
```

---

#### `LArray:mulInplace`

Multiplies this array by another array in place.

```lua
LArray:mulInplace(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LArray](#larray) | Array with a compatible shape. |

**Example**

```lua
do
    local reward_grid = lurek.compute.fromTable({2, 3, 4, 5}, {2, 2})
    local combo_boost = lurek.compute.fromTable({10, 10, 10, 10}, {2, 2})
    reward_grid:mulInplace(combo_boost)
    local boosted = reward_grid:get(1, 1)
    compute_log("reward grid after combo boost first=" .. boosted .. " total=" .. reward_grid:sum())
end
```

---

#### `LArray:neg`

Returns element-wise negated values.

```lua
LArray:neg()
```

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing negated values. |

**Example**

```lua
do
    local knockback = lurek.compute.fromTable({5, -3, 0}, {3})
    local reversed = knockback:neg()
    local first = reversed:get(1)
    local second = reversed:get(2)
    compute_log("reversed knockback first=" .. first .. " second=" .. second)
end
```

---

#### `LArray:neq`

Returns element-wise inequality comparison with an array or scalar.

```lua
LArray:neq(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | Array or scalar number for element-wise operation. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New mask array containing comparison results. |

**Example**

```lua
do
    local terrain_ids = lurek.compute.fromTable({1, 2, 3}, {3})
    local moving_mask = terrain_ids:neq(2)
    local first = moving_mask:get(1)
    local second = moving_mask:get(2)
    compute_log("moving mask first=" .. first .. " blocked_center=" .. second)
end
```

---

#### `LArray:normalizeRange`

Returns array values normalized into a target range.

```lua
LArray:normalizeRange(lo, hi)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `lo` | number | Target lower bound. |
| `hi` | number | Target upper bound. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New normalized array. |

**Example**

```lua
do
    local light_levels = lurek.compute.fromTable({0, 50, 100}, {3})
    local normalized = light_levels:normalizeRange(0, 1)
    local middle = normalized:get(2)
    local high = normalized:get(3)
    compute_log("normalized light middle=" .. middle .. " high=" .. high)
end
```

---

#### `LArray:normalizeVec`

Returns this vector normalized to unit length.

```lua
LArray:normalizeVec()
```

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New normalized vector array. |

**Example**

```lua
do
    local move_input = lurek.compute.fromTable({3, 4}, {2})
    local unit = move_input:normalizeVec()
    local x = unit:get(1)
    local y = unit:get(2)
    compute_log("unit move vector=(" .. x .. "," .. y .. ")")
end
```

---

#### `LArray:outer`

Returns outer product with another vector array.

```lua
LArray:outer(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LArray](#larray) | Vector array used as the second operand. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing outer product result. |

**Example**

```lua
do
    local row = lurek.compute.fromTable({1, 2, 3}, {3})
    local col = lurek.compute.fromTable({4, 5}, {2})
    local score_grid = row:outer(col)
    local shape = shape_text(score_grid)
    compute_log("outer score grid=" .. shape .. " top_right=" .. score_grid:get(1, 2))
end
```

---

#### `LArray:pearsonCorr`

Returns Pearson correlation with another array.

```lua
LArray:pearsonCorr(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LArray](#larray) | Array used as the second variable. |

**Returns**

| Type | Description |
|------|-------------|
| number | Pearson correlation coefficient. |

**Example**

```lua
do
    local effort = lurek.compute.fromTable({1, 2, 3, 4, 5}, {5})
    local reward = lurek.compute.fromTable({2, 4, 6, 8, 10}, {5})
    local corr = effort:pearsonCorr(reward)
    local pairs = reward:getSize()
    compute_log("effort reward correlation=" .. corr .. " pairs=" .. pairs)
end
```

---

#### `LArray:percentile`

Returns a percentile value from the array.

```lua
LArray:percentile(p)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `p` | number | Percentile between 0 and 100. |

**Returns**

| Type | Description |
|------|-------------|
| number | Percentile result. |

**Example**

```lua
do
    local damage_log = lurek.compute.range(1, 100, 1)
    local median = damage_log:percentile(50)
    local upper = damage_log:percentile(90)
    local count = damage_log:getSize()
    compute_log("damage percentile median=" .. median .. " p90=" .. upper .. " count=" .. count)
end
```

---

#### `LArray:pow`

Returns this array raised element-wise to a scalar exponent.

```lua
LArray:pow(exp)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `exp` | number | Exponent applied to every element. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing powered values. |

**Example**

```lua
do
    local distance_ring = lurek.compute.fromTable({2, 3, 4}, {3})
    local falloff = distance_ring:pow(2)
    local second = falloff:get(2)
    local third = falloff:get(3)
    compute_log("quadratic falloff second=" .. second .. " third=" .. third)
end
```

---

#### `LArray:reduce`

Reduces array values with a Lua accumulator function.

```lua
LArray:reduce(func, init)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `func` | function | Function called as `(accumulator, value)` and returning the next accumulator. |
| `init` | number | Initial accumulator value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Final accumulator value. |

**Example**

```lua
do
    local rewards = lurek.compute.fromTable({1, 2, 3, 4}, {4})
    local total = rewards:reduce(function(acc, v) return acc + v end, 0)
    local mean = rewards:mean()
    local count = rewards:getSize()
    compute_log("reduced rewards total=" .. total .. " mean=" .. mean .. " count=" .. count)
end
```

---

#### `LArray:reshape`

Returns a reshaped copy of this array.

```lua
LArray:reshape(shape)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shape` | table | Array table of positive dimension sizes. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array with the requested shape. |

**Example**

```lua
do
    local encounter_stream = lurek.compute.fromTable({1, 2, 3, 4, 5, 6}, {6})
    local encounter_grid = encounter_stream:reshape({2, 3})
    local shape = shape_text(encounter_grid)
    local last = encounter_grid:get(2, 3)
    compute_log("reshaped encounter grid=" .. shape .. " last=" .. last)
end
```

---

#### `LArray:scan`

Produces prefix accumulator values with a Lua function.

```lua
LArray:scan(func, init)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `func` | function | Function called as `(accumulator, value)` and returning the next accumulator. |
| `init` | number | Initial accumulator value. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing accumulator values. |

**Example**

```lua
do
    local combo_hits = lurek.compute.fromTable({1, 2, 3, 4}, {4})
    local running = combo_hits:scan(function(acc, v) return acc + v end, 0)
    local second = running:get(2)
    local fourth = running:get(4)
    compute_log("running combo score second=" .. second .. " fourth=" .. fourth)
end
```

---

#### `LArray:set`

Writes an array element using one-based indices followed by the value.

```lua
LArray:set(...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| — | — | @param ... number One-based indices followed by the numeric value to store. |

**Example**

```lua
do
    local threat_map = lurek.compute.zeros({3, 3})
    threat_map:set(2, 2, 99)
    threat_map:set(2, 3, 42)
    local center = threat_map:get(2, 2)
    compute_log("threat hotspot center=" .. center .. " east=" .. threat_map:get(2, 3))
end
```

---

#### `LArray:setRegion`

Writes a source array into this array at a one-based row and column.

```lua
LArray:setRegion(row, col, source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `row` | number | One-based destination row. |
| `col` | number | One-based destination column. |
| `source` | [LArray](#larray) | Source array copied into this array. |

**Example**

```lua
do
    local minimap = lurek.compute.zeros({4, 4})
    local room_patch = lurek.compute.ones({2, 2})
    minimap:setRegion(2, 2, room_patch)
    local center = minimap:get(2, 2)
    compute_log("inserted room patch center=" .. center .. " far_corner=" .. minimap:get(4, 4))
end
```

---

#### `LArray:sobel`

Computes Sobel gradients for this array.

```lua
LArray:sobel()
```

**Returns**

| Type | Description |
|------|-------------|
| LArraySobelResult | Table with `gx` and `gy` gradient arrays. |

**Example**

```lua
do
    local heightfield = lurek.compute.zeros({5, 5})
    heightfield:set(3, 3, 1)
    local gradient = heightfield:sobel()
    local gx_shape = shape_text(gradient.gx)
    compute_log("sobel gx=" .. gx_shape .. " gy=" .. shape_text(gradient.gy))
end
```

---

#### `LArray:sqrt`

Returns element-wise square roots.

```lua
LArray:sqrt()
```

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing square root values. |

**Example**

```lua
do
    local area_values = lurek.compute.fromTable({4, 9, 16}, {3})
    local side_lengths = area_values:sqrt()
    local first = side_lengths:get(1)
    local third = side_lengths:get(3)
    compute_log("square root lengths first=" .. first .. " third=" .. third)
end
```

---

#### `LArray:sub`

Returns element-wise subtraction with an array or scalar.

```lua
LArray:sub(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | Array or scalar number for element-wise operation. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing the subtraction result. |

**Example**

```lua
do
    local health_bar = lurek.compute.fromTable({10, 20, 30}, {3})
    local after_hit = health_bar:sub(5)
    local middle = after_hit:get(2)
    local last = after_hit:get(3)
    compute_log("health after hit middle=" .. middle .. " last=" .. last)
end
```

---

#### `LArray:subInplace`

Subtracts another array from this array in place.

```lua
LArray:subInplace(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LArray](#larray) | Array with a compatible shape. |

**Example**

```lua
do
    local stamina_pool = lurek.compute.fromTable({5, 5, 5, 5}, {2, 2})
    local drain = lurek.compute.ones({2, 2})
    stamina_pool:subInplace(drain)
    local remaining = stamina_pool:get(1, 1)
    compute_log("stamina pool after drain first=" .. remaining .. " total=" .. stamina_pool:sum())
end
```

---

#### `LArray:sum`

Returns total sum or a summed array along a one-based axis.

```lua
LArray:sum()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Scalar sum when no axis is given. |

**Example**

```lua
do
    local wave_counts = lurek.compute.fromTable({1, 2, 3, 4}, {4})
    local total = wave_counts:sum()
    local average = wave_counts:mean()
    local last = wave_counts:get(4)
    compute_log("wave count total=" .. total .. " mean=" .. average .. " last=" .. last)
end
```

---

#### `LArray:threshold`

Returns a mask array where values above a threshold are selected.

```lua
LArray:threshold(val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `val` | number | Threshold value. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New mask array containing threshold results. |

**Example**

```lua
do
    local light_probe = lurek.compute.fromTable({0.1, 0.5, 0.9}, {3})
    local lit_mask = light_probe:threshold(0.4)
    local first = lit_mask:get(1)
    local third = lit_mask:get(3)
    compute_log("light threshold mask first=" .. first .. " third=" .. third)
end
```

---

#### `LArray:toTable`

Returns array values flattened into a Lua table.

```lua
LArray:toTable()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Numeric values in storage order. |

**Example**

```lua
do
    local patrol_route = lurek.compute.fromTable({1, 2, 3}, {3})
    local steps = patrol_route:toTable()
    local first = steps[1]
    local last = steps[#steps]
    compute_log("patrol route table length=" .. #steps .. " first=" .. first .. " last=" .. last)
end
```

---

#### `LArray:transformPoints`

Transforms a point array by this transform matrix.

```lua
LArray:transformPoints(pts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pts` | [LArray](#larray) | Point array to transform. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing transformed points. |

**Example**

```lua
do
    local world_from_local = lurek.compute.affine2d(10, 20, 0, 1, 1)
    local corners = lurek.compute.fromTable({0, 0, 5, 5}, {2, 2})
    local world_points = world_from_local:transformPoints(corners)
    local first_x = world_points:get(1, 1)
    compute_log("transformed points first_x=" .. first_x .. " last_y=" .. world_points:get(2, 2))
end
```

---

#### `LArray:transpose`

Returns a transposed copy of a two-dimensional array.

```lua
LArray:transpose()
```

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New transposed array. |

**Example**

```lua
do
    local room_links = lurek.compute.fromTable({1, 2, 3, 4, 5, 6}, {2, 3})
    local reversed_links = room_links:transpose()
    local shape = shape_text(reversed_links)
    local mirrored = reversed_links:get(3, 2)
    compute_log("transposed room links shape=" .. shape .. " mirrored_cell=" .. mirrored)
end
```

---

#### `LArray:type`

Returns the Lua-visible type name for this array handle.

```lua
LArray:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LArray](#larray)`. |

**Example**

```lua
do
    local scratch = lurek.compute.ones({2, 2})
    scratch:set(1, 2, 3)
    local type_name = scratch:type()
    local shape = shape_text(scratch)
    compute_log("array userdata type=" .. type_name .. " shape=" .. shape)
end
```

---

#### `LArray:typeOf`

Returns whether this array handle matches a supported type name.

```lua
LArray:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LArray](#larray)`, `Array`, and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local scratch = lurek.compute.ones({2, 2})
    scratch:set(2, 1, 4)
    local is_array = scratch:typeOf("LArray")
    local is_object = scratch:typeOf("LObject")
    compute_log("typeOf array=" .. tostring(is_array) .. " object=" .. tostring(is_object))
end
```

---

#### `LArray:where`

Selects values from this array or another array using a mask array.

```lua
LArray:where(mask, other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mask` | [LArray](#larray) | Mask array used to choose between arrays. |
| `other` | [LArray](#larray) | Array used where the mask is false. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing selected values. |

**Example**

```lua
do
    local daytime = lurek.compute.fromTable({10, 20, 30}, {3})
    local nighttime = lurek.compute.fromTable({-1, -2, -3}, {3})
    local visible = daytime:gt(15)
    local blend = daytime:where(visible, nighttime)
    compute_log("where blend values=" .. blend:get(1) .. "," .. blend:get(2) .. "," .. blend:get(3))
end
```

---

#### `LArray:zscore`

Returns z-score normalized array values.

```lua
LArray:zscore()
```

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New z-score normalized array. |

**Example**

```lua
do
    local enemy_speeds = lurek.compute.fromTable({2, 4, 4, 4, 5, 5, 7, 9}, {8})
    local zscores = enemy_speeds:zscore()
    local first = zscores:get(1)
    local last = zscores:get(8)
    compute_log("enemy speed zscores first=" .. first .. " last=" .. last)
end
```

---
