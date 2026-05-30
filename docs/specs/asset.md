# asset

## TL;DR

- The `asset` module is a shared asset registry with ref counts, metadata, tags, and search helpers, so scripts can find and manage assets without owning decode logic.

## General Info

- Module group: `Feature Systems`
- Source path: `src/asset/`
- Binding: `src/lua_api/asset_api.rs`
- Namespace: `lurek.asset`
- Lua API surface: `23` functions, `3` types, `2` methods
- Rust test path(s): tests/rust/unit/asset_tests.rs
- Lua test path(s): tests/lua/unit/test_asset_core_unit.lua

## Summary

The `asset` module provides one shared catalog for asset identity and lifetime. It lets the runtime load entries, keep reference counts, and expose stable handles to scripts. This gives projects a predictable way to track what is currently in use.

Its functional focus is discovery and metadata, not heavy decoding. The module tracks path, type, group, tags, display name, and reference state, then offers query helpers to search by those fields. This removes repeated ad-hoc indexing logic from gameplay scripts and tools.

Because ref counts are first-class, asset ownership is easier to reason about. Systems can acquire and release handles without guessing when data should be removed. The cache can report stats and loaded state, which improves runtime visibility during development and debugging.

The module is designed as a lightweight coordination layer. Type-specific decode and playback responsibilities stay in specialized modules, while `asset` remains the place for lookup contracts and lifecycle bookkeeping. This keeps integration clean and reduces coupling.

In day-to-day use, the value is consistency: one way to load, label, group, tag, find, and unload assets across a project. That consistency helps both game code and tooling stay simpler as content size grows.

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

- `lurek.asset.addTag`: Adds a tag to the tag set of an asset handle.
- `lurek.asset.clear`: Removes all entries from the cache immediately, regardless of ref counts.
- `lurek.asset.findByGroup`: Returns an array of asset handles whose group label exactly matches `group`.
- `lurek.asset.findByName`: Returns an array of asset handles whose display name contains the substring.
- `lurek.asset.findByTag`: Returns an array of asset handles that have the given tag in their tag set.
- `lurek.asset.findByType`: Returns an array of asset handles whose type exactly matches `type_str`.
- `lurek.asset.get`: Returns the underlying asset value for a cached handle.
- `lurek.asset.getGroup`: Returns the group label for an asset handle.
- `lurek.asset.getInfo`: Returns a table containing all metadata for an asset handle.
- `lurek.asset.getName`: Returns the display name of an asset handle.
- `lurek.asset.getPath`: Returns the filesystem path for the asset associated with a handle.
- `lurek.asset.getTags`: Returns an array of all tags for an asset handle.
- `lurek.asset.getType`: Returns the type string for the asset associated with a handle.
- `lurek.asset.hasTag`: Returns true when an asset handle has the given tag in its tag set.
- `lurek.asset.isLoaded`: Returns true when the asset for the given handle is still in the cache.
- `lurek.asset.load`: Loads and caches an asset by path and type, returning a ref-counted handle.
- `lurek.asset.preload`: Synchronously loads a batch of assets and fires `callback(loaded, total)` after each item.
- `lurek.asset.refcount`: Returns the current ref count for a handle, or 0 when it is no longer loaded.
- `lurek.asset.removeTag`: Removes a tag from the tag set of an asset handle.
- `lurek.asset.setGroup`: Assigns an asset handle to a named group.
- `lurek.asset.setName`: Sets the display name for an asset handle.
- `lurek.asset.stats`: Returns a snapshot table describing the current cache state.
- `lurek.asset.unload`: Decrements the ref count for a cached asset; removes the entry when it reaches zero.

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

- `LAssetHandle:type`: Returns the Lua-visible type name for this asset handle.
- `LAssetHandle:typeOf`: Returns whether this handle matches a supported type name.

#### LAssetStatsResult Type

- Generated result shape from @field tags.

##### Fields

- `groups` (`table`): Sorted array of unique group labels in the cache.
- `loaded` (`integer`): Number of distinct assets currently cached.
- `total_refs` (`integer`): Sum of all ref counts across all cached assets.
- `types` (`table`): Per-type entry counts keyed by type string.

##### Methods

- No documented methods.
