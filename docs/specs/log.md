# log

## TL;DR

- The `log` module is a vital Foundations tier component that implements a highly efficient, structured logging facade for Lurek2D.

## General Info

- Module group: `Foundations`
- Source path: `src/log/`
- Lua API path(s): `src/lua_api/log_api.rs`
- Primary Lua namespace: `lurek.log`
- Rust test path(s): tests/rust/unit/log_tests.rs
- Lua test path(s): tests/lua/unit/test_log_core_unit.lua

## Summary

It provides a unified system for capturing, filtering, and dispatching diagnostic messages across the entire engine and Lua scripting environment. At its core, the module utilizes a level-gated emission system. The global log level acts as an initial filter, ensuring that messages below the active threshold incur near-zero performance cost—they are suppressed before any formatting or string allocation occurs. This allows developers to instrument code heavily with debug and trace messages without impacting production performance.

When a message passes the global filter, it is dispatched via the `SinkRegistry` to one or more registered `Sink` destinations. The module supports several powerful sink types. The `MemoryEntry` sink utilizes a bounded, in-memory ring buffer, perfectly suited for powering in-game developer consoles or debug overlays where recent logs must be rapidly accessible. The `RotatingFileSink` writes output to disk, automatically managing file sizes and backups to prevent unbounded storage consumption, while buffering writes to minimize OS syscall overhead. Furthermore, a callback sink allows log messages to be routed back into the Lua runtime for custom handling.

Logging is highly structured, allowing messages to carry not only severity levels and optional tags, but also complex key-value `LogFields`. This structured approach enables sophisticated log analysis and filtering downstream. Each individual sink maintains its own `SinkLevel` threshold and tag-based allow-list, meaning a single game instance can simultaneously write all `Trace` messages to a rotating file while only displaying `Warning` and `Error` messages in the on-screen console. The entire logging pipeline is fully configurable dynamically at runtime and exposed to scripts via the `lurek.log.*` namespace.

## Files

### facade.rs

- Structured log dispatch with level, tag, and key-value fields.
- Runtime log-level query and mutation via string names.
- Level-filter check without emitting a message.

### mod.rs

- Structured logging facade with global level control and dispatch to registered sinks.
- Rotating file sink and in-memory ring buffer for runtime log capture.
- Level-gated emission so disabled messages cost near-zero.

### sinks.rs

- Log severity levels and string parsing for sink-level filtering.
- In-memory ring-buffer sink for captured log entries with structured fields.
- Output format selection: plain text, JSON, and NDJSON line formats.
- Timestamp and ANSI color formatting helpers for human-readable output.
- Rotating file sink with configurable size limit and backup management.
- Buffered write coalescing to reduce OS syscall frequency.
- Tag-based allow-list filtering per sink instance.
- Callback sink variant for Lua-side log dispatch.
- Unified `Sink` abstraction combining level, format, and storage backend.
- `SinkRegistry` for multi-sink dispatch of unstructured and structured messages.

## Lua API Ref

- Binding: `src/lua_api/log_api.rs`
- Namespace: `lurek.log`

### Functions

- `lurek.log.addSink`: Adds a memory, file, rotating, or callback sink from a config table.
- `lurek.log.clearSinks`: Removes all sinks and releases callback registry keys.
- `lurek.log.debug`: Logs a debug message with an optional tag.
- `lurek.log.debug_fields`: Logs a debug message with structured fields.
- `lurek.log.error`: Logs an error message with an optional tag.
- `lurek.log.error_fields`: Logs an error message with structured fields.
- `lurek.log.flushFile`: Flushes a file-backed sink by id when it exists.
- `lurek.log.getLevel`: Returns the global log level string.
- `lurek.log.info`: Logs an info message with an optional tag.
- `lurek.log.info_fields`: Logs an info message with structured fields.
- `lurek.log.listSinks`: Returns metadata for all registered sinks.
- `lurek.log.print`: Logs a message at a runtime-selected level with an optional tag.
- `lurek.log.readMemory`: Reads entries from a memory sink and optionally drains them.
- `lurek.log.removeSink`: Removes a sink by id and releases any callback registry key.
- `lurek.log.setLevel`: Sets the global log level. This function is exposed to Lua scripts.
- `lurek.log.struct`: Logs a structured message at a runtime-selected level.
- `lurek.log.warn`: Logs a warning message with an optional tag.
- `lurek.log.warn_fields`: Logs a warning message with structured fields.

### Enums

- No documented module-level enums/constants.

### Types

- No documented module types.

## References

- `binary`: Imports or references `src/binary/`. Cross-group dependency from `Foundations` into `Edge/Integration`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.
