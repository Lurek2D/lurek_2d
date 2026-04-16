# IDEA.md — `math` module

> Migrated from `ideas/features/math.md` and `ideas/performance/13-math-simd-noise.md`.
> Status checked against `src/math/` and `src/lua_api/math_api.rs`.
> Lua namespace: `lurek.math`.

---

## Features

### ⚠️ FIXME — Remove `log_messages` Dependency from `SpatialHash`
**Source**: features/math.md — Structural Issues

`src/math/spatial_hash.rs` imports `crate::engine::log_messages` (or similar), breaking the
leaf-module invariant. Either remove the log call or gate it behind a cfg feature. Math must
remain a zero-dependency leaf so all other modules can safely import it.

---

## Performance

### 🔇 LOW — SIMD Noise Acceleration
**Source**: performance/13-math-simd-noise.md

Perlin noise generation is scalar. SIMD (via `std::simd` or `packed_simd2`) could speed up
batch noise generation (terrain gen, per-pixel effects). Priority: **LOW** — only relevant
for large procedural maps. Profile before investing here.
