# Tilelight

## Purpose

Tile-based environment lighting computed from a shared LTileField.

## When To Use

- It is environment-level data, not player-specific knowledge. Fog-of-war, action masks, and remembered exploration belong to awareness.
- It is tile-level gameplay/light data, not the screen/world render-light system. Render-facing lights and occluders remain in lurek.light.
- Point lights, ambient light, and global top light live on LTileLightMap so LTileField can remain a reusable source of gameplay data for many independent systems.

## Minimal Example

Example block: `lurek.tilelight.new`

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 1 })
    local light = lurek.tilelight.new(field)
    tilelight_log("tilelight type=" .. light:type())
end
```

## Common Patterns

- Start with `lurek.tilelight.compute` when exploring this module.
- Start with `lurek.tilelight.new` when exploring this module.

## API Reference

- This page is the generated API reference for this module.

## Summary

- The `tilelight` module owns light propagation over tile cells. It reads blockers, transmission costs, topology, and sun occlusion from `tilefield`, then produces computed RGB/luma layers.
- It is environment-level data, not player-specific knowledge. Fog-of-war, action masks, and remembered exploration belong to `awareness`.
- It is tile-level gameplay/light data, not the screen/world render-light system. Render-facing lights and occluders remain in `lurek.light`.
- Point lights, ambient light, and global top light live on `LTileLightMap` so `LTileField` can remain a reusable source of gameplay data for many independent systems.

This module primarily collaborates with `tilefield`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Functions

### `lurek.tilelight.compute`

Creates and computes a tile light map for a shared tilefield.

```lua
lurek.tilelight.compute(field, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `field` | [LTileField](#ltilefield) | Source tilefield. |
| `opts?` | table | Optional includePointLights, includeLineLights, includeSunLight/includeGlobalLight, ambient, and time settings. |

**Returns**

| Type | Description |
|------|-------------|
| [LTileLightMap](#ltilelightmap) | Computed tile light map handle. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 2, height = 2 })
    local light = lurek.tilelight.compute(field, { ambient = { r = 0.1, g = 0.1, b = 0.12 } })
    local _, _, _, luma = light:getLight(1, 1, 1)
    tilelight_log("ambient luma=" .. luma)
end
```

---

### `lurek.tilelight.new`

Creates a tile light map attached to a shared tilefield.

```lua
lurek.tilelight.new(field)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `field` | [LTileField](#ltilefield) | Source tilefield. |

**Returns**

| Type | Description |
|------|-------------|
| [LTileLightMap](#ltilelightmap) | New tile light map handle. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 1 })
    local light = lurek.tilelight.new(field)
    tilelight_log("tilelight type=" .. light:type())
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LTileField](#ltilefield)
- [LTileLightMap](#ltilelightmap)

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

---

#### `LTileField:clear`

Clears all cell gameplay state.

```lua
LTileField:clear()
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

---

#### `LTileLightMap:exportVolume`

Exports all computed light levels as nested row-major tables.

```lua
LTileLightMap:exportVolume()
```

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 3, height = 3, levels = 2 })
    field:setSunOcclusion(2, 2, 2, 0.5)
    local light = lurek.tilelight.new(field)
    light:setGlobalLight({ intensity = 0.4, color = { r = 1, g = 0.85, b = 0.55 } })
    light:compute({ includePointLights = false, includeGlobalLight = true })
    local layer = light:exportLayer(1)
    local volume = light:exportVolume()
    tilelight_log("layer cells=" .. #layer .. " levels=" .. #volume)
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
    local field = lurek.tilefield.new({ width = 6, height = 3 })
    field:setBlock(4, 2, 1, "light", true)
    local light = lurek.tilelight.new(field)
    light:addPointLight({ x = 2, y = 2, z = 1, radius = 5, intensity = 1, color = { r = 1, g = 0.6, b = 0.2 } })
    light:compute({ includePointLights = true, includeGlobalLight = false })
    local _, _, _, near = light:getLight(3, 2, 1)
    local _, _, _, blocked = light:getLight(6, 2, 1)
    tilelight_log("point light near=" .. near .. " blocked=" .. blocked)
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

---
