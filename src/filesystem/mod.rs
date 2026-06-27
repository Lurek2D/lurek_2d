//! `src/filesystem/mod.rs` is the module index for virtual paths, file data, handles, watchers, and async I/O.
//! It declares the files that own path resolution, buffered stream access, watch polling, and worker I/O.
//! This file reexports the main filesystem types so callers can use storage services without importing deep internal paths.
//! No path normalization, mount state, or worker queues live here; it only defines visibility and subsystem boundaries.
//! Read this index first when tracing filesystem behavior, because it shows where sandboxing, streams, and mounts split.
//! Changes here affect reachability and API shape, not traversal checks, file polling, or read and write semantics.

/// Async file request queue and result tracking.
pub mod async_loader;
/// Cached file payload helper. This module is publicly re-exported.
pub mod file_data;
/// Buffered file handle and file mode helpers.
pub mod file_handle;
/// Virtual filesystem and mount management.
pub mod vfs;
/// File modification watcher. This module is publicly re-exported.
pub mod watcher;
/// Async file request queue and result tracking.
pub use async_loader::{AsyncLoader, LoadHandle, LoadResult, LoadStatus, WriteResult, WriteStatus};
/// Cached file payload helper.
pub use file_data::FileData;
/// Buffered file handle and file mode helpers.
pub use file_handle::{FileHandle, FileMode};
/// Virtual filesystem metadata and mount types.
pub use vfs::{FileInfo, FileType, GameFS, MountLayer};
