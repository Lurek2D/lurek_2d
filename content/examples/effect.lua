-- content/examples/effect.lua
-- Auto-generated from content/examples2/effect_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/effect.lua


--- Effect Module Part 1: Factory functions, LPostFxEffect, LPostFxStack


--@api: lurek.effect.newEffect
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fx = lurek.effect.newEffect("bloom")
    fx:setThreshold(0.65)
    fx:setIntensity(1.8)
    local effect_type = fx:getType()
    effect_log("cinematic " .. effect_type .. " built_in=" .. tostring(fx:isBuiltIn()))
end

--@api: lurek.effect.newCustomEffect
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local shader = lurek.shader.new([[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb + uv.xyx * 0.0, color.a);
}
]], { target = "postfx" })
    local fx = lurek.effect.newCustomEffect(shader)
    fx:setParameter("distortion", 0.15)
    fx:disableAutoUniforms()
    local enabled = fx:isEnabled()
    effect_log("custom pass built_in=" .. tostring(fx:isBuiltIn()) .. " enabled=" .. tostring(enabled))
end

--@api: lurek.effect.newStack
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:add(lurek.effect.newEffect("blur"))
    local w, h = stack:getDimensions()
    effect_log("combat stack " .. w .. "x" .. h .. " effects=" .. stack:getEffectCount())
end

--@api: lurek.effect.newPresetStack
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local stack = lurek.effect.newPresetStack("retro_tv", 320, 240)
    stack:setFeedback(0.2)
    local count = stack:getEffectCount()
    local w, h = stack:getDimensions()
    effect_log("retro preset effects=" .. count .. " size=" .. w .. "x" .. h)
end

--@api: lurek.effect.newPass
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local shader = lurek.shader.new([[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb + uv.xyx * 0.0, color.a);
}
]], { target = "postfx" })
    local fx = lurek.effect.newPass(shader)
    fx:setParameter("exposure", 1.1)
    fx:enableAutoUniforms()
    local type_name = fx:getType()
    effect_log("custom pass type=" .. type_name .. " auto_uniforms=" .. tostring(fx:isAutoUniforms()))
end

--@api: lurek.effect.getEffectTypes
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local types = lurek.effect.getEffectTypes()
    local stack = lurek.effect.newStack(640, 360)
    stack:add(lurek.effect.newEffect(types[1] or "bloom"))
    local first = types[1] or "none"
    effect_log("effect catalog size=" .. #types .. " first=" .. first)
end

--@api: lurek.effect.getPresetNames
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local names = lurek.effect.getPresetNames()
    local preset = names[1] or "retro_tv"
    local stack = lurek.effect.newPresetStack(preset, 320, 180)
    local count = stack:getEffectCount()
    effect_log("preset catalog size=" .. #names .. " sample=" .. preset .. " effects=" .. count)
end

--@api: lurek.effect.newImageEffect
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    ie:addEffect("blur")
    local count = ie:getEffectCount()
    effect_log("thumbnail chain effects=" .. count)
end

--@api: lurek.effect.setShaderErrorDisplay
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.effect.setShaderErrorDisplay(true)
    local fx = lurek.effect.newEffect("blur")
    fx:setRadius(6.0)
    local shown = lurek.effect.getShaderErrorDisplay()
    effect_log("shader errors visible=" .. tostring(shown))
end

--@api: lurek.effect.getShaderErrorDisplay
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local on = lurek.effect.getShaderErrorDisplay()
    local stack = lurek.effect.newStack(320, 180)
    stack:add(lurek.effect.newEffect("bloom"))
    local count = stack:getEffectCount()
    effect_log("shader overlay=" .. tostring(on) .. " stack effects=" .. count)
end

--@api: LPostFxEffect:getType
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fx = lurek.effect.newEffect("blur")
    fx:setRadius(8.0)
    fx:setStrength(0.4)
    local effect_type = fx:getType()
    effect_log("pause blur type=" .. effect_type .. " owner=" .. fx:type())
end

--@api: LPostFxEffect:getTypeName
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fx = lurek.effect.newEffect("crt")
    fx:setScanlineStrength(0.35)
    fx:setEnabled(true)
    local type_name = fx:getTypeName()
    effect_log("crt type name=" .. type_name .. " owner=" .. fx:type())
end

--@api: LPostFxEffect:getEffectType
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fx = lurek.effect.newEffect("bloom")
    fx:setThreshold(0.7)
    fx:setIntensity(1.6)
    local effect_type = fx:getEffectType()
    effect_log("effect type=" .. effect_type .. " owner=" .. fx:type())
end

--@api: LPostFxEffect:isBuiltIn
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fx = lurek.effect.newEffect("blur")
    fx:setRadius(4.0)
    fx:setEnabled(true)
    local built_in = fx:isBuiltIn()
    effect_log("built_in=" .. tostring(built_in) .. " owner=" .. fx:type())
end

--@api: LPostFxEffect:isEnabled
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fx = lurek.effect.newEffect("bloom")
    fx:setIntensity(2.2)
    fx:setThreshold(0.6)
    local enabled = fx:isEnabled()
    effect_log("bloom enabled=" .. tostring(enabled) .. " owner=" .. fx:type())
end

--@api: LPostFxEffect:setEnabled
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fx = lurek.effect.newEffect("bloom")
    fx:setEnabled(false)
    fx:setIntensity(2.0)
    local enabled = fx:isEnabled()
    effect_log("photo bloom enabled=" .. tostring(enabled))
end

--@api: LPostFxEffect:setParameter
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fx = lurek.effect.newEffect("bloom")
    fx:setParameter("threshold", 0.8)
    fx:setParameter("intensity", 1.4)
    local threshold = fx:getParameter("threshold", 0.0)
    effect_log("custom threshold=" .. threshold)
end

--@api: LPostFxEffect:getParameter
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fx = lurek.effect.newEffect("bloom")
    fx:setParameter("intensity", 1.5)
    local v = fx:getParameter("intensity", 1.0)
    fx:setEnabled(true)
    effect_log("intensity=" .. v .. " enabled=" .. tostring(fx:isEnabled()))
end

--@api: LPostFxEffect:hasParameter
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fx = lurek.effect.newEffect("blur")
    fx:setParameter("radius", 4)
    fx:setStrength(0.4)
    local has_radius = fx:hasParameter("radius")
    effect_log("has radius=" .. tostring(has_radius) .. " names=" .. #fx:getParameterNames())
end

--@api: LPostFxEffect:getParameterNames
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fx = lurek.effect.newEffect("bloom")
    fx:setParameter("threshold", 0.5)
    fx:setParameter("intensity", 1.3)
    local names = fx:getParameterNames()
    local first = names[1] or "none"
    effect_log("parameter names=" .. #names .. " first=" .. first)
end

--@api: LPostFxEffect:setIntensity
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fx = lurek.effect.newEffect("bloom")
    fx:setIntensity(2.0)
    fx:setThreshold(0.6)
    local intensity = fx:getParameter("intensity", 0.0)
    effect_log("bloom intensity=" .. intensity)
end

--@api: LPostFxEffect:setStrength
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fx = lurek.effect.newEffect("blur")
    fx:setStrength(0.5)
    fx:setRadius(6.0)
    local strength = fx:getParameter("strength", 0.0)
    effect_log("blur strength=" .. strength)
end

--@api: LPostFxEffect:setRadius
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fx = lurek.effect.newEffect("blur")
    fx:setRadius(8)
    fx:setStrength(0.25)
    local radius = fx:getParameter("radius", 0.0)
    effect_log("blur radius=" .. radius)
end

--@api: LPostFxEffect:setThreshold
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fx = lurek.effect.newEffect("bloom")
    fx:setThreshold(0.6)
    fx:setIntensity(1.7)
    local threshold = fx:getParameter("threshold", 0.0)
    effect_log("bloom threshold=" .. threshold)
end

--@api: LPostFxEffect:setBrightness
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fx = lurek.effect.newEffect("colourgrade")
    fx:setBrightness(1.2)
    fx:setContrast(1.05)
    local brightness = fx:getParameter("brightness", 0.0)
    effect_log("grade brightness=" .. brightness)
end

--@api: LPostFxEffect:setContrast
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fx = lurek.effect.newEffect("colourgrade")
    fx:setContrast(1.1)
    fx:setBrightness(0.95)
    local contrast = fx:getParameter("contrast", 0.0)
    effect_log("grade contrast=" .. contrast)
end

--@api: LPostFxEffect:setSaturation
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fx = lurek.effect.newEffect("colourgrade")
    fx:setSaturation(0.8)
    fx:setContrast(1.1)
    local saturation = fx:getParameter("saturation", 0.0)
    effect_log("grade saturation=" .. saturation)
end

--@api: LPostFxEffect:setOffset
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fx = lurek.effect.newEffect("chromatic")
    fx:setOffset(0.002)
    fx:setEnabled(true)
    local offset = fx:getParameter("offset", 0.0)
    effect_log("chromatic offset=" .. offset)
end

--@api: LPostFxEffect:setScanlineStrength
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fx = lurek.effect.newEffect("crt")
    fx:setScanlineStrength(0.3)
    fx:setEnabled(true)
    local scanline = fx:getParameter("scanline_strength", 0.0)
    effect_log("crt scanlines=" .. scanline)
end

--@api: LPostFxEffect:enableAutoUniforms
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fx = lurek.effect.newEffect("bloom")
    fx:enableAutoUniforms()
    fx:setIntensity(1.4)
    local auto = fx:isAutoUniforms()
    effect_log("auto uniforms on=" .. tostring(auto))
end

--@api: LPostFxEffect:disableAutoUniforms
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fx = lurek.effect.newEffect("bloom")
    fx:disableAutoUniforms()
    fx:setIntensity(1.4)
    local auto = fx:isAutoUniforms()
    effect_log("auto uniforms on=" .. tostring(auto))
end

--@api: LPostFxEffect:isAutoUniforms
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fx = lurek.effect.newEffect("bloom")
    fx:enableAutoUniforms()
    fx:setThreshold(0.7)
    local auto = fx:isAutoUniforms()
    effect_log("auto uniforms=" .. tostring(auto) .. " owner=" .. fx:type())
end

--@api: LPostFxEffect:type
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fx = lurek.effect.newEffect("blur")
    fx:setRadius(5.0)
    fx:setEnabled(true)
    local type_name = fx:type()
    effect_log(type_name .. " object=" .. tostring(fx:typeOf("LObject")))
end

--@api: LPostFxEffect:typeOf
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fx = lurek.effect.newEffect("blur")
    fx:setRadius(5.0)
    fx:setStrength(0.4)
    local is_effect = fx:typeOf("LPostFxEffect")
    effect_log("is effect=" .. tostring(is_effect) .. " type=" .. fx:type())
end

--@api: LPostFxStack:add
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local stack = lurek.effect.newStack(800, 600)
    local fx = lurek.effect.newEffect("bloom")
    stack:add(fx)
    stack:add(lurek.effect.newEffect("blur"))
    local count = stack:getEffectCount()
    effect_log("stack count=" .. count)
end

--@api: LPostFxStack:remove
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local stack = lurek.effect.newStack(800, 600)
    local fx = lurek.effect.newEffect("blur")
    stack:add(fx)
    local ok = stack:remove(fx)
    example_print_log("removed = " .. tostring(ok))
end

--@api: LPostFxStack:insert
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:insert(1, lurek.effect.newEffect("blur"))
    local first = stack:getEffect(1)
    local count = stack:getEffectCount()
    effect_log("after insert count=" .. count .. " first=" .. tostring(first and first:getType()))
end

--@api: LPostFxStack:setEnabled
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local stack = lurek.effect.newStack(800, 600)
    local fx = lurek.effect.newEffect("bloom")
    stack:add(fx)
    stack:setEnabled(1, false)
    example_print_log("pass 1 enabled = " .. tostring(stack:isEnabled(1)))
end

--@api: LPostFxStack:isEnabled
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local stack = lurek.effect.newStack(800, 600)
    local fx = lurek.effect.newEffect("blur")
    stack:add(fx)
    fx:setEnabled(true)
    local enabled = stack:isEnabled(1)
    effect_log("pass enabled=" .. tostring(enabled) .. " count=" .. stack:getEffectCount())
end

--@api: LPostFxStack:getEffectCount
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:add(lurek.effect.newEffect("blur"))
    local count = stack:getEffectCount()
    local enabled = #stack:getEnabledEffects()
    effect_log("effect count=" .. count .. " enabled=" .. enabled)
end

--@api: LPostFxStack:getEffect
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    local fx = stack:getEffect(1)
    local count = stack:getEffectCount()
    local kind = fx and fx:getType() or "none"
    effect_log("got effect=" .. kind .. " count=" .. count)
end

--@api: LPostFxStack:getEnabledEffects
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:add(lurek.effect.newEffect("blur"))
    local enabled = stack:getEnabledEffects()
    example_print_log("enabled effects = " .. #enabled)
end

--@api: LPostFxStack:getWidth
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local stack = lurek.effect.newStack(1024, 768)
    stack:add(lurek.effect.newEffect("bloom"))
    local width = stack:getWidth()
    local count = stack:getEffectCount()
    effect_log("stack width=" .. width .. " effects=" .. count)
end

--@api: LPostFxStack:getHeight
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local stack = lurek.effect.newStack(1024, 768)
    stack:add(lurek.effect.newEffect("bloom"))
    local height = stack:getHeight()
    local count = stack:getEffectCount()
    effect_log("stack height=" .. height .. " effects=" .. count)
end

--@api: LPostFxStack:getDimensions
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("blur"))
    local w, h = stack:getDimensions()
    local count = stack:getEffectCount()
    effect_log("dims=" .. w .. "x" .. h .. " effects=" .. count)
end

--@api: LPostFxStack:resize
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:resize(1920, 1080)
    local w, h = stack:getDimensions()
    effect_log("resized to " .. w .. "x" .. h)
end

--@api: LPostFxStack:len
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:add(lurek.effect.newEffect("blur"))
    local len = stack:len()
    effect_log("len=" .. len .. " enabled=" .. #stack:getEnabledEffects())
end

--@api: LPostFxStack:isEmpty
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    local empty = stack:isEmpty()
    local count = stack:getEffectCount()
    effect_log("empty=" .. tostring(empty) .. " count=" .. count)
end

--@api: LPostFxStack:clear
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:clear()
    local count = stack:getEffectCount()
    local empty = stack:isEmpty()
    effect_log("after clear count=" .. count .. " empty=" .. tostring(empty))
end

--- Effect Module Part 2: LPostFxStack feedback/capture, LImageEffect, LOverlay triggers and state

--@api: LPostFxStack:dedup
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local stack = lurek.effect.newStack(800, 600)
    local fx = lurek.effect.newEffect("bloom")
    stack:add(fx)
    stack:add(fx)
    local removed = stack:dedup()
    example_print_log("dedup removed = " .. removed)
end

--@api: LPostFxStack:isCapturing
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:setFeedback(0.15)
    local capturing = stack:isCapturing()
    effect_log("capturing=" .. tostring(capturing) .. " feedback=" .. stack:getFeedback())
end

--@api: LPostFxStack:beginCapture
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:beginCapture()
    local capturing = stack:isCapturing()
    local count = stack:getEffectCount()
    effect_log("capture started=" .. tostring(capturing) .. " effects=" .. count)
end

--@api: LPostFxStack:endCapture
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:beginCapture()
    stack:endCapture()
    example_print_log("capture ended")
end

--@api: LPostFxStack:apply
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    stack:beginCapture()
    stack:endCapture()
    stack:apply()
    example_print_log("applied")
end

--@api: LPostFxStack:setFeedback
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local stack = lurek.effect.newStack(800, 600)
    stack:setFeedback(0.5)
    stack:add(lurek.effect.newEffect("crt"))
    local feedback = stack:getFeedback()
    effect_log("feedback=" .. feedback .. " effects=" .. stack:getEffectCount())
end

--@api: LPostFxStack:getFeedback
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local stack = lurek.effect.newStack(800, 600)
    stack:setFeedback(0.3)
    stack:add(lurek.effect.newEffect("crt"))
    local feedback = stack:getFeedback()
    effect_log("feedback=" .. feedback .. " width=" .. stack:getWidth())
end

--@api: LPostFxStack:clearFeedback
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local stack = lurek.effect.newStack(800, 600)
    stack:setFeedback(0.8)
    stack:clearFeedback()
    local feedback = stack:getFeedback()
    local capturing = stack:isCapturing()
    effect_log("cleared feedback=" .. feedback .. " capturing=" .. tostring(capturing))
end

--@api: LPostFxStack:type
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    local type_name = stack:type()
    local is_object = stack:typeOf("LObject")
    effect_log(type_name .. " object=" .. tostring(is_object))
end

--@api: LPostFxStack:typeOf
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local stack = lurek.effect.newStack(800, 600)
    stack:add(lurek.effect.newEffect("bloom"))
    local is_stack = stack:typeOf("LPostFxStack")
    local type_name = stack:type()
    effect_log("is stack=" .. tostring(is_stack) .. " type=" .. type_name)
end

--@api: LImageEffect:addEffect
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ie = lurek.effect.newImageEffect()
    local fx = ie:addEffect("bloom")
    ie:addEffect("blur")
    local count = ie:getEffectCount()
    effect_log("added effect=" .. fx:getType() .. " count=" .. count)
end

--@api: LImageEffect:getEffect
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ie = lurek.effect.newImageEffect()
    ie:addEffect("blur")
    local fx = ie:getEffect("blur")
    ie:addEffect("bloom")
    local count = ie:getEffectCount()
    effect_log("found blur=" .. tostring(fx ~= nil) .. " count=" .. count)
end

--@api: LImageEffect:getEffectCount
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    ie:addEffect("blur")
    local count = ie:getEffectCount()
    local first = ie:getEffect(1)
    effect_log("count=" .. count .. " first=" .. tostring(first and first:getType()))
end

--@api: LImageEffect:effectCount
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ie = lurek.effect.newImageEffect()
    ie:addEffect("crt")
    ie:addEffect("bloom")
    local count = ie:effectCount()
    effect_log("effectCount=" .. count .. " cloneable=" .. tostring(ie:clone() ~= nil))
end

--@api: LImageEffect:removeEffect
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    local ok = ie:removeEffect("bloom")
    local count = ie:getEffectCount()
    effect_log("removed=" .. tostring(ok) .. " count=" .. count)
end

--@api: LImageEffect:removeByName
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ie = lurek.effect.newImageEffect()
    ie:addEffect("blur")
    local ok = ie:removeByName("blur")
    local count = ie:getEffectCount()
    effect_log("removeByName=" .. tostring(ok) .. " count=" .. count)
end

--@api: LImageEffect:removeByIndex
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    local ok = ie:removeByIndex(0)
    local count = ie:getEffectCount()
    effect_log("removeByIndex=" .. tostring(ok) .. " count=" .. count)
end

--@api: LImageEffect:clear
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    ie:clear()
    local count = ie:getEffectCount()
    local empty = ie:effectCount()
    effect_log("after clear count=" .. count .. " effectCount=" .. empty)
end

--@api: LImageEffect:clearEffects
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ie = lurek.effect.newImageEffect()
    ie:addEffect("crt")
    ie:clearEffects()
    local count = ie:getEffectCount()
    local empty = ie:effectCount()
    effect_log("after clearEffects count=" .. count .. " effectCount=" .. empty)
end

--@api: LImageEffect:clone
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    local copy = ie:clone()
    copy:addEffect("blur")
    local count = copy:getEffectCount()
    effect_log("clone count=" .. count .. " source=" .. ie:getEffectCount())
end

--@api: LImageEffect:save
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    ie:addEffect("crt")
    local ok = ie:save()
    local count = ie:getEffectCount()
    effect_log("save=" .. tostring(ok) .. " count=" .. count)
end

--@api: LImageEffect:type
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    local type_name = ie:type()
    local is_object = ie:typeOf("LObject")
    effect_log(type_name .. " object=" .. tostring(is_object))
end

--@api: LImageEffect:typeOf
do
    local function effect_log(message)
        lurek.log.info("[effect.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ie = lurek.effect.newImageEffect()
    ie:addEffect("bloom")
    local is_image_effect = ie:typeOf("LImageEffect")
    local type_name = ie:type()
    effect_log("is image effect=" .. tostring(is_image_effect) .. " type=" .. type_name)
end
