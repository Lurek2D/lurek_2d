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

print("dataframe_01.lua")
