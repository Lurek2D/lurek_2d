# Tilemap

## Purpose

Supports orthogonal, isometric, and hex grids with sparse culling, LOD, and standard map imports.

## When To Use

- Its value begins with representation. The module gives projects a stable way to describe tile space itself, including orthogonal, isometric, hex-based, layered, large, and chunked interpretations, so different grid styles can still live inside one conceptual family.
- That multi-model support matters because grid worlds are not all alike. A tactics map, an isometric action world, a hex strategy board, and a layered platforming scene all have different adjacency, transform, and draw-order assumptions, yet they still need shared tooling.
- Storage and indexing are only the foundation. Practical tile worlds also require import pipelines, coordinate conversion, tile queries, collision helpers, rendering rules, overlays, metadata, and traversal semantics, and this module keeps those concerns together.

## Minimal Example

Example block: `lurek.tilemap.newTileMap`

```lua
do
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
- Start with `lurek.tilemap.fromScreenHex` when exploring this module.
- Start with `lurek.tilemap.fromScreenIso` when exploring this module.
- Start with `lurek.tilemap.getAutoTileFormats` when exploring this module.
- Start with `lurek.tilemap.hexArea` when exploring this module.

## API Reference

- This page is the generated API reference for this module.

## Summary

- The `tilemap` module is the engine's full grid-world framework for users who want tile-based spaces to be authored, generated, rendered, queried, and traversed through one reusable system rather than through several disconnected helpers.
- Its value begins with representation. The module gives projects a stable way to describe tile space itself, including orthogonal, isometric, hex-based, layered, large, and chunked interpretations, so different grid styles can still live inside one conceptual family.
- That multi-model support matters because grid worlds are not all alike. A tactics map, an isometric action world, a hex strategy board, and a layered platforming scene all have different adjacency, transform, and draw-order assumptions, yet they still need shared tooling.
- Storage and indexing are only the foundation. Practical tile worlds also require import pipelines, coordinate conversion, tile queries, collision helpers, rendering rules, overlays, metadata, and traversal semantics, and this module keeps those concerns together.
- Import support for formats such as TMX or LDtk makes the module useful in authored-content workflows, while generation helpers and block-based assembly support keep it relevant for procedural or hybrid worlds built at runtime.
- Autotiling is also a major user-facing capability because it lets projects derive coherent visual transitions from simpler authored data instead of manually placing every terrain variant.
- Coordinate helpers are central because tile worlds constantly move between grid cells, world positions, screen projections, isometric transforms, hex neighbors, and chunk-local indices, and those conversions must stay consistent.
- Collision and sweep-style queries are a major practical feature. A tile world should be directly searchable for blocked cells, traversable neighbors, hits, ranges, or occupancy questions without escalating every problem into full rigid-body simulation.
- Isometric and hex support deserve special emphasis because those spaces bring their own neighbor rules, movement assumptions, vertical ordering concerns, and projection logic that should not feel bolted onto a rectangular grid core.
- Large-map and chunk-aware rendering support keep the system practical at scale, where naive whole-map processing would be too expensive or too inflexible.
- Polygon overlays, named regions, and related metadata helpers extend the feature from geometry into gameplay space by letting designers describe areas, triggers, provinces, and semantic regions layered over the same map.
- The module is also a bridge between authored content and runtime systems. Maps loaded from external tools, generated chunks, and script-applied overlays can all resolve into one consistent tile-space authority.
- That consistency matters because neighboring modules frequently depend on the exact same tile coordinates for different reasons: pathfinding needs traversability, render needs projection, and gameplay logic needs regions, triggers, or occupancy.
- It also gives projects a stable place to express tile metadata, adjacency, and region semantics without scattering that meaning across several helper layers.
- Chunk-aware storage matters beyond performance, because streaming, tooling, and large-world editing all depend on a shared notion of how the map is partitioned.
- That makes `tilemap` useful not only for drawing terrain, but also for organizing the world model that several other modules stand on.
- The feature therefore serves as both storage and interpretation: it does not merely hold tile IDs, it defines what tile-space means well enough for the rest of the engine to build on top of it.
- That authority lets authored maps, generated chunks, and runtime overlays remain compatible.
- `pathfind`, `physics`, `raycaster`, and `render` all consume tile-space in specialized ways, but `tilemap` owns what the grid world fundamentally is.
- Read `tilemap` as the engine's main authority for tile space and tile-world structure.

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
    local hx, hy = lurek.tilemap.fromScreenHex(80, 40, 32)
    local sx, sy = lurek.tilemap.toScreenHex(hx, hy, 32)
    local dist = lurek.tilemap.hexDistance(hx, hy, hx, hy)
    example_print_log("hex_x=" .. hx .. " hex_y=" .. hy)
    example_print_log("back_to_screen=" .. sx .. "," .. sy)
    example_print_log("self_distance=" .. dist)
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
    local ix, iy = lurek.tilemap.fromScreenIso(128, 64, 32, 16)
    local sx, sy = lurek.tilemap.toScreenIso(ix, iy, 32, 16)
    local dir = lurek.tilemap.isoDirectionFromAngle(0)
    example_print_log("iso_x=" .. ix .. " iso_y=" .. iy)
    example_print_log("back_to_screen=" .. sx .. "," .. sy)
    example_print_log("default_dir=" .. dir)
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
    local formats = lurek.tilemap.getAutoTileFormats()
    for _, format in ipairs(formats) do
        if format.name == "rpgmaker48" or format.name == "minimal16" then
            example_print_log(format.name .. " tiles=" .. format.tileCount .. " mode=" .. format.mode)
        end
    end
end
```

---

### `lurek.tilemap.hexArea`

Returns all hex cells within a filled area of a given radius.

```lua
lurek.tilemap.hexArea(q, r, radius)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `q` | number | Center Q. |
| `r` | number | Center R. |
| `radius` | number | Area radius. |

**Returns**

| Type | Description |
|------|-------------|
| LTilemapHexAreaResult | Array of `{q, r}` pairs inside the area. |

**Example**

```lua
do
    local area = lurek.tilemap.hexArea(0, 0, 1)
    example_print_log("area radius 1: " .. #area .. " cells")
    local bigArea = lurek.tilemap.hexArea(5, 5, 3)
    local ring = lurek.tilemap.hexRing(5, 5, 3)
    example_print_log("area radius 3 around (5,5): " .. #bigArea .. " cells")
    example_print_log("matching outer ring cells = " .. #ring)
end
```

---

### `lurek.tilemap.hexDistance`

Computes the hex grid distance between two axial coordinates.

```lua
lurek.tilemap.hexDistance(q1, r1, q2, r2)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `q1` | number | First Q. |
| `r1` | number | First R. |
| `q2` | number | Second Q. |
| `r2` | number | Second R. |

**Returns**

| Type | Description |
|------|-------------|
| number | Distance in hex steps. |

**Example**

```lua
do
    local d = lurek.tilemap.hexDistance(0, 0, 3, 2)
    example_print_log("hex distance (0,0) to (3,2) = " .. d)
    d = lurek.tilemap.hexDistance(1, 1, 1, 1)
    example_print_log("same cell distance = " .. d)
    d = lurek.tilemap.hexDistance(-2, 1, 2, -1)
    example_print_log("across-origin distance = " .. d)
end
```

---

### `lurek.tilemap.hexLine`

Returns all hex cells along a line between two axial coordinates.

```lua
lurek.tilemap.hexLine(q1, r1, q2, r2)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `q1` | number | Start Q. |
| `r1` | number | Start R. |
| `q2` | number | End Q. |
| `r2` | number | End R. |

**Returns**

| Type | Description |
|------|-------------|
| LTilemapHexLineResult | Array of `{q, r}` pairs along the line. |

**Example**

```lua
do
    local function hexCoords(cell)
        return cell.q or cell[1], cell.r or cell[2]
    end

    local line = lurek.tilemap.hexLine(0, 0, 4, 2)
    example_print_log("line (0,0) to (4,2): " .. #line .. " cells")
    for i, cell in ipairs(line) do
        local q, r = hexCoords(cell)
        example_print_log("  step " .. i .. ": q=" .. q .. " r=" .. r)
    end
end
```

---

### `lurek.tilemap.hexNeighbors`

Returns the six neighboring hex cells of a given axial coordinate.

```lua
lurek.tilemap.hexNeighbors(q, r)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `q` | number | Axial Q. |
| `r` | number | Axial R. |

**Returns**

| Type | Description |
|------|-------------|
| LTilemapHexNeighborsResult | Array of `{q=number, r=number}` neighbor cells. |

**Example**

```lua
do
    local function hexCoords(cell)
        return cell.q or cell[1], cell.r or cell[2]
    end

    local neighbors = lurek.tilemap.hexNeighbors(3, 4)
    example_print_log("neighbors of (3,4): " .. #neighbors .. " cells")
    for i, n in ipairs(neighbors) do
        local q, r = hexCoords(n)
        example_print_log("  " .. i .. ": q=" .. q .. " r=" .. r)
    end
end
```

---

### `lurek.tilemap.hexReflect`

Reflects a hex cell across an axis through a center point.

```lua
lurek.tilemap.hexReflect(q, r, centerQ, centerR, axis)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `q` | number | Cell Q. |
| `r` | number | Cell R. |
| `centerQ` | number | Pivot Q. |
| `centerR` | number | Pivot R. |
| `axis` | string | Reflection axis name. |

**Returns**

| Type | Description |
|------|-------------|
| number | Reflected Q. |
| number | Reflected R. |

**Example**

```lua
do
    local q, r = lurek.tilemap.hexReflect(3, 1, 0, 0, "q")
    example_print_log("reflect (3,1) across q axis = " .. q .. ", " .. r)
    q, r = lurek.tilemap.hexReflect(2, -1, 0, 0, "r")
    local dist = lurek.tilemap.hexDistance(0, 0, q, r)
    example_print_log("reflect (2,-1) across r axis = " .. q .. ", " .. r)
    example_print_log("reflected point distance from origin = " .. dist)
end
```

---

### `lurek.tilemap.hexRing`

Returns all hex cells forming a ring at a given radius around a center.

```lua
lurek.tilemap.hexRing(q, r, radius)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `q` | number | Center Q. |
| `r` | number | Center R. |
| `radius` | number | Ring radius in hex steps. |

**Returns**

| Type | Description |
|------|-------------|
| LTilemapHexRingResult | Array of `{q, r}` pairs on the ring. |

**Example**

```lua
do
    local function hexCoords(cell)
        return cell.q or cell[1], cell.r or cell[2]
    end

    local ring = lurek.tilemap.hexRing(0, 0, 2)
    example_print_log("ring at radius 2: " .. #ring .. " cells")
    for _, cell in ipairs(ring) do
        local q, r = hexCoords(cell)
        example_print_log("  q=" .. q .. " r=" .. r)
    end
end
```

---

### `lurek.tilemap.hexRotate`

Rotates a hex cell around a center point by a number of 60-degree steps.

```lua
lurek.tilemap.hexRotate(q, r, centerQ, centerR, steps)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `q` | number | Cell Q. |
| `r` | number | Cell R. |
| `centerQ` | number | Pivot Q. |
| `centerR` | number | Pivot R. |
| `steps` | number | Number of 60-degree rotation steps (positive = clockwise). |

**Returns**

| Type | Description |
|------|-------------|
| number | Rotated Q. |
| number | Rotated R. |

**Example**

```lua
do
    local q, r = lurek.tilemap.hexRotate(2, 0, 0, 0, 1)
    example_print_log("(2,0) rotated 60deg CW around origin = " .. q .. ", " .. r)
    q, r = lurek.tilemap.hexRotate(2, 0, 0, 0, 3)
    local dist = lurek.tilemap.hexDistance(0, 0, q, r)
    example_print_log("(2,0) rotated 180deg = " .. q .. ", " .. r)
    example_print_log("rotated point distance from origin = " .. dist)
end
```

---

### `lurek.tilemap.hexRound`

Rounds fractional axial hex coordinates to the nearest integer hex cell.

```lua
lurek.tilemap.hexRound(q, r)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `q` | number | Fractional Q. |
| `r` | number | Fractional R. |

**Returns**

| Type | Description |
|------|-------------|
| number | Rounded Q. |
| number | Rounded R. |

**Example**

```lua
do
    local q, r = lurek.tilemap.hexRound(2.3, 1.7)
    example_print_log("round(2.3, 1.7) = " .. q .. ", " .. r)
    q, r = lurek.tilemap.hexRound(-0.4, 0.6)
    local dist = lurek.tilemap.hexDistance(0, 0, q, r)
    example_print_log("round(-0.4, 0.6) = " .. q .. ", " .. r)
    example_print_log("rounded cell distance from origin = " .. dist)
end
```

---

### `lurek.tilemap.hexSpiral`

Returns all hex cells in a spiral pattern out to a given radius.

```lua
lurek.tilemap.hexSpiral(q, r, radius)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `q` | number | Center Q. |
| `r` | number | Center R. |
| `radius` | number | Maximum radius. |

**Returns**

| Type | Description |
|------|-------------|
| LTilemapHexSpiralResult | Array of `{q, r}` pairs in spiral order. |

**Example**

```lua
do
    local function hexCoords(cell)
        return cell.q or cell[1], cell.r or cell[2]
    end

    local spiral = lurek.tilemap.hexSpiral(0, 0, 2)
    example_print_log("spiral radius 2: " .. #spiral .. " cells")
    local q, r = hexCoords(spiral[1])
    example_print_log("center = q=" .. q .. " r=" .. r)
end
```

---

### `lurek.tilemap.isoDirectionFromAngle`

Converts an angle in degrees to the nearest isometric direction index.

```lua
lurek.tilemap.isoDirectionFromAngle(angle)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `angle` | number | Angle in degrees. |

**Returns**

| Type | Description |
|------|-------------|
| number | Direction index. |

**Example**

```lua
do
    local dir = lurek.tilemap.isoDirectionFromAngle(45)
    local name = lurek.tilemap.isoDirectionName(dir)
    local rotated = lurek.tilemap.isoRotate(dir, 1)
    example_print_log("45 degrees -> direction " .. dir)
    example_print_log("direction name = " .. name)
    example_print_log("one step clockwise = " .. rotated)
end
```

---

### `lurek.tilemap.isoDirectionName`

Returns a human-readable name for an isometric direction index.

```lua
lurek.tilemap.isoDirectionName(direction)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `direction` | number | Direction index. |

**Returns**

| Type | Description |
|------|-------------|
| string | Direction name (e.g. `"north"`, `"east"`, `"south"`, `"west"`). |

**Example**

```lua
do
    local name = lurek.tilemap.isoDirectionName(1)
    local rotated = lurek.tilemap.isoRotate(1, 1)
    local rotated_name = lurek.tilemap.isoDirectionName(rotated)
    example_print_log("iso_dir=" .. name)
    example_print_log("rotated_dir=" .. rotated)
    example_print_log("rotated_name=" .. rotated_name)
end
```

---

### `lurek.tilemap.isoRotate`

Rotates an isometric direction index by a number of 90-degree steps.

```lua
lurek.tilemap.isoRotate(direction, steps)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `direction` | number | Current direction (0..3). |
| `steps` | number | Number of 90-degree steps. |

**Returns**

| Type | Description |
|------|-------------|
| number | Rotated direction. |

**Example**

```lua
do
    local rotated = lurek.tilemap.isoRotate(1, 2)
    local label = lurek.tilemap.isoDirectionName(rotated)
    local reset = lurek.tilemap.isoRotate(rotated, 2)
    example_print_log("iso_rotated=" .. rotated)
    example_print_log("iso_rotated_name=" .. label)
    example_print_log("iso_reset=" .. reset)
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
| `opts?` | any | Optional limits table (`maxChunkCells`, `maxChunks`, `maxCollisionTileChecks`, and related tilemap ceilings). |

**Returns**

| Type | Description |
|------|-------------|
| [LChunkMap](#lchunkmap) | New chunk map. |

**Example**

```lua
do
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
    ---@type LLargeMapRenderer
    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    example_print_log("type = " .. lmr:type())
    example_print_log("chunk size = " .. lmr:getChunkSize())
    example_print_log("tileset columns = " .. lmr:getTilesetColumns())
    example_print_log("typeOf renderer = " .. tostring(lmr:typeOf("LLargeMapRenderer")))
end
```

---

### `lurek.tilemap.newMapBlock`

Creates a new procedural map block with the given dimensions.

```lua
lurek.tilemap.newMapBlock(width, height, layers, segmentSize)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Block width in tiles. |
| `height` | number | Block height in tiles. |
| `layers?` | number | Number of tile layers (default 1). |
| `segmentSize?` | number | Edge segment size in tiles (default 1). |

**Returns**

| Type | Description |
|------|-------------|
| [LMapBlock](#lmapblock) | New map block. |

**Example**

```lua
do
    local block = lurek.tilemap.newMapBlock(8, 8, 2, 2) ; example_print_log("type = " .. block:type())
    local w, h = block:getDimensions() ; example_print_log("dimensions = " .. w .. "x" .. h)
    example_print_log("layers = " .. block:getLayerCount()) ; example_print_log("segment size = " .. block:getSegmentSize())
    example_print_log("width in segments = " .. block:getWidthInSegments())
    example_print_log("height in segments = " .. block:getHeightInSegments())
end
```

---

### `lurek.tilemap.newMapGen`

Creates a procedural map generator from a group and either a size preset or explicit dimensions.

```lua
lurek.tilemap.newMapGen(group, presetOrWidth, segmentSizeOrHeight, segmentSize)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `group` | [LMapGroup](#lmapgroup) | Block group to generate from. |
| `presetOrWidth` | string|number | Size preset (`"small"`, `"medium"`, `"large"`) or width in tiles. |
| `segmentSizeOrHeight` | number | Segment size (if preset) or height in tiles. |
| `segmentSize?` | number | Segment size when using explicit dimensions. |

**Returns**

| Type | Description |
|------|-------------|
| [LMapGen](#lmapgen) | New map generator. |

**Example**

```lua
do
    local group = lurek.tilemap.newMapGroup("caves") ; local block = lurek.tilemap.newMapBlock(4, 4) ; block:setName("open")
    block:setTile(1, 1, 1, 1) ; block:setTile(1, 2, 2, 1) ; group:addBlock(block)
    local script = lurek.tilemap.newMapScript() ; script:addStep({ type = "fillArea", gid = 1, x = 0, y = 0, w = 4, h = 4 }) ; group:addScript(script)
    local gen = lurek.tilemap.newMapGen(group, "small", 1) ; example_print_log("type = " .. gen:type())
    local result = gen:generate(1, 42, "terrain") ; example_print_log("generated map type = " .. result:type())
end
```

---

### `lurek.tilemap.newMapGroup`

Creates a new map group to hold blocks and generation scripts.

```lua
lurek.tilemap.newMapGroup(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Group name. |

**Returns**

| Type | Description |
|------|-------------|
| [LMapGroup](#lmapgroup) | New map group. |

**Example**

```lua
do
    local group = lurek.tilemap.newMapGroup("dungeon") ; example_print_log("type = " .. group:type()) ; example_print_log("name = " .. group:getName())
    local b1 = lurek.tilemap.newMapBlock(4, 4) ; b1:setName("corridor") ; local b2 = lurek.tilemap.newMapBlock(4, 4)
    b2:setName("room") ; group:addBlock(b1)
    group:addBlock(b2) ; example_print_log("block count = " .. group:getBlockCount())
    group:removeBlock(1) ; example_print_log("after remove = " .. group:getBlockCount())
end
```

---

### `lurek.tilemap.newMapScript`

Creates a new empty map-generation script.

```lua
lurek.tilemap.newMapScript()
```

**Returns**

| Type | Description |
|------|-------------|
| [LMapScript](#lmapscript) | New script. |

**Example**

```lua
do
    local script = lurek.tilemap.newMapScript() ; example_print_log("type = " .. script:type())
    script:addStep({ type = "fillArea", gid = 1, x = 0, y = 0, w = 4, h = 4 })
    script:addStep({ type = "placeRandom", gid = 5, count = 2 })
    script:addStep({ type = "fillRect", gid = 2, x = 0, y = 0, w = 5, h = 1 })
    example_print_log("step count = " .. script:getStepCount())
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
| `opts?` | any | Optional limits table (`maxLayers`, `maxTiles`, `maxImagePixels`, `maxImportBytes`, `maxDecodedBytes`, `maxChunkCells`, `maxChunks`, `maxCollisionTileChecks`). |

**Returns**

| Type | Description |
|------|-------------|
| [LTileMap](#ltilemap) | New tilemap. |

**Example**

```lua
do
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

Creates a new tileset from atlas parameters.

```lua
lurek.tilemap.newTileSet(firstGid, tileCount, columns, tileWidth, tileHeight, spacing, margin)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `firstGid` | number | First global tile ID. |
| `tileCount` | number | Total tiles in the set. |
| `columns` | number | Columns in the atlas image. |
| `tileWidth` | number | Tile width in pixels. |
| `tileHeight` | number | Tile height in pixels. |
| `spacing?` | number | Pixel spacing between tiles (default 0). |
| `margin?` | number | Pixel margin around the atlas edge (default 0). |

**Returns**

| Type | Description |
|------|-------------|
| [LTileSet](#ltileset) | New tileset. |

**Example**

```lua
do
    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 64, 8, 32, 32)
    example_print_log("type = " .. ts:type())
    example_print_log("first gid = " .. ts:getFirstGid())
    example_print_log("tile count = " .. ts:getTileCount())
    example_print_log("columns = " .. ts:getColumns())
end
```

---

### `lurek.tilemap.syncMinimap`

Synchronizes a tilemap layer's solid tiles into a minimap's terrain grid.

```lua
lurek.tilemap.syncMinimap(map, layer, minimap, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `map` | [LTileMap](#ltilemap) | Source tilemap. |
| `layer` | number | Layer index (1-based). |
| `minimap` | [LMinimap](#lminimap) | Target minimap. |
| `opts?` | table | Options with keys: solid_terrain (default 2), empty_terrain (default 1). |

**Example**

```lua
do
    local tilemap = lurek.tilemap.newTileMap(16, 16, 32)
    local minimap = lurek.minimap.newMinimap(16, 16)

    -- Sync the tilemap's collision layer to minimap terrain with options
    lurek.tilemap.syncMinimap(tilemap, 1, minimap, {
        solid_terrain = 2,
        empty_terrain = 1
    })
    example_print_log("minimap synced from tilemap with options")

    -- Also show sync with default terrain values
    local tilemap2 = lurek.tilemap.newTileMap(10, 10, 32)
    local minimap2 = lurek.minimap.newMinimap(10, 10)
    lurek.tilemap.syncMinimap(tilemap2, 1, minimap2)
    example_print_log("minimap synced with defaults")
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
    local sx, sy = lurek.tilemap.toScreenHex(2, 3, 32)
    local q, r = lurek.tilemap.fromScreenHex(sx, sy, 32)
    local distance = lurek.tilemap.hexDistance(2, 3, q, r)
    example_print_log("hex(2,3) -> screen(" .. sx .. ", " .. sy .. ")")
    example_print_log("round trip -> hex(" .. q .. "," .. r .. ")")
    example_print_log("round trip distance = " .. distance)
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
    local sx, sy = lurek.tilemap.toScreenIso(3, 5, 64, 32)
    local tx, ty = lurek.tilemap.fromScreenIso(sx, sy, 64, 32)
    local direction = lurek.tilemap.isoDirectionName(lurek.tilemap.isoDirectionFromAngle(45))
    example_print_log("tile(3,5) -> screen(" .. sx .. ", " .. sy .. ")")
    example_print_log("round trip -> tile(" .. tx .. "," .. ty .. ")")
    example_print_log("camera heading label = " .. direction)
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
- [LMapBlock](#lmapblock)
- [LMapGen](#lmapgen)
- [LMapGroup](#lmapgroup)
- [LMapScript](#lmapscript)
- [LMinimap](#lminimap)
- [LTileMap](#ltilemap)
- [LTileSet](#ltileset)

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
| `tileSet` | [LTileSet](#ltileset) | Target tileset to receive the rules. |
| `typeName` | string | Logical tile type name to register under. |
| `startGid?` | number | Optional first GID offset. |

**Example**

```lua
do
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
    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32) ; lmr:setChunkSize(32)
    example_print_log("chunk size = " .. lmr:getChunkSize()) ; lmr:setTilesetColumns(16)
    example_print_log("tileset columns = " .. lmr:getTilesetColumns()) ; lmr:invalidateChunk(0, 0)
    lmr:invalidateAll()
    example_print_log("all chunks invalidated")
end
```

---

#### `LLargeMapRenderer:setViewport`

Sets the viewport dimensions for visibility calculations.

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
    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    local ok = lmr:typeOf("LLargeMapRenderer")
    local as_object = lmr:typeOf("LObject")
    example_print_log("typeOf:", ok)
    example_print_log("typeOfObject:", as_object)
    example_print_log("chunkSize:", lmr:getChunkSize())
end
```

---

## LMapBlock

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LMapBlock:getDimensions`

Returns both width and height of the block in tiles.

```lua
LMapBlock:getDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width. |
| number | Height. |

---

#### `LMapBlock:getFootprintCellCount`

Get the number of occupied footprint cells.

```lua
LMapBlock:getFootprintCellCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Occupied footprint cell count. |

---

#### `LMapBlock:getHeight`

Get height in tiles for this object.

```lua
LMapBlock:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Block height. |

---

#### `LMapBlock:getHeightInSegments`

Returns the block height measured in segments.

```lua
LMapBlock:getHeightInSegments()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Height in segments. |

---

#### `LMapBlock:getLayerCount`

Get the number of tile layers in this map block.

```lua
LMapBlock:getLayerCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Number of layers. |

---

#### `LMapBlock:getName`

Get the map block's display or lookup name string value.

```lua
LMapBlock:getName()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Block name. |

---

#### `LMapBlock:getSegmentSize`

Returns the segment size used for edge matching.

```lua
LMapBlock:getSegmentSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Segment size in tiles. |

---

#### `LMapBlock:getSide`

Returns the side ID for an edge segment.

```lua
LMapBlock:getSide(edge, segment)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `edge` | string | Edge direction: `"north"`, `"east"`, `"south"`, or `"west"`. |
| `segment` | number | Segment index along the edge (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| number | Side identifier. |

---

#### `LMapBlock:getSocket`

Get a previously stored per-cell socket type.

```lua
LMapBlock:getSocket(x, y, edge)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Footprint cell X. |
| `y` | number | Footprint cell Y. |
| `edge` | string | Edge direction. |

**Returns**

| Type | Description |
|------|-------------|
| number | Socket type or 0 when missing. |

---

#### `LMapBlock:getTile`

Get the tile GID at a specified row and column position.

```lua
LMapBlock:getTile(layer, x, y, slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index. |
| `x` | number | Tile X. |
| `y` | number | Tile Y. |
| `slot` | number | Slot index. |

**Returns**

| Type | Description |
|------|-------------|
| number | Tile GID. |

---

#### `LMapBlock:getWeight`

Get block weight for random selection.

```lua
LMapBlock:getWeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Weight value. |

---

#### `LMapBlock:getWidth`

Get the block width measured in tile grid units.

```lua
LMapBlock:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Block width. |

---

#### `LMapBlock:getWidthInSegments`

Returns the block width measured in segments.

```lua
LMapBlock:getWidthInSegments()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width in segments. |

---

#### `LMapBlock:isFootprintCell`

Check whether a local footprint cell exists.

```lua
LMapBlock:isFootprintCell(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Cell X. |
| `y` | number | Cell Y. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if occupied by the footprint. |

---

#### `LMapBlock:setEdge`

Set edge type for a side and segment.

```lua
LMapBlock:setEdge(edge, segment, edge_type)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `edge` | string | Edge direction: "north", "east", "south", "west". |
| `segment` | number | Segment index along the edge. |
| `edge_type` | number | Edge type identifier. |

---

#### `LMapBlock:setEdgeOnly`

Set whether block must be on map edge.

```lua
LMapBlock:setEdgeOnly(edge_only)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `edge_only` | boolean | True if edge-only. |

---

#### `LMapBlock:setFootprint`

Replace the placement footprint with a custom cell list.

```lua
LMapBlock:setFootprint(cells)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cells` | table | Array of {x, y} cells. |

---

#### `LMapBlock:setInteriorOnly`

Set whether block must be in interior.

```lua
LMapBlock:setInteriorOnly(interior_only)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `interior_only` | boolean | True if interior-only. |

---

#### `LMapBlock:setLevelSpan`

Set multi-level span for this object.

```lua
LMapBlock:setLevelSpan(levels)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `levels` | number | Number of levels this block spans. |

---

#### `LMapBlock:setName`

Set the map block's display or lookup name string value.

```lua
LMapBlock:setName(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Block name. |

---

#### `LMapBlock:setSide`

Sets the side ID for an edge segment, used for edge matching in map generation.

```lua
LMapBlock:setSide(edge, segment, sideId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `edge` | string | Edge direction: `"north"`, `"east"`, `"south"`, or `"west"`. |
| `segment` | number | Segment index along the edge (1-based). |
| `sideId` | number | Side identifier for matching. |

---

#### `LMapBlock:setSocket`

Set a per-cell socket type for one edge of the footprint.

```lua
LMapBlock:setSocket(x, y, edge, edge_type)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Footprint cell X. |
| `y` | number | Footprint cell Y. |
| `edge` | string | Edge direction. |
| `edge_type` | number | Socket type identifier. |

---

#### `LMapBlock:setTile`

Set a tile slot value - Lua userdata object exposed by the engine.

```lua
LMapBlock:setTile(layer, x, y, slot, tileset_id, gid)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (0-based). |
| `x` | number | Tile X position. |
| `y` | number | Tile Y position. |
| `slot` | number | Slot index. |
| `tileset_id` | number | Tileset ID. |
| `gid` | number | Tile GID. |

---

#### `LMapBlock:setWeight`

Set block weight for random selection.

```lua
LMapBlock:setWeight(weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `weight` | number | Weight value (higher = more likely). |

---

#### `LMapBlock:type`

Returns the type name of this userdata.

```lua
LMapBlock:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always `"[LMapBlock](#lmapblock)"`. |

---

#### `LMapBlock:typeOf`

Checks whether this object matches the given type name.

```lua
LMapBlock:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check against. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if `name` is `"[LMapBlock](#lmapblock)"` or `"Object"`. |

---

## LMapGen

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LMapGen:generate`

Runs the map generator, optionally using a specific script, seed, and layer name, returning a new tilemap.

```lua
LMapGen:generate(scriptIdx, seed, layerName)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `scriptIdx?` | number | Script index in the group (1-based), or nil for default. |
| `seed?` | number | Random seed, or nil for random. |
| `layerName?` | string | Output layer name (default `"main"`). |

**Returns**

| Type | Description |
|------|-------------|
| [LTileMap](#ltilemap) | Generated tilemap. |

**Example**

```lua
do
    local group = lurek.tilemap.newMapGroup("caves") ; local block = lurek.tilemap.newMapBlock(4, 4) ; block:setName("open")
    block:setTile(1, 1, 1, 1) ; block:setTile(1, 2, 2, 1) ; group:addBlock(block)
    local script = lurek.tilemap.newMapScript() ; script:addStep({ type = "fillArea", gid = 1, x = 0, y = 0, w = 4, h = 4 })
    group:addScript(script) ; local gen = lurek.tilemap.newMapGen(group, "small", 1)
    local result = gen:generate(1, 42, "terrain") ; example_print_log("generated map type = " .. result:type())
end
```

---

#### `LMapGen:type`

Returns the type name of this userdata.

```lua
LMapGen:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always `"[LMapGen](#lmapgen)"`. |

**Example**

```lua
do
    local group = lurek.tilemap.newMapGroup("dungeon") ; local mb = lurek.tilemap.newMapBlock(8, 8, 1, 2)
    group:addBlock(mb)
    local gen = lurek.tilemap.newMapGen(group, "small", 4)
    local t = gen:type()
    example_print_log("LMapGen type:", t)
end
```

---

#### `LMapGen:typeOf`

Checks whether this object matches the given type name.

```lua
LMapGen:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check against. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if `name` is `"[LMapGen](#lmapgen)"` or `"Object"`. |

**Example**

```lua
do
    local group = lurek.tilemap.newMapGroup("dungeon") ; local mb = lurek.tilemap.newMapBlock(8, 8, 1, 2)
    group:addBlock(mb)
    local gen = lurek.tilemap.newMapGen(group, "small", 4)
    local ok = gen:typeOf("LMapGen")
    example_print_log("LMapGen typeOf:", ok)
end
```

---

## LMapGroup

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LMapGroup:addBlock`

Add a block to this group for this object.

```lua
LMapGroup:addBlock(block)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `block` | [LMapBlock](#lmapblock) | Block to add. |

---

#### `LMapGroup:addScript`

Add a script to this group for this object.

```lua
LMapGroup:addScript(script)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `script` | [LMapScript](#lmapscript) | Script to add. |

---

#### `LMapGroup:getBlockCount`

Get the number of blocks for this object.

```lua
LMapGroup:getBlockCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Block count. |

---

#### `LMapGroup:getName`

Get the display name of this map group object.

```lua
LMapGroup:getName()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Group name. |

---

#### `LMapGroup:getScriptCount`

Returns how many scripts are attached to this group.

```lua
LMapGroup:getScriptCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Script count. |

---

#### `LMapGroup:removeBlock`

Removes a block from the group by index.

```lua
LMapGroup:removeBlock(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Block index (1-based). |

---

#### `LMapGroup:type`

Returns the type name of this userdata.

```lua
LMapGroup:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always `"[LMapGroup](#lmapgroup)"`. |

---

#### `LMapGroup:typeOf`

Checks whether this object matches the given type name.

```lua
LMapGroup:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check against. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if `name` is `"[LMapGroup](#lmapgroup)"` or `"Object"`. |

---

## LMapScript

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LMapScript:addStep`

Add a generation step - Lua userdata object exposed by the engine.

```lua
LMapScript:addStep(step_type, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `step_type` | string | Step type name. |
| `opts?` | table | Step configuration options. |

---

#### `LMapScript:clear`

Clear all queued script steps from this map script.

```lua
LMapScript:clear()
```

---

#### `LMapScript:getName`

Get the script name for this object.

```lua
LMapScript:getName()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Script name. |

---

#### `LMapScript:getStepCount`

Get the number of steps for this object.

```lua
LMapScript:getStepCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Step count. |

---

#### `LMapScript:type`

Returns the type name of this userdata.

```lua
LMapScript:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always `"[LMapScript](#lmapscript)"`. |

---

#### `LMapScript:typeOf`

Checks whether this object matches the given type name.

```lua
LMapScript:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check against. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if `name` is `"[LMapScript](#lmapscript)"` or `"Object"`. |

---

## LMinimap

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LMinimap:addMarker`

Adds a world-space marker and returns its unique id.

```lua
LMinimap:addMarker(x, y, desc, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Marker x coordinate. |
| `y` | number | Marker y coordinate. |
| `desc?` | string | Marker description. |
| `r?` | number | Red channel override, defaults to 1.0. |
| `g?` | number | Green channel override, defaults to 0.0. |
| `b?` | number | Blue channel override, defaults to 0.0. |
| `a?` | number | Alpha channel override, defaults to 1.0. |

**Returns**

| Type | Description |
|------|-------------|
| number | Marker id. |

---

#### `LMinimap:addObjectType`

Adds an object type and returns its one-based index.

```lua
LMinimap:addObjectType(name, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Object type name. |
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a?` | number | Alpha channel, defaults to 1.0. |

**Returns**

| Type | Description |
|------|-------------|
| number | One-based object type index. |

---

#### `LMinimap:addPing`

Adds a timed ping effect at a minimap world position.

```lua
LMinimap:addPing(x, y, duration, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | World x coordinate of the ping. |
| `y` | number | World y coordinate of the ping. |
| `duration` | number | Duration in seconds before the ping fades out. |
| `r?` | number | Red channel, defaults to 1.0. |
| `g?` | number | Green channel, defaults to 1.0. |
| `b?` | number | Blue channel, defaults to 0.0. |
| `a?` | number | Alpha channel, defaults to 1.0. |

---

#### `LMinimap:clearMarkerAnimation`

Clears the animation assigned to a marker by id.

```lua
LMinimap:clearMarkerAnimation(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Marker id. |

---

#### `LMinimap:clearMarkerTexture`

Clears image texture from a marker.

```lua
LMinimap:clearMarkerTexture(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Marker id. |

---

#### `LMinimap:clearObjectTypeTexture`

Clears image texture for an object type.

```lua
LMinimap:clearObjectTypeTexture(type_idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_idx` | number | One-based object type index. |

---

#### `LMinimap:clearObjects`

Clears all objects from the minimap.

```lua
LMinimap:clearObjects()
```

---

#### `LMinimap:clearOverlay`

Clears all minimap overlay shapes.

```lua
LMinimap:clearOverlay()
```

---

#### `LMinimap:clearPath`

Clears one path by id or all paths when no id is provided.

```lua
LMinimap:clearPath(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id?` | number | Path id to clear. |

---

#### `LMinimap:clearViewportRect`

Clears the minimap viewport rectangle overlay.

```lua
LMinimap:clearViewportRect()
```

---

#### `LMinimap:drawLine`

Adds an overlay line between two world-space points.

```lua
LMinimap:drawLine(x1, y1, x2, y2, color_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | number | Start x coordinate. |
| `y1` | number | Start y coordinate. |
| `x2` | number | End x coordinate. |
| `y2` | number | End y coordinate. |
| `color_tbl` | table | RGBA byte color table. |

---

#### `LMinimap:drawRect`

Adds an overlay rectangle at a world-space position.

```lua
LMinimap:drawRect(x, y, w, h, color_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Rectangle x coordinate. |
| `y` | number | Rectangle y coordinate. |
| `w` | number | Rectangle width. |
| `h` | number | Rectangle height. |
| `color_tbl` | table | RGBA byte color table. |

---

#### `LMinimap:drawToImage`

Draws the minimap into image data at a pixel size.

```lua
LMinimap:drawToImage(pixel_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pixel_size` | number | Pixel size scale. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](render.md#limagedata) | Image data containing the rendered minimap. |

---

#### `LMinimap:getCellCount`

Returns the total number of grid cells.

```lua
LMinimap:getCellCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Cell count. |

---

#### `LMinimap:getCenter`

Returns the current minimap world-space center position.

```lua
LMinimap:getCenter()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Center x coordinate. |
| number | Center y coordinate. |

---

#### `LMinimap:getCenterX`

Returns minimap world center x coordinate.

```lua
LMinimap:getCenterX()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Center x coordinate. |

---

#### `LMinimap:getCenterY`

Returns minimap world center y coordinate.

```lua
LMinimap:getCenterY()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Center y coordinate. |

---

#### `LMinimap:getColorMode`

Returns the current minimap color mode.

```lua
LMinimap:getColorMode()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Color mode name. |

---

#### `LMinimap:getDisplayHeight`

Returns the minimap display height.

```lua
LMinimap:getDisplayHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Display height in pixels. |

---

#### `LMinimap:getDisplaySize`

Returns the minimap display width and height in pixels.

```lua
LMinimap:getDisplaySize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Display width in pixels. |
| number | Display height in pixels. |

---

#### `LMinimap:getDisplayWidth`

Returns the minimap display width.

```lua
LMinimap:getDisplayWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Display width in pixels. |

---

#### `LMinimap:getFogColor`

Returns the current RGBA fog overlay color.

```lua
LMinimap:getFogColor()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Red channel. |
| number | Green channel. |
| number | Blue channel. |
| number | Alpha channel. |

---

#### `LMinimap:getFogLevel`

Returns fog level for a one-based grid cell.

```lua
LMinimap:getFogLevel(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based grid x coordinate. |
| `y` | number | One-based grid y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Fog level byte. |

---

#### `LMinimap:getGridHeight`

Returns the height of the minimap grid in cells.

```lua
LMinimap:getGridHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Grid height in cells. |

---

#### `LMinimap:getGridSize`

Returns the minimap grid width and height in cells.

```lua
LMinimap:getGridSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Grid width in cells. |
| number | Grid height in cells. |

---

#### `LMinimap:getGridWidth`

Returns the width of the minimap grid in cells.

```lua
LMinimap:getGridWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Grid width in cells. |

---

#### `LMinimap:getHoverInfo`

Returns hover text for a screen position when available.

```lua
LMinimap:getHoverInfo(sx, sy, mx, my)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | number | Screen x coordinate. |
| `sy` | number | Screen y coordinate. |
| `mx` | number | Minimap x position. |
| `my` | number | Minimap y position. |

**Returns**

| Type | Description |
|------|-------------|
| string | Hover info text, or nil when unavailable. |

---

#### `LMinimap:getLayer`

Returns the active minimap display layer index.

```lua
LMinimap:getLayer()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Layer index. |

---

#### `LMinimap:getLayerCount`

Returns the number of minimap layers.

```lua
LMinimap:getLayerCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Layer count. |

---

#### `LMinimap:getLayerData`

Returns raw cell data for a minimap layer.

```lua
LMinimap:getLayerData(layer)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of cell bytes, or nil when missing. |

---

#### `LMinimap:getMarkerCount`

Returns the total number of minimap markers.

```lua
LMinimap:getMarkerCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Marker count. |

---

#### `LMinimap:getMarkerDescription`

Returns a marker description by id.

```lua
LMinimap:getMarkerDescription(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Marker id. |

**Returns**

| Type | Description |
|------|-------------|
| string | Marker description, or nil when missing. |

---

#### `LMinimap:getObjectCount`

Returns the number of objects on the minimap.

```lua
LMinimap:getObjectCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Object count. |

---

#### `LMinimap:getObjectTypeCount`

Returns the number of object types.

```lua
LMinimap:getObjectTypeCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Object type count. |

---

#### `LMinimap:getOverlayShapeCount`

Returns the number of overlay shapes.

```lua
LMinimap:getOverlayShapeCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Overlay shape count. |

---

#### `LMinimap:getOwnerColor`

Returns the current RGBA color for an owner id.

```lua
LMinimap:getOwnerColor(owner)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `owner` | number | Owner id. |

**Returns**

| Type | Description |
|------|-------------|
| number | Red channel. |
| number | Green channel. |
| number | Blue channel. |
| number | Alpha channel. |

---

#### `LMinimap:getPathCount`

Returns the number of active path overlays.

```lua
LMinimap:getPathCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Path count. |

---

#### `LMinimap:getPingCount`

Returns the number of active pings.

```lua
LMinimap:getPingCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Ping count. |

---

#### `LMinimap:getTerrain`

Returns terrain type for a one-based grid cell.

```lua
LMinimap:getTerrain(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based grid x coordinate. |
| `y` | number | One-based grid y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Terrain type id. |

---

#### `LMinimap:getTerrainColor`

Returns RGBA color for a terrain type.

```lua
LMinimap:getTerrainColor(terrain_type)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `terrain_type` | number | Terrain type id. |

**Returns**

| Type | Description |
|------|-------------|
| number | Red channel. |
| number | Green channel. |
| number | Blue channel. |
| number | Alpha channel. |

---

#### `LMinimap:getTileDescription`

Returns text description for a tile type.

```lua
LMinimap:getTileDescription(type_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_id` | number | Tile type id. |

**Returns**

| Type | Description |
|------|-------------|
| string | Description text, or nil when missing. |

---

#### `LMinimap:getViewportColor`

Returns the viewport rectangle color.

```lua
LMinimap:getViewportColor()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Red channel. |
| number | Green channel. |
| number | Blue channel. |
| number | Alpha channel. |

---

#### `LMinimap:getViewportRect`

Returns the viewport rectangle when one is set.

```lua
LMinimap:getViewportRect()
```

**Returns**

| Type | Description |
|------|-------------|
| number | X coordinate; or nil when unset. |
| number | Y coordinate; or nil when unset. |
| number | Width; or nil when unset. |
| number | Height; or nil when unset. |

---

#### `LMinimap:getZoom`

Returns the current minimap zoom magnification level.

```lua
LMinimap:getZoom()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Zoom value. |

---

#### `LMinimap:gridToScreen`

Converts grid coordinates to screen coordinates.

```lua
LMinimap:gridToScreen(gx, gy, mx, my)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `gx` | number | Grid x coordinate. |
| `gy` | number | Grid y coordinate. |
| `mx` | number | Minimap x position. |
| `my` | number | Minimap y position. |

**Returns**

| Type | Description |
|------|-------------|
| number | Screen x coordinate; or nil when the transform state is invalid. |
| number | Screen y coordinate; or nil when the transform state is invalid. |

---

#### `LMinimap:hasMarker`

Returns whether a marker id exists.

```lua
LMinimap:hasMarker(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Marker id. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the marker exists. |

---

#### `LMinimap:isAntiAlias`

Returns whether anti-aliasing is enabled.

```lua
LMinimap:isAntiAlias()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when enabled. |

---

#### `LMinimap:isClickable`

Returns whether minimap click handling is enabled.

```lua
LMinimap:isClickable()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when clickable. |

---

#### `LMinimap:isFogEnabled`

Returns whether fog display is enabled.

```lua
LMinimap:isFogEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when fog is enabled. |

---

#### `LMinimap:isObjectTypeVisible`

Returns visibility for an object type by one-based index.

```lua
LMinimap:isObjectTypeVisible(type_idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_idx` | number | One-based object type index. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the object type is visible. |

---

#### `LMinimap:isViewportVisible`

Returns whether the viewport rectangle is visible.

```lua
LMinimap:isViewportVisible()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when visible. |

---

#### `LMinimap:removeMarker`

Removes a minimap marker by its unique id.

```lua
LMinimap:removeMarker(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Marker id. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a marker was removed. |

---

#### `LMinimap:removeObject`

Removes a minimap object by its unique id.

```lua
LMinimap:removeObject(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Object id. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when an object was removed. |

---

#### `LMinimap:render`

Enqueues minimap render commands at an optional screen position.

```lua
LMinimap:render(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x?` | number | Screen x coordinate, defaults to 0. |
| `y?` | number | Screen y coordinate, defaults to 0. |

---

#### `LMinimap:revealRadius`

Reveals fog inside a world-space radius.

```lua
LMinimap:revealRadius(cx, cy, radius)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | number | Center x coordinate. |
| `cy` | number | Center y coordinate. |
| `radius` | number | Reveal radius. |

---

#### `LMinimap:screenToGrid`

Converts a screen position to grid coordinates.

```lua
LMinimap:screenToGrid(sx, sy, mx, my)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | number | Screen x coordinate. |
| `sy` | number | Screen y coordinate. |
| `mx` | number | Minimap x position. |
| `my` | number | Minimap y position. |

**Returns**

| Type | Description |
|------|-------------|
| number | Grid x coordinate; or nil when the transform state is invalid. |
| number | Grid y coordinate; or nil when the transform state is invalid. |

---

#### `LMinimap:setAntiAlias`

Enables or disables minimap anti-aliasing.

```lua
LMinimap:setAntiAlias(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | boolean | Anti-alias flag. |

---

#### `LMinimap:setCenter`

Sets the minimap world-space center position.

```lua
LMinimap:setCenter(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Center x coordinate. |
| `y` | number | Center y coordinate. |

---

#### `LMinimap:setClickable`

Enables or disables minimap click handling.

```lua
LMinimap:setClickable(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | boolean | Clickable flag. |

---

#### `LMinimap:setColorMode`

Sets the minimap color mode to terrain or political.

```lua
LMinimap:setColorMode(mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | string | Color mode name, expected `terrain` or `political`. |

---

#### `LMinimap:setDisplaySize`

Sets the minimap display width and height in pixels.

```lua
LMinimap:setDisplaySize(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Display width in pixels. |
| `h` | number | Display height in pixels. |

---

#### `LMinimap:setFogColor`

Sets the RGBA fog overlay color for covered cells.

```lua
LMinimap:setFogColor(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a?` | number | Alpha channel, defaults to 0.8. |

---

#### `LMinimap:setFogData`

Replaces fog data from a flat array table.

```lua
LMinimap:setFogData(data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | table | Array table of fog level bytes. |

---

#### `LMinimap:setFogEnabled`

Enables or disables the minimap fog display.

```lua
LMinimap:setFogEnabled(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | boolean | Fog enabled flag. |

---

#### `LMinimap:setFogLevel`

Sets fog level for a one-based grid cell.

```lua
LMinimap:setFogLevel(x, y, level)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based grid x coordinate. |
| `y` | number | One-based grid y coordinate. |
| `level` | number | Fog level byte. |

---

#### `LMinimap:setLayer`

Sets the active minimap display layer index.

```lua
LMinimap:setLayer(layer)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index. |

---

#### `LMinimap:setLayerData`

Sets raw cell data for a minimap layer.

```lua
LMinimap:setLayerData(layer, data_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index. |
| `data_tbl` | table | Array table of cell bytes. |

---

#### `LMinimap:setMarkerAnimation`

Sets marker animation by type name.

```lua
LMinimap:setMarkerAnimation(id, anim_type, speed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Marker id. |
| `anim_type` | string | Animation type: `blink`, `pulse`, or `rotate`. |
| `speed` | number | Animation speed. |

---

#### `LMinimap:setMarkerTexture`

Assigns an image texture to a marker.

```lua
LMinimap:setMarkerTexture(id, image_ud, width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Marker id. |
| `image_ud` | [LImage](render.md#limage) | Image handle from `lurek.render.newImage`. |
| `width?` | number | Display width override. |
| `height?` | number | Display height override. |

---

#### `LMinimap:setObject`

Adds or updates an object on the minimap.

```lua
LMinimap:setObject(id, x, y, type_idx, owner)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Object id. |
| `x` | number | Object x coordinate. |
| `y` | number | Object y coordinate. |
| `type_idx` | number | One-based object type index. |
| `owner?` | number | Owner id, defaults to 0. |

---

#### `LMinimap:setObjectTypeTexture`

Assigns an image texture to an object type.

```lua
LMinimap:setObjectTypeTexture(type_idx, image_ud, width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_idx` | number | One-based object type index. |
| `image_ud` | [LImage](render.md#limage) | Image handle from `lurek.render.newImage`. |
| `width?` | number | Display width override. |
| `height?` | number | Display height override. |

---

#### `LMinimap:setObjectTypeVisible`

Sets visibility for an object type by one-based index.

```lua
LMinimap:setObjectTypeVisible(type_idx, visible)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_idx` | number | One-based object type index. |
| `visible` | boolean | Visibility flag. |

---

#### `LMinimap:setOwnerColor`

Sets the RGBA display color for an owner id.

```lua
LMinimap:setOwnerColor(owner, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `owner` | number | Owner id. |
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a?` | number | Alpha channel, defaults to 1.0. |

---

#### `LMinimap:setTerrain`

Sets terrain type for a one-based grid cell.

```lua
LMinimap:setTerrain(x, y, terrain_type)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based grid x coordinate. |
| `y` | number | One-based grid y coordinate. |
| `terrain_type` | number | Terrain type id. |

---

#### `LMinimap:setTerrainColor`

Sets the RGBA display color for a terrain type.

```lua
LMinimap:setTerrainColor(terrain_type, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `terrain_type` | number | Terrain type id. |
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a?` | number | Alpha channel, defaults to 1.0. |

---

#### `LMinimap:setTerrainData`

Replaces terrain data from a flat array table.

```lua
LMinimap:setTerrainData(data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | table | Array table of terrain type ids. |

---

#### `LMinimap:setTileDescription`

Sets text description for a tile type.

```lua
LMinimap:setTileDescription(type_id, desc)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_id` | number | Tile type id. |
| `desc` | string | Description text. |

---

#### `LMinimap:setViewportColor`

Sets the viewport rectangle color.

```lua
LMinimap:setViewportColor(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a?` | number | Alpha channel, defaults to 0.8. |

---

#### `LMinimap:setViewportRect`

Sets the visible viewport rectangle shown on the minimap.

```lua
LMinimap:setViewportRect(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Viewport x coordinate. |
| `y` | number | Viewport y coordinate. |
| `w` | number | Viewport width. |
| `h` | number | Viewport height. |

---

#### `LMinimap:setViewportVisible`

Sets whether the viewport rectangle is visible.

```lua
LMinimap:setViewportVisible(visible)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `visible` | boolean | Visibility flag. |

---

#### `LMinimap:setZoom`

Sets the minimap zoom magnification level.

```lua
LMinimap:setZoom(zoom)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `zoom` | number | Zoom value. |

---

#### `LMinimap:showPath`

Adds a colored path overlay and returns its id.

```lua
LMinimap:showPath(points_tbl, color_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `points_tbl` | table | Array table of point arrays `{x, y}`. |
| `color_tbl` | table | RGBA byte color table. |

**Returns**

| Type | Description |
|------|-------------|
| number | Path id. |

---

#### `LMinimap:trackCamera`

Centers the minimap and viewport rectangle from a camera handle.

```lua
LMinimap:trackCamera(camera_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `camera_ud` | [LCamera](camera.md#lcamera) | Camera handle from `lurek.camera.newCamera`. |

---

#### `LMinimap:type`

Returns the Lua-visible type name for this minimap handle.

```lua
LMinimap:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LMinimap](#lminimap)`. |

---

#### `LMinimap:typeOf`

Returns whether this minimap handle matches a supported type name.

```lua
LMinimap:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LMinimap](#lminimap)`, `Minimap`, and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

---

#### `LMinimap:update`

Advances minimap animations and timers.

```lua
LMinimap:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds. |

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
| `tileSet` | [LTileSet](#ltileset) | Tileset to add. |

**Example**

```lua
do
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

#### `LTileMap:checkEntities`

Checks a list of entities against registered tile-enter callbacks on a layer.

```lua
LTileMap:checkEntities(layer, entities)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `entities` | table | Array of entity tables, each with `x`/`y` or `[1]`/`[2]` fields. |

**Example**

```lua
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("events", 10, 10)
    map:setTile(layer, 2, 2, 3)
    map:onTileEnter(3, function(entity, tx, ty) example_print_log("entered at " .. tx .. "," .. ty) end)
    local entities = {
        { x = 64, y = 64 },
        { x = 128, y = 128 },
    }

    map:checkEntities(layer, entities)
    example_print_log("entities checked against tile events")
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
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("main", 10, 10)
    map:setTile(layer, 3, 4, 5)
    map:clearTile(layer, 3, 4)
    local gid = map:getTile(layer, 3, 4)
    example_print_log("after clear = " .. gid)
end
```

---

#### `LTileMap:drawToImage`

Rasterizes the map into an image using the given tile size, returning an image handle.

```lua
LTileMap:drawToImage(tileSize)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tileSize` | number | Pixel size of each tile in the output image. |

**Returns**

| Type | Description |
|------|-------------|
| [LImage](render.md#limage) | Rasterized image of the map. |

**Example**

```lua
do
    local map = lurek.tilemap.newTileMap(16, 16)
    local layer = map:addLayer("simple", 8, 8)
    map:fill(layer, 1)
    local img = map:drawToImage(16)
    example_print_log("image type = " .. img:type())
    example_print_log("drawn to image at tile size 16")
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

#### `LTileMap:fireTileExit`

Manually fires the tile-exit callback for a specific GID and entity at a tile position.

```lua
LTileMap:fireTileExit(gid, entity, tx, ty)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `gid` | number | Global tile ID. |
| `entity` | table | Entity table to pass to the callback. |
| `tx` | number | Tile column. |
| `ty` | number | Tile row. |

**Example**

```lua
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("events", 10, 10)
    map:setTile(layer, 2, 2, 3)
    map:onTileEnter(3, function(entity, tx, ty) example_print_log("entered at " .. tx .. "," .. ty) end)
    local entities = {
        { x = 64, y = 64 },
        { x = 128, y = 128 },
    }

    map:fireTileExit(3, entities[1], 2, 2)
    example_print_log("tile exit fired")
end
```

---

#### `LTileMap:fireTileStep`

Manually fires the tile-step callback for a specific GID and entity at a tile position.

```lua
LTileMap:fireTileStep(gid, entity, tx, ty)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `gid` | number | Global tile ID. |
| `entity` | table | Entity table to pass to the callback. |
| `tx` | number | Tile column. |
| `ty` | number | Tile row. |

**Example**

```lua
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("events", 10, 10)
    map:setTile(layer, 2, 2, 3)
    map:onTileEnter(3, function(entity, tx, ty) example_print_log("entered at " .. tx .. "," .. ty) end)
    local entities = {
        { x = 64, y = 64 },
        { x = 128, y = 128 },
    }

    map:fireTileStep(3, entities[1], 2, 2)
    example_print_log("tile step fired")
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
| [LTileSet](#ltileset) | The tileset, or nil if index is out of range. |

**Example**

```lua
do
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
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("ground", 100, 100)
    map:setViewport(0, 0, 800, 600)
    local vx, vy, vw, vh = map:getViewport()
    example_print_log("viewport = " .. vx .. "," .. vy .. " " .. vw .. "x" .. vh)
end
```

---

#### `LTileMap:isSolid`

Checks whether the tile at a given position on a layer is solid.

```lua
LTileMap:isSolid(layer, x, y)
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
| boolean | True if the tile at that position is marked solid. |

**Example**

```lua
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 32, 32)
    ts:setSolid(1, true)
    map:addTileSet(ts)

    local layer = map:addLayer("collision", 10, 10)
    map:setTile(layer, 3, 3, 1)
    map:setTile(layer, 4, 3, 1)

    example_print_log("3,3 solid = " .. tostring(map:isSolid(layer, 3, 3)))
    example_print_log("5,5 solid = " .. tostring(map:isSolid(layer, 5, 5)))
end
```

---

#### `LTileMap:onTileEnter`

Registers a callback invoked when an entity enters a tile with the given GID.

```lua
LTileMap:onTileEnter(gid, func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `gid` | number | Global tile ID to watch for. |
| `func` | function | Callback receiving `(wx, wy, tx, ty)`. |

**Example**

```lua
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("triggers", 10, 10)
    map:setTile(layer, 3, 3, 5)
    map:onTileEnter(5, function(entity, tx, ty) example_print_log("entity entered trigger tile at " .. tx .. "," .. ty) end)
    example_print_log("enter callback registered for gid=5")
end
```

---

#### `LTileMap:onTileExit`

Registers a callback invoked when an entity leaves a tile with the given GID.

```lua
LTileMap:onTileExit(gid, func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `gid` | number | Global tile ID to watch for. |
| `func` | function | Callback receiving `(entity, tx, ty)`. |

**Example**

```lua
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("triggers", 10, 10)
    map:setTile(layer, 3, 3, 5)
    map:onTileExit(5, function(entity, tx, ty) example_print_log("entity left trigger tile at " .. tx .. "," .. ty) end)
    example_print_log("exit callback registered for gid=5")
end
```

---

#### `LTileMap:onTileStep`

Registers a callback invoked each frame an entity remains on a tile with the given GID.

```lua
LTileMap:onTileStep(gid, func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `gid` | number | Global tile ID to watch for. |
| `func` | function | Callback receiving `(entity, tx, ty)`. |

**Example**

```lua
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local layer = map:addLayer("triggers", 10, 10)
    map:setTile(layer, 3, 3, 5)
    map:onTileStep(5, function(entity, tx, ty) example_print_log("entity stepping on trigger at " .. tx .. "," .. ty) end)
    example_print_log("step callback registered for gid=5")
end
```

---

#### `LTileMap:rectOverlapsSolid`

Tests whether a world-space rectangle overlaps any solid tile on a layer.

```lua
LTileMap:rectOverlapsSolid(layer, x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `x` | number | Rectangle left edge in world pixels. |
| `y` | number | Rectangle top edge in world pixels. |
| `w` | number | Rectangle width in pixels. |
| `h` | number | Rectangle height in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if any solid tile is overlapped. |

**Example**

```lua
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 32, 32)
    ts:setSolid(1, true)
    map:addTileSet(ts)

    local layer = map:addLayer("collision", 10, 10)
    map:setTile(layer, 3, 3, 1)
    map:setTile(layer, 4, 3, 1)

    local overlap = map:rectOverlapsSolid(layer, 80, 80, 40, 40)
    example_print_log("rect overlaps solid = " .. tostring(overlap))
    example_print_log("note: rectOverlapsSolid is a tile query pre-check; physics bodies need explicit lurek.physics colliders")
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
    local map = lurek.tilemap.newTileMap(32, 32)
    map:addLayer("ground", 100, 100)
    map:setViewport(0, 0, 800, 600)
    local vx, vy, vw, vh = map:getViewport()
    example_print_log("viewport = " .. vx .. "," .. vy .. " " .. vw .. "x" .. vh)
end
```

---

#### `LTileMap:sweepRect`

Performs a swept AABB collision test against solid tiles on a layer, returning the contact point and normal.

```lua
LTileMap:sweepRect(layer, x, y, w, h, dx, dy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `x` | number | Rectangle left edge in world pixels. |
| `y` | number | Rectangle top edge in world pixels. |
| `w` | number | Rectangle width in pixels. |
| `h` | number | Rectangle height in pixels. |
| `dx` | number | Horizontal movement delta. |
| `dy` | number | Vertical movement delta. |

**Returns**

| Type | Description |
|------|-------------|
| number | Contact X position. |
| number | Contact Y position. |
| number | Normal X component. |
| number | Normal Y component. |
| number | Tile column hit (1-based; or 0 if no hit). |
| number | Tile row hit (1-based; or 0 if no hit). |

**Example**

```lua
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 32, 32)
    ts:setSolid(1, true)
    map:addTileSet(ts)

    local layer = map:addLayer("collision", 20, 20)
    map:setTile(layer, 5, 5, 1)
    map:setTile(layer, 6, 5, 1)

    local cx, cy, nx, ny, tx, ty = map:sweepRect(layer, 64, 64, 16, 16, 200, 0)
    example_print_log("contact pos = " .. cx .. ", " .. cy)
    example_print_log("normal = " .. nx .. ", " .. ny)
    example_print_log("tile hit = " .. tx .. ", " .. ty)
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

#### `LTileMap:toNavGrid`

Converts a layer into a 2D boolean grid for pathfinding. Tiles with GIDs in the given list are marked walkable.

```lua
LTileMap:toNavGrid(layer, gids)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index (1-based). |
| `gids` | table | Array of walkable GIDs. |

**Returns**

| Type | Description |
|------|-------------|
| boolean[] | Flat walkable grid (true = walkable), row-major order. |

**Example**

```lua
do
    local map = lurek.tilemap.newTileMap(32, 32)
    local ts = lurek.tilemap.newTileSet(1, 8, 4, 32, 32)
    ts:setSolid(1, true)
    ts:setSolid(2, true)
    map:addTileSet(ts)

    local layer = map:addLayer("nav", 5, 5)
    map:setTile(layer, 2, 2, 1)
    map:setTile(layer, 3, 2, 2)

    local grid = map:toNavGrid(layer, { 1, 2 })
    example_print_log("nav grid rows = " .. #grid)
    example_print_log("cell 1,1 walkable = " .. tostring(grid[1] and grid[1][1]))
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

## LTileSet

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTileSet:getAnimation`

Returns the animation frames for a tile, or nil if none are set.

```lua
LTileSet:getAnimation(tileId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tileId` | number | Tile ID to query (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| LTileSetGetAnimationResult | Array of `{tileid=number, duration=number}` frames, or nil. |

**Example**

```lua
do
    local ts = lurek.tilemap.newTileSet(1, 32, 8, 16, 16)
    ts:setAnimation(1, {
        { tileid = 1, duration = 200 },
        { tileid = 2, duration = 200 },
        { tileid = 3, duration = 200 },
        { tileid = 4, duration = 200 },
    })

    local anim = ts:getAnimation(1)
    example_print_log("animation frames = " .. #anim)
    for i, frame in ipairs(anim) do
        example_print_log("  frame " .. i .. ": tile=" .. frame.tileid .. " dur=" .. frame.duration)
    end
    local noAnim = ts:getAnimation(10)
    example_print_log("tile 10 anim = " .. tostring(noAnim))
end
```

---

#### `LTileSet:getAutoTileId`

Looks up the tile ID for a 4-bit auto-tile bitmask and type name.

```lua
LTileSet:getAutoTileId(typeName, bitmask)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `typeName` | string | Logical tile type name. |
| `bitmask` | number | 4-bit neighbor bitmask (0..15). |

**Returns**

| Type | Description |
|------|-------------|
| number | Resolved tile ID (1-based), or nil if no rule matches. |

**Example**

```lua
do
    local ts = lurek.tilemap.newTileSet(1, 32, 8, 16, 16)
    ts:setAutoTileRule("grass", 0, 1)
    ts:setAutoTileRule("grass", 15, 16)
    local id = ts:getAutoTileId("grass", 15)
    example_print_log("bitmask 15 -> tile " .. id)
end
```

---

#### `LTileSet:getAutoTileId8`

Looks up the tile ID for an 8-bit auto-tile bitmask and type name.

```lua
LTileSet:getAutoTileId8(typeName, bitmask)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `typeName` | string | Logical tile type name. |
| `bitmask` | number | 8-bit neighbor bitmask (0..255). |

**Returns**

| Type | Description |
|------|-------------|
| number | Resolved tile ID (1-based), or nil if no rule matches. |

**Example**

```lua
do
    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 256, 16, 16, 16)
    ts:setAutoTileRule8("wall", 255, 48)
    local id = ts:getAutoTileId8("wall", 255)
    ts:setAutoTileRule8("wall", 0, 1)
    local edge = ts:getAutoTileId8("wall", 0)
    example_print_log("8-bit bitmask 255 -> tile " .. id)
    example_print_log("8-bit bitmask 0 -> tile " .. edge)
end
```

---

#### `LTileSet:getAutoTileMode`

Returns the neighbor matching mode for a named auto-tile type.

```lua
LTileSet:getAutoTileMode(typeName)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `typeName` | string | Logical tile type name. |

**Returns**

| Type | Description |
|------|-------------|
| string | One of `"matchSides"`, `"matchCorners"`, `"matchCornersAndSides"`. |

**Example**

```lua
do
    local ts = lurek.tilemap.newTileSet(1, 64, 8, 16, 16)
    local default_mode = ts:getAutoTileMode("grass")
    ts:setAutoTileMode("grass", "matchSides")
    local configured_mode = ts:getAutoTileMode("grass")
    example_print_log("grass default mode = " .. default_mode)
    example_print_log("grass configured mode = " .. configured_mode)
end
```

---

#### `LTileSet:getColumns`

Returns the number of columns in the tileset atlas image.

```lua
LTileSet:getColumns()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Column count. |

**Example**

```lua
do
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local count = ts:getTileCount()
    example_print_log("columns=" .. ts:getColumns())
    example_print_log("tileCount=" .. count)
    example_print_log("tileWidth=" .. ts:getTileWidth())
end
```

---

#### `LTileSet:getFirstGid`

Returns the first global tile ID (GID) of this tileset.

```lua
LTileSet:getFirstGid()
```

**Returns**

| Type | Description |
|------|-------------|
| number | First GID assigned to this tileset. |

**Example**

```lua
do
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local columns = ts:getColumns()
    example_print_log("firstGid=" .. ts:getFirstGid())
    example_print_log("columns=" .. columns)
    example_print_log("tileHeight=" .. ts:getTileHeight())
end
```

---

#### `LTileSet:getMargin`

Returns the margin around the edge of the atlas image, in pixels.

```lua
LTileSet:getMargin()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Margin in pixels. |

**Example**

```lua
do
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local spacing = ts:getSpacing()
    local width = ts:getTileWidth()
    example_print_log("margin=" .. ts:getMargin())
    example_print_log("spacing=" .. spacing)
    example_print_log("tileWidth=" .. width)
end
```

---

#### `LTileSet:getQuad`

Returns the source rectangle (UV quad) for a tile in the atlas.

```lua
LTileSet:getQuad(tileId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tileId` | number | Tile ID (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| LTileSetGetQuadResult | Table with fields `x`, `y`, `width`, `height` in pixels. |

**Example**

```lua
do
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 32, 32)
    local q1 = ts:getQuad(1)
    example_print_log("tile 1: x=" .. q1.x .. " y=" .. q1.y .. " w=" .. q1.width .. " h=" .. q1.height)
    local q5 = ts:getQuad(5)
    example_print_log("tile 5: x=" .. q5.x .. " y=" .. q5.y .. " w=" .. q5.width .. " h=" .. q5.height)
end
```

---

#### `LTileSet:getSpacing`

Returns the spacing between tiles in the atlas image, in pixels.

```lua
LTileSet:getSpacing()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Spacing in pixels. |

**Example**

```lua
do
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local margin = ts:getMargin()
    local height = ts:getTileHeight()
    example_print_log("spacing=" .. ts:getSpacing())
    example_print_log("margin=" .. margin)
    example_print_log("tileHeight=" .. height)
end
```

---

#### `LTileSet:getTileCount`

Returns the total number of tiles defined in this tileset.

```lua
LTileSet:getTileCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Total tile count. |

**Example**

```lua
do
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local columns = ts:getColumns()
    local first_gid = ts:getFirstGid()
    example_print_log("tileCount=" .. ts:getTileCount())
    example_print_log("columns=" .. columns)
    example_print_log("firstGid=" .. first_gid)
end
```

---

#### `LTileSet:getTileDimensions`

Returns both tile width and height in pixels.

```lua
LTileSet:getTileDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Tile width in pixels. |
| number | Tile height in pixels. |

**Example**

```lua
do
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local tw, th = ts:getTileDimensions()
    local quad = ts:getQuad(1)
    example_print_log("tile_w=" .. tw .. " tile_h=" .. th)
    example_print_log("quad_w=" .. quad.width .. " quad_h=" .. quad.height)
end
```

---

#### `LTileSet:getTileHeight`

Returns the height of a single tile in pixels.

```lua
LTileSet:getTileHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Tile height in pixels. |

**Example**

```lua
do
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local tw = ts:getTileWidth()
    local count = ts:getTileCount()
    example_print_log("tileHeight=" .. ts:getTileHeight())
    example_print_log("tileWidth=" .. tw)
    example_print_log("tileCount=" .. count)
end
```

---

#### `LTileSet:getTileWidth`

Returns the width of a single tile in pixels.

```lua
LTileSet:getTileWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Tile width in pixels. |

**Example**

```lua
do
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local th = ts:getTileHeight()
    local count = ts:getTileCount()
    example_print_log("tileWidth=" .. ts:getTileWidth())
    example_print_log("tileHeight=" .. th)
    example_print_log("tileCount=" .. count)
end
```

---

#### `LTileSet:isSolid`

Checks whether a tile is marked as solid.

```lua
LTileSet:isSolid(tileId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tileId` | number | Tile ID to check (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the tile is solid. |

**Example**

```lua
do
    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 32, 8, 32, 32)
    ts:setSolid(1, true)
    ts:setSolid(2, false)
    example_print_log("tile 1 solid = " .. tostring(ts:isSolid(1)))
    example_print_log("tile 2 solid = " .. tostring(ts:isSolid(2)))
end
```

---

#### `LTileSet:setAnimation`

Assigns an animation sequence to a tile. Each frame references another tile ID and a duration.

```lua
LTileSet:setAnimation(tileId, frames)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tileId` | number | Tile ID to animate (1-based). |
| `frames` | table | Array of `{tileid=number, duration=number}` frame definitions. |

**Example**

```lua
do
    local ts = lurek.tilemap.newTileSet(1, 32, 8, 16, 16)
    ts:setAnimation(1, {
        { tileid = 1, duration = 200 },
        { tileid = 2, duration = 200 },
        { tileid = 3, duration = 200 },
        { tileid = 4, duration = 200 },
    })

    local anim = ts:getAnimation(1)
    example_print_log("animation frames = " .. #anim)
    for i, frame in ipairs(anim) do
        example_print_log("  frame " .. i .. ": tile=" .. frame.tileid .. " dur=" .. frame.duration)
    end
    local noAnim = ts:getAnimation(10)
    example_print_log("tile 10 anim = " .. tostring(noAnim))
end
```

---

#### `LTileSet:setAutoTileMode`

Sets the neighbor matching mode for a named auto-tile type.

```lua
LTileSet:setAutoTileMode(typeName, mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `typeName` | string | Logical tile type name. |
| `mode` | string | One of `"matchSides"`, `"matchCorners"`, `"matchCornersAndSides"`. |

**Example**

```lua
do
    local ts = lurek.tilemap.newTileSet(1, 64, 8, 16, 16)
    ts:setAutoTileRule8("shore", 255, 8)
    ts:setAutoTileMode("shore", "matchCornersAndSides")
    local mode = ts:getAutoTileMode("shore")
    example_print_log("shore mode = " .. mode)
end
```

---

#### `LTileSet:setAutoTileRule`

Registers a 4-bit auto-tile rule mapping a bitmask to a tile ID for a named tile type.

```lua
LTileSet:setAutoTileRule(typeName, bitmask, tileId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `typeName` | string | Logical tile type name (e.g. "grass"). |
| `bitmask` | number | 4-bit neighbor bitmask (0..15). |
| `tileId` | number | Tile ID to use for this bitmask (1-based). |

**Example**

```lua
do
    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 32, 8, 16, 16)
    ts:setAutoTileRule("grass", 0, 1)
    ts:setAutoTileRule("grass", 15, 16)
    local id = ts:getAutoTileId("grass", 0)
    example_print_log("bitmask 0 -> tile " .. id)
    example_print_log("bitmask 15 -> tile " .. ts:getAutoTileId("grass", 15))
end
```

---

#### `LTileSet:setAutoTileRule8`

Registers an 8-bit auto-tile rule mapping a bitmask to a tile ID for a named tile type.

```lua
LTileSet:setAutoTileRule8(typeName, bitmask, tileId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `typeName` | string | Logical tile type name. |
| `bitmask` | number | 8-bit neighbor bitmask (0..255). |
| `tileId` | number | Tile ID to use for this bitmask (1-based). |

**Example**

```lua
do
    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 256, 16, 16, 16)
    ts:setAutoTileRule8("wall", 0, 1)
    ts:setAutoTileRule8("wall", 255, 48)
    local id = ts:getAutoTileId8("wall", 0)
    example_print_log("8-bit bitmask 0 -> tile " .. id)
    example_print_log("8-bit bitmask 255 -> tile " .. ts:getAutoTileId8("wall", 255))
end
```

---

#### `LTileSet:setSolid`

Marks a tile as solid or non-solid for collision queries.

```lua
LTileSet:setSolid(tileId, solid)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tileId` | number | Tile ID to modify (1-based). |
| `solid` | boolean | Whether the tile blocks movement. |

**Example**

```lua
do
    ---@type LTileSet
    local ts = lurek.tilemap.newTileSet(1, 32, 8, 32, 32)
    ts:setSolid(1, true)
    ts:setSolid(2, false)
    local wall = ts:isSolid(1)
    example_print_log("tile 1 solid = " .. tostring(ts:isSolid(1)))
    example_print_log("tile 2 solid = " .. tostring(ts:isSolid(2)))
    example_print_log("wall collision flag = " .. tostring(wall))
end
```

---

#### `LTileSet:type`

Returns the type name of this userdata.

```lua
LTileSet:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always `"[LTileSet](#ltileset)"`. |

**Example**

```lua
do
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local count = ts:getTileCount()
    local columns = ts:getColumns()
    example_print_log("type=" .. ts:type())
    example_print_log("tileCount=" .. count)
    example_print_log("columns=" .. columns)
end
```

---

#### `LTileSet:typeOf`

Checks whether this object matches the given type name.

```lua
LTileSet:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check against. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if `name` is `"[LTileSet](#ltileset)"` or `"Object"`. |

**Example**

```lua
do
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    local is_tileset = ts:typeOf("LTileSet")
    local is_object = ts:typeOf("LObject")
    example_print_log("typeOf=" .. tostring(ts:typeOf("LTileSet")))
    example_print_log("as_tileset=" .. tostring(is_tileset))
    example_print_log("as_object=" .. tostring(is_object))
end
```

---
