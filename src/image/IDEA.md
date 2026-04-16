# IDEA.md — `image` module

> Migrated from `ideas/features/image.md` and `ideas/performance/12-image-cpu-pixel-ops.md`.
> Status checked against `src/image/` and `src/lua_api/image_api.rs`.
> Lua namespace: `lurek.image`.

---

## Features

### ❌ TODO — Screen Pixel Readback
**Source**: features/image.md — Feature Gaps #1 / Suggestions #1

No `lurek.image.fromScreen()` or GPU texture readback found. Needed for screenshot,
visual testing, and post-processing Lua pipelines. GPU readback must be async
(submit → poll next frame) — design carefully to avoid pipeline stall.

---

## Performance
