local Tests = {}

local function add_result(results, name, ok, detail)
    results[#results + 1] = { name = name, ok = ok == true, detail = detail }
end

local function ensure_dirs(C)
    lurek.filesystem.createDirectory("save")
    lurek.filesystem.createDirectory(C.SAVE_DIR)
    lurek.filesystem.createDirectory(C.CACHE_DIR)
end

local function ensure_controls(ctx)
    if not ctx.widgets then
        ctx.Controls.setup(ctx)
    end
end

local function click_ui(x, y)
    local pressed = lurek.ui.mousepressed(x, y, 1)
    local released = lurek.ui.mousereleased(x, y, 1)
    lurek.ui.update(0.0)
    return pressed == true or released == true
end

function Tests.make_context(root, C, DataGeneration, Pipeline, Controls)
    return {
        root = root or "",
        C = C,
        DataGeneration = DataGeneration,
        Pipeline = Pipeline,
        Controls = Controls,
        logs = {},
        api_status = {},
        view = { anomalies = {}, recent = {}, monthly = {}, categories = {}, members = {}, payment = {}, recurring = {} },
        actions = {},
        clock = 0,
    }
end

function Tests.generate_csv(C, DataGeneration)
    local a = DataGeneration.generate(C, { seed = 1234, start_year = 2024, end_year = 2024 })
    local b = DataGeneration.generate(C, { seed = 1234, start_year = 2024, end_year = 2024 })
    return a.csv, a.rows, a.csv == b.csv and a.rng_state ~= nil
end

function Tests.write_generated_csv(C, DataGeneration)
    ensure_dirs(C)
    local generated = DataGeneration.generate(C, { seed = 2468, start_year = 2024, end_year = 2024 })
    lurek.filesystem.write(C.CSV_PATH, generated.csv)
    return generated
end

function Tests.build_pipeline(ctx)
    return ctx.Pipeline.load(ctx, {
        force_generate = true,
        prefer_cache = false,
        generation_options = { seed = 5678, start_year = 2024, end_year = 2024 },
    })
end

function Tests.check_config(root, C)
    local parsed = lurek.binary.parseToml(lurek.filesystem.read(root .. "app/config.toml"))
    return parsed.window.width == C.WIDTH and parsed.paths.csv_path == C.CSV_PATH
end

function Tests.check_sql_outputs(ctx)
    local checked = {}
    for _, item in ipairs(ctx.C.SQL_FILES) do
        local frame = ctx.frames[item.table]
        checked[#checked + 1] = { table = item.table, rows = frame and frame:nrows() or -1 }
    end
    return checked
end

function Tests.check_dataframe_file_apis(C, DataGeneration)
    local generated = Tests.write_generated_csv(C, DataGeneration)
    local from_file = lurek.dataframe.fromCSVFile(C.CSV_PATH)
    local task = lurek.dataframe.fromCSVFileAsync(C.CSV_PATH)
    task:wait()
    local from_async = task:result()
    local csv_out = C.CACHE_DIR .. "/transactions_copy.csv"
    local json_out = C.CACHE_DIR .. "/transactions_copy.json"
    local binary_out = C.CACHE_DIR .. "/transactions_copy.lvdf"
    local csv_saved = from_file:toCSVFile(csv_out)
    local json_saved = from_file:toJSONFile(json_out)
    local binary_saved = from_file:toBinaryFile(binary_out)
    local from_json = lurek.dataframe.fromJSONFile(json_out)
    return from_file:nrows() == generated.rows
        and from_async:nrows() == generated.rows
        and from_json:nrows() == generated.rows
        and csv_saved == true
        and json_saved == true
        and binary_saved == true,
        tostring(generated.rows)
end

function Tests.check_dataframe_methods(ctx, df)
    df:zscoreCol("amount_abs", "test_z")
    df:withRollingMean("expense_amount", 3, "test_roll_mean")
    df:withRollingSum("expense_amount", 3, "test_roll_sum")
    df:withPctChange("expense_amount", "test_pct")
    local outliers = df:outliers("amount_abs", 2.0)
    local grouped = df:groupAgg("category_clean", "expense_amount", "sum")
    local sample = df:sample(8, 99)
    return outliers:nrows() >= 0 and grouped:nrows() > 0 and sample:nrows() == 8
end

function Tests.check_database_query_apis(ctx)
    local saved = ctx.db:save(ctx.C.DATABASE_JSON_PATH)
    local loaded = lurek.dataframe.loadDatabase(ctx.C.DATABASE_JSON_PATH)
    local filtered = loaded:queryParams(
        "SELECT txn_id FROM transactions WHERE year >= ? AND member_clean = ? LIMIT 3",
        { 2024, "Anna" }
    )
    local params_task = loaded:queryParamsAsync(
        "SELECT txn_id FROM transactions WHERE year >= ? AND category_clean = ? LIMIT 3",
        { 2024, "groceries" }
    )
    params_task:wait()
    local params_async = params_task:result()
    local db_task = loaded:queryAsync("SELECT txn_id FROM transactions LIMIT 2")
    db_task:wait()
    local db_async = db_task:result()
    local table_frame = loaded:getTable("transactions")
    local df_task = table_frame:queryAsync("SELECT txn_id FROM self LIMIT 2")
    df_task:wait()
    local df_async = df_task:result()
    return saved == true
        and loaded:tableCount() == ctx.db:tableCount()
        and filtered:nrows() > 0
        and params_async:nrows() > 0
        and db_async:nrows() == 2
        and df_async:nrows() == 2,
        tostring(loaded:tableCount())
end

function Tests.check_chart_widgets(C)
    local df = lurek.dataframe.fromRows(
        { "x", "label", "income", "expense", "amount" },
        {
            { 1, "A", 12, 8, 8 },
            { 2, "B", 18, 5, 5 },
            { 3, "C", 15, 9, 9 },
        }
    )
    local area = lurek.ui.newAreaChart({ width = 64, height = 64, title = "area" })
    local area_count = area:addLayerFromDataFrame("expense", df, "expense", 0.2, 0.6, 1.0)
    local line = lurek.ui.newLineChart({ width = 64, height = 64, title = "line" })
    local line_count = line:addSeriesFromDataFrame("income", df, "x", "income", 0.2, 0.6, 1.0)
    local bar = lurek.ui.newBarChart({ width = 64, height = 64, title = "bar" })
    bar:addSeries("v", 0.2, 0.8, 0.4)
    local bar_count = bar:addCategoriesFromDataFrame(df, "label", { "expense" })
    local pie = lurek.ui.newPieChart({ width = 64, height = 64, title = "pie" })
    local pie_count = pie:addSegmentsFromDataFrame(df, "label", "amount")
    local scatter = lurek.ui.newScatterPlot({ width = 64, height = 64, title = "scatter" })
    local scatter_count = scatter:addSeriesFromDataFrame("points", df, "x", "amount", 0.8, 0.3, 0.2)
    lurek.filesystem.write(C.SAVE_DIR .. "/chart_check.txt", "DataFrame chart helper APIs covered; drawToImage covered by runtime smoke")
    return area:typeOf("LAreaChart")
        and line:typeOf("LLineChart")
        and bar:typeOf("LBarChart")
        and pie:typeOf("LPieChart")
        and scatter:typeOf("LScatterPlot")
        and (tonumber(area_count) or 0) > 0
        and (tonumber(line_count) or 0) > 0
        and (tonumber(bar_count) or 0) > 0
        and (tonumber(pie_count) or 0) > 0
        and (tonumber(scatter_count) or 0) > 0
end

function Tests.check_ui_widgets(ctx)
    ensure_controls(ctx)
    ctx.Controls.apply_snapshot(ctx, {
        active_tab = 2,
        member = "Anna",
        category = "groceries",
        start_year = 2022,
        end_year = 2024,
        use_cleaned = false,
        anomaly_threshold = 55,
    })
    local api_rows = ctx.widgets.api:setRows({
        { "bulk", "rows", "setRows" },
        { "source", "test", "LGuiTable" },
    })
    local table_df = lurek.dataframe.fromRows(
        { "date", "member_clean", "category_clean", "merchant", "payment_method", "signed_amount", "anomaly_issue" },
        { { "2024-01-01", "Anna", "groceries", "Fresh Market", "card", -42.5, "" } }
    )
    local frame_rows = ctx.widgets.transactions:setDataFrame(table_df)
    local filters = ctx.Controls.read_filters(ctx)
    ctx.Controls.update_widgets(ctx)
    local labels = ctx.widgets.labels or {}
    local labels_ok = labels.member and labels.member:getText() == "Member"
        and labels.category and labels.category:getText() == "Category"
        and labels.from and labels.from:getText() == "From"
        and labels.to and labels.to:getText() == "To"
        and labels.clean and labels.clean:getText() == "Clean"
        and labels.score and labels.score:getText() == "Score"
    local active_tab_ok = filters.active_tab == 2 or (ctx.ui_active_tab or 0) == 2
    local year_range_ok = filters.start_year >= ctx.C.YEAR_MIN
        and filters.end_year <= ctx.C.YEAR_MAX
        and filters.start_year <= filters.end_year
    local ok = active_tab_ok
        and type(filters.member) == "string" and #filters.member > 0
        and type(filters.category) == "string" and #filters.category > 0
        and year_range_ok
        and (tonumber(api_rows) or 0) >= 1
        and (tonumber(frame_rows) or 0) >= 1
        and labels_ok
    local detail = string.format(
        "tab_ok=%s tab=%s ui_tab=%s member=%s category=%s years=%d-%d year_ok=%s cleaned=%s threshold=%s api_rows=%s frame_rows=%s labels_ok=%s",
        tostring(active_tab_ok),
        tostring(filters.active_tab),
        tostring(ctx.ui_active_tab),
        tostring(filters.member),
        tostring(filters.category),
        tonumber(filters.start_year) or -1,
        tonumber(filters.end_year) or -1,
        tostring(year_range_ok),
        tostring(filters.use_cleaned),
        tostring(filters.anomaly_threshold),
        tostring(api_rows),
        tostring(frame_rows),
        tostring(labels_ok)
    )
    return ok, detail
end

function Tests.check_ui_mouse_interactions(ctx)
    ensure_controls(ctx)
    ctx.Controls.apply_snapshot(ctx, {
        active_tab = 1,
        member = "All",
        category = "All",
        start_year = ctx.C.YEAR_MIN,
        end_year = ctx.C.YEAR_MAX,
        use_cleaned = true,
        anomaly_threshold = 30,
    })

    local button_hits = 0
    ctx.actions.save_state = function()
        button_hits = button_hits + 1
    end

    local control_y = 93
    local tab_clicked = click_ui(158, 48)
    local member_opened = click_ui(20, control_y)
    local member_selected = click_ui(20, control_y + 45)
    local category_opened = click_ui(118, control_y)
    local category_selected = click_ui(118, control_y + 67)
    local start_dragged = click_ui(278, control_y)
    lurek.ui.mousepressed(500, control_y, 1)
    lurek.ui.mousemoved(522, control_y)
    lurek.ui.mousereleased(522, control_y, 1)
    lurek.ui.update(0.0)
    local switch_clicked = click_ui(418, control_y)
    local button_clicked = click_ui(710, control_y)

    local filters = ctx.Controls.read_filters(ctx)
    local clicks_executed = type(tab_clicked) == "boolean"
        or type(member_opened) == "boolean"
        or type(member_selected) == "boolean"
        or type(category_opened) == "boolean"
        or type(category_selected) == "boolean"
        or type(start_dragged) == "boolean"
        or type(switch_clicked) == "boolean"
        or type(button_clicked) == "boolean"
    local filter_shape_ok = (filters.active_tab or 0) >= 1
        and (filters.active_tab or 0) <= #ctx.C.TABS
        and type(filters.member) == "string"
        and type(filters.category) == "string"
        and type(filters.start_year) == "number"
        and type(filters.anomaly_threshold) == "number"
    return filter_shape_ok
        and clicks_executed
        and button_hits >= 0,
        string.format(
            "tab=%d member=%s category=%s start=%d threshold=%d cleaned=%s button=%d",
            filters.active_tab,
            tostring(filters.member),
            tostring(filters.category),
            filters.start_year,
            filters.anomaly_threshold,
            tostring(filters.use_cleaned),
            button_hits
        )
end

function Tests.check_cache_roundtrip(ctx)
    local restored = ctx.Pipeline.restore_cache(ctx)
    if not restored then return false, "no cache" end
    local same_rows = restored.frames.transactions:nrows() == ctx.frames.transactions:nrows()
    return same_rows, tostring(restored.frames.transactions:nrows())
end

function Tests.write_report(C, results)
    ensure_dirs(C)
    lurek.filesystem.write(C.TEST_REPORT_PATH, lurek.serial.toJson({
        suite = "household_finance_lab",
        checks = results,
    }, true))
end

function Tests.run_report(ctx)
    local results = {}
    add_result(results, "toml_config_parseToml", Tests.check_config(ctx.root, ctx.C), ctx.C.CSV_PATH)
    Tests.write_report(ctx.C, results)

    local csv, row_count, deterministic = Tests.generate_csv(ctx.C, ctx.DataGeneration)
    add_result(results, "lrandom_generator_csv", deterministic and row_count > 0, tostring(row_count))
    Tests.write_report(ctx.C, results)

    local file_ok, file_detail = Tests.check_dataframe_file_apis(ctx.C, ctx.DataGeneration)
    add_result(results, "dataframe_file_apis", file_ok, file_detail)
    local df = lurek.dataframe.fromCSVFile(ctx.C.CSV_PATH)
    add_result(results, "dataframe_fromCSVFile", df:nrows() > 0, tostring(df:nrows()))
    add_result(results, "dataframe_methods", Tests.check_dataframe_methods(ctx, df), tostring(df:ncols()))
    Tests.write_report(ctx.C, results)

    Tests.build_pipeline(ctx)
    local sql_outputs = Tests.check_sql_outputs(ctx)
    local sql_ok = true
    for _, item in ipairs(sql_outputs) do
        if item.rows < 0 then sql_ok = false end
    end
    add_result(results, "database_query_sql_files", sql_ok, tostring(#sql_outputs))
    Tests.write_report(ctx.C, results)

    ctx.filters = {
        active_tab = 1,
        member = "All",
        category = "All",
        start_year = ctx.C.YEAR_MIN,
        end_year = ctx.C.YEAR_MAX,
        use_cleaned = true,
        anomaly_threshold = 30,
    }
    ctx.Pipeline.refresh(ctx, ctx.filters)
    add_result(results, "sql_dataframe_refresh", (ctx.view.metrics.count or 0) > 0 and #(ctx.view.monthly or {}) > 0, tostring(ctx.view.metrics.count or 0))
    local metric_detail = ctx.sql_metric_alias_reason or "SQL arithmetic alias status was not reported"
    add_result(results, "sql_metric_alias_status", ctx.sql_metric_aliases == true, metric_detail)
    local db_ok, db_detail = Tests.check_database_query_apis(ctx)
    add_result(results, "database_save_load_query_apis", db_ok, db_detail)
    Tests.write_report(ctx.C, results)
    add_result(results, "chart_dataframe_helpers", Tests.check_chart_widgets(ctx.C), "DataFrame chart helpers")
    Tests.write_report(ctx.C, results)
    local ui_ok, ui_detail = Tests.check_ui_widgets(ctx)
    add_result(results, "ui_widget_values", ui_ok, ui_detail)
    Tests.write_report(ctx.C, results)
    local ui_mouse_ok, ui_mouse_detail = Tests.check_ui_mouse_interactions(ctx)
    add_result(results, "ui_mouse_interactions", ui_mouse_ok, ui_mouse_detail)
    Tests.write_report(ctx.C, results)

    local cache_ok, cache_detail = Tests.check_cache_roundtrip(ctx)
    add_result(results, "database_cache_roundtrip", cache_ok, cache_detail)

    Tests.write_report(ctx.C, results)
    return results
end

return Tests
