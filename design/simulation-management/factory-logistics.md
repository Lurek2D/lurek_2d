# Factory Logistics

**Category:** Simulation and management  
**Reference games:** Factorio, Shapez, Opus Magnum, Mini Motorways  
**Document type:** Technical game design and architecture

## Design target

A 2D factory/logistics game where machines transform resources, conveyors or carriers move items, bottlenecks emerge, and the player optimizes throughput. The design should make flow visible and measurable.

## Market positioning

Use the reference set (Factorio, Shapez, Opus Magnum, Mini Motorways) to define player expectations around pacing, readability, and production scope, not to copy mechanics directly. Target itch.io with one visible systemic loop that players can understand in minutes. Target Steam with inspectable simulation, speed controls, overlays, scenario goals, save stability, and enough data-driven depth to support long sessions. For factory logistics, the store page must communicate the core verb, session length, progression promise, and why the 2D presentation is intentional.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Grid placement | `lurek.tilemap`, `lurek.tilefield`, `lurek.input` |
| Machines and items | `lurek.ecs` components for machine state, ports, inventories, recipes |
| Transport networks | `lurek.pathfind`, `lurek.flownet`, `lurek.math` |
| Data tables | `lurek.dataframe`, `lurek.filesystem`, `lurek.serialize` |
| Visualization | `lurek.render`, `lurek.particle`, `lurek.charts`, `lurek.ui` |
| Persistence | `lurek.save` with factory graph and versioned recipe data |

## Runtime architecture

Model the factory as a directed graph over placed entities. Machines have input ports, output ports, buffers, recipe timers, power demand, and connection references. Transport segments are not just art; each segment has capacity, direction, lane rules, and throughput counters.

Use fixed simulation ticks for production and transport. Rendering can interpolate item positions between logical nodes, but the authoritative item state should live in buffers, carriers, or belt slots. This keeps saves small and avoids pixel-perfect state corruption.

Data-driven recipes are essential: inputs, outputs, duration, byproducts, power, category, unlock requirement, and UI icon. A statistics subsystem should aggregate items per minute, machine idle reasons, power deficit, and blocked outputs.

## Suggested project structure

```text
my_factory/
  data/recipes.toml
  data/machines.toml
  data/items.toml
  scripts/state/factory.lua
  scripts/systems/placement.lua
  scripts/systems/transport_graph.lua
  scripts/systems/production.lua
  scripts/systems/power.lua
  scripts/ui/build_menu.lua
  scripts/ui/throughput_charts.lua
  assets/machines/
  assets/items/
```

## Data and content model

- Author map cells, resources, buildings, jobs, agents, production rules, and scenario goals as data, not hidden script constants.
- Author derived overlays, reservations, alerts, history logs, budgets, and simulation tick snapshots as data, not hidden script constants.
- Author balancing tables, tutorial milestones, save migrations, and debug inspection state as data, not hidden script constants.
- Keep factory logistics content split between durable authored files under `data/`, media under `assets/`, and orchestration modules under `scripts/`.
- Save files should store player/world progress and stable identifiers, not transient render objects, cached paths, or UI widget instances.


## Technical design notes

- Use a fixed simulation tick owned by a domain scheduler; rendering and UI should read prepared snapshots.
- Use `lurek.tilefield`, `lurek.pathfind`, and `lurek.ai` for map facts, routing, job selection, and inspectable agent decisions.
- Use `lurek.dataframe`, `lurek.serialize`, and `lurek.filesystem` for large balancing tables and scenario data.
- Use `lurek.save` with explicit sections and versioning because long-running saves are central to the product.

## Vertical slice acceptance

Build one resource source, one belt type, three machines, four items, one research unlock, live throughput chart, blocked-output warning, blueprint placement, delete tool, and save/load.

## Risks

The main risk is representing every moving item as an expensive actor. Keep logical flow compact and reserve ECS entities for machines, carriers, and visible exceptions. Render many item sprites from transport buffers rather than simulating them as independent agents.
