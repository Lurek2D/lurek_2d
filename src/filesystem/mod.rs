//! Provides the high-level filesystem module boundary for virtual mounts, async loading, and file handle access.
//! Connects path resolution, buffered I/O, watch support, and archive overlays into one storage surface.
//! Delivers the core file-service layer used by runtime systems and script-facing persistence flows.

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
