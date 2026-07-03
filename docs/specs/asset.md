<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/asset.md or source docstrings instead. -->

# asset

## TL;DR

- Caches, tags, and queries reference-counted asset handles.

## General Info

- Module group: `Feature Systems`
- Source path: `src/asset`
- Binding: `src/lua_api/asset_api.rs`
- Namespace: `lurek.asset`
- Lua API surface: `29` functions, `3` types, `2` methods
- User-facing: `true`
- Plugin tier: `not_evaluated`

## Summary

- The `asset` module is the shared runtime catalog for loaded resources, so users can work with stable handles instead of repeatedly reopening raw file paths.
- Its core value is lifecycle control: the cache keeps assets deduplicated, reference counted, and discoverable by name, group, and tag.
- Preload and lookup features keep it useful during startup setup, content pipelines, and diagnostics because the same module can answer what is loaded and what should stay alive.
- Read it as the ownership layer for resource identity and retention. Neighboring modules still decide how loaded resources are consumed.

This module is mostly self-contained inside the `Feature Systems` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Ownership

- Canonical source: `src/asset`
- Owning tier: `Feature Systems`
- Plugin tier: `not_evaluated`
- Lua binding owner: `src/lua_api/asset_api.rs`
- Referenced engine modules: None detected from Rust imports.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Source Files

### cache.rs

- Owns the asset cache implementation for the asset subsystem and keeps related runtime rules local here.
- Keeps asset caches, loading state, and lookup helpers ownership so helpers stay close to invariants this file updates.
- Defines how asset cache data is validated, transformed, or stored before neighboring systems consume it.
- Separates asset cache behavior from Lua bindings, tests, and sibling owners so integration stays readable.
- Documents the boundary where asset code accepts inputs, reports errors, allocates state, or emits outputs.
- Use this file when changing asset cache defaults, lifecycle handling, validation, or data ownership rules.
- Keeps failure paths and edge cases near the asset cache state that explains them instead of spreading rules outward.
- Preserves deterministic behavior by keeping asset cache calculations explicit at their owning subsystem boundary.

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
- `lurek.asset.getRevision(handle) -> integer`: Returns the current reload revision for an asset handle.
- `lurek.asset.getTags(handle) -> table`: Returns an array of all tags for an asset handle.
- `lurek.asset.getType(handle) -> string`: Returns the type string for the asset associated with a handle.
- `lurek.asset.hasTag(handle, tag) -> boolean`: Returns true when an asset handle has the given tag in its tag set.
- `lurek.asset.isLoaded(handle) -> boolean`: Returns true when the asset for the given handle is still in the cache.
- `lurek.asset.load(path, asset_type, opts?) -> LAssetHandle`: Loads and caches an asset by path and type, returning a ref-counted handle.
- `lurek.asset.loadManifest(path) -> table`: Loads a TOML asset manifest and registers listed assets without transforming them.
- `lurek.asset.onReload(handle, callback) -> nil`: Registers a callback fired by `lurek.asset.reload(handle)`.
- `lurek.asset.preload(paths, callback) -> nil`: Synchronously loads a batch of assets and fires `callback(loaded, total)` after each item.
- `lurek.asset.refcount(handle) -> integer`: Returns the current ref count for a handle, or 0 when it is no longer loaded.
- `lurek.asset.reload(handle) -> integer`: Reloads the cached asset metadata/content and increments its revision.
- `lurek.asset.removeTag(handle, tag) -> boolean`: Removes a tag from the tag set of an asset handle.
- `lurek.asset.resolve(handle) -> table`: Returns a metadata snapshot for an asset handle without transforming the asset data.
- `lurek.asset.setGroup(handle, group) -> nil`: Assigns an asset handle to a named group.
- `lurek.asset.setName(handle, name) -> nil`: Sets the display name for an asset handle.
- `lurek.asset.stats() -> table`: Returns a snapshot table describing the current cache state.
- `lurek.asset.unload(handle) -> nil`: Decrements the ref count for a cached asset; removes the entry when it reaches zero.
- `lurek.asset.watch(handle_or_path, asset_type?) -> LAssetHandle`: Marks an asset handle or path as watched for live reload.

### Callbacks

- `lurek.asset.onReload` param `callback` (`function`): Called as `callback(handle, revision)`. Invocation: `callback(handle, revision)`.

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
- `revision` (`integer`): Reload revision.
- `tags` (`table`): Array of tag strings.
- `type` (`string`): Asset type string.
- `watched` (`boolean`): True when live reload watching is requested.

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

## Examples

- `content/examples/asset.lua` (present)

## Architecture Links

- Intentionally empty.

## Notes

- No additional module-specific notes.
