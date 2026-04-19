# IDEA — compute

- **Module**: `compute`
- **Path**: `src/compute/`
- **Date**: 2026-04-18
- **Tier**: Foundations

## Mission

Provide a dense N-dimensional numerical array library (NdArray) with NumPy-style operations for CPU-bound numerical workloads: matrix math, signal processing, convolution, statistics, and linear algebra — exposed to Lua scripts as `lurek.compute.*`.

## Strengths

- Comprehensive operation coverage: element-wise arithmetic, reductions (global + per-axis), comparisons, masking, bitwise ops, shape manipulation, FFT, linear algebra, spatial ops, analytics.
- Clean submodule decomposition: `array` (core type), `ops` (arithmetic/reductions), `spatial` (2D convolution/morphology), `analytics` (statistics/signal), `linalg` (solvers/transforms), `fft` (Fourier).
- Rayon parallelization for element-wise ops above 10k elements.
- Solid existing test suites across all 6 submodules.
- Pure Foundations tier — zero dependencies on Core Runtime or higher groups.
- Three dtype support (f32/f64/i32) with uniform f64 access interface.

## Gaps

- No SIMD/vectorization — all element access goes through `get_f64`/`set_f64` with byte conversion per element.
- No broadcasting — binary ops require identical shapes (no NumPy-style shape broadcasting).
- No sparse array support — dense-only storage (deferred).
- No GPU compute path — `isOnGPU()` returns `false` stub. All operations are CPU-only.
- `NdArray` limited to 1D/2D/3D — no 4D+ support for batch operations.
- No in-place operations — every op allocates a new array.
- No ImageData interop — needs image module alignment (deferred).
- Consider namespace rename: `compute` implies GPU; actual impl is CPU NdArray (breaking change, needs Lua-Designer sign-off).

## Features (competitor cites)

1. **Broadcasting** — NumPy, PyTorch, and LÖVE's `moonshine` tensor lib all support shape broadcasting for binary ops. Lurek2D should support at least scalar-to-array and 1D-to-2D broadcasting.
2. **In-place operations** — NumPy's `out=` parameter and PyTorch's `_` suffix ops (e.g. `add_`) reduce allocation pressure. Add `add_inplace(a, b)` variants for hot-path usage.
3. **Strided views / slicing without copy** — NumPy slicing returns a view, not a copy. Lurek2D's `get_region` copies data. A view-based slice would enable zero-copy windowing for convolution and pooling.

## Perf / Quality

- Per-element byte conversion in `get_f64`/`set_f64` is a bottleneck for large arrays. Consider typed inner loops or SIMD for contiguous f32/f64 sections.
- `convolve2d` is a naive O(N×K) loop — could use FFT-based convolution for large kernels via the existing `fft` module.
- `dilate`/`erode` are O(N×R²) — separable passes would be O(N×R).
- `PAR_THRESHOLD` is hardcoded at 10,000 — should be tunable or auto-calibrated.
- Rayon is already integrated in `ops.rs` (resolving the previously deferred parallel ops item).

## Test Gaps

- No test for `NdArray::from_slice` with shape mismatch (error path).
- No test for `NdArray::range` with zero step (error path).
- No test for `eigenvalue_power` convergence on a known 3×3 matrix.
- No test for `lu_decompose` on a singular matrix.
- No test for `histogram` with out-of-range values.
- No test for `convolve2d` with non-square kernels.
- `ops.rs` missing tests for `lte`, `lte_scalar`, `gte`, `gte_scalar`, `neq`, `neq_scalar`, `eq_scalar`.
- No test for `bitwise_lshift` and `bitwise_rshift`.

## TODO(dedup)

- `elementwise_binary`, `elementwise_unary`, `elementwise_scalar` in `ops.rs` share nearly identical parallel/serial dispatch logic. Extract a generic `dispatch_parallel(size, threshold, op)` helper.
- `convolve2d` (spatial.rs) and `sobel` (linalg.rs) both implement 2D kernel sliding. `sobel` could delegate to `convolve2d`.

## TODO(helper)

- Add `NdArray::fill(val)` as a method (currently only `ops::fill` free function).
- Add `NdArray::map(f: fn(f64) -> f64) -> NdArray` for custom element-wise transforms.
- Add `NdArray::iter_f64() -> impl Iterator<Item = f64>` for ergonomic iteration.

## TODO(plugin)

- Compute is already flagged as a plugin candidate in `docs/specs/compute.md`. Confirm as TIER-1-PLUGIN — games not using numerical arrays shouldn't pay the Rayon dependency cost. Gate behind a `compute` Cargo feature flag.

## References

- `src/lua_api/compute_api.rs` — Lua bridge
- `docs/specs/compute.md` — module spec
- `docs/architecture/plugins.md` — plugin candidacy
