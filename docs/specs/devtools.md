<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/devtools.md or source docstrings instead. -->

# devtools

## TL;DR

- Gathers hardware frame stats and runs a hierarchical zone profiler.
- Integrates structured logs, REPL evaluation, and live file watching.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/devtools`
- Binding: `src/lua_api/devtools_api.rs`
- Namespace: `lurek.devtools`
- Lua API surface: `50` functions, `9` types, `12` methods
- User-facing: `true`
- Plugin tier: `not_evaluated`

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

## Ownership

- Canonical source: `src/devtools`
- Owning tier: `Edge/Integration`
- Plugin tier: `not_evaluated`
- Lua binding owner: `src/lua_api/devtools_api.rs`
- Referenced engine modules: `filesystem`, `repl`

## Imports

- `filesystem`: Imports or references `src/filesystem/`. Cross-group dependency from `Edge/Integration` into `Core Runtime`.
- `repl`: Imports or references `src/repl/`. Cross-group dependency from `Edge/Integration` into `Core Runtime`.

## Source Files

### frame_stats.rs

- This file owns `FrameStats` and `FrameSnapshot`, the rolling metrics source for live performance telemetry.
- It stores a bounded deque of frame deltas, trims history on writes, and clamps capacity updates to sane limits.
- Snapshot generation sorts retained samples and derives FPS, average, min, max, and percentile timing summaries.
- The zero snapshot path keeps empty-history behavior explicit for overlays and diagnostic reporting callers.
- Open this file when frame-metric semantics change; logging, profiling, and watchers live in sibling modules.

### logger.rs

- This file owns `LogLevel`, `LogEntry`, and `Logger`, the bounded developer logging stack for runtime diagnostics.
- It parses severity labels, timestamps accepted records, mirrors output to stderr, and can append to a log file.
- History helpers retain recent entries, return configurable tails, and filter categories by lowercase prefix match.
- The logger uses `TimeAnchor` for relative timestamps so devtools records share one stable elapsed-time reference.
- Open this file when log retention or filtering changes; clocks, profiling, and file watching live in siblings.

### lua_display.rs

- This file owns Lua value display formatting used by the REPL and other developer-facing text output paths.
- It converts primitive `mlua::Value` variants to readable strings and uses placeholders for opaque runtime kinds.
- Open this file when debug text rendering changes; command history and evaluation flow live in sibling modules.

### mod.rs

- This module re-exports devtools support for frame stats, logging, profiling, REPL helpers, timing, and file watching.
- It is the navigation map for developer instrumentation surfaces rather than the owner of runtime capture state.
- `frame_stats.rs` owns rolling frame metrics, while `profiler.rs` records hierarchical timing trees across frames.
- `logger.rs` and `repl.rs` cover diagnostic text capture and command evaluation used by developer workflows.
- `lua_display.rs`, `time_anchor.rs`, and `watcher.rs` provide value formatting, clocks, and change detection.
- Change this file when public devtools exports move; change sibling files when the underlying behavior changes.

### profiler.rs

- This file owns `ProfileZone` and `Profiler`, the hierarchical timing capture model used for runtime profiling.
- It records nested push-pop zones, computes total and exclusive time, and keeps bounded frame history in memory.
- Frame finalization closes open zones, stores root trees, and supports reverse-style frame indexing for inspection.
- Flattening helpers expose pre-order traversals so reporting code can aggregate hotspots without tree rewriting.
- Open this file when profiling capture semantics change; frame stats, logging, and clocks live in sibling files.

### repl.rs

- This file owns `ReplConsole`, the devtools wrapper around the shared `ReplSession` evaluation implementation.
- It preserves bounded history, delegates line evaluation, and exposes history, length, and clear operations.
- Open this file when developer console behavior changes; Lua value formatting and session core live in siblings.

### time_anchor.rs

- This file owns `TimeAnchor`, the monotonic clock wrapper used to measure elapsed devtools time in seconds.
- It stores one `Instant` and exposes lightweight construction plus elapsed reads for loggers and profilers.
- Open this file when shared elapsed-time semantics change; higher-level history and capture logic lives in siblings.

### watcher.rs

- This file owns `FileWatcher`, the watched-path tracker used to detect file changes for hot-reload workflows.
- It stores path-to-mtime state, polls for modifications, removals, and stale markers, and returns changed paths.
- When the `devtools-plugin` feature is enabled, it also bridges the native `notify` backend into the same API.
- Watch, unwatch, clear, and force-changed operations keep registration and reset behavior local to one owner.
- Open this file when change-detection semantics move; filesystem mtimes and devtools callers live in siblings.



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

## Examples

- `content/examples/devtools.lua` (present)

## Tests

- Lua unit: `tests/lua/unit/test_devtools_unit.lua` (present)
- Rust: none detected.

## Evidence / Golden

- No evidence or golden artifacts registered.

## Architecture Links

- Intentionally empty.

## Notes

- No additional module-specific notes.
