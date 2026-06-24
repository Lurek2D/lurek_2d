# Tilefield

## Purpose

Coordinates exposed to Lua are one-based x, y, z; Rust storage is zero-based.

## When To Use

- LTileField is a single field with width, height, and one or more levels. This is the default one-level map model.
- LTileFieldMap is a 2D or layered map of shared LTileField handles. Use it when a world is chunked into fields or stacked as layers of fields.
- Supported topologies are square, square4, square8, iso_square, and hex. square keeps the existing eight-way distance behavior, square4 uses Manhattan distance, and iso_square uses square gameplay math because projection belongs to tilemap/rendering.

## Minimal Example

Example block: `lurek.tilefield.new`

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 8, height = 8, levels = 2, topology = "square" })
    local w, h, levels = field:getSize()
    local topology = field:getTopology()
    local inside = field:inBounds(8, 8, 2)
    tilefield_log("new field " .. w .. "x" .. h .. "x" .. levels .. " " .. topology .. " inside=" .. tostring(inside))
end
```

## Common Patterns

- Start with `lurek.tilefield.fromTileMap` when exploring this module.
- Start with `lurek.tilefield.new` when exploring this module.
- Start with `lurek.tilefield.newFieldMap` when exploring this module.

## API Reference

- This page is the generated API reference for this module.

## Summary

- Coordinates exposed to Lua are one-based `x, y, z`; Rust storage is zero-based.
- `LTileField` is a single field with width, height, and one or more levels. This is the default one-level map model.
- `LTileFieldMap` is a 2D or layered map of shared `LTileField` handles. Use it when a world is chunked into fields or stacked as layers of fields.
- Supported topologies are `square`, `square4`, `square8`, `iso_square`, and `hex`. `square` keeps the existing eight-way distance behavior, `square4` uses Manhattan distance, and `iso_square` uses square gameplay math because projection belongs to tilemap/rendering.
- Channels are intentionally independent: seeing through a cell does not imply acting, moving, or lighting through it.
- Built-in profiles include `empty`, `wall`, `window`, `door_closed`, `door_open`, and `half_wall`.
- The `light` channel and `sunOcclusion` are environment inputs consumed by `lurek.tilelight`; `tilefield` does not store point lights or computed light values.
- Cell refs such as `floor`, `wall_left`, `roof`, or `object` are author-defined slots. They are useful for mapping tile ids, object ids, or block slots onto the same gameplay field without forcing every system to own separate data.

This module is mostly self-contained inside the Feature Systems group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Functions

### `lurek.tilefield.fromTileMap`

Copies a tilemap layer into a tilefield, optionally applying profiles and a ref slot.

```lua
lurek.tilefield.fromTileMap(tilemap, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tilemap` | [LTileMap](#ltilemap) | Source tilemap. |
| `opts?` | table | `{level?, topology?, solidProfile?, emptyProfile?, solidGids?, refSlot?}`; `solidGids` is explicit and no tileset solidity is inferred. |

**Returns**

| Type | Description |
|------|-------------|
| [LTileField](#ltilefield) | New tilefield copied from the tilemap layer. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local map = lurek.tilemap.newTileMap(16, 16)
    map:addLayer("ground", 4, 4)
    map:setTile(1, 2, 2, 9)
    local field = lurek.tilefield.fromTileMap(map, { layer = 1, solidGids = { 9 } })
    tilefield_log("tilemap copied, blocked=" .. tostring(field:blocks(2, 2, 1, "move")))
end
```

---

### `lurek.tilefield.new`

Creates a multi-level tilefield with explicit dimensions and topology.

```lua
lurek.tilefield.new(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | `{width, height, levels?, topology?}`. |

**Returns**

| Type | Description |
|------|-------------|
| [LTileField](#ltilefield) | New tilefield handle. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 8, height = 8, levels = 2, topology = "square" })
    local w, h, levels = field:getSize()
    local topology = field:getTopology()
    local inside = field:inBounds(8, 8, 2)
    tilefield_log("new field " .. w .. "x" .. h .. "x" .. levels .. " " .. topology .. " inside=" .. tostring(inside))
end
```

---

### `lurek.tilefield.newFieldMap`

Creates a 2D or layered map of shared tilefields.

```lua
lurek.tilefield.newFieldMap(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | `{width, height, layers?, fieldWidth, fieldHeight, fieldLevels?, topology?}`. |

**Returns**

| Type | Description |
|------|-------------|
| [LTileFieldMap](#ltilefieldmap) | New tilefield map handle. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local map = lurek.tilefield.newFieldMap({ width = 2, height = 2, layers = 2, fieldWidth = 4, fieldHeight = 4, topology = "square4" })
    local mw, mh, ml = map:getMapSize()
    local fw, fh = map:getFieldSize()
    local topology = map:getTopology()
    tilefield_log("fieldmap " .. mw .. "x" .. mh .. "x" .. ml .. " field=" .. fw .. "x" .. fh .. " topology=" .. topology)
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LTileField](#ltilefield)
- [LTileFieldMap](#ltilefieldmap)
- [LTileLightMap](#ltilelightmap)
- [LTileMap](#ltilemap)

## LTileField

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTileField:applyProfile`

Applies a named profile to one cell.

```lua
LTileField:applyProfile(x, y, z, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `name` | string | Profile name to apply to the cell. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:applyProfile(2, 2, 1, "window")
    local move = field:blocks(2, 2, 1, "move")
    local light = field:blocks(2, 2, 1, "light")
    tilefield_log("window move=" .. tostring(move) .. " light=" .. tostring(light))
end
```

---

#### `LTileField:applyTilesetProfile`

Applies the tilefield profile named by a tileset tile referenced from one cell.

```lua
LTileField:applyTilesetProfile(x, y, z, slot, tileset, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `slot` | string | Reference slot name. |
| `tileset` | [LTileSet](tilemap.md#ltileset) | Tileset that stores profile metadata. |
| `opts?` | table | Options: refIsGid. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a profile was found and applied. |

---

#### `LTileField:applyTilesetStats`

Applies tileset gameplay properties for a tile referenced from one cell.

```lua
LTileField:applyTilesetStats(x, y, z, slot, tileset, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `slot` | string | Reference slot name. |
| `tileset` | [LTileSet](tilemap.md#ltileset) | Tileset that stores object metadata. |
| `opts?` | table | Options: refIsGid. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when referenced tileset properties were found and applied. |

---

#### `LTileField:applyTilesetStatsLayer`

Applies tileset gameplay properties for every referenced cell on one tilefield level.

```lua
LTileField:applyTilesetStatsLayer(slot, tileset, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | string | Reference slot name. |
| `tileset` | [LTileSet](tilemap.md#ltileset) | Tileset that stores object metadata. |
| `opts?` | table | Options: z, refIsGid. |

**Returns**

| Type | Description |
|------|-------------|
| number | Number of cells that received at least one stat. |

---

#### `LTileField:blocks`

Returns whether a cell blocks a channel.

```lua
LTileField:blocks(x, y, z, channel)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `channel` | string | Blocker channel name to query. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the addressed cell blocks the channel. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:applyProfile(2, 2, 1, "window")
    local move = field:blocks(2, 2, 1, "move")
    local vision = field:blocks(2, 2, 1, "vision")
    tilefield_log("blocks move=" .. tostring(move) .. " vision=" .. tostring(vision))
end
```

---

#### `LTileField:clear`

Clears all cell gameplay state.

```lua
LTileField:clear()
```

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setBlock(2, 2, 1, "move", true)
    local before = field:blocks(2, 2, 1, "move")
    field:clear()
    tilefield_log("clear before=" .. tostring(before) .. " after=" .. tostring(field:blocks(2, 2, 1, "move")))
end
```

---

#### `LTileField:clearCell`

Clears gameplay state for one addressed cell.

```lua
LTileField:clearCell(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setBlock(2, 2, 1, "vision", true)
    field:setBlock(3, 2, 1, "vision", true)
    field:clearCell(2, 2, 1)
    tilefield_log("clearCell target=" .. tostring(field:blocks(2, 2, 1, "vision")) .. " neighbor=" .. tostring(field:blocks(3, 2, 1, "vision")))
end
```

---

#### `LTileField:clearLine`

Returns true when the line between two cell tables has no blocker for a channel.

```lua
LTileField:clearLine(from_tbl, to_tbl, channel, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from_tbl` | table | Start cell table with one-based x, y, and optional z fields. |
| `to_tbl` | table | End cell table with one-based x, y, and optional z fields. |
| `channel` | string | Blocker channel name to test along the line. |
| `opts?` | table | Reserved optional line query options. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when no blocker exists between the two cells. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 6, height = 3 })
    field:applyProfile(3, 2, 1, "window")
    local sight = field:clearLine({ x = 1, y = 2, z = 1 }, { x = 6, y = 2, z = 1 }, "vision")
    local action = field:clearLine({ x = 1, y = 2, z = 1 }, { x = 6, y = 2, z = 1 }, "action")
    tilefield_log("clearLine sight=" .. tostring(sight) .. " action=" .. tostring(action))
end
```

---

#### `LTileField:clearRef`

Clears a named object/tile reference from one cell.

```lua
LTileField:clearRef(x, y, z, slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `slot` | string | Reference slot name. |

---

#### `LTileField:exportBlockLayer`

Exports one blocker channel and level as a row-major boolean array.

```lua
LTileField:exportBlockLayer(channel, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `channel` | string | Blocker channel name to export. |
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| table | Row-major boolean array for the requested channel and level. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 3, height = 3 })
    field:applyProfile(2, 2, 1, "wall")
    local layer = field:exportBlockLayer("move", 1)
    local blocked = layer[5]
    tilefield_log("block layer center=" .. tostring(blocked))
end
```

---

#### `LTileField:exportCostLayer`

Exports one cost channel and level as a row-major number array.

```lua
LTileField:exportCostLayer(channel, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `channel` | string | Cost channel name to export. |
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| table | Row-major number array for the requested channel and level. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 3, height = 3 })
    field:setCost(2, 2, 1, "move", 7)
    local layer = field:exportCostLayer("move", 1)
    local center = layer[5]
    tilefield_log("cost layer center=" .. center)
end
```

---

#### `LTileField:exportProfileLayer`

Exports one level of profile names as a row-major array.

```lua
LTileField:exportProfileLayer(z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `z?` | number | One-based level, default 1. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 3, height = 3 })
    field:applyProfile(2, 2, 1, "window")
    local layer = field:exportProfileLayer(1)
    local center = layer[5]
    tilefield_log("profile layer center=" .. tostring(center))
end
```

---

#### `LTileField:exportRefLayer`

Exports one named object/tile reference slot and level as a row-major array.

```lua
LTileField:exportRefLayer(slot, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | string | Reference slot name to export. |
| `z?` | number | One-based level, default 1. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4, levels = 2 })
    field:setRef(2, 2, 1, "floor", 101)
    field:setRef(2, 2, 1, "wall_left", 210)
    local layer = field:exportRefLayer("wall_left", 1)
    tilefield_log("floor=" .. field:getRef(2, 2, 1, "floor") .. " wall_left=" .. tostring(layer[6]))
end
```

---

#### `LTileField:firstBlocker`

Returns the first one-based blocking cell table between two cells, or nil.

```lua
LTileField:firstBlocker(from_tbl, to_tbl, channel, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from_tbl` | table | Start cell table with one-based x, y, and optional z fields. |
| `to_tbl` | table | End cell table with one-based x, y, and optional z fields. |
| `channel` | string | Blocker channel name to test along the line. |
| `opts?` | table | Reserved optional line query options. |

**Returns**

| Type | Description |
|------|-------------|
| table | nil | First blocking cell table, or nil when the line is clear. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 6, height = 3 })
    field:applyProfile(4, 2, 1, "wall")
    local blocker = field:firstBlocker({ x = 1, y = 2, z = 1 }, { x = 6, y = 2, z = 1 }, "vision")
    local x = blocker and blocker.x or 0
    tilefield_log("first blocker x=" .. x)
end
```

---

#### `LTileField:getCell`

Returns a table with blockers, costs, sun occlusion, and optional profile name.

```lua
LTileField:getCell(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| table | Cell state table. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:applyProfile(2, 2, 1, "window")
    local cell = field:getCell(2, 2, 1)
    local move = cell.blocks.move
    local vision = cell.blocks.vision
    tilefield_log("cell move=" .. tostring(move) .. " vision=" .. tostring(vision))
end
```

---

#### `LTileField:getCost`

Returns the cost for one cell/channel.

```lua
LTileField:getCost(x, y, z, channel)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `channel` | string | Cost channel name to query. |

**Returns**

| Type | Description |
|------|-------------|
| number | Movement or traversal cost value. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    local base = field:getCost(1, 1, 1, "move")
    field:setCost(1, 2, 1, "move", 5)
    local changed = field:getCost(1, 2, 1, "move")
    tilefield_log("cost base=" .. base .. " changed=" .. changed)
end
```

---

#### `LTileField:getNeighbors`

Returns topology-aware same-level neighbours for one cell.

```lua
LTileField:getNeighbors(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of one-based coordinate tables. |

---

#### `LTileField:getProfile`

Returns a named object profile table, or nil when absent.

```lua
LTileField:getProfile(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Profile name to read. |

**Returns**

| Type | Description |
|------|-------------|
| table | nil | Profile table with blockers, costs, and sunOcclusion, or nil. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    local profile = field:getProfile("wall")
    local move = profile.blocks.move
    local vision = profile.blocks.vision
    tilefield_log("wall profile move=" .. tostring(move) .. " vision=" .. tostring(vision))
end
```

---

#### `LTileField:getRef`

Returns a named object/tile reference from one cell, or nil.

```lua
LTileField:getRef(x, y, z, slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `slot` | string | Reference slot name. |

**Returns**

| Type | Description |
|------|-------------|
| number | nil | Stored reference id, or nil when unset. |

---

#### `LTileField:getRefProperties`

Reads all tileset properties for a tile referenced from one cell.

```lua
LTileField:getRefProperties(x, y, z, slot, tileset, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `slot` | string | Reference slot name. |
| `tileset` | [LTileSet](tilemap.md#ltileset) | Tileset that stores object metadata. |
| `opts?` | table | Options: refIsGid. |

**Returns**

| Type | Description |
|------|-------------|
| table | nil | Property name/value table, or nil when the ref is missing/outside the tileset. |

---

#### `LTileField:getRefProperty`

Reads a tileset property for a tile referenced from one cell.

```lua
LTileField:getRefProperty(x, y, z, slot, tileset, property, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `slot` | string | Reference slot name. |
| `tileset` | [LTileSet](tilemap.md#ltileset) | Tileset that stores object metadata. |
| `property` | string | Property name to read. |
| `opts?` | table | Options: refIsGid. |

**Returns**

| Type | Description |
|------|-------------|
| string | nil | Property value, or nil when missing. |

---

#### `LTileField:getRefPropertyBool`

Reads a tileset property for a tile referenced from one cell and parses it as a boolean.

```lua
LTileField:getRefPropertyBool(x, y, z, slot, tileset, property, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `slot` | string | Reference slot name. |
| `tileset` | [LTileSet](tilemap.md#ltileset) | Tileset that stores object metadata. |
| `property` | string | Property name to read. |
| `opts?` | table | Options: refIsGid. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | nil | Boolean property value, or nil when missing/not boolean. |

---

#### `LTileField:getRefPropertyNumber`

Reads a tileset property for a tile referenced from one cell and parses it as a number.

```lua
LTileField:getRefPropertyNumber(x, y, z, slot, tileset, property, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `slot` | string | Reference slot name. |
| `tileset` | [LTileSet](tilemap.md#ltileset) | Tileset that stores object metadata. |
| `property` | string | Property name to read. |
| `opts?` | table | Options: refIsGid. |

**Returns**

| Type | Description |
|------|-------------|
| number | nil | Numeric property value, or nil when missing/not numeric. |

---

#### `LTileField:getRefSlots`

Returns every named ref slot currently used by this field.

```lua
LTileField:getRefSlots()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Ref slot names. |

---

#### `LTileField:getRegionCells`

Returns one-based cells for a named region, or nil when it does not exist.

```lua
LTileField:getRegionCells(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Region name. |

**Returns**

| Type | Description |
|------|-------------|
| table? | Array of `{ x, y, z }` cells. |

---

#### `LTileField:getRegionNames`

Returns all region names in stable order.

```lua
LTileField:getRegionNames()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of region names. |

---

#### `LTileField:getSize`

Returns field width, height, and level count.

```lua
LTileField:getSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Field width in cells. |
| number | Field height in cells. |
| number | Level count. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 10, height = 6, levels = 3 })
    local width, height, levels = field:getSize()
    local cells = width * height * levels
    local valid = cells == 180
    tilefield_log("field cells=" .. cells .. " valid=" .. tostring(valid))
end
```

---

#### `LTileField:getSunOcclusion`

Returns top-light occlusion in the inclusive range 0..1.

```lua
LTileField:getSunOcclusion(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| number | Top-light occlusion value in the inclusive range 0..1. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 2, height = 2 })
    field:setSunOcclusion(1, 1, 1, 0.3)
    local value = field:getSunOcclusion(1, 1, 1)
    local default = field:getSunOcclusion(2, 2, 1)
    tilefield_log("sun values=" .. value .. "," .. default)
end
```

---

#### `LTileField:getTopology`

Returns the field topology name used for coordinate interpretation.

```lua
LTileField:getTopology()
```

**Returns**

| Type | Description |
|------|-------------|
| string | `square`, `square4`, `square8`, `iso_square`, or `hex`. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 5, height = 5, topology = "iso_square" })
    local topology = field:getTopology()
    local same_logic = topology == "iso_square"
    local line = field:line({ from = { x = 1, y = 1, z = 1 }, to = { x = 3, y = 1, z = 1 } })
    tilefield_log("topology=" .. topology .. " line=" .. #line .. " same=" .. tostring(same_logic))
end
```

---

#### `LTileField:inBounds`

Returns whether one-based coordinates are inside the field.

```lua
LTileField:inBounds(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when coordinates are in bounds. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 3, height = 3, levels = 2 })
    local a = field:inBounds(1, 1, 1)
    local b = field:inBounds(4, 1, 1)
    local c = field:inBounds(3, 3, 2)
    tilefield_log("bounds " .. tostring(a) .. "," .. tostring(b) .. "," .. tostring(c))
end
```

---

#### `LTileField:line`

Returns topology-aware one-based cells between `from` and `to` tables.

```lua
LTileField:line(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | `{from={x,y,z?}, to={x,y,z?}, includeEndpoints?}`. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 6, height = 6 })
    local line = field:line({ from = { x = 1, y = 1, z = 1 }, to = { x = 5, y = 1, z = 1 } })
    local first = line[1].x
    local last = line[#line].x
    tilefield_log("line first=" .. first .. " last=" .. last .. " count=" .. #line)
end
```

---

#### `LTileField:regionContains`

Returns whether a named region contains a one-based tile cell.

```lua
LTileField:regionContains(name, x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Region name. |
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the region contains the cell. |

---

#### `LTileField:removeProfile`

Removes a named object profile from the tilefield profile registry.

```lua
LTileField:removeProfile(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Profile name to remove. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setProfile("temporary", { blocks = { move = true } })
    field:removeProfile("temporary")
    local missing = field:getProfile("temporary") == nil
    tilefield_log("profile removed=" .. tostring(missing))
end
```

---

#### `LTileField:removeRegion`

Removes a named region.

```lua
LTileField:removeRegion(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Region name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the region existed. |

---

#### `LTileField:setBlock`

Sets whether a cell blocks a channel.

```lua
LTileField:setBlock(x, y, z, channel, blocked)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `channel` | string | Blocker channel name to update. |
| `blocked` | boolean | True when the channel should be blocked. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setBlock(2, 2, 1, "move", true)
    field:setBlock(2, 2, 1, "vision", false)
    local move = field:blocks(2, 2, 1, "move")
    tilefield_log("setBlock move=" .. tostring(move))
end
```

---

#### `LTileField:setCell`

Sets cell state from a table with optional `blocks`, `costs`, `sunOcclusion`, and `profile`.

```lua
LTileField:setCell(x, y, z, cell)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `cell` | table | Cell data. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setCell(2, 2, 1, { blocks = { action = true }, costs = { move = 3 }, sunOcclusion = 0.25 })
    local action = field:blocks(2, 2, 1, "action")
    local cost = field:getCost(2, 2, 1, "move")
    tilefield_log("setCell action=" .. tostring(action) .. " cost=" .. cost)
end
```

---

#### `LTileField:setCost`

Sets the cost for one cell/channel.

```lua
LTileField:setCost(x, y, z, channel, cost)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `channel` | string | Cost channel name to update. |
| `cost` | number | Movement or traversal cost value. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setCost(2, 2, 1, "move", 4)
    field:setCost(2, 3, 1, "move", 2)
    local a = field:getCost(2, 2, 1, "move")
    tilefield_log("setCost high=" .. a)
end
```

---

#### `LTileField:setProfile`

Registers or replaces a named object profile.

```lua
LTileField:setProfile(name, profile_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Profile name to create or replace. |
| `profile_tbl` | table | Profile table with blockers, costs, and sunOcclusion fields. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setProfile("bars", { blocks = { move = true, vision = false, action = true }, sunOcclusion = 0.1 })
    field:applyProfile(2, 2, 1, "bars")
    local visible = not field:blocks(2, 2, 1, "vision")
    tilefield_log("custom bars visible=" .. tostring(visible))
end
```

---

#### `LTileField:setRef`

Sets a named object/tile reference on one cell.

```lua
LTileField:setRef(x, y, z, slot, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `slot` | string | Reference slot name defined by the Lua game. |
| `value` | number | Object, tile, or tileset-local id stored for the slot. |

---

#### `LTileField:setRegionCells`

Defines or replaces a named region from explicit one-based tile cells.

```lua
LTileField:setRegionCells(name, cells)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Region name. |
| `cells` | table | Array of `{ x, y, z? }` cells. |

---

#### `LTileField:setRegionRect`

Defines or replaces a named region from an inclusive one-based tile rectangle.

```lua
LTileField:setRegionRect(name, x1, y1, x2, y2, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Region name. |
| `x1` | number | First one-based column. |
| `y1` | number | First one-based row. |
| `x2` | number | Second one-based column. |
| `y2` | number | Second one-based row. |
| `z?` | number | One-based level, default 1. |

---

#### `LTileField:setSunOcclusion`

Sets top-light occlusion in the inclusive range 0..1.

```lua
LTileField:setSunOcclusion(x, y, z, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `value` | number | Top-light occlusion value in the inclusive range 0..1. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 2, height = 2, levels = 2 })
    field:setSunOcclusion(1, 1, 2, 0.5)
    tilefield_log("sun occlusion=" .. field:getSunOcclusion(1, 1, 2))
end
```

---

#### `LTileField:type`

Returns the Lua-visible type name for this tilefield handle.

```lua
LTileField:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LTileField](#ltilefield)`. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 2, height = 2 })
    local type_name = field:type()
    local expected = type_name == "LTileField"
    local object = field:typeOf("LObject")
    tilefield_log("type=" .. type_name .. " ok=" .. tostring(expected) .. " object=" .. tostring(object))
end
```

---

#### `LTileField:typeOf`

Returns whether this handle matches a supported type name.

```lua
LTileField:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True for `[LTileField](#ltilefield)` or `LObject`. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 2, height = 2 })
    local exact = field:typeOf("LTileField")
    local object = field:typeOf("LObject")
    local miss = field:typeOf("LNavGrid")
    tilefield_log("typeOf exact=" .. tostring(exact) .. " object=" .. tostring(object) .. " miss=" .. tostring(miss))
end
```

---

#### `LTileField:writeBlockLayer`

Writes one full blocker channel layer from a row-major boolean array.

```lua
LTileField:writeBlockLayer(channel, z, values)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `channel` | string | Blocker channel name to write. |
| `z?` | number | One-based level, default 1. |
| `values` | table | Row-major boolean array with width*height entries. |

---

#### `LTileField:writeCostLayer`

Writes one full cost channel layer from a row-major number array.

```lua
LTileField:writeCostLayer(channel, z, values)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `channel` | string | Cost channel name to write. |
| `z?` | number | One-based level, default 1. |
| `values` | table | Row-major number array with width*height entries. |

---

#### `LTileField:writeProfileLayer`

Writes one full profile-name layer from a row-major string-or-nil array.

```lua
LTileField:writeProfileLayer(z, values)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `z?` | number | One-based level, default 1. |
| `values` | table | Row-major string-or-nil array with width*height entries. |

---

#### `LTileField:writeRefLayer`

Writes one full named ref layer from a row-major integer-or-nil array.

```lua
LTileField:writeRefLayer(slot, z, values)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | string | Reference slot name to write. |
| `z?` | number | One-based level, default 1. |
| `values` | table | Row-major integer-or-nil array with width*height entries. |

---

## LTileFieldMap

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTileFieldMap:getField`

Returns the shared tilefield at one field-map coordinate.

```lua
LTileFieldMap:getField(mapX, mapY, mapZ)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mapX` | number | One-based field-map column. |
| `mapY` | number | One-based field-map row. |
| `mapZ?` | number | One-based field-map layer, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| [LTileField](#ltilefield) | Shared tilefield handle. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local map = lurek.tilefield.newFieldMap({ width = 2, height = 2, layers = 2, fieldWidth = 3, fieldHeight = 3 })
    local field = map:getField(2, 2, 2)
    field:setRef(1, 1, 1, "floor", 12)
    local shared = map:getField(2, 2, 2):getRef(1, 1, 1, "floor")
    tilefield_log("shared field ref=" .. tostring(shared))
end
```

---

#### `LTileFieldMap:getFieldSize`

Returns contained field width, height, and level count.

```lua
LTileFieldMap:getFieldSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Contained field width in cells. |
| number | Contained field height in cells. |
| number | Contained field level count. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local map = lurek.tilefield.newFieldMap({ width = 1, height = 1, fieldWidth = 8, fieldHeight = 6, fieldLevels = 2 })
    local width, height, levels = map:getFieldSize()
    local cells = width * height * levels
    local field = map:getField(1, 1, 1)
    tilefield_log("field cells=" .. cells .. " type=" .. field:type())
end
```

---

#### `LTileFieldMap:getMapSize`

Returns field-map width, height, and layer count.

```lua
LTileFieldMap:getMapSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Field-map width in field slots. |
| number | Field-map height in field slots. |
| number | Field-map layer count. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local map = lurek.tilefield.newFieldMap({ width = 3, height = 2, layers = 1, fieldWidth = 4, fieldHeight = 4 })
    local width, height, layers = map:getMapSize()
    local slots = width * height * layers
    local valid = slots == 6
    tilefield_log("map slots=" .. slots .. " valid=" .. tostring(valid))
end
```

---

#### `LTileFieldMap:getTopology`

Returns the topology shared by every contained field.

```lua
LTileFieldMap:getTopology()
```

**Returns**

| Type | Description |
|------|-------------|
| string | `square`, `square4`, `square8`, `iso_square`, or `hex`. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local map = lurek.tilefield.newFieldMap({ width = 1, height = 1, fieldWidth = 4, fieldHeight = 4, topology = "hex" })
    local topology = map:getTopology()
    local field = map:getField(1, 1, 1)
    local same = field:getTopology() == topology
    tilefield_log("fieldmap topology=" .. topology .. " same=" .. tostring(same))
end
```

---

#### `LTileFieldMap:inBounds`

Returns whether one-based field-map coordinates are inside the field map.

```lua
LTileFieldMap:inBounds(mapX, mapY, mapZ)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mapX` | number | One-based field-map column. |
| `mapY` | number | One-based field-map row. |
| `mapZ?` | number | One-based field-map layer, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when coordinates are in bounds. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local map = lurek.tilefield.newFieldMap({ width = 2, height = 2, layers = 2, fieldWidth = 3, fieldHeight = 3 })
    local inside = map:inBounds(2, 2, 2)
    local outside = map:inBounds(3, 1, 1)
    local default_layer = map:inBounds(1, 1)
    tilefield_log("fieldmap bounds=" .. tostring(inside) .. "," .. tostring(outside) .. "," .. tostring(default_layer))
end
```

---

#### `LTileFieldMap:setField`

Replaces one field-map slot with an existing compatible tilefield handle.

```lua
LTileFieldMap:setField(mapX, mapY, mapZ, field)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mapX` | number | One-based field-map column. |
| `mapY` | number | One-based field-map row. |
| `mapZ?` | number | One-based field-map layer, default 1. |
| `field` | [LTileField](#ltilefield) | Existing compatible tilefield handle. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local map = lurek.tilefield.newFieldMap({ width = 1, height = 1, layers = 1, fieldWidth = 3, fieldHeight = 3, topology = "square8" })
    local field = lurek.tilefield.new({ width = 3, height = 3, topology = "square8" })
    field:setRef(2, 2, 1, "object", 90)
    map:setField(1, 1, 1, field)
    tilefield_log("stored object=" .. tostring(map:getField(1, 1, 1):getRef(2, 2, 1, "object")))
end
```

---

#### `LTileFieldMap:type`

Returns the Lua-visible type name for this tilefield map handle.

```lua
LTileFieldMap:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LTileFieldMap](#ltilefieldmap)`. |

---

#### `LTileFieldMap:typeOf`

Returns whether this handle matches a supported type name.

```lua
LTileFieldMap:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True for `[LTileFieldMap](#ltilefieldmap)` or `LObject`. |

---

## LTileLightMap

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTileLightMap:addLineLight`

Adds a tile line light and returns its stable id.

```lua
LTileLightMap:addLineLight(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | `{x1,y1,z1?,x2,y2,z2?,radius,intensity?,color?,flicker?,colorCycle?}`. |

---

#### `LTileLightMap:addPointLight`

Adds a point light and returns its stable id.

```lua
LTileLightMap:addPointLight(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | `{x, y, z?, radius, intensity?, color?, flicker?, colorCycle?}` light definition. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 5, height = 5 })
    local light = lurek.tilelight.new(field)
    local id = light:addPointLight({ x = 2, y = 2, z = 1, radius = 4, intensity = 1 })
    light:compute({ includePointLights = true })
    local _, _, _, luma = light:getLight(2, 2, 1)
    tilefield_log("light id=" .. id .. " luma=" .. luma)
end
```

---

#### `LTileLightMap:clearLineLights`

Removes all line lights currently stored on this tile light map.

```lua
LTileLightMap:clearLineLights()
```

---

#### `LTileLightMap:clearPointLights`

Removes all point lights currently stored on this tile light map.

```lua
LTileLightMap:clearPointLights()
```

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 5, height = 5 })
    local light = lurek.tilelight.new(field)
    light:addPointLight({ x = 1, y = 1, z = 1, radius = 2 })
    light:clearPointLights()
    light:compute({ includePointLights = true })
    tilefield_log("point lights cleared")
end
```

---

#### `LTileLightMap:compute`

Computes tile light from ambient, point lights, line lights, and sun light.

```lua
LTileLightMap:compute(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | table | Optional includePointLights, includeLineLights, includeSunLight/includeGlobalLight, ambient, and time settings. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 6, height = 4 })
    field:setProfile("smoked_glass", {
        blocks = { light = false, vision = false, move = true, action = true },
        costs = { light = 0.5 },
        sunOcclusion = 0.25,
    })
    field:applyProfile(4, 2, 1, "smoked_glass")
    local light = lurek.tilelight.new(field)
    light:addPointLight({ x = 2, y = 2, z = 1, radius = 5, color = { r = 1, g = 0.35, b = 0.1 } })
    light:compute({ includePointLights = true, ambient = { r = 0.02, g = 0.02, b = 0.02 } })
    local r, g, b, luma = light:getLight(6, 2, 1)
    tilefield_log("filtered rgb=" .. (r + g + b) .. " luma=" .. luma)
end
```

---

#### `LTileLightMap:exportLayer`

Exports one level of computed light as row-major `{r,g,b,luma}` tables.

```lua
LTileLightMap:exportLayer(z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `z?` | number | One-based level, default 1. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 3, height = 3 })
    local light = lurek.tilelight.new(field)
    light:compute({ ambient = { r = 0.1, g = 0.1, b = 0.1 } })
    local layer = light:exportLayer(1)
    local count = #layer
    tilefield_log("light layer count=" .. count .. " first=" .. layer[1].luma)
end
```

---

#### `LTileLightMap:exportVolume`

Exports all computed light levels as nested row-major tables.

```lua
LTileLightMap:exportVolume()
```

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 2, height = 2, levels = 2 })
    local light = lurek.tilelight.new(field)
    light:compute({ ambient = { r = 0.05, g = 0.05, b = 0.05 } })
    local volume = light:exportVolume()
    local levels = #volume
    tilefield_log("light volume levels=" .. levels .. " cells=" .. #volume[1])
end
```

---

#### `LTileLightMap:getLight`

Returns r, g, b, and luma for one cell.

```lua
LTileLightMap:getLight(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based cell x coordinate. |
| `y` | number | One-based cell y coordinate. |
| `z?` | number | One-based level, default 1. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    local light = lurek.tilelight.new(field)
    light:compute({ ambient = { r = 0.1, g = 0.1, b = 0.1 } })
    local r, g, b, luma = light:getLight(1, 1, 1)
    local rgb = r + g + b
    tilefield_log("light rgb=" .. rgb .. " luma=" .. luma)
end
```

---

#### `LTileLightMap:getSize`

Returns light-map width, height, and level count.

```lua
LTileLightMap:getSize()
```

---

#### `LTileLightMap:removeLineLight`

Removes a line light by id and returns whether it existed.

```lua
LTileLightMap:removeLineLight(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | any |  |

---

#### `LTileLightMap:removePointLight`

Removes a point light by id and returns whether it existed.

```lua
LTileLightMap:removePointLight(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Stable point light id returned by `addPointLight`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a point light was removed. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 5, height = 5 })
    local light = lurek.tilelight.new(field)
    local id = light:addPointLight({ x = 1, y = 1, z = 1, radius = 2 })
    local removed = light:removePointLight(id)
    light:compute({ includePointLights = true })
    tilefield_log("removed=" .. tostring(removed))
end
```

---

#### `LTileLightMap:setAmbient`

Sets ambient tile light stored on this light map.

```lua
LTileLightMap:setAmbient(color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `color` | table | `{r,g,b}` ambient color. |

---

#### `LTileLightMap:setGlobalLight`

Sets top-down global light parameters used during light computation.

```lua
LTileLightMap:setGlobalLight(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | `{intensity?, color?}` global top-light settings. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 2, height = 2, levels = 2 })
    local light = lurek.tilelight.new(field)
    light:setGlobalLight({ intensity = 0.35, color = { r = 1, g = 0.95, b = 0.8 } })
    light:compute({ includeGlobalLight = true })
    local _, _, _, luma = light:getLight(1, 1, 2)
    tilefield_log("global luma=" .. luma)
end
```

---

#### `LTileLightMap:setSunLight`

Sets tile sun light parameters used during light computation.

```lua
LTileLightMap:setSunLight(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | 'directional', intensity?, color?, direction?}`. |

---

#### `LTileLightMap:type`

Returns the Lua-visible type name for this tile light map handle.

```lua
LTileLightMap:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LTileLightMap](#ltilelightmap)`. |

---

#### `LTileLightMap:typeOf`

Returns whether this handle matches a supported type name.

```lua
LTileLightMap:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True for `[LTileLightMap](#ltilelightmap)` or `LObject`. |

---

#### `LTileLightMap:updateLineLight`

Updates an existing tile line light by id.

```lua
LTileLightMap:updateLineLight(id, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Stable line light id returned by `addLineLight`. |
| `opts` | table | Partial line light update. |

---

#### `LTileLightMap:updatePointLight`

Updates an existing point light by id.

```lua
LTileLightMap:updatePointLight(id, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Stable point light id returned by `addPointLight`. |
| `opts` | table | Partial light update table with x, y, z, radius, intensity, or color. |

**Example**

```lua
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 5, height = 5 })
    local light = lurek.tilelight.new(field)
    local id = light:addPointLight({ x = 1, y = 1, z = 1, radius = 2 })
    light:updatePointLight(id, { x = 3, y = 3, radius = 4, intensity = 0.5 })
    light:compute({ includePointLights = true })
    tilefield_log("updated light at center")
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

---

#### `LTileMap:addTileSet`

Attaches a tileset to this map for tile rendering.

```lua
LTileMap:addTileSet(tileSet)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tileSet` | [LTileSet](tilemap.md#ltileset) | Tileset to add. |

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

---

#### `LTileMap:getDiagnostics`

Returns tilemap diagnostics counters for invalid calls, unknown gids, and lazy index rebuilds.

```lua
LTileMap:getDiagnostics()
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
| [LTileSet](tilemap.md#ltileset) | The tileset, or nil if index is out of range. |

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

---
