-- content/examples/effect.lua
-- Auto-generated from content/examples2/effect_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/effect.lua

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

--- Effect Module Part 3: LOverlay fog, heat haze, vignette, film grain, clouds, weather, wind, lightning, render

--@api-stub: LOverlay:setFogEnabled
-- Enables or disables overlay fog rendering.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setFogEnabled(true)
    print("fog enabled = " .. tostring(ov:isFogEnabled()))
end

--@api-stub: LOverlay:isFogEnabled
-- Returns whether fog rendering is enabled.
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("fog = " .. tostring(ov:isFogEnabled()))
end

--@api-stub: LOverlay:setFogColor
-- Sets the overlay fog RGBA color.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setFogColor(0.5, 0.5, 0.5, 0.8)
    local r, g, b, a = ov:getFogColor()
    print("fog color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LOverlay:getFogColor
-- Returns overlay fog RGBA color.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setFogColor(0.3, 0.3, 0.4, 1.0)
    local r, g, b, a = ov:getFogColor()
    print("fog = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LOverlay:setFogDensity
-- Sets overlay fog density.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setFogDensity(0.7)
    print("fog density = " .. ov:getFogDensity())
end

--@api-stub: LOverlay:getFogDensity
-- Returns overlay fog density.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setFogDensity(0.4)
    print("density = " .. ov:getFogDensity())
end

--@api-stub: LOverlay:setHeatHazeEnabled
-- Enables or disables heat haze rendering.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setHeatHazeEnabled(true)
    print("heat haze on = " .. tostring(ov:isHeatHazeEnabled()))
end

--@api-stub: LOverlay:isHeatHazeEnabled
-- Returns whether heat haze is enabled.
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("heat haze = " .. tostring(ov:isHeatHazeEnabled()))
end

--@api-stub: LOverlay:setHeatHazeIntensity
-- Sets heat haze intensity.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setHeatHazeIntensity(0.5)
    print("heat intensity = " .. ov:getHeatHazeIntensity())
end

--@api-stub: LOverlay:getHeatHazeIntensity
-- Returns heat haze intensity.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setHeatHazeIntensity(0.3)
    print("intensity = " .. ov:getHeatHazeIntensity())
end

--@api-stub: LOverlay:setVignetteEnabled
-- Enables or disables vignette rendering.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setVignetteEnabled(true)
    print("vignette on = " .. tostring(ov:isVignetteEnabled()))
end

--@api-stub: LOverlay:isVignetteEnabled
-- Returns whether vignette is enabled.
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("vignette = " .. tostring(ov:isVignetteEnabled()))
end

--@api-stub: LOverlay:setVignetteStrength
-- Sets vignette strength.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setVignetteStrength(0.6)
    print("vignette strength = " .. ov:getVignetteStrength())
end

--@api-stub: LOverlay:getVignetteStrength
-- Returns vignette strength.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setVignetteStrength(0.4)
    print("strength = " .. ov:getVignetteStrength())
end

--@api-stub: LOverlay:setFilmGrainEnabled
-- Enables or disables film grain rendering.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setFilmGrainEnabled(true)
    print("grain on = " .. tostring(ov:isFilmGrainEnabled()))
end

--@api-stub: LOverlay:isFilmGrainEnabled
-- Returns whether film grain is enabled.
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("grain = " .. tostring(ov:isFilmGrainEnabled()))
end

--@api-stub: LOverlay:setFilmGrainIntensity
-- Sets film grain intensity.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setFilmGrainIntensity(0.2)
    print("grain intensity = " .. ov:getFilmGrainIntensity())
end

--@api-stub: LOverlay:getFilmGrainIntensity
-- Returns film grain intensity.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setFilmGrainIntensity(0.15)
    print("intensity = " .. ov:getFilmGrainIntensity())
end

--@api-stub: LOverlay:setCloudShadows
-- Enables or disables cloud shadow rendering.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setCloudShadows(true)
    print("clouds on = " .. tostring(ov:isCloudShadowsEnabled()))
end

--@api-stub: LOverlay:isCloudShadowsEnabled
-- Returns whether cloud shadows are enabled.
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("clouds = " .. tostring(ov:isCloudShadowsEnabled()))
end

--@api-stub: LOverlay:setCloudCount
-- Sets the cloud shadow count.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setCloudCount(5)
    print("clouds = " .. ov:getCloudCount())
end

--@api-stub: LOverlay:getCloudCount
-- Returns the cloud shadow count.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setCloudCount(3)
    print("count = " .. ov:getCloudCount())
end

--@api-stub: LOverlay:setCloudSpeed
-- Sets cloud shadow movement speed.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setCloudSpeed(0.5)
    print("speed = " .. ov:getCloudSpeed())
end

--@api-stub: LOverlay:getCloudSpeed
-- Returns cloud shadow speed.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setCloudSpeed(1.0)
    print("speed = " .. ov:getCloudSpeed())
end

--@api-stub: LOverlay:setCloudScale
-- Sets cloud shadow scale.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setCloudScale(2.0)
    print("scale = " .. ov:getCloudScale())
end

--@api-stub: LOverlay:getCloudScale
-- Returns cloud shadow scale.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setCloudScale(1.5)
    print("scale = " .. ov:getCloudScale())
end

--@api-stub: LOverlay:setCloudOpacity
-- Sets cloud shadow opacity.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setCloudOpacity(0.6)
    print("opacity = " .. ov:getCloudOpacity())
end

--@api-stub: LOverlay:getCloudOpacity
-- Returns cloud shadow opacity.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setCloudOpacity(0.4)
    print("opacity = " .. ov:getCloudOpacity())
end

--@api-stub: LOverlay:setWeatherEnabled
-- Enables or disables weather rendering.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setWeatherEnabled(true)
    print("weather on = " .. tostring(ov:isWeatherEnabled()))
end

--@api-stub: LOverlay:isWeatherEnabled
-- Returns whether weather is enabled.
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("weather = " .. tostring(ov:isWeatherEnabled()))
end

--@api-stub: LOverlay:setWeather
-- Sets the weather type by name.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setWeather("rain")
    print("weather = " .. ov:getWeather())
end

--@api-stub: LOverlay:getWeather
-- Returns the weather type name.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setWeather("snow")
    print("weather = " .. ov:getWeather())
end

--@api-stub: LOverlay:setWeatherIntensity
-- Sets weather intensity.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setWeatherIntensity(0.8)
    print("intensity = " .. ov:getWeatherIntensity())
end

--@api-stub: LOverlay:getWeatherIntensity
-- Returns weather intensity.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setWeatherIntensity(0.5)
    print("intensity = " .. ov:getWeatherIntensity())
end

--@api-stub: LOverlay:setWindDirection
-- Sets the weather wind direction.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setWindDirection(45)
    print("wind dir = " .. ov:getWindDirection())
end

--@api-stub: LOverlay:getWindDirection
-- Returns the wind direction.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setWindDirection(90)
    print("dir = " .. ov:getWindDirection())
end

--@api-stub: LOverlay:setWindSpeed
-- Sets the weather wind speed.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setWindSpeed(2.5)
    print("wind speed = " .. ov:getWindSpeed())
end

--@api-stub: LOverlay:getWindSpeed
-- Returns the wind speed.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setWindSpeed(1.0)
    print("speed = " .. ov:getWindSpeed())
end

--@api-stub: LOverlay:setLightningColor
-- Sets the lightning RGBA color.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setLightningColor(0.9, 0.9, 1.0, 1.0)
    local r, g, b, a = ov:getLightningColor()
    print("lightning = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LOverlay:getLightningColor
-- Returns the lightning RGBA color.
do
    local ov = lurek.effect.newOverlay(800, 600)
    local r, g, b, a = ov:getLightningColor()
    print("lightning color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LOverlay:isFlashing
-- Returns whether the flash overlay is active.
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("flashing = " .. tostring(ov:isFlashing()))
end

--@api-stub: LOverlay:isShaking
-- Returns whether the screen shake is active.
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("shaking = " .. tostring(ov:isShaking()))
end

--@api-stub: LOverlay:isFading
-- Returns whether the fade overlay is active.
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("fading = " .. tostring(ov:isFading()))
end

--@api-stub: LOverlay:render
-- Queues renderer commands for the overlay's visual state.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:render()
    print("overlay rendered")
end

--@api-stub: LOverlay:flash
-- Starts a short flash overlay.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:flash(1, 1, 1, 0.5, 0.2)
    print("flash started")
end

--@api-stub: LOverlay:shake
-- Starts a screen shake with optional duration.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:shake(3.0, 0.4)
    print("shake started")
end

--@api-stub: LOverlay:fade
-- Starts a fade overlay.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:fade(0, 0, 0, 1.0, 1.0)
    print("fade started")
end

--@api-stub: LOverlay:type
-- Returns the type name ("LOverlay").
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("type = " .. ov:type())
end

--@api-stub: LOverlay:typeOf
-- Returns whether this handle matches a type name.
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("is Overlay = " .. tostring(ov:typeOf("Overlay")))
end

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

--- Effect Module: LOverlay extended methods

--@api-stub: LOverlay:drawToImage
--@api-stub: LOverlay:getAmbientColor
--@api-stub: LOverlay:setCustomShader
-- Overlay image export and ambient color.
do
    local ov = lurek.effect.newOverlay(800, 600)
    local r, g, b, a = ov:getAmbientColor()
    print("ambient", r, g, b, a)
    ov:setCustomShader("chromatic")
    local img = ov:drawToImage(800, 600)
    print("img type = " .. tostring(img))
end

--@api-stub: LOverlay:getTimeOfDay
--@api-stub: LOverlay:setTimeOfDay
-- Time-of-day lighting control on an overlay.
do
    local ov = lurek.effect.newOverlay(800, 600)
    local tod = ov:getTimeOfDay()
    print("time_of_day = " .. tostring(tod))
    ov:setTimeOfDay(0.5)
    ov:setTimeOfDay(0.0)
    ov:setTimeOfDay(1.0)
    print("time_of_day set")
end

--@api-stub: LOverlay:getWater
--@api-stub: LOverlay:setWater
--@api-stub: LOverlay:setWaterTint
-- Water configuration on overlay.
do
    local ov = lurek.effect.newOverlay(800, 600)
    local water = ov:getWater()
    print("water = " .. tostring(water))
    ov:setWater(0.5, 2.0, 1.0)
    ov:setWaterTint(0.1, 0.4, 0.8, 0.9)
    ov:setWaterTint(0.0, 0.0, 0.0, 0.5)
    print("water configured")
end

--@api-stub: LOverlay:pullAmbientFromLight
--@api-stub: LOverlay:pushAmbientToLight
--@api-stub: LOverlay:syncAmbientWithLight
-- Overlay-light ambient synchronization.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:pullAmbientFromLight()
    ov:pushAmbientToLight()
    ov:syncAmbientWithLight("avg")
    ov:syncAmbientWithLight("light")
    print("ambient synced")
end

print("content/examples/effect.lua")
