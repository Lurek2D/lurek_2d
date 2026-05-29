# compute

## TL;DR

- The `compute` module is a dense N-dimensional numerical array library forming a core component of the Foundations tier.

## General Info

- Module group: `Foundations`
- Source path: `src/compute/`
- Lua API path(s): `src/lua_api/compute_api.rs`
- Primary Lua namespace: `lurek.compute`
- Rust test path(s): tests/rust/unit/compute_tests.rs; tests/rust/stress/compute_stress_tests.rs; inline tests in src/compute/array.rs, src/compute/spatial.rs
- Lua test path(s): tests/lua/unit/test_compute.lua; tests/lua/stress/test_compute_stress.lua; tests/lua/integration/test_data_compute.lua; tests/lua/integration/test_compute_dataframe.lua; tests/lua/golden/test_compute_golden.lua

## Summary

The `compute` module is the CPU numerical workspace for typed n-dimensional array operations and analytics-style transforms. `NdArray` plus `DataType` form the primary data container, while specialized submodules provide FFT, linear algebra, element-wise ops, spatial processing, and aggregate analytics.

Its architecture is capability-based: `array` handles shape and storage, `ops` handles vectorized/reduction primitives and parallel thresholds, `linalg` handles matrix/transform operations, `fft` handles frequency transforms, and `spatial` handles neighborhood-based processing. `analytics` adds higher-level statistics over these same typed buffers.

This module is intentionally GPU-agnostic and gameplay-agnostic. It exists to provide deterministic numerical kernels that other systems can call, from simulation features to offline tooling.

Quality for this module means strong shape/type guarantees, predictable numeric behavior, and transparent performance controls (such as configurable parallel dispatch thresholds) so callers can balance determinism and throughput.

Implementation detail and boundary guarantees for compute: this module keeps responsibilities explicit across source files so behavior remains inspectable during refactors. The current source map is: analytics.rs: Cumulative and differential operations (cumsum, diff, convolve1d, correlate1d) - Histogram binning with configurable range and bin count - Percentile extraction with linear interpolation - Pairwise statistical measures (covariance, Pearson correlation) - Value normalization helpe; array.rs: Dense n-dimensional array container with typed storage (float32, float64, int32) - Shape validation, stride computation, and flat-index addressing - Constructors for zeros, ones, range, and from-slice initialization - Element access by flat index or multidimensional coordinates -; fft.rs: Radix-2 in-place FFT and inverse FFT for power-of-two length buffers - Real-to-complex forward transform with automatic zero-padding - Complex-to-real inverse transform for spectrum reconstruction - Magnitude spectrum extraction from complex bin pairs; linalg.rs: Vector operations (normalize, cross2d, outer product, dot via spatial) - 2D transformation matrices (rotation, affine, point transform) - Convolution kernels (Gaussian) and edge detection (Sobel) - Linear system solving via Gaussian elimination with partial pivoting - LU decompos; mod.rs: N-dimensional array container, element-wise and reduction operations - FFT, linear algebra, spatial filtering, and statistical analytics - Configurable parallel dispatch threshold for large arrays; ops.rs: Element-wise arithmetic, comparison, and bitwise operations on NdArray - Scalar and array binary operations with row-broadcast support - Reduction operations (sum, mean, min, max) globally and along axes - In-place mutation variants for add, sub, mul, div - Reshape, transpose, cl; spatial.rs: 2D convolution with zero-padded boundary handling - Binary morphology operators (dilate, erode) using Manhattan radius - Flood fill with 4-connected BFS propagation - Sub-region extraction and insertion for 2D arrays - Matrix multiplication and 1D dot product. This split is part of the contract: orchestration stays in composition points, data models stay in type-centric files, and adapters stay in bridge files. That separation reduces hidden coupling, improves testability, and keeps Lua API surfaces aligned with Rust runtime semantics. For maintainers, the key guarantee is that high-level APIs should keep delegating into scoped internals instead of collapsing into a single large entry point. Future extensions should preserve explicit dependency direction and documented invariants near owning types and functions.

## Files

### analytics.rs

- Cumulative and differential operations (cumsum, diff, convolve1d, correlate1d)
- Histogram binning with configurable range and bin count
- Percentile extraction with linear interpolation
- Pairwise statistical measures (covariance, Pearson correlation)
- Value normalization helpers (range scaling, z-score standardization)

### array.rs

- Dense n-dimensional array container with typed storage (float32, float64, int32)
- Shape validation, stride computation, and flat-index addressing
- Constructors for zeros, ones, range, and from-slice initialization
- Element access by flat index or multidimensional coordinates
- Utility iterators, fill, map, and display formatting

### fft.rs

- Radix-2 in-place FFT and inverse FFT for power-of-two length buffers
- Real-to-complex forward transform with automatic zero-padding
- Complex-to-real inverse transform for spectrum reconstruction
- Magnitude spectrum extraction from complex bin pairs

### linalg.rs

- Vector operations (normalize, cross2d, outer product, dot via spatial)
- 2D transformation matrices (rotation, affine, point transform)
- Convolution kernels (Gaussian) and edge detection (Sobel)
- Linear system solving via Gaussian elimination with partial pivoting
- LU decomposition with row permutation and determinant sign tracking
- Dominant eigenpair estimation via power iteration

### mod.rs

- N-dimensional array container, element-wise and reduction operations
- FFT, linear algebra, spatial filtering, and statistical analytics
- Configurable parallel dispatch threshold for large arrays

### ops.rs

- Element-wise arithmetic, comparison, and bitwise operations on NdArray
- Scalar and array binary operations with row-broadcast support
- Reduction operations (sum, mean, min, max) globally and along axes
- In-place mutation variants for add, sub, mul, div
- Reshape, transpose, clone, fill, threshold, and conditional select
- Configurable parallel dispatch via rayon above a tunable threshold
- Argmin, argmax, count_nonzero, any, all logical queries

### spatial.rs

- 2D convolution with zero-padded boundary handling
- Binary morphology operators (dilate, erode) using Manhattan radius
- Flood fill with 4-connected BFS propagation
- Sub-region extraction and insertion for 2D arrays
- Matrix multiplication and 1D dot product

## Lua API Ref

- Binding: `src/lua_api/compute_api.rs`
- Namespace: `lurek.compute`

### Functions

- `lurek.compute.affine2d`: Creates a 2D affine transform matrix.
- `lurek.compute.fft`: Computes the FFT of real-valued samples.
- `lurek.compute.fftMagnitude`: Computes FFT magnitudes for real-valued samples.
- `lurek.compute.fromTable`: Creates an array from a flat Lua table and optional shape.
- `lurek.compute.gaussianKernel`: Creates a square Gaussian kernel array.
- `lurek.compute.getParThreshold`: Returns the global compute parallelism threshold.
- `lurek.compute.ifft`: Computes the inverse FFT of complex frequency pairs.
- `lurek.compute.newArray`: Creates a zero-filled array with the requested shape and data type.
- `lurek.compute.ones`: Creates a one-filled array with the requested shape and data type.
- `lurek.compute.range`: Creates a one-dimensional range array.
- `lurek.compute.rotate2dMatrix`: Creates a 2D rotation matrix from an angle in radians.
- `lurek.compute.setParThreshold`: Sets the global compute parallelism threshold and returns the previous value.
- `lurek.compute.zeros`: Creates a zero-filled array with the requested shape and data type.

### Enums

- No documented module-level enums/constants.

### Types


#### LArray Type


##### Fields

- No documented fields.

##### Methods

- `LArray:abs`: Returns element-wise absolute values.
- `LArray:add`: Returns element-wise addition with an array or scalar.
- `LArray:addInplace`: Adds another array into this array in place.
- `LArray:all`: Returns whether all elements are non-zero.
- `LArray:any`: Returns whether any element is non-zero.
- `LArray:argmax`: Returns the one-based flat index of the maximum value.
- `LArray:argmin`: Returns the one-based flat index of the minimum value.
- `LArray:bitwiseAnd`: Returns element-wise bitwise AND with another array.
- `LArray:bitwiseLShift`: Returns element-wise left shift by a bit count.
- `LArray:bitwiseNot`: Returns element-wise bitwise NOT.
- `LArray:bitwiseOr`: Returns element-wise bitwise OR with another array.
- `LArray:bitwiseRShift`: Returns element-wise right shift by a bit count.
- `LArray:bitwiseXor`: Returns element-wise bitwise XOR with another array.
- `LArray:clamp`: Returns values clamped between minimum and maximum bounds.
- `LArray:clone`: Returns an independent deep copy of this array.
- `LArray:convolve1d`: Returns one-dimensional convolution with a kernel array.
- `LArray:convolve2D`: Returns two-dimensional convolution with a kernel array.
- `LArray:correlate1d`: Returns one-dimensional correlation with a template array.
- `LArray:countNonZero`: Counts the number of non-zero elements in this array.
- `LArray:covariance`: Returns covariance with another array.
- `LArray:cross2d`: Returns two-dimensional cross product with another vector.
- `LArray:cumsum`: Returns cumulative sum over the flattened array.
- `LArray:diff`: Returns finite differences over the flattened array.
- `LArray:dilate`: Returns morphological dilation with a radius.
- `LArray:div`: Returns element-wise division with an array or scalar.
- `LArray:divInplace`: Divides this array by another array in place.
- `LArray:dot`: Returns dot product with another array.
- `LArray:eigenPower`: Estimates dominant eigenvalue and eigenvector using power iteration.
- `LArray:eq`: Returns element-wise equality comparison with an array or scalar.
- `LArray:erode`: Returns morphological erosion with a radius.
- `LArray:eval`: Maps each element through a Lua expression compiled as `function(x) return expression end`.
- `LArray:fill`: Fills this array in place with one value.
- `LArray:floodFill`: Returns a flood-filled copy starting at a one-based row and column.
- `LArray:get`: Reads an array element using one-based indices.
- `LArray:getDataType`: Returns the element data type name as a string.
- `LArray:getDimensions`: Returns the number of array dimensions.
- `LArray:getRegion`: Returns a rectangular region from this array.
- `LArray:getShape`: Returns the array shape as one-based dimension table.
- `LArray:getSize`: Returns the total number of array elements.
- `LArray:gt`: Returns element-wise greater-than comparison with an array or scalar.
- `LArray:gte`: Returns element-wise greater-or-equal comparison with an array or scalar.
- `LArray:histogram`: Returns histogram bins for the array values.
- `LArray:isOnGPU`: Returns whether this array is currently stored on the GPU.
- `LArray:linsolve`: Solves a linear system using this matrix and a right-hand side array.
- `LArray:lt`: Returns element-wise less-than comparison with an array or scalar.
- `LArray:lte`: Returns element-wise less-or-equal comparison with an array or scalar.
- `LArray:luDecompose`: Decomposes this matrix into LU data and permutation metadata.
- `LArray:map`: Maps each element through a Lua function and returns a new array.
- `LArray:matmul`: Returns matrix multiplication of this array and another array.
- `LArray:max`: Returns total maximum or a maximum array along a one-based axis.
- `LArray:mean`: Returns total mean or a mean array along a one-based axis.
- `LArray:min`: Returns total minimum or a minimum array along a one-based axis.
- `LArray:mul`: Returns element-wise multiplication with an array or scalar.
- `LArray:mulInplace`: Multiplies this array by another array in place.
- `LArray:neg`: Returns element-wise negated values.
- `LArray:neq`: Returns element-wise inequality comparison with an array or scalar.
- `LArray:normalizeRange`: Returns array values normalized into a target range.
- `LArray:normalizeVec`: Returns this vector normalized to unit length.
- `LArray:outer`: Returns outer product with another vector array.
- `LArray:pearsonCorr`: Returns Pearson correlation with another array.
- `LArray:percentile`: Returns a percentile value from the array.
- `LArray:pow`: Returns this array raised element-wise to a scalar exponent.
- `LArray:reduce`: Reduces array values with a Lua accumulator function.
- `LArray:reshape`: Returns a reshaped copy of this array.
- `LArray:scan`: Produces prefix accumulator values with a Lua function.
- `LArray:set`: Writes an array element using one-based indices followed by the value.
- `LArray:setRegion`: Writes a source array into this array at a one-based row and column.
- `LArray:sobel`: Computes Sobel gradients for this array.
- `LArray:sqrt`: Returns element-wise square roots.
- `LArray:sub`: Returns element-wise subtraction with an array or scalar.
- `LArray:subInplace`: Subtracts another array from this array in place.
- `LArray:sum`: Returns total sum or a summed array along a one-based axis.
- `LArray:threshold`: Returns a mask array where values above a threshold are selected.
- `LArray:toTable`: Returns array values flattened into a Lua table.
- `LArray:transformPoints`: Transforms a point array by this transform matrix.
- `LArray:transpose`: Returns a transposed copy of a two-dimensional array.
- `LArray:type`: Returns the Lua-visible type name for this array handle.
- `LArray:typeOf`: Returns whether this array handle matches a supported type name.
- `LArray:where`: Selects values from this array or another array using a mask array.
- `LArray:zscore`: Returns z-score normalized array values.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.
