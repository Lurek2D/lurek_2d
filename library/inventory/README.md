# inventory

A slot-based inventory system with item stacks, weighted bags, and equipment slots. Supports transfer between containers, save/load serialization, and an event bus for pick-up, drop, and equip notifications.

## Usage

```lua
local inventory = require("library/inventory")

local bag = inventory.Container.new({ slots = 20, max_weight = 50 })
local sword = inventory.InvItem.new({ id = "iron_sword", weight = 3.5 })

bag:add(sword)
print("Items:", bag:count())

local equip = inventory.Equipment.new({ slots = { "weapon", "armor", "ring" } })
equip:equip("weapon", sword)
print("Weapon:", equip:get("weapon").id)
```

## Dependencies

- `lurek.serialize` (optional), `lurek.save.SaveManager` (optional)
