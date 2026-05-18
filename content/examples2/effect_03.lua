--- Effect Module Part 4: LScreenTransition

--@api-stub: LScreenTransition:play
-- Starts this screen transition forward.
do
    local tr = lurek.effect.newTransition("fade", 1.0)
    tr:play()
    print("playing, active = " .. tostring(tr:isActive()))
end

--@api-stub: LScreenTransition:reverse
-- Starts this screen transition in reverse.
do
    local tr = lurek.effect.newTransition("fade", 1.0)
    tr:play()
    tr:update(1.0)
    tr:reverse()
    print("reversed, active = " .. tostring(tr:isActive()))
end

--@api-stub: LScreenTransition:update
-- Advances the transition timer.
do
    local tr = lurek.effect.newTransition("fade", 0.5)
    tr:play()
    local still_active = tr:update(0.25)
    print("still active = " .. tostring(still_active))
end

--@api-stub: LScreenTransition:progress
-- Returns normalized transition progress.
do
    local tr = lurek.effect.newTransition("fade", 1.0)
    tr:play()
    tr:update(0.5)
    print("progress = " .. tr:progress())
end

--@api-stub: LScreenTransition:isActive
-- Returns whether the transition is currently active.
do
    local tr = lurek.effect.newTransition("fade", 1.0)
    print("before play active = " .. tostring(tr:isActive()))
end

--@api-stub: LScreenTransition:isDone
-- Returns whether the transition has finished.
do
    local tr = lurek.effect.newTransition("fade", 0.5)
    tr:play()
    tr:update(1.0)
    print("done = " .. tostring(tr:isDone()))
end

--@api-stub: LScreenTransition:kind
-- Returns the transition kind name.
do
    local tr = lurek.effect.newTransition("wipe", 1.0)
    print("kind = " .. tr:kind())
end

--@api-stub: LScreenTransition:color
-- Returns the transition RGBA color.
do
    local tr = lurek.effect.newTransition("fade", 1.0, {0, 0, 0, 1})
    local r, g, b, a = tr:color()
    print("color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LScreenTransition:setColor
-- Sets the transition RGBA color from a table.
do
    local tr = lurek.effect.newTransition("fade", 1.0)
    tr:setColor({1, 0, 0, 1})
    local r, g, b, a = tr:color()
    print("new color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LScreenTransition:type
-- Returns the type name ("LScreenTransition").
do
    local tr = lurek.effect.newTransition()
    print("type = " .. tr:type())
end

--@api-stub: LScreenTransition:typeOf
-- Returns whether this handle matches a type name.
do
    local tr = lurek.effect.newTransition()
    print("is ScreenTransition = " .. tostring(tr:typeOf("ScreenTransition")))
end

print("effect_03.lua")
