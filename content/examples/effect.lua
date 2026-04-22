-- content/examples/effect.lua
-- love2d-style usage snippets for the lurek.effect API (142 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/effect.lua

-- ── lurek.effect.* functions ──

--@api-stub: lurek.effect.newEffect
-- Creates a new built-in post-processing effect by type name.
-- Build once at startup; reuse across frames.
local effect = lurek.effect.newEffect("main")
print("created", effect)
return effect

--@api-stub: lurek.effect.newCustomEffect
-- Creates a custom shader post-processing effect.
-- Build once at startup; reuse across frames.
local customeffect = lurek.effect.newCustomEffect(1)
print("created", customeffect)
return customeffect

--@api-stub: lurek.effect.newStack
-- Creates a new post-processing pipeline stack.
-- Build once at startup; reuse across frames.
local stack = lurek.effect.newStack(64, 64)
print("created", stack)
return stack

--@api-stub: lurek.effect.newPresetStack
-- Creates a pre-configured effect stack from a named preset.
-- Build once at startup; reuse across frames.
local presetstack = lurek.effect.newPresetStack("main", 64, 64)
print("created", presetstack)
return presetstack

--@api-stub: lurek.effect.newPass
-- Creates a custom-shader post-processing effect (alias for newCustomEffect).
-- Build once at startup; reuse across frames.
local pass = lurek.effect.newPass(1)
print("created", pass)
return pass

--@api-stub: lurek.effect.getEffectTypes
-- Returns the list of all built-in effect type names.
-- Cheap to call; safe inside callbacks.
local value = lurek.effect.getEffectTypes()
print("getEffectTypes:", value)
return value

--@api-stub: lurek.effect.newImageEffect
-- Creates a new per-image effect chain.
-- Build once at startup; reuse across frames.
local imageeffect = lurek.effect.newImageEffect({ x = 0, y = 0 })
print("created", imageeffect)
return imageeffect

--@api-stub: lurek.effect.newOverlay
-- Creates a new screen overlay controller for weather, flash, shake, and fade effects.
-- Build once at startup; reuse across frames.
local overlay = lurek.effect.newOverlay(64, 64)
print("created", overlay)
return overlay

--@api-stub: lurek.effect.newTransition
-- Creates a new screen-transition controller.
-- Build once at startup; reuse across frames.
local transition = lurek.effect.newTransition(kind, 1.0, {1, 0.5, 0, 1})
print("created", transition)
return transition

--@api-stub: lurek.effect.setShaderErrorDisplay
-- Enables or disables the effect that renders shader compile errors as red text.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.effect.setShaderErrorDisplay(enabled)
print("setShaderErrorDisplay applied")
print("ok")

--@api-stub: lurek.effect.getShaderErrorDisplay
-- Returns whether shader error display is currently enabled.
-- Cheap to call; safe inside callbacks.
local value = lurek.effect.getShaderErrorDisplay()
print("getShaderErrorDisplay:", value)
return value

-- ── PostFxEffect methods ──

--@api-stub: PostFxEffect:getTypeName
-- Returns the display name of this effect type.
-- Cheap to call; safe inside callbacks.
local postFxEffect = lurek.effect.newPostFxEffect()  -- or your existing handle
local value = postFxEffect:getTypeName()
print("PostFxEffect:getTypeName ->", value)

--@api-stub: PostFxEffect:isBuiltIn
-- Returns true if this is a built-in effect, false if custom.
-- Use as a guard inside lurek.update or event handlers.
local postFxEffect = lurek.effect.newPostFxEffect()
if postFxEffect:isBuiltIn() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: PostFxEffect:isEnabled
-- Returns whether this effect is currently active.
-- Use as a guard inside lurek.update or event handlers.
local postFxEffect = lurek.effect.newPostFxEffect()
if postFxEffect:isEnabled() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: PostFxEffect:setEnabled
-- Enables or disables this effect.
-- Apply at startup or in response to user input.
local postFxEffect = lurek.effect.newPostFxEffect()
postFxEffect:setEnabled(enabled)
print("PostFxEffect:setEnabled applied")

--@api-stub: PostFxEffect:setParameter
-- Sets a named float parameter on this effect.
-- Apply at startup or in response to user input.
local postFxEffect = lurek.effect.newPostFxEffect()
postFxEffect:setParameter("main", value)
print("PostFxEffect:setParameter applied")

--@api-stub: PostFxEffect:hasParameter
-- Returns true if the named parameter exists on this effect.
-- Use as a guard inside lurek.update or event handlers.
local postFxEffect = lurek.effect.newPostFxEffect()
if postFxEffect:hasParameter("main") then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: PostFxEffect:getParameterNames
-- Returns a list of all parameter names on this effect.
-- Cheap to call; safe inside callbacks.
local postFxEffect = lurek.effect.newPostFxEffect()  -- or your existing handle
local value = postFxEffect:getParameterNames()
print("PostFxEffect:getParameterNames ->", value)

--@api-stub: PostFxEffect:getEffectType
-- Returns the type name of this effect (alias for getTypeName).
-- Cheap to call; safe inside callbacks.
local postFxEffect = lurek.effect.newPostFxEffect()  -- or your existing handle
local value = postFxEffect:getEffectType()
print("PostFxEffect:getEffectType ->", value)

--@api-stub: PostFxEffect:getType
-- Returns the type name of this effect (alias for getTypeName).
-- Cheap to call; safe inside callbacks.
local postFxEffect = lurek.effect.newPostFxEffect()  -- or your existing handle
local value = postFxEffect:getType()
print("PostFxEffect:getType ->", value)

--@api-stub: PostFxEffect:type
-- Returns the type name "PostFxEffect".
-- See the module spec for detailed semantics.
local postFxEffect = lurek.effect.newPostFxEffect()
postFxEffect:type()
print("PostFxEffect:type done")

--@api-stub: PostFxEffect:typeOf
-- Returns true when the given name matches "PostFxEffect" or a parent type.
-- See the module spec for detailed semantics.
local postFxEffect = lurek.effect.newPostFxEffect()
postFxEffect:typeOf("main")
print("PostFxEffect:typeOf done")

--@api-stub: PostFxEffect:setThreshold
-- Sets the threshold parameter of this effect.
-- Apply at startup or in response to user input.
local postFxEffect = lurek.effect.newPostFxEffect()
postFxEffect:setThreshold(v)
print("PostFxEffect:setThreshold applied")

--@api-stub: PostFxEffect:setIntensity
-- Sets the intensity parameter of this effect.
-- Apply at startup or in response to user input.
local postFxEffect = lurek.effect.newPostFxEffect()
postFxEffect:setIntensity(v)
print("PostFxEffect:setIntensity applied")

--@api-stub: PostFxEffect:setRadius
-- Sets the radius parameter of this effect.
-- Apply at startup or in response to user input.
local postFxEffect = lurek.effect.newPostFxEffect()
postFxEffect:setRadius(v)
print("PostFxEffect:setRadius applied")

--@api-stub: PostFxEffect:setStrength
-- Sets the strength parameter of this effect.
-- Apply at startup or in response to user input.
local postFxEffect = lurek.effect.newPostFxEffect()
postFxEffect:setStrength(v)
print("PostFxEffect:setStrength applied")

--@api-stub: PostFxEffect:setScanlineStrength
-- Sets the scanline strength parameter of this effect.
-- Apply at startup or in response to user input.
local postFxEffect = lurek.effect.newPostFxEffect()
postFxEffect:setScanlineStrength(v)
print("PostFxEffect:setScanlineStrength applied")

--@api-stub: PostFxEffect:setOffset
-- Sets the offset parameter of this effect.
-- Apply at startup or in response to user input.
local postFxEffect = lurek.effect.newPostFxEffect()
postFxEffect:setOffset(v)
print("PostFxEffect:setOffset applied")

--@api-stub: PostFxEffect:setBrightness
-- Sets the brightness parameter of this effect.
-- Apply at startup or in response to user input.
local postFxEffect = lurek.effect.newPostFxEffect()
postFxEffect:setBrightness(v)
print("PostFxEffect:setBrightness applied")

--@api-stub: PostFxEffect:setContrast
-- Sets the contrast parameter of this effect.
-- Apply at startup or in response to user input.
local postFxEffect = lurek.effect.newPostFxEffect()
postFxEffect:setContrast(v)
print("PostFxEffect:setContrast applied")

--@api-stub: PostFxEffect:setSaturation
-- Sets the saturation parameter of this effect.
-- Apply at startup or in response to user input.
local postFxEffect = lurek.effect.newPostFxEffect()
postFxEffect:setSaturation(v)
print("PostFxEffect:setSaturation applied")

-- ── PostFxStack methods ──

--@api-stub: PostFxStack:add
-- Appends a PostFxEffect to the end of the pipeline.
-- Side-effecting; safe to call any time after init.
local postFxStack = lurek.effect.newPostFxStack()
postFxStack:add(effect_ud)
print("PostFxStack:add done")

--@api-stub: PostFxStack:remove
-- Removes the given PostFxEffect from the pipeline.
-- Pair with the matching constructor to free resources.
local postFxStack = lurek.effect.newPostFxStack()
postFxStack:remove(effect_ud)
-- postFxStack is now released
print("ok")

--@api-stub: PostFxStack:isEnabled
-- Returns whether the effect at the given 1-based position is enabled.
-- Use as a guard inside lurek.update or event handlers.
local postFxStack = lurek.effect.newPostFxStack()
if postFxStack:isEnabled(position) then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: PostFxStack:getEffectCount
-- Returns the number of effects in the pipeline.
-- Cheap to call; safe inside callbacks.
local postFxStack = lurek.effect.newPostFxStack()  -- or your existing handle
local value = postFxStack:getEffectCount()
print("PostFxStack:getEffectCount ->", value)

--@api-stub: PostFxStack:getEffect
-- Returns the effect at the given 1-based position, or nil.
-- Cheap to call; safe inside callbacks.
local postFxStack = lurek.effect.newPostFxStack()  -- or your existing handle
local value = postFxStack:getEffect(1)
print("PostFxStack:getEffect ->", value)

--@api-stub: PostFxStack:getEnabledEffects
-- Returns a list of currently enabled effect objects.
-- Cheap to call; safe inside callbacks.
local postFxStack = lurek.effect.newPostFxStack()  -- or your existing handle
local value = postFxStack:getEnabledEffects()
print("PostFxStack:getEnabledEffects ->", value)

--@api-stub: PostFxStack:getWidth
-- Returns the width of the render target.
-- Cheap to call; safe inside callbacks.
local postFxStack = lurek.effect.newPostFxStack()  -- or your existing handle
local value = postFxStack:getWidth()
print("PostFxStack:getWidth ->", value)

--@api-stub: PostFxStack:getHeight
-- Returns the height of the render target.
-- Cheap to call; safe inside callbacks.
local postFxStack = lurek.effect.newPostFxStack()  -- or your existing handle
local value = postFxStack:getHeight()
print("PostFxStack:getHeight ->", value)

--@api-stub: PostFxStack:getDimensions
-- Returns width and height of the render target.
-- Cheap to call; safe inside callbacks.
local postFxStack = lurek.effect.newPostFxStack()  -- or your existing handle
local value = postFxStack:getDimensions()
print("PostFxStack:getDimensions ->", value)

--@api-stub: PostFxStack:resize
-- Resizes the render target to the given dimensions.
-- See the module spec for detailed semantics.
local postFxStack = lurek.effect.newPostFxStack()
postFxStack:resize(64, 64)
print("PostFxStack:resize done")

--@api-stub: PostFxStack:len
-- Returns the total number of effect slots in the pipeline.
-- See the module spec for detailed semantics.
local postFxStack = lurek.effect.newPostFxStack()
postFxStack:len()
print("PostFxStack:len done")

--@api-stub: PostFxStack:isEmpty
-- Returns true if the pipeline has no effect slots.
-- Use as a guard inside lurek.update or event handlers.
local postFxStack = lurek.effect.newPostFxStack()
if postFxStack:isEmpty() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: PostFxStack:clear
-- Removes all effects from the pipeline.
-- Pair with the matching constructor to free resources.
local postFxStack = lurek.effect.newPostFxStack()
postFxStack:clear()
-- postFxStack is now released
print("ok")

--@api-stub: PostFxStack:dedup
-- Removes duplicate effects from the pipeline, keeping the first occurrence.
-- See the module spec for detailed semantics.
local postFxStack = lurek.effect.newPostFxStack()
postFxStack:dedup()
print("PostFxStack:dedup done")

--@api-stub: PostFxStack:isCapturing
-- Returns whether the stack is currently capturing the scene.
-- Use as a guard inside lurek.update or event handlers.
local postFxStack = lurek.effect.newPostFxStack()
if postFxStack:isCapturing() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: PostFxStack:beginCapture
-- Begins capturing the scene for post-processing.
-- See the module spec for detailed semantics.
local postFxStack = lurek.effect.newPostFxStack()
postFxStack:beginCapture()
print("PostFxStack:beginCapture done")

--@api-stub: PostFxStack:endCapture
-- Ends scene capture for post-processing.
-- See the module spec for detailed semantics.
local postFxStack = lurek.effect.newPostFxStack()
postFxStack:endCapture()
print("PostFxStack:endCapture done")

--@api-stub: PostFxStack:apply
-- Applies all enabled effects in the stack and composites the result to screen.
-- Apply at startup or in response to user input.
local postFxStack = lurek.effect.newPostFxStack()
postFxStack:apply()
print("PostFxStack:apply applied")

--@api-stub: PostFxStack:type
-- Returns the type name "PostFxStack".
-- See the module spec for detailed semantics.
local postFxStack = lurek.effect.newPostFxStack()
postFxStack:type()
print("PostFxStack:type done")

--@api-stub: PostFxStack:typeOf
-- Returns true when the given name matches "PostFxStack" or a parent type.
-- See the module spec for detailed semantics.
local postFxStack = lurek.effect.newPostFxStack()
postFxStack:typeOf("main")
print("PostFxStack:typeOf done")

--@api-stub: PostFxStack:setFeedback
-- Sets the feedback loop intensity.
-- Apply at startup or in response to user input.
local postFxStack = lurek.effect.newPostFxStack()
postFxStack:setFeedback(1.0)
print("PostFxStack:setFeedback applied")

--@api-stub: PostFxStack:getFeedback
-- Returns the current feedback loop intensity `[0.0, 1.0]`.
-- Cheap to call; safe inside callbacks.
local postFxStack = lurek.effect.newPostFxStack()  -- or your existing handle
local value = postFxStack:getFeedback()
print("PostFxStack:getFeedback ->", value)

--@api-stub: PostFxStack:clearFeedback
-- Resets the feedback intensity to `0.0` (disables feedback).
-- Pair with the matching constructor to free resources.
local postFxStack = lurek.effect.newPostFxStack()
postFxStack:clearFeedback()
-- postFxStack is now released
print("ok")

-- ── ImageEffect methods ──

--@api-stub: ImageEffect:addEffect
-- Creates a new effect by type name, appends it, and returns the shared PostFxEffect.
-- Side-effecting; safe to call any time after init.
local imageEffect = lurek.effect.newImageEffect()
imageEffect:addEffect("main")
print("ImageEffect:addEffect done")

--@api-stub: ImageEffect:getEffect
-- Returns the effect at the given 1-based index or with the given type name.
-- Cheap to call; safe inside callbacks.
local imageEffect = lurek.effect.newImageEffect()  -- or your existing handle
local value = imageEffect:getEffect("space")
print("ImageEffect:getEffect ->", value)

--@api-stub: ImageEffect:removeEffect
-- Removes the effect at the given 1-based index or with the given type name.
-- Pair with the matching constructor to free resources.
local imageEffect = lurek.effect.newImageEffect()
imageEffect:removeEffect("space")
-- imageEffect is now released
print("ok")

--@api-stub: ImageEffect:clearEffects
-- Removes all effects from the chain.
-- Pair with the matching constructor to free resources.
local imageEffect = lurek.effect.newImageEffect()
imageEffect:clearEffects()
-- imageEffect is now released
print("ok")

--@api-stub: ImageEffect:clear
-- Removes all effects from the chain (alias for clearEffects).
-- Pair with the matching constructor to free resources.
local imageEffect = lurek.effect.newImageEffect()
imageEffect:clear()
-- imageEffect is now released
print("ok")

--@api-stub: ImageEffect:effectCount
-- Returns the number of effects in the chain.
-- See the module spec for detailed semantics.
local imageEffect = lurek.effect.newImageEffect()
imageEffect:effectCount()
print("ImageEffect:effectCount done")

--@api-stub: ImageEffect:getEffectCount
-- Returns the number of effects in the chain (alias for effectCount).
-- Cheap to call; safe inside callbacks.
local imageEffect = lurek.effect.newImageEffect()  -- or your existing handle
local value = imageEffect:getEffectCount()
print("ImageEffect:getEffectCount ->", value)

--@api-stub: ImageEffect:clone
-- Returns a deep copy of this ImageEffect chain.
-- See the module spec for detailed semantics.
local imageEffect = lurek.effect.newImageEffect()
imageEffect:clone()
print("ImageEffect:clone done")

--@api-stub: ImageEffect:save
-- Stub: no-op serialisation placeholder.
-- May block — call from a worker thread for large payloads.
local imageEffect = lurek.effect.newImageEffect()
imageEffect:save()
print("ImageEffect:save done")

--@api-stub: ImageEffect:type
-- Returns the type name "ImageEffect".
-- See the module spec for detailed semantics.
local imageEffect = lurek.effect.newImageEffect()
imageEffect:type()
print("ImageEffect:type done")

--@api-stub: ImageEffect:typeOf
-- Returns true when the given name matches "ImageEffect" or a parent type.
-- See the module spec for detailed semantics.
local imageEffect = lurek.effect.newImageEffect()
imageEffect:typeOf("main")
print("ImageEffect:typeOf done")

--@api-stub: ImageEffect:removeByIndex
-- Removes the effect at the given 0-based index from the chain.
-- Pair with the matching constructor to free resources.
local imageEffect = lurek.effect.newImageEffect()
imageEffect:removeByIndex(1)
-- imageEffect is now released
print("ok")

--@api-stub: ImageEffect:removeByName
-- Removes the first effect matching the given type name.
-- Pair with the matching constructor to free resources.
local imageEffect = lurek.effect.newImageEffect()
imageEffect:removeByName("main")
-- imageEffect is now released
print("ok")

-- ── Overlay methods ──

--@api-stub: Overlay:update
-- Advances all effect subsystems by the given delta time.
-- Apply at startup or in response to user input.
local overlay = lurek.effect.newOverlay()
overlay:update(dt)
print("Overlay:update applied")

--@api-stub: Overlay:triggerLightning
-- Triggers a lightning flash effect.
-- See the module spec for detailed semantics.
local overlay = lurek.effect.newOverlay()
overlay:triggerLightning()
print("Overlay:triggerLightning done")

--@api-stub: Overlay:getShakeOffset
-- Returns the current shake displacement as x, y.
-- Cheap to call; safe inside callbacks.
local overlay = lurek.effect.newOverlay()  -- or your existing handle
local value = overlay:getShakeOffset()
print("Overlay:getShakeOffset ->", value)

--@api-stub: Overlay:isActive
-- Returns true if any effect subsystem is currently active.
-- Use as a guard inside lurek.update or event handlers.
local overlay = lurek.effect.newOverlay()
if overlay:isActive() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Overlay:clear
-- Resets all effect subsystems to their default inactive state.
-- Pair with the matching constructor to free resources.
local overlay = lurek.effect.newOverlay()
overlay:clear()
-- overlay is now released
print("ok")

--@api-stub: Overlay:resize
-- Resizes the effect to match new window dimensions.
-- See the module spec for detailed semantics.
local overlay = lurek.effect.newOverlay()
overlay:resize(64, 64)
print("Overlay:resize done")

--@api-stub: Overlay:getWidth
-- Returns the effect width.
-- Cheap to call; safe inside callbacks.
local overlay = lurek.effect.newOverlay()  -- or your existing handle
local value = overlay:getWidth()
print("Overlay:getWidth ->", value)

--@api-stub: Overlay:getHeight
-- Returns the effect height.
-- Cheap to call; safe inside callbacks.
local overlay = lurek.effect.newOverlay()  -- or your existing handle
local value = overlay:getHeight()
print("Overlay:getHeight ->", value)

--@api-stub: Overlay:getDimensions
-- Returns the effect width and height.
-- Cheap to call; safe inside callbacks.
local overlay = lurek.effect.newOverlay()  -- or your existing handle
local value = overlay:getDimensions()
print("Overlay:getDimensions ->", value)

--@api-stub: Overlay:getFlashAlpha
-- Returns the current flash overlay alpha value.
-- Cheap to call; safe inside callbacks.
local overlay = lurek.effect.newOverlay()  -- or your existing handle
local value = overlay:getFlashAlpha()
print("Overlay:getFlashAlpha ->", value)

--@api-stub: Overlay:getLightningAlpha
-- Returns the current lightning overlay alpha value.
-- Cheap to call; safe inside callbacks.
local overlay = lurek.effect.newOverlay()  -- or your existing handle
local value = overlay:getLightningAlpha()
print("Overlay:getLightningAlpha ->", value)

--@api-stub: Overlay:setAmbientEnabled
-- Enables or disables the ambient light layer.
-- Apply at startup or in response to user input.
local overlay = lurek.effect.newOverlay()
overlay:setAmbientEnabled(v)
print("Overlay:setAmbientEnabled applied")

--@api-stub: Overlay:isAmbientEnabled
-- Returns whether the ambient light layer is active.
-- Use as a guard inside lurek.update or event handlers.
local overlay = lurek.effect.newOverlay()
if overlay:isAmbientEnabled() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Overlay:getAmbientColor
-- Returns the current ambient tint as r, g, b, a components.
-- Cheap to call; safe inside callbacks.
local overlay = lurek.effect.newOverlay()  -- or your existing handle
local value = overlay:getAmbientColor()
print("Overlay:getAmbientColor ->", value)

--@api-stub: Overlay:setTimeOfDay
-- Sets the simulated time-of-day (0â€“24) which drives ambient colour.
-- Apply at startup or in response to user input.
local overlay = lurek.effect.newOverlay()
overlay:setTimeOfDay(v)
print("Overlay:setTimeOfDay applied")

--@api-stub: Overlay:getTimeOfDay
-- Returns the current simulated time-of-day (0â€“24).
-- Cheap to call; safe inside callbacks.
local overlay = lurek.effect.newOverlay()  -- or your existing handle
local value = overlay:getTimeOfDay()
print("Overlay:getTimeOfDay ->", value)

--@api-stub: Overlay:setFogEnabled
-- Enables or disables the fog layer.
-- Apply at startup or in response to user input.
local overlay = lurek.effect.newOverlay()
overlay:setFogEnabled(v)
print("Overlay:setFogEnabled applied")

--@api-stub: Overlay:isFogEnabled
-- Returns whether the fog layer is active.
-- Use as a guard inside lurek.update or event handlers.
local overlay = lurek.effect.newOverlay()
if overlay:isFogEnabled() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Overlay:setFogDensity
-- Sets the fog density (0.0 = clear, 1.0 = fully opaque).
-- Apply at startup or in response to user input.
local overlay = lurek.effect.newOverlay()
overlay:setFogDensity(v)
print("Overlay:setFogDensity applied")

--@api-stub: Overlay:getFogDensity
-- Returns the current fog density.
-- Cheap to call; safe inside callbacks.
local overlay = lurek.effect.newOverlay()  -- or your existing handle
local value = overlay:getFogDensity()
print("Overlay:getFogDensity ->", value)

--@api-stub: Overlay:getFogColor
-- Returns the current fog tint as r, g, b, a components.
-- Cheap to call; safe inside callbacks.
local overlay = lurek.effect.newOverlay()  -- or your existing handle
local value = overlay:getFogColor()
print("Overlay:getFogColor ->", value)

--@api-stub: Overlay:setHeatHazeEnabled
-- Enables or disables the heat-haze distortion layer.
-- Apply at startup or in response to user input.
local overlay = lurek.effect.newOverlay()
overlay:setHeatHazeEnabled(v)
print("Overlay:setHeatHazeEnabled applied")

--@api-stub: Overlay:isHeatHazeEnabled
-- Returns whether the heat-haze layer is active.
-- Use as a guard inside lurek.update or event handlers.
local overlay = lurek.effect.newOverlay()
if overlay:isHeatHazeEnabled() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Overlay:setHeatHazeIntensity
-- Sets the heat-haze distortion intensity (0.0â€“1.0).
-- Apply at startup or in response to user input.
local overlay = lurek.effect.newOverlay()
overlay:setHeatHazeIntensity(v)
print("Overlay:setHeatHazeIntensity applied")

--@api-stub: Overlay:getHeatHazeIntensity
-- Returns the current heat-haze distortion intensity.
-- Cheap to call; safe inside callbacks.
local overlay = lurek.effect.newOverlay()  -- or your existing handle
local value = overlay:getHeatHazeIntensity()
print("Overlay:getHeatHazeIntensity ->", value)

--@api-stub: Overlay:setVignetteEnabled
-- Enables or disables the screen-edge vignette layer.
-- Apply at startup or in response to user input.
local overlay = lurek.effect.newOverlay()
overlay:setVignetteEnabled(v)
print("Overlay:setVignetteEnabled applied")

--@api-stub: Overlay:isVignetteEnabled
-- Returns whether the vignette layer is active.
-- Use as a guard inside lurek.update or event handlers.
local overlay = lurek.effect.newOverlay()
if overlay:isVignetteEnabled() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Overlay:setVignetteStrength
-- Sets the vignette darkening strength (0.0â€“1.0).
-- Apply at startup or in response to user input.
local overlay = lurek.effect.newOverlay()
overlay:setVignetteStrength(v)
print("Overlay:setVignetteStrength applied")

--@api-stub: Overlay:getVignetteStrength
-- Returns the current vignette strength.
-- Cheap to call; safe inside callbacks.
local overlay = lurek.effect.newOverlay()  -- or your existing handle
local value = overlay:getVignetteStrength()
print("Overlay:getVignetteStrength ->", value)

--@api-stub: Overlay:setFilmGrainEnabled
-- Enables or disables the film-grain noise layer.
-- Apply at startup or in response to user input.
local overlay = lurek.effect.newOverlay()
overlay:setFilmGrainEnabled(v)
print("Overlay:setFilmGrainEnabled applied")

--@api-stub: Overlay:isFilmGrainEnabled
-- Returns whether the film-grain layer is active.
-- Use as a guard inside lurek.update or event handlers.
local overlay = lurek.effect.newOverlay()
if overlay:isFilmGrainEnabled() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Overlay:setFilmGrainIntensity
-- Sets the film-grain noise intensity (0.0â€“1.0).
-- Apply at startup or in response to user input.
local overlay = lurek.effect.newOverlay()
overlay:setFilmGrainIntensity(v)
print("Overlay:setFilmGrainIntensity applied")

--@api-stub: Overlay:getFilmGrainIntensity
-- Returns the current film-grain intensity.
-- Cheap to call; safe inside callbacks.
local overlay = lurek.effect.newOverlay()  -- or your existing handle
local value = overlay:getFilmGrainIntensity()
print("Overlay:getFilmGrainIntensity ->", value)

--@api-stub: Overlay:setCloudShadows
-- Enables or disables scrolling cloud-shadow projection.
-- Apply at startup or in response to user input.
local overlay = lurek.effect.newOverlay()
overlay:setCloudShadows(v)
print("Overlay:setCloudShadows applied")

--@api-stub: Overlay:isCloudShadowsEnabled
-- Returns whether cloud shadows are active.
-- Use as a guard inside lurek.update or event handlers.
local overlay = lurek.effect.newOverlay()
if overlay:isCloudShadowsEnabled() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Overlay:setCloudCount
-- Sets the number of cloud shadow instances to render.
-- Apply at startup or in response to user input.
local overlay = lurek.effect.newOverlay()
overlay:setCloudCount(v)
print("Overlay:setCloudCount applied")

--@api-stub: Overlay:getCloudCount
-- Returns the current cloud shadow instance count.
-- Cheap to call; safe inside callbacks.
local overlay = lurek.effect.newOverlay()  -- or your existing handle
local value = overlay:getCloudCount()
print("Overlay:getCloudCount ->", value)

--@api-stub: Overlay:setCloudSpeed
-- Sets the horizontal scroll speed of cloud shadows in pixels per second.
-- Apply at startup or in response to user input.
local overlay = lurek.effect.newOverlay()
overlay:setCloudSpeed(v)
print("Overlay:setCloudSpeed applied")

--@api-stub: Overlay:getCloudSpeed
-- Returns the current cloud shadow scroll speed.
-- Cheap to call; safe inside callbacks.
local overlay = lurek.effect.newOverlay()  -- or your existing handle
local value = overlay:getCloudSpeed()
print("Overlay:getCloudSpeed ->", value)

--@api-stub: Overlay:setCloudScale
-- Sets the scale multiplier applied to each cloud shadow.
-- Apply at startup or in response to user input.
local overlay = lurek.effect.newOverlay()
overlay:setCloudScale(v)
print("Overlay:setCloudScale applied")

--@api-stub: Overlay:getCloudScale
-- Returns the current cloud shadow scale.
-- Cheap to call; safe inside callbacks.
local overlay = lurek.effect.newOverlay()  -- or your existing handle
local value = overlay:getCloudScale()
print("Overlay:getCloudScale ->", value)

--@api-stub: Overlay:setCloudOpacity
-- Sets the opacity of cloud shadows (0.0 = invisible, 1.0 = fully dark).
-- Apply at startup or in response to user input.
local overlay = lurek.effect.newOverlay()
overlay:setCloudOpacity(v)
print("Overlay:setCloudOpacity applied")

--@api-stub: Overlay:getCloudOpacity
-- Returns the current cloud shadow opacity.
-- Cheap to call; safe inside callbacks.
local overlay = lurek.effect.newOverlay()  -- or your existing handle
local value = overlay:getCloudOpacity()
print("Overlay:getCloudOpacity ->", value)

--@api-stub: Overlay:setWeatherEnabled
-- Enables or disables the weather particle system.
-- Apply at startup or in response to user input.
local overlay = lurek.effect.newOverlay()
overlay:setWeatherEnabled(v)
print("Overlay:setWeatherEnabled applied")

--@api-stub: Overlay:isWeatherEnabled
-- Returns whether the weather particle system is active.
-- Use as a guard inside lurek.update or event handlers.
local overlay = lurek.effect.newOverlay()
if overlay:isWeatherEnabled() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Overlay:setWeather
-- Sets the active weather type by name ("none", "rain", "snow", "hail", "dust", "leaves", "ash", "pollen").
-- Apply at startup or in response to user input.
local overlay = lurek.effect.newOverlay()
overlay:setWeather("main")
print("Overlay:setWeather applied")

--@api-stub: Overlay:getWeather
-- Returns the name of the current weather type.
-- Cheap to call; safe inside callbacks.
local overlay = lurek.effect.newOverlay()  -- or your existing handle
local value = overlay:getWeather()
print("Overlay:getWeather ->", value)

--@api-stub: Overlay:setWeatherIntensity
-- Sets the particle spawn rate multiplier (0.0â€“1.0).
-- Apply at startup or in response to user input.
local overlay = lurek.effect.newOverlay()
overlay:setWeatherIntensity(v)
print("Overlay:setWeatherIntensity applied")

--@api-stub: Overlay:getWeatherIntensity
-- Returns the current weather intensity.
-- Cheap to call; safe inside callbacks.
local overlay = lurek.effect.newOverlay()  -- or your existing handle
local value = overlay:getWeatherIntensity()
print("Overlay:getWeatherIntensity ->", value)

--@api-stub: Overlay:setWindDirection
-- Sets the wind direction in radians (0 = right, Ď€/2 = down).
-- Apply at startup or in response to user input.
local overlay = lurek.effect.newOverlay()
overlay:setWindDirection(v)
print("Overlay:setWindDirection applied")

--@api-stub: Overlay:getWindDirection
-- Returns the current wind direction in radians.
-- Cheap to call; safe inside callbacks.
local overlay = lurek.effect.newOverlay()  -- or your existing handle
local value = overlay:getWindDirection()
print("Overlay:getWindDirection ->", value)

--@api-stub: Overlay:setWindSpeed
-- Sets the wind speed applied to weather particles in units per second.
-- Apply at startup or in response to user input.
local overlay = lurek.effect.newOverlay()
overlay:setWindSpeed(v)
print("Overlay:setWindSpeed applied")

--@api-stub: Overlay:getWindSpeed
-- Returns the current wind speed.
-- Cheap to call; safe inside callbacks.
local overlay = lurek.effect.newOverlay()  -- or your existing handle
local value = overlay:getWindSpeed()
print("Overlay:getWindSpeed ->", value)

--@api-stub: Overlay:getLightningColor
-- Returns the lightning flash tint as r, g, b, a components.
-- Cheap to call; safe inside callbacks.
local overlay = lurek.effect.newOverlay()  -- or your existing handle
local value = overlay:getLightningColor()
print("Overlay:getLightningColor ->", value)

--@api-stub: Overlay:isFlashing
-- Returns true while a flash effect is in progress.
-- Use as a guard inside lurek.update or event handlers.
local overlay = lurek.effect.newOverlay()
if overlay:isFlashing() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Overlay:shake
-- Triggers a camera shake; duration defaults to 0.5 s.
-- See the module spec for detailed semantics.
local overlay = lurek.effect.newOverlay()
overlay:shake(intensity, dur)
print("Overlay:shake done")

--@api-stub: Overlay:isShaking
-- Returns true while a shake effect is in progress.
-- Use as a guard inside lurek.update or event handlers.
local overlay = lurek.effect.newOverlay()
if overlay:isShaking() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Overlay:isFading
-- Returns true while a fade effect is in progress.
-- Use as a guard inside lurek.update or event handlers.
local overlay = lurek.effect.newOverlay()
if overlay:isFading() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Overlay:render
-- Emits GPU render commands for all active overlay effects (flash, fade, lightning, vignette).
-- See the module spec for detailed semantics.
local overlay = lurek.effect.newOverlay()
overlay:render()
print("Overlay:render done")

--@api-stub: Overlay:drawToImage
-- Renders the effect state (flash, fade, effects) to a CPU ImageData.
-- Place inside `function lurek.render() ... end`.
local overlay = lurek.effect.newOverlay()
overlay:drawToImage(64, 64)
print("Overlay:drawToImage done")

--@api-stub: Overlay:setCustomShader
-- Assigns a custom shader name to the effect, or clears it when `nil` is passed.
-- Apply at startup or in response to user input.
local overlay = lurek.effect.newOverlay()
overlay:setCustomShader("main")
print("Overlay:setCustomShader applied")

--@api-stub: Overlay:getWater
-- Returns a table describing the current water overlay state.
-- Cheap to call; safe inside callbacks.
local overlay = lurek.effect.newOverlay()  -- or your existing handle
local value = overlay:getWater()
print("Overlay:getWater ->", value)

--@api-stub: Overlay:type
-- Returns the type name of this object ("Overlay").
-- See the module spec for detailed semantics.
local overlay = lurek.effect.newOverlay()
overlay:type()
print("Overlay:type done")

--@api-stub: Overlay:typeOf
-- Returns true if this object is of the given type ("Object" or "Overlay").
-- See the module spec for detailed semantics.
local overlay = lurek.effect.newOverlay()
overlay:typeOf("main")
print("Overlay:typeOf done")

-- ── mlua methods ──

--@api-stub: mlua:play
-- Starts the transition playing forward (scene fades/wipes out).
-- Trigger from input, timers, or game events.
local mlua = lurek.effect.newmlua()
mlua:play()
-- trigger from input, timer, or event
print("ok")

--@api-stub: mlua:reverse
-- Starts the transition in reverse (scene fades/wipes in).
-- See the module spec for detailed semantics.
local mlua = lurek.effect.newmlua()
mlua:reverse()
print("mlua:reverse done")

--@api-stub: mlua:update
-- Advances the transition by `dt` seconds.
-- Apply at startup or in response to user input.
local mlua = lurek.effect.newmlua()
mlua:update(dt)
print("mlua:update applied")

--@api-stub: mlua:progress
-- Returns the fractional progress `[0, 1]` of the transition, taking.
-- See the module spec for detailed semantics.
local mlua = lurek.effect.newmlua()
mlua:progress()
print("mlua:progress done")

--@api-stub: mlua:isActive
-- Returns `true` while the transition is running.
-- Use as a guard inside lurek.update or event handlers.
local mlua = lurek.effect.newmlua()
if mlua:isActive() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: mlua:isDone
-- Returns `true` after the transition has completed.
-- Use as a guard inside lurek.update or event handlers.
local mlua = lurek.effect.newmlua()
if mlua:isDone() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: mlua:kind
-- Returns the transition kind name (`"fade"`, `"wipe"`, `"iris_wipe"`,.
-- See the module spec for detailed semantics.
local mlua = lurek.effect.newmlua()
mlua:kind()
print("mlua:kind done")

--@api-stub: mlua:color
-- Returns the fill color as four numbers: `r, g, b, a`.
-- See the module spec for detailed semantics.
local mlua = lurek.effect.newmlua()
mlua:color()
print("mlua:color done")

--@api-stub: mlua:setColor
-- Updates the fill color from `{r, g, b, a?}`.
-- Apply at startup or in response to user input.
local mlua = lurek.effect.newmlua()
mlua:setColor()
print("mlua:setColor applied")

--@api-stub: mlua:type
-- Type.
-- See the module spec for detailed semantics.
local mlua = lurek.effect.newmlua()
mlua:type()
print("mlua:type done")

--@api-stub: mlua:typeOf
-- Type of.
-- See the module spec for detailed semantics.
local mlua = lurek.effect.newmlua()
mlua:typeOf("main")
print("mlua:typeOf done")

