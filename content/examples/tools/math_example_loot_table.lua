--[[
    example_loot_table.lua
    Demonstrates lurek.math.newLootTable and newPityTracker:
    - Weighted random drops (Walker-Vose O(1) alias method)
    - Pity system that guarantees a rare drop after N misses
    - Deterministic seeding for reproducible runs

    API used:
      lurek.math.newLootTable([seed])
        :add(id, weight, meta?)
        :build()
        :sample()          -> {id, weight}?
        :sampleN(n)        -> array
        :sampleUnique(n)   -> array
        :remove(id)        -> bool
        :setWeight(id, w)  -> bool
        :setSeed(seed)
        :entryCount()      -> int

      lurek.math.newPityTracker(target_id, threshold)
        :notice(result_id) -> bool (true = just primed)
        :isPrimed()        -> bool
        :reset()
        :counter()         -> int
        :export()          -> string (blob)
        :import(blob)
--]]

-- ── 1. Basic weighted drop table ─────────────────────────────────────────────

local function example_print_log(...)
    local parts = {}
    for i = 1, select("#", ...) do
        parts[i] = tostring(select(i, ...))
    end
    lurek.log.info(table.concat(parts, " "))
end

local drops = lurek.math.newLootTable(42)  -- deterministic seed
drops:add("common_coin",   60.0)
drops:add("uncommon_gem",  25.0)
drops:add("rare_crystal",  12.0)
drops:add("epic_artifact",  3.0)
drops:build()

example_print_log("=== 10 random drops ===")
for i = 1, 10 do
    local entry = drops:sample()
    example_print_log(string.format("  drop %2d: %s (weight=%.0f)", i, entry.id, entry.weight))
end

-- ── 2. Batch sampling ─────────────────────────────────────────────────────────

example_print_log("\n=== Frequency over 1000 samples ===")
local counts = {}
local samples = drops:sampleN(1000)
for _, e in ipairs(samples) do
    counts[e.id] = (counts[e.id] or 0) + 1
end
for id, n in pairs(counts) do
    example_print_log(string.format("  %-22s %d%%", id, n / 10))
end

-- ── 3. Unique loot chest (no repeats) ────────────────────────────────────────

example_print_log("\n=== Unique 3-item chest roll ===")
local chest = lurek.math.newLootTable(7)
chest:add("sword",  20.0)
chest:add("shield", 20.0)
chest:add("bow",    20.0)
chest:add("staff",  20.0)
chest:add("dagger", 20.0)
chest:build()
for i, e in ipairs(chest:sampleUnique(3)) do
    example_print_log(string.format("  slot %d: %s", i, e.id))
end

-- ── 4. Pity system ─────────────────────────────────────────────────────────────

example_print_log("\n=== Pity system (guaranteed epic after 10 misses) ===")
local loot = lurek.math.newLootTable(100)
loot:add("common",  70.0)
loot:add("rare",    28.0)
loot:add("epic",     2.0)
loot:build()

local pity = lurek.math.newPityTracker("epic", 10)

for i = 1, 20 do
    local entry
    if pity:isPrimed() then
        -- Guarantee the epic drop
        entry = { id = "epic", weight = 2.0 }
        pity:reset()
        example_print_log(string.format("  pull %2d: [PITY] epic  (miss counter was %d)", i, pity:counter()))
    else
        entry = loot:sample()
        local just_primed = pity:notice(entry.id)
        local flag = just_primed and " <-- pity primed!" or ""
        example_print_log(string.format("  pull %2d: %-10s (misses=%d)%s", i, entry.id, pity:counter(), flag))
    end
end

-- ── 5. Save / restore pity state ─────────────────────────────────────────────

example_print_log("\n=== Save/restore pity state ===")
local pt = lurek.math.newPityTracker("epic", 5)
pt:notice("common")
pt:notice("common")
pt:notice("rare")
example_print_log("Before save: counter=" .. pt:counter())
local blob = pt:export()
local pt2 = lurek.math.newPityTracker("epic", 5)
pt2:import(blob)
example_print_log("After restore: counter=" .. pt2:counter() .. " isPrimed=" .. tostring(pt2:isPrimed()))
