-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_debugbridge_core_unit.lua
do
-- DebugBridge Lua Tests
-- Tests the lurek.debugbridge TCP debug server API

-- ===== Lifecycle =====

-- @describe lurek.debugbridge lifecycle
describe("lurek.debugbridge lifecycle", function()

    local function start_on_free_high_port(start_port, end_port)
        for port = start_port, end_port do
            local ok = lurek.debugbridge.start(port)
            if ok then
                return port
            end
        end
        return nil
    end

    -- @covers lurek.debugbridge.isRunning
    it("isRunning returns false initially", function()
        expect_equal(false, lurek.debugbridge.isRunning())
    end)

    -- @covers lurek.debugbridge.getPort
    it("getPort returns 0 when not running", function()
        expect_equal(0, lurek.debugbridge.getPort())
    end)

    -- @covers lurek.debugbridge.getClientCount
    it("getClientCount returns 0 when not running", function()
        expect_equal(0, lurek.debugbridge.getClientCount())
    end)

    -- @covers lurek.debugbridge.start
    it("start and stop work on a high port", function()
        local port = start_on_free_high_port(49740, 49840)
        expect_not_nil(port)
        expect_equal(true, lurek.debugbridge.isRunning())
        expect_equal(port, lurek.debugbridge.getPort())

        lurek.debugbridge.stop()
        expect_equal(false, lurek.debugbridge.isRunning())
    end)

    -- @covers lurek.debugbridge.poll
    it("poll does not error when not running", function()
        expect_no_error(function() lurek.debugbridge.poll() end)
    end)

end)

-- ===== Print Capture =====

-- @describe lurek.debugbridge print capture
describe("lurek.debugbridge print capture", function()

    -- @covers lurek.debugbridge.capturePrint
    it("capturePrint records a message", function()
        lurek.debugbridge.capturePrint("hello world")
        local history = lurek.debugbridge.getPrintHistory()
        expect_true(#history >= 1)
        local last = history[#history]
        expect_equal("hello world", last.message)
    end)

    -- @covers lurek.debugbridge.clearPrintHistory
    it("clearPrintHistory clears all entries", function()
        lurek.debugbridge.capturePrint("before clear")
        lurek.debugbridge.clearPrintHistory()
        local history = lurek.debugbridge.getPrintHistory()
        expect_equal(0, #history)
    end)

    -- @covers lurek.debugbridge.setMaxPrintHistory
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

-- @describe lurek.debugbridge performance
describe("lurek.debugbridge performance", function()

    -- @covers lurek.debugbridge.getPerformance
    it("getPerformance returns a stable table shape", function()
        -- poll() auto-records frame time; in tests there is no game loop so
        -- we just verify the shape of the returned table.
        local perf = lurek.debugbridge.getPerformance()
        expect_not_nil(perf)
        expect_not_nil(perf.fps)
        expect_not_nil(perf.avgDt)
        expect_type("table", perf)
    end)

end)

-- ===== Protocol =====

-- @describe lurek.debugbridge protocol
describe("lurek.debugbridge protocol", function()

    -- @covers lurek.debugbridge.getProtocolInfo
    it("getProtocolInfo returns version and capabilities", function()
        local info = lurek.debugbridge.getProtocolInfo()
        expect_not_nil(info)
        expect_true(info.version >= 1)
        expect_not_nil(info.capabilities)
        expect_true(#info.capabilities >= 1)
        expect_not_nil(info.nonce)
    end)

    -- @covers lurek.debugbridge.consumeHotReloadRequest
    it("consumeHotReloadRequest returns boolean", function()
        local pending = lurek.debugbridge.consumeHotReloadRequest()
        expect_equal(type(pending), "boolean")
    end)

end)

-- ===== Screenshots =====

-- @describe lurek.debugbridge screenshots
describe("lurek.debugbridge screenshots", function()

    -- @covers lurek.debugbridge.isScreenshotRequested
    it("isScreenshotRequested returns false initially", function()
        expect_equal(false, lurek.debugbridge.isScreenshotRequested())
    end)

    -- @covers lurek.debugbridge.requestScreenshot
    it("requestScreenshot sets the flag", function()
        lurek.debugbridge.requestScreenshot(2)
        expect_equal(true, lurek.debugbridge.isScreenshotRequested())
    end)

end)

-- ===== Broadcast =====

-- @describe lurek.debugbridge broadcast
describe("lurek.debugbridge broadcast", function()

    -- @covers lurek.debugbridge.broadcast
    it("broadcast does not error without connected clients", function()
        expect_no_error(function() lurek.debugbridge.broadcast("test_event", '{"key": "value"}') end)
    end)

end)

-- ===== Poll =====

-- @describe lurek.debugbridge poll
describe("lurek.debugbridge poll", function()

    -- @covers lurek.debugbridge.stop
    it("poll processes without error when server is running", function()
        local port = nil
        for p = 49740, 49840 do
            local ok = lurek.debugbridge.start(p)
            if ok then
                port = p
                break
            end
        end
        expect_not_nil(port)
        expect_no_error(function() lurek.debugbridge.poll() end)
        lurek.debugbridge.stop()
    end)

end)
end
-- END test_debugbridge_core_unit.lua

test_summary()
