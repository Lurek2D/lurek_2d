-- content/examples/debugbridge.lua
-- Auto-generated from content/examples2/debugbridge_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/debugbridge.lua

--- DebugBridge Module: Remote Debug Server, Print Capture, Screenshots, Hot Reload

--@api-stub: lurek.debugbridge.start
do
  local ok, started = pcall(function()
    return lurek.debugbridge.start(19740)
  end)
  print("start call ok = " .. tostring(ok))
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
  local running = lurek.debugbridge.isRunning()
  print("running = " .. tostring(running))
end

--@api-stub: lurek.debugbridge.getPort
do
  local port = lurek.debugbridge.getPort()
  print("port = " .. tostring(port))
end

--@api-stub: lurek.debugbridge.getClientCount
do
  local clients = lurek.debugbridge.getClientCount()
  print("clients = " .. tostring(clients))
end

--@api-stub: lurek.debugbridge.poll
do
  lurek.debugbridge.poll()
  print("polled bridge requests")
end

--@api-stub: lurek.debugbridge.capturePrint
do
  lurek.debugbridge.capturePrint("Hello from game", "main.lua", 42)
  local history = lurek.debugbridge.getPrintHistory(1)
  print("message captured = " .. tostring(#history == 1))
end

--@api-stub: lurek.debugbridge.getPrintHistory
do
  lurek.debugbridge.capturePrint("test msg", "src", 1)
  local history = lurek.debugbridge.getPrintHistory(10)
  print("history entries = " .. tostring(#history))
  if #history > 0 then
    print("last message = " .. tostring(history[#history].message))
  end
end

--@api-stub: lurek.debugbridge.clearPrintHistory
do
  lurek.debugbridge.capturePrint("will be cleared", "x", 1)
  lurek.debugbridge.clearPrintHistory()
  local history = lurek.debugbridge.getPrintHistory()
  print("after clear = " .. tostring(#history))
end

--@api-stub: lurek.debugbridge.setMaxPrintHistory
do
  lurek.debugbridge.setMaxPrintHistory(100)
  lurek.debugbridge.capturePrint("history limit updated", "debugbridge.lua", 35)
  print("max print history set to 100")
end

--@api-stub: lurek.debugbridge.getPerformance
do
  local perf = lurek.debugbridge.getPerformance()
  print("frame time avg = " .. tostring(perf.avg_dt or perf.avg_frame_ms or "n/a"))
  print("fps = " .. tostring(perf.fps or "n/a"))
end

--@api-stub: lurek.debugbridge.requestScreenshot
do
  lurek.debugbridge.requestScreenshot(2)
  print("screenshot requested at 2x")
  print("pending = " .. tostring(lurek.debugbridge.isScreenshotRequested()))
end

--@api-stub: lurek.debugbridge.isScreenshotRequested
do
  lurek.debugbridge.requestScreenshot()
  local pending = lurek.debugbridge.isScreenshotRequested()
  print("pending = " .. tostring(pending))
end

--@api-stub: lurek.debugbridge.broadcast
do
  lurek.debugbridge.broadcast("game_event", '{"score":100}')
  print("broadcast sent")
end

--@api-stub: lurek.debugbridge.getProtocolInfo
do
  local info = lurek.debugbridge.getProtocolInfo()
  print("protocol version = " .. tostring(info.version))
  print("capability count = " .. tostring(#info.capabilities))
end

--@api-stub: lurek.debugbridge.consumeHotReloadRequest
do
  local had_request = lurek.debugbridge.consumeHotReloadRequest()
  print("hot reload pending = " .. tostring(had_request))
end
