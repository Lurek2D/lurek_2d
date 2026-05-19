-- content/examples/system.lua
-- Auto-generated from content/examples2/system_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/system.lua

--- System/Runtime Module: version, OS, hardware, args, clipboard, logging, config, batch, power, messages


--@api-stub: lurek.runtime.getVersion
-- Basic system identification.
do
    local version = lurek.runtime.getVersion()
    print("engine version = " .. version)
end

--@api-stub: lurek.runtime.getInfo
-- Comprehensive engine and host information.
do
    local info = lurek.runtime.getInfo()
    print("engine = " .. info.engine)
    print("version = " .. info.version)
    print("lua version = " .. info.lua_version)
    print("renderer = " .. info.renderer)
    print("os = " .. info.os)
    print("processors = " .. info.processors)
    print("memory = " .. info.memory .. " MiB")
end

--@api-stub: lurek.runtime.getProcessorCount
-- Hardware details.
do
    local cpus = lurek.runtime.getProcessorCount()
    print("logical processors = " .. cpus)
end

--@api-stub: lurek.runtime.getArgs
-- Command-line argument handling.
do
    local args = lurek.runtime.getArgs()
    print("raw args count = " .. #args)
end

--@api-stub: lurek.runtime.parseArgs
-- Parsing with no arguments (uses os.args).
do
    local parsed = lurek.runtime.parseArgs()
    print("default parse flags = " .. type(parsed.flags))
    print("default parse options = " .. type(parsed.options))
    print("default parse positional = " .. #parsed.positional)
end

--@api-stub: lurek.runtime.getEnv
-- Reading environment variables.
do
    local path = lurek.runtime.getEnv("PATH")
    if path then
        print("PATH length = " .. #path)
    else
        print("PATH not set")
    end
    local home = lurek.runtime.getEnv("USERPROFILE")
    if home then
        print("home = " .. home)
    end
    local missing = lurek.runtime.getEnv("LUREK_NONEXISTENT_VAR")
    print("missing var = " .. tostring(missing))
end

--@api-stub: lurek.runtime.getClipboardText
-- Clipboard operations.
do
    lurek.runtime.setClipboardText("Hello from Lurek2D!")
    local text = lurek.runtime.getClipboardText()
    print("clipboard = " .. text)
end

--@api-stub: lurek.runtime.openURL
-- Opening URLs in system browser.
do
    local ok = lurek.runtime.openURL("https://lurek2d.dev")
    print("open https = " .. tostring(ok))
    local mailto = lurek.runtime.openURL("mailto:test@example.com")
    print("open mailto = " .. tostring(mailto))
end

--@api-stub: lurek.runtime.log
-- Logging with different levels.
do
    lurek.runtime.log("info", "Game starting up")
end

--@api-stub: lurek.runtime.getConfig
-- Runtime configuration access and reload.
do
    local config = lurek.runtime.getConfig()
    print("runtime mode = " .. config.runtime_mode)
    print("physics tick rate = " .. config.physics_tick_rate)
end

--@api-stub: lurek.runtime.setDebugOverlay
-- Debug overlay toggle.
do
    print("debug overlay = " .. tostring(lurek.runtime.getDebugOverlay()))
    lurek.runtime.setDebugOverlay(true)
    print("after enable = " .. tostring(lurek.runtime.getDebugOverlay()))
    lurek.runtime.setDebugOverlay(false)
    print("after disable = " .. tostring(lurek.runtime.getDebugOverlay()))
end

--@api-stub: lurek.runtime.getPowerInfo
-- Battery and power state.
do
    local state, percent, seconds = lurek.runtime.getPowerInfo()
    print("power state = " .. state)
    if percent then
        print("battery = " .. percent .. "%")
    else
        print("battery = unknown")
    end
    if seconds then
        local minutes = math.floor(seconds / 60)
        print("remaining = " .. minutes .. " min")
    else
        print("remaining = unknown")
    end
end

--@api-stub: lurek.runtime.getPreferredLocales
-- User locale preferences.
do
    local locales = lurek.runtime.getPreferredLocales()
    print("locale count = " .. #locales)
    for i, loc in ipairs(locales) do
        print("  locale " .. i .. " = " .. loc)
    end
end

--@api-stub: lurek.runtime.runBatch
-- Executing task batches with result collection.
do
    local results = lurek.runtime.runBatch({
        load_config = function()
            local data = { width = 800, height = 600 }
        end,
        validate_assets = function()
            local files = { "player.png", "enemy.png", "tileset.png" }
        end,
        init_audio = function()
            local channels = 16
        end,
    })
    local passed, failed, skipped = lurek.runtime.getBatchResults(results)
    print("passed = " .. passed)
    print("failed = " .. failed)
    print("skipped = " .. skipped)

    -- Stopping batch on first failure.
    local results = lurek.runtime.runBatch({
        step1 = function()
            print("step1 ok")
        end,
        step2 = function()
            error("step2 failed intentionally")
        end,
        step3 = function()
            print("step3 should be skipped")
        end,
    }, { stopOnError = true })
    local passed, failed, skipped = lurek.runtime.getBatchResults(results)
    print("with stop: passed=" .. passed .. " failed=" .. failed .. " skipped=" .. skipped)
end

--@api-stub: lurek.runtime.errorSnapshot
-- Capturing error snapshots for diagnostics.
do
    local snapshot = lurek.runtime.errorSnapshot("Something went wrong in level 3")
    print("snapshot type = " .. type(snapshot))
    print("snapshot length = " .. #snapshot)
    local parsed = lurek.serial.fromJson(snapshot)
    print("snapshot has message = " .. tostring(parsed.message ~= nil))
end

--@api-stub: lurek.runtime.getMessage
-- Engine message catalog access.
do
    local count = lurek.runtime.getMessageCount()
    print("message count = " .. count)
    local hasWelcome = lurek.runtime.hasMessage("engine.welcome")
    print("has engine.welcome = " .. tostring(hasWelcome))
    if hasWelcome then
        local msg = lurek.runtime.getMessage("engine.welcome")
        print("welcome = " .. msg)
    end
    local hasMissing = lurek.runtime.hasMessage("nonexistent.message")
    print("has nonexistent = " .. tostring(hasMissing))
end

--@api-stub: lurek.runtime.getLastError
-- Retrieving the last error.
do
    local err = lurek.runtime.getLastError()
    if err then
        print("last error message = " .. tostring(err.message))
        print("last error code = " .. tostring(err.code))
        print("last error category = " .. tostring(err.category))
        if err.hint then
            print("hint = " .. err.hint)
        end
    else
        print("last error = nil")
    end
end

--- System/Runtime Part 1: coverage for lurek.runtime functions missing from system_00


--@api-stub: lurek.runtime.getOS
-- Runtime platform info: OS, arch, memory, locales, power state. Focus: getOS.
do
    local os_name = lurek.runtime.getOS()
    print("os=" .. os_name)
    local arch = lurek.runtime.getArch()
    print("arch=" .. arch)
    local mem = lurek.runtime.getMemorySize()
    print("mem_mb=" .. mem)
    local locales = lurek.runtime.getPreferredLocales()
    print("locales=" .. #locales)
    local state, pct, secs = lurek.runtime.getPowerInfo()
    print("power_state=" .. state)
end

--@api-stub: lurek.runtime.getArch
-- Runtime platform info: OS, arch, memory, locales, power state. Focus: getArch.
do
    local os_name = lurek.runtime.getOS()
    print("os=" .. os_name)
    local arch = lurek.runtime.getArch()
    print("arch=" .. arch)
    local mem = lurek.runtime.getMemorySize()
    print("mem_mb=" .. mem)
    local locales = lurek.runtime.getPreferredLocales()
    print("locales=" .. #locales)
    local state, pct, secs = lurek.runtime.getPowerInfo()
    print("power_state=" .. state)
end

--@api-stub: lurek.runtime.getMemorySize
-- Runtime platform info: OS, arch, memory, locales, power state. Focus: getMemorySize.
do
    local os_name = lurek.runtime.getOS()
    print("os=" .. os_name)
    local arch = lurek.runtime.getArch()
    print("arch=" .. arch)
    local mem = lurek.runtime.getMemorySize()
    print("mem_mb=" .. mem)
    local locales = lurek.runtime.getPreferredLocales()
    print("locales=" .. #locales)
    local state, pct, secs = lurek.runtime.getPowerInfo()
    print("power_state=" .. state)
end

--@api-stub: lurek.runtime.setLogLevel
-- Runtime log, clipboard, and message queue. Focus: setLogLevel.
do
    lurek.runtime.setLogLevel("info")
    local lvl = lurek.runtime.getLogLevel()
    print("log_level=" .. lvl)

    lurek.runtime.setClipboardText("lurek_test")
    local clip = lurek.runtime.getClipboardText()
    print("clipboard=" .. (clip or "nil"))

    local count = lurek.runtime.getMessageCount()
    print("msg_count=" .. count)
    local has = lurek.runtime.hasMessage("test_msg")
    print("has_msg=" .. tostring(has))
end

--@api-stub: lurek.runtime.getLogLevel
-- Runtime log, clipboard, and message queue. Focus: getLogLevel.
do
    lurek.runtime.setLogLevel("info")
    local lvl = lurek.runtime.getLogLevel()
    print("log_level=" .. lvl)

    lurek.runtime.setClipboardText("lurek_test")
    local clip = lurek.runtime.getClipboardText()
    print("clipboard=" .. (clip or "nil"))

    local count = lurek.runtime.getMessageCount()
    print("msg_count=" .. count)
    local has = lurek.runtime.hasMessage("test_msg")
    print("has_msg=" .. tostring(has))
end

--@api-stub: lurek.runtime.setClipboardText
-- Runtime log, clipboard, and message queue. Focus: setClipboardText.
do
    lurek.runtime.setLogLevel("info")
    local lvl = lurek.runtime.getLogLevel()
    print("log_level=" .. lvl)

    lurek.runtime.setClipboardText("lurek_test")
    local clip = lurek.runtime.getClipboardText()
    print("clipboard=" .. (clip or "nil"))

    local count = lurek.runtime.getMessageCount()
    print("msg_count=" .. count)
    local has = lurek.runtime.hasMessage("test_msg")
    print("has_msg=" .. tostring(has))
end

--@api-stub: lurek.runtime.hasMessage
-- Runtime log, clipboard, and message queue. Focus: hasMessage.
do
    lurek.runtime.setLogLevel("info")
    local lvl = lurek.runtime.getLogLevel()
    print("log_level=" .. lvl)

    lurek.runtime.setClipboardText("lurek_test")
    local clip = lurek.runtime.getClipboardText()
    print("clipboard=" .. (clip or "nil"))

    local count = lurek.runtime.getMessageCount()
    print("msg_count=" .. count)
    local has = lurek.runtime.hasMessage("test_msg")
    print("has_msg=" .. tostring(has))
end

--@api-stub: lurek.runtime.getMessageCount
-- Runtime log, clipboard, and message queue. Focus: getMessageCount.
do
    lurek.runtime.setLogLevel("info")
    local lvl = lurek.runtime.getLogLevel()
    print("log_level=" .. lvl)

    lurek.runtime.setClipboardText("lurek_test")
    local clip = lurek.runtime.getClipboardText()
    print("clipboard=" .. (clip or "nil"))

    local count = lurek.runtime.getMessageCount()
    print("msg_count=" .. count)
    local has = lurek.runtime.hasMessage("test_msg")
    print("has_msg=" .. tostring(has))
end

--@api-stub: lurek.runtime.getBatchResults
-- Runtime diagnostic helpers: error snapshot and batch result aggregation.
do
    lurek.runtime.errorSnapshot("test_snapshot")
    local results = lurek.runtime.getBatchResults({
        { success = true, result = "ok" },
        { success = false, result = "err" }
    })
    print("batch_results=" .. tostring(results ~= nil))
end

--@api-stub: lurek.runtime.getDebugOverlay
-- Runtime debug overlay state, arg parsing, config reload. Focus: getDebugOverlay.
do
    local overlay = lurek.runtime.getDebugOverlay()
    local parsed = lurek.runtime.parseArgs({"--debug", "--level=5", "game.lua"})
    lurek.runtime.reloadConfig()
    print("getDebugOverlay:", overlay, "parseArgs flags:", type(parsed.flags), "reloadConfig ok")
end

--@api-stub: lurek.runtime.reloadConfig
-- Runtime debug overlay state, arg parsing, config reload. Focus: reloadConfig.
do
    local overlay = lurek.runtime.getDebugOverlay()
    local parsed = lurek.runtime.parseArgs({"--debug", "--level=5", "game.lua"})
    lurek.runtime.reloadConfig()
    print("getDebugOverlay:", overlay, "parseArgs flags:", type(parsed.flags), "reloadConfig ok")
end

print("content/examples/system.lua")
