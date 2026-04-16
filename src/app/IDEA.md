# IDEA.md — `app` module

> Migrated from `ideas/features/engine.md`.
> Status checked against `src/app/` (includes `app.rs`, `shared_state.rs`, boot sequence).
> Lua namespace: N/A — `app` is the engine lifecycle entry point; no direct Lua exposure.

---

## Features

### ❌ TODO — Hot Reload (Lua + Assets) — HIGH PRIORITY
**Source**: features/engine.md — Feature Gaps #1 / Suggestions #1

No mechanism to reload Lua scripts or assets at runtime without restarting.
This is the #1 missing feature for development workflow — every competitor engine
supports some form of live reload.

Infrastructure available: `src/filesystem/watcher.rs` (polling-based `FileWatcher`) already
exists and watches for file modifications. Wiring plan:
1. On change to `main.lua` or required Lua files: call `restart_game()` which already
   reinitialises the Lua VM while keeping window and GPU state intact.
2. Asset hot-reload: invalidate `TextureKey` / `FontKey` entries in SharedState pools.

---

### ✅ DONE — `.luna` Single-File Distribution Format
**Source**: features/engine.md — Feature Gaps #4 / Suggestions #3

`ZipMount` infrastructure exists in `src/filesystem/zip_mount.rs`. App detects when
the `game_dir` argument ends with `.luna` (case-insensitive), extracts to a temp
directory, mounts it as the GameFS root, and runs `main.lua` from it. Distribution
remains "zip your game, rename to `.luna`".

See: `src/app/app.rs` — `detect_and_mount_luna_bundle()`, `src/filesystem/zip_mount.rs`.

---

### ❌ TODO — Plugin / Extension Registry
**Source**: features/engine.md — Feature Gaps #3

No way to register new `lurek.*` namespaces without modifying `src/lua_api/mod.rs`.
Requires a trait-based plugin registry with a stable FFI surface. Medium effort,
architectural change — needs Architect decision before implementation.

---

### 🤔 CONSIDER — Extract Splash Screen to Dedicated Module
**Source**: features/engine.md — Structural Issues

`app.rs` handles: boot + event loop + splash screen + debug overlay.
Splash screen logic (embeds large PNGs, draw commands) bloats `app.rs` significantly.
A `src/splash/` module would isolate branding code from lifecycle logic.

---

### ✅ DONE — Config Fallback on conf.lua Syntax Error
**Source**: features/engine.md — Structural Issues

When `conf.lua` fails to parse, `Config::default()` is used and the error is stored
in `LunaApp::conf_error`. On the first `init_lua()` call, the error is surfaced on the
red error screen rather than panicking before the window exists.
