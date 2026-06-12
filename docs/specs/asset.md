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
- Lua test path(s): tests/lua_reorg/unit/test_asset_core_unit.lua

## Summary

- The asset module provides shared, ref-counted resource lifetime management for scripts and runtime systems.
- Stable handles prevent duplicate loads and make ownership explicit across subsystems.
- Metadata supports naming, grouping, and tagging for structured content management.
- Query helpers support lookup by name fragment, type, tag, and group.
- Batch preload paths support startup and streaming workflows.
- Ref-counted unload behavior removes entries only when the last user releases them.
- Cache identity and discovery are centralized here for predictable sharing.
- Decoding and rendering stay in feature-specific modules instead of the cache layer.

This module is mostly self-contained inside the `Feature Systems` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Files

### cache.rs

- Implements a reference-counted asset registry for tracking media lifecycle across runtime systems.
- Stores normalized metadata, optional text payloads, and ownership counters for shared access.
- Separates cache bookkeeping from decoded resource ownership handled by feature-specific modules.
- Supports acquisition, release, and eviction decisions through explicit handle lifecycle updates.
- Provides metadata and tag-query surfaces for tooling, filtering, and runtime introspection.
- Preserves deterministic cache semantics so repeated asset flow remains predictable.
- Serves as the core state container behind the engine-facing `lurek.asset` behavior.

### mod.rs

- Defines the top-level asset module boundary for cache-backed media lifecycle management.
- Exposes shared cache contracts while concentrating concrete registry behavior in the cache layer.
- Serves as the composition entry for engine-side `lurek.asset` state and operations.

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
