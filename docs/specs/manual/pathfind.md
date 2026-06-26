# pathfind manual spec overlay

## TL;DR

- Navigates grids, hex layouts, isometric maps, navmeshes, and province graphs.
- Employs A*, JPS, bidirectional search, HPA*, and async thread pools.
- Uses Dijkstra flow fields, tactical influence maps, steering stacks, context steering, ORCA-style local avoidance, and debug visual overlays.

## Summary

- The `pathfind` module is the engine's navigation and movement-analysis surface for users who need more than one hard-coded shortest-path helper.
- It supports several spatial models at once, including weighted grids, hex and isometric spaces, province-style graphs, influence fields, and other routing abstractions, so different worlds can still share one navigation family.
- A* is only part of the surface. The module also covers bidirectional search, Jump Point Search, hierarchical routing, graph travel, flow fields, influence maps, steering, local avoidance, and reachability-style analysis under one subsystem.
- This breadth matters because movement questions differ dramatically across features. Some systems need one precise route, others need shared guidance, tactical pressure, move ranges, or background jobs for expensive searches.
- That makes the module useful not only for point-to-point travel but also for squad guidance, threat-aware movement, logistics overlays, and strategic map reasoning where spatial scoring matters.
- Async search support is especially important because pathfinding is often one of the first systems that must leave the main loop without losing an engine-owned, script-facing API.
- Shared abstractions for grids and graph-like inputs reduce adapter overhead and make it easier for a project to compare algorithms without rewriting all navigation data plumbing.
- Range and reachability helpers are as important as final path extraction. Many systems need to know where a unit could move, what lies inside a budget, or which cells are effectively controlled before they need an explicit route.
- Influence, steering, ORCA, and shared-field helpers broaden the module into tactical movement analysis. Movement is not only about reaching a goal; it is also about preferring safe zones, avoiding danger, and turning desired motion into local movement advice for several actors.
- Because several world models can feed the same pathfinding family, projects can evolve from simple grid routing to richer graph or field-based navigation without abandoning the same conceptual subsystem.
- That flexibility is one of the main reasons the module exists as a family rather than as one algorithm wrapper: different gameplay scales can still share one navigation vocabulary.
- Cost rules are part of that vocabulary too. Terrain penalties, danger zones, ownership boundaries, and temporary blockers can all be expressed as navigation data instead of being bolted on after a path is returned.
- This helps projects keep route quality and tactical intent aligned, because the same system can explain not only where an actor can go, but why one route is preferred over another.
- The module is also valuable when several agents share the same traversability model but need different routing policies over it.
- That makes `pathfind` a planning layer, not only a shortest-path helper.
- Debug and visualization helpers matter because navigation bugs usually come from topology, weights, or blocked-space assumptions rather than from the solver implementation alone.
- `tilemap`, `province`, and related modules define traversable space, but `pathfind` owns how that space is searched, scored, and turned into movement advice.
- Province-level BFS, weighted Dijkstra/A*, connected-component traversal, and reachability belong here even when `province` exposes convenience methods that adapt registry topology into pathfinding inputs.
- Read `pathfind` as the reusable navigation and local-movement analysis layer of the engine, not as an animation or physics integration system.

This module primarily collaborates with `flownet`, `image`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Notes

- `pathfind` owns movement algorithms, movement range, route search, costs, reachability, influence maps, steering, context steering, and ORCA local avoidance. It does not own line-of-sight, line-of-action, lighting, object-profile semantics, or high-level decision models.
- `pathfind::graph_path` owns reusable integer-id graph traversal. Public Lua helpers `lurek.pathfind.graphRoute`, `graphRoutes`, `graphConnectedComponents`, and `graphConnected` accept ordinary edge tables, while territory registries remain in `province` and logistics flow simulation remains in `flownet`.
- `lurek.pathfind.newNavGridFromField(field, opts)`, `lurek.pathfind.newHexGridFromField(field, opts)`, and `lurek.pathfind.rangeMapFromField(field, opts)` are adapters from `lurek.tilefield`; by default they read the `"move"` channel and movement costs from the field. Use the hex adapter when the field topology is `hex`.
- `newNavGridFromTileMap` remains a compatibility path for projects that want direct tilemap-to-navigation conversion without adopting `tilefield`.

## Architecture Links

- Intentionally empty.
