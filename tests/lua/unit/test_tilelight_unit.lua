-- Canonical unit coverage for lurek.tilelight.

local function new_field(width, height, levels)
    return lurek.tilefield.new({ width = width or 5, height = height or 5, levels = levels or 1 })
end

local function new_light(width, height, levels)
    return lurek.tilelight.new(new_field(width, height, levels))
end

-- @describe lurek.tilelight module functions
describe("lurek.tilelight module functions", function()
    -- @covers lurek.tilelight.new
    it("creates a tile light map from a tilefield", function()
        expect_equal("LTileLightMap", new_light(4, 3, 2):type())
    end)

    -- @covers lurek.tilelight.compute
    it("creates an ambient computed light map", function()
        local light = lurek.tilelight.compute(new_field(2, 2), {
            ambient = { r = 0.2, g = 0.2, b = 0.2 },
        })
        local _, _, _, luma = light:getLight(1, 1, 1)
        expect_true(luma > 0)
    end)
end)

-- @describe LTileLightMap methods
describe("LTileLightMap methods", function()
    -- @covers LTileLightMap:addPointLight
    it("adds a point light", function()
        local light = new_light()
        local id = light:addPointLight({ x = 2, y = 2, z = 1, radius = 2, intensity = 1 })
        expect_type("number", id)
    end)

    -- @covers LTileLightMap:updatePointLight
    it("updates a point light", function()
        local light = new_light()
        local id = light:addPointLight({ x = 1, y = 1, z = 1, radius = 2 })
        expect_no_error(function()
            light:updatePointLight(id, { x = 3, y = 3, radius = 3 })
        end)
    end)

    -- @covers LTileLightMap:removePointLight
    it("removes a point light", function()
        local light = new_light()
        local id = light:addPointLight({ x = 1, y = 1, z = 1, radius = 2 })
        expect_true(light:removePointLight(id))
    end)

    -- @covers LTileLightMap:clearPointLights
    it("clears point lights", function()
        local light = new_light()
        light:addPointLight({ x = 2, y = 2, z = 1, radius = 2 })
        light:clearPointLights()
        light:compute({ includePointLights = true, includeSunLight = false })
        local _, _, _, luma = light:getLight(2, 2, 1)
        expect_near(0.0, luma, 0.001)
    end)

    -- @covers LTileLightMap:addLineLight
    it("adds a line light", function()
        local light = new_light(6, 4)
        local id = light:addLineLight({ x1 = 1, y1 = 2, x2 = 6, y2 = 2, z1 = 1, z2 = 1, radius = 1.5 })
        expect_type("number", id)
    end)

    -- @covers LTileLightMap:updateLineLight
    it("updates a line light", function()
        local light = new_light(6, 4)
        local id = light:addLineLight({ x1 = 1, y1 = 2, x2 = 6, y2 = 2, z1 = 1, z2 = 1, radius = 1.5 })
        expect_no_error(function()
            light:updateLineLight(id, { x1 = 2, y1 = 2, x2 = 5, y2 = 2, radius = 2 })
        end)
    end)

    -- @covers LTileLightMap:removeLineLight
    it("removes a line light", function()
        local light = new_light(6, 4)
        local id = light:addLineLight({ x1 = 1, y1 = 2, x2 = 6, y2 = 2, z1 = 1, z2 = 1, radius = 1.5 })
        expect_true(light:removeLineLight(id))
    end)

    -- @covers LTileLightMap:clearLineLights
    it("clears line lights", function()
        local light = new_light(6, 4)
        light:addLineLight({ x1 = 1, y1 = 2, x2 = 6, y2 = 2, z1 = 1, z2 = 1, radius = 1.5 })
        light:clearLineLights()
        light:compute({ includeLineLights = true, includeSunLight = false })
        local _, _, _, luma = light:getLight(3, 2, 1)
        expect_near(0.0, luma, 0.001)
    end)

    -- @covers LTileLightMap:addAreaLight
    it("adds an area light", function()
        local light = new_light()
        local id = light:addAreaLight({ x = 2, y = 2, z = 1, width = 2, height = 2, radius = 2 })
        expect_type("number", id)
    end)

    -- @covers LTileLightMap:addRectLight
    it("adds a rect light alias", function()
        local light = new_light()
        local id = light:addRectLight({ x = 2, y = 2, z = 1, w = 2, h = 2, radius = 2 })
        expect_type("number", id)
    end)

    -- @covers LTileLightMap:updateAreaLight
    it("updates an area light", function()
        local light = new_light()
        local id = light:addAreaLight({ x = 2, y = 2, z = 1, width = 2, height = 2, radius = 2 })
        expect_no_error(function()
            light:updateAreaLight(id, { x = 3, y = 3, w = 1, h = 1 })
        end)
    end)

    -- @covers LTileLightMap:updateRectLight
    it("updates a rect light alias", function()
        local light = new_light()
        local id = light:addRectLight({ x = 2, y = 2, z = 1, w = 2, h = 2, radius = 2 })
        expect_no_error(function()
            light:updateRectLight(id, { x = 3, y = 3, w = 1, h = 1 })
        end)
    end)

    -- @covers LTileLightMap:removeAreaLight
    it("removes an area light", function()
        local light = new_light()
        local id = light:addAreaLight({ x = 2, y = 2, z = 1, width = 2, height = 2, radius = 2 })
        expect_true(light:removeAreaLight(id))
    end)

    -- @covers LTileLightMap:removeRectLight
    it("removes a rect light alias", function()
        local light = new_light()
        local id = light:addRectLight({ x = 2, y = 2, z = 1, w = 2, h = 2, radius = 2 })
        expect_true(light:removeRectLight(id))
    end)

    -- @covers LTileLightMap:clearAreaLights
    it("clears area lights", function()
        local light = new_light()
        light:addAreaLight({ x = 2, y = 2, z = 1, width = 2, height = 2, radius = 2 })
        light:clearAreaLights()
        light:compute({ includeAreaLights = true, includeSunLight = false })
        local _, _, _, luma = light:getLight(2, 2, 1)
        expect_near(0.0, luma, 0.001)
    end)

    -- @covers LTileLightMap:clearRectLights
    it("clears rect light alias", function()
        local light = new_light()
        light:addRectLight({ x = 2, y = 2, z = 1, w = 2, h = 2, radius = 2 })
        light:clearRectLights()
        light:compute({ includeAreaLights = true, includeSunLight = false })
        local _, _, _, luma = light:getLight(2, 2, 1)
        expect_near(0.0, luma, 0.001)
    end)

    -- @covers LTileLightMap:setAmbient
    it("sets ambient light", function()
        local light = new_light()
        light:setAmbient({ r = 0.1, g = 0.2, b = 0.3 })
        light:compute({ includePointLights = false, includeSunLight = false })
        local r, g, b = light:getLight(1, 1, 1)
        expect_true(r > 0 and g > 0 and b > 0)
    end)

    -- @covers LTileLightMap:setSunLight
    it("sets directional sun light", function()
        local field = new_field(4, 2)
        field:setCost(2, 1, 1, "light", 0.25)
        local light = lurek.tilelight.new(field)
        light:setSunLight({ kind = "directional", intensity = 0.8, direction = { x = 1, y = 0 } })
        light:compute({ includePointLights = false, includeSunLight = true })
        local _, _, _, lit = light:getLight(1, 1, 1)
        expect_true(lit > 0)
    end)

    -- @covers LTileLightMap:setGlobalLight
    it("sets legacy global top light", function()
        local field = new_field(2, 2, 2)
        field:setSunOcclusion(1, 1, 2, 0.25)
        local light = lurek.tilelight.new(field)
        light:setGlobalLight({ intensity = 0.4, color = { r = 1.0, g = 0.55, b = 0.25 } })
        light:compute({ includePointLights = false, includeGlobalLight = true })
        local _, _, _, lit = light:getLight(1, 1, 1)
        expect_true(lit > 0)
    end)

    -- @covers LTileLightMap:compute
    it("computes point light contribution", function()
        local light = new_light()
        light:addPointLight({ x = 2, y = 2, z = 1, radius = 3, intensity = 1 })
        light:compute({ includePointLights = true, includeSunLight = false })
        local _, _, _, luma = light:getLight(2, 2, 1)
        expect_true(luma > 0)
    end)

    -- @covers LTileLightMap:getLight
    it("returns cell light values", function()
        local light = new_light()
        light:setAmbient({ r = 0.1, g = 0.1, b = 0.1 })
        light:compute({ includeSunLight = false })
        local r, g, b, luma = light:getLight(1, 1, 1)
        expect_type("number", r)
        expect_type("number", g)
        expect_type("number", b)
        expect_type("number", luma)
    end)

    -- @covers LTileLightMap:exportLayer
    it("exports one computed layer", function()
        local light = new_light(2, 2)
        light:setAmbient({ r = 0.1, g = 0.1, b = 0.1 })
        light:compute({ includeSunLight = false })
        expect_equal(4, #light:exportLayer(1))
    end)

    -- @covers LTileLightMap:exportVolume
    it("exports all computed levels", function()
        local light = new_light(2, 2, 2)
        light:setAmbient({ r = 0.1, g = 0.1, b = 0.1 })
        light:compute({ includeSunLight = false })
        expect_equal(2, #light:exportVolume())
    end)

    -- @covers LTileLightMap:getSize
    it("returns light map size", function()
        local w, h, levels = new_light(4, 3, 2):getSize()
        expect_equal(4, w)
        expect_equal(3, h)
        expect_equal(2, levels)
    end)

    -- @covers LTileLightMap:type
    it("reports tile light type", function()
        expect_equal("LTileLightMap", new_light():type())
    end)

    -- @covers LTileLightMap:typeOf
    it("matches tile light type names", function()
        expect_true(new_light():typeOf("LTileLightMap"))
    end)
end)

test_summary()
