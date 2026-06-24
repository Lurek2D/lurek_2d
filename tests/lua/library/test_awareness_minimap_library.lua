-- Lurek2D Library Visibility Minimap Tests
-- @testCategory library

local AwarenessMinimap = require("library.awareness_minimap")

local function build_visibility()
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 1 })
    field:setBlock(4, 2, 1, "vision", true)
    field:setBlock(4, 3, 1, "action", true)

    local visibility = lurek.awareness.newTileAwareness(field, { players = { "p1" }, rememberExplored = true })
    visibility:computeVisible("p1", {
        origin = { x = 2, y = 2, z = 1 },
        range = 1,
        channel = "vision",
    })
    visibility:computeAction("p1", {
        origin = { x = 2, y = 2, z = 1 },
        range = 2,
        channel = "action",
    })
    return visibility
end

-- @describe awareness_minimap library
describe("awareness_minimap library", function()
    -- @library lurek.library_awareness_minimap
    it("syncs visible and explored cells into minimap fog data", function()
        local helper = AwarenessMinimap.new({ visibility = build_visibility(), width = 5, height = 4 })
        local data = helper:syncFog("p1")

        expect_equal(2, data[(2 - 1) * 5 + 2], "origin should be visible")
        expect_equal(0, data[(4 - 1) * 5 + 5], "far corner should stay hidden")

        local mm = helper:getMinimap()
        expect_true(mm:isFogEnabled(), "adapter should enable minimap fog by default")
        expect_equal(2, mm:getFogLevel(2, 2))
    end)

    -- @library lurek.library_awareness_minimap
    it("syncs visible cells into a styled raw layer", function()
        local helper = AwarenessMinimap.new({ visibility = build_visibility(), width = 5, height = 4 })
        local data = helper:syncVisibleLayer("p1", 1, {
            visible_value = 9,
            style = {
                visible = true,
                alpha = 0.75,
                blend = "replace",
                colors = {
                    [9] = { 0.1, 0.8, 0.25, 1.0 },
                },
            },
        })

        expect_equal(9, data[(2 - 1) * 5 + 2])
        local mm = helper:getMinimap()
        expect_true(mm:isLayerVisible(1))
        expect_equal("replace", mm:getLayerBlendMode(1))
        local r = select(1, mm:getLayerColor(1, 9))
        expect_near(0.1, r)
    end)

    -- @library lurek.library_awareness_minimap
    it("syncs actionable cells into a raw layer", function()
        local helper = AwarenessMinimap.new({ visibility = build_visibility(), width = 5, height = 4 })
        local data = helper:syncActionLayer("p1", 2, {
            action_value = 6,
            style = { visible = true, alpha = 0.5, blend = "add" },
        })

        expect_equal(6, data[(2 - 1) * 5 + 2], "origin should be actionable")
        expect_true(helper:getMinimap():isLayerVisible(2))
        expect_equal("add", helper:getMinimap():getLayerBlendMode(2))
    end)
end)
test_summary()
