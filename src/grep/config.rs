//! Grep engine configuration: thread count, file size limits, and encoding settings.
//!
//! - Data type: `GrepConfig`.

/// Grep engine search configuration.
#[derive(Debug, Clone)]
pub struct GrepConfig {
    /// Number of worker threads for parallel search.
    pub thread_count: usize,
    /// Maximum file size in bytes to search.
    pub max_file_size: u64,
    /// Whether pattern matching is case-sensitive.
    pub case_sensitive: bool,
    /// Whether to match whole words only.
    pub whole_word: bool,
    /// Maximum number of results to return.
    pub max_results: usize,
    /// Number of context lines around each match.
    pub context_lines: usize,
}

impl Default for GrepConfig {
    fn default() -> Self {
        Self {
            thread_count: 4,
            max_file_size: 50 * 1024 * 1024,
            case_sensitive: true,
            whole_word: false,
            max_results: 10000,
            context_lines: 0,
        }
    }
}
