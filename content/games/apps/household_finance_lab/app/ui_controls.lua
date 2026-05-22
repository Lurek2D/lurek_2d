local Controls = {}

local function clamp(value, min_value, max_value)
    value = tonumber(value) or min_value
    if value < min_value then return min_value end
    if value > max_value then return max_value end
    return value
end

local function round(value)
    return math.floor((tonumber(value) or 0) + 0.5)
end

local function ms(value)
    return string.format("%.0f ms", tonumber(value) or 0)
end

local function index_of(values, target)
    for index, value in ipairs(values or {}) do
        if value == target then return index end
    end
    return 1
end

local function short(text, max_len)
    text = tostring(text or "")
    if #text <= max_len then return text end
    return string.sub(text, 1, math.max(1, max_len - 1)) .. "."
end

local function add_items(combo, values)
    for _, value in ipairs(values or {}) do
        combo:addItem(tostring(value))
    end
end

local function place(widget, x, y, w, h)
    widget:setPosition(x, y)
    widget:setSize(w, h)
    return widget
end

local LABEL_Y = 62
local CONTROL_Y = 80
local SUMMARY_Y = 110

local function make_label(text, x, y, w)
    return place(lurek.ui.newLabel(text), x, y, w, 12)
end

local function make_button(ctx, label, x, y, w, action_name)
    local button = place(lurek.ui.newButton(label), x, y, w, 22)
    button:setOnClick(function()
        if ctx.actions and ctx.actions[action_name] then
            ctx.actions[action_name]()
        else
            ctx.needs_refresh = true
        end
    end)
    return button
end

local function ensure_status_sections(status)
    if status:getSectionCount() == 0 then
        status:addSection("source", 120)
        status:addSection("rows", 120)
        status:addSection("refresh", 120)
        status:addSection("view", 440)
    end
end

local function status_source(source)
    source = tostring(source or "ready")
    local known = {
        ["database cache"] = "cache",
        ["generated csv"] = "generated",
        ["csv file"] = "csv",
        ["restored save"] = "save",
    }
    return short(known[source] or source, 10)
end

local function ensure_table_rows(tbl, count, columns)
    if tbl:getColumnCount() == 0 then
        for _, column in ipairs(columns) do
            tbl:addColumn(column[1], column[2])
        end
    end
    while tbl:getRowCount() < count do
        local row = {}
        for _ = 1, #columns do row[#row + 1] = "" end
        tbl:addRow(row)
    end
end

function Controls.setup(ctx)
    lurek.ui.setDefaultTheme()
    lurek.ui.setViewport(ctx.C.WIDTH, ctx.C.HEIGHT)

    local root = lurek.ui.getRoot()
    local widgets = {}
    widgets.tabs = place(lurek.ui.newTabBar(), 12, 36, 776, 20)
    for _, label in ipairs(ctx.C.TABS) do widgets.tabs:addTab(label) end
    widgets.tabs:setActiveTab(1)
    widgets.tabs:setOnChange(function()
        ctx.needs_refresh = true
    end)

    widgets.labels = {
        member = make_label("Member", 12, LABEL_Y, 88),
        category = make_label("Category", 108, LABEL_Y, 104),
        from = make_label("From", 220, LABEL_Y, 78),
        to = make_label("To", 306, LABEL_Y, 78),
        clean = make_label("Clean", 392, LABEL_Y, 54),
        score = make_label("Score", 454, LABEL_Y, 88),
    }

    widgets.member = place(lurek.ui.newComboBox(), 12, CONTROL_Y, 88, 22)
    add_items(widgets.member, ctx.C.MEMBERS)
    widgets.member:setSelectedIndex(1)
    widgets.member:setOnChange(function() ctx.needs_refresh = true end)

    widgets.category = place(lurek.ui.newComboBox(), 108, CONTROL_Y, 104, 22)
    add_items(widgets.category, ctx.C.CATEGORIES)
    widgets.category:setSelectedIndex(1)
    widgets.category:setOnChange(function() ctx.needs_refresh = true end)

    widgets.start_year = place(lurek.ui.newSlider(ctx.C.YEAR_MIN, ctx.C.YEAR_MAX), 220, CONTROL_Y, 78, 22)
    widgets.start_year:setStep(1)
    widgets.start_year:setValue(ctx.C.YEAR_MIN)
    widgets.start_year:setOnChange(function() ctx.needs_refresh = true end)

    widgets.end_year = place(lurek.ui.newSlider(ctx.C.YEAR_MIN, ctx.C.YEAR_MAX), 306, CONTROL_Y, 78, 22)
    widgets.end_year:setStep(1)
    widgets.end_year:setValue(ctx.C.YEAR_MAX)
    widgets.end_year:setOnChange(function() ctx.needs_refresh = true end)

    widgets.cleaned = place(lurek.ui.newSwitch(true), 392, CONTROL_Y, 54, 22)
    widgets.cleaned:setOnChange(function() ctx.needs_refresh = true end)

    widgets.threshold = place(lurek.ui.newSlider(0, 100), 454, CONTROL_Y, 88, 22)
    widgets.threshold:setStep(5)
    widgets.threshold:setValue(30)
    widgets.threshold:setOnChange(function() ctx.needs_refresh = true end)

    widgets.regenerate = make_button(ctx, "Regen", 552, CONTROL_Y, 70, "regenerate")
    widgets.reload = make_button(ctx, "Reload", 630, CONTROL_Y, 58, "reload_cache")
    widgets.save = make_button(ctx, "Save", 696, CONTROL_Y, 44, "save_state")
    widgets.screenshot = make_button(ctx, "Shot", 748, CONTROL_Y, 40, "screenshot")

    widgets.filter_summary = make_label("All/All 2021-2025 clean >=30", 12, SUMMARY_Y, 776)

    widgets.status = place(lurek.ui.newStatusBar(), 0, 560, ctx.C.WIDTH, 24)
    ensure_status_sections(widgets.status)

    widgets.transactions = place(lurek.ui.newTable(), 16, 156, 768, 390)
    ensure_table_rows(widgets.transactions, 18, {
        { "Date", 70 },
        { "Member", 70 },
        { "Category", 96 },
        { "Merchant", 250 },
        { "Method", 92 },
        { "Amount", 84 },
        { "Issue", 98 },
    })

    widgets.api = place(lurek.ui.newTable(), 526, 134, 262, 422)
    ensure_table_rows(widgets.api, 14, {
        { "Key", 76 },
        { "Value", 104 },
        { "API", 72 },
    })

    local attached = {
        widgets.tabs,
        widgets.member,
        widgets.category,
        widgets.start_year,
        widgets.end_year,
        widgets.cleaned,
        widgets.threshold,
        widgets.regenerate,
        widgets.reload,
        widgets.save,
        widgets.screenshot,
        widgets.labels.member,
        widgets.labels.category,
        widgets.labels.from,
        widgets.labels.to,
        widgets.labels.clean,
        widgets.labels.score,
        widgets.filter_summary,
        widgets.status,
        widgets.transactions,
        widgets.api,
    }
    for _, widget in ipairs(attached) do
        root:addChild(widget)
    end

    ctx.widgets = widgets
    ctx.filters = Controls.read_filters(ctx)
    Controls.update_visibility(ctx)
end

function Controls.snapshot(ctx)
    local filters = Controls.read_filters(ctx)
    return {
        active_tab = filters.active_tab,
        member = filters.member,
        category = filters.category,
        start_year = filters.start_year,
        end_year = filters.end_year,
        use_cleaned = filters.use_cleaned,
        anomaly_threshold = filters.anomaly_threshold,
    }
end

function Controls.apply_snapshot(ctx, snapshot)
    if not ctx.widgets or not snapshot then return end
    local w = ctx.widgets
    if snapshot.active_tab then w.tabs:setActiveTab(clamp(snapshot.active_tab, 1, #ctx.C.TABS)) end
    if snapshot.member then w.member:setSelectedIndex(index_of(ctx.C.MEMBERS, snapshot.member)) end
    if snapshot.category then w.category:setSelectedIndex(index_of(ctx.C.CATEGORIES, snapshot.category)) end
    if snapshot.start_year then w.start_year:setValue(clamp(snapshot.start_year, ctx.C.YEAR_MIN, ctx.C.YEAR_MAX)) end
    if snapshot.end_year then w.end_year:setValue(clamp(snapshot.end_year, ctx.C.YEAR_MIN, ctx.C.YEAR_MAX)) end
    if snapshot.use_cleaned ~= nil then w.cleaned:setOn(snapshot.use_cleaned == true) end
    if snapshot.anomaly_threshold then w.threshold:setValue(clamp(snapshot.anomaly_threshold, 0, 100)) end
    ctx.filters = Controls.read_filters(ctx)
    ctx.needs_refresh = true
end

function Controls.read_filters(ctx)
    local w = ctx.widgets
    if not w then
        return {
            active_tab = 1,
            member = "All",
            category = "All",
            start_year = ctx.C.YEAR_MIN,
            end_year = ctx.C.YEAR_MAX,
            use_cleaned = true,
            anomaly_threshold = 30,
        }
    end
    local start_year = clamp(round(w.start_year:getValue()), ctx.C.YEAR_MIN, ctx.C.YEAR_MAX)
    local end_year = clamp(round(w.end_year:getValue()), ctx.C.YEAR_MIN, ctx.C.YEAR_MAX)
    if start_year > end_year then
        end_year = start_year
        w.end_year:setValue(end_year)
    end
    local member = w.member:getSelectedItem() or "All"
    local category = w.category:getSelectedItem() or "All"
    return {
        active_tab = clamp(w.tabs:getActiveTab(), 1, #ctx.C.TABS),
        member = member,
        category = category,
        start_year = start_year,
        end_year = end_year,
        use_cleaned = w.cleaned:isOn(),
        anomaly_threshold = clamp(round(w.threshold:getValue()), 0, 100),
    }
end

local function filter_key(filters)
    return table.concat({
        tostring(filters.active_tab),
        filters.member,
        filters.category,
        tostring(filters.start_year),
        tostring(filters.end_year),
        tostring(filters.use_cleaned),
        tostring(filters.anomaly_threshold),
    }, "|")
end

function Controls.poll(ctx)
    local filters = Controls.read_filters(ctx)
    local key = filter_key(filters)
    local changed = key ~= ctx.filter_key or ctx.needs_refresh == true
    ctx.filters = filters
    ctx.filter_key = key
    Controls.update_visibility(ctx)
    return changed
end

function Controls.update_visibility(ctx)
    if not ctx.widgets or not ctx.filters then return end
    local active = ctx.filters.active_tab or 1
    ctx.widgets.transactions:setVisible(active == 7)
    ctx.widgets.api:setVisible(false)
end

local function update_transactions(ctx)
    local tbl = ctx.widgets and ctx.widgets.transactions
    if not tbl then return end
    local frame = ctx.view and ctx.view.recent_frame
    if frame then
        local version = tostring(ctx.view_version or 0)
        if ctx.transactions_widget_version == version then return end
        tbl:setDataFrame(frame)
        ctx.transactions_widget_version = version
    else
        if ctx.transactions_widget_version == "empty" then return end
        tbl:clearRows()
        ctx.transactions_widget_version = "empty"
    end
end

local function update_api_table(ctx)
    local tbl = ctx.widgets and ctx.widgets.api
    if not tbl then return end
    local filters = ctx.filters or Controls.read_filters(ctx)
    local report = (ctx.test_report_lines and ctx.test_report_lines[1]) or "no report"
    local method_count = 0
    for _, used in pairs(ctx.dataframe_methods or {}) do
        if used then method_count = method_count + 1 end
    end
    local perf = ctx.perf or {}
    local version = table.concat({
        tostring(ctx.view_version or 0),
        tostring(filters.active_tab or 0),
        tostring(filters.member or ""),
        tostring(filters.category or ""),
        tostring(filters.start_year or ""),
        tostring(filters.end_year or ""),
        tostring(filters.use_cleaned),
        tostring(filters.anomaly_threshold or ""),
        tostring(ctx.chart_count or 0),
        tostring(method_count),
        string.format("%.1f", tonumber(ctx.refresh_ms) or 0),
        string.format("%.1f", tonumber(perf.frame_ms) or 0),
        string.format("%.1f", tonumber(perf.render_ms) or 0),
    }, "|")
    if ctx.api_widget_version == version then return end
    ctx.api_widget_version = version
    local rows = {
        { "tab", ctx.C.TABS[filters.active_tab] or "", "LTabBar" },
        { "member", filters.member, "LComboBox" },
        { "category", filters.category, "LComboBox" },
        { "years", tostring(filters.start_year) .. "-" .. tostring(filters.end_year), "LSlider" },
        { "cleaned", tostring(filters.use_cleaned), "LSwitch" },
        { "threshold", tostring(filters.anomaly_threshold), "LSlider" },
        { "db tables", tostring(ctx.db and ctx.db:tableCount() or 0), "LDatabase" },
        { "sql files", tostring(#(ctx.C.SQL_FILES or {})), "queryParams" },
        { "cache", ctx.C.CACHE_VERSION, "LDatabase:save" },
        { "restore", "database", "loadDatabase" },
        { "dataframe methods", tostring(method_count), "LDataFrame" },
        { "chart images", tostring(ctx.chart_count or 0), "DF charts" },
        { "frame ms", string.format("%.2f", tonumber(perf.frame_ms) or 0), "getFrameProfile" },
        { "render ms", string.format("%.2f", tonumber(perf.render_ms) or 0), "getStats" },
        { "refresh ms", string.format("%.2f", tonumber(ctx.refresh_ms) or 0), "SQL refresh" },
        { "test report", short(report, 36), "GameFS" },
        { "save slot", ctx.C.SAVE_SLOT, "lurek.save" },
    }
    tbl:setRows(rows)
end

function Controls.update_widgets(ctx)
    if not ctx.widgets then return end
    local status = ctx.widgets.status
    ensure_status_sections(status)
    local filters = ctx.filters or Controls.read_filters(ctx)
    if ctx.widgets.filter_summary then
        ctx.widgets.filter_summary:setText(short(string.format(
            "%s/%s %d-%d %s >=%d",
            short(filters.member or "All", 8),
            short(filters.category or "All", 10),
            filters.start_year or ctx.C.YEAR_MIN,
            filters.end_year or ctx.C.YEAR_MAX,
            (filters.use_cleaned == false) and "raw" or "clean",
            filters.anomaly_threshold or 30
        ), 40))
    end
    status:setSectionText(1, "src " .. status_source(ctx.source))
    status:setSectionText(2, string.format("rows %s/%s", tostring(ctx.clean_count or 0), tostring(ctx.row_count or 0)))
    status:setSectionText(3, "sql " .. ms(ctx.refresh_ms))
    status:setSectionText(4, string.format("%s | %s/%s", short(ctx.C.TABS[filters.active_tab] or "view", 12), short(filters.member or "All", 6), short(filters.category or "All", 8)))
    update_transactions(ctx)
    update_api_table(ctx)
    Controls.update_visibility(ctx)
end

return Controls
