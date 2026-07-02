-- ==========================================================================
-- Lurek2D Example: Cursor
-- ==========================================================================
-- Demonstrates cursor management with system cursors, custom image cursors,
-- animated cursors, trails, context-sensitive switching, and zoom.
-- ==========================================================================




--@api: lurek.cursor.newManager
do

    local manager = lurek.cursor.newManager()
    manager:setContext("default")
    local visible = manager:isVisible()
    local context = manager:getContext()
    lurek.log.info("manager visible=" .. tostring(visible) .. " context=" .. context)
end

--@api: lurek.cursor.newCustom
do

    local cursor = lurek.cursor.newCustom(16, 16, 2, 2)
    cursor:setPixel(2, 2, 255, 255, 255, 255)
    local w, h = cursor:getSize()
    local hx, hy = cursor:getHotspot()
    lurek.log.info("custom cursor size=" .. w .. "x" .. h .. " hotspot=" .. hx .. "," .. hy)
end

--@api: lurek.cursor.newAnimated
do

    local animated = lurek.cursor.newAnimated(true)
    animated:addFrame(lurek.cursor.newCustom(16, 16, 2, 2), 16)
    local frame_count = animated:frameCount()
    local scale = animated:currentScale()
    lurek.log.info("animated cursor frames=" .. frame_count .. " scale=" .. scale)
end

--@api: lurek.cursor.systemCursors
do

    local names = lurek.cursor.systemCursors()
    local first = names[1] or "none"
    local second = names[2] or "none"
    local count = #names
    lurek.log.info("system cursor count=" .. count .. " sample=" .. first .. "," .. second)
end

--@api: LAnimatedCursor:addFrame
do

    local animated = lurek.cursor.newAnimated(true)
    local first = lurek.cursor.newCustom(16, 16, 2, 2)
    local second = lurek.cursor.newCustom(16, 16, 3, 3)
    animated:addFrame(first, 100)
    animated:addFrame(second, 120)
    lurek.log.info("animated cursor frame count after addFrame=" .. animated:frameCount())
end

--@api: LAnimatedCursor:update
do

    local animated = lurek.cursor.newAnimated(true)
    animated:addFrame(lurek.cursor.newCustom(16, 16, 2, 2), 16)
    animated:addFrame(lurek.cursor.newCustom(16, 16, 3, 3), 16)
    local before = animated:currentIndex()
    animated:update(0.05)
    local after = animated:currentIndex()
    lurek.log.info("animated cursor index advanced from " .. before .. " to " .. after)
end

--@api: LAnimatedCursor:currentIndex
do

    local animated = lurek.cursor.newAnimated(true)
    animated:addFrame(lurek.cursor.newCustom(16, 16, 2, 2), 16)
    animated:addFrame(lurek.cursor.newCustom(16, 16, 3, 3), 16)
    animated:update(0.03)
    local index = animated:currentIndex()
    local count = animated:frameCount()
    lurek.log.info("animated cursor current index=" .. index .. " of " .. count .. " frames")
end

--@api: LAnimatedCursor:frameCount
do

    local animated = lurek.cursor.newAnimated(true)
    animated:addFrame(lurek.cursor.newCustom(16, 16, 2, 2), 100)
    animated:addFrame(lurek.cursor.newCustom(16, 16, 4, 4), 100)
    local count = animated:frameCount()
    lurek.log.info("animated cursor frame count=" .. count)
end

--@api: LAnimatedCursor:currentScale
do

    local animated = lurek.cursor.newAnimated(true)
    animated:addFrame(lurek.cursor.newCustom(16, 16, 2, 2), 16)
    animated:addFrame(lurek.cursor.newCustom(16, 16, 3, 3), 16)
    animated:setPulse(0.8, 1.2, 1.5)
    animated:update(0.10)
    local scale = animated:currentScale()
    lurek.log.info("animated cursor pulse scale=" .. scale)
end

--@api: LAnimatedCursor:setPulse
do

    local animated = lurek.cursor.newAnimated(true)
    animated:addFrame(lurek.cursor.newCustom(16, 16, 2, 2), 16)
    animated:addFrame(lurek.cursor.newCustom(16, 16, 3, 3), 16)
    animated:setPulse(0.8, 1.2, 1.5)
    animated:update(0.10)
    local scale = animated:currentScale()
    lurek.log.info("pulse configured current scale=" .. scale)
end

--@api: LAnimatedCursor:clearPulse
do

    local animated = lurek.cursor.newAnimated(true)
    animated:addFrame(lurek.cursor.newCustom(16, 16, 2, 2), 16)
    animated:addFrame(lurek.cursor.newCustom(16, 16, 3, 3), 16)
    animated:setPulse(0.8, 1.2, 1.5)
    animated:clearPulse()
    animated:update(0.10)
    lurek.log.info("pulse cleared scale=" .. animated:currentScale())
end

--@api: LAnimatedCursor:reset
do

    local animated = lurek.cursor.newAnimated(true)
    animated:addFrame(lurek.cursor.newCustom(16, 16, 2, 2), 16)
    animated:addFrame(lurek.cursor.newCustom(16, 16, 3, 3), 16)
    animated:update(0.20)
    local before = animated:currentIndex()
    animated:reset()
    local after = animated:currentIndex()
    lurek.log.info("animated cursor reset from " .. before .. " to " .. after)
end

--@api: LCursorManager:setSystem
do

    local manager = lurek.cursor.newManager()
    manager:setSystem("arrow")
    manager:setContext("menu")
    local context = manager:getContext()
    lurek.log.info("system cursor set for context=" .. context)
end

--@api: LCursorManager:setCustom
do

    local manager = lurek.cursor.newManager()
    local cursor = lurek.cursor.newCustom(16, 16, 2, 2)
    manager:setCustom(cursor)
    manager:setContext("editor")
    lurek.log.info("custom cursor active for context=" .. manager:getContext())
end

--@api: LCursorManager:setAnimated
do

    local manager = lurek.cursor.newManager()
    local animated = lurek.cursor.newAnimated(true)
    animated:addFrame(lurek.cursor.newCustom(16, 16, 2, 2), 16)
    animated:addFrame(lurek.cursor.newCustom(16, 16, 3, 3), 16)
    manager:setAnimated(animated)
    manager:setContext("combat")
    lurek.log.info("animated cursor active for context=" .. manager:getContext())
end

--@api: LCursorManager:setContext
do

    local manager = lurek.cursor.newManager()
    manager:addRule("gameplay", "crosshair")
    manager:setContext("gameplay")
    local context = manager:getContext()
    lurek.log.info("manager context switched to " .. context)
end

--@api: LCursorManager:defineState
do

    local manager = lurek.cursor.newManager()
    manager:defineState("inspect", {
        system = "crosshair",
        scale = 1.2,
        offset_x = 1,
        offset_y = -1,
        trail = {
            mode = "ribbon",
            width = 6,
            lifetime = 0.35,
        },
        zoom = {
            magnification = 2.25,
            radius = 44,
        },
    })
    manager:defineState("paint", {
        custom = lurek.cursor.newCustom(16, 16, 2, 2),
        native_preferred = false,
    })
    local preview = manager:getActiveState()
    lurek.log.info("defined cursor states inspect and paint")
    lurek.log.info("preview cursor kind = " .. preview.kind)
end

--@api: LCursorManager:defineEffect
do

    local manager = lurek.cursor.newManager()
    manager:defineEffect("click_spark", {
        shape = "ring",
        count = 10,
        spread = math.pi,
        lifetime = 0.18,
        speed = 96,
        size = 5,
        button = 0,
    })
    lurek.log.info("defined click_spark cursor effect")
end

--@api: LCursorManager:addRule
do

    local manager = lurek.cursor.newManager()
    manager:defineState("inspect", { system = "crosshair" })
    local id = manager:addRule({
        priority = 25,
        event = "context",
        context = "ui_button",
        state = "inspect",
    })
    manager:setContext("ui_button")
    local state = manager:getActiveState()
    lurek.log.info("v2 cursor rule id = " .. id)
    lurek.log.info("v2 cursor rule state kind = " .. state.kind)
end

--@api: LCursorManager:addSource
do

    local manager = lurek.cursor.newManager()
    local id = manager:addSource({
        kind = "callback",
        callback = function(x, y)
            return {
                module = "example",
                kind = "hover",
                surface = "surface",
                id = string.format("%.0f:%.0f", x, y),
                attrs = {
                    cursor_state = "inspect",
                },
            }
        end,
    })
    lurek.log.info("cursor source id = " .. id)
end

--@api: LCursorManager:removeSource
do

    local manager = lurek.cursor.newManager()
    local id = manager:addSource({
        kind = "callback",
        callback = function()
            return nil
        end,
    })
    local removed = manager:removeSource(id)
    lurek.log.info("cursor source removed = " .. tostring(removed))
end

--@api: LCursorManager:getLastHit
do

    local manager = lurek.cursor.newManager()
    manager:addSource({
        kind = "callback",
        callback = function()
            return {
                module = "example",
                kind = "marker",
                surface = "surface",
                id = "hover-01",
            }
        end,
    })
    manager:update(48, 64, 0.016)
    local hit = manager:getLastHit()
    lurek.log.info("cursor last hit exists = " .. tostring(hit ~= nil))
    lurek.log.info("cursor last hit kind = " .. tostring(hit and hit.kind))
    lurek.log.info("cursor last hit id = " .. tostring(hit and hit.id))
end

--@api: LCursorManager:getActiveState
do

    local manager = lurek.cursor.newManager()
    manager:setSystem("hand")
    manager:setContext("example_active_state")
    local state = manager:getActiveState()
    lurek.log.info("active cursor kind = " .. state.kind)
    lurek.log.info("active cursor prefers native = " .. tostring(state.native_preferred))
    lurek.log.info("active cursor scale = " .. tostring(state.scale))
end

--@api: LCursorManager:type
do

    local manager = lurek.cursor.newManager()
    local manager_type = manager:type()
    local x, y = manager:getPosition()
    local visible = manager:isVisible()
    lurek.log.info("cursor manager type = " .. manager_type)
    lurek.log.info("cursor manager position = " .. x .. "," .. y)
    lurek.log.info("cursor manager visible = " .. tostring(visible))
end

--@api: LCursorManager:removeRule
do

    local manager = lurek.cursor.newManager()
    manager:addRule("ui", "hand")
    manager:setContext("ui")
    manager:removeRule("ui")
    manager:setContext("default")
    lurek.log.info("context after removeRule=" .. manager:getContext())
end

--@api: LCursorManager:update
do

    local manager = lurek.cursor.newManager()
    manager:update(320, 180, 0.016)
    local x, y = manager:getPosition()
    local visible = manager:isVisible()
    lurek.log.info("manager update position=" .. x .. "," .. y .. " visible=" .. tostring(visible))
end

--@api: LCursorManager:setVisible
do

    local manager = lurek.cursor.newManager()
    manager:setVisible(false)
    local hidden = manager:isVisible()
    manager:setVisible(true)
    lurek.log.info("visibility toggled hidden=" .. tostring(hidden) .. " final=" .. tostring(manager:isVisible()))
end

--@api: LCursorManager:isVisible
do

    local manager = lurek.cursor.newManager()
    local before = manager:isVisible()
    manager:setVisible(false)
    local after = manager:isVisible()
    lurek.log.info("visibility before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api: LCursorManager:setLocked
do

    local manager = lurek.cursor.newManager()
    manager:setLocked(true)
    local locked = manager:isLocked()
    manager:setLocked(false)
    lurek.log.info("lock toggled true=" .. tostring(locked) .. " final=" .. tostring(manager:isLocked()))
end

--@api: LCursorManager:isLocked
do

    local manager = lurek.cursor.newManager()
    local before = manager:isLocked()
    manager:setLocked(true)
    local after = manager:isLocked()
    lurek.log.info("isLocked before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api: LCursorManager:getPosition
do

    local manager = lurek.cursor.newManager()
    manager:update(640, 360, 0.016)
    local x, y = manager:getPosition()
    local context = manager:getContext()
    lurek.log.info("cursor position x=" .. x .. " y=" .. y .. " context=" .. context)
end

--@api: LCursorManager:getContext
do

    local manager = lurek.cursor.newManager()
    manager:setContext("menu")
    local first = manager:getContext()
    manager:setContext("gameplay")
    lurek.log.info("context changed from " .. first .. " to " .. manager:getContext())
end

--@api: LCursorManager:enableTrail
do

    local manager = lurek.cursor.newManager()
    manager:enableTrail(1.0, 0.5, 0.0, 0.8)
    manager:update(200, 140, 0.016)
    local x, y = manager:getPosition()
    lurek.log.info("trail enabled near position=" .. x .. "," .. y)
end

--@api: LCursorManager:enableLineTrail
do

    local manager = lurek.cursor.newManager()
    manager:enableLineTrail(0.0, 1.0, 1.0, 2.0)
    manager:update(220, 160, 0.016)
    local x, y = manager:getPosition()
    lurek.log.info("line trail enabled near position=" .. x .. "," .. y)
end

--@api: LCursorManager:disableTrail
do

    local manager = lurek.cursor.newManager()
    manager:enableTrail(1.0, 1.0, 1.0, 0.5)
    manager:disableTrail()
    manager:update(200, 120, 0.016)
    lurek.log.info("trail disabled while cursor remains visible=" .. tostring(manager:isVisible()))
end

--@api: LCursorManager:enableZoom
do

    local manager = lurek.cursor.newManager()
    manager:enableZoom(2.0, 80)
    manager:update(320, 180, 0.016)
    local x, y = manager:getPosition()
    lurek.log.info("zoom enabled around position=" .. x .. "," .. y)
end

--@api: LCursorManager:disableZoom
do

    local manager = lurek.cursor.newManager()
    manager:enableZoom(1.5, 60)
    manager:disableZoom()
    manager:setContext("default")
    lurek.log.info("zoom disabled context=" .. manager:getContext())
end

--@api: LCustomCursor:setPixel
do

    local cursor = lurek.cursor.newCustom(16, 16, 0, 0)
    cursor:setPixel(8, 8, 255, 255, 255, 255)
    cursor:setPixel(9, 8, 0, 200, 255, 255)
    local r, g, b, a = cursor:getPixel(8, 8)
    lurek.log.info("custom pixel set rgba=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LCustomCursor:getPixel
do

    local cursor = lurek.cursor.newCustom(16, 16, 0, 0)
    cursor:setPixel(4, 4, 255, 0, 0, 255)
    local r, g, b, a = cursor:getPixel(4, 4)
    local sample_is_red = r == 255 and g == 0 and b == 0 and a == 255
    lurek.log.info("sampled pixel rgba=" .. r .. "," .. g .. "," .. b .. "," .. a .. " red=" .. tostring(sample_is_red))
end

--@api: LCustomCursor:getSize
do

    local cursor = lurek.cursor.newCustom(24, 24, 12, 12)
    cursor:setPixel(12, 12, 255, 255, 0, 255)
    local w, h = cursor:getSize()
    local hx, hy = cursor:getHotspot()
    lurek.log.info("cursor size=" .. w .. "x" .. h .. " hotspot=" .. hx .. "," .. hy)
end

--@api: LCustomCursor:getHotspot
do

    local cursor = lurek.cursor.newCustom(32, 32, 16, 16)
    cursor:setPixel(16, 16, 255, 255, 255, 255)
    local hx, hy = cursor:getHotspot()
    local w, h = cursor:getSize()
    lurek.log.info("cursor hotspot=" .. hx .. "," .. hy .. " size=" .. w .. "x" .. h)
end
