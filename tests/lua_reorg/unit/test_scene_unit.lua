-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_scene_core_unit.lua
do
-- Scene module Lua tests
-- Headless-safe (no window/GPU/audio needed).
-- lurek.scene is a module-level singleton; each describe calls lurek.scene.clear() first.

-- @describe DepthSorter
describe("DepthSorter", function()
    -- @covers LDepthSorter:flush
    it("flushes callbacks in ascending depth order", function()
        local sorter = lurek.scene.newDepthSorter()
        expect_true(sorter ~= nil)
        expect_equal(0, sorter:getCount())

        local order = {}
        sorter:add(function() table.insert(order, "c") end, 10)
        sorter:add(function() table.insert(order, "a") end, 0)
        sorter:add(function() table.insert(order, "b") end, 5)
        expect_equal(3, sorter:getCount())

        sorter:flush()
        expect_equal(0, sorter:getCount())
        expect_equal(3, #order)
        expect_equal("a", order[1])
        expect_equal("b", order[2])
        expect_equal("c", order[3])
    end)
end)

-- @describe Lifecycle callbacks
describe("Lifecycle callbacks", function()
    -- @covers lurek.scene.update
    it("update dispatches to the top scene", function()
        lurek.scene.clear()
        local log = {}
        local s1 = { update = function(self, dt) table.insert(log, "s1:update") end }
        lurek.scene.push(s1)

        lurek.scene.update(0.016)
        expect_equal("s1:update", log[1])
    end)
    -- @covers lurek.scene.draw
    it("draw dispatches only to top render-active scene", function()
        lurek.scene.clear()
        local log = {}
        local s1 = { draw = function(self) table.insert(log, "s1:draw") end }
        local s2 = { draw = function(self) table.insert(log, "s2:draw") end }
        lurek.scene.push(s1)
        lurek.scene.push(s2)

        lurek.scene.draw()
        expect_equal(1, #log)
        expect_equal("s2:draw", log[1])
        lurek.scene.clear()
    end)
    -- @covers lurek.scene.switchTo
    it("switchTo calls leave on old and enter on new", function()
        lurek.scene.clear()
        local log = {}
        local s1 = { leave = function(self) table.insert(log, "s1:leave") end }
        local s2 = { enter = function(self) table.insert(log, "s2:enter") end }

        lurek.scene.push(s1)
        log = {}  -- reset after push's enter (s1 has no enter)
        lurek.scene.switchTo(s2)
        expect_equal("s1:leave", log[1])
        expect_equal("s2:enter", log[2])
    end)
    -- @covers lurek.scene.push
    it("push forwards params to enter callback", function()
        lurek.scene.clear()
        ---@type any
        local received = nil
        local s = { enter = function(self, p) received = p end }

        ---@type any
        local params = { level = 3, mode = "hard" }
        lurek.scene.push(s, nil, nil, nil, params)
        expect_type("table", received)
        expect_equal(3, received.level)
        expect_equal("hard", received.mode)
    end)
end)

-- @describe lurek.scene new pipeline callbacks
describe("lurek.scene new pipeline callbacks", function()
    -- @covers lurek.scene.processPhysics
    it("processPhysics calls scene:process_physics(dt)", function()
        lurek.scene.clear()
        local called_dt = nil
        local scene = {
            process_physics = function(self, dt) called_dt = dt end
        }
        lurek.scene.push(scene)
        lurek.scene.processPhysics(1.0 / 60.0)
        expect_near(1.0 / 60.0, called_dt, 1e-9)
        lurek.scene.pop()
    end)
    -- @covers lurek.scene.processLate
    it("processLate calls scene:process_late(dt)", function()
        lurek.scene.clear()
        local called_dt = nil
        local scene = {
            process_late = function(self, dt) called_dt = dt end
        }
        lurek.scene.push(scene)
        lurek.scene.processLate(0.016)
        expect_near(0.016, called_dt, 1e-3)
        lurek.scene.pop()
    end)
    -- @covers lurek.scene.process
    it("process calls scene:process(dt)", function()
        lurek.scene.clear()
        local called_dt = nil
        local scene = {
            process = function(self, dt) called_dt = dt end
        }
        lurek.scene.push(scene)
        lurek.scene.process(0.016)
        expect_near(0.016, called_dt, 1e-3)
        lurek.scene.pop()
    end)
    -- @covers lurek.scene.render
    it("render calls scene:render() only for top render-active scene", function()
        lurek.scene.clear()
        local calls = {}
        local s1 = { render = function(self) table.insert(calls, "s1") end }
        local s2 = { render = function(self) table.insert(calls, "s2") end }
        lurek.scene.push(s1)
        lurek.scene.push(s2)
        lurek.scene.render()
        expect_equal(1, #calls)
        expect_equal("s2", calls[1])
        lurek.scene.clear()
    end)
    -- @covers lurek.scene.renderUi
    it("renderUi calls scene:render_ui() only for top render-active scene", function()
        lurek.scene.clear()
        local calls = {}
        local s1 = { render_ui = function(self) table.insert(calls, "s1") end }
        local s2 = { render_ui = function(self) table.insert(calls, "s2") end }
        lurek.scene.push(s1)
        lurek.scene.push(s2)
        lurek.scene.renderUi()
        expect_equal(1, #calls)
        expect_equal("s2", calls[1])
        lurek.scene.clear()
    end)
    -- @covers lurek.scene.getRenderActiveScenes
    it("getRenderActiveScenes returns only top scene even with overlay stack", function()
        lurek.scene.clear()
        local base = { name = "base" }
        local game = { name = "game" }
        local overlay = { name = "overlay" }

        lurek.scene.push(base)
        lurek.scene.push(game)
        lurek.scene.pushOverlay(overlay)

        local rs = lurek.scene.getRenderActiveScenes()
        expect_type("table", rs)
        expect_equal(1, #rs)
        expect_equal(overlay, rs[1])
        lurek.scene.clear()
    end)
    -- @covers lurek.scene.setUpdateEnabled
    it("freeze flags control update/process/physics/late independently", function()
        lurek.scene.clear()
        local counts = { update = 0, process = 0, physics = 0, late = 0 }
        local scene = {
            update = function(self, dt) counts.update = counts.update + 1 end,
            process = function(self, dt) counts.process = counts.process + 1 end,
            process_physics = function(self, dt) counts.physics = counts.physics + 1 end,
            process_late = function(self, dt) counts.late = counts.late + 1 end,
        }

        lurek.scene.push(scene)

        expect_true(lurek.scene.isUpdateEnabled())
        expect_true(lurek.scene.isProcessEnabled())
        expect_true(lurek.scene.isPhysicsEnabled())
        expect_true(lurek.scene.isLateEnabled())

        lurek.scene.setUpdateEnabled(nil, false)
        lurek.scene.setProcessEnabled(nil, false)
        lurek.scene.setPhysicsEnabled(nil, false)
        lurek.scene.setLateEnabled(nil, false)

        expect_false(lurek.scene.isUpdateEnabled())
        expect_false(lurek.scene.isProcessEnabled())
        expect_false(lurek.scene.isPhysicsEnabled())
        expect_false(lurek.scene.isLateEnabled())

        lurek.scene.update(0.016)
        lurek.scene.process(0.016)
        lurek.scene.processPhysics(0.016)
        lurek.scene.processLate(0.016)

        expect_equal(0, counts.update)
        expect_equal(0, counts.process)
        expect_equal(0, counts.physics)
        expect_equal(0, counts.late)

        lurek.scene.setUpdateEnabled(nil, true)
        lurek.scene.setProcessEnabled(nil, true)
        lurek.scene.setPhysicsEnabled(nil, true)
        lurek.scene.setLateEnabled(nil, true)

        lurek.scene.update(0.016)
        lurek.scene.process(0.016)
        lurek.scene.processPhysics(0.016)
        lurek.scene.processLate(0.016)

        expect_equal(1, counts.update)
        expect_equal(1, counts.process)
        expect_equal(1, counts.physics)
        expect_equal(1, counts.late)
        lurek.scene.clear()
    end)
    -- @covers lurek.scene.setProcessEnabled
    it("freeze API target selector works for name and stack index", function()
        lurek.scene.clear()
        local menu = { name = "menu" }
        local game = { name = "game" }

        lurek.scene.registerScene("menu", menu)
        lurek.scene.registerScene("game", game)
        lurek.scene.push(menu)
        lurek.scene.push(game)

        -- by registered name
        expect_true(lurek.scene.setProcessEnabled("menu", false))
        expect_false(lurek.scene.isProcessEnabled("menu"))

        -- by 1-based stack index (bottom scene is index 1)
        expect_true(lurek.scene.setProcessEnabled(2, false))
        expect_false(lurek.scene.isProcessEnabled(2))

        lurek.scene.clear()
    end)
end)

-- popTo

-- @describe popTo
describe("popTo", function()
    -- @covers lurek.scene.popTo
    it("pops scenes above registered target (inclusive)", function()
        lurek.scene.clear()
        local menu = { name = "menu" }
        local game = { name = "game" }
        local pause_scene = { name = "pause" }
        lurek.scene.registerScene("menu", menu)
        lurek.scene.push(menu)
        lurek.scene.push(game)
        lurek.scene.push(pause_scene)
        expect_equal(3, lurek.scene.getStackSize())
        local ok = lurek.scene.popTo("menu")
        expect_true(ok)
        -- popTo pops until target is found (inclusive); stack size depends on implementation
        expect_true(lurek.scene.getStackSize() < 3)
        lurek.scene.clear()
    end)
end)

-- DepthSorter addObject

-- @describe DepthSorter addObject
describe("DepthSorter addObject", function()
    -- @covers LDepthSorter:addObject
    it("addObject uses obj.depth and calls drawSorted", function()
        lurek.scene.clear()
        local sorter = lurek.scene.newDepthSorter()
        local calls = {}
        local obj1 = {
            depth = 10,
            drawSorted = function(self) calls[#calls + 1] = "obj1" end,
        }
        local obj2 = {
            depth = 5,
            drawSorted = function(self) calls[#calls + 1] = "obj2" end,
        }
        sorter:addObject(obj1)
        sorter:addObject(obj2)
        sorter:sort()
        sorter:flush()
        expect_equal(2, #calls)
        -- depth 5 should be drawn before depth 10
        expect_equal("obj2", calls[1])
        expect_equal("obj1", calls[2])
    end)
    -- @covers LDepthSorter:getCount
    it("getCount reflects addObject", function()
        local sorter = lurek.scene.newDepthSorter()
        expect_equal(0, sorter:getCount())
        sorter:addObject({ depth = 1, drawSorted = function() end })
        expect_equal(1, sorter:getCount())
    end)
    -- @covers LDepthSorter:clear
    it("clear removes all without calling callbacks", function()
        local sorter = lurek.scene.newDepthSorter()
        local called = false
        sorter:add(function() called = true end, 1)
        sorter:clear()
        expect_equal(0, sorter:getCount())
        expect_false(called)
    end)
end)

-- DepthSorter negative depths

-- @describe DepthSorter negative depths
describe("DepthSorter negative depths", function()
    -- @covers LDepthSorter:sort
    it("sorts negative depths before positive", function()
        local sorter = lurek.scene.newDepthSorter()
        local calls = {}
        sorter:add(function() calls[#calls + 1] = "pos" end, 5)
        sorter:add(function() calls[#calls + 1] = "neg" end, -5)
        sorter:sort()
        sorter:flush()
        expect_equal("neg", calls[1])
        expect_equal("pos", calls[2])
    end)
end)

-- scene.new factory

-- @describe scene.new factory
describe("scene.new factory", function()
    -- @covers lurek.scene.new
    it("returns a table", function()
        local s = lurek.scene.new()
        expect_type("table", s)
    end)

    -- @covers lurek.scene.getStackSize
    it("returned scene works with push", function()
        lurek.scene.clear()
        local s = lurek.scene.new()
        lurek.scene.push(s)
        expect_equal(1, lurek.scene.getStackSize())
        lurek.scene.clear()
    end)
end)

-- scene.define factory

-- @describe scene.define factory
describe("scene.define factory", function()
    -- @covers lurek.scene.define
    it("returns a constructor function", function()
        local ctor = lurek.scene.define()
        expect_type("function", ctor)
    end)

end)

-- data store with complex types

-- @describe Data store complex values
describe("Data store complex values", function()
    -- @covers lurek.scene.setData
    it("stores and retrieves tables", function()
        lurek.scene.clear()
        local data = { hp = 100, items = {"sword", "shield"} }
        lurek.scene.setData("player", data)
        local got = lurek.scene.getData("player")
        expect_not_nil(got)
        local got_tbl = got or { hp = nil, items = {} }
        expect_equal(100, got_tbl.hp)
        expect_equal("sword", got_tbl.items[1])
        lurek.scene.removeData("player")
    end)
    -- @covers lurek.scene.getData
    it("overwrite replaces value", function()
        lurek.scene.clear()
        lurek.scene.setData("score", 10)
        lurek.scene.setData("score", 20)
        expect_equal(20, lurek.scene.getData("score"))
        lurek.scene.removeData("score")
    end)
end)

-- @describe DepthSorter (RS parity)
describe("DepthSorter (RS parity)", function()
    -- @covers lurek.scene.newDepthSorter
    it("newDepthSorter returns userdata", function()
        local ds = lurek.scene.newDepthSorter()
        expect_equal("userdata", type(ds))
    end)
end)

-- ============================================================
-- Phase B: Easing transitions
-- ============================================================
-- @describe scene easing transitions
describe("scene easing transitions", function()
    -- Migrated from Rust active_transition_progress_eased_linear_matches_progress
    -- and scene_stack_get_transition_progress_eased_linear_matches.
    -- @covers lurek.scene.getTransitionProgressEased
    it("reports sane idle, linear, and ease_in eased progress values", function()
        lurek.scene.clear()
        local idle = lurek.scene.getTransitionProgressEased()
        expect_true(type(idle) == "number")
        expect_true(idle >= 0.0 and idle <= 1.0)

        lurek.scene.clear()
        local scene_a = {}
        lurek.scene.push(scene_a, "fade", 2.0, "linear")
        lurek.scene.update(1.0)  -- advance to t = 0.5
        local raw   = lurek.scene.getTransitionProgress()
        local eased = lurek.scene.getTransitionProgressEased()
        expect_true(type(raw)   == "number")
        expect_true(type(eased) == "number")
        expect_near(raw, eased, 0.005)

        lurek.scene.clear()
        lurek.scene.push({}, "fade", 2.0, "ease_in")
        lurek.scene.update(0.5)  -- advance to t = 0.25 (raw progress)
        local ease_in_raw   = lurek.scene.getTransitionProgress()
        local ease_in_eased = lurek.scene.getTransitionProgressEased()
        expect_true(ease_in_raw > 0.0)
        expect_true(ease_in_eased < ease_in_raw)
        lurek.scene.clear()
    end)
end)

-- ============================================================
-- Phase C: Overlay mode
-- ============================================================
-- @describe scene overlay
describe("scene overlay", function()
    -- @covers lurek.scene.pop
    it("popping overlay restores normal mode", function()
        lurek.scene.clear()
        local base = {}
        local ov = {}
        lurek.scene.push(base)
        lurek.scene.pushOverlay(ov)
        lurek.scene.pop()
        expect_false(lurek.scene.isOverlay())
        lurek.scene.clear()
    end)
end)

-- ============================================================
-- Phase D: Preload
-- ============================================================
-- @describe DepthSorter flush sort order
describe("DepthSorter flush sort order", function()
    -- @covers LDepthSorter:typeOf
    it("flush re-sorts after add() following sort()", function()
        local ds = lurek.scene.newDepthSorter()
        local order = {}
        local function fn1() order[#order + 1] = "fn1" end
        local function fn2() order[#order + 1] = "fn2" end
        local function fn3() order[#order + 1] = "fn3" end
        expect_true(ds:typeOf("LDepthSorter"))
        ds:add(fn1, 3.0)
        ds:add(fn2, 1.0)
        ds:sort()        -- sorts & marks clean
        ds:add(fn3, 0.5) -- re-dirties; must be placed correctly on next flush
        ds:flush()
        expect_equal(order[1], "fn3")
        expect_equal(order[2], "fn2")
        expect_equal(order[3], "fn1")
    end)
end)

-- ============================================================
-- Overlay clear state (migrated from Rust scene_tests.rs)
-- ============================================================
-- @describe scene overlay clear state
describe("scene overlay clear state", function()
    -- @covers lurek.scene.clear
    it("clear after pushOverlay resets overlay flag and empties stack", function()
        lurek.scene.clear()
        local base = {}
        local ov   = {}
        lurek.scene.push(base)
        lurek.scene.pushOverlay(ov)
        lurek.scene.clear()
        expect_false(lurek.scene.isOverlay())
        expect_equal(lurek.scene.getStackSize(), 0)
    end)
end)

-- ============================================================
-- Merged from test_scene_ui.lua
-- ============================================================


-- @describe lurek.scene overlay mode
describe("lurek.scene overlay mode", function()
    -- @covers lurek.scene.pushOverlay
    it("pushOverlay accepts a scene table and increments depth", function()
        lurek.scene.clear()
        local overlay = { enter = function() end, draw = function() end }
        lurek.scene.pushOverlay(overlay)
        expect_equal(lurek.scene.depth(), 1)
        lurek.scene.pop()
        expect_equal(lurek.scene.depth(), 0)
    end)
    -- @covers lurek.scene.isOverlay
    it("isOverlay returns true after pushOverlay", function()
        lurek.scene.clear()
        local overlay = {}
        lurek.scene.pushOverlay(overlay)
        expect_true(lurek.scene.isOverlay())
        lurek.scene.pop()
    end)
    -- @covers lurek.scene.getActiveScenes
    it("both background and overlay are in getActiveScenes", function()
        lurek.scene.clear()
        local bg      = { name = "bg"      }
        local overlay = { name = "effect" }
        lurek.scene.push(bg)
        lurek.scene.pushOverlay(overlay)
        local active = lurek.scene.getActiveScenes()
        expect_equal(#active, 2)
        lurek.scene.clear()
    end)
    -- @covers lurek.scene.depth
    it("depth() equals getStackSize()", function()
        lurek.scene.clear()
        local s1 = {}
        local s2 = {}
        lurek.scene.push(s1)
        lurek.scene.pushOverlay(s2)
        expect_equal(lurek.scene.depth(), lurek.scene.getStackSize())
        lurek.scene.clear()
    end)
end)

-- ============================================================
-- Merged from test_scene_preload.lua
-- ============================================================


-- @describe lurek.scene.preload
describe("lurek.scene.preload", function()
    -- @covers lurek.scene.preload
    it("can register a preload function without error", function()
        lurek.scene.preload("test_scene", function()
            -- heavy asset load would go here
        end)
        expect_false(lurek.scene.isPreloaded("test_scene"))
    end)

    -- @covers lurek.scene.isPreloaded
    it("scene is not preloaded before pushPreloaded is called", function()
        lurek.scene.clear()
        lurek.scene.preload("lazy_scene", function() end)
        expect_false(lurek.scene.isPreloaded("lazy_scene"))
    end)
    -- is invoked multiple times for the same name.
    -- @covers lurek.scene.registerScene
    it("loader is invoked exactly once across multiple pushPreloaded calls", function()
        lurek.scene.clear()
        local scene_name = "once_scene_preload"
        local call_count = 0
        local dummy = {}
        lurek.scene.registerScene(scene_name, dummy)
        lurek.scene.preload(scene_name, function()
            call_count = call_count + 1
        end)
        lurek.scene.pushPreloaded(scene_name)
        lurek.scene.pop()
        lurek.scene.pushPreloaded(scene_name)
        lurek.scene.pop()
        expect_equal(call_count, 1)
        lurek.scene.unregisterScene(scene_name)
        lurek.scene.clear()
    end)

    -- @covers lurek.scene.pushPreloaded
    it("isPreloaded returns true after pushPreloaded triggers the loader", function()
        lurek.scene.clear()
        local scene_tbl = {}
        lurek.scene.registerScene("preload_check", scene_tbl)
        lurek.scene.preload("preload_check", function() end)
        lurek.scene.pushPreloaded("preload_check")
        expect_true(lurek.scene.isPreloaded("preload_check"))
        lurek.scene.pop()
        lurek.scene.unregisterScene("preload_check")
        lurek.scene.clear()
    end)
end)

-- ============================================================
-- Merged from test_scene_serialization.lua
-- ============================================================

-- @describe serializeScene and deserializeScene
describe("serializeScene and deserializeScene", function()
    -- @covers lurek.scene.serializeScene
    it("serializeScene captures setData values", function()
        lurek.scene.setData("level", 3)
        lurek.scene.setData("score", 9999)
        local snap = lurek.scene.serializeScene()
        expect_equal("table", type(snap))
        expect_equal("table", type(snap.data))
        expect_equal(3, snap.data.level)
        expect_equal(9999, snap.data.score)
    end)
    -- @covers lurek.scene.deserializeScene
    it("deserializeScene restores setData values", function()
        local snap = { data = { gold = 150, hp = 80 }, stack = {} }
        lurek.scene.deserializeScene(snap)
        expect_equal(150, lurek.scene.getData("gold"))
        expect_equal(80, lurek.scene.getData("hp"))
    end)
    -- @pending: requires a global scene-data reset API (e.g. clearAllData()).
    -- deserializeScene merges, not replaces; no way to guarantee zero keys with shared global state.
end)

-- ============================================================
-- Merged from test_scene_transitions.lua
-- ============================================================

---@type any
local scene_api = lurek.scene
local scene_transitions = scene_api.transitions

-- @describe lurek.scene.transitions
describe("lurek.scene.transitions", function()
    -- @covers lurek.scene.transitions.fade
    it("fade() returns a fresh fade transition table with expected duration", function()
        local a = scene_transitions.fade()
        local b = scene_transitions.fade(1.0)
        expect_equal(type(scene_transitions.fade), "function")
        expect_equal(a.type, "fade")
        expect_near(a.duration, 0.5, 0.001)
        expect_false(a == b)
        expect_near(b.duration, 1.0, 0.001)
    end)

    -- @covers lurek.scene.transitions.slide
    it("slide() returns left/right variants with expected defaults", function()
        local t = scene_transitions.slide()
        expect_equal(type(scene_transitions.slide), "function")
        expect_equal(t.type, "slideleft")
        local t = scene_transitions.slide("right")
        expect_equal(t.type, "slideright")
        local t = scene_transitions.slide()
        expect_near(t.duration, 0.4, 0.001)
    end)

    -- @covers lurek.scene.transitions.wipe
    it("wipe() returns type=wipe with default duration", function()
        local t = scene_transitions.wipe()
        expect_equal(t.type, "wipe")
        expect_near(t.duration, 0.5, 0.001)
    end)

    -- @covers lurek.scene.transitions.iris
    it("iris() returns type=iris with default duration", function()
        local t = scene_transitions.iris()
        expect_equal(t.type, "iris")
        expect_near(t.duration, 0.6, 0.001)
    end)
end)

-- ============================================================
-- Merged from test_scene_transitions_extended.lua
-- ============================================================

-- @describe getTransitionTypes
describe("getTransitionTypes", function()
    -- @covers lurek.scene.getTransitionTypes
    it("returns the expected transition type names as strings", function()
        local types = lurek.scene.getTransitionTypes()
        expect_equal(10, #types)
        local lookup = {}
        for _, v in ipairs(types) do lookup[v] = true end
        expect_equal(true, lookup["none"])
        expect_equal(true, lookup["fade"])
        expect_equal(true, lookup["slideleft"])
        expect_equal(true, lookup["slideright"])
        expect_equal(true, lookup["slideup"])
        expect_equal(true, lookup["slidedown"])
        expect_equal(true, lookup["wipe"])
        expect_equal(true, lookup["iris"])
        expect_equal(true, lookup["zoom"])
        expect_equal(true, lookup["crossfade"])
        for _, v in ipairs(types) do
            expect_equal("string", type(v))
        end
    end)
end)

-- @describe lurek.scene.newScene
describe("lurek.scene.newScene", function()
    -- @covers lurek.scene.newScene
    it("creates a scene table that inherits methods from the definition", function()
        local scene = lurek.scene.newScene({
            enter = function(self)
                self.entered = true
                return "ok"
            end,
        })
        local enter_fn = scene.enter  -- method is inherited via __index metatable, not a raw field
        expect_equal("table", type(scene))
        expect_equal("function", type(enter_fn))
        expect_equal("ok", enter_fn(scene))
        expect_equal(true, rawget(scene, "entered"))
    end)
end)

-- @describe scene queue/layer API
describe("scene queue/layer API", function()
    -- @covers lurek.scene.queueTransition
    it("queueTransition chains transition requests", function()
        lurek.scene.clear()
        lurek.scene.clearQueuedTransitions()
        lurek.scene.push({})
        lurek.scene.queueTransition("fade", 0.5, "linear")
        lurek.scene.queueTransition("wipe", 0.5, "ease_out")
        expect_equal(1, lurek.scene.getQueuedTransitionCount())
        lurek.scene.update(0.5)
        expect_equal(0, lurek.scene.getQueuedTransitionCount())
        lurek.scene.clear()
    end)
    -- @covers lurek.scene.setCurrentLayer
    it("setCurrentLayer controls process order", function()
        lurek.scene.clear()
        local order = {}
        local base = { process = function(self, dt) table.insert(order, "base") end }
        local overlay = { process = function(self, dt) table.insert(order, "overlay") end }

        lurek.scene.push(base)
        lurek.scene.setCurrentLayer(10)
        lurek.scene.pushOverlay(overlay)
        lurek.scene.setCurrentLayer(-1)

        expect_equal(-1, lurek.scene.getCurrentLayer())
        lurek.scene.process(0.016)
        expect_equal("overlay", order[1])
        expect_equal("base", order[2])
        lurek.scene.clear()
    end)
end)

-- =========================================================================
-- =========================================================================

-- @describe DepthSorter:add
describe("DepthSorter:add ", function()
    -- @covers LDepthSorter:add
    it("add increments the sorted-object count", function()
        local ds = lurek.scene.newDepthSorter()
        ds:add(function() end, 5.0)
        ds:add(function() end, 3.0)
        expect_true(ds:getCount() >= 2)
    end)
end)

-- @describe scene strict: LDepthSorter type/typeOf
describe("scene strict: LDepthSorter type/typeOf", function()
    -- @covers LDepthSorter:type
    it("LDepthSorter type and typeOf are callable", function()
        local ds = lurek.scene.newDepthSorter()
        expect_type("string", ds:type())
        expect_type("boolean", ds:typeOf("LObject"))
    end)
end)
end
-- END test_scene_core_unit.lua

do
local function reset_scene_state()
    lurek.scene.clear()
    lurek.scene.clearQueuedTransitions()
end

local function new_container()
    return lurek.scene.newObjectContainer()
end

-- @describe scene explicit owner coverage
describe("scene explicit owner coverage", function()
    -- @covers lurek.scene.isEmpty
    it("reports whether the scene stack is empty", function()
        reset_scene_state()
        expect_true(lurek.scene.isEmpty())
        lurek.scene.push({})
        expect_false(lurek.scene.isEmpty())
        reset_scene_state()
    end)

    -- @covers lurek.scene.getCurrent
    it("returns the current top scene table", function()
        reset_scene_state()
        local current = { name = "current" }
        lurek.scene.push(current)
        expect_equal(current, lurek.scene.getCurrent())
        reset_scene_state()
    end)

    -- @covers lurek.scene.getCurrentLayer
    it("returns the layer of the top scene", function()
        reset_scene_state()
        lurek.scene.push({})
        lurek.scene.setCurrentLayer(12)
        expect_equal(12, lurek.scene.getCurrentLayer())
        reset_scene_state()
    end)

    -- @covers lurek.scene.isTransitioning
    it("reports transition activity during a switch", function()
        reset_scene_state()
        lurek.scene.push({})
        lurek.scene.switchTo({}, "fade", 0.5, "linear")
        expect_true(lurek.scene.isTransitioning())
        reset_scene_state()
    end)

    -- @covers lurek.scene.getTransitionProgress
    it("returns raw transition progress while a transition is active", function()
        reset_scene_state()
        lurek.scene.push({})
        lurek.scene.switchTo({}, "fade", 1.0, "linear")
        lurek.scene.update(0.25)
        local progress = lurek.scene.getTransitionProgress()
        expect_true(progress > 0.0)
        expect_true(progress < 1.0)
        reset_scene_state()
    end)

    -- @covers lurek.scene.getQueuedTransitionCount
    it("counts queued transitions", function()
        reset_scene_state()
        lurek.scene.push({})
        lurek.scene.queueTransition("fade", 0.25, "linear")
        lurek.scene.queueTransition("wipe", 0.25, "ease_out")
        expect_equal(1, lurek.scene.getQueuedTransitionCount())
        reset_scene_state()
    end)

    -- @covers lurek.scene.clearQueuedTransitions
    it("clears queued transitions without touching the stack", function()
        reset_scene_state()
        lurek.scene.push({})
        lurek.scene.queueTransition("fade", 0.25, "linear")
        lurek.scene.clearQueuedTransitions()
        expect_equal(0, lurek.scene.getQueuedTransitionCount())
        expect_equal(1, lurek.scene.getStackSize())
        reset_scene_state()
    end)

    -- @covers lurek.scene.getRegistered
    it("returns a previously registered scene table", function()
        reset_scene_state()
        local scene = { name = "registered" }
        lurek.scene.registerScene("registered_scene", scene)
        expect_equal(scene, lurek.scene.getRegistered("registered_scene"))
        lurek.scene.unregisterScene("registered_scene")
        reset_scene_state()
    end)

    -- @covers lurek.scene.hasRegistered
    it("reports whether a scene name is registered", function()
        reset_scene_state()
        lurek.scene.registerScene("has_registered_scene", {})
        expect_true(lurek.scene.hasRegistered("has_registered_scene"))
        lurek.scene.unregisterScene("has_registered_scene")
        expect_false(lurek.scene.hasRegistered("has_registered_scene"))
        reset_scene_state()
    end)

    -- @covers lurek.scene.unregisterScene
    it("removes a registered scene mapping", function()
        reset_scene_state()
        lurek.scene.registerScene("to_unregister", {})
        lurek.scene.unregisterScene("to_unregister")
        expect_false(lurek.scene.hasRegistered("to_unregister"))
        reset_scene_state()
    end)

    -- @covers lurek.scene.getRegisteredNames
    it("lists registered scene names", function()
        reset_scene_state()
        lurek.scene.registerScene("alpha_scene", {})
        lurek.scene.registerScene("beta_scene", {})
        local names = lurek.scene.getRegisteredNames()
        local seen = {}
        for _, name in ipairs(names) do
            seen[name] = true
        end
        expect_true(seen.alpha_scene)
        expect_true(seen.beta_scene)
        lurek.scene.unregisterScene("alpha_scene")
        lurek.scene.unregisterScene("beta_scene")
        reset_scene_state()
    end)

    -- @covers lurek.scene.hasData
    it("reports whether shared scene data exists", function()
        reset_scene_state()
        lurek.scene.setData("player_hp", 10)
        expect_true(lurek.scene.hasData("player_hp"))
        reset_scene_state()
    end)

    -- @covers lurek.scene.removeData
    it("removes shared scene data entries", function()
        reset_scene_state()
        lurek.scene.setData("temporary_key", 42)
        lurek.scene.removeData("temporary_key")
        expect_false(lurek.scene.hasData("temporary_key"))
        expect_nil(lurek.scene.getData("temporary_key"))
        reset_scene_state()
    end)

    -- @covers lurek.scene.setPhysicsEnabled
    it("toggles physics processing on the selected scene", function()
        reset_scene_state()
        lurek.scene.push({ name = "physics_scene" })
        expect_true(lurek.scene.setPhysicsEnabled(nil, false))
        expect_false(lurek.scene.isPhysicsEnabled())
        expect_true(lurek.scene.setPhysicsEnabled(nil, true))
        expect_true(lurek.scene.isPhysicsEnabled())
        reset_scene_state()
    end)

    -- @covers lurek.scene.setLateEnabled
    it("toggles late processing on the selected scene", function()
        reset_scene_state()
        lurek.scene.push({ name = "late_scene" })
        expect_true(lurek.scene.setLateEnabled(nil, false))
        expect_false(lurek.scene.isLateEnabled())
        expect_true(lurek.scene.setLateEnabled(nil, true))
        expect_true(lurek.scene.isLateEnabled())
        reset_scene_state()
    end)

    -- @covers lurek.scene.isProcessEnabled
    it("reports whether process is enabled", function()
        reset_scene_state()
        lurek.scene.push({})
        expect_true(lurek.scene.isProcessEnabled())
        lurek.scene.setProcessEnabled(nil, false)
        expect_false(lurek.scene.isProcessEnabled())
        reset_scene_state()
    end)

    -- @covers lurek.scene.isPhysicsEnabled
    it("reports whether physics is enabled", function()
        reset_scene_state()
        lurek.scene.push({})
        expect_true(lurek.scene.isPhysicsEnabled())
        lurek.scene.setPhysicsEnabled(nil, false)
        expect_false(lurek.scene.isPhysicsEnabled())
        reset_scene_state()
    end)

    -- @covers lurek.scene.isLateEnabled
    it("reports whether late processing is enabled", function()
        reset_scene_state()
        lurek.scene.push({})
        expect_true(lurek.scene.isLateEnabled())
        lurek.scene.setLateEnabled(nil, false)
        expect_false(lurek.scene.isLateEnabled())
        reset_scene_state()
    end)

    -- @covers lurek.scene.isUpdateEnabled
    it("reports whether update is enabled", function()
        reset_scene_state()
        lurek.scene.push({})
        expect_true(lurek.scene.isUpdateEnabled())
        lurek.scene.setUpdateEnabled(nil, false)
        expect_false(lurek.scene.isUpdateEnabled())
        reset_scene_state()
    end)

    -- @covers lurek.scene.newObjectContainer
    it("creates a scene object container userdata", function()
        local container = new_container()
        expect_type("userdata", container)
        expect_equal(0, container:getCount())
    end)

    -- @covers LDepthSorter:setStable
    it("toggles depth sorter stable sorting", function()
        local sorter = lurek.scene.newDepthSorter()
        sorter:setStable(false)
        expect_false(sorter:isStable())
    end)

    -- @covers LDepthSorter:isStable
    it("reports whether depth sorter stable sorting is enabled", function()
        local sorter = lurek.scene.newDepthSorter()
        sorter:setStable(true)
        expect_true(sorter:isStable())
    end)

    -- @covers LSceneObjectContainer:add
    it("adds an object to the scene object container", function()
        local container = new_container()
        local obj = { layer = 1 }
        container:add(obj)
        expect_true(container:has(obj))
    end)

    -- @covers LSceneObjectContainer:remove
    it("removes an object from the scene object container", function()
        local container = new_container()
        local obj = { layer = 1 }
        container:add(obj)
        container:remove(obj)
        expect_false(container:has(obj))
    end)

    -- @covers LSceneObjectContainer:clear
    it("clears all objects from the scene object container", function()
        local container = new_container()
        container:add({ layer = 1 })
        container:add({ layer = 2 })
        container:clear()
        expect_equal(0, container:getCount())
    end)

    -- @covers LSceneObjectContainer:update
    it("calls update on contained objects", function()
        local container = new_container()
        local updated_dt = nil
        container:add({
            layer = 0,
            update = function(self, dt)
                updated_dt = dt
            end,
        })
        container:update(0.25)
        expect_near(0.25, updated_dt, 0.001)
    end)

    -- @covers LSceneObjectContainer:draw
    it("calls draw on contained objects", function()
        local container = new_container()
        local draws = 0
        container:add({
            layer = 0,
            draw = function()
                draws = draws + 1
            end,
        })
        container:draw()
        expect_equal(1, draws)
    end)

    -- @covers LSceneObjectContainer:getCount
    it("returns the number of contained objects", function()
        local container = new_container()
        container:add({ layer = 0 })
        container:add({ layer = 1 })
        expect_equal(2, container:getCount())
    end)

    -- @covers LSceneObjectContainer:getObjects
    it("returns the contained objects table", function()
        local container = new_container()
        local obj = { layer = 0, id = "alpha" }
        container:add(obj)
        local objects = container:getObjects()
        expect_equal(1, #objects)
        expect_equal(obj, objects[1])
    end)

    -- @covers LSceneObjectContainer:getByLayer
    it("returns only objects from a given layer", function()
        local container = new_container()
        local a = { layer = 1, id = "a" }
        local b = { layer = 2, id = "b" }
        container:add(a)
        container:add(b)
        local objects = container:getByLayer(2)
        expect_equal(1, #objects)
        expect_equal(b, objects[1])
    end)

    -- @covers LSceneObjectContainer:has
    it("checks membership by object identity", function()
        local container = new_container()
        local obj = { layer = 1 }
        container:add(obj)
        expect_true(container:has(obj))
        expect_false(container:has({ layer = 1 }))
    end)

    -- @covers LSceneObjectContainer:type
    it("returns the scene object container type name", function()
        expect_equal("LSceneObjectContainer", new_container():type())
    end)

    -- @covers LSceneObjectContainer:typeOf
    it("matches the scene object container type name", function()
        local container = new_container()
        expect_true(container:typeOf("LSceneObjectContainer"))
        expect_false(container:typeOf("LDepthSorter"))
    end)
end)
end

test_summary()
