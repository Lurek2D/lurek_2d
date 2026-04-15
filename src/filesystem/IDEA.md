# IDEA.md — `filesystem` module

> Migrated from `ideas/features/filesystem.md` and `ideas/performance/06-io-filesystem.md`.
> Status checked against `src/filesystem/` and `src/lua_api/filesystem_api.rs`.
> Lua namespace: `lurek.fs`.

---

## Features

### ❌ TODO — ZIP Archive Mounting (HIGH PRIORITY)
**Source**: features/filesystem.md — Feature Gaps #1 / Suggestions #1

No `lurek.fs.mountZip(path, mountPoint)` found. ZIP mounting is critical for:
- `.luna` distribution format (single-file game bundles)
- Mod archive support

Engine A (LÖVE) has this via the `.love` ZIP format. Without it, distribution is a
directory copy only.

---

### ❌ TODO — File Watcher / Change Notification
**Source**: features/filesystem.md — Feature Gaps #2 / Suggestions #2

No `lurek.fs.watch(path, fn)` found. File watching enables hot reload of Lua scripts,
textures, and data files during development. One of the most-requested missing features
for rapid iteration workflows.

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
