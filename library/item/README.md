# item

A typed item system with a global type registry, instance pools, stacks, and a history log. Separates item type definitions (static data) from item instances (runtime state), and tracks stack mutation history for undo/replay.

## Usage

```lua
local item = require("library/item")

item.ItemPool.register({ id = "potion", name = "Health Potion", max_stack = 10 })
item.ItemPool.register({ id = "sword",  name = "Iron Sword",    max_stack = 1  })

local mgr = item.StackManager.new()
mgr:add("potion", 5)
mgr:add("potion", 3)   -- stacks to 8
print("Potions:", mgr:count("potion"))

mgr:remove("potion", 2)
print("History entries:", mgr:historySize())
```

## Dependencies

- `lurek.math` (optional), `lurek.serialize` (optional)
