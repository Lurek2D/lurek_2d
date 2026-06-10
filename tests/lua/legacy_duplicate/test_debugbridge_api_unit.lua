-- DebugBridge Lua API owner tests.

-- @describe lurek.debugbridge lifecycle
describe("lurek.debugbridge lifecycle", function()
    -- @covers lurek.debugbridge
    it("namespace exists", function()
        expect_not_nil(lurek.debugbridge)
    end)

    -- @covers lurek.debugbridge.isRunning
    it("isRunning reflects lifecycle state", function()
        expect_false(lurek.debugbridge.isRunning())
        local ok = lurek.debugbridge.start(49740)
        expect_true(ok)
        expect_true(lurek.debugbridge.isRunning())
        lurek.debugbridge.stop()
        expect_false(lurek.debugbridge.isRunning())
    end)

    -- @covers lurek.debugbridge.getPort
    it("getPort reports the configured port while running and after stop", function()
        lurek.debugbridge.stop()
        expect_true(lurek.debugbridge.getPort() >= 0)
        expect_true(lurek.debugbridge.start(49741))
        expect_equal(49741, lurek.debugbridge.getPort())
        lurek.debugbridge.stop()
        expect_equal(49741, lurek.debugbridge.getPort())
    end)

    -- @covers lurek.debugbridge.getClientCount
    it("getClientCount is zero with no clients", function()
        expect_equal(0, lurek.debugbridge.getClientCount())
    end)

    -- @covers lurek.debugbridge.start
    it("start returns false when already running", function()
        lurek.debugbridge.start(49742)
        local second = lurek.debugbridge.start(49743)
        expect_false(second)
        lurek.debugbridge.stop()
    end)

    -- @covers lurek.debugbridge.stop
    it("stop shuts a running bridge down cleanly", function()
        lurek.debugbridge.start(49744)
        lurek.debugbridge.stop()
        expect_false(lurek.debugbridge.isRunning())
    end)

    -- @covers lurek.debugbridge.poll
    it("poll does not error whether the bridge is running or not", function()
        expect_no_error(function() lurek.debugbridge.poll() end)
        lurek.debugbridge.start(49745)
        expect_no_error(function() lurek.debugbridge.poll() end)
        lurek.debugbridge.stop()
    end)
end)

-- @describe lurek.debugbridge print capture
describe("lurek.debugbridge print capture", function()
    -- @covers lurek.debugbridge.capturePrint
    it("capturePrint records message, source, and line data", function()
        lurek.debugbridge.capturePrint("hello world")
        lurek.debugbridge.capturePrint("test msg", "main.lua", 42)
        local history = lurek.debugbridge.getPrintHistory()
        local last = history[#history]
        expect_equal("test msg", last.message)
        expect_equal("main.lua", last.source)
        expect_equal(42, last.line)
    end)

    -- @covers lurek.debugbridge.getPrintHistory
    it("getPrintHistory returns the last requested entries", function()
        lurek.debugbridge.clearPrintHistory()
        for i = 1, 10 do
            lurek.debugbridge.capturePrint("entry " .. i)
        end
        local last3 = lurek.debugbridge.getPrintHistory(3)
        expect_equal(3, #last3)
        expect_equal("entry 8", last3[1].message)
        expect_equal("entry 10", last3[3].message)
    end)

    -- @covers lurek.debugbridge.clearPrintHistory
    it("clearPrintHistory removes all saved entries", function()
        lurek.debugbridge.capturePrint("before clear")
        lurek.debugbridge.clearPrintHistory()
        expect_equal(0, #lurek.debugbridge.getPrintHistory())
    end)

    -- @covers lurek.debugbridge.setMaxPrintHistory
    it("setMaxPrintHistory limits stored history length", function()
        lurek.debugbridge.clearPrintHistory()
        lurek.debugbridge.setMaxPrintHistory(3)
        for i = 1, 5 do
            lurek.debugbridge.capturePrint("msg " .. i)
        end
        local history = lurek.debugbridge.getPrintHistory()
        expect_equal(3, #history)
        expect_equal("msg 3", history[1].message)
        lurek.debugbridge.setMaxPrintHistory(2000)
    end)
end)

-- @describe lurek.debugbridge telemetry
describe("lurek.debugbridge telemetry", function()
    -- @covers lurek.debugbridge.getPerformance
    it("getPerformance returns a table with expected keys", function()
        local perf = lurek.debugbridge.getPerformance()
        expect_not_nil(perf)
        expect_not_nil(perf.fps)
        expect_not_nil(perf.avgDt)
    end)

    -- @covers lurek.debugbridge.getProtocolInfo
    it("getProtocolInfo returns version, capabilities, and nonce", function()
        local info = lurek.debugbridge.getProtocolInfo()
        expect_true(info.version >= 1)
        expect_not_nil(info.capabilities)
        expect_true(#info.capabilities >= 1)
        expect_not_nil(info.nonce)
    end)

    -- @covers lurek.debugbridge.consumeHotReloadRequest
    it("consumeHotReloadRequest returns a boolean", function()
        expect_equal(type(lurek.debugbridge.consumeHotReloadRequest()), "boolean")
    end)
end)

-- @describe lurek.debugbridge screenshots
describe("lurek.debugbridge screenshots", function()
    -- @covers lurek.debugbridge.isScreenshotRequested
    it("isScreenshotRequested reflects request state", function()
        expect_false(lurek.debugbridge.isScreenshotRequested())
        lurek.debugbridge.requestScreenshot(2)
        expect_true(lurek.debugbridge.isScreenshotRequested())
    end)

    -- @covers lurek.debugbridge.requestScreenshot
    it("requestScreenshot can be called without error", function()
        expect_no_error(function()
            lurek.debugbridge.requestScreenshot(1)
        end)
    end)
end)

-- @describe lurek.debugbridge broadcast
describe("lurek.debugbridge broadcast", function()
    -- @covers lurek.debugbridge.broadcast
    it("broadcast does not error without connected clients", function()
        expect_no_error(function()
            lurek.debugbridge.broadcast("test_event", '{"key": "value"}')
        end)
    end)
end)

test_summary()
