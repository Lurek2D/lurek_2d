# Mapblock Labyrinth

**Category:** puzzle / procedural maps  
**Status:** skeleton

Procedural labyrinth puzzle assembled from reusable block pieces with fog-of-war and route solving.

**Modules:** `mapblock`, `tilemap`, `procgen`, `pathfind`, `visibility`

Next steps:
- Define a small block library with sockets and lock/key rules.
- Generate readable levels from those blocks.
- Add solver hints and visibility reveal.

Run:

```bash
cargo run -- content/games/puzzle/mapblock_labyrinth
```
