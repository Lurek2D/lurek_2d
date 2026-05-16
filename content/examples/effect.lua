-- content/examples/effect.lua
-- lurek.effect API examples.
-- Run: cargo run -- content/examples/effect.lua

--@api-stub: lurek.effect.newEffect -- Creates a built-in post-processing effect by type name
do -- lurek.effect.newEffect
  local bloom = lurek.effect.newEffect("bloom")
  bloom:setThreshold(0.6)
  bloom:setIntensity(1.5)
  lurek.log.info("bloom built-in=" .. tostring(bloom:isBuiltIn()), "fx")
end

--@api-stub: lurek.effect.newCustomEffect -- Creates a custom post-processing effect that references an existing shader id
do -- lurek.effect.newCustomEffect
  local shader_id = 7  -- shader handle created during setup
  local glitch = lurek.effect.newCustomEffect(shader_id)
  glitch:setParameter("intensity", 0.4)
  lurek.log.info("custom fx built-in=" .. tostring(glitch:isBuiltIn()), "fx")
end

--@api-stub: lurek.effect.newStack -- Creates a post-processing stack using optional dimensions or the current window size
do -- lurek.effect.newStack
  local stack = lurek.effect.newStack()
  stack:add(lurek.effect.newEffect("bloom"))
  stack:add(lurek.effect.newEffect("vignette"))
  lurek.log.info("stack ready w=" .. stack:getWidth() .. " h=" .. stack:getHeight(), "fx")
end

--@api-stub: lurek.effect.newPresetStack -- Creates a named preset post-processing stack with optional dimensions
do -- lurek.effect.newPresetStack
  local crt = lurek.effect.newPresetStack("retro_tv", 1280, 720)
  function lurek.draw()
    crt:beginCapture(); crt:endCapture(); crt:apply()
  end
end

--@api-stub: lurek.effect.newPass -- Creates a custom post-processing pass from an existing shader id
do -- lurek.effect.newPass
  local shader_id = 3  -- shader handle created during setup
  local edge_pass = lurek.effect.newPass(shader_id)
  edge_pass:setParameter("threshold", 0.2)
  lurek.log.debug("pass enabled=" .. tostring(edge_pass:isEnabled()), "fx")
end

--@api-stub: lurek.effect.getEffectTypes -- Returns all built-in post-processing effect type names
do -- lurek.effect.getEffectTypes
  local types = lurek.effect.getEffectTypes()
  for i, name in ipairs(types) do
    lurek.log.info("[" .. i .. "] " .. name, "fx-types")
  end
end

--@api-stub: lurek.effect.newImageEffect -- Creates an image effect chain from no arguments, a type name and optional parameters, or a chain table
do -- lurek.effect.newImageEffect
  local chain = lurek.effect.newImageEffect({
    { type = "blur", radius = 3.0 },
    { type = "vignette", strength = 0.4 },
  })
  lurek.log.info("image chain count=" .. chain:effectCount(), "fx")
end

--@api-stub: lurek.effect.newOverlay -- Creates an overlay controller for screen effects using optional dimensions
do -- lurek.effect.newOverlay
  local overlay = lurek.effect.newOverlay(1280, 720)
  overlay:setWeather("rain")
  overlay:setWeatherEnabled(true)
  function lurek.process(dt) overlay:update(dt) end
end

--@api-stub: lurek.effect.newTransition -- Creates a timed screen transition with optional kind, duration, and color
do -- lurek.effect.newTransition
  local trans = lurek.effect.newTransition("wipe", 0.75, {0, 0, 0, 1})
  trans:play()
  function lurek.process(dt)
    if trans:update(dt) then lurek.log.debug("trans p=" .. trans:progress(), "fx") end
  end
end

--@api-stub: lurek.effect.setShaderErrorDisplay -- Enables or disables renderer shader error display overlays
do -- lurek.effect.setShaderErrorDisplay
  local in_dev = true
  lurek.effect.setShaderErrorDisplay(in_dev)
  lurek.log.info("shader err display=" .. tostring(in_dev), "fx-dev")
end

--@api-stub: lurek.effect.getShaderErrorDisplay -- Returns whether renderer shader error display overlays are enabled
do -- lurek.effect.getShaderErrorDisplay
  if lurek.effect.getShaderErrorDisplay() then
    lurek.log.warn("dev shader error overlay is ON â€” disable for shipping", "fx-dev")
  end
end

-- â”€â”€ PostFxEffect methods â”€â”€

--@api-stub: PostFxEffect:getTypeName
do -- PostFxEffect:getTypeName
  local eff = lurek.effect.newEffect("crt")
  local name = eff:getTypeName()
  lurek.log.info("active fx: " .. name, "fx")
end

--@api-stub: PostFxEffect:isBuiltIn
do -- PostFxEffect:isBuiltIn
  local eff = lurek.effect.newEffect("vignette")
  if eff:isBuiltIn() then
    lurek.log.info("safe to serialise '" .. eff:getTypeName() .. "' by name", "fx")
  end
end

--@api-stub: PostFxEffect:isEnabled
do -- PostFxEffect:isEnabled
  local bloom = lurek.effect.newEffect("bloom")
  bloom:setEnabled(false)
  if not bloom:isEnabled() then
    lurek.log.debug("bloom currently muted", "fx")
  end
end

--@api-stub: PostFxEffect:setEnabled
do -- PostFxEffect:setEnabled
  local crt = lurek.effect.newEffect("crt")
  local low_quality = true
  crt:setEnabled(not low_quality)
end

--@api-stub: PostFxEffect:setParameter
do -- PostFxEffect:setParameter
  local bloom = lurek.effect.newEffect("bloom")
  bloom:setParameter("threshold", 0.5)
  bloom:setParameter("intensity", 1.2)
  lurek.log.debug("bloom configured", "fx")
end

--@api-stub: PostFxEffect:hasParameter
do -- PostFxEffect:hasParameter
  local eff = lurek.effect.newEffect("crt")
  if eff:hasParameter("scanline_strength") then
    eff:setParameter("scanline_strength", 0.7)
  end
end

--@api-stub: PostFxEffect:getParameterNames
do -- PostFxEffect:getParameterNames
  local eff = lurek.effect.newEffect("colourgrade")
  for _, name in ipairs(eff:getParameterNames()) do
    lurek.log.info("colourgrade param: " .. name, "fx-edit")
  end
end

--@api-stub: PostFxEffect:getEffectType
do -- PostFxEffect:getEffectType
  local eff = lurek.effect.newEffect("sepia")
  local kind = eff:getEffectType()
  lurek.log.info("kind=" .. kind, "fx")
end

--@api-stub: PostFxEffect:getType
do -- PostFxEffect:getType
  local eff = lurek.effect.newEffect("invert")
  if eff:getType() == "invert" then
    lurek.log.debug("invert pass detected", "fx")
  end
end

--@api-stub: PostFxEffect:type
do -- PostFxEffect:type
  local eff = lurek.effect.newEffect("bloom")
  lurek.log.debug("effect type: " .. eff:type(), "fx")
end

--@api-stub: PostFxEffect:typeOf
do -- PostFxEffect:typeOf
  local eff = lurek.effect.newEffect("blur")
  if eff:typeOf("Object") then
    lurek.log.debug("eff inherits from Object", "fx")
  end
end

--@api-stub: PostFxEffect:setThreshold
do -- PostFxEffect:setThreshold
  local bloom = lurek.effect.newEffect("bloom")
  bloom:setThreshold(0.75)
  lurek.log.debug("bloom threshold set", "fx")
end

--@api-stub: PostFxEffect:setIntensity
do -- PostFxEffect:setIntensity
  local godrays = lurek.effect.newEffect("godrays")
  godrays:setIntensity(1.4)
end

--@api-stub: PostFxEffect:setRadius
do -- PostFxEffect:setRadius
  local blur = lurek.effect.newEffect("blur")
  blur:setRadius(4.0)
end

--@api-stub: PostFxEffect:setStrength
do -- PostFxEffect:setStrength
  local vig = lurek.effect.newEffect("vignette")
  local from_slider = 0.6
  vig:setStrength(math.max(0.0, math.min(1.0, from_slider)))
end

--@api-stub: PostFxEffect:setScanlineStrength
do -- PostFxEffect:setScanlineStrength
  local crt = lurek.effect.newEffect("crt")
  crt:setScanlineStrength(0.35)
  crt:setIntensity(1.0)
end

--@api-stub: PostFxEffect:setOffset
do -- PostFxEffect:setOffset
  local chroma = lurek.effect.newEffect("chromatic")
  chroma:setOffset(2.0)
end

--@api-stub: PostFxEffect:setBrightness
do -- PostFxEffect:setBrightness
  local grade = lurek.effect.newEffect("colourgrade")
  grade:setBrightness(0.05)
end

--@api-stub: PostFxEffect:setContrast
do -- PostFxEffect:setContrast
  local grade = lurek.effect.newEffect("colourgrade")
  grade:setContrast(1.15)
end

--@api-stub: PostFxEffect:setSaturation
do -- PostFxEffect:setSaturation
  local grade = lurek.effect.newEffect("colourgrade")
  grade:setSaturation(0.7)  -- desaturated mood
end

-- â”€â”€ PostFxStack methods â”€â”€

--@api-stub: PostFxStack:add
do -- PostFxStack:add
  local stack = lurek.effect.newStack()
  stack:add(lurek.effect.newEffect("bloom"))
  stack:add(lurek.effect.newEffect("vignette"))
  lurek.log.info("stack size=" .. stack:getEffectCount(), "fx")
end

--@api-stub: PostFxStack:remove
do -- PostFxStack:remove
  local stack = lurek.effect.newStack()
  local crt = lurek.effect.newEffect("crt")
  stack:add(crt)
  local removed = stack:remove(crt)
  lurek.log.debug("crt removed=" .. tostring(removed), "fx")
end

--@api-stub: PostFxStack:isEnabled
do -- PostFxStack:isEnabled
  local stack = lurek.effect.newStack()
  stack:add(lurek.effect.newEffect("bloom"))
  if stack:isEnabled(1) then
    lurek.log.debug("slot 1 active", "fx")
  end
end

--@api-stub: PostFxStack:getEffectCount
do -- PostFxStack:getEffectCount
  local stack = lurek.effect.newStack()
  stack:add(lurek.effect.newEffect("bloom"))
  stack:add(lurek.effect.newEffect("crt"))
  for i = 1, stack:getEffectCount() do
    local effect = assert(stack:getEffect(i))
    lurek.log.info("slot " .. i .. " = " .. effect:getTypeName(), "fx")
  end
end

--@api-stub: PostFxStack:getEffect
do -- PostFxStack:getEffect
  local stack = lurek.effect.newStack()
  stack:add(lurek.effect.newEffect("vignette"))
  local first = stack:getEffect(1)
  if first then first:setStrength(0.8) end
end

--@api-stub: PostFxStack:getEnabledEffects
do -- PostFxStack:getEnabledEffects
  local stack = lurek.effect.newStack()
  stack:add(lurek.effect.newEffect("bloom"))
  for _, eff in ipairs(stack:getEnabledEffects()) do
    lurek.log.debug("enabled: " .. eff:getTypeName(), "fx")
  end
end

--@api-stub: PostFxStack:getWidth
do -- PostFxStack:getWidth
  local stack = lurek.effect.newStack(1920, 1080)
  if stack:getWidth() ~= 1920 then
    lurek.log.warn("stack width drift: " .. stack:getWidth(), "fx")
  end
end

--@api-stub: PostFxStack:getHeight
do -- PostFxStack:getHeight
  local stack = lurek.effect.newStack(1280, 720)
  if stack:getHeight() < 480 then
    lurek.log.warn("stack height too small for HUD layout", "fx")
  end
end

--@api-stub: PostFxStack:getDimensions
do -- PostFxStack:getDimensions
  local stack = lurek.effect.newStack()
  local w, h = stack:getDimensions()
  lurek.log.info("stack target = " .. w .. "x" .. h, "fx")
end

--@api-stub: PostFxStack:resize
do -- PostFxStack:resize
  local stack = lurek.effect.newStack(800, 600)
  local new_w, new_h = 1600, 900
  stack:resize(new_w, new_h)
  lurek.log.info("stack resized to " .. new_w .. "x" .. new_h, "fx")
end

--@api-stub: PostFxStack:len
do -- PostFxStack:len
  local stack = lurek.effect.newStack()
  stack:add(lurek.effect.newEffect("bloom"))
  lurek.log.debug("stack len=" .. stack:len(), "fx")
end

--@api-stub: PostFxStack:isEmpty
do -- PostFxStack:isEmpty
  local stack = lurek.effect.newStack()
  if stack:isEmpty() then
    lurek.log.debug("post-fx pipeline empty â€” skipping capture", "fx")
  end
end

--@api-stub: PostFxStack:clear
do -- PostFxStack:clear
  local stack = lurek.effect.newStack()
  stack:add(lurek.effect.newEffect("crt"))
  stack:clear()
  lurek.log.info("pipeline cleared, count=" .. stack:getEffectCount(), "fx")
end

--@api-stub: PostFxStack:dedup
do -- PostFxStack:dedup
  local stack = lurek.effect.newStack()
  local bloom = lurek.effect.newEffect("bloom")
  stack:add(bloom); stack:add(bloom)
  local removed = stack:dedup()
  lurek.log.info("dedup removed " .. tostring(removed) .. " duplicate slot(s)", "fx")
end

--@api-stub: PostFxStack:isCapturing
do -- PostFxStack:isCapturing
  local stack = lurek.effect.newStack()
  function lurek.draw()
    stack:beginCapture()
    assert(stack:isCapturing(), "post-fx capture should be active here")
    stack:endCapture(); stack:apply()
  end
end

--@api-stub: PostFxStack:beginCapture
do -- PostFxStack:beginCapture
  local stack = lurek.effect.newStack()
  stack:add(lurek.effect.newEffect("bloom"))
  function lurek.draw()
    stack:beginCapture()
    -- scene draws happen here
    stack:endCapture(); stack:apply()
  end
end

--@api-stub: PostFxStack:endCapture
do -- PostFxStack:endCapture
  local stack = lurek.effect.newStack()
  function lurek.draw()
    stack:beginCapture()
    stack:endCapture()
    stack:apply()
  end
end

--@api-stub: PostFxStack:apply
do -- PostFxStack:apply
  local stack = lurek.effect.newStack()
  stack:add(lurek.effect.newEffect("bloom"))
  function lurek.draw()
    stack:beginCapture(); stack:endCapture()
    stack:apply()
  end
end

--@api-stub: PostFxStack:type
do -- PostFxStack:type
  local stack = lurek.effect.newStack()
  if stack:type() == "PostFxStack" then
    lurek.log.debug("got a real post-fx stack", "fx")
  end
end

--@api-stub: PostFxStack:typeOf
do -- PostFxStack:typeOf
  local stack = lurek.effect.newStack()
  assert(stack:typeOf("Object"), "PostFxStack should inherit Object")
end

--@api-stub: PostFxStack:setFeedback
do -- PostFxStack:setFeedback
  local stack = lurek.effect.newStack()
  stack:setFeedback(0.85)  -- strong trail for a dream sequence
  lurek.log.info("feedback=" .. stack:getFeedback(), "fx")
end

--@api-stub: PostFxStack:getFeedback
do -- PostFxStack:getFeedback
  local stack = lurek.effect.newStack()
  stack:setFeedback(2.0)  -- will be clamped
  lurek.log.info("clamped feedback=" .. stack:getFeedback(), "fx")
end

--@api-stub: PostFxStack:clearFeedback
do -- PostFxStack:clearFeedback
  local stack = lurek.effect.newStack()
  stack:setFeedback(0.6)
  stack:clearFeedback()
  lurek.log.debug("feedback cleared=" .. stack:getFeedback(), "fx")
end

-- â”€â”€ ImageEffect methods â”€â”€

--@api-stub: ImageEffect:addEffect
do -- ImageEffect:addEffect
  local chain = lurek.effect.newImageEffect()
  local blur = chain:addEffect("blur")
  blur:setRadius(2.5)
  lurek.log.info("chain size=" .. chain:effectCount(), "fx")
end

--@api-stub: ImageEffect:getEffect
do -- ImageEffect:getEffect
  local chain = lurek.effect.newImageEffect({{ type = "vignette" }})
  local vig = chain:getEffect("vignette")
  if vig then vig:setStrength(0.5) end
end

--@api-stub: ImageEffect:removeEffect
do -- ImageEffect:removeEffect
  local chain = lurek.effect.newImageEffect({{ type = "blur" }, { type = "vignette" }})
  local removed = chain:removeEffect("blur")
  lurek.log.debug("blur removed=" .. tostring(removed) .. " count=" .. chain:effectCount(), "fx")
end

--@api-stub: ImageEffect:clearEffects
do -- ImageEffect:clearEffects
  local chain = lurek.effect.newImageEffect({{ type = "bloom" }})
  chain:clearEffects()
  assert(chain:effectCount() == 0, "chain should be empty")
end

--@api-stub: ImageEffect:clear
do -- ImageEffect:clear
  local chain = lurek.effect.newImageEffect({{ type = "crt" }})
  chain:clear()
  lurek.log.debug("chain cleared", "fx")
end

--@api-stub: ImageEffect:effectCount
do -- ImageEffect:effectCount
  local chain = lurek.effect.newImageEffect({{ type = "blur" }, { type = "vignette" }})
  if chain:effectCount() > 0 then
    lurek.log.info("image chain has " .. chain:effectCount() .. " passes", "fx")
  end
end

--@api-stub: ImageEffect:getEffectCount
do -- ImageEffect:getEffectCount
  local chain = lurek.effect.newImageEffect({{ type = "sepia" }})
  lurek.log.debug("count=" .. chain:getEffectCount(), "fx")
end

--@api-stub: ImageEffect:clone
do -- ImageEffect:clone
  local base = lurek.effect.newImageEffect({{ type = "vignette", strength = 0.4 }})
  local night = base:clone()
  night:addEffect("colourgrade"):setBrightness(-0.1)
end

--@api-stub: ImageEffect:save
do -- ImageEffect:save
  local chain = lurek.effect.newImageEffect({{ type = "bloom" }})
  if chain:save() then
    lurek.log.debug("image chain save() acknowledged", "fx")
  end
end

--@api-stub: ImageEffect:type
do -- ImageEffect:type
  local chain = lurek.effect.newImageEffect()
  if chain:type() == "ImageEffect" then
    lurek.log.debug("per-image chain detected", "fx")
  end
end

--@api-stub: ImageEffect:typeOf
do -- ImageEffect:typeOf
  local chain = lurek.effect.newImageEffect()
  assert(chain:typeOf("Object"), "ImageEffect should be an Object")
end

--@api-stub: ImageEffect:removeByIndex
do -- ImageEffect:removeByIndex
  local chain = lurek.effect.newImageEffect({{ type = "blur" }, { type = "crt" }})
  local removed = chain:removeByIndex(0)  -- removes the blur
  lurek.log.debug("by-index removed=" .. tostring(removed), "fx")
end

--@api-stub: ImageEffect:removeByName
do -- ImageEffect:removeByName
  local chain = lurek.effect.newImageEffect({{ type = "vignette" }, { type = "sepia" }})
  chain:removeByName("vignette")
  lurek.log.debug("after by-name remove count=" .. chain:effectCount(), "fx")
end

-- â”€â”€ Overlay methods â”€â”€

--@api-stub: Overlay:update
do -- Overlay:update
  local overlay = lurek.effect.newOverlay()
  function lurek.process(dt)
    overlay:update(dt)
  end
end

--@api-stub: Overlay:triggerLightning
do -- Overlay:triggerLightning
  local overlay = lurek.effect.newOverlay()
  overlay:triggerLightning()
  lurek.log.info("lightning fired alpha=" .. overlay:getLightningAlpha(), "weather")
end

--@api-stub: Overlay:getShakeOffset
do -- Overlay:getShakeOffset
  local overlay = lurek.effect.newOverlay()
  overlay:shake(8.0, 0.4)
  function lurek.draw()
    local ox, oy = overlay:getShakeOffset()
    lurek.log.debug("shake ox=" .. ox .. " oy=" .. oy, "shake")
  end
end

--@api-stub: Overlay:isActive
do -- Overlay:isActive
  local overlay = lurek.effect.newOverlay()
  if overlay:isActive() then
    function lurek.draw() overlay:render() end
  end
end

--@api-stub: Overlay:clear
do -- Overlay:clear
  local overlay = lurek.effect.newOverlay()
  overlay:flash(1, 1, 1, 1, 0.5)
  overlay:clear()
  assert(not overlay:isFlashing(), "flash should be cancelled")
end

--@api-stub: Overlay:resize
do -- Overlay:resize
  local overlay = lurek.effect.newOverlay(800, 600)
  overlay:resize(1920, 1080)
  lurek.log.info("overlay resized to " .. overlay:getWidth() .. "x" .. overlay:getHeight(), "fx")
end

--@api-stub: Overlay:getWidth
do -- Overlay:getWidth
  local overlay = lurek.effect.newOverlay(1024, 768)
  lurek.log.debug("overlay w=" .. overlay:getWidth(), "fx")
end

--@api-stub: Overlay:getHeight
do -- Overlay:getHeight
  local overlay = lurek.effect.newOverlay(1024, 768)
  lurek.log.debug("overlay h=" .. overlay:getHeight(), "fx")
end

--@api-stub: Overlay:getDimensions
do -- Overlay:getDimensions
  local overlay = lurek.effect.newOverlay()
  local w, h = overlay:getDimensions()
  lurek.log.info("overlay = " .. w .. "x" .. h, "fx")
end

--@api-stub: Overlay:getFlashAlpha
do -- Overlay:getFlashAlpha
  local overlay = lurek.effect.newOverlay()
  overlay:flash(1, 1, 1, 1, 0.3)
  function lurek.process(dt)
    overlay:update(dt)
    if overlay:getFlashAlpha() > 0.5 then lurek.log.debug("flash peak", "fx") end
  end
end

--@api-stub: Overlay:getLightningAlpha
do -- Overlay:getLightningAlpha
  local overlay = lurek.effect.newOverlay()
  overlay:triggerLightning()
  function lurek.process(dt)
    overlay:update(dt)
    local a = overlay:getLightningAlpha()
    if a > 0.0 then lurek.log.debug("lightning a=" .. a, "fx") end
  end
end

--@api-stub: Overlay:setAmbientEnabled
do -- Overlay:setAmbientEnabled
  local overlay = lurek.effect.newOverlay()
  overlay:setAmbientEnabled(true)
  overlay:setTimeOfDay(20.0)  -- evening
end

--@api-stub: Overlay:isAmbientEnabled
do -- Overlay:isAmbientEnabled
  local overlay = lurek.effect.newOverlay()
  if overlay:isAmbientEnabled() then
    lurek.log.debug("ambient layer is live", "fx")
  end
end

--@api-stub: Overlay:getAmbientColor
do -- Overlay:getAmbientColor
  local overlay = lurek.effect.newOverlay()
  overlay:setAmbientEnabled(true)
  local r, g, b, a = overlay:getAmbientColor()
  lurek.log.info(string.format("ambient %.2f %.2f %.2f a=%.2f", r, g, b, a), "fx")
end

--@api-stub: Overlay:setTimeOfDay
do -- Overlay:setTimeOfDay
  local overlay = lurek.effect.newOverlay()
  overlay:setAmbientEnabled(true)
  overlay:setTimeOfDay(7.5)  -- early morning
end

--@api-stub: Overlay:getTimeOfDay
do -- Overlay:getTimeOfDay
  local overlay = lurek.effect.newOverlay()
  overlay:setTimeOfDay(18.0)
  if overlay:getTimeOfDay() > 18.0 then
    lurek.log.info("dusk â€” enable street lamps", "world")
  end
end

--@api-stub: Overlay:setFogEnabled
do -- Overlay:setFogEnabled
  local overlay = lurek.effect.newOverlay()
  overlay:setFogEnabled(true)
  overlay:setFogDensity(0.4)
end

--@api-stub: Overlay:isFogEnabled
do -- Overlay:isFogEnabled
  local overlay = lurek.effect.newOverlay()
  if not overlay:isFogEnabled() then
    overlay:setFogEnabled(true)
  end
end

--@api-stub: Overlay:setFogDensity
do -- Overlay:setFogDensity
  local overlay = lurek.effect.newOverlay()
  overlay:setFogEnabled(true)
  local target = 0.6
  overlay:setFogDensity(target)
end

--@api-stub: Overlay:getFogDensity
do -- Overlay:getFogDensity
  local overlay = lurek.effect.newOverlay()
  overlay:setFogDensity(0.3)
  lurek.log.debug("fog density=" .. overlay:getFogDensity(), "fx")
end

--@api-stub: Overlay:getFogColor
do -- Overlay:getFogColor
  local overlay = lurek.effect.newOverlay()
  overlay:setFogEnabled(true)
  local r, g, b = overlay:getFogColor()
  lurek.log.info(string.format("fog rgb %.2f %.2f %.2f", r, g, b), "fx")
end

--@api-stub: Overlay:setHeatHazeEnabled
do -- Overlay:setHeatHazeEnabled
  local overlay = lurek.effect.newOverlay()
  overlay:setHeatHazeEnabled(true)
  overlay:setHeatHazeIntensity(0.5)
end

--@api-stub: Overlay:isHeatHazeEnabled
do -- Overlay:isHeatHazeEnabled
  local overlay = lurek.effect.newOverlay()
  if overlay:isHeatHazeEnabled() then
    lurek.log.debug("heat haze on", "fx")
  end
end

--@api-stub: Overlay:setHeatHazeIntensity
do -- Overlay:setHeatHazeIntensity
  local overlay = lurek.effect.newOverlay()
  overlay:setHeatHazeEnabled(true)
  local temp_c = 42
  overlay:setHeatHazeIntensity(math.min(1.0, math.max(0.0, (temp_c - 30) / 20)))
end

--@api-stub: Overlay:getHeatHazeIntensity
do -- Overlay:getHeatHazeIntensity
  local overlay = lurek.effect.newOverlay()
  overlay:setHeatHazeIntensity(0.6)
  lurek.log.debug("heat haze i=" .. overlay:getHeatHazeIntensity(), "fx")
end

--@api-stub: Overlay:setVignetteEnabled
do -- Overlay:setVignetteEnabled
  local overlay = lurek.effect.newOverlay()
  overlay:setVignetteEnabled(true)
  overlay:setVignetteStrength(0.55)
end

--@api-stub: Overlay:isVignetteEnabled
do -- Overlay:isVignetteEnabled
  local overlay = lurek.effect.newOverlay()
  if overlay:isVignetteEnabled() then
    overlay:setVignetteStrength(0.7)
  end
end

--@api-stub: Overlay:setVignetteStrength
do -- Overlay:setVignetteStrength
  local overlay = lurek.effect.newOverlay()
  overlay:setVignetteEnabled(true)
  overlay:setVignetteStrength(0.45)
end

--@api-stub: Overlay:getVignetteStrength
do -- Overlay:getVignetteStrength
  local overlay = lurek.effect.newOverlay()
  overlay:setVignetteStrength(0.5)
  lurek.log.debug("vignette s=" .. overlay:getVignetteStrength(), "fx")
end

--@api-stub: Overlay:setFilmGrainEnabled
do -- Overlay:setFilmGrainEnabled
  local overlay = lurek.effect.newOverlay()
  overlay:setFilmGrainEnabled(true)
  overlay:setFilmGrainIntensity(0.25)
end

--@api-stub: Overlay:isFilmGrainEnabled
do -- Overlay:isFilmGrainEnabled
  local overlay = lurek.effect.newOverlay()
  if overlay:isFilmGrainEnabled() then
    lurek.log.debug("grain layer is live", "fx")
  end
end

--@api-stub: Overlay:setFilmGrainIntensity
do -- Overlay:setFilmGrainIntensity
  local overlay = lurek.effect.newOverlay()
  overlay:setFilmGrainEnabled(true)
  overlay:setFilmGrainIntensity(0.18)
end

--@api-stub: Overlay:getFilmGrainIntensity
do -- Overlay:getFilmGrainIntensity
  local overlay = lurek.effect.newOverlay()
  overlay:setFilmGrainIntensity(0.3)
  lurek.log.debug("grain i=" .. overlay:getFilmGrainIntensity(), "fx")
end

--@api-stub: Overlay:setCloudShadows
do -- Overlay:setCloudShadows
  local overlay = lurek.effect.newOverlay()
  overlay:setCloudShadows(true)
  overlay:setCloudCount(8)
end

--@api-stub: Overlay:isCloudShadowsEnabled
do -- Overlay:isCloudShadowsEnabled
  local overlay = lurek.effect.newOverlay()
  if overlay:isCloudShadowsEnabled() then
    overlay:setCloudOpacity(0.4)
  end
end

--@api-stub: Overlay:setCloudCount
do -- Overlay:setCloudCount
  local overlay = lurek.effect.newOverlay()
  overlay:setCloudShadows(true)
  overlay:setCloudCount(12)
end

--@api-stub: Overlay:getCloudCount
do -- Overlay:getCloudCount
  local overlay = lurek.effect.newOverlay()
  overlay:setCloudCount(6)
  lurek.log.debug("clouds=" .. overlay:getCloudCount(), "fx")
end

--@api-stub: Overlay:setCloudSpeed
do -- Overlay:setCloudSpeed
  local overlay = lurek.effect.newOverlay()
  overlay:setCloudShadows(true)
  overlay:setCloudSpeed(40.0)
end

--@api-stub: Overlay:getCloudSpeed
do -- Overlay:getCloudSpeed
  local overlay = lurek.effect.newOverlay()
  overlay:setCloudSpeed(25.0)
  lurek.log.debug("cloud px/s=" .. overlay:getCloudSpeed(), "fx")
end

--@api-stub: Overlay:setCloudScale
do -- Overlay:setCloudScale
  local overlay = lurek.effect.newOverlay()
  overlay:setCloudShadows(true)
  overlay:setCloudScale(1.5)
end

--@api-stub: Overlay:getCloudScale
do -- Overlay:getCloudScale
  local overlay = lurek.effect.newOverlay()
  overlay:setCloudScale(0.8)
  lurek.log.debug("cloud scale=" .. overlay:getCloudScale(), "fx")
end

--@api-stub: Overlay:setCloudOpacity
do -- Overlay:setCloudOpacity
  local overlay = lurek.effect.newOverlay()
  overlay:setCloudShadows(true)
  overlay:setCloudOpacity(0.35)
end

--@api-stub: Overlay:getCloudOpacity
do -- Overlay:getCloudOpacity
  local overlay = lurek.effect.newOverlay()
  overlay:setCloudOpacity(0.4)
  if overlay:getCloudOpacity() > 0.3 then
    lurek.log.info("overcast skies", "weather")
  end
end

--@api-stub: Overlay:setWeatherEnabled
do -- Overlay:setWeatherEnabled
  local overlay = lurek.effect.newOverlay()
  overlay:setWeather("rain")
  overlay:setWeatherEnabled(true)
end

--@api-stub: Overlay:isWeatherEnabled
do -- Overlay:isWeatherEnabled
  local overlay = lurek.effect.newOverlay()
  if overlay:isWeatherEnabled() then
    lurek.log.debug("weather active = " .. overlay:getWeather(), "weather")
  end
end

--@api-stub: Overlay:setWeather
do -- Overlay:setWeather
  local overlay = lurek.effect.newOverlay()
  overlay:setWeather("snow")
  overlay:setWeatherEnabled(true)
  overlay:setWeatherIntensity(0.7)
end

--@api-stub: Overlay:getWeather
do -- Overlay:getWeather
  local overlay = lurek.effect.newOverlay()
  overlay:setWeather("rain")
  lurek.log.info("current weather: " .. overlay:getWeather(), "weather")
end

--@api-stub: Overlay:setWeatherIntensity
do -- Overlay:setWeatherIntensity
  local overlay = lurek.effect.newOverlay()
  overlay:setWeather("rain")
  overlay:setWeatherIntensity(0.85)
end

--@api-stub: Overlay:getWeatherIntensity
do -- Overlay:getWeatherIntensity
  local overlay = lurek.effect.newOverlay()
  overlay:setWeatherIntensity(0.5)
  lurek.log.debug("weather i=" .. overlay:getWeatherIntensity(), "weather")
end

--@api-stub: Overlay:setWindDirection
do -- Overlay:setWindDirection
  local overlay = lurek.effect.newOverlay()
  overlay:setWindDirection(math.pi / 4)  -- down-right
  overlay:setWindSpeed(60.0)
end

--@api-stub: Overlay:getWindDirection
do -- Overlay:getWindDirection
  local overlay = lurek.effect.newOverlay()
  overlay:setWindDirection(math.pi)
  lurek.log.debug("wind dir rad=" .. overlay:getWindDirection(), "weather")
end

--@api-stub: Overlay:setWindSpeed
do -- Overlay:setWindSpeed
  local overlay = lurek.effect.newOverlay()
  overlay:setWindSpeed(120.0)
  overlay:setCloudSpeed(60.0)
end

--@api-stub: Overlay:getWindSpeed
do -- Overlay:getWindSpeed
  local overlay = lurek.effect.newOverlay()
  overlay:setWindSpeed(80.0)
  lurek.log.debug("wind=" .. overlay:getWindSpeed(), "weather")
end

--@api-stub: Overlay:getLightningColor
do -- Overlay:getLightningColor
  local overlay = lurek.effect.newOverlay()
  local r, g, b, a = overlay:getLightningColor()
  lurek.log.info(string.format("lightning rgba %.2f %.2f %.2f %.2f", r, g, b, a), "fx")
end

--@api-stub: Overlay:isFlashing
do -- Overlay:isFlashing
  local overlay = lurek.effect.newOverlay()
  overlay:flash(1, 0, 0, 1, 0.2)
  if overlay:isFlashing() then
    lurek.log.debug("ignoring input during damage flash", "input")
  end
end

--@api-stub: Overlay:shake
do -- Overlay:shake
  local overlay = lurek.effect.newOverlay()
  overlay:shake(12.0, 0.35)  -- explosion impact
  function lurek.process(dt) overlay:update(dt) end
end

--@api-stub: Overlay:isShaking
do -- Overlay:isShaking
  local overlay = lurek.effect.newOverlay()
  overlay:shake(6.0, 0.25)
  if overlay:isShaking() then
    lurek.log.debug("camera shaking", "fx")
  end
end

--@api-stub: Overlay:isFading
do -- Overlay:isFading
  local overlay = lurek.effect.newOverlay()
  overlay:fade(0, 0, 0, 1, 0.6)
  function lurek.process(dt)
    overlay:update(dt)
    if not overlay:isFading() then lurek.log.debug("fade done", "fx") end
  end
end

--@api-stub: Overlay:render
do -- Overlay:render
  local overlay = lurek.effect.newOverlay()
  function lurek.draw_ui()
    overlay:render()
  end
end

--@api-stub: Overlay:drawToImage
do -- Overlay:drawToImage
  local overlay = lurek.effect.newOverlay()
  overlay:flash(1, 1, 1, 1, 1.0)
  local img = overlay:drawToImage(640, 360)
  lurek.log.info("overlay snapshot taken", "fx")
end

--@api-stub: Overlay:setCustomShader
do -- Overlay:setCustomShader
  local overlay = lurek.effect.newOverlay()
  overlay:setCustomShader("shaders/post_grade.wgsl")
  -- overlay:setCustomShader(nil)  -- to revert later
end

--@api-stub: Overlay:getWater
do -- Overlay:getWater
  local overlay = lurek.effect.newOverlay()
  local w = overlay:getWater()
  lurek.log.info("water enabled=" .. tostring(w.enabled) .. " amp=" .. w.amplitude, "fx")
end

--@api-stub: Overlay:type
do -- Overlay:type
  local overlay = lurek.effect.newOverlay()
  lurek.log.info("Overlay:type = " .. overlay:type(), "fx")
end

--@api-stub: Overlay:typeOf
do -- Overlay:typeOf
  local overlay = lurek.effect.newOverlay()
  if overlay:typeOf("Object") then
    lurek.log.debug("overlay is an Object", "fx")
  end
end

-- â”€â”€ mlua methods â”€â”€

--@api-stub: mlua:play
do -- mlua:play
  local trans = lurek.effect.newTransition("fade", 0.6, {0, 0, 0, 1})
  trans:play()
  function lurek.process(dt) trans:update(dt) end
end

--@api-stub: mlua:reverse
do -- mlua:reverse
  local trans = lurek.effect.newTransition("iris", 0.5)
  trans:reverse()
  function lurek.process(dt) trans:update(dt) end
end

--@api-stub: mlua:update
do -- mlua:update
  local trans = lurek.effect.newTransition("dissolve", 0.8)
  trans:play()
  function lurek.process(dt)
    if not trans:update(dt) then lurek.log.debug("transition complete", "fx") end
  end
end

--@api-stub: mlua:progress
do -- mlua:progress
  local trans = lurek.effect.newTransition("wipe", 1.0)
  trans:play()
  function lurek.process(dt)
    trans:update(dt)
    lurek.log.debug(string.format("trans p=%.2f", trans:progress()), "fx")
  end
end

--@api-stub: mlua:isActive
do -- mlua:isActive
  local trans = lurek.effect.newTransition("fade", 0.5)
  trans:play()
  if trans:isActive() then
    lurek.log.debug("transition in progress â€” pausing input", "input")
  end
end

--@api-stub: mlua:isDone
do -- mlua:isDone
  local trans = lurek.effect.newTransition("fade", 0.4)
  trans:play()
  function lurek.process(dt)
    trans:update(dt)
    if trans:isDone() then lurek.log.info("ready for next scene", "scene") end
  end
end

--@api-stub: mlua:kind
do -- mlua:kind
  local trans = lurek.effect.newTransition("dissolve", 0.5)
  lurek.log.info("transition kind=" .. trans:kind(), "fx")
end

--@api-stub: mlua:color
do -- mlua:color
  local trans = lurek.effect.newTransition("fade", 0.5, {0.05, 0.0, 0.1, 1.0})
  local r, g, b, a = trans:color()
  lurek.log.info(string.format("trans color %.2f %.2f %.2f %.2f", r, g, b, a), "fx")
end

--@api-stub: mlua:setColor
do -- mlua:setColor
  local trans = lurek.effect.newTransition("fade", 0.5)
  trans:setColor({0.0, 0.0, 0.0, 1.0})  -- fade to black
end

--@api-stub: mlua:type
do -- mlua:type
  local trans = lurek.effect.newTransition("wipe", 0.5)
  lurek.log.info("ScreenTransition:type = " .. tostring(trans and trans:type() or "nil"), "fx")
end

--@api-stub: mlua:typeOf
do -- mlua:typeOf
  local trans = lurek.effect.newTransition("fade", 0.5)
  if trans:typeOf("Object") then
    lurek.log.debug("transition inherits Object", "fx")
  end
end


--     struct PostFxParams { p: array<vec4<f32>, 4>, }
--     @group(0) @binding(2) var<uniform> params: PostFxParams;

--     // p[3] auto-uniform layout when enableAutoUniforms() is active:
--     //   p[3].x = total elapsed time (seconds)
--     //   p[3].y = frame count (cast to f32)
--     //   p[3].z = render target width (pixels)
--     //   p[3].w = render target height (pixels)

--     @fragment
--     fn fs_main(
--         @location(0) color: vec4<f32>,
--         @location(1) uv: vec2<f32>
--     ) -> @location(0) vec4<f32> {
--         let time = params.p[3].x;
--         let wave = sin(uv.x * 20.0 + time * 3.0) * 0.005;
--         let distorted_uv = vec2<f32>(uv.x, uv.y + wave);
--         return textureSample(t_src, s_src, distorted_uv);
--     }
--   ]]

--   lurek.render.newShader(wgsl)
--   local shader_id = 1
--   local wave_effect = lurek.effect.newCustomEffect(shader_id)
--   wave_effect:enableAutoUniforms()
--   lurek.log.info("auto_uniforms=" .. tostring(wave_effect:isAutoUniforms()), "fx")

--   local stack = lurek.effect.newStack(1280, 720)
--   stack:add(wave_effect)

--   function lurek.draw()
--     stack:beginCapture()
    -- draw scene here
--     stack:endCapture()
--     stack:apply()
--   end
-- end

--@api-stub: PostFxEffect:enableAutoUniforms
do -- PostFxEffect:enableAutoUniforms
  local fx = lurek.effect.newCustomEffect(0)
  fx:enableAutoUniforms()
  lurek.log.debug("enableAutoUniforms called", "fx")
end

--@api-stub: PostFxEffect:isAutoUniforms
do -- PostFxEffect:isAutoUniforms
  local fx = lurek.effect.newCustomEffect(0)
  fx:enableAutoUniforms()
  lurek.log.debug("isAutoUniforms=" .. tostring(fx:isAutoUniforms()), "fx")
end

--@api-stub: PostFxEffect:disableAutoUniforms
do -- PostFxEffect:disableAutoUniforms
  local fx = lurek.effect.newCustomEffect(0)
  fx:enableAutoUniforms()
  fx:disableAutoUniforms()
  lurek.log.debug("auto_uniforms=" .. tostring(fx:isAutoUniforms()), "fx")
end

--@api-stub: Overlay:fade
do -- Overlay:fade
  local overlay = lurek.effect.newOverlay(800, 600)
  overlay:fade(0, 0, 0, 1.0, 1.0)
  lurek.log.info("fade started", "effect")
end

--@api-stub: Overlay:flash
do -- Overlay:flash
  local overlay = lurek.effect.newOverlay(800, 600)
  overlay:flash(0.15, 1, 1, 1, 1)
  lurek.log.info("flash triggered", "effect")
end

--@api-stub: PostFxEffect:getParameter
do -- PostFxEffect:getParameter
  local stack = lurek.effect.newStack(800, 600)
  stack:add(lurek.effect.newEffect("bloom"))
  local effect = assert(stack:getEffect(1))
  local intensity = effect:getParameter("intensity")
  lurek.log.info("bloom intensity: " .. tostring(intensity), "effect")
end

--@api-stub: PostFxStack:insert
do -- PostFxStack:insert
  local stack = lurek.effect.newStack(800, 600)
  stack:add(lurek.effect.newEffect("crt"))
  stack:insert(1, lurek.effect.newEffect("vignette"))
  lurek.log.info("stack count: " .. stack:getEffectCount(), "effect")
end

--@api-stub: Overlay:setAmbientColor
do -- Overlay:setAmbientColor
  local overlay = lurek.effect.newOverlay(800, 600)
  overlay:setAmbientEnabled(true)
  overlay:setAmbientColor(0.1, 0.1, 0.3, 0.6)
  lurek.log.info("ambient colour set", "effect")
end

--@api-stub: PostFxStack:setEnabled
do -- PostFxStack:setEnabled
  local stack = lurek.effect.newStack(800, 600)
  stack:add(lurek.effect.newEffect("bloom"))
  stack:setEnabled(1, false)
  lurek.log.info("stack enabled: " .. tostring(stack:isEnabled(1)), "effect")
end

--@api-stub: Overlay:setFogColor
do -- Overlay:setFogColor
  local overlay = lurek.effect.newOverlay(800, 600)
  overlay:setFogEnabled(true)
  overlay:setFogColor(0.6, 0.6, 0.7)
  lurek.log.info("fog colour set", "effect")
end

--@api-stub: Overlay:setLightningColor
do -- Overlay:setLightningColor
  local overlay = lurek.effect.newOverlay(800, 600)
  overlay:setLightningColor(0.9, 0.95, 1.0)
  lurek.log.info("lightning colour set", "effect")
end

--@api-stub: Overlay:setWater
do -- Overlay:setWater
  local overlay = lurek.effect.newOverlay(800, 600)
  overlay:setWater(0.02, 12.0, 1.5)
  lurek.log.info("water effect set", "effect")
end

--@api-stub: Overlay:setWaterTint
do -- Overlay:setWaterTint
  local overlay = lurek.effect.newOverlay(800, 600)
  overlay:setWater(0.02, 12.0, 1.5)
  overlay:setWaterTint(0.2, 0.6, 0.8, 0.5)
  lurek.log.info("water tint set", "effect")
end

--@api-stub: Overlay:triggerFade
do -- Overlay:triggerFade
  local overlay = lurek.effect.newOverlay(800, 600)
  overlay:triggerFade(0, 0, 0, 1.0, 1.5)
  lurek.log.info("fade out triggered", "effect")
end

--@api-stub: Overlay:triggerFlash
do -- Overlay:triggerFlash
  local overlay = lurek.effect.newOverlay(800, 600)
  overlay:triggerFlash(1.0, 0.0, 0.0, 0.8, 0.12)
  lurek.log.info("flash triggered", "effect")
end

--@api-stub: Overlay:triggerShake
do -- Overlay:triggerShake
  local overlay = lurek.effect.newOverlay(800, 600)
  overlay:triggerShake(8.0, 0.4)
  lurek.log.info("shake triggered", "effect")
end

-- =============================================================================
-- COVERAGE: 147 uncovered lurek.effect API item(s)
-- Generated by tools/audit/example_add_missing.py
-- REQUIRED: replace every --@api-stub: block below with a real scenario.
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- The final committed file must contain ZERO --@api-stub: lines.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- LScreenTransition methods
-- -----------------------------------------------------------------------------

--@api-stub: LScreenTransition:play -- Starts this screen transition forward from its current state
do -- LScreenTransition:play
  local tr = lurek.effect.newTransition("fade", 0.5, {0, 0, 0, 1})
  tr:play()
  lurek.log.info("transition playing, active=" .. tostring(tr:isActive()), "effect")
end
--@api-stub: LScreenTransition:reverse -- Starts this screen transition in reverse from its current state
do -- LScreenTransition:reverse
  local tr = lurek.effect.newTransition("fade", 0.5, {0, 0, 0, 1})
  tr:reverse()
  lurek.log.info("transition reversed, active=" .. tostring(tr:isActive()), "effect")
end
--@api-stub: LScreenTransition:update -- Advances this transition timer and returns whether it remains active
do -- LScreenTransition:update
  local tr = lurek.effect.newTransition("fade", 0.5, {0, 0, 0, 1})
  tr:play()
  local running = tr:update(0.1)
  lurek.log.info("still_active=" .. tostring(running), "effect")
end
--@api-stub: LScreenTransition:progress -- Returns normalized transition progress
do -- LScreenTransition:progress
  local tr = lurek.effect.newTransition("fade", 1.0, {0, 0, 0, 1})
  tr:play()
  tr:update(0.25)
  lurek.log.info("progress=" .. tr:progress(), "effect")
end
--@api-stub: LScreenTransition:isActive -- Returns whether the transition is currently active
do -- LScreenTransition:isActive
  local tr = lurek.effect.newTransition("wipe", 0.4, {0, 0, 0, 1})
  lurek.log.info("before play: " .. tostring(tr:isActive()), "effect")
  tr:play()
  lurek.log.info("after play: " .. tostring(tr:isActive()), "effect")
end
--@api-stub: LScreenTransition:isDone -- Returns whether the transition has finished
do -- LScreenTransition:isDone
  local tr = lurek.effect.newTransition("fade", 0.1, {0, 0, 0, 1})
  tr:play()
  while not tr:isDone() do
    tr:update(0.05)
  end
  lurek.log.info("transition is done", "effect")
end
--@api-stub: LScreenTransition:kind -- Returns the transition kind name
do -- LScreenTransition:kind
  local tr = lurek.effect.newTransition("iris_wipe", 0.5, {0, 0, 0, 1})
  lurek.log.info("kind=" .. tr:kind(), "effect")
end
--@api-stub: LScreenTransition:color -- Returns the transition RGBA color
do -- LScreenTransition:color
  local tr = lurek.effect.newTransition("fade", 0.5, {0.1, 0.2, 0.3, 1.0})
  local r, g, b, a = tr:color()
  lurek.log.info("color r=" .. r .. " g=" .. g .. " b=" .. b, "effect")
end
--@api-stub: LScreenTransition:setColor -- Sets the transition RGBA color from a numeric array table
do -- LScreenTransition:setColor
  local tr = lurek.effect.newTransition("fade", 0.5, {0, 0, 0, 1})
  tr:setColor({1.0, 1.0, 1.0, 1.0})   -- switch to white flash
  local r, g, b = tr:color()
  lurek.log.info("updated color r=" .. r .. " g=" .. g, "effect")
end
--@api-stub: LScreenTransition:type -- Returns the Lua-visible type name for this transition handle
do -- LScreenTransition:type
  local screen_transition_obj = lurek.effect.newTransition(nil, nil, nil)
  local t = screen_transition_obj:type()
  lurek.log.info("LScreenTransition:type = " .. t, "effect")
end
--@api-stub: LScreenTransition:typeOf -- Returns whether this transition handle matches a supported type name
do -- LScreenTransition:typeOf
  local screen_transition_obj = lurek.effect.newTransition(nil, nil, nil)
  lurek.log.info("is LScreenTransition: " .. tostring(screen_transition_obj:typeOf("LScreenTransition")), "effect")
  lurek.log.info("is wrong: " .. tostring(screen_transition_obj:typeOf("Unknown")), "effect")
end

--@api-stub: LOverlay:pullAmbientFromLight -- Copies ambient color from the shared light world into this overlay
do -- LOverlay:pullAmbientFromLight
  local overlay = lurek.effect.newOverlay()
  overlay:pullAmbientFromLight()
end

--@api-stub: LOverlay:pushAmbientToLight -- Copies this overlay ambient color into the shared light world
do -- LOverlay:pushAmbientToLight
  local overlay = lurek.effect.newOverlay()
  overlay:pushAmbientToLight()
end

--@api-stub: LOverlay:syncAmbientWithLight -- Resolves overlay and light ambient colors using a named mode and writes both stores
do -- LOverlay:syncAmbientWithLight
  local overlay = lurek.effect.newOverlay()
  overlay:syncAmbientWithLight("avg")
end
