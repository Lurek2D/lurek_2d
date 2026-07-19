# Tileset module audit and fix plan

## Goal

Harden `tileset` as the reusable owner of atlas-local tile metadata, object archetypes, tile animation metadata, autotile rules, terrain profiles, and typed-ref catalogs. Preserve a clean boundary with `tilemap`, `tilefield`, `sprite`, `animation`, `physics`, `light`, `image`, and `render`.

This is an implementation plan, not a statement that every candidate feature must be added. Luna should implement confirmed defects first, measure performance work, and reject any feature that duplicates a neighboring module.

## Current evidence

- Canonical engine code: `src/tileset/*.rs`; Lua edge: `src/lua_api/tileset_api.rs`.
- Public lifecycle files exist: `docs/specs/manual/tileset.md`, generated spec/module pages, `content/examples/tileset.lua`, and `tests/lua/unit/test_tileset_unit.lua`.
- Focused audits currently report 100% Lua unit ownership, 100% example coverage (46/46), 100% generated Lua spec coverage (46/46), no Lua test-structure errors, no unknown `@covers`, and no missing Lua API docstrings.
- The module quality report still fails on structured Rust docs, missing Lua `@param`/`@return` metadata, missing binding separators, one binding closure containing domain logic, no Rust private-seam test owner, and a parser-level example/spec mismatch.
- The master quality and perf gates pass globally, but neither proves tileset-specific hostile-input safety or hot-path behavior.

## Required ownership boundary

| Concern | Owner | Tileset rule |
|---|---|---|
| Atlas geometry, tile properties, local animation frames, tile archetypes, terrain/autotile rule metadata | `tileset` | Keep here. |
| Map layers, chunks, placement, coordinate transforms, application of autotile rules, render-command assembly | `tilemap` | Tileset supplies metadata only. |
| Gameplay blockers, costs, refs, regions, runtime modifiers | `tilefield` | Archetypes may carry author defaults, but tilefield owns materialized gameplay state. |
| General sprite animation timelines and entities | `sprite` / `animation` | Tileset animation remains tile-id/frame-duration metadata only. |
| Physics bodies, render lights, occluders | `physics` / `light` | Archetypes describe defaults; integration owners instantiate runtime objects. |
| Textures, handles, loading, GPU lifetime | `asset` / `image` / `render` | Store identifiers and rectangles only; never own GPU resources. |

Keep the existing `lurek.tilemap.newTileSet` compatibility alias during migration, but document `lurek.tileset.newTileSet` as canonical and add a deprecation path rather than maintaining two independent implementations.

## Findings and work order

### P0 - Constructor and arithmetic safety

1. Add a validated `TileSet::try_new` path in `src/tileset/tileset.rs` and make both `lurek.tileset.newTileSet` and provider parsing use it.
   - Reject zero `tile_count`, `columns`, `tile_width`, and `tile_height` unless an explicit empty-tileset use case is proven.
   - Use checked arithmetic for texture dimensions and source-quad coordinates; never rely on release wrapping or debug panics.
   - Define conservative ceilings for tile count, atlas dimensions, spacing, margin, archetype count, properties, animation frames, and autotile rules. Put the limits in a tileset-owned type rather than reusing tilemap limits accidentally.
   - Return errors containing `lurek.tileset.<method>` at the Lua boundary.
2. Validate every local tile id at mutation time.
   - `set_animation`, `set_property`, `set_auto_tile_rule`, `set_auto_tile_rule_8`, terrain-profile defaults, and provider records must reject ids outside `0..tile_count`.
   - Validate animation frame tile ids and require finite, positive durations.
   - Validate non-empty normalized names for autotile types, terrain profiles, catalog ids, properties, slots, and archetypes.
3. Add a fallible quad query.
   - Rust: `try_get_quad(local_tile_id) -> Result<Rect, TilesetError>`.
   - Lua: prefer either an erroring canonical `getQuad` or a clearly named `tryGetQuad`; do not silently return a plausible rectangle for an invalid id.
4. Replace free-form `String` errors with a small `TilesetError` enum where errors cross multiple methods. Preserve precise Lua-facing messages.

Acceptance: zero/overflow-sized constructors, invalid ids, non-finite durations, and excessive provider collections fail before allocation-heavy or arithmetic work; valid legacy calls remain compatible.

### P0 - Numeric and archetype validation

1. Centralize validation in `src/tileset/archetype.rs` for all author defaults.
   - Finite non-negative light radii/intensities; finite clamped color components.
   - Positive bounded footprint dimensions.
   - `sun_occlusion`, occluder opacity, friction, restitution, density, and optional mass must be finite and in documented ranges.
   - Validate body type, blend mode, falloff, and light type using the owning module's accepted enum vocabulary or leave them opaque only if downstream validation is guaranteed.
2. Make provider parsing transactional: parse and validate into a new `TileSet`, then publish it. A late invalid field must not leave partially installed data.
3. Bound nested Lua tables and string sizes to prevent memory-amplification from untrusted providers.

### P1 - Thin Lua binding and code quality

1. Move catalog construction/validation from the closure around `src/lua_api/tileset_api.rs:1426` into tileset-owned helpers. The Lua file should only convert tables, invoke engine helpers, and wrap userdata.
2. Split the very large binding file into private registration/helper sections only if supported by current Lua API tooling; do not break the canonical `src/lua_api/tileset_api.rs` owner path.
3. Avoid lookup allocations in `get_auto_tile_id` and `get_auto_tile_id_8`: use borrowed-key compatible storage or a two-level map keyed by type name, then bitmask. Benchmark before choosing the representation.
4. Return borrowed slices instead of `Option<&Vec<TileAnimFrame>>` in Rust.
5. Decide whether catalog entries intentionally clone full tilesets. If shared live updates are desired, introduce immutable/shared handles; if snapshot semantics are desired, document and test the clone behavior. Do not change semantics silently.
6. Keep stable sorted catalog/archetype name output and test it.

### P1 - Tests and reliability proof

1. Create `tests/rust/unit/tileset_tests.rs` and register it in the Rust test target if required.
2. Cover private/domain seams:
   - checked atlas arithmetic and exact texture dimensions;
   - local/global id boundaries and first-gid overflow;
   - animation validation and deterministic frame metadata;
   - property insert/remove cleanup;
   - 4-way and 8-way autotile lookup without per-query allocation regressions;
   - archetype removal detaches tile mappings;
   - catalog resolution for tile refs and object refs;
   - clone/snapshot semantics;
   - every numeric validation edge, including NaN and infinities.
3. Add `tests/lua/security/test_tileset_security.lua` for oversized provider tables, malformed nested records, invalid ids, huge strings, zero dimensions, and non-finite floats. Use one `@security` owner per `it()`.
4. Retain one canonical Lua unit owner per public API. New APIs must first enter generated API data, then receive one example block and one `@covers` test.
5. Add a modest stress suite for large but allowed catalogs/rule tables. Assert a documented ceiling and stable completion; do not use wall-clock-only flaky assertions.
6. Add evidence/golden output only if it demonstrates atlas rectangle or animation-frame correctness visually. Do not create decorative snapshots.

### P1 - Documentation, docstrings, specs, and examples

1. Rewrite generic file docs in `src/tileset/*.rs` to state specific owned state, invariants, errors, allocation behavior, and neighbor boundaries.
2. Add structured `# Fields` / `# Variants` sections for the types named by D-03, including `TileAnimFrame`, archetype structs/enums, `TileSet`, `TileCatalog`, `TerrainProfile`, and `TileVisual` as required by the audit.
3. Complete source-owned Lua `@param`/`@return` annotations and add parser-recognized section separators in `src/lua_api/tileset_api.rs`.
4. Investigate W-04 before editing generated specs. `image`, `order`, `radius`, `sprite`, and `mask` appear to be nested table fields, so the audit may be confusing fields with API symbols. Fix the audit parser if confirmed; otherwise fix source docstrings/examples. Never hand-edit `docs/specs/tileset.md`.
5. Update `docs/specs/manual/tileset.md` with:
   - validation limits and error policy;
   - snapshot/shared catalog semantics;
   - canonical namespace and legacy alias timeline;
   - explicit local tile animation versus general animation boundary.
6. Keep `content/examples/tileset.lua` at one marker-owned standalone block per API. Add failure examples only when the example contract supports them; hostile input belongs in tests.
7. Regenerate API, module, and spec outputs after source doc changes.

### P2 - Useful non-duplicating feature gaps

Implement only after P0/P1 and an API review:

1. Deterministic serialization of tileset metadata to/from plain data for save/editor pipelines, provided `serialize` owns encoding and tileset only exports/imports its schema.
2. Read-only iterators or bulk export for animation/rule/property metadata to avoid repeated Lua crossings in tooling.
3. Optional immutable/frozen tilesets for safe sharing across maps and catalogs, if profiling shows clone cost or mutation ambiguity.
4. Explicit GID/local-id conversion helpers with overflow errors. Do not duplicate tilemap placement or importer logic.
5. Versioned provider schema diagnostics listing the exact failing path, useful for editors and mod content.

Reject: runtime pathfinding rules, materialized blockers, entity animation controllers, texture loading, GPU upload, physics/light creation, or map placement.

## Performance plan

- Add Criterion-free deterministic microbench/report coverage using existing repo perf tooling for rule lookup, catalog resolution, provider parsing, and large name-list export.
- Record dataset size, allowed ceiling, allocation count where tooling permits, and baseline environment.
- Eliminate per-lookup `String` creation in autotile lookups if measurement confirms it.
- Avoid cloning full archetypes/tilesets on hot render queries; return borrowed data internally and convert only at Lua boundaries.
- Add a tileset scenario to the stress report before tightening performance gates.

## CAG and contract updates to include with implementation

1. Update `.codex/skills/review-all/SKILL.md` so future broad module reviews explicitly include security/hostile-input analysis, feature-gap/non-duplication review, file-level docs, numeric/allocation ceilings, and cross-module ownership decisions. Keep it a checklist/link addition, not copied module policy.
2. Update `.codex/skills/review-api/SKILL.md` to require nested option-table field validation and compatibility-alias ownership checks.
3. Update `.codex/skills/review-performance/SKILL.md` to require a module-specific scenario; a global passing perf gate is not sufficient evidence.
4. Add `src/tileset/AGENTS.md` because the module currently lacks a nearest contract. Keep it similar in size to `src/tilemap/AGENTS.md`: mission, files, 4-6 durable rules, and focused validation commands.
5. Do not enlarge root `AGENTS.md` with tileset details. Update `src/tilemap/AGENTS.md` only to state that tileset creation metadata is owned by `tileset` and the tilemap alias is compatibility-only.
6. Run CAG validation and strict link checking after guidance changes. Existing unrelated broken links must be reported separately, not hidden in this work.

## Implementation owners and sequence

1. `developer`: P0 core types, limits, errors, and Rust tests.
2. `lua_designer`: thin bindings, source docstrings, generated API parity, compatibility alias.
3. `tester`: Lua unit/security/stress/evidence ownership.
4. `content`: example blocks after API generation.
5. `doc_writer`: manual spec and regenerated docs.
6. `cag_architect`: skill and nearest `AGENTS.md` updates.
7. `reviewer`: rerun audits, performance evidence, and boundary review.

## Verification

```powershell
tools\python.cmd tools\audit\audit_module.py tileset --docs-quality
tools\python.cmd tools\audit\thin_wrapper_audit.py --scope tileset --format text
tools\python.cmd tools\audit\docstring_audit.py --file src\lua_api\tileset_api.rs --check
tools\python.cmd tools\audit\example_coverage.py --module tileset --report --no-stubs --no-partials
tools\python.cmd tools\audit\unit_test_api_coverage.py --module tileset --threshold 100
tools\python.cmd tools\audit\lua_spec_coverage.py --module tileset --threshold 100
tools\python.cmd tools\audit\lua_test_structure_audit.py --path tests\lua\unit\test_tileset_unit.lua
cargo test --test tileset_tests
cargo test --test lua_tests
cargo clippy -- -D warnings
tools\python.cmd tools\validate\cag_validate.py
tools\python.cmd tools\audit\cag_link_check.py --strict
```

## Done definition

- All confirmed P0/P1 findings are fixed or explicitly rejected with evidence.
- Quality report for `tileset` passes without suppressing valid checks.
- Public API/example/unit/spec ownership remains exactly 100%.
- Hostile inputs fail deterministically before large allocations or wrapped arithmetic.
- Scope and compatibility ownership are documented and tested.
- Performance claims have module-specific evidence.
