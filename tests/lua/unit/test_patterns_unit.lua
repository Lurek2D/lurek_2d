-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_patterns_unit.lua
do
-- Canonical unit coverage for lurek.patterns.

-- @describe event bus
describe("event bus", function()
    -- @covers lurek.patterns.newEventBus
    it("newEventBus creates an event bus", function()
        expect_not_nil(lurek.patterns.newEventBus())
    end)

    -- @covers LEventBus:on
    it("on registers a listener and returns an id", function()
        local bus = lurek.patterns.newEventBus()
        expect_type("number", bus:on("ping", function() end))
    end)

    -- @covers LEventBus:emit
    it("emit dispatches to registered listeners", function()
        local bus = lurek.patterns.newEventBus()
        local value = nil
        bus:on("ping", function(v) value = v end)
        bus:emit("ping", 42)
        expect_equal(42, value)
    end)

    -- @covers LEventBus:off
    it("off removes a listener by id", function()
        local bus = lurek.patterns.newEventBus()
        local count = 0
        local id = bus:on("tick", function() count = count + 1 end)
        bus:emit("tick")
        bus:off(id)
        bus:emit("tick")
        expect_equal(1, count)
    end)

    -- @covers LEventBus:clear
    it("clear removes listeners for one event", function()
        local bus = lurek.patterns.newEventBus()
        bus:on("a", function() end)
        bus:on("a", function() end)
        bus:clear("a")
        expect_equal(0, bus:getListenerCount("a"))
    end)

    -- @covers LEventBus:getListenerCount
    it("getListenerCount returns listener count per event", function()
        local bus = lurek.patterns.newEventBus()
        bus:on("a", function() end)
        bus:on("a", function() end)
        expect_equal(2, bus:getListenerCount("a"))
    end)

    -- @covers LEventBus:clearAll
    it("clearAll removes all listeners", function()
        local bus = lurek.patterns.newEventBus()
        bus:on("a", function() end)
        bus:on("b", function() end)
        bus:clearAll()
        expect_equal(0, bus:getListenerCount("a"))
        expect_equal(0, bus:getListenerCount("b"))
    end)

    -- @covers LEventBus:getEvents
    it("getEvents returns event names with listeners", function()
        local bus = lurek.patterns.newEventBus()
        bus:on("alpha", function() end)
        bus:on("beta", function() end)
        local events = bus:getEvents()
        expect_type("table", events)
        expect_equal(2, #events)
    end)
end)

-- @describe object pool
describe("object pool", function()
    -- @covers lurek.patterns.newObjectPool
    it("newObjectPool creates a pool", function()
        expect_not_nil(lurek.patterns.newObjectPool())
    end)

    -- @covers LObjectPool:add
    it("add inserts an object into the available pool", function()
        local pool = lurek.patterns.newObjectPool()
        pool:add("bullet")
        expect_equal(1, pool:getAvailableCount())
    end)

    -- @covers LObjectPool:acquire
    it("acquire returns an available object", function()
        local pool = lurek.patterns.newObjectPool()
        pool:add("bullet")
        expect_equal("bullet", pool:acquire())
    end)

    -- @covers LObjectPool:release
    it("release returns an active object to the pool", function()
        local pool = lurek.patterns.newObjectPool()
        pool:add("bullet")
        local item = pool:acquire()
        pool:release(item)
        expect_equal(1, pool:getAvailableCount())
    end)

    -- @covers LObjectPool:getActiveCount
    it("getActiveCount tracks acquired objects", function()
        local pool = lurek.patterns.newObjectPool()
        pool:add("a")
        pool:acquire()
        expect_equal(1, pool:getActiveCount())
    end)

    -- @covers LObjectPool:getAvailableCount
    it("getAvailableCount tracks available objects", function()
        local pool = lurek.patterns.newObjectPool()
        pool:add("a")
        pool:add("b")
        pool:acquire()
        expect_equal(1, pool:getAvailableCount())
    end)

    -- @covers LObjectPool:getTotalCount
    it("getTotalCount returns active plus available", function()
        local pool = lurek.patterns.newObjectPool()
        pool:add("a")
        pool:add("b")
        pool:acquire()
        expect_equal(2, pool:getTotalCount())
    end)

    -- @covers LObjectPool:clearAll
    it("clearAll removes all pooled objects", function()
        local pool = lurek.patterns.newObjectPool()
        pool:add("a")
        pool:add("b")
        pool:clearAll()
        expect_equal(0, pool:getTotalCount())
    end)
end)

-- @describe command stack
describe("command stack", function()
    -- @covers lurek.patterns.newCommandStack
    it("newCommandStack creates a command stack", function()
        expect_not_nil(lurek.patterns.newCommandStack())
    end)

    -- @covers LCommandStack:execute
    it("execute runs the command immediately", function()
        local stack = lurek.patterns.newCommandStack()
        local value = 0
        stack:execute("inc", function() value = value + 1 end)
        expect_equal(1, value)
    end)

    -- @covers LCommandStack:undo
    it("undo reverses the most recent command", function()
        local stack = lurek.patterns.newCommandStack()
        local value = 0
        stack:execute("inc", function() value = value + 5 end, function() value = value - 5 end)
        expect_true(stack:undo())
        expect_equal(0, value)
    end)

    -- @covers LCommandStack:redo
    it("redo reapplies an undone command", function()
        local stack = lurek.patterns.newCommandStack()
        local value = 0
        stack:execute("inc", function() value = value + 5 end, function() value = value - 5 end)
        stack:undo()
        expect_true(stack:redo())
        expect_equal(5, value)
    end)

    -- @covers LCommandStack:canUndo
    it("canUndo reflects whether history exists", function()
        local stack = lurek.patterns.newCommandStack()
        stack:execute("noop", function() end, function() end)
        expect_true(stack:canUndo())
    end)

    -- @covers LCommandStack:canRedo
    it("canRedo reflects whether redo history exists", function()
        local stack = lurek.patterns.newCommandStack()
        stack:execute("noop", function() end, function() end)
        stack:undo()
        expect_true(stack:canRedo())
    end)

    -- @covers LCommandStack:getHistorySize
    it("getHistorySize returns executed command count", function()
        local stack = lurek.patterns.newCommandStack()
        stack:execute("a", function() end)
        stack:execute("b", function() end)
        expect_equal(2, stack:getHistorySize())
    end)

    -- @covers LCommandStack:getCurrentName
    it("getCurrentName returns the latest command name", function()
        local stack = lurek.patterns.newCommandStack()
        stack:execute("place", function() end)
        expect_equal("place", stack:getCurrentName())
    end)

    -- @covers LCommandStack:clearAll
    it("clearAll removes all history", function()
        local stack = lurek.patterns.newCommandStack()
        stack:execute("place", function() end)
        stack:clearAll()
        expect_equal(0, stack:getHistorySize())
    end)
end)

-- @describe services and factories
describe("services and factories", function()
    -- @covers lurek.patterns.newServiceLocator
    it("newServiceLocator creates a locator", function()
        expect_not_nil(lurek.patterns.newServiceLocator())
    end)

    -- @covers LServiceLocator:provide
    it("provide registers a service", function()
        local locator = lurek.patterns.newServiceLocator()
        locator:provide("audio", { enabled = true })
        expect_true(locator:has("audio"))
    end)

    -- @covers LServiceLocator:locate
    it("locate returns a provided service", function()
        local locator = lurek.patterns.newServiceLocator()
        locator:provide("audio", { enabled = true })
        expect_true(locator:locate("audio").enabled)
    end)

    -- @covers LServiceLocator:has
    it("has reports whether a service exists", function()
        local locator = lurek.patterns.newServiceLocator()
        locator:provide("audio", {})
        expect_true(locator:has("audio"))
    end)

    -- @covers LServiceLocator:remove
    it("remove unregisters a provided service", function()
        local locator = lurek.patterns.newServiceLocator()
        locator:provide("audio", {})
        locator:remove("audio")
        expect_false(locator:has("audio"))
    end)

    -- @covers LServiceLocator:getServices
    it("getServices returns a table of services", function()
        local locator = lurek.patterns.newServiceLocator()
        locator:provide("audio", {})
        expect_type("table", locator:getServices())
    end)

    -- @covers LServiceLocator:clearAll
    it("clearAll removes all services", function()
        local locator = lurek.patterns.newServiceLocator()
        locator:provide("audio", {})
        locator:provide("input", {})
        locator:clearAll()
        expect_false(locator:has("audio"))
    end)

    -- @covers lurek.patterns.newFactory
    it("newFactory creates a factory", function()
        expect_not_nil(lurek.patterns.newFactory())
    end)

    -- @covers LFactory:register
    it("register stores a constructor by name", function()
        local factory = lurek.patterns.newFactory()
        factory:register("enemy", function(name) return { name = name } end)
        expect_true(factory:has("enemy"))
    end)

    -- @covers LFactory:create
    it("create calls a registered constructor", function()
        local factory = lurek.patterns.newFactory()
        factory:register("enemy", function(name) return { name = name } end)
        expect_equal("orc", factory:create("enemy", "orc").name)
    end)

    -- @covers LFactory:has
    it("has reports whether a constructor exists", function()
        local factory = lurek.patterns.newFactory()
        factory:register("enemy", function() return {} end)
        expect_true(factory:has("enemy"))
    end)

    -- @covers LFactory:getTypes
    it("getTypes returns registered constructor names", function()
        local factory = lurek.patterns.newFactory()
        factory:register("enemy", function() return {} end)
        expect_equal(1, #factory:getTypes())
    end)

    -- @covers LFactory:remove
    it("remove unregisters a constructor", function()
        local factory = lurek.patterns.newFactory()
        factory:register("enemy", function() return {} end)
        factory:remove("enemy")
        expect_false(factory:has("enemy"))
    end)

    -- @covers LFactory:clearAll
    it("clearAll removes all constructors", function()
        local factory = lurek.patterns.newFactory()
        factory:register("enemy", function() return {} end)
        factory:clearAll()
        expect_equal(0, #factory:getTypes())
    end)

    -- @covers LFactory:alias
    it("alias maps an alias name to a registered constructor", function()
        local factory = lurek.patterns.newFactory()
        factory:register("enemy", function(name) return { name = name } end)
        factory:alias("foe", "enemy")
        expect_equal("orc", factory:create("foe", "orc").name)
    end)
end)

-- @describe simple state and strategy
describe("simple state and strategy", function()
    -- @covers lurek.patterns.newSimpleState
    it("newSimpleState creates a state machine", function()
        expect_not_nil(lurek.patterns.newSimpleState())
    end)

    -- @covers LSimpleState:addState
    it("addState registers a state", function()
        local fsm = lurek.patterns.newSimpleState()
        fsm:addState("idle")
        expect_true(fsm:hasState("idle"))
    end)

    -- @covers LSimpleState:getCurrent
    it("getCurrent returns the active state name", function()
        local fsm = lurek.patterns.newSimpleState()
        fsm:addState("idle")
        fsm:transitionTo("idle")
        expect_equal("idle", fsm:getCurrent())
    end)

    -- @covers LSimpleState:transitionTo
    it("transitionTo changes the active state", function()
        local fsm = lurek.patterns.newSimpleState()
        fsm:addState("idle")
        fsm:addState("run")
        fsm:transitionTo("run")
        expect_equal("run", fsm:getCurrent())
    end)

    -- @covers LSimpleState:update
    it("update calls the active state update callback", function()
        local fsm = lurek.patterns.newSimpleState()
        local dt_seen = 0
        fsm:addState("idle", {
            update = function(dt)
                dt_seen = dt
            end,
        })
        fsm:transitionTo("idle")
        fsm:update(0.5)
        expect_near(0.5, dt_seen, 0.001)
    end)

    -- @covers LSimpleState:hasState
    it("hasState reports whether a state exists", function()
        local fsm = lurek.patterns.newSimpleState()
        fsm:addState("idle")
        expect_true(fsm:hasState("idle"))
    end)

    -- @covers LSimpleState:getStates
    it("getStates returns registered state names", function()
        local fsm = lurek.patterns.newSimpleState()
        fsm:addState("idle")
        fsm:addState("run")
        expect_equal(2, #fsm:getStates())
    end)

    -- @covers LSimpleState:clearAll
    it("clearAll removes all states", function()
        local fsm = lurek.patterns.newSimpleState()
        fsm:addState("idle")
        fsm:clearAll()
        expect_equal(0, #fsm:getStates())
    end)

    -- @covers lurek.patterns.newStrategy
    it("newStrategy creates a strategy container", function()
        expect_not_nil(lurek.patterns.newStrategy())
    end)

    -- @covers LStrategy:register
    it("register stores a strategy callback", function()
        local strategy = lurek.patterns.newStrategy()
        strategy:register("double", function(v) return v * 2 end)
        expect_true(strategy:has("double"))
    end)

    -- @covers LStrategy:set
    it("set chooses the current strategy", function()
        local strategy = lurek.patterns.newStrategy()
        strategy:register("double", function(v) return v * 2 end)
        strategy:set("double")
        expect_equal("double", strategy:getCurrent())
    end)

    -- @covers LStrategy:execute
    it("execute calls the current strategy", function()
        local strategy = lurek.patterns.newStrategy()
        strategy:register("double", function(v) return v * 2 end)
        strategy:set("double")
        expect_equal(8, strategy:execute(4))
    end)

    -- @covers LStrategy:getCurrent
    it("getCurrent returns the current strategy name", function()
        local strategy = lurek.patterns.newStrategy()
        strategy:register("double", function(v) return v * 2 end)
        strategy:set("double")
        expect_equal("double", strategy:getCurrent())
    end)

    -- @covers LStrategy:has
    it("has reports whether a strategy exists", function()
        local strategy = lurek.patterns.newStrategy()
        strategy:register("double", function(v) return v * 2 end)
        expect_true(strategy:has("double"))
    end)

    -- @covers LStrategy:remove
    it("remove unregisters a strategy", function()
        local strategy = lurek.patterns.newStrategy()
        strategy:register("double", function(v) return v * 2 end)
        strategy:remove("double")
        expect_false(strategy:has("double"))
    end)

    -- @covers LStrategy:names
    it("names returns registered strategy names", function()
        local strategy = lurek.patterns.newStrategy()
        strategy:register("double", function(v) return v * 2 end)
        expect_equal(1, #strategy:names())
    end)

    -- @covers LStrategy:clear
    it("clear removes all strategies", function()
        local strategy = lurek.patterns.newStrategy()
        strategy:register("double", function(v) return v * 2 end)
        strategy:clear()
        expect_equal(0, #strategy:names())
    end)
end)

-- @describe linear containers
describe("linear containers", function()
    -- @covers lurek.patterns.newStack
    it("newStack creates a stack", function()
        expect_not_nil(lurek.patterns.newStack())
    end)

    -- @covers LStack:push
    it("push appends an item to the stack", function()
        local stack = lurek.patterns.newStack()
        stack:push("a")
        expect_equal(1, stack:len())
    end)

    -- @covers LStack:pop
    it("pop removes the top item from the stack", function()
        local stack = lurek.patterns.newStack()
        stack:push("a")
        expect_equal("a", stack:pop())
    end)

    -- @covers LStack:peek
    it("peek returns the top item without removal", function()
        local stack = lurek.patterns.newStack()
        stack:push("a")
        expect_equal("a", stack:peek())
    end)

    -- @covers LStack:len
    it("len returns the number of stack items", function()
        local stack = lurek.patterns.newStack()
        stack:push("a")
        stack:push("b")
        expect_equal(2, stack:len())
    end)

    -- @covers LStack:isEmpty
    it("isEmpty reports whether the stack is empty", function()
        expect_true(lurek.patterns.newStack():isEmpty())
    end)

    -- @covers LStack:isFull
    it("isFull reports capacity saturation", function()
        local stack = lurek.patterns.newStack(1)
        stack:push("a")
        expect_true(stack:isFull())
    end)

    -- @covers LStack:toArray
    it("toArray returns stack contents as a table", function()
        local stack = lurek.patterns.newStack()
        stack:push("a")
        stack:push("b")
        expect_equal(2, #stack:toArray())
    end)

    -- @covers LStack:clear
    it("clear removes all stack items", function()
        local stack = lurek.patterns.newStack()
        stack:push("a")
        stack:clear()
        expect_true(stack:isEmpty())
    end)

    -- @covers lurek.patterns.newQueue
    it("newQueue creates a queue", function()
        expect_not_nil(lurek.patterns.newQueue())
    end)

    -- @covers LQueue:enqueue
    it("enqueue appends an item to the queue", function()
        local queue = lurek.patterns.newQueue()
        queue:enqueue("a")
        expect_equal(1, queue:len())
    end)

    -- @covers LQueue:dequeue
    it("dequeue removes the front item from the queue", function()
        local queue = lurek.patterns.newQueue()
        queue:enqueue("a")
        expect_equal("a", queue:dequeue())
    end)

    -- @covers LQueue:front
    it("front returns the first queued item", function()
        local queue = lurek.patterns.newQueue()
        queue:enqueue("a")
        expect_equal("a", queue:front())
    end)

    -- @covers LQueue:back
    it("back returns the last queued item", function()
        local queue = lurek.patterns.newQueue()
        queue:enqueue("a")
        queue:enqueue("b")
        expect_equal("b", queue:back())
    end)

    -- @covers LQueue:len
    it("len returns queue length", function()
        local queue = lurek.patterns.newQueue()
        queue:enqueue("a")
        queue:enqueue("b")
        expect_equal(2, queue:len())
    end)

    -- @covers LQueue:isEmpty
    it("isEmpty reports whether the queue is empty", function()
        expect_true(lurek.patterns.newQueue():isEmpty())
    end)

    -- @covers LQueue:isFull
    it("isFull reports queue capacity saturation", function()
        local queue = lurek.patterns.newQueue(1)
        queue:enqueue("a")
        expect_true(queue:isFull())
    end)

    -- @covers LQueue:toArray
    it("toArray returns queue contents as a table", function()
        local queue = lurek.patterns.newQueue()
        queue:enqueue("a")
        queue:enqueue("b")
        expect_equal(2, #queue:toArray())
    end)

    -- @covers LQueue:clear
    it("clear removes all queue items", function()
        local queue = lurek.patterns.newQueue()
        queue:enqueue("a")
        queue:clear()
        expect_true(queue:isEmpty())
    end)

    -- @covers lurek.patterns.newList
    it("newList creates a list", function()
        expect_not_nil(lurek.patterns.newList())
    end)

    -- @covers LList:add
    it("add appends a list item", function()
        local list = lurek.patterns.newList()
        list:add("a")
        expect_equal(1, list:len())
    end)

    -- @covers LList:get
    it("get returns an item by index", function()
        local list = lurek.patterns.newList()
        list:add("a")
        expect_equal("a", list:get(1))
    end)

    -- @covers LList:len
    it("len returns the number of list items", function()
        local list = lurek.patterns.newList()
        list:add("a")
        list:add("b")
        expect_equal(2, list:len())
    end)

    -- @covers LList:remove
    it("remove deletes an item by index", function()
        local list = lurek.patterns.newList()
        list:add("a")
        list:remove(1)
        expect_equal(0, list:len())
    end)

    -- @covers LList:set
    it("set updates an existing item by index", function()
        local list = lurek.patterns.newList()
        list:add("a")
        list:set(1, "b")
        expect_equal("b", list:get(1))
    end)

    -- @covers LList:contains
    it("contains reports whether a value is present", function()
        local list = lurek.patterns.newList()
        list:add("a")
        expect_true(list:contains("a"))
    end)

    -- @covers LList:isEmpty
    it("isEmpty reports whether the list is empty", function()
        expect_true(lurek.patterns.newList():isEmpty())
    end)

    -- @covers LList:clear
    it("clear removes all list items", function()
        local list = lurek.patterns.newList()
        list:add("a")
        list:clear()
        expect_true(list:isEmpty())
    end)

    -- @covers LList:toArray
    it("toArray returns list contents as a table", function()
        local list = lurek.patterns.newList()
        list:add("a")
        list:add("b")
        expect_equal(2, #list:toArray())
    end)

    -- @covers lurek.patterns.newSet
    it("newSet creates a set", function()
        expect_not_nil(lurek.patterns.newSet())
    end)

    -- @covers LSet:add
    it("add inserts a set member", function()
        local set = lurek.patterns.newSet()
        set:add("a")
        expect_true(set:has("a"))
    end)

    -- @covers LSet:has
    it("has reports whether a member exists", function()
        local set = lurek.patterns.newSet()
        set:add("a")
        expect_true(set:has("a"))
    end)

    -- @covers LSet:len
    it("len returns the number of set members", function()
        local set = lurek.patterns.newSet()
        set:add("a")
        set:add("b")
        expect_equal(2, set:len())
    end)

    -- @covers LSet:remove
    it("remove deletes a set member", function()
        local set = lurek.patterns.newSet()
        set:add("a")
        set:remove("a")
        expect_false(set:has("a"))
    end)

    -- @covers LSet:union
    it("union returns a merged set", function()
        local a = lurek.patterns.newSet()
        local b = lurek.patterns.newSet()
        a:add("x")
        b:add("y")
        expect_equal(2, a:union(b):len())
    end)

    -- @covers LSet:intersection
    it("intersection returns shared members", function()
        local a = lurek.patterns.newSet()
        local b = lurek.patterns.newSet()
        a:add("x")
        a:add("y")
        b:add("y")
        expect_equal(1, a:intersection(b):len())
    end)

    -- @covers LSet:toArray
    it("toArray returns members as a table", function()
        local set = lurek.patterns.newSet()
        set:add("a")
        expect_equal(1, #set:toArray())
    end)

    -- @covers LSet:isEmpty
    it("isEmpty reports whether the set is empty", function()
        expect_true(lurek.patterns.newSet():isEmpty())
    end)

    -- @covers LSet:clear
    it("clear removes all set members", function()
        local set = lurek.patterns.newSet()
        set:add("a")
        set:clear()
        expect_true(set:isEmpty())
    end)
end)

-- @describe reactive helpers
describe("reactive helpers", function()
    -- @covers lurek.patterns.newBlackboard
    it("newBlackboard creates a blackboard", function()
        expect_not_nil(lurek.patterns.newBlackboard())
    end)

    -- @covers LBlackboard:set
    it("set stores a blackboard value", function()
        local bb = lurek.patterns.newBlackboard()
        bb:set("hp", 10)
        expect_equal(10, bb:get("hp"))
    end)

    -- @covers LBlackboard:get
    it("get returns a stored blackboard value", function()
        local bb = lurek.patterns.newBlackboard()
        bb:set("hp", 10)
        expect_equal(10, bb:get("hp"))
    end)

    -- @covers LBlackboard:has
    it("has reports whether a key exists", function()
        local bb = lurek.patterns.newBlackboard()
        bb:set("hp", 10)
        expect_true(bb:has("hp"))
    end)

    -- @covers LBlackboard:getRevision
    it("getRevision increments when values change", function()
        local bb = lurek.patterns.newBlackboard()
        local rev = bb:getRevision()
        bb:set("hp", 10)
        expect_true(bb:getRevision() > rev)
    end)

    -- @covers LBlackboard:clear
    it("clear removes one blackboard key", function()
        local bb = lurek.patterns.newBlackboard()
        bb:set("hp", 10)
        bb:clear("hp")
        expect_false(bb:has("hp"))
    end)

    -- @covers LBlackboard:keys
    it("keys returns current blackboard keys", function()
        local bb = lurek.patterns.newBlackboard()
        bb:set("hp", 10)
        expect_equal(1, #bb:keys())
    end)

    -- @covers LBlackboard:watch
    it("watch runs callbacks when a key changes", function()
        local bb = lurek.patterns.newBlackboard()
        local seen = nil
        bb:watch("hp", function(_, value) seen = value end)
        bb:set("hp", 10)
        expect_equal(10, seen)
    end)

    -- @covers LBlackboard:unwatch
    it("unwatch removes a watcher", function()
        local bb = lurek.patterns.newBlackboard()
        local seen = 0
        local id = bb:watch("hp", function() seen = seen + 1 end)
        bb:unwatch(id)
        bb:set("hp", 10)
        expect_equal(0, seen)
    end)

    -- @covers LBlackboard:snapshot
    it("snapshot returns a table copy of values", function()
        local bb = lurek.patterns.newBlackboard()
        bb:set("hp", 10)
        expect_equal(10, bb:snapshot().hp)
    end)

    -- @covers LBlackboard:clearAll
    it("clearAll removes all blackboard values", function()
        local bb = lurek.patterns.newBlackboard()
        bb:set("hp", 10)
        bb:set("mp", 5)
        bb:clearAll()
        expect_equal(0, #bb:keys())
    end)

    -- @covers lurek.patterns.newObserver
    it("newObserver creates an observer", function()
        expect_not_nil(lurek.patterns.newObserver("obs"))
    end)

    -- @covers LObserver:set
    it("set stores an observed value", function()
        local obs = lurek.patterns.newObserver("obs")
        obs:set("mood", "calm")
        expect_equal("calm", obs:get("mood"))
    end)

    -- @covers LObserver:get
    it("get returns the observed value", function()
        local obs = lurek.patterns.newObserver("obs")
        obs:set("mood", "alert")
        expect_equal("alert", obs:get("mood"))
    end)

    -- @covers LObserver:subscribe
    it("subscribe registers observer callbacks", function()
        local obs = lurek.patterns.newObserver("obs")
        local seen = nil
        local id = obs:subscribe("change", function(_, v) seen = v end)
        obs:set("change", 9)
        expect_type("number", id)
        expect_equal(9, seen)
    end)

    -- @covers LObserver:unsubscribe
    it("unsubscribe removes observer callbacks", function()
        local obs = lurek.patterns.newObserver("obs")
        local count = 0
        local id = obs:subscribe("change", function() count = count + 1 end)
        obs:unsubscribe(id)
        obs:set("change", 9)
        expect_equal(0, count)
    end)

    -- @covers LObserver:getCount
    it("getCount returns subscriber count", function()
        local obs = lurek.patterns.newObserver("obs")
        obs:subscribe("change", function() end)
        expect_type("number", obs:getCount())
    end)
end)

local function table_contains(values, wanted)
    for _, value in ipairs(values) do
        if value == wanted then
            return true
        end
    end
    return false
end

-- @describe timing helpers
describe("timing helpers", function()
    -- @covers lurek.patterns.newThrottle
    it("newThrottle creates a throttle", function()
        expect_not_nil(lurek.patterns.newThrottle(0.2))
    end)

    -- @covers LThrottle:onFire
    it("onFire registers a callback invoked on fire", function()
        local throttle = lurek.patterns.newThrottle(0.2)
        local count = 0
        throttle:onFire(function()
            count = count + 1
        end)
        throttle:update(0.2)
        expect_equal(1, count)
    end)

    -- @covers LThrottle:update
    it("update returns true when the interval elapses", function()
        local throttle = lurek.patterns.newThrottle(0.2)
        throttle:reset()
        expect_false(throttle:update(0.1))
        expect_true(throttle:update(0.1))
    end)

    -- @covers LThrottle:reset
    it("reset clears accumulated progress", function()
        local throttle = lurek.patterns.newThrottle(1.0)
        throttle:update(0.5)
        throttle:reset()
        expect_near(0.0, throttle:getProgress(), 1e-6)
    end)

    -- @covers LThrottle:getProgress
    it("getProgress reports interval completion fraction", function()
        local throttle = lurek.patterns.newThrottle(1.0)
        throttle:reset()
        throttle:update(0.5)
        expect_near(0.5, throttle:getProgress(), 1e-6)
    end)

    -- @covers LThrottle:getFireCount
    it("getFireCount increments after each fire", function()
        local throttle = lurek.patterns.newThrottle(0.2)
        throttle:onFire(function() end)
        throttle:update(0.2)
        throttle:update(0.2)
        expect_equal(2, throttle:getFireCount())
    end)

    -- @covers LThrottle:setEnabled
    it("setEnabled disables firing while false", function()
        local throttle = lurek.patterns.newThrottle(0.2)
        throttle:onFire(function() end)
        throttle:setEnabled(false)
        expect_false(throttle:update(1.0))
        expect_equal(0, throttle:getFireCount())
    end)

    -- @covers lurek.patterns.newDebounce
    it("newDebounce creates a debounce", function()
        expect_not_nil(lurek.patterns.newDebounce(0.5))
    end)

    -- @covers LDebounce:onFire
    it("onFire registers a callback invoked after quiet time", function()
        local debounce = lurek.patterns.newDebounce(0.5)
        local count = 0
        debounce:onFire(function()
            count = count + 1
        end)
        debounce:trigger()
        debounce:update(0.6)
        expect_equal(1, count)
    end)

    -- @covers LDebounce:trigger
    it("trigger marks the debounce as pending", function()
        local debounce = lurek.patterns.newDebounce(0.5)
        debounce:trigger()
        expect_true(debounce:isPending())
    end)

    -- @covers LDebounce:update
    it("update returns true once the wait period elapses", function()
        local debounce = lurek.patterns.newDebounce(0.5)
        debounce:trigger()
        expect_false(debounce:update(0.2))
        expect_true(debounce:update(0.3))
    end)

    -- @covers LDebounce:cancel
    it("cancel clears pending state without firing", function()
        local debounce = lurek.patterns.newDebounce(0.5)
        debounce:onFire(function() end)
        debounce:trigger()
        debounce:cancel()
        debounce:update(1.0)
        expect_false(debounce:isPending())
        expect_equal(0, debounce:getFireCount())
    end)

    -- @covers LDebounce:isPending
    it("isPending reports whether a fire is queued", function()
        local debounce = lurek.patterns.newDebounce(0.5)
        debounce:trigger()
        expect_true(debounce:isPending())
        debounce:update(0.5)
        expect_false(debounce:isPending())
    end)

    -- @covers LDebounce:getFireCount
    it("getFireCount increments after firing", function()
        local debounce = lurek.patterns.newDebounce(0.3)
        debounce:onFire(function() end)
        debounce:trigger()
        debounce:update(0.4)
        expect_equal(1, debounce:getFireCount())
    end)
end)

-- @describe mediator and funnel helpers
describe("mediator and funnel helpers", function()
    -- @covers lurek.patterns.newMediator
    it("newMediator creates a mediator", function()
        expect_not_nil(lurek.patterns.newMediator())
    end)

    -- @covers LMediator:on
    it("on registers a channel handler and returns its id", function()
        local mediator = lurek.patterns.newMediator()
        expect_type("number", mediator:on("ui", function() end))
    end)

    -- @covers LMediator:off
    it("off unregisters a handler from its channel", function()
        local mediator = lurek.patterns.newMediator()
        local count = 0
        local id = mediator:on("ui", function()
            count = count + 1
        end)
        mediator:send("ui")
        mediator:off("ui", id)
        mediator:send("ui")
        expect_equal(1, count)
    end)

    -- @covers LMediator:send
    it("send dispatches payloads to one channel", function()
        local mediator = lurek.patterns.newMediator()
        local seen = nil
        mediator:on("ui", function(value)
            seen = value
        end)
        mediator:send("ui", "pause")
        expect_equal("pause", seen)
    end)

    -- @covers LMediator:broadcast
    it("broadcast dispatches payloads to every channel", function()
        local mediator = lurek.patterns.newMediator()
        local count = 0
        mediator:on("ui", function() count = count + 1 end)
        mediator:on("audio", function() count = count + 1 end)
        mediator:broadcast("pause")
        expect_equal(2, count)
    end)

    -- @covers LMediator:handlerCount
    it("handlerCount reports handlers for one channel", function()
        local mediator = lurek.patterns.newMediator()
        mediator:on("ui", function() end)
        mediator:on("ui", function() end)
        expect_equal(2, mediator:handlerCount("ui"))
    end)

    -- @covers LMediator:channels
    it("channels returns channel names with handlers", function()
        local mediator = lurek.patterns.newMediator()
        mediator:on("ui", function() end)
        mediator:on("audio", function() end)
        local channels = mediator:channels()
        expect_true(table_contains(channels, "ui"))
        expect_true(table_contains(channels, "audio"))
    end)

    -- @covers LMediator:removeChannel
    it("removeChannel drops every handler in that channel", function()
        local mediator = lurek.patterns.newMediator()
        mediator:on("ui", function() end)
        mediator:removeChannel("ui")
        expect_equal(0, mediator:handlerCount("ui"))
    end)

    -- @covers LMediator:clear
    it("clear removes all channels and handlers", function()
        local mediator = lurek.patterns.newMediator()
        mediator:on("ui", function() end)
        mediator:on("audio", function() end)
        mediator:clear()
        expect_equal(0, #mediator:channels())
    end)

    -- @covers lurek.patterns.newFunnel
    it("newFunnel creates a funnel", function()
        expect_not_nil(lurek.patterns.newFunnel(1.0, 5, "damage_log"))
    end)

    -- @covers LFunnel:onFlush
    it("onFlush registers a callback for flush batches", function()
        local funnel = lurek.patterns.newFunnel(1.0, 5, "damage_log")
        local flushed = 0
        funnel:onFlush(function(entries)
            flushed = #entries
        end)
        funnel:push("fire", 10)
        funnel:push("ice", 5)
        funnel:flush()
        expect_equal(2, flushed)
    end)

    -- @covers LFunnel:push
    it("push adds pending entries", function()
        local funnel = lurek.patterns.newFunnel(1.0, 5, "damage_log")
        funnel:push("fire", 10)
        funnel:push("ice", 5)
        expect_equal(2, funnel:pendingCount())
    end)

    -- @covers LFunnel:update
    it("update flushes when the time window elapses", function()
        local funnel = lurek.patterns.newFunnel(1.0, 5, "damage_log")
        funnel:onFlush(function() end)
        funnel:push("fire", 10)
        expect_true(funnel:update(1.1))
    end)

    -- @covers LFunnel:flush
    it("flush forces an immediate flush", function()
        local funnel = lurek.patterns.newFunnel(5.0, 0, "damage_log")
        funnel:onFlush(function() end)
        funnel:push("fire", 10)
        funnel:flush()
        expect_equal(0, funnel:pendingCount())
    end)

    -- @covers LFunnel:discard
    it("discard drops pending entries without flushing", function()
        local funnel = lurek.patterns.newFunnel(5.0, 0, "damage_log")
        funnel:push("fire", 10)
        funnel:push("ice", 5)
        funnel:discard()
        expect_equal(0, funnel:pendingCount())
        expect_equal(0, funnel:getFlushCount())
    end)

    -- @covers LFunnel:pendingCount
    it("pendingCount returns the current buffered entry count", function()
        local funnel = lurek.patterns.newFunnel(5.0, 0, "damage_log")
        funnel:push("fire", 10)
        funnel:push("ice", 5)
        expect_equal(2, funnel:pendingCount())
    end)

    -- @covers LFunnel:getFlushCount
    it("getFlushCount increments after flushes", function()
        local funnel = lurek.patterns.newFunnel(5.0, 0, "damage_log")
        funnel:onFlush(function() end)
        funnel:push("fire", 10)
        funnel:flush()
        expect_equal(1, funnel:getFlushCount())
    end)
end)

-- @describe extended linear containers
describe("extended linear containers", function()
    -- @covers LStack:pushBottom
    it("pushBottom inserts a value at the bottom of the stack", function()
        local stack = lurek.patterns.newStack()
        stack:push("b")
        stack:pushBottom("a")
        expect_equal("a", stack:peekBottom())
    end)

    -- @covers LStack:popBottom
    it("popBottom removes the bottom-most stack value", function()
        local stack = lurek.patterns.newStack()
        stack:push("b")
        stack:pushBottom("a")
        expect_equal("a", stack:popBottom())
    end)

    -- @covers LStack:popMany
    it("popMany removes several values from the top", function()
        local stack = lurek.patterns.newStack()
        stack:push("a")
        stack:push("b")
        stack:push("c")
        local popped = stack:popMany(2)
        expect_equal(2, #popped)
        expect_equal("c", popped[1])
        expect_equal("b", popped[2])
    end)

    -- @covers LStack:peekBottom
    it("peekBottom returns the oldest stack value", function()
        local stack = lurek.patterns.newStack()
        stack:push("b")
        stack:pushBottom("a")
        expect_equal("a", stack:peekBottom())
    end)

    -- @covers LStack:peekAt
    it("peekAt reads a stack value by one-based position", function()
        local stack = lurek.patterns.newStack()
        stack:push("a")
        stack:push("b")
        expect_equal("b", stack:peekAt(2))
    end)

    -- @covers LStack:insertAt
    it("insertAt inserts a stack value at a position", function()
        local stack = lurek.patterns.newStack()
        stack:push("a")
        stack:push("c")
        stack:insertAt(2, "b")
        expect_equal("b", stack:peekAt(2))
    end)

    -- @covers LStack:removeAt
    it("removeAt removes a stack value by position", function()
        local stack = lurek.patterns.newStack()
        stack:push("a")
        stack:push("b")
        stack:push("c")
        expect_equal("b", stack:removeAt(2))
    end)

    -- @covers LStack:moveWithin
    it("moveWithin reorders stack items in place", function()
        local stack = lurek.patterns.newStack()
        stack:push("a")
        stack:push("b")
        stack:push("c")
        expect_true(stack:moveWithin(3, 1))
        expect_equal("c", stack:peekBottom())
    end)

    -- @covers LQueue:enqueueFront
    it("enqueueFront inserts a value at the front of the queue", function()
        local queue = lurek.patterns.newQueue()
        queue:enqueue("b")
        queue:enqueueFront("a")
        expect_equal("a", queue:front())
    end)

    -- @covers LQueue:dequeueBack
    it("dequeueBack removes the last queue value", function()
        local queue = lurek.patterns.newQueue()
        queue:enqueue("a")
        queue:enqueue("b")
        expect_equal("b", queue:dequeueBack())
    end)

    -- @covers LQueue:peekAt
    it("peekAt reads a queue value by one-based position", function()
        local queue = lurek.patterns.newQueue()
        queue:enqueue("a")
        queue:enqueue("b")
        expect_equal("b", queue:peekAt(2))
    end)

    -- @covers LQueue:insertAt
    it("insertAt inserts a queue value at a position", function()
        local queue = lurek.patterns.newQueue()
        queue:enqueue("a")
        queue:enqueue("c")
        queue:insertAt(2, "b")
        expect_equal("b", queue:peekAt(2))
    end)

    -- @covers LQueue:removeAt
    it("removeAt removes a queue value by position", function()
        local queue = lurek.patterns.newQueue()
        queue:enqueue("a")
        queue:enqueue("b")
        queue:enqueue("c")
        expect_equal("b", queue:removeAt(2))
    end)

    -- @covers LList:push
    it("push appends a value to the list", function()
        local list = lurek.patterns.newList()
        list:push("a")
        expect_equal("a", list:get(1))
    end)

    -- @covers LList:unshift
    it("unshift inserts a value at the beginning of the list", function()
        local list = lurek.patterns.newList()
        list:add("b")
        list:unshift("a")
        expect_equal("a", list:get(1))
    end)

    -- @covers LList:insert
    it("insert places a value at a one-based index", function()
        local list = lurek.patterns.newList()
        list:add("a")
        list:add("c")
        list:insert(2, "b")
        expect_equal("b", list:get(2))
    end)

    -- @covers LList:pop
    it("pop removes the last list value", function()
        local list = lurek.patterns.newList()
        list:add("a")
        list:add("b")
        expect_equal("b", list:pop())
    end)

    -- @covers LList:shift
    it("shift removes the first list value", function()
        local list = lurek.patterns.newList()
        list:add("a")
        list:add("b")
        expect_equal("a", list:shift())
    end)

    -- @covers LList:indexOf
    it("indexOf returns the one-based index of a matching value", function()
        local list = lurek.patterns.newList()
        list:add("a")
        list:add("b")
        expect_equal(2, list:indexOf("b"))
    end)

    -- @covers LList:reverse
    it("reverse flips the list order in place", function()
        local list = lurek.patterns.newList()
        list:add("a")
        list:add("b")
        list:add("c")
        list:reverse()
        expect_equal("c", list:get(1))
        expect_equal("a", list:get(3))
    end)
end)

-- @describe associative and weighted helpers
describe("associative and weighted helpers", function()
    -- @covers lurek.patterns.newMap
    it("newMap creates a map", function()
        expect_not_nil(lurek.patterns.newMap())
    end)

    -- @covers LMap:set
    it("set stores a map value by key", function()
        local map = lurek.patterns.newMap()
        map:set("name", "hero")
        expect_equal("hero", map:get("name"))
    end)

    -- @covers LMap:get
    it("get returns a stored map value", function()
        local map = lurek.patterns.newMap()
        map:set("level", 5)
        expect_equal(5, map:get("level"))
    end)

    -- @covers LMap:has
    it("has reports whether a map key exists", function()
        local map = lurek.patterns.newMap()
        map:set("level", 5)
        expect_true(map:has("level"))
    end)

    -- @covers LMap:remove
    it("remove deletes a map key and returns true", function()
        local map = lurek.patterns.newMap()
        map:set("class", "warrior")
        expect_true(map:remove("class"))
        expect_false(map:has("class"))
    end)

    -- @covers LMap:len
    it("len returns the number of map entries", function()
        local map = lurek.patterns.newMap()
        map:set("name", "hero")
        map:set("level", 5)
        expect_equal(2, map:len())
    end)

    -- @covers LMap:isEmpty
    it("isEmpty reports whether the map has entries", function()
        local map = lurek.patterns.newMap()
        expect_true(map:isEmpty())
        map:set("name", "hero")
        expect_false(map:isEmpty())
    end)

    -- @covers LMap:keys
    it("keys returns all stored key names", function()
        local map = lurek.patterns.newMap()
        map:set("name", "hero")
        map:set("level", 5)
        local keys = map:keys()
        expect_true(table_contains(keys, "name"))
        expect_true(table_contains(keys, "level"))
    end)

    -- @covers LMap:values
    it("values returns all stored values", function()
        local map = lurek.patterns.newMap()
        map:set("name", "hero")
        map:set("level", 5)
        local values = map:values()
        expect_true(table_contains(values, "hero"))
        expect_true(table_contains(values, 5))
    end)

    -- @covers LMap:entries
    it("entries returns key-value rows", function()
        local map = lurek.patterns.newMap()
        map:set("a", 1)
        map:set("b", 2)
        local entries = map:entries()
        local found_a = false
        local found_b = false
        for _, entry in ipairs(entries) do
            if entry.key == "a" and entry.value == 1 then
                found_a = true
            end
            if entry.key == "b" and entry.value == 2 then
                found_b = true
            end
        end
        expect_true(found_a)
        expect_true(found_b)
    end)

    -- @covers LMap:merge
    it("merge copies entries from another map", function()
        local left = lurek.patterns.newMap()
        local right = lurek.patterns.newMap()
        left:set("a", 1)
        right:set("b", 2)
        left:merge(right)
        expect_equal(2, left:len())
        expect_equal(2, left:get("b"))
    end)

    -- @covers LMap:clear
    it("clear removes all map entries", function()
        local map = lurek.patterns.newMap()
        map:set("a", 1)
        map:set("b", 2)
        map:clear()
        expect_equal(0, map:len())
    end)

    -- @covers lurek.patterns.newPriorityQueue
    it("newPriorityQueue creates a priority queue", function()
        expect_not_nil(lurek.patterns.newPriorityQueue("tasks"))
    end)

    -- @covers LPriorityQueue:push
    it("push inserts values ordered by priority", function()
        local queue = lurek.patterns.newPriorityQueue("tasks")
        queue:push(1, "low_task", "low")
        queue:push(10, "high_task", "high")
        expect_equal("high_task", queue:peek())
    end)

    -- @covers LPriorityQueue:pop
    it("pop removes the highest-priority value first", function()
        local queue = lurek.patterns.newPriorityQueue("tasks")
        queue:push(1, "low_task", "low")
        queue:push(10, "high_task", "high")
        expect_equal("high_task", queue:pop())
    end)

    -- @covers LPriorityQueue:peek
    it("peek returns the highest-priority value without removal", function()
        local queue = lurek.patterns.newPriorityQueue("tasks")
        queue:push(1, "low_task", "low")
        queue:push(10, "high_task", "high")
        expect_equal("high_task", queue:peek())
        expect_equal(2, queue:len())
    end)

    -- @covers LPriorityQueue:len
    it("len returns the number of queued values", function()
        local queue = lurek.patterns.newPriorityQueue("tasks")
        queue:push(1, "low_task", "low")
        queue:push(10, "high_task", "high")
        expect_equal(2, queue:len())
    end)

    -- @covers LPriorityQueue:isEmpty
    it("isEmpty reports whether the priority queue has entries", function()
        local queue = lurek.patterns.newPriorityQueue("tasks")
        expect_true(queue:isEmpty())
        queue:push(10, "high_task", "high")
        expect_false(queue:isEmpty())
    end)

    -- @covers LPriorityQueue:clearAll
    it("clearAll removes every queued value", function()
        local queue = lurek.patterns.newPriorityQueue("tasks")
        queue:push(1, "low_task", "low")
        queue:push(10, "high_task", "high")
        queue:clearAll()
        expect_equal(0, queue:len())
    end)

    -- @covers lurek.patterns.newRing
    it("newRing creates a ring buffer", function()
        expect_not_nil(lurek.patterns.newRing(5, "fps_samples"))
    end)

    -- @covers LRing:push
    it("push appends a ring entry", function()
        local ring = lurek.patterns.newRing(5, "fps_samples")
        ring:push(60)
        expect_equal(1, ring:len())
    end)

    -- @covers LRing:latest
    it("latest returns the most recent ring entry", function()
        local ring = lurek.patterns.newRing(5, "fps_samples")
        ring:push(60)
        ring:push(62)
        expect_equal(62, ring:latest().value)
    end)

    -- @covers LRing:toArray
    it("toArray returns ring entries in order", function()
        local ring = lurek.patterns.newRing(5, "fps_samples")
        ring:push(60)
        ring:push(58)
        ring:push(62)
        local values = ring:toArray()
        expect_equal(3, #values)
        expect_equal(60, values[1].value)
        expect_equal(62, values[3].value)
    end)

    -- @covers LRing:sum
    it("sum returns the total of numeric ring values", function()
        local ring = lurek.patterns.newRing(5, "fps_samples")
        ring:push(60)
        ring:push(58)
        ring:push(62)
        expect_near(180.0, ring:sum(), 1e-6)
    end)

    -- @covers LRing:average
    it("average returns the mean of numeric ring values", function()
        local ring = lurek.patterns.newRing(5, "fps_samples")
        ring:push(60)
        ring:push(58)
        ring:push(62)
        expect_near(60.0, ring:average(), 1e-6)
    end)

    -- @covers LRing:len
    it("len returns the number of buffered ring entries", function()
        local ring = lurek.patterns.newRing(5, "fps_samples")
        ring:push(60)
        ring:push(58)
        expect_equal(2, ring:len())
    end)

    -- @covers LRing:isFull
    it("isFull reports when ring capacity is reached", function()
        local ring = lurek.patterns.newRing(3, "fps_samples")
        ring:push(60)
        ring:push(58)
        ring:push(62)
        expect_true(ring:isFull())
    end)

    -- @covers LRing:clear
    it("clear removes all ring entries", function()
        local ring = lurek.patterns.newRing(5, "fps_samples")
        ring:push(60)
        ring:push(58)
        ring:clear()
        expect_equal(0, ring:len())
    end)

    -- @covers lurek.patterns.newWeightedRandom
    it("newWeightedRandom creates a weighted pool", function()
        expect_not_nil(lurek.patterns.newWeightedRandom())
    end)

    -- @covers LWeightedRandom:add
    it("add inserts a weighted item and returns its id", function()
        local wr = lurek.patterns.newWeightedRandom()
        expect_type("number", wr:add(10, "common", "common_loot"))
    end)

    -- @covers LWeightedRandom:remove
    it("remove deletes a weighted item by id", function()
        local wr = lurek.patterns.newWeightedRandom()
        local id = wr:add(5, "item_a")
        wr:add(5, "item_b")
        expect_true(wr:remove(id))
        expect_equal(1, wr:len())
    end)

    -- @covers LWeightedRandom:setWeight
    it("setWeight updates the stored weight of an item", function()
        local wr = lurek.patterns.newWeightedRandom()
        local id = wr:add(5, "item_a")
        wr:add(5, "item_b")
        expect_true(wr:setWeight(id, 20))
        expect_near(25.0, wr:totalWeight(), 1e-6)
    end)

    -- @covers LWeightedRandom:pick
    it("pick returns a sampled payload", function()
        local wr = lurek.patterns.newWeightedRandom()
        wr:add(10, "common", "common_loot")
        wr:add(3, "rare", "rare_loot")
        expect_equal("common", wr:pick(0.1))
    end)

    -- @covers LWeightedRandom:pickN
    it("pickN returns multiple sampled payloads", function()
        local wr = lurek.patterns.newWeightedRandom()
        wr:add(10, "common", "common_loot")
        wr:add(3, "rare", "rare_loot")
        wr:add(1, "legendary", "legendary_loot")
        local picks = wr:pickN(2, {0.1, 0.95})
        expect_equal(2, #picks)
        expect_true(table_contains(picks, "common"))
    end)

    -- @covers LWeightedRandom:totalWeight
    it("totalWeight returns the sum of all weights", function()
        local wr = lurek.patterns.newWeightedRandom()
        wr:add(10, "common", "common_loot")
        wr:add(3, "rare", "rare_loot")
        expect_near(13.0, wr:totalWeight(), 1e-6)
    end)

    -- @covers LWeightedRandom:len
    it("len returns the number of weighted items", function()
        local wr = lurek.patterns.newWeightedRandom()
        wr:add(10, "common", "common_loot")
        wr:add(3, "rare", "rare_loot")
        expect_equal(2, wr:len())
    end)

    -- @covers LWeightedRandom:isEmpty
    it("isEmpty reports whether the weighted pool has items", function()
        local wr = lurek.patterns.newWeightedRandom()
        expect_true(wr:isEmpty())
        wr:add(5, "item_a")
        expect_false(wr:isEmpty())
    end)

    -- @covers LWeightedRandom:clearAll
    it("clearAll removes all weighted items", function()
        local wr = lurek.patterns.newWeightedRandom()
        wr:add(5, "item_a")
        wr:add(5, "item_b")
        wr:clearAll()
        expect_equal(0, wr:len())
    end)

    -- @covers LWeightedRandom:getRevision
    it("getRevision increments on mutations", function()
        local wr = lurek.patterns.newWeightedRandom()
        local rev = wr:getRevision()
        wr:add(5, "item_a")
        expect_true(wr:getRevision() > rev)
    end)
end)

-- @describe relationship and behavior structures
describe("relationship and behavior structures", function()
    -- @covers lurek.patterns.newRelationshipManager
    it("newRelationshipManager creates a relationship manager", function()
        expect_not_nil(lurek.patterns.newRelationshipManager())
    end)

    -- @covers LRelationshipManager:defineType
    it("defineType registers a named relationship ladder", function()
        local rm = lurek.patterns.newRelationshipManager()
        rm:defineType("friendship", {"hostile", "neutral", "friendly"}, "neutral")
        expect_true(table_contains(rm:typeNames(), "friendship"))
    end)

    -- @covers LRelationshipManager:removeType
    it("removeType deletes a registered relationship type", function()
        local rm = lurek.patterns.newRelationshipManager()
        rm:defineType("friendship", {"hostile", "neutral", "friendly"}, "neutral")
        rm:removeType("friendship")
        expect_false(table_contains(rm:typeNames(), "friendship"))
    end)

    -- @covers LRelationshipManager:typeNames
    it("typeNames returns all defined relationship types", function()
        local rm = lurek.patterns.newRelationshipManager()
        rm:defineType("friendship", {"hostile", "neutral", "friendly"}, "neutral")
        rm:defineType("trust", {"low", "medium", "high"}, "medium")
        local names = rm:typeNames()
        expect_equal("friendship", names[1])
        expect_equal("trust", names[2])
    end)

    -- @covers LRelationshipManager:setValue
    it("setValue stores a numeric relation between two entities", function()
        local rm = lurek.patterns.newRelationshipManager()
        rm:setValue(1, 2, 50)
        expect_near(50.0, rm:getValue(1, 2), 1e-6)
    end)

    -- @covers LRelationshipManager:getValue
    it("getValue returns a stored numeric relation", function()
        local rm = lurek.patterns.newRelationshipManager()
        rm:setValue(1, 3, -20)
        expect_near(-20.0, rm:getValue(1, 3), 1e-6)
    end)

    -- @covers LRelationshipManager:adjustValue
    it("adjustValue adds a delta to a numeric relation", function()
        local rm = lurek.patterns.newRelationshipManager()
        rm:setValue(1, 2, 50)
        rm:adjustValue(1, 2, 10)
        expect_near(60.0, rm:getValue(1, 2), 1e-6)
    end)

    -- @covers LRelationshipManager:setLevel
    it("setLevel stores a named relation level for a type", function()
        local rm = lurek.patterns.newRelationshipManager()
        rm:defineType("friendship", {"hostile", "neutral", "friendly"}, "neutral")
        expect_true(rm:setLevel(1, 2, "friendship", "friendly"))
    end)

    -- @covers LRelationshipManager:getLevel
    it("getLevel returns the named relation level", function()
        local rm = lurek.patterns.newRelationshipManager()
        rm:defineType("friendship", {"hostile", "neutral", "friendly"}, "neutral")
        rm:setLevel(1, 2, "friendship", "friendly")
        expect_equal("friendly", rm:getLevel(1, 2, "friendship"))
    end)

    -- @covers LRelationshipManager:removePair
    it("removePair deletes all data for one relation pair", function()
        local rm = lurek.patterns.newRelationshipManager()
        rm:setValue(1, 2, 50)
        rm:setValue(1, 3, -20)
        rm:removePair(1, 2)
        expect_near(0.0, rm:getValue(1, 2), 1e-6)
    end)

    -- @covers LRelationshipManager:pairCount
    it("pairCount returns the number of tracked pairs", function()
        local rm = lurek.patterns.newRelationshipManager()
        rm:setValue(1, 2, 50)
        rm:setValue(1, 3, -20)
        expect_equal(2, rm:pairCount())
    end)

    -- @covers lurek.patterns.newBehaviorTree
    it("newBehaviorTree creates a behavior tree", function()
        expect_not_nil(lurek.patterns.newBehaviorTree())
    end)

    -- @covers LBehaviorTree:addSequence
    it("addSequence creates a sequence node that can succeed", function()
        local bt = lurek.patterns.newBehaviorTree()
        local root = bt:addSequence("root")
        local leaf = bt:addLeaf("act")
        bt:addChild(root, leaf)
        bt:setLeaf("act", function() return "success" end)
        bt:setRoot(root)
        expect_equal("success", bt:tick())
    end)

    -- @covers LBehaviorTree:addSelector
    it("addSelector succeeds when one child succeeds", function()
        local bt = lurek.patterns.newBehaviorTree()
        local root = bt:addSelector("root")
        local fail_leaf = bt:addLeaf("fail")
        local ok_leaf = bt:addLeaf("ok")
        bt:addChild(root, fail_leaf)
        bt:addChild(root, ok_leaf)
        bt:setLeaf("fail", function() return "failure" end)
        bt:setLeaf("ok", function() return "success" end)
        bt:setRoot(root)
        expect_equal("success", bt:tick())
    end)

    -- @covers LBehaviorTree:addParallel
    it("addParallel succeeds when enough children succeed", function()
        local bt = lurek.patterns.newBehaviorTree()
        local root = bt:addParallel(2, "root")
        local a = bt:addLeaf("a")
        local b = bt:addLeaf("b")
        bt:addChild(root, a)
        bt:addChild(root, b)
        bt:setLeaf("a", function() return "success" end)
        bt:setLeaf("b", function() return "success" end)
        bt:setRoot(root)
        expect_equal("success", bt:tick())
    end)

    -- @covers LBehaviorTree:addInverter
    it("addInverter flips child failure into success", function()
        local bt = lurek.patterns.newBehaviorTree()
        local root = bt:addInverter("invert")
        local leaf = bt:addLeaf("check")
        bt:addChild(root, leaf)
        bt:setLeaf("check", function() return "failure" end)
        bt:setRoot(root)
        expect_equal("success", bt:tick())
    end)

    -- @covers LBehaviorTree:addRepeat
    it("addRepeat repeats a successful child and succeeds", function()
        local bt = lurek.patterns.newBehaviorTree()
        local root = bt:addRepeat(2, "repeat")
        local leaf = bt:addLeaf("step")
        local count = 0
        bt:addChild(root, leaf)
        bt:setLeaf("step", function()
            count = count + 1
            return "success"
        end)
        bt:setRoot(root)
        expect_equal("success", bt:tick())
        expect_equal(2, count)
    end)

    -- @covers LBehaviorTree:addLeaf
    it("addLeaf creates a callable action node", function()
        local bt = lurek.patterns.newBehaviorTree()
        local root = bt:addSequence("root")
        local leaf = bt:addLeaf("act")
        bt:addChild(root, leaf)
        bt:setLeaf("act", function() return "success" end)
        bt:setRoot(root)
        expect_equal("success", bt:tick())
    end)

    -- @covers LBehaviorTree:addChild
    it("addChild attaches a node under a parent", function()
        local bt = lurek.patterns.newBehaviorTree()
        local root = bt:addSequence("root")
        local leaf = bt:addLeaf("act")
        expect_true(bt:addChild(root, leaf))
    end)

    -- @covers LBehaviorTree:setLeaf
    it("setLeaf registers the implementation for a named leaf", function()
        local bt = lurek.patterns.newBehaviorTree()
        local root = bt:addSequence("root")
        local leaf = bt:addLeaf("act")
        bt:addChild(root, leaf)
        bt:setLeaf("act", function() return "success" end)
        bt:setRoot(root)
        expect_equal("success", bt:tick())
    end)

    -- @covers LBehaviorTree:tick
    it("tick evaluates the current root node", function()
        local bt = lurek.patterns.newBehaviorTree()
        local root = bt:addSequence("root")
        local leaf = bt:addLeaf("act")
        bt:addChild(root, leaf)
        bt:setLeaf("act", function() return "success" end)
        bt:setRoot(root)
        expect_equal("success", bt:tick())
    end)

    -- @covers LBehaviorTree:resetState
    it("resetState clears running state between ticks", function()
        local bt = lurek.patterns.newBehaviorTree()
        local root = bt:addSequence("root")
        local leaf = bt:addLeaf("act")
        local first = true
        bt:addChild(root, leaf)
        bt:setLeaf("act", function()
            if first then
                first = false
                return "running"
            end
            return "success"
        end)
        bt:setRoot(root)
        expect_equal("running", bt:tick())
        bt:resetState()
        expect_equal("success", bt:tick())
    end)

    -- @covers LBehaviorTree:nodeCount
    it("nodeCount returns the total number of tree nodes", function()
        local bt = lurek.patterns.newBehaviorTree()
        local root = bt:addSequence("root")
        local a = bt:addLeaf("a")
        local b = bt:addLeaf("b")
        bt:addChild(root, a)
        bt:addChild(root, b)
        expect_equal(3, bt:nodeCount())
    end)

    -- @covers LBehaviorTree:clearAll
    it("clearAll removes every node and leaf implementation", function()
        local bt = lurek.patterns.newBehaviorTree()
        bt:addSelector("root")
        bt:addLeaf("idle")
        bt:clearAll()
        expect_equal(0, bt:nodeCount())
    end)
end)

-- @describe graph structures
describe("graph structures", function()
    -- @covers lurek.patterns.newGraph
    it("newGraph creates a graph", function()
        expect_not_nil(lurek.patterns.newGraph(true))
    end)

    -- @covers LPatternGraph:addNode
    it("addNode creates a node and returns its id", function()
        local graph = lurek.patterns.newGraph(true)
        expect_type("number", graph:addNode("A", {cost = 10}))
    end)

    -- @covers LPatternGraph:removeNode
    it("removeNode deletes an existing node", function()
        local graph = lurek.patterns.newGraph(true)
        local a = graph:addNode("A", {cost = 10})
        expect_true(graph:removeNode(a))
        expect_false(graph:hasNode(a))
    end)

    -- @covers LPatternGraph:getNodeValue
    it("getNodeValue returns the stored node payload", function()
        local graph = lurek.patterns.newGraph(true)
        local a = graph:addNode("A", {cost = 10})
        expect_equal(10, graph:getNodeValue(a).cost)
    end)

    -- @covers LPatternGraph:addEdge
    it("addEdge connects two nodes and returns an edge id", function()
        local graph = lurek.patterns.newGraph(true)
        local a = graph:addNode("A", {cost = 10})
        local b = graph:addNode("B", {cost = 5})
        expect_type("number", graph:addEdge(a, b, 1.5, "road"))
    end)

    -- @covers LPatternGraph:removeEdge
    it("removeEdge deletes an existing edge", function()
        local graph = lurek.patterns.newGraph(true)
        local a = graph:addNode("A", {cost = 10})
        local b = graph:addNode("B", {cost = 5})
        local edge = graph:addEdge(a, b, 1.5, "road")
        expect_true(graph:removeEdge(edge))
        expect_equal(0, graph:edgeCount())
    end)

    -- @covers LPatternGraph:neighbors
    it("neighbors returns directly connected node ids", function()
        local graph = lurek.patterns.newGraph(true)
        local a = graph:addNode("A", {cost = 10})
        local b = graph:addNode("B", {cost = 5})
        graph:addEdge(a, b, 1.5, "road")
        local neighbors = graph:neighbors(a)
        expect_true(table_contains(neighbors, b))
    end)

    -- @covers LPatternGraph:bfs
    it("bfs returns reachable nodes in breadth-first traversal", function()
        local graph = lurek.patterns.newGraph(true)
        local a = graph:addNode("A")
        local b = graph:addNode("B")
        local c = graph:addNode("C")
        graph:addEdge(a, b, 1.0, "ab")
        graph:addEdge(a, c, 1.0, "ac")
        local order = graph:bfs(a)
        expect_equal(a, order[1])
        expect_equal(3, #order)
    end)

    -- @covers LPatternGraph:dfs
    it("dfs returns reachable nodes in depth-first traversal", function()
        local graph = lurek.patterns.newGraph(true)
        local a = graph:addNode("A")
        local b = graph:addNode("B")
        local c = graph:addNode("C")
        graph:addEdge(a, b, 1.0, "ab")
        graph:addEdge(b, c, 1.0, "bc")
        local order = graph:dfs(a)
        expect_equal(a, order[1])
        expect_equal(3, #order)
    end)

    -- @covers LPatternGraph:isConnected
    it("isConnected reports whether a path exists between nodes", function()
        local graph = lurek.patterns.newGraph(true)
        local a = graph:addNode("A")
        local b = graph:addNode("B")
        graph:addEdge(a, b, 1.0, "ab")
        expect_true(graph:isConnected(a, b))
    end)

    -- @covers LPatternGraph:hasNode
    it("hasNode reports whether a node id exists", function()
        local graph = lurek.patterns.newGraph(true)
        local a = graph:addNode("A")
        expect_true(graph:hasNode(a))
    end)

    -- @covers LPatternGraph:nodeCount
    it("nodeCount returns the number of graph nodes", function()
        local graph = lurek.patterns.newGraph(true)
        graph:addNode("A")
        graph:addNode("B")
        expect_equal(2, graph:nodeCount())
    end)

    -- @covers LPatternGraph:edgeCount
    it("edgeCount returns the number of graph edges", function()
        local graph = lurek.patterns.newGraph(false)
        local a = graph:addNode("A")
        local b = graph:addNode("B")
        graph:addEdge(a, b, 1.0, "ab")
        expect_equal(1, graph:edgeCount())
    end)

    -- @covers LPatternGraph:clearAll
    it("clearAll removes all graph nodes and edges", function()
        local graph = lurek.patterns.newGraph(true)
        local a = graph:addNode("A")
        local b = graph:addNode("B")
        graph:addEdge(a, b, 1.0, "ab")
        graph:clearAll()
        expect_equal(0, graph:nodeCount())
        expect_equal(0, graph:edgeCount())
    end)
end)
end
-- END test_patterns_core_unit.lua

test_summary()
