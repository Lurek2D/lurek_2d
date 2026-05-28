# Devtools

- The `devtools` module provides an extensive suite of development-time diagnostic utilities intended for runtime inspection, profiling, and debugging in Lurek2D.

Situated within the Edge/Integration tier, this module empowers developers to analyze performance and iteratively refine game code without interrupting execution. Key among its features is the `Logger`, which provides structured, severity-leveled logging with sophisticated sink routing—allowing logs to be mirrored to in-memory bounded buffers, standard error, or append-only log files. It natively supports severity filtering and prefix-based category filtering.

For performance analysis, the `Profiler` implements a hierarchical, push/pop zone-based timing system. It captures execution durations per named scope (zone), segregating total elapsed time from exclusive 'self-time'. The data is collected on a per-frame basis and stored in a rolling frame history, facilitating deep CPU-cost inspection across consecutive frames. Working alongside the profiler is `FrameStats`, which translates raw per-frame CPU and GPU timing deltas into actionable metrics, including FPS aggregates, minimums, maximums, and percentiles.

To accelerate the development workflow, `devtools` integrates hot-reload capabilities through the `FileWatcher`. This component watches directories for changes using native operating system notification backends, triggering Lua callbacks on file creation, modification, or deletion. Additionally, the `ReplConsole` provides an interactive in-game Read-Eval-Print Loop (REPL), wrapping the release-safe core REPL to offer an integrated environment for executing Lua expressions on the fly while retaining bounded command history.

All these diagnostic tools are designed to be 'headless-safe' and lightweight, importing only core dependencies such as `runtime` and `log`. The module's comprehensive feature set is made accessible to the engine via the `lurek.devtools.*` Lua API namespace, where developers can programmatically inject logs, define profiler zones, query performance aggregates, handle file watches, and even execute Lua snippets directly within the running application.

## Functions

### `lurek.devtools.clearLog`

Clears all in-memory devtools log entries.

```lua
-- signature
lurek.devtools.clearLog()
```

**Example**

```lua
do
    lurek.devtools.info("will be cleared")
    lurek.devtools.clearLog()
    print("log cleared")
end
```

---

### `lurek.devtools.clearWatches`

Removes every path from the module-level file watcher.

```lua
-- signature
lurek.devtools.clearWatches()
```

**Example**

```lua
do
    lurek.devtools.watch("content/examples/assets/layouts/sample_menu.html")
    lurek.devtools.clearWatches()
    print("watches cleared, count = " .. #lurek.devtools.getWatchedPaths())
end
```

---

### `lurek.devtools.debug`

Adds a debug-level diagnostic message to the devtools log.

```lua
-- signature
lurek.devtools.debug(message)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `message` | `string` | Message text stored in the in-memory log history. |

**Example**

```lua
do
    lurek.devtools.debug("player pos = 100, 200")
    print("debug logged")
end
```

---

### `lurek.devtools.error`

Adds an error-level diagnostic message to the devtools log.

```lua
-- signature
lurek.devtools.error(message)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `message` | `string` | Message text stored in the in-memory log history. |

**Example**

```lua
do
    lurek.devtools.error("save file warning emitted")
    print("error logged")
end
```

---

### `lurek.devtools.eval`

Evaluates Lua code in the current state and returns success plus values or failure plus an error message.

```lua
-- signature
lurek.devtools.eval(code)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `code` | `string` | Lua source code evaluated through the current Lua VM. |

**Returns**

| Type | Description |
|------|-------------|
| `LuaValue` | Multi-return where the first value is a boolean success flag followed by result values or an error string. |

**Example**

```lua
do
    local ok, value = lurek.devtools.eval("return 2 + 2")
    print("eval ok = " .. tostring(ok))
    print("eval value = " .. tostring(value))
end
```

---

### `lurek.devtools.exposeWatch`

Registers a watch expression callback for snapshots and watch panels.

```lua
-- signature
lurek.devtools.exposeWatch(name, getter, category)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Display name for the watch entry. |
| `getter` | `function` | Callback invoked with no arguments when watch values are collected. |
| `category?` | `string` | Optional category label used by devtools UIs. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Numeric watch id that can be passed to `removeWatch`. |

**Example**

```lua
do
    local id = lurek.devtools.exposeWatch("health", function() return 100 end, "player")
    print("watch id = " .. id)
end
```

---

### `lurek.devtools.fatal`

Adds a fatal-level diagnostic message to the devtools log.

```lua
-- signature
lurek.devtools.fatal(message)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `message` | `string` | Message text stored in the in-memory log history. |

**Example**

```lua
do
    lurek.devtools.fatal("unrecoverable GPU error")
    print("fatal logged")
end
```

---

### `lurek.devtools.getCallStack`

Returns Lua call stack frames using the Lua debug library.

```lua
-- signature
lurek.devtools.getCallStack(max_depth)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `max_depth?` | `number` | Optional maximum number of frames to return; defaults to 20 and is capped at 100. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Array of frame tables; each has source (string), line (integer), name (string), and what (string) fields. |

**Example**

```lua
do
    local frames = lurek.devtools.getCallStack(5)
    print("stack frames = " .. #frames)
end
```

---

### `lurek.devtools.getFrameHistory`

Returns retained CPU frame duration samples in insertion order.

```lua
-- signature
lurek.devtools.getFrameHistory()
```

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Array table of CPU frame durations in seconds. |

**Example**

```lua
do
    lurek.devtools.recordFrameTime(0.016)
    local h = lurek.devtools.getFrameHistory()
    print("history count = " .. #h)
end
```

---

### `lurek.devtools.getFrameHistorySize`

Returns the current CPU frame history capacity.

```lua
-- signature
lurek.devtools.getFrameHistorySize()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Maximum number of retained CPU frame duration samples. |

**Example**

```lua
do
    local n = lurek.devtools.getFrameHistorySize()
    print("history capacity = " .. n)
end
```

---

### `lurek.devtools.getFrameStats`

Returns aggregate CPU frame timing statistics from recorded samples.

```lua
-- signature
lurek.devtools.getFrameStats()
```

**Returns**

| Type | Description |
|------|-------------|
| `DevtoolsGetFrameStatsResult` | Table containing fps, dt, avg, min, max, p50, p95, p99, and samples fields. |

**Example**

```lua
do
    lurek.devtools.recordFrameTime(0.016)
    lurek.devtools.recordFrameTime(0.018)
    local stats = lurek.devtools.getFrameStats()
    print("fps = " .. tostring(stats.fps))
    print("samples = " .. tostring(stats.samples))
end
```

---

### `lurek.devtools.getGpuFrameStats`

Returns aggregate GPU frame timing statistics from recorded samples.

```lua
-- signature
lurek.devtools.getGpuFrameStats()
```

**Returns**

| Type | Description |
|------|-------------|
| `DevtoolsGetGpuFrameStatsResult` | Table containing fps, dt, avg, min, max, p50, p95, p99, and samples fields. |

**Example**

```lua
do
    lurek.devtools.recordGpuFrameTime(0.008)
    lurek.devtools.recordGpuFrameTime(0.009)
    local stats = lurek.devtools.getGpuFrameStats()
    print("gpu fps = " .. tostring(stats.fps))
    print("gpu samples = " .. tostring(stats.samples))
end
```

---

### `lurek.devtools.getLogConsole`

Returns whether devtools log entries are mirrored to the console.

```lua
-- signature
lurek.devtools.getLogConsole()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when console logging is enabled. |

**Example**

```lua
do
    local console = lurek.devtools.getLogConsole()
    print("console = " .. tostring(console))
end
```

---

### `lurek.devtools.getLogFile`

Returns the file path currently stored as the devtools log target.

```lua
-- signature
lurek.devtools.getLogFile()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Current log file path. |

**Example**

```lua
do
    local fp = lurek.devtools.getLogFile()
    print("log file = " .. fp)
end
```

---

### `lurek.devtools.getLogHistory`

Returns recent devtools log entries as structured tables.

```lua
-- signature
lurek.devtools.getLogHistory(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count?` | `number` | Optional number of newest entries to return; omitted returns the logger default. |

**Returns**

| Type | Description |
|------|-------------|
| `DevtoolsGetLogHistoryResult` | Array table containing level, timestamp, message, source, line, and optional category fields. |

**Example**

```lua
do
    lurek.devtools.info("test entry")
    local entries = lurek.devtools.getLogHistory(5)
    print("log entries = " .. #entries)
end
```

---

### `lurek.devtools.getLogLevel`

Returns the minimum severity currently used by devtools log output.

```lua
-- signature
lurek.devtools.getLogLevel()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Current minimum log level name. |

**Example**

```lua
do
    local level = lurek.devtools.getLogLevel()
    print("log level = " .. level)
end
```

---

### `lurek.devtools.getProfileData`

Returns the profiler zone tree for a retained frame.

```lua
-- signature
lurek.devtools.getProfileData(frame)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `frame?` | `number` | Optional frame index understood by the profiler; omitted reads the newest frame alias used by the backend. |

**Returns**

| Type | Description |
|------|-------------|
| `DevtoolsGetProfileDataResult` | Array of profiler zones with name, time, selfTime, startTime, and children fields. |

**Example**

```lua
do
    lurek.devtools.setProfilingEnabled(true)
    lurek.devtools.profilePush("update")
    lurek.devtools.profilePop()
    lurek.devtools.profileFrame()
    local frames = lurek.devtools.getProfileData()
    print("profile rows = " .. #frames)
    if frames[1] then
        print("first zone = " .. tostring(frames[1].name))
    end
end
```

---

### `lurek.devtools.getProfileFrameCount`

Returns how many profiling frames are currently stored.

```lua
-- signature
lurek.devtools.getProfileFrameCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Number of retained profiler frames. |

**Example**

```lua
do
    local n = lurek.devtools.getProfileFrameCount()
    print("profile frames = " .. n)
end
```

---

### `lurek.devtools.getWatchInterval`

Returns the polling interval hint used by devtools watch UIs.

```lua
-- signature
lurek.devtools.getWatchInterval()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Watch interval in seconds. |

**Example**

```lua
do
    local v = lurek.devtools.getWatchInterval()
    print("interval = " .. v)
end
```

---

### `lurek.devtools.getWatchedPaths`

Returns all paths currently watched by the module-level file watcher.

```lua
-- signature
lurek.devtools.getWatchedPaths()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Sorted array table of watched path strings. |

**Example**

```lua
do
    lurek.devtools.watch("content/examples/assets/images")
    local paths = lurek.devtools.getWatchedPaths()
    print("watched = " .. #paths)
end
```

---

### `lurek.devtools.getWatches`

Evaluates exposed watch callbacks and returns their current values.

```lua
-- signature
lurek.devtools.getWatches()
```

**Returns**

| Type | Description |
|------|-------------|
| `DevtoolsGetWatchesResult` | Array of watch rows with name, category, and value fields. |

**Example**

```lua
do
    lurek.devtools.exposeWatch("score", function() return 42 end)
    local watches = lurek.devtools.getWatches()
    print("watch entries = " .. #watches)
end
```

---

### `lurek.devtools.info`

Adds an info-level diagnostic message to the devtools log.

```lua
-- signature
lurek.devtools.info(message)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `message` | `string` | Message text stored in the in-memory log history. |

**Example**

```lua
do
    lurek.devtools.info("level loaded")
    print("info logged")
end
```

---

### `lurek.devtools.isConsoleOpen`

Returns whether the devtools console is marked open.

```lua
-- signature
lurek.devtools.isConsoleOpen()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the console-open flag is set. |

**Example**

```lua
do
    local v = lurek.devtools.isConsoleOpen()
    print("console open = " .. tostring(v))
end
```

---

### `lurek.devtools.isEntityInspectorOpen`

Returns whether the devtools entity inspector is marked open.

```lua
-- signature
lurek.devtools.isEntityInspectorOpen()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the entity-inspector-open flag is set. |

**Example**

```lua
do
    local v = lurek.devtools.isEntityInspectorOpen()
    print("inspector open = " .. tostring(v))
end
```

---

### `lurek.devtools.isProfilingEnabled`

Returns whether CPU profiling zone collection is currently enabled.

```lua
-- signature
lurek.devtools.isProfilingEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when profiler recording is enabled. |

**Example**

```lua
do
    local v = lurek.devtools.isProfilingEnabled()
    print("profiling = " .. tostring(v))
end
```

---

### `lurek.devtools.log`

Adds a message to the devtools log using an explicit severity level.

```lua
-- signature
lurek.devtools.log(level, message)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `level` | `string` | Log level name such as `trace`, `debug`, `info`, `warn`, `error`, or `fatal`. |
| `message` | `string` | Message text stored in the in-memory log history. |

**Example**

```lua
do
    lurek.devtools.log("info", "game started")
    print("logged info message")
end
```

---

### `lurek.devtools.newFileWatcher`

Creates a dedicated file watcher userdata for one path.

```lua
-- signature
lurek.devtools.newFileWatcher(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | File or directory path watched by the returned handle. |

**Returns**

| Type | Description |
|------|-------------|
| `LFileWatcher` | File watcher handle with polling and callback methods. |

**Example**

```lua
do
    local watcher = lurek.devtools.newFileWatcher("content/")
    print("watcher path = " .. watcher:getPath())
end
```

---

### `lurek.devtools.newRepl`

Creates a REPL console userdata with bounded command history.

```lua
-- signature
lurek.devtools.newRepl(max_history)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `max_history?` | `number` | Optional maximum number of history entries; defaults to 200. |

**Returns**

| Type | Description |
|------|-------------|
| `LReplConsole` | REPL console handle for eval and history management. |

**Example**

```lua
do
    local repl = lurek.devtools.newRepl(50)
    repl:eval("return 5 * 5")
    print("repl type = " .. repl:type())
    print("history len = " .. repl:len())
end
```

---

### `lurek.devtools.openConsole`

Marks the devtools console as open for UI state tracking.

```lua
-- signature
lurek.devtools.openConsole()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | Always returns true after setting the console-open flag. |

**Example**

```lua
do
    local ok = lurek.devtools.openConsole()
    print("console opened = " .. tostring(ok))
end
```

---

### `lurek.devtools.openEntityInspector`

Marks the devtools entity inspector as open for UI state tracking.

```lua
-- signature
lurek.devtools.openEntityInspector()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | Always returns true after setting the entity-inspector flag. |

**Example**

```lua
do
    local ok = lurek.devtools.openEntityInspector()
    print("inspector opened = " .. tostring(ok))
end
```

---

### `lurek.devtools.profileFrame`

Closes the current profiling frame and stores its zone tree for later inspection.

```lua
-- signature
lurek.devtools.profileFrame()
```

**Example**

```lua
do
    lurek.devtools.setProfilingEnabled(true)
    lurek.devtools.profilePush("update")
    lurek.devtools.profilePop()
    lurek.devtools.profileFrame()
    print("frame stored")
end
```

---

### `lurek.devtools.profilePop`

Ends the current profiling zone on the profiler stack.

```lua
-- signature
lurek.devtools.profilePop(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name?` | `string` | Optional zone name accepted for API compatibility and ignored by the profiler. |

**Example**

```lua
do
    lurek.devtools.setProfilingEnabled(true)
    lurek.devtools.profilePush("render")
    lurek.devtools.profilePop()
    print("popped render zone")
end
```

---

### `lurek.devtools.profilePush`

Starts a named profiling zone on the current profiler stack.

```lua
-- signature
lurek.devtools.profilePush(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Profiling zone name shown in reports and snapshots. |

**Example**

```lua
do
    lurek.devtools.setProfilingEnabled(true)
    lurek.devtools.profilePush("physics")
    print("pushed physics zone")
end
```

---

### `lurek.devtools.profilerReport`

Aggregates retained profiler frames into per-zone timing rows.

```lua
-- signature
lurek.devtools.profilerReport()
```

**Returns**

| Type | Description |
|------|-------------|
| `DevtoolsProfilerReportResult` | Array table with zone name, call count, total_ms, avg_ms, min_ms, max_ms, and self_ms fields. |

**Example**

```lua
do
    lurek.devtools.setProfilingEnabled(true)
    lurek.devtools.profilePush("render")
    lurek.devtools.profilePop()
    lurek.devtools.profileFrame()
    local report = lurek.devtools.profilerReport()
    print("report rows = " .. #report)
    if report[1] then
        print("first report zone = " .. tostring(report[1].name))
    end
end
```

---

### `lurek.devtools.recordFrameTime`

Records one CPU frame duration sample for devtools frame statistics.

```lua
-- signature
lurek.devtools.recordFrameTime(dt_val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt_val` | `number` | Frame duration in seconds. |

**Example**

```lua
do
    lurek.devtools.recordFrameTime(0.016)
    lurek.devtools.recordFrameTime(0.017)
    print("frame times recorded")
end
```

---

### `lurek.devtools.recordGpuFrameTime`

Records one GPU frame duration sample for devtools frame statistics.

```lua
-- signature
lurek.devtools.recordGpuFrameTime(dt_val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt_val` | `number` | GPU frame duration in seconds. |

**Example**

```lua
do
    lurek.devtools.recordGpuFrameTime(0.008)
    print("gpu frame time recorded")
end
```

---

### `lurek.devtools.removeWatch`

Removes a previously exposed watch expression by id.

```lua
-- signature
lurek.devtools.removeWatch(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Watch id returned by `exposeWatch`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when a watch entry was removed. |

**Example**

```lua
do
    local id = lurek.devtools.exposeWatch("temp", function() return 0 end)
    local ok = lurek.devtools.removeWatch(id)
    print("removed = " .. tostring(ok))
end
```

---

### `lurek.devtools.resetProfile`

Clears profiler state, active zones, and retained profiling frames.

```lua
-- signature
lurek.devtools.resetProfile()
```

**Example**

```lua
do
    lurek.devtools.resetProfile()
    print("profile reset, frames = " .. lurek.devtools.getProfileFrameCount())
end
```

---

### `lurek.devtools.scan`

Polls module-level file watches and returns paths that changed since the previous scan.

```lua
-- signature
lurek.devtools.scan()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Changed path strings. |

**Example**

```lua
do
    lurek.devtools.watch("content/examples/assets/layouts/sample_menu.html")
    local changed = lurek.devtools.scan()
    print("changed files = " .. #changed)
    print("watched paths = " .. #lurek.devtools.getWatchedPaths())
end
```

---

### `lurek.devtools.setFrameHistorySize`

Sets the maximum number of CPU frame duration samples retained by devtools.

```lua
-- signature
lurek.devtools.setFrameHistorySize(size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `size` | `number` | Maximum number of frame samples to keep. |

**Example**

```lua
do
    lurek.devtools.setFrameHistorySize(120)
    print("history size set to 120")
end
```

---

### `lurek.devtools.setLogConsole`

Enables or disables mirroring devtools log entries to the console.

```lua
-- signature
lurek.devtools.setLogConsole(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | `boolean` | True to emit future log entries to console output. |

**Example**

```lua
do
    lurek.devtools.setLogConsole(true)
    print("console logging enabled")
end
```

---

### `lurek.devtools.setLogFile`

Sets the file path used by devtools file logging state.

```lua
-- signature
lurek.devtools.setLogFile(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | File path recorded as the active devtools log target. |

**Example**

```lua
do
    lurek.devtools.setLogFile("logs/devtools.log")
    print("log file set")
end
```

---

### `lurek.devtools.setLogLevel`

Sets the minimum severity that remains visible in devtools log output.

```lua
-- signature
lurek.devtools.setLogLevel(level)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `level` | `string` | Log level name parsed by the devtools logger; unknown names are ignored. |

**Example**

```lua
do
    lurek.devtools.setLogLevel("warn")
    print("log level set to warn")
end
```

---

### `lurek.devtools.setProfilingEnabled`

Enables or disables collection of CPU profiling zones.

```lua
-- signature
lurek.devtools.setProfilingEnabled(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | `boolean` | True to record profiling zones into future profiler frames. |

**Example**

```lua
do
    lurek.devtools.setProfilingEnabled(true)
    print("profiling enabled")
end
```

---

### `lurek.devtools.setWatchInterval`

Sets the polling interval hint used by devtools watch UIs.

```lua
-- signature
lurek.devtools.setWatchInterval(interval)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `interval` | `number` | Watch interval in seconds, clamped to at least 0.01. |

**Example**

```lua
do
    lurek.devtools.setWatchInterval(0.5)
    print("interval set to 0.5s")
end
```

---

### `lurek.devtools.snapshot`

Captures a combined devtools snapshot containing frame stats, watch values, profile data, and recent logs.

```lua
-- signature
lurek.devtools.snapshot()
```

**Returns**

| Type | Description |
|------|-------------|
| `DevtoolsSnapshotResult` | Snapshot table with frameStats, watches, profile, log, and watchCount fields. |

**Example**

```lua
do
    lurek.devtools.recordFrameTime(0.016)
    lurek.devtools.info("snapshot ready")
    lurek.devtools.exposeWatch("score", function()
        return 42
    end, "hud")
    local snap = lurek.devtools.snapshot()
    print("watch count = " .. tostring(snap.watchCount))
    print("log rows = " .. tostring(#snap.log))
end
```

---

### `lurek.devtools.trace`

Adds a trace-level diagnostic message to the devtools log.

```lua
-- signature
lurek.devtools.trace(message)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `message` | `string` | Message text stored in the in-memory log history. |

**Example**

```lua
do
    lurek.devtools.trace("entering update loop")
    print("trace logged")
end
```

---

### `lurek.devtools.unwatch`

Removes a path from the module-level devtools file watcher.

```lua
-- signature
lurek.devtools.unwatch(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | Previously watched file or directory path. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the path was removed. |

**Example**

```lua
do
    lurek.devtools.watch("content/examples/assets/layouts/sample_menu.html")
    local removed = lurek.devtools.unwatch("content/examples/assets/layouts/sample_menu.html")
    print("removed = " .. tostring(removed))
end
```

---

### `lurek.devtools.warn`

Adds a warning-level diagnostic message to the devtools log.

```lua
-- signature
lurek.devtools.warn(message)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `message` | `string` | Message text stored in the in-memory log history. |

**Example**

```lua
do
    lurek.devtools.warn("texture missing fallback used")
    print("warn logged")
end
```

---

### `lurek.devtools.watch`

Adds a path to the module-level devtools file watcher.

```lua
-- signature
lurek.devtools.watch(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | File or directory path to poll for changes. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the path was newly added; false when it was already watched. |

**Example**

```lua
do
    local added = lurek.devtools.watch("content/examples/assets/layouts/sample_menu.html")
    print("watch added = " .. tostring(added))
end
```

---

## LFileWatcher

### `LFileWatcher:cancel`

Cancels this watcher and removes its callback.

```lua
-- signature
LFileWatcher:cancel()
```

**Example**

```lua
do
    local watcher = lurek.devtools.newFileWatcher("save/")
    watcher:cancel()
    print("watcher cancelled")
end
```

---

### `LFileWatcher:check`

Polls the watcher and invokes the change callback when a change is found.

```lua
-- signature
LFileWatcher:check()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when at least one change was detected. |

**Example**

```lua
do
    local watcher = lurek.devtools.newFileWatcher("content/")
    local changed = watcher:check()
    print("change detected = " .. tostring(changed))
end
```

---

### `LFileWatcher:getPath`

Returns the watched path. This method is available to Lua scripts.

```lua
-- signature
LFileWatcher:getPath()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Watched path string. |

**Example**

```lua
do
    local watcher = lurek.devtools.newFileWatcher("content/")
    print("watching = " .. watcher:getPath())
end
```

---

### `LFileWatcher:onChanged`

Sets the callback invoked when this watcher observes a change.

```lua
-- signature
LFileWatcher:onChanged(func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `func` | `function` | Callback called with no arguments after a change is detected. |

**Example**

```lua
do
    local watcher = lurek.devtools.newFileWatcher("assets/")
    watcher:onChanged(function()
        print("file changed!")
    end)
    print("onChange callback set")
end
```

---

### `LFileWatcher:type`

Returns the Lua-visible type name for this file watcher handle.

```lua
-- signature
LFileWatcher:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LFileWatcher`. |

**Example**

```lua
do
    local watcher = lurek.devtools.newFileWatcher("assets/")
    print("type = " .. watcher:type())
end
```

---

### `LFileWatcher:typeOf`

Returns whether this file watcher handle matches a supported type name.

```lua
-- signature
LFileWatcher:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LFileWatcher` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local watcher = lurek.devtools.newFileWatcher("assets/textures/")
    print("is LFileWatcher = " .. tostring(watcher:typeOf("LFileWatcher")))
end
```

---

## LReplConsole

### `LReplConsole:clear`

Clears this REPL console's command history.

```lua
-- signature
LReplConsole:clear()
```

**Example**

```lua
do
    local repl = lurek.devtools.newRepl(100)
    repl:eval("print('hi')")
    repl:clear()
    print("history after clear = " .. repl:len())
end
```

---

### `LReplConsole:eval`

Evaluates Lua code through this REPL console and records it in history.

```lua
-- signature
LReplConsole:eval(code)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `code` | `string` | Lua source code evaluated in the active Lua VM. |

**Returns**

| Type | Description |
|------|-------------|
| `LuaValue` | Evaluation result shape produced by the devtools REPL backend. |

**Example**

```lua
do
    local repl = lurek.devtools.newRepl(100)
    local result = repl:eval("return 1 + 1")
    print("eval result type = " .. type(result))
    print("history len = " .. repl:len())
end
```

---

### `LReplConsole:history`

Returns this REPL console's recorded command history.

```lua
-- signature
LReplConsole:history()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | History entry strings. |

**Example**

```lua
do
    local repl = lurek.devtools.newRepl(100)
    repl:eval("local x = 1")
    repl:eval("local y = 2")
    local h = repl:history()
    print("history entries = " .. #h)
end
```

---

### `LReplConsole:len`

Returns the number of entries stored in this REPL console history.

```lua
-- signature
LReplConsole:len()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | History entry count. |

**Example**

```lua
do
    local repl = lurek.devtools.newRepl(100)
    repl:eval("a = 1")
    repl:eval("b = 2")
    print("history len = " .. repl:len())
end
```

---

### `LReplConsole:type`

Returns the Lua-visible type name for this REPL console handle.

```lua
-- signature
LReplConsole:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LReplConsole`. |

**Example**

```lua
do
    local repl = lurek.devtools.newRepl()
    print("type = " .. repl:type())
end
```

---

### `LReplConsole:typeOf`

Returns whether this REPL console handle matches a supported type name.

```lua
-- signature
LReplConsole:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LReplConsole` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local repl = lurek.devtools.newRepl()
    print("is LReplConsole = " .. tostring(repl:typeOf("LReplConsole")))
end
```

---
