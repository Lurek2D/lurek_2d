//! This file owns `ValidatorConfig`, the execution policy record that shapes how validator scans should run.
//! It stores worker count, maximum file size, early-stop behavior, and hint inclusion defaults in one place.
//! Open this file when validator runtime policy changes; rule logic and report formatting belong to siblings.

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
