# item

A pure-Lua item library with type definitions, mutable item instances, stacks,
weighted pools, stack history, and flat-array analysis helpers.

## Usage

```lua
local item = require("library.item")

item.clearTypes()
item.defineType("potion", {
    category = "consumable",
    base_stats = { heal = 25 },
    base_tags = { "usable" },
})

local stack = item.newStack("bag")
stack:push(item.newItem("potion"))

local pool = item.newItemPool()
pool:addType("potion", 10)
print(pool:draw())
```

## Optional bindings

- `lurek.patterns.newWeightedRandom`: used by `ItemPool` when available.
- `lurek.patterns.groupBy`, `topN`, `sortedIndices`: used by some analysis
  helpers when they preserve the library's return shape.

The item model, stacks, slots, history, and stack manager remain pure Lua.
