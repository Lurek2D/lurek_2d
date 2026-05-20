-- content/examples/debugbridge.lua
-- Auto-generated from content/examples2/debugbridge_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/debugbridge.lua

--- DebugBridge Module: Remote Debug Server, Print Capture, Screenshots, Hot Reload


--@api-stub: lurek.debugbridge.start
do
    local ok, started = pcall(function()
        return lurek.debugbridge.start(19740)
    end)
    print("started = " .. tostring(ok and started))
end

--@api-stub: lurek.debugbridge.stop
do
    local ok = pcall(function()
        lurek.debugbridge.stop()
    end)
    print("bridge stopped = " .. tostring(ok))
end

--@api-stub: lurek.debugbridge.isRunning
do
    print("running = " .. tostring(lurek.debugbridge.isRunning()))
end

--@api-stub: lurek.debugbridge.getPort
do
    print("port = " .. lurek.debugbridge.getPort())
end

--@api-stub: lurek.debugbridge.getClientCount
do
    print("clients = " .. lurek.debugbridge.getClientCount())
end

--@api-stub: lurek.debugbridge.poll
do
    lurek.debugbridge.poll()
    print("polled")
end

--@api-stub: lurek.debugbridge.capturePrint
do
    lurek.debugbridge.capturePrint("Hello from game", "main.lua", 42)
    print("message captured")
end

--@api-stub: lurek.debugbridge.getPrintHistory
do
    lurek.debugbridge.capturePrint("test msg", "src", 1)
    local history = lurek.debugbridge.getPrintHistory(10)
    print("history entries = " .. #history)
end

--@api-stub: lurek.debugbridge.clearPrintHistory
do
    lurek.debugbridge.capturePrint("will be cleared", "x", 1)
    lurek.debugbridge.clearPrintHistory()
    local h = lurek.debugbridge.getPrintHistory()
    print("after clear = " .. #h)
end

--@api-stub: lurek.debugbridge.setMaxPrintHistory
do
    lurek.debugbridge.setMaxPrintHistory(100)
    print("max print history set to 100")
end

--@api-stub: lurek.debugbridge.getPerformance
do
    local perf = lurek.debugbridge.getPerformance()
    print("perf keys available")
end

--@api-stub: lurek.debugbridge.requestScreenshot
do
    lurek.debugbridge.requestScreenshot(2)
    print("screenshot requested at 2x")
end

--@api-stub: lurek.debugbridge.isScreenshotRequested
do
    lurek.debugbridge.requestScreenshot()
    print("pending = " .. tostring(lurek.debugbridge.isScreenshotRequested()))
end

--@api-stub: lurek.debugbridge.broadcast
do
    lurek.debugbridge.broadcast("game_event", '{"score":100}')
    print("broadcast sent")
end

--@api-stub: lurek.debugbridge.getProtocolInfo
do
    local info = lurek.debugbridge.getProtocolInfo()
    print("protocol version = " .. info.version)
end

--@api-stub: lurek.debugbridge.consumeHotReloadRequest
do
    local had_request = lurek.debugbridge.consumeHotReloadRequest()
    print("hot reload pending = " .. tostring(had_request))
end

print("content/examples/debugbridge.lua")
