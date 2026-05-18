-- content/examples/dataframe.lua
-- lurek.dataframe API examples: tabular data for analytics, leaderboards, item databases, and stat tracking.
-- Run: cargo run -- content/examples/dataframe.lua
--@api-stub: lurek.dataframe.newDataFrame
-- Builds an empty dataframe for runtime session data
do
  -- Start with no schema when rows will arrive during play.
  local scoreboard = lurek.dataframe.newDataFrame()
  scoreboard:addColumn("pilot", "")
  scoreboard:addColumn("score", 0)
  scoreboard:addColumn("lives", 3)

  -- Missing fields use the column default, so this row keeps three lives.
  local row = scoreboard:addRow({pilot = "Mira", score = 4200})
  scoreboard:setValue(row, "score", 4500)

  lurek.log.info("scoreboard rows=" .. tostring(scoreboard:nrows()))
end
--@api-stub: lurek.dataframe.newDatabase
-- Groups named dataframes for game data
do
  -- Use a database when a save or mod pack has several related tables.
  local db = lurek.dataframe.newDatabase()
  local players = lurek.dataframe.fromTable({
    {id = 1, name = "Mira", class = "scout"},
  })
  local items = lurek.dataframe.fromTable({
    {id = 7, name = "coil blade", rarity = "rare"},
  })

  -- Table names become stable handles for queries and debug tools.
  db:addTable("players", players)
  db:addTable("items", items)

  lurek.log.info("campaign tables=" .. tostring(db:tableCount()))
end
--@api-stub: lurek.dataframe.fromTable
-- Creates a dataframe from keyed Lua rows
do
  -- Keyed rows are easy to read in hand-authored balance data.
  local enemies = lurek.dataframe.fromTable({
    {id = 1, kind = "drone", hp = 30, damage = 5, xp = 10},
    {id = 2, kind = "brute", hp = 90, damage = 18, xp = 35},
    {id = 3, kind = "warden", hp = 160, damage = 26, xp = 80},
  })

  -- The first row defines the starting schema; later rows can fill it.
  lurek.log.info("enemy rows=" .. tostring(enemies:nrows()))
end
--@api-stub: lurek.dataframe.fromRows
-- Creates a dataframe from positional rows
do
  -- Positional rows match network packets or binary logs with known order.
  local columns = {"tick", "ship", "x", "y"}
  local rows = {
    {10, "alpha", 12.5,  4.0},
    {11, "alpha", 13.0,  4.5},
    {12, "beta",  -2.0, 18.0},
  }

  local telemetry = lurek.dataframe.fromRows(columns, rows)
  lurek.log.info("tracked ship=" .. tostring(telemetry:getValue(2, "ship")))
end
--@api-stub: lurek.dataframe.fromCSV
-- Parses CSV text into a dataframe
do
  -- CSV works well for designer-owned tables exported from spreadsheets.
  local csv = "recipe,ore,seconds\nmedkit,2,4\nturret,5,12\nbeacon,3,8\n"
  local recipes = lurek.dataframe.fromCSV(csv)

  -- Numeric columns can be used immediately by statistics helpers.
  lurek.log.info("average craft time=" .. string.format("%.1f", recipes:mean("seconds")))
end
--@api-stub: lurek.dataframe.fromJSON
-- Parses a JSON array of objects
do
  -- JSON is useful for web tools, save payloads, or launcher data.
  local json = '[{"id":1,"quest":"signal","state":"open"},{"id":2,"quest":"forge","state":"done"}]'
  local quests = lurek.dataframe.fromJSON(json)

  lurek.log.info("quest rows=" .. tostring(quests:nrows()))
end
--@api-stub: lurek.dataframe.fromBinary
-- Restores a dataframe from binary data
do
  -- Binary round trips keep the dataframe compact for save snapshots.
  local snapshot = lurek.dataframe.fromTable({
    {entity = "player", x = 18.5, y = 7.0, hp = 88},
    {entity = "companion", x = 17.0, y = 7.5, hp = 64},
  })

  local blob = snapshot:toBinary()
  local restored = lurek.dataframe.fromBinary(blob)

  lurek.log.info("binary restore hp=" .. tostring(restored:getValue(1, "hp")))
end
--@api-stub: lurek.dataframe.random
-- Generates reproducible sample data
do
  -- random() is handy for stress-testing UI tables without hand-writing rows.
  local defs = {
    {"npc_id", "id"},
    {"name", "name"},
    {"threat", "int"},
    {"rare_spawn", "bool"},
  }

  -- The seed keeps generated rows stable between test runs.
  local npc_pool = lurek.dataframe.random(defs, 12, 42)
  lurek.log.info("generated npc rows=" .. tostring(npc_pool:nrows()))
end
--@api-stub: LDataFrame:nrows
-- Returns the number of dataframe rows
do
  -- Guard game UI before reading the first row.
  local party = lurek.dataframe.fromTable({
    {slot = 1, hero = "Mira", hp = 80},
    {slot = 2, hero = "Sol", hp = 55},
    {slot = 3, hero = "Ren", hp = 72},
  })

  if party:nrows() > 0 then
    lurek.log.info("party size=" .. tostring(party:nrows()))
  end
end
--@api-stub: LDataFrame:ncols
-- Returns the number of dataframe columns
do
  -- Use ncols to size debug table headers or stat grids.
  local loot = lurek.dataframe.fromTable({
    {item = "medkit", rarity = "common", price = 30, stock = 4},
  })

  lurek.log.info("loot schema width=" .. tostring(loot:ncols()))
end
--@api-stub: LDataFrame:columns
-- Returns ordered column names
do
  -- Build a compact header row for a debug overlay.
  local stats = lurek.dataframe.fromRows(
    {"stat", "base", "bonus"},
    {{"attack", 10, 3}, {"defense", 8, 1}}
  )

  local headers = stats:columns()
  lurek.log.info("stat columns=" .. table.concat(headers, ","))
end
--@api-stub: LDataFrame:count
-- Returns the row count alias
do
  -- count() mirrors nrows(), which is useful in generic table widgets.
  local events = lurek.dataframe.fromTable({
    {kind = "spawn", tick = 1},
    {kind = "loot", tick = 8},
    {kind = "checkpoint", tick = 21},
  })

  lurek.log.info("event count=" .. tostring(events:count()))
end
--@api-stub: LDataFrame:removeColumn
-- Removes a column from a dataframe
do
  -- Strip debug-only fields before showing data to players.
  local leaderboard = lurek.dataframe.fromTable({
    {name = "Mira", score = 9500, debug_seed = 181},
    {name = "Sol", score = 8700, debug_seed = 182},
  })

  leaderboard:removeColumn("debug_seed")
  lurek.log.info("public columns=" .. tostring(leaderboard:ncols()))
end
--@api-stub: LDataFrame:rename
-- Renames a column by name or index
do
  -- Normalize imported labels before game code depends on them.
  local imported = lurek.dataframe.fromCSV("Player Name,Pts\nMira,1200\nSol,980\n")

  imported:rename("Player Name", "player")
  imported:rename("Pts", "score")

  lurek.log.info("renamed columns=" .. table.concat(imported:columns(), ","))
end
--@api-stub: LDataFrame:getColumn
-- Reads a column as a Lua array
do
  -- Pull one stat into an array for custom UI bars or local math.
  local damage_log = lurek.dataframe.fromTable({
    {hit = 1, damage = 12},
    {hit = 2, damage = 18},
    {hit = 3, damage = 9},
  })

  local damage = damage_log:getColumn("damage")
  lurek.log.info("first hit damage=" .. tostring(damage[1]) .. ", hits=" .. tostring(#damage))
end
--@api-stub: LDataFrame:addRow
-- Appends a row and returns its index
do
  -- Add rows as game events happen, then keep the row id for follow-up edits.
  local event_log = lurek.dataframe.newDataFrame()
  event_log:addColumn("kind", "")
  event_log:addColumn("time_s", 0)
  event_log:addColumn("player", "")

  local index = event_log:addRow({kind = "boss_clear", time_s = 125.4, player = "Mira"})
  event_log:setValue(index, "time_s", 124.9)

  lurek.log.info("event row=" .. tostring(index))
end
--@api-stub: LDataFrame:removeRow
-- Removes a row by one-based index
do
  -- Remove a disconnected player before matchmaking starts.
  local roster = lurek.dataframe.fromTable({
    {name = "Mira", status = "ready"},
    {name = "Sol", status = "left"},
    {name = "Ren", status = "ready"},
  })

  roster:removeRow(2)
  lurek.log.info("ready roster=" .. tostring(roster:nrows()))
end
--@api-stub: LDataFrame:getRow
-- Reads one row as a keyed table
do
  -- Fetch a complete inventory slot for gameplay code.
  local inventory = lurek.dataframe.fromTable({
    {slot = 1, item = "medkit", qty = 5},
    {slot = 2, item = "coil blade", qty = 1},
  })

  local slot = inventory:getRow(2)
  lurek.log.info("equipped " .. tostring(slot.item) .. " x" .. tostring(slot.qty))
end
--@api-stub: LDataFrame:getValue
-- Reads one cell by row and column
do
  -- Cell lookup is useful for quick HUD checks.
  local party = lurek.dataframe.fromTable({
    {name = "Mira", hp = 80, max_hp = 100},
    {name = "Sol", hp = 15, max_hp = 100},
  })

  for row = 1, party:nrows() do
    local hp = tonumber(party:getValue(row, "hp")) or 0
    if hp < 30 then
      lurek.log.info(tostring(party:getValue(row, "name")) .. " needs healing")
    end
  end
end
--@api-stub: LDataFrame:head
-- Returns the first rows as a new dataframe
do
  -- Preview a long table without dumping every row to the log.
  local queue = lurek.dataframe.fromRows(
    {"rank", "player", "score"},
    {{1, "Mira", 9500}, {2, "Sol", 8700}, {3, "Ren", 8300}, {4, "Ivo", 7600}}
  )

  local podium = queue:head(3)
  lurek.log.info("podium rows=" .. tostring(podium:nrows()))
end
--@api-stub: LDataFrame:tail
-- Returns the last rows as a new dataframe
do
  -- Event logs often need the latest entries, not the whole history.
  local events = lurek.dataframe.fromRows(
    {"tick", "kind"},
    {{1, "spawn"}, {8, "loot"}, {13, "hit"}, {21, "checkpoint"}}
  )

  local recent = events:tail(2)
  lurek.log.info("recent rows=" .. tostring(recent:nrows()))
end
--@api-stub: LDataFrame:slice
-- Returns an inclusive row range
do
  -- Slice pages a shop list without copying unrelated rows.
  local shop = lurek.dataframe.random({{"id", "id"}, {"name", "name"}, {"price", "int"}}, 30, 2)

  local page_two = shop:slice(11, 20)
  lurek.log.info("shop page rows=" .. tostring(page_two:nrows()))
end
--@api-stub: LDataFrame:select
-- Keeps selected columns in a new dataframe
do
  -- Create a player-facing view from a larger internal record.
  local roster = lurek.dataframe.fromTable({
    {callsign = "Mira", rank = 1, ready = true, secret_seed = 77},
    {callsign = "Sol", rank = 2, ready = false, secret_seed = 88},
  })

  local public = roster:select("callsign", "rank", "ready")
  lurek.log.info("public columns=" .. table.concat(public:columns(), ","))
end
--@api-stub: LDataFrame:unique
-- Returns unique values from one column
do
  -- Distinct values are useful for filters and summary chips.
  local spawns = lurek.dataframe.fromTable({
    {enemy = "drone", zone = "hangar"},
    {enemy = "brute", zone = "reactor"},
    {enemy = "drone", zone = "bridge"},
    {enemy = "warden", zone = "reactor"},
  })

  local enemy_types = spawns:unique("enemy")
  lurek.log.info("enemy type count=" .. tostring(#enemy_types))
end
--@api-stub: LDataFrame:groupBy
-- Groups rows into keyed dataframes
do
  -- Split encounter data by biome for local balancing.
  local encounters = lurek.dataframe.fromTable({
    {biome = "ice", enemy = "drone", threat = 3},
    {biome = "lava", enemy = "brute", threat = 8},
    {biome = "ice", enemy = "warden", threat = 6},
    {biome = "lava", enemy = "drone", threat = 4},
  })

  local by_biome = encounters:groupBy("biome")
  lurek.log.info("ice encounters=" .. tostring(by_biome["ice"]:nrows()))
end
--@api-stub: LDataFrame:merge
-- Appends rows from another dataframe
do
  -- Merge per-round rewards into one match history.
  local round_one = lurek.dataframe.fromTable({
    {player = "Mira", credits = 120},
    {player = "Sol", credits = 90},
  })
  local round_two = lurek.dataframe.fromTable({
    {player = "Mira", credits = 160},
    {player = "Ren", credits = 110},
  })

  round_one:merge(round_two)
  lurek.log.info("merged reward rows=" .. tostring(round_one:nrows()))
end
--@api-stub: LDataFrame:countBy
-- Counts occurrences of values in a column
do
  -- Frequency tables highlight common drops or popular choices.
  local loot_drops = lurek.dataframe.fromTable({
    {item = "medkit"}, {item = "credits"}, {item = "medkit"},
    {item = "core"}, {item = "credits"}, {item = "medkit"},
  })

  local frequency = loot_drops:countBy("item")
  lurek.log.info("loot groups=" .. tostring(frequency:nrows()))
end
--@api-stub: LDataFrame:dropNil
-- Drops rows with nil in a chosen column
do
  -- Remove incomplete feedback before computing satisfaction scores.
  local feedback = lurek.dataframe.fromTable({
    {player = "Mira", rating = 5, note = "fast"},
    {player = "Sol", rating = nil, note = "left early"},
    {player = "Ren", rating = 4, note = "clear"},
  })

  local valid = feedback:dropNil("rating")
  lurek.log.info("rated sessions=" .. tostring(valid:nrows()))
end
--@api-stub: LDataFrame:sample
-- Returns a random subset of rows
do
  -- Seeded sampling gives reproducible encounter previews.
  local all_mobs = lurek.dataframe.random({{"id", "id"}, {"name", "name"}, {"hp", "int"}}, 50, 9)

  local floor_pack = all_mobs:sample(5, 123)
  lurek.log.info("sampled floor mobs=" .. tostring(floor_pack:nrows()))
end
--@api-stub: LDataFrame:describe
-- Returns descriptive statistics for numeric columns
do
  -- Use describe() for a quick balance pass over numeric combat logs.
  local combat_log = lurek.dataframe.fromTable({
    {damage = 12, healing = 0},
    {damage = 24, healing = 6},
    {damage = 8, healing = 12},
    {damage = 30, healing = 0},
  })

  local summary = combat_log:describe()
  lurek.log.info("stat rows=" .. tostring(summary:nrows()))
end
--@api-stub: LDataFrame:sum
-- Sums a numeric column
do
  -- Sum total combo damage for scoring and achievements.
  local hits = lurek.dataframe.fromTable({
    {source = "slash", damage = 12},
    {source = "dash", damage = 18},
    {source = "finisher", damage = 45},
  })

  local total = hits:sum("damage")
  lurek.log.info("combo damage=" .. tostring(total))
end
--@api-stub: LDataFrame:mean
-- Computes the average of a numeric column
do
  -- Average frame time is easier to scan than a full trace.
  local frame_stats = lurek.dataframe.fromTable({
    {frame = 1, dt_ms = 16.1},
    {frame = 2, dt_ms = 16.4},
    {frame = 3, dt_ms = 32.0},
    {frame = 4, dt_ms = 15.9},
  })

  local avg_dt = frame_stats:mean("dt_ms")
  lurek.log.info("average frame ms=" .. string.format("%.1f", avg_dt))
end
--@api-stub: LDataFrame:min
-- Finds the minimum value in a column
do
  -- Minimum time is the best speedrun attempt.
  local speedrun = lurek.dataframe.fromTable({
    {attempt = 1, time_s = 142.5},
    {attempt = 2, time_s = 138.2},
    {attempt = 3, time_s = 145.0},
  })

  local best = speedrun:min("time_s")
  lurek.log.info("best time=" .. tostring(best) .. "s")
end
--@api-stub: LDataFrame:max
-- Finds the maximum value in a column
do
  -- Maximum score marks the season best.
  local season_scores = lurek.dataframe.fromTable({
    {week = 1, score = 1200},
    {week = 2, score = 4500},
    {week = 3, score = 3800},
  })

  local high_score = season_scores:max("score")
  lurek.log.info("season high score=" .. tostring(high_score))
end
--@api-stub: LDataFrame:median
-- Computes the median of a numeric column
do
  -- Median gives a stable typical value when one sample spikes.
  local frame_times = lurek.dataframe.fromTable({
    {ms = 16}, {ms = 16}, {ms = 17}, {ms = 200},
  })

  local typical = frame_times:median("ms")
  lurek.log.info("typical frame ms=" .. tostring(typical))
end
--@api-stub: LDataFrame:stddev
-- Computes standard deviation for a column
do
  -- Low spread means the weapon is predictable; high spread feels swingy.
  local damage_rolls = lurek.dataframe.fromTable({
    {roll = 10}, {roll = 12}, {roll = 11}, {roll = 28}, {roll = 9},
  })

  local spread = damage_rolls:stddev("roll")
  lurek.log.info("damage spread=" .. string.format("%.2f", spread))
end
--@api-stub: LDataFrame:variance
-- Computes variance for a numeric column
do
  -- Variance is useful when comparing balance sets offline.
  local weapon_tests = lurek.dataframe.fromTable({
    {damage = 18}, {damage = 20}, {damage = 17}, {damage = 24},
  })

  local variance = weapon_tests:variance("damage")
  lurek.log.info("weapon variance=" .. string.format("%.1f", variance))
end
--@api-stub: LDataFrame:fillNil
-- Replaces nil cells in one column
do
  -- Fill missing scores before showing totals.
  local scores = lurek.dataframe.fromTable({
    {player = "Mira", score = 10},
    {player = "Sol", score = nil},
    {player = "Ren", score = 5},
  })

  scores:fillNil("score", 0)
  lurek.log.info("filled score total=" .. tostring(scores:sum("score")))
end
--@api-stub: LDataFrame:toCSV
-- Serializes a dataframe to CSV text
do
  -- Keep the CSV in memory for a copy button or debug console.
  local leaderboard = lurek.dataframe.fromTable({
    {rank = 1, name = "Mira", score = 9500},
    {rank = 2, name = "Sol", score = 8200},
  })

  local csv = leaderboard:toCSV()
  lurek.log.info("csv bytes=" .. tostring(#csv))
end
--@api-stub: LDataFrame:toJSON
-- Serializes a dataframe to JSON text
do
  -- JSON is convenient for UI panels or external tooling payloads.
  local save_slots = lurek.dataframe.fromTable({
    {slot = 1, name = "Station", playtime_s = 3600},
    {slot = 2, name = "Outpost", playtime_s = 1200},
  })

  local json = save_slots:toJSON()
  lurek.log.info("json bytes=" .. tostring(#json))
end
--@api-stub: LDataFrame:toBinary
-- Serializes this dataframe to a compact binary format
do
  -- toBinary is the most space-efficient and fastest serialization.
  -- Use it for autosave, network sync, or large dataset caching.
  local world_state = lurek.dataframe.fromTable({
    {entity_id = 1, x = 10.5, y = 20.3, hp = 100},
    {entity_id = 2, x = -5.0, y = 12.7, hp = 45},
  })

  local blob = world_state:toBinary()
  lurek.log.info("binary size: " .. #blob .. " bytes")
end
--@api-stub: LDataFrame:toTable
-- Converts this dataframe to a plain Lua array of row tables
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
--@api-stub: LDataFrame:rows
-- Returns an iterator for use in for-loops (index, row_table)
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
--@api-stub: LDataFrame:toString
-- Formats this dataframe as a human-readable aligned text table
do
  -- toString() produces a pretty-printed table for debug output or console display.
  local party = lurek.dataframe.fromTable({
    {name = "Alice", hp = 80, class = "warrior"},
    {name = "Bob", hp = 50, class = "mage"},
  })

  -- Great for lurek.log.info during development
  lurek.log.info("party:\n" .. party:toString())
end
--@api-stub: LDataFrame:query
-- Runs a SQL SELECT query against this dataframe (table alias is "t")
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
--@api-stub: LDataFrame:clone
-- Returns a deep copy of this dataframe (modifications don't affect the original)
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
--@api-stub: LDataFrame:correlationMatrix
-- Returns a correlation matrix dataframe for all numeric columns
do
  -- correlationMatrix shows how numeric columns relate to each other.
  -- Values near 1 or -1 indicate strong correlation (useful for game balance).
  local balance = lurek.dataframe.random({{"damage", "int"}, {"cost", "int"}, {"weight", "int"}}, 50, 5)

  -- Check if high-damage weapons are also the most expensive (should they be?)
  local matrix = balance:correlationMatrix()
  lurek.log.info("correlation:\n" .. matrix:toString())
end
--@api-stub: LDataFrame:modeVal
-- Returns the most frequently occurring value in a column
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
--@api-stub: LDataFrame:entropy
-- Returns the Shannon entropy of a column (measures diversity)
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
--@api-stub: LDataFrame:addRowBatch
-- Appends multiple rows at once from positional arrays (faster than repeated addRow)
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
--@api-stub: LDataFrame:getColumnAsF64
-- Returns a numeric column as an array of Lua numbers (float64)
do
  -- getColumnAsF64 extracts numeric data as a flat number array.
  -- Useful for feeding into math functions or VecFrame operations.
  local df = lurek.dataframe.random({{"hp", "int"}}, 16, 6)

  -- Returns a plain array of numbers
  local hp_values = df:getColumnAsF64("hp")
  lurek.log.info("first entity HP = " .. hp_values[1])
end
--@api-stub: LDataFrame:setColumnFromF64
-- Replaces a numeric column's values from an array of numbers
do
  -- setColumnFromF64 bulk-writes computed values back into a column.
  -- Use after external math processing.
  local df = lurek.dataframe.fromTable({{x = 0}, {x = 0}, {x = 0}})

  -- Overwrite the "x" column with computed values
  df:setColumnFromF64("x", {1.5, 2.5, 3.5})
  lurek.log.info("sum of x after set: " .. df:sum("x"))  -- 7.5
end
--@api-stub: LDataFrame:type
-- Returns the type name string "DataFrame" for this handle
do
  -- type() and typeOf() let you do runtime type checking on dataframe handles.
  local df = lurek.dataframe.newDataFrame()
  if df:type() == "DataFrame" then
    lurek.log.info("confirmed: this is a DataFrame handle")
  end
end
--@api-stub: LDataFrame:typeOf
-- Returns true if this handle matches the given type name
do
  -- typeOf checks against "LDataFrame", "DataFrame", or "Object".
  -- Useful for generic functions that accept multiple handle types.
  local df = lurek.dataframe.newDataFrame()
  if df:typeOf("Object") then
    lurek.log.info("DataFrame is an Object (all handles are)")
  end
end
--@api-stub: LDataFrame:withEval
-- Returns a new dataframe with an added column computed from an expression
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
--@api-stub: LDatabase:getTable
-- Returns a copy of a named table from the database (or nil if not found)
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
--@api-stub: LDatabase:removeTable
-- Removes a named table from the database
do
  -- removeTable deletes a table by name. Use for cleanup or session resets.
  local db = lurek.dataframe.newDatabase()
  db:addTable("temp_cache", lurek.dataframe.newDataFrame())

  -- Clean up temporary data
  db:removeTable("temp_cache")
  lurek.log.info("tables remaining: " .. db:tableCount())
end
--@api-stub: LDatabase:hasTable
-- Returns true if the database contains a table with the given name
do
  -- hasTable lets you check before inserting to avoid overwriting.
  local db = lurek.dataframe.newDatabase()

  -- Only create the scores table if it doesn't already exist
  if not db:hasTable("scores") then
    db:addTable("scores", lurek.dataframe.newDataFrame())
    lurek.log.info("created scores table")
  end
end
--@api-stub: LDatabase:listTables
-- Returns an array of all table names in the database
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
--@api-stub: LDatabase:tableCount
-- Returns the number of tables in this database
do
  -- tableCount is a quick way to check if the database is populated.
  local db = lurek.dataframe.newDatabase()
  db:addTable("scores", lurek.dataframe.newDataFrame())
  db:addTable("config", lurek.dataframe.newDataFrame())

  if db:tableCount() > 0 then
    lurek.log.info("database has " .. db:tableCount() .. " tables")
  end
end
--@api-stub: LDatabase:clear
-- Removes all tables from this database
do
  -- clear() wipes the database for a fresh start (e.g., new game session).
  local db = lurek.dataframe.newDatabase()
  db:addTable("round1", lurek.dataframe.newDataFrame())
  db:addTable("round2", lurek.dataframe.newDataFrame())

  -- Reset for a new session
  db:clear()
  lurek.log.info("database cleared, tables=" .. db:tableCount())
end
--@api-stub: LDatabase:merge
-- Merges all tables from another database into this one
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
--@api-stub: LDatabase:toJSON
-- Serializes the entire database (all tables) to JSON text
do
  -- toJSON serializes every table in the database as a JSON object of arrays.
  -- Use for full save-game export or debug snapshots.
  local db = lurek.dataframe.newDatabase()
  db:addTable("players", lurek.dataframe.fromTable({{name = "Alice", level = 5}}))
  db:addTable("inventory", lurek.dataframe.fromTable({{item = "potion", qty = 3}}))

  local json = db:toJSON()
  lurek.log.info("database JSON: " .. #json .. " bytes")
end
--@api-stub: LDatabase:query
-- Runs a SQL query across multiple database tables (supports JOINs)
do
  -- Database:query() lets you write SQL that references multiple tables by name.
  -- This is the most powerful way to combine related data.
  pcall(function()
    local db = lurek.dataframe.newDatabase()
    db:addTable("players", lurek.dataframe.fromTable({
      {id = 1, name = "Alice"},
      {id = 2, name = "Bob"},
    }))
    db:addTable("scores", lurek.dataframe.fromTable({
      {player_id = 1, points = 9000},
      {player_id = 2, points = 7500},
    }))

    -- Cross-table JOIN: match players to their scores
    local result = db:query(
      "SELECT players.name, scores.points FROM players, scores WHERE players.id = scores.player_id"
    )
    lurek.log.info("joined result: " .. result:nrows() .. " rows")
  end)
end
--@api-stub: LDatabase:type
-- Returns the type name string "Database" for this handle
do
  local db = lurek.dataframe.newDatabase()
  if db:type() == "Database" then
    lurek.log.info("confirmed: this is a Database handle")
  end
end
--@api-stub: LDatabase:typeOf
-- Returns true if this handle matches the given type name
do
  -- typeOf checks against "LDatabase", "Database", or "Object".
  local db = lurek.dataframe.newDatabase()
  if db:typeOf("Object") then
    lurek.log.info("Database is an Object")
  end
end
--@api-stub: LGroupedFrame:aggregate
-- Aggregates a column in each group using a custom Lua function
do
  -- GroupedFrame is returned by groupByObj(). It lets you run custom aggregation
  -- functions per group (more flexible than groupAgg's built-in functions).
  local df = lurek.dataframe.newDataFrame()
  df:addColumn("damage", 0)
  df:addColumn("class", "")
  df:addRow({damage = 12, class = "warrior"})
  df:addRow({damage = 8, class = "mage"})
  df:addRow({damage = 20, class = "warrior"})
  df:addRow({damage = 5, class = "mage"})

  local grouped = df:groupByObj("class")
  if grouped and grouped.aggregate then
    -- Custom aggregation: compute mean damage per class
    local result = grouped:aggregate("damage", function(vals)
      local sum = 0
      for _, v in ipairs(vals) do sum = sum + v end
      return sum / #vals
    end)
    lurek.log.debug("aggregate done", "dataframe")
  end
end
--@api-stub: LDataFrame:groupByObj
-- Groups rows by a column and returns a GroupedFrame object
do
  -- groupByObj returns a LGroupedFrame handle (unlike groupBy which returns a plain table).
  -- The handle supports aggregate() for custom per-group calculations.
  local df = lurek.dataframe.newDataFrame()
  df:addColumn("score", 0)
  df:addColumn("region", "")
  df:addRow({score = 100, region = "EU"})
  df:addRow({score = 200, region = "NA"})
  df:addRow({score = 150, region = "EU"})

  if df.groupByObj then
    local grouped = df:groupByObj("region")
    lurek.log.debug("groupByObj returned: " .. tostring(grouped), "dataframe")
  end
end
--@api-stub: lurek.dataframe.toVec
-- Converts a dataframe to a vectorized VecFrame for bulk numeric operations
do
  -- toVec() converts a DataFrame into a VecFrame optimized for batch math.
  -- All numeric operations on VecFrame run in Rust without per-cell Lua overhead.
  local df = lurek.dataframe.fromCSV("hp,mp,stamina\n100,50,80\n200,80,60\n150,60,90\n")

  -- Convert to VecFrame for fast bulk processing
  local vf = lurek.dataframe.toVec(df)
  lurek.log.info("VecFrame: " .. vf:nrows() .. " rows, " .. vf:ncols() .. " cols")
end
--@api-stub: lurek.dataframe.fromVec
-- Converts a VecFrame back to a regular DataFrame
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
--@api-stub: LVecFrame:colAdd
-- Adds a scalar value to every cell in a numeric column (in-place)
do
  -- colAdd shifts all values up by a constant. Use for buffs, offsets, or adjustments.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("score\n10\n20\n30\n"))

  -- Give everyone a +5 bonus (runs in Rust, no Lua loop)
  vf:colAdd("score", 5)

  local df = vf:toDataFrame()
  lurek.log.info("score after +5 bonus: " .. tostring(df:getValue(1, "score")))  -- 15
end
--@api-stub: LVecFrame:colMul
-- Multiplies every cell in a numeric column by a scalar (in-place)
do
  -- colMul scales all values. Use for damage multipliers, difficulty scaling, etc.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("dmg\n10\n15\n20\n"))

  -- Apply a 1.5x critical hit multiplier to all damage values
  vf:colMul("dmg", 1.5)

  local df = vf:toDataFrame()
  lurek.log.info("crit damage: " .. tostring(df:getValue(1, "dmg")))  -- 15
end
--@api-stub: LVecFrame:colClamp
-- Clamps every cell in a numeric column to [min, max] range (in-place)
do
  -- colClamp enforces bounds. Essential for HP (0 to max), percentages (0 to 100), etc.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("hp\n-5\n50\n150\n"))

  -- Ensure HP stays in valid range [0, 100]
  vf:colClamp("hp", 0, 100)

  local df = vf:toDataFrame()
  lurek.log.info("clamped: " .. tostring(df:getValue(1, "hp")) .. ", "
    .. tostring(df:getValue(3, "hp")))  -- 0, 100
end
--@api-stub: LVecFrame:colAbs
-- Applies absolute value to every cell in a numeric column (in-place)
do
  -- colAbs converts negatives to positives. Useful for distances or magnitudes.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("velocity\n-3\n4\n-1\n"))

  -- Get speed (magnitude) from velocity (which can be negative)
  vf:colAbs("velocity")

  local df = vf:toDataFrame()
  lurek.log.info("speed values: " .. tostring(df:getValue(1, "velocity")))  -- 3
end
--@api-stub: LVecFrame:colSqrt
-- Applies square root to every cell in a numeric column (in-place)
do
  -- colSqrt computes sqrt per cell. Useful for converting squared distances to actual distances.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("dist_sq\n9\n16\n25\n"))

  -- Convert squared distances to actual distances
  vf:colSqrt("dist_sq")

  local df = vf:toDataFrame()
  lurek.log.info("distances: " .. tostring(df:getValue(1, "dist_sq")) .. ", "
    .. tostring(df:getValue(2, "dist_sq")))  -- 3, 4
end
--@api-stub: LVecFrame:colOp
-- Applies a binary operation between two columns, storing result in a new column
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
--@api-stub: LVecFrame:reduce
-- Reduces a numeric column to a single value using a named operation
do
  -- reduce() computes an aggregate over a VecFrame column without converting back.
  -- Supported ops: "sum", "mean", "min", "max", "count".
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("score\n10\n20\n30\n"))

  local total = vf:reduce("score", "sum")    -- 60
  local avg = vf:reduce("score", "mean")     -- 20
  lurek.log.info("total=" .. total .. " avg=" .. avg)
end
--@api-stub: LVecFrame:filterMask
-- Builds a boolean mask array from a column comparison
do
  -- filterMask creates a {true, false, ...} array based on a condition.
  -- Use with applyMask to filter the VecFrame efficiently.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("hp\n10\n50\n90\n"))

  -- Build a mask: which rows have hp >= 50?
  local mask = vf:filterMask("hp", ">=", 50)
  -- mask = {false, true, true}
  lurek.log.info("row 2 passes filter: " .. tostring(mask[2]))
end
--@api-stub: LVecFrame:applyMask
-- Returns a new VecFrame containing only rows where mask is true
do
  -- applyMask filters rows using a boolean array (from filterMask or custom logic).
  -- This is the vectorized equivalent of DataFrame:filter().
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("hp\n10\n50\n90\n"))

  -- Filter to only rows with hp >= 50
  local mask = vf:filterMask("hp", ">=", 50)
  local alive = vf:applyMask(mask)

  lurek.log.info("alive entities: " .. alive:nrows())  -- 2
end
--@api-stub: LVecFrame:colType
-- Returns the data type name of a vectorized column ("float64", "int64", "text", "bool")
do
  -- colType tells you how a column is stored internally.
  -- Useful for debugging type mismatches in operations.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("hp\n10\n20\n"))

  local dtype = vf:colType("hp")
  lurek.log.info("hp stored as: " .. dtype)  -- "float64"
end
--@api-stub: LVecFrame:parReduce
-- Reduces multiple columns in parallel using a named operation
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
--@api-stub: LVecFrame:toDataFrame
-- Converts this VecFrame back to a regular DataFrame
do
  -- toDataFrame() is the same as lurek.dataframe.fromVec(vf) but called as a method.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("v\n1\n2\n3\n"))
  vf:colAdd("v", 10)

  -- Method-style conversion back to DataFrame
  local df = vf:toDataFrame()
  lurek.log.info("v[1] after +10: " .. tostring(df:getValue(1, "v")))  -- 11
end
--@api-stub: LVecFrame:colSub
-- Subtracts a scalar from every cell in a numeric column (in-place)
do
  -- colSub decreases all values. Use for drain effects, decay, or cost deduction.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("stamina\n100\n80\n60\n"))

  -- All entities lose 10 stamina per turn
  vf:colSub("stamina", 10)

  local df = vf:toDataFrame()
  lurek.log.info("stamina after drain: " .. tostring(df:getValue(1, "stamina")))  -- 90
end
--@api-stub: LVecFrame:colDiv
-- Divides every cell in a numeric column by a scalar (in-place)
do
  -- colDiv normalizes values or applies fractional scaling.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("score\n100\n200\n150\n"))

  -- Normalize scores to 0-1 range by dividing by max (200)
  vf:colDiv("score", 200)

  local df = vf:toDataFrame()
  lurek.log.info("normalized score[1]: " .. tostring(df:getValue(1, "score")))  -- 0.5
end
--@api-stub: LVecFrame:colFloor
-- Applies floor (round down) to every cell in a numeric column (in-place)
do
  -- colFloor rounds down to the nearest integer. Use for tile snapping or integer coercion.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("x\n1.9\n2.1\n3.7\n"))

  -- Snap to grid (floor to integer)
  vf:colFloor("x")

  local df = vf:toDataFrame()
  lurek.log.info("floored: " .. tostring(df:getValue(1, "x")) .. ", "
    .. tostring(df:getValue(3, "x")))  -- 1, 3
end
--@api-stub: LVecFrame:colCeil
-- Applies ceil (round up) to every cell in a numeric column (in-place)
do
  -- colCeil rounds up. Use for "minimum 1 damage" type calculations.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("y\n1.1\n2.5\n3.0\n"))

  vf:colCeil("y")

  local df = vf:toDataFrame()
  lurek.log.info("ceiled y[1]: " .. tostring(df:getValue(1, "y")))  -- 2
end
--@api-stub: LVecFrame:colNeg
-- Negates every cell in a numeric column (in-place)
do
  -- colNeg flips the sign. Use for reversing velocity, inverting offsets, etc.
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("vy\n3\n-2\n0\n"))

  -- Reverse vertical velocity (bounce)
  vf:colNeg("vy")

  local df = vf:toDataFrame()
  lurek.log.info("bounced vy[1]: " .. tostring(df:getValue(1, "vy")))  -- -3
end
--@api-stub: LVecFrame:colCast
-- Casts a column to a different data type (e.g., "float64", "int64")
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
--@api-stub: LVecFrame:nrows
-- Returns the number of rows in this VecFrame
do
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("v\n10\n20\n30\n"))

  -- Row count is consistent between VecFrame and its source DataFrame
  lurek.log.info("VecFrame rows: " .. vf:nrows())
  assert(vf:nrows() == 3)
end
--@api-stub: LVecFrame:ncols
-- Returns the number of columns in this VecFrame
do
  local df = lurek.dataframe.fromCSV("hp,mp,atk\n10,5,8\n")
  local vf = lurek.dataframe.toVec(df)

  -- Column count matches the source DataFrame
  lurek.log.info("VecFrame cols: " .. vf:ncols())
  assert(vf:ncols() == df:ncols())
end
--@api-stub: LVecFrame:columns
-- Returns an array of column names in this VecFrame
do
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("hp,mp,stamina\n1,2,3\n"))

  -- Column names are preserved from the source DataFrame
  local cols = vf:columns()
  for i, name in ipairs(cols) do
    lurek.log.info("VecFrame col " .. i .. ": " .. name)
  end
end
--@api-stub: LVecFrame:type
-- Returns the type name string "VecFrame" for this handle
do
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("x\n1\n"))
  if vf:type() == "VecFrame" then
    lurek.log.info("confirmed: this is a VecFrame handle")
  end
end
--@api-stub: LVecFrame:typeOf
-- Returns true if this handle matches the given type name
do
  -- typeOf checks against "VecFrame" or "Object".
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("x\n1\n"))
  if vf:typeOf("Object") then
    lurek.log.info("VecFrame is an Object")
  end
end
--@api-stub: LDataFrame:addColumn
-- Adds a new column with an optional default value for existing rows
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
--@api-stub: LDatabase:addTable
-- Adds or replaces a named table in the database
do
  -- addTable registers a dataframe under a string key.
  -- If a table with that name exists, it gets replaced.
  local db = lurek.dataframe.newDatabase()
  local users = lurek.dataframe.newDataFrame()
  users:addRow({id = 1, name = "Alice", role = "admin"})

  db:addTable("users", users)
  lurek.log.info("database now has " .. db:tableCount() .. " table(s)")
end
--@api-stub: LDataFrame:apply
-- Transforms every cell in a column using a Lua function (in-place)
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
--@api-stub: LDataFrame:corr
-- Returns the Pearson correlation between two numeric columns
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
--@api-stub: LDataFrame:filter
-- Returns a new dataframe with rows matching a condition (col op val)
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
--@api-stub: LDataFrame:groupAgg
-- Groups by one column and aggregates another with a built-in function
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
--@api-stub: LDataFrame:join
-- Joins two dataframes by column (inner, left, right, or outer)
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
--@api-stub: LDataFrame:normalizeCol
-- Adds a range-normalized column (maps values to [out_min, out_max])
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
--@api-stub: LDataFrame:outliers
-- Returns rows where a column value is a statistical outlier (z-score based)
do
  -- outliers() finds rows with values far from the mean.
  -- Default threshold is 2.0 standard deviations.
  local df = lurek.dataframe.newDataFrame()
  for i = 1, 10 do df:addRow({response_ms = 15 + i}) end
  df:addRow({response_ms = 1000})  -- obvious outlier (lag spike)

  local spikes = df:outliers("response_ms", 2.0)
  lurek.log.info("lag spikes detected: " .. spikes:nrows())
end
--@api-stub: LVecFrame:parScalarOp
-- Applies a scalar operation to multiple columns in parallel
do
  -- parScalarOp runs the same scalar op on multiple columns at once, using threads.
  -- Supported ops: "add", "sub", "mul", "div".
  local vf = lurek.dataframe.toVec(lurek.dataframe.fromCSV("x,y,z\n1.0,4.0,2.0\n2.0,5.0,3.0\n3.0,6.0,4.0\n"))

  -- Double all coordinate values simultaneously (multi-threaded)
  vf:parScalarOp({"x", "y", "z"}, "mul", 2.0)
  lurek.log.info("parallel scalar op done")
end
--@api-stub: LDataFrame:pivot
-- Pivots rows into columns using row key, column key, and value fields
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
--@api-stub: LDataFrame:pivotTable
-- Builds a pivot table with aggregation (like a spreadsheet pivot)
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
--@api-stub: LDataFrame:rank
-- Returns a new dataframe with a rank column added
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
--@api-stub: LDataFrame:rollingMean
-- Returns a new dataframe with a rolling average column added
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
--@api-stub: LDataFrame:rollingSum
-- Returns a new dataframe with a rolling sum column added
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
--@api-stub: LDataFrame:setValue
-- Sets one cell value by row index and column reference
do
  -- setValue modifies a single cell in-place. Use for targeted updates.
  local df = lurek.dataframe.newDataFrame()
  df:addRow({player = "Alice", score = 50})

  -- Player earned points — update their score
  df:setValue(1, "score", 150)
  lurek.log.info("updated score: " .. df:getValue(1, "score"))
end
--@api-stub: LDataFrame:sort
-- Returns a new sorted dataframe by column (ascending or descending)
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
--@api-stub: LDataFrame:withCumsum
-- Adds a cumulative sum column (running total) in-place
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
--@api-stub: LDataFrame:withPctChange
-- Adds a percent-change column (row-over-row change rate) in-place
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
--@api-stub: LDataFrame:withRank
-- Adds a rank column in-place based on a source column
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
--@api-stub: LDataFrame:withRollingMax
-- Adds a rolling maximum column in-place
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
--@api-stub: LDataFrame:withRollingMean
-- Adds a rolling mean column in-place
do
  -- withRollingMean smooths data inline (same as rollingMean but modifies in-place).
  local df = lurek.dataframe.newDataFrame()
  for i = 1, 5 do df:addRow({temp = 20 + i}) end

  df:withRollingMean("temp", 3, "temp_smooth")
  lurek.log.info("rolling mean column added in-place")
end
--@api-stub: LDataFrame:withRollingMin
-- Adds a rolling minimum column in-place
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
--@api-stub: LDataFrame:withRollingSum
-- Adds a rolling sum column in-place
do
  -- withRollingSum tracks a windowed total inline.
  local df = lurek.dataframe.newDataFrame()
  for i = 1, 5 do df:addRow({sales = i * 10}) end

  -- Sum of last 3 periods
  df:withRollingSum("sales", 3, "sales_3period")
  lurek.log.info("rolling sum column added in-place")
end
--@api-stub: LDataFrame:zscoreCol
-- Adds a z-score normalized column in-place
do
  -- zscoreCol standardizes values: (value - mean) / stddev.
  -- Result has mean=0, stddev=1. Use for comparing across different scales.
  local df = lurek.dataframe.newDataFrame()
  for i = 1, 6 do df:addRow({stat = i * 5}) end

  -- Normalize "stat" to z-scores in column "stat_z"
  df:zscoreCol("stat", "stat_z")
  lurek.log.info("z-score normalized column added")
end
--@api-stub: LDataFrame:lazy
-- Starts a lazy query pipeline from this dataframe
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
--@api-stub: LLazyQuery:collect
-- Executes the lazy query and returns a concrete dataframe.
do
  -- collect() is the point where a lazy pipeline runs.
  local df = lurek.dataframe.fromTable({
    {name = "alice", hp = 12},
    {name = "bob", hp = 7},
    {name = "cara", hp = 20},
  })

  local result = df:lazy():filter("hp", ">", 10):collect()
  lurek.log.info("lazy collected rows: " .. result:nrows())
end
--@api-stub: LLazyQuery:dropNil
-- Adds a step that removes rows where a column is nil.
do
  -- Use dropNil before numeric work when imported rows have missing values.
  local df = lurek.dataframe.fromTable({
    {name = "alice", mana = 5},
    {name = "bob", mana = nil},
    {name = "cara", mana = 9},
  })

  local complete = df:lazy():dropNil("mana"):collect()
  lurek.log.info("lazy non-nil rows: " .. complete:nrows())
end
--@api-stub: LLazyQuery:filter
-- Adds a comparison filter to a lazy query pipeline.
do
  -- Lazy filters can be chained with sort, select, and limit before collect().
  local df = lurek.dataframe.fromTable({
    {name = "alice", hp = 12},
    {name = "bob", hp = 7},
    {name = "cara", hp = 20},
  })

  local wounded = df:lazy():filter("hp", "<", 15):collect()
  lurek.log.info("lazy wounded rows: " .. wounded:nrows())
end
--@api-stub: LLazyQuery:head
-- Keeps the first rows in a lazy query pipeline.
do
  -- head() is useful after sorting when only the first page is needed.
  local df = lurek.dataframe.fromTable({
    {name = "alice", score = 50},
    {name = "bob", score = 80},
    {name = "cara", score = 70},
  })

  local first_two = df:lazy():sort("score", false):head(2):collect()
  lurek.log.info("lazy head rows: " .. first_two:nrows())
end
--@api-stub: LLazyQuery:limit
-- Caps the number of rows returned by a lazy query pipeline.
do
  -- limit() protects UI views from accidentally rendering very large tables.
  local df = lurek.dataframe.random({{"id", "id"}, {"score", "int"}}, 20, 7)
  local page = df:lazy():limit(5):collect()
  lurek.log.info("lazy limited rows: " .. page:nrows())
end
--@api-stub: LLazyQuery:select
-- Keeps selected columns in a lazy query pipeline.
do
  -- Lazy select uses an array table of column names.
  local df = lurek.dataframe.fromTable({
    {name = "alice", hp = 12, team = "red"},
    {name = "bob", hp = 7, team = "blue"},
  })

  local public = df:lazy():select({"name", "hp"}):collect()
  lurek.log.info("lazy selected columns: " .. public:ncols())
end
--@api-stub: LLazyQuery:slice
-- Keeps a one-based inclusive row range in a lazy query pipeline.
do
  -- slice() is useful for fixed pages after an earlier sort step.
  local df = lurek.dataframe.random({{"id", "id"}, {"score", "int"}}, 12, 11)
  local middle = df:lazy():slice(4, 8):collect()
  lurek.log.info("lazy sliced rows: " .. middle:nrows())
end
--@api-stub: LLazyQuery:sort
-- Adds a sort step to a lazy query pipeline.
do
  -- The optional boolean controls ascending order; false means descending.
  local df = lurek.dataframe.fromTable({
    {name = "alice", score = 50},
    {name = "bob", score = 80},
    {name = "cara", score = 70},
  })

  local sorted = df:lazy():sort("score", false):collect()
  lurek.log.info("lazy sorted rows: " .. sorted:nrows())
end
--@api-stub: LLazyQuery:tail
-- Keeps the last rows in a lazy query pipeline.
do
  -- tail() is a compact way to read the newest rows from an ordered log.
  local df = lurek.dataframe.fromRows(
    {"tick", "event"},
    {{1, "spawn"}, {2, "hit"}, {3, "loot"}, {4, "exit"}}
  )

  local recent = df:lazy():tail(2):collect()
  lurek.log.info("lazy tail rows: " .. recent:nrows())
end
--@api-stub: LLazyQuery:type
-- Returns the Lua-visible type name for this lazy query handle.
do
  -- type() is useful in debug inspectors that handle several userdata kinds.
  local query = lurek.dataframe.fromTable({{x = 1}}):lazy()
  lurek.log.info("lazy type: " .. query:type())
end
--@api-stub: LLazyQuery:typeOf
-- Checks whether this userdata is a lazy query handle.
do
  -- typeOf accepts LLazyQuery, LazyQuery, and Object.
  local query = lurek.dataframe.fromTable({{x = 1}}):lazy()
  lurek.log.info("lazy typeOf: " .. tostring(query:typeOf("LLazyQuery")))
end
print("content/examples/dataframe.lua")
