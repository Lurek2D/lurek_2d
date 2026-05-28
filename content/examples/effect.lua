-- content/examples/effect.lua
-- Auto-generated from content/examples2/effect_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/effect.lua

--- Effect Module Part 1: Factory functions, LPostFxEffect, LPostFxStack

--@api-stub: lurek.effect.newEffect
do
    local fx = lurek.effect.newEffect("bloom")
    print("effect type = " .. fx:getType())
    print("built-in = " .. tostring(fx:isBuiltIn()))
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

--@api-stub: lurek.effect.getPresetNames
do
    local names = lurek.effect.getPresetNames()
    print("preset count = " .. #names)
    print("first preset = " .. tostring(names[1]))
end

--@api-stub: lurek.effect.newImageEffect
do
    local ie = lurek.effect.newImageEffect()
    print("image effect count = " .. ie:getEffectCount())
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
    stack:add(fx)
    stack:add(fx)
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
    stack:add(lurek.effect.newEffect("bloom"))
    stack:beginCapture()
    stack:endCapture()
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
