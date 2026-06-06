# log

## General Info

- Module group: `Foundations`
- Source path: `src/log/`
- Binding: `src/lua_api/log_api.rs`
- Namespace: `lurek.log`
- Lua API surface: `18` functions, `2` types, `0` methods
- Rust test path(s): tests/rust/unit/log_tests.rs
- Lua test path(s): tests/lua/unit/test_log_core_unit.lua

## Summary

This module provides structured logging, letting developers filter and route runtime messages. It hosts a logging facade that dispatches level-tagged entries and key-value fields. Enforcing severity gates early minimizes performance overhead, keeping diagnostics highly efficient.

To direct outputs, the system manages a sink registry. Logs can target console streams, memory buffers, or rotating files in plain text, JSON, or NDJSON formats, serving both human inspectors and automated analysis tools.

## Files

### [facade.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/log/facade.rs)

- Provides the structured logging facade used to emit level-tagged messages with fields.
- Handles runtime level queries and updates while enforcing fast level gating before dispatch.
- Exposes compact log-entry helpers consumed by Lua and Rust call sites.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/log/mod.rs)

- High-level logging module that combines facade APIs with sink implementations.
- Re-exports level control and sink types for centralized runtime log configuration.
- Defines the boundary for structured log routing to memory and file backends.

### [sinks.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/log/sinks.rs)

- Implements logging sink backends, severity filters, and output formatting infrastructure.
- Defines sink-level enums and parsing rules used to gate message delivery.
- Provides in-memory capture sinks for runtime inspection and diagnostic tooling.
- Supports plain, JSON, and NDJSON output styles for machine and human consumers.
- Manages timestamp and optional color formatting for readable terminal and file logs.
- Implements rotating file sinks with size limits and backup retention control.
- Uses buffered writes and filtering hooks to keep output efficient and configurable.
- Offers callback-style sink integration for forwarding logs to external handlers.
- Unifies sink behavior under shared abstractions for consistent dispatch semantics.
- Exposes registry orchestration for broadcasting structured and plain messages to many sinks.
