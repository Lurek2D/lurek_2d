# Top-Down Racing

**Category:** Sports and racing  
**Reference games:** Micro Machines, Super Sprint, Death Rally, Circuit Superstars  
**Document type:** Technical game design and architecture

## Design target

A top-down 2D racing game with tight vehicle handling, track boundaries, laps, checkpoints, AI drivers, hazards, boosts, and time trials. The architecture should make vehicle feel tunable and replayable.

## Market positioning

Use the reference set (Micro Machines, Super Sprint, Death Rally, Circuit Superstars) to define player expectations around pacing, readability, and production scope, not to copy mechanics directly. Target itch.io with instant controls, one ruleset, and a short competitive loop. Target Steam with season/challenge structure, input remapping, ghosts or AI rivals, replayable tracks/arenas, and strong gamepad support. For top-down racing, the store page must communicate the core verb, session length, progression promise, and why the 2D presentation is intentional.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Track map | `lurek.tilemap`, `lurek.physics`, `lurek.camera` |
| Vehicles | `lurek.ecs`, `lurek.math`, `lurek.animation` |
| AI drivers | `lurek.pathfind`, `lurek.ai`, racing line waypoints |
| UI/timing | `lurek.ui`, `lurek.time`, `lurek.save` |
| Feedback | `lurek.audio`, `lurek.particle`, `lurek.effect` |

## Runtime architecture

Use a vehicle controller with acceleration, brake, steering, drift, traction, surface modifiers, boost, collision response, and recovery rules. Store vehicle setup as data so each car can tune handling without changing code.

Track data should include collision polygons, checkpoint order, lap line, camera bounds, surface zones, spawn positions, item/boost placements, and AI waypoint lanes. Timing is authoritative: lap count advances only when checkpoint sequence is valid.

AI drivers follow a racing line but adapt to speed, obstacle, overtake opportunity, and recovery. Keep AI outputs as throttle/steer/brake intents so they use the same vehicle controller as the player.

## Suggested project structure

```text
my_racer/
  data/tracks/*.ldtk
  data/cars.toml
  data/rules.toml
  scripts/systems/vehicle_controller.lua
  scripts/systems/lap_timer.lua
  scripts/systems/surfaces.lua
  scripts/ai/racing_ai.lua
  scripts/ui/race_hud.lua
  assets/cars/
  assets/tracks/
```

## Data and content model

- Author arenas or tracks, teams, vehicles, athletes, ball/puck objects, checkpoints, and scoring zones as data, not hidden script constants.
- Author input bindings, AI profiles, tournament state, lap/round timers, and replay or ghost data as data, not hidden script constants.
- Author physics tuning, camera zones, crowd/audio cues, and challenge progression as data, not hidden script constants.
- Keep top-down racing content split between durable authored files under `data/`, media under `assets/`, and orchestration modules under `scripts/`.
- Save files should store player/world progress and stable identifiers, not transient render objects, cached paths, or UI widget instances.


## Technical design notes

- Use `lurek.physics` for collision, steering, ball/vehicle response, and trigger zones, with authored tuning data separate from code.
- Use `lurek.input` action maps for keyboard and gamepad parity.
- Use `lurek.camera`, `lurek.audio`, `lurek.particle`, and `lurek.effect` for speed, impact, crowd, and scoring feedback.
- Use `lurek.save` for campaign, time trials, unlocks, best scores, and controller preferences.

## Vertical slice acceptance

The slice should include one track, three cars, lap timing, checkpoints, surface slowdown, boost pad, two AI opponents, results screen, best-time save, and gamepad support.

## Risks

The risk is inconsistent handling. Use deterministic input intents and data-driven handling curves, then build debug display for velocity, traction, surface, checkpoint, and lap state.
