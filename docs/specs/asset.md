# asset

## TL;DR

`lurek.asset` is a ref-counted asset registry with metadata and search. It tracks
paths and type classification (not decoded GPU/audio resources), supports tags and
groups, and exposes query helpers for scripts.

## General Info

- Module group: `Feature Systems`
- Source path: `src/asset/`
- Lua API path(s): `src/lua_api/asset_api.rs`
- Primary Lua namespace: `lurek.asset`
- Rust test path(s): tests/rust/unit/asset_tests.rs
- Lua test path(s): tests/lua/unit/test_asset_core_unit.lua

## Summary

The module is intentionally lightweight: it stores entry metadata and file source
content for text-like assets, while delegating decoded runtime objects to domain
modules (`lurek.image`, `lurek.font`, `lurek.audio`).

Supported asset types:

- Binary/path-only: `image`, `font`, `audio`, `music`
- Text-like/in-memory source: `text`, `toml`, `json`, `obj`, `shader`, `lua`

Each entry can have:

- display name (`name`)
- group (`group`)
- tags (`tags[]`)

Search APIs return arrays of `LAssetHandle`:

- `findByName`
- `findByGroup`
- `findByTag`
- `findByType`

## Files

- `cache.rs`: Ref-counted asset cache for `lurek.asset`.
- `mod.rs`: `lurek.asset` — ref-counted media cache for images, fonts, audio, and text assets.

## Source Documentation

### `cache.rs`
- Ref-counted asset cache for `lurek.asset`.
- ## Responsibilities
- `AssetCache` is the sole owner of all registered game-asset entries.
- It provides:
- Unique `u64` handle IDs for each registered entry.
- Reference counting: entries are removed when their ref count reaches zero.
- Optional display names, group labels, and tag sets per entry.
- Query methods: find entries by name substring, exact group, exact tag, or type string.
- ## Asset types
- | Type string | Storage          | `get()` resolution                    |
- |-------------|------------------|---------------------------------------|
- | `image`     | path ref         | `lurek.image.loadImage(path)`         |
- | `font`      | path ref         | `lurek.font.load(path, 16)`           |
- | `audio`     | path ref         | `lurek.audio.newSource(path)`         |
- | `music`     | path ref         | `lurek.audio.newSource(path)`         |
- | `text`      | cached text      | returns content string directly       |
- | `toml`      | cached text      | returns raw TOML string               |
- | `json`      | cached text      | returns raw JSON string               |
- | `obj`       | cached text      | returns raw OBJ geometry string       |
- | `shader`    | cached text      | returns shader source string          |
- | `lua`       | cached text      | returns Lua source string             |
- ## Design notes
- The cache is a plain in-process store — it records *where* an asset lives on disk
- and *how it is classified*, not the decoded GPU resource itself. Decoded resources
- (textures, fonts, audio sources) are owned by the respective `lurek.*` sub-modules;
- `lurek.asset` is the lightweight registry and search layer.
- One cache instance is created per Lua VM during `asset_api::register()`.
- Worker VMs created by `lurek.thread` each get their own independent cache.

### `mod.rs`
- `lurek.asset` — ref-counted media cache for images, fonts, audio, and text assets.
- Asset registry module for `lurek.asset`.
- Re-exports [`AssetCache`], [`AssetEntry`], and [`AssetType`] from
- `cache.rs`.  All business logic lives in `cache.rs`; `asset_api.rs`
- contains only the thin Lua bindings.

## Types

- `AssetType` (`enum`, `cache.rs`): type discriminant for registry behavior.
- `AssetEntry` (`struct`, `cache.rs`): one registered entry (path/type/refcount/name/group/tags/content).
- `AssetCache` (`struct`, `cache.rs`): ID-keyed map with ref counting and search helpers.

## Functions

- `AssetType::from_type_str` (`cache.rs`): Parses the Lua-facing lowercase type string into the matching variant.
- `AssetType::is_text_like` (`cache.rs`): Returns `true` when the type stores its content as in-process text.
- `AssetType::as_str` (`cache.rs`): Returns the canonical lowercase string used in stats tables and Lua-side queries.
- `AssetCache::new` (`cache.rs`): Creates an empty cache with the ID counter starting at `1`.
- `AssetCache::register` (`cache.rs`): Registers a new entry and returns its unique handle ID.
- `AssetCache::inc_ref` (`cache.rs`): Increments the ref count for `id`.
- `AssetCache::dec_ref` (`cache.rs`): Decrements the ref count for `id`; removes the entry when it reaches zero.
- `AssetCache::get` (`cache.rs`): Returns a reference to the entry with the given ID, or `None`.
- `AssetCache::set_name` (`cache.rs`): Sets the display name for the entry with the given ID.
- `AssetCache::set_group` (`cache.rs`): Sets the group label for the entry with the given ID.
- `AssetCache::add_tag` (`cache.rs`): Adds `tag` to the tag set of the entry with the given ID.
- `AssetCache::remove_tag` (`cache.rs`): Removes `tag` from the tag set of the entry with the given ID.
- `AssetCache::has_tag` (`cache.rs`): Returns `true` when the entry with the given ID has the given tag.
- `AssetCache::ref_count` (`cache.rs`): Returns the current ref count for `id`, or `0` when not present.
- `AssetCache::is_loaded` (`cache.rs`): Returns `true` if `id` is still present in the cache.
- `AssetCache::loaded_count` (`cache.rs`): Total number of live entries.
- `AssetCache::total_refs` (`cache.rs`): Sum of all ref counts across all live entries.
- `AssetCache::find_by_name` (`cache.rs`): Returns all IDs whose display name contains `substr` (case-insensitive).
- `AssetCache::find_by_group` (`cache.rs`): Returns all IDs whose group label exactly matches `group`.
- `AssetCache::find_by_tag` (`cache.rs`): Returns all IDs that have `tag` in their tag set.
- `AssetCache::find_by_type` (`cache.rs`): Returns all IDs whose asset type string matches `type_str` exactly.
- `AssetCache::unique_groups` (`cache.rs`): Returns all unique group labels currently in the cache (sorted).
- `AssetCache::clear` (`cache.rs`): Removes all entries from the cache, regardless of ref counts.
- `AssetCache::iter` (`cache.rs`): Returns an iterator over all `(id, entry)` pairs.

## Lua API Reference

- Binding path(s): `src/lua_api/asset_api.rs`
- Namespace: `lurek.asset`

### Module Functions
- `lurek.asset.load`: Loads and caches an asset by path and type, returning a ref-counted handle.
- `lurek.asset.unload`: Decrements the ref count for a cached asset; removes the entry when it reaches zero.
- `lurek.asset.get`: Returns the underlying asset value for a cached handle.
- `lurek.asset.preload`: Synchronously loads a batch of assets and fires `callback(loaded, total)` after each item.
- `lurek.asset.refcount`: Returns the current ref count for a handle, or 0 when it is no longer loaded.
- `lurek.asset.isLoaded`: Returns true when the asset for the given handle is still in the cache.
- `lurek.asset.stats`: Returns a snapshot table describing the current cache state.
- `lurek.asset.clear`: Removes all entries from the cache immediately, regardless of ref counts.
- `lurek.asset.getPath`: Returns the filesystem path for the asset associated with a handle.
- `lurek.asset.getType`: Returns the type string for the asset associated with a handle.
- `lurek.asset.getInfo`: Returns a table containing all metadata for an asset handle.
- `lurek.asset.setName`: Sets the display name for an asset handle.
- `lurek.asset.getName`: Returns the display name of an asset handle.
- `lurek.asset.setGroup`: Assigns an asset handle to a named group.
- `lurek.asset.getGroup`: Returns the group label for an asset handle.
- `lurek.asset.addTag`: Adds a tag to the tag set of an asset handle.
- `lurek.asset.removeTag`: Removes a tag from the tag set of an asset handle.
- `lurek.asset.getTags`: Returns an array of all tags for an asset handle.
- `lurek.asset.hasTag`: Returns true when an asset handle has the given tag in its tag set.
- `lurek.asset.findByName`: Returns an array of asset handles whose display name contains the substring.
- `lurek.asset.findByGroup`: Returns an array of asset handles whose group label exactly matches `group`.
- `lurek.asset.findByTag`: Returns an array of asset handles that have the given tag in their tag set.
- `lurek.asset.findByType`: Returns an array of asset handles whose type exactly matches `type_str`.

### `LAssetHandle` Methods
- `LAssetHandle:type`: Returns the Lua-visible type name for this asset handle.
- `LAssetHandle:typeOf`: Returns whether this handle matches a supported type name.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- Cache scope is per Lua VM.
- `preload` is synchronous.
- Ref counting is manual (`unload`/`clear`); Lua variable drop does not decrement.
- The module does not replace `lurek.image`, `lurek.font`, `lurek.audio`, or `lurek.sprite`.
