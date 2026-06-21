local app = {
    ready = false,
    ctx = nil,
}

local REFRESH_DEBOUNCE_SEC = 0.12

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

local function time_seconds()
    return os.clock()
end

--- updates all data in the UI
-- @param ctx table: the app context
local function refresh(ctx)
    local started = time_seconds()
    ctx.filters = ctx.Controls.read_filters(ctx)
    ctx.Pipeline.refresh(ctx, ctx.filters)
    local finished = time_seconds()
    ctx.refresh_ms = math.max(0, (finished - started) * 1000)
    ctx.status = string.format(
        "%s | %d raw | %d clean | %d visible",
        ctx.source or "ready",
        ctx.row_count or 0,
        ctx.clean_count or 0,
        math.floor((ctx.view.metrics and ctx.view.metrics.count) or 0)
    )
    ctx.Controls.update_widgets(ctx)
    ctx.needs_refresh = false
    ctx.pending_refresh = false
end

-- Schedules a refresh after a debounce period
-- @param ctx table: the app context
local function schedule_refresh(ctx)
    ctx.pending_refresh = true
    ctx.refresh_due = (ctx.clock or 0) + REFRESH_DEBOUNCE_SEC
    ctx.needs_refresh = false
    ctx.status = "Filters changed; SQL refresh queued"
end

--- converts screen coordinates to virtual coordinates
-- @param ctx table: the app context
-- @param x number: the screen x coordinate
-- @param y number: the screen y coordinate
-- @return number: the virtual x coordinate
-- @return number: the virtual y coordinate
local function screen_to_virtual(ctx, x, y)
    return x, y
end

-- Sets default window configuration
local function apply_window_defaults()
    lurek.window.windowConfig({
        width = 1200,
        height = 800,
        scaleMode = "none",
    })
end

-- saves widget state through lurek.save
-- @param ctx table: the app context
local function save_state(ctx)
    if not ctx.save_manager then return end
    ctx.save_manager:setSummary("Household Finance Lab widgets")
    ctx.save_manager:markDirty()
    ctx.save_manager:save(ctx.C.SAVE_SLOT)
    ctx.Pipeline.log(ctx, "info", "Saved widget snapshot through lurek.save")
    ctx.status = "Saved widget snapshot"
end

-- setup save manager
-- @param ctx table: the app context
local function setup_save(ctx)
    local manager = lurek.save.newSaveManager()
    manager:setSchemaVersion(1)
    manager:setCompress(true)
    manager:register("widgets", function()
        return ctx.Controls.snapshot(ctx)
    end, function(data)
        ctx.Controls.apply_snapshot(ctx, data or {})
    end)
    ctx.save_manager = manager
    if manager:exists(ctx.C.SAVE_SLOT) then
        local ok = pcall(function() return manager:load(ctx.C.SAVE_SLOT) end)
        if ok then
            ctx.Pipeline.log(ctx, "info", "Loaded widget snapshot through lurek.save")
        end
    end
end

-- wire up the global actions available to the application
-- @param ctx table: the app context
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
            ctx.Pipeline.log(ctx, "info", "Reloaded dataframe database cache")
        end,
        screenshot = function()
            lurek.render.saveScreenshot(ctx.C.SCREENSHOT_PATH)
            ctx.Pipeline.log(ctx, "info", "Screenshot requested: " .. ctx.C.SCREENSHOT_PATH)
            ctx.status = "Screenshot saved to " .. ctx.C.SCREENSHOT_PATH
        end,
        save_state = function()
            save_state(ctx)
        end,
    }
end

-- Create app context
-- @param mods table: the modules to load
-- @return table: the app context
local function make_context(mods)
    local C = mods.Config.load("app/config.toml")
    local ctx = {
        root = "",
        C = C,
        DataGeneration = mods.DataGeneration,
        Pipeline = mods.Pipeline,
        Controls = mods.Controls,
        UIRender = mods.UIRender,
        Tests = mods.Tests,
        logs = {},
        api_status = {},
        view = { anomalies = {}, recent = {}, monthly = {}, categories = {}, members = {}, payment = {}, recurring = {} },
        fonts = {},
        clock = 0,
        status = "Booting",
        refresh_ms = 0,
    }
    wire_actions(ctx)
    return ctx
end

-- Load all modules
-- @return table: the loaded modules
local function load_modules()
    return {
        Config = load_app_module("app/config.lua"),
        DataGeneration = load_app_module("app/data_generation.lua"),
        Pipeline = load_app_module("app/data_pipeline.lua"),
        Controls = load_app_module("app/ui_controls_toml.lua"),
        UIRender = load_app_module("app/ui_render.lua"),
        Tests = load_app_module("app/tests.lua"),
    }
end

-- Called by Lurek when the app is initialized
function lurek.init()
    apply_window_defaults()
    local mods = load_modules()
    local ctx = make_context(mods)
    app.ctx = ctx

    -- Initialize UI
    ctx.UIRender.setup(ctx)
    -- Initialize controls
    ctx.Controls.setup(ctx)
    -- Setup save manager
    setup_save(ctx)
    -- Load data
    ctx.Pipeline.load(ctx, { prefer_cache = true })
    -- Load test report
    load_test_report(ctx)
    refresh(ctx)
    ctx.Pipeline.log(ctx, "info", "Household Finance Lab ready")
    app.ready = true
end

-- Called by Lurek during the update loop
-- @param dt number: the time delta since the last update
function lurek.process(dt)
    if not app.ready then return end
    local ctx = app.ctx
    if not ctx then return end
    ctx.clock = ctx.clock + (dt or 0)
    if ctx.UIRender.update_viewport then ctx.UIRender.update_viewport(ctx) end
    if ctx.Controls.relayout then
        ctx.Controls.relayout(ctx, ctx.layout_width or ctx.viewport_width, ctx.layout_height or ctx.viewport_height)
    end
    lurek.ui.update(dt or 0)
    if ctx.save_manager then ctx.save_manager:update(dt or 0) end
    if ctx.Controls.poll(ctx) then schedule_refresh(ctx) end
    if ctx.pending_refresh and (ctx.clock or 0) >= (ctx.refresh_due or 0) then refresh(ctx) end
end

function lurek.draw()
    if not app.ready then return end
    local ctx = app.ctx
    if not ctx then return end
    ctx.UIRender.draw(ctx)
    if not ctx.screen_written and (ctx.clock or 0) > 0.5 then
        lurek.render.saveScreenshot(ctx.C.SCREEN_PATH)
        ctx.screen_written = true
    end
end

function lurek.keypressed(key)
    if not app.ready then return false end
    local ctx = app.ctx
    if not ctx then return false end
    local handled = lurek.ui.keypressed(key)
    local w = ctx.widgets or {}
    local n = tonumber(key)
    if n and n >= 1 and n <= #ctx.C.TABS then
        if w.tabs then
            w.tabs:setActiveTab(n)
            ctx.ui_active_tab = n
        else
            ctx.ui_active_tab = n
        end
        ctx.needs_refresh = true
        return true
    end
    if key == "left" and w.start_year then
        w.start_year:setValue((w.start_year:getValue() or ctx.C.YEAR_MIN) - 1)
        ctx.needs_refresh = true
        return true
    end
    if key == "right" and w.end_year then
        w.end_year:setValue((w.end_year:getValue() or ctx.C.YEAR_MAX) + 1)
        ctx.needs_refresh = true
        return true
    end
    if key == "c" and w.cleaned then w.cleaned:toggle(); ctx.needs_refresh = true; return true end
    if key == "r" then ctx.actions.regenerate(); return true end
    if key == "p" then ctx.actions.screenshot(); return true end
    if key == "s" then ctx.actions.save_state(); return true end
    return handled
end

function lurek.mousepressed(x, y, button)
    if not app.ready then return false end
    local ctx = app.ctx
    if not ctx then return false end
    x, y = screen_to_virtual(ctx, x, y)
    return lurek.ui.mousepressed(x, y, button)
end

function lurek.mousereleased(x, y, button)
    if not app.ready then return false end
    local ctx = app.ctx
    if not ctx then return false end
    x, y = screen_to_virtual(ctx, x, y)
    return lurek.ui.mousereleased(x, y, button)
end

function lurek.mousemoved(x, y)
    if not app.ready then return false end
    local ctx = app.ctx
    if not ctx then return false end
    x, y = screen_to_virtual(ctx, x, y)
    return lurek.ui.mousemoved(x, y)
end

function lurek.wheelmoved(x, y)
    if not app.ready then return false end
    return lurek.ui.wheelmoved(x, y)
end

function lurek.textinput(text)
    if not app.ready then return false end
    return lurek.ui.textinput(text)
end

function lurek.resize(width, height)
    local ctx = app.ctx
    if app.ready and ctx then
        ctx.viewport_width = width
        ctx.viewport_height = height
        if ctx.UIRender.update_viewport then ctx.UIRender.update_viewport(ctx) end
        if ctx.Controls.relayout then
            ctx.Controls.relayout(ctx, ctx.layout_width or width, ctx.layout_height or height)
        end
    end
end
