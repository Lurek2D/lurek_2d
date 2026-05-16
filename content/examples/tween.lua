-- content/examples/tween.lua
-- lurek.tween API examples.
-- Run: cargo run -- content/examples/tween.lua

--@api-stub: lurek.tween.update -- Advances all active tweens, sequences, parallels, and springs by the given delta time
do -- lurek.tween.update
  function lurek.process(dt)
    lurek.tween.update(dt)
  end
end

--@api-stub: lurek.tween.tween -- Creates and starts a property tween that smoothly interpolates numeric fields on the target table over the given duration
do -- lurek.tween.tween
  local hud = { alpha = 0, y = -32 }
  lurek.tween.tween(0.4, hud, { alpha = 1, y = 0 }, "outQuad")
end

--@api-stub: lurek.tween.sequence -- Creates a new empty tween sequence
do -- lurek.tween.sequence
  local door = { y = 0 }
  lurek.tween.sequence()
    :tween(0.5, door, { y = 64 }, "outQuad")
    :delay(0.25)
    :start()
end

--@api-stub: lurek.tween.parallel -- Creates a new empty parallel tween group
do -- lurek.tween.parallel
  local actor = { x = 0, alpha = 1 }
  lurek.tween.parallel()
    :tween(0.6, actor, { x = 200 }, "inOutQuad")
    :tween(0.6, actor, { alpha = 0 }, "linear")
    :start()
end

--@api-stub: lurek.tween.delay -- Creates a one-shot delay
do -- lurek.tween.delay
  lurek.tween.delay(1.5, function()
    lurek.log.info("respawn now", "spawn")
  end)
end

--@api-stub: lurek.tween.cancelAll -- Immediately cancels all active tweens, sequences, parallels, and springs managed by the tween engine
do -- lurek.tween.cancelAll
  lurek.tween.cancelAll()
end

--@api-stub: lurek.tween.getActiveCount -- Returns the total number of currently active tweens, sequences, and parallels
do -- lurek.tween.getActiveCount
  local n = lurek.tween.getActiveCount()
  if n > 100 then
    lurek.log.warn("tween budget exceeded: " .. n, "tween")
  end
end

--@api-stub: lurek.tween.registerEasing -- Registers a custom easing function by name
do -- lurek.tween.registerEasing
  lurek.tween.registerEasing("squared", function(t)
    return t * t
  end)
end

--@api-stub: lurek.tween.getEasingNames -- Returns an array of all available easing function names, including both built-in and custom-registered easings
do -- lurek.tween.getEasingNames
  local names = lurek.tween.getEasingNames()
  for i = 1, #names do
    lurek.log.debug("easing[" .. i .. "]=" .. names[i], "tween")
  end
end

--@api-stub: lurek.tween.newState -- Creates a standalone tween state for manual interpolation
do -- lurek.tween.newState
  local s = lurek.tween.newState(0.5, "outCubic")
  s:tick(1 / 60)
  local x = s:lerp(0, 100)
  lurek.log.debug("hand-eased x=" .. x, "tween")
end

--@api-stub: lurek.tween.to -- Creates and starts a property tween with a different parameter order: target first, then fields, duration, easing
do -- lurek.tween.to
  local enemy = { hp = 100 }
  lurek.tween.to(enemy, { hp = 0 }, 0.8, "inQuad")
end

--@api-stub: lurek.tween.spring -- Creates a spring-physics animation that smoothly drives table fields toward target values with bounce and settle behavior
do -- lurek.tween.spring
  local cam = { x = 0, y = 0 }
  lurek.tween.spring(cam, { x = 320, y = 180 }, { stiffness = 180, damping = 18 })
end

--@api-stub: lurek.tween.tweenChain -- Creates a sequence from a table of step descriptors
do -- lurek.tween.tweenChain
  local actor = { x = 0 }
  lurek.tween["tweenChain"]({
    { duration = 0.2, target = actor, fields = { x = 32 }, easing = "linear" },
    { delay = 0.1 },
    { duration = 0.2, target = actor, fields = { x = 64 }, easing = "linear" },
  })
end

--@api-stub: lurek.tween.tweenColor -- Creates and starts a color tween that smoothly interpolates r, g, b, and/or a fields on the target table
do -- lurek.tween.tweenColor
  local c = { r = 1, g = 1, b = 1, a = 1 }
  lurek.tween["tweenColor"](0.4, c, { r = 1, g = 0.2, b = 0.2, a = 0.8 }, "linear")
end


-- â”€â”€ TweenState methods â”€â”€

--@api-stub: TweenState:tick
do -- TweenState:tick
  local s = lurek.tween.newState(1.0)
  function lurek.process(dt) s:tick(dt) end
end

--@api-stub: TweenState:isComplete
do -- TweenState:isComplete
  local s = lurek.tween.newState(0.5)
  s:tick(0.5)
  if s:isComplete() then
    lurek.log.info("ease finished", "tween")
  end
end

--@api-stub: TweenState:t
do -- TweenState:t
  local s = lurek.tween.newState(0.5)
  s:tick(0.25)
  local raw = s:t()
  lurek.log.debug("raw t=" .. raw, "tween")
end

--@api-stub: TweenState:lerp
do -- TweenState:lerp
  local s = lurek.tween.newState(0.5, "outQuad")
  s:tick(0.25)
  local x = s:lerp(0, 320)
  local y = s:lerp(180, 0)
  lurek.log.debug("ease x=" .. x .. " y=" .. y, "tween")
end

--@api-stub: TweenState:reset
do -- TweenState:reset
  local s = lurek.tween.newState(0.5)
  s:tick(0.5)
  s:reset()
end


-- â”€â”€ Tween methods â”€â”€

--@api-stub: Tween:pause
do -- Tween:pause
  local card = { y = 0 }
  local tw = lurek.tween.tween(0.6, card, { y = 200 })
  tw:pause()
end

--@api-stub: Tween:resume
do -- Tween:resume
  local card = { y = 0 }
  local tw = lurek.tween.tween(0.6, card, { y = 200 })
  tw:pause()
  tw:resume()
end

--@api-stub: Tween:isActive
do -- Tween:isActive
  local card = { y = 0 }
  local tw = lurek.tween.tween(0.6, card, { y = 200 })
  if tw:isActive() then
    lurek.log.debug("card moving", "ui")
  end
end

--@api-stub: Tween:getProgress
do -- Tween:getProgress
  local bar = { fill = 0 }
  local tw = lurek.tween.tween(2.0, bar, { fill = 1 })
  local p = tw:getProgress()
  lurek.log.debug("loading=" .. p, "ui")
end

--@api-stub: Tween:getElapsed
do -- Tween:getElapsed
  local obj = { x = 0 }
  local tw = lurek.tween.tween(1.0, obj, { x = 10 })
  lurek.tween.update(0.25)
  lurek.log.debug("elapsed=" .. tw["getElapsed"](tw), "tween")
end

--@api-stub: Tween:getDuration
do -- Tween:getDuration
  local obj = { x = 0 }
  local tw = lurek.tween.tween(1.0, obj, { x = 10 })
  lurek.log.debug("duration=" .. tw:getDuration(), "tween")
end

--@api-stub: Tween:getRemaining
do -- Tween:getRemaining
  local obj = { x = 0 }
  local tw = lurek.tween.tween(1.0, obj, { x = 10 })
  lurek.tween.update(0.25)
  lurek.log.debug("remaining=" .. tw["getRemaining"](tw), "tween")
end

--@api-stub: Tween:getFields
do -- Tween:getFields
  local obj = { x = 0, y = 0 }
  local tw = lurek.tween.tween(1.0, obj, { x = 10, y = 20 })
  local fields = tw["getFields"](tw)
  lurek.log.debug("fields=" .. tostring(#fields), "tween")
end

--@api-stub: Tween:setRelative
do -- Tween:setRelative
  local obj = { x = 10 }
  local tw = lurek.tween.tween(1.0, obj, { x = 5 }, "linear")
  tw["setRelative"](tw, true)
end

--@api-stub: Tween:relative
do -- Tween:relative
  local obj = { x = 10 }
  local tw = lurek.tween.tween(1.0, obj, { x = 5 }, "linear")
  tw["relative"](tw, true)
end

--@api-stub: Tween:await
do -- Tween:await
  local obj = { x = 0 }
  local tw = lurek.tween.tween(0.2, obj, { x = 1 }, "linear")
  local co = coroutine.create(function()
    tw["await"](tw)
    lurek.log.debug("await complete", "tween")
  end)
  coroutine.resume(co)
end

--@api-stub: Tween:setRepeat
do -- Tween:setRepeat
  local glow = { alpha = 0.3 }
  local tw = lurek.tween.tween(0.8, glow, { alpha = 1.0 })
  tw:setRepeat(-1)
end

--@api-stub: Tween:setYoyo
do -- Tween:setYoyo
  local glow = { alpha = 0.3 }
  local tw = lurek.tween.tween(0.8, glow, { alpha = 1.0 })
  tw:setRepeat(-1)
  tw:setYoyo(true)
end


-- â”€â”€ TweenSequence methods â”€â”€

--@api-stub: TweenSequence:cancel
do -- TweenSequence:cancel
  local door = { y = 0 }
  local seq = lurek.tween.sequence():tween(0.4, door, { y = 64 }):start()
  seq:cancel()
end

--@api-stub: TweenSequence:isActive
do -- TweenSequence:isActive
  local door = { y = 0 }
  local seq = lurek.tween.sequence():tween(0.4, door, { y = 64 }):start()
  if seq:isActive() then
    lurek.log.debug("door opening", "scene")
  end
end

--@api-stub: TweenSequence:getProgress
do -- TweenSequence:getProgress
  local door = { y = 0 }
  local seq = lurek.tween.sequence():tween(0.4, door, { y = 64 }):start()
  lurek.log.debug("seq progress=" .. seq["getProgress"](seq), "scene")
end

--@api-stub: TweenSequence:await
do -- TweenSequence:await
  local door = { y = 0 }
  local seq = lurek.tween.sequence():tween(0.2, door, { y = 64 }):start()
  local co = coroutine.create(function()
    seq["await"](seq)
    lurek.log.debug("sequence done", "scene")
  end)
  coroutine.resume(co)
end


-- â”€â”€ TweenParallel methods â”€â”€

--@api-stub: TweenParallel:cancel
do -- TweenParallel:cancel
  local actor = { x = 0, alpha = 1 }
  local par = lurek.tween.parallel()
    :tween(0.6, actor, { x = 200 })
    :tween(0.6, actor, { alpha = 0 })
    :start()
  par:cancel()
end

--@api-stub: TweenParallel:isActive
do -- TweenParallel:isActive
  local actor = { x = 0, alpha = 1 }
  local par = lurek.tween.parallel()
    :tween(0.6, actor, { x = 200 })
    :tween(0.6, actor, { alpha = 0 })
    :start()
  if par:isActive() then
    lurek.log.debug("actor exiting", "scene")
  end
end


-- â”€â”€ Spring methods â”€â”€

--@api-stub: Spring:update
do -- Spring:update
  local cam = { x = 0 }
  local sp = lurek.tween.spring(cam, { x = 320 })
  function lurek.process(dt) sp:update(dt) end
end

--@api-stub: Spring:isSettled
do -- Spring:isSettled
  local cam = { x = 0 }
  local sp = lurek.tween.spring(cam, { x = 320 })
  if sp:isSettled() then
    lurek.log.debug("camera at rest", "camera")
  end
end

--@api-stub: Spring:isActive
do -- Spring:isActive
  local cam = { x = 0 }
  local sp = lurek.tween.spring(cam, { x = 320 })
  if sp:isActive() then
    lurek.log.debug("camera following", "camera")
  end
end

--@api-stub: Spring:setTarget
do -- Spring:setTarget
  local cam = { x = 0, y = 0 }
  local sp = lurek.tween.spring(cam, { x = 320, y = 180 })
  sp:setTarget({ x = 480, y = 240 })
end

--@api-stub: Spring:setStiffness
do -- Spring:setStiffness
  local cam = { x = 0 }
  local sp = lurek.tween.spring(cam, { x = 320 })
  sp:setStiffness(240)
end

--@api-stub: Spring:setDamping
do -- Spring:setDamping
  local cam = { x = 0 }
  local sp = lurek.tween.spring(cam, { x = 320 })
  sp:setDamping(24)
end

--@api-stub: Spring:cancel
do -- Spring:cancel
  local cam = { x = 0 }
  local sp = lurek.tween.spring(cam, { x = 320 })
  sp:cancel()
end

--@api-stub: Spring:getPosition
do -- Spring:getPosition
  local cam = { x = 0 }
  local sp = lurek.tween.spring(cam, { x = 320 })
  local px = sp:getPosition("x")
  if px then
    lurek.log.debug("spring x=" .. px, "camera")
  end
end

--@api-stub: Spring:type
do -- Spring:type
  local cam = { x = 0 }
  local sp = lurek.tween.spring(cam, { x = 320 })
  lurek.log.debug("spring type: " .. sp:type(), "tween")
end

--@api-stub: Spring:typeOf
do -- Spring:typeOf
  local cam = { x = 0 }
  local sp = lurek.tween.spring(cam, { x = 320 })
  lurek.log.info("is Spring: " .. tostring(sp:typeOf("Spring")), "tween")
end

-- -----------------------------------------------------------------------------
-- Tween methods
-- -----------------------------------------------------------------------------

--@api-stub: Tween:onComplete
do -- Tween:onComplete
  local box = { x = 0 }
  -- onComplete registers a callback; tween auto-starts via lurek.tween.tween.
  lurek.tween.tween(0.5, box, { x = 100 }):onComplete(function()
    lurek.log.debug("done", "tween")
  end)
end

--@api-stub: Tween:onUpdate
do -- Tween:onUpdate
  local box = { x = 0 }
  lurek.tween.tween(0.5, box, { x = 100 }):onUpdate(function(t)
    lurek.log.debug("t=" .. t, "tween")
  end)
end

--@api-stub: Tween:onCancel
do -- Tween:onCancel
  local box = { x = 0 }
  local tw = lurek.tween.tween(0.5, box, { x = 100 })
  tw:onCancel(function() lurek.log.debug("cancelled", "tween") end)
  tw:cancel()
end

--@api-stub: Tween:type
do -- Tween:type
  local box = { x = 0 }
  local tw = lurek.tween.tween(0.5, box, { x = 100 })
  lurek.log.info("Tween:type = " .. tostring(tw and tw:type() or "nil"), "tween")
end

--@api-stub: Tween:typeOf
do -- Tween:typeOf
  local box = { x = 0 }
  local tw = lurek.tween.tween(0.5, box, { x = 100 })
  lurek.log.info("Tween:typeOf = " .. tostring(tw and tw:typeOf("Tween") or false), "tween")
end

-- -----------------------------------------------------------------------------
-- TweenParallel methods
-- -----------------------------------------------------------------------------

--@api-stub: TweenParallel:add
do -- TweenParallel:add
  local a = { x = 0 }
  local b = { y = 0 }
  local tw1 = lurek.tween.tween(0.4, a, { x = 80 })
  local par = lurek.tween.parallel()
  par:add(tw1)
  par:tween(0.4, b, { y = 80 })
  par:start()
end

--@api-stub: TweenParallel:onComplete
do -- TweenParallel:onComplete
  local actor = { x = 0, alpha = 1 }
  lurek.tween.parallel()
    :tween(0.6, actor, { x = 200 })
    :tween(0.6, actor, { alpha = 0 })
    :onComplete(function() lurek.log.debug("parallel done", "tween") end)
    :start()
end

--@api-stub: TweenParallel:type
do -- TweenParallel:type
  local par = lurek.tween.parallel()
  lurek.log.info("TweenParallel:type = " .. tostring(par:type()), "tween")
end

--@api-stub: TweenParallel:typeOf
do -- TweenParallel:typeOf
  local par = lurek.tween.parallel()
  lurek.log.info("TweenParallel:typeOf = " .. tostring(par:typeOf("TweenParallel")), "tween")
end

-- -----------------------------------------------------------------------------
-- TweenSequence methods
-- -----------------------------------------------------------------------------

--@api-stub: TweenSequence:callback
do -- TweenSequence:callback
  local door = { y = 0 }
  lurek.tween.sequence()
    :tween(0.3, door, { y = 64 })
    :callback(function() lurek.log.debug("door open", "scene") end)
    :tween(0.3, door, { y = 0 })
    :start()
end

--@api-stub: TweenSequence:onComplete
do -- TweenSequence:onComplete
  local door = { y = 0 }
  lurek.tween.sequence()
    :tween(0.4, door, { y = 64 })
    :onComplete(function() lurek.log.debug("sequence done", "scene") end)
    :start()
end

--@api-stub: TweenSequence:type
do -- TweenSequence:type
  local seq = lurek.tween.sequence()
  lurek.log.info("TweenSequence:type = " .. tostring(seq:type()), "tween")
end

--@api-stub: TweenSequence:typeOf
do -- TweenSequence:typeOf
  local seq = lurek.tween.sequence()
  lurek.log.info("TweenSequence:typeOf = " .. tostring(seq:typeOf("TweenSequence")), "tween")
end

-- =============================================================================
-- COVERAGE: 46 uncovered lurek.tween API item(s)
-- Generated by tools/audit/example_add_missing.py
-- REQUIRED: replace every --@api-stub: block below with a real scenario.
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- The final committed file must contain ZERO --@api-stub: lines.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- LTween methods
-- -----------------------------------------------------------------------------

--@api-stub: LTween:cancel -- Cancels this tween immediately, fires the onCancel callback if set, and resumes any coroutines waiting on it
do -- LTween:cancel
  local target = { x = 0 }
  local tw = lurek.tween.tween(1.0, target, { x = 100 })
  tw:cancel()   -- interrupt before it finishes
  lurek.log.info("tween cancelled, target.x=" .. tostring(target.x), "tween")
end
--@api-stub: LTweenParallel:tween
do -- LTweenParallel:tween
  local obj = { x = 0, alpha = 1.0 }
  lurek.tween.parallel()
    :tween(0.5, obj, { x = 200 })
    :tween(0.5, obj, { alpha = 0.0 })
    :start()
  lurek.log.info("parallel group with two tweens started", "tween")
end
--@api-stub: LTweenParallel:start -- Starts all tweens in this parallel group simultaneously
do -- LTweenParallel:start
  local pos = { x = 0 }
  local col = { a = 1.0 }
  lurek.tween.parallel()
    :tween(0.4, pos, { x = 100 })
    :tween(0.4, col, { a = 0 })
    :start()   -- activates the group
  lurek.log.info("parallel group started", "tween")
end
--@api-stub: LTweenSequence:tween
do -- LTweenSequence:tween
  local pos = { x = 0, y = 0 }
  lurek.tween.sequence()
    :tween(0.3, pos, { x = 100 })  -- step 1: move right
    :tween(0.3, pos, { y = 80 })   -- step 2: move down
    :start()
  lurek.log.info("sequence with two tween steps queued", "tween")
end
--@api-stub: LTweenSequence:delay
do -- LTweenSequence:delay
  local obj = { x = 0 }
  lurek.tween.sequence()
    :tween(0.2, obj, { x = 100 })
    :delay(0.5)                    -- pause half a second
    :tween(0.2, obj, { x = 0 })
    :start()
  lurek.log.info("sequence with delay inserted", "tween")
end
--@api-stub: LTweenSequence:start -- Starts playback of this sequence from the first step
do -- LTweenSequence:start
  local door = { y = 0 }
  local seq = lurek.tween.sequence()
    :tween(0.4, door, { y = 64 })
    :delay(1.0)
    :tween(0.4, door, { y = 0 })
  seq:start()   -- begin the sequence
  lurek.log.info("door open/wait/close sequence started", "tween")
end
--@api-stub: LTweenState:type -- Returns the type name of this object
do -- LTweenState:type
  local tween_state_obj = lurek.tween.newState(0.5)
  local t = tween_state_obj:type()
  lurek.log.info("LTweenState:type = " .. t, "tween")
end
--@api-stub: LTweenState:typeOf -- Checks whether this object matches the given type name
do -- LTweenState:typeOf
  local tween_state_obj = lurek.tween.newState(0.5)
  lurek.log.info("is LTweenState: " .. tostring(tween_state_obj:typeOf("LTweenState")), "tween")
  lurek.log.info("is wrong: " .. tostring(tween_state_obj:typeOf("Unknown")), "tween")
end
