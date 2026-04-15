# IDEA.md — `light` module

> Migrated from `ideas/features/light.md`.
> Status checked against `src/light/` and `src/lua_api/light_api.rs`.
> Lua namespace: `lurek.light`.

---

## Features

### ✅ DONE — Light Groups with `setGroupIntensity`
**Source**: features/light.md — Suggestions #5

`setGroupIntensity(groupName, intensity)` implemented in `light_api.rs` (line ~1057).

---

### ❌ TODO — Soft Shadows (Penumbra)
**Source**: features/light.md — Feature Gaps #7 / Suggestions #3

No `light:setShadowSoftness(factor)` found. Hard shadows only. Soft shadows require either
multi-sample shadow rays or a blur post-pass on the shadow map.

---

### ✅ DONE — Light Cookies / Gobo Patterns
**Source**: features/light.md — Feature Gaps #2 / Suggestions #4

`light:setCookie(path)` / `light:getCookie()` / `light:clearCookie()` implemented in
`light_api.rs`. Stores the texture path on the `LuaLight` wrapper for use by the renderer.
```lua
light:setCookie("assets/textures/venetian_blind.png")
```

---

### ✅ DONE — Animated Light Transitions
**Source**: features/light.md — Feature Gaps #4 / Suggestions #6

`light:transitionTo(target, duration)` implemented in `light_api.rs`. `target` table may
contain `color`, `intensity`, and/or `radius`. Call `light:updateTransition(dt)` each frame.
`light:stopTransition()` cancels. `light:transitionProgress()` returns `[0,1]`.
Created `src/light/transition.rs` with `LightTransition` struct.
```lua
light:transitionTo({color={1,0.2,0,1}, intensity=3.0}, 2.0)
```

---

### ✅ DONE — Extended Flicker API
**Source**: API completeness

`light:addFlicker(min, max, hz)` implemented in `light_api.rs`. Converts intensity-range
+ frequency arguments to the underlying `FlickerConfig.speed` / `FlickerConfig.strength`.
More intuitive than calling `setFlicker(speed, strength)` directly.
```lua
light:addFlicker(0.8, 1.2, 5)   -- oscillate between 80%-120% intensity at 5 Hz
```

---

### ❌ TODO — Integration with `fx` Ambient Overlay
**Source**: features/light.md — Feature Gaps #8 / Suggestions #2

Two independent ambient color systems: `LightWorld.ambient_color` and the fx module's
ambient time-of-day overlay. They don't talk to each other. Unify or bridge to avoid
conflicting ambient states.

---

### ❌ TODO — Integration with PostFx GodRays
**Source**: features/light.md — Feature Gaps #6 / Suggestions #7

Directional lights have a position and angle but `effect`/PostFx god-ray effect doesn't
use light positions. Bridge needed: feed light data as god-ray source hint.

---

### ⚠️ FIXME — Tier Label in Source Code
**Source**: features/light.md — Structural Issues

`src/light/mod.rs` documents itself as Tier 1 (Core) but architecture docs and
`docs/specs/light.md` classify it as Tier 2 (Extension / Platform Services). Fix the
comment in `mod.rs`.
