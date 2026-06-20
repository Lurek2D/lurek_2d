local M = {}
function M.new(config)
    local df = lurek.dataframe.fromCSVFile("assets/data/sales.csv")
    local schema = df:schema()
    return { df = df, schema = schema, sort_col = "revenue", filter_min = 0, selected = 1, rows = {}, mean = df:mean("revenue") }
end
function M.refresh(app)
    local view = app.df:filter("revenue", ">=", app.filter_min):sort(app.sort_col, false)
    app.rows = {}
    for i = 0, 7 do
        local ok, row = pcall(function() return view:getRow(i) end)
        if ok and row then
            app.rows[#app.rows + 1] = row
        end
    end
end
function M.update(app, dt)
    M.refresh(app)
end
return M
