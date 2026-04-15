# IDEA.md — `animation` module

> Migrated from `ideas/features/animation.md`.
> Status checked against `src/animation/` and `src/lua_api/animation_api.rs`.

---

## Features

### ✅ DONE — Crossfade Between Clips
**Source**: features/animation.md — Feature Gaps #1

`crossfade()` implemented in `animation_api.rs` (line ~228). Smooth blend from current clip to
a named target clip with duration parameter.

---

### ✅ DONE — Animation State Machine
**Source**: features/animation.md — Feature Gaps #2 / Suggestions #1

`src/animation/state_machine.rs` and `LuaAnimStateMachine` exist. Exposed as
`lurek.animation.newStateMachine()` in `animation_api.rs`.

---

### ✅ DONE — Aseprite Import
**Source**: features/animation.md — Feature Gaps #6 / Suggestions #3

`src/animation/aseprite.rs` and `lurek.animation.fromAseprite()` implemented in
`animation_api.rs` (line ~411).

---

### ❌ TODO — Animation Blend Layers / Masks
**Source**: features/animation.md — Feature Gaps #5

No upper/lower body layer blending found. Needed for playing an attack animation on the upper
body simultaneously with a walk on the lower body. No implementation in `src/animation/` or
`animation_api.rs`.

---

### ✅ DONE — Animation Curves (Keyframe / Linear / Easing Interpolation)
**Source**: features/animation.md — Feature Gaps #3

`lurek.animation.newCurve()` factory added. `AnimCurve` implemented in `src/animation/curve.rs`.
Supports `Step`, `Linear`, `EaseIn`, `EaseOut`, `EaseInOut` easing kinds.
Lua API: `curve:addKeyframe(t, v)`, `curve:eval(t)`, `curve:setEasing(name)`, `curve:keyframeCount()`, `curve:clear()`.

---

### ❌ TODO — Spine Bridge
**Source**: features/animation.md — Feature Gaps #4 / Suggestions #5

`src/spine/` and `src/animation/` are independent. There is no API for animation clips to drive
bone transforms in the Spine module. Requires design alignment between both modules.

---

### ✅ DONE — Named Animation Groups (Sync)
**Source**: features/animation.md — Feature Gaps #8

`lurek.animation.newSyncGroup()` factory added. `AnimSyncGroup` implemented in `src/animation/sync_group.rs`.
Lua API: `group:add(key)`, `group:remove(key)`, `group:clear()`, `group:memberCount()`.

---

### 🤔 CONSIDER — Tween/Property Animation Ownership
**Source**: features/animation.md — Structural Issues

Property tweening (`move X from 0 to 100 over 2 seconds`) falls in a gap between `animation`
and `math` modules. The dedicated `tween` module (`src/tween/`) exists — ensure it is clearly
documented as the canonical owner and cross-link from `lurek.animation` docs.
