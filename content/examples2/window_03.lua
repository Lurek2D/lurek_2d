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
