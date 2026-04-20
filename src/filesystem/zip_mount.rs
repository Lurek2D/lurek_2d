//! ZIP archive mounting — read-only virtual filesystem layer backed by a `.zip` file.
//!
//! [`ZipMount`] wraps a `.zip` archive and exposes its contents through a virtual
//! path prefix.  Every access goes through an in-memory central-directory index built
//! once at mount time, so repeated lookups are O(1).
//!
//! ## Security
//! Virtual paths are normalised before lookup.  Paths containing `..` components or
//! starting with `/` or a drive letter are rejected with an [`Err`] to prevent
//! traversal out of the mount point.

use std::collections::HashMap;
use std::io::Read;
use std::path::{Path, PathBuf};

/// A read-only mount backed by a `.zip` file.
///
/// Created via [`ZipMount::new`] and queried via [`ZipMount::read_file`],
/// [`ZipMount::contains`], and [`ZipMount::list_files`].
pub struct ZipMount {
    /// Path to the source `.zip` file on disk.
    pub archive_path: PathBuf,
    /// Virtual prefix under which zip entries are reachable (e.g. `"mods/extra"`).
    pub prefix: String,
    /// Pre-built map from *normalised virtual path* → *zip entry name*.
    index: HashMap<String, String>,
}

impl ZipMount {
    /// Opens a ZIP archive at `archive_path` and builds the entry index.
    ///
    /// `prefix` is the virtual filesystem root under which zip contents appear.
    /// Pass an empty string to mount at the root.
    ///
    /// # Errors
    /// Returns an error string if the file cannot be opened or parsed as a ZIP.
    pub fn new<P: AsRef<Path>>(archive_path: P, prefix: &str) -> Result<Self, String> {
        let path = archive_path.as_ref().to_path_buf();
        let file = std::fs::File::open(&path)
            .map_err(|e| format!("ZipMount: cannot open '{}': {}", path.display(), e))?;

        let archive = zip::ZipArchive::new(file)
            .map_err(|e| format!("ZipMount: invalid ZIP '{}': {}", path.display(), e))?;

        let clean_prefix = prefix.trim_matches('/').to_string();

        let mut index = HashMap::new();
        for i in 0..archive.len() {
            // Re-open to enumerate without moving ownership.
            let file2 = std::fs::File::open(&path)
                .map_err(|e| format!("ZipMount: re-open failed: {}", e))?;
            let mut arc2 = zip::ZipArchive::new(file2)
                .map_err(|e| format!("ZipMount: re-open parse failed: {}", e))?;
            let entry = arc2
                .by_index(i)
                .map_err(|e| format!("ZipMount: index {}: {}", i, e))?;
            let entry_name = entry.name().to_string();
            if entry.is_file() {
                let virtual_path = if clean_prefix.is_empty() {
                    entry_name.clone()
                } else {
                    format!("{}/{}", clean_prefix, entry_name)
                };
                index.insert(normalise(&virtual_path), entry_name);
            }
        }

        Ok(Self {
            archive_path: path,
            prefix: clean_prefix,
            index,
        })
    }

    /// Reads the contents of `virtual_path` from the ZIP.
    ///
    /// `virtual_path` is resolved relative to the mount prefix.  Returns the raw bytes
    /// on success.
    ///
    /// # Errors
    /// Returns an error string for path traversal attempts, missing entries, or I/O failures.
    pub fn read_file(&self, virtual_path: &str) -> Result<Vec<u8>, String> {
        let norm = normalise(virtual_path);
        if is_traversal(&norm) {
            return Err(format!(
                "ZipMount: path traversal rejected: '{}'",
                virtual_path
            ));
        }
        let entry_name = self
            .index
            .get(&norm)
            .ok_or_else(|| format!("ZipMount: file not found: '{}'", virtual_path))?
            .clone();

        let file = std::fs::File::open(&self.archive_path)
            .map_err(|e| format!("ZipMount: cannot open archive: {}", e))?;
        let mut archive =
            zip::ZipArchive::new(file).map_err(|e| format!("ZipMount: parse error: {}", e))?;
        let mut entry = archive
            .by_name(&entry_name)
            .map_err(|e| format!("ZipMount: entry '{}' not found: {}", entry_name, e))?;

        let mut buf = Vec::with_capacity(entry.size() as usize);
        entry
            .read_to_end(&mut buf)
            .map_err(|e| format!("ZipMount: read error: {}", e))?;
        Ok(buf)
    }

    /// Returns `true` if `virtual_path` exists in this ZIP mount.
    pub fn contains(&self, virtual_path: &str) -> bool {
        let norm = normalise(virtual_path);
        self.index.contains_key(&norm)
    }

    /// Returns a sorted list of all virtual file paths exposed by this mount.
    pub fn list_files(&self) -> Vec<String> {
        let mut paths: Vec<String> = self.index.keys().cloned().collect();
        paths.sort();
        paths
    }
}

// ── Helpers ─────────────────────────────────────────────────────────────────

/// Normalise a path: collapse duplicate slashes, strip leading slash.
pub fn normalise(path: &str) -> String {
    let cleaned = path.replace('\\', "/");
    let parts: Vec<&str> = cleaned.split('/').filter(|s| !s.is_empty()).collect();
    parts.join("/")
}

/// Returns `true` if any path component is `..`, or if the path starts with
/// a drive letter (Windows absolute), to prevent traversal attacks.
pub fn is_traversal(path: &str) -> bool {
    path.contains("..") || path.starts_with('/') || (path.len() >= 2 && path.as_bytes()[1] == b':')
}
