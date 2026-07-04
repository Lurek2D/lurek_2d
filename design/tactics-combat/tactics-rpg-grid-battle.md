# Tactics RPG Grid Battle

**Category:** Tactics combat  
**Reference games:** Final Fantasy Tactics, Tactics Ogre, Fire Emblem, Shining Force  
**Document type:** Technical game design and architecture

## Design target

A character-driven tactics RPG built around discrete maps, party growth, job classes, equipment, grid movement, skill ranges, and scripted battle objectives. Compared with a pure skirmish sim, this design emphasizes readable character identity, progression, ability kits, and authored encounter pacing.

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

## Vertical slice acceptance

Ship one battle with four party members, two classes, five abilities, one status effect, one dialogue intro, one victory condition, battle forecast UI, experience award, and persistence back to campaign state.

## Risks

Progression systems can overwhelm battle clarity. Keep formulas data-driven but limited at first, and make every ability preview include target cells, expected damage, status chance, and resource cost.
