# Precision Platformer

**Category:** Platformers  
**Reference games:** Celeste, Super Meat Boy, N++, VVVVVV  
**Document type:** Technical game design and architecture

## Design target

A tight 2D platformer where jumps, dashes, wall interactions, hazards, checkpoints, and retry flow must feel exact. The product depends less on content volume than on deterministic movement and fast failure recovery.

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

## Vertical slice acceptance

One chapter should include five rooms, jump, dash, wall slide, spikes, moving hazard, checkpoint reset, collectible, death counter, timer, and assist toggle.

## Risks

The main risk is feel regression. Treat movement constants as data and add debug overlays for velocity, grounded state, coyote timer, dash timer, and collision normals.
