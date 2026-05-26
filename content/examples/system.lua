-- content/examples/system.lua
-- Auto-generated from content/examples2/system_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/system.lua

--- System/Runtime Module: version, OS, hardware, args, clipboard, logging, config, batch, power, messages

--@api-stub: lurek.runtime.getVersion
do
    local version = lurek.runtime.getVersion()
    print("engine version = " .. version)
    print("major tag = " .. tostring(version:match("^[^.]+")))
end

--@api-stub: lurek.runtime.getInfo
do
    local info = lurek.runtime.getInfo()
    print("engine = " .. info.engine .. " version = " .. info.version)
    print("os = " .. info.os .. " lua = " .. info.lua_version)
    print("processors = " .. info.processors .. " memory = " .. info.memory)
end

--@api-stub: lurek.runtime.getProcessorCount
do
    local cpus = lurek.runtime.getProcessorCount()
    print("logical processors = " .. cpus)
end

--@api-stub: lurek.runtime.getArgs
do
    local args = lurek.runtime.getArgs()
    print("raw args count = " .. #args)
    print("first arg = " .. tostring(args[1]))
end

--@api-stub: lurek.runtime.parseArgs
do
    local parsed = lurek.runtime.parseArgs({"--debug", "--level=5", "demo.lua", "--", "tail.txt"})
    print("debug flag = " .. tostring(parsed.flags.debug))
    print("level option = " .. tostring(parsed.options.level))
    print("positional count = " .. #parsed.positional)
end

--@api-stub: lurek.runtime.getEnv
do
    local path = lurek.runtime.getEnv("PATH")
    print("PATH set = " .. tostring(path ~= nil))
    print("missing var = " .. tostring(lurek.runtime.getEnv("LUREK_NONEXISTENT_VAR") == nil))
end

--@api-stub: lurek.runtime.getClipboardText
do
    lurek.runtime.setClipboardText("Hello from Lurek2D!")
    local text = lurek.runtime.getClipboardText()
    print("clipboard = " .. text)
    print("clipboard len = " .. #text)
end

--@api-stub: lurek.runtime.openURL
do
    local ok = lurek.runtime.openURL("https://lurek2d.dev")
    print("open https = " .. tostring(ok))
end

--@api-stub: lurek.runtime.log
do
    lurek.runtime.log("info", "Game starting up")
    lurek.runtime.log("debug", "Loading system runtime example block")
    print("logged runtime messages")
end

--@api-stub: lurek.runtime.getConfig
do
    local config = lurek.runtime.getConfig()
    print("runtime mode = " .. config.runtime_mode)
    print("physics tick rate = " .. config.physics_tick_rate)
    print("config revision = " .. config.config_reload_revision)
end

--@api-stub: lurek.runtime.setDebugOverlay
do
    print("debug overlay = " .. tostring(lurek.runtime.getDebugOverlay()))
    lurek.runtime.setDebugOverlay(true)
    print("after enable = " .. tostring(lurek.runtime.getDebugOverlay()))
    lurek.runtime.setDebugOverlay(false)
    print("after disable = " .. tostring(lurek.runtime.getDebugOverlay()))
end

--@api-stub: lurek.runtime.getPowerInfo
do
    local state, percent, seconds = lurek.runtime.getPowerInfo()
    print("power state = " .. state)
    print("battery = " .. tostring(percent))
    print("seconds = " .. tostring(seconds))
end

--@api-stub: lurek.runtime.getPreferredLocales
do
    local locales = lurek.runtime.getPreferredLocales()
    print("locale count = " .. #locales)
    print("first locale = " .. tostring(locales[1]))
end

--@api-stub: lurek.runtime.runBatch
do
    local results = lurek.runtime.runBatch({
        ping = function()
            return true
        end,
        fail = function()
            error("boom")
        end,
    })
    local passed, failed, skipped = lurek.runtime.getBatchResults(results)
    print("passed = " .. passed .. " failed = " .. failed .. " skipped = " .. skipped)
    print("fail status = " .. results.fail.status)
end

--@api-stub: lurek.runtime.errorSnapshot
do
    local snapshot = lurek.runtime.errorSnapshot("Something went wrong in level 3")
    print("snapshot type = " .. type(snapshot))
    print("snapshot length = " .. #snapshot)
    local parsed = lurek.serialize.fromJson(snapshot)
    print("snapshot has message = " .. tostring(parsed.message ~= nil))
end

--@api-stub: lurek.runtime.getMessage
do
    local key = "engine.welcome"
    print("has engine.welcome = " .. tostring(lurek.runtime.hasMessage(key)))
    print("message = " .. tostring(lurek.runtime.getMessage(key)))
end

--@api-stub: lurek.runtime.getLastError
do
    local err = lurek.runtime.getLastError()
    print("last error = " .. tostring(err and err.message))
    print("category = " .. tostring(err and err.category))
end

--- System/Runtime Part 1: coverage for lurek.runtime functions missing from system_00

--@api-stub: lurek.runtime.getOS
do
    print("os = " .. lurek.runtime.getOS())
end

--@api-stub: lurek.runtime.getArch
do
    print("arch = " .. lurek.runtime.getArch())
end

--@api-stub: lurek.runtime.getMemorySize
do
    local memory = lurek.runtime.getMemorySize()
    print("mem_mb = " .. memory)
    print("memory ok = " .. tostring(memory >= 0))
end

--@api-stub: lurek.runtime.setLogLevel
do
    local before = lurek.runtime.getLogLevel()
    lurek.runtime.setLogLevel("info")
    print("before = " .. before)
    print("after = " .. lurek.runtime.getLogLevel())
end

--@api-stub: lurek.runtime.getLogLevel
do
    print("log_level = " .. lurek.runtime.getLogLevel())
end

--@api-stub: lurek.runtime.setClipboardText
do
    lurek.runtime.setClipboardText("lurek_test")
    print("clipboard = " .. tostring(lurek.runtime.getClipboardText()))
end

--@api-stub: lurek.runtime.hasMessage
do
    print("has_msg = " .. tostring(lurek.runtime.hasMessage("engine.welcome")))
end

--@api-stub: lurek.runtime.getMessageCount
do
    print("msg_count = " .. lurek.runtime.getMessageCount())
end

--@api-stub: lurek.runtime.getBatchResults
do
    local results = {
        ok = { status = "passed" },
        bad = { status = "failed" },
        later = { status = "skipped" },
    }
    local passed, failed, skipped = lurek.runtime.getBatchResults(results)
    print("batch_results = " .. passed .. "/" .. failed .. "/" .. skipped)
end

--@api-stub: lurek.runtime.getDebugOverlay
do
    local overlay = lurek.runtime.getDebugOverlay()
    print("overlay enabled = " .. tostring(overlay))
end

--@api-stub: lurek.runtime.reloadConfig
do
    local before = lurek.runtime.getConfig().config_reload_revision
    lurek.runtime.reloadConfig()
    local after = lurek.runtime.getConfig().config_reload_revision
    print("reload requested = true")
    print("revision now = " .. after .. " (before " .. before .. ")")
end

print("content/examples/system.lua")

