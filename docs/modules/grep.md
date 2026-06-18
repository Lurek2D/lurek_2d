# Grep

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
    local results = lurek.grep.jsonSearch("content/examples", "lurek.math")
    print("json results = " .. #results)
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
    local path = "save/grep_runtime.log"
    lurek.filesystem.write(path, "[INFO] boot\n[ERROR] panic: sample failure\n")
    local results = lurek.grep.logSearch(path, "ERROR", "panic")
    print("log results = " .. #results)
end
```

---

### `lurek.grep.luaFilter`

Create a filter for Lua files only.

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
    local fil = lurek.grep.luaFilter()
    print("lua filter created = " .. tostring(fil ~= nil))
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
    local eng = lurek.grep.newEngine()
    print("engine created = " .. tostring(eng ~= nil))
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
    local opts = { case_sensitive = false, threads = 2, whole_word = false }
    local eng = lurek.grep.newEngineOpts(opts)
    print("engine with opts created = " .. tostring(eng ~= nil))
end
```

---

### `lurek.grep.newFilter`

Create an empty file filter.

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
    local fil = lurek.grep.newFilter()
    fil:addExtension("lua")
    print("filter created = " .. tostring(fil ~= nil))
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
    local results = lurek.grep.search("content/examples", "lurek.math")
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
    local fil = lurek.grep.newFilter()
    fil:addExtension("lua")
    fil:addExtension("toml")
    print("LFileFilter:addExtension ok")
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
    local fil = lurek.grep.newFilter()
    fil:excludeExtension("min.lua")
    print("LFileFilter:excludeExtension ok")
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
    local eng = lurek.grep.newEngine()
    local n = eng:count("content/examples", "lurek.math")
    print("LGrepEngine:count=" .. n)
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
    local eng = lurek.grep.newEngine()
    local results = eng:multiSearch("content/examples", { "lurek.math", "lurek.color" })
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
    local ok, results = pcall(function() return eng:search("content/examples", "lurek.math") end)
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
    local eng = lurek.grep.newEngine()
    local ok, results = pcall(function() return eng:searchExt("content/examples", "lurek.math", { "lua" }) end)
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
    local results = eng:searchFiles({ "content/examples/grep.lua", "content/examples/font.lua" }, "lurek.math")
    print("LGrepEngine:searchFiles files=" .. results.files_searched)
    print("LGrepEngine:searchFiles matches=" .. results.total_matches)
end
```

---
