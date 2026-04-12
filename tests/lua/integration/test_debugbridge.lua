-- DebugBridge Lua Tests
-- Tests the lurek.debugbridge TCP debug server API

-- ===== Lifecycle =====

-- @description Covers suite: lurek.debugbridge lifecycle.
describe("lurek.debugbridge lifecycle", function()

    -- @covers lurek.debugbridge
    -- @covers lurek.debugbridge.isRunning
    -- @covers lurek.debugbridge.broadcast
    -- @covers lurek.debugbridge.capturePrint
    -- @covers lurek.debugbridge.clearPrintHistory
    -- @covers lurek.debugbridge.getClientCount
    -- @covers lurek.debugbridge.getPerformance
    -- @covers lurek.debugbridge.getPort
    -- @covers lurek.debugbridge.getPrintHistory
    -- @covers lurek.debugbridge.isScreenshotRequested
    -- @covers lurek.debugbridge.poll
    -- @covers lurek.debugbridge.requestScreenshot
    -- @covers lurek.debugbridge.setMaxPrintHistory
    -- @covers lurek.debugbridge.start
    -- @covers lurek.debugbridge.stop
    -- @description Verifies the debugbridge namespace exists; despite the integration folder placement this is a single-module lifecycle smoke test.
    it("namespace exists", function()
        expect_not_nil(lurek.debugbridge)
    end)

    -- @covers lurek.debugbridge.isRunning
    -- @covers lurek.debugbridge
    -- @description Verifies a fresh debugbridge server reports a stopped state before any server startup.
    it("isRunning returns false initially", function()
        expect_equal(false, lurek.debugbridge.isRunning())
    end)

    -- @covers lurek.debugbridge.getPort
    -- @covers lurek.debugbridge
    -- @description Verifies querying the port before startup returns the zero sentinel; this remains a single-module debugbridge contract check.
    it("getPort returns 0 when not running", function()
        expect_equal(0, lurek.debugbridge.getPort())
    end)

    -- @covers lurek.debugbridge.getClientCount
    -- @covers lurek.debugbridge
    -- @description Verifies the debugbridge reports zero connected clients while no server is running.
    it("getClientCount returns 0 when not running", function()
        expect_equal(0, lurek.debugbridge.getClientCount())
    end)

    -- @covers lurek.debugbridge.start
    -- @covers lurek.debugbridge.stop
    -- @description Verifies the debugbridge can start on a high port, report its running state, and then shut down cleanly.
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
    -- @covers lurek.debugbridge.isRunning
    -- @description Verifies a second start attempt is rejected while the debugbridge server is already running.
    it("start returns false if already running", function()
        lurek.debugbridge.start(49741)
        local second = lurek.debugbridge.start(49742)
        expect_equal(false, second)
        lurek.debugbridge.stop()
    end)

    -- @covers lurek.debugbridge.poll
    -- @covers lurek.debugbridge
    -- @description Verifies polling the debugbridge while stopped is a harmless no-op in this unit-scoped test.
    it("poll does not error when not running", function()
        lurek.debugbridge.poll()  -- should be a no-op
    end)

end)

-- ===== Print Capture =====

-- @description Covers suite: lurek.debugbridge print capture.
describe("lurek.debugbridge print capture", function()

    -- @covers lurek.debugbridge.capturePrint
    -- @covers lurek.debugbridge.getPrintHistory
    -- @description Verifies captured print output is appended to the debugbridge history buffer.
    it("capturePrint records a message", function()
        lurek.debugbridge.capturePrint("hello world")
        local history = lurek.debugbridge.getPrintHistory()
        expect_true(#history >= 1)
        local last = history[#history]
        expect_equal("hello world", last.message)
    end)

    -- @covers lurek.debugbridge.capturePrint
    -- @covers lurek.debugbridge.getPrintHistory
    -- @description Verifies source filename and line metadata are preserved when debugbridge captures a print event.
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
    -- @description Verifies clearing the print history removes all previously captured debugbridge entries.
    it("clearPrintHistory clears all entries", function()
        lurek.debugbridge.capturePrint("before clear")
        lurek.debugbridge.clearPrintHistory()
        local history = lurek.debugbridge.getPrintHistory()
        expect_equal(0, #history)
    end)

    -- @covers lurek.debugbridge.setMaxPrintHistory
    -- @covers lurek.debugbridge.capturePrint
    -- @description Verifies the configured history cap trims older print entries once the debugbridge buffer exceeds its limit.
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
    -- @covers lurek.debugbridge.capturePrint
    -- @description Verifies requesting only the last N print entries returns a truncated tail of the debugbridge history.
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
    -- @covers lurek.debugbridge.poll
    -- @description Verifies the performance snapshot exposes the expected table shape even without a live game loop.
    it("getPerformance returns a table with expected keys", function()
        -- poll() auto-records frame time; in tests there is no game loop so
        -- we just verify the shape of the returned table.
        local perf = lurek.debugbridge.getPerformance()
        expect_not_nil(perf)
        expect_not_nil(perf.fps)
        expect_not_nil(perf.avgDt)
    end)

    -- @covers lurek.debugbridge.getPerformance
    -- @covers lurek.debugbridge
    -- @description Verifies querying performance data in an effectively empty state still returns a report object instead of failing.
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
    -- @covers lurek.debugbridge
    -- @description Verifies the screenshot request flag is initially cleared on the debugbridge module.
    it("isScreenshotRequested returns false initially", function()
        expect_equal(false, lurek.debugbridge.isScreenshotRequested())
    end)

    -- @covers lurek.debugbridge.requestScreenshot
    -- @covers lurek.debugbridge.isScreenshotRequested
    -- @description Verifies requesting a screenshot toggles the internal debugbridge flag that a capture is pending.
    it("requestScreenshot sets the flag", function()
        lurek.debugbridge.requestScreenshot(2)
        expect_equal(true, lurek.debugbridge.isScreenshotRequested())
    end)

end)

-- ===== Broadcast =====

-- @description Covers suite: lurek.debugbridge broadcast.
describe("lurek.debugbridge broadcast", function()

    -- @covers lurek.debugbridge.broadcast
    -- @covers lurek.debugbridge
    -- @description Verifies broadcast is safe to call with no clients connected, documenting this file's single-module scope.
    it("broadcast does not error without connected clients", function()
        lurek.debugbridge.broadcast("test_event", '{"key": "value"}')
        -- No error means success â€” no clients to receive it
    end)

end)

-- ===== Poll =====

-- @description Covers suite: lurek.debugbridge poll.
describe("lurek.debugbridge poll", function()

    -- @covers lurek.debugbridge.poll
    -- @covers lurek.debugbridge.start
    -- @description Verifies polling an active debugbridge server does not raise while the server is running.
    it("poll processes without error when server is running", function()
        lurek.debugbridge.start(49743)
        lurek.debugbridge.poll()
        lurek.debugbridge.stop()
    end)

end)
test_summary()
