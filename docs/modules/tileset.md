# Tileset

## Purpose

lurek.tileset owns reusable tileset metadata: atlas geometry, tile properties, object archetypes, animation frames, autotile rules, and catalogs that resolve typed tilefield refs for tilemap rendering.

## Summary

- `LTileSet` describes what tile ids mean inside one atlas, independent of map storage and gameplay fields.
- Atlas geometry covers first gid, tile count, columns, tile size, spacing, margin, and computed source quads.
- Tile properties are arbitrary author metadata and are useful for editor imports, object refs, and examples.
- Object archetypes describe named tile objects with optional visual, blocker, cost, and property data.
- Tile animations stay local to the tileset so tilemap rendering can ask for the current tile frame.
- Autotile rules map neighborhood masks to tile ids, while tilemap owns where those rules are applied.
- `LTileCatalog` stores named tilesets and resolves `{ tileset, tile/object }` refs from tilefield slots.
- The legacy `lurek.tilemap.newTileSet` alias remains a compatibility path, but new code should use `lurek.tileset.newTileSet`.

This module primarily collaborates with `math`, `runtime`, `tilefield`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## API Reference

- This page is the generated API reference for this module.

## Functions

### `lurek.tileset.fromProvider`

Builds a native tileset from a Lua provider table with atlas fields, objects, tileObjects, properties, and animations.

```lua
lurek.tileset.fromProvider(provider)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `provider` | table | Lua-authored tileset provider. |

**Returns**

| Type | Description |
|------|-------------|
| [LTileSet](#ltileset) | New tileset copied from provider data. |

**Example**

```lua
do
    local tileset = lurek.tileset.fromProvider({
        firstGid = 1,
        tileCount = 4,
        columns = 2,
        tileWidth = 16,
        tileHeight = 16,
        objects = {
            crate = { slot = "object", visual = { image = "crate.png", order = 2 } },
        },
    })
    lurek.log.info("provider object = " .. tileset:getObject("crate").name)
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

### `lurek.tileset.newCatalog`

Creates a catalog that resolves typed references across named tilesets.

```lua
lurek.tileset.newCatalog(entries)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `entries` | table | Map of catalog id to `[LTileSet](#ltileset)`. |

**Returns**

| Type | Description |
|------|-------------|
| [LTileCatalog](#ltilecatalog) | New tile catalog handle. |

**Example**

```lua
do
    local terrain = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    local catalog = lurek.tileset.newCatalog({ terrain = terrain })
    lurek.log.info("catalog ids = " .. #catalog:getIds())
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

### `lurek.tileset.newTileSet`

Creates a native tileset from atlas dimensions.

```lua
lurek.tileset.newTileSet(first_gid, tile_count, columns, tile_width, tile_height, spacing, margin)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `first_gid` | number | First global tile id assigned to the tileset. |
| `tile_count` | number | Number of tiles in the atlas. |
| `columns` | number | Number of atlas columns. |
| `tile_width` | number | Tile width in pixels. |
| `tile_height` | number | Tile height in pixels. |
| `spacing?` | number | Optional pixel spacing between tiles. |
| `margin?` | number | Optional atlas margin in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| [LTileSet](#ltileset) | New tileset handle. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(1, 16, 4, 16, 16, 1, 2)
    lurek.log.info("tileset first gid = " .. tileset:getFirstGid())
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LTileCatalog](#ltilecatalog)
- [LTileSet](#ltileset)

## LTileCatalog

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTileCatalog:getIds`

Returns the sorted catalog ids available for typed tile references.

```lua
LTileCatalog:getIds()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of catalog id strings. |

**Example**

```lua
do
    local catalog = lurek.tileset.newCatalog({ terrain = lurek.tileset.newTileSet(1, 4, 2, 16, 16) })
    lurek.log.info("first catalog id = " .. catalog:getIds()[1])
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileCatalog:getObject`

Resolves object archetype metadata from a typed tile or object reference.

```lua
LTileCatalog:getObject(reference)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `reference` | table | Reference table with `tileset` and either `tile` or `object`. |

**Returns**

| Type | Description |
|------|-------------|
| table | nil | Object archetype table, or nil when the reference cannot resolve. |

**Example**

```lua
do
    local tileset = lurek.tileset.fromProvider({
        tileCount = 4,
        columns = 2,
        tileWidth = 16,
        tileHeight = 16,
        objects = { crate = { slot = "object", tileId = 2 } },
        tileObjects = { [2] = "crate" },
    })
    local catalog = lurek.tileset.newCatalog({ props = tileset })
    lurek.log.info("catalog object = " .. catalog:getObject({ tileset = "props", tile = 2 }).name)
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileCatalog:getTileset`

Returns the tileset stored under a catalog id.

```lua
LTileCatalog:getTileset(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Catalog id to resolve. |

**Returns**

| Type | Description |
|------|-------------|
| [LTileSet](#ltileset) | nil | Tileset for the id, or nil when missing. |

**Example**

```lua
do
    local terrain = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    local catalog = lurek.tileset.newCatalog({ terrain = terrain })
    lurek.log.info("catalog tileset type = " .. catalog:getTileset("terrain"):type())
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileCatalog:getVisual`

Resolves render visual metadata from a typed tile or object reference.

```lua
LTileCatalog:getVisual(reference)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `reference` | table | Reference table with `tileset` and either `tile` or `object`. |

**Returns**

| Type | Description |
|------|-------------|
| table | nil | Visual metadata table, or nil when the reference has no visual. |

**Example**

```lua
do
    local tileset = lurek.tileset.fromProvider({
        tileCount = 4,
        columns = 2,
        tileWidth = 16,
        tileHeight = 16,
        objects = { crate = { slot = "object", visual = { image = "crate.png" } } },
    })
    local catalog = lurek.tileset.newCatalog({ props = tileset })
    lurek.log.info("catalog visual = " .. catalog:getVisual({ tileset = "props", object = "crate" }).image)
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileCatalog:type`

Returns the Lua-visible userdata type name for this tile catalog.

```lua
LTileCatalog:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always `[LTileCatalog](#ltilecatalog)`. |

**Example**

```lua
do
    local catalog = lurek.tileset.newCatalog({ terrain = lurek.tileset.newTileSet(1, 4, 2, 16, 16) })
    lurek.log.info("catalog type = " .. catalog:type())
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileCatalog:typeOf`

Checks whether this catalog matches a type name.

```lua
LTileCatalog:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True for `[LTileCatalog](#ltilecatalog)` or `LObject`. |

**Example**

```lua
do
    local catalog = lurek.tileset.newCatalog({ terrain = lurek.tileset.newTileSet(1, 4, 2, 16, 16) })
    lurek.log.info("is catalog = " .. tostring(catalog:typeOf("LTileCatalog")))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

## LTileSet

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTileSet:getAnimation`

Returns the animation frames for one tile.

```lua
LTileSet:getAnimation(tile_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tile_id` | number | Tile id (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| table | nil | Array of frame tables, or nil when no animation exists. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setAnimation(1, { { tileid = 2, duration = 90 } })
    lurek.log.info("animation tile = " .. tileset:getAnimation(1)[1].tileid)
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileSet:getAutoTileId`

Resolves a four-neighbor autotile bitmask to a tile id.

```lua
LTileSet:getAutoTileId(type_name, bitmask)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_name` | string | Logical tile type name. |
| `bitmask` | number | Four-neighbor bitmask. |

**Returns**

| Type | Description |
|------|-------------|
| number | nil | Tile id (1-based), or nil when no rule exists. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setAutoTileRule("road", 5, 6)
    lurek.log.info("autotile id = " .. tileset:getAutoTileId("road", 5))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileSet:getAutoTileId8`

Resolves an eight-neighbor autotile bitmask to a tile id.

```lua
LTileSet:getAutoTileId8(type_name, bitmask)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_name` | string | Logical tile type name. |
| `bitmask` | number | Eight-neighbor bitmask. |

**Returns**

| Type | Description |
|------|-------------|
| number | nil | Tile id (1-based), or nil when no rule exists. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(1, 32, 8, 16, 16)
    tileset:setAutoTileRule8("cliff", 7, 9)
    lurek.log.info("autotile id8 = " .. tileset:getAutoTileId8("cliff", 7))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileSet:getAutoTileMode`

Returns the autotile matching mode for a tile type.

```lua
LTileSet:getAutoTileMode(type_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_name` | string | Logical tile type name. |

**Returns**

| Type | Description |
|------|-------------|
| string | Autotile matching mode. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(1, 32, 8, 16, 16)
    tileset:setAutoTileMode("road", "matchSides")
    lurek.log.info("autotile mode = " .. tileset:getAutoTileMode("road"))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileSet:getColumns`

Returns the number of atlas columns.

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
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    lurek.log.info("columns = " .. tileset:getColumns())
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileSet:getFirstGid`

Returns the first global tile id assigned to this tileset.

```lua
LTileSet:getFirstGid()
```

**Returns**

| Type | Description |
|------|-------------|
| number | First global tile id. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(10, 8, 4, 16, 16)
    lurek.log.info("first gid = " .. tileset:getFirstGid())
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileSet:getMargin`

Returns the atlas margin in pixels.

```lua
LTileSet:getMargin()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Atlas margin. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16, 0, 3)
    lurek.log.info("margin = " .. tileset:getMargin())
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileSet:getObject`

Returns object archetype metadata by name.

```lua
LTileSet:getObject(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Object archetype name. |

**Returns**

| Type | Description |
|------|-------------|
| table | nil | Object metadata table, or nil when missing. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setObject("crate", { slot = "object", properties = { material = "wood" } })
    lurek.log.info("object material = " .. tileset:getObject("crate").properties.material)
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileSet:getObjectNames`

Returns all object archetype names in this tileset.

```lua
LTileSet:getObjectNames()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of object archetype names. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setObject("crate", { slot = "object" })
    lurek.log.info("object names = " .. table.concat(tileset:getObjectNames(), ","))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileSet:getPhysicsShape`

Returns the physics shape label for one tile.

```lua
LTileSet:getPhysicsShape(tile_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tile_id` | number | Tile id (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| string | nil | Physics shape label, or nil when unset. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setPhysicsShape(2, "slope")
    lurek.log.info("shape = " .. tileset:getPhysicsShape(2))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileSet:getProfile`

Returns the named gameplay profile for one tile.

```lua
LTileSet:getProfile(tile_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tile_id` | number | Tile id (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| string | nil | Profile name, or nil when unset. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setProfile(2, "floor")
    lurek.log.info("profile = " .. tileset:getProfile(2))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileSet:getProperties`

Returns all custom properties for one tile.

```lua
LTileSet:getProperties(tile_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tile_id` | number | Tile id (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| table | Property name/value table. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setProperty(2, "biome", "forest")
    lurek.log.info("properties biome = " .. tileset:getProperties(2).biome)
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileSet:getProperty`

Returns a custom tile property as a string.

```lua
LTileSet:getProperty(tile_id, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tile_id` | number | Tile id (1-based). |
| `name` | string | Property name. |

**Returns**

| Type | Description |
|------|-------------|
| string | nil | Property value, or nil when unset. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setProperty(2, "biome", "forest")
    lurek.log.info("property = " .. tileset:getProperty(2, "biome"))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileSet:getPropertyBool`

Returns a custom tile property parsed as a boolean.

```lua
LTileSet:getPropertyBool(tile_id, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tile_id` | number | Tile id (1-based). |
| `name` | string | Property name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | nil | Boolean property value, or nil when unset or not boolean. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setProperty(2, "solid", true)
    lurek.log.info("solid = " .. tostring(tileset:getPropertyBool(2, "solid")))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileSet:getPropertyNumber`

Returns a custom tile property parsed as a number.

```lua
LTileSet:getPropertyNumber(tile_id, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tile_id` | number | Tile id (1-based). |
| `name` | string | Property name. |

**Returns**

| Type | Description |
|------|-------------|
| number | nil | Numeric property value, or nil when unset or not numeric. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setProperty(2, "cost", 2.5)
    lurek.log.info("cost = " .. tileset:getPropertyNumber(2, "cost"))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileSet:getQuad`

Returns the atlas rectangle for one tile id.

```lua
LTileSet:getQuad(tile_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tile_id` | number | Tile id (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| table | Rectangle table with x, y, width, and height. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    local quad = tileset:getQuad(3)
    lurek.log.info("quad = " .. quad.x .. "," .. quad.y .. "," .. quad.width .. "," .. quad.height)
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileSet:getSpacing`

Returns the spacing between atlas tiles in pixels.

```lua
LTileSet:getSpacing()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Tile spacing. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16, 2, 0)
    lurek.log.info("spacing = " .. tileset:getSpacing())
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileSet:getTerrainProfile`

Returns a Godot-style terrain-set profile.

```lua
LTileSet:getTerrainProfile(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Profile name. |

**Returns**

| Type | Description |
|------|-------------|
| table | nil | Profile table or nil. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(1, 16, 4, 16, 16)
    tileset:setTerrainProfile("water", { terrainSet = "liquid", mode = "matchSides", defaultTileId = 2 })
    local profile = tileset:getTerrainProfile("water")
    local id = profile.defaultTileId
    lurek.log.info("[tileset] terrain default=" .. tostring(id))
end
```

---

#### `LTileSet:getTextureDimensions`

Returns the computed texture width and height in pixels.

```lua
LTileSet:getTextureDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Texture width. |
| number | Texture height. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16, 1, 2)
    local w, h = tileset:getTextureDimensions()
    lurek.log.info("texture dimensions = " .. w .. "x" .. h)
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileSet:getTileCount`

Returns the number of tile entries in this tileset.

```lua
LTileSet:getTileCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Tile count. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    lurek.log.info("tile count = " .. tileset:getTileCount())
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileSet:getTileDimensions`

Returns the tile width and height in pixels.

```lua
LTileSet:getTileDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Tile width. |
| number | Tile height. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    local w, h = tileset:getTileDimensions()
    lurek.log.info("tile dimensions = " .. w .. "x" .. h)
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileSet:getTileHeight`

Returns the height of each tile in pixels.

```lua
LTileSet:getTileHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Tile height. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    lurek.log.info("tile height = " .. tileset:getTileHeight())
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileSet:getTileObject`

Returns the object archetype name mapped to one tile.

```lua
LTileSet:getTileObject(tile_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tile_id` | number | Tile id (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| string | nil | Object archetype name, or nil when unmapped. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setObject("tree", { slot = "object" })
    tileset:setTileObject(4, "tree")
    lurek.log.info("tile object = " .. tileset:getTileObject(4))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileSet:getTileWidth`

Returns the width of each tile in pixels.

```lua
LTileSet:getTileWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Tile width. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    lurek.log.info("tile width = " .. tileset:getTileWidth())
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileSet:removeObject`

Removes an object archetype by name.

```lua
LTileSet:removeObject(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Object archetype name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when an archetype was removed. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setObject("crate", { slot = "object" })
    lurek.log.info("removed = " .. tostring(tileset:removeObject("crate")))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileSet:setAnimation`

Replaces the animation frames for one tile.

```lua
LTileSet:setAnimation(tile_id, frames)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tile_id` | number | Tile id (1-based). |
| `frames` | table | Array of frame tables with `tileid` and `duration`. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setAnimation(1, { { tileid = 1, duration = 120 }, { tileid = 2, duration = 120 } })
    lurek.log.info("animation frames = " .. #tileset:getAnimation(1))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileSet:setAutoTileMode`

Sets the autotile matching mode for a tile type.

```lua
LTileSet:setAutoTileMode(type_name, mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_name` | string | Logical tile type name. |
| `mode` | string | One of `matchSides`, `matchCorners`, or `matchCornersAndSides`. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(1, 32, 8, 16, 16)
    tileset:setAutoTileMode("water", "matchCornersAndSides")
    lurek.log.info("autotile mode set = " .. tileset:getAutoTileMode("water"))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileSet:setAutoTileRule`

Sets a four-neighbor autotile bitmask rule for a tile type.

```lua
LTileSet:setAutoTileRule(type_name, bitmask, tile_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_name` | string | Logical tile type name. |
| `bitmask` | number | Four-neighbor bitmask. |
| `tile_id` | number | Tile id (1-based) to emit for the bitmask. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setAutoTileRule("wall", 3, 7)
    lurek.log.info("autotile rule = " .. tileset:getAutoTileId("wall", 3))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileSet:setAutoTileRule8`

Sets an eight-neighbor autotile bitmask rule for a tile type.

```lua
LTileSet:setAutoTileRule8(type_name, bitmask, tile_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_name` | string | Logical tile type name. |
| `bitmask` | number | Eight-neighbor bitmask. |
| `tile_id` | number | Tile id (1-based) to emit for the bitmask. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(1, 32, 8, 16, 16)
    tileset:setAutoTileRule8("water", 255, 12)
    lurek.log.info("autotile rule8 = " .. tileset:getAutoTileId8("water", 255))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileSet:setObject`

Stores an object archetype and its visual, pathing, lighting, and custom metadata.

```lua
LTileSet:setObject(name, object)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Object archetype name. |
| `object` | table | Object metadata table. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setObject("torch", { slot = "object", visual = { sprite = "torch" }, light = { radius = 4 } })
    lurek.log.info("object set = " .. tileset:getObject("torch").name)
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileSet:setPhysicsShape`

Sets or clears the physics shape label for one tile.

```lua
LTileSet:setPhysicsShape(tile_id, shape)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tile_id` | number | Tile id (1-based). |
| `shape?` | string | Physics shape label, or nil/empty to clear it. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setPhysicsShape(2, "solid")
    lurek.log.info("shape set = " .. tileset:getPhysicsShape(2))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileSet:setProfile`

Sets or clears the named gameplay profile for one tile.

```lua
LTileSet:setProfile(tile_id, profile)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tile_id` | number | Tile id (1-based). |
| `profile?` | string | Profile name, or nil/empty to clear it. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setProfile(2, "wall")
    lurek.log.info("profile set = " .. tileset:getProfile(2))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileSet:setProperty`

Sets or clears a custom string-convertible tile property.

```lua
LTileSet:setProperty(tile_id, name, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tile_id` | number | Tile id (1-based). |
| `name` | string | Property name. |
| `value` | any | String, number, boolean, or nil to clear the property. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setProperty(2, "cost", 3)
    lurek.log.info("property set = " .. tileset:getProperty(2, "cost"))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileSet:setTerrainProfile`

Sets a Godot-style terrain-set profile for autotile authoring.

```lua
LTileSet:setTerrainProfile(name, profile)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Profile name. |
| `profile` | table | `{terrainSet, mode, defaultTileId?}`. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(1, 16, 4, 16, 16)
    tileset:setTerrainProfile("grass", { terrainSet = "ground", mode = "matchCornersAndSides", defaultTileId = 1 })
    local profile = tileset:getTerrainProfile("grass")
    local mode = profile.mode
    lurek.log.info("[tileset] terrain profile mode=" .. mode)
end
```

---

#### `LTileSet:setTileObject`

Assigns or clears the object archetype mapped to one tile.

```lua
LTileSet:setTileObject(tile_id, object_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tile_id` | number | Tile id (1-based). |
| `object_name?` | string | Object archetype name, or nil to clear it. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setObject("crate", { slot = "object" })
    tileset:setTileObject(3, "crate")
    lurek.log.info("tile object set = " .. tileset:getTileObject(3))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileSet:type`

Returns the Lua-visible userdata type name for this tileset.

```lua
LTileSet:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always `[LTileSet](#ltileset)`. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    lurek.log.info("tileset type = " .. tileset:type())
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---

#### `LTileSet:typeOf`

Checks whether this tileset matches a type name.

```lua
LTileSet:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True for `[LTileSet](#ltileset)` or `LObject`. |

**Example**

```lua
do
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    lurek.log.info("is tileset = " .. tostring(tileset:typeOf("LTileSet")))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
```

---
