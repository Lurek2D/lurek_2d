-- window_00.lua: Window basics — dimensions, title, position, mode, fullscreen

--@api-stub: lurek.window.getDimensions
do
    -- query window width and height
    local w, h = lurek.window.getDimensions()
    print("window dimensions:", w, h)
    print("width:", lurek.window.getWidth())
    print("height:", lurek.window.getHeight())
end

--@api-stub: lurek.window.getTitle setTitle
do
    -- get and set the window title
    lurek.window.setTitle("My Game - Level 1")
    print("title:", lurek.window.getTitle())
    lurek.window.setTitle("My Game - Paused")
    print("updated title:", lurek.window.getTitle())
end

--@api-stub: lurek.window.getPosition setPosition
do
    -- read and set window position on screen
    local x, y = lurek.window.getPosition()
    print("position:", x, y)
    lurek.window.setPosition(100, 100)
    local nx, ny = lurek.window.getPosition()
    print("new position:", nx, ny)
end

--@api-stub: lurek.window.getMode setMode
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

--@api-stub: lurek.window.setFullscreen getFullscreen isFullscreen
do
    -- toggle fullscreen mode
    print("is fullscreen:", lurek.window.isFullscreen())
    print("fullscreen state:", lurek.window.getFullscreen())
    lurek.window.setFullscreen(true, "desktop")
    print("after enable:", lurek.window.isFullscreen())
    lurek.window.setFullscreen(false)
    print("after disable:", lurek.window.isFullscreen())
end

--@api-stub: lurek.window.getPixelDimensions getDPIScale
do
    -- physical pixel dimensions and DPI scale
    local pw, ph = lurek.window.getPixelDimensions()
    print("pixel dimensions:", pw, ph)
    print("DPI scale:", lurek.window.getDPIScale())
    print("native DPI scale:", lurek.window.getNativeDPIScale())
end

--@api-stub: lurek.window.fromPixels toPixels
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

print("window_00.lua")
