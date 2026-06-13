# grep

## TL;DR

- Provides parallel file scanning, fuzzy text matchers, and JSON/log searches.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/grep/`
- Binding: `src/lua_api/grep_api.rs`
- Namespace: `lurek.grep`
- Lua API surface: `7` functions, `2` types, `9` methods
- Rust test path(s): None found in the workspace
- Lua test path(s): tests/lua/unit/test_grep_unit.lua

## Summary

- This module gives users fast text and content search across project files from one scriptable API.
- It supports literal, regex, glob, fuzzy, and multi-pattern matching for different search needs.
- File filters and extension controls help narrow scope before scanning begins.
- Parallel execution improves throughput on large code and content trees.
- Large-file handling with mmap paths keeps heavy searches practical.
- JSON-path and structured-log search helpers support data-oriented workflows beyond plain text.
- Configurable limits and flags keep scans predictable and safer for mixed asset repositories.
- Result objects include match context suitable for tooling, diagnostics, and automated audits.
- For users, this module turns ad-hoc grep logic into a reusable, high-performance search subsystem.
- It is useful for validation scripts, content checks, migration tools, and runtime diagnostics.
- The practical value is faster discovery and less custom search boilerplate.

This module is mostly self-contained inside the `Edge/Integration` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Files

### config.rs

- Grep engine configuration: thread count, file size limits, and encoding settings.
- `GrepConfig` holds `thread_count`, `max_file_size`, `case_sensitive`, and `whole_word`.
- Deserialized from the `[grep]` TOML block or constructed via Lua table defaults.
- `thread_count` defaults to `num_cpus / 2`; 0 means single-threaded.
- `max_file_size` prevents accidentally reading binary assets during a code search.

### engine.rs

- High-level search engine: wires configuration, file filter, and pattern matcher.
- `GrepEngine::run(root, pattern)` returns a `GrepResult` across all matching files.
- Delegates file discovery to `FileFilter` and matching to `Matcher`.
- Work is split across a Rayon thread pool sized from `GrepConfig::thread_count`.
- Used by `lurek.grep.*` Lua API; the Lua binding owns the config lifecycle.

### filter.rs

- File extension and path filters for narrowing the search scope.
- `FileFilter` accepts `include_extensions`, `exclude_extensions`, and glob patterns.
- `FileFilter::matches(path)` is a pure predicate; no I/O at the filter stage.
- Hidden files and directories starting with `.` are excluded by default.
- Configured from `GrepConfig` or directly by Lua via `lurek.grep.set_filter`.

### json_search.rs

- JSON path search: query structured key-value paths within JSON files.
- `search_json_path` scans a directory for JSON files and extracts values at a path.
- `search_json_file` operates on a single file; returns `Option<serde_json::Value>`.
- Path syntax uses `/`-separated keys; arrays are addressed by numeric index.
- Exposed to Lua via `lurek.grep.json_path(dir, path)` in `grep_api.rs`.

### log_search.rs

- Structured log file search with level, time-range, and text pattern filters.
- `parse_log_lines` parses lines of the form `[LEVEL TIMESTAMP] MESSAGE`.
- `search_logs` filters `Vec<LogEntry>` by level, time bounds, and text pattern.
- `LogSearchOpts` drives the filter; all fields are optional (zero = no filter).
- Used by `lurek.grep.logs` to let game scripts query the engine's runtime log.

### matcher.rs

- Low-level pattern matcher: wraps all supported pattern kinds behind one trait.
- `Matcher` implements literal, regex, glob, and fuzzy match against a `&str`.
- Returns a `Vec<(usize, usize)>` of byte-span matches within the target string.
- Regex variant compiles once and is reused across all lines in a file.
- Fuzzy variant uses edit-distance threshold configurable via `GrepConfig`.

### mod.rs

- Text search engine for game content files.
- Literal, regex, glob, and multi-pattern search.
- Memory-mapped file reading for large files.
- Parallel file search with rayon-style thread distribution.
- Specialized JSON path search and log file parsing.
- Streaming mode with callbacks for real-time results.

### parallel.rs

- Parallel file search: distributes work across a Rayon thread pool.
- `validate_parallel` is the primary entry point; returns a flat `Vec<Violation>`.
- `collect_lua_files` / `collect_files_with_ext` enumerate files before dispatch.
- Each worker receives a slice of paths; results are merged after the pool drains.
- Thread count comes from `GrepConfig`; 0 forces synchronous single-threaded mode.

### pattern.rs

- Pattern kinds: literal, regex, glob, fuzzy, and multi-literal match strategies.
- `PatternKind` is the discriminant stored in `Matcher` to select dispatch logic.
- `Literal` and `MultiLiteral` use Aho-Corasick for sub-linear multi-pattern search.
- `Regex` wraps the `regex` crate; patterns are validated at construction time.
- `Glob` converts shell-style `*`/`?` patterns to a regex and reuses the regex path.
- `Fuzzy` uses Levenshtein distance with a configurable `max_edit_distance`.

### reader.rs

- File reading utilities: buffered I/O and memory-mapped access for large files.
- Small files (< threshold) are read with `BufReader` and iterated line-by-line.
- Large files use `memmap2` for zero-copy line scanning via byte search.
- The threshold is configurable via `GrepConfig::mmap_threshold_bytes`.
- On failure the reader falls back to buffered mode; mmap errors are non-fatal.

### result.rs

- Search result types: per-line matches, per-file matches, and totals.
- `LineMatch` carries `line_number`, `content` string, and `positions` spans.
- `FileMatch` groups `Vec<LineMatch>` under a `PathBuf` source path.
- `GrepResult` is the top-level return: `matches`, `files_searched`, `total_matches`.
- All types are `Debug + Clone`; `GrepResult` implements `Display` for summary output.



## Lua API Ref

### Functions

- `lurek.grep.jsonSearch(file, key) -> table`: Searches a JSON file for all values associated with a given key name at any depth.
- `lurek.grep.logSearch(file, level, pattern) -> table`: Searches a structured log file by log level and regex pattern, returning matched entries.
- `lurek.grep.luaFilter() -> LFileFilter`: Creates a file filter preset that matches only Lua source files (.lua extension).
- `lurek.grep.newEngine() -> LGrepEngine`: Creates a new grep engine with default configuration settings.
- `lurek.grep.newEngineOpts(opts) -> LGrepEngine`: Creates a new grep engine with custom search configuration options.
- `lurek.grep.newFilter() -> LFileFilter`: Creates a new empty file filter that can be configured to match specific file patterns.
- `lurek.grep.search(path, pattern) -> table`: Searches a directory tree for files containing an exact literal pattern string.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LFileFilter Type

- Lua userdata that controls which files are scanned by a LGrepEngine instance.

##### Fields

- No documented fields.

##### Methods

- `LFileFilter:addExtension(ext) -> nil`: Add allowed file extensions â€” Lua userdata object exposed by the engine.
- `LFileFilter:excludeExtension(ext) -> nil`: Add excluded file extension for this object.
- `LFileFilter:excludePattern(pattern) -> nil`: Add path pattern to exclude for this object.
- `LFileFilter:setIncludeHidden(include) -> nil`: Set whether hidden files are included.

#### LGrepEngine Type

- Lua userdata that performs pattern-based search across game content files.

##### Fields

- No documented fields.

##### Methods

- `LGrepEngine:count(path, pattern) -> integer`: Count total matches without returning line details.
- `LGrepEngine:multiSearch(path, patterns) -> table`: Search with multiple patterns simultaneously.
- `LGrepEngine:search(path, pattern) -> table`: Search a directory for a literal pattern.
- `LGrepEngine:searchExt(path, pattern, extensions) -> table`: Search with file extension filter.
- `LGrepEngine:searchFiles(files, pattern) -> table`: Search a specific provided list of files for text matches.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- No additional module-specific notes.
