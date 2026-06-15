-- content/examples/effect.lua
-- Auto-generated from content/examples2/effect_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/effect.lua

--- Effect Module Part 1: Factory functions, LPostFxEffect, LPostFxStack

--@api: lurek.effect.newEffect
do
    local fx = lurek.effect.newEffect("bloom")
    print("effect type = " .. fx:getType())
    print("built-in = " .. tostring(fx:isBuiltIn()))
end

--@api: lurek.effect.newCustomEffect
do
    local fx = lurek.effect.newCustomEffect(1)
    print("custom effect built-in = " .. tostring(fx:isBuiltIn()))
    print("lua type = " .. type(fx))
end

--@api: lurek.effect.newStack
do
    local stack = lurek.effect.newStack(800, 600)
    print("stack w=" .. stack:getWidth() .. " h=" .. stack:getHeight())
    print("lua type = " .. type(stack))
end

--@api: lurek.effect.newPresetStack
do
    local stack = lurek.effect.newPresetStack("retro_tv", 320, 240)
    print("preset stack effects = " .. stack:getEffectCount())
    print("lua type = " .. type(stack))
end

--@api: lurek.effect.newPass
do
    local fx = lurek.effect.newPass(2)
    print("pass type = " .. fx:getType())
    print("lua type = " .. type(fx))
end

--@api: lurek.effect.getEffectTypes
do
    local types = lurek.effect.getEffectTypes()
    print("available types = " .. #types)
    print("lua type = " .. type(types))
end

--@api: lurek.effect.getPresetNames
do
    local names = lurek.effect.getPresetNames()
    print("preset count = " .. #names)
    print("first preset = " .. tostring(names[1]))
end

--@api: lurek.effect.newImageEffect
do
    local ie = lurek.effect.newImageEffect()
    print("image effect count = " .. ie:getEffectCount())
    print("lua type = " .. type(ie))
end

--@api: lurek.effect.setShaderErrorDisplay
do
    lurek.effect.setShaderErrorDisplay(true)
    print("shader errors on")
    print("shader error display = " .. tostring(lurek.effect.getShaderErrorDisplay()))
end

--@api: lurek.effect.getShaderErrorDisplay
do
    local on = lurek.effect.getShaderErrorDisplay()
    print("shader error display = " .. tostring(on))
    print("lua type = " .. type(on))
end

--@api: LPostFxEffect:getType
do
    local fx = lurek.effect.newEffect("blur")
    print("type = " .. fx:getType())
    print("owner type = " .. tostring(fx:type()))
end

--@api: LPostFxEffect:getTypeName
do
    local fx = lurek.effect.newEffect("crt")
    print("typeName = " .. fx:getTypeName())
    print("owner type = " .. tostring(fx:type()))
end

--@api: LPostFxEffect:getEffectType
do
    local fx = lurek.effect.newEffect("bloom")
    print("effectType = " .. fx:getEffectType())
    print("owner type = " .. tostring(fx:type()))
end

--@api: LPostFxEffect:isBuiltIn
do
    local fx = lurek.effect.newEffect("blur")
    print("builtIn = " .. tostring(fx:isBuiltIn()))
    print("owner type = " .. tostring(fx:type()))
end

--@api: LPostFxEffect:isEnabled
do
    local fx = lurek.effect.newEffect("bloom")
    print("enabled = " .. tostring(fx:isEnabled()))
    print("owner type = " .. tostring(fx:type()))
end

--@api: LPostFxEffect:setEnabled
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setEnabled(false)
    print("after disable = " .. tostring(fx:isEnabled()))
end

--@api: LPostFxEffect:setParameter
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setParameter("threshold", 0.8)
    print("param set")
end

--@api: LPostFxEffect:getParameter
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setParameter("intensity", 1.5)
    local v = fx:getParameter("intensity", 1.0)
    print("intensity = " .. v)
end

--@api: LPostFxEffect:hasParameter
do
    local fx = lurek.effect.newEffect("blur")
    fx:setParameter("radius", 4)
    print("has radius = " .. tostring(fx:hasParameter("radius")))
end

--@api: LPostFxEffect:getParameterNames
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setParameter("threshold", 0.5)
    local names = fx:getParameterNames()
    print("param names = " .. #names)
end

--@api: LPostFxEffect:setIntensity
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setIntensity(2.0)
    print("intensity set")
end

--@api: LPostFxEffect:setStrength
do
    local fx = lurek.effect.newEffect("blur")
    fx:setStrength(0.5)
    print("strength set")
end

--@api: LPostFxEffect:setRadius
do
    local fx = lurek.effect.newEffect("blur")
    fx:setRadius(8)
    print("radius set")
end

--@api: LPostFxEffect:setThreshold
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setThreshold(0.6)
    print("threshold set")
end

--@api: LPostFxEffect:setBrightness
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setBrightness(1.2)
    print("brightness set")
end

--@api: LPostFxEffect:setContrast
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setContrast(1.1)
    print("contrast set")
end

--@api: LPostFxEffect:setSaturation
do
    local fx = lurek.effect.newEffect("bloom")
    fx:setSaturation(0.8)
    print("saturation set")
end

--@api: LPostFxEffect:setOffset
do
    local fx = lurek.effect.newEffect("crt")
    fx:setOffset(0.002)
    print("offset set")
end

--@api: LPostFxEffect:setScanlineStrength
do
    local fx = lurek.effect.newEffect("crt")
    fx:setScanlineStrength(0.3)
    print("scanline set")
end

--@api: LPostFxEffect:enableAutoUniforms
do
    local fx = lurek.effect.newEffect("bloom")
    fx:enableAutoUniforms()
    print("auto uniforms on = " .. tostring(fx:isAutoUniforms()))
end

--@api: LPostFxEffect:disableAutoUniforms
do
    local fx = lurek.effect.newEffect("bloom")
    fx:disableAutoUniforms()
    print("auto uniforms off = " .. tostring(fx:isAutoUniforms()))
end

--@api: LPostFxEffect:isAutoUniforms
do
    local fx = lurek.effect.newEffect("bloom")
    print("autoUniforms = " .. tostring(fx:isAutoUniforms()))
    print("owner type = " .. tostring(fx:type()))
end

--@api: LPostFxEffect:type
do
    local fx = lurek.effect.newEffect("blur")
    print("type = " .. fx:type())
    print("typeOf LObject = " .. tostring(fx:typeOf("LObject")))
end

--@api: LPostFxEffect:typeOf
do
    local fx = lurek.effect.newEffect("blur")
    print("is PostFxEffect = " .. tostring(fx:typeOf("LPostFxEffect")))
    print("type = " .. tostring(fx:type()))
end

--@api: LPostFxStack:add
do
    local stack = lurek.effect.newStack(800, 600)
    local fx = lurek.effect.newEffect("bloom")
    stack:add(fx)
    print("stack count = " .. stack:getEffectCount())
end

--@api: LPostFxStack:remove
do
    local stack = lurek.effect.newStack(800, 600)
    local fx = lurek.effect.newEffect("blur")
    stack:add(fx)
    local ok = stack:remove(fx)
    print("removed = " .. tostring(ok))
end

--@api: LPostFxStack:insert
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:insert(1, lurek.effect.newEffect("blur"))
    print("after insert count = " .. stack:getEffectCount())
end

--@api: LPostFxStack:setEnabled
do
    local stack = lurek.effect.newStack(800, 600)
    local fx = lurek.effect.newEffect("bloom")
    stack:add(fx)
    stack:setEnabled(1, false)
    print("pass 1 enabled = " .. tostring(stack:isEnabled(1)))
end

--@api: LPostFxStack:isEnabled
do
    local stack = lurek.effect.newStack(800, 600)
    local fx = lurek.effect.newEffect("blur")
    stack:add(fx)
    print("pass enabled = " .. tostring(stack:isEnabled(1)))
end

--@api: LPostFxStack:getEffectCount
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:add(lurek.effect.newEffect("blur"))
    print("effect count = " .. stack:getEffectCount())
end

--@api: LPostFxStack:getEffect
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    local fx = stack:getEffect(1)
    print("got effect at 1 = " .. tostring(fx ~= nil))
end

--@api: LPostFxStack:getEnabledEffects
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:add(lurek.effect.newEffect("blur"))
    local enabled = stack:getEnabledEffects()
    print("enabled effects = " .. #enabled)
end

--@api: LPostFxStack:getWidth
do
    local stack = lurek.effect.newStack(1024, 768)
    print("width = " .. stack:getWidth())
    print("owner type = " .. tostring(stack:type()))
end

--@api: LPostFxStack:getHeight
do
    local stack = lurek.effect.newStack(1024, 768)
    print("height = " .. stack:getHeight())
    print("owner type = " .. tostring(stack:type()))
end

--@api: LPostFxStack:getDimensions
do
    local stack = lurek.effect.newStack(800, 600)
    local w, h = stack:getDimensions()
    print("dims = " .. w .. "x" .. h)
end

--@api: LPostFxStack:resize
do
    local stack = lurek.effect.newStack(800, 600)
    stack:resize(1920, 1080)
    print("resized w=" .. stack:getWidth())
end

--@api: LPostFxStack:len
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    print("len = " .. stack:len())
end

--@api: LPostFxStack:isEmpty
do
    local stack = lurek.effect.newStack(800, 600)
    print("empty = " .. tostring(stack:isEmpty()))
    print("owner type = " .. tostring(stack:type()))
end

--@api: LPostFxStack:clear
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:clear()
    print("after clear = " .. stack:getEffectCount())
end

--- Effect Module Part 2: LPostFxStack feedback/capture, LImageEffect, LOverlay triggers and state

--@api: LPostFxStack:dedup
do
    local stack = lurek.effect.newStack(800, 600)
    local fx = lurek.effect.newEffect("bloom")
    stack:add(fx)
    stack:add(fx)
    local removed = stack:dedup()
    print("dedup removed = " .. removed)
end

--@api: LPostFxStack:isCapturing
do
    local stack = lurek.effect.newStack(800, 600)
    print("capturing = " .. tostring(stack:isCapturing()))
    print("owner type = " .. tostring(stack:type()))
end

--@api: LPostFxStack:beginCapture
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:beginCapture()
    print("capture started")
end

--@api: LPostFxStack:endCapture
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:beginCapture()
    stack:endCapture()
    print("capture ended")
end

--@api: LPostFxStack:apply
do
    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:beginCapture()
    stack:endCapture()
    stack:apply()
    print("applied")
end

--@api: LPostFxStack:setFeedback
do
    local stack = lurek.effect.newStack(800, 600)
    stack:setFeedback(0.5)
    print("feedback = " .. stack:getFeedback())
end

--@api: LPostFxStack:getFeedback
do
    local stack = lurek.effect.newStack(800, 600)
    stack:setFeedback(0.3)
    print("feedback = " .. stack:getFeedback())
end

--@api: LPostFxStack:clearFeedback
do
    local stack = lurek.effect.newStack(800, 600)
    stack:setFeedback(0.8)
    stack:clearFeedback()
    print("cleared feedback = " .. stack:getFeedback())
end

--@api: LPostFxStack:type
do
    local stack = lurek.effect.newStack(800, 600)
    print("type = " .. stack:type())
    print("typeOf LObject = " .. tostring(stack:typeOf("LObject")))
end

--@api: LPostFxStack:typeOf
do
    local stack = lurek.effect.newStack(800, 600)
    print("is PostFxStack = " .. tostring(stack:typeOf("LPostFxStack")))
    print("type = " .. tostring(stack:type()))
end

--@api: LImageEffect:addEffect
do
    local ie = lurek.effect.newImageEffect()
    local fx = ie:addEffect("bloom")
    print("added effect type = " .. fx:getType())
end

--@api: LImageEffect:getEffect
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("blur")
    local fx = ie:getEffect("blur")
    print("found effect = " .. tostring(fx ~= nil))
end

--@api: LImageEffect:getEffectCount
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    ie:addEffect("blur")
    print("count = " .. ie:getEffectCount())
end

--@api: LImageEffect:effectCount
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("crt")
    print("effectCount = " .. ie:effectCount())
end

--@api: LImageEffect:removeEffect
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    local ok = ie:removeEffect("bloom")
    print("removed = " .. tostring(ok))
end

--@api: LImageEffect:removeByName
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("blur")
    local ok = ie:removeByName("blur")
    print("removeByName = " .. tostring(ok))
end

--@api: LImageEffect:removeByIndex
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    local ok = ie:removeByIndex(0)
    print("removeByIndex = " .. tostring(ok))
end

--@api: LImageEffect:clear
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    ie:clear()
    print("after clear = " .. ie:getEffectCount())
end

--@api: LImageEffect:clearEffects
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("crt")
    ie:clearEffects()
    print("after clearEffects = " .. ie:getEffectCount())
end

--@api: LImageEffect:clone
do
    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    local copy = ie:clone()
    print("clone count = " .. copy:getEffectCount())
end

--@api: LImageEffect:save
do
    local ie = lurek.effect.newImageEffect()
    local ok = ie:save()
    print("save = " .. tostring(ok))
end

--@api: LImageEffect:type
do
    local ie = lurek.effect.newImageEffect()
    print("type = " .. ie:type())
    print("typeOf LObject = " .. tostring(ie:typeOf("LObject")))
end

--@api: LImageEffect:typeOf
do
    local ie = lurek.effect.newImageEffect()
    print("is ImageEffect = " .. tostring(ie:typeOf("LImageEffect")))
    print("type = " .. tostring(ie:type()))
end
