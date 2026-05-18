--- Effect Module Part 2: LPostFxStack feedback/capture, LImageEffect, LOverlay triggers and state

--@api-stub: LPostFxStack:dedup
-- Removes duplicate effect handles while preserving first occurrences.
do
    local stack = lurek.effect.newStack(800, 600)
    local fx = lurek.effect.newEffect("bloom")
    stack:add(fx)
    stack:add(fx)
    local removed = stack:dedup()
    print("dedup removed = " .. removed)
end

--@api-stub: LPostFxStack:isCapturing
-- Returns whether this stack is currently capturing draw commands.
do
    local stack = lurek.effect.newStack(800, 600)
    print("capturing = " .. tostring(stack:isCapturing()))
end

--@api-stub: LPostFxStack:beginCapture
-- Starts post-effect capture.
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:beginCapture()
    print("capture started")
end

--@api-stub: LPostFxStack:endCapture
-- Ends post-effect capture.
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:beginCapture()
    stack:endCapture()
    print("capture ended")
end

--@api-stub: LPostFxStack:apply
-- Queues this stack's enabled post-effect passes for renderer application.
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:beginCapture()
    stack:endCapture()
    stack:apply()
    print("applied")
end

--@api-stub: LPostFxStack:setFeedback
-- Sets the stack feedback blend factor.
do
    local stack = lurek.effect.newStack(800, 600)
    stack:setFeedback(0.5)
    print("feedback = " .. stack:getFeedback())
end

--@api-stub: LPostFxStack:getFeedback
-- Returns the current feedback blend factor.
do
    local stack = lurek.effect.newStack(800, 600)
    stack:setFeedback(0.3)
    print("feedback = " .. stack:getFeedback())
end

--@api-stub: LPostFxStack:clearFeedback
-- Resets the stack feedback blend factor to zero.
do
    local stack = lurek.effect.newStack(800, 600)
    stack:setFeedback(0.8)
    stack:clearFeedback()
    print("cleared feedback = " .. stack:getFeedback())
end

--@api-stub: LPostFxStack:type
-- Returns the type name ("LPostFxStack").
do
    local stack = lurek.effect.newStack(800, 600)
    print("type = " .. stack:type())
end

--@api-stub: LPostFxStack:typeOf
-- Returns whether this handle matches a type name.
do
    local stack = lurek.effect.newStack(800, 600)
    print("is PostFxStack = " .. tostring(stack:typeOf("PostFxStack")))
end

--@api-stub: LImageEffect:addEffect
-- Appends a built-in effect by type name to this image effect chain.
do
    local ie = lurek.effect.newImageEffect()
    local fx = ie:addEffect("bloom")
    print("added effect type = " .. fx:getType())
end

--@api-stub: LImageEffect:getEffect
-- Looks up an image effect by name or index.
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("blur")
    local fx = ie:getEffect("blur")
    if fx then
        print("found effect")
    end
end

--@api-stub: LImageEffect:getEffectCount
-- Returns the number of effects in this chain.
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    ie:addEffect("blur")
    print("count = " .. ie:getEffectCount())
end

--@api-stub: LImageEffect:effectCount
-- Returns the number of effects (alias).
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("crt")
    print("effectCount = " .. ie:effectCount())
end

--@api-stub: LImageEffect:removeEffect
-- Removes an effect by name or index.
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    local ok = ie:removeEffect("bloom")
    print("removed = " .. tostring(ok))
end

--@api-stub: LImageEffect:removeByName
-- Removes the first effect with a matching type name.
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("blur")
    local ok = ie:removeByName("blur")
    print("removeByName = " .. tostring(ok))
end

--@api-stub: LImageEffect:removeByIndex
-- Removes an effect by zero-based index.
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    local ok = ie:removeByIndex(0)
    print("removeByIndex = " .. tostring(ok))
end

--@api-stub: LImageEffect:clear
-- Removes every effect from this chain.
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    ie:clear()
    print("after clear = " .. ie:getEffectCount())
end

--@api-stub: LImageEffect:clearEffects
-- Removes every effect from this chain (alias).
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("crt")
    ie:clearEffects()
    print("after clearEffects = " .. ie:getEffectCount())
end

--@api-stub: LImageEffect:clone
-- Creates a new image effect chain with cloned entries.
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    local copy = ie:clone()
    print("clone count = " .. copy:getEffectCount())
end

--@api-stub: LImageEffect:save
-- Reports success for save placeholder.
do
    local ie = lurek.effect.newImageEffect()
    local ok = ie:save()
    print("save = " .. tostring(ok))
end

--@api-stub: LImageEffect:type
-- Returns the type name ("LImageEffect").
do
    local ie = lurek.effect.newImageEffect()
    print("type = " .. ie:type())
end

--@api-stub: LImageEffect:typeOf
-- Returns whether this handle matches a type name.
do
    local ie = lurek.effect.newImageEffect()
    print("is ImageEffect = " .. tostring(ie:typeOf("ImageEffect")))
end

--@api-stub: LOverlay:update
-- Advances overlay timers and animated effect state.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:update(1 / 60)
    print("overlay updated")
end

--@api-stub: LOverlay:triggerFlash
-- Starts a screen flash with explicit RGBA color and duration.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:triggerFlash(1, 1, 1, 0.8, 0.3)
    print("flash triggered, active = " .. tostring(ov:isFlashing()))
end

--@api-stub: LOverlay:triggerShake
-- Starts a screen shake effect.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:triggerShake(5.0, 0.5)
    print("shake triggered, active = " .. tostring(ov:isShaking()))
end

--@api-stub: LOverlay:triggerFade
-- Starts a fade overlay toward a target alpha.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:triggerFade(0, 0, 0, 1.0, 2.0)
    print("fade triggered, active = " .. tostring(ov:isFading()))
end

--@api-stub: LOverlay:triggerLightning
-- Starts a lightning flash.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:triggerLightning()
    print("lightning triggered")
end

--@api-stub: LOverlay:getShakeOffset
-- Returns the current screen shake offset.
do
    local ov = lurek.effect.newOverlay(800, 600)
    local x, y = ov:getShakeOffset()
    print("shake offset = " .. x .. ", " .. y)
end

--@api-stub: LOverlay:isActive
-- Returns whether any overlay effect is active.
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("active = " .. tostring(ov:isActive()))
end

--@api-stub: LOverlay:clear
-- Clears active overlay effects and resets state.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:triggerFlash(1, 0, 0, 1, 0.5)
    ov:clear()
    print("cleared, active = " .. tostring(ov:isActive()))
end

--@api-stub: LOverlay:resize
-- Resizes the overlay target dimensions.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:resize(1920, 1080)
    print("resized w=" .. ov:getWidth() .. " h=" .. ov:getHeight())
end

--@api-stub: LOverlay:getWidth
-- Returns the overlay width.
do
    local ov = lurek.effect.newOverlay(640, 480)
    print("width = " .. ov:getWidth())
end

--@api-stub: LOverlay:getHeight
-- Returns the overlay height.
do
    local ov = lurek.effect.newOverlay(640, 480)
    print("height = " .. ov:getHeight())
end

--@api-stub: LOverlay:getDimensions
-- Returns the overlay dimensions.
do
    local ov = lurek.effect.newOverlay(800, 600)
    local w, h = ov:getDimensions()
    print("dims = " .. w .. "x" .. h)
end

--@api-stub: LOverlay:getFlashAlpha
-- Returns the current flash alpha.
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("flash alpha = " .. ov:getFlashAlpha())
end

--@api-stub: LOverlay:getLightningAlpha
-- Returns the current lightning alpha.
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("lightning alpha = " .. ov:getLightningAlpha())
end

--@api-stub: LOverlay:setAmbientEnabled
-- Enables or disables ambient color rendering.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setAmbientEnabled(true)
    print("ambient enabled = " .. tostring(ov:isAmbientEnabled()))
end

--@api-stub: LOverlay:isAmbientEnabled
-- Returns whether ambient rendering is enabled.
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("ambient = " .. tostring(ov:isAmbientEnabled()))
end

--@api-stub: LOverlay:setAmbientColor
-- Sets the overlay ambient RGBA color.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setAmbientColor(0.2, 0.1, 0.3, 1.0)
    local r, g, b, a = ov:getAmbientColor()
    print("ambient color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

print("effect_01.lua")
