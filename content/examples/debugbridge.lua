-- content/examples/debugbridge.lua
-- Auto-generated from content/examples2/debugbridge_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/debugbridge.lua

local function bridge_log(message)
    lurek.log.info("[debugbridge] " .. message)
end

local function stop_bridge_if_running()
    if lurek.debugbridge.isRunning() then
        lurek.debugbridge.stop()
    end
end

local function start_bridge()
    stop_bridge_if_running()
    for port = 49740, 49840 do
        if lurek.debugbridge.start(port) then
            return port
        end
    end
    return nil
end

local function reset_print_history()
    lurek.debugbridge.clearPrintHistory()
    lurek.debugbridge.setMaxPrintHistory(2000)
end

--- DebugBridge Module: editor bridge lifecycle, runtime telemetry, print capture, screenshots, and hot reload.

--@api: lurek.debugbridge.start
do
    local port = start_bridge()
    local running = lurek.debugbridge.isRunning()
    local active_port = lurek.debugbridge.getPort()
    bridge_log("start running=" .. tostring(running) .. " requested_port=" .. tostring(port) .. " active_port=" .. tostring(active_port))
    stop_bridge_if_running()
end

--@api: lurek.debugbridge.stop
do
    local port = start_bridge()
    local before = lurek.debugbridge.isRunning()
    lurek.debugbridge.stop()
    local after = lurek.debugbridge.isRunning()
    bridge_log("stop port=" .. tostring(port) .. " before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api: lurek.debugbridge.isRunning
do
    stop_bridge_if_running()
    local before = lurek.debugbridge.isRunning()
    local port = start_bridge()
    local after = lurek.debugbridge.isRunning()
    bridge_log("isRunning before=" .. tostring(before) .. " after_start=" .. tostring(after) .. " port=" .. tostring(port))
    stop_bridge_if_running()
end

--@api: lurek.debugbridge.getPort
do
    stop_bridge_if_running()
    local idle_port = lurek.debugbridge.getPort()
    local port = start_bridge()
    local active_port = lurek.debugbridge.getPort()
    bridge_log("getPort idle=" .. tostring(idle_port) .. " started=" .. tostring(port) .. " active=" .. tostring(active_port))
    stop_bridge_if_running()
end

--@api: lurek.debugbridge.getClientCount
do
    stop_bridge_if_running()
    local before = lurek.debugbridge.getClientCount()
    local port = start_bridge()
    local after = lurek.debugbridge.getClientCount()
    bridge_log("getClientCount before=" .. tostring(before) .. " after_start=" .. tostring(after) .. " port=" .. tostring(port))
    stop_bridge_if_running()
end

--@api: lurek.debugbridge.poll
do
    stop_bridge_if_running()
    lurek.debugbridge.poll()
    local port = start_bridge()
    lurek.debugbridge.poll()
    local running = lurek.debugbridge.isRunning()
    bridge_log("poll running=" .. tostring(running) .. " port=" .. tostring(port) .. " clients=" .. lurek.debugbridge.getClientCount())
    stop_bridge_if_running()
end

--@api: lurek.debugbridge.capturePrint
do
    reset_print_history()
    lurek.debugbridge.capturePrint("quest accepted", "quests.lua", 42)
    local history = lurek.debugbridge.getPrintHistory(1)
    local last = history[1]
    bridge_log("capturePrint size=" .. #history .. " msg=" .. tostring(last and last.message) .. " source=" .. tostring(last and last.source))
end

--@api: lurek.debugbridge.getPrintHistory
do
    reset_print_history()
    for i = 1, 4 do
        lurek.debugbridge.capturePrint("frame " .. i, "hud.lua", i)
    end
    local last_two = lurek.debugbridge.getPrintHistory(2)
    local first = last_two[1]
    local second = last_two[2]
    bridge_log("getPrintHistory size=" .. #last_two .. " first=" .. tostring(first and first.message) .. " second=" .. tostring(second and second.message))
end

--@api: lurek.debugbridge.clearPrintHistory
do
    reset_print_history()
    lurek.debugbridge.capturePrint("before clear", "main.lua", 10)
    local before = #lurek.debugbridge.getPrintHistory()
    lurek.debugbridge.clearPrintHistory()
    local after = #lurek.debugbridge.getPrintHistory()
    bridge_log("clearPrintHistory before=" .. before .. " after=" .. after)
end

--@api: lurek.debugbridge.setMaxPrintHistory
do
    reset_print_history()
    lurek.debugbridge.setMaxPrintHistory(3)
    for i = 1, 5 do
        lurek.debugbridge.capturePrint("msg " .. i, "debug.lua", i)
    end
    local history = lurek.debugbridge.getPrintHistory()
    bridge_log("setMaxPrintHistory kept=" .. #history .. " first=" .. tostring(history[1] and history[1].message))
    lurek.debugbridge.setMaxPrintHistory(2000)
end

--@api: lurek.debugbridge.getPerformance
do
    lurek.debugbridge.poll()
    local perf = lurek.debugbridge.getPerformance()
    local fps = perf.fps or "n/a"
    local avg_dt = perf.avgDt or perf.avg_dt or perf.avg_frame_ms or "n/a"
    local frame_count = perf.frameCount or perf.frames or "n/a"
    bridge_log("getPerformance fps=" .. tostring(fps) .. " avg=" .. tostring(avg_dt) .. " frames=" .. tostring(frame_count))
end

--@api: lurek.debugbridge.requestScreenshot
do
    local before = lurek.debugbridge.isScreenshotRequested()
    lurek.debugbridge.requestScreenshot(2)
    local after = lurek.debugbridge.isScreenshotRequested()
    local protocol = lurek.debugbridge.getProtocolInfo()
    bridge_log("requestScreenshot before=" .. tostring(before) .. " after=" .. tostring(after) .. " protocol=" .. tostring(protocol.version))
end

--@api: lurek.debugbridge.isScreenshotRequested
do
    local before = lurek.debugbridge.isScreenshotRequested()
    lurek.debugbridge.requestScreenshot()
    local after = lurek.debugbridge.isScreenshotRequested()
    local clients = lurek.debugbridge.getClientCount()
    bridge_log("isScreenshotRequested before=" .. tostring(before) .. " after=" .. tostring(after) .. " clients=" .. tostring(clients))
end

--@api: lurek.debugbridge.broadcast
do
    stop_bridge_if_running()
    local port = start_bridge()
    lurek.debugbridge.broadcast("quest:update", '{"quest":"intro","state":"ready"}')
    local protocol = lurek.debugbridge.getProtocolInfo()
    bridge_log("broadcast port=" .. tostring(port) .. " capabilities=" .. #protocol.capabilities .. " clients=" .. lurek.debugbridge.getClientCount())
    stop_bridge_if_running()
end

--@api: lurek.debugbridge.getProtocolInfo
do
    local info = lurek.debugbridge.getProtocolInfo()
    local version = info.version
    local nonce = info.nonce
    local capabilities = info.capabilities
    bridge_log("getProtocolInfo version=" .. tostring(version) .. " nonce=" .. tostring(nonce) .. " capability_count=" .. #capabilities)
end

--@api: lurek.debugbridge.consumeHotReloadRequest
do
    local first = lurek.debugbridge.consumeHotReloadRequest()
    local second = lurek.debugbridge.consumeHotReloadRequest()
    local info = lurek.debugbridge.getProtocolInfo()
    local running = lurek.debugbridge.isRunning()
    bridge_log("consumeHotReloadRequest first=" .. tostring(first) .. " second=" .. tostring(second) .. " protocol=" .. tostring(info.version) .. " running=" .. tostring(running))
end
