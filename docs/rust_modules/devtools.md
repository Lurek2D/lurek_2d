# devtools

## General Info

- Module group: `Edge/Integration`
- Source path: `src/devtools/`
- Binding: `src/lua_api/devtools_api.rs`
- Namespace: `lurek.devtools`
- Lua API surface: `50` functions, `9` types, `12` methods
- Rust test path(s): tests/rust/unit/devtools_tests.rs
- Lua test path(s): tests/lua/unit/test_devtools.lua; tests/lua/integration/test_devtools.lua

## Summary

The `devtools` module is the main diagnostics toolkit for development-time runtime inspection. It gathers useful signals while the game is running, so teams can understand behavior, detect problems, and iterate faster.

Its capabilities are practical and complementary: structured logs for event history, frame statistics for timing trends, hierarchical profiling for hotspot analysis, and REPL evaluation for quick debugging loops.

File-watch support and watch-style value inspection help with rapid iteration when scripts and data change often. This reduces turnaround time for testing fixes and tuning systems.

The module is operational, not gameplay-facing. It provides instrumentation surfaces that other systems can call, while feature logic stays in dedicated runtime modules.

In practice, `lurek.devtools` gives one consistent interface for diagnostics across local runs, test workflows, and integration debugging.

## Files

### [frame_stats.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/devtools/frame_stats.rs)

- Implements bounded rolling frame-timing history used for live performance telemetry.
- Computes aggregate metrics including FPS, mean, min, max, and percentile summaries.
- Produces immutable snapshot views for diagnostics overlays and developer reporting paths.
- Serves as the frame-statistics data source for devtools performance introspection.
- Keeps sample retention bounded to maintain predictable memory usage in long sessions.

### [logger.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/devtools/logger.rs)

- Implements structured developer logging with severity levels and bounded in-memory retention.
- Parses level labels case-insensitively and applies configurable minimum-level filtering.
- Supports optional category filtering and tail-style retrieval over retained log entries.
- Mirrors accepted records to stderr and optional append-only file outputs.
- Serves as the local devtools logging backbone for runtime diagnostics.

### [lua_display.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/devtools/lua_display.rs)

- Implements Lua value pretty-print conversion for REPL and debug-facing display output.
- Handles scalar and structured value variants with stable human-readable formatting behavior.
- Returns safe fallback labels for unrecognized or unsupported value representations.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/devtools/mod.rs)

- Defines the devtools module boundary for profiling, logging, REPL, and file-watch diagnostics.
- Groups developer instrumentation utilities into one cohesive runtime helper surface.
- Serves as the composition entry for non-production debugging and observability workflows.

### [profiler.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/devtools/profiler.rs)

- Implements hierarchical runtime profiling with nested push-pop zone timing semantics.
- Computes total and exclusive durations per zone for accurate hotspot attribution.
- Captures per-frame profiling trees into bounded rolling history collections.
- Supports indexed frame access and flattened traversal for aggregate performance reporting.
- Serves as the profiling core for devtools runtime instrumentation.

### [repl.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/devtools/repl.rs)

- Implements a compatibility wrapper around the release-safe REPL session core.
- Preserves devtools console API shape with bounded command-history behavior.
- Returns evaluation outcomes as success markers, value strings, or formatted errors.

### [time_anchor.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/devtools/time_anchor.rs)

- Implements a monotonic timing anchor used to compute elapsed seconds on demand.
- Provides shared timestamp base behavior for logger and profiler instrumentation.
- Serves as a lightweight time-reference primitive for devtools subsystems.

### [watcher.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/devtools/watcher.rs)

- Implements watched-file tracking with mtime snapshots for change-detection workflows.
- Polls registered paths and reports deterministic modified-path sets per update tick.
- Integrates optional native notify backend when feature-gated devtools plugin support is enabled.
- Supports path registration, stale marking, and complete watch-state reset operations.
- Deduplicates and orders change reports for stable hot-reload consumption.
