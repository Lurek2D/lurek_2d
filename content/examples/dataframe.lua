-- content/examples/dataframe.lua
-- Auto-generated from content/examples2/dataframe_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/dataframe.lua

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
    })
    print("fromTable rows = " .. df:nrows())
end

--@api-stub: lurek.dataframe.fromRows
-- Creates a dataframe from column names and row arrays.
do
    local df = lurek.dataframe.fromRows(
        {"x", "y", "z"},
        {{1, 2, 3}, {4, 5, 6}}
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

--- DataFrame Module Part 2: Serialization, Query, Rolling, Rank, Pivot, Correlation, Normalize, LazyQuery, Database


--@api-stub: LDataFrame:toCSV
-- Serializes this dataframe to CSV text.
do
    local df = lurek.dataframe.fromRows({"name", "val"}, {{"a", 1}, {"b", 2}})
    local csv = df:toCSV()
    print("csv len = " .. #csv)
end

--@api-stub: LDataFrame:toJSON
-- Serializes this dataframe to JSON text.
do
    local df = lurek.dataframe.fromRows({"x"}, {{10}, {20}})
    local json = df:toJSON()
    print("json len = " .. #json)
end

--@api-stub: LDataFrame:toBinary
-- Serializes this dataframe to binary data.
do
    local df = lurek.dataframe.fromRows({"a"}, {{1}, {2}})
    local bin = df:toBinary()
    print("binary len = " .. #bin)
end

--@api-stub: LDataFrame:toTable
-- Converts to an array of row tables.
do
    local df = lurek.dataframe.fromRows({"k", "v"}, {{"x", 1}, {"y", 2}})
    local t = df:toTable()
    print("table rows = " .. #t)
end

--@api-stub: LDataFrame:rows
-- Returns an iterator over row index and row table pairs.
do
    local df = lurek.dataframe.fromRows({"v"}, {{10}, {20}, {30}})
    local count = 0
    for _, _ in df:rows() do count = count + 1 end
    print("iterated rows = " .. count)
end

--@api-stub: LDataFrame:toString
-- Formats as a human-readable text table.
do
    local df = lurek.dataframe.fromRows({"x", "y"}, {{1, 2}})
    local s = df:toString()
    print("toString len = " .. #s)
end

--@api-stub: LDataFrame:query
-- Runs a SQL-style query against this dataframe.
do
    local df = lurek.dataframe.fromRows({"name", "score"}, {{"a", 90}, {"b", 50}, {"c", 80}})
    local result = df:query("SELECT name FROM self WHERE score > 60")
    print("query rows = " .. result:nrows())
end

--@api-stub: LDataFrame:clone
-- Returns a deep copy.
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}})
    local copy = df:clone()
    copy:setValue(1, "v", 99)
    print("original[1] = " .. df:getValue(1, "v"))
end

--@api-stub: LDataFrame:withRollingMean
-- Adds a rolling mean column in place.
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}, {4}, {5}})
    df:withRollingMean("v", 3, "rm")
    print("rolling mean cols = " .. df:ncols())
end

--@api-stub: LDataFrame:withRollingSum
-- Adds a rolling sum column in place.
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}, {4}})
    df:withRollingSum("v", 2, "rs")
    print("rolling sum cols = " .. df:ncols())
end

--@api-stub: LDataFrame:withRollingMin
-- Adds a rolling minimum column in place.
do
    local df = lurek.dataframe.fromRows({"v"}, {{5}, {3}, {8}, {1}})
    df:withRollingMin("v", 2, "rmin")
    print("rolling min cols = " .. df:ncols())
end

--@api-stub: LDataFrame:withRollingMax
-- Adds a rolling maximum column in place.
do
    local df = lurek.dataframe.fromRows({"v"}, {{5}, {3}, {8}, {1}})
    df:withRollingMax("v", 2, "rmax")
    print("rolling max cols = " .. df:ncols())
end

--@api-stub: LDataFrame:withRank
-- Adds a rank column in place.
do
    local df = lurek.dataframe.fromRows({"score"}, {{30}, {10}, {20}})
    df:withRank("score", true, "rank")
    print("rank cols = " .. df:ncols())
end

--@api-stub: LDataFrame:withPctChange
-- Adds a percent-change column in place.
do
    local df = lurek.dataframe.fromRows({"v"}, {{100}, {110}, {105}})
    df:withPctChange("v", "pct")
    print("pct change cols = " .. df:ncols())
end

--@api-stub: LDataFrame:withCumsum
-- Adds a cumulative-sum column in place.
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}, {4}})
    df:withCumsum("v", "csum")
    print("cumsum cols = " .. df:ncols())
end

--@api-stub: LDataFrame:groupAgg
-- Groups by one column and aggregates another.
do
    local df = lurek.dataframe.fromTable({
        {cat = "A", v = 10}, {cat = "A", v = 20}, {cat = "B", v = 30},
    })
    local agg = df:groupAgg("cat", "v", "sum")
    print("groupAgg rows = " .. agg:nrows())
end

--@api-stub: LDataFrame:pivot
-- Pivots rows into columns.
do
    local df = lurek.dataframe.fromTable({
        {row = "r1", col = "c1", val = 10},
        {row = "r1", col = "c2", val = 20},
        {row = "r2", col = "c1", val = 30},
    })
    local pv = df:pivot("row", "col", "val")
    print("pivot cols = " .. pv:ncols())
end

--@api-stub: LDataFrame:corr
-- Returns correlation between two numeric columns.
do
    local df = lurek.dataframe.fromRows({"a", "b"}, {{1, 2}, {2, 4}, {3, 6}})
    print("corr = " .. df:corr("a", "b"))
end

--@api-stub: LDataFrame:correlationMatrix
-- Returns a correlation matrix dataframe.
do
    local df = lurek.dataframe.fromRows({"x", "y"}, {{1, 2}, {2, 4}, {3, 6}})
    local cm = df:correlationMatrix()
    print("corr matrix cols = " .. cm:ncols())
end

--@api-stub: LDataFrame:zscoreCol
-- Adds a z-score normalized column in place.
do
    local df = lurek.dataframe.fromRows({"v"}, {{2}, {4}, {4}, {4}, {5}, {5}, {7}, {9}})
    df:zscoreCol("v", "z")
    print("zscore cols = " .. df:ncols())
end

--@api-stub: LDataFrame:normalizeCol
-- Adds a range-normalized column in place.
do
    local df = lurek.dataframe.fromRows({"v"}, {{0}, {50}, {100}})
    df:normalizeCol("v", 0, 1, "norm")
    print("normalize cols = " .. df:ncols())
end

--@api-stub: LDataFrame:outliers
-- Returns rows considered outliers for a numeric column.
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}, {100}, {2}, {3}})
    local out = df:outliers("v", 2.0)
    print("outlier rows = " .. out:nrows())
end

--@api-stub: LDataFrame:modeVal
-- Returns the most common value of a column.
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {2}, {3}})
    print("mode = " .. df:modeVal("v"))
end

--@api-stub: LDataFrame:entropy
-- Returns entropy for a column.
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {1}, {2}, {2}, {3}})
    print("entropy = " .. df:entropy("v"))
end

--@api-stub: LDataFrame:addRowBatch
-- Appends multiple rows from array-style row tables.
do
    local df = lurek.dataframe.fromRows({"a", "b"}, {{1, 2}})
    df:addRowBatch({{3, 4}, {5, 6}})
    print("after batch rows = " .. df:nrows())
end

--@api-stub: LDataFrame:getColumnAsF64
-- Returns a numeric column as an array of numbers.
do
    local df = lurek.dataframe.fromRows({"score"}, {{10}, {20}, {30}})
    local vals = df:getColumnAsF64("score")
    print("f64[2] = " .. vals[2])
end

--@api-stub: LDataFrame:setColumnFromF64
-- Replaces a numeric column from an array of numbers.
do
    local df = lurek.dataframe.fromRows({"v"}, {{0}, {0}, {0}})
    df:setColumnFromF64("v", {100, 200, 300})
    print("after set[3] = " .. df:getValue(3, "v"))
end

--@api-stub: LDataFrame:type
-- Returns the type name ("LDataFrame").
do
    local df = lurek.dataframe.newDataFrame()
    print("type = " .. df:type())
end

--@api-stub: LDataFrame:typeOf
-- Returns whether this handle matches a type name.
do
    local df = lurek.dataframe.newDataFrame()
    print("is LDataFrame = " .. tostring(df:typeOf("LDataFrame")))
end

--@api-stub: LDataFrame:withEval
-- Returns a dataframe with a column computed from an expression.
do
    local df = lurek.dataframe.fromRows({"a", "b"}, {{1, 2}, {3, 4}})
    local result = df:withEval("sum", "a + b")
    print("eval cols = " .. result:ncols())
end

--@api-stub: LDataFrame:pivotTable
-- Builds a pivot table with aggregate function.
do
    local df = lurek.dataframe.fromTable({
        {region = "N", product = "X", sales = 10},
        {region = "N", product = "Y", sales = 20},
        {region = "S", product = "X", sales = 30},
    })
    local pt = df:pivotTable("region", "product", "sales", "sum")
    print("pivotTable rows = " .. pt:nrows())
end

--@api-stub: LDataFrame:rollingMean
-- Returns a dataframe with a rolling mean column.
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}, {4}, {5}})
    local rm = df:rollingMean("v", 3)
    print("rollingMean cols = " .. rm:ncols())
end

--@api-stub: LDataFrame:rollingSum
-- Returns a dataframe with a rolling sum column.
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}, {4}})
    local rs = df:rollingSum("v", 2)
    print("rollingSum cols = " .. rs:ncols())
end

--@api-stub: LDataFrame:rank
-- Returns a dataframe with a rank column.
do
    local df = lurek.dataframe.fromRows({"score"}, {{30}, {10}, {20}})
    local ranked = df:rank("score", "asc")
    print("rank cols = " .. ranked:ncols())
end

--@api-stub: LDataFrame:lazy
-- Starts a lazy query pipeline.
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}})
    local lq = df:lazy()
    print("lazy type = " .. lq:type())
end

--@api-stub: LLazyQuery:filter
-- Adds a filter step to the lazy pipeline.
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}, {4}, {5}})
    local result = df:lazy():filter("v", ">", 3):collect()
    print("lazy filter rows = " .. result:nrows())
end

--@api-stub: LLazyQuery:sort
-- Adds a sort step.
do
    local df = lurek.dataframe.fromRows({"v"}, {{3}, {1}, {2}})
    local result = df:lazy():sort("v", true):collect()
    print("lazy sort first = " .. result:getValue(1, "v"))
end

--@api-stub: LLazyQuery:head
-- Adds a head limit step.
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}, {4}, {5}})
    local result = df:lazy():head(2):collect()
    print("lazy head rows = " .. result:nrows())
end

--@api-stub: LLazyQuery:tail
-- Adds a tail limit step.
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}, {4}, {5}})
    local result = df:lazy():tail(2):collect()
    print("lazy tail rows = " .. result:nrows())
end

--@api-stub: LLazyQuery:limit
-- Adds a row limit step.
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}, {4}})
    local result = df:lazy():limit(2):collect()
    print("lazy limit rows = " .. result:nrows())
end

--@api-stub: LLazyQuery:slice
-- Adds a row slice step.
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}, {4}, {5}})
    local result = df:lazy():slice(2, 4):collect()
    print("lazy slice rows = " .. result:nrows())
end

--@api-stub: LLazyQuery:dropNil
-- Adds a drop-nil step.
do
    local df = lurek.dataframe.newDataFrame()
    df:addColumn("x")
    df:addRow({x = 1})
    df:addRow({})
    df:addRow({x = 3})
    local result = df:lazy():dropNil("x"):collect()
    print("lazy dropNil rows = " .. result:nrows())
end

--@api-stub: LLazyQuery:select
-- Adds a column selection step.
do
    local df = lurek.dataframe.fromRows({"a", "b", "c"}, {{1, 2, 3}})
    local result = df:lazy():select({"a", "c"}):collect()
    print("lazy select cols = " .. result:ncols())
end

--@api-stub: LLazyQuery:collect
-- Executes the lazy query and returns a dataframe.
do
    local df = lurek.dataframe.fromRows({"v"}, {{5}, {3}, {8}, {1}})
    local result = df:lazy():sort("v"):head(2):collect()
    print("collected rows = " .. result:nrows())
end

--@api-stub: LLazyQuery:type
-- Returns the type name ("LLazyQuery").
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}})
    local lq = df:lazy()
    print("type = " .. lq:type())
end

--@api-stub: LLazyQuery:typeOf
-- Returns whether this handle matches a type name.
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}})
    local lq = df:lazy()
    print("is LLazyQuery = " .. tostring(lq:typeOf("LLazyQuery")))
end

--@api-stub: LDatabase:addTable
-- Adds a named dataframe table to the database.
do
    local db = lurek.dataframe.newDatabase()
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}})
    db:addTable("scores", df)
    print("added table, count = " .. db:tableCount())
end

--@api-stub: LDatabase:getTable
-- Returns a copy of a named table.
do
    local db = lurek.dataframe.newDatabase()
    local df = lurek.dataframe.fromRows({"x"}, {{42}})
    db:addTable("data", df)
    local t = db:getTable("data")
    print("got table rows = " .. t:nrows())
end

--@api-stub: LDatabase:removeTable
-- Removes a named table.
do
    local db = lurek.dataframe.newDatabase()
    local df = lurek.dataframe.fromRows({"v"}, {{1}})
    db:addTable("tmp", df)
    db:removeTable("tmp")
    print("after remove count = " .. db:tableCount())
end

--@api-stub: LDatabase:hasTable
-- Returns whether a named table exists.
do
    local db = lurek.dataframe.newDatabase()
    local df = lurek.dataframe.fromRows({"v"}, {{1}})
    db:addTable("test", df)
    print("has test = " .. tostring(db:hasTable("test")))
end

--- DataFrame Module Part 3: Database Operations, VecFrame Vectorized Operations


--@api-stub: LDatabase:listTables
-- Returns all table names in the database.
do
    local db = lurek.dataframe.newDatabase()
    local df = lurek.dataframe.fromRows({"v"}, {{1}})
    db:addTable("alpha", df)
    db:addTable("beta", df)
    local names = db:listTables()
    print("tables = " .. #names)
end

--@api-stub: LDatabase:tableCount
-- Returns the number of tables in the database.
do
    local db = lurek.dataframe.newDatabase()
    local df = lurek.dataframe.fromRows({"v"}, {{1}})
    db:addTable("t1", df)
    print("count = " .. db:tableCount())
end

--@api-stub: LDatabase:clear
-- Removes all tables from the database.
do
    local db = lurek.dataframe.newDatabase()
    local df = lurek.dataframe.fromRows({"v"}, {{1}})
    db:addTable("t1", df)
    db:addTable("t2", df)
    db:clear()
    print("after clear = " .. db:tableCount())
end

--@api-stub: LDatabase:merge
-- Merges another database into this one.
do
    local db1 = lurek.dataframe.newDatabase()
    local db2 = lurek.dataframe.newDatabase()
    local df = lurek.dataframe.fromRows({"v"}, {{1}})
    db1:addTable("a", df)
    db2:addTable("b", df)
    db1:merge(db2)
    print("merged count = " .. db1:tableCount())
end

--@api-stub: LDatabase:toJSON
-- Serializes the database to JSON text.
do
    local db = lurek.dataframe.newDatabase()
    local df = lurek.dataframe.fromRows({"x"}, {{42}})
    db:addTable("data", df)
    local json = db:toJSON()
    print("json len = " .. #json)
end

--@api-stub: LDatabase:query
-- Runs a SQL-style query against the database tables.
do
    local db = lurek.dataframe.newDatabase()
    local df = lurek.dataframe.fromRows({"name", "score"}, {{"a", 90}, {"b", 50}})
    db:addTable("players", df)
    local result = db:query("SELECT name FROM players WHERE score > 60")
    print("query rows = " .. result:nrows())
end

--@api-stub: LDatabase:type
-- Returns the type name ("LDatabase").
do
    local db = lurek.dataframe.newDatabase()
    print("type = " .. db:type())
end

--@api-stub: LDatabase:typeOf
-- Returns whether this handle matches a type name.
do
    local db = lurek.dataframe.newDatabase()
    print("is LDatabase = " .. tostring(db:typeOf("LDatabase")))
end

--@api-stub: LVecFrame:colAdd
-- Adds a scalar to a numeric column in place.
do
    local df = lurek.dataframe.fromRows({"a", "b"}, {{1, 10}, {2, 20}, {3, 30}})
    local vf = lurek.dataframe.toVec(df)
    vf:colAdd("a", 100)
    print("colAdd done, nrows = " .. vf:nrows())
end

--@api-stub: LVecFrame:colSub
-- Subtracts a scalar from a numeric column in place.
do
    local df = lurek.dataframe.fromRows({"v"}, {{10}, {20}, {30}})
    local vf = lurek.dataframe.toVec(df)
    vf:colSub("v", 5)
    print("colSub done")
end

--@api-stub: LVecFrame:colMul
-- Multiplies a numeric column by a scalar in place.
do
    local df = lurek.dataframe.fromRows({"v"}, {{2}, {3}, {4}})
    local vf = lurek.dataframe.toVec(df)
    vf:colMul("v", 10)
    print("colMul done")
end

--@api-stub: LVecFrame:colDiv
-- Divides a numeric column by a scalar in place.
do
    local df = lurek.dataframe.fromRows({"v"}, {{100}, {200}, {300}})
    local vf = lurek.dataframe.toVec(df)
    vf:colDiv("v", 10)
    print("colDiv done")
end

--@api-stub: LVecFrame:colAbs
-- Applies absolute value to a numeric column in place.
do
    local df = lurek.dataframe.fromRows({"v"}, {{-5}, {3}, {-1}})
    local vf = lurek.dataframe.toVec(df)
    vf:colAbs("v")
    print("colAbs done")
end

--@api-stub: LVecFrame:colSqrt
-- Applies square root to a numeric column in place.
do
    local df = lurek.dataframe.fromRows({"v"}, {{4}, {9}, {16}})
    local vf = lurek.dataframe.toVec(df)
    vf:colSqrt("v")
    print("colSqrt done")
end

--@api-stub: LVecFrame:colFloor
-- Applies floor to a numeric column in place.
do
    local df = lurek.dataframe.fromRows({"v"}, {{1.7}, {2.3}, {3.9}})
    local vf = lurek.dataframe.toVec(df)
    vf:colFloor("v")
    print("colFloor done")
end

--@api-stub: LVecFrame:colCeil
-- Applies ceil to a numeric column in place.
do
    local df = lurek.dataframe.fromRows({"v"}, {{1.1}, {2.5}, {3.9}})
    local vf = lurek.dataframe.toVec(df)
    vf:colCeil("v")
    print("colCeil done")
end

--@api-stub: LVecFrame:colNeg
-- Negates a numeric column in place.
do
    local df = lurek.dataframe.fromRows({"v"}, {{5}, {-3}, {0}})
    local vf = lurek.dataframe.toVec(df)
    vf:colNeg("v")
    print("colNeg done")
end

--@api-stub: LVecFrame:colClamp
-- Clamps a numeric column in place.
do
    local df = lurek.dataframe.fromRows({"v"}, {{-10}, {5}, {100}})
    local vf = lurek.dataframe.toVec(df)
    vf:colClamp("v", 0, 50)
    print("colClamp done")
end

--@api-stub: LVecFrame:colOp
-- Applies a binary column operation into an output column.
do
    local df = lurek.dataframe.fromRows({"a", "b"}, {{10, 3}, {20, 5}})
    local vf = lurek.dataframe.toVec(df)
    vf:colOp("result", "a", "add", "b")
    print("colOp cols = " .. vf:ncols())
end

--@api-stub: LVecFrame:reduce
-- Reduces a numeric column with a named operation.
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}, {4}})
    local vf = lurek.dataframe.toVec(df)
    local total = vf:reduce("v", "sum")
    print("reduce sum = " .. total)
end

--@api-stub: LVecFrame:filterMask
-- Builds a boolean mask for a column comparison.
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {5}, {3}, {8}})
    local vf = lurek.dataframe.toVec(df)
    local mask = vf:filterMask("v", "gt", 4)
    print("mask len = " .. #mask)
end

--@api-stub: LVecFrame:applyMask
-- Filters rows by a boolean mask table.
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}, {4}})
    local vf = lurek.dataframe.toVec(df)
    local filtered = vf:applyMask({true, false, true, false})
    print("masked rows = " .. filtered:nrows())
end

--@api-stub: LVecFrame:colType
-- Returns the data type name for a column.
do
    local df = lurek.dataframe.fromRows({"v"}, {{1.5}, {2.5}})
    local vf = lurek.dataframe.toVec(df)
    print("colType = " .. vf:colType("v"))
end

--@api-stub: LVecFrame:colCast
-- Casts a column to another data type in place.
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}})
    local vf = lurek.dataframe.toVec(df)
    vf:colCast("v", "f64")
    print("cast to f64 done")
end

--@api-stub: LVecFrame:nrows
-- Returns the number of rows.
do
    local df = lurek.dataframe.fromRows({"a"}, {{1}, {2}, {3}})
    local vf = lurek.dataframe.toVec(df)
    print("nrows = " .. vf:nrows())
end

--@api-stub: LVecFrame:ncols
-- Returns the number of columns.
do
    local df = lurek.dataframe.fromRows({"a", "b"}, {{1, 2}})
    local vf = lurek.dataframe.toVec(df)
    print("ncols = " .. vf:ncols())
end

--@api-stub: LVecFrame:columns
-- Returns all column names in order.
do
    local df = lurek.dataframe.fromRows({"x", "y"}, {{1, 2}})
    local vf = lurek.dataframe.toVec(df)
    local cols = vf:columns()
    print("columns = " .. cols[1] .. ", " .. cols[2])
end

--@api-stub: LVecFrame:parReduce
-- Reduces multiple columns in parallel.
do
    local df = lurek.dataframe.fromRows({"a", "b"}, {{1, 10}, {2, 20}, {3, 30}})
    local vf = lurek.dataframe.toVec(df)
    local results = vf:parReduce({"a", "b"}, "sum")
    print("parReduce a=" .. results.a .. " b=" .. results.b)
end

--@api-stub: LVecFrame:parScalarOp
-- Applies a scalar op to multiple columns in parallel.
do
    local df = lurek.dataframe.fromRows({"a", "b"}, {{1, 10}, {2, 20}})
    local vf = lurek.dataframe.toVec(df)
    vf:parScalarOp({"a", "b"}, "add", 100)
    print("parScalarOp done")
end

--@api-stub: LVecFrame:toDataFrame
-- Converts this vectorized frame back to a dataframe.
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}})
    local vf = lurek.dataframe.toVec(df)
    vf:colAdd("v", 10)
    local df2 = vf:toDataFrame()
    print("toDataFrame rows = " .. df2:nrows())
end

--@api-stub: LVecFrame:type
-- Returns the type name ("LVecFrame").
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}})
    local vf = lurek.dataframe.toVec(df)
    print("type = " .. vf:type())
end

--@api-stub: LVecFrame:typeOf
-- Returns whether this handle matches a type name.
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}})
    local vf = lurek.dataframe.toVec(df)
    print("is VecFrame = " .. tostring(vf:typeOf("VecFrame")))
end

print("content/examples/dataframe.lua")
