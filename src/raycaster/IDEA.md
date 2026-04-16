# IDEA.md — `raycaster` module

> Migrated from `ideas/features/raycaster.md`.
> Status checked against `src/raycaster/` and `src/lua_api/raycaster_api.rs`.
> Lua namespace: `lurek.raycaster`.

> **NOTE**: The feature analysis file (written before this audit) listed DoorManager,
> HeightMap, and PointLight as "Rust-only not exposed to Lua". That was incorrect — all
> three are fully Lua-exposed as of the current codebase. Marked ✅ below.

---

## Features

### ❌ TODO — Document Rust-Internal Types
**Source**: features/raycaster.md — Structural Issues

`ColumnBatch`, `Segment`, and `DepthBuffer` exist as Rust types but appear to have no
Lua binding. Either expose them or explicitly document them as "Rust internals."

---

## Performance

### 🔇 LOW — Performance optimizations not meaningfully relevant
DDA raycaster is already near-optimal for 2D grid traversal. The bottleneck for retro-FPS
is GPU draw call count for wall columns and sprite batching, not the DDA logic itself.
Optimize GPU slice submission before revisiting raycaster Rust code.
