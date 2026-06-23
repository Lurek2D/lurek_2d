# tilefield Manual Notes

## TL;DR

`lurek.tilefield` is the tile-based gameplay semantics owner for multi-level maps. It stores independent blockers and costs for movement, vision, action, point light, and top light so pathfinding, visibility, minimap, and raycaster adapters can share one source of truth without depending on each other.

## Summary

- Coordinates exposed to Lua are one-based `x, y, z`; Rust storage is zero-based.
- Supported topologies are `square`, `iso_square`, and `hex`. `iso_square` uses square gameplay math because projection belongs to tilemap/rendering.
- Channels are intentionally independent: seeing through a cell does not imply acting, moving, or lighting through it.
- Built-in profiles include `empty`, `wall`, `window`, `door_closed`, `door_open`, and `half_wall`.
- Point lights use the `light` channel. `blocks.light=true` is full occlusion; `costs.light` is a `0..1` transmission multiplier for partial blockers such as smoked glass, grates, or shade screens.
- Point-light radius is radial: square and iso-square fields use Euclidean distance, while hex fields use hex distance. The square bounding box is only an iteration window, not the shape of the light.
- Point-light and global-light colors are RGB gameplay data, not renderer-only tint. Dusk, night, torch, alarm, and magical lights can use different colors and intensities.
- Global top light is attenuated by `sunOcclusion` from upper levels, preserving the configured global color while reducing intensity below occluding cells.

## Boundaries

- `pathfind` owns movement algorithms and consumes `tilefield` through adapters.
- `visibility` owns per-player visible/explored/action masks and line-of-sight/action queries.
- `raycaster` consumes `tilefield` as render input through `buildMultiLevelSceneFromField`; gameplay helpers stay in `tilefield`, `visibility`, and `pathfind`.
- `minimap` should consume exported layers and not compute gameplay state.
- `lurek.light` remains the 2D render-light/occluder module, separate from tilefield lighting.
