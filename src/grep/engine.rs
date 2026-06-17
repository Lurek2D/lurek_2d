//! High-level search engine: wires configuration, file filter, and pattern matcher. `grep/engine` delivers the engine implementation for the grep subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Delegates file discovery to `FileFilter` and matching to the lightweight `Matcher`. The file owns or coordinates data contracts including `GrepEngine`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Work is split across a small std-thread worker set sized from `GrepConfig::thread_count`. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `search_literal`, `search_regex`, `search_multi`, `search_files`, `count`, and 1 more stays attached to the local data model and invariants.
//! Returned results are deterministically sorted and capped by `GrepConfig::max_results`. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

use super::config::GrepConfig;
use super::filter::FileFilter;
use super::matcher::Matcher;
use super::parallel::ParallelSearch;
use super::pattern::PatternKind;
use super::result::SearchResult;
use std::path::{Path, PathBuf};

/// Main search engine combining configuration, file filter, and pattern matcher.
pub struct GrepEngine {
    config: GrepConfig,
    parallel: ParallelSearch,
}

impl GrepEngine {
    /// Apply the configured result cap to a collected search result.
    fn cap_result(&self, result: SearchResult) -> SearchResult {
        result.limit_total_matches(self.config.max_results)
    }

    /// Create a new `GrepEngine` using the provided configuration.
    pub fn new(config: GrepConfig) -> Self {
        let parallel = ParallelSearch::new(config.thread_count, config.max_file_size);
        Self { config, parallel }
    }

    /// Search a directory with a literal pattern.
    pub fn search_literal(&self, root: &Path, pattern: &str, filter: &FileFilter) -> SearchResult {
        let matcher = Matcher::new(
            PatternKind::literal(pattern),
            self.config.case_sensitive,
            self.config.whole_word,
        );
        self.cap_result(self.parallel.search(root, &matcher, filter))
    }

    /// Search a directory with a regex pattern.
    pub fn search_regex(&self, root: &Path, pattern: &str, filter: &FileFilter) -> SearchResult {
        let matcher = Matcher::new(
            PatternKind::regex(pattern),
            self.config.case_sensitive,
            self.config.whole_word,
        );
        self.cap_result(self.parallel.search(root, &matcher, filter))
    }

    /// Search a directory with multiple literal patterns.
    pub fn search_multi(
        &self,
        root: &Path,
        patterns: Vec<String>,
        filter: &FileFilter,
    ) -> SearchResult {
        let matcher = Matcher::new(
            PatternKind::multi_literal(patterns),
            self.config.case_sensitive,
            self.config.whole_word,
        );
        self.cap_result(self.parallel.search(root, &matcher, filter))
    }

    /// Search a specific list of files for matches.
    pub fn search_files(&self, files: &[PathBuf], pattern: &str) -> SearchResult {
        let matcher = Matcher::new(
            PatternKind::literal(pattern),
            self.config.case_sensitive,
            self.config.whole_word,
        );
        self.cap_result(self.parallel.search_files(files, &matcher))
    }

    /// Count matches without collecting line details.
    pub fn count(&self, root: &Path, pattern: &str, filter: &FileFilter) -> usize {
        let result = self.search_literal(root, pattern, filter);
        result.total_matches
    }

    /// Return a shared reference to this engine's configuration.
    pub fn config(&self) -> &GrepConfig {
        &self.config
    }
}

impl Default for GrepEngine {
    fn default() -> Self {
        Self::new(GrepConfig::default())
    }
}
