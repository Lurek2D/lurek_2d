# IDEA.md — `scene` module

> Migrated from `ideas/features/scene.md` + `ideas/performance/21-gui-scene-events.md`.
> Status checked against `src/scene/` and `src/lua_api/scene_api.rs`.
> Lua namespace: `lurek.scene`.

---

## Features

### 🤔 CONSIDER — Move DepthSorter to `render` Module
**Source**: features/scene.md — Structural Issues

`DepthSorter` (z-order sorting for draw calls) is a rendering primitive living inside
the scene module. It should be in `render` or `camera`. Move requires Architect review.

---

### 🤔 CONSIDER — Unify Scene Transitions with `effect` Module
**Source**: features/scene.md — Structural Issues

Scene transitions (fade, slide) duplicate visual effects already in `lurek.fx`.
Consider delegating transition rendering to the effect module.
