//! - Search result types: per-line matches, per-file matches, and totals.
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

    /// Limit returned matches to at most `max_matches` total match spans.
    pub fn limit_total_matches(mut self, max_matches: usize) -> Self {
        if max_matches == 0 {
            self.matches.clear();
            self.files_matched = 0;
            self.total_matches = 0;
            return self;
        }

        let mut remaining = max_matches;
        let mut limited_files = Vec::new();
        for mut file_match in self.matches.into_iter() {
            if remaining == 0 {
                break;
            }

            let mut kept_lines = Vec::new();
            let mut file_total = 0;
            for mut line in file_match.lines.into_iter() {
                let line_total = line.positions.len().max(1);
                if line_total > remaining {
                    if !line.positions.is_empty() && remaining > 0 {
                        line.positions.truncate(remaining);
                        file_total += line.positions.len();
                        kept_lines.push(line);
                        remaining = 0;
                    }
                    break;
                }
                remaining -= line_total;
                file_total += line_total;
                kept_lines.push(line);
            }

            if !kept_lines.is_empty() {
                file_match.lines = kept_lines;
                file_match.total_matches = file_total;
                limited_files.push(file_match);
            }
        }

        self.matches = limited_files;
        self.files_matched = self.matches.len();
        self.total_matches = self.matches.iter().map(|m| m.total_matches).sum();
        self
    }
}
