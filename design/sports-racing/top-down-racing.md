# Top-Down Racing

**Category:** Sports and racing  
**Reference games:** Micro Machines, Super Sprint, Death Rally, Circuit Superstars  
**Document type:** Technical game design and architecture

## Design target

A top-down 2D racing game with tight vehicle handling, track boundaries, laps, checkpoints, AI drivers, hazards, boosts, and time trials. The architecture should make vehicle feel tunable and replayable.

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

## Vertical slice acceptance

The slice should include one track, three cars, lap timing, checkpoints, surface slowdown, boost pad, two AI opponents, results screen, best-time save, and gamepad support.

## Risks

The risk is inconsistent handling. Use deterministic input intents and data-driven handling curves, then build debug display for velocity, traction, surface, checkpoint, and lap state.
