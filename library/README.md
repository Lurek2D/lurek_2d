# Lureksome - Lurek2D Standard Library

The `library/` tree is Tier 3 in the Lurek2D layer model. These modules are
pure Lua gameplay libraries that sit on top of the public `lurek.*` API.

## Layer Contract

- Tier 1 and Tier 2 live in Rust under `src/`.
- `src/lua_api/` exposes the public `lurek.*` surface.
- Tier 3 lives here in `library/`.
- Library modules may delegate to public engine bindings, but the Rust engine
  does not depend on `library/`.

## Modules

| Module | Description | Status |
| --- | --- | --- |
| `library.battle` | Turn-based battle system with combatants, actions, status effects, and battle resolution | Full |
| `library.combat` | Vehicle and projectile combat model for chassis, turrets, weapons, and projectile pools | Full |
| `library.crafting` | Recipes, stations, queues, upgrade trees, skills, and knowledge tracking | Full |
| `library.doll` | Socket-based visual composition with caller-side draw-list rendering | Full |
| `library.economy` | Named resource economy with flow, decay, conversion rules, and manager helpers | Full |
| `library.inventory` | Containers, item stacks, equip slots, item sets, and inventory helpers | Full |
| `library.item` | Type registry, items, stacks, weighted pools, stack history, and analysis helpers | Full |
| `library.loot` | Weighted loot tables, drop DSL, pity trackers, and loot modifiers | Full |
| `library.roguelike` | FOV, energy scheduler, and goal-map pathing helpers for tile-grid games | Full |

## Usage

```lua
local item = require("library.item")
local loot = require("library.loot")
local rl = require("library.roguelike")

item.defineType("potion", { category = "consumable" })

local tbl = loot.fromList({
    { "potion", 10 },
    { "gem", 1 },
})

local id = tbl:sample()
local fov = rl.newFov({ range = 8 })
```

The runtime adds the search path automatically, so `require("library.*")`
resolves next to the engine binary or game directory.

## Validation

Each library is owned by one canonical Lua test file:
`tests/lua/library/test_<name>_library.lua`.

Useful checks:

```powershell
tools\python.cmd tools\validate\validate_library.py
tools\python.cmd tools\audit\library_coverage.py
tools\python.cmd tools\docs\gen_lib_docs.py
```

## LDoc

Library modules should keep LDoc-style comments in `init.lua`, including
`@module library.<name>`, `@status`, and `@see` links where the module composes
or delegates to a `lurek.*` API.
