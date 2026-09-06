-- content/examples/debugbridge.lua
-- Auto-generated from content/examples2/debugbridge_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/debugbridge.lua





--- DebugBridge Module: editor bridge lifecycle, runtime telemetry, print capture, screenshots, and hot reload.

--@api: lurek.debugbridge.start
do

    local port = 49740
    if lurek.debugbridge.isRunning() then
        lurek.debugbridge.stop()
    end
    if not lurek.debugbridge.start(port) then
        port = nil
    end
    local running = lurek.debugbridge.isRunning()
    local active_port = lurek.debugbridge.getPort()
    lurek.log.info("start running=" .. tostring(running) .. " requested_port=" .. tostring(port) .. " active_port=" .. tostring(active_port))
    if lurek.debugbridge.isRunning() then
        lurek.debugbridge.stop()
    end
end

--@api: lurek.debugbridge.stop
do

    local port = 49740
    if lurek.debugbridge.isRunning() then
        lurek.debugbridge.stop()
    end
    if not lurek.debugbridge.start(port) then
        port = nil
    end
    local before = lurek.debugbridge.isRunning()
    lurek.debugbridge.stop()
    local after = lurek.debugbridge.isRunning()
    lurek.log.info("stop port=" .. tostring(port) .. " before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api: lurek.debugbridge.isRunning
do

    if lurek.debugbridge.isRunning() then
        lurek.debugbridge.stop()
    end
    local before = lurek.debugbridge.isRunning()
    local port = 49740
    if lurek.debugbridge.isRunning() then
        lurek.debugbridge.stop()
    end
    if not lurek.debugbridge.start(port) then
        port = nil
    end
    local after = lurek.debugbridge.isRunning()
    lurek.log.info("isRunning before=" .. tostring(before) .. " after_start=" .. tostring(after) .. " port=" .. tostring(port))
    if lurek.debugbridge.isRunning() then
        lurek.debugbridge.stop()
    end
end

--@api: lurek.debugbridge.getPort
do

    if lurek.debugbridge.isRunning() then
        lurek.debugbridge.stop()
    end
    local idle_port = lurek.debugbridge.getPort()
    local port = 49740
    if lurek.debugbridge.isRunning() then
        lurek.debugbridge.stop()
    end
    if not lurek.debugbridge.start(port) then
        port = nil
    end
    local active_port = lurek.debugbridge.getPort()
    lurek.log.info("getPort idle=" .. tostring(idle_port) .. " started=" .. tostring(port) .. " active=" .. tostring(active_port))
    if lurek.debugbridge.isRunning() then
        lurek.debugbridge.stop()
    end
end

--@api: lurek.debugbridge.getClientCount
do

    if lurek.debugbridge.isRunning() then
        lurek.debugbridge.stop()
    end
    local before = lurek.debugbridge.getClientCount()
    local port = 49740
    if lurek.debugbridge.isRunning() then
        lurek.debugbridge.stop()
    end
    if not lurek.debugbridge.start(port) then
        port = nil
    end
    local after = lurek.debugbridge.getClientCount()
    lurek.log.info("getClientCount before=" .. tostring(before) .. " after_start=" .. tostring(after) .. " port=" .. tostring(port))
    if lurek.debugbridge.isRunning() then
        lurek.debugbridge.stop()
    end
end

--@api: lurek.debugbridge.poll
do

if lurek.debugbridge.isRunning() then
lurek.debugbridge.stop()
end
lurek.debugbridge.poll()
local port = 49740
if lurek.debugbridge.isRunning() then
lurek.debugbridge.stop()
end
if not lurek.debugbridge.start(port) then
port = nil
end
lurek.debugbridge.poll()
local running = lurek.debugbridge.isRunning()
lurek.log.info("poll running=" .. tostring(running) .. " port=" .. tostring(port) .. " clients=" .. lurek.debugbridge.getClientCount())
end

--@api: lurek.debugbridge.capturePrint
do

    lurek.debugbridge.clearPrintHistory()
    lurek.debugbridge.setMaxPrintHistory(2000)
    lurek.debugbridge.capturePrint("quest accepted", "quests.lua", 42)
    local history = lurek.debugbridge.getPrintHistory(1)
    local last = history[1]
    lurek.log.info("capturePrint size=" .. #history .. " msg=" .. tostring(last and last.message) .. " source=" .. tostring(last and last.source))
end

--@api: lurek.debugbridge.getPrintHistory
do

    lurek.debugbridge.clearPrintHistory()
    lurek.debugbridge.setMaxPrintHistory(2000)
    for i = 1, 4 do
        lurek.debugbridge.capturePrint("frame " .. i, "hud.lua", i)
    end
    local last_two = lurek.debugbridge.getPrintHistory(2)
    local first = last_two[1]
    local second = last_two[2]
    lurek.log.info("getPrintHistory size=" .. #last_two .. " first=" .. tostring(first and first.message) .. " second=" .. tostring(second and second.message))
end

--@api: lurek.debugbridge.clearPrintHistory
do

    lurek.debugbridge.clearPrintHistory()
    lurek.debugbridge.setMaxPrintHistory(2000)
    lurek.debugbridge.capturePrint("before clear", "main.lua", 10)
    local before = #lurek.debugbridge.getPrintHistory()
    lurek.debugbridge.clearPrintHistory()
    local after = #lurek.debugbridge.getPrintHistory()
    lurek.log.info("clearPrintHistory before=" .. before .. " after=" .. after)
end

--@api: lurek.debugbridge.setMaxPrintHistory
do

    lurek.debugbridge.clearPrintHistory()
    lurek.debugbridge.setMaxPrintHistory(2000)
    lurek.debugbridge.setMaxPrintHistory(3)
    for i = 1, 5 do
        lurek.debugbridge.capturePrint("msg " .. i, "debug.lua", i)
    end
    local history = lurek.debugbridge.getPrintHistory()
    lurek.log.info("setMaxPrintHistory kept=" .. #history .. " first=" .. tostring(history[1] and history[1].message))
    lurek.debugbridge.setMaxPrintHistory(2000)
end

--@api: lurek.debugbridge.getPerformance
do

    lurek.debugbridge.poll()
    local perf = lurek.debugbridge.getPerformance()
    local fps = perf.fps or "n/a"
    local avg_dt = perf.avgDt or perf.avg_dt or perf.avg_frame_ms or "n/a"
    local frame_count = perf.frameCount or perf.frames or "n/a"
    lurek.log.info("getPerformance fps=" .. tostring(fps) .. " avg=" .. tostring(avg_dt) .. " frames=" .. tostring(frame_count))
end

--@api: lurek.debugbridge.requestScreenshot
do

    local before = lurek.debugbridge.isScreenshotRequested()
    lurek.debugbridge.requestScreenshot(2)
    local after = lurek.debugbridge.isScreenshotRequested()
    local protocol = lurek.debugbridge.getProtocolInfo()
    lurek.log.info("requestScreenshot before=" .. tostring(before) .. " after=" .. tostring(after) .. " protocol=" .. tostring(protocol.version))
end

--@api: lurek.debugbridge.isScreenshotRequested
do

    local before = lurek.debugbridge.isScreenshotRequested()
    lurek.debugbridge.requestScreenshot()
    local after = lurek.debugbridge.isScreenshotRequested()
    local clients = lurek.debugbridge.getClientCount()
    lurek.log.info("isScreenshotRequested before=" .. tostring(before) .. " after=" .. tostring(after) .. " clients=" .. tostring(clients))
end

--@api: lurek.debugbridge.broadcast
do

    if lurek.debugbridge.isRunning() then
        lurek.debugbridge.stop()
    end
    local port = 49740
    if lurek.debugbridge.isRunning() then
        lurek.debugbridge.stop()
    end
    if not lurek.debugbridge.start(port) then
        port = nil
    end
    lurek.debugbridge.broadcast("quest:update", '{"quest":"intro","state":"ready"}')
    local protocol = lurek.debugbridge.getProtocolInfo()
    lurek.log.info("broadcast port=" .. tostring(port) .. " capabilities=" .. #protocol.capabilities .. " clients=" .. lurek.debugbridge.getClientCount())
    if lurek.debugbridge.isRunning() then
        lurek.debugbridge.stop()
    end
end

--@api: lurek.debugbridge.getProtocolInfo
do

    local info = lurek.debugbridge.getProtocolInfo()
    local version = info.version
    local nonce = info.nonce
    local capabilities = info.capabilities
    lurek.log.info("getProtocolInfo version=" .. tostring(version) .. " nonce=" .. tostring(nonce) .. " capability_count=" .. #capabilities)
end

--@api: lurek.debugbridge.consumeHotReloadRequest
do

    local first = lurek.debugbridge.consumeHotReloadRequest()
    local second = lurek.debugbridge.consumeHotReloadRequest()
    local info = lurek.debugbridge.getProtocolInfo()
    local running = lurek.debugbridge.isRunning()
    lurek.log.info("consumeHotReloadRequest first=" .. tostring(first) .. " second=" .. tostring(second) .. " protocol=" .. tostring(info.version) .. " running=" .. tostring(running))
end
