# loot

A weighted random loot system using the Walker-Vose alias method for O(1) draws. Supports drop sets, pity timers (guaranteed drop after N misses), and per-roll modifiers (luck bonuses, item-type multipliers). Table data can be loaded from TOML files.

## Usage

```lua
local loot = require("library/loot")

local table = loot.LootTable.new({
    { item = "gold_coin",  weight = 60 },
    { item = "iron_sword", weight = 25 },
    { item = "rare_gem",   weight = 10 },
    { item = "epic_ring",  weight =  5 },
})

local rng = lurek.math.newRandomGenerator(os.time())
local drop = table:roll(rng)
print("Dropped:", drop.item)

-- Pity: guarantees epic_ring after 50 misses
local pity = loot.Pity.new({ item = "epic_ring", max_misses = 50 })
drop = table:rollWithPity(rng, pity)
```

## Dependencies

- `lurek.math.newRandomGenerator` (required), `lurek.save` (optional for pity persistence)
