# Bullet-Hell Shmup

**Category:** Shooters  
**Reference games:** DoDonPachi, Touhou Project, Ikaruga, Jamestown  
**Document type:** Technical game design and architecture

## Design target

A vertically or horizontally scrolling 2D shooter with precise hitboxes, dense bullet patterns, scoring systems, waves, bosses, and stage scripting. The architecture must handle many bullets while keeping collision and scoring deterministic.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Stage rendering | `lurek.render`, `lurek.parallax`, `lurek.camera` |
| Bullet patterns | `lurek.math`, `lurek.patterns`, `lurek.particle` |
| Actors and collision | `lurek.ecs`, `lurek.physics` or custom hitbox checks |
| Boss scripting | `lurek.ai`, `lurek.tween`, `lurek.signal` |
| Effects/audio | `lurek.audio`, `lurek.effect`, `lurek.animation` |
| Score/replay | `lurek.save`, `lurek.serialize`, `lurek.log` |

## Runtime architecture

Bullet simulation should be a specialized subsystem, not generic full ECS per bullet. Store bullet pools with position, velocity, acceleration, pattern ID, owner, graze radius, hit radius, lifetime, color, and sprite. Render from the pool and perform fast radius or shape checks.

Stage scripts are timelines: spawn wave, change background, start dialogue, move boss, launch pattern, wait until clear, award bonus. Timelines emit commands into systems; they should not directly mutate every subsystem.

Use separate hitboxes for sprite, damage, and graze. Player death should depend on the small damage hitbox, while scoring may use graze proximity and chain timing.

## Suggested project structure

```text
my_shmup/
  data/stages/stage_01.toml
  data/patterns.toml
  data/bosses.toml
  scripts/state/stage_run.lua
  scripts/systems/bullet_pool.lua
  scripts/systems/stage_timeline.lua
  scripts/systems/scoring.lua
  scripts/systems/boss_phases.lua
  scripts/ui/replay_hud.lua
  assets/bullets/
```

## Vertical slice acceptance

The slice should include one scrolling stage, three enemy waves, one boss with two phases, bullet pool, graze scoring, bomb/clear mechanic, score save, and deterministic replay seed.

## Risks

The risk is treating bullets as rich objects. Keep bullet data compact, avoid allocations during patterns, and make pattern scripts declarative enough to debug frame-by-frame.
