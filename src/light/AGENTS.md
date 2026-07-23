# Light Module Contract

## Mission & Scope
- `light` owns authoritative 2D light, occluder, group, flicker, transition, and renderer-ready snapshot state.
- `render` owns GPU pipelines, texture binding, and command submission; `light` never loads textures or compiles shaders.
- `tilefield` supplies authored tile facts, `tilelight` owns grid propagation, and `awareness` owns gameplay visibility.

## Files

- `light2d.rs`, `occluder.rs`, `limits.rs`, and `light_world.rs` own per-light data, geometry, ceilings, and scene snapshots.
- `debug_image.rs` owns only bounded CPU preview/evidence rasterization; it must borrow scene data rather than duplicate it.
- `src/lua_api/light_api.rs` owns conversion and registration; `src/lua_api/tilefield_api.rs` provides the tile metadata adapter only.

## Rules
- Validate every Lua-reachable number as finite before mutation; reject invalid state rather than silently repairing it.
- `LightLimits` must bound stored lights, occluders, vertices, hint exports, and preview allocation/work before iteration or allocation.
- `max_lights` is renderer selection only, never a storage limit. Selection must remain deterministic.
- Constructors and bulk adapters are transactional: a rejected operation leaves world counts and existing handles unchanged.
- Occluder geometry uses checked constructors; no Lua-reachable path may panic.
- Keep cookies and transitions on authoritative `Light2D`/`LightWorld` state, not per-handle wrappers.

## Workflow
- Add Rust tests for domain limits and lifecycle invariants, plus Lua security/stress proof for public paths.
- Run `cargo test --test light_tests` and the light Lua coverage/security targets after behavioral changes.
