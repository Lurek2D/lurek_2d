<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/grep.md or source docstrings instead. -->

# grep

## TL;DR

- Provides literal-first file scanning, lightweight pattern helpers, and JSON/log searches.

## General Info

- Module group: `Feature Systems`
- Source path: `src/grep`
- Binding: `src/lua_api/grep_api.rs`
- Namespace: `lurek.grep`
- Lua API surface: `7` functions, `2` types, `9` methods
- User-facing: `true`
- Plugin tier: `not_evaluated`

## Summary

- The `grep` module is the scriptable text-search surface for users who want to scan project files, logs, or structured content from inside the engine environment.
- Search configuration, path filtering, matching, and specialized JSON or log helpers work together so one module can cover ordinary content search as well as more structured diagnostic queries.
- Literal-first behavior matters because many runtime and tooling searches are about exact identifiers, paths, or messages rather than full external-regex-engine complexity.
- Threaded scanning and result shaping make the module practical for tools, editors, audit scripts, and content workflows that need search without leaving the project runtime.
- Read it as the in-engine file-search utility layer: it does not replace every external grep tool, but it gives scripts a controlled search workflow that fits the engine's data and file model.

This module is mostly self-contained inside the `Edge/Integration` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Ownership

- Canonical source: `src/grep`
- Owning tier: `Feature Systems`
- Plugin tier: `not_evaluated`
- Lua binding owner: `src/lua_api/grep_api.rs`
- Referenced engine modules: None detected from Rust imports.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Source Files

### config.rs

- This file owns `GrepConfig`, the shared search configuration for thread count, limits, casing, and result caps.
- It stores worker count, max file size, whole-word mode, case sensitivity, max results, and context-line settings.
- Open this file when grep defaults or tunable search limits change; engine flow and path filtering live in siblings.

### engine.rs

- This file owns `GrepEngine`, the high-level search facade that combines config, filters, matchers, and workers.
- It builds literal, regex-like, and multi-literal searches, then delegates filesystem scanning to `ParallelSearch`.
- Result capping happens here so every entry point obeys `GrepConfig::max_results` before callers inspect matches.
- Open this file when top-level grep workflows change; pattern evaluation and raw file traversal live in siblings.

### filter.rs

- This file owns `FileFilter`, the path-selection layer used to narrow grep scans before any file content is read.
- It stores allowed and blocked extensions, include and exclude substrings, a size cap, and hidden-file policy.
- `matches` is a pure path predicate, so discovery can reject files cheaply without loading bytes or parsing lines.
- Preset constructors provide ready-made filters for Lua, TOML, and broader game-content scans across repo assets.
- Open this file when file-selection rules change; text matching and parallel execution live in sibling modules.

### json_search.rs

- This file owns lightweight JSON-path search helpers that scan text or files for matching structured key paths.
- It returns `JsonMatch` records containing the queried path and extracted value for each matching source line.
- The implementation is heuristic and line-based, using simple `:` or `=` extraction instead of full tree walking.
- Open this file when structured JSON grep behavior changes; generic text matching and filters live in siblings.

### log_search.rs

- This file owns structured log parsing and filtering for grep-style inspection of timestamped runtime log lines.
- It defines `LogEntry` and `LogSearchOpts`, then parses common bracketed or ISO-like log formats into fields.
- Search helpers filter by severity, optional time bounds, and message substrings without re-reading source files.
- Timestamp filtering uses string comparison, which fits normalized log formats but keeps parsing deliberately simple.
- Open this file when log-specific grep semantics change; generic matchers and file traversal live in siblings.

### matcher.rs

- This file owns `Matcher`, the text-evaluation layer that applies one `PatternKind` to lines and match spans.
- It dispatches literal, regex-like, glob, fuzzy, and multi-literal checks behind one consistent search interface.
- Literal searches can return byte ranges, while non-literal modes fall back to whole-line spans after a match check.
- Regex and glob support are custom lightweight implementations here, not full crate-backed regular expressions.
- Fuzzy matching uses an edit-distance threshold over sliding windows so near matches can be found in plain text.
- Open this file when pattern semantics change; enum construction and high-level grep orchestration live nearby.

### mod.rs

- This module re-exports the grep subsystem surface for config, filtering, matching, readers, and search results.
- It exists as the navigation map that tells callers which sibling files own engine flow, pattern kinds, or log helpers.
- `engine.rs` drives top-level searches, while `parallel.rs` and `reader.rs` cover filesystem work and file loading.
- `matcher.rs` and `pattern.rs` define how literal, regex-like, glob, fuzzy, and multi-pattern checks are evaluated.
- `filter.rs`, `json_search.rs`, and `log_search.rs` narrow scope or parse structured content beyond raw text lines.
- Change this file when the public grep symbol map moves; change siblings when search behavior or data rules change.

### parallel.rs

- This file owns `ParallelSearch`, the filesystem worker layer that splits grep work across deterministic chunks.
- It gathers candidate files, reads them through `FileReader`, applies `Matcher`, and merges sorted `FileMatch` output.
- Directory scans recurse through subfolders, skip hidden entries when configured, and keep file ordering predictable.
- Chunk workers run inside scoped threads, so search stays std-only and shares readers without async machinery.
- Open this file when traversal or worker behavior changes; top-level query setup and pattern logic live in siblings.

### pattern.rs

- This file owns `PatternKind`, the enum that names every grep match strategy before a `Matcher` executes it.
- It stores literal, regex-like, glob, fuzzy, and multi-literal variants so search intent stays explicit in data.
- Constructor helpers create each variant without exposing enum field details to higher-level engine call sites.
- Open this file when supported pattern families change; evaluation logic and file traversal live in sibling files.

### reader.rs

- This file owns `FileReader`, the size-gated file access helper shared by grep directory and flat-file searches.
- It reads UTF-8 content as lines or one full string, but rejects oversized or unreadable files before loading them.
- `is_readable` exposes the same gate as a cheap metadata check so callers can reason about search eligibility.
- Open this file when grep file-loading rules change; path filtering and match semantics live in sibling modules.

### result.rs

- This file owns `LineMatch`, `FileMatch`, and `SearchResult`, the structured output produced by grep searches.
- It records matched paths, line numbers, source text, byte spans, aggregate counts, and elapsed search duration.
- `SearchResult::empty` provides a zeroed baseline, while `limit_total_matches` trims nested matches to a cap.
- Result limiting rewrites per-file totals so callers see consistent counts after truncation across many files.
- Open this file when grep output structure changes; matching logic and filesystem traversal live in siblings.



## Lua API Ref

### Functions

- `lurek.grep.jsonSearch(file, key) -> table`: Search a JSON file for every matching key name.
- `lurek.grep.logSearch(file, level, pattern) -> table`: Search a structured log file by level and literal message pattern.
- `lurek.grep.luaFilter() -> LFileFilter`: Creates a file filter preconfigured for Lua files only.
- `lurek.grep.newEngine() -> LGrepEngine`: Create a new grep engine with default settings.
- `lurek.grep.newEngineOpts(opts) -> LGrepEngine`: Create a grep engine with custom options.
- `lurek.grep.newFilter() -> LFileFilter`: Creates an empty file filter for custom include rules.
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

## Examples

- `content/examples/grep.lua` (present)

## Tests

- Lua unit: `tests/lua/unit/test_grep_unit.lua` (present)
- Rust: `tests/rust/unit/grep_tests.rs`

## Evidence / Golden

- No evidence or golden artifacts registered.

## Architecture Links

- Intentionally empty.

## Notes

- The current implementation is intentionally narrower than the older docs: no mmap reader, no rayon-specific engine contract, and no promise of full regex semantics.
