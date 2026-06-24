-- Canonical unit coverage for lurek.tilefield.

-- @describe lurek.tilefield module functions
describe("lurek.tilefield module functions", function()
    -- @covers lurek.tilefield.new
    it("creates a multi-level field", function()
        local field = lurek.tilefield.new({ width = 6, height = 5, levels = 2, topology = "square" })
        expect_type("userdata", field)
        expect_equal("LTileField", field:type())
    end)

    -- @covers lurek.tilefield.fromTileMap
    it("copies solid gids from tilemap into a field", function()
        local map = lurek.tilemap.newTileMap(16, 16)
        map:addLayer("ground", 3, 3)
        map:setTile(1, 2, 2, 9)
        local field = lurek.tilefield.fromTileMap(map, { layer = 1, levels = 2, level = 2, solidGids = { 9 } })
        expect_true(field:blocks(2, 2, 2, "move"))
        expect_true(not field:blocks(2, 2, 1, "move"))
        expect_true(not field:blocks(1, 1, 1, "move"))
    end)

    -- @covers lurek.tilefield.newFieldMap
    it("creates a layered map of shared fields", function()
        local map = lurek.tilefield.newFieldMap({
            width = 2,
            height = 3,
            layers = 2,
            fieldWidth = 4,
            fieldHeight = 5,
            fieldLevels = 1,
            topology = "square4",
        })
        expect_equal("LTileFieldMap", map:type())
        expect_true(map:typeOf("LTileFieldMap"))
    end)
end)

-- @describe LTileFieldMap methods
describe("LTileFieldMap methods", function()
    -- @covers LTileFieldMap:inBounds
    it("checks map slot bounds", function()
        local map = lurek.tilefield.newFieldMap({ width = 2, height = 2, layers = 2, fieldWidth = 3, fieldHeight = 3 })
        expect_true(map:inBounds(2, 2, 2))
        expect_true(not map:inBounds(3, 1, 1))
    end)

    -- @covers LTileFieldMap:getField
    it("returns shared fields from map slots", function()
        local map = lurek.tilefield.newFieldMap({ width = 2, height = 2, layers = 2, fieldWidth = 3, fieldHeight = 3 })
        local field = map:getField(2, 2, 2)
        field:setRef(1, 1, 1, "floor", 44)
        expect_equal(44, map:getField(2, 2, 2):getRef(1, 1, 1, "floor"))
    end)

    -- @covers LTileFieldMap:setField
    it("stores compatible external fields", function()
        local map = lurek.tilefield.newFieldMap({ width = 1, height = 1, layers = 1, fieldWidth = 3, fieldHeight = 3, topology = "square8" })
        local field = lurek.tilefield.new({ width = 3, height = 3, topology = "square8" })
        field:setRef(2, 2, 1, "object", 90)
        map:setField(1, 1, 1, field)
        expect_equal(90, map:getField(1, 1, 1):getRef(2, 2, 1, "object"))
    end)
end)

-- @describe LTileField cell state
describe("LTileField cell state", function()
    -- @covers LTileField:getSize
    it("returns width height and levels", function()
        local field = lurek.tilefield.new({ width = 7, height = 8, levels = 3 })
        local w, h, levels = field:getSize()
        expect_equal(7, w)
        expect_equal(8, h)
        expect_equal(3, levels)
    end)

    -- @covers LTileField:getTopology
    it("returns topology", function()
        local field = lurek.tilefield.new({ width = 4, height = 4, topology = "iso_square" })
        expect_equal("iso_square", field:getTopology())
    end)

    -- @covers LTileField:inBounds
    it("checks one-based bounds", function()
        local field = lurek.tilefield.new({ width = 2, height = 2, levels = 2 })
        expect_true(field:inBounds(2, 2, 2))
        expect_true(not field:inBounds(3, 2, 1))
    end)

    -- @covers LTileField:setRegionCells
    it("stores named regions from explicit tile cells", function()
        local field = lurek.tilefield.new({ width = 5, height = 5, levels = 2 })
        field:setRegionCells("stairs", {
            { x = 2, y = 2, z = 1 },
            { x = 2, y = 2, z = 1 },
            { x = 2, y = 3, z = 2 },
        })
        expect_equal(2, #field:getRegionCells("stairs"))
        expect_true(field:regionContains("stairs", 2, 3, 2))
    end)

    -- @covers LTileField:clear
    it("clears all cells", function()
        local field = lurek.tilefield.new({ width = 3, height = 3 })
        field:setBlock(2, 2, 1, "move", true)
        field:clear()
        expect_true(not field:blocks(2, 2, 1, "move"))
    end)

    -- @covers LTileField:clearCell
    it("clears one cell", function()
        local field = lurek.tilefield.new({ width = 3, height = 3 })
        field:setBlock(2, 2, 1, "vision", true)
        field:clearCell(2, 2, 1)
        expect_true(not field:blocks(2, 2, 1, "vision"))
    end)

    -- @covers LTileField:getCell
    it("returns cell table", function()
        local field = lurek.tilefield.new({ width = 3, height = 3 })
        field:setBlock(2, 2, 1, "action", true)
        local cell = field:getCell(2, 2, 1)
        expect_true(cell.blocks.action)
    end)

    -- @covers LTileField:setCell
    it("sets cell table", function()
        local field = lurek.tilefield.new({ width = 3, height = 3 })
        field:setCell(2, 2, 1, {
            blocks = { move = true },
            costs = { move = 4 },
            sunOcclusion = 0.25,
            refs = { floor = 7 },
        })
        expect_true(field:blocks(2, 2, 1, "move"))
        expect_near(4.0, field:getCost(2, 2, 1, "move"), 0.001)
        expect_near(0.25, field:getSunOcclusion(2, 2, 1), 0.001)
        expect_equal(7, field:getCell(2, 2, 1).refs.floor)
    end)

    -- @covers LTileField:setBlock
    it("sets channel blockers independently", function()
        local field = lurek.tilefield.new({ width = 3, height = 3 })
        field:setBlock(2, 2, 1, "vision", true)
        expect_true(field:blocks(2, 2, 1, "vision"))
        expect_true(not field:blocks(2, 2, 1, "action"))
    end)

    -- @covers LTileField:blocks
    it("returns blocker state", function()
        local field = lurek.tilefield.new({ width = 3, height = 3 })
        field:setBlock(1, 1, 1, "light", true)
        expect_true(field:blocks(1, 1, 1, "light"))
    end)

    -- @covers LTileField:setCost
    it("sets channel cost", function()
        local field = lurek.tilefield.new({ width = 3, height = 3 })
        field:setCost(1, 2, 1, "move", 3.5)
        expect_near(3.5, field:getCost(1, 2, 1, "move"), 0.001)
    end)

    -- @covers LTileField:getCost
    it("returns default cost", function()
        local field = lurek.tilefield.new({ width = 3, height = 3 })
        expect_near(1.0, field:getCost(1, 1, 1, "move"), 0.001)
    end)

    -- @covers LTileField:setSunOcclusion
    it("sets sun occlusion", function()
        local field = lurek.tilefield.new({ width = 3, height = 3 })
        field:setSunOcclusion(1, 1, 1, 0.75)
        expect_near(0.75, field:getSunOcclusion(1, 1, 1), 0.001)
    end)

    -- @covers LTileField:getSunOcclusion
    it("returns default sun occlusion", function()
        local field = lurek.tilefield.new({ width = 3, height = 3 })
        expect_near(0.0, field:getSunOcclusion(1, 1, 1), 0.001)
    end)
end)

-- @describe LTileField categories and lines
describe("LTileField categories and lines", function()
    -- @covers LTileField:setCategoryBlock
    it("registers custom category blocker", function()
        local field = lurek.tilefield.new({ width = 4, height = 4 })
        field:defineCategory("grate_move", { kind = "movement" })
        field:setCategoryBlock(2, 2, 1, "grate_move", true)
        field:setSunOcclusion(2, 2, 1, 0.1)
        expect_true(field:blocksCategory(2, 2, 1, "grate_move"))
        expect_near(0.1, field:getSunOcclusion(2, 2, 1), 0.001)
    end)

    -- @covers LTileField:getCategory
    it("returns category details", function()
        local field = lurek.tilefield.new({ width = 4, height = 4 })
        field:defineCategory("wall_move", { kind = "movement", active = true })
        local wall = field:getCategory("wall_move")
        expect_equal("movement", wall.kind)
        expect_true(wall.active)
    end)

    -- @covers LTileField:clearModifier
    it("removes applied modifier", function()
        local field = lurek.tilefield.new({ width = 4, height = 4 })
        field:setModifier("tmp", { blocks = { move = true } })
        field:applyModifier(2, 2, 1, "tmp")
        expect_true(field:blocks(2, 2, 1, "move"))
        expect_true(field:clearModifier(2, 2, 1, "tmp"))
        expect_true(not field:blocks(2, 2, 1, "move"))
    end)

    -- @covers LTileField:line
    it("returns square line cells", function()
        local field = lurek.tilefield.new({ width = 5, height = 5 })
        local cells = field:line({ from = { x = 1, y = 1, z = 1 }, to = { x = 4, y = 1, z = 1 } })
        expect_equal(4, #cells)
        expect_equal(4, cells[#cells].x)
    end)

    -- @covers LTileField:clearLine
    it("uses selected blocker channel for clear line", function()
        local field = lurek.tilefield.new({ width = 5, height = 5 })
        field:setBlock(3, 1, 1, "vision", true)
        expect_true(not field:clearLine({ x = 1, y = 1, z = 1 }, { x = 5, y = 1, z = 1 }, "vision"))
        expect_true(field:clearLine({ x = 1, y = 1, z = 1 }, { x = 5, y = 1, z = 1 }, "action"))
    end)

    -- @covers LTileField:firstBlocker
    it("returns first blocker cell", function()
        local field = lurek.tilefield.new({ width = 5, height = 5 })
        field:setBlock(3, 1, 1, "action", true)
        local blocker = field:firstBlocker({ x = 1, y = 1, z = 1 }, { x = 5, y = 1, z = 1 }, "action")
        expect_equal(3, blocker.x)
    end)
end)

-- @describe LTileLightMap lighting and LTileField exports
describe("LTileLightMap lighting and LTileField exports", function()
    -- @covers LTileField:exportBlockLayer
    it("exports block layer", function()
        local field = lurek.tilefield.new({ width = 2, height = 2 })
        field:setBlock(2, 1, 1, "move", true)
        local layer = field:exportBlockLayer("move", 1)
        expect_equal(4, #layer)
        expect_true(layer[2])
    end)

    -- @covers LTileField:exportCostLayer
    it("exports cost layer", function()
        local field = lurek.tilefield.new({ width = 2, height = 2 })
        field:setCost(2, 1, 1, "move", 5)
        local layer = field:exportCostLayer("move", 1)
        expect_equal(5, layer[2])
    end)

    -- @covers LTileField:getCategories
    it("exports category registry names", function()
        local field = lurek.tilefield.new({ width = 2, height = 2 })
        field:defineCategory("window_move", { kind = "movement" })
        local names = field:getCategories()
        expect_true(#names >= 1)
    end)

    -- @covers LTileField:type
    it("returns type name", function()
        local field = lurek.tilefield.new({ width = 2, height = 2 })
        expect_equal("LTileField", field:type())
    end)

    -- @covers LTileField:typeOf
    it("checks type name", function()
        local field = lurek.tilefield.new({ width = 2, height = 2 })
        expect_true(field:typeOf("LTileField"))
        expect_true(field:typeOf("LObject"))
    end)
end)

test_summary()
