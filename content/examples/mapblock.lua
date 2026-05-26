-- ==========================================================================
-- Lurek2D Example: MapBlock
-- ==========================================================================
-- Demonstrates procedural map block generation with configurable tiles,
-- neighbor constraints, and scripted generation pipelines.
--
-- Topics: mapblock config, block creation, grids, rules, generators.
-- ==========================================================================

--@api-stub: lurek.mapblock.newConfig
do
    local cfg = lurek.mapblock.newConfig()
    print("lurek.mapblock.newConfig slotCount=" .. cfg:getSlotCount())
end

--@api-stub: lurek.mapblock.newEmptyConfig
do
    local cfg = lurek.mapblock.newEmptyConfig()
    cfg:addSlot("floor", true, 0)
    print("lurek.mapblock.newEmptyConfig slotCount=" .. cfg:getSlotCount())
end

--@api-stub: lurek.mapblock.newBlock
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 4, 1, cfg)
    print("lurek.mapblock.newBlock=" .. block:getWidth() .. "x" .. block:getHeight())
end

--@api-stub: lurek.mapblock.newGroup
do
    local group = lurek.mapblock.newGroup("rooms")
    print("lurek.mapblock.newGroup=" .. group:getName())
end

--@api-stub: lurek.mapblock.newScript
do
    local script = lurek.mapblock.newScript("layout_pass")
    script:addStep("fill_rect", { x = 0, y = 0, width = 4, height = 3, tile_id = 1, slot = 0, layer = 0 })
    print("lurek.mapblock.newScript steps=" .. script:getStepCount())
    print("lurek.mapblock.newScript name=" .. script:getName())
end

--@api-stub: lurek.mapblock.newRules
do
    local rules = lurek.mapblock.newRules()
    rules:addCompatible(1, 2)
    print("lurek.mapblock.newRules compatible=" .. tostring(rules:isCompatible(1, 2)))
end

--@api-stub: lurek.mapblock.newGrid
do
    local grid = lurek.mapblock.newGrid(10, 10)
    grid:addPosition(3, 4)
    print("lurek.mapblock.newGrid available=" .. grid:getAvailableCount())
end

--@api-stub: lurek.mapblock.newEmptyGrid
do
    local grid = lurek.mapblock.newEmptyGrid()
    grid:addPosition(2, 2)
    print("lurek.mapblock.newEmptyGrid available=" .. grid:getAvailableCount())
end

--@api-stub: lurek.mapblock.newGenerator
do
    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(6, 4)
    print("lurek.mapblock.newGenerator ready=true")
end

--@api-stub: lurek.mapblock.newTilesetRef
do
    local ref = lurek.mapblock.newTilesetRef(1, "ground_tiles", 64, 8, 32, 32)
    print("lurek.mapblock.newTilesetRef id=" .. ref:getId())
    print("lurek.mapblock.newTilesetRef name=" .. ref:getName())
end

--@api-stub: LMapBlock:setEdge
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 4, 1, cfg)
    block:setEdge("north", 0, 2)
    block:setEdge("south", 1, 2)
    print("LMapBlock:setEdge width=" .. block:getWidth())
end

--@api-stub: LMapBlock:setEdgeOnly
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 4, 1, cfg)
    block:setEdgeOnly(true)
    print("LMapBlock:setEdgeOnly height=" .. block:getHeight())
end

--@api-stub: LMapBlock:setInteriorOnly
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 4, 1, cfg)
    block:setInteriorOnly(true)
    print("LMapBlock:setInteriorOnly width=" .. block:getWidth())
end

--@api-stub: LMapBlock:setLevelSpan
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 4, 2, cfg)
    block:setLevelSpan(2)
    print("LMapBlock:setLevelSpan layers=" .. block:getLayerCount())
end

--@api-stub: LMapBlockConfig:addSlot
do
    local cfg = lurek.mapblock.newConfig()
    cfg:addSlot("wall", true, 0)
    cfg:addSlot("floor", false, 1)
    print("LMapBlockConfig:addSlot slotCount=" .. cfg:getSlotCount())
end

--@api-stub: LMapBlockConfig:removeSlot
do
    local cfg = lurek.mapblock.newConfig()
    cfg:addSlot("door", false, 0)
    cfg:removeSlot("door")
    print("LMapBlockConfig:removeSlot slotCount=" .. cfg:getSlotCount())
end

--@api-stub: LMapBlockConfig:getSlotCount
do
    local cfg = lurek.mapblock.newConfig()
    cfg:addSlot("layer1", true, 0)
    cfg:addSlot("layer2", false, 1)
    cfg:addSlot("layer3", false, 2)
    print("LMapBlockConfig:getSlotCount=" .. cfg:getSlotCount())
end

--@api-stub: LMapBlockConfig:setMaxLayers
do
    local cfg = lurek.mapblock.newConfig()
    cfg:setMaxLayers(3)
    cfg:addSlot("detail", false, 0)
    print("LMapBlockConfig:setMaxLayers slotCount=" .. cfg:getSlotCount())
end

--@api-stub: LMapBlockConfig:setDefaultSegmentSize
do
    local cfg = lurek.mapblock.newConfig()
    cfg:setDefaultSegmentSize(32)
    print("LMapBlockConfig:setDefaultSegmentSize slotCount=" .. cfg:getSlotCount())
end

--@api-stub: LMapBlockGenerator:setRectShape
do
    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(10, 8)
    print("LMapBlockGenerator:setRectShape ready=true")
end

--@api-stub: LMapBlockGenerator:setShape
do
    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setShape({ { 0, 0 }, { 1, 0 }, { 1, 1 }, { 2, 1 } })
    print("LMapBlockGenerator:setShape ready=true")
end

--@api-stub: LMapBlockGenerator:setOrientation
do
    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setOrientation("isometric")
    print("LMapBlockGenerator:setOrientation ready=true")
end

--@api-stub: LMapBlockGenerator:setMaxLevels
do
    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setMaxLevels(3)
    print("LMapBlockGenerator:setMaxLevels ready=true")
end

--@api-stub: LMapBlockGenerator:setRules
do
    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    local rules = lurek.mapblock.newRules()
    rules:addCompatible(1, 2)
    gen:setRules(rules)
    print("LMapBlockGenerator:setRules compatible=" .. tostring(rules:isCompatible(1, 2)))
end

--@api-stub: LMapBlockGenerator:setSeed
do
    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setSeed(12345)
    print("LMapBlockGenerator:setSeed ready=true")
end

--@api-stub: LMapBlockGenerator:setTileSize
do
    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setTileSize(32, 32)
    print("LMapBlockGenerator:setTileSize ready=true")
end

--@api-stub: LMapBlockGenerator:addGroup
do
    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    local group = lurek.mapblock.newGroup("rooms")
    gen:addGroup(group)
    print("LMapBlockGenerator:addGroup group=" .. group:getName())
end

--@api-stub: LMapBlockGenerator:generate
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

--@api-stub: LMapBlockGenerator:getLastPlacedCount
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

--@api-stub: LMapBlockResult:getWidth
do
    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("rect_fill")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(8, 6)
    script:addStep("fill_rect", { x = 0, y = 0, width = 2, height = 2, tile_id = 1, slot = 0, layer = 0 })
    local result = gen:generate(script)
    print("LMapBlockResult:getWidth=" .. result:getWidth())
end

--@api-stub: LMapBlockResult:getHeight
do
    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("rect_fill")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(8, 6)
    script:addStep("fill_rect", { x = 0, y = 0, width = 2, height = 2, tile_id = 1, slot = 0, layer = 0 })
    local result = gen:generate(script)
    print("LMapBlockResult:getHeight=" .. result:getHeight())
end

--@api-stub: LMapBlockResult:getLevelCount
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

--@api-stub: LMapBlockResult:getLayerCount
do
    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("rect_fill")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(4, 4)
    script:addStep("fill_rect", { x = 0, y = 0, width = 2, height = 2, tile_id = 1, slot = 0, layer = 0 })
    local result = gen:generate(script)
    print("LMapBlockResult:getLayerCount=" .. result:getLayerCount())
end

--@api-stub: LMapBlockResult:getGid
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

--@api-stub: LMapBlockResult:getBlocksPlaced
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

--@api-stub: LMapBlockResult:isEmpty
do
    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("empty")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(4, 4)
    local result = gen:generate(script)
    print("LMapBlockResult:isEmpty=" .. tostring(result:isEmpty()))
end

--@api-stub: LMapScript:clear
do
    local script = lurek.mapblock.newScript("cleanup")
    script:addStep("fill_rect", { x = 0, y = 0, width = 2, height = 2, tile_id = 1, slot = 0, layer = 0 })
    script:addStep("fill_edges", { tile_id = 2, slot = 0, layer = 0 })
    script:clear()
    print("LMapScript:clear stepCount=" .. script:getStepCount())
end

--@api-stub: LMapScript:getName
do
    local script = lurek.mapblock.newScript("dungeon_gen")
    print("LMapScript:getName=" .. tostring(script:getName()))
end

--@api-stub: LNeighborRules:addCompatible
do
    local rules = lurek.mapblock.newRules()
    rules:addCompatible(10, 20)
    rules:addCompatible(10, 30)
    print("LNeighborRules:addCompatible=" .. tostring(rules:isCompatible(20, 10)))
end

--@api-stub: LNeighborRules:addCompatibleOneWay
do
    local rules = lurek.mapblock.newRules()
    rules:addCompatibleOneWay(5, 9)
    print("LNeighborRules:addCompatibleOneWay forward=" .. tostring(rules:isCompatible(5, 9)))
    print("LNeighborRules:addCompatibleOneWay reverse=" .. tostring(rules:isCompatible(9, 5)))
end

--@api-stub: LNeighborRules:isCompatible
do
    local rules = lurek.mapblock.newRules()
    rules:addCompatible(4, 6)
    print("LNeighborRules:isCompatible=" .. tostring(rules:isCompatible(4, 6)))
end

--@api-stub: LNeighborRules:clear
do
    local rules = lurek.mapblock.newRules()
    rules:addCompatible(1, 2)
    rules:clear()
    print("LNeighborRules:clear=" .. tostring(rules:isCompatible(1, 2)))
end

--@api-stub: LPlacementGrid:addPosition
do
    local grid = lurek.mapblock.newGrid(10, 10)
    grid:addPosition(3, 4)
    print("LPlacementGrid:addPosition availCount=" .. grid:getAvailableCount())
end

--@api-stub: LPlacementGrid:isAvailable
do
    local grid = lurek.mapblock.newEmptyGrid()
    grid:addPosition(5, 5)
    print("LPlacementGrid:isAvailable=" .. tostring(grid:isAvailable(5, 5)))
end

--@api-stub: LPlacementGrid:getAvailableCount
do
    local grid = lurek.mapblock.newEmptyGrid()
    grid:addPosition(1, 1)
    grid:addPosition(2, 2)
    grid:addPosition(3, 3)
    print("LPlacementGrid:getAvailableCount=" .. grid:getAvailableCount())
end

--@api-stub: LPlacementGrid:clear
do
    local grid = lurek.mapblock.newEmptyGrid()
    grid:addPosition(1, 1)
    grid:clear()
    print("LPlacementGrid:clear availCount=" .. grid:getAvailableCount())
end

--@api-stub: LTilesetRef:getId
do
    local ref = lurek.mapblock.newTilesetRef(2, "ground_tiles", 64, 8, 32, 32)
    print("LTilesetRef:getId=" .. tostring(ref:getId()))
end

--@api-stub: LTilesetRef:getName
do
    local ref = lurek.mapblock.newTilesetRef(3, "world_tileset", 128, 16, 16, 16)
    print("LTilesetRef:getName=" .. tostring(ref:getName()))
end

--@api-stub: LTilesetRef:setImagePath
do
    local ref = lurek.mapblock.newTilesetRef(4, "cave_tiles", 64, 8, 32, 32)
    ref:setImagePath("assets/textures/cave.png")
    print("LTilesetRef:setImagePath name=" .. ref:getName())
end

-- --- LMapBlock / LMapGroup / LMapScript (also in tilemap_api.rs) ------------

--@api-stub: LMapBlock:getHeight
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 3, 1, cfg)
    print("getHeight=" .. block:getHeight())
end

--@api-stub: LMapBlock:getLayerCount
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 3, 2, cfg)
    print("getLayerCount=" .. block:getLayerCount())
end

--@api-stub: LMapBlock:getName
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setName("room_a")
    print("getName=" .. block:getName())
end

--@api-stub: LMapBlock:getTile
do
    local cfg = lurek.mapblock.newEmptyConfig()
    cfg:addSlot("floor", true, 0)
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setTile(0, 1, 1, 0, 1, 9)
    local tile = block:getTile(0, 1, 1, 0)
    print("getTile value=" .. tostring(tile))
end

--@api-stub: LMapBlock:getWidth
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 3, 1, cfg)
    print("getWidth=" .. block:getWidth())
end

--@api-stub: LMapBlock:setName
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setName("corridor")
    print("setName=" .. block:getName())
end

--@api-stub: LMapBlock:setTile
do
    local cfg = lurek.mapblock.newEmptyConfig()
    cfg:addSlot("wall", true, 0)
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setTile(0, 1, 1, 0, 1, 5)
    print("setTile value=" .. tostring(block:getTile(0, 1, 1, 0)))
end

--@api-stub: LMapBlock:setWeight
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setWeight(3.0)
    print("setWeight ok")
end

--@api-stub: LMapGroup:addBlock
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    local group = lurek.mapblock.newGroup("rooms")
    group:addBlock(block)
    print("addBlock count=" .. group:getBlockCount())
end

--@api-stub: LMapGroup:addScript
do
    local script = lurek.mapblock.newScript("rooms_pass")
    script:addStep("fill_rect", { x = 0, y = 0, width = 1, height = 1, tile_id = 1, slot = 0, layer = 0 })
    local group = lurek.mapblock.newGroup("rooms")
    group:addScript(script)
    print("addScript group=" .. group:getName())
end

--@api-stub: LMapGroup:getBlockCount
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    local group = lurek.mapblock.newGroup("rooms")
    group:addBlock(block)
    print("getBlockCount=" .. group:getBlockCount())
end

--@api-stub: LMapGroup:getName
do
    local group = lurek.mapblock.newGroup("dungeon_rooms")
    print("getName=" .. group:getName())
end

--@api-stub: LMapScript:addStep
do
    local script = lurek.mapblock.newScript("block_fill")
    script:addStep("fill_rect", { x = 1, y = 1, width = 2, height = 2, tile_id = 5, slot = 0, layer = 0 })
    print("addStep count=" .. script:getStepCount())
end

--@api-stub: LMapScript:getStepCount
do
    local script = lurek.mapblock.newScript("multi_step")
    script:addStep("fill_rect", { x = 0, y = 0, width = 2, height = 2, tile_id = 1, slot = 0, layer = 0 })
    script:addStep("fill_edges", { tile_id = 2, slot = 0, layer = 0 })
    print("getStepCount=" .. script:getStepCount())
end
