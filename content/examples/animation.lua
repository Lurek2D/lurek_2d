-- content/examples/animation.lua
-- lurek.animation API examples.
-- Run: cargo run -- content/examples/animation.lua

--@api-stub: lurek.animation.new -- Creates an empty animation with no frames or clips
do -- lurek.animation.new
  local hero = lurek.animation.new()
  hero:addFrame(0, 0, 32, 32)
  hero:addFrame(32, 0, 32, 32)
  hero:addClip("idle", {0, 1}, 4, true)
  hero:play("idle")
end

--@api-stub: lurek.animation.fromAseprite -- Loads an animation from an Aseprite JSON export string
do -- lurek.animation.fromAseprite
  local json = '{"frames":[],"meta":{"size":{"w":32,"h":32},"frameTags":[]}}'
  local hero = lurek.animation.fromAseprite(json)
  hero:play("walk")
end

--@api-stub: lurek.animation.newStateMachine -- Creates an animation state machine by consuming an animation handle
do -- lurek.animation.newStateMachine
  local anim = lurek.animation.new()
  anim:addFrame(0, 0, 32, 32)
  anim:addClip("idle", {0}, 1, true)
  local fsm = lurek.animation.newStateMachine(anim, "idle")
  fsm:addState("idle", "idle", true)
end

--@api-stub: lurek.animation.newCurve -- Creates an empty animation curve
do -- lurek.animation.newCurve
  local zoom = lurek.animation.newCurve()
  zoom:addKeyframe(0.0, 1.0)
  zoom:addKeyframe(1.5, 2.0)
  local current = zoom:eval(0.75)
  lurek.log.info("camera zoom at t=0.75 -> " .. current, "anim")
end

--@api-stub: lurek.animation.newSyncGroup -- Creates an empty animation synchronization group
do -- lurek.animation.newSyncGroup
  local squad = lurek.animation.newSyncGroup()
  squad:add(1)
  squad:add(2)
  lurek.log.info("synced animations: " .. squad:memberCount(), "anim")
end

--@api-stub: lurek.animation.newBlendLayerSet -- Creates an empty blend layer set for layered animation playback
do -- lurek.animation.newBlendLayerSet
  local bls = lurek.animation.newBlendLayerSet()
  bls:addLayer("base", "run", 1.0)
  bls:addLayer("upper", "aim", 0.8, {"spine", "arm_r"})
end

-- â”€â”€ Animation methods â”€â”€

--@api-stub: Animation:addFrame
do -- Animation:addFrame
  local anim = lurek.animation.new()
  local idx = anim:addFrame(0, 0, 48, 64)
  anim:addFrame(48, 0, 48, 64)
  lurek.log.debug("added frame index=" .. idx, "anim")
end

--@api-stub: Animation:addFramesFromRects
do -- Animation:addFramesFromRects
  local anim = lurek.animation.new()
  local added = anim:addFramesFromRects({
    { x = 0, y = 0, w = 32, h = 32 },
    { x = 32, y = 0, w = 32, h = 32 },
  })
  lurek.log.debug("added rect frames=" .. tostring(added), "anim")
end

--@api-stub: Animation:play
do -- Animation:play
  local anim = lurek.animation.new()
  anim:addFrame(0, 0, 32, 32)
  anim:addClip("walk", {0}, 8, true)
  if not anim:play("walk") then
    lurek.log.warn("clip 'walk' not registered", "anim")
  end
end

--@api-stub: Animation:stop
do -- Animation:stop
  local anim = lurek.animation.new()
  anim:addFrame(0, 0, 32, 32)
  anim:addClip("walk", {0}, 8, true)
  anim:play("walk")
  anim:stop()
end

--@api-stub: Animation:pause
do -- Animation:pause
  local anim = lurek.animation.new()
  anim:addFrame(0, 0, 32, 32)
  anim:addClip("walk", {0}, 8, true)
  anim:play("walk")
  anim:pause()
end

--@api-stub: Animation:resume
do -- Animation:resume
  local anim = lurek.animation.new()
  anim:addFrame(0, 0, 32, 32)
  anim:addClip("walk", {0}, 8, true)
  anim:play("walk")
  anim:pause()
  anim:resume()
end

--@api-stub: Animation:update
do -- Animation:update
  local anim = lurek.animation.new()
  anim:addFrame(0, 0, 32, 32)
  anim:addClip("walk", {0}, 8, true)
  anim:play("walk")
  function lurek.process(dt) anim:update(dt) end
end

--@api-stub: Animation:getQuad
do -- Animation:getQuad
  local anim = lurek.animation.new()
  anim:addFrame(0, 0, 32, 32)
  anim:addClip("idle", {0}, 4, true)
  anim:play("idle")
  local q = anim:getQuad()
  if q then lurek.log.debug("frame quad w=" .. q.w .. " h=" .. q.h, "anim") end
end

--@api-stub: Animation:pollEvents
do -- Animation:pollEvents
  local anim = lurek.animation.new()
  anim:addFrame(0, 0, 32, 32)
  anim:addClip("attack", {0}, 8, false)
  anim:play("attack")
  function lurek.process(dt)
    anim:update(dt)
    for _, ev in ipairs(anim:pollEvents()) do
      if ev.type == "clip_finished" then lurek.log.info("attack done", "anim") end
    end
  end
end

--@api-stub: Animation:isPlaying
do -- Animation:isPlaying
  local anim = lurek.animation.new()
  anim:addFrame(0, 0, 32, 32)
  anim:addClip("swing", {0}, 6, false)
  anim:play("swing")
  if anim:isPlaying() then lurek.log.debug("swing in progress, ignoring input", "combat") end
end

--@api-stub: Animation:isLooping
do -- Animation:isLooping
  local anim = lurek.animation.new()
  anim:addFrame(0, 0, 32, 32)
  anim:addClip("idle", {0}, 2, true)
  anim:play("idle")
  if not anim:isLooping() then lurek.log.warn("idle clip should loop but does not", "anim") end
end

--@api-stub: Animation:getClip
do -- Animation:getClip
  local anim = lurek.animation.new()
  anim:addFrame(0, 0, 32, 32)
  anim:addClip("run", {0}, 12, true)
  anim:play("run")
  local clip = anim:getClip()
  if clip then lurek.log.debug("now playing: " .. clip, "anim") end
end

--@api-stub: Animation:getSpeed
do -- Animation:getSpeed
  local anim = lurek.animation.new()
  anim:addFrame(0, 0, 32, 32)
  anim:addClip("run", {0}, 12, true)
  local previous = anim:getSpeed()
  anim:setSpeed(previous * 0.5)
end

--@api-stub: Animation:setSpeed
do -- Animation:setSpeed
  local anim = lurek.animation.new()
  anim:addFrame(0, 0, 32, 32)
  anim:addClip("run", {0}, 12, true)
  anim:play("run")
  anim:setSpeed(2.0)
end

--@api-stub: Animation:getFrameCount
do -- Animation:getFrameCount
  local anim = lurek.animation.new()
  anim:addFrame(0, 0, 32, 32)
  anim:addFrame(32, 0, 32, 32)
  if anim:getFrameCount() ~= 2 then lurek.log.error("frame pool wrong size", "anim") end
end

--@api-stub: Animation:getClipCount
do -- Animation:getClipCount
  local anim = lurek.animation.new()
  anim:addFrame(0, 0, 32, 32)
  anim:addClip("idle", {0}, 4, true)
  lurek.log.info("clips registered: " .. anim:getClipCount(), "anim")
end

--@api-stub: Animation:getCurrentFrame
do -- Animation:getCurrentFrame
  local anim = lurek.animation.new()
  anim:addFrame(0, 0, 32, 32)
  anim:addClip("walk", {0}, 8, true)
  anim:play("walk")
  if anim:getCurrentFrame() == 3 then lurek.audio.play(lurek.audio.newSource("tests/rust/fixtures/sine_mono_44100.wav")) end
end

--@api-stub: Animation:setFrame
do -- Animation:setFrame
  local anim = lurek.animation.new()
  anim:addFrame(0, 0, 32, 32)
  anim:addClip("walk", {0}, 8, true)
  anim:play("walk")
  anim:setFrame(0)
end

--@api-stub: Animation:getBlendState
do -- Animation:getBlendState
  local anim = lurek.animation.new()
  anim:addFrame(0, 0, 32, 32)
  anim:addClip("idle", {0}, 4, true)
  anim:play("idle")
  local bs = anim:getBlendState()
  if bs then lurek.log.debug("crossfade blend=" .. bs.blend, "anim") end
end

--@api-stub: Animation:drawToImage
do -- Animation:drawToImage
  pcall(function()
    local anim = lurek.animation.new()
    anim:addFrame(0, 0, 32, 32)
    anim:addClip("idle", {0}, 4, true)
    anim:play("idle")
    local thumb = anim:drawToImage(64, 64)
    lurek.image.savePNG(thumb, "save/anim_thumb.png")
  end)
end

-- â”€â”€ AnimStateMachine methods â”€â”€

--@api-stub: AnimStateMachine:update
do -- AnimStateMachine:update
  local anim = lurek.animation.new()
  anim:addFrame(0, 0, 32, 32); anim:addClip("idle", {0}, 4, true)
  local fsm = lurek.animation.newStateMachine(anim, "idle")
  fsm:addState("idle", "idle", true)
  function lurek.process(dt) fsm:update(dt) end
end

--@api-stub: AnimStateMachine:getState
do -- AnimStateMachine:getState
  local anim = lurek.animation.new()
  anim:addFrame(0, 0, 32, 32); anim:addClip("idle", {0}, 4, true)
  local fsm = lurek.animation.newStateMachine(anim, "idle")
  fsm:addState("idle", "idle", true)
  if fsm:getState() ~= "idle" then lurek.log.warn("unexpected initial state", "anim") end
end

--@api-stub: AnimStateMachine:forceState
do -- AnimStateMachine:forceState
  local anim = lurek.animation.new()
  anim:addFrame(0, 0, 32, 32); anim:addClip("idle", {0}, 4, true); anim:addClip("dead", {0}, 1, false)
  local fsm = lurek.animation.newStateMachine(anim, "idle")
  fsm:addState("idle", "idle", true); fsm:addState("dead", "dead", false)
  if not fsm:forceState("dead") then lurek.log.error("dead state missing", "anim") end
end

--@api-stub: AnimStateMachine:setParam
do -- AnimStateMachine:setParam
  local anim = lurek.animation.new()
  anim:addFrame(0, 0, 32, 32); anim:addClip("idle", {0}, 4, true); anim:addClip("run", {0}, 8, true)
  local fsm = lurek.animation.newStateMachine(anim, "idle")
  fsm:addState("idle", "idle", true); fsm:addState("run", "run", true)
  fsm:addTransition("idle", "run", "speed > 0.5")
  function lurek.process(dt) fsm:setParam("speed", 1.2); fsm:update(dt) end
end

--@api-stub: AnimStateMachine:getQuad
do -- AnimStateMachine:getQuad
  local anim = lurek.animation.new()
  anim:addFrame(0, 0, 32, 32); anim:addClip("idle", {0}, 4, true)
  local fsm = lurek.animation.newStateMachine(anim, "idle")
  fsm:addState("idle", "idle", true)
  function lurek.draw() local q = fsm:getQuad(); if q then lurek.log.debug("fsm quad w=" .. q.w, "anim") end end
end

-- â”€â”€ BlendLayerSet methods â”€â”€

--@api-stub: BlendLayerSet:removeLayer
do -- BlendLayerSet:removeLayer
  local bls = lurek.animation.newBlendLayerSet()
  bls:addLayer("base", "idle", 1.0)
  bls:addLayer("upper", "aim", 0.5, {"spine"})
  bls:removeLayer("upper")
end

--@api-stub: BlendLayerSet:setWeight
do -- BlendLayerSet:setWeight
  local bls = lurek.animation.newBlendLayerSet()
  bls:addLayer("base", "idle", 1.0)
  bls:addLayer("aim", "aim", 0.0, {"spine", "arm_r"})
  local aim_strength = 0.7
  bls:setWeight("aim", aim_strength)
end

--@api-stub: BlendLayerSet:getWeight
do -- BlendLayerSet:getWeight
  local bls = lurek.animation.newBlendLayerSet()
  bls:addLayer("aim", "aim", 0.5, {"spine"})
  local w = bls:getWeight("aim")
  if w and w > 0.5 then lurek.log.debug("aim layer dominant", "anim") end
end

--@api-stub: BlendLayerSet:setMask
do -- BlendLayerSet:setMask
  local bls = lurek.animation.newBlendLayerSet()
  bls:addLayer("aim", "aim_pistol", 1.0, {"arm_r"})
  bls:setMask("aim", {"spine", "arm_l", "arm_r"})
end

--@api-stub: BlendLayerSet:listLayers
do -- BlendLayerSet:listLayers
  local bls = lurek.animation.newBlendLayerSet()
  bls:addLayer("base", "idle", 1.0)
  bls:addLayer("aim", "aim", 0.6, {"arm_r"})
  for _, layer in ipairs(bls:listLayers()) do
    lurek.log.debug(layer.name .. " weight=" .. layer.weight, "anim")
  end
end

--@api-stub: BlendLayerSet:len
do -- BlendLayerSet:len
  local bls = lurek.animation.newBlendLayerSet()
  bls:addLayer("base", "idle", 1.0)
  if bls:len() == 0 then lurek.log.warn("blend set has no layers", "anim") end
end

-- â”€â”€ AnimCurve methods â”€â”€

--@api-stub: AnimCurve:addKeyframe
do -- AnimCurve:addKeyframe
  local fade = lurek.animation.newCurve()
  fade:addKeyframe(0.0, 0.0)
  fade:addKeyframe(0.5, 1.0)
  fade:addKeyframe(1.0, 0.0)
end

--@api-stub: AnimCurve:eval
do -- AnimCurve:eval
  local fade = lurek.animation.newCurve()
  fade:addKeyframe(0.0, 0.0); fade:addKeyframe(1.0, 1.0)
  local alpha = fade:eval(0.25)
  function lurek.draw() lurek.render.setColor(1, 1, 1, alpha) end
end

--@api-stub: AnimCurve:setEasing
do -- AnimCurve:setEasing
  local curve = lurek.animation.newCurve()
  curve:addKeyframe(0.0, 0.0); curve:addKeyframe(1.0, 1.0)
  curve:setEasing("ease_in_out")
end

--@api-stub: AnimCurve:keyframeCount
do -- AnimCurve:keyframeCount
  local curve = lurek.animation.newCurve()
  curve:addKeyframe(0.0, 0.0)
  if curve:keyframeCount() < 2 then lurek.log.warn("curve needs at least two keyframes", "anim") end
end

--@api-stub: AnimCurve:clear
do -- AnimCurve:clear
  local curve = lurek.animation.newCurve()
  curve:addKeyframe(0.0, 0.5); curve:addKeyframe(1.0, 1.0)
  curve:clear()
end

-- â”€â”€ AnimSyncGroup methods â”€â”€

--@api-stub: AnimSyncGroup:add
do -- AnimSyncGroup:add
  local squad = lurek.animation.newSyncGroup()
  squad:add(1)
  squad:add(2)
  squad:add(3)
end

--@api-stub: AnimSyncGroup:remove
do -- AnimSyncGroup:remove
  local squad = lurek.animation.newSyncGroup()
  squad:add(1); squad:add(2)
  squad:remove(1)
end

--@api-stub: AnimSyncGroup:clear
do -- AnimSyncGroup:clear
  local squad = lurek.animation.newSyncGroup()
  squad:add(1); squad:add(2); squad:add(3)
  squad:clear()
end

--@api-stub: AnimSyncGroup:memberCount
do -- AnimSyncGroup:memberCount
  local squad = lurek.animation.newSyncGroup()
  squad:add(1); squad:add(2)
  if squad:memberCount() > 0 then lurek.log.info("squad alive: " .. squad:memberCount(), "anim") end
end

--@api-stub: AnimCurve:setCustomEasing
do -- AnimCurve:setCustomEasing
  if lurek.animation.newCurve then
    local c = lurek.animation.newCurve()
    c:setCustomEasing(function(t)
      -- Smoothstep
      return t * t * (3 - 2 * t)
    end)
    lurek.log.debug("custom easing attached", "anim")
  end
end

--@api-stub: Animation:addClip
do -- Animation:addClip
  local anim = lurek.animation.new()
  anim:addFrame(0, 0, 32, 32)
  anim:addFrame(32, 0, 32, 32)
  anim:addClip("walk", {0, 1}, 8, true)
  anim:play("walk")
  lurek.log.info("clip count: " .. anim:getClipCount(), "anim")
end

--@api-stub: Animation:addClipFromGrid
do -- Animation:addClipFromGrid
  local anim = lurek.animation.new()
  anim:addFramesFromGrid(128, 128, 32, 32, 0, 16)
  anim:addClipFromGrid("run", 128, 128, 32, 32, 0, 4, 8, true)
  anim:play("run")
  lurek.log.info("clip from grid added", "anim")
end

--@api-stub: Animation:addFramesFromGrid
do -- Animation:addFramesFromGrid
  local anim = lurek.animation.new()
  local n = anim:addFramesFromGrid(64, 64, 32, 32, 0, 8)
  lurek.log.info("frames added: " .. n, "anim")
end

--@api-stub: BlendLayerSet:addLayer
do -- BlendLayerSet:addLayer
  local anim = lurek.animation.new()
  anim:addFrame(0, 0, 64, 64)
  anim:addClip("run", {0}, 8, true)
  local bls = lurek.animation.newBlendLayerSet()
  bls:addLayer("base", "run", 1.0)
  bls:addLayer("aim", "aim", 0.9, {"spine", "arm_r"})
  lurek.log.info("layers: " .. bls:len(), "anim")
end

--@api-stub: AnimStateMachine:addState
do -- AnimStateMachine:addState
  local anim = lurek.animation.new()
  anim:addFrame(0, 0, 32, 32)
  anim:addClip("idle", {0}, 1, true)
  anim:addClip("run", {0}, 8, true)
  local fsm = lurek.animation.newStateMachine(anim, "idle")
  fsm:addState("idle", "idle", true)
  fsm:addState("run", "run", true)
  lurek.log.info("state machine ready", "anim")
end

--@api-stub: AnimStateMachine:addTransition
do -- AnimStateMachine:addTransition
  local anim = lurek.animation.new()
  anim:addFrame(0, 0, 32, 32)
  anim:addClip("idle", {0}, 1, true)
  anim:addClip("run", {0}, 8, true)
  local fsm = lurek.animation.newStateMachine(anim, "idle")
  fsm:addState("idle", "idle", true)
  fsm:addState("run", "run", true)
  fsm:addTransition("idle", "run", "speed > 0")
  lurek.log.info("transition added", "anim")
end

--@api-stub: Animation:crossfade
do -- Animation:crossfade
  local anim = lurek.animation.new()
  anim:addFrame(0, 0, 32, 32)
  anim:addClip("idle", {0}, 4, true)
  anim:addClip("run", {0}, 8, true)
  anim:play("idle")
  anim:crossfade("run", 0.2)
  lurek.log.info("crossfade started", "anim")
end

-- =============================================================================
-- COVERAGE: 10 uncovered lurek.animation API item(s)
-- Generated by tools/audit/example_add_missing.py
-- REQUIRED: replace every --@api-stub: block below with a real scenario.
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- The final committed file must contain ZERO --@api-stub: lines.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- BlendLayerSet methods
-- -----------------------------------------------------------------------------

-- =============================================================================
-- COVERAGE: 10 uncovered lurek.animation API item(s)
-- Generated by tools/audit/example_add_missing.py
-- REQUIRED: replace every --@api-stub: block below with a real scenario.
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- The final committed file must contain ZERO --@api-stub: lines.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- LAnimCurve methods
-- -----------------------------------------------------------------------------

--@api-stub: LAnimCurve:type -- Returns the Lua-visible type name for this animation curve handle
do -- LAnimCurve:type
  local anim_curve_obj = lurek.animation.newCurve()
  local t = anim_curve_obj:type()
  lurek.log.info("LAnimCurve:type = " .. t, "animation")
end
--@api-stub: LAnimCurve:typeOf -- Returns whether this animation curve handle matches a supported type name
do -- LAnimCurve:typeOf
  local anim_curve_obj = lurek.animation.newCurve()
  lurek.log.info("is LAnimCurve: " .. tostring(anim_curve_obj:typeOf("LAnimCurve")), "animation")
  lurek.log.info("is wrong: " .. tostring(anim_curve_obj:typeOf("Unknown")), "animation")
end
--@api-stub: LAnimStateMachine:type -- Returns the Lua-visible type name for this animation state machine handle
do -- LAnimStateMachine:type
  local anim_state_machine_obj = lurek.animation.newStateMachine(lurek.animation.new(), "idle")
  local t = anim_state_machine_obj:type()
  lurek.log.info("LAnimStateMachine:type = " .. t, "animation")
end
--@api-stub: LAnimStateMachine:typeOf -- Returns whether this animation state machine handle matches a supported type name
do -- LAnimStateMachine:typeOf
  local anim_state_machine_obj = lurek.animation.newStateMachine(lurek.animation.new(), "idle")
  lurek.log.info("is LAnimStateMachine: " .. tostring(anim_state_machine_obj:typeOf("LAnimStateMachine")), "animation")
  lurek.log.info("is wrong: " .. tostring(anim_state_machine_obj:typeOf("Unknown")), "animation")
end
--@api-stub: LAnimSyncGroup:type -- Returns the Lua-visible type name for this animation sync group handle
do -- LAnimSyncGroup:type
  local anim_sync_group_obj = lurek.animation.newSyncGroup()
  local t = anim_sync_group_obj:type()
  lurek.log.info("LAnimSyncGroup:type = " .. t, "animation")
end
--@api-stub: LAnimSyncGroup:typeOf -- Returns whether this animation sync group handle matches a supported type name
do -- LAnimSyncGroup:typeOf
  local anim_sync_group_obj = lurek.animation.newSyncGroup()
  lurek.log.info("is LAnimSyncGroup: " .. tostring(anim_sync_group_obj:typeOf("LAnimSyncGroup")), "animation")
  lurek.log.info("is wrong: " .. tostring(anim_sync_group_obj:typeOf("Unknown")), "animation")
end
--@api-stub: LAnimation:type -- Returns the Lua-visible type name for this animation handle
do -- LAnimation:type
  local animation_obj = lurek.animation.new()
  local t = animation_obj:type()
  lurek.log.info("LAnimation:type = " .. t, "animation")
end
--@api-stub: LAnimation:typeOf -- Returns whether this animation handle matches a supported type name
do -- LAnimation:typeOf
  local animation_obj = lurek.animation.new()
  lurek.log.info("is LAnimation: " .. tostring(animation_obj:typeOf("LAnimation")), "animation")
  lurek.log.info("is wrong: " .. tostring(animation_obj:typeOf("Unknown")), "animation")
end
--@api-stub: LBlendLayerSet:type -- Returns the Lua-visible type name for this blend layer set handle
do -- LBlendLayerSet:type
  local blend_layer_set_obj = lurek.animation.newBlendLayerSet()
  local t = blend_layer_set_obj:type()
  lurek.log.info("LBlendLayerSet:type = " .. t, "animation")
end
--@api-stub: LBlendLayerSet:typeOf -- Returns whether this blend layer set handle matches a supported type name
do -- LBlendLayerSet:typeOf
  local blend_layer_set_obj = lurek.animation.newBlendLayerSet()
  lurek.log.info("is LBlendLayerSet: " .. tostring(blend_layer_set_obj:typeOf("LBlendLayerSet")), "animation")
  lurek.log.info("is wrong: " .. tostring(blend_layer_set_obj:typeOf("Unknown")), "animation")
end

do
  local anim = lurek.animation.new()
  anim:addFrame(0, 0, 16, 16)
  anim:addFrame(16, 0, 16, 16)
  anim:addClip("walk", {0, 1}, 8, true, "pingpong")
  lurek.log.info("walk mode: " .. tostring(anim:getClipMode("walk")), "anim")
end

do
  local anim = lurek.animation.new()
  anim:addFrame(0, 0, 16, 16)
  anim:addClip("idle", {0}, 4, true)
  anim:setClipMode("idle", "reverse")
  lurek.log.info("idle mode: " .. tostring(anim:getClipMode("idle")), "anim")
end

do
  local anim = lurek.animation.new()
  anim:addFramesFromGrid(64, 32, 16, 16, 0, 8)
  local img = anim:drawPreviewGrid(4, 20)
  lurek.log.info("preview image userdata: " .. tostring(img), "anim")
end

do
  local bundle = lurek.animation.buildCharacter({
    texW = 64,
    texH = 32,
    frameW = 16,
    frameH = 16,
    clips = {
      { name = "idle", start = 0, count = 2, fps = 4, looping = true, mode = "forward" },
      { name = "run", start = 2, count = 2, fps = 10, looping = true, mode = "pingpong" },
    },
    states = {
      { name = "idle", clip = "idle", looping = true },
      { name = "run", clip = "run", looping = true },
    },
    transitions = {
      { from = "idle", to = "run", condition = "speed > 0.5" },
    },
    initialState = "idle",
  })
  if bundle and bundle.animation then
    lurek.log.info("character bundle clips: " .. tostring(bundle.animation:getClipCount()), "anim")
  end
end

