# filesystem manual spec overlay

## TL;DR

- Sandboxes path resolution, mount overlays, and ZIP archives.
- Supports file streams, asynchronous I/O, and poll watchers.

## Summary

- The `filesystem` module is the sandboxed storage surface for users who need file access without giving every script raw platform path power.
- Path normalization, traversal checks, mounts, archive access, synchronous handles, and asynchronous IO combine into one controlled runtime view of storage.
- That matters because asset lookup, save data, mod content, hot reload, and tooling workflows all need file access, but they should not each invent their own safety and path rules.
- Watchers, metadata queries, recursive listing, and convenience helpers make the module useful for diagnostics and content tooling as well as for normal gameplay persistence.
- Mount and archive support are especially important because real projects often mix loose files, packaged assets, save locations, and mod roots under one conceptual storage view.
- The sandboxed design is the key policy boundary: `filesystem` exists so scripts can do meaningful file work while the engine still controls what paths are valid, portable, and safe to expose.
- Async reads and watch-style helpers also make the module practical for hot-reload and content-iteration workflows where storage changes need to become observable runtime events.
- Read `filesystem` as the place where storage becomes safe, portable, and composable for the rest of the engine.

This module primarily collaborates with `dataframe`, `runtime`. Its responsibility should stay inside the Core Runtime group rather than absorb behavior owned by those neighbors.

## Notes

- `mountZip` currently returns a standalone `LZipMount` handle. Directory `mount(...)` participates in GameFS reads and listings; `mountZip(...)` does not.

## Architecture Links

- Intentionally empty.
