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

local function cache_path(C, name)
    return C.CACHE_DIR .. "/" .. name .. ".bin"
end

local function save_frame(C, name, frame)
    lurek.filesystem.writeBytes(cache_path(C, name), frame:toBinary())
end

local function load_frame(C, name)
    local path = cache_path(C, name)
    if not lurek.filesystem.exists(path) then return nil end
    return lurek.dataframe.fromBinary(lurek.filesystem.readBytes(path))
end

local function write_manifest(C, names)
    local parts = { "{\n", "  \"version\": \"", C.CACHE_VERSION, "\",\n", "  \"tables\": [" }
    for index, name in ipairs(names) do
        if index > 1 then parts[#parts + 1] = ", " end
        parts[#parts + 1] = "\"" .. name .. "\""
    end
    parts[#parts + 1] = "]\n}\n"
    lurek.filesystem.write(C.CACHE_MANIFEST, table.concat(parts))
end

local function manifest_valid(C)
    if not lurek.filesystem.exists(C.CACHE_MANIFEST) then return false end
    local text = lurek.filesystem.read(C.CACHE_MANIFEST)
    return string.find(text, C.CACHE_VERSION, 1, true) ~= nil
end

local function table_names(C)
    local names = { "transactions", "anomalies" }
    for _, item in ipairs(C.SQL_FILES) do
        names[#names + 1] = item.table
    end
    return names
end

local function rebuild_db_from_frames(frames)
    local db = lurek.dataframe.newDatabase()
    for name, frame in pairs(frames) do
        db:addTable(name, frame)
    end
    return db
end

function Pipeline.restore_cache(ctx)
    local C = ctx.C
    if not manifest_valid(C) then return nil end
    local frames = {}
    for _, name in ipairs(table_names(C)) do
        local frame = load_frame(C, name)
        if not frame then return nil end
        frames[name] = frame
    end
    local db = rebuild_db_from_frames(frames)
    append_log(ctx, "info", "Restored dataframe database from binary cache")
    return {
        db = db,
        frames = frames,
        source = "binary cache",
        rows = frames.transactions:nrows(),
        clean_rows = frames.filtered_transactions:nrows(),
    }
end

function Pipeline.save_cache(ctx, frames)
    local names = table_names(ctx.C)
    for _, name in ipairs(names) do
        if frames[name] then save_frame(ctx.C, name, frames[name]) end
    end
    write_manifest(ctx.C, names)
    append_log(ctx, "info", "Saved per-table binary dataframe cache")
end

function Pipeline.ensure_csv(ctx, options)
    local C = ctx.C
    ensure_dirs(C)
    local needs_generate = options.force_generate or not lurek.filesystem.exists(C.CSV_PATH)
    local existing = nil
    if not needs_generate then
        existing = lurek.filesystem.read(C.CSV_PATH)
        if not string.find(existing, "anomaly_issue", 1, true) or not string.find(existing, "category_clean", 1, true) then
            needs_generate = true
            append_log(ctx, "info", "Regenerating stale CSV schema")
        end
    end
    if needs_generate then
        local generated = ctx.DataGeneration.generate(C, options.generation_options or {})
        lurek.filesystem.write(C.CSV_PATH, generated.csv)
        append_log(ctx, "info", "Generated deterministic CSV with " .. tostring(generated.rows) .. " rows")
        return generated.csv
    end
    return existing
end

function Pipeline.build_from_csv(ctx, csv)
    ctx.api_status = {}
    local raw = lurek.dataframe.fromCSV(csv)
    pcall(function() raw:zscoreCol("amount_abs", "amount_z") end)

    local db = lurek.dataframe.newDatabase()
    db:addTable("transactions", raw)
    ctx.db = db

    local frames = ctx.SQLRunner.run_all(ctx, db, ctx.C.SQL_FILES)
    frames.transactions = raw

    local anomalies = db:query("SELECT txn_id, date, year, month, member_clean, category_clean, merchant, amount_abs, anomaly_issue, anomaly_severity, anomaly_score FROM transactions WHERE anomaly_issue != NULL")
    db:addTable("anomalies", anomalies)
    frames.anomalies = anomalies

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

    local csv = Pipeline.ensure_csv(ctx, options)
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

    local built = Pipeline.build_from_csv(ctx, csv)
    Pipeline.save_cache(ctx, built.frames)
    ctx.db = built.db
    ctx.frames = built.frames
    ctx.source = built.source
    ctx.row_count = built.rows
    ctx.clean_count = built.clean_rows
    return built
end

function Pipeline.log(ctx, level, message)
    append_log(ctx, level, message)
end

return Pipeline