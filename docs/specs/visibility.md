# visibility

## TL;DR



## General Info

- Module group: `Edge/Integration`
- Source path: `src/visibility/`
- Lua API path(s): `src/lua_api/visibility_api.rs`
- Primary Lua namespace: `lurek.visibility`
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

Universal visibility system for fog-of-war, discovery, and line-of-sight. Provides a generic, geometry-agnostic visibility layer that can be attached to any region-based system (tilemap, province map, globe, custom grids). Part of the Platform Services tier — no dependencies on globe, province, or tilemap modules.

This module is mostly self-contained inside the Edge/Integration group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Source Documentation

### `adjacency.rs`
- Adjacency provider trait: defines the neighbor relationship between map regions.
- `AdjacencyProvider` trait has one method: `neighbors(region_id) -> Vec<RegionId>`.
- Grid-based maps implement it via 4-directional or 8-directional cell adjacency.
- Province maps implement it via the province border index for irregular shapes.
- Injected into the visibility grid at construction; swappable without engine changes.

### `cost.rs`
- Per-region discovery cost and adjacency requirements for visibility reveal logic.
- `VisibilityCost` stores a movement-point cost and required flag mask per region.
- Regions with `cost = 0` are revealed instantly when any neighbor becomes visible.
- Required flags can block reveal until the player has a specific capability.
- Costs are set from Lua via `lurek.visibility.set_cost(region_id, cost)`.

### `events.rs`
- Visibility state-change events emitted when regions transition between states.
- `VisibilityEvent` variants: `RegionRevealed`, `RegionDiscovered`, `RegionHidden`.
- Events are queued during the visibility update pass and drained to Lua each tick.
- `RegionRevealed` fires when a region moves from Hidden/Discovered to Visible.
- Used to trigger map-reveal animations, narration, and scripted events.

### `flags.rs`
- Per-region bitfield flags: terrain type, unit presence, buildings, and custom bits.
- `VisibilityFlags` is a `u32` bitfield; bits 0-7 are engine-reserved, 8-31 are game-defined.
- Flag constants are registered at game startup; names are mapped to bit positions.
- Used as required-flag masks in `VisibilityCost` to gate region reveal.
- Modified from Lua via `lurek.visibility.set_flags(region_id, flags)`.

### `fog_render.rs`
- Fog-of-war rendering configuration: intensity, colour, and render integration hints.
- `FogRenderConfig` controls fog opacity for `Hidden` and `Discovered` states.
- Fog is composited in the tilemap/world render pass as a per-tile colour multiply.
- `FogColor` is an RGBA value applied to hidden tiles; discovered tiles use a lighter shade.
- Config is hot-reloadable from `[visibility.fog]` TOML without a restart.

### `grid.rs`
- Visibility grid: per-region state storage for multiple simultaneous players/factions.
- `VisibilityGrid` maps `(faction_id, region_id) → VisibilityState`.
- Update pass: marks visible set, propagates discovery, reverts out-of-range to Discovered.
- Dirty tracking ensures only changed regions emit events and redraw fog tiles.
- Grid is serialised into the save file; full snapshot is compact (2 bits per region per faction).

### `mod.rs`
- Universal visibility system for fog-of-war, discovery, and line-of-sight.
- This module provides a generic visibility layer that can be attached to any
- region-based system (tilemap, province map, globe, custom). The module is
- agnostic to geometry — it receives region counts and adjacency lists.
- # Architecture
- `VisibilityGrid` — per-region visibility state for multiple players
- `VisibilityState` — enum: Hidden, Discovered, Visible (+ custom u8 levels)
- `PlayerOwnership` — which players/groups share visibility
- `VisibilityFlags` — bitfield per region (terrain, units, buildings, etc.)
- `DiscoveryCost` — per-region cost to reveal, adjacency requirements
- `FogConfig` — fog intensity and rendering hints

### `owner.rs`
- Player and faction ownership of shared visibility and discovery state.
- `OwnerMap` tracks which faction owns each region for fog-of-war sharing.
- Allied factions share visibility when `share_vision` is enabled per-alliance.
- `OwnerMap::visible_to(faction_id, region_id)` is the hot-path query.
- Ownership changes trigger re-evaluation of all visibility states for affected factions.

### `state.rs`
- Visibility state enum: Hidden, Discovered, Visible, and custom extension levels.
- `VisibilityState` has three built-in variants and reserves bits for game-defined levels.
- `Hidden` = never seen; `Discovered` = seen but not currently in sight range; `Visible` = in range.
- Ordered by ascending information: `Hidden < Discovered < Visible`.
- Custom levels (e.g. `Remembered`) can be inserted between `Discovered` and `Visible`.

## Types

- `AdjacencyProvider` (`trait`, `adjacency.rs`): trait
- `SimpleAdjacency` (`struct`, `adjacency.rs`): struct
- `DiscoveryCost` (`struct`, `cost.rs`): struct
- `VisibilityEvent` (`enum`, `events.rs`): enum
- `VisibilityFlags` (`struct`, `flags.rs`): struct
- `FogConfig` (`struct`, `fog_render.rs`): struct
- `VisibilityGrid` (`struct`, `grid.rs`): struct
- `PlayerOwnership` (`struct`, `owner.rs`): struct
- `VisibilityState` (`enum`, `state.rs`): enum

## Functions

- `SimpleAdjacency::new` (`adjacency.rs`): Create a `SimpleAdjacency` with the given number of regions and empty neighbor lists.
- `SimpleAdjacency::add_neighbor` (`adjacency.rs`): Add `neighbor_id` as a one-way neighbor of `region_id` (does not add the reverse).
- `SimpleAdjacency::add_bidirectional` (`adjacency.rs`): Add a bidirectional neighbor link between regions `a` and `b`.
- `VisibilityFlags::new` (`flags.rs`): Create a new `VisibilityFlags` with no flags set.
- `VisibilityFlags::set` (`flags.rs`): Set or clear the flag at bit position `bit` (0–63).
- `VisibilityFlags::has` (`flags.rs`): Return `true` if the flag at bit position `bit` is set.
- `VisibilityFlags::union` (`flags.rs`): Return the bitwise OR of two flag sets.
- `VisibilityFlags::intersect` (`flags.rs`): Return the bitwise AND of two flag sets.
- `VisibilityFlags::count` (`flags.rs`): Return the number of flags currently set (popcount).
- `VisibilityGrid::new` (`grid.rs`): Create a new grid for the given number of regions and players, with all cells hidden.
- `VisibilityGrid::reveal` (`grid.rs`): Reveal a region for a player (and their allies).
- `VisibilityGrid::hide` (`grid.rs`): Hide a region for a player (move to Discovered if it was Visible).
- `VisibilityGrid::get_state` (`grid.rs`): Get visibility state for a player at a region.
- `VisibilityGrid::get_fog_intensity` (`grid.rs`): Get fog intensity for a region from a player's perspective.
- `VisibilityGrid::set_cost` (`grid.rs`): Set the discovery cost for a region.
- `VisibilityGrid::get_cost` (`grid.rs`): Get discovery cost for a region.
- `VisibilityGrid::get_flags` (`grid.rs`): Get visibility flags for a region.
- `VisibilityGrid::set_flags` (`grid.rs`): Set visibility flags for a region.
- `VisibilityGrid::set_group` (`grid.rs`): Set group for players (shared visibility).
- `VisibilityGrid::shares_visibility` (`grid.rs`): Check if two players share visibility.
- `VisibilityGrid::drain_events` (`grid.rs`): Drain and return all pending visibility events.
- `VisibilityGrid::set_fog_config` (`grid.rs`): Set the fog of war configuration.
- `VisibilityGrid::region_count` (`grid.rs`): Get the total number of regions tracked.
- `VisibilityGrid::player_count` (`grid.rs`): Get the total number of tracked players.
- `VisibilityGrid::reveal_all` (`grid.rs`): Reveal all regions for a player (debug/cheat).
- `VisibilityGrid::reset` (`grid.rs`): Reset all visibility to Hidden for a player.
- `PlayerOwnership::new` (`owner.rs`): Create a new `PlayerOwnership` tracking the given number of players, all ungrouped.
- `PlayerOwnership::set_group` (`owner.rs`): Assign multiple players to a shared visibility group.
- `PlayerOwnership::remove_from_group` (`owner.rs`): Remove a player from their group (becomes independent).
- `PlayerOwnership::allies_of` (`owner.rs`): Get all players that share visibility with a given player.
- `PlayerOwnership::shares_visibility` (`owner.rs`): Check if two players share visibility.
- `PlayerOwnership::player_count` (`owner.rs`): Return the total number of players managed by this ownership tracker.
- `VisibilityState::level` (`state.rs`): Returns the numeric level (Hidden=0, Discovered=1, Visible=2, Custom=3+).
- `VisibilityState::from_level` (`state.rs`): Create a state from a numeric level value.
- `VisibilityState::is_known` (`state.rs`): Whether the region has been seen at least once.
- `VisibilityState::is_visible` (`state.rs`): Whether the region is currently fully visible.

## Lua API Reference

- Binding path(s): `src/lua_api/visibility_api.rs`
- Namespace: `lurek.visibility`

### Module Functions
- `lurek.visibility.new`: Create a new visibility grid for shadow-cast computation.

### `LVisibilityGrid` Methods
- `LVisibilityGrid:reveal`: Reveals a region for a player (and their allies). Optional flags argument.
- `LVisibilityGrid:hide`: Hides a region for a player (moves from Visible to Discovered).
- `LVisibilityGrid:getState`: Gets the visibility state for a player at a region.
- `LVisibilityGrid:getFogIntensity`: Gets the fog intensity for a region from a player's perspective.
- `LVisibilityGrid:setCost`: Sets the discovery cost for a region.
- `LVisibilityGrid:getCost`: Gets the discovery cost for a region.
- `LVisibilityGrid:setFlag`: Sets a visibility flag bit on a region.
- `LVisibilityGrid:hasFlag`: Checks if a visibility flag bit is set on a region.
- `LVisibilityGrid:setGroup`: Sets an alliance group for a list of players (shared visibility).
- `LVisibilityGrid:sharesVisibility`: Checks if two players share visibility (same alliance group or same player).
- `LVisibilityGrid:revealAll`: Reveals all regions for a player (debug/cheat).
- `LVisibilityGrid:reset`: Resets all visibility to Hidden for a player.
- `LVisibilityGrid:drainEvents`: Drains and returns all pending visibility events.
- `LVisibilityGrid:regionCount`: Returns the total number of regions in the grid.
- `LVisibilityGrid:playerCount`: Returns the total number of players in the grid.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- The module is pure data — no GPU resources. Rendering fog visuals is the responsibility of the consumer (render module, tilemap, province map).
- Alliance groups are additive: calling `setGroup` creates a new group. Players can only belong to one group at a time.
- Events accumulate until `drainEvents()` is called. The consumer should drain events each frame.
- Custom visibility levels (3+) allow games to define arbitrary granularity beyond the standard three states.
