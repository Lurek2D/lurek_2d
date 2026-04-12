-- Lurek2D Window Scaling API Tests
-- Tests for lurek.window scale mode, game dimensions, and viewport info.
-- @covers lurek.window.getGameHeight
-- @covers lurek.window.getGameWidth
-- @covers lurek.window.getScaleInfo
-- @covers lurek.window.getScaleMode
-- @covers lurek.window.setScaleMode


-- @description Covers suite: lurek.window scaling API exists.
describe("lurek.window scaling API exists", function()
    -- @covers lurek.window.setScaleMode
    -- @description Verifies the scale-mode setter is exposed.
    it("setScaleMode is a function", function()
        expect_type("function", lurek.window.setScaleMode)
    end)

    -- @covers lurek.window.getScaleMode
    -- @description Verifies the scale-mode getter is exposed.
    it("getScaleMode is a function", function()
        expect_type("function", lurek.window.getScaleMode)
    end)

    -- @covers lurek.window.getScaleInfo
    -- @description Verifies the aggregate scale-info query is exposed.
    it("getScaleInfo is a function", function()
        expect_type("function", lurek.window.getScaleInfo)
    end)

    -- @covers lurek.window.getGameWidth
    -- @description Verifies the logical game-width getter is exposed.
    it("getGameWidth is a function", function()
        expect_type("function", lurek.window.getGameWidth)
    end)

    -- @covers lurek.window.getGameHeight
    -- @description Verifies the logical game-height getter is exposed.
    it("getGameHeight is a function", function()
        expect_type("function", lurek.window.getGameHeight)
    end)
end)

-- @description Covers suite: lurek.window.getScaleMode defaults.
describe("lurek.window.getScaleMode defaults", function()
    -- @covers lurek.window.getScaleMode
    -- @description Verifies getScaleMode returns a string enum value.
    it("returns a string", function()
        local mode = lurek.window.getScaleMode()
        expect_type("string", mode)
    end)

    -- @covers lurek.window.getScaleMode
    -- @description Verifies the default headless scale mode is none.
    it("default scale mode is none", function()
        local mode = lurek.window.getScaleMode()
        expect_equal("none", mode)
    end)
end)

-- @description Covers suite: lurek.window.setScaleMode.
describe("lurek.window.setScaleMode", function()
    -- @covers lurek.window.setScaleMode
    -- @description Verifies setScaleMode accepts the letterbox mode without error.
    it("accepts letterbox mode", function()
        expect_no_error(function()
            lurek.window.setScaleMode("letterbox")
        end)
    end)

    -- @covers lurek.window.setScaleMode
    -- @description Verifies setScaleMode accepts the stretch mode without error.
    it("accepts stretch mode", function()
        expect_no_error(function()
            lurek.window.setScaleMode("stretch")
        end)
    end)

    -- @covers lurek.window.setScaleMode
    -- @description Verifies setScaleMode accepts the pixel-perfect mode without error.
    it("accepts pixel mode", function()
        expect_no_error(function()
            lurek.window.setScaleMode("pixel")
        end)
    end)

    -- @covers lurek.window.setScaleMode
    -- @description Verifies setScaleMode accepts the none mode without error.
    it("accepts none mode", function()
        expect_no_error(function()
            lurek.window.setScaleMode("none")
        end)
    end)

    -- @covers lurek.window.setScaleMode
    -- @description Verifies invalid scale modes are ignored and leave the previous mode unchanged.
    it("silently ignores an invalid mode without error", function()
        -- Mode before invalid call
        local before = lurek.window.getScaleMode()
        -- This should not throw
        expect_no_error(function()
            lurek.window.setScaleMode("invalid_mode")
        end)
        -- Mode must remain unchanged
        local after = lurek.window.getScaleMode()
        expect_equal(before, after)
    end)

    -- @covers lurek.window.setScaleMode
    -- @description Verifies an empty scale-mode string is ignored without mutating the current mode.
    it("silently ignores an empty string without error", function()
        local before = lurek.window.getScaleMode()
        expect_no_error(function()
            lurek.window.setScaleMode("")
        end)
        local after = lurek.window.getScaleMode()
        expect_equal(before, after)
    end)
end)

-- @description Covers suite: lurek.window.getGameWidth.
describe("lurek.window.getGameWidth", function()
    -- @covers lurek.window.getGameWidth
    -- @description Verifies getGameWidth returns a numeric logical width.
    it("returns a number", function()
        local w = lurek.window.getGameWidth()
        expect_type("number", w)
    end)

    -- @covers lurek.window.getGameWidth
    -- @description Verifies the logical game width stays positive.
    it("returns a positive value", function()
        local w = lurek.window.getGameWidth()
        expect_true(w > 0, "game_width must be positive, got " .. tostring(w))
    end)
end)

-- @description Covers suite: lurek.window.getGameHeight.
describe("lurek.window.getGameHeight", function()
    -- @covers lurek.window.getGameHeight
    -- @description Verifies getGameHeight returns a numeric logical height.
    it("returns a number", function()
        local h = lurek.window.getGameHeight()
        expect_type("number", h)
    end)

    -- @covers lurek.window.getGameHeight
    -- @description Verifies the logical game height stays positive.
    it("returns a positive value", function()
        local h = lurek.window.getGameHeight()
        expect_true(h > 0, "game_height must be positive, got " .. tostring(h))
    end)
end)

-- @description Covers suite: lurek.window.getScaleInfo.
describe("lurek.window.getScaleInfo", function()
    -- @covers lurek.window.getScaleInfo
    -- @description Verifies getScaleInfo returns a table payload.
    it("returns a table", function()
        local info = lurek.window.getScaleInfo()
        expect_type("table", info)
    end)

    -- @covers lurek.window.getScaleInfo
    -- @description Verifies the scale info table includes scale_x.
    it("table contains scale_x field", function()
        local info = lurek.window.getScaleInfo()
        expect_not_nil(info.scale_x)
    end)

    -- @covers lurek.window.getScaleInfo
    -- @description Verifies the scale info table includes scale_y.
    it("table contains scale_y field", function()
        local info = lurek.window.getScaleInfo()
        expect_not_nil(info.scale_y)
    end)

    -- @covers lurek.window.getScaleInfo
    -- @description Verifies the scale info table includes offset_x.
    it("table contains offset_x field", function()
        local info = lurek.window.getScaleInfo()
        expect_not_nil(info.offset_x)
    end)

    -- @covers lurek.window.getScaleInfo
    -- @description Verifies the scale info table includes offset_y.
    it("table contains offset_y field", function()
        local info = lurek.window.getScaleInfo()
        expect_not_nil(info.offset_y)
    end)

    -- @covers lurek.window.getScaleInfo
    -- @description Verifies the scale info table includes game_width.
    it("table contains game_width field", function()
        local info = lurek.window.getScaleInfo()
        expect_not_nil(info.game_width)
    end)

    -- @covers lurek.window.getScaleInfo
    -- @description Verifies the scale info table includes game_height.
    it("table contains game_height field", function()
        local info = lurek.window.getScaleInfo()
        expect_not_nil(info.game_height)
    end)

    -- @covers lurek.window.getScaleInfo
    -- @description Verifies scale_x is numeric.
    it("scale_x is a number", function()
        local info = lurek.window.getScaleInfo()
        expect_type("number", info.scale_x)
    end)

    -- @covers lurek.window.getScaleInfo
    -- @description Verifies scale_y is numeric.
    it("scale_y is a number", function()
        local info = lurek.window.getScaleInfo()
        expect_type("number", info.scale_y)
    end)

    -- @covers lurek.window.getScaleInfo
    -- @description Verifies offset_x is numeric.
    it("offset_x is a number", function()
        local info = lurek.window.getScaleInfo()
        expect_type("number", info.offset_x)
    end)

    -- @covers lurek.window.getScaleInfo
    -- @description Verifies offset_y is numeric.
    it("offset_y is a number", function()
        local info = lurek.window.getScaleInfo()
        expect_type("number", info.offset_y)
    end)

    -- @covers lurek.window.getScaleInfo
    -- @covers lurek.window.getGameWidth
    -- @description Verifies scale info echoes the same logical width reported by getGameWidth.
    it("game_width matches getGameWidth()", function()
        local info = lurek.window.getScaleInfo()
        local w = lurek.window.getGameWidth()
        expect_near(w, info.game_width, 0.001)
    end)

    -- @covers lurek.window.getScaleInfo
    -- @covers lurek.window.getGameHeight
    -- @description Verifies scale info echoes the same logical height reported by getGameHeight.
    it("game_height matches getGameHeight()", function()
        local info = lurek.window.getScaleInfo()
        local h = lurek.window.getGameHeight()
        expect_near(h, info.game_height, 0.001)
    end)

    -- @covers lurek.window.getScaleInfo
    -- @description Verifies scale_x stays at 1.0 when the active scale mode is none.
    it("default scale_x is 1.0 with none mode", function()
        local info = lurek.window.getScaleInfo()
        -- In headless test VM, scale mode is "none" so scale should be 1.0
        if lurek.window.getScaleMode() == "none" then
            expect_near(1.0, info.scale_x, 0.001)
        end
    end)

    -- @covers lurek.window.getScaleInfo
    -- @description Verifies scale_y stays at 1.0 when the active scale mode is none.
    it("default scale_y is 1.0 with none mode", function()
        local info = lurek.window.getScaleInfo()
        if lurek.window.getScaleMode() == "none" then
            expect_near(1.0, info.scale_y, 0.001)
        end
    end)
end)

test_summary()
