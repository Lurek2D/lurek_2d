# patterns

## TL;DR

- Provides a comprehensive architectural toolkit for state, decision, and communication coordination.
- Implements behavior trees, finite state machines, event buses, blackboards, and command stacks.
- Controls execution cadences via throttles, debounces, and reusable object pools.
- Supports graph structures, bidirectional maps, prefix tries, factories, and service locators.

## General Info

- Module group: `Foundations`
- Source path: `src/patterns/`
- Binding: `src/lua_api/patterns_api.rs`
- Namespace: `lurek.patterns`
- Lua API surface: `24` functions, `27` types, `218` methods
- Rust test path(s): tests/rust/unit/patterns_tests.rs
- Lua test path(s): tests/lua/unit/test_patterns_core_unit.lua; tests/lua/stress/test_patterns_stress.lua

## Summary

- The patterns module is a Foundations toolbox for coordination, control flow, and reusable architecture primitives.
- It focuses on decoupling systems and making game logic easier to compose and test.
- Behavior trees provide deterministic reactive decision flow with explicit node semantics.
- Trees support sequence, selector, inverter, repeater, and parallel execution patterns.
- Runtime tree state is preserved across ticks for long-running action continuity.
- Simple state tracking supports lightweight single-mode workflows.
- Full state machines provide guarded transitions and bounded transition history.
- Transition history enables debugging and analytics of behavior progression.
- Event buses provide publish-subscribe routing with priorities and wildcard listeners.
- One-shot listeners reduce boilerplate for temporary event reactions.
- Mediator routing supports broker-style communication channels between decoupled systems.
- Blackboard storage supports shared facts with revision-aware reads.
- Hierarchical blackboards allow local override with parent fallback.
- Observer primitives provide key-based reactive notifications.
- Wildcard observers support broad state-change monitoring.
- Command stacks implement undo and redo with bounded history policies.
- Batch commands support atomic rollback of multi-step operations.
- Throttle and debounce utilities control cadence for noisy inputs and triggers.
- Object pools support stable identity reuse in allocation-sensitive loops.
- Priority queues support deterministic ordering for equal-priority entries.
- Ring buffers retain rolling windows of recent values or events.
- Bi-directional maps support reversible key-value lookup.
- Tries support efficient prefix search for command palettes and filters.
- Factory registries support data-driven construction by symbolic names.
- Strategy registries support runtime algorithm swapping without callsite rewrites.
- Service locators expose shared capability lookup for loosely-coupled modules.
- Graph primitives support node-edge modeling with traversal helpers.
- Weighted random selection supports repeat-aware probabilistic choice.
- Funnel buffering supports time-windowed accumulation and controlled flush behavior.
- Collection capacity helpers keep bounded/unbounded semantics consistent.
- The module favors explicit IDs and stable iteration order.
- That design improves reproducibility across runs and test environments.
- Primitives are intentionally small and orthogonal for composability.
- The module does not own gameplay domain rules.
- It does not own rendering, audio, filesystem, or host runtime concerns.
- It is intended to be reused by many higher-level feature modules.
- Typical AI stacks combine behavior trees, blackboards, and event buses.
- Typical tooling stacks combine command stacks with observers.
- Typical input pipelines combine debounce/throttle with ring diagnostics.
- Contracts are script-friendly while keeping behavior deterministic.
- APIs are designed for incremental adoption in existing systems.
- Cross-module dependencies remain acyclic at the Foundations level.
- The module improves maintainability by reducing orchestration duplication.
- It improves testability by making side effects and transitions explicit.
- It improves readability by encoding common control patterns directly.
- The toolbox is broad but consistently structured.
- It scales from small prototypes to production systems.
- It remains architecture-focused rather than feature-domain specific.
- Overall, patterns is the reusable orchestration layer beneath gameplay features.
- It exists to help teams ship complex behavior with less structural debt.

This module primarily collaborates with `runtime`. Its responsibility should stay inside the Foundations group rather than absorb behavior owned by those neighbors.

## Imports

- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Foundations` into `Core Runtime`.

## Files

### behavior_tree.rs

- Behavior tree runtime for composing game and AI decisions as explicit node graphs that evaluate in a stable left-to-right order.
- The file provides structural node storage for sequences, selectors, parallels, repeaters, inverters, and named leaf actions without hiding execution flow behind opaque callbacks.
- It keeps build-time graph authoring and tick-time run state close together so trees can be assembled, reset, and stepped with predictable control over parent-child relationships.
- Repeat counters, running markers, and root selection live alongside compact integer node addressing, which keeps behavior updates easy to reason about and cheap to traverse.
- Functionally this file delivers the core decision backbone for scripted actors that need readable branching logic, reusable subtrees, and deterministic per-frame evaluation semantics.

### bimap.rs

- Bidirectional map storage for cases where game code must move between symbolic keys and canonical values with equal ease.
- The file maintains mirrored forward and reverse tables so each mutation preserves a single authoritative pairing instead of forcing callers to manage two separate maps by hand.
- Inserts, removals, and containment checks are shaped around keeping that two-way contract coherent even when entries are replaced or deleted from either side.
- Functionally this delivers fast reversible lookup for registries, id-name bindings, alias tables, and other systems that need symmetry rather than one-directional indexing.

### blackboard.rs

- Shared blackboard storage for gameplay and AI systems that need a common language for state without hard-coding direct dependencies between producers and consumers.
- The file models values as a compact tagged set of common script-facing types and couples each write to revision tracking so readers can cheaply detect what changed and when.
- Parent-linked lookup lets a local board inherit broader context while still overriding specific keys, which makes squad, faction, and entity state layering practical.
- Typed getters, defaults, clears, and revision queries turn the store into more than a raw map by giving behavior code a disciplined way to read uncertain state.
- Functionally this is the coordination memory for systems that want shared facts, incremental change detection, and hierarchical fallback instead of tightly wired state plumbing.

### collections.rs

- Small shared capacity metadata for collection-style pattern objects that expose bounded or unbounded behavior through one consistent rule set.
- The file centralizes count, limit, and full-state semantics so stacks, queues, and similar wrappers can agree on what capacity means without duplicating bookkeeping code.
- Functionally this delivers the lightweight policy layer behind collection limits, especially the convention that zero means unbounded while positive values enforce a hard ceiling.

### command_stack.rs

- Command history storage for features that need explicit undo and redo flow instead of ad hoc reversal logic spread across many systems.
- The file tracks a linear timeline with a movable cursor, letting callers push new actions, walk backward through applied work, and replay discarded steps in order.
- Batch grouping keeps multi-step edits together as one logical unit, which matters for editors, tactics actions, and scripted transactions that should reverse atomically.
- Size limits and eviction rules keep history bounded without losing the current navigation model or forcing clients to hand-roll trimming behavior.
- Functionally this delivers the memory of reversible work for tooling and gameplay flows that care about chronological intent, replay, and controlled rollback.

### event_bus.rs

- Event bus routing for decoupled gameplay communication where systems publish named signals and interested listeners react without direct caller knowledge.
- The file organizes subscriptions by event name while preserving listener identity, priority order, and wildcard reach so dispatch can stay predictable as projects grow.
- One-shot listeners, targeted clearing, and ordered listener extraction make the bus practical both for transient reactions and for long-lived system wiring.
- Rather than executing script callbacks itself, it prepares the dispatch shape that higher layers can consume while keeping subscription state authoritative in one place.
- Functionally this is the message circulation core for feature coordination, broadcast-style notifications, and low-friction cross-system signaling.

### factory.rs

- Runtime factory registry for systems that construct objects by declared type names instead of hard-wiring every spawn path to concrete branches.
- The file keeps canonical names and aliases aligned so different labels can converge on the same build target while still allowing registration changes at runtime.
- Resolution, replacement, and removal are framed around keeping the name graph explicit and queryable rather than letting construction rules disappear into scattered conditionals.
- Functionally this delivers the naming and lookup backbone for data-driven spawning, pluggable content registration, and alias-friendly creation flows.

### funnel.rs

- Buffered funnel for gathering small tagged numeric events into controlled flush windows instead of reacting to every sample the instant it arrives.
- The file couples entry accumulation with elapsed-time tracking and count thresholds so callers can model batch release, burst shaping, or windowed aggregation with simple state.
- Immediate windows, manual discard, and explicit readiness checks make the behavior usable for both deterministic simulation ticks and script-driven control loops.
- Functionally this delivers a compact batching primitive for telemetry, combo capture, score staging, and other flows where grouping matters more than raw per-event immediacy.

### graph.rs

- General-purpose graph structure for gameplay relationships, navigation-like topologies, and any domain that benefits from explicit nodes connected by weighted or labelled edges.
- The file stores graph state as stable integer-addressed nodes and adjacency lists, which keeps structural edits straightforward while preserving identities scripts can hold onto.
- Directed and undirected operation live behind one representation, including automatic reverse-edge behavior when a connection should semantically exist in both directions.
- Traversal helpers expose breadth-first and depth-first walks as first-class capabilities so callers can inspect reachability, discover neighborhoods, or derive ordered visits without rebuilding utility code.
- Connectivity checks, node metadata, and edge labels make the graph more than a bare container by supporting practical gameplay queries around ownership, routes, influence, or dependency webs.
- Functionally this file delivers the relational map backbone for systems that need editable topology, traversable links, and stable graph identities in script-friendly form.

### mediator.rs

- Mediator registry for coordinating communication through named channels when systems should meet through a broker rather than pointing at each other directly.
- The file assigns durable handler identities per channel so registration, removal, counting, and inspection all speak the same compact vocabulary.
- By storing channel membership centrally it becomes easy to clear one lane of traffic or reset the whole routing surface without leaking per-subscriber bookkeeping into callers.
- Functionally this delivers a message rendezvous layer for decoupled gameplay features, scripted services, and hub-style coordination flows.

### mod.rs

- Foundational gameplay pattern toolbox that packages decision flow, state coordination, messaging, reuse, and selection primitives into small reusable building blocks.
- The module supplies behavior trees, simple and guarded state machines, observer and event distribution layers, mediator routing, factories, service lookup, and undo-oriented command history.
- It also delivers practical supporting structures such as graphs, tries, rings, priority ordering, bidirectional lookup, weighted picks, throttling windows, buffered funnels, and object reuse pools.
- At module level this is the high-level kit for assembling decoupled game logic systems in Lua and Rust without re-implementing common orchestration patterns for each feature.

### object_pool.rs

- Object pool state for reuse-heavy systems that would rather recycle stable ids than continuously allocate and discard short-lived gameplay resources.
- The file separates idle and active membership, supports prewarming, and enforces optional capacity so callers can shape reuse policy without inventing their own lifecycle bookkeeping.
- Acquire and release flow is designed around predictable id turnover, which suits bullets, particles, temporary actors, and other bursty populations.
- Functionally this delivers the reuse scheduler behind allocation-sensitive gameplay loops that want bounded churn and explicit ownership transitions.

### observer.rs

- Observer-style notification store for reactive game state where changes on named keys should wake interested listeners without binding readers to writers.
- The file keeps subscriptions grouped by key while still supporting wildcard reach, so systems can watch a narrow property or an entire stream of change events.
- Persistent and one-shot modes share one dispatch model, which simplifies lifecycle handling and ensures cleanup happens in the same place that notifications are tracked.
- Clear operations, listener ids, and stored observer entries make the structure suitable for long-running scenes where subscriptions need explicit ownership and maintenance.
- Functionally this delivers the change-broadcast layer for reactive UI, quest logic, AI memory watchers, and any flow that responds to named value transitions.

### priority_queue.rs

- Ordered priority queue for gameplay scheduling and selection tasks that need highest-priority work first without losing deterministic order among ties.
- The file assigns each entry its own identity and insertion sequence so queue mutation remains inspectable even when multiple items share the same score.
- Push, pop, peek, and targeted removal operate on one consistently sorted store rather than spreading priority semantics across separate containers and side maps.
- Functionally this delivers stable urgency-based ordering for task systems, AI planners, turn resolution, and any script logic that needs predictable priority arbitration.

### ring.rs

- Fixed-capacity ring buffer for rolling gameplay history where the newest samples matter most but recent context still needs to remain queryable in order.
- The file stores tagged entries in arrival order and automatically evicts the oldest data once capacity is reached, keeping the window fresh without manual trimming.
- Numeric and string payload support makes the structure useful for both measured telemetry and symbolic event trails.
- Aggregate helpers and ordered iteration turn the buffer into a practical runtime history tool instead of a passive overwrite container.
- Functionally this delivers short-horizon memory for combo tracking, diagnostics, smoothing inputs, and any system that lives on a moving recent window.

### service_locator.rs

- Lightweight service locator for runtime feature discovery when systems need to find shared capabilities by agreed names instead of direct construction paths.
- The file keeps registration, removal, lookup, and sorted listing in one compact registry so service presence stays explicit and easy to inspect.
- Functionally this delivers a simple dependency access hub for loosely coupled gameplay code, especially where availability changes during runtime.

### simple_state.rs

- Minimal named-state tracker for systems that only need one active mode at a time without the heavier transition model of a full state machine.
- The file focuses on managing the known state set and the current selection, which keeps switching semantics explicit and validation cheap.
- Enumeration and counting support make the registry easy to inspect from scripts and tooling that want to reason about available modes.
- Functionally this delivers the lightweight mode switch core for menus, AI phases, control states, and other simple single-state flows.

### state_machine.rs

- Full finite state machine runtime for systems that need named states, validated transitions, and a remembered trail of where control has moved over time.
- The file separates state membership from transition rules so allowed movement stays explicit and can be guarded rather than implied by arbitrary caller behavior.
- Bounded history gives each machine a replayable memory of recent changes, which is useful for debugging, analytics, and gameplay rules that depend on prior modes.
- Current-state management, rule inspection, and history maintenance live together so switching logic stays coherent instead of fragmenting across helpers.
- Functionally this delivers the structured mode-control layer for actors, encounters, UI flows, and scripted systems with meaningful transition policy.

### strategy.rs

- Strategy registry for features that swap among named behaviors or algorithms while keeping the selection surface explicit and data-driven.
- The file assigns stable ids to registered strategies and tracks which one is currently active so callers can inspect or switch policy without hidden branching.
- Registration and removal are treated as first-class operations, which fits systems where available strategies change with content, upgrades, or scripting.
- Functionally this delivers the hot-swappable behavior catalog behind interchangeable decision rules, tactics, generators, or processing modes.

### throttle.rs

- Timing control primitives for gameplay actions that should be rate-limited or delayed instead of firing on every raw input or event edge.
- The file pairs throttle and debounce behaviors in one place because both solve cadence control while differing in whether they emit immediately or only after quiet time.
- Shared state around elapsed time, enable flags, fire counts, and reset flow makes these utilities practical for per-frame ticking and script-side inspection.
- Progress queries on throttle and trigger-cancel semantics on debounce cover the two common rhythms of spaced repetition and delayed confirmation.
- Functionally this delivers the pacing layer for input smoothing, cooldown-like gates, UI chatter suppression, and event burst control.

### trie.rs

- Prefix trie storage for string-centric gameplay data where whole-key lookup and shared-prefix discovery should both be fast and structurally related.
- The file models words as character paths, letting inserts and exact searches coexist naturally with prefix queries that expand into many matching keys.
- Removal includes branch pruning so the structure sheds dead paths instead of accumulating empty nodes after content churn.
- Depth-first key collection turns the trie into a practical retrieval tool for completions, dictionaries, filters, and lookup-heavy scripting workflows.
- Functionally this delivers the text-prefix indexing backbone for command palettes, content search, lexicons, and other systems built around incremental string matching.

### weighted_random.rs

- Weighted random selector for content and gameplay systems that want probability-driven picks while still keeping the candidate set editable at runtime.
- The file stores named weighted entries and supports structural mutation so drops, spawns, behaviors, or narrative beats can rebalance without rebuilding the container.
- It covers both single draws and multi-pick selection without replacement, which makes the same structure useful for one-off rolls and curated batches.
- Revision tracking gives outside code a reliable signal that probabilities or membership changed, helping caches and derived tables stay honest.
- Functionally this delivers the probability orchestration layer for loot tables, encounter variation, weighted choices, and repeat-aware random selection flows.



## Lua API Ref

### Functions

- `lurek.patterns.newBehaviorTree() -> LBehaviorTree`: Create a new behavior tree for AI decision-making with sequences, selectors, parallels, and leaf actions.
- `lurek.patterns.newBlackboard(name?) -> LBlackboard`: Create a new shared key-value blackboard supporting reactive watchers for game logic variables.
- `lurek.patterns.newCommandStack(maxSize?) -> LCommandStack`: Create a new undo/redo command stack for recording and reversing player or editor actions.
- `lurek.patterns.newDebounce(wait) -> LDebounce`: Create a new debounce that delays firing until input stops for a specified wait period.
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

## References

- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Foundations` into `Core Runtime`.

## Notes

- No additional module-specific notes.
