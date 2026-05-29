# asset

## TL;DR

The `asset` module is a ref-counted registry for game-asset metadata. Scripts load
assets by path and type; each `LAssetHandle` keeps the entry alive. Assets can be
annotated with a display name, a group label, and an arbitrary tag set. Query
functions (`findByName`, `findByGroup`, `findByTag`, `findByType`) return handle
arrays for batch iteration.

## General Info

- **Module group:** `Feature Systems`
- **Source path:** `src/asset/`
- **Lua API path(s):** `src/lua_api/asset_api.rs`
- **Primary Lua namespace:** `lurek.asset`
- **Lua test path(s):** `tests/lua/unit/test_asset_core_unit.lua`
- **Example stubs:** `content/examples/asset.lua`

## Summary

The `asset` module records *where* an asset lives on disk and *how it is classified*.
It does not own decoded GPU resources; those are managed by `lurek.image`, `lurek.font`,
and `lurek.audio`. The cache is a lightweight per-VM registry and search layer.

Scripts call `lurek.asset.load(path, type, opts?)` to register an entry. The returned
`LAssetHandle` keeps the entry alive. `lurek.asset.unload(handle)` decrements the ref
count and removes the entry when it reaches zero. `lurek.asset.clear()` drops all
entries unconditionally.

### Text-like vs binary types

Text-like types (`text`, `toml`, `json`, `obj`, `shader`, `lua`) read the file into
memory at load time. `lurek.asset.get(handle)` returns the cached string.

Binary types (`image`, `font`, `audio`, `music`) store only the path reference.
`lurek.asset.get(handle)` calls the appropriate Lua constructor each time:

| Type     | `get()` calls                |
|----------|------------------------------|
| `image`  | `lurek.image.loadImage(path)`|
| `font`   | `lurek.font.load(path, 16)`  |
| `audio`  | `lurek.audio.newSource(path)`|
| `music`  | `lurek.audio.newSource(path)`|

### Metadata

Each entry supports an optional display name, a group label, and a tag set. All three
are set either at load time via the `opts` table or later with the setter functions.

## Files

- `mod.rs`: Module manifest and public re-exports.
- `cache.rs`: `AssetCache`, `AssetEntry`, and `AssetType` types; all business logic.

## Types

### `AssetType` (enum, `cache.rs`)

Variants: `Image`, `Font`, `Audio`, `Music`, `Text`, `Toml`, `Json`, `Obj`, `Shader`,
`Lua`, `Unknown(String)`. The `is_text_like()` method returns `true` for
`Text | Toml | Json | Obj | Shader | Lua`.

### `AssetEntry` (struct, `cache.rs`)

Fields: `path: String`, `asset_type: AssetType`, `ref_count: usize`,
`text_content: Option<String>`, `name: Option<String>`, `group: Option<String>`,
`tags: HashSet<String>`.

### `AssetCache` (struct, `cache.rs`)

Ref-counted map from `u64` handle IDs to `AssetEntry`. One instance per Lua VM.

## Rust API

| Method            | Signature                                                  |
|-------------------|------------------------------------------------------------|
| `new`             | `() -> Self`                                               |
| `register`        | `(&mut self, path, type, text) -> u64`                     |
| `inc_ref`         | `(&mut self, id: u64)`                                     |
| `dec_ref`         | `(&mut self, id: u64)`                                     |
| `get`             | `(&self, id: u64) -> Option<&AssetEntry>`                  |
| `set_name`        | `(&mut self, id: u64, name: String)`                       |
| `set_group`       | `(&mut self, id: u64, group: String)`                      |
| `add_tag`         | `(&mut self, id: u64, tag: &str)`                          |
| `remove_tag`      | `(&mut self, id: u64, tag: &str) -> bool`                  |
| `has_tag`         | `(&self, id: u64, tag: &str) -> bool`                      |
| `ref_count`       | `(&self, id: u64) -> usize`                                |
| `is_loaded`       | `(&self, id: u64) -> bool`                                 |
| `loaded_count`    | `(&self) -> usize`                                         |
| `total_refs`      | `(&self) -> usize`                                         |
| `find_by_name`    | `(&self, substr: &str) -> Vec<u64>`                        |
| `find_by_group`   | `(&self, group: &str) -> Vec<u64>`                         |
| `find_by_tag`     | `(&self, tag: &str) -> Vec<u64>`                           |
| `find_by_type`    | `(&self, type_str: &str) -> Vec<u64>`                      |
| `unique_groups`   | `(&self) -> Vec<String>`                                   |
| `clear`           | `(&mut self)`                                              |
| `iter`            | `(&self) -> impl Iterator<Item=(&u64,&AssetEntry)>`        |

## Lua API Reference

### Core load/unload

| Symbol                     | Signature                                              | Notes                                      |
|----------------------------|--------------------------------------------------------|--------------------------------------------|
| `lurek.asset.load`         | `(path, type, opts?) → LAssetHandle`                   | `opts`: `{name?, group?, tags?}`.          |
| `lurek.asset.unload`       | `(handle) → nil`                                       | Decrements ref; removes entry at 0.        |
| `lurek.asset.get`          | `(handle) → any`                                       | String for text-like; Lua obj for binary.  |
| `lurek.asset.preload`      | `(paths: table, cb: function) → nil`                   | Sync batch; calls `cb(i,n)` per item.      |
| `lurek.asset.refcount`     | `(handle) → integer`                                   | 0 when entry is not present.               |
| `lurek.asset.isLoaded`     | `(handle) → boolean`                                   | True while entry is alive.                 |
| `lurek.asset.stats`        | `() → table`                                           | `{loaded, total_refs, types, groups}`.     |
| `lurek.asset.clear`        | `() → nil`                                             | Removes all entries unconditionally.       |

### Path / type inspection

| Symbol                     | Signature                    | Notes                                         |
|----------------------------|------------------------------|-----------------------------------------------|
| `lurek.asset.getPath`      | `(handle) → string`          | Path supplied to `load`.                      |
| `lurek.asset.getType`      | `(handle) → string`          | Type string, e.g. `"toml"`, `"music"`.        |
| `lurek.asset.getInfo`      | `(handle) → table`           | `{path, type, name, group, tags, refcount}`.  |

### Name and group

| Symbol                     | Signature                              | Notes                                         |
|----------------------------|----------------------------------------|-----------------------------------------------|
| `lurek.asset.setName`      | `(handle, name: string) → nil`         | Sets display name.                            |
| `lurek.asset.getName`      | `(handle) → string`                    | Returns name or path file-stem.               |
| `lurek.asset.setGroup`     | `(handle, group: string) → nil`        | Assigns group label.                          |
| `lurek.asset.getGroup`     | `(handle) → string`                    | Returns group or `""` when unset.             |

### Tags

| Symbol                     | Signature                              | Notes                                         |
|----------------------------|----------------------------------------|-----------------------------------------------|
| `lurek.asset.addTag`       | `(handle, tag: string) → nil`          | Adds tag to the set.                          |
| `lurek.asset.removeTag`    | `(handle, tag: string) → boolean`      | True when tag was present and removed.        |
| `lurek.asset.getTags`      | `(handle) → table`                     | Array of tag strings.                         |
| `lurek.asset.hasTag`       | `(handle, tag: string) → boolean`      | True when tag is in the set.                  |

### Search

| Symbol                     | Signature                              | Notes                                                         |
|----------------------------|----------------------------------------|---------------------------------------------------------------|
| `lurek.asset.findByName`   | `(substr: string) → table`             | Case-insensitive; uses file-stem when no explicit name set.   |
| `lurek.asset.findByGroup`  | `(group: string) → table`              | Exact match on group label.                                   |
| `lurek.asset.findByTag`    | `(tag: string) → table`                | All handles that have `tag` in their set.                     |
| `lurek.asset.findByType`   | `(type: string) → table`               | Exact match on type string.                                   |

### LAssetHandle methods

| Symbol               | Signature              | Notes                                  |
|----------------------|------------------------|----------------------------------------|
| `LAssetHandle:type`  | `() → string`          | Returns `"LAssetHandle"`.              |
| `LAssetHandle:typeOf`| `(name) → boolean`     | True for `LAssetHandle` or `LObject`.  |

## Notes

- The cache is **per-VM**. Worker VMs created by `lurek.thread` each have their own
  independent `AssetCache`; assets are not shared across Lua VMs.
- `preload` is **synchronous** — it iterates inline and is not deferred.
  The callback is called once per item with `(i, n)` and once more with `(nil, nil)`
  to signal completion.
- For `image`, `font`, `audio`, and `music` types, `get()` constructs the Lua object
  on every call. The cache stores only the path; there is no GPU/audio handle cache.
  This keeps `AssetCache` free of `mlua` lifetimes.
- `font` assets retrieved via `get()` are loaded at a fixed size of 16 pt.
- Ref-count management is **entirely manual**: dropping a Lua variable holding an
  `LAssetHandle` does **not** decrement the ref count. Always call
  `lurek.asset.unload(handle)` or `lurek.asset.clear()` when assets are no longer needed.
- `lurek.asset` does not replace `lurek.sprite`, `lurek.image`, or `lurek.audio`.
  Those modules own decoded resources; `lurek.asset` is the registry and tagging
  layer that sits in front of them.
