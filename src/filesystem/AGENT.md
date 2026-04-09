# `filesystem` � Agent Reference

| Property       | Value                                                |
|----------------|------------------------------------------------------|
| **Tier**       | Tier 1 � Core Engine Subsystems                      |
| **Status**     | Implemented � Full                                   |
| **Lua API**    | `lurek.fs`                                    |
| **Source**     | `src/filesystem/`                                    |
| **Rust Tests** | `tests/rust/unit/filesystem_tests.rs`                |
| **Lua Tests**  | `tests/lua/unit/test_filesystem.lua`                 |
| **Architecture** | �                                                  |

## Purpose

The `filesystem` module provides all game I/O through `GameFS`, a sandboxed virtual filesystem that restricts every resolved path to the game directory or a per-identity save directory. `FileHandle` wraps open files in Read/Write/Append/Closed modes. `AsyncLoader` dispatches background reads via a worker thread. The VFS layer supports mod-folder overlays. See `docs/specs/filesystem.md` for full detail.

## Source Files

| File              | Purpose                                                              |
|-------------------|----------------------------------------------------------------------|
| `mod.rs`          | Module root; re-exports `GameFS`, `AsyncLoader`, `FileHandle`, `FileData`, `MountLayer` |
| `vfs.rs`          | `GameFS` sandboxed filesystem, `FileInfo`, `FileType`, `MountLayer`, path resolution, mount layers |
| `file_handle.rs`  | `FileHandle` with buffered read/write/seek/close, `FileMode` enum   |
| `file_data.rs`    | `FileData` raw byte buffer loaded from VFS                          |
| `async_loader.rs` | `AsyncLoader` background file reader, `LoadHandle`, `LoadResult`, `LoadStatus` |

## Key Types

| Type | Description |
|------|-------------|
| `LoadHandle` | Principal type for the `filesystem` module. |
| `LoadResult` | Principal type for the `filesystem` module. |
| `LoadStatus` | Principal type for the `filesystem` module. |
| `AsyncLoader` | Principal type for the `filesystem` module. |
| `FileData` | Principal type for the `filesystem` module. |
| `FileMode` | Principal type for the `filesystem` module. |
| `FileHandle` | Principal type for the `filesystem` module. |
| `FileInfo` | Principal type for the `filesystem` module. |
| `FileType` | Principal type for the `filesystem` module. |
| `MountLayer` | Principal type for the `filesystem` module. |
| `GameFS` | Principal type for the `filesystem` module. |

## Lua API Summary

| Function | Description |
|----------|-------------|
| `lurek.filesystem.read()` | See `docs/specs/filesystem.md`. |
| `lurek.filesystem.write()` | See `docs/specs/filesystem.md`. |
| `lurek.filesystem.exists()` | See `docs/specs/filesystem.md`. |
| `lurek.filesystem.append()` | See `docs/specs/filesystem.md`. |
| `lurek.filesystem.openFile()` | See `docs/specs/filesystem.md`. |
| `lurek.filesystem.getDirectoryItems()` | See `docs/specs/filesystem.md`. |
| `lurek.filesystem.isFile()` | See `docs/specs/filesystem.md`. |
| `lurek.filesystem.isDirectory()` | See `docs/specs/filesystem.md`. |
| `lurek.filesystem.createDirectory()` | See `docs/specs/filesystem.md`. |
| `lurek.filesystem.remove()` | See `docs/specs/filesystem.md`. |
| `lurek.filesystem.getInfo()` | See `docs/specs/filesystem.md`. |
| `lurek.filesystem.getSource()` | See `docs/specs/filesystem.md`. |
| `lurek.filesystem.getSaveDirectory()` | See `docs/specs/filesystem.md`. |
| `lurek.filesystem.getWorkingDirectory()` | See `docs/specs/filesystem.md`. |
| `lurek.filesystem.getUserDirectory()` | See `docs/specs/filesystem.md`. |
| `lurek.filesystem.getIdentity()` | See `docs/specs/filesystem.md`. |
| `lurek.filesystem.setIdentity()` | See `docs/specs/filesystem.md`. |
| `lurek.filesystem.lines()` | See `docs/specs/filesystem.md`. |
| `lurek.filesystem.readAsync()` | See `docs/specs/filesystem.md`. |
| `lurek.filesystem.pollAsync()` | See `docs/specs/filesystem.md`. |

## Full Specification

All architecture diagrams, detailed type documentation, Lua API reference, examples, and cross-module references live in the consolidated spec:

� [`docs/specs/filesystem.md`](../../docs/specs/filesystem.md)

_Update both this file **and** `docs/specs/filesystem.md` whenever source files, public types, or Lua bindings change._
