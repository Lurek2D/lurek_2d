-- content/examples/log.lua
-- Demonstrates every lurek.log.* function with realistic game-dev usage.
-- Run: cargo run -- content/examples/log.lua

--@api-stub: lurek.log.setLevel
-- Sets the minimum severity for log output across all sinks
do
  -- During development use "debug" to see everything;
  -- in shipping builds switch to "warn" to reduce noise.
  local is_dev_build = true
  if is_dev_build then
    lurek.log.setLevel("debug")
  else
    lurek.log.setLevel("warn")
  end
end

--@api-stub: lurek.log.getLevel
-- Returns the current global log level as a string
do
  -- Use this to conditionally build expensive debug strings only when needed.
  local level = lurek.log.getLevel()
  if level == "debug" or level == "trace" then
    local world_state = "entities=214 particles=890 dt=16.4ms"
    lurek.log.debug("world snapshot: " .. world_state, "perf")
  end
end

--@api-stub: lurek.log.debug
-- Logs a debug message visible only at debug/trace level
do
  -- Track per-frame values that help you diagnose movement or physics issues.
  local player = { x = 312.5, y = 144.0, vx = 2.1, vy = -0.3 }
  lurek.log.debug(
    string.format("player pos=(%.1f,%.1f) vel=(%.2f,%.2f)", player.x, player.y, player.vx, player.vy),
    "movement"
  )
end

--@api-stub: lurek.log.info
-- Logs an informational message for notable lifecycle events
do
  -- Record transitions that help you understand session flow in the log file.
  local level_name = "dungeon_b2"
  local enemy_count = 23
  local spawn_time_ms = 4.7
  lurek.log.info(
    "loaded '" .. level_name .. "': " .. enemy_count .. " enemies in " .. spawn_time_ms .. "ms",
    "scene"
  )
end

--@api-stub: lurek.log.warn
-- Logs a warning for recoverable problems that deserve attention
do
  -- Alert on degraded performance so QA can spot patterns in the log file.
  local fps = 42
  local target_fps = 60
  if fps < target_fps * 0.75 then
    lurek.log.warn(
      string.format("fps dropped to %d (target %d) in boss_arena", fps, target_fps),
      "perf"
    )
  end
end

--@api-stub: lurek.log.error
-- Logs an error for failures that need immediate investigation
do
  -- Always include enough context to reproduce: path, operation, fallback chosen.
  local save_path = "save/slot2.dat"
  local reason = "permission denied"
  lurek.log.error(
    "save failed: path='" .. save_path .. "' reason=" .. reason .. " (falling back to slot1)",
    "save"
  )
end

--@api-stub: lurek.log.print
-- Logs at a runtime-chosen level, useful when severity comes from config or data
do
  -- Example: a modding system where script authors choose their own log level.
  local mod_log_level = "info"  -- read from mod manifest
  local mod_name = "expanded_items"
  lurek.log.print(mod_log_level, "mod '" .. mod_name .. "' initialized (v1.2.0)", "mods")
end

--@api-stub: lurek.log.debug_fields
-- Logs a debug message with a structured key-value table
do
  -- Structured fields make logs machine-parseable for tooling and dashboards.
  lurek.log.debug_fields("physics step", {
    bodies = 64,
    contacts = 12,
    step_ms = 1.8,
    island_count = 3,
  })
end

--@api-stub: lurek.log.info_fields
-- Logs an info message with structured fields
do
  -- Record session milestones with exact numeric data for analytics.
  lurek.log.info_fields("checkpoint reached", {
    checkpoint = "forest_bridge",
    play_time_s = 924,
    deaths = 2,
    coins = 187,
  })
end

--@api-stub: lurek.log.warn_fields
-- Logs a warning with structured fields for machine-parseable diagnostics
do
  -- Attach frame budget data so automated tools can correlate spikes.
  local gpu_ms = 14.2
  local budget_ms = 11.1
  if gpu_ms > budget_ms then
    lurek.log.warn_fields("gpu over budget", {
      gpu_ms = gpu_ms,
      budget_ms = budget_ms,
      scene = "particle_storm",
      draw_calls = 320,
    })
  end
end

--@api-stub: lurek.log.error_fields
-- Logs an error with structured fields for post-mortem analysis
do
  -- Include all context needed to reproduce without asking the player.
  lurek.log.error_fields("asset load failed", {
    path = "sprites/boss_phase3.png",
    operation = "texture_decode",
    error_code = 2,
    fallback = "sprites/placeholder.png",
  })
end

--@api-stub: lurek.log.struct
-- Logs a structured message at a runtime-selected level
do
  -- Useful when both level and fields come from game data (e.g., telemetry config).
  local event_level = "info"
  lurek.log.struct(event_level, "item crafted", {
    recipe = "iron_sword",
    materials_used = 3,
    quality = "rare",
    crafter = "player_01",
  })
end

--@api-stub: lurek.log.addSink
-- Registers a new sink (memory, file, rotating, or callback) and returns its id
do
  -- Memory sink: captures recent warnings in a ring buffer for an in-game console.
  local console_sink = lurek.log.addSink({
    type = "memory",
    capacity = 128,
    level = "warn",
  })

  -- File sink: writes all info+ messages to a session log for QA.
  local session_sink = lurek.log.addSink({
    type = "file",
    path = "save/session.log",
    level = "info",
  })

  lurek.log.info("sinks ready: console=" .. console_sink .. " session=" .. session_sink, "boot")
end

--@api-stub: lurek.log.removeSink
-- Removes a sink by id; returns true if it existed
do
  -- Temporarily attach a diagnostic sink, then remove it after the hot section.
  local diag = lurek.log.addSink({ type = "memory", capacity = 64, level = "debug" })
  lurek.log.debug("entering boss fight diagnostics", "combat")
  -- ... boss fight runs ...
  local was_removed = lurek.log.removeSink(diag)
  lurek.log.info("diag sink removed=" .. tostring(was_removed), "combat")
end

--@api-stub: lurek.log.clearSinks
-- Removes ALL sinks; useful during teardown or hot-reload
do
  -- On scene transition, clear old sinks before setting up new ones.
  lurek.log.addSink({ type = "memory", capacity = 32 })
  lurek.log.addSink({ type = "memory", capacity = 32, level = "error" })
  lurek.log.clearSinks()
  -- After clearing, only stderr remains. Re-add sinks for the new scene.
  lurek.log.info("sinks cleared for scene transition", "scene")
end

--@api-stub: lurek.log.listSinks
-- Returns an array of tables describing every active sink
do
  -- Use this to build a developer HUD showing which sinks are active.
  lurek.log.addSink({ type = "memory", capacity = 100, level = "info" })
  local sinks = lurek.log.listSinks()
  for _, s in ipairs(sinks) do
    lurek.log.debug(
      string.format("sink #%d type=%s level=%s", s.id, s.type, s.level),
      "diag"
    )
  end
end

--@api-stub: lurek.log.readMemory
-- Reads entries from a memory sink; optionally drains (clears) them
do
  -- Feed an in-game developer console from the memory sink.
  local hud_sink = lurek.log.addSink({ type = "memory", capacity = 64, level = "warn" })
  lurek.log.warn("enemy stuck in wall at tile (14,8)", "ai")
  lurek.log.warn("texture atlas rebuild took 32ms", "render")

  -- drain=true means we won't see these entries again on next read.
  local entries = lurek.log.readMemory(hud_sink, true)
  for _, e in ipairs(entries) do
    -- Each entry has .level, .tag, .message, .timestamp
    print(string.format("[%s][%s] %s", e.level, e.tag, e.message))
  end
end

--@api-stub: lurek.log.flushFile
-- Forces a file sink to write buffered data to disk immediately
do
  -- Call this before a risky operation so the log is complete if the game crashes.
  local crash_log = lurek.log.addSink({ type = "file", path = "save/crash.log", level = "error" })
  lurek.log.error("unrecoverable state: physics world desynced", "engine")
  lurek.log.flushFile(crash_log)
  -- Now the file has the error even if we abort right after.
end

print("content/examples/log.lua")
