# Grep

## Purpose

Provides literal-first file scanning, lightweight pattern helpers, and JSON/log searches.

## When To Use

- Search configuration, path filtering, matching, and specialized JSON or log helpers work together so one module can cover ordinary content search as well as more structured diagnostic queries.
- Literal-first behavior matters because many runtime and tooling searches are about exact identifiers, paths, or messages rather than full external-regex-engine complexity.
- Threaded scanning and result shaping make the module practical for tools, editors, audit scripts, and content workflows that need search without leaving the project runtime.

## Minimal Example

From the `lurek.grep.newEngine` example block:

```lua
do
    local paths = fixture_paths()
    local engine = lurek.grep.newEngine()
    local result = engine:search(paths.search, "needle")
    local total = result.total_matches
    local files = result.files_searched
    grep_log("newEngine files=" .. files .. " total_matches=" .. total)
end
```

## Common Patterns

- Start with `lurek.grep.jsonSearch` when exploring this module.
- Start with `lurek.grep.logSearch` when exploring this module.
- Start with `lurek.grep.luaFilter` when exploring this module.
- Start with `lurek.grep.newEngine` when exploring this module.
- Start with `lurek.grep.newEngineOpts` when exploring this module.

## API Reference

- Full generated API reference: [docs/api/lurek.md](../api/lurek.md)
- Runnable example owner: `content/examples/grep.lua`

## Summary

- The `grep` module is the scriptable text-search surface for users who want to scan project files, logs, or structured content from inside the engine environment.
- Search configuration, path filtering, matching, and specialized JSON or log helpers work together so one module can cover ordinary content search as well as more structured diagnostic queries.
- Literal-first behavior matters because many runtime and tooling searches are about exact identifiers, paths, or messages rather than full external-regex-engine complexity.
- Threaded scanning and result shaping make the module practical for tools, editors, audit scripts, and content workflows that need search without leaving the project runtime.
- Read it as the in-engine file-search utility layer: it does not replace every external grep tool, but it gives scripts a controlled search workflow that fits the engine's data and file model.

This module is mostly self-contained inside the `Edge/Integration` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Functions

### `lurek.grep.jsonSearch`

Search a JSON file for every matching key name.

```lua
lurek.grep.jsonSearch(file, key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `file` | string | JSON file path. |
| `key` | string | Key name to search for. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of matches with path and value. |

**Example**

```lua
do
    local paths = fixture_paths()
    local result = lurek.grep.jsonSearch(paths.json, "kind")
    local first = result[1]
    local third = result[3]
    local first_value = first and first.value or "nil"
    local third_value = third and third.value or "nil"
    grep_log("jsonSearch hits=" .. #result .. " first=" .. first_value .. " third=" .. third_value)
end
```

---

### `lurek.grep.logSearch`

Search a structured log file by level and literal message pattern.

```lua
lurek.grep.logSearch(file, level, pattern)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `file` | string | Log file path. |
| `level` | string | Log level filter (INFO, WARN, ERROR, etc.) or empty. |
| `pattern` | string | Literal message pattern or empty. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of matching log entries. |

**Example**

```lua
do
    local paths = fixture_paths()
    local result = lurek.grep.logSearch(paths.log, "ERROR", "panic")
    local first = result[1]
    local level = first and first.level or "nil"
    local line = first and first.line or -1
    grep_log("logSearch hits=" .. #result .. " level=" .. tostring(level) .. " line=" .. tostring(line))
end
```

---

### `lurek.grep.luaFilter`

Creates a file filter preconfigured for Lua files only.

```lua
lurek.grep.luaFilter()
```

**Returns**

| Type | Description |
|------|-------------|
| [LFileFilter](#lfilefilter) | Pre-configured Lua filter. |

**Example**

```lua
do
    local filter = lurek.grep.luaFilter()
    filter:excludePattern("notes")
    filter:setIncludeHidden(false)
    local engine = lurek.grep.newEngine()
    local paths = fixture_paths()
    local result = engine:searchExt(paths.search, "needle", { "lua" })
    grep_log("luaFilter companion search matched=" .. result.total_matches .. " across " .. result.files_searched .. " files")
end
```

---

### `lurek.grep.newEngine`

Create a new grep engine with default settings.

```lua
lurek.grep.newEngine()
```

**Returns**

| Type | Description |
|------|-------------|
| [LGrepEngine](#lgrepengine) | Grep engine instance. |

**Example**

```lua
do
    local paths = fixture_paths()
    local engine = lurek.grep.newEngine()
    local result = engine:search(paths.search, "needle")
    local total = result.total_matches
    local files = result.files_searched
    grep_log("newEngine files=" .. files .. " total_matches=" .. total)
end
```

---

### `lurek.grep.newEngineOpts`

Create a grep engine with custom options.

```lua
lurek.grep.newEngineOpts(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | Options: threads (integer), case_sensitive (boolean), whole_word (boolean), max_file_size (integer). |

**Returns**

| Type | Description |
|------|-------------|
| [LGrepEngine](#lgrepengine) | Grep engine instance. |

**Example**

```lua
do
    local paths = fixture_paths()
    local opts = { threads = 2, case_sensitive = true, whole_word = false, max_file_size = 4096 }
    local engine = lurek.grep.newEngineOpts(opts)
    local result = engine:search(paths.search, "needle")
    local matched = result.files_matched
    local total = result.total_matches
    grep_log("newEngineOpts matched_files=" .. matched .. " total_matches=" .. total)
end
```

---

### `lurek.grep.newFilter`

Creates an empty file filter for custom include rules.

```lua
lurek.grep.newFilter()
```

**Returns**

| Type | Description |
|------|-------------|
| [LFileFilter](#lfilefilter) | File filter instance. |

**Example**

```lua
do
    local filter = lurek.grep.newFilter()
    filter:addExtension("lua")
    filter:excludeExtension("txt")
    filter:excludePattern("vendor")
    filter:setIncludeHidden(false)
    grep_log("newFilter configured for lua files without txt or vendor paths")
end
```

---

### `lurek.grep.search`

Search a directory for a literal pattern in game content files.

```lua
lurek.grep.search(path, pattern)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Directory path. |
| `pattern` | string | Text to search for. |

**Returns**

| Type | Description |
|------|-------------|
| table | Search result. |

**Example**

```lua
do
    local paths = fixture_paths()
    local result = lurek.grep.search(paths.search, "needle")
    local first = result.matches[1]
    local line = first and first.lines and first.lines[1]
    local line_no = line and line.line or -1
    grep_log("search files=" .. result.files_searched .. " matched=" .. result.files_matched .. " first_line=" .. line_no)
end
```

---

## Module Fields

*No module-level fields documented.*

## Callbacks

*No callback parameters documented in this module.*

## Enums

*No module-specific enums documented.*

## Types

- [LFileFilter](#lfilefilter)
- [LGrepEngine](#lgrepengine)

## LFileFilter

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LFileFilter:addExtension`

Add an allowed file extension to this filter.

```lua
LFileFilter:addExtension(ext)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ext` | string | Extension (without dot). |

**Example**

```lua
do
    local filter = lurek.grep.newFilter()
    filter:addExtension("lua")
    filter:addExtension("toml")
    filter:excludePattern("vendor")
    filter:setIncludeHidden(false)
    grep_log("LFileFilter:addExtension added lua and toml include rules")
end
```

---

#### `LFileFilter:excludeExtension`

Add an excluded file extension to this filter.

```lua
LFileFilter:excludeExtension(ext)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ext` | string | Extension to exclude. |

**Example**

```lua
do
    local filter = lurek.grep.newFilter()
    filter:addExtension("lua")
    filter:excludeExtension("txt")
    filter:excludePattern("notes")
    filter:setIncludeHidden(false)
    grep_log("LFileFilter:excludeExtension configured txt exclusion")
end
```

---

#### `LFileFilter:excludePattern`

Add a path substring exclusion rule to this filter.

```lua
LFileFilter:excludePattern(pattern)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pattern` | string | Substring to exclude in file paths. |

**Example**

```lua
do
    local filter = lurek.grep.newFilter()
    filter:addExtension("lua")
    filter:excludePattern("notes")
    filter:excludePattern("vendor")
    filter:setIncludeHidden(false)
    grep_log("LFileFilter:excludePattern configured notes/vendor path exclusions")
end
```

---

#### `LFileFilter:setIncludeHidden`

Set whether hidden files are included.

```lua
LFileFilter:setIncludeHidden(include)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `include` | boolean | Include hidden files. |

**Example**

```lua
do
    local filter = lurek.grep.newFilter()
    filter:addExtension("lua")
    filter:setIncludeHidden(true)
    filter:setIncludeHidden(false)
    filter:excludePattern(".git")
    grep_log("LFileFilter:setIncludeHidden toggled hidden file scanning")
end
```

---

## LGrepEngine

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LGrepEngine:count`

Count total literal matches without returning line details.

```lua
LGrepEngine:count(path, pattern)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Directory to search. |
| `pattern` | string | Text pattern. |

**Returns**

| Type | Description |
|------|-------------|
| number | Total match count. |

**Example**

```lua
do
    local paths = fixture_paths()
    local engine = lurek.grep.newEngine()
    local count = engine:count(paths.search, "needle")
    local search = engine:search(paths.search, "needle")
    local files = search.files_searched
    grep_log("LGrepEngine:count total=" .. count .. " files=" .. files)
end
```

---

#### `LGrepEngine:multiSearch`

Search with multiple literal patterns simultaneously.

```lua
LGrepEngine:multiSearch(path, patterns)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Directory to search. |
| `patterns` | table | Array of literal patterns. |

**Returns**

| Type | Description |
|------|-------------|
| table | Search result. |

**Example**

```lua
do
    local paths = fixture_paths()
    local engine = lurek.grep.newEngine()
    local result = engine:multiSearch(paths.search, { "needle", "other" })
    local first = result.matches[1]
    local path = first and first.path or "nil"
    grep_log("LGrepEngine:multiSearch files=" .. result.files_searched .. " total=" .. result.total_matches .. " first_path=" .. tostring(path))
end
```

---

#### `LGrepEngine:search`

Search a directory for a literal pattern.

```lua
LGrepEngine:search(path, pattern)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Directory to search. |
| `pattern` | string | Text pattern to find. |

**Returns**

| Type | Description |
|------|-------------|
| table | Search result with matches, files_searched, total_matches, duration_ms. |

**Example**

```lua
do
    local paths = fixture_paths()
    local engine = lurek.grep.newEngine()
    local result = engine:search(paths.search, "needle")
    local first = result.matches[1]
    local path = first and first.path or "nil"
    grep_log("LGrepEngine:search files=" .. result.files_searched .. " total=" .. result.total_matches .. " first_path=" .. tostring(path))
end
```

---

#### `LGrepEngine:searchExt`

Search with a file extension filter.

```lua
LGrepEngine:searchExt(path, pattern, extensions)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Directory to search. |
| `pattern` | string | Text pattern. |
| `extensions` | table | Array of file extensions (for example {"lua", "toml"}). |

**Returns**

| Type | Description |
|------|-------------|
| table | Search result. |

**Example**

```lua
do
    local paths = fixture_paths()
    local engine = lurek.grep.newEngine()
    local result = engine:searchExt(paths.search, "needle", { "lua" })
    local total = result.total_matches
    local files = result.files_searched
    local matched = result.files_matched
    grep_log("LGrepEngine:searchExt files=" .. files .. " matched=" .. matched .. " total=" .. total)
end
```

---

#### `LGrepEngine:searchFiles`

Search a specific provided list of files for text matches.

```lua
LGrepEngine:searchFiles(files, pattern)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `files` | table | Array of file paths. |
| `pattern` | string | Text pattern. |

**Returns**

| Type | Description |
|------|-------------|
| table | Search result. |

**Example**

```lua
do
    local paths = fixture_paths()
    local engine = lurek.grep.newEngine()
    local result = engine:searchFiles({ paths.alpha, paths.beta }, "needle")
    local first = result.matches[1]
    local path = first and first.path or "nil"
    grep_log("LGrepEngine:searchFiles files=" .. result.files_searched .. " total=" .. result.total_matches .. " first=" .. tostring(path))
end
```

---
