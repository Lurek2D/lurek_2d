# tilelight manual spec overlay

## TL;DR

- Tile-based environment lighting computed from a shared `LTileField`.

## Summary

- The `tilelight` module owns light propagation over tile cells. It reads blockers, transmission costs, topology, and sun occlusion from `tilefield`, then produces computed RGB/luma layers.
- It is environment-level data, not player-specific knowledge. Fog-of-war, action masks, and remembered exploration belong to `awareness`.
- It is tile-level gameplay/light data, not the screen/world render-light system. Render-facing lights and occluders remain in `lurek.light`.
- Point lights, ambient light, and global top light live on `LTileLightMap` so `LTileField` can remain a reusable source of gameplay data for many independent systems.
- Runtime source ids, source updates/removal, modulation, computed values, and propagation remain tilelight-owned. Tilefield stores only authored emitter metadata and environmental inputs.

## Notes

- `LTileLightMap` must match the source field dimensions and topology before compute.
- Point lights use the field `light` channel. `blocks.light=true` is full occlusion; `costs.light` is a `0..1` transmission multiplier for partial blockers such as smoked glass, grates, or shade screens.
- Global top light is attenuated by `sunOcclusion` from upper levels, preserving the configured global color while reducing intensity below occluding cells.
- Exported light layers are passive data suitable for minimap overlays, render adapters, diagnostics, and Lua game logic. `exportLayer` and `exportVolume` are bounded copies and require current computed output.
- `TileLightLimits` rejects oversized volumes, source counts, radii, line lengths, area halos, per-source influence, output copies, and estimated compute work before allocation or nested propagation.
- Colors and intensities are finite and clamped only after validation. Modulation amplitudes are `0..1`, frequencies are finite and non-negative, phases are finite, and compute time must be finite; negative finite time is allowed for deterministic replay.
- A successful compute records the tilefield version and runtime source version it represents. Mutations mark output dirty, stale reads/exports fail with the owning API name, and `compute_dirty` currently uses a bounded full-recompute fallback for correctness.
- `blocks.light` and transmission/filter values on intermediate cells affect incoming point, line, and area light. The source cell is not re-applied as an occluder, and target-cell blocker semantics follow the existing line transfer contract.

## Architecture Links

- Intentionally empty.
