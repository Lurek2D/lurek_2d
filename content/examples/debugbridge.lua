-- content/examples/debugbridge.lua
-- Auto-generated from content/examples2/debugbridge_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/debugbridge.lua

--- DebugBridge Module: Remote Debug Server, Print Capture, Screenshots, Hot Reload


--@api-stub: lurek.debugbridge.start
-- Starts the localhost debug bridge server on a port.
do
    local ok, started = pcall(function()
        return lurek.debugbridge.start(19740)
    end)
    print("started = " .. tostring(ok and started))
end

--@api-stub: lurek.debugbridge.stop
-- Stops the debug bridge server and joins the server thread.
do
    local ok = pcall(function()
        lurek.debugbridge.stop()
    end)
    print("bridge stopped = " .. tostring(ok))
end

--@api-stub: lurek.debugbridge.isRunning
-- Returns whether the debug bridge server is currently running.
do
    print("running = " .. tostring(lurek.debugbridge.isRunning()))
end

--@api-stub: lurek.debugbridge.getPort
-- Returns the configured TCP port.
do
    print("port = " .. lurek.debugbridge.getPort())
end

--@api-stub: lurek.debugbridge.getClientCount
-- Returns the number of connected debug bridge clients.
do
    print("clients = " .. lurek.debugbridge.getClientCount())
end

--@api-stub: lurek.debugbridge.poll
-- Polls pending debugger requests and queues responses.
do
    lurek.debugbridge.poll()
    print("polled")
end

--@api-stub: lurek.debugbridge.capturePrint
-- Captures a print message and broadcasts to debug clients.
do
    lurek.debugbridge.capturePrint("Hello from game", "main.lua", 42)
    print("message captured")
end

--@api-stub: lurek.debugbridge.getPrintHistory
-- Returns captured print history entries.
do
    lurek.debugbridge.capturePrint("test msg", "src", 1)
    local history = lurek.debugbridge.getPrintHistory(10)
    print("history entries = " .. #history)
end

--@api-stub: lurek.debugbridge.clearPrintHistory
-- Clears all entries from the print history buffer.
do
    lurek.debugbridge.capturePrint("will be cleared", "x", 1)
    lurek.debugbridge.clearPrintHistory()
    local h = lurek.debugbridge.getPrintHistory()
    print("after clear = " .. #h)
end

--@api-stub: lurek.debugbridge.setMaxPrintHistory
-- Sets the maximum retained print history entry count.
do
    lurek.debugbridge.setMaxPrintHistory(100)
    print("max print history set to 100")
end

--@api-stub: lurek.debugbridge.getPerformance
-- Returns debug bridge performance metrics.
do
    local perf = lurek.debugbridge.getPerformance()
    print("perf keys available")
end

--@api-stub: lurek.debugbridge.requestScreenshot
-- Requests a screenshot from the runtime at an optional scale.
do
    lurek.debugbridge.requestScreenshot(2)
    print("screenshot requested at 2x")
end

--@api-stub: lurek.debugbridge.isScreenshotRequested
-- Returns whether a screenshot request is pending.
do
    lurek.debugbridge.requestScreenshot()
    print("pending = " .. tostring(lurek.debugbridge.isScreenshotRequested()))
end

--@api-stub: lurek.debugbridge.broadcast
-- Queues a JSON payload broadcast for debug bridge clients.
do
    lurek.debugbridge.broadcast("game_event", '{"score":100}')
    print("broadcast sent")
end

--@api-stub: lurek.debugbridge.getProtocolInfo
-- Returns protocol version, capabilities, and nonce.
do
    local info = lurek.debugbridge.getProtocolInfo()
    print("protocol version = " .. info.version)
end

--@api-stub: lurek.debugbridge.consumeHotReloadRequest
-- Returns and clears the pending hot reload request flag.
do
    local had_request = lurek.debugbridge.consumeHotReloadRequest()
    print("hot reload pending = " .. tostring(had_request))
end

print("content/examples/debugbridge.lua")
