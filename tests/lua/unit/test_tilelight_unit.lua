-- Canonical unit coverage for lurek.tilelight.

-- @describe lurek.tilelight module functions
describe("lurek.tilelight module functions", function()
    -- @covers lurek.tilelight.new
    it("creates a tile light map from a tilefield", function()
        local field = lurek.tilefield.new({ width = 4, height = 3, levels = 2 })
        local light = lurek.tilelight.new(field)
        expect_equal("LTileLightMap", light:type())
        expect_true(light:typeOf("LTileLightMap"))
    end)

    -- @covers lurek.tilelight.compute
    it("creates an ambient computed light map", function()
        local field = lurek.tilefield.new({ width = 2, height = 2 })
        local light = lurek.tilelight.compute(field, { ambient = { r = 0.2, g = 0.2, b = 0.2 } })
        local _, _, _, luma = light:getLight(1, 1, 1)
        expect_true(luma > 0)
    end)
end)

-- @describe LTileLightMap methods
describe("LTileLightMap methods", function()
    -- @covers LTileLightMap:addPointLight
    -- @covers LTileLightMap:compute
    -- @covers LTileLightMap:getLight
    it("computes point light through tilefield light blockers", function()
        local field = lurek.tilefield.new({ width = 5, height = 3 })
        field:setBlock(3, 2, 1, "light", true)
        local light = lurek.tilelight.new(field)
        light:addPointLight({ x = 1, y = 2, z = 1, radius = 5, intensity = 1 })
        light:compute({ includePointLights = true, includeGlobalLight = false })
        local _, _, _, near = light:getLight(2, 2, 1)
        local _, _, _, blocked = light:getLight(5, 2, 1)
        expect_true(near > 0)
        expect_near(0.0, blocked, 0.001)
    end)

    -- @covers LTileLightMap:setGlobalLight
    -- @covers LTileLightMap:exportLayer
    -- @covers LTileLightMap:exportVolume
    it("computes and exports global top light", function()
        local field = lurek.tilefield.new({ width = 2, height = 2, levels = 2 })
        field:setSunOcclusion(1, 1, 2, 0.5)
        local light = lurek.tilelight.new(field)
        light:setGlobalLight({ intensity = 1, color = { r = 1, g = 1, b = 1 } })
        light:compute({ includePointLights = false, includeGlobalLight = true })
        local layer = light:exportLayer(1)
        local volume = light:exportVolume()
        expect_equal(4, #layer)
        expect_equal(2, #volume)
        expect_true(layer[1].luma > 0)
    end)

    -- @covers LTileLightMap:updatePointLight
    -- @covers LTileLightMap:removePointLight
    -- @covers LTileLightMap:clearPointLights
    it("updates and clears point lights", function()
        local field = lurek.tilefield.new({ width = 4, height = 4 })
        local light = lurek.tilelight.new(field)
        local id = light:addPointLight({ x = 1, y = 1, z = 1, radius = 2 })
        light:updatePointLight(id, { x = 3, y = 3, radius = 3 })
        expect_true(light:removePointLight(id))
        light:addPointLight({ x = 2, y = 2, z = 1, radius = 2 })
        light:clearPointLights()
        light:compute({ includePointLights = true })
        local _, _, _, luma = light:getLight(2, 2, 1)
        expect_near(0.0, luma, 0.001)
    end)

    -- @covers LTileLightMap:addLineLight
    -- @covers LTileLightMap:removeLineLight
    -- @covers LTileLightMap:clearLineLights
    it("computes tile line lights", function()
        local field = lurek.tilefield.new({ width = 6, height = 4 })
        local light = lurek.tilelight.new(field)
        local id = light:addLineLight({ x1 = 1, y1 = 2, x2 = 6, y2 = 2, z1 = 1, z2 = 1, radius = 1.5, intensity = 1.0, color = { r = 0, g = 1, b = 0 } })
        light:compute({ includePointLights = false, includeLineLights = true, includeSunLight = false })
        local _, g, _, luma = light:getLight(3, 2, 1)
        expect_true(g > 0)
        expect_true(luma > 0)
        expect_true(light:removeLineLight(id))
        light:clearLineLights()
    end)

    -- @covers LTileLightMap:setAmbient
    -- @covers LTileLightMap:setSunLight
    it("computes ambient and directional sun", function()
        local field = lurek.tilefield.new({ width = 4, height = 2 })
        field:setCost(2, 1, 1, "light", 0.25)
        local light = lurek.tilelight.new(field)
        light:setAmbient({ r = 0.1, g = 0.0, b = 0.0 })
        light:setSunLight({ kind = "directional", intensity = 0.8, color = { r = 1, g = 1, b = 1 }, direction = { x = 1, y = 0 } })
        light:compute({ includePointLights = false, includeLineLights = false, includeSunLight = true })
        local _, _, _, lit = light:getLight(1, 1, 1)
        local _, _, _, filtered = light:getLight(4, 1, 1)
        expect_true(lit > filtered)
    end)

    -- @covers LTileLightMap:updatePointLight
    it("applies flicker and color cycle over compute time", function()
        local field = lurek.tilefield.new({ width = 3, height = 3 })
        local light = lurek.tilelight.new(field)
        local id = light:addPointLight({
            x = 2, y = 2, z = 1, radius = 2, intensity = 0.5,
            flicker = { amplitude = 0.5, frequency = 1.0 },
            colorCycle = {
                from = { r = 1, g = 0, b = 0 },
                to = { r = 0, g = 0, b = 1 },
                frequency = 1.0,
            },
        })
        light:compute({ includePointLights = true, includeSunLight = false, time = 0.0 })
        local r1, _, b1 = light:getLight(2, 2, 1)
        light:compute({ includePointLights = true, includeSunLight = false, time = 0.25 })
        local r2, _, b2 = light:getLight(2, 2, 1)
        expect_true(math.abs(r1 - r2) > 0.01 or math.abs(b1 - b2) > 0.01)
        light:updatePointLight(id, { flicker = { amplitude = 0.0, frequency = 0.0 } })
    end)
end)

test_summary()
