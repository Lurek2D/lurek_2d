# IDEA.md — `tween` module

> Migrated from `ideas/features/animation.md` (tween sections).
> Status checked against `src/tween/` and `src/lua_api/tween_api.rs`.
> Lua namespace: `lurek.tween`.

---

## Features

### 🔇 LOW — Coroutine yield inside tween sequence
**Source**: features/animation.md

No tween-sequence step that yields a coroutine until the tween finishes. Low priority
if timer coroutine wait is also missing (see `src/timer/IDEA.md`).
