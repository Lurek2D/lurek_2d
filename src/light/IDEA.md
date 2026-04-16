# IDEA.md — `light` module

> Migrated from `ideas/features/light.md`.
> Status checked against `src/light/` and `src/lua_api/light_api.rs`.
> Lua namespace: `lurek.light`.

---

## Features

### ❌ TODO — Soft Shadows (Penumbra)
**Source**: features/light.md — Feature Gaps #7 / Suggestions #3

No `light:setShadowSoftness(factor)` found. Hard shadows only. Soft shadows require either
multi-sample shadow rays or a blur post-pass on the shadow map.

---

### ❌ TODO — Integration with `fx` Ambient Overlay
**Source**: features/light.md — Feature Gaps #8 / Suggestions #2

Two independent ambient color systems: `LightWorld.ambient_color` and the fx module's
ambient time-of-day overlay. They don't talk to each other. Unify or bridge to avoid
conflicting ambient states.

---
