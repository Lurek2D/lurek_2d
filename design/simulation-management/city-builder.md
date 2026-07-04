# City Builder

**Category:** Simulation and management  
**Reference games:** SimCity 2000, Caesar III, Pharaoh, Islanders  
**Document type:** Technical game design and architecture

## Design target

A 2D city builder where the player zones or places structures, manages roads and services, balances population demand, and watches the city grow. The best Lurek2D version should focus on readable overlays, deterministic systems, and data-driven buildings.

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

## Vertical slice acceptance

The first slice should support road placement, residential/commercial/industrial zones, one service building, population growth, tax income, demand bars, pollution overlay, pause/speed control, and save/load.

## Risks

The risk is over-simulating citizens too early. Start with aggregate building simulation, then add visual agents as feedback. The player needs truthful overlays more than thousands of independent pawns.
