# visibility

## TL;DR

- The `visibility` module is a geometry-agnostic fog-of-war, discovery state, and line-of-sight system attachable to any region-based map (tilemap, province, globe, or custom grids).

## General Info

- Module group: `Edge/Integration`
- Source path: `src/visibility/`
- Lua API path(s): `src/lua_api/visibility_api.rs`
- Primary Lua namespace: `lurek.visibility`
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

The `visibility` module provides a universal fog-of-war and discovery layer that can be attached to any region-based map without coupling to a specific map module. The foundational abstraction is the `AdjacencyProvider` trait: callers implement a single `neighbors(region_id)` method to describe neighbor relationships. Grid maps inject 4- or 8-directional adjacency; province maps use their border index; custom systems supply arbitrary neighbor lists. This injection point is the only geometry dependency.

Per-region state is stored in the `VisibilityGrid`, a compact `(faction_id, region_id)` map tracking three built-in `VisibilityState` levels: `Hidden` (never seen), `Discovered` (seen at least once, currently out of range), and `Visible` (currently in sight range). Custom intermediate levels can be defined for richer game-state models. Multiple factions are supported simultaneously; the `PlayerOwnership` tracker groups allies so that shared-vision alliances propagate reveals automatically.

Discovery semantics are controlled per region via `VisibilityCost`: a movement-point cost gates reveal progression, and a required-flag mask (`VisibilityFlags`, a `u32` bitfield with 24 game-defined bits) can block reveal until the player possesses a specific capability. When regions transition between states, the grid queues `VisibilityEvent` entries (`RegionRevealed`, `RegionDiscovered`, `RegionHidden`) that are drained to Lua each tick — providing clean hooks for map-reveal animations, narrator cues, and scripted responses.

Rendering integration is handled via `FogRenderConfig`, which supplies per-state fog opacity values and RGBA tint colors composited as per-tile multiply in the world render pass. The full grid state serializes compactly (2 bits per region per faction) into the save file. The `lurek.visibility.*` Lua API exposes grid construction, reveal/hide calls, state queries, event draining, cost and flag mutation, faction grouping, and fog configuration.

## Files

### adjacency.rs

- Adjacency provider trait: defines the neighbor relationship between map regions.
- `AdjacencyProvider` trait has one method: `neighbors(region_id) -> Vec<RegionId>`.
- Grid-based maps implement it via 4-directional or 8-directional cell adjacency.
- Province maps implement it via the province border index for irregular shapes.
- Injected into the visibility grid at construction; swappable without engine changes.

### cost.rs

- Per-region discovery cost and adjacency requirements for visibility reveal logic.
- `VisibilityCost` stores a movement-point cost and required flag mask per region.
- Regions with `cost = 0` are revealed instantly when any neighbor becomes visible.
- Required flags can block reveal until the player has a specific capability.
- Costs are set from Lua via `lurek.visibility.set_cost(region_id, cost)`.

### events.rs

- Visibility state-change events emitted when regions transition between states.
- `VisibilityEvent` variants: `RegionRevealed`, `RegionDiscovered`, `RegionHidden`.
- Events are queued during the visibility update pass and drained to Lua each tick.
- `RegionRevealed` fires when a region moves from Hidden/Discovered to Visible.
- Used to trigger map-reveal animations, narration, and scripted events.

### flags.rs

- Per-region bitfield flags: terrain type, unit presence, buildings, and custom bits.
- `VisibilityFlags` is a `u32` bitfield; bits 0-7 are engine-reserved, 8-31 are game-defined.
- Flag constants are registered at game startup; names are mapped to bit positions.
- Used as required-flag masks in `VisibilityCost` to gate region reveal.
- Modified from Lua via `lurek.visibility.set_flags(region_id, flags)`.

### fog_render.rs

- Fog-of-war rendering configuration: intensity, colour, and render integration hints.
- `FogRenderConfig` controls fog opacity for `Hidden` and `Discovered` states.
- Fog is composited in the tilemap/world render pass as a per-tile colour multiply.
- `FogColor` is an RGBA value applied to hidden tiles; discovered tiles use a lighter shade.
- Config is hot-reloadable from `[visibility.fog]` TOML without a restart.

### grid.rs

- Visibility grid: per-region state storage for multiple simultaneous players/factions.
- `VisibilityGrid` maps `(faction_id, region_id) → VisibilityState`.
- Update pass: marks visible set, propagates discovery, reverts out-of-range to Discovered.
- Dirty tracking ensures only changed regions emit events and redraw fog tiles.
- Grid is serialised into the save file; full snapshot is compact (2 bits per region per faction).

### mod.rs

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

### owner.rs

- Player and faction ownership of shared visibility and discovery state.
- `OwnerMap` tracks which faction owns each region for fog-of-war sharing.
- Allied factions share visibility when `share_vision` is enabled per-alliance.
- `OwnerMap::visible_to(faction_id, region_id)` is the hot-path query.
- Ownership changes trigger re-evaluation of all visibility states for affected factions.

### shadowcast.rs

- Tile-grid line-of-sight using recursive shadowcasting (8-octant, Björn Bergström method).
- `TileFov` computes per-cell visibility on a flat tile grid.
- Visible cells accumulate into an `explored` mask that persists across frames.
- The blocker predicate is accepted at `compute` time — no internal cache.
- `save` / `restore` serialise both `visible` and `explored` as compact binary blobs.

### state.rs

- Visibility state enum: Hidden, Discovered, Visible, and custom extension levels.
- `VisibilityState` has three built-in variants and reserves bits for game-defined levels.
- `Hidden` = never seen; `Discovered` = seen but not currently in sight range; `Visible` = in range.
- Ordered by ascending information: `Hidden < Discovered < Visible`.
- Custom levels (e.g. `Remembered`) can be inserted between `Discovered` and `Visible`.

## Lua API Ref

- Binding: `src/lua_api/visibility_api.rs`
- Namespace: `lurek.visibility`

### Functions

- `lurek.visibility.new`: Create a new visibility grid for shadow-cast computation.
- `lurek.visibility.newFov`: Creates a new tile-grid shadowcasting FOV for roguelike and stealth games.

### Enums

- No documented module-level enums/constants.

### Types


#### LFov Type


##### Fields

- No documented fields.

##### Methods

- `LFov:compute`: Runs recursive shadowcasting from the observer position.
- `LFov:eachVisible`: Calls `fn(x, y)` for every currently visible cell (one-based coordinates).
- `LFov:export`: Serialises the visible and explored masks to a binary blob.
- `LFov:import`: Restores visible and explored masks from a blob produced by `export`.
- `LFov:isExplored`: Returns true if the cell has ever been visible.
- `LFov:isVisible`: Returns true if the cell is visible in the current frame.
- `LFov:resetExplored`: Clears the explored mask so all cells appear unexplored.
- `LFov:setBlocker`: Sets the Lua predicate that determines which cells are opaque.
- `LFov:setRange`: Changes the visibility radius for subsequent compute calls.
- `LFov:type`: Returns the Lua-visible type name for this FOV handle.
- `LFov:typeOf`: Returns whether this FOV handle matches the given type name.
- `LFov:visibleCells`: Returns an array of `{x, y}` tables for all currently visible cells (one-based).


#### LVisibilityGrid Type


##### Fields

- No documented fields.

##### Methods

- `LVisibilityGrid:drainEvents`: Drains and returns all pending visibility events.
- `LVisibilityGrid:getCost`: Gets the discovery cost for a region.
- `LVisibilityGrid:getFogIntensity`: Gets the fog intensity for a region from a player's perspective.
- `LVisibilityGrid:getState`: Gets the visibility state for a player at a region.
- `LVisibilityGrid:hasFlag`: Checks if a visibility flag bit is set on a region.
- `LVisibilityGrid:hide`: Hides a region for a player (moves from Visible to Discovered).
- `LVisibilityGrid:playerCount`: Returns the total number of players in the grid.
- `LVisibilityGrid:regionCount`: Returns the total number of regions in the grid.
- `LVisibilityGrid:reset`: Resets all visibility to Hidden for a player.
- `LVisibilityGrid:reveal`: Reveals a region for a player (and their allies). Optional flags argument.
- `LVisibilityGrid:revealAll`: Reveals all regions for a player (debug/cheat).
- `LVisibilityGrid:setCost`: Sets the discovery cost for a region.
- `LVisibilityGrid:setFlag`: Sets a visibility flag bit on a region.
- `LVisibilityGrid:setGroup`: Sets an alliance group for a list of players (shared visibility).
- `LVisibilityGrid:sharesVisibility`: Checks if two players share visibility (same alliance group or same player).

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.
