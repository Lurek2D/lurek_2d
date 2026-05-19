-- content/examples/window.lua
-- Auto-generated from content/examples2/window_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/window.lua

-- window_00.lua: Window basics — dimensions, title, position, mode, fullscreen

--@api-stub: lurek.window.getDimensions
do
    -- query window width and height
    local w, h = lurek.window.getDimensions()
    print("window dimensions:", w, h)
    print("width:", lurek.window.getWidth())
    print("height:", lurek.window.getHeight())
end

--@api-stub: lurek.window.setTitle
--@api-stub: lurek.window.getTitle
do
    -- get and set the window title
    lurek.window.setTitle("My Game - Level 1")
    print("title:", lurek.window.getTitle())
    lurek.window.setTitle("My Game - Paused")
    print("updated title:", lurek.window.getTitle())
end

--@api-stub: lurek.window.getPosition
--@api-stub: lurek.window.setPosition
do
    -- read and set window position on screen
    local x, y = lurek.window.getPosition()
    print("position:", x, y)
    lurek.window.setPosition(100, 100)
    local nx, ny = lurek.window.getPosition()
    print("new position:", nx, ny)
end

--@api-stub: lurek.window.getMode
--@api-stub: lurek.window.setMode
do
    -- query and set window mode with flags
    local w, h, flags = lurek.window.getMode()
    print("mode:", w, "x", h)
    print("fullscreen:", flags.fullscreen)
    print("vsync:", flags.vsync)
    lurek.window.setMode(1280, 720, { fullscreen = false, vsync = 1 })
    local nw, nh, nflags = lurek.window.getMode()
    print("new mode:", nw, "x", nh, "vsync:", nflags.vsync)
end

--@api-stub: lurek.window.isFullscreen
--@api-stub: lurek.window.getFullscreen
--@api-stub: lurek.window.setFullscreen
do
    -- toggle fullscreen mode
    print("is fullscreen:", lurek.window.isFullscreen())
    print("fullscreen state:", lurek.window.getFullscreen())
    lurek.window.setFullscreen(true, "desktop")
    print("after enable:", lurek.window.isFullscreen())
    lurek.window.setFullscreen(false)
    print("after disable:", lurek.window.isFullscreen())
end

--@api-stub: lurek.window.getPixelDimensions
--@api-stub: lurek.window.getDPIScale
--@api-stub: lurek.window.getNativeDPIScale
do
    -- physical pixel dimensions and DPI scale
    local pw, ph = lurek.window.getPixelDimensions()
    print("pixel dimensions:", pw, ph)
    print("DPI scale:", lurek.window.getDPIScale())
    print("native DPI scale:", lurek.window.getNativeDPIScale())
end

--@api-stub: lurek.window.fromPixels
--@api-stub: lurek.window.toPixels
do
    -- convert between logical and pixel units
    local logical = lurek.window.fromPixels(200)
    print("200 pixels in logical:", logical)
    local pixels = lurek.window.toPixels(100)
    print("100 logical in pixels:", pixels)
end

--@api-stub: lurek.window.windowConfig
do
    -- apply multiple window settings at once
    lurek.window.windowConfig({
        title = "Configured Window",
        width = 1024,
        height = 768,
        fullscreen = false,
        vsync = 1,
        scaleMode = "letterbox",
    })
    print("title after config:", lurek.window.getTitle())
    local w, h = lurek.window.getDimensions()
    print("dimensions after config:", w, h)
end

-- window_01.lua: Window advanced — displays, scale, focus, state, dialogs

--@api-stub: lurek.window.getDisplayCount
--@api-stub: lurek.window.getCurrentDisplay
--@api-stub: lurek.window.getDisplayName
do
    -- query display/monitor information
    local count = lurek.window.getDisplayCount()
    print("display count:", count)
    local current = lurek.window.getCurrentDisplay()
    print("current display index:", current)
    local name = lurek.window.getDisplayName(current)
    print("display name:", name)
end

--@api-stub: lurek.window.getDesktopDimensions
--@api-stub: lurek.window.getDisplays
do
    -- get desktop resolution and full display list
    local dw, dh = lurek.window.getDesktopDimensions()
    print("desktop resolution:", dw, dh)
    local displays = lurek.window.getDisplays()
    for i, d in ipairs(displays) do
        print("display", d.index, d.name, d.width .. "x" .. d.height, "scale:", d.scale)
    end
end

--@api-stub: lurek.window.getFullscreenModes
do
    -- list available fullscreen modes
    local modes = lurek.window.getFullscreenModes()
    print("fullscreen modes available:", #modes)
    if #modes > 0 then
        local m = modes[1]
        print("first mode:", m.width .. "x" .. m.height, "@", m.refreshRate, "Hz")
    end
end

--@api-stub: lurek.window.setScaleMode
--@api-stub: lurek.window.getScaleMode
--@api-stub: lurek.window.getScaleInfo
do
    -- scale mode configuration
    lurek.window.setScaleMode("letterbox")
    print("scale mode:", lurek.window.getScaleMode())
    local info = lurek.window.getScaleInfo()
    print("scale x:", info.scale_x, "y:", info.scale_y)
    print("offset:", info.offset_x, info.offset_y)
    print("game size:", info.game_width, "x", info.game_height)
end

--@api-stub: lurek.window.getGameWidth
--@api-stub: lurek.window.getGameHeight
do
    -- query logical game dimensions
    print("game width:", lurek.window.getGameWidth())
    print("game height:", lurek.window.getGameHeight())
end

do
    -- check window focus state
    print("has keyboard focus:", lurek.window.hasFocus())
    print("has mouse focus:", lurek.window.hasMouseFocus())
    lurek.window.focus()
    print("after focus call:", lurek.window.hasFocus())
end

--@api-stub: lurek.window.isOpen
--@api-stub: lurek.window.isVisible
--@api-stub: lurek.window.isResizable
--@api-stub: lurek.window.isMaximized
--@api-stub: lurek.window.isMinimized
do
    -- check window state flags
    print("is open:", lurek.window.isOpen())
    print("is visible:", lurek.window.isVisible())
    print("is resizable:", lurek.window.isResizable())
    print("is maximized:", lurek.window.isMaximized())
    print("is minimized:", lurek.window.isMinimized())
end

--@api-stub: lurek.window.maximize
--@api-stub: lurek.window.isMaximized
--@api-stub: lurek.window.restore
--@api-stub: lurek.window.minimize
--@api-stub: lurek.window.isMinimized
do
    -- window state management
    lurek.window.maximize()
    print("maximized:", lurek.window.isMaximized())
    lurek.window.restore()
    print("after restore:", lurek.window.isMaximized())
    lurek.window.minimize()
    print("minimized:", lurek.window.isMinimized())
    lurek.window.restore()
end

--@api-stub: lurek.window.setVSync
--@api-stub: lurek.window.getVSync
do
    -- configure vertical sync
    lurek.window.setVSync(1)
    print("vsync:", lurek.window.getVSync())
    lurek.window.setVSync(0)
    print("vsync off:", lurek.window.getVSync())
    lurek.window.setVSync(-1)
    print("adaptive vsync:", lurek.window.getVSync())
end

--@api-stub: lurek.window.setDisplay
--@api-stub: lurek.window.flash
--@api-stub: lurek.window.requestAttention
--@api-stub: lurek.window.getDisplayOrientation
--@api-stub: lurek.window.getSystemTheme
do
    -- move window to display, flash, and request attention
    lurek.window.setDisplay(0)
    lurek.window.flash()
    lurek.window.requestAttention()
    print("display orientation:", lurek.window.getDisplayOrientation())
    print("system theme:", lurek.window.getSystemTheme())
end

--@api-stub: lurek.window.showMessageBox
do
    -- display a native message box dialog
    local result = lurek.window.showMessageBox("Save?", "Do you want to save before exit?", "warning", "yesno")
    print("user clicked:", result)
end

--@api-stub: lurek.window.getSafeArea
do
    -- get safe drawing area (desktop = full window)
    local sx, sy, sw, sh = lurek.window.getSafeArea()
    print("safe area:", sx, sy, sw, sh)
end

--@api-stub: lurek.window.setIcon
do
    -- set the window icon from an image file
    lurek.window.setIcon("assets/textures/ray_water.png")
    print("icon set")
end

do
    -- register DPI change callback
    lurek.window.onDpiChange(function(new_scale)
        print("DPI changed to:", new_scale)
    end)
    local scale = lurek.window.pollDpiChange()
    print("current DPI scale:", scale)
end

--@api-stub: lurek.window.isHighDPIAllowed
do
    -- check high-DPI mode status
    print("high DPI allowed:", lurek.window.isHighDPIAllowed())
end

--- Window Part 2: full lurek.window module + LGuiWindow coverage

--@api-stub: lurek.window.close
--@api-stub: lurek.window.focus
-- lurek.window full API: display info, title, mode, fullscreen, scale, position, icon.
do
    local title = lurek.window.getTitle()
    print("title=" .. tostring(title))
    lurek.window.setTitle("Lurek2D Test")

    local w, h = lurek.window.getDimensions()
    print("w=" .. w .. " h=" .. h)

    local gw = lurek.window.getGameWidth()
    local gh = lurek.window.getGameHeight()
    print("gw=" .. gw .. " gh=" .. gh)

    local pw, ph = lurek.window.getPixelDimensions()
    print("pixel_w=" .. pw .. " pixel_h=" .. ph)

    local dpi = lurek.window.getDPIScale()
    print("dpi=" .. dpi)
    local native_dpi = lurek.window.getNativeDPIScale()
    print("native_dpi=" .. native_dpi)

    local display = lurek.window.getCurrentDisplay()
    print("display=" .. display)
    local dcount = lurek.window.getDisplayCount()
    print("display_count=" .. dcount)
    local dname = lurek.window.getDisplayName(1)
    print("display_name=" .. tostring(dname))
    local dori = lurek.window.getDisplayOrientation()
    print("display_ori=" .. tostring(dori))
    local displays = lurek.window.getDisplays()
    print("displays_count=" .. #displays)
    local dw, dh = lurek.window.getDesktopDimensions(1)
    print("desktop_w=" .. dw .. " desktop_h=" .. dh)

    local fullscreen, fstype = lurek.window.getFullscreen()
    print("fullscreen=" .. tostring(fullscreen))
    local fsmodes = lurek.window.getFullscreenModes()
    print("fullscreen_modes=" .. #fsmodes)

    local px, py = lurek.window.getPosition()
    print("pos_x=" .. px .. " pos_y=" .. py)

    local safe = lurek.window.getSafeArea()
    print("safe_area=" .. tostring(safe ~= nil))

    local scale_info = lurek.window.getScaleInfo()
    print("scale_info=" .. tostring(scale_info ~= nil))
    local scale_mode = lurek.window.getScaleMode()
    print("scale_mode=" .. tostring(scale_mode))

    local theme = lurek.window.getSystemTheme()
    print("theme=" .. tostring(theme))

    local vsync = lurek.window.getVSync()
    print("vsync=" .. tostring(vsync))

    local mode = lurek.window.getMode()
    print("mode=" .. tostring(mode ~= nil))

    local px_val = lurek.window.toPixels(100)
    print("to_pixels=" .. px_val)
    local fp_val = lurek.window.fromPixels(100)
    print("from_pixels=" .. fp_val)

    print("is_maximized=" .. tostring(lurek.window.isMaximized()))
    print("is_minimized=" .. tostring(lurek.window.isMinimized()))

    lurek.window.setMode(1280, 720, {})
    lurek.window.setFullscreen(false, "desktop")
    lurek.window.setScaleMode("nearest")
    lurek.window.setVSync(1)
    lurek.window.setIcon("assets/textures/ray_water.png")

    lurek.window.maximize()
    lurek.window.minimize()
    lurek.window.restore()
    lurek.window.focus()
    lurek.window.flash()

end

--@api-stub: LGuiWindow:getTitle
--@api-stub: LGuiWindow:isCloseable
--@api-stub: LGuiWindow:isDraggable
--@api-stub: LGuiWindow:isResizable
--@api-stub: LGuiWindow:setCloseable
--@api-stub: LGuiWindow:setDraggable
--@api-stub: LGuiWindow:setOnClose
--@api-stub: LGuiWindow:setResizable
--@api-stub: LGuiWindow:setTitle
-- LGuiWindow: floating UI window with title and draggability controls.
do
    local win = lurek.ui.newWindow("Test Window")
    print("win_title=" .. win:getTitle())
    win:setTitle("Renamed Window")
    print("win_title2=" .. win:getTitle())
    print("closeable=" .. tostring(win:isCloseable()))
    win:setCloseable(true)
    print("draggable=" .. tostring(win:isDraggable()))
    win:setDraggable(false)
    print("resizable=" .. tostring(win:isResizable()))
    win:setResizable(true)
    win:setOnClose(function() print("window_closed") end)
end

--@api-stub: lurek.window.getHeight
--@api-stub: lurek.window.getWidth
--@api-stub: lurek.window.hasFocus
-- Query window size and focus state.
do
    local w = lurek.window.getWidth()
    local h = lurek.window.getHeight()
    local focused = lurek.window.hasFocus()
    print("window size:", w, h, "focused:", focused)
end

--@api-stub: lurek.window.hasMouseFocus
-- Check mouse focus, fullscreen and open state.
do
    local mfocus = lurek.window.hasMouseFocus()
    local fs = lurek.window.isFullscreen()
    local open = lurek.window.isOpen()
    print("mouse focus:", mfocus, "fullscreen:", fs, "open:", open)
end

--@api-stub: lurek.window.onDpiChange
--@api-stub: lurek.window.pollDpiChange
--@api-stub: lurek.window.openFileDialog
-- DPI change callback and file dialog.
do
    lurek.window.onDpiChange(function(scale)
        print("dpi changed:", scale)
    end)
    local changed = lurek.window.pollDpiChange()
    -- openFileDialog returns string path or nil
    local path = lurek.window.openFileDialog({title = "Select file"})
    print("dpi changed:", changed, "chosen path:", tostring(path))
end

print("content/examples/window.lua")
