-- Lurek2D Library Tilefield Minimap Tests
-- @testCategory library

local TilefieldMinimap = require("library.tilefield_minimap")

local function build_field()
    local field = lurek.tilefield.new({ width = 3, height = 2, levels = 1 })
    field:setBlock(2, 1, 1, "move", true)
    field:setCost(3, 2, 1, "move", 4)
    local light = lurek.tilelight.new(field)
    light:addPointLight({ x = 2, y = 1, z = 1, radius = 2, intensity = 1.0 })
    light:compute({ includePointLights = true, includeGlobalLight = false })
    return field, light
end

-- @describe tilefield_minimap library
describe("tilefield_minimap library", function()
    -- @library lurek.library_tilefield_minimap
    it("syncs blocker exports into minimap layer data", function()
        local field, light = build_field()
        local helper = TilefieldMinimap.new({ field = field, lightMap = light, width = 3, height = 2 })
        local data = helper:syncBlockLayer("move", 1, {
            blocked_value = 9,
            style = {
                visible = true,
                alpha = 0.8,
                blend = "replace",
                colors = {
                    [9] = { 1.0, 0.1, 0.1, 1.0 },
                },
            },
        })

        expect_equal(9, data[2], "blocked tile should map to configured byte")
        expect_equal(0, data[1], "open tile should remain zero")

        local mm = helper:getMinimap()
        local layer = mm:getLayerData(1)
        expect_equal(9, layer[2])
        expect_true(mm:isLayerVisible(1), "adapter should apply minimap layer visibility")
        expect_equal("replace", mm:getLayerBlendMode(1))
        local r = select(1, mm:getLayerColor(1, 9))
        expect_near(1.0, r)
    end)

    -- @library lurek.library_tilefield_minimap
    it("syncs cost exports into scaled minimap bytes", function()
        local field, light = build_field()
        local helper = TilefieldMinimap.new({ field = field, lightMap = light, width = 3, height = 2 })
        local data = helper:syncCostLayer("move", 2, {
            scale = 2,
            style = { visible = true, alpha = 0.5, blend = "add" },
        })

        expect_equal(8, data[6], "cost layer should scale numeric tilefield cost")
        local mm = helper:getMinimap()
        expect_true(mm:isLayerVisible(2))
        expect_near(0.5, mm:getLayerAlpha(2))
    end)

    -- @library lurek.library_tilefield_minimap
    it("syncs computed light luma into minimap layer bytes", function()
        local field, light = build_field()
        local helper = TilefieldMinimap.new({ field = field, lightMap = light, width = 3, height = 2 })
        local data = helper:syncLightLayer(3, {
            scale = 9,
            style = { visible = true, alpha = 0.7, blend = "add" },
        })

        expect_true(data[2] > 0, "light source cell should produce a visible byte")
        expect_equal("add", helper:getMinimap():getLayerBlendMode(3))
    end)
end)
test_summary()
