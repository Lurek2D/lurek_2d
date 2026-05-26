--- Lurek2D input action map — bind named actions to keys, mouse buttons, and gamepad buttons.
--
-- A pure-Lua action mapping layer over `lurek.input.*`. Supports multiple
-- bindings per action, pressed/held/released queries, and simple two-action axes.
--
-- Usage:
--   local InputActionMap = require("library.input_action_map")
--   local actions = InputActionMap.new()
--   actions:bind("jump", "space")
--   actions:bind("jump", "gamepad_a")
--   actions:update()
--   if actions:pressed("jump") then ... end
--
-- @module library.input_action_map
-- @status full
-- @see lurek.input.isKeyPressed      keyboard pressed query
-- @see lurek.input.isKeyDown          keyboard held query
-- @see lurek.input.isKeyReleased      keyboard released query
-- @see lurek.input.isMousePressed     mouse pressed query
-- @see lurek.input.isMouseDown        mouse held query
-- @see lurek.input.isMouseReleased    mouse released query
-- @see lurek.input.isGamepadPressed   gamepad pressed query
-- @see lurek.input.isGamepadDown      gamepad held query
-- @see lurek.input.isGamepadReleased  gamepad released query

local InputActionMap = {}

--- Optional engine logger. Uses lurek.log when running inside the engine,
-- silently no-ops in standalone Lua.
local _log
local ok, _ = pcall(function()
    if lurek and lurek.log then _log = lurek.log end
end)
if not ok then _log = nil end
local function _info(msg) if _log then _log.info(msg) end end
local function _warn(msg) if _log then _log.warn(msg) end end

--- Resolve input API references (guarded for standalone Lua).
local _input
pcall(function()
    if lurek and lurek.input then _input = lurek.input end
end)

-- ─── Internal helpers ─────────────────────────────────────────────────────────

--- Determine the input source for a binding key string.
-- @tparam string key The binding key name.
-- @treturn string "mouse", "gamepad", or "keyboard"
local function _classify(key)
    if key:sub(1, 6) == "mouse_" then return "mouse"
    elseif key:sub(1, 8) == "gamepad_" then return "gamepad"
    else return "keyboard"
    end
end

--- Strip the prefix from a binding key to get the raw button/key name.
-- @tparam string key The binding key name.
-- @treturn string The raw name passed to the lurek.input API.
local function _rawKey(key)
    local kind = _classify(key)
    if kind == "mouse" then return key:sub(7)
    elseif kind == "gamepad" then return key:sub(9)
    else return key
    end
end

--- Query whether a key is currently down this frame.
-- @tparam string key The binding key name.
-- @treturn boolean
local function _isDown(key)
    if not _input then return false end
    local kind = _classify(key)
    local raw = _rawKey(key)
    if kind == "mouse" then
        return _input.isMouseDown and _input.isMouseDown(raw) or false
    elseif kind == "gamepad" then
        return _input.isGamepadDown and _input.isGamepadDown(raw) or false
    else
        return _input.isKeyDown and _input.isKeyDown(raw) or false
    end
end

--- Query whether a key was just pressed this frame.
-- @tparam string key The binding key name.
-- @treturn boolean
local function _isPressed(key)
    if not _input then return false end
    local kind = _classify(key)
    local raw = _rawKey(key)
    if kind == "mouse" then
        return _input.isMousePressed and _input.isMousePressed(raw) or false
    elseif kind == "gamepad" then
        return _input.isGamepadPressed and _input.isGamepadPressed(raw) or false
    else
        return _input.isKeyPressed and _input.isKeyPressed(raw) or false
    end
end

--- Query whether a key was just released this frame.
-- @tparam string key The binding key name.
-- @treturn boolean
local function _isReleased(key)
    if not _input then return false end
    local kind = _classify(key)
    local raw = _rawKey(key)
    if kind == "mouse" then
        return _input.isMouseReleased and _input.isMouseReleased(raw) or false
    elseif kind == "gamepad" then
        return _input.isGamepadReleased and _input.isGamepadReleased(raw) or false
    else
        return _input.isKeyReleased and _input.isKeyReleased(raw) or false
    end
end

-- ─── ActionMap instance ───────────────────────────────────────────────────────

local ActionMap = {}
ActionMap.__index = ActionMap

--- Create a new action map instance.
-- @treturn ActionMap A fresh action map with no bindings.
function InputActionMap.new()
    local self = setmetatable({}, ActionMap)
    self._bindings = {}  -- action_name -> {key1, key2, ...}
    _info("[InputActionMap] created new action map")
    return self
end

--- Bind a key to a named action. Multiple keys can be bound to the same action.
-- @tparam string action The action name.
-- @tparam string key The input key (e.g. "space", "mouse_left", "gamepad_a").
function ActionMap:bind(action, key)
    if not action or not key then
        _warn("[InputActionMap] bind: action and key are required")
        return
    end
    if not self._bindings[action] then
        self._bindings[action] = {}
    end
    -- Avoid duplicate bindings
    for _, existing in ipairs(self._bindings[action]) do
        if existing == key then return end
    end
    self._bindings[action][#self._bindings[action] + 1] = key
end

--- Remove a specific key binding from an action.
-- @tparam string action The action name.
-- @tparam string key The input key to unbind.
function ActionMap:unbind(action, key)
    local keys = self._bindings[action]
    if not keys then return end
    for i = #keys, 1, -1 do
        if keys[i] == key then
            table.remove(keys, i)
            break
        end
    end
    if #keys == 0 then
        self._bindings[action] = nil
    end
end

--- Remove all bindings for a named action.
-- @tparam string action The action name.
function ActionMap:unbindAll(action)
    self._bindings[action] = nil
end

--- Poll input state. Call once per frame before querying actions.
-- This method exists for forward-compatibility (e.g. buffered input, repeat
-- detection). Currently the lurek.input API is frame-synchronous so this is
-- a no-op, but consumers should always call it.
function ActionMap:update()
    -- Reserved for future per-frame bookkeeping.
end

--- Check if an action was just pressed this frame.
-- Returns true if ANY bound key for the action was pressed.
-- @tparam string action The action name.
-- @treturn boolean
function ActionMap:pressed(action)
    local keys = self._bindings[action]
    if not keys then return false end
    for _, key in ipairs(keys) do
        if _isPressed(key) then return true end
    end
    return false
end

--- Check if an action is currently held down.
-- Returns true if ANY bound key for the action is held.
-- @tparam string action The action name.
-- @treturn boolean
function ActionMap:held(action)
    local keys = self._bindings[action]
    if not keys then return false end
    for _, key in ipairs(keys) do
        if _isDown(key) then return true end
    end
    return false
end

--- Check if an action was just released this frame.
-- Returns true if ANY bound key for the action was released.
-- @tparam string action The action name.
-- @treturn boolean
function ActionMap:released(action)
    local keys = self._bindings[action]
    if not keys then return false end
    for _, key in ipairs(keys) do
        if _isReleased(key) then return true end
    end
    return false
end

--- Compute a simple axis value from two opposing actions.
-- Returns -1 if negative_action is held, +1 if positive_action is held,
-- 0 if both or neither are held.
-- @tparam string negative_action The action for the negative direction.
-- @tparam string positive_action The action for the positive direction.
-- @treturn number -1, 0, or 1
function ActionMap:axis(negative_action, positive_action)
    local neg = self:held(negative_action) and 1 or 0
    local pos = self:held(positive_action) and 1 or 0
    return pos - neg
end

--- Get all keys bound to an action.
-- @tparam string action The action name.
-- @treturn table Array of key strings, or empty table if action has no bindings.
function ActionMap:getBindings(action)
    local keys = self._bindings[action]
    if not keys then return {} end
    -- Return a copy to prevent external mutation
    local out = {}
    for i, k in ipairs(keys) do out[i] = k end
    return out
end

--- Remove all actions and bindings from this map.
function ActionMap:clear()
    self._bindings = {}
    _info("[InputActionMap] cleared all bindings")
end

return InputActionMap
