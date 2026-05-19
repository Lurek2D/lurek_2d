--- System/Runtime Part 1: coverage for lurek.runtime functions missing from system_00

--@api-stub: lurek.runtime.getOS
--@api-stub: lurek.runtime.getArch
--@api-stub: lurek.runtime.getMemorySize
-- Runtime platform info: OS, arch, memory, locales, power state.
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
--@api-stub: lurek.runtime.getLogLevel
--@api-stub: lurek.runtime.setClipboardText
--@api-stub: lurek.runtime.hasMessage
--@api-stub: lurek.runtime.getMessageCount
-- Runtime log, clipboard, and message queue.
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

print("system_01.lua")
