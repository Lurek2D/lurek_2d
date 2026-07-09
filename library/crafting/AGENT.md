# `crafting` - Agent Reference

| Property | Value |
| --- | --- |
| Tier | Tier 3 - Lureksome (pure Lua) |
| Source | `library/crafting/init.lua` |
| Lua tests | `tests/lua/library/test_crafting_library.lua` |
| Status | full |
| Optional bindings | `lurek.patterns.newWeightedRandom` |

## Purpose

Recipe-driven crafting with stations, queues, skill progression, upgrade trees,
knowledge tracking, recipe groups, and weighted modifier pools.

## Current shape

- Recipes and outputs are created with `newRecipe`, `newIngredient`,
  `newIngredientTag`, `newRecipeOutput`, and `newRecipeOutputWithChance`.
- `RecipeRegistry` indexes recipes by id and supports filtering helpers.
- `Station`, `CraftJob`, and `CraftQueue` model gameplay time and station
  behavior in pure Lua.
- `CraftSkill`, `PerkNode`, `UpgradeTree`, `RecipeKnowledge`, and `RecipeGroup`
  provide the progression side.
- `ModifierPool` stores weighted modifier entries and exposes `roll()` / `draw()`.

## Engine integration

- `ModifierPool` uses `lurek.patterns.newWeightedRandom` when available.
- Queue timing does not delegate to `lurek.time`; it remains a gameplay queue.

## Notes

- Keep recipe, station, and queue behavior domain-specific.
- Maintain current method names and constructor signatures for compatibility.
