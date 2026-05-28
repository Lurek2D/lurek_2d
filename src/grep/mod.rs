//! Text search engine for game content files.
//!
//! - Sub-modules: `config`, `engine`, `filter`, `json_search`, and 6 more.

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
/// File reading utilities: buffered I/O and memory-mapped file access.
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
