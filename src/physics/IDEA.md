# IDEA.md — `physics` module

> Migrated from `ideas/features/physics.md` and `ideas/performance/01-physics-threading.md`.
> Status checked against `src/physics/` and `src/lua_api/physics_api.rs`.
> Lua namespace: `lurek.physics`. Backed by rapier2d 0.32.

---

## Features

### 🔇 LOW — Buoyancy Forces
**Source**: features/physics.md — Feature Gaps #8

No fluid buoyancy. Can be simulated manually with per-frame upward forces proportional to
submerged area. Document as a pattern in examples rather than building native support.

---

## Performance

### ❌ TODO — Physics Step on Separate Thread
**Source**: performance/01-physics-threading.md

PhysicsWorld::step() runs on the main thread every frame. For worlds with 500+ bodies
this consumes significant frame budget. The step could run on a dedicated rayon thread pool
with double-buffered state. Rapier2d supports this pattern. Priority: **MEDIUM** for
simulation-heavy games, **LOW** for typical arcade/platformer loads.
