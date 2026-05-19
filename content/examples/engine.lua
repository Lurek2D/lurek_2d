-- content/examples/engine.lua
-- Auto-generated from content/examples2/engine_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/engine.lua

--- Engine Module: runtime info and profiling


--@api-stub: lurek.engine.getVersion
-- Returns the engine build version string.
do
    local ver = lurek.engine.getVersion()
    print("version = " .. ver)
end

--@api-stub: lurek.engine.platform
-- Returns the current operating system name.
do
    local os_name = lurek.engine.platform()
    print("platform = " .. os_name)
end

--@api-stub: lurek.engine.isDebug
-- Returns whether this is a debug build.
do
    local dbg = lurek.engine.isDebug()
    print("debug build = " .. tostring(dbg))
end

--@api-stub: lurek.engine.fps
-- Returns the current frames-per-second.
do
    local f = lurek.engine.fps()
    print("fps = " .. f)
end

--@api-stub: lurek.engine.frameCount
-- Returns the total number of frames rendered.
do
    local n = lurek.engine.frameCount()
    print("frame count = " .. n)
end

--@api-stub: lurek.engine.uptime
-- Returns total engine uptime in seconds.
do
    local t = lurek.engine.uptime()
    print("uptime = " .. t .. " s")
end

--@api-stub: lurek.engine.getFrameBudget
-- Returns the per-frame time budget in milliseconds.
do
    local budget = lurek.engine.getFrameBudget()
    print("frame budget = " .. budget .. " ms")
end

--@api-stub: lurek.engine.getConfigRevision
-- Returns the configuration reload revision counter.
do
    local rev = lurek.engine.getConfigRevision()
    print("config revision = " .. rev)
end

--@api-stub: lurek.engine.memoryUsage
-- Returns Lua VM memory usage as bytes and kilobytes.
do
    local mem = lurek.engine.memoryUsage()
    print("lua memory = " .. mem.lua_bytes .. " bytes (" .. mem.lua_kb .. " KB)")
end

--@api-stub: lurek.engine.setResourceBudget
-- Sets the resource memory budget for stats reporting.
do
    lurek.engine.setResourceBudget(64 * 1024 * 1024)
    print("resource budget set to 64 MB")
end

--@api-stub: lurek.engine.getResourceStats
-- Returns current resource memory usage and object counts.
do
    local stats = lurek.engine.getResourceStats()
    print("textures: " .. stats.texture_count .. " (" .. stats.texture_bytes .. " bytes)")
    print("fonts: " .. stats.font_count .. " (" .. stats.font_bytes .. " bytes)")
    print("total: " .. stats.total_bytes .. " / " .. stats.budget_bytes .. " budget")
end

--@api-stub: lurek.engine.getFrameProfile
-- Returns the latest frame timing profile split by engine phase.
do
    local prof = lurek.engine.getFrameProfile()
    print("frame total = " .. prof.app_frame_total_ms .. " ms")
    print("  tick = " .. prof.app_tick_ms .. " ms")
    print("  update = " .. prof.app_update_ms .. " ms")
    print("  render = " .. prof.app_render_ms .. " ms")
    print("  draw = " .. prof.draw_ms .. " ms")
end

--@api-stub: lurek.engine.getFrameProfileText
-- Returns the frame profile as a human-readable text line.
do
    local txt = lurek.engine.getFrameProfileText()
    print("profile: " .. txt)
end

print("content/examples/engine.lua")
