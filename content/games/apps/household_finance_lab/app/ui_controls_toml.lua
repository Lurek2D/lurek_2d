local Controls = {}

local LAYOUT_PATH = "layouts/household_finance_lab_ui.toml"

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

local function short(text, max_len)
    text = tostring(text or "")
    if #text <= max_len then return text end
    return string.sub(text, 1, math.max(1, max_len - 1)) .. "."
end

local function index_of(values, target)
    for index, value in ipairs(values or {}) do
        if value == target then return index end
    end
    return 1
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

local function add_items(combo, values)
    if not combo then return end
    combo:clearItems()
    for _, value in ipairs(values or {}) do
        combo:addItem(tostring(value))
    end
end

local function ensure_status_sections(status)
    if not status then return end
    local section_count = status:getSectionCount()
    if section_count == 0 then
        status:addSection("source", 180)
        status:addSection("rows", 220)
        status:addSection("refresh", 180)
        status:addSection("view", 620)
    end
end

local function ensure_table_columns(tbl, columns)
    if not tbl then return end
    if tbl:getColumnCount() ~= 0 then return end
    for _, column in ipairs(columns) do
        tbl:addColumn(column[1], column[2])
    end
end

local function root_find(root, id)
    if not root then return nil end
    local found = root:findById(id)
    if found == nil then return nil end
    return found
end

local function load_layout(ctx)
    lurek.ui.clear()
    lurek.ui.loadLayoutGameFile(LAYOUT_PATH)
end

local function ensure_tabs(tabs, names)
    if not tabs then return end
    local existing = tabs:getTabCount()
    for i = existing, 1, -1 do
        tabs:removeTab(i)
    end
    for _, name in ipairs(names or {}) do
        tabs:addTab(name)
    end
end

local function bind_callbacks(ctx)
    local w = ctx.widgets
    if not w then return end

    if w.tabs then
        w.tabs:setOnChange(function()
            ctx.needs_refresh = true
            Controls.update_visibility(ctx)
        end)
    end

    if w.member then w.member:setOnChange(function() ctx.needs_refresh = true end) end
    if w.category then w.category:setOnChange(function() ctx.needs_refresh = true end) end
    if w.start_year then w.start_year:setOnChange(function() ctx.needs_refresh = true end) end
    if w.end_year then w.end_year:setOnChange(function() ctx.needs_refresh = true end) end
    if w.cleaned then w.cleaned:setOnChange(function() ctx.needs_refresh = true end) end
    if w.threshold then w.threshold:setOnChange(function() ctx.needs_refresh = true end) end

    if w.regenerate then
        w.regenerate:setOnClick(function()
            if ctx.actions and ctx.actions.regenerate then ctx.actions.regenerate() end
        end)
    end
    if w.reload then
        w.reload:setOnClick(function()
            if ctx.actions and ctx.actions.reload_cache then ctx.actions.reload_cache() end
        end)
    end
    if w.save then
        w.save:setOnClick(function()
            if ctx.actions and ctx.actions.save_state then ctx.actions.save_state() end
        end)
    end
    if w.screenshot then
        w.screenshot:setOnClick(function()
            if ctx.actions and ctx.actions.screenshot then ctx.actions.screenshot() end
        end)
    end
end

local function tune_widget_spacing(w)
    -- Keep native theme defaults for all widgets.
    local _ = w
end

function Controls.setup(ctx)
    lurek.ui.setDefaultTheme()
    load_layout(ctx)

    local root = lurek.ui.getRoot()
    local widgets = {
        root = root,
        title = root_find(root, "title"),
        subtitle = root_find(root, "subtitle"),
        tabs = root_find(root, "tabs"),
        member = root_find(root, "member_combo"),
        category = root_find(root, "category_combo"),
        start_year = root_find(root, "year_from"),
        end_year = root_find(root, "year_to"),
        cleaned = root_find(root, "clean_switch"),
        threshold = root_find(root, "score_threshold"),
        regenerate = root_find(root, "regen_btn"),
        reload = root_find(root, "reload_btn"),
        save = root_find(root, "save_btn"),
        screenshot = root_find(root, "shot_btn"),
        filter_summary = root_find(root, "filter_summary"),
        status = root_find(root, "status"),
        transactions = root_find(root, "transactions_table"),
        api = root_find(root, "api_table"),
        chart_slots = {
            cashflow_tab2 = root_find(root, "slot_cashflow_tab2"),
            monthly_area_tab2 = root_find(root, "slot_monthly_area_tab2"),
            payments_tab2 = root_find(root, "slot_payments_tab2"),
            categories_tab3 = root_find(root, "slot_categories_tab3"),
            members_tab3 = root_find(root, "slot_members_tab3"),
            recurring_tab2 = root_find(root, "slot_recurring_tab2"),
            anomalies_tab6 = root_find(root, "slot_anomalies_tab6"),
            members_tab4 = root_find(root, "slot_members_tab4"),
            payments_tab5 = root_find(root, "slot_payments_tab5"),
            recurring_tab5 = root_find(root, "slot_recurring_tab5"),
            cashflow_tab5 = root_find(root, "slot_cashflow_tab5"),
        },
        labels = {
            member = root_find(root, "member_label"),
            category = root_find(root, "category_label"),
            from = root_find(root, "from_label"),
            to = root_find(root, "to_label"),
            clean = root_find(root, "clean_label"),
            score = root_find(root, "score_label"),
        },
    }

    ensure_tabs(widgets.tabs, ctx.C.TABS)
    if widgets.tabs then
        widgets.tabs:setActiveTab(1)
        ctx.ui_active_tab = 1
    end

    if widgets.labels then
        if widgets.labels.member then widgets.labels.member:setText("Member") end
        if widgets.labels.category then widgets.labels.category:setText("Category") end
        if widgets.labels.from then widgets.labels.from:setText("From") end
        if widgets.labels.to then widgets.labels.to:setText("To") end
        if widgets.labels.clean then widgets.labels.clean:setText("Clean") end
        if widgets.labels.score then widgets.labels.score:setText("Score") end
    end

    add_items(widgets.member, ctx.C.MEMBERS)
    if widgets.member then widgets.member:setSelectedIndex(1) end

    add_items(widgets.category, ctx.C.CATEGORIES)
    if widgets.category then widgets.category:setSelectedIndex(1) end

    if widgets.start_year then
        widgets.start_year:setStep(1)
        widgets.start_year:setValue(ctx.C.YEAR_MIN)
    end
    if widgets.end_year then
        widgets.end_year:setStep(1)
        widgets.end_year:setValue(ctx.C.YEAR_MAX)
    end
    if widgets.threshold then
        widgets.threshold:setStep(5)
        widgets.threshold:setValue(30)
    end
    if widgets.regenerate then widgets.regenerate:setText("Run") end
    if widgets.reload then widgets.reload:setText("Load") end
    if widgets.save then widgets.save:setText("Save") end
    if widgets.screenshot then widgets.screenshot:setText("Shot") end

    ensure_status_sections(widgets.status)
    ensure_table_columns(widgets.transactions, {
        { "Date", 120 },
        { "Member", 110 },
        { "Category", 140 },
        { "Merchant", 360 },
        { "Method", 120 },
        { "Amount", 140 },
        { "Issue", 140 },
    })
    ensure_table_columns(widgets.api, {
        { "Key", 110 },
        { "Value", 170 },
        { "API", 110 },
    })

    if ctx.fonts and ctx.fonts.table then
        if widgets.transactions then widgets.transactions:setFont(ctx.fonts.table) end
        if widgets.api then widgets.api:setFont(ctx.fonts.table) end
    end

    ctx.widgets = widgets
    tune_widget_spacing(widgets)
    bind_callbacks(ctx)
    ctx.filters = Controls.read_filters(ctx)
    Controls.update_visibility(ctx)
end

function Controls.relayout(ctx, width, height)
    local w = math.max(1200, math.floor(tonumber(width) or 1200))
    local h = math.max(800, math.floor(tonumber(height) or 800))
    ctx.layout_width = w
    ctx.layout_height = h
    lurek.ui.setViewport(w, h)
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
    if snapshot.active_tab and w.tabs then
        local clamped_tab = clamp(snapshot.active_tab, 1, #ctx.C.TABS)
        w.tabs:setActiveTab(clamped_tab)
        ctx.ui_active_tab = clamped_tab
    end
    if snapshot.member and w.member then w.member:setSelectedIndex(index_of(ctx.C.MEMBERS, snapshot.member)) end
    if snapshot.category and w.category then w.category:setSelectedIndex(index_of(ctx.C.CATEGORIES, snapshot.category)) end
    if snapshot.start_year and w.start_year then w.start_year:setValue(clamp(snapshot.start_year, ctx.C.YEAR_MIN, ctx.C.YEAR_MAX)) end
    if snapshot.end_year and w.end_year then w.end_year:setValue(clamp(snapshot.end_year, ctx.C.YEAR_MIN, ctx.C.YEAR_MAX)) end
    if snapshot.use_cleaned ~= nil and w.cleaned then w.cleaned:setOn(snapshot.use_cleaned == true) end
    if snapshot.anomaly_threshold and w.threshold then w.threshold:setValue(clamp(snapshot.anomaly_threshold, 0, 100)) end
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

    local active_tab = ctx.ui_active_tab or 1
    if w.tabs then
        local runtime_tab = w.tabs:getActiveTab()
        if runtime_tab ~= nil then
            active_tab = clamp(runtime_tab, 1, #ctx.C.TABS)
            ctx.ui_active_tab = active_tab
        end
    end
    local member = "All"
    if w.member then member = tostring(w.member:getSelectedItem() or "All") end
    local category = "All"
    if w.category then category = tostring(w.category:getSelectedItem() or "All") end
    local start_year = ctx.C.YEAR_MIN
    if w.start_year then start_year = clamp(round(w.start_year:getValue()), ctx.C.YEAR_MIN, ctx.C.YEAR_MAX) end
    local end_year = ctx.C.YEAR_MAX
    if w.end_year then end_year = clamp(round(w.end_year:getValue()), ctx.C.YEAR_MIN, ctx.C.YEAR_MAX) end
    if start_year > end_year then
        end_year = start_year
        if w.end_year then w.end_year:setValue(end_year) end
    end

    return {
        active_tab = active_tab,
        member = member,
        category = category,
        start_year = start_year,
        end_year = end_year,
        use_cleaned = w.cleaned and (w.cleaned:isOn() == true) or true,
        anomaly_threshold = w.threshold and clamp(round(w.threshold:getValue()), 0, 100) or 30,
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
    local w = ctx.widgets
    local active = ctx.filters.active_tab or 1
    if w.transactions then w.transactions:setVisible(active == 7 or active == 8) end
    if w.api then w.api:setVisible(active == 1) end

    local slots = w.chart_slots or {}
    local function vis(slot, on)
        if slot then slot:setVisible(on) end
    end

    vis(slots.cashflow_tab2, active == 2)
    vis(slots.monthly_area_tab2, active == 2)
    vis(slots.payments_tab2, active == 2)
    vis(slots.recurring_tab2, active == 2)

    vis(slots.categories_tab3, active == 3)
    vis(slots.members_tab3, active == 3)

    vis(slots.members_tab4, active == 4)

    vis(slots.payments_tab5, active == 5)
    vis(slots.recurring_tab5, active == 5)
    vis(slots.cashflow_tab5, active == 5)

    vis(slots.anomalies_tab6, active == 6)
end

local function frame_for_active_tab(ctx, active)
    local view = ctx.view or {}
    if active == 7 then return view.recent_frame end
    return nil
end

local function update_transactions(ctx)
    local tbl = ctx.widgets and ctx.widgets.transactions
    if not tbl then return end
    local active = (ctx.filters and ctx.filters.active_tab) or 1
    local frame = frame_for_active_tab(ctx, active)
    if frame then
        local version = string.format("%s:%s", tostring(active), tostring(ctx.view_version or 0))
        if ctx.transactions_widget_version == version then return end
        tbl:setDataFrame(frame)
        ctx.transactions_widget_version = version
        return
    end

    if active == 8 then
        local version = string.format("logs:%s", tostring(#(ctx.logs or {})))
        if ctx.transactions_widget_version == version then return end
        local rows = {}
        local logs = ctx.logs or {}
        local start = math.max(1, #logs - 24)
        for i = start, #logs do
            local row = logs[i]
            if row then
                rows[#rows + 1] = {
                    tostring(i),
                    tostring(row.level or "info"),
                    tostring(row.message or ""),
                    "",
                    "",
                    "",
                    "",
                }
            end
        end
        tbl:setRows(rows)
        ctx.transactions_widget_version = version
        return
    end

    if active ~= 1 then
        local version = string.format("empty:%s", tostring(active))
        if ctx.transactions_widget_version == version then return end
        tbl:clearRows()
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
        { "df methods", tostring(method_count), "LDataFrame" },
        { "chart imgs", tostring(ctx.chart_count or 0), "DF charts" },
        { "frame", string.format("%.2f ms", tonumber(perf.frame_ms) or 0), "getFrameProfile" },
        { "render", string.format("%.2f ms", tonumber(perf.render_ms) or 0), "getStats" },
        { "refresh", string.format("%.2f ms", tonumber(ctx.refresh_ms) or 0), "SQL refresh" },
        { "test", short(report, 36), "GameFS" },
        { "save slot", ctx.C.SAVE_SLOT, "lurek.save" },
    }
    tbl:setRows(rows)
end

function Controls.update_widgets(ctx)
    if not ctx.widgets then return end
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
        ), 64))
    end

    if ctx.widgets.status then
        ensure_status_sections(ctx.widgets.status)
        ctx.widgets.status:setSectionText(1, "src " .. status_source(ctx.source))
        ctx.widgets.status:setSectionText(2, string.format("rows %s/%s", tostring(ctx.clean_count or 0), tostring(ctx.row_count or 0)))
        ctx.widgets.status:setSectionText(3, "sql " .. ms(ctx.refresh_ms))
        ctx.widgets.status:setSectionText(4, string.format("%s | %s/%s", short(ctx.C.TABS[filters.active_tab] or "view", 12), short(filters.member or "All", 10), short(filters.category or "All", 12)))
    end

    update_transactions(ctx)
    update_api_table(ctx)
    Controls.update_visibility(ctx)
end

return Controls
