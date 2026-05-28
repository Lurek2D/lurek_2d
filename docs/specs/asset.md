# asset

## TL;DR

- The `asset` module provides a ref-counted media cache for Lua scripts.
  Load images, fonts, audio, and text assets by path; hold `LAssetHandle` values
  to keep them alive; query stats and preload batches.

## General Info

- **Module group:** `Feature Systems`
- **Source path:** `src/asset/`
- **Lua API path(s):** `src/lua_api/asset_api.rs`
- **Primary Lua namespace:** `lurek.asset`
- **Lua test path(s):** `tests/lua/unit/test_asset_core_unit.lua`
- **Example stubs:** `content/examples/asset.lua`

## Summary

The `asset` module is a lightweight ref-counted cache for named game assets. Scripts
call `lurek.asset.load(path, type)` to register an entry; the returned `LAssetHandle`
keeps the entry alive as long as at least one handle holds a positive ref count.
Calling `lurek.asset.unload(handle)` decrements the ref count and removes the entry
when it reaches zero. `lurek.asset.clear()` is an escape hatch that drops all entries
unconditionally.

For `text` assets the file content is read and cached in Rust. For `image`, `font`,
and `audio` assets the path is stored; `lurek.asset.get(handle)` calls the
appropriate `lurek.*` sub-module constructor on each invocation. The cache is a
per-VM singleton created during `register()`.

## Files

- `mod.rs`: Module manifest. `pub mod cache; pub use cache::*`.
- `cache.rs`: `AssetCache`, `AssetEntry`, and `AssetType` types.

## Types

- `AssetCache` (`struct`, `cache.rs`): Ref-counted cache keyed by `u64` handle IDs.
  Manages `register`, `inc_ref`, `dec_ref`, `get`, and iteration.
- `AssetEntry` (`struct`, `cache.rs`): One cached record: `path`, `asset_type`,
  `ref_count`, and optional `text_content`.
- `AssetType` (`enum`, `cache.rs`): Discriminant with variants `Image`, `Font`,
  `Audio`, `Text`, and `Unknown(String)`.

## Functions

| Function      | Module     | Signature                                            |
| ------------- | ---------- | ---------------------------------------------------- |
| `new`         | `cache`    | `AssetCache::new() -> AssetCache`                    |
| `register`    | `cache`    | `(&mut self, path, type, text) -> u64`               |
| `inc_ref`     | `cache`    | `(&mut self, id: u64)`                               |
| `dec_ref`     | `cache`    | `(&mut self, id: u64)`                               |
| `get`         | `cache`    | `(&self, id: u64) -> Option<&AssetEntry>`            |
| `ref_count`   | `cache`    | `(&self, id: u64) -> usize`                          |
| `is_loaded`   | `cache`    | `(&self, id: u64) -> bool`                           |
| `loaded_count`| `cache`    | `(&self) -> usize`                                   |
| `total_refs`  | `cache`    | `(&self) -> usize`                                   |
| `clear`       | `cache`    | `(&mut self)`                                        |
| `iter`        | `cache`    | `(&self) -> impl Iterator<Item=(&u64,&AssetEntry)>`  |

## Lua API Reference

| Symbol                    | Signature                                          | Notes                                |
| ------------------------- | -------------------------------------------------- | ------------------------------------ |
| `lurek.asset.load`        | `(path: string, type: string) → LAssetHandle`      | Creates a new cache entry; ref=1.    |
| `lurek.asset.unload`      | `(handle: LAssetHandle) → nil`                     | Decrements ref; removes at 0.        |
| `lurek.asset.get`         | `(handle: LAssetHandle) → any`                     | Returns value; calls Lua ctor.       |
| `lurek.asset.preload`     | `(paths: table, callback: any) → nil`              | Sync batch; fires `cb(i,n)` each.    |
| `lurek.asset.refcount`    | `(handle: LAssetHandle) → integer`                 | Current ref count; 0 if not loaded.  |
| `lurek.asset.isLoaded`    | `(handle: LAssetHandle) → boolean`                 | True while entry is alive.           |
| `lurek.asset.stats`       | `() → table`                                       | `{loaded, total_refs, types}`.       |
| `lurek.asset.clear`       | `() → nil`                                         | Removes all entries unconditionally. |
| `LAssetHandle:type`       | `() → string`                                      | Returns `"LAssetHandle"`.            |
| `LAssetHandle:typeOf`     | `(name: string) → boolean`                         | Tests `LAssetHandle` or `LObject`.   |

## Notes

- The cache is per-VM: each Lua VM created by `register.rs` has its own independent
  `AssetCache` instance. Assets are not shared across worker-VM threads.
- `preload` is synchronous (not deferred). The callback is called inline for each
  item and once with `nil, nil` when the loop completes.
- For `image`, `font`, and `audio` types, `get()` calls the Lua constructor on every
  invocation. There is no caching of the Lua userdata value itself; only the path and
  metadata are cached. This keeps the Rust cache free of `mlua` lifetimes.
- `font` assets are loaded with a fixed size of 16pt when retrieved via `get()`.
- Ref-count management is entirely manual: dropping a Lua variable holding an
  `LAssetHandle` does **not** decrement the ref count. Call `lurek.asset.unload` or
  `lurek.asset.clear` to release entries.
