# Devtools

## Purpose

Gathers hardware frame stats and runs a hierarchical zone profiler. - Integrates structured logs, REPL evaluation, and live file watching.

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

## API Reference

- This page is the generated API reference for this module.

## Functions

### `lurek.devtools.clearLog`

Clears all in-memory devtools log entries.

```lua
lurek.devtools.clearLog()
```

**Example**

```lua
do

    lurek.log.clearSinks()
    local sink = lurek.log.addSink({
        type = "memory",
        level = "debug",
        capacity = 8,
        tags = { "Devtools" },
    })
    lurek.devtools.info("will be cleared")
    local beforeClear = lurek.devtools.getLogHistory()
    lurek.devtools.clearLog()
    local afterClear = lurek.devtools.getLogHistory()
    local shared = lurek.log.readMemory(sink, false)
    lurek.log.info("log rows before clear=" .. tostring(#beforeClear))
    lurek.log.info("log rows after clear=" .. tostring(#afterClear))
    lurek.log.info("shared sink rows after clear=" .. tostring(#shared))
end
```

---

### `lurek.devtools.clearWatches`

Removes every path from the module-level file watcher.

```lua
lurek.devtools.clearWatches()
```

**Example**

```lua
do

    lurek.devtools.watch("content/examples/assets/layouts/sample_main_menu.toml")
    local beforeClear = lurek.devtools.getWatchedPaths()
    lurek.devtools.clearWatches()
    local afterClear = lurek.devtools.getWatchedPaths()
    lurek.log.info("watched paths before clear=" .. tostring(#beforeClear))
    lurek.log.info("watched paths after clear=" .. tostring(#afterClear))
end
```

---

### `lurek.devtools.debug`

Adds a debug-level diagnostic message to the devtools log.

```lua
lurek.devtools.debug(message)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `message` | string | Message text stored in the in-memory log history. |

**Example**

```lua
do

    lurek.devtools.debug("player pos = 100, 200")
    lurek.devtools.debug("camera follow target = player_1")
    local level = lurek.devtools.getLogLevel()
    local history = lurek.devtools.getLogHistory(2)
    lurek.log.info("debug level gate=" .. tostring(level))
    lurek.log.info("debug history rows=" .. tostring(#history))
end
```

---

### `lurek.devtools.error`

Adds an error-level diagnostic message to the devtools log.

```lua
lurek.devtools.error(message)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `message` | string | Message text stored in the in-memory log history. |

**Example**

```lua
do

    lurek.devtools.error("save file warning emitted")
    lurek.devtools.error("quest state patch failed validation")
    local level = lurek.devtools.getLogLevel()
    local history = lurek.devtools.getLogHistory(2)
    lurek.log.info("error level gate=" .. tostring(level))
    lurek.log.info("error history rows=" .. tostring(#history))
end
```

---

### `lurek.devtools.eval`

Evaluates Lua code in the current state and returns success plus values or failure plus an error message.

```lua
lurek.devtools.eval(code)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `code` | string | Lua source code evaluated through the current Lua VM. |

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Multi-return where the first value is a boolean success flag followed by result values or an error string. |

**Example**

```lua
do

    local ok, value = lurek.devtools.eval("return 2 + 2")
    local badOk, badValue = lurek.devtools.eval("invalid syntax %%%")
    local stack = lurek.devtools.getCallStack(2)
    lurek.log.info("eval success=" .. tostring(ok) .. " value=" .. tostring(value))
    lurek.log.info("eval failure=" .. tostring(badOk) .. " error=" .. tostring(badValue) .. " stack=" .. tostring(#stack))
end
```

---

### `lurek.devtools.exposeWatch`

Registers a watch expression callback for snapshots and watch panels.

```lua
lurek.devtools.exposeWatch(name, getter, category)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Display name for the watch entry. |
| `getter` | function | Callback invoked with no arguments when watch values are collected. |
| `category?` | string | Optional category label used by devtools UIs. |

**Returns**

| Type | Description |
|------|-------------|
| number | Numeric watch id that can be passed to `removeWatch`. |

**Example**

```lua
do

    local id = lurek.devtools.exposeWatch("health", function() return 100 end, "player")
    local watchEntries = lurek.devtools.getWatches()
    local snapshot = lurek.devtools.snapshot()
    lurek.log.info("watch id=" .. tostring(id))
    lurek.log.info("watch entries=" .. tostring(#watchEntries) .. " snapshot count=" .. tostring(snapshot.watchCount))
end
```

---

### `lurek.devtools.fatal`

Adds a fatal-level diagnostic message to the devtools log.

```lua
lurek.devtools.fatal(message)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `message` | string | Message text stored in the in-memory log history. |

**Example**

```lua
do

    lurek.devtools.fatal("unrecoverable GPU error")
    lurek.devtools.fatal("recovery path exhausted for render backend")
    local level = lurek.devtools.getLogLevel()
    local history = lurek.devtools.getLogHistory(2)
    lurek.log.info("fatal level gate=" .. tostring(level))
    lurek.log.info("fatal history rows=" .. tostring(#history))
end
```

---

### `lurek.devtools.getCallStack`

Returns Lua call stack frames using the Lua debug library.

```lua
lurek.devtools.getCallStack(max_depth)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `max_depth?` | number | Optional maximum number of frames to return; defaults to 20 and is capped at 100. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of frame tables; each has source (string), line (integer), name (string), and what (string) fields. |

**Example**

```lua
do

    local frames = lurek.devtools.getCallStack(5)
    local stackDepth = #frames
    local firstFrame = frames[1] and (frames[1].name or frames[1].source) or "none"
    local framesType = type(frames)
    lurek.log.info("call stack depth=" .. tostring(stackDepth))
    lurek.log.info("call stack first frame=" .. tostring(firstFrame) .. " type=" .. tostring(framesType))
end
```

---

### `lurek.devtools.getFrameHistory`

Returns retained CPU frame duration samples in insertion order.

```lua
lurek.devtools.getFrameHistory()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of CPU frame durations in seconds. |

**Example**

```lua
do

    lurek.devtools.recordFrameTime(0.016)
    local h = lurek.devtools.getFrameHistory()
    lurek.devtools.recordFrameTime(0.018)
    local latest = lurek.devtools.getFrameHistory()
    lurek.log.info("frame history count initial=" .. tostring(#h))
    lurek.log.info("frame history count updated=" .. tostring(#latest))
end
```

---

### `lurek.devtools.getFrameHistorySize`

Returns the current CPU frame history capacity.

```lua
lurek.devtools.getFrameHistorySize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Maximum number of retained CPU frame duration samples. |

**Example**

```lua
do

    local n = lurek.devtools.getFrameHistorySize()
    lurek.devtools.setFrameHistorySize(90)
    local updated = lurek.devtools.getFrameHistorySize()
    local valueType = type(n)
    lurek.log.info("frame history size initial=" .. tostring(n))
    lurek.log.info("frame history size updated=" .. tostring(updated) .. " type=" .. tostring(valueType))
end
```

---

### `lurek.devtools.getFrameStats`

Returns aggregate CPU frame timing statistics from recorded samples.

```lua
lurek.devtools.getFrameStats()
```

**Returns**

| Type | Description |
|------|-------------|
| LDevtoolsGetFrameStatsResult | Table containing fps, dt, avg, min, max, p50, p95, p99, and samples fields. |

**Example**

```lua
do

    lurek.devtools.recordFrameTime(0.016)
    lurek.devtools.recordFrameTime(0.018)
    local stats = lurek.devtools.getFrameStats()
    lurek.log.info(tostring("fps = " .. tostring(stats.fps)))
    lurek.log.info(tostring("samples = " .. tostring(stats.samples)))
end
```

---

### `lurek.devtools.getGpuFrameStats`

Returns aggregate GPU frame timing statistics from recorded samples.

```lua
lurek.devtools.getGpuFrameStats()
```

**Returns**

| Type | Description |
|------|-------------|
| LDevtoolsGetGpuFrameStatsResult | Table containing fps, dt, avg, min, max, p50, p95, p99, and samples fields. |

**Example**

```lua
do

    lurek.devtools.recordGpuFrameTime(0.008)
    lurek.devtools.recordGpuFrameTime(0.009)
    local stats = lurek.devtools.getGpuFrameStats()
    lurek.log.info(tostring("gpu fps = " .. tostring(stats.fps)))
    lurek.log.info(tostring("gpu samples = " .. tostring(stats.samples)))
end
```

---

### `lurek.devtools.getLogConsole`

Returns whether devtools log entries are mirrored to the console.

```lua
lurek.devtools.getLogConsole()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when console logging is enabled. |

**Example**

```lua
do

    local console = lurek.devtools.getLogConsole()
    lurek.devtools.setLogConsole(not console)
    local toggled = lurek.devtools.getLogConsole()
    local consoleType = type(console)
    lurek.log.info("console mirror initial=" .. tostring(console))
    lurek.log.info("console mirror toggled=" .. tostring(toggled) .. " type=" .. tostring(consoleType))
end
```

---

### `lurek.devtools.getLogFile`

Returns the file path currently stored as the devtools log target.

```lua
lurek.devtools.getLogFile()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Current log file path. |

**Example**

```lua
do

    local fp = lurek.devtools.getLogFile()
    lurek.devtools.setLogFile("save/devtools_session.log")
    local updated = lurek.devtools.getLogFile()
    local fileType = type(updated)
    lurek.log.info("previous log file=" .. tostring(fp))
    lurek.log.info("current log file=" .. tostring(updated) .. " type=" .. tostring(fileType))
end
```

---

### `lurek.devtools.getLogHistory`

Returns recent devtools log entries as structured tables.

```lua
lurek.devtools.getLogHistory(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count?` | number | Optional number of newest entries to return; omitted returns the logger default. |

**Returns**

| Type | Description |
|------|-------------|
| LDevtoolsGetLogHistoryResult | Array table containing level, timestamp, message, source, line, and optional category fields. |

**Example**

```lua
do

    lurek.devtools.info("test entry")
    local entries = lurek.devtools.getLogHistory(5)
    lurek.devtools.warn("second test entry")
    local latestEntries = lurek.devtools.getLogHistory(5)
    local last = latestEntries[#latestEntries]
    lurek.log.info("log history entries=" .. tostring(#entries))
    lurek.log.info("log history after second entry=" .. tostring(#latestEntries))
    lurek.log.info("latest history source=" .. tostring(last and last.source or "nil"))
    lurek.log.info("latest history timestamp>0=" .. tostring(last and last.timestamp and last.timestamp > 0))
end
```

---

### `lurek.devtools.getLogLevel`

Returns the minimum severity currently used by devtools log output.

```lua
lurek.devtools.getLogLevel()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Current minimum log level name. |

**Example**

```lua
do

    local level = lurek.devtools.getLogLevel()
    lurek.devtools.setLogLevel("info")
    local refreshed = lurek.devtools.getLogLevel()
    local levelType = type(level)
    lurek.log.info("initial log level=" .. tostring(level))
    lurek.log.info("refreshed log level=" .. tostring(refreshed) .. " type=" .. tostring(levelType))
end
```

---

### `lurek.devtools.getProfileData`

Returns the profiler zone tree for a retained frame.

```lua
lurek.devtools.getProfileData(frame)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `frame?` | number | Optional frame index understood by the profiler; omitted reads the newest frame alias used by the backend. |

**Returns**

| Type | Description |
|------|-------------|
| LDevtoolsGetProfileDataResult | Array of profiler zones with name, time, selfTime, startTime, and children fields. |

**Example**

```lua
do

    lurek.devtools.setProfilingEnabled(true)
    lurek.devtools.profilePush("update")
    lurek.devtools.profilePop()
    lurek.devtools.profileFrame()
    local frames = lurek.devtools.getProfileData()
    lurek.log.info(tostring("profile rows = " .. #frames))
    if frames[1] then
        lurek.log.info(tostring("first zone = " .. tostring(frames[1].name)))
    end
end
```

---

### `lurek.devtools.getProfileFrameCount`

Returns how many profiling frames are currently stored.

```lua
lurek.devtools.getProfileFrameCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Number of retained profiler frames. |

**Example**

```lua
do

    local n = lurek.devtools.getProfileFrameCount()
    lurek.devtools.setProfilingEnabled(true)
    lurek.devtools.profilePush("count")
    lurek.devtools.profilePop()
    lurek.devtools.profileFrame()
    lurek.log.info("profile frames before sample=" .. tostring(n))
    lurek.log.info("profile frames after sample=" .. tostring(lurek.devtools.getProfileFrameCount()))
end
```

---

### `lurek.devtools.getWatchInterval`

Returns the polling interval hint used by devtools watch UIs.

```lua
lurek.devtools.getWatchInterval()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Watch interval in seconds. |

**Example**

```lua
do

    local v = lurek.devtools.getWatchInterval()
    lurek.devtools.setWatchInterval(0.75)
    local updated = lurek.devtools.getWatchInterval()
    local valueType = type(v)
    lurek.log.info("watch interval initial=" .. tostring(v))
    lurek.log.info("watch interval updated=" .. tostring(updated) .. " type=" .. tostring(valueType))
end
```

---

### `lurek.devtools.getWatchedPaths`

Returns all paths currently watched by the module-level file watcher.

```lua
lurek.devtools.getWatchedPaths()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Sorted array table of watched path strings. |

**Example**

```lua
do

    lurek.devtools.watch("content/examples/assets/images")
    local paths = lurek.devtools.getWatchedPaths()
    lurek.devtools.watch("content/examples/assets/layouts/sample_main_menu.toml")
    local updated = lurek.devtools.getWatchedPaths()
    lurek.log.info("watched path count initial=" .. tostring(#paths))
    lurek.log.info("watched path count updated=" .. tostring(#updated))
end
```

---

### `lurek.devtools.getWatches`

Evaluates exposed watch callbacks and returns their current values.

```lua
lurek.devtools.getWatches()
```

**Returns**

| Type | Description |
|------|-------------|
| LDevtoolsGetWatchesResult | Array of watch rows with name, category, and value fields. |

**Example**

```lua
do

    lurek.devtools.exposeWatch("score", function() return 42 end)
    local watches = lurek.devtools.getWatches()
    lurek.devtools.exposeWatch("ammo", function() return 12 end, "hud")
    local updated = lurek.devtools.getWatches()
    lurek.log.info("watch entries initial=" .. tostring(#watches))
    lurek.log.info("watch entries updated=" .. tostring(#updated))
end
```

---

### `lurek.devtools.info`

Adds an info-level diagnostic message to the devtools log.

```lua
lurek.devtools.info(message)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `message` | string | Message text stored in the in-memory log history. |

**Example**

```lua
do

    lurek.log.clearSinks()
    local sink = lurek.log.addSink({
        type = "memory",
        level = "debug",
        capacity = 8,
        tags = { "Devtools" },
    })
    lurek.devtools.info("level loaded")
    lurek.devtools.info("checkpoint state restored")
    local level = lurek.devtools.getLogLevel()
    local history = lurek.devtools.getLogHistory(2)
    local shared = lurek.log.readMemory(sink, true)
    lurek.log.info("info level gate=" .. tostring(level))
    lurek.log.info("info history rows=" .. tostring(#history))
    lurek.log.info("shared sink rows=" .. tostring(#shared))
end
```

---

### `lurek.devtools.isConsoleOpen`

Returns whether the devtools console is marked open.

```lua
lurek.devtools.isConsoleOpen()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the console-open flag is set. |

**Example**

```lua
do

    local v = lurek.devtools.isConsoleOpen()
    lurek.devtools.openConsole()
    local updated = lurek.devtools.isConsoleOpen()
    local valueType = type(v)
    lurek.log.info("console open initial=" .. tostring(v))
    lurek.log.info("console open updated=" .. tostring(updated) .. " type=" .. tostring(valueType))
end
```

---

### `lurek.devtools.isEntityInspectorOpen`

Returns whether the devtools entity inspector is marked open.

```lua
lurek.devtools.isEntityInspectorOpen()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the entity-inspector-open flag is set. |

**Example**

```lua
do

    local v = lurek.devtools.isEntityInspectorOpen()
    lurek.devtools.openEntityInspector()
    local updated = lurek.devtools.isEntityInspectorOpen()
    local valueType = type(v)
    lurek.log.info("entity inspector initial=" .. tostring(v))
    lurek.log.info("entity inspector updated=" .. tostring(updated) .. " type=" .. tostring(valueType))
end
```

---

### `lurek.devtools.isProfilingEnabled`

Returns whether CPU profiling zone collection is currently enabled.

```lua
lurek.devtools.isProfilingEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when profiler recording is enabled. |

**Example**

```lua
do

    local v = lurek.devtools.isProfilingEnabled()
    lurek.devtools.setProfilingEnabled(not v)
    local toggled = lurek.devtools.isProfilingEnabled()
    local valueType = type(v)
    lurek.log.info("profiling initial=" .. tostring(v))
    lurek.log.info("profiling toggled=" .. tostring(toggled) .. " type=" .. tostring(valueType))
end
```

---

### `lurek.devtools.log`

Adds a message to the devtools log using an explicit severity level.

```lua
lurek.devtools.log(level, message)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `level` | string | Log level name such as `trace`, `debug`, `info`, `warn`, `error`, or `fatal`. |
| `message` | string | Message text stored in the in-memory log history. |

**Example**

```lua
do

    lurek.devtools.log("info", "game started")
    lurek.devtools.log("warn", "shader cache cold on first boot")
    local level = lurek.devtools.getLogLevel()
    local history = lurek.devtools.getLogHistory(2)
    lurek.log.info("devtools log level=" .. tostring(level))
    lurek.log.info("devtools log history rows=" .. tostring(#history))
end
```

---

### `lurek.devtools.newFileWatcher`

Creates a dedicated file watcher userdata for one path.

```lua
lurek.devtools.newFileWatcher(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | File or directory path watched by the returned handle. |

**Returns**

| Type | Description |
|------|-------------|
| [LFileWatcher](#lfilewatcher) | File watcher handle with polling and callback methods. |

**Example**

```lua
do

    local watcher = lurek.devtools.newFileWatcher("content/")
    local path = watcher:getPath()
    local typeName = watcher:type()
    local changed = watcher:check()
    lurek.log.info("file watcher path=" .. tostring(path))
    lurek.log.info("file watcher type=" .. tostring(typeName) .. " changed=" .. tostring(changed))
end
```

---

### `lurek.devtools.newRepl`

Creates a REPL console userdata with bounded command history.

```lua
lurek.devtools.newRepl(max_history)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `max_history?` | number | Optional maximum number of history entries; defaults to 200. |

**Returns**

| Type | Description |
|------|-------------|
| [LReplConsole](#lreplconsole) | REPL console handle for eval and history management. |

**Example**

```lua
do

    local repl = lurek.devtools.newRepl(50)
    repl:eval("return 5 * 5")
    local historyLen = repl:len()
    local typeName = repl:type()
    local history = repl:history()
    lurek.log.info("repl type=" .. tostring(typeName))
    lurek.log.info("repl history len=" .. tostring(historyLen) .. " entries=" .. tostring(#history))
end
```

---

### `lurek.devtools.openConsole`

Marks the devtools console as open for UI state tracking.

```lua
lurek.devtools.openConsole()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | Always returns true after setting the console-open flag. |

**Example**

```lua
do

    local ok = lurek.devtools.openConsole()
    local isOpen = lurek.devtools.isConsoleOpen()
    local stack = lurek.devtools.getCallStack(2)
    lurek.log.info("console opened=" .. tostring(ok))
    lurek.log.info("console open state=" .. tostring(isOpen) .. " stack depth=" .. tostring(#stack))
end
```

---

### `lurek.devtools.openEntityInspector`

Marks the devtools entity inspector as open for UI state tracking.

```lua
lurek.devtools.openEntityInspector()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | Always returns true after setting the entity-inspector flag. |

**Example**

```lua
do

    local ok = lurek.devtools.openEntityInspector()
    local isOpen = lurek.devtools.isEntityInspectorOpen()
    local snapshot = lurek.devtools.snapshot()
    lurek.log.info("entity inspector opened=" .. tostring(ok))
    lurek.log.info("entity inspector state=" .. tostring(isOpen) .. " watch count=" .. tostring(snapshot.watchCount))
end
```

---

### `lurek.devtools.profileFrame`

Closes the current profiling frame and stores its zone tree for later inspection.

```lua
lurek.devtools.profileFrame()
```

**Example**

```lua
do

    lurek.devtools.setProfilingEnabled(true)
    lurek.devtools.profilePush("update")
    lurek.devtools.profilePop()
    lurek.devtools.profileFrame()
    lurek.log.info(tostring("frame stored"))
end
```

---

### `lurek.devtools.profilePop`

Ends the current profiling zone on the profiler stack.

```lua
lurek.devtools.profilePop(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name?` | string | Optional zone name accepted for API compatibility and ignored by the profiler. |

**Example**

```lua
do

    lurek.devtools.setProfilingEnabled(true)
    lurek.devtools.profilePush("render")
    lurek.devtools.profilePop()
    lurek.devtools.profileFrame()
    local frames = lurek.devtools.getProfileFrameCount()
    local report = lurek.devtools.profilerReport()
    lurek.log.info("popped render zone and stored frame")
    lurek.log.info("profile frames=" .. tostring(frames) .. " report rows=" .. tostring(#report))
end
```

---

### `lurek.devtools.profilePush`

Starts a named profiling zone on the current profiler stack.

```lua
lurek.devtools.profilePush(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Profiling zone name shown in reports and snapshots. |

**Example**

```lua
do

    lurek.devtools.setProfilingEnabled(true)
    lurek.devtools.profilePush("physics")
    lurek.devtools.profilePop()
    lurek.devtools.profileFrame()
    local frames = lurek.devtools.getProfileFrameCount()
    lurek.log.info("pushed and closed physics zone")
    lurek.log.info("stored profile frames=" .. tostring(frames))
end
```

---

### `lurek.devtools.profilerReport`

Aggregates retained profiler frames into per-zone timing rows.

```lua
lurek.devtools.profilerReport()
```

**Returns**

| Type | Description |
|------|-------------|
| LDevtoolsProfilerReportResult | Array table with zone name, call count, total_ms, avg_ms, min_ms, max_ms, and self_ms fields. |

**Example**

```lua
do

    lurek.devtools.setProfilingEnabled(true)
    lurek.devtools.profilePush("render")
    lurek.devtools.profilePop()
    lurek.devtools.profileFrame()
    local report = lurek.devtools.profilerReport()
    lurek.log.info(tostring("report rows = " .. #report))
    if report[1] then
        lurek.log.info(tostring("first report zone = " .. tostring(report[1].name)))
    end
end
```

---

### `lurek.devtools.recordFrameTime`

Records one CPU frame duration sample for devtools frame statistics.

```lua
lurek.devtools.recordFrameTime(dt_val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt_val` | number | Frame duration in seconds. |

**Example**

```lua
do

    lurek.devtools.recordFrameTime(0.016)
    lurek.devtools.recordFrameTime(0.017)
    local history = lurek.devtools.getFrameHistory()
    local stats = lurek.devtools.getFrameStats()
    lurek.log.info("cpu frame samples=" .. tostring(#history))
    lurek.log.info("cpu fps estimate=" .. tostring(stats.fps))
end
```

---

### `lurek.devtools.recordGpuFrameTime`

Records one GPU frame duration sample for devtools frame statistics.

```lua
lurek.devtools.recordGpuFrameTime(dt_val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt_val` | number | GPU frame duration in seconds. |

**Example**

```lua
do

    lurek.devtools.recordGpuFrameTime(0.008)
    lurek.devtools.recordGpuFrameTime(0.009)
    local stats = lurek.devtools.getGpuFrameStats()
    local profiling = lurek.devtools.isProfilingEnabled()
    lurek.log.info("gpu samples=" .. tostring(stats.samples))
    lurek.log.info("gpu profiling flag=" .. tostring(profiling))
end
```

---

### `lurek.devtools.removeWatch`

Removes a previously exposed watch expression by id.

```lua
lurek.devtools.removeWatch(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Watch id returned by `exposeWatch`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a watch entry was removed. |

**Example**

```lua
do

    local id = lurek.devtools.exposeWatch("temp", function() return 0 end)
    local ok = lurek.devtools.removeWatch(id)
    local watchEntries = lurek.devtools.getWatches()
    local snapshot = lurek.devtools.snapshot()
    lurek.log.info("watch removed=" .. tostring(ok))
    lurek.log.info("watch entries after remove=" .. tostring(#watchEntries) .. " snapshot count=" .. tostring(snapshot.watchCount))
end
```

---

### `lurek.devtools.resetProfile`

Clears profiler state, active zones, and retained profiling frames.

```lua
lurek.devtools.resetProfile()
```

**Example**

```lua
do

    lurek.devtools.setProfilingEnabled(true)
    lurek.devtools.profilePush("temporary")
    lurek.devtools.profilePop()
    lurek.devtools.profileFrame()
    lurek.devtools.resetProfile()
    local frames = lurek.devtools.getProfileFrameCount()
    local enabled = lurek.devtools.isProfilingEnabled()
    lurek.log.info("profile reset frames=" .. tostring(frames))
    lurek.log.info("profiling enabled after reset=" .. tostring(enabled))
end
```

---

### `lurek.devtools.scan`

Polls module-level file watches and returns paths that changed since the previous scan.

```lua
lurek.devtools.scan()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Changed path strings. |

**Example**

```lua
do

    lurek.devtools.watch("content/examples/assets/layouts/sample_main_menu.toml")
    local changed = lurek.devtools.scan()
    local watchedPaths = lurek.devtools.getWatchedPaths()
    local interval = lurek.devtools.getWatchInterval()
    lurek.log.info("changed files count=" .. tostring(#changed))
    lurek.log.info("watched paths=" .. tostring(#watchedPaths) .. " interval=" .. tostring(interval))
end
```

---

### `lurek.devtools.setFrameHistorySize`

Sets the maximum number of CPU frame duration samples retained by devtools.

```lua
lurek.devtools.setFrameHistorySize(size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `size` | number | Maximum number of frame samples to keep. |

**Example**

```lua
do

    lurek.devtools.setFrameHistorySize(120)
    lurek.devtools.recordFrameTime(0.016)
    local historySize = lurek.devtools.getFrameHistorySize()
    local stats = lurek.devtools.getFrameStats()
    lurek.log.info("frame history size=" .. tostring(historySize))
    lurek.log.info("frame stats samples after resize=" .. tostring(stats.samples))
end
```

---

### `lurek.devtools.setLogConsole`

Enables or disables mirroring devtools log entries to the console.

```lua
lurek.devtools.setLogConsole(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | boolean | True to emit future log entries to console output. |

**Example**

```lua
do

    lurek.devtools.setLogConsole(true)
    lurek.devtools.info("console mirror enabled for local debugging")
    local consoleEnabled = lurek.devtools.getLogConsole()
    local history = lurek.devtools.getLogHistory(1)
    lurek.log.info("console mirror enabled=" .. tostring(consoleEnabled))
    lurek.log.info("history rows after mirror toggle=" .. tostring(#history))
end
```

---

### `lurek.devtools.setLogFile`

Sets the file path used by devtools file logging state.

```lua
lurek.devtools.setLogFile(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | File path recorded as the active devtools log target. |

**Example**

```lua
do

    lurek.log.clearSinks()
    lurek.devtools.setLogFile("save/devtools_example.log")
    lurek.devtools.info("writing runtime diagnostics to save/devtools_example.log")
    local logFile = lurek.devtools.getLogFile()
    local history = lurek.devtools.getLogHistory(1)
    lurek.devtools.setLogFile("")
    lurek.log.info("log file path=" .. tostring(logFile))
    lurek.log.info("history rows after file target change=" .. tostring(#history))
    lurek.log.info("hidden sinks visible to lurek.log=" .. tostring(#lurek.log.listSinks()))
end
```

---

### `lurek.devtools.setLogLevel`

Sets the minimum severity that remains visible in devtools log output.

```lua
lurek.devtools.setLogLevel(level)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `level` | string | Log level name parsed by the devtools logger; unknown names are ignored. |

**Example**

```lua
do

    lurek.devtools.setLogLevel("warn")
    lurek.devtools.info("hidden by warn gate")
    lurek.devtools.warn("visible warning after gate change")
    local currentLevel = lurek.devtools.getLogLevel()
    local history = lurek.devtools.getLogHistory(3)
    lurek.log.info("log level set to=" .. tostring(currentLevel))
    lurek.log.info("history rows after gate change=" .. tostring(#history))
end
```

---

### `lurek.devtools.setProfilingEnabled`

Enables or disables collection of CPU profiling zones.

```lua
lurek.devtools.setProfilingEnabled(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | boolean | True to record profiling zones into future profiler frames. |

**Example**

```lua
do

    lurek.devtools.setProfilingEnabled(true)
    lurek.devtools.profilePush("bootstrap")
    lurek.devtools.profilePop()
    local enabled = lurek.devtools.isProfilingEnabled()
    lurek.log.info("profiling enabled=" .. tostring(enabled))
    lurek.log.info("profile frame count=" .. tostring(lurek.devtools.getProfileFrameCount()))
end
```

---

### `lurek.devtools.setWatchInterval`

Sets the polling interval hint used by devtools watch UIs.

```lua
lurek.devtools.setWatchInterval(interval)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `interval` | number | Watch interval in seconds, clamped to at least 0.01. |

**Example**

```lua
do

    lurek.devtools.setWatchInterval(0.5)
    lurek.devtools.watch("content/examples/assets/layouts/sample_main_menu.toml")
    local interval = lurek.devtools.getWatchInterval()
    local watchedPaths = lurek.devtools.getWatchedPaths()
    lurek.log.info("watch interval set to=" .. tostring(interval))
    lurek.log.info("watched paths after interval set=" .. tostring(#watchedPaths))
end
```

---

### `lurek.devtools.snapshot`

Captures a combined devtools snapshot containing frame stats, watch values, profile data, and recent logs.

```lua
lurek.devtools.snapshot()
```

**Returns**

| Type | Description |
|------|-------------|
| LDevtoolsSnapshotResult | Snapshot table with frameStats, watches, profile, log, and watchCount fields. |

**Example**

```lua
do

    lurek.devtools.recordFrameTime(0.016)
    lurek.devtools.info("snapshot ready")
    lurek.devtools.exposeWatch("score", function()
        return 42
    end, "hud")
    local snap = lurek.devtools.snapshot()
    lurek.log.info(tostring("watch count = " .. tostring(snap.watchCount)))
    lurek.log.info(tostring("log rows = " .. tostring(#snap.log)))
end
```

---

### `lurek.devtools.trace`

Adds a trace-level diagnostic message to the devtools log.

```lua
lurek.devtools.trace(message)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `message` | string | Message text stored in the in-memory log history. |

**Example**

```lua
do

    lurek.devtools.trace("entering update loop")
    lurek.devtools.trace("polling input before simulation")
    local level = lurek.devtools.getLogLevel()
    local history = lurek.devtools.getLogHistory(2)
    lurek.log.info("trace level gate=" .. tostring(level))
    lurek.log.info("trace history rows=" .. tostring(#history))
end
```

---

### `lurek.devtools.unwatch`

Removes a path from the module-level devtools file watcher.

```lua
lurek.devtools.unwatch(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Previously watched file or directory path. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the path was removed. |

**Example**

```lua
do

    lurek.devtools.watch("content/examples/assets/layouts/sample_main_menu.toml")
    local removed = lurek.devtools.unwatch("content/examples/assets/layouts/sample_main_menu.toml")
    local watchedPaths = lurek.devtools.getWatchedPaths()
    local count = #watchedPaths
    lurek.log.info("watch removed=" .. tostring(removed))
    lurek.log.info("watched path count after remove=" .. tostring(count))
end
```

---

### `lurek.devtools.warn`

Adds a warning-level diagnostic message to the devtools log.

```lua
lurek.devtools.warn(message)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `message` | string | Message text stored in the in-memory log history. |

**Example**

```lua
do

    lurek.devtools.warn("texture missing fallback used")
    lurek.devtools.warn("navmesh using last valid bake")
    local level = lurek.devtools.getLogLevel()
    local history = lurek.devtools.getLogHistory(2)
    lurek.log.info("warn level gate=" .. tostring(level))
    lurek.log.info("warn history rows=" .. tostring(#history))
end
```

---

### `lurek.devtools.watch`

Adds a path to the module-level devtools file watcher.

```lua
lurek.devtools.watch(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | File or directory path to poll for changes. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the path was newly added; false when it was already watched. |

**Example**

```lua
do

    local added = lurek.devtools.watch("content/examples/assets/layouts/sample_main_menu.toml")
    lurek.devtools.watch("content/examples/assets/images")
    local watchedPaths = lurek.devtools.getWatchedPaths()
    lurek.log.info("watch added=" .. tostring(added))
    lurek.log.info("watched paths count=" .. tostring(#watchedPaths))
end
```

---

## Module Fields

*No module-level fields documented.*

## Callback Parameters

- `lurek.devtools.exposeWatch` param `getter` (`function`): Callback invoked with no arguments when watch values are collected.

## Enums

*No module-specific enums documented.*

## Types

- [LFileWatcher](#lfilewatcher)
- [LReplConsole](#lreplconsole)

## LFileWatcher

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LFileWatcher:cancel`

Cancels this watcher and removes its callback.

```lua
LFileWatcher:cancel()
```

**Example**

```lua
do

    local watcher = lurek.devtools.newFileWatcher("save/")
    watcher:cancel()
    local path = watcher:getPath()
    local changed = watcher:check()
    lurek.log.info("watcher cancelled for path=" .. tostring(path))
    lurek.log.info("watcher changed after cancel=" .. tostring(changed))
end
```

---

#### `LFileWatcher:check`

Polls the watcher and invokes the change callback when a change is found.

```lua
LFileWatcher:check()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when at least one change was detected. |

**Example**

```lua
do

    local watcher = lurek.devtools.newFileWatcher("content/")
    local changed = watcher:check()
    local path = watcher:getPath()
    local typeName = watcher:type()
    lurek.log.info("file watcher changed=" .. tostring(changed))
    lurek.log.info("file watcher path=" .. tostring(path) .. " type=" .. tostring(typeName))
end
```

---

#### `LFileWatcher:getPath`

Returns the watched path. This method is available to Lua scripts.

```lua
LFileWatcher:getPath()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Watched path string. |

**Example**

```lua
do

    local watcher = lurek.devtools.newFileWatcher("content/")
    local path = watcher:getPath()
    local typeName = watcher:type()
    local changed = watcher:check()
    lurek.log.info("watcher path=" .. tostring(path))
    lurek.log.info("watcher type=" .. tostring(typeName) .. " changed=" .. tostring(changed))
end
```

---

#### `LFileWatcher:onChanged`

Sets the callback invoked when this watcher observes a change.

```lua
LFileWatcher:onChanged(func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `func` | function | Callback called with no arguments after a change is detected. |

**Example**

```lua
do

    local watcher = lurek.devtools.newFileWatcher("assets/")
    watcher:onChanged(function()
        lurek.log.info(tostring("file changed!"))
    end)
    lurek.log.info(tostring("onChange callback set"))
end
```

---

#### `LFileWatcher:type`

Returns the Lua-visible type name for this file watcher handle.

```lua
LFileWatcher:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LFileWatcher](#lfilewatcher)`. |

**Example**

```lua
do

    local watcher = lurek.devtools.newFileWatcher("assets/")
    local typeName = watcher:type()
    local isObject = watcher:typeOf("LObject")
    local path = watcher:getPath()
    lurek.log.info("file watcher type=" .. tostring(typeName))
    lurek.log.info("file watcher path=" .. tostring(path) .. " is object=" .. tostring(isObject))
end
```

---

#### `LFileWatcher:typeOf`

Returns whether this file watcher handle matches a supported type name.

```lua
LFileWatcher:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LFileWatcher](#lfilewatcher)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do

    local watcher = lurek.devtools.newFileWatcher("assets/textures/")
    local isWatcher = watcher:typeOf("LFileWatcher")
    local typeName = watcher:type()
    local path = watcher:getPath()
    lurek.log.info("is LFileWatcher=" .. tostring(isWatcher))
    lurek.log.info("file watcher path=" .. tostring(path) .. " type=" .. tostring(typeName))
end
```

---

## LReplConsole

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LReplConsole:clear`

Clears this REPL console's command history.

```lua
LReplConsole:clear()
```

**Example**

```lua
do

    local repl = lurek.devtools.newRepl(100)
    repl:eval("print('hi')")
    local beforeClear = repl:len()
    repl:clear()
    local afterClear = repl:len()
    local history = repl:history()
    lurek.log.info("repl history before clear=" .. tostring(beforeClear))
    lurek.log.info("repl history after clear=" .. tostring(afterClear) .. " entries=" .. tostring(#history))
end
```

---

#### `LReplConsole:eval`

Evaluates Lua code through this REPL console and records it in history.

```lua
LReplConsole:eval(code)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `code` | string | Lua source code evaluated in the active Lua VM. |

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Evaluation result shape produced by the devtools REPL backend. |

**Example**

```lua
do

    local repl = lurek.devtools.newRepl(100)
    local result = repl:eval("return 1 + 1")
    local historyLen = repl:len()
    local history = repl:history()
    lurek.log.info("repl eval result type=" .. tostring(type(result)))
    lurek.log.info("repl history len=" .. tostring(historyLen) .. " entries=" .. tostring(#history))
end
```

---

#### `LReplConsole:history`

Returns this REPL console's recorded command history.

```lua
LReplConsole:history()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | History entry strings. |

**Example**

```lua
do

    local repl = lurek.devtools.newRepl(100)
    repl:eval("local x = 1")
    repl:eval("local y = 2")
    local h = repl:history()
    lurek.log.info(tostring("history entries = " .. #h))
end
```

---

#### `LReplConsole:len`

Returns the number of entries stored in this REPL console history.

```lua
LReplConsole:len()
```

**Returns**

| Type | Description |
|------|-------------|
| number | History entry count. |

**Example**

```lua
do

    local repl = lurek.devtools.newRepl(100)
    repl:eval("a = 1")
    repl:eval("b = 2")
    local historyLen = repl:len()
    local history = repl:history()
    lurek.log.info("repl history len=" .. tostring(historyLen))
    lurek.log.info("repl history entries=" .. tostring(#history))
end
```

---

#### `LReplConsole:type`

Returns the Lua-visible type name for this REPL console handle.

```lua
LReplConsole:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LReplConsole](#lreplconsole)`. |

**Example**

```lua
do

    local repl = lurek.devtools.newRepl()
    repl:eval("return 'warmup'")
    local typeName = repl:type()
    local isObject = repl:typeOf("LObject")
    lurek.log.info("repl type=" .. tostring(typeName))
    lurek.log.info("repl is object=" .. tostring(isObject))
end
```

---

#### `LReplConsole:typeOf`

Returns whether this REPL console handle matches a supported type name.

```lua
LReplConsole:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LReplConsole](#lreplconsole)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do

    local repl = lurek.devtools.newRepl()
    repl:eval("return 'warmup'")
    local isRepl = repl:typeOf("LReplConsole")
    local typeName = repl:type()
    lurek.log.info("is LReplConsole=" .. tostring(isRepl))
    lurek.log.info("repl type=" .. tostring(typeName))
end
```

---
