# IDEA — mods

- **Module**: `mods`
- **Path**: `src/mods/`
- **Date**: 2026-04-18
- **Tier**: Feature Systems

## Mission

Provide a mod management framework for Lurek2D — discovering, registering, ordering, validating, and hot-reloading user-created content packages that extend or override a base game without modifying its source.

## Strengths

- Complete lifecycle: scan → parse → register → validate deps → order → enable/disable → hot-reload queue.
- Circular dependency detection via DFS with visiting/visited sets.
- Custom load order support that gracefully falls back to priority-based sorting.
- TOML-based `mod.toml` manifests aligned with engine config convention (B-05).
- API versioning and capability declarations on ModInfo for forward-compatible sandboxing.
- Comprehensive existing test suite (~15 tests) covering registration, ordering, deps, reload, and disk scanning.

## Gaps

- No actual hot-reload execution — only queuing. Requires filesystem watcher integration (deferred).
- No semver parsing for `api_version` — stored as a plain string with no compatibility check in Rust.
- No mod conflict detection (two mods overriding the same asset path).
- No mod signature verification or integrity checking.
- `scan_folder` silently skips parse errors — no way for callers to learn which folders failed.
- No `mod.toml` schema validation beyond the few known fields.
- No integration with save system to track active mods in save files (deferred).

## Features (competitor cites)

1. **Mod conflict resolution UI** — Factorio shows a conflict matrix when two mods modify the same prototype. Lurek2D could report asset-path conflicts at mount time.
2. **Mod workshop / download integration** — Minecraft (CurseForge), Factorio (mod portal) provide in-game mod browsing. Lurek2D could add a `lurek.mods.fetch(url)` with sandboxed download to a staging folder.
3. **Sandboxed Lua environments per mod** — Garry's Mod and Minetest restrict each mod's Lua environment to prevent cross-mod interference. Lurek2D could spawn a restricted Lua VM per mod with only declared capabilities accessible.

## Perf / Quality

- `validate_dependencies` and `has_circular_dependencies` rebuild data structures from scratch each call. For small mod counts this is fine; for 100+ mods, cache the dep graph.
- `reload_queue` uses `Vec::contains` (O(n) string comparison) for deduplication — a `HashSet` would be O(1).

## Test Gaps

- No Rust test for malformed `mod.toml` (missing required fields, invalid TOML syntax, wrong value types).
- No test for `from_parts` with various `None` overrides.
- No test for `get_mod_mut` modifying a mod in-place.
- No test for `get_custom_load_order` accessor.

## TODO(dedup)

- `scan_folder`'s field-by-field override of ModInfo fields duplicates the pattern from `from_parts`. Refactor `scan_folder` to use `from_parts`.

## TODO(helper)

- Add `ModManager::get_mods_by_capability(cap: &str) -> Vec<&ModInfo>` for capability-based querying.
- Add `ModManager::topological_order() -> Result<Vec<&ModInfo>, String>` returning a proper topo-sort (not just priority) that errors on cycles.

## TODO(plugin)

- The mods system is a TIER-1-PLUGIN candidate — games without mod support shouldn't include the scanning and TOML parsing overhead. Gate behind a `mods` Cargo feature flag.

## References

- `src/lua_api/mods_api.rs` — Lua bridge
- `docs/specs/mods.md` — module spec
- `content/plugins/` — plugin content directory
