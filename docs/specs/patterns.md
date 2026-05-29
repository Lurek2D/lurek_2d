# patterns

## TL;DR

- The `patterns` module is a fundamental Foundations tier library providing a comprehensive suite of twelve classic game-programming design patterns and robust data structures for Lurek2D.

## General Info

- Module group: `Foundations`
- Source path: `src/patterns/`
- Lua API path(s): `src/lua_api/patterns_api.rs`
- Primary Lua namespace: `lurek.patterns`
- Rust test path(s): tests/rust/unit/patterns_tests.rs
- Lua test path(s): tests/lua/unit/test_patterns_core_unit.lua; tests/lua/stress/test_patterns_stress.lua

## Summary

Designed to be highly reusable, completely decoupled from one another, and fully exposed to the Lua environment, these primitives act as high-level building blocks for complex game logic. At the core of AI decision-making is the `BehaviorTree` system, featuring Sequences, Selectors, Parallels, Inverters, Repeats, and Leaf action nodes. For transition-heavy logic, the module offers a hierarchical `StateMachine` with enter/exit/update callbacks, explicit transition rules, and bounded history, alongside a `SimpleState` alternative for simpler needs.

To facilitate decoupled communication across systems, the module provides a robust `EventBus` for pub-sub messaging with wildcard listeners and prioritized execution, as well as a channel-based `Mediator`. The `Observer` pattern is available for reactive property-change notifications, and the `Blackboard` provides a shared, typed key-value store with revision tracking—essential for coordinating AI state. For undo/redo functionality (e.g., in editors or turn-based games), the `CommandStack` offers a cursor-based linear history with batching support. Resource management is handled by the `ObjectPool`, which tracks active and idle IDs to reduce allocation churn for frequently spawned entities like bullets or particles. The `Factory` and `ServiceLocator` patterns provide dynamic object construction and dependency injection.

The module also includes specialized data structures optimized for game development. These include a `Graph` (directed/undirected with BFS/DFS traversals), a `Trie` for rapid prefix searches, a `BiMap` for bidirectional lookups, and a `PriorityQueue` with stable FIFO tie-breaking. Time-based operations are supported by a `Ring` buffer for fixed-size rolling histories (useful for telemetry or combo tracking), a `Funnel` for batching events over a time window, and `Throttle`/`Debounce` primitives for rate-limiting inputs or actions. Additionally, the `WeightedRandom` selector enables deterministic, dynamic picking with or without replacement. All these tools are instantiated via `lurek.patterns.*` and operate as standalone userdata objects, ensuring script developers have robust, C-speed architectural primitives at their fingertips.

## Files

### behavior_tree.rs

- Behavior tree data structure with Sequence, Selector, Parallel, Inverter, Repeat, and Leaf node kinds.
- Builder API for allocating nodes, linking children, and setting the root.
- Per-tick runtime state tracking running nodes and repeat counters.
- Integer `NodeId` addressing; no heap indirection between parent and child.
- Fully deterministic tick ordering: left-to-right child evaluation.

### bimap.rs

- Bidirectional map with O(1) lookup by key or by value.
- Mirrored forward and reverse `HashMap` tables kept in sync on every mutation.
- Insert, remove-by-key, remove-by-value, and containment checks in both directions.

### blackboard.rs

- Shared key-value store for passing typed state between AI and game systems.
- Supports bool, number, text, and nil entries with per-key revision tracking.
- Global and per-key revision counters enable efficient change detection.
- Optional parent chain for hierarchical lookup (child inherits parent data).
- Typed getters with defaults that walk the parent chain on miss.

### collections.rs

- Capacity metadata types for bounded stacks and queues.
- Full-check logic shared by Lua-facing collection wrappers.
- Zero capacity means unbounded; non-zero enforces a hard limit.

### command_stack.rs

- Linear undo/redo command history with cursor-based navigation.
- Batch grouping for multi-command atomic operations.
- Configurable max-size eviction of oldest entries.

### event_bus.rs

- Named event bus that routes events to prioritized subscriptions.
- Supports wildcard listeners, one-shot subscriptions, and per-event clearing.
- Returns ordered listener ID lists for the Lua callback layer to dispatch.

### factory.rs

- Named type registry with alias support for dynamic object construction.
- Register, unregister, and resolve canonical type names at runtime.
- Alias mapping allows multiple names to reference the same underlying type.

### funnel.rs

- Buffered accumulator that collects tagged numeric entries and flushes on a time window or count threshold.
- Provides push/update/flush lifecycle: push entries, tick time, drain when ready.
- Supports immediate flush (window=0), count-triggered flush, and manual discard.

### graph.rs

- Adjacency-list graph with directed and undirected mode support.
- Node and edge CRUD with stable integer identifiers.
- Weighted, labelled edges with automatic reverse-edge insertion for undirected graphs.
- BFS and DFS traversals from any start node.
- Connectivity queries and neighbour enumeration.

### mediator.rs

- Channel-based mediator for decoupled handler registration and dispatch.
- Register/unregister handlers by string channel with unique ids.
- Query, count, and clear handlers per channel or globally.

### mod.rs

- Reusable game-logic design patterns: state machines, behavior trees, event buses, and object pools.
- Data structures for priority queues, graphs, tries, rings, and bidirectional maps.
- Command stacking, observer subscriptions, throttling, and weighted random selection.

### object_pool.rs

- Capacity-bounded object pool that tracks idle and active ids for reuse.
- Supports acquire/release lifecycle, prewarming, and optional capacity limits.
- Useful for entity recycling, bullet pools, and particle systems.

### observer.rs

- Named observer pattern with per-key subscription lists and wildcard support.
- One-shot (`once`) and persistent subscription modes with auto-cleanup on dispatch.
- Key-scoped and global clear operations for lifecycle management.

### priority_queue.rs

- Sorted priority queue with stable FIFO tie-breaking for equal priorities.
- Push, pop, peek, and remove by id with O(n) insertion via partition point.
- Each item carries an auto-assigned id, priority, label, and sequence number.

### ring.rs

- Fixed-capacity ring buffer backed by `VecDeque` with automatic eviction of oldest entries.
- Each entry carries an optional numeric or string payload plus a caller-assigned tag.
- Provides aggregate helpers (sum, average) and ordered iteration from oldest to newest.

### service_locator.rs

- Name-based service registry for runtime feature discovery.
- Register, unregister, and query string-keyed services.
- Sorted enumeration of all active service names.

### simple_state.rs

- Named-state registry with at-most-one active state at a time.
- Add, remove, query, and switch states; validates transitions against the known set.
- Sorted enumeration and count helpers for introspection.

### state_machine.rs

- Finite state machine with explicit states, guarded transitions, and bounded history.
- Transition rules with optional guards control allowed state changes.
- Maintains a capped history ring of visited states for replay or debugging.

### strategy.rs

- Named-strategy registry with id assignment and current-selection tracking.
- Register, remove, query, and switch strategies by string name.
- Provides id-based lookup for the active strategy.

### throttle.rs

- Rate-limiting primitives: throttle (fire at most once per interval) and debounce (fire after quiet period).
- Both track elapsed time, fire counts, and can be enabled/disabled at runtime.
- Progress query on throttle; trigger/cancel lifecycle on debounce.

### trie.rs

- Prefix trie for character-level string key storage and retrieval.
- Insert, search, remove, and prefix-match operations.
- DFS collection of all keys sharing a common prefix.
- Automatic pruning of empty leaf nodes on removal.

### weighted_random.rs

- Weighted random selection over a dynamic entry list with add/remove/update.
- Single-pick and multi-pick-without-replacement algorithms using normalized samples.
- Revision counter for detecting structural changes and invalidating external caches.

## Lua API Ref

- Binding: `src/lua_api/patterns_api.rs`
- Namespace: `lurek.patterns`

### Functions

- `lurek.patterns.newBehaviorTree`: Create a new behavior tree for AI decision-making with sequences, selectors, parallels, and leaf actions.
- `lurek.patterns.newBlackboard`: Create a new shared key-value blackboard supporting reactive watchers for game logic variables.
- `lurek.patterns.newCommandStack`: Create a new undo/redo command stack for recording and reversing player or editor actions.
- `lurek.patterns.newDebounce`: Create a new debounce that delays firing until input stops for a specified wait period.
- `lurek.patterns.newEventBus`: Create a new publish/subscribe event bus for decoupled communication between game systems.
- `lurek.patterns.newFactory`: Create a new factory for producing typed game objects from registered constructor functions.
- `lurek.patterns.newFunnel`: Create a new batching funnel that collects events over a time window and flushes them together.
- `lurek.patterns.newGraph`: Create a new graph data structure with directed or undirected edges, BFS, DFS, and connectivity queries.
- `lurek.patterns.newList`: Create a new dynamic array list with indexed access, insertion, removal, and search.
- `lurek.patterns.newMap`: Create a new string-keyed dictionary (map) with keys/values/entries access and merge support.
- `lurek.patterns.newMediator`: Create a new mediator for channel-based message passing between decoupled game systems.
- `lurek.patterns.newObjectPool`: Create a new object pool for reusing pre-allocated game objects to reduce allocation overhead.
- `lurek.patterns.newObserver`: Create a new reactive observer that stores values and notifies subscribers when they change.
- `lurek.patterns.newPriorityQueue`: Create a new priority queue that orders elements by numeric priority (highest first).
- `lurek.patterns.newQueue`: Create a new FIFO queue with optional capacity limit.
- `lurek.patterns.newRelationshipManager`: Create a new relationship manager for tracking numeric values and named levels between entity pairs.
- `lurek.patterns.newRing`: Create a new fixed-size ring buffer for numeric or string values. Oldest entries are overwritten when full.
- `lurek.patterns.newServiceLocator`: Create a new service locator for registering and retrieving shared services by name at runtime.
- `lurek.patterns.newSet`: Create a new string set with add/remove/has operations and set algebra (union, intersection).
- `lurek.patterns.newSimpleState`: Create a new finite state machine with enter/exit/update callbacks per state.
- `lurek.patterns.newStack`: Create a new LIFO stack with optional capacity limit.
- `lurek.patterns.newStrategy`: Create a new strategy pattern container for hot-swappable algorithm implementations.
- `lurek.patterns.newThrottle`: Create a new throttle that limits how often an action can fire, enforcing a minimum interval.
- `lurek.patterns.newWeightedRandom`: Create a new weighted random selection pool. Add items with weights and pick random selections.

### Enums

- No documented module-level enums/constants.

### Types


#### LBehaviorTree Type


##### Fields

- No documented fields.

##### Methods

- `LBehaviorTree:addChild`: Attach a child node to a parent composite or decorator node.
- `LBehaviorTree:addInverter`: Create a decorator node that inverts its child's result (success ↔ failure).
- `LBehaviorTree:addLeaf`: Create a leaf (action) node that will invoke a named callback function on tick.
- `LBehaviorTree:addParallel`: Create a parallel composite node that runs all children simultaneously.
- `LBehaviorTree:addRepeat`: Create a decorator node that repeats its child a fixed number of times.
- `LBehaviorTree:addSelector`: Create a selector (fallback) composite node. Succeeds if any child succeeds.
- `LBehaviorTree:addSequence`: Create a sequence composite node. All children must succeed for this node to succeed.
- `LBehaviorTree:clearAll`: Remove all nodes and leaf functions, resetting the tree to empty.
- `LBehaviorTree:nodeCount`: Return the total number of nodes in the tree.
- `LBehaviorTree:resetState`: Reset the tree's running state. Use between encounters or when restarting AI logic.
- `LBehaviorTree:setLeaf`: Register or replace the callback function for a named leaf. The function must return "success", "failure", or "running".
- `LBehaviorTree:setRoot`: Designate a node as the tree's root. Tick evaluation starts here.
- `LBehaviorTree:tick`: Execute one tick of the behavior tree from the root. Returns the root node's status.


#### LBlackboard Type


##### Fields

- No documented fields.

##### Methods

- `LBlackboard:clear`: Remove a single key from the blackboard.
- `LBlackboard:clearAll`: Remove all keys and values from the blackboard.
- `LBlackboard:get`: Retrieve the value stored under a key. Returns nil if the key does not exist.
- `LBlackboard:getRevision`: Return the current revision counter. Increments on every value change.
- `LBlackboard:has`: Check whether a key exists on the blackboard.
- `LBlackboard:keys`: Return an array of all keys currently stored on the blackboard.
- `LBlackboard:set`: Set a key to a value (boolean, number, string, or nil to clear). Notifies registered watchers if value changed.
- `LBlackboard:snapshot`: Return a table containing all current key-value pairs as a snapshot. Useful for serialization or debug display.
- `LBlackboard:unwatch`: Remove a previously registered watcher by its ID.
- `LBlackboard:watch`: Register a watcher callback that fires whenever the specified key changes. Use `"*"` to watch all keys.


#### LCommandStack Type


##### Fields

- No documented fields.

##### Methods

- `LCommandStack:canRedo`: Check whether a redo operation is possible (there are commands ahead of the pointer).
- `LCommandStack:canUndo`: Check whether an undo operation is possible (there is a command with an undo function behind the pointer).
- `LCommandStack:clearAll`: Discard all command history and free associated callbacks.
- `LCommandStack:execute`: Execute a named command immediately, recording it in history. Discards any redo history ahead of the current position.
- `LCommandStack:getCurrentName`: Return the name of the most recently executed (or undone-to) command, or nil if history is empty.
- `LCommandStack:getHistorySize`: Return the total number of commands in the history (both undone and available for redo).
- `LCommandStack:redo`: Redo a previously undone command by re-calling its execute function. Moves the pointer forward.
- `LCommandStack:undo`: Undo the most recent command by calling its undo function. Moves the pointer back in history.


#### LDebounce Type


##### Fields

- No documented fields.

##### Methods

- `LDebounce:cancel`: Cancel any pending debounce without firing. The callback will not be called until triggered again.
- `LDebounce:getFireCount`: Return the total number of times this debounce has fired since creation.
- `LDebounce:isPending`: Check whether the debounce is currently waiting to fire (has been triggered but wait period not yet elapsed).
- `LDebounce:onFire`: Set the callback function to invoke when the debounce fires after the wait period.
- `LDebounce:trigger`: Signal input activity. Resets the wait timer so the debounce will fire after the full wait period of inactivity.
- `LDebounce:update`: Advance the debounce timer. If the wait period elapsed since last trigger, fires the callback and returns true.


#### LEventBus Type


##### Fields

- No documented fields.

##### Methods

- `LEventBus:clear`: Remove all listeners subscribed to a specific event name.
- `LEventBus:clearAll`: Remove all listeners from every event on this bus. Resets the bus to empty.
- `LEventBus:emit`: Emit an event, invoking all subscribed listeners in priority order with optional payload arguments.
- `LEventBus:getEvents`: Return an array of all event names that have at least one listener.
- `LEventBus:getListenerCount`: Return the number of active listeners for a given event name.
- `LEventBus:off`: Unsubscribe a listener by its subscription ID. Removes the callback from the event bus.
- `LEventBus:on`: Subscribe a callback to a named event. Higher priority listeners fire first.


#### LFactory Type


##### Fields

- No documented fields.

##### Methods

- `LFactory:alias`: Create an alias that maps to an existing type name. `create(alias)` will use the canonical constructor.
- `LFactory:clearAll`: Remove all registered types and constructors, resetting the factory.
- `LFactory:create`: Create a new object by type name, passing additional arguments to the constructor.
- `LFactory:getTypes`: Return an array of all registered type names.
- `LFactory:has`: Check whether a constructor is registered for the given type name.
- `LFactory:register`: Register a constructor function for a given type name. Future `create()` calls with this type will invoke it.
- `LFactory:remove`: Unregister a type and discard its constructor function.


#### LFunnel Type


##### Fields

- No documented fields.

##### Methods

- `LFunnel:discard`: Discard all pending entries without flushing or calling the callback.
- `LFunnel:flush`: Force an immediate flush of all pending entries, invoking the callback.
- `LFunnel:getFlushCount`: Return the total number of times this funnel has flushed since creation.
- `LFunnel:onFlush`: Set the callback invoked when the funnel flushes. Receives an array of {tag, value} entries.
- `LFunnel:pendingCount`: Return the number of entries waiting to be flushed.
- `LFunnel:push`: Push a tagged event into the funnel. May trigger an immediate flush if the max entry count is reached.
- `LFunnel:update`: Advance the funnel's time window. Flushes and invokes the callback if the window elapsed.


#### LList Type


##### Fields

- No documented fields.

##### Methods

- `LList:add`: Append a value to the end of the list.
- `LList:clear`: Remove all items from the list. This method is available to Lua scripts.
- `LList:contains`: Check whether the list contains a specific value.
- `LList:get`: Get the value at a 1-based index. Returns nil if out of range.
- `LList:indexOf`: Find the 1-based index of the first occurrence of a value. Returns nil if not found.
- `LList:insert`: Insert a value at a 1-based index, shifting subsequent items right.
- `LList:isEmpty`: Check whether the list is empty. This method is available to Lua scripts.
- `LList:len`: Return the number of items in the list.
- `LList:pop`: Remove and return the last value. Returns nil if empty.
- `LList:push`: Append a value to the end of the list (alias for add).
- `LList:remove`: Remove and return the value at a 1-based index. Returns nil if out of range.
- `LList:reverse`: Reverse the order of all items in the list in-place.
- `LList:set`: Replace the value at a 1-based index. Errors if index is 0 or out of range.
- `LList:shift`: Remove and return the first value. Returns nil if empty.
- `LList:toArray`: Return all items as an array table. This method is available to Lua scripts.
- `LList:unshift`: Insert a value at the beginning of the list.


#### LMap Type


##### Fields

- No documented fields.

##### Methods

- `LMap:clear`: Remove all entries from the map. This method is available to Lua scripts.
- `LMap:entries`: Return an array of {key, value} tables for all entries.
- `LMap:get`: Retrieve the value for a key. Returns nil if the key does not exist.
- `LMap:has`: Check whether a key exists in the map.
- `LMap:isEmpty`: Check whether the map has no entries.
- `LMap:keys`: Return an array of all keys in the map.
- `LMap:len`: Return the number of key-value pairs.
- `LMap:merge`: Copy all entries from another LMap into this map. Existing keys are overwritten.
- `LMap:remove`: Remove a key from the map. Returns true if it was present.
- `LMap:set`: Set a key-value pair in the map. Replaces any existing value for the same key.
- `LMap:values`: Return an array of all values in the map.


#### LMediator Type


##### Fields

- No documented fields.

##### Methods

- `LMediator:broadcast`: Send a message to all handlers on all channels. Every registered handler receives the payload.
- `LMediator:channels`: Return an array of all channel names that have at least one handler.
- `LMediator:clear`: Remove all channels and handlers, resetting the mediator.
- `LMediator:handlerCount`: Return the number of handlers registered on a specific channel.
- `LMediator:off`: Unregister a handler from a channel by its ID.
- `LMediator:on`: Register a handler callback on a named channel. Returns an ID for unregistration.
- `LMediator:removeChannel`: Remove an entire channel and all its handlers.
- `LMediator:send`: Send a message to all handlers on a specific channel with optional payload arguments.


#### LObjectPool Type


##### Fields

- No documented fields.

##### Methods

- `LObjectPool:acquire`: Take an idle object from the pool and mark it active. Returns nil if the pool is empty.
- `LObjectPool:add`: Add an object to the pool's idle set, making it available for future acquisition.
- `LObjectPool:clearAll`: Destroy all objects (active and idle) and reset the pool to empty.
- `LObjectPool:getActiveCount`: Return the number of objects currently checked out from the pool.
- `LObjectPool:getAvailableCount`: Return the number of idle objects ready for acquisition.
- `LObjectPool:getTotalCount`: Return the total number of objects managed by this pool (active + idle).
- `LObjectPool:release`: Return an active object back to the pool's idle set so it can be reused.


#### LObserver Type


##### Fields

- No documented fields.

##### Methods

- `LObserver:get`: Retrieve the current value for a key. Returns nil if not set.
- `LObserver:getCount`: Return the total number of active subscriptions across all keys.
- `LObserver:set`: Set a value by key and notify all subscribers watching that key.
- `LObserver:subscribe`: Subscribe to changes on a specific key. The callback receives (key, newValue) on each change.
- `LObserver:unsubscribe`: Remove a subscription by its ID. The callback will no longer fire.


#### LPatternGraph Type


##### Fields

- No documented fields.

##### Methods

- `LPatternGraph:addEdge`: Add a directed (or undirected) edge between two nodes with optional weight and label.
- `LPatternGraph:addNode`: Add a node to the graph with an optional label and payload value.
- `LPatternGraph:bfs`: Perform a breadth-first search from a node. Returns visited node IDs in BFS order.
- `LPatternGraph:clearAll`: Remove all nodes, edges, and payloads from the graph.
- `LPatternGraph:dfs`: Perform a depth-first search from a node. Returns visited node IDs in DFS order.
- `LPatternGraph:edgeCount`: Return the total number of edges in the graph.
- `LPatternGraph:getNodeValue`: Retrieve the payload value stored on a node. Returns nil if no payload.
- `LPatternGraph:hasNode`: Check whether a node with the given ID exists in the graph.
- `LPatternGraph:isConnected`: Check whether there is any path from one node to another.
- `LPatternGraph:neighbors`: Return an array of node IDs directly connected to the given node.
- `LPatternGraph:nodeCount`: Return the total number of nodes in the graph.
- `LPatternGraph:removeEdge`: Remove an edge by its ID. Returns true if it existed.
- `LPatternGraph:removeNode`: Remove a node and all its connected edges. Returns true if the node existed.


#### LPriorityQueue Type


##### Fields

- No documented fields.

##### Methods

- `LPriorityQueue:clearAll`: Remove all items from the queue. This method is available to Lua scripts.
- `LPriorityQueue:isEmpty`: Check whether the queue contains no items.
- `LPriorityQueue:len`: Return the number of items currently in the queue.
- `LPriorityQueue:peek`: Return the highest-priority item without removing it. Returns nil if empty.
- `LPriorityQueue:pop`: Remove and return the highest-priority item. Returns nil if the queue is empty.
- `LPriorityQueue:push`: Add an item with a numeric priority. Higher priority items are dequeued first.


#### LQueue Type


##### Fields

- No documented fields.

##### Methods

- `LQueue:back`: Return the back value without removing it. Returns nil if empty.
- `LQueue:clear`: Remove all items from the queue. This method is available to Lua scripts.
- `LQueue:dequeue`: Remove and return the front value. Returns nil if empty.
- `LQueue:dequeueBack`: Remove and return the back value. Returns nil if empty.
- `LQueue:enqueue`: Add a value to the back of the queue. Returns false if at capacity.
- `LQueue:enqueueFront`: Add a value to the front of the queue (priority insertion). Returns false if at capacity.
- `LQueue:front`: Return the front value without removing it. Returns nil if empty.
- `LQueue:insertAt`: Insert a value at a 1-based index in the queue. Returns false if at capacity.
- `LQueue:isEmpty`: Check whether the queue is empty. This method is available to Lua scripts.
- `LQueue:isFull`: Check whether the queue has reached its capacity limit.
- `LQueue:len`: Return the current number of items in the queue.
- `LQueue:peekAt`: Return the value at a 1-based index without removing it. Returns nil if out of range.
- `LQueue:removeAt`: Remove and return the value at a 1-based index. Returns nil if out of range.
- `LQueue:toArray`: Return all queue items as an array table (front to back).


#### LRelationshipManager Type


##### Fields

- No documented fields.

##### Methods

- `LRelationshipManager:adjustValue`: Add a delta to the relationship value between two entities.
- `LRelationshipManager:defineType`: Define a relationship type with named levels (e.g. "friendship" with levels ["hostile", "neutral", "friendly"]).
- `LRelationshipManager:getLevel`: Get the named level for a relationship type between two entities.
- `LRelationshipManager:getValue`: Get the numeric relationship value between two entity IDs.
- `LRelationshipManager:pairCount`: Return the total number of tracked entity pairs.
- `LRelationshipManager:removePair`: Remove all relationship data between two entities.
- `LRelationshipManager:removeType`: Remove a relationship type definition.
- `LRelationshipManager:setLevel`: Set the named level for a relationship type between two entities.
- `LRelationshipManager:setValue`: Set the numeric relationship value between two entity IDs.
- `LRelationshipManager:typeNames`: Return all defined relationship type names.


#### LRing Type


##### Fields

- No documented fields.

##### Methods

- `LRing:average`: Return the arithmetic mean of all numeric values in the ring.
- `LRing:clear`: Remove all entries from the ring. This method is available to Lua scripts.
- `LRing:isFull`: Check whether the ring has reached its maximum capacity.
- `LRing:latest`: Return the most recently pushed entry as a table with id, tag, value, and text fields. Returns nil if empty.
- `LRing:len`: Return the number of entries currently in the ring.
- `LRing:push`: Push a number or string value into the ring. Overwrites the oldest entry if the ring is full.
- `LRing:sum`: Return the sum of all numeric values in the ring. Non-numeric entries contribute zero.
- `LRing:toArray`: Return all entries in the ring as an ordered array of tables (oldest to newest).


#### LServiceLocator Type


##### Fields

- No documented fields.

##### Methods

- `LServiceLocator:clearAll`: Remove all registered services and reset the locator.
- `LServiceLocator:getServices`: Return an array of all registered service names.
- `LServiceLocator:has`: Check whether a service with the given name is currently registered.
- `LServiceLocator:locate`: Retrieve a registered service by name. Returns nil if not found.
- `LServiceLocator:provide`: Register a service instance under a given name. Replaces any previously registered service with the same name.
- `LServiceLocator:remove`: Unregister and discard a service by name.


#### LSet Type


##### Fields

- No documented fields.

##### Methods

- `LSet:add`: Add a string to the set. Returns true if it was not already present.
- `LSet:clear`: Remove all items from the set. This method is available to Lua scripts.
- `LSet:has`: Check whether a string is in the set.
- `LSet:intersection`: Return a new set containing only items present in both this set and another.
- `LSet:isEmpty`: Check whether the set is empty. This method is available to Lua scripts.
- `LSet:len`: Return the number of items in the set.
- `LSet:remove`: Remove a string from the set. Returns true if it was present.
- `LSet:toArray`: Return all set items as an array table.
- `LSet:union`: Return a new set containing all items from both this set and another.


#### LSimpleState Type


##### Fields

- No documented fields.

##### Methods

- `LSimpleState:addState`: Register a named state with optional enter, exit, and update callbacks.
- `LSimpleState:clearAll`: Remove all states and their callbacks, resetting the state machine.
- `LSimpleState:getCurrent`: Return the name of the currently active state, or nil if no state is set.
- `LSimpleState:getStates`: Return an array of all registered state names.
- `LSimpleState:hasState`: Check whether a state with the given name is registered.
- `LSimpleState:transitionTo`: Transition to a new state. Calls the current state's `exit` and the target state's `enter` callbacks.
- `LSimpleState:update`: Call the current state's update callback with the frame delta time.


#### LStack Type


##### Fields

- No documented fields.

##### Methods

- `LStack:clear`: Remove all items from the stack. This method is available to Lua scripts.
- `LStack:insertAt`: Insert a value at a 1-based index in the stack, shifting items above it. Returns false if at capacity.
- `LStack:isEmpty`: Check whether the stack is empty. This method is available to Lua scripts.
- `LStack:isFull`: Check whether the stack has reached its capacity limit (if one was set).
- `LStack:len`: Return the current number of items in the stack.
- `LStack:moveWithin`: Move an item from one 1-based index to another within the stack.
- `LStack:peek`: Return the top value without removing it. Returns nil if empty.
- `LStack:peekAt`: Return the value at a 1-based index without removing it. Returns nil if out of range.
- `LStack:peekBottom`: Return the bottom value without removing it. Returns nil if empty.
- `LStack:pop`: Remove and return the top value. Returns nil if the stack is empty.
- `LStack:popBottom`: Remove and return the bottom value. Returns nil if empty.
- `LStack:popMany`: Pop up to `count` values from the top and return them as an array table.
- `LStack:push`: Push a value onto the top of the stack. Returns false if the stack is at capacity.
- `LStack:pushBottom`: Push a value onto the bottom of the stack. Returns false if at capacity.
- `LStack:removeAt`: Remove and return the value at a 1-based index. Returns nil if out of range.
- `LStack:toArray`: Return all stack items as an array table (bottom to top).


#### LStrategy Type


##### Fields

- No documented fields.

##### Methods

- `LStrategy:clear`: Remove all strategies and reset the selection.
- `LStrategy:execute`: Execute the currently active strategy, passing through all arguments and returning its results.
- `LStrategy:getCurrent`: Return the name of the currently active strategy, or nil if none set.
- `LStrategy:has`: Check whether a strategy with the given name is registered.
- `LStrategy:names`: Return an array of all registered strategy names.
- `LStrategy:register`: Register a named strategy implementation function.
- `LStrategy:remove`: Remove a named strategy. If it was the active strategy, no strategy will be selected.
- `LStrategy:set`: Switch to a named strategy. Future `execute()` calls will use this implementation.


#### LThrottle Type


##### Fields

- No documented fields.

##### Methods

- `LThrottle:getFireCount`: Return the total number of times this throttle has fired since creation.
- `LThrottle:getProgress`: Return how far through the current interval the throttle is (0.0 to 1.0).
- `LThrottle:onFire`: Set the callback function to invoke each time the throttle fires.
- `LThrottle:reset`: Reset the throttle timer back to zero without firing.
- `LThrottle:setEnabled`: Enable or disable the throttle. When disabled, update() will not accumulate time.
- `LThrottle:update`: Advance the throttle timer. If the interval has elapsed, fires the callback and returns true.


#### LWeightedRandom Type


##### Fields

- No documented fields.

##### Methods

- `LWeightedRandom:add`: Add an item with a relative weight. Higher weight = higher selection probability.
- `LWeightedRandom:clearAll`: Remove all entries from the pool. This method is available to Lua scripts.
- `LWeightedRandom:getRevision`: Return the revision counter. Increments on any add/remove/weight change.
- `LWeightedRandom:isEmpty`: Check whether the pool has no entries.
- `LWeightedRandom:len`: Return the number of entries in the pool.
- `LWeightedRandom:pick`: Pick one item using a random sample value in [0, 1). Returns its value or nil.
- `LWeightedRandom:pickN`: Pick multiple unique items. Requires an array of random samples.
- `LWeightedRandom:remove`: Remove an item by its ID. Returns true if it existed.
- `LWeightedRandom:setWeight`: Change the weight of an existing entry.
- `LWeightedRandom:totalWeight`: Return the sum of all entry weights.

## References

- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Foundations` into `Core Runtime`.
