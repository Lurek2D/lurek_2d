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
--@api-stub: lurek.window.isFullscreen
--@api-stub: lurek.window.isOpen
-- Check mouse focus, fullscreen and open state.
do
    local mfocus = lurek.window.hasMouseFocus()
    local fs = lurek.window.isFullscreen()
    local open = lurek.window.isOpen()
    print("mouse focus:", mfocus, "fullscreen:", fs, "open:", open)
end

--@api-stub: lurek.window.isResizable
--@api-stub: lurek.window.isVisible
--@api-stub: lurek.window.requestAttention
-- Window resizable/visible flags and request attention.
do
    local resizable = lurek.window.isResizable()
    local visible = lurek.window.isVisible()
    lurek.window.requestAttention()
    print("resizable:", resizable, "visible:", visible)
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

--@api-stub: lurek.window.setDisplay
--@api-stub: lurek.window.setPosition
-- Set window display and position.
do
    local displays = lurek.window.getDisplays()
    if displays and #displays > 0 then
        lurek.window.setDisplay(1)
    end
    local x, y = lurek.window.getPosition()
    lurek.window.setPosition(x, y)
    print("window position:", x, y)
end
