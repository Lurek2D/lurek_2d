-- Adversarial coverage for bounded tilelight storage, source input, and stale output.

local function field(opts)
    return lurek.tilefield.new(opts or { width = 8, height = 8, levels = 1 })
end

local function light(opts)
    return lurek.tilelight.new(field(opts))
end

local function fill_point_sources(map, count)
    for i = 1, count do
        map:addPointLight({ x = 1, y = 1, radius = 1, intensity = 0 })
    end
end

local function assert_point_source_limit(map)
    expect_error(function()
        map:addPointLight({ x = 1, y = 1, radius = 1, intensity = 0 })
    end)
end

local function stale_light_map()
    local source_field = field()
    local map = lurek.tilelight.new(source_field)
    map:compute({ includeSunLight = false })
    source_field:setBlock(1, 1, 1, "light", true)
    return map
end

-- @describe tilelight hostile numeric inputs
describe("tilelight hostile numeric inputs", function()
    -- @security LTileLightMap:addPointLight
    it("rejects non-finite point source values", function()
        local map = light()
        expect_error(function()
            map:addPointLight({ x = 1, y = 1, radius = math.huge, intensity = 1 })
        end)
        expect_error(function()
            map:addPointLight({ x = 1, y = 1, radius = 2, intensity = 0 / 0 })
        end)
        expect_error(function()
            map:addPointLight({ x = 1, y = 1, radius = 2, color = { r = 0 / 0, g = 0, b = 0 } })
        end)
        expect_error(function()
            map:addPointLight({ x = 1, y = 1, radius = 2, color = field() })
        end)
    end)

    -- @security LTileLightMap:addLineLight
    it("rejects hostile line and modulation values", function()
        local map = light()
        expect_error(function()
            map:addLineLight({ x1 = 1, y1 = 1, x2 = 8, y2 = 1, radius = 1, flicker = { frequency = math.huge } })
        end)
        expect_error(function()
            map:addLineLight({ x1 = 1, y1 = 1, x2 = 8, y2 = 1, radius = 1, colorCycle = {
                from = { r = 1, g = 0, b = 0 }, to = { r = 0 / 0, g = 1, b = 0 },
            } })
        end)
    end)

    -- @security LTileLightMap:addAreaLight
    it("rejects oversized area shapes", function()
        local map = light()
        expect_error(function()
            map:addAreaLight({ x = 1, y = 1, width = 1000000, height = 2, radius = 1 })
        end)
        expect_error(function()
            map:addAreaLight({ x = 1, y = 1, width = 2, height = 2, radius = math.huge })
        end)
    end)

    -- @security LTileLightMap:setAmbient
    it("rejects non-finite ambient values", function()
        local map = light()
        expect_error(function()
            map:setAmbient({ r = 0, g = math.huge, b = 0 })
        end)
    end)

    -- @security LTileLightMap:setSunLight
    it("rejects non-finite sun values", function()
        local map = light()
        expect_error(function()
            map:setSunLight({ intensity = 0 / 0 })
        end)
    end)

    -- @security LTileLightMap:compute
    it("rejects non-finite compute time", function()
        local map = light()
        expect_error(function()
            map:compute({ time = 0 / 0 })
        end)
        expect_error(function()
            map:compute({ timeSeconds = math.huge })
        end)
    end)
end)

-- @describe tilelight hostile sizes and handles
describe("tilelight hostile sizes and handles", function()
    -- @security lurek.tilelight.new
    it("rejects an oversized dense field", function()
        expect_error(function()
            lurek.tilelight.new(field({ width = 4096, height = 4096, levels = 2 }))
        end)
    end)

    -- @security LTileLightMap:removePointLight
    it("bounds active source churn", function()
        local map = light({ width = 2, height = 2, levels = 1 })
        fill_point_sources(map, 4096)
        assert_point_source_limit(map)
        for i = 1, 4096 do
            map:removePointLight(i)
        end
    end)

    -- @security LTileLightMap:updatePointLight
    it("rejects invalid and stale source ids", function()
        local map = light()
        expect_error(function()
            map:updatePointLight(999999, { radius = 2 })
        end)
        expect_error(function()
            map:updatePointLight(0, { radius = 2 })
        end)
    end)

    -- @security LTileLightMap:getLight
    it("rejects stale field output", function()
        local map = stale_light_map()
        expect_error(function()
            map:getLight(1, 1, 1)
        end)
    end)

    -- @security LTileLightMap:exportLayer
    it("bounds export levels", function()
        local map = light({ width = 2, height = 2, levels = 1 })
        map:compute({ includeSunLight = false })
        expect_error(function()
            map:exportLayer(2)
        end)
    end)
end)

test_summary()
