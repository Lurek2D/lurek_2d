# Tactics RPG Grid Battle

**Category:** Tactics combat  
**Reference games:** Final Fantasy Tactics, Tactics Ogre, Fire Emblem, Shining Force  
**Document type:** Technical game design and architecture

## Design target

A character-driven tactics RPG built around discrete maps, party growth, job classes, equipment, grid movement, skill ranges, and scripted battle objectives. Compared with a pure skirmish sim, this design emphasizes readable character identity, progression, ability kits, and authored encounter pacing.

## Market positioning

Use the reference set (Final Fantasy Tactics, Tactics Ogre, Fire Emblem, Shining Force) to define player expectations around pacing, readability, and production scope, not to copy mechanics directly. Target itch.io with a compact battle puzzle and readable combat outcomes. Target Steam with campaign structure, roster progression, AI variety, undo/replay tools where appropriate, and scenario authoring that keeps encounters maintainable. For tactics rpg grid battle, the store page must communicate the core verb, session length, progression promise, and why the 2D presentation is intentional.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Grid or isometric battlefield | `lurek.tilemap`, `lurek.camera`, `lurek.render.drawIsoCubeTile` |
| Move and skill range | `lurek.pathfind`, `lurek.tilefield` |
| Party and enemies | `lurek.ecs`, `lurek.serialize`, `lurek.save` |
| Ability sequencing | `lurek.patterns`, `lurek.tween`, `lurek.animation` |
| Dialogue and cut-ins | `lurek.dialog`, `lurek.ui`, `lurek.cinematic` |
| Progression data | `lurek.filesystem`, `lurek.dataframe` |

## Runtime architecture

Separate campaign state from battle state. Campaign state owns roster, inventory, unlocked jobs, story flags, and save metadata. Battle state owns the active map, initiative order, deployed actors, temporary statuses, objective counters, and queued animation beats.

Design each action as a data asset: cost, target shape, range rule, line-of-sight requirement, damage formula key, animation label, status effects, and AI tags. The action resolver consumes the asset and produces a list of result events. The presentation layer turns those events into tweens, particles, sound, camera shakes, and floating text.

Initiative should be deterministic and inspectable. Either use strict team phases or a timeline queue. Store every temporary buff with owner, source, duration policy, stacking rule, and expiry trigger.

## Suggested project structure

```text
my_tactics_rpg/
  data/classes/*.toml
  data/abilities/*.toml
  data/battles/chapter_01.ldtk
  data/story/dialogue/*.toml
  scripts/state/campaign.lua
  scripts/state/battle.lua
  scripts/systems/initiative.lua
  scripts/systems/ability_resolver.lua
  scripts/systems/status_effects.lua
  scripts/ui/battle_forecast.lua
  assets/portraits/
  assets/battle_sprites/
```

## Data and content model

- Author battle maps, cover/elevation tags, units, abilities, initiative, objectives, and spawn groups as data, not hidden script constants.
- Author action history, line-of-sight, reservations, AI plans, status effects, and combat result records as data, not hidden script constants.
- Author campaign roster, equipment, injuries, scenario rewards, and replay/debug traces as data, not hidden script constants.
- Keep tactics rpg grid battle content split between durable authored files under `data/`, media under `assets/`, and orchestration modules under `scripts/`.
- Save files should store player/world progress and stable identifiers, not transient render objects, cached paths, or UI widget instances.


## Technical design notes

- Use `lurek.tilefield` for tactical cell facts such as cover, elevation, movement cost, hazards, and occupancy.
- Use `lurek.pathfind` for move ranges, attack reach previews, AI route checks, and objective distance scoring.
- Use `lurek.ai` for staged enemy planning and `lurek.ui` for readable odds, tooltips, turn order, and action confirmation.
- Use `lurek.save` for campaign roster and between-battle state; keep in-battle undo/replay as a separate deterministic action log.

## Vertical slice acceptance

Ship one battle with four party members, two classes, five abilities, one status effect, one dialogue intro, one victory condition, battle forecast UI, experience award, and persistence back to campaign state.

## Risks

Progression systems can overwhelm battle clarity. Keep formulas data-driven but limited at first, and make every ability preview include target cells, expected damage, status chance, and resource cost.
