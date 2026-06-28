-- content/examples/runtime.lua
-- Auto-generated from content/examples2/system_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/runtime.lua

--- System/Runtime Module: version, OS, hardware, args, clipboard, logging, config, batch, power, messages



--@api: lurek.runtime.getVersion
do

    local version = lurek.runtime.getVersion()
    local major = version:match("^[^.]+") or "0"
    local parts = lurek.runtime.parseArgs({ "--version=" .. version })
    local tagged = parts.options.version or "unknown"
    lurek.log.info("getVersion version=" .. version .. " major=" .. major .. " tagged=" .. tagged)
end

--@api: lurek.runtime.getInfo
do

    local info = lurek.runtime.getInfo()
    local summary = info.engine .. " " .. info.version
    local host = info.os .. "/" .. tostring(info.processors)
    local renderer = info.renderer .. " with " .. info.lua_version
    lurek.log.info("getInfo summary=" .. summary .. " host=" .. host .. " renderer=" .. renderer .. " memory=" .. tostring(info.memory))
end

--@api: lurek.runtime.getProcessorCount
do

    local cpus = lurek.runtime.getProcessorCount()
    local workers = math.max(cpus - 1, 1)
    local batch = lurek.runtime.runBatch({ ai = function() return workers end })
    local passed = batch.ai.status
    lurek.log.info("getProcessorCount cpus=" .. tostring(cpus) .. " workers=" .. tostring(workers) .. " batch=" .. passed)
end

--@api: lurek.runtime.getArgs
do

    local args = lurek.runtime.getArgs()
    local first = args[1] ~= nil and tostring(args[1]) or "none"
    local parsed = lurek.runtime.parseArgs(args)
    local positional = #parsed.positional
    lurek.log.info("getArgs count=" .. tostring(#args) .. " first=" .. first .. " positional=" .. tostring(positional))
end

--@api: lurek.runtime.parseArgs
do

    local parsed = lurek.runtime.parseArgs({ "--debug", "--level=5", "demo.lua", "--", "tail.txt" })
    local debug_flag = tostring(parsed.flags.debug == true)
    local level = tostring(parsed.options.level)
    local entry = tostring(parsed.positional[1])
    lurek.log.info("parseArgs debug=" .. debug_flag .. " level=" .. level .. " entry=" .. entry .. " tail=" .. tostring(parsed.positional[2]))
end

--@api: lurek.runtime.getEnv
do

    local path = lurek.runtime.getEnv("PATH")
    local user = lurek.runtime.getEnv("USERNAME") or lurek.runtime.getEnv("USER")
    local missing = lurek.runtime.getEnv("LUREK_NONEXISTENT_VAR")
    local has_path = tostring(path ~= nil and #path > 0)
    lurek.log.info("getEnv has_path=" .. has_path .. " user=" .. tostring(user) .. " missing=" .. tostring(missing))
end

--@api: lurek.runtime.getClipboardText
do

    lurek.runtime.setClipboardText("mission:relay")
    local text = lurek.runtime.getClipboardText()
    local length = #text
    local restored = lurek.runtime.parseArgs({ "--clipboard=" .. text })
    lurek.log.info("getClipboardText text=" .. text .. " length=" .. tostring(length) .. " echoed=" .. tostring(restored.options.clipboard))
end

--@api: lurek.runtime.openURL
do

    local mode = lurek.runtime.getConfig().runtime_mode
    local docs_ok = (mode == "headless" or mode == "cli") and lurek.runtime.openURL("https://lurek2d.dev/docs") or false
    local issue_ok = (mode == "headless" or mode == "cli") and lurek.runtime.openURL("mailto:support@lurek2d.dev") or false
    local https_allowed = tostring(docs_ok)
    local mailto_allowed = tostring(issue_ok)
    lurek.log.info("openURL docs=" .. https_allowed .. " mailto=" .. mailto_allowed .. " mode=" .. mode)
end

--@api: lurek.runtime.log
do

    local before = lurek.runtime.getLogLevel()
    lurek.runtime.log("info", "Boot sequence ready")
    lurek.runtime.log("warn", "Shader cache cold")
    lurek.runtime.log("error", "Example error line for diagnostics")
    lurek.log.info("log before=" .. before .. " after=" .. lurek.runtime.getLogLevel())
end

--@api: lurek.runtime.getConfig
do

    local config = lurek.runtime.getConfig()
    local mode = config.runtime_mode
    local physics = tostring(config.physics_tick_rate)
    local revision = tostring(config.config_reload_revision)
    lurek.log.info("getConfig mode=" .. mode .. " physics=" .. physics .. " log=" .. config.log_level .. " revision=" .. revision)
end

--@api: lurek.runtime.setDebugOverlay
do

    local before = lurek.runtime.getDebugOverlay()
    lurek.runtime.setDebugOverlay(true)
    local enabled = lurek.runtime.getDebugOverlay()
    lurek.runtime.setDebugOverlay(false)
    lurek.log.info("setDebugOverlay before=" .. tostring(before) .. " enabled=" .. tostring(enabled) .. " final=" .. tostring(lurek.runtime.getDebugOverlay()))
end

--@api: lurek.runtime.getPowerInfo
do

    local state, percent, seconds = lurek.runtime.getPowerInfo()
    local battery = tostring(percent)
    local eta = tostring(seconds)
    local locales = lurek.runtime.getPreferredLocales()
    local locale = locales[1] ~= nil and tostring(locales[1]) or "en_US"
    lurek.log.info("getPowerInfo state=" .. state .. " battery=" .. battery .. " eta=" .. eta .. " locale=" .. locale)
end

--@api: lurek.runtime.getPreferredLocales
do

    local locales = lurek.runtime.getPreferredLocales()
    local first = locales[1] ~= nil and tostring(locales[1]) or "en_US"
    local parsed = lurek.runtime.parseArgs({ "--locale=" .. first })
    local locale = tostring(parsed.options.locale)
    lurek.log.info("getPreferredLocales count=" .. tostring(#locales) .. " first=" .. first .. " parsed=" .. locale)
end

--@api: lurek.runtime.runBatch
do

    local results = lurek.runtime.runBatch({
        compile = function() return true end,
        package = function() return "zip" end,
        deploy = function() error("network timeout") end,
    })
    local passed, failed, skipped = lurek.runtime.getBatchResults(results)
    lurek.log.info("runBatch passed=" .. tostring(passed) .. " failed=" .. tostring(failed) .. " skipped=" .. tostring(skipped) .. " deploy=" .. results.deploy.status)
end

--@api: lurek.runtime.errorSnapshot
do

    local snapshot = lurek.runtime.errorSnapshot("Renderer warmup failed")
    local has_message = snapshot:find('"message"') ~= nil
    local has_code = snapshot:find('"code"') ~= nil
    local has_category = snapshot:find('"category"') ~= nil
    lurek.log.info("errorSnapshot len=" .. tostring(#snapshot) .. " message=" .. tostring(has_message) .. " code=" .. tostring(has_code) .. " category=" .. tostring(has_category))
end

--@api: lurek.runtime.getMessage
do

    local boot = lurek.runtime.getMessage("L001")
    local loaded = lurek.runtime.getMessage("L003")
    local missing = lurek.runtime.getMessage("ZZUNKNOWN")
    local known = lurek.runtime.hasMessage("L001")
    lurek.log.info("getMessage boot=" .. boot .. " loaded=" .. loaded .. " missing=" .. missing .. " known=" .. tostring(known))
end

--@api: lurek.runtime.getLastError
do

    local err = lurek.runtime.getLastError()
    local kind = type(err)
    local message = err and err.message or "none"
    local category = err and err.category or "none"
    lurek.log.info("getLastError type=" .. kind .. " message=" .. message .. " category=" .. category)
end

--- System/Runtime Part 1: coverage for lurek.runtime functions missing from system_00

--@api: lurek.runtime.getOS
do

    local os = lurek.runtime.getOS()
    local arch = lurek.runtime.getArch()
    local host = os .. "-" .. arch
    local known = lurek.runtime.getInfo().os
    lurek.log.info("getOS host=" .. host .. " info_os=" .. known)
end

--@api: lurek.runtime.getArch
do

    local arch = lurek.runtime.getArch()
    local cpus = lurek.runtime.getProcessorCount()
    local memory = lurek.runtime.getMemorySize()
    local fingerprint = arch .. ":" .. tostring(cpus) .. ":" .. tostring(memory)
    lurek.log.info("getArch arch=" .. arch .. " fingerprint=" .. fingerprint)
end

--@api: lurek.runtime.getMemorySize
do

    local memory = lurek.runtime.getMemorySize()
    local info = lurek.runtime.getInfo()
    local enough = tostring(memory > 0)
    local mirrored = tostring(info.memory)
    lurek.log.info("getMemorySize memory=" .. tostring(memory) .. " enough=" .. enough .. " info_memory=" .. mirrored)
end

--@api: lurek.runtime.setLogLevel
do

    local before = lurek.runtime.getLogLevel()
    lurek.runtime.setLogLevel("warn")
    local during = lurek.runtime.getLogLevel()
    lurek.runtime.setLogLevel(before)
    lurek.log.info("setLogLevel before=" .. before .. " during=" .. during .. " restored=" .. lurek.runtime.getLogLevel())
end

--@api: lurek.runtime.getLogLevel
do

    local initial = lurek.runtime.getLogLevel()
    lurek.runtime.setLogLevel("info")
    local info_level = lurek.runtime.getLogLevel()
    lurek.runtime.setLogLevel(initial)
    lurek.log.info("getLogLevel initial=" .. initial .. " info_level=" .. info_level .. " restored=" .. lurek.runtime.getLogLevel())
end

--@api: lurek.runtime.setClipboardText
do

    local payload = "save-slot-02"
    lurek.runtime.setClipboardText(payload)
    local echoed = lurek.runtime.getClipboardText()
    local preview = string.sub(echoed, 1, 12)
    lurek.log.info("setClipboardText payload=" .. payload .. " echoed=" .. echoed .. " preview=" .. preview)
end

--@api: lurek.runtime.hasMessage
do

    local boot = lurek.runtime.hasMessage("L001")
    local render = lurek.runtime.hasMessage("L010")
    local unknown = lurek.runtime.hasMessage("ZZUNKNOWN")
    local count = lurek.runtime.getMessageCount()
    lurek.log.info("hasMessage boot=" .. tostring(boot) .. " render=" .. tostring(render) .. " unknown=" .. tostring(unknown) .. " count=" .. tostring(count))
end

--@api: lurek.runtime.getMessageCount
do

    local count = lurek.runtime.getMessageCount()
    local boot = lurek.runtime.getMessage("L001")
    local loaded = lurek.runtime.getMessage("L003")
    local enough = tostring(count >= 30)
    lurek.log.info("getMessageCount count=" .. tostring(count) .. " enough=" .. enough .. " sample=" .. boot .. " / " .. loaded)
end

--@api: lurek.runtime.getBatchResults
do

    local results = {
        ok = { status = "passed", time = 0.01 },
        bad = { status = "failed", time = 0.02, error = "nope" },
        later = { status = "skipped", time = 0.0 },
    }
    local passed, failed, skipped = lurek.runtime.getBatchResults(results)
    lurek.log.info("getBatchResults passed=" .. tostring(passed) .. " failed=" .. tostring(failed) .. " skipped=" .. tostring(skipped))
end

--@api: lurek.runtime.getDebugOverlay
do

    lurek.runtime.setDebugOverlay(false)
    local before = lurek.runtime.getDebugOverlay()
    lurek.runtime.setDebugOverlay(true)
    local after = lurek.runtime.getDebugOverlay()
    lurek.log.info("getDebugOverlay before=" .. tostring(before) .. " after=" .. tostring(after) .. " mode=" .. lurek.runtime.getConfig().runtime_mode)
end

--@api: lurek.runtime.reloadConfig
do

    local before = lurek.runtime.getConfig().config_reload_revision
    lurek.runtime.reloadConfig()
    local after = lurek.runtime.getConfig().config_reload_revision
    local changed = tostring(after ~= before)
    lurek.log.info("reloadConfig before=" .. tostring(before) .. " after=" .. tostring(after) .. " changed_now=" .. changed)
end
