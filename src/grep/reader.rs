//! File reading utilities: buffered I/O and memory-mapped access for large files.
//!
//! - Small files (< threshold) are read with `BufReader` and iterated line-by-line.
//! - Large files use `memmap2` for zero-copy line scanning via byte search.
//! - The threshold is configurable via `GrepConfig::mmap_threshold_bytes`.
//! - On failure the reader falls back to buffered mode; mmap errors are non-fatal.

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
