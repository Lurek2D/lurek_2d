# Squad Tactics Skirmish

**Category:** Tactics combat  
**Reference games:** X-COM: UFO Defense, Jagged Alliance 2, Into the Breach, Door Kickers  
**Document type:** Technical game design and architecture

## Design target

A mission-based tactics game where a small squad moves across a grid or freeform 2D map, uses cover, spends action points, manipulates line of sight, and resolves lethal encounters. The design goal is readable tactical causality: every hit, miss, flank, overwatch trigger, and panic result should be explainable.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Tactical map | `lurek.tilemap`, `lurek.tilefield`, `lurek.light` for visibility mood |
| Movement ranges | `lurek.pathfind` budgeted reachability and weighted costs |
| Soldiers and enemies | `lurek.ecs` components for stats, cover, inventory, stance, action points |
| Enemy behavior | `lurek.ai` behavior trees, utility targeting, blackboards |
| Combat presentation | `lurek.animation`, `lurek.particle`, `lurek.audio`, `lurek.effect` |
| UI and tooltips | `lurek.ui`, `lurek.render`, `lurek.input` |

## Runtime architecture

Use an explicit `TacticalTurn` state machine: planning, unit selected, action preview, action committed, reaction window, resolution, cleanup, and faction switch. Never mutate health or ammo during preview. Previews produce projected results that the UI can display; commits produce authoritative events.

Store cover, concealment, flammability, elevation tag, blocked movement, and blocked sight in tile facts. A unit component stores action points, morale, weapon profile, inventory slots, stance, wounds, and reaction flags. Line of sight and hit scoring should be services that return trace records for debug overlays.

Enemy AI should score actions using visible threats, objectives, safety, suppression, and flank potential. It should output intents such as move-to-cover, overwatch, attack-target, retreat, or interact-objective. The resolution system performs the actual mutation.

## Suggested project structure

```text
my_tactics/
  data/missions/warehouse.ldtk
  data/rules/weapons.toml
  data/rules/classes.toml
  scripts/state/tactical_turn.lua
  scripts/systems/action_points.lua
  scripts/systems/cover.lua
  scripts/systems/line_of_sight.lua
  scripts/systems/combat_resolution.lua
  scripts/ai/enemy_tactics.lua
  scripts/ui/action_bar.lua
  assets/units/
```

## Vertical slice acceptance

One mission should support two player units, three enemies, movement range overlay, cover preview, one weapon, overwatch reaction, enemy turn, mission success/failure, and a combat log that explains every damage result.

## Risks

The risk is preview/commit mismatch. The same services must feed both UI prediction and final resolution, with random seeds or probability rolls isolated at commit time.
