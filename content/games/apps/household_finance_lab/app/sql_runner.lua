local SQLRunner = {}

local function sql_path(ctx, file_name)
    return (ctx.root or "") .. "sql/" .. file_name
end

function SQLRunner.read(ctx, file_name)
    return lurek.filesystem.read(sql_path(ctx, file_name))
end

function SQLRunner.run_file(ctx, db, file_name, table_name)
    local sql = SQLRunner.read(ctx, file_name)
    local frame = db:query(sql)
    if table_name and table_name ~= "" then
        db:addTable(table_name, frame)
    end
    ctx.api_status[#ctx.api_status + 1] = {
        name = file_name,
        ok = true,
        rows = frame:nrows(),
        table = table_name or "",
    }
    return frame
end

function SQLRunner.run_all(ctx, db, files)
    local out = {}
    for _, item in ipairs(files) do
        out[item.table] = SQLRunner.run_file(ctx, db, item.file, item.table)
    end
    return out
end

function SQLRunner.quote(value)
    return "'" .. tostring(value):gsub("'", "''") .. "'"
end

function SQLRunner.query(ctx, sql)
    local ok, frame = pcall(function()
        return ctx.db:query(sql)
    end)
    ctx.api_status[#ctx.api_status + 1] = {
        name = "dynamic query",
        ok = ok,
        rows = ok and frame:nrows() or 0,
        table = ok and "view" or tostring(frame),
    }
    if not ok then error(frame, 2) end
    return frame
end

return SQLRunner