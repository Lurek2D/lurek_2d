-- content/examples/window.lua
-- Auto-generated from content/examples2/window_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/window.lua

--@api-stub: lurek.window.getDimensions
do
    local w, h = lurek.window.getDimensions()
    print("window dimensions:", w, h)
end

--@api-stub: lurek.window.setTitle
do
    lurek.window.setTitle("My Game - Level 1")
    print("title:", lurek.window.getTitle())
end

--@api-stub: lurek.window.getTitle
do
    lurek.window.setTitle("My Game - Level 1")
    print("title:", lurek.window.getTitle())
end

--@api-stub: lurek.window.getPosition
do
    local x, y = lurek.window.getPosition()
    print("position:", x, y)
end

--@api-stub: lurek.window.setPosition
do
    lurek.window.setPosition(100, 100)
    local nx, ny = lurek.window.getPosition()
    print("new position:", nx, ny)
end

--@api-stub: lurek.window.getMode
do
    local w, h, flags = lurek.window.getMode()
    print("mode:", w, "x", h)
    print("fullscreen:", flags.fullscreen)
    print("fullscreen type:", flags.fullscreentype, "vsync:", flags.vsync)
end

--@api-stub: lurek.window.setMode
do
    lurek.window.setMode(1280, 720, { fullscreen = false, fullscreentype = "desktop", vsync = 1 })
    local nw, nh, nflags = lurek.window.getMode()
    print("new mode:", nw, "x", nh, "vsync:", nflags.vsync)
end

--@api-stub: lurek.window.isFullscreen
do
    local v = lurek.window.isFullscreen()
    print("is fullscreen:", v)
end

--@api-stub: lurek.window.getFullscreen
do
    local enabled, fsType = lurek.window.getFullscreen()
    print("fullscreen enabled:", enabled)
    print("fullscreen type:", fsType)
end

--@api-stub: lurek.window.setFullscreen
do
    lurek.window.setFullscreen(true, "desktop")
    print("after enable:", lurek.window.isFullscreen())
    lurek.window.setFullscreen(false)
    print("after disable:", lurek.window.isFullscreen())
end

--@api-stub: lurek.window.getPixelDimensions
do
    local pw, ph = lurek.window.getPixelDimensions()
    print("pixel dimensions:", pw, ph)
end

--@api-stub: lurek.window.getDPIScale
do
    local s = lurek.window.getDPIScale()
    print("DPI scale:", s)
end

--@api-stub: lurek.window.getNativeDPIScale
do
    local s = lurek.window.getNativeDPIScale()
    print("native DPI scale:", s)
end

--@api-stub: lurek.window.fromPixels
do
    local logical = lurek.window.fromPixels(200)
    print("200 pixels in logical:", logical)
    local pixels = lurek.window.toPixels(100)
    print("100 logical in pixels:", pixels)
end

--@api-stub: lurek.window.toPixels
do
    local logical = lurek.window.fromPixels(200)
    print("200 pixels in logical:", logical)
    local pixels = lurek.window.toPixels(100)
    print("100 logical in pixels:", pixels)
end

--@api-stub: lurek.window.windowConfig
do
    lurek.window.windowConfig({ title = "Configured Window", width = 1024, height = 768, fullscreen = false, vsync = 1, scaleMode = "letterbox" })
    print("title after config:", lurek.window.getTitle())
    print("dimensions after config:", lurek.window.getDimensions())
end

--@api-stub: lurek.window.getDisplayCount
do
    local count = lurek.window.getDisplayCount()
    print("display count:", count)
    local current = lurek.window.getCurrentDisplay()
    print("current display index:", current)
    local name = lurek.window.getDisplayName(current)
    print("display name:", name)
end

--@api-stub: lurek.window.getCurrentDisplay
do
    local count = lurek.window.getDisplayCount()
    print("display count:", count)
    local current = lurek.window.getCurrentDisplay()
    print("current display index:", current)
    local name = lurek.window.getDisplayName(current)
    print("display name:", name)
end

--@api-stub: lurek.window.getDisplayName
do
    local count = lurek.window.getDisplayCount()
    print("display count:", count)
    local current = lurek.window.getCurrentDisplay()
    print("current display index:", current)
    local name = lurek.window.getDisplayName(current)
    print("display name:", name)
end

--@api-stub: lurek.window.getDesktopDimensions
do
    local dw, dh = lurek.window.getDesktopDimensions()
    print("desktop resolution:", dw, dh)
    local displays = lurek.window.getDisplays()
    local d = displays[1] or { index = -1, name = "none", width = 0, height = 0, scale = 0 }
    print("display", d.index, d.name, d.width .. "x" .. d.height, "scale:", d.scale)
end

--@api-stub: lurek.window.getDisplays
do
    local dw, dh = lurek.window.getDesktopDimensions()
    print("desktop resolution:", dw, dh)
    local displays = lurek.window.getDisplays()
    local d = displays[1] or { index = -1, name = "none", width = 0, height = 0, scale = 0 }
    print("display", d.index, d.name, d.width .. "x" .. d.height, "scale:", d.scale)
end

--@api-stub: lurek.window.getFullscreenModes
do
    local modes = lurek.window.getFullscreenModes()
    print("fullscreen modes available:", #modes)
    local m = modes[1] or { width = 0, height = 0, refreshRate = 0 }
    print("first mode:", m.width .. "x" .. m.height, "@", m.refreshRate, "Hz")
end

--@api-stub: lurek.window.setScaleMode
do
    lurek.window.setScaleMode("letterbox")
    print("scale mode:", lurek.window.getScaleMode())
    local info = lurek.window.getScaleInfo()
    print("scale:", info.scale_x, info.scale_y, "offset:", info.offset_x, info.offset_y, "game:", info.game_width, info.game_height)
end

--@api-stub: lurek.window.getScaleMode
do
    lurek.window.setScaleMode("letterbox")
    print("scale mode:", lurek.window.getScaleMode())
    local info = lurek.window.getScaleInfo()
    print("scale:", info.scale_x, info.scale_y, "offset:", info.offset_x, info.offset_y, "game:", info.game_width, info.game_height)
end

--@api-stub: lurek.window.getScaleInfo
do
    lurek.window.setScaleMode("letterbox")
    print("scale mode:", lurek.window.getScaleMode())
    local info = lurek.window.getScaleInfo()
    print("scale:", info.scale_x, info.scale_y, "offset:", info.offset_x, info.offset_y, "game:", info.game_width, info.game_height)
end

--@api-stub: lurek.window.getGameWidth
do
    print("game width:", lurek.window.getGameWidth())
    print("game height:", lurek.window.getGameHeight())
end

--@api-stub: lurek.window.getGameHeight
do
    print("game width:", lurek.window.getGameWidth())
    print("game height:", lurek.window.getGameHeight())
end

--@api-stub: lurek.window.hasFocus
do
    print("before focus = " .. tostring(lurek.window.hasFocus()))
    lurek.window.focus()
    print("after focus = " .. tostring(lurek.window.hasFocus()))
end

--@api-stub: lurek.window.hasMouseFocus
do
    local v = lurek.window.hasMouseFocus()
    print("mouse focus = " .. tostring(v))
end

--@api-stub: lurek.window.focus
do
    print("before focus = " .. tostring(lurek.window.hasFocus()))
    lurek.window.focus()
    print("after focus = " .. tostring(lurek.window.hasFocus()))
end

--@api-stub: lurek.window.isOpen
do
    print("is open:", lurek.window.isOpen())
    print("visible/resizable/maximized/minimized:", lurek.window.isVisible(), lurek.window.isResizable(), lurek.window.isMaximized(), lurek.window.isMinimized())
end

--@api-stub: lurek.window.isVisible
do
    print("is visible:", lurek.window.isVisible())
    print("open/resizable/maximized/minimized:", lurek.window.isOpen(), lurek.window.isResizable(), lurek.window.isMaximized(), lurek.window.isMinimized())
end

--@api-stub: lurek.window.isResizable
do
    print("is resizable:", lurek.window.isResizable())
    print("open/visible/maximized/minimized:", lurek.window.isOpen(), lurek.window.isVisible(), lurek.window.isMaximized(), lurek.window.isMinimized())
end

--@api-stub: lurek.window.isMaximized
do
    lurek.window.maximize()
    print("is maximized = " .. tostring(lurek.window.isMaximized()))
    lurek.window.restore()
end

--@api-stub: lurek.window.isMinimized
do
    lurek.window.minimize()
    print("is minimized = " .. tostring(lurek.window.isMinimized()))
    lurek.window.restore()
end

--@api-stub: lurek.window.maximize
do
    lurek.window.maximize()
    print("maximized:", lurek.window.isMaximized())
    lurek.window.restore()
    print("after restore:", lurek.window.isMaximized())
    lurek.window.minimize()
    print("minimized:", lurek.window.isMinimized())
    lurek.window.restore()
end

--@api-stub: lurek.window.restore
do
    lurek.window.maximize()
    print("maximized:", lurek.window.isMaximized())
    lurek.window.restore()
    print("after restore:", lurek.window.isMaximized())
    lurek.window.minimize()
    print("minimized:", lurek.window.isMinimized())
    lurek.window.restore()
end

--@api-stub: lurek.window.minimize
do
    lurek.window.maximize()
    print("maximized:", lurek.window.isMaximized())
    lurek.window.restore()
    print("after restore:", lurek.window.isMaximized())
    lurek.window.minimize()
    print("minimized:", lurek.window.isMinimized())
    lurek.window.restore()
end

--@api-stub: lurek.window.setVSync
do
    lurek.window.setVSync(1)
    print("vsync:", lurek.window.getVSync())
    lurek.window.setVSync(0)
    print("vsync off:", lurek.window.getVSync())
    lurek.window.setVSync(-1)
    print("adaptive vsync:", lurek.window.getVSync())
end

--@api-stub: lurek.window.getVSync
do
    lurek.window.setVSync(1)
    print("vsync:", lurek.window.getVSync())
    lurek.window.setVSync(0)
    print("vsync off:", lurek.window.getVSync())
    lurek.window.setVSync(-1)
    print("adaptive vsync:", lurek.window.getVSync())
end

--@api-stub: lurek.window.setDisplay
do
    lurek.window.setDisplay(0)
    lurek.window.flash()
    lurek.window.requestAttention()
    print("display orientation:", lurek.window.getDisplayOrientation())
    print("system theme:", lurek.window.getSystemTheme())
end

--@api-stub: lurek.window.flash
do
    lurek.window.setDisplay(0)
    lurek.window.flash()
    lurek.window.requestAttention()
    print("display orientation:", lurek.window.getDisplayOrientation())
    print("system theme:", lurek.window.getSystemTheme())
end

--@api-stub: lurek.window.requestAttention
do
    lurek.window.setDisplay(0)
    lurek.window.flash()
    lurek.window.requestAttention()
    print("display orientation:", lurek.window.getDisplayOrientation())
    print("system theme:", lurek.window.getSystemTheme())
end

--@api-stub: lurek.window.getDisplayOrientation
do
    lurek.window.setDisplay(0)
    lurek.window.flash()
    lurek.window.requestAttention()
    print("display orientation:", lurek.window.getDisplayOrientation())
    print("system theme:", lurek.window.getSystemTheme())
end

--@api-stub: lurek.window.getSystemTheme
do
    lurek.window.setDisplay(0)
    lurek.window.flash()
    lurek.window.requestAttention()
    print("display orientation:", lurek.window.getDisplayOrientation())
    print("system theme:", lurek.window.getSystemTheme())
end

--@api-stub: lurek.window.showMessageBox
do
    local title = "Save?"
    local message = "Do you want to save before exit?"
    local box_type = "warning"
    local btn_type = "yesno"
    local result = lurek.window.showMessageBox(title, message, box_type, btn_type)
    print("message box result:", result)
end

--@api-stub: lurek.window.getSafeArea
do
    local sx, sy, sw, sh = lurek.window.getSafeArea()
    print("safe area:", sx, sy, sw, sh)
end

--@api-stub: lurek.window.setIcon
do
    lurek.window.setIcon("content/examples/assets/images/sample_icon.png")
    print("icon set")
end

--@api-stub: lurek.window.onDpiChange
do
    lurek.window.onDpiChange(function(scale) print("dpi changed:", scale) end)
    local currentScale = lurek.window.pollDpiChange()
    print("current dpi scale:", currentScale)
end

--@api-stub: lurek.window.pollDpiChange
do
    lurek.window.onDpiChange(function(scale) print("dpi changed:", scale) end)
    local currentScale = lurek.window.pollDpiChange()
    print("current dpi scale:", currentScale)
end

--@api-stub: lurek.window.isHighDPIAllowed
do
    local v = lurek.window.isHighDPIAllowed()
    print("high DPI allowed:", v)
end

--- Window Part 2: full lurek.window module + LGuiWindow coverage

--@api-stub: lurek.window.close
do
    -- Call lurek.window.close() to programmatically end the session, e.g. from a Quit button.
    -- Safe to query the function exists before calling it in a headless test context.
    print("close available = " .. tostring(type(lurek.window.close) == "function"))
end

--@api-stub: LWindow:getTitle
do
    local win = lurek.ui.newWindow("Test Window")
    print("win_title=" .. win:getTitle())
    win:setTitle("Renamed Window")
    win:setCloseable(true)
    win:setDraggable(false)
    win:setResizable(true)
    win:setOnClose(function() print("window_closed") end)
    print("win_title2=" .. win:getTitle() .. " closeable=" .. tostring(win:isCloseable()) .. " draggable=" .. tostring(win:isDraggable()) .. " resizable=" .. tostring(win:isResizable()))
end

--@api-stub: LWindow:getTitle.2
do
    local win = lurek.ui.newWindow("Test Window")
    print("win_title=" .. win:getTitle())
    win:setTitle("Renamed Window")
    win:setCloseable(true)
    win:setDraggable(false)
    win:setResizable(true)
    win:setOnClose(function() print("window_closed") end)
    print("win_title2=" .. win:getTitle() .. " closeable=" .. tostring(win:isCloseable()) .. " draggable=" .. tostring(win:isDraggable()) .. " resizable=" .. tostring(win:isResizable()))
end

--@api-stub: LWindow:getTitle.3
do
    local win = lurek.ui.newWindow("Test Window")
    print("win_title=" .. win:getTitle())
    win:setTitle("Renamed Window")
    win:setCloseable(true)
    win:setDraggable(false)
    win:setResizable(true)
    win:setOnClose(function() print("window_closed") end)
    print("win_title2=" .. win:getTitle() .. " closeable=" .. tostring(win:isCloseable()) .. " draggable=" .. tostring(win:isDraggable()) .. " resizable=" .. tostring(win:isResizable()))
end

--@api-stub: LWindow:getTitle.4
do
    local win = lurek.ui.newWindow("Test Window")
    print("win_title=" .. win:getTitle())
    win:setTitle("Renamed Window")
    win:setCloseable(true)
    win:setDraggable(false)
    win:setResizable(true)
    win:setOnClose(function() print("window_closed") end)
    print("win_title2=" .. win:getTitle() .. " closeable=" .. tostring(win:isCloseable()) .. " draggable=" .. tostring(win:isDraggable()) .. " resizable=" .. tostring(win:isResizable()))
end

--@api-stub: LWindow:getTitle.5
do
    local win = lurek.ui.newWindow("Test Window")
    print("win_title=" .. win:getTitle())
    win:setTitle("Renamed Window")
    win:setCloseable(true)
    win:setDraggable(false)
    win:setResizable(true)
    win:setOnClose(function() print("window_closed") end)
    print("win_title2=" .. win:getTitle() .. " closeable=" .. tostring(win:isCloseable()) .. " draggable=" .. tostring(win:isDraggable()) .. " resizable=" .. tostring(win:isResizable()))
end

--@api-stub: LWindow:getTitle.6
do
    local win = lurek.ui.newWindow("Test Window")
    print("win_title=" .. win:getTitle())
    win:setTitle("Renamed Window")
    win:setCloseable(true)
    win:setDraggable(false)
    win:setResizable(true)
    win:setOnClose(function() print("window_closed") end)
    print("win_title2=" .. win:getTitle() .. " closeable=" .. tostring(win:isCloseable()) .. " draggable=" .. tostring(win:isDraggable()) .. " resizable=" .. tostring(win:isResizable()))
end

--@api-stub: LWindow:getTitle.7
do
    local win = lurek.ui.newWindow("Test Window")
    print("win_title=" .. win:getTitle())
    win:setTitle("Renamed Window")
    win:setCloseable(true)
    win:setDraggable(false)
    win:setResizable(true)
    win:setOnClose(function() print("window_closed") end)
    print("win_title2=" .. win:getTitle() .. " closeable=" .. tostring(win:isCloseable()) .. " draggable=" .. tostring(win:isDraggable()) .. " resizable=" .. tostring(win:isResizable()))
end

--@api-stub: lurek.window.getHeight
do
    local w = lurek.window.getWidth()
    local h = lurek.window.getHeight()
    local focused = lurek.window.hasFocus()
    print("window size:", w, h, "focused:", focused)
end

--@api-stub: lurek.window.getWidth
do
    local w = lurek.window.getWidth()
    local h = lurek.window.getHeight()
    local focused = lurek.window.hasFocus()
    print("window size:", w, h, "focused:", focused)
end

--@api-stub: lurek.window.openFileDialog
do
    local files = lurek.window.openFileDialog({ title = "Select file", multiple = true })
    print("selected file count:", #files)
    print("first file:", tostring(files[1]))
end
