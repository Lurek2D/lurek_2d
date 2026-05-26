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

-- ── Public API ────────────────────────────────────────────────────────────────

--- Add an object to the container.
-- Objects missing a `layer` field are treated as layer 0.
--- @tparam table obj Any table.  Optional fields: `draw`, `update`, `layer`.
function ObjectContainer:add(obj)
    self._objects[#self._objects + 1] = obj
    self._dirty = true
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
        if type(obj.update) == "function" then
            obj:update(dt)
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
        if type(obj.draw) == "function" then
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
