# Mapblock

- The `mapblock` module provides a scripted, constraint-based procedural map assembly system that composes reusable tile-block prefabs into fully rendered TileMaps.

The `mapblock` module implements a Carcassonne-inspired map assembly pipeline where discrete `MapBlock` prefabs — each a grid of `MapTile` slots with typed edges — are placed on a `PlacementGrid` according to `EdgeConstraint` rules that ensure neighboring blocks share compatible socket types (e.g., `"road"`, `"river"`). Block placement is driven by a `MapScript`: an ordered sequence of typed `ScriptStep` operations including `Fill` (flood-fill a region with a block group), `PlaceGroup` (weighted random selection from a named `BlockGroup`), `PlaceBlock` (explicit placement), `ApplyLayer` (copy a layer from another block), and `Repeat` (nested sub-sequence with its own RNG advance). The `MapBlockGenerator` executes these steps in order with backtrack support, capped by a configurable `retry_limit`.

Blocks are organized into named `BlockGroup` sets using alias-method weighted sampling, enabling biome-zone filling where a single script step populates an entire region with contextually appropriate tiles. Each block references a `TilesetRef` that maps its tile slot IDs to world tile IDs via a `base_id` offset, allowing multiple blocks to share the same tileset texture. Tile slots are typed (`floor`, `roof`, `object`, `wall`, or custom), which maps directly to `TileMap` layer indices in the output.

Multi-storey environments are handled by a `LayerStack` (wrapped as `MultilevelMap`) that maintains independent `MapBlockGrid` instances per Z-level. Both top-down and isometric projection orientations are supported via `MapOrientation`, applied by the tilemap renderer. The final assembly step calls `grid_to_tilemap`, converting the block grid into a standard `TileMap` owned by the caller and decoupled from the generator. The `lurek.mapblock.*` Lua API exposes block definition, group registration, script construction, and generation entry points.

## Functions

### `lurek.mapblock.newBlock`

Create a new map block exposed by the lurek engine.

```lua
-- signature
lurek.mapblock.newBlock(width, height, layers, config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | `number` | Block width in tiles. |
| `height` | `number` | Block height in tiles. |
| `layers` | `number` | Number of layers. |
| `config` | `MapBlockConfig` | Configuration to use. |

**Returns**

| Type | Description |
|------|-------------|
| `MapBlock` | New block. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 4, 1, cfg)
    print("lurek.mapblock.newBlock=" .. block:getWidth() .. "x" .. block:getHeight())
end
```

---

### `lurek.mapblock.newConfig`

Create a new map block configuration with default slots.

```lua
-- signature
lurek.mapblock.newConfig()
```

**Returns**

| Type | Description |
|------|-------------|
| `MapBlockConfig` | New configuration. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    print("lurek.mapblock.newConfig slotCount=" .. cfg:getSlotCount())
end
```

---

### `lurek.mapblock.newEmptyConfig`

Create an empty config with no predefined slots.

```lua
-- signature
lurek.mapblock.newEmptyConfig()
```

**Returns**

| Type | Description |
|------|-------------|
| `MapBlockConfig` | Empty configuration. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newEmptyConfig()
    cfg:addSlot("floor", true, 0)
    print("lurek.mapblock.newEmptyConfig slotCount=" .. cfg:getSlotCount())
end
```

---

### `lurek.mapblock.newEmptyGrid`

Create an empty placement grid (for arbitrary shapes).

```lua
-- signature
lurek.mapblock.newEmptyGrid()
```

**Returns**

| Type | Description |
|------|-------------|
| `PlacementGrid` | Empty grid. |

**Example**

```lua
do
    local grid = lurek.mapblock.newEmptyGrid()
    grid:addPosition(2, 2)
    print("lurek.mapblock.newEmptyGrid available=" .. grid:getAvailableCount())
end
```

---

### `lurek.mapblock.newGenerator`

Create a new procedural map block generator instance.

```lua
-- signature
lurek.mapblock.newGenerator(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config` | `MapBlockConfig` | Configuration. |

**Returns**

| Type | Description |
|------|-------------|
| `MapBlockGenerator` | New generator. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(6, 4)
    print("lurek.mapblock.newGenerator ready=true")
end
```

---

### `lurek.mapblock.newGrid`

Create a rectangular placement grid.

```lua
-- signature
lurek.mapblock.newGrid(width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | `number` | Grid width. |
| `height` | `number` | Grid height. |

**Returns**

| Type | Description |
|------|-------------|
| `PlacementGrid` | New grid. |

**Example**

```lua
do
    local grid = lurek.mapblock.newGrid(10, 10)
    grid:addPosition(3, 4)
    print("lurek.mapblock.newGrid available=" .. grid:getAvailableCount())
end
```

---

### `lurek.mapblock.newGroup`

Create a new map group exposed by the lurek engine.

```lua
-- signature
lurek.mapblock.newGroup(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Group name. |

**Returns**

| Type | Description |
|------|-------------|
| `MapGroup` | New group. |

**Example**

```lua
do
    local group = lurek.mapblock.newGroup("rooms")
    print("lurek.mapblock.newGroup=" .. group:getName())
end
```

---

### `lurek.mapblock.newRules`

Create new neighbor rules exposed by the lurek engine.

```lua
-- signature
lurek.mapblock.newRules()
```

**Returns**

| Type | Description |
|------|-------------|
| `NeighborRules` | New rules. |

**Example**

```lua
do
    local rules = lurek.mapblock.newRules()
    rules:addCompatible(1, 2)
    print("lurek.mapblock.newRules compatible=" .. tostring(rules:isCompatible(1, 2)))
end
```

---

### `lurek.mapblock.newScript`

Create a new map script exposed by the lurek engine.

```lua
-- signature
lurek.mapblock.newScript(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name?` | `string` | Script name. |

**Returns**

| Type | Description |
|------|-------------|
| `MapScript` | New script. |

**Example**

```lua
do
    local script = lurek.mapblock.newScript("layout_pass")
    script:addStep("fill_rect", { x = 0, y = 0, width = 4, height = 3, tile_id = 1, slot = 0, layer = 0 })
    print("lurek.mapblock.newScript steps=" .. script:getStepCount())
    print("lurek.mapblock.newScript name=" .. script:getName())
end
```

---

### `lurek.mapblock.newTilesetRef`

Create a tileset reference exposed by the lurek engine.

```lua
-- signature
lurek.mapblock.newTilesetRef(id, name, tile_count, columns, tile_width, tile_height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Tileset ID. |
| `name` | `string` | Tileset name. |
| `tile_count` | `number` | Number of tiles. |
| `columns` | `number` | Columns in tileset image. |
| `tile_width` | `number` | Tile pixel width. |
| `tile_height` | `number` | Tile pixel height. |

**Returns**

| Type | Description |
|------|-------------|
| `TilesetRef` | New tileset reference. |

**Example**

```lua
do
    local ref = lurek.mapblock.newTilesetRef(1, "ground_tiles", 64, 8, 32, 32)
    print("lurek.mapblock.newTilesetRef id=" .. ref:getId())
    print("lurek.mapblock.newTilesetRef name=" .. ref:getName())
end
```

---

## LMapBlock

### `LMapBlock:getDimensions`

Returns both width and height of the block in tiles.

```lua
-- signature
LMapBlock:getDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Width. |
| `number` | b Height. |

---

### `LMapBlock:getHeight`

Get height in tiles for this object.

```lua
-- signature
LMapBlock:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Block height. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 3, 1, cfg)
    print("getHeight=" .. block:getHeight())
end
```

---

### `LMapBlock:getHeightInSegments`

Returns the block height measured in segments.

```lua
-- signature
LMapBlock:getHeightInSegments()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Height in segments. |

---

### `LMapBlock:getLayerCount`

Get the number of tile layers in this map block.

```lua
-- signature
LMapBlock:getLayerCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Number of layers. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 3, 2, cfg)
    print("getLayerCount=" .. block:getLayerCount())
end
```

---

### `LMapBlock:getName`

Get the map block's display or lookup name string value.

```lua
-- signature
LMapBlock:getName()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Block name. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setName("room_a")
    print("getName=" .. block:getName())
end
```

---

### `LMapBlock:getSegmentSize`

Returns the segment size used for edge matching.

```lua
-- signature
LMapBlock:getSegmentSize()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Segment size in tiles. |

---

### `LMapBlock:getSide`

Returns the side ID for an edge segment.

```lua
-- signature
LMapBlock:getSide(edge, segment)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `edge` | `string` | Edge direction: `"north"`, `"east"`, `"south"`, or `"west"`. |
| `segment` | `number` | Segment index along the edge (1-based). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Side identifier. |

---

### `LMapBlock:getTile`

Get the tile GID at a specified row and column position.

```lua
-- signature
LMapBlock:getTile(layer, x, y, slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | `number` | Layer index. |
| `x` | `number` | Tile X. |
| `y` | `number` | Tile Y. |
| `slot` | `number` | Slot index. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Tile GID. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newEmptyConfig()
    cfg:addSlot("floor", true, 0)
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setTile(0, 1, 1, 0, 1, 9)
    local tile = block:getTile(0, 1, 1, 0)
    print("getTile value=" .. tostring(tile))
end
```

---

### `LMapBlock:getWeight`

Returns the current selection weight.

```lua
-- signature
LMapBlock:getWeight()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Weight value. |

---

### `LMapBlock:getWidth`

Get the block width measured in tile grid units.

```lua
-- signature
LMapBlock:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Block width. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 3, 1, cfg)
    print("getWidth=" .. block:getWidth())
end
```

---

### `LMapBlock:getWidthInSegments`

Returns the block width measured in segments.

```lua
-- signature
LMapBlock:getWidthInSegments()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Width in segments. |

---

### `LMapBlock:setEdge`

Set edge type for a side and segment.

```lua
-- signature
LMapBlock:setEdge(edge, segment, edge_type)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `edge` | `string` | Edge direction: "north", "east", "south", "west". |
| `segment` | `number` | Segment index along the edge. |
| `edge_type` | `number` | Edge type identifier. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 4, 1, cfg)
    block:setEdge("north", 0, 2)
    block:setEdge("south", 1, 2)
    print("LMapBlock:setEdge width=" .. block:getWidth())
end
```

---

### `LMapBlock:setEdgeOnly`

Set whether block must be on map edge.

```lua
-- signature
LMapBlock:setEdgeOnly(edge_only)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `edge_only` | `boolean` | True if edge-only. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 4, 1, cfg)
    block:setEdgeOnly(true)
    print("LMapBlock:setEdgeOnly height=" .. block:getHeight())
end
```

---

### `LMapBlock:setInteriorOnly`

Set whether block must be in interior.

```lua
-- signature
LMapBlock:setInteriorOnly(interior_only)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `interior_only` | `boolean` | True if interior-only. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 4, 1, cfg)
    block:setInteriorOnly(true)
    print("LMapBlock:setInteriorOnly width=" .. block:getWidth())
end
```

---

### `LMapBlock:setLevelSpan`

Set multi-level span for this object.

```lua
-- signature
LMapBlock:setLevelSpan(levels)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `levels` | `number` | Number of levels this block spans. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 4, 2, cfg)
    block:setLevelSpan(2)
    print("LMapBlock:setLevelSpan layers=" .. block:getLayerCount())
end
```

---

### `LMapBlock:setName`

Set the map block's display or lookup name string value.

```lua
-- signature
LMapBlock:setName(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Block name. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setName("corridor")
    print("setName=" .. block:getName())
end
```

---

### `LMapBlock:setSide`

Sets the side ID for an edge segment, used for edge matching in map generation.

```lua
-- signature
LMapBlock:setSide(edge, segment, sideId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `edge` | `string` | Edge direction: `"north"`, `"east"`, `"south"`, or `"west"`. |
| `segment` | `number` | Segment index along the edge (1-based). |
| `sideId` | `number` | Side identifier for matching. |

---

### `LMapBlock:setTile`

Set a tile slot value — Lua userdata object exposed by the engine.

```lua
-- signature
LMapBlock:setTile(layer, x, y, slot, tileset_id, gid)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | `number` | Layer index (0-based). |
| `x` | `number` | Tile X position. |
| `y` | `number` | Tile Y position. |
| `slot` | `number` | Slot index. |
| `tileset_id` | `number` | Tileset ID. |
| `gid` | `number` | Tile GID. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newEmptyConfig()
    cfg:addSlot("wall", true, 0)
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setTile(0, 1, 1, 0, 1, 5)
    print("setTile value=" .. tostring(block:getTile(0, 1, 1, 0)))
end
```

---

### `LMapBlock:setWeight`

Set block weight for random selection.

```lua
-- signature
LMapBlock:setWeight(weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `weight` | `number` | Weight value (higher = more likely). |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setWeight(3.0)
    print("setWeight ok")
end
```

---

### `LMapBlock:type`

Returns the type name of this userdata.

```lua
-- signature
LMapBlock:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always `"LMapBlock"`. |

---

### `LMapBlock:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LMapBlock:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check against. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if `name` is `"LMapBlock"` or `"Object"`. |

---

## LMapBlockConfig

### `LMapBlockConfig:addSlot`

Add a slot definition — Lua userdata object exposed by the engine.

```lua
-- signature
LMapBlockConfig:addSlot(name, required, default_gid)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Slot name. |
| `required?` | `boolean` | Whether this slot is required. |
| `default_gid?` | `number` | Default GID when empty. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    cfg:addSlot("wall", true, 0)
    cfg:addSlot("floor", false, 1)
    print("LMapBlockConfig:addSlot slotCount=" .. cfg:getSlotCount())
end
```

---

### `LMapBlockConfig:getSlotCount`

Get the number of slots for this object.

```lua
-- signature
LMapBlockConfig:getSlotCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Slot count. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    cfg:addSlot("layer1", true, 0)
    cfg:addSlot("layer2", false, 1)
    cfg:addSlot("layer3", false, 2)
    print("LMapBlockConfig:getSlotCount=" .. cfg:getSlotCount())
end
```

---

### `LMapBlockConfig:removeSlot`

Remove a slot by name for this object.

```lua
-- signature
LMapBlockConfig:removeSlot(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Slot name to remove. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if removed. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    cfg:addSlot("door", false, 0)
    cfg:removeSlot("door")
    print("LMapBlockConfig:removeSlot slotCount=" .. cfg:getSlotCount())
end
```

---

### `LMapBlockConfig:setDefaultSegmentSize`

Set default segment size for this object.

```lua
-- signature
LMapBlockConfig:setDefaultSegmentSize(size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `size` | `number` | Segment size in tiles. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    cfg:setDefaultSegmentSize(32)
    print("LMapBlockConfig:setDefaultSegmentSize slotCount=" .. cfg:getSlotCount())
end
```

---

### `LMapBlockConfig:setMaxLayers`

Set maximum layers per block for this object.

```lua
-- signature
LMapBlockConfig:setMaxLayers(max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `max` | `number` | Max layers (1-10). |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    cfg:setMaxLayers(3)
    cfg:addSlot("detail", false, 0)
    print("LMapBlockConfig:setMaxLayers slotCount=" .. cfg:getSlotCount())
end
```

---

## LMapBlockGenerator

### `LMapBlockGenerator:addGroup`

Add a named block group definition to this map generator.

```lua
-- signature
LMapBlockGenerator:addGroup(group)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `group` | `MapGroup` | Group of blocks. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    local group = lurek.mapblock.newGroup("rooms")
    gen:addGroup(group)
    print("LMapBlockGenerator:addGroup group=" .. group:getName())
end
```

---

### `LMapBlockGenerator:generate`

Generate map using a script for this object.

```lua
-- signature
LMapBlockGenerator:generate(script)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `script` | `MapScript` | Script to execute. |

**Returns**

| Type | Description |
|------|-------------|
| `MapBlockResult` | Generation result. |

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
    print("LMapBlockGenerator:generate isEmpty=" .. tostring(result:isEmpty()))
    print("LMapBlockGenerator:generate width=" .. result:getWidth())
end
```

---

### `LMapBlockGenerator:getLastPlacedCount`

Get last placement count for this object.

```lua
-- signature
LMapBlockGenerator:getLastPlacedCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Blocks placed in last generation. |

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
    print("LMapBlockGenerator:getLastPlacedCount=" .. gen:getLastPlacedCount())
end
```

---

### `LMapBlockGenerator:setMaxLevels`

Set the number of vertical levels or storeys to generate.

```lua
-- signature
LMapBlockGenerator:setMaxLevels(levels)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `levels` | `number` | Max levels (1-10). |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setMaxLevels(3)
    print("LMapBlockGenerator:setMaxLevels ready=true")
end
```

---

### `LMapBlockGenerator:setOrientation`

Set rendering orientation for this object.

```lua
-- signature
LMapBlockGenerator:setOrientation(orientation)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `orientation` | `string` | "topdown" or "isometric". |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setOrientation("isometric")
    print("LMapBlockGenerator:setOrientation ready=true")
end
```

---

### `LMapBlockGenerator:setRectShape`

Set rectangular map shape — Lua userdata object exposed by the engine.

```lua
-- signature
LMapBlockGenerator:setRectShape(width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | `number` | Grid width. |
| `height` | `number` | Grid height. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(10, 8)
    print("LMapBlockGenerator:setRectShape ready=true")
end
```

---

### `LMapBlockGenerator:setRules`

Set neighbor matching rules for this object.

```lua
-- signature
LMapBlockGenerator:setRules(rules)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `rules` | `NeighborRules` | Rules object. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    local rules = lurek.mapblock.newRules()
    rules:addCompatible(1, 2)
    gen:setRules(rules)
    print("LMapBlockGenerator:setRules compatible=" .. tostring(rules:isCompatible(1, 2)))
end
```

---

### `LMapBlockGenerator:setSeed`

Set RNG seed for deterministic generation.

```lua
-- signature
LMapBlockGenerator:setSeed(seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `seed` | `number` | Seed value. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setSeed(12345)
    print("LMapBlockGenerator:setSeed ready=true")
end
```

---

### `LMapBlockGenerator:setShape`

Set the generator map shape using a list of tile positions.

```lua
-- signature
LMapBlockGenerator:setShape(positions)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `positions` | `table` | Array of {x, y} positions. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setShape({ { 0, 0 }, { 1, 0 }, { 1, 1 }, { 2, 1 } })
    print("LMapBlockGenerator:setShape ready=true")
end
```

---

### `LMapBlockGenerator:setTileSize`

Set tile pixel dimensions for this object.

```lua
-- signature
LMapBlockGenerator:setTileSize(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | `number` | Pixel width. |
| `h` | `number` | Pixel height. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setTileSize(32, 32)
    print("LMapBlockGenerator:setTileSize ready=true")
end
```

---

## LMapBlockResult

### `LMapBlockResult:getBlocksPlaced`

Get number of blocks placed for this object.

```lua
-- signature
LMapBlockResult:getBlocksPlaced()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Blocks placed. |

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
    print("LMapBlockResult:getBlocksPlaced=" .. result:getBlocksPlaced())
end
```

---

### `LMapBlockResult:getGid`

Get tile GID at position for this object.

```lua
-- signature
LMapBlockResult:getGid(level, layer, x, y, slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `level` | `number` | Level index. |
| `layer` | `number` | Layer index. |
| `x` | `number` | Tile X. |
| `y` | `number` | Tile Y. |
| `slot` | `number` | Slot index. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | GID value. |

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
    print("LMapBlockResult:getGid=" .. tostring(gid))
end
```

---

### `LMapBlockResult:getHeight`

Get total height in tiles — Lua userdata object exposed by the engine.

```lua
-- signature
LMapBlockResult:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Height. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("rect_fill")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(8, 6)
    script:addStep("fill_rect", { x = 0, y = 0, width = 2, height = 2, tile_id = 1, slot = 0, layer = 0 })
    local result = gen:generate(script)
    print("LMapBlockResult:getHeight=" .. result:getHeight())
end
```

---

### `LMapBlockResult:getLayerCount`

Get number of layers for this object.

```lua
-- signature
LMapBlockResult:getLayerCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Layer count. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("rect_fill")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(4, 4)
    script:addStep("fill_rect", { x = 0, y = 0, width = 2, height = 2, tile_id = 1, slot = 0, layer = 0 })
    local result = gen:generate(script)
    print("LMapBlockResult:getLayerCount=" .. result:getLayerCount())
end
```

---

### `LMapBlockResult:getLevelCount`

Get number of levels for this object.

```lua
-- signature
LMapBlockResult:getLevelCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Level count. |

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
    print("LMapBlockResult:getLevelCount=" .. result:getLevelCount())
end
```

---

### `LMapBlockResult:getWidth`

Get total width in tiles for this object.

```lua
-- signature
LMapBlockResult:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Width. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("rect_fill")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(8, 6)
    script:addStep("fill_rect", { x = 0, y = 0, width = 2, height = 2, tile_id = 1, slot = 0, layer = 0 })
    local result = gen:generate(script)
    print("LMapBlockResult:getWidth=" .. result:getWidth())
end
```

---

### `LMapBlockResult:isEmpty`

Check if result is empty for this object.

```lua
-- signature
LMapBlockResult:isEmpty()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if no blocks placed. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("empty")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(4, 4)
    local result = gen:generate(script)
    print("LMapBlockResult:isEmpty=" .. tostring(result:isEmpty()))
end
```

---

## LMapGroup

### `LMapGroup:addBlock`

Add a block to this group for this object.

```lua
-- signature
LMapGroup:addBlock(block)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `block` | `MapBlock` | Block to add. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    local group = lurek.mapblock.newGroup("rooms")
    group:addBlock(block)
    print("addBlock count=" .. group:getBlockCount())
end
```

---

### `LMapGroup:addScript`

Add a script to this group for this object.

```lua
-- signature
LMapGroup:addScript(script)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `script` | `MapScript` | Script to add. |

**Example**

```lua
do
    local script = lurek.mapblock.newScript("rooms_pass")
    script:addStep("fill_rect", { x = 0, y = 0, width = 1, height = 1, tile_id = 1, slot = 0, layer = 0 })
    local group = lurek.mapblock.newGroup("rooms")
    group:addScript(script)
    print("addScript group=" .. group:getName())
end
```

---

### `LMapGroup:getBlockCount`

Get the number of blocks for this object.

```lua
-- signature
LMapGroup:getBlockCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Block count. |

**Example**

```lua
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    local group = lurek.mapblock.newGroup("rooms")
    group:addBlock(block)
    print("getBlockCount=" .. group:getBlockCount())
end
```

---

### `LMapGroup:getName`

Get the display name of this map group object.

```lua
-- signature
LMapGroup:getName()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Group name. |

**Example**

```lua
do
    local group = lurek.mapblock.newGroup("dungeon_rooms")
    print("getName=" .. group:getName())
end
```

---

### `LMapGroup:getScriptCount`

Returns how many scripts are attached to this group.

```lua
-- signature
LMapGroup:getScriptCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Script count. |

---

### `LMapGroup:removeBlock`

Removes a block from the group by index.

```lua
-- signature
LMapGroup:removeBlock(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | `number` | Block index (1-based). |

---

### `LMapGroup:type`

Returns the type name of this userdata.

```lua
-- signature
LMapGroup:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always `"LMapGroup"`. |

---

### `LMapGroup:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LMapGroup:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check against. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if `name` is `"LMapGroup"` or `"Object"`. |

---

## LMapScript

### `LMapScript:addStep`

Add a generation step — Lua userdata object exposed by the engine.

```lua
-- signature
LMapScript:addStep(step_type, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `step_type` | `string` | Step type name. |
| `opts?` | `table` | Step configuration options. |

**Example**

```lua
do
    local script = lurek.mapblock.newScript("block_fill")
    script:addStep("fill_rect", { x = 1, y = 1, width = 2, height = 2, tile_id = 5, slot = 0, layer = 0 })
    print("addStep count=" .. script:getStepCount())
end
```

---

### `LMapScript:clear`

Clear all queued script steps from this map script.

```lua
-- signature
LMapScript:clear()
```

**Example**

```lua
do
    local script = lurek.mapblock.newScript("cleanup")
    script:addStep("fill_rect", { x = 0, y = 0, width = 2, height = 2, tile_id = 1, slot = 0, layer = 0 })
    script:addStep("fill_edges", { tile_id = 2, slot = 0, layer = 0 })
    script:clear()
    print("LMapScript:clear stepCount=" .. script:getStepCount())
end
```

---

### `LMapScript:getName`

Get the script name for this object.

```lua
-- signature
LMapScript:getName()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Script name. |

**Example**

```lua
do
    local script = lurek.mapblock.newScript("dungeon_gen")
    print("LMapScript:getName=" .. tostring(script:getName()))
end
```

---

### `LMapScript:getStepCount`

Get the number of steps for this object.

```lua
-- signature
LMapScript:getStepCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Step count. |

**Example**

```lua
do
    local script = lurek.mapblock.newScript("multi_step")
    script:addStep("fill_rect", { x = 0, y = 0, width = 2, height = 2, tile_id = 1, slot = 0, layer = 0 })
    script:addStep("fill_edges", { tile_id = 2, slot = 0, layer = 0 })
    print("getStepCount=" .. script:getStepCount())
end
```

---

### `LMapScript:type`

Returns the type name of this userdata.

```lua
-- signature
LMapScript:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always `"LMapScript"`. |

---

### `LMapScript:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LMapScript:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check against. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if `name` is `"LMapScript"` or `"Object"`. |

---

## LNeighborRules

### `LNeighborRules:addCompatible`

Add bidirectional compatibility between two edge types.

```lua
-- signature
LNeighborRules:addCompatible(type_a, type_b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_a` | `number` | First edge type. |
| `type_b` | `number` | Second edge type. |

**Example**

```lua
do
    local rules = lurek.mapblock.newRules()
    rules:addCompatible(10, 20)
    rules:addCompatible(10, 30)
    print("LNeighborRules:addCompatible=" .. tostring(rules:isCompatible(20, 10)))
end
```

---

### `LNeighborRules:addCompatibleOneWay`

Add one-way compatibility for this object.

```lua
-- signature
LNeighborRules:addCompatibleOneWay(type_a, type_b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_a` | `number` | Source edge type. |
| `type_b` | `number` | Target edge type. |

**Example**

```lua
do
    local rules = lurek.mapblock.newRules()
    rules:addCompatibleOneWay(5, 9)
    print("LNeighborRules:addCompatibleOneWay forward=" .. tostring(rules:isCompatible(5, 9)))
    print("LNeighborRules:addCompatibleOneWay reverse=" .. tostring(rules:isCompatible(9, 5)))
end
```

---

### `LNeighborRules:clear`

Clear all neighbor placement rules from this rule set.

```lua
-- signature
LNeighborRules:clear()
```

**Example**

```lua
do
    local rules = lurek.mapblock.newRules()
    rules:addCompatible(1, 2)
    rules:clear()
    print("LNeighborRules:clear=" .. tostring(rules:isCompatible(1, 2)))
end
```

---

### `LNeighborRules:isCompatible`

Check if two edge types are compatible.

```lua
-- signature
LNeighborRules:isCompatible(type_a, type_b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_a` | `number` | First edge type. |
| `type_b` | `number` | Second edge type. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if compatible. |

**Example**

```lua
do
    local rules = lurek.mapblock.newRules()
    rules:addCompatible(4, 6)
    print("LNeighborRules:isCompatible=" .. tostring(rules:isCompatible(4, 6)))
end
```

---

## LPlacementGrid

### `LPlacementGrid:addPosition`

Add a position to the grid — Lua userdata object exposed by the engine.

```lua
-- signature
LPlacementGrid:addPosition(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | X coordinate. |
| `y` | `number` | Y coordinate. |

**Example**

```lua
do
    local grid = lurek.mapblock.newGrid(10, 10)
    grid:addPosition(3, 4)
    print("LPlacementGrid:addPosition availCount=" .. grid:getAvailableCount())
end
```

---

### `LPlacementGrid:clear`

Clear all positions and placed blocks.

```lua
-- signature
LPlacementGrid:clear()
```

**Example**

```lua
do
    local grid = lurek.mapblock.newEmptyGrid()
    grid:addPosition(1, 1)
    grid:clear()
    print("LPlacementGrid:clear availCount=" .. grid:getAvailableCount())
end
```

---

### `LPlacementGrid:getAvailableCount`

Get available position count for this object.

```lua
-- signature
LPlacementGrid:getAvailableCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Number of available positions. |

**Example**

```lua
do
    local grid = lurek.mapblock.newEmptyGrid()
    grid:addPosition(1, 1)
    grid:addPosition(2, 2)
    grid:addPosition(3, 3)
    print("LPlacementGrid:getAvailableCount=" .. grid:getAvailableCount())
end
```

---

### `LPlacementGrid:isAvailable`

Check whether a placement grid position is currently available.

```lua
-- signature
LPlacementGrid:isAvailable(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | X coordinate. |
| `y` | `number` | Y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if available. |

**Example**

```lua
do
    local grid = lurek.mapblock.newEmptyGrid()
    grid:addPosition(5, 5)
    print("LPlacementGrid:isAvailable=" .. tostring(grid:isAvailable(5, 5)))
end
```

---

## LTilesetRef

### `LTilesetRef:getId`

Get the numeric tileset ID for this tileset reference.

```lua
-- signature
LTilesetRef:getId()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Tileset ID. |

**Example**

```lua
do
    local ref = lurek.mapblock.newTilesetRef(2, "ground_tiles", 64, 8, 32, 32)
    print("LTilesetRef:getId=" .. tostring(ref:getId()))
end
```

---

### `LTilesetRef:getName`

Get tileset name — Lua userdata object exposed by the engine.

```lua
-- signature
LTilesetRef:getName()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Tileset name. |

**Example**

```lua
do
    local ref = lurek.mapblock.newTilesetRef(3, "world_tileset", 128, 16, 16, 16)
    print("LTilesetRef:getName=" .. tostring(ref:getName()))
end
```

---

### `LTilesetRef:setImagePath`

Set the image file path for this tileset reference.

```lua
-- signature
LTilesetRef:setImagePath(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | Image file path. |

**Example**

```lua
do
    local ref = lurek.mapblock.newTilesetRef(4, "cave_tiles", 64, 8, 32, 32)
    ref:setImagePath("assets/textures/cave.png")
    print("LTilesetRef:setImagePath name=" .. ref:getName())
end
```

---
