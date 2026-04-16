# IDEA.md — `filesystem` module

> Migrated from `ideas/features/filesystem.md` and `ideas/performance/06-io-filesystem.md`.
> Status checked against `src/filesystem/` and `src/lua_api/filesystem_api.rs`.
> Lua namespace: `lurek.fs`.

---

## Features

### 🔇 LOW — Temp File Creation
**Source**: features/filesystem.md — Feature Gaps #5

No `createTempFile()`. Useful for intermediate processing but low priority for most game
use cases.

---

## Performance

### 🔇 LOW — Async Loader Completion Pattern Clarity
**Source**: features/filesystem.md — Structural Issues

`src/filesystem/async_loader.rs` exists. Verify whether completion uses callbacks or polling
and document the pattern clearly. No performance bottleneck identified — docs issue only.
