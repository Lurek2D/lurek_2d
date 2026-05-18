-- content/examples/devtools.lua
-- lurek.devtools API examples: logging, profiling, file watching, REPL, watches, and inspection.
-- Run: cargo run -- content/examples/devtools.lua

--@api-stub: lurek.devtools.log
-- Logs one message with a runtime-selected severity.
do
  -- Use log() when game state chooses the severity at runtime.
  local previous = lurek.devtools.getLogLevel()
  lurek.devtools.setLogLevel("trace")
  local hp, max_hp = 14, 100
  local level = (hp / max_hp) < 0.2 and "warn" or "info"
  lurek.devtools.log(level, "player hp " .. hp .. "/" .. max_hp)
  lurek.devtools.setLogLevel(previous)
end

--@api-stub: lurek.devtools.trace
-- Records very detailed diagnostics for a frame-level investigation.
do
  -- Trace is useful for temporary frame-by-frame probes.
  local previous = lurek.devtools.getLogLevel()
  lurek.devtools.setLogLevel("trace")
  lurek.devtools.trace(string.format("frame dt=%.4f visible=%d", 1 / 60, 73))
  lurek.devtools.setLogLevel(previous)
end

--@api-stub: lurek.devtools.debug
-- Records implementation details that help during local debugging.
do
  -- Debug messages fit state transitions and branch choices.
  local previous = lurek.devtools.getLogLevel()
  lurek.devtools.setLogLevel("debug")
  lurek.devtools.debug("state patrol -> chase for entity 42")
  lurek.devtools.setLogLevel(previous)
end

--@api-stub: lurek.devtools.info
-- Records a normal milestone that is useful in playtest logs.
do
  -- Info entries can stay enabled during development.
  lurek.devtools.info("loaded level forest_01 with 87 entities")
end

--@api-stub: lurek.devtools.warn
-- Records a recoverable problem and the fallback being used.
do
  -- Warn when the game can continue with a fallback path.
  lurek.devtools.warn("missing textures/hero_alt.png; using textures/hero.png")
end

--@api-stub: lurek.devtools.error
-- Records an operation failure that the game handled.
do
  -- Error is appropriate for failed work that does not crash the runtime.
  local save_ok = false
  if not save_ok then
    lurek.devtools.error("save failed for save/slot1.sav: permission denied")
  end
end

--@api-stub: lurek.devtools.fatal
-- Records an unrecoverable condition before shutdown code runs.
do
  -- fatal() logs the message; it does not throw by itself.
  local shutdown_requested = true
  if shutdown_requested then
    lurek.devtools.fatal("critical renderer state; requesting shutdown")
  end
end

--@api-stub: lurek.devtools.setLogLevel
-- Changes which log severities are retained by devtools.
do
  -- Store and restore global devtools state around focused examples.
  local previous = lurek.devtools.getLogLevel()
  lurek.devtools.setLogLevel("debug")
  lurek.devtools.trace("hidden while level is debug")
  lurek.devtools.debug("debug logging enabled for local tools")
  lurek.devtools.setLogLevel(previous)
end

--@api-stub: lurek.devtools.getLogLevel
-- Reads the active minimum log severity before doing extra debug work.
do
  -- Guard verbose formatting with the current level.
  local previous = lurek.devtools.getLogLevel()
  lurek.devtools.setLogLevel("debug")
  local current = lurek.devtools.getLogLevel()
  if current == "trace" or current == "debug" then
    lurek.devtools.debug("visible_entities=73, chunk=forest_north")
  end
  lurek.devtools.setLogLevel(previous)
end

--@api-stub: lurek.devtools.setLogConsole
-- Toggles whether accepted log entries mirror to the process console.
do
  -- Preserve the previous value so examples do not affect later blocks.
  local previous = lurek.devtools.getLogConsole()
  lurek.devtools.setLogConsole(true)
  lurek.devtools.info("console mirror enabled for one capture")
  lurek.devtools.setLogConsole(previous)
end

--@api-stub: lurek.devtools.getLogConsole
-- Reads the console mirror setting for debug UI status text.
do
  -- A settings screen can show this as a checkbox state.
  local enabled = lurek.devtools.getLogConsole()
  local label = enabled and "terminal logging on" or "terminal logging off"
  lurek.devtools.info("devtools option: " .. label)
end

--@api-stub: lurek.devtools.setLogFile
-- Stores the devtools log file path.
do
  -- The binding stores the path string; this block clears it afterward.
  lurek.devtools.setLogFile("save/devtools/session_debug.log")
  local configured = lurek.devtools.getLogFile()
  lurek.devtools.setLogFile("")
  lurek.devtools.info("file log target checked: " .. configured)
end

--@api-stub: lurek.devtools.getLogFile
-- Reads the configured log file path for a settings or report panel.
do
  -- Empty string means file logging is disabled.
  lurek.devtools.setLogFile("save/devtools/playtest.log")
  local path = lurek.devtools.getLogFile()
  lurek.devtools.setLogFile("")
  lurek.devtools.info("file logging target: " .. (path == "" and "disabled" or path))
end

--@api-stub: lurek.devtools.getLogHistory
-- Pulls recent log rows for an in-game console overlay.
do
  -- Each row contains level, timestamp, message, source, line, and category.
  lurek.devtools.clearLog()
  lurek.devtools.info("console overlay opened")
  lurek.devtools.warn("optional minimap data not loaded")
  local recent = lurek.devtools.getLogHistory(5)
  for index, entry in ipairs(recent) do
    lurek.devtools.debug(index .. ": [" .. tostring(entry.level) .. "] " .. tostring(entry.message))
  end
end

--@api-stub: lurek.devtools.clearLog
-- Clears stale log rows before entering a new scene.
do
  -- Clear the old scene log before adding new-scene messages.
  lurek.devtools.info("leaving village scene")
  lurek.devtools.clearLog()
  lurek.devtools.info("entered dungeon scene")
  lurek.devtools.debug("log rows after reset: " .. #lurek.devtools.getLogHistory(0))
end

--@api-stub: lurek.devtools.setProfilingEnabled
-- Enables profiler capture for a small debug measurement.
do
  -- Profiling zones are retained only while profiling is enabled.
  lurek.devtools.setProfilingEnabled(true)
  lurek.devtools.profilePush("inventory_sort")
  local slots = {3, 1, 2}
  table.sort(slots)
  lurek.devtools.profilePop("inventory_sort")
  lurek.devtools.profileFrame()
  lurek.devtools.setProfilingEnabled(false)
end

--@api-stub: lurek.devtools.isProfilingEnabled
-- Checks whether profiler annotations should run this frame.
do
  -- This keeps optional zone code cheap when profiling is disabled.
  lurek.devtools.setProfilingEnabled(true)
  if lurek.devtools.isProfilingEnabled() then
    lurek.devtools.profilePush("ai_decision")
    lurek.devtools.debug("profiled action=flank")
    lurek.devtools.profilePop("ai_decision")
  end
  lurek.devtools.profileFrame()
  lurek.devtools.setProfilingEnabled(false)
end

--@api-stub: lurek.devtools.profilePush
-- Starts a named profiling zone on the current profiler stack.
do
  -- Zones can nest to show which subsystem owned the time.
  lurek.devtools.setProfilingEnabled(true)
  lurek.devtools.profilePush("game_update")
  lurek.devtools.profilePush("physics_step")
  lurek.devtools.debug("physics bodies=24")
  lurek.devtools.profilePop("physics_step")
  lurek.devtools.profilePop("game_update")
  lurek.devtools.profileFrame()
  lurek.devtools.setProfilingEnabled(false)
end

--@api-stub: lurek.devtools.profilePop
-- Ends the current profiling zone on the profiler stack.
do
  -- Balance each push with a pop even when protected work fails.
  lurek.devtools.setProfilingEnabled(true)
  lurek.devtools.profilePush("spawn_wave")
  local ok, err = pcall(function()
    error("spawn budget exceeded")
  end)
  lurek.devtools.profilePop("spawn_wave")
  if not ok then
    lurek.devtools.error("spawn failed: " .. tostring(err))
  end
  lurek.devtools.profileFrame()
  lurek.devtools.setProfilingEnabled(false)
end

--@api-stub: lurek.devtools.profileFrame
-- Closes the current profiling frame and stores its zone tree.
do
  -- Call this after update and render profiling zones close.
  lurek.devtools.setProfilingEnabled(true)
  lurek.devtools.profilePush("frame")
  lurek.devtools.recordFrameTime(1 / 60)
  lurek.devtools.profilePop("frame")
  lurek.devtools.profileFrame()
  lurek.devtools.setProfilingEnabled(false)
end

--@api-stub: lurek.devtools.getProfileFrameCount
-- Counts retained profiler frames before showing a report button.
do
  -- Frame count tells a UI whether enough data exists for a report.
  lurek.devtools.setProfilingEnabled(true)
  lurek.devtools.profilePush("warmup_frame")
  lurek.devtools.profilePop("warmup_frame")
  lurek.devtools.profileFrame()
  lurek.devtools.debug("profile frames=" .. lurek.devtools.getProfileFrameCount())
  lurek.devtools.setProfilingEnabled(false)
end

--@api-stub: lurek.devtools.getProfileData
-- Reads profiler zones from a retained frame for a debug overlay.
do
  -- Zone timing fields can be displayed after profileFrame().
  lurek.devtools.setProfilingEnabled(true)
  lurek.devtools.profilePush("render_submit")
  lurek.devtools.profilePop("render_submit")
  lurek.devtools.profileFrame()
  local zones = lurek.devtools.getProfileData(0)
  for _, zone in ipairs(zones) do
    local total_ms = (tonumber(zone.time) or 0) * 1000
    lurek.devtools.debug(tostring(zone.name) .. " total=" .. string.format("%.3fms", total_ms))
  end
  lurek.devtools.setProfilingEnabled(false)
end

--@api-stub: lurek.devtools.resetProfile
-- Clears profiler state, active zones, and retained profiling frames.
do
  -- Reset before a focused measurement to avoid old frames in reports.
  lurek.devtools.resetProfile()
  lurek.devtools.setProfilingEnabled(true)
  lurek.devtools.profilePush("benchmark_run")
  lurek.devtools.recordFrameTime(0.016)
  lurek.devtools.profilePop("benchmark_run")
  lurek.devtools.profileFrame()
  lurek.devtools.info("profiler frames after reset: " .. lurek.devtools.getProfileFrameCount())
  lurek.devtools.setProfilingEnabled(false)
end

--@api-stub: lurek.devtools.profilerReport
-- Aggregates retained profiler frames into per-zone timing rows.
do
  -- Reports are useful for a sortable debug table.
  lurek.devtools.resetProfile()
  lurek.devtools.setProfilingEnabled(true)
  lurek.devtools.profilePush("sim")
  lurek.devtools.profilePop("sim")
  lurek.devtools.profileFrame()
  local report = lurek.devtools.profilerReport()
  for _, row in ipairs(report) do
    local avg_ms = tonumber(row.avg_ms) or 0
    lurek.devtools.info(tostring(row.name) .. " avg=" .. string.format("%.3fms", avg_ms))
  end
  lurek.devtools.setProfilingEnabled(false)
end

--@api-stub: lurek.devtools.recordFrameTime
-- Records one CPU frame duration sample for devtools frame statistics.
do
  -- Use seconds, usually the dt passed to the process callback.
  lurek.devtools.recordFrameTime(1 / 60)
  lurek.devtools.recordFrameTime(1 / 55)
  local stats = lurek.devtools.getFrameStats()
  lurek.devtools.info("CPU frame samples recorded: " .. tostring(stats.samples))
end

--@api-stub: lurek.devtools.getFrameStats
-- Reads CPU frame timing metrics for an FPS overlay.
do
  -- Values are seconds except fps and samples.
  lurek.devtools.recordFrameTime(0.016)
  lurek.devtools.recordFrameTime(0.032)
  local stats = lurek.devtools.getFrameStats()
  local avg_ms = (tonumber(stats.avg) or 0) * 1000
  local p99_ms = (tonumber(stats.p99) or 0) * 1000
  lurek.devtools.info(string.format("CPU avg=%.1fms p99=%.1fms", avg_ms, p99_ms))
end

--@api-stub: lurek.devtools.recordGpuFrameTime
-- Records one GPU frame duration sample for devtools frame statistics.
do
  -- GPU samples can come from timestamp queries or renderer estimates.
  lurek.devtools.recordGpuFrameTime(0.008)
  lurek.devtools.recordGpuFrameTime(0.018)
  local gpu = lurek.devtools.getGpuFrameStats()
  lurek.devtools.debug("GPU samples recorded: " .. tostring(gpu.samples))
end

--@api-stub: lurek.devtools.getGpuFrameStats
-- Reads GPU frame timing metrics and compares them to CPU stats.
do
  -- Same table shape as getFrameStats.
  lurek.devtools.recordFrameTime(0.016)
  lurek.devtools.recordGpuFrameTime(0.008)
  local gpu = lurek.devtools.getGpuFrameStats()
  local cpu = lurek.devtools.getFrameStats()
  local bottleneck = (tonumber(gpu.avg) or 0) > (tonumber(cpu.avg) or 0) and "GPU" or "CPU"
  lurek.devtools.info("current bottleneck=" .. bottleneck)
end

--@api-stub: lurek.devtools.getFrameHistory
-- Reads retained CPU frame duration samples in insertion order.
do
  -- History can feed a sparkline or hitch detector.
  lurek.devtools.recordFrameTime(0.016)
  lurek.devtools.recordFrameTime(0.033)
  local worst = 0
  for _, dt in ipairs(lurek.devtools.getFrameHistory()) do
    if dt > worst then
      worst = dt
    end
  end
  lurek.devtools.debug(string.format("worst CPU frame %.1fms", worst * 1000))
end

--@api-stub: lurek.devtools.setFrameHistorySize
-- Sets the retained CPU frame sample window size.
do
  -- Restore the previous capacity after the example.
  local previous = lurek.devtools.getFrameHistorySize()
  lurek.devtools.setFrameHistorySize(120)
  lurek.devtools.info("CPU frame history capacity=" .. lurek.devtools.getFrameHistorySize())
  lurek.devtools.setFrameHistorySize(previous)
end

--@api-stub: lurek.devtools.getFrameHistorySize
-- Reads the current CPU frame history capacity after clamping.
do
  -- The Rust implementation clamps capacity into a safe range.
  local previous = lurek.devtools.getFrameHistorySize()
  lurek.devtools.setFrameHistorySize(50000)
  lurek.devtools.info("requested 50000 CPU samples, actual=" .. lurek.devtools.getFrameHistorySize())
  lurek.devtools.setFrameHistorySize(previous)
end

--@api-stub: lurek.devtools.watch
-- Adds a path to the module-level devtools file watcher.
do
  -- Watching a path twice returns false the second time.
  lurek.devtools.clearWatches()
  local path = "content/examples/devtools.lua"
  local first = lurek.devtools.watch(path)
  local second = lurek.devtools.watch(path)
  lurek.devtools.info("watch first=" .. tostring(first) .. " second=" .. tostring(second))
end

--@api-stub: lurek.devtools.unwatch
-- Removes a path from the module-level devtools file watcher.
do
  -- unwatch() returns true only when the path was present.
  local path = "content/examples/devtools.lua"
  lurek.devtools.watch(path)
  local removed = lurek.devtools.unwatch(path)
  local removed_again = lurek.devtools.unwatch(path)
  lurek.devtools.debug("unwatch removed=" .. tostring(removed) .. " again=" .. tostring(removed_again))
end

--@api-stub: lurek.devtools.getWatchedPaths
-- Lists watched paths for a hot-reload status panel.
do
  -- The binding returns a sorted array of path strings.
  lurek.devtools.clearWatches()
  lurek.devtools.watch("content/examples/devtools.lua")
  lurek.devtools.watch("Cargo.toml")
  local paths = lurek.devtools.getWatchedPaths()
  lurek.devtools.info("watcher paths=" .. #paths)
end

--@api-stub: lurek.devtools.scan
-- Polls watched files and returns paths changed since the previous scan.
do
  -- The first scan records mtimes; later scans report modifications.
  lurek.devtools.clearWatches()
  lurek.devtools.watch("content/examples/devtools.lua")
  local changed = lurek.devtools.scan()
  lurek.devtools.debug("changed paths this scan=" .. #changed)
end

--@api-stub: lurek.devtools.clearWatches
-- Removes every path from the module-level file watcher.
do
  -- Clear old scene files before registering the next scene's assets.
  lurek.devtools.watch("content/examples/devtools.lua")
  lurek.devtools.watch("Cargo.toml")
  lurek.devtools.clearWatches()
  lurek.devtools.info("watches after clear=" .. #lurek.devtools.getWatchedPaths())
end

--@api-stub: lurek.devtools.getWatchInterval
-- Reads the watcher polling interval hint.
do
  -- UI code can display this beside the hot-reload toggle.
  local interval = lurek.devtools.getWatchInterval()
  lurek.devtools.info(string.format("watch poll interval %.2fs", interval))
end

--@api-stub: lurek.devtools.setWatchInterval
-- Sets the watcher polling interval hint for hot-reload UI.
do
  -- Values below 0.01 are clamped by the binding.
  local previous = lurek.devtools.getWatchInterval()
  lurek.devtools.setWatchInterval(0.25)
  lurek.devtools.info(string.format("watch interval set to %.2fs", lurek.devtools.getWatchInterval()))
  lurek.devtools.setWatchInterval(previous)
end

--@api-stub: lurek.devtools.getCallStack
-- Captures a short Lua call stack for an error report.
do
  -- Each frame has source, line, name, and what fields.
  local function capture_stack_for_quest(quest_id)
    local frames = lurek.devtools.getCallStack(5)
    local top = frames[1]
    local source = top and top.source or "?"
    lurek.devtools.debug("quest " .. quest_id .. " stack frames=" .. #frames .. " top=" .. tostring(source))
  end
  capture_stack_for_quest("q_find_relic")
end

--@api-stub: lurek.devtools.eval
-- Evaluates Lua code in the current state and returns success plus values.
do
  -- eval() returns true plus values, or false plus an error string.
  local ok, value = lurek.devtools.eval("return 2 + 2")
  if ok then
    lurek.devtools.info("eval math result=" .. tostring(value))
  end
  local ok2, err = lurek.devtools.eval("return missing_table.field")
  if not ok2 then
    lurek.devtools.warn("eval failed safely: " .. tostring(err))
  end
end

--@api-stub: lurek.devtools.openConsole
-- Marks the devtools console as open for UI state tracking.
do
  -- The game can read isConsoleOpen() when drawing its own console panel.
  lurek.devtools.openConsole()
  lurek.devtools.debug("console open flag: " .. tostring(lurek.devtools.isConsoleOpen()))
end

--@api-stub: lurek.devtools.isConsoleOpen
-- Returns whether the devtools console is marked open.
do
  -- Use this flag to decide whether a game-owned console panel should be visible.
  lurek.devtools.openConsole()
  local should_draw_console = lurek.devtools.isConsoleOpen()
  if should_draw_console then
    lurek.devtools.trace("console overlay would draw this frame")
  end
end

--@api-stub: lurek.devtools.openEntityInspector
-- Marks the devtools entity inspector as open for UI state tracking.
do
  -- This is a UI flag; the game still decides how to render the inspector.
  lurek.devtools.openEntityInspector()
  lurek.devtools.debug("entity inspector opened")
end

--@api-stub: lurek.devtools.isEntityInspectorOpen
-- Returns whether the devtools entity inspector is marked open.
do
  -- Gate inspector work behind this state flag.
  lurek.devtools.openEntityInspector()
  if lurek.devtools.isEntityInspectorOpen() then
    lurek.devtools.trace("entity inspector would draw this frame")
  end
end

--@api-stub: lurek.devtools.exposeWatch
-- Registers a watch expression callback for snapshots and watch panels.
do
  -- Watches are named getter callbacks evaluated when getWatches() runs.
  local player = {x = 256.5, y = 128.0, hp = 80, max_hp = 100}
  lurek.devtools.exposeWatch("player.x", function() return player.x end, "position")
  lurek.devtools.exposeWatch("player.y", function() return player.y end, "position")
  lurek.devtools.exposeWatch("player.hp", function() return player.hp .. "/" .. player.max_hp end, "combat")
  lurek.devtools.debug("player watches registered")
end

--@api-stub: lurek.devtools.removeWatch
-- Removes a previously exposed watch expression by id.
do
  -- exposeWatch returns the numeric id consumed by removeWatch().
  local score = 0
  local id = lurek.devtools.exposeWatch("score", function() return score end, "hud")
  local removed = lurek.devtools.removeWatch(id)
  local removed_again = lurek.devtools.removeWatch(id)
  lurek.devtools.debug("watch removed=" .. tostring(removed) .. " again=" .. tostring(removed_again))
end

--@api-stub: lurek.devtools.getWatches
-- Evaluates exposed watch callbacks and returns their current values.
do
  -- Rows contain name, category, and value fields.
  local frame_count = 0
  lurek.devtools.exposeWatch("frames", function() return frame_count end, "engine")
  frame_count = 120
  for _, watch in ipairs(lurek.devtools.getWatches()) do
    lurek.devtools.info(tostring(watch.category) .. "/" .. tostring(watch.name) .. "=" .. tostring(watch.value))
  end
end

--@api-stub: lurek.devtools.snapshot
-- Captures frame stats, watch values, profile data, logs, and watch count.
do
  -- snapshot() is useful for one-click debug reports.
  lurek.devtools.recordFrameTime(0.016)
  lurek.devtools.exposeWatch("snapshot.ok", function() return "ok" end, "debug")
  local snap = lurek.devtools.snapshot()
  local fps = tonumber(snap.frameStats.fps) or 0
  lurek.devtools.info(string.format("snapshot fps=%.0f watches=%d", fps, snap.watchCount))
end

--@api-stub: lurek.devtools.newFileWatcher
-- Creates a dedicated file watcher userdata for one path.
do
  -- The handle has its own callback and can be polled manually.
  local watcher = lurek.devtools.newFileWatcher("content/examples/devtools.lua")
  watcher:onChanged(function()
    lurek.devtools.info("devtools.lua modified; reload would run")
  end)
  watcher:check()
end

--@api-stub: LFileWatcher:onChanged
-- Sets the callback invoked when this watcher observes a change.
do
  -- Use a closure to capture reload state for a specific file.
  local watcher = lurek.devtools.newFileWatcher("conf.toml")
  local reload_count = 0
  watcher:onChanged(function()
    reload_count = reload_count + 1
    lurek.devtools.info("conf.toml reload count=" .. reload_count)
  end)
end

--@api-stub: LFileWatcher:check
-- Polls the watcher and invokes the change callback when a change is found.
do
  -- check() returns true only when at least one change is detected.
  local watcher = lurek.devtools.newFileWatcher("content/examples/devtools.lua")
  watcher:onChanged(function() lurek.devtools.info("file changed") end)
  local changed = watcher:check()
  lurek.devtools.debug("file watcher changed=" .. tostring(changed))
end

--@api-stub: LFileWatcher:getPath
-- Returns the watched path.
do
  -- Useful when several watchers share one polling list.
  local watcher = lurek.devtools.newFileWatcher("content/levels/forest_01.toml")
  lurek.devtools.debug("watcher target: " .. watcher:getPath())
end

--@api-stub: LFileWatcher:cancel
-- Cancels this watcher and removes its callback.
do
  -- After cancel(), check() becomes a no-op and returns false.
  local watcher = lurek.devtools.newFileWatcher("conf.toml")
  watcher:onChanged(function() lurek.devtools.info("changed") end)
  watcher:cancel()
  lurek.devtools.debug("watcher cancelled for: " .. watcher:getPath())
end

--@api-stub: LFileWatcher:type
-- Returns the Lua-visible type name for this file watcher handle.
do
  -- The type string can drive debug inspector dispatch.
  local watcher = lurek.devtools.newFileWatcher("save/")
  lurek.devtools.debug("file watcher type=" .. watcher:type())
end

--@api-stub: LFileWatcher:typeOf
-- Returns whether this file watcher handle matches a supported type name.
do
  -- File watchers match LFileWatcher and Object.
  local watcher = lurek.devtools.newFileWatcher("save/")
  lurek.devtools.debug("is LFileWatcher=" .. tostring(watcher:typeOf("LFileWatcher")))
end

--@api-stub: lurek.devtools.newRepl
-- Creates a REPL console userdata with bounded command history.
do
  -- The REPL evaluates code in the current Lua VM and stores history.
  local repl = lurek.devtools.newRepl(100)
  local result = repl:eval("return math.pi * 2")
  lurek.devtools.info("repl pi*2=" .. tostring(result))
end

--@api-stub: LReplConsole:eval
-- Evaluates Lua code through this REPL console and records it in history.
do
  -- eval() can return a value and can also run side effects.
  local repl = lurek.devtools.newRepl(50)
  local greeting = repl:eval("return string.upper('hello world')")
  repl:eval("_G.debug_flag = true")
  local flag = repl:eval("return _G.debug_flag")
  lurek.devtools.info("repl greeting=" .. tostring(greeting) .. " flag=" .. tostring(flag))
end

--@api-stub: LReplConsole:history
-- Returns this REPL console's recorded command history.
do
  -- Use history for command recall in a developer console.
  local repl = lurek.devtools.newRepl(20)
  repl:eval("x = 1")
  repl:eval("x = x + 1")
  repl:eval("return x")
  local history = repl:history()
  lurek.devtools.info("repl history entries=" .. #history)
end

--@api-stub: LReplConsole:clear
-- Clears this REPL console's command history.
do
  -- A console clear command can wipe stored history.
  local repl = lurek.devtools.newRepl(10)
  repl:eval("return 1")
  repl:eval("return 2")
  repl:clear()
  lurek.devtools.debug("repl history after clear=" .. repl:len())
end

--@api-stub: LReplConsole:len
-- Returns the number of entries stored in this REPL console history.
do
  -- Show len() beside the configured history capacity.
  local repl = lurek.devtools.newRepl(100)
  repl:eval("return 'a'")
  repl:eval("return 'b'")
  lurek.devtools.info("REPL history: " .. repl:len() .. "/100")
end

--@api-stub: LReplConsole:type
-- Returns the Lua-visible type name for this REPL console handle.
do
  -- The type string helps generic inspectors label the handle.
  local repl = lurek.devtools.newRepl(50)
  lurek.devtools.debug("repl type=" .. repl:type())
end

--@api-stub: LReplConsole:typeOf
-- Returns whether this REPL console handle matches a supported type name.
do
  -- REPL consoles match LReplConsole and Object.
  local repl = lurek.devtools.newRepl(50)
  lurek.devtools.debug("is LReplConsole=" .. tostring(repl:typeOf("LReplConsole")))
end

print("content/examples/devtools.lua")
