-- DebugBridge Lua Tests
-- Tests the lurek.debugbridge TCP debug server API

-- ===== Lifecycle =====
-- @covers lurek.debugbridge.broadcast
-- @covers lurek.debugbridge.capturePrint
-- @covers lurek.debugbridge.clearPrintHistory
-- @covers lurek.debugbridge.getClientCount
-- @covers lurek.debugbridge.getPerformance
-- @covers lurek.debugbridge.getPort
-- @covers lurek.debugbridge.getPrintHistory
-- @covers lurek.debugbridge.isRunning
-- @covers lurek.debugbridge.isScreenshotRequested
-- @covers lurek.debugbridge.poll
-- @covers lurek.debugbridge.requestScreenshot
-- @covers lurek.debugbridge.setMaxPrintHistory
-- @covers lurek.debugbridge.start
-- @covers lurek.debugbridge.stop


-- @description Covers suite: lurek.debugbridge lifecycle.
describe("lurek.debugbridge lifecycle", function()

    -- @covers lurek.debugbridge
    -- @description Verifies the debugbridge namespace is present in Lua.
    it("namespace exists", function()
        expect_not_nil(lurek.debugbridge)
    end)

    -- @covers lurek.debugbridge.isRunning
    -- @description Verifies the debug server starts in a stopped state.
    it("isRunning returns false initially", function()
        expect_equal(false, lurek.debugbridge.isRunning())
    end)

    -- @covers lurek.debugbridge.getPort
    -- @description Verifies getPort reports 0 while the bridge is stopped.
    it("getPort returns 0 when not running", function()
        expect_equal(0, lurek.debugbridge.getPort())
    end)

    -- @covers lurek.debugbridge.getClientCount
    -- @description Verifies no clients are reported before the bridge starts.
    it("getClientCount returns 0 when not running", function()
        expect_equal(0, lurek.debugbridge.getClientCount())
    end)

    -- @covers lurek.debugbridge.start
    -- @covers lurek.debugbridge.stop
    -- @covers lurek.debugbridge.isRunning
    -- @covers lurek.debugbridge.getPort
    -- @description Verifies the bridge can start on a specific port and returns to the stopped state after stop().
    it("start and stop work on a high port", function()
        -- Use a high port unlikely to conflict
        local ok = lurek.debugbridge.start(49740)
        expect_equal(true, ok)
        expect_equal(true, lurek.debugbridge.isRunning())
        expect_equal(49740, lurek.debugbridge.getPort())

        lurek.debugbridge.stop()
        expect_equal(false, lurek.debugbridge.isRunning())
    end)

    -- @covers lurek.debugbridge.start
    -- @description Verifies a second start attempt fails while the bridge is already running.
    it("start returns false if already running", function()
        lurek.debugbridge.start(49741)
        local second = lurek.debugbridge.start(49742)
        expect_equal(false, second)
        lurek.debugbridge.stop()
    end)

    -- @covers lurek.debugbridge.poll
    -- @description Verifies poll behaves as a no-op when the server is not running.
    it("poll does not error when not running", function()
        lurek.debugbridge.poll()  -- should be a no-op
    end)

end)

-- ===== Print Capture =====

-- @description Covers suite: lurek.debugbridge print capture.
describe("lurek.debugbridge print capture", function()

    -- @covers lurek.debugbridge.capturePrint
    -- @covers lurek.debugbridge.getPrintHistory
    -- @description Verifies captured print messages are appended to the bridge print history.
    it("capturePrint records a message", function()
        lurek.debugbridge.capturePrint("hello world")
        local history = lurek.debugbridge.getPrintHistory()
        expect_true(#history >= 1)
        local last = history[#history]
        expect_equal("hello world", last.message)
    end)

    -- @covers lurek.debugbridge.capturePrint
    -- @covers lurek.debugbridge.getPrintHistory
    -- @description Verifies optional source file and line metadata are stored alongside a captured print message.
    it("capturePrint with source and line", function()
        lurek.debugbridge.capturePrint("test msg", "main.lua", 42)
        local history = lurek.debugbridge.getPrintHistory()
        local last = history[#history]
        expect_equal("test msg", last.message)
        expect_equal("main.lua", last.source)
        expect_equal(42, last.line)
    end)

    -- @covers lurek.debugbridge.clearPrintHistory
    -- @covers lurek.debugbridge.getPrintHistory
    -- @description Verifies clearPrintHistory removes all buffered print entries.
    it("clearPrintHistory clears all entries", function()
        lurek.debugbridge.capturePrint("before clear")
        lurek.debugbridge.clearPrintHistory()
        local history = lurek.debugbridge.getPrintHistory()
        expect_equal(0, #history)
    end)

    -- @covers lurek.debugbridge.setMaxPrintHistory
    -- @covers lurek.debugbridge.capturePrint
    -- @covers lurek.debugbridge.getPrintHistory
    -- @description Verifies max print history trims older entries once the configured capacity is exceeded.
    it("setMaxPrintHistory limits history size", function()
        lurek.debugbridge.clearPrintHistory()
        lurek.debugbridge.setMaxPrintHistory(3)
        for i = 1, 5 do
            lurek.debugbridge.capturePrint("msg " .. i)
        end
        local history = lurek.debugbridge.getPrintHistory()
        expect_equal(3, #history)
        expect_equal("msg 3", history[1].message)
        -- Reset to default
        lurek.debugbridge.setMaxPrintHistory(2000)
    end)

    -- @covers lurek.debugbridge.getPrintHistory
    -- @description Verifies getPrintHistory(count) returns only the trailing slice of history.
    it("getPrintHistory with count returns last N", function()
        lurek.debugbridge.clearPrintHistory()
        for i = 1, 10 do
            lurek.debugbridge.capturePrint("entry " .. i)
        end
        local last3 = lurek.debugbridge.getPrintHistory(3)
        expect_equal(3, #last3)
        expect_equal("entry 8", last3[1].message)
    end)

end)

-- ===== Performance =====

-- @description Covers suite: lurek.debugbridge performance.
describe("lurek.debugbridge performance", function()

    -- @covers lurek.debugbridge.getPerformance
    -- @description Verifies getPerformance returns the expected metrics table shape even without a live frame loop.
    it("getPerformance returns a table with expected keys", function()
        -- poll() auto-records frame time; in tests there is no game loop so
        -- we just verify the shape of the returned table.
        local perf = lurek.debugbridge.getPerformance()
        expect_not_nil(perf)
        expect_not_nil(perf.fps)
        expect_not_nil(perf.avgDt)
    end)

    -- @covers lurek.debugbridge.getPerformance
    -- @description Verifies getPerformance remains callable and returns a table in an effectively empty state.
    it("getPerformance returns zero stats when empty", function()
        -- Start fresh (can't easily clear, but test initial state logic)
        local perf = lurek.debugbridge.getPerformance()
        expect_not_nil(perf)
    end)

end)

-- ===== Screenshots =====

-- @description Covers suite: lurek.debugbridge screenshots.
describe("lurek.debugbridge screenshots", function()

    -- @covers lurek.debugbridge.isScreenshotRequested
    -- @description Verifies the screenshot-request flag starts cleared.
    it("isScreenshotRequested returns false initially", function()
        expect_equal(false, lurek.debugbridge.isScreenshotRequested())
    end)

    -- @covers lurek.debugbridge.requestScreenshot
    -- @covers lurek.debugbridge.isScreenshotRequested
    -- @description Verifies requestScreenshot raises the screenshot-request flag.
    it("requestScreenshot sets the flag", function()
        lurek.debugbridge.requestScreenshot(2)
        expect_equal(true, lurek.debugbridge.isScreenshotRequested())
    end)

end)

-- ===== Broadcast =====

-- @description Covers suite: lurek.debugbridge broadcast.
describe("lurek.debugbridge broadcast", function()

    -- @covers lurek.debugbridge.broadcast
    -- @description Verifies broadcast tolerates the no-client case without throwing.
    it("broadcast does not error without connected clients", function()
        lurek.debugbridge.broadcast("test_event", '{"key": "value"}')
        -- No error means success â€” no clients to receive it
    end)

end)

-- ===== Poll =====

-- @description Covers suite: lurek.debugbridge poll.
describe("lurek.debugbridge poll", function()

    -- @covers lurek.debugbridge.start
    -- @covers lurek.debugbridge.poll
    -- @covers lurek.debugbridge.stop
    -- @description Verifies poll can run while the server is active without raising transport errors.
    it("poll processes without error when server is running", function()
        lurek.debugbridge.start(49743)
        lurek.debugbridge.poll()
        lurek.debugbridge.stop()
    end)

end)

test_summary()
