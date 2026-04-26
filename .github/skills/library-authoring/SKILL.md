---
name: library-authoring
description: "Load this skill when authoring or modifying a Lunasome library under library/: creating a new library, refactoring an existing one, fixing helper drift, regenerating the library docs, or registering a new test in tests/lua/harness.rs. Owns library folder layout, LDoc tag conventions, the runtime-namespace name table, and the gen_lib_docs.py workflow. Skip it for engine Rust code, content/examples/ single-file scripts (use examples-management), or content/games/ games (use demo-creation)."
---
# library-authoring

## Mission

Own library/ folder layout, LDoc tag conventions, runtime-namespace name table, forbidden API rules, and the gen_lib_docs.py workflow for Lunasome libraries.

## When To Load

- Creating a new library folder under library/<name>/
- Refactoring an existing library or fixing helper drift
- Wiring a new library's test file into tests/lua/harness.rs
- Regenerating docs/api/library.md or docs/reports/libs/<name>.md

## When To Skip

- Engine Rust code → use rust-coding
- content/examples/ single-file scripts → use examples-management
- content/games/ playable games → use demo-creation
- Designing new lurek.* engine APIs → use lua-api-design

## Domain Knowledge

**Mandatory folder layout per library:**

| File | Purpose |
|------|--------|
| library/<name>/init.lua | Public API; returned by require("library.<name>") |
| library/<name>/AGENT.md | Module reference (purpose, deps, public surface) |
| library/<name>/example.lua | Self-contained runnable showcase |
| tests/lua/library/test_library_<name>.lua | BDD test, ends with test_summary() |
| tests/lua/harness.rs | Manual #[test] fn lua_test_library_<name>() entry |

Renames or deletions must update ALL of the above in the same commit. Deprecated libraries keep old init.lua as a thin stub that requires the new name with a deprecation warning.

**LDoc tag set (parsed by tools/docs/gen_lib_docs.py):** @module library.<name> (once at top), @status full|partial|stub|proxy (per module and per public fn), @local (mark non-public helpers, suppressed in docs), @param name type description, @tparam type name description, @treturn type description.

**Forbidden API calls from library code:** library code is the headless layer — must not require window, GPU, or audio device at require() time. Forbidden in init.lua: lurek.render.* (draw calls), lurek.audio.play* (device opening), lurek.window.* (size/title/cursor), lurek.input.* (polling at load time), lurek.effect.* (shader passes). If a library needs rendering hooks, expose data and document with @see.

**Lua portability rules:** no bare unpack() — always use local unpack = table.unpack or unpack. All locals at module top. No metatable surgery on lurek.* returns. Must work on both LuaJIT and lua54 fallback.

**Runtime namespace names:** always grep src/lua_api/mod.rs for the actual registered name before introducing a dependency. Doc names and runtime names generally match (lurek.image, lurek.serial, lurek.save, lurek.timer, lurek.ecs, lurek.filesystem, lurek.pathfind, lurek.effect, lurek.particle, lurek.render, lurek.i18n, lurek.runtime) but always verify.

**Regeneration workflow:** python tools/docs/gen_lib_docs.py regenerates docs/reports/lib-api.md and per-library pages. Run after any library change. Validate with tools/validate/validate_library.py --library NAME --strict.

## Companion File Index

None — all guidance is inline.

## References

- library/README.md — library index and status table
- tools/docs/gen_lib_docs.py — library doc generator
- tools/validate/validate_library.py — library structure validator
- tools/mods/mod_init.py — scaffold a new lurek-mod plugin layout
