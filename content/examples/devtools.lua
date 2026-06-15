-- content/examples/devtools.lua
-- Auto-generated from content/examples2/devtools_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/devtools.lua

--- DevTools Module Part 1: Logging, Profiling, Frame Stats, File Watches, Console, Inspector

--@api: lurek.devtools.log
do
    lurek.devtools.log("info", "game started")
    print("logged info message")
    print("current level = " .. lurek.devtools.getLogLevel())
end

--@api: lurek.devtools.trace
do
    lurek.devtools.trace("entering update loop")
    print("trace logged")
    print("current level = " .. lurek.devtools.getLogLevel())
end

--@api: lurek.devtools.debug
do
    lurek.devtools.debug("player pos = 100, 200")
    print("debug logged")
    print("current level = " .. lurek.devtools.getLogLevel())
end

--@api: lurek.devtools.info
do
    lurek.devtools.info("level loaded")
    print("info logged")
    print("current level = " .. lurek.devtools.getLogLevel())
end

--@api: lurek.devtools.warn
do
    lurek.devtools.warn("texture missing fallback used")
    print("warn logged")
    print("current level = " .. lurek.devtools.getLogLevel())
end

--@api: lurek.devtools.error
do
    lurek.devtools.error("save file warning emitted")
    print("error logged")
    print("current level = " .. lurek.devtools.getLogLevel())
end

--@api: lurek.devtools.fatal
do
    lurek.devtools.fatal("unrecoverable GPU error")
    print("fatal logged")
    print("current level = " .. lurek.devtools.getLogLevel())
end

--@api: lurek.devtools.setLogLevel
do
    lurek.devtools.setLogLevel("warn")
    print("log level set to warn")
    print("current level = " .. lurek.devtools.getLogLevel())
end

--@api: lurek.devtools.getLogLevel
do
    local level = lurek.devtools.getLogLevel()
    print("log level = " .. level)
    print("lua type = " .. type(level))
end

--@api: lurek.devtools.setLogConsole
do
    lurek.devtools.setLogConsole(true)
    print("console logging enabled")
    print("console logging = " .. tostring(lurek.devtools.getLogConsole()))
end

--@api: lurek.devtools.getLogConsole
do
    local console = lurek.devtools.getLogConsole()
    print("console = " .. tostring(console))
    print("lua type = " .. type(console))
end

--@api: lurek.devtools.setLogFile
do
    lurek.devtools.setLogFile("logs/devtools.log")
    print("log file set")
    print("log file = " .. tostring(lurek.devtools.getLogFile()))
end

--@api: lurek.devtools.getLogFile
do
    local fp = lurek.devtools.getLogFile()
    print("log file = " .. fp)
    print("lua type = " .. type(fp))
end

--@api: lurek.devtools.getLogHistory
do
    lurek.devtools.info("test entry")
    local entries = lurek.devtools.getLogHistory(5)
    print("log entries = " .. #entries)
end

--@api: lurek.devtools.clearLog
do
    lurek.devtools.info("will be cleared")
    lurek.devtools.clearLog()
    print("log cleared")
end

--@api: lurek.devtools.setProfilingEnabled
do
    lurek.devtools.setProfilingEnabled(true)
    print("profiling enabled")
    print("profiling = " .. tostring(lurek.devtools.isProfilingEnabled()))
end

--@api: lurek.devtools.isProfilingEnabled
do
    local v = lurek.devtools.isProfilingEnabled()
    print("profiling = " .. tostring(v))
    print("lua type = " .. type(v))
end

--@api: lurek.devtools.profilePush
do
    lurek.devtools.setProfilingEnabled(true)
    lurek.devtools.profilePush("physics")
    print("pushed physics zone")
end

--@api: lurek.devtools.profilePop
do
    lurek.devtools.setProfilingEnabled(true)
    lurek.devtools.profilePush("render")
    lurek.devtools.profilePop()
    print("popped render zone")
end

--@api: lurek.devtools.profileFrame
do
    lurek.devtools.setProfilingEnabled(true)
    lurek.devtools.profilePush("update")
    lurek.devtools.profilePop()
    lurek.devtools.profileFrame()
    print("frame stored")
end

--@api: lurek.devtools.getProfileFrameCount
do
    local n = lurek.devtools.getProfileFrameCount()
    print("profile frames = " .. n)
    print("lua type = " .. type(n))
end

--@api: lurek.devtools.getProfileData
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

--@api: lurek.devtools.resetProfile
do
    lurek.devtools.resetProfile()
    print("profile reset, frames = " .. lurek.devtools.getProfileFrameCount())
    print("profile frames = " .. tostring(lurek.devtools.getProfileFrameCount()))
end

--@api: lurek.devtools.recordFrameTime
do
    lurek.devtools.recordFrameTime(0.016)
    lurek.devtools.recordFrameTime(0.017)
    print("frame times recorded")
end

--@api: lurek.devtools.getFrameStats
do
    lurek.devtools.recordFrameTime(0.016)
    lurek.devtools.recordFrameTime(0.018)
    local stats = lurek.devtools.getFrameStats()
    print("fps = " .. tostring(stats.fps))
    print("samples = " .. tostring(stats.samples))
end

--@api: lurek.devtools.recordGpuFrameTime
do
    lurek.devtools.recordGpuFrameTime(0.008)
    print("gpu frame time recorded")
    print("profiling = " .. tostring(lurek.devtools.isProfilingEnabled()))
end

--@api: lurek.devtools.getGpuFrameStats
do
    lurek.devtools.recordGpuFrameTime(0.008)
    lurek.devtools.recordGpuFrameTime(0.009)
    local stats = lurek.devtools.getGpuFrameStats()
    print("gpu fps = " .. tostring(stats.fps))
    print("gpu samples = " .. tostring(stats.samples))
end

--@api: lurek.devtools.getFrameHistory
do
    lurek.devtools.recordFrameTime(0.016)
    local h = lurek.devtools.getFrameHistory()
    print("history count = " .. #h)
end

--@api: lurek.devtools.setFrameHistorySize
do
    lurek.devtools.setFrameHistorySize(120)
    print("history size set to 120")
    print("frame history size = " .. tostring(lurek.devtools.getFrameHistorySize()))
end

--@api: lurek.devtools.getFrameHistorySize
do
    local n = lurek.devtools.getFrameHistorySize()
    print("history capacity = " .. n)
    print("lua type = " .. type(n))
end

--@api: lurek.devtools.watch
do
    local added = lurek.devtools.watch("content/examples/assets/layouts/sample_menu.html")
    print("watch added = " .. tostring(added))
    print("watched paths = " .. tostring(#lurek.devtools.getWatchedPaths()))
end

--@api: lurek.devtools.unwatch
do
    lurek.devtools.watch("content/examples/assets/layouts/sample_menu.html")
    local removed = lurek.devtools.unwatch("content/examples/assets/layouts/sample_menu.html")
    print("removed = " .. tostring(removed))
end

--@api: lurek.devtools.getWatchedPaths
do
    lurek.devtools.watch("content/examples/assets/images")
    local paths = lurek.devtools.getWatchedPaths()
    print("watched = " .. #paths)
end

--@api: lurek.devtools.scan
do
    lurek.devtools.watch("content/examples/assets/layouts/sample_menu.html")
    local changed = lurek.devtools.scan()
    print("changed files = " .. #changed)
    print("watched paths = " .. #lurek.devtools.getWatchedPaths())
end

--@api: lurek.devtools.clearWatches
do
    lurek.devtools.watch("content/examples/assets/layouts/sample_menu.html")
    lurek.devtools.clearWatches()
    print("watches cleared, count = " .. #lurek.devtools.getWatchedPaths())
end

--@api: lurek.devtools.getWatchInterval
do
    local v = lurek.devtools.getWatchInterval()
    print("interval = " .. v)
    print("lua type = " .. type(v))
end

--@api: lurek.devtools.setWatchInterval
do
    lurek.devtools.setWatchInterval(0.5)
    print("interval set to 0.5s")
    print("watch interval = " .. tostring(lurek.devtools.getWatchInterval()))
end

--@api: lurek.devtools.getCallStack
do
    local frames = lurek.devtools.getCallStack(5)
    print("stack frames = " .. #frames)
    print("lua type = " .. type(frames))
end

--@api: lurek.devtools.eval
do
    local ok, value = lurek.devtools.eval("return 2 + 2")
    print("eval ok = " .. tostring(ok))
    print("eval value = " .. tostring(value))
end

--@api: lurek.devtools.openConsole
do
    local ok = lurek.devtools.openConsole()
    print("console opened = " .. tostring(ok))
    print("console open = " .. tostring(lurek.devtools.isConsoleOpen()))
end

--@api: lurek.devtools.isConsoleOpen
do
    local v = lurek.devtools.isConsoleOpen()
    print("console open = " .. tostring(v))
    print("lua type = " .. type(v))
end

--@api: lurek.devtools.openEntityInspector
do
    local ok = lurek.devtools.openEntityInspector()
    print("inspector opened = " .. tostring(ok))
    print("entity inspector open = " .. tostring(lurek.devtools.isEntityInspectorOpen()))
end

--@api: lurek.devtools.isEntityInspectorOpen
do
    local v = lurek.devtools.isEntityInspectorOpen()
    print("inspector open = " .. tostring(v))
    print("lua type = " .. type(v))
end

--@api: lurek.devtools.exposeWatch
do
    local id = lurek.devtools.exposeWatch("health", function() return 100 end, "player")
    print("watch id = " .. id)
    print("watch entries = " .. tostring(#lurek.devtools.getWatches()))
end

--@api: lurek.devtools.removeWatch
do
    local id = lurek.devtools.exposeWatch("temp", function() return 0 end)
    local ok = lurek.devtools.removeWatch(id)
    print("removed = " .. tostring(ok))
end

--@api: lurek.devtools.getWatches
do
    lurek.devtools.exposeWatch("score", function() return 42 end)
    local watches = lurek.devtools.getWatches()
    print("watch entries = " .. #watches)
end

--@api: lurek.devtools.snapshot
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

--@api: lurek.devtools.profilerReport
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

--@api: lurek.devtools.newFileWatcher
do
    local watcher = lurek.devtools.newFileWatcher("content/")
    print("watcher path = " .. watcher:getPath())
    print("lua type = " .. type(watcher))
end

--@api: lurek.devtools.newRepl
do
    local repl = lurek.devtools.newRepl(50)
    repl:eval("return 5 * 5")
    print("repl type = " .. repl:type())
    print("history len = " .. repl:len())
end

--- DevTools Module Part 2: LFileWatcher and LReplConsole Methods

--@api: LFileWatcher:onChanged
do
    local watcher = lurek.devtools.newFileWatcher("assets/")
    watcher:onChanged(function()
        print("file changed!")
    end)
    print("onChange callback set")
end

--@api: LFileWatcher:check
do
    local watcher = lurek.devtools.newFileWatcher("content/")
    local changed = watcher:check()
    print("change detected = " .. tostring(changed))
end

--@api: LFileWatcher:getPath
do
    local watcher = lurek.devtools.newFileWatcher("content/")
    print("watching = " .. watcher:getPath())
    print("owner type = " .. tostring(watcher:type()))
end

--@api: LFileWatcher:cancel
do
    local watcher = lurek.devtools.newFileWatcher("save/")
    watcher:cancel()
    print("watcher cancelled")
end

--@api: LFileWatcher:type
do
    local watcher = lurek.devtools.newFileWatcher("assets/")
    print("type = " .. watcher:type())
    print("typeOf LObject = " .. tostring(watcher:typeOf("LObject")))
end

--@api: LFileWatcher:typeOf
do
    local watcher = lurek.devtools.newFileWatcher("assets/textures/")
    print("is LFileWatcher = " .. tostring(watcher:typeOf("LFileWatcher")))
    print("type = " .. tostring(watcher:type()))
end

--@api: LReplConsole:eval
do
    local repl = lurek.devtools.newRepl(100)
    local result = repl:eval("return 1 + 1")
    print("eval result type = " .. type(result))
    print("history len = " .. repl:len())
end

--@api: LReplConsole:history
do
    local repl = lurek.devtools.newRepl(100)
    repl:eval("local x = 1")
    repl:eval("local y = 2")
    local h = repl:history()
    print("history entries = " .. #h)
end

--@api: LReplConsole:clear
do
    local repl = lurek.devtools.newRepl(100)
    repl:eval("print('hi')")
    repl:clear()
    print("history after clear = " .. repl:len())
end

--@api: LReplConsole:len
do
    local repl = lurek.devtools.newRepl(100)
    repl:eval("a = 1")
    repl:eval("b = 2")
    print("history len = " .. repl:len())
end

--@api: LReplConsole:type
do
    local repl = lurek.devtools.newRepl()
    print("type = " .. repl:type())
    print("typeOf LObject = " .. tostring(repl:typeOf("LObject")))
end

--@api: LReplConsole:typeOf
do
    local repl = lurek.devtools.newRepl()
    print("is LReplConsole = " .. tostring(repl:typeOf("LReplConsole")))
    print("type = " .. tostring(repl:type()))
end
