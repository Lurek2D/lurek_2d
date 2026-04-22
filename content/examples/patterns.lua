-- content/examples/patterns.lua
-- love2d-style usage snippets for the lurek.patterns API (170 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/patterns.lua

-- ── lurek.patterns.* functions ──

--@api-stub: lurek.patterns.newEventBus
-- Creates a new EventBus instance.
-- Build once at startup; reuse across frames.
local eventbus = lurek.patterns.newEventBus("main")
print("created", eventbus)
return eventbus

--@api-stub: lurek.patterns.newObjectPool
-- Creates a new ObjectPool instance.
-- Build once at startup; reuse across frames.
local objectpool = lurek.patterns.newObjectPool()
print("created", objectpool)
return objectpool

--@api-stub: lurek.patterns.newCommandStack
-- Creates a new CommandStack instance.
-- Build once at startup; reuse across frames.
local commandstack = lurek.patterns.newCommandStack(max_size)
print("created", commandstack)
return commandstack

--@api-stub: lurek.patterns.newServiceLocator
-- Creates a new ServiceLocator instance.
-- Build once at startup; reuse across frames.
local servicelocator = lurek.patterns.newServiceLocator()
print("created", servicelocator)
return servicelocator

--@api-stub: lurek.patterns.newFactory
-- Creates a new Factory instance.
-- Build once at startup; reuse across frames.
local factory = lurek.patterns.newFactory()
print("created", factory)
return factory

--@api-stub: lurek.patterns.newSimpleState
-- Creates a new SimpleState finite state machine instance.
-- Build once at startup; reuse across frames.
local simplestate = lurek.patterns.newSimpleState()
print("created", simplestate)
return simplestate

--@api-stub: lurek.patterns.newBlackboard
-- Creates a new Blackboard shared key-value store.
-- Build once at startup; reuse across frames.
local blackboard = lurek.patterns.newBlackboard("main")
print("created", blackboard)
return blackboard

--@api-stub: lurek.patterns.newObserver
-- Creates a new reactive property Observer.
-- Build once at startup; reuse across frames.
local observer = lurek.patterns.newObserver("main")
print("created", observer)
return observer

--@api-stub: lurek.patterns.newThrottle
-- Creates a leading-edge rate limiter that fires at most once per interval seconds.
-- Build once at startup; reuse across frames.
local throttle = lurek.patterns.newThrottle(interval)
print("created", throttle)
return throttle

--@api-stub: lurek.patterns.newDebounce
-- Creates a trailing-edge debounce that fires after the input stream is idle for wait seconds.
-- Build once at startup; reuse across frames.
local debounce = lurek.patterns.newDebounce(1.0)
print("created", debounce)
return debounce

--@api-stub: lurek.patterns.newPriorityQueue
-- Creates a stable priority-ordered task queue.
-- Build once at startup; reuse across frames.
local priorityqueue = lurek.patterns.newPriorityQueue("main")
print("created", priorityqueue)
return priorityqueue

--@api-stub: lurek.patterns.newRing
-- Creates a fixed-capacity circular history buffer.
-- Build once at startup; reuse across frames.
local ring = lurek.patterns.newRing(capacity, "main")
print("created", ring)
return ring

--@api-stub: lurek.patterns.newFunnel
-- Creates a time-windowed event aggregator.
-- Build once at startup; reuse across frames.
local funnel = lurek.patterns.newFunnel(window, max_entries, "main")
print("created", funnel)
return funnel

--@api-stub: lurek.patterns.newRelationshipManager
-- Creates a new entity relationship manager.
-- Build once at startup; reuse across frames.
local relationshipmanager = lurek.patterns.newRelationshipManager()
print("created", relationshipmanager)
return relationshipmanager

--@api-stub: lurek.patterns.newMediator
-- Creates a new named-channel message broker.
-- Build once at startup; reuse across frames.
local mediator = lurek.patterns.newMediator()
print("created", mediator)
return mediator

--@api-stub: lurek.patterns.newStrategy
-- Creates a new strategy registry.
-- Build once at startup; reuse across frames.
local strategy = lurek.patterns.newStrategy()
print("created", strategy)
return strategy

--@api-stub: lurek.patterns.newStack
-- Creates a LIFO stack.
-- Build once at startup; reuse across frames.
local stack = lurek.patterns.newStack(capacity)
print("created", stack)
return stack

--@api-stub: lurek.patterns.newQueue
-- Creates a FIFO queue.
-- Build once at startup; reuse across frames.
local queue = lurek.patterns.newQueue(capacity)
print("created", queue)
return queue

--@api-stub: lurek.patterns.newList
-- Creates an ordered, resizable list.
-- Build once at startup; reuse across frames.
local list = lurek.patterns.newList()
print("created", list)
return list

--@api-stub: lurek.patterns.newSet
-- Creates an unordered set that rejects duplicate values (by string key).
-- Build once at startup; reuse across frames.
local set = lurek.patterns.newSet()
print("created", set)
return set

-- ── EventBus methods ──

--@api-stub: EventBus:on
-- Registers a listener callback for an event.
-- See the module spec for detailed semantics.
local eventBus = lurek.patterns.newEventBus()
eventBus:on(event, function() print("on fired") end, priority)
print("EventBus:on done")

--@api-stub: EventBus:off
-- Removes a previously registered event listener by subscription ID.
-- See the module spec for detailed semantics.
local eventBus = lurek.patterns.newEventBus()
eventBus:off(1)
print("EventBus:off done")

--@api-stub: EventBus:emit
-- Dispatches an event, calling all registered listeners in priority order.
-- Side-effecting; safe to call any time after init.
local eventBus = lurek.patterns.newEventBus()
eventBus:emit({ x = 0, y = 0 })
print("EventBus:emit done")

--@api-stub: EventBus:clear
-- Removes all listeners for a specific event.
-- Pair with the matching constructor to free resources.
local eventBus = lurek.patterns.newEventBus()
eventBus:clear(event)
-- eventBus is now released
print("ok")

--@api-stub: EventBus:clearAll
-- Removes all listeners on this EventBus.
-- Pair with the matching constructor to free resources.
local eventBus = lurek.patterns.newEventBus()
eventBus:clearAll()
-- eventBus is now released
print("ok")

--@api-stub: EventBus:getListenerCount
-- Returns the number of listeners registered for an event.
-- Cheap to call; safe inside callbacks.
local eventBus = lurek.patterns.newEventBus()  -- or your existing handle
local value = eventBus:getListenerCount(event)
print("EventBus:getListenerCount ->", value)

--@api-stub: EventBus:getEvents
-- Returns all event names that have at least one listener.
-- Cheap to call; safe inside callbacks.
local eventBus = lurek.patterns.newEventBus()  -- or your existing handle
local value = eventBus:getEvents()
print("EventBus:getEvents ->", value)

-- ── ObjectPool methods ──

--@api-stub: ObjectPool:add
-- Inserts a pre-built object into the available pool.
-- Side-effecting; safe to call any time after init.
local objectPool = lurek.patterns.newObjectPool()
objectPool:add(value)
print("ObjectPool:add done")

--@api-stub: ObjectPool:acquire
-- Acquires an available object from the pool; returns nil if empty.
-- See the module spec for detailed semantics.
local objectPool = lurek.patterns.newObjectPool()
objectPool:acquire()
print("ObjectPool:acquire done")

--@api-stub: ObjectPool:release
-- Returns an object to the available pool.
-- See the module spec for detailed semantics.
local objectPool = lurek.patterns.newObjectPool()
objectPool:release(value)
print("ObjectPool:release done")

--@api-stub: ObjectPool:getActiveCount
-- Returns the number of currently active (acquired) objects.
-- Cheap to call; safe inside callbacks.
local objectPool = lurek.patterns.newObjectPool()  -- or your existing handle
local value = objectPool:getActiveCount()
print("ObjectPool:getActiveCount ->", value)

--@api-stub: ObjectPool:getAvailableCount
-- Returns the number of available (idle) objects in the pool.
-- Cheap to call; safe inside callbacks.
local objectPool = lurek.patterns.newObjectPool()  -- or your existing handle
local value = objectPool:getAvailableCount()
print("ObjectPool:getAvailableCount ->", value)

--@api-stub: ObjectPool:getTotalCount
-- Returns the total number of tracked objects (active + available).
-- Cheap to call; safe inside callbacks.
local objectPool = lurek.patterns.newObjectPool()  -- or your existing handle
local value = objectPool:getTotalCount()
print("ObjectPool:getTotalCount ->", value)

--@api-stub: ObjectPool:clearAll
-- Clears all objects from the pool, releasing Lua registry values.
-- Pair with the matching constructor to free resources.
local objectPool = lurek.patterns.newObjectPool()
objectPool:clearAll()
-- objectPool is now released
print("ok")

-- ── CommandStack methods ──

--@api-stub: CommandStack:execute
-- Executes a named command and records it in undo/redo history.
-- Trigger from input, timers, or game events.
local commandStack = lurek.patterns.newCommandStack()
commandStack:execute("main", function() print("execute fired") end, function() print("execute fired") end)
-- trigger from input, timer, or event
print("ok")

--@api-stub: CommandStack:undo
-- Undoes the most recent command.
-- See the module spec for detailed semantics.
local commandStack = lurek.patterns.newCommandStack()
commandStack:undo()
print("CommandStack:undo done")

--@api-stub: CommandStack:redo
-- Re-executes the next undone command.
-- See the module spec for detailed semantics.
local commandStack = lurek.patterns.newCommandStack()
commandStack:redo()
print("CommandStack:redo done")

--@api-stub: CommandStack:canUndo
-- Returns true if the most recent command can be undone.
-- Use as a guard inside lurek.update or event handlers.
local commandStack = lurek.patterns.newCommandStack()
if commandStack:canUndo() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: CommandStack:canRedo
-- Returns true if there is a command available to redo.
-- Use as a guard inside lurek.update or event handlers.
local commandStack = lurek.patterns.newCommandStack()
if commandStack:canRedo() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: CommandStack:getHistorySize
-- Returns the total number of recorded commands (undo + redo).
-- Cheap to call; safe inside callbacks.
local commandStack = lurek.patterns.newCommandStack()  -- or your existing handle
local value = commandStack:getHistorySize()
print("CommandStack:getHistorySize ->", value)

--@api-stub: CommandStack:getCurrentName
-- Returns the name of the most recently executed command, or nil.
-- Cheap to call; safe inside callbacks.
local commandStack = lurek.patterns.newCommandStack()  -- or your existing handle
local value = commandStack:getCurrentName()
print("CommandStack:getCurrentName ->", value)

--@api-stub: CommandStack:clearAll
-- Clears all command history, releasing Lua registry values.
-- Pair with the matching constructor to free resources.
local commandStack = lurek.patterns.newCommandStack()
commandStack:clearAll()
-- commandStack is now released
print("ok")

-- ── ServiceLocator methods ──

--@api-stub: ServiceLocator:provide
-- Registers a named service with an associated Lua value.
-- See the module spec for detailed semantics.
local serviceLocator = lurek.patterns.newServiceLocator()
serviceLocator:provide("main", value)
print("ServiceLocator:provide done")

--@api-stub: ServiceLocator:locate
-- Retrieves a registered service by name; returns nil if not found.
-- See the module spec for detailed semantics.
local serviceLocator = lurek.patterns.newServiceLocator()
serviceLocator:locate("main")
print("ServiceLocator:locate done")

--@api-stub: ServiceLocator:has
-- Returns true if a service with the given name is registered.
-- See the module spec for detailed semantics.
local serviceLocator = lurek.patterns.newServiceLocator()
serviceLocator:has("main")
print("ServiceLocator:has done")

--@api-stub: ServiceLocator:remove
-- Unregisters and removes a named service.
-- Pair with the matching constructor to free resources.
local serviceLocator = lurek.patterns.newServiceLocator()
serviceLocator:remove("main")
-- serviceLocator is now released
print("ok")

--@api-stub: ServiceLocator:getServices
-- Returns a table of all registered service names.
-- Cheap to call; safe inside callbacks.
local serviceLocator = lurek.patterns.newServiceLocator()  -- or your existing handle
local value = serviceLocator:getServices()
print("ServiceLocator:getServices ->", value)

--@api-stub: ServiceLocator:clearAll
-- Removes all registered services.
-- Pair with the matching constructor to free resources.
local serviceLocator = lurek.patterns.newServiceLocator()
serviceLocator:clearAll()
-- serviceLocator is now released
print("ok")

-- ── Factory methods ──

--@api-stub: Factory:register
-- Registers a named type constructor function.
-- Side-effecting; safe to call any time after init.
local factory = lurek.patterns.newFactory()
factory:register("main", ctor)
print("Factory:register done")

--@api-stub: Factory:create
-- Creates an instance of the named type by invoking its constructor.
-- Build once at startup; reuse across frames.
local factory = lurek.patterns.newFactory()
factory:create({ x = 0, y = 0 })
print("Factory:create done")

--@api-stub: Factory:has
-- Returns true if the named type (or alias) is registered.
-- See the module spec for detailed semantics.
local factory = lurek.patterns.newFactory()
factory:has("main")
print("Factory:has done")

--@api-stub: Factory:alias
-- Registers an alias pointing to an existing canonical type name.
-- See the module spec for detailed semantics.
local factory = lurek.patterns.newFactory()
factory:alias(alias, canonical)
print("Factory:alias done")

--@api-stub: Factory:getTypes
-- Returns a table of all registered type names.
-- Cheap to call; safe inside callbacks.
local factory = lurek.patterns.newFactory()  -- or your existing handle
local value = factory:getTypes()
print("Factory:getTypes ->", value)

--@api-stub: Factory:remove
-- Unregisters a type constructor (and any aliases pointing to it).
-- Pair with the matching constructor to free resources.
local factory = lurek.patterns.newFactory()
factory:remove("main")
-- factory is now released
print("ok")

--@api-stub: Factory:clearAll
-- Removes all registered type constructors and aliases.
-- Pair with the matching constructor to free resources.
local factory = lurek.patterns.newFactory()
factory:clearAll()
-- factory is now released
print("ok")

-- ── SimpleState methods ──

--@api-stub: SimpleState:addState
-- Registers a named state with optional enter, exit, and update callbacks.
-- Side-effecting; safe to call any time after init.
local simpleState = lurek.patterns.newSimpleState()
simpleState:addState("main", function() print("addState fired") end)
print("SimpleState:addState done")

--@api-stub: SimpleState:transitionTo
-- Transitions to a named state, calling exit/enter callbacks as needed.
-- See the module spec for detailed semantics.
local simpleState = lurek.patterns.newSimpleState()
simpleState:transitionTo("main")
print("SimpleState:transitionTo done")

--@api-stub: SimpleState:update
-- Calls the update callback of the current state with the given delta time.
-- Apply at startup or in response to user input.
local simpleState = lurek.patterns.newSimpleState()
simpleState:update(dt)
print("SimpleState:update applied")

--@api-stub: SimpleState:getCurrent
-- Returns the name of the current state, or nil if none is active.
-- Cheap to call; safe inside callbacks.
local simpleState = lurek.patterns.newSimpleState()  -- or your existing handle
local value = simpleState:getCurrent()
print("SimpleState:getCurrent ->", value)

--@api-stub: SimpleState:hasState
-- Returns true if a state with the given name is registered.
-- Use as a guard inside lurek.update or event handlers.
local simpleState = lurek.patterns.newSimpleState()
if simpleState:hasState("main") then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: SimpleState:getStates
-- Returns a table of all registered state names.
-- Cheap to call; safe inside callbacks.
local simpleState = lurek.patterns.newSimpleState()  -- or your existing handle
local value = simpleState:getStates()
print("SimpleState:getStates ->", value)

--@api-stub: SimpleState:clearAll
-- Removes all states and callbacks from this state machine.
-- Pair with the matching constructor to free resources.
local simpleState = lurek.patterns.newSimpleState()
simpleState:clearAll()
-- simpleState is now released
print("ok")

-- ── Blackboard methods ──

--@api-stub: Blackboard:set
-- Sets a fact on the blackboard.
-- Apply at startup or in response to user input.
local blackboard = lurek.patterns.newBlackboard()
blackboard:set("space", value)
print("Blackboard:set applied")

--@api-stub: Blackboard:get
-- Gets a fact from the blackboard.
-- Cheap to call; safe inside callbacks.
local blackboard = lurek.patterns.newBlackboard()  -- or your existing handle
local value = blackboard:get("space")
print("Blackboard:get ->", value)

--@api-stub: Blackboard:has
-- Returns true when the key has a non-nil value.
-- See the module spec for detailed semantics.
local blackboard = lurek.patterns.newBlackboard()
blackboard:has("space")
print("Blackboard:has done")

--@api-stub: Blackboard:clear
-- Removes a fact from the blackboard.
-- Pair with the matching constructor to free resources.
local blackboard = lurek.patterns.newBlackboard()
blackboard:clear("space")
-- blackboard is now released
print("ok")

--@api-stub: Blackboard:keys
-- Returns all set fact keys as a table.
-- See the module spec for detailed semantics.
local blackboard = lurek.patterns.newBlackboard()
blackboard:keys()
print("Blackboard:keys done")

--@api-stub: Blackboard:watch
-- Subscribes to changes on a specific key (or "*" for all changes).
-- See the module spec for detailed semantics.
local blackboard = lurek.patterns.newBlackboard()
blackboard:watch("space", function() print("watch fired") end)
print("Blackboard:watch done")

--@api-stub: Blackboard:unwatch
-- Removes a watcher subscription by id.
-- See the module spec for detailed semantics.
local blackboard = lurek.patterns.newBlackboard()
blackboard:unwatch(1)
print("Blackboard:unwatch done")

--@api-stub: Blackboard:getRevision
-- Returns the monotonic revision counter (incremented on every write).
-- Cheap to call; safe inside callbacks.
local blackboard = lurek.patterns.newBlackboard()  -- or your existing handle
local value = blackboard:getRevision()
print("Blackboard:getRevision ->", value)

--@api-stub: Blackboard:snapshot
-- Returns all facts as a flat keyâ†’value table.
-- See the module spec for detailed semantics.
local blackboard = lurek.patterns.newBlackboard()
blackboard:snapshot()
print("Blackboard:snapshot done")

--@api-stub: Blackboard:clearAll
-- Clears all facts from the blackboard.
-- Pair with the matching constructor to free resources.
local blackboard = lurek.patterns.newBlackboard()
blackboard:clearAll()
-- blackboard is now released
print("ok")

-- ── Observer methods ──

--@api-stub: Observer:set
-- Sets a property value and fires subscribed watchers.
-- Apply at startup or in response to user input.
local observer = lurek.patterns.newObserver()
observer:set("space", new_val)
print("Observer:set applied")

--@api-stub: Observer:get
-- Gets a property value, or nil if not set.
-- Cheap to call; safe inside callbacks.
local observer = lurek.patterns.newObserver()  -- or your existing handle
local value = observer:get("space")
print("Observer:get ->", value)

--@api-stub: Observer:subscribe
-- Subscribes to changes on a property key (or "*" for all).
-- See the module spec for detailed semantics.
local observer = lurek.patterns.newObserver()
observer:subscribe("space", function() print("subscribe fired") end, once)
print("Observer:subscribe done")

--@api-stub: Observer:unsubscribe
-- Removes a subscription by id.
-- See the module spec for detailed semantics.
local observer = lurek.patterns.newObserver()
observer:unsubscribe(1)
print("Observer:unsubscribe done")

--@api-stub: Observer:getCount
-- Returns the total number of active subscriptions.
-- Cheap to call; safe inside callbacks.
local observer = lurek.patterns.newObserver()  -- or your existing handle
local value = observer:getCount()
print("Observer:getCount ->", value)

-- ── Throttle methods ──

--@api-stub: Throttle:onFire
-- Sets the callback invoked when the throttle fires.
-- See the module spec for detailed semantics.
local throttle = lurek.patterns.newThrottle()
throttle:onFire(f)
print("Throttle:onFire done")

--@api-stub: Throttle:update
-- Advances the timer by dt seconds; fires the callback if the interval elapsed.
-- Apply at startup or in response to user input.
local throttle = lurek.patterns.newThrottle()
throttle:update(dt)
print("Throttle:update applied")

--@api-stub: Throttle:reset
-- Resets the elapsed counter without firing.
-- Pair with the matching constructor to free resources.
local throttle = lurek.patterns.newThrottle()
throttle:reset()
-- throttle is now released
print("ok")

--@api-stub: Throttle:getProgress
-- Returns the normalised progress through the current interval [0, 1].
-- Cheap to call; safe inside callbacks.
local throttle = lurek.patterns.newThrottle()  -- or your existing handle
local value = throttle:getProgress()
print("Throttle:getProgress ->", value)

--@api-stub: Throttle:getFireCount
-- Returns the total number of times this throttle has fired.
-- Cheap to call; safe inside callbacks.
local throttle = lurek.patterns.newThrottle()  -- or your existing handle
local value = throttle:getFireCount()
print("Throttle:getFireCount ->", value)

--@api-stub: Throttle:setEnabled
-- Enables or disables the throttle.
-- Apply at startup or in response to user input.
local throttle = lurek.patterns.newThrottle()
throttle:setEnabled(v)
print("Throttle:setEnabled applied")

-- ── Debounce methods ──

--@api-stub: Debounce:onFire
-- Sets the callback invoked when the debounce fires.
-- See the module spec for detailed semantics.
local debounce = lurek.patterns.newDebounce()
debounce:onFire(f)
print("Debounce:onFire done")

--@api-stub: Debounce:trigger
-- Records an input event, resetting the idle timer.
-- See the module spec for detailed semantics.
local debounce = lurek.patterns.newDebounce()
debounce:trigger()
print("Debounce:trigger done")

--@api-stub: Debounce:update
-- Advances the idle timer by dt seconds; fires the callback if idle wait expired.
-- Apply at startup or in response to user input.
local debounce = lurek.patterns.newDebounce()
debounce:update(dt)
print("Debounce:update applied")

--@api-stub: Debounce:cancel
-- Cancels the pending trigger without firing.
-- Pair with the matching constructor to free resources.
local debounce = lurek.patterns.newDebounce()
debounce:cancel()
-- debounce is now released
print("ok")

--@api-stub: Debounce:isPending
-- Returns true when a trigger is pending.
-- Use as a guard inside lurek.update or event handlers.
local debounce = lurek.patterns.newDebounce()
if debounce:isPending() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Debounce:getFireCount
-- Returns the total number of times this debounce has fired.
-- Cheap to call; safe inside callbacks.
local debounce = lurek.patterns.newDebounce()  -- or your existing handle
local value = debounce:getFireCount()
print("Debounce:getFireCount ->", value)

-- ── PriorityQueue methods ──

--@api-stub: PriorityQueue:push
-- Inserts an item with a priority.
-- Side-effecting; safe to call any time after init.
local priorityQueue = lurek.patterns.newPriorityQueue()
priorityQueue:push(priority, value, "main")
print("PriorityQueue:push done")

--@api-stub: PriorityQueue:pop
-- Removes and returns the highest-priority item, or nil if empty.
-- Pair with the matching constructor to free resources.
local priorityQueue = lurek.patterns.newPriorityQueue()
priorityQueue:pop()
-- priorityQueue is now released
print("ok")

--@api-stub: PriorityQueue:peek
-- Returns the highest-priority item without removing it, or nil if empty.
-- Cheap to call; safe inside callbacks.
local priorityQueue = lurek.patterns.newPriorityQueue()  -- or your existing handle
local value = priorityQueue:peek()
print("PriorityQueue:peek ->", value)

--@api-stub: PriorityQueue:len
-- Returns the number of items in the queue.
-- See the module spec for detailed semantics.
local priorityQueue = lurek.patterns.newPriorityQueue()
priorityQueue:len()
print("PriorityQueue:len done")

--@api-stub: PriorityQueue:isEmpty
-- Returns true when the queue has no items.
-- Use as a guard inside lurek.update or event handlers.
local priorityQueue = lurek.patterns.newPriorityQueue()
if priorityQueue:isEmpty() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: PriorityQueue:clearAll
-- Removes all items from the queue.
-- Pair with the matching constructor to free resources.
local priorityQueue = lurek.patterns.newPriorityQueue()
priorityQueue:clearAll()
-- priorityQueue is now released
print("ok")

-- ── Ring methods ──

--@api-stub: Ring:push
-- Pushes a value (number or string) with an optional tag.
-- Side-effecting; safe to call any time after init.
local ring = lurek.patterns.newRing()
ring:push(value, "main")
print("Ring:push done")

--@api-stub: Ring:latest
-- Returns the most recently pushed entry, or nil.
-- See the module spec for detailed semantics.
local ring = lurek.patterns.newRing()
ring:latest()
print("Ring:latest done")

--@api-stub: Ring:toArray
-- Returns all entries (oldest first) as an array of {id, tag, value?, text?} tables.
-- See the module spec for detailed semantics.
local ring = lurek.patterns.newRing()
ring:toArray()
print("Ring:toArray done")

--@api-stub: Ring:sum
-- Returns the sum of all numeric values in the ring.
-- See the module spec for detailed semantics.
local ring = lurek.patterns.newRing()
ring:sum()
print("Ring:sum done")

--@api-stub: Ring:average
-- Returns the average of all numeric values, or 0 if empty.
-- See the module spec for detailed semantics.
local ring = lurek.patterns.newRing()
ring:average()
print("Ring:average done")

--@api-stub: Ring:len
-- Returns the number of entries currently in the ring.
-- See the module spec for detailed semantics.
local ring = lurek.patterns.newRing()
ring:len()
print("Ring:len done")

--@api-stub: Ring:isFull
-- Returns true when the ring is at capacity.
-- Use as a guard inside lurek.update or event handlers.
local ring = lurek.patterns.newRing()
if ring:isFull() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Ring:clear
-- Removes all entries from the ring.
-- Pair with the matching constructor to free resources.
local ring = lurek.patterns.newRing()
ring:clear()
-- ring is now released
print("ok")

-- ── Funnel methods ──

--@api-stub: Funnel:onFlush
-- Sets a callback invoked when the funnel flushes.
-- See the module spec for detailed semantics.
local funnel = lurek.patterns.newFunnel()
funnel:onFlush(f)
print("Funnel:onFlush done")

--@api-stub: Funnel:push
-- Adds an event to the funnel.
-- Side-effecting; safe to call any time after init.
local funnel = lurek.patterns.newFunnel()
funnel:push("main", value)
print("Funnel:push done")

--@api-stub: Funnel:update
-- Advances the window timer by dt seconds; flushes when window expires.
-- Apply at startup or in response to user input.
local funnel = lurek.patterns.newFunnel()
funnel:update(dt)
print("Funnel:update applied")

--@api-stub: Funnel:flush
-- Manually flushes all pending entries, invoking the onFlush callback.
-- See the module spec for detailed semantics.
local funnel = lurek.patterns.newFunnel()
funnel:flush()
print("Funnel:flush done")

--@api-stub: Funnel:discard
-- Discards all buffered entries without flushing.
-- See the module spec for detailed semantics.
local funnel = lurek.patterns.newFunnel()
funnel:discard()
print("Funnel:discard done")

--@api-stub: Funnel:pendingCount
-- Returns the number of buffered entries not yet flushed.
-- See the module spec for detailed semantics.
local funnel = lurek.patterns.newFunnel()
funnel:pendingCount()
print("Funnel:pendingCount done")

--@api-stub: Funnel:getFlushCount
-- Returns the total number of flushes performed.
-- Cheap to call; safe inside callbacks.
local funnel = lurek.patterns.newFunnel()  -- or your existing handle
local value = funnel:getFlushCount()
print("Funnel:getFlushCount ->", value)

-- ── RelationshipManager methods ──

--@api-stub: RelationshipManager:defineType
-- Defines a relationship type with ordered levels.
-- See the module spec for detailed semantics.
local relationshipManager = lurek.patterns.newRelationshipManager()
relationshipManager:defineType("main", levels, default_level)
print("RelationshipManager:defineType done")

--@api-stub: RelationshipManager:removeType
-- Removes a relationship type definition.
-- Pair with the matching constructor to free resources.
local relationshipManager = lurek.patterns.newRelationshipManager()
relationshipManager:removeType("main")
-- relationshipManager is now released
print("ok")

--@api-stub: RelationshipManager:typeNames
-- Returns all defined relationship type names.
-- See the module spec for detailed semantics.
local relationshipManager = lurek.patterns.newRelationshipManager()
relationshipManager:typeNames()
print("RelationshipManager:typeNames done")

--@api-stub: RelationshipManager:setValue
-- Sets the numeric relationship value between two entities.
-- Apply at startup or in response to user input.
local relationshipManager = lurek.patterns.newRelationshipManager()
relationshipManager:setValue(1, 0, value)
print("RelationshipManager:setValue applied")

--@api-stub: RelationshipManager:getValue
-- Returns the numeric relationship value between two entities (default 0.0).
-- Cheap to call; safe inside callbacks.
local relationshipManager = lurek.patterns.newRelationshipManager()  -- or your existing handle
local value = relationshipManager:getValue(1, 0)
print("RelationshipManager:getValue ->", value)

--@api-stub: RelationshipManager:adjustValue
-- Adjusts the numeric relationship value by a delta.
-- See the module spec for detailed semantics.
local relationshipManager = lurek.patterns.newRelationshipManager()
relationshipManager:adjustValue(1, 0, dt)
print("RelationshipManager:adjustValue done")

--@api-stub: RelationshipManager:setLevel
-- Sets a named level for a typed relationship between two entities.
-- Apply at startup or in response to user input.
local relationshipManager = lurek.patterns.newRelationshipManager()
relationshipManager:setLevel(1, 0, "main", level)
print("RelationshipManager:setLevel applied")

--@api-stub: RelationshipManager:getLevel
-- Returns the named level for a typed relationship, or nil.
-- Cheap to call; safe inside callbacks.
local relationshipManager = lurek.patterns.newRelationshipManager()  -- or your existing handle
local value = relationshipManager:getLevel(1, 0, "main")
print("RelationshipManager:getLevel ->", value)

--@api-stub: RelationshipManager:removePair
-- Removes all relationship data between two entities.
-- Pair with the matching constructor to free resources.
local relationshipManager = lurek.patterns.newRelationshipManager()
relationshipManager:removePair(1, 0)
-- relationshipManager is now released
print("ok")

--@api-stub: RelationshipManager:pairCount
-- Returns the total number of stored relationship pairs.
-- See the module spec for detailed semantics.
local relationshipManager = lurek.patterns.newRelationshipManager()
relationshipManager:pairCount()
print("RelationshipManager:pairCount done")

-- ── Mediator methods ──

--@api-stub: Mediator:on
-- Registers a handler callback on a channel; returns handler ID.
-- See the module spec for detailed semantics.
local mediator = lurek.patterns.newMediator()
mediator:on(channel, function() print("on fired") end)
print("Mediator:on done")

--@api-stub: Mediator:off
-- Unregisters a handler by ID.
-- See the module spec for detailed semantics.
local mediator = lurek.patterns.newMediator()
mediator:off(channel, 1)
print("Mediator:off done")

--@api-stub: Mediator:send
-- Dispatches a message to all handlers on a channel.
-- See the module spec for detailed semantics.
local mediator = lurek.patterns.newMediator()
mediator:send({ x = 0, y = 0 })
print("Mediator:send done")

--@api-stub: Mediator:broadcast
-- Dispatches a message to all handlers across all channels.
-- See the module spec for detailed semantics.
local mediator = lurek.patterns.newMediator()
mediator:broadcast({ x = 0, y = 0 })
print("Mediator:broadcast done")

--@api-stub: Mediator:handlerCount
-- Returns the number of handlers on a channel.
-- See the module spec for detailed semantics.
local mediator = lurek.patterns.newMediator()
mediator:handlerCount(channel)
print("Mediator:handlerCount done")

--@api-stub: Mediator:channels
-- Returns all registered channel names.
-- See the module spec for detailed semantics.
local mediator = lurek.patterns.newMediator()
mediator:channels()
print("Mediator:channels done")

--@api-stub: Mediator:removeChannel
-- Removes a channel and all its handlers.
-- Pair with the matching constructor to free resources.
local mediator = lurek.patterns.newMediator()
mediator:removeChannel(channel)
-- mediator is now released
print("ok")

--@api-stub: Mediator:clear
-- Removes all channels and handlers.
-- Pair with the matching constructor to free resources.
local mediator = lurek.patterns.newMediator()
mediator:clear()
-- mediator is now released
print("ok")

-- ── Strategy methods ──

--@api-stub: Strategy:register
-- Registers a named strategy function.
-- Side-effecting; safe to call any time after init.
local strategy = lurek.patterns.newStrategy()
strategy:register("main", function() print("register fired") end)
print("Strategy:register done")

--@api-stub: Strategy:set
-- Sets the active strategy by name.
-- Apply at startup or in response to user input.
local strategy = lurek.patterns.newStrategy()
strategy:set("main")
print("Strategy:set applied")

--@api-stub: Strategy:execute
-- Calls the currently active strategy function with the given arguments.
-- Trigger from input, timers, or game events.
local strategy = lurek.patterns.newStrategy()
strategy:execute({ x = 0, y = 0 })
-- trigger from input, timer, or event
print("ok")

--@api-stub: Strategy:getCurrent
-- Returns the name of the active strategy, or nil.
-- Cheap to call; safe inside callbacks.
local strategy = lurek.patterns.newStrategy()  -- or your existing handle
local value = strategy:getCurrent()
print("Strategy:getCurrent ->", value)

--@api-stub: Strategy:has
-- Returns true if a strategy with this name is registered.
-- See the module spec for detailed semantics.
local strategy = lurek.patterns.newStrategy()
strategy:has("main")
print("Strategy:has done")

--@api-stub: Strategy:remove
-- Removes a strategy by name.
-- Pair with the matching constructor to free resources.
local strategy = lurek.patterns.newStrategy()
strategy:remove("main")
-- strategy is now released
print("ok")

--@api-stub: Strategy:names
-- Returns all registered strategy names.
-- See the module spec for detailed semantics.
local strategy = lurek.patterns.newStrategy()
strategy:names()
print("Strategy:names done")

--@api-stub: Strategy:clear
-- Removes all strategies and clears the active selection.
-- Pair with the matching constructor to free resources.
local strategy = lurek.patterns.newStrategy()
strategy:clear()
-- strategy is now released
print("ok")

-- ── Stack methods ──

--@api-stub: Stack:push
-- Pushes a value onto the stack.
-- Side-effecting; safe to call any time after init.
local stack = lurek.patterns.newStack()
stack:push(value)
print("Stack:push done")

--@api-stub: Stack:pop
-- Removes and returns the top value, or nil if empty.
-- Pair with the matching constructor to free resources.
local stack = lurek.patterns.newStack()
stack:pop()
-- stack is now released
print("ok")

--@api-stub: Stack:peek
-- Returns the top value without removing it, or nil if empty.
-- Cheap to call; safe inside callbacks.
local stack = lurek.patterns.newStack()  -- or your existing handle
local value = stack:peek()
print("Stack:peek ->", value)

--@api-stub: Stack:len
-- Returns the number of items on the stack.
-- See the module spec for detailed semantics.
local stack = lurek.patterns.newStack()
stack:len()
print("Stack:len done")

--@api-stub: Stack:isEmpty
-- Returns true if the stack is empty.
-- Use as a guard inside lurek.update or event handlers.
local stack = lurek.patterns.newStack()
if stack:isEmpty() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Stack:isFull
-- Returns true if the stack is at its capacity limit.
-- Use as a guard inside lurek.update or event handlers.
local stack = lurek.patterns.newStack()
if stack:isFull() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Stack:clear
-- Removes all values from the stack.
-- Pair with the matching constructor to free resources.
local stack = lurek.patterns.newStack()
stack:clear()
-- stack is now released
print("ok")

--@api-stub: Stack:toArray
-- Returns all items as a Lua table (bottom to top).
-- See the module spec for detailed semantics.
local stack = lurek.patterns.newStack()
stack:toArray()
print("Stack:toArray done")

-- ── Queue methods ──

--@api-stub: Queue:enqueue
-- Adds a value to the back of the queue.
-- See the module spec for detailed semantics.
local queue = lurek.patterns.newQueue()
queue:enqueue(value)
print("Queue:enqueue done")

--@api-stub: Queue:dequeue
-- Removes and returns the front value, or nil if empty.
-- See the module spec for detailed semantics.
local queue = lurek.patterns.newQueue()
queue:dequeue()
print("Queue:dequeue done")

--@api-stub: Queue:front
-- Returns the front value without removing it, or nil if empty.
-- See the module spec for detailed semantics.
local queue = lurek.patterns.newQueue()
queue:front()
print("Queue:front done")

--@api-stub: Queue:len
-- Returns the number of items in the queue.
-- See the module spec for detailed semantics.
local queue = lurek.patterns.newQueue()
queue:len()
print("Queue:len done")

--@api-stub: Queue:isEmpty
-- Returns true if the queue is empty.
-- Use as a guard inside lurek.update or event handlers.
local queue = lurek.patterns.newQueue()
if queue:isEmpty() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Queue:isFull
-- Returns true if the queue is at its capacity limit.
-- Use as a guard inside lurek.update or event handlers.
local queue = lurek.patterns.newQueue()
if queue:isFull() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Queue:clear
-- Removes all values from the queue.
-- Pair with the matching constructor to free resources.
local queue = lurek.patterns.newQueue()
queue:clear()
-- queue is now released
print("ok")

--@api-stub: Queue:toArray
-- Returns all items as a Lua table (front to back).
-- See the module spec for detailed semantics.
local queue = lurek.patterns.newQueue()
queue:toArray()
print("Queue:toArray done")

-- ── List methods ──

--@api-stub: List:add
-- Appends a value to the end of the list.
-- Side-effecting; safe to call any time after init.
local list = lurek.patterns.newList()
list:add(value)
print("List:add done")

--@api-stub: List:get
-- Returns the value at a 1-based index, or nil.
-- Cheap to call; safe inside callbacks.
local list = lurek.patterns.newList()  -- or your existing handle
local value = list:get(1)
print("List:get ->", value)

--@api-stub: List:set
-- Replaces the value at a 1-based index.
-- Apply at startup or in response to user input.
local list = lurek.patterns.newList()
list:set(1, value)
print("List:set applied")

--@api-stub: List:remove
-- Removes and returns the value at a 1-based index.
-- Pair with the matching constructor to free resources.
local list = lurek.patterns.newList()
list:remove(1)
-- list is now released
print("ok")

--@api-stub: List:len
-- Returns the number of items in the list.
-- See the module spec for detailed semantics.
local list = lurek.patterns.newList()
list:len()
print("List:len done")

--@api-stub: List:isEmpty
-- Returns true if the list is empty.
-- Use as a guard inside lurek.update or event handlers.
local list = lurek.patterns.newList()
if list:isEmpty() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: List:contains
-- Returns true if the list contains a value equal to the given Lua value (string/number/boolean).
-- See the module spec for detailed semantics.
local list = lurek.patterns.newList()
list:contains(value)
print("List:contains done")

--@api-stub: List:clear
-- Removes all values from the list.
-- Pair with the matching constructor to free resources.
local list = lurek.patterns.newList()
list:clear()
-- list is now released
print("ok")

--@api-stub: List:toArray
-- Returns all items as a Lua table.
-- See the module spec for detailed semantics.
local list = lurek.patterns.newList()
list:toArray()
print("List:toArray done")

-- ── Set methods ──

--@api-stub: Set:add
-- Adds a string key to the set.
-- Side-effecting; safe to call any time after init.
local set = lurek.patterns.newSet()
set:add("space")
print("Set:add done")

--@api-stub: Set:remove
-- Removes a key from the set.
-- Pair with the matching constructor to free resources.
local set = lurek.patterns.newSet()
set:remove("space")
-- set is now released
print("ok")

--@api-stub: Set:has
-- Returns true if the key is in the set.
-- See the module spec for detailed semantics.
local set = lurek.patterns.newSet()
set:has("space")
print("Set:has done")

--@api-stub: Set:len
-- Returns the number of distinct keys in the set.
-- See the module spec for detailed semantics.
local set = lurek.patterns.newSet()
set:len()
print("Set:len done")

--@api-stub: Set:isEmpty
-- Returns true if the set is empty.
-- Use as a guard inside lurek.update or event handlers.
local set = lurek.patterns.newSet()
if set:isEmpty() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Set:toArray
-- Returns all keys as a Lua table (unordered).
-- See the module spec for detailed semantics.
local set = lurek.patterns.newSet()
set:toArray()
print("Set:toArray done")

--@api-stub: Set:clear
-- Removes all keys from the set.
-- Pair with the matching constructor to free resources.
local set = lurek.patterns.newSet()
set:clear()
-- set is now released
print("ok")

--@api-stub: Set:union
-- Returns the union of this set and another as a new Set.
-- See the module spec for detailed semantics.
local set = lurek.patterns.newSet()
set:union(other)
print("Set:union done")

--@api-stub: Set:intersection
-- Returns the intersection of this set and another as a new Set.
-- See the module spec for detailed semantics.
local set = lurek.patterns.newSet()
set:intersection(other)
print("Set:intersection done")

