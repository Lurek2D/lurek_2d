# crafting

A pure-Lua crafting library with recipes, stations, queues, knowledge, upgrade
trees, and skill progression.

## Usage

```lua
local crafting = require("library.crafting")

local recipe = crafting.newRecipe("iron_sword")
recipe:addIngredient(crafting.newIngredient("iron_ingot", 3))
recipe:addIngredient(crafting.newIngredient("wood", 1))
recipe:addOutput(crafting.newRecipeOutput("iron_sword", 1))
recipe.station = "forge"

local registry = crafting.newRecipeRegistry()
registry:add(recipe)

local forge = crafting.newStation("Forge", "forge")
local queue = crafting.newCraftQueue(4)
local id = queue:enqueue(recipe.id, 5, 1)

queue:update(1.0)
print(id, queue:getJob(id):percent())
```

## Optional bindings

- `lurek.patterns.newWeightedRandom`: used by `ModifierPool` when available.

Recipes, jobs, stations, skills, and craft queues remain pure Lua even when
the weighted-random backend is available.
