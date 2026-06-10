# Grep

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

## Functions

### `lurek.grep.jsonSearch`

Searches a JSON file for all values associated with a given key name at any depth.

```lua
lurek.grep.jsonSearch(file, key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `file` | string | Path to the JSON file to search. |
| `key` | string | Key name to search for in the JSON structure. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of tables with fields: path (string), value (string). |

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
lurek.grep.logSearch(file, level, pattern)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `file` | string | Path to the log file to search. |
| `level` | string | Log level filter (e.g. "ERROR", "WARN"); empty string matches all. |
| `pattern` | string | Regex pattern to match against log messages; empty string matches all. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of tables with fields: line (integer), message (string), timestamp (string?), level (string?). |

**Example**

```lua
do
    local path = "save/grep_runtime.log"
    lurek.filesystem.write(path, "[INFO] boot\n[ERROR] panic: sample failure\n")
    local results = lurek.grep.logSearch(path, "ERROR", "panic")
    print("log results = " .. #results)
end
```

---

### `lurek.grep.luaFilter`

Creates a file filter preset that matches only Lua source files (.lua extension).

```lua
lurek.grep.luaFilter()
```

**Returns**

| Type | Description |
|------|-------------|
| [LFileFilter](#lfilefilter) | A file filter configured for Lua files only. |

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
lurek.grep.newEngine()
```

**Returns**

| Type | Description |
|------|-------------|
| [LGrepEngine](#lgrepengine) | A new grep engine instance. |

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
lurek.grep.newEngineOpts(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | Options table with fields: threads (integer), case_sensitive (boolean), whole_word (boolean), max_file_size (integer). |

**Returns**

| Type | Description |
|------|-------------|
| [LGrepEngine](#lgrepengine) | A new configured grep engine instance. |

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
lurek.grep.newFilter()
```

**Returns**

| Type | Description |
|------|-------------|
| [LFileFilter](#lfilefilter) | A new empty file filter instance. |

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
lurek.grep.search(path, pattern)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Root directory path to search in. |
| `pattern` | string | Literal text pattern to search for. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of tables with fields: file (string), line (integer), text (string). |

**Example**

```lua
do
    local results = lurek.grep.search("content/examples", "api-stub")
    print("files searched = " .. results.files_searched)
    print("total matches = " .. results.total_matches)
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

Add allowed file extensions â€” Lua userdata object exposed by the engine.

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
    local fil = lurek.grep.newFilter()
    fil:addExtension("lua")
    fil:addExtension("toml")
    print("LFileFilter:addExtension ok")
end
```

---

#### `LFileFilter:excludeExtension`

Add excluded file extension for this object.

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
    local fil = lurek.grep.newFilter()
    fil:excludeExtension("min.lua")
    print("LFileFilter:excludeExtension ok")
end
```

---

#### `LFileFilter:excludePattern`

Add path pattern to exclude for this object.

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
    local fil = lurek.grep.newFilter()
    fil:excludePattern("test_")
    print("LFileFilter:excludePattern ok")
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
    local fil = lurek.grep.newFilter()
    fil:setIncludeHidden(false)
    print("LFileFilter:setIncludeHidden ok")
end
```

---

## LGrepEngine

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LGrepEngine:count`

Count total matches without returning line details.

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
    local eng = lurek.grep.newEngine()
    local n = eng:count("content/examples", "api-stub")
    print("LGrepEngine:count=" .. n)
end
```

---

#### `LGrepEngine:multiSearch`

Search with multiple patterns simultaneously.

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
    local eng = lurek.grep.newEngine()
    local results = eng:multiSearch("content/examples", { "api-stub", "lurek.math" })
    print("LGrepEngine:multiSearch files=" .. results.files_searched)
    print("LGrepEngine:multiSearch matches=" .. results.total_matches)
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

#### `LGrepEngine:searchExt`

Search with file extension filter.

```lua
LGrepEngine:searchExt(path, pattern, extensions)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Directory to search. |
| `pattern` | string | Text pattern. |
| `extensions` | table | Array of file extensions (e.g., {"lua", "toml"}). |

**Returns**

| Type | Description |
|------|-------------|
| table | Search result. |

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
    local eng = lurek.grep.newEngine()
    local results = eng:searchFiles({ "content/examples/grep.lua", "content/examples/font.lua" }, "api-stub")
    print("LGrepEngine:searchFiles files=" .. results.files_searched)
    print("LGrepEngine:searchFiles matches=" .. results.total_matches)
end
```

---
