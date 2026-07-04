# Colony Sim

**Category:** Simulation and management  
**Reference games:** RimWorld, Dwarf Fortress Classic, Oxygen Not Included, Prison Architect  
**Document type:** Technical game design and architecture

## Design target

A colony simulation where autonomous pawns satisfy needs, perform jobs, build structures, consume resources, react to events, and create emergent stories. The product should prioritize systemic readability and inspectable AI over visual complexity.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Colony map | `lurek.tilemap`, `lurek.tilefield`, `lurek.camera` |
| Pawns and objects | `lurek.ecs` with components for needs, job, inventory, mood, health |
| Job assignment | `lurek.ai` utility scoring, blackboards, GOAP/HTN-style planning |
| Navigation | `lurek.pathfind` grids, async paths, influence maps |
| Events and alerts | `lurek.signal`, `lurek.ui`, `lurek.audio` |
| Simulation data | `lurek.filesystem`, `lurek.serialize`, `lurek.dataframe` |
| Persistence | `lurek.save` schema sections for map, pawns, stockpiles, history |

## Runtime architecture

Use a central job board. Work providers scan the world and post jobs: haul, build, cook, sleep, treat wound, repair, mine, clean, flee, fight. Pawns do not directly search the whole world every frame. They evaluate available jobs based on priorities, reachability, skill, need urgency, danger, and reservation status.

The map should distinguish terrain, buildings, stockpiles, rooms, temperature tags, ownership, forbidden cells, and path costs. Resources should be stack entities with material, count, spoilage, reservation, and storage policy. Rooms are derived regions recalculated when walls or doors change.

AI is the heart of the design. Each pawn owns needs, traits, skills, memories, mood, current job, and interrupt policy. Use Lurek2D debug overlays to show selected job, path, need urgency, and reservation conflicts.

## Suggested project structure

```text
my_colony/
  data/rules/jobs.toml
  data/rules/buildings.toml
  data/rules/needs.toml
  data/events/incidents.toml
  scripts/state/colony.lua
  scripts/systems/job_board.lua
  scripts/systems/reservations.lua
  scripts/systems/needs.lua
  scripts/systems/rooms.lua
  scripts/ai/pawn_ai.lua
  scripts/ui/inspector.lua
```

## Vertical slice acceptance

One map should support five pawns, sleep/eat/work needs, construction blueprints, hauling, stockpiles, one hostile incident, job priority UI, pause/speed control, and save/load.

## Risks

The largest risk is simulation churn. Put hard budgets on scans, cache derived regions, and avoid per-pawn global searches. Emergence should come from small explicit systems, not unbounded scripts.
