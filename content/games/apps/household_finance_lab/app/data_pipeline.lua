local Pipeline = {}

local function append_log(ctx, level, message)
    ctx.logs[#ctx.logs + 1] = { level = level or "info", message = message }
    if #ctx.logs > 120 then table.remove(ctx.logs, 1) end
    pcall(function()
        lurek.filesystem.append(ctx.C.LOG_PATH, string.format("[%s] %s\n", level or "info", message))
    end)
end

local function ensure_dirs(C)
    lurek.filesystem.createDirectory("save")
    lurek.filesystem.createDirectory(C.SAVE_DIR)
    lurek.filesystem.createDirectory(C.CACHE_DIR)
end

local function sql_path(ctx, file_name)
    return (ctx.root or "") .. "sql/" .. file_name
end

local function read_sql(ctx, file_name)
    return lurek.filesystem.read(sql_path(ctx, file_name))
end

local function num(value)
    return tonumber(value) or 0
end

local function rows(frame)
    if not frame then return {} end
    return frame:toTable()
end

local function first_row(frame)
    return rows(frame)[1] or {}
end

local function run_file(ctx, db, file_name, table_name)
    local sql = read_sql(ctx, file_name)
    local frame = db:query(sql)
    if table_name and table_name ~= "" then
        db:addTable(table_name, frame)
    end
    ctx.api_status[#ctx.api_status + 1] = {
        name = file_name,
        ok = true,
        rows = frame:nrows(),
        table = table_name or "",
        api = "LDatabase:query",
    }
    return frame
end

local function run_all(ctx, db, files)
    local out = {}
    for _, item in ipairs(files) do
        out[item.table] = run_file(ctx, db, item.file, item.table)
    end
    return out
end

local function query_params(ctx, name, sql, params)
    local frame = ctx.db:queryParams(sql, params or {})
    ctx.api_status[#ctx.api_status + 1] = {
        name = name,
        ok = true,
        rows = frame:nrows(),
        table = "queryParams",
        api = "LDatabase:queryParams",
    }
    return frame
end

local function write_manifest(C, names)
    lurek.filesystem.write(C.CACHE_MANIFEST, lurek.serial.toJson({
        version = C.CACHE_VERSION,
        format = "lurek.dataframe.database.json",
        database = C.DATABASE_JSON_PATH,
        tables = names,
    }, true))
end

local function manifest_valid(C)
    if not lurek.filesystem.exists(C.CACHE_MANIFEST) then return false end
    if not lurek.filesystem.exists(C.DATABASE_JSON_PATH) then return false end
    local ok, data = pcall(function()
        return lurek.serial.fromJson(lurek.filesystem.read(C.CACHE_MANIFEST))
    end)
    return ok and data and data.version == C.CACHE_VERSION and data.database == C.DATABASE_JSON_PATH
end

local function table_names(C)
    local names = { "transactions", "amount_outliers", "category_grouped", "sample_transactions" }
    for _, item in ipairs(C.SQL_FILES) do
        names[#names + 1] = item.table
    end
    return names
end

local function copy_params(params)
    local out = {}
    for index, value in ipairs(params or {}) do
        out[index] = value
    end
    return out
end

local function append_params(params, extra)
    local out = copy_params(params)
    for _, value in ipairs(extra or {}) do
        out[#out + 1] = value
    end
    return out
end

local function database_table_names(db)
    local ok, names = pcall(function() return db:listTables() end)
    if ok and names then return names end
    return {}
end

local function dataframe_method_status(frames)
    frames = frames or {}
    return {
        fromCSVFileAsync = true,
        loadDatabase = true,
        saveDatabase = true,
        queryParams = true,
        zscoreCol = true,
        outliers = frames.amount_outliers and frames.amount_outliers:nrows() >= 0 or false,
        groupAgg = frames.category_grouped and frames.category_grouped:nrows() >= 0 or false,
        sample = frames.sample_transactions and frames.sample_transactions:nrows() > 0 or false,
        withRollingMean = true,
        withRollingSum = true,
        withPctChange = true,
    }
end

function Pipeline.restore_cache(ctx)
    local C = ctx.C
    if not manifest_valid(C) then return nil end
    local ok, db = pcall(function() return lurek.dataframe.loadDatabase(C.DATABASE_JSON_PATH) end)
    if not ok or not db then return nil end
    local frames = {}
    for _, name in ipairs(table_names(C)) do
        if db:hasTable(name) then
            frames[name] = db:getTable(name)
        end
    end
    if not frames.transactions or not frames.filtered_transactions then return nil end
    ctx.dataframe_methods = dataframe_method_status(frames)
    append_log(ctx, "info", "Restored dataframe database with lurek.dataframe.loadDatabase")
    return {
        db = db,
        frames = frames,
        source = "database cache",
        rows = frames.transactions:nrows(),
        clean_rows = frames.filtered_transactions:nrows(),
    }
end

function Pipeline.save_cache(ctx, frames)
    if not ctx.db then return false end
    local ok = ctx.db:save(ctx.C.DATABASE_JSON_PATH)
    if ok then
        write_manifest(ctx.C, database_table_names(ctx.db))
        append_log(ctx, "info", "Saved dataframe database with LDatabase:save")
    else
        append_log(ctx, "warn", "Database cache save failed")
    end
    return ok
end

function Pipeline.ensure_csv(ctx, options)
    local C = ctx.C
    ensure_dirs(C)
    local needs_generate = options.force_generate or not lurek.filesystem.exists(C.CSV_PATH)
    if needs_generate then
        local generated = ctx.DataGeneration.generate(C, options.generation_options or {})
        lurek.filesystem.write(C.CSV_PATH, generated.csv)
        append_log(ctx, "info", "Generated deterministic CSV with " .. tostring(generated.rows) .. " rows")
        return { generated = true, rows = generated.rows, path = C.CSV_PATH }
    end
    return { generated = false, path = C.CSV_PATH }
end

local function load_csv_frame(ctx, options)
    local dataframe = lurek.dataframe
    if type(dataframe) ~= "table" then
        error("lurek.dataframe module is unavailable")
    end

    if not options.sync_csv_load then
        local from_csv_async = dataframe.fromCSVFileAsync
        if type(from_csv_async) == "function" then
            local task = from_csv_async(ctx.C.CSV_PATH)
            task:wait()
            append_log(ctx, "info", "Loading CSV with lurek.dataframe.fromCSVFileAsync")
            return task:result()
        end
    end

    local from_csv_file = dataframe.fromCSVFile
    if type(from_csv_file) == "function" then
        append_log(ctx, "info", "Loading CSV with lurek.dataframe.fromCSVFile")
        return from_csv_file(ctx.C.CSV_PATH)
    end

    local from_csv_text = dataframe.fromCSV
    local fs_read = lurek.filesystem and lurek.filesystem.read
    if type(from_csv_text) == "function" and type(fs_read) == "function" then
        append_log(ctx, "warn", "fromCSVFile unavailable, loading CSV through filesystem.read + fromCSV")
        return from_csv_text(fs_read(ctx.C.CSV_PATH))
    end

    error("No supported CSV loader available (fromCSVFileAsync/fromCSVFile/fromCSV)")
end

function Pipeline.build_from_csv(ctx, options)
    options = options or {}
    ctx.api_status = {}
    local raw = load_csv_frame(ctx, options)
    raw:zscoreCol("amount_abs", "amount_z")
    raw:withRollingMean("expense_amount", 6, "expense_roll6")
    raw:withRollingSum("expense_amount", 6, "expense_sum6")
    raw:withPctChange("expense_amount", "expense_pct_change")

    local amount_outliers = raw:outliers("amount_abs", 2.0)
    local category_grouped = raw:groupAgg("category_clean", "expense_amount", "sum")
    local sample_transactions = raw:sample(24, 20260520)

    local db = lurek.dataframe.newDatabase()
    db:addTable("transactions", raw)
    db:addTable("amount_outliers", amount_outliers)
    db:addTable("category_grouped", category_grouped)
    db:addTable("sample_transactions", sample_transactions)
    ctx.db = db

    local frames = run_all(ctx, db, ctx.C.SQL_FILES)
    frames.transactions = raw
    frames.amount_outliers = amount_outliers
    frames.category_grouped = category_grouped
    frames.sample_transactions = sample_transactions

    ctx.dataframe_methods = dataframe_method_status(frames)

    append_log(ctx, "info", "Executed " .. tostring(#ctx.C.SQL_FILES) .. " SQL files through LDatabase:query")
    return {
        db = db,
        frames = frames,
        source = "CSV + SQL",
        rows = raw:nrows(),
        clean_rows = frames.filtered_transactions:nrows(),
    }
end

function Pipeline.load(ctx, options)
    options = options or {}
    ensure_dirs(ctx.C)
    lurek.filesystem.write(ctx.C.LOG_PATH, "Household Finance Lab app log\n")

    Pipeline.ensure_csv(ctx, options)
    if options.prefer_cache and not options.force_generate then
        local cached = Pipeline.restore_cache(ctx)
        if cached then
            ctx.db = cached.db
            ctx.frames = cached.frames
            ctx.source = cached.source
            ctx.row_count = cached.rows
            ctx.clean_count = cached.clean_rows
            return cached
        end
    end

    local built = Pipeline.build_from_csv(ctx, options)
    Pipeline.save_cache(ctx, built.frames)
    ctx.db = built.db
    ctx.frames = built.frames
    ctx.source = built.source
    ctx.row_count = built.rows
    ctx.clean_count = built.clean_rows
    return built
end

local function current_table(filters)
    if filters and filters.use_cleaned == false then return "transactions" end
    return "filtered_transactions"
end

local function filter_where(C, filters, include_anomalies)
    filters = filters or {}
    local clauses = {
        "year >= ?",
        "year <= ?",
    }
    local params = { filters.start_year or C.YEAR_MIN, filters.end_year or C.YEAR_MAX }
    if filters.member and filters.member ~= "All" then
        clauses[#clauses + 1] = "member_clean = ?"
        params[#params + 1] = filters.member
    end
    if filters.category and filters.category ~= "All" then
        clauses[#clauses + 1] = "category_clean = ?"
        params[#params + 1] = filters.category
    end
    if include_anomalies then
        clauses[#clauses + 1] = "anomaly_issue != NULL"
        clauses[#clauses + 1] = "anomaly_score >= ?"
        params[#params + 1] = filters.anomaly_threshold or 0
    elseif current_table(filters) ~= "transactions" then
        clauses[#clauses + 1] = "anomaly_issue = NULL"
    end
    return table.concat(clauses, " AND "), params
end

local function render_sql_template(ctx, file_name, replacements)
    local sql = read_sql(ctx, file_name)
    for token, value in pairs(replacements or {}) do
        sql = sql:gsub(token, value)
    end
    return sql
end

local function filter_months(ctx)
    local filters = ctx.filters or {}
    return math.max(1, ((filters.end_year or ctx.C.YEAR_MAX) - (filters.start_year or ctx.C.YEAR_MIN) + 1) * 12)
end

local function metric_view_from_aliases(row)
    return {
        count = num(row.row_count),
        income = num(row.income),
        expense = num(row.expense),
        savings = num(row.savings),
        debt = num(row.debt),
        essential = num(row.essential),
        assets = num(row.assets),
        net = num(row.income) - num(row.expense) - num(row.savings),
        savings_rate = num(row.savings_rate),
        debt_ratio = num(row.debt_ratio),
        essential_ratio = num(row.essential_ratio),
        runway_months = num(row.runway_months),
        avg_expense = num(row.avg_expense),
    }
end

local function query_metrics(ctx, table_name, where, params)
    local months = filter_months(ctx)
    local alias_params = append_params({ months, months }, params)
    local sql = render_sql_template(ctx, "50_refresh_metrics.sql", {
        ["__SOURCE_TABLE__"] = table_name,
        ["__WHERE__"] = where,
    })
    local frame = query_params(ctx, "summary metric aliases", sql, alias_params)
    local row = first_row(frame)
    ctx.sql_metric_aliases = row.income ~= nil and row.savings_rate ~= nil
    ctx.sql_metric_alias_reason = ctx.sql_metric_aliases and "arithmetic aliases available" or "arithmetic aliases did not return named columns"
    return metric_view_from_aliases(row)
end

function Pipeline.refresh(ctx, filters)
    ctx.filters = filters or ctx.filters or {}
    local table_name = current_table(ctx.filters)
    local where, where_params = filter_where(ctx.C, ctx.filters, false)
    local anomaly_where, anomaly_params = filter_where(ctx.C, ctx.filters, true)
    local A = ctx.C.AGG

    local monthly_sql = render_sql_template(ctx, "51_refresh_monthly.sql", {
        ["__SOURCE_TABLE__"] = table_name,
        ["__WHERE__"] = where,
    })
    local categories_sql = render_sql_template(ctx, "52_refresh_categories.sql", {
        ["__SOURCE_TABLE__"] = table_name,
        ["__WHERE__"] = where,
    })
    local members_sql = render_sql_template(ctx, "53_refresh_members.sql", {
        ["__SOURCE_TABLE__"] = table_name,
        ["__WHERE__"] = where,
    })
    local payment_sql = render_sql_template(ctx, "54_refresh_payment.sql", {
        ["__SOURCE_TABLE__"] = table_name,
        ["__WHERE__"] = where,
    })
    local recurring_sql = render_sql_template(ctx, "55_refresh_recurring.sql", {
        ["__SOURCE_TABLE__"] = table_name,
        ["__WHERE__"] = where,
    })
    local anomalies_sql = render_sql_template(ctx, "56_refresh_anomalies.sql", {
        ["__ANOMALY_WHERE__"] = anomaly_where,
    })
    local recent_sql = render_sql_template(ctx, "57_refresh_recent.sql", {
        ["__SOURCE_TABLE__"] = table_name,
        ["__WHERE__"] = where,
    })

    local monthly_frame = query_params(ctx, "monthly filtered", monthly_sql, where_params)
    local categories_frame = query_params(ctx, "categories filtered", categories_sql, append_params(where_params, { 0 }))
    local members_frame = query_params(ctx, "members filtered", members_sql, where_params)
    local payment_frame = query_params(ctx, "payment filtered", payment_sql, append_params(where_params, { 0 }))
    local recurring_frame = query_params(ctx, "recurring filtered", recurring_sql, append_params(where_params, { 1 }))
    local anomalies_frame = query_params(ctx, "anomalies filtered", anomalies_sql, anomaly_params)
    local recent_frame = query_params(ctx, "recent filtered", recent_sql, where_params)

    ctx.view_version = (ctx.view_version or 0) + 1
    ctx.view = {
        table_name = table_name,
        where = where,
        metrics = query_metrics(ctx, table_name, where, where_params),
        monthly = rows(monthly_frame),
        monthly_frame = monthly_frame,
        categories = rows(categories_frame),
        categories_frame = categories_frame,
        members = rows(members_frame),
        members_frame = members_frame,
        payment = rows(payment_frame),
        payment_frame = payment_frame,
        recurring = rows(recurring_frame),
        recurring_frame = recurring_frame,
        anomalies = rows(anomalies_frame),
        anomalies_frame = anomalies_frame,
        recent = rows(recent_frame),
        recent_frame = recent_frame,
        expressions = A,
        refreshed_at = ctx.clock or 0,
    }
    return ctx.view
end

function Pipeline.log(ctx, level, message)
    append_log(ctx, level, message)
end

return Pipeline
