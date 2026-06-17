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

- The event module provides a central messaging layer so systems can communicate without tight coupling.
- Priority-aware queueing lets critical events run ahead of routine traffic when timing matters.
- Deferred push paths help schedule cross-frame dispatch cleanly.
- Signal subscriptions support exact names and wildcard patterns for flexible event routing.
- Listener lifecycle controls keep registration and cleanup explicit.
- Optional history retention helps trace event flow during debugging.
- Rust-Lua marshalling keeps payload transfer practical across the boundary.
- The module delivers deterministic, inspectable runtime event orchestration.

This module primarily collaborates with `runtime`. Its responsibility should stay inside the Core Runtime group rather than absorb behavior owned by those neighbors.

## Imports

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### event_queue.rs

- Provides a dual-priority FIFO event queue that dispatches high-priority items before normal traffic. `event/event_queue` delivers the event queue implementation for the event subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Defines portable event payload shapes that carry scalar and shallow table data across boundaries. The file owns or coordinates data contracts including `EventPriority`, `EventTableKey`, `EventArg`, `Event`, `EventQueue`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Supports blocking wait semantics with timeout control for synchronized producer-consumer patterns. Public callable behavior is centered on `event_arg_to_lua_value`, `event_to_lua_multi`, while method-level behavior such as `new`, `push`, `push_with_priority`, `push_event`, `push_event_with_priority`, `poll`, and 6 more stays attached to the local data model and invariants.
- Converts queued payloads between Rust and Lua value domains using predictable marshalling rules. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Preserves insertion order inside each priority lane to keep event flow behavior deterministic. External integration uses `std`, `mlua`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### mod.rs

- Provides the high-level event module boundary for queued dispatch and signal-based subscription routing. `event/mod` is the event module index, declaring `event_queue`, `signal` so agents can identify which files own each feature slice before opening implementation code.
- Connects payload conversion, priority handling, and listener registration into one communication layer. `src/event/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `event_queue::{ event_arg_to_lua_value, event_to_lua_multi, Event, EventArg, EventPriority, EventQueue, EventTableKey, }`, `signal::Signal` centralized for the event subsystem.

### signal.rs

- Provides named signal subscription storage with support for exact and wildcard pattern matching. `event/signal` delivers the signal implementation for the event subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Allocates stable handle ids so listeners can be removed or inspected through explicit lifecycle control. The file owns or coordinates data contracts including `Subscription`, `Signal`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Resolves matching subscribers with deterministic behavior for both direct names and glob-style patterns. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `subscribe`, `remove`, `clear`, `clear_all`, `get_handles`, and 5 more stays attached to the local data model and invariants.
- Exposes snapshot-friendly query helpers that aid runtime diagnostics and tooling inspection. Runtime integration reaches sibling engine areas through crate modules `log_msg`, `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.



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
