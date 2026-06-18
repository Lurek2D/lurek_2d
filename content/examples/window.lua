-- content/examples/window.lua
-- Auto-generated from content/examples2/window_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/window.lua

local function example_print_log(...)
    local parts = {}
    for i = 1, select("#", ...) do
        parts[i] = tostring(select(i, ...))
    end
    lurek.log.info(table.concat(parts, " "))
end

--@api: lurek.window.getDimensions
do
    local w, h = lurek.window.getDimensions()
    local pixel_w, pixel_h = lurek.window.getPixelDimensions()
    local dpi = lurek.window.getDPIScale()
    local title = lurek.window.getTitle()
    lurek.log.info("window '" .. title .. "' dimensions = " .. w .. "x" .. h)
    lurek.log.info("pixel size = " .. pixel_w .. "x" .. pixel_h .. " dpi=" .. dpi)
end

--@api: lurek.window.setTitle
do
    local previous = lurek.window.getTitle()
    lurek.window.setTitle("My Game - Level 1")
    local current = lurek.window.getTitle()
    lurek.window.setTitle(previous)
    lurek.log.info("title changed " .. previous .. " -> " .. current)
    lurek.log.info("title restored = " .. lurek.window.getTitle())
end

--@api: lurek.window.getTitle
do
    local title = lurek.window.getTitle()
    local has_focus = lurek.window.hasFocus()
    local is_open = lurek.window.isOpen()
    lurek.log.info("window title = " .. title)
    lurek.log.info("open=" .. tostring(is_open) .. " focus=" .. tostring(has_focus))
end

--@api: lurek.window.getPosition
do
    local x, y = lurek.window.getPosition()
    local w, h = lurek.window.getDimensions()
    local display = lurek.window.getCurrentDisplay()
    local label = x .. "," .. y
    lurek.log.info("window position = " .. label)
    lurek.log.info("display=" .. display .. " size=" .. w .. "x" .. h)
end

--@api: lurek.window.setPosition
do
    local x, y = lurek.window.getPosition()
    lurek.window.setPosition(100, 100)
    local nx, ny = lurek.window.getPosition()
    lurek.window.setPosition(x, y)
    local restored_x, restored_y = lurek.window.getPosition()
    lurek.log.info("temporary position = " .. nx .. "," .. ny)
    lurek.log.info("restored position = " .. restored_x .. "," .. restored_y)
end

--@api: lurek.window.getMode
do
    local w, h, flags = lurek.window.getMode()
    local title = lurek.window.getTitle()
    local fullscreen = tostring(flags.fullscreen)
    local vsync = tostring(flags.vsync)
    lurek.log.info("mode for " .. title .. " = " .. w .. "x" .. h)
    lurek.log.info("fullscreen=" .. fullscreen .. " type=" .. flags.fullscreentype .. " vsync=" .. vsync)
end

--@api: lurek.window.setMode
do
    local old_w, old_h, old_flags = lurek.window.getMode()
    lurek.window.setMode(1280, 720, { fullscreen = false, fullscreentype = "desktop", vsync = 1 })
    local nw, nh, nflags = lurek.window.getMode()
    lurek.window.setMode(old_w, old_h, old_flags)
    local rw, rh = lurek.window.getDimensions()
    lurek.log.info("temporary mode = " .. nw .. "x" .. nh .. " vsync=" .. tostring(nflags.vsync))
    lurek.log.info("restored dimensions = " .. rw .. "x" .. rh)
end

--@api: lurek.window.isFullscreen
do
    local v = lurek.window.isFullscreen()
    local enabled, mode = lurek.window.getFullscreen()
    local scale_mode = lurek.window.getScaleMode()
    lurek.log.info("is fullscreen = " .. tostring(v))
    lurek.log.info("fullscreen tuple=" .. tostring(enabled) .. "/" .. mode .. " scale=" .. scale_mode)
end

--@api: lurek.window.getFullscreen
do
    local enabled, fsType = lurek.window.getFullscreen()
    local flag = lurek.window.isFullscreen()
    local w, h = lurek.window.getDimensions()
    lurek.log.info("fullscreen enabled = " .. tostring(enabled))
    lurek.log.info("fullscreen type = " .. fsType .. " current size=" .. w .. "x" .. h .. " flag=" .. tostring(flag))
end

--@api: lurek.window.setFullscreen
do
    local before_enabled, before_type = lurek.window.getFullscreen()
    lurek.window.setFullscreen(true, "desktop")
    local enabled_now = lurek.window.isFullscreen()
    lurek.window.setFullscreen(false)
    local disabled_now = lurek.window.isFullscreen()
    lurek.window.setFullscreen(before_enabled, before_type)
    lurek.log.info("enabled fullscreen temporarily = " .. tostring(enabled_now))
    lurek.log.info("disabled again = " .. tostring(disabled_now))
end

--@api: lurek.window.getPixelDimensions
do
    local pw, ph = lurek.window.getPixelDimensions()
    local lw, lh = lurek.window.getDimensions()
    local scale = lurek.window.getDPIScale()
    lurek.log.info("pixel dimensions = " .. pw .. "x" .. ph)
    lurek.log.info("logical=" .. lw .. "x" .. lh .. " dpi=" .. scale)
end

--@api: lurek.window.getDPIScale
do
    local s = lurek.window.getDPIScale()
    local native = lurek.window.getNativeDPIScale()
    local px = lurek.window.toPixels(100)
    lurek.log.info("DPI scale = " .. s)
    lurek.log.info("native scale = " .. native .. " logical100->px" .. px)
end

--@api: lurek.window.getNativeDPIScale
do
    local s = lurek.window.getNativeDPIScale()
    local runtime = lurek.window.getDPIScale()
    local logical = lurek.window.fromPixels(200)
    lurek.log.info("native DPI scale = " .. s)
    lurek.log.info("runtime scale = " .. runtime .. " px200->logical " .. logical)
end

--@api: lurek.window.fromPixels
do
    local logical = lurek.window.fromPixels(200)
    local pixels = lurek.window.toPixels(100)
    local native = lurek.window.getNativeDPIScale()
    lurek.log.info("200 px -> logical " .. logical)
    lurek.log.info("100 logical -> px " .. pixels .. " native scale=" .. native)
end

--@api: lurek.window.toPixels
do
    local logical = lurek.window.fromPixels(200)
    local pixels = lurek.window.toPixels(100)
    local runtime = lurek.window.getDPIScale()
    lurek.log.info("100 logical -> px " .. pixels)
    lurek.log.info("reverse check 200px->logical " .. logical .. " runtime scale=" .. runtime)
end

--@api: lurek.window.windowConfig
do
    local previous = lurek.window.getTitle()
    lurek.window.windowConfig({ title = "Configured Window", width = 1024, height = 768, fullscreen = false, vsync = 1, scaleMode = "letterbox" })
    local title = lurek.window.getTitle()
    local w, h = lurek.window.getDimensions()
    lurek.window.setTitle(previous)
    lurek.log.info("windowConfig applied title=" .. title)
    lurek.log.info("configured dimensions = " .. w .. "x" .. h .. " then restored title")
end

--@api: lurek.window.getDisplayCount
do
    local count = lurek.window.getDisplayCount()
    example_print_log("display count:", count)
    local current = lurek.window.getCurrentDisplay()
    example_print_log("current display index:", current)
    local name = lurek.window.getDisplayName(current)
    example_print_log("display name:", name)
end

--@api: lurek.window.getCurrentDisplay
do
    local count = lurek.window.getDisplayCount()
    example_print_log("display count:", count)
    local current = lurek.window.getCurrentDisplay()
    example_print_log("current display index:", current)
    local name = lurek.window.getDisplayName(current)
    example_print_log("display name:", name)
end

--@api: lurek.window.getDisplayName
do
    local count = lurek.window.getDisplayCount()
    example_print_log("display count:", count)
    local current = lurek.window.getCurrentDisplay()
    example_print_log("current display index:", current)
    local name = lurek.window.getDisplayName(current)
    example_print_log("display name:", name)
end

--@api: lurek.window.getDesktopDimensions
do
    local dw, dh = lurek.window.getDesktopDimensions()
    example_print_log("desktop resolution:", dw, dh)
    local displays = lurek.window.getDisplays()
    local d = displays[1] or { index = -1, name = "none", width = 0, height = 0, scale = 0 }
    example_print_log("display", d.index, d.name, d.width .. "x" .. d.height, "scale:", d.scale)
end

--@api: lurek.window.getDisplays
do
    local dw, dh = lurek.window.getDesktopDimensions()
    example_print_log("desktop resolution:", dw, dh)
    local displays = lurek.window.getDisplays()
    local d = displays[1] or { index = -1, name = "none", width = 0, height = 0, scale = 0 }
    example_print_log("display", d.index, d.name, d.width .. "x" .. d.height, "scale:", d.scale)
end

--@api: lurek.window.getFullscreenModes
do
    local modes = lurek.window.getFullscreenModes()
    local m = modes[1] or { width = 0, height = 0, refreshRate = 0 }
    local count = #modes
    local label = m.width .. "x" .. m.height .. "@" .. m.refreshRate
    lurek.log.info("fullscreen modes available = " .. count)
    lurek.log.info("first mode = " .. label)
end

--@api: lurek.window.setScaleMode
do
    local previous = lurek.window.getScaleMode()
    lurek.window.setScaleMode("letterbox")
    local mode = lurek.window.getScaleMode()
    local info = lurek.window.getScaleInfo()
    lurek.window.setScaleMode(previous)
    lurek.log.info("scale mode set to " .. mode)
    lurek.log.info("scale=" .. info.scale_x .. "," .. info.scale_y .. " offset=" .. info.offset_x .. "," .. info.offset_y)
end

--@api: lurek.window.getScaleMode
do
    lurek.window.setScaleMode("letterbox")
    local mode = lurek.window.getScaleMode()
    local info = lurek.window.getScaleInfo()
    lurek.window.setScaleMode("none")
    lurek.log.info("queried scale mode = " .. mode)
    lurek.log.info("game area = " .. info.game_width .. "x" .. info.game_height)
end

--@api: lurek.window.getScaleInfo
do
    lurek.window.setScaleMode("letterbox")
    local mode = lurek.window.getScaleMode()
    local info = lurek.window.getScaleInfo()
    lurek.window.setScaleMode("none")
    lurek.log.info("scale info for mode " .. mode)
    lurek.log.info("scale=" .. info.scale_x .. "," .. info.scale_y .. " game=" .. info.game_width .. "x" .. info.game_height)
end

--@api: lurek.window.getGameWidth
do
    local gw = lurek.window.getGameWidth()
    local gh = lurek.window.getGameHeight()
    local info = lurek.window.getScaleInfo()
    lurek.log.info("game width = " .. gw)
    lurek.log.info("paired height = " .. gh .. " scale_x=" .. info.scale_x)
end

--@api: lurek.window.getGameHeight
do
    local gw = lurek.window.getGameWidth()
    local gh = lurek.window.getGameHeight()
    local info = lurek.window.getScaleInfo()
    lurek.log.info("game height = " .. gh)
    lurek.log.info("paired width = " .. gw .. " scale_y=" .. info.scale_y)
end

--@api: lurek.window.hasFocus
do
    local before = lurek.window.hasFocus()
    lurek.window.focus()
    local after = lurek.window.hasFocus()
    local mouse = lurek.window.hasMouseFocus()
    lurek.log.info("focus before=" .. tostring(before) .. " after=" .. tostring(after))
    lurek.log.info("mouse focus = " .. tostring(mouse))
end

--@api: lurek.window.hasMouseFocus
do
    local v = lurek.window.hasMouseFocus()
    local cursor_focus = lurek.window.cursor.hasFocus()
    local win_focus = lurek.window.hasFocus()
    lurek.log.info("mouse focus = " .. tostring(v))
    lurek.log.info("cursor focus = " .. tostring(cursor_focus) .. " window focus=" .. tostring(win_focus))
end

--@api: lurek.window.cursor.hasFocus
do
    local cursor_focus = lurek.window.cursor.hasFocus()
    local mouse_focus = lurek.window.hasMouseFocus()
    local matches = cursor_focus == mouse_focus
    lurek.log.info("cursor focus = " .. tostring(cursor_focus))
    lurek.log.info("matches mouse focus = " .. tostring(matches))
end

--@api: lurek.window.focus
do
    local before = lurek.window.hasFocus()
    lurek.window.focus()
    local after = lurek.window.hasFocus()
    local title = lurek.window.getTitle()
    lurek.log.info("focus request for '" .. title .. "'")
    lurek.log.info("focus before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api: lurek.window.isOpen
do
    local open = lurek.window.isOpen()
    local visible = lurek.window.isVisible()
    local maximized = lurek.window.isMaximized()
    local minimized = lurek.window.isMinimized()
    lurek.log.info("is open = " .. tostring(open))
    lurek.log.info("visible=" .. tostring(visible) .. " max=" .. tostring(maximized) .. " min=" .. tostring(minimized))
end

--@api: lurek.window.isVisible
do
    local visible = lurek.window.isVisible()
    local open = lurek.window.isOpen()
    local resizable = lurek.window.isResizable()
    local minimized = lurek.window.isMinimized()
    lurek.log.info("is visible = " .. tostring(visible))
    lurek.log.info("open=" .. tostring(open) .. " resizable=" .. tostring(resizable) .. " minimized=" .. tostring(minimized))
end

--@api: lurek.window.isResizable
do
    local resizable = lurek.window.isResizable()
    local open = lurek.window.isOpen()
    local visible = lurek.window.isVisible()
    local maximized = lurek.window.isMaximized()
    lurek.log.info("is resizable = " .. tostring(resizable))
    lurek.log.info("open=" .. tostring(open) .. " visible=" .. tostring(visible) .. " max=" .. tostring(maximized))
end

--@api: lurek.window.isMaximized
do
    lurek.window.maximize()
    local maximized = lurek.window.isMaximized()
    lurek.window.restore()
    local restored = lurek.window.isMaximized()
    lurek.log.info("maximized state after request = " .. tostring(maximized))
    lurek.log.info("after restore maximized = " .. tostring(restored))
end

--@api: lurek.window.isMinimized
do
    lurek.window.minimize()
    local minimized = lurek.window.isMinimized()
    lurek.window.restore()
    local restored = lurek.window.isMinimized()
    lurek.log.info("minimized state after request = " .. tostring(minimized))
    lurek.log.info("after restore minimized = " .. tostring(restored))
end

--@api: lurek.window.maximize
do
    lurek.window.maximize()
    example_print_log("maximized:", lurek.window.isMaximized())
    lurek.window.restore()
    example_print_log("after restore:", lurek.window.isMaximized())
    lurek.window.minimize()
    example_print_log("minimized:", lurek.window.isMinimized())
    lurek.window.restore()
end

--@api: lurek.window.restore
do
    lurek.window.maximize()
    example_print_log("maximized:", lurek.window.isMaximized())
    lurek.window.restore()
    example_print_log("after restore:", lurek.window.isMaximized())
    lurek.window.minimize()
    example_print_log("minimized:", lurek.window.isMinimized())
    lurek.window.restore()
end

--@api: lurek.window.minimize
do
    lurek.window.maximize()
    example_print_log("maximized:", lurek.window.isMaximized())
    lurek.window.restore()
    example_print_log("after restore:", lurek.window.isMaximized())
    lurek.window.minimize()
    example_print_log("minimized:", lurek.window.isMinimized())
    lurek.window.restore()
end

--@api: lurek.window.setVSync
do
    lurek.window.setVSync(1)
    example_print_log("vsync:", lurek.window.getVSync())
    lurek.window.setVSync(0)
    example_print_log("vsync off:", lurek.window.getVSync())
    lurek.window.setVSync(-1)
    example_print_log("adaptive vsync:", lurek.window.getVSync())
end

--@api: lurek.window.getVSync
do
    lurek.window.setVSync(1)
    example_print_log("vsync:", lurek.window.getVSync())
    lurek.window.setVSync(0)
    example_print_log("vsync off:", lurek.window.getVSync())
    lurek.window.setVSync(-1)
    example_print_log("adaptive vsync:", lurek.window.getVSync())
end

--@api: lurek.window.setDisplay
do
    lurek.window.setDisplay(0)
    lurek.window.flash()
    lurek.window.requestAttention()
    example_print_log("display orientation:", lurek.window.getDisplayOrientation())
    example_print_log("system theme:", lurek.window.getSystemTheme())
end

--@api: lurek.window.flash
do
    lurek.window.setDisplay(0)
    lurek.window.flash()
    lurek.window.requestAttention()
    example_print_log("display orientation:", lurek.window.getDisplayOrientation())
    example_print_log("system theme:", lurek.window.getSystemTheme())
end

--@api: lurek.window.requestAttention
do
    lurek.window.setDisplay(0)
    lurek.window.flash()
    lurek.window.requestAttention()
    example_print_log("display orientation:", lurek.window.getDisplayOrientation())
    example_print_log("system theme:", lurek.window.getSystemTheme())
end

--@api: lurek.window.getDisplayOrientation
do
    lurek.window.setDisplay(0)
    lurek.window.flash()
    lurek.window.requestAttention()
    example_print_log("display orientation:", lurek.window.getDisplayOrientation())
    example_print_log("system theme:", lurek.window.getSystemTheme())
end

--@api: lurek.window.getSystemTheme
do
    lurek.window.setDisplay(0)
    lurek.window.flash()
    lurek.window.requestAttention()
    example_print_log("display orientation:", lurek.window.getDisplayOrientation())
    example_print_log("system theme:", lurek.window.getSystemTheme())
end

--@api: lurek.window.showMessageBox
do
    local title = "Save?"
    local message = "Do you want to save before exit?"
    local box_type = "warning"
    local btn_type = "yesno"
    local interactive = lurek.runtime.getEnv("LUREK_RUN_INTERACTIVE_DIALOGS") == "1"
    if interactive then
        local result = lurek.window.showMessageBox(title, message, box_type, btn_type)
        example_print_log("message box result:", result)
    else
        example_print_log("set LUREK_RUN_INTERACTIVE_DIALOGS=1 to run the blocking message box example")
    end
end

--@api: lurek.window.getSafeArea
do
    local sx, sy, sw, sh = lurek.window.getSafeArea()
    local w, h = lurek.window.getDimensions()
    local padding_x = w - sw
    local padding_y = h - sh
    lurek.log.info("safe area = " .. sx .. "," .. sy .. " " .. sw .. "x" .. sh)
    lurek.log.info("outside safe area padding = " .. padding_x .. "x" .. padding_y)
end

--@api: lurek.window.setIcon
do
    lurek.window.setIcon("content/examples/assets/images/sample_icon.png")
    local title = lurek.window.getTitle()
    local w, h = lurek.window.getDimensions()
    lurek.log.info("icon set for window '" .. title .. "'")
    lurek.log.info("window size while setting icon = " .. w .. "x" .. h)
end

--@api: lurek.window.onDpiChange
do
    local last_scale = 0
    lurek.window.onDpiChange(function(scale) last_scale = scale end)
    local currentScale = lurek.window.pollDpiChange()
    local native = lurek.window.getNativeDPIScale()
    lurek.log.info("dpi callback registered, last callback scale = " .. last_scale)
    lurek.log.info("poll scale = " .. currentScale .. " native=" .. native)
end

--@api: lurek.window.pollDpiChange
do
    local callback_hits = 0
    lurek.window.onDpiChange(function(_scale) callback_hits = callback_hits + 1 end)
    local currentScale = lurek.window.pollDpiChange()
    local runtime = lurek.window.getDPIScale()
    local logical = lurek.window.fromPixels(200)
    lurek.log.info("pollDpiChange returned " .. currentScale .. " callback hits=" .. callback_hits)
    lurek.log.info("runtime scale = " .. runtime .. " px200->logical " .. logical)
end

--@api: lurek.window.isHighDPIAllowed
do
    local v = lurek.window.isHighDPIAllowed()
    local runtime = lurek.window.getDPIScale()
    local native = lurek.window.getNativeDPIScale()
    lurek.log.info("high DPI allowed = " .. tostring(v))
    lurek.log.info("runtime/native scale = " .. runtime .. "/" .. native)
end

--- Window Part 2: full lurek.window module + LGuiWindow coverage

--@api: lurek.window.close
do
    -- Call lurek.window.close() to programmatically end the session, e.g. from a Quit button.
    -- Safe to query the function exists before calling it in a headless test context.
    local close_available = type(lurek.window.close) == "function"
    local open = lurek.window.isOpen()
    local title = lurek.window.getTitle()
    lurek.log.info("close available = " .. tostring(close_available))
    lurek.log.info("window '" .. title .. "' open before close request = " .. tostring(open))
end

--@api: LWindow:getTitle
do
    local win = lurek.ui.newWindow("Test Window")
    example_print_log("win_title=" .. win:getTitle())
    win:setTitle("Renamed Window")
    win:setCloseable(true)
    win:setDraggable(false)
    win:setResizable(true)
    win:setOnClose(function() example_print_log("window_closed") end)
    example_print_log("win_title2=" .. win:getTitle() .. " closeable=" .. tostring(win:isCloseable()) .. " draggable=" .. tostring(win:isDraggable()) .. " resizable=" .. tostring(win:isResizable()))
end

--@api: LWindow:getTitle.2
do
    local win = lurek.ui.newWindow("Test Window")
    example_print_log("win_title=" .. win:getTitle())
    win:setTitle("Renamed Window")
    win:setCloseable(true)
    win:setDraggable(false)
    win:setResizable(true)
    win:setOnClose(function() example_print_log("window_closed") end)
    example_print_log("win_title2=" .. win:getTitle() .. " closeable=" .. tostring(win:isCloseable()) .. " draggable=" .. tostring(win:isDraggable()) .. " resizable=" .. tostring(win:isResizable()))
end

--@api: LWindow:getTitle.3
do
    local win = lurek.ui.newWindow("Test Window")
    example_print_log("win_title=" .. win:getTitle())
    win:setTitle("Renamed Window")
    win:setCloseable(true)
    win:setDraggable(false)
    win:setResizable(true)
    win:setOnClose(function() example_print_log("window_closed") end)
    example_print_log("win_title2=" .. win:getTitle() .. " closeable=" .. tostring(win:isCloseable()) .. " draggable=" .. tostring(win:isDraggable()) .. " resizable=" .. tostring(win:isResizable()))
end

--@api: LWindow:getTitle.4
do
    local win = lurek.ui.newWindow("Test Window")
    example_print_log("win_title=" .. win:getTitle())
    win:setTitle("Renamed Window")
    win:setCloseable(true)
    win:setDraggable(false)
    win:setResizable(true)
    win:setOnClose(function() example_print_log("window_closed") end)
    example_print_log("win_title2=" .. win:getTitle() .. " closeable=" .. tostring(win:isCloseable()) .. " draggable=" .. tostring(win:isDraggable()) .. " resizable=" .. tostring(win:isResizable()))
end

--@api: LWindow:getTitle.5
do
    local win = lurek.ui.newWindow("Test Window")
    example_print_log("win_title=" .. win:getTitle())
    win:setTitle("Renamed Window")
    win:setCloseable(true)
    win:setDraggable(false)
    win:setResizable(true)
    win:setOnClose(function() example_print_log("window_closed") end)
    example_print_log("win_title2=" .. win:getTitle() .. " closeable=" .. tostring(win:isCloseable()) .. " draggable=" .. tostring(win:isDraggable()) .. " resizable=" .. tostring(win:isResizable()))
end

--@api: LWindow:getTitle.6
do
    local win = lurek.ui.newWindow("Test Window")
    example_print_log("win_title=" .. win:getTitle())
    win:setTitle("Renamed Window")
    win:setCloseable(true)
    win:setDraggable(false)
    win:setResizable(true)
    win:setOnClose(function() example_print_log("window_closed") end)
    example_print_log("win_title2=" .. win:getTitle() .. " closeable=" .. tostring(win:isCloseable()) .. " draggable=" .. tostring(win:isDraggable()) .. " resizable=" .. tostring(win:isResizable()))
end

--@api: LWindow:getTitle.7
do
    local win = lurek.ui.newWindow("Test Window")
    example_print_log("win_title=" .. win:getTitle())
    win:setTitle("Renamed Window")
    win:setCloseable(true)
    win:setDraggable(false)
    win:setResizable(true)
    win:setOnClose(function() example_print_log("window_closed") end)
    example_print_log("win_title2=" .. win:getTitle() .. " closeable=" .. tostring(win:isCloseable()) .. " draggable=" .. tostring(win:isDraggable()) .. " resizable=" .. tostring(win:isResizable()))
end

--@api: lurek.window.getHeight
do
    local w = lurek.window.getWidth()
    local h = lurek.window.getHeight()
    local focused = lurek.window.hasFocus()
    local ratio = w / h
    lurek.log.info("window size = " .. w .. "x" .. h)
    lurek.log.info("focused=" .. tostring(focused) .. " aspect=" .. string.format("%.3f", ratio))
end

--@api: lurek.window.getWidth
do
    local w = lurek.window.getWidth()
    local h = lurek.window.getHeight()
    local focused = lurek.window.hasFocus()
    local pixel_w, pixel_h = lurek.window.getPixelDimensions()
    lurek.log.info("window width = " .. w .. " height=" .. h)
    lurek.log.info("focused=" .. tostring(focused) .. " pixel size=" .. pixel_w .. "x" .. pixel_h)
end

--@api: lurek.window.openFileDialog
do
    local opts = { title = "Select file", multiple = true }
    local interactive = lurek.runtime.getEnv("LUREK_RUN_INTERACTIVE_DIALOGS") == "1"
    if interactive then
        local files = lurek.window.openFileDialog(opts)
        example_print_log("selected file count:", #files)
        example_print_log("first file:", tostring(files[1]))
    else
        example_print_log("set LUREK_RUN_INTERACTIVE_DIALOGS=1 to run the blocking file dialog example")
        example_print_log("dialog title:", opts.title)
    end
end
