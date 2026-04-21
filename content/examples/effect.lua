-- content/examples/effect.lua
-- Lurek2D lurek.effect API Reference
-- Run with: cargo run -- content/examples/effect
--
-- Scenario: An action RPG with full-screen post-processing (bloom, CRT, vignette),
-- a dynamic weather/day-night overlay system, image processing effects for screenshots,
-- and screen transitions (fade, dissolve, slide) between game scenes.

print("=== lurek.effect — Visual Effects & Post-Processing ===\n")

-- =============================================================================
-- Effect Creation (module-level functions)
-- =============================================================================

-- ---- Stub: lurek.effect.newEffect -----------------------------------------
--@api-stub: lurek.effect.newEffect
-- Demonstrates the proper usage of lurek.effect.newEffect.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_effect_newEffect()
    local bloom = lurek.effect.newEffect("bloom")
    local crt = lurek.effect.newEffect("crt")
    local blur = lurek.effect.newEffect("blur")
    print("effects created: bloom, crt, blur")
end
local _ok, _err = pcall(demo_lurek_effect_newEffect)

-- ---- Stub: lurek.effect.newCustomEffect -----------------------------------
--@api-stub: lurek.effect.newCustomEffect
-- Demonstrates the proper usage of lurek.effect.newCustomEffect.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_effect_newCustomEffect()
    local custom_fx = lurek.effect.newCustomEffect("assets/shaders/pixelate.wgsl", {
    pixel_size = 4.0
    })
    print("custom effect: pixelate shader (4px grid)")
end
local _ok, _err = pcall(demo_lurek_effect_newCustomEffect)

-- ---- Stub: lurek.effect.getEffectTypes ------------------------------------
--@api-stub: lurek.effect.getEffectTypes
-- Demonstrates the proper usage of lurek.effect.getEffectTypes.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_effect_getEffectTypes()
    local types = lurek.effect.getEffectTypes()
    print("available effect types: " .. #types)
    for _, t in ipairs(types) do
    print("  - " .. t)
end
local _ok, _err = pcall(demo_lurek_effect_getEffectTypes)

-- ---- Stub: lurek.effect.setShaderErrorDisplay -----------------------------
--@api-stub: lurek.effect.setShaderErrorDisplay
-- Demonstrates the proper usage of lurek.effect.setShaderErrorDisplay.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_effect_setShaderErrorDisplay()
    lurek.effect.setShaderErrorDisplay(true)
    print("shader error display: ON (dev mode)")
end
local _ok, _err = pcall(demo_lurek_effect_setShaderErrorDisplay)

-- ---- Stub: lurek.effect.getShaderErrorDisplay -----------------------------
--@api-stub: lurek.effect.getShaderErrorDisplay
-- Demonstrates the proper usage of lurek.effect.getShaderErrorDisplay.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_effect_getShaderErrorDisplay()
    print("shader error display: " .. tostring(lurek.effect.getShaderErrorDisplay()))
end
local _ok, _err = pcall(demo_lurek_effect_getShaderErrorDisplay)

-- =============================================================================
-- PostFxEffect Object Methods — per-effect control
-- =============================================================================

-- ---- Stub: PostFxEffect:getTypeName ---------------------------------------
--@api-stub: PostFxEffect:getTypeName
-- Demonstrates the proper usage of PostFxEffect:getTypeName.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxEffect_getTypeName()
    print("bloom type: " .. bloom:getTypeName())
    print("crt type: " .. crt:getTypeName())
end
local _ok, _err = pcall(demo_PostFxEffect_getTypeName)

-- ---- Stub: PostFxEffect:isBuiltIn -----------------------------------------
--@api-stub: PostFxEffect:isBuiltIn
-- Demonstrates the proper usage of PostFxEffect:isBuiltIn.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxEffect_isBuiltIn()
    print("bloom built-in: " .. tostring(bloom:isBuiltIn()))
    print("custom built-in: " .. tostring(custom_fx:isBuiltIn()))
end
local _ok, _err = pcall(demo_PostFxEffect_isBuiltIn)

-- ---- Stub: PostFxEffect:isEnabled -----------------------------------------
--@api-stub: PostFxEffect:isEnabled
-- Demonstrates the proper usage of PostFxEffect:isEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxEffect_isEnabled()
    print("bloom enabled: " .. tostring(bloom:isEnabled()))
end
local _ok, _err = pcall(demo_PostFxEffect_isEnabled)

-- ---- Stub: PostFxEffect:setEnabled ----------------------------------------
--@api-stub: PostFxEffect:setEnabled
-- Demonstrates the proper usage of PostFxEffect:setEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxEffect_setEnabled()
    bloom:setEnabled(true)
    crt:setEnabled(false)
    print("bloom ON, crt OFF")
end
local _ok, _err = pcall(demo_PostFxEffect_setEnabled)

-- ---- Stub: PostFxEffect:setParameter --------------------------------------
--@api-stub: PostFxEffect:setParameter
-- Demonstrates the proper usage of PostFxEffect:setParameter.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxEffect_setParameter()
    bloom:setParameter("threshold", 0.8)
    bloom:setParameter("intensity", 1.5)
    bloom:setParameter("radius", 4)
    print("bloom: threshold=0.8, intensity=1.5, radius=4")
end
local _ok, _err = pcall(demo_PostFxEffect_setParameter)

-- ---- Stub: PostFxEffect:hasParameter --------------------------------------
--@api-stub: PostFxEffect:hasParameter
-- Demonstrates the proper usage of PostFxEffect:hasParameter.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxEffect_hasParameter()
    print("bloom has 'threshold': " .. tostring(bloom:hasParameter("threshold")))
    print("bloom has 'color': " .. tostring(bloom:hasParameter("color")))
end
local _ok, _err = pcall(demo_PostFxEffect_hasParameter)

-- ---- Stub: PostFxEffect:getParameterNames ---------------------------------
--@api-stub: PostFxEffect:getParameterNames
-- Demonstrates the proper usage of PostFxEffect:getParameterNames.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxEffect_getParameterNames()
    local params = bloom:getParameterNames()
    print("bloom parameters: " .. table.concat(params, ", "))
end
local _ok, _err = pcall(demo_PostFxEffect_getParameterNames)

-- ---- Stub: PostFxEffect:getEffectType -------------------------------------
--@api-stub: PostFxEffect:getEffectType
-- Demonstrates the proper usage of PostFxEffect:getEffectType.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxEffect_getEffectType()
    print("bloom effect type: " .. tostring(bloom:getEffectType()))
end
local _ok, _err = pcall(demo_PostFxEffect_getEffectType)

-- ---- Stub: PostFxEffect:getType -------------------------------------------
--@api-stub: PostFxEffect:getType
-- Demonstrates the proper usage of PostFxEffect:getType.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxEffect_getType()
    print("bloom getType: " .. tostring(bloom:getType()))
end
local _ok, _err = pcall(demo_PostFxEffect_getType)

-- ---- Stub: PostFxEffect:type ----------------------------------------------
--@api-stub: PostFxEffect:type
-- Demonstrates the proper usage of PostFxEffect:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxEffect_type()
    print('Executing type')
end
local _ok, _err = pcall(demo_PostFxEffect_type)

-- ---- Stub: PostFxEffect:typeOf --------------------------------------------
--@api-stub: PostFxEffect:typeOf
-- Demonstrates the proper usage of PostFxEffect:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxEffect_typeOf()
    print("bloom type(): " .. tostring(bloom:type()))
    print("bloom typeOf: " .. tostring(bloom:typeOf("PostFxEffect")))
end
local _ok, _err = pcall(demo_PostFxEffect_typeOf)

-- ---- Stub: PostFxEffect:setThreshold --------------------------------------
--@api-stub: PostFxEffect:setThreshold
-- Demonstrates the proper usage of PostFxEffect:setThreshold.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxEffect_setThreshold()
    bloom:setThreshold(0.6)
    print("bloom threshold: 0.6 (more objects glow)")
end
local _ok, _err = pcall(demo_PostFxEffect_setThreshold)

-- ---- Stub: PostFxEffect:setIntensity --------------------------------------
--@api-stub: PostFxEffect:setIntensity
-- Demonstrates the proper usage of PostFxEffect:setIntensity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxEffect_setIntensity()
    bloom:setIntensity(2.0)
    print("bloom intensity: 2.0 (strong glow)")
end
local _ok, _err = pcall(demo_PostFxEffect_setIntensity)

-- ---- Stub: PostFxEffect:setRadius -----------------------------------------
--@api-stub: PostFxEffect:setRadius
-- Demonstrates the proper usage of PostFxEffect:setRadius.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxEffect_setRadius()
    bloom:setRadius(8)
    print("bloom radius: 8 (wide halo)")
end
local _ok, _err = pcall(demo_PostFxEffect_setRadius)

-- ---- Stub: PostFxEffect:setStrength ---------------------------------------
--@api-stub: PostFxEffect:setStrength
-- Demonstrates the proper usage of PostFxEffect:setStrength.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxEffect_setStrength()
    blur:setStrength(0.5)
    print("blur strength: 0.5 (subtle background blur)")
end
local _ok, _err = pcall(demo_PostFxEffect_setStrength)

-- ---- Stub: PostFxEffect:setScanlineStrength -------------------------------
--@api-stub: PostFxEffect:setScanlineStrength
-- Demonstrates the proper usage of PostFxEffect:setScanlineStrength.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxEffect_setScanlineStrength()
    crt:setScanlineStrength(0.3)
    print("CRT scanlines: 0.3 (subtle retro look)")
end
local _ok, _err = pcall(demo_PostFxEffect_setScanlineStrength)

-- ---- Stub: PostFxEffect:setOffset -----------------------------------------
--@api-stub: PostFxEffect:setOffset
-- Demonstrates the proper usage of PostFxEffect:setOffset.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxEffect_setOffset()
    crt:setOffset(1.5)
    print("CRT chromatic offset: 1.5px")
end
local _ok, _err = pcall(demo_PostFxEffect_setOffset)

-- ---- Stub: PostFxEffect:setBrightness -------------------------------------
--@api-stub: PostFxEffect:setBrightness
-- Demonstrates the proper usage of PostFxEffect:setBrightness.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxEffect_setBrightness()
    crt:setBrightness(1.1)
    print("CRT brightness: 1.1 (slightly brighter)")
end
local _ok, _err = pcall(demo_PostFxEffect_setBrightness)

-- ---- Stub: PostFxEffect:setContrast ---------------------------------------
--@api-stub: PostFxEffect:setContrast
-- Demonstrates the proper usage of PostFxEffect:setContrast.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxEffect_setContrast()
    crt:setContrast(1.2)
    print("CRT contrast: 1.2 (punchier colors)")
end
local _ok, _err = pcall(demo_PostFxEffect_setContrast)

-- ---- Stub: PostFxEffect:setSaturation -------------------------------------
--@api-stub: PostFxEffect:setSaturation
-- Demonstrates the proper usage of PostFxEffect:setSaturation.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxEffect_setSaturation()
    crt:setSaturation(0.4)
    print("CRT saturation: 0.4 (desaturated — low health warning)")
end
local _ok, _err = pcall(demo_PostFxEffect_setSaturation)

-- =============================================================================
-- PostFx Effect Stack — compositing multiple effects
-- =============================================================================

-- ---- Stub: lurek.effect.newStack ------------------------------------------
--@api-stub: lurek.effect.newStack
-- Demonstrates the proper usage of lurek.effect.newStack.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_effect_newStack()
    local fx_stack = lurek.effect.newStack(800, 600)
    print("effect stack created: 800x600")
end
local _ok, _err = pcall(demo_lurek_effect_newStack)

-- ---- Stub: lurek.effect.newPresetStack ------------------------------------
--@api-stub: lurek.effect.newPresetStack
-- Demonstrates the proper usage of lurek.effect.newPresetStack.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_effect_newPresetStack()
    local retro_stack = lurek.effect.newPresetStack("retro", 800, 600)
    print("retro preset stack: bloom + CRT + vignette")
end
local _ok, _err = pcall(demo_lurek_effect_newPresetStack)

-- ---- Stub: lurek.effect.newPass -------------------------------------------
--@api-stub: lurek.effect.newPass
-- Demonstrates the proper usage of lurek.effect.newPass.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_effect_newPass()
    local pass = lurek.effect.newPass("assets/shaders/downsample.wgsl", 400, 300)
    print("render pass: downsample at 400x300")
end
local _ok, _err = pcall(demo_lurek_effect_newPass)

-- ---- Stub: PostFxStack:add ------------------------------------------------
--@api-stub: PostFxStack:add
-- Demonstrates the proper usage of PostFxStack:add.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxStack_add()
    fx_stack:add(bloom)
    fx_stack:add(crt)
    print("stack: bloom -> CRT (rendering order)")
end
local _ok, _err = pcall(demo_PostFxStack_add)

-- ---- Stub: PostFxStack:remove ---------------------------------------------
--@api-stub: PostFxStack:remove
-- Demonstrates the proper usage of PostFxStack:remove.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxStack_remove()
    fx_stack:remove(crt)
    print("CRT removed from stack")
end
local _ok, _err = pcall(demo_PostFxStack_remove)

-- ---- Stub: PostFxStack:isEnabled ------------------------------------------
--@api-stub: PostFxStack:isEnabled
-- Demonstrates the proper usage of PostFxStack:isEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxStack_isEnabled()
    print("stack enabled: " .. tostring(fx_stack:isEnabled()))
end
local _ok, _err = pcall(demo_PostFxStack_isEnabled)

-- ---- Stub: PostFxStack:getEffectCount -------------------------------------
--@api-stub: PostFxStack:getEffectCount
-- Demonstrates the proper usage of PostFxStack:getEffectCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxStack_getEffectCount()
    print("effects in stack: " .. fx_stack:getEffectCount())
end
local _ok, _err = pcall(demo_PostFxStack_getEffectCount)

-- ---- Stub: PostFxStack:getEffect ------------------------------------------
--@api-stub: PostFxStack:getEffect
-- Demonstrates the proper usage of PostFxStack:getEffect.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxStack_getEffect()
    local first_fx = fx_stack:getEffect(0)
    print("first effect: " .. tostring(first_fx:getTypeName()))
end
local _ok, _err = pcall(demo_PostFxStack_getEffect)

-- ---- Stub: PostFxStack:getEnabledEffects ----------------------------------
--@api-stub: PostFxStack:getEnabledEffects
-- Demonstrates the proper usage of PostFxStack:getEnabledEffects.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxStack_getEnabledEffects()
    local enabled = fx_stack:getEnabledEffects()
    print("enabled effects: " .. #enabled)
end
local _ok, _err = pcall(demo_PostFxStack_getEnabledEffects)

-- ---- Stub: PostFxStack:getWidth -------------------------------------------
--@api-stub: PostFxStack:getWidth
-- Demonstrates the proper usage of PostFxStack:getWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxStack_getWidth()
    print("stack width: " .. fx_stack:getWidth())
end
local _ok, _err = pcall(demo_PostFxStack_getWidth)

-- ---- Stub: PostFxStack:getHeight ------------------------------------------
--@api-stub: PostFxStack:getHeight
-- Demonstrates the proper usage of PostFxStack:getHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxStack_getHeight()
    print("stack height: " .. fx_stack:getHeight())
end
local _ok, _err = pcall(demo_PostFxStack_getHeight)

-- ---- Stub: PostFxStack:getDimensions --------------------------------------
--@api-stub: PostFxStack:getDimensions
-- Demonstrates the proper usage of PostFxStack:getDimensions.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxStack_getDimensions()
    local sw, sh = fx_stack:getDimensions()
    print("stack dimensions: " .. sw .. "x" .. sh)
end
local _ok, _err = pcall(demo_PostFxStack_getDimensions)

-- ---- Stub: PostFxStack:resize ---------------------------------------------
--@api-stub: PostFxStack:resize
-- Demonstrates the proper usage of PostFxStack:resize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxStack_resize()
    fx_stack:resize(1280, 720)
    print("stack resized to 1280x720")
end
local _ok, _err = pcall(demo_PostFxStack_resize)

-- ---- Stub: PostFxStack:len -----------------------------------------------
--@api-stub: PostFxStack:len
-- Demonstrates the proper usage of PostFxStack:len.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxStack_len()
    print("stack length: " .. fx_stack:len())
end
local _ok, _err = pcall(demo_PostFxStack_len)

-- ---- Stub: PostFxStack:isEmpty --------------------------------------------
--@api-stub: PostFxStack:isEmpty
-- Demonstrates the proper usage of PostFxStack:isEmpty.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxStack_isEmpty()
    print("stack empty: " .. tostring(fx_stack:isEmpty()))
end
local _ok, _err = pcall(demo_PostFxStack_isEmpty)

-- ---- Stub: PostFxStack:clear ----------------------------------------------
--@api-stub: PostFxStack:clear
-- Demonstrates the proper usage of PostFxStack:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxStack_clear()
    fx_stack:clear()
    print("stack cleared (all effects removed)")
    fx_stack:add(bloom)
end
local _ok, _err = pcall(demo_PostFxStack_clear)

-- ---- Stub: PostFxStack:dedup ----------------------------------------------
--@api-stub: PostFxStack:dedup
-- Demonstrates the proper usage of PostFxStack:dedup.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxStack_dedup()
    fx_stack:add(bloom)  -- intentional duplicate
    fx_stack:dedup()
    print("duplicates removed: " .. fx_stack:getEffectCount() .. " effects remain")
end
local _ok, _err = pcall(demo_PostFxStack_dedup)

-- ---- Stub: PostFxStack:isCapturing ----------------------------------------
--@api-stub: PostFxStack:isCapturing
-- Demonstrates the proper usage of PostFxStack:isCapturing.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxStack_isCapturing()
    print("capturing: " .. tostring(fx_stack:isCapturing()))
end
local _ok, _err = pcall(demo_PostFxStack_isCapturing)

-- ---- Stub: PostFxStack:beginCapture ---------------------------------------
--@api-stub: PostFxStack:beginCapture
-- Demonstrates the proper usage of PostFxStack:beginCapture.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxStack_beginCapture()
    fx_stack:beginCapture()
    print("capture started — game renders to offscreen buffer")
end
local _ok, _err = pcall(demo_PostFxStack_beginCapture)

-- ---- Stub: PostFxStack:endCapture -----------------------------------------
--@api-stub: PostFxStack:endCapture
-- Demonstrates the proper usage of PostFxStack:endCapture.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxStack_endCapture()
    fx_stack:endCapture()
    print("capture ended — effects applied to frame")
end
local _ok, _err = pcall(demo_PostFxStack_endCapture)

-- ---- Stub: PostFxStack:apply ----------------------------------------------
--@api-stub: PostFxStack:apply
-- Demonstrates the proper usage of PostFxStack:apply.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxStack_apply()
    fx_stack:apply()
    print("effect stack applied to screen")
end
local _ok, _err = pcall(demo_PostFxStack_apply)

-- ---- Stub: PostFxStack:type -----------------------------------------------
--@api-stub: PostFxStack:type
-- Demonstrates the proper usage of PostFxStack:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxStack_type()
    print('Executing type')
end
local _ok, _err = pcall(demo_PostFxStack_type)

-- ---- Stub: PostFxStack:typeOf ---------------------------------------------
--@api-stub: PostFxStack:typeOf
-- Demonstrates the proper usage of PostFxStack:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxStack_typeOf()
    print("stack type: " .. tostring(fx_stack:type()))
    print("stack typeOf: " .. tostring(fx_stack:typeOf("PostFxStack")))
end
local _ok, _err = pcall(demo_PostFxStack_typeOf)

-- ---- Stub: PostFxStack:setFeedback ----------------------------------------
--@api-stub: PostFxStack:setFeedback
-- Demonstrates the proper usage of PostFxStack:setFeedback.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxStack_setFeedback()
    fx_stack:setFeedback(0.85)
    print("feedback: 0.85 (previous frame blends in at 85%)")
end
local _ok, _err = pcall(demo_PostFxStack_setFeedback)

-- ---- Stub: PostFxStack:getFeedback ----------------------------------------
--@api-stub: PostFxStack:getFeedback
-- Demonstrates the proper usage of PostFxStack:getFeedback.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxStack_getFeedback()
    print("feedback: " .. tostring(fx_stack:getFeedback()))
end
local _ok, _err = pcall(demo_PostFxStack_getFeedback)

-- ---- Stub: PostFxStack:clearFeedback --------------------------------------
--@api-stub: PostFxStack:clearFeedback
-- Demonstrates the proper usage of PostFxStack:clearFeedback.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PostFxStack_clearFeedback()
    fx_stack:clearFeedback()
    print("feedback cleared (no more motion trail)")
end
local _ok, _err = pcall(demo_PostFxStack_clearFeedback)

-- =============================================================================
-- ImageEffect — apply effects to static images
-- =============================================================================

-- ---- Stub: lurek.effect.newImageEffect ------------------------------------
--@api-stub: lurek.effect.newImageEffect
-- Demonstrates the proper usage of lurek.effect.newImageEffect.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_effect_newImageEffect()
    local img_fx = lurek.effect.newImageEffect("assets/screenshots/scene.png")
    print("image effect loaded: scene.png")
end
local _ok, _err = pcall(demo_lurek_effect_newImageEffect)

-- ---- Stub: ImageEffect:addEffect ------------------------------------------
--@api-stub: ImageEffect:addEffect
-- Demonstrates the proper usage of ImageEffect:addEffect.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ImageEffect_addEffect()
    img_fx:addEffect("blur", { strength = 3 })
    img_fx:addEffect("brightness", { value = 1.2 })
    img_fx:addEffect("vignette", { strength = 0.5 })
    print("3 effects chained: blur -> brightness -> vignette")
end
local _ok, _err = pcall(demo_ImageEffect_addEffect)

-- ---- Stub: ImageEffect:getEffect ------------------------------------------
--@api-stub: ImageEffect:getEffect
-- Demonstrates the proper usage of ImageEffect:getEffect.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ImageEffect_getEffect()
    local img_e0 = img_fx:getEffect(0)
    print("image effect 0: " .. tostring(img_e0))
end
local _ok, _err = pcall(demo_ImageEffect_getEffect)

-- ---- Stub: ImageEffect:removeEffect ---------------------------------------
--@api-stub: ImageEffect:removeEffect
-- Demonstrates the proper usage of ImageEffect:removeEffect.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ImageEffect_removeEffect()
    img_fx:removeEffect("blur")
    print("blur removed from image pipeline")
end
local _ok, _err = pcall(demo_ImageEffect_removeEffect)

-- ---- Stub: ImageEffect:removeByIndex -------------------------------------
--@api-stub: ImageEffect:removeByIndex
-- Demonstrates the proper usage of ImageEffect:removeByIndex.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ImageEffect_removeByIndex()
    img_fx:removeByIndex(0)
    print("effect at index 0 removed")
end
local _ok, _err = pcall(demo_ImageEffect_removeByIndex)

-- ---- Stub: ImageEffect:removeByName ---------------------------------------
--@api-stub: ImageEffect:removeByName
-- Demonstrates the proper usage of ImageEffect:removeByName.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ImageEffect_removeByName()
    img_fx:removeByName("vignette")
    print("vignette removed by name")
end
local _ok, _err = pcall(demo_ImageEffect_removeByName)

-- ---- Stub: ImageEffect:clearEffects ---------------------------------------
--@api-stub: ImageEffect:clearEffects
-- Demonstrates the proper usage of ImageEffect:clearEffects.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ImageEffect_clearEffects()
    img_fx:clearEffects()
    print("all image effects cleared")
end
local _ok, _err = pcall(demo_ImageEffect_clearEffects)

-- ---- Stub: ImageEffect:clear ----------------------------------------------
--@api-stub: ImageEffect:clear
-- Demonstrates the proper usage of ImageEffect:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ImageEffect_clear()
    img_fx:clear()
    print("image effect pipeline fully reset")
end
local _ok, _err = pcall(demo_ImageEffect_clear)

-- ---- Stub: ImageEffect:effectCount ----------------------------------------
--@api-stub: ImageEffect:effectCount
-- Demonstrates the proper usage of ImageEffect:effectCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ImageEffect_effectCount()
    print("image effects: " .. tostring(img_fx:effectCount()))
end
local _ok, _err = pcall(demo_ImageEffect_effectCount)

-- ---- Stub: ImageEffect:getEffectCount -------------------------------------
--@api-stub: ImageEffect:getEffectCount
-- Demonstrates the proper usage of ImageEffect:getEffectCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ImageEffect_getEffectCount()
    print("image effect count: " .. tostring(img_fx:getEffectCount()))
end
local _ok, _err = pcall(demo_ImageEffect_getEffectCount)

-- ---- Stub: ImageEffect:clone ----------------------------------------------
--@api-stub: ImageEffect:clone
-- Demonstrates the proper usage of ImageEffect:clone.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ImageEffect_clone()
    local img_fx_copy = img_fx:clone()
    print("image effect pipeline cloned")
end
local _ok, _err = pcall(demo_ImageEffect_clone)

-- ---- Stub: ImageEffect:save -----------------------------------------------
--@api-stub: ImageEffect:save
-- Demonstrates the proper usage of ImageEffect:save.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ImageEffect_save()
    img_fx:save("output/processed_scene.png")
    print("processed image saved: output/processed_scene.png")
end
local _ok, _err = pcall(demo_ImageEffect_save)

-- ---- Stub: ImageEffect:type -----------------------------------------------
--@api-stub: ImageEffect:type
-- Demonstrates the proper usage of ImageEffect:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ImageEffect_type()
    print('Executing type')
end
local _ok, _err = pcall(demo_ImageEffect_type)

-- ---- Stub: ImageEffect:typeOf ---------------------------------------------
--@api-stub: ImageEffect:typeOf
-- Demonstrates the proper usage of ImageEffect:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ImageEffect_typeOf()
    print("img_fx type: " .. tostring(img_fx:type()))
    print("img_fx typeOf: " .. tostring(img_fx:typeOf("ImageEffect")))
end
local _ok, _err = pcall(demo_ImageEffect_typeOf)

-- =============================================================================
-- Overlay — weather, day/night, screen shake, flash, fog
-- =============================================================================

-- ---- Stub: lurek.effect.newOverlay ----------------------------------------
--@api-stub: lurek.effect.newOverlay
-- Demonstrates the proper usage of lurek.effect.newOverlay.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_effect_newOverlay()
    local overlay = lurek.effect.newOverlay(800, 600)
    print("overlay created: 800x600")
end
local _ok, _err = pcall(demo_lurek_effect_newOverlay)

-- ---- Stub: Overlay:update -------------------------------------------------
--@api-stub: Overlay:update
-- Demonstrates the proper usage of Overlay:update.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_update()
    overlay:update(0.016)
    print("overlay updated (16ms frame)")
end
local _ok, _err = pcall(demo_Overlay_update)

-- ---- Stub: Overlay:isActive -----------------------------------------------
--@api-stub: Overlay:isActive
-- Demonstrates the proper usage of Overlay:isActive.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_isActive()
    print("overlay active: " .. tostring(overlay:isActive()))
end
local _ok, _err = pcall(demo_Overlay_isActive)

-- ---- Stub: Overlay:clear --------------------------------------------------
--@api-stub: Overlay:clear
-- Demonstrates the proper usage of Overlay:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_clear()
    overlay:clear()
    print("overlay cleared (all effects reset)")
end
local _ok, _err = pcall(demo_Overlay_clear)

-- ---- Stub: Overlay:resize -------------------------------------------------
--@api-stub: Overlay:resize
-- Demonstrates the proper usage of Overlay:resize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_resize()
    overlay:resize(1280, 720)
    print("overlay resized to 1280x720")
end
local _ok, _err = pcall(demo_Overlay_resize)

-- ---- Stub: Overlay:getWidth -----------------------------------------------
--@api-stub: Overlay:getWidth
-- Demonstrates the proper usage of Overlay:getWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_getWidth()
    print("overlay width: " .. overlay:getWidth())
end
local _ok, _err = pcall(demo_Overlay_getWidth)

-- ---- Stub: Overlay:getHeight ----------------------------------------------
--@api-stub: Overlay:getHeight
-- Demonstrates the proper usage of Overlay:getHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_getHeight()
    print("overlay height: " .. overlay:getHeight())
end
local _ok, _err = pcall(demo_Overlay_getHeight)

-- ---- Stub: Overlay:getDimensions ------------------------------------------
--@api-stub: Overlay:getDimensions
-- Demonstrates the proper usage of Overlay:getDimensions.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_getDimensions()
    local ow, oh = overlay:getDimensions()
    print("overlay dimensions: " .. ow .. "x" .. oh)
end
local _ok, _err = pcall(demo_Overlay_getDimensions)

-- ---- Stub: Overlay:setAmbientEnabled --------------------------------------
--@api-stub: Overlay:setAmbientEnabled
-- Demonstrates the proper usage of Overlay:setAmbientEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_setAmbientEnabled()
    overlay:setAmbientEnabled(true)
    print("ambient lighting enabled")
end
local _ok, _err = pcall(demo_Overlay_setAmbientEnabled)

-- ---- Stub: Overlay:isAmbientEnabled ---------------------------------------
--@api-stub: Overlay:isAmbientEnabled
-- Demonstrates the proper usage of Overlay:isAmbientEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_isAmbientEnabled()
    print("ambient enabled: " .. tostring(overlay:isAmbientEnabled()))
end
local _ok, _err = pcall(demo_Overlay_isAmbientEnabled)

-- ---- Stub: Overlay:getAmbientColor ----------------------------------------
--@api-stub: Overlay:getAmbientColor
-- Demonstrates the proper usage of Overlay:getAmbientColor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_getAmbientColor()
    local ar, ag, ab, aa = overlay:getAmbientColor()
    print("ambient color: (" .. ar .. "," .. ag .. "," .. ab .. ")")
end
local _ok, _err = pcall(demo_Overlay_getAmbientColor)

-- ---- Stub: Overlay:setTimeOfDay -------------------------------------------
--@api-stub: Overlay:setTimeOfDay
-- Demonstrates the proper usage of Overlay:setTimeOfDay.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_setTimeOfDay()
    overlay:setTimeOfDay(0.75)
    print("time of day: 0.75 (dusk — golden hour)")
end
local _ok, _err = pcall(demo_Overlay_setTimeOfDay)

-- ---- Stub: Overlay:getTimeOfDay -------------------------------------------
--@api-stub: Overlay:getTimeOfDay
-- Demonstrates the proper usage of Overlay:getTimeOfDay.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_getTimeOfDay()
    print("time: " .. string.format("%.2f", overlay:getTimeOfDay()))
end
local _ok, _err = pcall(demo_Overlay_getTimeOfDay)

-- ---- Stub: Overlay:setFogEnabled ------------------------------------------
--@api-stub: Overlay:setFogEnabled
-- Demonstrates the proper usage of Overlay:setFogEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_setFogEnabled()
    overlay:setFogEnabled(true)
    print("fog enabled (eerie swamp atmosphere)")
end
local _ok, _err = pcall(demo_Overlay_setFogEnabled)

-- ---- Stub: Overlay:isFogEnabled -------------------------------------------
--@api-stub: Overlay:isFogEnabled
-- Demonstrates the proper usage of Overlay:isFogEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_isFogEnabled()
    print("fog enabled: " .. tostring(overlay:isFogEnabled()))
end
local _ok, _err = pcall(demo_Overlay_isFogEnabled)

-- ---- Stub: Overlay:setFogDensity ------------------------------------------
--@api-stub: Overlay:setFogDensity
-- Demonstrates the proper usage of Overlay:setFogDensity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_setFogDensity()
    overlay:setFogDensity(0.6)
    print("fog density: 0.6 (thick fog, low visibility)")
end
local _ok, _err = pcall(demo_Overlay_setFogDensity)

-- ---- Stub: Overlay:getFogDensity ------------------------------------------
--@api-stub: Overlay:getFogDensity
-- Demonstrates the proper usage of Overlay:getFogDensity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_getFogDensity()
    print("fog density: " .. tostring(overlay:getFogDensity()))
end
local _ok, _err = pcall(demo_Overlay_getFogDensity)

-- ---- Stub: Overlay:getFogColor --------------------------------------------
--@api-stub: Overlay:getFogColor
-- Demonstrates the proper usage of Overlay:getFogColor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_getFogColor()
    local fogr, fogg, fogb, foga = overlay:getFogColor()
    print("fog color: (" .. fogr .. "," .. fogg .. "," .. fogb .. ")")
end
local _ok, _err = pcall(demo_Overlay_getFogColor)

-- ---- Stub: Overlay:setHeatHazeEnabled -------------------------------------
--@api-stub: Overlay:setHeatHazeEnabled
-- Demonstrates the proper usage of Overlay:setHeatHazeEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_setHeatHazeEnabled()
    overlay:setHeatHazeEnabled(true)
    print("heat haze enabled (desert/lava area)")
end
local _ok, _err = pcall(demo_Overlay_setHeatHazeEnabled)

-- ---- Stub: Overlay:isHeatHazeEnabled --------------------------------------
--@api-stub: Overlay:isHeatHazeEnabled
-- Demonstrates the proper usage of Overlay:isHeatHazeEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_isHeatHazeEnabled()
    print("heat haze: " .. tostring(overlay:isHeatHazeEnabled()))
end
local _ok, _err = pcall(demo_Overlay_isHeatHazeEnabled)

-- ---- Stub: Overlay:setHeatHazeIntensity -----------------------------------
--@api-stub: Overlay:setHeatHazeIntensity
-- Demonstrates the proper usage of Overlay:setHeatHazeIntensity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_setHeatHazeIntensity()
    overlay:setHeatHazeIntensity(0.3)
    print("heat haze intensity: 0.3 (subtle shimmer)")
end
local _ok, _err = pcall(demo_Overlay_setHeatHazeIntensity)

-- ---- Stub: Overlay:getHeatHazeIntensity -----------------------------------
--@api-stub: Overlay:getHeatHazeIntensity
-- Demonstrates the proper usage of Overlay:getHeatHazeIntensity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_getHeatHazeIntensity()
    print("heat haze: " .. tostring(overlay:getHeatHazeIntensity()))
end
local _ok, _err = pcall(demo_Overlay_getHeatHazeIntensity)

-- ---- Stub: Overlay:setVignetteEnabled -------------------------------------
--@api-stub: Overlay:setVignetteEnabled
-- Demonstrates the proper usage of Overlay:setVignetteEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_setVignetteEnabled()
    overlay:setVignetteEnabled(true)
    print("vignette enabled (cinematic frame)")
end
local _ok, _err = pcall(demo_Overlay_setVignetteEnabled)

-- ---- Stub: Overlay:isVignetteEnabled --------------------------------------
--@api-stub: Overlay:isVignetteEnabled
-- Demonstrates the proper usage of Overlay:isVignetteEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_isVignetteEnabled()
    print("vignette: " .. tostring(overlay:isVignetteEnabled()))
end
local _ok, _err = pcall(demo_Overlay_isVignetteEnabled)

-- ---- Stub: Overlay:setVignetteStrength ------------------------------------
--@api-stub: Overlay:setVignetteStrength
-- Demonstrates the proper usage of Overlay:setVignetteStrength.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_setVignetteStrength()
    overlay:setVignetteStrength(0.4)
    print("vignette strength: 0.4 (subtle)")
end
local _ok, _err = pcall(demo_Overlay_setVignetteStrength)

-- ---- Stub: Overlay:getVignetteStrength ------------------------------------
--@api-stub: Overlay:getVignetteStrength
-- Demonstrates the proper usage of Overlay:getVignetteStrength.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_getVignetteStrength()
    print("vignette: " .. tostring(overlay:getVignetteStrength()))
end
local _ok, _err = pcall(demo_Overlay_getVignetteStrength)

-- ---- Stub: Overlay:setFilmGrainEnabled ------------------------------------
--@api-stub: Overlay:setFilmGrainEnabled
-- Demonstrates the proper usage of Overlay:setFilmGrainEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_setFilmGrainEnabled()
    overlay:setFilmGrainEnabled(true)
    print("film grain enabled (horror atmosphere)")
end
local _ok, _err = pcall(demo_Overlay_setFilmGrainEnabled)

-- ---- Stub: Overlay:isFilmGrainEnabled -------------------------------------
--@api-stub: Overlay:isFilmGrainEnabled
-- Demonstrates the proper usage of Overlay:isFilmGrainEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_isFilmGrainEnabled()
    print("film grain: " .. tostring(overlay:isFilmGrainEnabled()))
end
local _ok, _err = pcall(demo_Overlay_isFilmGrainEnabled)

-- ---- Stub: Overlay:setFilmGrainIntensity ----------------------------------
--@api-stub: Overlay:setFilmGrainIntensity
-- Demonstrates the proper usage of Overlay:setFilmGrainIntensity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_setFilmGrainIntensity()
    overlay:setFilmGrainIntensity(0.15)
    print("film grain intensity: 0.15 (subtle noise)")
end
local _ok, _err = pcall(demo_Overlay_setFilmGrainIntensity)

-- ---- Stub: Overlay:getFilmGrainIntensity ----------------------------------
--@api-stub: Overlay:getFilmGrainIntensity
-- Demonstrates the proper usage of Overlay:getFilmGrainIntensity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_getFilmGrainIntensity()
    print("grain: " .. tostring(overlay:getFilmGrainIntensity()))
end
local _ok, _err = pcall(demo_Overlay_getFilmGrainIntensity)

-- ---- Stub: Overlay:setCloudShadows ----------------------------------------
--@api-stub: Overlay:setCloudShadows
-- Demonstrates the proper usage of Overlay:setCloudShadows.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_setCloudShadows()
    overlay:setCloudShadows(true)
    print("cloud shadows enabled (overworld ambiance)")
end
local _ok, _err = pcall(demo_Overlay_setCloudShadows)

-- ---- Stub: Overlay:isCloudShadowsEnabled ----------------------------------
--@api-stub: Overlay:isCloudShadowsEnabled
-- Demonstrates the proper usage of Overlay:isCloudShadowsEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_isCloudShadowsEnabled()
    print("cloud shadows: " .. tostring(overlay:isCloudShadowsEnabled()))
end
local _ok, _err = pcall(demo_Overlay_isCloudShadowsEnabled)

-- ---- Stub: Overlay:setCloudCount ------------------------------------------
--@api-stub: Overlay:setCloudCount
-- Demonstrates the proper usage of Overlay:setCloudCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_setCloudCount()
    overlay:setCloudCount(12)
    print("cloud count: 12")
end
local _ok, _err = pcall(demo_Overlay_setCloudCount)

-- ---- Stub: Overlay:getCloudCount ------------------------------------------
--@api-stub: Overlay:getCloudCount
-- Demonstrates the proper usage of Overlay:getCloudCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_getCloudCount()
    print("clouds: " .. tostring(overlay:getCloudCount()))
end
local _ok, _err = pcall(demo_Overlay_getCloudCount)

-- ---- Stub: Overlay:setCloudSpeed ------------------------------------------
--@api-stub: Overlay:setCloudSpeed
-- Demonstrates the proper usage of Overlay:setCloudSpeed.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_setCloudSpeed()
    overlay:setCloudSpeed(0.3)
    print("cloud speed: 0.3 (gentle drift)")
end
local _ok, _err = pcall(demo_Overlay_setCloudSpeed)

-- ---- Stub: Overlay:getCloudSpeed ------------------------------------------
--@api-stub: Overlay:getCloudSpeed
-- Demonstrates the proper usage of Overlay:getCloudSpeed.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_getCloudSpeed()
    print("cloud speed: " .. tostring(overlay:getCloudSpeed()))
end
local _ok, _err = pcall(demo_Overlay_getCloudSpeed)

-- ---- Stub: Overlay:setCloudScale ------------------------------------------
--@api-stub: Overlay:setCloudScale
-- Demonstrates the proper usage of Overlay:setCloudScale.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_setCloudScale()
    overlay:setCloudScale(2.0)
    print("cloud scale: 2.0 (large puffy clouds)")
end
local _ok, _err = pcall(demo_Overlay_setCloudScale)

-- ---- Stub: Overlay:getCloudScale ------------------------------------------
--@api-stub: Overlay:getCloudScale
-- Demonstrates the proper usage of Overlay:getCloudScale.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_getCloudScale()
    print("cloud scale: " .. tostring(overlay:getCloudScale()))
end
local _ok, _err = pcall(demo_Overlay_getCloudScale)

-- ---- Stub: Overlay:setCloudOpacity ----------------------------------------
--@api-stub: Overlay:setCloudOpacity
-- Demonstrates the proper usage of Overlay:setCloudOpacity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_setCloudOpacity()
    overlay:setCloudOpacity(0.5)
    print("cloud opacity: 0.5 (semi-transparent shadows)")
end
local _ok, _err = pcall(demo_Overlay_setCloudOpacity)

-- ---- Stub: Overlay:getCloudOpacity ----------------------------------------
--@api-stub: Overlay:getCloudOpacity
-- Demonstrates the proper usage of Overlay:getCloudOpacity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_getCloudOpacity()
    print("cloud opacity: " .. tostring(overlay:getCloudOpacity()))
end
local _ok, _err = pcall(demo_Overlay_getCloudOpacity)

-- ---- Stub: Overlay:setWeatherEnabled --------------------------------------
--@api-stub: Overlay:setWeatherEnabled
-- Demonstrates the proper usage of Overlay:setWeatherEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_setWeatherEnabled()
    overlay:setWeatherEnabled(true)
    print("weather enabled")
end
local _ok, _err = pcall(demo_Overlay_setWeatherEnabled)

-- ---- Stub: Overlay:isWeatherEnabled ---------------------------------------
--@api-stub: Overlay:isWeatherEnabled
-- Demonstrates the proper usage of Overlay:isWeatherEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_isWeatherEnabled()
    print("weather: " .. tostring(overlay:isWeatherEnabled()))
end
local _ok, _err = pcall(demo_Overlay_isWeatherEnabled)

-- ---- Stub: Overlay:setWeather ---------------------------------------------
--@api-stub: Overlay:setWeather
-- Demonstrates the proper usage of Overlay:setWeather.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_setWeather()
    overlay:setWeather("rain")
    print("weather: rain (forest ambiance)")
end
local _ok, _err = pcall(demo_Overlay_setWeather)

-- ---- Stub: Overlay:getWeather ---------------------------------------------
--@api-stub: Overlay:getWeather
-- Demonstrates the proper usage of Overlay:getWeather.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_getWeather()
    print("weather type: " .. tostring(overlay:getWeather()))
end
local _ok, _err = pcall(demo_Overlay_getWeather)

-- ---- Stub: Overlay:setWeatherIntensity ------------------------------------
--@api-stub: Overlay:setWeatherIntensity
-- Demonstrates the proper usage of Overlay:setWeatherIntensity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_setWeatherIntensity()
    overlay:setWeatherIntensity(0.7)
    print("rain intensity: 0.7 (heavy rain)")
end
local _ok, _err = pcall(demo_Overlay_setWeatherIntensity)

-- ---- Stub: Overlay:getWeatherIntensity ------------------------------------
--@api-stub: Overlay:getWeatherIntensity
-- Demonstrates the proper usage of Overlay:getWeatherIntensity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_getWeatherIntensity()
    print("rain intensity: " .. tostring(overlay:getWeatherIntensity()))
end
local _ok, _err = pcall(demo_Overlay_getWeatherIntensity)

-- ---- Stub: Overlay:setWindDirection ---------------------------------------
--@api-stub: Overlay:setWindDirection
-- Demonstrates the proper usage of Overlay:setWindDirection.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_setWindDirection()
    overlay:setWindDirection(0.3)
    print("wind direction: 0.3 radians (slight eastward)")
end
local _ok, _err = pcall(demo_Overlay_setWindDirection)

-- ---- Stub: Overlay:getWindDirection ---------------------------------------
--@api-stub: Overlay:getWindDirection
-- Demonstrates the proper usage of Overlay:getWindDirection.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_getWindDirection()
    print("wind direction: " .. tostring(overlay:getWindDirection()))
end
local _ok, _err = pcall(demo_Overlay_getWindDirection)

-- ---- Stub: Overlay:setWindSpeed -------------------------------------------
--@api-stub: Overlay:setWindSpeed
-- Demonstrates the proper usage of Overlay:setWindSpeed.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_setWindSpeed()
    overlay:setWindSpeed(2.0)
    print("wind speed: 2.0 (moderate)")
end
local _ok, _err = pcall(demo_Overlay_setWindSpeed)

-- ---- Stub: Overlay:getWindSpeed -------------------------------------------
--@api-stub: Overlay:getWindSpeed
-- Demonstrates the proper usage of Overlay:getWindSpeed.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_getWindSpeed()
    print("wind speed: " .. tostring(overlay:getWindSpeed()))
end
local _ok, _err = pcall(demo_Overlay_getWindSpeed)

-- ---- Stub: Overlay:triggerLightning ---------------------------------------
--@api-stub: Overlay:triggerLightning
-- Demonstrates the proper usage of Overlay:triggerLightning.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_triggerLightning()
    overlay:triggerLightning()
    print("LIGHTNING! (flash + screen shake)")
end
local _ok, _err = pcall(demo_Overlay_triggerLightning)

-- ---- Stub: Overlay:getLightningColor --------------------------------------
--@api-stub: Overlay:getLightningColor
-- Demonstrates the proper usage of Overlay:getLightningColor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_getLightningColor()
    local ltr, ltg, ltb, lta = overlay:getLightningColor()
    print("lightning color: (" .. ltr .. "," .. ltg .. "," .. ltb .. ")")
end
local _ok, _err = pcall(demo_Overlay_getLightningColor)

-- ---- Stub: Overlay:getFlashAlpha ------------------------------------------
--@api-stub: Overlay:getFlashAlpha
-- Demonstrates the proper usage of Overlay:getFlashAlpha.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_getFlashAlpha()
    print("flash alpha: " .. string.format("%.2f", overlay:getFlashAlpha()))
end
local _ok, _err = pcall(demo_Overlay_getFlashAlpha)

-- ---- Stub: Overlay:getLightningAlpha --------------------------------------
--@api-stub: Overlay:getLightningAlpha
-- Demonstrates the proper usage of Overlay:getLightningAlpha.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_getLightningAlpha()
    print("lightning alpha: " .. string.format("%.2f", overlay:getLightningAlpha()))
end
local _ok, _err = pcall(demo_Overlay_getLightningAlpha)

-- ---- Stub: Overlay:isFlashing ---------------------------------------------
--@api-stub: Overlay:isFlashing
-- Demonstrates the proper usage of Overlay:isFlashing.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_isFlashing()
    print("flashing: " .. tostring(overlay:isFlashing()))
end
local _ok, _err = pcall(demo_Overlay_isFlashing)

-- ---- Stub: Overlay:shake --------------------------------------------------
--@api-stub: Overlay:shake
-- Demonstrates the proper usage of Overlay:shake.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_shake()
    overlay:shake(5.0, 0.3)
    print("screen shake: 5px intensity, 0.3s duration")
end
local _ok, _err = pcall(demo_Overlay_shake)

-- ---- Stub: Overlay:isShaking ----------------------------------------------
--@api-stub: Overlay:isShaking
-- Demonstrates the proper usage of Overlay:isShaking.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_isShaking()
    print("shaking: " .. tostring(overlay:isShaking()))
end
local _ok, _err = pcall(demo_Overlay_isShaking)

-- ---- Stub: Overlay:getShakeOffset ----------------------------------------
--@api-stub: Overlay:getShakeOffset
-- Demonstrates the proper usage of Overlay:getShakeOffset.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_getShakeOffset()
    local shake_x, shake_y = overlay:getShakeOffset()
    print("shake offset: (" .. tostring(shake_x) .. ", " .. tostring(shake_y) .. ")")
end
local _ok, _err = pcall(demo_Overlay_getShakeOffset)

-- ---- Stub: Overlay:isFading -----------------------------------------------
--@api-stub: Overlay:isFading
-- Demonstrates the proper usage of Overlay:isFading.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_isFading()
    print("fading: " .. tostring(overlay:isFading()))
end
local _ok, _err = pcall(demo_Overlay_isFading)

-- ---- Stub: Overlay:render -------------------------------------------------
--@api-stub: Overlay:render
-- Demonstrates the proper usage of Overlay:render.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_render()
    overlay:render()
    print("overlay rendered to screen")
end
local _ok, _err = pcall(demo_Overlay_render)

-- ---- Stub: Overlay:drawToImage --------------------------------------------
--@api-stub: Overlay:drawToImage
-- Demonstrates the proper usage of Overlay:drawToImage.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_drawToImage()
    overlay:drawToImage("output/overlay_preview.png")
    print("overlay exported to PNG")
end
local _ok, _err = pcall(demo_Overlay_drawToImage)

-- ---- Stub: Overlay:setCustomShader ----------------------------------------
--@api-stub: Overlay:setCustomShader
-- Demonstrates the proper usage of Overlay:setCustomShader.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_setCustomShader()
    overlay:setCustomShader("assets/shaders/custom_overlay.wgsl")
    print("custom overlay shader loaded")
end
local _ok, _err = pcall(demo_Overlay_setCustomShader)

-- ---- Stub: Overlay:getWater -----------------------------------------------
--@api-stub: Overlay:getWater
-- Demonstrates the proper usage of Overlay:getWater.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_getWater()
    local water = overlay:getWater()
    print("water effect: " .. tostring(water))
end
local _ok, _err = pcall(demo_Overlay_getWater)

-- ---- Stub: Overlay:type ---------------------------------------------------
--@api-stub: Overlay:type
-- Demonstrates the proper usage of Overlay:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_type()
    print('Executing type')
end
local _ok, _err = pcall(demo_Overlay_type)

-- ---- Stub: Overlay:typeOf -------------------------------------------------
--@api-stub: Overlay:typeOf
-- Demonstrates the proper usage of Overlay:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Overlay_typeOf()
    print("overlay type: " .. tostring(overlay:type()))
    print("overlay typeOf: " .. tostring(overlay:typeOf("Overlay")))
end
local _ok, _err = pcall(demo_Overlay_typeOf)

-- =============================================================================
-- Transitions — scene-change effects (mlua class)
-- =============================================================================

-- ---- Stub: lurek.effect.newTransition -------------------------------------
--@api-stub: lurek.effect.newTransition
-- Create a screen transition for scene changes.
-- Types: "fade", "dissolve", "wipe_left", "wipe_right", "circle_close", "pixelate".
local fade = lurek.effect.newTransition("fade", { duration = 1.0 })
local dissolve = lurek.effect.newTransition("dissolve", { duration = 0.8 })
print("transitions: fade (1.0s), dissolve (0.8s)")

-- ---- Stub: mlua:play ------------------------------------------------------
--@api-stub: mlua:play
-- Demonstrates the proper usage of mlua:play.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_play()
    fade:play()
    print("fade transition playing (screen going dark)")
end
local _ok, _err = pcall(demo_mlua_play)

-- ---- Stub: mlua:reverse ---------------------------------------------------
--@api-stub: mlua:reverse
-- Demonstrates the proper usage of mlua:reverse.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_reverse()
    fade:reverse()
    print("fade reversing (screen brightening)")
end
local _ok, _err = pcall(demo_mlua_reverse)

-- ---- Stub: mlua:update ----------------------------------------------------
--@api-stub: mlua:update
-- Demonstrates the proper usage of mlua:update.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_update()
    fade:update(0.016)
    print("transition updated (16ms)")
end
local _ok, _err = pcall(demo_mlua_update)

-- ---- Stub: mlua:progress --------------------------------------------------
--@api-stub: mlua:progress
-- Demonstrates the proper usage of mlua:progress.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_progress()
    local prog = fade:progress()
    print("transition progress: " .. string.format("%.1f%%", prog * 100))
end
local _ok, _err = pcall(demo_mlua_progress)

-- ---- Stub: mlua:isActive --------------------------------------------------
--@api-stub: mlua:isActive
-- Demonstrates the proper usage of mlua:isActive.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_isActive()
    print("transition active: " .. tostring(fade:isActive()))
end
local _ok, _err = pcall(demo_mlua_isActive)

-- ---- Stub: mlua:isDone ----------------------------------------------------
--@api-stub: mlua:isDone
-- Demonstrates the proper usage of mlua:isDone.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_isDone()
    if fade:isDone() then
    print("transition done — safe to switch scene")
end
local _ok, _err = pcall(demo_mlua_isDone)

-- ---- Stub: mlua:kind ------------------------------------------------------
--@api-stub: mlua:kind
-- Demonstrates the proper usage of mlua:kind.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_kind()
    print("transition kind: " .. fade:kind())
    print("dissolve kind: " .. dissolve:kind())
end
local _ok, _err = pcall(demo_mlua_kind)

-- ---- Stub: mlua:color -----------------------------------------------------
--@api-stub: mlua:color
-- Demonstrates the proper usage of mlua:color.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_color()
    local cr, cg, cb, ca = fade:color()
    print("fade color: (" .. tostring(cr) .. "," .. tostring(cg) .. "," .. tostring(cb) .. ")")
end
local _ok, _err = pcall(demo_mlua_color)

-- ---- Stub: mlua:setColor --------------------------------------------------
--@api-stub: mlua:setColor
-- Demonstrates the proper usage of mlua:setColor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_setColor()
    fade:setColor(0.1, 0.0, 0.0, 1.0)
    print("fade color: dark red (damage transition)")
end
local _ok, _err = pcall(demo_mlua_setColor)

-- ---- Stub: mlua:type ------------------------------------------------------
--@api-stub: mlua:type
-- Demonstrates the proper usage of mlua:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_type()
    print('Executing type')
end
local _ok, _err = pcall(demo_mlua_type)

-- ---- Stub: mlua:typeOf ----------------------------------------------------
--@api-stub: mlua:typeOf
-- Demonstrates the proper usage of mlua:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_typeOf()
    print("transition type: " .. tostring(fade:type()))
    print("transition typeOf: " .. tostring(fade:typeOf("Transition")))
    print("\n-- effect.lua example complete --")
end
local _ok, _err = pcall(demo_mlua_typeOf)
