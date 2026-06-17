//! Grep engine configuration: thread count, file size limits, and encoding settings. `grep/config` delivers the configuration schema and defaults for the grep subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! `GrepConfig` holds `thread_count`, `max_file_size`, `case_sensitive`, and `whole_word`. The file owns or coordinates data contracts including `GrepConfig`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Deserialized from the `[grep]` TOML block or constructed via Lua table defaults. Public callable behavior is centered on no named public items, while method-level behavior such as no named public items stays attached to the local data model and invariants.

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
