//! Search result types: per-line matches, per-file matches, and totals.
//!
//! - `LineMatch` carries `line_number`, `content` string, and `positions` spans.
//! - `FileMatch` groups `Vec<LineMatch>` under a `PathBuf` source path.
//! - `GrepResult` is the top-level return: `matches`, `files_searched`, `total_matches`.
//! - All types are `Debug + Clone`; `GrepResult` implements `Display` for summary output.

use std::path::PathBuf;

/// A single line that matched the search pattern, with position spans.
#[derive(Debug, Clone)]
pub struct LineMatch {
    /// Line number (1-based) in the source file.
    pub line_number: usize,
    /// Raw text content of the matching line.
    pub content: String,
    /// Byte positions of the match spans within the line.
    pub positions: Vec<(usize, usize)>,
}

/// All matches within a single file.
#[derive(Debug, Clone)]
pub struct FileMatch {
    /// File system path.
    pub path: PathBuf,
    /// Matching lines found in this file.
    pub lines: Vec<LineMatch>,
    /// Total number of matching lines found.
    pub total_matches: usize,
}

/// Complete search result across all files.
#[derive(Debug, Clone)]
pub struct SearchResult {
    /// Per-file match results.
    pub matches: Vec<FileMatch>,
    /// Total number of files searched.
    pub files_searched: usize,
    /// Files matched.
    pub files_matched: usize,
    /// Total number of matching lines found.
    pub total_matches: usize,
    /// Frame display duration in milliseconds.
    pub duration_ms: u64,
}

impl SearchResult {
    /// Create an empty search result with all counts at zero.
    pub fn empty() -> Self {
        Self {
            matches: Vec::new(),
            files_searched: 0,
            files_matched: 0,
            total_matches: 0,
            duration_ms: 0,
        }
    }

    /// Return `true` if the result contains no file matches.
    pub fn is_empty(&self) -> bool {
        self.matches.is_empty()
    }
}
