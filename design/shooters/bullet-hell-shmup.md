# Bullet-Hell Shmup

**Category:** Shooters  
**Reference games:** DoDonPachi, Touhou Project, Ikaruga, Jamestown  
**Document type:** Technical game design and architecture

## Design target

A vertically or horizontally scrolling 2D shooter with precise hitboxes, dense bullet patterns, scoring systems, waves, bosses, and stage scripting. The architecture must handle many bullets while keeping collision and scoring deterministic.

## Market positioning

Use the reference set (DoDonPachi, Touhou Project, Ikaruga, Jamestown) to define player expectations around pacing, readability, and production scope, not to copy mechanics directly. Target itch.io with immediate feel, clear hit feedback, and a small arena or stage set. Target Steam with input remapping, difficulty curves, scoreboards or challenge goals, boss patterns, progression unlocks, and strong audio-visual feedback. For bullet-hell shmup, the store page must communicate the core verb, session length, progression promise, and why the 2D presentation is intentional.

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

## Data and content model

- Author arenas or stages, enemy waves, projectile patterns, pickups, and collision categories as data, not hidden script constants.
- Author weapon data, cooldowns, score rules, player upgrades, difficulty modifiers, and hit feedback as data, not hidden script constants.
- Author boss scripts, replay seeds, audio buses, particles, and camera shake profiles as data, not hidden script constants.
- Keep bullet-hell shmup content split between durable authored files under `data/`, media under `assets/`, and orchestration modules under `scripts/`.
- Save files should store player/world progress and stable identifiers, not transient render objects, cached paths, or UI widget instances.


## Technical design notes

- Use `lurek.ecs` for bullets, enemies, pickups, hit sparks, and timed effects so object churn remains organized.
- Use `lurek.input` actions for move, aim, fire, dash, reload, weapon swap, and pause.
- Use `lurek.physics` for collision categories and sensors, while projectile pattern ownership stays in gameplay systems.
- Use `lurek.audio`, `lurek.particle`, `lurek.effect`, and `lurek.camera` for hit confirmation, screen shake, and danger readability.

## Vertical slice acceptance

The slice should include one scrolling stage, three enemy waves, one boss with two phases, bullet pool, graze scoring, bomb/clear mechanic, score save, and deterministic replay seed.

## Risks

The risk is treating bullets as rich objects. Keep bullet data compact, avoid allocations during patterns, and make pattern scripts declarative enough to debug frame-by-frame.
