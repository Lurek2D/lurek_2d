-- ==========================================================================
-- Lurek2D Example: Cursor
-- ==========================================================================
-- Demonstrates cursor management with system cursors, custom image cursors,
-- animated cursors, trails, context-sensitive switching, and zoom.
-- ==========================================================================

local function cursor_log(message)
    lurek.log.info("[cursor] " .. message)
end

local function make_custom_cursor(size, hotspot)
    local cursor = lurek.cursor.newCustom(size, size, hotspot, hotspot)
    cursor:setPixel(hotspot, hotspot, 255, 255, 255, 255)
    cursor:setPixel(hotspot + 1, hotspot, 0, 200, 255, 255)
    return cursor
end

local function make_animated_cursor()
    local animated = lurek.cursor.newAnimated(true)
    animated:addFrame(make_custom_cursor(16, 2), 16)
    animated:addFrame(make_custom_cursor(16, 3), 16)
    return animated
end

--@api: lurek.cursor.newManager
do
    local manager = lurek.cursor.newManager()
    manager:setContext("default")
    local visible = manager:isVisible()
    local context = manager:getContext()
    cursor_log("manager visible=" .. tostring(visible) .. " context=" .. context)
end

--@api: lurek.cursor.newCustom
do
    local cursor = lurek.cursor.newCustom(16, 16, 2, 2)
    cursor:setPixel(2, 2, 255, 255, 255, 255)
    local w, h = cursor:getSize()
    local hx, hy = cursor:getHotspot()
    cursor_log("custom cursor size=" .. w .. "x" .. h .. " hotspot=" .. hx .. "," .. hy)
end

--@api: lurek.cursor.newAnimated
do
    local animated = lurek.cursor.newAnimated(true)
    animated:addFrame(make_custom_cursor(16, 2), 16)
    local frame_count = animated:frameCount()
    local scale = animated:currentScale()
    cursor_log("animated cursor frames=" .. frame_count .. " scale=" .. scale)
end

--@api: lurek.cursor.systemCursors
do
    local names = lurek.cursor.systemCursors()
    local first = names[1] or "none"
    local second = names[2] or "none"
    local count = #names
    cursor_log("system cursor count=" .. count .. " sample=" .. first .. "," .. second)
end

--@api: LAnimatedCursor:addFrame
do
    local animated = lurek.cursor.newAnimated(true)
    local first = make_custom_cursor(16, 2)
    local second = make_custom_cursor(16, 3)
    animated:addFrame(first, 100)
    animated:addFrame(second, 120)
    cursor_log("animated cursor frame count after addFrame=" .. animated:frameCount())
end

--@api: LAnimatedCursor:update
do
    local animated = make_animated_cursor()
    local before = animated:currentIndex()
    animated:update(0.05)
    local after = animated:currentIndex()
    cursor_log("animated cursor index advanced from " .. before .. " to " .. after)
end

--@api: LAnimatedCursor:currentIndex
do
    local animated = make_animated_cursor()
    animated:update(0.03)
    local index = animated:currentIndex()
    local count = animated:frameCount()
    cursor_log("animated cursor current index=" .. index .. " of " .. count .. " frames")
end

--@api: LAnimatedCursor:frameCount
do
    local animated = lurek.cursor.newAnimated(true)
    animated:addFrame(make_custom_cursor(16, 2), 100)
    animated:addFrame(make_custom_cursor(16, 4), 100)
    local count = animated:frameCount()
    cursor_log("animated cursor frame count=" .. count)
end

--@api: LAnimatedCursor:currentScale
do
    local animated = make_animated_cursor()
    animated:setPulse(0.8, 1.2, 1.5)
    animated:update(0.10)
    local scale = animated:currentScale()
    cursor_log("animated cursor pulse scale=" .. scale)
end

--@api: LAnimatedCursor:setPulse
do
    local animated = make_animated_cursor()
    animated:setPulse(0.8, 1.2, 1.5)
    animated:update(0.10)
    local scale = animated:currentScale()
    cursor_log("pulse configured current scale=" .. scale)
end

--@api: LAnimatedCursor:clearPulse
do
    local animated = make_animated_cursor()
    animated:setPulse(0.8, 1.2, 1.5)
    animated:clearPulse()
    animated:update(0.10)
    cursor_log("pulse cleared scale=" .. animated:currentScale())
end

--@api: LAnimatedCursor:reset
do
    local animated = make_animated_cursor()
    animated:update(0.20)
    local before = animated:currentIndex()
    animated:reset()
    local after = animated:currentIndex()
    cursor_log("animated cursor reset from " .. before .. " to " .. after)
end

--@api: LCursorManager:setSystem
do
    local manager = lurek.cursor.newManager()
    manager:setSystem("arrow")
    manager:setContext("menu")
    local context = manager:getContext()
    cursor_log("system cursor set for context=" .. context)
end

--@api: LCursorManager:setCustom
do
    local manager = lurek.cursor.newManager()
    local cursor = make_custom_cursor(16, 2)
    manager:setCustom(cursor)
    manager:setContext("editor")
    cursor_log("custom cursor active for context=" .. manager:getContext())
end

--@api: LCursorManager:setAnimated
do
    local manager = lurek.cursor.newManager()
    local animated = make_animated_cursor()
    manager:setAnimated(animated)
    manager:setContext("combat")
    cursor_log("animated cursor active for context=" .. manager:getContext())
end

--@api: LCursorManager:setContext
do
    local manager = lurek.cursor.newManager()
    manager:addRule("gameplay", "crosshair")
    manager:setContext("gameplay")
    local context = manager:getContext()
    cursor_log("manager context switched to " .. context)
end

--@api: LCursorManager:addRule
do
    local manager = lurek.cursor.newManager()
    manager:addRule("gameplay", "crosshair")
    manager:addRule("dialogue", "text")
    manager:setContext("dialogue")
    cursor_log("context rule applied for " .. manager:getContext())
end

--@api: LCursorManager:removeRule
do
    local manager = lurek.cursor.newManager()
    manager:addRule("ui", "hand")
    manager:setContext("ui")
    manager:removeRule("ui")
    manager:setContext("default")
    cursor_log("context after removeRule=" .. manager:getContext())
end

--@api: LCursorManager:update
do
    local manager = lurek.cursor.newManager()
    manager:update(320, 180, 0.016)
    local x, y = manager:getPosition()
    local visible = manager:isVisible()
    cursor_log("manager update position=" .. x .. "," .. y .. " visible=" .. tostring(visible))
end

--@api: LCursorManager:setVisible
do
    local manager = lurek.cursor.newManager()
    manager:setVisible(false)
    local hidden = manager:isVisible()
    manager:setVisible(true)
    cursor_log("visibility toggled hidden=" .. tostring(hidden) .. " final=" .. tostring(manager:isVisible()))
end

--@api: LCursorManager:isVisible
do
    local manager = lurek.cursor.newManager()
    local before = manager:isVisible()
    manager:setVisible(false)
    local after = manager:isVisible()
    cursor_log("visibility before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api: LCursorManager:setLocked
do
    local manager = lurek.cursor.newManager()
    manager:setLocked(true)
    local locked = manager:isLocked()
    manager:setLocked(false)
    cursor_log("lock toggled true=" .. tostring(locked) .. " final=" .. tostring(manager:isLocked()))
end

--@api: LCursorManager:isLocked
do
    local manager = lurek.cursor.newManager()
    local before = manager:isLocked()
    manager:setLocked(true)
    local after = manager:isLocked()
    cursor_log("isLocked before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api: LCursorManager:getPosition
do
    local manager = lurek.cursor.newManager()
    manager:update(640, 360, 0.016)
    local x, y = manager:getPosition()
    local context = manager:getContext()
    cursor_log("cursor position x=" .. x .. " y=" .. y .. " context=" .. context)
end

--@api: LCursorManager:getContext
do
    local manager = lurek.cursor.newManager()
    manager:setContext("menu")
    local first = manager:getContext()
    manager:setContext("gameplay")
    cursor_log("context changed from " .. first .. " to " .. manager:getContext())
end

--@api: LCursorManager:enableTrail
do
    local manager = lurek.cursor.newManager()
    manager:enableTrail(1.0, 0.5, 0.0, 0.8)
    manager:update(200, 140, 0.016)
    local x, y = manager:getPosition()
    cursor_log("trail enabled near position=" .. x .. "," .. y)
end

--@api: LCursorManager:enableLineTrail
do
    local manager = lurek.cursor.newManager()
    manager:enableLineTrail(0.0, 1.0, 1.0, 2.0)
    manager:update(220, 160, 0.016)
    local x, y = manager:getPosition()
    cursor_log("line trail enabled near position=" .. x .. "," .. y)
end

--@api: LCursorManager:disableTrail
do
    local manager = lurek.cursor.newManager()
    manager:enableTrail(1.0, 1.0, 1.0, 0.5)
    manager:disableTrail()
    manager:update(200, 120, 0.016)
    cursor_log("trail disabled while cursor remains visible=" .. tostring(manager:isVisible()))
end

--@api: LCursorManager:enableZoom
do
    local manager = lurek.cursor.newManager()
    manager:enableZoom(2.0, 80)
    manager:update(320, 180, 0.016)
    local x, y = manager:getPosition()
    cursor_log("zoom enabled around position=" .. x .. "," .. y)
end

--@api: LCursorManager:disableZoom
do
    local manager = lurek.cursor.newManager()
    manager:enableZoom(1.5, 60)
    manager:disableZoom()
    manager:setContext("default")
    cursor_log("zoom disabled context=" .. manager:getContext())
end

--@api: LCustomCursor:setPixel
do
    local cursor = lurek.cursor.newCustom(16, 16, 0, 0)
    cursor:setPixel(8, 8, 255, 255, 255, 255)
    cursor:setPixel(9, 8, 0, 200, 255, 255)
    local r, g, b, a = cursor:getPixel(8, 8)
    cursor_log("custom pixel set rgba=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LCustomCursor:getPixel
do
    local cursor = lurek.cursor.newCustom(16, 16, 0, 0)
    cursor:setPixel(4, 4, 255, 0, 0, 255)
    local r, g, b, a = cursor:getPixel(4, 4)
    local sample_is_red = r == 255 and g == 0 and b == 0 and a == 255
    cursor_log("sampled pixel rgba=" .. r .. "," .. g .. "," .. b .. "," .. a .. " red=" .. tostring(sample_is_red))
end

--@api: LCustomCursor:getSize
do
    local cursor = lurek.cursor.newCustom(24, 24, 12, 12)
    cursor:setPixel(12, 12, 255, 255, 0, 255)
    local w, h = cursor:getSize()
    local hx, hy = cursor:getHotspot()
    cursor_log("cursor size=" .. w .. "x" .. h .. " hotspot=" .. hx .. "," .. hy)
end

--@api: LCustomCursor:getHotspot
do
    local cursor = lurek.cursor.newCustom(32, 32, 16, 16)
    cursor:setPixel(16, 16, 255, 255, 255, 255)
    local hx, hy = cursor:getHotspot()
    local w, h = cursor:getSize()
    cursor_log("cursor hotspot=" .. hx .. "," .. hy .. " size=" .. w .. "x" .. h)
end
