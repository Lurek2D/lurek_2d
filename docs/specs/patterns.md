<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/patterns.md or source docstrings instead. -->

# patterns

## TL;DR

- Provides a comprehensive architectural toolkit for state, decision, and communication coordination.
- Implements behavior trees, finite state machines, event buses, blackboards, and command stacks.
- Controls execution cadences via throttles, debounces, and reusable object pools.
- Supports graph structures, bidirectional maps, prefix tries, factories, and service locators.
- Includes practical game/data structures such as Deck/Card when they are reusable logic patterns rather than entity identity systems.

## General Info

- Module group: `Foundations`
- Source path: `src/patterns`
- Binding: `src/lua_api/patterns_api.rs`
- Namespace: `lurek.patterns`
- Lua API surface: `30` functions, `28` types, `228` methods
- User-facing: `true`
- Plugin tier: `not_evaluated`

## Summary

- The `patterns` module is the engine's reusable architectural toolkit for users who want common coordination, control-flow, storage, and utility structures implemented once and then reused across gameplay, tools, UI, AI, and automation features.
- Its defining value is that it packages recurring design patterns as runtime-ready components rather than leaving them as abstract advice. A project can directly use an event bus, a behavior tree, a bounded queue, a blackboard, or a command history instead of re-deriving those ideas from scratch.
- Decision and control-flow patterns are a major part of the surface. Behavior trees, state machines, and related orchestration helpers provide stable ways to express staged logic, branching behavior, mode transitions, and rule-driven execution.
- That is useful even outside `ai`, because many systems need explicit control flow: scripted encounters, UI workflows, tool wizards, tutorial logic, job pipelines, and editor modes all benefit from the same transition-oriented vocabulary.
- Communication patterns form another large category. Event buses, mediators, observers, channels, and related coordination helpers provide different answers to how modules should publish state changes or trigger reactions without tightly coupling every producer to every consumer.
- The presence of several communication styles matters because no single coupling model fits every feature. Some systems want broadcast signals, some want centralized arbitration, and some want direct subscription with stable state propagation rules.
- Shared-state helpers such as blackboards and keyed stores are especially valuable for collaborative runtime features where several actors or subsystems need to read and write facts under shared names.
- Those shared stores are useful for AI behavior, UI workflows, tool execution state, scripted conversations, agent memory, and validation pipelines, which makes `patterns` one of the main bridges between otherwise unrelated feature areas.
- Command-history support extends the module into authoring and reversible workflows, while factories, registries, and related helpers give projects a standardized way to organize larger runtime graphs.
- The module also provides utility data structures that keep proving useful across domains: priority queues, ring buffers, tries, weighted selectors, bidirectional maps, graph containers, bounded collections, and pooling helpers.
- Object reuse and bounded collections matter because several runtime systems need allocation control, limited history, or reusable queues without wanting ad hoc versions hidden inside every feature.
- Weighted selectors, graph containers, and queue-like helpers show that `patterns` is not only about software architecture in the narrow sense. It also owns practical reusable mechanics that often sit just below game logic and tool logic but above low-level containers.
- Deck/Card lives here rather than in `ecs` because a deck is reusable game logic: it owns draw order, shuffle determinism, discard/reset behavior, and card payload handling. It does not define object identity, inheritance, components, or world membership.
- That boundary keeps `patterns` broad and domain-neutral while leaving object/class semantics to `ecs`.
- The module also helps keep terminology stable across the codebase. Several features can depend on the same ideas of event dispatch, reversible actions, orchestration, and shared state instead of each inventing slightly different local vocabulary.
- The breadth of the module is deliberate: these pieces are small enough to stay reusable, but substantial enough that reimplementing them repeatedly would fragment the rest of the engine.
- That makes `patterns` valuable not only as a library shelf, but also as a consistency layer. Several systems can solve similar structural problems without diverging in naming, behavior, or maintenance style.
- For wiki readers, the practical boundary is that `patterns` owns reusable mechanics, not end-user domain behavior. If a component could reasonably be reused by AI, UI, tooling, and automation alike, it probably belongs here rather than inside one specialized module.
- This broad but domain-neutral scope is what makes the module distinctive. `patterns` does not try to become the owner of AI, rendering, or networking itself; it supplies the architectural pieces those higher-level systems repeatedly depend on.
- That separation matters because several engine features need the same structures without importing each other's domain logic.
- It also gives long-lived projects one place to refine shared mechanics instead of letting near-duplicates drift.
- The module therefore acts like a shared vocabulary for structure. It gives different features a common way to talk about transitions, events, coordination, reversible actions, pooling, and shared facts, which improves consistency across the rest of the engine.
- Read `patterns` as the place where recurring structural ideas become concrete runtime components and shared coordination vocabulary.

This module primarily collaborates with `runtime`. Its responsibility should stay inside the Foundations group rather than absorb behavior owned by those neighbors.

## Ownership

- Canonical source: `src/patterns`
- Owning tier: `Foundations`
- Plugin tier: `not_evaluated`
- Lua binding owner: `src/lua_api/patterns_api.rs`
- Referenced engine modules: `runtime`

## Imports

- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Foundations` into `Core Runtime`.

## Source Files

### behavior_tree.rs

- This file owns the behavior-tree builder and runtime structs used to model ordered AI decisions as node graphs.
- `BehaviorTree` allocates sequence, selector, parallel, inverter, repeat, and leaf nodes with stable `NodeId`s.
- `BtNode` and `NodeKind` define tree structure, while `root` and child links keep traversal data in one owner.
- `BtRunState` stores running-node markers and repeat counters so tick execution can resume without hidden globals.
- Open it when decision-tree topology changes; blackboards, FSMs, and schedulers live in sibling pattern modules.

### bimap.rs

- This file owns the mirrored key-to-value and value-to-key tables used for symmetric lookup in both directions.
- `BiMap` keeps forward and reverse hashes synchronized so inserts and removals preserve one authoritative pairing.
- Containment and removal helpers also belong here because duplicate-key and duplicate-value conflict rules are local.
- Open it when reversible registry bindings change; tries, graphs, and event-routing structures live in siblings.

### blackboard.rs

- This file owns the shared blackboard store used by gameplay and AI code to exchange typed facts by string keys.
- `BlackboardValue` models bool, number, text, and nil entries so behavior code can share compact script-facing data.
- `Blackboard` tracks revisions per write, local key storage, and optional parent fallback for inherited context layers.
- Typed setters and getters stay here because coercion rules, defaults, and lookup order are part of board semantics.
- Clear, snapshot, key listing, and parent access also belong here since they expose the board as coordination memory.
- Open it when shared state semantics change; trees, FSMs, and transport code live in other owning modules.

### collections.rs

- This file owns shared capacity metadata structs that give bounded stack and queue wrappers one common limit policy.
- `StackMeta` and `QueueMeta` centralize the rule that zero means unbounded while positive values enforce hard caps.
- Open it when collection limit semantics change; concrete histories, rings, and priority stores live in siblings.

### command_stack.rs

- This file owns the linear undo and redo history used to track named commands with a movable replay cursor.
- `CommandStack` stores entries, redo truncation, cursor position, batch depth, and max-size eviction in one owner.
- `CommandEntry` plus batch helpers stay here because command ids and grouped reversal boundaries are local history data.
- Peek and step helpers also belong here since they expose navigation across applied and redoable work without callbacks.
- Open it when history semantics change; event routing, state machines, and pools live in sibling pattern modules.

### deck.rs

- Owns the patterns deck implementation for the patterns subsystem and keeps related runtime rules local here.
- Keeps pattern data, exported submodules, and navigation helpers so helpers stay close to invariants this file updates.
- Defines how patterns deck data is validated, transformed, or stored before neighboring systems consume it.
- Separates patterns deck behavior from Lua bindings, tests, and sibling owners so integration stays readable.

### event_bus.rs

- This file owns the named event-subscription store used to route listeners without direct caller-to-callee wiring.
- `EventBus` tracks ids, priorities, wildcard matches, and one-shot listeners so dispatch order stays inspectable.
- `Subscription` lives here because event name, priority, and once semantics define the bus-owned routing contract.
- Listener queries and once-drain helpers also belong here since they expose dispatch shape without invoking callbacks.
- Open it when publish-subscribe semantics change; observers and mediators live in sibling coordination modules.

### factory.rs

- This file owns the runtime factory registry that maps canonical type names and aliases to constructable targets.
- `Factory` stores registered types plus alias mappings so multiple labels can resolve onto one canonical build name.
- Registration, removal, and resolution stay here because alias invalidation rules are part of factory ownership.
- Open it when type-lookup semantics change; service discovery and strategy selection live in sibling modules.

### funnel.rs

- This file owns the buffered funnel primitive used to batch tagged numeric events into timed or counted flushes.
- `FunnelEntry` stores ids, tags, and values, while `Funnel` tracks pending entries, timers, and flush statistics.
- Push, update, flush, and discard stay here because batching windows and max-entry thresholds define funnel semantics.
- Open it when buffered release behavior changes; throttles, rings, and queues live in sibling pattern modules.

### graph.rs

- This file owns the general graph container used to model labeled nodes and weighted edges with stable integer ids.
- `GraphNode` and `GraphEdge` define stored topology, while `Graph` keeps nodes, edges, adjacency, and id allocators.
- Directed and undirected edge insertion stay here because reverse-edge behavior is part of graph-owned structure rules.
- Traversal helpers such as BFS, DFS, neighbor lookup, and connectivity checks also belong with the adjacency cache.
- Node and edge removal remain local because index repair and adjacency rebuilds are internal consistency concerns.
- Open it when topology semantics change; tries, blackboards, and state coordinators live in sibling modules.

### mediator.rs

- This file owns the channel-based mediator registry used to coordinate handlers through a central broker surface.
- `Mediator` stores per-channel handler ids and the next allocator so registration and removal share one authority.
- Channel listing and count helpers stay here because handler membership is mediator-owned coordination state.
- Open it when brokered routing semantics change; event buses and observers live in sibling pattern modules.

### mod.rs

- This module re-exports patterns surface for `behavior_tree.rs`, `bimap.rs`, `blackboard.rs`, and helpers.
- It keeps navigation explicit by showing which sibling files own state, validation, transport, or render behavior.
- Public exports here route callers toward `behavior_tree.rs`, `bimap.rs`, and `blackboard.rs` first, while deeper owners.
- Open this file when the public patterns symbol map moves; edit siblings when runtime rules themselves change.
- This index exists to organize entrypoints, not to absorb the state, caches, or algorithms its children own.
- Use neighboring owners for behavioral fixes, and keep this file limited to exports, docs, and navigation.
- Reexports here help agents find right module quickly when changes touch `behavior_tree.rs`, `bimap.rs`, subsystem.
- Keep concrete logic in `behavior_tree.rs`, `bimap.rs`, and `blackboard.rs` so symbol lookup stays shallow.

### object_pool.rs

- This file owns the reusable object-id pool used to recycle active and idle slots under an optional capacity limit.
- `ObjectPool` tracks free ids, checked-out ids, next allocation, and prewarm behavior inside one lifecycle owner.
- Acquire, release, and release-all stay here because active-versus-idle membership rules define pool semantics.
- Open it when reuse policy changes; rings, funnels, and history stacks live in sibling pattern modules.

### observer.rs

- This file owns the keyed observer store used to watch named changes without binding readers directly to writers.
- `ObserverEntry` records subscription ids, keys, and once flags, while `Observer` groups watchers by key string.
- Wildcard matching and once-only cleanup stay here because dispatch membership is observer-owned state bookkeeping.
- Subscription counts and clear helpers also belong here since long-lived scenes need explicit maintenance controls.
- Open it when reactive watch semantics change; event buses and mediators live in sibling coordination modules.

### priority_queue.rs

- This file owns the stable priority queue used to order items by urgency while preserving FIFO ties by sequence.
- `PriorityItem` stores ids, priority, label, and sequence, while `PriorityQueue` owns sorting and head compaction.
- Push, pop, peek, and removal stay here because tie-breaking and consumed-front cleanup are local queue semantics.
- The live-slice and compact helpers also belong here since they hide storage details behind stable public ordering.
- Open it when scheduling order changes; rings, command history, and weighted picks live in sibling modules.

### ring.rs

- This file owns the fixed-capacity ring buffer used to keep the newest tagged history while evicting stale entries.
- `RingEntry` stores numeric or string payloads, while `Ring` tracks capacity, push ids, totals, and entry order.
- Automatic front eviction stays here because overwrite policy is part of the buffer contract, not caller behavior.
- Aggregate helpers such as sum and average also belong here since numeric rollups derive from ring-owned contents.
- Open it when rolling-history semantics change; funnels, throttles, and queues live in sibling pattern modules.

### service_locator.rs

- This file owns the string-keyed service registry used to advertise shared runtime capabilities by agreed names.
- `ServiceLocator` stores the registered names set so feature presence can be queried, listed, or cleared centrally.
- Open it when service-discovery semantics change; factories, strategies, and event routers live in siblings.

### simple_state.rs

- This file owns the lightweight named-state registry used when one current mode is enough and full FSM rules are not.
- `SimpleState` stores the declared states set and current selection so callers can inspect and switch active modes.
- Add, remove, and current-state helpers stay here because state membership and validation are local semantics.
- Open it when flat mode tracking changes; guarded transitions and history live in `state_machine.rs` instead.

### state_machine.rs

- This file owns the full finite-state machine used to manage named states, allowed transitions, and recent history.
- `TransitionRule` stores source, destination, label, and guard presence, while `StateMachine` owns live state data.
- Declared states, current and previous mode, transition lists, and bounded visit history all remain in one owner.
- Transition checks and history compaction stay here because they define what moves are legal and what memory persists.
- Open it when mode-transition semantics change; simpler current-state tracking lives in `simple_state.rs`.

### strategy.rs

- This file owns the named strategy registry used to swap among algorithms while keeping selection data explicit.
- `Strategy` stores registered names, assigned ids, the current choice, and removal logic inside one owner.
- Registration and current-selection helpers stay here because available policies may change during runtime.
- Open it when algorithm-selection semantics change; factories and service lookup live in sibling modules.

### throttle.rs

- This file owns the throttle and debounce timers used to shape action cadence instead of firing on every input.
- `Throttle` tracks interval progress and fire counts, while `Debounce` tracks pending triggers and quiet-time waits.
- Update, reset, trigger, and cancel stay here because cadence semantics are local to these timing primitives.
- Progress queries also belong here since they expose internal timer state for scripts and frame-based controllers.
- Open it when rate-limiting behavior changes; funnels, rings, and event buses live in sibling pattern modules.

### trie.rs

- This file owns the prefix trie used to store string keys for exact lookup, prefix tests, and completion queries.
- `TrieNode` keeps child edges and end markers, while `Trie` owns root storage and public mutation or search helpers.
- Insertion, exact search, prefix search, and removal stay here because path creation and pruning are trie semantics.
- Depth-first key collection also belongs here since completion output derives directly from trie-owned descendants.
- Open it when string-index semantics change; bidirectional maps and graphs live in sibling pattern modules.

### weighted_random.rs

- This file owns the mutable weighted selector used to pick entries by probability while keeping the table editable.
- `WeightedEntry` stores ids, weights, and labels, while `WeightedRandom` owns entries, revision, and id allocation.
- Add, remove, set-weight, and total-weight stay here because probability-table maintenance is local selector state.
- Single-pick and multi-pick helpers also belong here since no-replacement sampling uses local scratch rules.
- Open it when probability selection changes; queues, tries, and object pools live in sibling pattern modules.



## Lua API Ref

### Functions

- `lurek.patterns.countBy(items, selector) -> nil`: Counts array items by a selector field path or callback.
- `lurek.patterns.findSequences(items, selector, opts?) -> nil`: Finds numeric selector runs with a constant step.
- `lurek.patterns.groupBy(items, selector) -> table`: Groups array items by a selector field path or callback.
- `lurek.patterns.newBehaviorTree() -> LBehaviorTree`: Create a new behavior tree for AI decision-making with sequences, selectors, parallels, and leaf actions.
- `lurek.patterns.newBlackboard(name?) -> LBlackboard`: Create a new shared key-value blackboard supporting reactive watchers for game logic variables.
- `lurek.patterns.newCommandStack(maxSize?) -> LCommandStack`: Create a new undo/redo command stack for recording and reversing player or editor actions.
- `lurek.patterns.newDebounce(wait) -> LDebounce`: Create a new debounce that delays firing until input stops for a specified wait period.
- `lurek.patterns.newDeck(cards?) -> LDeck`: Create a reusable deck/card collection with shuffle, draw, discard, and reset operations.
- `lurek.patterns.newEventBus(name?) -> LEventBus`: Create a new publish/subscribe event bus for decoupled communication between game systems.
- `lurek.patterns.newFactory() -> LFactory`: Create a new factory for producing typed game objects from registered constructor functions.
- `lurek.patterns.newFunnel(window, maxEntries?, name?) -> LFunnel`: Create a new batching funnel that collects events over a time window and flushes them together.
- `lurek.patterns.newGraph(undirected?) -> LPatternGraph`: Create a new graph data structure with directed or undirected edges, BFS, DFS, and connectivity queries.
- `lurek.patterns.newList() -> LList`: Create a new dynamic array list with indexed access, insertion, removal, and search.
- `lurek.patterns.newMap() -> LMap`: Create a new string-keyed dictionary (map) with keys/values/entries access and merge support.
- `lurek.patterns.newMediator() -> LMediator`: Create a new mediator for channel-based message passing between decoupled game systems.
- `lurek.patterns.newObjectPool() -> LObjectPool`: Create a new object pool for reusing pre-allocated game objects to reduce allocation overhead.
- `lurek.patterns.newObserver(name?) -> LObserver`: Create a new reactive observer that stores values and notifies subscribers when they change.
- `lurek.patterns.newPriorityQueue(name?) -> LPriorityQueue`: Create a new priority queue that orders elements by numeric priority (highest first).
- `lurek.patterns.newQueue(capacity?) -> LQueue`: Create a new FIFO queue with optional capacity limit.
- `lurek.patterns.newRelationshipManager() -> LRelationshipManager`: Create a new relationship manager for tracking numeric values and named levels between entity pairs.
- `lurek.patterns.newRing(capacity, name?) -> LRing`: Create a new fixed-size ring buffer for numeric or string values. Oldest entries are overwritten when full.
- `lurek.patterns.newServiceLocator() -> LServiceLocator`: Create a new service locator for registering and retrieving shared services by name at runtime.
- `lurek.patterns.newSet() -> LSet`: Create a new string set with add/remove/has operations and set algebra (union, intersection).
- `lurek.patterns.newSimpleState() -> LSimpleState`: Create a new finite state machine with enter/exit/update callbacks per state.
- `lurek.patterns.newStack(capacity?) -> LStack`: Create a new LIFO stack with optional capacity limit.
- `lurek.patterns.newStrategy() -> LStrategy`: Create a new strategy pattern container for hot-swappable algorithm implementations.
- `lurek.patterns.newThrottle(interval) -> LThrottle`: Create a new throttle that limits how often an action can fire, enforcing a minimum interval.
- `lurek.patterns.newWeightedRandom() -> LWeightedRandom`: Create a new weighted random selection pool. Add items with weights and pick random selections.
- `lurek.patterns.sortedIndices(items, selector, opts?) -> nil`: Returns one-based item indices sorted by selector value.
- `lurek.patterns.topN(items, selector, n, opts?) -> nil`: Returns the top `n` items by selector value, or indices when `opts.indices` is true.

### Callbacks

- `LBehaviorTree:setLeaf` param `callback` (`function`): A function returning a status string.
- `LBlackboard:watch` param `callback` (`function`): Called with (key, newValue) when a change occurs.
- `LCommandStack:execute` param `execFn` (`function`): The function that performs the action.
- `LCommandStack:execute` param `undoFn` (`function?`): An optional function that reverses the action. If omitted, command cannot be undone.
- `LDebounce:onFire` param `f` (`function`): The callback to execute.
- `LEventBus:on` param `callback` (`function`): The function to invoke when the event fires.
- `LFactory:register` param `ctor` (`function`): A constructor function that returns a new instance.
- `LFunnel:onFlush` param `f` (`function`): Callback receiving a table array of batched entries.
- `LMediator:on` param `callback` (`function`): The handler to invoke when a message is sent to this channel.
- `LObserver:subscribe` param `callback` (`function`): Called with (key, newValue) when the property changes.
- `LStrategy:register` param `callback` (`function`): The implementation function to call when this strategy is active.
- `LThrottle:onFire` param `f` (`function`): The callback to execute on fire.

### Enums

- No documented module-level enums/constants.

### Types

#### LBehaviorTree Type

- Lua-facing behavior tree for AI decision-making with sequences, selectors, parallels, inverters, repeaters, and leaf actions.

##### Fields

- No documented fields.

##### Methods

- `LBehaviorTree:addChild(parentId, childId) -> boolean`: Attach a child node to a parent composite or decorator node.
- `LBehaviorTree:addInverter(label?) -> number`: Create a decorator node that inverts its child's result (success â†” failure).
- `LBehaviorTree:addLeaf(name, label?) -> number`: Create a leaf (action) node that will invoke a named callback function on tick.
- `LBehaviorTree:addParallel(minSuccess, label?) -> number`: Create a parallel composite node that runs all children simultaneously.
- `LBehaviorTree:addRepeat(count, label?) -> number`: Create a decorator node that repeats its child a fixed number of times.
- `LBehaviorTree:addSelector(label?) -> number`: Create a selector (fallback) composite node. Succeeds if any child succeeds.
- `LBehaviorTree:addSequence(label?) -> number`: Create a sequence composite node. All children must succeed for this node to succeed.
- `LBehaviorTree:clearAll() -> nil`: Remove all nodes and leaf functions, resetting the tree to empty.
- `LBehaviorTree:nodeCount() -> number`: Return the total number of nodes in the tree.
- `LBehaviorTree:resetState() -> nil`: Reset the tree's running state. Use between encounters or when restarting AI logic.
- `LBehaviorTree:setLeaf(name, callback) -> nil`: Register or replace the callback function for a named leaf. The function must return "success", "failure", or "running".
- `LBehaviorTree:setRoot(id) -> boolean`: Designate a node as the tree's root. Tick evaluation starts here.
- `LBehaviorTree:tick() -> string`: Execute one tick of the behavior tree from the root. Returns the root node's status.

#### LBlackboard Type

- Lua-facing shared key-value blackboard supporting bool/number/string values with watchers for reactive game logic.

##### Fields

- No documented fields.

##### Methods

- `LBlackboard:clear(key) -> nil`: Remove a single key from the blackboard.
- `LBlackboard:clearAll() -> nil`: Remove all keys and values from the blackboard.
- `LBlackboard:get(key) -> boolean|number|string|nil`: Retrieve the value stored under a key. Returns nil if the key does not exist.
- `LBlackboard:getRevision() -> number`: Return the current revision counter. Increments on every value change.
- `LBlackboard:has(key) -> boolean`: Check whether a key exists on the blackboard.
- `LBlackboard:keys() -> string[]`: Return an array of all keys currently stored on the blackboard.
- `LBlackboard:set(key, value) -> nil`: Set a key to a value (boolean, number, string, or nil to clear). Notifies registered watchers if value changed.
- `LBlackboard:snapshot() -> table`: Return a table containing all current key-value pairs as a snapshot. Useful for serialization or debug display.
- `LBlackboard:unwatch(id) -> nil`: Remove a previously registered watcher by its ID.
- `LBlackboard:watch(key, callback) -> number`: Register a watcher callback that fires whenever the specified key changes. Use `"*"` to watch all keys.

#### LCommandStack Type

- Lua-facing undo/redo command stack. Records executed actions with optional undo functions for full history navigation.

##### Fields

- No documented fields.

##### Methods

- `LCommandStack:canRedo() -> boolean`: Check whether a redo operation is possible (there are commands ahead of the pointer).
- `LCommandStack:canUndo() -> boolean`: Check whether an undo operation is possible (there is a command with an undo function behind the pointer).
- `LCommandStack:clearAll() -> nil`: Discard all command history and free associated callbacks.
- `LCommandStack:execute(name, execFn, undoFn?) -> nil`: Execute a named command immediately, recording it in history. Discards any redo history ahead of the current position.
- `LCommandStack:getCurrentName() -> string`: Return the name of the most recently executed (or undone-to) command, or nil if history is empty.
- `LCommandStack:getHistorySize() -> number`: Return the total number of commands in the history (both undone and available for redo).
- `LCommandStack:redo() -> boolean`: Redo a previously undone command by re-calling its execute function. Moves the pointer forward.
- `LCommandStack:undo() -> boolean`: Undo the most recent command by calling its undo function. Moves the pointer back in history.

#### LDebounce Type

- Lua-facing debounce that delays firing until input stops for a specified wait period.

##### Fields

- No documented fields.

##### Methods

- `LDebounce:cancel() -> nil`: Cancel any pending debounce without firing. The callback will not be called until triggered again.
- `LDebounce:getFireCount() -> number`: Return the total number of times this debounce has fired since creation.
- `LDebounce:isPending() -> boolean`: Check whether the debounce is currently waiting to fire (has been triggered but wait period not yet elapsed).
- `LDebounce:onFire(f) -> nil`: Set the callback function to invoke when the debounce fires after the wait period.
- `LDebounce:trigger() -> nil`: Signal input activity. Resets the wait timer so the debounce will fire after the full wait period of inactivity.
- `LDebounce:update(dt) -> boolean`: Advance the debounce timer. If the wait period elapsed since last trigger, fires the callback and returns true.

#### LDeck Type

- Lua-facing reusable deck that stores arbitrary card payloads and delegates pile ordering to Rust.

##### Fields

- No documented fields.

##### Methods

- `LDeck:add(card) -> integer`: Add a card payload to the bottom of the deck's draw pile.
- `LDeck:count() -> integer`: Return the number of cards left in the draw pile.
- `LDeck:discard(card) -> boolean`: Move a card into the discard pile by card table or stable id.
- `LDeck:discardCount() -> integer`: Return the number of cards in the discard pile.
- `LDeck:draw(count?) -> LuaValue`: Draw one or more cards from the top of the draw pile.
- `LDeck:isEmpty() -> boolean`: Return true when no cards remain in the draw pile.
- `LDeck:peek(count?) -> LuaValue`: Inspect one or more cards from the top without removing them.
- `LDeck:reset() -> nil`: Restore the draw pile to original insertion order and clear discard.
- `LDeck:shuffle(seed?) -> nil`: Shuffle the current draw pile with a deterministic optional seed.
- `LDeck:toArray() -> table`: Return the current draw pile as an array without modifying it.

#### LEventBus Type

- Lua-facing publish/subscribe event bus allowing decoupled communication between game systems.

##### Fields

- No documented fields.

##### Methods

- `LEventBus:clear(event) -> nil`: Remove all listeners subscribed to a specific event name.
- `LEventBus:clearAll() -> nil`: Remove all listeners from every event on this bus. Resets the bus to empty.
- `LEventBus:emit(event, ...) -> nil`: Emit an event, invoking all subscribed listeners in priority order with optional payload arguments.
- `LEventBus:getEvents() -> string[]`: Return an array of all event names that have at least one listener.
- `LEventBus:getListenerCount(event) -> number`: Return the number of active listeners for a given event name.
- `LEventBus:off(id) -> nil`: Unsubscribe a listener by its subscription ID. Removes the callback from the event bus.
- `LEventBus:on(event, callback, priority?) -> number`: Subscribe a callback to a named event. Higher priority listeners fire first.

#### LFactory Type

- Lua-facing factory pattern for creating typed game objects from registered constructor functions.

##### Fields

- No documented fields.

##### Methods

- `LFactory:alias(alias, canonical) -> nil`: Create an alias that maps to an existing type name. `create(alias)` will use the canonical constructor.
- `LFactory:clearAll() -> nil`: Remove all registered types and constructors, resetting the factory.
- `LFactory:create(typeName, ...) -> table`: Create a new object by type name, passing additional arguments to the constructor.
- `LFactory:getTypes() -> string[]`: Return an array of all registered type names.
- `LFactory:has(typeName) -> boolean`: Check whether a constructor is registered for the given type name.
- `LFactory:register(typeName, ctor) -> nil`: Register a constructor function for a given type name. Future `create()` calls with this type will invoke it.
- `LFactory:remove(typeName) -> nil`: Unregister a type and discard its constructor function.

#### LFunnel Type

- Lua-facing batching funnel that collects events over a time window and flushes them together.

##### Fields

- No documented fields.

##### Methods

- `LFunnel:discard() -> nil`: Discard all pending entries without flushing or calling the callback.
- `LFunnel:flush() -> nil`: Force an immediate flush of all pending entries, invoking the callback.
- `LFunnel:getFlushCount() -> number`: Return the total number of times this funnel has flushed since creation.
- `LFunnel:onFlush(f) -> nil`: Set the callback invoked when the funnel flushes. Receives an array of {tag, value} entries.
- `LFunnel:pendingCount() -> number`: Return the number of entries waiting to be flushed.
- `LFunnel:push(tag, value?) -> nil`: Push a tagged event into the funnel. May trigger an immediate flush if the max entry count is reached.
- `LFunnel:update(dt) -> boolean`: Advance the funnel's time window. Flushes and invokes the callback if the window elapsed.

#### LList Type

- Lua-facing dynamic array list with indexed access, insertion, removal, and search.

##### Fields

- No documented fields.

##### Methods

- `LList:add(value) -> nil`: Append a value to the end of the list.
- `LList:clear() -> nil`: Remove all items from the list. This method is available to Lua scripts.
- `LList:contains(value) -> boolean`: Check whether the list contains a specific value.
- `LList:get(index) -> string`: Get the value at a 1-based index. Returns nil if out of range.
- `LList:indexOf(value) -> integer`: Find the 1-based index of the first occurrence of a value. Returns nil if not found.
- `LList:insert(index, value) -> nil`: Insert a value at a 1-based index, shifting subsequent items right.
- `LList:isEmpty() -> boolean`: Check whether the list is empty. This method is available to Lua scripts.
- `LList:len() -> number`: Return the number of items in the list.
- `LList:pop() -> string`: Remove and return the last value. Returns nil if empty.
- `LList:push(value) -> nil`: Append a value to the end of the list (alias for add).
- `LList:remove(index) -> string`: Remove and return the value at a 1-based index. Returns nil if out of range.
- `LList:reverse() -> nil`: Reverse the order of all items in the list in-place.
- `LList:set(index, value) -> nil`: Replace the value at a 1-based index. Errors if index is 0 or out of range.
- `LList:shift() -> string`: Remove and return the first value. Returns nil if empty.
- `LList:toArray() -> number[]`: Return all items as an array table. This method is available to Lua scripts.
- `LList:unshift(value) -> nil`: Insert a value at the beginning of the list.

#### LMap Type

- Lua-facing string-keyed dictionary (map) with keys(), values(), entries(), and merge operations.

##### Fields

- No documented fields.

##### Methods

- `LMap:clear() -> nil`: Remove all entries from the map. This method is available to Lua scripts.
- `LMap:entries() -> table`: Return an array of {key, value} tables for all entries.
- `LMap:get(key) -> string`: Retrieve the value for a key. Returns nil if the key does not exist.
- `LMap:has(key) -> boolean`: Check whether a key exists in the map.
- `LMap:isEmpty() -> boolean`: Check whether the map has no entries.
- `LMap:keys() -> string[]`: Return an array of all keys in the map.
- `LMap:len() -> number`: Return the number of key-value pairs.
- `LMap:merge(other) -> nil`: Copy all entries from another LMap into this map. Existing keys are overwritten.
- `LMap:remove(key) -> boolean`: Remove a key from the map. Returns true if it was present.
- `LMap:set(key, value) -> nil`: Set a key-value pair in the map. Replaces any existing value for the same key.
- `LMap:values() -> number[]`: Return an array of all values in the map.

#### LMapEntriesResult Type

- Generated result shape from @field tags.

##### Fields

- `id` (`integer`): Entry id.
- `tag` (`string`): Tag string.
- `text` (`string`): Text content.
- `value` (`number`): Numeric value.

##### Methods

- No documented methods.

#### LMediator Type

- Lua-facing mediator for channel-based message passing between decoupled game systems.

##### Fields

- No documented fields.

##### Methods

- `LMediator:broadcast(...) -> nil`: Send a message to all handlers on all channels. Every registered handler receives the payload.
- `LMediator:channels() -> string[]`: Return an array of all channel names that have at least one handler.
- `LMediator:clear() -> nil`: Remove all channels and handlers, resetting the mediator.
- `LMediator:handlerCount(channel) -> number`: Return the number of handlers registered on a specific channel.
- `LMediator:off(channel, id) -> nil`: Unregister a handler from a channel by its ID.
- `LMediator:on(channel, callback) -> number`: Register a handler callback on a named channel. Returns an ID for unregistration.
- `LMediator:removeChannel(channel) -> nil`: Remove an entire channel and all its handlers.
- `LMediator:send(channel, ...) -> nil`: Send a message to all handlers on a specific channel with optional payload arguments.

#### LObjectPool Type

- Lua-facing object pool for reusing pre-allocated game objects (bullets, particles, enemies) to avoid per-frame allocations.

##### Fields

- No documented fields.

##### Methods

- `LObjectPool:acquire() -> table`: Take an idle object from the pool and mark it active. Returns nil if the pool is empty.
- `LObjectPool:add(value) -> nil`: Add an object to the pool's idle set, making it available for future acquisition.
- `LObjectPool:clearAll() -> nil`: Destroy all objects (active and idle) and reset the pool to empty.
- `LObjectPool:getActiveCount() -> number`: Return the number of objects currently checked out from the pool.
- `LObjectPool:getAvailableCount() -> number`: Return the number of idle objects ready for acquisition.
- `LObjectPool:getTotalCount() -> number`: Return the total number of objects managed by this pool (active + idle).
- `LObjectPool:release(value) -> nil`: Return an active object back to the pool's idle set so it can be reused.

#### LObserver Type

- Lua-facing reactive observer that stores values and notifies subscribers when values change.

##### Fields

- No documented fields.

##### Methods

- `LObserver:get(key) -> number`: Retrieve the current value for a key. Returns nil if not set.
- `LObserver:getCount() -> number`: Return the total number of active subscriptions across all keys.
- `LObserver:set(key, value) -> nil`: Set a value by key and notify all subscribers watching that key.
- `LObserver:subscribe(key, callback, once?) -> number`: Subscribe to changes on a specific key. The callback receives (key, newValue) on each change.
- `LObserver:unsubscribe(id) -> nil`: Remove a subscription by its ID. The callback will no longer fire.

#### LPatternGraph Type

- Lua-facing graph data structure with directed/undirected edges, BFS, DFS, and connectivity queries.

##### Fields

- No documented fields.

##### Methods

- `LPatternGraph:addEdge(from, to, weight?, label?) -> number`: Add a directed (or undirected) edge between two nodes with optional weight and label.
- `LPatternGraph:addNode(label?, value?) -> number`: Add a node to the graph with an optional label and payload value.
- `LPatternGraph:bfs(start) -> integer[]`: Perform a breadth-first search from a node. Returns visited node IDs in BFS order.
- `LPatternGraph:clearAll() -> nil`: Remove all nodes, edges, and payloads from the graph.
- `LPatternGraph:dfs(start) -> integer[]`: Perform a depth-first search from a node. Returns visited node IDs in DFS order.
- `LPatternGraph:edgeCount() -> number`: Return the total number of edges in the graph.
- `LPatternGraph:getNodeValue(id) -> table`: Retrieve the payload value stored on a node. Returns nil if no payload.
- `LPatternGraph:hasNode(id) -> boolean`: Check whether a node with the given ID exists in the graph.
- `LPatternGraph:isConnected(from, to) -> boolean`: Check whether there is any path from one node to another.
- `LPatternGraph:neighbors(id) -> integer[]`: Return an array of node IDs directly connected to the given node.
- `LPatternGraph:nodeCount() -> number`: Return the total number of nodes in the graph.
- `LPatternGraph:removeEdge(id) -> boolean`: Remove an edge by its ID. Returns true if it existed.
- `LPatternGraph:removeNode(id) -> boolean`: Remove a node and all its connected edges. Returns true if the node existed.

#### LPriorityQueue Type

- Lua-facing priority queue that orders elements by numeric priority (highest first).

##### Fields

- No documented fields.

##### Methods

- `LPriorityQueue:clearAll() -> nil`: Remove all items from the queue. This method is available to Lua scripts.
- `LPriorityQueue:isEmpty() -> boolean`: Check whether the queue contains no items.
- `LPriorityQueue:len() -> number`: Return the number of items currently in the queue.
- `LPriorityQueue:peek() -> table`: Return the highest-priority item without removing it. Returns nil if empty.
- `LPriorityQueue:pop() -> table`: Remove and return the highest-priority item. Returns nil if the queue is empty.
- `LPriorityQueue:push(priority, value, label?) -> number`: Add an item with a numeric priority. Higher priority items are dequeued first.

#### LQueue Type

- Lua-facing FIFO queue with optional capacity limit. Supports enqueue/dequeue from both ends.

##### Fields

- No documented fields.

##### Methods

- `LQueue:back() -> string`: Return the back value without removing it. Returns nil if empty.
- `LQueue:clear() -> nil`: Remove all items from the queue. This method is available to Lua scripts.
- `LQueue:dequeue() -> string`: Remove and return the front value. Returns nil if empty.
- `LQueue:dequeueBack() -> string`: Remove and return the back value. Returns nil if empty.
- `LQueue:enqueue(value) -> boolean`: Add a value to the back of the queue. Returns false if at capacity.
- `LQueue:enqueueFront(value) -> boolean`: Add a value to the front of the queue (priority insertion). Returns false if at capacity.
- `LQueue:front() -> string`: Return the front value without removing it. Returns nil if empty.
- `LQueue:insertAt(index, value) -> boolean`: Insert a value at a 1-based index in the queue. Returns false if at capacity.
- `LQueue:isEmpty() -> boolean`: Check whether the queue is empty. This method is available to Lua scripts.
- `LQueue:isFull() -> boolean`: Check whether the queue has reached its capacity limit.
- `LQueue:len() -> number`: Return the current number of items in the queue.
- `LQueue:peekAt(index) -> string`: Return the value at a 1-based index without removing it. Returns nil if out of range.
- `LQueue:removeAt(index) -> string`: Remove and return the value at a 1-based index. Returns nil if out of range.
- `LQueue:toArray() -> number[]`: Return all queue items as an array table (front to back).

#### LRelationshipManager Type

- Lua-facing relationship manager for tracking numeric values and named levels between entity pairs.

##### Fields

- No documented fields.

##### Methods

- `LRelationshipManager:adjustValue(a, b, delta) -> nil`: Add a delta to the relationship value between two entities.
- `LRelationshipManager:defineType(name, levels, defaultLevel?) -> nil`: Define a relationship type with named levels (e.g. "friendship" with levels ["hostile", "neutral", "friendly"]).
- `LRelationshipManager:getLevel(a, b, typeName) -> string`: Get the named level for a relationship type between two entities.
- `LRelationshipManager:getValue(a, b) -> number`: Get the numeric relationship value between two entity IDs.
- `LRelationshipManager:pairCount() -> number`: Return the total number of tracked entity pairs.
- `LRelationshipManager:removePair(a, b) -> nil`: Remove all relationship data between two entities.
- `LRelationshipManager:removeType(name) -> nil`: Remove a relationship type definition.
- `LRelationshipManager:setLevel(a, b, typeName, level) -> boolean`: Set the named level for a relationship type between two entities.
- `LRelationshipManager:setValue(a, b, value) -> nil`: Set the numeric relationship value between two entity IDs.
- `LRelationshipManager:typeNames() -> string[]`: Return all defined relationship type names.

#### LRing Type

- Lua-facing fixed-size ring buffer for numeric or string values. Oldest entries are overwritten when full.

##### Fields

- No documented fields.

##### Methods

- `LRing:average() -> number`: Return the arithmetic mean of all numeric values in the ring.
- `LRing:clear() -> nil`: Remove all entries from the ring. This method is available to Lua scripts.
- `LRing:isFull() -> boolean`: Check whether the ring has reached its maximum capacity.
- `LRing:latest() -> table|nil`: Return the most recently pushed entry as a table with id, tag, value, and text fields. Returns nil if empty.
- `LRing:len() -> number`: Return the number of entries currently in the ring.
- `LRing:push(value, tag?) -> number`: Push a number or string value into the ring. Overwrites the oldest entry if the ring is full.
- `LRing:sum() -> number`: Return the sum of all numeric values in the ring. Non-numeric entries contribute zero.
- `LRing:toArray() -> table`: Return all entries in the ring as an ordered array of tables (oldest to newest).

#### LRingLatestResult Type

- Generated result shape from @field tags.

##### Fields

- `id` (`integer`): Id.
- `tag` (`string`): Tag.
- `text` (`string`): Text.
- `value` (`number`): Value.

##### Methods

- No documented methods.

#### LRingToArrayResult Type

- Generated result shape from @field tags.

##### Fields

- `id` (`integer`): Entry id.
- `tag` (`string`): Tag string.
- `text` (`string`): Text content.
- `value` (`number`): Numeric value.

##### Methods

- No documented methods.

#### LServiceLocator Type

- Lua-facing service locator for registering and retrieving shared services by name at runtime.

##### Fields

- No documented fields.

##### Methods

- `LServiceLocator:clearAll() -> nil`: Remove all registered services and reset the locator.
- `LServiceLocator:getServices() -> string[]`: Return an array of all registered service names.
- `LServiceLocator:has(name) -> boolean`: Check whether a service with the given name is currently registered.
- `LServiceLocator:locate(name) -> table`: Retrieve a registered service by name. Returns nil if not found.
- `LServiceLocator:provide(name, value) -> nil`: Register a service instance under a given name. Replaces any previously registered service with the same name.
- `LServiceLocator:remove(name) -> nil`: Unregister and discard a service by name.

#### LSet Type

- Lua-facing string set with add/remove/has operations and set algebra (union, intersection).

##### Fields

- No documented fields.

##### Methods

- `LSet:add(key) -> boolean`: Add a string to the set. Returns true if it was not already present.
- `LSet:clear() -> nil`: Remove all items from the set. This method is available to Lua scripts.
- `LSet:has(key) -> boolean`: Check whether a string is in the set.
- `LSet:intersection(other) -> LSet`: Return a new set containing only items present in both this set and another.
- `LSet:isEmpty() -> boolean`: Check whether the set is empty. This method is available to Lua scripts.
- `LSet:len() -> number`: Return the number of items in the set.
- `LSet:remove(key) -> boolean`: Remove a string from the set. Returns true if it was present.
- `LSet:toArray() -> string[]`: Return all set items as an array table.
- `LSet:union(other) -> LSet`: Return a new set containing all items from both this set and another.

#### LSimpleState Type

- Lua-facing finite state machine with enter/exit/update callbacks per state.

##### Fields

- No documented fields.

##### Methods

- `LSimpleState:addState(name, callbacks?) -> nil`: Register a named state with optional enter, exit, and update callbacks.
- `LSimpleState:clearAll() -> nil`: Remove all states and their callbacks, resetting the state machine.
- `LSimpleState:getCurrent() -> string`: Return the name of the currently active state, or nil if no state is set.
- `LSimpleState:getStates() -> string[]`: Return an array of all registered state names.
- `LSimpleState:hasState(name) -> boolean`: Check whether a state with the given name is registered.
- `LSimpleState:transitionTo(name) -> boolean`: Transition to a new state. Calls the current state's `exit` and the target state's `enter` callbacks.
- `LSimpleState:update(dt) -> nil`: Call the current state's update callback with the frame delta time.

#### LStack Type

- Lua-facing LIFO stack with optional capacity limit. Supports push/pop from both ends.

##### Fields

- No documented fields.

##### Methods

- `LStack:clear() -> nil`: Remove all items from the stack. This method is available to Lua scripts.
- `LStack:insertAt(index, value) -> boolean`: Insert a value at a 1-based index in the stack, shifting items above it. Returns false if at capacity.
- `LStack:isEmpty() -> boolean`: Check whether the stack is empty. This method is available to Lua scripts.
- `LStack:isFull() -> boolean`: Check whether the stack has reached its capacity limit (if one was set).
- `LStack:len() -> number`: Return the current number of items in the stack.
- `LStack:moveWithin(from, to) -> boolean`: Move an item from one 1-based index to another within the stack.
- `LStack:peek() -> string`: Return the top value without removing it. Returns nil if empty.
- `LStack:peekAt(index) -> string`: Return the value at a 1-based index without removing it. Returns nil if out of range.
- `LStack:peekBottom() -> string`: Return the bottom value without removing it. Returns nil if empty.
- `LStack:pop() -> string`: Remove and return the top value. Returns nil if the stack is empty.
- `LStack:popBottom() -> string`: Remove and return the bottom value. Returns nil if empty.
- `LStack:popMany(count) -> integer[]`: Pop up to `count` values from the top and return them as an array table.
- `LStack:push(value) -> boolean`: Push a value onto the top of the stack. Returns false if the stack is at capacity.
- `LStack:pushBottom(value) -> boolean`: Push a value onto the bottom of the stack. Returns false if at capacity.
- `LStack:removeAt(index) -> string`: Remove and return the value at a 1-based index. Returns nil if out of range.
- `LStack:toArray() -> number[]`: Return all stack items as an array table (bottom to top).

#### LStrategy Type

- Lua-facing strategy pattern allowing hot-swappable algorithm implementations by name.

##### Fields

- No documented fields.

##### Methods

- `LStrategy:clear() -> nil`: Remove all strategies and reset the selection.
- `LStrategy:execute(...) -> table`: Execute the currently active strategy, passing through all arguments and returning its results.
- `LStrategy:getCurrent() -> string`: Return the name of the currently active strategy, or nil if none set.
- `LStrategy:has(name) -> boolean`: Check whether a strategy with the given name is registered.
- `LStrategy:names() -> string[]`: Return an array of all registered strategy names.
- `LStrategy:register(name, callback) -> nil`: Register a named strategy implementation function.
- `LStrategy:remove(name) -> boolean`: Remove a named strategy. If it was the active strategy, no strategy will be selected.
- `LStrategy:set(name) -> boolean`: Switch to a named strategy. Future `execute()` calls will use this implementation.

#### LThrottle Type

- Lua-facing throttle that limits how often an action can fire, enforcing a minimum interval between executions.

##### Fields

- No documented fields.

##### Methods

- `LThrottle:getFireCount() -> number`: Return the total number of times this throttle has fired since creation.
- `LThrottle:getProgress() -> number`: Return how far through the current interval the throttle is (0.0 to 1.0).
- `LThrottle:onFire(f) -> nil`: Set the callback function to invoke each time the throttle fires.
- `LThrottle:reset() -> nil`: Reset the throttle timer back to zero without firing.
- `LThrottle:setEnabled(enabled) -> nil`: Enable or disable the throttle. When disabled, update() will not accumulate time.
- `LThrottle:update(dt) -> boolean`: Advance the throttle timer. If the interval has elapsed, fires the callback and returns true.

#### LWeightedRandom Type

- Lua-facing weighted random selection pool. Add items with weights and pick random selections.

##### Fields

- No documented fields.

##### Methods

- `LWeightedRandom:add(weight, value, label?) -> number`: Add an item with a relative weight. Higher weight = higher selection probability.
- `LWeightedRandom:clearAll() -> nil`: Remove all entries from the pool. This method is available to Lua scripts.
- `LWeightedRandom:getRevision() -> number`: Return the revision counter. Increments on any add/remove/weight change.
- `LWeightedRandom:isEmpty() -> boolean`: Check whether the pool has no entries.
- `LWeightedRandom:len() -> number`: Return the number of entries in the pool.
- `LWeightedRandom:pick(sample) -> string`: Pick one item using a random sample value in [0, 1). Returns its value or nil.
- `LWeightedRandom:pickN(count, samples) -> number[]`: Pick multiple unique items. Requires an array of random samples.
- `LWeightedRandom:remove(id) -> boolean`: Remove an item by its ID. Returns true if it existed.
- `LWeightedRandom:setWeight(id, weight) -> boolean`: Change the weight of an existing entry.
- `LWeightedRandom:totalWeight() -> number`: Return the sum of all entry weights.

## Examples

- `content/examples/patterns.lua` (present)

## Architecture Links

- Intentionally empty.

## Notes

- No additional module-specific notes.
