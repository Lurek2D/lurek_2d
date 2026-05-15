# repl

## General Info

- Module group: `Core Runtime`
- Source path: `src/repl/`
- Lua API path(s): `src/lua_api/repl_api.rs`
- Primary Lua namespace: `lurek.repl`
- Rust test path(s): tests/rust/unit/repl_tests.rs
- Lua test path(s): tests/lua/unit/test_repl_core_unit.lua

## Summary

Release-safe Lua REPL (Read-Eval-Print Loop) core providing interactive command execution with bounded history, tab completion, multi-line input detection, and formatted value display. `ReplSession` manages input state, history navigation, and colon-command dispatch (`:help`, `:clear`, `:vars`, `:time`, `:reset`).

Value formatting recursively converts Lua values to human-readable strings with configurable depth limits and table truncation. Tab completion resolves partial identifiers against the Lua global table and loaded module namespaces. The REPL core is headless — it processes string input and returns string output, making it reusable by both the GUI terminal and the debug bridge. Exposed as `lurek.repl.*`. Core Runtime tier.

## Source Documentation

### `commands.rs`
- Declares `ReplCommand` enum for the five built-in colon commands: `:help`, `:quit`, `:clear`, `:reset`, and `:load <path>`.
- `display_text` returns a short human-readable confirmation string for each command variant.
- Command data only; dispatch logic and Lua eval live in `session.rs`.

### `completer.rs`
- Provides `complete_prefix` for tab completion against a static pool and live Lua globals.
- Static pool includes Lua keywords, built-in globals, standard libraries, colon commands, and all `lurek.*` sub-namespaces.
- Dynamic branch resolves a dot-separated path through Lua globals and collects matching key names.
- Output is sorted and deduplicated; callers pass `None` for the Lua handle when no VM is available.

### `mod.rs`
- Exports the release-safe Lua REPL core: session, commands, completer, and value formatter.
- Re-exports top-level symbols for convenient use by `lua_api` bindings and `devtools`.
- All REPL state is pure Rust with no wgpu or winit dependencies; safe for headless and test contexts.

### `session.rs`
- Implements `ReplSession`, a stateful Lua evaluator with bounded command history.
- `ReplResult` captures value output, silent success, structured error text, or a parsed colon command.
- Eval dispatches colon commands first; expression input tries `return <input>` then falls back to statement execution.
- History is capped at `max_history` entries; oldest entries are evicted when the cap is reached; default capacity is 200.
- `:load` reads a file from disk and executes it inside the current Lua VM, returning a command or error result.
- Session state is pure Rust; the Lua reference is borrowed per call and never stored on the struct.

### `value.rs`
- Converts a single `mlua::Value` to a display string for REPL and headless stdout output.
- Covers all Lua value kinds; opaque types like tables and functions return fixed angle-bracket labels.
- Error values include the Lua error message; nil returns the literal string `"nil"`.

## Types

- `ReplCommand` (`enum`, `commands.rs`): Supported special commands: `:help`, `:quit`, `:clear`, `:reset`, and `:load <file>`.
- `ReplResult` (`enum`, `session.rs`): Result shape for one REPL line: value, ok, error, or command.
- `ReplSession` (`struct`, `session.rs`): Bounded-history REPL evaluator over an existing `mlua::Lua` VM.

## Functions

- `ReplCommand::display_text` (`commands.rs`): Return a short human-readable command result.
- `complete_prefix` (`completer.rs`): Returns sorted completions for a prefix using static candidates and optional Lua table inspection.
- `ReplResult::display_text` (`session.rs`): Convert the result into the text shown by devtools and CLI views.
- `ReplSession::new` (`session.rs`): Create a REPL session with bounded history capacity.
- `ReplSession::eval_line` (`session.rs`): Evaluate one line as a command, expression, or statement.
- `ReplSession::history` (`session.rs`): Return an immutable view of recorded history entries.
- `ReplSession::clear` (`session.rs`): Clear all recorded REPL command history entries.
- `ReplSession::len` (`session.rs`): Return the number of retained history entries.
- `ReplSession::is_empty` (`session.rs`): Return true when no history entries are stored.
- `ReplSession::completions_for` (`session.rs`): Return sorted completions for a prefix using static and Lua table candidates.
- `value_to_string` (`value.rs`): Converts a Lua value into stable display text.

## Lua API Reference

- Binding path(s): `src/lua_api/repl_api.rs`
- Namespace: `lurek.repl`

### Module Functions
- `lurek.repl.new`: Creates a release-safe REPL session with bounded command history.

### `LReplSession` Methods
- `LReplSession:eval`: Evaluates Lua code and records the input in this REPL history.
- `LReplSession:history`: Returns the recorded REPL input history in oldest-first order.
- `LReplSession:clear`: Clears all entries from this REPL session history.
- `LReplSession:len`: Returns the number of entries stored in this REPL history.
- `LReplSession:complete`: Returns completion candidates that begin with the supplied prefix.
- `LReplSession:type`: Returns the Lua-visible type name for this REPL session handle.
- `LReplSession:typeOf`: Returns whether this REPL session handle matches a supported type name.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- `ReplSession` does not own a Lua VM. Embedding runtimes pass the active `mlua::Lua` into each evaluation call.
- `:reset` returns a command result and clears REPL history. The embedding CLI is responsible for creating a fresh Lua VM in a later phase.
- `:load <file>` reads a local Lua file and executes it in the current VM. The current GUI CLI mode still resolves host-file paths; a future GameFS-aware path policy can replace that if needed.
