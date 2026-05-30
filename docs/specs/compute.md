# compute

## TL;DR

- The `compute` module provides a CPU-first N-dimensional array toolkit for numeric transforms, statistics, linear algebra, FFT, and spatial processing through one consistent API.

## General Info

- Module group: `Foundations`
- Source path: `src/compute/`
- Binding: `src/lua_api/compute_api.rs`
- Namespace: `lurek.compute`
- Lua API surface: `13` functions, `6` types, `80` methods
- Rust test path(s): tests/rust/unit/compute_tests.rs; tests/rust/stress/compute_stress_tests.rs; inline tests in src/compute/array.rs, src/compute/spatial.rs
- Lua test path(s): tests/lua/unit/test_compute.lua; tests/lua/stress/test_compute_stress.lua; tests/lua/integration/test_data_compute.lua; tests/lua/integration/test_compute_dataframe.lua; tests/lua/golden/test_compute_golden.lua

## Summary

The `compute` module is the engine's general-purpose numeric workspace. It gives scripts and systems one place to create typed arrays and run deterministic math over them, from simple element-wise operations to heavier analytical and transform workflows.

Its functional coverage is broad but coherent. The same array model supports arithmetic, reductions, reshaping, comparisons, and in-place updates, then extends into matrix math, FFT-based spectral analysis, neighborhood filtering, and statistical post-processing.

Because these capabilities share one data contract, teams can build end-to-end numeric pipelines without jumping between incompatible formats. This helps with simulation logic, data preparation, tool-side analysis, and runtime feature code that depends on reliable numerical behavior.

The module is designed to stay CPU-first and predictable. It exposes shape and type constraints clearly, reports mismatch errors early, and keeps parallelism controls explicit so callers can choose between throughput and strict repeatability.

From a workflow perspective, the module helps unify experimentation and production code. The same primitives used for quick script exploration can be reused in stable runtime paths, so teams can prototype calculations, validate them, and keep the exact logic in shipped features without rewriting data handling around a different math stack.

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

