# Province module contract

## Mission & Scope

- Own province identifiers, topology, spans, borders, polygons, and province-facing Lua userdata.
- Keep `lurek.province.newGrid` as the canonical bounded GameFS constructor for province grids.

## Files

- `registry.rs` owns province registries and their state.
- `types.rs`, `render.rs`, and `routing.rs` own province semantics and rendering decisions.

## Rules

- `image` may supply decoded CPU pixels only; do not move province topology or `LuaProvinceGrid` state into image.
- Keep `lurek.image.newProvinceGrid` as a thin compatibility alias during its documented migration window.
- Use GameFS for Lua asset paths and preserve image decoder limits at the boundary.

## Workflow

- Sync province Lua APIs with examples, specs, and exact unit coverage.
- Validate ownership changes with targeted province and image audits.
