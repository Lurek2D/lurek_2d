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
- Lua test path(s): tests/lua/unit/test_compute.lua; tests/lua/stress/test_compute_stress.lua; tests/lua/integration/test_data_compute.lua; tests/lua/integration/test_compute_dataframe.lua; tests/lua/golden/test_compute_golden.lua

## Summary

The compute module serves as the primary high-performance numeric processing engine for Lurek2D. Its core purpose is to provide scripts with dense, multi-dimensional array structures, enabling heavy mathematical calculations directly within game loops. It centers around a robust NdArray model that stores typed scalar buffers with explicit shape strides, supporting initializations for zeros, ones, or custom ranges. It manages sub-regions and supports parallel multithreaded calculation thresholds for massive array blocks.

For scientific computing and complex transformations, the module exposes rich algebraic, geometric, and spectral operations. It provides linear-algebra tools including vector cross products, unit normalizations, Gaussian solvers with pivoting, LU matrix decompositions, and eigenpair estimators. It also includes radix-2 fast Fourier transforms and inverse transforms, allowing scripts to map real-valued waveforms into complex frequency spectra and back for audio or signal-processing tasks.

Spatial data processing and statistical analysis are supported through spatial grid and analytics layers. The spatial engine delivers zero-padded convolutions, Sobel gradient calculations, flood-fill propagation, and morphological dilation or erosion filters over coordinate grids. In parallel, the analytics layer computes cumulative sums, percentile distributions, histogram binning, range scaling, and Pearson correlations, supplying comprehensive telemetry capabilities.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

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

## Lua API Ref

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
