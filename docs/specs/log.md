# log

## TL;DR

- Runs structured logs with level-filtered sinks.

## General Info

- Module group: `Foundations`
- Source path: `src/log/`
- Binding: `src/lua_api/log_api.rs`
- Namespace: `lurek.log`
- Lua API surface: `18` functions, `2` types, `0` methods
- Rust test path(s): tests/rust/unit/log_tests.rs
- Lua test path(s): tests/lua/unit/test_log_core_unit.lua

## Summary

- This module gives users structured runtime logging with severity control and flexible output routing.
- It supports tagged messages and key-value fields for machine-friendly and human-friendly diagnostics.
- Global level gates reduce noise and overhead by filtering early.
- Sink management supports console, memory, file, rotating-file, and callback outputs.
- Multiple output formats enable both readable logs and ingestion-ready streams.
- Memory sink access supports in-game debug panels and test assertions.
- File rotation controls support long sessions without unbounded log growth.
- For users, this module centralizes diagnostics flow instead of scattering print logic across scripts.

This module primarily collaborates with `binary`, `runtime`. Its responsibility should stay inside the Foundations group rather than absorb behavior owned by those neighbors.

## Imports

- `binary`: Imports or references `src/binary/`. Cross-group dependency from `Foundations` into `Edge/Integration`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### facade.rs

- Provides the structured logging facade used to emit level-tagged messages with fields. `log/facade` delivers the public facade over lower-level subsystem helpers for the log subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Handles runtime level queries and updates while enforcing fast level gating before dispatch. The file owns or coordinates data contracts including `LogFields`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Exposes compact log-entry helpers consumed by Lua and Rust call sites. Public callable behavior is centered on `log_structured`, `set_level`, `get_level`, while method-level behavior such as no named public items stays attached to the local data model and invariants.

### mod.rs

- High-level logging module that combines facade APIs with sink implementations. `log/mod` is the log module index, declaring `facade`, `sinks` so agents can identify which files own each feature slice before opening implementation code.
- Re-exports level control and sink types for centralized runtime log configuration. `src/log/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `facade::{get_level, log_structured, set_level, LogFields}`, `sinks::{MemoryEntry, RotatingFileSink, Sink, SinkLevel, SinkRegistry}` centralized for the log subsystem.

### sinks.rs

- Implements logging sink backends, severity filters, and output formatting infrastructure. `log/sinks` delivers the sinks implementation for the log subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Defines sink-level enums and parsing rules used to gate message delivery. The file owns or coordinates data contracts including `SinkLevel`, `MemoryEntry`, `RotatingFileSink`, `SinkKind`, `Sink`, and 1 more, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Provides in-memory capture sinks for runtime inspection and diagnostic tooling. Public callable behavior is centered on no named public items, while method-level behavior such as `severity_rank`, `as_str`, `open`, `write_with_rotation`, `flush`, `file`, and 17 more stays attached to the local data model and invariants.
- Supports plain, JSON, and NDJSON output styles for machine and human consumers. Runtime integration reaches sibling engine areas through crate modules `binary`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Manages timestamp and optional color formatting for readable terminal and file logs. External integration uses `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Implements rotating file sinks with size limits and backup retention control. The file boundary separates log implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.



## Lua API Ref

### Functions

- `lurek.log.addSink(config) -> integer`: Adds a memory, file, rotating, or callback sink from a config table.
- `lurek.log.clearSinks() -> nil`: Removes all sinks and releases callback registry keys.
- `lurek.log.debug(message, tag?) -> nil`: Logs a debug message with an optional tag.
- `lurek.log.debug_fields(message, fields_tbl) -> nil`: Logs a debug message with structured fields.
- `lurek.log.error(message, tag?) -> nil`: Logs an error message with an optional tag.
- `lurek.log.error_fields(message, fields_tbl) -> nil`: Logs an error message with structured fields.
- `lurek.log.flushFile(id) -> nil`: Flushes a file-backed sink by id when it exists.
- `lurek.log.getLevel() -> string`: Returns the global log level string.
- `lurek.log.info(message, tag?) -> nil`: Logs an info message with an optional tag.
- `lurek.log.info_fields(message, fields_tbl) -> nil`: Logs an info message with structured fields.
- `lurek.log.listSinks() -> table`: Returns metadata for all registered sinks.
- `lurek.log.print(level, message, tag?) -> nil`: Logs a message at a runtime-selected level with an optional tag.
- `lurek.log.readMemory(id, drain?) -> table`: Reads entries from a memory sink and optionally drains them.
- `lurek.log.removeSink(id) -> boolean`: Removes a sink by id and releases any callback registry key.
- `lurek.log.setLevel(level) -> nil`: Sets the global log level. This function is exposed to Lua scripts.
- `lurek.log.struct(level_str, message, fields_tbl) -> nil`: Logs a structured message at a runtime-selected level.
- `lurek.log.warn(message, tag?) -> nil`: Logs a warning message with an optional tag.
- `lurek.log.warn_fields(message, fields_tbl) -> nil`: Logs a warning message with structured fields.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LLogListSinksResult Type

- Generated result shape from @field tags.

##### Fields

- `id` (`integer`): Sink id.
- `level` (`string`): Minimum log level.
- `path` (`string?`): File path for file-backed sinks.
- `type` (`string`): Sink type name.

##### Methods

- No documented methods.

#### LLogReadMemoryResult Type

- Generated result shape from @field tags.

##### Fields

- `fields` (`table?`): Optional structured fields table.
- `level` (`string`): Log level.
- `message` (`string`): Log message.
- `tag` (`string`): Log tag.

##### Methods

- No documented methods.

## References

- `binary`: Imports or references `src/binary/`. Cross-group dependency from `Foundations` into `Edge/Integration`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- No additional module-specific notes.
