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

It provides the essential abstraction layer between Lua game scripts and the host operating system, ensuring that all file I/O is secure. By confining operations to a designated base game directory and a specific user save directory, `GameFS` actively prevents path-traversal attacks. It intercepts and validates every path component, rejecting any attempts to use `..`, symbolic links, or absolute prefixes that point outside the allowed security boundary. Violations immediately trigger an `EngineError::FsPathTraversal`.

Beyond security, the module offers a robust suite of filesystem operations. It supports synchronous and asynchronous file reads/writes, directory creation, flat and recursive listing, glob matching, and file copy/move operations. A notable feature is its support for virtual mount overlays: directories or read-only `.zip` archives (`ZipMount`) can be layered into the virtual filesystem at specified prefixes. When a file is requested, `GameFS` queries these layered mounts seamlessly, enabling modding, content patching, and asset packing without altering game logic.

To prevent blocking the main engine thread during expensive I/O operations, the module includes an `AsyncLoader`. This loader dispatches read and write requests to a dedicated background worker thread, returning opaque handles that scripts can poll for completion. For fine-grained file manipulation, `FileHandle` provides a buffered, cursor-based streaming API with discrete read, write, and append modes. Additionally, for hot-reload development workflows, a poll-based `FileWatcher` tracks modification-time (`mtime`) changes across registered paths, enabling real-time asset updates. The full functionality of the virtual filesystem, including JSON validation helpers and file metadata queries, is exposed to scripts via the `lurek.filesystem.*` API.

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
