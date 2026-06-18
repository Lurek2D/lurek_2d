# repl

## TL;DR

- Evaluates Lua inputs with tab completion.

## General Info

- Module group: `Core Runtime`
- Source path: `src/repl/`
- Binding: `src/lua_api/repl_api.rs`
- Namespace: `lurek.repl`
- Lua API surface: `1` functions, `1` types, `7` methods
- Rust test path(s): tests/rust/unit/repl_tests.rs
- Lua test path(s): tests/lua/unit/test_repl_unit.lua

## Summary

- The `repl` module is the interactive evaluation surface for users who want to inspect or execute Lua code live inside a running engine context.
- Session state, commands, completion, and value rendering work together so ad hoc evaluation feels like a usable runtime console instead of a raw `eval` hook.
- Read it as the runtime console boundary. `repl` owns how state is queried, evaluated, formatted, and returned.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Files

### commands.rs

- `src/repl/commands.rs` defines the colon-command vocabulary that controls REPL behavior without entering plain Lua code.
- `ReplCommand` captures help, quit, clear, reset, and file-load intents so session control stays typed and explicit.
- Open this file when REPL control syntax or command result text changes, not when Lua evaluation semantics change.

### completer.rs

- `src/repl/completer.rs` provides interactive completion for REPL input, combining static names with live Lua globals.
- It resolves dotted table paths step by step, so nested namespaces like `lurek.render` can suggest meaningful members.
- Static completions keep core Lua and engine symbols available even before a runtime has populated additional globals.
- Normalization, sorting, and deduplication live here so prompt UIs receive stable suggestions instead of raw table noise.
- Open this file when completion scope, Lua table traversal, or suggestion ranking behavior needs to change.

### mod.rs

- `src/repl/mod.rs` is the REPL module index, exposing the headless interactive stack used by CLI, tools, and tests.
- It reexports command parsing, completion, session state, and value formatting so callers build a REPL from one surface.
- No execution state lives here; this file defines the public boundary while implementation stays split by concern below.
- Read this index when wiring REPL features, because it shows which pieces are public and how they are grouped.
- This module keeps evaluation independent from rendering, so terminals and automation can share one session core.
- Changes here alter the REPL boundary, since reexports decide what runtime code and developer tools may import.

### session.rs

- `src/repl/session.rs` owns REPL session state, classifying each input line as a command, expression, or statement.
- `ReplSession` stores bounded history, dispatches colon commands, and evaluates Lua code against a caller-supplied VM.
- Expression-first execution lives here so quick probing stays ergonomic while statements still work for larger snippets.
- `ReplResult` also lives here, keeping displayable outcomes for values, success, errors, and commands under one owner.
- Open this file when history policy, command dispatch, file loading, or evaluation flow needs to change.

### value.rs

- `src/repl/value.rs` converts raw Lua values into stable display text for REPL output and other inspection paths.
- It centralizes fallback labels for tables, functions, userdata, threads, and Lua errors so output stays consistent.
- Open this file when printable value formatting changes, not when session flow or command parsing behavior changes.



## Lua API Ref

### Functions

- `lurek.repl.new(max_history?) -> LReplSession`: Creates a release-safe REPL session with bounded command history.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LReplSession Type

- Lua-side REPL session handle with bounded history.

##### Fields

- No documented fields.

##### Methods

- `LReplSession:clear() -> nil`: Clears all entries from this REPL session history.
- `LReplSession:complete(prefix) -> string[]`: Returns completion candidates that begin with the supplied prefix.
- `LReplSession:eval(code) -> string`: Evaluates Lua code and records the input in this REPL history.
- `LReplSession:history() -> string[]`: Returns the recorded REPL input history in oldest-first order.
- `LReplSession:len() -> integer`: Returns the number of entries stored in this REPL history.
- `LReplSession:type() -> string`: Returns the Lua-visible type name for this REPL session handle.
- `LReplSession:typeOf(name) -> boolean`: Returns whether this REPL session handle matches a supported type name.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- No additional module-specific notes.
