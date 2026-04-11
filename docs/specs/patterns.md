# patterns

## General Info

- Module group: `Foundations`
- Source path: `src/patterns/`
- Lua API path(s): `src/lua_api/patterns_api.rs`
- Primary Lua namespace: `lurek.patterns`
- Rust test path(s): tests/rust/unit/patterns_tests.rs
- Lua test path(s): tests/lua/unit/test_patterns.lua; tests/lua/stress/test_patterns_stress.lua

## Summary

The `patterns` module owns reusable coordination primitives for Lurek2D gameplay code. It gathers small, pure-Rust building blocks such as event buses, state trackers, queues, registries, object pools, throttles, blackboards, and similar logic helpers that can be shared across many higher-level systems.

This module exists so common gameplay-control patterns do not have to be reimplemented ad hoc in Lua or buried inside unrelated engine modules. Most types here intentionally store only the domain-side bookkeeping and metadata, while the Lua API layer adds callback storage, registry keys, and UserData wrappers on top.

`patterns` intentionally does not own the engine's global event system, ECS state, AI decision policies, or task-graph execution. It provides generic mechanics and containers; feature modules are responsible for deciding when and why to use them.

**Scope boundary**: This module currently acts as a mostly self-contained part of the Foundations layer. Cross-module behavior should remain anchored to the top-level source files and Lua bindings listed below.

## Files

- `blackboard.rs`: Implements a shared typed key-value board with revision tracking for cross-system facts.
- `command_stack.rs`: Tracks undo and redo history metadata, including cursor position and batching state.
- `event_bus.rs`: Implements named event-subscription metadata with priority ordering and one-shot listeners.
- `factory.rs`: Implements a constructor-name registry with optional alias resolution.
- `funnel.rs`: Implements a time-windowed event collector that can batch inputs before flushing.
- `mod.rs`: Declares the patterns submodules and re-exports the public helper types.
- `object_pool.rs`: Implements slot bookkeeping for reusable pooled objects, including idle and active tracking.
- `observer.rs`: Implements per-key watcher metadata for reactive property changes.
- `priority_queue.rs`: Implements a stable highest-priority-first queue for small agenda or turn-order workloads.
- `ring.rs`: Implements a fixed-capacity circular history buffer for numeric or string-tagged entries.
- `service_locator.rs`: Implements a named-service presence registry used by the Lua layer to store actual values.
- `simple_state.rs`: Implements a lightweight named-state tracker with a single active state and no validated transition graph.
- `state_machine.rs`: Implements a fuller finite-state machine with registered states, explicit transition rules, and history.
- `throttle.rs`: Implements leading-edge throttle and trailing-edge debounce timers for callback rate limiting.

## Types

- `BlackboardValue` (`enum`, `blackboard.rs`): Tagged value enum stored inside a `Blackboard`. It keeps the shared state surface small and predictable.
- `Blackboard` (`struct`, `blackboard.rs`): Shared fact store for lightweight cross-system coordination. It is useful when multiple systems need to read and write the same named state without a direct dependency.
- `CommandEntry` (`struct`, `command_stack.rs`): Single recorded command inside a `CommandStack`. It carries the user-visible label and undo capability metadata.
- `CommandStack` (`struct`, `command_stack.rs`): Undo and redo metadata tracker. The Lua layer attaches the actual callbacks, but this type owns the history rules.
- `Subscription` (`struct`, `event_bus.rs`): Metadata record for one event-bus listener. It keeps listener identity, target event, and once behavior explicit.
- `EventBus` (`struct`, `event_bus.rs`): Named pub-sub registry that orders listeners by priority. It is the local coordination primitive for systems that need scoped event routing.
- `Factory` (`struct`, `factory.rs`): Named constructor registry. It helps scripts instantiate families of objects without hard-coding constructor tables everywhere.
- `FunnelEntry` (`struct`, `funnel.rs`): Single buffered record inside a `Funnel`.
- `Funnel` (`struct`, `funnel.rs`): Batch collector that groups time-adjacent events before a flush.
- `ObjectPool` (`struct`, `object_pool.rs`): Slot manager for reusable objects. It separates active and idle handles so higher-level code can reduce allocation churn.
- `ObserverEntry` (`struct`, `observer.rs`): Metadata for one observer subscription. It tracks watcher identity, watched key, and once semantics.
- `Observer` (`struct`, `observer.rs`): Per-key subscription registry for reactive property changes. Use it when changes should be keyed to specific names rather than free-form events.
- `PriorityItem` (`struct`, `priority_queue.rs`): Entry stored inside a `PriorityQueue`. It carries priority plus stable insertion sequencing.
- `PriorityQueue` (`struct`, `priority_queue.rs`): Stable priority queue for small scheduling and agenda workloads. It favors simple predictable ordering over heap complexity.
- `Ring` (`struct`, `ring.rs`): Fixed-capacity rolling history buffer. It is useful for recent-input, combo, telemetry, or score-history style workflows.
- `RingEntry` (`struct`, `ring.rs`): One retained ring-buffer entry with optional numeric or string payload and a tag.
- `ServiceLocator` (`struct`, `service_locator.rs`): Named-service registry. The domain type tracks registration while the Lua layer stores the actual service values.
- `SimpleState` (`struct`, `simple_state.rs`): Minimal state tracker with one active named state. It is the simpler choice when callers do not need validated transition rules.
- `TransitionRule` (`struct`, `state_machine.rs`): Declares one allowed transition in a `StateMachine`. It keeps edge validation and optional guard presence explicit.
- `StateMachine` (`struct`, `state_machine.rs`): Transition-aware finite-state machine with registered states and visit history. Use it when transition structure matters.
- `Throttle` (`struct`, `throttle.rs`): Leading-edge rate limiter that decides when a callback is allowed to fire.
- `Debounce` (`struct`, `throttle.rs`): Trailing-edge idle timer that delays firing until input settles.

## Functions

- `Blackboard::new` (`blackboard.rs`): Creates an empty blackboard with the given name.
- `Blackboard::set_bool` (`blackboard.rs`): Sets a boolean fact.
- `Blackboard::set_number` (`blackboard.rs`): Sets a numeric fact.
- `Blackboard::set_text` (`blackboard.rs`): Sets a string fact.
- `Blackboard::clear` (`blackboard.rs`): Clears (sets to nil) a fact.
- `Blackboard::get` (`blackboard.rs`): Returns the current value for a key, or `None` if absent.
- `Blackboard::keys` (`blackboard.rs`): Returns all keys currently set on the blackboard.
- `Blackboard::snapshot` (`blackboard.rs`): Returns all key-value pairs as a snapshot.
- `Blackboard::has` (`blackboard.rs`): Returns `true` when the key holds any non-nil value.
- `Blackboard::key_revision` (`blackboard.rs`): Returns the board revision when `key` was last written, or `0` if never.
- `Blackboard::clear_all` (`blackboard.rs`): Clears all facts and resets the blackboard.
- `Blackboard::len` (`blackboard.rs`): Returns the number of facts currently stored.
- `Blackboard::is_empty` (`blackboard.rs`): Returns `true` when no facts are stored.
- `CommandStack::new` (`command_stack.rs`): Creates a new command stack.
- `CommandStack::push` (`command_stack.rs`): Records a new command entry, discarding any redo history above the cursor.
- `CommandStack::peek_undo` (`command_stack.rs`): Returns the entry ID at the undo position (most recently applied command).
- `CommandStack::peek_redo` (`command_stack.rs`): Returns the entry ID at the redo position (next command that can be re-applied).
- `CommandStack::step_undo` (`command_stack.rs`): Moves cursor back one step (undo intent); caller must execute the callback.
- `CommandStack::step_redo` (`command_stack.rs`): Moves cursor forward one step (redo intent); caller must execute the callback.
- `CommandStack::clear` (`command_stack.rs`): Clears all history.
- `CommandStack::undo_count` (`command_stack.rs`): Number of undoable steps from the current cursor.
- `CommandStack::redo_count` (`command_stack.rs`): Number of redoable steps from the current cursor.
- `CommandStack::get_entry` (`command_stack.rs`): Lookup entry metadata by ID.
- `CommandStack::begin_batch` (`command_stack.rs`): Begins a batch grouping.
- `CommandStack::end_batch` (`command_stack.rs`): Ends a batch grouping and returns the grouped IDs if the outermost batch closes.
- `EventBus::new` (`event_bus.rs`): Creates a new, enabled event bus.
- `EventBus::subscribe` (`event_bus.rs`): Registers a subscription and returns its handle ID.
- `EventBus::unsubscribe` (`event_bus.rs`): Removes a subscription by its handle.
- `EventBus::get_listeners` (`event_bus.rs`): Returns ordered handles for dispatching `event` (highest priority first).
- `EventBus::drain_once` (`event_bus.rs`): Returns handles that marked `once = true` for use-after-dispatch cleanup.
- `EventBus::clear_event` (`event_bus.rs`): Removes all subscriptions for an event, returning their handle IDs.
- `EventBus::clear_all` (`event_bus.rs`): Removes every subscription, returning all handle IDs.
- `EventBus::listener_count` (`event_bus.rs`): Returns the subscription count for an event.
- `EventBus::event_names` (`event_bus.rs`): Returns all unique event names with at least one subscription.
- `EventBus::total_count` (`event_bus.rs`): Total number of active subscriptions across all events.
- `Factory::new` (`factory.rs`): Creates a new empty factory.
- `Factory::register` (`factory.rs`): Registers a type name.
- `Factory::unregister` (`factory.rs`): Removes a type name registration.
- `Factory::has` (`factory.rs`): Whether a type name is registered (resolves aliases).
- `Factory::resolve` (`factory.rs`): Resolves an alias to its canonical name, or returns the name unchanged.
- `Factory::add_alias` (`factory.rs`): Registers a type alias pointing to an existing canonical name.
- `Factory::type_names` (`factory.rs`): Returns all registered type names sorted alphabetically.
- `Factory::clear` (`factory.rs`): Clears all registrations and aliases.
- `Funnel::new` (`funnel.rs`): Creates a new funnel.
- `Funnel::push` (`funnel.rs`): Adds an event to the funnel.
- `Funnel::update` (`funnel.rs`): Advances the window timer by `dt` seconds.
- `Funnel::flush` (`funnel.rs`): Drains all buffered entries and resets the timer.
- `Funnel::pending` (`funnel.rs`): Returns the buffered entries without draining them.
- `Funnel::pending_count` (`funnel.rs`): Number of buffered entries.
- `Funnel::discard` (`funnel.rs`): Discards all buffered entries without calling a flush callback.
- `ObjectPool::new` (`object_pool.rs`): Creates a new pool.
- `ObjectPool::acquire` (`object_pool.rs`): Acquires an idle slot, returning its handle.
- `ObjectPool::release` (`object_pool.rs`): Returns a slot handle to the idle pool.
- `ObjectPool::release_all` (`object_pool.rs`): Moves all active handles back to idle, returning the released IDs.
- `ObjectPool::prewarm` (`object_pool.rs`): Pre-warms the idle pool to at least `count` total slots.
- `ObjectPool::idle_count` (`object_pool.rs`): Number of idle (available) slots.
- `ObjectPool::active_count` (`object_pool.rs`): Number of active (in-use) slots.
- `ObjectPool::total_count` (`object_pool.rs`): Total slots tracked (idle + active).
- `ObjectPool::is_active` (`object_pool.rs`): Whether a handle is currently active.
- `Observer::new` (`observer.rs`): Creates a new observer with the given name.
- `Observer::subscribe` (`observer.rs`): Registers a watcher for `key` (or `"*"` for all changes).
- `Observer::unsubscribe` (`observer.rs`): Removes a subscription by id.
- `Observer::watchers_for` (`observer.rs`): Returns subscriber ids that should fire when `key` changes.
- `Observer::clear_key` (`observer.rs`): Removes all subscriptions for a specific key.
- `Observer::clear_all` (`observer.rs`): Removes all subscriptions.
- `Observer::subscription_count` (`observer.rs`): Total number of active subscriptions across all keys.
- `PriorityQueue::new` (`priority_queue.rs`): Creates an empty priority queue.
- `PriorityQueue::push` (`priority_queue.rs`): Inserts an item with the given priority.
- `PriorityQueue::peek` (`priority_queue.rs`): Returns a reference to the highest-priority item without removing it.
- `PriorityQueue::pop` (`priority_queue.rs`): Removes and returns the highest-priority item id and priority.
- `PriorityQueue::remove` (`priority_queue.rs`): Removes the item with the given id.
- `PriorityQueue::len` (`priority_queue.rs`): Returns the number of items in the queue.
- `PriorityQueue::is_empty` (`priority_queue.rs`): Returns `true` when the queue is empty.
- `PriorityQueue::items` (`priority_queue.rs`): Returns all item records ordered by priority (highest first).
- `PriorityQueue::clear` (`priority_queue.rs`): Removes all items.
- `Ring::new` (`ring.rs`): Creates a new ring buffer with the given capacity.
- `Ring::push_number` (`ring.rs`): Pushes a numeric entry.
- `Ring::push_string` (`ring.rs`): Pushes a string entry.
- `Ring::iter` (`ring.rs`): Returns all entries from oldest to newest.
- `Ring::latest` (`ring.rs`): Returns the most-recently pushed entry.
- `Ring::oldest` (`ring.rs`): Returns the oldest retained entry.
- `Ring::len` (`ring.rs`): Number of entries currently held.
- `Ring::is_empty` (`ring.rs`): Returns `true` when the ring contains no entries.
- `Ring::is_full` (`ring.rs`): Returns `true` when the ring is at capacity.
- `Ring::clear` (`ring.rs`): Clears all entries (does not reset id counter).
- `Ring::sum` (`ring.rs`): Sum of all numeric values in the ring.
- `Ring::average` (`ring.rs`): Average of all numeric values, or `0` when empty.
- `ServiceLocator::new` (`service_locator.rs`): Creates a new empty service locator.
- `ServiceLocator::register` (`service_locator.rs`): Registers a service name.
- `ServiceLocator::unregister` (`service_locator.rs`): Removes a service name.
- `ServiceLocator::has` (`service_locator.rs`): Whether a service name is registered.
- `ServiceLocator::names` (`service_locator.rs`): Returns all registered service names sorted alphabetically.
- `ServiceLocator::clear` (`service_locator.rs`): Clears all registered services.
- `SimpleState::new` (`simple_state.rs`): Creates a new `SimpleState` with no states defined.
- `SimpleState::add` (`simple_state.rs`): Registers a state by name.
- `SimpleState::remove` (`simple_state.rs`): Removes a state by name.
- `SimpleState::has` (`simple_state.rs`): Returns `true` when `name` is a registered state.
- `SimpleState::current` (`simple_state.rs`): Returns the current state name, or `None` if no state is active.
- `SimpleState::set_current` (`simple_state.rs`): Transitions to `name`.
- `SimpleState::clear_current` (`simple_state.rs`): Clears the current state, leaving the machine in an inactive state.
- `SimpleState::states` (`simple_state.rs`): Returns all registered state names sorted alphabetically.
- `SimpleState::state_count` (`simple_state.rs`): Returns the number of registered states.
- `StateMachine::new` (`state_machine.rs`): Creates a new state machine with the given initial state.
- `StateMachine::add_state` (`state_machine.rs`): Registers a state, optionally marking callback presence.
- `StateMachine::has_state` (`state_machine.rs`): Whether a state is registered.
- `StateMachine::state_names` (`state_machine.rs`): Returns all registered state names.
- `StateMachine::add_transition` (`state_machine.rs`): Registers an allowed transition.
- `StateMachine::can_transition` (`state_machine.rs`): Whether a direct transition from `from` to `to` is defined.
- `StateMachine::get_transition` (`state_machine.rs`): Returns the `TransitionRule` for `from → to`, if defined.
- `StateMachine::transition_to` (`state_machine.rs`): Advances to a new state and records history.
- `StateMachine::history` (`state_machine.rs`): Returns the state visit history (oldest first).
- `StateMachine::reachable_from` (`state_machine.rs`): Returns reachable state names from the given state.
- `StateMachine::has_update_callback` (`state_machine.rs`): Whether the given state has an update callback.
- `Throttle::new` (`throttle.rs`): Creates a throttle that fires at most once per `interval` seconds.
- `Throttle::update` (`throttle.rs`): Advances time by `dt` seconds and returns `true` if the callback should fire.
- `Throttle::reset` (`throttle.rs`): Resets the elapsed counter forcing the next `update` to not fire (unless interval is 0).
- `Throttle::progress` (`throttle.rs`): Returns the normalised progress through the current interval in `[0, 1]`.
- `Debounce::new` (`throttle.rs`): Creates a debounce with the given idle `wait` duration.
- `Debounce::trigger` (`throttle.rs`): Records an input event, resetting the idle timer.
- `Debounce::update` (`throttle.rs`): Advances time by `dt` seconds.
- `Debounce::cancel` (`throttle.rs`): Cancels any pending trigger without firing.

## Lua API Reference

- Binding path(s): `src/lua_api/patterns_api.rs`
- Namespace: `lurek.patterns`

### Module Functions
- `lurek.patterns.newEventBus`: Creates a new EventBus instance.
- `lurek.patterns.newObjectPool`: Creates a new ObjectPool instance.
- `lurek.patterns.newCommandStack`: Creates a new CommandStack instance.
- `lurek.patterns.newServiceLocator`: Creates a new ServiceLocator instance.
- `lurek.patterns.newFactory`: Creates a new Factory instance.
- `lurek.patterns.newSimpleState`: Creates a new SimpleState finite state machine instance.
- `lurek.patterns.newBlackboard`: Creates a new Blackboard shared key-value store.
- `lurek.patterns.newObserver`: Creates a new reactive property Observer.
- `lurek.patterns.newThrottle`: Creates a leading-edge rate limiter that fires at most once per interval seconds.
- `lurek.patterns.newDebounce`: Creates a trailing-edge debounce that fires after the input stream is idle for wait seconds.
- `lurek.patterns.newPriorityQueue`: Creates a stable priority-ordered task queue.
- `lurek.patterns.newRing`: Creates a fixed-capacity circular history buffer.
- `lurek.patterns.newFunnel`: Creates a time-windowed event aggregator. window=0 means flush on every push.

### `Blackboard` Methods
- `Blackboard:set`: Sets a fact on the blackboard. Accepts boolean, number, or string values.
- `Blackboard:get`: Gets a fact from the blackboard. Returns nil if not set.
- `Blackboard:has`: Returns true when the key has a non-nil value.
- `Blackboard:clear`: Removes a fact from the blackboard.
- `Blackboard:keys`: Returns all set fact keys as a table.
- `Blackboard:watch`: Subscribes to changes on a specific key (or "*" for all changes).
- `Blackboard:unwatch`: Removes a watcher subscription by id.
- `Blackboard:getRevision`: Returns the monotonic revision counter (incremented on every write).
- `Blackboard:snapshot`: Returns all facts as a flat key→value table.
- `Blackboard:clearAll`: Clears all facts from the blackboard.

### `CommandStack` Methods
- `CommandStack:execute`: Executes a named command and records it in undo/redo history.
- `CommandStack:undo`: Undoes the most recent command. Returns true if successful.
- `CommandStack:redo`: Re-executes the next undone command. Returns true if successful.
- `CommandStack:canUndo`: Returns true if the most recent command can be undone.
- `CommandStack:canRedo`: Returns true if there is a command available to redo.
- `CommandStack:getHistorySize`: Returns the total number of recorded commands (undo + redo).
- `CommandStack:getCurrentName`: Returns the name of the most recently executed command, or nil.
- `CommandStack:clearAll`: Clears all command history, releasing Lua registry values.

### `Debounce` Methods
- `Debounce:onFire`: Sets the callback invoked when the debounce fires.
- `Debounce:trigger`: Records an input event, resetting the idle timer.
- `Debounce:update`: Advances the idle timer by dt seconds; fires the callback if idle wait expired.
- `Debounce:cancel`: Cancels the pending trigger without firing.
- `Debounce:isPending`: Returns true when a trigger is pending.
- `Debounce:getFireCount`: Returns the total number of times this debounce has fired.

### `EventBus` Methods
- `EventBus:on`: Registers a listener callback for an event.
- `EventBus:off`: Removes a previously registered event listener by subscription ID.
- `EventBus:emit`: Dispatches an event, calling all registered listeners in priority order.
- `EventBus:clear`: Removes all listeners for a specific event.
- `EventBus:clearAll`: Removes all listeners on this EventBus.
- `EventBus:getListenerCount`: Returns the number of listeners registered for an event.
- `EventBus:getEvents`: Returns all event names that have at least one listener.

### `Factory` Methods
- `Factory:register`: Registers a named type constructor function.
- `Factory:create`: Creates an instance of the named type by invoking its constructor.
- `Factory:has`: Returns true if the named type (or alias) is registered.
- `Factory:alias`: Registers an alias pointing to an existing canonical type name.
- `Factory:getTypes`: Returns a table of all registered type names.
- `Factory:remove`: Unregisters a type constructor (and any aliases pointing to it).
- `Factory:clearAll`: Removes all registered type constructors and aliases.

### `Funnel` Methods
- `Funnel:onFlush`: Sets a callback invoked when the funnel flushes. Receives a table of {tag, value} entries.
- `Funnel:push`: Adds an event to the funnel. Immediately flushes if max_entries reached or window is 0.
- `Funnel:update`: Advances the window timer by dt seconds; flushes when window expires.
- `Funnel:flush`: Manually flushes all pending entries, invoking the onFlush callback.
- `Funnel:discard`: Discards all buffered entries without flushing.
- `Funnel:pendingCount`: Returns the number of buffered entries not yet flushed.
- `Funnel:getFlushCount`: Returns the total number of flushes performed.

### `ObjectPool` Methods
- `ObjectPool:add`: Inserts a pre-built object into the available pool.
- `ObjectPool:acquire`: Acquires an available object from the pool; returns nil if empty.
- `ObjectPool:release`: Returns an object to the available pool.
- `ObjectPool:getActiveCount`: Returns the number of currently active (acquired) objects.
- `ObjectPool:getAvailableCount`: Returns the number of available (idle) objects in the pool.
- `ObjectPool:getTotalCount`: Returns the total number of tracked objects (active + available).
- `ObjectPool:clearAll`: Clears all objects from the pool, releasing Lua registry values.

### `Observer` Methods
- `Observer:set`: Sets a property value and fires subscribed watchers.
- `Observer:get`: Gets a property value, or nil if not set.
- `Observer:subscribe`: Subscribes to changes on a property key (or "*" for all).
- `Observer:unsubscribe`: Removes a subscription by id.
- `Observer:getCount`: Returns the total number of active subscriptions.

### `PriorityQueue` Methods
- `PriorityQueue:push`: Inserts an item with a priority. Higher priorities are dequeued first.
- `PriorityQueue:pop`: Removes and returns the highest-priority item, or nil if empty.
- `PriorityQueue:peek`: Returns the highest-priority item without removing it, or nil if empty.
- `PriorityQueue:len`: Returns the number of items in the queue.
- `PriorityQueue:isEmpty`: Returns true when the queue has no items.
- `PriorityQueue:clearAll`: Removes all items from the queue.

### `Ring` Methods
- `Ring:push`: Pushes a value (number or string) with an optional tag. Overwrites oldest on overflow.
- `Ring:latest`: Returns the most recently pushed entry, or nil.
- `Ring:toArray`: Returns all entries (oldest first) as an array of {id, tag, value?, text?} tables.
- `Ring:sum`: Returns the sum of all numeric values in the ring.
- `Ring:average`: Returns the average of all numeric values, or 0 if empty.
- `Ring:len`: Returns the number of entries currently in the ring.
- `Ring:isFull`: Returns true when the ring is at capacity.
- `Ring:clear`: Removes all entries from the ring.

### `ServiceLocator` Methods
- `ServiceLocator:provide`: Registers a named service with an associated Lua value.
- `ServiceLocator:locate`: Retrieves a registered service by name; returns nil if not found.
- `ServiceLocator:has`: Returns true if a service with the given name is registered.
- `ServiceLocator:remove`: Unregisters and removes a named service.
- `ServiceLocator:getServices`: Returns a table of all registered service names.
- `ServiceLocator:clearAll`: Removes all registered services.

### `SimpleState` Methods
- `SimpleState:addState`: Registers a named state with optional enter, exit, and update callbacks.
- `SimpleState:transitionTo`: Transitions to a named state, calling exit/enter callbacks as needed.
- `SimpleState:update`: Calls the update callback of the current state with the given delta time.
- `SimpleState:getCurrent`: Returns the name of the current state, or nil if none is active.
- `SimpleState:hasState`: Returns true if a state with the given name is registered.
- `SimpleState:getStates`: Returns a table of all registered state names.
- `SimpleState:clearAll`: Removes all states and callbacks from this state machine.

### `Throttle` Methods
- `Throttle:onFire`: Sets the callback invoked when the throttle fires.
- `Throttle:update`: Advances the timer by dt seconds; fires the callback if the interval elapsed.
- `Throttle:reset`: Resets the elapsed counter without firing.
- `Throttle:getProgress`: Returns the normalised progress through the current interval [0, 1].
- `Throttle:getFireCount`: Returns the total number of times this throttle has fired.
- `Throttle:setEnabled`: Enables or disables the throttle.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- Keep this module reference synchronized with `src/patterns/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
