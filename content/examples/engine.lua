-- content/examples/engine.lua
-- Auto-generated from content/examples2/engine_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/engine.lua

--- Engine Module: runtime info and profiling

--@api: lurek.engine.getVersion
do
    local ver = lurek.engine.getVersion()
    local platform = lurek.engine.platform()
    local debug_build = lurek.engine.isDebug()
    local label = "Lurek " .. ver .. " on " .. platform
    lurek.log.info("engine build: " .. label)
    lurek.log.info("debug assertions enabled = " .. tostring(debug_build))
end

--@api: lurek.engine.platform
do
    local os_name = lurek.engine.platform()
    local version = lurek.engine.getVersion()
    local debug_build = lurek.engine.isDebug()
    local runtime_tag = os_name .. " / " .. version
    lurek.log.info("runtime target = " .. runtime_tag)
    lurek.log.info("debug build = " .. tostring(debug_build))
end

--@api: lurek.engine.isDebug
do
    local dbg = lurek.engine.isDebug()
    local version = lurek.engine.getVersion()
    local platform = lurek.engine.platform()
    local build_type = dbg and "debug" or "release"
    lurek.log.info("build channel = " .. build_type)
    lurek.log.info("binary " .. version .. " running on " .. platform)
end

--@api: lurek.engine.fps
do
    local f = lurek.engine.fps()
    local budget_ms = lurek.engine.getFrameBudget()
    local target_fps = 1000 / budget_ms
    local frame_time_ms = f > 0 and (1000 / f) or 0
    lurek.log.info("fps = " .. string.format("%.2f", f) .. " target=" .. string.format("%.2f", target_fps))
    lurek.log.info("estimated frame time = " .. string.format("%.2f", frame_time_ms) .. " ms")
end

--@api: lurek.engine.frameCount
do
    local n = lurek.engine.frameCount()
    local uptime = lurek.engine.uptime()
    local avg_fps = uptime > 0 and (n / uptime) or 0
    local sample_window = n > 120 and "warmed-up" or "startup"
    lurek.log.info("frame count = " .. n .. " (" .. sample_window .. ")")
    lurek.log.info("average fps since boot = " .. string.format("%.2f", avg_fps))
end

--@api: lurek.engine.uptime
do
    local t = lurek.engine.uptime()
    local frames = lurek.engine.frameCount()
    local per_frame = frames > 0 and (t / frames) or 0
    local started_recently = t < 5
    lurek.log.info("uptime = " .. string.format("%.3f", t) .. " s")
    lurek.log.info("seconds per frame = " .. string.format("%.5f", per_frame) .. ", startup=" .. tostring(started_recently))
end

--@api: lurek.engine.getFrameBudget
do
    local budget = lurek.engine.getFrameBudget()
    local target_fps = 1000 / budget
    local current_fps = lurek.engine.fps()
    local slack_ms = budget - (current_fps > 0 and (1000 / current_fps) or 0)
    lurek.log.info("frame budget = " .. string.format("%.2f", budget) .. " ms")
    lurek.log.info("target fps = " .. string.format("%.2f", target_fps) .. ", slack = " .. string.format("%.2f", slack_ms) .. " ms")
end

--@api: lurek.engine.getConfigRevision
do
    local rev = lurek.engine.getConfigRevision()
    local version = lurek.engine.getVersion()
    local platform = lurek.engine.platform()
    local config_tag = version .. "#cfg" .. rev
    lurek.log.info("config revision = " .. rev)
    lurek.log.info("diagnostic tag = " .. config_tag .. "@" .. platform)
end

--@api: lurek.engine.memoryUsage
do
    local mem = lurek.engine.memoryUsage()
    local lua_mb = mem.lua_bytes / (1024 * 1024)
    local frame = lurek.engine.frameCount()
    local budget_note = mem.lua_kb > 1024 and "heavy scene" or "light scene"
    lurek.log.info("lua memory = " .. string.format("%.2f", lua_mb) .. " MB at frame " .. frame)
    lurek.log.info("memory note = " .. budget_note)
end

--@api: lurek.engine.setResourceBudget
do
    local previous = lurek.engine.getResourceStats().budget_bytes
    local new_budget = 64 * 1024 * 1024
    lurek.engine.setResourceBudget(new_budget)
    local updated = lurek.engine.getResourceStats()
    lurek.engine.setResourceBudget(previous)
    lurek.log.info("resource budget changed to " .. updated.budget_bytes .. " bytes")
    lurek.log.info("restored previous budget = " .. previous)
end

--@api: lurek.engine.getResourceStats
do
    local stats = lurek.engine.getResourceStats()
    local usage_pct = stats.budget_bytes > 0 and (stats.total_bytes / stats.budget_bytes) * 100 or 0
    local gpu_objects = stats.texture_count + stats.shader_count + stats.font_count + stats.canvas_count
    local texture_bytes = string.format("%.2f", stats.texture_bytes / 1024)
    lurek.log.info("resource usage = " .. string.format("%.1f", usage_pct) .. "% of budget")
    lurek.log.info("gpu objects = " .. gpu_objects .. ", texture KB = " .. texture_bytes)
end

--@api: lurek.engine.getFrameProfile
do
    local prof = lurek.engine.getFrameProfile()
    local script_ms = prof.process_ms + prof.process_late_ms + prof.callback_total_ms
    local render_ms = prof.draw_ms + prof.draw_ui_ms
    local core_ms = prof.app_tick_ms + prof.app_update_ms + prof.app_render_ms
    lurek.log.info("frame total = " .. string.format("%.3f", prof.app_frame_total_ms) .. " ms")
    lurek.log.info("core=" .. string.format("%.3f", core_ms) .. " script=" .. string.format("%.3f", script_ms) .. " render=" .. string.format("%.3f", render_ms))
end

--@api: lurek.engine.getFrameProfileText
do
    local txt = lurek.engine.getFrameProfileText()
    local profile = lurek.engine.getFrameProfile()
    local has_draw_data = profile.draw_ms >= 0 and profile.draw_ui_ms >= 0
    local line_count = select(2, txt:gsub("\n", "\n")) + 1
    lurek.log.info("profile summary: " .. txt)
    lurek.log.info("text lines = " .. line_count .. ", draw data present = " .. tostring(has_draw_data))
end
