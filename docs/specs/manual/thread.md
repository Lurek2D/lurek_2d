# thread manual spec overlay

## TL;DR

- Parallel Lua workers via isolated threads, safe channels, and promises.

## Summary

- The `thread` module is the isolated-concurrency surface for projects that want background Lua work without violating the engine's VM and runtime-safety rules.
- Channels, worker threads, pools, and promises let asynchronous work move messages and results between isolated execution contexts instead of sharing unsafe state directly.
- That matters because concurrency here is not just thread creation; it is about controlling what can cross between workers and how results return safely.
- The module is useful for expensive background tasks, staged jobs, and workflows where script-facing logic should continue while separate workers finish their part of the work.
- Promise-style completion is central because finished work still has to rejoin the foreground safely.
- It keeps worker isolation visible to scripts while still making background jobs practical and safe.
- Read it as the engine's sanctioned script-concurrency model.

This module primarily collaborates with `runtime`. Its responsibility should stay inside the Core Runtime group rather than absorb behavior owned by those neighbors.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
