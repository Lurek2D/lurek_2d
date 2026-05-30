# repl

## TL;DR

- The `repl` module is a crucial Core Runtime tier component that provides a release-safe, interactive Read-Eval-Print Loop (REPL) for Lurek2D.

## General Info

- Module group: `Core Runtime`
- Source path: `src/repl/`
- Lua API path(s): `src/lua_api/repl_api.rs`
- Primary Lua namespace: `lurek.repl`
- Rust test path(s): tests/rust/unit/repl_tests.rs
- Lua test path(s): tests/lua/unit/test_repl_core_unit.lua

## Summary

Designed to execute Lua commands dynamically, it empowers developers and users to introspect state, run functions, and tweak variables at runtime. At its center is the `ReplSession`, a stateful evaluator that operates over an existing `mlua::Lua` VM without directly owning it. This design makes the REPL completely headless—processing string input and returning string output—so it can be seamlessly embedded into both in-game GUI developer terminals and external command-line debug bridges.

The REPL supports a rich set of interactive features. It manages a bounded command history (with a configurable capacity, defaulting to 200 entries), allowing users to easily navigate past inputs. The input evaluator intelligently handles expressions (attempting a `return <input>` first) before falling back to statement execution. A suite of built-in colon commands (`:help`, `:clear`, `:vars`, `:time`, `:reset`, `:load <file>`) provides essential session management and file execution capabilities directly from the prompt.

Furthermore, the module includes a sophisticated `completer` that offers tab completion against a static pool of Lua keywords, built-ins, standard libraries, and all `lurek.*` namespaces, while also dynamically resolving dot-separated paths against the live Lua global table. Value formatting is handled by a robust `value_to_string` recursive formatter, which converts all Lua value types (including opaque types like functions and userdata) into stable, human-readable display text with configurable depth limits and table truncation. Entirely free of wgpu or winit dependencies, the `lurek.repl.*` API ensures that interactive scripting is safe, stable, and available across all Lurek2D environments.

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

- Binding: `src/lua_api/repl_api.rs`
- Namespace: `lurek.repl`

### Functions

- `lurek.repl.new`: Creates a release-safe REPL session with bounded command history.

### Enums

- No documented module-level enums/constants.

### Types

#### LReplSession Type

- Lua-side REPL session handle with bounded history.

##### Fields

- No documented fields.

##### Methods

- `LReplSession:clear`: Clears all entries from this REPL session history.
- `LReplSession:complete`: Returns completion candidates that begin with the supplied prefix.
- `LReplSession:eval`: Evaluates Lua code and records the input in this REPL history.
- `LReplSession:history`: Returns the recorded REPL input history in oldest-first order.
- `LReplSession:len`: Returns the number of entries stored in this REPL history.
- `LReplSession:type`: Returns the Lua-visible type name for this REPL session handle.
- `LReplSession:typeOf`: Returns whether this REPL session handle matches a supported type name.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.
