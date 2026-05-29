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

The `devtools` module aggregates developer-facing runtime instrumentation: frame statistics, structured logging, hierarchical profiling, REPL interaction, and file-watcher support. It is an operational toolkit for diagnosis and iteration, not a gameplay feature module.

Each submodule owns a clear diagnostic surface: `frame_stats` for timing snapshots and aggregates, `logger` for filtered message capture, `profiler` for nested timing zones, `repl` for interactive scripting flows, `watcher` for file-change tracking, and `time_anchor` for stable elapsed-time references. `lua_display` normalizes value formatting for user-visible debug output.

The design goal is composable instrumentation with minimal disruption to runtime behavior. Tools should be callable from scripting and runtime integration points without introducing tight coupling to specific game systems.

As an Edge/Integration module, it should preserve clear contracts for output structure, history bounds, and performance overhead, so diagnostics remain useful under both local iteration and automated quality checks.

Implementation detail and boundary guarantees for devtools: this module keeps responsibilities explicit across source files so behavior remains inspectable during refactors. The current source map is: frame_stats.rs: Collect bounded rolling history of frame-delta samples - Compute aggregate metrics: FPS, average, min, max, and percentiles - Produce immutable snapshots summarizing recent frame performance; logger.rs: Define ordered severity levels with case-insensitive parsing - Store bounded in-memory log history with timestamped entries - Filter log output by minimum severity and optional category prefix - Mirror accepted entries to stderr and optional append-only file - Provide tail and ca; lua_display.rs: Convert Lua values to human-readable text for REPL and debug display - Handle nil, boolean, number, string, table, function, and userdata variants - Return safe fallback labels for unrecognized value kinds; mod.rs: Aggregate frame-time statistics and FPS percentile snapshots - Structured logging with severity filtering, file output, and history - Hierarchical profiler with zone stacking and per-frame capture - Interactive Lua REPL console with bounded command history - File-watcher polling; profiler.rs: Record hierarchical profiling zones with push/pop stack semantics - Compute total and self (exclusive) duration per zone - Capture per-frame zone trees into bounded rolling history - Retrieve frames by positive or negative index - Flatten nested zone trees for aggregate reporting; repl.rs: Compatibility wrapper around the release-safe REPL core - Preserves the devtools ReplConsole API and bounded history behavior - Returns expression results, success markers, command text, or formatted error text; time_anchor.rs: Capture a monotonic instant at construction time - Compute elapsed seconds from that anchor on demand - Provide a shared timing primitive for logger and profiler; watcher.rs: Track watched file paths with last-observed modification timestamps - Poll for mtime changes and report modified paths on each tick - Integrate native notify backend when devtools-plugin feature is enabled - Support forced-stale marking, path registration, and full clear - Dedupl. This split is part of the contract: orchestration stays in composition points, data models stay in type-centric files, and adapters stay in bridge files. That separation reduces hidden coupling, improves testability, and keeps Lua API surfaces aligned with Rust runtime semantics. For maintainers, the key guarantee is that high-level APIs should keep delegating into scoped internals instead of collapsing into a single large entry point. Future extensions should preserve explicit dependency direction and documented invariants near owning types and functions.

## Files

### frame_stats.rs

- Collect bounded rolling history of frame-delta samples
- Compute aggregate metrics: FPS, average, min, max, and percentiles
- Produce immutable snapshots summarizing recent frame performance

### logger.rs

- Define ordered severity levels with case-insensitive parsing
- Store bounded in-memory log history with timestamped entries
- Filter log output by minimum severity and optional category prefix
- Mirror accepted entries to stderr and optional append-only file
- Provide tail and category query access over retained entries

### lua_display.rs

- Convert Lua values to human-readable text for REPL and debug display
- Handle nil, boolean, number, string, table, function, and userdata variants
- Return safe fallback labels for unrecognized value kinds

### mod.rs

- Aggregate frame-time statistics and FPS percentile snapshots
- Structured logging with severity filtering, file output, and history
- Hierarchical profiler with zone stacking and per-frame capture
- Interactive Lua REPL console with bounded command history
- File-watcher polling and native notify integration for hot-reload

### profiler.rs

- Record hierarchical profiling zones with push/pop stack semantics
- Compute total and self (exclusive) duration per zone
- Capture per-frame zone trees into bounded rolling history
- Retrieve frames by positive or negative index
- Flatten nested zone trees for aggregate reporting

### repl.rs

- Compatibility wrapper around the release-safe REPL core
- Preserves the devtools `ReplConsole` API and bounded history behavior
- Returns expression results, success markers, command text, or formatted error text

### time_anchor.rs

- Capture a monotonic instant at construction time
- Compute elapsed seconds from that anchor on demand
- Provide a shared timing primitive for logger and profiler

### watcher.rs

- Track watched file paths with last-observed modification timestamps
- Poll for mtime changes and report modified paths on each tick
- Integrate native notify backend when devtools-plugin feature is enabled
- Support forced-stale marking, path registration, and full clear
- Deduplicate change reports via sorted set collection

## Lua API Ref

- Binding: `src/lua_api/devtools_api.rs`
- Namespace: `lurek.devtools`

### Functions

- `lurek.devtools.clearLog`: Clears all in-memory devtools log entries.
- `lurek.devtools.clearWatches`: Removes every path from the module-level file watcher.
- `lurek.devtools.debug`: Adds a debug-level diagnostic message to the devtools log.
- `lurek.devtools.error`: Adds an error-level diagnostic message to the devtools log.
- `lurek.devtools.eval`: Evaluates Lua code in the current state and returns success plus values or failure plus an error message.
- `lurek.devtools.exposeWatch`: Registers a watch expression callback for snapshots and watch panels.
- `lurek.devtools.fatal`: Adds a fatal-level diagnostic message to the devtools log.
- `lurek.devtools.getCallStack`: Returns Lua call stack frames using the Lua debug library.
- `lurek.devtools.getFrameHistory`: Returns retained CPU frame duration samples in insertion order.
- `lurek.devtools.getFrameHistorySize`: Returns the current CPU frame history capacity.
- `lurek.devtools.getFrameStats`: Returns aggregate CPU frame timing statistics from recorded samples.
- `lurek.devtools.getGpuFrameStats`: Returns aggregate GPU frame timing statistics from recorded samples.
- `lurek.devtools.getLogConsole`: Returns whether devtools log entries are mirrored to the console.
- `lurek.devtools.getLogFile`: Returns the file path currently stored as the devtools log target.
- `lurek.devtools.getLogHistory`: Returns recent devtools log entries as structured tables.
- `lurek.devtools.getLogLevel`: Returns the minimum severity currently used by devtools log output.
- `lurek.devtools.getProfileData`: Returns the profiler zone tree for a retained frame.
- `lurek.devtools.getProfileFrameCount`: Returns how many profiling frames are currently stored.
- `lurek.devtools.getWatchInterval`: Returns the polling interval hint used by devtools watch UIs.
- `lurek.devtools.getWatchedPaths`: Returns all paths currently watched by the module-level file watcher.
- `lurek.devtools.getWatches`: Evaluates exposed watch callbacks and returns their current values.
- `lurek.devtools.info`: Adds an info-level diagnostic message to the devtools log.
- `lurek.devtools.isConsoleOpen`: Returns whether the devtools console is marked open.
- `lurek.devtools.isEntityInspectorOpen`: Returns whether the devtools entity inspector is marked open.
- `lurek.devtools.isProfilingEnabled`: Returns whether CPU profiling zone collection is currently enabled.
- `lurek.devtools.log`: Adds a message to the devtools log using an explicit severity level.
- `lurek.devtools.newFileWatcher`: Creates a dedicated file watcher userdata for one path.
- `lurek.devtools.newRepl`: Creates a REPL console userdata with bounded command history.
- `lurek.devtools.openConsole`: Marks the devtools console as open for UI state tracking.
- `lurek.devtools.openEntityInspector`: Marks the devtools entity inspector as open for UI state tracking.
- `lurek.devtools.profileFrame`: Closes the current profiling frame and stores its zone tree for later inspection.
- `lurek.devtools.profilePop`: Ends the current profiling zone on the profiler stack.
- `lurek.devtools.profilePush`: Starts a named profiling zone on the current profiler stack.
- `lurek.devtools.profilerReport`: Aggregates retained profiler frames into per-zone timing rows.
- `lurek.devtools.recordFrameTime`: Records one CPU frame duration sample for devtools frame statistics.
- `lurek.devtools.recordGpuFrameTime`: Records one GPU frame duration sample for devtools frame statistics.
- `lurek.devtools.removeWatch`: Removes a previously exposed watch expression by id.
- `lurek.devtools.resetProfile`: Clears profiler state, active zones, and retained profiling frames.
- `lurek.devtools.scan`: Polls module-level file watches and returns paths that changed since the previous scan.
- `lurek.devtools.setFrameHistorySize`: Sets the maximum number of CPU frame duration samples retained by devtools.
- `lurek.devtools.setLogConsole`: Enables or disables mirroring devtools log entries to the console.
- `lurek.devtools.setLogFile`: Sets the file path used by devtools file logging state.
- `lurek.devtools.setLogLevel`: Sets the minimum severity that remains visible in devtools log output.
- `lurek.devtools.setProfilingEnabled`: Enables or disables collection of CPU profiling zones.
- `lurek.devtools.setWatchInterval`: Sets the polling interval hint used by devtools watch UIs.
- `lurek.devtools.snapshot`: Captures a combined devtools snapshot containing frame stats, watch values, profile data, and recent logs.
- `lurek.devtools.trace`: Adds a trace-level diagnostic message to the devtools log.
- `lurek.devtools.unwatch`: Removes a path from the module-level devtools file watcher.
- `lurek.devtools.warn`: Adds a warning-level diagnostic message to the devtools log.
- `lurek.devtools.watch`: Adds a path to the module-level devtools file watcher.

### Enums

- No documented module-level enums/constants.

### Types


#### LFileWatcher Type


##### Fields

- No documented fields.

##### Methods

- `LFileWatcher:cancel`: Cancels this watcher and removes its callback.
- `LFileWatcher:check`: Polls the watcher and invokes the change callback when a change is found.
- `LFileWatcher:getPath`: Returns the watched path. This method is available to Lua scripts.
- `LFileWatcher:onChanged`: Sets the callback invoked when this watcher observes a change.
- `LFileWatcher:type`: Returns the Lua-visible type name for this file watcher handle.
- `LFileWatcher:typeOf`: Returns whether this file watcher handle matches a supported type name.


#### LReplConsole Type


##### Fields

- No documented fields.

##### Methods

- `LReplConsole:clear`: Clears this REPL console's command history.
- `LReplConsole:eval`: Evaluates Lua code through this REPL console and records it in history.
- `LReplConsole:history`: Returns this REPL console's recorded command history.
- `LReplConsole:len`: Returns the number of entries stored in this REPL console history.
- `LReplConsole:type`: Returns the Lua-visible type name for this REPL console handle.
- `LReplConsole:typeOf`: Returns whether this REPL console handle matches a supported type name.

## References

- `filesystem`: Imports or references `src/filesystem/`. Cross-group dependency from `Edge/Integration` into `Core Runtime`.
- `repl`: Imports or references `src/repl/`. Dependency stays inside `Edge/Integration` and should remain acyclic.
