-- content/snippets/engine.lua
-- Handcrafted snippets for lurek.engine — runtime identity, performance, memory, profiling.
-- API surface covered: getVersion, platform, isDebug, fps, frameCount, uptime,
--   getFrameBudget, getConfigRevision, memoryUsage, setResourceBudget, getResourceStats,
--   getFrameProfile, getFrameProfileText

local ver = lurek.engine.getVersion()
local PLATFORM = lurek.engine.platform()
local fps = lurek.engine.fps()
local frame = lurek.engine.frameCount()
local uptime_s = lurek.engine.uptime()
local FIXED_DT = 1 / 60
local _last_rev = lurek.engine.getConfigRevision()
local mem = lurek.engine.memoryUsage()
local MB = 1024 * 1024
local prof = lurek.engine.getFrameProfile()
local budget_ms = lurek.engine.getFrameBudget()

-- ─────────────────────────────────────────────────────────────
-- IDENTITY & BUILD
-- ─────────────────────────────────────────────────────────────

-- @snippet lurek.engine.version_guard
-- @prefix lk-engine-version-guard
-- @module engine
-- @description Use at the very top of main.lua to assert a minimum engine version before any other code runs. Prevents silent breakage when players ship or run an older binary without rebuilding.
-- @body
local SNIP_1_ver = lurek.engine.getVersion()
assert(ver >= "0.6", "lurek " .. ver .. " too old — need 0.6+")
print("[boot] engine=" .. ver
    .. " platform=" .. lurek.engine.platform()
    .. " debug=" .. tostring(lurek.engine.isDebug()))
-- @end

-- @snippet lurek.engine.platform_branch
-- @prefix lk-engine-platform-branch
-- @module engine
-- @description Use when you need platform-specific paths: keybind hint text, default save directories, cursor behaviour, or audio driver selection. Cache at module level — avoid calling platform() every frame.
-- @body
local SNIP_1_PLATFORM   = lurek.engine.platform()
local IS_WINDOWS = PLATFORM == "windows"
local IS_LINUX   = PLATFORM == "linux"
local IS_MAC     = PLATFORM == "macos"

if IS_WINDOWS then
    print("windows path: use AppData")
elseif IS_LINUX then
    print("linux path: use ~/.local/share")
elseif IS_MAC then
    print("mac path: use ~/Library/Application Support")
end
-- @end

-- @snippet lurek.engine.debug_only_block
-- @prefix lk-engine-debug-only-block
-- @module engine
-- @description Use to gate ALL expensive debug overlays, cheat commands, and verbose assertion dumps. In release, isDebug() returns false so this block is skipped entirely — no runtime cost.
-- @body
if lurek.engine.isDebug() then
    -- god mode keybind, profiler HUD, overlay text, verbose log
    print("[debug] diagnostics active, ver=" .. lurek.engine.getVersion())
end
-- SNIP_1_MODULE: lurek
-- @end

-- ─────────────────────────────────────────────────────────────
-- FRAME RATE & TIMING
-- ─────────────────────────────────────────────────────────────

-- @snippet lurek.engine.fps_warn_threshold
-- @prefix lk-engine-fps-warn
-- @module engine
-- @description Use in update() to detect sustained low-FPS before players notice stutter. Derives the warning threshold from the actual frame budget so the check stays valid across 30 / 60 / 120 FPS targets.
-- @body
local SNIP_1_fps      = lurek.engine.fps()
local budget_ms = lurek.engine.getFrameBudget()
local warn_fps  = (1000 / budget_ms) * 0.75   -- 75 % of target FPS
if fps < warn_fps then
    print(string.format("[perf] fps=%.1f below warning=%.1f", fps, warn_fps))
end
-- @end

-- @snippet lurek.engine.even_odd_frame_stagger
-- @prefix lk-engine-even-odd-stagger
-- @module engine
-- @description Use to split expensive per-frame work across alternating frames (AI ticks on even, particle updates on odd) without extra boolean state variables. frameCount() is the canonical engine clock — safe to use in save data.
-- @body
local SNIP_1_frame = lurek.engine.frameCount()
if frame % 2 == 0 then
    -- AI tick, physics LOD, ambient sound probe
    print("even frame " .. frame .. ": heavy systems")
else
    -- particle update, UI animation tick
    print("odd frame " .. frame .. ": light systems")
end
-- @end

-- @snippet lurek.engine.uptime_session_stamp
-- @prefix lk-engine-uptime-stamp
-- @module engine
-- @description Use for session analytics, auto-save triggers, and achievement timers. uptime() is wall-clock seconds since engine start — combine with frameCount() to attach a reproducible stamp to save records and bug reports.
-- @body
local SNIP_1_uptime_s = lurek.engine.uptime()
local minutes  = math.floor(uptime_s / 60)
local seconds  = math.floor(uptime_s % 60)
local stamp    = string.format("t=%dm%02ds  f=%d", minutes, seconds, lurek.engine.frameCount())
print("[session] " .. stamp)
-- @end

-- @snippet lurek.engine.fixed_timestep_accumulator
-- @prefix lk-engine-fixed-dt
-- @module engine
-- @description Use for physics / simulation that needs deterministic fixed steps. Drives the accumulator loop with uptime delta; clamps the spiral-of-death so a slow machine can't accumulate hundreds of ticks on one spike frame.
-- @body
local SNIP_1_FIXED_DT  = 1 / 60
local _accum    = 0
local _last_t   = lurek.engine.uptime()

-- call this each frame from your update() callback:
local function tick_fixed()
    local now   = lurek.engine.uptime()
    local delta = math.min(now - _last_t, 0.25)  -- spiral-of-death cap = 250 ms
    _last_t     = now
    _accum      = _accum + delta
    while _accum >= FIXED_DT do
        -- fixed_update(FIXED_DT)
        _accum = _accum - FIXED_DT
    end
    return _accum / FIXED_DT  -- interpolation alpha [0..1)
end
local alpha = tick_fixed()
print("fixed tick alpha=" .. string.format("%.3f", alpha))
-- @end

-- @snippet lurek.engine.config_revision_hotreload
-- @prefix lk-engine-config-hotreload
-- @module engine
-- @description Use when supporting hot-reload of conf.toml at runtime. Compare the config revision each frame; if it changed, re-read and re-apply settings without restarting the game.
-- @body
local SNIP_1__last_rev = lurek.engine.getConfigRevision()

local function check_config_reload()
    local rev = lurek.engine.getConfigRevision()
    if rev ~= _last_rev then
        _last_rev = rev
        print("[config] revision=" .. rev .. " — reloading settings")
        -- re-apply volume, keybinds, resolution, locale…
    end
end
check_config_reload()
-- @end

-- ─────────────────────────────────────────────────────────────
-- MEMORY
-- ─────────────────────────────────────────────────────────────

-- @snippet lurek.engine.memory_hud_line
-- @prefix lk-engine-memory-hud
-- @module engine
-- @description Use for a single-line memory HUD. Combines lua_kb + resource stats into one formatted string suitable for lurek.render.print() in a debug overlay.
-- @body
local SNIP_1_mem   = lurek.engine.memoryUsage()
local stats = lurek.engine.getResourceStats()
local res_mb    = stats.total_bytes  / (1024 * 1024)
local budget_mb = stats.budget_bytes / (1024 * 1024)
local hud = string.format("lua=%d KB  res=%.1f/%.0f MB", mem.lua_kb, res_mb, budget_mb)
lurek.render.setColor(0.9, 0.9, 0.9, 0.8)
lurek.render.print(hud, 8, 8)
lurek.render.setColor(1, 1, 1, 1)
-- @end

-- @snippet lurek.engine.resource_budget_init
-- @prefix lk-engine-resource-budget-init
-- @module engine
-- @description Use once in main.lua or level_init() to set the memory ceiling for all loaded assets. Prevents unbounded accumulation during level streaming. Pick a value ≤ 50 % of target device RAM to leave headroom for OS + GPU.
-- @body
local SNIP_1_MB = 1024 * 1024
lurek.engine.setResourceBudget(128 * MB)
local s = lurek.engine.getResourceStats()
print(string.format("[init] resource budget=%.0f MB total=%.1f MB",
    s.budget_bytes / MB, s.total_bytes / MB))
-- @end

-- @snippet lurek.engine.resource_pressure_abort_load
-- @prefix lk-engine-pressure-abort-load
-- @module engine
-- @description Use before streaming a large asset batch (level, cutscene). Abort the load early and trigger a cache purge if utilisation is already above 85 %, rather than crashing mid-load with an OOM.
-- @body
local SNIP_1_stats = lurek.engine.getResourceStats()
local ratio = (stats.budget_bytes > 0) and (stats.total_bytes / stats.budget_bytes) or 0
if ratio > 0.85 then
    error(string.format("resource pressure %.0f%% — purge cache before loading level", ratio * 100))
end
print(string.format("[load] pressure=%.0f%%, ok to proceed", ratio * 100))
-- @end

-- ─────────────────────────────────────────────────────────────
-- PROFILING
-- ─────────────────────────────────────────────────────────────

-- @snippet lurek.engine.frame_profile_breakdown
-- @prefix lk-engine-frame-profile
-- @module engine
-- @description Use during optimisation sprints to print a structured per-phase breakdown each frame. More actionable than fps() alone — shows which phase (lua, render, audio) is the bottleneck.
-- @body
local SNIP_1_prof = lurek.engine.getFrameProfile()
print(string.format(
    "[prof] total=%.2fms  budget=%dms  fps=%.1f",
    prof.app_frame_total_ms,
    lurek.engine.getFrameBudget(),
    lurek.engine.fps()
))
-- @end

-- @snippet lurek.engine.profile_text_overlay
-- @prefix lk-engine-profile-overlay
-- @module engine
-- @description Use as a single-line debug overlay. getFrameProfileText() returns a pre-formatted multi-line string — pass it straight to render.print().
-- @body
if lurek.engine.isDebug() then
    lurek.render.setColor(0.9, 0.9, 0.9, 0.85)
    lurek.render.print(lurek.engine.getFrameProfileText(), 8, 8)
    lurek.render.setColor(1, 1, 1, 1)
end
-- SNIP_1_MODULE: lurek
-- @end

-- @snippet lurek.engine.spike_frame_log
-- @prefix lk-engine-spike-log
-- @module engine
-- @description Use to detect and log individual spike frames without flooding the console. Only prints profile text when the frame exceeds 2× the configured budget.
-- @body
local SNIP_1_budget_ms = lurek.engine.getFrameBudget()
local prof      = lurek.engine.getFrameProfile()
if prof.app_frame_total_ms > budget_ms * 2 then
    print(string.format("[spike] f=%d  %.1fms (budget=%dms)",
        lurek.engine.frameCount(), prof.app_frame_total_ms, budget_ms))
    print(lurek.engine.getFrameProfileText())
end
-- @end

-- @snippet lurek.engine.boot_record
-- @prefix lk-engine-boot-record
-- @module engine
-- @description Use as the very first call in main.lua. Emits one reproducible boot record that correlates crash reports with the exact binary, platform, and memory state at launch.
-- @body
local function print_boot_record()
    local SNIP_1_mem   = lurek.engine.memoryUsage()
    local stats = lurek.engine.getResourceStats()
    print(string.format(
        "[boot] ver=%s  platform=%s  debug=%s  budget_ms=%d  lua_kb=%d  res_budget_mb=%.0f",
        lurek.engine.getVersion(),
        lurek.engine.platform(),
        tostring(lurek.engine.isDebug()),
        lurek.engine.getFrameBudget(),
        mem.lua_kb,
        stats.budget_bytes / (1024 * 1024)
    ))
end
print_boot_record()
-- @end
