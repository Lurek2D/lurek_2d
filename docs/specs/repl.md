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

- The repl module gives users an embeddable headless Lua REPL for live runtime inspection and quick experimentation.
- Session state includes bounded history so command context stays manageable over long usage.
- Colon-prefixed commands support console-style control behavior alongside Lua evaluation.
- Completion scans keywords and live globals, including top-level and dot-path suggestions.
- Value formatting produces readable output suited to interactive debugging sessions.

This module is mostly self-contained inside the `Core Runtime` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Files

### commands.rs

- This file defines the small command language for colon-prefixed REPL control actions.
- It keeps command intent separate from evaluation logic so parsing and execution stay cleanly divided.
- The result is a lightweight vocabulary for session management layered on top of ordinary Lua input.

### completer.rs

- This file implements completion for interactive REPL input so partially typed commands can expand into useful candidates.
- Suggestions come from both a static knowledge base of Lua and engine names and the live global environment of the current VM.
- Dot-path completion is resolved step by step, which makes nested tables and engine namespaces feel navigable from the prompt.
- Candidate output is normalized and deduplicated so the REPL can present stable suggestions instead of noisy raw table keys.
- The file therefore acts as the discoverability layer of the REPL, helping users explore available runtime symbols while typing.

### mod.rs

- This module provides the headless REPL stack for evaluating Lua, formatting results, and assisting interactive input.
- It keeps the feature independent from rendering concerns so terminals, tests, and tools can all reuse the same session core.
- At the top level this is the engine's embeddable interactive console backend rather than a UI implementation.

### session.rs

- This file implements the stateful heart of the REPL, where input is recorded, classified, and evaluated against a caller-supplied Lua VM.
- It distinguishes between command-style control input and ordinary Lua text so one prompt can manage both session behavior and code execution.
- Expression-first evaluation keeps interactive probing ergonomic while still falling back to statement execution for longer snippets.
- Command history is bounded and owned by the session, which keeps repeated use predictable without leaking VM references across calls.
- The file is therefore the operational core that makes the REPL feel persistent and interactive while remaining headless and embeddable.

### value.rs

- This file turns raw Lua values into stable human-readable text for REPL output and other headless inspection paths.
- It gives every major Lua value kind a display strategy, including opaque runtime objects that cannot sensibly print their full internals.
- The formatter is tuned for readable interactive feedback rather than lossless serialization of Lua state.



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
