-- content/examples/dataframe.lua
-- lurek.dataframe API examples: tabular data for analytics, leaderboards, item databases, and stat tracking.
-- Run: cargo run -- content/examples/dataframe.lua

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

--@api: lurek.dataframe.newDataFrame
do
-- Creates an empty dataframe with no columns or rows
  -- newDataFrame builds an empty frame; define columns before inserting rows.
  local df = lurek.dataframe.newDataFrame()
  df:addColumn("name", "")
  df:addColumn("score", 0)
  df:addRow({name = "Alice", score = 1200})
  dataframe_log("scoreboard rows=" .. df:nrows() .. " cols=" .. df:ncols())
  dataframe_log("first player=" .. df:getValue(1, "name"))
end
--@api: LDataFrame:addColumn
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
--@api: lurek.dataframe.newDatabase
do
-- Creates an empty dataframe database for managing multiple named tables
  -- newDatabase returns an empty container for named dataframes.
  local db = lurek.dataframe.newDatabase()
  local players = lurek.dataframe.fromTable({{id = 1, name = "Alice", level = 12}})
  db:addTable("players", players)
  dataframe_log("database tables=" .. db:tableCount())
  dataframe_log("has players=" .. tostring(db:hasTable("players")))
end
--@api: LDatabase:addTable
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
--@api: lurek.dataframe.fromTable
do
-- Creates a dataframe from an array of row tables (most common constructor)
  -- fromTable converts a Lua array-of-row-tables into a dataframe.
  local df = lurek.dataframe.fromTable({{name = "Goblin", hp = 30}, {name = "Orc", hp = 60}})
  local strongest = df:sort("hp", false)
  local firstRow = df:getRow(1)
  dataframe_log("enemy table rows=" .. df:nrows() .. " cols=" .. df:ncols())
  dataframe_log("strongest enemy=" .. strongest:getValue(1, "name"))
  dataframe_log("first row enemy=" .. firstRow.name)
end
--@api: LfromTable:nrows
do
  -- fromTable is the fastest way to create a dataframe from existing Lua data.
  -- Each element is a table mapping column names to values.
  -- All rows should share the same keys; missing keys become nil.
  local enemies = lurek.dataframe.fromTable({
    {name = "goblin",  hp = 30,  atk = 5,  xp = 10},
    {name = "orc",     hp = 60,  atk = 12, xp = 25},
    {name = "dragon",  hp = 500, atk = 80, xp = 1000},
  })

  -- Useful for loading static game data defined in Lua tables
  lurek.log.info("enemy database: " .. enemies:nrows() .. " entries")
end
--@api: lurek.dataframe.fromRows
do
-- Creates a dataframe from column names and positional row arrays
  -- fromRows maps column names to positional arrays; no key look-up overhead.
  local df = lurek.dataframe.fromRows({"name", "hp"}, {{"Goblin", 30}, {"Orc", 60}})
  local upgraded = df:clone()
  upgraded:addColumn("status", "idle")
  dataframe_log("spawn plan rows=" .. df:nrows() .. " cols=" .. df:ncols())
  dataframe_log("upgraded schema cols=" .. upgraded:ncols())
end
--@api: LfromRows:getValue
do
  -- fromRows is useful when data comes in array form (e.g., from a binary protocol)
  -- where you know column order but rows lack named keys.
  local columns = {"rank", "player", "score", "time_ms"}
  local rows = {
    {1, "Alice",  9500, 42300},
    {2, "Bob",    8200, 51200},
    {3, "Cara",   7800, 48100},
  }

  -- Column names map 1:1 with array positions in each row
  local leaderboard = lurek.dataframe.fromRows(columns, rows)
  lurek.log.info("rank #2: " .. leaderboard:getValue(2, "player"))
end
--@api: lurek.dataframe.fromCSV
do
-- Parses a dataframe from CSV-formatted text
  -- fromCSV parses CSV text; the first line becomes column headers.
  local df = lurek.dataframe.fromCSV("name,hp\nGoblin,30\nOrc,60\n")
  local names = df:select("name")
  local top = df:sort("hp", false)
  dataframe_log("csv import rows=" .. df:nrows() .. " cols=" .. df:ncols())
  dataframe_log("name preview=" .. names:getValue(2, "name"))
  dataframe_log("top hp enemy=" .. top:getValue(1, "name"))
end
--@api: LfromCSV:mean
do
  -- fromCSV is ideal for loading exported spreadsheet data or config tables.
  -- The first line is treated as column headers.
  local csv = "weapon,damage,cost,rarity\nsword,12,50,common\nbow,8,40,common\nstaff,15,120,rare\n"
  local shop = lurek.dataframe.fromCSV(csv)

  -- Numeric columns are auto-detected, so you can immediately compute stats
  local avgDamage = shop:mean("damage")
  local avgCost = shop:mean("cost")
  dataframe_log("avg weapon damage=" .. avgDamage)
  dataframe_log("avg shop cost=" .. avgCost)
end
--@api: lurek.dataframe.fromJSON
do
-- Parses a dataframe from a JSON array of objects
  -- fromJSON parses a JSON array of objects into a dataframe.
  local df = lurek.dataframe.fromJSON('[{"name":"Goblin","hp":30},{"name":"Orc","hp":60}]')
  local top = df:sort("hp", false)
  local row = df:getRow(2)
  dataframe_log("json import rows=" .. df:nrows() .. " cols=" .. df:ncols())
  dataframe_log("boss preview=" .. top:getValue(1, "name"))
  dataframe_log("second row enemy=" .. row.name)
end
--@api: LfromJSON:nrows
do
  -- fromJSON handles data from web APIs or save files stored as JSON.
  -- Expects a JSON array where each element is an object with consistent keys.
  local json = '[{"id":1,"name":"Alice","guild":"Phoenix"},{"id":2,"name":"Bob","guild":"Shadow"}]'
  local roster = lurek.dataframe.fromJSON(json)

  local first = roster:getRow(1)
  dataframe_log("guild roster members=" .. roster:nrows())
  dataframe_log("first guild member=" .. first.name .. " of " .. first.guild)
end
--@api: lurek.dataframe.fromBinary
do
-- Deserializes a dataframe from its compact binary format
  -- fromBinary restores a dataframe that was serialised with toBinary().
  local src = lurek.dataframe.fromTable({{x = 1, y = 2}})
  local df = lurek.dataframe.fromBinary(src:toBinary())
  local row = df:getRow(1)
  dataframe_log("binary restore rows=" .. df:nrows())
  dataframe_log("restored point=" .. tostring(row.x) .. "," .. tostring(row.y))
end
--@api: LfromTable:toBinary
do
  -- toBinary/fromBinary is the fastest serialization for save/load cycles.
  -- Binary format preserves exact types and is smaller than CSV or JSON.
  local original = lurek.dataframe.fromTable({
    {x = 1.5, y = 2.3, entity = "player"},
    {x = 4.0, y = 7.1, entity = "npc"},
  })

  -- Serialize to binary blob (suitable for file I/O or network transfer)
  local blob = original:toBinary()

  -- Restore the exact same dataframe structure
  local restored = lurek.dataframe.fromBinary(blob)
  lurek.log.info("restored " .. restored:nrows() .. " entities from binary")
end
--@api: lurek.dataframe.random
do
-- Generates a random dataframe from column type definitions
  -- random generates test data using column type hints and an optional seed.
  local df = lurek.dataframe.random({{"id", "id"}, {"hp", "int"}}, 10, 1)
  local sample = df:head(2)
  local cols = df:columns()
  dataframe_log("random mob rows=" .. df:nrows())
  dataframe_log("sample first id=" .. tostring(sample:getValue(1, "id")))
  dataframe_log("random schema=" .. table.concat(cols, ","))
end
--@api: Lrandom:nrows
do
  -- random() is great for testing, procedural generation, or populating mock data.
  -- Column defs: each entry is {column_name, type_hint}.
  -- Supported hints: "id" (sequential int), "int" (random integer), "float" (random float), "name" (random name), "bool".
  local defs = {
    {"mob_id", "id"},      -- sequential 1, 2, 3...
    {"hp", "int"},         -- random integers
    {"speed", "float"},    -- random floats
    {"name", "name"},      -- random name strings
  }

  -- Generate 100 random mobs with seed 42 for reproducibility
  local mob_pool = lurek.dataframe.random(defs, 100, 42)
  lurek.log.info("generated " .. mob_pool:nrows() .. " random mobs")
end
--@api: LVecFrame:nrows
do
-- Returns the number of rows in this dataframe
  -- nrows on a VecFrame returns the row count, same as on DataFrame.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("v\n1\n2\n3\n"))
  local cols = vf:columns()
  local asDf = vf:toDataFrame()
  dataframe_log("vec rows=" .. vf:nrows() .. " cols=" .. vf:ncols())
  dataframe_log("first column=" .. cols[1] .. " first value=" .. tostring(asDf:getValue(1, "v")))
end
--@api: LfromTable:getValue
do
  -- Use nrows to check if a dataframe has data before processing
  local df = lurek.dataframe.fromTable({{name = "Alice"}, {name = "Bob"}, {name = "Cara"}})

  -- Common pattern: guard against empty frames before accessing values
  if df:nrows() > 0 then
    local firstName = df:getValue(1, "name")
    local lastName = df:getValue(df:nrows(), "name")
    dataframe_log("first player=" .. firstName)
    dataframe_log("last player=" .. lastName)
  end
end
--@api: LVecFrame:ncols
do
-- Returns the number of columns in this dataframe
  -- ncols on a VecFrame returns the column count.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("x,y\n1,2\n"))
  local cols = vf:columns()
  local rows = vf:nrows()
  dataframe_log("vec cols=" .. vf:ncols() .. " rows=" .. rows)
  dataframe_log("schema=" .. cols[1] .. "," .. cols[2])
end
--@api: LfromTable:ncols
do
  -- ncols tells you how wide the schema is.
  -- Useful for dynamic rendering (e.g., how many columns to draw in a HUD table).
  local df = lurek.dataframe.fromTable({{x = 1, y = 2, z = 3, w = 4}})

  -- Iterate columns by index to build dynamic headers
  for i = 1, df:ncols() do
    dataframe_log("column " .. i .. " = " .. df:columns()[i])
  end
  dataframe_log("total columns=" .. df:ncols())
end
--@api: LVecFrame:columns
do
-- Returns an array table of column names in order
  -- columns() on a VecFrame returns the column name array.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("hp,mp\n10,5\n"))
  local cols = vf:columns()
  local rowCount = vf:nrows()
  dataframe_log("vec columns=" .. cols[1] .. "," .. cols[2])
  dataframe_log("row count=" .. rowCount)
end
--@api: LfromTable:columns
do
  -- columns() gives you the schema as a string array.
  -- Useful for rendering table headers or validating imported data.
  local df = lurek.dataframe.fromTable({{hp = 100, mp = 50, stamina = 80}})
  local headers = df:columns()

  -- headers = {"hp", "mp", "stamina"} (order matches creation)
  for _, name in ipairs(headers) do
    lurek.log.info("stat: " .. name)
  end
end
--@api: LDataFrame:count
do
-- Returns the total count of non-nil items in this dataframe
  local df = lurek.dataframe.fromTable({{a = 1, b = 2}, {a = 3, b = 4}})
  local count = df:count()
  local firstRow = df:getRow(1)
  dataframe_log("row count=" .. count)
  dataframe_log("first row a=" .. tostring(firstRow.a) .. " b=" .. tostring(firstRow.b))
end
--@api: LfromTable:count
do
  local df = lurek.dataframe.fromTable({
    {event = "kill", ts = 1.0},
    {event = "death", ts = 2.5},
    {event = "kill", ts = 3.2},
  })
  local row_count = df:count()
  example_print_log("tracked rows", row_count)
  example_print_log("first event", df:getValue(1, "event"))
end
--@api: LDataFrame:removeColumn
do
-- Removes a column from this dataframe by name or index
  -- removeColumn drops a named column, reducing ncols by one.
  local df = lurek.dataframe.fromTable({{name = "Alice", internal = "x7", score = 100}})
  df:removeColumn("internal")
  local cols = df:columns()
  dataframe_log("cols after remove=" .. df:ncols())
  dataframe_log("remaining schema=" .. table.concat(cols, ","))
end
--@api: LfromTable:removeColumn
do
  -- Use removeColumn to strip sensitive or unnecessary data before export.
  -- Example: remove internal IDs before showing a leaderboard to players.
  local df = lurek.dataframe.fromTable({
    {name = "Alice", internal_id = "a7f3", score = 9500},
    {name = "Bob", internal_id = "b2c1", score = 8200},
  })

  -- Remove the internal field before serializing for display
  df:removeColumn("internal_id")
  lurek.log.info(df:toCSV())
end
--@api: LDataFrame:rename
do
-- Renames a column (by name or index) to a new name
  -- rename changes a column header without touching its data.
  local df = lurek.dataframe.fromTable({{pts = 100}})
  df:rename("pts", "score")
  local row = df:getRow(1)
  dataframe_log("renamed column=" .. df:columns()[1])
  dataframe_log("value survived=" .. tostring(df:getValue(1, "score")))
  dataframe_log("row score=" .. tostring(row.score))
end
--@api: LfromCSV:rename
do
  -- rename() is useful when loading external data with unfriendly headers.
  -- CSV exports often have spaces or abbreviations that need normalizing.
  local df = lurek.dataframe.fromCSV("Player Name,Pts,W/L\nAlice,1200,15/3\n")

  -- Normalize column names for easier programmatic access
  df:rename("Player Name", "name")
  df:rename("Pts", "points")
  local row = df:getRow(1)
  dataframe_log("first column is now=" .. df:columns()[1])
  dataframe_log("normalized player=" .. row.name .. " points=" .. tostring(row.points))
end
--@api: LDataFrame:getColumn
do
-- Returns all values in a column as an array table
  -- getColumn extracts all values in a named column as a plain Lua array.
  local df = lurek.dataframe.fromTable({{hp = 10}, {hp = 20}, {hp = 30}})
  local vals = df:getColumn("hp")
  local sum = vals[1] + vals[2] + vals[3]
  dataframe_log("hp[2]=" .. vals[2])
  dataframe_log("column sum=" .. sum)
end
--@api: LfromTable:getColumn
do
  -- getColumn extracts a full column as a plain Lua array.
  -- Useful for feeding data into chart rendering or custom calculations.
  local df = lurek.dataframe.fromTable({
    {frame = 1, ms = 16.2},
    {frame = 2, ms = 15.8},
    {frame = 3, ms = 33.1},  -- spike!
  })

  -- Get all frame times for plotting or anomaly detection
  local times = df:getColumn("ms")
  lurek.log.info("frame times: " .. times[1] .. ", " .. times[2] .. ", " .. times[3])
end
--@api: LDataFrame:addRow
do
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
--@api: LDataFrame:addRow.2
do
  -- addRow is the primary way to insert data at runtime.
  -- Returns the new row's 1-based index, useful for immediate reference.
  local event_log = lurek.dataframe.newDataFrame()
  event_log:addColumn("event", "")
  event_log:addColumn("timestamp", 0)
  event_log:addColumn("player", "")

  -- Log a game event; the returned index lets you reference this row later
  local idx = event_log:addRow({event = "boss_kill", timestamp = 125.4, player = "Alice"})
  lurek.log.info("logged event at row " .. idx)
end
--@api: LDataFrame:removeRow
do
-- Removes a row by one-based index
  -- removeRow deletes one record by 1-based index; later rows shift down.
  local df = lurek.dataframe.fromTable({{n = 1}, {n = 2}, {n = 3}})
  df:removeRow(2)
  local first = df:getValue(1, "n")
  dataframe_log("rows after remove=" .. df:nrows())
  dataframe_log("new second row=" .. tostring(df:getValue(2, "n")))
  dataframe_log("first row still=" .. tostring(first))
end
--@api: LfromTable:removeRow
do
  -- removeRow deletes a specific entry. Rows after it shift down.
  -- Example: removing a disconnected player from the active roster.
  local roster = lurek.dataframe.fromTable({
    {name = "Alice", status = "active"},
    {name = "Bob", status = "disconnected"},
    {name = "Cara", status = "active"},
  })

  -- Remove the disconnected player (row 2)
  roster:removeRow(2)
  lurek.log.info("active players: " .. roster:nrows())
end
--@api: LDataFrame:getRow
do
-- Returns a row as a table keyed by column name
  -- getRow returns one record as a {col = value} Lua table.
  local df = lurek.dataframe.fromTable({{name = "Alice", hp = 80}})
  local row = df:getRow(1)
  local summary = row.name .. " hp=" .. row.hp
  dataframe_log(summary)
  dataframe_log("row keys=" .. table.concat(df:columns(), ","))
end
--@api: LfromTable:getRow
do
  -- getRow returns a single row as {col_name = value, ...}.
  -- Useful for reading one entity's full record.
  local inventory = lurek.dataframe.fromTable({
    {slot = 1, item = "Health Potion", qty = 5},
    {slot = 2, item = "Iron Sword", qty = 1},
  })

  -- Read slot 1 as a full record
  local slot1 = inventory:getRow(1)
  lurek.log.info(slot1.item .. " x" .. slot1.qty)
end
--@api: LDataFrame:getValue
do
-- Returns one cell value by row index and column reference
  -- getValue reads one cell by 1-based row index and column name.
  local df = lurek.dataframe.fromTable({{name = "Alice", score = 950}})
  local score = df:getValue(1, "score")
  local player = df:getValue(1, "name")
  dataframe_log("score=" .. tostring(score))
  dataframe_log("player=" .. tostring(player) .. " type=" .. df:type())
end
--@api: LfromTable:getValue.2
do
  -- getValue is the fastest way to read a single cell.
  -- Use it in tight loops or conditional checks.
  local df = lurek.dataframe.fromTable({
    {name = "Alice", hp = 80, max_hp = 100},
    {name = "Bob", hp = 15, max_hp = 100},
  })

  -- Check if any player is critically low
  for i = 1, df:nrows() do
    local hp = df:getValue(i, "hp")
    if hp < 30 then
      lurek.log.warn(df:getValue(i, "name") .. " is critically low: " .. hp .. " HP")
    end
  end
end
--@api: LLazyQuery:head
do
-- Returns a new dataframe with the first N rows (default 5)
  -- head on a lazy query limits to the first N rows at collect time.
  local df = lurek.dataframe.fromTable({{n=1},{n=2},{n=3},{n=4},{n=5}})
  local result = df:lazy():head(3):collect()
  dataframe_log("head rows=" .. result:nrows())
  dataframe_log("first preview row=" .. tostring(result:getValue(1, "n")))
  dataframe_log("head last preview row=" .. tostring(result:getValue(result:nrows(), "n")))
end
--@api: Lrandom:head
do
  -- head() is useful for previewing large datasets or showing "top N" results.
  local scores = lurek.dataframe.random({{"rank", "id"}, {"score", "int"}}, 100, 1)

  -- Preview the first 3 entries
  local top3 = scores:head(3)
  dataframe_log("top3 rows=" .. top3:nrows())
  dataframe_log("top3 first rank=" .. tostring(top3:getValue(1, "rank")))
  dataframe_log("top3 first score=" .. tostring(top3:getValue(1, "score")))
end
--@api: LLazyQuery:tail
do
-- Returns a new dataframe with the last N rows (default 5)
  -- tail on a lazy query keeps only the last N rows.
  local df = lurek.dataframe.fromTable({{n=1},{n=2},{n=3},{n=4},{n=5}})
  local result = df:lazy():tail(2):collect()
  dataframe_log("tail rows=" .. result:nrows())
  dataframe_log("tail first row=" .. tostring(result:getValue(1, "n")))
  dataframe_log("tail newest row=" .. tostring(result:getValue(result:nrows(), "n")))
end
--@api: Lrandom:tail
do
  -- tail() shows the most recent entries. Ideal for event logs or chat history.
  local events = lurek.dataframe.random({{"timestamp", "int"}, {"event", "name"}}, 50, 7)

  -- Show the 5 most recent events
  local recent = events:tail(5)
  dataframe_log("recent rows=" .. recent:nrows())
  dataframe_log("oldest row in tail=" .. tostring(recent:getValue(1, "timestamp")))
  dataframe_log("newest event=" .. tostring(recent:getValue(recent:nrows(), "event")))
end
--@api: LLazyQuery:slice
do
-- Returns a one-based inclusive row slice as a new dataframe
  -- slice on a lazy query extracts a 1-based inclusive row range.
  local df = lurek.dataframe.fromTable({{n=1},{n=2},{n=3},{n=4},{n=5}})
  local result = df:lazy():slice(2, 4):collect()
  dataframe_log("slice rows=" .. result:nrows())
  dataframe_log("slice starts at=" .. tostring(result:getValue(1, "n")))
  dataframe_log("slice ends at=" .. tostring(result:getValue(result:nrows(), "n")))
end
--@api: Lrandom:slice
do
  -- slice(start, end) extracts a range of rows. Both indices are inclusive.
  -- Great for pagination in a UI list.
  local all_items = lurek.dataframe.random({{"id", "id"}, {"name", "name"}, {"price", "int"}}, 100, 2)

  -- Page 2 of a 10-items-per-page list: rows 11 through 20
  local page2 = all_items:slice(11, 20)
  dataframe_log("page2 rows=" .. page2:nrows())
  dataframe_log("page2 first id=" .. tostring(page2:getValue(1, "id")))
  dataframe_log("page2 last price=" .. tostring(page2:getValue(page2:nrows(), "price")))
end
--@api: LLazyQuery:select
do
-- Returns a new dataframe with only the specified columns
  -- select on a lazy query projects only the specified columns.
  local df = lurek.dataframe.fromTable({{a=1, b=2, c=3}})
  local result = df:lazy():select({"a", "b"}):collect()
  dataframe_log("selected cols=" .. result:ncols())
  dataframe_log("first row a=" .. tostring(result:getValue(1, "a")))
  dataframe_log("first row b=" .. tostring(result:getValue(1, "b")))
end
--@api: LfromTable:select
do
  -- select() projects specific columns, discarding the rest.
  -- Useful for creating a "view" that only shows relevant fields.
  local full_data = lurek.dataframe.fromTable({
    {name = "Alice", hp = 80, mp = 30, x = 12.5, y = -3.2, internal_state = 7},
  })

  -- HUD only needs name, hp, mp -- hide position and internal data
  local hud_view = full_data:select("name", "hp", "mp")
  lurek.log.info(hud_view:toString())
end
--@api: LDataFrame:unique
do
-- Returns unique values from a column as an array table
  -- unique returns the distinct values of one column as a Lua array.
  local df = lurek.dataframe.fromTable({{cls="warrior"},{cls="mage"},{cls="warrior"}})
  local types = df:unique("cls")
  dataframe_log("distinct classes=" .. #types)
  dataframe_log("first distinct=" .. tostring(types[1]))
  dataframe_log("last distinct=" .. tostring(types[#types]))
end
--@api: LfromTable:unique
do
  -- unique() extracts distinct values. Useful for building filter dropdowns
  -- or counting how many different enemy types exist.
  local spawns = lurek.dataframe.fromTable({
    {type = "goblin", zone = "forest"},
    {type = "orc", zone = "mountain"},
    {type = "goblin", zone = "cave"},
    {type = "dragon", zone = "mountain"},
  })

  local enemy_types = spawns:unique("type")
  lurek.log.info("distinct enemy types: " .. #enemy_types)
end
--@api: LDataFrame:groupBy
do
-- Groups rows by column value; returns a table of {key = sub-dataframe}
  -- groupBy splits the frame into per-key sub-dataframes in a Lua table.
  local df = lurek.dataframe.fromTable({
    {team="red",pts=10},{team="blue",pts=20},{team="red",pts=5}
  })
  local groups = df:groupBy("team")
  lurek.log.info("red team rows: " .. groups["red"]:nrows())
end
--@api: LfromTable:groupBy
do
  -- groupBy splits a dataframe into sub-frames keyed by column value.
  -- Perfect for per-team stats, per-zone analysis, etc.
  local match_data = lurek.dataframe.fromTable({
    {team = "red",  player = "Alice", kills = 10},
    {team = "blue", player = "Bob",   kills = 7},
    {team = "red",  player = "Cara",  kills = 5},
    {team = "blue", player = "Dave",  kills = 12},
  })

  -- Split into per-team dataframes
  local by_team = match_data:groupBy("team")
  lurek.log.info("red team players: " .. by_team["red"]:nrows())
  lurek.log.info("blue team players: " .. by_team["blue"]:nrows())
end

--@api: LDataFrame:countBy
do
-- Counts occurrences of each value in a column; returns a new dataframe
  -- countBy builds a frequency table: one row per distinct value in the column.
  local df = lurek.dataframe.fromTable({{item="sword"},{item="bow"},{item="sword"}})
  local freq = df:countBy("item")
  local cols = freq:columns()
  dataframe_log("frequency rows=" .. freq:nrows())
  dataframe_log("top key column=" .. cols[1] .. " value=" .. tostring(freq:getValue(1, cols[1])))
end
--@api: LfromTable:countBy
do
  -- countBy creates a frequency table. Useful for finding the most common item,
  -- most-picked weapon, or most-visited zone.
  local loot_drops = lurek.dataframe.fromTable({
    {item = "potion"}, {item = "gold"}, {item = "potion"},
    {item = "gem"}, {item = "gold"}, {item = "potion"},
  })

  -- Result has columns: the grouped column and "count"
  local freq = loot_drops:countBy("item")
  lurek.log.info("loot frequency:\n" .. freq:toString())
end
--@api: LLazyQuery:dropNil
do
-- Returns a new dataframe with rows where a column is nil removed
  -- dropNil on a lazy query filters out rows where the column is nil.
  local df = lurek.dataframe.fromTable({{v=1},{v=nil},{v=3}})
  local result = df:lazy():dropNil("v"):collect()
  dataframe_log("rows after dropNil=" .. result:nrows())
  dataframe_log("first kept value=" .. tostring(result:getValue(1, "v")))
  dataframe_log("last kept value=" .. tostring(result:getValue(result:nrows(), "v")))
end
--@api: LfromTable:dropNil
do
  -- dropNil filters out incomplete records.
  -- Common when optional fields are missing for some entries.
  local survey = lurek.dataframe.fromTable({
    {player = "Alice", rating = 5},
    {player = "Bob", rating = nil},   -- Bob didn't answer
    {player = "Cara", rating = 4},
  })

  -- Only process rows where rating is present
  local valid = survey:dropNil("rating")
  lurek.log.info("valid responses: " .. valid:nrows())
end
--@api: LDataFrame:sample
do
-- Returns a random subset of N rows (optional seed for reproducibility)
  -- sample picks N random rows without replacement; seed for reproducibility.
  local src = lurek.dataframe.random({{"id","id"}}, 100, 1)
  local subset = src:sample(10, 42)
  dataframe_log("sampled rows=" .. subset:nrows())
  dataframe_log("sample first id=" .. tostring(subset:getValue(1, "id")))
  dataframe_log("sample last id=" .. tostring(subset:getValue(subset:nrows(), "id")))
end
--@api: Lrandom:sample
do
  -- sample() picks random rows without replacement.
  -- Useful for random encounters, test subsets, or A/B testing.
  local all_mobs = lurek.dataframe.random({{"id", "id"}, {"hp", "int"}, {"name", "name"}}, 1000, 9)

  -- Pick 50 random mobs for this dungeon floor (seed 123 for consistent generation)
  local floor_mobs = all_mobs:sample(50, 123)
  dataframe_log("spawning mobs=" .. floor_mobs:nrows())
  dataframe_log("first sampled mob=" .. tostring(floor_mobs:getValue(1, "name")))
  dataframe_log("first sampled hp=" .. tostring(floor_mobs:getValue(1, "hp")))
end
--@api: LDataFrame:describe
do
-- Returns summary statistics (count, mean, std, min, max) for numeric columns
  -- describe returns a summary-stats frame (min, max, mean, std per numeric col).
  local df = lurek.dataframe.fromTable({{v=1},{v=2},{v=3},{v=4},{v=5}})
  local stats = df:describe()
  dataframe_log("describe rows=" .. stats:nrows())
  dataframe_log("describe cols=" .. stats:ncols())
  dataframe_log("describe first label=" .. tostring(stats:getValue(1, "stat")))
end
--@api: Lrandom:describe
do
  -- describe() gives you a quick statistical overview of your data.
  -- Returns a dataframe where rows are statistics and columns are your numeric fields.
  local combat_log = lurek.dataframe.random({{"damage", "int"}, {"heal", "int"}}, 200, 11)

  -- Get min, max, mean, std for damage and heal at a glance
  local summary = combat_log:describe()
  dataframe_log("combat summary rows=" .. summary:nrows())
  dataframe_log("combat summary cols=" .. summary:ncols())
  dataframe_log("combat first stat=" .. tostring(summary:getValue(1, "stat")))
end
--@api: LDataFrame:sum
do
-- Returns the numeric sum of a column
  -- sum totals all values in a numeric column.
  local df = lurek.dataframe.fromTable({{dmg=10},{dmg=20},{dmg=5}})
  local total = df:sum("dmg")
  dataframe_log("total damage=" .. total)
  dataframe_log("average hit=" .. tostring(df:mean("dmg")))
  dataframe_log("highest hit=" .. tostring(df:max("dmg")))
end
--@api: LfromTable:sum
do
  -- sum() totals all values in a numeric column.
  -- Use for total damage dealt, total gold earned, total distance traveled, etc.
  local hits = lurek.dataframe.fromTable({
    {source = "sword", dmg = 12},
    {source = "fireball", dmg = 45},
    {source = "arrow", dmg = 8},
  })

  local total_damage = hits:sum("dmg")
  lurek.log.info("total damage this combo: " .. total_damage)
end
--@api: LDataFrame:mean
do
-- Returns the arithmetic mean of a numeric column
  -- mean computes the arithmetic average of a numeric column.
  local df = lurek.dataframe.fromTable({{ms=16},{ms=17},{ms=33}})
  local avg = df:mean("ms")
  dataframe_log("avg ms=" .. avg)
  dataframe_log("slowest frame=" .. tostring(df:max("ms")))
  dataframe_log("frame samples=" .. tostring(df:nrows()))
end
--@api: LfromTable:mean
do
  -- mean() computes the average. Useful for performance monitoring or balance analysis.
  local frame_stats = lurek.dataframe.fromTable({
    {frame = 1, dt_ms = 16.1},
    {frame = 2, dt_ms = 16.4},
    {frame = 3, dt_ms = 32.0},  -- dropped frame
    {frame = 4, dt_ms = 15.9},
  })

  local avg_dt = frame_stats:mean("dt_ms")
  lurek.log.info("average frame time: " .. string.format("%.1f", avg_dt) .. " ms")
end
--@api: LDataFrame:min
do
-- Returns the minimum value of a column
  -- min returns the smallest value in a numeric column.
  local df = lurek.dataframe.fromTable({{t=140},{t=138},{t=145}})
  local best = df:min("t")
  dataframe_log("best time=" .. best)
  dataframe_log("attempt count=" .. df:nrows())
  dataframe_log("worst time=" .. tostring(df:max("t")))
end
--@api: LfromTable:min
do
  -- min() finds the smallest value. Useful for best scores, fastest times, lowest prices.
  local speedrun = lurek.dataframe.fromTable({
    {attempt = 1, time_s = 142.5},
    {attempt = 2, time_s = 138.2},
    {attempt = 3, time_s = 145.0},
  })

  local best = speedrun:min("time_s")
  lurek.log.info("personal best: " .. best .. "s")
end
--@api: LDataFrame:max
do
-- Returns the maximum value of a column
  -- max returns the largest value in a numeric column.
  local df = lurek.dataframe.fromTable({{s=100},{s=450},{s=380}})
  local high = df:max("s")
  dataframe_log("high score=" .. high)
  dataframe_log("lowest score=" .. tostring(df:min("s")))
  dataframe_log("score samples=" .. tostring(df:nrows()))
end
--@api: LfromTable:max
do
  -- max() finds the largest value. Use for high scores, max damage, peak values.
  local season_scores = lurek.dataframe.fromTable({
    {week = 1, score = 1200},
    {week = 2, score = 4500},
    {week = 3, score = 3800},
  })

  local high_score = season_scores:max("score")
  lurek.log.info("season high score: " .. high_score)
end
--@api: LDataFrame:median
do
-- Returns the median (middle value) of a numeric column
  -- median returns the middle value and is robust against outliers.
  local df = lurek.dataframe.fromTable({{ms=16},{ms=16},{ms=17},{ms=200}})
  local typical = df:median("ms")
  dataframe_log("typical ms=" .. typical)
  dataframe_log("outlier max=" .. tostring(df:max("ms")))
  dataframe_log("sample count=" .. tostring(df:nrows()))
end
--@api: LfromTable:median
do
  -- median() is robust against outliers unlike mean().
  -- Use it for "typical" frame time or "typical" damage output.
  local frame_times = lurek.dataframe.fromTable({
    {ms = 16}, {ms = 16}, {ms = 17}, {ms = 200},  -- one huge spike
  })

  -- median (16.5) is much more representative than mean (~62)
  local typical = frame_times:median("ms")
  lurek.log.info("typical frame time: " .. typical .. " ms")
end
--@api: LDataFrame:stddev
do
-- Returns the standard deviation of a numeric column
  -- stddev measures the spread of values in a numeric column.
  local df = lurek.dataframe.fromTable({{v=10},{v=20},{v=30},{v=40}})
  local spread = df:stddev("v")
  dataframe_log("stddev=" .. string.format("%.1f", spread))
  dataframe_log("variance=" .. string.format("%.1f", df:variance("v")))
  dataframe_log("mean=" .. string.format("%.1f", df:mean("v")))
end
--@api: Lrandom:stddev
do
  -- stddev() measures spread. Low stddev = consistent performance; high = erratic.
  local perf = lurek.dataframe.random({{"frame_ms", "int"}}, 60, 3)

  local spread = perf:stddev("frame_ms")
  lurek.log.info("frame time stddev: " .. string.format("%.2f", spread) .. " ms")
  lurek.log.info("frame time mean: " .. string.format("%.2f", perf:mean("frame_ms")) .. " ms")
  lurek.log.info("sampled frames: " .. perf:nrows())
end
--@api: LDataFrame:variance
do
-- Returns the variance of a numeric column
  -- variance is stddev squared; used in statistical formulas.
  local df = lurek.dataframe.fromTable({{v=10},{v=20},{v=30}})
  local variance = df:variance("v")
  dataframe_log("variance=" .. variance)
  dataframe_log("stddev=" .. tostring(df:stddev("v")))
  dataframe_log("mean=" .. tostring(df:mean("v")))
end
--@api: Lrandom:variance
do
  -- variance() is stddev squared. Useful in statistical formulas.
  -- High variance in damage output = inconsistent weapon balance.
  local hits = lurek.dataframe.random({{"dmg", "int"}}, 100, 4)

  local v = hits:variance("dmg")
  lurek.log.info("damage variance: " .. string.format("%.1f", v))
  lurek.log.info("mean damage: " .. string.format("%.1f", hits:mean("dmg")))
  lurek.log.info("sampled hits: " .. hits:nrows())
end
--@api: LDataFrame:fillNil
do
-- Replaces nil cells in a column with a specified value
  -- fillNil replaces nil cells with a default so aggregations don't fail.
  local df = lurek.dataframe.fromTable({{s=10},{s=nil},{s=5}})
  df:fillNil("s", 0)
  dataframe_log("sum after fill=" .. df:sum("s"))
  dataframe_log("middle score=" .. tostring(df:getValue(2, "s")))
  dataframe_log("mean after fill=" .. tostring(df:mean("s")))
end
--@api: LfromTable:fillNil
do
  -- fillNil patches missing data with a default.
  -- Use before computations that would fail on nil values.
  local scores = lurek.dataframe.fromTable({
    {player = "Alice", score = 10},
    {player = "Bob", score = nil},   -- Bob crashed mid-game
    {player = "Cara", score = 5},
  })

  -- Replace nil with 0 so sum/mean work correctly
  scores:fillNil("score", 0)
  lurek.log.info("total score after fill: " .. scores:sum("score"))
end
--@api: LDataFrame:toCSV
do
-- Serializes this dataframe to CSV text
  -- toCSV serialises the frame to CSV text with a header row.
  local df = lurek.dataframe.fromTable({{name="Alice",score=100}})
  local csv = df:toCSV()
  dataframe_log("CSV bytes=" .. #csv)
  dataframe_log("csv has header=" .. tostring(string.find(csv, "name,score", 1, true) ~= nil))
  dataframe_log("csv has row=" .. tostring(string.find(csv, "Alice", 1, true) ~= nil))
end
--@api: LfromTable:Year
do
  -- toCSV creates a string suitable for file export or clipboard copy.
  -- First row is column headers, subsequent rows are values.
  local leaderboard = lurek.dataframe.fromTable({
    {rank = 1, name = "Alice", score = 9500},
    {rank = 2, name = "Bob", score = 8200},
  })

  local csv = leaderboard:toCSV()
  -- Write to disk if filesystem is available
  if lurek.fs then lurek.fs.write("save/leaderboard.csv", csv) end
  lurek.log.info("exported CSV: " .. #csv .. " bytes")
end
--@api: LDatabase:toJSON
do
-- Serializes this dataframe to a JSON array of objects
  -- toJSON on a Database serialises all its tables to a JSON string.
  local db = lurek.dataframe.newDatabase()
  db:addTable("scores", lurek.dataframe.fromTable({{v=1}}))
  local json = db:toJSON()
  local tables = db:listTables()
  dataframe_log("database JSON bytes=" .. #json)
  dataframe_log("tables exported=" .. table.concat(tables, ","))
end
--@api: LfromTable:toJSON.2
do
  -- toJSON produces a JSON string for web API output or inter-process communication.
  local save_data = lurek.dataframe.fromTable({
    {slot = 1, name = "World 1", playtime = 3600},
    {slot = 2, name = "World 2", playtime = 1200},
  })

  local json = save_data:toJSON()
  if lurek.fs then lurek.fs.write("save/slots.json", json) end
  lurek.log.info("exported JSON: " .. #json .. " bytes")
end
--@api: LDataFrame:toBinary
do
-- Serializes this dataframe to a compact binary format
  -- toBinary produces the most compact serialisation format.
  local df = lurek.dataframe.fromTable({{x=1.5,y=2.3}})
  local blob = df:toBinary()
  local restored = lurek.dataframe.fromBinary(blob)
  dataframe_log("binary bytes=" .. #blob)
  dataframe_log("restored rows=" .. restored:nrows())
end
--@api: LfromTable:toBinary.2
do
  -- toBinary is the most space-efficient and fastest serialization.
  -- Use it for autosave, network sync, or large dataset caching.
  local world_state = lurek.dataframe.fromTable({
    {entity_id = 1, x = 10.5, y = 20.3, hp = 100},
    {entity_id = 2, x = -5.0, y = 12.7, hp = 45},
  })

  local blob = world_state:toBinary()
  if lurek.fs then lurek.fs.write("save/world.lvdf", blob) end
  lurek.log.info("binary size: " .. #blob .. " bytes")
end
--@api: LDataFrame:toTable
do
-- Converts this dataframe to a plain Lua array of row tables
  -- toTable converts the frame back to a plain Lua array-of-row-tables.
  local df = lurek.dataframe.fromTable({{name="Alice",hp=80}})
  local rows = df:toTable()
  dataframe_log("first row name=" .. rows[1].name)
  dataframe_log("row count=" .. #rows)
  dataframe_log("first row hp=" .. tostring(rows[1].hp))
end
--@api: LfromTable:toTable
do
  -- toTable() gives you back raw Lua tables for custom processing.
  -- Use when you need to iterate with Lua-native patterns.
  local df = lurek.dataframe.fromTable({
    {name = "Alice", hp = 80},
    {name = "Bob", hp = 50},
  })

  local rows = df:toTable()
  -- rows is now a plain Lua array: {{name="Alice", hp=80}, {name="Bob", hp=50}}
  for _, row in ipairs(rows) do
    lurek.log.info(row.name .. " has " .. row.hp .. " HP")
  end
end
--@api: LDataFrame:rows
do
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
--@api: LfromTable:rows
do
  -- rows() provides a generic-for iterator that yields (index, row_table).
  -- More idiomatic than manual index loops for sequential processing.
  local party = lurek.dataframe.fromTable({
    {name = "Alice", role = "tank", hp = 120},
    {name = "Bob", role = "healer", hp = 60},
    {name = "Cara", role = "dps", hp = 80},
  })

  -- Iterate all party members with their position index
  for i, member in party:rows() do
    lurek.log.info("#" .. i .. " " .. member.name .. " (" .. member.role .. ")")
  end
end
--@api: LDataFrame:toString
do
-- Formats this dataframe as a human-readable aligned text table
  -- toString formats the frame as an aligned text table for debug output.
  local df = lurek.dataframe.fromTable({{name="Alice",hp=80}})
  local text = df:toString()
  dataframe_log("frame text bytes=" .. #text)
  dataframe_log("frame type=" .. df:type())
  dataframe_log("text contains name=" .. tostring(string.find(text, "Alice", 1, true) ~= nil))
end
--@api: LfromTable:toString
do
  -- toString() produces a pretty-printed table for debug output or console display.
  local party = lurek.dataframe.fromTable({
    {name = "Alice", hp = 80, class = "warrior"},
    {name = "Bob", hp = 50, class = "mage"},
  })

  -- Great for lurek.log.info during development
  lurek.log.info("party:\n" .. party:toString())
end
--@api: LDatabase:query
do
-- Runs a SQL SELECT query against this dataframe (table alias is "t")
  -- query on a Database runs SQL that can reference all registered tables.
  local db = lurek.dataframe.newDatabase()
  db:addTable("players", lurek.dataframe.fromTable({{name="Alice",hp=80},{name="Bob",hp=20}}))
  local result = db:query("SELECT name FROM players WHERE hp < 50")
  dataframe_log("low-hp players=" .. result:nrows())
  dataframe_log("first wounded=" .. tostring(result:getValue(1, "name")))
end
--@api: LfromTable:query
do
  -- query() lets you use SQL syntax for complex filtering and projection.
  -- The dataframe is exposed as table "t" in the SQL context.
  local players = lurek.dataframe.fromTable({
    {name = "Alice", hp = 80, level = 12},
    {name = "Bob", hp = 20, level = 5},
    {name = "Cara", hp = 45, level = 8},
  })

  -- Find players with low HP who might need healing
  local wounded = players:query("SELECT name, hp FROM t WHERE hp < 50")
  lurek.log.info("wounded players: " .. wounded:nrows())
end
--@api: LDataFrame:clone
do
-- Returns a deep copy of this dataframe (modifications don't affect the original)
  -- clone returns a deep copy; mutations to the copy don't affect the original.
  local base = lurek.dataframe.fromTable({{stat="atk",value=10}})
  local copy = base:clone()
  copy:setValue(1, "value", 99)
  dataframe_log("base atk=" .. base:getValue(1,"value") .. " copy=" .. copy:getValue(1,"value"))
  dataframe_log("copy rows=" .. copy:nrows())
end
--@api: LfromTable:clone
do
  -- clone() creates an independent copy. Essential when you want to modify
  -- data without corrupting the original (e.g., "what-if" simulations).
  local base_stats = lurek.dataframe.fromTable({
    {stat = "atk", value = 10},
    {stat = "def", value = 8},
  })

  -- Create a buffed copy for simulation without touching base_stats
  local buffed = base_stats:clone()
  buffed:setValue(1, "value", 15)  -- boost attack in the copy only
  lurek.log.info("base atk=" .. base_stats:getValue(1, "value") ..
                 " buffed atk=" .. buffed:getValue(1, "value"))
end
--@api: LDataFrame:correlationMatrix
do
-- Returns a correlation matrix dataframe for all numeric columns
  -- correlationMatrix shows pairwise linear correlation between numeric columns.
  local df = lurek.dataframe.fromTable({{a=1,b=2},{a=2,b=4},{a=3,b=6}})
  local matrix = df:correlationMatrix()
  dataframe_log("correlation matrix cols=" .. matrix:ncols())
  dataframe_log("correlation rows=" .. matrix:nrows())
  dataframe_log("matrix first label=" .. tostring(matrix:getValue(1, "column")))
end
--@api: Lrandom:correlationMatrix
do
  -- correlationMatrix shows how numeric columns relate to each other.
  -- Values near 1 or -1 indicate strong correlation (useful for game balance).
  local balance = lurek.dataframe.random({{"damage", "int"}, {"cost", "int"}, {"weight", "int"}}, 50, 5)

  -- Check if high-damage weapons are also the most expensive (should they be?)
  local matrix = balance:correlationMatrix()
  dataframe_log("correlation rows=" .. matrix:nrows())
  dataframe_log("correlation cols=" .. matrix:ncols())
  dataframe_log("matrix first label=" .. tostring(matrix:getValue(1, "column")))
end
--@api: LDataFrame:modeVal
do
-- Returns the most frequently occurring value in a column
  -- modeVal returns the most frequently occurring value in a column.
  local df = lurek.dataframe.fromTable({{w="sword"},{w="bow"},{w="sword"},{w="staff"},{w="sword"}})
  local mode = df:modeVal("w")
  dataframe_log("most popular=" .. tostring(mode))
  dataframe_log("dataframe type=" .. df:type())
  dataframe_log("unique choices=" .. tostring(#df:unique("w")))
end
--@api: LfromTable:modeVal
do
  -- modeVal finds the most common value (the "mode" in statistics).
  -- Useful for finding the most popular weapon, most common drop, etc.
  local weapon_picks = lurek.dataframe.fromTable({
    {match = 1, weapon = "sword"},
    {match = 2, weapon = "bow"},
    {match = 3, weapon = "sword"},
    {match = 4, weapon = "staff"},
    {match = 5, weapon = "sword"},
  })

  local most_popular = weapon_picks:modeVal("weapon")
  lurek.log.info("most picked weapon: " .. tostring(most_popular))
end
--@api: LDataFrame:entropy
do
-- Returns the Shannon entropy of a column (measures diversity)
  -- entropy quantifies value diversity (bits); 0 = all same, high = many different.
  local df = lurek.dataframe.fromTable({{cls="warrior"},{cls="mage"},{cls="rogue"}})
  local entropy = df:entropy("cls")
  dataframe_log("class entropy=" .. string.format("%.2f", entropy))
  dataframe_log("dataframe type=" .. df:type())
  dataframe_log("class count=" .. tostring(df:nrows()))
end
--@api: LfromTable:entropy
do
  -- entropy() quantifies how "spread out" values are.
  -- High entropy = diverse picks; low entropy = dominated by one value.
  -- Useful for measuring class balance in multiplayer games.
  local class_picks = lurek.dataframe.fromTable({
    {class = "warrior"}, {class = "mage"}, {class = "warrior"},
    {class = "rogue"}, {class = "mage"}, {class = "healer"},
  })

  local h = class_picks:entropy("class")
  lurek.log.info("class diversity (entropy): " .. string.format("%.2f", h) .. " bits")
end
--@api: LDataFrame:addRowBatch
do
-- Appends multiple rows at once from positional arrays (faster than repeated addRow)
  -- addRowBatch inserts multiple rows at once; faster than repeated addRow.
  local df = lurek.dataframe.newDataFrame()
  df:addColumn("x", 0)
  df:addColumn("y", 0)
  df:addRowBatch({{1, 2}, {3, 4}, {5, 6}})
  lurek.log.info("rows after batch: " .. df:nrows())
end
--@api: LDataFrame:nrows.2
do
  -- addRowBatch is significantly faster than calling addRow in a loop.
  -- Rows are arrays matching column order (not keyed tables).
  local positions = lurek.dataframe.newDataFrame()
  positions:addColumn("x", 0)
  positions:addColumn("y", 0)
  positions:addColumn("entity_id", 0)

  -- Batch-insert 3 positions at once (order matches columns: x, y, entity_id)
  positions:addRowBatch({
    {10.5, 20.0, 1},
    {-3.0,  5.5, 2},
    { 0.0, -1.0, 3},
  })
  lurek.log.info("entities tracked: " .. positions:nrows())
end
--@api: LDataFrame:getColumnAsF64
do
-- Returns a numeric column as an array of Lua numbers (float64)
  -- getColumnAsF64 extracts a numeric column as a flat Lua number array.
  local df = lurek.dataframe.fromTable({{hp=10},{hp=20},{hp=30}})
  local vals = df:getColumnAsF64("hp")
  dataframe_log("hp[1]=" .. vals[1])
  dataframe_log("hp[3]=" .. vals[3])
  dataframe_log("hp sample count=" .. tostring(#vals))
end
--@api: Lrandom:getColumnAsF64
do
  -- getColumnAsF64 extracts numeric data as a flat number array.
  -- Useful for feeding into math functions or VecFrame operations.
  local df = lurek.dataframe.random({{"hp", "int"}}, 16, 6)

  -- Returns a plain array of numbers
  local hp_values = df:getColumnAsF64("hp")
  dataframe_log("first entity HP=" .. hp_values[1])
  dataframe_log("sample count=" .. #hp_values)
  dataframe_log("last entity HP=" .. hp_values[#hp_values])
end
--@api: LDataFrame:setColumnFromF64
do
-- Replaces a numeric column's values from an array of numbers
  -- setColumnFromF64 bulk-writes computed numbers back into a column.
  local df = lurek.dataframe.fromTable({{x=0},{x=0},{x=0}})
  df:setColumnFromF64("x", {1.5, 2.5, 3.5})
  dataframe_log("sum x=" .. df:sum("x"))
  dataframe_log("last x=" .. tostring(df:getValue(3, "x")))
  dataframe_log("mean x=" .. tostring(df:mean("x")))
end
--@api: LfromTable:setColumnFromF64
do
  -- setColumnFromF64 bulk-writes computed values back into a column.
  -- Use after external math processing.
  local df = lurek.dataframe.fromTable({{x = 0}, {x = 0}, {x = 0}})

  -- Overwrite the "x" column with computed values
  df:setColumnFromF64("x", {1.5, 2.5, 3.5})
  dataframe_log("sum of x after set=" .. df:sum("x"))
  dataframe_log("first x after set=" .. tostring(df:getValue(1, "x")))
  dataframe_log("last x after set=" .. tostring(df:getValue(3, "x")))
end
--@api: LVecFrame:type
do
-- Returns the type name string "DataFrame" for this handle
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("v\n1\n"))
  local typeName = vf:type()
  local isObject = vf:typeOf("LObject")
  dataframe_log("vec type=" .. typeName)
  dataframe_log("typeOf object=" .. tostring(isObject))
end
--@api: LDataFrame:type
do
  local df = lurek.dataframe.newDataFrame()
  local typeName = df:type()
  local matches = typeName == "LDataFrame"
  dataframe_log("dataframe type=" .. typeName)
  dataframe_log("confirmed dataframe handle=" .. tostring(matches))
end
--@api: LVecFrame:typeOf
do
-- Returns true if this handle matches the given type name
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("v\n1\n"))
  local isVec = vf:typeOf("LVecFrame")
  local isObject = vf:typeOf("LObject")
  dataframe_log("is vec frame=" .. tostring(isVec))
  dataframe_log("is object=" .. tostring(isObject))
end
--@api: LDataFrame:typeOf
do
  local df = lurek.dataframe.newDataFrame()
  local isObject = df:typeOf("LObject")
  local isFrame = df:typeOf("LDataFrame")
  dataframe_log("dataframe is object=" .. tostring(isObject))
  dataframe_log("dataframe is frame=" .. tostring(isFrame))
end
--@api: LDataFrame:withEval
do
-- Returns a new dataframe with an added column computed from an expression
  -- withEval adds a derived column computed row-by-row from an expression.
  local df = lurek.dataframe.fromTable({{atk=10,bonus=4},{atk=15,bonus=2}})
  local result = df:withEval("eff", "atk + bonus")
  dataframe_log("eff[1]=" .. result:getValue(1, "eff"))
  dataframe_log("best eff=" .. tostring(result:max("eff")))
  dataframe_log("eff rows=" .. tostring(result:nrows()))
end
--@api: LfromTable:withEval
do
  -- withEval creates a derived column using a math expression referencing other columns.
  -- The expression is evaluated row-by-row in the Rust engine (fast).
  local weapons = lurek.dataframe.fromTable({
    {name = "sword", atk = 10, bonus = 4},
    {name = "axe", atk = 15, bonus = 2},
    {name = "dagger", atk = 6, bonus = 8},
  })

  -- Compute effective damage: atk + bonus * 1.5 (applied per row)
  local with_eff = weapons:withEval("effective_dmg", "atk + bonus * 1.5")
  lurek.log.info("best effective damage: " .. with_eff:max("effective_dmg"))
end
--@api: LDatabase:getTable
do
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
--@api: LDatabase:getTable.2
do
  -- getTable retrieves a dataframe by its registered name.
  -- Returns nil if the name doesn't exist, so always check.
  local db = lurek.dataframe.newDatabase()
  db:addTable("players", lurek.dataframe.fromTable({{name = "Alice", level = 10}}))

  local players = db:getTable("players")
  if players then
    lurek.log.info("players table has " .. players:nrows() .. " rows")
  end
end
--@api: LDatabase:removeTable
do
-- Removes a named table from the database
  -- removeTable deletes a named table; useful for session cleanup.
  local db = lurek.dataframe.newDatabase()
  db:addTable("temp", lurek.dataframe.newDataFrame())
  db:removeTable("temp")
  dataframe_log("tables after remove=" .. db:tableCount())
  dataframe_log("has temp=" .. tostring(db:hasTable("temp")))
end
--@api: LDatabase:tableCount.2
do
  -- removeTable deletes a table by name. Use for cleanup or session resets.
  local db = lurek.dataframe.newDatabase()
  db:addTable("temp_cache", lurek.dataframe.newDataFrame())

  -- Clean up temporary data
  db:removeTable("temp_cache")
  dataframe_log("tables remaining=" .. db:tableCount())
  dataframe_log("temp cache exists=" .. tostring(db:hasTable("temp_cache")))
end
--@api: LDatabase:hasTable
do
-- Returns true if the database contains a table with the given name
  -- hasTable returns true when the named table is registered.
  local db = lurek.dataframe.newDatabase()
  db:addTable("scores", lurek.dataframe.newDataFrame())
  dataframe_log("has scores=" .. tostring(db:hasTable("scores")))
  dataframe_log("has items=" .. tostring(db:hasTable("items")))
  dataframe_log("table count=" .. tostring(db:tableCount()))
end
--@api: LDatabase:addTable.2
do
  -- hasTable lets you check before inserting to avoid overwriting.
  local db = lurek.dataframe.newDatabase()

  -- Only create the scores table if it doesn't already exist
  if not db:hasTable("scores") then
    db:addTable("scores", lurek.dataframe.newDataFrame())
    lurek.log.info("created scores table")
  end
end
--@api: LDatabase:listTables
do
-- Returns an array of all table names in the database
  -- listTables returns all registered table names as a Lua array.
  local db = lurek.dataframe.newDatabase()
  db:addTable("players", lurek.dataframe.newDataFrame())
  db:addTable("items", lurek.dataframe.newDataFrame())
  local names = db:listTables()
  dataframe_log("tables=" .. table.concat(names, ", "))
  dataframe_log("table count=" .. #names)
end
--@api: LDatabase:listTables.2
do
  -- listTables gives you the full schema of the database.
  -- Useful for debug UIs or save-game inspection tools.
  local db = lurek.dataframe.newDatabase()
  db:addTable("players", lurek.dataframe.newDataFrame())
  db:addTable("items", lurek.dataframe.newDataFrame())
  db:addTable("quests", lurek.dataframe.newDataFrame())

  for _, name in ipairs(db:listTables()) do
    lurek.log.info("table: " .. name)
  end
end
--@api: LDatabase:tableCount
do
-- Returns the number of tables in this database
  -- tableCount returns the number of tables registered in this database.
  local db = lurek.dataframe.newDatabase()
  db:addTable("a", lurek.dataframe.newDataFrame())
  db:addTable("b", lurek.dataframe.newDataFrame())
  dataframe_log("table count=" .. db:tableCount())
  dataframe_log("has a=" .. tostring(db:hasTable("a")))
end
--@api: LDatabase:tableCount.3
do
  -- tableCount is a quick way to check if the database is populated.
  local db = lurek.dataframe.newDatabase()
  db:addTable("scores", lurek.dataframe.newDataFrame())
  db:addTable("config", lurek.dataframe.newDataFrame())

  if db:tableCount() > 0 then
    lurek.log.info("database has " .. db:tableCount() .. " tables")
  end
end
--@api: LDatabase:clear
do
-- Removes all tables from this database
  -- clear removes all tables, resetting the database to empty.
  local db = lurek.dataframe.newDatabase()
  db:addTable("round1", lurek.dataframe.newDataFrame())
  local before = db:tableCount()
  db:clear()
  dataframe_log("tables before clear=" .. before)
  dataframe_log("tables after clear=" .. db:tableCount())
end
--@api: LDatabase:tableCount.4
do
  -- clear() wipes the database for a fresh start (e.g., new game session).
  local db = lurek.dataframe.newDatabase()
  db:addTable("round1", lurek.dataframe.newDataFrame())
  db:addTable("round2", lurek.dataframe.newDataFrame())

  -- Reset for a new session
  db:clear()
  lurek.log.info("database cleared, tables=" .. db:tableCount())
end
--@api: LDatabase:merge
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
--@api: LDatabase:tableCount.5
do
  -- merge() combines two databases. Tables with same name get overwritten.
  -- Useful for loading mod data on top of base data.
  local base = lurek.dataframe.newDatabase()
  base:addTable("weapons", lurek.dataframe.fromTable({{name = "sword", dmg = 10}}))

  local mod_data = lurek.dataframe.newDatabase()
  mod_data:addTable("extra_weapons", lurek.dataframe.fromTable({{name = "laser", dmg = 99}}))

  -- Mod's tables are added into the base database
  base:merge(mod_data)
  lurek.log.info("after mod merge: " .. base:tableCount() .. " tables")
end
--@api: LGroupedFrame:aggregate
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
  example_print_log("aggregate rows", result:nrows())
  example_print_log(result:toString())
end
--@api: LDataFrame:lazy.2
do
  local df = lurek.dataframe.newDataFrame()
  df:addColumn("damage", 0)
  df:addColumn("class", "")
  df:addRow({damage = 12, class = "warrior"})
  df:addRow({damage = 8, class = "mage"})
  df:addRow({damage = 20, class = "warrior"})
  df:addRow({damage = 5, class = "mage"})

  local grouped = df:groupByObj("class")
  local result = grouped:aggregate("damage", function(vals)
    local sum = 0
    for _, value in ipairs(vals) do
      sum = sum + value
    end
    return sum / #vals
  end)
  example_print_log("grouped aggregate")
  example_print_log(result:toString())
end
--@api: LDataFrame:groupByObj
do
-- Groups rows by a column and returns a GroupedFrame object
  local df = lurek.dataframe.fromTable({
    {region="EU",score=100},{region="NA",score=200},{region="EU",score=150}
  })
  local grouped = df:groupByObj("region")
  example_print_log("grouped type", grouped:type())
end
--@api: LDataFrame:groupByObj.2
do
  local df = lurek.dataframe.newDataFrame()
  df:addColumn("score", 0)
  df:addColumn("region", "")
  df:addRow({score = 100, region = "EU"})
  df:addRow({score = 200, region = "NA"})
  df:addRow({score = 150, region = "EU"})

  local grouped = df:groupByObj("region")
  example_print_log("is grouped frame", grouped:typeOf("LGroupedFrame"))
  example_print_log("grouped handle", tostring(grouped))
end
--@api: lurek.dataframe.toVec
do
-- Converts a dataframe to a vectorized VecFrame for bulk numeric operations
  -- toVec converts a DataFrame to a VecFrame optimised for bulk numeric ops.
  local df = lurek.dataframe.fromCSV("hp,mp\n100,50\n200,80\n")
  local vf = lurek.dataframe.toVec(df)
  lurek.log.info("VecFrame rows: " .. vf:nrows())
  lurek.log.info("VecFrame cols: " .. vf:ncols())
  lurek.log.info("VecFrame hp type: " .. vf:colType("hp"))
end
--@api: LfromCSV:nrows
do
  -- toVec() converts a DataFrame into a VecFrame optimized for batch math.
  -- All numeric operations on VecFrame run in Rust without per-cell Lua overhead.
  local df = lurek.dataframe.fromCSV("hp,mp,stamina\n100,50,80\n200,80,60\n150,60,90\n")

  -- Convert to VecFrame for fast bulk processing
  local vf = lurek.dataframe.toVec(df)
  lurek.log.info("VecFrame: " .. vf:nrows() .. " rows, " .. vf:ncols() .. " cols")
  lurek.log.info("stamina type: " .. vf:colType("stamina"))
  lurek.log.info("hp total via vec reduce: " .. tostring(vf:reduce("hp", "sum")))
end
--@api: lurek.dataframe.fromVec
do
-- Converts a VecFrame back to a regular DataFrame
  -- fromVec converts a VecFrame back to a regular DataFrame.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("hp\n100\n200\n"))
  vf:colMul("hp", 0.5)
  local df = lurek.dataframe.fromVec(vf)
  lurek.log.info("hp after reduction: " .. tostring(df:getValue(1, "hp")))
  lurek.log.info("converted rows: " .. df:nrows())
end
--@api: LfromCSV:colMul
do
  -- fromVec() is the inverse of toVec().
  -- After performing fast bulk operations, convert back to DataFrame for display/query.
  local df = lurek.dataframe.fromCSV("hp,mp\n100,50\n200,80\n")
  local vf = lurek.dataframe.toVec(df)

  -- Apply a damage reduction to all HP values at once
  vf:colMul("hp", 0.5)

  -- Convert back to DataFrame for normal operations
  local result = lurek.dataframe.fromVec(vf)
  lurek.log.info("HP after 50% reduction: " .. tostring(result:getValue(1, "hp")))
end
--@api: LVecFrame:colAdd
do
-- Adds a scalar value to every cell in a numeric column (in-place)
  -- colAdd adds a scalar to every cell in a column (in-place).
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("score\n10\n20\n30\n"))
  vf:colAdd("score", 5)
  local df = vf:toDataFrame()
  lurek.log.info("score[1] after +5: " .. tostring(df:getValue(1, "score")))
  lurek.log.info("score[3] after +5: " .. tostring(df:getValue(3, "score")))
end
--@api: LtoVec:colAdd
do
  -- colAdd shifts all values up by a constant. Use for buffs, offsets, or adjustments.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("score\n10\n20\n30\n"))

  -- Give everyone a +5 bonus (runs in Rust, no Lua loop)
  vf:colAdd("score", 5)

  local df = vf:toDataFrame()
  lurek.log.info("score after +5 bonus: " .. tostring(df:getValue(1, "score")))  -- 15
  lurek.log.info("team total after bonus: " .. tostring(df:sum("score")))
end
--@api: LVecFrame:colMul
do
-- Multiplies every cell in a numeric column by a scalar (in-place)
  -- colMul multiplies every cell in a column by a scalar (in-place).
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("dmg\n10\n20\n"))
  vf:colMul("dmg", 2.0)
  local df = vf:toDataFrame()
  lurek.log.info("dmg[1] doubled: " .. tostring(df:getValue(1, "dmg")))
  lurek.log.info("dmg[2] doubled: " .. tostring(df:getValue(2, "dmg")))
end
--@api: LtoVec:colMul
do
  -- colMul scales all values. Use for damage multipliers, difficulty scaling, etc.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("dmg\n10\n15\n20\n"))

  -- Apply a 1.5x critical hit multiplier to all damage values
  vf:colMul("dmg", 1.5)

  local df = vf:toDataFrame()
  lurek.log.info("crit damage: " .. tostring(df:getValue(1, "dmg")))  -- 15
  lurek.log.info("crit total damage: " .. tostring(df:sum("dmg")))
end
--@api: LVecFrame:colClamp
do
-- Clamps every cell in a numeric column to [min, max] range (in-place)
  -- colClamp enforces a [min, max] range on every cell (in-place).
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("hp\n-5\n50\n150\n"))
  vf:colClamp("hp", 0, 100)
  local df = vf:toDataFrame()
  lurek.log.info("clamped hp[1]: " .. tostring(df:getValue(1, "hp")))
  lurek.log.info("clamped hp[3]: " .. tostring(df:getValue(3, "hp")))
end
--@api: LtoVec:colClamp
do
  -- colClamp enforces bounds. Essential for HP (0 to max), percentages (0 to 100), etc.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("hp\n-5\n50\n150\n"))

  -- Ensure HP stays in valid range [0, 100]
  vf:colClamp("hp", 0, 100)

  local df = vf:toDataFrame()
  lurek.log.info("clamped: " .. tostring(df:getValue(1, "hp")) .. ", "
    .. tostring(df:getValue(3, "hp")))  -- 0, 100
end
--@api: LVecFrame:colAbs
do
-- Applies absolute value to every cell in a numeric column (in-place)
  -- colAbs converts negative cells to their absolute value (in-place).
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("vel\n-3\n4\n-1\n"))
  vf:colAbs("vel")
  local df = vf:toDataFrame()
  lurek.log.info("speed[1]: " .. tostring(df:getValue(1, "vel")))
  lurek.log.info("speed[3]: " .. tostring(df:getValue(3, "vel")))
end
--@api: LtoVec:colAbs
do
  -- colAbs converts negatives to positives. Useful for distances or magnitudes.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("velocity\n-3\n4\n-1\n"))

  -- Get speed (magnitude) from velocity (which can be negative)
  vf:colAbs("velocity")

  local df = vf:toDataFrame()
  lurek.log.info("speed values: " .. tostring(df:getValue(1, "velocity")))  -- 3
  lurek.log.info("speed max: " .. tostring(df:max("velocity")))
end
--@api: LVecFrame:colSqrt
do
-- Applies square root to every cell in a numeric column (in-place)
  -- colSqrt applies square root to every cell (in-place).
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("d2\n9\n16\n25\n"))
  vf:colSqrt("d2")
  local df = vf:toDataFrame()
  lurek.log.info("dist[1]: " .. tostring(df:getValue(1, "d2")))
  lurek.log.info("dist[3]: " .. tostring(df:getValue(3, "d2")))
end
--@api: LtoVec:colSqrt
do
  -- colSqrt computes sqrt per cell. Useful for converting squared distances to actual distances.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("dist_sq\n9\n16\n25\n"))

  -- Convert squared distances to actual distances
  vf:colSqrt("dist_sq")

  local df = vf:toDataFrame()
  lurek.log.info("distances: " .. tostring(df:getValue(1, "dist_sq")) .. ", "
    .. tostring(df:getValue(2, "dist_sq")))  -- 3, 4
end
--@api: LVecFrame:colOp
do
-- Applies a binary operation between two columns, storing result in a new column
  -- colOp computes (col_a op col_b) per row into a new output column.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("atk,def\n30,10\n40,15\n"))
  vf:colOp("net", "atk", "sub", "def")
  local df = vf:toDataFrame()
  lurek.log.info("net[1]: " .. tostring(df:getValue(1, "net")))
  lurek.log.info("net[2]: " .. tostring(df:getValue(2, "net")))
end
--@api: LfromCSV:colOp
do
  -- colOp computes (left_col <op> right_col) per row into a new output column.
  -- Supported ops: "add", "sub", "mul", "div".
  local df = lurek.dataframe.fromCSV("atk,def\n30,10\n40,15\n20,5\n")
  local vf = lurek.dataframe.toVec(df)

  -- Compute net damage = atk - def for each entity
  vf:colOp("net_dmg", "atk", "sub", "def")

  local result = vf:toDataFrame()
  lurek.log.info("net damage row 1: " .. tostring(result:getValue(1, "net_dmg")))  -- 20
end
--@api: LVecFrame:reduce
do
-- Reduces a numeric column to a single value using a named operation
  -- reduce aggregates a column to one value using a named operation.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("score\n10\n20\n30\n"))
  local total = vf:reduce("score", "sum")
  lurek.log.info("total score: " .. total)
  lurek.log.info("max score: " .. tostring(vf:reduce("score", "max")))
  lurek.log.info("score rows: " .. tostring(vf:nrows()))
end
--@api: LtoVec:reduce
do
  -- reduce() computes an aggregate over a VecFrame column without converting back.
  -- Supported ops: "sum", "mean", "min", "max", "count".
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("score\n10\n20\n30\n"))

  local total = vf:reduce("score", "sum")    -- 60
  local avg = vf:reduce("score", "mean")     -- 20
  lurek.log.info("total=" .. total .. " avg=" .. avg)
  lurek.log.info("peak score=" .. tostring(vf:reduce("score", "max")))
end
--@api: LVecFrame:filterMask
do
-- Builds a boolean mask array from a column comparison
  -- filterMask builds a boolean mask array from a column comparison.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("hp\n10\n50\n90\n"))
  local mask = vf:filterMask("hp", ">=", 50)
  lurek.log.info("row 2 passes: " .. tostring(mask[2]))
  lurek.log.info("row 3 passes: " .. tostring(mask[3]))
  lurek.log.info("mask length: " .. tostring(#mask))
end
--@api: LtoVec:filterMask
do
  -- filterMask creates a {true, false, ...} array based on a condition.
  -- Use with applyMask to filter the VecFrame efficiently.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("hp\n10\n50\n90\n"))

  -- Build a mask: which rows have hp >= 50?
  local mask = vf:filterMask("hp", ">=", 50)
  -- mask = {false, true, true}
  lurek.log.info("row 2 passes filter: " .. tostring(mask[2]))
  lurek.log.info("row 3 passes filter: " .. tostring(mask[3]))
  lurek.log.info("mask size: " .. tostring(#mask))
end
--@api: LVecFrame:applyMask
do
-- Returns a new VecFrame containing only rows where mask is true
  -- applyMask returns a new VecFrame with only the rows where mask is true.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("hp\n10\n50\n90\n"))
  local mask = vf:filterMask("hp", ">=", 50)
  local alive = vf:applyMask(mask)
  lurek.log.info("alive rows: " .. alive:nrows())
  lurek.log.info("alive hp type: " .. alive:colType("hp"))
end
--@api: LtoVec:filter
do
  -- applyMask filters rows using a boolean array (from filterMask or custom logic).
  -- This is the vectorized equivalent of DataFrame:filter().
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("hp\n10\n50\n90\n"))

  -- Filter to only rows with hp >= 50
  local mask = vf:filterMask("hp", ">=", 50)
  local alive = vf:applyMask(mask)

  lurek.log.info("alive entities: " .. alive:nrows())  -- 2
  lurek.log.info("alive hp type: " .. alive:colType("hp"))
end
--@api: LVecFrame:colType
do
-- Returns the data type name of a vectorized column ("float64", "int64", "text", "bool")
  -- colType returns the internal data type of a column ("float64", "int64", etc.).
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("hp\n10\n20\n"))
  local dtype = vf:colType("hp")
  lurek.log.info("hp dtype: " .. dtype)
  lurek.log.info("vec type: " .. tostring(vf:type()))
  lurek.log.info("is vec frame: " .. tostring(vf:typeOf("LVecFrame")))
end
--@api: LtoVec:colType
do
  -- colType tells you how a column is stored internally.
  -- Useful for debugging type mismatches in operations.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("hp\n10\n20\n"))

  local dtype = vf:colType("hp")
  lurek.log.info("hp stored as: " .. dtype)  -- "float64"
  lurek.log.info("row count: " .. tostring(vf:nrows()))
  lurek.log.info("vec type: " .. tostring(vf:type()))
end
--@api: LVecFrame:parReduce
do
-- Reduces multiple columns in parallel using a named operation
  -- parReduce reduces multiple columns in parallel using a named operation.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("hp,mp\n10,5\n20,10\n30,15\n"))
  local sums = vf:parReduce({"hp", "mp"}, "sum")
  lurek.log.info("hp sum: " .. tostring(sums["hp"]))
  lurek.log.info("mp sum: " .. tostring(sums["mp"]))
  lurek.log.info("reduced cols: " .. tostring(vf:ncols()))
end
--@api: LtoVec:parReduce
do
  -- parReduce runs the same reduction on multiple columns simultaneously.
  -- Exploits multi-core CPUs for large datasets.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("hp,mp,atk\n10,5,8\n20,10,12\n30,15,6\n"))

  -- Sum all three stat columns in parallel
  local sums = vf:parReduce({"hp", "mp", "atk"}, "sum")
  for col, s in pairs(sums) do
    lurek.log.info(col .. " total = " .. tostring(s))
  end
end
--@api: LVecFrame:toDataFrame
do
-- Converts this VecFrame back to a regular DataFrame
  -- toDataFrame converts this VecFrame back to a regular DataFrame.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("v\n1\n2\n3\n"))
  vf:colAdd("v", 10)
  local df = vf:toDataFrame()
  lurek.log.info("v[1] after +10: " .. tostring(df:getValue(1, "v")))
  lurek.log.info("v rows after convert: " .. tostring(df:nrows()))
end
--@api: LfromVec:colAdd
do
  -- toDataFrame() is the same as lurek.dataframe.fromVec(vf) but called as a method.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("v\n1\n2\n3\n"))
  vf:colAdd("v", 10)

  -- Method-style conversion back to DataFrame
  local df = vf:toDataFrame()
  lurek.log.info("v[1] after +10: " .. tostring(df:getValue(1, "v")))  -- 11
  lurek.log.info("v total after +10: " .. tostring(df:sum("v")))
end
--@api: LVecFrame:colSub
do
-- Subtracts a scalar from every cell in a numeric column (in-place)
  -- colSub subtracts a scalar from every cell (in-place).
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("stamina\n100\n80\n"))
  vf:colSub("stamina", 10)
  local df = vf:toDataFrame()
  lurek.log.info("stamina[1] after drain: " .. tostring(df:getValue(1, "stamina")))
  lurek.log.info("stamina[2] after drain: " .. tostring(df:getValue(2, "stamina")))
end
--@api: LtoVec:colSub
do
  -- colSub decreases all values. Use for drain effects, decay, or cost deduction.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("stamina\n100\n80\n60\n"))

  -- All entities lose 10 stamina per turn
  vf:colSub("stamina", 10)

  local df = vf:toDataFrame()
  lurek.log.info("stamina after drain: " .. tostring(df:getValue(1, "stamina")))  -- 90
  lurek.log.info("remaining stamina total: " .. tostring(df:sum("stamina")))
end
--@api: LVecFrame:colDiv
do
-- Divides every cell in a numeric column by a scalar (in-place)
  -- colDiv divides every cell by a scalar (in-place).
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("score\n100\n200\n"))
  vf:colDiv("score", 200)
  local df = vf:toDataFrame()
  lurek.log.info("normalised[1]: " .. tostring(df:getValue(1, "score")))
  lurek.log.info("normalised[2]: " .. tostring(df:getValue(2, "score")))
end
--@api: LtoVec:colDiv
do
  -- colDiv normalizes values or applies fractional scaling.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("score\n100\n200\n150\n"))

  -- Normalize scores to 0-1 range by dividing by max (200)
  vf:colDiv("score", 200)

  local df = vf:toDataFrame()
  lurek.log.info("normalized score[1]: " .. tostring(df:getValue(1, "score")))  -- 0.5
  lurek.log.info("normalized max score: " .. tostring(df:max("score")))
end
--@api: LVecFrame:colFloor
do
-- Applies floor (round down) to every cell in a numeric column (in-place)
  -- colFloor rounds every cell down to the nearest integer (in-place).
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("x\n1.9\n2.1\n3.7\n"))
  vf:colFloor("x")
  local df = vf:toDataFrame()
  lurek.log.info("floored x[1]: " .. tostring(df:getValue(1, "x")))
  lurek.log.info("floored x[3]: " .. tostring(df:getValue(3, "x")))
end
--@api: LtoVec:colFloor
do
  -- colFloor rounds down to the nearest integer. Use for tile snapping or integer coercion.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("x\n1.9\n2.1\n3.7\n"))

  -- Snap to grid (floor to integer)
  vf:colFloor("x")

  local df = vf:toDataFrame()
  lurek.log.info("floored: " .. tostring(df:getValue(1, "x")) .. ", "
    .. tostring(df:getValue(3, "x")))  -- 1, 3
end
--@api: LVecFrame:colCeil
do
-- Applies ceil (round up) to every cell in a numeric column (in-place)
  -- colCeil rounds every cell up to the nearest integer (in-place).
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("y\n1.1\n2.5\n3.0\n"))
  vf:colCeil("y")
  local df = vf:toDataFrame()
  lurek.log.info("ceiled y[1]: " .. tostring(df:getValue(1, "y")))
  lurek.log.info("ceiled y[2]: " .. tostring(df:getValue(2, "y")))
end
--@api: LtoVec:colCeil
do
  -- colCeil rounds up. Use for "minimum 1 damage" type calculations.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("y\n1.1\n2.5\n3.0\n"))

  vf:colCeil("y")

  local df = vf:toDataFrame()
  lurek.log.info("ceiled y[1]: " .. tostring(df:getValue(1, "y")))  -- 2
  lurek.log.info("ceiled y[2]: " .. tostring(df:getValue(2, "y")))
end
--@api: LVecFrame:colNeg
do
-- Negates every cell in a numeric column (in-place)
  -- colNeg negates every cell (in-place), flipping the sign.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("vy\n3\n-2\n0\n"))
  vf:colNeg("vy")
  local df = vf:toDataFrame()
  lurek.log.info("bounced vy[1]: " .. tostring(df:getValue(1, "vy")))
  lurek.log.info("bounced vy[2]: " .. tostring(df:getValue(2, "vy")))
end
--@api: LtoVec:colNeg
do
  -- colNeg flips the sign. Use for reversing velocity, inverting offsets, etc.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("vy\n3\n-2\n0\n"))

  -- Reverse vertical velocity (bounce)
  vf:colNeg("vy")

  local df = vf:toDataFrame()
  lurek.log.info("bounced vy[1]: " .. tostring(df:getValue(1, "vy")))  -- -3
  lurek.log.info("bounced vy[2]: " .. tostring(df:getValue(2, "vy")))
end
--@api: LVecFrame:colCast
do
-- Casts a column to a different data type (e.g., "float64", "int64")
  -- colCast changes the internal storage type of a column.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("level\n1\n2\n3\n"))
  vf:colCast("level", "float64")
  lurek.log.info("level dtype after cast: " .. vf:colType("level"))
  lurek.log.info("level rows after cast: " .. tostring(vf:nrows()))
  lurek.log.info("vec type after cast: " .. tostring(vf:type()))
end
--@api: LtoVec:colCast
do
  -- colCast changes the internal storage type of a column.
  -- Use when you need float precision for integer data or vice versa.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("level\n1\n2\n3\n"))

  -- Cast int column to float for fractional math
  vf:colCast("level", "float64")
  lurek.log.info("level dtype after cast: " .. vf:colType("level"))

  local df = vf:toDataFrame()
  lurek.log.info("level[1] as float: " .. tostring(df:getValue(1, "level")))
end
--@api: LDataFrame:addColumn.6
do
-- Adds a new column with an optional default value for existing rows
  -- addColumn extends the schema; existing rows receive the default value.
  local df = lurek.dataframe.newDataFrame()
  df:addRow({name = "Alice", score = 85})
  df:addColumn("grade", "ungraded")
  lurek.log.info("cols after addColumn: " .. df:ncols())
  lurek.log.info("default grade: " .. tostring(df:getValue(1, "grade")))
end
--@api: LDataFrame:ncols.2
do
  -- addColumn extends the schema. Existing rows get the default value.
  -- The default can be a single value (applied to all rows) or an array of per-row values.
  local df = lurek.dataframe.newDataFrame()
  df:addRow({name = "Alice", score = 85})
  df:addRow({name = "Bob", score = 72})

  -- Add a "grade" column after the fact; existing rows get the provided default
  df:addColumn("grade", "ungraded")
  lurek.log.info("columns now: " .. df:ncols())
end
--@api: LDatabase:addTable.8
do
-- Adds or replaces a named table in the database
  -- addTable registers a dataframe under a name; replaces if it already exists.
  local db = lurek.dataframe.newDatabase()
  db:addTable("users", lurek.dataframe.fromTable({{id=1,name="Alice"}}))
  lurek.log.info("tables: " .. db:tableCount())
  lurek.log.info("has users: " .. tostring(db:hasTable("users")))
  lurek.log.info("user rows: " .. tostring(db:getTable("users"):nrows()))
end
--@api: LDatabase:tableCount.6
do
  -- addTable registers a dataframe under a string key.
  -- If a table with that name exists, it gets replaced.
  local db = lurek.dataframe.newDatabase()
  local users = lurek.dataframe.newDataFrame()
  users:addRow({id = 1, name = "Alice", role = "admin"})

  db:addTable("users", users)
  lurek.log.info("database now has " .. db:tableCount() .. " table(s)")
end
--@api: LDataFrame:apply
do
-- Transforms every cell in a column using a Lua function (in-place)
  -- apply transforms every cell in a column using a Lua function (in-place).
  local df = lurek.dataframe.fromTable({{score=60},{score=80},{score=45}})
  df:apply("score", function(v) return v >= 70 and "pass" or "fail" end)
  lurek.log.info("grade[1]: " .. df:getValue(1, "score"))
  lurek.log.info("grade[2]: " .. df:getValue(2, "score"))
  lurek.log.info("grade[3]: " .. df:getValue(3, "score"))
end
--@api: LDataFrame:lazy.5
do
  -- apply() runs your function on each cell and replaces it with the return value.
  -- Use for custom transformations that simple math can't express.
  local df = lurek.dataframe.newDataFrame()
  df:addRow({score = 60, name = "Alice"})
  df:addRow({score = 80, name = "Bob"})
  df:addRow({score = 45, name = "Cara"})

  -- Convert numeric scores to letter grades
  df:apply("score", function(v)
    if v >= 70 then return "pass" else return "fail" end
  end)
  lurek.log.info("applied grade transform")
end
--@api: LDataFrame:corr
do
-- Returns the Pearson correlation between two numeric columns
  -- corr returns Pearson correlation between two numeric columns.
  local df = lurek.dataframe.fromTable({{x=1,y=2},{x=2,y=4},{x=3,y=6}})
  local r = df:corr("x", "y")
  lurek.log.info("corr x,y: " .. string.format("%.3f", r))
  lurek.log.info("x mean: " .. tostring(df:mean("x")))
  lurek.log.info("y mean: " .. tostring(df:mean("y")))
end
--@api: LDataFrame:corr.2
do
  -- corr() measures linear relationship between two variables.
  -- +1 = perfectly correlated, -1 = inversely correlated, 0 = no relationship.
  local df = lurek.dataframe.newDataFrame()
  df:addRow({playtime = 10, skill = 20})
  df:addRow({playtime = 30, skill = 55})
  df:addRow({playtime = 50, skill = 85})

  -- Check if playtime correlates with skill level
  local r = df:corr("playtime", "skill")
  lurek.log.info("playtime-skill correlation: " .. string.format("%.3f", r))
end
--@api: LLazyQuery:filter
do
-- Returns a new dataframe with rows matching a condition (col op val)
  -- filter on a lazy query keeps only rows where the column matches the condition.
  local df = lurek.dataframe.fromTable({{level=5},{level=20},{level=35}})
  local result = df:lazy():filter("level", ">=", 15):collect()
  lurek.log.info("high-level rows: " .. result:nrows())
  lurek.log.info("lowest kept level: " .. tostring(result:getValue(1, "level")))
  lurek.log.info("highest kept level: " .. tostring(result:getValue(result:nrows(), "level")))
end
--@api: LDataFrame:filter.2
do
  -- filter() creates a subset based on a comparison.
  -- Supported ops: "==", "!=", ">", ">=", "<", "<=".
  local players = lurek.dataframe.newDataFrame()
  players:addRow({name = "Alice", level = 20})
  players:addRow({name = "Bob", level = 5})
  players:addRow({name = "Cara", level = 35})

  -- Find high-level players for the raid
  local raiders = players:filter("level", ">=", 15)
  lurek.log.info("raid-eligible: " .. raiders:nrows() .. " players")
end
--@api: LDataFrame:groupAgg
do
-- Groups by one column and aggregates another with a built-in function
  -- groupAgg groups by one column and aggregates another with a built-in function.
  local df = lurek.dataframe.fromTable({
    {region="N",revenue=500},{region="N",revenue=300},{region="S",revenue=700}
  })
  local totals = df:groupAgg("region", "revenue", "sum")
  lurek.log.info("aggregated rows: " .. totals:nrows())
end
--@api: LDataFrame:groupAgg.2
do
  -- groupAgg is a shorthand: group by one column, aggregate another.
  -- Built-in aggregates: "sum", "mean", "min", "max", "count".
  local sales = lurek.dataframe.newDataFrame()
  sales:addRow({region = "North", revenue = 500})
  sales:addRow({region = "North", revenue = 300})
  sales:addRow({region = "South", revenue = 700})

  -- Total revenue per region
  local totals = sales:groupAgg("region", "revenue", "sum")
  lurek.log.info("revenue by region:\n" .. totals:toString())
end
--@api: LDataFrame:join
do
-- Joins two dataframes by column (inner, left, right, or outer)
  -- join combines two frames on matching column values.
  local players = lurek.dataframe.fromTable({{id=1,name="Alice"},{id=2,name="Bob"}})
  local guilds  = lurek.dataframe.fromTable({{player_id=1,guild="Phoenix"},{player_id=2,guild="Shadow"}})
  local merged = players:join(guilds, "id", "player_id", "inner")
  lurek.log.info("joined rows: " .. merged:nrows())
  lurek.log.info("first joined guild: " .. tostring(merged:getValue(1, "guild")))
end
--@api: LDataFrame:join.2
do
  -- join() combines rows from two dataframes where a key matches.
  -- Supports: "inner" (default), "left", "right", "outer".
  local players = lurek.dataframe.newDataFrame()
  players:addRow({id = 1, name = "Alice"})
  players:addRow({id = 2, name = "Bob"})

  local guilds = lurek.dataframe.newDataFrame()
  guilds:addRow({player_id = 1, guild = "Phoenix"})
  guilds:addRow({player_id = 2, guild = "Shadow"})

  -- Inner join: match players.id to guilds.player_id
  local merged = players:join(guilds, "id", "player_id", "inner")
  lurek.log.info("joined rows: " .. merged:nrows())
end
--@api: LDataFrame:normalizeCol
do
-- Adds a range-normalized column (maps values to [out_min, out_max])
  -- normalizeCol maps a column's range to [out_min, out_max] and stores it.
  local df = lurek.dataframe.fromTable({{val=10},{val=50},{val=90}})
  df:normalizeCol("val", 0.0, 1.0, "val_norm")
  lurek.log.info("normalised column added: " .. df:ncols() .. " cols")
  lurek.log.info("first normalized value: " .. tostring(df:getValue(1, "val_norm")))
  lurek.log.info("last normalized value: " .. tostring(df:getValue(3, "val_norm")))
end
--@api: LDataFrame:normalizeCol.2
do
  -- normalizeCol scales a numeric column to a target range.
  -- Use for normalizing stats to 0-1 for ML inputs or UI bar widths.
  local df = lurek.dataframe.newDataFrame()
  df:addRow({val = 10})
  df:addRow({val = 50})
  df:addRow({val = 90})

  -- Normalize "val" to [0.0, 1.0] and store in "val_norm"
  df:normalizeCol("val", 0.0, 1.0, "val_norm")
  lurek.log.info("normalized column added")
end
--@api: LDataFrame:outliers
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
--@api: LDataFrame:Year
do
  -- outliers() finds rows with values far from the mean.
  -- Default threshold is 2.0 standard deviations.
  local df = lurek.dataframe.newDataFrame()
  for i = 1, 10 do df:addRow({response_ms = 15 + i}) end
  df:addRow({response_ms = 1000})  -- obvious outlier (lag spike)

  local spikes = df:outliers("response_ms", 2.0)
  lurek.log.info("lag spikes detected: " .. spikes:nrows())
end
--@api: LVecFrame:parScalarOp
do
-- Applies a scalar operation to multiple columns in parallel
  -- parScalarOp applies a scalar operation to multiple columns in parallel.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("x,y\n1,2\n3,4\n"))
  vf:parScalarOp({"x", "y"}, "mul", 2.0)
  local df = vf:toDataFrame()
  lurek.log.info("x[1] doubled: " .. tostring(df:getValue(1, "x")))
  lurek.log.info("y[1] doubled: " .. tostring(df:getValue(1, "y")))
end
--@api: LtoVec:parScalarOp
do
  -- parScalarOp runs the same scalar op on multiple columns at once, using threads.
  -- Supported ops: "add", "sub", "mul", "div".
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("x,y,z\n1.0,4.0,2.0\n2.0,5.0,3.0\n3.0,6.0,4.0\n"))

  -- Double all coordinate values simultaneously (multi-threaded)
  vf:parScalarOp({"x", "y", "z"}, "mul", 2.0)
  lurek.log.info("parallel scalar op done")
  lurek.log.info("x total after op: " .. tostring(vf:reduce("x", "sum")))
  lurek.log.info("z total after op: " .. tostring(vf:reduce("z", "sum")))
end
--@api: LDataFrame:pivot
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
--@api: LDataFrame:pivot.2
do
  -- pivot() reshapes data from long format to wide format.
  -- Each unique value in col_col becomes a new column.
  local df = lurek.dataframe.newDataFrame()
  df:addRow({player = "Alice", stat = "hp", value = 100})
  df:addRow({player = "Alice", stat = "mp", value = 50})
  df:addRow({player = "Bob", stat = "hp", value = 80})
  df:addRow({player = "Bob", stat = "mp", value = 70})

  -- Pivot: players as rows, stats as columns
  local wide = df:pivot("player", "stat", "value")
  lurek.log.info("pivot columns: " .. wide:ncols())
end
--@api: LDataFrame:pivotTable
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
--@api: LDataFrame:pivotTable.2
do
  -- pivotTable groups by two dimensions and aggregates.
  -- Like a cross-tab or spreadsheet pivot table.
  local df = lurek.dataframe.newDataFrame()
  df:addRow({region = "North", product = "Sword", sales = 50})
  df:addRow({region = "North", product = "Shield", sales = 30})
  df:addRow({region = "South", product = "Sword", sales = 70})
  df:addRow({region = "South", product = "Shield", sales = 40})

  -- Pivot: region as rows, product as columns, sum of sales
  local pt = df:pivotTable("region", "product", "sales", "sum")
  lurek.log.info("pivot table:\n" .. pt:toString())
end
--@api: LDataFrame:rank
do
-- Returns a new dataframe with a rank column added
  -- rank returns a new frame with a rank column based on the source column.
  local df = lurek.dataframe.fromTable({{player="Alice",score=80},{player="Bob",score=95},{player="Cara",score=72}})
  local ranked = df:rank("score", "desc", "position")
  lurek.log.info("ranked rows: " .. ranked:nrows())
  lurek.log.info("leader name: " .. tostring(ranked:getValue(1, "player")))
  lurek.log.info("leader rank: " .. tostring(ranked:getValue(1, "position")))
end
--@api: LDataFrame:rank.2
do
  -- rank() assigns a position (1st, 2nd, 3rd...) based on a column's value.
  -- Use for leaderboard position calculation.
  local df = lurek.dataframe.newDataFrame()
  df:addRow({player = "Alice", score = 80})
  df:addRow({player = "Bob", score = 95})
  df:addRow({player = "Cara", score = 72})

  -- Rank by score descending (highest = rank 1)
  local ranked = df:rank("score", "desc", "position")
  lurek.log.info("ranked:\n" .. ranked:toString())
end
--@api: LDataFrame:rollingMean
do
-- Returns a new dataframe with a rolling average column added
  -- rollingMean adds a smoothed column by averaging over a sliding window.
  local df = lurek.dataframe.newDataFrame()
  df:addColumn("ms", 0)
  for _, v in ipairs({16, 17, 33, 16, 15, 16}) do df:addRow({ms=v}) end
  local smoothed = df:rollingMean("ms", 3)
  lurek.log.info("rolling mean cols: " .. smoothed:ncols())
end
--@api: LDataFrame:rollingMean.2
do
  -- rollingMean smooths noisy data over a window of N rows.
  -- Common for frame time smoothing or trend detection.
  local df = lurek.dataframe.newDataFrame()
  for _, v in ipairs({16, 17, 33, 16, 15, 16, 32, 16}) do
    df:addRow({frame_ms = v})
  end

  -- 3-frame rolling average to smooth spikes
  local smoothed = df:rollingMean("frame_ms", 3)
  lurek.log.info("smoothed frame data:\n" .. smoothed:head(5):toString())
end
--@api: LDataFrame:rollingSum
do
-- Returns a new dataframe with a rolling sum column added
  -- rollingSum adds a windowed cumulative total column.
  local df = lurek.dataframe.newDataFrame()
  df:addColumn("dmg", 0)
  for _, v in ipairs({10, 20, 15, 30, 5}) do df:addRow({dmg=v}) end
  local windowed = df:rollingSum("dmg", 3)
  lurek.log.info("rolling sum cols: " .. windowed:ncols())
end
--@api: LDataFrame:rollingSum.2
do
  -- rollingSum totals over a sliding window. Useful for "damage in last N hits".
  local df = lurek.dataframe.newDataFrame()
  for _, v in ipairs({10, 20, 15, 30, 5}) do
    df:addRow({dmg = v})
  end

  -- Sum of damage over last 3 hits
  local windowed = df:rollingSum("dmg", 3)
  lurek.log.info("rolling sum data:\n" .. windowed:toString())
end
--@api: LDataFrame:setValue
do
-- Sets one cell value by row index and column reference
  -- setValue updates one cell by 1-based row index and column name.
  local df = lurek.dataframe.fromTable({{player="Alice",score=50}})
  df:setValue(1, "score", 150)
  lurek.log.info("updated score: " .. df:getValue(1, "score"))
  lurek.log.info("player after update: " .. tostring(df:getValue(1, "player")))
  lurek.log.info("row count: " .. tostring(df:nrows()))
end
--@api: LDataFrame:getValue.2
do
  -- setValue modifies a single cell in-place. Use for targeted updates.
  local df = lurek.dataframe.newDataFrame()
  df:addRow({player = "Alice", score = 50})

  -- Player earned points — update their score
  df:setValue(1, "score", 150)
  lurek.log.info("updated score: " .. df:getValue(1, "score"))
  lurek.log.info("updated player: " .. tostring(df:getValue(1, "player")))
end
--@api: LLazyQuery:sort
do
-- Returns a new sorted dataframe by column (ascending or descending)
  -- sort on a lazy query orders rows by a column before collect.
  local df = lurek.dataframe.fromTable({{name="Cara",score=80},{name="Alice",score=95},{name="Bob",score=60}})
  local top = df:lazy():sort("score", false):collect()
  lurek.log.info("1st place: " .. top:getValue(1, "name"))
  lurek.log.info("1st score: " .. tostring(top:getValue(1, "score")))
  lurek.log.info("last score: " .. tostring(top:getValue(top:nrows(), "score")))
end
--@api: LDataFrame:sort.2
do
  -- sort() orders rows by a column. Use for leaderboards, priority queues, etc.
  local df = lurek.dataframe.newDataFrame()
  df:addRow({name = "Cara", score = 80})
  df:addRow({name = "Alice", score = 95})
  df:addRow({name = "Bob", score = 60})

  -- Sort descending for a high-score list
  local leaderboard = df:sort("score", false)
  lurek.log.info("1st place: " .. leaderboard:getValue(1, "name"))
end
--@api: LDataFrame:withCumsum
do
-- Adds a cumulative sum column (running total) in-place
  -- withCumsum adds a running-total column derived from an existing column.
  local df = lurek.dataframe.newDataFrame()
  df:addColumn("xp", 0)
  for _, v in ipairs({100, 50, 200, 75}) do df:addRow({xp=v}) end
  df:withCumsum("xp", "total_xp")
  lurek.log.info("cumsum col added: " .. df:ncols() .. " cols")
end
--@api: LDataFrame:withCumsum.2
do
  -- withCumsum creates a running total column. Use for total gold over time,
  -- cumulative XP, or progressive score tracking.
  local df = lurek.dataframe.newDataFrame()
  for _, xp in ipairs({100, 50, 200, 75}) do
    df:addRow({xp_gained = xp})
  end

  -- Column "total_xp" will be: 100, 150, 350, 425
  df:withCumsum("xp_gained", "total_xp")
  lurek.log.info("cumulative XP column added")
end
--@api: LDataFrame:withPctChange
do
-- Adds a percent-change column (row-over-row change rate) in-place
  -- withPctChange adds a row-over-row percent-change column.
  local df = lurek.dataframe.newDataFrame()
  df:addColumn("price", 0)
  for _, v in ipairs({100, 110, 121, 133}) do df:addRow({price=v}) end
  df:withPctChange("price", "pct")
  lurek.log.info("pct col added: " .. df:ncols() .. " cols")
end
--@api: LDataFrame:withPctChange.2
do
  -- withPctChange shows the rate of change between consecutive rows.
  -- Useful for detecting sudden spikes or drops in metrics.
  local df = lurek.dataframe.newDataFrame()
  for _, price in ipairs({100, 110, 121, 133}) do
    df:addRow({gold_price = price})
  end

  -- Shows ~10% growth each step
  df:withPctChange("gold_price", "gold_change_pct")
  lurek.log.info("percent change column added")
end
--@api: LDataFrame:withRank
do
-- Adds a rank column in-place based on a source column
  -- withRank adds a rank column in-place without creating a new frame.
  local df = lurek.dataframe.fromTable({{player="Alice",pts=10},{player="Bob",pts=30},{player="Cara",pts=20}})
  df:withRank("pts", true, "rank")
  lurek.log.info("rank col added: " .. df:ncols() .. " cols")
  lurek.log.info("lowest points rank: " .. tostring(df:getValue(1, "rank")))
  lurek.log.info("highest points rank: " .. tostring(df:getValue(2, "rank")))
end
--@api: LDataFrame:withRank.2
do
  -- withRank assigns ordinal positions without creating a new dataframe.
  local df = lurek.dataframe.newDataFrame()
  df:addRow({player = "Alice", pts = 10})
  df:addRow({player = "Bob", pts = 30})
  df:addRow({player = "Cara", pts = 20})

  -- Rank ascending: lowest pts = rank 1
  df:withRank("pts", true, "pts_rank")
  lurek.log.info("rank column added in-place")
end
--@api: LDataFrame:withRollingMax
do
-- Adds a rolling maximum column in-place
  -- withRollingMax adds a sliding-window maximum column in-place.
  local df = lurek.dataframe.newDataFrame()
  df:addColumn("v", 0)
  for _, v in ipairs({3,1,4,1,5,9,2,6}) do df:addRow({v=v}) end
  df:withRollingMax("v", 3, "peak")
  lurek.log.info("rolling max col added")
end
--@api: LDataFrame:withRollingMax.2
do
  -- withRollingMax tracks the peak value over a sliding window.
  -- Use for "max damage in last N hits" or "peak FPS in last N frames".
  local df = lurek.dataframe.newDataFrame()
  for _, v in ipairs({3, 1, 4, 1, 5, 9, 2, 6}) do
    df:addRow({value = v})
  end

  -- Track the maximum over a 3-row window
  df:withRollingMax("value", 3, "peak_3")
  lurek.log.info("rolling max column added")
end
--@api: LDataFrame:withRollingMean
do
-- Adds a rolling mean column in-place
  -- withRollingMean adds a rolling average column in-place.
  local df = lurek.dataframe.newDataFrame()
  df:addColumn("temp", 0)
  for i = 1, 5 do df:addRow({temp=20+i}) end
  df:withRollingMean("temp", 3, "smooth")
  lurek.log.info("rolling mean col added")
end
--@api: LDataFrame:lazy.6
do
  -- withRollingMean smooths data inline (same as rollingMean but modifies in-place).
  local df = lurek.dataframe.newDataFrame()
  for i = 1, 5 do df:addRow({temp = 20 + i}) end

  df:withRollingMean("temp", 3, "temp_smooth")
  lurek.log.info("rolling mean column added in-place")
  lurek.log.info("smooth row count: " .. tostring(df:nrows()))
end
--@api: LDataFrame:withRollingMin
do
-- Adds a rolling minimum column in-place
  -- withRollingMin adds a sliding-window minimum column in-place.
  local df = lurek.dataframe.newDataFrame()
  df:addColumn("hp", 0)
  for _, v in ipairs({5,3,8,2,7,1}) do df:addRow({hp=v}) end
  df:withRollingMin("hp", 3, "floor")
  lurek.log.info("rolling min col added")
end
--@api: LDataFrame:withRollingMin.2
do
  -- withRollingMin tracks the lowest value in a sliding window.
  -- Use for "minimum HP in last N ticks" monitoring.
  local df = lurek.dataframe.newDataFrame()
  for _, v in ipairs({5, 3, 8, 2, 7, 1}) do
    df:addRow({hp = v})
  end

  -- Track the minimum over a 3-row window
  df:withRollingMin("hp", 3, "hp_floor")
  lurek.log.info("rolling min column added")
end
--@api: LDataFrame:withRollingSum
do
-- Adds a rolling sum column in-place
  -- withRollingSum adds a windowed rolling-total column in-place.
  local df = lurek.dataframe.newDataFrame()
  df:addColumn("sales", 0)
  for i = 1, 5 do df:addRow({sales=i*10}) end
  df:withRollingSum("sales", 3, "s3")
  lurek.log.info("rolling sum col added")
end
--@api: LDataFrame:lazy.3
do
  -- withRollingSum tracks a windowed total inline.
  local df = lurek.dataframe.newDataFrame()
  for i = 1, 5 do df:addRow({sales = i * 10}) end

  -- Sum of last 3 periods
  df:withRollingSum("sales", 3, "sales_3period")
  lurek.log.info("rolling sum column added in-place")
  lurek.log.info("latest rolling total: " .. tostring(df:getValue(df:nrows(), "sales_3period")))
end
--@api: LDataFrame:zscoreCol
do
-- Adds a z-score normalized column in-place
  -- zscoreCol standardises values to z-scores: (value - mean) / stddev.
  local df = lurek.dataframe.newDataFrame()
  df:addColumn("stat", 0)
  for i = 1, 6 do df:addRow({stat=i*5}) end
  df:zscoreCol("stat", "stat_z")
  lurek.log.info("z-score col added: " .. df:ncols() .. " cols")
end
--@api: LDataFrame:lazy.4
do
  -- zscoreCol standardizes values: (value - mean) / stddev.
  -- Result has mean=0, stddev=1. Use for comparing across different scales.
  local df = lurek.dataframe.newDataFrame()
  for i = 1, 6 do df:addRow({stat = i * 5}) end

  -- Normalize "stat" to z-scores in column "stat_z"
  df:zscoreCol("stat", "stat_z")
  lurek.log.info("z-score normalized column added")
  lurek.log.info("first z-score: " .. tostring(df:getValue(1, "stat_z")))
end
--@api: LDataFrame:lazy
do
-- Starts a lazy query pipeline from this dataframe
  -- lazy() returns a deferred query handle; operations are chained, not executed yet.
  local df = lurek.dataframe.fromTable({{hp=12,team="red"},{hp=7,team="blue"}})
  local q = df:lazy()
  lurek.log.info("lazy query type: " .. tostring(q:type()))
  lurek.log.info("is lazy query: " .. tostring(q:typeOf("LLazyQuery")))
  lurek.log.info("source rows still available: " .. tostring(df:nrows()))
end
--@api: LfromTable:lazy
do
  -- lazy() creates a deferred query builder. Steps are chained but not executed
  -- until you call :collect(). This allows the engine to optimize the query plan.
  local df = lurek.dataframe.fromTable({
    {name = "alice", hp = 12, team = "red"},
    {name = "bob", hp = 7, team = "blue"},
    {name = "cara", hp = 20, team = "red"},
  })

  -- Create a lazy query handle (no work done yet)
  local q = df:lazy()
  lurek.log.info("lazy query type: " .. tostring(q:type()))
end
--@api: LLazyQuery
do
-- Lazy query pipeline: chain filter, sort, head, tail, limit, slice, select, dropNil, then collect
  -- LLazyQuery is the deferred pipeline handle; call collect() to materialise.
  local df = lurek.dataframe.fromTable({{n=1},{n=2},{n=3},{n=4}})
  local q = df:lazy()
  lurek.log.info("LLazyQuery is object: " .. tostring(q:typeOf("LObject")))
  lurek.log.info("LLazyQuery type: " .. tostring(q:type()))
  lurek.log.info("source rows: " .. tostring(df:nrows()))
end
--@api: LfromTable:lazy.2
do
  -- LazyQuery chains multiple operations before executing them all at once.
  -- This can be more efficient than applying each operation individually.
  local df = lurek.dataframe.fromTable({
    {name = "alice", hp = 12, mana = 5, team = "red"},
    {name = "bob", hp = 7, mana = nil, team = "blue"},
    {name = "cara", hp = 20, mana = 9, team = "red"},
    {name = "dave", hp = 15, mana = 3, team = "blue"},
  })

  -- Verify type
  local q = df:lazy()
  local is_lazy = q:typeOf("LLazyQuery")
  lurek.log.info("is lazy query: " .. tostring(is_lazy))

  -- Chain: filter hp > 10, then collect results
  local filtered = df:lazy():filter("hp", ">", 10):collect()

  -- Chain: sort by hp descending, take top 2
  local sorted = df:lazy():sort("hp", false):head(2):collect()

  -- Chain: get last 2 rows
  local tailed = df:lazy():tail(2):collect()

  -- Chain: limit to 3 rows maximum
  local limited = df:lazy():limit(3):collect()

  -- Chain: slice rows 2 through 4 (inclusive)
  local sliced = df:lazy():slice(2, 4):collect()

  -- Chain: drop rows where mana is nil
  local non_nil = df:lazy():dropNil("mana"):collect()

  -- Chain: keep only name and hp columns
  local selected = df:lazy():select({"name", "hp"}):collect()

  lurek.log.info("filtered: " .. filtered:nrows() .. " rows")
  lurek.log.info("top 2 by hp: " .. sorted:nrows() .. " rows")
  lurek.log.info("tailed: " .. tailed:nrows() .. " rows")
  lurek.log.info("limited: " .. limited:nrows() .. " rows")
  lurek.log.info("sliced: " .. sliced:nrows() .. " rows")
  lurek.log.info("non-nil mana: " .. non_nil:nrows() .. " rows")
  lurek.log.info("selected cols: " .. selected:ncols() .. " cols")
end
--@api: LDataFrame:nrows
do
-- Returns the number of rows in this dataframe.
  -- nrows returns the row count; check it before iterating or indexing.
  local df = lurek.dataframe.fromTable({{name="Alice"},{name="Bob"},{name="Cara"}})
  lurek.log.info("player count: " .. df:nrows())
  lurek.log.info("first player: " .. tostring(df:getValue(1, "name")))
  lurek.log.info("row/col shape: " .. df:nrows() .. "x" .. df:ncols())
  lurek.log.info("last player: " .. tostring(df:getValue(df:nrows(), "name")))
end
--@api: LfromTable:nrows.4
do
  -- Check row count after loading player stats for a leaderboard.
  local df = lurek.dataframe.fromTable({
    { name = "Alice", score = 950 },
    { name = "Bob", score = 870 },
    { name = "Carol", score = 1020 },
  })
  lurek.log.info("leaderboard rows: " .. df:nrows())
end
--@api: LDataFrame:ncols
do
-- Returns the number of columns in this dataframe.
  -- ncols returns how many columns the schema has.
  local df = lurek.dataframe.fromTable({{name="Sword",damage=12,weight=3}})
  lurek.log.info("item schema cols: " .. df:ncols())
  lurek.log.info("item schema names: " .. table.concat(df:columns(), ", "))
  lurek.log.info("row/col shape: " .. df:nrows() .. "x" .. df:ncols())
  lurek.log.info("first item name: " .. tostring(df:getValue(1, "name")))
end
--@api: LfromTable:ncols.2
do
  -- Verify column count matches the expected schema.
  local df = lurek.dataframe.fromTable({
    { name = "Sword", damage = 12, weight = 3 },
  })
  lurek.log.debug("item schema cols: " .. df:ncols())
  lurek.log.debug("item columns: " .. table.concat(df:columns(), ", "))
end
--@api: LDataFrame:columns
do
-- Returns all column names in order. This method is available to Lua scripts.
  -- columns() returns all column names in order as a Lua array.
  local df = lurek.dataframe.fromTable({{hp=100,mp=50,stamina=80}})
  local cols = df:columns()
  lurek.log.info("schema: " .. table.concat(cols, ", "))
  lurek.log.info("column count: " .. tostring(#cols))
  lurek.log.info("first column: " .. tostring(cols[1]))
end
--@api: LfromTable:columns.2
do
  -- List columns for a debug table header in the inventory UI.
  local df = lurek.dataframe.fromTable({
    { id = 1, name = "Potion", qty = 5 },
  })
  local cols = df:columns()
  lurek.log.debug("columns: " .. table.concat(cols, ", "))
end
--@api: LDataFrame:filter
do
-- Returns rows whose column value matches a comparison.
  -- filter returns a new frame with only the rows matching the condition.
  local df = lurek.dataframe.fromTable({{enemy="Goblin",hp=30},{enemy="Orc",hp=80}})
  local strong = df:filter("hp", ">", 50)
  lurek.log.info("strong enemies: " .. strong:nrows())
  lurek.log.info("strongest first enemy: " .. tostring(strong:getValue(1, "enemy")))
  lurek.log.info("strongest hp: " .. tostring(strong:getValue(1, "hp")))
end
--@api: LfromTable:filter
do
  -- Filter enemies whose HP is above a threshold for boss-wave selection.
  local df = lurek.dataframe.fromTable({
    { enemy = "Goblin", hp = 30 },
    { enemy = "Orc", hp = 80 },
    { enemy = "Dragon", hp = 500 },
  })
  local strong = df:filter("hp", ">", 50)
  lurek.log.info("strong enemies: " .. strong:nrows())
end
--@api: LDataFrame:sort
do
-- Returns rows sorted by a column. This method is available to Lua scripts.
  -- sort returns a new frame with rows ordered by the named column.
  local df = lurek.dataframe.fromTable({{name="Alice",score=950},{name="Bob",score=1200}})
  local sorted = df:sort("score", false)
  lurek.log.info("top scorer: " .. sorted:getValue(1, "name"))
  lurek.log.info("top score: " .. tostring(sorted:getValue(1, "score")))
  lurek.log.info("sorted rows: " .. tostring(sorted:nrows()))
end
--@api: LfromTable:sort
do
  -- Sort highscores descending for display.
  local df = lurek.dataframe.fromTable({
    { name = "Alice", score = 950 },
    { name = "Bob", score = 1200 },
    { name = "Carol", score = 870 },
  })
  local sorted = df:sort("score", false)
  lurek.log.info("top scorer row count: " .. sorted:nrows())
end
--@api: LDataFrame:head
do
-- Returns the first rows of this dataframe.
  -- head returns a new frame containing only the first N rows.
  local df = lurek.dataframe.fromTable({{item="Sword"},{item="Shield"},{item="Potion"},{item="Arrow"}})
  local preview = df:head(3)
  lurek.log.info("preview rows: " .. preview:nrows())
  lurek.log.info("preview first item: " .. tostring(preview:getValue(1, "item")))
  lurek.log.info("preview last item: " .. tostring(preview:getValue(preview:nrows(), "item")))
end
--@api: LfromTable:head
do
  -- Preview the first 3 inventory items for a quick tooltip.
  local df = lurek.dataframe.fromTable({
    { item = "Sword", qty = 1 },
    { item = "Shield", qty = 1 },
    { item = "Potion", qty = 5 },
    { item = "Arrow", qty = 20 },
  })
  local preview = df:head(3)
  lurek.log.debug("preview rows: " .. preview:nrows())
end
--@api: LDataFrame:tail
do
-- Returns the last rows of this dataframe.
  -- tail returns a new frame containing only the last N rows.
  local df = lurek.dataframe.fromTable({{turn=1},{turn=2},{turn=3},{turn=4}})
  local recent = df:tail(2)
  lurek.log.info("recent rows: " .. recent:nrows())
  lurek.log.info("recent first turn: " .. tostring(recent:getValue(1, "turn")))
  lurek.log.info("recent last turn: " .. tostring(recent:getValue(recent:nrows(), "turn")))
end
--@api: LfromTable:tail
do
  -- Show the most recent combat log entries.
  local df = lurek.dataframe.fromTable({
    { turn = 1, action = "attack" },
    { turn = 2, action = "defend" },
    { turn = 3, action = "heal" },
    { turn = 4, action = "flee" },
  })
  local recent = df:tail(2)
  lurek.log.debug("recent log rows: " .. recent:nrows())
end
--@api: LDataFrame:slice
do
-- Returns a one-based inclusive row slice.
  -- slice returns a 1-based inclusive row range as a new frame.
  local df = lurek.dataframe.fromTable({{r="Sword"},{r="Shield"},{r="Bow"},{r="Staff"},{r="Helm"},{r="Boots"}})
  local page2 = df:slice(4, 6)
  lurek.log.info("page 2 rows: " .. page2:nrows())
  lurek.log.info("page 2 first recipe: " .. tostring(page2:getValue(1, "r")))
  lurek.log.info("page 2 last recipe: " .. tostring(page2:getValue(page2:nrows(), "r")))
end
--@api: LfromTable:slice
do
  -- Paginate crafting recipes: show page 2 (rows 4-6).
  local df = lurek.dataframe.fromTable({
    { recipe = "Sword" }, { recipe = "Shield" }, { recipe = "Bow" },
    { recipe = "Staff" }, { recipe = "Helm" }, { recipe = "Boots" },
  })
  local page2 = df:slice(4, 6)
  lurek.log.debug("page 2 recipes: " .. page2:nrows())
end
--@api: LDataFrame:select
do
-- Returns a dataframe with selected columns.
  -- select returns a new frame with only the specified columns.
  local df = lurek.dataframe.fromTable({{name="Alice",score=950,guild="Knights"}})
  local view = df:select("name", "score")
  lurek.log.info("selected cols: " .. view:ncols())
  lurek.log.info("selected player: " .. tostring(view:getValue(1, "name")))
  lurek.log.info("selected score: " .. tostring(view:getValue(1, "score")))
end
--@api: LfromTable:select.2
do
  -- Extract only name and score for the leaderboard display.
  local df = lurek.dataframe.fromTable({
    { name = "Alice", score = 950, guild = "Knights" },
    { name = "Bob", score = 870, guild = "Mages" },
  })
  local view = df:select("name", "score")
  lurek.log.debug("selected cols: " .. view:ncols())
end
--@api: LDataFrame:merge
do
-- Appends another dataframe into this dataframe in place.
  -- merge appends another frame's rows into this frame in-place.
  local wave1 = lurek.dataframe.fromTable({{enemy="Goblin",hp=30}})
  local wave2 = lurek.dataframe.fromTable({{enemy="Orc",hp=80}})
  wave1:merge(wave2)
  lurek.log.info("combined spawn count: " .. wave1:nrows())
  lurek.log.info("first spawn: " .. tostring(wave1:getValue(1, "enemy")))
end
--@api: LfromTable:merge
do
  -- Merge wave-1 and wave-2 enemy lists into a combined spawn table.
  local wave1 = lurek.dataframe.fromTable({
    { enemy = "Goblin", hp = 30 },
  })
  local wave2 = lurek.dataframe.fromTable({
    { enemy = "Orc", hp = 80 },
  })
  wave1:merge(wave2)
  lurek.log.info("combined spawn count: " .. wave1:nrows())
end
--@api: LDataFrame:dropNil
do
-- Returns rows where the chosen column is not nil.
  -- dropNil returns a new frame with rows where the column is nil removed.
  local df = lurek.dataframe.fromTable({{item="Gem",rarity="rare"},{item="Rock",rarity=nil},{item="Ring",rarity="epic"}})
  local clean = df:dropNil("rarity")
  lurek.log.info("valid loot rows: " .. clean:nrows())
  lurek.log.info("first valid item: " .. tostring(clean:getValue(1, "item")))
  lurek.log.info("last valid rarity: " .. tostring(clean:getValue(clean:nrows(), "rarity")))
end
--@api: LfromTable:dropNil.2
do
  -- Remove loot entries with no rarity assigned before display.
  local df = lurek.dataframe.fromTable({
    { item = "Gem", rarity = "rare" },
    { item = "Rock", rarity = nil },
    { item = "Ring", rarity = "epic" },
  })
  local clean = df:dropNil("rarity")
  lurek.log.debug("valid loot rows: " .. clean:nrows())
end
--@api: LDataFrame:toJSON
do
-- Serializes this dataframe to JSON text.
  -- toJSON serialises the frame to a JSON array-of-objects string.
  local df = lurek.dataframe.fromTable({{stat="playtime",value=3600}})
  local json = df:toJSON()
  lurek.log.info("JSON length: " .. #json)
  lurek.log.info("json has key stat: " .. tostring(string.find(json, "stat", 1, true) ~= nil))
  lurek.log.info("json has value 3600: " .. tostring(string.find(json, "3600", 1, true) ~= nil))
end
--@api: LfromTable:toJSON
do
  -- Export save-game stats to a JSON string for cloud sync.
  local df = lurek.dataframe.fromTable({
    { stat = "playtime", value = 3600 },
    { stat = "deaths", value = 7 },
  })
  local json = df:toJSON()
  lurek.log.debug("json length: " .. #json)
end
--@api: LDataFrame:query
do
-- Runs a SQL-style query against this dataframe.
  -- query runs SQL against this frame (the frame is the table "t").
  local df = lurek.dataframe.fromTable({{item="Sword",gold=150},{item="Stick",gold=5}})
  local expensive = df:query("SELECT * FROM t WHERE gold > 100")
  lurek.log.info("expensive items: " .. expensive:nrows())
  lurek.log.info("first expensive item: " .. tostring(expensive:getValue(1, "item")))
  lurek.log.info("first expensive price: " .. tostring(expensive:getValue(1, "gold")))
end
--@api: LfromTable:query.2
do
  local df = lurek.dataframe.fromTable({
    { item = "Sword", gold = 150 },
    { item = "Stick", gold = 5 },
    { item = "Shield", gold = 120 },
  })
  local expensive = df:query("SELECT * FROM t WHERE gold > 100")
  example_print_log("expensive items", expensive:nrows())
  example_print_log(expensive:toString())
end
--@api: LDataFrame:schema
do
-- Inspect inferred column types and nullability before running a data pipeline.
  local df = lurek.dataframe.fromTable({ { name = "Alice", score = 10 }, { name = "Bob", score = nil } })
  local schema = df:schema()
  lurek.log.info("first column " .. tostring(schema[1].name) .. " " .. tostring(schema[1].dtype))
  lurek.log.info("score nullable " .. tostring(schema[2].nullable))
  lurek.log.info("schema entries " .. tostring(#schema))
end
--@api: LDataFrame:explain
do
-- Preview dataframe shape or SQL query structure for debugging.
  local df = lurek.dataframe.fromTable({ { item = "Sword", gold = 150 }, { item = "Stick", gold = 5 } })
  local plan = df:explain()
  local sql_plan = df:explain("SELECT item FROM self WHERE gold > 100 LIMIT 1")
  lurek.log.info(plan)
  lurek.log.info(sql_plan)
  lurek.log.info("explain rows " .. tostring(df:nrows()))
end
--@api: LDataFrame:type.2
do
-- Returns the Lua-visible type name for this dataframe handle.
  local df = lurek.dataframe.fromTable({{x=1}})
  lurek.log.info("type " .. tostring(df:type()))
  lurek.log.info("row/col shape: " .. df:nrows() .. "x" .. df:ncols())
  lurek.log.info("is dataframe " .. tostring(df:typeOf("LDataFrame")))
  lurek.log.info("row count " .. tostring(df:nrows()))
end
--@api: LfromTable:type
do
  local df = lurek.dataframe.fromTable({ { x = 1 } })
  lurek.log.info("df type " .. tostring(df:type()))
  lurek.log.info("columns snapshot: " .. table.concat(df:columns(), ", "))
  lurek.log.info("row count " .. tostring(df:nrows()))
  lurek.log.info("first x " .. tostring(df:getValue(1, "x")))
end
--@api: LDataFrame:typeOf.2
do
-- Returns whether this dataframe handle matches a supported type name.
  local df = lurek.dataframe.fromTable({{x=1}})
  lurek.log.info("is dataframe " .. tostring(df:typeOf("LDataFrame")))
  lurek.log.info("is object " .. tostring(df:typeOf("LObject")))
  lurek.log.info("type " .. tostring(df:type()))
  lurek.log.info("row count " .. tostring(df:nrows()))
end
--@api: LfromTable:head.2
do
  local df = lurek.dataframe.fromTable({ { x = 1 } })
  lurek.log.info("guard dataframe " .. tostring(df:typeOf("LDataFrame")))
  lurek.log.info("row/col shape: " .. df:nrows() .. "x" .. df:ncols())
  lurek.log.info("object guard " .. tostring(df:typeOf("LObject")))
  lurek.log.info("x value " .. tostring(df:getValue(1, "x")))
end
--@api: LDatabase:type
do
-- Returns the Lua-visible type name for this database handle.
  local db = lurek.dataframe.newDatabase()
  lurek.log.info("db type " .. tostring(db:type()))
  lurek.log.info("db rows: " .. tostring(db:nrows()))
  lurek.log.info("table count " .. tostring(db:tableCount()))
  lurek.log.info("is database " .. tostring(db:typeOf("LDatabase")))
end
--@api: LDatabase:type.2
do
  local db = lurek.dataframe.newDatabase()
  lurek.log.info("db type again " .. tostring(db:type()))
  lurek.log.info("db cols: " .. tostring(db:ncols()))
  lurek.log.info("is database " .. tostring(db:typeOf("LDatabase")))
  lurek.log.info("table count again " .. tostring(db:tableCount()))
end
--@api: LDatabase:typeOf
do
-- Returns whether this database handle matches a supported type name.
  local db = lurek.dataframe.newDatabase()
  lurek.log.info("is database " .. tostring(db:typeOf("LDatabase")))
  lurek.log.info("is object " .. tostring(db:typeOf("LObject")))
  lurek.log.info("db type " .. tostring(db:type()))
  lurek.log.info("table count " .. tostring(db:tableCount()))
end
--@api: LDatabase:Year
do
  local db = lurek.dataframe.newDatabase()
  lurek.log.info("database guard " .. tostring(db:typeOf("LDatabase")))
  lurek.log.info("db cols: " .. tostring(db:ncols()))
  lurek.log.info("object guard " .. tostring(db:typeOf("LObject")))
  lurek.log.info("table count " .. tostring(db:tableCount()))
end
--@api: LGroupedFrame:type
do
-- Returns the Lua-visible type name for this grouped frame handle.
  local df = lurek.dataframe.fromTable({{team="red",score=10},{team="blue",score=20}})
  local grouped = df:groupByObj("team")
  lurek.log.info("grouped type " .. tostring(grouped:type()))
  lurek.log.info("grouped handle " .. tostring(grouped))
  lurek.log.info("is grouped object " .. tostring(grouped:typeOf("LObject")))
end
--@api: LfromTable:groupByObj
do
  local df = lurek.dataframe.fromTable({
    { team = "red", score = 10 },
    { team = "blue", score = 20 },
  })
  local grouped = df:groupByObj("team")
  example_print_log("grouped type again", grouped:type())
end
--@api: LGroupedFrame:typeOf
do
-- Returns whether this grouped frame handle matches a supported type name.
  local df = lurek.dataframe.fromTable({{team="red",score=10},{team="blue",score=20}})
  local grouped = df:groupByObj("team")
  lurek.log.info("is grouped frame " .. tostring(grouped:typeOf("LGroupedFrame")))
  lurek.log.info("is object " .. tostring(grouped:typeOf("LObject")))
  lurek.log.info("grouped type " .. tostring(grouped:type()))
end
--@api: LfromTable:head.3
do
  local df = lurek.dataframe.fromTable({
    { team = "red", score = 10 },
    { team = "blue", score = 20 },
  })
  local grouped = df:groupByObj("team")
  example_print_log("grouped guard", grouped:typeOf("LGroupedFrame"))
end
--@api: LLazyQuery:limit
do
-- Adds a row limit step to the lazy query.
  local df = lurek.dataframe.fromTable({{n=1},{n=2},{n=3},{n=4},{n=5},{n=6}})
  local q = df:lazy():limit(5)
  local result = q:collect()
  example_print_log("rows after limit", result:nrows())
  example_print_log(result:toString())
end
--@api: LfromTable:lazy.3
do
  local df = lurek.dataframe.fromTable({
    { name = "A", score = 10 }, { name = "B", score = 20 },
    { name = "C", score = 30 }, { name = "D", score = 40 },
    { name = "E", score = 50 }, { name = "F", score = 60 },
  })
  local lazy = df:lazy():limit(5)
  local result = lazy:collect()
  example_print_log("limited rows", result:nrows())
end
--@api: LLazyQuery:collect
do
-- Executes the lazy query and returns a dataframe.
  local df = lurek.dataframe.fromTable({{item="Sword",gold=150},{item="Stick",gold=5}})
  local result = df:lazy():limit(10):collect()
  lurek.log.info("collected rows " .. tostring(result:nrows()))
  lurek.log.info("first collected item " .. tostring(result:getValue(1, "item")))
  lurek.log.info(result:toString())
end
--@api: LfromTable:lazy.4
do
  local df = lurek.dataframe.fromTable({
    { item = "Sword", gold = 150 },
    { item = "Stick", gold = 5 },
  })
  local result = df:lazy():limit(10):collect()
  example_print_log("collected rows again", result:nrows())
end
--@api: LLazyQuery:type
do
-- Returns the Lua-visible type name for this lazy query handle.
  local df = lurek.dataframe.fromTable({{x=1}})
  local lq = df:lazy()
  lurek.log.info("lazy type " .. tostring(lq:type()))
  lurek.log.info("is object " .. tostring(lq:typeOf("LObject")))
  lurek.log.info("source rows " .. tostring(df:nrows()))
end
--@api: LfromTable:lazy.5
do
  local df = lurek.dataframe.fromTable({ { x = 1 } })
  local lq = df:lazy()
  lurek.log.info("lazy type again " .. tostring(lq:type()))
  lurek.log.info("lazy is object " .. tostring(lq:typeOf("LObject")))
  lurek.log.info("source rows " .. tostring(df:nrows()))
end
--@api: LLazyQuery:typeOf
do
-- Returns whether this lazy query handle matches a supported type name.
  local df = lurek.dataframe.fromTable({{x=1}})
  local lq = df:lazy()
  lurek.log.info("is lazy query " .. tostring(lq:typeOf("LLazyQuery")))
  lurek.log.info("is object " .. tostring(lq:typeOf("LObject")))
  lurek.log.info("lazy type " .. tostring(lq:type()))
end
--@api: LfromTable:head.4
do
  local df = lurek.dataframe.fromTable({ { x = 1 } })
  local lq = df:lazy()
  lurek.log.info("lazy guard " .. tostring(lq:typeOf("LLazyQuery")))
  lurek.log.info("lazy object guard " .. tostring(lq:typeOf("LObject")))
  lurek.log.info("lazy type " .. tostring(lq:type()))
end

--@api: lurek.dataframe.fromCSVFile
do
  local path = "save/dataframe_example.csv"
  local source = lurek.dataframe.fromRows({ "name", "score" }, { { "Alice", 10 }, { "Bob", 20 } })
  source:toCSVFile(path)
  local df = lurek.dataframe.fromCSVFile(path)
  example_print_log("csv rows", df:nrows())
  example_print_log(df:head(1):toString())
end

--@api: lurek.dataframe.fromCSVFileAsync
do
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

--@api: lurek.dataframe.fromJSONFile
do
  local path = "save/dataframe_example.json"
  local source = lurek.dataframe.fromRows({ "name", "score" }, { { "Alice", 10 }, { "Bob", 20 } })
  source:toJSONFile(path)
  local df = lurek.dataframe.fromJSONFile(path)
  example_print_log("json rows", df:nrows())
  local columns = df:columns()
  example_print_log("Loaded schema:", table.concat(columns, ", "))
end

--@api: lurek.dataframe.fromJSONFileAsync
do
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

--@api: lurek.dataframe.loadDatabase
do
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

--@api: LDataFrame:valueCounts
do
  local df = lurek.dataframe.fromTable({
    {class = "Warrior"},
    {class = "Mage"},
    {class = "Warrior"},
  })
  local counts = df:valueCounts("class")
  example_print_log("value counts rows", counts:nrows())
  example_print_log(counts:toString())
end

--@api: LDataFrame:missingReport
do
  local df = lurek.dataframe.fromTable({
    {score = 100},
    {score = nil},
    {score = 200},
  })
  local report = df:missingReport()
  example_print_log("missing report rows", report:nrows())
  example_print_log(report:toString())
end

--@api: LDataFrame:duplicateRows
do
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

--@api: LDataFrame:dateParts
do
  local df = lurek.dataframe.fromTable({
    {login_date = "2026-05-21"},
  })
  local parts = df:dateParts("login_date")
  local row = parts:getRow(1)
  example_print_log("date parts rows", parts:nrows())
  example_print_log("year", row.year, "month", row.month, "day", row.day)
end

--@api: LDataFrame:toCSVFile
do
  local df = lurek.dataframe.fromTable({
    {score = 500},
    {score = 725},
  })
  local ok = df:toCSVFile("save/output.csv")
  example_print_log("csv saved", ok)
  example_print_log("csv preview", df:toCSV())
end

--@api: LDataFrame:toJSONFile
do
  local df = lurek.dataframe.fromTable({
    {name = "Alice"},
    {name = "Bob"},
  })
  local ok = df:toJSONFile("save/output.json")
  example_print_log("json saved", ok)
  example_print_log("json preview", df:toJSON())
end

--@api: LDataFrame:toBinaryFile
do
  local df = lurek.dataframe.fromTable({
    {level = 42},
    {level = 43},
  })
  local ok = df:toBinaryFile("save/output.lvdf")
  example_print_log("binary saved", ok)
  example_print_log("binary bytes", #df:toBinary())
end

--@api: LDataFrame:queryAsync
do
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

--@api: LDataFrameTask:isDone
do
  local path = "save/dataframe_task_status.csv"
  local source = lurek.dataframe.fromRows({ "name", "score" }, { { "Alice", 10 }, { "Bob", 20 } })
  source:toCSVFile(path)
  local task = lurek.dataframe.fromCSVFileAsync(path)
  example_print_log("done before wait", task:isDone())
  task:wait()
  example_print_log("done after wait", task:isDone())
end

--@api: LDataFrameTask:wait
do
  local path = "save/dataframe_task_wait.json"
  local source = lurek.dataframe.fromRows({ "name", "score" }, { { "Alice", 10 }, { "Bob", 20 } })
  source:toJSONFile(path)
  local task = lurek.dataframe.fromJSONFileAsync(path)
  example_print_log("waiting for task")
  task:wait()
  example_print_log("task error", task:getError())
end

--@api: LDataFrameTask:result
do
  local df = lurek.dataframe.fromRows({ "id" }, { { 1 }, { 2 } })
  local task = df:queryAsync("SELECT * FROM t WHERE id = 1")
  task:wait()
  local result_df = task:result()
  example_print_log("result rows", result_df:nrows())
  example_print_log(result_df:toString())
end

--@api: LDataFrameTask:getError
do
  local path = "save/dataframe_task_error.csv"
  local source = lurek.dataframe.fromRows({ "name", "score" }, { { "Alice", 10 }, { "Bob", 20 } })
  source:toCSVFile(path)
  local task = lurek.dataframe.fromCSVFileAsync(path)
  task:wait()
  example_print_log("task error", task:getError())
end

--@api: LDataFrameTask:progress
do
  local path = "save/dataframe_task_progress.csv"
  local source = lurek.dataframe.fromRows({ "name", "score" }, { { "Alice", 10 }, { "Bob", 20 } })
  source:toCSVFile(path)
  local task = lurek.dataframe.fromCSVFileAsync(path)
  example_print_log("initial progress", task:progress())
  task:wait()
  example_print_log("final progress", task:progress())
end

--@api: LDataFrameTask:type
do
  local df = lurek.dataframe.fromRows({ "id" }, { { 1 }, { 2 } })
  local task = df:queryAsync("SELECT * FROM t WHERE id = 1")
  local type_name = task:type()
  example_print_log("task type", type_name)
  if type_name == "LDataFrameTask" then
    example_print_log("This is indeed a DataFrameTask")
  end
  task:wait()
end

--@api: LDataFrameTask:typeOf
do
  local df = lurek.dataframe.fromRows({ "id" }, { { 1 }, { 2 } })
  local task = df:queryAsync("SELECT * FROM t WHERE id = 1")
  local is_task = task:typeOf("LDataFrameTask")
  example_print_log("is dataframe task", is_task)
  if is_task then
    example_print_log("Object is verified as DataFrameTask")
  end
  task:wait()
end

--@api: LDatabase:save
do
  local db = lurek.dataframe.newDatabase()
  local df = lurek.dataframe.fromTable({
    {score = 100},
  })
  db:addTable("savegame_stats", df)
  local success = db:save("save/savegame_stats.json")
  example_print_log("database saved", success)
end

--@api: LDatabase:queryAsync
do
  local db = lurek.dataframe.newDatabase()
  local users = lurek.dataframe.fromRows({ "age" }, { { 25 }, { 30 } })
  db:addTable("users", users)
  local task = db:queryAsync("SELECT * FROM users WHERE age > 26")
  example_print_log("database query task", task:type())
  task:wait()
  local result_df = task:result()
  example_print_log("Async query finished, resulting rows: " .. result_df:nrows())
end

--@api: LDatabase:queryParams
do
  local db = lurek.dataframe.newDatabase()
  local users = lurek.dataframe.fromRows({ "name" }, { { "Alice" }, { "Bob" } })
  db:addTable("users", users)
  local result = db:queryParams("SELECT * FROM users WHERE name = ?", {"Alice"})
  example_print_log("query params rows", result:nrows())
  example_print_log(result:toString())
end

--@api: LDatabase:queryParamsAsync
do
  local db = lurek.dataframe.newDatabase()
  local players = lurek.dataframe.fromRows({ "level" }, { { 10 }, { 20 } })
  db:addTable("players", players)
  local task = db:queryParamsAsync("SELECT * FROM players WHERE level > ?", {15})
  task:wait()
  local result = task:result()
  example_print_log("async param rows", result:nrows())
  example_print_log(result:toString())
end

--@api: LDataFrame:parFilter
do
  local df = lurek.dataframe.fromRows({ "x" }, { {1}, {2}, {3}, {4}, {5}, {6} })
  local out = df:parFilter("x", ">", 3)
  lurek.log.info("parFilter rows " .. tostring(out:nrows()))
  lurek.log.info("parFilter first kept " .. tostring(out:getValue(1, "x")))
  lurek.log.info(out:toString())
end

--@api: LDataFrame:parGroupAgg
do
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
