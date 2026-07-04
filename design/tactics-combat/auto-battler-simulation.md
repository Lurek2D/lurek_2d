# Auto Battler Simulation

**Category:** Tactics combat  
**Reference games:** Teamfight Tactics, Auto Chess, Gladiabots, The Last Flame  
**Document type:** Technical game design and architecture

## Design target

An auto battler where the player drafts units, places them on a board, combines synergies, and watches deterministic or semi-deterministic combat resolve. The core tension is preparation quality, not moment-to-moment control.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Board and placement | `lurek.tilemap`, `lurek.input`, `lurek.ui` |
| Unit population | `lurek.ecs` components for team, stats, traits, target, cast state |
| AI combat decisions | `lurek.ai` utility targeting, behavior trees, blackboards |
| Motion and engagement | `lurek.pathfind`, `lurek.tween`, `lurek.animation` |
| Draft/shop economy | `lurek.dataframe`, `lurek.filesystem`, `lurek.serialize` |
| Combat visualization | `lurek.render`, `lurek.particle`, `lurek.audio`, `lurek.effect` |

## Runtime architecture

Split the match into buy phase, placement phase, combat phase, reward phase, and transition phase. During buy and placement, the player mutates roster and board slots. During combat, player input is mostly observational and the simulation runs from unit AI plus ability cooldowns.

Each unit definition should include base stats, tags, attack profile, ability profile, targeting policy, movement style, and merge tier. Synergies are separate rules that scan the deployed roster and emit modifiers. Do not bake synergy effects into units because balancing requires independent tuning.

Combat should run as a reproducible event stream. AI selects targets, movement chooses reachable positions, attacks generate damage events, abilities generate effect events, death cleanup removes entities, and the presenter animates the stream.

## Suggested project structure

```text
my_auto_battler/
  data/units.toml
  data/synergies.toml
  data/items.toml
  scripts/state/match.lua
  scripts/systems/shop.lua
  scripts/systems/placement.lua
  scripts/systems/synergies.lua
  scripts/systems/combat_sim.lua
  scripts/ai/unit_brains.lua
  scripts/ui/bench.lua
  scripts/ui/combat_log.lua
```

## Vertical slice acceptance

The slice should include eight units, three synergies, a reroll shop, bench management, placement grid, one full combat round, deterministic replay from seed, damage numbers, and round rewards.

## Risks

The main risk is opaque outcomes. Auto battlers require trust. Store combat events, expose damage contribution, show active synergies, and allow a debug replay that reproduces the same fight from the same seed.
