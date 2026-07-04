# Precision Platformer

**Category:** Platformers  
**Reference games:** Celeste, Super Meat Boy, N++, VVVVVV  
**Document type:** Technical game design and architecture

## Design target

A tight 2D platformer where jumps, dashes, wall interactions, hazards, checkpoints, and retry flow must feel exact. The product depends less on content volume than on deterministic movement and fast failure recovery.

## Market positioning

Use the reference set (Celeste, Super Meat Boy, N++, VVVVVV) to define player expectations around pacing, readability, and production scope, not to copy mechanics directly. Target itch.io with a polished movement verb and a small level set that communicates the hook immediately. Target Steam with controller-first input, assist options, speedrun timers, level/chapter progression, and enough authored rooms to support reviews beyond a prototype. For precision platformer, the store page must communicate the core verb, session length, progression promise, and why the 2D presentation is intentional.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Player movement and collision | `lurek.physics`, `lurek.input`, `lurek.math` |
| Rooms and hazards | `lurek.tilemap`, `lurek.tilefield`, `lurek.scene` |
| Animation and feel | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` |
| Camera and shake | `lurek.camera`, `lurek.render`, `lurek.effect` |
| Assist/debug tools | `lurek.devtools`, `lurek.log`, `lurek.overlay` |
| Progress | `lurek.save` for chapter, checkpoint, collectibles, assists |

## Runtime architecture

Use a dedicated movement controller with explicit states: grounded, coyote, jumping, falling, wall-slide, dash, climb, stunned, and respawn. Input buffering and coyote time are gameplay rules, not input hacks. Store timers and transition reasons so movement bugs can be replayed.

Levels should be authored as rooms with spawn point, camera bounds, collision layer, hazard layer, collectible IDs, checkpoint positions, and exit triggers. Hazards should be simple deterministic volumes. If physics is used, keep player movement controlled by the platformer controller rather than by unconstrained rigid-body impulses.

The retry loop is a first-class system. Death freezes briefly, emits feedback, resets transient room state, restores the checkpoint, and preserves durable collectibles according to design policy.

## Suggested project structure

```text
my_precision_platformer/
  data/chapters/*.ldtk
  data/movement.toml
  scripts/systems/player_movement.lua
  scripts/systems/hazards.lua
  scripts/systems/checkpoints.lua
  scripts/systems/room_reset.lua
  scripts/ui/assist_options.lua
  assets/player/
  assets/tiles/
```

## Data and content model

- Author rooms, collision layers, hazard layers, spawn points, exits, and camera bounds as data, not hidden script constants.
- Author movement constants, assist settings, collectible IDs, checkpoints, and room reset policy as data, not hidden script constants.
- Author animation states, audio cues, particles, timers, and death/retry counters as data, not hidden script constants.
- Keep precision platformer content split between durable authored files under `data/`, media under `assets/`, and orchestration modules under `scripts/`.
- Save files should store player/world progress and stable identifiers, not transient render objects, cached paths, or UI widget instances.


## Technical design notes

- Use `lurek.input` action buffering and explicit movement states instead of coupling movement directly to raw key events.
- Use `lurek.physics` for collision queries and sensors, but keep the platforming controller authoritative for feel-critical motion.
- Use `lurek.camera`, `lurek.particle`, `lurek.audio`, and `lurek.tween` for feedback that does not alter simulation results.
- Use `lurek.devtools`, `lurek.log`, and `lurek.overlay` to inspect velocity, grounded state, collision normals, and retry state.

## Vertical slice acceptance

One chapter should include five rooms, jump, dash, wall slide, spikes, moving hazard, checkpoint reset, collectible, death counter, timer, and assist toggle.

## Risks

The main risk is feel regression. Treat movement constants as data and add debug overlays for velocity, grounded state, coyote timer, dash timer, and collision normals.
