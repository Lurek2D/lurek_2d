# Trick Score Sports

**Category:** Sports and racing  
**Reference games:** Tony Hawk's Pro Skater as structure reference, OlliOlli, SSX as scoring reference, Jet Set Radio as style reference  
**Document type:** Technical game design and architecture

## Design target

A 2D trick-score game focused on movement lines, timed inputs, combo chains, multipliers, objectives, and expressive replay. It can be skateboarding, snowboarding, BMX, parkour, or fictional stunt movement.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Course layout | `lurek.tilemap`, `lurek.physics`, `lurek.camera` |
| Character movement | `lurek.input`, `lurek.math`, `lurek.animation`, `lurek.tween` |
| Trick/combo logic | `lurek.patterns`, `lurek.time`, `lurek.signal` |
| Effects/audio/UI | `lurek.render`, `lurek.audio`, `lurek.particle`, `lurek.ui` |
| Progress | `lurek.save` for scores, objectives, unlocks |

## Runtime architecture

The controller should distinguish locomotion, jump, airtime, grind, wallride, manual, landing, bail, and recovery states. Trick inputs generate trick events with name, base score, difficulty, direction, repetition penalty, and timing window.

The combo system owns current chain, multiplier, balance meter, landing quality, objective counters, and timeout. It should not depend on animation completion. It consumes movement state and trick events, then emits score updates.

Course data includes collision, ramps, rails, gaps, objective markers, collectibles, camera zones, and restart points. Rails and trick surfaces are authored objects with IDs so objectives can reference them.

## Suggested project structure

```text
my_trick_sport/
  data/courses/*.ldtk
  data/tricks.toml
  data/objectives.toml
  scripts/systems/rider_controller.lua
  scripts/systems/trick_resolver.lua
  scripts/systems/combo.lua
  scripts/systems/course_objectives.lua
  scripts/ui/combo_hud.lua
  assets/rider/
```

## Vertical slice acceptance

The slice should include one course, jump, grind, manual, five tricks, combo multiplier, bail, three objectives, timer, results screen, and high-score save.

## Risks

The risk is animation driving rules. Movement state and collision should be authoritative; animation should visualize trick state, not determine whether a trick succeeded.
