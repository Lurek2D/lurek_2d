# Grep

## Purpose

Provides literal-first file scanning, lightweight pattern helpers, and JSON/log searches.

## Summary

- The `grep` module is the scriptable text-search surface for users who want to scan project files, logs, or structured content from inside the engine environment.
- Search configuration, path filtering, matching, and specialized JSON or log helpers work together so one module can cover ordinary content search as well as more structured diagnostic queries.
- Literal-first behavior matters because many runtime and tooling searches are about exact identifiers, paths, or messages rather than full external-regex-engine complexity.
- Threaded scanning and result shaping make the module practical for tools, editors, audit scripts, and content workflows that need search without leaving the project runtime.
- Read it as the in-engine file-search utility layer: it does not replace every external grep tool, but it gives scripts a controlled search workflow that fits the engine's data and file model.

This module is mostly self-contained inside the `Edge/Integration` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## API Reference

- This page is the generated API reference for this module.

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
    local root = "save/_grep_example_json"
    local json = root .. "/sample.json"
    lurek.filesystem.createDirectory(root)
    lurek.filesystem.write(json, [[
{
  "kind": "enemy",
  "nested": {
    "kind": "boss",
    "hp": 10
  },
  "items": [
    { "kind": "loot" }
  ]
}
]])
    local result = lurek.grep.jsonSearch(json, "kind")
    local first = result[1]
    local third = result[3]
    lurek.log.info("jsonSearch hits=" .. #result .. " first=" .. tostring(first and first.value or "nil") .. " third=" .. tostring(third and third.value or "nil"))
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
    local root = "save/_grep_example_log"
    local log_path = root .. "/sample.log"
    lurek.filesystem.createDirectory(root)
    lurek.filesystem.write(log_path, "[INFO] boot\n[ERROR] panic: sample failure\n[WARN] recoverable issue\n")
    local result = lurek.grep.logSearch(log_path, "ERROR", "panic")
    local first = result[1]
    lurek.log.info("logSearch hits=" .. #result .. " level=" .. tostring(first and first.level or "nil") .. " line=" .. tostring(first and first.line or -1))
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
    local root = "save/_grep_example_lua_filter"
    local search = root .. "/search"
    lurek.filesystem.createDirectory(root)
    lurek.filesystem.createDirectory(search)
    lurek.filesystem.write(search .. "/alpha.lua", "local needle = 'alpha'\nprint('needle alpha')\n")
    lurek.filesystem.write(search .. "/notes.txt", "needle in text file\n")
    local filter = lurek.grep.luaFilter()
    filter:excludePattern("notes")
    local result = lurek.grep.newEngine():searchExt(search, "needle", { "lua" })
    lurek.log.info("luaFilter companion search matched=" .. result.total_matches .. " across " .. result.files_searched .. " files")
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
    local root = "save/_grep_example_new_engine"
    local search = root .. "/search"
    lurek.filesystem.createDirectory(root)
    lurek.filesystem.createDirectory(search)
    lurek.filesystem.write(search .. "/alpha.lua", "local needle = 'alpha'\nprint('needle alpha')\n")
    lurek.filesystem.write(search .. "/beta.lua", "local needle = 'beta'\n")
    local engine = lurek.grep.newEngine()
    local result = engine:search(search, "needle")
    lurek.log.info("newEngine files=" .. result.files_searched .. " total_matches=" .. result.total_matches)
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
    local root = "save/_grep_example_new_engine_opts"
    local search = root .. "/search"
    lurek.filesystem.createDirectory(root)
    lurek.filesystem.createDirectory(search)
    lurek.filesystem.write(search .. "/alpha.lua", "local needle = 'alpha'\nprint('needle alpha')\n")
    lurek.filesystem.write(search .. "/beta.lua", "local needle = 'beta'\n")
    local engine = lurek.grep.newEngineOpts({ threads = 2, case_sensitive = true, whole_word = false, max_file_size = 4096 })
    local result = engine:search(search, "needle")
    lurek.log.info("newEngineOpts matched_files=" .. result.files_matched .. " total_matches=" .. result.total_matches)
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
    lurek.log.info("newFilter configured for lua files without txt or vendor paths")
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
    local root = "save/_grep_example_search"
    local search = root .. "/search"
    local forbidden = "save/_grep_example_search_forbidden"
    lurek.filesystem.createDirectory(root)
    lurek.filesystem.createDirectory(search)
    lurek.filesystem.createDirectory(forbidden)
    lurek.filesystem.write(search .. "/alpha.lua", "local needle = 'alpha'\nprint('needle alpha')\n")
    lurek.filesystem.write(search .. "/beta.lua", "local needle = 'beta'\n")
    lurek.filesystem.write(forbidden .. "/forbidden.lua", "needle outside sandbox\n")
    local root_abs = lurek.filesystem.getSaveDirectory() .. "/_grep_example_search"
    local mod = lurek.mods.newMod({
        id = "grep_runtime_example",
        sandbox = {
            api_mode = "allow_list",
            apis = { "grep" },
            hook_mode = "allow_list",
            hooks = { "on_load" },
            read_mode = "allow_list",
            read_roots = { root_abs },
        },
    })
    mod:setHook("on_load", function()
        local allowed = lurek.grep.search(search, "needle")
        local blocked_ok = pcall(function()
            lurek.grep.search(forbidden, "needle")
        end)
        return allowed, blocked_ok
    end)
    local result, blocked_ok = mod:runHook("on_load")
    local first = result.matches[1]
    lurek.log.info("search files=" .. result.files_searched .. " matched=" .. result.files_matched .. " first_path=" .. tostring(first and first.path or "nil"))
    lurek.log.info("sandbox blocked forbidden dir=" .. tostring(not blocked_ok))
end
```

---

## Module Fields

*No module-level fields documented.*

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
    lurek.log.info("LFileFilter:addExtension added lua and toml include rules")
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
    lurek.log.info("LFileFilter:excludeExtension configured txt exclusion")
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
    lurek.log.info("LFileFilter:excludePattern configured notes/vendor path exclusions")
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
    lurek.log.info("LFileFilter:setIncludeHidden toggled hidden file scanning")
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
    local root = "save/_grep_engine_count"
    local search = root .. "/search"
    lurek.filesystem.createDirectory(root)
    lurek.filesystem.createDirectory(search)
    lurek.filesystem.write(search .. "/alpha.lua", "local needle = 'alpha'\nprint('needle alpha')\n")
    lurek.filesystem.write(search .. "/beta.lua", "local needle = 'beta'\n")
    local engine = lurek.grep.newEngine()
    local count = engine:count(search, "needle")
    local files = engine:search(search, "needle").files_searched
    lurek.log.info("LGrepEngine:count total=" .. count .. " files=" .. files)
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
    local root = "save/_grep_engine_multi_search"
    local search = root .. "/search"
    lurek.filesystem.createDirectory(root)
    lurek.filesystem.createDirectory(search)
    lurek.filesystem.write(search .. "/alpha.lua", "local needle = 'alpha'\nlocal other = 'ally'\n")
    lurek.filesystem.write(search .. "/beta.lua", "local needle = 'beta'\n")
    local result = lurek.grep.newEngine():multiSearch(search, { "needle", "other" })
    local first = result.matches[1]
    lurek.log.info("LGrepEngine:multiSearch files=" .. result.files_searched .. " total=" .. result.total_matches .. " first_path=" .. tostring(first and first.path or "nil"))
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
    local root = "save/_grep_engine_example"
    local search = root .. "/search"
    local forbidden = "save/_grep_engine_example_forbidden"
    lurek.filesystem.createDirectory(root)
    lurek.filesystem.createDirectory(search)
    lurek.filesystem.createDirectory(forbidden)
    lurek.filesystem.write(search .. "/alpha.lua", "local needle = 'alpha'\n")
    lurek.filesystem.write(search .. "/beta.lua", "local needle = 'beta'\n")
    lurek.filesystem.write(forbidden .. "/forbidden.lua", "needle outside sandbox\n")
    local root_abs = lurek.filesystem.getSaveDirectory() .. "/_grep_engine_example"
    local mod = lurek.mods.newMod({
        id = "grep_engine_runtime_example",
        sandbox = {
            api_mode = "allow_list",
            apis = { "grep" },
            hook_mode = "allow_list",
            hooks = { "on_load" },
            read_mode = "allow_list",
            read_roots = { root_abs },
        },
    })
    mod:setHook("on_load", function()
        local engine = lurek.grep.newEngine()
        local allowed = engine:search(search, "needle")
        local blocked_ok = pcall(function()
            engine:search(forbidden, "needle")
        end)
        return allowed, blocked_ok
    end)
    local result, blocked_ok = mod:runHook("on_load")
    local first = result.matches[1]
    lurek.log.info("LGrepEngine:search files=" .. result.files_searched .. " total=" .. result.total_matches .. " first_path=" .. tostring(first and first.path or "nil"))
    lurek.log.info("LGrepEngine:search sandbox blocked forbidden dir=" .. tostring(not blocked_ok))
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
    local root = "save/_grep_engine_search_ext"
    local search = root .. "/search"
    lurek.filesystem.createDirectory(root)
    lurek.filesystem.createDirectory(search)
    lurek.filesystem.write(search .. "/alpha.lua", "local needle = 'alpha'\nprint('needle alpha')\n")
    lurek.filesystem.write(search .. "/notes.txt", "needle in text file\n")
    local result = lurek.grep.newEngine():searchExt(search, "needle", { "lua" })
    lurek.log.info("LGrepEngine:searchExt files=" .. result.files_searched .. " matched=" .. result.files_matched .. " total=" .. result.total_matches)
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
    local root = "save/_grep_engine_search_files"
    local search = root .. "/search"
    local alpha = search .. "/alpha.lua"
    local beta = search .. "/beta.lua"
    lurek.filesystem.createDirectory(root)
    lurek.filesystem.createDirectory(search)
    lurek.filesystem.write(alpha, "local needle = 'alpha'\nprint('needle alpha')\n")
    lurek.filesystem.write(beta, "local needle = 'beta'\n")
    local result = lurek.grep.newEngine():searchFiles({ alpha, beta }, "needle")
    local first = result.matches[1]
    lurek.log.info("LGrepEngine:searchFiles files=" .. result.files_searched .. " total=" .. result.total_matches .. " first=" .. tostring(first and first.path or "nil"))
end
```

---
