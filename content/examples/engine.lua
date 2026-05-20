-- content/examples/engine.lua
-- Auto-generated from content/examples2/engine_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/engine.lua

--- Engine Module: runtime info and profiling


--@api-stub: lurek.engine.getVersion
do
    local ver = lurek.engine.getVersion()
    print("version = " .. ver)
end

--@api-stub: lurek.engine.platform
do
    local os_name = lurek.engine.platform()
    print("platform = " .. os_name)
end

--@api-stub: lurek.engine.isDebug
do
    local dbg = lurek.engine.isDebug()
    print("debug build = " .. tostring(dbg))
end

--@api-stub: lurek.engine.fps
do
    local f = lurek.engine.fps()
    print("fps = " .. f)
end

--@api-stub: lurek.engine.frameCount
do
    local n = lurek.engine.frameCount()
    print("frame count = " .. n)
end

--@api-stub: lurek.engine.uptime
do
    local t = lurek.engine.uptime()
    print("uptime = " .. t .. " s")
end

--@api-stub: lurek.engine.getFrameBudget
do
    local budget = lurek.engine.getFrameBudget()
    print("frame budget = " .. budget .. " ms")
end

--@api-stub: lurek.engine.getConfigRevision
do
    local rev = lurek.engine.getConfigRevision()
    print("config revision = " .. rev)
end

--@api-stub: lurek.engine.memoryUsage
do
    local mem = lurek.engine.memoryUsage()
    print("lua memory = " .. mem.lua_bytes .. " bytes (" .. mem.lua_kb .. " KB)")
end

--@api-stub: lurek.engine.setResourceBudget
do
    lurek.engine.setResourceBudget(64 * 1024 * 1024)
    print("resource budget set to 64 MB")
end

--@api-stub: lurek.engine.getResourceStats
do
    local stats = lurek.engine.getResourceStats()
    print("total: " .. stats.total_bytes .. " / " .. stats.budget_bytes .. " budget")
end

--@api-stub: lurek.engine.getFrameProfile
do
    local prof = lurek.engine.getFrameProfile()
    print("frame total = " .. prof.app_frame_total_ms .. " ms")
end

--@api-stub: lurek.engine.getFrameProfileText
do
    local txt = lurek.engine.getFrameProfileText()
    print("profile: " .. txt)
end

print("content/examples/engine.lua")
