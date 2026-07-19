# Tileset Module Contract

## Mission & Scope
- Own atlas-local tile metadata, animation, autotile rules, and visual tile profiles.
- Keep map storage, chunk ownership, coordinate conversion, import budgets, and dirty-region state in `tilemap`.
- Keep validation limits, checked atlas arithmetic, object-archetype defaults, and typed-ref catalog snapshot semantics here.

## Files
- `mod.rs`, `tileset.rs`, `catalog.rs`: Atlas metadata, animation, autotile, and catalog state.
- `animation.rs`, `archetype.rs`, `autotile.rs`, `visual.rs`, `limits.rs`, `error.rs`: Local records, validation, ceilings, and structured errors.
- `AGENTS.md`: Reciprocal ownership boundary with `tilemap`.

## Rules
- `TileSet` describes what a GID means; it must not become a second owner of map cells or map-wide reverse indexes.
- Animation metadata is consumed by `tilemap` timers and render selection; tileset mutations must preserve stable GID ranges and metadata semantics.
- Autotile layout policy may be shared with `tilemap`, but map mutation and dirty propagation remain tilemap-owned.
- Lua-created instances must use checked construction and bounded mutation paths; errors crossing Lua include `lurek.tileset.<method>`.
- Archetypes describe defaults only; `physics`, `light`, `render`, and `tilefield` materialize their own runtime state.
- Catalogs intentionally clone tilesets as snapshots; do not introduce live shared handles without an explicit API/spec decision.

## Workflow
- Validate with the owning module tests and the tilemap tests when changing animation or autotile contracts.
- Run `cargo test --test tileset_tests`, the tileset security/stress Lua tests, and `tools\python.cmd tools\audit\audit_module.py tileset --docs-quality` for behavior changes.
