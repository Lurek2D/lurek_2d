-- content/examples/effect.lua
-- Auto-generated from content/examples2/effect_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/effect.lua

--- Effect Module Part 1: Factory functions, LPostFxEffect, LPostFxStack


--@api-stub: lurek.effect.newEffect
do
    local fx = lurek.effect.newEffect("bloom")
    print("effect type = " .. fx:getType())
end

--@api-stub: lurek.effect.newCustomEffect
do
    local fx = lurek.effect.newCustomEffect(1)
    print("custom effect built-in = " .. tostring(fx:isBuiltIn()))
end

--@api-stub: lurek.effect.newStack
do
    local stack = lurek.effect.newStack(800, 600)
    print("stack w=" .. stack:getWidth() .. " h=" .. stack:getHeight())
end

--@api-stub: lurek.effect.newPresetStack
do
    local stack = lurek.effect.newPresetStack("retro_tv", 320, 240)
    print("preset stack effects = " .. stack:getEffectCount())
end

--@api-stub: lurek.effect.newPass
do
    local fx = lurek.effect.newPass(2)
    print("pass type = " .. fx:getType())
end

--@api-stub: lurek.effect.getEffectTypes
do
    local types = lurek.effect.getEffectTypes()
    print("available types = " .. #types)
end

--@api-stub: lurek.effect.newImageEffect
do
    local ie = lurek.effect.newImageEffect()
    print("image effect count = " .. ie:getEffectCount())
end

--@api-stub: lurek.effect.newOverlay
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("overlay w=" .. ov:getWidth() .. " h=" .. ov:getHeight())
end

--@api-stub: lurek.effect.newTransition
do
    local tr = lurek.effect.newTransition("fade", 1.0, {0, 0, 0, 1})
    print("transition kind = " .. tr:kind())
end

--@api-stub: lurek.effect.setShaderErrorDisplay
do
    lurek.effect.setShaderErrorDisplay(true)
    print("shader errors on")
end

--@api-stub: lurek.effect.getShaderErrorDisplay
do
    local on = lurek.effect.getShaderErrorDisplay()
    print("shader error display = " .. tostring(on))
end

--@api-stub: LPostFxEffect:getType
do
    local fx = lurek.effect.newEffect("blur")
    print("type = " .. fx:getType())
end

--@api-stub: LPostFxEffect:getTypeName
do
    local fx = lurek.effect.newEffect("crt")
    print("typeName = " .. fx:getTypeName())
end

--@api-stub: LPostFxEffect:getEffectType
do
    local fx = lurek.effect.newEffect("bloom")
    print("effectType = " .. fx:getEffectType())
end

--@api-stub: LPostFxEffect:isBuiltIn
do
    local fx = lurek.effect.newEffect("blur")
    print("builtIn = " .. tostring(fx:isBuiltIn()))
end

--@api-stub: LPostFxEffect:isEnabled
do
    local fx = lurek.effect.newEffect("bloom")
    print("enabled = " .. tostring(fx:isEnabled()))
end

--@api-stub: LPostFxEffect:setEnabled
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setEnabled(false)
    print("after disable = " .. tostring(fx:isEnabled()))
end

--@api-stub: LPostFxEffect:setParameter
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setParameter("threshold", 0.8)
    print("param set")
end

--@api-stub: LPostFxEffect:getParameter
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setParameter("intensity", 1.5)
    local v = fx:getParameter("intensity", 1.0)
    print("intensity = " .. v)
end

--@api-stub: LPostFxEffect:hasParameter
do
    local fx = lurek.effect.newEffect("blur")
    fx:setParameter("radius", 4)
    print("has radius = " .. tostring(fx:hasParameter("radius")))
end

--@api-stub: LPostFxEffect:getParameterNames
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setParameter("threshold", 0.5)
    local names = fx:getParameterNames()
    print("param names = " .. #names)
end

--@api-stub: LPostFxEffect:setIntensity
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setIntensity(2.0)
    print("intensity set")
end

--@api-stub: LPostFxEffect:setStrength
do
    local fx = lurek.effect.newEffect("blur")
    fx:setStrength(0.5)
    print("strength set")
end

--@api-stub: LPostFxEffect:setRadius
do
    local fx = lurek.effect.newEffect("blur")
    fx:setRadius(8)
    print("radius set")
end

--@api-stub: LPostFxEffect:setThreshold
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setThreshold(0.6)
    print("threshold set")
end

--@api-stub: LPostFxEffect:setBrightness
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setBrightness(1.2)
    print("brightness set")
end

--@api-stub: LPostFxEffect:setContrast
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setContrast(1.1)
    print("contrast set")
end

--@api-stub: LPostFxEffect:setSaturation
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setSaturation(0.8)
    print("saturation set")
end

--@api-stub: LPostFxEffect:setOffset
do
    local fx = lurek.effect.newEffect("crt")
    fx:setOffset(0.002)
    print("offset set")
end

--@api-stub: LPostFxEffect:setScanlineStrength
do
    local fx = lurek.effect.newEffect("crt")
    fx:setScanlineStrength(0.3)
    print("scanline set")
end

--@api-stub: LPostFxEffect:enableAutoUniforms
do
    local fx = lurek.effect.newEffect("bloom")
    fx:enableAutoUniforms()
    print("auto uniforms on = " .. tostring(fx:isAutoUniforms()))
end

--@api-stub: LPostFxEffect:disableAutoUniforms
do
    local fx = lurek.effect.newEffect("bloom")
    fx:disableAutoUniforms()
    print("auto uniforms off = " .. tostring(fx:isAutoUniforms()))
end

--@api-stub: LPostFxEffect:isAutoUniforms
do
    local fx = lurek.effect.newEffect("bloom")
    print("autoUniforms = " .. tostring(fx:isAutoUniforms()))
end

--@api-stub: LPostFxEffect:type
do
    local fx = lurek.effect.newEffect("blur")
    print("type = " .. fx:type())
end

--@api-stub: LPostFxEffect:typeOf
do
    local fx = lurek.effect.newEffect("blur")
    print("is PostFxEffect = " .. tostring(fx:typeOf("LPostFxEffect")))
end

--@api-stub: LPostFxStack:add
do
    local stack = lurek.effect.newStack(800, 600)
    local fx = lurek.effect.newEffect("bloom")
    stack:add(fx)
    print("stack count = " .. stack:getEffectCount())
end

--@api-stub: LPostFxStack:remove
do
    local stack = lurek.effect.newStack(800, 600)
    local fx = lurek.effect.newEffect("blur")
    stack:add(fx)
    local ok = stack:remove(fx)
    print("removed = " .. tostring(ok))
end

--@api-stub: LPostFxStack:insert
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:insert(1, lurek.effect.newEffect("blur"))
    print("after insert count = " .. stack:getEffectCount())
end

--@api-stub: LPostFxStack:setEnabled
do
    local stack = lurek.effect.newStack(800, 600)
    local fx = lurek.effect.newEffect("bloom")
    stack:add(fx)
    stack:setEnabled(1, false)
    print("pass 1 enabled = " .. tostring(stack:isEnabled(1)))
end

--@api-stub: LPostFxStack:isEnabled
do
    local stack = lurek.effect.newStack(800, 600)
    local fx = lurek.effect.newEffect("blur")
    stack:add(fx)
    print("pass enabled = " .. tostring(stack:isEnabled(1)))
end

--@api-stub: LPostFxStack:getEffectCount
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:add(lurek.effect.newEffect("blur"))
    print("effect count = " .. stack:getEffectCount())
end

--@api-stub: LPostFxStack:getEffect
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    local fx = stack:getEffect(1)
    print("got effect at 1 = " .. tostring(fx ~= nil))
end

--@api-stub: LPostFxStack:getEnabledEffects
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:add(lurek.effect.newEffect("blur"))
    local enabled = stack:getEnabledEffects()
    print("enabled effects = " .. #enabled)
end

--@api-stub: LPostFxStack:getWidth
do
    local stack = lurek.effect.newStack(1024, 768)
    print("width = " .. stack:getWidth())
end

--@api-stub: LPostFxStack:getHeight
do
    local stack = lurek.effect.newStack(1024, 768)
    print("height = " .. stack:getHeight())
end

--@api-stub: LPostFxStack:getDimensions
do
    local stack = lurek.effect.newStack(800, 600)
    local w, h = stack:getDimensions()
    print("dims = " .. w .. "x" .. h)
end

--@api-stub: LPostFxStack:resize
do
    local stack = lurek.effect.newStack(800, 600)
    stack:resize(1920, 1080)
    print("resized w=" .. stack:getWidth())
end

--@api-stub: LPostFxStack:len
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    print("len = " .. stack:len())
end

--@api-stub: LPostFxStack:isEmpty
do
    local stack = lurek.effect.newStack(800, 600)
    print("empty = " .. tostring(stack:isEmpty()))
end

--@api-stub: LPostFxStack:clear
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:clear()
    print("after clear = " .. stack:getEffectCount())
end

--- Effect Module Part 2: LPostFxStack feedback/capture, LImageEffect, LOverlay triggers and state


--@api-stub: LPostFxStack:dedup
do
    local stack = lurek.effect.newStack(800, 600)
    local fx = lurek.effect.newEffect("bloom")
    stack:add(fx); stack:add(fx)
    local removed = stack:dedup()
    print("dedup removed = " .. removed)
end

--@api-stub: LPostFxStack:isCapturing
do
    local stack = lurek.effect.newStack(800, 600)
    print("capturing = " .. tostring(stack:isCapturing()))
end

--@api-stub: LPostFxStack:beginCapture
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:beginCapture()
    print("capture started")
end

--@api-stub: LPostFxStack:endCapture
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:beginCapture()
    stack:endCapture()
    print("capture ended")
end

--@api-stub: LPostFxStack:apply
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom")); stack:beginCapture(); stack:endCapture()
    stack:apply()
    print("applied")
end

--@api-stub: LPostFxStack:setFeedback
do
    local stack = lurek.effect.newStack(800, 600)
    stack:setFeedback(0.5)
    print("feedback = " .. stack:getFeedback())
end

--@api-stub: LPostFxStack:getFeedback
do
    local stack = lurek.effect.newStack(800, 600)
    stack:setFeedback(0.3)
    print("feedback = " .. stack:getFeedback())
end

--@api-stub: LPostFxStack:clearFeedback
do
    local stack = lurek.effect.newStack(800, 600)
    stack:setFeedback(0.8)
    stack:clearFeedback()
    print("cleared feedback = " .. stack:getFeedback())
end

--@api-stub: LPostFxStack:type
do
    local stack = lurek.effect.newStack(800, 600)
    print("type = " .. stack:type())
end

--@api-stub: LPostFxStack:typeOf
do
    local stack = lurek.effect.newStack(800, 600)
    print("is PostFxStack = " .. tostring(stack:typeOf("LPostFxStack")))
end

--@api-stub: LImageEffect:addEffect
do
    local ie = lurek.effect.newImageEffect()
    local fx = ie:addEffect("bloom")
    print("added effect type = " .. fx:getType())
end

--@api-stub: LImageEffect:getEffect
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("blur")
    local fx = ie:getEffect("blur")
    print("found effect = " .. tostring(fx ~= nil))
end

--@api-stub: LImageEffect:getEffectCount
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    ie:addEffect("blur")
    print("count = " .. ie:getEffectCount())
end

--@api-stub: LImageEffect:effectCount
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("crt")
    print("effectCount = " .. ie:effectCount())
end

--@api-stub: LImageEffect:removeEffect
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    local ok = ie:removeEffect("bloom")
    print("removed = " .. tostring(ok))
end

--@api-stub: LImageEffect:removeByName
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("blur")
    local ok = ie:removeByName("blur")
    print("removeByName = " .. tostring(ok))
end

--@api-stub: LImageEffect:removeByIndex
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    local ok = ie:removeByIndex(0)
    print("removeByIndex = " .. tostring(ok))
end

--@api-stub: LImageEffect:clear
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    ie:clear()
    print("after clear = " .. ie:getEffectCount())
end

--@api-stub: LImageEffect:clearEffects
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("crt")
    ie:clearEffects()
    print("after clearEffects = " .. ie:getEffectCount())
end

--@api-stub: LImageEffect:clone
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    local copy = ie:clone()
    print("clone count = " .. copy:getEffectCount())
end

--@api-stub: LImageEffect:save
do
    local ie = lurek.effect.newImageEffect()
    local ok = ie:save()
    print("save = " .. tostring(ok))
end

--@api-stub: LImageEffect:type
do
    local ie = lurek.effect.newImageEffect()
    print("type = " .. ie:type())
end

--@api-stub: LImageEffect:typeOf
do
    local ie = lurek.effect.newImageEffect()
    print("is ImageEffect = " .. tostring(ie:typeOf("LImageEffect")))
end

--@api-stub: LOverlay:update
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:update(1 / 60)
    print("overlay updated")
end

--@api-stub: LOverlay:triggerFlash
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:triggerFlash(1, 1, 1, 0.8, 0.3)
    print("flash triggered, active = " .. tostring(ov:isFlashing()))
end

--@api-stub: LOverlay:triggerShake
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:triggerShake(5.0, 0.5)
    print("shake triggered, active = " .. tostring(ov:isShaking()))
end

--@api-stub: LOverlay:triggerFade
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:triggerFade(0, 0, 0, 1.0, 2.0)
    print("fade triggered, active = " .. tostring(ov:isFading()))
end

--@api-stub: LOverlay:triggerLightning
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:triggerLightning()
    print("lightning triggered")
end

--@api-stub: LOverlay:getShakeOffset
do
    local ov = lurek.effect.newOverlay(800, 600)
    local x, y = ov:getShakeOffset()
    print("shake offset = " .. x .. ", " .. y)
end

--@api-stub: LOverlay:isActive
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("active = " .. tostring(ov:isActive()))
end

--@api-stub: LOverlay:clear
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:triggerFlash(1, 0, 0, 1, 0.5)
    ov:clear()
    print("cleared, active = " .. tostring(ov:isActive()))
end

--@api-stub: LOverlay:resize
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:resize(1920, 1080)
    print("resized w=" .. ov:getWidth() .. " h=" .. ov:getHeight())
end

--@api-stub: LOverlay:getWidth
do
    local ov = lurek.effect.newOverlay(640, 480)
    print("width = " .. ov:getWidth())
end

--@api-stub: LOverlay:getHeight
do
    local ov = lurek.effect.newOverlay(640, 480)
    print("height = " .. ov:getHeight())
end

--@api-stub: LOverlay:getDimensions
do
    local ov = lurek.effect.newOverlay(800, 600)
    local w, h = ov:getDimensions()
    print("dims = " .. w .. "x" .. h)
end

--@api-stub: LOverlay:getFlashAlpha
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("flash alpha = " .. ov:getFlashAlpha())
end

--@api-stub: LOverlay:getLightningAlpha
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("lightning alpha = " .. ov:getLightningAlpha())
end

--@api-stub: LOverlay:setAmbientEnabled
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setAmbientEnabled(true)
    print("ambient enabled = " .. tostring(ov:isAmbientEnabled()))
end

--@api-stub: LOverlay:isAmbientEnabled
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("ambient = " .. tostring(ov:isAmbientEnabled()))
end

--@api-stub: LOverlay:setAmbientColor
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setAmbientColor(0.2, 0.1, 0.3, 1.0)
    local r, g, b, a = ov:getAmbientColor()
    print("ambient color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--- Effect Module Part 3: LOverlay fog, heat haze, vignette, film grain, clouds, weather, wind, lightning, render


--@api-stub: LOverlay:setFogEnabled
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setFogEnabled(true)
    print("fog enabled = " .. tostring(ov:isFogEnabled()))
end

--@api-stub: LOverlay:isFogEnabled
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("fog = " .. tostring(ov:isFogEnabled()))
end

--@api-stub: LOverlay:setFogColor
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setFogColor(0.5, 0.5, 0.5, 0.8)
    local r, g, b, a = ov:getFogColor()
    print("fog color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LOverlay:getFogColor
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setFogColor(0.3, 0.3, 0.4, 1.0)
    local r, g, b, a = ov:getFogColor()
    print("fog = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LOverlay:setFogDensity
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setFogDensity(0.7)
    print("fog density = " .. ov:getFogDensity())
end

--@api-stub: LOverlay:getFogDensity
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setFogDensity(0.4)
    print("density = " .. ov:getFogDensity())
end

--@api-stub: LOverlay:setHeatHazeEnabled
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setHeatHazeEnabled(true)
    print("heat haze on = " .. tostring(ov:isHeatHazeEnabled()))
end

--@api-stub: LOverlay:isHeatHazeEnabled
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("heat haze = " .. tostring(ov:isHeatHazeEnabled()))
end

--@api-stub: LOverlay:setHeatHazeIntensity
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setHeatHazeIntensity(0.5)
    print("heat intensity = " .. ov:getHeatHazeIntensity())
end

--@api-stub: LOverlay:getHeatHazeIntensity
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setHeatHazeIntensity(0.3)
    print("intensity = " .. ov:getHeatHazeIntensity())
end

--@api-stub: LOverlay:setVignetteEnabled
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setVignetteEnabled(true)
    print("vignette on = " .. tostring(ov:isVignetteEnabled()))
end

--@api-stub: LOverlay:isVignetteEnabled
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("vignette = " .. tostring(ov:isVignetteEnabled()))
end

--@api-stub: LOverlay:setVignetteStrength
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setVignetteStrength(0.6)
    print("vignette strength = " .. ov:getVignetteStrength())
end

--@api-stub: LOverlay:getVignetteStrength
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setVignetteStrength(0.4)
    print("strength = " .. ov:getVignetteStrength())
end

--@api-stub: LOverlay:setFilmGrainEnabled
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setFilmGrainEnabled(true)
    print("grain on = " .. tostring(ov:isFilmGrainEnabled()))
end

--@api-stub: LOverlay:isFilmGrainEnabled
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("grain = " .. tostring(ov:isFilmGrainEnabled()))
end

--@api-stub: LOverlay:setFilmGrainIntensity
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setFilmGrainIntensity(0.2)
    print("grain intensity = " .. ov:getFilmGrainIntensity())
end

--@api-stub: LOverlay:getFilmGrainIntensity
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setFilmGrainIntensity(0.15)
    print("intensity = " .. ov:getFilmGrainIntensity())
end

--@api-stub: LOverlay:setCloudShadows
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setCloudShadows(true)
    print("clouds on = " .. tostring(ov:isCloudShadowsEnabled()))
end

--@api-stub: LOverlay:isCloudShadowsEnabled
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("clouds = " .. tostring(ov:isCloudShadowsEnabled()))
end

--@api-stub: LOverlay:setCloudCount
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setCloudCount(5)
    print("clouds = " .. ov:getCloudCount())
end

--@api-stub: LOverlay:getCloudCount
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setCloudCount(3)
    print("count = " .. ov:getCloudCount())
end

--@api-stub: LOverlay:setCloudSpeed
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setCloudSpeed(0.5)
    print("speed = " .. ov:getCloudSpeed())
end

--@api-stub: LOverlay:getCloudSpeed
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setCloudSpeed(1.0)
    print("speed = " .. ov:getCloudSpeed())
end

--@api-stub: LOverlay:setCloudScale
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setCloudScale(2.0)
    print("scale = " .. ov:getCloudScale())
end

--@api-stub: LOverlay:getCloudScale
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setCloudScale(1.5)
    print("scale = " .. ov:getCloudScale())
end

--@api-stub: LOverlay:setCloudOpacity
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setCloudOpacity(0.6)
    print("opacity = " .. ov:getCloudOpacity())
end

--@api-stub: LOverlay:getCloudOpacity
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setCloudOpacity(0.4)
    print("opacity = " .. ov:getCloudOpacity())
end

--@api-stub: LOverlay:setWeatherEnabled
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setWeatherEnabled(true)
    print("weather on = " .. tostring(ov:isWeatherEnabled()))
end

--@api-stub: LOverlay:isWeatherEnabled
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("weather = " .. tostring(ov:isWeatherEnabled()))
end

--@api-stub: LOverlay:setWeather
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setWeather("rain")
    print("weather = " .. ov:getWeather())
end

--@api-stub: LOverlay:getWeather
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setWeather("snow")
    print("weather = " .. ov:getWeather())
end

--@api-stub: LOverlay:setWeatherIntensity
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setWeatherIntensity(0.8)
    print("intensity = " .. ov:getWeatherIntensity())
end

--@api-stub: LOverlay:getWeatherIntensity
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setWeatherIntensity(0.5)
    print("intensity = " .. ov:getWeatherIntensity())
end

--@api-stub: LOverlay:setWindDirection
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setWindDirection(45)
    print("wind dir = " .. ov:getWindDirection())
end

--@api-stub: LOverlay:getWindDirection
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setWindDirection(90)
    print("dir = " .. ov:getWindDirection())
end

--@api-stub: LOverlay:setWindSpeed
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setWindSpeed(2.5)
    print("wind speed = " .. ov:getWindSpeed())
end

--@api-stub: LOverlay:getWindSpeed
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setWindSpeed(1.0)
    print("speed = " .. ov:getWindSpeed())
end

--@api-stub: LOverlay:setLightningColor
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setLightningColor(0.9, 0.9, 1.0, 1.0)
    local r, g, b, a = ov:getLightningColor()
    print("lightning = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LOverlay:getLightningColor
do
    local ov = lurek.effect.newOverlay(800, 600)
    local r, g, b, a = ov:getLightningColor()
    print("lightning color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LOverlay:isFlashing
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("flashing = " .. tostring(ov:isFlashing()))
end

--@api-stub: LOverlay:isShaking
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("shaking = " .. tostring(ov:isShaking()))
end

--@api-stub: LOverlay:isFading
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("fading = " .. tostring(ov:isFading()))
end

--@api-stub: LOverlay:render
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:render()
    print("overlay rendered")
end

--@api-stub: LOverlay:flash
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:flash(1, 1, 1, 0.5, 0.2)
    print("flash started")
end

--@api-stub: LOverlay:shake
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:shake(3.0, 0.4)
    print("shake started")
end

--@api-stub: LOverlay:fade
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:fade(0, 0, 0, 1.0, 1.0)
    print("fade started")
end

--@api-stub: LOverlay:type
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("type = " .. ov:type())
end

--@api-stub: LOverlay:typeOf
do
    local ov = lurek.effect.newOverlay(800, 600)
    print("is Overlay = " .. tostring(ov:typeOf("LOverlay")))
end

--- Effect Module Part 4: LScreenTransition


--@api-stub: LScreenTransition:play
do
    local tr = lurek.effect.newTransition("fade", 1.0)
    tr:play()
    print("playing, active = " .. tostring(tr:isActive()))
end

--@api-stub: LScreenTransition:reverse
do
    local tr = lurek.effect.newTransition("fade", 1.0)
    tr:play()
    tr:update(1.0)
    tr:reverse()
    print("reversed, active = " .. tostring(tr:isActive()))
end

--@api-stub: LScreenTransition:update
do
    local tr = lurek.effect.newTransition("fade", 0.5)
    tr:play()
    local still_active = tr:update(0.25)
    print("still active = " .. tostring(still_active))
end

--@api-stub: LScreenTransition:progress
do
    local tr = lurek.effect.newTransition("fade", 1.0)
    tr:play()
    tr:update(0.5)
    print("progress = " .. tr:progress())
end

--@api-stub: LScreenTransition:isActive
do
    local tr = lurek.effect.newTransition("fade", 1.0)
    print("before play active = " .. tostring(tr:isActive()))
end

--@api-stub: LScreenTransition:isDone
do
    local tr = lurek.effect.newTransition("fade", 0.5)
    tr:play()
    tr:update(1.0)
    print("done = " .. tostring(tr:isDone()))
end

--@api-stub: LScreenTransition:kind
do
    local tr = lurek.effect.newTransition("wipe", 1.0)
    print("kind = " .. tr:kind())
end

--@api-stub: LScreenTransition:color
do
    local tr = lurek.effect.newTransition("fade", 1.0, {0, 0, 0, 1})
    local r, g, b, a = tr:color()
    print("color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LScreenTransition:setColor
do
    local tr = lurek.effect.newTransition("fade", 1.0)
    tr:setColor({1, 0, 0, 1})
    local r, g, b, a = tr:color()
    print("new color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LScreenTransition:type
do
    local tr = lurek.effect.newTransition()
    print("type = " .. tr:type())
end

--@api-stub: LScreenTransition:typeOf
do
    local tr = lurek.effect.newTransition()
    print("is ScreenTransition = " .. tostring(tr:typeOf("LScreenTransition")))
end

--- Effect Module: LOverlay extended methods


--@api-stub: LOverlay:drawToImage
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setCustomShader("chromatic")
    local img = ov:drawToImage(800, 600)
    print("img type = " .. tostring(img))
end

--@api-stub: LOverlay:getAmbientColor
do
    local ov = lurek.effect.newOverlay(800, 600)
    local r, g, b, a = ov:getAmbientColor()
    print("ambient", r, g, b, a)
end

--@api-stub: LOverlay:setCustomShader
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setCustomShader("chromatic")
    print("custom shader set")
end

--@api-stub: LOverlay:getTimeOfDay
do
    local ov = lurek.effect.newOverlay(800, 600)
    local tod = ov:getTimeOfDay()
    print("time_of_day = " .. tostring(tod))
end

--@api-stub: LOverlay:setTimeOfDay
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setTimeOfDay(0.5)
    print("time_of_day = " .. tostring(ov:getTimeOfDay()))
end

--@api-stub: LOverlay:getWater
do
    local ov = lurek.effect.newOverlay(800, 600)
    local water = ov:getWater()
    print("water = " .. tostring(water))
end

--@api-stub: LOverlay:setWater
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setWater(0.5, 2.0, 1.0)
    print("water = " .. tostring(ov:getWater()))
end

--@api-stub: LOverlay:setWaterTint
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:setWater(0.5, 2.0, 1.0)
    ov:setWaterTint(0.1, 0.4, 0.8, 0.9)
    print("water tint set")
end

--@api-stub: LOverlay:pullAmbientFromLight
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:pullAmbientFromLight()
    print("ambient pulled")
end

--@api-stub: LOverlay:pushAmbientToLight
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:pushAmbientToLight()
    print("ambient pushed")
end

--@api-stub: LOverlay:syncAmbientWithLight
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:syncAmbientWithLight("avg")
    print("ambient synced")
end

print("content/examples/effect.lua")
