local UIRender = {}

local function set(c)
    lurek.render.setColor(c[1], c[2], c[3], c[4] or 1)
end

local function short(text, max_len)
    text = tostring(text or "")
    if #text <= max_len then return text end
    return string.sub(text, 1, math.max(1, max_len - 1)) .. "."
end

local function money(value)
    local n = tonumber(value) or 0
    local sign = n < 0 and "-" or ""
    n = math.abs(n)
    if n >= 1000000 then return sign .. string.format("%.1fm PLN", n / 1000000) end
    if n >= 1000 then return sign .. string.format("%.0fk PLN", n / 1000) end
    return sign .. string.format("%.0f PLN", n)
end

local function pct(value)
    return string.format("%.1f%%", (tonumber(value) or 0) * 100)
end

local function ms(value)
    return string.format("%.2f ms", tonumber(value) or 0)
end

local function frame_max(frame, key)
    if not frame or not key then return 0 end
    local ok, value = pcall(function() return frame:max(key) end)
    if ok then return tonumber(value) or 0 end
    return 0
end

local BASE_DRAW_W = 1200
local BASE_DRAW_H = 800

local CONTENT_TOP = 146
local CONTENT_BOTTOM = 548

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
    local y_max = math.max(1, frame_max(monthly_frame, A.income), frame_max(monthly_frame, A.expense), frame_max(monthly_frame, A.savings))

    local line = lurek.ui.newLineChart({ width = 486, height = 184, title = "Cashflow" })
    if monthly_frame then
        line:addSeriesFromDataFrame("income", monthly_frame, "month_index", A.income, C.COLORS.green[1], C.COLORS.green[2], C.COLORS.green[3])
        line:addSeriesFromDataFrame("expense", monthly_frame, "month_index", A.expense, C.COLORS.red[1], C.COLORS.red[2], C.COLORS.red[3])
        line:addSeriesFromDataFrame("savings", monthly_frame, "month_index", A.savings, C.COLORS.cyan[1], C.COLORS.cyan[2], C.COLORS.cyan[3])
    end
    line:setXMax(math.max(1, frame_max(monthly_frame, "month_index")))
    line:setYMax(y_max)
    charts.cashflow = chart_image(line, 486, 184)

    local area = lurek.ui.newAreaChart({ width = 220, height = 96, title = "Monthly" })
    if monthly_frame then
        area:addLayerFromDataFrame("expense", monthly_frame, A.expense, C.COLORS.red[1], C.COLORS.red[2], C.COLORS.red[3])
        area:addLayerFromDataFrame("income", monthly_frame, A.income, C.COLORS.green[1], C.COLORS.green[2], C.COLORS.green[3])
    end
    area:setYMax(y_max)
    charts.monthly_area = chart_image(area, 220, 96)

    local cat = lurek.ui.newBarChart({ width = 360, height = 278, title = "Categories" })
    cat:addSeries("expense", C.COLORS.blue[1], C.COLORS.blue[2], C.COLORS.blue[3])
    if categories_frame then cat:addCategoriesFromDataFrame(categories_frame, "category_clean", { A.expense }) end
    charts.categories = chart_image(cat, 360, 278)

    local members = lurek.ui.newBarChart({ width = 360, height = 210, title = "Members" })
    members:addSeries("expense", C.COLORS.violet[1], C.COLORS.violet[2], C.COLORS.violet[3])
    if members_frame then members:addCategoriesFromDataFrame(members_frame, "member_clean", { A.expense }) end
    charts.members = chart_image(members, 360, 210)

    local recurring = lurek.ui.newBarChart({ width = 360, height = 124, title = "Recurring" })
    recurring:addSeries("expense", C.COLORS.amber[1], C.COLORS.amber[2], C.COLORS.amber[3])
    if recurring_frame then recurring:addCategoriesFromDataFrame(recurring_frame, "merchant", { A.expense }) end
    charts.recurring = chart_image(recurring, 360, 124)

    local pie = lurek.ui.newPieChart({ width = 220, height = 130, title = "Payments" })
    if payment_frame then pie:addSegmentsFromDataFrame(payment_frame, "payment_method", A.expense) end
    charts.payments = chart_image(pie, 220, 130)

    local scatter = lurek.ui.newScatterPlot({ width = 340, height = 210, title = "Anomalies" })
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

local function draw_chart(ctx, name, x, y, sx, sy)
    local image = ctx.charts and ctx.charts[name]
    if not image then return end
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.draw(image, x, y, 0, sx or 1, sy or sx or 1)
end

local function panel(C, x, y, w, h, title)
    set(C.COLORS.panel)
    lurek.render.rectangle("fill", x, y, w, h, 5, 5)
    set(C.COLORS.line)
    lurek.render.rectangle("line", x, y, w, h, 5, 5)
    if title then
        set(C.COLORS.text)
        lurek.render.print(title, x + 10, y + 8, 1)
    end
end

local function draw_control_text(_ctx)
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

local function api_rows(ctx)
    local filters = ctx.filters or {}
    local report = (ctx.test_report_lines and ctx.test_report_lines[1]) or "no report"
    local method_count = 0
    for _, used in pairs(ctx.dataframe_methods or {}) do
        if used then method_count = method_count + 1 end
    end
    return {
        { "tab", ctx.C.TABS[filters.active_tab or 1] or "", "LTabBar" },
        { "member", filters.member or "All", "LComboBox" },
        { "category", filters.category or "All", "LComboBox" },
        { "years", tostring(filters.start_year or ctx.C.YEAR_MIN) .. "-" .. tostring(filters.end_year or ctx.C.YEAR_MAX), "LSlider" },
        { "cleaned", tostring(filters.use_cleaned ~= false), "LSwitch" },
        { "threshold", tostring(filters.anomaly_threshold or 30), "LSlider" },
        { "db tables", tostring(ctx.db and ctx.db:tableCount() or 0), "LDatabase" },
        { "sql files", tostring(#(ctx.C.SQL_FILES or {})), "queryParams" },
        { "cache", ctx.C.CACHE_VERSION, "LDatabase:save" },
        { "restore", "database", "loadDatabase" },
        { "df methods", tostring(method_count), "LDataFrame" },
        { "chart imgs", tostring(ctx.chart_count or 0), "DF charts" },
        { "frame", ms(ctx.perf and ctx.perf.frame_ms), "getFrameProfile" },
        { "render", ms(ctx.perf and ctx.perf.render_ms), "getStats" },
        { "refresh", ms(ctx.refresh_ms), "SQL refresh" },
        { "test", short(report, 24), "GameFS" },
        { "save slot", ctx.C.SAVE_SLOT, "save" },
    }
end

local function draw_api_table_text(ctx)
    local C = ctx.C
    set(C.COLORS.panel2)
    lurek.render.rectangle("fill", 524, CONTENT_TOP, 264, CONTENT_BOTTOM - CONTENT_TOP, 5, 5)
    set(C.COLORS.amber)
    lurek.render.rectangle("fill", 524, CONTENT_TOP, 5, CONTENT_BOTTOM - CONTENT_TOP, 2, 2)
    set(C.COLORS.line)
    lurek.render.rectangle("line", 524, CONTENT_TOP, 264, CONTENT_BOTTOM - CONTENT_TOP, 5, 5)
    set(C.COLORS.text)
    lurek.render.print("Widget/API state", 540, CONTENT_TOP + 8, 1)
    set(C.COLORS.white)
    lurek.render.print("Key", 540, CONTENT_TOP + 32, 1)
    lurek.render.print("Value", 614, CONTENT_TOP + 32, 1)
    lurek.render.print("API", 716, CONTENT_TOP + 32, 1)
    local y = CONTENT_TOP + 54
    for _, row in ipairs(api_rows(ctx)) do
        set(C.COLORS.muted)
        lurek.render.print(short(row[1], 10), 540, y, 1)
        set(C.COLORS.text)
        lurek.render.print(short(row[2], 14), 614, y, 1)
        set(C.COLORS.cyan)
        lurek.render.print(short(row[3], 10), 716, y, 1)
        y = y + 20
    end
end

local function draw_api_compact_text(ctx, x, y)
    local C = ctx.C
    local rows = api_rows(ctx)
    set(C.COLORS.white)
    lurek.render.print("API proof", x, y, 1)
    y = y + 22
    for index = 1, math.min(6, #rows) do
        local row = rows[index]
        set(C.COLORS.muted)
        lurek.render.print(short(row[1], 9), x, y, 1)
        set(C.COLORS.text)
        lurek.render.print(short(row[2], 12), x + 66, y, 1)
        set(C.COLORS.cyan)
        lurek.render.print(short(row[3], 10), x + 146, y, 1)
        y = y + 18
    end
end

local function metric(C, x, y, w, label, value, detail, color)
    local max_chars = math.max(8, math.floor((w - 18) / 6))
    set(C.COLORS.panel2)
    lurek.render.rectangle("fill", x, y, w, 54, 4, 4)
    set(color)
    lurek.render.rectangle("fill", x, y, 4, 54, 2, 2)
    set(C.COLORS.muted)
    lurek.render.print(short(label, max_chars), x + 10, y + 6, 1)
    set(C.COLORS.text)
    lurek.render.print(short(value, max_chars), x + 10, y + 22, 1)
    set(C.COLORS.muted)
    lurek.render.print(short(detail, max_chars), x + 10, y + 39, 1)
end

local function draw_controls(_ctx)
end

local function draw_header(ctx)
    local C = ctx.C
    if ctx.fonts.title then lurek.render.setFont(ctx.fonts.title) end
    set(C.COLORS.text)
    lurek.render.print("Household Finance Lab", 12, 10, 1)
    if ctx.fonts.small then lurek.render.setFont(ctx.fonts.small) end
    set(C.COLORS.muted)
    lurek.render.print("Public API: TOML + DataFrame + SQL + UI widgets", 218, 13, 1)
    draw_controls(ctx)
end

local function draw_widgets(ctx)
    local C = ctx.C
    local v = ctx.view
    local m = v.metrics or {}
    metric(C, 12, CONTENT_TOP, 118, "Income", money(m.income), "filtered", C.COLORS.green)
    metric(C, 138, CONTENT_TOP, 118, "Expenses", money(m.expense), "spend", C.COLORS.red)
    metric(C, 264, CONTENT_TOP, 118, "Savings", pct(m.savings_rate), "rate", C.COLORS.cyan)
    metric(C, 390, CONTENT_TOP, 118, "Debt", pct(m.debt_ratio), "ratio", C.COLORS.amber)
    metric(C, 12, CONTENT_TOP + 62, 118, "Runway", string.format("%.1f mo", m.runway_months or 0), "buffer", C.COLORS.violet)
    metric(C, 138, CONTENT_TOP + 62, 118, "Rows", tostring(math.floor(m.count or 0)), v.table_name or "", C.COLORS.blue)
    metric(C, 264, CONTENT_TOP + 62, 118, "Anomalies", tostring(#(v.anomalies or {})), "threshold", C.COLORS.red)
    metric(C, 390, CONTENT_TOP + 62, 118, "Cache", ctx.source or "", tostring(ctx.clean_count or 0) .. " clean", C.COLORS.green)

    panel(C, 12, 270, 240, 120, "Monthly")
    draw_chart(ctx, "monthly_area", 22, 296)

    panel(C, 264, 270, 248, 120, "Payment mix")
    draw_chart(ctx, "payments", 278, 278, 1, 0.82)

    panel(C, 12, 400, 500, 144, "Pipeline status")
    local y = 426
    local lines = {
        "CSV rows: " .. tostring(ctx.row_count or 0),
        "Clean rows: " .. tostring(ctx.clean_count or 0),
        "DB tables: " .. tostring(ctx.db and ctx.db:tableCount() or 0),
        "SQL files: " .. tostring(#C.SQL_FILES),
        "Cache: " .. C.DATABASE_JSON_PATH,
        "Source: " .. tostring(ctx.source or ""),
        "Refresh: " .. ms(ctx.refresh_ms),
        "Frame: " .. ms(ctx.perf and ctx.perf.frame_ms),
    }
    for _, line in ipairs(lines) do
        set(C.COLORS.muted)
        lurek.render.print(short(line, 34), 30, y, 1)
        y = y + 18
    end
    draw_api_compact_text(ctx, 282, 426)

end

local function draw_cashflow(ctx)
    local C = ctx.C
    panel(C, 12, CONTENT_TOP, 500, 250, "Income, expense, savings")
    draw_chart(ctx, "cashflow", 20, 170)
    panel(C, 524, CONTENT_TOP, 264, 250, "Trend cards")
    local m = ctx.view.metrics or {}
    metric(C, 538, 166, 236, "Net", money(m.net), "income - expense - savings", m.net and m.net >= 0 and C.COLORS.green or C.COLORS.red)
    metric(C, 538, 220, 236, "Essential", pct(m.essential_ratio), "expense share", C.COLORS.amber)
    metric(C, 538, 274, 236, "Average expense", money(m.avg_expense), "monthly", C.COLORS.red)
    metric(C, 538, 328, 236, "Runway", string.format("%.1f mo", m.runway_months or 0), "buffer", C.COLORS.cyan)
    panel(C, 12, 392, 776, 152, "Recurring merchants")
    draw_chart(ctx, "recurring", 220, 416)
end

local function draw_categories(ctx)
    local C = ctx.C
    panel(C, 12, CONTENT_TOP, 386, CONTENT_BOTTOM - CONTENT_TOP, "Category totals")
    draw_chart(ctx, "categories", 24, 172)
    panel(C, 410, CONTENT_TOP, 378, 250, "Member totals")
    draw_chart(ctx, "members", 420, 168)
    panel(C, 410, 392, 378, 152, "DataFrame methods")
    local y = 424
    for name, used in pairs(ctx.dataframe_methods or {}) do
        set(used and C.COLORS.green or C.COLORS.red)
        lurek.render.print(short(name, 28) .. " = " .. tostring(used), 430, y, 1)
        y = y + 18
    end
end

local function draw_members(ctx)
    local C = ctx.C
    panel(C, 12, CONTENT_TOP, 374, CONTENT_BOTTOM - CONTENT_TOP, "Household member load")
    draw_chart(ctx, "members", 20, 172)
    panel(C, 398, CONTENT_TOP, 390, CONTENT_BOTTOM - CONTENT_TOP, "Recent selected member transactions")
    set(C.COLORS.muted)
    lurek.render.print("Right panel uses native LGuiTable widget", 414, 168, 1)
end

local function draw_payments(ctx)
    local C = ctx.C
    panel(C, 12, CONTENT_TOP, 250, 210, "Payment method mix")
    draw_chart(ctx, "payments", 26, 160)
    panel(C, 274, CONTENT_TOP, 514, 210, "Recurring merchant chart")
    draw_chart(ctx, "recurring", 350, 178)
    panel(C, 12, 348, 776, 196, "Cashflow line")
    draw_chart(ctx, "cashflow", 156, 360)
end

local function draw_anomalies(ctx)
    local C = ctx.C
    panel(C, 12, CONTENT_TOP, 366, CONTENT_BOTTOM - CONTENT_TOP, "Anomaly scatter")
    local rows = ctx.view.anomalies or {}
    draw_chart(ctx, "anomalies", 24, 172)
    local selected = rows[1]
    set(C.COLORS.muted)
    lurek.render.print("Selected", 24, 390, 1)
    if selected then
        set(C.COLORS.text)
        lurek.render.print(short(selected.anomaly_issue, 28), 24, 412, 1)
        lurek.render.print(short((selected.date or "") .. " " .. (selected.merchant or ""), 44), 24, 434, 1)
        lurek.render.print(short((selected.member_clean or "") .. " / " .. (selected.category_clean or ""), 44), 24, 456, 1)
        lurek.render.print("Score " .. tostring(selected.anomaly_score or 0) .. "  " .. money(selected.amount_abs), 24, 478, 1)
    end

    panel(C, 390, CONTENT_TOP, 398, CONTENT_BOTTOM - CONTENT_TOP, "Anomaly list")
    local y = 168
    for index = 1, math.min(16, #rows) do
        local row = rows[index]
        if index == 1 then
            set(C.COLORS.panel2)
            lurek.render.rectangle("fill", 402, y - 3, 370, 20, 3, 3)
        end
        set(row.anomaly_severity == "high" and C.COLORS.red or C.COLORS.amber)
        lurek.render.print(short(row.anomaly_issue, 16), 410, y, 1)
        set(C.COLORS.text)
        lurek.render.print(short(row.date, 10), 526, y, 1)
        lurek.render.print(short(row.merchant, 18), 596, y, 1)
        set(C.COLORS.muted)
        lurek.render.print(money(row.amount_abs), 716, y, 1)
        y = y + 24
    end
end

local function draw_transactions(ctx)
    local C = ctx.C
    set(C.COLORS.line)
    lurek.render.rectangle("line", 12, CONTENT_TOP, 776, CONTENT_BOTTOM - CONTENT_TOP, 5, 5)
    set(C.COLORS.text)
    lurek.render.print("Transaction table from LGuiTable:setDataFrame", 22, CONTENT_TOP + 8, 1)
end

local function draw_logs(ctx)
    local C = ctx.C
    panel(C, 12, CONTENT_TOP, 510, CONTENT_BOTTOM - CONTENT_TOP, "Logs")
    local y = 168
    local start = math.max(1, #ctx.logs - 20)
    for index = start, math.min(#ctx.logs, start + 20) do
        local row = ctx.logs[index]
        set(row.level == "warn" and C.COLORS.amber or C.COLORS.muted)
        lurek.render.print(short(row.level, 6), 30, y, 1)
        set(C.COLORS.text)
        lurek.render.print(short(row.message, 58), 82, y, 1)
        y = y + 20
    end

    panel(C, 534, CONTENT_TOP, 254, 196, "SQL")
    y = 168
    for index = math.max(1, #ctx.api_status - 7), #ctx.api_status do
        local item = ctx.api_status[index]
        if item then
            set(item.ok and C.COLORS.green or C.COLORS.red)
            lurek.render.print(item.ok and "OK" or "ERR", 552, y, 1)
            set(C.COLORS.text)
            lurek.render.print(short(item.name, 20), 590, y, 1)
            set(C.COLORS.muted)
            lurek.render.print(tostring(item.rows or 0), 730, y, 1)
            y = y + 20
        end
    end

    panel(C, 534, 336, 254, 208, "Tests")
    y = 370
    local lines = ctx.test_report_lines or { "No report loaded" }
    for index = 1, math.min(8, #lines) do
        set(C.COLORS.text)
        lurek.render.print(short(lines[index], 28), 552, y, 1)
        y = y + 22
    end
end

function UIRender.setup(ctx)
    pcall(function() lurek.render.setDefaultFilter("nearest", "nearest", 1) end)
    local ui_font_size = math.max(10, ctx.C.FONT_SIZE or 8)
    ctx.fonts = {
        small = lurek.render.getDefaultFont(ctx.C.FONT_SIZE or 8),
        title = lurek.render.getDefaultFont(ctx.C.TITLE_FONT_SIZE or 10),
        ui = lurek.render.getDefaultFont(ui_font_size),
    }
    if ctx.fonts.ui then
        pcall(function() lurek.ui.setFont(ctx.fonts.ui) end)
    elseif ctx.fonts.small then
        pcall(function() lurek.ui.setFont(ctx.fonts.small) end)
    end
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
    local C = ctx.C
    local width = ctx.viewport_width or C.WIDTH
    local height = ctx.viewport_height or C.HEIGHT
    local ok_w, runtime_w = pcall(function() return lurek.window.getWidth() end)
    local ok_h, runtime_h = pcall(function() return lurek.window.getHeight() end)
    if ok_w and runtime_w and runtime_w > 0 then width = runtime_w end
    if ok_h and runtime_h and runtime_h > 0 then height = runtime_h end
    ctx.viewport_width = width
    ctx.viewport_height = height
    ctx.layout_width = math.max(1200, width)
    ctx.layout_height = math.max(800, height)
    ctx.render_scale = 1
    ctx.render_offset_x = 0
    ctx.render_offset_y = 0
    lurek.ui.setViewport(ctx.layout_width, ctx.layout_height)
end

function UIRender.draw(ctx)
    local C = ctx.C
    UIRender.update_viewport(ctx)
    sample_performance(ctx)
    build_charts(ctx)
    if ctx.Controls then ctx.Controls.update_widgets(ctx) end
    lurek.render.clear(C.COLORS.bg[1], C.COLORS.bg[2], C.COLORS.bg[3])
    local sx = (ctx.layout_width or ctx.C.WIDTH) / BASE_DRAW_W
    local sy = (ctx.layout_height or ctx.C.HEIGHT) / BASE_DRAW_H
    lurek.render.push()
    lurek.render.scale(sx, sy)
    if ctx.fonts.small then lurek.render.setFont(ctx.fonts.small) end
    lurek.render.setScissor()
    local active_tab = (ctx.filters and ctx.filters.active_tab) or 1
    if active_tab == 1 then
        draw_widgets(ctx)
    elseif active_tab == 2 then
        draw_cashflow(ctx)
    elseif active_tab == 3 then
        draw_categories(ctx)
    elseif active_tab == 4 then
        draw_members(ctx)
    elseif active_tab == 5 then
        draw_payments(ctx)
    elseif active_tab == 6 then
        draw_anomalies(ctx)
    elseif active_tab == 7 then
        draw_transactions(ctx)
    else
        draw_logs(ctx)
    end
    lurek.render.setScissor()
    if ctx.fonts.small then lurek.render.setFont(ctx.fonts.small) end
    draw_control_text(ctx)
    -- Reset render tint so native UI widgets are not dimmed by previous custom draws.
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.pop()
end

return UIRender
