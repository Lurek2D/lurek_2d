# tilefield Manual Notes

## TL;DR

`lurek.tilefield` is the shared tile-based gameplay data owner for multi-level maps. It stores independent blockers, costs, profile names, and author-defined cell refs so pathfinding, awareness, tilelight, minimap, and raycaster adapters can share one source of truth without depending on each other.

## Summary

- Coordinates exposed to Lua are one-based `x, y, z`; Rust storage is zero-based.
- `LTileField` is a single field with width, height, and one or more levels. This is the default one-level map model.
- `LTileFieldMap` is a 2D or layered map of shared `LTileField` handles. Use it when a world is chunked into fields or stacked as layers of fields.
- Supported topologies are `square`, `square4`, `square8`, `iso_square`, and `hex`. `square` keeps the existing eight-way distance behavior, `square4` uses Manhattan distance, and `iso_square` uses square gameplay math because projection belongs to tilemap/rendering.
- Channels are intentionally independent: seeing through a cell does not imply acting, moving, or lighting through it.
- Built-in profiles include `empty`, `wall`, `window`, `door_closed`, `door_open`, and `half_wall`.
- The `light` channel and `sunOcclusion` are environment inputs consumed by `lurek.tilelight`; `tilefield` does not store point lights or computed light values.
- Cell refs such as `floor`, `wall_left`, `roof`, or `object` are author-defined slots. They are useful for mapping tile ids, object ids, or block slots onto the same gameplay field without forcing every system to own separate data.

## Boundaries

- `pathfind` owns movement algorithms and consumes `tilefield` through adapters.
- `awareness` owns per-player visible/explored/action masks and line-of-sight/action queries.
- `tilelight` owns tile-based environment lighting from point lights, ambient light, global top light, occluders, and shadows.
- `raycaster` consumes `tilefield` as render input through `buildMultiLevelSceneFromField`; gameplay helpers stay in `tilefield`, `awareness`, `tilelight`, and `pathfind`.
- `minimap` should consume exported layers and not compute gameplay state.
- `lurek.light` remains the screen/world render-light and occluder module, separate from tile-based environment lighting.
