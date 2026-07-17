-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_effect_core_unit.lua
do
-- Lurek2D effect API owner tests.

local function new_effect(name)
    return lurek.effect.newEffect(name)
end

local function new_stack(w, h)
    return lurek.effect.newStack(w or 320, h or 240)
end

local function minimal_shader_code()
    return "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
end

local function postfx_shader()
    return lurek.render.newShader([[
@fragment
fn fs_main(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>, @location(2) pixel: vec2<f32>, @location(3) resolution: vec2<f32>, @location(4) texel: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb + uv.xyx * 0.0 + pixel.xyx * 0.0 + resolution.xyx * 0.0 + texel.xyx * 0.0, color.a);
}
]], { target = "postfx" })
end

local function new_overlay(w, h)
    return lurek.overlay.new(w, h)
end

local function new_image_effect(spec, params)
    if spec == nil then
        return lurek.effect.newImageEffect()
    end
    return lurek.effect.newImageEffect(spec, params)
end

local function new_transition(kind, duration)
    return lurek.overlay.newTransition(kind or "fade", duration or 1.0)
end

-- @describe lurek.effect module
describe("lurek.effect module", function()
    -- @covers lurek.effect.setShaderErrorDisplay
    it("setShaderErrorDisplay updates the flag", function()
        lurek.effect.setShaderErrorDisplay(true)
        expect_true(lurek.effect.getShaderErrorDisplay())
        lurek.effect.setShaderErrorDisplay(false)
    end)

    -- @covers lurek.effect.getShaderErrorDisplay
    it("getShaderErrorDisplay returns a boolean", function()
        expect_equal("boolean", type(lurek.effect.getShaderErrorDisplay()))
    end)

    -- @covers lurek.effect.getEffectTypes
    it("getEffectTypes returns built-in effect names", function()
        local types = lurek.effect.getEffectTypes()
        expect_type("table", types)
        expect_true(#types >= 1)
        local found = {}
        for _, name in ipairs(types) do
            found[name] = true
        end
        expect_true(found.crt)
        expect_true(found.sepia)
        expect_true(found.pixelate)
        expect_true(found.scanlines)
        expect_true(found.scale2x)
    end)

    -- @covers lurek.effect.newEffect
    it("newEffect constructs built-in effects and accepts the scalex2 alias", function()
        local effect = new_effect("blur")
        expect_equal("LPostFxEffect", effect:type())
        expect_equal("scale2x", new_effect("scale2x"):getTypeName())
        expect_equal("scale2x", new_effect("scalex2"):getTypeName())
    end)

    -- @covers lurek.effect.newStack
    it("newStack constructs a stack with dimensions and rejects zero sizes", function()
        local stack = new_stack(640, 360)
        expect_equal(640, stack:getWidth())
        expect_equal(360, stack:getHeight())
        expect_error(function()
            lurek.effect.newStack(0, 240)
        end)
    end)

    -- @covers lurek.effect.newPass
    it("newPass constructs a custom pass effect", function()
        expect_equal("LPostFxEffect", lurek.effect.newPass(postfx_shader()):type())
    end)

    -- @covers lurek.effect.newCustomEffect
    it("newCustomEffect accepts postfx shaders and rejects an unknown shader id", function()
        expect_type("function", lurek.effect.newCustomEffect)
        expect_equal("LPostFxEffect", lurek.effect.newCustomEffect(postfx_shader()):type())
        expect_error(function()
            lurek.effect.newCustomEffect(999999)
        end)
    end)

    -- @covers lurek.effect.newPresetStack
    it("newPresetStack builds a named preset", function()
        local stack = lurek.effect.newPresetStack("retro_tv", 256, 144)
        expect_not_nil(stack)
    end)

    -- @covers lurek.effect.newImageEffect
    it("newImageEffect can create a single-effect chain", function()
        local chain = new_image_effect("blur", { radius = 4 })
        expect_equal(1, chain:effectCount())
    end)
end)

-- @describe LPostFxEffect methods
describe("LPostFxEffect methods", function()
    -- @covers LPostFxEffect:getTypeName
    it("getTypeName returns the built-in type name", function()
        expect_equal("blur", new_effect("blur"):getTypeName())
    end)

    -- @covers LPostFxEffect:getType
    it("getType returns the same effect identifier", function()
        expect_equal("blur", new_effect("blur"):getType())
    end)

    -- @covers LPostFxEffect:isBuiltIn
    it("isBuiltIn is true for a built-in effect", function()
        expect_true(new_effect("bloom"):isBuiltIn())
    end)

    -- @covers LPostFxEffect:isEnabled
    it("isEnabled is true by default", function()
        expect_true(new_effect("bloom"):isEnabled())
    end)

    -- @covers LPostFxEffect:setEnabled
    it("setEnabled toggles the enabled state", function()
        local effect = new_effect("bloom")
        effect:setEnabled(false)
        expect_false(effect:isEnabled())
    end)

    -- @covers LPostFxEffect:type
    it("type returns LPostFxEffect", function()
        expect_equal("LPostFxEffect", new_effect("vignette"):type())
    end)

    -- @covers LPostFxEffect:typeOf
    it("typeOf recognizes LPostFxEffect", function()
        local effect = new_effect("vignette")
        expect_true(effect:typeOf("LPostFxEffect"))
        expect_true(effect:typeOf("LObject"))
    end)

    -- @covers LPostFxEffect:hasParameter
    it("hasParameter reports blur radius", function()
        expect_true(new_effect("blur"):hasParameter("radius"))
    end)

    -- @covers LPostFxEffect:getParameter
    it("getParameter reads a default parameter value", function()
        local value = new_effect("blur"):getParameter("radius")
        expect_type("number", value)
    end)

    -- @covers LPostFxEffect:setParameter
    it("setParameter updates values and rejects unknown built-in parameters", function()
        local effect = new_effect("blur")
        effect:setParameter("radius", 5)
        expect_near(5.0, effect:getParameter("radius"), 1e-6)
        expect_error(function()
            effect:setParameter("bogus", 1)
        end)
    end)

    -- @covers LPostFxEffect:getParameterNames
    it("getParameterNames returns available parameters", function()
        local names = new_effect("blur"):getParameterNames()
        expect_type("table", names)
        expect_true(#names >= 1)
    end)

    -- @covers LPostFxEffect:setRadius
    it("setRadius updates the blur radius", function()
        local effect = new_effect("blur")
        effect:setRadius(6)
        expect_near(6.0, effect:getParameter("radius"), 1e-6)
    end)

    -- @covers LPostFxEffect:setIntensity
    it("setIntensity updates bloom intensity", function()
        local effect = new_effect("bloom")
        effect:setIntensity(1.5)
        expect_near(1.5, effect:getParameter("intensity"), 1e-6)
    end)
end)

-- @describe LPostFxStack methods
describe("LPostFxStack methods", function()
    -- @covers LPostFxStack:add
    it("add appends an effect to the stack", function()
        local stack = new_stack()
        stack:add(new_effect("bloom"))
        expect_equal(1, stack:getEffectCount())
    end)

    -- @covers LPostFxStack:len
    it("len returns the number of effects", function()
        local stack = new_stack()
        stack:add(new_effect("bloom"))
        stack:add(new_effect("blur"))
        expect_equal(2, stack:len())
    end)

    -- @covers LPostFxStack:getEffectCount
    it("getEffectCount starts at zero", function()
        expect_equal(0, new_stack():getEffectCount())
    end)

    -- @covers LPostFxStack:isEmpty
    it("isEmpty is true for a fresh stack", function()
        expect_true(new_stack():isEmpty())
    end)

    -- @covers LPostFxStack:getEffect
    it("getEffect returns the inserted effect", function()
        local stack = new_stack()
        stack:add(new_effect("blur"))
        expect_equal("blur", stack:getEffect(1):getType())
    end)

    -- @covers LPostFxStack:remove
    it("remove deletes a specific effect object without shifting remaining order incorrectly", function()
        local stack = new_stack()
        local blur = new_effect("blur")
        local bloom = new_effect("bloom")
        stack:add(blur)
        stack:add(bloom)
        stack:remove(blur)
        expect_equal(1, stack:getEffectCount())
        expect_equal("bloom", stack:getEffect(1):getType())
    end)

    -- @covers LPostFxStack:clear
    it("clear empties the stack", function()
        local stack = new_stack()
        stack:add(new_effect("bloom"))
        stack:add(new_effect("blur"))
        stack:clear()
        expect_equal(0, stack:getEffectCount())
    end)

    -- @covers LPostFxStack:snapshot
    it("snapshot captures dimensions, feedback, and effect parameters", function()
        local stack = new_stack(640, 360)
        stack:add(new_effect("blur"))
        stack:setFeedback(0.4)
        local snapshot = stack:snapshot()
        expect_equal(640, snapshot.width)
        expect_equal("blur", snapshot.effects[1].name)
        expect_near(0.4, snapshot.feedback, 0.001)
    end)

    -- @covers LPostFxStack:restore
    it("restore rebuilds an effect stack from its snapshot", function()
        local source = new_stack(640, 360)
        source:add(new_effect("vignette"))
        source:setEnabled(1, false)
        local target = new_stack()
        target:restore(source:snapshot())
        local width, height = target:getDimensions()
        expect_equal(640, width)
        expect_equal(360, height)
        expect_equal(1, target:getEffectCount())
        expect_false(target:isEnabled(1))
    end)

    -- @covers LPostFxStack:dedup
    it("dedup removes repeated effect objects and keeps enabled handles aligned", function()
        local stack = new_stack()
        local effect = new_effect("blur")
        stack:add(effect)
        stack:add(effect)
        stack:add(new_effect("bloom"))
        stack:setEnabled(2, false)
        expect_equal(1, stack:dedup())
        expect_equal(2, stack:getEffectCount())
        expect_equal(1, #stack:getEnabledEffects())
        expect_equal("blur", stack:getEnabledEffects()[1]:getType())
    end)

    -- @covers LPostFxStack:insert
    it("insert places an effect at a given position and preserves later entries", function()
        local stack = new_stack()
        stack:add(new_effect("bloom"))
        stack:add(new_effect("crt"))
        stack:insert(1, new_effect("blur"))
        expect_equal("blur", stack:getEffect(1):getType())
        expect_equal("bloom", stack:getEffect(2):getType())
        expect_equal("crt", stack:getEffect(3):getType())
    end)

    -- @covers LPostFxStack:getDimensions
    it("getDimensions returns width and height", function()
        local w, h = new_stack(800, 600):getDimensions()
        expect_equal(800, w)
        expect_equal(600, h)
    end)

    -- @covers LPostFxStack:resize
    it("resize updates stack dimensions", function()
        local stack = new_stack(320, 240)
        stack:resize(1024, 768)
        expect_equal(1024, stack:getWidth())
        expect_equal(768, stack:getHeight())
    end)

    -- @covers LPostFxStack:setEnabled
    it("setEnabled disables the stack", function()
        local stack = new_stack()
        stack:add(new_effect("bloom"))
        stack:setEnabled(1, false)
        expect_false(stack:isEnabled(1))
    end)

    -- @covers LPostFxStack:isEnabled
    it("isEnabled is true by default", function()
        local stack = new_stack()
        stack:add(new_effect("bloom"))
        expect_true(stack:isEnabled(1))
    end)

    -- @covers LPostFxStack:isCapturing
    it("isCapturing starts false", function()
        expect_false(new_stack():isCapturing())
    end)

    -- @covers LPostFxStack:beginCapture
    it("beginCapture marks the stack as capturing", function()
        local stack = new_stack()
        stack:beginCapture()
        expect_true(stack:isCapturing())
    end)

    -- @covers LPostFxStack:endCapture
    it("endCapture clears the capturing state", function()
        local stack = new_stack()
        stack:beginCapture()
        stack:endCapture()
        expect_false(stack:isCapturing())
    end)

    -- @covers LPostFxStack:apply
    it("apply does not error after capture", function()
        local stack = new_stack()
        stack:beginCapture()
        stack:endCapture()
        expect_no_error(function() stack:apply() end)
    end)

    -- @covers LPostFxStack:type
    it("type returns LPostFxStack", function()
        expect_equal("LPostFxStack", new_stack():type())
    end)

    -- @covers LPostFxStack:typeOf
    it("typeOf recognizes LPostFxStack", function()
        local stack = new_stack()
        expect_true(stack:typeOf("LPostFxStack"))
        expect_true(stack:typeOf("LObject"))
    end)
end)

-- @describe LOverlay methods
describe("LOverlay methods", function()
    -- @covers LOverlay:getWater
    it("getWater exposes default water state", function()
        local water = new_overlay():getWater()
        expect_false(water.enabled)
        expect_near(0.0, water.time, 1e-6)
    end)

    -- @covers LOverlay:setWater
    it("setWater enables water and stores wave settings", function()
        local overlay = new_overlay()
        overlay:setWater(0.05, 4.0, 2.0)
        local water = overlay:getWater()
        expect_true(water.enabled)
        expect_near(0.05, water.amplitude, 1e-6)
    end)

    -- @covers LOverlay:setWaterTint
    it("setWaterTint stores tint information", function()
        local overlay = new_overlay()
        overlay:setWaterTint(0.1, 0.5, 0.9, 0.7)
        local water = overlay:getWater()
        expect_near(0.7, water.tint_strength, 1e-6)
    end)

    -- @covers LOverlay:resize
    it("resize changes overlay dimensions", function()
        local overlay = new_overlay(320, 240)
        overlay:resize(800, 600)
        expect_equal(800, overlay:getWidth())
        expect_equal(600, overlay:getHeight())
    end)

    -- @covers LOverlay:update
    it("update advances water time when water is enabled", function()
        local overlay = new_overlay()
        overlay:setWater(0.02, 3.0, 2.0)
        overlay:update(0.5)
        expect_near(1.0, overlay:getWater().time, 1e-6)
    end)

    -- @covers LOverlay:clear
    it("clear resets water state", function()
        local overlay = new_overlay()
        overlay:setWater(0.03, 2.0, 1.5)
        overlay:clear()
        expect_false(overlay:getWater().enabled)
    end)

    -- @covers LOverlay:setAmbientEnabled
    it("setAmbientEnabled toggles ambient state", function()
        local overlay = new_overlay()
        overlay:setAmbientEnabled(true)
        expect_true(overlay:isAmbientEnabled())
    end)

    -- @covers LOverlay:setFogColor
    it("setFogColor stores fog channels", function()
        local overlay = new_overlay()
        overlay:setFogColor(0.2, 0.3, 0.4, 0.5)
        local _, _, _, a = overlay:getFogColor()
        expect_near(0.5, a, 1e-6)
    end)

    -- @covers LOverlay:type
    it("type returns LOverlay", function()
        expect_equal("LOverlay", new_overlay():type())
    end)

    -- @covers LOverlay:typeOf
    it("typeOf recognizes LOverlay", function()
        local overlay = new_overlay()
        expect_true(overlay:typeOf("LOverlay"))
        expect_true(overlay:typeOf("LObject"))
    end)
end)

-- @describe LImageEffect methods
describe("LImageEffect methods", function()
    -- @covers LImageEffect:effectCount
    it("effectCount reflects chain length", function()
        expect_equal(1, new_image_effect("blur"):effectCount())
    end)

    -- @covers LImageEffect:addEffect
    it("addEffect appends an effect to the chain", function()
        local fx = new_image_effect()
        fx:addEffect("vignette")
        expect_equal(1, fx:effectCount())
    end)

    -- @covers LImageEffect:getEffect
    it("getEffect returns the requested effect", function()
        local fx = new_image_effect()
        fx:addEffect("blur")
        fx:addEffect("sepia")
        expect_equal("sepia", fx:getEffect(2):getType())
    end)

    -- @covers LImageEffect:removeEffect
    it("removeEffect accepts an effect name", function()
        local fx = new_image_effect()
        fx:addEffect("blur")
        fx:addEffect("sepia")
        fx:removeEffect("blur")
        expect_equal(1, fx:effectCount())
    end)

    -- @covers LImageEffect:clearEffects
    it("clearEffects empties the chain", function()
        local fx = new_image_effect()
        fx:addEffect("blur")
        fx:addEffect("sepia")
        fx:clearEffects()
        expect_equal(0, fx:effectCount())
    end)

    -- @covers LImageEffect:clone
    it("clone preserves effect order", function()
        local fx = new_image_effect()
        fx:addEffect("blur")
        fx:addEffect("sepia")
        local copy = fx:clone()
        expect_equal("blur", copy:getEffect(1):getType())
        expect_equal("sepia", copy:getEffect(2):getType())
    end)
end)

-- @describe LScreenTransition methods
describe("LScreenTransition methods", function()
    -- @covers LScreenTransition:kind
    it("kind reports the chosen transition kind", function()
        expect_equal("wipe", new_transition("wipe", 1.0):kind())
    end)

    -- @covers LScreenTransition:play
    it("play activates the transition", function()
        local transition = new_transition("fade", 1.0)
        transition:play()
        expect_true(transition:isActive())
    end)

    -- @covers LScreenTransition:update
    it("update advances the transition", function()
        local transition = new_transition("fade", 2.0)
        transition:play()
        transition:update(1.0)
        expect_near(0.5, transition:progress(), 1e-3)
    end)

    -- @covers LScreenTransition:reverse
    it("reverse also advances progress over time", function()
        local transition = new_transition("fade", 2.0)
        transition:reverse()
        transition:update(1.0)
        expect_near(0.5, transition:progress(), 1e-3)
    end)

    -- @covers LScreenTransition:setColor
    it("setColor updates the transition tint", function()
        local transition = new_transition("fade", 1.0)
        expect_no_error(function()
            transition:setColor({ r = 0.2, g = 0.3, b = 0.4, a = 0.5 })
        end)
        local r, g, b, a = transition:color()
        expect_type("number", r)
        expect_type("number", g)
        expect_type("number", b)
        expect_type("number", a)
    end)

    -- @covers LScreenTransition:type
    it("type returns LScreenTransition", function()
        expect_equal("LScreenTransition", new_transition():type())
    end)
end)
end
-- END test_effect_core_unit.lua

do
local function new_effect_local(name)
    return lurek.effect.newEffect(name)
end

local function new_stack_local(w, h)
    return lurek.effect.newStack(w or 320, h or 240)
end

local function new_image_effect_local(spec, params)
    if spec == nil then
        return lurek.effect.newImageEffect()
    end
    return lurek.effect.newImageEffect(spec, params)
end

-- @describe effect explicit owner coverage
describe("effect explicit owner coverage", function()
    -- @covers lurek.effect.getPresetNames
    it("returns available preset stack names", function()
        local names = lurek.effect.getPresetNames()
        expect_type("table", names)
        expect_true(#names >= 1)
    end)

    -- @covers LPostFxEffect:getEffectType
    it("returns the renderer effect type name", function()
        expect_equal("blur", new_effect_local("blur"):getEffectType())
    end)

    -- @covers LPostFxEffect:setThreshold
    it("stores the threshold parameter", function()
        local effect = new_effect_local("bloom")
        effect:setThreshold(0.4)
        expect_near(0.4, effect:getParameter("threshold"), 1e-6)
    end)

    -- @covers LPostFxEffect:setStrength
    it("stores the strength parameter", function()
        local effect = new_effect_local("vignette")
        effect:setStrength(0.7)
        expect_near(0.7, effect:getParameter("strength"), 1e-6)
    end)

    -- @covers LPostFxEffect:setScanlineStrength
    it("stores the scanline strength parameter", function()
        local effect = new_effect_local("crt")
        effect:setScanlineStrength(0.6)
        expect_near(0.6, effect:getParameter("scanline_strength"), 1e-6)
    end)

    -- @covers LPostFxEffect:setOffset
    it("stores the offset parameter", function()
        local effect = new_effect_local("chromatic")
        effect:setOffset(0.2)
        expect_near(0.2, effect:getParameter("offset"), 1e-6)
    end)

    -- @covers LPostFxEffect:setBrightness
    it("stores the brightness parameter", function()
        local effect = new_effect_local("colourgrade")
        effect:setBrightness(1.1)
        expect_near(1.1, effect:getParameter("brightness"), 1e-6)
    end)

    -- @covers LPostFxEffect:setContrast
    it("stores the contrast parameter", function()
        local effect = new_effect_local("colourgrade")
        effect:setContrast(0.9)
        expect_near(0.9, effect:getParameter("contrast"), 1e-6)
    end)

    -- @covers LPostFxEffect:setSaturation
    it("stores the saturation parameter", function()
        local effect = new_effect_local("colourgrade")
        effect:setSaturation(0.8)
        expect_near(0.8, effect:getParameter("saturation"), 1e-6)
    end)

    -- @covers LPostFxEffect:enableAutoUniforms
    it("enables automatic uniforms", function()
        local effect = new_effect_local("blur")
        effect:disableAutoUniforms()
        effect:enableAutoUniforms()
        expect_true(effect:isAutoUniforms())
    end)

    -- @covers LPostFxEffect:disableAutoUniforms
    it("disables automatic uniforms", function()
        local effect = new_effect_local("blur")
        effect:disableAutoUniforms()
        expect_false(effect:isAutoUniforms())
    end)

    -- @covers LPostFxEffect:isAutoUniforms
    it("reports automatic uniform state", function()
        expect_false(new_effect_local("blur"):isAutoUniforms())
    end)

    -- @covers LPostFxStack:getEnabledEffects
    it("returns only stack-enabled and effect-enabled objects", function()
        local stack = new_stack_local()
        stack:add(new_effect_local("bloom"))
        stack:add(new_effect_local("blur"))
        stack:setEnabled(2, false)
        local enabled = stack:getEnabledEffects()
        expect_equal(1, #enabled)
        expect_equal("bloom", enabled[1]:getType())
        local stack2 = new_stack_local()
        local bloom = new_effect_local("bloom")
        local blur = new_effect_local("blur")
        stack2:add(bloom)
        stack2:add(blur)
        blur:setEnabled(false)
        local enabled2 = stack2:getEnabledEffects()
        expect_equal(1, #enabled2)
        expect_equal("bloom", enabled2[1]:getType())
    end)

    -- @covers LPostFxStack:getWidth
    it("returns the stack width", function()
        expect_equal(512, new_stack_local(512, 128):getWidth())
    end)

    -- @covers LPostFxStack:getHeight
    it("returns the stack height", function()
        expect_equal(128, new_stack_local(512, 128):getHeight())
    end)

    -- @covers LPostFxStack:setFeedback
    it("stores a feedback blend factor", function()
        local stack = new_stack_local()
        stack:setFeedback(0.65)
        expect_near(0.65, stack:getFeedback(), 1e-6)
    end)

    -- @covers LPostFxStack:getFeedback
    it("returns zero feedback by default", function()
        expect_near(0.0, new_stack_local():getFeedback(), 1e-6)
    end)

    -- @covers LPostFxStack:clearFeedback
    it("resets feedback to zero", function()
        local stack = new_stack_local()
        stack:setFeedback(0.4)
        stack:clearFeedback()
        expect_near(0.0, stack:getFeedback(), 1e-6)
    end)

    -- @covers LImageEffect:clear
    it("clears image effect entries", function()
        local chain = new_image_effect_local()
        chain:addEffect("blur")
        chain:clear()
        expect_equal(0, chain:getEffectCount())
    end)

    -- @covers LImageEffect:getEffectCount
    it("returns the image effect entry count", function()
        local chain = new_image_effect_local()
        chain:addEffect("blur")
        chain:addEffect("bloom")
        expect_equal(2, chain:getEffectCount())
    end)

    -- @covers LImageEffect:save
    it("reports success for save placeholder", function()
        expect_true(new_image_effect_local():save())
    end)

    -- @covers LImageEffect:type
    it("returns the image effect type name", function()
        expect_equal("LImageEffect", new_image_effect_local():type())
    end)

    -- @covers LImageEffect:typeOf
    it("matches the image effect type name", function()
        local chain = new_image_effect_local()
        expect_true(chain:typeOf("LImageEffect"))
        expect_false(chain:typeOf("LPostFxStack"))
    end)

    -- @covers LImageEffect:removeByIndex
    it("removes an effect by zero-based index", function()
        local chain = new_image_effect_local()
        chain:addEffect("blur")
        chain:addEffect("bloom")
        expect_true(chain:removeByIndex(0))
        expect_equal(1, chain:getEffectCount())
    end)

    -- @covers LImageEffect:removeByName
    it("removes an effect by name", function()
        local chain = new_image_effect_local()
        chain:addEffect("blur")
        chain:addEffect("bloom")
        expect_true(chain:removeByName("blur"))
        expect_equal(1, chain:getEffectCount())
        expect_equal("bloom", chain:getEffect(1):getType())
    end)
end)
end

test_summary()
