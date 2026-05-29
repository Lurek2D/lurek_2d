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

- Declares `ReplCommand` enum for the five built-in colon commands: `:help`, `:quit`, `:clear`, `:reset`, and `:load <path>`.
- `display_text` returns a short human-readable confirmation string for each command variant.
- Command data only; dispatch logic and Lua eval live in `session.rs`.

### completer.rs

- Provides `complete_prefix` for tab completion against a static pool and live Lua globals.
- Static pool includes Lua keywords, built-in globals, standard libraries, colon commands, and all `lurek.*` sub-namespaces.
- Dynamic branch resolves a dot-separated path through Lua globals and collects matching key names.
- Output is sorted and deduplicated; callers pass `None` for the Lua handle when no VM is available.

### mod.rs

- Exports the release-safe Lua REPL core: session, commands, completer, and value formatter.
- Re-exports top-level symbols for convenient use by `lua_api` bindings and `devtools`.
- All REPL state is pure Rust with no wgpu or winit dependencies; safe for headless and test contexts.

### session.rs

- Implements `ReplSession`, a stateful Lua evaluator with bounded command history.
- `ReplResult` captures value output, silent success, structured error text, or a parsed colon command.
- Eval dispatches colon commands first; expression input tries `return <input>` then falls back to statement execution.
- History is capped at `max_history` entries; oldest entries are evicted when the cap is reached; default capacity is 200.
- `:load` reads a file from disk and executes it inside the current Lua VM, returning a command or error result.
- Session state is pure Rust; the Lua reference is borrowed per call and never stored on the struct.

### value.rs

- Converts a single `mlua::Value` to a display string for REPL and headless stdout output.
- Covers all Lua value kinds; opaque types like tables and functions return fixed angle-bracket labels.
- Error values include the Lua error message; nil returns the literal string `"nil"`.

## Lua API Ref

- Binding: `src/lua_api/repl_api.rs`
- Namespace: `lurek.repl`

### Functions

- `lurek.repl.new`: Creates a release-safe REPL session with bounded command history.

### Enums

- No documented module-level enums/constants.

### Types


#### LReplSession Type


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
