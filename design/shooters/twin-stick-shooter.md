# Twin-Stick Shooter

**Category:** Shooters  
**Reference games:** Robotron: 2084, Geometry Wars, Smash TV, Nuclear Throne  
**Document type:** Technical game design and architecture

## Design target

A fast top-down shooter with independent movement and aiming, enemy swarms, pickups, arena hazards, weapon variety, screen shake, particles, and score/combo pressure. It should feel immediate and readable even under heavy effects.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Input and aiming | `lurek.input`, gamepad callbacks, `lurek.math` |
| Actors and bullets | `lurek.ecs`, `lurek.physics`, `lurek.animation` |
| Enemy swarms | `lurek.ai`, `lurek.pathfind`, `lurek.awareness` |
| Effects | `lurek.particle`, `lurek.audio`, `lurek.effect`, `lurek.tween` |
| UI/score | `lurek.ui`, `lurek.render`, `lurek.save` |

## Runtime architecture

Use an arena state with player, enemies, bullets, pickups, hazards, wave number, score, combo, and director intensity. The player controller accepts movement vector and aim vector independently. Keyboard/mouse and gamepad should map to the same intent structure.

Bullets should be compact and pooled. Define weapon data with fire rate, spread, count, speed, lifetime, damage, pierce, knockback, and effect preset. Collision layers must distinguish player shots, enemy shots, enemies, player, walls, pickups, and hazards.

A wave director spawns enemies according to budget, arena region, player pressure, and current combo. AI can be lightweight: seek, orbit, flee, fire, charge, split, explode.

## Suggested project structure

```text
my_twin_stick/
  data/weapons.toml
  data/enemies.toml
  data/waves.toml
  data/arenas/*.ldtk
  scripts/state/arena.lua
  scripts/systems/player_aim.lua
  scripts/systems/bullets.lua
  scripts/systems/wave_director.lua
  scripts/systems/pickups.lua
  scripts/ui/score_hud.lua
```

## Vertical slice acceptance

The slice should include one arena, two weapons, four enemy types, wave progression, pickup, combo counter, gamepad and mouse aim, death/restart, and high-score save.

## Risks

The risk is visual noise. Establish priority rules for particles, shake, bloom, hit flashes, and UI so the player can always read threats.
