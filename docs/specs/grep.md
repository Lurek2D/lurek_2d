# grep

## Overview

Text search engine for game content files. Supports literal, regex, glob, fuzzy, and multi-pattern search with parallel file traversal.

## Tier

Feature Systems

## Dependencies

- None (standalone, pure Rust)

## Public API (`lurek.grep`)

### Constructors
- `newEngine()` — Create grep engine with defaults.
- `newEngineOpts(opts)` — Create engine with options (threads, case_sensitive, whole_word, max_file_size).
- `newFilter()` — Create empty file filter.
- `luaFilter()` — Create pre-configured Lua file filter.

### Quick Functions
- `search(path, pattern)` — Search directory for literal pattern in game content files.
- `jsonSearch(file, key)` — Search JSON file for key path.
- `logSearch(file, level, pattern)` — Search log file by level and message pattern.

### Engine Methods
- `engine:search(path, pattern)` — Search directory.
- `engine:searchExt(path, pattern, extensions)` — Search with extension filter.
- `engine:multiSearch(path, patterns)` — Multi-pattern search.
- `engine:count(path, pattern)` — Count matches.
- `engine:searchFiles(files, pattern)` — Search specific file list.

### Filter Methods
- `filter:addExtension(ext)` — Add allowed extension.
- `filter:excludeExtension(ext)` — Exclude extension.
- `filter:excludePattern(pattern)` — Exclude path pattern.
- `filter:setIncludeHidden(bool)` — Include hidden files.

### Result Format
```lua
{
    files_searched = 42,
    files_matched = 3,
    total_matches = 7,
    duration_ms = 15,
    matches = {
        { path = "file.lua", total_matches = 2, lines = {
            { line = 10, content = "local x = foo()" },
        }}
    }
}
```

## Invariants

- Default file size limit: 50 MB.
- Parallel search uses std::thread::scope (no rayon dependency).
- Fuzzy matching uses Levenshtein edit distance.
- Log parser handles [TIMESTAMP] [LEVEL] message format.
- File filter excludes hidden files by default.
