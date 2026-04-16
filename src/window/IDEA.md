# IDEA.md — `window` module

> Migrated from `ideas/features/window.md`.
> Status checked against `src/window/` and `src/lua_api/window_api.rs`.
> Lua namespace: `lurek.window`.

---

## Features

### 🤔 CONSIDER — API Sub-Table Reorganization
**Source**: features/window.md — Structural Issues

39+ functions is a flat namespace. Grouping into sub-tables would improve discoverability:
`lurek.window.display.*`, `lurek.window.cursor.*`, `lurek.window.clipboard.*`.
Breaking change — requires API version bump.
