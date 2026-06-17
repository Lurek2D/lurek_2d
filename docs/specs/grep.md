# grep

## TL;DR

- Provides literal-first file scanning, lightweight pattern helpers, and JSON/log searches.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/grep/`
- Binding: `src/lua_api/grep_api.rs`
- Namespace: `lurek.grep`
- Lua API surface: `7` functions, `2` types, `9` methods
- Rust test path(s): tests/rust/unit/grep_tests.rs
- Lua test path(s): tests/lua/unit/test_grep_unit.lua

## Summary

- This module exposes scriptable text search across project files from one Lua-facing API.
- Literal and multi-literal search are the strongest paths today.
- Regex, glob, and fuzzy modes remain lightweight helpers, not full external-engine equivalents.
- Directory scans use buffered file reads, size caps, and small std-thread worker pools.
- Result ordering is deterministic after parallel merge.
- `GrepConfig.max_results` caps returned matches after collection.
- File filters handle extensions, path substring exclusions, and hidden-file policy.
- JSON and structured-log helpers support data-oriented searches beside plain text.

This module is mostly self-contained inside the `Edge/Integration` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Files

### config.rs

- Grep engine configuration: thread count, file size limits, and encoding settings. `grep/config` delivers the configuration schema and defaults for the grep subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- `GrepConfig` holds `thread_count`, `max_file_size`, `case_sensitive`, and `whole_word`. The file owns or coordinates data contracts including `GrepConfig`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Deserialized from the `[grep]` TOML block or constructed via Lua table defaults. Public callable behavior is centered on no named public items, while method-level behavior such as no named public items stays attached to the local data model and invariants.

### engine.rs

- High-level search engine: wires configuration, file filter, and pattern matcher. `grep/engine` delivers the engine implementation for the grep subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Delegates file discovery to `FileFilter` and matching to the lightweight `Matcher`. The file owns or coordinates data contracts including `GrepEngine`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Work is split across a small std-thread worker set sized from `GrepConfig::thread_count`. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `search_literal`, `search_regex`, `search_multi`, `search_files`, `count`, and 1 more stays attached to the local data model and invariants.
- Returned results are deterministically sorted and capped by `GrepConfig::max_results`. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### filter.rs

- File extension and path filters for narrowing the search scope. `grep/filter` delivers the filter implementation for the grep subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- `FileFilter` accepts `include_extensions`, `exclude_extensions`, and glob patterns. The file owns or coordinates data contracts including `FileFilter`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- `FileFilter::matches(path)` is a pure predicate; no I/O at the filter stage. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `matches`, `lua_files`, `toml_files`, `game_content` stays attached to the local data model and invariants.
- Hidden files and directories starting with `.` are excluded by default. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### json_search.rs

- JSON path search: query structured key-value paths within JSON files. `grep/json_search` delivers the json search implementation for the grep subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- `search_json_path` scans a directory for JSON files and extracts values at a path. The file owns or coordinates data contracts including `JsonMatch`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- `search_json_file` operates on a single file; returns `Option<serde_json::Value>`. Public callable behavior is centered on `search_json_path`, `search_json_file`, while method-level behavior such as no named public items stays attached to the local data model and invariants.

### log_search.rs

- Structured log file search with level, time-range, and text pattern filters. `grep/log_search` delivers the log search implementation for the grep subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- `parse_log_lines` parses lines of the form `[LEVEL TIMESTAMP] MESSAGE`. The file owns or coordinates data contracts including `LogEntry`, `LogSearchOpts`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- `search_logs` filters `Vec<LogEntry>` by level, time bounds, and text pattern. Public callable behavior is centered on `parse_log_lines`, `search_logs`, while method-level behavior such as `new` stays attached to the local data model and invariants.
- `LogSearchOpts` drives the filter; all fields are optional (zero = no filter). Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### matcher.rs

- Low-level pattern matcher: wraps the supported pattern kinds behind one helper. `grep/matcher` delivers the matcher implementation for the grep subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- `Matcher` implements literal, simplified regex/glob, fuzzy, and multi-literal search. The file owns or coordinates data contracts including `Matcher`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Returns a `Vec<(usize, usize)>` of byte-span matches within the target string. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `matches_line`, `find_positions` stays attached to the local data model and invariants.
- Regex and glob support are lightweight custom matchers rather than full regex-crate semantics. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Fuzzy matching uses an edit-distance threshold per query. External integration uses `super`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### mod.rs

- Text search engine for game and tooling content files. `grep/mod` is the grep module index, declaring `config`, `engine`, `filter`, `json_search`, `log_search`, and 5 more so agents can identify which files own each feature slice before opening implementation code.
- Literal-first matching with simplified regex/glob/fuzzy helpers and multi-pattern search. `src/grep/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `config::GrepConfig`, `engine::GrepEngine`, `filter::FileFilter`, `matcher::Matcher`, and 4 more centralized for the grep subsystem.
- Buffered file reading with a configurable size cap. The file documents how grep submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.
- Deterministic std-thread parallel file search for directory scans. Agents should read this index to choose the narrow owner file first, because it maps names such as `config`, `engine`, `filter`, `json_search`, `log_search`, and 5 more to concrete implementation responsibilities.
- Specialized JSON path search and log file parsing. Re-export decisions in this file define the stable Rust boundary consumed by sibling modules, Lua bindings, generated specs, and examples that mention grep features.
- No streaming callbacks or memory-mapped reader in the current implementation. The module stays implementation-light by delegating behavior to child files, which preserves a clear boundary between navigation metadata and executable subsystem logic.

### parallel.rs

- Parallel file search: distributes work across a small std-thread worker set. `grep/parallel` delivers the parallel implementation for the grep subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Files are collected eagerly, chunked deterministically, and merged after workers finish. The file owns or coordinates data contracts including `ParallelSearch`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Thread count comes from `GrepConfig`; `0` is clamped to a single worker. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `search`, `search_files` stays attached to the local data model and invariants.
- Matching remains literal-first and filesystem-oriented rather than a streaming validator engine. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### pattern.rs

- Pattern kinds: literal, regex, glob, fuzzy, and multi-literal match strategies. `grep/pattern` delivers the pattern implementation for the grep subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- `PatternKind` is the discriminant stored in `Matcher` to select dispatch logic. The file owns or coordinates data contracts including `PatternKind`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- `Literal` and `MultiLiteral` use Aho-Corasick for sub-linear multi-pattern search. Public callable behavior is centered on no named public items, while method-level behavior such as `literal`, `regex`, `glob`, `fuzzy`, `multi_literal` stays attached to the local data model and invariants.

### reader.rs

- File reading utilities: buffered I/O with a simple size gate. `grep/reader` delivers the reader implementation for the grep subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Files larger than the configured limit are skipped instead of partially streamed. The file owns or coordinates data contracts including `FileReader`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Callers can read line-by-line or whole-file UTF-8 content through the same helper. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `read_lines`, `read_string`, `is_readable` stays attached to the local data model and invariants.

### result.rs

- Search result types: per-line matches, per-file matches, and totals. `grep/result` delivers the result implementation for the grep subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- `LineMatch` carries `line_number`, `content` string, and `positions` spans. The file owns or coordinates data contracts including `LineMatch`, `FileMatch`, `SearchResult`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- `FileMatch` groups `Vec<LineMatch>` under a `PathBuf` source path. Public callable behavior is centered on no named public items, while method-level behavior such as `empty`, `is_empty`, `limit_total_matches` stays attached to the local data model and invariants.
- `GrepResult` is the top-level return: `matches`, `files_searched`, `total_matches`. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.



## Lua API Ref

### Functions

- `lurek.grep.jsonSearch(file, key) -> table`: Search a JSON file for every matching key name.
- `lurek.grep.logSearch(file, level, pattern) -> table`: Search a structured log file by level and literal message pattern.
- `lurek.grep.luaFilter() -> LFileFilter`: Create a filter for Lua files only.
- `lurek.grep.newEngine() -> LGrepEngine`: Create a new grep engine with default settings.
- `lurek.grep.newEngineOpts(opts) -> LGrepEngine`: Create a grep engine with custom options.
- `lurek.grep.newFilter() -> LFileFilter`: Create an empty file filter.
- `lurek.grep.search(path, pattern) -> table`: Search a directory for a literal pattern in game content files.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LFileFilter Type

- Lua userdata that controls which files are scanned by a `LuaGrepEngine`.

##### Fields

- No documented fields.

##### Methods

- `LFileFilter:addExtension(ext) -> nil`: Add an allowed file extension to this filter.
- `LFileFilter:excludeExtension(ext) -> nil`: Add an excluded file extension to this filter.
- `LFileFilter:excludePattern(pattern) -> nil`: Add a path substring exclusion rule to this filter.
- `LFileFilter:setIncludeHidden(include) -> nil`: Set whether hidden files are included.

#### LGrepEngine Type

- Lua userdata that performs search operations across game content files.

##### Fields

- No documented fields.

##### Methods

- `LGrepEngine:count(path, pattern) -> integer`: Count total literal matches without returning line details.
- `LGrepEngine:multiSearch(path, patterns) -> table`: Search with multiple literal patterns simultaneously.
- `LGrepEngine:search(path, pattern) -> table`: Search a directory for a literal pattern.
- `LGrepEngine:searchExt(path, pattern, extensions) -> table`: Search with a file extension filter.
- `LGrepEngine:searchFiles(files, pattern) -> table`: Search a specific provided list of files for text matches.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- The current implementation is intentionally narrower than the older docs: no mmap reader, no rayon-specific engine contract, and no promise of full regex semantics.
