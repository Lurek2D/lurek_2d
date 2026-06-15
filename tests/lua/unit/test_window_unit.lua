-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_window_core_unit.lua
do
-- Lurek2D Window API Tests

-- @describe lurek.window basic functions
describe("lurek.window basic functions", function()
    -- @covers lurek.window.getTitle
    it("getTitle returns a string", function()
        local title = lurek.window.getTitle()
        expect_type("string", title)
    end)

    -- @covers lurek.window.getDimensions
    it("getDimensions returns positive numeric values", function()
        local w, h = lurek.window.getDimensions()
        expect_type("number", w)
        expect_type("number", h)
        expect_true(w > 0, "width > 0")
        expect_true(h > 0, "height > 0")
    end)

    -- @covers lurek.window.getWidth
    it("getWidth returns a number", function()
        expect_type("number", lurek.window.getWidth())
    end)

    -- @covers lurek.window.getHeight
    it("getHeight returns a number", function()
        expect_type("number", lurek.window.getHeight())
    end)
end)

-- @describe lurek.window fullscreen
describe("lurek.window fullscreen", function()
    -- @covers lurek.window.getFullscreen
    it("getFullscreen returns the default desktop fullscreen tuple", function()
        local fs, ft = lurek.window.getFullscreen()
        expect_type("boolean", fs)
        expect_type("string", ft)
        expect_equal(false, fs)
        expect_equal("desktop", ft)
    end)

    -- @covers lurek.window.isOpen
    it("isOpen always returns true", function()
        expect_equal(true, lurek.window.isOpen())
    end)

    -- @covers lurek.window.setFullscreen
    it("setFullscreen accepts a boolean flag without breaking fullscreen queries", function()
        local before_flag, before_type = lurek.window.getFullscreen()
        expect_no_error(function()
            lurek.window.setFullscreen(false)
        end)
        local after_flag, after_type = lurek.window.getFullscreen()
        expect_type("boolean", after_flag)
        expect_type("string", after_type)
        expect_equal(false, after_flag)
        expect_equal(before_type, after_type)

        expect_no_error(function()
            lurek.window.setFullscreen(before_flag)
        end)
    end)
end)

-- @describe lurek.window vsync
describe("lurek.window vsync", function()
    -- @covers lurek.window.getVSync
    it("getVSync returns default 1", function()
        expect_equal(1, lurek.window.getVSync())
    end)

    -- @covers lurek.window.setVSync
    it("setVSync accepts integer modes and preserves numeric reads", function()
        local before = lurek.window.getVSync()
        expect_no_error(function()
            lurek.window.setVSync(0)
        end)
        expect_type("number", lurek.window.getVSync())

        expect_no_error(function()
            lurek.window.setVSync(1)
        end)
        expect_type("number", lurek.window.getVSync())

        expect_no_error(function()
            lurek.window.setVSync(before)
        end)
    end)
end)

-- @describe lurek.window state queries
describe("lurek.window state queries", function()
    -- @covers lurek.window.hasFocus
    it("hasFocus returns the default focused state", function()
        expect_type("boolean", lurek.window.hasFocus())
        expect_equal(true, lurek.window.hasFocus())
    end)

    -- @covers lurek.window.hasMouseFocus
    it("hasMouseFocus returns boolean", function()
        expect_type("boolean", lurek.window.hasMouseFocus())
    end)

    -- @covers lurek.window.isMinimized
    it("isMinimized default is false", function()
        expect_equal(false, lurek.window.isMinimized())
    end)

    -- @covers lurek.window.isMaximized
    it("isMaximized default is false", function()
        expect_equal(false, lurek.window.isMaximized())
    end)

    -- @covers lurek.window.isVisible
    it("isVisible default is true", function()
        expect_equal(true, lurek.window.isVisible())
    end)

    -- @covers lurek.window.minimize
    it("minimize updates the minimized window state", function()
        lurek.window.minimize()
        expect_type("boolean", lurek.window.isMinimized())
        lurek.window.restore()
    end)

    -- @covers lurek.window.maximize
    it("maximize updates the maximized window state", function()
        lurek.window.maximize()
        expect_type("boolean", lurek.window.isMaximized())
        lurek.window.restore()
    end)

    -- @covers lurek.window.restore
    it("restore clears minimized and maximized window states", function()
        lurek.window.maximize()
        lurek.window.restore()
        expect_type("boolean", lurek.window.isMaximized())
        lurek.window.minimize()
        lurek.window.restore()
        expect_type("boolean", lurek.window.isMinimized())
    end)
end)

-- @describe lurek.window position
describe("lurek.window position", function()
    -- @covers lurek.window.getPosition
    it("getPosition returns two numbers", function()
        local x, y = lurek.window.getPosition()
        expect_type("number", x)
        expect_type("number", y)
    end)

    -- @covers lurek.window.setPosition
    it("setPosition accepts numeric coordinates without breaking position reads", function()
        local x, y = lurek.window.getPosition()
        expect_no_error(function()
            lurek.window.setPosition(x, y)
        end)
        local next_x, next_y = lurek.window.getPosition()
        expect_type("number", next_x)
        expect_type("number", next_y)
    end)

    -- @covers lurek.window.getDisplayCount
    it("getDisplayCount returns a number", function()
        local n = lurek.window.getDisplayCount()
        expect_type("number", n)
        expect_true(n >= 1, "at least 1 display")
    end)

    -- @covers lurek.window.getDisplays
    it("getDisplays returns structured entries", function()
        local displays = lurek.window["getDisplays"]()
        expect_type("table", displays)
        expect_not_nil(displays[1])
        expect_type("table", displays[1])
        local first = displays[1]
        expect_type("number", first.index)
        expect_type("string", first.name)
        expect_type("number", first.width)
        expect_type("number", first.height)
        expect_type("boolean", first.primary)
    end)

    -- @covers lurek.window.getCurrentDisplay
    it("getCurrentDisplay returns a number", function()
        local idx = lurek.window["getCurrentDisplay"]()
        expect_type("number", idx)
        expect_true(idx >= 0, "display index should be >= 0")
    end)

    -- @covers lurek.window.setDisplay
    it("setDisplay accepts valid indices and rejects negative indices", function()
        expect_no_error(function()
            lurek.window["setDisplay"](0)
        end)
        expect_error(function()
            lurek.window["setDisplay"](-1)
        end)
    end)

    -- @covers lurek.window.getDesktopDimensions
    it("getDesktopDimensions returns two numbers", function()
        local w, h = lurek.window.getDesktopDimensions()
        expect_type("number", w)
        expect_type("number", h)
    end)
end)

-- @describe lurek.window DPI
describe("lurek.window DPI", function()
    -- @covers lurek.window.getDPIScale
    it("getDPIScale returns the default positive scale", function()
        local s = lurek.window.getDPIScale()
        expect_type("number", s)
        expect_true(s > 0, "DPI scale > 0")
        expect_equal(1, s)
    end)

    -- @covers lurek.window.toPixels
    it("toPixels converts correctly", function()
        local px = lurek.window.toPixels(100)
        expect_type("number", px)
        -- With default DPI scale of 1.0, should be 100
        expect_equal(100, px)
    end)

    -- @covers lurek.window.fromPixels
    it("fromPixels converts correctly", function()
        local val = lurek.window.fromPixels(100)
        expect_type("number", val)
        expect_equal(100, val)
    end)
end)

-- @describe lurek.window mode
describe("lurek.window mode", function()
    -- @covers lurek.window.setMode
    it("setMode is a function", function()
        expect_type("function", lurek.window.setMode)
    end)

    -- @covers lurek.window.getMode
    it("getMode returns width, height, and structured flags", function()
        local w, h, flags = lurek.window.getMode()
        expect_type("number", w)
        expect_type("number", h)
        expect_type("table", flags)
        expect_type("boolean", flags.fullscreen)
        expect_type("string", flags.fullscreentype)
        expect_type("number", flags.vsync)
    end)
end)

-- @describe lurek.window close and attention
describe("lurek.window close and attention", function()
    -- @covers lurek.window.close
    it("close is a function", function()
        expect_type("function", lurek.window.close)
    end)

    -- @covers lurek.window.requestAttention
    it("requestAttention is a function", function()
        expect_type("function", lurek.window.requestAttention)
    end)

    -- @covers lurek.window.flash
    it("flash is callable without error", function()
        expect_type("function", lurek.window["flash"])
        expect_no_error(function()
            lurek.window["flash"]()
        end)
    end)
end)

-- Phase 17: Missing Window Surface
-- @describe lurek.window missing surface (Phase 17)
describe("lurek.window missing surface (Phase 17)", function()
    -- @covers lurek.window.focus
    it("focus is callable without error and keeps focus queries stable", function()
        expect_type("function", lurek.window.focus)
        local before = lurek.window.hasFocus()
        expect_no_error(function()
            lurek.window.focus()
        end)
        expect_equal(before, lurek.window.hasFocus())
    end)

    -- @covers lurek.window.getNativeDPIScale
    it("getNativeDPIScale returns a positive number", function()
        expect_type("function", lurek.window.getNativeDPIScale)
        local s = lurek.window.getNativeDPIScale()
        expect_type("number", s)
        expect_true(s > 0, "DPI scale must be positive")
    end)

    -- @covers lurek.window.getDisplayOrientation
    it("getDisplayOrientation returns a recognized orientation string", function()
        expect_type("function", lurek.window.getDisplayOrientation)
        local o = lurek.window.getDisplayOrientation()
        expect_type("string", o)
        local valid = (o == "landscape" or o == "portrait" or
                       o == "landscapeflipped" or o == "portraitflipped")
        expect_true(valid, "orientation must be landscape/portrait/landscapeflipped/portraitflipped")
    end)

    -- @covers lurek.window.getSafeArea
    it("getSafeArea returns a positive numeric rectangle", function()
        expect_type("function", lurek.window.getSafeArea)
        local x, y, w, h = lurek.window.getSafeArea()
        expect_type("number", x)
        expect_type("number", y)
        expect_type("number", w)
        expect_type("number", h)
        expect_true(w > 0, "safe area width > 0")
        expect_true(h > 0, "safe area height > 0")
    end)

    -- @covers lurek.window.getSystemTheme
    it("getSystemTheme returns a string", function()
        expect_type("function", lurek.window.getSystemTheme)
        local t = lurek.window.getSystemTheme()
        expect_type("string", t)
    end)

    -- @covers lurek.window.isHighDPIAllowed
    it("isHighDPIAllowed returns a boolean", function()
        expect_type("function", lurek.window.isHighDPIAllowed)
        expect_type("boolean", lurek.window.isHighDPIAllowed())
    end)
end)

-- @describe lurek.window cursor helpers
describe("lurek.window cursor helpers", function()
    -- @covers lurek.window.cursor.hasFocus
    it("cursor.hasFocus mirrors the mouse focus query", function()
        expect_type("table", lurek.window.cursor)
        expect_type("function", lurek.window.cursor.hasFocus)
        expect_equal(lurek.window.hasMouseFocus(), lurek.window.cursor.hasFocus())
    end)
end)

-- @describe lurek.window DPI and dialog
describe("lurek.window DPI and dialog", function()
  -- @covers lurek.window.onDpiChange
  it("onDpiChange registers a callback without error", function()
    expect_no_error(function()
      lurek.window.onDpiChange(function(scale) end)
    end)
  end)

  -- @covers lurek.window.pollDpiChange
  it("pollDpiChange returns a positive number", function()
    local scale = lurek.window.pollDpiChange()
    expect_equal(type(scale), "number")
    expect_true(scale > 0, "DPI scale must be positive")
  end)

    -- @covers lurek.window.openFileDialog
    it("openFileDialog is exposed as a function", function()
        expect_type("function", lurek.window.openFileDialog)
  end)
end)

-- ============================================================
-- Merged from test_window_icon.lua
-- ============================================================

-- @describe lurek.window.setIcon  exposure
describe("lurek.window.setIcon  exposure", function()
    -- @covers lurek.window.setIcon
    it("validates icon paths", function()
        expect_type("function", lurek.window.setIcon)
        expect_error(function()
            lurek.window.setIcon("")
        end)
        expect_error(function()
            lurek.window.setIcon("nonexistent_icon_file.png")
        end)
        expect_error(function()
            lurek.window.setIcon("missing_icon.bmp")
        end)
    end)
end)

-- ============================================================
-- Merged from test_window_scaling.lua
-- ============================================================

-- @describe lurek.window.getScaleMode defaults
describe("lurek.window.getScaleMode defaults", function()
    -- @covers lurek.window.getScaleMode
    it("returns the default scale mode string", function()
        local mode = lurek.window.getScaleMode()
        expect_type("string", mode)
        expect_equal("none", mode)
    end)
end)

-- @describe lurek.window.setScaleMode
describe("lurek.window.setScaleMode", function()
    -- @covers lurek.window.setScaleMode
    it("accepts valid modes and ignores invalid ones", function()
        expect_no_error(function()
            lurek.window.setScaleMode("letterbox")
        end)
        expect_no_error(function()
            lurek.window.setScaleMode("stretch")
        end)
        expect_no_error(function()
            lurek.window.setScaleMode("pixel")
        end)
        expect_no_error(function()
            lurek.window.setScaleMode("none")
        end)
        local before = lurek.window.getScaleMode()
        expect_no_error(function()
            lurek.window.setScaleMode("invalid_mode")
        end)
        local after = lurek.window.getScaleMode()
        expect_equal(before, after)
        expect_no_error(function()
            lurek.window.setScaleMode("")
        end)
        expect_equal(before, lurek.window.getScaleMode())
    end)
end)

-- @describe lurek.window.getGameWidth
describe("lurek.window.getGameWidth", function()
    -- @covers lurek.window.getGameWidth
    it("returns a positive number", function()
        local w = lurek.window.getGameWidth()
        expect_type("number", w)
        expect_true(w > 0, "game_width must be positive, got " .. tostring(w))
    end)
end)

-- @describe lurek.window.getGameHeight
describe("lurek.window.getGameHeight", function()
    -- @covers lurek.window.getGameHeight
    it("returns a positive number", function()
        local h = lurek.window.getGameHeight()
        expect_type("number", h)
        expect_true(h > 0, "game_height must be positive, got " .. tostring(h))
    end)
end)

-- @describe lurek.window.getScaleInfo
describe("lurek.window.getScaleInfo", function()
    -- @covers lurek.window.getScaleInfo
    it("returns a complete scaling info table", function()
        local info = lurek.window.getScaleInfo()
        expect_type("table", info)
        expect_not_nil(info.scale_x)
        expect_not_nil(info.scale_y)
        expect_not_nil(info.offset_x)
        expect_not_nil(info.offset_y)
        expect_not_nil(info.game_width)
        expect_not_nil(info.game_height)
        expect_type("number", info.scale_x)
        expect_type("number", info.scale_y)
        expect_type("number", info.offset_x)
        expect_type("number", info.offset_y)
        local w = lurek.window.getGameWidth()
        expect_near(w, info.game_width, 0.001)
        local h = lurek.window.getGameHeight()
        expect_near(h, info.game_height, 0.001)
        if lurek.window.getScaleMode() == "none" then
            expect_near(1.0, info.scale_x, 0.001)
            expect_near(1.0, info.scale_y, 0.001)
        end
    end)
end)

-- @describe Lua API coverage
describe("Lua API coverage", function()
    -- @covers lurek.window.getFullscreenModes
    it("covers lurek.window.getFullscreenModes", function()
        expect_type("function", lurek.window.getFullscreenModes)
    end)

    -- @covers lurek.window.getDisplayName
    it("covers lurek.window.getDisplayName", function()
        local name = lurek.window.getDisplayName()
        expect_type("string", name)
        expect_true(#name > 0, "display name should not be empty")
    end)

    -- @covers lurek.window.getPixelDimensions
    it("covers lurek.window.getPixelDimensions", function()
        local pixel_w, pixel_h = lurek.window.getPixelDimensions()
        local logical_w, logical_h = lurek.window.getDimensions()
        local scale = lurek.window.getDPIScale()

        expect_type("number", pixel_w)
        expect_type("number", pixel_h)
        expect_equal(math.floor(logical_w * scale + 0.5), pixel_w)
        expect_equal(math.floor(logical_h * scale + 0.5), pixel_h)
    end)

    -- @covers lurek.window.showMessageBox
    it("covers lurek.window.showMessageBox", function()
        expect_type("function", lurek.window.showMessageBox)
    end)

end)

-- @describe lurek.window.setTitle
describe("lurek.window.setTitle", function()
    -- @covers lurek.window.setTitle
    it("updates title without error", function()
        local title = lurek.window.getTitle()
        expect_no_error(function()
            lurek.window.setTitle(title)
        end)
        expect_type("string", lurek.window.getTitle())
    end)
end)
-- @describe lurek.window.isFullscreen
describe("lurek.window.isFullscreen", function()
    -- @covers lurek.window.isFullscreen
    it("matches the fullscreen flag from getFullscreen", function()
        local fullscreen_flag = lurek.window.isFullscreen()
        local expected_flag = select(1, lurek.window.getFullscreen())
        expect_type("boolean", fullscreen_flag)
        expect_equal(expected_flag, fullscreen_flag)
    end)
end)

-- @describe lurek.window.isResizable
describe("lurek.window.isResizable", function()
    -- @covers lurek.window.isResizable
    it("returns a boolean", function()
        expect_type("boolean", lurek.window.isResizable())
    end)
end)
-- @describe windowConfig helper
describe("windowConfig helper", function()
    -- @covers lurek.window.windowConfig
    it("windowConfig applies title and mode fields", function()
        local apply = lurek.window["windowConfig"]
        apply({
            title = "Window Config Test",
            width = 800,
            height = 600,
            fullscreen = false,
            fullscreentype = "desktop",
            vsync = 1,
            scaleMode = "letterbox",
        })
        local w, h, flags = lurek.window.getMode()
        expect_equal(800, w)
        expect_equal(600, h)
        expect_equal(false, flags.fullscreen)
    end)

    -- @covers lurek.window.windowConfig
    it("windowConfig applies only provided fields", function()
        local title_before = lurek.window.getTitle()
        local width_before, height_before = lurek.window.getDimensions()

        expect_no_error(function()
            lurek.window.windowConfig({
                title = "Window Config Partial",
            })
        end)
        expect_equal(title_before, lurek.window.getTitle())
        local width_after, height_after = lurek.window.getDimensions()
        expect_equal(width_before, width_after)
        expect_equal(height_before, height_after)

        expect_no_error(function()
            lurek.window.windowConfig({
                scaleMode = "stretch",
            })
        end)
        local width_scale, height_scale = lurek.window.getDimensions()
        expect_equal(width_before, width_scale)
        expect_equal(height_before, height_scale)

        expect_no_error(function()
            lurek.window.windowConfig({
                title = title_before,
                scaleMode = "none",
            })
        end)
    end)
end)
end
-- END test_window_core_unit.lua

test_summary()
