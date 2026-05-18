-- content/examples/debugbridge.lua
-- Debug bridge: localhost TCP server for VS Code extension and external debuggers.
-- Run: cargo run -- content/examples/debugbridge.lua
--@api-stub: lurek.debugbridge.start
-- Starts a local debug bridge listener for editor and tool clients.
do
  -- A game can start the bridge during developer boot, then keep running normally
  -- if the port is already busy. The API rejects ports below 1024.
  local debug_port = 17800
  local started = false
  local ok, err = pcall(function()
    started = lurek.debugbridge.start(debug_port)
  end)
  if not ok then
    -- Another running copy may already own the port; gameplay should continue.
    lurek.log.warn("debug bridge failed: " .. tostring(err), "debugbridge")
  elseif started then
    lurek.log.info("debug bridge listening on 127.0.0.1:" .. debug_port, "debugbridge")
    -- Examples clean up immediately so test runs do not leave a server thread open.
    lurek.debugbridge.stop()
  else
    lurek.log.debug("debug bridge was already active", "debugbridge")
  end
end
--@api-stub: lurek.debugbridge.stop
-- Stops the debug bridge and releases its listener thread.
do
  -- Game shutdown code can call this helper from its quit path. It is safe to
  -- skip the call when the bridge was never started.
  local function shutdown_bridge()
    if lurek.debugbridge.isRunning() then
      lurek.debugbridge.stop()
      lurek.log.info("debug bridge stopped cleanly", "debugbridge")
    else
      lurek.log.debug("debug bridge already stopped", "debugbridge")
    end
  end
  shutdown_bridge()
end
--@api-stub: lurek.debugbridge.isRunning
-- Checks whether the debug bridge server thread is active.
do
  -- Developer HUDs can show bridge status without trying to open sockets or
  -- contact external tools during every frame.
  local hud = { status = "offline", tint = "gray" }
  local function refresh_debug_hud()
    if lurek.debugbridge.isRunning() then
      hud.status = "online on " .. lurek.debugbridge.getPort()
      hud.tint = "green"
    else
      hud.status = "offline"
      hud.tint = "gray"
    end
  end
  refresh_debug_hud()
  lurek.log.info("debug HUD: " .. hud.status .. " (" .. hud.tint .. ")", "debugbridge")
end
--@api-stub: lurek.debugbridge.getPort
-- Reads the configured debug bridge TCP port.
do
  -- The value is useful for connection hints. After a successful start it can
  -- stay configured even after the example stops the listener.
  local port = lurek.debugbridge.getPort()
  if port > 0 then
    local connect_hint = "tcp://127.0.0.1:" .. port
    lurek.log.info("debug tools can connect with " .. connect_hint, "debugbridge")
  else
    lurek.log.debug("no debug bridge port configured yet", "debugbridge")
  end
end
--@api-stub: lurek.debugbridge.getClientCount
-- Counts connected debugger or tooling clients.
do
  -- Use the count to avoid building detailed payloads when no external tool is
  -- listening. The example still produces a readable fallback log.
  local clients = lurek.debugbridge.getClientCount()
  if clients == 0 then
    lurek.log.debug("skip live player telemetry; no debug clients", "debugbridge")
  else
    local player = { hp = 85, x = 120.5, y = 64.0 }
    local payload = string.format(
      '{"hp":%d,"x":%.1f,"y":%.1f}',
      player.hp,
      player.x,
      player.y
    )
    lurek.debugbridge.broadcast("player_state", payload)
    lurek.log.info("sent player telemetry to " .. clients .. " debug client(s)", "debugbridge")
  end
end
--@api-stub: lurek.debugbridge.poll
-- Processes pending debug bridge requests from clients.
do
  -- Poll once in the game's update path. The function is cheap when no requests
  -- are queued and it also updates bridge frame metrics when time data exists.
  local function update_debug_tools(dt)
    if lurek.debugbridge.isRunning() then
      lurek.debugbridge.poll()
      lurek.log.debug("debug bridge polled after dt=" .. tostring(dt), "debugbridge")
    else
      -- Calling poll while stopped is also harmless, but most games guard it.
      lurek.debugbridge.poll()
    end
  end
  update_debug_tools(1 / 60)
end
--@api-stub: lurek.debugbridge.capturePrint
-- Captures a console-style message for bridge history and clients.
do
  -- Games can route their own debug console through the bridge without
  -- replacing Lua's global print function.
  local function capture_debug_message(source, line, ...)
    local parts = {}
    for i = 1, select("#", ...) do
      parts[i] = tostring(select(i, ...))
    end
    local message = table.concat(parts, "\t")
    lurek.debugbridge.capturePrint(message, source, line)
    lurek.log.info(message, "debug-console")
  end
  capture_debug_message("content/examples/debugbridge.lua", 27, "loaded", "debug bridge sample")
end
--@api-stub: lurek.debugbridge.getPrintHistory
-- Reads recent messages captured by the debug bridge.
do
  -- Capture a small breadcrumb, then fetch the latest rows for a pause menu or
  -- editor output panel. Each row has timestamp, message, source, and line.
  lurek.debugbridge.capturePrint("opening debug console", "ui/debug_console.lua", 14)
  local recent = lurek.debugbridge.getPrintHistory(3)
  for index, entry in ipairs(recent) do
    local location = tostring(entry.source) .. ":" .. tostring(entry.line)
    local text = "#" .. index .. " [" .. location .. "] " .. tostring(entry.message)
    lurek.log.debug(text, "debug-console")
  end
end
--@api-stub: lurek.debugbridge.clearPrintHistory
-- Clears captured print history entries.
do
  -- Clear history when moving between scenes so the debug panel starts with
  -- messages from the new scene only.
  local function enter_scene(scene_name)
    lurek.debugbridge.capturePrint("leaving previous scene", "scene.lua", 40)
    lurek.debugbridge.clearPrintHistory()
    local remaining = #lurek.debugbridge.getPrintHistory(0)
    lurek.log.info("scene entered: " .. scene_name .. "; history rows=" .. remaining, "scene")
  end
  enter_scene("dungeon_floor_3")
end
--@api-stub: lurek.debugbridge.setMaxPrintHistory
-- Sets the retained print history capacity.
do
  -- Tune this per build type. The engine clamps the value to a safe internal
  -- range, so game settings can stay simple.
  local build_kind = "playtest"
  local max_entries = build_kind == "development" and 4096 or 64
  lurek.debugbridge.setMaxPrintHistory(max_entries)
  for i = 1, 3 do
    lurek.debugbridge.capturePrint("history sample " .. i, "debugbridge.lua", 90 + i)
  end
  local retained = #lurek.debugbridge.getPrintHistory(0)
  lurek.log.info("print history capacity=" .. max_entries .. ", rows=" .. retained, "debugbridge")
end
--@api-stub: lurek.debugbridge.getPerformance
-- Reads debug bridge performance metrics.
do
  -- Performance values summarize recent frame deltas recorded while polling:
  -- fps, dt, avgDt, minDt, and maxDt.
  lurek.debugbridge.poll()
  local perf = lurek.debugbridge.getPerformance()
  local fps = perf.fps or 0
  local avg_dt = perf.avgDt or 0
  local status = string.format("bridge perf fps=%.1f avgDt=%.4f", fps, avg_dt)
  lurek.log.info(status, "debugbridge")
end
--@api-stub: lurek.debugbridge.requestScreenshot
-- Queues a screenshot request for the runtime.
do
  -- A bug-report shortcut can ask for a higher scale. The runtime clamps the
  -- scale from 1 to 8, so user settings cannot request an unsafe capture size.
  local function queue_bug_report_capture(reason)
    local requested_scale = reason == "pixel_art" and 2 or 1
    lurek.debugbridge.requestScreenshot(requested_scale)
    lurek.log.info("screenshot queued at " .. requested_scale .. "x for " .. reason, "debugbridge")
  end
  queue_bug_report_capture("pixel_art")
end
--@api-stub: lurek.debugbridge.isScreenshotRequested
-- Checks whether a screenshot request is pending.
do
  -- A UI layer can show a small capture indicator until the runtime consumes
  -- the request. This block queues one first so the state is visible.
  lurek.debugbridge.requestScreenshot(1)
  local function refresh_capture_indicator()
    if lurek.debugbridge.isScreenshotRequested() then
      lurek.log.debug("screenshot pending; show capture indicator", "debugbridge")
    else
      lurek.log.debug("no screenshot pending", "debugbridge")
    end
  end
  refresh_capture_indicator()
end
--@api-stub: lurek.debugbridge.broadcast
-- Broadcasts a named event payload to connected clients.
do
  -- The payload parameter is a string. Build a small JSON string yourself when
  -- external tools expect structured game data.
  local enemy = { id = 42, kind = "skeleton", x = 320, y = 192, room = 3 }
  local payload = string.format(
    '{"id":%d,"kind":"%s","x":%d,"y":%d}',
    enemy.id,
    enemy.kind,
    enemy.x,
    enemy.y
  )
  lurek.debugbridge.broadcast("enemy_spawned", payload)
  lurek.log.debug("broadcast enemy_spawned for room " .. enemy.room, "debugbridge")
end
--@api-stub: lurek.debugbridge.getProtocolInfo
-- Returns protocol version, capabilities, and handshake nonce.
do
  -- Show protocol details in a developer-only screen. Clients must use the
  -- nonce from the handshake path before protected requests are accepted.
  local info = lurek.debugbridge.getProtocolInfo()
  local capability_set = {}
  for _, capability in ipairs(info.capabilities) do
    capability_set[capability] = true
  end
  local supports_eval = capability_set.eval and "yes" or "no"
  local summary = "protocol v" .. tostring(info.version)
    .. " eval=" .. supports_eval
    .. " nonce=" .. tostring(info.nonce)
  lurek.log.info(summary, "debugbridge")
end
--@api-stub: lurek.debugbridge.consumeHotReloadRequest
-- Consumes one pending hot-reload request flag.
do
  -- Poll this in the update path. The flag is cleared by this call, so a game
  -- should reload scripts once and then wait for the next request.
  local function update_hot_reload_watch()
    if lurek.debugbridge.consumeHotReloadRequest() then
      local scene_name = "debugbridge_example"
      lurek.log.info("hot reload requested for " .. scene_name, "debugbridge")
      -- A real game would rebuild its scene or re-run its safe script loader here.
    else
      lurek.log.debug("no hot reload request pending", "debugbridge")
    end
  end
  update_hot_reload_watch()
end
print("content/examples/debugbridge.lua")
