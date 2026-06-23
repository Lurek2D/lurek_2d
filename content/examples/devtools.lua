-- content/examples/devtools.lua
-- Auto-generated from content/examples2/devtools_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/devtools.lua

--- DevTools Module Part 1: Logging, Profiling, Frame Stats, File Watches, Console, Inspector


--@api: lurek.devtools.log
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.devtools.log("info", "game started")
    lurek.devtools.log("warn", "shader cache cold on first boot")
    local level = lurek.devtools.getLogLevel()
    local history = lurek.devtools.getLogHistory(2)
    lurek.log.info("devtools log level=" .. tostring(level))
    lurek.log.info("devtools log history rows=" .. tostring(#history))
end

--@api: lurek.devtools.trace
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.devtools.trace("entering update loop")
    lurek.devtools.trace("polling input before simulation")
    local level = lurek.devtools.getLogLevel()
    local history = lurek.devtools.getLogHistory(2)
    lurek.log.info("trace level gate=" .. tostring(level))
    lurek.log.info("trace history rows=" .. tostring(#history))
end

--@api: lurek.devtools.debug
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.devtools.debug("player pos = 100, 200")
    lurek.devtools.debug("camera follow target = player_1")
    local level = lurek.devtools.getLogLevel()
    local history = lurek.devtools.getLogHistory(2)
    lurek.log.info("debug level gate=" .. tostring(level))
    lurek.log.info("debug history rows=" .. tostring(#history))
end

--@api: lurek.devtools.info
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.devtools.info("level loaded")
    lurek.devtools.info("checkpoint state restored")
    local level = lurek.devtools.getLogLevel()
    local history = lurek.devtools.getLogHistory(2)
    lurek.log.info("info level gate=" .. tostring(level))
    lurek.log.info("info history rows=" .. tostring(#history))
end

--@api: lurek.devtools.warn
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.devtools.warn("texture missing fallback used")
    lurek.devtools.warn("navmesh using last valid bake")
    local level = lurek.devtools.getLogLevel()
    local history = lurek.devtools.getLogHistory(2)
    lurek.log.info("warn level gate=" .. tostring(level))
    lurek.log.info("warn history rows=" .. tostring(#history))
end

--@api: lurek.devtools.error
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.devtools.error("save file warning emitted")
    lurek.devtools.error("quest state patch failed validation")
    local level = lurek.devtools.getLogLevel()
    local history = lurek.devtools.getLogHistory(2)
    lurek.log.info("error level gate=" .. tostring(level))
    lurek.log.info("error history rows=" .. tostring(#history))
end

--@api: lurek.devtools.fatal
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.devtools.fatal("unrecoverable GPU error")
    lurek.devtools.fatal("recovery path exhausted for render backend")
    local level = lurek.devtools.getLogLevel()
    local history = lurek.devtools.getLogHistory(2)
    lurek.log.info("fatal level gate=" .. tostring(level))
    lurek.log.info("fatal history rows=" .. tostring(#history))
end

--@api: lurek.devtools.setLogLevel
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.devtools.setLogLevel("warn")
    lurek.devtools.info("hidden by warn gate")
    lurek.devtools.warn("visible warning after gate change")
    local currentLevel = lurek.devtools.getLogLevel()
    local history = lurek.devtools.getLogHistory(3)
    lurek.log.info("log level set to=" .. tostring(currentLevel))
    lurek.log.info("history rows after gate change=" .. tostring(#history))
end

--@api: lurek.devtools.getLogLevel
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local level = lurek.devtools.getLogLevel()
    lurek.devtools.setLogLevel("info")
    local refreshed = lurek.devtools.getLogLevel()
    local levelType = type(level)
    lurek.log.info("initial log level=" .. tostring(level))
    lurek.log.info("refreshed log level=" .. tostring(refreshed) .. " type=" .. tostring(levelType))
end

--@api: lurek.devtools.setLogConsole
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.devtools.setLogConsole(true)
    lurek.devtools.info("console mirror enabled for local debugging")
    local consoleEnabled = lurek.devtools.getLogConsole()
    local history = lurek.devtools.getLogHistory(1)
    lurek.log.info("console mirror enabled=" .. tostring(consoleEnabled))
    lurek.log.info("history rows after mirror toggle=" .. tostring(#history))
end

--@api: lurek.devtools.getLogConsole
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local console = lurek.devtools.getLogConsole()
    lurek.devtools.setLogConsole(not console)
    local toggled = lurek.devtools.getLogConsole()
    local consoleType = type(console)
    lurek.log.info("console mirror initial=" .. tostring(console))
    lurek.log.info("console mirror toggled=" .. tostring(toggled) .. " type=" .. tostring(consoleType))
end

--@api: lurek.devtools.setLogFile
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.devtools.setLogFile("save/devtools_example.log")
    lurek.devtools.info("writing runtime diagnostics to save/devtools_example.log")
    local logFile = lurek.devtools.getLogFile()
    local history = lurek.devtools.getLogHistory(1)
    lurek.log.info("log file path=" .. tostring(logFile))
    lurek.log.info("history rows after file target change=" .. tostring(#history))
end

--@api: lurek.devtools.getLogFile
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fp = lurek.devtools.getLogFile()
    lurek.devtools.setLogFile("save/devtools_session.log")
    local updated = lurek.devtools.getLogFile()
    local fileType = type(updated)
    lurek.log.info("previous log file=" .. tostring(fp))
    lurek.log.info("current log file=" .. tostring(updated) .. " type=" .. tostring(fileType))
end

--@api: lurek.devtools.getLogHistory
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.devtools.info("test entry")
    local entries = lurek.devtools.getLogHistory(5)
    lurek.devtools.warn("second test entry")
    local latestEntries = lurek.devtools.getLogHistory(5)
    lurek.log.info("log history entries=" .. tostring(#entries))
    lurek.log.info("log history after second entry=" .. tostring(#latestEntries))
end

--@api: lurek.devtools.clearLog
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.devtools.info("will be cleared")
    local beforeClear = lurek.devtools.getLogHistory()
    lurek.devtools.clearLog()
    local afterClear = lurek.devtools.getLogHistory()
    lurek.log.info("log rows before clear=" .. tostring(#beforeClear))
    lurek.log.info("log rows after clear=" .. tostring(#afterClear))
end

--@api: lurek.devtools.setProfilingEnabled
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.devtools.setProfilingEnabled(true)
    lurek.devtools.profilePush("bootstrap")
    lurek.devtools.profilePop()
    local enabled = lurek.devtools.isProfilingEnabled()
    lurek.log.info("profiling enabled=" .. tostring(enabled))
    lurek.log.info("profile frame count=" .. tostring(lurek.devtools.getProfileFrameCount()))
end

--@api: lurek.devtools.isProfilingEnabled
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.devtools.isProfilingEnabled()
    lurek.devtools.setProfilingEnabled(not v)
    local toggled = lurek.devtools.isProfilingEnabled()
    local valueType = type(v)
    lurek.log.info("profiling initial=" .. tostring(v))
    lurek.log.info("profiling toggled=" .. tostring(toggled) .. " type=" .. tostring(valueType))
end

--@api: lurek.devtools.profilePush
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.devtools.setProfilingEnabled(true)
    lurek.devtools.profilePush("physics")
    lurek.devtools.profilePop()
    lurek.devtools.profileFrame()
    local frames = lurek.devtools.getProfileFrameCount()
    lurek.log.info("pushed and closed physics zone")
    lurek.log.info("stored profile frames=" .. tostring(frames))
end

--@api: lurek.devtools.profilePop
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.devtools.setProfilingEnabled(true)
    lurek.devtools.profilePush("render")
    lurek.devtools.profilePop()
    lurek.devtools.profileFrame()
    local frames = lurek.devtools.getProfileFrameCount()
    local report = lurek.devtools.profilerReport()
    lurek.log.info("popped render zone and stored frame")
    lurek.log.info("profile frames=" .. tostring(frames) .. " report rows=" .. tostring(#report))
end

--@api: lurek.devtools.profileFrame
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.devtools.setProfilingEnabled(true)
    lurek.devtools.profilePush("update")
    lurek.devtools.profilePop()
    lurek.devtools.profileFrame()
    example_print_log("frame stored")
end

--@api: lurek.devtools.getProfileFrameCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local n = lurek.devtools.getProfileFrameCount()
    lurek.devtools.setProfilingEnabled(true)
    lurek.devtools.profilePush("count")
    lurek.devtools.profilePop()
    lurek.devtools.profileFrame()
    lurek.log.info("profile frames before sample=" .. tostring(n))
    lurek.log.info("profile frames after sample=" .. tostring(lurek.devtools.getProfileFrameCount()))
end

--@api: lurek.devtools.getProfileData
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.devtools.setProfilingEnabled(true)
    lurek.devtools.profilePush("update")
    lurek.devtools.profilePop()
    lurek.devtools.profileFrame()
    local frames = lurek.devtools.getProfileData()
    example_print_log("profile rows = " .. #frames)
    if frames[1] then
        example_print_log("first zone = " .. tostring(frames[1].name))
    end
end

--@api: lurek.devtools.resetProfile
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

--@api: lurek.devtools.recordFrameTime
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.devtools.recordFrameTime(0.016)
    lurek.devtools.recordFrameTime(0.017)
    local history = lurek.devtools.getFrameHistory()
    local stats = lurek.devtools.getFrameStats()
    lurek.log.info("cpu frame samples=" .. tostring(#history))
    lurek.log.info("cpu fps estimate=" .. tostring(stats.fps))
end

--@api: lurek.devtools.getFrameStats
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.devtools.recordFrameTime(0.016)
    lurek.devtools.recordFrameTime(0.018)
    local stats = lurek.devtools.getFrameStats()
    example_print_log("fps = " .. tostring(stats.fps))
    example_print_log("samples = " .. tostring(stats.samples))
end

--@api: lurek.devtools.recordGpuFrameTime
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.devtools.recordGpuFrameTime(0.008)
    lurek.devtools.recordGpuFrameTime(0.009)
    local stats = lurek.devtools.getGpuFrameStats()
    local profiling = lurek.devtools.isProfilingEnabled()
    lurek.log.info("gpu samples=" .. tostring(stats.samples))
    lurek.log.info("gpu profiling flag=" .. tostring(profiling))
end

--@api: lurek.devtools.getGpuFrameStats
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.devtools.recordGpuFrameTime(0.008)
    lurek.devtools.recordGpuFrameTime(0.009)
    local stats = lurek.devtools.getGpuFrameStats()
    example_print_log("gpu fps = " .. tostring(stats.fps))
    example_print_log("gpu samples = " .. tostring(stats.samples))
end

--@api: lurek.devtools.getFrameHistory
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.devtools.recordFrameTime(0.016)
    local h = lurek.devtools.getFrameHistory()
    lurek.devtools.recordFrameTime(0.018)
    local latest = lurek.devtools.getFrameHistory()
    lurek.log.info("frame history count initial=" .. tostring(#h))
    lurek.log.info("frame history count updated=" .. tostring(#latest))
end

--@api: lurek.devtools.setFrameHistorySize
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.devtools.setFrameHistorySize(120)
    lurek.devtools.recordFrameTime(0.016)
    local historySize = lurek.devtools.getFrameHistorySize()
    local stats = lurek.devtools.getFrameStats()
    lurek.log.info("frame history size=" .. tostring(historySize))
    lurek.log.info("frame stats samples after resize=" .. tostring(stats.samples))
end

--@api: lurek.devtools.getFrameHistorySize
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local n = lurek.devtools.getFrameHistorySize()
    lurek.devtools.setFrameHistorySize(90)
    local updated = lurek.devtools.getFrameHistorySize()
    local valueType = type(n)
    lurek.log.info("frame history size initial=" .. tostring(n))
    lurek.log.info("frame history size updated=" .. tostring(updated) .. " type=" .. tostring(valueType))
end

--@api: lurek.devtools.watch
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local added = lurek.devtools.watch("content/examples/assets/layouts/sample_main_menu.toml")
    lurek.devtools.watch("content/examples/assets/images")
    local watchedPaths = lurek.devtools.getWatchedPaths()
    lurek.log.info("watch added=" .. tostring(added))
    lurek.log.info("watched paths count=" .. tostring(#watchedPaths))
end

--@api: lurek.devtools.unwatch
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.devtools.watch("content/examples/assets/layouts/sample_main_menu.toml")
    local removed = lurek.devtools.unwatch("content/examples/assets/layouts/sample_main_menu.toml")
    local watchedPaths = lurek.devtools.getWatchedPaths()
    local count = #watchedPaths
    lurek.log.info("watch removed=" .. tostring(removed))
    lurek.log.info("watched path count after remove=" .. tostring(count))
end

--@api: lurek.devtools.getWatchedPaths
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.devtools.watch("content/examples/assets/images")
    local paths = lurek.devtools.getWatchedPaths()
    lurek.devtools.watch("content/examples/assets/layouts/sample_main_menu.toml")
    local updated = lurek.devtools.getWatchedPaths()
    lurek.log.info("watched path count initial=" .. tostring(#paths))
    lurek.log.info("watched path count updated=" .. tostring(#updated))
end

--@api: lurek.devtools.scan
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.devtools.watch("content/examples/assets/layouts/sample_main_menu.toml")
    local changed = lurek.devtools.scan()
    local watchedPaths = lurek.devtools.getWatchedPaths()
    local interval = lurek.devtools.getWatchInterval()
    lurek.log.info("changed files count=" .. tostring(#changed))
    lurek.log.info("watched paths=" .. tostring(#watchedPaths) .. " interval=" .. tostring(interval))
end

--@api: lurek.devtools.clearWatches
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.devtools.watch("content/examples/assets/layouts/sample_main_menu.toml")
    local beforeClear = lurek.devtools.getWatchedPaths()
    lurek.devtools.clearWatches()
    local afterClear = lurek.devtools.getWatchedPaths()
    lurek.log.info("watched paths before clear=" .. tostring(#beforeClear))
    lurek.log.info("watched paths after clear=" .. tostring(#afterClear))
end

--@api: lurek.devtools.getWatchInterval
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.devtools.getWatchInterval()
    lurek.devtools.setWatchInterval(0.75)
    local updated = lurek.devtools.getWatchInterval()
    local valueType = type(v)
    lurek.log.info("watch interval initial=" .. tostring(v))
    lurek.log.info("watch interval updated=" .. tostring(updated) .. " type=" .. tostring(valueType))
end

--@api: lurek.devtools.setWatchInterval
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.devtools.setWatchInterval(0.5)
    lurek.devtools.watch("content/examples/assets/layouts/sample_main_menu.toml")
    local interval = lurek.devtools.getWatchInterval()
    local watchedPaths = lurek.devtools.getWatchedPaths()
    lurek.log.info("watch interval set to=" .. tostring(interval))
    lurek.log.info("watched paths after interval set=" .. tostring(#watchedPaths))
end

--@api: lurek.devtools.getCallStack
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local frames = lurek.devtools.getCallStack(5)
    local stackDepth = #frames
    local firstFrame = frames[1] and (frames[1].name or frames[1].source) or "none"
    local framesType = type(frames)
    lurek.log.info("call stack depth=" .. tostring(stackDepth))
    lurek.log.info("call stack first frame=" .. tostring(firstFrame) .. " type=" .. tostring(framesType))
end

--@api: lurek.devtools.eval
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ok, value = lurek.devtools.eval("return 2 + 2")
    local badOk, badValue = lurek.devtools.eval("invalid syntax %%%")
    local stack = lurek.devtools.getCallStack(2)
    lurek.log.info("eval success=" .. tostring(ok) .. " value=" .. tostring(value))
    lurek.log.info("eval failure=" .. tostring(badOk) .. " error=" .. tostring(badValue) .. " stack=" .. tostring(#stack))
end

--@api: lurek.devtools.openConsole
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ok = lurek.devtools.openConsole()
    local isOpen = lurek.devtools.isConsoleOpen()
    local stack = lurek.devtools.getCallStack(2)
    lurek.log.info("console opened=" .. tostring(ok))
    lurek.log.info("console open state=" .. tostring(isOpen) .. " stack depth=" .. tostring(#stack))
end

--@api: lurek.devtools.isConsoleOpen
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.devtools.isConsoleOpen()
    lurek.devtools.openConsole()
    local updated = lurek.devtools.isConsoleOpen()
    local valueType = type(v)
    lurek.log.info("console open initial=" .. tostring(v))
    lurek.log.info("console open updated=" .. tostring(updated) .. " type=" .. tostring(valueType))
end

--@api: lurek.devtools.openEntityInspector
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ok = lurek.devtools.openEntityInspector()
    local isOpen = lurek.devtools.isEntityInspectorOpen()
    local snapshot = lurek.devtools.snapshot()
    lurek.log.info("entity inspector opened=" .. tostring(ok))
    lurek.log.info("entity inspector state=" .. tostring(isOpen) .. " watch count=" .. tostring(snapshot.watchCount))
end

--@api: lurek.devtools.isEntityInspectorOpen
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.devtools.isEntityInspectorOpen()
    lurek.devtools.openEntityInspector()
    local updated = lurek.devtools.isEntityInspectorOpen()
    local valueType = type(v)
    lurek.log.info("entity inspector initial=" .. tostring(v))
    lurek.log.info("entity inspector updated=" .. tostring(updated) .. " type=" .. tostring(valueType))
end

--@api: lurek.devtools.exposeWatch
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local id = lurek.devtools.exposeWatch("health", function() return 100 end, "player")
    local watchEntries = lurek.devtools.getWatches()
    local snapshot = lurek.devtools.snapshot()
    lurek.log.info("watch id=" .. tostring(id))
    lurek.log.info("watch entries=" .. tostring(#watchEntries) .. " snapshot count=" .. tostring(snapshot.watchCount))
end

--@api: lurek.devtools.removeWatch
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local id = lurek.devtools.exposeWatch("temp", function() return 0 end)
    local ok = lurek.devtools.removeWatch(id)
    local watchEntries = lurek.devtools.getWatches()
    local snapshot = lurek.devtools.snapshot()
    lurek.log.info("watch removed=" .. tostring(ok))
    lurek.log.info("watch entries after remove=" .. tostring(#watchEntries) .. " snapshot count=" .. tostring(snapshot.watchCount))
end

--@api: lurek.devtools.getWatches
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.devtools.exposeWatch("score", function() return 42 end)
    local watches = lurek.devtools.getWatches()
    lurek.devtools.exposeWatch("ammo", function() return 12 end, "hud")
    local updated = lurek.devtools.getWatches()
    lurek.log.info("watch entries initial=" .. tostring(#watches))
    lurek.log.info("watch entries updated=" .. tostring(#updated))
end

--@api: lurek.devtools.snapshot
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.devtools.recordFrameTime(0.016)
    lurek.devtools.info("snapshot ready")
    lurek.devtools.exposeWatch("score", function()
        return 42
    end, "hud")
    local snap = lurek.devtools.snapshot()
    example_print_log("watch count = " .. tostring(snap.watchCount))
    example_print_log("log rows = " .. tostring(#snap.log))
end

--@api: lurek.devtools.profilerReport
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.devtools.setProfilingEnabled(true)
    lurek.devtools.profilePush("render")
    lurek.devtools.profilePop()
    lurek.devtools.profileFrame()
    local report = lurek.devtools.profilerReport()
    example_print_log("report rows = " .. #report)
    if report[1] then
        example_print_log("first report zone = " .. tostring(report[1].name))
    end
end

--@api: lurek.devtools.newFileWatcher
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local watcher = lurek.devtools.newFileWatcher("content/")
    local path = watcher:getPath()
    local typeName = watcher:type()
    local changed = watcher:check()
    lurek.log.info("file watcher path=" .. tostring(path))
    lurek.log.info("file watcher type=" .. tostring(typeName) .. " changed=" .. tostring(changed))
end

--@api: lurek.devtools.newRepl
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local repl = lurek.devtools.newRepl(50)
    repl:eval("return 5 * 5")
    local historyLen = repl:len()
    local typeName = repl:type()
    local history = repl:history()
    lurek.log.info("repl type=" .. tostring(typeName))
    lurek.log.info("repl history len=" .. tostring(historyLen) .. " entries=" .. tostring(#history))
end

--- DevTools Module Part 2: LFileWatcher and LReplConsole Methods

--@api: LFileWatcher:onChanged
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local watcher = lurek.devtools.newFileWatcher("assets/")
    watcher:onChanged(function()
        example_print_log("file changed!")
    end)
    example_print_log("onChange callback set")
end

--@api: LFileWatcher:check
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local watcher = lurek.devtools.newFileWatcher("content/")
    local changed = watcher:check()
    local path = watcher:getPath()
    local typeName = watcher:type()
    lurek.log.info("file watcher changed=" .. tostring(changed))
    lurek.log.info("file watcher path=" .. tostring(path) .. " type=" .. tostring(typeName))
end

--@api: LFileWatcher:getPath
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local watcher = lurek.devtools.newFileWatcher("content/")
    local path = watcher:getPath()
    local typeName = watcher:type()
    local changed = watcher:check()
    lurek.log.info("watcher path=" .. tostring(path))
    lurek.log.info("watcher type=" .. tostring(typeName) .. " changed=" .. tostring(changed))
end

--@api: LFileWatcher:cancel
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local watcher = lurek.devtools.newFileWatcher("save/")
    watcher:cancel()
    local path = watcher:getPath()
    local changed = watcher:check()
    lurek.log.info("watcher cancelled for path=" .. tostring(path))
    lurek.log.info("watcher changed after cancel=" .. tostring(changed))
end

--@api: LFileWatcher:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local watcher = lurek.devtools.newFileWatcher("assets/")
    local typeName = watcher:type()
    local isObject = watcher:typeOf("LObject")
    local path = watcher:getPath()
    lurek.log.info("file watcher type=" .. tostring(typeName))
    lurek.log.info("file watcher path=" .. tostring(path) .. " is object=" .. tostring(isObject))
end

--@api: LFileWatcher:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local watcher = lurek.devtools.newFileWatcher("assets/textures/")
    local isWatcher = watcher:typeOf("LFileWatcher")
    local typeName = watcher:type()
    local path = watcher:getPath()
    lurek.log.info("is LFileWatcher=" .. tostring(isWatcher))
    lurek.log.info("file watcher path=" .. tostring(path) .. " type=" .. tostring(typeName))
end

--@api: LReplConsole:eval
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local repl = lurek.devtools.newRepl(100)
    local result = repl:eval("return 1 + 1")
    local historyLen = repl:len()
    local history = repl:history()
    lurek.log.info("repl eval result type=" .. tostring(type(result)))
    lurek.log.info("repl history len=" .. tostring(historyLen) .. " entries=" .. tostring(#history))
end

--@api: LReplConsole:history
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local repl = lurek.devtools.newRepl(100)
    repl:eval("local x = 1")
    repl:eval("local y = 2")
    local h = repl:history()
    example_print_log("history entries = " .. #h)
end

--@api: LReplConsole:clear
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local repl = lurek.devtools.newRepl(100)
    repl:eval("print('hi')")
    local beforeClear = repl:len()
    repl:clear()
    local afterClear = repl:len()
    local history = repl:history()
    lurek.log.info("repl history before clear=" .. tostring(beforeClear))
    lurek.log.info("repl history after clear=" .. tostring(afterClear) .. " entries=" .. tostring(#history))
end

--@api: LReplConsole:len
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local repl = lurek.devtools.newRepl(100)
    repl:eval("a = 1")
    repl:eval("b = 2")
    local historyLen = repl:len()
    local history = repl:history()
    lurek.log.info("repl history len=" .. tostring(historyLen))
    lurek.log.info("repl history entries=" .. tostring(#history))
end

--@api: LReplConsole:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local repl = lurek.devtools.newRepl()
    repl:eval("return 'warmup'")
    local typeName = repl:type()
    local isObject = repl:typeOf("LObject")
    lurek.log.info("repl type=" .. tostring(typeName))
    lurek.log.info("repl is object=" .. tostring(isObject))
end

--@api: LReplConsole:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local repl = lurek.devtools.newRepl()
    repl:eval("return 'warmup'")
    local isRepl = repl:typeOf("LReplConsole")
    local typeName = repl:type()
    lurek.log.info("is LReplConsole=" .. tostring(isRepl))
    lurek.log.info("repl type=" .. tostring(typeName))
end
