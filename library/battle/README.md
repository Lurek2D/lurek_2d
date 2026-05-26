# battle

A pure-Lua turn-based combat engine. Models combatants with status effects, combat actions (attack, skill, item, flee), and full battle resolution including damage rolls, buffs, debuffs, and victory detection.

## Usage

```lua
local battle = require("library/battle")

local hero  = battle.Combatant.new({ name = "Hero",  hp = 100, atk = 20, def = 5 })
local enemy = battle.Combatant.new({ name = "Slime", hp =  40, atk = 10, def = 2 })

local b = battle.CombatBattle.new({ hero, enemy })
b:start()
while not b:isOver() do
    b:queueAction(hero, battle.CombatAction.attack(enemy))
    b:queueAction(enemy, battle.CombatAction.attack(hero))
    b:resolveTurn()
end
print("Winner:", b:winner().name)
```

## Dependencies

- `lurek.math` (optional), `lurek.event` (optional)
