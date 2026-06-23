# Tilefield

## Purpose

Coordinates exposed to Lua are one-based x, y, z; Rust storage is zero-based.

## When To Use

- Supported topologies are square, iso_square, and hex. iso_square uses square gameplay math because projection belongs to tilemap/rendering.
- Channels are intentionally independent: seeing through a cell does not imply acting, moving, or lighting through it.
- Built-in profiles include empty, wall, window, door_closed, door_open, and half_wall.

## Minimal Example

Example block: `lurek.tilefield.new`

```lua
do
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

## API Reference

- This page is the generated API reference for this module.

## Summary

- Coordinates exposed to Lua are one-based `x, y, z`; Rust storage is zero-based.
- Supported topologies are `square`, `iso_square`, and `hex`. `iso_square` uses square gameplay math because projection belongs to tilemap/rendering.
- Channels are intentionally independent: seeing through a cell does not imply acting, moving, or lighting through it.
- Built-in profiles include `empty`, `wall`, `window`, `door_closed`, `door_open`, and `half_wall`.
- Point lights use the `light` channel. `blocks.light=true` is full occlusion; `costs.light` is a `0..1` transmission multiplier for partial blockers such as smoked glass, grates, or shade screens.
- Point-light radius is radial: square and iso-square fields use Euclidean distance, while hex fields use hex distance. The square bounding box is only an iteration window, not the shape of the light.
- Point-light and global-light colors are RGB gameplay data, not renderer-only tint. Dusk, night, torch, alarm, and magical lights can use different colors and intensities.
- Global top light is attenuated by `sunOcclusion` from upper levels, preserving the configured global color while reducing intensity below occluding cells.

This module is mostly self-contained inside the Feature Systems group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Functions

### `lurek.tilefield.fromTileMap`

Copies a tilemap layer into a tilefield using solid and empty profiles.

```lua
lurek.tilefield.fromTileMap(tilemap, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tilemap` | [LTileMap](#ltilemap) | Source tilemap. |
| `opts?` | table | `{level?, topology?, solidProfile?, emptyProfile?, solidGids?}`. |

**Returns**

| Type | Description |
|------|-------------|
| [LTileField](#ltilefield) | New tilefield copied from the tilemap layer. |

**Example**

```lua
do
    local map = lurek.tilemap.newTileMap(16, 16)
    map:addLayer("ground", 4, 4)
    map:setTile(1, 2, 2, 9)
    local field = lurek.tilefield.fromTileMap(map, { layer = 1, solidGids = { 9 } })
    tilefield_log("tilemap copied, blocked=" .. tostring(field:blocks(2, 2, 1, "move")))
end
```

---

### `lurek.tilefield.new`

Creates a multi-level tilefield.

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
    local field = lurek.tilefield.new({ width = 8, height = 8, levels = 2, topology = "square" })
    local w, h, levels = field:getSize()
    local topology = field:getTopology()
    local inside = field:inBounds(8, 8, 2)
    tilefield_log("new field " .. w .. "x" .. h .. "x" .. levels .. " " .. topology .. " inside=" .. tostring(inside))
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LTileField](#ltilefield)
- [LTileMap](#ltilemap)

## LTileField

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTileField:addPointLight`

Adds a point light and returns its stable id.

```lua
LTileField:addPointLight(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | `{x, y, z?, radius, intensity?, color?}` light definition. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 5 })
    local id = field:addPointLight({ x = 2, y = 2, z = 1, radius = 4, intensity = 1 })
    field:computeLight({ includePointLights = true })
    local _, _, _, luma = field:getLight(2, 2, 1)
    tilefield_log("light id=" .. id .. " luma=" .. luma)
end
```

---

#### `LTileField:applyProfile`

Applies a named profile to one cell.

```lua
LTileField:applyProfile(x, y, z, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `name` | any |  |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:applyProfile(2, 2, 1, "window")
    local move = field:blocks(2, 2, 1, "move")
    local light = field:blocks(2, 2, 1, "light")
    tilefield_log("window move=" .. tostring(move) .. " light=" .. tostring(light))
end
```

---

#### `LTileField:blocks`

Returns whether a cell blocks a channel.

```lua
LTileField:blocks(x, y, z, channel)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `channel` | any |  |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:applyProfile(2, 2, 1, "window")
    local move = field:blocks(2, 2, 1, "move")
    local vision = field:blocks(2, 2, 1, "vision")
    tilefield_log("blocks move=" .. tostring(move) .. " vision=" .. tostring(vision))
end
```

---

#### `LTileField:clear`

Clears all cell gameplay state and computed light values.

```lua
LTileField:clear()
```

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setBlock(2, 2, 1, "move", true)
    local before = field:blocks(2, 2, 1, "move")
    field:clear()
    tilefield_log("clear before=" .. tostring(before) .. " after=" .. tostring(field:blocks(2, 2, 1, "move")))
end
```

---

#### `LTileField:clearCell`

Clears one cell.

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
| `from_tbl` | any |  |
| `to_tbl` | any |  |
| `channel` | any |  |
| `opts?` | any |  |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 3 })
    field:applyProfile(3, 2, 1, "window")
    local sight = field:clearLine({ x = 1, y = 2, z = 1 }, { x = 6, y = 2, z = 1 }, "vision")
    local action = field:clearLine({ x = 1, y = 2, z = 1 }, { x = 6, y = 2, z = 1 }, "action")
    tilefield_log("clearLine sight=" .. tostring(sight) .. " action=" .. tostring(action))
end
```

---

#### `LTileField:clearPointLights`

Removes all point lights.

```lua
LTileField:clearPointLights()
```

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 5 })
    field:addPointLight({ x = 1, y = 1, z = 1, radius = 2 })
    field:clearPointLights()
    field:computeLight({ includePointLights = true })
    tilefield_log("point lights cleared")
end
```

---

#### `LTileField:computeLight`

Computes tile light from ambient, point lights, and global top light.

```lua
LTileField:computeLight(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | table | Optional includePointLights, includeGlobalLight, and ambient settings. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4 })
    field:setProfile("smoked_glass", {
        blocks = { light = false, vision = false, move = true, action = true },
        costs = { light = 0.5 },
        sunOcclusion = 0.25,
    })
    field:applyProfile(4, 2, 1, "smoked_glass")
    field:addPointLight({ x = 2, y = 2, z = 1, radius = 5, color = { r = 1, g = 0.35, b = 0.1 } })
    field:computeLight({ includePointLights = true, ambient = { r = 0.02, g = 0.02, b = 0.02 } })
    local r, g, b, luma = field:getLight(6, 2, 1)
    tilefield_log("filtered rgb=" .. (r + g + b) .. " luma=" .. luma)
end
```

---

#### `LTileField:exportBlockLayer`

Exports one blocker channel and level as a row-major boolean array.

```lua
LTileField:exportBlockLayer(channel, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `channel` | any |  |
| `z?` | any |  |

**Example**

```lua
do
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
| `channel` | any |  |
| `z?` | any |  |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 3, height = 3 })
    field:setCost(2, 2, 1, "move", 7)
    local layer = field:exportCostLayer("move", 1)
    local center = layer[5]
    tilefield_log("cost layer center=" .. center)
end
```

---

#### `LTileField:exportLightLayer`

Exports one level of computed light as row-major `{r,g,b,luma}` tables.

```lua
LTileField:exportLightLayer(z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| table | Row-major array of light tables. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 3, height = 3 })
    field:computeLight({ ambient = { r = 0.1, g = 0.1, b = 0.1 } })
    local layer = field:exportLightLayer(1)
    local count = #layer
    tilefield_log("light layer count=" .. count .. " first=" .. layer[1].luma)
end
```

---

#### `LTileField:exportLightVolume`

Exports all computed light levels as nested row-major tables.

```lua
LTileField:exportLightVolume()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of per-level row-major light layers. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 2, height = 2, levels = 2 })
    field:computeLight({ ambient = { r = 0.05, g = 0.05, b = 0.05 } })
    local volume = field:exportLightVolume()
    local levels = #volume
    tilefield_log("light volume levels=" .. levels .. " cells=" .. #volume[1])
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
    local field = lurek.tilefield.new({ width = 3, height = 3 })
    field:applyProfile(2, 2, 1, "window")
    local layer = field:exportProfileLayer(1)
    local center = layer[5]
    tilefield_log("profile layer center=" .. tostring(center))
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
| `from_tbl` | any |  |
| `to_tbl` | any |  |
| `channel` | any |  |
| `opts?` | any |  |

**Example**

```lua
do
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
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `channel` | any |  |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 4, height = 4 })
    local base = field:getCost(1, 1, 1, "move")
    field:setCost(1, 2, 1, "move", 5)
    local changed = field:getCost(1, 2, 1, "move")
    tilefield_log("cost base=" .. base .. " changed=" .. changed)
end
```

---

#### `LTileField:getLight`

Returns r, g, b, and luma for one cell.

```lua
LTileField:getLight(x, y, z)
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
| number | Red component in 0..1. |
| number | Green component in 0..1. |
| number | Blue component in 0..1. |
| number | Luma value in 0..1. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:computeLight({ ambient = { r = 0.1, g = 0.1, b = 0.1 } })
    local r, g, b, luma = field:getLight(1, 1, 1)
    local rgb = r + g + b
    tilefield_log("light rgb=" .. rgb .. " luma=" .. luma)
end
```

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
    local field = lurek.tilefield.new({ width = 4, height = 4 })
    local profile = field:getProfile("wall")
    local move = profile.blocks.move
    local vision = profile.blocks.vision
    tilefield_log("wall profile move=" .. tostring(move) .. " vision=" .. tostring(vision))
end
```

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
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 2, height = 2 })
    field:setSunOcclusion(1, 1, 1, 0.3)
    local value = field:getSunOcclusion(1, 1, 1)
    local default = field:getSunOcclusion(2, 2, 1)
    tilefield_log("sun values=" .. value .. "," .. default)
end
```

---

#### `LTileField:getTopology`

Returns the field topology name.

```lua
LTileField:getTopology()
```

**Returns**

| Type | Description |
|------|-------------|
| string | `square`, `iso_square`, or `hex`. |

**Example**

```lua
do
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
    local field = lurek.tilefield.new({ width = 6, height = 6 })
    local line = field:line({ from = { x = 1, y = 1, z = 1 }, to = { x = 5, y = 1, z = 1 } })
    local first = line[1].x
    local last = line[#line].x
    tilefield_log("line first=" .. first .. " last=" .. last .. " count=" .. #line)
end
```

---

#### `LTileField:removePointLight`

Removes a point light by id and returns whether it existed.

```lua
LTileField:removePointLight(id)
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
    local field = lurek.tilefield.new({ width = 5, height = 5 })
    local id = field:addPointLight({ x = 1, y = 1, z = 1, radius = 2 })
    local removed = field:removePointLight(id)
    field:computeLight({ includePointLights = true })
    tilefield_log("removed=" .. tostring(removed))
end
```

---

#### `LTileField:removeProfile`

Removes a named object profile.

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
    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setProfile("temporary", { blocks = { move = true } })
    field:removeProfile("temporary")
    local missing = field:getProfile("temporary") == nil
    tilefield_log("profile removed=" .. tostring(missing))
end
```

---

#### `LTileField:setBlock`

Sets whether a cell blocks a channel.

```lua
LTileField:setBlock(x, y, z, channel, blocked)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `channel` | any |  |
| `blocked` | any |  |

**Example**

```lua
do
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
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `channel` | any |  |
| `cost` | any |  |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setCost(2, 2, 1, "move", 4)
    field:setCost(2, 3, 1, "move", 2)
    local a = field:getCost(2, 2, 1, "move")
    tilefield_log("setCost high=" .. a)
end
```

---

#### `LTileField:setGlobalLight`

Sets top-down global light.

```lua
LTileField:setGlobalLight(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | `{intensity?, color?}` global top-light settings. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 2, height = 2, levels = 2 })
    field:setGlobalLight({ intensity = 0.35, color = { r = 1, g = 0.95, b = 0.8 } })
    field:computeLight({ includeGlobalLight = true })
    local _, _, _, luma = field:getLight(1, 1, 2)
    tilefield_log("global luma=" .. luma)
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
| `name` | any |  |
| `profile_tbl` | any |  |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setProfile("bars", { blocks = { move = true, vision = false, action = true }, sunOcclusion = 0.1 })
    field:applyProfile(2, 2, 1, "bars")
    local visible = not field:blocks(2, 2, 1, "vision")
    tilefield_log("custom bars visible=" .. tostring(visible))
end
```

---

#### `LTileField:setSunOcclusion`

Sets top-light occlusion in the inclusive range 0..1.

```lua
LTileField:setSunOcclusion(x, y, z, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `value` | any |  |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 2, height = 2, levels = 2 })
    field:setSunOcclusion(1, 1, 2, 0.5)
    field:setGlobalLight({ intensity = 1 })
    field:computeLight({ includeGlobalLight = true })
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
    local field = lurek.tilefield.new({ width = 2, height = 2 })
    local exact = field:typeOf("LTileField")
    local object = field:typeOf("LObject")
    local miss = field:typeOf("LNavGrid")
    tilefield_log("typeOf exact=" .. tostring(exact) .. " object=" .. tostring(object) .. " miss=" .. tostring(miss))
end
```

---

#### `LTileField:updatePointLight`

Updates an existing point light by id.

```lua
LTileField:updatePointLight(id, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | any |  |
| `opts` | any |  |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 5 })
    local id = field:addPointLight({ x = 1, y = 1, z = 1, radius = 2 })
    field:updatePointLight(id, { x = 3, y = 3, radius = 4, intensity = 0.5 })
    field:computeLight({ includePointLights = true })
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
