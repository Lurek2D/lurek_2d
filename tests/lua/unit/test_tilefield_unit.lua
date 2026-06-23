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
        local field = lurek.tilefield.fromTileMap(map, { layer = 1, solidGids = { 9 } })
        expect_true(field:blocks(2, 2, 1, "move"))
        expect_true(not field:blocks(1, 1, 1, "move"))
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
        field:setCell(2, 2, 1, { blocks = { move = true }, costs = { move = 4 }, sunOcclusion = 0.25 })
        expect_true(field:blocks(2, 2, 1, "move"))
        expect_near(4.0, field:getCost(2, 2, 1, "move"), 0.001)
        expect_near(0.25, field:getSunOcclusion(2, 2, 1), 0.001)
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

-- @describe LTileField profiles and lines
describe("LTileField profiles and lines", function()
    -- @covers LTileField:setProfile
    it("registers custom profile", function()
        local field = lurek.tilefield.new({ width = 4, height = 4 })
        field:setProfile("grate", { blocks = { move = true, vision = false }, sunOcclusion = 0.1 })
        field:applyProfile(2, 2, 1, "grate")
        expect_true(field:blocks(2, 2, 1, "move"))
        expect_true(not field:blocks(2, 2, 1, "vision"))
    end)

    -- @covers LTileField:applyProfile
    it("applies built-in window profile", function()
        local field = lurek.tilefield.new({ width = 4, height = 4 })
        field:applyProfile(2, 2, 1, "window")
        expect_true(field:blocks(2, 2, 1, "move"))
        expect_true(not field:blocks(2, 2, 1, "vision"))
        expect_true(field:blocks(2, 2, 1, "action"))
        expect_true(not field:blocks(2, 2, 1, "light"))
    end)

    -- @covers LTileField:getProfile
    it("returns profile details", function()
        local field = lurek.tilefield.new({ width = 4, height = 4 })
        local wall = field:getProfile("wall")
        expect_true(wall.blocks.move)
        expect_true(wall.blocks.vision)
    end)

    -- @covers LTileField:removeProfile
    it("removes custom profile", function()
        local field = lurek.tilefield.new({ width = 4, height = 4 })
        field:setProfile("tmp", { blocks = { move = true } })
        field:removeProfile("tmp")
        expect_nil(field:getProfile("tmp"))
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

-- @describe LTileField lighting and exports
describe("LTileField lighting and exports", function()
    -- @covers LTileField:addPointLight
    it("adds point light", function()
        local field = lurek.tilefield.new({ width = 5, height = 5 })
        local id = field:addPointLight({ x = 2, y = 2, z = 1, radius = 3, intensity = 1 })
        expect_type("number", id)
    end)

    -- @covers LTileField:updatePointLight
    it("updates point light", function()
        local field = lurek.tilefield.new({ width = 5, height = 5 })
        local id = field:addPointLight({ x = 1, y = 1, z = 1, radius = 2 })
        field:updatePointLight(id, { x = 3, y = 3, radius = 4, intensity = 0.5 })
        field:computeLight({ includePointLights = true })
        local _, _, _, luma = field:getLight(3, 3, 1)
        expect_true(luma > 0)
    end)

    -- @covers LTileField:removePointLight
    it("removes point light", function()
        local field = lurek.tilefield.new({ width = 5, height = 5 })
        local id = field:addPointLight({ x = 1, y = 1, z = 1, radius = 2 })
        expect_true(field:removePointLight(id))
    end)

    -- @covers LTileField:clearPointLights
    it("clears point lights", function()
        local field = lurek.tilefield.new({ width = 5, height = 5 })
        field:addPointLight({ x = 1, y = 1, z = 1, radius = 2 })
        field:clearPointLights()
        field:computeLight({ includePointLights = true })
        local _, _, _, luma = field:getLight(1, 1, 1)
        expect_near(0.0, luma, 0.001)
    end)

    -- @covers LTileField:setGlobalLight
    it("sets global light", function()
        local field = lurek.tilefield.new({ width = 2, height = 2, levels = 2 })
        field:setGlobalLight({ intensity = 0.5, color = { r = 1, g = 1, b = 1 } })
        field:computeLight({ includeGlobalLight = true })
        local _, _, _, luma = field:getLight(1, 1, 2)
        expect_true(luma > 0.4)
    end)

    -- @covers LTileField:computeLight
    it("computes colored point light with full and partial blockers", function()
        local blocked_field = lurek.tilefield.new({ width = 5, height = 3 })
        blocked_field:setBlock(3, 2, 1, "light", true)
        blocked_field:addPointLight({ x = 1, y = 2, z = 1, radius = 5, intensity = 1, color = { r = 1, g = 0.25, b = 0 } })
        blocked_field:computeLight({ includePointLights = true })
        local _, _, _, near = blocked_field:getLight(2, 2, 1)
        local _, _, _, blocked = blocked_field:getLight(5, 2, 1)
        expect_true(near > 0)
        expect_near(0.0, blocked, 0.001)

        local filter_field = lurek.tilefield.new({ width = 7, height = 3 })
        filter_field:setCost(4, 2, 1, "light", 0.5)
        filter_field:addPointLight({ x = 1, y = 2, z = 1, radius = 8, intensity = 1, color = { r = 1, g = 0.25, b = 0 } })
        filter_field:computeLight({ includePointLights = true })
        local r, g, b, filtered = filter_field:getLight(6, 2, 1)
        local _, _, _, before_filter = filter_field:getLight(3, 2, 1)
        expect_true(r > g and g > b, "warm light keeps its RGB color")
        expect_true(filtered > 0 and filtered < before_filter, "partial light cost attenuates light behind it")
    end)

    -- @covers LTileField:getLight
    it("returns rgb and luma", function()
        local field = lurek.tilefield.new({ width = 3, height = 3 })
        field:computeLight({ ambient = { r = 0.1, g = 0.1, b = 0.1 } })
        local r, g, b, luma = field:getLight(1, 1, 1)
        expect_true(r > 0 and g > 0 and b > 0 and luma > 0)
    end)

    -- @covers LTileField:exportLightLayer
    it("exports light layer", function()
        local field = lurek.tilefield.new({ width = 2, height = 2 })
        field:computeLight({ ambient = { r = 0.2, g = 0.2, b = 0.2 } })
        local layer = field:exportLightLayer(1)
        expect_equal(4, #layer)
        expect_true(layer[1].luma > 0)
    end)

    -- @covers LTileField:exportLightVolume
    it("exports light volume", function()
        local field = lurek.tilefield.new({ width = 2, height = 2, levels = 2 })
        field:computeLight({ ambient = { r = 0.1, g = 0.1, b = 0.1 } })
        local volume = field:exportLightVolume()
        expect_equal(2, #volume)
        expect_equal(4, #volume[1])
    end)

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

    -- @covers LTileField:exportProfileLayer
    it("exports profile layer", function()
        local field = lurek.tilefield.new({ width = 2, height = 2 })
        field:applyProfile(2, 1, 1, "window")
        local layer = field:exportProfileLayer(1)
        expect_equal("window", layer[2])
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
