-- content/examples/dataframe.lua
-- Auto-generated from content/examples2/dataframe_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/dataframe.lua

--- DataFrame Module Part 1: Creation, Structure, Row/Column Ops, Filtering, Sorting, Grouping, Stats


--@api-stub: lurek.dataframe.newDataFrame
do
    local df = lurek.dataframe.newDataFrame()
    print("new df cols = " .. df:ncols())
end

--@api-stub: lurek.dataframe.newDatabase
do
    local db = lurek.dataframe.newDatabase()
    print("db tables = " .. db:tableCount())
end

--@api-stub: lurek.dataframe.fromTable
do
    local df = lurek.dataframe.fromTable({
        {name = "Alice", age = 30},
        {name = "Bob", age = 25},
    })
    print("fromTable rows = " .. df:nrows())
end

--@api-stub: lurek.dataframe.fromRows
do
    local df = lurek.dataframe.fromRows(
        {"x", "y", "z"},
        {{1, 2, 3}, {4, 5, 6}}
    )
    print("fromRows = " .. df:nrows() .. "x" .. df:ncols())
end

--@api-stub: lurek.dataframe.fromCSV
do
    local csv = "name,score\nAlice,90\nBob,85\n"
    local df = lurek.dataframe.fromCSV(csv)
    print("fromCSV rows = " .. df:nrows())
end

--@api-stub: lurek.dataframe.fromJSON
do
    local json = '[{"id":1,"val":10},{"id":2,"val":20}]'
    local df = lurek.dataframe.fromJSON(json)
    print("fromJSON rows = " .. df:nrows())
end

--@api-stub: lurek.dataframe.fromBinary
do
    local df = lurek.dataframe.fromTable({{a = 1, b = 2}})
    local bin = df:toBinary()
    local restored = lurek.dataframe.fromBinary(bin)
    print("fromBinary rows = " .. restored:nrows())
end

--@api-stub: lurek.dataframe.random
do
    local df = lurek.dataframe.random({{"score", "float"}, {"rank", "int"}}, 10)
    print("random rows = " .. df:nrows())
end

--@api-stub: lurek.dataframe.toVec
do
    local df = lurek.dataframe.fromRows({"a", "b"}, {{1, 2}, {3, 4}})
    local vf = lurek.dataframe.toVec(df)
    print("vecframe rows = " .. vf:nrows())
end

--@api-stub: lurek.dataframe.fromVec
do
    local df = lurek.dataframe.fromRows({"x"}, {{10}, {20}})
    local vf = lurek.dataframe.toVec(df)
    local df2 = lurek.dataframe.fromVec(vf)
    print("fromVec rows = " .. df2:nrows())
end

--@api-stub: LGroupedFrame:aggregate
do
    local gf = lurek.dataframe.fromTable({ { team = "A", score = 10 }, { team = "A", score = 20 } }):groupByObj("team")
    local agg = gf:aggregate("score", function(vals) return vals[1] + vals[2] end)
    print("agg rows = " .. agg:nrows())
end

--@api-stub: LGroupedFrame:type
do
    local df = lurek.dataframe.fromTable({{cat = "x", v = 1}})
    local gf = df:groupByObj("cat")
    print("type = " .. gf:type())
end

--@api-stub: LGroupedFrame:typeOf
do
    local df = lurek.dataframe.fromTable({{cat = "x", v = 1}})
    local gf = df:groupByObj("cat")
    print("is LGroupedFrame = " .. tostring(gf:typeOf("LGroupedFrame")))
end

--@api-stub: LDataFrame:nrows
do
    local df = lurek.dataframe.fromRows({"a"}, {{1}, {2}, {3}})
    print("nrows = " .. df:nrows())
end

--@api-stub: LDataFrame:ncols
do
    local df = lurek.dataframe.fromRows({"a", "b", "c"}, {{1, 2, 3}})
    print("ncols = " .. df:ncols())
end

--@api-stub: LDataFrame:columns
do
    local df = lurek.dataframe.fromRows({"x", "y"}, {{1, 2}})
    local cols = df:columns()
    print("cols = " .. cols[1] .. ", " .. cols[2])
end

--@api-stub: LDataFrame:count
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}})
    print("count = " .. df:count())
end

--@api-stub: LDataFrame:addColumn
do
    local df = lurek.dataframe.fromRows({"a"}, {{1}, {2}})
    df:addColumn("b", 0)
    print("after addColumn ncols = " .. df:ncols())
end

--@api-stub: LDataFrame:removeColumn
do
    local df = lurek.dataframe.fromRows({"a", "b"}, {{1, 2}})
    df:removeColumn("b")
    print("after removeColumn ncols = " .. df:ncols())
end

--@api-stub: LDataFrame:rename
do
    local df = lurek.dataframe.fromRows({"old_name"}, {{1}})
    df:rename("old_name", "new_name")
    local cols = df:columns()
    print("renamed = " .. cols[1])
end

--@api-stub: LDataFrame:getColumn
do
    local df = lurek.dataframe.fromRows({"score"}, {{10}, {20}, {30}})
    local col = df:getColumn("score")
    print("col[2] = " .. col[2])
end

--@api-stub: LDataFrame:addRow
do
    local df = lurek.dataframe.fromRows({"name", "val"}, {{"a", 1}})
    local idx = df:addRow({name = "b", val = 2})
    print("added at row " .. idx)
end

--@api-stub: LDataFrame:removeRow
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}})
    df:removeRow(2)
    print("after remove nrows = " .. df:nrows())
end

--@api-stub: LDataFrame:getRow
do
    local df = lurek.dataframe.fromTable({{name = "Alice", age = 30}})
    local row = df:getRow(1)
    print("row name = " .. row.name)
end

--@api-stub: LDataFrame:getValue
do
    local df = lurek.dataframe.fromRows({"a", "b"}, {{10, 20}, {30, 40}})
    local val = df:getValue(2, "b")
    print("cell[2,b] = " .. val)
end

--@api-stub: LDataFrame:setValue
do
    local df = lurek.dataframe.fromRows({"x"}, {{0}, {0}})
    df:setValue(1, "x", 99)
    print("after set = " .. df:getValue(1, "x"))
end

--@api-stub: LDataFrame:filter
do
    local df = lurek.dataframe.fromRows({"score"}, {{10}, {50}, {80}, {30}})
    local filtered = df:filter("score", ">", 40)
    print("filtered rows = " .. filtered:nrows())
end

--@api-stub: LDataFrame:sort
do
    local df = lurek.dataframe.fromRows({"v"}, {{3}, {1}, {2}})
    local sorted = df:sort("v", true)
    print("sorted first = " .. sorted:getValue(1, "v"))
end

--@api-stub: LDataFrame:head
do
    local df = lurek.dataframe.fromRows({"x"}, {{1}, {2}, {3}, {4}, {5}})
    local top = df:head(3)
    print("head rows = " .. top:nrows())
end

--@api-stub: LDataFrame:tail
do
    local df = lurek.dataframe.fromRows({"x"}, {{1}, {2}, {3}, {4}, {5}})
    local bottom = df:tail(2)
    print("tail rows = " .. bottom:nrows())
end

--@api-stub: LDataFrame:slice
do
    local df = lurek.dataframe.fromRows({"x"}, {{1}, {2}, {3}, {4}, {5}})
    local mid = df:slice(2, 4)
    print("slice rows = " .. mid:nrows())
end

--@api-stub: LDataFrame:select
do
    local df = lurek.dataframe.fromRows({"a", "b", "c"}, {{1, 2, 3}})
    local sub = df:select("a", "c")
    print("select ncols = " .. sub:ncols())
end

--@api-stub: LDataFrame:unique
do
    local df = lurek.dataframe.fromRows({"color"}, {{"red"}, {"blue"}, {"red"}, {"green"}})
    local uniq = df:unique("color")
    print("unique count = " .. #uniq)
end

--@api-stub: LDataFrame:groupBy
do
    local groups = lurek.dataframe.fromTable({ { team = "A", pts = 10 }, { team = "B", pts = 20 } }):groupBy("team")
    print("group A rows = " .. groups["A"]:nrows())
end

--@api-stub: LDataFrame:groupByObj
do
    local df = lurek.dataframe.fromTable({
        {cat = "x", v = 1}, {cat = "y", v = 2},
    })
    local gf = df:groupByObj("cat")
    print("grouped type = " .. gf:type())
end

--@api-stub: LDataFrame:join
do
    local left = lurek.dataframe.fromTable({{id = 1, name = "A"}, {id = 2, name = "B"}})
    local right = lurek.dataframe.fromTable({{id = 1, score = 90}, {id = 2, score = 80}})
    local joined = left:join(right, "id", "id", "inner")
    print("joined cols = " .. joined:ncols())
end

--@api-stub: LDataFrame:merge
do
    local a = lurek.dataframe.fromRows({"v"}, {{1}, {2}})
    local b = lurek.dataframe.fromRows({"v"}, {{3}, {4}})
    a:merge(b)
    print("after merge rows = " .. a:nrows())
end

--@api-stub: LDataFrame:countBy
do
    local df = lurek.dataframe.fromRows({"fruit"}, {{"apple"}, {"banana"}, {"apple"}})
    local counts = df:countBy("fruit")
    print("countBy rows = " .. counts:nrows())
end

--@api-stub: LDataFrame:dropNil
do
    local df = lurek.dataframe.newDataFrame()
    df:addColumn("x")
    df:addRow({x = 1})
    df:addRow({})
    print("after dropNil rows = " .. df:dropNil("x"):nrows())
end

--@api-stub: LDataFrame:sample
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}})
    local s = df:sample(3, 42)
    print("sample rows = " .. s:nrows())
end

--@api-stub: LDataFrame:describe
do
    local df = lurek.dataframe.fromRows({"score"}, {{10}, {20}, {30}, {40}, {50}})
    local stats = df:describe()
    print("describe rows = " .. stats:nrows())
end

--@api-stub: LDataFrame:sum
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}, {4}})
    print("sum = " .. df:sum("v"))
end

--@api-stub: LDataFrame:mean
do
    local df = lurek.dataframe.fromRows({"v"}, {{10}, {20}, {30}})
    print("mean = " .. df:mean("v"))
end

--@api-stub: LDataFrame:min
do
    local df = lurek.dataframe.fromRows({"v"}, {{5}, {1}, {8}})
    print("min = " .. df:min("v"))
end

--@api-stub: LDataFrame:max
do
    local df = lurek.dataframe.fromRows({"v"}, {{5}, {1}, {8}})
    print("max = " .. df:max("v"))
end

--@api-stub: LDataFrame:median
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}, {4}, {5}})
    print("median = " .. df:median("v"))
end

--@api-stub: LDataFrame:stddev
do
    local df = lurek.dataframe.fromRows({"v"}, {{2}, {4}, {4}, {4}, {5}, {5}, {7}, {9}})
    print("stddev = " .. df:stddev("v"))
end

--@api-stub: LDataFrame:variance
do
    local df = lurek.dataframe.fromRows({"v"}, {{2}, {4}, {4}, {4}, {5}, {5}, {7}, {9}})
    print("variance = " .. df:variance("v"))
end

--@api-stub: LDataFrame:fillNil
do
    local df = lurek.dataframe.newDataFrame()
    df:addColumn("x")
    df:addRow({})
    df:fillNil("x", 0)
    print("filled = " .. df:getValue(2, "x"))
end

--@api-stub: LDataFrame:apply
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}})
    df:apply("v", function(x) return (x or 0) * 10 end)
    print("applied[2] = " .. df:getValue(2, "v"))
end

--- DataFrame Module Part 2: Serialization, Query, Rolling, Rank, Pivot, Correlation, Normalize, LazyQuery, Database


--@api-stub: LDataFrame:toCSV
do
    local df = lurek.dataframe.fromRows({"name", "val"}, {{"a", 1}, {"b", 2}})
    local csv = df:toCSV()
    print("csv len = " .. #csv)
end

--@api-stub: LDataFrame:toJSON
do
    local df = lurek.dataframe.fromRows({"x"}, {{10}, {20}})
    local json = df:toJSON()
    print("json len = " .. #json)
end

--@api-stub: LDataFrame:toBinary
do
    local df = lurek.dataframe.fromRows({"a"}, {{1}, {2}})
    local bin = df:toBinary()
    print("binary len = " .. #bin)
end

--@api-stub: LDataFrame:toTable
do
    local df = lurek.dataframe.fromRows({"k", "v"}, {{"x", 1}, {"y", 2}})
    local t = df:toTable()
    print("table rows = " .. #t)
end

--@api-stub: LDataFrame:rows
do
    local df = lurek.dataframe.fromRows({"v"}, {{10}, {20}, {30}})
    local count = 0
    for _, _ in df:rows() do count = count + 1 end
    print("iterated rows = " .. count)
end

--@api-stub: LDataFrame:toString
do
    local df = lurek.dataframe.fromRows({"x", "y"}, {{1, 2}})
    local s = df:toString()
    print("toString len = " .. #s)
end

--@api-stub: LDataFrame:query
do
    local df = lurek.dataframe.fromRows({"name", "score"}, {{"a", 90}, {"b", 50}, {"c", 80}})
    local result = df:query("SELECT name FROM self WHERE score > 60")
    print("query rows = " .. result:nrows())
end

--@api-stub: LDataFrame:clone
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}})
    local copy = df:clone()
    copy:setValue(1, "v", 99)
    print("original[1] = " .. df:getValue(1, "v"))
end

--@api-stub: LDataFrame:withRollingMean
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}, {4}, {5}})
    df:withRollingMean("v", 3, "rm")
    print("rolling mean cols = " .. df:ncols())
end

--@api-stub: LDataFrame:withRollingSum
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}, {4}})
    df:withRollingSum("v", 2, "rs")
    print("rolling sum cols = " .. df:ncols())
end

--@api-stub: LDataFrame:withRollingMin
do
    local df = lurek.dataframe.fromRows({"v"}, {{5}, {3}, {8}, {1}})
    df:withRollingMin("v", 2, "rmin")
    print("rolling min cols = " .. df:ncols())
end

--@api-stub: LDataFrame:withRollingMax
do
    local df = lurek.dataframe.fromRows({"v"}, {{5}, {3}, {8}, {1}})
    df:withRollingMax("v", 2, "rmax")
    print("rolling max cols = " .. df:ncols())
end

--@api-stub: LDataFrame:withRank
do
    local df = lurek.dataframe.fromRows({"score"}, {{30}, {10}, {20}})
    df:withRank("score", true, "rank")
    print("rank cols = " .. df:ncols())
end

--@api-stub: LDataFrame:withPctChange
do
    local df = lurek.dataframe.fromRows({"v"}, {{100}, {110}, {105}})
    df:withPctChange("v", "pct")
    print("pct change cols = " .. df:ncols())
end

--@api-stub: LDataFrame:withCumsum
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}, {4}})
    df:withCumsum("v", "csum")
    print("cumsum cols = " .. df:ncols())
end

--@api-stub: LDataFrame:groupAgg
do
    local df = lurek.dataframe.fromTable({
        {cat = "A", v = 10}, {cat = "A", v = 20}, {cat = "B", v = 30},
    })
    local agg = df:groupAgg("cat", "v", "sum")
    print("groupAgg rows = " .. agg:nrows())
end

--@api-stub: LDataFrame:pivot
do
    local pv = lurek.dataframe.fromTable({ { row = "r1", col = "c1", val = 10 }, { row = "r1", col = "c2", val = 20 }, { row = "r2", col = "c1", val = 30 } }):pivot("row", "col", "val")
    print("pivot cols = " .. pv:ncols())
end

--@api-stub: LDataFrame:corr
do
    local df = lurek.dataframe.fromRows({"a", "b"}, {{1, 2}, {2, 4}, {3, 6}})
    print("corr = " .. df:corr("a", "b"))
end

--@api-stub: LDataFrame:correlationMatrix
do
    local df = lurek.dataframe.fromRows({"x", "y"}, {{1, 2}, {2, 4}, {3, 6}})
    local cm = df:correlationMatrix()
    print("corr matrix cols = " .. cm:ncols())
end

--@api-stub: LDataFrame:zscoreCol
do
    local df = lurek.dataframe.fromRows({"v"}, {{2}, {4}, {4}, {4}, {5}, {5}, {7}, {9}})
    df:zscoreCol("v", "z")
    print("zscore cols = " .. df:ncols())
end

--@api-stub: LDataFrame:normalizeCol
do
    local df = lurek.dataframe.fromRows({"v"}, {{0}, {50}, {100}})
    df:normalizeCol("v", 0, 1, "norm")
    print("normalize cols = " .. df:ncols())
end

--@api-stub: LDataFrame:outliers
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}, {100}, {2}, {3}})
    local out = df:outliers("v", 2.0)
    print("outlier rows = " .. out:nrows())
end

--@api-stub: LDataFrame:modeVal
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {2}, {3}})
    print("mode = " .. df:modeVal("v"))
end

--@api-stub: LDataFrame:entropy
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {1}, {2}, {2}, {3}})
    print("entropy = " .. df:entropy("v"))
end

--@api-stub: LDataFrame:addRowBatch
do
    local df = lurek.dataframe.fromRows({"a", "b"}, {{1, 2}})
    df:addRowBatch({{3, 4}, {5, 6}})
    print("after batch rows = " .. df:nrows())
end

--@api-stub: LDataFrame:getColumnAsF64
do
    local df = lurek.dataframe.fromRows({"score"}, {{10}, {20}, {30}})
    local vals = df:getColumnAsF64("score")
    print("f64[2] = " .. vals[2])
end

--@api-stub: LDataFrame:setColumnFromF64
do
    local df = lurek.dataframe.fromRows({"v"}, {{0}, {0}, {0}})
    df:setColumnFromF64("v", {100, 200, 300})
    print("after set[3] = " .. df:getValue(3, "v"))
end

--@api-stub: LDataFrame:type
do
    local df = lurek.dataframe.newDataFrame()
    print("type = " .. df:type())
end

--@api-stub: LDataFrame:typeOf
do
    local df = lurek.dataframe.newDataFrame()
    print("is LDataFrame = " .. tostring(df:typeOf("LDataFrame")))
end

--@api-stub: LDataFrame:withEval
do
    local df = lurek.dataframe.fromRows({"a", "b"}, {{1, 2}, {3, 4}})
    local result = df:withEval("sum", "a + b")
    print("eval cols = " .. result:ncols())
end

--@api-stub: LDataFrame:pivotTable
do
    local pt = lurek.dataframe.fromTable({ { region = "N", product = "X", sales = 10 }, { region = "N", product = "Y", sales = 20 }, { region = "S", product = "X", sales = 30 } }):pivotTable("region", "product", "sales", "sum")
    print("pivotTable rows = " .. pt:nrows())
end

--@api-stub: LDataFrame:rollingMean
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}, {4}, {5}})
    local rm = df:rollingMean("v", 3)
    print("rollingMean cols = " .. rm:ncols())
end

--@api-stub: LDataFrame:rollingSum
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}, {4}})
    local rs = df:rollingSum("v", 2)
    print("rollingSum cols = " .. rs:ncols())
end

--@api-stub: LDataFrame:rank
do
    local df = lurek.dataframe.fromRows({"score"}, {{30}, {10}, {20}})
    local ranked = df:rank("score", "asc")
    print("rank cols = " .. ranked:ncols())
end

--@api-stub: LDataFrame:lazy
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}})
    local lq = df:lazy()
    print("lazy type = " .. lq:type())
end

--@api-stub: LLazyQuery:filter
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}, {4}, {5}})
    local result = df:lazy():filter("v", ">", 3):collect()
    print("lazy filter rows = " .. result:nrows())
end

--@api-stub: LLazyQuery:sort
do
    local df = lurek.dataframe.fromRows({"v"}, {{3}, {1}, {2}})
    local result = df:lazy():sort("v", true):collect()
    print("lazy sort first = " .. result:getValue(1, "v"))
end

--@api-stub: LLazyQuery:head
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}, {4}, {5}})
    local result = df:lazy():head(2):collect()
    print("lazy head rows = " .. result:nrows())
end

--@api-stub: LLazyQuery:tail
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}, {4}, {5}})
    local result = df:lazy():tail(2):collect()
    print("lazy tail rows = " .. result:nrows())
end

--@api-stub: LLazyQuery:limit
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}, {4}})
    local result = df:lazy():limit(2):collect()
    print("lazy limit rows = " .. result:nrows())
end

--@api-stub: LLazyQuery:slice
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}, {4}, {5}})
    local result = df:lazy():slice(2, 4):collect()
    print("lazy slice rows = " .. result:nrows())
end

--@api-stub: LLazyQuery:dropNil
do
    local df = lurek.dataframe.newDataFrame()
    df:addColumn("x")
    df:addRow({x = 1})
    df:addRow({})
    print("lazy dropNil rows = " .. df:lazy():dropNil("x"):collect():nrows())
end

--@api-stub: LLazyQuery:select
do
    local df = lurek.dataframe.fromRows({"a", "b", "c"}, {{1, 2, 3}})
    local result = df:lazy():select({"a", "c"}):collect()
    print("lazy select cols = " .. result:ncols())
end

--@api-stub: LLazyQuery:collect
do
    local df = lurek.dataframe.fromRows({"v"}, {{5}, {3}, {8}, {1}})
    local result = df:lazy():sort("v"):head(2):collect()
    print("collected rows = " .. result:nrows())
end

--@api-stub: LLazyQuery:type
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}})
    local lq = df:lazy()
    print("type = " .. lq:type())
end

--@api-stub: LLazyQuery:typeOf
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}})
    local lq = df:lazy()
    print("is LLazyQuery = " .. tostring(lq:typeOf("LLazyQuery")))
end

--@api-stub: LDatabase:addTable
do
    local db = lurek.dataframe.newDatabase()
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}})
    db:addTable("scores", df)
    print("added table, count = " .. db:tableCount())
end

--@api-stub: LDatabase:getTable
do
    local db = lurek.dataframe.newDatabase()
    local df = lurek.dataframe.fromRows({"x"}, {{42}})
    db:addTable("data", df)
    local t = db:getTable("data")
    print("got table rows = " .. t:nrows())
end

--@api-stub: LDatabase:removeTable
do
    local db = lurek.dataframe.newDatabase()
    local df = lurek.dataframe.fromRows({"v"}, {{1}})
    db:addTable("tmp", df)
    db:removeTable("tmp")
    print("after remove count = " .. db:tableCount())
end

--@api-stub: LDatabase:hasTable
do
    local db = lurek.dataframe.newDatabase()
    local df = lurek.dataframe.fromRows({"v"}, {{1}})
    db:addTable("test", df)
    print("has test = " .. tostring(db:hasTable("test")))
end

--- DataFrame Module Part 3: Database Operations, VecFrame Vectorized Operations


--@api-stub: LDatabase:listTables
do
    local db = lurek.dataframe.newDatabase()
    local df = lurek.dataframe.fromRows({"v"}, {{1}})
    db:addTable("alpha", df)
    db:addTable("beta", df)
    print("tables = " .. #db:listTables())
end

--@api-stub: LDatabase:tableCount
do
    local db = lurek.dataframe.newDatabase()
    local df = lurek.dataframe.fromRows({"v"}, {{1}})
    db:addTable("t1", df)
    print("count = " .. db:tableCount())
end

--@api-stub: LDatabase:clear
do
    local db = lurek.dataframe.newDatabase()
    local df = lurek.dataframe.fromRows({"v"}, {{1}})
    db:addTable("t1", df)
    db:clear()
    print("after clear = " .. db:tableCount())
end

--@api-stub: LDatabase:merge
do
    local db1, db2 = lurek.dataframe.newDatabase(), lurek.dataframe.newDatabase()
    db1:addTable("a", lurek.dataframe.fromRows({"v"}, {{1}}))
    db2:addTable("b", lurek.dataframe.fromRows({"v"}, {{1}}))
    db1:merge(db2)
    print("merged count = " .. db1:tableCount())
end

--@api-stub: LDatabase:toJSON
do
    local db = lurek.dataframe.newDatabase()
    local df = lurek.dataframe.fromRows({"x"}, {{42}})
    db:addTable("data", df)
    local json = db:toJSON()
    print("json len = " .. #json)
end

--@api-stub: LDatabase:query
do
    local db = lurek.dataframe.newDatabase()
    local df = lurek.dataframe.fromRows({"name", "score"}, {{"a", 90}, {"b", 50}})
    db:addTable("players", df)
    local result = db:query("SELECT name FROM players WHERE score > 60")
    print("query rows = " .. result:nrows())
end

--@api-stub: LDatabase:type
do
    local db = lurek.dataframe.newDatabase()
    print("type = " .. db:type())
end

--@api-stub: LDatabase:typeOf
do
    local db = lurek.dataframe.newDatabase()
    print("is LDatabase = " .. tostring(db:typeOf("LDatabase")))
end

--@api-stub: LVecFrame:colAdd
do
    local df = lurek.dataframe.fromRows({"a", "b"}, {{1, 10}, {2, 20}, {3, 30}})
    local vf = lurek.dataframe.toVec(df)
    vf:colAdd("a", 100)
    print("colAdd done, nrows = " .. vf:nrows())
end

--@api-stub: LVecFrame:colSub
do
    local df = lurek.dataframe.fromRows({"v"}, {{10}, {20}, {30}})
    local vf = lurek.dataframe.toVec(df)
    vf:colSub("v", 5)
    print("colSub done")
end

--@api-stub: LVecFrame:colMul
do
    local df = lurek.dataframe.fromRows({"v"}, {{2}, {3}, {4}})
    local vf = lurek.dataframe.toVec(df)
    vf:colMul("v", 10)
    print("colMul done")
end

--@api-stub: LVecFrame:colDiv
do
    local df = lurek.dataframe.fromRows({"v"}, {{100}, {200}, {300}})
    local vf = lurek.dataframe.toVec(df)
    vf:colDiv("v", 10)
    print("colDiv done")
end

--@api-stub: LVecFrame:colAbs
do
    local df = lurek.dataframe.fromRows({"v"}, {{-5}, {3}, {-1}})
    local vf = lurek.dataframe.toVec(df)
    vf:colAbs("v")
    print("colAbs done")
end

--@api-stub: LVecFrame:colSqrt
do
    local df = lurek.dataframe.fromRows({"v"}, {{4}, {9}, {16}})
    local vf = lurek.dataframe.toVec(df)
    vf:colSqrt("v")
    print("colSqrt done")
end

--@api-stub: LVecFrame:colFloor
do
    local df = lurek.dataframe.fromRows({"v"}, {{1.7}, {2.3}, {3.9}})
    local vf = lurek.dataframe.toVec(df)
    vf:colFloor("v")
    print("colFloor done")
end

--@api-stub: LVecFrame:colCeil
do
    local df = lurek.dataframe.fromRows({"v"}, {{1.1}, {2.5}, {3.9}})
    local vf = lurek.dataframe.toVec(df)
    vf:colCeil("v")
    print("colCeil done")
end

--@api-stub: LVecFrame:colNeg
do
    local df = lurek.dataframe.fromRows({"v"}, {{5}, {-3}, {0}})
    local vf = lurek.dataframe.toVec(df)
    vf:colNeg("v")
    print("colNeg done")
end

--@api-stub: LVecFrame:colClamp
do
    local df = lurek.dataframe.fromRows({"v"}, {{-10}, {5}, {100}})
    local vf = lurek.dataframe.toVec(df)
    vf:colClamp("v", 0, 50)
    print("colClamp done")
end

--@api-stub: LVecFrame:colOp
do
    local df = lurek.dataframe.fromRows({"a", "b"}, {{10, 3}, {20, 5}})
    local vf = lurek.dataframe.toVec(df)
    vf:colOp("result", "a", "add", "b")
    print("colOp cols = " .. vf:ncols())
end

--@api-stub: LVecFrame:reduce
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}, {4}})
    local vf = lurek.dataframe.toVec(df)
    local total = vf:reduce("v", "sum")
    print("reduce sum = " .. total)
end

--@api-stub: LVecFrame:filterMask
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {5}, {3}, {8}})
    local vf = lurek.dataframe.toVec(df)
    local mask = vf:filterMask("v", "gt", 4)
    print("mask len = " .. #mask)
end

--@api-stub: LVecFrame:applyMask
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}, {4}})
    local vf = lurek.dataframe.toVec(df)
    local filtered = vf:applyMask({true, false, true, false})
    print("masked rows = " .. filtered:nrows())
end

--@api-stub: LVecFrame:colType
do
    local df = lurek.dataframe.fromRows({"v"}, {{1.5}, {2.5}})
    local vf = lurek.dataframe.toVec(df)
    print("colType = " .. vf:colType("v"))
end

--@api-stub: LVecFrame:colCast
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}, {3}})
    local vf = lurek.dataframe.toVec(df)
    vf:colCast("v", "f64")
    print("cast to f64 done")
end

--@api-stub: LVecFrame:nrows
do
    local df = lurek.dataframe.fromRows({"a"}, {{1}, {2}, {3}})
    local vf = lurek.dataframe.toVec(df)
    print("nrows = " .. vf:nrows())
end

--@api-stub: LVecFrame:ncols
do
    local df = lurek.dataframe.fromRows({"a", "b"}, {{1, 2}})
    local vf = lurek.dataframe.toVec(df)
    print("ncols = " .. vf:ncols())
end

--@api-stub: LVecFrame:columns
do
    local df = lurek.dataframe.fromRows({"x", "y"}, {{1, 2}})
    local vf = lurek.dataframe.toVec(df)
    local cols = vf:columns()
    print("columns = " .. cols[1] .. ", " .. cols[2])
end

--@api-stub: LVecFrame:parReduce
do
    local df = lurek.dataframe.fromRows({"a", "b"}, {{1, 10}, {2, 20}, {3, 30}})
    local vf = lurek.dataframe.toVec(df)
    local results = vf:parReduce({"a", "b"}, "sum")
    print("parReduce a=" .. results.a .. " b=" .. results.b)
end

--@api-stub: LVecFrame:parScalarOp
do
    local df = lurek.dataframe.fromRows({"a", "b"}, {{1, 10}, {2, 20}})
    local vf = lurek.dataframe.toVec(df)
    vf:parScalarOp({"a", "b"}, "add", 100)
    print("parScalarOp done")
end

--@api-stub: LVecFrame:toDataFrame
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}, {2}})
    local vf = lurek.dataframe.toVec(df)
    vf:colAdd("v", 10)
    local df2 = vf:toDataFrame()
    print("toDataFrame rows = " .. df2:nrows())
end

--@api-stub: LVecFrame:type
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}})
    local vf = lurek.dataframe.toVec(df)
    print("type = " .. vf:type())
end

--@api-stub: LVecFrame:typeOf
do
    local df = lurek.dataframe.fromRows({"v"}, {{1}})
    local vf = lurek.dataframe.toVec(df)
    print("is VecFrame = " .. tostring(vf:typeOf("VecFrame")))
end

print("content/examples/dataframe.lua")
