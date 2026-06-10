-- tests/lua/unit/test_loot_unit.lua
-- lurek.math loot table and pity tracker unit tests.

local T = ...
local math = lurek.math

-- @describe lurek.math.newLootTable
describe("lurek.math.newLootTable", function()
    -- @covers lurek.math.newLootTable
    it("creates an empty loot table", function()
        local lt = math.newLootTable()
        T.assert_equal(lt:entryCount(), 0)
    end)

    -- @covers LLootTable:add
    it("add increases entry count", function()
        local lt = math.newLootTable()
        lt:add("sword", 10.0)
        lt:add("shield", 5.0)
        T.assert_equal(lt:entryCount(), 2)
    end)

    -- @covers LLootTable:sample
    it("sample returns a valid entry after build", function()
        local lt = math.newLootTable(42)
        lt:add("gold", 80.0)
        lt:add("gem", 20.0)
        lt:build()
        local entry = lt:sample()
        T.assert_not_nil(entry)
        T.assert_true(entry.id == "gold" or entry.id == "gem")
    end)

    -- @covers LLootTable:sampleN
    it("sampleN returns the requested number of entries", function()
        local lt = math.newLootTable(1)
        lt:add("apple", 1.0)
        lt:add("banana", 1.0)
        lt:build()
        local results = lt:sampleN(5)
        T.assert_equal(#results, 5)
    end)

    -- @covers LLootTable:sampleUnique
    it("sampleUnique avoids duplicate ids", function()
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

    -- @covers LLootTable:remove
    it("remove decreases entry count", function()
        local lt = math.newLootTable()
        lt:add("x", 5.0)
        lt:add("y", 5.0)
        local removed = lt:remove("x")
        T.assert_true(removed)
        T.assert_equal(lt:entryCount(), 1)
    end)

    -- @covers LLootTable:setWeight
    it("setWeight updates an entry weight", function()
        local lt = math.newLootTable()
        lt:add("rare", 1.0)
        local ok = lt:setWeight("rare", 50.0)
        T.assert_true(ok)
    end)

    -- @covers LLootTable:merge
    it("merge combines entries from another table", function()
        local a = math.newLootTable(5)
        a:add("sword", 1.0)
        local b = math.newLootTable(6)
        b:add("shield", 1.0)
        a:merge(b)
        T.assert_equal(a:entryCount(), 2)
    end)

    -- @covers lurek.math.lootFromList
    it("lootFromList creates a populated loot table", function()
        local lt = math.lootFromList({
            { id = "common", weight = 10.0, meta = { tier = "c" } },
            { id = "rare", weight = 1.0, meta = { tier = "r" } },
        })
        T.assert_equal(lt:entryCount(), 2)
        local sample = lt:sample()
        T.assert_not_nil(sample)
        T.assert_not_nil(sample.meta)
    end)

    -- @covers lurek.math.lootFromToml
    it("lootFromToml loads entries from a file", function()
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

    -- @covers LLootTable:save
    it("save and restore round-trip loot table state", function()
        local lt = math.newLootTable(123)
        lt:add("a", 1.0)
        lt:add("b", 2.0)
        lt:build()
        local blob = lt:save()
        T.assert_not_nil(blob)

        local restored = math.newLootTable()
        restored:restore(blob)
        T.assert_equal(restored:entryCount(), 2)
        T.assert_not_nil(restored:sample())
    end)

    -- @covers LLootTable:setSeed
    it("setSeed supports deterministic sampling", function()
        local function make_and_sample(seed)
            local lt = math.newLootTable(seed)
            lt:add("head", 50.0)
            lt:add("tail", 50.0)
            lt:build()
            return lt:sample().id
        end
        local a = make_and_sample(7)
        local b = make_and_sample(7)
        T.assert_equal(a, b)
    end)

    -- @covers LLootTable:typeOf
    it("typeOf recognises loot table types", function()
        local lt = math.newLootTable()
        T.assert_true(lt:typeOf("LLootTable"))
        T.assert_true(lt:typeOf("LObject"))
        T.assert_false(lt:typeOf("LSprite"))
    end)
end)

-- @describe lurek.math.newPityTracker
describe("lurek.math.newPityTracker", function()
    -- @covers lurek.math.newPityTracker
    it("creates a tracker with zero counter", function()
        local pt = math.newPityTracker("rare", 5)
        T.assert_equal(pt:counter(), 0)
        T.assert_false(pt:isPrimed())
    end)

    -- @covers LPityTracker:notice
    it("notice primes the tracker after enough misses", function()
        local pt = math.newPityTracker("rare", 3)
        pt:notice("common")
        pt:notice("common")
        T.assert_false(pt:isPrimed())
        pt:notice("common")
        T.assert_true(pt:isPrimed())
    end)

    -- @covers LPityTracker:counter
    it("counter resets to zero after the target hit", function()
        local pt = math.newPityTracker("rare", 3)
        pt:notice("common")
        pt:notice("common")
        pt:notice("common")
        pt:notice("rare")
        T.assert_equal(pt:counter(), 0)
    end)

    -- @covers LPityTracker:reset
    it("reset clears counter and primed state", function()
        local pt = math.newPityTracker("epic", 2)
        pt:notice("trash")
        pt:notice("trash")
        T.assert_true(pt:isPrimed())
        pt:reset()
        T.assert_false(pt:isPrimed())
        T.assert_equal(pt:counter(), 0)
    end)

    -- @covers LPityTracker:save
    it("save and restore round-trip pity tracker state", function()
        local pt = math.newPityTracker("gold", 4)
        pt:notice("silver")
        pt:notice("silver")
        local blob = pt:save()
        T.assert_not_nil(blob)
        local pt2 = math.newPityTracker("gold", 4)
        pt2:restore(blob)
        T.assert_equal(pt2:counter(), 2)
    end)

    -- @covers lurek.math.sampleWithPity
    it("sampleWithPity forces the target when primed", function()
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

    -- @covers LPityTracker:typeOf
    it("typeOf recognises pity tracker types", function()
        local pt = math.newPityTracker("x", 1)
        T.assert_true(pt:typeOf("LPityTracker"))
        T.assert_true(pt:typeOf("LObject"))
        T.assert_false(pt:typeOf("LBeatClock"))
    end)
end)

test_summary()
