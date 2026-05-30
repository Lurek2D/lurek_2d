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

It provides a unified system for capturing, filtering, and dispatching diagnostic messages across the entire engine and Lua scripting environment. At its core, the module utilizes a level-gated emission system. The global log level acts as an initial filter, ensuring that messages below the active threshold incur near-zero performance cost—they are suppressed before any formatting or string allocation occurs. This allows developers to instrument code heavily with debug and trace messages without impacting production performance.

When a message passes the global filter, it is dispatched via the `SinkRegistry` to one or more registered `Sink` destinations. The module supports several powerful sink types. The `MemoryEntry` sink utilizes a bounded, in-memory ring buffer, perfectly suited for powering in-game developer consoles or debug overlays where recent logs must be rapidly accessible. The `RotatingFileSink` writes output to disk, automatically managing file sizes and backups to prevent unbounded storage consumption, while buffering writes to minimize OS syscall overhead. Furthermore, a callback sink allows log messages to be routed back into the Lua runtime for custom handling.

Logging is highly structured, allowing messages to carry not only severity levels and optional tags, but also complex key-value `LogFields`. This structured approach enables sophisticated log analysis and filtering downstream. Each individual sink maintains its own `SinkLevel` threshold and tag-based allow-list, meaning a single game instance can simultaneously write all `Trace` messages to a rotating file while only displaying `Warning` and `Error` messages in the on-screen console. The entire logging pipeline is fully configurable dynamically at runtime and exposed to scripts via the `lurek.log.*` namespace.

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
