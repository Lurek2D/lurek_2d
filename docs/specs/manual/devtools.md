# devtools manual spec overlay

## TL;DR

- Gathers hardware frame stats and runs a hierarchical zone profiler.
- Integrates structured logs, REPL evaluation, and live file watching.

## Summary

- The `devtools` module is the live diagnostics surface for users who need to inspect runtime behavior while the game is still running.
- Frame stats, profiling, structured logs, REPL evaluation, file watching, and value display work together so performance issues, script mistakes, and content regressions can be investigated through one integrated toolset.
- Debugging rarely depends on one signal at a time, so the same workflow often needs timings, logs, on-the-fly evaluation, and change detection to explain what is actually happening.
- Retained history, snapshots, and bounded diagnostic state make the module useful for both immediate interactive debugging and later post-failure analysis.
- Live overlays and runtime command surfaces shorten the loop between observation and intervention, while the shared observability layer reduces the need for scattered temporary debug code.
- The module therefore acts as more than a bag of debug widgets. It is the place where runtime evidence becomes structured enough to inspect, compare, and revisit across a longer development session.
- REPL access and live value inspection are especially useful because they let users test assumptions directly inside a running build instead of relying only on offline logs or one-off instrumentation.
- File watching and retained traces further reduce iteration cost by keeping content changes, script reloads, and inspection history inside the same feedback loop.
- Read `devtools` as the developer-facing observability hub of the engine.

This module primarily collaborates with `filesystem`, `repl`. Its responsibility should stay inside the Edge/Integration group rather than absorb behavior owned by those neighbors.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
