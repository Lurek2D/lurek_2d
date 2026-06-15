# Asset

## Summary

- The asset module provides a ref-counted cache for shared runtime resources and source files.
- Repeated loads of the same normalized path and asset type reuse one cache entry and increment its reference count.
- Metadata fields support naming, grouping, and tagging for discovery and batch-oriented workflows.
- Query helpers expose lookup by name fragment, group, tag, and asset type.
- Text-like assets cache file contents directly, while binary assets defer decoding to their feature-specific modules.

This module is mostly self-contained inside the `Feature Systems` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Key Functions

### `lurek.asset.load`

Loads and caches an asset by path and type, returning a ref-counted handle.

```lua
lurek.asset.load(path, asset_type, opts)
```

### `lurek.asset.get`

Returns cached text content or resolves the runtime object for binary assets.

```lua
lurek.asset.get(handle)
```

### `lurek.asset.unload`

Decrements a handle reference count and evicts the cache entry when the last reference is released.

```lua
lurek.asset.unload(handle)
```

### `lurek.asset.stats`

Returns aggregate cache information, including loaded entries, total refs, per-type counts, and unique groups.

```lua
lurek.asset.stats()
```
