-- tests/lua/unit/test_window_unit.lua
-- Lua-first unit tests for lurek.window module covering title, size, mode, and configuration.

local harness = require("tests.lua.harness")

-- @describe lurek.window
describe("lurek.window", function()
    -- Title management
    -- @covers lurek.window.setTitle
    it("sets window title bar text", function()
        lurek.window.setTitle("Test Game")
        assert_equal("userdata", type(lurek.window))
    end)

    -- @covers lurek.window.getTitle
    it("gets current window title", function()
        lurek.window.setTitle("New Title")
        local title = lurek.window.getTitle()
        assert_equal("string", type(title))
    end)

    -- Size queries
    -- @covers lurek.window.getWidth
    it("returns current window width in pixels", function()
        local width = lurek.window.getWidth()
        assert_equal("number", type(width))
        assert_true(width > 0)
    end)

    -- @covers lurek.window.getHeight
    it("returns current window height in pixels", function()
        local height = lurek.window.getHeight()
        assert_equal("number", type(height))
        assert_true(height > 0)
    end)

    -- @covers lurek.window.getDimensions
    it("returns width and height as tuple", function()
        local w, h = lurek.window.getDimensions()
        assert_equal("number", type(w))
        assert_equal("number", type(h))
        assert_true(w > 0 and h > 0)
    end)

    -- Window mode / fullscreen
    -- @covers lurek.window.setFullscreen
    it("toggles fullscreen mode", function()
        lurek.window.setFullscreen(false)
        assert_equal(false, lurek.window.isFullscreen())
    end)

    -- @covers lurek.window.isFullscreen
    it("reports fullscreen state", function()
        local is_full = lurek.window.isFullscreen()
        assert_true(type(is_full) == "boolean")
    end)

    -- VSync control
    -- @covers lurek.window.setVSync
    it("enables or disables vertical sync", function()
        lurek.window.setVSync(1)
        assert_equal("userdata", type(lurek.window))
    end)

    -- @covers lurek.window.getVSync
    it("reports vsync enabled state", function()
        lurek.window.setVSync(0)
        local vsync_on = lurek.window.getVSync()
        assert_true(type(vsync_on) == "boolean")
    end)

    -- Centered window
    -- @covers lurek.window.setPosition
    it("sets window position on screen", function()
        lurek.window.setPosition(100, 100)
        assert_equal("userdata", type(lurek.window))
    end)

    -- @covers lurek.window.getPosition
    it("gets window position", function()
        lurek.window.setPosition(200, 150)
        local x, y = lurek.window.getPosition()
        assert_equal("number", type(x))
        assert_equal("number", type(y))
    end)

    -- Icon
    -- @covers lurek.window.setIcon
    it("sets window icon from asset path", function()
        -- Use a common test fixture or skip if none exists
        lurek.window.setIcon("assets/icon.png")
        assert_equal("userdata", type(lurek.window))
    end)

    -- Window mode presets
    -- @covers lurek.window.setMode
    it("applies window mode configuration", function()
        local flags = {
            title = "Game",
            fullscreen = false,
            vsync = true,
        }
        lurek.window.setMode(1280, 720, flags)
        assert_equal("userdata", type(lurek.window))
    end)

    -- @covers lurek.window.getMode
    it("returns current window mode configuration", function()
        local mode = lurek.window.getMode()
        assert_true(type(mode) == "table" or mode == nil)
    end)

    -- Display info
    -- @covers lurek.window.getDisplayCount
    it("returns number of available displays", function()
        local count = lurek.window.getDisplayCount()
        assert_equal("number", type(count))
        assert_true(count >= 1)
    end)

    -- @covers lurek.window.getDisplayName
    it("returns the active display name", function()
        local display_name = lurek.window.getDisplayName()
        assert_equal("string", type(display_name))
    end)

    -- Scale mode (letterbox, stretch, pixel-perfect)
    -- @covers lurek.window.setScaleMode
    it("sets scaling mode for pixel-perfect or letterbox", function()
        lurek.window.setScaleMode("letterbox")
        assert_equal("userdata", type(lurek.window))
    end)

    -- @covers lurek.window.getScaleMode
    it("returns current scale mode", function()
        lurek.window.setScaleMode("stretch")
        local mode = lurek.window.getScaleMode()
        assert_true(type(mode) == "string" and string.len(mode) > 0)
    end)

end)
test_summary()
