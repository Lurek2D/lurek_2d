# minimap manual spec overlay

## TL;DR

- Runs grid-based HUD minimaps with fog-of-war inputs, custom markers, passive render snapshots, and camera tracking.

## Summary

- The `minimap` module is the HUD-scale map surface for users who want world state, fog, markers, and view tracking to become a compact readable overlay.
- Core minimap state, render helpers, and adapters from province, tilefield, visibility, or render snapshot data work together so the same module can represent several kinds of world information in one small map display.
- Fog, owner colors, overlays, tracked objects, and camera-aware view markers matter because a minimap is not only a tiny texture: it is a summarized navigation and awareness tool for the player.
- The module is useful wherever a project needs strategic orientation, local awareness, or debug-style map inspection without switching to a full map screen.
- Marker and layer support are especially important because a minimap often needs to combine several categories of information at once: player position, objectives, faction territory, danger, or discovered landmarks.
- In tool and strategy-heavy contexts, the minimap can also become a compact interaction surface or diagnostic lens rather than only a passive HUD element, which is why adapters and styling control matter.
- Rotation, zoom, clipping, and icon policy matter too, because a compact map has to stay legible while world state and camera framing keep changing.
- A minimap is therefore not only a tiny render, but a compact policy layer for world awareness.
- Read it as the owner of compact map presentation.

This module primarily collaborates with `camera`, `image`, `province`, `raycaster`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Notes

- `minimap` is a passive compact visualization layer. It should not compute movement, line-of-sight, line-of-action, or tile lighting.
- For tilefield-driven games, feed minimap terrain/fog/overlay data from `LTileField:exportProfileLayer`, `LTileField:exportBlockLayer`, `LTileField:exportLightLayer`, and `LTileVisibility:*` outputs.
- Existing raycaster or tilemap helpers are passive adapters; they should not become gameplay authorities for blockers, visibility, or lighting.
- Construction is strict: zero grid dimensions, zero display dimensions, overflowed cell counts, and oversized display buffers are rejected before the minimap is created.
- Bulk terrain and fog loads use exact-length validation on the Lua-facing API so stale cells are not silently mixed with fresh data.
- Grid/display transforms require finite coordinates, a finite positive zoom, and positive display dimensions; invalid transform state returns nils for `screenToGrid` and `gridToScreen` instead of leaking NaN or Inf into callers.
- Layer payloads are grid-shaped contracts: `width` and `height` must match the minimap grid, cell payload length must match `width * height`, and active-layer switches are only valid for populated layers.
- `drawToImage(pixel_size)` now honors `pixel_size` when provided, falls back to the configured display size when `pixel_size == 0`, and covers the full output image even when display pixels do not divide evenly by grid size.
- Render-command generation batches adjacent same-color cells into horizontal runs and exposes debug stats through `Minimap::render_stats(screen_x, screen_y)` for tooling and regression tests.
- Raycaster minimap extraction uses checked arithmetic for radius, cell size, pixel count, and byte count, and player-arrow drawing validates both width and height against the supplied RGBA buffer length.
- Marker/object/ping/icon setters reject missing ids, invalid type indices, non-finite coordinates, and invalid icon size overrides on the strict Lua path instead of silently no-oping.

## Architecture Links

- Intentionally empty.
