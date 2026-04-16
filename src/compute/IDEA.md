# IDEA.md — `compute` module

> Migrated from `ideas/features/compute.md` and `ideas/performance/04-compute-threading.md`.
> Status checked against `src/compute/` and `src/lua_api/compute_api.rs`.
> Lua namespace: `lurek.compute`.

---

## Features

### ⚠️ STUB — GPU Compute
**Source**: features/compute.md — Feature Gaps #1

`isOnGPU()` returns `false` (line ~133 in `compute_api.rs`). The GPU compute path is not
implemented. All operations are CPU-only. Mark as a future roadmap item and ensure docs and
the `isOnGPU()` stub don't mislead users.

---

### ❌ DEFERRED — Sparse Array Support
**Source**: features/compute.md — Feature Gaps #2

Complex implementation. Deferred.

---

### ❌ DEFERRED — Integer Array Type
**Source**: features/compute.md — Feature Gaps #6

Deferred. NdArray stays f64-only for now.

---

### ❌ DEFERRED — ImageData Interop
**Source**: features/compute.md — Feature Gaps #7 / Suggestions #4

Needs image module alignment. Deferred.

---

### 🤔 CONSIDER — Rename Module / Namespace
**Source**: features/compute.md — Structural Issues

The name `compute` implies GPU compute. The module is actually a CPU NdArray implementation.
Consider renaming the Lua namespace to `lurek.ndarray` or merging with `lurek.data`.
This is a **breaking API change** requiring MAJOR version bump and Lua-Designer sign-off.

---

## Performance

### ❌ DEFERRED — Parallel Array Operations (rayon)
**Source**: performance/04-compute-threading.md

No rayon in `ops.rs` yet. Deferred until profiling confirms a bottleneck.
