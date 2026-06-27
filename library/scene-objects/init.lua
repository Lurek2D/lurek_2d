--- Scene object container — layered draw and update loop for game objects.
--
-- A pure-Lua runtime-agnostic container that holds any table with optional
-- `draw`, `update`, and `layer` fields.  One container per scene; call
-- `:update(dt)` and `:draw()` every frame from your scene callbacks.
--
-- Objects are drawn in ascending `layer` order.  An object's `layer` defaults
-- to 0 when not set.  Objects on the same layer are drawn in insertion order.
--
-- No engine dependencies; the module works in headless test VMs.
--
-- Usage:
--   local sceneobj = require("library/scene-objects")
--   local world = sceneobj.new()
--   world:add({ layer = 1, update = function(self, dt) end,
--                           draw   = function(self)     end })
--   -- each frame:
--   world:update(dt)
--   world:draw()
--
-- @module library.scene-objects
-- @status full

local scene_objects = {}

-- ── ObjectContainer metatable ─────────────────────────────────────────────────

local ObjectContainer = {}
ObjectContainer.__index = ObjectContainer

--- Create a new scene object container.
--- @treturn ObjectContainer A fresh empty container.
function scene_objects.new()
    return setmetatable({
        _objects       = {},   -- array: insertion order
        _dirty         = false, -- true when draw cache needs rebuild
        _draw_cache    = {},   -- sorted copy rebuilt on demand
        _group_bits    = {},   -- group name -> 0-based bit index
        _group_names   = {},   -- 1-based list of group names by bit+1
        _pass_enabled  = {
            update = {},
            physics = {},
            draw = {},
        },
    }, ObjectContainer)
end

-- ── Internal helpers ──────────────────────────────────────────────────────────

--- Rebuild the sorted draw cache from _objects.
--- @local
local function _rebuild_cache(self)
    local cache = {}
    for i = 1, #self._objects do
        cache[i] = self._objects[i]
    end
    table.sort(cache, function(a, b)
        return (a.layer or 0) < (b.layer or 0)
    end)
    self._draw_cache = cache
    self._dirty = false
end

local function _normalize_pass(pass)
    if pass == "process_physics" then
        return "physics"
    end
    if pass == "process" then
        return "update"
    end
    return pass or "update"
end

local function _bit_mask(bit)
    return 2 ^ bit
end

local function _object_mask(self, obj)
    local mask = obj.groupMask or obj.mask or 0
    if type(obj.group) == "string" then
        local bit = self._group_bits[obj.group]
        if bit ~= nil then
            mask = mask + _bit_mask(bit)
        end
    end
    if type(obj.groups) == "table" then
        for _, name in ipairs(obj.groups) do
            local bit = self._group_bits[name]
            if bit ~= nil then
                mask = mask + _bit_mask(bit)
            end
        end
    end
    return mask
end

local function _enabled_for_pass(self, obj, pass)
    local mask = _object_mask(self, obj)
    if mask == 0 then
        return true
    end
    local enabled = self._pass_enabled[_normalize_pass(pass)] or {}
    for bit = 0, 15 do
        local bit_mask = _bit_mask(bit)
        if mask % (bit_mask * 2) >= bit_mask and enabled[bit] == false then
            return false
        end
    end
    return true
end

-- ── Public API ────────────────────────────────────────────────────────────────

--- Add an object to the container.
-- Objects missing a `layer` field are treated as layer 0.
--- @tparam table obj Any table.  Optional fields: `draw`, `update`, `layer`.
function ObjectContainer:add(obj)
    self._objects[#self._objects + 1] = obj
    self._dirty = true
end

--- Define an object group and return its 0-based bit index.
--- @tparam string name Group name.
--- @treturn number Bit index from 0 to 15.
function ObjectContainer:defineGroup(name)
    local existing = self._group_bits[name]
    if existing ~= nil then
        return existing
    end
    local bit = #self._group_names
    if bit >= 16 then
        error("scene object container supports at most 16 groups")
    end
    self._group_names[bit + 1] = name
    self._group_bits[name] = bit
    self._pass_enabled.update[bit] = true
    self._pass_enabled.physics[bit] = true
    self._pass_enabled.draw[bit] = true
    return bit
end

--- Return the bit index assigned to a group name, or nil when undefined.
--- @tparam string name Group name.
--- @treturn number|nil Bit index.
function ObjectContainer:getGroupBit(name)
    return self._group_bits[name]
end

--- Enable or disable one group for one pass.
--- @tparam string|number group Group name or 0-based group bit.
--- @tparam string pass Pass name: update, physics/process_physics, or draw.
--- @tparam boolean enabled Whether the pass should include the group.
--- @treturn boolean True when the group and pass were accepted.
function ObjectContainer:setGroupEnabled(group, pass, enabled)
    local bit = type(group) == "number" and group or self._group_bits[group]
    pass = _normalize_pass(pass)
    if bit == nil or bit < 0 or bit > 15 or self._pass_enabled[pass] == nil then
        return false
    end
    self._pass_enabled[pass][bit] = not not enabled
    return true
end

--- Return whether one group is enabled for one pass.
--- @tparam string|number group Group name or 0-based group bit.
--- @tparam string pass Pass name.
--- @treturn boolean Enabled state.
function ObjectContainer:isGroupEnabled(group, pass)
    local bit = type(group) == "number" and group or self._group_bits[group]
    pass = _normalize_pass(pass)
    if bit == nil or self._pass_enabled[pass] == nil then
        return false
    end
    return self._pass_enabled[pass][bit] ~= false
end

--- Remove an object from the container (identity comparison).
-- Silently does nothing when the object is not present.
--- @tparam table obj The object to remove.
function ObjectContainer:remove(obj)
    local list = self._objects
    for i = 1, #list do
        if list[i] == obj then
            table.remove(list, i)
            self._dirty = true
            return
        end
    end
end

--- Remove all objects from the container.
function ObjectContainer:clear()
    self._objects = {}
    self._draw_cache = {}
    self._dirty = false
end

--- Call `obj:update(dt)` on every object that has an `update` method.
-- Objects are updated in insertion order.
--- @tparam number dt Delta time in seconds.
function ObjectContainer:update(dt)
    local list = self._objects
    for i = 1, #list do
        local obj = list[i]
        if _enabled_for_pass(self, obj, "update") and type(obj.update) == "function" then
            obj:update(dt)
        end
    end
end

--- Call `obj:process_physics(dt)` on objects enabled for the physics pass.
-- Falls back to `obj:physics(dt)` when present.
--- @tparam number dt Delta time in seconds.
function ObjectContainer:processPhysics(dt)
    local list = self._objects
    for i = 1, #list do
        local obj = list[i]
        if _enabled_for_pass(self, obj, "physics") then
            if type(obj.process_physics) == "function" then
                obj:process_physics(dt)
            elseif type(obj.physics) == "function" then
                obj:physics(dt)
            end
        end
    end
end

--- Call `obj:draw()` on every object that has a `draw` method, sorted by
-- `layer` ascending.  Objects with the same layer are drawn in insertion order.
function ObjectContainer:draw()
    if self._dirty then
        _rebuild_cache(self)
    end
    local cache = self._draw_cache
    for i = 1, #cache do
        local obj = cache[i]
        if _enabled_for_pass(self, obj, "draw") and type(obj.draw) == "function" then
            obj:draw()
        end
    end
end

--- Return the number of objects currently in the container.
--- @treturn number Total object count.
function ObjectContainer:count()
    return #self._objects
end

--- Return all objects on a specific layer.
--- @tparam number n Layer number.
--- @treturn table Array of objects whose `layer` equals `n` (may be empty).
function ObjectContainer:getByLayer(n)
    local result = {}
    local list = self._objects
    for i = 1, #list do
        if (list[i].layer or 0) == n then
            result[#result + 1] = list[i]
        end
    end
    return result
end

--- Check whether a specific object is present in the container.
--- @tparam table obj The object to look up.
--- @treturn boolean `true` if the object is in the container.
function ObjectContainer:has(obj)
    local list = self._objects
    for i = 1, #list do
        if list[i] == obj then
            return true
        end
    end
    return false
end

return scene_objects
