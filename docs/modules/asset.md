# Asset

## Purpose

Caches, tags, and queries reference-counted asset handles.

## When To Use

- Its core value is lifecycle control: the cache keeps assets deduplicated, reference counted, and discoverable by name, group, and tag.
- Preload and lookup features keep it useful during startup setup, content pipelines, and diagnostics because the same module can answer what is loaded and what should stay alive.
- Read it as the ownership layer for resource identity and retention. Neighboring modules still decide how loaded resources are consumed.

## Minimal Example

Example block: `lurek.asset.load`

```lua
do
    -- Minimal load: text type reads file content immediately.
    local h = lurek.asset.load(PATH_TEXT, "text")
    example_print_log("loaded: " .. h:type())
    lurek.asset.unload(h)

    -- load type=toml
    local ht = lurek.asset.load(PATH_TOML, "toml")
    example_print_log("toml loaded: " .. tostring(lurek.asset.isLoaded(ht)))
    lurek.asset.unload(ht)

    -- load type=json
    local hj = lurek.asset.load(PATH_JSON, "json")
    example_print_log("json loaded: " .. tostring(lurek.asset.isLoaded(hj)))
    lurek.asset.unload(hj)

    -- load type=lua
    local hl = lurek.asset.load(PATH_LUA, "lua")
    example_print_log("lua loaded: " .. tostring(lurek.asset.isLoaded(hl)))
    lurek.asset.unload(hl)

    -- load type=shader
    local hs = lurek.asset.load(PATH_SHADER, "shader")
    example_print_log("shader loaded: " .. tostring(lurek.asset.isLoaded(hs)))
    lurek.asset.unload(hs)

    -- load type=obj (any text file works for raw OBJ geometry)
    local ho = lurek.asset.load(PATH_OBJ, "obj")
    example_print_log("obj loaded: " .. tostring(lurek.asset.isLoaded(ho)))
    lurek.asset.unload(ho)

    -- load type=music (binary path reference only; no file content cached)
    local hm = lurek.asset.load(PATH_BIN, "music")
    example_print_log("music loaded: " .. tostring(lurek.asset.isLoaded(hm)))
    lurek.asset.unload(hm)

    -- load type=audio (same as music but semantically a sound effect)
    local ha = lurek.asset.load(PATH_BIN, "audio")
    example_print_log("audio loaded: " .. tostring(lurek.asset.isLoaded(ha)))
    lurek.asset.unload(ha)

    -- load with opts: name, group, and tags supplied inline.
    local h = lurek.asset.load(PATH_TOML, "toml", {
        name  = "build_config",
        group = "project",
        tags  = {"config", "meta"},
    })
    example_print_log("name="  .. lurek.asset.getName(h))
    example_print_log("group=" .. lurek.asset.getGroup(h))
    example_print_log("hasTag config=" .. tostring(lurek.asset.hasTag(h, "config")))
    lurek.asset.unload(h)
end
```

## Common Patterns

- Start with `lurek.asset.addTag` when exploring this module.
- Start with `lurek.asset.clear` when exploring this module.
- Start with `lurek.asset.findByGroup` when exploring this module.
- Start with `lurek.asset.findByName` when exploring this module.
- Start with `lurek.asset.findByTag` when exploring this module.

## API Reference

- This page is the generated API reference for this module.

## Summary

- The `asset` module is the shared runtime catalog for loaded resources, so users can work with stable handles instead of repeatedly reopening raw file paths.
- Its core value is lifecycle control: the cache keeps assets deduplicated, reference counted, and discoverable by name, group, and tag.
- Preload and lookup features keep it useful during startup setup, content pipelines, and diagnostics because the same module can answer what is loaded and what should stay alive.
- Read it as the ownership layer for resource identity and retention. Neighboring modules still decide how loaded resources are consumed.

This module is mostly self-contained inside the `Feature Systems` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Functions

### `lurek.asset.addTag`

Adds a tag to the tag set of an asset handle.

```lua
lurek.asset.addTag(handle, tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle` | [LAssetHandle](#lassethandle) | Asset handle to update. |
| `tag` | string | Tag string to add. |

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local h = lurek.asset.load(PATH_JSON, "json")
    lurek.asset.addTag(h, "config")
    lurek.asset.addTag(h, "ui")
    example_print_log("hasTag config=" .. tostring(lurek.asset.hasTag(h, "config")))
    lurek.asset.unload(h)
end
```

---

### `lurek.asset.clear`

Removes all entries from the cache immediately, regardless of ref counts.

```lua
lurek.asset.clear()
```

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    lurek.asset.load(PATH_TEXT, "text", { group = "temp" })
    lurek.asset.load(PATH_JSON, "json", { group = "temp" })
    local before = lurek.asset.stats()
    lurek.asset.clear()
    local after = lurek.asset.stats()
    example_print_log("clear removed loaded=" .. before.loaded .. " -> " .. after.loaded)
end
```

---

### `lurek.asset.findByGroup`

Returns an array of asset handles whose group label exactly matches `group`.

```lua
lurek.asset.findByGroup(group)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `group` | string | Group label to match. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of `[LAssetHandle](#lassethandle)` values in the given group. |

**Example**

```lua
do
    lurek.asset.clear()
    local h1 = lurek.asset.load(PATH_JSON,   "json",   {group = "ui"})
    local h2 = lurek.asset.load(PATH_TOML,   "toml",   {group = "ui"})
    local h3 = lurek.asset.load(PATH_SHADER, "shader", {group = "gfx"})

    local ui = lurek.asset.findByGroup("ui")
    example_print_log("findByGroup 'ui' count=" .. #ui)   -- 2
    local gfx = lurek.asset.findByGroup("gfx")
    example_print_log("findByGroup 'gfx' count=" .. #gfx) -- 1
    lurek.asset.clear()
end
```

---

### `lurek.asset.findByName`

Returns an array of asset handles whose display name contains the substring.

```lua
lurek.asset.findByName(substr)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `substr` | string | Substring to search for in display names. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of `[LAssetHandle](#lassethandle)` values whose name contains `substr`. |

**Example**

```lua
do
    lurek.asset.clear()
    local h1 = lurek.asset.load(PATH_TOML,   "toml", {name = "ProjectConfig"})
    local h2 = lurek.asset.load(PATH_JSON,   "json", {name = "FontAtlas"})
    local h3 = lurek.asset.load(PATH_SHADER, "shader")  -- stem = "province_map"

    -- Substring search is case-insensitive.
    local matches = lurek.asset.findByName("config")
    example_print_log("findByName 'config' count=" .. #matches)  -- 1
    local shader_matches = lurek.asset.findByName("province")
    example_print_log("findByName 'province' count=" .. #shader_matches)  -- 1
    lurek.asset.clear()
end
```

---

### `lurek.asset.findByTag`

Returns an array of asset handles that have the given tag in their tag set.

```lua
lurek.asset.findByTag(tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tag` | string | Tag string to match. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of `[LAssetHandle](#lassethandle)` values tagged with `tag`. |

**Example**

```lua
do
    lurek.asset.clear()
    local h1 = lurek.asset.load(PATH_JSON,   "json")
    local h2 = lurek.asset.load(PATH_TOML,   "toml")
    local h3 = lurek.asset.load(PATH_SHADER, "shader")
    lurek.asset.addTag(h1, "config")
    lurek.asset.addTag(h2, "config")
    lurek.asset.addTag(h3, "gfx")

    local config = lurek.asset.findByTag("config")
    example_print_log("findByTag 'config' count=" .. #config)  -- 2
    local gfx = lurek.asset.findByTag("gfx")
    example_print_log("findByTag 'gfx' count=" .. #gfx)        -- 1
    lurek.asset.clear()
end
```

---

### `lurek.asset.findByType`

Returns an array of asset handles whose type exactly matches `type_str`.

```lua
lurek.asset.findByType(type_str)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_str` | string | Type string such as `"image"`, `"audio"`, `"toml"`. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of `[LAssetHandle](#lassethandle)` values of that type. |

**Example**

```lua
do
    lurek.asset.clear()
    local h1 = lurek.asset.load(PATH_JSON,   "json")
    local h2 = lurek.asset.load(PATH_TOML,   "toml")
    local h3 = lurek.asset.load(PATH_TOML,   "toml")
    local h4 = lurek.asset.load(PATH_SHADER, "shader")
    local h5 = lurek.asset.load(PATH_BIN,    "music")

    example_print_log("findByType 'toml' count="   .. #lurek.asset.findByType("toml"))    -- 2
    example_print_log("findByType 'json' count="   .. #lurek.asset.findByType("json"))    -- 1
    example_print_log("findByType 'shader' count=" .. #lurek.asset.findByType("shader"))  -- 1
    example_print_log("findByType 'music' count="  .. #lurek.asset.findByType("music"))   -- 1
    example_print_log("findByType 'audio' count="  .. #lurek.asset.findByType("audio"))   -- 0
    lurek.asset.clear()
end
```

---

### `lurek.asset.get`

Returns the underlying asset value for a cached handle.

```lua
lurek.asset.get(handle)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle` | [LAssetHandle](#lassethandle) | Asset handle to retrieve. |

**Returns**

| Type | Description |
|------|-------------|
| string | Source text for text-like asset types. |

**Example**

```lua
do
    -- get() for text-like types returns cached file content as a string.
    local h = lurek.asset.load(PATH_TEXT, "text")
    local content = lurek.asset.get(h)
    example_print_log("content length=" .. tostring(type(content) == "string" and #content or 0))
    lurek.asset.unload(h)

    -- get() for toml returns the raw TOML source.
    local ht = lurek.asset.load(PATH_TOML, "toml")
    local toml_src = lurek.asset.get(ht)
    example_print_log("toml source length=" .. #toml_src)
    lurek.asset.unload(ht)
end
```

---

### `lurek.asset.getGroup`

Returns the group label for an asset handle.

```lua
lurek.asset.getGroup(handle)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle` | [LAssetHandle](#lassethandle) | Asset handle to query. |

**Returns**

| Type | Description |
|------|-------------|
| string | Group label or empty string. |

**Example**

```lua
do
    local h = lurek.asset.load(PATH_JSON, "json")
    example_print_log("getGroup (unset)=" .. lurek.asset.getGroup(h))   -- ""
    lurek.asset.setGroup(h, "hud")
    example_print_log("getGroup (set)=" .. lurek.asset.getGroup(h))
    lurek.asset.unload(h)
end
```

---

### `lurek.asset.getInfo`

Returns a table containing all metadata for an asset handle.

```lua
lurek.asset.getInfo(handle)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle` | [LAssetHandle](#lassethandle) | Asset handle to inspect. |

**Returns**

| Type | Description |
|------|-------------|
| LAssetGetInfoResult | Metadata table; see fields below. |

**Example**

```lua
do
    local h = lurek.asset.load(PATH_JSON, "json", {
        name  = "ui_config",
        group = "ui",
        tags  = {"config", "ui"},
    })
    local info = lurek.asset.getInfo(h)
    example_print_log("info.path="     .. info.path)
    example_print_log("info.type="     .. info.type)
    example_print_log("info.name="     .. info.name)
    example_print_log("info.group="    .. info.group)
    example_print_log("info.refcount=" .. info.refcount)
    example_print_log("info.tags[1]="  .. tostring(info.tags[1]))
    lurek.asset.unload(h)
end
```

---

### `lurek.asset.getName`

Returns the display name of an asset handle.

```lua
lurek.asset.getName(handle)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle` | [LAssetHandle](#lassethandle) | Asset handle to query. |

**Returns**

| Type | Description |
|------|-------------|
| string | Display name or path file-stem. |

**Example**

```lua
do
    local h = lurek.asset.load(PATH_TOML, "toml")
    -- No explicit name: getName returns the path file-stem ("Cargo").
    example_print_log("getName (stem)=" .. lurek.asset.getName(h))
    lurek.asset.setName(h, "project_config")
    example_print_log("getName (set)=" .. lurek.asset.getName(h))
    lurek.asset.unload(h)
end
```

---

### `lurek.asset.getPath`

Returns the filesystem path for the asset associated with a handle.

```lua
lurek.asset.getPath(handle)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle` | [LAssetHandle](#lassethandle) | Asset handle to inspect. |

**Returns**

| Type | Description |
|------|-------------|
| string | Path that was passed to `lurek.asset.load`. |

**Example**

```lua
do
    local h = lurek.asset.load(PATH_TOML, "toml")
    local path = lurek.asset.getPath(h)
    local type_name = lurek.asset.getType(h)
    example_print_log("path=" .. path)
    example_print_log("type for path lookup=" .. type_name)
    lurek.asset.unload(h)
end
```

---

### `lurek.asset.getTags`

Returns an array of all tags for an asset handle.

```lua
lurek.asset.getTags(handle)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle` | [LAssetHandle](#lassethandle) | Asset handle to query. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of tag strings. |

**Example**

```lua
do
    local h = lurek.asset.load(PATH_JSON, "json")
    lurek.asset.addTag(h, "sfx")
    lurek.asset.addTag(h, "level_1")
    local tags = lurek.asset.getTags(h)
    example_print_log("tag count=" .. #tags)
    lurek.asset.unload(h)
end
```

---

### `lurek.asset.getType`

Returns the type string for the asset associated with a handle.

```lua
lurek.asset.getType(handle)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle` | [LAssetHandle](#lassethandle) | Asset handle to inspect. |

**Returns**

| Type | Description |
|------|-------------|
| string | Type string, for example `"image"`, `"audio"`, `"toml"`. |

**Example**

```lua
do
    local h = lurek.asset.load(PATH_TOML, "toml")
    example_print_log("type=" .. lurek.asset.getType(h))   -- "toml"
    lurek.asset.unload(h)

    local hm = lurek.asset.load(PATH_BIN, "music")
    example_print_log("music type=" .. lurek.asset.getType(hm))  -- "music"
    lurek.asset.unload(hm)
end
```

---

### `lurek.asset.hasTag`

Returns true when an asset handle has the given tag in its tag set.

```lua
lurek.asset.hasTag(handle, tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle` | [LAssetHandle](#lassethandle) | Asset handle to check. |
| `tag` | string | Tag string to test. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the tag is present. |

**Example**

```lua
do
    local h = lurek.asset.load(PATH_JSON, "json")
    lurek.asset.addTag(h, "enemy")
    example_print_log("hasTag enemy=" .. tostring(lurek.asset.hasTag(h, "enemy")))
    example_print_log("hasTag boss="  .. tostring(lurek.asset.hasTag(h, "boss")))
    lurek.asset.unload(h)
end
```

---

### `lurek.asset.isLoaded`

Returns true when the asset for the given handle is still in the cache.

```lua
lurek.asset.isLoaded(handle)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle` | [LAssetHandle](#lassethandle) | Asset handle to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the asset is still cached. |

**Example**

```lua
do
    local h = lurek.asset.load(PATH_TEXT, "text")
    local loaded_before = lurek.asset.isLoaded(h)
    lurek.asset.unload(h)
    local loaded_after = lurek.asset.isLoaded(h)
    example_print_log("isLoaded before unload=" .. tostring(loaded_before))
    example_print_log("isLoaded after unload=" .. tostring(loaded_after))
end
```

---

### `lurek.asset.load`

Loads and caches an asset by path and type, returning a ref-counted handle.

```lua
lurek.asset.load(path, asset_type, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Filesystem path to the asset file. |
| `asset_type` | string | Asset type string; see above for valid values. |
| `opts?` | table | Optional metadata: `{name, group, tags}`. |

**Returns**

| Type | Description |
|------|-------------|
| [LAssetHandle](#lassethandle) | Handle that keeps the asset alive in the cache. |

**Example**

```lua
do
    -- Minimal load: text type reads file content immediately.
    local h = lurek.asset.load(PATH_TEXT, "text")
    example_print_log("loaded: " .. h:type())
    lurek.asset.unload(h)

    -- load type=toml
    local ht = lurek.asset.load(PATH_TOML, "toml")
    example_print_log("toml loaded: " .. tostring(lurek.asset.isLoaded(ht)))
    lurek.asset.unload(ht)

    -- load type=json
    local hj = lurek.asset.load(PATH_JSON, "json")
    example_print_log("json loaded: " .. tostring(lurek.asset.isLoaded(hj)))
    lurek.asset.unload(hj)

    -- load type=lua
    local hl = lurek.asset.load(PATH_LUA, "lua")
    example_print_log("lua loaded: " .. tostring(lurek.asset.isLoaded(hl)))
    lurek.asset.unload(hl)

    -- load type=shader
    local hs = lurek.asset.load(PATH_SHADER, "shader")
    example_print_log("shader loaded: " .. tostring(lurek.asset.isLoaded(hs)))
    lurek.asset.unload(hs)

    -- load type=obj (any text file works for raw OBJ geometry)
    local ho = lurek.asset.load(PATH_OBJ, "obj")
    example_print_log("obj loaded: " .. tostring(lurek.asset.isLoaded(ho)))
    lurek.asset.unload(ho)

    -- load type=music (binary path reference only; no file content cached)
    local hm = lurek.asset.load(PATH_BIN, "music")
    example_print_log("music loaded: " .. tostring(lurek.asset.isLoaded(hm)))
    lurek.asset.unload(hm)

    -- load type=audio (same as music but semantically a sound effect)
    local ha = lurek.asset.load(PATH_BIN, "audio")
    example_print_log("audio loaded: " .. tostring(lurek.asset.isLoaded(ha)))
    lurek.asset.unload(ha)

    -- load with opts: name, group, and tags supplied inline.
    local h = lurek.asset.load(PATH_TOML, "toml", {
        name  = "build_config",
        group = "project",
        tags  = {"config", "meta"},
    })
    example_print_log("name="  .. lurek.asset.getName(h))
    example_print_log("group=" .. lurek.asset.getGroup(h))
    example_print_log("hasTag config=" .. tostring(lurek.asset.hasTag(h, "config")))
    lurek.asset.unload(h)
end
```

---

### `lurek.asset.preload`

Synchronously loads a batch of assets and fires `callback(loaded, total)` after each item.

```lua
lurek.asset.preload(paths, callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `paths` | table | Array of `{path, type}` pairs (or `{path=â€¦, type=â€¦}` tables). |
| `callback` | any | Function invoked as `callback(loaded, total)` per item; `callback(nil, nil)` on finish. |

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local results = {}
    lurek.asset.preload(
        {
            {PATH_TEXT,   "text"},
            {PATH_JSON,   "json"},
            {PATH_TOML,   "toml"},
            {PATH_LUA,    "lua"},
        },
        function(loaded, total)
            if loaded ~= nil then
                table.insert(results, loaded .. "/" .. tostring(total))
            else
                example_print_log("preload done: " .. table.concat(results, ", "))
            end
        end
    )
    lurek.asset.clear()
end
```

---

### `lurek.asset.refcount`

Returns the current ref count for a handle, or 0 when it is no longer loaded.

```lua
lurek.asset.refcount(handle)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle` | [LAssetHandle](#lassethandle) | Asset handle to inspect. |

**Returns**

| Type | Description |
|------|-------------|
| number | Current reference count. |

**Example**

```lua
do
    local h = lurek.asset.load(PATH_TEXT, "text")
    local before = lurek.asset.refcount(h)
    local same = lurek.asset.load(PATH_TEXT, "text")
    example_print_log("refcount before duplicate load=" .. before)
    example_print_log("refcount after duplicate load=" .. lurek.asset.refcount(same))
    lurek.asset.unload(h)
    lurek.asset.unload(same)
end
```

---

### `lurek.asset.removeTag`

Removes a tag from the tag set of an asset handle.

```lua
lurek.asset.removeTag(handle, tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle` | [LAssetHandle](#lassethandle) | Asset handle to update. |
| `tag` | string | Tag string to remove. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the tag was present and removed. |

**Example**

```lua
do
    local h = lurek.asset.load(PATH_JSON, "json")
    lurek.asset.addTag(h, "temp")
    local removed = lurek.asset.removeTag(h, "temp")
    example_print_log("removeTag returned=" .. tostring(removed))
    example_print_log("hasTag after remove=" .. tostring(lurek.asset.hasTag(h, "temp")))
    lurek.asset.unload(h)
end
```

---

### `lurek.asset.setGroup`

Assigns an asset handle to a named group.

```lua
lurek.asset.setGroup(handle, group)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle` | [LAssetHandle](#lassethandle) | Asset handle to update. |
| `group` | string | Group label to assign. |

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local h = lurek.asset.load(PATH_JSON, "json")
    example_print_log("group before=" .. lurek.asset.getGroup(h))
    lurek.asset.setGroup(h, "level_1")
    local grouped = lurek.asset.findByGroup("level_1")
    example_print_log("findByGroup level_1 count=" .. #grouped)
    example_print_log("setGroup → " .. lurek.asset.getGroup(h))
    lurek.asset.unload(h)
end
```

---

### `lurek.asset.setName`

Sets the display name for an asset handle.

```lua
lurek.asset.setName(handle, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle` | [LAssetHandle](#lassethandle) | Asset handle to update. |
| `name` | string | Display name to assign. |

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local h = lurek.asset.load(PATH_JSON, "json")
    example_print_log("name before=" .. lurek.asset.getName(h))
    lurek.asset.setName(h, "font_atlas")
    local named = lurek.asset.findByName("font")
    example_print_log("setName → " .. lurek.asset.getName(h))
    example_print_log("findByName font count=" .. #named)
    lurek.asset.unload(h)
end
```

---

### `lurek.asset.stats`

Returns a snapshot table describing the current cache state.

```lua
lurek.asset.stats()
```

**Returns**

| Type | Description |
|------|-------------|
| LAssetStatsResult | Table with `loaded`, `total_refs`, `types`, and `groups` fields. |

**Example**

```lua
do
    lurek.asset.clear()
    local h1 = lurek.asset.load(PATH_JSON,   "json",   {group = "data"})
    local h2 = lurek.asset.load(PATH_TOML,   "toml",   {group = "data"})
    local h3 = lurek.asset.load(PATH_SHADER, "shader", {group = "gfx"})
    local s = lurek.asset.stats()
    example_print_log("loaded="     .. s.loaded)
    example_print_log("total_refs=" .. s.total_refs)
    example_print_log("json count=" .. tostring(s.types.json))
    example_print_log("groups="     .. #s.groups)   -- 2 unique groups: "data" and "gfx"
    lurek.asset.clear()
end
```

---

### `lurek.asset.unload`

Decrements the ref count for a cached asset; removes the entry when it reaches zero.

```lua
lurek.asset.unload(handle)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle` | [LAssetHandle](#lassethandle) | Asset handle to release. |

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local h = lurek.asset.load(PATH_TEXT, "text")
    local before = lurek.asset.isLoaded(h)
    lurek.asset.unload(h)
    local after = lurek.asset.isLoaded(h)
    example_print_log("loaded before unload=" .. tostring(before))
    example_print_log("unloaded, isLoaded=" .. tostring(after))
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LAssetHandle](#lassethandle)

## LAssetHandle

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LAssetHandle:type`

Returns the Lua-visible type name for this asset handle.

```lua
LAssetHandle:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LAssetHandle](#lassethandle)`. |

**Example**

```lua
do
    local h = lurek.asset.load(PATH_TEXT, "text")
    local type_name = h:type()
    local same_type = h:typeOf(type_name)
    example_print_log("type=" .. type_name)
    example_print_log("type matches handle=" .. tostring(same_type))
    lurek.asset.unload(h)
end
```

---

#### `LAssetHandle:typeOf`

Returns whether this handle matches a supported type name.

```lua
LAssetHandle:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LAssetHandle](#lassethandle)` and `LObject`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local h = lurek.asset.load(PATH_TEXT, "text")
    example_print_log("typeOf LAssetHandle=" .. tostring(h:typeOf("LAssetHandle")))
    example_print_log("handle type name=" .. tostring(h:type()))
    example_print_log("typeOf other="        .. tostring(h:typeOf("other")))
    lurek.asset.unload(h)
end
```

---
