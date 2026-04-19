# IDEA — `src/animation/`

> **This file is forward-looking.** It records ideas, not commitments. Nothing here is
> implemented in the same session that produces it. Implementation is gated by a separate
> roadmap decision.

---

## 1. Header

- **Module**: `animation`
- **Owner module path**: `src/animation/`
- **Last reviewed**: 2026-04-18 (UTC)
- **Reviewer agent**: `developer` · Session: `src-module-review-20260418`
- **Plugin tier candidacy**: `CORE-KEEP`
- **LOC (rust only)**: ~2503 · **Public Lua surface**: `lurek.animation` — ~30 fns / 6 userdata
- **Inbound non-`lua_api` callers**: `src/render/` (via AnimRenderParams), `src/spine/` (potential bridge)
- **Heavy dependencies**: `serde_json` (Aseprite parser)

## 2. Mission Summary

The animation module is Lurek2D's sprite animation system: frame pools, named clips, a playback controller with speed/pause/crossfade, an event queue, parameter-driven state machines, blend layers, keyframe curves, and sync groups. It serves GameDev (clip-based sprite animation), Modder (Aseprite import, blend layers), and EngDev (clean Foundations-tier dependency graph). It deliberately does NOT own property tweening (that belongs to `tween`), texture management (that belongs to `render`), or skeletal/bone animation (that belongs to `spine`).

## 3. Existing Strengths

- Pure-Rust Foundations tier — depends only on `crate::math`, making it testable without GPU or Lua VM.
- Rich feature set: clips, crossfade, state machine, blend layers, sync groups, keyframe curves — covers common animation workflows from simple sprite loops to parameter-driven character controllers.
- Aseprite import (`aseprite.rs`) handles array and hash JSON formats with per-frame durations and tag-based clip creation.
- `AnimEvent` queue provides clean separation between update logic and game-script reaction code.
- Comprehensive test coverage already in place for `frame.rs`, `clip.rs`, `controller.rs`, `render.rs`, `curve.rs`, `sync_group.rs`.
- `Animation::draw_to_image` enables headless evidence tests without GPU.

## 4. Gap List

1. **[P1][GAP]** `Spine bridge` — `src/spine/` and `src/animation/` are independent; no API for animation clips to drive bone transforms.
   - Why: Games needing skeletal animation cannot use the animation state machine to drive Spine rigs.
2. **[P2][GAP]** `Sprite-sheet integration` — `Animation::add_frames_from_grid` duplicates the grid-slicing logic that `SpriteSheet` already provides.
   - Why: Maintenance burden and subtle inconsistency risk between the two implementations.
3. **[P2][GAP]** `PingPong clip support` — Aseprite PingPong tags are parsed but the clip does not automatically reverse on completion.
   - Why: Aseprite PingPong animations play forward-only unless manually handled in Lua.

## 5. Feature Ideas

1. **[P1][FEAT]** `Spine Animation Bridge` — Add a `SpineAnimationAdapter` that translates `AnimStateMachine` state changes into Spine slot/bone transforms via `src/spine/`.
   - Rationale: Enables skeletal animation with parameter-driven state machines (GameDev).
   - Effort: L · Risk: high (two independent module designs must align).
   - Competitor inspiration: `[Defold: Spine animation integration with state machine — https://defold.com/manuals/spine/]`, `[Godot: AnimationTree with Spine runtime — https://docs.godotengine.org/en/stable/classes/class_animationtree.html]`.
2. **[P2][FEAT]** `PingPong Clip Mode` — Add a `ping_pong: bool` field to `AnimClip`; when true, the clip auto-reverses at the end instead of looping from frame 0.
   - Rationale: Direct Aseprite PingPong support without Lua-side reversal logic (GameDev, Modder).
   - Effort: S · Risk: low.
3. **[P2][FEAT]** `AnimCurve Multi-Property` — Allow an `AnimCurve` to drive multiple named properties in parallel (e.g. x, y, alpha) from a single timeline.
   - Rationale: Reduces the number of curves game scripts must manage for complex procedural animations.
   - Effort: S · Risk: low.
   - Competitor inspiration: `[LÖVE2D: flux library multi-property tween — https://github.com/rxi/flux]`.

## 6. Performance / Reliability / Quality Ideas

- **[P1][PERF]** `Avoid clip clone in update()` — `Animation::update` clones the entire `AnimClip` each frame via `clip.clone()`. Refactor to borrow.
  - Hot path: `controller.rs:update` (line ~275).
  - Verification: criterion bench with 100 active animations at 60 fps.
- **[P2][QUAL]** `AnimFrame constructor` — `AnimFrame` has no `new()` method; frames are constructed via struct literal. Add `AnimFrame::new(quad, duration)` for API consistency.
  - File: `frame.rs`.
  - Reason: All other animation types provide constructors.
- **[P3][QUAL]** `parse_condition visibility` — `parse_condition` and `compare_nums` in `state_machine.rs` are private but useful for testing. Consider `pub(crate)` or expose via a test helper.
  - File: `state_machine.rs`.
  - Reason: Improves testability.

## 7. Test Coverage Gaps

- **[P1][TEST-RUST]** Add Rust tests for `Animation::load_from_aseprite` (various tag directions, empty frames).
- **[P1][TEST-RUST]** Add Rust tests for `AnimStateMachine::update` transition chains (multi-hop).
- **[P2][TEST-LUA]** Add Lua BDD test for `lurek.animation.newCurve()` under `tests/lua/animation/`.
- **[P2][TEST-LUA]** Add Lua BDD test for `lurek.animation.newBlendLayerSet()`.
- **[P3][TEST-FUZZ]** Fuzz target: `load_aseprite_json` with random JSON strings.

## 8. TODO(dedup): Cross-Module Overlap

```text
TODO(dedup): sprite::sprite_sheet::SpriteSheet — animation::controller::add_frames_from_grid duplicates grid-slicing; consider accepting SpriteSheet frames as input
TODO(dedup): sprite::atlas::parse_aseprite_json — animation::aseprite::load_aseprite_json both parse Aseprite JSON; unify or layer (atlas for regions, aseprite for frames+tags)
TODO(dedup): tween::state::TweenState — animation::curve::AnimCurve both interpolate values over time with easing; clarify ownership boundary (curve = keyframes, tween = start→end)
```

## 9. TODO(helper): Engine-Level Helper Candidates

```text
TODO(helper): anim_controller — Lua helper combining Animation + SpriteSheet + state machine for the "animated game character" pattern — citation: content/library/animator/init.lua
TODO(helper): anim_preview — Lua helper rendering animation frames to an ImageData grid for debug UI — citation: content/examples/animation.lua
```

## 10. TODO(plugin): Plugin Candidacy Proposal

```text
TODO(plugin): CORE-KEEP — sprite animation is a fundamental 2D engine feature; every game with moving sprites uses it. No extraction benefit.
```

- **Extraction blockers**: `Animation` is used by `render.rs` (RenderCommand generation), `lua_api/animation_api.rs`, and stored in `SharedState`.
- **Heavy dep impact if extracted**: n/a (only `serde_json` for Aseprite parser, already shared).
- **Lua surface stability**: stable.
- **Migration step**: n/a.

## 11. References

- Module spec: [docs/specs/animation.md](../../../docs/specs/animation.md)
- Lua API reference: [docs/API/lua-api.md#animation](../../../docs/API/lua-api.md)
- Philosophy constraints touched: `A-03` (2D only), `B-03` (60 FPS target)
- Plugin doc tier table: [plugins.md §5](../../../docs/architecture/plugins.md#5-candidate-modules)
- Competitor links cited above: Defold Spine, Godot AnimationTree, LÖVE2D flux
- Authoring guide: [IDEA_AUTHORING.md](../../work/src-module-review-20260418/reports/IDEA_AUTHORING.md)
- Session plan: [PLAN.md](../../work/src-module-review-20260418/reports/PLAN.md)
