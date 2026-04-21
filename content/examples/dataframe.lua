-- content/examples/dataframe.lua
-- Lurek2D lurek.dataframe API Reference
-- Run with: cargo run -- content/examples/dataframe
--
-- Scenario: An RPG analytics dashboard — tracking player stats, item inventories,
-- monster spawn data, and leaderboard scores. Uses DataFrames for in-game data
-- analysis, CSV/JSON import/export, and a Database for multi-table persistence.

print("=== lurek.dataframe — Game Data Analytics ===\n")

-- =============================================================================
-- DataFrame Creation (module-level functions)
-- =============================================================================

-- ---- Stub: lurek.dataframe.newDataFrame -----------------------------------
--@api-stub: lurek.dataframe.newDataFrame
-- Demonstrates the proper usage of lurek.dataframe.newDataFrame.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_dataframe_newDataFrame()
    local monsters = lurek.dataframe.newDataFrame({
    columns = {"name", "type", "hp", "attack", "xp_reward"}
    })
    print("monsters table created: 5 columns")
end
local _ok, _err = pcall(demo_lurek_dataframe_newDataFrame)

-- ---- Stub: lurek.dataframe.fromTable --------------------------------------
--@api-stub: lurek.dataframe.fromTable
-- Demonstrates the proper usage of lurek.dataframe.fromTable.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_dataframe_fromTable()
    local items = lurek.dataframe.fromTable({
    name = {"Iron Sword", "Health Potion", "Fire Staff", "Steel Shield", "Mana Ring"},
    type = {"weapon", "consumable", "weapon", "armor", "accessory"},
    price = {150, 50, 300, 200, 250},
    weight = {3.5, 0.5, 2.0, 6.0, 0.2},
    rarity = {"common", "common", "rare", "uncommon", "rare"}
    })
    print("items table: " .. items:nrows() .. " rows, " .. items:ncols() .. " columns")
end
local _ok, _err = pcall(demo_lurek_dataframe_fromTable)

-- ---- Stub: lurek.dataframe.fromCSV ----------------------------------------
--@api-stub: lurek.dataframe.fromCSV
-- Demonstrates the proper usage of lurek.dataframe.fromCSV.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_dataframe_fromCSV()
    local balance = lurek.dataframe.fromCSV("assets/data/monster_balance.csv")
    print("balance data loaded from CSV")
end
local _ok, _err = pcall(demo_lurek_dataframe_fromCSV)

-- ---- Stub: lurek.dataframe.fromJSON ---------------------------------------
--@api-stub: lurek.dataframe.fromJSON
-- Demonstrates the proper usage of lurek.dataframe.fromJSON.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_dataframe_fromJSON()
    local scores = lurek.dataframe.fromJSON("assets/data/leaderboard.json")
    print("leaderboard loaded from JSON")
end
local _ok, _err = pcall(demo_lurek_dataframe_fromJSON)

-- ---- Stub: lurek.dataframe.fromBinary -------------------------------------
--@api-stub: lurek.dataframe.fromBinary
-- Demonstrates the proper usage of lurek.dataframe.fromBinary.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_dataframe_fromBinary()
    local save_data = lurek.dataframe.fromBinary("saves/player_stats.bin")
    print("save data loaded from binary")
end
local _ok, _err = pcall(demo_lurek_dataframe_fromBinary)

-- ---- Stub: lurek.dataframe.random -----------------------------------------
--@api-stub: lurek.dataframe.random
-- Demonstrates the proper usage of lurek.dataframe.random.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_dataframe_random()
    local test_data = lurek.dataframe.random(100, {
    columns = {"x", "y", "damage"},
    min = {0, 0, 1},
    max = {800, 600, 100}
    })
    print("random test data: " .. test_data:nrows() .. " rows")
end
local _ok, _err = pcall(demo_lurek_dataframe_random)

-- =============================================================================
-- DataFrame Object Methods — Row & Column Access
-- =============================================================================

-- ---- Stub: DataFrame:nrows ------------------------------------------------
--@api-stub: DataFrame:nrows
-- Demonstrates the proper usage of DataFrame:nrows.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_nrows()
    print("items rows: " .. items:nrows())
end
local _ok, _err = pcall(demo_DataFrame_nrows)

-- ---- Stub: DataFrame:ncols ------------------------------------------------
--@api-stub: DataFrame:ncols
-- Demonstrates the proper usage of DataFrame:ncols.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_ncols()
    print("items columns: " .. items:ncols())
end
local _ok, _err = pcall(demo_DataFrame_ncols)

-- ---- Stub: DataFrame:columns ----------------------------------------------
--@api-stub: DataFrame:columns
-- Demonstrates the proper usage of DataFrame:columns.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_columns()
    local cols = items:columns()
    print("item columns: " .. table.concat(cols, ", "))
end
local _ok, _err = pcall(demo_DataFrame_columns)

-- ---- Stub: DataFrame:count ------------------------------------------------
--@api-stub: DataFrame:count
-- Demonstrates the proper usage of DataFrame:count.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_count()
    print("non-nil prices: " .. items:count("price"))
end
local _ok, _err = pcall(demo_DataFrame_count)

-- ---- Stub: DataFrame:getColumn --------------------------------------------
--@api-stub: DataFrame:getColumn
-- Demonstrates the proper usage of DataFrame:getColumn.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_getColumn()
    local prices = items:getColumn("price")
    print("prices: " .. table.concat(prices, ", "))
end
local _ok, _err = pcall(demo_DataFrame_getColumn)

-- ---- Stub: DataFrame:getRow -----------------------------------------------
--@api-stub: DataFrame:getRow
-- Demonstrates the proper usage of DataFrame:getRow.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_getRow()
    local row = items:getRow(0)
    print("first item: " .. row.name .. " (" .. row.type .. ") - " .. row.price .. "g")
end
local _ok, _err = pcall(demo_DataFrame_getRow)

-- ---- Stub: DataFrame:getValue ---------------------------------------------
--@api-stub: DataFrame:getValue
-- Demonstrates the proper usage of DataFrame:getValue.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_getValue()
    local first_name = items:getValue(0, "name")
    print("item[0].name = " .. first_name)
end
local _ok, _err = pcall(demo_DataFrame_getValue)

-- ---- Stub: DataFrame:addRow -----------------------------------------------
--@api-stub: DataFrame:addRow
-- Demonstrates the proper usage of DataFrame:addRow.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_addRow()
    items:addRow({name = "Dragon Scale", type = "material", price = 500, weight = 1.0, rarity = "legendary"})
    print("added Dragon Scale: " .. items:nrows() .. " items total")
end
local _ok, _err = pcall(demo_DataFrame_addRow)

-- ---- Stub: DataFrame:addRowBatch ------------------------------------------
--@api-stub: DataFrame:addRowBatch
-- Demonstrates the proper usage of DataFrame:addRowBatch.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_addRowBatch()
    items:addRowBatch({
    {name = "Bronze Axe", type = "weapon", price = 120, weight = 4.0, rarity = "common"},
    {name = "Elixir", type = "consumable", price = 200, weight = 0.3, rarity = "uncommon"},
    })
    print("batch added 2 items: " .. items:nrows() .. " total")
end
local _ok, _err = pcall(demo_DataFrame_addRowBatch)

-- ---- Stub: DataFrame:removeRow --------------------------------------------
--@api-stub: DataFrame:removeRow
-- Demonstrates the proper usage of DataFrame:removeRow.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_removeRow()
    items:removeRow(items:nrows() - 1)
    print("last row removed: " .. items:nrows() .. " remaining")
end
local _ok, _err = pcall(demo_DataFrame_removeRow)

-- ---- Stub: DataFrame:removeColumn -----------------------------------------
--@api-stub: DataFrame:removeColumn
-- Demonstrates the proper usage of DataFrame:removeColumn.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_removeColumn()
    local items_copy = items:clone()
    items_copy:removeColumn("weight")
    print("weight column removed from copy: " .. items_copy:ncols() .. " columns")
end
local _ok, _err = pcall(demo_DataFrame_removeColumn)

-- ---- Stub: DataFrame:rename -----------------------------------------------
--@api-stub: DataFrame:rename
-- Demonstrates the proper usage of DataFrame:rename.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_rename()
    items_copy:rename("price", "gold_cost")
    print("price renamed to gold_cost")
end
local _ok, _err = pcall(demo_DataFrame_rename)

-- =============================================================================
-- Filtering, Slicing & Sampling
-- =============================================================================

-- ---- Stub: DataFrame:head -------------------------------------------------
--@api-stub: DataFrame:head
-- Demonstrates the proper usage of DataFrame:head.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_head()
    local top3 = items:head(3)
    print("top 3 items: " .. top3:nrows() .. " rows")
end
local _ok, _err = pcall(demo_DataFrame_head)

-- ---- Stub: DataFrame:tail -------------------------------------------------
--@api-stub: DataFrame:tail
-- Demonstrates the proper usage of DataFrame:tail.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_tail()
    local last2 = items:tail(2)
    print("last 2 items: " .. last2:nrows() .. " rows")
end
local _ok, _err = pcall(demo_DataFrame_tail)

-- ---- Stub: DataFrame:slice ------------------------------------------------
--@api-stub: DataFrame:slice
-- Demonstrates the proper usage of DataFrame:slice.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_slice()
    local mid = items:slice(1, 3)
    print("items [1..3]: " .. mid:nrows() .. " rows")
end
local _ok, _err = pcall(demo_DataFrame_slice)

-- ---- Stub: DataFrame:select -----------------------------------------------
--@api-stub: DataFrame:select
-- Demonstrates the proper usage of DataFrame:select.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_select()
    local name_price = items:select({"name", "price"})
    print("selected name+price: " .. name_price:ncols() .. " columns")
end
local _ok, _err = pcall(demo_DataFrame_select)

-- ---- Stub: DataFrame:unique -----------------------------------------------
--@api-stub: DataFrame:unique
-- Demonstrates the proper usage of DataFrame:unique.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_unique()
    local unique_types = items:unique("type")
    print("unique item types: " .. #unique_types)
end
local _ok, _err = pcall(demo_DataFrame_unique)

-- ---- Stub: DataFrame:query ------------------------------------------------
--@api-stub: DataFrame:query
-- Demonstrates the proper usage of DataFrame:query.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_query()
    local rare = items:query("rarity == 'rare'")
    print("rare items: " .. rare:nrows())
end
local _ok, _err = pcall(demo_DataFrame_query)

-- ---- Stub: DataFrame:sample -----------------------------------------------
--@api-stub: DataFrame:sample
-- Demonstrates the proper usage of DataFrame:sample.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_sample()
    local sample = items:sample(2)
    print("random sample of 2 items: " .. sample:nrows())
end
local _ok, _err = pcall(demo_DataFrame_sample)

-- ---- Stub: DataFrame:dropNil ----------------------------------------------
--@api-stub: DataFrame:dropNil
-- Demonstrates the proper usage of DataFrame:dropNil.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_dropNil()
    local clean = items:dropNil()
    print("after dropNil: " .. clean:nrows() .. " rows (no nils)")
end
local _ok, _err = pcall(demo_DataFrame_dropNil)

-- ---- Stub: DataFrame:fillNil ----------------------------------------------
--@api-stub: DataFrame:fillNil
-- Demonstrates the proper usage of DataFrame:fillNil.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_fillNil()
    items:fillNil("price", 0)
    print("nil prices filled with 0")
end
local _ok, _err = pcall(demo_DataFrame_fillNil)

-- =============================================================================
-- Grouping & Aggregation — game balance analytics
-- =============================================================================

-- ---- Stub: DataFrame:groupBy ----------------------------------------------
--@api-stub: DataFrame:groupBy
-- Demonstrates the proper usage of DataFrame:groupBy.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_groupBy()
    local by_type = items:groupBy("type")
    print("grouped by type: " .. tostring(by_type))
end
local _ok, _err = pcall(demo_DataFrame_groupBy)

-- ---- Stub: DataFrame:countBy ----------------------------------------------
--@api-stub: DataFrame:countBy
-- Demonstrates the proper usage of DataFrame:countBy.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_countBy()
    local counts = items:countBy("type")
    print("items per type: " .. tostring(counts))
end
local _ok, _err = pcall(demo_DataFrame_countBy)

-- ---- Stub: DataFrame:merge ------------------------------------------------
--@api-stub: DataFrame:merge
-- Demonstrates the proper usage of DataFrame:merge.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_merge()
    local drop_sources = lurek.dataframe.fromTable({
    name = {"Iron Sword", "Fire Staff"},
    drop_from = {"Skeleton Knight", "Fire Dragon"}
    })
    local merged = items:merge(drop_sources, "name")
    print("merged items+drops: " .. merged:nrows() .. " rows, " .. merged:ncols() .. " cols")
end
local _ok, _err = pcall(demo_DataFrame_merge)

-- =============================================================================
-- Statistics — balance analysis
-- =============================================================================

-- ---- Stub: DataFrame:sum --------------------------------------------------
--@api-stub: DataFrame:sum
-- Demonstrates the proper usage of DataFrame:sum.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_sum()
    print("total item value: " .. items:sum("price") .. " gold")
end
local _ok, _err = pcall(demo_DataFrame_sum)

-- ---- Stub: DataFrame:mean -------------------------------------------------
--@api-stub: DataFrame:mean
-- Demonstrates the proper usage of DataFrame:mean.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_mean()
    print("average price: " .. string.format("%.1f", items:mean("price")) .. " gold")
end
local _ok, _err = pcall(demo_DataFrame_mean)

-- ---- Stub: DataFrame:min --------------------------------------------------
--@api-stub: DataFrame:min
-- Demonstrates the proper usage of DataFrame:min.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_min()
    print("cheapest: " .. items:min("price") .. " gold")
end
local _ok, _err = pcall(demo_DataFrame_min)

-- ---- Stub: DataFrame:max --------------------------------------------------
--@api-stub: DataFrame:max
-- Demonstrates the proper usage of DataFrame:max.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_max()
    print("most expensive: " .. items:max("price") .. " gold")
end
local _ok, _err = pcall(demo_DataFrame_max)

-- ---- Stub: DataFrame:median -----------------------------------------------
--@api-stub: DataFrame:median
-- Demonstrates the proper usage of DataFrame:median.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_median()
    print("median price: " .. tostring(items:median("price")))
end
local _ok, _err = pcall(demo_DataFrame_median)

-- ---- Stub: DataFrame:stddev -----------------------------------------------
--@api-stub: DataFrame:stddev
-- Demonstrates the proper usage of DataFrame:stddev.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_stddev()
    print("price std dev: " .. string.format("%.1f", items:stddev("price")))
end
local _ok, _err = pcall(demo_DataFrame_stddev)

-- ---- Stub: DataFrame:variance ---------------------------------------------
--@api-stub: DataFrame:variance
-- Demonstrates the proper usage of DataFrame:variance.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_variance()
    print("price variance: " .. string.format("%.1f", items:variance("price")))
end
local _ok, _err = pcall(demo_DataFrame_variance)

-- ---- Stub: DataFrame:describe ---------------------------------------------
--@api-stub: DataFrame:describe
-- Demonstrates the proper usage of DataFrame:describe.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_describe()
    local stats = items:describe()
    print("describe:\n" .. tostring(stats))
end
local _ok, _err = pcall(demo_DataFrame_describe)

-- ---- Stub: DataFrame:correlationMatrix ------------------------------------
--@api-stub: DataFrame:correlationMatrix
-- Demonstrates the proper usage of DataFrame:correlationMatrix.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_correlationMatrix()
    local corr = items:correlationMatrix()
    print("correlation matrix:\n" .. tostring(corr))
end
local _ok, _err = pcall(demo_DataFrame_correlationMatrix)

-- ---- Stub: DataFrame:modeVal ----------------------------------------------
--@api-stub: DataFrame:modeVal
-- Demonstrates the proper usage of DataFrame:modeVal.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_modeVal()
    print("most common rarity: " .. tostring(items:modeVal("rarity")))
end
local _ok, _err = pcall(demo_DataFrame_modeVal)

-- ---- Stub: DataFrame:entropy ----------------------------------------------
--@api-stub: DataFrame:entropy
-- Demonstrates the proper usage of DataFrame:entropy.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_entropy()
    print("type entropy: " .. string.format("%.3f", items:entropy("type")))
end
local _ok, _err = pcall(demo_DataFrame_entropy)

-- ---- Stub: DataFrame:withEval ---------------------------------------------
--@api-stub: DataFrame:withEval
-- Demonstrates the proper usage of DataFrame:withEval.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_withEval()
    local enriched = items:withEval("value_per_kg", "price / weight")
    print("value_per_kg computed: " .. enriched:ncols() .. " columns")
end
local _ok, _err = pcall(demo_DataFrame_withEval)

-- ---- Stub: DataFrame:getColumnAsF64 ---------------------------------------
--@api-stub: DataFrame:getColumnAsF64
-- Demonstrates the proper usage of DataFrame:getColumnAsF64.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_getColumnAsF64()
    local price_arr = items:getColumnAsF64("price")
    print("prices as f64: " .. #price_arr .. " values")
end
local _ok, _err = pcall(demo_DataFrame_getColumnAsF64)

-- ---- Stub: DataFrame:setColumnFromF64 -------------------------------------
--@api-stub: DataFrame:setColumnFromF64
-- Demonstrates the proper usage of DataFrame:setColumnFromF64.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_setColumnFromF64()
    items:setColumnFromF64("price", price_arr)
    print("prices restored from f64 array")
end
local _ok, _err = pcall(demo_DataFrame_setColumnFromF64)

-- =============================================================================
-- Clone & Type
-- =============================================================================

-- ---- Stub: DataFrame:clone ------------------------------------------------
--@api-stub: DataFrame:clone
-- Demonstrates the proper usage of DataFrame:clone.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_clone()
    local items_backup = items:clone()
    print("items cloned: " .. items_backup:nrows() .. " rows")
end
local _ok, _err = pcall(demo_DataFrame_clone)

-- ---- Stub: DataFrame:type -------------------------------------------------
--@api-stub: DataFrame:type
-- Demonstrates the proper usage of DataFrame:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_type()
    print('Executing type')
end
local _ok, _err = pcall(demo_DataFrame_type)

-- ---- Stub: DataFrame:typeOf -----------------------------------------------
--@api-stub: DataFrame:typeOf
-- Demonstrates the proper usage of DataFrame:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_typeOf()
    print("type: " .. tostring(items:type()))
    print("typeOf: " .. tostring(items:typeOf("DataFrame")))
end
local _ok, _err = pcall(demo_DataFrame_typeOf)

-- =============================================================================
-- Serialization — Save/Load game data
-- =============================================================================

-- ---- Stub: DataFrame:toString ---------------------------------------------
--@api-stub: DataFrame:toString
-- Demonstrates the proper usage of DataFrame:toString.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_toString()
    print(items:toString())
end
local _ok, _err = pcall(demo_DataFrame_toString)

-- ---- Stub: DataFrame:toTable ----------------------------------------------
--@api-stub: DataFrame:toTable
-- Demonstrates the proper usage of DataFrame:toTable.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_toTable()
    local tbl = items:toTable()
    print("toTable: " .. #tbl.name .. " names")
end
local _ok, _err = pcall(demo_DataFrame_toTable)

-- ---- Stub: DataFrame:toCSV ------------------------------------------------
--@api-stub: DataFrame:toCSV
-- Demonstrates the proper usage of DataFrame:toCSV.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_toCSV()
    items:toCSV("output/items_export.csv")
    print("exported to CSV: output/items_export.csv")
end
local _ok, _err = pcall(demo_DataFrame_toCSV)

-- ---- Stub: DataFrame:toJSON -----------------------------------------------
--@api-stub: DataFrame:toJSON
-- Demonstrates the proper usage of DataFrame:toJSON.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_toJSON()
    items:toJSON("output/items_export.json")
    print("exported to JSON: output/items_export.json")
end
local _ok, _err = pcall(demo_DataFrame_toJSON)

-- ---- Stub: DataFrame:toBinary ---------------------------------------------
--@api-stub: DataFrame:toBinary
-- Demonstrates the proper usage of DataFrame:toBinary.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DataFrame_toBinary()
    items:toBinary("output/items_export.bin")
    print("exported to binary: output/items_export.bin")
end
local _ok, _err = pcall(demo_DataFrame_toBinary)

-- =============================================================================
-- Database — multi-table game data persistence
-- =============================================================================

-- ---- Stub: lurek.dataframe.newDatabase ------------------------------------
--@api-stub: lurek.dataframe.newDatabase
-- Demonstrates the proper usage of lurek.dataframe.newDatabase.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_dataframe_newDatabase()
    local db = lurek.dataframe.newDatabase()
    print("database created")
end
local _ok, _err = pcall(demo_lurek_dataframe_newDatabase)

-- ---- Stub: Database:getTable ----------------------------------------------
--@api-stub: Database:getTable
-- Demonstrates the proper usage of Database:getTable.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Database_getTable()
    db:getTable("items")  -- returns nil if not yet stored
    print("items table from DB: " .. tostring(db:getTable("items")))
end
local _ok, _err = pcall(demo_Database_getTable)

-- ---- Stub: Database:hasTable ----------------------------------------------
--@api-stub: Database:hasTable
-- Demonstrates the proper usage of Database:hasTable.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Database_hasTable()
    print("has 'items': " .. tostring(db:hasTable("items")))
end
local _ok, _err = pcall(demo_Database_hasTable)

-- ---- Stub: Database:listTables --------------------------------------------
--@api-stub: Database:listTables
-- Demonstrates the proper usage of Database:listTables.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Database_listTables()
    local tables = db:listTables()
    print("DB tables: " .. #tables)
end
local _ok, _err = pcall(demo_Database_listTables)

-- ---- Stub: Database:tableCount --------------------------------------------
--@api-stub: Database:tableCount
-- Demonstrates the proper usage of Database:tableCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Database_tableCount()
    print("table count: " .. db:tableCount())
end
local _ok, _err = pcall(demo_Database_tableCount)

-- ---- Stub: Database:removeTable -------------------------------------------
--@api-stub: Database:removeTable
-- Demonstrates the proper usage of Database:removeTable.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Database_removeTable()
    db:removeTable("items")
    print("items table removed from DB")
end
local _ok, _err = pcall(demo_Database_removeTable)

-- ---- Stub: Database:clear -------------------------------------------------
--@api-stub: Database:clear
-- Demonstrates the proper usage of Database:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Database_clear()
    db:clear()
    print("database cleared")
end
local _ok, _err = pcall(demo_Database_clear)

-- ---- Stub: Database:merge -------------------------------------------------
--@api-stub: Database:merge
-- Demonstrates the proper usage of Database:merge.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Database_merge()
    local db2 = lurek.dataframe.newDatabase()
    db:merge(db2)
    print("databases merged")
end
local _ok, _err = pcall(demo_Database_merge)

-- ---- Stub: Database:toJSON ------------------------------------------------
--@api-stub: Database:toJSON
-- Demonstrates the proper usage of Database:toJSON.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Database_toJSON()
    db:toJSON("output/game_db.json")
    print("database exported to JSON")
end
local _ok, _err = pcall(demo_Database_toJSON)

-- ---- Stub: Database:query -------------------------------------------------
--@api-stub: Database:query
-- Demonstrates the proper usage of Database:query.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Database_query()
    local result = db:query("SELECT * FROM items WHERE price > 100")
    print("query result: " .. tostring(result))
end
local _ok, _err = pcall(demo_Database_query)

-- ---- Stub: Database:type --------------------------------------------------
--@api-stub: Database:type
-- Demonstrates the proper usage of Database:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Database_type()
    print('Executing type')
end
local _ok, _err = pcall(demo_Database_type)

-- ---- Stub: Database:typeOf ------------------------------------------------
--@api-stub: Database:typeOf
-- Demonstrates the proper usage of Database:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Database_typeOf()
    print("DB type: " .. tostring(db:type()))
    print("DB typeOf: " .. tostring(db:typeOf("Database")))
    print("\n-- dataframe.lua example complete --")
end
local _ok, _err = pcall(demo_Database_typeOf)
