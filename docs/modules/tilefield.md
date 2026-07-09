# Tilefield

## Purpose

lurek.tilefield is the shared tile-based gameplay data owner for multi-level maps. It stores independent blockers, costs, profile names, and author-defined cell refs so pathfinding, awareness, tilelight, minimap, and raycaster adapters can share one source of truth without depending on each other.

## Summary

- Coordinates exposed to Lua are one-based `x, y, z`; Rust storage is zero-based.
- `LTileField` is a single field with width, height, and one or more levels. This is the default one-level map model.
- `LTileFieldMap` is a 2D or layered map of shared `LTileField` handles. Use it when a world is chunked into fields or stacked as layers of fields.
- Supported topologies are `square`, `square4`, `square8`, `iso_square`, and `hex`. `square`/`square8` use eight neighbors, but radial range budgets use Euclidean square distance so a diagonal is `sqrt(2)`; `square4` uses Manhattan distance, and `iso_square` uses square gameplay math because projection belongs to tilemap/rendering.
- Channels are intentionally independent: seeing through a cell does not imply acting, moving, or lighting through it.
- Built-in profiles include `empty`, `wall`, `window`, `door_closed`, `door_open`, and `half_wall`.
- The `light` channel and `sunOcclusion` are environment inputs consumed by `lurek.tilelight`; `tilefield` does not store point lights or computed light values.
- Cell refs such as `floor`, `wall_left`, `roof`, or `object` are author-defined slots. They are useful for mapping tile ids, object ids, or block slots onto the same gameplay field without forcing every system to own separate data.

This module is mostly self-contained inside the Feature Systems group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## API Reference

- This page is the generated API reference for this module.

## Functions

### `lurek.tilefield.createLightsFromTileset`

Creates normal render lights and occluders from tilefield refs whose tileset objects define `renderLight` or `occluder`.

```lua
lurek.tilefield.createLightsFromTileset(field, slot, tileset, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `field` | [LTileField](#ltilefield) | Source field containing refs. |
| `slot` | string | Reference slot name. |
| `tileset` | [LTileSet](tileset.md#ltileset) | Tileset with tile object metadata. |
| `opts?` | table | `{z?/level?, refIsGid?, originX?, originY?, tileWidth?, tileHeight?}`. |

**Returns**

| Type | Description |
|------|-------------|
| table | `{lights=Llight[], occluders=[LOccluder](light.md#loccluder)[]}`. |

**Example**

```lua
do

    lurek.light.clear()
    local tileset = lurek.tileset.fromProvider({
        firstGid = 1,
        tileCount = 1,
        columns = 1,
        tileWidth = 16,
        tileHeight = 16,
        objects = { torch_wall = { renderLight = { radius = 64, intensity = 1.2, color = { 1, 0.8, 0.4, 1 } }, occluder = { shape = "diamond" } } },
        tileObjects = { [1] = "torch_wall" },
    })
    local field = lurek.tilefield.new({ width = 2, height = 2 })
    field:setRef(1, 1, 1, "tiles", 1)
    local spawned = lurek.tilefield.createLightsFromTileset(field, "tiles", tileset, { refIsGid = true })
    lurek.log.info("tileset lights=" .. #spawned.lights .. " occluders=" .. #spawned.occluders)
end
```

---

### `lurek.tilefield.createPhysicsFromTileset`

Creates physics bodies from tilefield refs whose tileset objects define `physics`.

```lua
lurek.tilefield.createPhysicsFromTileset(field, slot, tileset, world, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `field` | [LTileField](#ltilefield) | Source field containing refs. |
| `slot` | string | Reference slot name. |
| `tileset` | [LTileSet](tileset.md#ltileset) | Tileset with tile object metadata. |
| `world` | [LWorld](physics.md#lworld) | Physics world that receives the bodies. |
| `opts?` | table | `{z?/level?, refIsGid?, originX?, originY?, tileWidth?, tileHeight?}`. |

**Returns**

| Type | Description |
|------|-------------|
| [LBody](physics.md#lbody)[] | Created physics body handles in row-major order. |

**Example**

```lua
do

    local tileset = lurek.tileset.fromProvider({
        firstGid = 1,
        tileCount = 2,
        columns = 2,
        tileWidth = 16,
        tileHeight = 16,
        objects = { wall = { physics = { shape = "rect", bodyType = "static", restitution = 0.8 } } },
        tileObjects = { [1] = "wall" },
    })
    local field = lurek.tilefield.new({ width = 3, height = 3 })
    field:setRef(2, 2, 1, "tiles", 1)
    local world = lurek.physics.newWorld(0, 0)
    local bodies = lurek.tilefield.createPhysicsFromTileset(field, "tiles", tileset, world, { refIsGid = true })
    lurek.log.info("tileset physics bodies=" .. #bodies .. " world=" .. world:getBodyCount())
end
```

---

### `lurek.tilefield.fromProvider`

Builds a native tilefield from a Lua provider table with width, height, optional levels/topology, slots, modifiers, regions, and optional getCell(x,y,z).

```lua
lurek.tilefield.fromProvider(provider)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `provider` | table | Lua-authored tilefield provider. |

**Returns**

| Type | Description |
|------|-------------|
| [LTileField](#ltilefield) | New tilefield copied from the provider. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        local f = lurek.tilefield.fromProvider({ width = 3, height = 2, levels = 2, topology = "square4" })
        return f:getTopology()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

### `lurek.tilefield.fromTileMap`

Copies a tilemap layer into a tilefield, optionally applying tileset object defaults and a ref slot.

```lua
lurek.tilefield.fromTileMap(tilemap, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tilemap` | [LTileMap](tilemap.md#ltilemap) | Source tilemap. |
| `opts?` | table | `{layer?, level?, levels?, topology?, solidGids?, refSlot?, applyTilesetObject?}`; `solidGids` and `applyTilesetObject` are explicit, no tileset solidity is inferred. |

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
    lurek.log.info("tilemap copied, blocked=" .. tostring(field:blocks(2, 2, 1, "move")))
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

    local field = lurek.tilefield.new({ width = 8, height = 8, levels = 2, topology = "square" })
    local w, h, levels = field:getSize()
    local topology = field:getTopology()
    local inside = field:inBounds(8, 8, 2)
    lurek.log.info("new field " .. w .. "x" .. h .. "x" .. levels .. " " .. topology .. " inside=" .. tostring(inside))
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

    local map = lurek.tilefield.newFieldMap({ width = 2, height = 2, layers = 2, fieldWidth = 4, fieldHeight = 4, topology = "square4" })
    local mw, mh, ml = map:getMapSize()
    local fw, fh = map:getFieldSize()
    local topology = map:getTopology()
    lurek.log.info("fieldmap " .. mw .. "x" .. mh .. "x" .. ml .. " field=" .. fw .. "x" .. fh .. " topology=" .. topology)
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

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setModifier("wall", { blocks = { move = true } })
        field:applyModifier(2, 2, 1, "wall")
        return field:blocks(2, 2, 1, "move")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

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

**Example**

```lua
do

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:applyProfile(2, 2, 1, "window")
    local move = field:blocks(2, 2, 1, "move")
    local light = field:blocks(2, 2, 1, "light")
    lurek.log.info("window move=" .. tostring(move) .. " light=" .. tostring(light))
end
```

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

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setRef(1, 1, 1, "object", 1)
        return field:applyTilesetObject(1, 1, 1, "object", tileset)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

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

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setRef(1, 1, 1, "object", 1)
        field:setRef(2, 1, 1, "object", 1)
        return field:applyTilesetObjectLayer("object", tileset, { z = 1 })
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileField:beginEdit`

Clears pending dirty rectangles before a grouped tilefield edit.

```lua
LTileField:beginEdit()
```

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 1 })
    field:beginEdit()
    field:setBlock(2, 2, 1, "move", true)
    field:setResource(3, 2, 1, "iron")
    local dirty = field:getDirtyRects()
    lurek.log.info("beginEdit dirty=" .. tostring(#dirty))
    lurek.log.info("beginEdit resource=" .. tostring(field:getResource(3, 2, 1)))
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

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:applyProfile(2, 2, 1, "window")
    local move = field:blocks(2, 2, 1, "move")
    local vision = field:blocks(2, 2, 1, "vision")
    lurek.log.info("blocks move=" .. tostring(move) .. " vision=" .. tostring(vision))
end
```

---

#### `LTileField:blocksCategory`

Returns whether one cell blocks a category.

```lua
LTileField:blocksCategory(x, y, z, category)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based cell column. |
| `y` | number | One-based cell row. |
| `z?` | number | Optional one-based level index, defaulting to 1. |
| `category` | string | Category name to test. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the addressed cell blocks the selected category. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setCategoryBlock(2, 2, 1, "tank", true)
        return field:blocksCategory(2, 2, 1, "tank")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileField:clear`

Clears all gameplay state, modifiers, and references in the field.

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
    lurek.log.info("clear before=" .. tostring(before) .. " after=" .. tostring(field:blocks(2, 2, 1, "move")))
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

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setBlock(2, 2, 1, "vision", true)
    field:setBlock(3, 2, 1, "vision", true)
    field:clearCell(2, 2, 1)
    lurek.log.info("clearCell target=" .. tostring(field:blocks(2, 2, 1, "vision")) .. " neighbor=" .. tostring(field:blocks(3, 2, 1, "vision")))
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

    local field = lurek.tilefield.new({ width = 6, height = 3 })
    field:applyProfile(3, 2, 1, "window")
    local sight = field:clearLine({ x = 1, y = 2, z = 1 }, { x = 6, y = 2, z = 1 }, "vision")
    local action = field:clearLine({ x = 1, y = 2, z = 1 }, { x = 6, y = 2, z = 1 }, "action")
    lurek.log.info("clearLine sight=" .. tostring(sight) .. " action=" .. tostring(action))
end
```

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

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setModifier("mud", { costs = { move = 4 } })
        field:applyModifier(2, 2, 1, "mud")
        field:clearModifier(2, 2, 1)
        return #field:getModifiers(2, 2, 1)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileField:clearOccupant`

Clears any occupant id stored on one tile cell.

```lua
LTileField:clearOccupant(x, y, z)
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
| boolean | True when an occupant was removed. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 8, height = 8 })
    field:setOccupant(2, 3, 1, 99)
    field:clearOccupant(2, 3, 1)
    local occupant = field:getOccupant(2, 3, 1)
    lurek.log.info("occupant after clear=" .. tostring(occupant))
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

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setRef(2, 2, 1, "object", 1)
        field:clearRef(2, 2, 1, "object")
        return field:getRef(2, 2, 1, "object")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileField:commitEdit`

Clears and returns dirty rectangles accumulated since `beginEdit`.

```lua
LTileField:commitEdit(chunkSize)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `chunkSize?` | number | Optional chunk size used to add cx/cy fields to each dirty rect. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of `{x, y, z, w, h, cx?, cy?}` one-based dirty rectangles. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 1 })
    field:beginEdit()
    field:setBlock(2, 2, 1, "move", true)
    field:setRef(2, 2, 1, "foreground", 12)
    local dirty = field:commitEdit(4)
    lurek.log.info("commit rects=" .. tostring(#dirty))
    lurek.log.info("commit ref=" .. tostring(field:getRef(2, 2, 1, "foreground")))
end
```

---

#### `LTileField:defineBlockWorldSlots`

Defines conventional ref slots for mutable block worlds without adding a new module.

```lua
LTileField:defineBlockWorldSlots()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Slot names: foreground, wall, platform, ore, furniture, liquid, spawn, biome. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 1 })
    local slots = field:defineBlockWorldSlots()
    field:setRef(2, 2, 1, "foreground", 12)
    field:setRef(2, 2, 1, "wall", 13)
    local foreground = field:getRef(2, 2, 1, "foreground")
    lurek.log.info("block slots=" .. tostring(#slots))
    lurek.log.info("foreground ref=" .. tostring(foreground))
end
```

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

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:defineCategory("tank", { kind = "movement" })
        return field:getCategory("tank").kind
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

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

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:defineSlot("object")
        return field:hasSlot("object")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileField:drainDirtyRects`

Clears and returns pending dirty cell rectangles.

```lua
LTileField:drainDirtyRects(chunkSize)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `chunkSize?` | number | Optional chunk size used to add cx/cy fields to each dirty rect. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of `{x, y, z, w, h, cx?, cy?}` one-based dirty rectangles. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 1 })
    field:setBlock(2, 2, 1, "move", true)
    field:setResource(3, 2, 1, "coal")
    local drained = field:drainDirtyRects()
    local remaining = field:getDirtyRects()
    lurek.log.info("drained rects=" .. tostring(#drained))
    lurek.log.info("remaining rects=" .. tostring(#remaining))
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
| `channel` | string | Blocker channel name to export. |
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| table | Row-major boolean array for the requested channel and level. |

**Example**

```lua
do

    local field = lurek.tilefield.new({ width = 3, height = 3 })
    field:applyProfile(2, 2, 1, "wall")
    local layer = field:exportBlockLayer("move", 1)
    local blocked = layer[5]
    lurek.log.info("block layer center=" .. tostring(blocked))
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

    local field = lurek.tilefield.new({ width = 3, height = 3 })
    field:setCost(2, 2, 1, "move", 7)
    local layer = field:exportCostLayer("move", 1)
    local center = layer[5]
    lurek.log.info("cost layer center=" .. center)
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

    local field = lurek.tilefield.new({ width = 4, height = 4, levels = 2 })
    field:setRef(2, 2, 1, "floor", 101)
    field:setRef(2, 2, 1, "wall_left", 210)
    local layer = field:exportRefLayer("wall_left", 1)
    lurek.log.info("floor=" .. field:getRef(2, 2, 1, "floor") .. " wall_left=" .. tostring(layer[6]))
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

    local field = lurek.tilefield.new({ width = 6, height = 3 })
    field:applyProfile(4, 2, 1, "wall")
    local blocker = field:firstBlocker({ x = 1, y = 2, z = 1 }, { x = 6, y = 2, z = 1 }, "vision")
    local x = blocker and blocker.x or 0
    lurek.log.info("first blocker x=" .. x)
end
```

---

#### `LTileField:footprintPassable`

Returns whether a rectangular footprint can occupy a cell anchor for a category.

```lua
LTileField:footprintPassable(x, y, z, w, h, category)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based anchor column. |
| `y` | number | One-based anchor row. |
| `z?` | number | Optional one-based level index, defaulting to 1. |
| `w` | number | Footprint width in cells. |
| `h` | number | Footprint height in cells. |
| `category` | string | Category name to test against blockers and costs. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the footprint can be placed at the addressed anchor cell. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setCategoryBlock(3, 2, 1, "tank", true)
        return field:footprintPassable(2, 2, 1, 2, 1, "tank")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileField:getCategories`

Returns the sorted names of all known cell categories.

```lua
LTileField:getCategories()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Sorted category names. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:defineCategory("tank", { kind = "movement" })
        return field:getCategories()[1]
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

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

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:defineCategory("tank", { kind = "movement" })
        return field:getCategory("tank").kind
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileField:getCategoryCost`

Returns one effective category cost.

```lua
LTileField:getCategoryCost(x, y, z, category)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based cell column. |
| `y` | number | One-based cell row. |
| `z?` | number | Optional one-based level index, defaulting to 1. |
| `category` | string | Category name to inspect. |

**Returns**

| Type | Description |
|------|-------------|
| number | Effective movement cost for that category on the addressed cell. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setCategoryCost(2, 2, 1, "tank", 6)
        return field:getCategoryCost(2, 2, 1, "tank")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileField:getCategoryFilter`

Returns one effective RGB category filter.

```lua
LTileField:getCategoryFilter(x, y, z, category)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based cell column. |
| `y` | number | One-based cell row. |
| `z?` | number | Optional one-based level index, defaulting to 1. |
| `category` | string | Category name to inspect. |

**Returns**

| Type | Description |
|------|-------------|
| table | RGB multiplier table for that category on the addressed cell. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setCategoryFilter(2, 2, 1, "light", { 0.25, 0.5, 1 })
        return field:getCategoryFilter(2, 2, 1, "light")[3]
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileField:getCategoryTransmission`

Returns one effective category transmission multiplier.

```lua
LTileField:getCategoryTransmission(x, y, z, category)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based cell column. |
| `y` | number | One-based cell row. |
| `z?` | number | Optional one-based level index, defaulting to 1. |
| `category` | string | Category name to inspect. |

**Returns**

| Type | Description |
|------|-------------|
| number | Effective transmission multiplier for that category on the addressed cell. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setCategoryTransmission(2, 2, 1, "light", 0.25)
        return field:getCategoryTransmission(2, 2, 1, "light")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

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

**Example**

```lua
do

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:applyProfile(2, 2, 1, "window")
    local cell = field:getCell(2, 2, 1)
    local move = cell.blocks.move
    local vision = cell.blocks.vision
    lurek.log.info("cell move=" .. tostring(move) .. " vision=" .. tostring(vision))
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

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    local base = field:getCost(1, 1, 1, "move")
    field:setCost(1, 2, 1, "move", 5)
    local changed = field:getCost(1, 2, 1, "move")
    lurek.log.info("cost base=" .. base .. " changed=" .. changed)
end
```

---

#### `LTileField:getDirtyRects`

Returns pending dirty cell rectangles without clearing them.

```lua
LTileField:getDirtyRects(chunkSize)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `chunkSize?` | number | Optional chunk size used to add cx/cy fields to each dirty rect. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of `{x, y, z, w, h, cx?, cy?}` one-based dirty rectangles. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 1 })
    field:setBlock(2, 2, 1, "move", true)
    field:setBlock(3, 2, 1, "light", true)
    local dirty = field:getDirtyRects(4)
    local first = dirty[1] or { x = 0, y = 0, cx = 0, cy = 0 }
    lurek.log.info("dirty rects=" .. tostring(#dirty))
    lurek.log.info("first rect=" .. tostring(first.x) .. "," .. tostring(first.y) .. " chunk=" .. tostring(first.cx) .. "," .. tostring(first.cy))
end
```

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

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setModifier("mud", { costs = { move = 4 } })
        return field:getModifier("mud").costs.move
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

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

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setModifier("wall", { blocks = { move = true } })
        field:applyModifier(2, 2, 1, "wall")
        return field:getModifiers(2, 2, 1)[1]
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
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

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        return #field:getNeighbors(2, 2, 1)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileField:getOccupant`

Returns the occupant id stored on one tile cell.

```lua
LTileField:getOccupant(x, y, z)
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
| number | Occupant id, or nil. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 8, height = 8 })
    field:setOccupant(1, 1, 77)
    local occupant = field:getOccupant(1, 1, 1)
    local same = occupant == 77
    lurek.log.info("occupant read=" .. tostring(occupant) .. " same=" .. tostring(same))
end
```

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

**Example**

```lua
do

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    local profile = field:getProfile("wall")
    local move = profile.blocks.move
    local vision = profile.blocks.vision
    lurek.log.info("wall profile move=" .. tostring(move) .. " vision=" .. tostring(vision))
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
| number | table|nil | Stored legacy id, typed ref table, or nil when unset. |

**Example**

```lua
do

    local field = lurek.tilefield.new({ width = 4, height = 4, levels = 2 })
    field:setRef(2, 2, 1, "object", { tileset = "props", object = "crate" })
    local value = field:getRef(2, 2, 1, "object")
    local missing = field:getRef(1, 1, 1, "object")
    lurek.log.info("getRef object=" .. tostring(value.object) .. " missing=" .. tostring(missing))
end
```

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

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setRef(1, 1, 1, "object", 1)
        return field:getRefProperties(1, 1, 1, "object", tileset).terrain
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

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

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setRef(1, 1, 1, "object", 1)
        return field:getRefProperty(1, 1, 1, "object", tileset, "material")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

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

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setRef(1, 1, 1, "object", 1)
        return field:getRefPropertyBool(1, 1, 1, "object", tileset, "solid")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

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

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setRef(1, 1, 1, "object", 1)
        return field:getRefPropertyNumber(1, 1, 1, "object", tileset, "cost")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileField:getRefSlots`

Returns the sorted names of every declared reference slot.

```lua
LTileField:getRefSlots()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Ref slot names. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:defineSlot("object")
        return field:getRefSlots()[1]
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

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
| table | Array of `{ x, y, z }` cells. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setRegionRect("room", 1, 1, 2, 2, 1)
        return #field:getRegionCells("room")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

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

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setRegionCells("stairs", { { x = 1, y = 1, z = 1 } })
        return field:getRegionNames()[1]
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileField:getRegionProperties`

Returns all properties for a named region, or nil when the region does not exist.

```lua
LTileField:getRegionProperties(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Region name. |

**Returns**

| Type | Description |
|------|-------------|
| table | Key-value table of string properties, or nil. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    field:setRegionCells("shop", { { x = 3, y = 3, z = 1 } })
    field:setRegionProperty("shop", "trigger", "open_shop")
    field:setRegionProperty("shop", "facing", "south")
    local props = field:getRegionProperties("shop")
    lurek.log.info("region properties trigger = " .. tostring(props and props.trigger))
    lurek.log.info("region properties facing = " .. tostring(props and props.facing))
end
```

---

#### `LTileField:getRegionProperty`

Returns one string property from a named region, or nil when absent.

```lua
LTileField:getRegionProperty(name, key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Region name. |
| `key` | string | Property key. |

**Returns**

| Type | Description |
|------|-------------|
| string | Stored property value, or nil. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    field:setRegionCells("inn", { { x = 2, y = 2, z = 1 } })
    field:setRegionProperty("inn", "music", "inn_theme")
    local music = field:getRegionProperty("inn", "music")
    lurek.log.info("region property = " .. tostring(music))
end
```

---

#### `LTileField:getResource`

Returns a resource label stored on one tile cell.

```lua
LTileField:getResource(x, y, z)
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
| string | Resource label, or nil. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 8, height = 8 })
    field:setResource(2, 3, 1, "ore")
    local resource = field:getResource(2, 3, 1)
    local same = resource == "ore"
    lurek.log.info("resource read=" .. tostring(resource) .. " same=" .. tostring(same))
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
    lurek.log.info("field cells=" .. cells .. " valid=" .. tostring(valid))
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

    local field = lurek.tilefield.new({ width = 2, height = 2 })
    field:setSunOcclusion(1, 1, 1, 0.3)
    local value = field:getSunOcclusion(1, 1, 1)
    local default = field:getSunOcclusion(2, 2, 1)
    lurek.log.info("sun values=" .. value .. "," .. default)
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

    local field = lurek.tilefield.new({ width = 5, height = 5, topology = "iso_square" })
    local topology = field:getTopology()
    local same_logic = topology == "iso_square"
    local line = field:line({ from = { x = 1, y = 1, z = 1 }, to = { x = 3, y = 1, z = 1 } })
    lurek.log.info("topology=" .. topology .. " line=" .. #line .. " same=" .. tostring(same_logic))
end
```

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

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        local before = field:getVersion()
        field:setBlock(1, 1, 1, "move", true)
        return field:getVersion() - before
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

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

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:defineSlot("object")
        return field:hasSlot("object")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
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
    lurek.log.info("bounds " .. tostring(a) .. "," .. tostring(b) .. "," .. tostring(c))
end
```

---

#### `LTileField:isBuildable`

Returns whether one tile cell accepts build placement.

```lua
LTileField:isBuildable(x, y, z)
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
| boolean | True when build placement is allowed. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 8, height = 8 })
    field:setBuildable(2, 3, 1, true)
    local buildable = field:isBuildable(2, 3, 1)
    local status = buildable and "allowed" or "blocked"
    lurek.log.info("buildability read=" .. status)
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
    lurek.log.info("line first=" .. first .. " last=" .. last .. " count=" .. #line)
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

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setRegionCells("stairs", { { x = 2, y = 2, z = 1 } })
        return field:regionContains("stairs", 2, 2, 1)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileField:regionsAt`

Returns all region names that contain the addressed one-based tile cell.

```lua
LTileField:regionsAt(x, y, z)
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
| table | Array of region names in stable order. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    field:setRegionRect("stairs", 2, 2, 3, 2, 1)
    field:setRegionCells("shop_door", { { x = 2, y = 2, z = 1 } })
    local names = field:regionsAt(2, 2, 1)
    lurek.log.info("regions at tile = " .. #names)
    lurek.log.info("first region = " .. tostring(names[1]))
end
```

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

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setModifier("mud", { costs = { move = 4 } })
        return field:removeModifier("mud")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

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

**Example**

```lua
do

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setProfile("temporary", { blocks = { move = true } })
    field:removeProfile("temporary")
    local missing = field:getProfile("temporary") == nil
    lurek.log.info("profile removed=" .. tostring(missing))
end
```

---

#### `LTileField:removeRegion`

Removes a named region definition and its stored cell membership from this field.

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

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setRegionRect("room", 1, 1, 2, 2, 1)
        return field:removeRegion("room")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

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

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:defineSlot("object")
        return field:removeSlot("object")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileField:restore`

Replaces this tilefield state from a snapshot returned by `snapshot`.

```lua
LTileField:restore(snapshot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `snapshot` | table | Snapshot table. |

**Example**

```lua
do
    local source = lurek.tilefield.new({ width = 5, height = 4, levels = 1 })
    source:defineBlockWorldSlots()
    source:setRef(2, 2, 1, "wall", 13)
    source:setBuildable(3, 2, 1, false)
    local snapshot = source:snapshot()
    local clone = lurek.tilefield.new({ width = 1, height = 1 })
    clone:restore(snapshot)
    lurek.log.info("restore wall=" .. tostring(clone:getRef(2, 2, 1, "wall")))
    lurek.log.info("restore buildable=" .. tostring(clone:isBuildable(3, 2, 1)))
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
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `channel` | string | Blocker channel name to update. |
| `blocked` | boolean | True when the channel should be blocked. |

**Example**

```lua
do

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setBlock(2, 2, 1, "move", true)
    field:setBlock(2, 2, 1, "vision", false)
    local move = field:blocks(2, 2, 1, "move")
    lurek.log.info("setBlock move=" .. tostring(move))
end
```

---

#### `LTileField:setBuildable`

Sets whether one tile cell accepts build placement.

```lua
LTileField:setBuildable(x, y, z, buildable)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `buildable` | boolean | True when build placement is allowed. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 8, height = 8 })
    field:setBuildable(2, 3, 1, true)
    local buildable = field:isBuildable(2, 3, 1)
    local status = buildable and "allowed" or "blocked"
    lurek.log.info("buildability set=" .. status)
end
```

---

#### `LTileField:setCategoryBlock`

Sets one category blocker on one cell.

```lua
LTileField:setCategoryBlock(x, y, z, category, blocked)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based cell column. |
| `y` | number | One-based cell row. |
| `z?` | number | Optional one-based level index, defaulting to 1. |
| `category` | string | Category name to update. |
| `blocked` | boolean | Whether the category is blocked on that cell. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setCategoryBlock(2, 2, 1, "tank", true)
        return field:blocksCategory(2, 2, 1, "tank")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileField:setCategoryCost`

Sets one movement-cost override for a category on one cell.

```lua
LTileField:setCategoryCost(x, y, z, category, cost)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based cell column. |
| `y` | number | One-based cell row. |
| `z?` | number | Optional one-based level index, defaulting to 1. |
| `category` | string | Category name to update. |
| `cost` | number | Effective movement cost to assign. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setCategoryCost(2, 2, 1, "tank", 5)
        return field:getCategoryCost(2, 2, 1, "tank")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileField:setCategoryFilter`

Sets one RGB category filter on one cell.

```lua
LTileField:setCategoryFilter(x, y, z, category, filter)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based cell column. |
| `y` | number | One-based cell row. |
| `z?` | number | Optional one-based level index, defaulting to 1. |
| `category` | string | Category name to update. |
| `filter` | table | RGB multiplier table with three numeric entries. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setCategoryFilter(2, 2, 1, "light", { 1, 0.5, 0.25 })
        return field:getCategoryFilter(2, 2, 1, "light")[2]
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileField:setCategoryTransmission`

Sets one category transmission multiplier on one cell.

```lua
LTileField:setCategoryTransmission(x, y, z, category, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based cell column. |
| `y` | number | One-based cell row. |
| `z?` | number | Optional one-based level index, defaulting to 1. |
| `category` | string | Category name to update. |
| `value` | number | Transmission multiplier to assign. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setCategoryTransmission(2, 2, 1, "light", 0.5)
        return field:getCategoryTransmission(2, 2, 1, "light")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

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

**Example**

```lua
do

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setCell(2, 2, 1, { blocks = { action = true }, costs = { move = 3 }, sunOcclusion = 0.25 })
    local action = field:blocks(2, 2, 1, "action")
    local cost = field:getCost(2, 2, 1, "move")
    lurek.log.info("setCell action=" .. tostring(action) .. " cost=" .. cost)
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

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setCost(2, 2, 1, "move", 4)
    field:setCost(2, 3, 1, "move", 2)
    local a = field:getCost(2, 2, 1, "move")
    lurek.log.info("setCost high=" .. a)
end
```

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

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setModifier("mud", { costs = { move = 4 } })
        return field:getModifier("mud").name
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileField:setOccupant`

Stores an occupant id on one tile cell.

```lua
LTileField:setOccupant(x, y, z, occupant)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `occupant` | number | Occupant id, usually an ECS entity id. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 8, height = 8 })
    field:setOccupant(2, 3, 1, 99)
    local occupant = field:getOccupant(2, 3, 1)
    local occupied = occupant ~= nil
    lurek.log.info("occupant set=" .. tostring(occupant) .. " occupied=" .. tostring(occupied))
end
```

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

**Example**

```lua
do

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setProfile("bars", { blocks = { move = true, vision = false, action = true }, sunOcclusion = 0.1 })
    field:applyProfile(2, 2, 1, "bars")
    local visible = not field:blocks(2, 2, 1, "vision")
    lurek.log.info("custom bars visible=" .. tostring(visible))
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
| `value` | number|table | Legacy id or typed `{ tileset, tile?/object? }` ref stored for the slot. |

**Example**

```lua
do

    local field = lurek.tilefield.new({ width = 4, height = 4, levels = 2 })
    field:setRef(2, 2, 1, "object", 101)
    local value = field:getRef(2, 2, 1, "object")
    local slots = field:getRefSlots()
    lurek.log.info("setRef object=" .. tostring(value) .. " slots=" .. #slots)
end
```

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

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local cells = { { x = 2, y = 2, z = 1 }, { x = 3, y = 2, z = 1 } }
    field:setRegionCells("stairs", cells)
    local ok = field:regionContains("stairs", 3, 2, 1)
    lurek.log.info("setRegionCells contains=" .. tostring(ok))
end
```

---

#### `LTileField:setRegionProperty`

Sets or clears one string property on a named region. Numbers and booleans are stringified; nil removes the property.

```lua
LTileField:setRegionProperty(name, key, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Region name. |
| `key` | string | Property key. |
| `value` | any | String/number/boolean value, or nil to remove. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    field:setRegionCells("exit", { { x = 5, y = 2, z = 1 } })
    field:setRegionProperty("exit", "targetScene", "town_square")
    local target = field:getRegionProperty("exit", "targetScene")
    lurek.log.info("region property set = " .. tostring(target))
end
```

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

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setRegionRect("room", 2, 2, 3, 2, 1)
        return field:regionContains("room", 2, 2, 1)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileField:setResource`

Sets or clears a resource label on one tile cell.

```lua
LTileField:setResource(x, y, z, resource)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `resource?` | string | Resource label, or nil to clear. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 8, height = 8 })
    field:setResource(2, 3, 1, "ore")
    local resource = field:getResource(2, 3, 1)
    local has_resource = resource ~= nil
    lurek.log.info("resource set=" .. tostring(resource) .. " present=" .. tostring(has_resource))
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
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `value` | number | Top-light occlusion value in the inclusive range 0..1. |

**Example**

```lua
do

    local field = lurek.tilefield.new({ width = 2, height = 2, levels = 2 })
    field:setSunOcclusion(1, 1, 2, 0.5)
    local value = field:getSunOcclusion(1, 1, 2)
    local default = field:getSunOcclusion(2, 2, 2)
    lurek.log.info("sun occlusion=" .. value .. " default=" .. default)
end
```

---

#### `LTileField:snapshot`

Captures block/cost/ref layers plus resource, buildable, and occupant cell facts.

```lua
LTileField:snapshot()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Snapshot table suitable for `restore`. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 1 })
    field:defineBlockWorldSlots()
    field:setRef(2, 2, 1, "foreground", 12)
    field:setResource(3, 2, 1, "copper")
    local snapshot = field:snapshot()
    lurek.log.info("snapshot width=" .. tostring(snapshot.width))
    lurek.log.info("snapshot resources=" .. tostring(#snapshot.resources))
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
    lurek.log.info("type=" .. type_name .. " ok=" .. tostring(expected) .. " object=" .. tostring(object))
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
    lurek.log.info("typeOf exact=" .. tostring(exact) .. " object=" .. tostring(object) .. " miss=" .. tostring(miss))
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

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:writeBlockLayer("move", 1, { true, false, false, true })
        return field:blocks(1, 1, 1, "move")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

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

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:writeCostLayer("move", 1, { 1, 2, 3, 4 })
        return field:getCost(2, 2, 1, "move")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

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

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:writeRefLayer("object", 1, { 1, nil, 3, 4 })
        return field:getRef(1, 2, 1, "object")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

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

    local map = lurek.tilefield.newFieldMap({ width = 2, height = 2, layers = 2, fieldWidth = 3, fieldHeight = 3 })
    local field = map:getField(2, 2, 2)
    field:setRef(1, 1, 1, "floor", 12)
    local shared = map:getField(2, 2, 2):getRef(1, 1, 1, "floor")
    lurek.log.info("shared field ref=" .. tostring(shared))
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

    local map = lurek.tilefield.newFieldMap({ width = 1, height = 1, fieldWidth = 8, fieldHeight = 6, fieldLevels = 2 })
    local width, height, levels = map:getFieldSize()
    local cells = width * height * levels
    local field = map:getField(1, 1, 1)
    lurek.log.info("field cells=" .. cells .. " type=" .. field:type())
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

    local map = lurek.tilefield.newFieldMap({ width = 3, height = 2, layers = 1, fieldWidth = 4, fieldHeight = 4 })
    local width, height, layers = map:getMapSize()
    local slots = width * height * layers
    local valid = slots == 6
    lurek.log.info("map slots=" .. slots .. " valid=" .. tostring(valid))
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

    local map = lurek.tilefield.newFieldMap({ width = 1, height = 1, fieldWidth = 4, fieldHeight = 4, topology = "hex" })
    local topology = map:getTopology()
    local field = map:getField(1, 1, 1)
    local same = field:getTopology() == topology
    lurek.log.info("fieldmap topology=" .. topology .. " same=" .. tostring(same))
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

    local map = lurek.tilefield.newFieldMap({ width = 2, height = 2, layers = 2, fieldWidth = 3, fieldHeight = 3 })
    local inside = map:inBounds(2, 2, 2)
    local outside = map:inBounds(3, 1, 1)
    local default_layer = map:inBounds(1, 1)
    lurek.log.info("fieldmap bounds=" .. tostring(inside) .. "," .. tostring(outside) .. "," .. tostring(default_layer))
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

    local map = lurek.tilefield.newFieldMap({ width = 1, height = 1, layers = 1, fieldWidth = 3, fieldHeight = 3, topology = "square8" })
    local field = lurek.tilefield.new({ width = 3, height = 3, topology = "square8" })
    field:setRef(2, 2, 1, "object", 90)
    map:setField(1, 1, 1, field)
    lurek.log.info("stored object=" .. tostring(map:getField(1, 1, 1):getRef(2, 2, 1, "object")))
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

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        local map = lurek.tilefield.newFieldMap({ width = 2, height = 3, layers = 2, fieldWidth = 4, fieldHeight = 5, fieldLevels = 2 })
        return map:type()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

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

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        local map = lurek.tilefield.newFieldMap({ width = 2, height = 3, layers = 2, fieldWidth = 4, fieldHeight = 5, fieldLevels = 2 })
        return map:typeOf("LTileFieldMap")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---
