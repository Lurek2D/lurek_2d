-- tests/lua/test_patterns.lua
-- BDD-style integration tests for lurek.patterns module

-- ===================================================================
-- EventBus
-- ===================================================================

-- @description Covers suite: lurek.patterns.newEventBus.
describe("lurek.patterns.newEventBus", function()
    -- @covers lurek.patterns.newEventBus
    -- @covers lurek.patterns.EventBus.type
    -- @covers lurek.patterns.EventBus.typeOf
    -- @covers lurek.patterns.newCommandStack
    -- @covers lurek.patterns.newFactory
    -- @covers lurek.patterns.newObjectPool
    -- @covers lurek.patterns.newServiceLocator
    -- @covers lurek.patterns.newSimpleState
    -- @description Verifies newEventBus returns EventBus userdata with working type checks.
    it("creates an EventBus with type/typeOf", function()
        local bus = lurek.patterns.newEventBus()
        expect_equal(bus:type(), "EventBus")
        expect_true(bus:typeOf("EventBus"))
        expect_true(bus:typeOf("Object"))
    end)

    -- @covers lurek.patterns.newEventBus
    -- @covers lurek.patterns.EventBus.on
    -- @covers lurek.patterns.EventBus.emit
    -- @description Verifies EventBus:on registers listeners that EventBus:emit invokes with payload data.
    it("on/emit fires callbacks", function()
        local bus = lurek.patterns.newEventBus()
        local received = nil
        bus:on("ping", function(val) received = val end)
        bus:emit("ping", 42)
        expect_equal(received, 42)
    end)

    -- @covers lurek.patterns.newEventBus
    -- @covers lurek.patterns.EventBus.on
    -- @description Verifies EventBus:on returns distinct subscription IDs for separate listeners.
    it("on returns unique subscription IDs", function()
        local bus = lurek.patterns.newEventBus()
        local id1 = bus:on("a", function() end)
        local id2 = bus:on("a", function() end)
        expect_true(id1 ~= id2)
    end)

    -- @covers lurek.patterns.newEventBus
    -- @covers lurek.patterns.EventBus.on
    -- @covers lurek.patterns.EventBus.emit
    -- @description Verifies EventBus executes listeners in priority order.
    it("listeners fire in priority order", function()
        local bus = lurek.patterns.newEventBus()
        local order = {}
        bus:on("act", function() table.insert(order, "low") end, 10)
        bus:on("act", function() table.insert(order, "high") end, -5)
        bus:on("act", function() table.insert(order, "mid") end, 0)
        bus:emit("act")
        expect_equal(order[1], "high")
        expect_equal(order[2], "mid")
        expect_equal(order[3], "low")
    end)

    -- @covers lurek.patterns.newEventBus
    -- @covers lurek.patterns.EventBus.on
    -- @covers lurek.patterns.EventBus.off
    -- @covers lurek.patterns.EventBus.emit
    -- @description Verifies EventBus:off removes a listener so later emits do not invoke it.
    it("off removes a listener by ID", function()
        local bus = lurek.patterns.newEventBus()
        local count = 0
        local id = bus:on("tick", function() count = count + 1 end)
        bus:emit("tick")
        expect_equal(count, 1)
        bus:off(id)
        bus:emit("tick")
        expect_equal(count, 1)
    end)

    -- @covers lurek.patterns.newEventBus
    -- @covers lurek.patterns.EventBus.on
    -- @covers lurek.patterns.EventBus.clear
    -- @covers lurek.patterns.EventBus.getListenerCount
    -- @description Verifies EventBus:clear removes all listeners for one event without affecting others.
    it("clear removes all listeners for an event", function()
        local bus = lurek.patterns.newEventBus()
        bus:on("x", function() end)
        bus:on("x", function() end)
        bus:on("y", function() end)
        expect_equal(bus:getListenerCount("x"), 2)
        bus:clear("x")
        expect_equal(bus:getListenerCount("x"), 0)
        expect_equal(bus:getListenerCount("y"), 1)
    end)

    -- @covers lurek.patterns.newEventBus
    -- @covers lurek.patterns.EventBus.on
    -- @covers lurek.patterns.EventBus.clearAll
    -- @covers lurek.patterns.EventBus.getListenerCount
    -- @description Verifies EventBus:clearAll removes listeners across every event.
    it("clearAll removes all listeners", function()
        local bus = lurek.patterns.newEventBus()
        bus:on("a", function() end)
        bus:on("b", function() end)
        bus:clearAll()
        expect_equal(bus:getListenerCount("a"), 0)
        expect_equal(bus:getListenerCount("b"), 0)
    end)

    -- @covers lurek.patterns.newEventBus
    -- @covers lurek.patterns.EventBus.on
    -- @covers lurek.patterns.EventBus.getEvents
    -- @description Verifies EventBus:getEvents returns the names of events with registered listeners.
    it("getEvents lists event names with listeners", function()
        local bus = lurek.patterns.newEventBus()
        bus:on("alpha", function() end)
        bus:on("beta", function() end)
        local events = bus:getEvents()
        expect_equal(#events, 2)
    end)
end)

-- ===================================================================
-- ObjectPool
-- ===================================================================
-- @description Covers suite: lurek.patterns.newObjectPool.
describe("lurek.patterns.newObjectPool", function()
    -- @covers lurek.patterns.newObjectPool
    -- @covers lurek.patterns.ObjectPool.type
    -- @covers lurek.patterns.ObjectPool.typeOf
    -- @description Verifies newObjectPool returns ObjectPool userdata with working type helpers.
    it("creates an ObjectPool with correct type", function()
        local pool = lurek.patterns.newObjectPool()
        expect_equal(pool:type(), "ObjectPool")
        expect_true(pool:typeOf("ObjectPool"))
    end)

    -- @covers lurek.patterns.newObjectPool
    -- @covers lurek.patterns.ObjectPool.add
    -- @covers lurek.patterns.ObjectPool.acquire
    -- @covers lurek.patterns.ObjectPool.getAvailableCount
    -- @covers lurek.patterns.ObjectPool.getActiveCount
    -- @description Verifies ObjectPool add and acquire update available and active counts correctly.
    it("add/acquire round-trips objects", function()
        local pool = lurek.patterns.newObjectPool()
        pool:add("bullet1")
        pool:add("bullet2")
        expect_equal(pool:getAvailableCount(), 2)
        local obj = pool:acquire()
        expect_true(obj ~= nil)
        expect_equal(pool:getActiveCount(), 1)
        expect_equal(pool:getAvailableCount(), 1)
    end)

    -- @covers lurek.patterns.newObjectPool
    -- @covers lurek.patterns.ObjectPool.acquire
    -- @description Verifies ObjectPool:acquire returns nil when no pooled objects exist.
    it("acquire returns nil on empty pool", function()
        local pool = lurek.patterns.newObjectPool()
        local obj = pool:acquire()
        expect_nil(obj)
    end)

    -- @covers lurek.patterns.newObjectPool
    -- @covers lurek.patterns.ObjectPool.add
    -- @covers lurek.patterns.ObjectPool.acquire
    -- @covers lurek.patterns.ObjectPool.release
    -- @covers lurek.patterns.ObjectPool.getActiveCount
    -- @covers lurek.patterns.ObjectPool.getAvailableCount
    -- @description Verifies ObjectPool:release returns an acquired object back to the available pool.
    it("release returns object to pool", function()
        local pool = lurek.patterns.newObjectPool()
        pool:add("item")
        local obj = pool:acquire()
        expect_equal(pool:getActiveCount(), 1)
        pool:release(obj)
        expect_equal(pool:getActiveCount(), 0)
        expect_equal(pool:getAvailableCount(), 1)
    end)

    -- @covers lurek.patterns.newObjectPool
    -- @covers lurek.patterns.ObjectPool.add
    -- @covers lurek.patterns.ObjectPool.acquire
    -- @covers lurek.patterns.ObjectPool.getTotalCount
    -- @description Verifies ObjectPool:getTotalCount reports active plus available objects.
    it("getTotalCount sums active + available", function()
        local pool = lurek.patterns.newObjectPool()
        pool:add("a")
        pool:add("b")
        pool:acquire()
        expect_equal(pool:getTotalCount(), 2)
    end)

    -- @covers lurek.patterns.newObjectPool
    -- @covers lurek.patterns.ObjectPool.add
    -- @covers lurek.patterns.ObjectPool.acquire
    -- @covers lurek.patterns.ObjectPool.clearAll
    -- @covers lurek.patterns.ObjectPool.getTotalCount
    -- @description Verifies ObjectPool:clearAll resets all stored and active objects.
    it("clearAll resets everything", function()
        local pool = lurek.patterns.newObjectPool()
        pool:add("x")
        pool:acquire()
        pool:add("y")
        pool:clearAll()
        expect_equal(pool:getTotalCount(), 0)
    end)
end)

-- ===================================================================
-- CommandStack
-- ===================================================================
-- @description Covers suite: lurek.patterns.newCommandStack.
describe("lurek.patterns.newCommandStack", function()
    -- @covers lurek.patterns.newCommandStack
    -- @covers lurek.patterns.CommandStack.type
    -- @covers lurek.patterns.CommandStack.typeOf
    -- @description Verifies newCommandStack returns CommandStack userdata with working type checks.
    it("creates a CommandStack with correct type", function()
        local cmds = lurek.patterns.newCommandStack()
        expect_equal(cmds:type(), "CommandStack")
        expect_true(cmds:typeOf("CommandStack"))
    end)

    -- @covers lurek.patterns.newCommandStack
    -- @covers lurek.patterns.CommandStack.execute
    -- @description Verifies CommandStack:execute runs the forward command immediately.
    it("execute runs the command immediately", function()
        local cmds = lurek.patterns.newCommandStack()
        local x = 0
        cmds:execute("inc", function() x = x + 1 end)
        expect_equal(x, 1)
    end)

    -- @covers lurek.patterns.newCommandStack
    -- @covers lurek.patterns.CommandStack.execute
    -- @covers lurek.patterns.CommandStack.undo
    -- @description Verifies CommandStack:undo invokes the stored reverse operation for the latest command.
    it("undo reverses the last command", function()
        local cmds = lurek.patterns.newCommandStack()
        local x = 0
        cmds:execute("inc", function() x = x + 10 end, function() x = x - 10 end)
        expect_equal(x, 10)
        local ok = cmds:undo()
        expect_true(ok)
        expect_equal(x, 0)
    end)

    -- @covers lurek.patterns.newCommandStack
    -- @covers lurek.patterns.CommandStack.execute
    -- @covers lurek.patterns.CommandStack.undo
    -- @covers lurek.patterns.CommandStack.redo
    -- @description Verifies CommandStack:redo replays an undone command.
    it("redo re-executes after undo", function()
        local cmds = lurek.patterns.newCommandStack()
        local x = 0
        cmds:execute("inc", function() x = x + 5 end, function() x = x - 5 end)
        cmds:undo()
        expect_equal(x, 0)
        local ok = cmds:redo()
        expect_true(ok)
        expect_equal(x, 5)
    end)

    -- @covers lurek.patterns.newCommandStack
    -- @covers lurek.patterns.CommandStack.execute
    -- @covers lurek.patterns.CommandStack.undo
    -- @covers lurek.patterns.CommandStack.canUndo
    -- @covers lurek.patterns.CommandStack.canRedo
    -- @description Verifies canUndo and canRedo track command history state changes.
    it("canUndo/canRedo report correctly", function()
        local cmds = lurek.patterns.newCommandStack()
        expect_false(cmds:canUndo())
        expect_false(cmds:canRedo())
        cmds:execute("a", function() end, function() end)
        expect_true(cmds:canUndo())
        expect_false(cmds:canRedo())
        cmds:undo()
        expect_false(cmds:canUndo())
        expect_true(cmds:canRedo())
    end)

    -- @covers lurek.patterns.newCommandStack
    -- @covers lurek.patterns.CommandStack.execute
    -- @covers lurek.patterns.CommandStack.undo
    -- @covers lurek.patterns.CommandStack.canRedo
    -- @covers lurek.patterns.CommandStack.getHistorySize
    -- @description Verifies executing a new command after undo truncates redo history.
    it("execute after undo truncates redo history", function()
        local cmds = lurek.patterns.newCommandStack()
        local x = 0
        cmds:execute("a", function() x = x + 1 end, function() x = x - 1 end)
        cmds:execute("b", function() x = x + 10 end, function() x = x - 10 end)
        cmds:undo()
        cmds:execute("c", function() x = x + 100 end, function() x = x - 100 end)
        expect_false(cmds:canRedo())
        expect_equal(cmds:getHistorySize(), 2)
    end)

    -- @covers lurek.patterns.newCommandStack
    -- @covers lurek.patterns.CommandStack.execute
    -- @covers lurek.patterns.CommandStack.getCurrentName
    -- @description Verifies getCurrentName reflects the most recently executed command name.
    it("getCurrentName returns the last command name", function()
        local cmds = lurek.patterns.newCommandStack()
        expect_nil(cmds:getCurrentName())
        cmds:execute("move", function() end)
        expect_equal(cmds:getCurrentName(), "move")
    end)

    -- @covers lurek.patterns.newCommandStack
    -- @covers lurek.patterns.CommandStack.execute
    -- @covers lurek.patterns.CommandStack.clearAll
    -- @covers lurek.patterns.CommandStack.getHistorySize
    -- @covers lurek.patterns.CommandStack.canUndo
    -- @description Verifies CommandStack:clearAll removes all history and undo state.
    it("clearAll resets the stack", function()
        local cmds = lurek.patterns.newCommandStack()
        cmds:execute("a", function() end, function() end)
        cmds:execute("b", function() end, function() end)
        cmds:clearAll()
        expect_equal(cmds:getHistorySize(), 0)
        expect_false(cmds:canUndo())
    end)
end)

-- ===================================================================
-- ServiceLocator
-- ===================================================================
-- @description Covers suite: lurek.patterns.newServiceLocator.
describe("lurek.patterns.newServiceLocator", function()
    -- @covers lurek.patterns.newServiceLocator
    -- @covers lurek.patterns.ServiceLocator.type
    -- @covers lurek.patterns.ServiceLocator.typeOf
    -- @description Verifies newServiceLocator returns ServiceLocator userdata with working type helpers.
    it("creates a ServiceLocator with correct type", function()
        local sl = lurek.patterns.newServiceLocator()
        expect_equal(sl:type(), "ServiceLocator")
        expect_true(sl:typeOf("ServiceLocator"))
    end)

    -- @covers lurek.patterns.newServiceLocator
    -- @covers lurek.patterns.ServiceLocator.provide
    -- @covers lurek.patterns.ServiceLocator.has
    -- @covers lurek.patterns.ServiceLocator.locate
    -- @description Verifies provide stores a service and locate retrieves it by name.
    it("provide/locate stores and retrieves values", function()
        local sl = lurek.patterns.newServiceLocator()
        sl:provide("logger", { log = function() end })
        expect_true(sl:has("logger"))
        local svc = sl:locate("logger")
        expect_true(svc ~= nil)
    end)

    -- @covers lurek.patterns.newServiceLocator
    -- @covers lurek.patterns.ServiceLocator.locate
    -- @description Verifies locate returns nil for an unregistered service name.
    it("locate returns nil for unknown service", function()
        local sl = lurek.patterns.newServiceLocator()
        local svc = sl:locate("missing")
        expect_nil(svc)
    end)

    -- @covers lurek.patterns.newServiceLocator
    -- @covers lurek.patterns.ServiceLocator.provide
    -- @covers lurek.patterns.ServiceLocator.has
    -- @covers lurek.patterns.ServiceLocator.remove
    -- @description Verifies remove unregisters a previously provided service.
    it("remove deletes a service", function()
        local sl = lurek.patterns.newServiceLocator()
        sl:provide("db", "connection")
        expect_true(sl:has("db"))
        sl:remove("db")
        expect_false(sl:has("db"))
    end)

    -- @covers lurek.patterns.newServiceLocator
    -- @covers lurek.patterns.ServiceLocator.provide
    -- @covers lurek.patterns.ServiceLocator.getServices
    -- @description Verifies getServices returns the set of registered service names.
    it("getServices lists all names", function()
        local sl = lurek.patterns.newServiceLocator()
        sl:provide("a", 1)
        sl:provide("b", 2)
        local names = sl:getServices()
        expect_equal(#names, 2)
    end)

    -- @covers lurek.patterns.newServiceLocator
    -- @covers lurek.patterns.ServiceLocator.provide
    -- @covers lurek.patterns.ServiceLocator.clearAll
    -- @covers lurek.patterns.ServiceLocator.has
    -- @description Verifies clearAll removes every registered service.
    it("clearAll removes everything", function()
        local sl = lurek.patterns.newServiceLocator()
        sl:provide("x", 1)
        sl:provide("y", 2)
        sl:clearAll()
        expect_false(sl:has("x"))
        expect_false(sl:has("y"))
    end)
end)

-- ===================================================================
-- Factory
-- ===================================================================
-- @description Covers suite: lurek.patterns.newFactory.
describe("lurek.patterns.newFactory", function()
    -- @covers lurek.patterns.newFactory
    -- @covers lurek.patterns.Factory.type
    -- @covers lurek.patterns.Factory.typeOf
    -- @description Verifies newFactory returns Factory userdata with working type helpers.
    it("creates a Factory with correct type", function()
        local f = lurek.patterns.newFactory()
        expect_equal(f:type(), "Factory")
        expect_true(f:typeOf("Factory"))
    end)

    -- @covers lurek.patterns.newFactory
    -- @covers lurek.patterns.Factory.register
    -- @covers lurek.patterns.Factory.create
    -- @description Verifies register and create build objects using the named factory callback.
    it("register/create builds objects", function()
        local f = lurek.patterns.newFactory()
        f:register("bullet", function(x, y)
            return { x = x, y = y, kind = "bullet" }
        end)
        local b = f:create("bullet", 10, 20)
        expect_equal(b.x, 10)
        expect_equal(b.y, 20)
        expect_equal(b.kind, "bullet")
    end)

    -- @covers lurek.patterns.newFactory
    -- @covers lurek.patterns.Factory.has
    -- @covers lurek.patterns.Factory.register
    -- @description Verifies has reflects whether a named factory type has been registered.
    it("has checks type registration", function()
        local f = lurek.patterns.newFactory()
        expect_false(f:has("nope"))
        f:register("enemy", function() return {} end)
        expect_true(f:has("enemy"))
    end)

    -- @covers lurek.patterns.newFactory
    -- @covers lurek.patterns.Factory.register
    -- @covers lurek.patterns.Factory.getTypes
    -- @description Verifies getTypes returns the registered factory type names.
    it("getTypes lists registered types", function()
        local f = lurek.patterns.newFactory()
        f:register("a", function() end)
        f:register("b", function() end)
        local types = f:getTypes()
        expect_equal(#types, 2)
    end)

    -- @covers lurek.patterns.newFactory
    -- @covers lurek.patterns.Factory.register
    -- @covers lurek.patterns.Factory.remove
    -- @covers lurek.patterns.Factory.has
    -- @description Verifies remove unregisters a factory type.
    it("remove unregisters a type", function()
        local f = lurek.patterns.newFactory()
        f:register("temp", function() end)
        f:remove("temp")
        expect_false(f:has("temp"))
    end)

    -- @covers lurek.patterns.newFactory
    -- @covers lurek.patterns.Factory.register
    -- @covers lurek.patterns.Factory.clearAll
    -- @covers lurek.patterns.Factory.getTypes
    -- @description Verifies clearAll removes every registered factory type.
    it("clearAll removes all types", function()
        local f = lurek.patterns.newFactory()
        f:register("a", function() end)
        f:register("b", function() end)
        f:clearAll()
        expect_equal(#f:getTypes(), 0)
    end)
end)

-- ===================================================================
-- SimpleState (FSM)
-- ===================================================================
-- @description Covers suite: lurek.patterns.newSimpleState.
describe("lurek.patterns.newSimpleState", function()
    -- @covers lurek.patterns.newSimpleState
    -- @covers lurek.patterns.SimpleState.type
    -- @covers lurek.patterns.SimpleState.typeOf
    -- @description Verifies newSimpleState returns SimpleState userdata with working type helpers.
    it("creates a SimpleState with correct type", function()
        local fsm = lurek.patterns.newSimpleState()
        expect_equal(fsm:type(), "SimpleState")
        expect_true(fsm:typeOf("SimpleState"))
    end)

    -- @covers lurek.patterns.newSimpleState
    -- @covers lurek.patterns.SimpleState.addState
    -- @covers lurek.patterns.SimpleState.transitionTo
    -- @covers lurek.patterns.SimpleState.getCurrent
    -- @description Verifies transitionTo activates registered states and updates the current state name.
    it("addState/transitionTo changes state", function()
        local fsm = lurek.patterns.newSimpleState()
        fsm:addState("idle")
        fsm:addState("walk")
        local ok = fsm:transitionTo("idle")
        expect_true(ok)
        expect_equal(fsm:getCurrent(), "idle")
        fsm:transitionTo("walk")
        expect_equal(fsm:getCurrent(), "walk")
    end)

    -- @covers lurek.patterns.newSimpleState
    -- @covers lurek.patterns.SimpleState.transitionTo
    -- @description Verifies transitionTo returns false when the target state is unknown.
    it("transitionTo returns false for unknown state", function()
        local fsm = lurek.patterns.newSimpleState()
        local ok = fsm:transitionTo("nonexistent")
        expect_false(ok)
    end)

    -- @covers lurek.patterns.newSimpleState
    -- @covers lurek.patterns.SimpleState.addState
    -- @covers lurek.patterns.SimpleState.transitionTo
    -- @description Verifies state enter and exit callbacks run during transitions.
    it("enter and exit callbacks fire on transition", function()
        local fsm = lurek.patterns.newSimpleState()
        local log = {}
        fsm:addState("a", {
            enter = function() table.insert(log, "enter_a") end,
            exit = function() table.insert(log, "exit_a") end,
        })
        fsm:addState("b", {
            enter = function() table.insert(log, "enter_b") end,
        })
        fsm:transitionTo("a")
        expect_equal(log[1], "enter_a")
        fsm:transitionTo("b")
        expect_equal(log[2], "exit_a")
        expect_equal(log[3], "enter_b")
    end)

    -- @covers lurek.patterns.newSimpleState
    -- @covers lurek.patterns.SimpleState.addState
    -- @covers lurek.patterns.SimpleState.transitionTo
    -- @covers lurek.patterns.SimpleState.update
    -- @description Verifies update forwards dt to the active state's update callback.
    it("update calls the current state update", function()
        local fsm = lurek.patterns.newSimpleState()
        local dt_received = nil
        fsm:addState("run", {
            update = function(dt) dt_received = dt end,
        })
        fsm:transitionTo("run")
        fsm:update(0.016)
        expect_true(math.abs(dt_received - 0.016) < 0.001)
    end)

    -- @covers lurek.patterns.newSimpleState
    -- @covers lurek.patterns.SimpleState.hasState
    -- @covers lurek.patterns.SimpleState.addState
    -- @description Verifies hasState reflects whether a state name has been registered.
    it("hasState checks registration", function()
        local fsm = lurek.patterns.newSimpleState()
        expect_false(fsm:hasState("jump"))
        fsm:addState("jump")
        expect_true(fsm:hasState("jump"))
    end)

    -- @covers lurek.patterns.newSimpleState
    -- @covers lurek.patterns.SimpleState.addState
    -- @covers lurek.patterns.SimpleState.getStates
    -- @description Verifies getStates returns all registered state names.
    it("getStates lists all state names", function()
        local fsm = lurek.patterns.newSimpleState()
        fsm:addState("idle")
        fsm:addState("walk")
        fsm:addState("run")
        local states = fsm:getStates()
        expect_equal(#states, 3)
    end)

    -- @covers lurek.patterns.newSimpleState
    -- @covers lurek.patterns.SimpleState.addState
    -- @covers lurek.patterns.SimpleState.transitionTo
    -- @covers lurek.patterns.SimpleState.clearAll
    -- @covers lurek.patterns.SimpleState.getCurrent
    -- @covers lurek.patterns.SimpleState.getStates
    -- @description Verifies clearAll removes states and resets the current-state pointer.
    it("clearAll resets the FSM", function()
        local fsm = lurek.patterns.newSimpleState()
        fsm:addState("a")
        fsm:addState("b")
        fsm:transitionTo("a")
        fsm:clearAll()
        expect_nil(fsm:getCurrent())
        expect_equal(#fsm:getStates(), 0)
    end)
end)

-- @description Covers suite: SimpleState extended coverage (RS parity).
describe("SimpleState extended coverage (RS parity)", function()
    -- @covers lurek.patterns.newSimpleState
    -- @covers lurek.patterns.SimpleState.hasState
    -- @description Verifies hasState returns false for names that were never registered.
    it("hasState returns false for unregistered state", function()
        local fsm = lurek.patterns.newSimpleState()
        expect_false(fsm:hasState("unknown"))
    end)

    -- @covers lurek.patterns.newSimpleState
    -- @covers lurek.patterns.SimpleState.update
    -- @description Verifies update is a no-op when no current state has been selected.
    it("update does not error with no current state", function()
        local fsm = lurek.patterns.newSimpleState()
        expect_no_error(function() fsm:update(0.016) end)
    end)

    -- @covers lurek.patterns.newSimpleState
    -- @covers lurek.patterns.SimpleState.addState
    -- @covers lurek.patterns.SimpleState.getCurrent
    -- @description Verifies getCurrent stays nil until transitionTo is called.
    it("getCurrent returns nil before any transition", function()
        local fsm = lurek.patterns.newSimpleState()
        fsm:addState("idle")
        expect_nil(fsm:getCurrent())
    end)

    -- @covers lurek.patterns.newSimpleState
    -- @covers lurek.patterns.SimpleState.addState
    -- @covers lurek.patterns.SimpleState.clearAll
    -- @covers lurek.patterns.SimpleState.getStates
    -- @description Verifies states can be added again cleanly after clearAll.
    it("clearAll followed by addState works cleanly", function()
        local fsm = lurek.patterns.newSimpleState()
        fsm:addState("a")
        fsm:clearAll()
        fsm:addState("b")
        expect_equal(1, #fsm:getStates())
    end)
end)

-- @description Covers suite: CommandStack undo/redo (RS parity).
describe("CommandStack undo/redo (RS parity)", function()
    -- @covers lurek.patterns.newCommandStack
    -- @covers lurek.patterns.CommandStack.execute
    -- @covers lurek.patterns.CommandStack.undo
    -- @covers lurek.patterns.CommandStack.redo
    -- @description Verifies a full undo and redo cycle restores the command effect.
    it("undo and redo cycle correctly", function()
        local cs = lurek.patterns.newCommandStack()
        local val = 0
        cs:execute("inc", function() val = val + 1 end, function() val = val - 1 end)
        expect_equal(1, val)
        cs:undo()
        expect_equal(0, val)
        cs:redo()
        expect_equal(1, val)
    end)

    -- @covers lurek.patterns.newCommandStack
    -- @covers lurek.patterns.CommandStack.getHistorySize
    -- @covers lurek.patterns.CommandStack.execute
    -- @description Verifies getHistorySize increments after command execution.
    it("getHistorySize reflects executed commands", function()
        local cs = lurek.patterns.newCommandStack()
        expect_equal(0, cs:getHistorySize())
        cs:execute("op", function() end, function() end)
        expect_equal(1, cs:getHistorySize())
    end)
end)
test_summary()
