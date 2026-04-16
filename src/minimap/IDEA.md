# IDEA.md — `minimap` module

> Migrated from `ideas/features/minimap.md` and `ideas/performance/14-minimap-fov-gpu.md`.
> Status checked against `src/minimap/` and `src/lua_api/minimap_api.rs`.
> Lua namespace: `lurek.minimap`.

---

## Features

### 🤔 CONSIDER — Extract Fog of War as Standalone System
**Source**: features/minimap.md — Structural Issues #2

Fog of war is bundled inside the minimap module. In RTS, RPG, and stealth games, fog of
war is a gameplay system independent of the minimap. Consider extracting into `src/fow/`
or a sub-namespace `lurek.minimap.fow` with a standalone Lua API.

---

## Performance

### 🔇 LOW — GPU Fog of War Rendering
**Source**: performance/14-minimap-fov-gpu.md

Fog of war reveal is computed CPU-side per entity per frame. For large maps (500×500+
tiles) and many entities, a GPU compute shader fill would be faster. Evidence from profiling
is needed first. Priority: **LOW**.
