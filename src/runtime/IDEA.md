# IDEA.md — `runtime` module

> Migrated from `ideas/features/engine.md` (runtime / infrastructure sections).
> Status checked against `src/runtime/` (config.rs, resource_keys.rs, shared_state.rs, etc.).
> Lua namespace: N/A — `runtime` is internal infrastructure; no direct Lua exposure.

---

## Features

### ✅ DONE — Streaming Resource Loading (Background Thread)
**Source**: general performance patterns

`src/filesystem/async_loader.rs` implements `AsyncLoader` — a background thread pool
that reads files off the main thread and returns `LoadHandle` futures. The Lua API
exposes `lurek.filesystem.loadAsync(path)` with `isDone()`, `getBytes()`, and `getError()`
methods for polling from the game loop without blocking the main thread.

---

### ✅ DONE — Resource Eviction Policy
**Source**: general resource management

`SharedState` now tracks a configurable `resource_budget` (bytes) and an LRU access-time
table for textures and audio buffers. When total resident size exceeds the budget,
the least-recently-used resources are evicted. Eviction is triggered automatically at
frame start and can also be forced via the internal `evict_lru_resources()` helper.

---

### 🤔 CONSIDER — Config Hot Reload
**Source**: features/engine.md — Feature Gaps #1

With `src/filesystem/watcher.rs` (polling `FileWatcher`) now available, reloading
`conf.toml` at runtime for adjustable settings (window title, frame budget, active
modules) is feasible without a full restart. Medium effort — needs a diff-and-apply
strategy that avoids reinitialising immutable settings (window size, backend selection).
