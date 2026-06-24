# Tilemap

## Purpose

Supports orthogonal, isometric, and hex grids with sparse culling, LOD, and standard map imports.

## When To Use

- Its value begins with representation. The module gives projects a stable way to describe tile space itself, including orthogonal, isometric, hex-based, layered, large, and chunked interpretations, so different grid styles can still live inside one conceptual family.
- That multi-model support matters because grid worlds are not all alike. A tactics map, an isometric action world, a hex strategy board, and a layered platforming scene all have different adjacency, transform, and draw-order assumptions, yet they still need shared tooling.
- Storage and indexing are only the foundation. Practical tile worlds also require import pipelines, coordinate conversion, tile queries, rendering rules, overlays, and metadata, while traversal semantics live in systems that consume shared data.

## Minimal Example

Example block: `lurek.tilemap.newTileMap`

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    example_print_log("type = " .. map:type())
    local tw, th = map:getTileDimensions()
    local chunk_size = map:getChunkSize()
    example_print_log("tile size = " .. tw .. "x" .. th)
    example_print_log("chunk size = " .. chunk_size)
end
```

## Common Patterns

- Start with `lurek.tilemap.fromLDtk` when exploring this module.
- Start with `lurek.tilemap.fromProvider` when exploring this module.
- Start with `lurek.tilemap.fromScreenHex` when exploring this module.
- Start with `lurek.tilemap.fromScreenIso` when exploring this module.
- Start with `lurek.tilemap.getAutoTileFormats` when exploring this module.

## API Reference

- This page is the generated API reference for this module.

## Summary

- The `tilemap` module is the engine's runtime tile-grid storage and presentation bridge for users who want tile-based spaces to be authored, generated, imported, indexed, and submitted to rendering through one reusable storage model.
- Its value begins with representation. The module gives projects a stable way to describe tile space itself, including orthogonal, isometric, hex-based, layered, large, and chunked interpretations, so different grid styles can still live inside one conceptual family.
- That multi-model support matters because grid worlds are not all alike. A tactics map, an isometric action world, a hex strategy board, and a layered platforming scene all have different adjacency, transform, and draw-order assumptions, yet they still need shared tooling.
- Storage and indexing are only the foundation. Practical tile worlds also require import pipelines, coordinate conversion, tile queries, rendering rules, overlays, and metadata, while traversal semantics live in systems that consume shared data.
- Import support for formats such as TMX or LDtk makes the module useful in authored-content workflows, while generation helpers and block-based assembly support keep it relevant for procedural or hybrid worlds built at runtime.
- Autotiling is also a major user-facing capability because it lets projects derive coherent visual transitions from simpler authored data instead of manually placing every terrain variant.
- Coordinate helpers are central because tile worlds constantly move between grid cells, world positions, screen projections, isometric transforms, hex neighbors, and chunk-local indices, and those conversions must stay consistent.
- Movement blockers, line-of-sight blockers, tile-light blockers, ranges, action masks, and fog are not inferred by `tilemap`; projects materialize those semantics into `tilefield` and run `pathfind`, `awareness`, and `tilelight` independently.
- Isometric and hex support deserve special emphasis because those spaces bring their own neighbor rules, movement assumptions, vertical ordering concerns, and projection logic that should not feel bolted onto a rectangular grid core.
- Large-map and chunk-aware rendering support keep the system practical at scale, where naive whole-map processing would be too expensive or too inflexible.
- Polygon overlays, named regions, and related metadata helpers describe authored areas over the same map, but trigger/event policy stays in Lua or specialized gameplay systems.
- The module is also a bridge between authored content and runtime systems. Maps loaded from external tools, generated chunks, and script-applied overlays can all resolve into one consistent tile-space authority.
- That consistency matters because neighboring modules frequently depend on the exact same tile coordinates for different reasons: `render` needs projection payloads, `pathfind` needs traversability from `tilefield`, and gameplay logic may need regions or author refs.
- It also gives projects a stable place to express tile ids, tile metadata links, adjacency helpers, and region structure without mixing in per-system gameplay state.
- Chunk-aware storage matters beyond performance, because streaming, tooling, and large-world editing all depend on a shared notion of how the map is partitioned.
- That makes `tilemap` useful for drawing terrain and organizing visual tile space, while shared gameplay interpretation is stored in `tilefield`.
- The feature therefore serves as storage and presentation integration: it holds tile IDs and tile-space metadata well enough for the rest of the engine to build on top of it.
- That authority lets authored maps, generated chunks, and runtime overlays remain compatible.
- `pathfind`, `tilelight`, `awareness`, minimap helpers, physics scripts, raycaster, and `render` all consume tile-space in specialized ways, but `tilemap` owns the visual tile grid and coordinate model.
- Read `tilemap` as the engine's authority for visual tilemap storage and tile-world coordinate structure.

This module primarily collaborates with `color`, `image`, `math`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Functions

### `lurek.tilemap.fromLDtk`

Loads a tilemap from an LDtk JSON string, optionally targeting a specific level.

```lua
lurek.tilemap.fromLDtk(jsonStr, levelName, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `jsonStr` | string | Raw LDtk JSON content. |
| `levelName?` | string | Level name to load, or nil for the first level. |
| `opts?` | any | Optional limits table used to bound imported layer size, chunk allocation, and decoded input bytes. |

**Returns**

| Type | Description |
|------|-------------|
| [LTileMap](#ltilemap) | Loaded tilemap; or nil when import fails. |
| LTilemapFromLDtkResult | Structured import error table on import failure; or nil on success. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ldtkJson = '{"levels":[{"identifier":"Level_0","layerInstances":[]}]}'
    local map, err = lurek.tilemap.fromLDtk(ldtkJson)
    if map then
        example_print_log("LDtk map type = " .. map:type())
    else
        local err_tbl = err or {}
        local code = err_tbl["code"] or "unknown"
        local message = err_tbl["message"] or "unknown"
        example_print_log("LDtk import error: " .. code .. " - " .. message)
    end
    local named, named_err = lurek.tilemap.fromLDtk(ldtkJson, "Level_0")
    if named then
        example_print_log("named level loaded")
    else
        local err_tbl = named_err or {}
        local code = err_tbl["code"] or "unknown"
        example_print_log("named level import error: " .. code)
    end
end
```

---

### `lurek.tilemap.fromProvider`

Builds a native tilemap from a Lua provider table with tileWidth, tileHeight, layers, optional tilesets, and optional getTile(layer,x,y).

```lua
lurek.tilemap.fromProvider(provider, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `provider` | table | Lua-authored tilemap provider. |
| `opts?` | table | Optional limits table. |

**Returns**

| Type | Description |
|------|-------------|
| [LTileMap](#ltilemap) | New tilemap copied from provider data. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilemap.example] " .. tostring(message))
    end
    local provider = { tileWidth = 16, tileHeight = 16, layers = { { name = "ground", width = 2, height = 2, tiles = { 1, 2, 3, 4 } } } }
    local ok, value = pcall(function()
        local tm = lurek.tilemap.fromProvider(provider)
        return tm:getLayerCount()
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

### `lurek.tilemap.fromScreenHex`

Converts screen-space pixel coordinates to axial hex coordinates.

```lua
lurek.tilemap.fromScreenHex(sx, sy, size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | number | Screen X. |
| `sy` | number | Screen Y. |
| `size` | number | Hex cell size in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| number | Axial Q. |
| number | Axial R. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local hx, hy = lurek.tilemap.fromScreenHex(80, 40, 32)
    local sx, sy = lurek.tilemap.toScreenHex(hx, hy, 32)
    example_print_log("hex_x=" .. hx .. " hex_y=" .. hy)
    example_print_log("back_to_screen=" .. sx .. "," .. sy)
end
```

---

### `lurek.tilemap.fromScreenIso`

Converts screen-space coordinates back to tile coordinates for isometric projection.

```lua
lurek.tilemap.fromScreenIso(sx, sy, tw, th)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | number | Screen X. |
| `sy` | number | Screen Y. |
| `tw` | number | Tile width in pixels. |
| `th` | number | Tile height in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| number | Tile X. |
| number | Tile Y. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ix, iy = lurek.tilemap.fromScreenIso(128, 64, 32, 16)
    local sx, sy = lurek.tilemap.toScreenIso(ix, iy, 32, 16)
    example_print_log("iso_x=" .. ix .. " iso_y=" .. iy)
    example_print_log("back_to_screen=" .. sx .. "," .. sy)
end
```

---

### `lurek.tilemap.getAutoTileFormats`

Returns the supported auto-tile sheet layouts and their default matching modes.

```lua
lurek.tilemap.getAutoTileFormats()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of `{ name, tileCount, mode }` entries. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local formats = lurek.tilemap.getAutoTileFormats()
    for _, format in ipairs(formats) do
        if format.name == "rpgmaker48" or format.name == "minimal16" then
            example_print_log(format.name .. " tiles=" .. format.tileCount .. " mode=" .. format.mode)
        end
    end
end
```

---

### `lurek.tilemap.loadTMX`

Parses a TMX (Tiled XML) string and returns a table describing the map structure.

```lua
lurek.tilemap.loadTMX(xml, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `xml` | string | Raw TMX XML content. |
| `opts?` | any | Optional import policy table (`strictLayerSize`, `allowExternalTilesets`, `safePaths`, `assetRoot`) plus byte/size limits. |

**Returns**

| Type | Description |
|------|-------------|
| LTilemapLoadTMXResult | Parsed map with `width`; `height`; `tileWidth`; `tileHeight`; `orientation`; and `layers`; or nil on parse failure. |
| LTilemapLoadTMXResult | Structured import error table on parse failure; or nil on success. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tmxData = [[<?xml version="1.0" encoding="UTF-8"?> <map version="1.10" orientation="orthogonal" width="4" height="4" tilewidth="32" tileheight="32"> <layer name="ground" width="4" height="4"> <data encoding="csv">1,1,1,1,1,2,2,1,1,2,2,1,1,1,1,1</data> </layer> </map>]]
    local result, err = lurek.tilemap.loadTMX(tmxData)
    if result then
        example_print_log("TMX width = " .. result.width)
        example_print_log("TMX height = " .. result.height)
        example_print_log("TMX tile size = " .. result.tileWidth .. "x" .. result.tileHeight)
        example_print_log("TMX orientation = " .. result.orientation)
        example_print_log("TMX layers = " .. #result.layers)
    else
        local err_tbl = err or {}
        local code = err_tbl["code"] or "unknown"
        local message = err_tbl["message"] or "unknown"
        example_print_log("TMX import error: " .. code .. " - " .. message)
    end
end
```

---

### `lurek.tilemap.newAutoTileSheet`

Creates an auto-tile sheet with a given tile size and layout.

```lua
lurek.tilemap.newAutoTileSheet(tileW, tileH, layout)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tileW` | number | Tile width in pixels. |
| `tileH` | number | Tile height in pixels. |
| `layout` | string | Layout type: `"blob47"`, `"composite48"`, `"rpgmaker48"`, or `"minimal16"`. |

**Returns**

| Type | Description |
|------|-------------|
| [LAutoTileSheet](#lautotilesheet) | New auto-tile sheet. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local blob = lurek.tilemap.newAutoTileSheet(16, 16, "blob47")
    example_print_log("blob47 layout = " .. blob:getLayout())
    example_print_log("blob47 tile count = " .. blob:getTileCount())
    example_print_log("blob47 tile size = " .. blob:getTileWidth() .. "x" .. blob:getTileHeight())
    local minimal = lurek.tilemap.newAutoTileSheet(16, 16, "minimal16")
    example_print_log("minimal16 tile count = " .. minimal:getTileCount())
    local rpg = lurek.tilemap.newAutoTileSheet(16, 16, "rpgmaker48")
    example_print_log("rpgmaker48 mode = " .. rpg:getDefaultMode())
end
```

---

### `lurek.tilemap.newChunkMap`

Creates a new infinite chunk-based tile map.

```lua
lurek.tilemap.newChunkMap(chunkSize, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `chunkSize?` | number | Tiles per chunk side (default 16). |
| `opts?` | any | Optional limits table (`maxChunkCells`, `maxChunks`, `maxTileOperationCells`, and related tilemap ceilings). |

**Returns**

| Type | Description |
|------|-------------|
| [LChunkMap](#lchunkmap) | New chunk map. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LChunkMap
    local cm = lurek.tilemap.newChunkMap(16)
    example_print_log("type = " .. cm:type())
    example_print_log("chunk size = " .. cm:getChunkSize())
    example_print_log("loaded chunks = " .. #cm:getLoadedChunks())
    example_print_log("typeOf chunk map = " .. tostring(cm:typeOf("LChunkMap")))
end
```

---

### `lurek.tilemap.newIsoMap`

Creates a new isometric map with the given dimensions and tile geometry.

```lua
lurek.tilemap.newIsoMap(width, height, tileW, tileH, levelHeight, partCount)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Map width in tiles. |
| `height` | number | Map height in tiles. |
| `tileW` | number | Tile width in pixels. |
| `tileH` | number | Tile height in pixels. |
| `levelHeight` | number | Vertical pixel offset between levels. |
| `partCount?` | number | Number of tile parts per cell (default 4). |

**Returns**

| Type | Description |
|------|-------------|
| [LIsoMap](#lisomap) | New isometric map. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local iso = lurek.tilemap.newIsoMap(20, 20, 64, 32, 16)
    example_print_log("type = " .. iso:type())
    example_print_log("size = " .. iso:getWidth() .. "x" .. iso:getHeight())
    example_print_log("tile size = " .. iso:getTileWidth() .. "x" .. iso:getTileHeight())
    example_print_log("level height = " .. iso:getLevelHeight())
end
```

---

### `lurek.tilemap.newLargeMapRenderer`

Creates a chunk-based large-map renderer for efficient rendering of very large maps.

```lua
lurek.tilemap.newLargeMapRenderer(tileW, tileH)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tileW` | number | Tile width in pixels. |
| `tileH` | number | Tile height in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| [LLargeMapRenderer](#llargemaprenderer) | New large-map renderer. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LLargeMapRenderer
    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    example_print_log("type = " .. lmr:type())
    example_print_log("chunk size = " .. lmr:getChunkSize())
    example_print_log("tileset columns = " .. lmr:getTilesetColumns())
    example_print_log("typeOf renderer = " .. tostring(lmr:typeOf("LLargeMapRenderer")))
end
```

---

### `lurek.tilemap.newTileMap`

Creates a new empty tilemap with the given tile dimensions.

```lua
lurek.tilemap.newTileMap(tileWidth, tileHeight, chunkSize, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tileWidth` | number | Tile width in pixels. |
| `tileHeight` | number | Tile height in pixels. |
| `chunkSize?` | number | Internal chunk size in tiles (default 16). |
| `opts?` | any | Optional limits table (`maxLayers`, `maxTiles`, `maxImportBytes`, `maxDecodedBytes`, `maxChunkCells`, `maxChunks`, `maxTileOperationCells`). |

**Returns**

| Type | Description |
|------|-------------|
| [LTileMap](#ltilemap) | New tilemap. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    example_print_log("type = " .. map:type())
    local tw, th = map:getTileDimensions()
    local chunk_size = map:getChunkSize()
    example_print_log("tile size = " .. tw .. "x" .. th)
    example_print_log("chunk size = " .. chunk_size)
end
```

---

### `lurek.tilemap.newTileSet`

Compatibility alias for `lurek.tileset.newTileSet`.

```lua
lurek.tilemap.newTileSet()
```

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 64, 8, 32, 32)
    example_print_log("type = " .. ts:type())
    example_print_log("first gid = " .. ts:getFirstGid())
    example_print_log("tile count = " .. ts:getTileCount())
    example_print_log("columns = " .. ts:getColumns())
end
```

---

### `lurek.tilemap.toScreenHex`

Converts axial hex coordinates to screen-space pixel position.

```lua
lurek.tilemap.toScreenHex(q, r, size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `q` | number | Axial Q coordinate. |
| `r` | number | Axial R coordinate. |
| `size` | number | Hex cell size in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| number | Screen X. |
| number | Screen Y. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sx, sy = lurek.tilemap.toScreenHex(2, 3, 32)
    local q, r = lurek.tilemap.fromScreenHex(sx, sy, 32)
    example_print_log("hex(2,3) -> screen(" .. sx .. ", " .. sy .. ")")
    example_print_log("round trip -> hex(" .. q .. "," .. r .. ")")
end
```

---

### `lurek.tilemap.toScreenIso`

Converts tile coordinates to screen-space position for isometric projection.

```lua
lurek.tilemap.toScreenIso(tx, ty, tw, th)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tx` | number | Tile X. |
| `ty` | number | Tile Y. |
| `tw` | number | Tile width in pixels. |
| `th` | number | Tile height in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| number | Screen X. |
| number | Screen Y. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sx, sy = lurek.tilemap.toScreenIso(3, 5, 64, 32)
    local tx, ty = lurek.tilemap.fromScreenIso(sx, sy, 64, 32)
    example_print_log("tile(3,5) -> screen(" .. sx .. ", " .. sy .. ")")
    example_print_log("round trip -> tile(" .. tx .. "," .. ty .. ")")
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LAutoTileSheet](#lautotilesheet)
- [LChunkMap](#lchunkmap)
- [LIsoMap](#lisomap)
- [LLargeMapRenderer](#llargemaprenderer)
- [LTileMap](#ltilemap)

## LAutoTileSheet

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LAutoTileSheet:applyToTileSet`

Writes the auto-tile bitmask-to-tile rules from this sheet into a tileset.

```lua
LAutoTileSheet:applyToTileSet(tileSet, typeName, startGid)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tileSet` | [LTileSet](tileset.md#ltileset) | Target tileset to receive the rules. |
| `typeName` | string | Logical tile type name to register under. |
| `startGid?` | number | Optional first GID offset. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "blob47")
    local ts = lurek.tilemap.newTileSet(1, 64, 8, 16, 16)

    sheet:applyToTileSet(ts, "terrain")
    local id = ts:getAutoTileId("terrain", 5)
    example_print_log("after apply, bitmask 5 -> tile " .. tostring(id))

    sheet:applyToTileSet(ts, "water", 17)
    id = ts:getAutoTileId("water", 0)
    example_print_log("water bitmask 0 -> tile " .. tostring(id))
end
```

---

#### `LAutoTileSheet:getBitmaskForTile`

Returns the bitmask associated with a tile in this auto-tile sheet.

```lua
LAutoTileSheet:getBitmaskForTile(tileId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tileId` | number | Tile ID (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| number | Bitmask value, or nil if not found. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LAutoTileSheet
    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "minimal16")
    local bitmask = sheet:getBitmaskForTile(3)
    local tile = sheet:getTileForBitmask(bitmask)
    example_print_log("tile 3 has bitmask = " .. bitmask)
    example_print_log("bitmask " .. bitmask .. " resolves to tile " .. tile)
end
```

---

#### `LAutoTileSheet:getDefaultMode`

Returns the default neighbor matching mode for this auto-tile sheet layout.

```lua
LAutoTileSheet:getDefaultMode()
```

**Returns**

| Type | Description |
|------|-------------|
| string | One of `"matchSides"` or `"matchCornersAndSides"`. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sides = lurek.tilemap.newAutoTileSheet(16, 16, "minimal16")
    local rpg = lurek.tilemap.newAutoTileSheet(16, 16, "rpgmaker48")
    local sides_mode = sides:getDefaultMode()
    local rpg_mode = rpg:getDefaultMode()
    example_print_log("minimal16 mode:", sides_mode)
    example_print_log("rpgmaker48 mode:", rpg_mode)
end
```

---

#### `LAutoTileSheet:getLayout`

Returns the auto-tile layout type as a string.

```lua
LAutoTileSheet:getLayout()
```

**Returns**

| Type | Description |
|------|-------------|
| string | One of `"blob47"`, `"composite48"`, `"rpgmaker48"`, `"minimal16"`. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "blob47")
    local layout = sheet:getLayout()
    local count = sheet:getTileCount()
    example_print_log("layout:", layout)
    example_print_log("tileCount:", count)
    example_print_log("tileWidth:", sheet:getTileWidth())
end
```

---

#### `LAutoTileSheet:getQuad`

Returns the source rectangle for a tile in the auto-tile sheet.

```lua
LAutoTileSheet:getQuad(tileId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tileId` | number | Tile ID (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| number | X offset in pixels. |
| number | Y offset in pixels. |
| number | Width in pixels. |
| number | Height in pixels. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LAutoTileSheet
    local sheet = lurek.tilemap.newAutoTileSheet(32, 32, "composite48")
    example_print_log("composite48 count = " .. sheet:getTileCount())
    example_print_log("composite48 layout = " .. sheet:getLayout())
    local x, y, w, h = sheet:getQuad(1)
    example_print_log("quad 1: x=" .. x .. " y=" .. y .. " w=" .. w .. " h=" .. h)
end
```

---

#### `LAutoTileSheet:getTileCount`

Returns the total number of tiles in this auto-tile sheet.

```lua
LAutoTileSheet:getTileCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Tile count. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "blob47")
    local count = sheet:getTileCount()
    local layout = sheet:getLayout()
    example_print_log("tileCount:", count)
    example_print_log("layout:", layout)
    example_print_log("tileHeight:", sheet:getTileHeight())
end
```

---

#### `LAutoTileSheet:getTileForBitmask`

Looks up which tile corresponds to a given bitmask value.

```lua
LAutoTileSheet:getTileForBitmask(bitmask)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bitmask` | number | Bitmask to resolve. |

**Returns**

| Type | Description |
|------|-------------|
| number | Tile ID (1-based), or nil if no tile matches. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LAutoTileSheet
    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "minimal16")
    local tile = sheet:getTileForBitmask(7)
    local bitmask = sheet:getBitmaskForTile(tile)
    example_print_log("bitmask 7 -> tile " .. tile)
    example_print_log("tile " .. tile .. " back to bitmask " .. bitmask)
end
```

---

#### `LAutoTileSheet:getTileHeight`

Returns the height of each tile in the auto-tile sheet, in pixels.

```lua
LAutoTileSheet:getTileHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Tile height. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "blob47")
    local h = sheet:getTileHeight()
    local w = sheet:getTileWidth()
    example_print_log("tileHeight:", h)
    example_print_log("tileWidth:", w)
    example_print_log("layout:", sheet:getLayout())
end
```

---

#### `LAutoTileSheet:getTileWidth`

Returns the width of each tile in the auto-tile sheet, in pixels.

```lua
LAutoTileSheet:getTileWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Tile width. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sheet = lurek.tilemap.newAutoTileSheet(32, 32, "minimal16")
    local w = sheet:getTileWidth()
    local h = sheet:getTileHeight()
    example_print_log("tileWidth:", w)
    example_print_log("tileHeight:", h)
    example_print_log("tileCount:", sheet:getTileCount())
end
```

---

#### `LAutoTileSheet:type`

Returns the type name of this userdata.

```lua
LAutoTileSheet:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always `"[LAutoTileSheet](#lautotilesheet)"`. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sheet = lurek.tilemap.newAutoTileSheet(32, 32, "minimal16")
    local t = sheet:type()
    local layout = sheet:getLayout()
    example_print_log("type:", t)
    example_print_log("layout:", layout)
    example_print_log("tileCount:", sheet:getTileCount())
end
```

---

#### `LAutoTileSheet:typeOf`

Checks whether this object matches the given type name.

```lua
LAutoTileSheet:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check against. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if `name` is `"[LAutoTileSheet](#lautotilesheet)"` or `"Object"`. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sheet = lurek.tilemap.newAutoTileSheet(32, 32, "minimal16")
    local ok = sheet:typeOf("LAutoTileSheet")
    local as_object = sheet:typeOf("LObject")
    example_print_log("typeOf:", ok)
    example_print_log("typeOfObject:", as_object)
    example_print_log("layout:", sheet:getLayout())
end
```

---

## LChunkMap

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LChunkMap:chunkTileRange`

Returns the tile-coordinate range covered by a specific chunk.

```lua
LChunkMap:chunkTileRange(cx, cy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | number | Chunk X coordinate. |
| `cy` | number | Chunk Y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Minimum tile X. |
| number | Minimum tile Y. |
| number | Maximum tile X. |
| number | Maximum tile Y. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cm = lurek.tilemap.newChunkMap(16)
    local minX, minY, maxX, maxY = cm:chunkTileRange(2, 3)
    example_print_log("chunk (2,3) covers tiles:")
    example_print_log("  min = " .. minX .. ", " .. minY)
    example_print_log("  max = " .. maxX .. ", " .. maxY)
end
```

---

#### `LChunkMap:clearTile`

Removes the tile at the given world-tile coordinate.

```lua
LChunkMap:clearTile(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Tile X coordinate. |
| `y` | number | Tile Y coordinate. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cm = lurek.tilemap.newChunkMap(16)
    cm:setTile(10, 20, 5)
    cm:clearTile(10, 20)
    local gid = cm:getTile(10, 20)
    example_print_log("after clear = " .. gid)
end
```

---

#### `LChunkMap:fillRect`

Fills a rectangular region of tiles with a given GID.

```lua
LChunkMap:fillRect(x0, y0, x1, y1, gid)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x0` | number | Left tile coordinate. |
| `y0` | number | Top tile coordinate. |
| `x1` | number | Right tile coordinate (inclusive). |
| `y1` | number | Bottom tile coordinate (inclusive). |
| `gid` | number | Global tile ID to fill with. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cm = lurek.tilemap.newChunkMap(16)
    cm:fillRect(0, 0, 10, 10, 3)
    example_print_log("filled 11x11 area with gid=3")
    example_print_log("sample (5,5) = " .. cm:getTile(5, 5))
    example_print_log("sample (11,11) = " .. cm:getTile(11, 11))
end
```

---

#### `LChunkMap:getChunkSize`

Returns the size of each chunk in tiles per side.

```lua
LChunkMap:getChunkSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Chunk size. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cm = lurek.tilemap.newChunkMap(32)
    local sz = cm:getChunkSize()
    local loaded = cm:getLoadedChunks()
    example_print_log("chunkSize:", sz)
    example_print_log("loadedChunks:", #loaded)
end
```

---

#### `LChunkMap:getChunksInView`

Returns chunk coordinates that overlap a viewport region, given tile dimensions.

```lua
LChunkMap:getChunksInView(vx, vy, vw, vh, tw, th)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `vx` | number | Viewport left edge in world pixels. |
| `vy` | number | Viewport top edge in world pixels. |
| `vw` | number | Viewport width in pixels. |
| `vh` | number | Viewport height in pixels. |
| `tw` | number | Tile width in pixels. |
| `th` | number | Tile height in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| LChunkMapGetChunksInViewResult | Array of `{cx, cy}` pairs. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function chunkCoords(cell)
        return cell.cx or cell[1], cell.cy or cell[2]
    end

    local cm = lurek.tilemap.newChunkMap(16)
    local visible = cm:getChunksInView(0, 0, 800, 600, 32, 32)
    example_print_log("visible chunks in 800x600 viewport: " .. #visible)
    for i = 1, math.min(3, #visible) do
        local cx, cy = chunkCoords(visible[i])
        example_print_log("  chunk (" .. cx .. ", " .. cy .. ")")
    end
end
```

---

#### `LChunkMap:getLoadedChunks`

Returns a list of all currently loaded chunk coordinates.

```lua
LChunkMap:getLoadedChunks()
```

**Returns**

| Type | Description |
|------|-------------|
| LChunkMapGetLoadedChunksResult | Array of `{cx, cy}` pairs. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function chunkCoords(cell)
        return cell.cx or cell[1], cell.cy or cell[2]
    end

    local cm = lurek.tilemap.newChunkMap(16) ; cm:loadChunk(0, 0)
    cm:loadChunk(1, 0) ; cm:loadChunk(0, 1)
    local loaded = cm:getLoadedChunks()
    example_print_log("loaded chunks = " .. #loaded)
    for _, c in ipairs(loaded) do
        local cx, cy = chunkCoords(c)
        example_print_log("  chunk (" .. cx .. ", " .. cy .. ")")
    end
end
```

---

#### `LChunkMap:getTile`

Returns the tile GID at the given world-tile coordinate.

```lua
LChunkMap:getTile(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Tile X coordinate. |
| `y` | number | Tile Y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Global tile ID. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LChunkMap
    local cm = lurek.tilemap.newChunkMap(16)
    cm:setTile(10, 20, 5)
    local gid = cm:getTile(10, 20)
    local x0, y0, x1, y1 = cm:chunkTileRange(0, 1)
    example_print_log("tile at 10,20 = " .. gid)
    example_print_log("chunk range = (" .. x0 .. "," .. y0 .. ")-(" .. x1 .. "," .. y1 .. ")")
end
```

---

#### `LChunkMap:loadChunk`

Loads a chunk into memory at the given chunk coordinates.

```lua
LChunkMap:loadChunk(cx, cy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | number | Chunk X coordinate. |
| `cy` | number | Chunk Y coordinate. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function chunkCoords(cell)
        return cell.cx or cell[1], cell.cy or cell[2]
    end

    local cm = lurek.tilemap.newChunkMap(16)
    cm:loadChunk(0, 0)
    local loaded = cm:getLoadedChunks()
    example_print_log("loaded chunks = " .. #loaded)
    for _, c in ipairs(loaded) do
        local cx, cy = chunkCoords(c)
        example_print_log("  chunk (" .. cx .. ", " .. cy .. ")")
    end
end
```

---

#### `LChunkMap:setTile`

Sets the tile GID at the given world-tile coordinate.

```lua
LChunkMap:setTile(x, y, gid)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Tile X coordinate. |
| `y` | number | Tile Y coordinate. |
| `gid` | number | Global tile ID to place. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LChunkMap
    local cm = lurek.tilemap.newChunkMap(16)
    cm:setTile(10, 20, 5)
    local gid = cm:getTile(10, 20)
    local loaded = cm:getLoadedChunks()
    example_print_log("tile at 10,20 = " .. gid)
    example_print_log("loaded chunks after write = " .. #loaded)
end
```

---

#### `LChunkMap:type`

Returns the type name of this userdata.

```lua
LChunkMap:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always `"[LChunkMap](#lchunkmap)"`. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cm = lurek.tilemap.newChunkMap(32)
    local t = cm:type()
    local sz = cm:getChunkSize()
    example_print_log("type:", t)
    example_print_log("chunkSize:", sz)
    example_print_log("loadedChunks:", #cm:getLoadedChunks())
end
```

---

#### `LChunkMap:typeOf`

Checks whether this object matches the given type name.

```lua
LChunkMap:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check against. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if `name` is `"[LChunkMap](#lchunkmap)"` or `"Object"`. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cm = lurek.tilemap.newChunkMap(32)
    local ok = cm:typeOf("LChunkMap")
    local as_object = cm:typeOf("LObject")
    example_print_log("typeOf:", ok)
    example_print_log("typeOfObject:", as_object)
    example_print_log("chunkSize:", cm:getChunkSize())
end
```

---

#### `LChunkMap:unloadChunk`

Unloads a chunk from memory at the given chunk coordinates.

```lua
LChunkMap:unloadChunk(cx, cy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | number | Chunk X coordinate. |
| `cy` | number | Chunk Y coordinate. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cm = lurek.tilemap.newChunkMap(16) ; cm:loadChunk(0, 0)
    cm:loadChunk(1, 0)
    cm:unloadChunk(1, 0)
    local loaded = cm:getLoadedChunks()
    example_print_log("after unload = " .. #loaded .. " chunks")
end
```

---

## LIsoMap

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LIsoMap:addLevel`

Adds a new vertical level to the isometric map and returns its index.

```lua
LIsoMap:addLevel()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Index of the new level (1-based). |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    local lvl = iso:addLevel()
    local second = iso:addLevel()
    example_print_log("added level, count = " .. iso:getLevelCount())
    example_print_log("first level index = " .. lvl)
    example_print_log("second level index = " .. second)
end
```

---

#### `LIsoMap:fillLevel`

Fills all tiles on a level for a given part with a single GID.

```lua
LIsoMap:fillLevel(z, part, gid)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `z` | number | Level index (1-based). |
| `part` | number | Part index to fill. |
| `gid` | number | Global tile ID to fill with. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(8, 8, 64, 32, 16)
    iso:addLevel()
    iso:fillLevel(1, 1, 3)
    local gid = iso:getTilePart(1, 2, 2, 1)
    example_print_log("filled level 1, part 1 with gid=3")
    example_print_log("sample tile part = " .. gid)
end
```

---

#### `LIsoMap:getHeight`

Returns the map height in tiles. This method is available to Lua scripts.

```lua
LIsoMap:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Height. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local iso = lurek.tilemap.newIsoMap(20, 15, 64, 32, 16, 4)
    local h = iso:getHeight()
    local w = iso:getWidth()
    example_print_log("isomap height:", h)
    example_print_log("isomap width:", w)
end
```

---

#### `LIsoMap:getLevelCount`

Returns the number of vertical levels in the isometric map.

```lua
LIsoMap:getLevelCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Level count. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    local lvl = iso:addLevel()
    iso:addLevel()
    example_print_log("added level, count = " .. iso:getLevelCount())
    example_print_log("first level index = " .. lvl)
end
```

---

#### `LIsoMap:getLevelHeight`

Returns the vertical pixel offset between levels.

```lua
LIsoMap:getLevelHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Level height in pixels. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local iso = lurek.tilemap.newIsoMap(20, 15, 64, 32, 16, 4)
    local lh = iso:getLevelHeight()
    local parts = iso:getPartCount()
    example_print_log("levelHeight:", lh)
    example_print_log("partCount:", parts)
end
```

---

#### `LIsoMap:getPartCount`

Returns the number of tile parts per cell.

```lua
LIsoMap:getPartCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Part count. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local iso = lurek.tilemap.newIsoMap(20, 15, 64, 32, 16, 4)
    local pc = iso:getPartCount()
    local lh = iso:getLevelHeight()
    example_print_log("partCount:", pc)
    example_print_log("levelHeight:", lh)
end
```

---

#### `LIsoMap:getPartOrder`

Returns the rendering order of tile parts as an array of part indices.

```lua
LIsoMap:getPartOrder()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Part index values. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local iso = lurek.tilemap.newIsoMap(5, 5, 64, 32, 16, 4) ; local order = iso:getPartOrder()
    example_print_log("default part order: " .. #order .. " entries")
    iso:setPartOrder({ 3, 2, 1, 0 })
    order = iso:getPartOrder()
    example_print_log("reversed order[1] = " .. order[1])
end
```

---

#### `LIsoMap:getTileHeight`

Returns the height of an isometric tile in pixels.

```lua
LIsoMap:getTileHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Tile height. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    local th = iso:getTileHeight()
    local tw = iso:getTileWidth()
    example_print_log("tileHeight:", th)
    example_print_log("tileWidth:", tw)
end
```

---

#### `LIsoMap:getTilePart`

Returns the GID for a specific part of a tile at a given position and level.

```lua
LIsoMap:getTilePart(z, x, y, part)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `z` | number | Level index (1-based). |
| `x` | number | Column (1-based). |
| `y` | number | Row (1-based). |
| `part` | number | Part index. |

**Returns**

| Type | Description |
|------|-------------|
| number | Global tile ID. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    iso:addLevel()
    iso:setTilePart(1, 3, 4, 1, 5)
    local gid = iso:getTilePart(1, 3, 4, 1)
    example_print_log("tile part at (1,3,4,part=1) = " .. gid)
end
```

---

#### `LIsoMap:getTileWidth`

Returns the width of an isometric tile in pixels.

```lua
LIsoMap:getTileWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Tile width. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    local tw = iso:getTileWidth()
    local th = iso:getTileHeight()
    example_print_log("tileWidth:", tw)
    example_print_log("tileHeight:", th)
end
```

---

#### `LIsoMap:getWidth`

Returns the map width in tiles. This method is available to Lua scripts.

```lua
LIsoMap:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    local w = iso:getWidth()
    local h = iso:getHeight()
    example_print_log("width:", w)
    example_print_log("height:", h)
end
```

---

#### `LIsoMap:isLevelVisible`

Returns whether a vertical level is currently visible.

```lua
LIsoMap:isLevelVisible(z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `z` | number | Level index (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the level is visible. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(8, 8, 64, 32, 16)
    iso:addLevel()
    local before = iso:isLevelVisible(1)
    iso:setLevelVisible(1, false)
    example_print_log("level 1 visible = " .. tostring(iso:isLevelVisible(1)))
    example_print_log("default visible = " .. tostring(before))
    example_print_log("after hide = " .. tostring(iso:isLevelVisible(1)))
end
```

---

#### `LIsoMap:screenToTile`

Converts screen-space pixel coordinates to tile-grid coordinates (ignoring Z).

```lua
LIsoMap:screenToTile(sx, sy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | number | Screen X. |
| `sy` | number | Screen Y. |

**Returns**

| Type | Description |
|------|-------------|
| number | Tile X. |
| number | Tile Y. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16)
    iso:setOrigin(400, 100)
    local sx, sy = iso:tileToScreen(3, 2, 1)
    local tx, ty = iso:screenToTile(sx, sy)
    example_print_log("screen -> tile(" .. tx .. ", " .. ty .. ")")
end
```

---

#### `LIsoMap:setLevelVisible`

Sets whether a vertical level is drawn during rendering.

```lua
LIsoMap:setLevelVisible(z, visible)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `z` | number | Level index (1-based). |
| `visible` | boolean | True to show, false to hide. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(8, 8, 64, 32, 16)
    iso:addLevel()
    iso:setLevelVisible(1, false)
    local hidden = iso:isLevelVisible(1)
    example_print_log("after hide = " .. tostring(iso:isLevelVisible(1)))
    iso:setLevelVisible(1, true)
    example_print_log("hidden flag = " .. tostring(hidden))
    example_print_log("after show = " .. tostring(iso:isLevelVisible(1)))
end
```

---

#### `LIsoMap:setOrigin`

Sets the screen-space origin (top-left anchor) for isometric rendering.

```lua
LIsoMap:setOrigin(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Origin X in pixels. |
| `y` | number | Origin Y in pixels. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16)
    iso:setOrigin(400, 100)
    local sx, sy = iso:tileToScreen(1, 1, 1)
    example_print_log("origin set")
    example_print_log("tile(1,1,1) screen anchor = " .. sx .. "," .. sy)
end
```

---

#### `LIsoMap:setPartOrder`

Overrides the rendering order of tile parts.

```lua
LIsoMap:setPartOrder(order)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `order` | table | Array of part indices in desired draw order. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(5, 5, 64, 32, 16, 4)
    iso:setPartOrder({ 3, 2, 1, 0 })
    local order = iso:getPartOrder()
    local parts = iso:getPartCount()
    example_print_log("reversed order[1] = " .. order[1])
    example_print_log("part count = " .. parts)
end
```

---

#### `LIsoMap:setTilePart`

Sets the GID for a specific part of a tile at a given position and level.

```lua
LIsoMap:setTilePart(z, x, y, part, gid)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `z` | number | Level index (1-based). |
| `x` | number | Column (1-based). |
| `y` | number | Row (1-based). |
| `part` | number | Part index (e.g. floor, wall, object). |
| `gid` | number | Global tile ID to place. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    iso:addLevel()
    iso:setTilePart(1, 3, 4, 1, 5)
    local gid = iso:getTilePart(1, 3, 4, 1)
    example_print_log("tile part at (1,3,4,part=1) = " .. gid)
end
```

---

#### `LIsoMap:tileToScreen`

Converts tile-grid coordinates to screen-space pixel position.

```lua
LIsoMap:tileToScreen(tx, ty, tz)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tx` | number | Tile X. |
| `ty` | number | Tile Y. |
| `tz` | number | Tile Z (level). |

**Returns**

| Type | Description |
|------|-------------|
| number | Screen X. |
| number | Screen Y. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LIsoMap
    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16)
    iso:setOrigin(400, 100)
    local sx, sy = iso:tileToScreen(3, 2, 1)
    local tx, ty = iso:screenToTile(sx, sy)
    example_print_log("tile(3,2,z=1) -> screen(" .. sx .. ", " .. sy .. ")")
    example_print_log("round trip -> tile(" .. tx .. "," .. ty .. ")")
end
```

---

#### `LIsoMap:type`

Returns the type name of this userdata.

```lua
LIsoMap:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always `"[LIsoMap](#lisomap)"`. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local iso = lurek.tilemap.newIsoMap(8, 8, 32, 16, 8, 2)
    local t = iso:type()
    local w = iso:getWidth()
    example_print_log("type:", t)
    example_print_log("width:", w)
    example_print_log("parts:", iso:getPartCount())
end
```

---

#### `LIsoMap:typeOf`

Checks whether this object matches the given type name.

```lua
LIsoMap:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check against. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if `name` is `"[LIsoMap](#lisomap)"` or `"Object"`. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local iso = lurek.tilemap.newIsoMap(8, 8, 32, 16, 8, 2)
    local ok = iso:typeOf("LIsoMap")
    local as_object = iso:typeOf("LObject")
    example_print_log("typeOf:", ok)
    example_print_log("typeOfObject:", as_object)
    example_print_log("width:", iso:getWidth())
end
```

---

## LLargeMapRenderer

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LLargeMapRenderer:getChunkSize`

Returns the current chunk size. This method is available to Lua scripts.

```lua
LLargeMapRenderer:getChunkSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Chunk size in tiles per side. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(16, 16)
    local cs = lmr:getChunkSize()
    local cols = lmr:getTilesetColumns()
    example_print_log("chunkSize:", cs)
    example_print_log("tilesetColumns:", cols)
end
```

---

#### `LLargeMapRenderer:getMapSize`

Returns the map dimensions in tiles.

```lua
LLargeMapRenderer:getMapSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width in tiles. |
| number | Height in tiles. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function buildLargeMapData(width, height, value_mod)
        local data = {}
        for y = 1, height do
            for x = 1, width do
                data[#data + 1] = ((x + y) % value_mod) + 1
            end
        end
        return data
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    local width, height = 24, 24
    lmr:setMapData(buildLargeMapData(width, height, 4), width, height)
    local w, h = lmr:getMapSize() ; example_print_log("map size = " .. w .. "x" .. h)
    example_print_log("tile at (12,12) = " .. lmr:getTile(12, 12)) ; lmr:setTile(12, 12, 99)
    example_print_log("after set = " .. lmr:getTile(12, 12))
end
```

---

#### `LLargeMapRenderer:getTile`

Returns the tile GID at a given position.

```lua
LLargeMapRenderer:getTile(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Column. |
| `y` | number | Row. |

**Returns**

| Type | Description |
|------|-------------|
| number | Tile GID. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function buildLargeMapData(width, height, value_mod)
        local data = {}
        for y = 1, height do
            for x = 1, width do
                data[#data + 1] = ((x + y) % value_mod) + 1
            end
        end
        return data
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    local width, height = 24, 24
    lmr:setMapData(buildLargeMapData(width, height, 4), width, height)
    local w, h = lmr:getMapSize() ; example_print_log("map size = " .. w .. "x" .. h)
    example_print_log("tile at (12,12) = " .. lmr:getTile(12, 12)) ; lmr:setTile(12, 12, 99)
    example_print_log("after set = " .. lmr:getTile(12, 12))
end
```

---

#### `LLargeMapRenderer:getTilesetColumns`

Returns the tileset column count used for UV calculation.

```lua
LLargeMapRenderer:getTilesetColumns()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Column count. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(16, 16)
    local cols = lmr:getTilesetColumns()
    local chunk = lmr:getChunkSize()
    example_print_log("tilesetColumns:", cols)
    example_print_log("chunkSize:", chunk)
end
```

---

#### `LLargeMapRenderer:getTotalChunks`

Returns the total number of chunks in the map.

```lua
LLargeMapRenderer:getTotalChunks()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Total chunk count. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function buildLargeMapData(width, height, value_mod)
        local data = {}
        for y = 1, height do
            for x = 1, width do
                data[#data + 1] = ((x + y) % value_mod) + 1
            end
        end
        return data
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    local width, height = 40, 40
    lmr:setMapData(buildLargeMapData(width, height, 1), width, height)
    lmr:setViewport(800, 600) ; lmr:setCamera(640, 640, 1.0)
    example_print_log("total chunks = " .. lmr:getTotalChunks())
    example_print_log("visible chunks = " .. lmr:getVisibleChunks())
end
```

---

#### `LLargeMapRenderer:getVisibleChunks`

Returns the number of chunks currently visible in the viewport.

```lua
LLargeMapRenderer:getVisibleChunks()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Visible chunk count. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function buildLargeMapData(width, height, value_mod)
        local data = {}
        for y = 1, height do
            for x = 1, width do
                data[#data + 1] = ((x + y) % value_mod) + 1
            end
        end
        return data
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    local width, height = 40, 40
    lmr:setMapData(buildLargeMapData(width, height, 1), width, height)
    lmr:setViewport(800, 600) ; lmr:setCamera(640, 640, 1.0)
    example_print_log("total chunks = " .. lmr:getTotalChunks())
    example_print_log("visible chunks = " .. lmr:getVisibleChunks())
end
```

---

#### `LLargeMapRenderer:invalidateAll`

Marks all chunks as dirty, forcing a full rebuild on the next render.

```lua
LLargeMapRenderer:invalidateAll()
```

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32) ; lmr:setChunkSize(32)
    example_print_log("chunk size = " .. lmr:getChunkSize()) ; lmr:setTilesetColumns(16)
    example_print_log("tileset columns = " .. lmr:getTilesetColumns()) ; lmr:invalidateChunk(0, 0)
    lmr:invalidateAll()
    example_print_log("all chunks invalidated")
end
```

---

#### `LLargeMapRenderer:invalidateChunk`

Marks a specific chunk as dirty so it will be rebuilt on the next render.

```lua
LLargeMapRenderer:invalidateChunk(cx, cy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | number | Chunk X index. |
| `cy` | number | Chunk Y index. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32) ; lmr:setChunkSize(32)
    example_print_log("chunk size = " .. lmr:getChunkSize()) ; lmr:setTilesetColumns(16)
    example_print_log("tileset columns = " .. lmr:getTilesetColumns()) ; lmr:invalidateChunk(0, 0)
    lmr:invalidateAll()
    example_print_log("all chunks invalidated")
end
```

---

#### `LLargeMapRenderer:isLodEnabled`

Returns whether LOD rendering is currently enabled.

```lua
LLargeMapRenderer:isLodEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if LOD is enabled. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(16, 16) ; example_print_log("LOD enabled = " .. tostring(lmr:isLodEnabled()))
    lmr:setLodEnabled(true)
    example_print_log("after enable = " .. tostring(lmr:isLodEnabled()))
    lmr:setLodThresholds({ 0.5, 0.25, 0.1 })
    example_print_log("LOD thresholds set")
end
```

---

#### `LLargeMapRenderer:setCamera`

Sets the camera position and zoom level for determining visible chunks.

```lua
LLargeMapRenderer:setCamera(x, y, zoom)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Camera center X in world pixels. |
| `y` | number | Camera center Y in world pixels. |
| `zoom` | number | Zoom factor (1.0 = normal). |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function buildLargeMapData(width, height, value_mod)
        local data = {}
        for y = 1, height do
            for x = 1, width do
                data[#data + 1] = ((x + y) % value_mod) + 1
            end
        end
        return data
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    local width, height = 40, 40
    lmr:setMapData(buildLargeMapData(width, height, 1), width, height)
    lmr:setViewport(800, 600) ; lmr:setCamera(640, 640, 1.0)
    example_print_log("total chunks = " .. lmr:getTotalChunks())
    example_print_log("visible chunks = " .. lmr:getVisibleChunks())
end
```

---

#### `LLargeMapRenderer:setChunkSize`

Sets the chunk size used for rendering subdivision.

```lua
LLargeMapRenderer:setChunkSize(size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `size` | number | Chunk size in tiles per side. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32) ; lmr:setChunkSize(32)
    example_print_log("chunk size = " .. lmr:getChunkSize()) ; lmr:setTilesetColumns(16)
    example_print_log("tileset columns = " .. lmr:getTilesetColumns()) ; lmr:invalidateChunk(0, 0)
    lmr:invalidateAll()
    example_print_log("all chunks invalidated")
end
```

---

#### `LLargeMapRenderer:setLodEnabled`

Enables or disables level-of-detail rendering for distant chunks.

```lua
LLargeMapRenderer:setLodEnabled(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | boolean | True to enable LOD. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(16, 16) ; example_print_log("LOD enabled = " .. tostring(lmr:isLodEnabled()))
    lmr:setLodEnabled(true)
    example_print_log("after enable = " .. tostring(lmr:isLodEnabled()))
    lmr:setLodThresholds({ 0.5, 0.25, 0.1 })
    example_print_log("LOD thresholds set")
end
```

---

#### `LLargeMapRenderer:setLodThresholds`

Sets the zoom thresholds at which LOD levels change.

```lua
LLargeMapRenderer:setLodThresholds(levels)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `levels` | table | Array of zoom threshold values. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(16, 16) ; example_print_log("LOD enabled = " .. tostring(lmr:isLodEnabled()))
    lmr:setLodEnabled(true)
    example_print_log("after enable = " .. tostring(lmr:isLodEnabled()))
    lmr:setLodThresholds({ 0.5, 0.25, 0.1 })
    example_print_log("LOD thresholds set")
end
```

---

#### `LLargeMapRenderer:setMapData`

Replaces all tile data with a flat array of GIDs for the given dimensions.

```lua
LLargeMapRenderer:setMapData(data, width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | table | Flat array of tile GIDs (row-major order). |
| `width` | number | Map width in tiles. |
| `height` | number | Map height in tiles. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function buildLargeMapData(width, height, value_mod)
        local data = {}
        for y = 1, height do
            for x = 1, width do
                data[#data + 1] = ((x + y) % value_mod) + 1
            end
        end
        return data
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    local width, height = 24, 24
    lmr:setMapData(buildLargeMapData(width, height, 4), width, height)
    local w, h = lmr:getMapSize() ; example_print_log("map size = " .. w .. "x" .. h)
    example_print_log("tile at (12,12) = " .. lmr:getTile(12, 12)) ; lmr:setTile(12, 12, 99)
    example_print_log("after set = " .. lmr:getTile(12, 12))
end
```

---

#### `LLargeMapRenderer:setTile`

Sets a single tile GID at a given position.

```lua
LLargeMapRenderer:setTile(x, y, tileId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Column. |
| `y` | number | Row. |
| `tileId` | number | Tile GID to place. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function buildLargeMapData(width, height, value_mod)
        local data = {}
        for y = 1, height do
            for x = 1, width do
                data[#data + 1] = ((x + y) % value_mod) + 1
            end
        end
        return data
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    local width, height = 24, 24
    lmr:setMapData(buildLargeMapData(width, height, 4), width, height)
    local w, h = lmr:getMapSize() ; example_print_log("map size = " .. w .. "x" .. h)
    example_print_log("tile at (12,12) = " .. lmr:getTile(12, 12)) ; lmr:setTile(12, 12, 99)
    example_print_log("after set = " .. lmr:getTile(12, 12))
end
```

---

#### `LLargeMapRenderer:setTilesetColumns`

Sets the column count of the associated tileset atlas for UV calculation.

```lua
LLargeMapRenderer:setTilesetColumns(cols)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cols` | number | Number of columns in the tileset image. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32) ; lmr:setChunkSize(32)
    example_print_log("chunk size = " .. lmr:getChunkSize()) ; lmr:setTilesetColumns(16)
    example_print_log("tileset columns = " .. lmr:getTilesetColumns()) ; lmr:invalidateChunk(0, 0)
    lmr:invalidateAll()
    example_print_log("all chunks invalidated")
end
```

---

#### `LLargeMapRenderer:setViewport`

Sets the viewport rectangle used for render-command culling.

```lua
LLargeMapRenderer:setViewport(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Viewport width in pixels. |
| `h` | number | Viewport height in pixels. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local function buildLargeMapData(width, height, value_mod)
        local data = {}
        for y = 1, height do
            for x = 1, width do
                data[#data + 1] = ((x + y) % value_mod) + 1
            end
        end
        return data
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    local width, height = 40, 40
    lmr:setMapData(buildLargeMapData(width, height, 1), width, height)
    lmr:setViewport(800, 600) ; lmr:setCamera(640, 640, 1.0)
    example_print_log("total chunks = " .. lmr:getTotalChunks())
    example_print_log("visible chunks = " .. lmr:getVisibleChunks())
end
```

---

#### `LLargeMapRenderer:type`

Returns the type name of this userdata.

```lua
LLargeMapRenderer:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always `"[LLargeMapRenderer](#llargemaprenderer)"`. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(16, 16)
    local t = lmr:type()
    local chunk = lmr:getChunkSize()
    example_print_log("type:", t)
    example_print_log("chunkSize:", chunk)
    example_print_log("tilesetColumns:", lmr:getTilesetColumns())
end
```

---

#### `LLargeMapRenderer:typeOf`

Checks whether this object matches the given type name.

```lua
LLargeMapRenderer:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check against. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if `name` is `"[LLargeMapRenderer](#llargemaprenderer)"` or `"Object"`. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    local ok = lmr:typeOf("LLargeMapRenderer")
    local as_object = lmr:typeOf("LObject")
    example_print_log("typeOf:", ok)
    example_print_log("typeOfObject:", as_object)
    example_print_log("chunkSize:", lmr:getChunkSize())
end
```

---

## LTileMap

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTileMap:addLayer`

Creates a new tile layer with the given name and dimensions.

```lua
LTileMap:addLayer(name, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Layer name. |
| `w` | number | Width in tiles. |
| `h` | number | Height in tiles. |

**Returns**

| Type | Description |
|------|-------------|
| number | Index of the new layer (1-based). |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    local ground = map:addLayer("ground", 50, 50)
    local decor = map:addLayer("decor", 50, 50)
    local count = map:getLayerCount()
    example_print_log("ground layer idx = " .. ground)
    example_print_log("decor layer idx = " .. decor)
    example_print_log("layer count = " .. count)
end
```

---

#### `LTileMap:addTileSet`

Attaches a tileset to this map for tile rendering.

```lua
LTileMap:addTileSet(tileSet)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tileSet` | [LTileSet](tileset.md#ltileset) | Tileset to add. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    local terrain = lurek.tilemap.newTileSet(1, 64, 8, 32, 32)
    local objects = lurek.tilemap.newTileSet(65, 32, 8, 32, 32)

    map:addTileSet(terrain)
    map:addTileSet(objects)
    example_print_log("tileset count = " .. map:getTileSetCount())
end
```

---

#### `LTileMap:applyAutoTile`

Runs 4-bit auto-tiling on an entire layer, replacing tiles according to registered rules.

```lua
LTileMap:applyAutoTile(layer, typeName)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `typeName` | string | Tile type name whose rules to apply. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(16, 16)
    local ts = lurek.tilemap.newTileSet(1, 32, 8, 16, 16)
    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "minimal16")

    sheet:applyToTileSet(ts, "grass")
    map:addTileSet(ts)

    local layer = map:addLayer("terrain", 10, 10)
    map:fill(layer, 1)
    map:applyAutoTile(layer, "grass")

    local gid = map:getTile(layer, 5, 5)
    example_print_log("4-bit auto-tile applied")
    example_print_log("center tile after auto = " .. gid)
end
```

---

#### `LTileMap:applyAutoTile8`

Runs 8-bit auto-tiling on an entire layer, considering diagonal neighbors.

```lua
LTileMap:applyAutoTile8(layer, typeName)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `typeName` | string | Tile type name whose rules to apply. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(16, 16)
    local ts = lurek.tilemap.newTileSet(1, 256, 16, 16, 16)

    for i = 0, 255 do
        ts:setAutoTileRule8("wall", i, i + 1)
    end
    map:addTileSet(ts)

    local layer = map:addLayer("walls", 8, 8)
    map:setTile(layer, 3, 3, 1)
    map:setTile(layer, 4, 3, 1)
    map:setTile(layer, 3, 4, 1)
    map:applyAutoTile8(layer, "wall")

    example_print_log("8-bit auto-tile applied")
end
```

---

#### `LTileMap:applyAutoTile8At`

Runs 8-bit auto-tiling at a single tile position and updates it and its neighbors.

```lua
LTileMap:applyAutoTile8At(layer, x, y, typeName)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `x` | number | Column (1-based). |
| `y` | number | Row (1-based). |
| `typeName` | string | Tile type name whose rules to apply. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(16, 16)
    local ts = lurek.tilemap.newTileSet(1, 32, 8, 16, 16)
    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "minimal16")

    sheet:applyToTileSet(ts, "dirt")
    map:addTileSet(ts)

    local layer = map:addLayer("ground", 10, 10)
    map:fill(layer, 1)
    map:applyAutoTile8At(layer, 3, 3, "dirt")
    example_print_log("single cell 8-bit auto-tiled at 3,3")
end
```

---

#### `LTileMap:applyAutoTileAt`

Runs 4-bit auto-tiling at a single tile position and updates it and its neighbors.

```lua
LTileMap:applyAutoTileAt(layer, x, y, typeName)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `x` | number | Column (1-based). |
| `y` | number | Row (1-based). |
| `typeName` | string | Tile type name whose rules to apply. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(16, 16)
    local ts = lurek.tilemap.newTileSet(1, 32, 8, 16, 16)
    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "minimal16")

    sheet:applyToTileSet(ts, "dirt")
    map:addTileSet(ts)

    local layer = map:addLayer("ground", 10, 10)
    map:fill(layer, 1)
    map:applyAutoTileAt(layer, 5, 5, "dirt")
    example_print_log("single cell auto-tiled at 5,5")
end
```

---

#### `LTileMap:applyAutoTileMode`

Runs auto-tiling on an entire layer using the mode configured on the matching tileset.

```lua
LTileMap:applyAutoTileMode(layer, typeName)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `typeName` | string | Tile type name whose configured mode and rules to apply. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(16, 16)
    local ts = lurek.tilemap.newTileSet(1, 64, 8, 16, 16)
    ts:setAutoTileMode("shore", "matchCornersAndSides")
    ts:setAutoTileRule8("shore", 255, 8)
    map:addTileSet(ts)
    local layer = map:addLayer("shore", 8, 8)
    for y = 3, 5 do
        for x = 3, 5 do
            map:setTile(layer, x, y, 1)
        end
    end
    map:applyAutoTileMode(layer, "shore")
    example_print_log("configured-mode center tile = " .. map:getTile(layer, 4, 4))
end
```

---

#### `LTileMap:applyAutoTileModeAt`

Runs configured-mode auto-tiling at a single tile position and updates it and its neighbors.

```lua
LTileMap:applyAutoTileModeAt(layer, x, y, typeName)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `x` | number | Column (1-based). |
| `y` | number | Row (1-based). |
| `typeName` | string | Tile type name whose configured mode and rules to apply. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(16, 16)
    local ts = lurek.tilemap.newTileSet(1, 32, 8, 16, 16)
    ts:setAutoTileMode("corner", "matchCorners")
    ts:setAutoTileRule("corner", 15, 4)
    map:addTileSet(ts)
    local layer = map:addLayer("corner", 8, 8)
    map:setTile(layer, 4, 4, 1)
    map:setTile(layer, 3, 3, 1)
    map:setTile(layer, 5, 3, 1)
    map:setTile(layer, 3, 5, 1)
    map:setTile(layer, 5, 5, 1)
    map:applyAutoTileModeAt(layer, 4, 4, "corner")
    example_print_log("corner-mode center tile = " .. map:getTile(layer, 4, 4))
end
```

---

#### `LTileMap:clearTile`

Removes the tile at a specific grid position, setting it to empty (GID 0).

```lua
LTileMap:clearTile(layer, x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `x` | number | Column (1-based). |
| `y` | number | Row (1-based). |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("main", 10, 10)
    map:setTile(layer, 3, 4, 5)
    map:clearTile(layer, 3, 4)
    local gid = map:getTile(layer, 3, 4)
    example_print_log("after clear = " .. gid)
end
```

---

#### `LTileMap:fill`

Fills every cell of a layer with the given GID.

```lua
LTileMap:fill(layer, gid)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `gid` | number | Global tile ID to fill with. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("ground", 20, 20)
    map:fill(layer, 3)
    example_print_log("fill complete, sample = " .. map:getTile(layer, 10, 10))
    example_print_log("corner = " .. map:getTile(layer, 1, 1))
end
```

---

#### `LTileMap:findTilesByGid`

Returns all positions on a layer that contain a specific GID.

```lua
LTileMap:findTilesByGid(layer, gid)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `gid` | number | Global tile ID to search for. |

**Returns**

| Type | Description |
|------|-------------|
| LTileMapFindTilesByGidResult | Array of `{x=number, y=number}` positions. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("main", 10, 10)

    map:setTile(layer, 2, 3, 7)
    map:setTile(layer, 5, 1, 7)
    map:setTile(layer, 8, 9, 7)
    map:setTile(layer, 4, 4, 2)

    local positions = map:findTilesByGid(layer, 7)
    example_print_log("found gid=7 count = " .. #positions)
    for _, pos in ipairs(positions) do
        example_print_log("  x=" .. pos.x .. " y=" .. pos.y)
    end
end
```

---

#### `LTileMap:getChunkSize`

Returns the chunk size used for internal tile storage.

```lua
LTileMap:getChunkSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Chunk size in tiles per side. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local cs = tm:getChunkSize()
    local tw, th = tm:getTileDimensions()
    example_print_log("chunk_size=" .. cs)
    example_print_log("tile_dims=" .. tw .. "x" .. th)
end
```

---

#### `LTileMap:getDiagnostics`

Returns tilemap diagnostics counters for invalid calls, unknown gids, and lazy index rebuilds.

```lua
LTileMap:getDiagnostics()
```

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("main", 10, 10)
    map:trySetTile(layer, 11, 1, 7)
    map:tryGetTile(2, 1, 1)
    local diagnostics = map:getDiagnostics()
    example_print_log("invalid layer = " .. tostring(diagnostics.invalidLayer))
    example_print_log("invalid coord = " .. tostring(diagnostics.invalidCoord))
end
```

---

#### `LTileMap:getLayerColor`

Returns the tint color of a layer as four RGBA components.

```lua
LTileMap:getLayerColor(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Layer index (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| number | Red (0..1). |
| number | Green (0..1). |
| number | Blue (0..1). |
| number | Alpha (0..1). |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("tinted", 10, 10)
    map:setLayerColor(1, 0.8, 0.5, 0.5, 0.9)
    local r, g, b, a = map:getLayerColor(1)
    example_print_log("layer color = " .. r .. ", " .. g .. ", " .. b .. ", " .. a)
end
```

---

#### `LTileMap:getLayerCount`

Returns the total number of layers in this map.

```lua
LTileMap:getLayerCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Layer count. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("terrain", 40, 30)
    map:addLayer("props", 40, 30)
    local second = map:getLayerName(2)
    example_print_log("layer count = " .. map:getLayerCount())
    example_print_log("second layer = " .. second)
end
```

---

#### `LTileMap:getLayerName`

Returns the name of a layer by index.

```lua
LTileMap:getLayerName(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Layer index (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| string | Layer name, or nil if index is out of range. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("terrain", 40, 30)
    map:addLayer("props", 40, 30)
    local second_name = map:getLayerName(2)
    example_print_log("layer 1 = " .. map:getLayerName(1))
    example_print_log("layer 2 = " .. second_name)
end
```

---

#### `LTileMap:getLayerOffset`

Returns the pixel offset of a layer.

```lua
LTileMap:getLayerOffset(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Layer index (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| number | Horizontal offset. |
| number | Vertical offset. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("shifted", 10, 10)
    map:setLayerOffset(1, 16, 8)
    local ox, oy = map:getLayerOffset(1)
    example_print_log("offset = " .. ox .. ", " .. oy)
end
```

---

#### `LTileMap:getLayerParallax`

Returns the parallax scroll factor of a layer.

```lua
LTileMap:getLayerParallax(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Layer index (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| number | Horizontal parallax factor. |
| number | Vertical parallax factor. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("background", 40, 30)
    map:setLayerParallax(1, 0.5, 0.5)
    local px, py = map:getLayerParallax(1)
    example_print_log("bg parallax = " .. px .. ", " .. py)
end
```

---

#### `LTileMap:getLayerVisible`

Returns whether a layer is currently visible.

```lua
LTileMap:getLayerVisible(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Layer index (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the layer is visible. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("background", 20, 20)
    local before = map:getLayerVisible(1)
    map:setLayerVisible(1, false)
    example_print_log("layer 1 visible = " .. tostring(map:getLayerVisible(1)))
    example_print_log("default visible = " .. tostring(before))
    example_print_log("after hide = " .. tostring(map:getLayerVisible(1)))
end
```

---

#### `LTileMap:getOrientation`

Returns the current map orientation as a string.

```lua
LTileMap:getOrientation()
```

**Returns**

| Type | Description |
|------|-------------|
| string | One of `"topdown"`, `"sideview"`, `"isometric"`, `"hexagonal"`. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("main", 10, 10)
    local before = map:getOrientation()
    map:setOrientation("hexagonal")
    example_print_log("default orientation = " .. map:getOrientation())
    example_print_log("initial orientation = " .. before)
    example_print_log("hex orientation = " .. map:getOrientation())
end
```

---

#### `LTileMap:getTile`

Returns the tile GID at a specific grid position on a layer.

```lua
LTileMap:getTile(layer, x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `x` | number | Column (1-based). |
| `y` | number | Row (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| number | Global tile ID at that position. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("main", 10, 10)
    map:setTile(layer, 3, 4, 5)
    local gid = map:getTile(layer, 3, 4)
    example_print_log("tile at 3,4 = " .. gid)
end
```

---

#### `LTileMap:getTileDimensions`

Returns both tile width and height in pixels.

```lua
LTileMap:getTileDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Tile width. |
| number | Tile height. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local tw, th = tm:getTileDimensions()
    local chunk = tm:getChunkSize()
    example_print_log("tile_w=" .. tw .. " tile_h=" .. th)
    example_print_log("chunk_size=" .. chunk)
end
```

---

#### `LTileMap:getTileHeight`

Returns the height of a single tile in pixels for this map.

```lua
LTileMap:getTileHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Tile height in pixels. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local th2 = tm:getTileHeight()
    local tw2 = tm:getTileWidth()
    example_print_log("tile_height=" .. th2)
    example_print_log("tile_width=" .. tw2)
end
```

---

#### `LTileMap:getTileSet`

Returns the tileset at the given index.

```lua
LTileMap:getTileSet(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Tileset index (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| [LTileSet](tileset.md#ltileset) | The tileset, or nil if index is out of range. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    local terrain = lurek.tilemap.newTileSet(1, 64, 8, 32, 32)
    local objects = lurek.tilemap.newTileSet(65, 32, 8, 32, 32)

    map:addTileSet(terrain)
    map:addTileSet(objects)
    local ts1 = map:getTileSet(1)
    example_print_log("tileset 1 first gid = " .. ts1:getFirstGid())
end
```

---

#### `LTileMap:getTileSetCount`

Returns how many tilesets are attached to this map.

```lua
LTileMap:getTileSetCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Tileset count. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    local terrain = lurek.tilemap.newTileSet(1, 64, 8, 32, 32)
    local objects = lurek.tilemap.newTileSet(65, 32, 8, 32, 32)

    map:addTileSet(terrain)
    map:addTileSet(objects)
    example_print_log("tileset count = " .. map:getTileSetCount())
end
```

---

#### `LTileMap:getTileWidth`

Returns the width of a single tile in pixels for this map.

```lua
LTileMap:getTileWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Tile width in pixels. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local tw2 = tm:getTileWidth()
    local th2 = tm:getTileHeight()
    example_print_log("tile_width=" .. tw2)
    example_print_log("tile_height=" .. th2)
end
```

---

#### `LTileMap:getViewport`

Returns the current viewport rectangle, or nils if none is set.

```lua
LTileMap:getViewport()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Left edge. |
| number | Top edge. |
| number | Width. |
| number | Height. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("ground", 100, 100)
    map:setViewport(0, 0, 800, 600)
    local vx, vy, vw, vh = map:getViewport()
    example_print_log("viewport = " .. vx .. "," .. vy .. " " .. vw .. "x" .. vh)
end
```

---

#### `LTileMap:render`

Submits render commands for all visible tiles, optionally offset by a scroll position.

```lua
LTileMap:render(ox, oy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ox?` | number | Horizontal scroll offset (default 0). |
| `oy?` | number | Vertical scroll offset (default 0). |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("ground", 100, 100)
    map:setViewport(0, 0, 800, 600)

    map:render()
    example_print_log("rendered at origin")
    map:render(10, 10)
    example_print_log("rendered with offset")
end
```

---

#### `LTileMap:renderFieldCatalogSlot`

Renders typed refs from a tilefield slot through a tileset catalog.

```lua
LTileMap:renderFieldCatalogSlot(field, catalog, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `field` | [LTileField](tilefield.md#ltilefield)|table | Source tilefield handle or provider table containing typed slot refs. |
| `catalog` | [LTileCatalog](tileset.md#ltilecatalog) | Catalog resolving `{tileset,tile/object}` refs to visuals. |
| `opts` | table | Options: slot, z, offsetX, offsetY. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilemap.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 2, height = 2 })
    field:setRef(1, 1, 1, "terrain", { tileset = "terrain", object = "grass" })
    local catalog = lurek.tileset.newCatalog({ terrain = lurek.tileset.newTileSet(1, 4, 2, 16, 16) })
    local tm = lurek.tilemap.newTileMap(16, 16)
    local ok, value = pcall(function()
        return tm:renderFieldCatalogSlot(field, catalog, { slot = "terrain", z = 1 })
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileMap:renderFieldSlot`

Renders objects referenced from a tilefield slot using tileset object visuals.

```lua
LTileMap:renderFieldSlot(field, tileset, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `field` | [LTileField](tilefield.md#ltilefield)|table | Source tilefield handle or provider table containing slot refs. |
| `tileset` | [LTileSet](tileset.md#ltileset)|table | Tileset handle or provider table with object archetype visuals. |
| `opts` | table | Options: slot, z, offsetX, offsetY, refIsGid. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[tilemap.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 2, height = 2 })
    field:setRef(1, 1, 1, "terrain", 1)
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    local tm = lurek.tilemap.newTileMap(16, 16)
    local ok, value = pcall(function()
        return tm:renderFieldSlot(field, tileset, { slot = "terrain", z = 1, refIsGid = true })
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end
```

---

#### `LTileMap:setLayerColor`

Sets the tint color for an entire layer.

```lua
LTileMap:setLayerColor(idx, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Layer index (1-based). |
| `r` | number | Red channel (0..1). |
| `g` | number | Green channel (0..1). |
| `b` | number | Blue channel (0..1). |
| `a` | number | Alpha channel (0..1). |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("tinted", 10, 10)
    map:setLayerColor(1, 0.8, 0.5, 0.5, 0.9)
    local r, g, b, a = map:getLayerColor(1)
    example_print_log("layer color = " .. r .. ", " .. g .. ", " .. b .. ", " .. a)
end
```

---

#### `LTileMap:setLayerOffset`

Sets the pixel offset for a layer, shifting all tiles during rendering.

```lua
LTileMap:setLayerOffset(idx, ox, oy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Layer index (1-based). |
| `ox` | number | Horizontal offset in pixels. |
| `oy` | number | Vertical offset in pixels. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("shifted", 10, 10)
    map:setLayerOffset(1, 16, 8)
    local ox, oy = map:getLayerOffset(1)
    example_print_log("offset = " .. ox .. ", " .. oy)
end
```

---

#### `LTileMap:setLayerParallax`

Sets the parallax scroll factor for a layer. Values less than 1 scroll slower than the camera.

```lua
LTileMap:setLayerParallax(idx, px, py)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Layer index (1-based). |
| `px` | number | Horizontal parallax factor. |
| `py` | number | Vertical parallax factor. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("background", 40, 30)
    map:setLayerParallax(1, 0.5, 0.5)
    local px, py = map:getLayerParallax(1)
    example_print_log("bg parallax = " .. px .. ", " .. py)
end
```

---

#### `LTileMap:setLayerVisible`

Sets whether a layer is drawn during rendering.

```lua
LTileMap:setLayerVisible(idx, visible)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Layer index (1-based). |
| `visible` | boolean | True to show, false to hide. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("background", 20, 20)
    map:setLayerVisible(1, false)
    local hidden = map:getLayerVisible(1)
    example_print_log("after hide = " .. tostring(map:getLayerVisible(1)))
    map:setLayerVisible(1, true)
    example_print_log("hidden flag = " .. tostring(hidden))
    example_print_log("after show = " .. tostring(map:getLayerVisible(1)))
end
```

---

#### `LTileMap:setOrientation`

Sets the map orientation, affecting coordinate transforms and rendering.

```lua
LTileMap:setOrientation(orientation)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `orientation` | string | One of `"topdown"`, `"sideview"`, `"isometric"`, `"hexagonal"`. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("main", 10, 10)
    map:setOrientation("isometric")
    local wx, wy = map:tileToWorld(3, 2)
    example_print_log("set to " .. map:getOrientation())
    example_print_log("tile(3,2) projects near world(" .. wx .. "," .. wy .. ")")
end
```

---

#### `LTileMap:setTile`

Sets the tile GID at a specific grid position on a layer.

```lua
LTileMap:setTile(layer, x, y, gid)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `x` | number | Column (1-based). |
| `y` | number | Row (1-based). |
| `gid` | number | Global tile ID to place. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("main", 10, 10)
    map:setTile(layer, 3, 4, 5)
    local gid = map:getTile(layer, 3, 4)
    example_print_log("tile at 3,4 = " .. gid)
end
```

---

#### `LTileMap:setTileTint`

Overrides the color tint for a single tile at a given position.

```lua
LTileMap:setTileTint(layer, x, y, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `x` | number | Column (1-based). |
| `y` | number | Row (1-based). |
| `r` | number | Red channel (0..1). |
| `g` | number | Green channel (0..1). |
| `b` | number | Blue channel (0..1). |
| `a` | number | Alpha channel (0..1). |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("tinted", 10, 10)

    map:setTile(layer, 1, 1, 1)
    map:setTile(layer, 2, 1, 1)
    map:setTile(layer, 3, 1, 1)
    map:setTileTint(layer, 1, 1, 1.0, 0.0, 0.0, 1.0)
    map:setTileTint(layer, 2, 1, 0.0, 1.0, 0.0, 1.0)
    map:setTileTint(layer, 3, 1, 0.0, 0.0, 1.0, 1.0)
    example_print_log("RGB tints applied to 3 tiles")
end
```

---

#### `LTileMap:setViewport`

Sets the visible area of the map for culling during rendering.

```lua
LTileMap:setViewport(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Left edge in world pixels. |
| `y` | number | Top edge in world pixels. |
| `w` | number | Viewport width in pixels. |
| `h` | number | Viewport height in pixels. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("ground", 100, 100)
    map:setViewport(0, 0, 800, 600)
    local vx, vy, vw, vh = map:getViewport()
    example_print_log("viewport = " .. vx .. "," .. vy .. " " .. vw .. "x" .. vh)
end
```

---

#### `LTileMap:tileToWorld`

Converts tile-grid coordinates to world-space pixel coordinates (top-left corner of the tile).

```lua
LTileMap:tileToWorld(tx, ty)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tx` | number | Tile column (1-based). |
| `ty` | number | Tile row (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| number | World X position in pixels. |
| number | World Y position in pixels. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("main", 20, 20)
    local wx, wy = map:tileToWorld(5, 3)
    local tx, ty = map:worldToTile(wx, wy)
    example_print_log("tile(5,3) -> world(" .. wx .. "," .. wy .. ")")
    example_print_log("round trip -> tile(" .. tx .. "," .. ty .. ")")
end
```

---

#### `LTileMap:tileTypeIndex`

Builds an index mapping each GID present on a layer to an array of `{x, y}` positions.

```lua
LTileMap:tileTypeIndex(layer)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| LTileMapTileTypeIndexResult | Table keyed by GID, each value an array of `{x=number, y=number}`. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("terrain", 5, 5)

    map:setTile(layer, 1, 1, 1)
    map:setTile(layer, 2, 1, 1)
    map:setTile(layer, 3, 1, 2)
    map:setTile(layer, 4, 1, 3)

    local index = map:tileTypeIndex(layer)
    example_print_log("tile type index built")
    for gid, positions in pairs(index) do
        example_print_log("  gid " .. gid .. " has " .. #positions .. " tiles")
    end
end
```

---

#### `LTileMap:tryAddLayer`

Creates a new tile layer and returns `nil, error` instead of throwing on invalid dimensions or layer limits.

```lua
LTileMap:tryAddLayer(name, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Layer name. |
| `w` | number | Width in tiles. |
| `h` | number | Height in tiles. |

**Returns**

| Type | Description |
|------|-------------|
| number | Index of the new layer (1-based). |
| string | Error message when validation fails. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32, 8, { maxLayers = 1 })
    local first, first_err = map:tryAddLayer("ground", 2, 2)
    local second, second_err = map:tryAddLayer("props", 2, 2)
    example_print_log("tryAddLayer first = " .. tostring(first) .. " err = " .. tostring(first_err))
    example_print_log("tryAddLayer second = " .. tostring(second) .. " err = " .. tostring(second_err))
end
```

---

#### `LTileMap:tryGetTile`

Returns the tile GID at a specific grid position, or `nil, error` when the layer or coord is invalid.

```lua
LTileMap:tryGetTile(layer, x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `x` | number | Column (1-based). |
| `y` | number | Row (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| number | Global tile ID at that position. |
| string | Error message on failure. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("main", 10, 10)
    local gid, err = map:tryGetTile(2, 1, 1)
    example_print_log("tryGetTile gid = " .. tostring(gid))
    example_print_log("tryGetTile err = " .. tostring(err))
end
```

---

#### `LTileMap:trySetTile`

Sets a tile and returns `false, error` instead of throwing on invalid layer or coordinate input.

```lua
LTileMap:trySetTile(layer, x, y, gid)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `x` | number | Column (1-based). |
| `y` | number | Row (1-based). |
| `gid` | number | Global tile ID to place. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True on success. |
| string | Error message on failure. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("main", 10, 10)
    local ok, err = map:trySetTile(layer, 11, 1, 7)
    example_print_log("trySetTile ok = " .. tostring(ok))
    example_print_log("trySetTile err = " .. tostring(err))
end
```

---

#### `LTileMap:trySetTileTint`

Sets a per-cell tint override and returns `false, error` instead of throwing on invalid input.

```lua
LTileMap:trySetTileTint(layer, x, y, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `x` | number | Column (1-based). |
| `y` | number | Row (1-based). |
| `r` | number | Red tint channel. |
| `g` | number | Green tint channel. |
| `b` | number | Blue tint channel. |
| `a` | number | Alpha tint channel. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True on success. |
| string | Error message on failure. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("tinted", 10, 10)
    map:setTile(layer, 1, 1, 1)
    local ok, err = map:trySetTileTint(layer, 1, 1, 1.0, 0.0, 0.0, 1.0)
    example_print_log("trySetTileTint ok = " .. tostring(ok))
    example_print_log("trySetTileTint err = " .. tostring(err))
end
```

---

#### `LTileMap:tryWorldToTile`

Converts world-space pixel coordinates to tile-grid coordinates, returning nils for negative or non-finite input.

```lua
LTileMap:tryWorldToTile(wx, wy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `wx` | number | World X position in pixels. |
| `wy` | number | World Y position in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| number | Tile column (1-based). |
| number | Tile row (1-based). |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("main", 20, 20)
    local tx, ty = map:tryWorldToTile(64, 32)
    local bad_tx, bad_ty = map:tryWorldToTile(-1, 0)
    example_print_log("tryWorldToTile valid = " .. tostring(tx) .. "," .. tostring(ty))
    example_print_log("tryWorldToTile invalid = " .. tostring(bad_tx) .. "," .. tostring(bad_ty))
end
```

---

#### `LTileMap:type`

Returns the type name of this userdata.

```lua
LTileMap:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always `"[LTileMap](#ltilemap)"`. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local tw, th = tm:getTileDimensions()
    example_print_log("type=" .. tm:type())
    example_print_log("tile_dims=" .. tw .. "x" .. th)
    example_print_log("chunk_size=" .. tm:getChunkSize())
end
```

---

#### `LTileMap:typeOf`

Checks whether this object matches the given type name.

```lua
LTileMap:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check against. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if `name` is `"[LTileMap](#ltilemap)"` or `"Object"`. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local is_map = tm:typeOf("LTileMap")
    local is_object = tm:typeOf("LObject")
    example_print_log("typeOf=" .. tostring(tm:typeOf("LTileMap")))
    example_print_log("as_map=" .. tostring(is_map))
    example_print_log("as_object=" .. tostring(is_object))
end
```

---

#### `LTileMap:update`

Advances tile animations by the given delta time.

```lua
LTileMap:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Time elapsed in seconds since last update. |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("animated", 10, 10)

    local dt = 1 / 60
    map:update(dt)
    map:update(dt)
    map:update(dt)
    example_print_log("updated 3 frames at 60fps")
end
```

---

#### `LTileMap:worldToTile`

Converts world-space pixel coordinates to tile-grid coordinates.

```lua
LTileMap:worldToTile(wx, wy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `wx` | number | World X position in pixels. |
| `wy` | number | World Y position in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| number | Tile column (1-based). |
| number | Tile row (1-based). |

**Example**

```lua
do
    local function tilemap_log(message)
        lurek.log.info("[tilemap] " .. message)
    end
    local tilemap_log_count = 0
    local tilemap_log_limit = 96
    local function example_print_log(...)
        tilemap_log_count = tilemap_log_count + 1
        if tilemap_log_count > tilemap_log_limit then
            return
        end
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        tilemap_log(table.concat(parts, " "))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    ---@type LTileMap
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("main", 20, 20)
    local tx, ty = map:worldToTile(100, 80)
    local wx, wy = map:tileToWorld(tx, ty)
    example_print_log("world(100,80) -> tile(" .. tx .. "," .. ty .. ")")
    example_print_log("tile(" .. tx .. "," .. ty .. ") -> world(" .. wx .. "," .. wy .. ")")
end
```

---
