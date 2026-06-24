# mapblock manual spec overlay

## TL;DR

- Assembles tilemaps from block pieces using socket rules, scripts, and multi-level grids.

## Summary

- The `mapblock` module is the engine's modular map-assembly surface for users who want larger spaces built from reusable authored blocks instead of from one monolithic generator.
- Blocks, sockets, constraints, groups, scripts, orientation rules, and multilevel placement live together here so handcrafted pieces can recombine without losing local design intent.
- The module is especially useful for dungeons, modular interiors, overworld chunks, and other generators where the meaningful unit is a room or chunk rather than an individual tile.
- Constraint and socket logic are central because modular generation only works when legal adjacency, facing, and connector rules remain explicit and enforceable.
- Placement state and output shaping matter because the system must not only choose valid pieces, but also produce results that downstream tilemap, navigation, and render workflows can use safely.
- Construction and generation now reject oversized block requests, invalid weights, and level-span overflow before they can degrade into silent no-ops or unchecked allocation paths.
- Rust callers can inspect per-run generator diagnostics for missing groups, unsupported steps, invalid weights, placement stalls, and rejected paint operations.
- Script hooks and grouping support make the system adaptable to thematic or progression-aware generation, which is important when modular pieces need more nuance than simple random choice.
- Orientation and multilevel handling matter because reusable blocks often connect vertically or directionally, and the legality of the final layout depends on those relationships being tracked explicitly.
- This makes the module useful whenever designed pieces need to stay meaningful after recombination. A corridor, room, bridge, or stair block can keep its authored purpose while still participating in procedural assembly.
- It preserves authored intent while still enabling recombination.
- Neighboring modules consume the output, but `mapblock` owns the modular grammar that decides how authored fragments connect into a legal larger space.
- Read `mapblock` as the subsystem that turns reusable map pieces into generated layouts with explicit connection rules.

This module primarily collaborates with `procgen`. Its responsibility should stay inside the `Edge/Integration` group rather than absorb behavior owned by those neighbors.

## Notes

- `mapblock` produces assembled map data: placed blocks, tile slots, tileset references, and exported tile layers. It should not compute pathfinding, awareness, tile lighting, minimap presentation, or render commands.
- A game that needs runtime systems should convert mapblock output into `tilemap` and/or a shared `tilefield` snapshot, then run `pathfind`, `tilelight`, `awareness`, and minimap adapters independently on that data.
- Rust-level integration is justified only for concrete adapters such as exporting block slots into `TileField` refs or copying tile ids into a `TileMap`; policy decisions stay in Lua/game code.

## Architecture Links

- Intentionally empty.
