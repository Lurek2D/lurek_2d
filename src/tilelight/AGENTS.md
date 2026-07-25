# Tilelight Module Contract

## Mission & Scope
- Own computed tile lighting, runtime sources, ambient/sun settings, propagation, and RGB/luma output.
- Read tile facts from `tilefield`; never add a reverse dependency.

## Files
- `map.rs`: Light grid, propagation, output, and freshness state.
- `source.rs`, `color.rs`: Runtime sources and color values.
- `limits.rs`: Storage and work limits.

## Rules
- Apply `TileLightLimits` before allocation, source changes, exports, or compute work.
- Runtime source ids are monotonic and never reused; removed source storage is compacted.
- Reject non-finite or out-of-range values before mutation.
- Output records its tilefield and source versions. Recompute stale output before reads or exports.
- Incremental output must match a full recompute within the documented epsilon.
- Do not own player knowledge, GPU lights, tilemap visuals, minimap, or raycaster output.

## Workflow
- Run `cargo test --test tilelight_tests` and tilelight Lua unit/security/stress tests.
