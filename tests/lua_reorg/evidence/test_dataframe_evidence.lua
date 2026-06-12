-- Canonical evidence file for lurek.dataframe data outputs.
-- @covers lurek.dataframe.fromBinary
-- @covers lurek.dataframe.fromCSV
-- @covers lurek.dataframe.fromJSON
-- @covers lurek.dataframe.fromRows
-- @covers lurek.dataframe.newDataFrame
-- @covers lurek.filesystem.write
-- @covers lurek.image.newImageData
-- @covers lurek.image.savePNG


local OUT = evidence_output_dir("dataframe")

local function write_text(path, text)
    if write_file then
        write_file(path, text)
    else
        lurek.filesystem.write(path, text)
    end
    expect_evidence_created(path)
end

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

local function draw_outline(img, x, y, w, h, r, g, b, a)
    img:drawLine(x, y, x + w - 1, y, r, g, b, a or 255)
    img:drawLine(x + w - 1, y, x + w - 1, y + h - 1, r, g, b, a or 255)
    img:drawLine(x + w - 1, y + h - 1, x, y + h - 1, r, g, b, a or 255)
    img:drawLine(x, y + h - 1, x, y, r, g, b, a or 255)
end

-- @describe Evidence: lurek.dataframe data outputs
describe("Evidence: lurek.dataframe data outputs", function()
    before_each(function()
        ensure_evidence_dir("dataframe")
    end)

    -- @evidence lurek.dataframe.fromCSV
    -- @evidence LDataFrame:sum
    -- @evidence LDataFrame:mean
    it("writes dataframe_csv_statistics.txt", function()
        local df = lurek.dataframe.fromCSV("values\n10\n20\n30\n40\n50")
        local text = table.concat({
            "row_count=5",
            "sum=" .. string.format("%.6f", df:sum("values")),
            "mean=" .. string.format("%.6f", df:mean("values")),
        }, "\n") .. "\n"
        write_text(OUT .. "dataframe_csv_statistics.txt", text)
    end)

    -- @evidence lurek.dataframe.fromRows
    -- @evidence LDataFrame:addColumn
    -- @evidence LDataFrame:setValue
    -- @evidence LDataFrame:filter
    -- @evidence LDataFrame:sort
    -- @evidence LDataFrame:getRow
    -- @evidence LDataFrame:nrows
    it("writes dataframe_transform_snapshot.txt", function()
        local df = lurek.dataframe.fromRows(
            { "name", "age", "score" },
            {
                { "Alice", 30, 90 },
                { "Bob", 25, 85 },
                { "Cara", 35, 92 },
            }
        )
        df:addColumn("tier", "mid")
        df:setValue(1, "tier", "gold")
        df:setValue(3, "tier", "gold")
        local filtered = df:filter("age", ">", 28):sort("score", "desc")
        local row = filtered:getRow(1)
        local text = table.concat({
            "filtered_rows=" .. tostring(filtered:nrows()),
            "leader_name=" .. tostring(row.name),
            "leader_score=" .. tostring(row.score),
            "leader_tier=" .. tostring(row.tier),
        }, "\n") .. "\n"
        write_text(OUT .. "dataframe_transform_snapshot.txt", text)
    end)

    -- @evidence LDataFrame:describe
    -- @evidence LDataFrame:min
    -- @evidence LDataFrame:max
    -- @evidence LDataFrame:median
    -- @evidence LDataFrame:stddev
    -- @evidence LDataFrame:variance
    it("writes dataframe_descriptive_statistics.txt", function()
        local df = lurek.dataframe.fromRows(
            { "value" },
            {
                { 10 },
                { 20 },
                { 30 },
                { 40 },
            }
        )
        local stats = df:describe()
        local text = table.concat({
            "describe_rows=" .. tostring(stats:nrows()),
            "describe_cols=" .. tostring(stats:ncols()),
            "min=" .. string.format("%.6f", df:min("value")),
            "max=" .. string.format("%.6f", df:max("value")),
            "median=" .. string.format("%.6f", df:median("value")),
            "stddev=" .. string.format("%.6f", df:stddev("value")),
            "variance=" .. string.format("%.6f", df:variance("value")),
        }, "\n") .. "\n"
        write_text(OUT .. "dataframe_descriptive_statistics.txt", text)
    end)

    -- @evidence LDataFrame:toCSV
    -- @evidence LDataFrame:toJSON
    -- @evidence LDataFrame:toBinary
    -- @evidence lurek.dataframe.fromBinary
    it("writes dataframe_serialization_snapshot.txt", function()
        local df = lurek.dataframe.fromCSV("name,score\nAlice,90\nBob,85\n")
        local csv = df:toCSV()
        local json = df:toJSON()
        local binary = df:toBinary()
        local restored = lurek.dataframe.fromBinary(binary)
        local text = table.concat({
            "csv_len=" .. tostring(#csv),
            "json_len=" .. tostring(#json),
            "binary_len=" .. tostring(#binary),
            "restored_rows=" .. tostring(restored:nrows()),
            "restored_name_1=" .. tostring(restored:getValue(1, "name")),
        }, "\n") .. "\n"
        write_text(OUT .. "dataframe_serialization_snapshot.txt", text)
    end)

    -- @evidence LDataFrame:getColumn
    -- @evidence lurek.image.savePNG
    it("writes dataframe_value_bars.png", function()
        local df = lurek.dataframe.fromCSV("label,value\nA,10\nB,35\nC,22\nD,48\n")
        local values = df:getColumn("value")
        local img = lurek.image.newImageData(320, 180)
        img:fill(14, 16, 20, 255)
        img:drawRect(24, 20, 272, 132, 24, 28, 36, 255)
        draw_outline(img, 24, 20, 272, 132, 232, 236, 244, 255)
        for i, value in ipairs(values) do
            local x = 44 + (i - 1) * 60
            local h = math.floor((tonumber(value) or 0) * 2.2)
            local y = 136 - h
            img:drawRect(x, y, 32, h, 90 + i * 30, 140 + i * 10, 220, 255)
            draw_outline(img, x, y, 32, h, 240, 244, 248, 255)
        end
        save_png(img, OUT .. "dataframe_value_bars.png")
    end)

    -- @evidence lurek.dataframe.newDataFrame
    -- @evidence lurek.dataframe.fromJSON
    -- @evidence LDataFrame:columns
    -- @evidence LDataFrame:schema
    -- @evidence LDataFrame:count
    -- @evidence LDataFrame:head
    -- @evidence LDataFrame:tail
    -- @evidence LDataFrame:slice
    -- @evidence LDataFrame:select
    -- @evidence LDataFrame:toTable
    -- @evidence LDataFrame:rows
    -- @evidence LDataFrame:toString
    it("writes dataframe_structure_query_trace.txt", function()
        local empty = lurek.dataframe.newDataFrame({ "name", "score" })
        local df = lurek.dataframe.fromJSON('[{"name":"A","score":10},{"name":"B","score":15},{"name":"C","score":15},{"name":"D","score":30}]')
        local cols = df:columns()
        local schema = df:schema()
        local first_two = df:head(2)
        local last_one = df:tail(1)
        local middle = df:slice(2, 3)
        local picked = df:select("name")
        local table_rows = df:toTable()
        local iter_names = {}
        for _, row in df:rows() do
            iter_names[#iter_names + 1] = row.name
        end
        local lines = {
            "empty_rows=" .. tostring(empty:nrows()),
            "columns=" .. table.concat(cols, ","),
            "schema=" .. tostring(schema),
            "count_score_15=" .. tostring(df:count("score", 15)),
            "head_first=" .. tostring(first_two:getValue(1, "name")),
            "tail_last=" .. tostring(last_one:getValue(1, "name")),
            "slice_rows=" .. tostring(middle:nrows()),
            "select_cols=" .. tostring(picked:ncols()),
            "rows_len=" .. tostring(#iter_names),
            "table_len=" .. tostring(#table_rows),
            "to_string_len=" .. tostring(#df:toString()),
        }
        write_text(OUT .. "dataframe_structure_query_trace.txt", table.concat(lines, "\n") .. "\n")
    end)
end)
test_summary()
