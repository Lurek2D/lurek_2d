-- content\examples\system.lua
-- Lurek2D lurek.system API Reference

--@api: lurek.system.getOS
do
	local os = lurek.runtime.getOS()
	print("os = " .. tostring(os))
    print("lua type = " .. type(os))
end


--@api: lurek.system.getVersion
do
	local version = lurek.runtime.getVersion()
	print("version = " .. tostring(version))
    print("lua type = " .. type(version))
end


--@api: lurek.system.getProcessorCount
do
	local cpus = lurek.runtime.getProcessorCount()
	print("cpus = " .. tostring(cpus))
    print("lua type = " .. type(cpus))
end


--@api: lurek.system.getMemorySize
do
	local memory = lurek.runtime.getMemorySize()
	print("memory = " .. tostring(memory))
    print("lua type = " .. type(memory))
end


--@api: lurek.system.openURL
do
	local ok = lurek.runtime.openURL("https://lurek2d.dev")
	print("openURL ok = " .. tostring(ok))
    print("lua type = " .. type(ok))
end


--@api: lurek.system.getPreferredLocales
do
	local locales = lurek.runtime.getPreferredLocales()
	print("locale count = " .. tostring(#locales))
    print("lua type = " .. type(locales))
end


--@api: lurek.system.getPowerInfo
do
	local state, percent, seconds = lurek.runtime.getPowerInfo()
	print("power = " .. tostring(state) .. ", " .. tostring(percent) .. ", " .. tostring(seconds))
    print("value types = " .. type(state) .. "," .. type(percent) .. "," .. type(seconds))
end


--@api: lurek.system.getInfo
do
	local info = lurek.runtime.getInfo()
	print("engine = " .. tostring(info.engine) .. " version = " .. tostring(info.version))
    print("lua type = " .. type(info))
end


--@api: lurek.system.getMessage
do
	local key = "engine.welcome"
	print("message = " .. tostring(lurek.runtime.getMessage(key)))
    print("lua type = " .. type(tostring(lurek.runtime.getMessage(key))))
end


--@api: lurek.system.hasMessage
do
	local key = "engine.welcome"
	print("has message = " .. tostring(lurek.runtime.hasMessage(key)))
    print("lua type = " .. type(tostring(lurek.runtime.hasMessage(key))))
end


--@api: lurek.system.getMessageCount
do
	local count = lurek.runtime.getMessageCount()
	print("message count = " .. tostring(count))
    print("lua type = " .. type(count))
end


--@api: lurek.system.setClipboardText
do
	lurek.runtime.setClipboardText("lurek system example")
	print("clipboard updated")
    print("clipboard = " .. tostring(lurek.runtime.getClipboardText()))
end


--@api: lurek.system.getClipboardText
do
	local text = lurek.runtime.getClipboardText()
	print("clipboard = " .. tostring(text))
    print("lua type = " .. type(text))
end


--@api: lurek.system.reloadConfig
do
	lurek.runtime.reloadConfig()
	print("config reload requested")
    print("config type = " .. type(lurek.runtime.getConfig()))
end


--@api: lurek.system.getConfig
do
	local config = lurek.runtime.getConfig()
	print("runtime_mode = " .. tostring(config.runtime_mode))
    print("lua type = " .. type(config))
end


--@api: lurek.system.setDebugOverlay
do
	lurek.runtime.setDebugOverlay(true)
	print("debug overlay enabled")
    print("debug overlay = " .. tostring(lurek.runtime.getDebugOverlay()))
end


--@api: lurek.system.getDebugOverlay
do
	local enabled = lurek.runtime.getDebugOverlay()
	print("debug overlay = " .. tostring(enabled))
    print("lua type = " .. type(enabled))
end


--@api: lurek.system.setLogLevel
do
	lurek.runtime.setLogLevel("info")
	print("log level set")
    print("log level = " .. tostring(lurek.runtime.getLogLevel()))
end


--@api: lurek.system.getLogLevel
do
	local level = lurek.runtime.getLogLevel()
	print("log level = " .. tostring(level))
    print("lua type = " .. type(level))
end


--@api: lurek.system.log
do
	lurek.runtime.log("info", "system example log message")
	print("log emitted")
    print("log level = " .. tostring(lurek.runtime.getLogLevel()))
end


--@api: lurek.system.getLastError
do
	local err = lurek.runtime.getLastError()
	print("last error = " .. tostring(err and err.message))
    print("lua type = " .. type(err))
end


--@api: lurek.system.errorSnapshot
do
	local snapshot = lurek.runtime.errorSnapshot("example error snapshot")
	print("snapshot size = " .. tostring(#snapshot))
    print("lua type = " .. type(snapshot))
end


--@api: lurek.system.getArch
do
	local arch = lurek.runtime.getArch()
	print("arch = " .. tostring(arch))
    print("lua type = " .. type(arch))
end


--@api: lurek.system.getEnv
do
	local path = lurek.runtime.getEnv("PATH")
	print("PATH exists = " .. tostring(path ~= nil))
    print("lua type = " .. type(path))
end


--@api: lurek.system.getArgs
do
	local args = lurek.runtime.getArgs()
	print("args count = " .. tostring(#args))
    print("lua type = " .. type(args))
end


--@api: lurek.system.parseArgs
do
	local parsed = lurek.runtime.parseArgs({"--debug", "--level=2", "demo.lua"})
	print("debug flag = " .. tostring(parsed.flags.debug))
    print("lua type = " .. type(parsed))
end


--@api: lurek.system.runBatch
do
	local batch = { ping = function() return true end }
	print("batch results type = " .. tostring(type(lurek.runtime.runBatch(batch))))
    print("lua type = " .. type(tostring(type(lurek.runtime.runBatch(batch)))))
end


--@api: lurek.system.getBatchResults
do
	local results = { ok = { status = "passed" }, bad = { status = "failed" } }
	local passed, failed, skipped = lurek.runtime.getBatchResults(results)
	print("batch = " .. tostring(passed) .. "/" .. tostring(failed) .. "/" .. tostring(skipped))
end

