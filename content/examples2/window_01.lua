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

print("window_01.lua")
