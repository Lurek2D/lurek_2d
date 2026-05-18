--- Effect Module Part 1: Factory functions, LPostFxEffect, LPostFxStack

--@api-stub: lurek.effect.newEffect
-- Creates a built-in post-processing effect by type name.
do
    local fx = lurek.effect.newEffect("bloom")
    print("effect type = " .. fx:getType())
end

--@api-stub: lurek.effect.newCustomEffect
-- Creates a custom post-processing effect from a shader id.
do
    local fx = lurek.effect.newCustomEffect(1)
    print("custom effect built-in = " .. tostring(fx:isBuiltIn()))
end

--@api-stub: lurek.effect.newStack
-- Creates a post-processing stack with optional dimensions.
do
    local stack = lurek.effect.newStack(800, 600)
    print("stack w=" .. stack:getWidth() .. " h=" .. stack:getHeight())
end

--@api-stub: lurek.effect.newPresetStack
-- Creates a named preset post-processing stack.
do
    local stack = lurek.effect.newPresetStack("retro", 320, 240)
    print("preset stack effects = " .. stack:getEffectCount())
end

--@api-stub: lurek.effect.newPass
-- Creates a custom post-processing pass from a shader id.
do
    local fx = lurek.effect.newPass(2)
    print("pass type = " .. fx:getType())
end

--@api-stub: lurek.effect.getEffectTypes
-- Returns all built-in post-processing effect type names.
do
    local types = lurek.effect.getEffectTypes()
    print("available types = " .. #types)
end

--@api-stub: lurek.effect.newImageEffect
-- Creates an image effect chain.
do
    local ie = lurek.effect.newImageEffect()
    print("image effect count = " .. ie:getEffectCount())
end

--@api-stub: lurek.effect.newOverlay
-- Creates an overlay controller for screen effects.
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("overlay w=" .. ov:getWidth() .. " h=" .. ov:getHeight())
end

--@api-stub: lurek.effect.newTransition
-- Creates a timed screen transition.
do
    local tr = lurek.effect.newTransition("fade", 1.0, {0, 0, 0, 1})
    print("transition kind = " .. tr:kind())
end

--@api-stub: lurek.effect.setShaderErrorDisplay
-- Enables or disables shader error display overlays.
do
    lurek.effect.setShaderErrorDisplay(true)
    print("shader errors on")
end

--@api-stub: lurek.effect.getShaderErrorDisplay
-- Returns whether shader error display is enabled.
do
    local on = lurek.effect.getShaderErrorDisplay()
    print("shader error display = " .. tostring(on))
end

--@api-stub: LPostFxEffect:getType
-- Returns the effect type name.
do
    local fx = lurek.effect.newEffect("blur")
    print("type = " .. fx:getType())
end

--@api-stub: LPostFxEffect:getTypeName
-- Returns the built-in or custom effect type name.
do
    local fx = lurek.effect.newEffect("crt")
    print("typeName = " .. fx:getTypeName())
end

--@api-stub: LPostFxEffect:getEffectType
-- Returns the renderer effect type name.
do
    local fx = lurek.effect.newEffect("bloom")
    print("effectType = " .. fx:getEffectType())
end

--@api-stub: LPostFxEffect:isBuiltIn
-- Returns whether this is a built-in effect.
do
    local fx = lurek.effect.newEffect("blur")
    print("builtIn = " .. tostring(fx:isBuiltIn()))
end

--@api-stub: LPostFxEffect:isEnabled
-- Returns whether this effect is enabled.
do
    local fx = lurek.effect.newEffect("bloom")
    print("enabled = " .. tostring(fx:isEnabled()))
end

--@api-stub: LPostFxEffect:setEnabled
-- Enables or disables this effect.
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setEnabled(false)
    print("after disable = " .. tostring(fx:isEnabled()))
end

--@api-stub: LPostFxEffect:setParameter
-- Sets a numeric shader parameter by name.
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setParameter("threshold", 0.8)
    print("param set")
end

--@api-stub: LPostFxEffect:getParameter
-- Reads a shader parameter with optional default.
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setParameter("intensity", 1.5)
    local v = fx:getParameter("intensity", 1.0)
    print("intensity = " .. v)
end

--@api-stub: LPostFxEffect:hasParameter
-- Returns whether a shader parameter exists.
do
    local fx = lurek.effect.newEffect("blur")
    fx:setParameter("radius", 4)
    print("has radius = " .. tostring(fx:hasParameter("radius")))
end

--@api-stub: LPostFxEffect:getParameterNames
-- Returns parameter names stored on this effect.
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setParameter("threshold", 0.5)
    local names = fx:getParameterNames()
    print("param names = " .. #names)
end

--@api-stub: LPostFxEffect:setIntensity
-- Sets the intensity shader parameter.
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setIntensity(2.0)
    print("intensity set")
end

--@api-stub: LPostFxEffect:setStrength
-- Sets the strength shader parameter.
do
    local fx = lurek.effect.newEffect("blur")
    fx:setStrength(0.5)
    print("strength set")
end

--@api-stub: LPostFxEffect:setRadius
-- Sets the radius shader parameter.
do
    local fx = lurek.effect.newEffect("blur")
    fx:setRadius(8)
    print("radius set")
end

--@api-stub: LPostFxEffect:setThreshold
-- Sets the threshold shader parameter.
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setThreshold(0.6)
    print("threshold set")
end

--@api-stub: LPostFxEffect:setBrightness
-- Sets the brightness shader parameter.
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setBrightness(1.2)
    print("brightness set")
end

--@api-stub: LPostFxEffect:setContrast
-- Sets the contrast shader parameter.
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setContrast(1.1)
    print("contrast set")
end

--@api-stub: LPostFxEffect:setSaturation
-- Sets the saturation shader parameter.
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setSaturation(0.8)
    print("saturation set")
end

--@api-stub: LPostFxEffect:setOffset
-- Sets the offset shader parameter.
do
    local fx = lurek.effect.newEffect("crt")
    fx:setOffset(0.002)
    print("offset set")
end

--@api-stub: LPostFxEffect:setScanlineStrength
-- Sets the scanline_strength shader parameter.
do
    local fx = lurek.effect.newEffect("crt")
    fx:setScanlineStrength(0.3)
    print("scanline set")
end

--@api-stub: LPostFxEffect:enableAutoUniforms
-- Enables automatic time and resolution uniforms.
do
    local fx = lurek.effect.newEffect("bloom")
    fx:enableAutoUniforms()
    print("auto uniforms on = " .. tostring(fx:isAutoUniforms()))
end

--@api-stub: LPostFxEffect:disableAutoUniforms
-- Disables automatic time and resolution uniforms.
do
    local fx = lurek.effect.newEffect("bloom")
    fx:disableAutoUniforms()
    print("auto uniforms off = " .. tostring(fx:isAutoUniforms()))
end

--@api-stub: LPostFxEffect:isAutoUniforms
-- Returns whether automatic uniforms are enabled.
do
    local fx = lurek.effect.newEffect("bloom")
    print("autoUniforms = " .. tostring(fx:isAutoUniforms()))
end

--@api-stub: LPostFxEffect:type
-- Returns the type name ("LPostFxEffect").
do
    local fx = lurek.effect.newEffect("blur")
    print("type = " .. fx:type())
end

--@api-stub: LPostFxEffect:typeOf
-- Returns whether this handle matches a type name.
do
    local fx = lurek.effect.newEffect("blur")
    print("is PostFxEffect = " .. tostring(fx:typeOf("PostFxEffect")))
end

--@api-stub: LPostFxStack:add
-- Appends an effect to the end of the stack.
do
    local stack = lurek.effect.newStack(800, 600)
    local fx = lurek.effect.newEffect("bloom")
    stack:add(fx)
    print("stack count = " .. stack:getEffectCount())
end

--@api-stub: LPostFxStack:remove
-- Removes the first matching effect handle from this stack.
do
    local stack = lurek.effect.newStack(800, 600)
    local fx = lurek.effect.newEffect("blur")
    stack:add(fx)
    local ok = stack:remove(fx)
    print("removed = " .. tostring(ok))
end

--@api-stub: LPostFxStack:insert
-- Inserts an effect at a one-based stack position.
do
    local stack = lurek.effect.newStack(800, 600)
    local a = lurek.effect.newEffect("bloom")
    local b = lurek.effect.newEffect("blur")
    stack:add(a)
    stack:insert(1, b)
    print("after insert count = " .. stack:getEffectCount())
end

--@api-stub: LPostFxStack:setEnabled
-- Enables or disables the effect pass at a one-based position.
do
    local stack = lurek.effect.newStack(800, 600)
    local fx = lurek.effect.newEffect("bloom")
    stack:add(fx)
    stack:setEnabled(1, false)
    print("pass 1 enabled = " .. tostring(stack:isEnabled(1)))
end

--@api-stub: LPostFxStack:isEnabled
-- Returns whether the pass at a one-based position is enabled.
do
    local stack = lurek.effect.newStack(800, 600)
    local fx = lurek.effect.newEffect("blur")
    stack:add(fx)
    print("pass enabled = " .. tostring(stack:isEnabled(1)))
end

--@api-stub: LPostFxStack:getEffectCount
-- Returns the number of effects in this stack.
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:add(lurek.effect.newEffect("blur"))
    print("effect count = " .. stack:getEffectCount())
end

--@api-stub: LPostFxStack:getEffect
-- Returns the effect handle at a one-based position.
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    local fx = stack:getEffect(1)
    if fx then
        print("got effect at 1")
    end
end

--@api-stub: LPostFxStack:getEnabledEffects
-- Returns effect handles whose passes are enabled.
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:add(lurek.effect.newEffect("blur"))
    local enabled = stack:getEnabledEffects()
    print("enabled effects = " .. #enabled)
end

--@api-stub: LPostFxStack:getWidth
-- Returns the stack render width.
do
    local stack = lurek.effect.newStack(1024, 768)
    print("width = " .. stack:getWidth())
end

--@api-stub: LPostFxStack:getHeight
-- Returns the stack render height.
do
    local stack = lurek.effect.newStack(1024, 768)
    print("height = " .. stack:getHeight())
end

--@api-stub: LPostFxStack:getDimensions
-- Returns the stack render dimensions.
do
    local stack = lurek.effect.newStack(800, 600)
    local w, h = stack:getDimensions()
    print("dims = " .. w .. "x" .. h)
end

--@api-stub: LPostFxStack:resize
-- Resizes the stack render target dimensions.
do
    local stack = lurek.effect.newStack(800, 600)
    stack:resize(1920, 1080)
    print("resized w=" .. stack:getWidth())
end

--@api-stub: LPostFxStack:len
-- Returns the effect count (alias).
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    print("len = " .. stack:len())
end

--@api-stub: LPostFxStack:isEmpty
-- Returns whether the stack has no effects.
do
    local stack = lurek.effect.newStack(800, 600)
    print("empty = " .. tostring(stack:isEmpty()))
end

--@api-stub: LPostFxStack:clear
-- Removes all effects from this stack.
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:clear()
    print("after clear = " .. stack:getEffectCount())
end

print("effect_00.lua")
