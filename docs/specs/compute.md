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

- The `compute` module is the dense numeric workspace for users who want array-heavy processing, analysis, and transformation logic inside the engine.
- Multidimensional arrays, element-wise operations, reductions, and in-place math make it practical to treat data as a structured computation surface instead of hand-written Lua loops over raw tables.
- Linear algebra, decompositions, and solver-style helpers extend that into simulation, optimization, and transform-oriented workloads where matrix logic must stay explicit and reusable.
- FFT, convolution, morphology, spatial processing, and statistics push the module beyond generic arithmetic, so image-like grids, signal data, and analytics pipelines can all live under one API surface.
- Parallel thresholds and typed operations matter from a user perspective because the same script-facing module can scale from quick experimentation to heavier numeric workloads without changing conceptual models.
- The module is also a useful bridge for neighboring numeric systems such as image processing, signal work, procedural analysis, and learning-oriented workloads because they often need dense arrays before they need a more specialized domain API.
- Deterministic typed array behavior matters for tooling and tests as much as for performance. Users can prototype a transform interactively and still keep the same operations reproducible enough for validation or batch workflows.
- That combination of expressiveness and repeatability is what makes the module practical for both interactive analysis and scripted offline processing.
- This makes it a practical staging area for algorithms that start as experiments and later become reusable runtime tools.
- Read `compute` as the engine feature that turns numerical data processing into a first-class runtime capability rather than an external preprocessing step.


## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Files

### analytics.rs

- `src/compute/analytics.rs` owns derived statistics, cumulative transforms, and distribution metrics over `NdArray`.
- It provides cumsum, finite differences, histograms, percentiles, covariance, correlation, scaling, and z-score helpers.
- Convolution and correlation helpers over 1D arrays also live here so analysis-style signal transforms stay nearby.
- This file is the metrics and summary boundary for compute arrays; it does not own storage or primitive arithmetic.
- Read it when statistical outputs, histogram semantics, normalization behavior, or analytic transforms need changes.
- Array shape and dtype expectations are enforced here before metrics run, keeping compute diagnostics deterministic.

### array.rs

- `src/compute/array.rs` owns the dense `NdArray` container, dtype metadata, strides, and raw byte storage contract.
- It defines `DataType` and `NdArray`, including shape validation, element limits, constructors, and indexing helpers.
- Flat and coordinate-based access, typed reads and writes, raw buffer exposure, and reshape metadata all live here.
- This file is the storage boundary for compute data; higher-level analytics, ops, and transforms build on this contract.
- Read it when dtype behavior, allocation limits, shape semantics, or dense array indexing rules need to change.
- Common constructors such as zeros, ones, ranges, slices, fills, maps, and iterators stay here for stable array setup.
- The module keeps array memory deterministic and allocation-aware so sibling compute code can trust buffer layout.

### fft.rs

- `src/compute/fft.rs` owns radix-2 Fourier transforms, inverse reconstruction, and magnitude extraction for 1D signals.
- It stores the internal complex scalar helpers, padding rules, bit-reversal logic, and in-place butterfly execution path.
- Automatic power-of-two padding and inverse scaling live here so FFT semantics stay deterministic across uneven inputs.
- This file is the spectral-transform boundary for compute; it does not own dense arrays, analytics, or spatial kernels.
- Read it when FFT sizing, inverse behavior, spectrum magnitude rules, or complex transform internals need changes.

### linalg.rs

- `src/compute/linalg.rs` owns vector, matrix, and factorization helpers built on top of `NdArray` compute storage.
- It provides normalization, cross products, outer products, affine transforms, Sobel kernels, LU, and power iteration.
- Linear-system solving with pivoted elimination also lives here so decomposition and solve semantics stay paired.
- This file is the matrix-and-geometry boundary for compute arrays; it does not own primitive storage or elementwise ops.
- Read it when transform matrices, decomposition metadata, solver behavior, or geometric numeric helpers need changes.
- Spatial convolution is reused here for Sobel-style operations, linking edge-analysis helpers to the spatial subsystem.
- Factorization outputs such as `LuDecomp` stay here so callers can inspect permutation and determinant-sign metadata.

### mod.rs

- `src/compute/mod.rs` is the module index for dense arrays, transforms, analytics, linear algebra, ops, and spatial.
- It declares the files that own core numeric containers, FFT helpers, reductions, geometry, and neighborhood processing.
- This file reexports the main compute types so callers can use numeric services without importing deep internal paths.
- No shape metadata, parallel thresholds, or transform buffers live here; it only defines visibility and boundaries.
- Read this index first when tracing compute behavior, because it shows where storage, math, and derived metrics split.
- Changes here affect reachability and API shape, not dtype validation, reduction rules, or transform implementations.

### ops.rs

- `src/compute/ops.rs` owns arithmetic, comparisons, reductions, reshaping, and in-place updates for arrays.
- It implements scalar and array binary ops, limited broadcasting, dtype-aware bitwise paths, and axis-based reductions.
- The file also stores the global parallel-dispatch threshold that decides when Rayon-backed execution should be used.
- Reshape, transpose, masks, thresholding, argmin or argmax, and boolean-style any or all helpers all live here.
- This file is the primitive numeric-ops boundary for compute arrays; it does not own storage layout or FFT transforms.
- Broadcast checks, axis validation, dtype checks, and mutation rules are enforced here before numeric work begins.
- In-place add, sub, mul, and div updates are centralized here so aliasing behavior stays explicit.
- Bitwise operations stay here because they share the same shape and dtype validation rules as scalar arithmetic paths.
- Read it when core array math, reduction semantics, broadcast policy, or parallel dispatch behavior needs changes.

### spatial.rs

- `src/compute/spatial.rs` owns 2D neighborhood operators, region editing, and matrix-style spatial transforms.
- It provides convolution, dilation, erosion, flood fill, region extraction, region writes, matmul, and dot products.
- Zero-padding, Manhattan-radius morphology, and queue-driven fill behavior live here so spatial semantics stay local.
- This file is the neighborhood-processing boundary for compute arrays; it does not own dense storage or scalar analytics.
- Read it when 2D filtering, morphology, flood-fill semantics, or spatial matrix helpers for array data need changes.
- Shape validation happens here before spatial work begins, keeping region and kernel operations deterministic and safe.



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

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- No additional module-specific notes.
