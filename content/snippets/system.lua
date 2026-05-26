-- content/snippets/system.lua
-- Handcrafted snippets for lurek.runtime — OS detection, versioning, environment,
-- logging, clipboard, config inspection, error handling, and batch tasks.
-- API surface covered: getOS, getVersion, getArch, getInfo, getProcessorCount,
--   getMemorySize, getPreferredLocales, getPowerInfo, getEnv, getArgs, parseArgs,
--   getConfig, reloadConfig, log, setLogLevel, getLogLevel, setClipboardText,
--   getClipboardText, getLastError, errorSnapshot, setDebugOverlay, getDebugOverlay,
--   runBatch, getBatchResults.

local rt = lurek.runtime

-- ─────────────────────────────────────────────────────────────
-- PLATFORM & VERSION DETECTION
-- ─────────────────────────────────────────────────────────────

-- @snippet lurek.runtime.platform_branch
-- @prefix lk-sys-platform-branch
-- @module system
-- @description Use to apply platform-specific code paths (e.g. keyboard shortcuts, path separators, OS integration). Combine with getArch() for more precise dispatch (e.g. "Windows" + "x86_64").
-- @body
local SNIP_1_rt  = lurek.runtime
local os  = rt.getOS()
local arch = rt.getArch()
print("platform=" .. os .. "  arch=" .. arch)
if os == "Windows" then
    -- Windows-specific init
elseif os == "Linux" then
    -- Linux-specific init
elseif os == "macOS" then
    -- macOS-specific init
end
-- @end

-- @snippet lurek.runtime.version_guard
-- @prefix lk-sys-version-guard
-- @module system
-- @description Use at game boot to verify the engine version meets the minimum requirement. Fail fast with a clear message rather than crashing later on a missing API or changed behaviour.
-- @body
local SNIP_1_rt  = lurek.runtime
local ver = rt.getVersion()
print("lurek2d version=" .. ver)

-- Simple semver major.minor comparison
local maj, min = ver:match("^(%d+)%.(%d+)")
maj = tonumber(maj) or 0
min = tonumber(min) or 0

if maj < 0 or (maj == 0 and min < 6) then
    error("This game requires Lurek2D >= 0.6, found " .. ver)
end
print("version ok")
-- @end

-- @snippet lurek.runtime.full_info_dump
-- @prefix lk-sys-info-dump
-- @module system
-- @description Use during development or debug builds to log the full engine environment (OS, version, Lua runtime, renderer, CPU count, memory). Gate behind isDebug to avoid leaking info in release builds.
-- @body
local SNIP_1_rt   = lurek.runtime
local info = rt.getInfo()
if lurek.engine.isDebug() then
    print(string.format(
        "[sys] %s v%s | %s | %s | %d cores | %.0f MB",
        info.engine, info.version, info.os,
        info.lua_version, info.processors,
        (info.memory or 0) / (1024 * 1024)
    ))
end
-- @end

-- ─────────────────────────────────────────────────────────────
-- ENVIRONMENT AND CLI ARGUMENTS
-- ─────────────────────────────────────────────────────────────

-- @snippet lurek.runtime.env_probe_path
-- @prefix lk-sys-env-path
-- @module system
-- @description Use to read environment variables for configuring dev overrides, save directories, or tool paths without hardcoding. Falls back gracefully when the variable is not set.
-- @body
local SNIP_1_rt       = lurek.runtime
local data_dir = rt.getEnv("LUREK_DATA_DIR") or "save"
local log_dir  = rt.getEnv("LUREK_LOG_DIR")  or "logs"
print("data_dir=" .. data_dir)
print("log_dir="  .. log_dir)
-- @end

-- @snippet lurek.runtime.parseargs_config_bootstrap
-- @prefix lk-sys-parseargs
-- @module system
-- @description Use to parse --flag and --key=value CLI arguments at game startup. parseArgs returns structured flags, options, and positional args so you can override config values without editing files.
-- @body
local SNIP_1_rt     = lurek.runtime
local parsed = rt.parseArgs()   -- uses process args by default

local headless    = parsed.flags["headless"]  or false
local config_path = parsed.options["config"]  or "save/options.toml"
local map_name    = parsed.positional[1]      or "main_menu"

print("headless="   .. tostring(headless))
print("config="     .. config_path)
print("start_map="  .. map_name)
-- @end

-- ─────────────────────────────────────────────────────────────
-- LOGGING
-- ─────────────────────────────────────────────────────────────

-- @snippet lurek.runtime.log_structured
-- @prefix lk-sys-log
-- @module system
-- @description Use lurek.runtime.log() for structured game-level log entries instead of print(). Level-tagged messages integrate with the RUST_LOG filter so debug lines are suppressed in release builds automatically.
-- @body
local SNIP_1_rt = lurek.runtime
rt.log("info",  "Game initialising: map=dungeon_01")
rt.log("debug", "Player spawn position: x=100 y=200")
rt.log("warn",  "Save slot 3 missing — creating new save")
rt.log("error", "Failed to load asset: assets/fonts/missing.ttf")
-- @end

-- @snippet lurek.runtime.loglevel_dev_vs_release
-- @prefix lk-sys-loglevel
-- @module system
-- @description Use setLogLevel to lower verbosity in release builds and raise it during development sessions. Pair with getLogLevel() to display the current level in a debug overlay or settings menu.
-- @body
local SNIP_1_rt = lurek.runtime
if lurek.engine.isDebug() then
    rt.setLogLevel("debug")
else
    rt.setLogLevel("warn")
end
print("log level=" .. rt.getLogLevel())
-- @end

-- ─────────────────────────────────────────────────────────────
-- CLIPBOARD
-- ─────────────────────────────────────────────────────────────

-- @snippet lurek.runtime.clipboard_copy_paste
-- @prefix lk-sys-clipboard
-- @module system
-- @description Use for user-facing copy/paste: share codes, map seeds, chat messages. getClipboardText returns nil when the clipboard is empty or unavailable — always guard before using the value.
-- @body
local SNIP_1_rt = lurek.runtime
-- write to clipboard (e.g. player copies a share code)
local share_code = "GAME-ABCD-1234"
rt.setClipboardText(share_code)
print("copied to clipboard: " .. share_code)

-- read back (e.g. player pastes a code from another window)
local pasted = rt.getClipboardText()
if pasted and #pasted > 0 then
    print("pasted: " .. pasted)
else
    print("clipboard empty or unavailable")
end
-- @end

-- ─────────────────────────────────────────────────────────────
-- CONFIG INSPECTION
-- ─────────────────────────────────────────────────────────────

-- @snippet lurek.runtime.config_inspect_hotreload
-- @prefix lk-sys-config-inspect
-- @module system
-- @description Use to read active engine config at runtime and detect when a hot- reload has occurred (config_reload_revision increments). Apply changed values without restarting.
-- @body
local SNIP_1_rt  = lurek.runtime
local cfg = rt.getConfig()
print("runtime_mode="    .. (cfg.runtime_mode or "unknown"))
print("physics_hz="      .. (cfg.physics_tick_rate or 0))
print("log_level="       .. (cfg.log_level or "info"))
print("reload_revision=" .. (cfg.config_reload_revision or 0))

-- detect hot-reload:
local last_rev = cfg.config_reload_revision or 0
-- later in update: if rt.getConfig().config_reload_revision ~= last_rev then apply() end
_ = last_rev
-- @end

-- ─────────────────────────────────────────────────────────────
-- ERROR HANDLING
-- ─────────────────────────────────────────────────────────────

-- @snippet lurek.runtime.last_error_recovery
-- @prefix lk-sys-last-error
-- @module system
-- @description Use getLastError() after calls that can fail to show a user-facing error message and log a diagnostic hint. The table includes message, code, category, and an optional hint for resolution.
-- @body
local SNIP_1_rt  = lurek.runtime
local err = rt.getLastError()
if err then
    print(string.format("[%s] %s (code=%s)", err.category, err.message, err.code))
    if err.hint then
        print("hint: " .. err.hint)
    end
    -- show error dialog:
    -- lurek.ui.showAlert("Error", err.message)
end
-- @end

-- @snippet lurek.runtime.error_snapshot_diagnostic
-- @prefix lk-sys-error-snapshot
-- @module system
-- @description Use errorSnapshot to create a structured JSON diagnostic that captures the engine state at the point of failure — useful for crash reporters, telemetry, and support tickets.
-- @body
local SNIP_1_rt   = lurek.runtime
local snap = rt.errorSnapshot("unexpected nil in inventory system")
print("snapshot JSON: " .. #snap .. " chars")
-- write to file for support:
-- lurek.filesystem.write("save/crash_report.json", snap)
-- @end

-- ─────────────────────────────────────────────────────────────
-- BATCH TASKS
-- ─────────────────────────────────────────────────────────────

-- @snippet lurek.runtime.runbatch_boot_checks
-- @prefix lk-sys-runbatch
-- @module system
-- @description Use runBatch to run a set of named boot validation tasks and collect per-task pass/fail/time results. getBatchResults summarises the counts for a single-line CI gate or dev-mode startup report.
-- @body
local SNIP_1_rt = lurek.runtime
local results = rt.runBatch({
    check_save_dir = function()
        assert(lurek.filesystem.isDirectory("save"), "save/ directory missing")
    end,
    check_engine_version = function()
        local ver = rt.getVersion()
        local maj, min = ver:match("^(%d+)%.(%d+)")
        assert(tonumber(maj) >= 0 and tonumber(min) >= 6, "engine too old")
    end,
    check_config = function()
        local cfg = rt.getConfig()
        assert(cfg.runtime_mode, "runtime_mode not set in config")
    end,
}, { stopOnError = false })

local passed, failed, skipped = rt.getBatchResults(results)
print(string.format("boot checks: %d passed  %d failed  %d skipped",
    passed, failed, skipped))
if failed > 0 then
    for name, r in pairs(results) do
        if r.status == "failed" then
            rt.log("error", "boot check failed: " .. name .. " — " .. (r.error or ""))
        end
    end
end
-- @end
