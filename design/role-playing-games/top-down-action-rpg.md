# Top-Down Action RPG

**Category:** Role-playing games  
**Reference games:** Diablo, Secret of Mana, Ys, Bastion  
**Document type:** Technical game design and architecture

## Design target

A top-down real-time RPG with zones, enemies, loot, stats, skills, quests, NPCs, and persistent character progression. The architecture should keep combat, loot, and progression data-driven.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Zones and dungeons | `lurek.tilemap`, `lurek.scene`, `lurek.camera` |
| Characters and items | `lurek.ecs`, Lureksome inventory/item/stats libraries |
| Combat | `lurek.physics`, `lurek.animation`, `lurek.particle`, `lurek.audio` |
| Enemy AI | `lurek.ai`, `lurek.pathfind` |
| Quests and dialogue | `lurek.dialog`, `lurek.signal`, Lureksome quest library |
| Saves | `lurek.save` with character, world, inventory, quest sections |

## Runtime architecture

Use a persistent character profile and zone-local runtime state. Character profile stores level, stats, skills, equipment, inventory, quest flags, and discovered waypoints. Zone state stores enemies, destructibles, local events, loot drops, and transition triggers.

Skills should be data-driven actions with cost, cooldown, target shape, hit policy, animation, and effect list. Loot should be generated from item definitions, rarity tables, affix pools, and level ranges. Keep item instances serializable and stable.

Enemy AI can use behavior trees with clear phases: idle, patrol, aggro, pursue, attack, retreat, special, dead. Pathfinding should be budgeted for groups and cached when possible.

## Suggested project structure

```text
my_action_rpg/
  data/zones/*.ldtk
  data/items.toml
  data/skills.toml
  data/enemies.toml
  data/quests.toml
  scripts/state/character.lua
  scripts/systems/combat.lua
  scripts/systems/loot.lua
  scripts/systems/skills.lua
  scripts/ai/enemy_brains.lua
  scripts/ui/inventory.lua
```

## Vertical slice acceptance

One slice should include town, dungeon zone, two skills, five item drops, two enemies, one boss, quest start/complete, inventory equipment, level-up, and save/load.

## Risks

The risk is stat formula opacity. Centralize formulas, show derived stats in UI, and log combat events with source, target, modifiers, and final result.
