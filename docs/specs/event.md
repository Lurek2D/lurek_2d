# event

## General Info

- Module group: `Core Runtime`
- Source path: `src/event/`
- Lua API path(s): `src/lua_api/event_api.rs`
- Primary Lua namespace: `lurek.event`
- Rust test path(s): tests/rust/unit/event_tests.rs, plus inline unit coverage in src/event/event_queue.rs and src/event/signal.rs
- Lua test path(s): tests/lua/unit/test_event.lua, tests/lua/integration/test_audio_event.lua

## Summary

The event module gives Lurek2D two lightweight messaging primitives: a FIFO event queue for polling named events and a handle-based signal dispatcher for callback-style fan-out. It exists so gameplay code can communicate across systems without introducing direct ownership or import dependencies between those systems.

The queue side is about ordered delivery and explicit consumption. Engine or gameplay code can push named events with primitive payload values, and scripts can poll or wait for them later. The signal side is about local pub-sub: listeners subscribe by name, get handles back, and can be removed or cleared without needing a full feature-rich event bus.

This module intentionally does not own OS input capture, scene transitions, or higher-order event orchestration policies. Hardware events originate in `input` and the app loop, richer callback patterns live under `patterns`, and Lua registry management for callbacks belongs in `src/lua_api/event_api.rs` rather than in the core `event` data structures.

**Scope boundary**: This module currently depends on `runtime`. It stays within the Core Runtime responsibility boundary defined in the architecture docs.

## Files

- `event_queue.rs`: Event types and FIFO event queue.
- `mod.rs`: Event queue for polling system and custom events.
- `signal.rs`: Handle-based pub-sub signal system.

## Types

- `EventArg` (`enum`, `event_queue.rs`): Argument values that can be attached to events.
- `Event` (`struct`, `event_queue.rs`): A single event in the event queue.
- `EventQueue` (`struct`, `event_queue.rs`): FIFO event queue for system and custom events.
- `Subscription` (`struct`, `signal.rs`): A single subscription entry in a [`Signal`].
- `Signal` (`struct`, `signal.rs`): Handle-based pub-sub signal dispatcher.

## Functions

- `EventQueue::new` (`event_queue.rs`): Create a new empty event queue.
- `EventQueue::push` (`event_queue.rs`): Push an event onto the queue.
- `EventQueue::push_event` (`event_queue.rs`): Push an event by name and arguments.
- `EventQueue::poll` (`event_queue.rs`): Poll the next event from the queue.
- `EventQueue::clear` (`event_queue.rs`): Clear all events from the queue.
- `EventQueue::is_empty` (`event_queue.rs`): Check if the queue is empty.
- `EventQueue::len` (`event_queue.rs`): Get the number of events in the queue.
- `EventQueue::pump` (`event_queue.rs`): Drains pending OS-level events into the queue (no-op in Lurek2D; documents as a sync point).
- `EventQueue::wait` (`event_queue.rs`): Blocks until an event is available or `timeout_ms` milliseconds elapse.
- `EventArg::from_lua_val` (`event_queue.rs`): Converts a [`LuaValue`] to an [`EventArg`] for event queue storage.
- `event_to_lua_multi` (`event_queue.rs`): Converts an [`Event`] into a Lua multi-value (name followed by args).
- `Signal::new` (`signal.rs`): Creates a new empty signal dispatcher.
- `Signal::subscribe` (`signal.rs`): Registers a subscription for the given event name.
- `Signal::remove` (`signal.rs`): Removes a subscription by its handle ID.
- `Signal::clear` (`signal.rs`): Removes all subscriptions for the given event name.
- `Signal::clear_all` (`signal.rs`): Removes all subscriptions across all event names.
- `Signal::get_handles` (`signal.rs`): Returns the handles registered for the given event name (in registration order).
- `Signal::get_count` (`signal.rs`): Returns the number of subscriptions for the given event name.
- `Signal::get_total_count` (`signal.rs`): Returns the total number of subscriptions across all event names.

## Lua API Reference

- Binding path(s): `src/lua_api/event_api.rs`
- Namespace: `lurek.event`

### Module Functions
- `lurek.event.exit`: Pushes an exit event, requesting the engine to stop.
- `lurek.event.push`: Pushes a custom event onto the event queue.
- `lurek.event.poll`: Returns an iterator function that pops events from the queue.
- `lurek.event.clear`: Discards all pending events in the queue.
- `lurek.event.newSignal`: Creates a new pub-sub Signal dispatcher.
- `lurek.event.pump`: Syncs OS-level events into the queue (no-op in Lurek2D push model).
- `lurek.event.wait`: Blocks until the next event arrives or the optional timeout elapses.
- `lurek.event.restart`: Requests that the engine restart at the beginning of the next frame.
- `lurek.event.quit`: Alias for `exit()` — requests the engine to stop at the end of the current frame.

### `Signal` Methods
- `Signal:emit`: Emits the named event, calling all registered callbacks with extra arguments.
- `Signal:remove`: Removes a subscription by handle ID.
- `Signal:clear`: Removes all callbacks for the named event.
- `Signal:clearAll`: Removes all callbacks across all events.
- `Signal:getCount`: Returns the callback count for the named event.
- `Signal:getTotalCount`: Returns the total callback count across all events.
- `Signal:type`: Returns the type name of this object.
- `Signal:typeOf`: Returns true if the given type name matches this object's type or any parent type.

## References

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/event/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
