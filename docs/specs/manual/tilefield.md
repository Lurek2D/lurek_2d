# tilefield Manual Notes

## TL;DR

`lurek.tilefield` is the shared tile-based gameplay data owner for multi-level maps. It stores independent blockers, costs, profile names, and author-defined cell refs so pathfinding, awareness, tilelight, minimap, and raycaster adapters can share one source of truth without depending on each other.

## Summary

- Coordinates exposed to Lua are one-based `x, y, z`; Rust storage is zero-based.
- `LTileField` is a single field with width, height, and one or more levels. This is the default one-level map model.
- `LTileFieldMap` is a 2D or layered map of shared `LTileField` handles. Use it when a world is chunked into fields or stacked as layers of fields.
- Supported topologies are `square`, `square4`, `square8`, `iso_square`, and `hex`. `square`/`square8` use eight neighbors, but radial range budgets use Euclidean square distance so a diagonal is `sqrt(2)`; `square4` uses Manhattan distance, and `iso_square` uses square gameplay math because projection belongs to tilemap/rendering.
- Channels are intentionally independent: seeing through a cell does not imply acting, moving, or lighting through it.
- Built-in profiles include `empty`, `wall`, `window`, `door_closed`, `door_open`, and `half_wall`.
- The `light` channel and `sunOcclusion` are environment inputs consumed by `lurek.tilelight`; `tilefield` does not store point lights or computed light values.
- Cell refs such as `floor`, `wall_left`, `roof`, or `object` are author-defined slots. They are useful for mapping tile ids, object ids, or block slots onto the same gameplay field without forcing every system to own separate data.
- Construction, provider import, field-map allocation, region expansion, snapshot export, and restore use `TileFieldLimits`. Products are checked as `u64` before conversion/allocation; Lua accepts a nested `limits` table with names such as `maxCells`, `maxFields`, `maxMapCells`, `maxLevels`, `maxRegions`, `maxRegionCells`, `maxDirtyRects`, `maxProviderRows`, `maxSnapshotEntries`, and `maxStringLength`.
- Provider import and snapshot restore are transactional. A malformed shape, duplicate sparse record, non-finite number, invalid coordinate, or exceeded ceiling is rejected before a live field is replaced.
- `version` starts at `1` and increments for successful data-definition and cell mutations. Dirty cells are coalesced into deterministic rectangles and bounded by `maxDirtyRects`; overflow emits a coarse full-level rectangle. `beginEdit` is nested and preserves pending dirty state; `commitEdit` drains only the outermost edit.
- `clear` resets cells, regions, occupants, resources, and buildability but retains category, modifier, and slot definitions. Occupant `0` removes an occupant, missing buildability is `true`, and empty resource labels are absent. Removing a custom category, modifier, or slot clears dependent cell data.
- Emitter records on cells/modifiers are authored environmental metadata for `tilelight`; computed light maps and runtime source lifecycle remain in `tilelight`.

## Boundaries

- `pathfind` owns movement algorithms and consumes `tilefield` through adapters.
- `awareness` owns per-player visible/explored/action masks and line-of-sight/action queries.
- `tilelight` owns tile-based environment lighting from point lights, ambient light, global top light, occluders, and shadows.
- `raycaster` consumes `tilefield` as render input through `buildMultiLevelSceneFromField`; gameplay helpers stay in `tilefield`, `awareness`, `tilelight`, and `pathfind`.
- `minimap` should consume exported layers and not compute gameplay state.
- `lurek.light` remains the screen/world render-light and occluder module, separate from tile-based environment lighting.
- `fromTileMap` is an explicit conversion adapter: it copies one named layer and only applies solid ids or tileset-object defaults when the caller opts in. It does not infer gameplay policy from map visuals.
- Runtime conversion ownership is split by consumer. `lurek.physics` is the canonical owner for physics bodies generated from tilefield refs, and `lurek.light` is the canonical owner for render lights/occluders. `lurek.tilefield.createPhysicsFromTileset` and `createLightsFromTileset` remain documented compatibility aliases for one migration window and are not core tilefield state.
- Authored tile-light emitter metadata contains finite non-negative `radius` and `intensity` values plus an RGB `color`; these are source defaults consumed by `tilelight`, not runtime light objects or computed propagation state.

## Lua API

- Tilefield light metadata uses `radius`, `intensity`, and RGB `color` fields when a cell or modifier describes an authored emitter for `tilelight`.
- `inspectCells`, `inspectFootprint`, and `summarizeResources` are bounded read-side aggregation helpers. They report tilefield facts only and do not infer building, economy, or ECS policy.
- `setFootprintOccupant` validates the whole footprint before mutation and advances the field version once. Occupant ids are opaque values chosen and interpreted by Lua.
- `preparePatch` stages a cloned, validated field mutation with preview/commit/discard semantics. Commit checks the live field version and never coordinates another module.
- `snapshotRegion` and `hashRegion` provide deterministic regional evidence for Lua-owned saves, caches, and replay checks.
