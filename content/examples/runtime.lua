-- content/examples/runtime.lua
-- Auto-generated from content/examples2/system_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/runtime.lua

--- System/Runtime Module: version, OS, hardware, args, clipboard, logging, config, batch, power, messages



--@api: lurek.runtime.getVersion
do
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local version = lurek.runtime.getVersion()
    local major = version:match("^[^.]+") or "0"
    local parts = lurek.runtime.parseArgs({ "--version=" .. version })
    local tagged = parts.options.version or "unknown"
    runtime_log("getVersion version=" .. version .. " major=" .. major .. " tagged=" .. tagged)
end

--@api: lurek.runtime.getInfo
do
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local info = lurek.runtime.getInfo()
    local summary = info.engine .. " " .. info.version
    local host = info.os .. "/" .. tostring(info.processors)
    local renderer = info.renderer .. " with " .. info.lua_version
    runtime_log("getInfo summary=" .. summary .. " host=" .. host .. " renderer=" .. renderer .. " memory=" .. tostring(info.memory))
end

--@api: lurek.runtime.getProcessorCount
do
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local cpus = lurek.runtime.getProcessorCount()
    local workers = math.max(cpus - 1, 1)
    local batch = lurek.runtime.runBatch({ ai = function() return workers end })
    local passed = batch.ai.status
    runtime_log("getProcessorCount cpus=" .. tostring(cpus) .. " workers=" .. tostring(workers) .. " batch=" .. passed)
end

--@api: lurek.runtime.getArgs
do
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local args = lurek.runtime.getArgs()
    local first = first_or(args, "none")
    local parsed = lurek.runtime.parseArgs(args)
    local positional = #parsed.positional
    runtime_log("getArgs count=" .. tostring(#args) .. " first=" .. first .. " positional=" .. tostring(positional))
end

--@api: lurek.runtime.parseArgs
do
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local parsed = lurek.runtime.parseArgs({ "--debug", "--level=5", "demo.lua", "--", "tail.txt" })
    local debug_flag = tostring(parsed.flags.debug == true)
    local level = tostring(parsed.options.level)
    local entry = tostring(parsed.positional[1])
    runtime_log("parseArgs debug=" .. debug_flag .. " level=" .. level .. " entry=" .. entry .. " tail=" .. tostring(parsed.positional[2]))
end

--@api: lurek.runtime.getEnv
do
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local path = lurek.runtime.getEnv("PATH")
    local user = lurek.runtime.getEnv("USERNAME") or lurek.runtime.getEnv("USER")
    local missing = lurek.runtime.getEnv("LUREK_NONEXISTENT_VAR")
    local has_path = tostring(path ~= nil and #path > 0)
    runtime_log("getEnv has_path=" .. has_path .. " user=" .. tostring(user) .. " missing=" .. tostring(missing))
end

--@api: lurek.runtime.getClipboardText
do
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    lurek.runtime.setClipboardText("mission:relay")
    local text = lurek.runtime.getClipboardText()
    local length = #text
    local restored = lurek.runtime.parseArgs({ "--clipboard=" .. text })
    runtime_log("getClipboardText text=" .. text .. " length=" .. tostring(length) .. " echoed=" .. tostring(restored.options.clipboard))
end

--@api: lurek.runtime.openURL
do
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local mode = lurek.runtime.getConfig().runtime_mode
    local docs_ok = (mode == "headless" or mode == "cli") and lurek.runtime.openURL("https://lurek2d.dev/docs") or false
    local issue_ok = (mode == "headless" or mode == "cli") and lurek.runtime.openURL("mailto:support@lurek2d.dev") or false
    local https_allowed = tostring(docs_ok)
    local mailto_allowed = tostring(issue_ok)
    runtime_log("openURL docs=" .. https_allowed .. " mailto=" .. mailto_allowed .. " mode=" .. mode)
end

--@api: lurek.runtime.log
do
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local before = lurek.runtime.getLogLevel()
    lurek.runtime.log("info", "Boot sequence ready")
    lurek.runtime.log("warn", "Shader cache cold")
    lurek.runtime.log("error", "Example error line for diagnostics")
    runtime_log("log before=" .. before .. " after=" .. lurek.runtime.getLogLevel())
end

--@api: lurek.runtime.getConfig
do
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local config = lurek.runtime.getConfig()
    local mode = config.runtime_mode
    local physics = tostring(config.physics_tick_rate)
    local revision = tostring(config.config_reload_revision)
    runtime_log("getConfig mode=" .. mode .. " physics=" .. physics .. " log=" .. config.log_level .. " revision=" .. revision)
end

--@api: lurek.runtime.setDebugOverlay
do
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local before = lurek.runtime.getDebugOverlay()
    lurek.runtime.setDebugOverlay(true)
    local enabled = lurek.runtime.getDebugOverlay()
    lurek.runtime.setDebugOverlay(false)
    runtime_log("setDebugOverlay before=" .. tostring(before) .. " enabled=" .. tostring(enabled) .. " final=" .. tostring(lurek.runtime.getDebugOverlay()))
end

--@api: lurek.runtime.getPowerInfo
do
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local state, percent, seconds = lurek.runtime.getPowerInfo()
    local battery = tostring(percent)
    local eta = tostring(seconds)
    local locale = first_or(lurek.runtime.getPreferredLocales(), "en_US")
    runtime_log("getPowerInfo state=" .. state .. " battery=" .. battery .. " eta=" .. eta .. " locale=" .. locale)
end

--@api: lurek.runtime.getPreferredLocales
do
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local locales = lurek.runtime.getPreferredLocales()
    local first = first_or(locales, "en_US")
    local parsed = lurek.runtime.parseArgs({ "--locale=" .. first })
    local locale = tostring(parsed.options.locale)
    runtime_log("getPreferredLocales count=" .. tostring(#locales) .. " first=" .. first .. " parsed=" .. locale)
end

--@api: lurek.runtime.runBatch
do
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local results = lurek.runtime.runBatch({
        compile = function() return true end,
        package = function() return "zip" end,
        deploy = function() error("network timeout") end,
    })
    local passed, failed, skipped = lurek.runtime.getBatchResults(results)
    runtime_log("runBatch passed=" .. tostring(passed) .. " failed=" .. tostring(failed) .. " skipped=" .. tostring(skipped) .. " deploy=" .. results.deploy.status)
end

--@api: lurek.runtime.errorSnapshot
do
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local snapshot = lurek.runtime.errorSnapshot("Renderer warmup failed")
    local has_message = snapshot:find('"message"') ~= nil
    local has_code = snapshot:find('"code"') ~= nil
    local has_category = snapshot:find('"category"') ~= nil
    runtime_log("errorSnapshot len=" .. tostring(#snapshot) .. " message=" .. tostring(has_message) .. " code=" .. tostring(has_code) .. " category=" .. tostring(has_category))
end

--@api: lurek.runtime.getMessage
do
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local boot = lurek.runtime.getMessage("L001")
    local loaded = lurek.runtime.getMessage("L003")
    local missing = lurek.runtime.getMessage("ZZUNKNOWN")
    local known = lurek.runtime.hasMessage("L001")
    runtime_log("getMessage boot=" .. boot .. " loaded=" .. loaded .. " missing=" .. missing .. " known=" .. tostring(known))
end

--@api: lurek.runtime.getLastError
do
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local err = lurek.runtime.getLastError()
    local kind = type(err)
    local message = err and err.message or "none"
    local category = err and err.category or "none"
    runtime_log("getLastError type=" .. kind .. " message=" .. message .. " category=" .. category)
end

--- System/Runtime Part 1: coverage for lurek.runtime functions missing from system_00

--@api: lurek.runtime.getOS
do
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local os = lurek.runtime.getOS()
    local arch = lurek.runtime.getArch()
    local host = os .. "-" .. arch
    local known = lurek.runtime.getInfo().os
    runtime_log("getOS host=" .. host .. " info_os=" .. known)
end

--@api: lurek.runtime.getArch
do
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local arch = lurek.runtime.getArch()
    local cpus = lurek.runtime.getProcessorCount()
    local memory = lurek.runtime.getMemorySize()
    local fingerprint = arch .. ":" .. tostring(cpus) .. ":" .. tostring(memory)
    runtime_log("getArch arch=" .. arch .. " fingerprint=" .. fingerprint)
end

--@api: lurek.runtime.getMemorySize
do
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local memory = lurek.runtime.getMemorySize()
    local info = lurek.runtime.getInfo()
    local enough = tostring(memory > 0)
    local mirrored = tostring(info.memory)
    runtime_log("getMemorySize memory=" .. tostring(memory) .. " enough=" .. enough .. " info_memory=" .. mirrored)
end

--@api: lurek.runtime.setLogLevel
do
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local before = lurek.runtime.getLogLevel()
    lurek.runtime.setLogLevel("warn")
    local during = lurek.runtime.getLogLevel()
    lurek.runtime.setLogLevel(before)
    runtime_log("setLogLevel before=" .. before .. " during=" .. during .. " restored=" .. lurek.runtime.getLogLevel())
end

--@api: lurek.runtime.getLogLevel
do
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local initial = lurek.runtime.getLogLevel()
    lurek.runtime.setLogLevel("info")
    local info_level = lurek.runtime.getLogLevel()
    lurek.runtime.setLogLevel(initial)
    runtime_log("getLogLevel initial=" .. initial .. " info_level=" .. info_level .. " restored=" .. lurek.runtime.getLogLevel())
end

--@api: lurek.runtime.setClipboardText
do
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local payload = "save-slot-02"
    lurek.runtime.setClipboardText(payload)
    local echoed = lurek.runtime.getClipboardText()
    local preview = string.sub(echoed, 1, 12)
    runtime_log("setClipboardText payload=" .. payload .. " echoed=" .. echoed .. " preview=" .. preview)
end

--@api: lurek.runtime.hasMessage
do
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local boot = lurek.runtime.hasMessage("L001")
    local render = lurek.runtime.hasMessage("L010")
    local unknown = lurek.runtime.hasMessage("ZZUNKNOWN")
    local count = lurek.runtime.getMessageCount()
    runtime_log("hasMessage boot=" .. tostring(boot) .. " render=" .. tostring(render) .. " unknown=" .. tostring(unknown) .. " count=" .. tostring(count))
end

--@api: lurek.runtime.getMessageCount
do
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local count = lurek.runtime.getMessageCount()
    local boot = lurek.runtime.getMessage("L001")
    local loaded = lurek.runtime.getMessage("L003")
    local enough = tostring(count >= 30)
    runtime_log("getMessageCount count=" .. tostring(count) .. " enough=" .. enough .. " sample=" .. boot .. " / " .. loaded)
end

--@api: lurek.runtime.getBatchResults
do
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local results = {
        ok = { status = "passed", time = 0.01 },
        bad = { status = "failed", time = 0.02, error = "nope" },
        later = { status = "skipped", time = 0.0 },
    }
    local passed, failed, skipped = lurek.runtime.getBatchResults(results)
    runtime_log("getBatchResults passed=" .. tostring(passed) .. " failed=" .. tostring(failed) .. " skipped=" .. tostring(skipped))
end

--@api: lurek.runtime.getDebugOverlay
do
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    lurek.runtime.setDebugOverlay(false)
    local before = lurek.runtime.getDebugOverlay()
    lurek.runtime.setDebugOverlay(true)
    local after = lurek.runtime.getDebugOverlay()
    runtime_log("getDebugOverlay before=" .. tostring(before) .. " after=" .. tostring(after) .. " mode=" .. lurek.runtime.getConfig().runtime_mode)
end

--@api: lurek.runtime.reloadConfig
do
    local function runtime_log(message)
        lurek.log.info("[runtime] " .. message)
    end
    local function first_or(list, fallback)
        if list ~= nil and list[1] ~= nil then
            return tostring(list[1])
        end
        return fallback
    end

    local before = lurek.runtime.getConfig().config_reload_revision
    lurek.runtime.reloadConfig()
    local after = lurek.runtime.getConfig().config_reload_revision
    local changed = tostring(after ~= before)
    runtime_log("reloadConfig before=" .. tostring(before) .. " after=" .. tostring(after) .. " changed_now=" .. changed)
end
