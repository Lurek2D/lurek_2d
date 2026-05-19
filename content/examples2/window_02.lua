--- Window Part 2: full lurek.window module + LGuiWindow coverage

--@api-stub: lurek.window.close
--@api-stub: lurek.window.flash
--@api-stub: lurek.window.focus
--@api-stub: lurek.window.fromPixels
--@api-stub: lurek.window.getCurrentDisplay
--@api-stub: lurek.window.getDPIScale
--@api-stub: lurek.window.getDesktopDimensions
--@api-stub: lurek.window.getDisplayCount
--@api-stub: lurek.window.getDisplayName
--@api-stub: lurek.window.getDisplayOrientation
--@api-stub: lurek.window.getDisplays
--@api-stub: lurek.window.getFullscreen
--@api-stub: lurek.window.getGameHeight
--@api-stub: lurek.window.getGameWidth
--@api-stub: lurek.window.getMode
--@api-stub: lurek.window.getNativeDPIScale
--@api-stub: lurek.window.getPixelDimensions
--@api-stub: lurek.window.getPosition
--@api-stub: lurek.window.getScaleInfo
--@api-stub: lurek.window.getScaleMode
--@api-stub: lurek.window.getSystemTheme
--@api-stub: lurek.window.getTitle
--@api-stub: lurek.window.getVSync
--@api-stub: lurek.window.isMaximized
--@api-stub: lurek.window.isMinimized
--@api-stub: lurek.window.maximize
--@api-stub: lurek.window.minimize
--@api-stub: lurek.window.restore
--@api-stub: lurek.window.setFullscreen
--@api-stub: lurek.window.setMode
--@api-stub: lurek.window.setScaleMode
--@api-stub: lurek.window.setTitle
--@api-stub: lurek.window.setVSync
--@api-stub: lurek.window.toPixels
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

print("window_02.lua")
