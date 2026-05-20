local Tests = {}

local function report_json(results)
    local lines = { "{", "  \"suite\": \"household_finance_lab\",", "  \"checks\": [" }
    for index, item in ipairs(results) do
        if index > 1 then lines[#lines + 1] = "," end
        lines[#lines + 1] = string.format("    {\"name\": \"%s\", \"ok\": %s, \"detail\": \"%s\"}", item.name, item.ok and "true" or "false", tostring(item.detail or ""))
    end
    lines[#lines + 1] = ""
    lines[#lines + 1] = "  ]"
    lines[#lines + 1] = "}"
    return table.concat(lines, "\n")
end

local function add_result(results, name, ok, detail)
    results[#results + 1] = { name = name, ok = ok, detail = detail }
end

function Tests.make_context(root, C, DataGeneration, SQLRunner, Pipeline, Analytics, UIState, Controls)
    local ctx = {
        root = root or "",
        C = C,
        DataGeneration = DataGeneration,
        SQLRunner = SQLRunner,
        Pipeline = Pipeline,
        Analytics = Analytics,
        UIState = UIState,
        Controls = Controls,
        logs = {},
        api_status = {},
        hitboxes = {},
        view = { anomalies = {}, recent = {} },
        actions = {},
    }
    ctx.state = UIState.new(C)
    return ctx
end

function Tests.generate_csv(C, DataGeneration)
    local a = DataGeneration.generate(C, { seed = 1234, start_year = 2024, end_year = 2024 })
    local b = DataGeneration.generate(C, { seed = 1234, start_year = 2024, end_year = 2024 })
    return a.csv, a.rows, a.csv == b.csv
end

function Tests.build_pipeline(ctx)
    local built = ctx.Pipeline.load(ctx, {
        force_generate = true,
        prefer_cache = false,
        generation_options = { seed = 5678, start_year = 2024, end_year = 2024 },
    })
    return built
end

function Tests.check_sql_outputs(ctx)
    local checked = {}
    for _, item in ipairs(ctx.C.SQL_FILES) do
        local frame = ctx.frames[item.table]
        checked[#checked + 1] = { table = item.table, rows = frame and frame:nrows() or 0 }
    end
    return checked
end

function Tests.check_cache_roundtrip(ctx)
    local restored = ctx.Pipeline.restore_cache(ctx)
    if not restored then return false, "no cache" end
    return restored.frames.transactions:nrows() == ctx.frames.transactions:nrows(), tostring(restored.frames.transactions:nrows())
end

function Tests.check_analytics(ctx)
    ctx.Analytics.refresh(ctx)
    return (ctx.view.metrics.count or 0) > 0 and #(ctx.view.monthly or {}) > 0 and #(ctx.view.categories or {}) > 0
end

local function center(ctx, id)
    for _, hb in ipairs(ctx.hitboxes) do
        if hb.id == id then return hb.x + hb.w / 2, hb.y + hb.h / 2 end
    end
    return nil, nil
end

function Tests.check_hitboxes(ctx)
    ctx.Controls.layout(ctx)
    local x, y = center(ctx, "tab_2")
    ctx.Controls.mousepressed(ctx, x, y, 1)
    local tab_ok = ctx.state.active_tab == 2
    x, y = center(ctx, "member_next")
    ctx.Controls.mousepressed(ctx, x, y, 1)
    local member_ok = ctx.state.member_index == 2 and ctx.state.needs_refresh
    x, y = center(ctx, "clean_toggle")
    ctx.Controls.mousepressed(ctx, x, y, 1)
    local toggle_ok = ctx.state.use_cleaned == false
    return tab_ok and member_ok and toggle_ok
end

function Tests.write_report(C, results)
    lurek.filesystem.createDirectory("save")
    lurek.filesystem.createDirectory(C.SAVE_DIR)
    lurek.filesystem.write(C.TEST_REPORT_PATH, report_json(results))
end

function Tests.run_report(ctx)
    local results = {}
    local csv, row_count, deterministic = Tests.generate_csv(ctx.C, ctx.DataGeneration)
    add_result(results, "deterministic_generation", deterministic and row_count > 0, tostring(row_count))
    local df = lurek.dataframe.fromCSV(csv)
    add_result(results, "csv_parse", df:nrows() == row_count, tostring(df:nrows()))

    Tests.build_pipeline(ctx)
    local sql_outputs = Tests.check_sql_outputs(ctx)
    local sql_ok = true
    for _, item in ipairs(sql_outputs) do
        if item.rows <= 0 then sql_ok = false end
    end
    add_result(results, "sql_files", sql_ok, tostring(#sql_outputs))

    local cache_ok, cache_detail = Tests.check_cache_roundtrip(ctx)
    add_result(results, "binary_roundtrip", cache_ok, cache_detail)
    add_result(results, "analytics_refresh", Tests.check_analytics(ctx), tostring(ctx.view.metrics.count or 0))
    add_result(results, "ui_hitboxes", Tests.check_hitboxes(ctx), ctx.state.last_action)

    Tests.write_report(ctx.C, results)
    return results
end

return Tests