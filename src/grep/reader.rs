//! File reading utilities: buffered I/O with a simple size gate. `grep/reader` delivers the reader implementation for the grep subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Files larger than the configured limit are skipped instead of partially streamed. The file owns or coordinates data contracts including `FileReader`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Callers can read line-by-line or whole-file UTF-8 content through the same helper. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `read_lines`, `read_string`, `is_readable` stays attached to the local data model and invariants.

use std::fs;
use std::io::{self, BufRead, BufReader};
use std::path::Path;

/// File reader with optional memory-mapped I/O.
pub struct FileReader {
    max_file_size: u64,
}

impl FileReader {
    /// Create a file reader that skips files larger than `max_file_size` bytes.
    pub fn new(max_file_size: u64) -> Self {
        Self { max_file_size }
    }

    /// Read file lines. Returns None if file is too large or unreadable.
    pub fn read_lines(&self, path: &Path) -> Option<Vec<String>> {
        let metadata = fs::metadata(path).ok()?;
        if metadata.len() > self.max_file_size {
            return None;
        }
        let file = fs::File::open(path).ok()?;
        let reader = BufReader::new(file);
        let lines: io::Result<Vec<String>> = reader.lines().collect();
        lines.ok()
    }

    /// Read file contents as a single string.
    pub fn read_string(&self, path: &Path) -> Option<String> {
        let metadata = fs::metadata(path).ok()?;
        if metadata.len() > self.max_file_size {
            return None;
        }
        fs::read_to_string(path).ok()
    }

    /// Check if file is within size limit.
    pub fn is_readable(&self, path: &Path) -> bool {
        match fs::metadata(path) {
            Ok(m) => m.len() <= self.max_file_size && m.is_file(),
            Err(_) => false,
        }
    }
}

impl Default for FileReader {
    fn default() -> Self {
        Self::new(50 * 1024 * 1024) // 50 MB default limit
    }
}
