# repl manual spec overlay

## TL;DR

- Evaluates Lua inputs with tab completion.

## Summary

- The `repl` module is the interactive evaluation surface for users who want to inspect or execute Lua code live inside a running engine context.
- Session state, commands, completion, and value rendering work together so ad hoc evaluation feels like a usable runtime console instead of a raw `eval` hook.
- Read it as the runtime console boundary. `repl` owns how state is queried, evaluated, formatted, and returned.

This module is mostly self-contained inside the `Core Runtime` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
