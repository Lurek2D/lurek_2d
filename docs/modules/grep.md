# Grep

- The `grep` module is a parallel, multi-strategy text search engine for game content files, supporting literal, regex, glob, fuzzy, and multi-pattern matching alongside specialized JSON path and structured log search.

The `grep` module exposes a full-featured file search engine to Lua game scripts and developer tooling. At its core, the `GrepEngine` wires together a `FileFilter` (controlling which files to search by extension, path glob, and hidden-file rules), a compiled `Matcher` (selecting the search strategy), and a Rayon parallel thread pool sized from `GrepConfig`. Searches can be expressed as literal strings, regular expressions, shell globs, edit-distance fuzzy patterns, or Aho-Corasick multi-literal sets — all returning structured `GrepResult` values with per-file `FileMatch` arrays and `LineMatch` byte-span positions.

Performance is addressed at multiple levels. Small files use buffered I/O; large files above a configurable threshold switch to `memmap2` zero-copy memory-mapped access, avoiding heap allocation for multi-megabyte assets. Parallel dispatch via Rayon distributes file slices across worker threads, with a `thread_count` of 0 forcing safe single-threaded mode.

Beyond general text search, the module includes two specialized engines. The `json_search` path traverses JSON files using a `/`-separated key path syntax, extracting nested values without loading the entire document into a Lua table. The `log_search` path parses structured log lines in `[LEVEL TIMESTAMP] MESSAGE` format, filtering by severity level, time range, and text pattern — enabling game scripts to query the engine's runtime log for debugging or telemetry analysis. Streaming search with callbacks is supported for real-time result delivery in UI tools. All functionality is accessible via `lurek.grep.*`, making this the primary tool for in-engine asset auditing, content discovery, and developer productivity features.

## Functions

### `lurek.grep.jsonSearch`

Searches a JSON file for all values associated with a given key name at any depth.

```lua
-- signature
lurek.grep.jsonSearch(file, key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `file` | `string` | Path to the JSON file to search. |
| `key` | `string` | Key name to search for in the JSON structure. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Array of tables with fields: path (string), value (string). |

**Example**

```lua
do
    local results = lurek.grep.jsonSearch("content/examples", "api-stub")
    print("json results = " .. #results)
end
```

---

### `lurek.grep.logSearch`

Searches a structured log file by log level and regex pattern, returning matched entries.

```lua
-- signature
lurek.grep.logSearch(file, level, pattern)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `file` | `string` | Path to the log file to search. |
| `level` | `string` | Log level filter (e.g. "ERROR", "WARN"); empty string matches all. |
| `pattern` | `string` | Regex pattern to match against log messages; empty string matches all. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Array of tables with fields: line (integer), message (string), timestamp (string?), level (string?). |

**Example**

```lua
do
    local results = lurek.grep.logSearch("logs/runtime.log", "ERROR", "panic")
    print("log results = " .. #results)
end
```

---

### `lurek.grep.luaFilter`

Creates a file filter preset that matches only Lua source files (.lua extension).

```lua
-- signature
lurek.grep.luaFilter()
```

**Returns**

| Type | Description |
|------|-------------|
| `LFileFilter` | A file filter configured for Lua files only. |

**Example**

```lua
do
    local fil = lurek.grep.luaFilter()
    print("lua filter created = " .. tostring(fil ~= nil))
end
```

---

### `lurek.grep.newEngine`

Creates a new grep engine with default configuration settings.

```lua
-- signature
lurek.grep.newEngine()
```

**Returns**

| Type | Description |
|------|-------------|
| `LGrepEngine` | A new grep engine instance. |

**Example**

```lua
do
    local eng = lurek.grep.newEngine()
    print("engine created = " .. tostring(eng ~= nil))
end
```

---

### `lurek.grep.newEngineOpts`

Creates a new grep engine with custom search configuration options.

```lua
-- signature
lurek.grep.newEngineOpts(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | `table` | Options table with fields: threads (integer), case_sensitive (boolean), whole_word (boolean), max_file_size (integer). |

**Returns**

| Type | Description |
|------|-------------|
| `LGrepEngine` | A new configured grep engine instance. |

**Example**

```lua
do
    local opts = { case_sensitive = false, threads = 2, whole_word = false }
    local eng = lurek.grep.newEngineOpts(opts)
    print("engine with opts created = " .. tostring(eng ~= nil))
end
```

---

### `lurek.grep.newFilter`

Creates a new empty file filter that can be configured to match specific file patterns.

```lua
-- signature
lurek.grep.newFilter()
```

**Returns**

| Type | Description |
|------|-------------|
| `LFileFilter` | A new empty file filter instance. |

**Example**

```lua
do
    local fil = lurek.grep.newFilter()
    fil:addExtension("lua")
    print("filter created = " .. tostring(fil ~= nil))
end
```

---

### `lurek.grep.search`

Searches a directory tree for files containing an exact literal pattern string.

```lua
-- signature
lurek.grep.search(path, pattern)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | Root directory path to search in. |
| `pattern` | `string` | Literal text pattern to search for. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Array of tables with fields: file (string), line (integer), text (string). |

**Example**

```lua
do
    local results = lurek.grep.search("content/examples", "api-stub")
    print("files searched = " .. results.files_searched)
    print("total matches = " .. results.total_matches)
end
```

---

## LFileFilter

### `LFileFilter:addExtension`

Add allowed file extensions — Lua userdata object exposed by the engine.

```lua
-- signature
LFileFilter:addExtension(ext)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ext` | `string` | Extension (without dot). |

**Example**

```lua
do
    local fil = lurek.grep.newFilter()
    fil:addExtension("lua")
    fil:addExtension("toml")
    print("LFileFilter:addExtension ok")
end
```

---

### `LFileFilter:excludeExtension`

Add excluded file extension for this object.

```lua
-- signature
LFileFilter:excludeExtension(ext)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ext` | `string` | Extension to exclude. |

**Example**

```lua
do
    local fil = lurek.grep.newFilter()
    fil:excludeExtension("min.lua")
    print("LFileFilter:excludeExtension ok")
end
```

---

### `LFileFilter:excludePattern`

Add path pattern to exclude for this object.

```lua
-- signature
LFileFilter:excludePattern(pattern)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pattern` | `string` | Substring to exclude in file paths. |

**Example**

```lua
do
    local fil = lurek.grep.newFilter()
    fil:excludePattern("test_")
    print("LFileFilter:excludePattern ok")
end
```

---

### `LFileFilter:setIncludeHidden`

Set whether hidden files are included.

```lua
-- signature
LFileFilter:setIncludeHidden(include)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `include` | `boolean` | Include hidden files. |

**Example**

```lua
do
    local fil = lurek.grep.newFilter()
    fil:setIncludeHidden(false)
    print("LFileFilter:setIncludeHidden ok")
end
```

---

## LGrepEngine

### `LGrepEngine:count`

Count total matches without returning line details.

```lua
-- signature
LGrepEngine:count(path, pattern)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | Directory to search. |
| `pattern` | `string` | Text pattern. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Total match count. |

**Example**

```lua
do
    local eng = lurek.grep.newEngine()
    local n = eng:count("content/examples", "api-stub")
    print("LGrepEngine:count=" .. n)
end
```

---

### `LGrepEngine:multiSearch`

Search with multiple patterns simultaneously.

```lua
-- signature
LGrepEngine:multiSearch(path, patterns)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | Directory to search. |
| `patterns` | `table` | Array of literal patterns. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Search result. |

**Example**

```lua
do
    local eng = lurek.grep.newEngine()
    local results = eng:multiSearch("content/examples", { "api-stub", "lurek.math" })
    print("LGrepEngine:multiSearch files=" .. results.files_searched)
    print("LGrepEngine:multiSearch matches=" .. results.total_matches)
end
```

---

### `LGrepEngine:search`

Search a directory for a literal pattern.

```lua
-- signature
LGrepEngine:search(path, pattern)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | Directory to search. |
| `pattern` | `string` | Text pattern to find. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Search result with matches, files_searched, total_matches, duration_ms. |

**Example**

```lua
do
    local eng = lurek.grep.newEngine()
    local ok, results = pcall(function() return eng:search("content/examples", "api-stub") end)
    if ok then
        print("LGrepEngine:search files=" .. results.files_searched)
        print("LGrepEngine:search matches=" .. results.total_matches)
    else
        print("LGrepEngine:search skipped: " .. tostring(results))
    end
end
```

---

### `LGrepEngine:searchExt`

Search with file extension filter.

```lua
-- signature
LGrepEngine:searchExt(path, pattern, extensions)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | Directory to search. |
| `pattern` | `string` | Text pattern. |
| `extensions` | `table` | Array of file extensions (e.g., {"lua", "toml"}). |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Search result. |

**Example**

```lua
do
    local eng = lurek.grep.newEngine()
    local ok, results = pcall(function() return eng:searchExt("content/examples", "api-stub", { "lua" }) end)
    if ok then
        print("LGrepEngine:searchExt files=" .. results.files_searched)
        print("LGrepEngine:searchExt matches=" .. results.total_matches)
    else
        print("LGrepEngine:searchExt skipped: " .. tostring(results))
    end
end
```

---

### `LGrepEngine:searchFiles`

Search a specific provided list of files for text matches.

```lua
-- signature
LGrepEngine:searchFiles(files, pattern)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `files` | `table` | Array of file paths. |
| `pattern` | `string` | Text pattern. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Search result. |

**Example**

```lua
do
    local eng = lurek.grep.newEngine()
    local results = eng:searchFiles({ "content/examples/grep.lua", "content/examples/font.lua" }, "api-stub")
    print("LGrepEngine:searchFiles files=" .. results.files_searched)
    print("LGrepEngine:searchFiles matches=" .. results.total_matches)
end
```

---
