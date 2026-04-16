# IDEA.md — `save` module

> Migrated from `ideas/features/savegame.md`.
> Status checked against `src/save/` and `src/lua_api/save_api.rs`.
> Lua namespace: `lurek.savegame`.

---

## Features

### ❌ DEFERRED — Entity Serialization Bridge
**Source**: features/savegame.md — Structural Issues / Suggestions #4

Needs design alignment with `lurek.ecs`. Deferred.

---

### ❌ DEFERRED — Screenshot Thumbnail Attachment
**Source**: features/savegame.md — Feature Gaps #4 / Suggestions #3

Needs render module integration. Deferred.

---

### ❌ DEFERRED — Incremental / Delta Saves
**Source**: features/savegame.md — Feature Gaps #1

Complex implementation. Deferred until save profiling shows this is a bottleneck.
