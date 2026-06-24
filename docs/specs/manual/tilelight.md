# tilelight manual spec overlay

## TL;DR

- Tile-based environment lighting computed from a shared `LTileField`.

## Summary

- The `tilelight` module owns light propagation over tile cells. It reads blockers, transmission costs, topology, and sun occlusion from `tilefield`, then produces computed RGB/luma layers.
- It is environment-level data, not player-specific knowledge. Fog-of-war, action masks, and remembered exploration belong to `awareness`.
- It is tile-level gameplay/light data, not the screen/world render-light system. Render-facing lights and occluders remain in `lurek.light`.
- Point lights, ambient light, and global top light live on `LTileLightMap` so `LTileField` can remain a reusable source of gameplay data for many independent systems.

## Notes

- `LTileLightMap` must match the source field dimensions and topology before compute.
- Point lights use the field `light` channel. `blocks.light=true` is full occlusion; `costs.light` is a `0..1` transmission multiplier for partial blockers such as smoked glass, grates, or shade screens.
- Global top light is attenuated by `sunOcclusion` from upper levels, preserving the configured global color while reducing intensity below occluding cells.
- Exported light layers are passive data suitable for minimap overlays, render adapters, diagnostics, and Lua game logic.

## Architecture Links

- Intentionally empty.
