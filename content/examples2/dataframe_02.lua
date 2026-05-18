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

print("dataframe_02.lua")
