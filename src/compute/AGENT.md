# `compute` — Agent Reference

| Property | Value |
|----------|-------|
| **Tier** | Tier 1 — Basic Core |
| **Status**     | Implemented — Full                                   |
| **Lua API** | `luna.compute` |
| **Source** | `src/compute/` |
| **Rust Tests** | `tests/unit/compute_tests.rs`                    |
| **Tests** | `tests/compute_tests.rs` |
| **Lua Tests** | `tests/lua/unit/test_compute.lua` |

## Summary

The compute module exposes data-parallel computation to Lua scripts for work
that would block the game loop if run naively on the main thread in a single
frame.  It provides an `NdArray` N-dimensional numeric array that supports
vectorised arithmetic, matrix operations, and statistical aggregations over
large datasets without marshalling data through Lua value iteration.  For
massively parallel numeric work a GPU compute path via wgpu compute shaders
runs the full pipeline entirely on the GPU.

Typical use cases include procedural terrain height-map generation (applying
noise functions to grids of thousands of cells in parallel), batch distance
field computation for large-scale AI pathfinding preprocessing, real-time
simulation of physical systems (spring networks, heat diffusion) at scales
that would drop below target frame rate if processed sequentially in Lua, and
offline data preprocessing steps embedded in the game's level-loading stage.

The CPU path operates on contiguous `Vec<f64>` storage so that Rust-level
loops benefit from SIMD auto-vectorisation without requiring any unsafe code or
explicit intrinsic calls.  The GPU path offloads arbitrarily large datasets to
a wgpu compute pipeline, uploads the input buffer, dispatches with the
appropriate workgroup count, and reads results back synchronously via
`pollster::block_on` — appropriate for one-off heavy computations, not
per-frame streaming.

## Architecture

```
NdArray (core container)
  │
  ├── DataType ── Float32 | Float64 | Int32
  │     └── Raw storage: Vec<u8> with type-aware access
  │
  ├── ops.rs ── 50+ pure functions
  │     ├── Arithmetic ── add, sub, mul, div, pow, negate, abs, sqrt
  │     ├── Comparison ── eq, ne, lt, gt, le, ge (return Float32 0|1)
  │     ├── Reductions ── sum, mean, min, max, argmin, argmax
  │     │     └── Global or per-axis variants
  │     ├── Shape ── reshape, transpose, flatten, squeeze, expand_dims
  │     └── Bitwise ── and, or, xor, not (Int32 only)
  │
  └── spatial.rs ── spatial/matrix operations
        ├── convolve2d ── 2D convolution with kernel
        ├── dilate / erode ── morphological operations
        ├── flood_fill ── region filling
        ├── get_region / set_region ── sub-array access
        ├── matmul ── matrix multiplication
        └── dot ── dot product
```

## Source Files

| File | Purpose |
|------|---------|
| `mod.rs` | Module root; re-exports NdArray, DataType, and all operation modules |
| `array.rs` | Core NdArray type and DataType enum |
| `ops.rs` | Element-wise, reduction, comparison, masking, shape, and bitwise operations on... |
| `spatial.rs` | 2D spatial operations and linear algebra for NdArray |

## Submodules

### `compute::array`

Core NdArray type and DataType enum.

- **`DataType`** (enum): Element data type for an NdArray. Consult the module-level documentation for the broader usage context and...
- **`NdArray`** (struct): Dense N-dimensional numerical array with row-major strides.  Data is stored as a contiguous `Vec<u8>` byte buffer....

### `compute::ops`

Element-wise, reduction, comparison, masking, shape, and bitwise operations on NdArray.

- **`add`** (fn): Element-wise addition of two arrays (same shape and dtype).
- **`add_scalar`** (fn): Add a scalar to every element. The insertion is O(1) amortised unless a resize is triggered.
- **`sub`** (fn): Element-wise subtraction of two arrays (same shape and dtype).
- **`sub_scalar`** (fn): Subtract a scalar from every element. Consult the module-level documentation for the broader usage context and...
- **`mul`** (fn): Element-wise multiplication of two arrays (same shape and dtype).
- **`mul_scalar`** (fn): Multiply every element by a scalar. Consult the module-level documentation for the broader usage context and...
- **`div`** (fn): Element-wise division of two arrays (same shape and dtype).
- **`div_scalar`** (fn): Divide every element by a scalar. Consult the module-level documentation for the broader usage context and...
- **`pow_scalar`** (fn): Raise every element to a scalar exponent.
- **`sqrt`** (fn): Element-wise square root. Consult the module-level documentation for the broader usage context and preconditions.
- **`abs`** (fn): Element-wise absolute value. Consult the module-level documentation for the broader usage context and preconditions.
- **`neg`** (fn): Element-wise negation. Consult the module-level documentation for the broader usage context and preconditions.
- **`clamp`** (fn): Clamp every element to `[min_val, max_val]`.
- **`eq`** (fn): Element-wise equality comparison of two arrays. Returns Float32 with 0/1.
- **`eq_scalar`** (fn): Element-wise equality comparison against a scalar. Returns Float32.
- **`neq`** (fn): Element-wise not-equal comparison of two arrays. Returns Float32.
- **`neq_scalar`** (fn): Element-wise not-equal comparison against a scalar. Returns Float32.
- **`gt`** (fn): Element-wise greater-than comparison of two arrays. Returns Float32.
- **`gt_scalar`** (fn): Element-wise greater-than comparison against a scalar. Returns Float32.
- **`lt`** (fn): Element-wise less-than comparison of two arrays. Returns Float32.
- **`lt_scalar`** (fn): Element-wise less-than comparison against a scalar. Returns Float32.
- **`gte`** (fn): Element-wise greater-than-or-equal comparison of two arrays. Returns Float32.
- **`gte_scalar`** (fn): Element-wise greater-than-or-equal comparison against a scalar. Returns Float32.
- **`lte`** (fn): Element-wise less-than-or-equal comparison of two arrays. Returns Float32.
- **`lte_scalar`** (fn): Element-wise less-than-or-equal comparison against a scalar. Returns Float32.
- **`threshold`** (fn): Threshold mask: returns Float32 array with 1.0 where `a >= val`, 0.0 otherwise.
- **`where_mask`** (fn): Conditional selection: where `cond != 0`, choose from `a`; otherwise from `b`.
- **`count_nonzero`** (fn): Count the number of non-zero elements. Runs in O(1) time.
- **`argmin`** (fn): Return the flat index of the minimum element (0-based).
- **`argmax`** (fn): Return the flat index of the maximum element (0-based).
- **`any`** (fn): Returns `true` if any element is non-zero.
- **`all`** (fn): Returns `true` if all elements are non-zero.
- **`sum`** (fn): Sum of all elements. Consult the module-level documentation for the broader usage context and preconditions.
- **`mean`** (fn): Mean of all elements. Consult the module-level documentation for the broader usage context and preconditions.
- **`min_val`** (fn): Minimum value across all elements. Consult the module-level documentation for the broader usage context and...
- **`max_val`** (fn): Maximum value across all elements. Consult the module-level documentation for the broader usage context and...
- **`sum_axis`** (fn): Sum along a given axis, producing an array with that axis removed.
- **`mean_axis`** (fn): Mean along a given axis. Consult the module-level documentation for the broader usage context and preconditions.
- **`min_axis`** (fn): Minimum along a given axis. Consult the module-level documentation for the broader usage context and preconditions.
- **`max_axis`** (fn): Maximum along a given axis. Consult the module-level documentation for the broader usage context and preconditions.
- **`reshape`** (fn): Reshape an array to a new shape with the same total element count.
- **`transpose_2d`** (fn): Transpose a 2D array (swap rows and columns).
- **`fill`** (fn): Fill all elements of an array with a value (in-place).
- **`clone_array`** (fn): Clone an array (convenience wrapper). Consult the module-level documentation for the broader usage context and...
- **`bitwise_and`** (fn): Bitwise AND of two Int32 arrays. Consult the module-level documentation for the broader usage context and preconditions.
- **`bitwise_or`** (fn): Bitwise OR of two Int32 arrays. Consult the module-level documentation for the broader usage context and preconditions.
- **`bitwise_xor`** (fn): Bitwise XOR of two Int32 arrays. Consult the module-level documentation for the broader usage context and preconditions.
- **`bitwise_not`** (fn): Bitwise NOT of an Int32 array. Consult the module-level documentation for the broader usage context and preconditions.
- **`bitwise_lshift`** (fn): Bitwise left shift of an Int32 array by `amount` bits.
- **`bitwise_rshift`** (fn): Bitwise right shift (arithmetic) of an Int32 array by `amount` bits.

### `compute::spatial`

2D spatial operations and linear algebra for NdArray.

- **`convolve2d`** (fn): 2D convolution with zero-padding (same-size output).
- **`dilate`** (fn): Morphological dilation with a Manhattan-diamond structuring element.
- **`erode`** (fn): Morphological erosion with a Manhattan-diamond structuring element.
- **`flood_fill`** (fn): Flood fill using BFS with 4-connectivity.
- **`get_region`** (fn): Extract a rectangular sub-region from a 2D array.
- **`set_region`** (fn): Copy a source 2D array into a target 2D array at position `(row, col)`.
- **`matmul`** (fn): Matrix multiplication of two 2D arrays: (m,k) × (k,n) → (m,n).
- **`dot`** (fn): Dot product of two 1D arrays (same length). Returns a scalar.

## Key Types

### Structs

#### `compute::array::NdArray`

Dense N-dimensional numerical array with row-major strides.  Data is stored as a contiguous `Vec<u8>` byte buffer....

### Enums

#### `compute::array::DataType`

Element data type for an NdArray. Consult the module-level documentation for the broader usage context and...

## Public Functions

- **`abs()`** `ops::` — Element-wise absolute value. Consult the module-level documentation for the broader usage context and preconditions.
- **`add()`** `ops::` — Element-wise addition of two arrays (same shape and dtype).
- **`add_scalar()`** `ops::` — Add a scalar to every element. The insertion is O(1) amortised unless a resize is triggered.
- **`all()`** `ops::` — Returns `true` if all elements are non-zero.
- **`any()`** `ops::` — Returns `true` if any element is non-zero.
- **`argmax()`** `ops::` — Return the flat index of the maximum element (0-based).
- **`argmin()`** `ops::` — Return the flat index of the minimum element (0-based).
- **`bitwise_and()`** `ops::` — Bitwise AND of two Int32 arrays. Consult the module-level documentation for the broader usage context and preconditions.
- **`bitwise_lshift()`** `ops::` — Bitwise left shift of an Int32 array by `amount` bits.
- **`bitwise_not()`** `ops::` — Bitwise NOT of an Int32 array. Consult the module-level documentation for the broader usage context and preconditions.
- **`bitwise_or()`** `ops::` — Bitwise OR of two Int32 arrays. Consult the module-level documentation for the broader usage context and preconditions.
- **`bitwise_rshift()`** `ops::` — Bitwise right shift (arithmetic) of an Int32 array by `amount` bits.
- **`bitwise_xor()`** `ops::` — Bitwise XOR of two Int32 arrays. Consult the module-level documentation for the broader usage context and preconditions.
- **`clamp()`** `ops::` — Clamp every element to `[min_val, max_val]`.
- **`clone_array()`** `ops::` — Clone an array (convenience wrapper). Consult the module-level documentation for the broader usage context and...
- **`convolve2d()`** `spatial::` — 2D convolution with zero-padding (same-size output).
- **`count_nonzero()`** `ops::` — Count the number of non-zero elements. Runs in O(1) time.
- **`dilate()`** `spatial::` — Morphological dilation with a Manhattan-diamond structuring element.
- **`div()`** `ops::` — Element-wise division of two arrays (same shape and dtype).
- **`div_scalar()`** `ops::` — Divide every element by a scalar. Consult the module-level documentation for the broader usage context and...
- **`dot()`** `spatial::` — Dot product of two 1D arrays (same length). Returns a scalar.
- **`eq()`** `ops::` — Element-wise equality comparison of two arrays. Returns Float32 with 0/1.
- **`eq_scalar()`** `ops::` — Element-wise equality comparison against a scalar. Returns Float32.
- **`erode()`** `spatial::` — Morphological erosion with a Manhattan-diamond structuring element.
- **`fill()`** `ops::` — Fill all elements of an array with a value (in-place).
- **`flood_fill()`** `spatial::` — Flood fill using BFS with 4-connectivity.
- **`get_region()`** `spatial::` — Extract a rectangular sub-region from a 2D array.
- **`gt()`** `ops::` — Element-wise greater-than comparison of two arrays. Returns Float32.
- **`gt_scalar()`** `ops::` — Element-wise greater-than comparison against a scalar. Returns Float32.
- **`gte()`** `ops::` — Element-wise greater-than-or-equal comparison of two arrays. Returns Float32.
- **`gte_scalar()`** `ops::` — Element-wise greater-than-or-equal comparison against a scalar. Returns Float32.
- **`lt()`** `ops::` — Element-wise less-than comparison of two arrays. Returns Float32.
- **`lt_scalar()`** `ops::` — Element-wise less-than comparison against a scalar. Returns Float32.
- **`lte()`** `ops::` — Element-wise less-than-or-equal comparison of two arrays. Returns Float32.
- **`lte_scalar()`** `ops::` — Element-wise less-than-or-equal comparison against a scalar. Returns Float32.
- **`matmul()`** `spatial::` — Matrix multiplication of two 2D arrays: (m,k) × (k,n) → (m,n).
- **`max_axis()`** `ops::` — Maximum along a given axis. Consult the module-level documentation for the broader usage context and preconditions.
- **`max_val()`** `ops::` — Maximum value across all elements. Consult the module-level documentation for the broader usage context and...
- **`mean()`** `ops::` — Mean of all elements. Consult the module-level documentation for the broader usage context and preconditions.
- **`mean_axis()`** `ops::` — Mean along a given axis. Consult the module-level documentation for the broader usage context and preconditions.
- **`min_axis()`** `ops::` — Minimum along a given axis. Consult the module-level documentation for the broader usage context and preconditions.
- **`min_val()`** `ops::` — Minimum value across all elements. Consult the module-level documentation for the broader usage context and...
- **`mul()`** `ops::` — Element-wise multiplication of two arrays (same shape and dtype).
- **`mul_scalar()`** `ops::` — Multiply every element by a scalar. Consult the module-level documentation for the broader usage context and...
- **`neg()`** `ops::` — Element-wise negation. Consult the module-level documentation for the broader usage context and preconditions.
- **`neq()`** `ops::` — Element-wise not-equal comparison of two arrays. Returns Float32.
- **`neq_scalar()`** `ops::` — Element-wise not-equal comparison against a scalar. Returns Float32.
- **`pow_scalar()`** `ops::` — Raise every element to a scalar exponent.
- **`reshape()`** `ops::` — Reshape an array to a new shape with the same total element count.
- **`set_region()`** `spatial::` — Copy a source 2D array into a target 2D array at position `(row, col)`.
- **`sqrt()`** `ops::` — Element-wise square root. Consult the module-level documentation for the broader usage context and preconditions.
- **`sub()`** `ops::` — Element-wise subtraction of two arrays (same shape and dtype).
- **`sub_scalar()`** `ops::` — Subtract a scalar from every element. Consult the module-level documentation for the broader usage context and...
- **`sum()`** `ops::` — Sum of all elements. Consult the module-level documentation for the broader usage context and preconditions.
- **`sum_axis()`** `ops::` — Sum along a given axis, producing an array with that axis removed.
- **`threshold()`** `ops::` — Threshold mask: returns Float32 array with 1.0 where `a >= val`, 0.0 otherwise.
- **`transpose_2d()`** `ops::` — Transpose a 2D array (swap rows and columns).
- **`where_mask()`** `ops::` — Conditional selection: where `cond != 0`, choose from `a`; otherwise from `b`.

## Lua API

Exposed under `luna.compute.*` by `src/lua_api/compute_api/`.

## Item Summary

| Kind | Count |
|------|-------|
| `enum` | 1 |
| `fn` | 58 |
| `mod` | 3 |
| `struct` | 1 |
| **Total** | **63** |

## Lua Examples

```lua
function luna.load()
    arr = luna.compute.newArray(1000, "f32")
    for i = 1, 1000 do
        arr:set(i, i * 0.1)
    end
end

function luna.update(dt)
    local sum = arr:reduce("sum")
    local mean = arr:mean()
end
```

## References

| Module      | Relationship  | Notes                                              |
|-------------|---------------|----------------------------------------------------|
| `engine`    | Imports from  | Uses `SharedState`                                 |
| `math`      | Imports from  | Numeric types, `Vec2`                              |
| `dataframe` | Related       | `dataframe` stores named column tables; `compute` stores raw numeric arrays |
| `lua_api`   | Imported by   | `src/lua_api/compute_api.rs` registers `luna.compute.*` |

## Notes

- `NdArray` stores data in row-major column-major layout; be consistent when iterating in Lua vs Rust.
- All arithmetic operations are CPU-side; there is no GPU compute shader path.
- Large arrays (>10M elements) may cause GC pressure in Lua due to boxing; use Rust-side batch operations where possible.
- Intended for numerical simulations, signal processing, and data analysis — not real-time per-frame game logic.
