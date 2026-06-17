# filesystem

## TL;DR

- Sandboxes path resolution, mount overlays, and ZIP archives.
- Supports file streams, asynchronous I/O, and poll watchers.

## General Info

- Module group: `Core Runtime`
- Source path: `src/filesystem/`
- Binding: `src/lua_api/filesystem_api.rs`
- Namespace: `lurek.filesystem`
- Lua API surface: `44` functions, `5` types, `23` methods
- Rust test path(s): tests/rust/unit/filesystem_tests.rs
- Lua test path(s): tests/lua/unit/test_filesystem_core_unit.lua, tests/lua/stress/test_filesystem_stress.lua

## Summary

- This module gives users a sandboxed file service that keeps script I/O inside controlled game paths.
- Path normalization and traversal checks help keep behavior consistent and safe across desktop platforms.
- Virtual mount support lets teams overlay directories under logical prefixes, while ZIP mounts remain standalone handle-based archive views.
- This is useful for mods, DLC-style content packs, and environment-specific asset overrides.
- ZIP archive handles read files on demand without promising full GameFS overlay integration.
- Sync file handles support common stream patterns such as read, write, append, seek, and line iteration.
- Async read/write operations move heavy transfer work off the main thread.
- Poll-based watcher features enable hot-reload loops for assets and config updates.
- JSON helpers and temporary file utilities reduce boilerplate in tooling scripts.
- Metadata and recursive listing APIs support content indexing and diagnostics.
- Mount introspection helps users reason about effective storage topology at runtime.
- The module unifies persistence, asset lookup, and automation-friendly file access in one namespace.
- For users, this means fewer custom path hacks and fewer platform-specific surprises.
- It supports both gameplay persistence and build/test tooling workflows.
- Overall, it is the core storage abstraction for safe and flexible runtime file operations.

This module primarily collaborates with `dataframe`, `runtime`. Its responsibility should stay inside the Core Runtime group rather than absorb behavior owned by those neighbors.

## Imports

- `dataframe`: Imports or references `src/dataframe/`. Cross-group dependency from `Core Runtime` into `Foundations`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### async_loader.rs

- Provides background file I/O through a dedicated worker thread and bounded request channel. `filesystem/async_loader` delivers the async loader implementation for the filesystem subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Supports non-blocking read and write scheduling with opaque handles for later status polling. The file owns or coordinates data contracts including `LoadHandle`, `LoadResult`, `LoadStatus`, `WriteResult`, `WriteStatus`, and 1 more, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Stores results in thread-safe maps so callers can retrieve outcomes without blocking producers. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `request_load`, `request_write`, `poll`, `pending_results`, `poll_write` stays attached to the local data model and invariants.
- Enforces queue capacity limits to keep memory and scheduling pressure under control. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Handles worker lifecycle shutdown cleanly when the loader is dropped. External integration uses `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### file_data.rs

- Provides a lightweight file payload container pairing logical paths with loaded raw bytes. `filesystem/file_data` delivers the file data implementation for the filesystem subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Exposes basic size, emptiness, and UTF-8 decode helpers for convenient caller-side consumption. The file owns or coordinates data contracts including `FileData`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Delivers the shared data object returned by filesystem read operations. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `len`, `is_empty`, `as_str` stays attached to the local data model and invariants.

### file_handle.rs

- Provides buffered file-handle behavior for mode-aware read, write, and append stream operations. `filesystem/file_handle` delivers the file handle implementation for the filesystem subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Resolves logical game paths through GameFS before touching host filesystem resources. The file owns or coordinates data contracts including `FileMode`, `FileHandle`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Exposes byte and line reading utilities with EOF-aware iteration semantics. Public callable behavior is centered on no named public items, while method-level behavior such as `parse_mode`, `as_str`, `open`, `read`, `read_line`, `write`, and 8 more stays attached to the local data model and invariants.
- Supports seek, tell, flush, and explicit close workflows for predictable stream control. Runtime integration reaches sibling engine areas through crate modules `filesystem`, `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Enforces access-mode checks so invalid operation mixes fail with clear runtime errors. External integration uses `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### mod.rs

- Provides the high-level filesystem module boundary for virtual mounts, async loading, and file handle access. `filesystem/mod` is the filesystem module index, declaring `async_loader`, `file_data`, `file_handle`, `vfs`, `watcher`, and 1 more so agents can identify which files own each feature slice before opening implementation code.
- Connects path resolution, buffered I/O, watch support, and archive overlays into one storage surface. `src/filesystem/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `async_loader::{AsyncLoader, LoadHandle, LoadResult, LoadStatus, WriteResult, WriteStatus}`, `file_data::FileData`, `file_handle::{FileHandle, FileMode}`, `vfs::{FileInfo, FileType, GameFS, MountLayer}` centralized for the filesystem subsystem.

### vfs.rs

- Provides the core virtual filesystem implementation rooted at a game directory and save space. `filesystem/vfs` delivers the vfs implementation for the filesystem subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Resolves read and write paths through mount overlays and base-root fallback rules. The file owns or coordinates data contracts including `FileInfo`, `FileType`, `MountLayer`, `GameFS`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Enforces traversal rejection and write confinement to preserve sandboxed filesystem behavior. Public callable behavior is centered on no named public items, while method-level behavior such as `as_str`, `new`, `base_dir`, `read_string`, `read_bytes`, `write_string`, and 35 more stays attached to the local data model and invariants.
- Exposes metadata, glob, list, copy, move, and removal operations under one coherent API. Runtime integration reaches sibling engine areas through crate modules `dataframe`, `filesystem`, `log_msg`, `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Supports layered directory and archive mounts with deterministic conflict resolution order. External integration uses `serde_json`, `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Builds file-handle and async-loader integration points over canonical resolved paths. The file boundary separates filesystem implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.

### watcher.rs

- Provides poll-based file watch behavior that detects mtime changes for registered paths. `filesystem/watcher` delivers the watcher implementation for the filesystem subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Maintains cached modification snapshots and reports deterministic change sets per poll cycle. The file owns or coordinates data contracts including `FileWatcher`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Supports watch, unwatch, and forced invalidation workflows for runtime refresh control. Public callable behavior is centered on `read_mtime`, while method-level behavior such as `new`, `watch`, `unwatch`, `is_watching`, `poll`, `len`, and 2 more stays attached to the local data model and invariants.

### zip_mount.rs

- Provides ZIP-backed virtual mount behavior that maps normalized virtual paths to archive entries. `filesystem/zip_mount` delivers the zip mount implementation for the filesystem subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Builds an index for fast repeated lookups while reading files on demand without full extraction. The file owns or coordinates data contracts including `ZipMount`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Enforces traversal-safe path handling before archive access to maintain sandbox guarantees. Public callable behavior is centered on `normalise`, `is_traversal`, while method-level behavior such as `new`, `read_file`, `contains`, `list_files` stays attached to the local data model and invariants.
- Supports listing and existence checks over mounted archive content through a unified interface. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.



## Lua API Ref

### Functions

- `lurek.filesystem.append(path, data) -> nil`: Appends UTF-8 text to a GameFS file.
- `lurek.filesystem.copy(src, dst) -> nil`: Copies one GameFS file to another path.
- `lurek.filesystem.createDirectory(path) -> nil`: Creates a GameFS directory and any missing parents.
- `lurek.filesystem.createTempFile(prefix?) -> string`: Creates a temporary file through GameFS.
- `lurek.filesystem.exists(path) -> boolean`: Returns whether a path exists in GameFS.
- `lurek.filesystem.getDirectoryItems(path) -> string[]`: Lists immediate entries in a GameFS directory.
- `lurek.filesystem.getIdentity() -> string`: Returns the current filesystem identity string.
- `lurek.filesystem.getInfo(path) -> table`: Returns file metadata for a GameFS path when available.
- `lurek.filesystem.getSaveDirectory() -> string`: Returns the save directory path used by GameFS.
- `lurek.filesystem.getSource() -> string`: Returns the GameFS source root string.
- `lurek.filesystem.getUserDirectory() -> string`: Returns the current user's directory path.
- `lurek.filesystem.getWorkingDirectory() -> string`: Returns the process working directory.
- `lurek.filesystem.glob(pattern) -> string[]`: Returns GameFS paths matching a glob pattern.
- `lurek.filesystem.isDirectory(path) -> boolean`: Returns whether a GameFS path is a directory.
- `lurek.filesystem.isFile(path) -> boolean`: Returns whether a GameFS path is a regular file.
- `lurek.filesystem.lines(path) -> function`: Creates an iterator function over lines in a text file.
- `lurek.filesystem.listRecursive(path) -> string[]`: Lists all paths under a GameFS directory recursively.
- `lurek.filesystem.load(path) -> function`: Loads a Lua chunk from GameFS and returns it as a Lua function.
- `lurek.filesystem.mkdir(path) -> nil`: Creates a directory under the GameFS base directory.
- `lurek.filesystem.mount(src, mp) -> boolean`: Mounts an external source path at a GameFS mount point.
- `lurek.filesystem.mountZip(archive_path, prefix) -> LZipMount`: Opens a ZIP archive and exposes it through a virtual prefix.
- `lurek.filesystem.move(src, dst) -> nil`: Moves or renames one GameFS file to another path.
- `lurek.filesystem.newFileData(path) -> LFileData`: Loads a file into an immutable file data handle.
- `lurek.filesystem.openFile(path, mode) -> LFileHandle`: Opens a GameFS file handle in a requested mode.
- `lurek.filesystem.pollAsync(handle_id) -> string`: Polls an asynchronous file load request.
- `lurek.filesystem.pollAsyncWrite(handle_id) -> string`: Polls an asynchronous file write request.
- `lurek.filesystem.pollWatchers() -> string[]`: Polls watched paths and returns paths that changed since the previous poll.
- `lurek.filesystem.read(path) -> string`: Reads a UTF-8 text file from GameFS.
- `lurek.filesystem.readAsync(path) -> integer`: Starts an asynchronous file load request.
- `lurek.filesystem.readBytes(path) -> string`: Reads a binary file from GameFS and returns the bytes as a Lua string.
- `lurek.filesystem.readJson(path) -> string`: Reads a JSON document as text from GameFS.
- `lurek.filesystem.readOrWriteJson(path, default_json) -> string`: Reads a JSON file or writes and returns default JSON when the file is absent.
- `lurek.filesystem.remove(path) -> nil`: Removes a GameFS file or supported path.
- `lurek.filesystem.removeDir(path) -> nil`: Removes a GameFS directory by its path.
- `lurek.filesystem.setIdentity(name) -> nil`: Sets the filesystem identity string used by save paths.
- `lurek.filesystem.stat(path) -> table`: Returns size and file/directory flags for a GameFS path.
- `lurek.filesystem.toAbsolutePath(path) -> string`: Resolves a GameFS-relative path against the filesystem base directory.
- `lurek.filesystem.unmount(mp) -> boolean`: Removes a GameFS mount point by its name.
- `lurek.filesystem.unwatchPath(path) -> nil`: Removes a path from the module-local file watcher.
- `lurek.filesystem.watchPath(path) -> nil`: Adds a path to the module-local file watcher.
- `lurek.filesystem.write(path, data) -> nil`: Writes a UTF-8 text file through GameFS.
- `lurek.filesystem.writeAsync(path, data) -> integer`: Starts an asynchronous file write request.
- `lurek.filesystem.writeBytes(path, data) -> nil`: Writes binary data through GameFS.
- `lurek.filesystem.writeJson(path, json) -> nil`: Writes JSON text through the GameFS layer.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LFileData Type

- Lua-side handle for immutable file bytes and their source path.

##### Fields

- No documented fields.

##### Methods

- `LFileData:getFilename() -> string`: Returns the path associated with this file data object.
- `LFileData:getSize() -> integer`: Returns the byte length of this file data.
- `LFileData:getString() -> string`: Returns file data bytes as a Lua string without UTF-8 validation.
- `LFileData:type() -> string`: Returns the Lua-visible type name for this file data handle.
- `LFileData:typeOf(name) -> boolean`: Returns whether this file data handle matches a supported type name.

#### LFileHandle Type

- Lua-side handle for a mutable file stream opened through GameFS.

##### Fields

- No documented fields.

##### Methods

- `LFileHandle:close() -> nil`: Closes this file handle on this object.
- `LFileHandle:flush() -> nil`: Flushes pending writes on this file handle.
- `LFileHandle:getMode() -> string`: Returns the mode used to open this file handle.
- `LFileHandle:getSize() -> integer`: Returns the size of the open file in bytes.
- `LFileHandle:isEOF() -> boolean`: Returns whether the file cursor is at end of file.
- `LFileHandle:read(count?) -> string`: Reads up to an optional byte count and returns text using lossless UTF-8 replacement.
- `LFileHandle:readLine() -> string`: Reads the next line from this file handle.
- `LFileHandle:seek(pos) -> nil`: Moves the file cursor to an absolute byte position.
- `LFileHandle:tell() -> integer`: Returns the current file cursor position.
- `LFileHandle:type() -> string`: Returns the Lua-visible type name for this file handle.
- `LFileHandle:typeOf(name) -> boolean`: Returns whether this file handle matches a supported type name.
- `LFileHandle:write(data) -> nil`: Writes a string to this file handle.

#### LFilesystemGetInfoResult Type

- Generated result shape from @field tags.

##### Fields

- `modtime` (`integer`): Modification time.
- `readonly` (`boolean`): Whether the file is read-only.
- `size` (`integer`): Size in bytes.
- `type` (`string`): File type.

##### Methods

- No documented methods.

#### LFilesystemStatResult Type

- Generated result shape from @field tags.

##### Fields

- `isDir` (`boolean`): Whether the path is a directory.
- `isFile` (`boolean`): Whether the path is a file.
- `size` (`integer`): Size in bytes.

##### Methods

- No documented methods.

#### LZipMount Type

- Lua-side handle for a mounted ZIP archive view.

##### Fields

- No documented fields.

##### Methods

- `LZipMount:contains(virtual_path) -> boolean`: Returns whether a virtual path exists in the ZIP mount.
- `LZipMount:listFiles() -> string[]`: Returns every virtual file path in the ZIP mount.
- `LZipMount:prefix() -> string`: Returns the virtual prefix used by this ZIP mount.
- `LZipMount:readFile(virtual_path) -> string`: Reads a file from the ZIP mount by virtual path.
- `LZipMount:type() -> string`: Returns the Lua-visible type name for this ZIP mount handle.
- `LZipMount:typeOf(name) -> boolean`: Returns whether this ZIP mount handle matches a supported type name.

## References

- `dataframe`: Imports or references `src/dataframe/`. Cross-group dependency from `Core Runtime` into `Foundations`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- `mountZip` currently returns a standalone `LZipMount` handle. Directory `mount(...)` participates in GameFS reads and listings; `mountZip(...)` does not.
