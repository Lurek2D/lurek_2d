//! Text search engine for game and tooling content files. `grep/mod` is the grep module index, declaring `config`, `engine`, `filter`, `json_search`, `log_search`, and 5 more so agents can identify which files own each feature slice before opening implementation code.
//! Literal-first matching with simplified regex/glob/fuzzy helpers and multi-pattern search. `src/grep/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `config::GrepConfig`, `engine::GrepEngine`, `filter::FileFilter`, `matcher::Matcher`, and 4 more centralized for the grep subsystem.
//! Buffered file reading with a configurable size cap. The file documents how grep submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.
//! Deterministic std-thread parallel file search for directory scans. Agents should read this index to choose the narrow owner file first, because it maps names such as `config`, `engine`, `filter`, `json_search`, `log_search`, and 5 more to concrete implementation responsibilities.
//! Specialized JSON path search and log file parsing. Re-export decisions in this file define the stable Rust boundary consumed by sibling modules, Lua bindings, generated specs, and examples that mention grep features.
//! No streaming callbacks or memory-mapped reader in the current implementation. The module stays implementation-light by delegating behavior to child files, which preserves a clear boundary between navigation metadata and executable subsystem logic.

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
