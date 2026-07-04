# Run-and-Gun Platformer

**Category:** Platformers  
**Reference games:** Contra, Metal Slug, Broforce, Mega Man X  
**Document type:** Technical game design and architecture

## Design target

A side-scrolling action platformer with responsive movement, directional shooting, enemy waves, destructible targets, pickups, bosses, and high audiovisual feedback. The architecture should keep combat readable while many projectiles are active.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Level and scrolling | `lurek.tilemap`, `lurek.camera`, `lurek.parallax` |
| Actor/projectile population | `lurek.ecs`, `lurek.physics`, `lurek.animation` |
| Enemy behavior | `lurek.ai`, `lurek.patterns` FSM helpers |
| Effects | `lurek.particle`, `lurek.audio`, `lurek.effect`, `lurek.render` |
| UI and score | `lurek.ui`, `lurek.save` |

## Runtime architecture

Use lanes or screen-space spawn triggers to stage encounters. The level defines camera rails, spawn volumes, hazard volumes, destructible entities, checkpoint gates, and boss arenas. A director system activates encounters as the camera or player crosses authored regions.

Projectiles should be lightweight. Represent common bullets as pooled components or compact tables with position, velocity, owner, hit mask, damage, lifetime, and visual ID. Reserve full ECS entities for actors, bosses, destructible props, and special projectiles with behavior.

Enemy AI can be simple but must be data-driven: patrol, aim, burst fire, jump, charge, retreat, boss phase. Bosses should be state machines with explicit telegraphs and interrupt windows.

## Suggested project structure

```text
my_run_gun/
  data/levels/*.ldtk
  data/enemies.toml
  data/weapons.toml
  data/bosses.toml
  scripts/systems/player_controller.lua
  scripts/systems/projectiles.lua
  scripts/systems/spawn_director.lua
  scripts/systems/combat.lua
  scripts/ai/enemy_fsm.lua
  scripts/ui/hud.lua
  assets/enemies/
  assets/fx/
```

## Vertical slice acceptance

One level should include two weapons, three enemy types, destructible crate, scrolling camera, checkpoint, miniboss phase, pickups, score, hit feedback, and restart flow.

## Risks

The risk is projectile overload. Separate projectile simulation from presentation, pool repeated effects, and cap offscreen actors aggressively.
