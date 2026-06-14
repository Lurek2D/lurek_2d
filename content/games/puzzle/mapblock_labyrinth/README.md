# Mapblock Labyrinth

**Category:** puzzle / procedural maps  
**Status:** playable

Irregular province puzzle assembled from `lurek.mapblock` building blocks.

- Stage 1 builds a province on an explicit irregular placement grid, not a plain rectangle.
- The macro script mixes `fill_edges`, fixed anchor placements, and `solve_shape`.
- Interior blocks use rotated and mirrored polyomino footprints.
- Stage 2 expands the macro placements into a full tile map with two detailed levels.
- Detail blocks use mixed sizes such as `10x10`, `15x10`, and `20x10` tiles.
- The screen shows the macro province and both detailed levels side by side so the demo doubles as a visual inspection tool for the module.

Controls:
- `Arrows` or `WASD`: move
- `R`: reroll the province with the next seed
- `Space`: reset to the start
- `Esc`: quit

Run:

```bash
cargo run --bin lurek2d -- content/games/puzzle/mapblock_labyrinth
```
