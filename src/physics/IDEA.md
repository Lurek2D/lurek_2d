# IDEA — `src/physics/`

> **This file is forward-looking.** It records ideas, not commitments. Nothing here is
> implemented in the same session that produces it. Implementation is gated by a separate
> roadmap decision.
>
> See [IDEA_AUTHORING.md](../../work/src-module-review-20260418/reports/IDEA_AUTHORING.md) for filling instructions.

---

## 1. Header

- **Module**: `physics`
- **Owner module path**: `src/physics/`
- **Last reviewed**: 2026-04-18 (UTC)
- **Reviewer agent**: `developer` · Session: `src-module-review-20260418`
- **Plugin tier candidacy**: `CORE-KEEP`
- **LOC (rust only)**: ~5490 · **Public Lua surface**: `lurek.physics` — ~60 fns / 4 userdata (World, Body, TerrainMap, CellularWorld)
- **Inbound non-`lua_api` callers**: `src/engine/app.rs`, `src/engine/shared_state.rs`
- **Heavy dependencies**: `rapier2d 0.32`

## 2. Mission Summary

The physics module provides 2D rigid-body dynamics, collision detection, terrain destruction,
cellular automata (falling-sand), and zone-based gravity via rapier2d 0.32. It serves EngDev
(World/Body internals), GameDev (Lua scripting of bodies, joints, terrain), and GameTest
(collision validation). It is NOT a 3D physics engine and does NOT include fluid dynamics.

## 3. Existing Strengths

- Comprehensive rapier2d integration: rigid bodies, sensors, joints, raycasts, shape casts, contact queries all exposed via `World`.
- Destructible terrain (`TerrainMap`) with bitgrid storage, chunked collider rebuild, and serialization.
- Cellular automata (`CellularWorld`) with falling-sand physics, configurable materials, and image export.
- Zone-based gravity system with directional, point, repulsor, and zero-gravity modes plus enter/leave events.
- Pure-function collision helpers (`collision_helpers.rs`) for AABB, circle, point tests — no rapier dependency.
- Clean shape abstraction (`shape.rs`) mapping engine shapes to rapier colliders via `to_rapier_collider`.

## 4. Gap List

1. **[P1][GAP]** `Buoyancy / fluid forces` — no native fluid simulation or buoyancy force application.
   - Why: water/lava levels require manual per-frame upward force hacks.
2. **[P1][GAP]** `One-way platforms` — no built-in one-way collision filter in World.
   - Why: platformers need pass-through-from-below platforms; currently requires manual contact filtering.
3. **[P2][GAP]** `Collision event batching` — contacts are processed per-step with HashMap allocation.
   - Why: high body counts cause per-frame allocation pressure in `World::step`.
4. **[P2][GAP]** `Physics step threading` — `World::step` runs on the main thread.
   - Why: 500+ body simulations consume significant frame budget.
5. **[P3][GAP]** `Terrain chunk damage notifications` — `TerrainMap` rebuilds all dirty chunks silently.
   - Why: game scripts cannot react to terrain damage events per-chunk.

## 5. Feature Ideas

1. **[P1][FEAT]** `One-way platform filter` — add a `one_way` flag to `Body` that allows upward passage but blocks downward collision, implemented via rapier's contact modification hooks.
   - Rationale: unlocks classic platformer mechanics (GameDev persona).
   - Effort: M · Risk: low.
2. **[P2][FEAT]** `Physics step on background thread` — double-buffer World state, run rapier step on a rayon thread, swap on completion.
   - Rationale: heavy simulations stay at 60 FPS on integrated GPUs (B-03).
   - Effort: L · Risk: med (synchronization complexity).
3. **[P2][FEAT]** `Buoyancy zone` — add a `ZoneGravityMode::Buoyancy` variant that applies per-body upward force proportional to submerged fraction.
   - Rationale: fluid-like gameplay without full fluid sim.
   - Effort: M · Risk: low.
4. **[P3][FEAT]** `Terrain damage events` — emit `TerrainDamageEvent` with chunk coordinates and bitmask delta when `rebuild_dirty_chunks` runs.
   - Rationale: game scripts can react to explosions destroying terrain.
   - Effort: S · Risk: low.

## 6. Performance / Reliability / Quality Ideas

- **[P1][PERF]** `Pre-allocate contact buffers` — replace per-step HashMap in `World::step` with a reusable Vec drain pattern.
  - Hot path: `world.rs:step()` contact iteration.
  - Verification: `RUST_LOG=lurek::physics=trace` frame-time before/after.
- **[P2][QUAL]** `Split world.rs` — at ~2600 lines, `world.rs` is the largest file. Extract joint management and query methods into `joints.rs` and `queries.rs`.
  - File: `src/physics/world.rs`.
  - Reason: readability, merge conflicts, navigation.
- **[P2][REL]** `Graceful rapier panic recovery` — wrap rapier step in `catch_unwind` to prevent engine crash on degenerate body configurations.
  - Files: `world.rs`.
  - Suggested fix: log error, skip step, return `EngineError`.

## 7. Test Coverage Gaps

- **[P1][TEST-RUST]** Add Rust unit tests for `World::add_body`, `remove_body`, `step`, `raycast` (non-Lua internals).
- **[P1][TEST-LUA]** Add Lua BDD tests for `lurek.physics.newWorld`, body creation, joint creation, collision callbacks.
- **[P2][TEST-RUST]** Add tests for `TerrainMap::rebuild_dirty_chunks` collider output.
- **[P2][TEST-LUA]** Add Lua tests for `CellularWorld` step + serialization roundtrip.
- **[P3][TEST-FUZZ]** Fuzz target: `Shape::from_parts` with random type/dimension inputs.

## 8. TODO(dedup): Cross-Module Overlap

```text
TODO(dedup): math::Vec2 — collision_helpers.rs re-implements point/AABB math that could use math::Vec2 directly
TODO(dedup): render::RenderCommand — physics/render.rs builds RenderCommands; shared debug-draw trait candidate
```

## 9. TODO(helper): Engine-Level Helper Candidates

```text
TODO(helper): one_way_platform — manual contact filter pattern repeated in platformer demos — citation: content/library/platformer/init.lua
TODO(helper): terrain_explosion — circle-fill + rebuild pattern used in destructible-terrain demos — citation: content/examples/terrain.lua
```

## 10. TODO(plugin): Plugin Candidacy Proposal

```text
TODO(plugin): CORE-KEEP — physics is fundamental to 2D games; rapier2d is the sole dynamics backend; extraction would break body/joint/collision API surface used by >50% of demos
```

- **Extraction blockers**: `runtime::shared_state` pool entry for `PhysicsWorld`, inbound imports from `app.rs`.
- **Heavy dep impact if extracted**: rapier2d ~2 MB; would save binary size if extracted, but too central.
- **Lua surface stability**: evolving.
- **Migration step**: n/a.

## 11. References

- Module spec: [docs/specs/physics.md](../../docs/specs/physics.md)
- Lua API reference: [docs/API/lua-api.md#physics](../../docs/API/lua-api.md)
- Philosophy constraints touched: `A-03` (2D only), `B-03` (60 FPS target), `B-04` (concurrency)
- Plugin doc tier table: [plugins.md §5](../../docs/architecture/plugins.md#5-candidate-modules)
- Authoring guide: [IDEA_AUTHORING.md](../../work/src-module-review-20260418/reports/IDEA_AUTHORING.md)
- Session plan: [PLAN.md](../../work/src-module-review-20260418/reports/PLAN.md) · Session decisions: [DECISIONS.md](../../work/src-module-review-20260418/reports/DECISIONS.md)
