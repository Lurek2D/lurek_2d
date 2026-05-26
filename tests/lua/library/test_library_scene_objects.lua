--- Tests for library.scene-objects
--- Covers: new, add, remove, clear, count, has, update order,
---          draw order (layered), getByLayer.
-- @testCategory library

require("tests/lua/init")
local sceneobj = require("library/scene-objects")

-- ── Helper: make a stub object ────────────────────────────────────────────────

local function make_obj(name, layer, opts)
    opts = opts or {}
    local log = {}
    local obj = { name = name, layer = layer, _log = log }
    if opts.update ~= false then
        obj.update = function(self, dt)
            log[#log + 1] = { event = "update", dt = dt }
        end
    end
    if opts.draw ~= false then
        obj.draw = function(self)
            log[#log + 1] = { event = "draw" }
        end
    end
    return obj
end

-- ── new / count ───────────────────────────────────────────────────────────────

-- @describe scene_objects.new
describe("scene_objects.new", function()
    -- @library lurek.library_scene_objects
    it("returns an empty container", function()
        local w = sceneobj.new()
        expect_equal(w:count(), 0)
    end)

    -- @library lurek.library_scene_objects
    it("two calls return independent containers", function()
        local a = sceneobj.new()
        local b = sceneobj.new()
        a:add(make_obj("x", 0))
        expect_equal(a:count(), 1)
        expect_equal(b:count(), 0)
    end)
end)


-- ── add / count / has ─────────────────────────────────────────────────────────

-- @describe add
describe("add", function()
    -- @library lurek.library_scene_objects
    it("increments count", function()
        local w = sceneobj.new()
        w:add(make_obj("a", 0))
        expect_equal(w:count(), 1)
        w:add(make_obj("b", 1))
        expect_equal(w:count(), 2)
    end)

    -- @library lurek.library_scene_objects
    it("has returns true for added object", function()
        local w   = sceneobj.new()
        local obj = make_obj("a", 0)
        w:add(obj)
        expect_equal(w:has(obj), true)
    end)

    -- @library lurek.library_scene_objects
    it("has returns false for unknown object", function()
        local w   = sceneobj.new()
        local obj = make_obj("a", 0)
        expect_equal(w:has(obj), false)
    end)

    -- @library lurek.library_scene_objects
    it("defaults layer to 0 when not set", function()
        local w   = sceneobj.new()
        local obj = {}         -- no layer field
        w:add(obj)
        local layer0 = w:getByLayer(0)
        expect_equal(#layer0, 1)
        expect_equal(layer0[1], obj)
    end)
end)

-- ── remove ────────────────────────────────────────────────────────────────────

-- @describe remove
describe("remove", function()
    -- @library lurek.library_scene_objects
    it("decrements count", function()
        local w   = sceneobj.new()
        local obj = make_obj("a", 0)
        w:add(obj)
        w:remove(obj)
        expect_equal(w:count(), 0)
    end)

    -- @library lurek.library_scene_objects
    it("has returns false after remove", function()
        local w   = sceneobj.new()
        local obj = make_obj("a", 0)
        w:add(obj)
        w:remove(obj)
        expect_equal(w:has(obj), false)
    end)

    -- @library lurek.library_scene_objects
    it("removing unknown object is a no-op", function()
        local w   = sceneobj.new()
        local obj = make_obj("a", 0)
        w:add(obj)
        local other = make_obj("b", 0)
        w:remove(other)  -- should not error or change count
        expect_equal(w:count(), 1)
    end)

    -- @library lurek.library_scene_objects
    it("removes only the matching object by identity", function()
        local w  = sceneobj.new()
        local a  = make_obj("a", 0)
        local b  = make_obj("b", 0)
        w:add(a)
        w:add(b)
        w:remove(a)
        expect_equal(w:count(), 1)
        expect_equal(w:has(b), true)
    end)
end)

-- ── clear ─────────────────────────────────────────────────────────────────────

-- @describe clear
describe("clear", function()
    -- @library lurek.library_scene_objects
    it("empties the container", function()
        local w = sceneobj.new()
        w:add(make_obj("a", 0))
        w:add(make_obj("b", 1))
        w:clear()
        expect_equal(w:count(), 0)
    end)

    -- @library lurek.library_scene_objects
    it("has returns false for previously added objects after clear", function()
        local w   = sceneobj.new()
        local obj = make_obj("a", 0)
        w:add(obj)
        w:clear()
        expect_equal(w:has(obj), false)
    end)
end)

-- ── update ────────────────────────────────────────────────────────────────────

-- @describe update
describe("update", function()
    -- @library lurek.library_scene_objects
    it("calls update on objects that have it", function()
        local w   = sceneobj.new()
        local obj = make_obj("a", 0)
        w:add(obj)
        w:update(0.016)
        expect_equal(#obj._log, 1)
        expect_equal(obj._log[1].event, "update")
    end)

    -- @library lurek.library_scene_objects
    it("passes dt to each object", function()
        local w   = sceneobj.new()
        local obj = make_obj("a", 0)
        w:add(obj)
        w:update(0.5)
        expect_equal(obj._log[1].dt, 0.5)
    end)

    -- @library lurek.library_scene_objects
    it("skips objects without update", function()
        local w   = sceneobj.new()
        local obj = make_obj("a", 0, { update = false })
        w:add(obj)
        w:update(0.016)  -- should not error
        expect_equal(#obj._log, 0)
    end)

    -- @library lurek.library_scene_objects
    it("updates in insertion order", function()
        local order = {}
        local w = sceneobj.new()

        -- Add in insertion order: first, second, third
        local first  = { layer = 2, update = function(self) order[#order+1] = "first"  end }
        local second = { layer = 0, update = function(self) order[#order+1] = "second" end }
        local third  = { layer = 1, update = function(self) order[#order+1] = "third"  end }

        w:add(first)
        w:add(second)
        w:add(third)
        w:update(0.016)

        -- update must respect insertion order regardless of layer
        expect_equal(order[1], "first")
        expect_equal(order[2], "second")
        expect_equal(order[3], "third")
    end)
end)

-- ── draw (layer sort) ─────────────────────────────────────────────────────────

-- @describe draw
describe("draw", function()
    -- @library lurek.library_scene_objects
    it("calls draw on objects that have it", function()
        local w   = sceneobj.new()
        local obj = make_obj("a", 0)
        w:add(obj)
        w:draw()
        local draw_events = {}
        for _, e in ipairs(obj._log) do
            if e.event == "draw" then draw_events[#draw_events+1] = e end
        end
        expect_equal(#draw_events, 1)
    end)

    -- @library lurek.library_scene_objects
    it("draws in ascending layer order", function()
        local draw_order = {}
        local w = sceneobj.new()

        local hi  = { layer = 10, draw = function(self) draw_order[#draw_order+1] = "hi"  end }
        local lo  = { layer =  0, draw = function(self) draw_order[#draw_order+1] = "lo"  end }
        local mid = { layer =  5, draw = function(self) draw_order[#draw_order+1] = "mid" end }

        -- Add in reverse layer order to confirm sorting, not insertion order
        w:add(hi)
        w:add(lo)
        w:add(mid)
        w:draw()

        expect_equal(draw_order[1], "lo")
        expect_equal(draw_order[2], "mid")
        expect_equal(draw_order[3], "hi")
    end)

    -- @library lurek.library_scene_objects
    it("objects on the same layer draw in insertion order", function()
        local draw_order = {}
        local w = sceneobj.new()

        local a = { layer = 1, draw = function() draw_order[#draw_order+1] = "a" end }
        local b = { layer = 1, draw = function() draw_order[#draw_order+1] = "b" end }
        local c = { layer = 1, draw = function() draw_order[#draw_order+1] = "c" end }

        w:add(a)
        w:add(b)
        w:add(c)
        w:draw()

        expect_equal(draw_order[1], "a")
        expect_equal(draw_order[2], "b")
        expect_equal(draw_order[3], "c")
    end)

    -- @library lurek.library_scene_objects
    it("skips objects without draw", function()
        local w   = sceneobj.new()
        local obj = make_obj("a", 0, { draw = false })
        w:add(obj)
        w:draw()  -- should not error
        expect_equal(#obj._log, 0)
    end)
end)

-- ── getByLayer ────────────────────────────────────────────────────────────────

-- @describe getByLayer
describe("getByLayer", function()
    -- @library lurek.library_scene_objects
    it("returns all objects on the requested layer", function()
        local w  = sceneobj.new()
        local a  = make_obj("a", 2)
        local b  = make_obj("b", 2)
        local c  = make_obj("c", 5)
        w:add(a)
        w:add(b)
        w:add(c)
        local result = w:getByLayer(2)
        expect_equal(#result, 2)
    end)

    -- @library lurek.library_scene_objects
    it("returns empty table when no objects are on that layer", function()
        local w = sceneobj.new()
        w:add(make_obj("a", 0))
        local result = w:getByLayer(99)
        expect_equal(#result, 0)
    end)

    -- @library lurek.library_scene_objects
    it("treats missing layer as 0", function()
        local w   = sceneobj.new()
        local obj = {}  -- no layer field
        w:add(obj)
        local result = w:getByLayer(0)
        expect_equal(#result, 1)
        expect_equal(result[1], obj)
    end)
end)

-- ── draw cache consistency after mutations ────────────────────────────────────

-- @describe draw cache invalidation
describe("draw cache invalidation", function()
    -- @library lurek.library_scene_objects
    it("respects layer after add following draw", function()
        local draw_order = {}
        local w = sceneobj.new()

        local lo = { layer = 0, draw = function() draw_order[#draw_order+1] = "lo" end }
        local hi = { layer = 9, draw = function() draw_order[#draw_order+1] = "hi" end }

        w:add(hi)
        w:draw()  -- caches [hi]

        w:add(lo)
        w:draw()  -- must rebuild: lo draws before hi

        -- Second draw produced two events (first drew only hi)
        expect_equal(draw_order[#draw_order - 1], "lo")
        expect_equal(draw_order[#draw_order],     "hi")
    end)

    -- @library lurek.library_scene_objects
    it("removes object from draw output after remove", function()
        local drawn = {}
        local w = sceneobj.new()

        local a = { layer = 0, draw = function() drawn[#drawn+1] = "a" end }
        local b = { layer = 1, draw = function() drawn[#drawn+1] = "b" end }

        w:add(a)
        w:add(b)
        w:draw()  -- a, b

        w:remove(a)
        drawn = {}
        w:draw()  -- must only draw b

        expect_equal(#drawn, 1)
        expect_equal(drawn[1], "b")
    end)
end)

test_summary()
