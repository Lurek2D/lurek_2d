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

test_summary()
