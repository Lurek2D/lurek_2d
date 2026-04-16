# IDEA.md — `mods` module

> Migrated from `ideas/features/modding.md` and `ideas/performance/24-savegame-modding-io.md` (modding section).
> Status checked against `src/mods/` and `src/lua_api/mods_api.rs`.
> Lua namespace: `lurek.modding`.

---

## Features

### ❌ DEFERRED — Track Active Mods in Save Files
**Source**: features/modding.md — Structural Issues / Suggestions #4

Needs cross-module coordination with `save`. Deferred until the save schema extension
landscape is clearer. Tracked in save module IDEA.md.

---

### ❌ DEFERRED — Mod Hot Reload
**Source**: features/modding.md — Feature Gaps #6 / Suggestions #5

Requires filesystem watcher integration. Deferred until `src/filesystem/` watcher lands.

---
