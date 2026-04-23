# compute

## General Info

- Module group: `Foundations`
- Source path: `src/compute/`
- Lua API path(s): `src/lua_api/compute_api.rs`
- Primary Lua namespace: `lurek.compute`
- Rust test path(s): tests/rust/unit/compute_tests.rs; tests/rust/stress/compute_stress_tests.rs; inline tests in src/compute/array.rs, src/compute/spatial.rs
- Lua test path(s): tests/lua/unit/test_compute.lua; tests/lua/stress/test_compute_stress.lua; tests/lua/integration/test_data_compute.lua; tests/lua/integration/test_compute_dataframe.lua; tests/lua/golden/test_compute_golden.lua

## Summary

The `compute` module is Lurek2D's dense N-dimensional numerical array library for the Foundations tier. It provides CPU-side matrix operations, signal processing, spatial transforms, and linear algebra that would otherwise require GPU compute shaders. All arithmetic executes synchronously on the calling thread — no background workers, no GPU memory — making it safe to call from Lua game scripts and easy to unit-test headlessly.

**Core type: `NdArray`.** `NdArray` is a row-major contiguous buffer supporting 1D, 2D, and 3D shapes. Three element types are supported via the `DataType` enum: `Float32`, `Float64`, and `Int32`. The restricted type set keeps the API predictable for Lua callers who do not control Rust type inference. Construction helpers: `new(shape, dtype)`, `zeros`, `ones`, `range(start, stop, step)`, `from_slice`. The Lua API additionally exposes `fromTable` to create an array from a plain Lua table. Shape inspection: `shape()`, `ndim()`, `numel()`. Mutation: `get_by_indices`/`set_by_indices` (multi-dim), `get_f64`/`set_f64` (flat index). Structural transforms: `reshape`, `transpose_2d`, `clone_array`, `fill`.

**`ops` submodule.** Element-wise binary operations (add, sub, mul, div, mod, pow) and their scalar variants. Unary transforms: `sqrt`, `abs`, `neg`, `clamp`, `threshold`. Comparison predicates (eq, neq, gt, lt, gte, lte) with scalar forms. Logical aggregates: `any`, `all`, `count_nonzero`. Global reductions: `sum`, `mean`, `min_val`, `max_val`, `argmin`, `argmax`. Axis reductions with the same set of operations. Conditional selection: `where_mask`. Bitwise operations for `Int32` arrays: AND, OR, XOR, NOT, left shift, right shift.

**`spatial` submodule.** 2D convolution (`convolve2d`) with zero-padding for same-size output. Morphological dilation and erosion with a Manhattan-diamond structuring element. Flood fill using BFS with 4-connectivity. Sub-array extraction/insertion (`get_region`/`set_region`). 2D matrix multiplication (`matmul`). 1D dot product.

**`linalg` submodule.** Vector utilities: L2 normalise, 2D cross product (signed scalar), outer product. Matrix construction: 2×2 rotation matrix, 3×3 homogeneous affine matrix. Point transformation by 2×2 or 3×3 matrix. `linsolve` via Gaussian elimination with partial pivoting. `lu_decompose` (P·A = L·U). `eigenvalue_power` (dominant eigenvalue by power iteration). `gaussian_kernel` generator. `sobel` edge detection.

**`analytics` submodule.** Signal processing: `convolve1d`, `correlate1d`, autocorrelation, moving average. Statistics: `variance`, `std_dev`, `histogram`, `percentile`, `covariance`, `pearson_corr`. Transforms: `cumsum`, `diff`, normalise to range (`normalize_range`), z-score standardisation (`zscore`). Normalisation norms: L1, L2, min-max.

**`fft` submodule.** Dedicated Fast Fourier Transform (power-of-two optimized). `fft(data)` returns the complex DFT spectrum. `ifft(data)` reconstructs the time-domain signal. `fft_magnitude(data)` returns the magnitude spectrum `|X[k]|`. Lua scripts access all three via `lurek.compute.fft`, `lurek.compute.ifft`, `lurek.compute.fftMagnitude`.

**Lua surface.** 11 module-level constructor/utility functions and a full `Array` userdata type with ~40 methods covering shape inspection, element access, arithmetic, reductions, transforms, and serialisation. Matrix helpers `gaussianKernel`, `rotate2dMatrix`, `affine2d` are exposed as free functions.

**Scope boundary.** Foundations tier. No Lurek2D module dependencies. Lua bridge in `src/lua_api/compute_api.rs`. Plugin candidacy under proposed constraint A-05 — see [docs/architecture/plugins.md](../architecture/plugins.md).

## Files

- `analytics.rs`: Statistical analytics, signal processing, and normalisation for NdArray.
- `array.rs`: Defines `NdArray`, `DataType`, shape validation, contiguous storage rules, typed element access, and array construction helpers.
- `fft.rs`: Fast Fourier Transform (FFT) and Inverse FFT for the compute subsystem.
- `linalg.rs`: Linear algebra extensions for NdArray.
- `mod.rs`: Declares the compute submodules and re-exports the core ndarray surface.
- `ops.rs`: Implements the bulk of ndarray behavior, including arithmetic, scalar ops, comparisons, masks, reductions, reshaping, transposition, and Int32-only bitwise operations.
- `spatial.rs`: Adds higher-level 2D spatial and linear algebra helpers such as convolution, morphology, flood fill, region copy, matrix multiply, and vector dot product.

## Types

- `DataType` (`enum`, `array.rs`): Declares the supported element representations: `Float32`, `Float64`, and `Int32`. The restricted dtype set keeps the implementation small and predictable for Lua callers.
- `NdArray` (`struct`, `array.rs`): Core dense numeric array type. It owns the contiguous row-major buffer and is the foundation every compute operation works against.
- `LuDecomp` (`struct`, `linalg.rs`): Result of an LU decomposition with partial pivoting.

## Functions

- `cumsum` (`analytics.rs`): Cumulative sum along a 1D array (or flattened elements if axis is None).
- `diff` (`analytics.rs`): Discrete difference: `out[i] = a[i+1] - a[i]` (order `n = 1`, 1D or flat).
- `histogram` (`analytics.rs`): Compute a histogram with `bins` equal-width bins.
- `percentile` (`analytics.rs`): Compute the `p`-th percentile (0–100) of all elements.
- `covariance` (`analytics.rs`): Population covariance of two 1D (or flat) arrays of equal size.
- `pearson_corr` (`analytics.rs`): Pearson correlation coefficient of two 1D (or flat) arrays.
- `normalize_range` (`analytics.rs`): Linearly rescale all elements to [out_min, out_max].
- `zscore` (`analytics.rs`): Standardise all elements to zero mean and unit variance (z-score).
- `convolve1d` (`analytics.rs`): 1D convolution of `signal` with `kernel` (full output length).
- `correlate1d` (`analytics.rs`): 1D cross-correlation: slide `template` over `signal` (valid output).
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
- `next_power_of_two` (`fft.rs`): Returns the smallest power of two ≥ `n`.
- `fft` (`fft.rs`): Computes the discrete Fourier transform (DFT) of `data`.
- `ifft` (`fft.rs`): Computes the inverse discrete Fourier transform.
- `fft_magnitude` (`fft.rs`): Returns the magnitude spectrum of `data` as `|X[k]|` values.
- `normalize_vec` (`linalg.rs`): L2-normalise a 1D vector.
- `cross2d` (`linalg.rs`): 2D cross product (returns signed scalar area of the parallelogram).
- `outer` (`linalg.rs`): Outer product of two 1D vectors: result shape is [m, n].
- `rotate2d_matrix` (`linalg.rs`): Build a 2×2 rotation matrix for `angle_rad` radians.
- `affine2d` (`linalg.rs`): Build a 3×3 homogeneous affine matrix combining translation, rotation, and scale.
- `transform_points` (`linalg.rs`): Apply a 2×2 or 3×3 (homogeneous) matrix to a list of 2D points.
- `gaussian_kernel` (`linalg.rs`): Generate a `size × size` Gaussian kernel with the given `sigma`.
- `sobel` (`linalg.rs`): Apply Sobel edge detection to a 2D Float32/Float64 array.
- `linsolve` (`linalg.rs`): Solve the linear system A·x = b using Gaussian elimination with partial pivoting.
- `lu_decompose` (`linalg.rs`): Decomposes a square matrix `a` into P·A = L·U using partial pivoting.
- `eigenvalue_power` (`linalg.rs`): Computes the dominant eigenvalue and its eigenvector of a square matrix using the power-iteration method.
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
- `lurek.compute.gaussianKernel`: Creates a sizeĂ—size Gaussian kernel array.
- `lurek.compute.rotate2dMatrix`: Creates a 2Ă—2 rotation matrix for the given angle in radians.
- `lurek.compute.affine2d`: Creates a 3Ă—3 homogeneous affine matrix.
- `lurek.compute.fft`: Computes the discrete Fourier transform of a 1D real-valued sample array.
- `lurek.compute.ifft`: Computes the inverse discrete Fourier transform.
- `lurek.compute.fftMagnitude`: Returns the magnitude spectrum `|X[k]|` of a real-valued sample array.

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
- `Array:neg`: Returns a new Array with every element negated (multiplied by â’1).
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
- `Array:cumsum`: Cumulative sum of all elements (flattened).
- `Array:diff`: Discrete difference applied `order` times.
- `Array:percentile`: Compute the p-th percentile (0â€“100).
- `Array:covariance`: Population covariance with another 1D array.
- `Array:pearsonCorr`: Pearson correlation coefficient with another 1D array.
- `Array:normalizeRange`: Linearly rescale values to [out_min, out_max].
- `Array:zscore`: Standardise values to zero mean and unit variance.
- `Array:convolve1d`: 1D convolution with a kernel array (full output).
- `Array:correlate1d`: 1D cross-correlation with a template array (valid output).
- `Array:normalizeVec`: L2-normalise a 1D vector.
- `Array:outer`: Outer product of two 1D vectors â†’ 2D array [m, n].
- `Array:cross2d`: Signed 2D cross product with another length-2 array.
- `Array:transformPoints`: Apply this 2Ă—2 or 3Ă—3 matrix to an [N,2] points array.
- `Array:sobel`: Apply Sobel edge detection to a 2D array. Returns {gx=Array, gy=Array}.
- `Array:linsolve`: Solve AÂ·x = b where this array is A (square [n,n]) and b is a 1D vector.
- `Array:luDecompose`: Decomposes this square matrix into L and U factors with partial pivoting.
- `Array:map`: Apply a Lua callback element-wise, returning a new Array of the same shape.
- `Array:eval`: Evaluate a Lua expression string element-wise, returning a new Array.
- `Array:reduce`: Fold the array left-to-right with an accumulator.
- `Array:scan`: Running accumulation — like reduce but returns every intermediate result.
- `Array:type`: Returns the type name "Array".
- `Array:typeOf`: Returns true when the given name matches "Array" or a parent type.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- Keep this module reference synchronized with `src/compute/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
