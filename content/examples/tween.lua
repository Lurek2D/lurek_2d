-- content/examples/tween.lua
-- love2d-style usage snippets for the lurek.tween API (35 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/tween.lua

-- ── lurek.tween.* functions ──

--@api-stub: lurek.tween.update
-- Advances all active tweens, sequences, and parallels by `dt` seconds.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.tween.update(dt)
print("update applied")
print("ok")

--@api-stub: lurek.tween.tween
-- Creates a new property tween and registers it for automatic updating.
-- See the module spec for detailed semantics.
local result = lurek.tween.tween()
print("tween:", result)
return result

--@api-stub: lurek.tween.sequence
-- Creates an empty TweenSequence.
-- See the module spec for detailed semantics.
local result = lurek.tween.sequence()
print("sequence:", result)
return result

--@api-stub: lurek.tween.parallel
-- Creates an empty TweenParallel.
-- See the module spec for detailed semantics.
local result = lurek.tween.parallel()
print("parallel:", result)
return result

--@api-stub: lurek.tween.delay
-- Creates a no-op tween that waits `seconds`, then optionally calls `callback`.
-- See the module spec for detailed semantics.
local result = lurek.tween.delay(1.0, function() print("delay fired") end)
print("delay:", result)
return result

--@api-stub: lurek.tween.cancelAll
-- Cancels all active tweens, sequences, parallels, and springs immediately.
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.tween.cancelAll()
print("cancelAll done")
print("ok")

--@api-stub: lurek.tween.getActiveCount
-- Returns the number of currently active tween objects (tweens + seqs + pars).
-- Cheap to call; safe inside callbacks.
local value = lurek.tween.getActiveCount()
print("getActiveCount:", value)
return value

--@api-stub: lurek.tween.registerEasing
-- Registers a custom easing function under `name`.
-- Side-effecting; safe to call any time after init.
lurek.tween.registerEasing("main", f)
-- mutator; side effect applied
print("registerEasing done")
print("ok")

--@api-stub: lurek.tween.getEasingNames
-- Returns a list of all available easing names (built-in + custom).
-- Cheap to call; safe inside callbacks.
local value = lurek.tween.getEasingNames()
print("getEasingNames:", value)
return value

--@api-stub: lurek.tween.newState
-- Creates a standalone tween timing state without registering it with the engine.
-- Build once at startup; reuse across frames.
local state = lurek.tween.newState(1.0, easing)
print("created", state)
return state

--@api-stub: lurek.tween.to
-- Sugar for `tween()` with `target` first â€” natural read order.
-- See the module spec for detailed semantics.
local result = lurek.tween.to()
print("to:", result)
return result

--@api-stub: lurek.tween.spring
-- Creates a physics-based spring animation that drives named fields on `target_table`.
-- See the module spec for detailed semantics.
local result = lurek.tween.spring(target_tbl, { x = 0, y = 0 }, { x = 0, y = 0 })
print("spring:", result)
return result

-- ── TweenState methods ──

--@api-stub: TweenState:tick
-- Advances the tween state by `dt` seconds.
-- Trigger from input, timers, or game events.
local tweenState = lurek.tween.newTweenState()
tweenState:tick(dt)
-- trigger from input, timer, or event
print("ok")

--@api-stub: TweenState:isComplete
-- Returns whether the tween state has completed.
-- Use as a guard inside lurek.update or event handlers.
local tweenState = lurek.tween.newTweenState()
if tweenState:isComplete() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: TweenState:t
-- Returns the raw 0..1 playback progress.
-- See the module spec for detailed semantics.
local tweenState = lurek.tween.newTweenState()
tweenState:t()
print("TweenState:t done")

--@api-stub: TweenState:lerp
-- Interpolates from `start` to `finish` using the eased tween progress.
-- See the module spec for detailed semantics.
local tweenState = lurek.tween.newTweenState()
tweenState:lerp(start, finish)
print("TweenState:lerp done")

--@api-stub: TweenState:reset
-- Resets the tween state to elapsed time zero.
-- Pair with the matching constructor to free resources.
local tweenState = lurek.tween.newTweenState()
tweenState:reset()
-- tweenState is now released
print("ok")

-- ── Tween methods ──

--@api-stub: Tween:pause
-- Pauses this tween; time stops advancing but the tween is not cancelled.
-- Trigger from input, timers, or game events.
local tween = lurek.tween.newTween()
tween:pause()
-- trigger from input, timer, or event
print("ok")

--@api-stub: Tween:resume
-- Resumes a paused tween, continuing from the position where it was paused.
-- Trigger from input, timers, or game events.
local tween = lurek.tween.newTween()
tween:resume()
-- trigger from input, timer, or event
print("ok")

--@api-stub: Tween:isActive
-- Returns true if the tween is still running (not completed or cancelled).
-- Use as a guard inside lurek.update or event handlers.
local tween = lurek.tween.newTween()
if tween:isActive() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Tween:getProgress
-- Returns raw 0..1 playback progress (not eased, not accounting for yoyo).
-- Cheap to call; safe inside callbacks.
local tween = lurek.tween.newTween()  -- or your existing handle
local value = tween:getProgress()
print("Tween:getProgress ->", value)

--@api-stub: Tween:setRepeat
-- Sets the number of extra play cycles after the first (0 = play once, -1 = infinite).
-- Apply at startup or in response to user input.
local tween = lurek.tween.newTween()
tween:setRepeat(10)
print("Tween:setRepeat applied")

--@api-stub: Tween:setYoyo
-- Enables or disables yoyo (ping-pong) on each repeat cycle.
-- Apply at startup or in response to user input.
local tween = lurek.tween.newTween()
tween:setYoyo(enabled)
print("Tween:setYoyo applied")

-- ── TweenSequence methods ──

--@api-stub: TweenSequence:cancel
-- Cancels the sequence and stops all pending steps.
-- Pair with the matching constructor to free resources.
local tweenSequence = lurek.tween.newTweenSequence()
tweenSequence:cancel()
-- tweenSequence is now released
print("ok")

--@api-stub: TweenSequence:isActive
-- Returns true if the sequence has been started and has not yet completed.
-- Use as a guard inside lurek.update or event handlers.
local tweenSequence = lurek.tween.newTweenSequence()
if tweenSequence:isActive() then print("yes") end
-- swap the constructor for your real handle
print("ok")

-- ── TweenParallel methods ──

--@api-stub: TweenParallel:cancel
-- Cancels the parallel group immediately.
-- Pair with the matching constructor to free resources.
local tweenParallel = lurek.tween.newTweenParallel()
tweenParallel:cancel()
-- tweenParallel is now released
print("ok")

--@api-stub: TweenParallel:isActive
-- Returns true if the parallel is running and not yet complete.
-- Use as a guard inside lurek.update or event handlers.
local tweenParallel = lurek.tween.newTweenParallel()
if tweenParallel:isActive() then print("yes") end
-- swap the constructor for your real handle
print("ok")

-- ── Spring methods ──

--@api-stub: Spring:update
-- Advances the spring by `dt` seconds and writes positions to the target table.
-- Apply at startup or in response to user input.
local spring = lurek.tween.newSpring()
spring:update(dt)
print("Spring:update applied")

--@api-stub: Spring:isSettled
-- Returns `true` when all spring axes have converged within `precision`.
-- Use as a guard inside lurek.update or event handlers.
local spring = lurek.tween.newSpring()
if spring:isSettled() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Spring:isActive
-- Returns `true` if the spring has not been cancelled or settled.
-- Use as a guard inside lurek.update or event handlers.
local spring = lurek.tween.newSpring()
if spring:isActive() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Spring:setTarget
-- Updates target values for all fields present in `fields_table`.
-- Apply at startup or in response to user input.
local spring = lurek.tween.newSpring()
spring:setTarget({ x = 0, y = 0 })
print("Spring:setTarget applied")

--@api-stub: Spring:setStiffness
-- Updates the stiffness constant on all axes.
-- Apply at startup or in response to user input.
local spring = lurek.tween.newSpring()
spring:setStiffness(value)
print("Spring:setStiffness applied")

--@api-stub: Spring:setDamping
-- Updates the damping coefficient on all axes.
-- Apply at startup or in response to user input.
local spring = lurek.tween.newSpring()
spring:setDamping(value)
print("Spring:setDamping applied")

--@api-stub: Spring:cancel
-- Stops the spring.
-- Pair with the matching constructor to free resources.
local spring = lurek.tween.newSpring()
spring:cancel()
-- spring is now released
print("ok")

--@api-stub: Spring:getPosition
-- Returns the current interpolated position for the named field, or `nil`.
-- Cheap to call; safe inside callbacks.
local spring = lurek.tween.newSpring()  -- or your existing handle
local value = spring:getPosition(field)
print("Spring:getPosition ->", value)

