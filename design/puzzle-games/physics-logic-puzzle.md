# Physics Logic Puzzle

**Category:** Puzzle games  
**Reference games:** World of Goo, The Incredible Machine, Crayon Physics Deluxe, Poly Bridge  
**Document type:** Technical game design and architecture

## Design target

A 2D physics puzzle where players place, connect, cut, trigger, or tune objects to satisfy a goal. The challenge is building systems that behave consistently enough to be solved, while still feeling physical.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Physics bodies | `lurek.physics`, `lurek.math` |
| Construction UI | `lurek.input`, `lurek.ui`, `lurek.render` |
| Level data | `lurek.filesystem`, `lurek.serialize`, `lurek.tilemap` for backdrop/collision |
| Effects and feedback | `lurek.audio`, `lurek.particle`, `lurek.tween` |
| Saves/progress | `lurek.save` for completed puzzles and best scores |

## Runtime architecture

Use edit mode and simulation mode. In edit mode, the player places or modifies puzzle objects under budget constraints. In simulation mode, the physics world runs and player edits may be disabled or limited. The solver state tracks whether the goal is satisfied for a required duration.

Objects should be data-driven: body type, shape, mass, friction, restitution, joints, break threshold, interaction tags, cost, and UI category. Goals are validators: reach zone, stay balanced, collect target, deliver resource, maintain bridge, or trigger sequence.

Do not save raw transient physics every frame. Save authored object placements, parameters, and seed. Rebuild the physics world when loading or restarting.

## Suggested project structure

```text
my_physics_puzzle/
  data/levels/*.toml
  data/objects.toml
  scripts/state/editor_state.lua
  scripts/systems/placement.lua
  scripts/systems/physics_runner.lua
  scripts/systems/goal_validators.lua
  scripts/ui/build_palette.lua
  scripts/ui/budget_panel.lua
  assets/objects/
```

## Vertical slice acceptance

The slice should include five levels, three placeable object types, joints or connectors, budget scoring, run/reset buttons, goal validation, best score save, and debug draw.

## Risks

The risk is non-repeatable solutions. Fix simulation timestep, keep object definitions stable, and make every level restart reconstruct physics from logical placement data.
