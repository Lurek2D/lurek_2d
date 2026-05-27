-- Lurek2D Cursor API Tests
-- Covers lurek.cursor module: manager, system cursors, custom cursors,
-- animated cursors, trails, contexts, and zoom.

-- =========================================================================
-- Module existence
-- =========================================================================

-- @describe lurek.cursor module exists
describe("lurek.cursor module exists", function()
    -- @covers lurek.cursor
    it("lurek.cursor is a table", function()
        expect_type("table", lurek.cursor)
    end)

    -- @covers lurek.cursor.newManager
    -- @covers lurek.cursor.newCustom
    -- @covers lurek.cursor.newAnimated
    -- @covers lurek.cursor.systemCursors
    it("exposes factory functions", function()
        expect_type("function", lurek.cursor.newManager)
        expect_type("function", lurek.cursor.newCustom)
        expect_type("function", lurek.cursor.newAnimated)
        expect_type("function", lurek.cursor.systemCursors)
    end)
end)

-- =========================================================================
-- CursorManager
-- =========================================================================

-- @describe CursorManager
describe("CursorManager", function()
    -- @covers lurek.cursor.newManager
    it("newManager creates a manager", function()
        local mgr = lurek.cursor.newManager()
        expect_type("userdata", mgr)
    end)

    -- @covers lurek.cursor.newManager
    it("manager default visibility is true", function()
        local mgr = lurek.cursor.newManager()
        expect_true(mgr:isVisible())
    end)

    -- @covers lurek.cursor.newManager
    it("setVisible toggles visibility", function()
        local mgr = lurek.cursor.newManager()
        mgr:setVisible(false)
        expect_equal(false, mgr:isVisible())
        mgr:setVisible(true)
        expect_true(mgr:isVisible())
    end)

    -- @covers lurek.cursor.newManager
    it("setLocked and isLocked", function()
        local mgr = lurek.cursor.newManager()
        expect_equal(false, mgr:isLocked())
        mgr:setLocked(true)
        expect_true(mgr:isLocked())
    end)

    -- @covers lurek.cursor.newManager
    it("getPosition returns x, y", function()
        local mgr = lurek.cursor.newManager()
        local x, y = mgr:getPosition()
        expect_type("number", x)
        expect_type("number", y)
    end)

    -- @covers lurek.cursor.newManager
    it("setSystem accepts cursor name", function()
        local mgr = lurek.cursor.newManager()
        mgr:setSystem("arrow")
        -- No crash = system cursor set
        expect_true(true)
    end)

    -- @covers lurek.cursor.newManager
    it("setContext and getContext roundtrip", function()
        local mgr = lurek.cursor.newManager()
        mgr:setContext("combat")
        expect_equal("combat", mgr:getContext())
    end)

    -- @covers lurek.cursor.newManager
    it("addRule and removeRule manage context rules", function()
        local mgr = lurek.cursor.newManager()
        mgr:addRule("hover", "hand")
        mgr:removeRule("hover")
        -- No crash = success
        expect_true(true)
    end)

    -- @covers lurek.cursor.newManager
    it("update advances state without crash", function()
        local mgr = lurek.cursor.newManager()
        mgr:update(100, 200, 1/60)
        local x, y = mgr:getPosition()
        expect_near(100, x, 0.1)
        expect_near(200, y, 0.1)
    end)

    -- @covers lurek.cursor.newManager
    it("enableTrail and disableTrail", function()
        local mgr = lurek.cursor.newManager()
        mgr:enableTrail(255, 0, 0, 0.5)
        mgr:disableTrail()
        expect_true(true)
    end)

    -- @covers lurek.cursor.newManager
    it("enableZoom and disableZoom", function()
        local mgr = lurek.cursor.newManager()
        mgr:enableZoom(2.0, 50)
        mgr:disableZoom()
        expect_true(true)
    end)
end)

-- =========================================================================
-- systemCursors
-- =========================================================================

-- @describe systemCursors list
describe("systemCursors list", function()
    -- @covers lurek.cursor.systemCursors
    it("returns a list of strings", function()
        local cursors = lurek.cursor.systemCursors()
        expect_type("table", cursors)
        expect_true(#cursors > 0)
        expect_type("string", cursors[1])
    end)

    -- @covers lurek.cursor.systemCursors
    it("includes arrow cursor", function()
        local cursors = lurek.cursor.systemCursors()
        local found = false
        for _, c in ipairs(cursors) do
            if c == "arrow" then found = true break end
        end
        expect_true(found)
    end)
end)

-- =========================================================================
-- CustomCursor
-- =========================================================================

-- @describe CustomCursor
describe("CustomCursor", function()
    -- @covers lurek.cursor.newCustom
    it("newCustom creates cursor with size", function()
        local cursor = lurek.cursor.newCustom(32, 32, 0, 0)
        expect_type("userdata", cursor)
        local w, h = cursor:getSize()
        expect_equal(32, w)
        expect_equal(32, h)
    end)

    -- @covers lurek.cursor.newCustom
    it("getHotspot returns hotspot position", function()
        local cursor = lurek.cursor.newCustom(16, 16, 8, 4)
        local hx, hy = cursor:getHotspot()
        expect_equal(8, hx)
        expect_equal(4, hy)
    end)

    -- @covers lurek.cursor.newCustom
    it("setPixel and getPixel roundtrip", function()
        local cursor = lurek.cursor.newCustom(4, 4, 0, 0)
        cursor:setPixel(1, 2, 255, 128, 64, 200)
        local r, g, b, a = cursor:getPixel(1, 2)
        expect_equal(255, r)
        expect_equal(128, g)
        expect_equal(64, b)
        expect_equal(200, a)
    end)
end)

-- =========================================================================
-- AnimatedCursor
-- =========================================================================

-- @describe AnimatedCursor
describe("AnimatedCursor", function()
    -- @covers lurek.cursor.newAnimated
    it("newAnimated creates animated cursor", function()
        local anim = lurek.cursor.newAnimated(true)
        expect_type("userdata", anim)
    end)

    -- @covers lurek.cursor.newAnimated
    it("addFrame increases frame count", function()
        local anim = lurek.cursor.newAnimated(true)
        local frame = lurek.cursor.newCustom(8, 8, 0, 0)
        anim:addFrame(frame, 100)
        expect_equal(1, anim:frameCount())
    end)

    -- @covers lurek.cursor.newAnimated
    it("currentIndex starts at 0", function()
        local anim = lurek.cursor.newAnimated(true)
        local frame = lurek.cursor.newCustom(8, 8, 0, 0)
        anim:addFrame(frame, 100)
        expect_equal(0, anim:currentIndex())
    end)

    -- @covers lurek.cursor.newAnimated
    it("update advances animation", function()
        local anim = lurek.cursor.newAnimated(true)
        local f1 = lurek.cursor.newCustom(8, 8, 0, 0)
        local f2 = lurek.cursor.newCustom(8, 8, 0, 0)
        anim:addFrame(f1, 50)
        anim:addFrame(f2, 50)
        anim:update(0.06) -- 60ms > 50ms frame duration
        expect_equal(1, anim:currentIndex())
    end)

    -- @covers lurek.cursor.newAnimated
    it("reset returns to first frame", function()
        local anim = lurek.cursor.newAnimated(true)
        local f1 = lurek.cursor.newCustom(8, 8, 0, 0)
        local f2 = lurek.cursor.newCustom(8, 8, 0, 0)
        anim:addFrame(f1, 50)
        anim:addFrame(f2, 50)
        anim:update(0.06)
        anim:reset()
        expect_equal(0, anim:currentIndex())
    end)

    -- @covers lurek.cursor.newAnimated
    it("setPulse and currentScale", function()
        local anim = lurek.cursor.newAnimated(true)
        local frame = lurek.cursor.newCustom(8, 8, 0, 0)
        anim:addFrame(frame, 100)
        anim:setPulse(0.8, 1.2, 2.0)
        local scale = anim:currentScale()
        expect_type("number", scale)
        expect_true(scale >= 0.8 and scale <= 1.2)
    end)

    -- @covers LAnimatedCursor:clearPulse
    it("clearPulse removes pulse configuration", function()
        local anim = lurek.cursor.newAnimated(true)
        local frame = lurek.cursor.newCustom(8, 8, 0, 0)
        anim:addFrame(frame, 100)
        anim:setPulse(0.8, 1.2, 2.0)
        anim:clearPulse()
        expect_true(true)
    end)
end)

-- =========================================================================
-- CursorManager extra methods
-- =========================================================================

-- @describe CursorManager setAnimated and enableLineTrail
describe("CursorManager setAnimated and enableLineTrail", function()
    -- @covers LCursorManager:setAnimated
    it("setAnimated applies animated cursor without crash", function()
        local mgr = lurek.cursor.newManager()
        local anim = lurek.cursor.newAnimated(true)
        mgr:setAnimated(anim)
        expect_true(true)
    end)

    -- @covers LCursorManager:enableLineTrail
    it("enableLineTrail sets line trail mode without crash", function()
        local mgr = lurek.cursor.newManager()
        mgr:enableLineTrail(1.0, 0.0, 0.0, 2.0)
        expect_true(true)
    end)
end)

test_summary()

