# repl

## General Info

- Module group: `Core Runtime`
- Source path: `src/repl/`
- Lua API path(s): `src/lua_api/repl_api.rs`
- Primary Lua namespace: `lurek.repl`
- Rust test path(s): tests/rust/unit/repl_tests.rs
- Lua test path(s): tests/lua/unit/test_repl_core_unit.lua

## Summary

The `repl` module owns the release-safe Lua REPL core used by interactive runtime surfaces. It evaluates Lua expressions and statements, stores bounded command history, formats Lua values for display, handles colon commands, and returns simple completion candidates.

The module is independent of `devtools` so it is available in release builds. Developer tools wrap this core through `ReplConsole`, and the GUI CLI startup path already embeds it through `lurek.repl` without depending on debug-only feature gates.

## Files

- `commands.rs`: Colon-command enum and display text for command results.
- `completer.rs`: Static and Lua-table-aware completion helper.
- `mod.rs`: Module root and re-export surface.
- `session.rs`: `ReplSession` state, evaluation flow, history, and file loading.
- `value.rs`: Lua value formatting for REPL display and headless stdout print.

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
- `ReplSession::clear` (`session.rs`): Clear command history.
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
