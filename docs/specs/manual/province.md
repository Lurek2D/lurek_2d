# province manual spec overlay

## TL;DR

- Simulates region maps decoded from color-coded PNG cartographic assets.
- Imports capitals, angled labels, and terrain metadata, compiling adjacencies.
- Supports horizontal span runs, binary geometry caches, and map modes.
- Calculates depth distance fields, strategic routing, and revision logs.

## Summary

- The `province` module is the engine's territory-region system for users who want named areas, borders, ownership, routing, and province-like gameplay state to behave as one native feature.
- Topology, registries, imports, labels, caches, route helpers, property layers, render bridges, and view transforms matter because a province map is more than a color fill; it is a structured graph of regions with state and presentation rules.
- Province identity is central from the user perspective. Scripts need to ask which region an area belongs to, how regions connect, what properties they carry, and how those answers change over time.
- Ownership, labels, borders, and view helpers make the module useful for strategy maps, campaign layers, regional simulations, and UI-heavy territory systems where territory data must be both playable and readable.
- Routing and adjacency behavior extend the feature from passive map metadata into active game logic, because movement, logistics, diplomacy, and campaign progression often depend on region-to-region relationships.
- Property layers, events, and interaction helpers make the module useful both as a gameplay authority for territory logic and as a map-facing surface for highlighting, picking, overlays, and editor-style inspection.
- Import and cache support matter because province-heavy projects often operate on large authored maps where region definitions, border relationships, and property tables must be reused efficiently at runtime instead of reparsed or recomputed ad hoc.
- Region properties broaden the feature beyond simple ownership maps. Provinces often carry economy, culture, terrain, danger, visibility, supply, or event flags, and the module gives those layers one shared place to live and change over time.
- That shared province identity is what keeps strategy logic, labels, overlays, and player interaction pointed at the same region model instead of drifting apart.
- Picking and view-transform helpers are especially important for strategy interfaces and editors, where the province system must translate user interaction into stable region identity rather than acting as a query-by-id database hidden behind other UI layers.
- This is why `province` works well for campaign maps, strategy regions, and territory editors.
- It also gives simulation and map UI one shared authority for ownership and adjacency.
- Read `province` as the territory authority of the engine. Other systems may navigate, draw, or summarize provinces, but this module decides how provinces are represented, connected, labeled, updated, and queried with one stable region model.

This module primarily collaborates with `image`, `render`, `runtime`. Its responsibility should stay inside the `Edge/Integration` group rather than absorb behavior owned by those neighbors.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
