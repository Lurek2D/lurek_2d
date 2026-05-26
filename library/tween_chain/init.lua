--- Lurek2D chainable tween sequences — a pure-Lua tweening system.
--
-- Provides sequential and parallel tween chains with built-in easing,
-- looping, callbacks, and pause/resume control. No engine runtime
-- dependency; works in headless test VMs.
--
-- A chain is a sequence of steps: property tweens (`to`), delays (`wait`),
-- or instant callbacks (`call`). Steps execute one at a time. A parallel
-- group runs all its sub-tweens simultaneously and completes when the
-- longest one finishes.
--
-- Usage:
--   local TweenChain = require("library.tween_chain")
--   local chain = TweenChain.new()
--   chain:to(obj, { x = 100, y = 200 }, 0.5, "easeOutQuad")
--        :wait(0.2)
--        :to(obj, { x = 300 }, 1.0, "linear")
--        :call(function() print("done!") end)
--   chain:start()
--   -- each frame:
--   chain:update(dt)
--
-- @module library.tween_chain
-- @status full

local tween_chain = {}

-- ── Optional logging ──────────────────────────────────────────────────────────

--- @local
local log_ok, _log = pcall(function()
    return lurek and lurek.log
end)
if not log_ok or not _log then
    _log = {
        debug = function() end,
        warn  = function() end,
        error = function() end,
    }
end

-- ══════════════════════════════════════════════════════════════════════════════
-- Easing functions
-- ══════════════════════════════════════════════════════════════════════════════

local easing = {}

--- Linear interpolation (no easing).
--- @tparam number t Progress 0..1
--- @treturn number Eased value
function easing.linear(t)
    return t
end

--- Quadratic ease-in.
--- @tparam number t Progress 0..1
--- @treturn number Eased value
function easing.easeInQuad(t)
    return t * t
end

--- Quadratic ease-out.
--- @tparam number t Progress 0..1
--- @treturn number Eased value
function easing.easeOutQuad(t)
    return t * (2 - t)
end

--- Quadratic ease-in-out.
--- @tparam number t Progress 0..1
--- @treturn number Eased value
function easing.easeInOutQuad(t)
    if t < 0.5 then
        return 2 * t * t
    end
    return -1 + (4 - 2 * t) * t
end

--- Cubic ease-in.
--- @tparam number t Progress 0..1
--- @treturn number Eased value
function easing.easeInCubic(t)
    return t * t * t
end

--- Cubic ease-out.
--- @tparam number t Progress 0..1
--- @treturn number Eased value
function easing.easeOutCubic(t)
    local u = t - 1
    return u * u * u + 1
end

--- Cubic ease-in-out.
--- @tparam number t Progress 0..1
--- @treturn number Eased value
function easing.easeInOutCubic(t)
    if t < 0.5 then
        return 4 * t * t * t
    end
    local u = 2 * t - 2
    return 0.5 * u * u * u + 1
end

--- Back ease-in (slight overshoot at start).
--- @tparam number t Progress 0..1
--- @treturn number Eased value
function easing.easeInBack(t)
    local s = 1.70158
    return t * t * ((s + 1) * t - s)
end

--- Back ease-out (slight overshoot at end).
--- @tparam number t Progress 0..1
--- @treturn number Eased value
function easing.easeOutBack(t)
    local s = 1.70158
    local u = t - 1
    return u * u * ((s + 1) * u + s) + 1
end

--- Back ease-in-out.
--- @tparam number t Progress 0..1
--- @treturn number Eased value
function easing.easeInOutBack(t)
    local s = 1.70158 * 1.525
    if t < 0.5 then
        return 0.5 * (4 * t * t * ((s + 1) * 2 * t - s))
    end
    local u = 2 * t - 2
    return 0.5 * (u * u * ((s + 1) * u + s) + 2)
end

--- Bounce ease-out.
--- @tparam number t Progress 0..1
--- @treturn number Eased value
function easing.easeOutBounce(t)
    if t < 1 / 2.75 then
        return 7.5625 * t * t
    elseif t < 2 / 2.75 then
        local u = t - 1.5 / 2.75
        return 7.5625 * u * u + 0.75
    elseif t < 2.5 / 2.75 then
        local u = t - 2.25 / 2.75
        return 7.5625 * u * u + 0.9375
    else
        local u = t - 2.625 / 2.75
        return 7.5625 * u * u + 0.984375
    end
end

--- Elastic ease-out.
--- @tparam number t Progress 0..1
--- @treturn number Eased value
function easing.easeOutElastic(t)
    if t == 0 then return 0 end
    if t == 1 then return 1 end
    local p = 0.3
    local s = p / 4
    return math.pow(2, -10 * t) * math.sin((t - s) * (2 * math.pi) / p) + 1
end

--- Exposed easing table for external use.
tween_chain.easing = easing

-- ══════════════════════════════════════════════════════════════════════════════
-- Internal step types
-- ══════════════════════════════════════════════════════════════════════════════

local function resolve_easing(name)
    if type(name) == "function" then return name end
    local fn = easing[name or "linear"]
    if not fn then
        _log.warn("tween_chain: unknown easing '" .. tostring(name) .. "', falling back to linear")
        fn = easing.linear
    end
    return fn
end

--- @local Create a tween step that interpolates properties.
local function make_tween_step(target, props, duration, ease_name)
    local ease_fn = resolve_easing(ease_name)
    local start_values = nil
    local elapsed = 0
    return {
        type = "tween",
        duration = duration,
        init = function()
            start_values = {}
            for k, _ in pairs(props) do
                start_values[k] = target[k] or 0
            end
            elapsed = 0
        end,
        update = function(dt)
            elapsed = elapsed + dt
            local t = math.min(elapsed / duration, 1.0)
            local eased = ease_fn(t)
            for k, goal in pairs(props) do
                target[k] = start_values[k] + (goal - start_values[k]) * eased
            end
            return t >= 1.0
        end,
        reset = function()
            elapsed = 0
            start_values = nil
        end,
    }
end

--- @local Create a wait step (delay).
local function make_wait_step(duration)
    local elapsed = 0
    return {
        type = "wait",
        duration = duration,
        init = function()
            elapsed = 0
        end,
        update = function(dt)
            elapsed = elapsed + dt
            return elapsed >= duration
        end,
        reset = function()
            elapsed = 0
        end,
    }
end

--- @local Create an instant callback step.
local function make_call_step(fn)
    local fired = false
    return {
        type = "call",
        duration = 0,
        init = function()
            fired = false
        end,
        update = function(_dt)
            if not fired then
                fired = true
                fn()
            end
            return true
        end,
        reset = function()
            fired = false
        end,
    }
end

-- ══════════════════════════════════════════════════════════════════════════════
-- Parallel group
-- ══════════════════════════════════════════════════════════════════════════════

local ParallelGroup = {}
ParallelGroup.__index = ParallelGroup

--- Create a parallel tween group. All sub-tweens run simultaneously.
--- The group completes when the longest sub-tween finishes.
--- @treturn ParallelGroup A new parallel group instance
function tween_chain.parallel()
    local self = setmetatable({}, ParallelGroup)
    self._tweens = {}
    self._started = false
    self._complete = false
    return self
end

--- Add a property tween to this parallel group.
--- @tparam table target Object whose properties will be animated
--- @tparam table props Table of {property = goal_value} pairs
--- @tparam number duration Tween duration in seconds
--- @tparam ?string ease_name Easing function name (default "linear")
--- @treturn ParallelGroup self for chaining
function ParallelGroup:to(target, props, duration, ease_name)
    self._tweens[#self._tweens + 1] = make_tween_step(target, props, duration, ease_name)
    return self
end

--- @local ParallelGroup acts as a single step in the chain.
function ParallelGroup:_as_step()
    local group = self
    return {
        type = "parallel",
        duration = 0, -- computed dynamically
        init = function()
            group._started = true
            group._complete = false
            for _, tw in ipairs(group._tweens) do
                tw.init()
            end
        end,
        update = function(dt)
            local all_done = true
            for _, tw in ipairs(group._tweens) do
                if not tw.update(dt) then
                    all_done = false
                end
            end
            group._complete = all_done
            return all_done
        end,
        reset = function()
            group._started = false
            group._complete = false
            for _, tw in ipairs(group._tweens) do
                tw.reset()
            end
        end,
    }
end

-- ══════════════════════════════════════════════════════════════════════════════
-- Chain
-- ══════════════════════════════════════════════════════════════════════════════

local Chain = {}
Chain.__index = Chain

--- Create a new sequential tween chain.
--- @treturn Chain A new chain instance
function tween_chain.new()
    local self = setmetatable({}, Chain)
    self._steps = {}
    self._current = 0
    self._playing = false
    self._complete = false
    self._paused = false
    self._loop_count = 1   -- 1 = play once, 0 = infinite
    self._loop_current = 0
    self._on_start = nil
    self._on_complete = nil
    self._on_loop = nil
    self._started_once = false
    return self
end

--- Add a property tween step to the chain.
--- @tparam table target Object whose properties will be animated
--- @tparam table props Table of {property = goal_value} pairs
--- @tparam number duration Tween duration in seconds
--- @tparam ?string ease_name Easing function name (default "linear")
--- @treturn Chain self for chaining
function Chain:to(target, props, duration, ease_name)
    self._steps[#self._steps + 1] = make_tween_step(target, props, duration, ease_name)
    return self
end

--- Add a delay step to the chain.
--- @tparam number duration Delay duration in seconds
--- @treturn Chain self for chaining
function Chain:wait(duration)
    self._steps[#self._steps + 1] = make_wait_step(duration)
    return self
end

--- Add an instant callback step to the chain.
--- @tparam function fn Callback to invoke when this step is reached
--- @treturn Chain self for chaining
function Chain:call(fn)
    self._steps[#self._steps + 1] = make_call_step(fn)
    return self
end

--- Add a parallel group (or any step-like object) to the chain.
--- @tparam ParallelGroup group A parallel group created via tween_chain.parallel()
--- @treturn Chain self for chaining
function Chain:add(group)
    if group._as_step then
        self._steps[#self._steps + 1] = group:_as_step()
    else
        self._steps[#self._steps + 1] = group
    end
    return self
end

--- Set the loop count for the chain.
--- @tparam number count Number of loops (0 = infinite, 1 = play once, default)
--- @treturn Chain self for chaining
function Chain:loop(count)
    self._loop_count = count or 0
    return self
end

--- Register a callback fired when the chain starts playing.
--- @tparam function fn Callback
--- @treturn Chain self for chaining
function Chain:onStart(fn)
    self._on_start = fn
    return self
end

--- Register a callback fired when the chain fully completes (all loops done).
--- @tparam function fn Callback
--- @treturn Chain self for chaining
function Chain:onComplete(fn)
    self._on_complete = fn
    return self
end

--- Register a callback fired at the end of each loop iteration.
--- @tparam function fn Callback receiving the current loop index
--- @treturn Chain self for chaining
function Chain:onLoop(fn)
    self._on_loop = fn
    return self
end

--- Start (or restart) the chain from the beginning.
function Chain:start()
    if #self._steps == 0 then
        _log.warn("tween_chain: start() called on empty chain")
        return
    end
    self._current = 1
    self._playing = true
    self._complete = false
    self._paused = false
    self._loop_current = 0
    self._started_once = true
    for _, step in ipairs(self._steps) do
        step.reset()
    end
    self._steps[1].init()
    if self._on_start then self._on_start() end
end

--- Advance the chain by dt seconds. Call once per frame.
--- @tparam number dt Delta time in seconds
function Chain:update(dt)
    if not self._playing or self._paused or self._complete then
        return
    end
    if self._current < 1 or self._current > #self._steps then
        return
    end

    local step = self._steps[self._current]
    local done = step.update(dt)

    if done then
        -- Advance to next step
        self._current = self._current + 1
        if self._current <= #self._steps then
            self._steps[self._current].init()
        else
            -- End of chain iteration
            self._loop_current = self._loop_current + 1
            if self._on_loop then self._on_loop(self._loop_current) end

            local should_loop = (self._loop_count == 0) or (self._loop_current < self._loop_count)
            if should_loop then
                -- Reset and replay
                self._current = 1
                for _, s in ipairs(self._steps) do
                    s.reset()
                end
                self._steps[1].init()
            else
                -- Fully complete
                self._playing = false
                self._complete = true
                if self._on_complete then self._on_complete() end
            end
        end
    end
end

--- Pause playback.
function Chain:pause()
    self._paused = true
end

--- Resume playback after pause.
function Chain:resume()
    self._paused = false
end

--- Stop playback and mark as complete.
function Chain:stop()
    self._playing = false
    self._paused = false
    self._complete = true
end

--- Reset the chain to its initial state (not playing).
function Chain:reset()
    self._current = 0
    self._playing = false
    self._complete = false
    self._paused = false
    self._loop_current = 0
    self._started_once = false
    for _, step in ipairs(self._steps) do
        step.reset()
    end
end

--- Check if the chain is currently playing (not paused, not complete).
--- @treturn boolean True if playing
function Chain:isPlaying()
    return self._playing and not self._paused
end

--- Check if the chain has finished all iterations.
--- @treturn boolean True if complete
function Chain:isComplete()
    return self._complete
end

--- Get overall progress through the current loop iteration.
--- @treturn number Progress from 0.0 to 1.0
function Chain:getProgress()
    if #self._steps == 0 then return 0 end
    if self._complete then return 1.0 end
    if self._current < 1 then return 0 end
    -- Approximate progress based on step index
    return math.min((self._current - 1) / #self._steps, 1.0)
end

return tween_chain
