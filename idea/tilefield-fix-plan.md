# Tilefield module audit and fix plan

## Goal

Harden `tilefield` as the renderer-independent source of authoritative tile gameplay facts: independent channels, categories, costs/transmission, profiles/modifiers, author refs, regions, occupants/resources/buildability, dirty/version state, and field maps. Remove cross-system creation policy from its Lua edge and keep algorithms and presentation in their own modules.

## Current evidence

- Canonical domain code is `src/tilefield/*.rs`; public Lua binding is the 155 KB `src/lua_api/tilefield_api.rs`.
- Focused audits report 100% Lua unit ownership, 100% example coverage (99/99), 100% Lua spec coverage (99/99), clean unit structure, no unknown `@covers`, and no missing Lua API docstrings.
- Module quality still fails on structured Rust docs, six missing nested-field annotations, missing separators, three large binding closures, float `assert_eq!` warnings, low private-seam test ratio, and example/spec parser drift.
- `tests/rust/unit/tilefield_tests.rs` contains 15 tests, but six are actually tilelight propagation tests. Tilefield's true private-seam coverage is therefore lower than the report implies, and tilelight ownership is obscured.
- `tests/lua/stress/test_tilefield_stress.lua` has one `multi-api-body` contract violation.
- Evidence/golden/integration coverage is extensive, but there is no tilefield-specific hostile-input security suite.

## Required ownership boundary

| Concern | Owner | Tilefield rule |
|---|---|---|
| Cell storage, independent channels/categories, refs, regions, base facts, modifiers, dirty/version state | `tilefield` | Keep here. |
| Map visuals, projection, layers, chunks, rendering payloads | `tilemap` | Tilefield may expose refs/adapters, never draw. |
| Routes, ranges, flow fields, reachability | `pathfind` | Consume tilefield snapshots/handles. |
| Per-player visible/explored/action knowledge | `awareness` | Tilefield stores environmental inputs only. |
| Computed tile light and light-source lifecycle | `tilelight` | Tilefield stores blockers/transmission/sun inputs; source metadata only if clearly author data. |
| World/render lights and occluders | `light` | Runtime creation belongs to light or an integration adapter. |
| Physics bodies/colliders | `physics` | Runtime creation belongs to physics or an integration adapter. |
| Minimap/raycaster presentation | `minimap` / `raycaster` | Consume exports; no dependencies from tilefield core. |
| Procedural generation/map assembly | `procgen` / `mapblock` | Produce refs/base facts; tilefield does not generate policy. |

The functions `createPhysicsFromTileset` and `createLightsFromTileset` currently live in the tilefield Lua namespace and contain large cross-system workflows. Resolve this overlap explicitly. Preferred ownership is an integration adapter on the consuming module (`physics`/`light`) or a dedicated conversion facade, with compatibility aliases left in `tilefield` for one documented deprecation window. Do not move physics/light dependencies into `src/tilefield` because its contract forbids them.

## Findings and work order

### P0 - Bound memory, work, and hostile input

1. Introduce `TileFieldLimits` in `src/tilefield/limits.rs`.
   - Maximum cells per field, fields per field map, total cells across a field map, levels, categories, modifiers, slots, regions, cells per region, refs per cell, dirty rectangles, snapshot entries, provider rows, and string lengths.
   - Use `u64` checked products before `usize` conversion and allocation.
   - Avoid constructing every child field in `TileFieldMap::new` before checking aggregate cell cost.
2. Make Lua constructors/providers accept optional limits consistent with tilemap naming where concepts match, without sharing a type that creates ownership coupling.
3. Harden provider parsing and `restore` transactionally.
   - Validate complete shape, counts, ids, coordinates, topology, categories, modifiers, refs, and floats before replacing live state.
   - Reject duplicate/conflicting records deterministically.
   - Preserve the original field on error.
4. Validate every float as finite before range checks: costs, transmissions, filters, sun occlusion, modifier additions/multipliers, light-emitter metadata, and any adapter dimensions/origins.
5. Bound rectangular region expansion and explicit region-cell lists before allocation. Coalesce or cap dirty rectangles so repeated writes cannot grow an unbounded list.
6. Add checked version overflow semantics. Saturating forever at `u64::MAX` can stop consumers from detecting later changes; return an error, wrap with an epoch, or document an impossible-state policy and test it.

Acceptance: oversized fields/providers/snapshots/regions fail before large allocation or iteration; NaN/inf cannot enter domain state; failed restore/provider import leaves the prior state unchanged.

### P0 - Correctness and state invariants

1. Ensure all mutations update version and dirty state consistently.
   - Audit `clear`, category/profile/slot/region changes, snapshot restore, bulk layer imports, occupant/resource/buildability, refs, modifiers, and emitter changes.
   - `clear()` currently resets cells but must also define what happens to occupants/resources/buildability/regions and mark a full dirty volume if it is a full reset.
2. Define `beginEdit` semantics. It currently clears existing dirty rectangles; callers may accidentally discard unconsumed changes. Prefer a nested transaction/token or rename/document the destructive behavior.
3. Coalesce adjacent cell edits into bounded rectangles/chunks at commit time. Preserve deterministic ordering.
4. Enforce category independence in code, not only convention. Built-in channel aliases may map to categories, but no write in one channel may infer another.
5. Validate topology semantics for `square`, `square4`, `square8`, `iso_square`, and `hex`, including line symmetry, neighbors, ranges, negative Lua conversions, and level isolation.
6. Define occupant id zero, empty resource labels, default buildability, missing slot/ref, and removed modifier/profile semantics precisely.
7. Ensure a removed category/modifier/slot cleans or rejects dependent cell data instead of leaving unreachable state.
8. Audit snapshot determinism: sorted maps/sets, schema version, exact default omission rules, and forward-compatible unknown-field behavior.

### P0 - Resolve cross-module overlap

1. Move the 18/37/115-line registration workflows around `src/lua_api/tilefield_api.rs:3393`, `3433`, and `3479` out of registration closures.
2. Keep `fromTileMap` as a narrow explicit conversion adapter only if ownership is documented once. It must copy a snapshot, accept explicit mappings, and never infer gameplay policy from visuals unless the caller opts into named archetype defaults.
3. Move runtime physics/light object creation to the consuming owner or a dedicated integration owner.
   - Preserve old methods as thin forwarding compatibility aliases if breaking changes are not allowed.
   - Generated docs must mark canonical replacements and migration timing.
4. Keep tilefield emitter metadata only if it represents authored environmental source defaults. Runtime source ids, modulation, computed values, and propagation remain in `tilelight`.
5. Keep mapblock/procgen adapters conversion-only and benchmarked; policy stays in Lua/game code.

### P1 - Internal code quality and API ergonomics

1. Split the very large Lua binding by private concern without breaking API tooling: core field methods, category/modifier/ref conversion, snapshot conversion, field-map wrapper, and compatibility adapters.
2. Extract repeated one-based coordinate conversion and option parsing into tested binding helpers. Every error must include the exact public method.
3. Use slices/iterators internally and preallocate exports from checked cell counts.
4. Avoid cloning region properties and large support lists unless snapshot semantics require it.
5. Add bulk setters/getters for contiguous regions only when they reduce Lua crossings and reuse the same validation/dirty machinery; do not duplicate pathfinding/grid algorithms.
6. Review whether `occupants`, `resources`, and `buildable` belong as generic author facts or should be expressed as typed categories/properties. Keep them only if their optimized semantics are justified and documented.

### P1 - Tests and proof

1. Move tilelight propagation tests from `tests/rust/unit/tilefield_tests.rs` to `tests/rust/unit/tilelight_tests.rs`. Tilefield tests should retain only input/category semantics used by lighting.
2. Expand tilefield Rust tests for:
   - every limits ceiling and checked product;
   - category/channel independence and custom category removal;
   - modifier precedence and finite/range validation;
   - refs/slots cleanup and deterministic exports;
   - region bounds, deduplication, ordering, properties, and large-input rejection;
   - dirty/version behavior for every mutator, transaction nesting, coalescing, and overflow policy;
   - clear/reset semantics;
   - transactional snapshot restore and schema drift;
   - field-map aggregate limits, shared-handle replacement, topology/size mismatch;
   - square4/square8/iso/hex lines, neighbors, ranges, and level boundaries.
3. Replace exact float equality with epsilon assertions where arithmetic is involved. Exact constants may keep `assert_eq!` only with a clear reason.
4. Add `tests/lua/security/test_tilefield_security.lua`: huge dimensions, field-map multiplication, malformed providers/snapshots, duplicate records, non-finite costs/filters, huge regions/strings, invalid one-based coordinates, excessive dirty edits, and cross-type userdata.
5. Fix the stress `multi-api-body` violation by splitting canonical ownership or removing the heuristic conflict through a clearer scenario. Add bounded large-field mutation/export/restore/dirty-coalescing scenarios.
6. Keep unit ownership exactly one API per `it()`. Integration suites should own cross-module behavior and markers should match actual calls.
7. Keep evidence artifacts legible and module-owned; tilelight visuals belong to tilelight evidence even when tilefield supplies blockers.

### P1 - Docs, docstrings, specs, and examples

1. Rewrite generic file docs to describe concrete state/invariants, especially `field.rs`, `field_map.rs`, `cell.rs`, `semantics.rs`, and adapter boundaries.
2. Add structured docs for all D-03 types: category kinds/records, channels/cells, emitter/source records, field/map/region/ref/modifier/topology types.
3. Add source annotations for nested `radius`, `intensity`, and `color` fields and parser-recognized binding separators.
4. Investigate W-04. These names are nested light table fields, so repair the audit parser if it treats them as APIs. Never edit generated `docs/specs/tilefield.md` directly.
5. Update `docs/specs/manual/tilefield.md` with:
   - exact limits and transactional restore contract;
   - dirty/version semantics;
   - canonical ownership/migration for tilemap, physics, light, and tilelight adapters;
   - whether emitter data is authored metadata or runtime state;
   - clear/reset and missing/default semantics.
6. Review all 99 example blocks for meaningful standalone use. Teach checked, explicit adapters and independent channels; avoid presenting cross-module convenience aliases as tilefield core.
7. Regenerate docs after source annotations and API ownership changes.

### P2 - Useful non-duplicating feature gaps

Implement only with an approved owner decision:

1. Coalesced dirty-region diff export keyed by version for downstream pathfind/awareness/tilelight/minimap caches.
2. Immutable snapshots/read views for safe concurrent consumption; do not add threading policy to Lua bindings without an engine-wide design.
3. Schema-versioned plain-data export/import, while `serialize` owns encoding.
4. Typed generic cell attributes if they can replace special-case resource/buildable fields without making hot queries slower.
5. Bulk rectangular/category/ref operations that share validation and dirty tracking.
6. A narrow adapter registry for explicit conversions, only if it prevents duplicate adapters across modules and does not create dependency cycles.

Reject: route finding, FOV, remembered fog, light propagation, rendering, minimap drawing, physics simulation, procedural generation, or runtime light object ownership.

## Performance plan

- Add release baselines for field creation, field-map creation, cell mutation, category/modifier lookup, line/neighbors, region creation, snapshot/restore, export, and dirty coalescing.
- Measure sparse side maps (`occupants`, `resources`, `buildable`) against a generic cell-attribute alternative before refactoring.
- Ensure downstream adapters can process changes proportional to dirty regions rather than full volumes.
- Cap output allocations from exported layers and snapshots with limits.
- Add a tilefield-specific scenario to the perf gate; the current global 38.57% stress score is not module evidence.

## CAG and contract updates to include with implementation

1. Extend `review-all` with hostile input, bugs, feature gaps, overlap, file-level docs, and security checks.
2. Extend `review-api` to flag cross-module workflows in public namespace closures even if the generic thin-wrapper heuristic passes.
3. Extend `review-tests` to detect tests stored under the wrong module owner, not just marker completeness.
4. Extend `review-performance` to require module-specific allocation/work ceilings and downstream dirty-update behavior.
5. Update `src/tilefield/AGENTS.md` compactly:
   - add limits/transactional restore and dirty/version invariants;
   - state adapter ownership and no runtime physics/light creation in core;
   - name security/stress validation.
6. Add reciprocal one-line boundary rules to nearest physics/light/tilelight contracts only if their APIs become canonical owners. Do not expand root `AGENTS.md`.

## Implementation owners and sequence

1. `architect`: decide adapter and specialized-field ownership.
2. `developer`: limits, invariants, dirty/version logic, core refactor.
3. `lua_designer`: binding split, canonical/compatibility APIs, annotations.
4. `tester`: test relocation, Rust gaps, security, stress, integration/evidence ownership.
5. `content`: example updates after generated API changes.
6. `doc_writer`: manual spec and generated docs.
7. `cag_architect`: skill and contract improvements.
8. `reviewer`: verify no dependency/ownership regression and accept perf evidence.

## Verification

```powershell
tools\python.cmd tools\audit\audit_module.py tilefield --docs-quality
tools\python.cmd tools\audit\thin_wrapper_audit.py --scope tilefield --format text
tools\python.cmd tools\audit\docstring_audit.py --file src\lua_api\tilefield_api.rs --check
tools\python.cmd tools\audit\example_coverage.py --module tilefield --report --no-stubs --no-partials
tools\python.cmd tools\audit\unit_test_api_coverage.py --module tilefield --threshold 100
tools\python.cmd tools\audit\lua_spec_coverage.py --module tilefield --threshold 100
tools\python.cmd tools\audit\lua_nonunit_test_coverage.py --path tests\lua\stress\test_tilefield_stress.lua --heuristic-body-check
tools\python.cmd tools\audit\lua_evidence_golden_contract_audit.py
cargo test --test tilefield_tests
cargo test --test lua_tests
tools\python.cmd tools\audit\perf_regression_gate.py
cargo clippy -- -D warnings
tools\python.cmd tools\validate\cag_validate.py
tools\python.cmd tools\audit\cag_link_check.py --strict
```

## Done definition

- Construction, provider import, snapshot restore, and bulk expansion are bounded and transactional.
- Every mutation has defined dirty/version behavior.
- Cross-system runtime creation has one canonical owner and compatibility is explicit.
- Tilefield and tilelight tests live under the correct owners.
- Module audit passes, stress structure is clean, and public ownership remains 100%.
- Module-specific performance and hostile-input evidence exists.
