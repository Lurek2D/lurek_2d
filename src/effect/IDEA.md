# IDEA.md — `effect` module

> Migrated from `ideas/features/fx.md` and `ideas/performance/15-postfx-shader-pipeline.md`.
> Status checked against `src/effect/` and `src/lua_api/effect_api.rs`.
> Lua namespace: `lurek.fx`.

---

## Features

### ✅ DONE — Preset Effect Stacks
**Source**: features/fx.md — Feature Gaps #4 / Suggestions #2

`newPresetStack(name, w, h)` implemented in `effect_api.rs` (line ~1382). Ships with presets:
`"retro_tv"`, `"horror"`, `"dream"`, `"neon"`, `"sepia_age"`.

---

### ✅ DONE — Palette Swap
**Source**: features/fx.md — Feature Gaps #3 / Suggestions #4

`"paletteswap"` PostFx type implemented in `effect_api.rs` (line ~1456).

---

### ✅ DONE — Screen Transition Effects (Wipe, Iris, Dissolve)
**Source**: features/fx.md — Feature Gaps #1 / Suggestions #1

`lurek.postfx.newTransition(kind, duration, color?)` implemented in `effect_api.rs`.
Created `src/effect/transition.rs` with `ScreenTransition` and `TransitionKind`.
Kinds: `"fade"` (default), `"wipe"`, `"iris"`, `"dissolve"`.
```lua
local t = lurek.postfx.newTransition("wipe", 1.0, {0,0,0,1})
t:play()
function lurek.render(dt)
  if t:isActive() then
    local p = t:progress()   -- use p to drive overlay alpha/width
    lurek.graphic.drawRect(0, 0, width * p, height)  -- example wipe overlay
  end
end
```

---

### ✅ DONE — GPU Feedback / Echo Effects
**Source**: features/fx.md — Feature Gaps #2 / Suggestions #5

`stack:setFeedback(factor)` / `stack:getFeedback()` / `stack:clearFeedback()` implemented
on `LuaPostFxStack` in `effect_api.rs`. `factor` is `[0,1]`; `0.0` disables feedback.
The `feedback_factor` field on `LuaPostFxStack` is exposed to the renderer for use in the
GPU frame-feedback loop.
```lua
local stack = lurek.postfx.newStack(800, 600)
stack:setFeedback(0.4)   -- 40% previous-frame blending
```

---

### ❌ TODO — Effect on Individual Layers / Sprites
**Source**: features/fx.md — Feature Gaps #6

PostFx stacks apply to the full screen. No per-layer or per-sprite effect found. A sprite
could pass through its own mini-canvas for local bloom or palette swap without affecting
the entire scene.

---

### ❌ TODO — Shader Compile Error Display in Dev Mode
**Source**: features/fx.md — Feature Gaps #7

Shader compilation errors in custom PostFx pass silently break the effect. A dev-mode
fallback (render a magenta/error quad with the WGSL error text) would speed up shader
authoring significantly.

> **Partial**: `lurek.postfx.setShaderErrorDisplay(true/false)` and `getShaderErrorDisplay()`
> are implemented (2026-04-16). The Lua-side toggle exists; GPU-side render path hookup is
> tracked in `docs/specs/effect.md`.

---

### 🤔 CONSIDER — Consolidate Screen Shake (see also `camera`)
**Source**: features/fx.md — Structural Issues

Screen shake appears in both `effect`/overlay system and `camera`. Pick one canonical
location (prefer camera) and remove the other. See `src/camera/IDEA.md`.

---

## Performance

### ✅ DONE — Effect Stack Deduplication
**Source**: performance/15-postfx-shader-pipeline.md
**Implemented**: 2026-04-16

`src/effect/stack.rs` — `PostFxStack::dedup_indices()` removes duplicate effect slots.
`src/lua_api/effect_api.rs` — `stack:dedup()` method on LuaPostFxStack (pointer-identity dedup).
Returns the number of slots removed.

Tests: `tests/lua/unit/test_effect_dedup.lua`
