local app = {
    ready = false,
    ctx = nil,
}

local function load_app_module(path)
    local chunk = lurek.filesystem.load(path)
    return chunk()
end

local function split_lines(text)
    local out = {}
    for line in string.gmatch(text or "", "[^\n]+") do
        out[#out + 1] = line
    end
    return out
end

local function load_test_report(ctx)
    if lurek.filesystem.exists(ctx.C.TEST_REPORT_PATH) then
        ctx.test_report_lines = split_lines(lurek.filesystem.read(ctx.C.TEST_REPORT_PATH))
    else
        ctx.test_report_lines = { "No app-local test report yet", ctx.C.TEST_REPORT_PATH }
    end
end

local function save_state(ctx)
    local snap = ctx.UIState.snapshot(ctx.C, ctx.state)
    local text = string.format(
        "{\n  \"tab\": \"%s\",\n  \"start_year\": %d,\n  \"end_year\": %d,\n  \"member\": \"%s\",\n  \"category\": \"%s\",\n  \"use_cleaned\": %s,\n  \"anomaly_threshold\": %d\n}\n",
        snap.tab,
        snap.start_year,
        snap.end_year,
        snap.member,
        snap.category,
        snap.use_cleaned and "true" or "false",
        snap.anomaly_threshold
    )
    lurek.filesystem.write(ctx.C.SAVE_DIR .. "/ui_state.json", text)
    ctx.Pipeline.log(ctx, "info", "Saved UI state")
    ctx.state.status = "Saved UI state"
end

local function refresh(ctx)
    ctx.Analytics.refresh(ctx)
    ctx.Controls.layout(ctx)
    ctx.state.status = string.format(
        "%s | %d raw rows | %d clean rows | %d visible rows",
        ctx.source or "ready",
        ctx.row_count or 0,
        ctx.clean_count or 0,
        math.floor((ctx.view.metrics and ctx.view.metrics.count) or 0)
    )
end

local function screen_to_virtual(ctx, x, y)
    local scale = ctx.render_scale or 1
    if scale <= 0 then scale = 1 end
    return (x - (ctx.render_offset_x or 0)) / scale, (y - (ctx.render_offset_y or 0)) / scale
end

local function wire_actions(ctx)
    ctx.actions = {
        regenerate = function()
            ctx.Pipeline.load(ctx, { force_generate = true, prefer_cache = false })
            refresh(ctx)
            ctx.Pipeline.log(ctx, "info", "Regenerated CSV and SQL views")
        end,
        reload_cache = function()
            ctx.Pipeline.load(ctx, { prefer_cache = true })
            refresh(ctx)
            ctx.Pipeline.log(ctx, "info", "Reloaded binary cache")
        end,
        screenshot = function()
            lurek.render.saveScreenshot(ctx.C.SCREENSHOT_PATH)
            ctx.Pipeline.log(ctx, "info", "Screenshot requested: " .. ctx.C.SCREENSHOT_PATH)
            ctx.state.status = "Screenshot saved to " .. ctx.C.SCREENSHOT_PATH
        end,
        save_state = function()
            save_state(ctx)
        end,
    }
end

local function make_context(mods)
    local ctx = {
        root = "",
        C = mods.C,
        DataGeneration = mods.DataGeneration,
        SQLRunner = mods.SQLRunner,
        Pipeline = mods.Pipeline,
        Analytics = mods.Analytics,
        UIState = mods.UIState,
        Controls = mods.Controls,
        Charts = mods.Charts,
        UIRender = mods.UIRender,
        Tests = mods.Tests,
        logs = {},
        api_status = {},
        hitboxes = {},
        view = { anomalies = {}, recent = {}, monthly = {}, categories = {}, members = {}, payment = {}, recurring = {} },
        fonts = {},
        clock = 0,
    }
    ctx.state = ctx.UIState.new(ctx.C)
    wire_actions(ctx)
    return ctx
end

local function load_modules()
    return {
        C = load_app_module("app/constants.lua"),
        DataGeneration = load_app_module("app/data_generation.lua"),
        SQLRunner = load_app_module("app/sql_runner.lua"),
        Pipeline = load_app_module("app/data_pipeline.lua"),
        Analytics = load_app_module("app/analytics.lua"),
        UIState = load_app_module("app/ui_state.lua"),
        Controls = load_app_module("app/ui_controls.lua"),
        Charts = load_app_module("app/charts.lua"),
        UIRender = load_app_module("app/ui_render.lua"),
        Tests = load_app_module("app/tests.lua"),
    }
end

function lurek.init()
    local mods = load_modules()
    local ctx = make_context(mods)
    app.ctx = ctx

    ctx.UIRender.setup(ctx)
    ctx.Pipeline.load(ctx, { prefer_cache = true })
    load_test_report(ctx)
    refresh(ctx)
    ctx.Pipeline.log(ctx, "info", "Household Finance Lab ready")
    app.ready = true
end

function lurek.process(dt)
    if not app.ready then return end
    local ctx = app.ctx
    if not ctx then return end
    ctx.clock = ctx.clock + (dt or 0)
    if ctx.UIRender.update_viewport then ctx.UIRender.update_viewport(ctx) end
    if ctx.state.needs_refresh then refresh(ctx) end
    ctx.Controls.layout(ctx)
end

function lurek.draw()
    if not app.ready then return end
    local ctx = app.ctx
    if not ctx then return end
    ctx.UIRender.draw(ctx)
end

function lurek.keypressed(key)
    if not app.ready then return false end
    local ctx = app.ctx
    if not ctx then return false end
    local handled = ctx.Controls.keypressed(ctx, key)
    if handled and ctx.state.needs_refresh then refresh(ctx) end
    return handled
end

function lurek.mousepressed(x, y, button)
    if not app.ready then return false end
    local ctx = app.ctx
    if not ctx then return false end
    x, y = screen_to_virtual(ctx, x, y)
    local handled = ctx.Controls.mousepressed(ctx, x, y, button)
    if handled and ctx.state.needs_refresh then refresh(ctx) end
    return handled
end

function lurek.mousereleased(x, y, button)
    if not app.ready then return false end
    local ctx = app.ctx
    if not ctx then return false end
    return ctx.Controls.mousereleased(ctx, x, y, button)
end

function lurek.mousemoved(x, y)
    if not app.ready then return false end
    local ctx = app.ctx
    if not ctx then return false end
    x, y = screen_to_virtual(ctx, x, y)
    return ctx.Controls.mousemoved(ctx, x, y)
end

function lurek.wheelmoved(x, y)
    if not app.ready then return false end
    local ctx = app.ctx
    if not ctx then return false end
    return ctx.Controls.wheelmoved(ctx, x, y)
end

function lurek.resize(width, height)
    local ctx = app.ctx
    if app.ready and ctx then
        ctx.viewport_width = width
        ctx.viewport_height = height
        if ctx.UIRender.update_viewport then ctx.UIRender.update_viewport(ctx) end
        ctx.Controls.layout(ctx)
    end
end
