--- @status full
--- Sprite animation toolkit: SpriteAnimator for frame-by-frame playback,
--- and AnimController for rule-based state-machine animation switching.
---
--- ## Engine integrations
---
--- @see lurek.sprite

local SpriteAnimator = require("library.sprite.sprite_animator")

local M = {}

-- Re-export SpriteAnimator
M.SpriteAnimator = SpriteAnimator

--- Log a debug message if lurek.log is available.
local function log_debug(msg)
    local ok, _ = pcall(function()
        if lurek and lurek.log and lurek.log.debug then
            lurek.log.debug("[sprite] " .. msg)
        end
    end)
    local _ = ok
end

-- ── AnimController ────────────────────────────────────────────────────────────

local AnimController = {}
AnimController.__index = AnimController

--- Create a new AnimController that auto-switches animation clips based on rules.
--- Rules are evaluated in order each frame; first matching rule wins.
--- @tparam SpriteAnimator animator The SpriteAnimator instance to control.
--- @tparam table opts Configuration table.
--- @tparam table opts.rules Array of {state=string, condition=function(ctx)->bool}.
--- @tparam[opt="idle"] string opts.default Fallback state when no rule matches.
--- @treturn AnimController
function AnimController.new(animator, opts)
    opts = opts or {}
    local self = setmetatable({}, AnimController)

    self._animator      = animator
    self._rules         = opts.rules or {}
    self._default       = opts.default or "idle"
    self._state         = nil
    self._forced        = nil     -- forced state name or nil
    self._forceTimer    = 0       -- remaining forced duration
    self._onChange      = nil     -- state change callback

    return self
end

--- Update the controller: evaluate rules or tick forced state timer.
--- @tparam number dt Delta time in seconds.
--- @tparam table ctx Context table passed to each rule's condition function.
function AnimController:update(dt, ctx)
    -- Tick forced state timer
    if self._forced then
        self._forceTimer = self._forceTimer - dt
        if self._forceTimer <= 0 then
            self._forced     = nil
            self._forceTimer = 0
        else
            self._animator:update(dt)
            return
        end
    end

    -- Evaluate rules in priority order
    local next_state = self._default
    for i = 1, #self._rules do
        local rule = self._rules[i]
        if rule.condition and rule.condition(ctx) then
            next_state = rule.state
            break
        end
    end

    -- Transition if state changed
    if next_state ~= self._state then
        local old = self._state
        self._state = next_state
        self._animator:play(next_state)
        log_debug("state: " .. tostring(old) .. " -> " .. next_state)
        if self._onChange then
            self._onChange(old, next_state)
        end
    end

    self._animator:update(dt)
end

--- Returns the current animation state name.
--- @treturn string
function AnimController:getState()
    if self._forced then
        return self._forced
    end
    return self._state
end

--- Force a specific state for a duration, ignoring rules.
--- @tparam string state The clip/state name to force.
--- @tparam number duration Seconds to hold the forced state.
function AnimController:force(state, duration)
    local old = self._state
    self._forced     = state
    self._forceTimer = duration or 0
    self._state      = state
    self._animator:play(state)
    log_debug("forced: " .. state .. " for " .. tostring(duration) .. "s")
    if self._onChange and old ~= state then
        self._onChange(old, state)
    end
end

--- Register a callback fired on state transitions. fn(oldState, newState)
--- @tparam function fn Callback function.
function AnimController:onStateChange(fn)
    self._onChange = fn
end

--- Returns the underlying SpriteAnimator.
--- @treturn SpriteAnimator
function AnimController:getAnimator()
    return self._animator
end

M.AnimController = AnimController

return M
