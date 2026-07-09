# inventory

A pure-Lua inventory library with items, item stacks, slots, containers,
equipment slots, item sets, and top-level inventory helpers.

## Usage

```lua
local inventory = require("library.inventory")

local bag = inventory.newContainer("bag", "fixed", 5)
local sword = inventory.newItem("sword")
bag:addItem(sword, 1)

local inv = inventory.newInventory()
inv:addContainer("bag", bag)

local mainHand = inventory.newSlot("weapon", inventory.SlotState.Active)
inv:addEquipSlot("main_hand", mainHand)
inv:equip("main_hand", inventory.newItemStack(sword, 1, 1))

print(inv:countItem("sword"))
```

## Optional bindings

- `lurek.patterns.newEventBus`: used by `inventory:getEventBus()` when available.
- `lurek.serialize.toJson/fromJson`: recommended for save payloads.
- `lurek.save.SaveManager`: recommended host for persistence collectors.
