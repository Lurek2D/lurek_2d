//! File-system watcher that detects modifications by polling `mtime`.
//!
//! [`FileWatcher`] keeps a snapshot of last-modified times for each watched
//! path.  On every [`poll`][FileWatcher::poll] call it checks for changes and
//! returns any modified paths.  Directories are watched non-recursively; add
//! individual file paths for precise control.

use std::collections::HashMap;
use std::path::{Path, PathBuf};
use std::time::SystemTime;

// ── FileWatcher ────────────────────────────────────────────────────────────

/// Polling-based file-modification watcher.
///
/// # Fields
/// - `paths` — `HashMap<PathBuf, Option<SystemTime>>`.
#[derive(Debug, Default)]
pub struct FileWatcher {
    /// Map from watched path to last-known mtime (None = newly added, not yet polled).
    pub paths: HashMap<PathBuf, Option<SystemTime>>,
}

impl FileWatcher {
    /// Creates a new empty watcher.
    ///
    /// # Returns
    /// `Self`.
    pub fn new() -> Self {
        Self::default()
    }

    /// Adds a path to the watch list.  Accepts both files and directories.
    ///
    /// # Parameters
    /// - `path` — `&str`.
    pub fn watch(&mut self, path: &str) {
        let p = PathBuf::from(path);
        self.paths.entry(p).or_insert(None);
    }

    /// Removes a path from the watch list.
    ///
    /// # Parameters
    /// - `path` — `&str`.
    ///
    /// # Returns
    /// `bool`.
    pub fn unwatch(&mut self, path: &str) -> bool {
        self.paths.remove(Path::new(path)).is_some()
    }

    /// Returns all currently watched paths.
    ///
    /// # Returns
    /// `Vec<String>`.
    pub fn watched_paths(&self) -> Vec<String> {
        self.paths.keys().map(|p| p.to_string_lossy().into_owned()).collect()
    }

    /// Polls all watched paths and returns paths that have changed since the
    /// last call to `poll`.
    ///
    /// # Returns
    /// `Vec<String>` of paths whose mtime changed.
    pub fn poll(&mut self) -> Vec<String> {
        let mut changed = Vec::new();
        for (path, last) in &mut self.paths {
            let current_mtime = Self::mtime(path);
            match (&*last, current_mtime) {
                (None, new) => {
                    // First poll — record baseline without marking as changed.
                    *last = new;
                }
                (Some(prev), Some(cur)) if cur != *prev => {
                    changed.push(path.to_string_lossy().into_owned());
                    *last = Some(cur);
                }
                (Some(_), None) => {
                    // File disappeared — treat as changed.
                    changed.push(path.to_string_lossy().into_owned());
                    *last = None;
                }
                _ => {}
            }
        }
        changed
    }

    /// Clears all watched paths.
    pub fn clear(&mut self) {
        self.paths.clear();
    }

    fn mtime(path: &Path) -> Option<SystemTime> {
        std::fs::metadata(path).ok()?.modified().ok()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn new_watcher_is_empty() {
        let w = FileWatcher::new();
        assert!(w.paths.is_empty());
    }

    #[test]
    fn watch_and_unwatch() {
        let mut w = FileWatcher::new();
        w.watch("test.txt");
        assert_eq!(w.watched_paths().len(), 1);
        assert!(w.unwatch("test.txt"));
        assert!(w.paths.is_empty());
    }

    #[test]
    fn unwatch_nonexistent_returns_false() {
        let mut w = FileWatcher::new();
        assert!(!w.unwatch("missing.txt"));
    }

    #[test]
    fn clear_removes_all() {
        let mut w = FileWatcher::new();
        w.watch("a.txt");
        w.watch("b.txt");
        w.clear();
        assert!(w.paths.is_empty());
    }

    #[test]
    fn poll_nonexistent_file_no_panic() {
        let mut w = FileWatcher::new();
        w.watch("nonexistent_file_12345.txt");
        let changed = w.poll();
        assert!(changed.is_empty(), "first poll should be baseline");
    }
}
