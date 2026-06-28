# Asset

## Purpose

Caches, tags, and queries reference-counted asset handles.

## Summary

- The `asset` module is the shared runtime catalog for loaded resources, so users can work with stable handles instead of repeatedly reopening raw file paths.
- Its core value is lifecycle control: the cache keeps assets deduplicated, reference counted, and discoverable by name, group, and tag.
- Preload and lookup features keep it useful during startup setup, content pipelines, and diagnostics because the same module can answer what is loaded and what should stay alive.
- Read it as the ownership layer for resource identity and retention. Neighboring modules still decide how loaded resources are consumed.

This module is mostly self-contained inside the `Feature Systems` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## API Reference

- This page is the generated API reference for this module.

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
    local handle = lurek.asset.load("assets/fonts/bitmap_fonts.json", "json")
    lurek.asset.addTag(handle, "config")
    lurek.asset.addTag(handle, "ui")
    local tags = lurek.asset.getTags(handle)
    lurek.log.info("asset tag count=" .. #tags .. " has_config=" .. tostring(lurek.asset.hasTag(handle, "config")))
    lurek.asset.unload(handle)
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
    lurek.asset.load("content/examples/assets/data/sample_hello.txt", "text", { group = "temp" })
    lurek.asset.load("content/examples/assets/data/sample_config.toml", "toml", { group = "temp" })
    local before = lurek.asset.stats()
    lurek.asset.clear()
    local after = lurek.asset.stats()
    lurek.log.info("clear removed loaded=" .. before.loaded .. " -> " .. after.loaded)
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
    lurek.asset.load("assets/fonts/bitmap_fonts.json", "json", { group = "ui" })
    lurek.asset.load("content/examples/assets/data/sample_config.toml", "toml", { group = "ui" })
    lurek.asset.load("content/examples/assets/shaders/sample_shader.wgsl", "shader", { group = "gfx" })
    local ui = lurek.asset.findByGroup("ui")
    local gfx = lurek.asset.findByGroup("gfx")
    lurek.log.info("findByGroup ui=" .. #ui .. " gfx=" .. #gfx)
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
    lurek.asset.load("content/examples/assets/data/sample_config.toml", "toml", { name = "ProjectConfig" })
    lurek.asset.load("assets/fonts/bitmap_fonts.json", "json", { name = "FontAtlas" })
    local config = lurek.asset.findByName("config")
    local font = lurek.asset.findByName("font")
    lurek.log.info("findByName config=" .. #config .. " font=" .. #font)
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
    local config_json = lurek.asset.load("assets/fonts/bitmap_fonts.json", "json")
    local config_toml = lurek.asset.load("content/examples/assets/data/sample_config.toml", "toml")
    local shader = lurek.asset.load("content/examples/assets/shaders/sample_shader.wgsl", "shader")
    lurek.asset.addTag(config_json, "config")
    lurek.asset.addTag(config_toml, "config")
    lurek.asset.addTag(shader, "gfx")
    local config = lurek.asset.findByTag("config")
    local gfx = lurek.asset.findByTag("gfx")
    lurek.log.info("findByTag config=" .. #config .. " gfx=" .. #gfx)
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
    lurek.asset.load("assets/fonts/bitmap_fonts.json", "json")
    lurek.asset.load("content/examples/assets/data/sample_config.toml", "toml")
    lurek.asset.load("content/examples/assets/shaders/sample_shader.wgsl", "shader")
    local toml = lurek.asset.findByType("toml")
    local json = lurek.asset.findByType("json")
    local shader = lurek.asset.findByType("shader")
    lurek.log.info("findByType toml=" .. #toml .. " json=" .. #json .. " shader=" .. #shader)
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
    local handle = lurek.asset.load("content/examples/assets/data/sample_hello.txt", "text")
    local content = lurek.asset.get(handle)
    local length = type(content) == "string" and #content or 0
    local loaded = lurek.asset.isLoaded(handle)
    lurek.log.info("asset content length=" .. length .. " loaded=" .. tostring(loaded))
    lurek.asset.unload(handle)
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
    local handle = lurek.asset.load("assets/fonts/bitmap_fonts.json", "json")
    local unset = lurek.asset.getGroup(handle)
    lurek.asset.setGroup(handle, "hud")
    local group = lurek.asset.getGroup(handle)
    lurek.log.info("asset groups unset=" .. unset .. " set=" .. group)
    lurek.asset.unload(handle)
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
    local handle = lurek.asset.load("assets/fonts/bitmap_fonts.json", "json", { name = "ui_config", group = "ui", tags = { "config", "ui" } })
    local info = lurek.asset.getInfo(handle)
    local tag = info.tags[1] or "none"
    lurek.log.info("asset info name=" .. info.name .. " group=" .. info.group .. " tag=" .. tag)
    lurek.asset.unload(handle)
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
    local handle = lurek.asset.load("content/examples/assets/data/sample_config.toml", "toml")
    local stem_name = lurek.asset.getName(handle)
    lurek.asset.setName(handle, "project_config")
    local custom_name = lurek.asset.getName(handle)
    lurek.log.info("asset names stem=" .. stem_name .. " custom=" .. custom_name)
    lurek.asset.unload(handle)
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
    local handle = lurek.asset.load("content/examples/assets/data/sample_config.toml", "toml")
    local path = lurek.asset.getPath(handle)
    local type_name = lurek.asset.getType(handle)
    lurek.log.info("asset path=" .. path .. " type=" .. type_name)
    lurek.asset.unload(handle)
end
```

---

### `lurek.asset.getRevision`

Returns the current reload revision for an asset handle.

```lua
lurek.asset.getRevision(handle)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle` | [LAssetHandle](#lassethandle) | Asset handle to inspect. |

**Returns**

| Type | Description |
|------|-------------|
| number | Current revision, or 0 when unloaded. |

**Example**

```lua
do
    local handle = lurek.asset.load("Cargo.toml", "toml")
    local revision = lurek.asset.getRevision(handle)
    local info = lurek.asset.resolve(handle)
    lurek.log.info("[asset] revision=" .. tostring(revision) .. " type=" .. tostring(info.type))
    lurek.asset.unload(handle)
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
    local handle = lurek.asset.load("assets/fonts/bitmap_fonts.json", "json")
    lurek.asset.addTag(handle, "ui")
    lurek.asset.addTag(handle, "level_1")
    local tags = lurek.asset.getTags(handle)
    lurek.log.info("asset tags count=" .. #tags .. " first=" .. tostring(tags[1]))
    lurek.asset.unload(handle)
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
    local handle = lurek.asset.load("content/examples/assets/data/sample_config.toml", "toml")
    local type_name = lurek.asset.getType(handle)
    local loaded = lurek.asset.isLoaded(handle)
    lurek.log.info("asset type=" .. type_name .. " loaded=" .. tostring(loaded))
    lurek.asset.unload(handle)
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
    local handle = lurek.asset.load("assets/fonts/bitmap_fonts.json", "json")
    lurek.asset.addTag(handle, "enemy")
    local has_enemy = lurek.asset.hasTag(handle, "enemy")
    local has_boss = lurek.asset.hasTag(handle, "boss")
    lurek.log.info("asset hasTag enemy=" .. tostring(has_enemy) .. " boss=" .. tostring(has_boss))
    lurek.asset.unload(handle)
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
    local handle = lurek.asset.load("content/examples/assets/data/sample_hello.txt", "text")
    local before = lurek.asset.isLoaded(handle)
    lurek.asset.unload(handle)
    local after = lurek.asset.isLoaded(handle)
    local refs = lurek.asset.refcount(handle)
    lurek.log.info("isLoaded before=" .. tostring(before) .. " after=" .. tostring(after) .. " refs=" .. refs)
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
    local path = "content/examples/assets/data/sample_config.toml"
    local handle = lurek.asset.load(path, "toml", { name = "build_config", group = "project", tags = { "config" } })
    local loaded = lurek.asset.isLoaded(handle)
    local name = lurek.asset.getName(handle)
    local group = lurek.asset.getGroup(handle)
    lurek.log.info("loaded asset name=" .. name .. " group=" .. group .. " loaded=" .. tostring(loaded))
    lurek.asset.unload(handle)
end
```

---

### `lurek.asset.loadManifest`

Loads a TOML asset manifest and registers listed assets without transforming them.

```lua
lurek.asset.loadManifest(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Manifest path. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of `[LAssetHandle](#lassethandle)` values for loaded entries. |

**Example**

```lua
do
    local handles = lurek.asset.loadManifest("tests/fixtures/asset_manifest.toml")
    local first = handles[1]
    local info = lurek.asset.resolve(first)
    lurek.log.info("[asset] manifest loaded " .. tostring(info.name))
    lurek.asset.clear()
end
```

---

### `lurek.asset.onReload`

Registers a callback fired by `lurek.asset.reload(handle)`.

```lua
lurek.asset.onReload(handle, callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle` | [LAssetHandle](#lassethandle) | Asset handle to observe. |
| `callback` | function | Called as `callback(handle, revision)`. |

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local handle = lurek.asset.load("Cargo.toml", "toml")
    local seen = 0
    lurek.asset.onReload(handle, function(_, revision) seen = revision end)
    local revision = lurek.asset.reload(handle)
    lurek.log.info("[asset] callback revision=" .. tostring(seen or revision))
    lurek.asset.unload(handle)
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
    lurek.asset.preload({
        { "content/examples/assets/data/sample_hello.txt", "text" },
        { "content/examples/assets/data/sample_config.toml", "toml" },
    }, function(loaded, total)
        results[#results + 1] = loaded and (loaded .. "/" .. tostring(total)) or "done"
    end)
    lurek.log.info("preload progress=" .. table.concat(results, ","))
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
    local path = "content/examples/assets/data/sample_hello.txt"
    local first = lurek.asset.load(path, "text")
    local before = lurek.asset.refcount(first)
    local second = lurek.asset.load(path, "text")
    local after = lurek.asset.refcount(second)
    lurek.log.info("asset refcount " .. before .. " -> " .. after)
    lurek.asset.unload(first)
    lurek.asset.unload(second)
end
```

---

### `lurek.asset.reload`

Reloads the cached asset metadata/content and increments its revision.

```lua
lurek.asset.reload(handle)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle` | [LAssetHandle](#lassethandle) | Asset handle to refresh. |

**Returns**

| Type | Description |
|------|-------------|
| number | New revision. |

**Example**

```lua
do
    local handle = lurek.asset.load("Cargo.toml", "toml")
    local before = lurek.asset.getRevision(handle)
    local after = lurek.asset.reload(handle)
    lurek.log.info("[asset] reload revision " .. tostring(before) .. " -> " .. tostring(after))
    lurek.asset.unload(handle)
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
    local handle = lurek.asset.load("assets/fonts/bitmap_fonts.json", "json")
    lurek.asset.addTag(handle, "temp")
    local removed = lurek.asset.removeTag(handle, "temp")
    local still_tagged = lurek.asset.hasTag(handle, "temp")
    lurek.log.info("asset removeTag removed=" .. tostring(removed) .. " still_tagged=" .. tostring(still_tagged))
    lurek.asset.unload(handle)
end
```

---

### `lurek.asset.resolve`

Returns a metadata snapshot for an asset handle without transforming the asset data.

```lua
lurek.asset.resolve(handle)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle` | [LAssetHandle](#lassethandle) | Asset handle to inspect. |

**Returns**

| Type | Description |
|------|-------------|
| table | Snapshot with path, type, refcount, revision, watched, name, group, and tags. |

**Example**

```lua
do
    local handle = lurek.asset.load("Cargo.toml", "toml", { name = "cargo-example" })
    local info = lurek.asset.resolve(handle)
    local label = info.name .. ":" .. info.type
    lurek.log.info("[asset] resolved " .. label)
    lurek.asset.unload(handle)
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
    local handle = lurek.asset.load("assets/fonts/bitmap_fonts.json", "json")
    local before = lurek.asset.getGroup(handle)
    lurek.asset.setGroup(handle, "level_1")
    local grouped = lurek.asset.findByGroup("level_1")
    lurek.log.info("asset group " .. before .. " -> " .. lurek.asset.getGroup(handle) .. " matches=" .. #grouped)
    lurek.asset.unload(handle)
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
    local handle = lurek.asset.load("assets/fonts/bitmap_fonts.json", "json")
    local before = lurek.asset.getName(handle)
    lurek.asset.setName(handle, "font_atlas")
    local named = lurek.asset.findByName("font")
    lurek.log.info("asset name " .. before .. " -> " .. lurek.asset.getName(handle) .. " matches=" .. #named)
    lurek.asset.unload(handle)
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
    lurek.asset.load("content/examples/assets/data/sample_config.toml", "toml", { group = "data" })
    lurek.asset.load("content/examples/assets/shaders/sample_shader.wgsl", "shader", { group = "gfx" })
    local stats = lurek.asset.stats()
    lurek.log.info("asset stats loaded=" .. stats.loaded .. " groups=" .. #stats.groups .. " refs=" .. stats.total_refs)
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
    local handle = lurek.asset.load("content/examples/assets/data/sample_hello.txt", "text")
    local before = lurek.asset.isLoaded(handle)
    lurek.asset.unload(handle)
    local after = lurek.asset.isLoaded(handle)
    local refs = lurek.asset.refcount(handle)
    lurek.log.info("unload changed loaded=" .. tostring(before) .. " to " .. tostring(after) .. " refs=" .. refs)
end
```

---

### `lurek.asset.watch`

Marks an asset handle or path as watched for live reload.

```lua
lurek.asset.watch(handle_or_path, asset_type)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle_or_path` | [LAssetHandle](#lassethandle)|string | Existing handle or path to register as watched. |
| `asset_type?` | string | Type used when `handle_or_path` is a path. Defaults to `unknown`. |

**Returns**

| Type | Description |
|------|-------------|
| [LAssetHandle](#lassethandle) | Watched handle. |

**Example**

```lua
do
    local handle = lurek.asset.load("Cargo.toml", "toml")
    local watched = lurek.asset.watch(handle)
    local info = lurek.asset.resolve(watched)
    lurek.log.info("[asset] watched=" .. tostring(info.watched))
    lurek.asset.unload(handle)
end
```

---

## Module Fields

*No module-level fields documented.*

## Callback Parameters

- `lurek.asset.onReload` param `callback` (`function`): Called as `callback(handle, revision)`.

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
    local handle = lurek.asset.load("content/examples/assets/data/sample_hello.txt", "text")
    local type_name = handle:type()
    local same_type = handle:typeOf(type_name)
    local loaded = lurek.asset.isLoaded(handle)
    lurek.log.info("asset handle type=" .. type_name .. " same=" .. tostring(same_type) .. " loaded=" .. tostring(loaded))
    lurek.asset.unload(handle)
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
    local handle = lurek.asset.load("content/examples/assets/data/sample_hello.txt", "text")
    local is_handle = handle:typeOf("LAssetHandle")
    local is_other = handle:typeOf("other")
    local type_name = handle:type()
    lurek.log.info("asset typeOf handle=" .. tostring(is_handle) .. " other=" .. tostring(is_other) .. " type=" .. type_name)
    lurek.asset.unload(handle)
end
```

---
