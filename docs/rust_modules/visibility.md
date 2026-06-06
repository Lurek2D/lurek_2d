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

This module delivers a highly flexible, geometry-agnostic visibility and fog-of-war system that integrates seamlessly with varied world models. By decoupling layout metrics from visibility calculations through a generic adjacency interface, the system can track exploration across tile grids, hex maps, province networks, and global spheres. It tracks hidden, discovered, and visible statuses separately across factions.

For tactical environments, the module features a recursive shadowcasting engine that calculates field-of-view masks with custom obstacle predicates. It supports exploration-sharing alliances, customizable discovery costs, and compact state serialization for game saves. When visibility updates occur, the system dispatches transition events, letting scripts react to changes dynamically.

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
