-- content/examples/engine.lua
-- lurek.engine API examples.
-- Run: cargo run -- content/examples/engine.lua

--@api-stub: lurek.engine.getVersion -- Returns the engine crate version string embedded at build time
do -- lurek.engine.getVersion
  local version = lurek.engine.getVersion()
  local save_header = { engine = version, schema = 3, ts = os.time() }
  lurek.log.info("save header engine=" .. save_header.engine, "save")
end

--@api-stub: lurek.engine.getFrameBudget -- Returns the target frame budget for a 60 FPS update loop
do -- lurek.engine.getFrameBudget
  local budget_ms = lurek.engine.getFrameBudget()
  local headroom_ms = budget_ms * 0.5
  function lurek.process(dt)
    if dt * 1000 > headroom_ms then
      lurek.log.warn("frame over half-budget: " .. (dt * 1000) .. "ms / " .. budget_ms, "perf")
    end
  end
end

--@api-stub: lurek.engine.memoryUsage -- Returns Lua VM memory usage as bytes and rounded kilobytes
do -- lurek.engine.memoryUsage
  local accum = 0
  function lurek.process(dt)
    accum = accum + dt
    if accum >= 1.0 then
      accum = 0
      local mem = lurek.engine.memoryUsage()
      lurek.log.debug("lua heap=" .. mem.lua_kb .. "KB (" .. mem.lua_bytes .. " bytes)", "mem")
    end
  end
end

--@api-stub: lurek.engine.platform -- Returns the current desktop operating system name
do -- lurek.engine.platform
  local os_name = lurek.engine.platform()
  local quit_hint = (os_name == "macos") and "Cmd+Q to quit" or "Alt+F4 to quit"
  lurek.log.info("running on " .. os_name .. " - " .. quit_hint, "boot")
end

--@api-stub: lurek.engine.uptime -- Returns total engine runtime accumulated by the main loop
do -- lurek.engine.uptime
  local session_start = lurek.engine.uptime()
  function lurek.quit()
    local played = lurek.engine.uptime() - session_start
    lurek.log.info("session lasted " .. string.format("%.1f", played) .. "s", "session")
  end
end

--@api-stub: lurek.engine.fps -- Returns the latest frames-per-second value stored by the runtime
do -- lurek.engine.fps
  local font
  function lurek.init() font = lurek.render.newFont(14) end
  function lurek.draw_ui()
    local fps = lurek.engine.fps()
    lurek.render.setFont(font)
    lurek.render.setColor(1, 1, 0, 1)
    lurek.render.print(string.format("FPS: %.0f", fps), 8, 8)
  end
end

--@api-stub: lurek.engine.frameCount -- Returns the number of frames counted by the shared runtime clock
do -- lurek.engine.frameCount
  function lurek.process(_)
    if lurek.engine.frameCount() % 600 == 0 then
      lurek.log.info("autosave tick at frame " .. lurek.engine.frameCount(), "save")
    end
  end
end

--@api-stub: lurek.engine.isDebug -- Returns whether the engine binary was built with debug assertions
do -- lurek.engine.isDebug
  if lurek.engine.isDebug() then
    lurek.log.setLevel("debug")
    lurek.log.debug("debug build - verbose logging enabled", "boot")
  else
    lurek.log.setLevel("info")
  end
end

--@api-stub: lurek.engine.setResourceBudget -- Sets the resource memory budget used by resource statistics reporting
do -- lurek.engine.setResourceBudget
  local mb = 256
  lurek.engine.setResourceBudget(mb * 1024 * 1024)
  lurek.log.info("texture budget set to " .. mb .. " MB", "boot")
end

--@api-stub: lurek.engine.getResourceStats -- Returns current resource memory usage and object counts by resource kind
do -- lurek.engine.getResourceStats
  function lurek.process(_)
    if lurek.engine.frameCount() % 300 ~= 0 then return end
    local stats = lurek.engine.getResourceStats()
    local mb = stats.total_bytes / (1024 * 1024)
    lurek.log.debug(string.format("tex=%d font=%d canvas=%d total=%.2fMB", stats.texture_count, stats.font_count, stats.canvas_count, mb), "mem")
  end
end

--@api-stub: lurek.engine.getFrameProfile -- Returns the latest frame timing profile split by engine phase
do -- lurek.engine.getFrameProfile
  function lurek.draw_ui()
    local p = lurek.engine.getFrameProfile()
    lurek.render.print(string.format("tick=%.2fms process=%.2fms draw=%.2fms", p.app_tick_ms, p.process_ms, p.draw_ms), 8, 28)
  end
end

--@api-stub: lurek.engine.getFrameProfileText -- Returns the latest frame timing profile formatted as one text line
do -- lurek.engine.getFrameProfileText
  function lurek.draw_ui()
    lurek.render.print(lurek.engine.getFrameProfileText(), 8, 46)
  end
end

--@api-stub: lurek.engine.getConfigRevision -- Returns the configuration reload revision counter
do -- lurek.engine.getConfigRevision
  local last = lurek.engine.getConfigRevision()
  function lurek.process(_)
    local now = lurek.engine.getConfigRevision()
    if now ~= last then
      last = now
      lurek.log.info("config revision changed to " .. now, "boot")
    end
  end
end
