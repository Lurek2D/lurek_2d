local UIRender = {}

local function frame_max(frame, key)
    if not frame or not key then return 0 end
    local ok, value = pcall(function() return frame:max(key) end)
    if ok then return tonumber(value) or 0 end
    return 0
end

local function release_image(image)
    if not image then return end
    pcall(function() image:release() end)
end

local function release_chart_images(charts)
    if type(charts) ~= "table" then return end
    for _, image in pairs(charts) do
        release_image(image)
    end
end

local function chart_image(chart, width, height)
    local target = lurek.image.newImageData(width, height)
    chart:drawToImage(target)
    return lurek.render.newImage(target)
end

local function build_charts(ctx)
    if ctx.chart_version == ctx.view_version then return end

    local C = ctx.C
    local A = C.AGG
    local view = ctx.view or {}
    local monthly_frame = view.monthly_frame
    local categories_frame = view.categories_frame
    local members_frame = view.members_frame
    local recurring_frame = view.recurring_frame
    local payment_frame = view.payment_frame
    local anomalies_frame = view.anomalies_frame
    local charts = {}

    local y_max = math.max(
        1,
        frame_max(monthly_frame, A.income),
        frame_max(monthly_frame, A.expense),
        frame_max(monthly_frame, A.savings)
    )

    local line = lurek.ui.newLineChart({ width = 486, height = 184 })
    if monthly_frame then
        line:addSeriesFromDataFrame("income", monthly_frame, "month_index", A.income, C.COLORS.green[1], C.COLORS.green[2], C.COLORS.green[3])
        line:addSeriesFromDataFrame("expense", monthly_frame, "month_index", A.expense, C.COLORS.red[1], C.COLORS.red[2], C.COLORS.red[3])
        line:addSeriesFromDataFrame("savings", monthly_frame, "month_index", A.savings, C.COLORS.cyan[1], C.COLORS.cyan[2], C.COLORS.cyan[3])
    end
    line:setXMax(math.max(1, frame_max(monthly_frame, "month_index")))
    line:setYMax(y_max)
    charts.cashflow = chart_image(line, 486, 184)

    local area = lurek.ui.newAreaChart({ width = 220, height = 96 })
    if monthly_frame then
        area:addLayerFromDataFrame("expense", monthly_frame, A.expense, C.COLORS.red[1], C.COLORS.red[2], C.COLORS.red[3])
        area:addLayerFromDataFrame("income", monthly_frame, A.income, C.COLORS.green[1], C.COLORS.green[2], C.COLORS.green[3])
    end
    area:setYMax(y_max)
    charts.monthly_area = chart_image(area, 220, 96)

    local cat = lurek.ui.newBarChart({ width = 360, height = 278 })
    cat:addSeries("expense", C.COLORS.blue[1], C.COLORS.blue[2], C.COLORS.blue[3])
    if categories_frame then cat:addCategoriesFromDataFrame(categories_frame, "category_clean", { A.expense }) end
    charts.categories = chart_image(cat, 360, 278)

    local members = lurek.ui.newBarChart({ width = 360, height = 210 })
    members:addSeries("expense", C.COLORS.violet[1], C.COLORS.violet[2], C.COLORS.violet[3])
    if members_frame then members:addCategoriesFromDataFrame(members_frame, "member_clean", { A.expense }) end
    charts.members = chart_image(members, 360, 210)

    local recurring = lurek.ui.newBarChart({ width = 360, height = 124 })
    recurring:addSeries("expense", C.COLORS.amber[1], C.COLORS.amber[2], C.COLORS.amber[3])
    if recurring_frame then recurring:addCategoriesFromDataFrame(recurring_frame, "merchant", { A.expense }) end
    charts.recurring = chart_image(recurring, 360, 124)

    local pie = lurek.ui.newPieChart({ width = 220, height = 130 })
    if payment_frame then pie:addSegmentsFromDataFrame(payment_frame, "payment_method", A.expense) end
    charts.payments = chart_image(pie, 220, 130)

    local scatter = lurek.ui.newScatterPlot({ width = 340, height = 210 })
    if anomalies_frame then
        scatter:addSeriesFromDataFrame("anomaly", anomalies_frame, "month_index", "amount_abs", C.COLORS.red[1], C.COLORS.red[2], C.COLORS.red[3])
    end
    scatter:setXRange(1, math.max(60, frame_max(monthly_frame, "month_index")))
    scatter:setYRange(0, math.max(1, frame_max(anomalies_frame, "amount_abs")))
    charts.anomalies = chart_image(scatter, 340, 210)

    release_chart_images(ctx.charts)
    ctx.charts = charts
    ctx.chart_count = 7
    ctx.chart_version = ctx.view_version
end

local function slot_rect(ctx, slot_id)
    local widgets = ctx.widgets
    local slots = widgets and widgets.chart_slots
    local slot = slots and slots[slot_id]
    if not slot then return nil end
    local x, y, w, h = slot:getRect()
    return x, y, w, h
end

local function draw_chart_in_slot(ctx, chart_name, slot_id)
    local image = ctx.charts and ctx.charts[chart_name]
    if not image then return end

    local x, y, w, h = slot_rect(ctx, slot_id)
    if not x then return end

    local iw = image:getWidth()
    local ih = image:getHeight()
    if iw <= 0 or ih <= 0 then return end

    local sx = w / iw
    local sy = h / ih
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.draw(image, x, y, 0, sx, sy)
end

local function draw_toml_charts(ctx, active_tab)
    if active_tab == 2 then
        draw_chart_in_slot(ctx, "cashflow", "cashflow_tab2")
        draw_chart_in_slot(ctx, "monthly_area", "monthly_area_tab2")
        draw_chart_in_slot(ctx, "payments", "payments_tab2")
        draw_chart_in_slot(ctx, "recurring", "recurring_tab2")
    elseif active_tab == 3 then
        draw_chart_in_slot(ctx, "categories", "categories_tab3")
        draw_chart_in_slot(ctx, "members", "members_tab3")
    elseif active_tab == 4 then
        draw_chart_in_slot(ctx, "members", "members_tab4")
    elseif active_tab == 5 then
        draw_chart_in_slot(ctx, "payments", "payments_tab5")
        draw_chart_in_slot(ctx, "recurring", "recurring_tab5")
        draw_chart_in_slot(ctx, "cashflow", "cashflow_tab5")
    elseif active_tab == 6 then
        draw_chart_in_slot(ctx, "anomalies", "anomalies_tab6")
    end
end

local function sample_performance(ctx)
    local clock = ctx.clock or 0
    if ctx.next_perf_sample and clock < ctx.next_perf_sample then return end
    ctx.next_perf_sample = clock + 0.25

    local profile = {}
    local ok_profile, profile_result = pcall(function() return lurek.engine.getFrameProfile() end)
    if ok_profile and type(profile_result) == "table" then profile = profile_result end

    local stats = {}
    local ok_stats, stats_result = pcall(function() return lurek.render.getStats() end)
    if ok_stats and type(stats_result) == "table" then stats = stats_result end

    ctx.perf = {
        frame_ms = tonumber(profile.app_frame_total_ms or profile.frame_total_ms or profile.callback_total_ms) or 0,
        render_ms = tonumber(profile.app_render_ms or profile.draw_ms or stats.cpu_render_ms) or 0,
        ui_ms = tonumber(profile.draw_ui_ms or 0) or 0,
        draw_calls = tonumber(stats.gpu_draw_calls or stats.draw_calls or stats.batched_draws) or 0,
    }
end

function UIRender.setup(ctx)
    -- Keep smoothing for dashboard visuals and text readability.
    lurek.render.setDefaultFilter("linear", "linear", 1)

    local ui_font_size = math.max(16, tonumber(ctx.C.FONT_SIZE) or 20)
    local title_font_size = math.max(ui_font_size, tonumber(ctx.C.TITLE_FONT_SIZE) or ui_font_size)
    local table_font_size = math.max(12, math.min(ui_font_size - 4, 14))

    ctx.fonts = {
        small = lurek.render.getDefaultFont(ui_font_size),
        title = lurek.render.getDefaultFont(title_font_size),
        ui = lurek.render.getDefaultFont(ui_font_size),
        table = lurek.render.getDefaultFont(table_font_size),
    }

    ctx.render_scale = 1
    ctx.render_offset_x = 0
    ctx.render_offset_y = 0
    ctx.viewport_width = ctx.C.WIDTH
    ctx.viewport_height = ctx.C.HEIGHT
    ctx.layout_width = math.max(1200, ctx.C.WIDTH)
    ctx.layout_height = math.max(800, ctx.C.HEIGHT)

    lurek.ui.setViewport(ctx.layout_width, ctx.layout_height)
    lurek.render.setBackgroundColor(ctx.C.COLORS.bg[1], ctx.C.COLORS.bg[2], ctx.C.COLORS.bg[3])
end

function UIRender.update_viewport(ctx)
    local view_w = math.max(1200, math.floor(tonumber(ctx.viewport_width) or tonumber(ctx.C.WIDTH) or 1200))
    local view_h = math.max(800, math.floor(tonumber(ctx.viewport_height) or tonumber(ctx.C.HEIGHT) or 800))
    ctx.viewport_width = view_w
    ctx.viewport_height = view_h
    ctx.layout_width = view_w
    ctx.layout_height = view_h
    ctx.render_scale = 1
    ctx.render_offset_x = 0
    ctx.render_offset_y = 0
    lurek.ui.setViewport(view_w, view_h)
end

function UIRender.draw(ctx)
    local C = ctx.C
    UIRender.update_viewport(ctx)
    sample_performance(ctx)

    local active_tab = (ctx.filters and ctx.filters.active_tab) or 1
    if active_tab >= 2 and active_tab <= 6 then
        build_charts(ctx)
    end

    if ctx.Controls then ctx.Controls.update_widgets(ctx) end

    lurek.render.clear(C.COLORS.bg[1], C.COLORS.bg[2], C.COLORS.bg[3])
    lurek.render.push()
    lurek.render.setScissor()
    draw_toml_charts(ctx, active_tab)
    lurek.render.setScissor()
    -- Reset render tint so native UI widgets are not dimmed by chart draws.
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.pop()
end

return UIRender
