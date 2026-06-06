# compute

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

## Files

### [analytics.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/compute/analytics.rs)

- Implements analytical operations over arrays including cumulative, differential, and distribution metrics.
- Provides histogram generation with configurable domains and binning resolution control.
- Computes percentile estimates with interpolation for robust quantile-style inspection workflows.
- Exposes pairwise statistics such as covariance and correlation for relationship analysis.
- Includes normalization helpers for range scaling and standardized z-score transformations.
- Serves as the statistical post-processing layer for compute arrays and derived results.

### [array.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/compute/array.rs)

- Implements the dense n-dimensional array container used by all compute submodules.
- Stores typed scalar buffers with explicit shape metadata and deterministic stride computation.
- Validates dimensions and element counts to protect allocation and indexing safety boundaries.
- Provides constructors for common initialization flows including zeros, ones, ranges, and slices.
- Supports flat and coordinate-based access paths for algorithmic and ergonomic usage patterns.
- Exposes utility mapping, filling, and iteration helpers for transformation pipelines.
- Serves as the foundational data model for operations, analytics, spatial, and linalg layers.

### [fft.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/compute/fft.rs)

- Implements radix-2 fast Fourier transform and inverse transform over power-of-two signal lengths.
- Supports forward real-to-complex conversion with automatic padding for nonconforming input sizes.
- Provides inverse reconstruction paths from complex spectra back to real-domain samples.
- Exposes magnitude extraction helpers for frequency-domain inspection and feature analysis.
- Serves as the spectral-analysis primitive layer for compute-side signal processing tasks.

### [linalg.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/compute/linalg.rs)

- Implements linear-algebra and geometric helper operations over compute array structures.
- Provides vector normalization, cross-style products, and matrix-oriented transformation utilities.
- Includes kernel builders and edge-oriented operators for signal and image-adjacent workflows.
- Solves linear systems with Gaussian elimination using pivoting for improved numerical stability.
- Computes LU decomposition with permutation tracking to support determinant-aware factorization.
- Exposes dominant eigenpair estimation through iterative power-method style evaluation.
- Serves as the algebraic backbone for higher-level analytical and spatial compute tasks.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/compute/mod.rs)

- Defines the compute module boundary for array math, analytics, transforms, and spatial processing.
- Groups core numeric submodules under one cohesive surface with shared data contracts.
- Serves as the composition entry for engine-side compute and numeric utility workflows.

### [ops.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/compute/ops.rs)

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

### [spatial.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/compute/spatial.rs)

- Implements spatial and neighborhood operations over array-based 1D and 2D data surfaces.
- Provides zero-padded convolution for kernel filtering across image-like matrix inputs.
- Includes binary morphology operators such as dilation and erosion with radius-based neighborhoods.
- Supports flood-fill propagation and region extraction or insertion for localized data editing.
- Exposes matrix multiplication and dot-product helpers for core spatial-numeric composition.
- Serves as the spatial-processing utility layer built on top of NdArray primitives.
