# Physics Logic Puzzle

**Category:** Puzzle games  
**Reference games:** World of Goo, The Incredible Machine, Crayon Physics Deluxe, Poly Bridge  
**Document type:** Technical game design and architecture

## Design target

A 2D physics puzzle where players place, connect, cut, trigger, or tune objects to satisfy a goal. The challenge is building systems that behave consistently enough to be solved, while still feeling physical.

## Market positioning

Use the reference set (World of Goo, The Incredible Machine, Crayon Physics Deluxe, Poly Bridge) to define player expectations around pacing, readability, and production scope, not to copy mechanics directly. Target itch.io with a clean rule twist, immediate readability, and hand-authored levels. Target Steam with a level progression curve, hints/undo, editor-style validation tools, and content packs that scale without adding systemic ambiguity. For physics logic puzzle, the store page must communicate the core verb, session length, progression promise, and why the 2D presentation is intentional.

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

## Data and content model

- Author level layouts, rule entities, goals, blockers, movable objects, and authored hints as data, not hidden script constants.
- Author undo stack, move counters, validation flags, completion stars, and level-pack progression as data, not hidden script constants.
- Author editor metadata, solution traces, tutorial messages, and accessibility settings as data, not hidden script constants.
- Keep physics logic puzzle content split between durable authored files under `data/`, media under `assets/`, and orchestration modules under `scripts/`.
- Save files should store player/world progress and stable identifiers, not transient render objects, cached paths, or UI widget instances.


## Technical design notes

- Use `lurek.scene` to separate level select, puzzle play, pause, and result screens.
- Keep puzzle state deterministic and serializable so undo, reset, hints, and validation can share the same state snapshots.
- Use `lurek.tilefield` for cell facts and `lurek.ui` for move counters, hint controls, level goals, and accessibility toggles.
- Use `lurek.save` for solved levels, stars, hints used, and level-pack progress.

## Vertical slice acceptance

The slice should include five levels, three placeable object types, joints or connectors, budget scoring, run/reset buttons, goal validation, best score save, and debug draw.

## Risks

The risk is non-repeatable solutions. Fix simulation timestep, keep object definitions stable, and make every level restart reconstruct physics from logical placement data.
