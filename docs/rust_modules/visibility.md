# visibility

## General Info

- Module group: `Edge/Integration`
- Source path: `src/visibility/`
- Binding: `src/lua_api/visibility_api.rs`
- Namespace: `lurek.visibility`
- Lua API surface: `2` functions, `2` types, `27` methods
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

The `visibility` module provides a universal fog-of-war and discovery layer that can be attached to any region-based map without coupling to a specific map module. The foundational abstraction is the `AdjacencyProvider` trait: callers implement a single `neighbors(region_id)` method to describe neighbor relationships. Grid maps inject 4- or 8-directional adjacency; province maps use their border index; custom systems supply arbitrary neighbor lists. This injection point is the only geometry dependency.

Per-region state is stored in the `VisibilityGrid`, a compact `(faction_id, region_id)` map tracking three built-in `VisibilityState` levels: `Hidden` (never seen), `Discovered` (seen at least once, currently out of range), and `Visible` (currently in sight range). Custom intermediate levels can be defined for richer game-state models. Multiple factions are supported simultaneously; the `PlayerOwnership` tracker groups allies so that shared-vision alliances propagate reveals automatically.

Discovery semantics are controlled per region via `VisibilityCost`: a movement-point cost gates reveal progression, and a required-flag mask (`VisibilityFlags`, a `u32` bitfield with 24 game-defined bits) can block reveal until the player possesses a specific capability. When regions transition between states, the grid queues `VisibilityEvent` entries (`RegionRevealed`, `RegionDiscovered`, `RegionHidden`) that are drained to Lua each tick — providing clean hooks for map-reveal animations, narrator cues, and scripted responses.

Rendering integration is handled via `FogRenderConfig`, which supplies per-state fog opacity values and RGBA tint colors composited as per-tile multiply in the world render pass. The full grid state serializes compactly (2 bits per region per faction) into the save file. The `lurek.visibility.*` Lua API exposes grid construction, reveal/hide calls, state queries, event draining, cost and flag mutation, faction grouping, and fog configuration.

## Files

### [adjacency.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/visibility/adjacency.rs)

- This file provides the adjacency abstraction that supplies neighborhood topology to visibility.
- It defines a geometry-agnostic contract so grids, graphs, and region maps share one interface.
- It enables visibility algorithms to run without coupling to any single world representation.
- It keeps neighbor queries and region cardinality explicit for deterministic reveal behavior.

### [cost.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/visibility/cost.rs)

- This file provides per-region discovery cost metadata used by reveal progression logic.
- It encodes adjacency prerequisites and progression thresholds for visibility expansion.
- It keeps reveal gating explicit so exploration pacing remains tunable and predictable.

### [events.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/visibility/events.rs)

- This file provides event types emitted when visibility state transitions occur.
- It captures reveal, hide, and ownership-related changes as script-consumable signals.
- It enables frame-coherent reaction flows for fog effects and gameplay scripting hooks.

### [flags.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/visibility/flags.rs)

- This file provides bitflag storage for per-region visibility-related feature markers.
- It encodes what information layers are present or unlocked for each map region.
- It supports gated reveal logic by combining flag checks with discovery progression rules.
- It keeps per-region capability state compact and efficient for frequent visibility queries.

### [fog_render.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/visibility/fog_render.rs)

- This file provides fog rendering configuration that maps visibility state to visual intensity.
- It defines opacity and transition behavior used by world compositing passes.
- It keeps fog appearance tunable without altering visibility simulation internals.

### [grid.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/visibility/grid.rs)

- This file provides the main visibility grid that stores region state across players and factions.
- It tracks current and historical knowledge levels to separate visible and discovered outcomes.
- It drives reveal and hide progression while emitting state-change events for script consumers.
- It marks dirty regions so rendering and event systems process only meaningful transitions.
- It supports compact serialization so long-campaign visibility history remains save-friendly.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/visibility/mod.rs)

- This module delivers the high-level fog, discovery, and line-of-sight system for region maps.
- It stays geometry-agnostic so tile, province, and custom topologies can share the same model.
- It unifies state storage, ownership sharing, reveal costs, events, and fog presentation paths.

### [owner.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/visibility/owner.rs)

- This file provides ownership and alliance mapping used for shared visibility semantics.
- It tracks player grouping so allied entities can inherit reveal information coherently.
- It answers hot-path sharing queries that visibility updates depend on each frame.
- It ensures ownership changes can trigger consistent recalculation of affected states.

### [shadowcast.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/visibility/shadowcast.rs)

- This file provides recursive shadowcasting field-of-view for tile-grid visibility queries.
- It computes current sight masks while preserving explored history across update frames.
- It accepts blocker predicates at compute time for flexible integration with world state.
- It serializes visible and explored masks so FOV state can persist across save boundaries.
- It supports deterministic octant traversal suitable for stealth and roguelike mechanics.
- It gives visibility systems a fast geometric core for line-of-sight decisions.
- It keeps FOV computation stable enough for repeated per-frame use in tactical scenarios.

### [state.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/visibility/state.rs)

- This file provides the visibility state model that describes player knowledge per region.
- It encodes hidden, discovered, visible, and extensible custom levels in one ordered enum.
- It standardizes information progression so reveal logic and fog rendering stay consistent.
