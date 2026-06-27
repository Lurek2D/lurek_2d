//! `src/filesystem/vfs.rs` owns the virtual filesystem rooted at the game directory, save area, and mounted overlays.
//! It stores base-dir identity, mount layers, and file metadata contracts while exposing the main `GameFS` API surface.
//! Path normalization, traversal rejection, read-path resolution, and save-write confinement are enforced in this file.
//! Read, write, list, glob, stat, copy, move, remove, JSON, and directory helpers all live here behind one sandbox owner.
//! Mounted directories and overlays are merged here with deterministic precedence and virtual directory support.
//! This file also builds integration points for `FileHandle`, `AsyncLoader`, and dataframe file-store persistence flows.
//! Filesystem identity, save-directory helpers, and temp-file creation stay here so storage policy remains centralized.
//! This file is the authoritative path and mount boundary; ZIP entry reads and buffered streams stay elsewhere.
//! Read it when sandbox rules, mount behavior, path resolution, or high-level filesystem operations need to change.

use crate::dataframe::file_io::DataFrameFileStore;
use crate::filesystem::file_handle::{FileHandle, FileMode};
use crate::log_msg;
use crate::runtime::error::{EngineError, EngineResult};
use crate::runtime::log_messages::{FS01_GAMEFS_INIT, FS04_PATH_TRAVERSAL, FS05_VFS_MOUNT};
use serde_json::Value as JsonValue;
use std::path::{Path, PathBuf};

const SAVE_ROOT: &str = "save";
const SAVE_TEMP_DIR: &str = "save/tmp";
/// Metadata snapshot for a file or directory in the virtual filesystem.
#[derive(Debug, Clone)]
pub struct FileInfo {
    /// Classified file kind returned by metadata queries.
    pub file_type: FileType,
    /// Size in bytes reported by the host filesystem.
    pub size: u64,
    /// Modification time in seconds since the Unix epoch when available.
    pub modified_time: Option<u64>,
    /// Host read-only flag copied from filesystem permissions.
    pub readonly: bool,
}
/// Coarse file kind used by metadata and scripting APIs.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum FileType {
    /// Regular file entry.
    File,
    /// Directory entry.
    Directory,
    /// Symbolic link entry.
    Symlink,
    /// Any other filesystem entry kind.
    Other,
}
impl FileType {
    /// Return the lowercase type label used in metadata output.
    pub fn as_str(&self) -> &'static str {
        match self {
            FileType::File => "file",
            FileType::Directory => "directory",
            FileType::Symlink => "symlink",
            FileType::Other => "other",
        }
    }
}
/// Mounted source directory with its virtual mountpoint.
#[derive(Debug, Clone)]
pub struct MountLayer {
    /// Canonical host path for the mounted source tree.
    pub source: PathBuf,
    /// Virtual prefix exposed inside GameFS.
    pub mountpoint: String,
}
/// Game filesystem rooted at a base directory with optional mount overlays.
#[derive(Clone)]
pub struct GameFS {
    /// Root directory used for all resolved filesystem paths.
    base_dir: PathBuf,
    /// Optional identity string used by save and runtime callers.
    identity: String,
    /// Overlay mounts searched from newest to oldest.
    mounts: Vec<MountLayer>,
}
impl GameFS {
    /// Normalize a caller-supplied logical path to slash-separated relative segments.
    fn normalize_logical_path(path: &str) -> String {
        path.replace('\\', "/")
            .split('/')
            .filter(|segment| !segment.is_empty() && *segment != ".")
            .collect::<Vec<_>>()
            .join("/")
    }
    /// Return the suffix of `path` that lives inside `mountpoint`, if any.
    fn relative_inside_mount<'a>(path: &'a str, mountpoint: &str) -> Option<&'a str> {
        if mountpoint.is_empty() {
            return Some(path);
        }
        if path == mountpoint {
            return Some("");
        }
        path.strip_prefix(mountpoint)?.strip_prefix('/')
    }
    /// Return the mountpoint-relative suffix when `mountpoint` is nested below `path`.
    fn mount_suffix_below_path<'a>(path: &str, mountpoint: &'a str) -> Option<&'a str> {
        if mountpoint.is_empty() || path == mountpoint {
            return None;
        }
        if path.is_empty() {
            return Some(mountpoint);
        }
        mountpoint.strip_prefix(path)?.strip_prefix('/')
    }
    /// Return true when a virtual directory is implied by a mounted subtree.
    fn is_virtual_mount_directory(&self, normalized_path: &str) -> bool {
        self.mounts.iter().any(|layer| {
            layer.mountpoint == normalized_path
                || Self::mount_suffix_below_path(normalized_path, &layer.mountpoint).is_some()
        })
    }
    /// Resolve a mounted read path before falling back to the base filesystem.
    fn resolve_mount_read_path(&self, normalized_path: &str) -> EngineResult<Option<PathBuf>> {
        for layer in self.mounts.iter().rev() {
            let Some(relative) =
                Self::relative_inside_mount(normalized_path, layer.mountpoint.as_str())
            else {
                continue;
            };
            let candidate = if relative.is_empty() {
                layer.source.clone()
            } else {
                layer.source.join(relative)
            };
            if !candidate.exists() {
                continue;
            }
            let canonical = candidate.canonicalize().map_err(|e| {
                EngineError::FileSystemError(format!(
                    "Cannot resolve mounted path '{}': {}",
                    normalized_path, e
                ))
            })?;
            if canonical.starts_with(&layer.source) {
                return Ok(Some(canonical));
            }
            return Err(EngineError::FileSystemError(
                "Access denied: mounted path escaped its source".into(),
            ));
        }
        Ok(None)
    }
    /// Collect recursive entries from `dir`, prefixing them with `virtual_prefix`.
    fn collect_recursive_prefixed(
        base: &Path,
        dir: &Path,
        virtual_prefix: &str,
        out: &mut std::collections::HashSet<String>,
    ) -> EngineResult<()> {
        let rd = std::fs::read_dir(dir).map_err(|e| {
            EngineError::FileSystemError(format!(
                "Failed to read directory '{}': {}",
                dir.display(),
                e
            ))
        })?;
        for entry in rd {
            let entry = entry.map_err(|e| {
                EngineError::FileSystemError(format!("Failed to read entry: {}", e))
            })?;
            let entry_path = entry.path();
            if let Ok(rel) = entry_path.strip_prefix(base) {
                let rel_str = rel.to_string_lossy().replace('\\', "/");
                let logical = if virtual_prefix.is_empty() {
                    rel_str
                } else if rel_str.is_empty() {
                    virtual_prefix.to_string()
                } else {
                    format!("{}/{}", virtual_prefix, rel_str)
                };
                out.insert(logical);
            }
            if entry_path.is_dir() {
                Self::collect_recursive_prefixed(base, &entry_path, virtual_prefix, out)?;
            }
        }
        Ok(())
    }
    /// Add synthetic virtual directories implied by a mounted subtree.
    fn add_virtual_mount_prefixes(
        relative_mount: &str,
        out: &mut std::collections::HashSet<String>,
    ) {
        let mut current = String::new();
        for segment in relative_mount
            .split('/')
            .filter(|segment| !segment.is_empty())
        {
            if current.is_empty() {
                current.push_str(segment);
            } else {
                current.push('/');
                current.push_str(segment);
            }
            out.insert(current.clone());
        }
    }
    /// Create a new filesystem rooted at the supplied base directory.
    pub fn new(base_dir: impl Into<PathBuf>) -> Self {
        log_msg!(debug, FS01_GAMEFS_INIT);
        GameFS {
            base_dir: base_dir.into(),
            identity: String::new(),
            mounts: Vec::new(),
        }
    }
    /// Return the root directory used for path resolution.
    pub fn base_dir(&self) -> &Path {
        &self.base_dir
    }
    /// Reject any path containing parent-directory traversal components.
    fn reject_traversal(path: &str) -> EngineResult<()> {
        for component in std::path::Path::new(path).components() {
            if let std::path::Component::ParentDir = component {
                return Err(EngineError::FileSystemError(
                    "Access denied: path traversal detected".into(),
                ));
            }
        }
        Ok(())
    }
    /// Read a UTF-8 file through the mounted filesystem or return a filesystem error.
    pub fn read_string(&self, path: &str) -> EngineResult<String> {
        let resolved = self.resolve_read_path(path)?;
        std::fs::read_to_string(&resolved)
            .map_err(|e| EngineError::FileSystemError(format!("Failed to read '{}': {}", path, e)))
    }
    /// Read a file as raw bytes or return a filesystem error.
    pub fn read_bytes(&self, path: &str) -> EngineResult<Vec<u8>> {
        let resolved = self.resolve_read_path(path)?;
        std::fs::read(&resolved)
            .map_err(|e| EngineError::FileSystemError(format!("Failed to read '{}': {}", path, e)))
    }
    /// Write UTF-8 content into the save filesystem or return a filesystem error.
    pub fn write_string(&self, path: &str, content: &str) -> EngineResult<()> {
        let resolved = self.resolve_save_path(path)?;
        if let Some(parent) = resolved.parent() {
            std::fs::create_dir_all(parent).map_err(|e| {
                EngineError::FileSystemError(format!("Failed to create directories: {}", e))
            })?;
        }
        std::fs::write(&resolved, content)
            .map_err(|e| EngineError::FileSystemError(format!("Failed to write '{}': {}", path, e)))
    }
    /// Write raw bytes into the save filesystem or return a filesystem error.
    pub fn write_bytes(&self, path: &str, bytes: &[u8]) -> EngineResult<()> {
        let resolved = self.resolve_save_path(path)?;
        if let Some(parent) = resolved.parent() {
            std::fs::create_dir_all(parent).map_err(|e| {
                EngineError::FileSystemError(format!("Failed to create directories: {}", e))
            })?;
        }
        std::fs::write(&resolved, bytes)
            .map_err(|e| EngineError::FileSystemError(format!("Failed to write '{}': {}", path, e)))
    }
    /// Validate JSON content and return the original string on success.
    pub fn read_json(&self, path: &str) -> EngineResult<String> {
        let content = self.read_string(path)?;
        serde_json::from_str::<JsonValue>(&content).map_err(|e| {
            EngineError::FileSystemError(format!("Invalid JSON in '{}': {}", path, e))
        })?;
        Ok(content)
    }
    /// Validate JSON text and write it to the save filesystem.
    pub fn write_json(&self, path: &str, json: &str) -> EngineResult<()> {
        serde_json::from_str::<JsonValue>(json).map_err(|e| {
            EngineError::FileSystemError(format!("Invalid JSON for '{}': {}", path, e))
        })?;
        self.write_string(path, json)
    }
    /// Read existing JSON or create it from the default payload when missing.
    pub fn read_or_write_json(&self, path: &str, default_json: &str) -> EngineResult<String> {
        if self.exists(path) {
            return self.read_json(path);
        }
        self.write_json(path, default_json)?;
        Ok(default_json.to_string())
    }
    /// Return true when the base filesystem path exists.
    pub fn exists(&self, path: &str) -> bool {
        self.is_file(path) || self.is_directory(path)
    }
    /// List entries in a directory without recursion.
    pub fn list(&self, path: &str) -> EngineResult<Vec<String>> {
        let full = self.base_dir.join(path);
        let mut entries = Vec::new();
        for entry in std::fs::read_dir(&full).map_err(|e| {
            EngineError::FileSystemError(format!("Failed to list '{}': {}", path, e))
        })? {
            let entry = entry.map_err(|e| {
                EngineError::FileSystemError(format!("Failed to read entry: {}", e))
            })?;
            if let Some(name) = entry.file_name().to_str() {
                entries.push(name.to_string());
            }
        }
        Ok(entries)
    }
    /// List directory entries recursively under the resolved read path.
    pub fn list_recursive(&self, path: &str) -> EngineResult<Vec<String>> {
        let normalized = Self::normalize_logical_path(path);
        let mut results = std::collections::HashSet::new();

        let base_dir = if normalized.is_empty() {
            self.base_dir.clone()
        } else {
            self.base_dir.join(&normalized)
        };
        if base_dir.is_dir() {
            Self::collect_recursive_prefixed(&base_dir, &base_dir, "", &mut results)?;
        }

        for layer in &self.mounts {
            if let Some(relative) =
                Self::relative_inside_mount(normalized.as_str(), layer.mountpoint.as_str())
            {
                let dir = if relative.is_empty() {
                    layer.source.clone()
                } else {
                    layer.source.join(relative)
                };
                if dir.is_dir() {
                    Self::collect_recursive_prefixed(&dir, &dir, "", &mut results)?;
                }
                continue;
            }
            if let Some(relative_mount) =
                Self::mount_suffix_below_path(normalized.as_str(), layer.mountpoint.as_str())
            {
                Self::add_virtual_mount_prefixes(relative_mount, &mut results);
                Self::collect_recursive_prefixed(
                    &layer.source,
                    &layer.source,
                    relative_mount,
                    &mut results,
                )?;
            }
        }

        let mut ordered: Vec<String> = results.into_iter().collect();
        ordered.sort();
        Ok(ordered)
    }
    /// Return sorted directory entries from the resolved read path.
    pub fn get_directory_items(&self, path: &str) -> EngineResult<Vec<String>> {
        self.get_directory_items_merged(path)
    }
    /// Return true when the resolved path points to a file.
    pub fn is_file(&self, path: &str) -> bool {
        self.resolve_read_path(path)
            .map(|p| p.is_file())
            .unwrap_or(false)
    }
    /// Return true when the resolved path points to a directory.
    pub fn is_directory(&self, path: &str) -> bool {
        let normalized = Self::normalize_logical_path(path);
        self.resolve_read_path(path)
            .map(|p| p.is_dir())
            .unwrap_or_else(|_| self.is_virtual_mount_directory(normalized.as_str()))
    }
    /// Create a directory tree in the save filesystem or return a filesystem error.
    pub fn create_directory(&self, path: &str) -> EngineResult<()> {
        let resolved = self.resolve_save_path(path)?;
        std::fs::create_dir_all(&resolved).map_err(|e| {
            EngineError::FileSystemError(format!("Cannot create directory '{}': {}", path, e))
        })
    }
    /// Remove a file or directory from the save filesystem or return a filesystem error.
    pub fn remove(&self, path: &str) -> EngineResult<()> {
        let resolved = self.resolve_save_path(path)?;
        if resolved.is_dir() {
            std::fs::remove_dir(&resolved).map_err(|e| {
                EngineError::FileSystemError(format!("Cannot remove directory '{}': {}", path, e))
            })
        } else {
            std::fs::remove_file(&resolved).map_err(|e| {
                EngineError::FileSystemError(format!("Cannot remove file '{}': {}", path, e))
            })
        }
    }
    /// Read metadata for a path and return a normalized file info record.
    pub fn get_info(&self, path: &str) -> EngineResult<FileInfo> {
        let resolved = self.resolve_read_path(path)?;
        let metadata = std::fs::metadata(&resolved).map_err(|e| {
            EngineError::FileSystemError(format!("Cannot get info for '{}': {}", path, e))
        })?;
        let modified_time = metadata
            .modified()
            .ok()
            .and_then(|t| t.duration_since(std::time::UNIX_EPOCH).ok())
            .map(|d| d.as_secs());
        Ok(FileInfo {
            file_type: if metadata.is_file() {
                FileType::File
            } else if metadata.is_dir() {
                FileType::Directory
            } else {
                FileType::Other
            },
            size: metadata.len(),
            modified_time,
            readonly: metadata.permissions().readonly(),
        })
    }
    /// Append UTF-8 content into a file in the save filesystem.
    pub fn append_string(&self, path: &str, content: &str) -> EngineResult<()> {
        let resolved = self.resolve_save_path(path)?;
        if let Some(parent) = resolved.parent() {
            std::fs::create_dir_all(parent).map_err(|e| {
                EngineError::FileSystemError(format!("Failed to create directories: {}", e))
            })?;
        }
        use std::io::Write;
        let mut file = std::fs::OpenOptions::new()
            .create(true)
            .append(true)
            .open(&resolved)
            .map_err(|e| {
                EngineError::FileSystemError(format!("Failed to open '{}' for append: {}", path, e))
            })?;
        file.write_all(content.as_bytes()).map_err(|e| {
            EngineError::FileSystemError(format!("Failed to append to '{}': {}", path, e))
        })
    }
    /// Return the base directory as a string for reporting.
    pub fn get_source(&self) -> String {
        self.base_dir.to_string_lossy().to_string()
    }
    /// Return the save directory path under the base directory.
    pub fn get_save_directory(&self) -> PathBuf {
        self.base_dir.join(SAVE_ROOT)
    }
    /// Return the current working directory as a string or filesystem error.
    pub fn get_working_directory() -> EngineResult<String> {
        std::env::current_dir()
            .map(|p| p.to_string_lossy().to_string())
            .map_err(|e| {
                EngineError::FileSystemError(format!("Cannot get working directory: {}", e))
            })
    }
    /// Return the user home directory string or fall back to the current directory.
    pub fn get_user_directory() -> String {
        #[cfg(target_os = "windows")]
        {
            std::env::var("USERPROFILE").unwrap_or_else(|_| {
                std::env::current_dir()
                    .map(|p| p.to_string_lossy().to_string())
                    .unwrap_or_else(|_| ".".to_string())
            })
        }
        #[cfg(not(target_os = "windows"))]
        {
            std::env::var("HOME").unwrap_or_else(|_| {
                std::env::current_dir()
                    .map(|p| p.to_string_lossy().to_string())
                    .unwrap_or_else(|_| ".".to_string())
            })
        }
    }
    /// Return the current identity string assigned to the filesystem.
    pub fn get_identity(&self) -> &str {
        &self.identity
    }
    /// Set the identity string used by filesystem callers.
    pub fn set_identity(&mut self, identity: &str) {
        self.identity = identity.to_string();
    }
    /// Mount a source directory under a virtual mountpoint or return an error.
    pub fn mount(&mut self, source_path: &str, mountpoint: &str) -> EngineResult<()> {
        for component in std::path::Path::new(source_path).components() {
            if let std::path::Component::ParentDir = component {
                log_msg!(warn, FS04_PATH_TRAVERSAL, "{}", source_path);
                return Err(EngineError::FileSystemError(
                    "Access denied: path traversal in mount source".into(),
                ));
            }
        }
        let full = self.base_dir.join(source_path);
        if !full.is_dir() {
            return Err(EngineError::FileSystemError(format!(
                "Mount source '{}' is not a directory",
                source_path
            )));
        }
        let canonical = full.canonicalize().map_err(|e| {
            EngineError::FileSystemError(format!(
                "Cannot resolve mount source '{}': {}",
                source_path, e
            ))
        })?;
        let base_canonical = self
            .base_dir
            .canonicalize()
            .map_err(|e| EngineError::FileSystemError(format!("Cannot resolve base dir: {}", e)))?;
        if !canonical.starts_with(&base_canonical) {
            return Err(EngineError::FileSystemError(
                "Access denied: mount source must be inside the game directory".into(),
            ));
        }
        log_msg!(info, FS05_VFS_MOUNT, "{} -> {}", source_path, mountpoint);
        self.mounts.push(MountLayer {
            source: canonical,
            mountpoint: Self::normalize_logical_path(mountpoint),
        });
        Ok(())
    }
    /// Mount an already validated path under a virtual mountpoint or return an error.
    pub fn mount_full(&mut self, source_path: &Path, mountpoint: &str) -> EngineResult<()> {
        if !source_path.is_dir() {
            return Err(EngineError::FileSystemError(format!(
                "Mount source '{}' is not a directory",
                source_path.display()
            )));
        }
        let canonical = source_path.canonicalize().map_err(|e| {
            EngineError::FileSystemError(format!("Cannot resolve mount path: {}", e))
        })?;
        self.mounts.push(MountLayer {
            source: canonical,
            mountpoint: Self::normalize_logical_path(mountpoint),
        });
        Ok(())
    }
    /// Remove a mountpoint and return true when one was removed.
    pub fn unmount(&mut self, mountpoint: &str) -> bool {
        if let Some(idx) = self.mounts.iter().position(|m| m.mountpoint == mountpoint) {
            self.mounts.remove(idx);
            true
        } else {
            false
        }
    }
    /// Read a chunk path from the newest matching mount layer or from the base filesystem.
    pub fn load_chunk(&self, path: &str) -> EngineResult<Vec<u8>> {
        self.read_bytes(path)
    }
    /// Merge directory entries from the base path and any mounted overlays.
    pub fn get_directory_items_merged(&self, path: &str) -> EngineResult<Vec<String>> {
        let mut items: std::collections::HashSet<String> = std::collections::HashSet::new();
        let normalized = Self::normalize_logical_path(path);
        let base_dir = if normalized.is_empty() {
            self.base_dir.clone()
        } else {
            self.base_dir.join(&normalized)
        };
        if base_dir.is_dir() {
            let rd = std::fs::read_dir(&base_dir).map_err(|e| {
                EngineError::FileSystemError(format!("Cannot read directory '{}': {}", path, e))
            })?;
            for entry in rd.flatten() {
                if let Some(name) = entry.file_name().to_str() {
                    items.insert(name.to_string());
                }
            }
        }
        for layer in &self.mounts {
            if let Some(relative) =
                Self::relative_inside_mount(normalized.as_str(), layer.mountpoint.as_str())
            {
                let dir = if relative.is_empty() {
                    layer.source.clone()
                } else {
                    layer.source.join(relative)
                };
                if dir.is_dir() {
                    if let Ok(rd) = std::fs::read_dir(&dir) {
                        for entry in rd.flatten() {
                            if let Some(name) = entry.file_name().to_str() {
                                items.insert(name.to_string());
                            }
                        }
                    }
                }
                continue;
            }
            if let Some(relative_mount) =
                Self::mount_suffix_below_path(normalized.as_str(), layer.mountpoint.as_str())
            {
                if let Some(first_segment) = relative_mount.split('/').next() {
                    items.insert(first_segment.to_string());
                }
            }
        }
        let mut result: Vec<String> = items.into_iter().collect();
        result.sort();
        Ok(result)
    }
    /// Resolve a readable path into a canonical host path or return a filesystem error.
    pub fn resolve_read_path(&self, path: &str) -> EngineResult<PathBuf> {
        let normalized = Self::normalize_logical_path(path);
        Self::reject_traversal(normalized.as_str())?;
        if let Some(resolved) = self.resolve_mount_read_path(normalized.as_str())? {
            return Ok(resolved);
        }
        let full = if normalized.is_empty() {
            self.base_dir.clone()
        } else {
            self.base_dir.join(&normalized)
        };
        let canonical = full.canonicalize().map_err(|e| {
            EngineError::FileSystemError(format!("Cannot resolve '{}': {}", path, e))
        })?;
        let base_canonical = self
            .base_dir
            .canonicalize()
            .map_err(|e| EngineError::FileSystemError(format!("Cannot resolve base dir: {}", e)))?;
        if !canonical.starts_with(&base_canonical) {
            return Err(EngineError::FileSystemError(
                "Access denied: path traversal detected".into(),
            ));
        }
        Ok(canonical)
    }
    /// Resolve a writable path inside save/ or return a filesystem error.
    pub fn resolve_save_path(&self, path: &str) -> EngineResult<PathBuf> {
        let full = self.base_dir.join(path);
        let save_dir = self.base_dir.join(SAVE_ROOT);
        if !full.starts_with(&save_dir) {
            return Err(EngineError::FileSystemError(
                "Write access restricted to save/ directory".into(),
            ));
        }
        Self::reject_traversal(path)?;
        Ok(full)
    }
    /// Read a file and split it into owned lines.
    pub fn read_lines(&self, path: &str) -> EngineResult<Vec<String>> {
        let content = self.read_string(path)?;
        Ok(content.lines().map(|l| l.to_string()).collect())
    }
    /// Open a file handle from a mode string or return a filesystem error.
    pub fn open_file(&self, path: &str, mode_str: &str) -> EngineResult<FileHandle> {
        let mode = FileMode::parse_mode(mode_str)?;
        FileHandle::open(self, path, mode)
    }
    /// Copy a file into the save filesystem or return a filesystem error.
    pub fn copy_file(&self, src: &str, dst: &str) -> EngineResult<()> {
        let src_path = self.resolve_read_path(src)?;
        let dst_path = self.resolve_save_path(dst)?;
        if let Some(parent) = dst_path.parent() {
            std::fs::create_dir_all(parent).map_err(|e| {
                EngineError::FileSystemError(format!("Cannot create parent dirs: {}", e))
            })?;
        }
        std::fs::copy(&src_path, &dst_path).map_err(|e| {
            EngineError::FileSystemError(format!("copy_file '{}' → '{}': {}", src, dst, e))
        })?;
        Ok(())
    }
    /// Move a file inside the save filesystem or return a filesystem error.
    pub fn move_file(&self, src: &str, dst: &str) -> EngineResult<()> {
        let src_path = self.resolve_save_path(src)?;
        let dst_path = self.resolve_save_path(dst)?;
        if let Some(parent) = dst_path.parent() {
            std::fs::create_dir_all(parent).map_err(|e| {
                EngineError::FileSystemError(format!("Cannot create parent dirs: {}", e))
            })?;
        }
        std::fs::rename(&src_path, &dst_path).map_err(|e| {
            EngineError::FileSystemError(format!("move_file '{}' → '{}': {}", src, dst, e))
        })
    }
    /// Remove a directory tree from the save filesystem or return a filesystem error.
    pub fn remove_dir(&self, path: &str) -> EngineResult<()> {
        let dir_path = self.resolve_save_path(path)?;
        if !dir_path.is_dir() {
            return Err(EngineError::FileSystemError(format!(
                "remove_dir: '{}' is not a directory",
                path
            )));
        }
        std::fs::remove_dir_all(&dir_path)
            .map_err(|e| EngineError::FileSystemError(format!("remove_dir '{}': {}", path, e)))
    }
    /// Return sorted matches for a glob pattern within a readable directory.
    pub fn glob(&self, pattern: &str) -> EngineResult<Vec<String>> {
        let (dir_part, file_pattern) = match pattern.rfind('/') {
            Some(idx) => (&pattern[..idx], &pattern[idx + 1..]),
            None => (".", pattern),
        };
        let mut matches: Vec<String> = Vec::new();
        for name in self.get_directory_items(dir_part)? {
            if glob_match(file_pattern, &name) {
                let rel = if dir_part == "." {
                    name
                } else {
                    format!("{}/{}", dir_part, name)
                };
                matches.push(rel);
            }
        }
        matches.sort();
        Ok(matches)
    }
    /// Return size and kind flags for the resolved path.
    pub fn stat(&self, path: &str) -> EngineResult<(u64, bool, bool)> {
        let resolved = self.resolve_read_path(path)?;
        let meta = std::fs::metadata(&resolved).map_err(|e| {
            EngineError::FileSystemError(format!("stat failed for '{}': {}", path, e))
        })?;
        Ok((meta.len(), meta.is_file(), meta.is_dir()))
    }
    /// Create a unique temporary file under save/ and return its logical path.
    pub fn create_temp_file(&self, prefix: &str) -> EngineResult<String> {
        let save_dir = self.base_dir.join(SAVE_TEMP_DIR);
        std::fs::create_dir_all(&save_dir).map_err(|e| {
            EngineError::FileSystemError(format!(
                "create_temp_file: cannot create {}: {}",
                SAVE_TEMP_DIR, e
            ))
        })?;
        let ts = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .map(|d| d.as_micros())
            .unwrap_or(0);
        static COUNTER: std::sync::atomic::AtomicU32 = std::sync::atomic::AtomicU32::new(0);
        let n = COUNTER.fetch_add(1, std::sync::atomic::Ordering::Relaxed);
        let safe_prefix = prefix
            .chars()
            .map(|c| {
                if c.is_alphanumeric() || c == '_' || c == '-' {
                    c
                } else {
                    '_'
                }
            })
            .take(32)
            .collect::<String>();
        let filename = format!("{}{}_{}.tmp", safe_prefix, ts, n);
        let full_path = save_dir.join(&filename);
        std::fs::File::create(&full_path).map_err(|e| {
            EngineError::FileSystemError(format!("create_temp_file: cannot create file: {}", e))
        })?;
        Ok(format!("{}/{}", SAVE_TEMP_DIR, filename))
    }
}
/// Provide dataframe file persistence storage operations through GameFS.
impl DataFrameFileStore for GameFS {
    type Error = EngineError;

    /// Read UTF-8 content through GameFS.
    fn read_string(&self, path: &str) -> EngineResult<String> {
        GameFS::read_string(self, path)
    }

    /// Read JSON content through GameFS validation.
    fn read_json(&self, path: &str) -> EngineResult<String> {
        GameFS::read_json(self, path)
    }

    /// Read binary content through GameFS.
    fn read_bytes(&self, path: &str) -> EngineResult<Vec<u8>> {
        GameFS::read_bytes(self, path)
    }

    /// Write UTF-8 content through GameFS.
    fn write_string(&self, path: &str, content: &str) -> EngineResult<()> {
        GameFS::write_string(self, path, content)
    }

    /// Write JSON content through GameFS validation.
    fn write_json(&self, path: &str, json: &str) -> EngineResult<()> {
        GameFS::write_json(self, path, json)
    }

    /// Write binary content through GameFS.
    fn write_bytes(&self, path: &str, bytes: &[u8]) -> EngineResult<()> {
        GameFS::write_bytes(self, path, bytes)
    }
}
/// Match a glob pattern against a file name using '*' and '?' only.
fn glob_match(pattern: &str, name: &str) -> bool {
    let pat: Vec<char> = pattern.chars().collect();
    let txt: Vec<char> = name.chars().collect();
    glob_match_inner(&pat, &txt)
}
/// Recurse through glob pattern and text slices for wildcard matching.
fn glob_match_inner(pat: &[char], txt: &[char]) -> bool {
    match (pat.first(), txt.first()) {
        (None, None) => true,
        (Some('*'), _) => {
            glob_match_inner(&pat[1..], txt)
                || (!txt.is_empty() && glob_match_inner(pat, &txt[1..]))
        }
        (Some('?'), Some(_)) => glob_match_inner(&pat[1..], &txt[1..]),
        (Some(p), Some(t)) if p == t => glob_match_inner(&pat[1..], &txt[1..]),
        _ => false,
    }
}
