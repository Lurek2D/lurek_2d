//! This file provides configuration structures that shape validator execution policy. `validator/config` delivers the configuration schema and defaults for the validator subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

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
