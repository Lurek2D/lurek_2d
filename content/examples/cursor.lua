-- ==========================================================================
-- Lurek2D Example: Cursor
-- ==========================================================================
-- Demonstrates cursor management with system cursors, custom image cursors,
-- animated cursors, trails, context-sensitive switching, and zoom.
--
-- Topics: cursor manager, custom cursors, animation, trails, zoom.
-- ==========================================================================

-- Create a cursor manager
--@api-stub: lurek.cursor.newManager
do
    local cm = lurek.cursor.newManager()
    print("manager visible = " .. tostring(cm:isVisible()))
    print("manager context = " .. cm:getContext())
end

--@api-stub: lurek.cursor.newCustom
do
    local c = lurek.cursor.newCustom(16, 16, 0, 0)
    local w, h = c:getSize()
    print("custom cursor size = " .. w .. "x" .. h)
    print("hotspot = 0,0")
end

--@api-stub: lurek.cursor.newAnimated
do
    local c = lurek.cursor.newAnimated(true)
    print("animated frame count = " .. c:frameCount())
    print("animated scale = " .. c:currentScale())
end

--@api-stub: lurek.cursor.systemCursors
do
    local list = lurek.cursor.systemCursors()
    print("lurek.cursor.systemCursors count=" .. #list)
end

--@api-stub: LAnimatedCursor:addFrame
do
    local c = lurek.cursor.newAnimated(true)
    local frame = lurek.cursor.newCustom(16, 16, 0, 0)
    c:addFrame(frame, 100)
    print("LAnimatedCursor:addFrame count=" .. c:frameCount())
end

--@api-stub: LAnimatedCursor:update
do
    local c = lurek.cursor.newAnimated(true)
    local frame = lurek.cursor.newCustom(16, 16, 0, 0)
    c:addFrame(frame, 100)
    c:update(0.05)
    print("LAnimatedCursor:update idx=" .. c:currentIndex())
end

--@api-stub: LAnimatedCursor:currentIndex
do
    local c = lurek.cursor.newAnimated(true)
    print("LAnimatedCursor:currentIndex=" .. c:currentIndex())
end

--@api-stub: LAnimatedCursor:frameCount
do
    local c = lurek.cursor.newAnimated(true)
    c:addFrame(lurek.cursor.newCustom(16, 16, 0, 0), 100)
    c:addFrame(lurek.cursor.newCustom(16, 16, 0, 0), 100)
    print("LAnimatedCursor:frameCount=" .. c:frameCount())
end

--@api-stub: LAnimatedCursor:currentScale
do
    local c = lurek.cursor.newAnimated(true)
    print("LAnimatedCursor:currentScale=" .. c:currentScale())
end

--@api-stub: LAnimatedCursor:setPulse
do
    local c = lurek.cursor.newAnimated(true)
    c:setPulse(0.8, 1.2, 1.5)
    print("LAnimatedCursor:setPulse scale=" .. c:currentScale())
end

--@api-stub: LAnimatedCursor:clearPulse
do
    local c = lurek.cursor.newAnimated(true)
    c:setPulse(0.8, 1.2, 1.5)
    c:clearPulse()
    print("LAnimatedCursor:clearPulse scale=" .. c:currentScale())
end

--@api-stub: LAnimatedCursor:reset
do
    local c = lurek.cursor.newAnimated(true)
    c:addFrame(lurek.cursor.newCustom(16, 16, 0, 0), 100)
    c:update(0.2)
    c:reset()
    print("LAnimatedCursor:reset idx=" .. c:currentIndex())
end

--@api-stub: LCursorManager:setSystem
do
    local cm = lurek.cursor.newManager()
    cm:setSystem("arrow")
    print("LCursorManager:setSystem ok")
end

--@api-stub: LCursorManager:setCustom
do
    local cm = lurek.cursor.newManager()
    local c = lurek.cursor.newCustom(16, 16, 0, 0)
    cm:setCustom(c)
    print("LCursorManager:setCustom ok")
end

--@api-stub: LCursorManager:setAnimated
do
    local cm = lurek.cursor.newManager()
    local c = lurek.cursor.newAnimated(true)
    cm:setAnimated(c)
    print("LCursorManager:setAnimated ok")
end

--@api-stub: LCursorManager:setContext
do
    local cm = lurek.cursor.newManager()
    cm:setContext("gameplay")
    print("LCursorManager:setContext=" .. cm:getContext())
end

--@api-stub: LCursorManager:addRule
do
    local cm = lurek.cursor.newManager()
    cm:addRule("gameplay", "crosshair")
    cm:setContext("gameplay")
    print("LCursorManager:addRule ok")
    print("context = " .. cm:getContext())
end

--@api-stub: LCursorManager:removeRule
do
    local cm = lurek.cursor.newManager()
    cm:addRule("ui", "hand")
    cm:removeRule("ui")
    print("LCursorManager:removeRule ok")
end

--@api-stub: LCursorManager:update
do
    local cm = lurek.cursor.newManager()
    cm:update(320, 180, 0.016)
    local x, y = cm:getPosition()
    print("LCursorManager:update ok")
    print("position = " .. x .. ", " .. y)
end

--@api-stub: LCursorManager:setVisible
do
    local cm = lurek.cursor.newManager()
    cm:setVisible(true)
    print("LCursorManager:setVisible=" .. tostring(cm:isVisible()))
end

--@api-stub: LCursorManager:isVisible
do
    local cm = lurek.cursor.newManager()
    cm:setVisible(false)
    print("LCursorManager:isVisible=" .. tostring(cm:isVisible()))
end

--@api-stub: LCursorManager:setLocked
do
    local cm = lurek.cursor.newManager()
    cm:setLocked(true)
    print("LCursorManager:setLocked=" .. tostring(cm:isLocked()))
end

--@api-stub: LCursorManager:isLocked
do
    local cm = lurek.cursor.newManager()
    cm:setLocked(false)
    print("LCursorManager:isLocked=" .. tostring(cm:isLocked()))
end

--@api-stub: LCursorManager:getPosition
do
    local cm = lurek.cursor.newManager()
    local x, y = cm:getPosition()
    print("LCursorManager:getPosition x=" .. x .. " y=" .. y)
end

--@api-stub: LCursorManager:getContext
do
    local cm = lurek.cursor.newManager()
    cm:setContext("menu")
    print("LCursorManager:getContext=" .. cm:getContext())
end

--@api-stub: LCursorManager:enableTrail
do
    local cm = lurek.cursor.newManager()
    cm:enableTrail(1.0, 0.5, 0.0, 0.8)
    print("LCursorManager:enableTrail ok")
    print("visible = " .. tostring(cm:isVisible()))
end

--@api-stub: LCursorManager:enableLineTrail
do
    local cm = lurek.cursor.newManager()
    cm:enableLineTrail(0.0, 1.0, 1.0, 2.0)
    print("LCursorManager:enableLineTrail ok")
    print("locked = " .. tostring(cm:isLocked()))
end

--@api-stub: LCursorManager:disableTrail
do
    local cm = lurek.cursor.newManager()
    cm:enableTrail(1.0, 1.0, 1.0, 0.5)
    cm:disableTrail()
    print("LCursorManager:disableTrail ok")
end

--@api-stub: LCursorManager:enableZoom
do
    local cm = lurek.cursor.newManager()
    cm:enableZoom(2.0, 80)
    print("LCursorManager:enableZoom ok")
    print("context = " .. cm:getContext())
end

--@api-stub: LCursorManager:disableZoom
do
    local cm = lurek.cursor.newManager()
    cm:enableZoom(1.5, 60)
    cm:disableZoom()
    print("LCursorManager:disableZoom ok")
end

--@api-stub: LCustomCursor:setPixel
do
    local c = lurek.cursor.newCustom(16, 16, 0, 0)
    c:setPixel(8, 8, 255, 255, 255, 255)
    print("LCustomCursor:setPixel ok")
end

--@api-stub: LCustomCursor:getPixel
do
    local c = lurek.cursor.newCustom(16, 16, 0, 0)
    c:setPixel(4, 4, 255, 0, 0, 255)
    local r, g, b, a = c:getPixel(4, 4)
    print("LCustomCursor:getPixel r=" .. r)
    print("pixel rgba = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LCustomCursor:getSize
do
    local c = lurek.cursor.newCustom(24, 24, 12, 12)
    local w, h = c:getSize()
    print("LCustomCursor:getSize=" .. w .. "x" .. h)
end

--@api-stub: LCustomCursor:getHotspot
do
    local c = lurek.cursor.newCustom(32, 32, 16, 16)
    local hx, hy = c:getHotspot()
    print("LCustomCursor:getHotspot hx=" .. hx .. " hy=" .. hy)
end
