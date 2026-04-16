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

### ✅ DONE — Integration with PostFx GodRays
**Source**: features/light.md — Feature Gaps #6 / Suggestions #7

`LightWorld::directional_light_hints()` added to `src/light/light_world.rs`. Filters enabled
directional lights and returns `Vec<(f32, f32, f32)>` (x, y, direction) tuples.

`lurek.light.getGodRayHints()` free function added to `src/lua_api/light_api.rs`. Returns an
indexed table of `{x, y, angle}` records, one per enabled directional light. A post-processing
or effect pass can read this table to drive god-ray shaders without coupling effect and light
Rust modules.

```lua
local hints = lurek.light.getGodRayHints()
for _, h in ipairs(hints) do
    -- pass h.x, h.y, h.angle to your god-ray shader
end
```

`LightWorld::ambient_color_hint()` + `lurek.light.syncAmbient()` also added for parity:
a read-only ambient snapshot suitable for shader uniform uploads.

Implemented: 2026-04-18

---

### ✅ DONE — Tier Label in Source Code
**Source**: features/light.md — Structural Issues

`src/light/mod.rs` tier comment updated from Tier 1 to Tier 2 (Platform Services) to
align with `docs/specs/light.md` and `docs/architecture/engine-architecture.md`.

Fixed: 2026-04-18
