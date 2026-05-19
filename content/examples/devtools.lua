-- content/examples/devtools.lua
-- Auto-generated from content/examples2/devtools_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/devtools.lua

--- DevTools Module Part 1: Logging, Profiling, Frame Stats, File Watches, Console, Inspector


--@api-stub: lurek.devtools.log
-- Adds a message at an explicit severity level.
do
    lurek.devtools.log("info", "game started")
    print("logged info message")
end

--@api-stub: lurek.devtools.trace
-- Adds a trace-level message.
do
    lurek.devtools.trace("entering update loop")
    print("trace logged")
end

--@api-stub: lurek.devtools.debug
-- Adds a debug-level message.
do
    lurek.devtools.debug("player pos = 100, 200")
    print("debug logged")
end

--@api-stub: lurek.devtools.info
-- Adds an info-level message.
do
    lurek.devtools.info("level loaded")
    print("info logged")
end

--@api-stub: lurek.devtools.warn
-- Adds a warning-level message.
do
    lurek.devtools.warn("texture missing fallback used")
    print("warn logged")
end

--@api-stub: lurek.devtools.error
-- Adds an error-level message.
do
    lurek.devtools.error("failed to load save file")
    print("error logged")
end

--@api-stub: lurek.devtools.fatal
-- Adds a fatal-level message.
do
    lurek.devtools.fatal("unrecoverable GPU error")
    print("fatal logged")
end

--@api-stub: lurek.devtools.setLogLevel
-- Sets minimum severity for log output.
do
    lurek.devtools.setLogLevel("warn")
    print("log level set to warn")
end

--@api-stub: lurek.devtools.getLogLevel
-- Returns the current minimum log severity.
do
    local level = lurek.devtools.getLogLevel()
    print("log level = " .. level)
end

--@api-stub: lurek.devtools.setLogConsole
-- Enables or disables mirroring log entries to console.
do
    lurek.devtools.setLogConsole(true)
    print("console logging enabled")
end

--@api-stub: lurek.devtools.getLogConsole
-- Returns whether log entries are mirrored to console.
do
    print("console = " .. tostring(lurek.devtools.getLogConsole()))
end

--@api-stub: lurek.devtools.setLogFile
-- Sets the devtools log file path.
do
    lurek.devtools.setLogFile("logs/devtools.log")
    print("log file set")
end

--@api-stub: lurek.devtools.getLogFile
-- Returns the current devtools log file path.
do
    local fp = lurek.devtools.getLogFile()
    print("log file = " .. fp)
end

--@api-stub: lurek.devtools.getLogHistory
-- Returns recent log entries as structured tables.
do
    lurek.devtools.info("test entry")
    local entries = lurek.devtools.getLogHistory(5)
    print("log entries = " .. #entries)
end

--@api-stub: lurek.devtools.clearLog
-- Clears all in-memory devtools log entries.
do
    lurek.devtools.info("will be cleared")
    lurek.devtools.clearLog()
    print("log cleared")
end

--@api-stub: lurek.devtools.setProfilingEnabled
-- Enables or disables CPU profiling zone collection.
do
    lurek.devtools.setProfilingEnabled(true)
    print("profiling enabled")
end

--@api-stub: lurek.devtools.isProfilingEnabled
-- Returns whether profiling is enabled.
do
    print("profiling = " .. tostring(lurek.devtools.isProfilingEnabled()))
end

--@api-stub: lurek.devtools.profilePush
-- Starts a named profiling zone.
do
    lurek.devtools.setProfilingEnabled(true)
    lurek.devtools.profilePush("physics")
    print("pushed physics zone")
end

--@api-stub: lurek.devtools.profilePop
-- Ends the current profiling zone.
do
    lurek.devtools.setProfilingEnabled(true)
    lurek.devtools.profilePush("render")
    lurek.devtools.profilePop()
    print("popped render zone")
end

--@api-stub: lurek.devtools.profileFrame
-- Closes the current frame and stores its zone tree.
do
    lurek.devtools.setProfilingEnabled(true)
    lurek.devtools.profilePush("update")
    lurek.devtools.profilePop()
    lurek.devtools.profileFrame()
    print("frame stored")
end

--@api-stub: lurek.devtools.getProfileFrameCount
-- Returns how many profiling frames are stored.
do
    print("profile frames = " .. lurek.devtools.getProfileFrameCount())
end

--@api-stub: lurek.devtools.getProfileData
-- Returns the profiler zone tree for a frame.
do
    local data = lurek.devtools.getProfileData()
    print("profile data type = " .. type(data))
end

--@api-stub: lurek.devtools.resetProfile
-- Clears profiler state and all retained frames.
do
    lurek.devtools.resetProfile()
    print("profile reset, frames = " .. lurek.devtools.getProfileFrameCount())
end

--@api-stub: lurek.devtools.recordFrameTime
-- Records one CPU frame duration sample.
do
    lurek.devtools.recordFrameTime(0.016)
    lurek.devtools.recordFrameTime(0.017)
    print("frame times recorded")
end

--@api-stub: lurek.devtools.getFrameStats
-- Returns aggregate CPU frame timing statistics.
do
    lurek.devtools.recordFrameTime(0.016)
    local stats = lurek.devtools.getFrameStats()
    print("fps = " .. stats.fps .. " avg = " .. stats.avg)
end

--@api-stub: lurek.devtools.recordGpuFrameTime
-- Records one GPU frame duration sample.
do
    lurek.devtools.recordGpuFrameTime(0.008)
    print("gpu frame time recorded")
end

--@api-stub: lurek.devtools.getGpuFrameStats
-- Returns aggregate GPU frame timing statistics.
do
    lurek.devtools.recordGpuFrameTime(0.008)
    local stats = lurek.devtools.getGpuFrameStats()
    print("gpu fps = " .. stats.fps)
end

--@api-stub: lurek.devtools.getFrameHistory
-- Returns retained CPU frame duration samples.
do
    lurek.devtools.recordFrameTime(0.016)
    local h = lurek.devtools.getFrameHistory()
    print("history count = " .. #h)
end

--@api-stub: lurek.devtools.setFrameHistorySize
-- Sets maximum retained frame samples.
do
    lurek.devtools.setFrameHistorySize(120)
    print("history size set to 120")
end

--@api-stub: lurek.devtools.getFrameHistorySize
-- Returns the current frame history capacity.
do
    print("history capacity = " .. lurek.devtools.getFrameHistorySize())
end

--@api-stub: lurek.devtools.watch
-- Adds a path to the module-level file watcher.
do
    local added = lurek.devtools.watch("scripts/main.lua")
    print("watch added = " .. tostring(added))
end

--@api-stub: lurek.devtools.unwatch
-- Removes a path from the file watcher.
do
    lurek.devtools.watch("scripts/main.lua")
    local removed = lurek.devtools.unwatch("scripts/main.lua")
    print("removed = " .. tostring(removed))
end

--@api-stub: lurek.devtools.getWatchedPaths
-- Returns all paths currently watched.
do
    lurek.devtools.watch("assets/sprites")
    local paths = lurek.devtools.getWatchedPaths()
    print("watched = " .. #paths)
end

--@api-stub: lurek.devtools.scan
-- Polls file watches and returns paths that changed.
do
    local changed = lurek.devtools.scan()
    print("changed files = " .. #changed)
end

--@api-stub: lurek.devtools.clearWatches
-- Removes every path from the file watcher.
do
    lurek.devtools.watch("a.lua")
    lurek.devtools.clearWatches()
    print("watches cleared, count = " .. #lurek.devtools.getWatchedPaths())
end

--@api-stub: lurek.devtools.getWatchInterval
-- Returns the polling interval hint.
do
    print("interval = " .. lurek.devtools.getWatchInterval())
end

--@api-stub: lurek.devtools.setWatchInterval
-- Sets the polling interval hint.
do
    lurek.devtools.setWatchInterval(0.5)
    print("interval set to 0.5s")
end

--@api-stub: lurek.devtools.getCallStack
-- Returns Lua call stack frames.
do
    local frames = lurek.devtools.getCallStack(5)
    print("stack frames = " .. #frames)
end

--@api-stub: lurek.devtools.eval
-- Evaluates Lua code and returns success plus result.
do
    local result = lurek.devtools.eval("return 2 + 2")
    print("eval result type = " .. type(result))
end

--@api-stub: lurek.devtools.openConsole
-- Marks the devtools console as open.
do
    local ok = lurek.devtools.openConsole()
    print("console opened = " .. tostring(ok))
end

--@api-stub: lurek.devtools.isConsoleOpen
-- Returns whether the console is marked open.
do
    print("console open = " .. tostring(lurek.devtools.isConsoleOpen()))
end

--@api-stub: lurek.devtools.openEntityInspector
-- Marks the entity inspector as open.
do
    local ok = lurek.devtools.openEntityInspector()
    print("inspector opened = " .. tostring(ok))
end

--@api-stub: lurek.devtools.isEntityInspectorOpen
-- Returns whether the entity inspector is marked open.
do
    print("inspector open = " .. tostring(lurek.devtools.isEntityInspectorOpen()))
end

--@api-stub: lurek.devtools.exposeWatch
-- Registers a watch expression callback.
do
    local id = lurek.devtools.exposeWatch("health", function() return 100 end, "player")
    print("watch id = " .. id)
end

--@api-stub: lurek.devtools.removeWatch
-- Removes a previously exposed watch by id.
do
    local id = lurek.devtools.exposeWatch("temp", function() return 0 end)
    local ok = lurek.devtools.removeWatch(id)
    print("removed = " .. tostring(ok))
end

--@api-stub: lurek.devtools.getWatches
-- Evaluates exposed watch callbacks and returns current values.
do
    lurek.devtools.exposeWatch("score", function() return 42 end)
    local watches = lurek.devtools.getWatches()
    print("watch entries = " .. #watches)
end

--@api-stub: lurek.devtools.snapshot
-- Captures a combined devtools snapshot.
do
    local snap = lurek.devtools.snapshot()
    print("snapshot keys: frameStats, watches, profile, log")
end

--@api-stub: lurek.devtools.profilerReport
-- Aggregates retained frames into per-zone timing rows.
do
    local report = lurek.devtools.profilerReport()
    print("report zones = " .. #report)
end

--@api-stub: lurek.devtools.newFileWatcher
-- Creates a dedicated file watcher handle for one path.
do
    local watcher = lurek.devtools.newFileWatcher("scripts/")
    print("watcher path = " .. watcher:getPath())
end

--@api-stub: lurek.devtools.newRepl
-- Creates a REPL console handle with bounded history.
do
    local repl = lurek.devtools.newRepl(50)
    print("repl type = " .. repl:type())
end

--- DevTools Module Part 2: LFileWatcher and LReplConsole Methods


--@api-stub: LFileWatcher:onChanged
-- Sets the callback invoked when a watched file changes.
do
    local watcher = lurek.devtools.newFileWatcher("assets/")
    watcher:onChanged(function()
        print("file changed!")
    end)
    print("onChange callback set")
end

--@api-stub: LFileWatcher:check
-- Polls the watcher and invokes the callback on change.
do
    local watcher = lurek.devtools.newFileWatcher("scripts/")
    local changed = watcher:check()
    print("change detected = " .. tostring(changed))
end

--@api-stub: LFileWatcher:getPath
-- Returns the watched path.
do
    local watcher = lurek.devtools.newFileWatcher("content/")
    print("watching = " .. watcher:getPath())
end

--@api-stub: LFileWatcher:cancel
-- Cancels this watcher and removes its callback.
do
    local watcher = lurek.devtools.newFileWatcher("temp/")
    watcher:cancel()
    print("watcher cancelled")
end

--@api-stub: LFileWatcher:type
-- Returns the type name ("LFileWatcher").
do
    local watcher = lurek.devtools.newFileWatcher("x/")
    print("type = " .. watcher:type())
end

--@api-stub: LFileWatcher:typeOf
-- Returns whether this handle matches a type name.
do
    local watcher = lurek.devtools.newFileWatcher("y/")
    print("is LFileWatcher = " .. tostring(watcher:typeOf("LFileWatcher")))
end

--@api-stub: LReplConsole:eval
-- Evaluates Lua code and records it in history.
do
    local repl = lurek.devtools.newRepl(100)
    local result = repl:eval("return 1 + 1")
    print("eval result type = " .. type(result))
end

--@api-stub: LReplConsole:history
-- Returns the REPL command history.
do
    local repl = lurek.devtools.newRepl(100)
    repl:eval("local x = 1")
    repl:eval("local y = 2")
    local h = repl:history()
    print("history entries = " .. #h)
end

--@api-stub: LReplConsole:clear
-- Clears the REPL command history.
do
    local repl = lurek.devtools.newRepl(100)
    repl:eval("print('hi')")
    repl:clear()
    print("history after clear = " .. repl:len())
end

--@api-stub: LReplConsole:len
-- Returns the number of entries in history.
do
    local repl = lurek.devtools.newRepl(100)
    repl:eval("a = 1")
    repl:eval("b = 2")
    print("history len = " .. repl:len())
end

--@api-stub: LReplConsole:type
-- Returns the type name ("LReplConsole").
do
    local repl = lurek.devtools.newRepl()
    print("type = " .. repl:type())
end

--@api-stub: LReplConsole:typeOf
-- Returns whether this handle matches a type name.
do
    local repl = lurek.devtools.newRepl()
    print("is LReplConsole = " .. tostring(repl:typeOf("LReplConsole")))
end

print("content/examples/devtools.lua")
