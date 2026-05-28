//! High-level search engine: wires configuration, file filter, and pattern matcher.
//!
//! - Data type: `GrepEngine`.
//! - Implementation: `GrepEngine`.

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
        self.parallel.search(root, &matcher, filter)
    }

    /// Search a directory with a regex pattern.
    pub fn search_regex(&self, root: &Path, pattern: &str, filter: &FileFilter) -> SearchResult {
        let matcher = Matcher::new(
            PatternKind::regex(pattern),
            self.config.case_sensitive,
            self.config.whole_word,
        );
        self.parallel.search(root, &matcher, filter)
    }

    /// Search a directory with multiple literal patterns.
    pub fn search_multi(&self, root: &Path, patterns: Vec<String>, filter: &FileFilter) -> SearchResult {
        let matcher = Matcher::new(
            PatternKind::multi_literal(patterns),
            self.config.case_sensitive,
            self.config.whole_word,
        );
        self.parallel.search(root, &matcher, filter)
    }

    /// Search a specific list of files for matches.
    pub fn search_files(&self, files: &[PathBuf], pattern: &str) -> SearchResult {
        let matcher = Matcher::new(
            PatternKind::literal(pattern),
            self.config.case_sensitive,
            self.config.whole_word,
        );
        self.parallel.search_files(files, &matcher)
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
