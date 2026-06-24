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
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    cfg:addSlot("detail", false, 0)
    local slots = cfg:getSlotCount()
    mapblock_log("newConfig slotCount=" .. slots)
    mapblock_log("newConfig supports detail slot=" .. tostring(slots > 0))
    mapblock_log("newConfig ready for layered room blocks")
end

--@api: lurek.mapblock.newEmptyConfig
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newEmptyConfig()
    cfg:addSlot("floor", true, 0)
    cfg:addSlot("wall", false, 0)
    local slots = cfg:getSlotCount()
    mapblock_log("newEmptyConfig slotCount=" .. slots)
    mapblock_log("newEmptyConfig keeps only authored slots")
    mapblock_log("newEmptyConfig wall slot added=" .. tostring(slots == 2))
end

--@api: lurek.mapblock.newBlock
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 4, 1, cfg)
    block:setName("entrance_room")
    local width = block:getWidth()
    local height = block:getHeight()
    mapblock_log("newBlock dims=" .. width .. "x" .. height)
    mapblock_log("newBlock layers=" .. block:getLayerCount())
    mapblock_log("newBlock name=" .. block:getName())
end

--@api: lurek.mapblock.newGroup
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local group = lurek.mapblock.newGroup("rooms")
    local script = lurek.mapblock.newScript("rooms_pass")
    group:addScript(script)
    mapblock_log("newGroup name=" .. group:getName())
    mapblock_log("newGroup blockCount=" .. group:getBlockCount())
    mapblock_log("newGroup accepts scripts for themed passes")
end

--@api: lurek.mapblock.newScript
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local script = lurek.mapblock.newScript("layout_pass")
    script:addStep("fill_rect", { x = 0, y = 0, width = 4, height = 3, tile_id = 1, slot = 0, layer = 0 })
    script:addStep("fill_edges", { tile_id = 2, slot = 0, layer = 0 })
    mapblock_log("newScript steps=" .. script:getStepCount())
    mapblock_log("newScript name=" .. script:getName())
    mapblock_log("newScript ready for layout pass")
end

--@api: lurek.mapblock.newRules
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rules = lurek.mapblock.newRules()
    rules:addCompatible(1, 2)
    rules:addCompatibleOneWay(3, 4)
    mapblock_log("newRules compatible12=" .. tostring(rules:isCompatible(1, 2)))
    mapblock_log("newRules compatible34=" .. tostring(rules:isCompatible(3, 4)))
    mapblock_log("newRules reverse43=" .. tostring(rules:isCompatible(4, 3)))
end

--@api: lurek.mapblock.newGrid
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.mapblock.newGrid(10, 10)
    grid:addPosition(3, 4)
    grid:addPosition(4, 4)
    mapblock_log("newGrid available=" .. grid:getAvailableCount())
    mapblock_log("newGrid position 3,4 available=" .. tostring(grid:isAvailable(3, 4)))
    mapblock_log("newGrid edge position 3,4=" .. tostring(grid:isEdgePosition(3, 4)))
end

--@api: lurek.mapblock.newEmptyGrid
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.mapblock.newEmptyGrid()
    grid:addPosition(2, 2)
    grid:addPosition(2, 3)
    mapblock_log("newEmptyGrid available=" .. grid:getAvailableCount())
    mapblock_log("newEmptyGrid position 2,2 available=" .. tostring(grid:isAvailable(2, 2)))
    mapblock_log("newEmptyGrid supports arbitrary shapes")
end

--@api: lurek.mapblock.newGenerator
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(6, 4)
    gen:setSeed(17)
    gen:setMaxLevels(2)
    mapblock_log("newGenerator ready=true")
    mapblock_log("newGenerator shape set to 6x4")
    mapblock_log("newGenerator max levels configured")
end

--@api: lurek.mapblock.newTilesetRef
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ref = lurek.mapblock.newTilesetRef(1, "ground_tiles", 64, 8, 32, 32)
    ref:setImagePath("content/examples/assets/mapblock_ground.png")
    mapblock_log("newTilesetRef id=" .. ref:getId())
    mapblock_log("newTilesetRef name=" .. ref:getName())
    mapblock_log("newTilesetRef image path configured for preview")
end

--@api: LMapBlock:setEdge
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 4, 1, cfg)
    block:setEdge("north", 0, 2)
    block:setEdge("south", 0, 2)
    example_print_log("LMapBlock:setEdge width=" .. block:getWidth())
end

--@api: LMapBlock:setEdgeOnly
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 4, 1, cfg)
    block:setEdgeOnly(true)
    block:setName("perimeter_wall")
    mapblock_log("setEdgeOnly height=" .. block:getHeight())
    mapblock_log("setEdgeOnly block name=" .. block:getName())
    mapblock_log("setEdgeOnly keeps perimeter pieces on outer border")
end

--@api: LMapBlock:setInteriorOnly
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 4, 1, cfg)
    block:setInteriorOnly(true)
    block:setName("treasure_room")
    mapblock_log("setInteriorOnly width=" .. block:getWidth())
    mapblock_log("setInteriorOnly block name=" .. block:getName())
    mapblock_log("setInteriorOnly reserves this block for inner cells")
end

--@api: LMapBlock:setLevelSpan
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 4, 2, cfg)
    block:setLevelSpan(2)
    block:setName("stairwell")
    mapblock_log("setLevelSpan layers=" .. block:getLayerCount())
    mapblock_log("setLevelSpan block height=" .. block:getHeight())
    mapblock_log("setLevelSpan block name=" .. block:getName())
end

--@api: LMapBlockConfig:addSlot
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    cfg:addSlot("wall", true, 0)
    cfg:addSlot("floor", false, 1)
    cfg:addSlot("ceiling", false, 0)
    mapblock_log("addSlot slotCount=" .. cfg:getSlotCount())
    mapblock_log("addSlot room config has ceiling slot")
    mapblock_log("addSlot supports authored wall/floor layering")
end

--@api: LMapBlockConfig:removeSlot
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    cfg:addSlot("door", false, 0)
    cfg:removeSlot("door")
    local slots = cfg:getSlotCount()
    cfg:addSlot("door", false, 0)
    mapblock_log("removeSlot remaining slots=" .. slots)
    mapblock_log("removeSlot restored slots=" .. cfg:getSlotCount())
    mapblock_log("removeSlot helps trim temporary authoring channels")
end

--@api: LMapBlockConfig:getSlotCount
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    cfg:addSlot("layer1", true, 0)
    cfg:addSlot("layer2", false, 1)
    cfg:addSlot("layer3", false, 2)
    example_print_log("LMapBlockConfig:getSlotCount=" .. cfg:getSlotCount())
end

--@api: LMapBlockConfig:setMaxLayers
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    cfg:setMaxLayers(3)
    cfg:addSlot("detail", false, 0)
    mapblock_log("setMaxLayers slotCount=" .. cfg:getSlotCount())
    mapblock_log("setMaxLayers allows floor/wall/detail layering")
    mapblock_log("setMaxLayers configured for 3 exported layers")
end

--@api: LMapBlockConfig:setDefaultSegmentSize
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    cfg:setDefaultSegmentSize(32)
    cfg:addSlot("floor", true, 0)
    mapblock_log("setDefaultSegmentSize slotCount=" .. cfg:getSlotCount())
    mapblock_log("setDefaultSegmentSize uses 32px wall segments")
    mapblock_log("setDefaultSegmentSize ready for block snapping")
end

--@api: LMapBlockGenerator:setRectShape
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(10, 8)
    gen:setSeed(5)
    mapblock_log("setRectShape ready=true")
    mapblock_log("setRectShape dimensions=10x8")
    mapblock_log("setRectShape deterministic seed applied")
end

--@api: LMapBlockGenerator:setShape
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setShape({ { 0, 0 }, { 1, 0 }, { 1, 1 }, { 2, 1 } })
    gen:setSeed(9)
    mapblock_log("setShape ready=true")
    mapblock_log("setShape custom footprint cells=4")
    mapblock_log("setShape supports carved irregular corridors")
end

--@api: LMapBlockGenerator:setOrientation
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setOrientation("isometric")
    gen:setTileSize(32, 16)
    mapblock_log("setOrientation ready=true")
    mapblock_log("setOrientation mode=isometric")
    mapblock_log("setOrientation paired with 32x16 tile pixels")
end

--@api: LMapBlockGenerator:setMaxLevels
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setMaxLevels(3)
    gen:setRectShape(6, 6)
    mapblock_log("setMaxLevels ready=true")
    mapblock_log("setMaxLevels storeys=3")
    mapblock_log("setMaxLevels used for towers and stairwells")
end

--@api: LMapBlockGenerator:setRules
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    local rules = lurek.mapblock.newRules()
    rules:addCompatible(1, 2)
    gen:setRules(rules)
    example_print_log("LMapBlockGenerator:setRules compatible=" .. tostring(rules:isCompatible(1, 2)))
end

--@api: LMapBlockGenerator:setSeed
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setSeed(12345)
    gen:setRectShape(5, 5)
    mapblock_log("setSeed ready=true")
    mapblock_log("setSeed value=12345")
    mapblock_log("setSeed makes block placement reproducible")
end

--@api: LMapBlockGenerator:setTileSize
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setTileSize(32, 32)
    gen:setOrientation("topdown")
    mapblock_log("setTileSize ready=true")
    mapblock_log("setTileSize value=32x32")
    mapblock_log("setTileSize matches authored dungeon tiles")
end

--@api: LMapBlockGenerator:setSolverBudget
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

--@api: LMapBlockGenerator:addGroup
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    local group = lurek.mapblock.newGroup("rooms")
    gen:addGroup(group)
    example_print_log("LMapBlockGenerator:addGroup group=" .. group:getName())
end

--@api: LMapBlockGenerator:generate
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

--@api: LMapBlockGenerator:generateWithReport
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

--@api: LMapBlockGenerator:getLastPlacedCount
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("rect_fill")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(8, 6)
    gen:setSeed(42)
    script:addStep("fill_rect", { x = 0, y = 0, width = 2, height = 2, tile_id = 1, slot = 0, layer = 0 })
    gen:generate(script)
    example_print_log("LMapBlockGenerator:getLastPlacedCount=" .. gen:getLastPlacedCount())
end

--@api: LMapBlockGenerator:getLastReport
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

--@api: LMapBlockReport:toTable
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

--@api: LMapBlockResult:getWidth
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("rect_fill")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(8, 6)
    script:addStep("fill_rect", { x = 0, y = 0, width = 2, height = 2, tile_id = 1, slot = 0, layer = 0 })
    local result = gen:generate(script)
    example_print_log("LMapBlockResult:getWidth=" .. result:getWidth())
end

--@api: LMapBlockResult:getHeight
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("rect_fill")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(8, 6)
    script:addStep("fill_rect", { x = 0, y = 0, width = 2, height = 2, tile_id = 1, slot = 0, layer = 0 })
    local result = gen:generate(script)
    example_print_log("LMapBlockResult:getHeight=" .. result:getHeight())
end

--@api: LMapBlockResult:getLevelCount
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("rect_fill")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(4, 4)
    gen:setMaxLevels(2)
    script:addStep("fill_rect", { x = 0, y = 0, width = 2, height = 2, tile_id = 1, slot = 0, layer = 0, level = 0 })
    local result = gen:generate(script)
    example_print_log("LMapBlockResult:getLevelCount=" .. result:getLevelCount())
end

--@api: LMapBlockResult:getLayerCount
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("rect_fill")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(4, 4)
    script:addStep("fill_rect", { x = 0, y = 0, width = 2, height = 2, tile_id = 1, slot = 0, layer = 0 })
    local result = gen:generate(script)
    example_print_log("LMapBlockResult:getLayerCount=" .. result:getLayerCount())
end

--@api: LMapBlockResult:getGid
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("rect_fill")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(4, 4)
    script:addStep("fill_rect", { x = 0, y = 0, width = 2, height = 2, tile_id = 7, slot = 0, layer = 0, level = 0 })
    local result = gen:generate(script)
    local gid = result:getGid(0, 0, 0, 0, 0)
    example_print_log("LMapBlockResult:getGid=" .. tostring(gid))
end

--@api: LMapBlockResult:getBlocksPlaced
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("place_once")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(6, 6)
    gen:setSeed(1)
    script:addStep("fill_rect", { x = 1, y = 1, width = 2, height = 2, tile_id = 4, slot = 0, layer = 0 })
    local result = gen:generate(script)
    example_print_log("LMapBlockResult:getBlocksPlaced=" .. result:getBlocksPlaced())
end

--@api: LMapBlockResult:isEmpty
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    local script = lurek.mapblock.newScript("empty")
    local gen = lurek.mapblock.newGenerator(cfg)
    gen:setRectShape(4, 4)
    local result = gen:generate(script)
    example_print_log("LMapBlockResult:isEmpty=" .. tostring(result:isEmpty()))
end

--@api: LMapScript:clear
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local script = lurek.mapblock.newScript("cleanup")
    script:addStep("fill_rect", { x = 0, y = 0, width = 2, height = 2, tile_id = 1, slot = 0, layer = 0 })
    script:addStep("fill_edges", { tile_id = 2, slot = 0, layer = 0 })
    script:clear()
    example_print_log("LMapScript:clear stepCount=" .. script:getStepCount())
end

--@api: LMapScript:getName
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local script = lurek.mapblock.newScript("dungeon_gen")
    script:addStep("fill_rect", { x = 0, y = 0, width = 1, height = 1, tile_id = 1, slot = 0, layer = 0 })
    mapblock_log("LMapScript:getName=" .. tostring(script:getName()))
    mapblock_log("LMapScript:getName steps=" .. tostring(script:getStepCount()))
    mapblock_log("LMapScript:getName ready for dungeon pass")
end

--@api: LNeighborRules:addCompatible
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rules = lurek.mapblock.newRules()
    rules:addCompatible(10, 20)
    rules:addCompatible(10, 30)
    mapblock_log("LNeighborRules:addCompatible 20->10=" .. tostring(rules:isCompatible(20, 10)))
    mapblock_log("LNeighborRules:addCompatible 10->30=" .. tostring(rules:isCompatible(10, 30)))
    mapblock_log("LNeighborRules:addCompatible 30->10=" .. tostring(rules:isCompatible(30, 10)))
end

--@api: LNeighborRules:addCompatibleOneWay
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rules = lurek.mapblock.newRules()
    rules:addCompatibleOneWay(5, 9)
    rules:addCompatibleOneWay(5, 7)
    mapblock_log("LNeighborRules:addCompatibleOneWay forward59=" .. tostring(rules:isCompatible(5, 9)))
    mapblock_log("LNeighborRules:addCompatibleOneWay reverse95=" .. tostring(rules:isCompatible(9, 5)))
    mapblock_log("LNeighborRules:addCompatibleOneWay forward57=" .. tostring(rules:isCompatible(5, 7)))
end

--@api: LNeighborRules:isCompatible
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rules = lurek.mapblock.newRules()
    rules:addCompatible(4, 6)
    local compatible = rules:isCompatible(4, 6)
    local reverse = rules:isCompatible(6, 4)
    local blocked = rules:isCompatible(4, 8)
    mapblock_log("LNeighborRules:isCompatible 4,6=" .. tostring(compatible))
    mapblock_log("LNeighborRules:isCompatible 6,4=" .. tostring(reverse))
    mapblock_log("LNeighborRules:isCompatible 4,8=" .. tostring(blocked))
end

--@api: LNeighborRules:clear
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

--@api: LPlacementGrid:addPosition
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.mapblock.newGrid(10, 10)
    grid:addPosition(3, 4)
    grid:addPosition(4, 4)
    mapblock_log("LPlacementGrid:addPosition availCount=" .. grid:getAvailableCount())
    mapblock_log("LPlacementGrid:addPosition has 3,4=" .. tostring(grid:isAvailable(3, 4)))
    mapblock_log("LPlacementGrid:addPosition has 4,4=" .. tostring(grid:isAvailable(4, 4)))
end

--@api: LPlacementGrid:isAvailable
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.mapblock.newEmptyGrid()
    grid:addPosition(5, 5)
    grid:addPosition(6, 5)
    mapblock_log("LPlacementGrid:isAvailable 5,5=" .. tostring(grid:isAvailable(5, 5)))
    mapblock_log("LPlacementGrid:isAvailable 6,5=" .. tostring(grid:isAvailable(6, 5)))
    mapblock_log("LPlacementGrid:isAvailable 0,0=" .. tostring(grid:isAvailable(0, 0)))
end

--@api: LPlacementGrid:getAvailableCount
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.mapblock.newEmptyGrid()
    grid:addPosition(1, 1)
    grid:addPosition(2, 2)
    grid:addPosition(3, 3)
    example_print_log("LPlacementGrid:getAvailableCount=" .. grid:getAvailableCount())
end

--@api: LPlacementGrid:clear
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.mapblock.newEmptyGrid()
    grid:addPosition(1, 1)
    grid:addPosition(2, 1)
    local before = grid:getAvailableCount()
    grid:clear()
    mapblock_log("LPlacementGrid:clear before=" .. before)
    mapblock_log("LPlacementGrid:clear after=" .. grid:getAvailableCount())
    mapblock_log("LPlacementGrid:clear removed 1,1=" .. tostring(grid:isAvailable(1, 1)))
end

--@api: LTilesetRef:getId
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ref = lurek.mapblock.newTilesetRef(2, "ground_tiles", 64, 8, 32, 32)
    ref:setImagePath("content/examples/assets/ground_tiles.png")
    mapblock_log("LTilesetRef:getId=" .. tostring(ref:getId()))
    mapblock_log("LTilesetRef:getId name=" .. tostring(ref:getName()))
    mapblock_log("LTilesetRef:getId path configured")
end

--@api: LTilesetRef:getName
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ref = lurek.mapblock.newTilesetRef(3, "world_tileset", 128, 16, 16, 16)
    ref:setImagePath("content/examples/assets/world_tileset.png")
    mapblock_log("LTilesetRef:getName=" .. tostring(ref:getName()))
    mapblock_log("LTilesetRef:getName id=" .. tostring(ref:getId()))
    mapblock_log("LTilesetRef:getName image path configured")
end

--@api: LTilesetRef:setImagePath
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ref = lurek.mapblock.newTilesetRef(4, "cave_tiles", 64, 8, 32, 32)
    ref:setImagePath("assets/textures/cave.png")
    mapblock_log("LTilesetRef:setImagePath name=" .. ref:getName())
    mapblock_log("LTilesetRef:setImagePath id=" .. tostring(ref:getId()))
    mapblock_log("LTilesetRef:setImagePath preview asset set")
end

-- --- LMapBlock / LMapGroup / LMapScript (also in tilemap_api.rs) ------------

--@api: LMapBlock:getHeight
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 3, 1, cfg)
    block:setName("hallway")
    mapblock_log("getHeight=" .. block:getHeight())
    mapblock_log("getHeight width=" .. block:getWidth())
    mapblock_log("getHeight name=" .. block:getName())
end

--@api: LMapBlock:getLayerCount
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 3, 2, cfg)
    block:setName("multi_layer_room")
    mapblock_log("getLayerCount=" .. block:getLayerCount())
    mapblock_log("getLayerCount width=" .. block:getWidth())
    mapblock_log("getLayerCount name=" .. block:getName())
end

--@api: LMapBlock:getName
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setName("room_a")
    block:setWeight(2.0)
    mapblock_log("getName=" .. block:getName())
    mapblock_log("getName weight=" .. tostring(block:getWeight()))
    mapblock_log("getName dims=" .. tostring(block:getWidth()) .. "x" .. tostring(block:getHeight()))
end

--@api: LMapBlock:getTile
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newEmptyConfig()
    cfg:addSlot("floor", true, 0)
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setTile(0, 1, 1, 0, 1, 9)
    local tile = block:getTile(0, 1, 1, 0)
    example_print_log("getTile value=" .. tostring(tile))
end

--@api: LMapBlock:getWidth
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(4, 3, 1, cfg)
    block:setName("entry")
    mapblock_log("getWidth=" .. block:getWidth())
    mapblock_log("getWidth height=" .. block:getHeight())
    mapblock_log("getWidth name=" .. block:getName())
end

--@api: LMapBlock:setName
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setName("corridor")
    block:setWeight(1.5)
    mapblock_log("setName=" .. block:getName())
    mapblock_log("setName weight=" .. tostring(block:getWeight()))
    mapblock_log("setName dims=" .. tostring(block:getWidth()) .. "x" .. tostring(block:getHeight()))
end

--@api: LMapBlock:setTile
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newEmptyConfig()
    cfg:addSlot("wall", true, 0)
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setTile(0, 1, 1, 0, 1, 5)
    example_print_log("setTile value=" .. tostring(block:getTile(0, 1, 1, 0)))
end

--@api: LMapBlock:setWeight
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setWeight(3.0)
    block:setName("rare_treasure_room")
    mapblock_log("setWeight ok")
    mapblock_log("setWeight value=" .. tostring(block:getWeight()))
    mapblock_log("setWeight block=" .. block:getName())
end

--@api: LMapGroup:addBlock
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    local group = lurek.mapblock.newGroup("rooms")
    group:addBlock(block)
    example_print_log("addBlock count=" .. group:getBlockCount())
end

--@api: LMapGroup:addScript
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local script = lurek.mapblock.newScript("rooms_pass")
    script:addStep("fill_rect", { x = 0, y = 0, width = 1, height = 1, tile_id = 1, slot = 0, layer = 0 })
    local group = lurek.mapblock.newGroup("rooms")
    group:addScript(script)
    example_print_log("addScript group=" .. group:getName())
end

--@api: LMapGroup:getBlockCount
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    local group = lurek.mapblock.newGroup("rooms")
    group:addBlock(block)
    example_print_log("getBlockCount=" .. group:getBlockCount())
end

--@api: LMapGroup:getName
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local group = lurek.mapblock.newGroup("dungeon_rooms")
    local script = lurek.mapblock.newScript("rooms_pass")
    group:addScript(script)
    mapblock_log("getName=" .. group:getName())
    mapblock_log("getName blockCount=" .. group:getBlockCount())
    mapblock_log("getName script attached for themed pass")
end

--@api: LMapScript:addStep
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local script = lurek.mapblock.newScript("block_fill")
    script:addStep("fill_rect", { x = 1, y = 1, width = 2, height = 2, tile_id = 5, slot = 0, layer = 0 })
    script:addStep("fill_edges", { tile_id = 9, slot = 0, layer = 0 })
    mapblock_log("addStep count=" .. script:getStepCount())
    mapblock_log("addStep script=" .. script:getName())
    mapblock_log("addStep supports multi-pass block painting")
end

--@api: LMapScript:getStepCount
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local script = lurek.mapblock.newScript("multi_step")
    script:addStep("fill_rect", { x = 0, y = 0, width = 2, height = 2, tile_id = 1, slot = 0, layer = 0 })
    script:addStep("fill_edges", { tile_id = 2, slot = 0, layer = 0 })
    mapblock_log("getStepCount=" .. script:getStepCount())
    mapblock_log("getStepCount script=" .. script:getName())
    mapblock_log("getStepCount multi-pass setup ready")
end

--@api: LMapBlock:getWeight
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setWeight(3.0)
    block:setName("rare_room")
    mapblock_log("getWeight=" .. tostring(block:getWeight()))
    mapblock_log("getWeight block=" .. block:getName())
    mapblock_log("getWeight dims=" .. tostring(block:getWidth()) .. "x" .. tostring(block:getHeight()))
end

--@api: LMapBlock:setFootprint
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    cfg:setDefaultSegmentSize(1)
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setFootprint({ { 0, 0 }, { 1, 0 }, { 0, 1 } })
    example_print_log("setFootprint cells=" .. tostring(block:getFootprintCellCount()))
end

--@api: LMapBlock:getFootprintCellCount
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    cfg:setDefaultSegmentSize(1)
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setFootprint({ { 0, 0 }, { 1, 0 }, { 0, 1 } })
    example_print_log("getFootprintCellCount=" .. tostring(block:getFootprintCellCount()))
end

--@api: LMapBlock:isFootprintCell
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    cfg:setDefaultSegmentSize(1)
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setFootprint({ { 0, 0 }, { 1, 0 }, { 0, 1 } })
    example_print_log("isFootprintCell=" .. tostring(block:isFootprintCell(1, 0)))
end

--@api: LMapBlock:setSocket
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    cfg:setDefaultSegmentSize(1)
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setFootprint({ { 0, 0 }, { 1, 0 }, { 0, 1 } })
    block:setSocket(1, 0, "east", 9)
    example_print_log("setSocket ok")
end

--@api: LMapBlock:getSocket
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    cfg:setDefaultSegmentSize(1)
    local block = lurek.mapblock.newBlock(2, 2, 1, cfg)
    block:setFootprint({ { 0, 0 }, { 1, 0 }, { 0, 1 } })
    block:setSocket(1, 0, "east", 9)
    example_print_log("getSocket=" .. tostring(block:getSocket(1, 0, "east")))
end

--@api: LPlacementGrid:removePosition
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.mapblock.newEmptyGrid()
    grid:addPosition(1, 1)
    grid:addPosition(2, 1)
    local before = grid:getAvailableCount()
    grid:removePosition(1, 1)
    mapblock_log("LPlacementGrid:removePosition before=" .. before)
    mapblock_log("LPlacementGrid:removePosition after=" .. grid:getAvailableCount())
    mapblock_log("LPlacementGrid:removePosition still has 2,1=" .. tostring(grid:isAvailable(2, 1)))
end

--@api: LPlacementGrid:isEdgePosition
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local grid = lurek.mapblock.newEmptyGrid()
    grid:addPosition(0, 0)
    grid:addPosition(1, 0)
    grid:addPosition(1, 1)
    example_print_log("LPlacementGrid:isEdgePosition=" .. tostring(grid:isEdgePosition(1, 1)))
end

--@api: LMapBlockGenerator:setGrid
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cfg = lurek.mapblock.newConfig()
    local gen = lurek.mapblock.newGenerator(cfg)
    local grid = lurek.mapblock.newEmptyGrid()
    grid:addPosition(0, 0)
    grid:addPosition(1, 0)
    grid:addPosition(1, 1)
    gen:setGrid(grid)
    example_print_log("LMapBlockGenerator:setGrid ready=true")
end

--@api: LMapBlockResult:getPlacements
do
    local function mapblock_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

--- Added coverage examples for newer API owners.

--@api: LMapBlockResult:toTileField
do
    local function example_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LMapBlockResult:writeTileField
do
    local function example_log(message)
        lurek.log.info("[mapblock.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end
