# compute

## TL;DR

- Manages dense array math, linear algebra, and FFT transforms.
- Computes spatial convolutions and statistical distributions.

## General Info

- Module group: `Foundations`
- Source path: `src/compute/`
- Binding: `src/lua_api/compute_api.rs`
- Namespace: `lurek.compute`
- Lua API surface: `13` functions, `6` types, `80` methods
- Rust test path(s): tests/rust/unit/compute_tests.rs; tests/rust/stress/compute_stress_tests.rs; inline tests in src/compute/array.rs, src/compute/spatial.rs
- Lua test path(s): tests/lua_reorg/unit/test_compute.lua; tests/lua_reorg/stress/test_compute_stress.lua; tests/lua_reorg/integration/test_data_compute.lua; tests/lua_reorg/integration/test_compute_dataframe.lua; tests/lua_reorg/golden/test_compute_golden.lua

## Summary

- Gives users a dense numeric workspace for array-heavy gameplay, simulation, AI, and analysis tasks.
- Exposes multidimensional arrays that make matrix and tensor-like logic practical from Lua.
- Supports common constructors and shape operations so data pipelines start quickly and stay explicit.
- Enables element-wise arithmetic, comparisons, reductions, and logical transforms for fast feature engineering.
- Provides in-place operations for performance-sensitive loops where allocation churn must stay low.
- Includes axis-aware aggregates for summarizing large datasets without custom iteration code.
- Supports linear algebra workflows for transforms, constraints, and solver-driven mechanics.
- Offers matrix decomposition and linear-system tools useful in optimization and simulation scenarios.
- Adds eigen and vector utilities for directional analysis and advanced math features.
- Includes FFT and inverse FFT paths for spectral analysis, rhythm tools, and signal-oriented gameplay.
- Provides convolution and Sobel operations for image-like or grid-based processing.
- Supports morphology and flood-fill style operations for map processing and mask refinement tasks.
- Delivers histogram, percentile, z-score, and correlation analytics for telemetry and balancing.
- Gives one pipeline from raw numeric data to derived insights without leaving engine runtime.
- Supports configurable parallel thresholds so heavy workloads can scale better on larger inputs.
- Helps teams avoid reimplementing math kernels in ad-hoc Lua loops.
- Acts as the user-facing compute backbone for projects that need more than scalar scripting.
- Balances high-level ergonomics with deterministic behavior required by tests and reproducible runs.
- Bridges gameplay scripting and scientific-style data operations in one cohesive module surface.
- Improves iteration speed by keeping experimentation, diagnostics, and math-heavy logic in-engine.
- Serves as the practical foundation for data-driven systems that depend on robust numeric primitives.

This module is mostly self-contained inside the Foundations group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Files

### analytics.rs

- Implements analytical operations over arrays including cumulative, differential, and distribution metrics.
- Provides histogram generation with configurable domains and binning resolution control.
- Computes percentile estimates with interpolation for robust quantile-style inspection workflows.
- Exposes pairwise statistics such as covariance and correlation for relationship analysis.
- Includes normalization helpers for range scaling and standardized z-score transformations.
- Serves as the statistical post-processing layer for compute arrays and derived results.

### array.rs

- Implements the dense n-dimensional array container used by all compute submodules.
- Stores typed scalar buffers with explicit shape metadata and deterministic stride computation.
- Validates dimensions and element counts to protect allocation and indexing safety boundaries.
- Provides constructors for common initialization flows including zeros, ones, ranges, and slices.
- Supports flat and coordinate-based access paths for algorithmic and ergonomic usage patterns.
- Exposes utility mapping, filling, and iteration helpers for transformation pipelines.
- Serves as the foundational data model for operations, analytics, spatial, and linalg layers.

### fft.rs

- Implements radix-2 fast Fourier transform and inverse transform over power-of-two signal lengths.
- Supports forward real-to-complex conversion with automatic padding for nonconforming input sizes.
- Provides inverse reconstruction paths from complex spectra back to real-domain samples.
- Exposes magnitude extraction helpers for frequency-domain inspection and feature analysis.
- Serves as the spectral-analysis primitive layer for compute-side signal processing tasks.

### linalg.rs

- Implements linear-algebra and geometric helper operations over compute array structures.
- Provides vector normalization, cross-style products, and matrix-oriented transformation utilities.
- Includes kernel builders and edge-oriented operators for signal and image-adjacent workflows.
- Solves linear systems with Gaussian elimination using pivoting for improved numerical stability.
- Computes LU decomposition with permutation tracking to support determinant-aware factorization.
- Exposes dominant eigenpair estimation through iterative power-method style evaluation.
- Serves as the algebraic backbone for higher-level analytical and spatial compute tasks.

### mod.rs

- Defines the compute module boundary for array math, analytics, transforms, and spatial processing.
- Groups core numeric submodules under one cohesive surface with shared data contracts.
- Serves as the composition entry for engine-side compute and numeric utility workflows.

### ops.rs

- Implements the primary array-operations engine for arithmetic, comparison, logic, and reduction flows.
- Supports scalar-array and array-array binary operations with bounded broadcast compatibility.
- Provides global and axis-based reductions including sum, mean, min, max, and related aggregates.
- Exposes in-place mutation variants for additive, subtractive, multiplicative, and divisive updates.
- Includes reshape, transpose, cloning, thresholding, and conditional selection utilities.
- Handles integer and floating operation variants through dtype-aware dispatch behavior.
- Integrates configurable parallel execution thresholds for rayon-backed large-array workloads.
- Returns deterministic error messages on shape mismatch, invalid axis, or unsupported operation cases.
- Provides positional and logical queries such as argmin, argmax, nonzero count, any, and all.
- Preserves predictable semantics across contiguous and non-trivial shape transformations.
- Serves as the high-throughput compute workhorse used by analytics and algorithmic systems.
- Anchors most data-manipulation behavior on top of the shared NdArray contract.

### spatial.rs

- Implements spatial and neighborhood operations over array-based 1D and 2D data surfaces.
- Provides zero-padded convolution for kernel filtering across image-like matrix inputs.
- Includes binary morphology operators such as dilation and erosion with radius-based neighborhoods.
- Supports flood-fill propagation and region extraction or insertion for localized data editing.
- Exposes matrix multiplication and dot-product helpers for core spatial-numeric composition.
- Serves as the spatial-processing utility layer built on top of NdArray primitives.

## Types

- `DataType` (`enum`, `array.rs`): Selects scalar storage type used by an NdArray instance. Details: variants: Float32, Float64, Int32 | methods: byte_size (Return byte width of dtype element representation.); name (Return canonical dtype name string.); parse (Parse dtype string and return matching DataType or parse error.)
- `NdArray` (`struct`, `array.rs`): Stores dense n-dimensional array metadata and raw typed element bytes. Details: methods: compute_strides (Compute row-major strides and return stride vector for provided shape.); data (Read immutable byte buffer and return raw data slice.); data_mut (Read mutable byte buffer and return raw mutable data slice.); display_string (Format array summary and return short display string.); dtype (Read scalar dtype and return DataType value.); fill (Fill all elements with scalar value and return after mutation.); flat_index (Convert multidimensional indices to flat index and return offset.); from_slice (Build array from f64 slice and return typed array with requested shape.); get_by_indices (Read element by multidimensional indices and return f64 value.); get_f64 (Read element by flat index and return value converted to f64.); get_i32 (Read element as i32 by flat index and return integer value.); iter_f64 (Iterate elements as f64 values and return lazy iterator.); map (Map function over elements and return new array with mapped values.); ndim (Read number of dimensions and return ndim value.); new (Create zero-initialized array and return it for shape and dtype.); ones (Allocate one-filled array and return initialized values.); range (Build 1D range array and return values from start to stop with step.); set_by_indices (Write element by multidimensional indices and return success status.); set_f64 (Write f64 value by flat index and return after dtype conversion.); set_i32 (Write i32 value by flat index and return after byte update.); set_shape (Replace shape and stride metadata and return after metadata update.); shape (Read shape slice and return axis lengths.); size (Read element count and return total number of elements.); strides (Read stride slice and return per-axis element strides.); to_f64_vec (Convert all elements to f64 and return copied vector.); zeros (Allocate zero-filled array and return it after validating shape limits.)
- `LuDecomp` (`struct`, `linalg.rs`): Stores compact LU decomposition with row permutation metadata. Details: fields: lu_data: Vec<f64>, perm: Vec<usize>, n: usize, det_sign: i32

## Functions

- `cumsum` (`analytics.rs`): Compute cumulative sum and return a 1D array with running totals.
- `diff` (`analytics.rs`): Compute finite difference of requested order and return derived 1D array.
- `histogram` (`analytics.rs`): Compute histogram bins and return (lo, hi, count) tuples for each bin.
- `percentile` (`analytics.rs`): Compute percentile value and return interpolated sample at p in [0, 100].
- `covariance` (`analytics.rs`): Compute population covariance and return scalar covariance between arrays.
- `pearson_corr` (`analytics.rs`): Compute Pearson correlation and return normalized linear correlation coefficient.
- `normalize_range` (`analytics.rs`): Normalize values to output range and return scaled 1D array.
- `zscore` (`analytics.rs`): Normalize values to z-scores and return array with mean-zero unit variance.
- `convolve1d` (`analytics.rs`): Compute full 1D convolution and return output signal array.
- `correlate1d` (`analytics.rs`): Compute valid 1D correlation and return sliding dot-product array.
- `DataType::parse` (`array.rs`): Parse dtype string and return matching DataType or parse error.
- `DataType::byte_size` (`array.rs`): Return byte width of dtype element representation.
- `DataType::name` (`array.rs`): Return canonical dtype name string.
- `NdArray::new` (`array.rs`): Create zero-initialized array and return it for shape and dtype.
- `NdArray::zeros` (`array.rs`): Allocate zero-filled array and return it after validating shape limits.
- `NdArray::ones` (`array.rs`): Allocate one-filled array and return initialized values.
- `NdArray::range` (`array.rs`): Build 1D range array and return values from start to stop with step.
- `NdArray::from_slice` (`array.rs`): Build array from f64 slice and return typed array with requested shape.
- `NdArray::get_f64` (`array.rs`): Read element by flat index and return value converted to f64.
- `NdArray::set_f64` (`array.rs`): Write f64 value by flat index and return after dtype conversion.
- `NdArray::get_i32` (`array.rs`): Read element as i32 by flat index and return integer value.
- `NdArray::set_i32` (`array.rs`): Write i32 value by flat index and return after byte update.
- `NdArray::flat_index` (`array.rs`): Convert multidimensional indices to flat index and return offset.
- `NdArray::shape` (`array.rs`): Read shape slice and return axis lengths.
- `NdArray::dtype` (`array.rs`): Read scalar dtype and return DataType value.
- `NdArray::size` (`array.rs`): Read element count and return total number of elements.
- `NdArray::ndim` (`array.rs`): Read number of dimensions and return ndim value.
- `NdArray::strides` (`array.rs`): Read stride slice and return per-axis element strides.
- `NdArray::data` (`array.rs`): Read immutable byte buffer and return raw data slice.
- `NdArray::data_mut` (`array.rs`): Read mutable byte buffer and return raw mutable data slice.
- `NdArray::set_shape` (`array.rs`): Replace shape and stride metadata and return after metadata update.
- `NdArray::compute_strides` (`array.rs`): Compute row-major strides and return stride vector for provided shape.
- `NdArray::get_by_indices` (`array.rs`): Read element by multidimensional indices and return f64 value.
- `NdArray::set_by_indices` (`array.rs`): Write element by multidimensional indices and return success status.
- `NdArray::to_f64_vec` (`array.rs`): Convert all elements to f64 and return copied vector.
- `NdArray::fill` (`array.rs`): Fill all elements with scalar value and return after mutation.
- `NdArray::map` (`array.rs`): Map function over elements and return new array with mapped values.
- `NdArray::iter_f64` (`array.rs`): Iterate elements as f64 values and return lazy iterator.
- `NdArray::display_string` (`array.rs`): Format array summary and return short display string.
- `next_power_of_two` (`fft.rs`): Compute next power-of-two length and return unchanged value when already aligned.
- `fft` (`fft.rs`): Compute FFT for real input and return padded complex spectrum pairs.
- `ifft` (`fft.rs`): Compute inverse FFT from complex bins and return reconstructed real samples.
- `fft_magnitude` (`fft.rs`): Compute FFT magnitude spectrum and return absolute value per complex bin.
- `normalize_vec` (`linalg.rs`): Normalize 1D vector and return unit-length vector with same dtype.
- `cross2d` (`linalg.rs`): Compute 2D cross product scalar and return signed area component.
- `outer` (`linalg.rs`): Compute outer product of two vectors and return `[m,n]` matrix.
- `rotate2d_matrix` (`linalg.rs`): Build 2D rotation matrix and return `[2,2]` Float64 matrix.
- `affine2d` (`linalg.rs`): Build 2D affine matrix and return `[3,3]` Float64 transform matrix.
- `transform_points` (`linalg.rs`): Transform `[N,2]` points and return transformed `[N,2]` points array.
- `gaussian_kernel` (`linalg.rs`): Build normalized odd-sized Gaussian kernel and return `[size,size]` matrix.
- `sobel` (`linalg.rs`): Compute Sobel gradients and return (gx, gy) filtered arrays.
- `linsolve` (`linalg.rs`): Solve linear system and return solution vector using Gaussian elimination.
- `lu_decompose` (`linalg.rs`): Compute LU decomposition and return packed factors with pivot metadata.
- `eigenvalue_power` (`linalg.rs`): Estimate dominant eigenpair and return (eigenvalue, eigenvector).
- `get_par_threshold` (`ops.rs`): Read current parallel threshold and return minimum size for parallel dispatch.
- `set_par_threshold` (`ops.rs`): Set parallel threshold and return previous threshold value.
- `add` (`ops.rs`): Add arrays element-wise and return result with broadcast support.
- `add_scalar` (`ops.rs`): Add scalar to array and return element-wise result.
- `sub` (`ops.rs`): Subtract arrays element-wise and return result with broadcast support.
- `sub_scalar` (`ops.rs`): Subtract scalar from array and return element-wise result.
- `mul` (`ops.rs`): Multiply arrays element-wise and return result with broadcast support.
- `mul_scalar` (`ops.rs`): Multiply array by scalar and return element-wise result.
- `div` (`ops.rs`): Divide arrays element-wise and return result with broadcast support.
- `div_scalar` (`ops.rs`): Divide array by scalar and return element-wise result.
- `pow_scalar` (`ops.rs`): Raise each element to exponent and return transformed array.
- `sqrt` (`ops.rs`): Compute square root per element and return transformed array.
- `abs` (`ops.rs`): Compute absolute value per element and return transformed array.
- `neg` (`ops.rs`): Negate each element and return transformed array.
- `clamp` (`ops.rs`): Clamp each element to range and return transformed array.
- `eq` (`ops.rs`): Compare arrays for equality and return float mask array.
- `eq_scalar` (`ops.rs`): Compare array to scalar for equality and return float mask array.
- `neq` (`ops.rs`): Compare arrays for inequality and return float mask array.
- `neq_scalar` (`ops.rs`): Compare array to scalar for inequality and return float mask array.
- `gt` (`ops.rs`): Compare arrays for greater-than and return float mask array.
- `gt_scalar` (`ops.rs`): Compare array to scalar for greater-than and return float mask array.
- `lt` (`ops.rs`): Compare arrays for less-than and return float mask array.
- `lt_scalar` (`ops.rs`): Compare array to scalar for less-than and return float mask array.
- `gte` (`ops.rs`): Compare arrays for greater-or-equal and return float mask array.
- `gte_scalar` (`ops.rs`): Compare array to scalar for greater-or-equal and return float mask array.
- `lte` (`ops.rs`): Compare arrays for less-or-equal and return float mask array.
- `lte_scalar` (`ops.rs`): Compare array to scalar for less-or-equal and return float mask array.
- `threshold` (`ops.rs`): Build threshold mask and return elements greater-or-equal to threshold as ones.
- `where_mask` (`ops.rs`): Select values by mask and return merged output array.
- `count_nonzero` (`ops.rs`): Count non-zero elements and return total count.
- `argmin` (`ops.rs`): Return flat index of minimum element.
- `argmax` (`ops.rs`): Return flat index of maximum element.
- `any` (`ops.rs`): Return true when any element is non-zero.
- `all` (`ops.rs`): Return true when all elements are non-zero.
- `sum` (`ops.rs`): Sum elements and return scalar total.
- `mean` (`ops.rs`): Compute mean value and return scalar average.
- `min_val` (`ops.rs`): Compute minimum element value and return scalar minimum.
- `max_val` (`ops.rs`): Compute maximum element value and return scalar maximum.
- `sum_axis` (`ops.rs`): Sum elements along axis and return reduced array.
- `mean_axis` (`ops.rs`): Compute mean along axis and return reduced array.
- `min_axis` (`ops.rs`): Compute minimum along axis and return reduced array.
- `max_axis` (`ops.rs`): Compute maximum along axis and return reduced array.
- `reshape` (`ops.rs`): Reshape array metadata and return cloned array with new shape.
- `transpose_2d` (`ops.rs`): Transpose 2D array and return array with swapped axes.
- `fill` (`ops.rs`): Fill array in place and return after mutation.
- `add_inplace` (`ops.rs`): Add second array into first array in place and return success status.
- `sub_inplace` (`ops.rs`): Subtract second array from first array in place and return success status.
- `mul_inplace` (`ops.rs`): Multiply first array by second array in place and return success status.
- `div_inplace` (`ops.rs`): Divide first array by second array in place and return success status.
- `clone_array` (`ops.rs`): Clone array and return independent copy.
- `bitwise_and` (`ops.rs`): Compute bitwise AND and return int32 output array.
- `bitwise_or` (`ops.rs`): Compute bitwise OR and return int32 output array.
- `bitwise_xor` (`ops.rs`): Compute bitwise XOR and return int32 output array.
- `bitwise_not` (`ops.rs`): Compute bitwise NOT and return int32 output array.
- `bitwise_lshift` (`ops.rs`): Shift int32 elements left and return shifted output array.
- `bitwise_rshift` (`ops.rs`): Shift int32 elements right and return shifted output array.
- `convolve2d` (`spatial.rs`): Convolve 2D input with 2D kernel and return same-sized output array.
- `dilate` (`spatial.rs`): Apply binary dilation with Manhattan radius and return dilated mask array.
- `erode` (`spatial.rs`): Apply binary erosion with Manhattan radius and return eroded mask array.
- `flood_fill` (`spatial.rs`): Flood fill from seed coordinate and return array with replaced connected region.
- `get_region` (`spatial.rs`): Copy a 2D sub-region and return extracted array of requested size.
- `set_region` (`spatial.rs`): Write source 2D region into target array and return success or bounds error.
- `matmul` (`spatial.rs`): Multiply two 2D matrices and return matrix product array.
- `dot` (`spatial.rs`): Compute dot product of two 1D vectors and return scalar sum.

## Lua API Reference

### Functions

- `lurek.compute.affine2d(tx, ty, angle_rad, sx, sy) -> LArray`: Creates a 2D affine transform matrix.
- `lurek.compute.fft(samples) -> table`: Computes the FFT of real-valued samples.
- `lurek.compute.fftMagnitude(samples) -> number[]`: Computes FFT magnitudes for real-valued samples.
- `lurek.compute.fromTable(data, shape?, dtype?) -> LArray`: Creates an array from a flat Lua table and optional shape.
- `lurek.compute.gaussianKernel(size, sigma) -> LArray`: Creates a square Gaussian kernel array.
- `lurek.compute.getParThreshold() -> integer`: Returns the global compute parallelism threshold.
- `lurek.compute.ifft(freqs) -> number[]`: Computes the inverse FFT of complex frequency pairs.
- `lurek.compute.newArray(shape, dtype?) -> LArray`: Creates a zero-filled array with the requested shape and data type.
- `lurek.compute.ones(shape, dtype?) -> LArray`: Creates a one-filled array with the requested shape and data type.
- `lurek.compute.range(start, stop, step?, dtype?) -> LArray`: Creates a one-dimensional range array.
- `lurek.compute.rotate2dMatrix(angle_rad) -> LArray`: Creates a 2D rotation matrix from an angle in radians.
- `lurek.compute.setParThreshold(threshold) -> integer`: Sets the global compute parallelism threshold and returns the previous value.
- `lurek.compute.zeros(shape, dtype?) -> LArray`: Creates a zero-filled array with the requested shape and data type.

### Callbacks

- `LArray:map` param `func` (`function`): Function called with each element value and returning a number.
- `LArray:reduce` param `func` (`function`): Function called as `(accumulator, value)` and returning the next accumulator.
- `LArray:scan` param `func` (`function`): Function called as `(accumulator, value)` and returning the next accumulator.

### Enums

- No documented module-level enums/constants.

### Types

#### LArray Type

- Lua-side multidimensional numeric array handle.

##### Fields

- No documented fields.

##### Methods

- `LArray:abs() -> LArray`: Returns element-wise absolute values.
- `LArray:add(value) -> LArray`: Returns element-wise addition with an array or scalar.
- `LArray:addInplace(other) -> nil`: Adds another array into this array in place.
- `LArray:all() -> boolean`: Returns whether all elements are non-zero.
- `LArray:any() -> boolean`: Returns whether any element is non-zero.
- `LArray:argmax() -> integer`: Returns the one-based flat index of the maximum value.
- `LArray:argmin() -> integer`: Returns the one-based flat index of the minimum value.
- `LArray:bitwiseAnd(other) -> LArray`: Returns element-wise bitwise AND with another array.
- `LArray:bitwiseLShift(amount) -> LArray`: Returns element-wise left shift by a bit count.
- `LArray:bitwiseNot() -> LArray`: Returns element-wise bitwise NOT.
- `LArray:bitwiseOr(other) -> LArray`: Returns element-wise bitwise OR with another array.
- `LArray:bitwiseRShift(amount) -> LArray`: Returns element-wise right shift by a bit count.
- `LArray:bitwiseXor(other) -> LArray`: Returns element-wise bitwise XOR with another array.
- `LArray:clamp(min, max) -> LArray`: Returns values clamped between minimum and maximum bounds.
- `LArray:clone() -> LArray`: Returns an independent deep copy of this array.
- `LArray:convolve1d(kernel) -> LArray`: Returns one-dimensional convolution with a kernel array.
- `LArray:convolve2D(kernel) -> LArray`: Returns two-dimensional convolution with a kernel array.
- `LArray:correlate1d(template) -> LArray`: Returns one-dimensional correlation with a template array.
- `LArray:countNonZero() -> integer`: Counts the number of non-zero elements in this array.
- `LArray:covariance(other) -> number`: Returns covariance with another array.
- `LArray:cross2d(other) -> number`: Returns two-dimensional cross product with another vector.
- `LArray:cumsum() -> LArray`: Returns cumulative sum over the flattened array.
- `LArray:diff(order?) -> LArray`: Returns finite differences over the flattened array.
- `LArray:dilate(radius) -> LArray`: Returns morphological dilation with a radius.
- `LArray:div(value) -> LArray`: Returns element-wise division with an array or scalar.
- `LArray:divInplace(other) -> nil`: Divides this array by another array in place.
- `LArray:dot(other) -> number`: Returns dot product with another array.
- `LArray:eigenPower(max_iter?, tol?) -> table`: Estimates dominant eigenvalue and eigenvector using power iteration.
- `LArray:eq(value) -> LArray`: Returns element-wise equality comparison with an array or scalar.
- `LArray:erode(radius) -> LArray`: Returns morphological erosion with a radius.
- `LArray:eval(expr) -> LArray`: Maps each element through a Lua expression compiled as `function(x) return expression end`.
- `LArray:fill(val) -> nil`: Fills this array in place with one value.
- `LArray:floodFill(row, col, val) -> LArray`: Returns a flood-filled copy starting at a one-based row and column.
- `LArray:get(...) -> number`: Reads an array element using one-based indices.
- `LArray:getDataType() -> string`: Returns the element data type name as a string.
- `LArray:getDimensions() -> integer`: Returns the number of array dimensions.
- `LArray:getRegion(row, col, rows, cols) -> LArray`: Returns a rectangular region from this array.
- `LArray:getShape() -> integer[]`: Returns the array shape as one-based dimension table.
- `LArray:getSize() -> integer`: Returns the total number of array elements.
- `LArray:gt(value) -> LArray`: Returns element-wise greater-than comparison with an array or scalar.
- `LArray:gte(value) -> LArray`: Returns element-wise greater-or-equal comparison with an array or scalar.
- `LArray:histogram(bins, lo?, hi?) -> table`: Returns histogram bins for the array values.
- `LArray:isOnGPU() -> boolean`: Returns whether this array is currently stored on the GPU.
- `LArray:linsolve(b) -> LArray`: Solves a linear system using this matrix and a right-hand side array.
- `LArray:lt(value) -> LArray`: Returns element-wise less-than comparison with an array or scalar.
- `LArray:lte(value) -> LArray`: Returns element-wise less-or-equal comparison with an array or scalar.
- `LArray:luDecompose() -> table`: Decomposes this matrix into LU data and permutation metadata.
- `LArray:map(func) -> LArray`: Maps each element through a Lua function and returns a new array.
- `LArray:matmul(other) -> LArray`: Returns matrix multiplication of this array and another array.
- `LArray:max(axis?) -> number`: Returns total maximum or a maximum array along a one-based axis.
- `LArray:mean(axis?) -> number`: Returns total mean or a mean array along a one-based axis.
- `LArray:min(axis?) -> number`: Returns total minimum or a minimum array along a one-based axis.
- `LArray:mul(value) -> LArray`: Returns element-wise multiplication with an array or scalar.
- `LArray:mulInplace(other) -> nil`: Multiplies this array by another array in place.
- `LArray:neg() -> LArray`: Returns element-wise negated values.
- `LArray:neq(value) -> LArray`: Returns element-wise inequality comparison with an array or scalar.
- `LArray:normalizeRange(lo, hi) -> LArray`: Returns array values normalized into a target range.
- `LArray:normalizeVec() -> LArray`: Returns this vector normalized to unit length.
- `LArray:outer(other) -> LArray`: Returns outer product with another vector array.
- `LArray:pearsonCorr(other) -> number`: Returns Pearson correlation with another array.
- `LArray:percentile(p) -> number`: Returns a percentile value from the array.
- `LArray:pow(exp) -> LArray`: Returns this array raised element-wise to a scalar exponent.
- `LArray:reduce(func, init) -> number`: Reduces array values with a Lua accumulator function.
- `LArray:reshape(shape) -> LArray`: Returns a reshaped copy of this array.
- `LArray:scan(func, init) -> LArray`: Produces prefix accumulator values with a Lua function.
- `LArray:set(...) -> nil`: Writes an array element using one-based indices followed by the value.
- `LArray:setRegion(row, col, source) -> nil`: Writes a source array into this array at a one-based row and column.
- `LArray:sobel() -> table`: Computes Sobel gradients for this array.
- `LArray:sqrt() -> LArray`: Returns element-wise square roots.
- `LArray:sub(value) -> LArray`: Returns element-wise subtraction with an array or scalar.
- `LArray:subInplace(other) -> nil`: Subtracts another array from this array in place.
- `LArray:sum(axis?) -> number`: Returns total sum or a summed array along a one-based axis.
- `LArray:threshold(val) -> LArray`: Returns a mask array where values above a threshold are selected.
- `LArray:toTable() -> number[]`: Returns array values flattened into a Lua table.
- `LArray:transformPoints(pts) -> LArray`: Transforms a point array by this transform matrix.
- `LArray:transpose() -> LArray`: Returns a transposed copy of a two-dimensional array.
- `LArray:type() -> string`: Returns the Lua-visible type name for this array handle.
- `LArray:typeOf(name) -> boolean`: Returns whether this array handle matches a supported type name.
- `LArray:where(mask, other) -> LArray`: Selects values from this array or another array using a mask array.
- `LArray:zscore() -> LArray`: Returns z-score normalized array values.

#### LArrayEigenPowerResult Type

- Generated result shape from @field tags.

##### Fields

- `value` (`number`): Dominant eigenvalue.
- `vector` (`number[]`): Eigenvector.

##### Methods

- No documented methods.

#### LArrayHistogramResult Type

- Generated result shape from @field tags.

##### Fields

- `count` (`integer`): Number of values in bin.
- `hi` (`number`): Bin upper bound.
- `lo` (`number`): Bin lower bound.

##### Methods

- No documented methods.

#### LArrayLuDecomposeResult Type

- Generated result shape from @field tags.

##### Fields

- `det_sign` (`integer`): Det sign.
- `lu_data` (`number[]`): LU decomposition data.
- `n` (`integer`): N.
- `perm` (`integer[]`): Permutation array.

##### Methods

- No documented methods.

#### LArraySobelResult Type

- Generated result shape from @field tags.

##### Fields

- `gx` (`LArray`): Gradient X array.
- `gy` (`LArray`): Gradient Y array.

##### Methods

- No documented methods.

#### LComputeFftResult Type

- Generated result shape from @field tags.

##### Fields

- `im` (`number`): Imaginary part.
- `re` (`number`): Real part.

##### Methods

- No documented methods.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- No additional module-specific notes.
