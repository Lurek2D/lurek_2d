-- tests/lua/test_devtools.lua
-- BDD-style integration tests for lurek.devtools module

-- ===================================================================
-- Logger
-- ===================================================================

-- @describe lurek.devtools logger
describe("lurek.devtools logger", function()
    it("exists as a table", function()
        expect_not_nil(lurek.devtools)
    end)

    -- @integration lurek.devtools.getLogLevel
    it("defaults log level to info", function()
        expect_equal("info", lurek.devtools.getLogLevel())
    end)

    -- @integration lurek.devtools.getLogLevel
    -- @integration lurek.devtools.setLogLevel
    it("can set and get log level", function()
        lurek.devtools.setLogLevel("warn")
        expect_equal("warn", lurek.devtools.getLogLevel())
        lurek.devtools.setLogLevel("info")
    end)

    -- @integration lurek.devtools.getLogConsole
    it("defaults log console to true", function()
        expect_equal(true, lurek.devtools.getLogConsole())
    end)

    -- @integration lurek.devtools.getLogConsole
    -- @integration lurek.devtools.setLogConsole
    it("can toggle console logging", function()
        lurek.devtools.setLogConsole(false)
        expect_equal(false, lurek.devtools.getLogConsole())
        lurek.devtools.setLogConsole(true)
    end)

    -- @integration lurek.devtools.getLogFile
    -- @integration lurek.devtools.setLogFile
    it("can set and get log file path", function()
        lurek.devtools.setLogFile("test.log")
        expect_equal("test.log", lurek.devtools.getLogFile())
        lurek.devtools.setLogFile("")
    end)

    -- @integration lurek.devtools.clearLog
    -- @integration lurek.devtools.getLogHistory
    -- @integration lurek.devtools.info
    -- @integration lurek.devtools.setLogConsole
    it("records log entries", function()
        lurek.devtools.clearLog()
        lurek.devtools.setLogConsole(false) -- suppress stderr noise
        lurek.devtools.info("test message")
        local history = lurek.devtools.getLogHistory()
        expect_true(#history >= 1)
        expect_equal("info", history[#history].level)
        expect_equal("test message", history[#history].message)
        lurek.devtools.setLogConsole(true)
    end)

    -- @integration lurek.devtools.clearLog
    -- @integration lurek.devtools.getLogHistory
    -- @integration lurek.devtools.info
    -- @integration lurek.devtools.setLogConsole
    -- @integration lurek.devtools.setLogLevel
    it("filters below minimum level", function()
        lurek.devtools.clearLog()
        lurek.devtools.setLogConsole(false)
        lurek.devtools.setLogLevel("error")
        lurek.devtools.info("should be ignored")
        local history = lurek.devtools.getLogHistory()
        expect_equal(0, #history)
        lurek.devtools.setLogLevel("info")
        lurek.devtools.setLogConsole(true)
    end)

    -- @integration lurek.devtools.clearLog
    -- @integration lurek.devtools.getLogHistory
    -- @integration lurek.devtools.info
    -- @integration lurek.devtools.setLogConsole
    it("clearLog empties history", function()
        lurek.devtools.setLogConsole(false)
        lurek.devtools.info("will be cleared")
        lurek.devtools.clearLog()
        expect_equal(0, #lurek.devtools.getLogHistory())
        lurek.devtools.setLogConsole(true)
    end)

    -- @integration lurek.devtools.clearLog
    -- @integration lurek.devtools.getLogHistory
    -- @integration lurek.devtools.info
    -- @integration lurek.devtools.setLogConsole
    it("getLogHistory respects count", function()
        lurek.devtools.clearLog()
        lurek.devtools.setLogConsole(false)
        lurek.devtools.info("a")
        lurek.devtools.info("b")
        lurek.devtools.info("c")
        local last2 = lurek.devtools.getLogHistory(2)
        expect_equal(2, #last2)
        expect_equal("b", last2[1].message)
        expect_equal("c", last2[2].message)
        lurek.devtools.setLogConsole(true)
    end)
end)

-- ===================================================================
-- Frame Statistics
-- ===================================================================
-- @describe lurek.devtools frame stats
describe("lurek.devtools frame stats", function()
    -- @integration lurek.devtools.getFrameHistorySize
    it("defaults frame history size to 300", function()
        expect_equal(300, lurek.devtools.getFrameHistorySize())
    end)

    -- @integration lurek.devtools.getFrameHistory
    -- @integration lurek.devtools.recordFrameTime
    it("can record and retrieve frame times", function()
        lurek.devtools.recordFrameTime(0.016)
        lurek.devtools.recordFrameTime(0.017)
        local history = lurek.devtools.getFrameHistory()
        expect_true(#history >= 2)
    end)

    -- @integration lurek.devtools.getFrameStats
    -- @integration lurek.devtools.recordFrameTime
    it("computes frame stats", function()
        -- Record some known values
        for i = 1, 10 do
            lurek.devtools.recordFrameTime(0.016)
        end
        local stats = lurek.devtools.getFrameStats()
        expect_not_nil(stats.fps)
        expect_not_nil(stats.avg)
        expect_not_nil(stats.min)
        expect_not_nil(stats.max)
        expect_not_nil(stats.p50)
        expect_not_nil(stats.p95)
        expect_not_nil(stats.p99)
    end)

    -- @integration lurek.devtools.getFrameHistorySize
    -- @integration lurek.devtools.setFrameHistorySize
    it("can change frame history size", function()
        lurek.devtools.setFrameHistorySize(50)
        expect_equal(50, lurek.devtools.getFrameHistorySize())
        lurek.devtools.setFrameHistorySize(300) -- restore
    end)

    -- @integration lurek.devtools.getFrameHistorySize
    -- @integration lurek.devtools.setFrameHistorySize
    it("clamps history size", function()
        lurek.devtools.setFrameHistorySize(1)
        expect_equal(10, lurek.devtools.getFrameHistorySize())
        lurek.devtools.setFrameHistorySize(300)
    end)
end)

-- ===================================================================
-- Profiler
-- ===================================================================
-- @describe lurek.devtools profiler
describe("lurek.devtools profiler", function()
    -- @integration lurek.devtools.isProfilingEnabled
    it("defaults profiling to disabled", function()
        expect_equal(false, lurek.devtools.isProfilingEnabled())
    end)

    -- @integration lurek.devtools.isProfilingEnabled
    -- @integration lurek.devtools.setProfilingEnabled
    it("can enable profiling", function()
        lurek.devtools.setProfilingEnabled(true)
        expect_equal(true, lurek.devtools.isProfilingEnabled())
        lurek.devtools.setProfilingEnabled(false)
    end)

    -- @integration lurek.devtools.getProfileData
    -- @integration lurek.devtools.getProfileFrameCount
    -- @integration lurek.devtools.profileFrame
    -- @integration lurek.devtools.profilePop
    -- @integration lurek.devtools.profilePush
    -- @integration lurek.devtools.resetProfile
    -- @integration lurek.devtools.setProfilingEnabled
    it("records and retrieves profile zones", function()
        lurek.devtools.setProfilingEnabled(true)
        lurek.devtools.profilePush("render")
        lurek.devtools.profilePush("sprites")
        lurek.devtools.profilePop()
        lurek.devtools.profilePop()
        lurek.devtools.profileFrame()
        expect_true(lurek.devtools.getProfileFrameCount() >= 1)
        local data = lurek.devtools.getProfileData()
        expect_true(#data >= 1)
        expect_equal("render", data[1].name)
        lurek.devtools.resetProfile()
        lurek.devtools.setProfilingEnabled(false)
    end)

    -- @integration lurek.devtools.getProfileFrameCount
    -- @integration lurek.devtools.profileFrame
    -- @integration lurek.devtools.profilePop
    -- @integration lurek.devtools.profilePush
    -- @integration lurek.devtools.resetProfile
    -- @integration lurek.devtools.setProfilingEnabled
    it("resetProfile clears all data", function()
        lurek.devtools.setProfilingEnabled(true)
        lurek.devtools.profilePush("test")
        lurek.devtools.profilePop()
        lurek.devtools.profileFrame()
        lurek.devtools.resetProfile()
        expect_equal(0, lurek.devtools.getProfileFrameCount())
        lurek.devtools.setProfilingEnabled(false)
    end)
end)

-- ===================================================================
-- File Watcher
-- ===================================================================
-- @describe lurek.devtools file watcher
describe("lurek.devtools file watcher", function()
    -- @integration lurek.devtools.clearWatches
    -- @integration lurek.devtools.getWatchedPaths
    it("starts with no watched paths", function()
        lurek.devtools.clearWatches()
        expect_equal(0, #lurek.devtools.getWatchedPaths())
    end)

    -- @integration lurek.devtools.getWatchInterval
    it("defaults watch interval to 0.5", function()
        local interval = lurek.devtools.getWatchInterval()
        expect_true(math.abs(interval - 0.5) < 0.01)
    end)

    -- @integration lurek.devtools.getWatchInterval
    -- @integration lurek.devtools.setWatchInterval
    it("can set watch interval", function()
        lurek.devtools.setWatchInterval(1.0)
        expect_true(math.abs(lurek.devtools.getWatchInterval() - 1.0) < 0.01)
        lurek.devtools.setWatchInterval(0.5)
    end)

    -- @integration lurek.devtools.clearWatches
    -- @integration lurek.devtools.getWatchedPaths
    -- @integration lurek.devtools.unwatch
    -- @integration lurek.devtools.watch
    it("can watch and unwatch paths", function()
        lurek.devtools.clearWatches()
        local added = lurek.devtools.watch("nonexistent_test_file.txt")
        expect_true(added)
        expect_equal(1, #lurek.devtools.getWatchedPaths())
        local removed = lurek.devtools.unwatch("nonexistent_test_file.txt")
        expect_true(removed)
        expect_equal(0, #lurek.devtools.getWatchedPaths())
    end)

    -- @integration lurek.devtools.clearWatches
    -- @integration lurek.devtools.watch
    it("watch returns false if already watched", function()
        lurek.devtools.clearWatches()
        lurek.devtools.watch("test.txt")
        local second = lurek.devtools.watch("test.txt")
        expect_equal(false, second)
        lurek.devtools.clearWatches()
    end)
end)

-- ===================================================================
-- Debug Bridge
-- ===================================================================
-- @describe lurek.devtools debug bridge
describe("lurek.devtools debug bridge", function()
    -- @integration lurek.devtools.getCallStack
    it("getCallStack returns a table", function()
        local stack = lurek.devtools.getCallStack()
        expect_not_nil(stack)
    end)

    -- @integration lurek.devtools.eval
    it("eval succeeds with valid code", function()
        local ok, result = lurek.devtools.eval("return 1 + 2")
        expect_true(ok)
        expect_equal(3, result)
    end)

    -- @integration lurek.devtools.eval
    it("eval fails with invalid code", function()
        local ok, err = lurek.devtools.eval("invalid code here %%%")
        expect_equal(false, ok)
        expect_not_nil(err)
    end)
end)

-- ===================================================================
-- Console
-- ===================================================================
-- @describe lurek.devtools console
describe("lurek.devtools console", function()
    -- @integration lurek.devtools.isConsoleOpen
    it("defaults console to not open", function()
        expect_equal(false, lurek.devtools.isConsoleOpen())
    end)

    -- @integration lurek.devtools.isConsoleOpen
    -- @integration lurek.devtools.openConsole
    it("openConsole marks it as open", function()
        lurek.devtools.openConsole()
        expect_equal(true, lurek.devtools.isConsoleOpen())
    end)
end)
test_summary()
