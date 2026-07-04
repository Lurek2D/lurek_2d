# Real-Time RTS Economy Combat

**Category:** Strategy games  
**Reference games:** Dune II, Command & Conquer, Age of Empires II, StarCraft  
**Document type:** Technical game design and architecture

## Design target

A 2D real-time strategy game where workers harvest resources, bases produce units, armies maneuver on a map, and the player wins through economy, positioning, scouting, and timing. Lurek2D is a good fit for a desktop RTS if the design keeps unit counts realistic and emphasizes data-driven 2D simulation over 3D spectacle.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Large 2D map with layers | `lurek.tilemap`, `lurek.camera`, `lurek.minimap` |
| Unit population | `lurek.ecs` components for position, selection, faction, command, health |
| Movement and formation intent | `lurek.pathfind` flow fields, weighted grids, async route requests |
| Combat simulation | `lurek.timer`, `lurek.math`, `lurek.physics` for proximity and collision rules |
| AI skirmish opponent | `lurek.ai` behavior trees, utility scoring, squad coordination |
| Selection UI and command panels | `lurek.ui`, `lurek.input`, `lurek.render` |
| Feedback | `lurek.audio`, `lurek.particle`, `lurek.effect` |

## Runtime architecture

Use a real-time simulation state with clear command queues. Mouse input creates high-level commands: select, move, attack, build, harvest, rally. Commands are stored per entity or per squad, then resolved by systems in deterministic order: economy, build queues, movement, targeting, weapon cooldowns, damage, death cleanup, visibility, and UI notification.

Do not ask every unit for an independent expensive path each frame. Use coarse routes for groups, flow fields for common goals, and local steering for avoidance. Units should expose intent and current order separately so UI can show queued behavior and AI can reason about interruptions.

Rendering should be layered: terrain, resource nodes, buildings, units, projectiles, particles, selection rings, range overlays, fog, HUD. Keep debug overlays for path cost, current command, and targeting owner available behind a dev flag.

## Suggested project structure

```text
my_rts/
  data/rules/factions.toml
  data/rules/units.toml
  data/rules/buildings.toml
  data/maps/skirmish_01.ldtk
  scripts/state/world.lua
  scripts/systems/selection.lua
  scripts/systems/orders.lua
  scripts/systems/economy.lua
  scripts/systems/combat.lua
  scripts/systems/rts_ai.lua
  scripts/ui/command_card.lua
  assets/units/
  assets/buildings/
```

## Vertical slice acceptance

Build one map with harvestable resources, one headquarters, one worker, one barracks, one combat unit, drag selection, right-click movement, attack order, fog toggle, minimap markers, basic AI wave, and restartable save state.

## Risks

The main risk is pathfinding cost. Plan path budgets early and design maps with chokepoints that are readable but not solver-hostile. The second risk is command ambiguity; solve it through explicit command objects and consistent UI feedback, not hidden input branches.
