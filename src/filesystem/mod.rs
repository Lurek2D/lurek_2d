//! Provides the high-level filesystem module boundary for virtual mounts, async loading, and file handle access. `filesystem/mod` is the filesystem module index, declaring `async_loader`, `file_data`, `file_handle`, `vfs`, `watcher`, and 1 more so agents can identify which files own each feature slice before opening implementation code.
//! Connects path resolution, buffered I/O, watch support, and archive overlays into one storage surface. `src/filesystem/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `async_loader::{AsyncLoader, LoadHandle, LoadResult, LoadStatus, WriteResult, WriteStatus}`, `file_data::FileData`, `file_handle::{FileHandle, FileMode}`, `vfs::{FileInfo, FileType, GameFS, MountLayer}` centralized for the filesystem subsystem.

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
/// ZIP archive overlay mount. This module is publicly re-exported.
pub mod zip_mount;
/// Async file request queue and result tracking.
pub use async_loader::{AsyncLoader, LoadHandle, LoadResult, LoadStatus, WriteResult, WriteStatus};
/// Cached file payload helper.
pub use file_data::FileData;
/// Buffered file handle and file mode helpers.
pub use file_handle::{FileHandle, FileMode};
/// Virtual filesystem metadata and mount types.
pub use vfs::{FileInfo, FileType, GameFS, MountLayer};
