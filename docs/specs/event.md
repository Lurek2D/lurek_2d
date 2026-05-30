# event

## TL;DR

- The `event` module resides in the Core Runtime tier and provides the centralized event queue and signal dispatch backbone necessary for decoupled inter-system communication.

## General Info

- Module group: `Core Runtime`
- Source path: `src/event/`
- Binding: `src/lua_api/event_api.rs`
- Namespace: `lurek.event`
- Lua API surface: `16` functions, `2` types, `12` methods
- Rust test path(s): tests/rust/unit/event_tests.rs
- Lua test path(s): tests/lua/unit/test_event.lua, tests/lua/integration/test_audio_event.lua

## Summary

The `event` module provides priority-aware runtime event queuing and signal subscription primitives. Its core role is decoupled communication: producers push typed payloads, consumers poll or subscribe by name/wildcard, and delivery semantics preserve ordering guarantees within priority lanes.

`event_queue` owns queue storage, event structures, priority behavior, and Lua payload conversion helpers. `signal` owns subscriber registration and matching semantics. The module then re-exports these types so runtime and scripting layers can integrate without binding to submodule internals.

Design emphasis is predictable dispatch behavior and safe payload bridging to Lua. Conversion helpers ensure event arguments can cross the Rust-Lua boundary without ad-hoc per-system glue.

As a core runtime messaging surface, this module should remain deterministic, minimal, and explicit about queue/priority semantics. Domain-specific event meanings belong to caller modules, not to the queue itself.

Implementation detail and boundary guarantees for event: this module keeps responsibilities explicit across source files so behavior remains inspectable during refactors. The current source map is: event_queue.rs: Dual-priority FIFO event queue (high and normal) with priority-based polling.; mod.rs: Priority queue with ordered dispatch and Lua payload conversion for runtime events.; signal.rs: Named signal subscription registry with exact-name and wildcard pattern matching.. This split is part of the contract: orchestration stays in composition points, data models stay in type-centric files, and adapters stay in bridge files. That separation reduces hidden coupling, improves testability, and keeps Lua API surfaces aligned with Rust runtime semantics. For maintainers, the key guarantee is that high-level APIs should keep delegating into scoped internals instead of collapsing into a single large entry point. Future extensions should preserve explicit dependency direction and documented invariants near owning types and functions.

## Imports

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### event_queue.rs

- Provides a dual-priority FIFO event queue that dispatches high-priority items before normal traffic.
- Defines portable event payload shapes that carry scalar and shallow table data across boundaries.
- Supports blocking wait semantics with timeout control for synchronized producer-consumer patterns.
- Converts queued payloads between Rust and Lua value domains using predictable marshalling rules.
- Preserves insertion order inside each priority lane to keep event flow behavior deterministic.
- Encapsulates push, poll, peek, and wait operations in one reusable runtime messaging primitive.
- Delivers the queue core used by event-driven systems that need ordered asynchronous signaling.

### mod.rs

- Provides the high-level event module boundary for queued dispatch and signal-based subscription routing.
- Connects payload conversion, priority handling, and listener registration into one communication layer.
- Delivers a stable event-facing surface for systems that need decoupled runtime messaging.

### signal.rs

- Provides named signal subscription storage with support for exact and wildcard pattern matching.
- Allocates stable handle ids so listeners can be removed or inspected through explicit lifecycle control.
- Resolves matching subscribers with deterministic behavior for both direct names and glob-style patterns.
- Exposes snapshot-friendly query helpers that aid runtime diagnostics and tooling inspection.
- Delivers the subscription registry used by event publishers to find active listeners efficiently.

## Lua API Ref

### Functions

- `lurek.event.clear`: Clears all pending events from the shared event queue.
- `lurek.event.clearHistory`: Clears retained pushed event history.
- `lurek.event.enableHistory`: Enables event push history with a maximum retained capacity.
- `lurek.event.exit`: Requests engine shutdown with an optional process exit code.
- `lurek.event.flushDeferred`: Moves all deferred events into the shared event queue and clears the deferred buffer.
- `lurek.event.getHistory`: Returns retained pushed event history entries.
- `lurek.event.newSignal`: Creates an isolated signal dispatcher for Lua callbacks.
- `lurek.event.poll`: Creates a polling function that returns the next queued event each time it is called.
- `lurek.event.pump`: Pumps the shared event queue without removing events for Lua.
- `lurek.event.push`: Pushes a normal-priority event into the shared event queue and optional history.
- `lurek.event.pushDeferred`: Adds a normal-priority event to the deferred buffer instead of the live queue.
- `lurek.event.pushDeferredPriority`: Adds an event with explicit priority to the deferred buffer.
- `lurek.event.pushPriority`: Pushes an event with explicit priority into the shared event queue and optional history.
- `lurek.event.quit`: Deprecated alias for `lurek.event.exit(0)`; requests engine shutdown with exit code zero.
- `lurek.event.restart`: Requests a full engine restart cycle from the runtime.
- `lurek.event.wait`: Waits for the next queued event and returns success, name, and argument table.

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

- `LSignal:clear`: Removes all callbacks registered for one exact signal event name.
- `LSignal:clearAll`: Removes every callback from this signal object.
- `LSignal:connect`: Registers a callback for an exact name or wildcard signal pattern.
- `LSignal:emit`: Emits a signal event and invokes matching callbacks with the remaining arguments.
- `LSignal:getCount`: Returns the callback count for one exact signal event name.
- `LSignal:getTotalCount`: Returns the total callback count across all signal event names.
- `LSignal:once`: Registers a callback that is removed after its next matching emission.
- `LSignal:register`: Registers a callback for an exact signal event name.
- `LSignal:registerWithFilter`: Registers a callback that runs only when a filter callback returns true.
- `LSignal:remove`: Removes a signal callback by subscription handle.
- `LSignal:type`: Returns the Lua-visible type name for this signal handle.
- `LSignal:typeOf`: Returns whether this signal handle matches a supported type name.
