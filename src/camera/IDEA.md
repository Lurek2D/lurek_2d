# IDEA — `src/camera/`

> **This file is forward-looking.** It records ideas, not commitments. Nothing here is
> implemented in the same session that produces it. Implementation is gated by a separate
> roadmap decision.

---

## 1. Header

- **Module**: `camera`
- **Owner module path**: `src/camera/`
- **Last reviewed**: 2026-04-18 (UTC)
- **Reviewer agent**: `developer` · Session: `src-module-review-20260418`
- **Plugin tier candidacy** (per [plugins.md §5](../../../docs/architecture/plugins.md#5-candidate-modules)):
  `CORE-KEEP`
- **LOC (rust only)**: `2136` · **Public Lua surface**: `lurek.camera` — `1` fn / `1` userdata (Camera2D)
- **Inbound non-`lua_api` callers**: `src/render/` (RenderCommand generation), `src/app/` (SharedState Camera field)
- **Heavy dependencies**: `crate::math` (Vec2, Mat3, Rect), `crate::render` (RenderCommand — render.rs only)

## 2. Mission Summary

The camera module provides 2D camera transforms and viewport scaling for Lurek2D. It serves
GameDev (smooth-follow player cameras, screen shake, cinematic paths), EngDev (view-matrix
integration with the render pipeline), and Modder (custom camera behaviours via the Lua API).
It is deliberately NOT a 3D camera, a scene graph, or a render pass manager — it produces
`Mat3` transforms and `RenderCommand` lists that the renderer consumes.

## 3. Existing Strengths

- Full `Camera2D` with follow, dead zone, look-ahead, bounds clamping, and deterministic shake — covers the core 2D platformer/RPG camera patterns.
- Cinematic effect system (`ZoomPulse`, `CameraSway`, `CameraBreathing`) with `effective_zoom()` and `effect_offset()` compositing — clean separation from base transform.
- `Viewport` / `ViewportScale` with letterbox, stretch, and pixel-perfect modes — essential for resolution independence.
- Coordinate conversion (`to_world_coords`, `to_screen_coords`, `to_game`, `to_screen`) available on both camera and viewport types.
- Clean render-command generation (`begin_render_commands` / `end_render_command`) keeps GPU knowledge in `render.rs` only.
- Comprehensive existing tests in `types.rs`, `effects.rs`, `render.rs`, and `viewport.rs`.

## 4. Gap List

1. **[P1][GAP]** `Camera constraints` — no zoom min/max, no velocity damping, no rotation limits.
   - Why: game authors must manually clamp zoom in Lua every frame; easy to forget.
2. **[P2][GAP]** `Multi-camera support` — SharedState holds a single Camera; split-screen or PIP requires manual switching.
   - Why: racing games, local co-op, and minimap cameras all need concurrent viewports.
3. **[P2][GAP]** `Effective zoom not used in render commands` — `begin_render_commands` uses `self.zoom`, not `effective_zoom()`, so effects don't appear in the rendered output unless the Lua script manually applies them.
   - Why: cinematic effects (zoom pulse, breathing) are computed but silently ignored by the default render path.
4. **[P3][GAP]** `Screen-shake duplication` — shake exists in both `camera` (Camera2D) and the `effect`/fx overlay system.
   - Why: two independent shake systems is confusing; game authors can trigger both and get doubled shake.

## 5. Feature Ideas

1. **[P1][FEAT]** `Camera constraints (zoom limits, rotation clamp)` — add optional `zoom_min/zoom_max` and `rotation_min/rotation_max` fields on Camera2D; clamp in `update()`.
   - Rationale: eliminates the most common Lua boilerplate (manual zoom clamping) and prevents accidental negative-zoom bugs.
   - Effort: S · Risk: low.
   - Competitor inspiration: LÖVE community library gamera provides zoom_min/zoom_max — https://github.com/kikito/gamera
2. **[P2][FEAT]** `Multi-camera / split-screen` — allow multiple named Camera2D instances, each bound to a viewport region, with the renderer iterating all active cameras per frame.
   - Rationale: unlocks split-screen co-op and PIP minimap use cases without manual render-command splicing.
   - Effort: L · Risk: med (render-pass restructuring).
   - Competitor inspiration: Godot Camera2D supports multiple cameras with `make_current()` — https://docs.godotengine.org/en/stable/classes/class_camera2d.html
3. **[P2][FEAT]** `Easing functions for follow and zoom` — replace linear lerp in follow and ZoomTween with configurable easing (ease-in-out, cubic, etc.) by integrating with the tween module.
   - Rationale: linear follow feels robotic; eased follow is standard in modern 2D games.
   - Effort: S · Risk: low.
   - Competitor inspiration: Solar2D transition library supports easing on all properties — https://docs.coronalabs.com/api/library/transition/

## 6. Performance / Reliability / Quality Ideas

- **[P2][QUAL]** `Use effective_zoom in render commands` — `Camera2D::begin_render_commands` should use `effective_zoom()` and add `effect_offset()` to the translate, so cinematic effects are visible by default without Lua workarounds.
  - File / type: `render.rs:70-100`.
  - Reason: current API computes effects that are silently dropped in the default render path.
- **[P3][PERF]** `Avoid Vec allocation in begin_render_commands` — returns `Vec<RenderCommand>` every frame; consider a fixed-size `ArrayVec<RenderCommand, 5>` or write directly into a caller-provided buffer.
  - Hot path: `render.rs:15-40`.
  - Verification: criterion bench with per-frame camera command generation.
- **[P3][QUAL]** `Consolidate Viewport and ViewportScale` — the two types have near-identical resize logic with only `scaled_width/scaled_height` as the difference; consider merging into one type with an optional flag.
  - File / type: `viewport.rs` + `viewport_scale.rs`.
  - Reason: reduces maintenance burden and API surface duplication.

## 7. Test Coverage Gaps

- **[P1][TEST-RUST]** Added inline Rust unit tests for `path.rs` and `viewport_scale.rs` (this session).
- **[P2][TEST-LUA]** Add Lua BDD test for `Camera2D:followPath` + `Camera2D:updatePath` under `tests/lua/unit/test_camera.lua`.
- **[P2][TEST-LUA]** Add Lua test for `Camera2D:zoomPulse` / `Camera2D:startBreathing` effect integration.
- **[P2][TEST-RUST]** Add Rust test for `Camera2D::effective_zoom` combining zoom_pulse + breathing deltas.
- **[P3][TEST-FUZZ]** Fuzz target candidate: `Camera2D::update` with extreme dt / position / zoom values.

## 8. TODO(dedup): Cross-Module Overlap

```text
TODO(dedup): effect::screen_shake — camera has its own shake system (Camera2D.shake_*); the effect/fx module also provides screen shake. Consolidate to one canonical shake location (camera is the natural home).
TODO(dedup): tween::ZoomTween — camera/path.rs has ZoomTween; the tween module has generic property tweening. Consider making ZoomTween delegate to tween or removing camera's custom tween once tween module supports camera properties natively.
TODO(dedup): viewport↔viewport_scale — near-identical resize logic duplicated between Viewport and ViewportScale.
```

## 9. TODO(helper): Engine-Level Helper Candidates

```text
TODO(helper): camera_follow_config — game authors repeatedly set follow_smooth + dead_zone + look_ahead as a group for common camera styles (platformer, top-down, cinematic); a preset helper in content/library/ would reduce boilerplate
TODO(helper): viewport_setup — game authors manually call viewport:resize in lurek.resize callback; a library helper that auto-wires viewport resize to the window resize event would eliminate this boilerplate
```

## 10. TODO(plugin): Plugin Candidacy Proposal

```text
TODO(plugin): CORE-KEEP — camera is fundamental to 2D rendering: SharedState holds a Camera field, the render pipeline consumes camera-generated RenderCommands, and every game needs viewport scaling. Extraction would break the core render loop. Keep as core.
```

- **Extraction blockers**: `SharedState` holds `Camera` field directly; `render.rs` imports `crate::render::renderer::RenderCommand`; all games depend on viewport scaling.
- **Heavy dep impact if extracted**: n/a (core module).
- **Lua surface stability**: stable.
- **Migration step**: n/a (CORE-KEEP).

## 11. References

- Module spec: [docs/specs/camera.md](../../../docs/specs/camera.md)
- Lua API reference: [docs/API/lua-api.md#camera](../../../docs/API/lua-api.md)
- Philosophy constraints touched: `A-03` (2D graphics only), `B-02` (wgpu renderer — camera feeds RenderCommands to it), `B-03` (60 FPS target — camera update is per-frame hot path)
- Plugin doc tier table: [plugins.md §5](../../../docs/architecture/plugins.md#5-candidate-modules)
- Competitor links cited above: gamera (LÖVE), Godot Camera2D, Solar2D transition
- Authoring guide: [IDEA_AUTHORING.md](../../work/src-module-review-20260418/reports/IDEA_AUTHORING.md)
- Session plan: [PLAN.md](../../work/src-module-review-20260418/reports/PLAN.md) · Session decisions: [DECISIONS.md](../../work/src-module-review-20260418/reports/DECISIONS.md)
# IDEA.md — `camera` module

> Migrated from `ideas/features/camera.md`.
> Status checked against `src/camera/` and `src/lua_api/camera_api.rs`.

---

## Features

### 🤔 CONSIDER — Consolidate Screen Shake
**Source**: features/camera.md — Structural Issues

Screen shake is implemented in both the `camera` module and the `effect`/`fx` overlay system.
Two independent shake systems is confusing. Pick one canonical location — camera shake is
the more natural home — and deprecate the other.
