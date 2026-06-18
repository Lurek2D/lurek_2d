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

- The `filesystem` module is the sandboxed storage surface for users who need file access without giving every script raw platform path power.
- Path normalization, traversal checks, mounts, archive access, synchronous handles, and asynchronous IO combine into one controlled runtime view of storage.
- That matters because asset lookup, save data, mod content, hot reload, and tooling workflows all need file access, but they should not each invent their own safety and path rules.
- Watchers, metadata queries, recursive listing, and convenience helpers make the module useful for diagnostics and content tooling as well as for normal gameplay persistence.
- Mount and archive support are especially important because real projects often mix loose files, packaged assets, save locations, and mod roots under one conceptual storage view.
- The sandboxed design is the key policy boundary: `filesystem` exists so scripts can do meaningful file work while the engine still controls what paths are valid, portable, and safe to expose.
- Async reads and watch-style helpers also make the module practical for hot-reload and content-iteration workflows where storage changes need to become observable runtime events.
- This gives the engine one place to reason about what storage operations are allowed, observable, and portable across several execution environments.
- Read `filesystem` as the place where byte-oriented storage becomes safe, portable, and composable for the rest of the engine.


## Imports

- `dataframe`: Imports or references `src/dataframe/`. Cross-group dependency from `Core Runtime` into `Foundations`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### async_loader.rs

- `src/filesystem/async_loader.rs` owns the background worker queue for asynchronous file reads and writes.
- It stores request ids, bounded channels, result maps, and the worker thread that executes resolved path operations.
- Load and write status enums live here so callers can schedule work and poll outcomes without blocking game threads.
- Queue saturation, spawn failure reporting, and worker shutdown behavior are handled here as part of the I/O contract.
- This file does not resolve logical paths itself; higher layers must hand it already validated host filesystem targets.
- Read it when async I/O scheduling, poll semantics, queue limits, or worker lifecycle behavior needs to change.

### file_data.rs

- `src/filesystem/file_data.rs` owns the lightweight payload object returned by filesystem reads and cache lookups.
- It stores a logical path with raw bytes and exposes size, emptiness, and UTF-8 decoding helpers for callers.
- Read it when file payload shape, decode helpers, or shared read-result contracts in the filesystem need changes.

### file_handle.rs

- `src/filesystem/file_handle.rs` owns buffered stream handles for mode-aware reading, writing, appending, and seeking.
- It stores the active access mode, resolved host path, logical path, buffered reader or writer, and captured file size.
- Mode parsing, access checks, EOF probing, flushing, closing, and line reads all live here with one handle contract.
- This file opens paths through `GameFS`, but it does not decide mount precedence or save-directory sandbox policy.
- Drop-based cleanup also lives here so buffered writes flush predictably when a handle leaves scope or closes early.
- Read it when stream semantics, mode validation, cursor behavior, or buffered file access contracts need changes.

### mod.rs

- `src/filesystem/mod.rs` is the module index for virtual paths, file data, handles, watchers, async I/O, and ZIP mounts.
- It declares the files that own path resolution, buffered stream access, archive overlays, watch polling, and worker I/O.
- This file reexports the main filesystem types so callers can use storage services without importing deep internal paths.
- No path normalization, mount state, or worker queues live here; it only defines visibility and subsystem boundaries.
- Read this index first when tracing filesystem behavior, because it shows where sandboxing, streams, and mounts split.
- Changes here affect reachability and API shape, not traversal checks, file polling, or read and write semantics.

### vfs.rs

- `src/filesystem/vfs.rs` owns the virtual filesystem rooted at the game directory, save area, and mounted overlays.
- It stores base-dir identity, mount layers, and file metadata contracts while exposing the main `GameFS` API surface.
- Path normalization, traversal rejection, read-path resolution, and save-write confinement are enforced in this file.
- Read, write, list, glob, stat, copy, move, remove, JSON, and directory helpers all live here behind one sandbox owner.
- Mounted directories and overlays are merged here with deterministic precedence and virtual directory support.
- This file also builds integration points for `FileHandle`, `AsyncLoader`, and dataframe file-store persistence flows.
- Filesystem identity, save-directory helpers, and temp-file creation stay here so storage policy remains centralized.
- This file is the authoritative path and mount boundary; ZIP entry reads and buffered streams stay elsewhere.
- Read it when sandbox rules, mount behavior, path resolution, or high-level filesystem operations need to change.

### watcher.rs

- `src/filesystem/watcher.rs` polls watched paths and reports which files changed since the previous snapshot.
- It owns watch registration, cached mtimes, deterministic poll ordering, and forced invalidation for refresh flows.
- This file is the change-detection helper for filesystem clients; it does not resolve paths or read file contents.
- Read it when watch semantics, change polling, or refresh-trigger contracts for filesystem consumers need changes.

### zip_mount.rs

- `src/filesystem/zip_mount.rs` mounts a ZIP archive as a virtual read-only path prefix inside the filesystem layer.
- It owns archive indexing, normalized virtual-path lookup, traversal rejection, and on-demand entry reads from ZIP data.
- Contains and list operations live here so archive-backed mounts can behave like directory sources to higher layers.
- This file is the archive overlay boundary; it does not manage save writes, async queues, or mutable stream handles.
- Read it when virtual archive paths, ZIP lookup behavior, or sandbox checks for mounted content need to change.



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
