# event

## TL;DR

- Runs a dual-priority event queue and wildcard signal registry.

## General Info

- Module group: `Core Runtime`
- Source path: `src/event/`
- Binding: `src/lua_api/event_api.rs`
- Namespace: `lurek.event`
- Lua API surface: `16` functions, `2` types, `12` methods
- Rust test path(s): tests/rust/unit/event_tests.rs
- Lua test path(s): tests/lua/unit/test_event.lua, tests/lua/integration/test_audio_event.lua

## Summary

- The `event` module is the central message-routing layer for users who want runtime systems to communicate without hardwiring direct dependencies.
- Queues, priorities, listeners, signals, and deferred dispatch work together so gameplay, input, and tooling events can move through one predictable channel.
- Wildcard-style subscriptions and explicit listener lifecycle management make the bus practical for both large subsystems and small script integrations.
- History and Rust-Lua payload transfer matter because the module is not only about dispatch, but also about making that dispatch inspectable and usable across the engine boundary.
- Read it as the shared traffic system for runtime messages.

This module primarily collaborates with `runtime`. Its responsibility should stay inside the Core Runtime group rather than absorb behavior owned by those neighbors.

## Imports

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### event_queue.rs

- `src/event/event_queue.rs` owns queued runtime events, their portable payload shapes, and Rust-Lua marshalling helpers.
- It defines `EventPriority`, `EventTableKey`, `EventArg`, `Event`, and `EventQueue` under one event-delivery owner.
- High and normal priority lanes live here, preserving FIFO order within each lane while dispatch prefers urgent traffic.
- The queue also exposes blocking wait semantics with wake epochs and a condition variable for producer-consumer flows.
- Shallow Lua table copying and conversion back to Lua values are implemented here so payload rules stay local.
- Read this file when queue ordering, timeout behavior, marshalling limits, or payload shape rules need to change.
- Higher layers should treat it as the queued-event boundary, while signal name matching lives separately in `signal.rs`.

### mod.rs

- `src/event/mod.rs` is the module index that exposes queued events, Lua payload conversion, and signal subscriptions.
- It reexports `EventQueue`, payload types, conversion helpers, and `Signal` through one stable event surface.
- No queued event or subscription state lives here; this file only declares child modules and chooses public symbols.
- Read this index when wiring runtime messaging, because it shows where queued dispatch ends and signal storage begins.
- Changes here reshape the event boundary, since reexports decide what engine code may import without deep module paths.
- This module keeps queue mechanics and signal matching separated, which makes event ownership easier to follow.

### signal.rs

- `src/event/signal.rs` owns named and wildcard signal subscriptions, along with stable handles for listener lifecycle.
- It defines `Subscription` and `Signal`, keeping registration maps, reverse lookups, and wildcard state under one owner.
- Subscribe, remove, clear, count, and wildcard matching live here so signal routing stays explicit and inspectable.
- The local glob matcher implements `*` and `?` handling, which keeps wildcard semantics independent from external crates.
- Read this file when subscription storage, wildcard rules, or runtime diagnostics for signal listeners need to change.



## Lua API Ref

### Functions

- `lurek.event.clear() -> nil`: Clears all pending events from the shared event queue.
- `lurek.event.clearHistory() -> nil`: Clears retained pushed event history.
- `lurek.event.enableHistory(capacity) -> nil`: Enables event push history with a maximum retained capacity.
- `lurek.event.exit(code?) -> nil`: Requests engine shutdown with an optional process exit code.
- `lurek.event.flushDeferred() -> integer`: Moves all deferred events into the shared event queue and clears the deferred buffer.
- `lurek.event.getHistory() -> table`: Returns retained pushed event history entries.
- `lurek.event.newSignal() -> LSignal`: Creates an isolated signal dispatcher for Lua callbacks.
- `lurek.event.poll() -> function`: Creates a polling function that returns the next queued event each time it is called.
- `lurek.event.pump() -> nil`: Pumps the shared event queue without removing events for Lua.
- `lurek.event.push(name, ...) -> nil`: Pushes a normal-priority event into the shared event queue and optional history.
- `lurek.event.pushDeferred(name, ...) -> nil`: Adds a normal-priority event to the deferred buffer instead of the live queue.
- `lurek.event.pushDeferredPriority(name, priority, ...) -> nil`: Adds an event with explicit priority to the deferred buffer.
- `lurek.event.pushPriority(name, priority, ...) -> nil`: Pushes an event with explicit priority into the shared event queue and optional history.
- `lurek.event.quit() -> nil`: Deprecated alias for `lurek.event.exit(0)`; requests engine shutdown with exit code zero.
- `lurek.event.restart() -> nil`: Requests a full engine restart cycle from the runtime.
- `lurek.event.wait(timeout?) -> boolean`: Waits for the next queued event and returns success, name, and argument table.

### Callbacks

- `LSignal:connect` param `func` (`function`): Lua function invoked with emitted signal arguments.
- `LSignal:once` param `callback` (`function`): Lua function invoked once with emitted signal arguments.
- `LSignal:register` param `callback` (`function`): Lua function invoked with emitted signal arguments.
- `LSignal:registerWithFilter` param `callback` (`function`): Lua function invoked after the filter accepts the signal.
- `LSignal:registerWithFilter` param `filter` (`function`): Lua predicate called with emitted arguments.

### Enums

- No documented module-level enums/constants.

### Types

#### LEventGetHistoryResult Type

- Generated result shape from @field tags.

##### Fields

- `args` (`table`): Event arguments array.
- `name` (`string`): Event name.

##### Methods

- No documented methods.

#### LSignal Type

- Lua-side signal object storing subscriptions and Lua callback registry keys.

##### Fields

- No documented fields.

##### Methods

- `LSignal:clear(name) -> integer`: Removes all callbacks registered for one exact signal event name.
- `LSignal:clearAll() -> integer`: Removes every callback from this signal object.
- `LSignal:connect(name, func) -> integer`: Registers a callback for an exact name or wildcard signal pattern.
- `LSignal:emit(name, ...) -> nil`: Emits a signal event and invokes matching callbacks with the remaining arguments.
- `LSignal:getCount(name) -> integer`: Returns the callback count for one exact signal event name.
- `LSignal:getTotalCount() -> integer`: Returns the total callback count across all signal event names.
- `LSignal:once(name, callback) -> integer`: Registers a callback that is removed after its next matching emission.
- `LSignal:register(name, callback) -> integer`: Registers a callback for an exact signal event name.
- `LSignal:registerWithFilter(name, callback, filter) -> integer`: Registers a callback that runs only when a filter callback returns true.
- `LSignal:remove(handle) -> boolean`: Removes a signal callback by subscription handle.
- `LSignal:type() -> string`: Returns the Lua-visible type name for this signal handle.
- `LSignal:typeOf(name) -> boolean`: Returns whether this signal handle matches a supported type name.

## References

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- No additional module-specific notes.
