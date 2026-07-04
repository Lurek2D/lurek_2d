# Puzzle Platformer

**Category:** Platformers  
**Reference games:** Braid, Limbo, Inside, Thomas Was Alone  
**Document type:** Technical game design and architecture

## Design target

A 2D platformer where traversal is inseparable from puzzle logic: switches, physics props, timing, clones, gravity changes, light beams, or character swapping. The architecture must keep puzzle state reversible and inspectable.

## Market positioning

Use the reference set (Braid, Limbo, Inside, Thomas Was Alone) to define player expectations around pacing, readability, and production scope, not to copy mechanics directly. Target itch.io with a polished movement verb and a small level set that communicates the hook immediately. Target Steam with controller-first input, assist options, speedrun timers, level/chapter progression, and enough authored rooms to support reviews beyond a prototype. For puzzle platformer, the store page must communicate the core verb, session length, progression promise, and why the 2D presentation is intentional.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Platforming | `lurek.physics`, `lurek.input`, `lurek.animation` |
| Puzzle rooms | `lurek.tilemap`, `lurek.scene`, `lurek.signal` |
| Interactive objects | `lurek.ecs`, `lurek.patterns`, `lurek.tween` |
| Visual explanation | `lurek.render`, `lurek.light`, `lurek.effect` |
| State persistence | `lurek.save`, `lurek.serialize` |

## Runtime architecture

Each puzzle room should have a local `PuzzleState` with switches, doors, props, emitters, receivers, timers, and solved flag. The room loader creates entities from data, then puzzle systems process interactions. The global save records solved status and durable pickups; resettable props remain room-local.

Design puzzle components as declarative relationships. A pressure plate emits a signal, a door listens to a channel, a mirror redirects a beam, a block has mass and material, a clone recorder stores input frames. Avoid hard-coding room-specific logic in `main.lua`; each room should be data plus reusable components.

If the game includes rewind or reset, record state snapshots at puzzle-safe boundaries. Do not blindly serialize every particle or tween. Capture only the logical state needed to reconstruct the room.

## Suggested project structure

```text
my_puzzle_platformer/
  data/rooms/*.ldtk
  data/puzzle_objects.toml
  scripts/state/puzzle_state.lua
  scripts/systems/platform_movement.lua
  scripts/systems/puzzle_signals.lua
  scripts/systems/props.lua
  scripts/systems/rewind.lua
  scripts/ui/hints.lua
  assets/objects/
```

## Data and content model

- Author rooms, collision layers, hazard layers, spawn points, exits, and camera bounds as data, not hidden script constants.
- Author movement constants, assist settings, collectible IDs, checkpoints, and room reset policy as data, not hidden script constants.
- Author animation states, audio cues, particles, timers, and death/retry counters as data, not hidden script constants.
- Keep puzzle platformer content split between durable authored files under `data/`, media under `assets/`, and orchestration modules under `scripts/`.
- Save files should store player/world progress and stable identifiers, not transient render objects, cached paths, or UI widget instances.


## Technical design notes

- Use `lurek.input` action buffering and explicit movement states instead of coupling movement directly to raw key events.
- Use `lurek.physics` for collision queries and sensors, but keep the platforming controller authoritative for feel-critical motion.
- Use `lurek.camera`, `lurek.particle`, `lurek.audio`, and `lurek.tween` for feedback that does not alter simulation results.
- Use `lurek.devtools`, `lurek.log`, and `lurek.overlay` to inspect velocity, grounded state, collision normals, and retry state.

## Vertical slice acceptance

The slice should include three puzzle rooms, one reusable switch-door circuit, one movable prop, one timing mechanic, reset button, solved-state persistence, and hint UI.

## Risks

Puzzle games break when state is implicit. Every interactable must declare its inputs, outputs, reset policy, and save policy. Debug mode should list active puzzle channels and listeners.
