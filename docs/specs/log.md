# log

## General Info

- Module group: `Foundations`
- Source path: `src/log/`
- Lua API path(s): `src/lua_api/log_api.rs`
- Primary Lua namespace: `lurek.log`
- Rust test path(s): tests/rust/unit/log_tests.rs
- Lua test path(s): tests/lua/unit/test_log.lua

## Summary

The `log` module owns the engine-facing logging domain that Lua scripts and other code can target without talking directly to the global logging backend. It provides a thin, stable layer for log level control and for dispatching script-originated messages into additional sinks such as files and in-memory ring buffers.

This module exists to separate logging policy from Lua registration code. The domain types in `src/log/` define what a sink is, how entries are filtered, and how sink fan-out works, while `src/lua_api/log_api.rs` decides how that functionality is exposed under `lurek.log` for a single VM.

`log` intentionally does not own engine-wide logger initialization, formatting, `RUST_LOG` parsing, or the general diagnostic UI story. It delegates level storage to `runtime::log_messages`, and it does not replace `devtools` or `debugbridge`, which serve different debugging and capture workflows.

**Scope boundary**: This module currently depends on `runtime`. It stays within the Foundations responsibility boundary defined in the architecture docs.

## Files

- `mod.rs`: Defines the small public domain surface for setting and querying the active log level and re-exports sink-related types.
- `sinks.rs`: Implements sink filtering and fan-out, including file-backed sinks, bounded memory sinks, and the registry that tracks active outputs.

## Types

- `SinkLevel` (`enum`, `sinks.rs`): Severity threshold used by sink filtering. It keeps file and memory sinks consistent even when the Lua caller uses string level names.
- `MemoryEntry` (`struct`, `sinks.rs`): Captured log record stored by memory sinks. It is intentionally small so Lua tooling can inspect recent messages without coupling to the Rust `log` crate.
- `SinkKind` (`enum`, `sinks.rs`): Backend enum for the supported sink storage strategies. It distinguishes append-to-file behavior from bounded in-memory buffering.
- `Sink` (`struct`, `sinks.rs`): Single output destination with an id, minimum level, and concrete backend. It is the unit the Lua API creates, lists, flushes, and removes.
- `SinkRegistry` (`struct`, `sinks.rs`): Mutable collection of active sinks for one runtime context. The Lua layer keeps one registry per VM and uses it to fan out every emitted message.

## Functions

- `set_level` (`mod.rs`): Sets the active log level to the named value.
- `get_level` (`mod.rs`): Returns the current log level name as a static string (e.g.
- `enabled_for` (`mod.rs`): Returns `true` when messages at `level` would be emitted under the current filter.
- `SinkLevel::from_str` (`sinks.rs`): Parses a level string ("debug", "info", "warn", "error").
- `SinkLevel::as_str` (`sinks.rs`): Returns a short lowercase string representation.
- `Sink::file` (`sinks.rs`): Creates a file sink.
- `Sink::memory` (`sinks.rs`): Creates a memory sink.
- `Sink::write` (`sinks.rs`): Dispatches a log entry to this sink (no-op when below `min_level`).
- `Sink::type_name` (`sinks.rs`): Returns the sink type name string.
- `Sink::path` (`sinks.rs`): Returns the path for a file sink, or `None`.
- `Sink::read_memory` (`sinks.rs`): Reads all memory entries and optionally drains them.
- `Sink::flush` (`sinks.rs`): Flushes a file sink (no-op on memory sinks).
- `SinkRegistry::new` (`sinks.rs`): Creates an empty registry.
- `SinkRegistry::add` (`sinks.rs`): Adds a sink, returning its assigned id.
- `SinkRegistry::remove` (`sinks.rs`): Removes a sink by id.
- `SinkRegistry::clear` (`sinks.rs`): Removes all sinks.
- `SinkRegistry::dispatch` (`sinks.rs`): Dispatches a log entry to all registered sinks.
- `SinkRegistry::get` (`sinks.rs`): Returns a sink by id.

## Lua API Reference

- Binding path(s): `src/lua_api/log_api.rs`
- Namespace: `lurek.log`

### Module Functions
- `lurek.log.debug`: Emits a debug-severity log message. Also dispatches to configured sinks.
- `lurek.log.info`: Emits an info-severity log message. Also dispatches to configured sinks.
- `lurek.log.warn`: Emits a warn-severity log message. Also dispatches to configured sinks.
- `lurek.log.error`: Emits an error-severity log message. Also dispatches to configured sinks.
- `lurek.log.print`: Emits a log message at the specified level. Also dispatches to sinks.
- `lurek.log.setLevel`: Sets the minimum severity level for the default log channel.
- `lurek.log.getLevel`: Returns the name of the currently active minimum log level.
- `lurek.log.addSink`: Registers a new output sink. Returns its numeric id.
- `lurek.log.removeSink`: Removes a sink by id. Returns true if one was removed.
- `lurek.log.clearSinks`: Removes all registered sinks (the default stderr channel is unaffected).
- `lurek.log.listSinks`: Returns a table describing all registered sinks.
- `lurek.log.readMemory`: Reads entries from a memory sink. If drain=true the buffer is cleared.
- `lurek.log.flushFile`: Flushes the OS write buffer for a file sink.

## References

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/log/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
