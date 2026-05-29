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

The `asset` module is a ref-counted registry and query surface for media handles and text-like source payloads exposed as `lurek.asset`. It is deliberately narrower than loaders in rendering or audio: it tracks identity, metadata, lifecycle, and lookups, while decode-specific runtime objects remain owned by domain modules such as `image`, `font`, and `audio`.

Core responsibilities are stable indexing and retrieval by name, group, tag, and type, plus consistent handle semantics for Lua and engine-side callers. `AssetCache` stores `AssetEntry` records with descriptive metadata and source affiliation so scripts can discover assets without duplicating path rules or ad-hoc indexing logic.

The design goal is a lightweight catalog layer, not a universal transcoder. Binary-heavy types (images, fonts, sounds) are primarily represented by handle/path metadata in this module, while text-like assets can retain source content when needed for script tooling and hot-reload workflows. This separation keeps the module performant and avoids tight coupling to decoder internals.

In practical usage, `asset` is the lookup and lifetime contract that other systems depend on. High-level gameplay code should query and resolve through this registry, then hand off to module-specific loaders for final decode/playback/render behavior.

## Files

### cache.rs

- Ref-counted asset registry used by `lurek.asset`.
- `AssetCache` stores asset metadata, optional text payload, and reference counts.
- Decoded runtime resources remain owned by feature modules such as image, font, and audio.
- This module provides load bookkeeping, metadata/tag queries, and handle lifecycle helpers.

### mod.rs

- `lurek.asset` — ref-counted media cache for images, fonts, audio, and text assets.
- Asset registry module for `lurek.asset`.
- Re-exports [`AssetCache`], [`AssetEntry`], and [`AssetType`] from
- `cache.rs`.  All business logic lives in `cache.rs`; `asset_api.rs`
- contains only the thin Lua bindings.

## Lua API Ref

- Binding: `src/lua_api/asset_api.rs`
- Namespace: `lurek.asset`

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

### Enums

- No documented module-level enums/constants.

### Types


#### LAssetHandle Type


##### Fields

- No documented fields.

##### Methods

- `LAssetHandle:type`: Returns the Lua-visible type name for this asset handle.
- `LAssetHandle:typeOf`: Returns whether this handle matches a supported type name.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.
