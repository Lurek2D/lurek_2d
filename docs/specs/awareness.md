<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/awareness.md or source docstrings instead. -->

# awareness

## TL;DR

- Player-specific fog-of-war, remembered exploration, line-of-sight, and action-mask simulation.

## General Info

- Module group: `Platform Services`
- Source path: `src/awareness`
- Binding: `src/lua_api/awareness_api.rs`
- Namespace: `lurek.awareness`
- Lua API surface: `5` functions, `3` types, `45` methods
- User-facing: `true`
- Plugin tier: `core_keep`

## Summary

- The `awareness` module is the shared answer to fog-of-war, line-of-sight, action reachability, and remembered exploration for users building map-aware gameplay.
- It combines adjacency rules, reveal cost, ownership flags, events, shadowcasting, and stored state so the same module can answer both gameplay questions and presentation needs.
- That makes it more than a single visibility check: current sight, remembered discovery, reveal transitions, and display-friendly output are meant to behave as one coherent information system.
- Team-specific reveal state and remembered exploration are especially important because many map-aware games care not only about what is visible now, but also about what was discovered earlier and by whom.
- That unified state is what lets fog-of-war, scouting, and map presentation stay aligned.
- It also keeps team knowledge explicit.
- Read this module as the authority for what an actor currently knows about a space.

This module is mostly self-contained inside the `Edge/Integration` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Ownership

- Canonical source: `src/awareness`
- Owning tier: `Platform Services`
- Plugin tier: `core_keep`
- Lua binding owner: `src/lua_api/awareness_api.rs`
- Referenced engine modules: `tilefield`

## Imports

- `tilefield`: Imports or references `src/tilefield/`. Cross-group dependency from `Platform Services` into `Feature Systems`.

## Source Files

### adjacency.rs

- This file owns adjacency contracts for visibility systems that need region-neighbor lookup without grid coupling.
- It defines `AdjacencyProvider` plus `SimpleAdjacency`, a small adjacency-list implementation for graph-like maps.
- Visibility and discovery code can query neighbors through this boundary without knowing how worlds store topology.
- Open this file when neighborhood semantics change; visibility state and fog progression live in sibling modules.

### cost.rs

- This file owns `DiscoveryCost`, the per-region metadata that controls how expensive or gated revelation should be.
- It stores a base reveal cost plus adjacency requirements so progression systems can tune map exploration pressure.
- Open this file when discovery gating changes; live visibility state and ownership sharing remain in sibling files.

### events.rs

- This file owns `AwarenessEvent`, the event payload emitted when regions are revealed, hidden, forgotten, or regrouped.
- It gives callers stable event variants for reacting to state changes without inspecting grid internals directly.
- Open this file when visibility notifications change; stored state and ownership logic live in sibling modules.

### flags.rs

- This file owns `AwarenessFlags`, the per-region bitfield used to mark which information layers are currently revealed.
- It supports custom terrain, unit, building, or game-specific reveal channels through a compact `u64` wrapper.
- Helpers set, test, merge, intersect, and count bits so reveal systems can evolve information without new enums.
- Open this file when reveal-flag semantics change; grid storage and fog state live in sibling modules.

### fog_render.rs

- This file owns `FogConfig`, the render-facing fog settings that translate visibility state into screen intensity.
- It stores discovered and hidden opacity plus transition controls so presentation can follow one visibility policy.
- Open this file when fog presentation rules change; state transitions and region ownership live in sibling files.

### grid.rs

- This file owns `AwarenessGrid`, the main per-player region store for hidden, discovered, visible, and flagged data.
- It tracks fog intensity, reveal costs, ownership sharing, and pending `AwarenessEvent` output in one state holder.
- Reveal and hide operations propagate through allied players, update fog and flags, and record transition events.
- Utility methods expose per-region state, costs, flags, player groups, global reveal, reset, and fog configuration.
- Open this file when multi-player visibility behavior changes; topology contracts and tile FOV live in siblings.

### mod.rs

- This module re-exports the visibility subsystem surface for grids, FOV, ownership, fog rules, and events.
- It serves as the navigation map for region-state storage, adjacency contracts, reveal costs, and shadowcasting.
- `grid.rs` owns shared per-player region state, while `shadowcast.rs` covers tile-based field-of-view computation.
- `owner.rs`, `events.rs`, and `state.rs` define shared-vision groups, emitted transitions, and visibility levels.
- `flags.rs`, `cost.rs`, `adjacency.rs`, and `fog_render.rs` describe reveal metadata and presentation inputs.
- Change this file when the public visibility symbol map moves; change siblings when runtime behavior changes.

### owner.rs

- This file owns `PlayerOwnership`, the shared-vision layer that decides which players inherit each other's sight.
- It stores player-to-group assignments and answers ally lookups so reveal propagation stays centralized and consistent.
- Group helpers add shared-visibility teams, remove members, and answer hot-path visibility-sharing checks by player id.
- Open this file when alliance semantics change; region state storage and transition events live in sibling files.

### shadowcast.rs

- This file owns `TileFov`, the tile-grid field-of-view runtime that computes current sight and remembered exploration.
- It stores dimensions, range, wall-lighting policy, and per-cell visible or explored masks for one observer context.
- `compute` runs deterministic recursive shadowcasting across eight octants using a caller-supplied blocker predicate.
- Helpers expose width, height, range, visible cells, explored state, and callback iteration over current sight.
- Save and restore logic serializes packed visibility masks so field-of-view memory can survive persistence boundaries.
- Internal bit-pack helpers keep the blob compact, while private casting code isolates slope math from public APIs.
- Open this file when tile FOV behavior changes; shared region-state visibility logic lives in sibling modules.

### state.rs

- This file owns `AwarenessState`, the ordered knowledge enum used to describe what one player knows about one region.
- It encodes hidden, discovered, visible, and custom levels so reveal logic and fog rendering share one progression model.
- Open this file when knowledge-level semantics change; event emission and grid storage live in sibling modules.

### tile_awareness.rs

- This file owns tile awareness behavior inside the awareness subsystem, close to its data and invariants.
- It keeps validation, defaults, and error-facing rules near the operations that mutate tile awareness state.
- Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.
- Public functions in this file are the stable entry points other modules should use for tile awareness work.
- Serialization, indexing, and boundary checks stay here when they depend on tile awareness internals.
- Renderer, API, and test layers should call through these helpers rather than duplicate private rules.
- Open this file when tile awareness ownership changes, but keep unrelated subsystem policy in sibling modules.
- The code favors small data transformations so examples, specs, and tests can assert behavior directly.
- Stateful changes are kept deterministic here so generated docs and smoke tests remain reproducible.



## Lua API Ref

### Functions

- `lurek.awareness.lineOfAction(field, from, to, opts?) -> boolean`: Returns whether two tilefield cells have a clear action line.
- `lurek.awareness.lineOfSight(field, from, to, opts?) -> boolean`: Returns whether two tilefield cells have a clear sight line.
- `lurek.awareness.new(config) -> LAwarenessGrid`: Create a new visibility grid for shadow-cast computation.
- `lurek.awareness.newFov(opts) -> LFov`: Creates a new tile-grid shadowcasting FOV for roguelike and stealth games.
- `lurek.awareness.newTileAwareness(field, opts) -> LTileAwareness`: Creates per-player tile visibility/action masks backed by a tilefield.

### Callbacks

- `LFov:eachVisible` param `fn` (`function`): Callback receiving column and row integers.
- `LFov:setBlocker` param `fn` (`function`): `fn(x: integer, y: integer) -> boolean` (one-based).

### Enums

- No documented module-level enums/constants.

### Types

#### LAwarenessGrid Type

- Lua-side wrapper for a visibility grid instance.

##### Fields

- No documented fields.

##### Methods

- `LAwarenessGrid:drainEvents() -> table`: Drains and returns all pending visibility events.
- `LAwarenessGrid:getCost(region_id) -> number`: Gets the discovery cost for a region.
- `LAwarenessGrid:getFogIntensity(player_id, region_id) -> number`: Gets the fog intensity for a region from a player's perspective.
- `LAwarenessGrid:getState(player_id, region_id) -> string`: Gets the visibility state for a player at a region.
- `LAwarenessGrid:hasFlag(region_id, bit) -> boolean`: Checks if a visibility flag bit is set on a region.
- `LAwarenessGrid:hide(player_id, region_id) -> nil`: Hides a region for a player (moves from Visible to Discovered).
- `LAwarenessGrid:playerCount() -> integer`: Returns the total number of players in the grid.
- `LAwarenessGrid:regionCount() -> integer`: Returns the total number of regions in the grid.
- `LAwarenessGrid:reset(player_id) -> nil`: Resets all visibility to Hidden for a player.
- `LAwarenessGrid:reveal(player_id, region_id, flags?) -> nil`: Reveals a region for a player (and their allies). Optional flags argument.
- `LAwarenessGrid:revealAll(player_id) -> nil`: Reveals all regions for a player (debug/cheat).
- `LAwarenessGrid:setCost(region_id, cost) -> nil`: Sets the discovery cost for a region.
- `LAwarenessGrid:setFlag(region_id, bit, value) -> nil`: Sets a visibility flag bit on a region.
- `LAwarenessGrid:setGroup(players) -> integer`: Sets an alliance group for a list of players (shared visibility).
- `LAwarenessGrid:sharesVisibility(player_a, player_b) -> boolean`: Checks if two players share visibility (same alliance group or same player).

#### LFov Type

- Lua-side wrapper for a tile-grid recursive-shadowcasting FOV.

##### Fields

- No documented fields.

##### Methods

- `LFov:compute(ox, oy) -> nil`: Runs recursive shadowcasting from the observer position.
- `LFov:eachVisible(fn) -> nil`: Calls `fn(x, y)` for every currently visible cell (one-based coordinates).
- `LFov:export() -> string`: Serialises the visible and explored masks to a binary blob.
- `LFov:import(blob) -> nil`: Restores visible and explored masks from a blob produced by `export`.
- `LFov:isExplored(x, y) -> boolean`: Returns true if the cell has ever been visible.
- `LFov:isVisible(x, y) -> boolean`: Returns true if the cell is visible in the current frame.
- `LFov:resetExplored() -> nil`: Clears the explored mask so all cells appear unexplored.
- `LFov:setBlocker(fn) -> nil`: Sets the Lua predicate that determines which cells are opaque.
- `LFov:setRange(range) -> nil`: Changes the visibility radius for subsequent compute calls.
- `LFov:type() -> string`: Returns the Lua-visible type name for this FOV handle.
- `LFov:typeOf(name) -> boolean`: Returns whether this FOV handle matches the given type name.
- `LFov:visibleCells() -> table`: Returns an array of `{x, y}` tables for all currently visible cells (one-based).

#### LTileAwareness Type

- Lua-side wrapper for per-player tile visibility/action masks.

##### Fields

- No documented fields.

##### Methods

- `LTileAwareness:actionCells(player, z?) -> table`: Returns all currently actionable cells for a player, optionally filtered to a level.
- `LTileAwareness:canActOn(player, x, y, z?) -> boolean`: Returns whether a one-based cell is currently actionable for a player.
- `LTileAwareness:clearAll() -> nil`: Clears current, explored, and action masks for all players.
- `LTileAwareness:clearPlayer(player) -> nil`: Clears current, explored, and action masks for one player.
- `LTileAwareness:clearShares() -> nil`: Clears all directed awareness share edges.
- `LTileAwareness:computeAction(player, opts) -> nil`: Computes one player's current action mask from a tilefield origin.
- `LTileAwareness:computeVisible(player, opts) -> nil`: Computes one player's current visible mask from a tilefield origin.
- `LTileAwareness:defineCategory(name, opts?) -> nil`: Defines or replaces one awareness category.
- `LTileAwareness:getCategories() -> table`: Returns known awareness category names.
- `LTileAwareness:getCategory(name) -> table?`: Returns awareness category metadata.
- `LTileAwareness:isAware(player, category, x, y, z?) -> nil`: Returns whether a one-based cell is visible for a specific awareness category.
- `LTileAwareness:isExplored(player, x, y, z?) -> boolean`: Returns whether a one-based cell has been explored for a player.
- `LTileAwareness:isVisible(player, x, y, z?) -> boolean`: Returns whether a one-based cell is currently visible for a player.
- `LTileAwareness:setTeam(players, categories?) -> nil`: Creates directed share edges between all listed players for selected categories.
- `LTileAwareness:share(from, to, category, opts?) -> nil`: Adds a directed awareness share edge for one category.
- `LTileAwareness:type() -> string`: Returns the Lua-visible type name for this tile visibility handle.
- `LTileAwareness:typeOf(name) -> boolean`: Returns whether this handle matches a supported type name.
- `LTileAwareness:visibleCells(player, z?, z?) -> table`: Returns all currently visible cells for a player, optionally filtered to a level.

## Examples

- `content/examples/awareness.lua` (present)

## Architecture Links

- Intentionally empty.

## Notes

- `awareness` owns visible, explored, and action masks. These masks are independent from tile lighting and from movement reachability.
- `lurek.awareness.newTileAwareness(field, opts)` stores separate current visible, explored, and action masks per player id.
- `lineOfSight(field, from, to, opts)` and `lineOfAction(field, from, to, opts)` intentionally default to different semantic channels: seeing a cell does not imply the actor can perform an action through the same line.
- `awareness` may consume light data in future policies, but v1 keeps tilelight and awareness separated.
