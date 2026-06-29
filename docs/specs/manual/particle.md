# particle manual spec overlay

## TL;DR

- Simulates pooled particles with rich shapes, gravity forces, and collider bounces.
- Supports keyframe curves, tapered ribbon trails, sub-emitters, and diagnostic images.

## Summary

- The `particle` module is the pooled visual-effects system for users who want smoke, sparks, rain, trails, bursts, and other transient visuals to behave like one reusable runtime feature.
- Emitters, particle state, force application, lifetimes, presets, trails, and render bridges all live together here, so effects can be authored as configurations instead of one-off update loops.
- Pooling is central to the design because short-lived effects appear in large numbers and need predictable reuse instead of constant allocation churn.
- Emission rules, spawn shapes, attractors, turbulence, and per-particle lifetime state give the module enough range to cover both ambient effects and gameplay feedback.
- Per-particle state is not only position and color. Lifetime, velocity, size evolution, rotation, and other update-time values determine how an effect feels over time and are part of the same runtime model.
- Sub-emitters, trails, and simple collision hooks matter because many practical effects need layered motion and lightweight grounding in world space.
- Force handling is especially important because many effects are really motion systems: wind, gravity-like influence, turbulence, and attractors all shape how a burst reads to the player.
- Spawn-shape variety matters too, since emitters often need circles, lines, cones, boxes, or directional releases rather than a single point source.
- Presets and visualization support make the system useful for iteration, docs, tests, and content authoring as well as for final shipped visuals.
- The same pooled model also keeps high-volume effects legible for debugging, because emitters, lifetimes, and force rules remain inspectable instead of dissolving into ad hoc update code.
- The module is useful for combat hits, weather, ambience, UI flourishes, projectiles, and other procedural or semi-procedural effect workflows.
- `render` draws the result and `physics` may inform light collision behavior, but `particle` owns effect spawning, pooled update logic, and transient visual behavior over time.
- Read `particle` as the subsystem that decides how short-lived procedural effects are described, updated, reused, and inspected.

This module primarily collaborates with `color`, `image`, `math`, `physics`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Notes

- Safety contract:
  Particle configs normalize permissively through legacy constructors, but strict callers use explicit `ParticleLimits` and reject oversized pools, nested death-emitter depth overflows, excessive keyframes/quads, and oversized TOML payloads.
- Determinism contract:
  Explicit `seed` values opt the emitter into deterministic replay under `ParticleRngVersion::V1`; omitted seeds are treated as nondeterministic and are reported through config/runtime diagnostics.
- Runtime budgets:
  Emitters cap direct pool size, total live particles, per-update sub-emitter spawns, recycled child-system retention, attractor count, and render instances per frame; dropped child spawns and render over-budget events are surfaced through `getStats`.
- File-backed tooling contract:
  `lurek.particle.newSystem(config)` accepts both the historical Lua-style camelCase option keys and the canonical snake_case TOML keys used by `lurek.serialize.fromToml`, so editors and content tools can preview parsed particle documents without field-by-field remapping.
- Custom emission callback contract:
  Deferred Lua custom-shape callbacks target stable particle ids instead of raw pool indices, so `bottom` and `random` insert modes cannot retarget pending offsets after later inserts. Failed callbacks leave the particle's existing spawn offset unchanged.
- Render and collision policy:
  Invalid sprite-sheet quads are removed during config normalization, render extraction skips non-finite or invisible instances, and bounds/attractor strict setters reject non-finite coordinates instead of propagating NaNs into the update loop.
- Shader render policy:
  `LParticleSystem:setShader(shader)` binds a `target = "particle"` WGSL fragment shader to rendering only. CPU simulation, deterministic seeds, collisions, and sub-emitter behavior remain unchanged. The renderer forwards color, uv, local/world position, velocity, normalized age, lifetime, seed, and sampled texture color; textured particles stay on the particle shader path instead of being expanded into ordinary image draws.
- GPU path:
  The current production simulation is CPU-owned and renderer-facing through particle snapshots. A GPU particle path should keep emitter authoring and policy in `particle`, but place storage buffers, compute dispatch, and instanced drawing in `render`; gameplay-critical physics/custom callbacks stay on the CPU path unless a bounded hybrid bridge is explicitly added.
- Ordering policy:
  World-space particles participate in normal scene/tilemap/camera ordering. Screen-space weather on the visible camera belongs to `overlay`; particles that must pass behind isometric walls or collide with blocks need a world-space particle/tilemap integration path.

## Architecture Links

- `docs/architecture/module-scope-boundaries.md`
- `docs/architecture/effects-particles-overlay-plan.md`
