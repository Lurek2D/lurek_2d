-- Integration: authored tilefield refs become bounded light-world render previews.

local function fixture()
    local tileset = lurek.tileset.fromProvider({
        firstGid = 20,
        tileCount = 1,
        columns = 1,
        tileWidth = 16,
        tileHeight = 16,
        objects = {
            torch = {
                renderLight = { radius = 24, intensity = 1.5, shadowEnabled = true },
                occluder = { shape = "rect", opacity = 1.0 },
            },
        },
        tileObjects = { [1] = "torch" },
    })
    local field = lurek.tilefield.new({ width = 2, height = 1 })
    field:setRef(1, 1, 1, "tiles", 20)
    return field, tileset
end

-- @describe tilefield + light render-preview bridge
describe("tilefield + light render-preview bridge", function()
    -- @integration lurek.tilefield.new
    -- @integration LTileField:setRef
    -- @integration lurek.tileset.fromProvider
    -- @integration lurek.light.createLightsFromTilefield
    -- @integration lurek.light.drawToImage
    -- @integration LImageData:getWidth
    -- @integration lurek.light.clear
    -- @integration lurek.light.getLightCount
    -- @integration lurek.light.setEnabled
    it("materializes authored objects into the canonical light world before preview rendering", function()
        lurek.light.clear()
        lurek.light.setEnabled(true)
        local field, tileset = fixture()
        local result = lurek.light.createLightsFromTilefield(field, "tiles", tileset, { refIsGid = true })
        expect_equal(1, #result.lights)
        expect_equal(1, #result.occluders)
        expect_equal(1, lurek.light.getLightCount())
        local preview = lurek.light.drawToImage(32, 32)
        expect_equal(32, preview:getWidth())
    end)

    -- @integration lurek.tilefield.createLightsFromTileset
    -- @integration lurek.light.createLightsFromTilefield
    -- @integration lurek.light.clear
    -- @integration lurek.light.setEnabled
    it("keeps the tilefield alias behaviorally equivalent to the canonical facade", function()
        lurek.light.clear()
        lurek.light.setEnabled(true)
        local field, tileset = fixture()
        local canonical = lurek.light.createLightsFromTilefield(field, "tiles", tileset, { refIsGid = true })
        expect_equal(1, #canonical.lights)
        lurek.light.clear()
        local alias = lurek.tilefield.createLightsFromTileset(field, "tiles", tileset, { refIsGid = true })
        expect_equal(1, #alias.lights)
        expect_equal(1, #alias.occluders)
    end)
end)

test_summary()
