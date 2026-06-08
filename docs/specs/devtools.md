# devtools

## TL;DR

- Gathers hardware frame stats and runs a hierarchical zone profiler.
- Integrates structured logs, REPL evaluation, and live file watching.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/devtools/`
- Binding: `src/lua_api/devtools_api.rs`
- Namespace: `lurek.devtools`
- Lua API surface: `50` functions, `9` types, `12` methods
- Rust test path(s): tests/rust/unit/devtools_tests.rs
- Lua test path(s): tests/lua/unit/test_devtools.lua; tests/lua/integration/test_devtools.lua

## Summary

- This module gives users a built-in diagnostics console for performance, logging, profiling, and live inspection.
- Frame statistics expose FPS and timing percentiles so regressions are visible during normal play sessions.
- CPU and GPU timing capture helps separate render bottlenecks from gameplay-script bottlenecks.
- Hierarchical profiling zones let teams measure nested code paths instead of guessing hotspots.
- Structured log controls support severity filtering and optional file mirroring for reproducible debug traces.
- REPL-style evaluation enables quick runtime checks and small fixes without full restart cycles.
- Watch expressions provide lightweight observability for high-value variables during tuning.
- File watching helps hot-reload loops react quickly to changed assets or scripts.
- Snapshot APIs combine multiple debug signals into one pull for overlays and tooling panes.
- The module improves iteration speed by shortening the observe-change-verify loop.
- It is useful for both solo debugging and team workflows where traceability matters.
- Script-level access keeps diagnostics close to gameplay code instead of hidden in engine internals.
- Users can gate profiling collection to control overhead when needed.
- For QA, retained history surfaces support post-failure triage without immediate repro.
- For content teams, watch-based updates reduce restart fatigue during frequent edits.
- Overall, this module turns diagnostics into a routine workflow rather than an emergency tool.
- It helps projects stay performance-aware throughout development, not only at the end.
- The practical result is faster root-cause discovery and cleaner release stabilization.
- Users gain visibility, control, and repeatable evidence from one integrated debug surface.

## Imports

- `filesystem`: Imports or references `src/filesystem/`. Cross-group dependency from `Edge/Integration` into `Core Runtime`.
- `repl`: Imports or references `src/repl/`. Dependency stays inside `Edge/Integration` and should remain acyclic.

## Files

### frame_stats.rs

- Implements bounded rolling frame-timing history used for live performance telemetry.
- Computes aggregate metrics including FPS, mean, min, max, and percentile summaries.
- Produces immutable snapshot views for diagnostics overlays and developer reporting paths.
- Serves as the frame-statistics data source for devtools performance introspection.
- Keeps sample retention bounded to maintain predictable memory usage in long sessions.

### logger.rs

- Implements structured developer logging with severity levels and bounded in-memory retention.
- Parses level labels case-insensitively and applies configurable minimum-level filtering.
- Supports optional category filtering and tail-style retrieval over retained log entries.
- Mirrors accepted records to stderr and optional append-only file outputs.
- Serves as the local devtools logging backbone for runtime diagnostics.

### lua_display.rs

- Implements Lua value pretty-print conversion for REPL and debug-facing display output.
- Handles scalar and structured value variants with stable human-readable formatting behavior.
- Returns safe fallback labels for unrecognized or unsupported value representations.

### mod.rs

- Defines the devtools module boundary for profiling, logging, REPL, and file-watch diagnostics.
- Groups developer instrumentation utilities into one cohesive runtime helper surface.
- Serves as the composition entry for non-production debugging and observability workflows.

### profiler.rs

- Implements hierarchical runtime profiling with nested push-pop zone timing semantics.
- Computes total and exclusive durations per zone for accurate hotspot attribution.
- Captures per-frame profiling trees into bounded rolling history collections.
- Supports indexed frame access and flattened traversal for aggregate performance reporting.
- Serves as the profiling core for devtools runtime instrumentation.

### repl.rs

- Implements a compatibility wrapper around the release-safe REPL session core.
- Preserves devtools console API shape with bounded command-history behavior.
- Returns evaluation outcomes as success markers, value strings, or formatted errors.

### time_anchor.rs

- Implements a monotonic timing anchor used to compute elapsed seconds on demand.
- Provides shared timestamp base behavior for logger and profiler instrumentation.
- Serves as a lightweight time-reference primitive for devtools subsystems.

### watcher.rs

- Implements watched-file tracking with mtime snapshots for change-detection workflows.
- Polls registered paths and reports deterministic modified-path sets per update tick.
- Integrates optional native notify backend when feature-gated devtools plugin support is enabled.
- Supports path registration, stale marking, and complete watch-state reset operations.
- Deduplicates and orders change reports for stable hot-reload consumption.

## Lua API Ref

### Functions

- `lurek.devtools.clearLog() -> nil`: Clears all in-memory devtools log entries.
- `lurek.devtools.clearWatches() -> nil`: Removes every path from the module-level file watcher.
- `lurek.devtools.debug(message) -> nil`: Adds a debug-level diagnostic message to the devtools log.
- `lurek.devtools.error(message) -> nil`: Adds an error-level diagnostic message to the devtools log.
- `lurek.devtools.eval(code) -> LuaValue`: Evaluates Lua code in the current state and returns success plus values or failure plus an error message.
- `lurek.devtools.exposeWatch(name, getter, category?) -> integer`: Registers a watch expression callback for snapshots and watch panels.
- `lurek.devtools.fatal(message) -> nil`: Adds a fatal-level diagnostic message to the devtools log.
- `lurek.devtools.getCallStack(max_depth?) -> table`: Returns Lua call stack frames using the Lua debug library.
- `lurek.devtools.getFrameHistory() -> number[]`: Returns retained CPU frame duration samples in insertion order.
- `lurek.devtools.getFrameHistorySize() -> integer`: Returns the current CPU frame history capacity.
- `lurek.devtools.getFrameStats() -> table`: Returns aggregate CPU frame timing statistics from recorded samples.
- `lurek.devtools.getGpuFrameStats() -> table`: Returns aggregate GPU frame timing statistics from recorded samples.
- `lurek.devtools.getLogConsole() -> boolean`: Returns whether devtools log entries are mirrored to the console.
- `lurek.devtools.getLogFile() -> string`: Returns the file path currently stored as the devtools log target.
- `lurek.devtools.getLogHistory(count?) -> table`: Returns recent devtools log entries as structured tables.
- `lurek.devtools.getLogLevel() -> string`: Returns the minimum severity currently used by devtools log output.
- `lurek.devtools.getProfileData(frame?) -> table`: Returns the profiler zone tree for a retained frame.
- `lurek.devtools.getProfileFrameCount() -> integer`: Returns how many profiling frames are currently stored.
- `lurek.devtools.getWatchInterval() -> number`: Returns the polling interval hint used by devtools watch UIs.
- `lurek.devtools.getWatchedPaths() -> string[]`: Returns all paths currently watched by the module-level file watcher.
- `lurek.devtools.getWatches() -> table`: Evaluates exposed watch callbacks and returns their current values.
- `lurek.devtools.info(message) -> nil`: Adds an info-level diagnostic message to the devtools log.
- `lurek.devtools.isConsoleOpen() -> boolean`: Returns whether the devtools console is marked open.
- `lurek.devtools.isEntityInspectorOpen() -> boolean`: Returns whether the devtools entity inspector is marked open.
- `lurek.devtools.isProfilingEnabled() -> boolean`: Returns whether CPU profiling zone collection is currently enabled.
- `lurek.devtools.log(level, message) -> nil`: Adds a message to the devtools log using an explicit severity level.
- `lurek.devtools.newFileWatcher(path) -> LFileWatcher`: Creates a dedicated file watcher userdata for one path.
- `lurek.devtools.newRepl(max_history?) -> LReplConsole`: Creates a REPL console userdata with bounded command history.
- `lurek.devtools.openConsole() -> boolean`: Marks the devtools console as open for UI state tracking.
- `lurek.devtools.openEntityInspector() -> boolean`: Marks the devtools entity inspector as open for UI state tracking.
- `lurek.devtools.profileFrame() -> nil`: Closes the current profiling frame and stores its zone tree for later inspection.
- `lurek.devtools.profilePop(name?) -> nil`: Ends the current profiling zone on the profiler stack.
- `lurek.devtools.profilePush(name) -> nil`: Starts a named profiling zone on the current profiler stack.
- `lurek.devtools.profilerReport() -> table`: Aggregates retained profiler frames into per-zone timing rows.
- `lurek.devtools.recordFrameTime(dt_val) -> nil`: Records one CPU frame duration sample for devtools frame statistics.
- `lurek.devtools.recordGpuFrameTime(dt_val) -> nil`: Records one GPU frame duration sample for devtools frame statistics.
- `lurek.devtools.removeWatch(id) -> boolean`: Removes a previously exposed watch expression by id.
- `lurek.devtools.resetProfile() -> nil`: Clears profiler state, active zones, and retained profiling frames.
- `lurek.devtools.scan() -> string[]`: Polls module-level file watches and returns paths that changed since the previous scan.
- `lurek.devtools.setFrameHistorySize(size) -> nil`: Sets the maximum number of CPU frame duration samples retained by devtools.
- `lurek.devtools.setLogConsole(enabled) -> nil`: Enables or disables mirroring devtools log entries to the console.
- `lurek.devtools.setLogFile(path) -> nil`: Sets the file path used by devtools file logging state.
- `lurek.devtools.setLogLevel(level) -> nil`: Sets the minimum severity that remains visible in devtools log output.
- `lurek.devtools.setProfilingEnabled(enabled) -> nil`: Enables or disables collection of CPU profiling zones.
- `lurek.devtools.setWatchInterval(interval) -> nil`: Sets the polling interval hint used by devtools watch UIs.
- `lurek.devtools.snapshot() -> table`: Captures a combined devtools snapshot containing frame stats, watch values, profile data, and recent logs.
- `lurek.devtools.trace(message) -> nil`: Adds a trace-level diagnostic message to the devtools log.
- `lurek.devtools.unwatch(path) -> boolean`: Removes a path from the module-level devtools file watcher.
- `lurek.devtools.warn(message) -> nil`: Adds a warning-level diagnostic message to the devtools log.
- `lurek.devtools.watch(path) -> boolean`: Adds a path to the module-level devtools file watcher.

### Callbacks

- `LFileWatcher:onChanged` param `func` (`function`): Callback called with no arguments after a change is detected.
- `lurek.devtools.exposeWatch` param `getter` (`function`): Callback invoked with no arguments when watch values are collected.

### Enums

- No documented module-level enums/constants.

### Types

#### LDevtoolsGetFrameStatsResult Type

- Generated result shape from @field tags.

##### Fields

- `avg` (`number`): Avg.
- `dt` (`number`): Dt.
- `fps` (`number`): Fps.
- `max` (`number`): Max.
- `min` (`number`): Min.
- `p50` (`number`): P50.
- `p95` (`number`): P95.
- `p99` (`number`): P99.
- `samples` (`integer`): Samples.

##### Methods

- No documented methods.

#### LDevtoolsGetGpuFrameStatsResult Type

- Generated result shape from @field tags.

##### Fields

- `avg` (`number`): Avg.
- `dt` (`number`): Dt.
- `fps` (`number`): Fps.
- `max` (`number`): Max.
- `min` (`number`): Min.
- `p50` (`number`): P50.
- `p95` (`number`): P95.
- `p99` (`number`): P99.
- `samples` (`integer`): Samples.

##### Methods

- No documented methods.

#### LDevtoolsGetLogHistoryResult Type

- Generated result shape from @field tags.

##### Fields

- `category` (`string?`): Optional log category.
- `level` (`string`): Log level.
- `line` (`integer`): Line number.
- `message` (`string`): Log message.
- `source` (`string`): Source file.
- `timestamp` (`number`): Unix timestamp.

##### Methods

- No documented methods.

#### LDevtoolsGetProfileDataResult Type

- Generated result shape from @field tags.

##### Fields

- `children` (`table`): Nested child zones.
- `name` (`string`): Zone name.
- `selfTime` (`number`): Self time in ms.
- `startTime` (`number`): Start time in ms.
- `time` (`number`): Total time in ms.

##### Methods

- No documented methods.

#### LDevtoolsGetWatchesResult Type

- Generated result shape from @field tags.

##### Fields

- `category` (`string`): Category.
- `name` (`string`): Watch name.
- `value` (`string`): Formatted value.

##### Methods

- No documented methods.

#### LDevtoolsProfilerReportResult Type

- Generated result shape from @field tags.

##### Fields

- `avg_ms` (`number`): Average time per call in ms.
- `call_count` (`integer`): Call count.
- `max_ms` (`number`): Maximum time in ms.
- `min_ms` (`number`): Minimum time in ms.
- `name` (`string`): Zone name.
- `self_ms` (`number`): Self time in ms.
- `total_ms` (`number`): Total time in ms.

##### Methods

- No documented methods.

#### LDevtoolsSnapshotResult Type

- Generated result shape from @field tags.

##### Fields

- `frameStats` (`table`): Frame statistics table.
- `log` (`table`): Recent log entries table.
- `profile` (`table`): Profile data table.
- `watchCount` (`integer`): WatchCount.
- `watches` (`table`): Watch values table.

##### Methods

- No documented methods.

#### LFileWatcher Type

- Lua-side file watcher with an optional change callback.

##### Fields

- No documented fields.

##### Methods

- `LFileWatcher:cancel() -> nil`: Cancels this watcher and removes its callback.
- `LFileWatcher:check() -> boolean`: Polls the watcher and invokes the change callback when a change is found.
- `LFileWatcher:getPath() -> string`: Returns the watched path. This method is available to Lua scripts.
- `LFileWatcher:onChanged(func) -> nil`: Sets the callback invoked when this watcher observes a change.
- `LFileWatcher:type() -> string`: Returns the Lua-visible type name for this file watcher handle.
- `LFileWatcher:typeOf(name) -> boolean`: Returns whether this file watcher handle matches a supported type name.

#### LReplConsole Type

- Lua-side REPL console handle with bounded history.

##### Fields

- No documented fields.

##### Methods

- `LReplConsole:clear() -> nil`: Clears this REPL console's command history.
- `LReplConsole:eval(code) -> LuaValue`: Evaluates Lua code through this REPL console and records it in history.
- `LReplConsole:history() -> string[]`: Returns this REPL console's recorded command history.
- `LReplConsole:len() -> integer`: Returns the number of entries stored in this REPL console history.
- `LReplConsole:type() -> string`: Returns the Lua-visible type name for this REPL console handle.
- `LReplConsole:typeOf(name) -> boolean`: Returns whether this REPL console handle matches a supported type name.
