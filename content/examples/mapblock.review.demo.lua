-- ==========================================================================
-- Lurek2D Example: MapBlock
-- ==========================================================================
-- Demonstrates procedural map block generation with configurable tiles,
-- neighbor constraints, and scripted generation pipelines.
--
-- Topics: mapblock config, block creation, grids, rules, generators.
-- ==========================================================================



--@api: lurek.mapblock.newConfig
do

    local cfg = lurek.mapblock.newConfig()
    cfg:addSlot("detail", false, 0)
    local slots = cfg:getSlotCount()
    lurek.log.info("newConfig slotCount=" .. slots)
    lurek.log.info("newConfig supports detail slot=" .. tostring(slots > 0))
    lurek.log.info("newConfig ready for layered room blocks")
end

--@api: lurek.mapblock.newEmptyConfig
do

    local cfg = lurek.mapblock.newEmptyConfig()
    cfg:addSlot("floor", true, 0)
    cfg:addSlot("wall", false, 0)
    local slots = cfg:getSlotCount()
    lurek.log.info("newEmptyConfig slotCount=" .. slots)
    lurek.log.info("newEmptyConfig keeps only authored slots")
    lurek.log.info("newEmptyConfig wall slot added=" .. tostring(slots == 2))
end

--@api: lurek.mapblock.newBlock
do

    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 4, 1, cfg)
    block:setName("entrance_room")
    local width = block:getWidth()
    local height = block:getHeight()
    lurek.log.info("newBlock dims=" .. width .. "x" .. height)
    lurek.log.info("newBlock layers=" .. block:getLayerCount())
    lurek.log.info("newBlock name=" .. block:getName())
end

--@api: lurek.mapblock.newGroup
do

    local group = lurek.mapblock.newGroup("rooms")
    local script = lurek.mapblock.newScript("rooms_pass")
    group:addScript(script)
    lurek.log.info("newGroup name=" .. group:getName())
    lurek.log.info("newGroup blockCount=" .. group:getBlockCount())
    lurek.log.info("newGroup accepts scripts for themed passes")
end

--@api: lurek.mapblock.newScript
do

    local script = lurek.mapblock.newScript("layout_pass")
    script:addStep("fill_rect", { x = 0, y = 0, width = 4, height = 3, tile_id = 1, slot = 0, layer = 0 })
    script:addStep("fill_edges", { tile_id = 2, slot = 0, layer = 0 })
    lurek.log.info("newScript steps=" .. script:getStepCount())
    lurek.log.info("newScript name=" .. script:getName())
    lurek.log.info("newScript ready for layout pass")
end

--@api: lurek.mapblock.newRules
do

    local rules = lurek.mapblock.newRules()
    rules:addCompatible(1, 2)
    rules:addCompatibleOneWay(3, 4)
    lurek.log.info("newRules compatible12=" .. tostring(rules:isCompatible(1, 2)))
    lurek.log.info("newRules compatible34=" .. tostring(rules:isCompatible(3, 4)))
    lurek.log.info("newRules reverse43=" .. tostring(rules:isCompatible(4, 3)))
end

--@api: lurek.mapblock.newGrid
do

    local grid = lurek.mapblock.newGrid(10, 10)
    grid:addPosition(3, 4)
    grid:addPosition(4, 4)
    lurek.log.info("newGrid available=" .. grid:getAvailableCount())
    lurek.log.info("newGrid position 3,4 available=" .. tostring(grid:isAvailable(3, 4)))
    lurek.log.info("newGrid edge position 3,4=" .. tostring(grid:isEdgePosition(3, 4)))
end

--@api: lurek.mapblock.newEmptyGrid
do

    local grid = lurek.mapblock.newEmptyGrid()
    grid:addPosition(2, 2)
    grid:addPosition(2, 3)
    lurek.log.info("newEmptyGrid available=" .. grid:getAvailableCount())
    lurek.log.info("newEmptyGrid position 2,2 available=" .. tostring(grid:isAvailable(2, 2)))
    lurek.log.info("newEmptyGrid supports arbitrary shapes")
end

--@api: lurek.mapblock.newGenerator
do

    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(6, 4)
    gen:setSeed(17)
    gen:setMaxLevels(2)
    lurek.log.info("newGenerator ready=true")
    lurek.log.info("newGenerator shape set to 6x4")
    lurek.log.info("newGenerator max levels configured")
end

--@api: lurek.mapblock.newTilesetRef
do

    local ref = lurek.mapblock.newTilesetRef(1, "ground_tiles", 64, 8, 32, 32)
    ref:setImagePath("content/examples/assets/mapblock_ground.png")
    lurek.log.info("newTilesetRef id=" .. ref:getId())
    lurek.log.info("newTilesetRef name=" .. ref:getName())
    lurek.log.info("newTilesetRef image path configured for preview")
end

--@api: LMapBlock:setEdge
do

    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 4, 1, cfg)
    block:setEdge("north", 0, 2)
    block:setEdge("south", 0, 2)
    lurek.log.info("LMapBlock:setEdge width=" .. block:getWidth())
end

--@api: LMapBlock:setEdgeOnly
do

    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 4, 1, cfg)
    block:setEdgeOnly(true)
    block:setName("perimeter_wall")
    lurek.log.info("setEdgeOnly height=" .. block:getHeight())
    lurek.log.info("setEdgeOnly block name=" .. block:getName())
    lurek.log.info("setEdgeOnly keeps perimeter pieces on outer border")
end

--@api: LMapBlock:setInteriorOnly
do

    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 4, 1, cfg)
    block:setInteriorOnly(true)
    block:setName("treasure_room")
    lurek.log.info("setInteriorOnly width=" .. block:getWidth())
    lurek.log.info("setInteriorOnly block name=" .. block:getName())
    lurek.log.info("setInteriorOnly reserves this block for inner cells")
end

--@api: LMapBlock:setLevelSpan
do

    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 4, 2, cfg)
    block:setLevelSpan(2)
    block:setName("stairwell")
    lurek.log.info("setLevelSpan layers=" .. block:getLayerCount())
    lurek.log.info("setLevelSpan block height=" .. block:getHeight())
    lurek.log.info("setLevelSpan block name=" .. block:getName())
end

--@api: LMapBlockConfig:addSlot
do

    local cfg = lurek.mapblock.newConfig()
    cfg:addSlot("wall", true, 0)
    cfg:addSlot("floor", false, 1)
    cfg:addSlot("ceiling", false, 0)
    lurek.log.info("addSlot slotCount=" .. cfg:getSlotCount())
    lurek.log.info("addSlot room config has ceiling slot")
    lurek.log.info("addSlot supports authored wall/floor layering")
end

--@api: LMapBlockConfig:removeSlot
do

    local cfg = lurek.mapblock.newConfig()
    cfg:addSlot("door", false, 0)
    cfg:removeSlot("door")
    local slots = cfg:getSlotCount()
    cfg:addSlot("door", false, 0)
    lurek.log.info("removeSlot remaining slots=" .. slots)
    lurek.log.info("removeSlot restored slots=" .. cfg:getSlotCount())
    lurek.log.info("removeSlot helps trim temporary authoring channels")
end

--@api: LMapBlockConfig:getSlotCount
do

    local cfg = lurek.mapblock.newConfig()
    cfg:addSlot("layer1", true, 0)
    cfg:addSlot("layer2", false, 1)
    cfg:addSlot("layer3", false, 2)
    lurek.log.info("LMapBlockConfig:getSlotCount=" .. cfg:getSlotCount())
end

--@api: LMapBlockConfig:setMaxLayers
do

    local cfg = lurek.mapblock.newConfig()
    cfg:setMaxLayers(3)
    cfg:addSlot("detail", false, 0)
    lurek.log.info("setMaxLayers slotCount=" .. cfg:getSlotCount())
    lurek.log.info("setMaxLayers allows floor/wall/detail layering")
    lurek.log.info("setMaxLayers configured for 3 exported layers")
end

--@api: LMapBlockConfig:setDefaultSegmentSize
do

    local cfg = lurek.mapblock.newConfig()
    cfg:setDefaultSegmentSize(32)
    cfg:addSlot("floor", true, 0)
    lurek.log.info("setDefaultSegmentSize slotCount=" .. cfg:getSlotCount())
    lurek.log.info("setDefaultSegmentSize uses 32px wall segments")
    lurek.log.info("setDefaultSegmentSize ready for block snapping")
end

--@api: LMapBlockGenerator:setRectShape
do

    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(10, 8)
    gen:setSeed(5)
    lurek.log.info("setRectShape ready=true")
    lurek.log.info("setRectShape dimensions=10x8")
    lurek.log.info("setRectShape deterministic seed applied")
end

--@api: LMapBlockGenerator:setShape
do

    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setShape({ { 0, 0 }, { 1, 0 }, { 1, 1 }, { 2, 1 } })
    gen:setSeed(9)
    lurek.log.info("setShape ready=true")
    lurek.log.info("setShape custom footprint cells=4")
    lurek.log.info("setShape supports carved irregular corridors")
end

--@api: LMapBlockGenerator:setOrientation
do

    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setOrientation("isometric")
    gen:setTileSize(32, 16)
    lurek.log.info("setOrientation ready=true")
    lurek.log.info("setOrientation mode=isometric")
    lurek.log.info("setOrientation paired with 32x16 tile pixels")
end

--@api: LMapBlockGenerator:setMaxLevels
do

    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setMaxLevels(3)
    gen:setRectShape(6, 6)
    lurek.log.info("setMaxLevels ready=true")
    lurek.log.info("setMaxLevels storeys=3")
    lurek.log.info("setMaxLevels used for towers and stairwells")
end

--@api: LMapBlockGenerator:setRules
do

    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    local rules = lurek.mapblock.newRules()
    rules:addCompatible(1, 2)
    gen:setRules(rules)
    lurek.log.info("LMapBlockGenerator:setRules compatible=" .. tostring(rules:isCompatible(1, 2)))
end

--@api: LMapBlockGenerator:setSeed
do

    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setSeed(12345)
    gen:setRectShape(5, 5)
    lurek.log.info("setSeed ready=true")
    lurek.log.info("setSeed value=12345")
    lurek.log.info("setSeed makes block placement reproducible")
end

--@api: LMapBlockGenerator:setTileSize
do

    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setTileSize(32, 32)
    gen:setOrientation("topdown")
    lurek.log.info("setTileSize ready=true")
    lurek.log.info("setTileSize value=32x32")
    lurek.log.info("setTileSize matches authored dungeon tiles")
end

--@api: LMapBlockGenerator:setSolverBudget
do

    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setSolverBudget({
        max_nodes = 256,
        max_depth = 64,
        max_ms = 100,
        max_candidates_per_cell = 16,
    })
    lurek.log.info("setSolverBudget nodes=256")
    lurek.log.info("setSolverBudget depth=64")
    lurek.log.info("setSolverBudget caps solve_shape recursion")
end

--@api: LMapBlockGenerator:addGroup
do

    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    local group = lurek.mapblock.newGroup("rooms")
    gen:addGroup(group)
    lurek.log.info("LMapBlockGenerator:addGroup group=" .. group:getName())
end

--@api: LMapBlockGenerator:generate
do

    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("rect_fill")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(8, 6)
    gen:setSeed(42)
    script:addStep("fill_rect", { x = 0, y = 0, width = 3, height = 2, tile_id = 1, slot = 0, layer = 0 })
    local result = gen:generate(script)
    lurek.log.info("LMapBlockGenerator:generate isEmpty=" .. tostring(result:isEmpty()))
    lurek.log.info("LMapBlockGenerator:generate width=" .. result:getWidth())
end

--@api: LMapBlockGenerator:generateWithReport
do

    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("missing_group")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(1, 1)
    script:addStep("place_random", { group = "missing" })
    local result, report = gen:generateWithReport(script)
    local tbl = report:toTable()
    lurek.log.info("LMapBlockGenerator:generateWithReport resultEmpty=" .. tostring(result:isEmpty()))
    lurek.log.info("LMapBlockGenerator:generateWithReport missingGroups=" .. tbl.diagnostics.missing_groups)
    lurek.log.info("LMapBlockGenerator:generateWithReport rng=" .. tbl.rng_version)
end

--@api: LMapBlockGenerator:getLastPlacedCount
do

    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("rect_fill")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(8, 6)
    gen:setSeed(42)
    script:addStep("fill_rect", { x = 0, y = 0, width = 2, height = 2, tile_id = 1, slot = 0, layer = 0 })
    gen:generate(script)
    lurek.log.info("LMapBlockGenerator:getLastPlacedCount=" .. gen:getLastPlacedCount())
end

--@api: LMapBlockGenerator:getLastReport
do

    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("missing_group")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(1, 1)
    script:addStep("place_random", { group = "missing" })
    gen:generateWithReport(script)
    local report = gen:getLastReport():toTable()
    lurek.log.info("LMapBlockGenerator:getLastReport executed=" .. report.executed_step_iterations)
    lurek.log.info("LMapBlockGenerator:getLastReport cacheMisses=" .. report.transform_cache_misses)
end

--@api: LMapBlockReport:toTable
do

    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("missing_group")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(1, 1)
    script:addStep("place_random", { group = "missing" })
    local _, report = gen:generateWithReport(script)
    local tbl = report:toTable()
    lurek.log.info("LMapBlockReport:toTable seed=" .. tbl.seed)
    lurek.log.info("LMapBlockReport:toTable missingGroups=" .. tbl.diagnostics.missing_groups)
    lurek.log.info("LMapBlockReport:toTable cacheHits=" .. tbl.transform_cache_hits)
end

--@api: LMapBlockResult:getWidth
do

    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("rect_fill")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(8, 6)
    script:addStep("fill_rect", { x = 0, y = 0, width = 2, height = 2, tile_id = 1, slot = 0, layer = 0 })
    local result = gen:generate(script)
    lurek.log.info("LMapBlockResult:getWidth=" .. result:getWidth())
end

--@api: LMapBlockResult:getHeight
do

    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("rect_fill")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(8, 6)
    script:addStep("fill_rect", { x = 0, y = 0, width = 2, height = 2, tile_id = 1, slot = 0, layer = 0 })
    local result = gen:generate(script)
    lurek.log.info("LMapBlockResult:getHeight=" .. result:getHeight())
end

--@api: LMapBlockResult:getLevelCount
do

    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("rect_fill")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(4, 4)
    gen:setMaxLevels(2)
    script:addStep("fill_rect", { x = 0, y = 0, width = 2, height = 2, tile_id = 1, slot = 0, layer = 0, level = 0 })
    local result = gen:generate(script)
    lurek.log.info("LMapBlockResult:getLevelCount=" .. result:getLevelCount())
end

--@api: LMapBlockResult:getLayerCount
do

    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("rect_fill")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(4, 4)
    script:addStep("fill_rect", { x = 0, y = 0, width = 2, height = 2, tile_id = 1, slot = 0, layer = 0 })
    local result = gen:generate(script)
    lurek.log.info("LMapBlockResult:getLayerCount=" .. result:getLayerCount())
end

--@api: LMapBlockResult:getGid
do

    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("rect_fill")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(4, 4)
    script:addStep("fill_rect", { x = 0, y = 0, width = 2, height = 2, tile_id = 7, slot = 0, layer = 0, level = 0 })
    local result = gen:generate(script)
    local gid = result:getGid(0, 0, 0, 0, 0)
    lurek.log.info("LMapBlockResult:getGid=" .. tostring(gid))
end

--@api: LMapBlockResult:getBlocksPlaced
do

    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("place_once")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(6, 6)
    gen:setSeed(1)
    script:addStep("fill_rect", { x = 1, y = 1, width = 2, height = 2, tile_id = 4, slot = 0, layer = 0 })
    local result = gen:generate(script)
    lurek.log.info("LMapBlockResult:getBlocksPlaced=" .. result:getBlocksPlaced())
end

--@api: LMapBlockResult:isEmpty
do

    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("empty")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(4, 4)
    local result = gen:generate(script)
    lurek.log.info("LMapBlockResult:isEmpty=" .. tostring(result:isEmpty()))
end

--@api: LMapScript:clear
do

    local script = lurek.mapblock.newScript("cleanup")
    script:addStep("fill_rect", { x = 0, y = 0, width = 2, height = 2, tile_id = 1, slot = 0, layer = 0 })
    script:addStep("fill_edges", { tile_id = 2, slot = 0, layer = 0 })
    script:clear()
    lurek.log.info("LMapScript:clear stepCount=" .. script:getStepCount())
end

--@api: LMapScript:getName
do

    local script = lurek.mapblock.newScript("dungeon_gen")
    script:addStep("fill_rect", { x = 0, y = 0, width = 1, height = 1, tile_id = 1, slot = 0, layer = 0 })
    lurek.log.info("LMapScript:getName=" .. tostring(script:getName()))
    lurek.log.info("LMapScript:getName steps=" .. tostring(script:getStepCount()))
    lurek.log.info("LMapScript:getName ready for dungeon pass")
end

--@api: LNeighborRules:addCompatible
do

    local rules = lurek.mapblock.newRules()
    rules:addCompatible(10, 20)
    rules:addCompatible(10, 30)
    lurek.log.info("LNeighborRules:addCompatible 20->10=" .. tostring(rules:isCompatible(20, 10)))
    lurek.log.info("LNeighborRules:addCompatible 10->30=" .. tostring(rules:isCompatible(10, 30)))
    lurek.log.info("LNeighborRules:addCompatible 30->10=" .. tostring(rules:isCompatible(30, 10)))
end

--@api: LNeighborRules:addCompatibleOneWay
do

    local rules = lurek.mapblock.newRules()
    rules:addCompatibleOneWay(5, 9)
    rules:addCompatibleOneWay(5, 7)
    lurek.log.info("LNeighborRules:addCompatibleOneWay forward59=" .. tostring(rules:isCompatible(5, 9)))
    lurek.log.info("LNeighborRules:addCompatibleOneWay reverse95=" .. tostring(rules:isCompatible(9, 5)))
    lurek.log.info("LNeighborRules:addCompatibleOneWay forward57=" .. tostring(rules:isCompatible(5, 7)))
end

--@api: LNeighborRules:isCompatible
do

    local rules = lurek.mapblock.newRules()
    rules:addCompatible(4, 6)
    local compatible = rules:isCompatible(4, 6)
    local reverse = rules:isCompatible(6, 4)
    local blocked = rules:isCompatible(4, 8)
    lurek.log.info("LNeighborRules:isCompatible 4,6=" .. tostring(compatible))
    lurek.log.info("LNeighborRules:isCompatible 6,4=" .. tostring(reverse))
    lurek.log.info("LNeighborRules:isCompatible 4,8=" .. tostring(blocked))
end

--@api: LNeighborRules:clear
do

    local rules = lurek.mapblock.newRules()
    rules:addCompatible(1, 2)
    rules:clear()
    rules:addCompatibleOneWay(3, 4)
    local before = rules:isCompatible(3, 4)
    rules:clear()
    lurek.log.info("LNeighborRules:clear before=" .. tostring(before))
    lurek.log.info("LNeighborRules:clear after34=" .. tostring(rules:isCompatible(3, 4)))
    lurek.log.info("LNeighborRules:clear after12=" .. tostring(rules:isCompatible(1, 2)))
end

--@api: LPlacementGrid:addPosition
do

    local grid = lurek.mapblock.newGrid(10, 10)
    grid:addPosition(3, 4)
    grid:addPosition(4, 4)
    lurek.log.info("LPlacementGrid:addPosition availCount=" .. grid:getAvailableCount())
    lurek.log.info("LPlacementGrid:addPosition has 3,4=" .. tostring(grid:isAvailable(3, 4)))
    lurek.log.info("LPlacementGrid:addPosition has 4,4=" .. tostring(grid:isAvailable(4, 4)))
end

--@api: LPlacementGrid:isAvailable
do

    local grid = lurek.mapblock.newEmptyGrid()
    grid:addPosition(5, 5)
    grid:addPosition(6, 5)
    lurek.log.info("LPlacementGrid:isAvailable 5,5=" .. tostring(grid:isAvailable(5, 5)))
    lurek.log.info("LPlacementGrid:isAvailable 6,5=" .. tostring(grid:isAvailable(6, 5)))
    lurek.log.info("LPlacementGrid:isAvailable 0,0=" .. tostring(grid:isAvailable(0, 0)))
end

--@api: LPlacementGrid:getAvailableCount
do

    local grid = lurek.mapblock.newEmptyGrid()
    grid:addPosition(1, 1)
    grid:addPosition(2, 2)
    grid:addPosition(3, 3)
    lurek.log.info("LPlacementGrid:getAvailableCount=" .. grid:getAvailableCount())
end

--@api: LPlacementGrid:clear
do

    local grid = lurek.mapblock.newEmptyGrid()
    grid:addPosition(1, 1)
    grid:addPosition(2, 1)
    local before = grid:getAvailableCount()
    grid:clear()
    lurek.log.info("LPlacementGrid:clear before=" .. before)
    lurek.log.info("LPlacementGrid:clear after=" .. grid:getAvailableCount())
    lurek.log.info("LPlacementGrid:clear removed 1,1=" .. tostring(grid:isAvailable(1, 1)))
end

--@api: LTilesetRef:getId
do

    local ref = lurek.mapblock.newTilesetRef(2, "ground_tiles", 64, 8, 32, 32)
    ref:setImagePath("content/examples/assets/ground_tiles.png")
    lurek.log.info("LTilesetRef:getId=" .. tostring(ref:getId()))
    lurek.log.info("LTilesetRef:getId name=" .. tostring(ref:getName()))
    lurek.log.info("LTilesetRef:getId path configured")
end

--@api: LTilesetRef:getName
do

    local ref = lurek.mapblock.newTilesetRef(3, "world_tileset", 128, 16, 16, 16)
    ref:setImagePath("content/examples/assets/world_tileset.png")
    lurek.log.info("LTilesetRef:getName=" .. tostring(ref:getName()))
    lurek.log.info("LTilesetRef:getName id=" .. tostring(ref:getId()))
    lurek.log.info("LTilesetRef:getName image path configured")
end

--@api: LTilesetRef:setImagePath
do

    local ref = lurek.mapblock.newTilesetRef(4, "cave_tiles", 64, 8, 32, 32)
    ref:setImagePath("assets/textures/cave.png")
    lurek.log.info("LTilesetRef:setImagePath name=" .. ref:getName())
    lurek.log.info("LTilesetRef:setImagePath id=" .. tostring(ref:getId()))
    lurek.log.info("LTilesetRef:setImagePath preview asset set")
end

-- --- LMapBlock / LMapGroup / LMapScript (also in tilemap_api.rs) ------------

--@api: LMapBlock:getHeight
do

    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 3, 1, cfg)
    block:setName("hallway")
    lurek.log.info("getHeight=" .. block:getHeight())
    lurek.log.info("getHeight width=" .. block:getWidth())
    lurek.log.info("getHeight name=" .. block:getName())
end

--@api: LMapBlock:getLayerCount
do

    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 3, 2, cfg)
    block:setName("multi_layer_room")
    lurek.log.info("getLayerCount=" .. block:getLayerCount())
    lurek.log.info("getLayerCount width=" .. block:getWidth())
    lurek.log.info("getLayerCount name=" .. block:getName())
end

--@api: LMapBlock:getName
do

    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setName("room_a")
    block:setWeight(2.0)
    lurek.log.info("getName=" .. block:getName())
    lurek.log.info("getName weight=" .. tostring(block:getWeight()))
    lurek.log.info("getName dims=" .. tostring(block:getWidth()) .. "x" .. tostring(block:getHeight()))
end

--@api: LMapBlock:getTile
do

    local cfg = lurek.mapblock.newEmptyConfig()
    cfg:addSlot("floor", true, 0)
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setTile(0, 1, 1, 0, 1, 9)
    local tile = block:getTile(0, 1, 1, 0)
    lurek.log.info("getTile value=" .. tostring(tile))
end

--@api: LMapBlock:getWidth
do

    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 3, 1, cfg)
    block:setName("entry")
    lurek.log.info("getWidth=" .. block:getWidth())
    lurek.log.info("getWidth height=" .. block:getHeight())
    lurek.log.info("getWidth name=" .. block:getName())
end

--@api: LMapBlock:setName
do

    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setName("corridor")
    block:setWeight(1.5)
    lurek.log.info("setName=" .. block:getName())
    lurek.log.info("setName weight=" .. tostring(block:getWeight()))
    lurek.log.info("setName dims=" .. tostring(block:getWidth()) .. "x" .. tostring(block:getHeight()))
end

--@api: LMapBlock:setTile
do

    local cfg = lurek.mapblock.newEmptyConfig()
    cfg:addSlot("wall", true, 0)
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setTile(0, 1, 1, 0, 1, 5)
    lurek.log.info("setTile value=" .. tostring(block:getTile(0, 1, 1, 0)))
end

--@api: LMapBlock:setWeight
do

    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setWeight(3.0)
    block:setName("rare_treasure_room")
    lurek.log.info("setWeight ok")
    lurek.log.info("setWeight value=" .. tostring(block:getWeight()))
    lurek.log.info("setWeight block=" .. block:getName())
end

--@api: LMapGroup:addBlock
do

    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    local group = lurek.mapblock.newGroup("rooms")
    group:addBlock(block)
    lurek.log.info("addBlock count=" .. group:getBlockCount())
end

--@api: LMapGroup:addScript
do

    local script = lurek.mapblock.newScript("rooms_pass")
    script:addStep("fill_rect", { x = 0, y = 0, width = 1, height = 1, tile_id = 1, slot = 0, layer = 0 })
    local group = lurek.mapblock.newGroup("rooms")
    group:addScript(script)
    lurek.log.info("addScript group=" .. group:getName())
end

--@api: LMapGroup:getBlockCount
do

    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    local group = lurek.mapblock.newGroup("rooms")
    group:addBlock(block)
    lurek.log.info("getBlockCount=" .. group:getBlockCount())
end

--@api: LMapGroup:getName
do

    local group = lurek.mapblock.newGroup("dungeon_rooms")
    local script = lurek.mapblock.newScript("rooms_pass")
    group:addScript(script)
    lurek.log.info("getName=" .. group:getName())
    lurek.log.info("getName blockCount=" .. group:getBlockCount())
    lurek.log.info("getName script attached for themed pass")
end

--@api: LMapScript:addStep
do

    local script = lurek.mapblock.newScript("block_fill")
    script:addStep("fill_rect", { x = 1, y = 1, width = 2, height = 2, tile_id = 5, slot = 0, layer = 0 })
    script:addStep("fill_edges", { tile_id = 9, slot = 0, layer = 0 })
    lurek.log.info("addStep count=" .. script:getStepCount())
    lurek.log.info("addStep script=" .. script:getName())
    lurek.log.info("addStep supports multi-pass block painting")
end

--@api: LMapScript:getStepCount
do

    local script = lurek.mapblock.newScript("multi_step")
    script:addStep("fill_rect", { x = 0, y = 0, width = 2, height = 2, tile_id = 1, slot = 0, layer = 0 })
    script:addStep("fill_edges", { tile_id = 2, slot = 0, layer = 0 })
    lurek.log.info("getStepCount=" .. script:getStepCount())
    lurek.log.info("getStepCount script=" .. script:getName())
    lurek.log.info("getStepCount multi-pass setup ready")
end

--@api: LMapBlock:getWeight
do

    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setWeight(3.0)
    block:setName("rare_room")
    lurek.log.info("getWeight=" .. tostring(block:getWeight()))
    lurek.log.info("getWeight block=" .. block:getName())
    lurek.log.info("getWeight dims=" .. tostring(block:getWidth()) .. "x" .. tostring(block:getHeight()))
end

--@api: LMapBlock:setFootprint
do

    local cfg = lurek.mapblock.newConfig()
    cfg:setDefaultSegmentSize(1)
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setFootprint({ { 0, 0 }, { 1, 0 }, { 0, 1 } })
    lurek.log.info("setFootprint cells=" .. tostring(block:getFootprintCellCount()))
end

--@api: LMapBlock:getFootprintCellCount
do

    local cfg = lurek.mapblock.newConfig()
    cfg:setDefaultSegmentSize(1)
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setFootprint({ { 0, 0 }, { 1, 0 }, { 0, 1 } })
    lurek.log.info("getFootprintCellCount=" .. tostring(block:getFootprintCellCount()))
end

--@api: LMapBlock:isFootprintCell
do

    local cfg = lurek.mapblock.newConfig()
    cfg:setDefaultSegmentSize(1)
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setFootprint({ { 0, 0 }, { 1, 0 }, { 0, 1 } })
    lurek.log.info("isFootprintCell=" .. tostring(block:isFootprintCell(1, 0)))
end

--@api: LMapBlock:setSocket
do

    local cfg = lurek.mapblock.newConfig()
    cfg:setDefaultSegmentSize(1)
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setFootprint({ { 0, 0 }, { 1, 0 }, { 0, 1 } })
    block:setSocket(1, 0, "east", 9)
    lurek.log.info("setSocket ok")
end

--@api: LMapBlock:getSocket
do

    local cfg = lurek.mapblock.newConfig()
    cfg:setDefaultSegmentSize(1)
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setFootprint({ { 0, 0 }, { 1, 0 }, { 0, 1 } })
    block:setSocket(1, 0, "east", 9)
    lurek.log.info("getSocket=" .. tostring(block:getSocket(1, 0, "east")))
end

--@api: LPlacementGrid:removePosition
do

    local grid = lurek.mapblock.newEmptyGrid()
    grid:addPosition(1, 1)
    grid:addPosition(2, 1)
    local before = grid:getAvailableCount()
    grid:removePosition(1, 1)
    lurek.log.info("LPlacementGrid:removePosition before=" .. before)
    lurek.log.info("LPlacementGrid:removePosition after=" .. grid:getAvailableCount())
    lurek.log.info("LPlacementGrid:removePosition still has 2,1=" .. tostring(grid:isAvailable(2, 1)))
end

--@api: LPlacementGrid:isEdgePosition
do

    local grid = lurek.mapblock.newEmptyGrid()
    grid:addPosition(0, 0)
    grid:addPosition(1, 0)
    grid:addPosition(1, 1)
    lurek.log.info("LPlacementGrid:isEdgePosition=" .. tostring(grid:isEdgePosition(1, 1)))
end

--@api: LMapBlockGenerator:setGrid
do

    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    local grid = lurek.mapblock.newEmptyGrid()
    grid:addPosition(0, 0)
    grid:addPosition(1, 0)
    grid:addPosition(1, 1)
    gen:setGrid(grid)
    lurek.log.info("LMapBlockGenerator:setGrid ready=true")
end

--@api: LMapBlockResult:getPlacements
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
    lurek.log.info("LMapBlockResult:getPlacements count=" .. tostring(#result:getPlacements()))
end

--- Added coverage examples for newer API owners.

--@api: LMapBlockResult:toTileField
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(1, 1, 1, cfg)
    block:setTile(0, 0, 0, 0, 0, 7)
    local group = lurek.mapblock.newGroup("terrain")
    group:addBlock(block)
    local script = lurek.mapblock.newScript("place_once")
    script:addStep("place_block", { group = "terrain", block_index = 0, x = 0, y = 0 })
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(1, 1)
    gen:addGroup(group)
    local result = gen:generate(script)
    local ok, value = pcall(function()
        local field = result:toTileField({ ref = "terrain", layer = 0, level = 0 })
        return field:getRef(1, 1, 1, "terrain")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LMapBlockResult:writeTileField
do
    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(1, 1, 1, cfg)
    block:setTile(0, 0, 0, 0, 0, 7)
    local group = lurek.mapblock.newGroup("terrain")
    group:addBlock(block)
    local script = lurek.mapblock.newScript("place_once")
    script:addStep("place_block", { group = "terrain", block_index = 0, x = 0, y = 0 })
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(1, 1)
    gen:addGroup(group)
    local result = gen:generate(script)
    local ok, value = pcall(function()
        local field = lurek.tilefield.new({ width = 1, height = 1 })
        result:writeTileField(field, { ref = "terrain", layer = 0, level = 0 })
        return field:getRef(1, 1, 1, "terrain")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
