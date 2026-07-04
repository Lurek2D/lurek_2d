# Tactical Cover Shooter

**Category:** Shooters  
**Reference games:** Hotline Miami as pace reference, Door Kickers, Alien Swarm, SYNTHETIK  
**Document type:** Technical game design and architecture

## Design target

A top-down shooter emphasizing cover, line of sight, suppression, ammunition, reload timing, enemy coordination, and lethal positioning. It can be real-time or pause-and-plan, but must make spatial tactics understandable.

## Market positioning

Use the reference set (Hotline Miami as pace reference, Door Kickers, Alien Swarm, SYNTHETIK) to define player expectations around pacing, readability, and production scope, not to copy mechanics directly. Target itch.io with immediate feel, clear hit feedback, and a small arena or stage set. Target Steam with input remapping, difficulty curves, scoreboards or challenge goals, boss patterns, progression unlocks, and strong audio-visual feedback. For tactical cover shooter, the store page must communicate the core verb, session length, progression promise, and why the 2D presentation is intentional.

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

## Data and content model

- Author arenas or stages, enemy waves, projectile patterns, pickups, and collision categories as data, not hidden script constants.
- Author weapon data, cooldowns, score rules, player upgrades, difficulty modifiers, and hit feedback as data, not hidden script constants.
- Author boss scripts, replay seeds, audio buses, particles, and camera shake profiles as data, not hidden script constants.
- Keep tactical cover shooter content split between durable authored files under `data/`, media under `assets/`, and orchestration modules under `scripts/`.
- Save files should store player/world progress and stable identifiers, not transient render objects, cached paths, or UI widget instances.


## Technical design notes

- Use `lurek.ecs` for bullets, enemies, pickups, hit sparks, and timed effects so object churn remains organized.
- Use `lurek.input` actions for move, aim, fire, dash, reload, weapon swap, and pause.
- Use `lurek.physics` for collision categories and sensors, while projectile pattern ownership stays in gameplay systems.
- Use `lurek.audio`, `lurek.particle`, `lurek.effect`, and `lurek.camera` for hit confirmation, screen shake, and danger readability.

## Vertical slice acceptance

One level should include cover nodes, two weapons, reloads, suppression, three enemy roles, flank AI, destructible prop, objective room, and combat log.

## Risks

The main risk is invisible modifiers. Show cover state, suppression, reload, and line-of-fire previews clearly. Tactical shooters need explainability as much as fast reactions.
