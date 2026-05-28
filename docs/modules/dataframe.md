# Dataframe

- The `dataframe` module provides a powerful in-memory, column-major tabular data engine that brings lightweight SQL-style querying and advanced data manipulation to Lurek2D.

Positioned within the Foundations tier, it offers robust data analytics capabilities completely decoupled from engine-specific state. The core data structure is the `DataFrame`, which stores named columns containing `CellValue` variants (Nil, Bool, Int, Float, String). It provides a comprehensive set of operations including adding or removing columns and rows, cell access, sorting, and filtering via predicates. The module also supports advanced tabular functions like inner, left, right, and full joins, grouping, and aggregations (sum, mean, min, max, count).

For analytical workloads, the module includes an extensive suite of window functions (rank, row_number, lag, lead, running totals) and processing helpers such as value counts, missing value reports, duplicate row extraction, and ISO date part extraction. A lazy query builder (`LazyQuery`) is available to chain sequential query steps (filter, sort, select, slice) before materializing the final frame, improving efficiency for complex data pipelines. Additionally, for highly performant bulk numeric operations, a vectorized variant called `VecFrame` leverages parallel operations and typed storage.

A standout feature is the `Database` container, which holds multiple named `DataFrame` instances and acts as a localized query catalog. The module features a bespoke, built-in SQL engine complete with a tokenizer and recursive-descent parser. This engine natively executes SQL queries across the database, supporting full SELECT statements with WHERE clauses, GROUP BY, ORDER BY, LIMIT, subqueries, and table JOINs. It robustly handles explicit `AS` aliases, aggregate calls, and complex arithmetic expressions, including parameterized queries with positional `?` placeholders.

To facilitate seamless data interchange, the module implements native serialization and deserialization for CSV, JSON, and compact binary (LVDF) formats. Recognizing the performance impact of parsing large datasets, these operations—alongside SQL queries—can be executed asynchronously on Rust worker threads using `DataFrameTask`. These tasks operate on storage snapshots, ensuring that heavy I/O and SQL processing do not block the main Lua thread. The entire robust feature set is exposed to script authors through the `lurek.dataframe.*` API, enabling sophisticated data engineering and analytics within game scripts.

## Functions

### `lurek.dataframe.fromBinary`

Parses a dataframe from binary data.

```lua
-- signature
lurek.dataframe.fromBinary(s)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `s` | `string` | Binary dataframe payload. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | New dataframe handle. |

**Example**

```lua
do
-- Deserializes a dataframe from its compact binary format
  -- fromBinary restores a dataframe that was serialised with toBinary().
  local src = lurek.dataframe.fromTable({{x = 1, y = 2}})
  local df = lurek.dataframe.fromBinary(src:toBinary())
  lurek.log.info("fromBinary rows: " .. df:nrows())
end
```

---

### `lurek.dataframe.fromCSV`

Parses a dataframe from CSV text. This function is exposed to Lua scripts.

```lua
-- signature
lurek.dataframe.fromCSV(s)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `s` | `string` | CSV text. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | New dataframe handle. |

**Example**

```lua
do
-- Parses a dataframe from CSV-formatted text
  -- fromCSV parses CSV text; the first line becomes column headers.
  local df = lurek.dataframe.fromCSV("name,hp\nGoblin,30\nOrc,60\n")
  lurek.log.info("fromCSV rows: " .. df:nrows())
end
```

---

### `lurek.dataframe.fromCSVFile`

Reads CSV text from GameFS and parses it into a dataframe.

```lua
-- signature
lurek.dataframe.fromCSVFile(path, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | GameFS path to read. |
| `opts?` | `table` | Optional file options table; reserved for future CSV options. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | New dataframe handle. |

**Example**

```lua
do
  local path = "save/dataframe_example.csv"
  local source = lurek.dataframe.fromRows({ "name", "score" }, { { "Alice", 10 }, { "Bob", 20 } })
  source:toCSVFile(path)
  local df = lurek.dataframe.fromCSVFile(path)
  print("csv rows", df:nrows())
  print(df:head(1):toString())
end
```

---

### `lurek.dataframe.fromCSVFileAsync`

Starts a Rust worker task that reads CSV text from GameFS and parses it into a dataframe.

```lua
-- signature
lurek.dataframe.fromCSVFileAsync(path, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | GameFS path to read. |
| `opts?` | `table` | Optional file options table; reserved for future CSV options. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrameTask` | Task that resolves to a dataframe loaded from the CSV file. |

**Example**

```lua
do
  local path = "save/dataframe_example_async.csv"
  local source = lurek.dataframe.fromRows({ "name", "score" }, { { "Alice", 10 }, { "Bob", 20 } })
  source:toCSVFile(path)
  local task = lurek.dataframe.fromCSVFileAsync(path)
  print("csv async started", task:type())
  task:wait()
  if task:getError() == nil then
    local df = task:result()
    print("csv async rows", df:nrows())
  end
end
```

---

### `lurek.dataframe.fromJSON`

Parses a dataframe from JSON text. This function is exposed to Lua scripts.

```lua
-- signature
lurek.dataframe.fromJSON(s)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `s` | `string` | JSON text. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | New dataframe handle. |

**Example**

```lua
do
-- Parses a dataframe from a JSON array of objects
  -- fromJSON parses a JSON array of objects into a dataframe.
  local df = lurek.dataframe.fromJSON('[{"name":"Goblin","hp":30},{"name":"Orc","hp":60}]')
  lurek.log.info("fromJSON rows: " .. df:nrows())
end
```

---

### `lurek.dataframe.fromJSONFile`

Reads JSON text from GameFS and parses it into a dataframe.

```lua
-- signature
lurek.dataframe.fromJSONFile(path, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | GameFS path to read. |
| `opts?` | `table` | Optional file options table; reserved for future JSON options. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | New dataframe handle. |

**Example**

```lua
do
  local path = "save/dataframe_example.json"
  local source = lurek.dataframe.fromRows({ "name", "score" }, { { "Alice", 10 }, { "Bob", 20 } })
  source:toJSONFile(path)
  local df = lurek.dataframe.fromJSONFile(path)
  print("json rows", df:nrows())
  local columns = df:columns()
  print("Loaded schema:", table.concat(columns, ", "))
end
```

---

### `lurek.dataframe.fromJSONFileAsync`

Starts a Rust worker task that reads JSON text from GameFS and parses it into a dataframe.

```lua
-- signature
lurek.dataframe.fromJSONFileAsync(path, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | GameFS path to read. |
| `opts?` | `table` | Optional file options table; reserved for future JSON options. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrameTask` | Task that resolves to a dataframe loaded from the JSON file. |

**Example**

```lua
do
  local path = "save/dataframe_example_async.json"
  local source = lurek.dataframe.fromRows({ "name", "score" }, { { "Alice", 10 }, { "Bob", 20 } })
  source:toJSONFile(path)
  local task = lurek.dataframe.fromJSONFileAsync(path)
  print("json async started", task:type())
  task:wait()
  if not task:getError() then
    local df = task:result()
    print("json async rows", df:nrows())
  end
end
```

---

### `lurek.dataframe.fromRows`

Creates a dataframe from column names and array-style rows.

```lua
-- signature
lurek.dataframe.fromRows(columns_tbl, rows_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `columns_tbl` | `table` | Array table of column names. |
| `rows_tbl` | `table` | Array table of row arrays. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | New dataframe handle. |

**Example**

```lua
do
-- Creates a dataframe from column names and positional row arrays
  -- fromRows maps column names to positional arrays; no key look-up overhead.
  local df = lurek.dataframe.fromRows({"name", "hp"}, {{"Goblin", 30}, {"Orc", 60}})
  lurek.log.info("fromRows rows: " .. df:nrows())
end
```

---

### `lurek.dataframe.fromTable`

Creates a dataframe from an array table of row tables.

```lua
-- signature
lurek.dataframe.fromTable(rows)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `rows` | `table` | Array of row tables keyed by column name. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | New dataframe handle. |

**Example**

```lua
do
-- Creates a dataframe from an array of row tables (most common constructor)
  -- fromTable converts a Lua array-of-row-tables into a dataframe.
  local df = lurek.dataframe.fromTable({{name = "Goblin", hp = 30}, {name = "Orc", hp = 60}})
  lurek.log.info("fromTable rows: " .. df:nrows())
end
```

---

### `lurek.dataframe.fromVec`

Converts a vectorized frame to a dataframe.

```lua
-- signature
lurek.dataframe.fromVec(vf)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `vf` | `LVecFrame` | Vectorized frame handle to convert. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | New dataframe handle. |

**Example**

```lua
do
-- Converts a VecFrame back to a regular DataFrame
  -- fromVec converts a VecFrame back to a regular DataFrame.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("hp\n100\n200\n"))
  vf:colMul("hp", 0.5)
  local df = lurek.dataframe.fromVec(vf)
  lurek.log.info("hp after reduction: " .. tostring(df:getValue(1, "hp")))
end
```

---

### `lurek.dataframe.loadDatabase`

Reads a JSON database file from GameFS and parses it into a database.

```lua
-- signature
lurek.dataframe.loadDatabase(path, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | GameFS path to read. |
| `opts?` | `table` | Optional options table; `format = "json"` is the only supported format. |

**Returns**

| Type | Description |
|------|-------------|
| `LDatabase` | New database handle. |

**Example**

```lua
do
  local path = "save/dataframe_database.json"
  local db = lurek.dataframe.newDatabase()
  local players = lurek.dataframe.fromRows({ "name", "level" }, { { "Alice", 10 }, { "Bob", 20 } })
  db:addTable("players", players)
  db:save(path)
  local restored = lurek.dataframe.loadDatabase(path)
  local loaded_players = restored:getTable("players")
  if loaded_players then
    print("Loaded " .. loaded_players:nrows() .. " player records")
    print(loaded_players:toString())
  end
end
```

---

### `lurek.dataframe.newDataFrame`

Creates an empty dataframe. This function is exposed to Lua scripts.

```lua
-- signature
lurek.dataframe.newDataFrame()
```

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | New empty dataframe handle. |

**Example**

```lua
do
-- Creates an empty dataframe with no columns or rows
  -- newDataFrame builds an empty frame; define columns before inserting rows.
  local df = lurek.dataframe.newDataFrame()
  lurek.log.info("empty dataframe ready")
end
```

---

### `lurek.dataframe.newDatabase`

Creates an empty dataframe database.

```lua
-- signature
lurek.dataframe.newDatabase()
```

**Returns**

| Type | Description |
|------|-------------|
| `LDatabase` | New database handle. |

**Example**

```lua
do
-- Creates an empty dataframe database for managing multiple named tables
  -- newDatabase returns an empty container for named dataframes.
  local db = lurek.dataframe.newDatabase()
  lurek.log.info("empty database ready")
end
```

---

### `lurek.dataframe.random`

Creates a random dataframe from column definitions.

```lua
-- signature
lurek.dataframe.random(defs_tbl, n, seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `defs_tbl` | `table` | Array table of `{name, hint}` column definitions. |
| `n` | `number` | Number of rows to generate. |
| `seed?` | `number` | Optional random seed. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | New random dataframe handle. |

**Example**

```lua
do
-- Generates a random dataframe from column type definitions
  -- random generates test data using column type hints and an optional seed.
  local df = lurek.dataframe.random({{"id", "id"}, {"hp", "int"}}, 10, 1)
  lurek.log.info("random rows: " .. df:nrows())
end
```

---

### `lurek.dataframe.toVec`

Converts a dataframe to a vectorized frame.

```lua
-- signature
lurek.dataframe.toVec(df)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `df` | `LDataFrame` | Dataframe handle to convert. |

**Returns**

| Type | Description |
|------|-------------|
| `LVecFrame` | New vectorized frame handle. |

**Example**

```lua
do
-- Converts a dataframe to a vectorized VecFrame for bulk numeric operations
  -- toVec converts a DataFrame to a VecFrame optimised for bulk numeric ops.
  local df = lurek.dataframe.fromCSV("hp,mp\n100,50\n200,80\n")
  local vf = lurek.dataframe.toVec(df)
  lurek.log.info("VecFrame rows: " .. vf:nrows())
end
```

---

## LDataFrame

### `LDataFrame:addColumn`

Adds a column with an optional default value.

```lua
-- signature
LDataFrame:addColumn(name, default)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Column name to create. |
| `default?` | `any` | Default cell value for existing rows; nil uses empty cells. |

**Example**

```lua
do
  -- Use newDataFrame when you need to build a table incrementally at runtime,
  -- such as tracking player session stats as events come in.
  local stats = lurek.dataframe.newDataFrame()

  -- Define the schema: each addColumn call creates a named column with a default value.
  -- The default is used when a row is added without specifying that column.
  stats:addColumn("name", "")
  stats:addColumn("score", 0)
  stats:addColumn("deaths", 0)

  -- Add rows as the session progresses
  stats:addRow({name = "Alice", score = 1200, deaths = 3})
  stats:addRow({name = "Bob", score = 980, deaths = 5})

  -- The dataframe now has 2 rows and 3 columns
  lurek.log.info("session stats: " .. stats:nrows() .. " players tracked")
end
```

---

### `LDataFrame:addRow`

Adds a row from an optional map table and returns its one-based row index.

```lua
-- signature
LDataFrame:addRow(row_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `row_tbl?` | `table` | Optional table mapping column names to cell values. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | One-based index of the inserted row. |

**Example**

```lua
do
-- Appends a row and returns its one-based index
  -- addRow appends one record and returns its 1-based row index.
  local df = lurek.dataframe.newDataFrame()
  df:addColumn("event", "")
  local idx = df:addRow({event = "spawn"})
  lurek.log.info("added at row " .. idx)
end
```

---

### `LDataFrame:addRowBatch`

Appends multiple rows from array-style row tables.

```lua
-- signature
LDataFrame:addRowBatch(rows)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `rows` | `table` | Array of row arrays matching the dataframe column order. |

**Example**

```lua
do
-- Appends multiple rows at once from positional arrays (faster than repeated addRow)
  -- addRowBatch inserts multiple rows at once; faster than repeated addRow.
  local df = lurek.dataframe.newDataFrame()
  df:addColumn("x", 0)
  df:addColumn("y", 0)
  df:addRowBatch({{1, 2}, {3, 4}, {5, 6}})
  lurek.log.info("rows after batch: " .. df:nrows())
end
```

---

### `LDataFrame:apply`

Applies a Lua function to each value in a column in place.

```lua
-- signature
LDataFrame:apply(col_val, func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col_val` | `string` | Column name string or one-based column index. |
| `func` | `function` | Function called with each cell value and returning a replacement value. |

**Example**

```lua
do
-- Transforms every cell in a column using a Lua function (in-place)
  -- apply transforms every cell in a column using a Lua function (in-place).
  local df = lurek.dataframe.fromTable({{score=60},{score=80},{score=45}})
  df:apply("score", function(v) return v >= 70 and "pass" or "fail" end)
  lurek.log.info("grade[1]: " .. df:getValue(1, "score"))
end
```

---

### `LDataFrame:clone`

Returns a deep copy of this dataframe.

```lua
-- signature
LDataFrame:clone()
```

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | New dataframe containing copied data. |

**Example**

```lua
do
-- Returns a deep copy of this dataframe (modifications don't affect the original)
  -- clone returns a deep copy; mutations to the copy don't affect the original.
  local base = lurek.dataframe.fromTable({{stat="atk",value=10}})
  local copy = base:clone()
  copy:setValue(1, "value", 99)
  lurek.log.info("base atk=" .. base:getValue(1,"value") .. " copy=" .. copy:getValue(1,"value"))
end
```

---

### `LDataFrame:columns`

Returns all column names in order. This method is available to Lua scripts.

```lua
-- signature
LDataFrame:columns()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Column names. |

**Example**

```lua
do
-- Returns all column names in order. This method is available to Lua scripts.
  -- columns() returns all column names in order as a Lua array.
  local df = lurek.dataframe.fromTable({{hp=100,mp=50,stamina=80}})
  local cols = df:columns()
  lurek.log.info("schema: " .. table.concat(cols, ", "))
end
```

---

### `LDataFrame:corr`

Returns correlation between two numeric columns.

```lua
-- signature
LDataFrame:corr(col_a, col_b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col_a` | `string` | Column name string or one-based column index. |
| `col_b` | `string` | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Correlation value. |

**Example**

```lua
do
-- Returns the Pearson correlation between two numeric columns
  -- corr returns Pearson correlation between two numeric columns.
  local df = lurek.dataframe.fromTable({{x=1,y=2},{x=2,y=4},{x=3,y=6}})
  local r = df:corr("x", "y")
  lurek.log.info("corr x,y: " .. string.format("%.3f", r))
end
```

---

### `LDataFrame:correlationMatrix`

Returns a correlation matrix for numeric columns.

```lua
-- signature
LDataFrame:correlationMatrix()
```

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | Correlation matrix dataframe. |

**Example**

```lua
do
-- Returns a correlation matrix dataframe for all numeric columns
  -- correlationMatrix shows pairwise linear correlation between numeric columns.
  local df = lurek.dataframe.fromTable({{a=1,b=2},{a=2,b=4},{a=3,b=6}})
  local matrix = df:correlationMatrix()
  lurek.log.info("correlation matrix cols: " .. matrix:ncols())
end
```

---

### `LDataFrame:count`

Returns the row count for this dataframe.

```lua
-- signature
LDataFrame:count()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Row count. |

**Example**

```lua
do
-- Returns the total count of non-nil items in this dataframe
  local df = lurek.dataframe.fromTable({{a = 1, b = 2}, {a = 3, b = 4}})
  print("row count", df:count())
end
```

---

### `LDataFrame:countBy`

Counts occurrences of each value in a column.

```lua
-- signature
LDataFrame:countBy(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | New dataframe containing value counts. |

**Example**

```lua
do
-- Counts occurrences of each value in a column; returns a new dataframe
  -- countBy builds a frequency table: one row per distinct value in the column.
  local df = lurek.dataframe.fromTable({{item="sword"},{item="bow"},{item="sword"}})
  local freq = df:countBy("item")
  lurek.log.info("frequency rows: " .. freq:nrows())
end
```

---

### `LDataFrame:dateParts`

Returns a new dataframe with year, month, and day columns extracted from ISO `yyyy-mm-dd` text.

```lua
-- signature
LDataFrame:dateParts(date_col, prefix)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `date_col` | `any` | Column name string or one-based column index containing ISO date text. |
| `prefix?` | `string` | Optional output prefix; `prefix = "txn"` creates `txn_year`, `txn_month`, and `txn_day`. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | New dataframe with extracted date-part columns; invalid or missing dates produce nil parts. |

**Example**

```lua
do
  local df = lurek.dataframe.fromTable({
    {login_date = "2026-05-21"},
  })
  local parts = df:dateParts("login_date")
  local row = parts:getRow(1)
  print("date parts rows", parts:nrows())
  print("year", row.year, "month", row.month, "day", row.day)
end
```

---

### `LDataFrame:describe`

Returns summary statistics for numeric columns.

```lua
-- signature
LDataFrame:describe()
```

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | New dataframe containing descriptive statistics. |

**Example**

```lua
do
-- Returns summary statistics (count, mean, std, min, max) for numeric columns
  -- describe returns a summary-stats frame (min, max, mean, std per numeric col).
  local df = lurek.dataframe.fromTable({{v=1},{v=2},{v=3},{v=4},{v=5}})
  local stats = df:describe()
  lurek.log.info("describe rows: " .. stats:nrows())
end
```

---

### `LDataFrame:dropNil`

Returns rows where the chosen column is not nil.

```lua
-- signature
LDataFrame:dropNil(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | New dataframe without nil rows for the column. |

**Example**

```lua
do
-- Returns rows where the chosen column is not nil.
  -- dropNil returns a new frame with rows where the column is nil removed.
  local df = lurek.dataframe.fromTable({{item="Gem",rarity="rare"},{item="Rock",rarity=nil},{item="Ring",rarity="epic"}})
  local clean = df:dropNil("rarity")
  lurek.log.info("valid loot rows: " .. clean:nrows())
end
```

---

### `LDataFrame:duplicateRows`

Returns rows whose full-row key or selected-column key appears more than once.

```lua
-- signature
LDataFrame:duplicateRows(cols)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cols?` | `table` | Optional array table of column name strings or one-based column indexes used as the duplicate key. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | New dataframe containing duplicate rows in original order. |

**Example**

```lua
do
  local df = lurek.dataframe.fromTable({
    {id = 1, name = "A"},
    {id = 2, name = "B"},
    {id = 1, name = "A"},
  })
  local duplicates = df:duplicateRows({ "id" })
  print("duplicate rows", duplicates:nrows())
  if duplicates:nrows() > 0 then
    print(duplicates:toString())
  end
end
```

---

### `LDataFrame:entropy`

Returns entropy for a column. This method is available to Lua scripts.

```lua
-- signature
LDataFrame:entropy(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Entropy value. |

**Example**

```lua
do
-- Returns the Shannon entropy of a column (measures diversity)
  -- entropy quantifies value diversity (bits); 0 = all same, high = many different.
  local df = lurek.dataframe.fromTable({{cls="warrior"},{cls="mage"},{cls="rogue"}})
  lurek.log.info("class entropy: " .. string.format("%.2f", df:entropy("cls")))
end
```

---

### `LDataFrame:fillNil`

Replaces nil cells in a column with a value.

```lua
-- signature
LDataFrame:fillNil(col, val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name string or one-based column index. |
| `val` | `any` | Replacement cell value. |

**Example**

```lua
do
-- Replaces nil cells in a column with a specified value
  -- fillNil replaces nil cells with a default so aggregations don't fail.
  local df = lurek.dataframe.fromTable({{s=10},{s=nil},{s=5}})
  df:fillNil("s", 0)
  lurek.log.info("sum after fill: " .. df:sum("s"))
end
```

---

### `LDataFrame:filter`

Returns rows whose column value matches a comparison.

```lua
-- signature
LDataFrame:filter(col, op, val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `any` | Column name string or one-based column index. |
| `op` | `string` | Comparison operator string. |
| `val` | `any` | Cell value used as the comparison target. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | New filtered dataframe. |

**Example**

```lua
do
-- Returns rows whose column value matches a comparison.
  -- filter returns a new frame with only the rows matching the condition.
  local df = lurek.dataframe.fromTable({{enemy="Goblin",hp=30},{enemy="Orc",hp=80}})
  local strong = df:filter("hp", ">", 50)
  lurek.log.info("strong enemies: " .. strong:nrows())
end
```

---

### `LDataFrame:getColumn`

Returns a column as an array table. This method is available to Lua scripts.

```lua
-- signature
LDataFrame:getColumn(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `any` | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Array table of column values. |

**Example**

```lua
do
-- Returns all values in a column as an array table
  -- getColumn extracts all values in a named column as a plain Lua array.
  local df = lurek.dataframe.fromTable({{hp = 10}, {hp = 20}, {hp = 30}})
  local vals = df:getColumn("hp")
  lurek.log.info("hp[2] = " .. vals[2])
end
```

---

### `LDataFrame:getColumnAsF64`

Returns a numeric column as an array of numbers.

```lua
-- signature
LDataFrame:getColumnAsF64(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Numeric values. |

**Example**

```lua
do
-- Returns a numeric column as an array of Lua numbers (float64)
  -- getColumnAsF64 extracts a numeric column as a flat Lua number array.
  local df = lurek.dataframe.fromTable({{hp=10},{hp=20},{hp=30}})
  local vals = df:getColumnAsF64("hp")
  lurek.log.info("hp[1] = " .. vals[1])
end
```

---

### `LDataFrame:getRow`

Returns a row as a table keyed by column name.

```lua
-- signature
LDataFrame:getRow(row)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `row` | `number` | One-based row index to read. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Row table keyed by column name. |

**Example**

```lua
do
-- Returns a row as a table keyed by column name
  -- getRow returns one record as a {col = value} Lua table.
  local df = lurek.dataframe.fromTable({{name = "Alice", hp = 80}})
  local row = df:getRow(1)
  lurek.log.info(row.name .. " hp=" .. row.hp)
end
```

---

### `LDataFrame:getValue`

Returns one cell value by one-based row and column reference.

```lua
-- signature
LDataFrame:getValue(row, col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `row` | `number` | One-based row index. |
| `col` | `any` | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | string|boolean|nil | Cell value at the requested row and column. |

**Example**

```lua
do
-- Returns one cell value by row index and column reference
  -- getValue reads one cell by 1-based row index and column name.
  local df = lurek.dataframe.fromTable({{name = "Alice", score = 950}})
  lurek.log.info("score: " .. df:getValue(1, "score"))
end
```

---

### `LDataFrame:groupAgg`

Groups by one column and aggregates another column.

```lua
-- signature
LDataFrame:groupAgg(group_col, agg_col, fn_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `group_col` | `string` | Column name string or one-based column index. |
| `agg_col` | `string` | Column name string or one-based column index. |
| `fn_name` | `string` | Aggregate function name. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | New grouped aggregate dataframe. |

**Example**

```lua
do
-- Groups by one column and aggregates another with a built-in function
  -- groupAgg groups by one column and aggregates another with a built-in function.
  local df = lurek.dataframe.fromTable({
    {region="N",revenue=500},{region="N",revenue=300},{region="S",revenue=700}
  })
  local totals = df:groupAgg("region", "revenue", "sum")
  lurek.log.info("aggregated rows: " .. totals:nrows())
end
```

---

### `LDataFrame:groupBy`

Groups rows by a column and returns a table from group key to dataframe.

```lua
-- signature
LDataFrame:groupBy(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Table keyed by group values with dataframe handles as values. |

**Example**

```lua
do
-- Groups rows by column value; returns a table of {key = sub-dataframe}
  -- groupBy splits the frame into per-key sub-dataframes in a Lua table.
  local df = lurek.dataframe.fromTable({
    {team="red",pts=10},{team="blue",pts=20},{team="red",pts=5}
  })
  local groups = df:groupBy("team")
  lurek.log.info("red team rows: " .. groups["red"]:nrows())
end
```

---

### `LDataFrame:groupByObj`

Groups rows by a column and returns a grouped-frame object.

```lua
-- signature
LDataFrame:groupByObj(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| `LGroupedFrame` | Grouped frame handle. |

**Example**

```lua
do
-- Groups rows by a column and returns a GroupedFrame object
  local df = lurek.dataframe.fromTable({
    {region="EU",score=100},{region="NA",score=200},{region="EU",score=150}
  })
  local grouped = df:groupByObj("region")
  print("grouped type", grouped:type())
end
```

---

### `LDataFrame:head`

Returns the first rows of this dataframe.

```lua
-- signature
LDataFrame:head(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n?` | `number` | Number of rows to return; defaults to 5. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | New dataframe containing the first rows. |

**Example**

```lua
do
-- Returns the first rows of this dataframe.
  -- head returns a new frame containing only the first N rows.
  local df = lurek.dataframe.fromTable({{item="Sword"},{item="Shield"},{item="Potion"},{item="Arrow"}})
  local preview = df:head(3)
  lurek.log.info("preview rows: " .. preview:nrows())
end
```

---

### `LDataFrame:join`

Joins this dataframe with another dataframe by column references.

```lua
-- signature
LDataFrame:join(other, this_col, other_col, jtype)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | `LDataFrame` | Other dataframe to join. |
| `this_col` | `string` | Column name string or one-based column index. |
| `other_col` | `string` | Column name string or one-based column index. |
| `jtype?` | `string` | Join type string; defaults to `inner`. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | New joined dataframe. |

**Example**

```lua
do
-- Joins two dataframes by column (inner, left, right, or outer)
  -- join combines two frames on matching column values.
  local players = lurek.dataframe.fromTable({{id=1,name="Alice"},{id=2,name="Bob"}})
  local guilds  = lurek.dataframe.fromTable({{player_id=1,guild="Phoenix"},{player_id=2,guild="Shadow"}})
  local merged = players:join(guilds, "id", "player_id", "inner")
  lurek.log.info("joined rows: " .. merged:nrows())
end
```

---

### `LDataFrame:lazy`

Starts a lazy query pipeline from this dataframe.

```lua
-- signature
LDataFrame:lazy()
```

**Returns**

| Type | Description |
|------|-------------|
| `LLazyQuery` | New lazy query handle. |

**Example**

```lua
do
-- Starts a lazy query pipeline from this dataframe
  -- lazy() returns a deferred query handle; operations are chained, not executed yet.
  local df = lurek.dataframe.fromTable({{hp=12,team="red"},{hp=7,team="blue"}})
  local q = df:lazy()
  lurek.log.info("lazy query type: " .. tostring(q:type()))
end
```

---

### `LDataFrame:max`

Returns the maximum value of a column.

```lua
-- signature
LDataFrame:max(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `any` | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | string|boolean|nil | Maximum cell value. |

**Example**

```lua
do
-- Returns the maximum value of a column
  -- max returns the largest value in a numeric column.
  local df = lurek.dataframe.fromTable({{s=100},{s=450},{s=380}})
  lurek.log.info("high score: " .. df:max("s"))
end
```

---

### `LDataFrame:mean`

Returns the numeric mean of a column.

```lua
-- signature
LDataFrame:mean(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `any` | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Column mean. |

**Example**

```lua
do
-- Returns the arithmetic mean of a numeric column
  -- mean computes the arithmetic average of a numeric column.
  local df = lurek.dataframe.fromTable({{ms=16},{ms=17},{ms=33}})
  lurek.log.info("avg ms: " .. df:mean("ms"))
end
```

---

### `LDataFrame:median`

Returns the numeric median of a column.

```lua
-- signature
LDataFrame:median(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `any` | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Column median. |

**Example**

```lua
do
-- Returns the median (middle value) of a numeric column
  -- median returns the middle value and is robust against outliers.
  local df = lurek.dataframe.fromTable({{ms=16},{ms=16},{ms=17},{ms=200}})
  lurek.log.info("typical ms: " .. df:median("ms"))
end
```

---

### `LDataFrame:merge`

Appends another dataframe into this dataframe in place.

```lua
-- signature
LDataFrame:merge(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | `LDataFrame` | Dataframe whose rows are merged into this dataframe. |

**Example**

```lua
do
-- Appends another dataframe into this dataframe in place.
  -- merge appends another frame's rows into this frame in-place.
  local wave1 = lurek.dataframe.fromTable({{enemy="Goblin",hp=30}})
  local wave2 = lurek.dataframe.fromTable({{enemy="Orc",hp=80}})
  wave1:merge(wave2)
  lurek.log.info("combined spawn count: " .. wave1:nrows())
end
```

---

### `LDataFrame:min`

Returns the minimum value of a column.

```lua
-- signature
LDataFrame:min(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `any` | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | string|boolean|nil | Minimum cell value. |

**Example**

```lua
do
-- Returns the minimum value of a column
  -- min returns the smallest value in a numeric column.
  local df = lurek.dataframe.fromTable({{t=140},{t=138},{t=145}})
  lurek.log.info("best time: " .. df:min("t"))
end
```

---

### `LDataFrame:missingReport`

Reports missing and non-missing cell counts for every column.

```lua
-- signature
LDataFrame:missingReport(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | `table` | Optional options table reserved for future report settings. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | New dataframe containing `column`, `missing`, `non_missing`, and `missing_percent` columns. |

**Example**

```lua
do
  local df = lurek.dataframe.fromTable({
    {score = 100},
    {score = nil},
    {score = 200},
  })
  local report = df:missingReport()
  print("missing report rows", report:nrows())
  print(report:toString())
end
```

---

### `LDataFrame:modeVal`

Returns the mode value of a column. This method is available to Lua scripts.

```lua
-- signature
LDataFrame:modeVal(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | string|boolean|nil | Most common cell value. |

**Example**

```lua
do
-- Returns the most frequently occurring value in a column
  -- modeVal returns the most frequently occurring value in a column.
  local df = lurek.dataframe.fromTable({{w="sword"},{w="bow"},{w="sword"},{w="staff"},{w="sword"}})
  lurek.log.info("most popular: " .. tostring(df:modeVal("w")))
end
```

---

### `LDataFrame:ncols`

Returns the number of columns in this dataframe.

```lua
-- signature
LDataFrame:ncols()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Column count. |

**Example**

```lua
do
-- Returns the number of columns in this dataframe.
  -- ncols returns how many columns the schema has.
  local df = lurek.dataframe.fromTable({{name="Sword",damage=12,weight=3}})
  lurek.log.info("item schema cols: " .. df:ncols())
end
```

---

### `LDataFrame:normalizeCol`

Adds a range-normalized column in place.

```lua
-- signature
LDataFrame:normalizeCol(col, out_min, out_max, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name string or one-based column index. |
| `out_min` | `number` | Output lower bound. |
| `out_max` | `number` | Output upper bound. |
| `name` | `string` | Output column name. |

**Example**

```lua
do
-- Adds a range-normalized column (maps values to [out_min, out_max])
  -- normalizeCol maps a column's range to [out_min, out_max] and stores it.
  local df = lurek.dataframe.fromTable({{val=10},{val=50},{val=90}})
  df:normalizeCol("val", 0.0, 1.0, "val_norm")
  lurek.log.info("normalised column added: " .. df:ncols() .. " cols")
end
```

---

### `LDataFrame:nrows`

Returns the number of rows in this dataframe.

```lua
-- signature
LDataFrame:nrows()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Row count. |

**Example**

```lua
do
-- Returns the number of rows in this dataframe.
  -- nrows returns the row count; check it before iterating or indexing.
  local df = lurek.dataframe.fromTable({{name="Alice"},{name="Bob"},{name="Cara"}})
  lurek.log.info("player count: " .. df:nrows())
end
```

---

### `LDataFrame:outliers`

Returns rows considered outliers for a numeric column.

```lua
-- signature
LDataFrame:outliers(col, threshold)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name string or one-based column index. |
| `threshold?` | `number` | Z-score threshold; defaults to 2.0. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | New dataframe containing outlier rows. |

**Example**

```lua
do
-- Returns rows where a column value is a statistical outlier (z-score based)
  -- outliers returns rows whose column value is a statistical outlier.
  local df = lurek.dataframe.newDataFrame()
  df:addColumn("ms", 0)
  for i = 1, 10 do df:addRow({ms = 15 + i}) end
  df:addRow({ms = 1000})
  local spikes = df:outliers("ms", 2.0)
  lurek.log.info("spikes: " .. spikes:nrows())
end
```

---

### `LDataFrame:parFilter`

Parallel filter — automatically parallelizes when frame has 10,000+ rows.

```lua
-- signature
LDataFrame:parFilter(col, op, val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `any` | Column name string or one-based column index. |
| `op` | `string` | Comparison operator (==, !=, <, >, <=, >=, contains). |
| `val` | `any` | Value to compare against. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | New filtered DataFrame. |

**Example**

```lua
do
  local df = lurek.dataframe.fromRows({ "x" }, { {1}, {2}, {3}, {4}, {5}, {6} })
  local out = df:parFilter("x", ">", 3)
  print("parFilter rows", out:nrows())
  print(out:toString())
end
```

---

### `LDataFrame:parGroupAgg`

Parallel group-by aggregation — partitions and aggregates in parallel.

```lua
-- signature
LDataFrame:parGroupAgg(group_col, agg_col, fn_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `group_col` | `any` | Column name string or one-based column index. |
| `agg_col` | `any` | Column name string or one-based column index. |
| `fn_name` | `string` | Aggregation function (sum, mean, count, min, max, first, last). |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | Grouped result. |

**Example**

```lua
do
  local df = lurek.dataframe.fromRows({ "g", "v" }, {
    {"a", 1},
    {"b", 2},
    {"a", 3},
    {"b", 4},
  })
  local out = df:parGroupAgg("g", "v", "sum")
  print("parGroupAgg rows", out:nrows())
  print(out:toString())
end
```

---

### `LDataFrame:pivot`

Pivots rows into columns using row, column, and value fields.

```lua
-- signature
LDataFrame:pivot(row_col, col_col, val_col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `row_col` | `string` | Column name string or one-based column index. |
| `col_col` | `string` | Column name string or one-based column index. |
| `val_col` | `string` | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | New pivoted dataframe. |

**Example**

```lua
do
-- Pivots rows into columns using row key, column key, and value fields
  -- pivot reshapes from long format (row_key, col_key, value) to wide format.
  local df = lurek.dataframe.fromTable({
    {player="Alice",stat="hp",value=100},{player="Alice",stat="mp",value=50},
    {player="Bob",  stat="hp",value=80}, {player="Bob",  stat="mp",value=70},
  })
  local wide = df:pivot("player", "stat", "value")
  lurek.log.info("pivot cols: " .. wide:ncols())
end
```

---

### `LDataFrame:pivotTable`

Builds a pivot table using row key, column key, value column, and aggregate function.

```lua
-- signature
LDataFrame:pivotTable(row_key, col_key, value_key, agg)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `row_key` | `string` | Column name string or one-based column index. |
| `col_key` | `string` | Column name string or one-based column index. |
| `value_key` | `string` | Column name string or one-based column index. |
| `agg?` | `string` | Aggregate function name; defaults to `mean`. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | New pivot table dataframe. |

**Example**

```lua
do
-- Builds a pivot table with aggregation (like a spreadsheet pivot)
  -- pivotTable groups by two dimensions and aggregates the value column.
  local df = lurek.dataframe.fromTable({
    {region="N",product="Sword",sales=50},{region="N",product="Shield",sales=30},
    {region="S",product="Sword",sales=70},{region="S",product="Shield",sales=40},
  })
  local pt = df:pivotTable("region", "product", "sales", "sum")
  lurek.log.info("pivot table rows: " .. pt:nrows())
end
```

---

### `LDataFrame:query`

Runs a SQL-style query against this dataframe.

```lua
-- signature
LDataFrame:query(sql_str)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sql_str` | `string` | SQL query text. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | Query result dataframe. |

**Example**

```lua
do
-- Runs a SQL-style query against this dataframe.
  -- query runs SQL against this frame (the frame is the table "t").
  local df = lurek.dataframe.fromTable({{item="Sword",gold=150},{item="Stick",gold=5}})
  local expensive = df:query("SELECT * FROM t WHERE gold > 100")
  lurek.log.info("expensive items: " .. expensive:nrows())
end
```

---

### `LDataFrame:queryAsync`

Runs a SQL-style query against this dataframe on a Rust worker thread.

```lua
-- signature
LDataFrame:queryAsync(sql_str)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sql_str` | `string` | SQL query text. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrameTask` | Task that resolves to the query result dataframe. |

**Example**

```lua
do
  local df = lurek.dataframe.fromTable({
    {age = 25},
    {age = 30},
  })
  local task = df:queryAsync("SELECT * FROM t WHERE age > 26")
  print("query task", task:type())
  task:wait()
  local result_df = task:result()
  print("async query rows", result_df:nrows())
  print(result_df:toString())
end
```

---

### `LDataFrame:rank`

Returns a dataframe with a rank column.

```lua
-- signature
LDataFrame:rank(col, order, result_col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name string or one-based column index. |
| `order?` | `string` | Rank order string; defaults to `asc`. |
| `result_col?` | `string` | Output column name; defaults to `rank`. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | New dataframe with the rank column. |

**Example**

```lua
do
-- Returns a new dataframe with a rank column added
  -- rank returns a new frame with a rank column based on the source column.
  local df = lurek.dataframe.fromTable({{player="Alice",score=80},{player="Bob",score=95},{player="Cara",score=72}})
  local ranked = df:rank("score", "desc", "position")
  lurek.log.info("ranked rows: " .. ranked:nrows())
end
```

---

### `LDataFrame:removeColumn`

Removes a column by name or one-based index.

```lua
-- signature
LDataFrame:removeColumn(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `any` | Column name string or one-based column index. |

**Example**

```lua
do
-- Removes a column from this dataframe by name or index
  -- removeColumn drops a named column, reducing ncols by one.
  local df = lurek.dataframe.fromTable({{name = "Alice", internal = "x7", score = 100}})
  df:removeColumn("internal")
  lurek.log.info("cols after remove: " .. df:ncols())
end
```

---

### `LDataFrame:removeRow`

Removes a row by one-based index. This method is available to Lua scripts.

```lua
-- signature
LDataFrame:removeRow(row)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `row` | `number` | One-based row index to remove. |

**Example**

```lua
do
-- Removes a row by one-based index
  -- removeRow deletes one record by 1-based index; later rows shift down.
  local df = lurek.dataframe.fromTable({{n = 1}, {n = 2}, {n = 3}})
  df:removeRow(2)
  lurek.log.info("rows after remove: " .. df:nrows())
end
```

---

### `LDataFrame:rename`

Renames a column by name or one-based index.

```lua
-- signature
LDataFrame:rename(col, new_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `any` | Column name string or one-based column index. |
| `new_name` | `string` | New column name. |

**Example**

```lua
do
-- Renames a column (by name or index) to a new name
  -- rename changes a column header without touching its data.
  local df = lurek.dataframe.fromTable({{pts = 100}})
  df:rename("pts", "score")
  lurek.log.info("renamed column: " .. df:columns()[1])
end
```

---

### `LDataFrame:rollingMean`

Returns a dataframe with a rolling mean column.

```lua
-- signature
LDataFrame:rollingMean(col, window, result_col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name string or one-based column index. |
| `window` | `number` | Rolling window size. |
| `result_col?` | `string` | Output column name; defaults to `rolling_mean`. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | New dataframe with the rolling mean column. |

**Example**

```lua
do
-- Returns a new dataframe with a rolling average column added
  -- rollingMean adds a smoothed column by averaging over a sliding window.
  local df = lurek.dataframe.newDataFrame()
  df:addColumn("ms", 0)
  for _, v in ipairs({16, 17, 33, 16, 15, 16}) do df:addRow({ms=v}) end
  local smoothed = df:rollingMean("ms", 3)
  lurek.log.info("rolling mean cols: " .. smoothed:ncols())
end
```

---

### `LDataFrame:rollingSum`

Returns a dataframe with a rolling sum column.

```lua
-- signature
LDataFrame:rollingSum(col, window, result_col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name string or one-based column index. |
| `window` | `number` | Rolling window size. |
| `result_col?` | `string` | Output column name; defaults to `rolling_sum`. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | New dataframe with the rolling sum column. |

**Example**

```lua
do
-- Returns a new dataframe with a rolling sum column added
  -- rollingSum adds a windowed cumulative total column.
  local df = lurek.dataframe.newDataFrame()
  df:addColumn("dmg", 0)
  for _, v in ipairs({10, 20, 15, 30, 5}) do df:addRow({dmg=v}) end
  local windowed = df:rollingSum("dmg", 3)
  lurek.log.info("rolling sum cols: " .. windowed:ncols())
end
```

---

### `LDataFrame:rows`

Returns an iterator function over one-based row index and row table pairs.

```lua
-- signature
LDataFrame:rows()
```

**Returns**

| Type | Description |
|------|-------------|
| `function` | Iterator function for Lua generic-for loops. |

**Example**

```lua
do
-- Returns an iterator for use in for-loops (index, row_table)
  -- rows() returns a generic-for iterator yielding (index, row_table).
  local df = lurek.dataframe.fromTable({{name="Alice"},{name="Bob"}})
  for i, row in df:rows() do
    lurek.log.info("#" .. i .. " " .. row.name)
  end
end
```

---

### `LDataFrame:sample`

Returns a sampled dataframe. This method is available to Lua scripts.

```lua
-- signature
LDataFrame:sample(n, seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | `number` | Number of rows to sample. |
| `seed?` | `number` | Optional random seed. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | New sampled dataframe. |

**Example**

```lua
do
-- Returns a random subset of N rows (optional seed for reproducibility)
  -- sample picks N random rows without replacement; seed for reproducibility.
  local src = lurek.dataframe.random({{"id","id"}}, 100, 1)
  local subset = src:sample(10, 42)
  lurek.log.info("sampled rows: " .. subset:nrows())
end
```

---

### `LDataFrame:select`

Returns a dataframe with selected columns.

```lua
-- signature
LDataFrame:select(...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| — | — | @param ... any Column name strings or one-based column indices to keep. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | New dataframe containing selected columns. |

**Example**

```lua
do
-- Returns a dataframe with selected columns.
  -- select returns a new frame with only the specified columns.
  local df = lurek.dataframe.fromTable({{name="Alice",score=950,guild="Knights"}})
  local view = df:select("name", "score")
  lurek.log.info("selected cols: " .. view:ncols())
end
```

---

### `LDataFrame:setColumnFromF64`

Replaces a numeric column from an array table of numbers.

```lua
-- signature
LDataFrame:setColumnFromF64(col, values)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name string or one-based column index. |
| `values` | `table` | Array table of numeric values. |

**Example**

```lua
do
-- Replaces a numeric column's values from an array of numbers
  -- setColumnFromF64 bulk-writes computed numbers back into a column.
  local df = lurek.dataframe.fromTable({{x=0},{x=0},{x=0}})
  df:setColumnFromF64("x", {1.5, 2.5, 3.5})
  lurek.log.info("sum x: " .. df:sum("x"))
end
```

---

### `LDataFrame:setValue`

Sets one cell value by one-based row and column reference.

```lua
-- signature
LDataFrame:setValue(row, col, val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `row` | `number` | One-based row index. |
| `col` | `any` | Column name string or one-based column index. |
| `val` | `any` | Cell value to store. |

**Example**

```lua
do
-- Sets one cell value by row index and column reference
  -- setValue updates one cell by 1-based row index and column name.
  local df = lurek.dataframe.fromTable({{player="Alice",score=50}})
  df:setValue(1, "score", 150)
  lurek.log.info("updated score: " .. df:getValue(1, "score"))
end
```

---

### `LDataFrame:slice`

Returns a one-based inclusive row slice.

```lua
-- signature
LDataFrame:slice(start, end_)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `start` | `number` | One-based start row. |
| `end_` | `number` | One-based end row. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | New dataframe containing the row slice. |

**Example**

```lua
do
-- Returns a one-based inclusive row slice.
  -- slice returns a 1-based inclusive row range as a new frame.
  local df = lurek.dataframe.fromTable({{r="Sword"},{r="Shield"},{r="Bow"},{r="Staff"},{r="Helm"},{r="Boots"}})
  local page2 = df:slice(4, 6)
  lurek.log.info("page 2 rows: " .. page2:nrows())
end
```

---

### `LDataFrame:sort`

Returns rows sorted by a column. This method is available to Lua scripts.

```lua
-- signature
LDataFrame:sort(col, ascending)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `any` | Column name string or one-based column index. |
| `ascending?` | `boolean` | True for ascending order; defaults to true. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | New sorted dataframe. |

**Example**

```lua
do
-- Returns rows sorted by a column. This method is available to Lua scripts.
  -- sort returns a new frame with rows ordered by the named column.
  local df = lurek.dataframe.fromTable({{name="Alice",score=950},{name="Bob",score=1200}})
  local sorted = df:sort("score", false)
  lurek.log.info("top scorer: " .. sorted:getValue(1, "name"))
end
```

---

### `LDataFrame:stddev`

Returns the numeric standard deviation of a column.

```lua
-- signature
LDataFrame:stddev(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `any` | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Column standard deviation. |

**Example**

```lua
do
-- Returns the standard deviation of a numeric column
  -- stddev measures the spread of values in a numeric column.
  local df = lurek.dataframe.fromTable({{v=10},{v=20},{v=30},{v=40}})
  lurek.log.info("stddev: " .. string.format("%.1f", df:stddev("v")))
end
```

---

### `LDataFrame:sum`

Returns the numeric sum of a column.

```lua
-- signature
LDataFrame:sum(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `any` | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Column sum. |

**Example**

```lua
do
-- Returns the numeric sum of a column
  -- sum totals all values in a numeric column.
  local df = lurek.dataframe.fromTable({{dmg=10},{dmg=20},{dmg=5}})
  lurek.log.info("total damage: " .. df:sum("dmg"))
end
```

---

### `LDataFrame:tail`

Returns the last rows of this dataframe.

```lua
-- signature
LDataFrame:tail(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n?` | `number` | Number of rows to return; defaults to 5. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | New dataframe containing the last rows. |

**Example**

```lua
do
-- Returns the last rows of this dataframe.
  -- tail returns a new frame containing only the last N rows.
  local df = lurek.dataframe.fromTable({{turn=1},{turn=2},{turn=3},{turn=4}})
  local recent = df:tail(2)
  lurek.log.info("recent rows: " .. recent:nrows())
end
```

---

### `LDataFrame:toBinary`

Serializes this dataframe to binary data.

```lua
-- signature
LDataFrame:toBinary()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Binary string containing serialized dataframe data. |

**Example**

```lua
do
-- Serializes this dataframe to a compact binary format
  -- toBinary produces the most compact serialisation format.
  local df = lurek.dataframe.fromTable({{x=1.5,y=2.3}})
  local blob = df:toBinary()
  lurek.log.info("binary bytes: " .. #blob)
end
```

---

### `LDataFrame:toBinaryFile`

Serializes this dataframe to LVDF binary data and writes it through GameFS.

```lua
-- signature
LDataFrame:toBinaryFile(path, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | GameFS save path to write, usually under `save/`. |
| `opts?` | `table` | Optional file options table; reserved for future binary options. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the file was written. |

**Example**

```lua
do
  local df = lurek.dataframe.fromTable({
    {level = 42},
    {level = 43},
  })
  local ok = df:toBinaryFile("save/output.lvdf")
  print("binary saved", ok)
  print("binary bytes", #df:toBinary())
end
```

---

### `LDataFrame:toCSV`

Serializes this dataframe to CSV text.

```lua
-- signature
LDataFrame:toCSV()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | CSV text. |

**Example**

```lua
do
-- Serializes this dataframe to CSV text
  -- toCSV serialises the frame to CSV text with a header row.
  local df = lurek.dataframe.fromTable({{name="Alice",score=100}})
  local csv = df:toCSV()
  lurek.log.info("CSV bytes: " .. #csv)
end
```

---

### `LDataFrame:toCSVFile`

Serializes this dataframe to CSV text and writes it through GameFS.

```lua
-- signature
LDataFrame:toCSVFile(path, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | GameFS save path to write, usually under `save/`. |
| `opts?` | `table` | Optional file options table; reserved for future CSV options. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the file was written. |

**Example**

```lua
do
  local df = lurek.dataframe.fromTable({
    {score = 500},
    {score = 725},
  })
  local ok = df:toCSVFile("save/output.csv")
  print("csv saved", ok)
  print("csv preview", df:toCSV())
end
```

---

### `LDataFrame:toJSON`

Serializes this dataframe to JSON text.

```lua
-- signature
LDataFrame:toJSON()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | JSON text. |

**Example**

```lua
do
-- Serializes this dataframe to JSON text.
  -- toJSON serialises the frame to a JSON array-of-objects string.
  local df = lurek.dataframe.fromTable({{stat="playtime",value=3600}})
  local json = df:toJSON()
  lurek.log.info("JSON length: " .. #json)
end
```

---

### `LDataFrame:toJSONFile`

Serializes this dataframe to JSON text and writes it through GameFS.

```lua
-- signature
LDataFrame:toJSONFile(path, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | GameFS save path to write, usually under `save/`. |
| `opts?` | `table` | Optional file options table; reserved for future JSON options. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the file was written. |

**Example**

```lua
do
  local df = lurek.dataframe.fromTable({
    {name = "Alice"},
    {name = "Bob"},
  })
  local ok = df:toJSONFile("save/output.json")
  print("json saved", ok)
  print("json preview", df:toJSON())
end
```

---

### `LDataFrame:toString`

Formats this dataframe as a human-readable text table.

```lua
-- signature
LDataFrame:toString()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Text table representation. |

**Example**

```lua
do
-- Formats this dataframe as a human-readable aligned text table
  -- toString formats the frame as an aligned text table for debug output.
  local df = lurek.dataframe.fromTable({{name="Alice",hp=80}})
  lurek.log.info("frame:\n" .. df:toString())
end
```

---

### `LDataFrame:toTable`

Converts this dataframe to an array table of row tables.

```lua
-- signature
LDataFrame:toTable()
```

**Returns**

| Type | Description |
|------|-------------|
| `table` | Array of rows keyed by column name. |

**Example**

```lua
do
-- Converts this dataframe to a plain Lua array of row tables
  -- toTable converts the frame back to a plain Lua array-of-row-tables.
  local df = lurek.dataframe.fromTable({{name="Alice",hp=80}})
  local rows = df:toTable()
  lurek.log.info("first row name: " .. rows[1].name)
end
```

---

### `LDataFrame:type`

Returns the Lua-visible type name for this dataframe handle.

```lua
-- signature
LDataFrame:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LDataFrame`. |

**Example**

```lua
do
  local df = lurek.dataframe.newDataFrame()
  if df:type() == "LDataFrame" then
    print("confirmed dataframe handle")
  end
end
```

---

### `LDataFrame:typeOf`

Returns whether this dataframe handle matches a supported type name.

```lua
-- signature
LDataFrame:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LDataFrame`, `DataFrame`, and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
  local df = lurek.dataframe.newDataFrame()
  if df:typeOf("LObject") then
    print("dataframe is object")
  end
end
```

---

### `LDataFrame:unique`

Returns unique values from a column.

```lua
-- signature
LDataFrame:unique(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `any` | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Array table of unique values. |

**Example**

```lua
do
-- Returns unique values from a column as an array table
  -- unique returns the distinct values of one column as a Lua array.
  local df = lurek.dataframe.fromTable({{cls="warrior"},{cls="mage"},{cls="warrior"}})
  local types = df:unique("cls")
  lurek.log.info("distinct classes: " .. #types)
end
```

---

### `LDataFrame:valueCounts`

Counts occurrences of each value in a column with optional percentage output.

```lua
-- signature
LDataFrame:valueCounts(col, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `any` | Column name string or one-based column index. |
| `opts?` | `table` | Optional options table; set `percent = true` to include percentage values from 0 to 100. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | New dataframe containing `value`, `count`, and optional `percent` columns. |

**Example**

```lua
do
  local df = lurek.dataframe.fromTable({
    {class = "Warrior"},
    {class = "Mage"},
    {class = "Warrior"},
  })
  local counts = df:valueCounts("class")
  print("value counts rows", counts:nrows())
  print(counts:toString())
end
```

---

### `LDataFrame:variance`

Returns the numeric variance of a column.

```lua
-- signature
LDataFrame:variance(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `any` | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Column variance. |

**Example**

```lua
do
-- Returns the variance of a numeric column
  -- variance is stddev squared; used in statistical formulas.
  local df = lurek.dataframe.fromTable({{v=10},{v=20},{v=30}})
  lurek.log.info("variance: " .. df:variance("v"))
end
```

---

### `LDataFrame:withCumsum`

Adds a cumulative-sum column in place.

```lua
-- signature
LDataFrame:withCumsum(col, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name string or one-based column index. |
| `name` | `string` | Output column name. |

**Example**

```lua
do
-- Adds a cumulative sum column (running total) in-place
  -- withCumsum adds a running-total column derived from an existing column.
  local df = lurek.dataframe.newDataFrame()
  df:addColumn("xp", 0)
  for _, v in ipairs({100, 50, 200, 75}) do df:addRow({xp=v}) end
  df:withCumsum("xp", "total_xp")
  lurek.log.info("cumsum col added: " .. df:ncols() .. " cols")
end
```

---

### `LDataFrame:withEval`

Returns a dataframe with a column computed from an expression.

```lua
-- signature
LDataFrame:withEval(col_name, expr)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col_name` | `string` | Output column name. |
| `expr` | `string` | Dataframe expression evaluated by the dataframe module. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | New dataframe with the evaluated column. |

**Example**

```lua
do
-- Returns a new dataframe with an added column computed from an expression
  -- withEval adds a derived column computed row-by-row from an expression.
  local df = lurek.dataframe.fromTable({{atk=10,bonus=4},{atk=15,bonus=2}})
  local result = df:withEval("eff", "atk + bonus")
  lurek.log.info("eff[1]: " .. result:getValue(1, "eff"))
end
```

---

### `LDataFrame:withPctChange`

Adds a percent-change column in place.

```lua
-- signature
LDataFrame:withPctChange(col, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name string or one-based column index. |
| `name` | `string` | Output column name. |

**Example**

```lua
do
-- Adds a percent-change column (row-over-row change rate) in-place
  -- withPctChange adds a row-over-row percent-change column.
  local df = lurek.dataframe.newDataFrame()
  df:addColumn("price", 0)
  for _, v in ipairs({100, 110, 121, 133}) do df:addRow({price=v}) end
  df:withPctChange("price", "pct")
  lurek.log.info("pct col added: " .. df:ncols() .. " cols")
end
```

---

### `LDataFrame:withRank`

Adds a rank column in place. This method is available to Lua scripts.

```lua
-- signature
LDataFrame:withRank(col, asc, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name string or one-based column index. |
| `asc?` | `boolean` | True for ascending rank; defaults to true. |
| `name` | `string` | Output column name. |

**Example**

```lua
do
-- Adds a rank column in-place based on a source column
  -- withRank adds a rank column in-place without creating a new frame.
  local df = lurek.dataframe.fromTable({{player="Alice",pts=10},{player="Bob",pts=30},{player="Cara",pts=20}})
  df:withRank("pts", true, "rank")
  lurek.log.info("rank col added: " .. df:ncols() .. " cols")
end
```

---

### `LDataFrame:withRollingMax`

Adds a rolling maximum column in place.

```lua
-- signature
LDataFrame:withRollingMax(col, window, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name string or one-based column index. |
| `window` | `number` | Rolling window size. |
| `name` | `string` | Output column name. |

**Example**

```lua
do
-- Adds a rolling maximum column in-place
  -- withRollingMax adds a sliding-window maximum column in-place.
  local df = lurek.dataframe.newDataFrame()
  df:addColumn("v", 0)
  for _, v in ipairs({3,1,4,1,5,9,2,6}) do df:addRow({v=v}) end
  df:withRollingMax("v", 3, "peak")
  lurek.log.info("rolling max col added")
end
```

---

### `LDataFrame:withRollingMean`

Adds a rolling mean column in place.

```lua
-- signature
LDataFrame:withRollingMean(col, window, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name string or one-based column index. |
| `window` | `number` | Rolling window size. |
| `name` | `string` | Output column name. |

**Example**

```lua
do
-- Adds a rolling mean column in-place
  -- withRollingMean adds a rolling average column in-place.
  local df = lurek.dataframe.newDataFrame()
  df:addColumn("temp", 0)
  for i = 1, 5 do df:addRow({temp=20+i}) end
  df:withRollingMean("temp", 3, "smooth")
  lurek.log.info("rolling mean col added")
end
```

---

### `LDataFrame:withRollingMin`

Adds a rolling minimum column in place.

```lua
-- signature
LDataFrame:withRollingMin(col, window, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name string or one-based column index. |
| `window` | `number` | Rolling window size. |
| `name` | `string` | Output column name. |

**Example**

```lua
do
-- Adds a rolling minimum column in-place
  -- withRollingMin adds a sliding-window minimum column in-place.
  local df = lurek.dataframe.newDataFrame()
  df:addColumn("hp", 0)
  for _, v in ipairs({5,3,8,2,7,1}) do df:addRow({hp=v}) end
  df:withRollingMin("hp", 3, "floor")
  lurek.log.info("rolling min col added")
end
```

---

### `LDataFrame:withRollingSum`

Adds a rolling sum column in place. This method is available to Lua scripts.

```lua
-- signature
LDataFrame:withRollingSum(col, window, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name string or one-based column index. |
| `window` | `number` | Rolling window size. |
| `name` | `string` | Output column name. |

**Example**

```lua
do
-- Adds a rolling sum column in-place
  -- withRollingSum adds a windowed rolling-total column in-place.
  local df = lurek.dataframe.newDataFrame()
  df:addColumn("sales", 0)
  for i = 1, 5 do df:addRow({sales=i*10}) end
  df:withRollingSum("sales", 3, "s3")
  lurek.log.info("rolling sum col added")
end
```

---

### `LDataFrame:zscoreCol`

Adds a z-score normalized column in place.

```lua
-- signature
LDataFrame:zscoreCol(col, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name string or one-based column index. |
| `name` | `string` | Output column name. |

**Example**

```lua
do
-- Adds a z-score normalized column in-place
  -- zscoreCol standardises values to z-scores: (value - mean) / stddev.
  local df = lurek.dataframe.newDataFrame()
  df:addColumn("stat", 0)
  for i = 1, 6 do df:addRow({stat=i*5}) end
  df:zscoreCol("stat", "stat_z")
  lurek.log.info("z-score col added: " .. df:ncols() .. " cols")
end
```

---

## LDataFrameTask

### `LDataFrameTask:getError`

Returns the task error message after failure.

```lua
-- signature
LDataFrameTask:getError()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | a Error message after failure. |
| `nil` | b If the task is pending or succeeded. |

**Example**

```lua
do
  local task = lurek.dataframe.fromCSVFileAsync("invalid/path/missing.csv")
  task:wait()
  print("task error", task:getError())
end
```

---

### `LDataFrameTask:isDone`

Returns whether this dataframe task has completed with success or failure.

```lua
-- signature
LDataFrameTask:isDone()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True once the worker has produced a result or error. |

**Example**

```lua
do
  local path = "save/dataframe_task_status.csv"
  local source = lurek.dataframe.fromRows({ "name", "score" }, { { "Alice", 10 }, { "Bob", 20 } })
  source:toCSVFile(path)
  local task = lurek.dataframe.fromCSVFileAsync(path)
  print("done before wait", task:isDone())
  task:wait()
  print("done after wait", task:isDone())
end
```

---

### `LDataFrameTask:progress`

Returns a coarse task progress estimate.

```lua
-- signature
LDataFrameTask:progress()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Progress from 0.0 to 1.0. |

**Example**

```lua
do
  local path = "save/dataframe_task_progress.csv"
  local source = lurek.dataframe.fromRows({ "name", "score" }, { { "Alice", 10 }, { "Bob", 20 } })
  source:toCSVFile(path)
  local task = lurek.dataframe.fromCSVFileAsync(path)
  print("initial progress", task:progress())
  task:wait()
  print("final progress", task:progress())
end
```

---

### `LDataFrameTask:result`

Returns the completed dataframe result.

```lua
-- signature
LDataFrameTask:result()
```

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | Completed dataframe result. |

**Example**

```lua
do
  local df = lurek.dataframe.fromRows({ "id" }, { { 1 }, { 2 } })
  local task = df:queryAsync("SELECT * FROM t WHERE id = 1")
  task:wait()
  local result_df = task:result()
  print("result rows", result_df:nrows())
  print(result_df:toString())
end
```

---

### `LDataFrameTask:type`

Returns the Lua-visible type name for this dataframe task handle.

```lua
-- signature
LDataFrameTask:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LDataFrameTask`. |

**Example**

```lua
do
  local df = lurek.dataframe.fromRows({ "id" }, { { 1 }, { 2 } })
  local task = df:queryAsync("SELECT * FROM t WHERE id = 1")
  local type_name = task:type()
  print("task type", type_name)
  if type_name == "LDataFrameTask" then
    print("This is indeed a DataFrameTask")
  end
  task:wait()
end
```

---

### `LDataFrameTask:typeOf`

Returns whether this dataframe task handle matches a supported type name.

```lua
-- signature
LDataFrameTask:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LDataFrameTask`, `DataFrameTask`, and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
  local df = lurek.dataframe.fromRows({ "id" }, { { 1 }, { 2 } })
  local task = df:queryAsync("SELECT * FROM t WHERE id = 1")
  local is_task = task:typeOf("LDataFrameTask")
  print("is dataframe task", is_task)
  if is_task then
    print("Object is verified as DataFrameTask")
  end
  task:wait()
end
```

---

### `LDataFrameTask:wait`

Blocks until this dataframe task completes.

```lua
-- signature
LDataFrameTask:wait()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the task completed successfully; false when it completed with an error. |

**Example**

```lua
do
  local path = "save/dataframe_task_wait.json"
  local source = lurek.dataframe.fromRows({ "name", "score" }, { { "Alice", 10 }, { "Bob", 20 } })
  source:toJSONFile(path)
  local task = lurek.dataframe.fromJSONFileAsync(path)
  print("waiting for task")
  task:wait()
  print("task error", task:getError())
end
```

---

## LDatabase

### `LDatabase:addTable`

Adds or replaces a named dataframe table in the database.

```lua
-- signature
LDatabase:addTable(name, df_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Table name. |
| `df_ud` | `LDataFrame` | Dataframe handle copied into the database. |

**Example**

```lua
do
  -- A Database groups related dataframes under string keys.
  -- Use it to organize game data: one table for players, one for items, one for quests, etc.
  local db = lurek.dataframe.newDatabase()

  local players = lurek.dataframe.fromTable({{id = 1, name = "Alice", level = 12}})
  local items = lurek.dataframe.fromTable({{id = 1, name = "Iron Sword", dmg = 15}})

  -- Register tables by name for later retrieval or SQL-style cross-table queries
  db:addTable("players", players)
  db:addTable("items", items)

  lurek.log.info("database has " .. db:tableCount() .. " tables")
end
```

---

### `LDatabase:clear`

Removes every table from the database.

```lua
-- signature
LDatabase:clear()
```

**Example**

```lua
do
-- Removes all tables from this database
  -- clear removes all tables, resetting the database to empty.
  local db = lurek.dataframe.newDatabase()
  db:addTable("round1", lurek.dataframe.newDataFrame())
  db:clear()
  lurek.log.info("tables after clear: " .. db:tableCount())
end
```

---

### `LDatabase:getTable`

Returns a copy of a named table when it exists.

```lua
-- signature
LDatabase:getTable(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Table name to retrieve. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | Dataframe handle, or nil when no table has that name. |

**Example**

```lua
do
-- Returns a copy of a named table from the database (or nil if not found)
  -- getTable retrieves a named dataframe from the database (nil if absent).
  local db = lurek.dataframe.newDatabase()
  db:addTable("players", lurek.dataframe.fromTable({{name="Alice"}}))
  local t = db:getTable("players")
  if t then lurek.log.info("players rows: " .. t:nrows()) end
end
```

---

### `LDatabase:hasTable`

Returns whether a named table exists.

```lua
-- signature
LDatabase:hasTable(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Table name to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the table exists. |

**Example**

```lua
do
-- Returns true if the database contains a table with the given name
  -- hasTable returns true when the named table is registered.
  local db = lurek.dataframe.newDatabase()
  db:addTable("scores", lurek.dataframe.newDataFrame())
  lurek.log.info("has scores: " .. tostring(db:hasTable("scores")))
end
```

---

### `LDatabase:listTables`

Returns all table names in the database.

```lua
-- signature
LDatabase:listTables()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Table names. |

**Example**

```lua
do
-- Returns an array of all table names in the database
  -- listTables returns all registered table names as a Lua array.
  local db = lurek.dataframe.newDatabase()
  db:addTable("players", lurek.dataframe.newDataFrame())
  db:addTable("items", lurek.dataframe.newDataFrame())
  lurek.log.info("tables: " .. table.concat(db:listTables(), ", "))
end
```

---

### `LDatabase:merge`

Merges another database into this database.

```lua
-- signature
LDatabase:merge(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | `LDatabase` | Database copied into this database. |

**Example**

```lua
do
-- Merges all tables from another database into this one
  -- merge imports all tables from another database (overwriting on name collision).
  local base = lurek.dataframe.newDatabase()
  base:addTable("weapons", lurek.dataframe.fromTable({{name="sword"}}))
  local mod = lurek.dataframe.newDatabase()
  mod:addTable("spells", lurek.dataframe.fromTable({{name="fireball"}}))
  base:merge(mod)
  lurek.log.info("after merge: " .. base:tableCount() .. " tables")
end
```

---

### `LDatabase:query`

Runs a SQL-style query against the database tables.

```lua
-- signature
LDatabase:query(sql_str)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sql_str` | `string` | SQL query text. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | Query result dataframe. |

**Example**

```lua
do
-- Runs a SQL SELECT query against this dataframe (table alias is "t")
  -- query on a Database runs SQL that can reference all registered tables.
  local db = lurek.dataframe.newDatabase()
  db:addTable("players", lurek.dataframe.fromTable({{name="Alice",hp=80},{name="Bob",hp=20}}))
  local result = db:query("SELECT name FROM players WHERE hp < 50")
  lurek.log.info("low-hp players: " .. result:nrows())
end
```

---

### `LDatabase:queryAsync`

Runs a SQL-style query against a snapshot of the database tables on a Rust worker thread.

```lua
-- signature
LDatabase:queryAsync(sql_str)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sql_str` | `string` | SQL query text. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrameTask` | Task that resolves to the query result dataframe. |

**Example**

```lua
do
  local db = lurek.dataframe.newDatabase()
  local users = lurek.dataframe.fromRows({ "age" }, { { 25 }, { 30 } })
  db:addTable("users", users)
  local task = db:queryAsync("SELECT * FROM users WHERE age > 26")
  print("database query task", task:type())
  task:wait()
  local result_df = task:result()
  print("Async query finished, resulting rows: " .. result_df:nrows())
end
```

---

### `LDatabase:queryParams`

Runs a SQL-style query against the database tables with positional parameters.

```lua
-- signature
LDatabase:queryParams(sql_str, params)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sql_str` | `string` | SQL query text using `?` placeholders outside string literals. |
| `params` | `table` | Array table of positional parameter values; nil maps to SQL NULL, strings are escaped, and booleans/numbers are bound as literals. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | Query result dataframe. |

**Example**

```lua
do
  local db = lurek.dataframe.newDatabase()
  local users = lurek.dataframe.fromRows({ "name" }, { { "Alice" }, { "Bob" } })
  db:addTable("users", users)
  local result = db:queryParams("SELECT * FROM users WHERE name = ?", {"Alice"})
  print("query params rows", result:nrows())
  print(result:toString())
end
```

---

### `LDatabase:queryParamsAsync`

Runs a parameterized SQL query against a snapshot of the database tables on a Rust worker thread.

```lua
-- signature
LDatabase:queryParamsAsync(sql_str, params)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sql_str` | `string` | SQL query text using `?` placeholders outside string literals. |
| `params` | `table` | Array table of positional parameter values; nil maps to SQL NULL, strings are escaped, and booleans/numbers are bound as literals. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrameTask` | Task that resolves to the query result dataframe. |

**Example**

```lua
do
  local db = lurek.dataframe.newDatabase()
  local players = lurek.dataframe.fromRows({ "level" }, { { 10 }, { 20 } })
  db:addTable("players", players)
  local task = db:queryParamsAsync("SELECT * FROM players WHERE level > ?", {15})
  task:wait()
  local result = task:result()
  print("async param rows", result:nrows())
  print(result:toString())
end
```

---

### `LDatabase:removeTable`

Removes a named table from the database.

```lua
-- signature
LDatabase:removeTable(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Table name to remove. |

**Example**

```lua
do
-- Removes a named table from the database
  -- removeTable deletes a named table; useful for session cleanup.
  local db = lurek.dataframe.newDatabase()
  db:addTable("temp", lurek.dataframe.newDataFrame())
  db:removeTable("temp")
  lurek.log.info("tables after remove: " .. db:tableCount())
end
```

---

### `LDatabase:save`

Serializes the database to the JSON database file format and writes it through GameFS.

```lua
-- signature
LDatabase:save(path, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | GameFS save path to write, usually under `save/`. |
| `opts?` | `table` | Optional options table; `format = "json"` is the only supported format. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the file was written. |

**Example**

```lua
do
  local db = lurek.dataframe.newDatabase()
  local df = lurek.dataframe.fromTable({
    {score = 100},
  })
  db:addTable("savegame_stats", df)
  local success = db:save("save/savegame_stats.json")
  print("database saved", success)
end
```

---

### `LDatabase:tableCount`

Returns the number of tables in the database.

```lua
-- signature
LDatabase:tableCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Table count. |

**Example**

```lua
do
-- Returns the number of tables in this database
  -- tableCount returns the number of tables registered in this database.
  local db = lurek.dataframe.newDatabase()
  db:addTable("a", lurek.dataframe.newDataFrame())
  db:addTable("b", lurek.dataframe.newDataFrame())
  lurek.log.info("table count: " .. db:tableCount())
end
```

---

### `LDatabase:toJSON`

Serializes the database to JSON text.

```lua
-- signature
LDatabase:toJSON()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | JSON text. |

**Example**

```lua
do
-- Serializes this dataframe to a JSON array of objects
  -- toJSON on a Database serialises all its tables to a JSON string.
  local db = lurek.dataframe.newDatabase()
  db:addTable("scores", lurek.dataframe.fromTable({{v=1}}))
  local json = db:toJSON()
  lurek.log.info("database JSON bytes: " .. #json)
end
```

---

### `LDatabase:type`

Returns the Lua-visible type name for this database handle.

```lua
-- signature
LDatabase:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LDatabase`. |

**Example**

```lua
do
-- Returns the Lua-visible type name for this database handle.
  local db = lurek.dataframe.newDatabase()
  print("db type", db:type())
end
```

---

### `LDatabase:typeOf`

Returns whether this database handle matches a supported type name.

```lua
-- signature
LDatabase:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LDatabase`, `Database`, and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
-- Returns whether this database handle matches a supported type name.
  local db = lurek.dataframe.newDatabase()
  print("is database", db:typeOf("LDatabase"))
  print("is object", db:typeOf("LObject"))
end
```

---

## LGroupedFrame

### `LGroupedFrame:aggregate`

Aggregates one numeric column in every group by calling a Lua function with that group's numeric values.

```lua
-- signature
LGroupedFrame:aggregate(col_name, func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col_name` | `string` | Column name to aggregate in each group. |
| `func` | `function` | Function called with an array table of numeric values and returning a number. |

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | DataFrame containing `group_key` and the aggregated column. |

**Example**

```lua
do
-- Aggregates a column in each group using a custom Lua function
  local df = lurek.dataframe.fromTable({
    {class="warrior",dmg=12},{class="mage",dmg=8},{class="warrior",dmg=20}
  })
  local grouped = df:groupByObj("class")
  local result = grouped:aggregate("dmg", function(vals)
    local sum = 0
    for _, value in ipairs(vals) do
      sum = sum + value
    end
    return sum / #vals
  end)
  print("aggregate rows", result:nrows())
  print(result:toString())
end
```

---

### `LGroupedFrame:type`

Returns the Lua-visible type name for this grouped frame handle.

```lua
-- signature
LGroupedFrame:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LGroupedFrame`. |

**Example**

```lua
do
-- Returns the Lua-visible type name for this grouped frame handle.
  local df = lurek.dataframe.fromTable({{team="red",score=10},{team="blue",score=20}})
  local grouped = df:groupByObj("team")
  print("grouped type", grouped:type())
end
```

---

### `LGroupedFrame:typeOf`

Returns whether this grouped frame handle matches a supported type name.

```lua
-- signature
LGroupedFrame:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LGroupedFrame` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
-- Returns whether this grouped frame handle matches a supported type name.
  local df = lurek.dataframe.fromTable({{team="red",score=10},{team="blue",score=20}})
  local grouped = df:groupByObj("team")
  print("is grouped frame", grouped:typeOf("LGroupedFrame"))
  print("is object", grouped:typeOf("LObject"))
end
```

---

## LLazyQuery

### `LLazyQuery:collect`

Executes the lazy query and returns a dataframe.

```lua
-- signature
LLazyQuery:collect()
```

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | Dataframe produced by the query plan. |

**Example**

```lua
do
-- Executes the lazy query and returns a dataframe.
  local df = lurek.dataframe.fromTable({{item="Sword",gold=150},{item="Stick",gold=5}})
  local result = df:lazy():limit(10):collect()
  print("collected rows", result:nrows())
  print(result:toString())
end
```

---

### `LLazyQuery:dropNil`

Adds a step that drops rows with nil values in a column.

```lua
-- signature
LLazyQuery:dropNil(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name to test for nil values. |

**Returns**

| Type | Description |
|------|-------------|
| `LLazyQuery` | New lazy query handle with the drop-nil step. |

**Example**

```lua
do
-- Returns a new dataframe with rows where a column is nil removed
  -- dropNil on a lazy query filters out rows where the column is nil.
  local df = lurek.dataframe.fromTable({{v=1},{v=nil},{v=3}})
  local result = df:lazy():dropNil("v"):collect()
  lurek.log.info("rows after dropNil: " .. result:nrows())
end
```

---

### `LLazyQuery:filter`

Adds a filter step to the lazy query.

```lua
-- signature
LLazyQuery:filter(col, op, val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name to filter. |
| `op` | `string` | Comparison operator string. |
| `val` | `any` | Filter comparison value. |

**Returns**

| Type | Description |
|------|-------------|
| `LLazyQuery` | New lazy query handle with the filter step. |

**Example**

```lua
do
-- Returns a new dataframe with rows matching a condition (col op val)
  -- filter on a lazy query keeps only rows where the column matches the condition.
  local df = lurek.dataframe.fromTable({{level=5},{level=20},{level=35}})
  local result = df:lazy():filter("level", ">=", 15):collect()
  lurek.log.info("high-level rows: " .. result:nrows())
end
```

---

### `LLazyQuery:head`

Adds a head limit step to the lazy query.

```lua
-- signature
LLazyQuery:head(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | `number` | Number of leading rows to keep. |

**Returns**

| Type | Description |
|------|-------------|
| `LLazyQuery` | New lazy query handle with the head step. |

**Example**

```lua
do
-- Returns a new dataframe with the first N rows (default 5)
  -- head on a lazy query limits to the first N rows at collect time.
  local df = lurek.dataframe.fromTable({{n=1},{n=2},{n=3},{n=4},{n=5}})
  local result = df:lazy():head(3):collect()
  lurek.log.info("head rows: " .. result:nrows())
end
```

---

### `LLazyQuery:limit`

Adds a row limit step to the lazy query.

```lua
-- signature
LLazyQuery:limit(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | `number` | Maximum number of rows to keep. |

**Returns**

| Type | Description |
|------|-------------|
| `LLazyQuery` | New lazy query handle with the limit step. |

**Example**

```lua
do
-- Adds a row limit step to the lazy query.
  local df = lurek.dataframe.fromTable({{n=1},{n=2},{n=3},{n=4},{n=5},{n=6}})
  local q = df:lazy():limit(5)
  local result = q:collect()
  print("rows after limit", result:nrows())
  print(result:toString())
end
```

---

### `LLazyQuery:select`

Adds a column selection step to the lazy query.

```lua
-- signature
LLazyQuery:select(cols)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cols` | `table` | Array table of column names to keep. |

**Returns**

| Type | Description |
|------|-------------|
| `LLazyQuery` | New lazy query handle with the select step. |

**Example**

```lua
do
-- Returns a new dataframe with only the specified columns
  -- select on a lazy query projects only the specified columns.
  local df = lurek.dataframe.fromTable({{a=1, b=2, c=3}})
  local result = df:lazy():select({"a", "b"}):collect()
  lurek.log.info("selected cols: " .. result:ncols())
end
```

---

### `LLazyQuery:slice`

Adds a one-based row slice step to the lazy query.

```lua
-- signature
LLazyQuery:slice(start, end_)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `start` | `number` | One-based start row. |
| `end_` | `number` | One-based end row. |

**Returns**

| Type | Description |
|------|-------------|
| `LLazyQuery` | New lazy query handle with the slice step. |

**Example**

```lua
do
-- Returns a one-based inclusive row slice as a new dataframe
  -- slice on a lazy query extracts a 1-based inclusive row range.
  local df = lurek.dataframe.fromTable({{n=1},{n=2},{n=3},{n=4},{n=5}})
  local result = df:lazy():slice(2, 4):collect()
  lurek.log.info("sliced rows: " .. result:nrows())
end
```

---

### `LLazyQuery:sort`

Adds a sort step to the lazy query. This method is available to Lua scripts.

```lua
-- signature
LLazyQuery:sort(col, ascending)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name to sort by. |
| `ascending?` | `boolean` | True for ascending order; defaults to true. |

**Returns**

| Type | Description |
|------|-------------|
| `LLazyQuery` | New lazy query handle with the sort step. |

**Example**

```lua
do
-- Returns a new sorted dataframe by column (ascending or descending)
  -- sort on a lazy query orders rows by a column before collect.
  local df = lurek.dataframe.fromTable({{name="Cara",score=80},{name="Alice",score=95},{name="Bob",score=60}})
  local top = df:lazy():sort("score", false):collect()
  lurek.log.info("1st place: " .. top:getValue(1, "name"))
end
```

---

### `LLazyQuery:tail`

Adds a tail limit step to the lazy query.

```lua
-- signature
LLazyQuery:tail(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | `number` | Number of trailing rows to keep. |

**Returns**

| Type | Description |
|------|-------------|
| `LLazyQuery` | New lazy query handle with the tail step. |

**Example**

```lua
do
-- Returns a new dataframe with the last N rows (default 5)
  -- tail on a lazy query keeps only the last N rows.
  local df = lurek.dataframe.fromTable({{n=1},{n=2},{n=3},{n=4},{n=5}})
  local result = df:lazy():tail(2):collect()
  lurek.log.info("tail rows: " .. result:nrows())
end
```

---

### `LLazyQuery:type`

Returns the Lua-visible type name for this lazy query handle.

```lua
-- signature
LLazyQuery:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LLazyQuery`. |

**Example**

```lua
do
-- Returns the Lua-visible type name for this lazy query handle.
  local df = lurek.dataframe.fromTable({{x=1}})
  local lq = df:lazy()
  print("lazy type", lq:type())
end
```

---

### `LLazyQuery:typeOf`

Returns whether this lazy query handle matches a supported type name.

```lua
-- signature
LLazyQuery:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LLazyQuery`, `LazyQuery`, and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
-- Returns whether this lazy query handle matches a supported type name.
  local df = lurek.dataframe.fromTable({{x=1}})
  local lq = df:lazy()
  print("is lazy query", lq:typeOf("LLazyQuery"))
  print("is object", lq:typeOf("LObject"))
end
```

---

## LVecFrame

### `LVecFrame:applyMask`

Returns a vectorized frame filtered by a boolean mask table.

```lua
-- signature
LVecFrame:applyMask(mask_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mask_tbl` | `table` | Array table of booleans, one per row. |

**Returns**

| Type | Description |
|------|-------------|
| `LVecFrame` | New vectorized frame containing masked rows. |

**Example**

```lua
do
-- Returns a new VecFrame containing only rows where mask is true
  -- applyMask returns a new VecFrame with only the rows where mask is true.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("hp\n10\n50\n90\n"))
  local mask = vf:filterMask("hp", ">=", 50)
  local alive = vf:applyMask(mask)
  lurek.log.info("alive rows: " .. alive:nrows())
end
```

---

### `LVecFrame:colAbs`

Applies absolute value to a numeric column in place.

```lua
-- signature
LVecFrame:colAbs(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name. |

**Example**

```lua
do
-- Applies absolute value to every cell in a numeric column (in-place)
  -- colAbs converts negative cells to their absolute value (in-place).
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("vel\n-3\n4\n-1\n"))
  vf:colAbs("vel")
  local df = vf:toDataFrame()
  lurek.log.info("speed[1]: " .. tostring(df:getValue(1, "vel")))
end
```

---

### `LVecFrame:colAdd`

Adds a scalar to a numeric column in place.

```lua
-- signature
LVecFrame:colAdd(col, val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name. |
| `val` | `number` | Scalar value to add. |

**Example**

```lua
do
-- Adds a scalar value to every cell in a numeric column (in-place)
  -- colAdd adds a scalar to every cell in a column (in-place).
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("score\n10\n20\n30\n"))
  vf:colAdd("score", 5)
  local df = vf:toDataFrame()
  lurek.log.info("score[1] after +5: " .. tostring(df:getValue(1, "score")))
end
```

---

### `LVecFrame:colCast`

Casts a vectorized column to another data type in place.

```lua
-- signature
LVecFrame:colCast(col, dtype)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name. |
| `dtype` | `string` | Target data type name. |

**Example**

```lua
do
-- Casts a column to a different data type (e.g., "float64", "int64")
  -- colCast changes the internal storage type of a column.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("level\n1\n2\n3\n"))
  vf:colCast("level", "float64")
  lurek.log.info("level dtype after cast: " .. vf:colType("level"))
end
```

---

### `LVecFrame:colCeil`

Applies ceil to a numeric column in place.

```lua
-- signature
LVecFrame:colCeil(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name. |

**Example**

```lua
do
-- Applies ceil (round up) to every cell in a numeric column (in-place)
  -- colCeil rounds every cell up to the nearest integer (in-place).
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("y\n1.1\n2.5\n3.0\n"))
  vf:colCeil("y")
  local df = vf:toDataFrame()
  lurek.log.info("ceiled y[1]: " .. tostring(df:getValue(1, "y")))
end
```

---

### `LVecFrame:colClamp`

Clamps a numeric column in place. This method is available to Lua scripts.

```lua
-- signature
LVecFrame:colClamp(col, min_val, max_val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name. |
| `min_val` | `number` | Minimum allowed value. |
| `max_val` | `number` | Maximum allowed value. |

**Example**

```lua
do
-- Clamps every cell in a numeric column to [min, max] range (in-place)
  -- colClamp enforces a [min, max] range on every cell (in-place).
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("hp\n-5\n50\n150\n"))
  vf:colClamp("hp", 0, 100)
  local df = vf:toDataFrame()
  lurek.log.info("clamped hp[1]: " .. tostring(df:getValue(1, "hp")))
end
```

---

### `LVecFrame:colDiv`

Divides a numeric column by a scalar in place.

```lua
-- signature
LVecFrame:colDiv(col, val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name. |
| `val` | `number` | Scalar divisor. |

**Example**

```lua
do
-- Divides every cell in a numeric column by a scalar (in-place)
  -- colDiv divides every cell by a scalar (in-place).
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("score\n100\n200\n"))
  vf:colDiv("score", 200)
  local df = vf:toDataFrame()
  lurek.log.info("normalised[1]: " .. tostring(df:getValue(1, "score")))
end
```

---

### `LVecFrame:colFloor`

Applies floor to a numeric column in place.

```lua
-- signature
LVecFrame:colFloor(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name. |

**Example**

```lua
do
-- Applies floor (round down) to every cell in a numeric column (in-place)
  -- colFloor rounds every cell down to the nearest integer (in-place).
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("x\n1.9\n2.1\n3.7\n"))
  vf:colFloor("x")
  local df = vf:toDataFrame()
  lurek.log.info("floored x[1]: " .. tostring(df:getValue(1, "x")))
end
```

---

### `LVecFrame:colMul`

Multiplies a numeric column by a scalar in place.

```lua
-- signature
LVecFrame:colMul(col, val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name. |
| `val` | `number` | Scalar multiplier. |

**Example**

```lua
do
-- Multiplies every cell in a numeric column by a scalar (in-place)
  -- colMul multiplies every cell in a column by a scalar (in-place).
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("dmg\n10\n20\n"))
  vf:colMul("dmg", 2.0)
  local df = vf:toDataFrame()
  lurek.log.info("dmg[1] doubled: " .. tostring(df:getValue(1, "dmg")))
end
```

---

### `LVecFrame:colNeg`

Negates a numeric column in place. This method is available to Lua scripts.

```lua
-- signature
LVecFrame:colNeg(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name. |

**Example**

```lua
do
-- Negates every cell in a numeric column (in-place)
  -- colNeg negates every cell (in-place), flipping the sign.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("vy\n3\n-2\n0\n"))
  vf:colNeg("vy")
  local df = vf:toDataFrame()
  lurek.log.info("bounced vy[1]: " .. tostring(df:getValue(1, "vy")))
end
```

---

### `LVecFrame:colOp`

Applies a binary column operation into an output column.

```lua
-- signature
LVecFrame:colOp(out_col, left_col, op, right_col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `out_col` | `string` | Output column name. |
| `left_col` | `string` | Left input column name. |
| `op` | `string` | Binary operation name. |
| `right_col` | `string` | Right input column name. |

**Example**

```lua
do
-- Applies a binary operation between two columns, storing result in a new column
  -- colOp computes (col_a op col_b) per row into a new output column.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("atk,def\n30,10\n40,15\n"))
  vf:colOp("net", "atk", "sub", "def")
  local df = vf:toDataFrame()
  lurek.log.info("net[1]: " .. tostring(df:getValue(1, "net")))
end
```

---

### `LVecFrame:colSqrt`

Applies square root to a numeric column in place.

```lua
-- signature
LVecFrame:colSqrt(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name. |

**Example**

```lua
do
-- Applies square root to every cell in a numeric column (in-place)
  -- colSqrt applies square root to every cell (in-place).
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("d2\n9\n16\n25\n"))
  vf:colSqrt("d2")
  local df = vf:toDataFrame()
  lurek.log.info("dist[1]: " .. tostring(df:getValue(1, "d2")))
end
```

---

### `LVecFrame:colSub`

Subtracts a scalar from a numeric column in place.

```lua
-- signature
LVecFrame:colSub(col, val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name. |
| `val` | `number` | Scalar value to subtract. |

**Example**

```lua
do
-- Subtracts a scalar from every cell in a numeric column (in-place)
  -- colSub subtracts a scalar from every cell (in-place).
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("stamina\n100\n80\n"))
  vf:colSub("stamina", 10)
  local df = vf:toDataFrame()
  lurek.log.info("stamina[1] after drain: " .. tostring(df:getValue(1, "stamina")))
end
```

---

### `LVecFrame:colType`

Returns the data type name for a vectorized column.

```lua
-- signature
LVecFrame:colType(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Column type name, or nil when the column is missing. |

**Example**

```lua
do
-- Returns the data type name of a vectorized column ("float64", "int64", "text", "bool")
  -- colType returns the internal data type of a column ("float64", "int64", etc.).
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("hp\n10\n20\n"))
  lurek.log.info("hp dtype: " .. vf:colType("hp"))
end
```

---

### `LVecFrame:columns`

Returns all vectorized column names in order.

```lua
-- signature
LVecFrame:columns()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Column names. |

**Example**

```lua
do
-- Returns an array table of column names in order
  -- columns() on a VecFrame returns the column name array.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("hp,mp\n10,5\n"))
  local cols = vf:columns()
  lurek.log.info("VecFrame columns: " .. cols[1] .. ", " .. cols[2])
end
```

---

### `LVecFrame:filterMask`

Builds a boolean mask for a numeric column comparison.

```lua
-- signature
LVecFrame:filterMask(col, cmp_op, val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name. |
| `cmp_op` | `string` | Comparison operation name. |
| `val` | `number` | Comparison value. |

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Array table of boolean mask values. |

**Example**

```lua
do
-- Builds a boolean mask array from a column comparison
  -- filterMask builds a boolean mask array from a column comparison.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("hp\n10\n50\n90\n"))
  local mask = vf:filterMask("hp", ">=", 50)
  lurek.log.info("row 2 passes: " .. tostring(mask[2]))
end
```

---

### `LVecFrame:ncols`

Returns the number of columns in this vectorized frame.

```lua
-- signature
LVecFrame:ncols()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Column count. |

**Example**

```lua
do
-- Returns the number of columns in this dataframe
  -- ncols on a VecFrame returns the column count.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("x,y\n1,2\n"))
  lurek.log.info("VecFrame cols: " .. vf:ncols())
end
```

---

### `LVecFrame:nrows`

Returns the number of rows in this vectorized frame.

```lua
-- signature
LVecFrame:nrows()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Row count. |

**Example**

```lua
do
-- Returns the number of rows in this dataframe
  -- nrows on a VecFrame returns the row count, same as on DataFrame.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("v\n1\n2\n3\n"))
  lurek.log.info("VecFrame rows: " .. vf:nrows())
end
```

---

### `LVecFrame:parReduce`

Reduces multiple numeric columns in parallel.

```lua
-- signature
LVecFrame:parReduce(cols_tbl, op)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cols_tbl` | `table` | Array table of column names. |
| `op` | `string` | Reduction operation name. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Table mapping column names to reduction results or nil. |

**Example**

```lua
do
-- Reduces multiple columns in parallel using a named operation
  -- parReduce reduces multiple columns in parallel using a named operation.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("hp,mp\n10,5\n20,10\n30,15\n"))
  local sums = vf:parReduce({"hp", "mp"}, "sum")
  lurek.log.info("hp sum: " .. tostring(sums["hp"]))
end
```

---

### `LVecFrame:parScalarOp`

Applies a scalar operation to multiple numeric columns in parallel.

```lua
-- signature
LVecFrame:parScalarOp(cols_tbl, op, val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cols_tbl` | `table` | Array table of column names. |
| `op` | `string` | Scalar operation name. |
| `val` | `number` | Scalar value used by the operation. |

**Example**

```lua
do
-- Applies a scalar operation to multiple columns in parallel
  -- parScalarOp applies a scalar operation to multiple columns in parallel.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("x,y\n1,2\n3,4\n"))
  vf:parScalarOp({"x", "y"}, "mul", 2.0)
  local df = vf:toDataFrame()
  lurek.log.info("x[1] doubled: " .. tostring(df:getValue(1, "x")))
end
```

---

### `LVecFrame:reduce`

Reduces a numeric column with a named operation.

```lua
-- signature
LVecFrame:reduce(col, op)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | `string` | Column name. |
| `op` | `string` | Reduction operation name. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Reduction result. |

**Example**

```lua
do
-- Reduces a numeric column to a single value using a named operation
  -- reduce aggregates a column to one value using a named operation.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("score\n10\n20\n30\n"))
  local total = vf:reduce("score", "sum")
  lurek.log.info("total score: " .. total)
end
```

---

### `LVecFrame:toDataFrame`

Converts this vectorized frame to a dataframe.

```lua
-- signature
LVecFrame:toDataFrame()
```

**Returns**

| Type | Description |
|------|-------------|
| `LDataFrame` | New dataframe handle. |

**Example**

```lua
do
-- Converts this VecFrame back to a regular DataFrame
  -- toDataFrame converts this VecFrame back to a regular DataFrame.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("v\n1\n2\n3\n"))
  vf:colAdd("v", 10)
  local df = vf:toDataFrame()
  lurek.log.info("v[1] after +10: " .. tostring(df:getValue(1, "v")))
end
```

---

### `LVecFrame:type`

Returns the Lua-visible type name for this vectorized frame handle.

```lua
-- signature
LVecFrame:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LVecFrame`. |

**Example**

```lua
do
-- Returns the type name string "DataFrame" for this handle
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("v\n1\n"))
  print("vec type", vf:type())
end
```

---

### `LVecFrame:typeOf`

Returns whether this vectorized frame handle matches a supported type name.

```lua
-- signature
LVecFrame:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `VecFrame` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
-- Returns true if this handle matches the given type name
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("v\n1\n"))
  print("is vec frame", vf:typeOf("LVecFrame"))
  print("is object", vf:typeOf("LObject"))
end
```

---
