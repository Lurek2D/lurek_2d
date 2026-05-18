--- DataFrame Module Part 1: Creation, Structure, Row/Column Ops, Filtering, Sorting, Grouping, Stats

--@api-stub: lurek.dataframe.newDataFrame
-- Creates an empty dataframe.
do
    local df = lurek.dataframe.newDataFrame()
    print("new df cols = " .. df:ncols())
end

--@api-stub: lurek.dataframe.newDatabase
-- Creates an empty dataframe database.
do
    local db = lurek.dataframe.newDatabase()
    print("db tables = " .. db:tableCount())
end

--@api-stub: lurek.dataframe.fromTable
-- Creates a dataframe from an array of row tables.
do
    local df = lurek.dataframe.fromTable({
        {name = "Alice", age = 30},
        {name = "Bob", age = 25},
        {name = "Carol", age = 35},
    })
    print("fromTable rows = " .. df:nrows())
end

--@api-stub: lurek.dataframe.fromRows
-- Creates a dataframe from column names and row arrays.
do
    local df = lurek.dataframe.fromRows(
        {"x", "y", "z"},
        {{1, 2, 3}, {4, 5, 6}, {7, 8, 9}}
    )
    print("fromRows = " .. df:nrows() .. "x" .. df:ncols())
end

--@api-stub: lurek.dataframe.fromCSV
-- Parses a dataframe from CSV text.
do
    local csv = "name,score\nAlice,90\nBob,85\n"
    local df = lurek.dataframe.fromCSV(csv)
    print("fromCSV rows = " .. df:nrows())
end

--@api-stub: lurek.dataframe.fromJSON
-- Parses a dataframe from JSON text.
do
    local json = '[{"id":1,"val":10},{"id":2,"val":20}]'
    local df = lurek.dataframe.fromJSON(json)
    print("fromJSON rows = " .. df:nrows())
end

--@api-stub: lurek.dataframe.fromBinary
-- Deserializes a dataframe from binary data.
do
    local df = lurek.dataframe.fromTable({{a = 1, b = 2}})
    local bin = df:toBinary()
    local restored = lurek.dataframe.fromBinary(bin)
    print("fromBinary rows = " .. restored:nrows())
end

--@api-stub: lurek.dataframe.random
-- Creates a random dataframe from column definitions.
do
    local df = lurek.dataframe.random({{"score", "float"}, {"rank", "int"}}, 10)
    print("random rows = " .. df:nrows())
end

--@api-stub: lurek.dataframe.toVec
-- Converts a dataframe to a vectorized frame.
do
    local df = lurek.dataframe.fromRows({"a", "b"}, {{1, 2}, {3, 4}})
    local vf = lurek.dataframe.toVec(df)
    print("vecframe rows = " .. vf:nrows())
end

--@api-stub: lurek.dataframe.fromVec
-- Converts a vectorized frame back to a dataframe.
do
    local df = lurek.dataframe.fromRows({"x"}, {{10}, {20}})
    local vf = lurek.dataframe.toVec(df)
    local df2 = lurek.dataframe.fromVec(vf)
    print("fromVec rows = " .. df2:nrows())
end

--@api-stub: LGroupedFrame:aggregate
-- Aggregates a column in each group with a Lua function.
do
    local df = lurek.dataframe.fromTable({
        {team = "A", score = 10},
        {team = "A", score = 20},
        {team = "B", score = 30},
    })
    local gf = df:groupByObj("team")
    local agg = gf:aggregate("score", function(vals)
        local s = 0
        for _, v in ipairs(vals) do s = s + v end
        return s
    end)
    print("agg rows = " .. agg:nrows())
end

--@api-stub: LGroupedFrame:type
-- Returns the type name ("LGroupedFrame").
do
    local df = lurek.dataframe.fromTable({{cat = "x", v = 1}})
    local gf = df:groupByObj("cat")
    print("type = " .. gf:type())
end

--@api-stub: LGroupedFrame:typeOf
-- Returns whether this handle matches a type name.
do
    local df = lurek.dataframe.fromTable({{cat = "x", v = 1}})
    local gf = df:groupByObj("cat")
    print("is LGroupedFrame = " .. tostring(gf:typeOf("LGroupedFrame")))
end

--@api-stub: LDataFrame:nrows
-- Returns the number of rows.
do
    local df = lurek.dataframe.fromRows({"a"}, {{1}, {2}, {3}})
    print("nrows = " .. df:nrows())
end

--@api-stub: LDataFrame:ncols
-- Returns the number of columns.
do
    local df = lurek.dataframe.fromRows({"a", "b", "c"}, {{1, 2, 3}})
    print("ncols = " .. df:ncols())
end

--@api-stub: LDataFrame:columns
-- Returns all column names in order.
do
    local df = lurek.dataframe.fromRows({"x", "y"}, {{1, 2}})
    local cols = df:columns()
    print("cols = " .. cols[1] .. ", " .. cols[2])
end

--@api-stub: LDataFrame:count
-- Returns the row count (alias for nrows).
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}})
    print("count = " .. df:count())
end

--@api-stub: LDataFrame:addColumn
-- Adds a column with an optional default value.
do
    local df = lurek.dataframe.fromRows({"a"}, {{1}, {2}})
    df:addColumn("b", 0)
    print("after addColumn ncols = " .. df:ncols())
end

--@api-stub: LDataFrame:removeColumn
-- Removes a column by name.
do
    local df = lurek.dataframe.fromRows({"a", "b"}, {{1, 2}})
    df:removeColumn("b")
    print("after removeColumn ncols = " .. df:ncols())
end

--@api-stub: LDataFrame:rename
-- Renames a column.
do
    local df = lurek.dataframe.fromRows({"old_name"}, {{1}})
    df:rename("old_name", "new_name")
    local cols = df:columns()
    print("renamed = " .. cols[1])
end

--@api-stub: LDataFrame:getColumn
-- Returns a column as an array table.
do
    local df = lurek.dataframe.fromRows({"score"}, {{10}, {20}, {30}})
    local col = df:getColumn("score")
    print("col[2] = " .. col[2])
end

--@api-stub: LDataFrame:addRow
-- Adds a row and returns its one-based index.
do
    local df = lurek.dataframe.fromRows({"name", "val"}, {{"a", 1}})
    local idx = df:addRow({name = "b", val = 2})
    print("added at row " .. idx)
end

--@api-stub: LDataFrame:removeRow
-- Removes a row by one-based index.
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}})
    df:removeRow(2)
    print("after remove nrows = " .. df:nrows())
end

--@api-stub: LDataFrame:getRow
-- Returns a row as a table keyed by column name.
do
    local df = lurek.dataframe.fromTable({{name = "Alice", age = 30}})
    local row = df:getRow(1)
    print("row name = " .. row.name)
end

--@api-stub: LDataFrame:getValue
-- Returns one cell value.
do
    local df = lurek.dataframe.fromRows({"a", "b"}, {{10, 20}, {30, 40}})
    local val = df:getValue(2, "b")
    print("cell[2,b] = " .. val)
end

--@api-stub: LDataFrame:setValue
-- Sets one cell value.
do
    local df = lurek.dataframe.fromRows({"x"}, {{0}, {0}})
    df:setValue(1, "x", 99)
    print("after set = " .. df:getValue(1, "x"))
end

--@api-stub: LDataFrame:filter
-- Returns rows matching a column comparison.
do
    local df = lurek.dataframe.fromRows({"score"}, {{10}, {50}, {80}, {30}})
    local filtered = df:filter("score", ">", 40)
    print("filtered rows = " .. filtered:nrows())
end

--@api-stub: LDataFrame:sort
-- Returns rows sorted by a column.
do
    local df = lurek.dataframe.fromRows({"v"}, {{3}, {1}, {2}})
    local sorted = df:sort("v", true)
    print("sorted first = " .. sorted:getValue(1, "v"))
end

--@api-stub: LDataFrame:head
-- Returns the first N rows.
do
    local df = lurek.dataframe.fromRows({"x"}, {{1}, {2}, {3}, {4}, {5}})
    local top = df:head(3)
    print("head rows = " .. top:nrows())
end

--@api-stub: LDataFrame:tail
-- Returns the last N rows.
do
    local df = lurek.dataframe.fromRows({"x"}, {{1}, {2}, {3}, {4}, {5}})
    local bottom = df:tail(2)
    print("tail rows = " .. bottom:nrows())
end

--@api-stub: LDataFrame:slice
-- Returns a one-based inclusive row slice.
do
    local df = lurek.dataframe.fromRows({"x"}, {{1}, {2}, {3}, {4}, {5}})
    local mid = df:slice(2, 4)
    print("slice rows = " .. mid:nrows())
end

--@api-stub: LDataFrame:select
-- Returns a dataframe with selected columns.
do
    local df = lurek.dataframe.fromRows({"a", "b", "c"}, {{1, 2, 3}})
    local sub = df:select("a", "c")
    print("select ncols = " .. sub:ncols())
end

--@api-stub: LDataFrame:unique
-- Returns unique values from a column.
do
    local df = lurek.dataframe.fromRows({"color"}, {{"red"}, {"blue"}, {"red"}, {"green"}})
    local uniq = df:unique("color")
    print("unique count = " .. #uniq)
end

--@api-stub: LDataFrame:groupBy
-- Groups rows by a column into a table of dataframes.
do
    local df = lurek.dataframe.fromTable({
        {team = "A", pts = 10},
        {team = "B", pts = 20},
        {team = "A", pts = 30},
    })
    local groups = df:groupBy("team")
    print("group A rows = " .. groups["A"]:nrows())
end

--@api-stub: LDataFrame:groupByObj
-- Groups rows and returns a LGroupedFrame handle.
do
    local df = lurek.dataframe.fromTable({
        {cat = "x", v = 1}, {cat = "y", v = 2},
    })
    local gf = df:groupByObj("cat")
    print("grouped type = " .. gf:type())
end

--@api-stub: LDataFrame:join
-- Joins this dataframe with another on column references.
do
    local left = lurek.dataframe.fromTable({{id = 1, name = "A"}, {id = 2, name = "B"}})
    local right = lurek.dataframe.fromTable({{id = 1, score = 90}, {id = 2, score = 80}})
    local joined = left:join(right, "id", "id", "inner")
    print("joined cols = " .. joined:ncols())
end

--@api-stub: LDataFrame:merge
-- Appends another dataframe's rows into this one.
do
    local a = lurek.dataframe.fromRows({"v"}, {{1}, {2}})
    local b = lurek.dataframe.fromRows({"v"}, {{3}, {4}})
    a:merge(b)
    print("after merge rows = " .. a:nrows())
end

--@api-stub: LDataFrame:countBy
-- Counts occurrences of each value in a column.
do
    local df = lurek.dataframe.fromRows({"fruit"}, {{"apple"}, {"banana"}, {"apple"}})
    local counts = df:countBy("fruit")
    print("countBy rows = " .. counts:nrows())
end

--@api-stub: LDataFrame:dropNil
-- Returns rows where the column is not nil.
do
    local df = lurek.dataframe.newDataFrame()
    df:addColumn("x")
    df:addRow({x = 1})
    df:addRow({})
    df:addRow({x = 3})
    local clean = df:dropNil("x")
    print("after dropNil rows = " .. clean:nrows())
end

--@api-stub: LDataFrame:sample
-- Returns a random sample of rows.
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}})
    local s = df:sample(3, 42)
    print("sample rows = " .. s:nrows())
end

--@api-stub: LDataFrame:describe
-- Returns summary statistics for numeric columns.
do
    local df = lurek.dataframe.fromRows({"score"}, {{10}, {20}, {30}, {40}, {50}})
    local stats = df:describe()
    print("describe rows = " .. stats:nrows())
end

--@api-stub: LDataFrame:sum
-- Returns the sum of a numeric column.
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}, {4}})
    print("sum = " .. df:sum("v"))
end

--@api-stub: LDataFrame:mean
-- Returns the mean of a numeric column.
do
    local df = lurek.dataframe.fromRows({"v"}, {{10}, {20}, {30}})
    print("mean = " .. df:mean("v"))
end

--@api-stub: LDataFrame:min
-- Returns the minimum of a column.
do
    local df = lurek.dataframe.fromRows({"v"}, {{5}, {1}, {8}})
    print("min = " .. df:min("v"))
end

--@api-stub: LDataFrame:max
-- Returns the maximum of a column.
do
    local df = lurek.dataframe.fromRows({"v"}, {{5}, {1}, {8}})
    print("max = " .. df:max("v"))
end

--@api-stub: LDataFrame:median
-- Returns the median of a numeric column.
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}, {4}, {5}})
    print("median = " .. df:median("v"))
end

--@api-stub: LDataFrame:stddev
-- Returns the standard deviation of a column.
do
    local df = lurek.dataframe.fromRows({"v"}, {{2}, {4}, {4}, {4}, {5}, {5}, {7}, {9}})
    print("stddev = " .. df:stddev("v"))
end

--@api-stub: LDataFrame:variance
-- Returns the variance of a column.
do
    local df = lurek.dataframe.fromRows({"v"}, {{2}, {4}, {4}, {4}, {5}, {5}, {7}, {9}})
    print("variance = " .. df:variance("v"))
end

--@api-stub: LDataFrame:fillNil
-- Replaces nil cells in a column with a value.
do
    local df = lurek.dataframe.newDataFrame()
    df:addColumn("x")
    df:addRow({x = 1})
    df:addRow({})
    df:fillNil("x", 0)
    print("filled = " .. df:getValue(2, "x"))
end

--@api-stub: LDataFrame:apply
-- Applies a function to each value in a column in place.
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}})
    df:apply("v", function(x) return (x or 0) * 10 end)
    print("applied[2] = " .. df:getValue(2, "v"))
end

print("dataframe_00.lua")
