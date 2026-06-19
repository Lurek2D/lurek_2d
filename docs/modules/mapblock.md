# Mapblock

## Summary

- The `mapblock` module is the engine's modular map-assembly surface for users who want larger spaces built from reusable authored blocks instead of from one monolithic generator.
- Blocks, sockets, constraints, groups, scripts, orientation rules, and multilevel placement live together here so handcrafted pieces can recombine without losing local design intent.
- The module is especially useful for dungeons, modular interiors, overworld chunks, and other generators where the meaningful unit is a room or chunk rather than an individual tile.
- Constraint and socket logic are central because modular generation only works when legal adjacency, facing, and connector rules remain explicit and enforceable.
- Placement state and output shaping matter because the system must not only choose valid pieces, but also produce results that downstream tilemap, navigation, and render workflows can use safely.
- Construction and generation now reject oversized block requests, invalid weights, and level-span overflow before they can degrade into silent no-ops or unchecked allocation paths.
- Rust callers can inspect per-run generator diagnostics for missing groups, unsupported steps, invalid weights, placement stalls, and rejected paint operations.
- Script hooks and grouping support make the system adaptable to thematic or progression-aware generation, which is important when modular pieces need more nuance than simple random choice.
- Orientation and multilevel handling matter because reusable blocks often connect vertically or directionally, and the legality of the final layout depends on those relationships being tracked explicitly.
- This makes the module useful whenever designed pieces need to stay meaningful after recombination. A corridor, room, bridge, or stair block can keep its authored purpose while still participating in procedural assembly.
- It preserves authored intent while still enabling recombination.
- Neighboring modules consume the output, but `mapblock` owns the modular grammar that decides how authored fragments connect into a legal larger space.
- Read `mapblock` as the subsystem that turns reusable map pieces into generated layouts with explicit connection rules.

This module primarily collaborates with `procgen`. Its responsibility should stay inside the `Edge/Integration` group rather than absorb behavior owned by those neighbors.

## Functions

### `lurek.mapblock.newBlock`

Create a new map block exposed by the lurek engine.

```lua
lurek.mapblock.newBlock(width, height, layers, config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Block width in tiles. |
| `height` | number | Block height in tiles. |
| `layers` | number | Number of layers. |
| `config` | [LMapBlockConfig](#lmapblockconfig) | Configuration to use. |

**Returns**

| Type | Description |
|------|-------------|
| [LMapBlock](#lmapblock) | New block. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 4, 1, cfg)
    block:setName("entrance_room")
    local width = block:getWidth()
    local height = block:getHeight()
    mapblock_log("newBlock dims=" .. width .. "x" .. height)
    mapblock_log("newBlock layers=" .. block:getLayerCount())
    mapblock_log("newBlock name=" .. block:getName())
end
```

---

### `lurek.mapblock.newConfig`

Create a new map block configuration with default slots.

```lua
lurek.mapblock.newConfig()
```

**Returns**

| Type | Description |
|------|-------------|
| [LMapBlockConfig](#lmapblockconfig) | New configuration. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    cfg:addSlot("detail", false, 0)
    local slots = cfg:getSlotCount()
    mapblock_log("newConfig slotCount=" .. slots)
    mapblock_log("newConfig supports detail slot=" .. tostring(slots > 0))
    mapblock_log("newConfig ready for layered room blocks")
end
```

---

### `lurek.mapblock.newEmptyConfig`

Create an empty config with no predefined slots.

```lua
lurek.mapblock.newEmptyConfig()
```

**Returns**

| Type | Description |
|------|-------------|
| [LMapBlockConfig](#lmapblockconfig) | Empty configuration. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newEmptyConfig()
    cfg:addSlot("floor", true, 0)
    cfg:addSlot("wall", false, 0)
    local slots = cfg:getSlotCount()
    mapblock_log("newEmptyConfig slotCount=" .. slots)
    mapblock_log("newEmptyConfig keeps only authored slots")
    mapblock_log("newEmptyConfig wall slot added=" .. tostring(slots == 2))
end
```

---

### `lurek.mapblock.newEmptyGrid`

Create an empty placement grid (for arbitrary shapes).

```lua
lurek.mapblock.newEmptyGrid()
```

**Returns**

| Type | Description |
|------|-------------|
| [LPlacementGrid](#lplacementgrid) | Empty grid. |

**Example**

```lua
do
    local grid = lurek.mapblock.newEmptyGrid()
    grid:addPosition(2, 2)
    grid:addPosition(2, 3)
    mapblock_log("newEmptyGrid available=" .. grid:getAvailableCount())
    mapblock_log("newEmptyGrid position 2,2 available=" .. tostring(grid:isAvailable(2, 2)))
    mapblock_log("newEmptyGrid supports arbitrary shapes")
end
```

---

### `lurek.mapblock.newGenerator`

Create a new procedural map block generator instance.

```lua
lurek.mapblock.newGenerator(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config` | [LMapBlockConfig](#lmapblockconfig) | Configuration. |

**Returns**

| Type | Description |
|------|-------------|
| [LMapBlockGenerator](#lmapblockgenerator) | New generator. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(6, 4)
    gen:setSeed(17)
    gen:setMaxLevels(2)
    mapblock_log("newGenerator ready=true")
    mapblock_log("newGenerator shape set to 6x4")
    mapblock_log("newGenerator max levels configured")
end
```

---

### `lurek.mapblock.newGrid`

Create a rectangular placement grid.

```lua
lurek.mapblock.newGrid(width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Grid width. |
| `height` | number | Grid height. |

**Returns**

| Type | Description |
|------|-------------|
| [LPlacementGrid](#lplacementgrid) | New grid. |

**Example**

```lua
do
    local grid = lurek.mapblock.newGrid(10, 10)
    grid:addPosition(3, 4)
    grid:addPosition(4, 4)
    mapblock_log("newGrid available=" .. grid:getAvailableCount())
    mapblock_log("newGrid position 3,4 available=" .. tostring(grid:isAvailable(3, 4)))
    mapblock_log("newGrid edge position 3,4=" .. tostring(grid:isEdgePosition(3, 4)))
end
```

---

### `lurek.mapblock.newGroup`

Create a new map group exposed by the lurek engine.

```lua
lurek.mapblock.newGroup(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Group name. |

**Returns**

| Type | Description |
|------|-------------|
| [LMapGroup](#lmapgroup) | New group. |

**Example**

```lua
do
    local group = lurek.mapblock.newGroup("rooms")
    local script = lurek.mapblock.newScript("rooms_pass")
    group:addScript(script)
    mapblock_log("newGroup name=" .. group:getName())
    mapblock_log("newGroup blockCount=" .. group:getBlockCount())
    mapblock_log("newGroup accepts scripts for themed passes")
end
```

---

### `lurek.mapblock.newRules`

Create new neighbor rules exposed by the lurek engine.

```lua
lurek.mapblock.newRules()
```

**Returns**

| Type | Description |
|------|-------------|
| [LNeighborRules](#lneighborrules) | New rules. |

**Example**

```lua
do
    local rules = lurek.mapblock.newRules()
    rules:addCompatible(1, 2)
    rules:addCompatibleOneWay(3, 4)
    mapblock_log("newRules compatible12=" .. tostring(rules:isCompatible(1, 2)))
    mapblock_log("newRules compatible34=" .. tostring(rules:isCompatible(3, 4)))
    mapblock_log("newRules reverse43=" .. tostring(rules:isCompatible(4, 3)))
end
```

---

### `lurek.mapblock.newScript`

Create a new map script exposed by the lurek engine.

```lua
lurek.mapblock.newScript(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name?` | string | Script name. |

**Returns**

| Type | Description |
|------|-------------|
| [LMapScript](#lmapscript) | New script. |

**Example**

```lua
do
    local script = lurek.mapblock.newScript("layout_pass")
    script:addStep("fill_rect", { x = 0, y = 0, width = 4, height = 3, tile_id = 1, slot = 0, layer = 0 })
    script:addStep("fill_edges", { tile_id = 2, slot = 0, layer = 0 })
    mapblock_log("newScript steps=" .. script:getStepCount())
    mapblock_log("newScript name=" .. script:getName())
    mapblock_log("newScript ready for layout pass")
end
```

---

### `lurek.mapblock.newTilesetRef`

Create a tileset reference exposed by the lurek engine.

```lua
lurek.mapblock.newTilesetRef(id, name, tile_count, columns, tile_width, tile_height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Tileset ID. |
| `name` | string | Tileset name. |
| `tile_count` | number | Number of tiles. |
| `columns` | number | Columns in tileset image. |
| `tile_width` | number | Tile pixel width. |
| `tile_height` | number | Tile pixel height. |

**Returns**

| Type | Description |
|------|-------------|
| [LTilesetRef](#ltilesetref) | New tileset reference. |

**Example**

```lua
do
    local ref = lurek.mapblock.newTilesetRef(1, "ground_tiles", 64, 8, 32, 32)
    ref:setImagePath("content/examples/assets/mapblock_ground.png")
    mapblock_log("newTilesetRef id=" .. ref:getId())
    mapblock_log("newTilesetRef name=" .. ref:getName())
    mapblock_log("newTilesetRef image path configured for preview")
end
```

---

## Module Fields

*No module-level fields documented.*

## Callbacks

*No callback parameters documented in this module.*

## Enums

*No module-specific enums documented.*

## Types

- [LMapBlock](#lmapblock)
- [LMapBlockConfig](#lmapblockconfig)
- [LMapBlockGenerator](#lmapblockgenerator)
- [LMapBlockReport](#lmapblockreport)
- [LMapBlockResult](#lmapblockresult)
- [LMapGroup](#lmapgroup)
- [LMapScript](#lmapscript)
- [LNeighborRules](#lneighborrules)
- [LPlacementGrid](#lplacementgrid)
- [LTilesetRef](#ltilesetref)

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

**Example**

```lua
do
    local block = lurek.tilemap.newMapBlock(6, 4, 1, 1)
    local width, height = block:getDimensions()
    mapblock_log("getDimensions=" .. tostring(width) .. "x" .. tostring(height))
    mapblock_log("getDimensions widthSegments=" .. tostring(block:getWidthInSegments()))
    mapblock_log("getDimensions heightSegments=" .. tostring(block:getHeightInSegments()))
end
```

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

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    cfg:setDefaultSegmentSize(1)
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setFootprint({ { 0, 0 }, { 1, 0 }, { 0, 1 } })
    example_print_log("getFootprintCellCount=" .. tostring(block:getFootprintCellCount()))
end
```

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

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 3, 1, cfg)
    block:setName("hallway")
    mapblock_log("getHeight=" .. block:getHeight())
    mapblock_log("getHeight width=" .. block:getWidth())
    mapblock_log("getHeight name=" .. block:getName())
end
```

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

**Example**

```lua
do
    local block = lurek.tilemap.newMapBlock(6, 4, 1, 2)
    mapblock_log("getHeightInSegments=" .. tostring(block:getHeightInSegments()))
    mapblock_log("getHeightInSegments dims=" .. tostring(block:getWidth()) .. "x" .. tostring(block:getHeight()))
    mapblock_log("getHeightInSegments segmentSize=" .. tostring(block:getSegmentSize()))
    mapblock_log("getHeightInSegments type=" .. tostring(block:type()))
end
```

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

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 3, 2, cfg)
    block:setName("multi_layer_room")
    mapblock_log("getLayerCount=" .. block:getLayerCount())
    mapblock_log("getLayerCount width=" .. block:getWidth())
    mapblock_log("getLayerCount name=" .. block:getName())
end
```

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

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setName("room_a")
    block:setWeight(2.0)
    mapblock_log("getName=" .. block:getName())
    mapblock_log("getName weight=" .. tostring(block:getWeight()))
    mapblock_log("getName dims=" .. tostring(block:getWidth()) .. "x" .. tostring(block:getHeight()))
end
```

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

**Example**

```lua
do
    local block = lurek.tilemap.newMapBlock(6, 4, 1, 2)
    mapblock_log("getSegmentSize=" .. tostring(block:getSegmentSize()))
    mapblock_log("getSegmentSize widthSegments=" .. tostring(block:getWidthInSegments()))
    mapblock_log("getSegmentSize heightSegments=" .. tostring(block:getHeightInSegments()))
    mapblock_log("getSegmentSize dims=" .. tostring(block:getWidth()) .. "x" .. tostring(block:getHeight()))
end
```

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

**Example**

```lua
do
    local block = lurek.tilemap.newMapBlock(4, 4, 1, 1)
    block:setSide("east", 1, 11)
    block:setSide("west", 1, 5)
    mapblock_log("getSide east1=" .. tostring(block:getSide("east", 1)))
    mapblock_log("getSide west1=" .. tostring(block:getSide("west", 1)))
    mapblock_log("getSide type=" .. tostring(block:type()))
end
```

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

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    cfg:setDefaultSegmentSize(1)
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setFootprint({ { 0, 0 }, { 1, 0 }, { 0, 1 } })
    block:setSocket(1, 0, "east", 9)
    example_print_log("getSocket=" .. tostring(block:getSocket(1, 0, "east")))
end
```

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

**Example**

```lua
do
    local cfg = lurek.mapblock.newEmptyConfig()
    cfg:addSlot("floor", true, 0)
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setTile(0, 1, 1, 0, 1, 9)
    local tile = block:getTile(0, 1, 1, 0)
    example_print_log("getTile value=" .. tostring(tile))
end
```

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

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setWeight(3.0)
    block:setName("rare_room")
    mapblock_log("getWeight=" .. tostring(block:getWeight()))
    mapblock_log("getWeight block=" .. block:getName())
    mapblock_log("getWeight dims=" .. tostring(block:getWidth()) .. "x" .. tostring(block:getHeight()))
end
```

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

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 3, 1, cfg)
    block:setName("entry")
    mapblock_log("getWidth=" .. block:getWidth())
    mapblock_log("getWidth height=" .. block:getHeight())
    mapblock_log("getWidth name=" .. block:getName())
end
```

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

**Example**

```lua
do
    local block = lurek.tilemap.newMapBlock(6, 4, 1, 2)
    mapblock_log("getWidthInSegments=" .. tostring(block:getWidthInSegments()))
    mapblock_log("getWidthInSegments dims=" .. tostring(block:getWidth()) .. "x" .. tostring(block:getHeight()))
    mapblock_log("getWidthInSegments segmentSize=" .. tostring(block:getSegmentSize()))
    mapblock_log("getWidthInSegments type=" .. tostring(block:type()))
end
```

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

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    cfg:setDefaultSegmentSize(1)
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setFootprint({ { 0, 0 }, { 1, 0 }, { 0, 1 } })
    example_print_log("isFootprintCell=" .. tostring(block:isFootprintCell(1, 0)))
end
```

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

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 4, 1, cfg)
    block:setEdge("north", 0, 2)
    block:setEdge("south", 0, 2)
    example_print_log("LMapBlock:setEdge width=" .. block:getWidth())
end
```

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

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 4, 1, cfg)
    block:setEdgeOnly(true)
    block:setName("perimeter_wall")
    mapblock_log("setEdgeOnly height=" .. block:getHeight())
    mapblock_log("setEdgeOnly block name=" .. block:getName())
    mapblock_log("setEdgeOnly keeps perimeter pieces on outer border")
end
```

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

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    cfg:setDefaultSegmentSize(1)
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setFootprint({ { 0, 0 }, { 1, 0 }, { 0, 1 } })
    example_print_log("setFootprint cells=" .. tostring(block:getFootprintCellCount()))
end
```

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

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 4, 1, cfg)
    block:setInteriorOnly(true)
    block:setName("treasure_room")
    mapblock_log("setInteriorOnly width=" .. block:getWidth())
    mapblock_log("setInteriorOnly block name=" .. block:getName())
    mapblock_log("setInteriorOnly reserves this block for inner cells")
end
```

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

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 4, 2, cfg)
    block:setLevelSpan(2)
    block:setName("stairwell")
    mapblock_log("setLevelSpan layers=" .. block:getLayerCount())
    mapblock_log("setLevelSpan block height=" .. block:getHeight())
    mapblock_log("setLevelSpan block name=" .. block:getName())
end
```

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

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setName("corridor")
    block:setWeight(1.5)
    mapblock_log("setName=" .. block:getName())
    mapblock_log("setName weight=" .. tostring(block:getWeight()))
    mapblock_log("setName dims=" .. tostring(block:getWidth()) .. "x" .. tostring(block:getHeight()))
end
```

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

**Example**

```lua
do
    local block = lurek.tilemap.newMapBlock(4, 4, 1, 1)
    block:setSide("north", 1, 7)
    block:setSide("south", 1, 9)
    mapblock_log("setSide north1=" .. tostring(block:getSide("north", 1)))
    mapblock_log("setSide south1=" .. tostring(block:getSide("south", 1)))
    mapblock_log("setSide type=" .. tostring(block:type()))
end
```

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

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    cfg:setDefaultSegmentSize(1)
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setFootprint({ { 0, 0 }, { 1, 0 }, { 0, 1 } })
    block:setSocket(1, 0, "east", 9)
    example_print_log("setSocket ok")
end
```

---

#### `LMapBlock:setTile`

Set a tile slot value â€” Lua userdata object exposed by the engine.

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

**Example**

```lua
do
    local cfg = lurek.mapblock.newEmptyConfig()
    cfg:addSlot("wall", true, 0)
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setTile(0, 1, 1, 0, 1, 5)
    example_print_log("setTile value=" .. tostring(block:getTile(0, 1, 1, 0)))
end
```

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

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setWeight(3.0)
    block:setName("rare_treasure_room")
    mapblock_log("setWeight ok")
    mapblock_log("setWeight value=" .. tostring(block:getWeight()))
    mapblock_log("setWeight block=" .. block:getName())
end
```

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

**Example**

```lua
do
    local block = lurek.tilemap.newMapBlock(2, 2, 1, 1)
    block:setSide("north", 1, 3)
    mapblock_log("LMapBlock:type=" .. tostring(block:type()))
    mapblock_log("LMapBlock:type north1=" .. tostring(block:getSide("north", 1)))
    mapblock_log("LMapBlock:type dims=" .. tostring(block:getWidth()) .. "x" .. tostring(block:getHeight()))
end
```

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

**Example**

```lua
do
    local block = lurek.tilemap.newMapBlock(2, 2, 1, 1)
    block:setSide("east", 1, 4)
    mapblock_log("LMapBlock:typeOf self=" .. tostring(block:typeOf("LMapBlock")))
    mapblock_log("LMapBlock:typeOf object=" .. tostring(block:typeOf("LObject")))
    mapblock_log("LMapBlock:typeOf east1=" .. tostring(block:getSide("east", 1)))
end
```

---

## LMapBlockConfig

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LMapBlockConfig:addSlot`

Add a slot definition â€” Lua userdata object exposed by the engine.

```lua
LMapBlockConfig:addSlot(name, required, default_gid)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Slot name. |
| `required?` | boolean | Whether this slot is required. |
| `default_gid?` | number | Default GID when empty. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    cfg:addSlot("wall", true, 0)
    cfg:addSlot("floor", false, 1)
    cfg:addSlot("ceiling", false, 0)
    mapblock_log("addSlot slotCount=" .. cfg:getSlotCount())
    mapblock_log("addSlot room config has ceiling slot")
    mapblock_log("addSlot supports authored wall/floor layering")
end
```

---

#### `LMapBlockConfig:getSlotCount`

Get the number of slots for this object.

```lua
LMapBlockConfig:getSlotCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Slot count. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    cfg:addSlot("layer1", true, 0)
    cfg:addSlot("layer2", false, 1)
    cfg:addSlot("layer3", false, 2)
    example_print_log("LMapBlockConfig:getSlotCount=" .. cfg:getSlotCount())
end
```

---

#### `LMapBlockConfig:removeSlot`

Remove a slot by name for this object.

```lua
LMapBlockConfig:removeSlot(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Slot name to remove. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if removed. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    cfg:addSlot("door", false, 0)
    cfg:removeSlot("door")
    local slots = cfg:getSlotCount()
    cfg:addSlot("door", false, 0)
    mapblock_log("removeSlot remaining slots=" .. slots)
    mapblock_log("removeSlot restored slots=" .. cfg:getSlotCount())
    mapblock_log("removeSlot helps trim temporary authoring channels")
end
```

---

#### `LMapBlockConfig:setDefaultSegmentSize`

Set default segment size for this object.

```lua
LMapBlockConfig:setDefaultSegmentSize(size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `size` | number | Segment size in tiles. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    cfg:setDefaultSegmentSize(32)
    cfg:addSlot("floor", true, 0)
    mapblock_log("setDefaultSegmentSize slotCount=" .. cfg:getSlotCount())
    mapblock_log("setDefaultSegmentSize uses 32px wall segments")
    mapblock_log("setDefaultSegmentSize ready for block snapping")
end
```

---

#### `LMapBlockConfig:setMaxLayers`

Set maximum layers per block for this object.

```lua
LMapBlockConfig:setMaxLayers(max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `max` | number | Max layers (1-10). |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    cfg:setMaxLayers(3)
    cfg:addSlot("detail", false, 0)
    mapblock_log("setMaxLayers slotCount=" .. cfg:getSlotCount())
    mapblock_log("setMaxLayers allows floor/wall/detail layering")
    mapblock_log("setMaxLayers configured for 3 exported layers")
end
```

---

## LMapBlockGenerator

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LMapBlockGenerator:addGroup`

Add a named block group definition to this map generator.

```lua
LMapBlockGenerator:addGroup(group)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `group` | [LMapGroup](#lmapgroup) | Group of blocks. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    local group = lurek.mapblock.newGroup("rooms")
    gen:addGroup(group)
    example_print_log("LMapBlockGenerator:addGroup group=" .. group:getName())
end
```

---

#### `LMapBlockGenerator:generate`

Generate map using a script for this object.

```lua
LMapBlockGenerator:generate(script)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `script` | [LMapScript](#lmapscript) | Script to execute. |

**Returns**

| Type | Description |
|------|-------------|
| [LMapBlockResult](#lmapblockresult) | Generation result. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("rect_fill")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(8, 6)
    gen:setSeed(42)
    script:addStep("fill_rect", { x = 0, y = 0, width = 3, height = 2, tile_id = 1, slot = 0, layer = 0 })
    local result = gen:generate(script)
    example_print_log("LMapBlockGenerator:generate isEmpty=" .. tostring(result:isEmpty()))
    example_print_log("LMapBlockGenerator:generate width=" .. result:getWidth())
end
```

---

#### `LMapBlockGenerator:generateWithReport`

Generate map using a script and return runtime diagnostics for this object.

```lua
LMapBlockGenerator:generateWithReport(script)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `script` | [LMapScript](#lmapscript) | Script to execute. |

**Returns**

| Type | Description |
|------|-------------|
| [LMapBlockResult](#lmapblockresult) | Generation result. |
| [LMapBlockReport](#lmapblockreport) | Diagnostics report. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("missing_group")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(1, 1)
    script:addStep("place_random", { group = "missing" })
    local result, report = gen:generateWithReport(script)
    local tbl = report:toTable()
    example_print_log("LMapBlockGenerator:generateWithReport resultEmpty=" .. tostring(result:isEmpty()))
    example_print_log("LMapBlockGenerator:generateWithReport missingGroups=" .. tbl.diagnostics.missing_groups)
    example_print_log("LMapBlockGenerator:generateWithReport rng=" .. tbl.rng_version)
end
```

---

#### `LMapBlockGenerator:getLastPlacedCount`

Get last placement count for this object.

```lua
LMapBlockGenerator:getLastPlacedCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Blocks placed in last generation. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("rect_fill")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(8, 6)
    gen:setSeed(42)
    script:addStep("fill_rect", { x = 0, y = 0, width = 2, height = 2, tile_id = 1, slot = 0, layer = 0 })
    gen:generate(script)
    example_print_log("LMapBlockGenerator:getLastPlacedCount=" .. gen:getLastPlacedCount())
end
```

---

#### `LMapBlockGenerator:getLastReport`

Get the diagnostic report captured during the previous generation run.

```lua
LMapBlockGenerator:getLastReport()
```

**Returns**

| Type | Description |
|------|-------------|
| [LMapBlockReport](#lmapblockreport) | Last diagnostics report. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("missing_group")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(1, 1)
    script:addStep("place_random", { group = "missing" })
    gen:generateWithReport(script)
    local report = gen:getLastReport():toTable()
    example_print_log("LMapBlockGenerator:getLastReport executed=" .. report.executed_step_iterations)
    example_print_log("LMapBlockGenerator:getLastReport cacheMisses=" .. report.transform_cache_misses)
end
```

---

#### `LMapBlockGenerator:setGrid`

Set the placement grid from a prepared PlacementGrid object.

```lua
LMapBlockGenerator:setGrid(grid)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `grid` | [LPlacementGrid](#lplacementgrid) | Grid to clone into the generator. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    local grid = lurek.mapblock.newEmptyGrid()
    grid:addPosition(0, 0)
    grid:addPosition(1, 0)
    grid:addPosition(1, 1)
    gen:setGrid(grid)
    example_print_log("LMapBlockGenerator:setGrid ready=true")
end
```

---

#### `LMapBlockGenerator:setMaxLevels`

Set the number of vertical levels or storeys to generate.

```lua
LMapBlockGenerator:setMaxLevels(levels)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `levels` | number | Max levels (1-10). |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setMaxLevels(3)
    gen:setRectShape(6, 6)
    mapblock_log("setMaxLevels ready=true")
    mapblock_log("setMaxLevels storeys=3")
    mapblock_log("setMaxLevels used for towers and stairwells")
end
```

---

#### `LMapBlockGenerator:setOrientation`

Set rendering orientation for this object.

```lua
LMapBlockGenerator:setOrientation(orientation)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `orientation` | string | "topdown" or "isometric". |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setOrientation("isometric")
    gen:setTileSize(32, 16)
    mapblock_log("setOrientation ready=true")
    mapblock_log("setOrientation mode=isometric")
    mapblock_log("setOrientation paired with 32x16 tile pixels")
end
```

---

#### `LMapBlockGenerator:setRectShape`

Set rectangular map shape â€” Lua userdata object exposed by the engine.

```lua
LMapBlockGenerator:setRectShape(width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Grid width. |
| `height` | number | Grid height. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(10, 8)
    gen:setSeed(5)
    mapblock_log("setRectShape ready=true")
    mapblock_log("setRectShape dimensions=10x8")
    mapblock_log("setRectShape deterministic seed applied")
end
```

---

#### `LMapBlockGenerator:setRules`

Set neighbor matching rules for this object.

```lua
LMapBlockGenerator:setRules(rules)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `rules` | [LNeighborRules](#lneighborrules) | Rules object. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    local rules = lurek.mapblock.newRules()
    rules:addCompatible(1, 2)
    gen:setRules(rules)
    example_print_log("LMapBlockGenerator:setRules compatible=" .. tostring(rules:isCompatible(1, 2)))
end
```

---

#### `LMapBlockGenerator:setSeed`

Set RNG seed for deterministic generation.

```lua
LMapBlockGenerator:setSeed(seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `seed` | number | Seed value. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setSeed(12345)
    gen:setRectShape(5, 5)
    mapblock_log("setSeed ready=true")
    mapblock_log("setSeed value=12345")
    mapblock_log("setSeed makes block placement reproducible")
end
```

---

#### `LMapBlockGenerator:setShape`

Set the generator map shape using a list of tile positions.

```lua
LMapBlockGenerator:setShape(positions)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `positions` | table | Array of {x, y} positions. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setShape({ { 0, 0 }, { 1, 0 }, { 1, 1 }, { 2, 1 } })
    gen:setSeed(9)
    mapblock_log("setShape ready=true")
    mapblock_log("setShape custom footprint cells=4")
    mapblock_log("setShape supports carved irregular corridors")
end
```

---

#### `LMapBlockGenerator:setSolverBudget`

Set bounded recursion budgets for `solve_shape`.

```lua
LMapBlockGenerator:setSolverBudget(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | Optional `max_nodes`, `max_depth`, `max_ms`, and `max_candidates_per_cell` fields. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setSolverBudget({
        max_nodes = 256,
        max_depth = 64,
        max_ms = 100,
        max_candidates_per_cell = 16,
    })
    mapblock_log("setSolverBudget nodes=256")
    mapblock_log("setSolverBudget depth=64")
    mapblock_log("setSolverBudget caps solve_shape recursion")
end
```

---

#### `LMapBlockGenerator:setTileSize`

Set tile pixel dimensions for this object.

```lua
LMapBlockGenerator:setTileSize(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Pixel width. |
| `h` | number | Pixel height. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setTileSize(32, 32)
    gen:setOrientation("topdown")
    mapblock_log("setTileSize ready=true")
    mapblock_log("setTileSize value=32x32")
    mapblock_log("setTileSize matches authored dungeon tiles")
end
```

---

## LMapBlockReport

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LMapBlockReport:toTable`

Serialize generation diagnostics into a plain Lua table.

```lua
LMapBlockReport:toTable()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Report fields and nested diagnostics counters. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("missing_group")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(1, 1)
    script:addStep("place_random", { group = "missing" })
    local _, report = gen:generateWithReport(script)
    local tbl = report:toTable()
    example_print_log("LMapBlockReport:toTable seed=" .. tbl.seed)
    example_print_log("LMapBlockReport:toTable missingGroups=" .. tbl.diagnostics.missing_groups)
    example_print_log("LMapBlockReport:toTable cacheHits=" .. tbl.transform_cache_hits)
end
```

---

## LMapBlockResult

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LMapBlockResult:getBlocksPlaced`

Get number of blocks placed for this object.

```lua
LMapBlockResult:getBlocksPlaced()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Blocks placed. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("place_once")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(6, 6)
    gen:setSeed(1)
    script:addStep("fill_rect", { x = 1, y = 1, width = 2, height = 2, tile_id = 4, slot = 0, layer = 0 })
    local result = gen:generate(script)
    example_print_log("LMapBlockResult:getBlocksPlaced=" .. result:getBlocksPlaced())
end
```

---

#### `LMapBlockResult:getGid`

Get tile GID at position for this object.

```lua
LMapBlockResult:getGid(level, layer, x, y, slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `level` | number | Level index. |
| `layer` | number | Layer index. |
| `x` | number | Tile X. |
| `y` | number | Tile Y. |
| `slot` | number | Slot index. |

**Returns**

| Type | Description |
|------|-------------|
| number | GID value. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("rect_fill")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(4, 4)
    script:addStep("fill_rect", { x = 0, y = 0, width = 2, height = 2, tile_id = 7, slot = 0, layer = 0, level = 0 })
    local result = gen:generate(script)
    local gid = result:getGid(0, 0, 0, 0, 0)
    example_print_log("LMapBlockResult:getGid=" .. tostring(gid))
end
```

---

#### `LMapBlockResult:getHeight`

Get total height in tiles â€” Lua userdata object exposed by the engine.

```lua
LMapBlockResult:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Height. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("rect_fill")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(8, 6)
    script:addStep("fill_rect", { x = 0, y = 0, width = 2, height = 2, tile_id = 1, slot = 0, layer = 0 })
    local result = gen:generate(script)
    example_print_log("LMapBlockResult:getHeight=" .. result:getHeight())
end
```

---

#### `LMapBlockResult:getLayerCount`

Get number of layers for this object.

```lua
LMapBlockResult:getLayerCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Layer count. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("rect_fill")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(4, 4)
    script:addStep("fill_rect", { x = 0, y = 0, width = 2, height = 2, tile_id = 1, slot = 0, layer = 0 })
    local result = gen:generate(script)
    example_print_log("LMapBlockResult:getLayerCount=" .. result:getLayerCount())
end
```

---

#### `LMapBlockResult:getLevelCount`

Get number of levels for this object.

```lua
LMapBlockResult:getLevelCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Level count. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("rect_fill")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(4, 4)
    gen:setMaxLevels(2)
    script:addStep("fill_rect", { x = 0, y = 0, width = 2, height = 2, tile_id = 1, slot = 0, layer = 0, level = 0 })
    local result = gen:generate(script)
    example_print_log("LMapBlockResult:getLevelCount=" .. result:getLevelCount())
end
```

---

#### `LMapBlockResult:getPlacements`

Get placement summaries from the last generation run.

```lua
LMapBlockResult:getPlacements()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of placement records. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    cfg:setDefaultSegmentSize(1)
    local block = lurek.mapblock.newBlock(1, 1, 1, cfg)
    block:setName("seed")
    block:setTile(0, 0, 0, 0, 1, 4)
    local group = lurek.mapblock.newGroup("terrain")
    group:addBlock(block)
    local script = lurek.mapblock.newScript("place_once")
    script:addStep("place_block", { group = "terrain", block_index = 0, x = 0, y = 0 })
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(1, 1)
    gen:addGroup(group)
    local result = gen:generate(script)
    example_print_log("LMapBlockResult:getPlacements count=" .. tostring(#result:getPlacements()))
end
```

---

#### `LMapBlockResult:getWidth`

Get total width in tiles for this object.

```lua
LMapBlockResult:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("rect_fill")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(8, 6)
    script:addStep("fill_rect", { x = 0, y = 0, width = 2, height = 2, tile_id = 1, slot = 0, layer = 0 })
    local result = gen:generate(script)
    example_print_log("LMapBlockResult:getWidth=" .. result:getWidth())
end
```

---

#### `LMapBlockResult:isEmpty`

Check if result is empty for this object.

```lua
LMapBlockResult:isEmpty()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if no blocks placed. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("empty")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(4, 4)
    local result = gen:generate(script)
    example_print_log("LMapBlockResult:isEmpty=" .. tostring(result:isEmpty()))
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

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    local group = lurek.mapblock.newGroup("rooms")
    group:addBlock(block)
    example_print_log("addBlock count=" .. group:getBlockCount())
end
```

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

**Example**

```lua
do
    local script = lurek.mapblock.newScript("rooms_pass")
    script:addStep("fill_rect", { x = 0, y = 0, width = 1, height = 1, tile_id = 1, slot = 0, layer = 0 })
    local group = lurek.mapblock.newGroup("rooms")
    group:addScript(script)
    example_print_log("addScript group=" .. group:getName())
end
```

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

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    local group = lurek.mapblock.newGroup("rooms")
    group:addBlock(block)
    example_print_log("getBlockCount=" .. group:getBlockCount())
end
```

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

**Example**

```lua
do
    local group = lurek.mapblock.newGroup("dungeon_rooms")
    local script = lurek.mapblock.newScript("rooms_pass")
    group:addScript(script)
    mapblock_log("getName=" .. group:getName())
    mapblock_log("getName blockCount=" .. group:getBlockCount())
    mapblock_log("getName script attached for themed pass")
end
```

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

**Example**

```lua
do
    local script = lurek.tilemap.newMapScript()
    script:addStep({ type = "fillArea", gid = 1, x = 0, y = 0, w = 1, h = 1 })
    local group = lurek.tilemap.newMapGroup("rooms")
    group:addScript(script)
    example_print_log("getScriptCount=" .. tostring(group:getScriptCount()))
end
```

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

**Example**

```lua
do
    local block_a = lurek.tilemap.newMapBlock(2, 2, 1, 1)
    local block_b = lurek.tilemap.newMapBlock(3, 3, 1, 1)
    local group = lurek.tilemap.newMapGroup("rooms")
    group:addBlock(block_a)
    group:addBlock(block_b)
    group:removeBlock(1)
    example_print_log("removeBlock count=" .. tostring(group:getBlockCount()))
end
```

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

**Example**

```lua
do
    local group = lurek.tilemap.newMapGroup("rooms")
    local script = lurek.tilemap.newMapScript()
    group:addScript(script)
    mapblock_log("LMapGroup:type=" .. tostring(group:type()))
    mapblock_log("LMapGroup:type scripts=" .. tostring(group:getScriptCount()))
    mapblock_log("LMapGroup:type name=" .. tostring(group:getName()))
end
```

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

**Example**

```lua
do
    local group = lurek.tilemap.newMapGroup("rooms")
    local script = lurek.tilemap.newMapScript()
    group:addScript(script)
    mapblock_log("LMapGroup:typeOf self=" .. tostring(group:typeOf("LMapGroup")))
    mapblock_log("LMapGroup:typeOf object=" .. tostring(group:typeOf("LObject")))
    mapblock_log("LMapGroup:typeOf scripts=" .. tostring(group:getScriptCount()))
end
```

---

## LMapScript

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LMapScript:addStep`

Add a generation step â€” Lua userdata object exposed by the engine.

```lua
LMapScript:addStep(step_type, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `step_type` | string | Step type name. |
| `opts?` | table | Step configuration options. |

**Example**

```lua
do
    local script = lurek.mapblock.newScript("block_fill")
    script:addStep("fill_rect", { x = 1, y = 1, width = 2, height = 2, tile_id = 5, slot = 0, layer = 0 })
    script:addStep("fill_edges", { tile_id = 9, slot = 0, layer = 0 })
    mapblock_log("addStep count=" .. script:getStepCount())
    mapblock_log("addStep script=" .. script:getName())
    mapblock_log("addStep supports multi-pass block painting")
end
```

---

#### `LMapScript:clear`

Clear all queued script steps from this map script.

```lua
LMapScript:clear()
```

**Example**

```lua
do
    local script = lurek.mapblock.newScript("cleanup")
    script:addStep("fill_rect", { x = 0, y = 0, width = 2, height = 2, tile_id = 1, slot = 0, layer = 0 })
    script:addStep("fill_edges", { tile_id = 2, slot = 0, layer = 0 })
    script:clear()
    example_print_log("LMapScript:clear stepCount=" .. script:getStepCount())
end
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

**Example**

```lua
do
    local script = lurek.mapblock.newScript("dungeon_gen")
    script:addStep("fill_rect", { x = 0, y = 0, width = 1, height = 1, tile_id = 1, slot = 0, layer = 0 })
    mapblock_log("LMapScript:getName=" .. tostring(script:getName()))
    mapblock_log("LMapScript:getName steps=" .. tostring(script:getStepCount()))
    mapblock_log("LMapScript:getName ready for dungeon pass")
end
```

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

**Example**

```lua
do
    local script = lurek.mapblock.newScript("multi_step")
    script:addStep("fill_rect", { x = 0, y = 0, width = 2, height = 2, tile_id = 1, slot = 0, layer = 0 })
    script:addStep("fill_edges", { tile_id = 2, slot = 0, layer = 0 })
    mapblock_log("getStepCount=" .. script:getStepCount())
    mapblock_log("getStepCount script=" .. script:getName())
    mapblock_log("getStepCount multi-pass setup ready")
end
```

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

**Example**

```lua
do
    local script = lurek.tilemap.newMapScript()
    script:addStep({ type = "fillArea", gid = 1, x = 0, y = 0, w = 1, h = 1 })
    mapblock_log("LMapScript:type=" .. tostring(script:type()))
    mapblock_log("LMapScript:type steps=" .. tostring(script:getStepCount()))
    mapblock_log("LMapScript:type ready for tilemap authoring")
end
```

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

**Example**

```lua
do
    local script = lurek.tilemap.newMapScript()
    script:addStep({ type = "fillArea", gid = 1, x = 0, y = 0, w = 1, h = 1 })
    mapblock_log("LMapScript:typeOf self=" .. tostring(script:typeOf("LMapScript")))
    mapblock_log("LMapScript:typeOf object=" .. tostring(script:typeOf("LObject")))
    mapblock_log("LMapScript:typeOf steps=" .. tostring(script:getStepCount()))
end
```

---

## LNeighborRules

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LNeighborRules:addCompatible`

Add bidirectional compatibility between two edge types.

```lua
LNeighborRules:addCompatible(type_a, type_b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_a` | number | First edge type. |
| `type_b` | number | Second edge type. |

**Example**

```lua
do
    local rules = lurek.mapblock.newRules()
    rules:addCompatible(10, 20)
    rules:addCompatible(10, 30)
    mapblock_log("LNeighborRules:addCompatible 20->10=" .. tostring(rules:isCompatible(20, 10)))
    mapblock_log("LNeighborRules:addCompatible 10->30=" .. tostring(rules:isCompatible(10, 30)))
    mapblock_log("LNeighborRules:addCompatible 30->10=" .. tostring(rules:isCompatible(30, 10)))
end
```

---

#### `LNeighborRules:addCompatibleOneWay`

Add one-way compatibility for this object.

```lua
LNeighborRules:addCompatibleOneWay(type_a, type_b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_a` | number | Source edge type. |
| `type_b` | number | Target edge type. |

**Example**

```lua
do
    local rules = lurek.mapblock.newRules()
    rules:addCompatibleOneWay(5, 9)
    rules:addCompatibleOneWay(5, 7)
    mapblock_log("LNeighborRules:addCompatibleOneWay forward59=" .. tostring(rules:isCompatible(5, 9)))
    mapblock_log("LNeighborRules:addCompatibleOneWay reverse95=" .. tostring(rules:isCompatible(9, 5)))
    mapblock_log("LNeighborRules:addCompatibleOneWay forward57=" .. tostring(rules:isCompatible(5, 7)))
end
```

---

#### `LNeighborRules:clear`

Clear all neighbor placement rules from this rule set.

```lua
LNeighborRules:clear()
```

**Example**

```lua
do
    local rules = lurek.mapblock.newRules()
    rules:addCompatible(1, 2)
    rules:clear()
    rules:addCompatibleOneWay(3, 4)
    local before = rules:isCompatible(3, 4)
    rules:clear()
    mapblock_log("LNeighborRules:clear before=" .. tostring(before))
    mapblock_log("LNeighborRules:clear after34=" .. tostring(rules:isCompatible(3, 4)))
    mapblock_log("LNeighborRules:clear after12=" .. tostring(rules:isCompatible(1, 2)))
end
```

---

#### `LNeighborRules:isCompatible`

Check if two edge types are compatible.

```lua
LNeighborRules:isCompatible(type_a, type_b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_a` | number | First edge type. |
| `type_b` | number | Second edge type. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if compatible. |

**Example**

```lua
do
    local rules = lurek.mapblock.newRules()
    rules:addCompatible(4, 6)
    local compatible = rules:isCompatible(4, 6)
    local reverse = rules:isCompatible(6, 4)
    local blocked = rules:isCompatible(4, 8)
    mapblock_log("LNeighborRules:isCompatible 4,6=" .. tostring(compatible))
    mapblock_log("LNeighborRules:isCompatible 6,4=" .. tostring(reverse))
    mapblock_log("LNeighborRules:isCompatible 4,8=" .. tostring(blocked))
end
```

---

## LPlacementGrid

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LPlacementGrid:addPosition`

Add a position to the grid â€” Lua userdata object exposed by the engine.

```lua
LPlacementGrid:addPosition(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |

**Example**

```lua
do
    local grid = lurek.mapblock.newGrid(10, 10)
    grid:addPosition(3, 4)
    grid:addPosition(4, 4)
    mapblock_log("LPlacementGrid:addPosition availCount=" .. grid:getAvailableCount())
    mapblock_log("LPlacementGrid:addPosition has 3,4=" .. tostring(grid:isAvailable(3, 4)))
    mapblock_log("LPlacementGrid:addPosition has 4,4=" .. tostring(grid:isAvailable(4, 4)))
end
```

---

#### `LPlacementGrid:clear`

Clear all positions and placed blocks.

```lua
LPlacementGrid:clear()
```

**Example**

```lua
do
    local grid = lurek.mapblock.newEmptyGrid()
    grid:addPosition(1, 1)
    grid:addPosition(2, 1)
    local before = grid:getAvailableCount()
    grid:clear()
    mapblock_log("LPlacementGrid:clear before=" .. before)
    mapblock_log("LPlacementGrid:clear after=" .. grid:getAvailableCount())
    mapblock_log("LPlacementGrid:clear removed 1,1=" .. tostring(grid:isAvailable(1, 1)))
end
```

---

#### `LPlacementGrid:getAvailableCount`

Get available position count for this object.

```lua
LPlacementGrid:getAvailableCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Number of available positions. |

**Example**

```lua
do
    local grid = lurek.mapblock.newEmptyGrid()
    grid:addPosition(1, 1)
    grid:addPosition(2, 2)
    grid:addPosition(3, 3)
    example_print_log("LPlacementGrid:getAvailableCount=" .. grid:getAvailableCount())
end
```

---

#### `LPlacementGrid:isAvailable`

Check whether a placement grid position is currently available.

```lua
LPlacementGrid:isAvailable(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if available. |

**Example**

```lua
do
    local grid = lurek.mapblock.newEmptyGrid()
    grid:addPosition(5, 5)
    grid:addPosition(6, 5)
    mapblock_log("LPlacementGrid:isAvailable 5,5=" .. tostring(grid:isAvailable(5, 5)))
    mapblock_log("LPlacementGrid:isAvailable 6,5=" .. tostring(grid:isAvailable(6, 5)))
    mapblock_log("LPlacementGrid:isAvailable 0,0=" .. tostring(grid:isAvailable(0, 0)))
end
```

---

#### `LPlacementGrid:isEdgePosition`

Check whether a cell touches the placement-shape boundary.

```lua
LPlacementGrid:isEdgePosition(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the cell lies on the shape edge. |

**Example**

```lua
do
    local grid = lurek.mapblock.newEmptyGrid()
    grid:addPosition(0, 0)
    grid:addPosition(1, 0)
    grid:addPosition(1, 1)
    example_print_log("LPlacementGrid:isEdgePosition=" .. tostring(grid:isEdgePosition(1, 1)))
end
```

---

#### `LPlacementGrid:removePosition`

Remove an available position from the grid.

```lua
LPlacementGrid:removePosition(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |

**Example**

```lua
do
    local grid = lurek.mapblock.newEmptyGrid()
    grid:addPosition(1, 1)
    grid:addPosition(2, 1)
    local before = grid:getAvailableCount()
    grid:removePosition(1, 1)
    mapblock_log("LPlacementGrid:removePosition before=" .. before)
    mapblock_log("LPlacementGrid:removePosition after=" .. grid:getAvailableCount())
    mapblock_log("LPlacementGrid:removePosition still has 2,1=" .. tostring(grid:isAvailable(2, 1)))
end
```

---

## LTilesetRef

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTilesetRef:getId`

Get the numeric tileset ID for this tileset reference.

```lua
LTilesetRef:getId()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Tileset ID. |

**Example**

```lua
do
    local ref = lurek.mapblock.newTilesetRef(2, "ground_tiles", 64, 8, 32, 32)
    ref:setImagePath("content/examples/assets/ground_tiles.png")
    mapblock_log("LTilesetRef:getId=" .. tostring(ref:getId()))
    mapblock_log("LTilesetRef:getId name=" .. tostring(ref:getName()))
    mapblock_log("LTilesetRef:getId path configured")
end
```

---

#### `LTilesetRef:getName`

Get tileset name â€” Lua userdata object exposed by the engine.

```lua
LTilesetRef:getName()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Tileset name. |

**Example**

```lua
do
    local ref = lurek.mapblock.newTilesetRef(3, "world_tileset", 128, 16, 16, 16)
    ref:setImagePath("content/examples/assets/world_tileset.png")
    mapblock_log("LTilesetRef:getName=" .. tostring(ref:getName()))
    mapblock_log("LTilesetRef:getName id=" .. tostring(ref:getId()))
    mapblock_log("LTilesetRef:getName image path configured")
end
```

---

#### `LTilesetRef:setImagePath`

Set the image file path for this tileset reference.

```lua
LTilesetRef:setImagePath(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Image file path. |

**Example**

```lua
do
    local ref = lurek.mapblock.newTilesetRef(4, "cave_tiles", 64, 8, 32, 32)
    ref:setImagePath("assets/textures/cave.png")
    mapblock_log("LTilesetRef:setImagePath name=" .. ref:getName())
    mapblock_log("LTilesetRef:setImagePath id=" .. tostring(ref:getId()))
    mapblock_log("LTilesetRef:setImagePath preview asset set")
end
```

---
