# Tilelight Module Contract

## Mission & Scope
- Own computed tile-cell environment lighting, runtime point/line/area sources, ambient/sun settings, propagation, and RGB/luma output.
- Consume `tilefield` blockers, transmission/filter categories, topology, authored emitter metadata, and version/dirty data without a reverse dependency.

## Files
- `color.rs`, `source.rs`, `limits.rs`, and `map.rs` own tilelight values, source records, ceilings, propagation, output, and freshness state.
- `src/lua_api/tilelight_api.rs` owns Lua conversion and registration only; tests and manual spec remain in their canonical repository locations.

## Rules
- `TileLightLimits` bounds every dense allocation, source collection, source shape, export copy, and compute workload before iteration.
- Runtime source ids are monotonic and never reused; removed source storage is compacted.
- Reject non-finite or out-of-range colors, intensities, modulation values, and compute time before mutating state.
- Computed output records the tilefield and source versions it represents; stale output must be recomputed before reads or exports.
- Dirty recompute may use the bounded full-recompute fallback, and any incremental implementation must match full output within documented epsilon.
- Do not own awareness/player knowledge, render lights/shadows/GPU passes, tilemap visual storage, or minimap/raycaster presentation.

## Workflow
- Validate with `cargo test --test tilelight_tests`, the tilelight Lua unit/security/stress suites, and the tilelight audit commands in the fix plan.
