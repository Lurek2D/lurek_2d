-- Integration: tilefield channel semantics feed visibility and action masks.

-- @describe integration: tilefield feeds visibility
describe("integration: tilefield feeds visibility", function()
    -- @integration lurek.tilefield.new
    -- @integration LTileField:applyProfile
    -- @integration lurek.visibility.lineOfSight
    -- @integration lurek.visibility.lineOfAction
    -- @integration lurek.visibility.newTileVisibility
    -- @integration LTileVisibility:computeVisible
    -- @integration LTileVisibility:computeAction
    -- @integration LTileVisibility:isVisible
    -- @integration LTileVisibility:canActOn
    it("window is visible through but not actionable through", function()
        local field = lurek.tilefield.new({ width = 5, height = 3 })
        field:applyProfile(3, 2, 1, "window")

        local from = { x = 1, y = 2, z = 1 }
        local to = { x = 5, y = 2, z = 1 }
        expect_true(lurek.visibility.lineOfSight(field, from, to))
        expect_true(not lurek.visibility.lineOfAction(field, from, to))

        local vis = lurek.visibility.newTileVisibility(field, { players = { "alpha", "beta" } })
        vis:computeVisible("alpha", { origin = from, range = 5 })
        vis:computeAction("alpha", { origin = from, range = 5 })

        expect_true(vis:isVisible("alpha", 5, 2, 1))
        expect_true(not vis:canActOn("alpha", 5, 2, 1))
        expect_true(not vis:isVisible("beta", 5, 2, 1))
    end)
end)

test_summary()
