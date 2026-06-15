# grep

## TL;DR

- Provides literal-first file scanning, lightweight pattern helpers, and JSON/log searches.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/grep/`
- Binding: `src/lua_api/grep_api.rs`
- Namespace: `lurek.grep`
- Lua API surface: `7` functions, `2` types, `9` methods
- Rust test path(s): `tests/rust/unit/grep_tests.rs`
- Lua test path(s): `tests/lua/unit/test_grep_unit.lua`

## Summary

- This module exposes scriptable text search across project files from one Lua-facing API.
- Literal and multi-literal search are the strongest paths today.
- Regex, glob, and fuzzy modes remain lightweight helpers, not full external-engine equivalents.
- Directory scans use buffered file reads, size caps, and small std-thread worker pools.
- Result ordering is deterministic after parallel merge.
- `GrepConfig.max_results` caps returned matches after collection.
- File filters handle extensions, path substring exclusions, and hidden-file policy.
- JSON and structured-log helpers support data-oriented searches beside plain text.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Files

### config.rs

- Holds `GrepConfig`: thread count, max file size, case-sensitivity, whole-word mode, result cap, and context setting.
- Default result cap is `10000`.

### engine.rs

- High-level entry point that wires `GrepConfig`, `FileFilter`, and `ParallelSearch`.
- Exposes literal, regex, multi-literal, explicit-file, and count helpers.
- Applies deterministic result capping through `GrepConfig::max_results`.

### filter.rs

- File extension and path filters for narrowing the scan scope.
- Hidden files and directories starting with `.` are excluded by default.
- Path pattern checks are substring-based rather than glob-engine based.

### json_search.rs

- Searches JSON documents for matching key names and returns path/value pairs.
- Operates on one file at a time in the current Lua binding.

### log_search.rs

- Parses structured log lines and filters them by level and message pattern.
- Message pattern checks are literal text matching in the current binding path.

### matcher.rs

- Implements literal, simplified regex, simplified glob, fuzzy, and multi-literal matching.
- Regex and glob modes use lightweight custom rules rather than the `regex` crate.

### mod.rs

- Re-exports the grep engine, filters, matcher, result types, and helpers.
- Documents the module as literal-first with buffered I/O and deterministic parallel merge.

### parallel.rs

- Collects files eagerly, splits work into chunks, and searches each chunk on a std thread.
- Workers return local results which are merged once after join.
- Final file and line ordering are sorted deterministically.

### pattern.rs

- Defines the pattern variants consumed by `Matcher`.
- Literal and multi-literal matching use straightforward substring scans.

### reader.rs

- Reads text files through buffered filesystem I/O with a max-size guard.
- Files larger than the configured limit are skipped.
- No mmap path exists in the current implementation.

### result.rs

- Defines `LineMatch`, `FileMatch`, and `SearchResult`.
- `SearchResult` carries totals plus the per-file/per-line payload returned to Lua.

## Lua API Ref

### Functions

- `lurek.grep.jsonSearch(file, key) -> table`: Searches a JSON file for values associated with the given key name.
- `lurek.grep.logSearch(file, level, pattern) -> table`: Searches a structured log file by log level and literal message pattern.
- `lurek.grep.luaFilter() -> LFileFilter`: Creates a file filter preset for `.lua` files.
- `lurek.grep.newEngine() -> LGrepEngine`: Creates a grep engine with default settings.
- `lurek.grep.newEngineOpts(opts) -> LGrepEngine`: Creates a grep engine with custom thread, case, whole-word, and max-file-size settings.
- `lurek.grep.newFilter() -> LFileFilter`: Creates an empty file filter.
- `lurek.grep.search(path, pattern) -> table`: Searches a directory tree for a literal pattern in game content files.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LFileFilter Type

- Lua userdata that controls which files are scanned by a `LGrepEngine`.

##### Fields

- No documented fields.

##### Methods

- `LFileFilter:addExtension(ext) -> nil`: Add an allowed file extension to this filter.
- `LFileFilter:excludeExtension(ext) -> nil`: Add an excluded file extension to this filter.
- `LFileFilter:excludePattern(pattern) -> nil`: Add a path substring exclusion rule to this filter.
- `LFileFilter:setIncludeHidden(include) -> nil`: Set whether hidden files are included.

#### LGrepEngine Type

- Lua userdata that performs pattern-based search across game content files.

##### Fields

- No documented fields.

##### Methods

- `LGrepEngine:count(path, pattern) -> integer`: Count total literal matches without returning line details.
- `LGrepEngine:multiSearch(path, patterns) -> table`: Search with multiple literal patterns simultaneously.
- `LGrepEngine:search(path, pattern) -> table`: Search a directory for a literal pattern.
- `LGrepEngine:searchExt(path, pattern, extensions) -> table`: Search with an extension whitelist.
- `LGrepEngine:searchFiles(files, pattern) -> table`: Search the provided file list only.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- The current implementation is intentionally narrower than the older docs: no mmap reader, no rayon-specific engine contract, and no promise of full regex semantics.
