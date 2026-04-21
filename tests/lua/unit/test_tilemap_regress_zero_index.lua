-- Regression: IsoMap:setTilePart / :getTilePart / :setLevelVisible must not
-- panic on 0-valued 1-based indices. Before the fix, the unsigned subtraction
-- at the binding boundary underflowed.

-- @description Covers suite: IsoMap regression — 0-index must return Lua error not panic.
describe("IsoMap regression: zero index", function()
    -- @covers lurek.tilemap.IsoMap.setTilePart
    it("setTilePart rejects z=0 without panicking", function()
        local iso = lurek.tilemap.newIsoMap(5, 5, 64, 32, 24)
        iso:addLevel()
        expect_error(function() iso:setTilePart(0, 1, 1, lurek.tilemap.FLOOR, 3) end)
        expect_error(function() iso:setTilePart(1, 0, 1, lurek.tilemap.FLOOR, 3) end)
        expect_error(function() iso:setTilePart(1, 1, 0, lurek.tilemap.FLOOR, 3) end)
    end)

    -- @covers lurek.tilemap.IsoMap.getTilePart
    it("getTilePart rejects z=0 without panicking", function()
        local iso = lurek.tilemap.newIsoMap(5, 5, 64, 32, 24)
        iso:addLevel()
        expect_error(function() iso:getTilePart(0, 1, 1, lurek.tilemap.FLOOR) end)
    end)

    -- @covers lurek.tilemap.IsoMap.setLevelVisible
    it("setLevelVisible rejects z=0 without panicking", function()
        local iso = lurek.tilemap.newIsoMap(5, 5, 64, 32, 24)
        iso:addLevel()
        expect_error(function() iso:setLevelVisible(0, true) end)
    end)
end)

test_summary()
