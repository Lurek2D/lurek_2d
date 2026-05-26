# crafting

A recipe-driven crafting system with skill gating, multi-ingredient recipes, configurable craft stations, and async craft jobs. Supports time-based crafting, failure chances, and output quantity rolls.

## Usage

```lua
local crafting = require("library/crafting")

local registry = crafting.RecipeRegistry.new()
registry:register(crafting.Recipe.new({
    id = "iron_sword",
    inputs  = { crafting.Ingredient.new("iron_ingot", 3), crafting.Ingredient.new("wood", 1) },
    outputs = { crafting.RecipeOutput.new("iron_sword", 1) },
    time    = 5.0,
    skill   = "smithing", min_skill = 10,
}))

local station = crafting.CraftStation.new({ registry = registry })
local job = station:startCraft("iron_sword", inventory, player_skill)

function lurek.update(dt)
    station:update(dt)
end
```

## Dependencies

- `lurek.serialize`, `lurek.patterns` (optional), `lurek.event` (optional)
