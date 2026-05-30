# grep

## General Info

- Module group: `Edge/Integration`
- Source path: `src/grep/`
- Binding: `src/lua_api/grep_api.rs`
- Namespace: `lurek.grep`
- Lua API surface: `7` functions, `2` types, `9` methods
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

The `grep` module exposes a full-featured file search engine to Lua game scripts and developer tooling. At its core, the `GrepEngine` wires together a `FileFilter` (controlling which files to search by extension, path glob, and hidden-file rules), a compiled `Matcher` (selecting the search strategy), and a Rayon parallel thread pool sized from `GrepConfig`. Searches can be expressed as literal strings, regular expressions, shell globs, edit-distance fuzzy patterns, or Aho-Corasick multi-literal sets — all returning structured `GrepResult` values with per-file `FileMatch` arrays and `LineMatch` byte-span positions.

Performance is addressed at multiple levels. Small files use buffered I/O; large files above a configurable threshold switch to `memmap2` zero-copy memory-mapped access, avoiding heap allocation for multi-megabyte assets. Parallel dispatch via Rayon distributes file slices across worker threads, with a `thread_count` of 0 forcing safe single-threaded mode.

Beyond general text search, the module includes two specialized engines. The `json_search` path traverses JSON files using a `/`-separated key path syntax, extracting nested values without loading the entire document into a Lua table. The `log_search` path parses structured log lines in `[LEVEL TIMESTAMP] MESSAGE` format, filtering by severity level, time range, and text pattern — enabling game scripts to query the engine's runtime log for debugging or telemetry analysis. Streaming search with callbacks is supported for real-time result delivery in UI tools. All functionality is accessible via `lurek.grep.*`, making this the primary tool for in-engine asset auditing, content discovery, and developer productivity features.

## Files

### [config.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/grep/config.rs)

- Grep engine configuration: thread count, file size limits, and encoding settings.
- `GrepConfig` holds `thread_count`, `max_file_size`, `case_sensitive`, and `whole_word`.
- Deserialized from the `[grep]` TOML block or constructed via Lua table defaults.
- `thread_count` defaults to `num_cpus / 2`; 0 means single-threaded.
- `max_file_size` prevents accidentally reading binary assets during a code search.

### [engine.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/grep/engine.rs)

- High-level search engine: wires configuration, file filter, and pattern matcher.
- `GrepEngine::run(root, pattern)` returns a `GrepResult` across all matching files.
- Delegates file discovery to `FileFilter` and matching to `Matcher`.
- Work is split across a Rayon thread pool sized from `GrepConfig::thread_count`.
- Used by `lurek.grep.*` Lua API; the Lua binding owns the config lifecycle.

### [filter.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/grep/filter.rs)

- File extension and path filters for narrowing the search scope.
- `FileFilter` accepts `include_extensions`, `exclude_extensions`, and glob patterns.
- `FileFilter::matches(path)` is a pure predicate; no I/O at the filter stage.
- Hidden files and directories starting with `.` are excluded by default.
- Configured from `GrepConfig` or directly by Lua via `lurek.grep.set_filter`.

### [json_search.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/grep/json_search.rs)

- JSON path search: query structured key-value paths within JSON files.
- `search_json_path` scans a directory for JSON files and extracts values at a path.
- `search_json_file` operates on a single file; returns `Option<serde_json::Value>`.
- Path syntax uses `/`-separated keys; arrays are addressed by numeric index.
- Exposed to Lua via `lurek.grep.json_path(dir, path)` in `grep_api.rs`.

### [log_search.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/grep/log_search.rs)

- Structured log file search with level, time-range, and text pattern filters.
- `parse_log_lines` parses lines of the form `[LEVEL TIMESTAMP] MESSAGE`.
- `search_logs` filters `Vec<LogEntry>` by level, time bounds, and text pattern.
- `LogSearchOpts` drives the filter; all fields are optional (zero = no filter).
- Used by `lurek.grep.logs` to let game scripts query the engine's runtime log.

### [matcher.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/grep/matcher.rs)

- Low-level pattern matcher: wraps all supported pattern kinds behind one trait.
- `Matcher` implements literal, regex, glob, and fuzzy match against a `&str`.
- Returns a `Vec<(usize, usize)>` of byte-span matches within the target string.
- Regex variant compiles once and is reused across all lines in a file.
- Fuzzy variant uses edit-distance threshold configurable via `GrepConfig`.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/grep/mod.rs)

- Text search engine for game content files.
- Literal, regex, glob, and multi-pattern search.
- Memory-mapped file reading for large files.
- Parallel file search with rayon-style thread distribution.
- Specialized JSON path search and log file parsing.
- Streaming mode with callbacks for real-time results.

### [parallel.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/grep/parallel.rs)

- Parallel file search: distributes work across a Rayon thread pool.
- `validate_parallel` is the primary entry point; returns a flat `Vec<Violation>`.
- `collect_lua_files` / `collect_files_with_ext` enumerate files before dispatch.
- Each worker receives a slice of paths; results are merged after the pool drains.
- Thread count comes from `GrepConfig`; 0 forces synchronous single-threaded mode.

### [pattern.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/grep/pattern.rs)

- Pattern kinds: literal, regex, glob, fuzzy, and multi-literal match strategies.
- `PatternKind` is the discriminant stored in `Matcher` to select dispatch logic.
- `Literal` and `MultiLiteral` use Aho-Corasick for sub-linear multi-pattern search.
- `Regex` wraps the `regex` crate; patterns are validated at construction time.
- `Glob` converts shell-style `*`/`?` patterns to a regex and reuses the regex path.
- `Fuzzy` uses Levenshtein distance with a configurable `max_edit_distance`.

### [reader.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/grep/reader.rs)

- File reading utilities: buffered I/O and memory-mapped access for large files.
- Small files (< threshold) are read with `BufReader` and iterated line-by-line.
- Large files use `memmap2` for zero-copy line scanning via byte search.
- The threshold is configurable via `GrepConfig::mmap_threshold_bytes`.
- On failure the reader falls back to buffered mode; mmap errors are non-fatal.

### [result.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/grep/result.rs)

- Search result types: per-line matches, per-file matches, and totals.
- `LineMatch` carries `line_number`, `content` string, and `positions` spans.
- `FileMatch` groups `Vec<LineMatch>` under a `PathBuf` source path.
- `GrepResult` is the top-level return: `matches`, `files_searched`, `total_matches`.
- All types are `Debug + Clone`; `GrepResult` implements `Display` for summary output.
