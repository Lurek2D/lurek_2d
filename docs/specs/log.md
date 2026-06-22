<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/log.md or source docstrings instead. -->

# log

## TL;DR

- Runs structured logs with level-filtered sinks.

## General Info

- Module group: `Foundations`
- Source path: `src/log`
- Binding: `src/lua_api/log_api.rs`
- Namespace: `lurek.log`
- Lua API surface: `18` functions, `2` types, `0` methods
- User-facing: `true`
- Plugin tier: `not_evaluated`

## Summary

- The `log` module is the common script-facing path for runtime diagnostics, so users can emit messages through one consistent logging surface instead of mixing ad hoc print styles.
- It keeps message formatting, structured fields, severity, and sink routing together, which lets debugging output scale from quick traces to retained logs.
- That common path makes filtering and correlation across subsystems easier.
- Read it as the standard language for script diagnostics when several systems need to be debugged through the same output flow.

This module primarily collaborates with `binary`, `runtime`. Its responsibility should stay inside the Foundations group rather than absorb behavior owned by those neighbors.

## Ownership

- Canonical source: `src/log`
- Owning tier: `Foundations`
- Plugin tier: `not_evaluated`
- Lua binding owner: `src/lua_api/log_api.rs`
- Referenced engine modules: `binary`, `runtime`

## Imports

- `binary`: Imports or references `src/binary/`. Dependency stays inside `Foundations` and should remain acyclic.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Foundations` into `Core Runtime`.

## Source Files

### facade.rs

- `src/log/facade.rs` owns the caller-facing structured logging helpers that emit tagged messages with optional fields.
- It defines `LogFields` plus level get and set helpers, keeping fast logging entry points separate from sink internals.
- Open this file when log message shaping, default tags, or global log-level control behavior need to change.

### mod.rs

- `src/log/mod.rs` is the module index that exposes structured logging helpers and sink infrastructure.
- It reexports level control, structured dispatch, and sink types so runtime code uses one stable logging surface.
- No active sink registry lives here; this file only declares child modules and defines which logging symbols are public.
- Read this index when wiring diagnostics, because it shows where caller-facing logging ends and backend sinks begin.
- Changes here reshape the logging boundary, since reexports decide what runtime and Lua-facing code may import.
- This module keeps facade APIs and sink implementations separated, which makes logging ownership easier to trace.

### sinks.rs

- `src/log/sinks.rs` owns sink backends, sink-level filtering, output formatting, and the registry that dispatches logs.
- It defines `SinkLevel`, `MemoryEntry`, `RotatingFileSink`, `SinkKind`, `Sink`, and `SinkRegistry` under one owner.
- File, rotating-file, memory, and callback sinks all live here, keeping backend-specific write behavior in one place.
- Plain text, JSON, and NDJSON formatting are implemented here along with timestamps, ANSI color, and tag filtering.
- Rotation policy, buffered file writes, memory capture, and per-sink acceptance rules are handled inside this file.
- The registry also dispatches structured and unstructured messages to every sink, which makes fan-out behavior explicit.
- Read it when retention, formatting, file-rotation rules, or backend selection for runtime diagnostics must change.
- Higher layers should treat this file as the sink boundary, while caller-facing log entry helpers stay in `facade.rs`.
- This is also where machine-oriented output contracts live, so tooling changes should start here before call sites.



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

## Examples

- `content/examples/log.lua` (present)

## Tests

- Lua unit: `tests/lua/unit/test_log_unit.lua` (present)
- Rust: `tests/rust/unit/log_tests.rs`

## Evidence / Golden

- No evidence or golden artifacts registered.

## Architecture Links

- Intentionally empty.

## Notes

- No additional module-specific notes.
