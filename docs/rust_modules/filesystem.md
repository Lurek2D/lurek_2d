# filesystem

## General Info

- Module group: `Core Runtime`
- Source path: `src/filesystem/`
- Binding: `src/lua_api/filesystem_api.rs`
- Namespace: `lurek.filesystem`
- Lua API surface: `44` functions, `5` types, `23` methods
- Rust test path(s): tests/rust/unit/filesystem_tests.rs
- Lua test path(s): tests/lua/unit/test_filesystem_core_unit.lua, tests/lua/stress/test_filesystem_stress.lua

## Summary

This module provides virtual filesystem services, sandboxing file access to game directories. It coordinates path resolution, file operations, and virtual mounts, ensuring scripting layers interact with files safely. Normalising paths across systems guarantees consistent cross-platform behavior for all read, write, and directory workflows.

To support asset loading, the system features virtual overlays. It mounts directories or ZIP archives under virtual prefixes, building lookup indexes to read archive files on demand without full extraction. This lets the engine resolve assets across folders dynamically, simplifying modding support and content overrides.

I/O operations support both synchronous streams and non-blocking asynchronous requests. The async loader delegates tasks to a dedicated worker thread, allowing the engine to transfer files without main-thread stalls. Buffered handles support mode-aware reading, writing, seeking, and appending for predictable stream control.

Additionally, a poll-based file watcher tracks modification timestamps. This detects file changes on demand, serving as the foundation for hot-reloading configurations and assets. The virtual filesystem layer also provides JSON serialization, temporary file creation, and directory metadata inspection.

## Files

### [async_loader.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/filesystem/async_loader.rs)

- Provides background file I/O through a dedicated worker thread and bounded request channel.
- Supports non-blocking read and write scheduling with opaque handles for later status polling.
- Stores results in thread-safe maps so callers can retrieve outcomes without blocking producers.
- Enforces queue capacity limits to keep memory and scheduling pressure under control.
- Handles worker lifecycle shutdown cleanly when the loader is dropped.
- Delivers asynchronous file transfer behavior for systems that must avoid main-thread stalls.

### [file_data.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/filesystem/file_data.rs)

- Provides a lightweight file payload container pairing logical paths with loaded raw bytes.
- Exposes basic size, emptiness, and UTF-8 decode helpers for convenient caller-side consumption.
- Delivers the shared data object returned by filesystem read operations.

### [file_handle.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/filesystem/file_handle.rs)

- Provides buffered file-handle behavior for mode-aware read, write, and append stream operations.
- Resolves logical game paths through GameFS before touching host filesystem resources.
- Exposes byte and line reading utilities with EOF-aware iteration semantics.
- Supports seek, tell, flush, and explicit close workflows for predictable stream control.
- Enforces access-mode checks so invalid operation mixes fail with clear runtime errors.
- Delivers safe per-file I/O primitives used by script APIs and engine persistence code.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/filesystem/mod.rs)

- Provides the high-level filesystem module boundary for virtual mounts, async loading, and file handle access.
- Connects path resolution, buffered I/O, watch support, and archive overlays into one storage surface.
- Delivers the core file-service layer used by runtime systems and script-facing persistence flows.

### [vfs.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/filesystem/vfs.rs)

- Provides the core virtual filesystem implementation rooted at a game directory and save space.
- Resolves read and write paths through mount overlays and base-root fallback rules.
- Enforces traversal rejection and write confinement to preserve sandboxed filesystem behavior.
- Exposes metadata, glob, list, copy, move, and removal operations under one coherent API.
- Supports layered directory and archive mounts with deterministic conflict resolution order.
- Builds file-handle and async-loader integration points over canonical resolved paths.
- Includes JSON helpers and temporary file utilities for common content and tooling workflows.
- Normalizes separators and path shapes to keep behavior stable across desktop platforms.
- Keeps mount metadata explicit so runtime systems can inspect and reason about storage topology.
- Delivers the authoritative storage-routing layer consumed by higher-level filesystem services.

### [watcher.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/filesystem/watcher.rs)

- Provides poll-based file watch behavior that detects mtime changes for registered paths.
- Maintains cached modification snapshots and reports deterministic change sets per poll cycle.
- Supports watch, unwatch, and forced invalidation workflows for runtime refresh control.
- Delivers a lightweight change-detection utility for assets and config reload pipelines.

### [zip_mount.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/filesystem/zip_mount.rs)

- Provides ZIP-backed virtual mount behavior that maps normalized virtual paths to archive entries.
- Builds an index for fast repeated lookups while reading files on demand without full extraction.
- Enforces traversal-safe path handling before archive access to maintain sandbox guarantees.
- Supports listing and existence checks over mounted archive content through a unified interface.
- Delivers archive overlay functionality used by the virtual filesystem mount stack.
