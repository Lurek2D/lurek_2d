# grep

## TL;DR



## General Info

- Module group: `Edge/Integration`
- Source path: `src/grep/`
- Lua API path(s): `src/lua_api/grep_api.rs`
- Primary Lua namespace: `lurek.grep`
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

The `grep` module is documented from the current source tree and existing module reference data.

This module is mostly self-contained inside the Edge/Integration group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Source Documentation

### `config.rs`
- Grep engine configuration: thread count, file size limits, and encoding settings.
- `GrepConfig` holds `thread_count`, `max_file_size`, `case_sensitive`, and `whole_word`.
- Deserialized from the `[grep]` TOML block or constructed via Lua table defaults.
- `thread_count` defaults to `num_cpus / 2`; 0 means single-threaded.
- `max_file_size` prevents accidentally reading binary assets during a code search.

### `engine.rs`
- High-level search engine: wires configuration, file filter, and pattern matcher.
- `GrepEngine::run(root, pattern)` returns a `GrepResult` across all matching files.
- Delegates file discovery to `FileFilter` and matching to `Matcher`.
- Work is split across a Rayon thread pool sized from `GrepConfig::thread_count`.
- Used by `lurek.grep.*` Lua API; the Lua binding owns the config lifecycle.

### `filter.rs`
- File extension and path filters for narrowing the search scope.
- `FileFilter` accepts `include_extensions`, `exclude_extensions`, and glob patterns.
- `FileFilter::matches(path)` is a pure predicate; no I/O at the filter stage.
- Hidden files and directories starting with `.` are excluded by default.
- Configured from `GrepConfig` or directly by Lua via `lurek.grep.set_filter`.

### `json_search.rs`
- JSON path search: query structured key-value paths within JSON files.
- `search_json_path` scans a directory for JSON files and extracts values at a path.
- `search_json_file` operates on a single file; returns `Option<serde_json::Value>`.
- Path syntax uses `/`-separated keys; arrays are addressed by numeric index.
- Exposed to Lua via `lurek.grep.json_path(dir, path)` in `grep_api.rs`.

### `log_search.rs`
- Structured log file search with level, time-range, and text pattern filters.
- `parse_log_lines` parses lines of the form `[LEVEL TIMESTAMP] MESSAGE`.
- `search_logs` filters `Vec<LogEntry>` by level, time bounds, and text pattern.
- `LogSearchOpts` drives the filter; all fields are optional (zero = no filter).
- Used by `lurek.grep.logs` to let game scripts query the engine's runtime log.

### `matcher.rs`
- Low-level pattern matcher: wraps all supported pattern kinds behind one trait.
- `Matcher` implements literal, regex, glob, and fuzzy match against a `&str`.
- Returns a `Vec<(usize, usize)>` of byte-span matches within the target string.
- Regex variant compiles once and is reused across all lines in a file.
- Fuzzy variant uses edit-distance threshold configurable via `GrepConfig`.

### `mod.rs`
- Text search engine for game content files.
- Literal, regex, glob, and multi-pattern search.
- Memory-mapped file reading for large files.
- Parallel file search with rayon-style thread distribution.
- Specialized JSON path search and log file parsing.
- Streaming mode with callbacks for real-time results.

### `parallel.rs`
- Parallel file search: distributes work across a Rayon thread pool.
- `validate_parallel` is the primary entry point; returns a flat `Vec<Violation>`.
- `collect_lua_files` / `collect_files_with_ext` enumerate files before dispatch.
- Each worker receives a slice of paths; results are merged after the pool drains.
- Thread count comes from `GrepConfig`; 0 forces synchronous single-threaded mode.

### `pattern.rs`
- Pattern kinds: literal, regex, glob, fuzzy, and multi-literal match strategies.
- `PatternKind` is the discriminant stored in `Matcher` to select dispatch logic.
- `Literal` and `MultiLiteral` use Aho-Corasick for sub-linear multi-pattern search.
- `Regex` wraps the `regex` crate; patterns are validated at construction time.
- `Glob` converts shell-style `*`/`?` patterns to a regex and reuses the regex path.
- `Fuzzy` uses Levenshtein distance with a configurable `max_edit_distance`.

### `reader.rs`
- File reading utilities: buffered I/O and memory-mapped access for large files.
- Small files (< threshold) are read with `BufReader` and iterated line-by-line.
- Large files use `memmap2` for zero-copy line scanning via byte search.
- The threshold is configurable via `GrepConfig::mmap_threshold_bytes`.
- On failure the reader falls back to buffered mode; mmap errors are non-fatal.

### `result.rs`
- Search result types: per-line matches, per-file matches, and totals.
- `LineMatch` carries `line_number`, `content` string, and `positions` spans.
- `FileMatch` groups `Vec<LineMatch>` under a `PathBuf` source path.
- `GrepResult` is the top-level return: `matches`, `files_searched`, `total_matches`.
- All types are `Debug + Clone`; `GrepResult` implements `Display` for summary output.

## Types

- `GrepConfig` (`struct`, `config.rs`): Grep engine search configuration.
- `GrepEngine` (`struct`, `engine.rs`): Main search engine combining configuration, file filter, and pattern matcher.
- `FileFilter` (`struct`, `filter.rs`): Filter rules for which files to include in search.
- `JsonMatch` (`struct`, `json_search.rs`): Result of a JSON key-path search.
- `LogEntry` (`struct`, `log_search.rs`): A single parsed log entry with line number, timestamp, level, and message.
- `LogSearchOpts` (`struct`, `log_search.rs`): Options for filtering log search by level, time range, and text pattern.
- `Matcher` (`struct`, `matcher.rs`): Compiled matcher ready to search text.
- `ParallelSearch` (`struct`, `parallel.rs`): Parallel search across multiple files.
- `PatternKind` (`enum`, `pattern.rs`): Kind of search pattern: literal, regex, glob, fuzzy, or multi-literal.
- `FileReader` (`struct`, `reader.rs`): File reader with optional memory-mapped I/O.
- `LineMatch` (`struct`, `result.rs`): A single line that matched the search pattern, with position spans.
- `FileMatch` (`struct`, `result.rs`): All matches within a single file.
- `SearchResult` (`struct`, `result.rs`): Complete search result across all files.

## Functions

- `GrepEngine::new` (`engine.rs`): Create a new `GrepEngine` using the provided configuration.
- `GrepEngine::search_literal` (`engine.rs`): Search a directory with a literal pattern.
- `GrepEngine::search_regex` (`engine.rs`): Search a directory with a regex pattern.
- `GrepEngine::search_multi` (`engine.rs`): Search a directory with multiple literal patterns.
- `GrepEngine::search_files` (`engine.rs`): Search a specific list of files for matches.
- `GrepEngine::count` (`engine.rs`): Count matches without collecting line details.
- `GrepEngine::config` (`engine.rs`): Return a shared reference to this engine's configuration.
- `FileFilter::new` (`filter.rs`): Create a `FileFilter` with permissive defaults (no extension limits, 50 MB cap).
- `FileFilter::matches` (`filter.rs`): Check if a file path passes the filter.
- `FileFilter::lua_files` (`filter.rs`): Create a filter for Lua files only.
- `FileFilter::toml_files` (`filter.rs`): Create a filter for TOML files only.
- `FileFilter::game_content` (`filter.rs`): Create a filter for common game content files.
- `search_json_path` (`json_search.rs`): Search JSON files for values at specific paths.
- `search_json_file` (`json_search.rs`): Search a JSON file for a key path.
- `LogSearchOpts::new` (`log_search.rs`): Create `LogSearchOpts` with no filters and zero context lines.
- `parse_log_lines` (`log_search.rs`): Parse log lines into structured entries.
- `search_logs` (`log_search.rs`): Search log entries with filters.
- `Matcher::new` (`matcher.rs`): Create a `Matcher` from a `PatternKind` with case-sensitivity and whole-word options.
- `Matcher::matches_line` (`matcher.rs`): Test if a line matches the pattern.
- `Matcher::find_positions` (`matcher.rs`): Find all match positions in a line.
- `ParallelSearch::new` (`parallel.rs`): Create a parallel file search worker with the given thread count and per-file size limit.
- `ParallelSearch::search` (`parallel.rs`): Search files matching filter in a directory tree.
- `ParallelSearch::search_files` (`parallel.rs`): Search a flat list of file paths.
- `PatternKind::literal` (`pattern.rs`): Create a literal exact-string search pattern.
- `PatternKind::regex` (`pattern.rs`): Create a regular expression search pattern.
- `PatternKind::glob` (`pattern.rs`): Create a glob file-path filter pattern (e.g., `"*.lua"`).
- `PatternKind::fuzzy` (`pattern.rs`): Create a fuzzy approximate-match pattern with a maximum edit distance.
- `PatternKind::multi_literal` (`pattern.rs`): Create a multi-literal OR pattern that matches if any of the given strings is found.
- `FileReader::new` (`reader.rs`): Create a file reader that skips files larger than `max_file_size` bytes.
- `FileReader::read_lines` (`reader.rs`): Read file lines.
- `FileReader::read_string` (`reader.rs`): Read file contents as a single string.
- `FileReader::is_readable` (`reader.rs`): Check if file is within size limit.
- `SearchResult::empty` (`result.rs`): Create an empty search result with all counts at zero.
- `SearchResult::is_empty` (`result.rs`): Return `true` if the result contains no file matches.

## Lua API Reference

- Binding path(s): `src/lua_api/grep_api.rs`
- Namespace: `lurek.grep`

### Module Functions
- `lurek.grep.newEngine`: Creates a new grep engine with default configuration settings.
- `lurek.grep.newEngineOpts`: Creates a new grep engine with custom search configuration options.
- `lurek.grep.newFilter`: Creates a new empty file filter that can be configured to match specific file patterns.
- `lurek.grep.luaFilter`: Creates a file filter preset that matches only Lua source files (.lua extension).
- `lurek.grep.search`: Searches a directory tree for files containing an exact literal pattern string.
- `lurek.grep.jsonSearch`: Searches a JSON file for all values associated with a given key name at any depth.
- `lurek.grep.logSearch`: Searches a structured log file by log level and regex pattern, returning matched entries.

### `LFileFilter` Methods
- `LFileFilter:addExtension`: Add allowed file extensions — Lua userdata object exposed by the engine.
- `LFileFilter:excludeExtension`: Add excluded file extension for this object.
- `LFileFilter:excludePattern`: Add path pattern to exclude for this object.
- `LFileFilter:setIncludeHidden`: Set whether hidden files are included.

### `LGrepEngine` Methods
- `LGrepEngine:search`: Search a directory for a literal pattern.
- `LGrepEngine:searchExt`: Search with file extension filter.
- `LGrepEngine:multiSearch`: Search with multiple patterns simultaneously.
- `LGrepEngine:count`: Count total matches without returning line details.
- `LGrepEngine:searchFiles`: Search a specific provided list of files for text matches.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- Keep this module reference synchronized with `src/grep/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
