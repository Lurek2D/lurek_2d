# Auto Battler Simulation

**Category:** Tactics combat  
**Reference games:** Teamfight Tactics, Auto Chess, Gladiabots, The Last Flame  
**Document type:** Technical game design and architecture

## Design target

An auto battler where the player drafts units, places them on a board, combines synergies, and watches deterministic or semi-deterministic combat resolve. The core tension is preparation quality, not moment-to-moment control.

## Market positioning

Use the reference set (Teamfight Tactics, Auto Chess, Gladiabots, The Last Flame) to define player expectations around pacing, readability, and production scope, not to copy mechanics directly. Target itch.io with a compact battle puzzle and readable combat outcomes. Target Steam with campaign structure, roster progression, AI variety, undo/replay tools where appropriate, and scenario authoring that keeps encounters maintainable. For auto battler simulation, the store page must communicate the core verb, session length, progression promise, and why the 2D presentation is intentional.

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

## Data and content model

- Author battle maps, cover/elevation tags, units, abilities, initiative, objectives, and spawn groups as data, not hidden script constants.
- Author action history, line-of-sight, reservations, AI plans, status effects, and combat result records as data, not hidden script constants.
- Author campaign roster, equipment, injuries, scenario rewards, and replay/debug traces as data, not hidden script constants.
- Keep auto battler simulation content split between durable authored files under `data/`, media under `assets/`, and orchestration modules under `scripts/`.
- Save files should store player/world progress and stable identifiers, not transient render objects, cached paths, or UI widget instances.


## Technical design notes

- Use `lurek.tilefield` for tactical cell facts such as cover, elevation, movement cost, hazards, and occupancy.
- Use `lurek.pathfind` for move ranges, attack reach previews, AI route checks, and objective distance scoring.
- Use `lurek.ai` for staged enemy planning and `lurek.ui` for readable odds, tooltips, turn order, and action confirmation.
- Use `lurek.save` for campaign roster and between-battle state; keep in-battle undo/replay as a separate deterministic action log.

## Vertical slice acceptance

The slice should include eight units, three synergies, a reroll shop, bench management, placement grid, one full combat round, deterministic replay from seed, damage numbers, and round rewards.

## Risks

The main risk is opaque outcomes. Auto battlers require trust. Store combat events, expose damage contribution, show active synergies, and allow a debug replay that reproduces the same fight from the same seed.
