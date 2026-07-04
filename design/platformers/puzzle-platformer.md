# Puzzle Platformer

**Category:** Platformers  
**Reference games:** Braid, Limbo, Inside, Thomas Was Alone  
**Document type:** Technical game design and architecture

## Design target

A 2D platformer where traversal is inseparable from puzzle logic: switches, physics props, timing, clones, gravity changes, light beams, or character swapping. The architecture must keep puzzle state reversible and inspectable.

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

## Vertical slice acceptance

The slice should include three puzzle rooms, one reusable switch-door circuit, one movable prop, one timing mechanic, reset button, solved-state persistence, and hint UI.

## Risks

Puzzle games break when state is implicit. Every interactable must declare its inputs, outputs, reset policy, and save policy. Debug mode should list active puzzle channels and listeners.
