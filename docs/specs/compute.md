# compute

## General Info

- Module group: `Foundations`
- Source path: `src/compute/`
- Lua API path(s): `src/lua_api/compute_api.rs`
- Primary Lua namespace: `lurek.compute`
- Rust test path(s): tests/rust/unit/compute_tests.rs; tests/rust/stress/compute_stress_tests.rs; inline tests in src/compute/array.rs, src/compute/spatial.rs
- Lua test path(s): tests/lua/unit/test_compute.lua; tests/lua/stress/test_compute_stress.lua; tests/lua/integration/test_data_compute.lua; tests/lua/integration/test_compute_dataframe.lua; tests/lua/golden/test_compute_golden.lua

## Summary

The `compute` module owns dense numeric array processing for Lurek2D. It provides a CPU-side `NdArray` container plus array math, reductions, comparisons, and 2D spatial operations that are expensive or awkward to express efficiently in plain Lua.

This module exists so game scripts can work with structured numeric grids, vectors, and matrices without depending on renderer resources or external scientific-computing crates. Its design is intentionally simple: contiguous row-major storage, a small fixed dtype set, and operations that return new arrays unless an explicitly mutating method is being used.

`compute` intentionally does not own GPU dispatch, general tensor features, broadcasting semantics, or named-column analytics. It is a raw numeric array module; for heterogeneous tabular records use `src/dataframe/`, and for binary serialization or byte transport use `src/data/`.

**Scope boundary**: This module currently depends on `runtime`. It stays within the Foundations responsibility boundary defined in the architecture docs.

## Files

- `array.rs`: Defines `NdArray`, `DataType`, shape validation, contiguous storage rules, typed element access, and array construction helpers.
- `mod.rs`: Declares the compute submodules and re-exports the core ndarray surface.
- `ops.rs`: Implements the bulk of ndarray behavior, including arithmetic, scalar ops, comparisons, masks, reductions, reshaping, transposition, and Int32-only bitwise operations.
- `spatial.rs`: Adds higher-level 2D spatial and linear algebra helpers such as convolution, morphology, flood fill, region copy, matrix multiply, and vector dot product.

## Types

- `DataType` (`enum`, `array.rs`): Declares the supported element representations: `Float32`, `Float64`, and `Int32`. The restricted dtype set keeps the implementation small and predictable for Lua callers.
- `NdArray` (`struct`, `array.rs`): Core dense numeric array type. It owns the contiguous row-major buffer and is the foundation every compute operation works against.

## Functions

- `DataType::parse` (`array.rs`): Parse a dtype from a string name (`"float32"`, `"float64"`, `"int32"`).
- `DataType::byte_size` (`array.rs`): Number of bytes per element for this dtype.
- `DataType::name` (`array.rs`): Human-readable name for this dtype.
- `NdArray::new` (`array.rs`): Create a new zero-initialized NdArray with the given shape and dtype.
- `NdArray::zeros` (`array.rs`): Create a zero-initialized NdArray.
- `NdArray::ones` (`array.rs`): Create an NdArray filled with ones (1.0 for floats, 1 for int32).
- `NdArray::range` (`array.rs`): Create a 1D NdArray with values from `start` to `stop` (exclusive) with given step.
- `NdArray::from_slice` (`array.rs`): Create an NdArray from a slice of f64 values, converting to the target dtype.
- `NdArray::get_f64` (`array.rs`): Read element at flat index as f64 (works for any dtype).
- `NdArray::set_f64` (`array.rs`): Write a value (as f64) to the flat index, converting to the array's dtype.
- `NdArray::get_i32` (`array.rs`): Read element at flat index as i32.
- `NdArray::set_i32` (`array.rs`): Write an i32 value at the flat index.
- `NdArray::flat_index` (`array.rs`): Convert a multi-dimensional index to a flat element offset.
- `NdArray::shape` (`array.rs`): Returns the shape of this array as a slice.
- `NdArray::dtype` (`array.rs`): Returns the element data type of this array.
- `NdArray::size` (`array.rs`): Returns the total number of elements in this array.
- `NdArray::ndim` (`array.rs`): Returns the number of dimensions (1, 2, or 3).
- `NdArray::strides` (`array.rs`): Returns the row-major strides for this array.
- `NdArray::data` (`array.rs`): Returns a reference to the underlying byte data.
- `NdArray::data_mut` (`array.rs`): Returns a mutable reference to the underlying byte data.
- `NdArray::set_shape` (`array.rs`): Sets the shape and strides directly.
- `NdArray::compute_strides` (`array.rs`): Compute row-major strides for a given shape.
- `NdArray::get_by_indices` (`array.rs`): Read element by multi-dimensional indices (0-based), combining flat_index + get_f64.
- `NdArray::set_by_indices` (`array.rs`): Write a value by multi-dimensional indices (0-based), combining flat_index + set_f64.
- `NdArray::to_f64_vec` (`array.rs`): Return all elements as a `Vec<f64>`.
- `NdArray::display_string` (`array.rs`): Return a human-readable summary string for debugging.
- `add` (`ops.rs`): Element-wise addition of two arrays (same shape and dtype).
- `add_scalar` (`ops.rs`): Add a scalar to every element.
- `sub` (`ops.rs`): Element-wise subtraction of two arrays (same shape and dtype).
- `sub_scalar` (`ops.rs`): Subtract a scalar from every element.
- `mul` (`ops.rs`): Element-wise multiplication of two arrays (same shape and dtype).
- `mul_scalar` (`ops.rs`): Multiply every element by a scalar.
- `div` (`ops.rs`): Element-wise division of two arrays (same shape and dtype).
- `div_scalar` (`ops.rs`): Divide every element by a scalar.
- `pow_scalar` (`ops.rs`): Raise every element to a scalar exponent.
- `sqrt` (`ops.rs`): Element-wise square root.
- `abs` (`ops.rs`): Element-wise absolute value.
- `neg` (`ops.rs`): Element-wise negation.
- `clamp` (`ops.rs`): Clamp every element to `[min_val, max_val]`.
- `eq` (`ops.rs`): Element-wise equality comparison of two arrays.
- `eq_scalar` (`ops.rs`): Element-wise equality comparison against a scalar.
- `neq` (`ops.rs`): Element-wise not-equal comparison of two arrays.
- `neq_scalar` (`ops.rs`): Element-wise not-equal comparison against a scalar.
- `gt` (`ops.rs`): Element-wise greater-than comparison of two arrays.
- `gt_scalar` (`ops.rs`): Element-wise greater-than comparison against a scalar.
- `lt` (`ops.rs`): Element-wise less-than comparison of two arrays.
- `lt_scalar` (`ops.rs`): Element-wise less-than comparison against a scalar.
- `gte` (`ops.rs`): Element-wise greater-than-or-equal comparison of two arrays.
- `gte_scalar` (`ops.rs`): Element-wise greater-than-or-equal comparison against a scalar.
- `lte` (`ops.rs`): Element-wise less-than-or-equal comparison of two arrays.
- `lte_scalar` (`ops.rs`): Element-wise less-than-or-equal comparison against a scalar.
- `threshold` (`ops.rs`): Threshold mask: returns Float32 array with 1.0 where `a >= val`, 0.0 otherwise.
- `where_mask` (`ops.rs`): Conditional selection: where `cond != 0`, choose from `a`; otherwise from `b`.
- `count_nonzero` (`ops.rs`): Count the number of non-zero elements.
- `argmin` (`ops.rs`): Return the flat index of the minimum element (0-based).
- `argmax` (`ops.rs`): Return the flat index of the maximum element (0-based).
- `any` (`ops.rs`): Returns `true` if any element is non-zero.
- `all` (`ops.rs`): Returns `true` if all elements are non-zero.
- `sum` (`ops.rs`): Sum of all elements.
- `mean` (`ops.rs`): Mean of all elements.
- `min_val` (`ops.rs`): Minimum value across all elements.
- `max_val` (`ops.rs`): Maximum value across all elements.
- `sum_axis` (`ops.rs`): Sum along a given axis, producing an array with that axis removed.
- `mean_axis` (`ops.rs`): Mean along a given axis.
- `min_axis` (`ops.rs`): Minimum along a given axis.
- `max_axis` (`ops.rs`): Maximum along a given axis.
- `reshape` (`ops.rs`): Reshape an array to a new shape with the same total element count.
- `transpose_2d` (`ops.rs`): Transpose a 2D array (swap rows and columns).
- `fill` (`ops.rs`): Fill all elements of an array with a value (in-place).
- `clone_array` (`ops.rs`): Clone an array (convenience wrapper).
- `bitwise_and` (`ops.rs`): Bitwise AND of two Int32 arrays.
- `bitwise_or` (`ops.rs`): Bitwise OR of two Int32 arrays.
- `bitwise_xor` (`ops.rs`): Bitwise XOR of two Int32 arrays.
- `bitwise_not` (`ops.rs`): Bitwise NOT of an Int32 array.
- `bitwise_lshift` (`ops.rs`): Bitwise left shift of an Int32 array by `amount` bits.
- `bitwise_rshift` (`ops.rs`): Bitwise right shift (arithmetic) of an Int32 array by `amount` bits.
- `convolve2d` (`spatial.rs`): 2D convolution with zero-padding (same-size output).
- `dilate` (`spatial.rs`): Morphological dilation with a Manhattan-diamond structuring element.
- `erode` (`spatial.rs`): Morphological erosion with a Manhattan-diamond structuring element.
- `flood_fill` (`spatial.rs`): Flood fill using BFS with 4-connectivity.
- `get_region` (`spatial.rs`): Extract a rectangular sub-region from a 2D array.
- `set_region` (`spatial.rs`): Copy a source 2D array into a target 2D array at position `(row, col)`.
- `matmul` (`spatial.rs`): Matrix multiplication of two 2D arrays: (m,k) × (k,n) → (m,n).
- `dot` (`spatial.rs`): Dot product of two 1D arrays (same length).

## Lua API Reference

- Binding path(s): `src/lua_api/compute_api.rs`
- Namespace: `lurek.compute`

### Module Functions
- `lurek.compute.newArray`: Creates a zero-initialized array with the given shape and optional dtype.
- `lurek.compute.zeros`: Creates a zero-filled array with the given shape and optional dtype.
- `lurek.compute.ones`: Creates a one-filled array with the given shape and optional dtype.
- `lurek.compute.range`: Creates a 1D array from start to stop with optional step and dtype.
- `lurek.compute.fromTable`: Creates an array from a Lua table of numbers with optional shape and dtype.

### `Array` Methods
- `Array:getShape`: Returns the shape as a table of dimension sizes.
- `Array:getDimensions`: Returns the number of dimensions.
- `Array:getSize`: Returns the total number of elements.
- `Array:getDataType`: Returns the element data type name.
- `Array:isOnGPU`: Returns false (CPU arrays only).
- `Array:get`: Returns the element at the given 1-based indices.
- `Array:set`: Sets the element at the given 1-based indices to a value.
- `Array:toTable`: Returns all elements as a flat table of numbers.
- `Array:reshape`: Returns a new array with the given shape and the same data.
- `Array:clone`: Returns a deep copy of this array.
- `Array:transpose`: Returns the transposed 2D array.
- `Array:fill`: Fills all elements with the given value in-place.
- `Array:pow`: Raises each element to a scalar exponent.
- `Array:sqrt`: Element-wise square root.
- `Array:abs`: Element-wise absolute value.
- `Array:neg`: Element-wise negation.
- `Array:clamp`: Clamps each element to the given range.
- `Array:threshold`: Returns a mask array with 1.0 where elements >= val, else 0.0.
- `Array:countNonZero`: Returns the count of nonzero elements.
- `Array:argmin`: Returns the 1-based flat index of the minimum element.
- `Array:argmax`: Returns the 1-based flat index of the maximum element.
- `Array:any`: Returns true if any element is nonzero.
- `Array:all`: Returns true if all elements are nonzero.
- `Array:sum`: Sum of all elements, or along an axis (1-based).
- `Array:mean`: Mean of all elements, or along an axis (1-based).
- `Array:min`: Minimum of all elements, or along an axis (1-based).
- `Array:max`: Maximum of all elements, or along an axis (1-based).
- `Array:matmul`: Matrix multiplication of two 2D arrays.
- `Array:dot`: Dot product of two 1D arrays.
- `Array:bitwiseAnd`: Bitwise AND of two Int32 arrays.
- `Array:bitwiseOr`: Bitwise OR of two Int32 arrays.
- `Array:bitwiseXor`: Bitwise XOR of two Int32 arrays.
- `Array:bitwiseNot`: Bitwise NOT of an Int32 array.
- `Array:bitwiseLShift`: Bitwise left shift of an Int32 array.
- `Array:bitwiseRShift`: Bitwise right shift of an Int32 array.
- `Array:convolve2D`: 2D convolution with zero-padding.
- `Array:dilate`: Morphological dilation with a diamond structuring element.
- `Array:erode`: Morphological erosion with a diamond structuring element.
- `Array:type`: Returns the type name "Array".
- `Array:typeOf`: Returns true when the given name matches "Array" or a parent type.

## References

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/compute/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
