-- content/examples/effect.lua
-- Auto-generated from content/examples2/effect_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/effect.lua


--- Effect Module Part 1: Factory functions, LPostFxEffect, LPostFxStack


--@api: lurek.effect.newEffect
do

    local fx = lurek.effect.newEffect("bloom")
    fx:setThreshold(0.65)
    fx:setIntensity(1.8)
    local effect_type = fx:getType()
    lurek.log.info("cinematic " .. effect_type .. " built_in=" .. tostring(fx:isBuiltIn()))
end

--@api: lurek.effect.newCustomEffect
do

    local shader = lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb + uv.xyx * 0.0, color.a);
}
]], { target = "postfx" })
    local fx = lurek.effect.newCustomEffect(shader)
    fx:setParameter("distortion", 0.15)
    fx:disableAutoUniforms()
    local enabled = fx:isEnabled()
    lurek.log.info("custom pass built_in=" .. tostring(fx:isBuiltIn()) .. " enabled=" .. tostring(enabled))
end

--@api: lurek.effect.newStack
do

    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:add(lurek.effect.newEffect("blur"))
    local w, h = stack:getDimensions()
    lurek.log.info("combat stack " .. w .. "x" .. h .. " effects=" .. stack:getEffectCount())
end

--@api: lurek.effect.newPresetStack
do

    local stack = lurek.effect.newPresetStack("retro_tv", 320, 240)
    stack:setFeedback(0.2)
    local count = stack:getEffectCount()
    local w, h = stack:getDimensions()
    lurek.log.info("retro preset effects=" .. count .. " size=" .. w .. "x" .. h)
end

--@api: lurek.effect.newPass
do

    local shader = lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb + uv.xyx * 0.0, color.a);
}
]], { target = "postfx" })
    local fx = lurek.effect.newPass(shader)
    fx:setParameter("exposure", 1.1)
    fx:enableAutoUniforms()
    local type_name = fx:getType()
    lurek.log.info("custom pass type=" .. type_name .. " auto_uniforms=" .. tostring(fx:isAutoUniforms()))
end

--@api: lurek.effect.getEffectTypes
do

    local types = lurek.effect.getEffectTypes()
    local stack = lurek.effect.newStack(640, 360)
    stack:add(lurek.effect.newEffect(types[1] or "bloom"))
    local first = types[1] or "none"
    lurek.log.info("effect catalog size=" .. #types .. " first=" .. first)
end

--@api: lurek.effect.getPresetNames
do

    local names = lurek.effect.getPresetNames()
    local preset = names[1] or "retro_tv"
    local stack = lurek.effect.newPresetStack(preset, 320, 180)
    local count = stack:getEffectCount()
    lurek.log.info("preset catalog size=" .. #names .. " sample=" .. preset .. " effects=" .. count)
end

--@api: lurek.effect.newImageEffect
do

    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    ie:addEffect("blur")
    local count = ie:getEffectCount()
    lurek.log.info("thumbnail chain effects=" .. count)
end

--@api: lurek.effect.setShaderErrorDisplay
do

    lurek.effect.setShaderErrorDisplay(true)
    local fx = lurek.effect.newEffect("blur")
    fx:setRadius(6.0)
    local shown = lurek.effect.getShaderErrorDisplay()
    lurek.log.info("shader errors visible=" .. tostring(shown))
end

--@api: lurek.effect.getShaderErrorDisplay
do

    local on = lurek.effect.getShaderErrorDisplay()
    local stack = lurek.effect.newStack(320, 180)
    stack:add(lurek.effect.newEffect("bloom"))
    local count = stack:getEffectCount()
    lurek.log.info("shader overlay=" .. tostring(on) .. " stack effects=" .. count)
end

--@api: LPostFxEffect:getType
do

    local fx = lurek.effect.newEffect("blur")
    fx:setRadius(8.0)
    fx:setStrength(0.4)
    local effect_type = fx:getType()
    lurek.log.info("pause blur type=" .. effect_type .. " owner=" .. fx:type())
end

--@api: LPostFxEffect:getTypeName
do

    local fx = lurek.effect.newEffect("crt")
    fx:setScanlineStrength(0.35)
    fx:setEnabled(true)
    local type_name = fx:getTypeName()
    lurek.log.info("crt type name=" .. type_name .. " owner=" .. fx:type())
end

--@api: LPostFxEffect:getEffectType
do

    local fx = lurek.effect.newEffect("bloom")
    fx:setThreshold(0.7)
    fx:setIntensity(1.6)
    local effect_type = fx:getEffectType()
    lurek.log.info("effect type=" .. effect_type .. " owner=" .. fx:type())
end

--@api: LPostFxEffect:isBuiltIn
do

    local fx = lurek.effect.newEffect("blur")
    fx:setRadius(4.0)
    fx:setEnabled(true)
    local built_in = fx:isBuiltIn()
    lurek.log.info("built_in=" .. tostring(built_in) .. " owner=" .. fx:type())
end

--@api: LPostFxEffect:isEnabled
do

    local fx = lurek.effect.newEffect("bloom")
    fx:setIntensity(2.2)
    fx:setThreshold(0.6)
    local enabled = fx:isEnabled()
    lurek.log.info("bloom enabled=" .. tostring(enabled) .. " owner=" .. fx:type())
end

--@api: LPostFxEffect:setEnabled
do

    local fx = lurek.effect.newEffect("bloom")
    fx:setEnabled(false)
    fx:setIntensity(2.0)
    local enabled = fx:isEnabled()
    lurek.log.info("photo bloom enabled=" .. tostring(enabled))
end

--@api: LPostFxEffect:setParameter
do

    local fx = lurek.effect.newEffect("bloom")
    fx:setParameter("threshold", 0.8)
    fx:setParameter("intensity", 1.4)
    local threshold = fx:getParameter("threshold", 0.0)
    lurek.log.info("custom threshold=" .. threshold)
end

--@api: LPostFxEffect:getParameter
do

    local fx = lurek.effect.newEffect("bloom")
    fx:setParameter("intensity", 1.5)
    local v = fx:getParameter("intensity", 1.0)
    fx:setEnabled(true)
    lurek.log.info("intensity=" .. v .. " enabled=" .. tostring(fx:isEnabled()))
end

--@api: LPostFxEffect:hasParameter
do

    local fx = lurek.effect.newEffect("blur")
    fx:setParameter("radius", 4)
    fx:setStrength(0.4)
    local has_radius = fx:hasParameter("radius")
    lurek.log.info("has radius=" .. tostring(has_radius) .. " names=" .. #fx:getParameterNames())
end

--@api: LPostFxEffect:getParameterNames
do

    local fx = lurek.effect.newEffect("bloom")
    fx:setParameter("threshold", 0.5)
    fx:setParameter("intensity", 1.3)
    local names = fx:getParameterNames()
    local first = names[1] or "none"
    lurek.log.info("parameter names=" .. #names .. " first=" .. first)
end

--@api: LPostFxEffect:setIntensity
do

    local fx = lurek.effect.newEffect("bloom")
    fx:setIntensity(2.0)
    fx:setThreshold(0.6)
    local intensity = fx:getParameter("intensity", 0.0)
    lurek.log.info("bloom intensity=" .. intensity)
end

--@api: LPostFxEffect:setStrength
do

    local fx = lurek.effect.newEffect("blur")
    fx:setStrength(0.5)
    fx:setRadius(6.0)
    local strength = fx:getParameter("strength", 0.0)
    lurek.log.info("blur strength=" .. strength)
end

--@api: LPostFxEffect:setRadius
do

    local fx = lurek.effect.newEffect("blur")
    fx:setRadius(8)
    fx:setStrength(0.25)
    local radius = fx:getParameter("radius", 0.0)
    lurek.log.info("blur radius=" .. radius)
end

--@api: LPostFxEffect:setThreshold
do

    local fx = lurek.effect.newEffect("bloom")
    fx:setThreshold(0.6)
    fx:setIntensity(1.7)
    local threshold = fx:getParameter("threshold", 0.0)
    lurek.log.info("bloom threshold=" .. threshold)
end

--@api: LPostFxEffect:setBrightness
do

    local fx = lurek.effect.newEffect("colourgrade")
    fx:setBrightness(1.2)
    fx:setContrast(1.05)
    local brightness = fx:getParameter("brightness", 0.0)
    lurek.log.info("grade brightness=" .. brightness)
end

--@api: LPostFxEffect:setContrast
do

    local fx = lurek.effect.newEffect("colourgrade")
    fx:setContrast(1.1)
    fx:setBrightness(0.95)
    local contrast = fx:getParameter("contrast", 0.0)
    lurek.log.info("grade contrast=" .. contrast)
end

--@api: LPostFxEffect:setSaturation
do

    local fx = lurek.effect.newEffect("colourgrade")
    fx:setSaturation(0.8)
    fx:setContrast(1.1)
    local saturation = fx:getParameter("saturation", 0.0)
    lurek.log.info("grade saturation=" .. saturation)
end

--@api: LPostFxEffect:setOffset
do

    local fx = lurek.effect.newEffect("chromatic")
    fx:setOffset(0.002)
    fx:setEnabled(true)
    local offset = fx:getParameter("offset", 0.0)
    lurek.log.info("chromatic offset=" .. offset)
end

--@api: LPostFxEffect:setScanlineStrength
do

    local fx = lurek.effect.newEffect("crt")
    fx:setScanlineStrength(0.3)
    fx:setEnabled(true)
    local scanline = fx:getParameter("scanline_strength", 0.0)
    lurek.log.info("crt scanlines=" .. scanline)
end

--@api: LPostFxEffect:enableAutoUniforms
do

    local fx = lurek.effect.newEffect("bloom")
    fx:enableAutoUniforms()
    fx:setIntensity(1.4)
    local auto = fx:isAutoUniforms()
    lurek.log.info("auto uniforms on=" .. tostring(auto))
end

--@api: LPostFxEffect:disableAutoUniforms
do

    local fx = lurek.effect.newEffect("bloom")
    fx:disableAutoUniforms()
    fx:setIntensity(1.4)
    local auto = fx:isAutoUniforms()
    lurek.log.info("auto uniforms on=" .. tostring(auto))
end

--@api: LPostFxEffect:isAutoUniforms
do

    local fx = lurek.effect.newEffect("bloom")
    fx:enableAutoUniforms()
    fx:setThreshold(0.7)
    local auto = fx:isAutoUniforms()
    lurek.log.info("auto uniforms=" .. tostring(auto) .. " owner=" .. fx:type())
end

--@api: LPostFxEffect:type
do

    local fx = lurek.effect.newEffect("blur")
    fx:setRadius(5.0)
    fx:setEnabled(true)
    local type_name = fx:type()
    lurek.log.info(type_name .. " object=" .. tostring(fx:typeOf("LObject")))
end

--@api: LPostFxEffect:typeOf
do

    local fx = lurek.effect.newEffect("blur")
    fx:setRadius(5.0)
    fx:setStrength(0.4)
    local is_effect = fx:typeOf("LPostFxEffect")
    lurek.log.info("is effect=" .. tostring(is_effect) .. " type=" .. fx:type())
end

--@api: LPostFxStack:add
do

    local stack = lurek.effect.newStack(800, 600)
    local fx = lurek.effect.newEffect("bloom")
    stack:add(fx)
    stack:add(lurek.effect.newEffect("blur"))
    local count = stack:getEffectCount()
    lurek.log.info("stack count=" .. count)
end

--@api: LPostFxStack:remove
do

    local stack = lurek.effect.newStack(800, 600)
    local fx = lurek.effect.newEffect("blur")
    stack:add(fx)
    local ok = stack:remove(fx)
    lurek.log.info(tostring("removed = " .. tostring(ok)))
end

--@api: LPostFxStack:insert
do

    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:insert(1, lurek.effect.newEffect("blur"))
    local first = stack:getEffect(1)
    local count = stack:getEffectCount()
    lurek.log.info("after insert count=" .. count .. " first=" .. tostring(first and first:getType()))
end

--@api: LPostFxStack:setEnabled
do

    local stack = lurek.effect.newStack(800, 600)
    local fx = lurek.effect.newEffect("bloom")
    stack:add(fx)
    stack:setEnabled(1, false)
    lurek.log.info(tostring("pass 1 enabled = " .. tostring(stack:isEnabled(1))))
end

--@api: LPostFxStack:isEnabled
do

    local stack = lurek.effect.newStack(800, 600)
    local fx = lurek.effect.newEffect("blur")
    stack:add(fx)
    fx:setEnabled(true)
    local enabled = stack:isEnabled(1)
    lurek.log.info("pass enabled=" .. tostring(enabled) .. " count=" .. stack:getEffectCount())
end

--@api: LPostFxStack:getEffectCount
do

    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:add(lurek.effect.newEffect("blur"))
    local count = stack:getEffectCount()
    local enabled = #stack:getEnabledEffects()
    lurek.log.info("effect count=" .. count .. " enabled=" .. enabled)
end

--@api: LPostFxStack:getEffect
do

    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    local fx = stack:getEffect(1)
    local count = stack:getEffectCount()
    local kind = fx and fx:getType() or "none"
    lurek.log.info("got effect=" .. kind .. " count=" .. count)
end

--@api: LPostFxStack:getEnabledEffects
do

    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:add(lurek.effect.newEffect("blur"))
    local enabled = stack:getEnabledEffects()
    lurek.log.info(tostring("enabled effects = " .. #enabled))
end

--@api: LPostFxStack:getWidth
do

    local stack = lurek.effect.newStack(1024, 768)
    stack:add(lurek.effect.newEffect("bloom"))
    local width = stack:getWidth()
    local count = stack:getEffectCount()
    lurek.log.info("stack width=" .. width .. " effects=" .. count)
end

--@api: LPostFxStack:getHeight
do

    local stack = lurek.effect.newStack(1024, 768)
    stack:add(lurek.effect.newEffect("bloom"))
    local height = stack:getHeight()
    local count = stack:getEffectCount()
    lurek.log.info("stack height=" .. height .. " effects=" .. count)
end

--@api: LPostFxStack:getDimensions
do

    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("blur"))
    local w, h = stack:getDimensions()
    local count = stack:getEffectCount()
    lurek.log.info("dims=" .. w .. "x" .. h .. " effects=" .. count)
end

--@api: LPostFxStack:resize
do

    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:resize(1920, 1080)
    local w, h = stack:getDimensions()
    lurek.log.info("resized to " .. w .. "x" .. h)
end

--@api: LPostFxStack:len
do

    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:add(lurek.effect.newEffect("blur"))
    local len = stack:len()
    lurek.log.info("len=" .. len .. " enabled=" .. #stack:getEnabledEffects())
end

--@api: LPostFxStack:isEmpty
do

    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    local empty = stack:isEmpty()
    local count = stack:getEffectCount()
    lurek.log.info("empty=" .. tostring(empty) .. " count=" .. count)
end

--@api: LPostFxStack:clear
do

    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:clear()
    local count = stack:getEffectCount()
    local empty = stack:isEmpty()
    lurek.log.info("after clear count=" .. count .. " empty=" .. tostring(empty))
end

--- Effect Module Part 2: LPostFxStack feedback/capture, LImageEffect, LOverlay triggers and state

--@api: LPostFxStack:dedup
do

    local stack = lurek.effect.newStack(800, 600)
    local fx = lurek.effect.newEffect("bloom")
    stack:add(fx)
    stack:add(fx)
    local removed = stack:dedup()
    lurek.log.info(tostring("dedup removed = " .. removed))
end

--@api: LPostFxStack:isCapturing
do

    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:setFeedback(0.15)
    local capturing = stack:isCapturing()
    lurek.log.info("capturing=" .. tostring(capturing) .. " feedback=" .. stack:getFeedback())
end

--@api: LPostFxStack:beginCapture
do

    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:beginCapture()
    local capturing = stack:isCapturing()
    local count = stack:getEffectCount()
    lurek.log.info("capture started=" .. tostring(capturing) .. " effects=" .. count)
end

--@api: LPostFxStack:endCapture
do

    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:beginCapture()
    stack:endCapture()
    lurek.log.info(tostring("capture ended"))
end

--@api: LPostFxStack:apply
do

    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:beginCapture()
    stack:endCapture()
    stack:apply()
    lurek.log.info(tostring("applied"))
end

--@api: LPostFxStack:setFeedback
do

    local stack = lurek.effect.newStack(800, 600)
    stack:setFeedback(0.5)
    stack:add(lurek.effect.newEffect("crt"))
    local feedback = stack:getFeedback()
    lurek.log.info("feedback=" .. feedback .. " effects=" .. stack:getEffectCount())
end

--@api: LPostFxStack:getFeedback
do

    local stack = lurek.effect.newStack(800, 600)
    stack:setFeedback(0.3)
    stack:add(lurek.effect.newEffect("crt"))
    local feedback = stack:getFeedback()
    lurek.log.info("feedback=" .. feedback .. " width=" .. stack:getWidth())
end

--@api: LPostFxStack:clearFeedback
do

    local stack = lurek.effect.newStack(800, 600)
    stack:setFeedback(0.8)
    stack:clearFeedback()
    local feedback = stack:getFeedback()
    local capturing = stack:isCapturing()
    lurek.log.info("cleared feedback=" .. feedback .. " capturing=" .. tostring(capturing))
end

--@api: LPostFxStack:type
do

    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    local type_name = stack:type()
    local is_object = stack:typeOf("LObject")
    lurek.log.info(type_name .. " object=" .. tostring(is_object))
end

--@api: LPostFxStack:typeOf
do

    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    local is_stack = stack:typeOf("LPostFxStack")
    local type_name = stack:type()
    lurek.log.info("is stack=" .. tostring(is_stack) .. " type=" .. type_name)
end

--@api: LImageEffect:addEffect
do

    local ie = lurek.effect.newImageEffect()
    local fx = ie:addEffect("bloom")
    ie:addEffect("blur")
    local count = ie:getEffectCount()
    lurek.log.info("added effect=" .. fx:getType() .. " count=" .. count)
end

--@api: LImageEffect:getEffect
do

    local ie = lurek.effect.newImageEffect()
    ie:addEffect("blur")
    local fx = ie:getEffect("blur")
    ie:addEffect("bloom")
    local count = ie:getEffectCount()
    lurek.log.info("found blur=" .. tostring(fx ~= nil) .. " count=" .. count)
end

--@api: LImageEffect:getEffectCount
do

    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    ie:addEffect("blur")
    local count = ie:getEffectCount()
    local first = ie:getEffect(1)
    lurek.log.info("count=" .. count .. " first=" .. tostring(first and first:getType()))
end

--@api: LImageEffect:effectCount
do

    local ie = lurek.effect.newImageEffect()
    ie:addEffect("crt")
    ie:addEffect("bloom")
    local count = ie:effectCount()
    lurek.log.info("effectCount=" .. count .. " cloneable=" .. tostring(ie:clone() ~= nil))
end

--@api: LImageEffect:removeEffect
do

    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    local ok = ie:removeEffect("bloom")
    local count = ie:getEffectCount()
    lurek.log.info("removed=" .. tostring(ok) .. " count=" .. count)
end

--@api: LImageEffect:removeByName
do

    local ie = lurek.effect.newImageEffect()
    ie:addEffect("blur")
    local ok = ie:removeByName("blur")
    local count = ie:getEffectCount()
    lurek.log.info("removeByName=" .. tostring(ok) .. " count=" .. count)
end

--@api: LImageEffect:removeByIndex
do

    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    local ok = ie:removeByIndex(0)
    local count = ie:getEffectCount()
    lurek.log.info("removeByIndex=" .. tostring(ok) .. " count=" .. count)
end

--@api: LImageEffect:clear
do

    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    ie:clear()
    local count = ie:getEffectCount()
    local empty = ie:effectCount()
    lurek.log.info("after clear count=" .. count .. " effectCount=" .. empty)
end

--@api: LImageEffect:clearEffects
do

    local ie = lurek.effect.newImageEffect()
    ie:addEffect("crt")
    ie:clearEffects()
    local count = ie:getEffectCount()
    local empty = ie:effectCount()
    lurek.log.info("after clearEffects count=" .. count .. " effectCount=" .. empty)
end

--@api: LImageEffect:clone
do

    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    local copy = ie:clone()
    copy:addEffect("blur")
    local count = copy:getEffectCount()
    lurek.log.info("clone count=" .. count .. " source=" .. ie:getEffectCount())
end

--@api: LImageEffect:save
do

    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    ie:addEffect("crt")
    local ok = ie:save()
    local count = ie:getEffectCount()
    lurek.log.info("save=" .. tostring(ok) .. " count=" .. count)
end

--@api: LPostFxStack:snapshot
do
    local stack = lurek.effect.newStack(640, 360)
    stack:add(lurek.effect.newEffect("blur"))
    stack:setFeedback(0.35)
    local snapshot = stack:snapshot()
    lurek.log.info("effect snapshot effects=" .. tostring(#snapshot.effects))
end

--@api: LPostFxStack:restore
do
    local source = lurek.effect.newStack(640, 360)
    source:add(lurek.effect.newEffect("vignette"))
    local target = lurek.effect.newStack(320, 240)
    target:restore(source:snapshot())
    local width, height = target:getDimensions()
    lurek.log.info("effect restored dimensions=" .. tostring(width) .. "x" .. tostring(height))
end

--@api: LImageEffect:type
do

    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    local type_name = ie:type()
    local is_object = ie:typeOf("LObject")
    lurek.log.info(type_name .. " object=" .. tostring(is_object))
end

--@api: LImageEffect:typeOf
do

    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    local is_image_effect = ie:typeOf("LImageEffect")
    local type_name = ie:type()
    lurek.log.info("is image effect=" .. tostring(is_image_effect) .. " type=" .. type_name)
end
