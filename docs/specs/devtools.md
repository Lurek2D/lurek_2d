# devtools

## TL;DR

- The `devtools` module provides an extensive suite of development-time diagnostic utilities intended for runtime inspection, profiling, and debugging in Lurek2D.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/devtools/`
- Lua API path(s): `src/lua_api/devtools_api.rs`
- Primary Lua namespace: `lurek.devtools`
- Rust test path(s): tests/rust/unit/devtools_tests.rs
- Lua test path(s): tests/lua/unit/test_devtools.lua; tests/lua/integration/test_devtools.lua

## Summary

 Situated within the Edge/Integration tier, this module empowers developers to analyze performance and iteratively refine game code without interrupting execution. Key among its features is the `Logger`, which provides structured, severity-leveled logging with sophisticated sink routing—allowing logs to be mirrored to in-memory bounded buffers, standard error, or append-only log files. It natively supports severity filtering and prefix-based category filtering.

For performance analysis, the `Profiler` implements a hierarchical, push/pop zone-based timing system. It captures execution durations per named scope (zone), segregating total elapsed time from exclusive 'self-time'. The data is collected on a per-frame basis and stored in a rolling frame history, facilitating deep CPU-cost inspection across consecutive frames. Working alongside the profiler is `FrameStats`, which translates raw per-frame CPU and GPU timing deltas into actionable metrics, including FPS aggregates, minimums, maximums, and percentiles.

To accelerate the development workflow, `devtools` integrates hot-reload capabilities through the `FileWatcher`. This component watches directories for changes using native operating system notification backends, triggering Lua callbacks on file creation, modification, or deletion. Additionally, the `ReplConsole` provides an interactive in-game Read-Eval-Print Loop (REPL), wrapping the release-safe core REPL to offer an integrated environment for executing Lua expressions on the fly while retaining bounded command history.

All these diagnostic tools are designed to be 'headless-safe' and lightweight, importing only core dependencies such as `runtime` and `log`. The module's comprehensive feature set is made accessible to the engine via the `lurek.devtools.*` Lua API namespace, where developers can programmatically inject logs, define profiler zones, query performance aggregates, handle file watches, and even execute Lua snippets directly within the running application.

## Source Documentation

### `frame_stats.rs`
- Collect bounded rolling history of frame-delta samples
- Compute aggregate metrics: FPS, average, min, max, and percentiles
- Produce immutable snapshots summarizing recent frame performance

### `logger.rs`
- Define ordered severity levels with case-insensitive parsing
- Store bounded in-memory log history with timestamped entries
- Filter log output by minimum severity and optional category prefix
- Mirror accepted entries to stderr and optional append-only file
- Provide tail and category query access over retained entries

### `lua_display.rs`
- Convert Lua values to human-readable text for REPL and debug display
- Handle nil, boolean, number, string, table, function, and userdata variants
- Return safe fallback labels for unrecognized value kinds

### `mod.rs`
- Aggregate frame-time statistics and FPS percentile snapshots
- Structured logging with severity filtering, file output, and history
- Hierarchical profiler with zone stacking and per-frame capture
- Interactive Lua REPL console with bounded command history
- File-watcher polling and native notify integration for hot-reload

### `profiler.rs`
- Record hierarchical profiling zones with push/pop stack semantics
- Compute total and self (exclusive) duration per zone
- Capture per-frame zone trees into bounded rolling history
- Retrieve frames by positive or negative index
- Flatten nested zone trees for aggregate reporting

### `repl.rs`
- Compatibility wrapper around the release-safe REPL core
- Preserves the devtools `ReplConsole` API and bounded history behavior
- Returns expression results, success markers, command text, or formatted error text

### `time_anchor.rs`
- Capture a monotonic instant at construction time
- Compute elapsed seconds from that anchor on demand
- Provide a shared timing primitive for logger and profiler

### `watcher.rs`
- Track watched file paths with last-observed modification timestamps
- Poll for mtime changes and report modified paths on each tick
- Integrate native notify backend when devtools-plugin feature is enabled
- Support forced-stale marking, path registration, and full clear
- Deduplicate change reports via sorted set collection

## Types

- `FrameStats` (`struct`, `frame_stats.rs`): Rolling frame-duration buffer that turns raw dt samples into actionable summary metrics. It is the module boundary between raw timing collection and interpreted frame-health reporting.
- `FrameSnapshot` (`struct`, `frame_stats.rs`): Immutable summary of the current FrameStats state. This is the structure most consumers should read instead of recalculating metrics themselves.
- `LogLevel` (`enum`, `logger.rs`): Ordered logging enum used to filter messages and present consistent severity labels to Lua and Rust callers. It is the shared language for the module's diagnostic output.
- `LogEntry` (`struct`, `logger.rs`): One captured runtime log record, including message, severity, source location, and optional category. It is the data unit exchanged between logger internals and diagnostics UIs.
- `Logger` (`struct`, `logger.rs`): In-memory logging surface with severity filtering and bounded history. It is the right place to look when runtime diagnostics need to be retained, filtered, or surfaced in tools.
- `ProfileZone` (`struct`, `profiler.rs`): One timed scope inside the profiler tree. It is useful when debugging incorrect nesting, missing pops, or self-time calculations.
- `Profiler` (`struct`, `profiler.rs`): Frame-by-frame nested timing recorder built around push or pop zones. It exists for CPU-cost inspection, not for GPU profiling or OS-level tracing.
- `ReplConsole` (`struct`, `repl.rs`): Interactive Lua REPL with a bounded input history buffer.
- `TimeAnchor` (`struct`, `time_anchor.rs`): Hold a monotonic start instant used to measure elapsed seconds.
- `FileWatcher` (`struct`, `watcher.rs`): Polling watcher for individual file paths. It is intentionally simple and should be treated as a developer convenience tool, not a full file-system event subsystem.

## Functions

- `FrameStats::new` (`frame_stats.rs`): Create frame stats with bounded capacity and return the instance.
- `FrameStats::record` (`frame_stats.rs`): Append one frame delta sample and drop oldest samples past capacity.
- `FrameStats::set_capacity` (`frame_stats.rs`): Set the sample capacity and trim stored history to the new bound.
- `FrameStats::snapshot` (`frame_stats.rs`): Compute aggregate frame metrics and return zeros when history is empty.
- `LogLevel::from_str` (`logger.rs`): Parse a case-insensitive level name and return None when unknown.
- `LogLevel::as_str` (`logger.rs`): Return the canonical lowercase level label for this severity.
- `Logger::new` (`logger.rs`): Create logger state with default filtering and retention settings.
- `Logger::elapsed` (`logger.rs`): Return elapsed time in seconds since logger construction.
- `Logger::push` (`logger.rs`): Push a log entry and return unit after filtering and retention updates.
- `Logger::tail` (`logger.rs`): Return the most recent log entries, or all entries when count is None or zero.
- `Logger::filter_category` (`logger.rs`): Return entries whose category starts with the requested prefix.
- `Logger::clear` (`logger.rs`): Remove all in-memory history entries and return unit.
- `value_to_string` (`lua_display.rs`): Convert one Lua value to display text and return a fallback for unknown kinds.
- `ProfileZone::total_time` (`profiler.rs`): Return total duration of this zone in seconds.
- `ProfileZone::self_time` (`profiler.rs`): Return exclusive duration after subtracting child zone totals.
- `ProfileZone::flatten` (`profiler.rs`): Return a flattened pre-order list containing this zone and descendants.
- `Profiler::new` (`profiler.rs`): Create profiler state with recording disabled and default retention.
- `Profiler::elapsed` (`profiler.rs`): Return elapsed time in seconds from profiler epoch.
- `Profiler::push` (`profiler.rs`): Push a zone name onto the stack when profiling is enabled.
- `Profiler::pop` (`profiler.rs`): Pop current zone and attach it to parent or temporary frame root bucket.
- `Profiler::end_frame` (`profiler.rs`): Finalize current frame zones and append them to retained frame history.
- `Profiler::get_frame` (`profiler.rs`): Return one frame by index, supporting non-positive indices from the end.
- `Profiler::reset` (`profiler.rs`): Clear active zones and stored frame history.
- `ReplConsole::new` (`repl.rs`): Create a REPL console with bounded history and return the instance.
- `ReplConsole::eval` (`repl.rs`): Evaluate input and return expression result, ok marker, or error text.
- `ReplConsole::history` (`repl.rs`): Return an immutable slice of stored history entries.
- `ReplConsole::clear` (`repl.rs`): Clear command history and return unit.
- `ReplConsole::len` (`repl.rs`): Return the number of stored history entries.
- `ReplConsole::is_empty` (`repl.rs`): Return true when history contains no entries.
- `TimeAnchor::new` (`time_anchor.rs`): Create a new anchor from the current instant and return it.
- `TimeAnchor::elapsed_seconds` (`time_anchor.rs`): Return elapsed time in seconds since this anchor was created.
- `FileWatcher::new` (`watcher.rs`): Create watcher state and return native-backed watcher when feature is enabled.
- `FileWatcher::watch` (`watcher.rs`): Start watching a path and return unit.
- `FileWatcher::unwatch` (`watcher.rs`): Stop watching a path and return true when an entry was removed.
- `FileWatcher::watched_paths` (`watcher.rs`): Return watched paths as owned strings.
- `FileWatcher::poll` (`watcher.rs`): Poll all watched paths and return changed path strings.
- `FileWatcher::clear` (`watcher.rs`): Unregister all native watches, clear tracked paths, and return unit.
- `FileWatcher::force_changed` (`watcher.rs`): Mark all watched paths as stale so next poll reports them as changed.

## Lua API Reference

- Binding path(s): `src/lua_api/devtools_api.rs`
- Namespace: `lurek.devtools`

### Module Functions
- `lurek.devtools.log`: Adds a message to the devtools log using an explicit severity level.
- `lurek.devtools.trace`: Adds a trace-level diagnostic message to the devtools log.
- `lurek.devtools.debug`: Adds a debug-level diagnostic message to the devtools log.
- `lurek.devtools.info`: Adds an info-level diagnostic message to the devtools log.
- `lurek.devtools.warn`: Adds a warning-level diagnostic message to the devtools log.
- `lurek.devtools.error`: Adds an error-level diagnostic message to the devtools log.
- `lurek.devtools.fatal`: Adds a fatal-level diagnostic message to the devtools log.
- `lurek.devtools.setLogLevel`: Sets the minimum severity that remains visible in devtools log output.
- `lurek.devtools.getLogLevel`: Returns the minimum severity currently used by devtools log output.
- `lurek.devtools.setLogConsole`: Enables or disables mirroring devtools log entries to the console.
- `lurek.devtools.getLogConsole`: Returns whether devtools log entries are mirrored to the console.
- `lurek.devtools.setLogFile`: Sets the file path used by devtools file logging state.
- `lurek.devtools.getLogFile`: Returns the file path currently stored as the devtools log target.
- `lurek.devtools.getLogHistory`: Returns recent devtools log entries as structured tables.
- `lurek.devtools.clearLog`: Clears all in-memory devtools log entries.
- `lurek.devtools.setProfilingEnabled`: Enables or disables collection of CPU profiling zones.
- `lurek.devtools.isProfilingEnabled`: Returns whether CPU profiling zone collection is currently enabled.
- `lurek.devtools.profilePush`: Starts a named profiling zone on the current profiler stack.
- `lurek.devtools.profilePop`: Ends the current profiling zone on the profiler stack.
- `lurek.devtools.profileFrame`: Closes the current profiling frame and stores its zone tree for later inspection.
- `lurek.devtools.getProfileFrameCount`: Returns how many profiling frames are currently stored.
- `lurek.devtools.getProfileData`: Returns the profiler zone tree for a retained frame.
- `lurek.devtools.resetProfile`: Clears profiler state, active zones, and retained profiling frames.
- `lurek.devtools.recordFrameTime`: Records one CPU frame duration sample for devtools frame statistics.
- `lurek.devtools.getFrameStats`: Returns aggregate CPU frame timing statistics from recorded samples.
- `lurek.devtools.recordGpuFrameTime`: Records one GPU frame duration sample for devtools frame statistics.
- `lurek.devtools.getGpuFrameStats`: Returns aggregate GPU frame timing statistics from recorded samples.
- `lurek.devtools.getFrameHistory`: Returns retained CPU frame duration samples in insertion order.
- `lurek.devtools.setFrameHistorySize`: Sets the maximum number of CPU frame duration samples retained by devtools.
- `lurek.devtools.getFrameHistorySize`: Returns the current CPU frame history capacity.
- `lurek.devtools.watch`: Adds a path to the module-level devtools file watcher.
- `lurek.devtools.unwatch`: Removes a path from the module-level devtools file watcher.
- `lurek.devtools.getWatchedPaths`: Returns all paths currently watched by the module-level file watcher.
- `lurek.devtools.scan`: Polls module-level file watches and returns paths that changed since the previous scan.
- `lurek.devtools.clearWatches`: Removes every path from the module-level file watcher.
- `lurek.devtools.getWatchInterval`: Returns the polling interval hint used by devtools watch UIs.
- `lurek.devtools.setWatchInterval`: Sets the polling interval hint used by devtools watch UIs.
- `lurek.devtools.getCallStack`: Returns Lua call stack frames using the Lua debug library.
- `lurek.devtools.eval`: Evaluates Lua code in the current state and returns success plus values or failure plus an error message.
- `lurek.devtools.openConsole`: Marks the devtools console as open for UI state tracking.
- `lurek.devtools.isConsoleOpen`: Returns whether the devtools console is marked open.
- `lurek.devtools.openEntityInspector`: Marks the devtools entity inspector as open for UI state tracking.
- `lurek.devtools.isEntityInspectorOpen`: Returns whether the devtools entity inspector is marked open.
- `lurek.devtools.exposeWatch`: Registers a watch expression callback for snapshots and watch panels.
- `lurek.devtools.removeWatch`: Removes a previously exposed watch expression by id.
- `lurek.devtools.getWatches`: Evaluates exposed watch callbacks and returns their current values.
- `lurek.devtools.snapshot`: Captures a combined devtools snapshot containing frame stats, watch values, profile data, and recent logs.
- `lurek.devtools.profilerReport`: Aggregates retained profiler frames into per-zone timing rows.
- `lurek.devtools.newFileWatcher`: Creates a dedicated file watcher userdata for one path.
- `lurek.devtools.newRepl`: Creates a REPL console userdata with bounded command history.

### `LFileWatcher` Methods
- `LFileWatcher:onChanged`: Sets the callback invoked when this watcher observes a change.
- `LFileWatcher:check`: Polls the watcher and invokes the change callback when a change is found.
- `LFileWatcher:getPath`: Returns the watched path. This method is available to Lua scripts.
- `LFileWatcher:cancel`: Cancels this watcher and removes its callback.
- `LFileWatcher:type`: Returns the Lua-visible type name for this file watcher handle.
- `LFileWatcher:typeOf`: Returns whether this file watcher handle matches a supported type name.

### `LReplConsole` Methods
- `LReplConsole:eval`: Evaluates Lua code through this REPL console and records it in history.
- `LReplConsole:history`: Returns this REPL console's recorded command history.
- `LReplConsole:clear`: Clears this REPL console's command history.
- `LReplConsole:len`: Returns the number of entries stored in this REPL console history.
- `LReplConsole:type`: Returns the Lua-visible type name for this REPL console handle.
- `LReplConsole:typeOf`: Returns whether this REPL console handle matches a supported type name.

## References

- `filesystem`: Imports or references `src/filesystem/`. Cross-group dependency from `Edge/Integration` into `Core Runtime`.
- `repl`: Imports or references `src/repl/`. Dependency stays inside `Edge/Integration` and should remain acyclic.

## Notes

- Keep this module reference synchronized with `src/devtools/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
- Release-safe interactive evaluation now lives in `src/repl/`. `devtools` keeps only the compatibility wrapper and debug-oriented Lua entry point.
