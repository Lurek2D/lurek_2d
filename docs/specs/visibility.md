# visibility

## Summary

Universal visibility system for fog-of-war, discovery, and line-of-sight. Provides a generic, geometry-agnostic visibility layer that can be attached to any region-based system (tilemap, province map, globe, custom grids). Part of the Platform Services tier — no dependencies on globe, province, or tilemap modules.

## General Info

| Property       | Value                       |
| -------------- | --------------------------- |
| Source path    | `src/visibility/`           |
| Lua namespace  | `lurek.visibility`          |
| Tier           | Platform Services           |
| Plugin tier    | `CORE-KEEP`                 |
| Dependencies   | None (leaf module)          |
| Consumed by    | province, globe, minimap, tilemap |

## Files

| File            | Purpose                                                      |
| --------------- | ------------------------------------------------------------ |
| `mod.rs`        | Module root: public exports and sub-module declarations.     |
| `state.rs`      | `VisibilityState` enum: Hidden, Discovered, Visible, Custom. |
| `flags.rs`      | `VisibilityFlags` — 64-bit bitfield for per-region flags.    |
| `owner.rs`      | `PlayerOwnership` — alliance groups for shared visibility.   |
| `grid.rs`       | `VisibilityGrid` — main per-region, per-player storage.      |
| `cost.rs`       | `DiscoveryCost` — per-region discovery cost configuration.   |
| `adjacency.rs`  | `AdjacencyProvider` trait and `SimpleAdjacency` implementation. |
| `fog_render.rs` | `FogConfig` — fog rendering configuration (intensity, transitions). |
| `events.rs`     | `VisibilityEvent` enum for state-change notifications.       |

## Types

| Type                | Kind   | Description                                                |
| ------------------- | ------ | ---------------------------------------------------------- |
| `VisibilityState`   | enum   | Hidden / Discovered / Visible / Custom(u8).                |
| `VisibilityFlags`   | struct | 64-bit bitfield with set/has/union/intersect operations.   |
| `PlayerOwnership`   | struct | Alliance group manager (shared visibility between players). |
| `VisibilityGrid`    | struct | Main grid: per-player per-region states, flags, costs, events. |
| `DiscoveryCost`     | struct | Per-region discovery cost and adjacency requirements.      |
| `AdjacencyProvider` | trait  | Neighbor lookup for arbitrary region topologies.           |
| `SimpleAdjacency`   | struct | Vec-based adjacency list implementing `AdjacencyProvider`. |
| `FogConfig`         | struct | Fog intensity and transition configuration.                |
| `VisibilityEvent`   | enum   | Revealed / Hidden / Forgotten / GroupChanged events.       |

## Lua API Reference

### Constructor

| Function                        | Returns             | Description                              |
| ------------------------------- | ------------------- | ---------------------------------------- |
| `lurek.visibility.new(config)`  | `LVisibilityGrid`   | Create a new visibility grid from config table. |

Config table fields:
- `regions` (integer) — number of regions
- `players` (integer) — number of players
- `fog` (table, optional) — `{ discovered = 0.5, hidden = 1.0, smooth = true, speed = 0.5 }`

### Methods on LVisibilityGrid

| Method                                    | Returns    | Description                                          |
| ----------------------------------------- | ---------- | ---------------------------------------------------- |
| `:reveal(player_id, region_id, flags?)`   | —          | Reveal region for player and allies.                 |
| `:hide(player_id, region_id)`             | —          | Hide region (Visible → Discovered) for player/allies.|
| `:getState(player_id, region_id)`         | string     | "hidden", "discovered", "visible", or custom number. |
| `:getFogIntensity(player_id, region_id)`  | number     | Fog intensity 0.0–1.0.                               |
| `:setCost(region_id, cost)`               | —          | Set discovery cost for a region.                     |
| `:getCost(region_id)`                     | number     | Get discovery cost.                                  |
| `:setFlag(region_id, bit, value)`         | —          | Set a visibility flag bit.                           |
| `:hasFlag(region_id, bit)`                | boolean    | Check if a flag bit is set.                          |
| `:setGroup(players_table)`                | integer    | Set alliance group for listed players.               |
| `:sharesVisibility(player_a, player_b)`   | boolean    | Check if two players share visibility.               |
| `:revealAll(player_id)`                   | —          | Reveal all regions for a player (debug).             |
| `:reset(player_id)`                       | —          | Reset all visibility to Hidden.                      |
| `:drainEvents()`                          | table      | Drain pending events as array of tables.             |
| `:regionCount()`                          | integer    | Total region count.                                  |
| `:playerCount()`                          | integer    | Total player count.                                  |

### Event Table Format

Each event table from `:drainEvents()`:
- `type` — "revealed", "hidden", "forgotten", or "group_changed"
- `player_id` — affected player
- `region_id` — affected region (for revealed/hidden/forgotten)
- `group_id` — new group (for group_changed)

## Notes

- The module is pure data — no GPU resources. Rendering fog visuals is the responsibility of the consumer (render module, tilemap, province map).
- Alliance groups are additive: calling `setGroup` creates a new group. Players can only belong to one group at a time.
- Events accumulate until `drainEvents()` is called. The consumer should drain events each frame.
- Custom visibility levels (3+) allow games to define arbitrary granularity beyond the standard three states.

## References

- [docs/architecture/engine-architecture.md](../architecture/engine-architecture.md) — tier placement
- [content/examples/visibility.lua](../../content/examples/visibility.lua) — usage example
- [tests/lua/unit/test_visibility_core_unit.lua](../../tests/lua/unit/test_visibility_core_unit.lua) — unit tests
