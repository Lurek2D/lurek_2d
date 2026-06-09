# visibility

## TL;DR

- Geometry-agnostic fog-of-war and shadowcasting field-of-view simulation.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/visibility/`
- Binding: `src/lua_api/visibility_api.rs`
- Namespace: `lurek.visibility`
- Lua API surface: `2` functions, `2` types, `27` methods
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

- The visibility module provides geometry-agnostic fog-of-war and discovery state simulation.
- Topology is abstracted through adjacency contracts rather than a fixed map representation.
- Per-player region state tracks hidden, discovered, and currently visible layers.
- Alliance grouping supports shared visibility between cooperating actors.
- Cost and flag channels support configurable reveal progression rules.
- Visibility transitions are emitted as structured events for script systems.
- Fog rendering parameters map state to visual intensity outputs.
- Shadowcasting FOV provides efficient tile-grid line-of-sight computation.
- State export/import supports save persistence of visibility history.
- The module owns visibility semantics, not renderer or AI policy.

This module is mostly self-contained inside the `Edge/Integration` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Files

### adjacency.rs

- This file provides the adjacency abstraction that supplies neighborhood topology to visibility.
- It defines a geometry-agnostic contract so grids, graphs, and region maps share one interface.
- It enables visibility algorithms to run without coupling to any single world representation.
- It keeps neighbor queries and region cardinality explicit for deterministic reveal behavior.

### cost.rs

- This file provides per-region discovery cost metadata used by reveal progression logic.
- It encodes adjacency prerequisites and progression thresholds for visibility expansion.
- It keeps reveal gating explicit so exploration pacing remains tunable and predictable.

### events.rs

- This file provides event types emitted when visibility state transitions occur.
- It captures reveal, hide, and ownership-related changes as script-consumable signals.
- It enables frame-coherent reaction flows for fog effects and gameplay scripting hooks.

### flags.rs

- This file provides bitflag storage for per-region visibility-related feature markers.
- It encodes what information layers are present or unlocked for each map region.
- It supports gated reveal logic by combining flag checks with discovery progression rules.
- It keeps per-region capability state compact and efficient for frequent visibility queries.

### fog_render.rs

- This file provides fog rendering configuration that maps visibility state to visual intensity.
- It defines opacity and transition behavior used by world compositing passes.
- It keeps fog appearance tunable without altering visibility simulation internals.

### grid.rs

- This file provides the main visibility grid that stores region state across players and factions.
- It tracks current and historical knowledge levels to separate visible and discovered outcomes.
- It drives reveal and hide progression while emitting state-change events for script consumers.
- It marks dirty regions so rendering and event systems process only meaningful transitions.
- It supports compact serialization so long-campaign visibility history remains save-friendly.

### mod.rs

- This module delivers the high-level fog, discovery, and line-of-sight system for region maps.
- It stays geometry-agnostic so tile, province, and custom topologies can share the same model.
- It unifies state storage, ownership sharing, reveal costs, events, and fog presentation paths.

### owner.rs

- This file provides ownership and alliance mapping used for shared visibility semantics.
- It tracks player grouping so allied entities can inherit reveal information coherently.
- It answers hot-path sharing queries that visibility updates depend on each frame.
- It ensures ownership changes can trigger consistent recalculation of affected states.

### shadowcast.rs

- This file provides recursive shadowcasting field-of-view for tile-grid visibility queries.
- It computes current sight masks while preserving explored history across update frames.
- It accepts blocker predicates at compute time for flexible integration with world state.
- It serializes visible and explored masks so FOV state can persist across save boundaries.
- It supports deterministic octant traversal suitable for stealth and roguelike mechanics.
- It gives visibility systems a fast geometric core for line-of-sight decisions.
- It keeps FOV computation stable enough for repeated per-frame use in tactical scenarios.

### state.rs

- This file provides the visibility state model that describes player knowledge per region.
- It encodes hidden, discovered, visible, and extensible custom levels in one ordered enum.
- It standardizes information progression so reveal logic and fog rendering stay consistent.

## Lua API Ref

### Functions

- `lurek.visibility.new(config) -> LVisibilityGrid`: Create a new visibility grid for shadow-cast computation.
- `lurek.visibility.newFov(opts) -> LFov`: Creates a new tile-grid shadowcasting FOV for roguelike and stealth games.

### Callbacks

- `LFov:eachVisible` param `fn` (`function`): Callback receiving column and row integers.
- `LFov:setBlocker` param `fn` (`function`): `fn(x: integer, y: integer) -> boolean` (one-based).

### Enums

- No documented module-level enums/constants.

### Types

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

#### LVisibilityGrid Type

- Lua-side wrapper for a visibility grid instance.

##### Fields

- No documented fields.

##### Methods

- `LVisibilityGrid:drainEvents() -> table`: Drains and returns all pending visibility events.
- `LVisibilityGrid:getCost(region_id) -> number`: Gets the discovery cost for a region.
- `LVisibilityGrid:getFogIntensity(player_id, region_id) -> number`: Gets the fog intensity for a region from a player's perspective.
- `LVisibilityGrid:getState(player_id, region_id) -> string`: Gets the visibility state for a player at a region.
- `LVisibilityGrid:hasFlag(region_id, bit) -> boolean`: Checks if a visibility flag bit is set on a region.
- `LVisibilityGrid:hide(player_id, region_id) -> nil`: Hides a region for a player (moves from Visible to Discovered).
- `LVisibilityGrid:playerCount() -> integer`: Returns the total number of players in the grid.
- `LVisibilityGrid:regionCount() -> integer`: Returns the total number of regions in the grid.
- `LVisibilityGrid:reset(player_id) -> nil`: Resets all visibility to Hidden for a player.
- `LVisibilityGrid:reveal(player_id, region_id, flags?) -> nil`: Reveals a region for a player (and their allies). Optional flags argument.
- `LVisibilityGrid:revealAll(player_id) -> nil`: Reveals all regions for a player (debug/cheat).
- `LVisibilityGrid:setCost(region_id, cost) -> nil`: Sets the discovery cost for a region.
- `LVisibilityGrid:setFlag(region_id, bit, value) -> nil`: Sets a visibility flag bit on a region.
- `LVisibilityGrid:setGroup(players) -> integer`: Sets an alliance group for a list of players (shared visibility).
- `LVisibilityGrid:sharesVisibility(player_a, player_b) -> boolean`: Checks if two players share visibility (same alliance group or same player).
