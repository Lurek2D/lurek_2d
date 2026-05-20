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

local function metric(C, x, y, w, label, value, detail, color)
    set(C.COLORS.panel2)
    lurek.render.rectangle("fill", x, y, w, 62, 4, 4)
    set(color)
    lurek.render.rectangle("fill", x, y, 4, 62, 2, 2)
    set(C.COLORS.muted)
    lurek.render.print(short(label, 18), x + 12, y + 8, 1)
    set(C.COLORS.text)
    lurek.render.print(short(value, 18), x + 12, y + 27, 1)
    set(C.COLORS.muted)
    lurek.render.print(short(detail, 20), x + 12, y + 45, 1)
end

local function draw_controls(ctx)
    local C = ctx.C
    for _, hb in ipairs(ctx.hitboxes) do
        if hb.kind ~= "row" then
            local active = (hb.kind == "tab" and hb.value == ctx.state.active_tab) or hb.id == ctx.state.hover_id
            set(active and C.COLORS.blue or C.COLORS.panel2)
            lurek.render.rectangle("fill", hb.x, hb.y, hb.w, hb.h, 4, 4)
            set(active and C.COLORS.text or C.COLORS.muted)
            lurek.render.print(short(hb.label, math.max(2, math.floor(hb.w / 7))), hb.x + 7, hb.y + 5, 1)
        end
    end
end

local function draw_header(ctx)
    local C = ctx.C
    if ctx.fonts.title then lurek.render.setFont(ctx.fonts.title) end
    set(C.COLORS.text)
    lurek.render.print("Household Finance Lab", 16, 13, 1)
    if ctx.fonts.small then lurek.render.setFont(ctx.fonts.small) end
    set(C.COLORS.muted)
    lurek.render.print("SQL-backed family finance dashboard", 238, 20, 1)
    draw_controls(ctx)
end

local function draw_widgets(ctx)
    local C = ctx.C
    local v = ctx.view
    local m = v.metrics or {}
    metric(C, 24, 116, 144, "Income", money(m.income), "filtered", C.COLORS.green)
    metric(C, 176, 116, 144, "Expenses", money(m.expense), "spend", C.COLORS.red)
    metric(C, 328, 116, 144, "Savings", pct(m.savings_rate), "rate", C.COLORS.cyan)
    metric(C, 480, 116, 144, "Debt", pct(m.debt_ratio), "ratio", C.COLORS.amber)
    metric(C, 632, 116, 144, "Runway", string.format("%.1f mo", m.runway_months or 0), "buffer", C.COLORS.violet)
    metric(C, 784, 116, 144, "Rows", tostring(math.floor(m.count or 0)), v.table_name or "", C.COLORS.blue)
    metric(C, 936, 116, 144, "Anomalies", tostring(#(v.anomalies or {})), "threshold", C.COLORS.red)
    metric(C, 1088, 116, 144, "Cache", ctx.source or "", tostring(ctx.clean_count or 0) .. " clean", C.COLORS.green)

    panel(C, 24, 200, 390, 188, "Monthly sparkline")
    ctx.Charts.sparkline(v.monthly or {}, 42, 232, 352, 132, "expense", C.COLORS.red)

    panel(C, 432, 200, 386, 188, "Payment mix")
    ctx.Charts.payment_mix(v.payment or {}, 450, 232, 348, 132, C)

    panel(C, 836, 200, 396, 188, "Pipeline status")
    local y = 232
    local lines = {
        "CSV rows: " .. tostring(ctx.row_count or 0),
        "Clean rows: " .. tostring(ctx.clean_count or 0),
        "DB tables: " .. tostring(ctx.db and ctx.db:tableCount() or 0),
        "SQL files: " .. tostring(#C.SQL_FILES),
        "Cache: " .. C.CACHE_MANIFEST,
        "Source: " .. tostring(ctx.source or ""),
    }
    for _, line in ipairs(lines) do
        set(C.COLORS.muted)
        lurek.render.print(short(line, 48), 854, y, 1)
        y = y + 20
    end

    panel(C, 24, 410, 1208, 236, "Spend heatmap")
    ctx.Charts.heatmap(v.heatmap or {}, 42, 442, 1172, 180, C)
end

local function draw_cashflow(ctx)
    local C = ctx.C
    panel(C, 24, 116, 782, 330, "Income, expense, savings")
    ctx.Charts.line(ctx.view.monthly or {}, 44, 152, 742, 250, { "income", "expense", "savings" }, { C.COLORS.green, C.COLORS.red, C.COLORS.cyan })
    panel(C, 826, 116, 406, 330, "Trend cards")
    local y = 154
    for _, card in ipairs(ctx.view.trend_cards or {}) do
        metric(C, 848, y, 360, card.label, money(card.value), "delta " .. money(card.delta), card.delta >= 0 and C.COLORS.green or C.COLORS.red)
        y = y + 72
    end
    panel(C, 24, 468, 1208, 158, "Recurring merchants")
    ctx.Charts.bars(ctx.view.recurring or {}, 44, 500, 1168, 104, "label", "value", C, 6)
end

local function draw_categories(ctx)
    local C = ctx.C
    panel(C, 24, 116, 580, 510, "Category totals")
    ctx.Charts.bars(ctx.view.categories or {}, 44, 150, 540, 450, "label", "value", C, 14)
    panel(C, 626, 116, 606, 244, "Member totals")
    ctx.Charts.bars(ctx.view.members or {}, 646, 150, 566, 184, "label", "value", C, 7)
    panel(C, 626, 382, 606, 244, "Category heatmap")
    ctx.Charts.heatmap(ctx.view.heatmap or {}, 646, 416, 566, 184, C)
end

local function draw_members(ctx)
    local C = ctx.C
    panel(C, 24, 116, 592, 510, "Household member load")
    ctx.Charts.bars(ctx.view.members or {}, 44, 152, 552, 430, "label", "value", C, 8)
    panel(C, 636, 116, 596, 510, "Recent selected member transactions")
    local y = 154
    for index, row in ipairs(ctx.view.recent or {}) do
        if index > 20 then break end
        set(C.COLORS.text)
        lurek.render.print(short(row.date, 10), 656, y, 1)
        lurek.render.print(short(row.member_clean, 10), 742, y, 1)
        lurek.render.print(short(row.category_clean, 14), 826, y, 1)
        lurek.render.print(short(row.merchant, 24), 944, y, 1)
        set((tonumber(row.signed_amount) or 0) < 0 and C.COLORS.red or C.COLORS.green)
        lurek.render.print(money(row.signed_amount), 1120, y, 1)
        y = y + 22
    end
end

local function draw_payments(ctx)
    local C = ctx.C
    panel(C, 24, 116, 520, 260, "Payment method mix")
    ctx.Charts.payment_mix(ctx.view.payment or {}, 44, 154, 480, 190, C)
    panel(C, 566, 116, 666, 260, "Recurring merchant chart")
    ctx.Charts.bars(ctx.view.recurring or {}, 586, 154, 626, 190, "label", "value", C, 8)
    panel(C, 24, 400, 1208, 226, "Cashflow line")
    ctx.Charts.line(ctx.view.monthly or {}, 44, 434, 1168, 160, { "expense", "debt", "essential" }, { C.COLORS.red, C.COLORS.amber, C.COLORS.violet })
end

local function draw_anomalies(ctx)
    local C = ctx.C
    panel(C, 24, 116, 570, 510, "Anomaly scatter")
    local rows = ctx.view.anomalies or {}
    local max_amount = 1
    for _, row in ipairs(rows) do max_amount = math.max(max_amount, tonumber(row.amount_abs) or 0) end
    set(C.COLORS.panel2)
    lurek.render.rectangle("fill", 48, 152, 512, 220, 4, 4)
    for _, row in ipairs(rows) do
        local mx = tonumber(row.month) or 1
        local yr = tonumber(row.year) or ctx.C.YEAR_MIN
        local px = 58 + (((yr - ctx.C.YEAR_MIN) * 12 + mx - 1) / 59) * 492
        local py = 358 - ((tonumber(row.amount_abs) or 0) / max_amount) * 188
        set((row.anomaly_severity == "high") and C.COLORS.red or C.COLORS.amber)
        lurek.render.circle("fill", px, py, 3)
    end
    local selected = rows[ctx.state.selected_anomaly] or rows[1]
    set(C.COLORS.muted)
    lurek.render.print("Selected", 48, 398, 1)
    if selected then
        set(C.COLORS.text)
        lurek.render.print(short(selected.anomaly_issue, 28), 48, 420, 1)
        lurek.render.print(short((selected.date or "") .. " " .. (selected.merchant or ""), 48), 48, 442, 1)
        lurek.render.print(short((selected.member_clean or "") .. " / " .. (selected.category_clean or ""), 48), 48, 464, 1)
        lurek.render.print("Score " .. tostring(selected.anomaly_score or 0) .. "  " .. money(selected.amount_abs), 48, 486, 1)
    end

    panel(C, 618, 116, 614, 510, "Anomaly list")
    local y = 146
    for index = 1, math.min(18, #rows) do
        local row = rows[index]
        if index == ctx.state.selected_anomaly then
            set(C.COLORS.panel2)
            lurek.render.rectangle("fill", 630, y - 3, 580, 20, 3, 3)
        end
        set(row.anomaly_severity == "high" and C.COLORS.red or C.COLORS.amber)
        lurek.render.print(short(row.anomaly_issue, 20), 638, y, 1)
        set(C.COLORS.text)
        lurek.render.print(short(row.date, 10), 800, y, 1)
        lurek.render.print(short(row.merchant, 22), 888, y, 1)
        set(C.COLORS.muted)
        lurek.render.print(money(row.amount_abs), 1076, y, 1)
        y = y + 24
    end
end

local function draw_transactions(ctx)
    local C = ctx.C
    panel(C, 24, 116, 1208, 510, "Transaction table")
    local y = 142
    set(C.COLORS.muted)
    lurek.render.print("Date", 42, y, 1)
    lurek.render.print("Member", 132, y, 1)
    lurek.render.print("Category", 226, y, 1)
    lurek.render.print("Merchant", 356, y, 1)
    lurek.render.print("Method", 750, y, 1)
    lurek.render.print("Amount", 1088, y, 1)
    y = y + 24
    for index = 1, math.min(24, #(ctx.view.recent or {})) do
        local row = ctx.view.recent[index]
        if index == ctx.state.selected_transaction then
            set(C.COLORS.panel2)
            lurek.render.rectangle("fill", 36, y - 3, 1176, 18, 3, 3)
        end
        set(C.COLORS.text)
        lurek.render.print(short(row.date, 10), 42, y, 1)
        lurek.render.print(short(row.member_clean, 11), 132, y, 1)
        lurek.render.print(short(row.category_clean, 14), 226, y, 1)
        lurek.render.print(short(row.merchant, 42), 356, y, 1)
        lurek.render.print(short(row.payment_method, 14), 750, y, 1)
        set((tonumber(row.signed_amount) or 0) < 0 and C.COLORS.red or C.COLORS.green)
        lurek.render.print(money(row.signed_amount), 1088, y, 1)
        y = y + 20
    end
end

local function draw_logs(ctx)
    local C = ctx.C
    panel(C, 24, 116, 588, 510, "Logs")
    local y = 150
    local start = math.max(1, #ctx.logs - 22 - ctx.state.log_scroll)
    for index = start, math.min(#ctx.logs, start + 22) do
        local row = ctx.logs[index]
        set(row.level == "warn" and C.COLORS.amber or C.COLORS.muted)
        lurek.render.print(short(row.level, 6), 44, y, 1)
        set(C.COLORS.text)
        lurek.render.print(short(row.message, 66), 96, y, 1)
        y = y + 20
    end

    panel(C, 634, 116, 598, 250, "SQL/API status")
    y = 150
    for index = math.max(1, #ctx.api_status - 9), #ctx.api_status do
        local item = ctx.api_status[index]
        if item then
            set(item.ok and C.COLORS.green or C.COLORS.red)
            lurek.render.print(item.ok and "OK" or "ERR", 654, y, 1)
            set(C.COLORS.text)
            lurek.render.print(short(item.name, 34), 690, y, 1)
            set(C.COLORS.muted)
            lurek.render.print(tostring(item.rows or 0) .. " rows", 1054, y, 1)
            y = y + 20
        end
    end

    panel(C, 634, 388, 598, 238, "Test status")
    y = 422
    local lines = ctx.test_report_lines or { "No report loaded" }
    for index = 1, math.min(8, #lines) do
        set(C.COLORS.text)
        lurek.render.print(short(lines[index], 72), 654, y, 1)
        y = y + 22
    end
end

function UIRender.setup(ctx)
    ctx.fonts = {
        small = lurek.render.getDefaultFont(10),
        title = lurek.render.getDefaultFont(14),
    }
    ctx.render_scale = 1
    ctx.render_offset_x = 0
    ctx.render_offset_y = 0
    ctx.viewport_width = ctx.C.WIDTH
    ctx.viewport_height = ctx.C.HEIGHT
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
    local scale = math.min(width / C.WIDTH, height / C.HEIGHT)
    if scale <= 0 then scale = 1 end
    ctx.viewport_width = width
    ctx.viewport_height = height
    ctx.render_scale = scale
    ctx.render_offset_x = math.floor((width - C.WIDTH * scale) * 0.5)
    ctx.render_offset_y = math.floor((height - C.HEIGHT * scale) * 0.5)
end

function UIRender.draw(ctx)
    local C = ctx.C
    UIRender.update_viewport(ctx)
    lurek.render.clear(C.COLORS.bg[1], C.COLORS.bg[2], C.COLORS.bg[3])
    lurek.render.push()
    lurek.render.translate(ctx.render_offset_x or 0, ctx.render_offset_y or 0)
    lurek.render.scale(ctx.render_scale or 1, ctx.render_scale or 1)
    if ctx.fonts.small then lurek.render.setFont(ctx.fonts.small) end
    draw_header(ctx)
    if ctx.state.active_tab == 1 then
        draw_widgets(ctx)
    elseif ctx.state.active_tab == 2 then
        draw_cashflow(ctx)
    elseif ctx.state.active_tab == 3 then
        draw_categories(ctx)
    elseif ctx.state.active_tab == 4 then
        draw_members(ctx)
    elseif ctx.state.active_tab == 5 then
        draw_payments(ctx)
    elseif ctx.state.active_tab == 6 then
        draw_anomalies(ctx)
    elseif ctx.state.active_tab == 7 then
        draw_transactions(ctx)
    else
        draw_logs(ctx)
    end
    set(C.COLORS.panel2)
    lurek.render.rectangle("fill", 0, 684, C.WIDTH, 36)
    set(C.COLORS.muted)
    lurek.render.print(short(ctx.state.status or "Ready", 84), 16, 696, 1)
    lurek.render.print(short(ctx.state.last_action or "", 38), 780, 696, 1)
    lurek.render.print(short(ctx.C.SCREENSHOT_PATH, 42), 1000, 696, 1)
    lurek.render.pop()
end

return UIRender