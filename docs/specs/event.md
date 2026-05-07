# event

## General Info

- Module group: `Core Runtime`
- Source path: `src/event/`
- Lua API path(s): `src/lua_api/event_api.rs`
- Primary Lua namespace: `lurek.event`
- Rust test path(s): `tests/rust/unit/event_tests.rs`
- Lua test path(s): tests/lua/unit/test_event.lua, tests/lua/integration/test_audio_event.lua

## Summary

The `event` module is Lurek2D's centralized queue and signal dispatch layer. It owns queue storage, queue ordering semantics, queue wait behavior, and the `Signal` pub-sub primitive used by Lua scripts through `lurek.event`.

Event queue behavior:
- `EventQueue` is a dual-lane FIFO (`high` and `normal`) backed by `VecDeque`.
- `poll()` always drains `high` before `normal`, while keeping FIFO order inside each lane.
- `wait(timeout_ms)` blocks on a condvar wake path (no spin loop), returning an event immediately when available.
- `pump()` is intentionally a no-op in Lurek2D and exists for API parity.

Payload behavior:
- `Event` payload is `Vec<EventArg>`.
- `EventArg` supports scalar values plus shallow-cloned table payloads.
- Table payload conversion stores only scalar keys (`string`, `number`, `boolean`) and scalar values; nested tables are not deep-cloned.

Lua-facing API behavior:
- Queue APIs: `poll`, `wait`, `clear`, `push`, `pushPriority`, `pushDeferred`, `pushDeferredPriority`, `flushDeferred`.
- Runtime control APIs: `exit`, `quit`, `restart`.
- History APIs: `enableHistory`, `getHistory`, `clearHistory`.
- Signal factory: `newSignal()` returning `LSignal` with methods `register`, `emit`, `remove`, `clear`, `clearAll`, `getCount`, `getTotalCount`, `once`, `registerWithFilter`, `connect`, `type`, `typeOf`.

Scope boundary:
- Core Runtime tier module with thin Lua bridge in `src/lua_api/event_api.rs`.
- OS/window/input events are pushed from `app`; synthetic events are pushed by `automation`.
- Cross-thread messaging is out of scope for this module and belongs to `lurek.thread.Channel`.

## Files

- `event_queue.rs`: Event types and FIFO event queue.
- `mod.rs`: Event queue for polling system and custom events.
- `signal.rs`: Handle-based pub-sub signal system with exact-name and glob-wildcard subscriptions.

## Types

- `EventPriority` (`enum`, `event_queue.rs`): Queue lane used during enqueue (`High` or `Normal`).
- `EventTableKey` (`enum`, `event_queue.rs`): Allowed key types for table payload cloning.
- `EventArg` (`enum`, `event_queue.rs`): Argument values that can be attached to events.
- `Event` (`struct`, `event_queue.rs`): A single event in the event queue.
- `EventQueue` (`struct`, `event_queue.rs`): FIFO event queue for system and custom events.
- `Subscription` (`struct`, `signal.rs`): A single subscription entry in a [`Signal`].
- `Signal` (`struct`, `signal.rs`): Handle-based pub-sub signal dispatcher.

## Functions

- `EventQueue::new` (`event_queue.rs`): Create a new empty event queue.
- `EventQueue::push` (`event_queue.rs`): Push an event onto the queue.
- `EventQueue::push_with_priority` (`event_queue.rs`): Push an event with explicit lane selection.
- `EventQueue::push_event` (`event_queue.rs`): Push an event by name and arguments.
- `EventQueue::push_event_with_priority` (`event_queue.rs`): Push an event by name/args to an explicit lane.
- `EventQueue::poll` (`event_queue.rs`): Poll the next event from the queue.
- `EventQueue::clear` (`event_queue.rs`): Clear all events from the queue.
- `EventQueue::is_empty` (`event_queue.rs`): Check if the queue is empty.
- `EventQueue::len` (`event_queue.rs`): Get the number of events in the queue.
- `EventQueue::pump` (`event_queue.rs`): Drains pending OS-level events into the queue (no-op in Lurek2D; documents as a sync point).
- `EventQueue::wait` (`event_queue.rs`): Blocks until an event is available or `timeout_ms` milliseconds elapse.
- `EventArg::from_lua_val` (`event_queue.rs`): Converts a [`LuaValue`] to an [`EventArg`] for event queue storage.
- `event_arg_to_lua_value` (`event_queue.rs`): Converts an `EventArg` back to a Lua value.
- `event_to_lua_multi` (`event_queue.rs`): Converts an [`Event`] into a Lua multi-value (name followed by args).
- `Signal::new` (`signal.rs`): Creates a new empty signal dispatcher.
- `Signal::subscribe` (`signal.rs`): Registers a subscription for the given event name.
- `Signal::remove` (`signal.rs`): Removes a subscription by its handle ID.
- `Signal::clear` (`signal.rs`): Removes all subscriptions for the given event name.
- `Signal::clear_all` (`signal.rs`): Removes all subscriptions across all event names.
- `Signal::get_handles` (`signal.rs`): Returns the handles registered for the given event name (in registration order).
- `Signal::get_count` (`signal.rs`): Returns the number of subscriptions for the given event name.
- `Signal::get_total_count` (`signal.rs`): Returns the total number of subscriptions across all event names.
- `Signal::subscribe_wildcard` (`signal.rs`): Registers a wildcard pattern subscription.
- `Signal::get_wildcard_handles` (`signal.rs`): Returns all wildcard handles whose pattern matches the given event name.
- `Signal::is_wildcard` (`signal.rs`): Returns `true` if `pattern` contains glob metacharacters (`*` or `?`).

## Lua API Reference

- Binding path(s): `src/lua_api/event_api.rs`
- Namespace: `lurek.event`

### Module Functions
- `lurek.event.exit`: Pushes an exit event onto the engine event queue, requesting a graceful shutdown at the end of the current frame.
- `lurek.event.poll`: Returns an iterator function that pops events one at a time from the engine event queue.
- `lurek.event.clear`: Discards every pending event in the engine event queue without processing them.
- `lurek.event.newSignal`: Creates and returns a new independent Signal pub-sub dispatcher.
- `lurek.event.pump`: Synchronises OS-level windowing events into the engine event queue.
- `lurek.event.wait`: Blocks the current thread until the next engine event arrives or the optional timeout elapses.
- `lurek.event.restart`: Requests that the engine perform a full restart at the beginning of the next frame.
- `lurek.event.quit`: Alias for `exit()` - requests the engine to stop gracefully at the end of the current frame with exit code 0.
- `lurek.event.pushDeferred`: Pushes a named event into the deferred buffer instead of the main queue.
- `lurek.event.pushDeferredPriority`: Pushes a named deferred event with explicit queue lane priority.
- `lurek.event.flushDeferred`: Moves all events from the deferred buffer into the main engine event queue and clears the buffer.
- `lurek.event.enableHistory`: Enables event history recording, keeping a ring buffer of the last `capacity` events pushed via `push()`.
- `lurek.event.getHistory`: Returns an array of recently pushed events as tables.
- `lurek.event.clearHistory`: Clears all recorded event history entries from the ring buffer.
- `lurek.event.push`: Pushes a custom named event onto the main engine event queue with optional payload arguments.
- `lurek.event.pushPriority`: Pushes a custom named event onto an explicit queue lane (`high` or `normal`).

### `LSignal` Methods
- `LSignal:register`: Registers a Lua callback function for the named event and returns a numeric handle ID.
- `LSignal:emit`: Fires all callbacks registered for the named event, passing any extra arguments to each callback function.
- `LSignal:remove`: Removes a previously registered subscription identified by its numeric handle.
- `LSignal:clear`: Removes every callback registered for the specified event name and releases their Lua registry entries.
- `LSignal:clearAll`: Removes every callback across all event names in this Signal instance, effectively resetting it to an empty state.
- `LSignal:getCount`: Returns the number of callbacks currently registered for the specified event name.
- `LSignal:getTotalCount`: Returns the total number of callbacks registered across all event names in this Signal instance.
- `LSignal:once`: Registers a one-shot callback that fires at most once for the named event and then automatically removes itself.
- `LSignal:registerWithFilter`: Registers a callback with an associated filter predicate function.
- `LSignal:connect`: Subscribes to an event name or wildcard glob pattern and returns a handle.
- `LSignal:type`: Returns the string type name of this userdata object.
- `LSignal:typeOf`: Returns true if the given type name matches this object's type or any parent type.

## References

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/event/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
- **Wildcard semantics**: `*` matches any sequence of characters (excluding `/`); `?` matches exactly one character. Wildcard patterns are stored separately in `wildcard_subs: Vec<(String, u64)>` and evaluated via `glob_match` on every `emit` call after the exact-name callbacks have fired.
