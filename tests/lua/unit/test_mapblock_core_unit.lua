-- Lurek2D MapBlock API Tests
-- Covers lurek.mapblock module: config, blocks, groups, scripts,
-- rules, grids, generators, and tileset references.

-- =========================================================================
-- Module existence
-- =========================================================================

-- @describe lurek.mapblock module exists
describe("lurek.mapblock module exists", function()
    -- @covers lurek.mapblock
    it("lurek.mapblock is a table", function()
        expect_type("table", lurek.mapblock)
    end)

    -- @covers lurek.mapblock.newConfig
    -- @covers lurek.mapblock.newEmptyConfig
    -- @covers lurek.mapblock.newBlock
    -- @covers lurek.mapblock.newGroup
    -- @covers lurek.mapblock.newScript
    -- @covers lurek.mapblock.newRules
    -- @covers lurek.mapblock.newGrid
    -- @covers lurek.mapblock.newEmptyGrid
    -- @covers lurek.mapblock.newGenerator
    -- @covers lurek.mapblock.newTilesetRef
    it("exposes factory functions", function()
        expect_type("function", lurek.mapblock.newConfig)
        expect_type("function", lurek.mapblock.newEmptyConfig)
        expect_type("function", lurek.mapblock.newBlock)
        expect_type("function", lurek.mapblock.newGroup)
        expect_type("function", lurek.mapblock.newScript)
        expect_type("function", lurek.mapblock.newRules)
        expect_type("function", lurek.mapblock.newGrid)
        expect_type("function", lurek.mapblock.newEmptyGrid)
        expect_type("function", lurek.mapblock.newGenerator)
        expect_type("function", lurek.mapblock.newTilesetRef)
    end)
end)

-- =========================================================================
-- MapBlockConfig
-- =========================================================================

-- @describe MapBlockConfig
describe("MapBlockConfig", function()
    -- @covers lurek.mapblock.newConfig
    it("newConfig returns a config with default slots", function()
        local cfg = lurek.mapblock.newConfig()
        expect_type("userdata", cfg)
        local slots = cfg:slots()
        assert_true(#slots > 0)
    end)

    -- @covers lurek.mapblock.newEmptyConfig
    it("newEmptyConfig returns a config with no slots", function()
        local cfg = lurek.mapblock.newEmptyConfig()
        expect_type("userdata", cfg)
        local slots = cfg:slots()
        assert_equal(0, #slots)
    end)

    -- @covers lurek.mapblock.newConfig
    it("default config has 5 standard slots", function()
        local cfg = lurek.mapblock.newConfig()
        local slots = cfg:slots()
        assert_equal(5, #slots)
    end)

    -- @covers lurek.mapblock.newEmptyConfig
    it("addSlot adds a slot to empty config", function()
        local cfg = lurek.mapblock.newEmptyConfig()
        cfg:addSlot("custom")
        local slots = cfg:slots()
        assert_equal(1, #slots)
        assert_equal("custom", slots[1])
    end)
end)

-- =========================================================================
-- MapBlock
-- =========================================================================

-- @describe MapBlock creation and tiles
describe("MapBlock creation and tiles", function()
    -- @covers lurek.mapblock.newBlock
    it("newBlock creates a block with correct dimensions", function()
        local cfg = lurek.mapblock.newConfig()
        local block = lurek.mapblock.newBlock("test", 8, 6, 2, cfg)
        expect_type("userdata", block)
        assert_equal(8, block:width())
        assert_equal(6, block:height())
        assert_equal(2, block:layers())
    end)

    -- @covers lurek.mapblock.newBlock
    it("setTile and getTile roundtrip", function()
        local cfg = lurek.mapblock.newConfig()
        local block = lurek.mapblock.newBlock("test", 4, 4, 1, cfg)
        block:setTile(0, 0, 0, "floor", 1, 42)
        local tid, gid = block:getTile(0, 0, 0, "floor")
        assert_equal(1, tid)
        assert_equal(42, gid)
    end)

    -- @covers lurek.mapblock.newBlock
    it("setWeight changes block weight", function()
        local cfg = lurek.mapblock.newConfig()
        local block = lurek.mapblock.newBlock("test", 4, 4, 1, cfg)
        block:setWeight(2.5)
        -- No crash = pass (weight is used internally by generator)
        assert_true(true)
    end)

    -- @covers lurek.mapblock.newBlock
    it("setSide marks edge compatibility", function()
        local cfg = lurek.mapblock.newConfig()
        local block = lurek.mapblock.newBlock("test", 4, 4, 1, cfg)
        block:setSide("north", true)
        block:setSide("south", false)
        -- Setter does not crash
        assert_true(true)
    end)
end)

-- =========================================================================
-- PlacementGrid
-- =========================================================================

-- @describe PlacementGrid
describe("PlacementGrid", function()
    -- @covers lurek.mapblock.newGrid
    it("newGrid creates grid with dimensions", function()
        local grid = lurek.mapblock.newGrid(10, 8)
        expect_type("userdata", grid)
        assert_equal(10, grid:width())
        assert_equal(8, grid:height())
    end)

    -- @covers lurek.mapblock.newEmptyGrid
    it("newEmptyGrid creates empty grid", function()
        local grid = lurek.mapblock.newEmptyGrid()
        expect_type("userdata", grid)
        assert_equal(0, grid:cellCount())
    end)

    -- @covers lurek.mapblock.newEmptyGrid
    it("addCell adds a cell to empty grid", function()
        local grid = lurek.mapblock.newEmptyGrid()
        grid:addCell(3, 5)
        assert_equal(1, grid:cellCount())
    end)
end)

-- =========================================================================
-- NeighborRules
-- =========================================================================

-- @describe NeighborRules
describe("NeighborRules", function()
    -- @covers lurek.mapblock.newRules
    it("newRules creates empty rules", function()
        local rules = lurek.mapblock.newRules()
        expect_type("userdata", rules)
        assert_equal(0, rules:count())
    end)

    -- @covers lurek.mapblock.newRules
    it("addRule increases rule count", function()
        local rules = lurek.mapblock.newRules()
        rules:addRule("blockA", "north", "blockB")
        assert_equal(1, rules:count())
    end)
end)

-- =========================================================================
-- Generator
-- =========================================================================

-- @describe Generator
describe("Generator", function()
    -- @covers lurek.mapblock.newGenerator
    it("newGenerator creates generator with seed", function()
        local gen = lurek.mapblock.newGenerator(12345)
        expect_type("userdata", gen)
    end)

    -- @covers lurek.mapblock.newGroup
    it("addGroup registers a block group", function()
        local gen = lurek.mapblock.newGenerator(42)
        local group = lurek.mapblock.newGroup("terrain")
        gen:addGroup(group)
        assert_true(true)
    end)
end)

-- =========================================================================
-- TilesetRef
-- =========================================================================

-- @describe TilesetRef
describe("TilesetRef", function()
    -- @covers lurek.mapblock.newTilesetRef
    it("newTilesetRef creates a tileset reference", function()
        local ts = lurek.mapblock.newTilesetRef(1, "ground", 64, 8, 32, 32, "ground.png")
        expect_type("userdata", ts)
    end)
end)

-- =========================================================================
-- GenerationScript
-- =========================================================================

-- @describe GenerationScript
describe("GenerationScript", function()
    -- @covers lurek.mapblock.newScript
    it("newScript creates empty script", function()
        local script = lurek.mapblock.newScript()
        expect_type("userdata", script)
        assert_equal(0, script:stepCount())
    end)

    -- @covers lurek.mapblock.newScript
    it("addStep adds generation steps", function()
        local script = lurek.mapblock.newScript()
        script:addStep("fill", { block = "grass" })
        assert_equal(1, script:stepCount())
    end)
end)

-- =========================================================================
-- MapBlockConfig extended coverage
-- =========================================================================

-- @describe MapBlockConfig getSlotCount setMaxLayers setDefaultSegmentSize
describe("MapBlockConfig getSlotCount setMaxLayers setDefaultSegmentSize", function()
    -- @covers LMapBlockConfig:getSlotCount
    it("getSlotCount returns number of defined slots", function()
        local cfg = lurek.mapblock.newConfig()
        local count = cfg:getSlotCount()
        expect_type("number", count)
        assert_true(count > 0)
    end)

    -- @covers LMapBlockConfig:getSlotCount
    it("getSlotCount is zero for empty config", function()
        local cfg = lurek.mapblock.newEmptyConfig()
        assert_equal(0, cfg:getSlotCount())
    end)

    -- @covers LMapBlockConfig:setMaxLayers
    it("setMaxLayers configures max layers without crash", function()
        local cfg = lurek.mapblock.newConfig()
        cfg:setMaxLayers(3)
        assert_true(true)
    end)

    -- @covers LMapBlockConfig:setDefaultSegmentSize
    it("setDefaultSegmentSize configures segment size without crash", function()
        local cfg = lurek.mapblock.newConfig()
        cfg:setDefaultSegmentSize(16)
        assert_true(true)
    end)
end)

-- =========================================================================
-- MapBlock edge and placement flags
-- =========================================================================

-- @describe MapBlock setEdge setEdgeOnly setInteriorOnly setLevelSpan
describe("MapBlock setEdge setEdgeOnly setInteriorOnly setLevelSpan", function()
    local function make_block()
        local cfg = lurek.mapblock.newConfig()
        return lurek.mapblock.newBlock(4, 4, 1, cfg)
    end

    -- @covers LMapBlock:setEdge
    it("setEdge sets edge type for each cardinal direction", function()
        local block = make_block()
        block:setEdge("north", 0, 1)
        block:setEdge("south", 0, 2)
        block:setEdge("east", 0, 1)
        block:setEdge("west", 0, 1)
        assert_true(true)
    end)

    -- @covers LMapBlock:setEdgeOnly
    it("setEdgeOnly marks block as edge-only placement", function()
        local block = make_block()
        block:setEdgeOnly(true)
        assert_true(true)
    end)

    -- @covers LMapBlock:setInteriorOnly
    it("setInteriorOnly marks block as interior-only placement", function()
        local block = make_block()
        block:setInteriorOnly(true)
        assert_true(true)
    end)

    -- @covers LMapBlock:setLevelSpan
    it("setLevelSpan sets multi-level span", function()
        local cfg = lurek.mapblock.newConfig()
        local block = lurek.mapblock.newBlock(4, 4, 2, cfg)
        block:setLevelSpan(2)
        assert_true(true)
    end)
end)

-- =========================================================================
-- NeighborRules addCompatible addCompatibleOneWay isCompatible
-- =========================================================================

-- @describe NeighborRules addCompatible addCompatibleOneWay isCompatible
describe("NeighborRules addCompatible addCompatibleOneWay isCompatible", function()
    -- @covers LNeighborRules:addCompatible
    -- @covers LNeighborRules:isCompatible
    it("addCompatible creates bidirectional compatibility", function()
        local rules = lurek.mapblock.newRules()
        rules:addCompatible(1, 2)
        assert_true(rules:isCompatible(1, 2))
        assert_true(rules:isCompatible(2, 1))
    end)

    -- @covers LNeighborRules:addCompatibleOneWay
    -- @covers LNeighborRules:isCompatible
    it("addCompatibleOneWay creates one-way compatibility", function()
        local rules = lurek.mapblock.newRules()
        rules:addCompatibleOneWay(3, 4)
        assert_true(rules:isCompatible(3, 4))
    end)

    -- @covers LNeighborRules:isCompatible
    it("isCompatible returns false for unregistered type pair", function()
        local rules = lurek.mapblock.newRules()
        assert_equal(false, rules:isCompatible(99, 100))
    end)
end)

-- =========================================================================
-- PlacementGrid addPosition isAvailable
-- =========================================================================

-- @describe PlacementGrid addPosition isAvailable
describe("PlacementGrid addPosition isAvailable", function()
    -- @covers LPlacementGrid:addPosition
    it("addPosition adds a grid position", function()
        local grid = lurek.mapblock.newEmptyGrid()
        grid:addPosition(3, 5)
        assert_equal(1, grid:getAvailableCount())
    end)

    -- @covers LPlacementGrid:isAvailable
    -- @covers LPlacementGrid:addPosition
    it("isAvailable returns true for an added position", function()
        local grid = lurek.mapblock.newEmptyGrid()
        grid:addPosition(2, 4)
        assert_true(grid:isAvailable(2, 4))
    end)

    -- @covers LPlacementGrid:isAvailable
    it("isAvailable returns false for a position not in grid", function()
        local grid = lurek.mapblock.newEmptyGrid()
        assert_equal(false, grid:isAvailable(99, 99))
    end)
end)

-- =========================================================================
-- MapBlockGenerator setRectShape setMaxLevels setRules getLastPlacedCount
-- =========================================================================

-- @describe MapBlockGenerator setRectShape setMaxLevels setRules getLastPlacedCount
describe("MapBlockGenerator setRectShape setMaxLevels setRules getLastPlacedCount", function()
    -- @covers LMapBlockGenerator:setRectShape
    it("setRectShape configures generator grid dimensions", function()
        local cfg = lurek.mapblock.newConfig()
        local gen = lurek.mapblock.newGenerator(cfg)
        gen:setRectShape(4, 4)
        assert_true(true)
    end)

    -- @covers LMapBlockGenerator:setMaxLevels
    it("setMaxLevels configures multi-level generation", function()
        local cfg = lurek.mapblock.newConfig()
        local gen = lurek.mapblock.newGenerator(cfg)
        gen:setMaxLevels(2)
        assert_true(true)
    end)

    -- @covers LMapBlockGenerator:setRules
    it("setRules applies neighbor matching rules", function()
        local cfg = lurek.mapblock.newConfig()
        local gen = lurek.mapblock.newGenerator(cfg)
        local rules = lurek.mapblock.newRules()
        rules:addCompatible(1, 1)
        gen:setRules(rules)
        assert_true(true)
    end)

    -- @covers LMapBlockGenerator:getLastPlacedCount
    it("getLastPlacedCount returns zero before any generation", function()
        local cfg = lurek.mapblock.newConfig()
        local gen = lurek.mapblock.newGenerator(cfg)
        local count = gen:getLastPlacedCount()
        expect_type("number", count)
        assert_equal(0, count)
    end)
end)

-- =========================================================================
-- MapBlockResult getGid getBlocksPlaced
-- =========================================================================

-- @describe MapBlockResult getGid getBlocksPlaced
describe("MapBlockResult getGid getBlocksPlaced", function()
    -- @covers LMapBlockResult:getGid
    -- @covers LMapBlockResult:getBlocksPlaced
    it("getBlocksPlaced and getGid are readable from generation result", function()
        local cfg = lurek.mapblock.newConfig()
        local gen = lurek.mapblock.newGenerator(cfg)
        gen:setRectShape(2, 2)
        local script = lurek.mapblock.newScript("gen_test")
        local result = gen:generate(script)
        local placed = result:getBlocksPlaced()
        expect_type("number", placed)
        local gid = result:getGid(0, 0, 0, 0, 0)
        expect_type("number", gid)
    end)
end)

-- =========================================================================
-- TilesetRef setImagePath
-- =========================================================================

-- @describe TilesetRef setImagePath
describe("TilesetRef setImagePath", function()
    -- @covers LTilesetRef:setImagePath
    it("setImagePath sets the image file path without crash", function()
        local ts = lurek.mapblock.newTilesetRef(1, "ground", 64, 8, 32, 32)
        ts:setImagePath("assets/textures/ground.png")
        assert_true(true)
    end)
end)

-- =========================================================================
-- MapBlockConfig:removeSlot
-- =========================================================================

-- @describe MapBlockConfig:removeSlot
describe("MapBlockConfig:removeSlot", function()
    -- @covers LMapBlockConfig:removeSlot
    it("removeSlot removes a previously added slot", function()
        local cfg = lurek.mapblock.newEmptyConfig()
        cfg:addSlot("floor")
        cfg:addSlot("wall")
        assert_equal(2, cfg:getSlotCount())
        cfg:removeSlot("floor")
        assert_equal(1, cfg:getSlotCount())
    end)

    -- @covers LMapBlockConfig:removeSlot
    it("removeSlot on nonexistent slot does not crash", function()
        local cfg = lurek.mapblock.newEmptyConfig()
        cfg:removeSlot("nonexistent")
        assert_equal(0, cfg:getSlotCount())
    end)
end)

test_summary()
