-- Canonical unit coverage for lurek.cursor.

local function new_manager()
    local manager = lurek.cursor.newManager()
    manager:setSystem("arrow")
    manager:setContext("default")
    manager:setVisible(true)
    manager:setLocked(false)
    manager:disableTrail()
    manager:disableZoom()
    return manager
end

local function new_custom()
    return lurek.cursor.newCustom(8, 6, 2, 1)
end

local function new_animated()
    return lurek.cursor.newAnimated(true)
end

local function new_frame()
    return lurek.cursor.newCustom(4, 4, 0, 0)
end

-- @describe lurek.cursor module
describe("lurek.cursor module", function()
    -- @covers lurek.cursor.newManager
    it("newManager returns userdata handles for one shared runtime cursor", function()
        local a = new_manager()
        local b = new_manager()
        expect_equal("userdata", type(a))
        a:setContext("shared_handle_ctx")
        expect_equal("shared_handle_ctx", b:getContext())
    end)

    -- @covers lurek.cursor.newCustom
    it("newCustom creates a custom cursor image", function()
        expect_equal("userdata", type(new_custom()))
    end)

    -- @covers lurek.cursor.newAnimated
    it("newAnimated creates an animated cursor", function()
        expect_equal("userdata", type(new_animated()))
    end)

    -- @covers lurek.cursor.systemCursors
    it("systemCursors returns known cursor names", function()
        local names = lurek.cursor.systemCursors()
        expect_true(#names > 0)
        expect_equal("arrow", names[1])
        expect_true(#names >= 12)
    end)
end)

-- @describe cursor manager methods
describe("cursor manager methods", function()
    -- @covers LCursorManager:setSystem
    it("setSystem accepts known names and rejects unknown ones", function()
        local manager = new_manager()
        expect_no_error(function()
            manager:setSystem("hand")
        end)
        expect_error(function()
            manager:setSystem("missing_cursor_name")
        end)
    end)

    -- @covers LCursorManager:setCustom
    it("setCustom accepts a custom cursor object", function()
        local manager = new_manager()
        expect_no_error(function()
            manager:setCustom(new_custom())
        end)
    end)

    -- @covers LCursorManager:setAnimated
    it("setAnimated accepts an animated cursor object", function()
        local manager = new_manager()
        local animated = new_animated()
        animated:addFrame(new_frame(), 16)
        expect_no_error(function()
            manager:setAnimated(animated)
        end)
    end)

    -- @covers LCursorManager:setContext
    it("setContext changes the active context string", function()
        local manager = new_manager()
        manager:setContext("ctx_set_context")
        expect_equal("ctx_set_context", manager:getContext())
    end)

    -- @covers LCursorManager:addRule
    it("addRule registers both legacy and table-driven cursor rules", function()
        local manager = new_manager()
        expect_no_error(function()
            manager:addRule("ctx_add_rule", "hand")
        end)
        manager:defineState("inspect", { system = "crosshair" })
        local id = manager:addRule({
            priority = 25,
            event = "context",
            context = "ctx_v2_rule",
            state = "inspect",
        })
        expect_type("number", id)
        expect_true(id >= 1)
    end)

    -- @covers LCursorManager:update
    it("update stores the latest cursor position", function()
        local manager = new_manager()
        manager:update(12.5, 18.75, 0.016)
        local x, y = manager:getPosition()
        expect_near(12.5, x, 0.0001)
        expect_near(18.75, y, 0.0001)
    end)

    -- @covers LCursorManager:setVisible
    it("setVisible toggles cursor visibility", function()
        local manager = new_manager()
        manager:setVisible(false)
        expect_false(manager:isVisible())
    end)

    -- @covers LCursorManager:isVisible
    it("isVisible returns true by default", function()
        expect_true(new_manager():isVisible())
    end)

    -- @covers LCursorManager:setLocked
    it("setLocked toggles the locked state", function()
        local manager = new_manager()
        manager:setLocked(true)
        expect_true(manager:isLocked())
    end)

    -- @covers LCursorManager:isLocked
    it("isLocked returns false by default", function()
        expect_false(new_manager():isLocked())
    end)

    -- @covers LCursorManager:getPosition
    it("getPosition returns x and y numbers", function()
        local x, y = new_manager():getPosition()
        expect_type("number", x)
        expect_type("number", y)
    end)

    -- @covers LCursorManager:getContext
    it("getContext defaults to default", function()
        expect_equal("default", new_manager():getContext())
    end)

    -- @covers LCursorManager:enableTrail
    it("enableTrail configures a fade point trail", function()
        local manager = new_manager()
        expect_no_error(function()
            manager:enableTrail(1.0, 0.2, 0.3, 0.5)
        end)
    end)

    -- @covers LCursorManager:enableLineTrail
    it("enableLineTrail configures a line trail", function()
        local manager = new_manager()
        expect_no_error(function()
            manager:enableLineTrail(0.1, 0.2, 0.9, 3.0)
        end)
    end)

    -- @covers LCursorManager:disableTrail
    it("disableTrail clears an active trail", function()
        local manager = new_manager()
        manager:enableTrail(1.0, 1.0, 1.0, 0.5)
        expect_no_error(function()
            manager:disableTrail()
        end)
    end)

    -- @covers LCursorManager:enableZoom
    it("enableZoom configures cursor magnification", function()
        local manager = new_manager()
        expect_no_error(function()
            manager:enableZoom(2.0, 64.0)
        end)
    end)

    -- @covers LCursorManager:disableZoom
    it("disableZoom clears zoom state", function()
        local manager = new_manager()
        manager:enableZoom(2.0, 64.0)
        expect_no_error(function()
            manager:disableZoom()
        end)
    end)

    -- @covers LCursorManager:defineState
    it("defineState accepts named system and custom cursor states", function()
        local manager = new_manager()
        expect_no_error(function()
            manager:defineState("inspect", {
                system = "crosshair",
                scale = 1.25,
                offset_x = 2,
                offset_y = -1,
                trail = {
                    mode = "ribbon",
                    width = 6,
                    lifetime = 0.4,
                },
                zoom = {
                    magnification = 2.5,
                    radius = 48,
                },
            })
            manager:defineState("paint", {
                custom = new_custom(),
                native_preferred = false,
            })
        end)
    end)

    -- @covers LCursorManager:defineEffect
    it("defineEffect accepts particle burst presets", function()
        local manager = new_manager()
        expect_no_error(function()
            manager:defineEffect("click_burst", {
                shape = "ring",
                count = 10,
                spread = math.pi,
                lifetime = 0.2,
                speed = 90,
                size = 6,
                button = 0,
            })
        end)
    end)

    -- @covers LCursorManager:addSource
    it("addSource accepts callback sources and removeSource detaches them", function()
        local manager = new_manager()
        local id = manager:addSource({
            kind = "callback",
            callback = function(x, y)
                return {
                    module = "test",
                    kind = "hover",
                    surface = "surface",
                    id = string.format("%.0f:%.0f", x, y),
                }
            end,
        })
        expect_type("number", id)
        expect_true(manager:removeSource(id))
        expect_false(manager:removeSource(id))
    end)

    -- @covers LCursorManager:getLastHit
    it("getLastHit returns nil when no hover source has produced a hit yet", function()
        expect_equal(nil, new_manager():getLastHit())
    end)

    -- @covers LCursorManager:getActiveState
    it("getActiveState reports the resolved runtime cursor kind", function()
        local manager = new_manager()
        manager:setSystem("hand")
        local state = manager:getActiveState()
        expect_equal("system", state.kind)
        expect_type("boolean", state.native_preferred)
        expect_type("number", state.scale)
    end)

    -- @covers LCursorManager:removeSource
    it("removeSource returns false when the source id is unknown", function()
        expect_false(new_manager():removeSource(999999))
    end)

    -- @covers LCursorManager:removeRule
    it("removeRule clears a registered context rule and falls back cleanly", function()
        local manager = new_manager()
        manager:addRule("ctx_remove_rule", "hand")
        expect_no_error(function()
            manager:removeRule("ctx_remove_rule")
        end)
        manager:setSystem("hand")
        manager:addRule("ctx_remove_rule", "crosshair")
        manager:setContext("ctx_remove_rule")
        manager:removeRule("ctx_remove_rule")
        manager:setContext("default")
        expect_equal("default", manager:getContext())
        expect_no_error(function()
            manager:setSystem("hand")
        end)
    end)

    -- @covers LCursorManager:type
    it("type returns the cursor manager userdata name", function()
        local manager = new_manager()
        expect_equal("LCursorManager", manager:type())
        expect_true(manager:isVisible())
    end)
end)

-- @describe custom cursor methods
describe("custom cursor methods", function()
    -- @covers LCustomCursor:setPixel
    it("setPixel stores one rgba pixel value", function()
        local cursor = new_custom()
        cursor:setPixel(1, 2, 10, 20, 30, 40)
        local r, g, b, a = cursor:getPixel(1, 2)
        expect_equal(10, r)
        expect_equal(20, g)
        expect_equal(30, b)
        expect_equal(40, a)
    end)

    -- @covers LCustomCursor:getPixel
    it("getPixel errors when the coordinate is out of bounds", function()
        local cursor = new_custom()
        expect_error(function()
            cursor:getPixel(99, 99)
        end)
    end)

    -- @covers LCustomCursor:getSize
    it("getSize returns the configured dimensions", function()
        local cursor = new_custom()
        local w, h = cursor:getSize()
        expect_equal(8, w)
        expect_equal(6, h)
    end)

    -- @covers LCustomCursor:getHotspot
    it("getHotspot returns the configured hotspot", function()
        local hx, hy = new_custom():getHotspot()
        expect_equal(2, hx)
        expect_equal(1, hy)
    end)
end)

-- @describe animated cursor methods
describe("animated cursor methods", function()
    -- @covers LAnimatedCursor:addFrame
    it("addFrame appends cursor frames", function()
        local animated = new_animated()
        animated:addFrame(new_frame(), 10)
        expect_equal(1, animated:frameCount())
    end)

    -- @covers LAnimatedCursor:update
    it("update advances the frame index using frame durations", function()
        local animated = new_animated()
        animated:addFrame(new_frame(), 10)
        animated:addFrame(new_frame(), 10)
        animated:update(0.015)
        expect_equal(1, animated:currentIndex())
    end)

    -- @covers LAnimatedCursor:currentIndex
    it("currentIndex starts at zero", function()
        expect_equal(0, new_animated():currentIndex())
    end)

    -- @covers LAnimatedCursor:frameCount
    it("frameCount reflects the number of inserted frames", function()
        local animated = new_animated()
        animated:addFrame(new_frame(), 16)
        animated:addFrame(new_frame(), 16)
        expect_equal(2, animated:frameCount())
    end)

    -- @covers LAnimatedCursor:currentScale
    it("currentScale returns a numeric scale factor", function()
        expect_type("number", new_animated():currentScale())
    end)

    -- @covers LAnimatedCursor:setPulse
    it("setPulse keeps the animated cursor readable after updates", function()
        local animated = new_animated()
        animated:addFrame(new_frame(), 16)
        animated:setPulse(0.8, 1.2, 4.0)
        animated:update(0.1)
        expect_true(animated:currentScale() > 0.0)
    end)

    -- @covers LAnimatedCursor:clearPulse
    it("clearPulse removes pulse configuration without error", function()
        local animated = new_animated()
        animated:setPulse(0.8, 1.2, 4.0)
        expect_no_error(function()
            animated:clearPulse()
        end)
    end)

    -- @covers LAnimatedCursor:reset
    it("reset returns playback to the first frame", function()
        local animated = new_animated()
        animated:addFrame(new_frame(), 10)
        animated:addFrame(new_frame(), 10)
        animated:update(0.02)
        animated:reset()
        expect_equal(0, animated:currentIndex())
    end)
end)

test_summary()
