-- content/examples/engine.lua
-- Auto-generated from content/examples2/engine_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/engine.lua

--- Engine Module: runtime info and profiling

--@api: lurek.engine.getVersion
do
    local ver = lurek.engine.getVersion()
    print("version = " .. ver)
    print("version type = " .. type(ver))
end

--@api: lurek.engine.platform
do
    local os_name = lurek.engine.platform()
    print("platform = " .. os_name)
    print("platform type = " .. type(os_name))
end

--@api: lurek.engine.isDebug
do
    local dbg = lurek.engine.isDebug()
    print("debug build = " .. tostring(dbg))
    print("debug flag type = " .. type(dbg))
end

--@api: lurek.engine.fps
do
    local f = lurek.engine.fps()
    print("fps = " .. f)
    print("fps rounded = " .. string.format("%.2f", f))
end

--@api: lurek.engine.frameCount
do
    local n = lurek.engine.frameCount()
    print("frame count = " .. n)
    print("frame count type = " .. type(n))
end

--@api: lurek.engine.uptime
do
    local t = lurek.engine.uptime()
    print("uptime = " .. t .. " s")
    print("uptime rounded = " .. string.format("%.3f", t))
end

--@api: lurek.engine.getFrameBudget
do
    local budget = lurek.engine.getFrameBudget()
    print("frame budget = " .. budget .. " ms")
    print("target fps = " .. string.format("%.2f", 1000 / budget))
end

--@api: lurek.engine.getConfigRevision
do
    local rev = lurek.engine.getConfigRevision()
    print("config revision = " .. rev)
    print("revision type = " .. type(rev))
end

--@api: lurek.engine.memoryUsage
do
    local mem = lurek.engine.memoryUsage()
    print("lua memory = " .. mem.lua_bytes .. " bytes (" .. mem.lua_kb .. " KB)")
    print("memory table type = " .. type(mem))
end

--@api: lurek.engine.setResourceBudget
do
    lurek.engine.setResourceBudget(64 * 1024 * 1024)
    print("resource budget set to 64 MB")
    print("budget bytes = " .. lurek.engine.getResourceStats().budget_bytes)
end

--@api: lurek.engine.getResourceStats
do
    local stats = lurek.engine.getResourceStats()
    print("total: " .. stats.total_bytes .. " / " .. stats.budget_bytes .. " budget")
    print("textures = " .. stats.texture_count .. " shaders = " .. stats.shader_count)
end

--@api: lurek.engine.getFrameProfile
do
    local prof = lurek.engine.getFrameProfile()
    print("frame total = " .. prof.app_frame_total_ms .. " ms")
    print("draw = " .. prof.draw_ms .. " ms, callbacks = " .. prof.callback_total_ms .. " ms")
end

--@api: lurek.engine.getFrameProfileText
do
    local txt = lurek.engine.getFrameProfileText()
    print("profile: " .. txt)
    print("profile text type = " .. type(txt))
end
