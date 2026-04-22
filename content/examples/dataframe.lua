-- content/examples/dataframe.lua
-- love2d-style usage snippets for the lurek.dataframe API (64 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/dataframe.lua

-- ── lurek.dataframe.* functions ──

--@api-stub: lurek.dataframe.newDataFrame
-- Creates a new empty DataFrame.
-- Build once at startup; reuse across frames.
local dataframe = lurek.dataframe.newDataFrame()
print("created", dataframe)
return dataframe

--@api-stub: lurek.dataframe.newDatabase
-- Creates a new empty Database.
-- Build once at startup; reuse across frames.
local database = lurek.dataframe.newDatabase()
print("created", database)
return database

--@api-stub: lurek.dataframe.fromTable
-- Creates a DataFrame from an array of row tables.
-- Build once at startup; reuse across frames.
local fromtable = lurek.dataframe.fromTable(10)
print("created", fromtable)
return fromtable

--@api-stub: lurek.dataframe.fromCSV
-- Parses a CSV string into a DataFrame.
-- Build once at startup; reuse across frames.
local fromcsv = lurek.dataframe.fromCSV(s)
print("created", fromcsv)
return fromcsv

--@api-stub: lurek.dataframe.fromJSON
-- Parses a JSON string into a DataFrame.
-- Build once at startup; reuse across frames.
local fromjson = lurek.dataframe.fromJSON(s)
print("created", fromjson)
return fromjson

--@api-stub: lurek.dataframe.fromBinary
-- Deserializes a binary LVDF string into a DataFrame.
-- Build once at startup; reuse across frames.
local frombinary = lurek.dataframe.fromBinary(s)
print("created", frombinary)
return frombinary

--@api-stub: lurek.dataframe.random
-- Generates a DataFrame with random data from column definitions.
-- See the module spec for detailed semantics.
local result = lurek.dataframe.random(defs_tbl, 10, seed)
print("random:", result)
return result

-- ── DataFrame methods ──

--@api-stub: DataFrame:nrows
-- Returns the number of rows.
-- See the module spec for detailed semantics.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:nrows()
print("DataFrame:nrows done")

--@api-stub: DataFrame:ncols
-- Returns the number of columns.
-- See the module spec for detailed semantics.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:ncols()
print("DataFrame:ncols done")

--@api-stub: DataFrame:columns
-- Returns a table of column names.
-- See the module spec for detailed semantics.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:columns()
print("DataFrame:columns done")

--@api-stub: DataFrame:count
-- Returns the row count (alias for nrows).
-- Cheap to call; safe inside callbacks.
local dataFrame = lurek.dataframe.newDataFrame()  -- or your existing handle
local value = dataFrame:count()
print("DataFrame:count ->", value)

--@api-stub: DataFrame:removeColumn
-- Removes a column by name or index.
-- Pair with the matching constructor to free resources.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:removeColumn(col)
-- dataFrame is now released
print("ok")

--@api-stub: DataFrame:rename
-- Renames the column `old_name` to `new_name` in this DataFrame.
-- See the module spec for detailed semantics.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:rename(col, "main")
print("DataFrame:rename done")

--@api-stub: DataFrame:getColumn
-- Returns all values in a column as a table.
-- Cheap to call; safe inside callbacks.
local dataFrame = lurek.dataframe.newDataFrame()  -- or your existing handle
local value = dataFrame:getColumn(col)
print("DataFrame:getColumn ->", value)

--@api-stub: DataFrame:addRow
-- Adds a row from an optional table of name-value pairs, returns 1-based index.
-- Side-effecting; safe to call any time after init.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:addRow(row_tbl)
print("DataFrame:addRow done")

--@api-stub: DataFrame:removeRow
-- Removes a row by 1-based index.
-- Pair with the matching constructor to free resources.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:removeRow(row)
-- dataFrame is now released
print("ok")

--@api-stub: DataFrame:getRow
-- Returns a row as a table of name-value pairs.
-- Cheap to call; safe inside callbacks.
local dataFrame = lurek.dataframe.newDataFrame()  -- or your existing handle
local value = dataFrame:getRow(row)
print("DataFrame:getRow ->", value)

--@api-stub: DataFrame:getValue
-- Returns a single cell value.
-- Cheap to call; safe inside callbacks.
local dataFrame = lurek.dataframe.newDataFrame()  -- or your existing handle
local value = dataFrame:getValue(row, col)
print("DataFrame:getValue ->", value)

--@api-stub: DataFrame:head
-- Returns the first n rows (default 5).
-- See the module spec for detailed semantics.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:head(10)
print("DataFrame:head done")

--@api-stub: DataFrame:tail
-- Returns the last n rows (default 5).
-- See the module spec for detailed semantics.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:tail(10)
print("DataFrame:tail done")

--@api-stub: DataFrame:slice
-- Returns rows from start to end (1-based, inclusive).
-- See the module spec for detailed semantics.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:slice(start, end)
print("DataFrame:slice done")

--@api-stub: DataFrame:select
-- Selects a subset of columns, returns a new DataFrame.
-- See the module spec for detailed semantics.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:select(10)
print("DataFrame:select done")

--@api-stub: DataFrame:unique
-- Returns unique values in a column as a table.
-- See the module spec for detailed semantics.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:unique(col)
print("DataFrame:unique done")

--@api-stub: DataFrame:groupBy
-- Groups rows by column value, returns a table of DataFrames keyed by value.
-- See the module spec for detailed semantics.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:groupBy(col)
print("DataFrame:groupBy done")

--@api-stub: DataFrame:merge
-- Appends rows from another DataFrame in-place.
-- See the module spec for detailed semantics.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:merge(other)
print("DataFrame:merge done")

--@api-stub: DataFrame:countBy
-- Counts distinct values in a column, returns a DataFrame with value and count columns.
-- Cheap to call; safe inside callbacks.
local dataFrame = lurek.dataframe.newDataFrame()  -- or your existing handle
local value = dataFrame:countBy(col)
print("DataFrame:countBy ->", value)

--@api-stub: DataFrame:dropNil
-- Removes rows where the given column is nil, returns a new DataFrame.
-- See the module spec for detailed semantics.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:dropNil(col)
print("DataFrame:dropNil done")

--@api-stub: DataFrame:sample
-- Returns a random sample of n rows.
-- See the module spec for detailed semantics.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:sample(10, seed)
print("DataFrame:sample done")

--@api-stub: DataFrame:describe
-- Returns descriptive statistics for all numeric columns.
-- See the module spec for detailed semantics.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:describe()
print("DataFrame:describe done")

--@api-stub: DataFrame:sum
-- Returns the sum of numeric values in a column.
-- See the module spec for detailed semantics.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:sum(col)
print("DataFrame:sum done")

--@api-stub: DataFrame:mean
-- Returns the mean of numeric values in a column.
-- See the module spec for detailed semantics.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:mean(col)
print("DataFrame:mean done")

--@api-stub: DataFrame:min
-- Returns the minimum numeric value in a column.
-- See the module spec for detailed semantics.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:min(col)
print("DataFrame:min done")

--@api-stub: DataFrame:max
-- Returns the maximum numeric value in a column.
-- See the module spec for detailed semantics.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:max(col)
print("DataFrame:max done")

--@api-stub: DataFrame:median
-- Returns the median of numeric values in a column.
-- See the module spec for detailed semantics.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:median(col)
print("DataFrame:median done")

--@api-stub: DataFrame:stddev
-- Returns the population standard deviation of numeric values in a column.
-- See the module spec for detailed semantics.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:stddev(col)
print("DataFrame:stddev done")

--@api-stub: DataFrame:variance
-- Returns the population variance of numeric values in a column.
-- See the module spec for detailed semantics.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:variance(col)
print("DataFrame:variance done")

--@api-stub: DataFrame:fillNil
-- Replaces nil values in a column with the given value.
-- See the module spec for detailed semantics.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:fillNil(col, val)
print("DataFrame:fillNil done")

--@api-stub: DataFrame:toCSV
-- Serializes this DataFrame to a CSV string.
-- See the module spec for detailed semantics.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:toCSV()
print("DataFrame:toCSV done")

--@api-stub: DataFrame:toJSON
-- Serializes this DataFrame to a JSON string.
-- See the module spec for detailed semantics.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:toJSON()
print("DataFrame:toJSON done")

--@api-stub: DataFrame:toBinary
-- Serializes this DataFrame to a binary LVDF string.
-- See the module spec for detailed semantics.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:toBinary()
print("DataFrame:toBinary done")

--@api-stub: DataFrame:toTable
-- Converts this DataFrame to a Lua table of row tables.
-- See the module spec for detailed semantics.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:toTable()
print("DataFrame:toTable done")

--@api-stub: DataFrame:toString
-- Returns a formatted string table representation.
-- See the module spec for detailed semantics.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:toString()
print("DataFrame:toString done")

--@api-stub: DataFrame:query
-- Executes a SQL query against this DataFrame.
-- Cheap to call; safe inside callbacks.
local dataFrame = lurek.dataframe.newDataFrame()  -- or your existing handle
local value = dataFrame:query("hello")
print("DataFrame:query ->", value)

--@api-stub: DataFrame:clone
-- Returns a deep copy of this DataFrame.
-- See the module spec for detailed semantics.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:clone()
print("DataFrame:clone done")

--@api-stub: DataFrame:correlationMatrix
-- Compute a correlation matrix for all numeric columns.
-- See the module spec for detailed semantics.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:correlationMatrix()
print("DataFrame:correlationMatrix done")

--@api-stub: DataFrame:modeVal
-- Return the most frequent value in a column (nil if empty).
-- See the module spec for detailed semantics.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:modeVal(col)
print("DataFrame:modeVal done")

--@api-stub: DataFrame:entropy
-- Shannon entropy (bits) of the value distribution in a column.
-- See the module spec for detailed semantics.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:entropy(col)
print("DataFrame:entropy done")

--@api-stub: DataFrame:addRowBatch
-- Add multiple rows at once from a table of row tables.
-- Side-effecting; safe to call any time after init.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:addRowBatch(10)
print("DataFrame:addRowBatch done")

--@api-stub: DataFrame:getColumnAsF64
-- Return a numeric column as a Lua array of numbers (nils → 0/nan).
-- Cheap to call; safe inside callbacks.
local dataFrame = lurek.dataframe.newDataFrame()  -- or your existing handle
local value = dataFrame:getColumnAsF64(col)
print("DataFrame:getColumnAsF64 ->", value)

--@api-stub: DataFrame:setColumnFromF64
-- Set a numeric column from a Lua array of numbers.
-- Apply at startup or in response to user input.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:setColumnFromF64(col, values)
print("DataFrame:setColumnFromF64 applied")

--@api-stub: DataFrame:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:type()
print("DataFrame:type done")

--@api-stub: DataFrame:typeOf
-- Returns true if this object is of the given type.
-- See the module spec for detailed semantics.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:typeOf("main")
print("DataFrame:typeOf done")

--@api-stub: DataFrame:withEval
-- Returns a new DataFrame with an additional computed column named `col_name`.
-- See the module spec for detailed semantics.
local dataFrame = lurek.dataframe.newDataFrame()
dataFrame:withEval("main", expr)
print("DataFrame:withEval done")

-- ── Database methods ──

--@api-stub: Database:getTable
-- Returns a copy of a table by name, or nil if not found.
-- Cheap to call; safe inside callbacks.
local database = lurek.dataframe.newDatabase()  -- or your existing handle
local value = database:getTable("main")
print("Database:getTable ->", value)

--@api-stub: Database:removeTable
-- Drops the named table from this in-memory database if it exists.
-- Pair with the matching constructor to free resources.
local database = lurek.dataframe.newDatabase()
database:removeTable("main")
-- database is now released
print("ok")

--@api-stub: Database:hasTable
-- Returns true if a table with the given name exists.
-- Use as a guard inside lurek.update or event handlers.
local database = lurek.dataframe.newDatabase()
if database:hasTable("main") then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Database:listTables
-- Returns a table of all table names.
-- See the module spec for detailed semantics.
local database = lurek.dataframe.newDatabase()
database:listTables()
print("Database:listTables done")

--@api-stub: Database:tableCount
-- Returns the number of tables.
-- See the module spec for detailed semantics.
local database = lurek.dataframe.newDatabase()
database:tableCount()
print("Database:tableCount done")

--@api-stub: Database:clear
-- Drops every table from this in-memory database, leaving it empty.
-- Pair with the matching constructor to free resources.
local database = lurek.dataframe.newDatabase()
database:clear()
-- database is now released
print("ok")

--@api-stub: Database:merge
-- Merges all tables from another Database into this one.
-- See the module spec for detailed semantics.
local database = lurek.dataframe.newDatabase()
database:merge(other)
print("Database:merge done")

--@api-stub: Database:toJSON
-- Serializes all tables to a JSON object string.
-- See the module spec for detailed semantics.
local database = lurek.dataframe.newDatabase()
database:toJSON()
print("Database:toJSON done")

--@api-stub: Database:query
-- Executes a SQL query against the database tables.
-- Cheap to call; safe inside callbacks.
local database = lurek.dataframe.newDatabase()  -- or your existing handle
local value = database:query("hello")
print("Database:query ->", value)

--@api-stub: Database:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local database = lurek.dataframe.newDatabase()
database:type()
print("Database:type done")

--@api-stub: Database:typeOf
-- Returns true if this object is of the given type.
-- See the module spec for detailed semantics.
local database = lurek.dataframe.newDatabase()
database:typeOf("main")
print("Database:typeOf done")

