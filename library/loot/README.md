# loot

A weighted loot library with loot tables, drop sets, pity tracking, and
modifier views. It uses public `lurek.math` backends when they can preserve
the legacy `library.loot` API, and keeps a pure Lua fallback for portability.

## Usage

```lua
local loot = require("library.loot")

local tbl = loot.fromList({
    { "gold_coin", 60 },
    { "iron_sword", 25, { rarity = "common" } },
    { "epic_ring", 5, { rarity = "epic" } },
})

local pity = loot.newPity("epic_ring", 50)
local id, meta = tbl:sample()
local guaranteed = pity:notice(id)

print(id, meta and meta.rarity, guaranteed)
```

## Optional bindings

- `lurek.math.newLootTable`, `lootFromList`, `lootFromToml`: engine-backed loot
  sampling and TOML loading.
- `lurek.math.newPityTracker`, `sampleWithPity`: engine-backed pity handling.
- `lurek.math.newRandomGenerator`: module default RNG.
- `lurek.serialize.fromToml`, `lurek.filesystem.read`: TOML file loading.
