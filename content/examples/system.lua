-- content\examples\system.lua
-- Lurek2D lurek.system API Reference

--@api-stub: lurek.system.getOS
do
	local os = lurek.runtime.getOS()
	print("os = " .. tostring(os))
end


--@api-stub: lurek.system.getVersion
do
	local version = lurek.runtime.getVersion()
	print("version = " .. tostring(version))
end


--@api-stub: lurek.system.getProcessorCount
do
	local cpus = lurek.runtime.getProcessorCount()
	print("cpus = " .. tostring(cpus))
end


--@api-stub: lurek.system.getMemorySize
do
	local memory = lurek.runtime.getMemorySize()
	print("memory = " .. tostring(memory))
end


--@api-stub: lurek.system.openURL
do
	local ok = lurek.runtime.openURL("https://lurek2d.dev")
	print("openURL ok = " .. tostring(ok))
end


--@api-stub: lurek.system.getPreferredLocales
do
	local locales = lurek.runtime.getPreferredLocales()
	print("locale count = " .. tostring(#locales))
end


--@api-stub: lurek.system.getPowerInfo
do
	local state, percent, seconds = lurek.runtime.getPowerInfo()
	print("power = " .. tostring(state) .. ", " .. tostring(percent) .. ", " .. tostring(seconds))
end


--@api-stub: lurek.system.getInfo
do
	local info = lurek.runtime.getInfo()
	print("engine = " .. tostring(info.engine) .. " version = " .. tostring(info.version))
end


--@api-stub: lurek.system.getMessage
do
	local key = "engine.welcome"
	print("message = " .. tostring(lurek.runtime.getMessage(key)))
end


--@api-stub: lurek.system.hasMessage
do
	local key = "engine.welcome"
	print("has message = " .. tostring(lurek.runtime.hasMessage(key)))
end


--@api-stub: lurek.system.getMessageCount
do
	local count = lurek.runtime.getMessageCount()
	print("message count = " .. tostring(count))
end


--@api-stub: lurek.system.setClipboardText
do
	lurek.runtime.setClipboardText("lurek system example")
	print("clipboard updated")
end


--@api-stub: lurek.system.getClipboardText
do
	local text = lurek.runtime.getClipboardText()
	print("clipboard = " .. tostring(text))
end


--@api-stub: lurek.system.reloadConfig
do
	lurek.runtime.reloadConfig()
	print("config reload requested")
end


--@api-stub: lurek.system.getConfig
do
	local config = lurek.runtime.getConfig()
	print("runtime_mode = " .. tostring(config.runtime_mode))
end


--@api-stub: lurek.system.setDebugOverlay
do
	lurek.runtime.setDebugOverlay(true)
	print("debug overlay enabled")
end


--@api-stub: lurek.system.getDebugOverlay
do
	local enabled = lurek.runtime.getDebugOverlay()
	print("debug overlay = " .. tostring(enabled))
end


--@api-stub: lurek.system.setLogLevel
do
	lurek.runtime.setLogLevel("info")
	print("log level set")
end


--@api-stub: lurek.system.getLogLevel
do
	local level = lurek.runtime.getLogLevel()
	print("log level = " .. tostring(level))
end


--@api-stub: lurek.system.log
do
	lurek.runtime.log("info", "system example log message")
	print("log emitted")
end


--@api-stub: lurek.system.getLastError
do
	local err = lurek.runtime.getLastError()
	print("last error = " .. tostring(err and err.message))
end


--@api-stub: lurek.system.errorSnapshot
do
	local snapshot = lurek.runtime.errorSnapshot("example error snapshot")
	print("snapshot size = " .. tostring(#snapshot))
end


--@api-stub: lurek.system.getArch
do
	local arch = lurek.runtime.getArch()
	print("arch = " .. tostring(arch))
end


--@api-stub: lurek.system.getEnv
do
	local path = lurek.runtime.getEnv("PATH")
	print("PATH exists = " .. tostring(path ~= nil))
end


--@api-stub: lurek.system.getArgs
do
	local args = lurek.runtime.getArgs()
	print("args count = " .. tostring(#args))
end


--@api-stub: lurek.system.parseArgs
do
	local parsed = lurek.runtime.parseArgs({"--debug", "--level=2", "demo.lua"})
	print("debug flag = " .. tostring(parsed.flags.debug))
end


--@api-stub: lurek.system.runBatch
do
	local batch = { ping = function() return true end }
	print("batch results type = " .. tostring(type(lurek.runtime.runBatch(batch))))
end


--@api-stub: lurek.system.getBatchResults
do
	local results = { ok = { status = "passed" }, bad = { status = "failed" } }
	local passed, failed, skipped = lurek.runtime.getBatchResults(results)
	print("batch = " .. tostring(passed) .. "/" .. tostring(failed) .. "/" .. tostring(skipped))
end

