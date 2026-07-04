# Tactical Cover Shooter

**Category:** Shooters  
**Reference games:** Hotline Miami as pace reference, Door Kickers, Alien Swarm, SYNTHETIK  
**Document type:** Technical game design and architecture

## Design target

A top-down shooter emphasizing cover, line of sight, suppression, ammunition, reload timing, enemy coordination, and lethal positioning. It can be real-time or pause-and-plan, but must make spatial tactics understandable.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Map and cover | `lurek.tilemap`, `lurek.tilefield`, `lurek.light` |
| Actors/weapons | `lurek.ecs`, `lurek.physics`, `lurek.animation` |
| LOS and navigation | `lurek.pathfind`, `lurek.math`, `lurek.awareness` |
| AI squads | `lurek.ai` blackboards, squad coordination, utility scoring |
| UI feedback | `lurek.ui`, `lurek.render`, `lurek.audio`, `lurek.effect` |

## Runtime architecture

Cover should be authored or derived as directional cover points with exposure arcs, lean positions, destructibility, and traversal cost. Line of sight is a query service that returns obstruction, cover modifier, distance, and visibility reason.

Weapons are data assets with rate of fire, spread, recoil, magazine, reload time, penetration, suppression value, audio profile, and tracer style. Combat systems emit events: shot fired, cover hit, actor suppressed, actor wounded, reload started, reload complete.

Enemy squads share a blackboard containing known player position, last sound, flank routes, suppression targets, and morale. Individual agents choose orders but group coordination avoids every enemy rushing independently.

## Suggested project structure

```text
my_cover_shooter/
  data/levels/*.ldtk
  data/weapons.toml
  data/enemies.toml
  scripts/systems/cover.lua
  scripts/systems/line_of_sight.lua
  scripts/systems/weapons.lua
  scripts/systems/suppression.lua
  scripts/ai/squad_ai.lua
  scripts/ui/tactical_overlay.lua
```

## Vertical slice acceptance

One level should include cover nodes, two weapons, reloads, suppression, three enemy roles, flank AI, destructible prop, objective room, and combat log.

## Risks

The main risk is invisible modifiers. Show cover state, suppression, reload, and line-of-fire previews clearly. Tactical shooters need explainability as much as fast reactions.
