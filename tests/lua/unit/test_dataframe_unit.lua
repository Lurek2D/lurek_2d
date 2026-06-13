-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_dataframe_core_unit.lua
do
-- Canonical unit coverage for lurek.dataframe.

local TMP = "save/"

local function make_test_df()
    return lurek.dataframe.fromCSV("name,age,score\nAlice,30,90\nBob,25,85\nCharlie,35,92\n")
end

local function make_group_df()
    return lurek.dataframe.fromRows(
        { "dept", "name", "score" },
        {
            { "eng", "Alice", 90 },
            { "eng", "Bob", 85 },
            { "sales", "Cara", 88 },
        }
    )
end

local function make_stats_df()
    return lurek.dataframe.fromRows(
        { "value" },
        {
            { 10 },
            { 20 },
            { 30 },
            { 40 },
        }
    )
end

local function make_vec_df()
    return lurek.dataframe.fromCSV("hp,mp\n10,5\n20,10\n30,15\n")
end

-- @describe lurek.dataframe namespace
describe("lurek.dataframe namespace", function()
end)

-- @describe dataframe factories
describe("dataframe factories", function()
    -- @covers lurek.dataframe.newDataFrame
    it("newDataFrame creates an empty dataframe", function()
        local df = lurek.dataframe.newDataFrame()
        expect_equal(0, df:nrows())
        expect_equal(0, df:ncols())
    end)

    -- @covers lurek.dataframe.fromCSV
    it("fromCSV parses columns and values", function()
        local df = make_test_df()
        expect_equal("Alice", df:getValue(1, "name"))
        expect_near(25, df:getValue(2, "age"), 1e-5)
    end)

    -- @covers lurek.dataframe.fromTable
    it("fromTable builds rows from keyed tables", function()
        local df = lurek.dataframe.fromTable({
            { x = 1, y = 2 },
            { x = 3, y = 4 },
        })
        expect_equal(2, df:nrows())
        expect_equal(2, df:ncols())
    end)

    -- @covers lurek.dataframe.fromRows
    it("fromRows respects declared column order", function()
        local df = lurek.dataframe.fromRows(
            { "id", "label" },
            {
                { 1, "one" },
                { 2, "two" },
            }
        )
        expect_equal("two", df:getValue(2, "label"))
    end)

    -- @covers lurek.dataframe.fromJSON
    it("fromJSON parses an array of objects", function()
        local df = lurek.dataframe.fromJSON('[{"a":1,"b":"x"},{"a":2,"b":"y"}]')
        expect_equal(2, df:nrows())
        expect_equal("y", df:getValue(2, "b"))
    end)

    -- @covers lurek.dataframe.random
    it("random is deterministic with a seed", function()
        local defs = { { "value", "float" } }
        local left = lurek.dataframe.random(defs, 3, 123)
        local right = lurek.dataframe.random(defs, 3, 123)
        expect_near(left:getValue(1, "value"), right:getValue(1, "value"), 1e-5)
        expect_near(left:getValue(3, "value"), right:getValue(3, "value"), 1e-5)
    end)

    -- @covers lurek.dataframe.fromCSVFile
    it("fromCSVFile loads a file written by the fixture", function()
        local path = TMP .. "dataframe_from_csv_file.csv"
        lurek.filesystem.write(path, "x,y\n1,2\n3,4\n")
        local df = lurek.dataframe.fromCSVFile(path)
        expect_equal(2, df:nrows())
        expect_near(4, df:getValue(2, "y"), 1e-5)
    end)

    -- @covers lurek.dataframe.fromJSONFile
    it("fromJSONFile loads json rows from disk", function()
        local path = TMP .. "dataframe_from_json_file.json"
        lurek.filesystem.writeJson(path, '[{"name":"A"},{"name":"B"}]')
        local df = lurek.dataframe.fromJSONFile(path)
        expect_equal(2, df:nrows())
        expect_equal("B", df:getValue(2, "name"))
    end)

    -- @covers lurek.dataframe.fromBinary
    it("fromBinary restores bytes produced by toBinary", function()
        local restored = lurek.dataframe.fromBinary(make_test_df():toBinary())
        expect_equal(3, restored:nrows())
        expect_equal("Charlie", restored:getValue(3, "name"))
    end)

    -- @covers lurek.dataframe.toVec
    it("toVec converts a dataframe into a vec frame", function()
        local vf = lurek.dataframe.toVec(make_vec_df())
        expect_type("userdata", vf)
        expect_equal(3, vf:nrows())
    end)

    -- @covers lurek.dataframe.fromVec
    it("fromVec converts a vec frame back into a dataframe", function()
        local vf = lurek.dataframe.toVec(make_vec_df())
        local df = lurek.dataframe.fromVec(vf)
        expect_equal(3, df:nrows())
        expect_near(5, df:getValue(1, "mp"), 1e-5)
    end)
end)

-- @describe dataframe shape and mutation
describe("dataframe shape and mutation", function()
    -- @covers LDataFrame:nrows
    it("nrows reports the number of rows", function()
        expect_equal(3, make_test_df():nrows())
    end)

    -- @covers LDataFrame:ncols
    it("ncols reports the number of columns", function()
        expect_equal(3, make_test_df():ncols())
    end)

    -- @covers LDataFrame:columns
    it("columns returns ordered column names", function()
        local cols = make_test_df():columns()
        expect_equal("name", cols[1])
        expect_equal("score", cols[3])
    end)

    -- @covers LDataFrame:schema
    it("schema returns inferred column metadata", function()
        local schema = make_test_df():schema()
        expect_equal("name", schema[1].name)
        expect_equal("text", schema[1].dtype)
        expect_equal(false, schema[1].nullable)
        expect_equal(3, schema[1].count)
        expect_equal("number", schema[2].dtype)
    end)

    -- @covers LDataFrame:explain
    it("explain returns dataframe and sql plan summaries", function()
        local df = make_test_df()
        local frame_plan = df:explain()
        expect_true(string.find(frame_plan, "DataFrame: rows=3", 1, true) ~= nil)
        local sql_plan = df:explain("SELECT name FROM self WHERE age > 28 ORDER BY score DESC LIMIT 2")
        expect_true(string.find(sql_plan, "SQL DataFrame Plan", 1, true) ~= nil)
        expect_true(string.find(sql_plan, "order_by: score DESC", 1, true) ~= nil)
    end)

    -- @covers LDataFrame:getValue
    it("getValue reads a single cell", function()
        expect_near(92, make_test_df():getValue(3, "score"), 1e-5)
    end)

    -- @covers LDataFrame:count
    it("count matches the row count", function()
        local df = make_test_df()
        expect_equal(df:nrows(), df:count())
    end)

    -- @covers LDataFrame:addColumn
    it("addColumn appends a new column", function()
        local df = make_test_df()
        df:addColumn("rank", 0)
        expect_equal(4, df:ncols())
        expect_near(0, df:getValue(1, "rank"), 1e-5)
    end)

    -- @covers LDataFrame:removeColumn
    it("removeColumn deletes an existing column", function()
        local df = make_test_df()
        df:removeColumn("score")
        expect_equal(2, df:ncols())
    end)

    -- @covers LDataFrame:rename
    it("rename changes the visible column name", function()
        local df = make_test_df()
        df:rename("score", "points")
        expect_near(90, df:getValue(1, "points"), 1e-5)
    end)

    -- @covers LDataFrame:getColumn
    it("getColumn returns an indexed lua table", function()
        local scores = make_test_df():getColumn("score")
        expect_near(90, scores[1], 1e-5)
        expect_near(92, scores[3], 1e-5)
    end)

    -- @covers LDataFrame:addRow
    it("addRow appends a record", function()
        local df = make_test_df()
        df:addRow({ name = "Dana", age = 28, score = 81 })
        expect_equal(4, df:nrows())
        expect_equal("Dana", df:getValue(4, "name"))
    end)

    -- @covers LDataFrame:removeRow
    it("removeRow shrinks the dataset", function()
        local df = make_test_df()
        df:removeRow(2)
        expect_equal(2, df:nrows())
        expect_equal("Charlie", df:getValue(2, "name"))
    end)

    -- @covers LDataFrame:getRow
    it("getRow returns a keyed lua table", function()
        local row = make_test_df():getRow(2)
        expect_equal("Bob", row.name)
        expect_near(85, row.score, 1e-5)
    end)

    -- @covers LDataFrame:setValue
    it("setValue updates an existing cell", function()
        local df = make_test_df()
        df:setValue(2, "score", 87)
        expect_near(87, df:getValue(2, "score"), 1e-5)
    end)
end)

-- @describe dataframe transforms
describe("dataframe transforms", function()
    -- @covers LDataFrame:filter
    it("filter keeps matching rows", function()
        local df = make_test_df():filter("age", ">", 28)
        expect_equal(2, df:nrows())
    end)

    -- @covers LDataFrame:sort
    it("sort orders rows by a column", function()
        local df = make_test_df():sort("age", "asc")
        expect_equal("Bob", df:getValue(1, "name"))
    end)

    -- @covers LDataFrame:head
    it("head returns the leading rows", function()
        local df = make_test_df():head(2)
        expect_equal(2, df:nrows())
        expect_equal("Bob", df:getValue(2, "name"))
    end)

    -- @covers LDataFrame:tail
    it("tail returns the trailing rows", function()
        local df = make_test_df():tail(2)
        expect_equal(2, df:nrows())
        expect_equal("Charlie", df:getValue(2, "name"))
    end)

    -- @covers LDataFrame:slice
    it("slice returns a row range", function()
        local df = make_test_df():slice(2, 3)
        expect_equal(2, df:nrows())
        expect_equal("Bob", df:getValue(1, "name"))
    end)

    -- @covers LDataFrame:select
    it("select keeps only chosen columns", function()
        local df = make_test_df():select("name", "score")
        expect_equal(2, df:ncols())
        expect_near(85, df:getValue(2, "score"), 1e-5)
    end)

    -- @covers LDataFrame:unique
    it("unique removes duplicated row values for one column", function()
        local df = lurek.dataframe.fromCSV("color\nred\nblue\nred\n")
        local out = df:unique("color")
        expect_type("table", out)
        expect_equal(2, #out)
    end)

    -- @covers LDataFrame:groupBy
    it("groupBy returns a table keyed by group value", function()
        local groups = make_group_df():groupBy("dept")
        expect_not_nil(groups.eng)
        expect_equal(2, groups.eng:nrows())
    end)

    -- @covers LDataFrame:join
    it("join performs an inner join by default", function()
        local left = lurek.dataframe.fromCSV("id,name\n1,Alice\n2,Bob\n")
        local right = lurek.dataframe.fromCSV("id,dept\n1,HR\n3,Ops\n")
        local joined = left:join(right, "id", "id")
        expect_equal(1, joined:nrows())
        expect_equal("HR", joined:getValue(1, "dept"))
    end)

    -- @covers LDataFrame:merge
    it("merge appends rows in place", function()
        local left = lurek.dataframe.fromCSV("x\n1\n2\n")
        local right = lurek.dataframe.fromCSV("x\n3\n4\n")
        left:merge(right)
        expect_equal(4, left:nrows())
    end)

    -- @covers LDataFrame:countBy
    it("countBy returns grouped counts", function()
        local df = lurek.dataframe.fromCSV("color\nred\nblue\nred\n")
        local out = df:countBy("color")
        expect_equal(2, out:nrows())
        expect_equal(2, out:ncols())
    end)

    -- @covers LDataFrame:valueCounts
    it("valueCounts can include percentages", function()
        local df = lurek.dataframe.fromCSV("color\nred\nblue\nred\nred\n")
        local out = df:valueCounts("color", { percent = true })
        expect_near(3, out:getValue(1, "count"), 1e-5)
        expect_near(75, out:getValue(1, "percent"), 1e-5)
    end)

    -- @covers LDataFrame:missingReport
    it("missingReport summarizes nil cells by column", function()
        local df = lurek.dataframe.newDataFrame()
        df:addColumn("name")
        df:addColumn("amount")
        df:addRow({ name = "rent", amount = 100 })
        df:addRow({ name = "food" })
        local report = df:missingReport()
        expect_equal(2, report:nrows())
        expect_equal("amount", report:getValue(2, "column"))
    end)

    -- @covers LDataFrame:duplicateRows
    it("duplicateRows returns repeated keys", function()
        local df = lurek.dataframe.fromRows(
            { "date", "account", "amount" },
            {
                { "2026-05-01", "cash", 10 },
                { "2026-05-01", "cash", 15 },
                { "2026-05-02", "card", 20 },
                { "2026-05-01", "cash", 30 },
            }
        )
        local out = df:duplicateRows({ "date", "account" })
        expect_equal(3, out:nrows())
    end)

    -- @covers LDataFrame:dropNil
    it("dropNil removes rows with nil in the selected column", function()
        local df = lurek.dataframe.newDataFrame()
        df:addColumn("x")
        df:addRow({ x = 1 })
        df:addRow()
        df:addRow({ x = 3 })
        local out = df:dropNil("x")
        expect_equal(2, out:nrows())
    end)

    -- @covers LDataFrame:sample
    it("sample is deterministic with a seed", function()
        local left = make_test_df():sample(2, 99)
        local right = make_test_df():sample(2, 99)
        expect_equal(left:getValue(1, "name"), right:getValue(1, "name"))
        expect_equal(left:getValue(2, "name"), right:getValue(2, "name"))
    end)
end)

-- @describe dataframe analytics and query
describe("dataframe analytics and query", function()
    -- @covers LDataFrame:describe
    it("describe returns a dataframe of statistics", function()
        local stats = make_stats_df():describe()
        expect_true(stats:nrows() > 0)
        expect_true(stats:ncols() > 0)
    end)

    -- @covers LDataFrame:sum
    it("sum aggregates a numeric column", function()
        expect_near(100, make_stats_df():sum("value"), 1e-5)
    end)

    -- @covers LDataFrame:mean
    it("mean computes the average value", function()
        expect_near(25, make_stats_df():mean("value"), 1e-5)
    end)

    -- @covers LDataFrame:min
    it("min returns the lowest value", function()
        expect_near(10, make_stats_df():min("value"), 1e-5)
    end)

    -- @covers LDataFrame:max
    it("max returns the highest value", function()
        expect_near(40, make_stats_df():max("value"), 1e-5)
    end)

    -- @covers LDataFrame:median
    it("median returns the middle of the distribution", function()
        expect_near(25, make_stats_df():median("value"), 1e-5)
    end)

    -- @covers LDataFrame:stddev
    it("stddev returns a positive spread for varied data", function()
        expect_true(make_stats_df():stddev("value") > 0)
    end)

    -- @covers LDataFrame:variance
    it("variance returns a non-negative value", function()
        expect_true(make_stats_df():variance("value") >= 0)
    end)

    -- @covers LDataFrame:fillNil
    it("fillNil replaces missing values in place", function()
        local df = lurek.dataframe.newDataFrame()
        df:addColumn("name")
        df:addRow()
        df:fillNil("name", "unknown")
        expect_equal("unknown", df:getValue(1, "name"))
    end)

    -- @covers LDataFrame:apply
    it("apply transforms values in place", function()
        local df = lurek.dataframe.fromCSV("x\n1\n2\n3\n")
        df:apply("x", function(v)
            return v * 2
        end)
        expect_near(6, df:getValue(3, "x"), 1e-5)
    end)

    -- @covers LDataFrame:query
    it("query runs SQL against self", function()
        local result = make_test_df():query("SELECT * FROM self WHERE age > 28")
        expect_equal(2, result:nrows())
        expect_true(result:getValue(1, "age") > 28)
    end)

    -- @covers LDataFrame:queryAsync
    it("queryAsync returns a task that resolves into a dataframe", function()
        local task = make_test_df():queryAsync("SELECT score FROM self WHERE score > 88")
        expect_true(task:wait())
        local result = task:result()
        expect_equal(2, result:nrows())
    end)

    -- @covers LDataFrame:pivotTable
    it("pivotTable reshapes long rows into wide columns", function()
        local df = lurek.dataframe.newDataFrame()
        df:addColumn("player")
        df:addColumn("stat")
        df:addColumn("value")
        df:addRow({ player = "A", stat = "hp", value = 100 })
        df:addRow({ player = "A", stat = "mp", value = 50 })
        df:addRow({ player = "B", stat = "hp", value = 80 })
        local wide = df:pivotTable("player", "stat", "value")
        expect_equal(2, wide:nrows())
        expect_near(100, wide:getValue(1, "hp"), 1e-5)
    end)

    -- @covers LDataFrame:rollingMean
    it("rollingMean appends a rolling average column", function()
        local df = lurek.dataframe.fromCSV("v\n2\n4\n6\n8\n")
        local out = df:rollingMean("v", 2, "v_rm")
        expect_near(7, out:getValue(4, "v_rm"), 1e-5)
    end)

    -- @covers LDataFrame:rollingSum
    it("rollingSum appends a rolling sum column", function()
        local df = lurek.dataframe.fromCSV("v\n1\n2\n3\n")
        local out = df:rollingSum("v", 2, "v_rs")
        expect_near(5, out:getValue(3, "v_rs"), 1e-5)
    end)

    -- @covers LDataFrame:rank
    it("rank assigns rank 1 to the highest descending value", function()
        local df = lurek.dataframe.fromCSV("score\n30\n10\n20\n")
        local out = df:rank("score", "desc", "rank")
        expect_near(1, out:getValue(1, "rank"), 1e-5)
        expect_near(3, out:getValue(2, "rank"), 1e-5)
    end)

    -- @covers LDataFrame:groupAgg
    it("groupAgg aggregates by key and metric", function()
        local df = lurek.dataframe.newDataFrame()
        df:addColumn("team")
        df:addColumn("score")
        df:addRow({ team = "A", score = 10 })
        df:addRow({ team = "A", score = 20 })
        df:addRow({ team = "B", score = 5 })
        local out = df:groupAgg("team", "score", "sum")
        expect_equal(2, out:nrows())
    end)

    -- @covers LDataFrame:clone
    it("clone returns an independent copy", function()
        local original = make_test_df()
        local copy = original:clone()
        copy:setValue(1, "name", "Changed")
        expect_equal("Alice", original:getValue(1, "name"))
        expect_equal("Changed", copy:getValue(1, "name"))
    end)

    -- @covers LDataFrame:type
    it("type returns LDataFrame", function()
        expect_equal("LDataFrame", make_test_df():type())
    end)

    -- @covers LDataFrame:typeOf
    it("typeOf reports dataframe inheritance", function()
        expect_true(make_test_df():typeOf("LDataFrame"))
    end)
end)

-- @describe grouped dataframe coverage
describe("grouped dataframe coverage", function()
    -- @covers LDataFrame:groupByObj
    it("groupByObj returns a grouped frame handle", function()
        local grouped = make_group_df():groupByObj("dept")
        expect_type("userdata", grouped)
    end)

    -- @covers LGroupedFrame:aggregate
    it("aggregate reduces each group into a summary dataframe", function()
        local grouped = make_group_df():groupByObj("dept")
        local out = grouped:aggregate("score", function(values)
            local sum = 0
            for i = 1, #values do
                sum = sum + values[i]
            end
            return sum
        end)
        expect_equal(2, out:nrows())
        expect_near(175, out:getValue(1, "score"), 1e-5)
        expect_near(88, out:getValue(2, "score"), 1e-5)
    end)

    -- @covers LGroupedFrame:type
    it("type returns LGroupedFrame", function()
        expect_equal("LGroupedFrame", make_group_df():groupByObj("dept"):type())
    end)

    -- @covers LGroupedFrame:typeOf
    it("typeOf reports grouped frame inheritance", function()
        expect_true(make_group_df():groupByObj("dept"):typeOf("LGroupedFrame"))
    end)
end)

-- @describe dataframe extended analytics
describe("dataframe extended analytics", function()
    -- @covers LDataFrame:dateParts
    it("dateParts extracts year month and day columns", function()
        local df = lurek.dataframe.fromRows(
            { "login_date" },
            {
                { "2024-03-12" },
                { "2025-01-05" },
            }
        )
        local parts = df:dateParts("login_date")
        expect_near(2024, parts:getValue(1, "year"), 1e-5)
        expect_near(1, parts:getValue(2, "month"), 1e-5)
        expect_near(5, parts:getValue(2, "day"), 1e-5)
    end)

    -- @covers LDataFrame:withRollingMean
    it("withRollingMean appends an in-place rolling mean column", function()
        local df = lurek.dataframe.fromCSV("v\n1\n3\n5\n")
        df:withRollingMean("v", 2, "smooth")
        expect_near(4, df:getValue(3, "smooth"), 1e-5)
    end)

    -- @covers LDataFrame:withRollingSum
    it("withRollingSum appends an in-place rolling sum column", function()
        local df = lurek.dataframe.fromCSV("v\n1\n3\n5\n")
        df:withRollingSum("v", 2, "sum2")
        expect_near(8, df:getValue(3, "sum2"), 1e-5)
    end)

    -- @covers LDataFrame:withRollingMin
    it("withRollingMin appends an in-place rolling minimum column", function()
        local df = lurek.dataframe.fromCSV("v\n1\n3\n5\n")
        df:withRollingMin("v", 2, "floor2")
        expect_near(3, df:getValue(3, "floor2"), 1e-5)
    end)

    -- @covers LDataFrame:withRollingMax
    it("withRollingMax appends an in-place rolling maximum column", function()
        local df = lurek.dataframe.fromCSV("v\n1\n3\n5\n")
        df:withRollingMax("v", 2, "peak2")
        expect_near(5, df:getValue(3, "peak2"), 1e-5)
    end)

    -- @covers LDataFrame:withRank
    it("withRank appends ascending ranks in place", function()
        local df = lurek.dataframe.fromCSV("pts\n30\n10\n20\n")
        df:withRank("pts", true, "rank")
        expect_near(3, df:getValue(1, "rank"), 1e-5)
        expect_near(1, df:getValue(2, "rank"), 1e-5)
    end)

    -- @covers LDataFrame:withPctChange
    it("withPctChange appends row-over-row percent change", function()
        local df = lurek.dataframe.fromCSV("price\n10\n15\n30\n")
        df:withPctChange("price", "pct")
        expect_near(0.5, df:getValue(2, "pct"), 1e-5)
        expect_near(1.0, df:getValue(3, "pct"), 1e-5)
    end)

    -- @covers LDataFrame:withCumsum
    it("withCumsum appends a cumulative sum column", function()
        local df = lurek.dataframe.fromCSV("xp\n10\n20\n30\n")
        df:withCumsum("xp", "total_xp")
        expect_near(60, df:getValue(3, "total_xp"), 1e-5)
    end)

    -- @covers LDataFrame:parFilter
    it("parFilter returns rows matching the predicate", function()
        local out = make_test_df():parFilter("age", ">", 28)
        expect_equal(2, out:nrows())
    end)

    -- @covers LDataFrame:parGroupAgg
    it("parGroupAgg aggregates grouped numeric values", function()
        local df = lurek.dataframe.fromRows(
            { "g", "v" },
            {
                { "A", 1 },
                { "A", 2 },
                { "B", 5 },
            }
        )
        local out = df:parGroupAgg("g", "v", "sum")
        expect_equal(2, out:nrows())
        expect_near(3, out:getValue(1, "v_sum"), 1e-5)
    end)

    -- @covers LDataFrame:pivot
    it("pivot reshapes long rows into wide columns", function()
        local df = lurek.dataframe.fromRows(
            { "player", "stat", "value" },
            {
                { "A", "hp", 100 },
                { "A", "mp", 50 },
                { "B", "hp", 80 },
            }
        )
        local wide = df:pivot("player", "stat", "value")
        expect_equal(2, wide:nrows())
        expect_near(100, wide:getValue(1, "hp"), 1e-5)
        expect_near(50, wide:getValue(1, "mp"), 1e-5)
    end)

    -- @covers LDataFrame:corr
    it("corr returns 1 for perfectly correlated columns", function()
        local df = lurek.dataframe.fromRows(
            { "x", "y" },
            {
                { 1, 2 },
                { 2, 4 },
                { 3, 6 },
            }
        )
        expect_near(1.0, df:corr("x", "y"), 1e-5)
    end)

    -- @covers LDataFrame:correlationMatrix
    it("correlationMatrix returns a labeled matrix with unit diagonal", function()
        local df = lurek.dataframe.fromRows(
            { "x", "y" },
            {
                { 1, 2 },
                { 2, 4 },
                { 3, 6 },
            }
        )
        local matrix = df:correlationMatrix()
        expect_equal(2, matrix:nrows())
        expect_equal("x", matrix:getValue(1, "column"))
        expect_near(1.0, matrix:getValue(1, "x"), 1e-5)
        expect_near(1.0, matrix:getValue(2, "y"), 1e-5)
    end)

    -- @covers LDataFrame:zscoreCol
    it("zscoreCol appends z-score normalized values", function()
        local df = lurek.dataframe.fromCSV("stat\n1\n2\n3\n")
        df:zscoreCol("stat", "stat_z")
        expect_near(0.0, df:getValue(2, "stat_z"), 1e-5)
    end)

    -- @covers LDataFrame:normalizeCol
    it("normalizeCol maps a numeric range into the target interval", function()
        local df = lurek.dataframe.fromCSV("val\n10\n20\n30\n")
        df:normalizeCol("val", 0.0, 1.0, "val_norm")
        expect_near(0.0, df:getValue(1, "val_norm"), 1e-5)
        expect_near(0.5, df:getValue(2, "val_norm"), 1e-5)
        expect_near(1.0, df:getValue(3, "val_norm"), 1e-5)
    end)

    -- @covers LDataFrame:outliers
    it("outliers returns rows that exceed the z-score threshold", function()
        local df = lurek.dataframe.fromCSV("ms\n1\n1\n1\n100\n")
        local spikes = df:outliers("ms", 1.0)
        expect_equal(1, spikes:nrows())
        expect_near(100, spikes:getValue(1, "ms"), 1e-5)
    end)

    -- @covers LDataFrame:modeVal
    it("modeVal returns the most frequent non-nil value", function()
        local df = lurek.dataframe.fromRows(
            { "weapon" },
            {
                { "sword" },
                { "sword" },
                { "bow" },
            }
        )
        expect_equal("sword", df:modeVal("weapon"))
    end)

    -- @covers LDataFrame:entropy
    it("entropy returns the Shannon entropy of a column", function()
        local df = lurek.dataframe.fromRows(
            { "cls" },
            {
                { "a" },
                { "a" },
                { "b" },
            }
        )
        expect_near(0.9183, df:entropy("cls"), 0.001)
    end)

    -- @covers LDataFrame:addRowBatch
    it("addRowBatch appends multiple array-style rows", function()
        local df = lurek.dataframe.fromRows(
            { "x", "y" },
            {
                { 1, 2 },
            }
        )
        df:addRowBatch({
            { 3, 4 },
            { 5, 6 },
        })
        expect_equal(3, df:nrows())
        expect_near(6, df:getValue(3, "y"), 1e-5)
    end)

    -- @covers LDataFrame:getColumnAsF64
    it("getColumnAsF64 extracts numeric column values as a lua array", function()
        local vals = make_vec_df():getColumnAsF64("hp")
        expect_equal(3, #vals)
        expect_near(10, vals[1], 1e-5)
        expect_near(30, vals[3], 1e-5)
    end)

    -- @covers LDataFrame:setColumnFromF64
    it("setColumnFromF64 bulk-writes numeric values into a column", function()
        local df = make_vec_df()
        df:setColumnFromF64("hp", { 1.5, 2.5, 3.5 })
        expect_near(1.5, df:getValue(1, "hp"), 1e-5)
        expect_near(3.5, df:getValue(3, "hp"), 1e-5)
    end)

    -- @covers LDataFrame:withEval
    it("withEval returns a dataframe with an expression-derived column", function()
        local df = lurek.dataframe.fromRows(
            { "atk", "bonus" },
            {
                { 10, 2 },
                { 20, 4 },
            }
        )
        local out = df:withEval("eff", "atk + bonus * 1.5")
        expect_near(13, out:getValue(1, "eff"), 1e-5)
        expect_near(26, out:getValue(2, "eff"), 1e-5)
    end)

    -- @covers LDataFrame:lazy
    it("lazy returns a lazy query handle", function()
        expect_equal("LLazyQuery", make_test_df():lazy():type())
    end)
end)

-- @describe lazy query coverage
describe("lazy query coverage", function()
    -- @covers LLazyQuery:filter
    it("filter narrows rows before collection", function()
        local result = make_test_df():lazy():filter("age", ">", 28):collect()
        expect_equal(2, result:nrows())
    end)

    -- @covers LLazyQuery:sort
    it("sort reorders rows before collection", function()
        local result = make_test_df():lazy():sort("score", false):collect()
        expect_equal("Charlie", result:getValue(1, "name"))
    end)

    -- @covers LLazyQuery:head
    it("head limits the lazy query to leading rows", function()
        local result = make_test_df():lazy():head(2):collect()
        expect_equal(2, result:nrows())
    end)

    -- @covers LLazyQuery:tail
    it("tail limits the lazy query to trailing rows", function()
        local result = make_test_df():lazy():tail(2):collect()
        expect_equal("Bob", result:getValue(1, "name"))
        expect_equal("Charlie", result:getValue(2, "name"))
    end)

    -- @covers LLazyQuery:limit
    it("limit keeps only the requested number of rows", function()
        local result = make_test_df():lazy():limit(1):collect()
        expect_equal(1, result:nrows())
    end)

    -- @covers LLazyQuery:slice
    it("slice keeps an inclusive one-based row range", function()
        local result = make_test_df():lazy():slice(2, 3):collect()
        expect_equal(2, result:nrows())
        expect_equal("Bob", result:getValue(1, "name"))
    end)

    -- @covers LLazyQuery:dropNil
    it("dropNil removes rows where the selected column is nil", function()
        local df = lurek.dataframe.newDataFrame()
        df:addColumn("name")
        df:addColumn("mana")
        df:addRow({ name = "A", mana = 10 })
        df:addRow({ name = "B" })
        df:addRow({ name = "C", mana = 20 })
        local result = df:lazy():dropNil("mana"):collect()
        expect_equal(2, result:nrows())
    end)

    -- @covers LLazyQuery:select
    it("select keeps only the requested columns", function()
        local result = make_test_df():lazy():select({ "name", "score" }):collect()
        expect_equal(2, result:ncols())
        expect_equal("Alice", result:getValue(1, "name"))
    end)

    -- @covers LLazyQuery:collect
    it("collect materializes the deferred query result", function()
        local result = make_test_df():lazy():limit(2):collect()
        expect_equal(2, result:nrows())
    end)

    -- @covers LLazyQuery:type
    it("type returns LLazyQuery", function()
        expect_equal("LLazyQuery", make_test_df():lazy():type())
    end)

    -- @covers LLazyQuery:typeOf
    it("typeOf reports lazy query inheritance", function()
        expect_true(make_test_df():lazy():typeOf("LLazyQuery"))
    end)
end)

-- @describe dataframe serialization
describe("dataframe serialization", function()
    -- @covers LDataFrame:toCSV
    it("toCSV returns a non-empty string", function()
        local csv = make_test_df():toCSV()
        expect_type("string", csv)
        expect_true(#csv > 0)
    end)

    -- @covers LDataFrame:toCSVFile
    it("toCSVFile writes a round-trippable csv file", function()
        local path = TMP .. "dataframe_roundtrip.csv"
        local df = make_test_df()
        expect_true(df:toCSVFile(path))
        local restored = lurek.dataframe.fromCSVFile(path)
        expect_equal(df:nrows(), restored:nrows())
    end)

    -- @covers LDataFrame:toJSON
    it("toJSON returns a non-empty string", function()
        local json = make_test_df():toJSON()
        expect_type("string", json)
        expect_true(#json > 0)
    end)

    -- @covers LDataFrame:toJSONFile
    it("toJSONFile writes a round-trippable json file", function()
        local path = TMP .. "dataframe_roundtrip.json"
        local df = make_test_df()
        expect_true(df:toJSONFile(path))
        local restored = lurek.dataframe.fromJSONFile(path)
        expect_equal("Bob", restored:getValue(2, "name"))
    end)

    -- @covers LDataFrame:toBinary
    it("toBinary returns a serialized byte string", function()
        expect_type("string", make_test_df():toBinary())
    end)

    -- @covers LDataFrame:toBinaryFile
    it("toBinaryFile writes bytes loadable by fromBinary", function()
        local path = TMP .. "dataframe_roundtrip.lvdf"
        local df = make_test_df()
        expect_true(df:toBinaryFile(path))
        local restored = lurek.dataframe.fromBinary(lurek.filesystem.readBytes(path))
        expect_equal("Charlie", restored:getValue(3, "name"))
    end)

    -- @covers LDataFrame:toTable
    it("toTable returns an array of row tables", function()
        local rows = make_test_df():toTable()
        expect_equal(3, #rows)
        expect_equal("Alice", rows[1].name)
    end)

    -- @covers LDataFrame:rows
    it("rows iterates index and row tables in order", function()
        local names = {}
        for _, row in make_test_df():rows() do
            names[#names + 1] = row.name
        end
        expect_equal(3, #names)
        expect_equal("Charlie", names[3])
    end)

    -- @covers LDataFrame:toString
    it("toString returns a printable representation", function()
        local text = make_test_df():toString()
        expect_type("string", text)
        expect_true(#text > 0)
    end)
end)

-- @describe database APIs
describe("database APIs", function()
    -- @covers lurek.dataframe.newDatabase
    it("newDatabase creates an empty database", function()
        local db = lurek.dataframe.newDatabase()
        expect_equal(0, db:tableCount())
    end)

    -- @covers LDatabase:addTable
    it("addTable registers a named dataframe", function()
        local db = lurek.dataframe.newDatabase()
        db:addTable("users", make_test_df())
        expect_true(db:hasTable("users"))
    end)

    -- @covers LDatabase:getTable
    it("getTable returns a previously stored dataframe", function()
        local db = lurek.dataframe.newDatabase()
        db:addTable("users", make_test_df())
        expect_equal(3, db:getTable("users"):nrows())
    end)

    -- @covers LDatabase:tableCount
    it("tableCount reflects the number of tables", function()
        local db = lurek.dataframe.newDatabase()
        db:addTable("a", make_test_df())
        db:addTable("b", make_test_df())
        expect_equal(2, db:tableCount())
    end)

    -- @covers LDatabase:hasTable
    it("hasTable reports missing tables as false", function()
        expect_false(lurek.dataframe.newDatabase():hasTable("missing"))
    end)

    -- @covers LDatabase:removeTable
    it("removeTable removes a named table", function()
        local db = lurek.dataframe.newDatabase()
        db:addTable("users", make_test_df())
        db:removeTable("users")
        expect_false(db:hasTable("users"))
    end)

    -- @covers LDatabase:listTables
    it("listTables returns table names", function()
        local db = lurek.dataframe.newDatabase()
        db:addTable("alpha", make_test_df())
        db:addTable("beta", make_test_df())
        local names = db:listTables()
        expect_equal(2, #names)
    end)

    -- @covers LDatabase:clear
    it("clear removes all registered tables", function()
        local db = lurek.dataframe.newDatabase()
        db:addTable("alpha", make_test_df())
        db:clear()
        expect_equal(0, db:tableCount())
    end)

    -- @covers LDatabase:merge
    it("merge combines table maps from two databases", function()
        local left = lurek.dataframe.newDatabase()
        local right = lurek.dataframe.newDatabase()
        left:addTable("users", make_test_df())
        right:addTable("scores", make_test_df())
        left:merge(right)
        expect_true(left:hasTable("users"))
        expect_true(left:hasTable("scores"))
    end)

    -- @covers LDatabase:toJSON
    it("toJSON serializes the table map", function()
        local db = lurek.dataframe.newDatabase()
        db:addTable("users", make_test_df())
        local json = db:toJSON()
        expect_type("string", json)
        expect_true(#json > 0)
    end)

    -- @covers LDatabase:save
    it("save writes a loadable database file", function()
        local path = TMP .. "database_save.json"
        local db = lurek.dataframe.newDatabase()
        db:addTable("users", make_test_df())
        expect_true(db:save(path))
    end)

    -- @covers lurek.dataframe.loadDatabase
    it("loadDatabase restores a saved database", function()
        local path = TMP .. "database_load.json"
        local db = lurek.dataframe.newDatabase()
        db:addTable("users", make_test_df())
        expect_true(db:save(path))
        local restored = lurek.dataframe.loadDatabase(path)
        expect_true(restored:hasTable("users"))
    end)

    -- @covers LDatabase:query
    it("query runs SQL against a named table", function()
        local db = lurek.dataframe.newDatabase()
        db:addTable("users", make_test_df())
        local result = db:query("SELECT name FROM users WHERE age > 28")
        expect_equal(2, result:nrows())
    end)

    -- @covers LDatabase:queryParams
    it("queryParams binds positional parameters", function()
        local db = lurek.dataframe.newDatabase()
        db:addTable("users", make_test_df())
        local result = db:queryParams(
            "SELECT name FROM users WHERE age > ? AND name != ?",
            { 26, "Alice" }
        )
        expect_equal("Charlie", result:getValue(1, "name"))
    end)

    -- @covers LDatabase:queryAsync
    it("queryAsync resolves into a result dataframe", function()
        local db = lurek.dataframe.newDatabase()
        db:addTable("users", make_test_df())
        local task = db:queryAsync("SELECT score FROM users WHERE score > 88")
        expect_true(task:wait())
        expect_equal(2, task:result():nrows())
    end)

    -- @covers LDatabase:queryParamsAsync
    it("queryParamsAsync resolves into a filtered result", function()
        local db = lurek.dataframe.newDatabase()
        db:addTable("users", make_test_df())
        local task = db:queryParamsAsync("SELECT name FROM users WHERE age > ?", { 28 })
        expect_true(task:wait())
        expect_equal(2, task:result():nrows())
    end)

    -- @covers LDatabase:type
    it("type returns LDatabase", function()
        expect_equal("LDatabase", lurek.dataframe.newDatabase():type())
    end)

    -- @covers LDatabase:typeOf
    it("typeOf reports database inheritance", function()
        expect_true(lurek.dataframe.newDatabase():typeOf("LDatabase"))
    end)
end)

-- @describe async dataframe tasks
describe("async dataframe tasks", function()
    -- @covers lurek.dataframe.fromCSVFileAsync
    it("fromCSVFileAsync starts a task for csv loading", function()
        local path = TMP .. "dataframe_async_csv.csv"
        lurek.filesystem.write(path, "name,score\nAlice,90\nBob,85\n")
        local task = lurek.dataframe.fromCSVFileAsync(path)
        expect_type("userdata", task)
    end)

    -- @covers lurek.dataframe.fromJSONFileAsync
    it("fromJSONFileAsync starts a task for json loading", function()
        local path = TMP .. "dataframe_async_json.json"
        lurek.filesystem.writeJson(path, '[{"id":1},{"id":2}]')
        local task = lurek.dataframe.fromJSONFileAsync(path)
        expect_type("userdata", task)
    end)

    -- @covers LDataFrameTask:isDone
    it("isDone returns a boolean task state", function()
        local path = TMP .. "dataframe_async_done.csv"
        lurek.filesystem.write(path, "x\n1\n")
        local task = lurek.dataframe.fromCSVFileAsync(path)
        expect_type("boolean", task:isDone())
    end)

    -- @covers LDataFrameTask:wait
    it("wait blocks until the task completes", function()
        local path = TMP .. "dataframe_async_wait.csv"
        lurek.filesystem.write(path, "x\n1\n2\n")
        local task = lurek.dataframe.fromCSVFileAsync(path)
        expect_true(task:wait())
    end)

    -- @covers LDataFrameTask:result
    it("result returns a dataframe after a successful task", function()
        local path = TMP .. "dataframe_async_result.csv"
        lurek.filesystem.write(path, "x\n1\n2\n")
        local task = lurek.dataframe.fromCSVFileAsync(path)
        expect_true(task:wait())
        expect_equal(2, task:result():nrows())
    end)

    -- @covers LDataFrameTask:getError
    it("getError returns a string after a failed task", function()
        local path = TMP .. "dataframe_async_error.csv"
        lurek.filesystem.write(path, "name,score\nAlice\n")
        local task = lurek.dataframe.fromCSVFileAsync(path)
        expect_false(task:wait())
        expect_type("string", task:getError())
    end)

    -- @covers LDataFrameTask:progress
    it("progress returns a numeric completion value", function()
        local path = TMP .. "dataframe_async_progress.csv"
        lurek.filesystem.write(path, "x\n1\n")
        local task = lurek.dataframe.fromCSVFileAsync(path)
        expect_type("number", task:progress())
    end)

    -- @covers LDataFrameTask:type
    it("type returns LDataFrameTask", function()
        local path = TMP .. "dataframe_async_type.csv"
        lurek.filesystem.write(path, "x\n1\n")
        local task = lurek.dataframe.fromCSVFileAsync(path)
        expect_equal("LDataFrameTask", task:type())
    end)

    -- @covers LDataFrameTask:typeOf
    it("typeOf reports task inheritance", function()
        local path = TMP .. "dataframe_async_typeof.csv"
        lurek.filesystem.write(path, "x\n1\n")
        local task = lurek.dataframe.fromCSVFileAsync(path)
        expect_true(task:typeOf("LDataFrameTask"))
    end)
end)

-- @describe vec frame APIs
describe("vec frame APIs", function()
    -- @covers LVecFrame:nrows
    it("nrows reports the vec frame row count", function()
        expect_equal(3, lurek.dataframe.toVec(make_vec_df()):nrows())
    end)

    -- @covers LVecFrame:ncols
    it("ncols reports the vec frame column count", function()
        expect_equal(2, lurek.dataframe.toVec(make_vec_df()):ncols())
    end)

    -- @covers LVecFrame:columns
    it("columns returns ordered vec frame column names", function()
        local cols = lurek.dataframe.toVec(make_vec_df()):columns()
        expect_equal("hp", cols[1])
        expect_equal("mp", cols[2])
    end)

    -- @covers LVecFrame:colType
    it("colType reports numeric columns as float64", function()
        expect_equal("float64", lurek.dataframe.toVec(make_vec_df()):colType("hp"))
    end)

    -- @covers LVecFrame:colCast
    it("colCast changes the stored vector type", function()
        local vf = lurek.dataframe.toVec(make_vec_df())
        vf:colCast("hp", "int64")
        expect_equal("int64", vf:colType("hp"))
    end)

    -- @covers LVecFrame:colAdd
    it("colAdd adds a scalar to each value", function()
        local vf = lurek.dataframe.toVec(make_vec_df())
        vf:colAdd("hp", 5)
        local df = lurek.dataframe.fromVec(vf)
        expect_near(15, df:getValue(1, "hp"), 1e-5)
    end)

    -- @covers LVecFrame:colSub
    it("colSub subtracts a scalar from each value", function()
        local vf = lurek.dataframe.toVec(make_vec_df())
        vf:colSub("hp", 5)
        local df = lurek.dataframe.fromVec(vf)
        expect_near(5, df:getValue(1, "hp"), 1e-5)
    end)

    -- @covers LVecFrame:colMul
    it("colMul multiplies each value by a scalar", function()
        local vf = lurek.dataframe.toVec(make_vec_df())
        vf:colMul("hp", 3)
        local df = lurek.dataframe.fromVec(vf)
        expect_near(30, df:getValue(1, "hp"), 1e-5)
    end)

    -- @covers LVecFrame:colDiv
    it("colDiv divides each value by a scalar", function()
        local vf = lurek.dataframe.toVec(make_vec_df())
        vf:colDiv("hp", 2)
        local df = lurek.dataframe.fromVec(vf)
        expect_near(5, df:getValue(1, "hp"), 1e-5)
    end)

    -- @covers LVecFrame:colAbs
    it("colAbs normalizes negative values", function()
        local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("v\n-3\n4\n"))
        vf:colAbs("v")
        local df = lurek.dataframe.fromVec(vf)
        expect_near(3, df:getValue(1, "v"), 1e-5)
    end)

    -- @covers LVecFrame:colSqrt
    it("colSqrt applies square root to each value", function()
        local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("v\n9\n4\n"))
        vf:colSqrt("v")
        local df = lurek.dataframe.fromVec(vf)
        expect_near(3, df:getValue(1, "v"), 1e-5)
    end)

    -- @covers LVecFrame:colFloor
    it("colFloor floors fractional values", function()
        local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("v\n1.9\n"))
        vf:colFloor("v")
        local df = lurek.dataframe.fromVec(vf)
        expect_near(1, df:getValue(1, "v"), 1e-5)
    end)

    -- @covers LVecFrame:colCeil
    it("colCeil ceils fractional values", function()
        local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("v\n1.1\n"))
        vf:colCeil("v")
        local df = lurek.dataframe.fromVec(vf)
        expect_near(2, df:getValue(1, "v"), 1e-5)
    end)

    -- @covers LVecFrame:colNeg
    it("colNeg negates each value", function()
        local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("v\n5\n"))
        vf:colNeg("v")
        local df = lurek.dataframe.fromVec(vf)
        expect_near(-5, df:getValue(1, "v"), 1e-5)
    end)

    -- @covers LVecFrame:colClamp
    it("colClamp enforces numeric bounds", function()
        local vf = lurek.dataframe.toVec(make_vec_df())
        vf:colClamp("hp", 15, 25)
        local df = lurek.dataframe.fromVec(vf)
        expect_near(15, df:getValue(1, "hp"), 1e-5)
        expect_near(25, df:getValue(3, "hp"), 1e-5)
    end)

    -- @covers LVecFrame:colOp
    it("colOp computes an element-wise column result", function()
        local vf = lurek.dataframe.toVec(make_vec_df())
        vf:colOp("total", "hp", "add", "mp")
        local df = lurek.dataframe.fromVec(vf)
        expect_near(15, df:getValue(1, "total"), 1e-5)
    end)

    -- @covers LVecFrame:reduce
    it("reduce aggregates numeric values", function()
        local vf = lurek.dataframe.toVec(make_vec_df())
        expect_near(60, vf:reduce("hp", "sum"), 1e-5)
    end)

    -- @covers LVecFrame:parReduce
    it("parReduce aggregates multiple numeric columns in parallel", function()
        local vf = lurek.dataframe.toVec(make_vec_df())
        local sums = vf:parReduce({ "hp", "mp" }, "sum")
        expect_near(60, sums.hp, 1e-5)
        expect_near(30, sums.mp, 1e-5)
    end)

    -- @covers LVecFrame:filterMask
    it("filterMask returns boolean membership for a predicate", function()
        local mask = lurek.dataframe.toVec(make_vec_df()):filterMask("hp", ">", 15)
        expect_false(mask[1])
        expect_true(mask[2])
        expect_true(mask[3])
    end)

    -- @covers LVecFrame:applyMask
    it("applyMask returns a filtered vec frame", function()
        local vf = lurek.dataframe.toVec(make_vec_df())
        local mask = vf:filterMask("hp", ">=", 20)
        local filtered = vf:applyMask(mask)
        expect_equal(2, filtered:nrows())
    end)

    -- @covers LVecFrame:parScalarOp
    it("parScalarOp applies one scalar operation to multiple columns", function()
        local vf = lurek.dataframe.toVec(make_vec_df())
        vf:parScalarOp({ "hp", "mp" }, "mul", 2.0)
        local df = vf:toDataFrame()
        expect_near(20, df:getValue(1, "hp"), 1e-5)
        expect_near(30, df:getValue(3, "mp"), 1e-5)
    end)

    -- @covers LVecFrame:toDataFrame
    it("toDataFrame converts a vec frame back into dataframe rows", function()
        local df = lurek.dataframe.toVec(make_vec_df()):toDataFrame()
        expect_equal(3, df:nrows())
        expect_near(15, df:getValue(3, "mp"), 1e-5)
    end)

    -- @covers LVecFrame:type
    it("type returns LVecFrame", function()
        expect_equal("LVecFrame", lurek.dataframe.toVec(make_vec_df()):type())
    end)

    -- @covers LVecFrame:typeOf
    it("typeOf reports vec frame inheritance", function()
        expect_true(lurek.dataframe.toVec(make_vec_df()):typeOf("LVecFrame"))
    end)
end)
end
-- END test_dataframe_core_unit.lua

test_summary()
