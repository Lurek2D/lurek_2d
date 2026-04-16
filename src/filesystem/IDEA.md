# IDEA.md — `filesystem` module

> Migrated from `ideas/features/filesystem.md` and `ideas/performance/06-io-filesystem.md`.
> Status checked against `src/filesystem/` and `src/lua_api/filesystem_api.rs`.
> Lua namespace: `lurek.fs`.

---

## Features

### ✅ DONE — ZIP Archive Mounting (HIGH PRIORITY)
**Source**: features/filesystem.md — Feature Gaps #1 / Suggestions #1
**Implemented**: 2026-04-16

`src/filesystem/zip_mount.rs` — `ZipMount` struct with entry index built at mount time.
Lua API in `src/lua_api/filesystem_api.rs`:
- `lurek.fs.mountZip(archive_path, prefix)` → `ZipMount` userdata
- `ZipMount:readFile(virtual_path)` → bytes string
- `ZipMount:contains(virtual_path)` → boolean
- `ZipMount:listFiles()` → sorted array of virtual paths
- `ZipMount:prefix()` → string

Path traversal guard: rejects `..`, absolute paths, and Windows drive letters.

---

### ✅ DONE — File Watcher / Change Notification
**Source**: features/filesystem.md — Feature Gaps #2 / Suggestions #2
**Implemented**: 2026-04-16

`src/filesystem/watcher.rs` — `FileWatcher` polling by `std::fs::metadata().modified()`.
Lua API in `src/lua_api/filesystem_api.rs`:
- `lurek.fs.watchPath(path)` — adds a path to the watch list
- `lurek.fs.unwatchPath(path)` — removes a path
- `lurek.fs.pollWatchers()` → array of changed path strings

No OS-native notification APIs used — pure polling, no platform coupling.
Tests: `tests/lua/unit/test_filesystem_zip_watcher.lua` — 8 BDD cases.

---

### ✅ DONE — Glob Pattern Listing
**Source**: features/filesystem.md — Feature Gaps #3 / Suggestions #3

`lurek.fs.glob(pattern)` added in `filesystem_api.rs`. Supports `*` (multi-char) and `?` (single-char) wildcards.
Searches the last path component against glob pattern. Returns array of matching file paths.

---

### ✅ DONE — File Copy / Move
**Source**: features/filesystem.md — Feature Gaps #8 / Suggestions #4

`lurek.fs.copy(src, dst)` and `lurek.fs.move(src, dst)` added in `filesystem_api.rs`.
Copy allows src from read-sandbox; dst must be in `save/`. Move requires both in `save/`.
Backed by `VFS::copy_file` and `VFS::move_file` in `src/filesystem/vfs.rs`.

---

### ✅ DONE — Recursive Directory Delete
**Source**: features/filesystem.md — Feature Gaps #4 / Suggestions #5

`lurek.fs.removeDir(path)` added in `filesystem_api.rs`. Backed by `VFS::remove_dir()` which
calls `std::fs::remove_dir_all`. Path must resolve under the save sandbox.

---

### 🔇 LOW — Temp File Creation
**Source**: features/filesystem.md — Feature Gaps #5

No `createTempFile()`. Useful for intermediate processing but low priority for most game
use cases.

---

## Performance

### 🔇 LOW — Async Loader Completion Pattern Clarity
**Source**: features/filesystem.md — Structural Issues

`src/filesystem/async_loader.rs` exists. Verify whether completion uses callbacks or polling
and document the pattern clearly. No performance bottleneck identified — docs issue only.
