-- content/examples/devtools.lua
-- lurek.devtools API examples.
-- Run: cargo run -- content/examples/devtools.lua

--@api-stub: lurek.devtools.log -- Adds a message to the devtools log using an explicit severity level
do -- lurek.devtools.log
  local hp, max_hp = 12, 100
  local level = (hp < max_hp * 0.2) and "warn" or "info"
  lurek.devtools.log(level, "player hp " .. hp .. "/" .. max_hp)
end

--@api-stub: lurek.devtools.setLogLevel -- Sets the minimum severity that remains visible in devtools log output
do -- lurek.devtools.setLogLevel
  local shipping = false
  lurek.devtools.setLogLevel(shipping and "info" or "debug")
  lurek.devtools.debug("verbose traces enabled")
end

--@api-stub: lurek.devtools.getLogLevel -- Returns the minimum severity currently used by devtools log output
do -- lurek.devtools.getLogLevel
  local current = lurek.devtools.getLogLevel()
  if current == "trace" or current == "debug" then
    lurek.devtools.debug("verbose path active (level=" .. current .. ")")
  end
end

--@api-stub: lurek.devtools.setLogConsole -- Enables or disables mirroring devtools log entries to the console
do -- lurek.devtools.setLogConsole
  lurek.devtools.setLogConsole(true)
  lurek.devtools.info("console logging on; ready for live debugging")
end

--@api-stub: lurek.devtools.getLogConsole -- Returns whether devtools log entries are mirrored to the console
do -- lurek.devtools.getLogConsole
  if lurek.devtools.getLogConsole() then
    local entities = 128
    lurek.devtools.debug("world tick: entities=" .. entities)
  end
end

--@api-stub: lurek.devtools.setLogFile -- Sets the file path used by devtools file logging state
do -- lurek.devtools.setLogFile
  local session_id = 1742
  lurek.devtools.setLogFile("save/logs/session_" .. session_id .. ".log")
  lurek.devtools.info("session log file opened")
end

--@api-stub: lurek.devtools.getLogFile -- Returns the file path currently stored as the devtools log target
do -- lurek.devtools.getLogFile
  local path = lurek.devtools.getLogFile()
  if path == "" then
    lurek.devtools.warn("no log file configured; bug reports will lack file output")
  end
end

--@api-stub: lurek.devtools.getLogHistory -- Returns recent devtools log entries as structured tables
do -- lurek.devtools.getLogHistory
  lurek.devtools.info("loaded forest_01")
  local recent = lurek.devtools.getLogHistory(20)
  local last = recent[#recent]
  lurek.devtools.debug("last log: [" .. last.level .. "] " .. last.message)
end

--@api-stub: lurek.devtools.clearLog -- Clears all in-memory devtools log entries
do -- lurek.devtools.clearLog
  lurek.devtools.info("old session noise")
  lurek.devtools.clearLog()
  lurek.devtools.info("fresh start: level transition complete")
end

--@api-stub: lurek.devtools.setProfilingEnabled -- Enables or disables collection of CPU profiling zones
do -- lurek.devtools.setProfilingEnabled
  local debug_keys_held = true
  lurek.devtools.setProfilingEnabled(debug_keys_held)
  lurek.devtools.info("profiler now " .. (debug_keys_held and "on" or "off"))
end

--@api-stub: lurek.devtools.isProfilingEnabled -- Returns whether CPU profiling zone collection is currently enabled
do -- lurek.devtools.isProfilingEnabled
  if lurek.devtools.isProfilingEnabled() then
    lurek.devtools.profilePush("physics_step")
    lurek.devtools.profilePop()
  end
end

--@api-stub: lurek.devtools.profilePush -- Starts a named profiling zone on the current profiler stack
do -- lurek.devtools.profilePush
  lurek.devtools.setProfilingEnabled(true)
  lurek.devtools.profilePush("ai_update")
  lurek.devtools.profilePush("pathfinding")
  lurek.devtools.profilePop()
  lurek.devtools.profilePop()
end

--@api-stub: lurek.devtools.profilePop -- Ends the current profiling zone on the profiler stack
do -- lurek.devtools.profilePop
  lurek.devtools.setProfilingEnabled(true)
  lurek.devtools.profilePush("render_world")
  -- ... draw work happens here ...
  lurek.devtools.profilePop()
end

--@api-stub: lurek.devtools.profileFrame -- Closes the current profiling frame and stores its zone tree for later inspection
do -- lurek.devtools.profileFrame
  function lurek.process(dt)
    lurek.devtools.profilePush("frame")
    lurek.devtools.profilePop()
    lurek.devtools.profileFrame()
  end
end

--@api-stub: lurek.devtools.getProfileFrameCount -- Returns how many profiling frames are currently stored
do -- lurek.devtools.getProfileFrameCount
  local n = lurek.devtools.getProfileFrameCount()
  if n >= 60 then
    lurek.devtools.info("profiler has " .. n .. " frames buffered â€” ready to summarise")
  end
end

--@api-stub: lurek.devtools.getProfileData -- Returns the profiler zone tree for a retained frame
do -- lurek.devtools.getProfileData
  local zones = lurek.devtools.getProfileData(0)
  for _, z in ipairs(zones) do
    lurek.devtools.debug(z.name .. " total=" .. z.time .. "s self=" .. z.selfTime .. "s")
  end
end

--@api-stub: lurek.devtools.resetProfile -- Clears profiler state, active zones, and retained profiling frames
do -- lurek.devtools.resetProfile
  lurek.devtools.resetProfile()
  lurek.devtools.profilePush("benchmark")
  lurek.devtools.profilePop()
  lurek.devtools.profileFrame()
end

--@api-stub: lurek.devtools.recordFrameTime -- Records one CPU frame duration sample for devtools frame statistics
do -- lurek.devtools.recordFrameTime
  function lurek.process(dt)
    lurek.devtools.recordFrameTime(dt)
  end
end

--@api-stub: lurek.devtools.getFrameStats -- Returns aggregate CPU frame timing statistics from recorded samples
do -- lurek.devtools.getFrameStats
  lurek.devtools.recordFrameTime(1/60)
  local s = lurek.devtools.getFrameStats()
  if s.p99 > 0.020 then
    lurek.devtools.warn("p99 frame time " .. s.p99 .. "s exceeds 20ms budget")
  end
end

--@api-stub: lurek.devtools.recordGpuFrameTime -- Records one GPU frame duration sample for devtools frame statistics
do -- lurek.devtools.recordGpuFrameTime
  function lurek.process(dt)
    lurek.devtools.recordGpuFrameTime(dt * 0.8)
  end
end

--@api-stub: lurek.devtools.getGpuFrameStats -- Returns aggregate GPU frame timing statistics from recorded samples
do -- lurek.devtools.getGpuFrameStats
  lurek.devtools.recordGpuFrameTime(1/90)
  local gpu = lurek.devtools.getGpuFrameStats()
  lurek.devtools.info("gpu avg dt=" .. gpu.avg .. " samples=" .. gpu.samples)
end

--@api-stub: lurek.devtools.getFrameHistory -- Returns retained CPU frame duration samples in insertion order
do -- lurek.devtools.getFrameHistory
  lurek.devtools.recordFrameTime(0.016)
  local history = lurek.devtools.getFrameHistory()
  local latest = history[#history] or 0
  lurek.devtools.debug("latest frame: " .. (latest * 1000) .. " ms")
end

--@api-stub: lurek.devtools.setFrameHistorySize -- Sets the maximum number of CPU frame duration samples retained by devtools
do -- lurek.devtools.setFrameHistorySize
  lurek.devtools.setFrameHistorySize(600)
  lurek.devtools.info("frame history sized for approx 10s at 60fps")
end

--@api-stub: lurek.devtools.getFrameHistorySize -- Returns the current CPU frame history capacity
do -- lurek.devtools.getFrameHistorySize
  lurek.devtools.setFrameHistorySize(50000)
  local cap = lurek.devtools.getFrameHistorySize()
  lurek.devtools.info("frame history capacity = " .. cap .. " (clamped from 50000)")
end

--@api-stub: lurek.devtools.watch -- Adds a path to the module-level devtools file watcher
do -- lurek.devtools.watch
  local added = lurek.devtools.watch("content/examples/devtools.lua")
  if added then
    lurek.devtools.info("now watching devtools.lua for live reload")
  end
end

--@api-stub: lurek.devtools.unwatch -- Removes a path from the module-level devtools file watcher
do -- lurek.devtools.unwatch
  lurek.devtools.watch("content/levels/forest_01.toml")
  local removed = lurek.devtools.unwatch("content/levels/forest_01.toml")
  lurek.devtools.debug("unwatched: " .. tostring(removed))
end

--@api-stub: lurek.devtools.getWatchedPaths -- Returns all paths currently watched by the module-level file watcher
do -- lurek.devtools.getWatchedPaths
  lurek.devtools.watch("conf.toml")
  local paths = lurek.devtools.getWatchedPaths()
  lurek.devtools.info("watching " .. #paths .. " path(s)")
end

--@api-stub: lurek.devtools.scan -- Polls module-level file watches and returns paths that changed since the previous scan
do -- lurek.devtools.scan
  lurek.devtools.watch("content/examples/devtools.lua")
  function lurek.process(dt)
    for _, path in ipairs(lurek.devtools.scan()) do
      lurek.devtools.info("reload: " .. path)
    end
  end
end

--@api-stub: lurek.devtools.clearWatches -- Removes every path from the module-level file watcher
do -- lurek.devtools.clearWatches
  lurek.devtools.watch("a.lua")
  lurek.devtools.watch("b.lua")
  lurek.devtools.clearWatches()
  lurek.devtools.info("watch list cleared (" .. #lurek.devtools.getWatchedPaths() .. " remain)")
end

--@api-stub: lurek.devtools.getWatchInterval -- Returns the polling interval hint used by devtools watch UIs
do -- lurek.devtools.getWatchInterval
  local interval = lurek.devtools.getWatchInterval()
  if interval > 1.0 then
    lurek.devtools.warn("watch poll every " .. interval .. "s feels sluggish; consider 0.25")
  end
end

--@api-stub: lurek.devtools.setWatchInterval -- Sets the polling interval hint used by devtools watch UIs
do -- lurek.devtools.setWatchInterval
  lurek.devtools.setWatchInterval(0.25)
  lurek.devtools.info("hot-reload poll @ " .. lurek.devtools.getWatchInterval() .. "s")
end

--@api-stub: lurek.devtools.getCallStack -- Returns Lua call stack frames using the Lua debug library
do -- lurek.devtools.getCallStack
  local frames = lurek.devtools.getCallStack(10)
  for i, f in ipairs(frames) do
    lurek.devtools.debug("frame " .. i .. ": " .. f.source .. ":" .. f.line .. " in " .. f.name)
  end
end

--@api-stub: lurek.devtools.eval -- Evaluates Lua code in the current state and returns success plus values or failure plus an error message
do -- lurek.devtools.eval
  local ok, value = lurek.devtools.eval("return 21 * 2")
  if ok then
    lurek.devtools.info("eval result = " .. tostring(value))
  end
end

--@api-stub: lurek.devtools.openConsole -- Marks the devtools console as open for UI state tracking
do -- lurek.devtools.openConsole
  lurek.devtools.openConsole()
  lurek.devtools.info("console flag is now " .. tostring(lurek.devtools.isConsoleOpen()))
end

--@api-stub: lurek.devtools.isConsoleOpen -- Returns whether the devtools console is marked open
do -- lurek.devtools.isConsoleOpen
  function lurek.draw_ui()
    if lurek.devtools.isConsoleOpen() then
      -- console panel would be drawn here
    end
  end
end

--@api-stub: lurek.devtools.openEntityInspector -- Marks the devtools entity inspector as open for UI state tracking
do -- lurek.devtools.openEntityInspector
  lurek.devtools.openEntityInspector()
end

--@api-stub: lurek.devtools.isEntityInspectorOpen -- Returns whether the devtools entity inspector is marked open
do -- lurek.devtools.isEntityInspectorOpen
  if lurek.devtools.isEntityInspectorOpen() then
    lurek.devtools.debug("entity inspector active")
  end
end

--@api-stub: lurek.devtools.exposeWatch -- Registers a watch expression callback for snapshots and watch panels
do -- lurek.devtools.exposeWatch
  local player = { x = 256, y = 128, hp = 80 }
  local id_x = lurek.devtools.exposeWatch("player.x", function() return player.x end, "actor")
  local id_hp = lurek.devtools.exposeWatch("player.hp", function() return player.hp end, "combat")
  lurek.devtools.debug("registered watch ids " .. id_x .. ", " .. id_hp)
end

--@api-stub: lurek.devtools.removeWatch -- Removes a previously exposed watch expression by id
do -- lurek.devtools.removeWatch
  local fps_value = 60
  local id = lurek.devtools.exposeWatch("fps", function() return fps_value end)
  local removed = lurek.devtools.removeWatch(id)
  lurek.devtools.debug("removed watch " .. id .. " -> " .. tostring(removed))
end

--@api-stub: lurek.devtools.getWatches -- Evaluates exposed watch callbacks and returns their current values
do -- lurek.devtools.getWatches
  local score = 1500
  lurek.devtools.exposeWatch("score", function() return score end, "hud")
  for _, w in ipairs(lurek.devtools.getWatches()) do
    lurek.devtools.info(w.category .. "/" .. w.name .. " = " .. tostring(w.value))
  end
end

--@api-stub: lurek.devtools.snapshot -- Captures a combined devtools snapshot containing frame stats, watch values, profile data, and recent logs
do -- lurek.devtools.snapshot
  lurek.devtools.recordFrameTime(0.016)
  local snap = lurek.devtools.snapshot()
  lurek.devtools.info("snapshot: fps=" .. snap.frameStats.fps .. " watches=" .. snap.watchCount)
end

--@api-stub: lurek.devtools.profilerReport -- Aggregates retained profiler frames into per-zone timing rows
do -- lurek.devtools.profilerReport
  lurek.devtools.profilePush("sim")
  lurek.devtools.profilePop()
  lurek.devtools.profileFrame()
  for _, row in ipairs(lurek.devtools.profilerReport()) do
    lurek.devtools.info(row.name .. " avg=" .. row.avg_ms .. "ms over " .. row.calls .. " calls")
  end
end

--@api-stub: lurek.devtools.newFileWatcher -- Creates a dedicated file watcher userdata for one path
do -- lurek.devtools.newFileWatcher
  local fw = lurek.devtools.newFileWatcher("content/examples/devtools.lua")
  fw:onChanged(function() lurek.devtools.info("devtools.lua changed; reloading") end)
  function lurek.process(dt) fw:check() end
end

--@api-stub: lurek.devtools.newRepl -- Creates a REPL console userdata with bounded command history
do -- lurek.devtools.newRepl
  local repl = lurek.devtools.newRepl(100)
  local result = repl:eval("return math.pi * 2")
  lurek.devtools.info("repl said: " .. result)
end

-- â”€â”€ FileWatcher methods â”€â”€

--@api-stub: FileWatcher:onChanged
do -- FileWatcher:onChanged
  local fw = lurek.devtools.newFileWatcher("conf.toml")
  local reloads = 0
  fw:onChanged(function() reloads = reloads + 1; lurek.devtools.info("reload #" .. reloads) end)
end

--@api-stub: FileWatcher:check
do -- FileWatcher:check
  local fw = lurek.devtools.newFileWatcher("content/examples/devtools.lua")
  function lurek.process(dt)
    if fw:check() then lurek.devtools.info("devtools.lua reloaded") end
  end
end

--@api-stub: FileWatcher:getPath
do -- FileWatcher:getPath
  local fw = lurek.devtools.newFileWatcher("content/levels/forest_01.toml")
  fw:onChanged(function() lurek.devtools.info("changed: " .. fw:getPath()) end)
end

--@api-stub: FileWatcher:cancel
do -- FileWatcher:cancel
  local fw = lurek.devtools.newFileWatcher("conf.toml")
  fw:onChanged(function() end)
  fw:cancel()
  lurek.devtools.debug("watcher cancelled for " .. fw:getPath())
end

-- â”€â”€ ReplConsole methods â”€â”€

--@api-stub: ReplConsole:eval
do -- ReplConsole:eval
  local repl = lurek.devtools.newRepl(50)
  local out = repl:eval("return string.upper('hello')")
  lurek.devtools.info("> " .. out)
end

--@api-stub: ReplConsole:history
do -- ReplConsole:history
  local repl = lurek.devtools.newRepl(20)
  repl:eval("x = 1")
  repl:eval("return x + 1")
  for i, line in ipairs(repl:history()) do
    lurek.devtools.debug(i .. ": " .. line)
  end
end

--@api-stub: ReplConsole:clear
do -- ReplConsole:clear
  local repl = lurek.devtools.newRepl(10)
  repl:eval("return 1")
  repl:clear()
  lurek.devtools.debug("history len after clear = " .. repl:len())
end

--@api-stub: ReplConsole:len
do -- ReplConsole:len
  local repl = lurek.devtools.newRepl(100)
  repl:eval("print('hi')")
  if repl:len() > 0 then
    lurek.devtools.info("REPL has " .. repl:len() .. " stored line(s)")
  end
end

-- =============================================================================
-- COVERAGE: 7 uncovered lurek.devtools API item(s)
-- Generated by tools/audit/example_add_missing.py
-- REQUIRED: replace every --@api-stub: block below with a real scenario.
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- The final committed file must contain ZERO --@api-stub: lines.
-- =============================================================================

--@api-stub: lurek.devtools.trace -- Adds a trace-level diagnostic message to the devtools log
do -- lurek.devtools.trace
  local dt = 1 / 60
  lurek.devtools.trace("frame dt=" .. dt)
  lurek.devtools.trace("update done")
end

--@api-stub: lurek.devtools.error -- Adds an error-level diagnostic message to the devtools log
do -- lurek.devtools.error
  local path = "assets/missing.png"
  lurek.devtools.error("asset not found: " .. path)
  lurek.devtools.error("continuing with placeholder")
end

--@api-stub: lurek.devtools.fatal -- Adds a fatal-level diagnostic message to the devtools log
do -- lurek.devtools.fatal
  local ok, result = pcall(function()
    lurek.devtools.fatal("save system unavailable")
  end)
  -- fatal is informational; does not itself raise
end


-- -----------------------------------------------------------------------------
-- ReplConsole methods
-- -----------------------------------------------------------------------------

-- =============================================================================
-- COVERAGE: 4 uncovered lurek.devtools API item(s)
-- Generated by tools/audit/example_add_missing.py
-- REQUIRED: replace every --@api-stub: block below with a real scenario.
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- The final committed file must contain ZERO --@api-stub: lines.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- LFileWatcher methods
-- -----------------------------------------------------------------------------

--@api-stub: LFileWatcher:type -- Returns the Lua-visible type name for this file watcher handle
do -- LFileWatcher:type
  local file_watcher_obj = lurek.devtools.newFileWatcher("save/")
  local t = file_watcher_obj:type()
  lurek.log.info("LFileWatcher:type = " .. t, "devtools")
end
--@api-stub: LFileWatcher:typeOf -- Returns whether this file watcher handle matches a supported type name
do -- LFileWatcher:typeOf
  local file_watcher_obj = lurek.devtools.newFileWatcher("save/")
  lurek.log.info("is LFileWatcher: " .. tostring(file_watcher_obj:typeOf("LFileWatcher")), "devtools")
  lurek.log.info("is wrong: " .. tostring(file_watcher_obj:typeOf("Unknown")), "devtools")
end
--@api-stub: LReplConsole:type -- Returns the Lua-visible type name for this REPL console handle
do -- LReplConsole:type
  local repl_console_obj = lurek.devtools.newRepl(50)
  local t = repl_console_obj:type()
  lurek.log.info("LReplConsole:type = " .. t, "devtools")
end
--@api-stub: LReplConsole:typeOf -- Returns whether this REPL console handle matches a supported type name
do -- LReplConsole:typeOf
  local repl_console_obj = lurek.devtools.newRepl(50)
  lurek.log.info("is LReplConsole: " .. tostring(repl_console_obj:typeOf("LReplConsole")), "devtools")
  lurek.log.info("is wrong: " .. tostring(repl_console_obj:typeOf("Unknown")), "devtools")
end

--@api-stub: lurek.devtools.debug -- Adds a debug-level diagnostic message to the devtools log
do -- lurek.devtools.debug
  lurek.devtools.debug("debug trace: player_x=32.5, frame=120")
end
--@api-stub: lurek.devtools.info -- Adds an info-level diagnostic message to the devtools log
do -- lurek.devtools.info
  lurek.devtools.info("game loaded: level=1, entities=42")
end
--@api-stub: lurek.devtools.warn -- Adds a warning-level diagnostic message to the devtools log
do -- lurek.devtools.warn
  lurek.devtools.warn("texture cache miss: assets/hero.png")
end
