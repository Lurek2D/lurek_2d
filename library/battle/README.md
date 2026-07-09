# battle

A pure-Lua turn-based battle library with combatants, actions, status effects,
initiative ordering, typed damage, and battle resolution.

## Usage

```lua
local battle = require("library.battle")

local hero = battle.newCombatant("hero")
hero:setTeam("player")

local slash = battle.newAction("slash")
slash:setBaseDamage(12)
slash:setAccuracy(0.95)
hero:addAction(slash)

local goblin = battle.newCombatant("goblin")
goblin:setTeam("enemy")
goblin:setHp(30)

local arena = battle.newBattle("arena")
arena:addCombatant(hero)
arena:addCombatant(goblin)

local result = arena:attack("hero", "slash", "goblin")
print(result and result.hit, goblin:getHp())
```

## Optional bindings

- `lurek.math.newRandomGenerator`: module default RNG via
  `battle.setDefaultRng(rng)` and per-battle RNG via `battle:setRng(rng)`.

The library stays portable without engine bindings and falls back to
`math.random`.
