# Tilelight

## Purpose

Tile-based environment lighting computed from a shared LTileField.

## Summary

- The `tilelight` module owns light propagation over tile cells. It reads blockers, transmission costs, topology, and sun occlusion from `tilefield`, then produces computed RGB/luma layers.
- It is environment-level data, not player-specific knowledge. Fog-of-war, action masks, and remembered exploration belong to `awareness`.
- It is tile-level gameplay/light data, not the screen/world render-light system. Render-facing lights and occluders remain in `lurek.light`.
- Point lights, ambient light, and global top light live on `LTileLightMap` so `LTileField` can remain a reusable source of gameplay data for many independent systems.

This module primarily collaborates with `tilefield`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## API Reference

- This page is the generated API reference for this module.

## Functions

### `lurek.tilelight.compute`

Creates and computes a tile light map for a shared tilefield or Lua tilefield provider table.

```lua
lurek.tilelight.compute(field, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `field` | [LTileField](#ltilefield)|table | Source tilefield handle or provider table. |
| `opts?` | table | Optional includePointLights, includeLineLights, includeSunLight, ambient, and time settings. |

**Returns**

| Type | Description |
|------|-------------|
| [LTileLightMap](#ltilelightmap) | Computed tile light map handle. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        local made = lurek.tilelight.compute(field, { ambient = { r = 0.1, g = 0.1, b = 0.12 } })
        local _, _, _, luma = made:getLight(1, 1, 1)
        return luma
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

### `lurek.tilelight.new`

Creates a tile light map attached to a shared tilefield or copied from a Lua tilefield provider table.

```lua
lurek.tilelight.new(field)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `field` | [LTileField](#ltilefield)|table | Source tilefield handle or provider table. |

**Returns**

| Type | Description |
|------|-------------|
| [LTileLightMap](#ltilelightmap) | New tile light map handle. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        local made = lurek.tilelight.new(field)
        return made:type()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
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

#### `LTileField:applyModifier`

Applies a named modifier to one cell.

```lua
LTileField:applyModifier(x, y, z, modifier)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `modifier` | string | Modifier name. |

---

#### `LTileField:applyProfile`

Applies a legacy profile to one cell.

```lua
LTileField:applyProfile(x, y, z, profile)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `profile` | string | Profile name. |

---

#### `LTileField:applyTilesetObject`

Applies the object archetype defaults for a tileset tile referenced from one cell.

```lua
LTileField:applyTilesetObject(x, y, z, slot, tileset, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `slot` | string | Reference slot name. |
| `tileset` | [LTileSet](tileset.md#ltileset) | Tileset that stores object archetype metadata. |
| `opts?` | table | Options: refIsGid. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the tileset object was found and applied. |

---

#### `LTileField:applyTilesetObjectLayer`

Applies tileset object defaults for every referenced cell on one tilefield level.

```lua
LTileField:applyTilesetObjectLayer(slot, tileset, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | string | Reference slot name. |
| `tileset` | [LTileSet](tileset.md#ltileset) | Tileset that stores object metadata. |
| `opts?` | table | Options: z, refIsGid. |

**Returns**

| Type | Description |
|------|-------------|
| number | Number of cells that received object defaults. |

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

#### `LTileField:blocksCategory`

Returns whether one cell blocks a category.

```lua
LTileField:blocksCategory(x, y, z, category)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `category` | any |  |

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

#### `LTileField:clearModifier`

Removes one modifier from one cell.

```lua
LTileField:clearModifier(x, y, z, modifier)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `modifier` | string | Modifier name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the cell had the modifier. |

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

#### `LTileField:defineCategory`

Defines or replaces a user category used by movement, awareness, light, sun, or custom systems.

```lua
LTileField:defineCategory(name, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Stable category name. |
| `opts?` | table?|Options | custom', active=true?. |

---

#### `LTileField:defineSlot`

Defines a named object slot that cells may reference.

```lua
LTileField:defineSlot(slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | string | Slot name chosen by the Lua game. |

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

#### `LTileField:footprintPassable`

Returns whether a rectangular footprint can occupy a cell anchor for a category.

```lua
LTileField:footprintPassable(x, y, z, w, h, category)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `w` | any |  |
| `h` | any |  |
| `category` | any |  |

---

#### `LTileField:getCategories`

Returns known category names.

```lua
LTileField:getCategories()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Sorted category names. |

---

#### `LTileField:getCategory`

Returns category metadata, or nil when the category is unknown.

```lua
LTileField:getCategory(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Category name. |

**Returns**

| Type | Description |
|------|-------------|
| table | nil | Category table with name, kind, and active. |

---

#### `LTileField:getCategoryCost`

Returns one effective category cost.

```lua
LTileField:getCategoryCost(x, y, z, category)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `category` | any |  |

---

#### `LTileField:getCategoryFilter`

Returns one effective RGB category filter.

```lua
LTileField:getCategoryFilter(x, y, z, category)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `category` | any |  |

---

#### `LTileField:getCategoryTransmission`

Returns one effective category transmission multiplier.

```lua
LTileField:getCategoryTransmission(x, y, z, category)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `category` | any |  |

---

#### `LTileField:getCell`

Returns a table with blockers, costs, sun occlusion, refs, and modifiers.

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

#### `LTileField:getModifier`

Returns a named tile modifier table, or nil.

```lua
LTileField:getModifier(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Modifier name. |

**Returns**

| Type | Description |
|------|-------------|
| table | nil | Modifier table. |

---

#### `LTileField:getModifiers`

Returns active modifier names on one cell.

```lua
LTileField:getModifiers(x, y, z)
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
| string[] | Active modifier names. |

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

Returns a legacy profile table, or nil.

```lua
LTileField:getProfile(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Profile name. |

**Returns**

| Type | Description |
|------|-------------|
| table | nil | Profile table. |

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
| number | table|nil | Stored legacy id, typed ref table, or nil when unset. |

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
| `tileset` | [LTileSet](tileset.md#ltileset) | Tileset that stores object metadata. |
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
| `tileset` | [LTileSet](tileset.md#ltileset) | Tileset that stores object metadata. |
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
| `tileset` | [LTileSet](tileset.md#ltileset) | Tileset that stores object metadata. |
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
| `tileset` | [LTileSet](tileset.md#ltileset) | Tileset that stores object metadata. |
| `property` | string | Property name to read. |
| `opts?` | table | Options: refIsGid. |

**Returns**

| Type | Description |
|------|-------------|
| number | nil | Numeric property value, or nil when missing/not numeric. |

---

#### `LTileField:getRefSlots`

Returns every declared ref slot.

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

#### `LTileField:getVersion`

Returns the current tilefield data version.

```lua
LTileField:getVersion()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Monotonic field version incremented by data mutations. |

---

#### `LTileField:hasSlot`

Returns true when a named object slot is declared.

```lua
LTileField:hasSlot(slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | string | Slot name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when declared. |

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

#### `LTileField:removeModifier`

Removes a named modifier and clears it from all cells.

```lua
LTileField:removeModifier(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Modifier name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when removed. |

---

#### `LTileField:removeProfile`

Removes a legacy profile and clears it from all cells.

```lua
LTileField:removeProfile(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Profile name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when removed. |

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

#### `LTileField:removeSlot`

Removes a named object slot and clears its references from the field.

```lua
LTileField:removeSlot(slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | string | Slot name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the slot existed. |

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

#### `LTileField:setCategoryBlock`

Sets one category blocker on one cell.

```lua
LTileField:setCategoryBlock(x, y, z, category, blocked)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `category` | any |  |
| `blocked` | any |  |

---

#### `LTileField:setCategoryCost`

Sets one category cost on one cell.

```lua
LTileField:setCategoryCost(x, y, z, category, cost)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `category` | any |  |
| `cost` | any |  |

---

#### `LTileField:setCategoryFilter`

Sets one RGB category filter on one cell.

```lua
LTileField:setCategoryFilter(x, y, z, category, filter)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `category` | any |  |
| `filter` | any |  |

---

#### `LTileField:setCategoryTransmission`

Sets one category transmission multiplier on one cell.

```lua
LTileField:setCategoryTransmission(x, y, z, category, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `category` | any |  |
| `value` | any |  |

---

#### `LTileField:setCell`

Sets cell state from a table with optional `blocks`, `costs`, `sunOcclusion`, `refs`, and `modifiers`.

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

#### `LTileField:setModifier`

Registers or replaces a named tile modifier.

```lua
LTileField:setModifier(name, modifier)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Modifier name. |
| `modifier` | table | Modifier table with blocks, costAdd, costMul, sunOcclusionAdd, light, properties. |

---

#### `LTileField:setProfile`

Registers or replaces a legacy tilefield profile.

```lua
LTileField:setProfile(name, profile)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Profile name. |
| `profile` | table | Profile table with blocks, costs, sunOcclusion, light, or properties. |

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
| `value` | number|table | Legacy id or typed `{ tileset, tile?/object? }` ref stored for the slot. |

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

#### `LTileLightMap:addAreaLight`

Adds a rectangular area light and returns its stable id.

```lua
LTileLightMap:addAreaLight(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | h,radius,intensity?,color?,flicker?,colorCycle?}`. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        return light:addAreaLight({ x = 2, y = 2, z = 1, width = 2, height = 2, radius = 2 })
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:addLineLight`

Adds a tile line light and returns its stable id.

```lua
LTileLightMap:addLineLight(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | `{x1,y1,z1?,x2,y2,z2?,radius,intensity?,color?,flicker?,colorCycle?}`. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        return light:addLineLight({ x1 = 1, y1 = 2, x2 = 6, y2 = 2, z1 = 1, z2 = 1, radius = 1.5 })
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

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
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        return light:addPointLight({ x = 2, y = 2, z = 1, radius = 3, intensity = 1 })
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:addRectLight`

Alias for `addAreaLight`.

```lua
LTileLightMap:addRectLight(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | h,radius,intensity?,color?,flicker?,colorCycle?}`. |

**Returns**

| Type | Description |
|------|-------------|
| number | Stable rectangular light id. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        return light:addRectLight({ x = 2, y = 2, z = 1, w = 2, h = 2, radius = 2 })
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:clearAreaLights`

Removes all rectangular area lights currently stored on this tile light map.

```lua
LTileLightMap:clearAreaLights()
```

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        light:addAreaLight({ x = 2, y = 2, z = 1, width = 2, height = 2, radius = 2 })
        light:clearAreaLights()
        return light:type()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:clearLineLights`

Removes all line lights currently stored on this tile light map.

```lua
LTileLightMap:clearLineLights()
```

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        light:addLineLight({ x1 = 1, y1 = 2, x2 = 6, y2 = 2, z1 = 1, z2 = 1, radius = 1.5 })
        light:clearLineLights()
        return light:type()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
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
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        light:addPointLight({ x = 2, y = 2, z = 1, radius = 2 })
        light:clearPointLights()
        return light:type()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:clearRectLights`

Alias for `clearAreaLights`.

```lua
LTileLightMap:clearRectLights()
```

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        light:addRectLight({ x = 2, y = 2, z = 1, w = 2, h = 2, radius = 2 })
        light:clearRectLights()
        return light:type()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
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
| `opts?` | table | Optional includePointLights, includeLineLights, includeAreaLights, includeSunLight, ambient, and time settings. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        light:addPointLight({ x = 2, y = 2, z = 1, radius = 3, intensity = 1 })
        light:compute({ includePointLights = true, includeSunLight = false })
        return light:getLight(2, 2, 1)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
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

**Returns**

| Type | Description |
|------|-------------|
| table | Row-major array of light color tables for the requested level. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        light:setAmbient({ r = 0.1, g = 0.1, b = 0.1 })
        light:compute({ includeSunLight = false })
        return #light:exportLayer(1)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:exportVolume`

Exports all computed light levels as nested row-major tables.

```lua
LTileLightMap:exportVolume()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of exported light layers, one table per level. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        light:setAmbient({ r = 0.1, g = 0.1, b = 0.1 })
        light:compute({ includeSunLight = false })
        return #light:exportVolume()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
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

**Returns**

| Type | Description |
|------|-------------|
| number | Red; green; blue; and luma values for the cell. (value 1). |
| number | Red; green; blue; and luma values for the cell. (value 2). |
| number | Red; green; blue; and luma values for the cell. (value 3). |
| number | Red; green; blue; and luma values for the cell. (value 4). |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        light:setAmbient({ r = 0.1, g = 0.1, b = 0.1 })
        light:compute({ includeSunLight = false })
        return light:getLight(1, 1, 1)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:getSize`

Returns light-map width, height, and level count.

```lua
LTileLightMap:getSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width; height; and level count. (value 1). |
| number | Width; height; and level count. (value 2). |
| number | Width; height; and level count. (value 3). |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        local w, h, levels = light:getSize()
        return w + h + levels
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:removeAreaLight`

Removes a rectangular area light by id and returns whether it existed.

```lua
LTileLightMap:removeAreaLight(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Stable area-light id returned by `addAreaLight`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when an area light was removed. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        local id = light:addAreaLight({ x = 2, y = 2, z = 1, width = 2, height = 2, radius = 2 })
        return light:removeAreaLight(id)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
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
| `id` | number | Stable line-light id returned by `addLineLight`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a line light was removed. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        local id = light:addLineLight({ x1 = 1, y1 = 2, x2 = 6, y2 = 2, z1 = 1, z2 = 1, radius = 1.5 })
        return light:removeLineLight(id)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

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
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        local id = light:addPointLight({ x = 1, y = 1, z = 1, radius = 2 })
        return light:removePointLight(id)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:removeRectLight`

Alias for `removeAreaLight`.

```lua
LTileLightMap:removeRectLight(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Stable rectangular light id returned by `addRectLight`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a rectangular light was removed. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        local id = light:addRectLight({ x = 2, y = 2, z = 1, w = 2, h = 2, radius = 2 })
        return light:removeRectLight(id)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
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

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        light:setAmbient({ r = 0.1, g = 0.2, b = 0.3 })
        light:compute({ includeSunLight = false })
        return light:getLight(1, 1, 1)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:setGlobalLight`

Compatibility alias for top sun light parameters used during light computation.

```lua
LTileLightMap:setGlobalLight(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | `{intensity?, color?}` top-light settings. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        light:setGlobalLight({ intensity = 0.4, color = { r = 1, g = 0.85, b = 0.55 } })
        light:compute({ includeGlobalLight = true })
        return light:getLight(1, 1, 1)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
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

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        light:setSunLight({ kind = "directional", intensity = 0.8, direction = { x = 1, y = 0 } })
        light:compute({ includeSunLight = true })
        return light:getLight(1, 1, 1)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

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

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        return light:type()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

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

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        return light:typeOf("LTileLightMap")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:updateAreaLight`

Updates an existing rectangular area light by id.

```lua
LTileLightMap:updateAreaLight(id, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Stable area-light id returned by `addAreaLight`. |
| `opts` | table | Area-light fields to update. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        local id = light:addAreaLight({ x = 2, y = 2, z = 1, width = 2, height = 2, radius = 2 })
        light:updateAreaLight(id, { x = 3, y = 3, w = 1, h = 1 })
        return id
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

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

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        local id = light:addLineLight({ x1 = 1, y1 = 2, x2 = 6, y2 = 2, z1 = 1, z2 = 1, radius = 1.5 })
        light:updateLineLight(id, { x1 = 2, y1 = 2, x2 = 5, y2 = 2, radius = 2 })
        return id
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

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
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        local id = light:addPointLight({ x = 1, y = 1, z = 1, radius = 2 })
        light:updatePointLight(id, { x = 3, y = 3, radius = 3 })
        return id
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:updateRectLight`

Alias for `updateAreaLight`.

```lua
LTileLightMap:updateRectLight(id, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Stable rectangular light id returned by `addRectLight`. |
| `opts` | table | Rectangular-light fields to update. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        local id = light:addRectLight({ x = 2, y = 2, z = 1, w = 2, h = 2, radius = 2 })
        light:updateRectLight(id, { x = 3, y = 3, w = 1, h = 1 })
        return id
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---
