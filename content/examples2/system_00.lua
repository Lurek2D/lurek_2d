--- System/Runtime Module: version, OS, hardware, args, clipboard, logging, config, batch, power, messages

--@api-stub: lurek.runtime.getVersion / getOS / getArch
-- Basic system identification.
do
    local version = lurek.runtime.getVersion()
    print("engine version = " .. version)
    local os_name = lurek.runtime.getOS()
    print("operating system = " .. os_name)
    local arch = lurek.runtime.getArch()
    print("architecture = " .. arch)
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

--@api-stub: lurek.runtime.getProcessorCount / getMemorySize
-- Hardware details.
do
    local cpus = lurek.runtime.getProcessorCount()
    print("logical processors = " .. cpus)
    local ram = lurek.runtime.getMemorySize()
    print("total RAM = " .. ram .. " MB")
end

--@api-stub: lurek.runtime.getArgs / parseArgs
-- Command-line argument handling.
do
    local args = lurek.runtime.getArgs()
    print("raw args count = " .. #args)
    for i, arg in ipairs(args) do
        print("  arg[" .. i .. "] = " .. arg)
    end
    local parsed = lurek.runtime.parseArgs({ "--verbose", "--output=result.txt", "-debug", "input.lua", "extra" })
    print("flags:")
    for k, v in pairs(parsed.flags) do
        print("  " .. k .. " = " .. tostring(v))
    end
    print("options:")
    for k, v in pairs(parsed.options) do
        print("  " .. k .. " = " .. v)
    end
    print("positional:")
    for i, v in ipairs(parsed.positional) do
        print("  " .. i .. ": " .. v)
    end
end

--@api-stub: lurek.runtime.parseArgs with defaults
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

--@api-stub: lurek.runtime.getClipboardText / setClipboardText
-- Clipboard operations.
do
    lurek.runtime.setClipboardText("Hello from Lurek2D!")
    local text = lurek.runtime.getClipboardText()
    print("clipboard = " .. text)
    lurek.runtime.setClipboardText("player_save_data = {hp=100, gold=500}")
    local data = lurek.runtime.getClipboardText()
    print("clipboard data = " .. data)
end

--@api-stub: lurek.runtime.openURL
-- Opening URLs in system browser.
do
    local ok = lurek.runtime.openURL("https://lurek2d.dev")
    print("open https = " .. tostring(ok))
    local mailto = lurek.runtime.openURL("mailto:test@example.com")
    print("open mailto = " .. tostring(mailto))
end

--@api-stub: lurek.runtime.log / setLogLevel / getLogLevel
-- Logging with different levels.
do
    print("current log level = " .. lurek.runtime.getLogLevel())
    lurek.runtime.log("info", "Game starting up")
    lurek.runtime.log("debug", "Loading assets phase 1")
    lurek.runtime.log("warn", "Texture not found, using fallback")
    lurek.runtime.log("error", "Failed to connect to server")
    lurek.runtime.setLogLevel("debug")
    print("new log level = " .. lurek.runtime.getLogLevel())
    lurek.runtime.log("debug", "This message is now visible")
    lurek.runtime.setLogLevel("info")
    print("restored log level = " .. lurek.runtime.getLogLevel())
end

--@api-stub: lurek.runtime.getConfig / reloadConfig
-- Runtime configuration access and reload.
do
    local config = lurek.runtime.getConfig()
    print("runtime mode = " .. config.runtime_mode)
    print("physics tick rate = " .. config.physics_tick_rate)
    print("fixed update tick = " .. config.fixed_update_tick_rate)
    print("frame budget warn = " .. config.frame_budget_warn_ms .. " ms")
    print("lua callback timeout = " .. config.lua_callback_timeout_ms .. " ms")
    print("vsync = " .. tostring(config.vsync))
    print("log level = " .. config.log_level)
    print("config revision = " .. config.config_reload_revision)
    lurek.runtime.reloadConfig()
    local updated = lurek.runtime.getConfig()
    print("after reload revision = " .. updated.config_reload_revision)
end

--@api-stub: lurek.runtime.setDebugOverlay / getDebugOverlay
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

--@api-stub: lurek.runtime.runBatch / getBatchResults
-- Executing task batches with result collection.
do
    local results = lurek.runtime.runBatch({
        load_config = function()
            local data = { width = 800, height = 600 }
            assert(data.width > 0)
        end,
        validate_assets = function()
            local files = { "player.png", "enemy.png", "tileset.png" }
            assert(#files == 3)
        end,
        init_audio = function()
            local channels = 16
            assert(channels >= 8)
        end,
    })
    local passed, failed, skipped = lurek.runtime.getBatchResults(results)
    print("passed = " .. passed)
    print("failed = " .. failed)
    print("skipped = " .. skipped)
end

--@api-stub: lurek.runtime.runBatch with stopOnError
-- Stopping batch on first failure.
do
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

--@api-stub: lurek.runtime.getMessage / getMessageCount / hasMessage
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
    print("last error message = " .. err.message)
    print("last error code = " .. err.code)
    print("last error category = " .. err.category)
    if err.hint then
        print("hint = " .. err.hint)
    end
end

print("system_00.lua")
