# IDEA.md — `particle` module

> Migrated from `ideas/features/particle.md` and `ideas/performance/03-particle-audio.md` (particle section).
> Status checked against `src/particle/` and `src/lua_api/particle_api.rs`.
> Lua namespace: `lurek.particles`.

---

## Features

### ❌ TODO — Particle Collision with Physics
**Source**: features/particle.md — Feature Gaps #6

No `setCollidesWithPhysics(world)` found. Particles can't bounce off physics bodies.
This is an advanced feature but critical for sand-simulation and satisfying
platformer juice (blood drops hitting floors).

---

### 🤔 CONSIDER — GPU Particle System
**Source**: features/particle.md — Feature Gaps #8 / performance/03-particle-audio.md

CPU-side particle update limits maximum live particle count (~50k on a modern CPU).
A GPU compute–backed emitter using wgpu compute shaders could handle millions. This is
a large engineering effort. Document capability ceiling and recommend GPU particles only
when the CPU ceiling is hit in profiling.

---

## Performance

### ❌ TODO — Parallel Particle Update (rayon)
**Source**: performance/03-particle-audio.md — Particle section

Particle integration (position, lifetime, color curves) is fully data-parallel. No rayon
found in `src/particle/emitter.rs`. Priority: **MEDIUM** (useful at ~5k+ live particles).
