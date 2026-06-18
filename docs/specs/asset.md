# asset

## TL;DR

- Caches, tags, and queries reference-counted asset handles.

## General Info

- Module group: `Feature Systems`
- Source path: `src/asset/`
- Binding: `src/lua_api/asset_api.rs`
- Namespace: `lurek.asset`
- Lua API surface: `23` functions, `3` types, `2` methods
- Rust test path(s): tests/rust/unit/asset_tests.rs
- Lua test path(s): tests/lua/unit/test_asset_unit.lua

## Summary

- The `asset` module is the shared runtime catalog for loaded resources, so users can work with stable handles instead of repeatedly reopening raw file paths.
- Its core value is lifecycle control: the cache keeps assets deduplicated, reference counted, and discoverable by name, group, and tag, which makes reuse explicit across gameplay systems and tools.
- Preload and lookup features turn it into more than a passive cache, because startup setup, content pipelines, and diagnostic scripts can all ask the same module what is loaded and what should stay alive.
- Read it as the ownership layer for resource identity and retention. Neighboring modules still decide how loaded resources are consumed.


## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Files

### cache.rs

- `src/asset/cache.rs` owns ref-counted asset bookkeeping, including registration, lookup, tagging, and eviction.
- It defines `AssetType`, `AssetEntry`, and `AssetCache`, keeping asset identity and lifecycle under one owner.
- Normalized path keys live here so repeated registrations of the same typed asset resolve to one shared cache entry.
- Reference increments, decrements, and zero-count removal are handled here, keeping lifetime behavior explicit.
- Search helpers for names, groups, tags, and types also live here, giving tools and runtime systems one query surface.
- Text-like assets may retain source content in memory here, while binary assets keep only path and metadata references.
- Open this file when asset identity, retention policy, cache queries, or metadata semantics need engine-wide changes.

### mod.rs

- `src/asset/mod.rs` is the asset module index, exposing the cache surface used to track media lifetimes.
- It reexports `AssetCache`, `AssetEntry`, and `AssetType` so callers reach asset bookkeeping through one boundary.
- No runtime cache state lives here; this file defines visibility while concrete asset lifecycle rules stay in `cache.rs`.
- Read this index when wiring asset features, because it shows which cache contracts are intentionally public and shared.
- Changes here alter the asset boundary, since reexports decide what runtime systems and bindings may import directly.
- This module keeps media lifecycle ownership separate from loaders, decoders, and subsystem-specific resources.



## Lua API Ref

### Functions

- `lurek.asset.addTag(handle, tag) -> nil`: Adds a tag to the tag set of an asset handle.
- `lurek.asset.clear() -> nil`: Removes all entries from the cache immediately, regardless of ref counts.
- `lurek.asset.findByGroup(group) -> table`: Returns an array of asset handles whose group label exactly matches `group`.
- `lurek.asset.findByName(substr) -> table`: Returns an array of asset handles whose display name contains the substring.
- `lurek.asset.findByTag(tag) -> table`: Returns an array of asset handles that have the given tag in their tag set.
- `lurek.asset.findByType(type_str) -> table`: Returns an array of asset handles whose type exactly matches `type_str`.
- `lurek.asset.get(handle) -> string`: Returns the underlying asset value for a cached handle.
- `lurek.asset.getGroup(handle) -> string`: Returns the group label for an asset handle.
- `lurek.asset.getInfo(handle) -> table`: Returns a table containing all metadata for an asset handle.
- `lurek.asset.getName(handle) -> string`: Returns the display name of an asset handle.
- `lurek.asset.getPath(handle) -> string`: Returns the filesystem path for the asset associated with a handle.
- `lurek.asset.getTags(handle) -> table`: Returns an array of all tags for an asset handle.
- `lurek.asset.getType(handle) -> string`: Returns the type string for the asset associated with a handle.
- `lurek.asset.hasTag(handle, tag) -> boolean`: Returns true when an asset handle has the given tag in its tag set.
- `lurek.asset.isLoaded(handle) -> boolean`: Returns true when the asset for the given handle is still in the cache.
- `lurek.asset.load(path, asset_type, opts?) -> LAssetHandle`: Loads and caches an asset by path and type, returning a ref-counted handle.
- `lurek.asset.preload(paths, callback) -> nil`: Synchronously loads a batch of assets and fires `callback(loaded, total)` after each item.
- `lurek.asset.refcount(handle) -> integer`: Returns the current ref count for a handle, or 0 when it is no longer loaded.
- `lurek.asset.removeTag(handle, tag) -> boolean`: Removes a tag from the tag set of an asset handle.
- `lurek.asset.setGroup(handle, group) -> nil`: Assigns an asset handle to a named group.
- `lurek.asset.setName(handle, name) -> nil`: Sets the display name for an asset handle.
- `lurek.asset.stats() -> table`: Returns a snapshot table describing the current cache state.
- `lurek.asset.unload(handle) -> nil`: Decrements the ref count for a cached asset; removes the entry when it reaches zero.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LAssetGetInfoResult Type

- Generated result shape from @field tags.

##### Fields

- `group` (`string`): Group label, or empty string when none is set.
- `name` (`string`): Display name, or the path file-stem when none is set.
- `path` (`string`): Filesystem path to the asset.
- `refcount` (`integer`): Current reference count.
- `tags` (`table`): Array of tag strings.
- `type` (`string`): Asset type string.

##### Methods

- No documented methods.

#### LAssetHandle Type

- Lua-side handle for a single cached asset entry.

##### Fields

- No documented fields.

##### Methods

- `LAssetHandle:type() -> string`: Returns the Lua-visible type name for this asset handle.
- `LAssetHandle:typeOf(name) -> boolean`: Returns whether this handle matches a supported type name.

#### LAssetStatsResult Type

- Generated result shape from @field tags.

##### Fields

- `groups` (`table`): Sorted array of unique group labels in the cache.
- `loaded` (`integer`): Number of distinct assets currently cached.
- `total_refs` (`integer`): Sum of all ref counts across all cached assets.
- `types` (`table`): Per-type entry counts keyed by type string.

##### Methods

- No documented methods.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- No additional module-specific notes.
