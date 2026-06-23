# Dataframe

## Purpose

Manages DataFrames, databases, SQL query execution, and lazy pipelines.

## When To Use

- At its core are DataFrame and Database concepts that let a project work with both standalone tables and related multi-table collections, which is important because some workflows are local column operations while others look more like lightweight analytics databases.
- Query behavior is deliberately broad. Filtering, sorting, slicing, grouping, joining, pivoting, window calculations, ranking, cumulative metrics, and percent-change analysis all live under the same module family so data processing can stay close to the game or tool using it.
- SQL-like execution makes the feature practical for users who think declaratively, while direct frame methods keep it approachable for scripts that prefer explicit programmatic transformation.

## Minimal Example

Example block: `lurek.dataframe.newDataFrame`

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Creates an empty dataframe with no columns or rows
  -- newDataFrame builds an empty frame; define columns before inserting rows.
  local df = lurek.dataframe.newDataFrame()
  df:addColumn("name", "")
  df:addColumn("score", 0)
  df:addRow({name = "Alice", score = 1200})
  dataframe_log("scoreboard rows=" .. df:nrows() .. " cols=" .. df:ncols())
  dataframe_log("first player=" .. df:getValue(1, "name"))
end
```

## Common Patterns

- Start with `lurek.dataframe.fromBinary` when exploring this module.
- Start with `lurek.dataframe.fromCSV` when exploring this module.
- Start with `lurek.dataframe.fromCSVFile` when exploring this module.
- Start with `lurek.dataframe.fromCSVFileAsync` when exploring this module.
- Start with `lurek.dataframe.fromJSON` when exploring this module.

## API Reference

- This page is the generated API reference for this module.

## Summary

- The `dataframe` module is the engine's tabular-data workspace for users who want table-shaped information to be loaded, queried, transformed, summarized, and exported without leaving the runtime.
- At its core are `DataFrame` and `Database` concepts that let a project work with both standalone tables and related multi-table collections, which is important because some workflows are local column operations while others look more like lightweight analytics databases.
- Query behavior is deliberately broad. Filtering, sorting, slicing, grouping, joining, pivoting, window calculations, ranking, cumulative metrics, and percent-change analysis all live under the same module family so data processing can stay close to the game or tool using it.
- SQL-like execution makes the feature practical for users who think declaratively, while direct frame methods keep it approachable for scripts that prefer explicit programmatic transformation.
- Lazy pipelines are a major functional category because they let callers stage a sequence of operations and materialize only when needed, which helps organize larger data workflows without immediately paying every computation cost.
- Vectorized execution extends the module from convenient table manipulation into more serious numeric workloads. Typed column stores and parallel operations make the same data model useful for both exploratory and performance-sensitive processing.
- Import and export paths such as CSV, JSON, and LVDF matter because real projects move data between authoring tools, analytics views, gameplay state, and regression artifacts. The module is designed to sit in the middle of that movement rather than only at one endpoint.
- Background task support is important from the user perspective because parsing and querying tables can become expensive; off-thread execution lets a project keep the same conceptual API while moving heavier work away from the frame-critical path.
- Diagnostics such as missing-value reports, duplicate analysis, and descriptive statistics turn the module into a quality and validation aid, not only a storage surface. That is useful for telemetry, balancing, content audits, and data-heavy debugging.
- Because joins, windows, grouping, and summary statistics live beside import/export, the module can support full analysis loops inside the engine: ingest data, clean it, compare it, visualize it elsewhere, and persist the refined result.
- That makes the same table model useful for both exploratory inspection and repeatable reporting workflows.
- This makes `dataframe` a natural backbone for reporting-oriented tools and live dashboards where structured content and metrics need to be manipulated with more discipline than generic Lua tables provide.
- That shared table model keeps ingest, analysis, export, and visualization steps connected.
- Read `dataframe` as the engine feature that turns structured tables into a first-class runtime capability. Other systems provide the data or consume the results, but this module owns how tabular information is modeled, queried, transformed, analyzed, and persisted.

This module is mostly self-contained inside the Foundations group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Functions

### `lurek.dataframe.fromBinary`

Parses a dataframe from binary data.

```lua
lurek.dataframe.fromBinary(s)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `s` | string | Binary dataframe payload. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | New dataframe handle. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Deserializes a dataframe from its compact binary format
  -- fromBinary restores a dataframe that was serialised with toBinary().
  local src = lurek.dataframe.fromTable({{x = 1, y = 2}})
  local df = lurek.dataframe.fromBinary(src:toBinary())
  local row = df:getRow(1)
  dataframe_log("binary restore rows=" .. df:nrows())
  dataframe_log("restored point=" .. tostring(row.x) .. "," .. tostring(row.y))
end
```

---

### `lurek.dataframe.fromCSV`

Parses a dataframe from CSV text. This function is exposed to Lua scripts.

```lua
lurek.dataframe.fromCSV(s)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `s` | string | CSV text. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | New dataframe handle. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Parses a dataframe from CSV-formatted text
  -- fromCSV parses CSV text; the first line becomes column headers.
  local df = lurek.dataframe.fromCSV("name,hp\nGoblin,30\nOrc,60\n")
  local names = df:select("name")
  local top = df:sort("hp", false)
  dataframe_log("csv import rows=" .. df:nrows() .. " cols=" .. df:ncols())
  dataframe_log("name preview=" .. names:getValue(2, "name"))
  dataframe_log("top hp enemy=" .. top:getValue(1, "name"))
end
```

---

### `lurek.dataframe.fromCSVFile`

Reads CSV text from GameFS and parses it into a dataframe.

```lua
lurek.dataframe.fromCSVFile(path, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | GameFS path to read. |
| `opts?` | table | Optional file options table; reserved for future CSV options. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | New dataframe handle. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

  local path = "save/dataframe_example.csv"
  local source = lurek.dataframe.fromRows({ "name", "score" }, { { "Alice", 10 }, { "Bob", 20 } })
  source:toCSVFile(path)
  local df = lurek.dataframe.fromCSVFile(path)
  example_print_log("csv rows", df:nrows())
  example_print_log(df:head(1):toString())
end
```

---

### `lurek.dataframe.fromCSVFileAsync`

Starts a Rust worker task that reads CSV text from GameFS and parses it into a dataframe.

```lua
lurek.dataframe.fromCSVFileAsync(path, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | GameFS path to read. |
| `opts?` | table | Optional file options table; reserved for future CSV options. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrameTask](#ldataframetask) | Task that resolves to a dataframe loaded from the CSV file. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

  local path = "save/dataframe_example_async.csv"
  local source = lurek.dataframe.fromRows({ "name", "score" }, { { "Alice", 10 }, { "Bob", 20 } })
  source:toCSVFile(path)
  local task = lurek.dataframe.fromCSVFileAsync(path)
  example_print_log("csv async started", task:type())
  task:wait()
  if task:getError() == nil then
    local df = task:result()
    example_print_log("csv async rows", df:nrows())
  end
end
```

---

### `lurek.dataframe.fromJSON`

Parses a dataframe from JSON text. This function is exposed to Lua scripts.

```lua
lurek.dataframe.fromJSON(s)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `s` | string | JSON text. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | New dataframe handle. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Parses a dataframe from a JSON array of objects
  -- fromJSON parses a JSON array of objects into a dataframe.
  local df = lurek.dataframe.fromJSON('[{"name":"Goblin","hp":30},{"name":"Orc","hp":60}]')
  local top = df:sort("hp", false)
  local row = df:getRow(2)
  dataframe_log("json import rows=" .. df:nrows() .. " cols=" .. df:ncols())
  dataframe_log("boss preview=" .. top:getValue(1, "name"))
  dataframe_log("second row enemy=" .. row.name)
end
```

---

### `lurek.dataframe.fromJSONFile`

Reads JSON text from GameFS and parses it into a dataframe.

```lua
lurek.dataframe.fromJSONFile(path, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | GameFS path to read. |
| `opts?` | table | Optional file options table; reserved for future JSON options. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | New dataframe handle. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

  local path = "save/dataframe_example.json"
  local source = lurek.dataframe.fromRows({ "name", "score" }, { { "Alice", 10 }, { "Bob", 20 } })
  source:toJSONFile(path)
  local df = lurek.dataframe.fromJSONFile(path)
  example_print_log("json rows", df:nrows())
  local columns = df:columns()
  example_print_log("Loaded schema:", table.concat(columns, ", "))
end
```

---

### `lurek.dataframe.fromJSONFileAsync`

Starts a Rust worker task that reads JSON text from GameFS and parses it into a dataframe.

```lua
lurek.dataframe.fromJSONFileAsync(path, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | GameFS path to read. |
| `opts?` | table | Optional file options table; reserved for future JSON options. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrameTask](#ldataframetask) | Task that resolves to a dataframe loaded from the JSON file. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

  local path = "save/dataframe_example_async.json"
  local source = lurek.dataframe.fromRows({ "name", "score" }, { { "Alice", 10 }, { "Bob", 20 } })
  source:toJSONFile(path)
  local task = lurek.dataframe.fromJSONFileAsync(path)
  example_print_log("json async started", task:type())
  task:wait()
  if not task:getError() then
    local df = task:result()
    example_print_log("json async rows", df:nrows())
  end
end
```

---

### `lurek.dataframe.fromRows`

Creates a dataframe from column names and array-style rows.

```lua
lurek.dataframe.fromRows(columns_tbl, rows_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `columns_tbl` | table | Array table of column names. |
| `rows_tbl` | table | Array table of row arrays. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | New dataframe handle. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Creates a dataframe from column names and positional row arrays
  -- fromRows maps column names to positional arrays; no key look-up overhead.
  local df = lurek.dataframe.fromRows({"name", "hp"}, {{"Goblin", 30}, {"Orc", 60}})
  local upgraded = df:clone()
  upgraded:addColumn("status", "idle")
  dataframe_log("spawn plan rows=" .. df:nrows() .. " cols=" .. df:ncols())
  dataframe_log("upgraded schema cols=" .. upgraded:ncols())
end
```

---

### `lurek.dataframe.fromTable`

Creates a dataframe from an array table of row tables.

```lua
lurek.dataframe.fromTable(rows)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `rows` | table | Array of row tables keyed by column name. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | New dataframe handle. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Creates a dataframe from an array of row tables (most common constructor)
  -- fromTable converts a Lua array-of-row-tables into a dataframe.
  local df = lurek.dataframe.fromTable({{name = "Goblin", hp = 30}, {name = "Orc", hp = 60}})
  local strongest = df:sort("hp", false)
  local firstRow = df:getRow(1)
  dataframe_log("enemy table rows=" .. df:nrows() .. " cols=" .. df:ncols())
  dataframe_log("strongest enemy=" .. strongest:getValue(1, "name"))
  dataframe_log("first row enemy=" .. firstRow.name)
end
```

---

### `lurek.dataframe.fromVec`

Converts a vectorized frame to a dataframe.

```lua
lurek.dataframe.fromVec(vf)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `vf` | [LVecFrame](#lvecframe) | Vectorized frame handle to convert. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | New dataframe handle. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Converts a VecFrame back to a regular DataFrame
  -- fromVec converts a VecFrame back to a regular DataFrame.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("hp\n100\n200\n"))
  vf:colMul("hp", 0.5)
  local df = lurek.dataframe.fromVec(vf)
  lurek.log.info("hp after reduction: " .. tostring(df:getValue(1, "hp")))
  lurek.log.info("converted rows: " .. df:nrows())
end
```

---

### `lurek.dataframe.loadDatabase`

Reads a JSON database file from GameFS and parses it into a database.

```lua
lurek.dataframe.loadDatabase(path, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | GameFS path to read. |
| `opts?` | table | Optional options table; `format = "json"` is the only supported format. |

**Returns**

| Type | Description |
|------|-------------|
| [LDatabase](#ldatabase) | New database handle. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

  local path = "save/dataframe_database.json"
  local db = lurek.dataframe.newDatabase()
  local players = lurek.dataframe.fromRows({ "name", "level" }, { { "Alice", 10 }, { "Bob", 20 } })
  db:addTable("players", players)
  db:save(path)
  local restored = lurek.dataframe.loadDatabase(path)
  local loaded_players = restored:getTable("players")
  if loaded_players then
    example_print_log("Loaded " .. loaded_players:nrows() .. " player records")
    example_print_log(loaded_players:toString())
  end
end
```

---

### `lurek.dataframe.newDataFrame`

Creates an empty dataframe. This function is exposed to Lua scripts.

```lua
lurek.dataframe.newDataFrame()
```

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | New empty dataframe handle. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Creates an empty dataframe with no columns or rows
  -- newDataFrame builds an empty frame; define columns before inserting rows.
  local df = lurek.dataframe.newDataFrame()
  df:addColumn("name", "")
  df:addColumn("score", 0)
  df:addRow({name = "Alice", score = 1200})
  dataframe_log("scoreboard rows=" .. df:nrows() .. " cols=" .. df:ncols())
  dataframe_log("first player=" .. df:getValue(1, "name"))
end
```

---

### `lurek.dataframe.newDatabase`

Creates an empty dataframe database.

```lua
lurek.dataframe.newDatabase()
```

**Returns**

| Type | Description |
|------|-------------|
| [LDatabase](#ldatabase) | New database handle. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Creates an empty dataframe database for managing multiple named tables
  -- newDatabase returns an empty container for named dataframes.
  local db = lurek.dataframe.newDatabase()
  local players = lurek.dataframe.fromTable({{id = 1, name = "Alice", level = 12}})
  db:addTable("players", players)
  dataframe_log("database tables=" .. db:tableCount())
  dataframe_log("has players=" .. tostring(db:hasTable("players")))
end
```

---

### `lurek.dataframe.random`

Creates a random dataframe from column definitions.

```lua
lurek.dataframe.random(defs_tbl, n, seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `defs_tbl` | table | Array table of `{name, hint}` column definitions. |
| `n` | number | Number of rows to generate. |
| `seed?` | number | Optional random seed. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | New random dataframe handle. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Generates a random dataframe from column type definitions
  -- random generates test data using column type hints and an optional seed.
  local df = lurek.dataframe.random({{"id", "id"}, {"hp", "int"}}, 10, 1)
  local sample = df:head(2)
  local cols = df:columns()
  dataframe_log("random mob rows=" .. df:nrows())
  dataframe_log("sample first id=" .. tostring(sample:getValue(1, "id")))
  dataframe_log("random schema=" .. table.concat(cols, ","))
end
```

---

### `lurek.dataframe.toVec`

Converts a dataframe to a vectorized frame.

```lua
lurek.dataframe.toVec(df)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `df` | [LDataFrame](#ldataframe) | Dataframe handle to convert. |

**Returns**

| Type | Description |
|------|-------------|
| [LVecFrame](#lvecframe) | New vectorized frame handle. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Converts a dataframe to a vectorized VecFrame for bulk numeric operations
  -- toVec converts a DataFrame to a VecFrame optimised for bulk numeric ops.
  local df = lurek.dataframe.fromCSV("hp,mp\n100,50\n200,80\n")
  local vf = lurek.dataframe.toVec(df)
  lurek.log.info("VecFrame rows: " .. vf:nrows())
  lurek.log.info("VecFrame cols: " .. vf:ncols())
  lurek.log.info("VecFrame hp type: " .. vf:colType("hp"))
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LDataFrame](#ldataframe)
- [LDataFrameTask](#ldataframetask)
- [LDatabase](#ldatabase)
- [LGroupedFrame](#lgroupedframe)
- [LLazyQuery](#llazyquery)
- [LVecFrame](#lvecframe)

## LDataFrame

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LDataFrame:addColumn`

Adds a column with an optional default value.

```lua
LDataFrame:addColumn(name, default)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Column name to create. |
| `default?` | any | Default cell value for existing rows; nil uses empty cells. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

#### `LDataFrame:addRow`

Adds a row from an optional map table and returns its one-based row index.

```lua
LDataFrame:addRow(row_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `row_tbl?` | table | Optional table mapping column names to cell values. |

**Returns**

| Type | Description |
|------|-------------|
| number | One-based index of the inserted row. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Appends a row and returns its one-based index
  -- addRow appends one record and returns its 1-based row index.
  local df = lurek.dataframe.newDataFrame()
  df:addColumn("event", "")
  df:addColumn("timestamp", 0)
  local idx = df:addRow({event = "spawn"})
  df:addRow({event = "loot_drop", timestamp = 4.2})
  dataframe_log("added at row " .. idx)
  dataframe_log("latest event=" .. df:getValue(df:nrows(), "event"))
end
```

---

#### `LDataFrame:addRowBatch`

Appends multiple rows from array-style row tables.

```lua
LDataFrame:addRowBatch(rows)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `rows` | table | Array of row arrays matching the dataframe column order. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

#### `LDataFrame:apply`

Applies a Lua function to each value in a column in place.

```lua
LDataFrame:apply(col_val, func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col_val` | string | Column name string or one-based column index. |
| `func` | function | Function called with each cell value and returning a replacement value. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Transforms every cell in a column using a Lua function (in-place)
  -- apply transforms every cell in a column using a Lua function (in-place).
  local df = lurek.dataframe.fromTable({{score=60},{score=80},{score=45}})
  df:apply("score", function(v) return v >= 70 and "pass" or "fail" end)
  lurek.log.info("grade[1]: " .. df:getValue(1, "score"))
  lurek.log.info("grade[2]: " .. df:getValue(2, "score"))
  lurek.log.info("grade[3]: " .. df:getValue(3, "score"))
end
```

---

#### `LDataFrame:clone`

Returns a deep copy of this dataframe.

```lua
LDataFrame:clone()
```

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | New dataframe containing copied data. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns a deep copy of this dataframe (modifications don't affect the original)
  -- clone returns a deep copy; mutations to the copy don't affect the original.
  local base = lurek.dataframe.fromTable({{stat="atk",value=10}})
  local copy = base:clone()
  copy:setValue(1, "value", 99)
  dataframe_log("base atk=" .. base:getValue(1,"value") .. " copy=" .. copy:getValue(1,"value"))
  dataframe_log("copy rows=" .. copy:nrows())
end
```

---

#### `LDataFrame:columns`

Returns all column names in order. This method is available to Lua scripts.

```lua
LDataFrame:columns()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Column names. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns all column names in order. This method is available to Lua scripts.
  -- columns() returns all column names in order as a Lua array.
  local df = lurek.dataframe.fromTable({{hp=100,mp=50,stamina=80}})
  local cols = df:columns()
  lurek.log.info("schema: " .. table.concat(cols, ", "))
  lurek.log.info("column count: " .. tostring(#cols))
  lurek.log.info("first column: " .. tostring(cols[1]))
end
```

---

#### `LDataFrame:corr`

Returns correlation between two numeric columns.

```lua
LDataFrame:corr(col_a, col_b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col_a` | string | Column name string or one-based column index. |
| `col_b` | string | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| number | Correlation value. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns the Pearson correlation between two numeric columns
  -- corr returns Pearson correlation between two numeric columns.
  local df = lurek.dataframe.fromTable({{x=1,y=2},{x=2,y=4},{x=3,y=6}})
  local r = df:corr("x", "y")
  lurek.log.info("corr x,y: " .. string.format("%.3f", r))
  lurek.log.info("x mean: " .. tostring(df:mean("x")))
  lurek.log.info("y mean: " .. tostring(df:mean("y")))
end
```

---

#### `LDataFrame:correlationMatrix`

Returns a correlation matrix for numeric columns.

```lua
LDataFrame:correlationMatrix()
```

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | Correlation matrix dataframe. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns a correlation matrix dataframe for all numeric columns
  -- correlationMatrix shows pairwise linear correlation between numeric columns.
  local df = lurek.dataframe.fromTable({{a=1,b=2},{a=2,b=4},{a=3,b=6}})
  local matrix = df:correlationMatrix()
  dataframe_log("correlation matrix cols=" .. matrix:ncols())
  dataframe_log("correlation rows=" .. matrix:nrows())
  dataframe_log("matrix first label=" .. tostring(matrix:getValue(1, "column")))
end
```

---

#### `LDataFrame:count`

Returns the row count for this dataframe.

```lua
LDataFrame:count()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Row count. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns the total count of non-nil items in this dataframe
  local df = lurek.dataframe.fromTable({{a = 1, b = 2}, {a = 3, b = 4}})
  local count = df:count()
  local firstRow = df:getRow(1)
  dataframe_log("row count=" .. count)
  dataframe_log("first row a=" .. tostring(firstRow.a) .. " b=" .. tostring(firstRow.b))
end
```

---

#### `LDataFrame:countBy`

Counts occurrences of each value in a column.

```lua
LDataFrame:countBy(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | New dataframe containing value counts. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Counts occurrences of each value in a column; returns a new dataframe
  -- countBy builds a frequency table: one row per distinct value in the column.
  local df = lurek.dataframe.fromTable({{item="sword"},{item="bow"},{item="sword"}})
  local freq = df:countBy("item")
  local cols = freq:columns()
  dataframe_log("frequency rows=" .. freq:nrows())
  dataframe_log("top key column=" .. cols[1] .. " value=" .. tostring(freq:getValue(1, cols[1])))
end
```

---

#### `LDataFrame:dateParts`

Returns a new dataframe with year, month, and day columns extracted from ISO `yyyy-mm-dd` text.

```lua
LDataFrame:dateParts(date_col, prefix)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `date_col` | any | Column name string or one-based column index containing ISO date text. |
| `prefix?` | string | Optional output prefix; `prefix = "txn"` creates `txn_year`, `txn_month`, and `txn_day`. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | New dataframe with extracted date-part columns; invalid or missing dates produce nil parts. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

  local df = lurek.dataframe.fromTable({
    {login_date = "2026-05-21"},
  })
  local parts = df:dateParts("login_date")
  local row = parts:getRow(1)
  example_print_log("date parts rows", parts:nrows())
  example_print_log("year", row.year, "month", row.month, "day", row.day)
end
```

---

#### `LDataFrame:describe`

Returns summary statistics for numeric columns.

```lua
LDataFrame:describe()
```

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | New dataframe containing descriptive statistics. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns summary statistics (count, mean, std, min, max) for numeric columns
  -- describe returns a summary-stats frame (min, max, mean, std per numeric col).
  local df = lurek.dataframe.fromTable({{v=1},{v=2},{v=3},{v=4},{v=5}})
  local stats = df:describe()
  dataframe_log("describe rows=" .. stats:nrows())
  dataframe_log("describe cols=" .. stats:ncols())
  dataframe_log("describe first label=" .. tostring(stats:getValue(1, "stat")))
end
```

---

#### `LDataFrame:dropNil`

Returns rows where the chosen column is not nil.

```lua
LDataFrame:dropNil(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | New dataframe without nil rows for the column. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns rows where the chosen column is not nil.
  -- dropNil returns a new frame with rows where the column is nil removed.
  local df = lurek.dataframe.fromTable({{item="Gem",rarity="rare"},{item="Rock",rarity=nil},{item="Ring",rarity="epic"}})
  local clean = df:dropNil("rarity")
  lurek.log.info("valid loot rows: " .. clean:nrows())
  lurek.log.info("first valid item: " .. tostring(clean:getValue(1, "item")))
  lurek.log.info("last valid rarity: " .. tostring(clean:getValue(clean:nrows(), "rarity")))
end
```

---

#### `LDataFrame:duplicateRows`

Returns rows whose full-row key or selected-column key appears more than once.

```lua
LDataFrame:duplicateRows(cols)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cols?` | table | Optional array table of column name strings or one-based column indexes used as the duplicate key. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | New dataframe containing duplicate rows in original order. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

  local df = lurek.dataframe.fromTable({
    {id = 1, name = "A"},
    {id = 2, name = "B"},
    {id = 1, name = "A"},
  })
  local duplicates = df:duplicateRows({ "id" })
  example_print_log("duplicate rows", duplicates:nrows())
  if duplicates:nrows() > 0 then
    example_print_log(duplicates:toString())
  end
end
```

---

#### `LDataFrame:entropy`

Returns entropy for a column. This method is available to Lua scripts.

```lua
LDataFrame:entropy(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| number | Entropy value. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns the Shannon entropy of a column (measures diversity)
  -- entropy quantifies value diversity (bits); 0 = all same, high = many different.
  local df = lurek.dataframe.fromTable({{cls="warrior"},{cls="mage"},{cls="rogue"}})
  local entropy = df:entropy("cls")
  dataframe_log("class entropy=" .. string.format("%.2f", entropy))
  dataframe_log("dataframe type=" .. df:type())
  dataframe_log("class count=" .. tostring(df:nrows()))
end
```

---

#### `LDataFrame:explain`

Returns a compact dataframe or SQL query execution plan summary.

```lua
LDataFrame:explain(sql_str)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sql_str?` | string | Optional SQL query text to parse and summarize. |

**Returns**

| Type | Description |
|------|-------------|
| string | Human-readable schema or query plan summary. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Preview dataframe shape or SQL query structure for debugging.
  local df = lurek.dataframe.fromTable({ { item = "Sword", gold = 150 }, { item = "Stick", gold = 5 } })
  local plan = df:explain()
  local sql_plan = df:explain("SELECT item FROM self WHERE gold > 100 LIMIT 1")
  lurek.log.info(plan)
  lurek.log.info(sql_plan)
  lurek.log.info("explain rows " .. tostring(df:nrows()))
end
```

---

#### `LDataFrame:fillNil`

Replaces nil cells in a column with a value.

```lua
LDataFrame:fillNil(col, val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name string or one-based column index. |
| `val` | any | Replacement cell value. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Replaces nil cells in a column with a specified value
  -- fillNil replaces nil cells with a default so aggregations don't fail.
  local df = lurek.dataframe.fromTable({{s=10},{s=nil},{s=5}})
  df:fillNil("s", 0)
  dataframe_log("sum after fill=" .. df:sum("s"))
  dataframe_log("middle score=" .. tostring(df:getValue(2, "s")))
  dataframe_log("mean after fill=" .. tostring(df:mean("s")))
end
```

---

#### `LDataFrame:filter`

Returns rows whose column value matches a comparison.

```lua
LDataFrame:filter(col, op, val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | any | Column name string or one-based column index. |
| `op` | string | Comparison operator string. |
| `val` | any | Cell value used as the comparison target. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | New filtered dataframe. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns rows whose column value matches a comparison.
  -- filter returns a new frame with only the rows matching the condition.
  local df = lurek.dataframe.fromTable({{enemy="Goblin",hp=30},{enemy="Orc",hp=80}})
  local strong = df:filter("hp", ">", 50)
  lurek.log.info("strong enemies: " .. strong:nrows())
  lurek.log.info("strongest first enemy: " .. tostring(strong:getValue(1, "enemy")))
  lurek.log.info("strongest hp: " .. tostring(strong:getValue(1, "hp")))
end
```

---

#### `LDataFrame:getColumn`

Returns a column as an array table. This method is available to Lua scripts.

```lua
LDataFrame:getColumn(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | any | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of column values. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns all values in a column as an array table
  -- getColumn extracts all values in a named column as a plain Lua array.
  local df = lurek.dataframe.fromTable({{hp = 10}, {hp = 20}, {hp = 30}})
  local vals = df:getColumn("hp")
  local sum = vals[1] + vals[2] + vals[3]
  dataframe_log("hp[2]=" .. vals[2])
  dataframe_log("column sum=" .. sum)
end
```

---

#### `LDataFrame:getColumnAsF64`

Returns a numeric column as an array of numbers.

```lua
LDataFrame:getColumnAsF64(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Numeric values. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns a numeric column as an array of Lua numbers (float64)
  -- getColumnAsF64 extracts a numeric column as a flat Lua number array.
  local df = lurek.dataframe.fromTable({{hp=10},{hp=20},{hp=30}})
  local vals = df:getColumnAsF64("hp")
  dataframe_log("hp[1]=" .. vals[1])
  dataframe_log("hp[3]=" .. vals[3])
  dataframe_log("hp sample count=" .. tostring(#vals))
end
```

---

#### `LDataFrame:getRow`

Returns a row as a table keyed by column name.

```lua
LDataFrame:getRow(row)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `row` | number | One-based row index to read. |

**Returns**

| Type | Description |
|------|-------------|
| table | Row table keyed by column name. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns a row as a table keyed by column name
  -- getRow returns one record as a {col = value} Lua table.
  local df = lurek.dataframe.fromTable({{name = "Alice", hp = 80}})
  local row = df:getRow(1)
  local summary = row.name .. " hp=" .. row.hp
  dataframe_log(summary)
  dataframe_log("row keys=" .. table.concat(df:columns(), ","))
end
```

---

#### `LDataFrame:getValue`

Returns one cell value by one-based row and column reference.

```lua
LDataFrame:getValue(row, col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `row` | number | One-based row index. |
| `col` | any | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| number | string|boolean|nil | Cell value at the requested row and column. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns one cell value by row index and column reference
  -- getValue reads one cell by 1-based row index and column name.
  local df = lurek.dataframe.fromTable({{name = "Alice", score = 950}})
  local score = df:getValue(1, "score")
  local player = df:getValue(1, "name")
  dataframe_log("score=" .. tostring(score))
  dataframe_log("player=" .. tostring(player) .. " type=" .. df:type())
end
```

---

#### `LDataFrame:groupAgg`

Groups by one column and aggregates another column.

```lua
LDataFrame:groupAgg(group_col, agg_col, fn_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `group_col` | string | Column name string or one-based column index. |
| `agg_col` | string | Column name string or one-based column index. |
| `fn_name` | string | Aggregate function name. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | New grouped aggregate dataframe. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

#### `LDataFrame:groupBy`

Groups rows by a column and returns a table from group key to dataframe.

```lua
LDataFrame:groupBy(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| table | Table keyed by group values with dataframe handles as values. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

#### `LDataFrame:groupByObj`

Groups rows by a column and returns a grouped-frame object.

```lua
LDataFrame:groupByObj(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| [LGroupedFrame](#lgroupedframe) | Grouped frame handle. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Groups rows by a column and returns a GroupedFrame object
  local df = lurek.dataframe.fromTable({
    {region="EU",score=100},{region="NA",score=200},{region="EU",score=150}
  })
  local grouped = df:groupByObj("region")
  example_print_log("grouped type", grouped:type())
end
```

---

#### `LDataFrame:head`

Returns the first rows of this dataframe.

```lua
LDataFrame:head(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n?` | number | Number of rows to return; defaults to 5. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | New dataframe containing the first rows. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns the first rows of this dataframe.
  -- head returns a new frame containing only the first N rows.
  local df = lurek.dataframe.fromTable({{item="Sword"},{item="Shield"},{item="Potion"},{item="Arrow"}})
  local preview = df:head(3)
  lurek.log.info("preview rows: " .. preview:nrows())
  lurek.log.info("preview first item: " .. tostring(preview:getValue(1, "item")))
  lurek.log.info("preview last item: " .. tostring(preview:getValue(preview:nrows(), "item")))
end
```

---

#### `LDataFrame:join`

Joins this dataframe with another dataframe by column references.

```lua
LDataFrame:join(other, this_col, other_col, jtype)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LDataFrame](#ldataframe) | Other dataframe to join. |
| `this_col` | string | Column name string or one-based column index. |
| `other_col` | string | Column name string or one-based column index. |
| `jtype?` | string | Join type string; defaults to `inner`. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | New joined dataframe. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Joins two dataframes by column (inner, left, right, or outer)
  -- join combines two frames on matching column values.
  local players = lurek.dataframe.fromTable({{id=1,name="Alice"},{id=2,name="Bob"}})
  local guilds  = lurek.dataframe.fromTable({{player_id=1,guild="Phoenix"},{player_id=2,guild="Shadow"}})
  local merged = players:join(guilds, "id", "player_id", "inner")
  lurek.log.info("joined rows: " .. merged:nrows())
  lurek.log.info("first joined guild: " .. tostring(merged:getValue(1, "guild")))
end
```

---

#### `LDataFrame:lazy`

Starts a lazy query pipeline from this dataframe.

```lua
LDataFrame:lazy()
```

**Returns**

| Type | Description |
|------|-------------|
| [LLazyQuery](#llazyquery) | New lazy query handle. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Starts a lazy query pipeline from this dataframe
  -- lazy() returns a deferred query handle; operations are chained, not executed yet.
  local df = lurek.dataframe.fromTable({{hp=12,team="red"},{hp=7,team="blue"}})
  local q = df:lazy()
  lurek.log.info("lazy query type: " .. tostring(q:type()))
  lurek.log.info("is lazy query: " .. tostring(q:typeOf("LLazyQuery")))
  lurek.log.info("source rows still available: " .. tostring(df:nrows()))
end
```

---

#### `LDataFrame:max`

Returns the maximum value of a column.

```lua
LDataFrame:max(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | any | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| number | string|boolean|nil | Maximum cell value. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns the maximum value of a column
  -- max returns the largest value in a numeric column.
  local df = lurek.dataframe.fromTable({{s=100},{s=450},{s=380}})
  local high = df:max("s")
  dataframe_log("high score=" .. high)
  dataframe_log("lowest score=" .. tostring(df:min("s")))
  dataframe_log("score samples=" .. tostring(df:nrows()))
end
```

---

#### `LDataFrame:mean`

Returns the numeric mean of a column.

```lua
LDataFrame:mean(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | any | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| number | Column mean. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns the arithmetic mean of a numeric column
  -- mean computes the arithmetic average of a numeric column.
  local df = lurek.dataframe.fromTable({{ms=16},{ms=17},{ms=33}})
  local avg = df:mean("ms")
  dataframe_log("avg ms=" .. avg)
  dataframe_log("slowest frame=" .. tostring(df:max("ms")))
  dataframe_log("frame samples=" .. tostring(df:nrows()))
end
```

---

#### `LDataFrame:median`

Returns the numeric median of a column.

```lua
LDataFrame:median(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | any | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| number | Column median. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns the median (middle value) of a numeric column
  -- median returns the middle value and is robust against outliers.
  local df = lurek.dataframe.fromTable({{ms=16},{ms=16},{ms=17},{ms=200}})
  local typical = df:median("ms")
  dataframe_log("typical ms=" .. typical)
  dataframe_log("outlier max=" .. tostring(df:max("ms")))
  dataframe_log("sample count=" .. tostring(df:nrows()))
end
```

---

#### `LDataFrame:merge`

Appends another dataframe into this dataframe in place.

```lua
LDataFrame:merge(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LDataFrame](#ldataframe) | Dataframe whose rows are merged into this dataframe. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Appends another dataframe into this dataframe in place.
  -- merge appends another frame's rows into this frame in-place.
  local wave1 = lurek.dataframe.fromTable({{enemy="Goblin",hp=30}})
  local wave2 = lurek.dataframe.fromTable({{enemy="Orc",hp=80}})
  wave1:merge(wave2)
  lurek.log.info("combined spawn count: " .. wave1:nrows())
  lurek.log.info("first spawn: " .. tostring(wave1:getValue(1, "enemy")))
end
```

---

#### `LDataFrame:min`

Returns the minimum value of a column.

```lua
LDataFrame:min(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | any | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| number | string|boolean|nil | Minimum cell value. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns the minimum value of a column
  -- min returns the smallest value in a numeric column.
  local df = lurek.dataframe.fromTable({{t=140},{t=138},{t=145}})
  local best = df:min("t")
  dataframe_log("best time=" .. best)
  dataframe_log("attempt count=" .. df:nrows())
  dataframe_log("worst time=" .. tostring(df:max("t")))
end
```

---

#### `LDataFrame:missingReport`

Reports missing and non-missing cell counts for every column.

```lua
LDataFrame:missingReport(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | table | Optional options table reserved for future report settings. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | New dataframe containing `column`, `missing`, `non_missing`, and `missing_percent` columns. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

  local df = lurek.dataframe.fromTable({
    {score = 100},
    {score = nil},
    {score = 200},
  })
  local report = df:missingReport()
  example_print_log("missing report rows", report:nrows())
  example_print_log(report:toString())
end
```

---

#### `LDataFrame:modeVal`

Returns the mode value of a column. This method is available to Lua scripts.

```lua
LDataFrame:modeVal(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| number | string|boolean|nil | Most common cell value. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns the most frequently occurring value in a column
  -- modeVal returns the most frequently occurring value in a column.
  local df = lurek.dataframe.fromTable({{w="sword"},{w="bow"},{w="sword"},{w="staff"},{w="sword"}})
  local mode = df:modeVal("w")
  dataframe_log("most popular=" .. tostring(mode))
  dataframe_log("dataframe type=" .. df:type())
  dataframe_log("unique choices=" .. tostring(#df:unique("w")))
end
```

---

#### `LDataFrame:ncols`

Returns the number of columns in this dataframe.

```lua
LDataFrame:ncols()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Column count. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns the number of columns in this dataframe.
  -- ncols returns how many columns the schema has.
  local df = lurek.dataframe.fromTable({{name="Sword",damage=12,weight=3}})
  lurek.log.info("item schema cols: " .. df:ncols())
  lurek.log.info("item schema names: " .. table.concat(df:columns(), ", "))
  lurek.log.info("row/col shape: " .. df:nrows() .. "x" .. df:ncols())
  lurek.log.info("first item name: " .. tostring(df:getValue(1, "name")))
end
```

---

#### `LDataFrame:normalizeCol`

Adds a range-normalized column in place.

```lua
LDataFrame:normalizeCol(col, out_min, out_max, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name string or one-based column index. |
| `out_min` | number | Output lower bound. |
| `out_max` | number | Output upper bound. |
| `name` | string | Output column name. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Adds a range-normalized column (maps values to [out_min, out_max])
  -- normalizeCol maps a column's range to [out_min, out_max] and stores it.
  local df = lurek.dataframe.fromTable({{val=10},{val=50},{val=90}})
  df:normalizeCol("val", 0.0, 1.0, "val_norm")
  lurek.log.info("normalised column added: " .. df:ncols() .. " cols")
  lurek.log.info("first normalized value: " .. tostring(df:getValue(1, "val_norm")))
  lurek.log.info("last normalized value: " .. tostring(df:getValue(3, "val_norm")))
end
```

---

#### `LDataFrame:nrows`

Returns the number of rows in this dataframe.

```lua
LDataFrame:nrows()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Row count. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns the number of rows in this dataframe.
  -- nrows returns the row count; check it before iterating or indexing.
  local df = lurek.dataframe.fromTable({{name="Alice"},{name="Bob"},{name="Cara"}})
  lurek.log.info("player count: " .. df:nrows())
  lurek.log.info("first player: " .. tostring(df:getValue(1, "name")))
  lurek.log.info("row/col shape: " .. df:nrows() .. "x" .. df:ncols())
  lurek.log.info("last player: " .. tostring(df:getValue(df:nrows(), "name")))
end
```

---

#### `LDataFrame:outliers`

Returns rows considered outliers for a numeric column.

```lua
LDataFrame:outliers(col, threshold)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name string or one-based column index. |
| `threshold?` | number | Z-score threshold; defaults to 2.0. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | New dataframe containing outlier rows. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

#### `LDataFrame:parFilter`

Parallel filter - automatically parallelizes when frame has 10,000+ rows.

```lua
LDataFrame:parFilter(col, op, val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | any | Column name string or one-based column index. |
| `op` | string | Comparison operator (==, !=, <, >, <=, >=, contains). |
| `val` | any | Value to compare against. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | New filtered DataFrame. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

  local df = lurek.dataframe.fromRows({ "x" }, { {1}, {2}, {3}, {4}, {5}, {6} })
  local out = df:parFilter("x", ">", 3)
  lurek.log.info("parFilter rows " .. tostring(out:nrows()))
  lurek.log.info("parFilter first kept " .. tostring(out:getValue(1, "x")))
  lurek.log.info(out:toString())
end
```

---

#### `LDataFrame:parGroupAgg`

Parallel group-by aggregation - partitions and aggregates in parallel.

```lua
LDataFrame:parGroupAgg(group_col, agg_col, fn_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `group_col` | any | Column name string or one-based column index. |
| `agg_col` | any | Column name string or one-based column index. |
| `fn_name` | string | Aggregation function (sum, mean, count, min, max, first, last). |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | Grouped result. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

  local df = lurek.dataframe.fromRows({ "g", "v" }, {
    {"a", 1},
    {"b", 2},
    {"a", 3},
    {"b", 4},
  })
  local out = df:parGroupAgg("g", "v", "sum")
  example_print_log("parGroupAgg rows", out:nrows())
  example_print_log(out:toString())
end
```

---

#### `LDataFrame:pivot`

Pivots rows into columns using row, column, and value fields.

```lua
LDataFrame:pivot(row_col, col_col, val_col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `row_col` | string | Column name string or one-based column index. |
| `col_col` | string | Column name string or one-based column index. |
| `val_col` | string | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | New pivoted dataframe. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

#### `LDataFrame:pivotTable`

Builds a pivot table using row key, column key, value column, and aggregate function.

```lua
LDataFrame:pivotTable(row_key, col_key, value_key, agg)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `row_key` | string | Column name string or one-based column index. |
| `col_key` | string | Column name string or one-based column index. |
| `value_key` | string | Column name string or one-based column index. |
| `agg?` | string | Aggregate function name; defaults to `mean`. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | New pivot table dataframe. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

#### `LDataFrame:query`

Runs a SQL-style query against this dataframe.

```lua
LDataFrame:query(sql_str)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sql_str` | string | SQL query text. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | Query result dataframe. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Runs a SQL-style query against this dataframe.
  -- query runs SQL against this frame (the frame is the table "t").
  local df = lurek.dataframe.fromTable({{item="Sword",gold=150},{item="Stick",gold=5}})
  local expensive = df:query("SELECT * FROM t WHERE gold > 100")
  lurek.log.info("expensive items: " .. expensive:nrows())
  lurek.log.info("first expensive item: " .. tostring(expensive:getValue(1, "item")))
  lurek.log.info("first expensive price: " .. tostring(expensive:getValue(1, "gold")))
end
```

---

#### `LDataFrame:queryAsync`

Runs a SQL-style query against this dataframe on a Rust worker thread.

```lua
LDataFrame:queryAsync(sql_str)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sql_str` | string | SQL query text. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrameTask](#ldataframetask) | Task that resolves to the query result dataframe. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

  local df = lurek.dataframe.fromTable({
    {age = 25},
    {age = 30},
  })
  local task = df:queryAsync("SELECT * FROM t WHERE age > 26")
  example_print_log("query task", task:type())
  task:wait()
  local result_df = task:result()
  example_print_log("async query rows", result_df:nrows())
  example_print_log(result_df:toString())
end
```

---

#### `LDataFrame:rank`

Returns a dataframe with a rank column.

```lua
LDataFrame:rank(col, order, result_col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name string or one-based column index. |
| `order?` | string | Rank order string; defaults to `asc`. |
| `result_col?` | string | Output column name; defaults to `rank`. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | New dataframe with the rank column. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns a new dataframe with a rank column added
  -- rank returns a new frame with a rank column based on the source column.
  local df = lurek.dataframe.fromTable({{player="Alice",score=80},{player="Bob",score=95},{player="Cara",score=72}})
  local ranked = df:rank("score", "desc", "position")
  lurek.log.info("ranked rows: " .. ranked:nrows())
  lurek.log.info("leader name: " .. tostring(ranked:getValue(1, "player")))
  lurek.log.info("leader rank: " .. tostring(ranked:getValue(1, "position")))
end
```

---

#### `LDataFrame:removeColumn`

Removes a column by name or one-based index.

```lua
LDataFrame:removeColumn(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | any | Column name string or one-based column index. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Removes a column from this dataframe by name or index
  -- removeColumn drops a named column, reducing ncols by one.
  local df = lurek.dataframe.fromTable({{name = "Alice", internal = "x7", score = 100}})
  df:removeColumn("internal")
  local cols = df:columns()
  dataframe_log("cols after remove=" .. df:ncols())
  dataframe_log("remaining schema=" .. table.concat(cols, ","))
end
```

---

#### `LDataFrame:removeRow`

Removes a row by one-based index. This method is available to Lua scripts.

```lua
LDataFrame:removeRow(row)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `row` | number | One-based row index to remove. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Removes a row by one-based index
  -- removeRow deletes one record by 1-based index; later rows shift down.
  local df = lurek.dataframe.fromTable({{n = 1}, {n = 2}, {n = 3}})
  df:removeRow(2)
  local first = df:getValue(1, "n")
  dataframe_log("rows after remove=" .. df:nrows())
  dataframe_log("new second row=" .. tostring(df:getValue(2, "n")))
  dataframe_log("first row still=" .. tostring(first))
end
```

---

#### `LDataFrame:rename`

Renames a column by name or one-based index.

```lua
LDataFrame:rename(col, new_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | any | Column name string or one-based column index. |
| `new_name` | string | New column name. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Renames a column (by name or index) to a new name
  -- rename changes a column header without touching its data.
  local df = lurek.dataframe.fromTable({{pts = 100}})
  df:rename("pts", "score")
  local row = df:getRow(1)
  dataframe_log("renamed column=" .. df:columns()[1])
  dataframe_log("value survived=" .. tostring(df:getValue(1, "score")))
  dataframe_log("row score=" .. tostring(row.score))
end
```

---

#### `LDataFrame:rollingMean`

Returns a dataframe with a rolling mean column.

```lua
LDataFrame:rollingMean(col, window, result_col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name string or one-based column index. |
| `window` | number | Rolling window size. |
| `result_col?` | string | Output column name; defaults to `rolling_mean`. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | New dataframe with the rolling mean column. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

#### `LDataFrame:rollingSum`

Returns a dataframe with a rolling sum column.

```lua
LDataFrame:rollingSum(col, window, result_col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name string or one-based column index. |
| `window` | number | Rolling window size. |
| `result_col?` | string | Output column name; defaults to `rolling_sum`. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | New dataframe with the rolling sum column. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

#### `LDataFrame:rows`

Returns an iterator function over one-based row index and row table pairs.

```lua
LDataFrame:rows()
```

**Returns**

| Type | Description |
|------|-------------|
| function | Iterator function for Lua generic-for loops. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns an iterator for use in for-loops (index, row_table)
  -- rows() returns a generic-for iterator yielding (index, row_table).
  local df = lurek.dataframe.fromTable({{name="Alice"},{name="Bob"}})
  local count = 0
  for i, row in df:rows() do
    count = count + 1
    dataframe_log("#" .. i .. " " .. row.name)
  end
  dataframe_log("iterated rows=" .. count)
end
```

---

#### `LDataFrame:sample`

Returns a sampled dataframe. This method is available to Lua scripts.

```lua
LDataFrame:sample(n, seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | number | Number of rows to sample. |
| `seed?` | number | Optional random seed. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | New sampled dataframe. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns a random subset of N rows (optional seed for reproducibility)
  -- sample picks N random rows without replacement; seed for reproducibility.
  local src = lurek.dataframe.random({{"id","id"}}, 100, 1)
  local subset = src:sample(10, 42)
  dataframe_log("sampled rows=" .. subset:nrows())
  dataframe_log("sample first id=" .. tostring(subset:getValue(1, "id")))
  dataframe_log("sample last id=" .. tostring(subset:getValue(subset:nrows(), "id")))
end
```

---

#### `LDataFrame:schema`

Returns inferred column schema metadata.

```lua
LDataFrame:schema()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of `{name, dtype, nullable, count}` column schema records. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Inspect inferred column types and nullability before running a data pipeline.
  local df = lurek.dataframe.fromTable({ { name = "Alice", score = 10 }, { name = "Bob", score = nil } })
  local schema = df:schema()
  lurek.log.info("first column " .. tostring(schema[1].name) .. " " .. tostring(schema[1].dtype))
  lurek.log.info("score nullable " .. tostring(schema[2].nullable))
  lurek.log.info("schema entries " .. tostring(#schema))
end
```

---

#### `LDataFrame:select`

Returns a dataframe with selected columns.

```lua
LDataFrame:select(...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| — | — | @param ... any Column name strings or one-based column indices to keep. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | New dataframe containing selected columns. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns a dataframe with selected columns.
  -- select returns a new frame with only the specified columns.
  local df = lurek.dataframe.fromTable({{name="Alice",score=950,guild="Knights"}})
  local view = df:select("name", "score")
  lurek.log.info("selected cols: " .. view:ncols())
  lurek.log.info("selected player: " .. tostring(view:getValue(1, "name")))
  lurek.log.info("selected score: " .. tostring(view:getValue(1, "score")))
end
```

---

#### `LDataFrame:setColumnFromF64`

Replaces a numeric column from an array table of numbers.

```lua
LDataFrame:setColumnFromF64(col, values)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name string or one-based column index. |
| `values` | table | Array table of numeric values. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Replaces a numeric column's values from an array of numbers
  -- setColumnFromF64 bulk-writes computed numbers back into a column.
  local df = lurek.dataframe.fromTable({{x=0},{x=0},{x=0}})
  df:setColumnFromF64("x", {1.5, 2.5, 3.5})
  dataframe_log("sum x=" .. df:sum("x"))
  dataframe_log("last x=" .. tostring(df:getValue(3, "x")))
  dataframe_log("mean x=" .. tostring(df:mean("x")))
end
```

---

#### `LDataFrame:setValue`

Sets one cell value by one-based row and column reference.

```lua
LDataFrame:setValue(row, col, val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `row` | number | One-based row index. |
| `col` | any | Column name string or one-based column index. |
| `val` | any | Cell value to store. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Sets one cell value by row index and column reference
  -- setValue updates one cell by 1-based row index and column name.
  local df = lurek.dataframe.fromTable({{player="Alice",score=50}})
  df:setValue(1, "score", 150)
  lurek.log.info("updated score: " .. df:getValue(1, "score"))
  lurek.log.info("player after update: " .. tostring(df:getValue(1, "player")))
  lurek.log.info("row count: " .. tostring(df:nrows()))
end
```

---

#### `LDataFrame:slice`

Returns a one-based inclusive row slice.

```lua
LDataFrame:slice(start, end_)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `start` | number | One-based start row. |
| `end_` | number | One-based end row. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | New dataframe containing the row slice. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns a one-based inclusive row slice.
  -- slice returns a 1-based inclusive row range as a new frame.
  local df = lurek.dataframe.fromTable({{r="Sword"},{r="Shield"},{r="Bow"},{r="Staff"},{r="Helm"},{r="Boots"}})
  local page2 = df:slice(4, 6)
  lurek.log.info("page 2 rows: " .. page2:nrows())
  lurek.log.info("page 2 first recipe: " .. tostring(page2:getValue(1, "r")))
  lurek.log.info("page 2 last recipe: " .. tostring(page2:getValue(page2:nrows(), "r")))
end
```

---

#### `LDataFrame:sort`

Returns rows sorted by a column. This method is available to Lua scripts.

```lua
LDataFrame:sort(col, ascending)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | any | Column name string or one-based column index. |
| `ascending?` | boolean | True for ascending order; defaults to true. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | New sorted dataframe. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns rows sorted by a column. This method is available to Lua scripts.
  -- sort returns a new frame with rows ordered by the named column.
  local df = lurek.dataframe.fromTable({{name="Alice",score=950},{name="Bob",score=1200}})
  local sorted = df:sort("score", false)
  lurek.log.info("top scorer: " .. sorted:getValue(1, "name"))
  lurek.log.info("top score: " .. tostring(sorted:getValue(1, "score")))
  lurek.log.info("sorted rows: " .. tostring(sorted:nrows()))
end
```

---

#### `LDataFrame:stddev`

Returns the numeric standard deviation of a column.

```lua
LDataFrame:stddev(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | any | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| number | Column standard deviation. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns the standard deviation of a numeric column
  -- stddev measures the spread of values in a numeric column.
  local df = lurek.dataframe.fromTable({{v=10},{v=20},{v=30},{v=40}})
  local spread = df:stddev("v")
  dataframe_log("stddev=" .. string.format("%.1f", spread))
  dataframe_log("variance=" .. string.format("%.1f", df:variance("v")))
  dataframe_log("mean=" .. string.format("%.1f", df:mean("v")))
end
```

---

#### `LDataFrame:sum`

Returns the numeric sum of a column.

```lua
LDataFrame:sum(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | any | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| number | Column sum. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns the numeric sum of a column
  -- sum totals all values in a numeric column.
  local df = lurek.dataframe.fromTable({{dmg=10},{dmg=20},{dmg=5}})
  local total = df:sum("dmg")
  dataframe_log("total damage=" .. total)
  dataframe_log("average hit=" .. tostring(df:mean("dmg")))
  dataframe_log("highest hit=" .. tostring(df:max("dmg")))
end
```

---

#### `LDataFrame:tail`

Returns the last rows of this dataframe.

```lua
LDataFrame:tail(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n?` | number | Number of rows to return; defaults to 5. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | New dataframe containing the last rows. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns the last rows of this dataframe.
  -- tail returns a new frame containing only the last N rows.
  local df = lurek.dataframe.fromTable({{turn=1},{turn=2},{turn=3},{turn=4}})
  local recent = df:tail(2)
  lurek.log.info("recent rows: " .. recent:nrows())
  lurek.log.info("recent first turn: " .. tostring(recent:getValue(1, "turn")))
  lurek.log.info("recent last turn: " .. tostring(recent:getValue(recent:nrows(), "turn")))
end
```

---

#### `LDataFrame:toBinary`

Serializes this dataframe to binary data.

```lua
LDataFrame:toBinary()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Binary string containing serialized dataframe data. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Serializes this dataframe to a compact binary format
  -- toBinary produces the most compact serialisation format.
  local df = lurek.dataframe.fromTable({{x=1.5,y=2.3}})
  local blob = df:toBinary()
  local restored = lurek.dataframe.fromBinary(blob)
  dataframe_log("binary bytes=" .. #blob)
  dataframe_log("restored rows=" .. restored:nrows())
end
```

---

#### `LDataFrame:toBinaryFile`

Serializes this dataframe to LVDF binary data and writes it through GameFS.

```lua
LDataFrame:toBinaryFile(path, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | GameFS save path to write, usually under `save/`. |
| `opts?` | table | Optional file options table; reserved for future binary options. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the file was written. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

  local df = lurek.dataframe.fromTable({
    {level = 42},
    {level = 43},
  })
  local ok = df:toBinaryFile("save/output.lvdf")
  example_print_log("binary saved", ok)
  example_print_log("binary bytes", #df:toBinary())
end
```

---

#### `LDataFrame:toCSV`

Serializes this dataframe to CSV text.

```lua
LDataFrame:toCSV()
```

**Returns**

| Type | Description |
|------|-------------|
| string | CSV text. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Serializes this dataframe to CSV text
  -- toCSV serialises the frame to CSV text with a header row.
  local df = lurek.dataframe.fromTable({{name="Alice",score=100}})
  local csv = df:toCSV()
  dataframe_log("CSV bytes=" .. #csv)
  dataframe_log("csv has header=" .. tostring(string.find(csv, "name,score", 1, true) ~= nil))
  dataframe_log("csv has row=" .. tostring(string.find(csv, "Alice", 1, true) ~= nil))
end
```

---

#### `LDataFrame:toCSVFile`

Serializes this dataframe to CSV text and writes it through GameFS.

```lua
LDataFrame:toCSVFile(path, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | GameFS save path to write, usually under `save/`. |
| `opts?` | table | Optional file options table; reserved for future CSV options. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the file was written. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

  local df = lurek.dataframe.fromTable({
    {score = 500},
    {score = 725},
  })
  local ok = df:toCSVFile("save/output.csv")
  example_print_log("csv saved", ok)
  example_print_log("csv preview", df:toCSV())
end
```

---

#### `LDataFrame:toJSON`

Serializes this dataframe to JSON text.

```lua
LDataFrame:toJSON()
```

**Returns**

| Type | Description |
|------|-------------|
| string | JSON text. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Serializes this dataframe to JSON text.
  -- toJSON serialises the frame to a JSON array-of-objects string.
  local df = lurek.dataframe.fromTable({{stat="playtime",value=3600}})
  local json = df:toJSON()
  lurek.log.info("JSON length: " .. #json)
  lurek.log.info("json has key stat: " .. tostring(string.find(json, "stat", 1, true) ~= nil))
  lurek.log.info("json has value 3600: " .. tostring(string.find(json, "3600", 1, true) ~= nil))
end
```

---

#### `LDataFrame:toJSONFile`

Serializes this dataframe to JSON text and writes it through GameFS.

```lua
LDataFrame:toJSONFile(path, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | GameFS save path to write, usually under `save/`. |
| `opts?` | table | Optional file options table; reserved for future JSON options. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the file was written. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

  local df = lurek.dataframe.fromTable({
    {name = "Alice"},
    {name = "Bob"},
  })
  local ok = df:toJSONFile("save/output.json")
  example_print_log("json saved", ok)
  example_print_log("json preview", df:toJSON())
end
```

---

#### `LDataFrame:toString`

Formats this dataframe as a human-readable text table.

```lua
LDataFrame:toString()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Text table representation. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Formats this dataframe as a human-readable aligned text table
  -- toString formats the frame as an aligned text table for debug output.
  local df = lurek.dataframe.fromTable({{name="Alice",hp=80}})
  local text = df:toString()
  dataframe_log("frame text bytes=" .. #text)
  dataframe_log("frame type=" .. df:type())
  dataframe_log("text contains name=" .. tostring(string.find(text, "Alice", 1, true) ~= nil))
end
```

---

#### `LDataFrame:toTable`

Converts this dataframe to an array table of row tables.

```lua
LDataFrame:toTable()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of rows keyed by column name. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Converts this dataframe to a plain Lua array of row tables
  -- toTable converts the frame back to a plain Lua array-of-row-tables.
  local df = lurek.dataframe.fromTable({{name="Alice",hp=80}})
  local rows = df:toTable()
  dataframe_log("first row name=" .. rows[1].name)
  dataframe_log("row count=" .. #rows)
  dataframe_log("first row hp=" .. tostring(rows[1].hp))
end
```

---

#### `LDataFrame:type`

Returns the Lua-visible type name for this dataframe handle.

```lua
LDataFrame:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LDataFrame](#ldataframe)`. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

  local df = lurek.dataframe.newDataFrame()
  local typeName = df:type()
  local matches = typeName == "LDataFrame"
  dataframe_log("dataframe type=" .. typeName)
  dataframe_log("confirmed dataframe handle=" .. tostring(matches))
end
```

---

#### `LDataFrame:typeOf`

Returns whether this dataframe handle matches a supported type name.

```lua
LDataFrame:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LDataFrame](#ldataframe)`, `DataFrame`, and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

  local df = lurek.dataframe.newDataFrame()
  local isObject = df:typeOf("LObject")
  local isFrame = df:typeOf("LDataFrame")
  dataframe_log("dataframe is object=" .. tostring(isObject))
  dataframe_log("dataframe is frame=" .. tostring(isFrame))
end
```

---

#### `LDataFrame:unique`

Returns unique values from a column.

```lua
LDataFrame:unique(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | any | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of unique values. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns unique values from a column as an array table
  -- unique returns the distinct values of one column as a Lua array.
  local df = lurek.dataframe.fromTable({{cls="warrior"},{cls="mage"},{cls="warrior"}})
  local types = df:unique("cls")
  dataframe_log("distinct classes=" .. #types)
  dataframe_log("first distinct=" .. tostring(types[1]))
  dataframe_log("last distinct=" .. tostring(types[#types]))
end
```

---

#### `LDataFrame:valueCounts`

Counts occurrences of each value in a column with optional percentage output.

```lua
LDataFrame:valueCounts(col, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | any | Column name string or one-based column index. |
| `opts?` | table | Optional options table; set `percent = true` to include percentage values from 0 to 100. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | New dataframe containing `value`, `count`, and optional `percent` columns. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

  local df = lurek.dataframe.fromTable({
    {class = "Warrior"},
    {class = "Mage"},
    {class = "Warrior"},
  })
  local counts = df:valueCounts("class")
  example_print_log("value counts rows", counts:nrows())
  example_print_log(counts:toString())
end
```

---

#### `LDataFrame:variance`

Returns the numeric variance of a column.

```lua
LDataFrame:variance(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | any | Column name string or one-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| number | Column variance. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns the variance of a numeric column
  -- variance is stddev squared; used in statistical formulas.
  local df = lurek.dataframe.fromTable({{v=10},{v=20},{v=30}})
  local variance = df:variance("v")
  dataframe_log("variance=" .. variance)
  dataframe_log("stddev=" .. tostring(df:stddev("v")))
  dataframe_log("mean=" .. tostring(df:mean("v")))
end
```

---

#### `LDataFrame:withCumsum`

Adds a cumulative-sum column in place.

```lua
LDataFrame:withCumsum(col, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name string or one-based column index. |
| `name` | string | Output column name. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

#### `LDataFrame:withEval`

Returns a dataframe with a column computed from an expression.

```lua
LDataFrame:withEval(col_name, expr)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col_name` | string | Output column name. |
| `expr` | string | Dataframe expression evaluated by the dataframe module. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | New dataframe with the evaluated column. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns a new dataframe with an added column computed from an expression
  -- withEval adds a derived column computed row-by-row from an expression.
  local df = lurek.dataframe.fromTable({{atk=10,bonus=4},{atk=15,bonus=2}})
  local result = df:withEval("eff", "atk + bonus")
  dataframe_log("eff[1]=" .. result:getValue(1, "eff"))
  dataframe_log("best eff=" .. tostring(result:max("eff")))
  dataframe_log("eff rows=" .. tostring(result:nrows()))
end
```

---

#### `LDataFrame:withPctChange`

Adds a percent-change column in place.

```lua
LDataFrame:withPctChange(col, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name string or one-based column index. |
| `name` | string | Output column name. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

#### `LDataFrame:withRank`

Adds a rank column in place. This method is available to Lua scripts.

```lua
LDataFrame:withRank(col, asc, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name string or one-based column index. |
| `asc?` | boolean | True for ascending rank; defaults to true. |
| `name` | string | Output column name. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Adds a rank column in-place based on a source column
  -- withRank adds a rank column in-place without creating a new frame.
  local df = lurek.dataframe.fromTable({{player="Alice",pts=10},{player="Bob",pts=30},{player="Cara",pts=20}})
  df:withRank("pts", true, "rank")
  lurek.log.info("rank col added: " .. df:ncols() .. " cols")
  lurek.log.info("lowest points rank: " .. tostring(df:getValue(1, "rank")))
  lurek.log.info("highest points rank: " .. tostring(df:getValue(2, "rank")))
end
```

---

#### `LDataFrame:withRollingMax`

Adds a rolling maximum column in place.

```lua
LDataFrame:withRollingMax(col, window, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name string or one-based column index. |
| `window` | number | Rolling window size. |
| `name` | string | Output column name. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

#### `LDataFrame:withRollingMean`

Adds a rolling mean column in place.

```lua
LDataFrame:withRollingMean(col, window, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name string or one-based column index. |
| `window` | number | Rolling window size. |
| `name` | string | Output column name. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

#### `LDataFrame:withRollingMin`

Adds a rolling minimum column in place.

```lua
LDataFrame:withRollingMin(col, window, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name string or one-based column index. |
| `window` | number | Rolling window size. |
| `name` | string | Output column name. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

#### `LDataFrame:withRollingSum`

Adds a rolling sum column in place. This method is available to Lua scripts.

```lua
LDataFrame:withRollingSum(col, window, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name string or one-based column index. |
| `window` | number | Rolling window size. |
| `name` | string | Output column name. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

#### `LDataFrame:zscoreCol`

Adds a z-score normalized column in place.

```lua
LDataFrame:zscoreCol(col, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name string or one-based column index. |
| `name` | string | Output column name. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LDataFrameTask:getError`

Returns the task error message after failure.

```lua
LDataFrameTask:getError()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Error message after failure. |
| nil | If the task is pending or succeeded. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

  local path = "save/dataframe_task_error.csv"
  local source = lurek.dataframe.fromRows({ "name", "score" }, { { "Alice", 10 }, { "Bob", 20 } })
  source:toCSVFile(path)
  local task = lurek.dataframe.fromCSVFileAsync(path)
  task:wait()
  example_print_log("task error", task:getError())
end
```

---

#### `LDataFrameTask:isDone`

Returns whether this dataframe task has completed with success or failure.

```lua
LDataFrameTask:isDone()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True once the worker has produced a result or error. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

  local path = "save/dataframe_task_status.csv"
  local source = lurek.dataframe.fromRows({ "name", "score" }, { { "Alice", 10 }, { "Bob", 20 } })
  source:toCSVFile(path)
  local task = lurek.dataframe.fromCSVFileAsync(path)
  example_print_log("done before wait", task:isDone())
  task:wait()
  example_print_log("done after wait", task:isDone())
end
```

---

#### `LDataFrameTask:progress`

Returns a coarse task progress estimate.

```lua
LDataFrameTask:progress()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Progress from 0.0 to 1.0. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

  local path = "save/dataframe_task_progress.csv"
  local source = lurek.dataframe.fromRows({ "name", "score" }, { { "Alice", 10 }, { "Bob", 20 } })
  source:toCSVFile(path)
  local task = lurek.dataframe.fromCSVFileAsync(path)
  example_print_log("initial progress", task:progress())
  task:wait()
  example_print_log("final progress", task:progress())
end
```

---

#### `LDataFrameTask:result`

Returns the completed dataframe result.

```lua
LDataFrameTask:result()
```

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | Completed dataframe result. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

  local df = lurek.dataframe.fromRows({ "id" }, { { 1 }, { 2 } })
  local task = df:queryAsync("SELECT * FROM t WHERE id = 1")
  task:wait()
  local result_df = task:result()
  example_print_log("result rows", result_df:nrows())
  example_print_log(result_df:toString())
end
```

---

#### `LDataFrameTask:type`

Returns the Lua-visible type name for this dataframe task handle.

```lua
LDataFrameTask:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LDataFrameTask](#ldataframetask)`. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

  local df = lurek.dataframe.fromRows({ "id" }, { { 1 }, { 2 } })
  local task = df:queryAsync("SELECT * FROM t WHERE id = 1")
  local type_name = task:type()
  example_print_log("task type", type_name)
  if type_name == "LDataFrameTask" then
    example_print_log("This is indeed a DataFrameTask")
  end
  task:wait()
end
```

---

#### `LDataFrameTask:typeOf`

Returns whether this dataframe task handle matches a supported type name.

```lua
LDataFrameTask:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LDataFrameTask](#ldataframetask)`, `DataFrameTask`, and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

  local df = lurek.dataframe.fromRows({ "id" }, { { 1 }, { 2 } })
  local task = df:queryAsync("SELECT * FROM t WHERE id = 1")
  local is_task = task:typeOf("LDataFrameTask")
  example_print_log("is dataframe task", is_task)
  if is_task then
    example_print_log("Object is verified as DataFrameTask")
  end
  task:wait()
end
```

---

#### `LDataFrameTask:wait`

Blocks until this dataframe task completes.

```lua
LDataFrameTask:wait()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the task completed successfully; false when it completed with an error. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

  local path = "save/dataframe_task_wait.json"
  local source = lurek.dataframe.fromRows({ "name", "score" }, { { "Alice", 10 }, { "Bob", 20 } })
  source:toJSONFile(path)
  local task = lurek.dataframe.fromJSONFileAsync(path)
  example_print_log("waiting for task")
  task:wait()
  example_print_log("task error", task:getError())
end
```

---

## LDatabase

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LDatabase:addTable`

Adds or replaces a named dataframe table in the database.

```lua
LDatabase:addTable(name, df_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Table name. |
| `df_ud` | [LDataFrame](#ldataframe) | Dataframe handle copied into the database. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

#### `LDatabase:clear`

Removes every table from the database.

```lua
LDatabase:clear()
```

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Removes all tables from this database
  -- clear removes all tables, resetting the database to empty.
  local db = lurek.dataframe.newDatabase()
  db:addTable("round1", lurek.dataframe.newDataFrame())
  local before = db:tableCount()
  db:clear()
  dataframe_log("tables before clear=" .. before)
  dataframe_log("tables after clear=" .. db:tableCount())
end
```

---

#### `LDatabase:getTable`

Returns a copy of a named table when it exists.

```lua
LDatabase:getTable(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Table name to retrieve. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | Dataframe handle, or nil when no table has that name. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns a copy of a named table from the database (or nil if not found)
  -- getTable retrieves a named dataframe from the database (nil if absent).
  local db = lurek.dataframe.newDatabase()
  db:addTable("players", lurek.dataframe.fromTable({{name="Alice"}}))
  local t = db:getTable("players")
  if t then
    dataframe_log("players rows=" .. t:nrows())
    dataframe_log("first player=" .. tostring(t:getValue(1, "name")))
  end
end
```

---

#### `LDatabase:hasTable`

Returns whether a named table exists.

```lua
LDatabase:hasTable(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Table name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the table exists. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns true if the database contains a table with the given name
  -- hasTable returns true when the named table is registered.
  local db = lurek.dataframe.newDatabase()
  db:addTable("scores", lurek.dataframe.newDataFrame())
  dataframe_log("has scores=" .. tostring(db:hasTable("scores")))
  dataframe_log("has items=" .. tostring(db:hasTable("items")))
  dataframe_log("table count=" .. tostring(db:tableCount()))
end
```

---

#### `LDatabase:listTables`

Returns all table names in the database.

```lua
LDatabase:listTables()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Table names. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns an array of all table names in the database
  -- listTables returns all registered table names as a Lua array.
  local db = lurek.dataframe.newDatabase()
  db:addTable("players", lurek.dataframe.newDataFrame())
  db:addTable("items", lurek.dataframe.newDataFrame())
  local names = db:listTables()
  dataframe_log("tables=" .. table.concat(names, ", "))
  dataframe_log("table count=" .. #names)
end
```

---

#### `LDatabase:merge`

Merges another database into this database.

```lua
LDatabase:merge(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LDatabase](#ldatabase) | Database copied into this database. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

#### `LDatabase:query`

Runs a SQL-style query against the database tables.

```lua
LDatabase:query(sql_str)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sql_str` | string | SQL query text. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | Query result dataframe. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Runs a SQL SELECT query against this dataframe (table alias is "t")
  -- query on a Database runs SQL that can reference all registered tables.
  local db = lurek.dataframe.newDatabase()
  db:addTable("players", lurek.dataframe.fromTable({{name="Alice",hp=80},{name="Bob",hp=20}}))
  local result = db:query("SELECT name FROM players WHERE hp < 50")
  dataframe_log("low-hp players=" .. result:nrows())
  dataframe_log("first wounded=" .. tostring(result:getValue(1, "name")))
end
```

---

#### `LDatabase:queryAsync`

Runs a SQL-style query against a snapshot of the database tables on a Rust worker thread.

```lua
LDatabase:queryAsync(sql_str)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sql_str` | string | SQL query text. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrameTask](#ldataframetask) | Task that resolves to the query result dataframe. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

  local db = lurek.dataframe.newDatabase()
  local users = lurek.dataframe.fromRows({ "age" }, { { 25 }, { 30 } })
  db:addTable("users", users)
  local task = db:queryAsync("SELECT * FROM users WHERE age > 26")
  example_print_log("database query task", task:type())
  task:wait()
  local result_df = task:result()
  example_print_log("Async query finished, resulting rows: " .. result_df:nrows())
end
```

---

#### `LDatabase:queryParams`

Runs a SQL-style query against the database tables with positional parameters.

```lua
LDatabase:queryParams(sql_str, params)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sql_str` | string | SQL query text using `?` placeholders outside string literals. |
| `params` | table | Array table of positional parameter values; nil maps to SQL NULL, strings are escaped, and booleans/numbers are bound as literals. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | Query result dataframe. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

  local db = lurek.dataframe.newDatabase()
  local users = lurek.dataframe.fromRows({ "name" }, { { "Alice" }, { "Bob" } })
  db:addTable("users", users)
  local result = db:queryParams("SELECT * FROM users WHERE name = ?", {"Alice"})
  example_print_log("query params rows", result:nrows())
  example_print_log(result:toString())
end
```

---

#### `LDatabase:queryParamsAsync`

Runs a parameterized SQL query against a snapshot of the database tables on a Rust worker thread.

```lua
LDatabase:queryParamsAsync(sql_str, params)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sql_str` | string | SQL query text using `?` placeholders outside string literals. |
| `params` | table | Array table of positional parameter values; nil maps to SQL NULL, strings are escaped, and booleans/numbers are bound as literals. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrameTask](#ldataframetask) | Task that resolves to the query result dataframe. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

  local db = lurek.dataframe.newDatabase()
  local players = lurek.dataframe.fromRows({ "level" }, { { 10 }, { 20 } })
  db:addTable("players", players)
  local task = db:queryParamsAsync("SELECT * FROM players WHERE level > ?", {15})
  task:wait()
  local result = task:result()
  example_print_log("async param rows", result:nrows())
  example_print_log(result:toString())
end
```

---

#### `LDatabase:removeTable`

Removes a named table from the database.

```lua
LDatabase:removeTable(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Table name to remove. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Removes a named table from the database
  -- removeTable deletes a named table; useful for session cleanup.
  local db = lurek.dataframe.newDatabase()
  db:addTable("temp", lurek.dataframe.newDataFrame())
  db:removeTable("temp")
  dataframe_log("tables after remove=" .. db:tableCount())
  dataframe_log("has temp=" .. tostring(db:hasTable("temp")))
end
```

---

#### `LDatabase:save`

Serializes the database to the JSON database file format and writes it through GameFS.

```lua
LDatabase:save(path, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | GameFS save path to write, usually under `save/`. |
| `opts?` | table | Optional options table; `format = "json"` is the only supported format. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the file was written. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

  local db = lurek.dataframe.newDatabase()
  local df = lurek.dataframe.fromTable({
    {score = 100},
  })
  db:addTable("savegame_stats", df)
  local success = db:save("save/savegame_stats.json")
  example_print_log("database saved", success)
end
```

---

#### `LDatabase:tableCount`

Returns the number of tables in the database.

```lua
LDatabase:tableCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Table count. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns the number of tables in this database
  -- tableCount returns the number of tables registered in this database.
  local db = lurek.dataframe.newDatabase()
  db:addTable("a", lurek.dataframe.newDataFrame())
  db:addTable("b", lurek.dataframe.newDataFrame())
  dataframe_log("table count=" .. db:tableCount())
  dataframe_log("has a=" .. tostring(db:hasTable("a")))
end
```

---

#### `LDatabase:toJSON`

Serializes the database to JSON text.

```lua
LDatabase:toJSON()
```

**Returns**

| Type | Description |
|------|-------------|
| string | JSON text. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Serializes this dataframe to a JSON array of objects
  -- toJSON on a Database serialises all its tables to a JSON string.
  local db = lurek.dataframe.newDatabase()
  db:addTable("scores", lurek.dataframe.fromTable({{v=1}}))
  local json = db:toJSON()
  local tables = db:listTables()
  dataframe_log("database JSON bytes=" .. #json)
  dataframe_log("tables exported=" .. table.concat(tables, ","))
end
```

---

#### `LDatabase:type`

Returns the Lua-visible type name for this database handle.

```lua
LDatabase:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LDatabase](#ldatabase)`. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns the Lua-visible type name for this database handle.
  local db = lurek.dataframe.newDatabase()
  lurek.log.info("db type " .. tostring(db:type()))
  lurek.log.info("table count " .. tostring(db:tableCount()))
  lurek.log.info("table count " .. tostring(db:tableCount()))
  lurek.log.info("is database " .. tostring(db:typeOf("LDatabase")))
end
```

---

#### `LDatabase:typeOf`

Returns whether this database handle matches a supported type name.

```lua
LDatabase:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LDatabase](#ldatabase)`, `Database`, and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns whether this database handle matches a supported type name.
  local db = lurek.dataframe.newDatabase()
  lurek.log.info("is database " .. tostring(db:typeOf("LDatabase")))
  lurek.log.info("is object " .. tostring(db:typeOf("LObject")))
  lurek.log.info("db type " .. tostring(db:type()))
  lurek.log.info("table count " .. tostring(db:tableCount()))
end
```

---

## LGroupedFrame

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LGroupedFrame:aggregate`

Aggregates one numeric column in every group by calling a Lua function with that group's numeric values.

```lua
LGroupedFrame:aggregate(col_name, func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col_name` | string | Column name to aggregate in each group. |
| `func` | function | Function called with an array table of numeric values and returning a number. |

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | DataFrame containing `group_key` and the aggregated column. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
  example_print_log("aggregate rows", result:nrows())
  example_print_log(result:toString())
end
```

---

#### `LGroupedFrame:type`

Returns the Lua-visible type name for this grouped frame handle.

```lua
LGroupedFrame:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LGroupedFrame](#lgroupedframe)`. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns the Lua-visible type name for this grouped frame handle.
  local df = lurek.dataframe.fromTable({{team="red",score=10},{team="blue",score=20}})
  local grouped = df:groupByObj("team")
  lurek.log.info("grouped type " .. tostring(grouped:type()))
  lurek.log.info("grouped handle " .. tostring(grouped))
  lurek.log.info("is grouped object " .. tostring(grouped:typeOf("LObject")))
end
```

---

#### `LGroupedFrame:typeOf`

Returns whether this grouped frame handle matches a supported type name.

```lua
LGroupedFrame:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LGroupedFrame](#lgroupedframe)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns whether this grouped frame handle matches a supported type name.
  local df = lurek.dataframe.fromTable({{team="red",score=10},{team="blue",score=20}})
  local grouped = df:groupByObj("team")
  lurek.log.info("is grouped frame " .. tostring(grouped:typeOf("LGroupedFrame")))
  lurek.log.info("is object " .. tostring(grouped:typeOf("LObject")))
  lurek.log.info("grouped type " .. tostring(grouped:type()))
end
```

---

## LLazyQuery

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LLazyQuery:collect`

Executes the lazy query and returns a dataframe.

```lua
LLazyQuery:collect()
```

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | Dataframe produced by the query plan. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Executes the lazy query and returns a dataframe.
  local df = lurek.dataframe.fromTable({{item="Sword",gold=150},{item="Stick",gold=5}})
  local result = df:lazy():limit(10):collect()
  lurek.log.info("collected rows " .. tostring(result:nrows()))
  lurek.log.info("first collected item " .. tostring(result:getValue(1, "item")))
  lurek.log.info(result:toString())
end
```

---

#### `LLazyQuery:dropNil`

Adds a step that drops rows with nil values in a column.

```lua
LLazyQuery:dropNil(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name to test for nil values. |

**Returns**

| Type | Description |
|------|-------------|
| [LLazyQuery](#llazyquery) | New lazy query handle with the drop-nil step. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns a new dataframe with rows where a column is nil removed
  -- dropNil on a lazy query filters out rows where the column is nil.
  local df = lurek.dataframe.fromTable({{v=1},{v=nil},{v=3}})
  local result = df:lazy():dropNil("v"):collect()
  dataframe_log("rows after dropNil=" .. result:nrows())
  dataframe_log("first kept value=" .. tostring(result:getValue(1, "v")))
  dataframe_log("last kept value=" .. tostring(result:getValue(result:nrows(), "v")))
end
```

---

#### `LLazyQuery:filter`

Adds a filter step to the lazy query.

```lua
LLazyQuery:filter(col, op, val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name to filter. |
| `op` | string | Comparison operator string. |
| `val` | any | Filter comparison value. |

**Returns**

| Type | Description |
|------|-------------|
| [LLazyQuery](#llazyquery) | New lazy query handle with the filter step. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns a new dataframe with rows matching a condition (col op val)
  -- filter on a lazy query keeps only rows where the column matches the condition.
  local df = lurek.dataframe.fromTable({{level=5},{level=20},{level=35}})
  local result = df:lazy():filter("level", ">=", 15):collect()
  lurek.log.info("high-level rows: " .. result:nrows())
  lurek.log.info("lowest kept level: " .. tostring(result:getValue(1, "level")))
  lurek.log.info("highest kept level: " .. tostring(result:getValue(result:nrows(), "level")))
end
```

---

#### `LLazyQuery:head`

Adds a head limit step to the lazy query.

```lua
LLazyQuery:head(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | number | Number of leading rows to keep. |

**Returns**

| Type | Description |
|------|-------------|
| [LLazyQuery](#llazyquery) | New lazy query handle with the head step. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns a new dataframe with the first N rows (default 5)
  -- head on a lazy query limits to the first N rows at collect time.
  local df = lurek.dataframe.fromTable({{n=1},{n=2},{n=3},{n=4},{n=5}})
  local result = df:lazy():head(3):collect()
  dataframe_log("head rows=" .. result:nrows())
  dataframe_log("first preview row=" .. tostring(result:getValue(1, "n")))
  dataframe_log("head last preview row=" .. tostring(result:getValue(result:nrows(), "n")))
end
```

---

#### `LLazyQuery:limit`

Adds a row limit step to the lazy query.

```lua
LLazyQuery:limit(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | number | Maximum number of rows to keep. |

**Returns**

| Type | Description |
|------|-------------|
| [LLazyQuery](#llazyquery) | New lazy query handle with the limit step. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Adds a row limit step to the lazy query.
  local df = lurek.dataframe.fromTable({{n=1},{n=2},{n=3},{n=4},{n=5},{n=6}})
  local q = df:lazy():limit(5)
  local result = q:collect()
  example_print_log("rows after limit", result:nrows())
  example_print_log(result:toString())
end
```

---

#### `LLazyQuery:select`

Adds a column selection step to the lazy query.

```lua
LLazyQuery:select(cols)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cols` | table | Array table of column names to keep. |

**Returns**

| Type | Description |
|------|-------------|
| [LLazyQuery](#llazyquery) | New lazy query handle with the select step. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns a new dataframe with only the specified columns
  -- select on a lazy query projects only the specified columns.
  local df = lurek.dataframe.fromTable({{a=1, b=2, c=3}})
  local result = df:lazy():select({"a", "b"}):collect()
  dataframe_log("selected cols=" .. result:ncols())
  dataframe_log("first row a=" .. tostring(result:getValue(1, "a")))
  dataframe_log("first row b=" .. tostring(result:getValue(1, "b")))
end
```

---

#### `LLazyQuery:slice`

Adds a one-based row slice step to the lazy query.

```lua
LLazyQuery:slice(start, end_)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `start` | number | One-based start row. |
| `end_` | number | One-based end row. |

**Returns**

| Type | Description |
|------|-------------|
| [LLazyQuery](#llazyquery) | New lazy query handle with the slice step. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns a one-based inclusive row slice as a new dataframe
  -- slice on a lazy query extracts a 1-based inclusive row range.
  local df = lurek.dataframe.fromTable({{n=1},{n=2},{n=3},{n=4},{n=5}})
  local result = df:lazy():slice(2, 4):collect()
  dataframe_log("slice rows=" .. result:nrows())
  dataframe_log("slice starts at=" .. tostring(result:getValue(1, "n")))
  dataframe_log("slice ends at=" .. tostring(result:getValue(result:nrows(), "n")))
end
```

---

#### `LLazyQuery:sort`

Adds a sort step to the lazy query. This method is available to Lua scripts.

```lua
LLazyQuery:sort(col, ascending)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name to sort by. |
| `ascending?` | boolean | True for ascending order; defaults to true. |

**Returns**

| Type | Description |
|------|-------------|
| [LLazyQuery](#llazyquery) | New lazy query handle with the sort step. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns a new sorted dataframe by column (ascending or descending)
  -- sort on a lazy query orders rows by a column before collect.
  local df = lurek.dataframe.fromTable({{name="Cara",score=80},{name="Alice",score=95},{name="Bob",score=60}})
  local top = df:lazy():sort("score", false):collect()
  lurek.log.info("1st place: " .. top:getValue(1, "name"))
  lurek.log.info("1st score: " .. tostring(top:getValue(1, "score")))
  lurek.log.info("last score: " .. tostring(top:getValue(top:nrows(), "score")))
end
```

---

#### `LLazyQuery:tail`

Adds a tail limit step to the lazy query.

```lua
LLazyQuery:tail(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | number | Number of trailing rows to keep. |

**Returns**

| Type | Description |
|------|-------------|
| [LLazyQuery](#llazyquery) | New lazy query handle with the tail step. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns a new dataframe with the last N rows (default 5)
  -- tail on a lazy query keeps only the last N rows.
  local df = lurek.dataframe.fromTable({{n=1},{n=2},{n=3},{n=4},{n=5}})
  local result = df:lazy():tail(2):collect()
  dataframe_log("tail rows=" .. result:nrows())
  dataframe_log("tail first row=" .. tostring(result:getValue(1, "n")))
  dataframe_log("tail newest row=" .. tostring(result:getValue(result:nrows(), "n")))
end
```

---

#### `LLazyQuery:type`

Returns the Lua-visible type name for this lazy query handle.

```lua
LLazyQuery:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LLazyQuery](#llazyquery)`. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns the Lua-visible type name for this lazy query handle.
  local df = lurek.dataframe.fromTable({{x=1}})
  local lq = df:lazy()
  lurek.log.info("lazy type " .. tostring(lq:type()))
  lurek.log.info("is object " .. tostring(lq:typeOf("LObject")))
  lurek.log.info("source rows " .. tostring(df:nrows()))
end
```

---

#### `LLazyQuery:typeOf`

Returns whether this lazy query handle matches a supported type name.

```lua
LLazyQuery:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LLazyQuery](#llazyquery)`, `LazyQuery`, and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns whether this lazy query handle matches a supported type name.
  local df = lurek.dataframe.fromTable({{x=1}})
  local lq = df:lazy()
  lurek.log.info("is lazy query " .. tostring(lq:typeOf("LLazyQuery")))
  lurek.log.info("is object " .. tostring(lq:typeOf("LObject")))
  lurek.log.info("lazy type " .. tostring(lq:type()))
end
```

---

## LVecFrame

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LVecFrame:applyMask`

Returns a vectorized frame filtered by a boolean mask table.

```lua
LVecFrame:applyMask(mask_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mask_tbl` | table | Array table of booleans, one per row. |

**Returns**

| Type | Description |
|------|-------------|
| [LVecFrame](#lvecframe) | New vectorized frame containing masked rows. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns a new VecFrame containing only rows where mask is true
  -- applyMask returns a new VecFrame with only the rows where mask is true.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("hp\n10\n50\n90\n"))
  local mask = vf:filterMask("hp", ">=", 50)
  local alive = vf:applyMask(mask)
  lurek.log.info("alive rows: " .. alive:nrows())
  lurek.log.info("alive hp type: " .. alive:colType("hp"))
end
```

---

#### `LVecFrame:colAbs`

Applies absolute value to a numeric column in place.

```lua
LVecFrame:colAbs(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Applies absolute value to every cell in a numeric column (in-place)
  -- colAbs converts negative cells to their absolute value (in-place).
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("vel\n-3\n4\n-1\n"))
  vf:colAbs("vel")
  local df = vf:toDataFrame()
  lurek.log.info("speed[1]: " .. tostring(df:getValue(1, "vel")))
  lurek.log.info("speed[3]: " .. tostring(df:getValue(3, "vel")))
end
```

---

#### `LVecFrame:colAdd`

Adds a scalar to a numeric column in place.

```lua
LVecFrame:colAdd(col, val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name. |
| `val` | number | Scalar value to add. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Adds a scalar value to every cell in a numeric column (in-place)
  -- colAdd adds a scalar to every cell in a column (in-place).
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("score\n10\n20\n30\n"))
  vf:colAdd("score", 5)
  local df = vf:toDataFrame()
  lurek.log.info("score[1] after +5: " .. tostring(df:getValue(1, "score")))
  lurek.log.info("score[3] after +5: " .. tostring(df:getValue(3, "score")))
end
```

---

#### `LVecFrame:colCast`

Casts a vectorized column to another data type in place.

```lua
LVecFrame:colCast(col, dtype)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name. |
| `dtype` | string | Target data type name. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Casts a column to a different data type (e.g., "float64", "int64")
  -- colCast changes the internal storage type of a column.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("level\n1\n2\n3\n"))
  vf:colCast("level", "float64")
  lurek.log.info("level dtype after cast: " .. vf:colType("level"))
  lurek.log.info("level rows after cast: " .. tostring(vf:nrows()))
  lurek.log.info("vec type after cast: " .. tostring(vf:type()))
end
```

---

#### `LVecFrame:colCeil`

Applies ceil to a numeric column in place.

```lua
LVecFrame:colCeil(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Applies ceil (round up) to every cell in a numeric column (in-place)
  -- colCeil rounds every cell up to the nearest integer (in-place).
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("y\n1.1\n2.5\n3.0\n"))
  vf:colCeil("y")
  local df = vf:toDataFrame()
  lurek.log.info("ceiled y[1]: " .. tostring(df:getValue(1, "y")))
  lurek.log.info("ceiled y[2]: " .. tostring(df:getValue(2, "y")))
end
```

---

#### `LVecFrame:colClamp`

Clamps a numeric column in place. This method is available to Lua scripts.

```lua
LVecFrame:colClamp(col, min_val, max_val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name. |
| `min_val` | number | Minimum allowed value. |
| `max_val` | number | Maximum allowed value. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Clamps every cell in a numeric column to [min, max] range (in-place)
  -- colClamp enforces a [min, max] range on every cell (in-place).
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("hp\n-5\n50\n150\n"))
  vf:colClamp("hp", 0, 100)
  local df = vf:toDataFrame()
  lurek.log.info("clamped hp[1]: " .. tostring(df:getValue(1, "hp")))
  lurek.log.info("clamped hp[3]: " .. tostring(df:getValue(3, "hp")))
end
```

---

#### `LVecFrame:colDiv`

Divides a numeric column by a scalar in place.

```lua
LVecFrame:colDiv(col, val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name. |
| `val` | number | Scalar divisor. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Divides every cell in a numeric column by a scalar (in-place)
  -- colDiv divides every cell by a scalar (in-place).
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("score\n100\n200\n"))
  vf:colDiv("score", 200)
  local df = vf:toDataFrame()
  lurek.log.info("normalised[1]: " .. tostring(df:getValue(1, "score")))
  lurek.log.info("normalised[2]: " .. tostring(df:getValue(2, "score")))
end
```

---

#### `LVecFrame:colFloor`

Applies floor to a numeric column in place.

```lua
LVecFrame:colFloor(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Applies floor (round down) to every cell in a numeric column (in-place)
  -- colFloor rounds every cell down to the nearest integer (in-place).
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("x\n1.9\n2.1\n3.7\n"))
  vf:colFloor("x")
  local df = vf:toDataFrame()
  lurek.log.info("floored x[1]: " .. tostring(df:getValue(1, "x")))
  lurek.log.info("floored x[3]: " .. tostring(df:getValue(3, "x")))
end
```

---

#### `LVecFrame:colMul`

Multiplies a numeric column by a scalar in place.

```lua
LVecFrame:colMul(col, val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name. |
| `val` | number | Scalar multiplier. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Multiplies every cell in a numeric column by a scalar (in-place)
  -- colMul multiplies every cell in a column by a scalar (in-place).
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("dmg\n10\n20\n"))
  vf:colMul("dmg", 2.0)
  local df = vf:toDataFrame()
  lurek.log.info("dmg[1] doubled: " .. tostring(df:getValue(1, "dmg")))
  lurek.log.info("dmg[2] doubled: " .. tostring(df:getValue(2, "dmg")))
end
```

---

#### `LVecFrame:colNeg`

Negates a numeric column in place. This method is available to Lua scripts.

```lua
LVecFrame:colNeg(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Negates every cell in a numeric column (in-place)
  -- colNeg negates every cell (in-place), flipping the sign.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("vy\n3\n-2\n0\n"))
  vf:colNeg("vy")
  local df = vf:toDataFrame()
  lurek.log.info("bounced vy[1]: " .. tostring(df:getValue(1, "vy")))
  lurek.log.info("bounced vy[2]: " .. tostring(df:getValue(2, "vy")))
end
```

---

#### `LVecFrame:colOp`

Applies a binary column operation into an output column.

```lua
LVecFrame:colOp(out_col, left_col, op, right_col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `out_col` | string | Output column name. |
| `left_col` | string | Left input column name. |
| `op` | string | Binary operation name. |
| `right_col` | string | Right input column name. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Applies a binary operation between two columns, storing result in a new column
  -- colOp computes (col_a op col_b) per row into a new output column.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("atk,def\n30,10\n40,15\n"))
  vf:colOp("net", "atk", "sub", "def")
  local df = vf:toDataFrame()
  lurek.log.info("net[1]: " .. tostring(df:getValue(1, "net")))
  lurek.log.info("net[2]: " .. tostring(df:getValue(2, "net")))
end
```

---

#### `LVecFrame:colSqrt`

Applies square root to a numeric column in place.

```lua
LVecFrame:colSqrt(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Applies square root to every cell in a numeric column (in-place)
  -- colSqrt applies square root to every cell (in-place).
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("d2\n9\n16\n25\n"))
  vf:colSqrt("d2")
  local df = vf:toDataFrame()
  lurek.log.info("dist[1]: " .. tostring(df:getValue(1, "d2")))
  lurek.log.info("dist[3]: " .. tostring(df:getValue(3, "d2")))
end
```

---

#### `LVecFrame:colSub`

Subtracts a scalar from a numeric column in place.

```lua
LVecFrame:colSub(col, val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name. |
| `val` | number | Scalar value to subtract. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Subtracts a scalar from every cell in a numeric column (in-place)
  -- colSub subtracts a scalar from every cell (in-place).
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("stamina\n100\n80\n"))
  vf:colSub("stamina", 10)
  local df = vf:toDataFrame()
  lurek.log.info("stamina[1] after drain: " .. tostring(df:getValue(1, "stamina")))
  lurek.log.info("stamina[2] after drain: " .. tostring(df:getValue(2, "stamina")))
end
```

---

#### `LVecFrame:colType`

Returns the data type name for a vectorized column.

```lua
LVecFrame:colType(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name. |

**Returns**

| Type | Description |
|------|-------------|
| string | Column type name, or nil when the column is missing. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns the data type name of a vectorized column ("float64", "int64", "text", "bool")
  -- colType returns the internal data type of a column ("float64", "int64", etc.).
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("hp\n10\n20\n"))
  local dtype = vf:colType("hp")
  lurek.log.info("hp dtype: " .. dtype)
  lurek.log.info("vec type: " .. tostring(vf:type()))
  lurek.log.info("is vec frame: " .. tostring(vf:typeOf("LVecFrame")))
end
```

---

#### `LVecFrame:columns`

Returns all vectorized column names in order.

```lua
LVecFrame:columns()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Column names. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns an array table of column names in order
  -- columns() on a VecFrame returns the column name array.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("hp,mp\n10,5\n"))
  local cols = vf:columns()
  local rowCount = vf:nrows()
  dataframe_log("vec columns=" .. cols[1] .. "," .. cols[2])
  dataframe_log("row count=" .. rowCount)
end
```

---

#### `LVecFrame:filterMask`

Builds a boolean mask for a numeric column comparison.

```lua
LVecFrame:filterMask(col, cmp_op, val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name. |
| `cmp_op` | string | Comparison operation name. |
| `val` | number | Comparison value. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of boolean mask values. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Builds a boolean mask array from a column comparison
  -- filterMask builds a boolean mask array from a column comparison.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("hp\n10\n50\n90\n"))
  local mask = vf:filterMask("hp", ">=", 50)
  lurek.log.info("row 2 passes: " .. tostring(mask[2]))
  lurek.log.info("row 3 passes: " .. tostring(mask[3]))
  lurek.log.info("mask length: " .. tostring(#mask))
end
```

---

#### `LVecFrame:ncols`

Returns the number of columns in this vectorized frame.

```lua
LVecFrame:ncols()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Column count. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns the number of columns in this dataframe
  -- ncols on a VecFrame returns the column count.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("x,y\n1,2\n"))
  local cols = vf:columns()
  local rows = vf:nrows()
  dataframe_log("vec cols=" .. vf:ncols() .. " rows=" .. rows)
  dataframe_log("schema=" .. cols[1] .. "," .. cols[2])
end
```

---

#### `LVecFrame:nrows`

Returns the number of rows in this vectorized frame.

```lua
LVecFrame:nrows()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Row count. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns the number of rows in this dataframe
  -- nrows on a VecFrame returns the row count, same as on DataFrame.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("v\n1\n2\n3\n"))
  local cols = vf:columns()
  local asDf = vf:toDataFrame()
  dataframe_log("vec rows=" .. vf:nrows() .. " cols=" .. vf:ncols())
  dataframe_log("first column=" .. cols[1] .. " first value=" .. tostring(asDf:getValue(1, "v")))
end
```

---

#### `LVecFrame:parReduce`

Reduces multiple numeric columns in parallel.

```lua
LVecFrame:parReduce(cols_tbl, op)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cols_tbl` | table | Array table of column names. |
| `op` | string | Reduction operation name. |

**Returns**

| Type | Description |
|------|-------------|
| table | Table mapping column names to reduction results or nil. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Reduces multiple columns in parallel using a named operation
  -- parReduce reduces multiple columns in parallel using a named operation.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("hp,mp\n10,5\n20,10\n30,15\n"))
  local sums = vf:parReduce({"hp", "mp"}, "sum")
  lurek.log.info("hp sum: " .. tostring(sums["hp"]))
  lurek.log.info("mp sum: " .. tostring(sums["mp"]))
  lurek.log.info("reduced cols: " .. tostring(vf:ncols()))
end
```

---

#### `LVecFrame:parScalarOp`

Applies a scalar operation to multiple numeric columns in parallel.

```lua
LVecFrame:parScalarOp(cols_tbl, op, val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cols_tbl` | table | Array table of column names. |
| `op` | string | Scalar operation name. |
| `val` | number | Scalar value used by the operation. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Applies a scalar operation to multiple columns in parallel
  -- parScalarOp applies a scalar operation to multiple columns in parallel.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("x,y\n1,2\n3,4\n"))
  vf:parScalarOp({"x", "y"}, "mul", 2.0)
  local df = vf:toDataFrame()
  lurek.log.info("x[1] doubled: " .. tostring(df:getValue(1, "x")))
  lurek.log.info("y[1] doubled: " .. tostring(df:getValue(1, "y")))
end
```

---

#### `LVecFrame:reduce`

Reduces a numeric column with a named operation.

```lua
LVecFrame:reduce(col, op)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | string | Column name. |
| `op` | string | Reduction operation name. |

**Returns**

| Type | Description |
|------|-------------|
| number | Reduction result. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Reduces a numeric column to a single value using a named operation
  -- reduce aggregates a column to one value using a named operation.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("score\n10\n20\n30\n"))
  local total = vf:reduce("score", "sum")
  lurek.log.info("total score: " .. total)
  lurek.log.info("max score: " .. tostring(vf:reduce("score", "max")))
  lurek.log.info("score rows: " .. tostring(vf:nrows()))
end
```

---

#### `LVecFrame:toDataFrame`

Converts this vectorized frame to a dataframe.

```lua
LVecFrame:toDataFrame()
```

**Returns**

| Type | Description |
|------|-------------|
| [LDataFrame](#ldataframe) | New dataframe handle. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Converts this VecFrame back to a regular DataFrame
  -- toDataFrame converts this VecFrame back to a regular DataFrame.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("v\n1\n2\n3\n"))
  vf:colAdd("v", 10)
  local df = vf:toDataFrame()
  lurek.log.info("v[1] after +10: " .. tostring(df:getValue(1, "v")))
  lurek.log.info("v rows after convert: " .. tostring(df:nrows()))
end
```

---

#### `LVecFrame:type`

Returns the Lua-visible type name for this vectorized frame handle.

```lua
LVecFrame:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LVecFrame](#lvecframe)`. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns the type name string "DataFrame" for this handle
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("v\n1\n"))
  local typeName = vf:type()
  local isObject = vf:typeOf("LObject")
  dataframe_log("vec type=" .. typeName)
  dataframe_log("typeOf object=" .. tostring(isObject))
end
```

---

#### `LVecFrame:typeOf`

Returns whether this vectorized frame handle matches a supported type name.

```lua
LVecFrame:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `VecFrame` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local function dataframe_log(message)
      lurek.log.info("[dataframe.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

-- Returns true if this handle matches the given type name
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("v\n1\n"))
  local isVec = vf:typeOf("LVecFrame")
  local isObject = vf:typeOf("LObject")
  dataframe_log("is vec frame=" .. tostring(isVec))
  dataframe_log("is object=" .. tostring(isObject))
end
```

---
