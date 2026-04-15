# IDEA.md — `particle` module

> Migrated from `ideas/features/particle.md` and `ideas/performance/03-particle-audio.md` (particle section).
> Status checked against `src/particle/` and `src/lua_api/particle_api.rs`.
> Lua namespace: `lurek.particles`.

---

## Features

### ✅ DONE — Trail Ribbons
**Source**: features/particle.md — Feature Gaps #4 / Suggestions #3

`Trail` and `LuaTrail` implemented in `particle_api.rs` (line ~1186). Exposed via
`lurek.particles.newTrail()`.

---

### ✅ DONE — Attractors / Repellers
**Source**: features/particle.md — Feature Gaps #3 / Suggestions #4

`addAttractor(x, y, strength, radius)` implemented in `particle_api.rs` (line ~1115).
Negative `strength` acts as a repeller.

---

### ✅ DONE — Warm-Up (Pre-Simulate)
**Source**: features/particle.md — Suggestions #5

`warmUp(seconds)` implemented in `particle_api.rs` (line ~1097). Pre-simulates N seconds
so emitter starts full.

---

### ✅ DONE — Sub-Emitters
**Source**: features/particle.md — Feature Gaps #2 / Suggestions #2

`addSubEmitter(config_tbl, burst_count?)` added to `particle_api.rs`. The underlying
`death_emitter` / `death_burst_count` / `sub_systems` infrastructure already existed in
`emitter.rs` and `config.rs`; the Lua binding was the only missing piece. Also added
`deathEmitter` key parsing to `ParticleConfig::from_lua_opts`.

---

### ✅ DONE — Flipbook Texture Animation
**Source**: features/particle.md — Feature Gaps #1 / Suggestions #1

`setFlipbook(cols, rows, fps)` and `getFlipbook()` added to `particle_api.rs`. The method
auto-computes `cols × rows` UV quads from a normalised [0,1] grid and sets `animated_frames`
and `frame_rate` on the config. The underlying `quads` cycling in `emitter.rs` already worked.

---

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
