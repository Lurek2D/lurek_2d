# IDEA — `src/tween/`

> **This file is forward-looking.** It records ideas, not commitments. Nothing here is
> implemented in the same session that produces it. Implementation is gated by a separate
> roadmap decision.

---

## 1. Header

- **Module**: `tween`
- **Owner module path**: `src/tween/`
- **Last reviewed**: 2026-04-18 (UTC)
- **Reviewer agent**: `developer` · Session: `src-module-review-20260418`
- **Plugin tier candidacy**: `CORE-KEEP`
- **LOC (rust only)**: ~1407 · **Public Lua surface**: `lurek.tween` — ~12 fns / 4 userdata
- **Inbound non-`lua_api` callers**: none (all access via `lurek.tween.*` Lua API)
- **Heavy dependencies**: `mlua` (engine.rs, handle.rs hold LuaRegistryKey)

## 2. Mission Summary

The tween module provides property interpolation for Lua table fields: smooth transitions of position, scale, alpha, color, or any numeric value over time using configurable easing curves. It serves GameDev (fluent tween API for UI and gameplay animation) and Modder (custom easing registration). It deliberately does NOT own frame-based sprite animation (that belongs to `animation`) or physics-based motion (that belongs to `physics`). Springs (`spring.rs`) provide oscillatory behaviour distinct from fixed-duration tweens.

## 3. Existing Strengths

- `TweenState` is pure Rust — no Lua dependency, fully testable in isolation with deterministic timing.
- Comprehensive easing library: 22 built-in easings resolved by name with case-insensitive matching.
- `LuaTweenSequence` correctly carries surplus dt across step boundaries, so short steps in a large dt are never skipped.
- `LuaTweenParallel` provides fire-and-forget concurrent tweening with a single `on_complete`.
- `SpringSystem` supports named multi-axis springs with shared stiffness/damping parameters.
- `TweenEngine::update` uses take-and-replace pattern to avoid holding `RefCell` borrow across Lua callbacks — correct by construction.
- Custom easing registration lets Lua scripts define `fn(t) -> t` easings at runtime.

## 4. Gap List

1. **[P2][GAP]** `Coroutine yield in sequence` — No way to `yield` a Lua coroutine until a tween/sequence completes.
   - Why: Game scripts using coroutine-based state machines must poll tween status manually.
2. **[P2][GAP]** `Relative tweens` — All tweens are absolute (start → end). No built-in "add 50 to current x" relative mode.
   - Why: Relative tweens simplify stacking (e.g. knockback + walk simultaneously).
3. **[P3][GAP]** `Tween introspection` — No way to query a running tween's progress, remaining time, or active field list from Lua.
   - Why: Debug UI and HUD code cannot display tween status.

## 5. Feature Ideas

1. **[P2][FEAT]** `Relative Tween Mode` — Add `:relative()` modifier to `LuaTween` that treats `end_values` as deltas from captured start values.
   - Rationale: Enables stackable, composable property animations (GameDev, Modder).
   - Effort: S · Risk: low (additive flag in `tick_with`).
   - Competitor inspiration: `[LÖVE2D: flux relative mode — https://github.com/rxi/flux]`, `[Godot: Tween.tween_property with relative delta — https://docs.godotengine.org/en/stable/classes/class_tween.html]`.
2. **[P2][FEAT]** `Coroutine Yield on Completion` — Add `lurek.tween.await(tween_handle)` that yields the calling coroutine until the tween finishes, returning elapsed time.
   - Rationale: Natural scripting for cutscenes and sequential game logic (GameDev).
   - Effort: M · Risk: med (needs coroutine scheduler integration with timer module).
   - Competitor inspiration: `[Defold: go.animate with coroutine support — https://defold.com/manuals/animation/]`.
3. **[P3][FEAT]** `Tween Progress Query` — Add `:getProgress()`, `:getElapsed()`, `:getFields()` to `LuaTween` for runtime introspection.
   - Rationale: Enables debug HUDs and conditional logic based on tween state.
   - Effort: S · Risk: low.

## 6. Performance / Reliability / Quality Ideas

- **[P1][PERF]** `Avoid per-tick registry lookups for target table` — `LuaTween::tick_with` calls `lua.registry_value(&self.target_key)` every frame. Cache the table reference across ticks when the GC is not collecting.
  - Hot path: `handle.rs:tick_with` (line ~165).
  - Verification: criterion bench with 200 concurrent tweens at 60 fps.
- **[P2][REL]** `Graceful handling of deleted target tables` — If the target Lua table is garbage-collected mid-tween (e.g. entity despawned), `tick_with` returns a registry error. Add explicit `is_valid` check and auto-cancel.
  - Files: `handle.rs`.
  - Suggested fix: Catch the registry error, mark tween inactive, fire `on_cancel`.
- **[P3][QUAL]** `engine.rs and handle.rs mlua dependency` — These files depend on `mlua` for `LuaRegistryKey`. This is by design (domain types need registry lifetimes), but document the rationale more clearly.
  - File: `engine.rs`, `handle.rs`.
  - Reason: Clarify that this is NOT a thin-wrapper violation.

## 7. Test Coverage Gaps

- **[P1][TEST-RUST]** Add Rust tests for `TweenState` edge cases: zero duration, negative dt, pause during tick.
- **[P2][TEST-LUA]** Add Lua BDD test for `lurek.tween.sequence` step transitions under `tests/lua/tween/`.
- **[P2][TEST-LUA]** Add Lua BDD test for `lurek.tween.spring` settlement behaviour.
- **[P2][TEST-LUA]** Add Lua BDD test for custom easing via `lurek.tween.registerEasing`.
- **[P3][TEST-FUZZ]** Fuzz target: `resolve_easing` with random strings (low priority — bounded domain).

## 8. TODO(dedup): Cross-Module Overlap

```text
TODO(dedup): animation::curve::AnimCurve — tween::state::TweenState both provide time-based interpolation with easing; AnimCurve uses keyframes while TweenState uses start→end. Clarify ownership: curve = multi-keyframe procedural, tween = two-point property animation.
TODO(dedup): animation::controller::Animation — tween could theoretically animate sprite source quads via table fields, overlapping with animation clip playback. Document the boundary: tween = numeric properties, animation = frame indices.
```

## 9. TODO(helper): Engine-Level Helper Candidates

```text
TODO(helper): tween_chain — Lua helper for named, reusable multi-step animation scripts (slide-in + bounce + fade) — citation: content/library/ui/transitions.lua
TODO(helper): tween_color — Lua helper for tweening Color userdata (r,g,b,a as a unit) — citation: content/examples/tween.lua
```

## 10. TODO(plugin): Plugin Candidacy Proposal

```text
TODO(plugin): CORE-KEEP — property tweening is fundamental to UI animation, gameplay feedback, and camera motion in every 2D game. No extraction benefit.
```

- **Extraction blockers**: `TweenEngine` stored in `SharedState` via `Rc<RefCell>`; `LuaTween`/`LuaTweenSequence`/`LuaTweenParallel` hold `LuaRegistryKey` handles that require the Lua VM.
- **Heavy dep impact if extracted**: n/a.
- **Lua surface stability**: stable.
- **Migration step**: n/a.

## 11. References

- Module spec: [docs/specs/tween.md](../../../docs/specs/tween.md)
- Lua API reference: [docs/API/lua-api.md#tween](../../../docs/API/lua-api.md)
- Philosophy constraints touched: `B-01` (LuaJIT primary), `B-03` (60 FPS target)
- Plugin doc tier table: [plugins.md §5](../../../docs/architecture/plugins.md#5-candidate-modules)
- Competitor links cited above: LÖVE2D flux, Godot Tween, Defold go.animate
- Authoring guide: [IDEA_AUTHORING.md](../../work/src-module-review-20260418/reports/IDEA_AUTHORING.md)
- Session plan: [PLAN.md](../../work/src-module-review-20260418/reports/PLAN.md)
