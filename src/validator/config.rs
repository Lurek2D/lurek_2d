//! Validator engine configuration: search paths, rule sets, and extension filters.

/// Validator engine configuration.
#[derive(Debug, Clone)]
pub struct ValidatorConfig {
    /// Number of worker threads for parallel search.
    pub thread_count: usize,
    /// Maximum file size in bytes to search.
    pub max_file_size: u64,
    /// Stop on first error.
    pub stop_on_first_error: bool,
    /// Include hints.
    pub include_hints: bool,
}

impl Default for ValidatorConfig {
    fn default() -> Self {
        Self {
            thread_count: 4,
            max_file_size: 10 * 1024 * 1024,
            stop_on_first_error: false,
            include_hints: true,
        }
    }
}
