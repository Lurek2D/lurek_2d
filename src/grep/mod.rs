//! This module re-exports the grep subsystem surface for config, filtering, matching, readers, and search results.
//! It exists as the navigation map that tells callers which sibling files own engine flow, pattern kinds, or log helpers.
//! `engine.rs` drives top-level searches, while `parallel.rs` and `reader.rs` cover filesystem work and file loading.
//! `matcher.rs` and `pattern.rs` define how literal, regex-like, glob, fuzzy, and multi-pattern checks are evaluated.
//! `filter.rs`, `json_search.rs`, and `log_search.rs` narrow scope or parse structured content beyond raw text lines.
//! Change this file when the public grep symbol map moves; change siblings when search behavior or data rules change.

/// Grep configuration: thread count, file size limits, and encoding settings.
pub mod config;
/// High-level search engine combining configuration, filter, and matcher.
pub mod engine;
/// File extension and path filters for narrowing the search scope.
pub mod filter;
/// JSON path search for structured key-value queries within JSON files.
pub mod json_search;
/// Structured log file search with level, time, and pattern filters.
pub mod log_search;
/// Low-level pattern matcher wrapping all supported pattern kinds.
pub mod matcher;
/// Parallel file search distributing work across a configurable thread pool.
pub mod parallel;
/// Pattern kinds: literal, regex, glob, fuzzy, and multi-literal.
pub mod pattern;
/// File reading utilities: buffered I/O with size gating.
pub mod reader;
/// Search result types: per-line matches, per-file matches, and totals.
pub mod result;

pub use config::GrepConfig;
pub use engine::GrepEngine;
pub use filter::FileFilter;
pub use matcher::Matcher;
pub use parallel::ParallelSearch;
pub use pattern::PatternKind;
pub use reader::FileReader;
pub use result::{FileMatch, LineMatch, SearchResult};
