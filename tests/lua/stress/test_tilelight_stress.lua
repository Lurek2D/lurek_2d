-- Bounded tilelight stress coverage for source shapes, sun propagation, edits, and exports.

local function make_field(width, height, levels)
    return lurek.tilefield.new({ width = width, height = height, levels = levels or 1 })
end

local function build_point_map(width, height, count)
    local map = lurek.tilelight.new(make_field(width, height, 1))
    for i = 1, count do
        map:addPointLight({
            x = (i - 1) % width + 1,
            y = math.floor((i - 1) / width) + 1,
            radius = 4,
            intensity = 0.5,
        })
    end
    return map
end

local function compute_point_map()
    local map = build_point_map(32, 32, 64)
    map:compute({ includeLineLights = false, includeAreaLights = false, includeSunLight = false })
    return map
end

local function compute_line_map()
    local map = lurek.tilelight.new(make_field(64, 32, 1))
    map:addLineLight({ x1 = 1, y1 = 16, x2 = 64, y2 = 16, radius = 3, intensity = 0.6 })
    map:compute({ includePointLights = false, includeAreaLights = false, includeSunLight = false })
    return map
end

local function compute_area_map()
    local map = lurek.tilelight.new(make_field(64, 32, 1))
    map:addAreaLight({ x = 20, y = 8, width = 16, height = 8, radius = 4, intensity = 0.6 })
    map:compute({ includePointLights = false, includeLineLights = false, includeSunLight = false })
    return map
end

local function compute_sun_map()
    local map = lurek.tilelight.new(make_field(40, 40, 4))
    map:setSunLight({ intensity = 0.7, color = { r = 1, g = 0.9, b = 0.7 } })
    map:compute({ includePointLights = false, includeLineLights = false, includeAreaLights = false })
    return map
end

local function export_edited_maps()
    local field = make_field(16, 16, 2)
    local map = lurek.tilelight.new(field)
    for i = 1, 12 do
        field:setSunOcclusion((i - 1) % 16 + 1, 1, 1, 0.25)
        map:compute({ includePointLights = false, includeLineLights = false, includeAreaLights = false })
        expect_equal(2, #map:exportVolume())
    end
end

-- @describe tilelight bounded point source stress
describe("tilelight bounded point source stress", function()
    -- @stress LTileLightMap:addPointLight
    it("adds many bounded point sources", function()
        local count = 256
        local start = os.clock()
        build_point_map(32, 32, count)
        expect_true(os.clock() - start < 5.0)
    end)

    -- @stress LTileLightMap:compute
    it("computes bounded point sources", function()
        local start = os.clock()
        compute_point_map()
        expect_true(os.clock() - start < 5.0)
    end)
end)

-- @describe tilelight shaped source stress
describe("tilelight shaped source stress", function()
    -- @stress LTileLightMap:addLineLight
    it("computes long bounded lines", function()
        local map = compute_line_map()
        expect_true(map:getLight(32, 16, 1) > 0)
    end)

    -- @stress LTileLightMap:addAreaLight
    it("computes bounded rectangular areas", function()
        local map = compute_area_map()
        local _, _, _, luma = map:getLight(28, 12, 1)
        expect_true(luma > 0)
    end)
end)

-- @describe tilelight multilevel and incremental stress
describe("tilelight multilevel and incremental stress", function()
    -- @stress LTileLightMap:setSunLight
    it("computes multilevel top sun within the work ceiling", function()
        local start = os.clock()
        compute_sun_map()
        expect_true(os.clock() - start < 5.0)
    end)

    -- @stress LTileLightMap:exportVolume
    it("exports repeated recomputed volumes after bounded edits", function()
        export_edited_maps()
    end)
end)

test_summary()
