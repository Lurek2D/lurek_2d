# filesystem

## TL;DR

- The `filesystem` module resides in the Core Runtime tier and implements `GameFS`, a strictly sandboxed virtual filesystem.

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

- `lurek.filesystem.append`: Appends UTF-8 text to a GameFS file.
- `lurek.filesystem.copy`: Copies one GameFS file to another path.
- `lurek.filesystem.createDirectory`: Creates a GameFS directory and any missing parents.
- `lurek.filesystem.createTempFile`: Creates a temporary file through GameFS.
- `lurek.filesystem.exists`: Returns whether a path exists in GameFS.
- `lurek.filesystem.getDirectoryItems`: Lists immediate entries in a GameFS directory.
- `lurek.filesystem.getIdentity`: Returns the current filesystem identity string.
- `lurek.filesystem.getInfo`: Returns file metadata for a GameFS path when available.
- `lurek.filesystem.getSaveDirectory`: Returns the save directory path used by GameFS.
- `lurek.filesystem.getSource`: Returns the GameFS source root string.
- `lurek.filesystem.getUserDirectory`: Returns the current user's directory path.
- `lurek.filesystem.getWorkingDirectory`: Returns the process working directory.
- `lurek.filesystem.glob`: Returns GameFS paths matching a glob pattern.
- `lurek.filesystem.isDirectory`: Returns whether a GameFS path is a directory.
- `lurek.filesystem.isFile`: Returns whether a GameFS path is a regular file.
- `lurek.filesystem.lines`: Creates an iterator function over lines in a text file.
- `lurek.filesystem.listRecursive`: Lists all paths under a GameFS directory recursively.
- `lurek.filesystem.load`: Loads a Lua chunk from GameFS and returns it as a Lua function.
- `lurek.filesystem.mkdir`: Creates a directory under the GameFS base directory.
- `lurek.filesystem.mount`: Mounts an external source path at a GameFS mount point.
- `lurek.filesystem.mountZip`: Opens a ZIP archive and exposes it through a virtual prefix.
- `lurek.filesystem.move`: Moves or renames one GameFS file to another path.
- `lurek.filesystem.newFileData`: Loads a file into an immutable file data handle.
- `lurek.filesystem.openFile`: Opens a GameFS file handle in a requested mode.
- `lurek.filesystem.pollAsync`: Polls an asynchronous file load request.
- `lurek.filesystem.pollAsyncWrite`: Polls an asynchronous file write request.
- `lurek.filesystem.pollWatchers`: Polls watched paths and returns paths that changed since the previous poll.
- `lurek.filesystem.read`: Reads a UTF-8 text file from GameFS.
- `lurek.filesystem.readAsync`: Starts an asynchronous file load request.
- `lurek.filesystem.readBytes`: Reads a binary file from GameFS and returns the bytes as a Lua string.
- `lurek.filesystem.readJson`: Reads a JSON document as text from GameFS.
- `lurek.filesystem.readOrWriteJson`: Reads a JSON file or writes and returns default JSON when the file is absent.
- `lurek.filesystem.remove`: Removes a GameFS file or supported path.
- `lurek.filesystem.removeDir`: Removes a GameFS directory by its path.
- `lurek.filesystem.setIdentity`: Sets the filesystem identity string used by save paths.
- `lurek.filesystem.stat`: Returns size and file/directory flags for a GameFS path.
- `lurek.filesystem.toAbsolutePath`: Resolves a GameFS-relative path against the filesystem base directory.
- `lurek.filesystem.unmount`: Removes a GameFS mount point by its name.
- `lurek.filesystem.unwatchPath`: Removes a path from the module-local file watcher.
- `lurek.filesystem.watchPath`: Adds a path to the module-local file watcher.
- `lurek.filesystem.write`: Writes a UTF-8 text file through GameFS.
- `lurek.filesystem.writeAsync`: Starts an asynchronous file write request.
- `lurek.filesystem.writeBytes`: Writes binary data through GameFS.
- `lurek.filesystem.writeJson`: Writes JSON text through the GameFS layer.

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

- `LFileData:getFilename`: Returns the path associated with this file data object.
- `LFileData:getSize`: Returns the byte length of this file data.
- `LFileData:getString`: Returns file data bytes as a Lua string without UTF-8 validation.
- `LFileData:type`: Returns the Lua-visible type name for this file data handle.
- `LFileData:typeOf`: Returns whether this file data handle matches a supported type name.

#### LFileHandle Type

- Lua-side handle for a mutable file stream opened through GameFS.

##### Fields

- No documented fields.

##### Methods

- `LFileHandle:close`: Closes this file handle on this object.
- `LFileHandle:flush`: Flushes pending writes on this file handle.
- `LFileHandle:getMode`: Returns the mode used to open this file handle.
- `LFileHandle:getSize`: Returns the size of the open file in bytes.
- `LFileHandle:isEOF`: Returns whether the file cursor is at end of file.
- `LFileHandle:read`: Reads up to an optional byte count and returns text using lossless UTF-8 replacement.
- `LFileHandle:readLine`: Reads the next line from this file handle.
- `LFileHandle:seek`: Moves the file cursor to an absolute byte position.
- `LFileHandle:tell`: Returns the current file cursor position.
- `LFileHandle:type`: Returns the Lua-visible type name for this file handle.
- `LFileHandle:typeOf`: Returns whether this file handle matches a supported type name.
- `LFileHandle:write`: Writes a string to this file handle.

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

- `LZipMount:contains`: Returns whether a virtual path exists in the ZIP mount.
- `LZipMount:listFiles`: Returns every virtual file path in the ZIP mount.
- `LZipMount:prefix`: Returns the virtual prefix used by this ZIP mount.
- `LZipMount:readFile`: Reads a file from the ZIP mount by virtual path.
- `LZipMount:type`: Returns the Lua-visible type name for this ZIP mount handle.
- `LZipMount:typeOf`: Returns whether this ZIP mount handle matches a supported type name.
