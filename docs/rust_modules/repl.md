# repl

## General Info

- Module group: `Core Runtime`
- Source path: `src/repl/`
- Binding: `src/lua_api/repl_api.rs`
- Namespace: `lurek.repl`
- Lua API surface: `1` functions, `1` types, `7` methods
- Rust test path(s): tests/rust/unit/repl_tests.rs
- Lua test path(s): tests/lua/unit/test_repl_core_unit.lua

## Summary

This module provides a headless, embeddable interactive Lua session that evaluates code against the running VM. It operates independently of rendering layers, maintaining a bounded history and executing colon-prefixed console commands.

To assist users, a completer scans live globals and keywords to suggest autocomplete candidates, resolving dot-paths. Raw values are formatted into readable text for interactive debugging feedback.

## Files

### [commands.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/repl/commands.rs)

- This file defines the small command language for colon-prefixed REPL control actions.
- It keeps command intent separate from evaluation logic so parsing and execution stay cleanly divided.
- The result is a lightweight vocabulary for session management layered on top of ordinary Lua input.

### [completer.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/repl/completer.rs)

- This file implements completion for interactive REPL input so partially typed commands can expand into useful candidates.
- Suggestions come from both a static knowledge base of Lua and engine names and the live global environment of the current VM.
- Dot-path completion is resolved step by step, which makes nested tables and engine namespaces feel navigable from the prompt.
- Candidate output is normalized and deduplicated so the REPL can present stable suggestions instead of noisy raw table keys.
- The file therefore acts as the discoverability layer of the REPL, helping users explore available runtime symbols while typing.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/repl/mod.rs)

- This module provides the headless REPL stack for evaluating Lua, formatting results, and assisting interactive input.
- It keeps the feature independent from rendering concerns so terminals, tests, and tools can all reuse the same session core.
- At the top level this is the engine's embeddable interactive console backend rather than a UI implementation.

### [session.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/repl/session.rs)

- This file implements the stateful heart of the REPL, where input is recorded, classified, and evaluated against a caller-supplied Lua VM.
- It distinguishes between command-style control input and ordinary Lua text so one prompt can manage both session behavior and code execution.
- Expression-first evaluation keeps interactive probing ergonomic while still falling back to statement execution for longer snippets.
- Command history is bounded and owned by the session, which keeps repeated use predictable without leaking VM references across calls.
- The file is therefore the operational core that makes the REPL feel persistent and interactive while remaining headless and embeddable.

### [value.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/repl/value.rs)

- This file turns raw Lua values into stable human-readable text for REPL output and other headless inspection paths.
- It gives every major Lua value kind a display strategy, including opaque runtime objects that cannot sensibly print their full internals.
- The formatter is tuned for readable interactive feedback rather than lossless serialization of Lua state.
