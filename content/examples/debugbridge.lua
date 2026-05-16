-- content/examples/debugbridge.lua
-- Debug bridge: localhost TCP server for VS Code extension and external debuggers.
-- Run: cargo run -- content/examples/debugbridge.lua

--@api-stub: lurek.debugbridge.start
-- Starts the localhost debug bridge server on a given TCP port.
do
  -- Start the bridge early in lurek.init so tools can connect before the first frame.
  -- Port must be >= 1024. Default is 19740 if omitted.
  local port = 17800
  local ok, err = pcall(function()
    local started = lurek.debugbridge.start(port)
    if started then
      lurek.log.info("debug bridge listening on 127.0.0.1:" .. port, "debugbridge")
    else
      -- Already running from a previous call — safe to ignore.
      lurek.log.debug("debug bridge was already running", "debugbridge")
    end
  end)
  if not ok then
    -- Port may be in use by another instance — non-fatal for gameplay.
    lurek.log.warn("debug bridge failed: " .. tostring(err), "debugbridge")
  end
end

--@api-stub: lurek.debugbridge.stop
-- Stops the debug bridge server and joins its background thread.
do
  -- Typical use: stop the bridge on game exit to release the port cleanly.
  -- Pair with isRunning() to avoid stopping a bridge that was never started.
  local function shutdown_bridge()
    if lurek.debugbridge.isRunning() then
      lurek.debugbridge.stop()
      lurek.log.info("debug bridge stopped cleanly", "debugbridge")
    end
  end
  -- Call in lurek.quit callback so the port is freed before the process exits.
  function lurek.quit()
    shutdown_bridge()
  end
end

--@api-stub: lurek.debugbridge.isRunning
-- Returns true when the debug bridge server thread is active.
do
  -- Use this to guard bridge calls that would error if the server is not up.
  -- Example: conditionally enable an in-game debug overlay.
  local function get_debug_status_text()
    if lurek.debugbridge.isRunning() then
      return "BRIDGE: ONLINE (port " .. lurek.debugbridge.getPort() .. ")"
    else
      return "BRIDGE: OFFLINE"
    end
  end
  lurek.log.info(get_debug_status_text(), "debugbridge")
end

--@api-stub: lurek.debugbridge.getPort
-- Returns the bound TCP port, or zero when the bridge is not running.
do
  -- Useful for displaying connection info in a developer HUD or writing
  -- a project file that external tools can read to auto-connect.
  local port = lurek.debugbridge.getPort()
  if port > 0 then
    lurek.log.info("IDE connect string: tcp://127.0.0.1:" .. port, "debugbridge")
  else
    lurek.log.debug("no active bridge port — start the bridge first", "debugbridge")
  end
end

--@api-stub: lurek.debugbridge.getClientCount
-- Returns the number of currently connected debugger/tool clients.
do
  -- Broadcast expensive diagnostics only when at least one client is listening.
  -- This avoids serialization overhead in production builds with no debugger.
  local player_hp = 85
  local player_x, player_y = 120.5, 64.0
  if lurek.debugbridge.getClientCount() > 0 then
    local payload = string.format(
      '{"hp":%d,"x":%.1f,"y":%.1f}', player_hp, player_x, player_y
    )
    lurek.debugbridge.broadcast("player_state", payload)
  end
end

--@api-stub: lurek.debugbridge.poll
-- Polls pending debugger requests, evaluates them, and queues responses.
do
  -- Call poll() once per frame inside lurek.process so the bridge can respond
  -- to breakpoints, watch expressions, and eval requests from the IDE.
  -- Without this call the bridge accepts connections but never replies.
  function lurek.process(dt)
    if lurek.debugbridge.isRunning() then
      lurek.debugbridge.poll()
    end
  end
end

--@api-stub: lurek.debugbridge.capturePrint
-- Captures a print message and broadcasts it to connected debug clients.
do
  -- Override the global print() so every script message also appears in the
  -- VS Code extension output panel with file and line metadata.
  local original_print = print
  print = function(...)
    local parts = {}
    for i = 1, select("#", ...) do
      parts[i] = tostring(select(i, ...))
    end
    local msg = table.concat(parts, "\t")
    -- source and line are optional; pass them when known for clickable links.
    lurek.debugbridge.capturePrint(msg, "game.lua", 0)
    original_print(...)
  end
  print("hello from captured print")
end

--@api-stub: lurek.debugbridge.getPrintHistory
-- Returns an array of recent captured print entries.
do
  -- Each entry has: timestamp (number), message (string), source (string), line (number).
  -- Pass a count to limit results; nil or 0 returns all entries.
  local last_10 = lurek.debugbridge.getPrintHistory(10)
  for _, entry in ipairs(last_10) do
    -- Format: [source:line] message
    local loc = entry.source .. ":" .. entry.line
    lurek.log.debug("[" .. loc .. "] " .. entry.message, "console")
  end
end

--@api-stub: lurek.debugbridge.clearPrintHistory
-- Clears all captured print history entries from memory.
do
  -- Clear history when transitioning between scenes so the debug panel
  -- only shows messages relevant to the current scene.
  local function enter_scene(name)
    lurek.debugbridge.clearPrintHistory()
    lurek.log.info("scene entered: " .. name .. " (print history cleared)", "scene")
  end
  enter_scene("dungeon_floor_3")
end

--@api-stub: lurek.debugbridge.setMaxPrintHistory
-- Sets the maximum number of print history entries retained in memory.
do
  -- Higher limits give more scrollback in the debug panel but use more RAM.
  -- Use a large buffer during development and a small one for playtests.
  local is_dev_build = true
  local max_entries = is_dev_build and 4096 or 256
  lurek.debugbridge.setMaxPrintHistory(max_entries)
  lurek.log.info("print history capacity set to " .. max_entries, "debugbridge")
end

--@api-stub: lurek.debugbridge.getPerformance
-- Returns a table of debug bridge performance metrics.
do
  -- Useful for monitoring bridge overhead itself. Returns numeric fields
  -- like messages_sent, messages_received, bytes_in, bytes_out.
  local perf = lurek.debugbridge.getPerformance()
  -- Log a summary every N seconds to track bridge traffic without flooding.
  local summary = "bridge perf:"
  for k, v in pairs(perf) do
    summary = summary .. " " .. k .. "=" .. tostring(v)
  end
  lurek.log.info(summary, "debugbridge")
end

--@api-stub: lurek.debugbridge.requestScreenshot
-- Requests a screenshot capture at the given scale (1-8, default 1).
do
  -- Bind a key so developers can grab hi-res screenshots for bug reports.
  -- Scale 2 gives 2x resolution for sharper inspection of pixel art.
  local function on_screenshot_key()
    lurek.debugbridge.requestScreenshot(2)
    lurek.log.info("screenshot queued at 2x scale", "debugbridge")
  end
  -- In a real game this would be inside lurek.init with lurek.input.bind.
  on_screenshot_key()
end

--@api-stub: lurek.debugbridge.isScreenshotRequested
-- Returns true when a screenshot capture is still pending.
do
  -- Show a brief flash or icon overlay while the capture is in progress.
  -- Check this in lurek.draw_ui so the indicator disappears once consumed.
  local function draw_capture_indicator()
    if lurek.debugbridge.isScreenshotRequested() then
      lurek.log.debug("screenshot pending — frame will be captured", "debugbridge")
    end
  end
  draw_capture_indicator()
end

--@api-stub: lurek.debugbridge.broadcast
-- Sends a named event with a JSON payload string to all connected clients.
do
  -- Use broadcast to push custom game events to external analysis tools.
  -- The VS Code extension listens for known event names and renders them.
  local event_name = "enemy_spawned"
  local enemy = { id = 42, kind = "skeleton", x = 320, y = 192 }
  local json = string.format(
    '{"id":%d,"kind":"%s","x":%d,"y":%d}',
    enemy.id, enemy.kind, enemy.x, enemy.y
  )
  lurek.debugbridge.broadcast(event_name, json)
end

--@api-stub: lurek.debugbridge.getProtocolInfo
-- Returns protocol version, capabilities list, and handshake nonce.
do
  -- Check protocol version to ensure the connected IDE extension is compatible.
  -- capabilities is an array of supported feature strings (e.g. "eval", "hotreload").
  local info = lurek.debugbridge.getProtocolInfo()
  lurek.log.info(
    "protocol v" .. info.version
      .. " | nonce=" .. tostring(info.nonce)
      .. " | caps=" .. table.concat(info.capabilities, ","),
    "debugbridge"
  )
end

--@api-stub: lurek.debugbridge.consumeHotReloadRequest
-- Returns and clears the pending hot-reload flag set by an external tool.
do
  -- Poll this each frame to detect when the IDE requests a script reload.
  -- After consuming, reload the active scene or re-run lurek.init logic.
  local function check_hot_reload()
    if lurek.debugbridge.consumeHotReloadRequest() then
      lurek.log.info("hot reload consumed — reloading scripts", "debugbridge")
      -- In a real game: dofile("main.lua") or scene:reload()
      return true
    end
    return false
  end
  check_hot_reload()
end

print("content/examples/debugbridge.lua")
