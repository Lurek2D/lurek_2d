# event

## General Info

- Module group: `Core Runtime`
- Source path: `src/event/`
- Binding: `src/lua_api/event_api.rs`
- Namespace: `lurek.event`
- Lua API surface: `16` functions, `2` types, `12` methods
- Rust test path(s): tests/rust/unit/event_tests.rs
- Lua test path(s): tests/lua/unit/test_event.lua, tests/lua/integration/test_audio_event.lua

## Summary

This module serves as the runtime messaging hub, decoupling subsystems through asynchronous signaling. It implements a dual-priority queue ensuring critical tasks process ahead of standard events. The system handles data marshalling between Rust and Lua, supporting both immediate pushes and deferred buffering to coordinate events across frames.

Additionally, the system manages a signal registry supporting exact and wildcard subscriber patterns. Listeners connect to named signals with lifecycle controls. To aid diagnostics, the module retains a configurable history of pushed events, allowing developers to inspect past messages to trace game flows and simplify debugging.

## Files

### [event_queue.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/event/event_queue.rs)

- Provides a dual-priority FIFO event queue that dispatches high-priority items before normal traffic.
- Defines portable event payload shapes that carry scalar and shallow table data across boundaries.
- Supports blocking wait semantics with timeout control for synchronized producer-consumer patterns.
- Converts queued payloads between Rust and Lua value domains using predictable marshalling rules.
- Preserves insertion order inside each priority lane to keep event flow behavior deterministic.
- Encapsulates push, poll, peek, and wait operations in one reusable runtime messaging primitive.
- Delivers the queue core used by event-driven systems that need ordered asynchronous signaling.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/event/mod.rs)

- Provides the high-level event module boundary for queued dispatch and signal-based subscription routing.
- Connects payload conversion, priority handling, and listener registration into one communication layer.
- Delivers a stable event-facing surface for systems that need decoupled runtime messaging.

### [signal.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/event/signal.rs)

- Provides named signal subscription storage with support for exact and wildcard pattern matching.
- Allocates stable handle ids so listeners can be removed or inspected through explicit lifecycle control.
- Resolves matching subscribers with deterministic behavior for both direct names and glob-style patterns.
- Exposes snapshot-friendly query helpers that aid runtime diagnostics and tooling inspection.
- Delivers the subscription registry used by event publishers to find active listeners efficiently.
