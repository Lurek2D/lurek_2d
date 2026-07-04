# City Builder

**Category:** Simulation and management  
**Reference games:** SimCity 2000, Caesar III, Pharaoh, Islanders  
**Document type:** Technical game design and architecture

## Design target

A 2D city builder where the player zones or places structures, manages roads and services, balances population demand, and watches the city grow. The best Lurek2D version should focus on readable overlays, deterministic systems, and data-driven buildings.

## Market positioning

Use the reference set (SimCity 2000, Caesar III, Pharaoh, Islanders) to define player expectations around pacing, readability, and production scope, not to copy mechanics directly. Target itch.io with one visible systemic loop that players can understand in minutes. Target Steam with inspectable simulation, speed controls, overlays, scenario goals, save stability, and enough data-driven depth to support long sessions. For city builder, the store page must communicate the core verb, session length, progression promise, and why the 2D presentation is intentional.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| City grid | `lurek.tilemap`, `lurek.tilefield`, `lurek.camera`, `lurek.minimap` |
| Buildings and agents | `lurek.ecs`, `lurek.pathfind` |
| Service coverage | `lurek.pathfind` influence maps, `lurek.charts` for metrics |
| Economy and demand | `lurek.dataframe`, `lurek.filesystem`, `lurek.serialize` |
| UI overlays | `lurek.ui`, `lurek.render`, `lurek.color` |
| Save/load | `lurek.save` sections for map, economy, historical metrics |

## Runtime architecture

Use zones, buildings, road graph, service graph, and economy as separate systems. The tile map stores terrain and occupancy. A city service system derives coverage from roads and providers: water, power, fire, health, education, desirability, pollution, and commute access.

Agents should be abstract at first. Instead of simulating every citizen, keep household and workplace counts inside building components and optionally spawn visible traffic sprites as visualization. This gives a city-builder feel without overwhelming the runtime.

Demand is calculated from population, jobs, land value, tax rate, service quality, and unlocked milestones. Buildings tick on slower intervals than rendering. Keep a metrics history so charts and advisors can explain trends.

## Suggested project structure

```text
my_city/
  data/buildings.toml
  data/zones.toml
  data/services.toml
  scripts/state/city.lua
  scripts/systems/zoning.lua
  scripts/systems/buildings.lua
  scripts/systems/roads.lua
  scripts/systems/services.lua
  scripts/systems/economy.lua
  scripts/ui/overlays.lua
  scripts/ui/advisors.lua
```

## Data and content model

- Author map cells, resources, buildings, jobs, agents, production rules, and scenario goals as data, not hidden script constants.
- Author derived overlays, reservations, alerts, history logs, budgets, and simulation tick snapshots as data, not hidden script constants.
- Author balancing tables, tutorial milestones, save migrations, and debug inspection state as data, not hidden script constants.
- Keep city builder content split between durable authored files under `data/`, media under `assets/`, and orchestration modules under `scripts/`.
- Save files should store player/world progress and stable identifiers, not transient render objects, cached paths, or UI widget instances.


## Technical design notes

- Use a fixed simulation tick owned by a domain scheduler; rendering and UI should read prepared snapshots.
- Use `lurek.tilefield`, `lurek.pathfind`, and `lurek.ai` for map facts, routing, job selection, and inspectable agent decisions.
- Use `lurek.dataframe`, `lurek.serialize`, and `lurek.filesystem` for large balancing tables and scenario data.
- Use `lurek.save` with explicit sections and versioning because long-running saves are central to the product.

## Vertical slice acceptance

The first slice should support road placement, residential/commercial/industrial zones, one service building, population growth, tax income, demand bars, pollution overlay, pause/speed control, and save/load.

## Risks

The risk is over-simulating citizens too early. Start with aggregate building simulation, then add visual agents as feedback. The player needs truthful overlays more than thousands of independent pawns.
