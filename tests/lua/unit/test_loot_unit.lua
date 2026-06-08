-- tests/lua/unit/test_loot_unit.lua
-- lurek.math.newLootTable and lurek.math.newPityTracker unit tests (TST-06)

local T = ...
local math = lurek.math

-- @describe lurek.math.newLootTable
describe("lurek.math.newLootTable", function()
    -- @covers lurek.math.newLootTable
    it("creates an empty table", function()
        local lt = math.newLootTable()
        T.assert_equal(lt:entryCount(), 0)
    end)

    -- @covers lurek.math.newLootTable
    it("add / entryCount", function()
        local lt = math.newLootTable()
        lt:add("sword",  10.0)
        lt:add("shield",  5.0)
        T.assert_equal(lt:entryCount(), 2)
    end)

    -- @covers lurek.math.newLootTable
    it("sample returns valid id after build", function()
        local lt = math.newLootTable(42)
        lt:add("gold",  80.0)
        lt:add("gem",   20.0)
        lt:build()
        local entry = lt:sample()
        T.assert_not_nil(entry)
        T.assert_true(entry.id == "gold" or entry.id == "gem",
            "expected gold or gem, got: " .. tostring(entry and entry.id))
    end)

    -- @covers lurek.math.newLootTable
    it("sampleN returns n results", function()
        local lt = math.newLootTable(1)
        lt:add("apple", 1.0)
        lt:add("banana", 1.0)
        lt:build()
        local results = lt:sampleN(5)
        T.assert_equal(#results, 5)
    end)

    -- @covers lurek.math.newLootTable
    it("sampleUnique returns no duplicates", function()
        local lt = math.newLootTable(99)
        lt:add("a", 1.0)
        lt:add("b", 1.0)
        lt:add("c", 1.0)
        lt:build()
        local results = lt:sampleUnique(3)
        T.assert_equal(#results, 3)
        local seen = {}
        for _, e in ipairs(results) do
            T.assert_nil(seen[e.id], "duplicate id: " .. e.id)
            seen[e.id] = true
        end
    end)

    -- @covers lurek.math.newLootTable
    it("remove decreases entryCount", function()
        local lt = math.newLootTable()
        lt:add("x", 5.0)
        lt:add("y", 5.0)
        local removed = lt:remove("x")
        T.assert_true(removed)
        T.assert_equal(lt:entryCount(), 1)
    end)

    -- @covers lurek.math.newLootTable
    it("setWeight updates weight", function()
        local lt = math.newLootTable()
        lt:add("rare", 1.0)
        local ok = lt:setWeight("rare", 50.0)
        T.assert_true(ok)
    end)

    -- @covers lurek.math.newLootTable
    it("merge combines entries from another table", function()
        local a = math.newLootTable(5)
        a:add("sword", 1.0)
        local b = math.newLootTable(6)
        b:add("shield", 1.0)
        a:merge(b)
        T.assert_equal(a:entryCount(), 2)
    end)

    it("lootFromList creates table with entries", function()
        local lt = math.lootFromList({
            { id = "common", weight = 10.0, meta = { tier = "c" } },
            { id = "rare", weight = 1.0, meta = { tier = "r" } },
        })
        T.assert_equal(lt:entryCount(), 2)
        local sample = lt:sample()
        T.assert_not_nil(sample)
        T.assert_not_nil(sample.meta)
    end)

    it("lootFromToml loads entries from file", function()
        local path = "save/loot_table_unit_test.toml"
        local toml_src = [=[
seed = 42

[[entries]]
id = "common"
weight = 10

[entries.meta]
tier = "c"

[[entries]]
id = "rare"
weight = 1
    ]=]
        lurek.filesystem.write(path, toml_src)

        local lt = math.lootFromToml(path)
        T.assert_equal(lt:entryCount(), 2)
        local sample = lt:sample()
        T.assert_not_nil(sample)
        T.assert_not_nil(sample.id)
    end)

    -- @covers lurek.math.newLootTable
    it("save / restore round-trips loot table state", function()
        local lt = math.newLootTable(123)
        lt:add("a", 1.0)
        lt:add("b", 2.0)
        lt:build()
        local blob = lt:save()
        T.assert_not_nil(blob)

        local restored = math.newLootTable()
        restored:restore(blob)
        T.assert_equal(restored:entryCount(), 2)
        local s = restored:sample()
        T.assert_not_nil(s)
    end)

    -- @covers lurek.math.newLootTable
    it("setSeed makes results deterministic", function()
        local function make_and_sample(seed)
            local lt = math.newLootTable(seed)
            lt:add("head",  50.0)
            lt:add("tail",  50.0)
            lt:build()
            return lt:sample().id
        end
        local a = make_and_sample(7)
        local b = make_and_sample(7)
        T.assert_equal(a, b)
    end)

    -- @covers lurek.math.newLootTable
    it("typeOf returns LLootTable", function()
        local lt = math.newLootTable()
        T.assert_true(lt:typeOf("LLootTable"))
        T.assert_true(lt:typeOf("LObject"))
        T.assert_false(lt:typeOf("LSprite"))
    end)
end)

-- @describe lurek.math.newPityTracker
describe("lurek.math.newPityTracker", function()
    -- @covers lurek.math.newPityTracker
    it("creates tracker with zero counter", function()
        local pt = math.newPityTracker("rare", 5)
        T.assert_equal(pt:counter(), 0)
        T.assert_false(pt:isPrimed())
    end)

    -- @covers lurek.math.newPityTracker
    it("primes after threshold misses", function()
        local pt = math.newPityTracker("rare", 3)
        pt:notice("common")
        pt:notice("common")
        T.assert_false(pt:isPrimed())
        pt:notice("common")
        T.assert_true(pt:isPrimed())
    end)

    -- @covers lurek.math.newPityTracker
    it("resets on target hit", function()
        local pt = math.newPityTracker("rare", 3)
        pt:notice("common")
        pt:notice("common")
        pt:notice("common") -- primed
        pt:notice("rare")   -- hit resets
        T.assert_false(pt:isPrimed())
        T.assert_equal(pt:counter(), 0)
    end)

    -- @covers lurek.math.newPityTracker
    it("reset() clears counter and primed", function()
        local pt = math.newPityTracker("epic", 2)
        pt:notice("trash")
        pt:notice("trash")
        T.assert_true(pt:isPrimed())
        pt:reset()
        T.assert_false(pt:isPrimed())
        T.assert_equal(pt:counter(), 0)
    end)

    -- @covers lurek.math.newPityTracker
    it("export / import round-trips state", function()
        local pt = math.newPityTracker("gold", 4)
        pt:notice("silver")
        pt:notice("silver")
        local blob = pt:save()
        T.assert_not_nil(blob)
        local pt2 = math.newPityTracker("gold", 4)
        pt2:restore(blob)
        T.assert_equal(pt2:counter(), 2)
    end)

    -- @covers lurek.math.newPityTracker
    it("sampleWithPity forces target when primed", function()
        local lt = math.newLootTable(2)
        lt:add("common", 100.0)
        lt:add("rare", 0.0, { tier = "r" })
        lt:build()

        local pity = math.newPityTracker("rare", 1)
        pity:notice("common")
        T.assert_true(pity:isPrimed())

        local id, meta = math.sampleWithPity(lt, pity)
        T.assert_equal(id, "rare")
        T.assert_not_nil(meta)
        T.assert_equal(meta.tier, "r")
    end)

    -- @covers lurek.math.newPityTracker
    it("typeOf returns LPityTracker", function()
        local pt = math.newPityTracker("x", 1)
        T.assert_true(pt:typeOf("LPityTracker"))
        T.assert_true(pt:typeOf("LObject"))
        T.assert_false(pt:typeOf("LBeatClock"))
    end)
end)
test_summary()
