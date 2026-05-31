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

This module provides virtual filesystem services, sandboxing file access to game directories. It coordinates path resolution, file operations, and virtual mounts, ensuring scripting layers interact with files safely. Normalising paths across systems guarantees consistent cross-platform behavior for all read, write, and directory workflows.

To support asset loading, the system features virtual overlays. It mounts directories or ZIP archives under virtual prefixes, building lookup indexes to read archive files on demand without full extraction. This lets the engine resolve assets across folders dynamically, simplifying modding support and content overrides.

I/O operations support both synchronous streams and non-blocking asynchronous requests. The async loader delegates tasks to a dedicated worker thread, allowing the engine to transfer files without main-thread stalls. Buffered handles support mode-aware reading, writing, seeking, and appending for predictable stream control.

Additionally, a poll-based file watcher tracks modification timestamps. This detects file changes on demand, serving as the foundation for hot-reloading configurations and assets. The virtual filesystem layer also provides JSON serialization, temporary file creation, and directory metadata inspection.

## Imports

- `dataframe`: Imports or references `src/dataframe/`. Cross-group dependency from `Core Runtime` into `Foundations`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### async_loader.rs

- Provides background file I/O through a dedicated worker thread and bounded request channel.
- Supports non-blocking read and write scheduling with opaque handles for later status polling.
- Stores results in thread-safe maps so callers can retrieve outcomes without blocking producers.
- Enforces queue capacity limits to keep memory and scheduling pressure under control.
- Handles worker lifecycle shutdown cleanly when the loader is dropped.
- Delivers asynchronous file transfer behavior for systems that must avoid main-thread stalls.

### file_data.rs

- Provides a lightweight file payload container pairing logical paths with loaded raw bytes.
- Exposes basic size, emptiness, and UTF-8 decode helpers for convenient caller-side consumption.
- Delivers the shared data object returned by filesystem read operations.

### file_handle.rs

- Provides buffered file-handle behavior for mode-aware read, write, and append stream operations.
- Resolves logical game paths through GameFS before touching host filesystem resources.
- Exposes byte and line reading utilities with EOF-aware iteration semantics.
- Supports seek, tell, flush, and explicit close workflows for predictable stream control.
- Enforces access-mode checks so invalid operation mixes fail with clear runtime errors.
- Delivers safe per-file I/O primitives used by script APIs and engine persistence code.

### mod.rs

- Provides the high-level filesystem module boundary for virtual mounts, async loading, and file handle access.
- Connects path resolution, buffered I/O, watch support, and archive overlays into one storage surface.
- Delivers the core file-service layer used by runtime systems and script-facing persistence flows.

### vfs.rs

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

### watcher.rs

- Provides poll-based file watch behavior that detects mtime changes for registered paths.
- Maintains cached modification snapshots and reports deterministic change sets per poll cycle.
- Supports watch, unwatch, and forced invalidation workflows for runtime refresh control.
- Delivers a lightweight change-detection utility for assets and config reload pipelines.

### zip_mount.rs

- Provides ZIP-backed virtual mount behavior that maps normalized virtual paths to archive entries.
- Builds an index for fast repeated lookups while reading files on demand without full extraction.
- Enforces traversal-safe path handling before archive access to maintain sandbox guarantees.
- Supports listing and existence checks over mounted archive content through a unified interface.
- Delivers archive overlay functionality used by the virtual filesystem mount stack.

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
