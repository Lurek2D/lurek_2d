-- content/examples/devtools.lua
-- Lurek2D lurek.devtools API Reference
-- Run with: cargo run -- content/examples/devtools
--
-- Scenario: A game development session — logging, profiling frame times,
-- hot-reloading assets via file watchers, live variable watches, and an
-- interactive REPL console for runtime debugging.

print("=== lurek.devtools — Development Tools ===\n")

-- =============================================================================
-- Logging — structured log output to console and file
-- =============================================================================

-- ---- Stub: lurek.devtools.setLogLevel ------------------------------------
--@api-stub: lurek.devtools.setLogLevel
-- Demonstrates the proper usage of lurek.devtools.setLogLevel.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_devtools_setLogLevel()
    lurek.devtools.setLogLevel("debug")
    print("log level set to: debug")
end
local _ok, _err = pcall(demo_lurek_devtools_setLogLevel)

-- ---- Stub: lurek.devtools.getLogLevel ------------------------------------
--@api-stub: lurek.devtools.getLogLevel
-- Demonstrates the proper usage of lurek.devtools.getLogLevel.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_devtools_getLogLevel()
    local level = lurek.devtools.getLogLevel()
    print("current log level: " .. tostring(level))
end
local _ok, _err = pcall(demo_lurek_devtools_getLogLevel)

-- ---- Stub: lurek.devtools.setLogConsole ----------------------------------
--@api-stub: lurek.devtools.setLogConsole
-- Demonstrates the proper usage of lurek.devtools.setLogConsole.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_devtools_setLogConsole()
    lurek.devtools.setLogConsole(true)
    print("console logging enabled")
end
local _ok, _err = pcall(demo_lurek_devtools_setLogConsole)

-- ---- Stub: lurek.devtools.getLogConsole ----------------------------------
--@api-stub: lurek.devtools.getLogConsole
-- Demonstrates the proper usage of lurek.devtools.getLogConsole.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_devtools_getLogConsole()
    local console_on = lurek.devtools.getLogConsole()
    print("console logging: " .. tostring(console_on))
end
local _ok, _err = pcall(demo_lurek_devtools_getLogConsole)

-- ---- Stub: lurek.devtools.setLogFile -------------------------------------
--@api-stub: lurek.devtools.setLogFile
-- Demonstrates the proper usage of lurek.devtools.setLogFile.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_devtools_setLogFile()
    lurek.devtools.setLogFile("logs/game_debug.log")
    print("log file set to: logs/game_debug.log")
end
local _ok, _err = pcall(demo_lurek_devtools_setLogFile)

-- ---- Stub: lurek.devtools.getLogFile -------------------------------------
--@api-stub: lurek.devtools.getLogFile
-- Demonstrates the proper usage of lurek.devtools.getLogFile.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_devtools_getLogFile()
    local log_path = lurek.devtools.getLogFile()
    print("log file path: " .. tostring(log_path))
end
local _ok, _err = pcall(demo_lurek_devtools_getLogFile)

-- ---- Stub: lurek.devtools.log --------------------------------------------
--@api-stub: lurek.devtools.log
-- Demonstrates the proper usage of lurek.devtools.log.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_devtools_log()
    lurek.devtools.log("info", "Game started — loading level 1")
    lurek.devtools.log("debug", "Player spawn at (100, 200)")
    lurek.devtools.log("warn", "Texture 'enemy_boss.png' not found — using fallback")
    lurek.devtools.log("error", "Physics body leaked — entity destroyed without cleanup")
    print("4 log messages written at different levels")
end
local _ok, _err = pcall(demo_lurek_devtools_log)

-- ---- Stub: lurek.devtools.getLogHistory ----------------------------------
--@api-stub: lurek.devtools.getLogHistory
-- Demonstrates the proper usage of lurek.devtools.getLogHistory.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_devtools_getLogHistory()
    local history = lurek.devtools.getLogHistory(10)
    if history then
    print("recent log entries: " .. #history)
    for i, entry in ipairs(history) do
        print("  [" .. i .. "] " .. tostring(entry.level or "") .. ": " .. tostring(entry.message or entry))
    end
end
local _ok, _err = pcall(demo_lurek_devtools_getLogHistory)

-- ---- Stub: lurek.devtools.clearLog ---------------------------------------
--@api-stub: lurek.devtools.clearLog
-- Demonstrates the proper usage of lurek.devtools.clearLog.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_devtools_clearLog()
    lurek.devtools.clearLog()
    print("log buffer cleared")
end
local _ok, _err = pcall(demo_lurek_devtools_clearLog)

-- =============================================================================
-- Profiling — measure frame zones and identify hot paths
-- =============================================================================

-- ---- Stub: lurek.devtools.setProfilingEnabled ----------------------------
--@api-stub: lurek.devtools.setProfilingEnabled
-- Demonstrates the proper usage of lurek.devtools.setProfilingEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_devtools_setProfilingEnabled()
    lurek.devtools.setProfilingEnabled(true)
    print("profiling enabled")
end
local _ok, _err = pcall(demo_lurek_devtools_setProfilingEnabled)

-- ---- Stub: lurek.devtools.isProfilingEnabled -----------------------------
--@api-stub: lurek.devtools.isProfilingEnabled
-- Demonstrates the proper usage of lurek.devtools.isProfilingEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_devtools_isProfilingEnabled()
    local profiling = lurek.devtools.isProfilingEnabled()
    print("profiling active: " .. tostring(profiling))
end
local _ok, _err = pcall(demo_lurek_devtools_isProfilingEnabled)

-- ---- Stub: lurek.devtools.profilePush ------------------------------------
--@api-stub: lurek.devtools.profilePush
-- Demonstrates the proper usage of lurek.devtools.profilePush.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_devtools_profilePush()
    lurek.devtools.profilePush("update")
  lurek.devtools.profilePush("physics")
end
local _ok, _err = pcall(demo_lurek_devtools_profilePush)

-- ---- Stub: lurek.devtools.profilePop -------------------------------------
--@api-stub: lurek.devtools.profilePop
-- Close profiling zones in reverse order (LIFO).
  lurek.devtools.profilePop()  -- closes "physics"
  lurek.devtools.profilePush("ai")
  -- ... AI tick work happens here ...
  lurek.devtools.profilePop()  -- closes "ai"
lurek.devtools.profilePop()    -- closes "update"
print("profiling zones: update > physics, update > ai")

-- ---- Stub: lurek.devtools.profileFrame -----------------------------------
--@api-stub: lurek.devtools.profileFrame
-- Demonstrates the proper usage of lurek.devtools.profileFrame.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_devtools_profileFrame()
    lurek.devtools.profileFrame()
    print("profile frame sealed")
end
local _ok, _err = pcall(demo_lurek_devtools_profileFrame)

-- ---- Stub: lurek.devtools.getProfileFrameCount ---------------------------
--@api-stub: lurek.devtools.getProfileFrameCount
-- Demonstrates the proper usage of lurek.devtools.getProfileFrameCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_devtools_getProfileFrameCount()
    local frame_count = lurek.devtools.getProfileFrameCount()
    print("retained profile frames: " .. tostring(frame_count))
end
local _ok, _err = pcall(demo_lurek_devtools_getProfileFrameCount)

-- ---- Stub: lurek.devtools.getProfileData ---------------------------------
--@api-stub: lurek.devtools.getProfileData
-- Demonstrates the proper usage of lurek.devtools.getProfileData.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_devtools_getProfileData()
    local profile = lurek.devtools.getProfileData(nil)
    if profile then
    print("profile zones in latest frame:")
    for _, zone in ipairs(profile) do
        print("  " .. tostring(zone.name or "?") .. ": " .. tostring(zone.duration_ms or zone.time or "?") .. "ms")
    end
    else
    print("no profile data yet")
end
local _ok, _err = pcall(demo_lurek_devtools_getProfileData)

-- ---- Stub: lurek.devtools.profilerReport ---------------------------------
--@api-stub: lurek.devtools.profilerReport
-- Generate a flat summary of all zones across all stored frames.
-- Useful for finding the most expensive systems over multiple frames.
local report = lurek.devtools.profilerReport()
if report then
    print("profiler report (" .. #report .. " zones):")
    for _, z in ipairs(report) do
        print("  " .. tostring(z.name or "?")
            .. " — avg: " .. tostring(z.avg_ms or "?") .. "ms"
            .. ", max: " .. tostring(z.max_ms or "?") .. "ms"
            .. ", calls: " .. tostring(z.calls or "?"))
    end
end

-- ---- Stub: lurek.devtools.resetProfile -----------------------------------
--@api-stub: lurek.devtools.resetProfile
-- Demonstrates the proper usage of lurek.devtools.resetProfile.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_devtools_resetProfile()
    lurek.devtools.resetProfile()
    print("profiler reset — all zone data cleared")
end
local _ok, _err = pcall(demo_lurek_devtools_resetProfile)

-- =============================================================================
-- Frame Time Tracking — FPS counter and timing statistics
-- =============================================================================

-- ---- Stub: lurek.devtools.setFrameHistorySize ----------------------------
--@api-stub: lurek.devtools.setFrameHistorySize
-- Demonstrates the proper usage of lurek.devtools.setFrameHistorySize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_devtools_setFrameHistorySize()
    lurek.devtools.setFrameHistorySize(300)
    print("frame history buffer: 300 samples")
end
local _ok, _err = pcall(demo_lurek_devtools_setFrameHistorySize)

-- ---- Stub: lurek.devtools.getFrameHistorySize ----------------------------
--@api-stub: lurek.devtools.getFrameHistorySize
-- Demonstrates the proper usage of lurek.devtools.getFrameHistorySize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_devtools_getFrameHistorySize()
    local hist_size = lurek.devtools.getFrameHistorySize()
    print("frame history size: " .. tostring(hist_size))
end
local _ok, _err = pcall(demo_lurek_devtools_getFrameHistorySize)

-- ---- Stub: lurek.devtools.recordFrameTime --------------------------------
--@api-stub: lurek.devtools.recordFrameTime
-- Demonstrates the proper usage of lurek.devtools.recordFrameTime.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_devtools_recordFrameTime()
    local simulated_dts = {0.0166, 0.0167, 0.0165, 0.0200, 0.0333, 0.0166, 0.0168}
    for _, dt in ipairs(simulated_dts) do
    lurek.devtools.recordFrameTime(dt)
    print(#simulated_dts .. " frame time samples recorded")
end
local _ok, _err = pcall(demo_lurek_devtools_recordFrameTime)

-- ---- Stub: lurek.devtools.getFrameStats ----------------------------------
--@api-stub: lurek.devtools.getFrameStats
-- Demonstrates the proper usage of lurek.devtools.getFrameStats.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_devtools_getFrameStats()
    local stats = lurek.devtools.getFrameStats()
    if stats then
    print("frame stats:")
    print("  avg:  " .. tostring(stats.avg_ms or stats.avg or "?") .. "ms")
    print("  min:  " .. tostring(stats.min_ms or stats.min or "?") .. "ms")
    print("  max:  " .. tostring(stats.max_ms or stats.max or "?") .. "ms")
    print("  fps:  " .. tostring(stats.fps or "?"))
end
local _ok, _err = pcall(demo_lurek_devtools_getFrameStats)

-- ---- Stub: lurek.devtools.getFrameHistory --------------------------------
--@api-stub: lurek.devtools.getFrameHistory
-- Demonstrates the proper usage of lurek.devtools.getFrameHistory.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_devtools_getFrameHistory()
    local frame_hist = lurek.devtools.getFrameHistory()
    if frame_hist then
    print("frame history: " .. #frame_hist .. " samples")
end
local _ok, _err = pcall(demo_lurek_devtools_getFrameHistory)

-- =============================================================================
-- File Watching — hot-reload assets and scripts during development
-- =============================================================================

-- ---- Stub: lurek.devtools.watch ------------------------------------------
--@api-stub: lurek.devtools.watch
-- Watch the player sprite sheet for live editing — re-upload texture on change.
local added = lurek.devtools.watch("assets/sprites/player.png")
print("watch 'assets/sprites/player.png': " .. tostring(added))

-- Also watch the main game script for hot-reload.
lurek.devtools.watch("main.lua")
lurek.devtools.watch("assets/levels/level1.json")
print("3 paths watched for changes")

-- ---- Stub: lurek.devtools.getWatchedPaths --------------------------------
--@api-stub: lurek.devtools.getWatchedPaths
-- Demonstrates the proper usage of lurek.devtools.getWatchedPaths.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_devtools_getWatchedPaths()
    local watched = lurek.devtools.getWatchedPaths()
    if watched then
    print("watched paths (" .. #watched .. "):")
    for _, p in ipairs(watched) do print("  " .. p) end
end
local _ok, _err = pcall(demo_lurek_devtools_getWatchedPaths)

-- ---- Stub: lurek.devtools.getWatchInterval -------------------------------
--@api-stub: lurek.devtools.getWatchInterval
-- Demonstrates the proper usage of lurek.devtools.getWatchInterval.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_devtools_getWatchInterval()
    local interval = lurek.devtools.getWatchInterval()
    print("watch poll interval: " .. tostring(interval) .. "s")
end
local _ok, _err = pcall(demo_lurek_devtools_getWatchInterval)

-- ---- Stub: lurek.devtools.setWatchInterval -------------------------------
--@api-stub: lurek.devtools.setWatchInterval
-- Demonstrates the proper usage of lurek.devtools.setWatchInterval.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_devtools_setWatchInterval()
    lurek.devtools.setWatchInterval(0.5)
    print("watch interval set to 0.5s")
end
local _ok, _err = pcall(demo_lurek_devtools_setWatchInterval)

-- ---- Stub: lurek.devtools.scan -------------------------------------------
--@api-stub: lurek.devtools.scan
-- Poll all watched paths and get a list of files that changed since last scan.
-- Call this once per frame in lurek.process() to detect hot-reload triggers.
local changed = lurek.devtools.scan()
if changed and #changed > 0 then
    print("changed files:")
    for _, path in ipairs(changed) do
        print("  " .. path .. " — triggering reload")
    end
else
    print("no files changed since last scan")
end

-- ---- Stub: lurek.devtools.unwatch ----------------------------------------
--@api-stub: lurek.devtools.unwatch
-- Demonstrates the proper usage of lurek.devtools.unwatch.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_devtools_unwatch()
    local removed = lurek.devtools.unwatch("assets/levels/level1.json")
    print("unwatched level1.json: " .. tostring(removed))
end
local _ok, _err = pcall(demo_lurek_devtools_unwatch)

-- ---- Stub: lurek.devtools.clearWatches -----------------------------------
--@api-stub: lurek.devtools.clearWatches
-- Demonstrates the proper usage of lurek.devtools.clearWatches.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_devtools_clearWatches()
    lurek.devtools.clearWatches()
    print("all file watches cleared")
end
local _ok, _err = pcall(demo_lurek_devtools_clearWatches)

-- =============================================================================
-- Standalone FileWatcher — per-asset watcher with callback
-- =============================================================================

-- ---- Stub: lurek.devtools.newFileWatcher ---------------------------------
--@api-stub: lurek.devtools.newFileWatcher
-- Demonstrates the proper usage of lurek.devtools.newFileWatcher.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_devtools_newFileWatcher()
    local tilemap_watcher = lurek.devtools.newFileWatcher("assets/maps/dungeon.tmx")
    print("FileWatcher created for: assets/maps/dungeon.tmx")
end
local _ok, _err = pcall(demo_lurek_devtools_newFileWatcher)

-- ---- Stub: FileWatcher:getPath -------------------------------------------
--@api-stub: FileWatcher:getPath
-- Demonstrates the proper usage of FileWatcher:getPath.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_FileWatcher_getPath()
    local wp = tilemap_watcher:getPath()
    print("watcher path: " .. tostring(wp))
end
local _ok, _err = pcall(demo_FileWatcher_getPath)

-- ---- Stub: FileWatcher:onChanged -----------------------------------------
--@api-stub: FileWatcher:onChanged
-- Demonstrates the proper usage of FileWatcher:onChanged.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_FileWatcher_onChanged()
    tilemap_watcher:onChanged(function()
    print("  [watcher] dungeon.tmx changed — reloading tilemap!")
    print("onChanged callback registered for tilemap watcher")
end
local _ok, _err = pcall(demo_FileWatcher_onChanged)

-- ---- Stub: FileWatcher:check ---------------------------------------------
--@api-stub: FileWatcher:check
-- Demonstrates the proper usage of FileWatcher:check.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_FileWatcher_check()
    local did_change = tilemap_watcher:check()
    print("tilemap watcher check: changed=" .. tostring(did_change))
end
local _ok, _err = pcall(demo_FileWatcher_check)

-- ---- Stub: FileWatcher:cancel --------------------------------------------
--@api-stub: FileWatcher:cancel
-- Demonstrates the proper usage of FileWatcher:cancel.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_FileWatcher_cancel()
    tilemap_watcher:cancel()
    print("tilemap watcher cancelled")
end
local _ok, _err = pcall(demo_FileWatcher_cancel)

-- =============================================================================
-- Live Watches — expose game variables for the debug inspector
-- =============================================================================

local player_hp = 85
local player_x, player_y = 100, 200
local enemy_count = 7

-- ---- Stub: lurek.devtools.exposeWatch ------------------------------------
--@api-stub: lurek.devtools.exposeWatch
-- Register live watches that sample game state on demand.
-- The getter function is called each time the debug panel refreshes.
local watch_hp = lurek.devtools.exposeWatch("player_hp", function()
    return player_hp
end, "player")
print("watch registered: player_hp (id=" .. tostring(watch_hp) .. ")")

local watch_pos = lurek.devtools.exposeWatch("player_pos", function()
    return player_x .. ", " .. player_y
end, "player")
print("watch registered: player_pos (id=" .. tostring(watch_pos) .. ")")

local watch_enemies = lurek.devtools.exposeWatch("enemy_count", function()
    return enemy_count
end, "world")
print("watch registered: enemy_count (id=" .. tostring(watch_enemies) .. ")")

-- ---- Stub: lurek.devtools.getWatches -------------------------------------
--@api-stub: lurek.devtools.getWatches
-- Demonstrates the proper usage of lurek.devtools.getWatches.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_devtools_getWatches()
    local watches = lurek.devtools.getWatches()
    if watches then
    print("live watches (" .. #watches .. "):")
    for _, w in ipairs(watches) do
        print("  [" .. tostring(w.category or "?") .. "] "
            .. tostring(w.name or "?") .. " = " .. tostring(w.value or "?"))
    end
end
local _ok, _err = pcall(demo_lurek_devtools_getWatches)

-- ---- Stub: lurek.devtools.removeWatch ------------------------------------
--@api-stub: lurek.devtools.removeWatch
-- Demonstrates the proper usage of lurek.devtools.removeWatch.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_devtools_removeWatch()
    local removed_w = lurek.devtools.removeWatch(watch_enemies)
    print("enemy_count watch removed: " .. tostring(removed_w))
end
local _ok, _err = pcall(demo_lurek_devtools_removeWatch)

-- =============================================================================
-- Snapshot and Console — capture state, evaluate expressions
-- =============================================================================

-- ---- Stub: lurek.devtools.snapshot ---------------------------------------
--@api-stub: lurek.devtools.snapshot
-- Take a full debug snapshot — combines watches, frame stats, and profile data
-- into one table for serialization or remote debugging.
local snap = lurek.devtools.snapshot()
if snap then
    print("debug snapshot captured:")
    for k, _ in pairs(snap) do print("  section: " .. k) end
end

-- ---- Stub: lurek.devtools.getCallStack -----------------------------------
--@api-stub: lurek.devtools.getCallStack
-- Capture the current Lua call stack for error reporting.
-- Max depth of 10 frames keeps the output manageable.
local stack = lurek.devtools.getCallStack(10)
if stack then
    print("call stack (" .. #stack .. " frames):")
    for i, frame in ipairs(stack) do
        print("  " .. i .. ": " .. tostring(frame.source or "?")
            .. ":" .. tostring(frame.line or "?")
            .. " " .. tostring(frame.name or "<anonymous>"))
    end
end

-- ---- Stub: lurek.devtools.eval -------------------------------------------
--@api-stub: lurek.devtools.eval
-- Demonstrates the proper usage of lurek.devtools.eval.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_devtools_eval()
    print("eval '2 + 2': ok=" .. tostring(ok) .. " result=" .. tostring(result))
end
local _ok, _err = pcall(demo_lurek_devtools_eval)

-- ---- Stub: lurek.devtools.openConsole ------------------------------------
--@api-stub: lurek.devtools.openConsole
-- Demonstrates the proper usage of lurek.devtools.openConsole.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_devtools_openConsole()
    local opened = lurek.devtools.openConsole()
    print("console opened: " .. tostring(opened))
end
local _ok, _err = pcall(demo_lurek_devtools_openConsole)

-- ---- Stub: lurek.devtools.isConsoleOpen ----------------------------------
--@api-stub: lurek.devtools.isConsoleOpen
-- Demonstrates the proper usage of lurek.devtools.isConsoleOpen.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_devtools_isConsoleOpen()
    local console_open = lurek.devtools.isConsoleOpen()
    print("console open: " .. tostring(console_open))
end
local _ok, _err = pcall(demo_lurek_devtools_isConsoleOpen)

-- =============================================================================
-- REPL Console — interactive Lua shell with history
-- =============================================================================

-- ---- Stub: lurek.devtools.newRepl ----------------------------------------
--@api-stub: lurek.devtools.newRepl
-- Demonstrates the proper usage of lurek.devtools.newRepl.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_devtools_newRepl()
    local repl = lurek.devtools.newRepl(100)
    print("REPL console created with 100-entry history")
end
local _ok, _err = pcall(demo_lurek_devtools_newRepl)

-- ---- Stub: ReplConsole:eval ----------------------------------------------
--@api-stub: ReplConsole:eval
-- Demonstrates the proper usage of ReplConsole:eval.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ReplConsole_eval()
    local r1 = repl:eval("return 'Hello from REPL'")
    print("repl eval: " .. tostring(r1))
    local r2 = repl:eval("return math.sqrt(144)")
    print("repl eval: " .. tostring(r2))
    local r3 = repl:eval("return type(lurek)")
    print("repl eval: " .. tostring(r3))
end
local _ok, _err = pcall(demo_ReplConsole_eval)

-- ---- Stub: ReplConsole:history -------------------------------------------
--@api-stub: ReplConsole:history
-- Demonstrates the proper usage of ReplConsole:history.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ReplConsole_history()
    local repl_hist = repl:history()
    if repl_hist then
    print("REPL history (" .. #repl_hist .. " entries):")
    for i, cmd in ipairs(repl_hist) do
        print("  [" .. i .. "] " .. cmd)
    end
end
local _ok, _err = pcall(demo_ReplConsole_history)

-- ---- Stub: ReplConsole:len -----------------------------------------------
--@api-stub: ReplConsole:len
-- Demonstrates the proper usage of ReplConsole:len.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ReplConsole_len()
    local hist_count = repl:len()
    print("REPL history length: " .. tostring(hist_count))
end
local _ok, _err = pcall(demo_ReplConsole_len)

-- ---- Stub: ReplConsole:clear ---------------------------------------------
--@api-stub: ReplConsole:clear
-- Demonstrates the proper usage of ReplConsole:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ReplConsole_clear()
    repl:clear()
    local after_clear = repl:len()
    print("REPL history after clear: " .. tostring(after_clear))
    print("\n-- devtools.lua example complete --")
end
local _ok, _err = pcall(demo_ReplConsole_clear)
