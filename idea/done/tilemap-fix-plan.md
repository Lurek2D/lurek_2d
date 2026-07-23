# Tilemap module audit and fix plan

## Goal

Make `tilemap` a safe, incremental, and well-bounded owner of visual tile-grid storage, layers, chunks, imports, projection/coordinate helpers, autotile application, render payload assembly, and map diagnostics. Remove ambiguous internal duplication and keep gameplay semantics in `tilefield`, algorithms in their specialist modules, and GPU execution in `render`.

## Current evidence

- Canonical code spans `src/tilemap/*.rs`; public Lua binding is `src/lua_api/tilemap_api.rs`.
- Focused audits report 100% Lua unit ownership, 100% example coverage (135/135), 100% Lua spec coverage (135/135), clean example structure, clean unit structure, and a clean thin-wrapper heuristic.
- `audit_module` still fails with: missing structured Rust doc sections, five missing Lua annotation fields, missing binding separators, five substantial registration closures, example/spec parser drift, and two `unwrap()` findings in chunk decoding.
- `tests/rust/unit/tilemap_tests.rs` has broad private-seam coverage; Lua evidence/golden and six stress owners exist.
- The global perf gate passes, but it does not isolate dense map, chunk streaming, reverse-index, importer, or render-command costs.
- Existing security coverage checks one invalid `LTileMap:getTile` case; it is not a complete hostile importer/allocation suite.

## Required ownership boundary

| Concern | Owner | Tilemap rule |
|---|---|---|
| Dense/sparse visual tile ids, layers, chunks, orientations, projections, regions, imports, render payloads | `tilemap` | Keep here. |
| Atlas-local meanings, archetypes, tile animation metadata, autotile rule tables | `tileset` | Consume by reference; do not reimplement. |
| Gameplay blockers/costs/refs/modifiers | `tilefield` | Adapter may copy explicit data; never infer policy silently. |
| Routing, FOV/awareness, environment lighting, minimap aggregation | `pathfind`, `awareness`, `tilelight`, `minimap` | Tilemap supplies coordinates/visual data only. |
| Procedural generation and block assembly | `procgen`, `mapblock` | Accept exported tiles; do not own generation policy. |
| Shader validation, pipelines, GPU resources, frame execution | `render` | Store handles and emit commands only. |

Within `tilemap`, explicitly resolve the overlap among `TileMap`, `ChunkMap`, and `LargeMapRenderer`: `TileMap` is layered dense visual state, `ChunkMap` is sparse/streamed tile storage, and `LargeMapRenderer` should be a render cache/view over an authoritative store. It must not remain a second independently mutable full map unless that distinction is justified and tested.

## Findings and work order

### P0 - Remove unsafe allocation and arithmetic paths

1. Route every public constructor/mutator through `TileMapLimits`.
   - `LargeMapRenderer::new`, `set_map_data`, `set_chunk_size`, camera/viewport setters, LOD thresholds, and Lua counterparts currently lack the same checked ceilings used by safe `TileMap` and `ChunkMap` paths.
   - Replace `(width * height) as usize`, `y * width + x`, chunk-count multiplication, and coordinate/pixel multiplication with checked `u64`/`usize` helpers.
   - Reject mismatched input data lengths or document padding/truncation explicitly; do not silently resize hostile payloads without a bounded policy.
2. Validate all floats crossing Lua: viewport size, camera zoom, offsets, parallax, layer colors/tints, tile sizes used in projection, LOD thresholds, and `dt`.
   - Require finite values and positive zoom/tile sizes where division occurs.
   - Sort/deduplicate LOD thresholds or reject unordered data; document semantics.
3. Audit legacy no-op/default methods (`setTile`, `getTile`, layer accessors, `worldToTile`) against their `try*` variants.
   - Keep compatibility behavior only when documented and diagnostics are incremented.
   - Prefer checked methods in new docs/examples.
4. Harden chunk binary decoding.
   - The two `try_into().unwrap()` calls are length-proven after checks, so they are not currently exploitable, but replace them with explicit four-byte copies or mapped errors to satisfy the no-panic contract and avoid audit noise.
   - Add a format version, reserved flags, and exact endianness documentation before evolving the binary format.
   - Enforce configured chunk and byte ceilings before allocating.
5. Add importer corpus limits to every TMX and LDtk path, including nested object/property counts, decompressed layers, external references, path normalization, XML nesting/entity behavior, and JSON nesting.
6. Ensure `TileMapLimits` itself rejects nonsensical configurations (zero ceilings, internally inconsistent decoded/raw limits, values exceeding addressable memory).

Acceptance: all Lua-reachable size/count/float inputs either pass documented bounds or return `lurek.tilemap.<method>` errors before expensive work; no release-wrap, debug-only invariant, or allocation panic is part of normal error handling.

### P0 - Resolve duplicated state and stale-cache risks

1. Decide and document the source of truth for large maps.
   - Preferred: make `LargeMapRenderer` consume `TileMap`/`ChunkMap` snapshots or shared read handles and own only visible chunk render caches.
   - Alternative: rename it to clearly describe an independent dense map and explain why duplication is necessary. Do not expose two interchangeable mutable map types.
2. Add invariant tests for cache invalidation after `setTile`, bulk writes, layer changes, chunk load/unload, tileset changes, viewport changes, orientation changes, shader changes, and LOD changes.
3. Make dirty regions/chunks first-class outputs and avoid whole-cache rebuilds for local edits.
4. Verify reverse-index eager/lazy transitions:
   - switching policies cannot serve stale results;
   - duplicate positions are never inserted;
   - `fill`, clear, imports, and bulk edits invalidate exactly once;
   - diagnostic counters are deterministic.
5. Prevent animation timers from retaining dead GIDs after layers/tilesets change, and cap the catch-up loop for long `dt` without changing valid frame results.

### P1 - Thin binding and internal modularity

1. Extract domain work from the registration closures around `src/lua_api/tilemap_api.rs:1768`, `1793`, `1943`, `2020`, and `2054`.
   - Candidate helpers belong in `autotile_sheet.rs`, import adapters, tilefield render adapters, or a dedicated tilemap conversion file.
   - Lua closures should parse options, call helpers, and wrap results.
2. Keep `LuaUserData::add_methods` registration-only. Move repeated one-based conversion, options parsing, diagnostics table construction, and render-option materialization to small binding helpers.
3. Break up `tilemap.rs` only along stable responsibilities: layer storage/index, animation state, projection, and autotile application. Avoid a cosmetic split that creates cyclic coupling.
4. Return borrowed/internal iterators where possible; convert to Lua tables once. Avoid cloning the entire reverse index for a single GID query.
5. Preallocate render command vectors from the visible tile estimate and reuse temporary buffers in field-slot/catalog render adapters.

### P1 - Correctness coverage

1. Extend Rust tests with focused groups:
   - checked arithmetic and every `TileMapLimits` ceiling;
   - dense/sparse negative coordinates and chunk boundaries;
   - chunk serialization corruption, version mismatch, truncation, excess bytes, and oversized headers;
   - TMX/LDtk malformed, compressed, oversized, external-path, unknown-GID, flipped-tile, object-layer, and orientation cases;
   - orthogonal/isometric/hex round trips, negative/non-finite picking, tile boundaries, and large coordinates;
   - lazy/eager index equivalence after randomized deterministic edits;
   - local dirty invalidation and render-cache coherence;
   - animation zero/invalid duration policy and long-frame catch-up;
   - shader handle fallback and layer override precedence.
2. Add `tests/lua/security/test_tilemap_security.lua` for importer bombs, path traversal options, huge layer dimensions, huge chunk sizes, malformed chunk bytes, NaN/infinite numeric options, excessive LOD thresholds, and mismatched map data.
3. Expand stress ownership beyond six API markers with scenarios for:
   - million-cell allowed dense map edits and lookups;
   - sparse far-negative/far-positive chunk coordinates;
   - viewport culling proportional to visible chunks;
   - large reverse-index rebuilds;
   - bounded importer decode.
4. Keep current evidence/golden coverage for projection, layers, hex, isometric, chunk streaming, collisions, draw-to-image, autotile, and shader bindings. Rebaseline only for intentional output changes.
5. Add property-based deterministic round-trip tests using existing Rust test patterns; do not introduce a heavy dependency unless approved.

### P1 - Docs, docstrings, specs, and examples

1. Replace generic file docs with precise ownership/invariant text, especially for `tilemap.rs`, `large_map_renderer.rs`, importers, render adapters, and limits.
2. Add structured `# Fields` / `# Variants` sections for all D-03 types, including `AutoTileLayout`, `AutoTileSheet`, `ChunkMap`, `TileMapError`, isometric types, layer/map diagnostics, limits, renderer cache types, and importer models.
3. Add missing source annotations for `invalidLayer`, `invalidCoord`, `unknownGid`, `invalidQueries`, and `lazyIndexRebuilds`, plus parser-recognized binding separators.
4. Investigate W-04 before editing generated output. `invalidLayer` and `invalidCoord` are diagnostics table fields, not necessarily API functions. Fix the audit parser if it confuses nested fields with methods. Never hand-edit `docs/specs/tilemap.md`.
5. Update `docs/specs/manual/tilemap.md` with:
   - the authoritative-store distinction among `TileMap`, `ChunkMap`, and render caches;
   - exact limits and importer security policy;
   - dirty/index consistency guarantees;
   - coordinate edge semantics and valid float ranges;
   - compatibility status of `lurek.tilemap.newTileSet`.
6. Review 135 example blocks for usefulness, not just marker count. Each should demonstrate one concrete call and avoid teaching legacy unsafe/default behavior when a checked alternative exists.
7. Regenerate docs and run smoke coverage after source changes.

### P2 - Useful non-duplicating feature gaps

Implement only after profiling and boundary review:

1. A unified bulk-edit transaction (`beginEdit`/`commitEdit`) returning coalesced dirty rectangles/chunks. It belongs in tilemap storage, not gameplay state.
2. Stream-provider callbacks for loading/unloading chunk payloads, while filesystem/network ownership remains outside tilemap.
3. Read-only map/layer snapshots with schema version for editor/save integration; `serialize` owns encoding.
4. Explicit tilemap-to-tilefield diff adapter that copies changed explicit refs/blocker mappings without live subsystem coupling. The adapter owner must be decided once; do not duplicate it in both modules.
5. Import diagnostics with source positions and recoverable warnings.
6. Render batching metadata that reduces commands without owning GPU pipelines.

Reject: pathfinding, fog ownership, awareness masks, computed lighting, procedural generation policy, physics legality, or GPU resource management.

## Performance plan

- Add module-specific baselines for dense mutation, chunk streaming, culling, reverse-index rebuild/query, import/decompression, render-command generation, and animation update.
- Report complexity and allocation behavior for each scenario.
- Require local edits to scale with affected chunks/regions, not total map size.
- Remove the duplicate full-map copy in `LargeMapRenderer` if measurements and ownership review support the preferred design.
- Reuse output buffers and reserve from visible estimates; verify no regression in golden output.
- Run release-mode stress/perf gates and store scratch reports only under `work/tilemap-review/`.

## CAG and contract updates to include with implementation

1. Extend `review-all` with explicit security, bug, feature-gap, file-doc, and module-overlap checkpoints.
2. Extend `review-performance` so global gate success cannot substitute for module-specific hot-path scenarios.
3. Extend `review-api` to compare legacy aliases, table-field annotations, fallible/legacy pairs, and numeric ceilings.
4. Update `src/tilemap/AGENTS.md` while keeping it compact:
   - define `TileMap`/`ChunkMap`/render-cache ownership;
   - require all public allocations to use `TileMapLimits`;
   - require dirty updates to stay local;
   - name focused Rust/Lua/security/perf validation.
5. Update `src/tileset/AGENTS.md` (created by the tileset plan) with reciprocal autotile/metadata ownership.
6. Do not put module details in root `AGENTS.md`. Keep nearest contracts within the existing short contract style.

## Implementation owners and sequence

1. `architect`: approve internal source-of-truth and adapter ownership decisions.
2. `developer`: safety, cache/index correctness, module refactor, importer hardening.
3. `lua_designer`: thin wrappers, compatibility API, source annotations.
4. `tester`: Rust, Lua security, stress, evidence/golden maintenance.
5. `content`: improve example blocks after API data stabilizes.
6. `doc_writer`: manual spec and regenerated docs.
7. `cag_architect`: skills and nearest contracts.
8. `reviewer`: focused audit and performance acceptance.

## Verification

```powershell
tools\python.cmd tools\audit\audit_module.py tilemap --docs-quality
tools\python.cmd tools\audit\thin_wrapper_audit.py --scope tilemap --format text
tools\python.cmd tools\audit\docstring_audit.py --file src\lua_api\tilemap_api.rs --check
tools\python.cmd tools\audit\example_coverage.py --module tilemap --report --no-stubs --no-partials
tools\python.cmd tools\audit\unit_test_api_coverage.py --module tilemap --threshold 100
tools\python.cmd tools\audit\lua_spec_coverage.py --module tilemap --threshold 100
tools\python.cmd tools\audit\lua_nonunit_test_coverage.py --path tests\lua\stress\test_tilemap_stress.lua --heuristic-body-check
tools\python.cmd tools\audit\lua_evidence_golden_contract_audit.py
cargo test --test tilemap_tests
cargo test --test lua_tests
tools\python.cmd tools\audit\perf_regression_gate.py
cargo clippy -- -D warnings
tools\python.cmd tools\validate\cag_validate.py
tools\python.cmd tools\audit\cag_link_check.py --strict
```

## Done definition

- All allocation, arithmetic, importer, and float inputs are bounded and fallible.
- `TileMap`, `ChunkMap`, and large-map render cache roles are unambiguous and tested.
- Local changes invalidate only affected state.
- Module quality passes without masking parser defects.
- Lua unit/example/spec coverage remains exactly 100% and evidence/goldens are intentional.
- Module-specific release performance evidence meets documented thresholds.
