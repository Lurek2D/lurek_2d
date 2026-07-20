# Physics module audit and fix plan

## Goal

Harden `physics` as the single 2D simulation and spatial-query authority: rigid bodies, fixtures, joints, zones, contacts, fixed stepping, collision policy, flow fields, 2.5D altitude, destructible terrain, and finite-volume grid liquids. Make every Lua-reachable workload bounded, preserve deterministic event semantics across substeps, and keep rendering, tile data, general pathfinding, and gameplay projectile policy outside the core.

## Current evidence

- Canonical code spans `src/physics/*.rs` plus `src/physics/world/*.rs`; `src/lua_api/physics_api.rs` is 6,271 lines. `src/physics/AGENTS.md` exists but documents only the high-level Rapier/fixed-step/tilefield boundary.
- Focused audits report 326/326 generated Lua APIs in specs and 326/326 exact Lua unit owners, structurally clean examples, and all 28 namespace functions represented in the module example.
- `cargo test --test physics_tests` passes 103/103. The module audit still reports only 103 Rust tests for roughly 370 public methods, exact float assertions at lines 165, 166, 171, 172, and 180, and no physics security suite.
- `tests/lua/stress/test_physics_stress.lua` has 11 valid stress owners. Evidence/golden contracts pass. `tests/lua/security/test_physics_security.lua` is absent.
- `thin_wrapper_audit.py --scope physics` reports the binding as SUSPECT (six long closures, ten hotspots, one standard-collection signal). `audit_module.py` identifies large closures near lines 5845, 6036, and 6125.
- Lua spec coverage is 100%, but doc audits report one missing binding description, more than 150 suspected missing `@param/@return` records, and structured-doc gaps across at least 37 public types. These counts must be verified against parser treatment of nested `@field` lines.
- The global perf gate passes, but no baseline proves body/fixture/joint ceilings, fixed-step catch-up, query output size, terrain rebuild budgets, or liquid active-cell budgets under this module.

## Required ownership boundary

| Concern | Canonical owner | Physics rule |
|---|---|---|
| Bodies, fixtures, joints, contacts, collision filters, stepping, spatial queries | `physics` | Keep one authoritative world and deterministic IDs/events. |
| Destructible collision terrain and collider rebuild state | `physics` | Own physical occupancy/colliders; do not become a visual tilemap. |
| Finite-volume liquid grid and body-force sampling | `physics` | Keep conservative cell volume here; VFX rendering belongs elsewhere. |
| Authored force/flow volumes affecting bodies | `physics` | `flow` means physical acceleration/drag, not graph/network flow. |
| Tile cell facts and tileset physics metadata | `tilefield` / `tileset` | Consume through the canonical physics adapter. |
| Tilefield-to-body conversion | `physics` | `lurek.physics.createBodiesFromTilefield` is canonical; tilefield forwards only. |
| Draw commands, GPU buffers, debug presentation | `render` | Physics emits bounded shape snapshots; render draws them. |
| CPU alpha masks | `image` | Physics may infer a collision shape from a supplied image snapshot; it does not own image loading/effects. |
| Gameplay projectile state/damage/weapon policy | game code / relevant feature owner | Physics owns casts, CCD, reflection math, and bodies only. |
| Navigation/reachability | `pathfind` | Consume collision snapshots; never place routing algorithms in physics. |
| Scene activation/lifecycle | `scene` | Scene decides which world is active; physics owns world consistency. |

Altitude remains a physics collision sidecar only. It must not grow into a second scene transform hierarchy or general 3D renderer.

## Findings and work order

### P0 - Enforce limits that already exist

1. Make `PhysicsLimits.max_bodies` real.
   - `World::add_body` currently appends unconditionally; the declared body ceiling is used by query validation but not creation.
   - Add `try_add_body` returning `PhysicsError::CountLimitExceeded`, and route every Lua constructor, batch path, terrain/debris spawn, ballistic spawn, and adapter through it.
   - Count active bodies and backing slots separately. Current tombstoned vectors grow forever; use a generation-safe reusable slot/free-list or `SlotMap`, or set a lifetime slot ceiling in addition to active-body ceiling.
2. Make every batch transactional and bounded.
   - `World::add_bodies` and `LWorld:newBodies` currently parse/collect an unbounded table and use infallible `Body::new`.
   - Preflight table length, checked aggregate fixture cost, all dimensions/types/floats, and remaining capacity; create nothing on any invalid entry.
3. Add ceilings for currently unbounded controls: fixed steps per call, solver iterations, CCD substeps, contact events, query hits, beam bounces/segments, ballistic samples, flow/gravity vectors, terrain debris bodies, and debug snapshot/output shapes.
   - `setSolverIterations` and `setCcdSubsteps` only clamp their minimum and can request pathological work.
   - `stepFixed(..., maxSteps)` accepts an arbitrary `u32`; cap it before entering the loop.
4. Review every `PhysicsLimits` field for enforcement on every constructor/mutator. Add a table-driven Rust test that fails when a declared limit has no reachable guard.
5. Ensure custom limits survive the intended lifecycle. `reset_world` reconstructs a default `World`; specify whether custom limits reset or persist and test it. `clear` must preserve limits and configuration as documented.

Acceptance: no public path can exceed body/joint/zone/fixture/query/step ceilings; batch and adapter failures are atomic; repeated create/destroy cannot grow tombstone storage without a bound.

### P0 - Fixed-step correctness and deterministic events

1. Replace the current ambiguous `step` clamp contract.
   - `World::step(dt)` silently reduces values above `max_step_dt`, losing simulation time while the Lua docs say it advances by the supplied delta.
   - Preferred contract: strict `try_step(dt)` reports invalid/oversized input; frame pacing uses `step_fixed`. If a compatibility `step` clamps, return diagnostics that expose consumed and discarded time and document it.
2. Fix `step_fixed` validation.
   - Enforce `min_step_dt <= step_dt <= max_step_dt`, finite accumulated time, and bounded `max_steps`.
   - Avoid lossy float-to-`u32` conversion before checking the ratio.
   - Define backlog policy explicitly: carry all remainder, cap accumulated backlog, or report dropped time; never silently vary it.
3. Preserve contact events across all substeps.
   - `World::step` clears event arrays each call, so `step_fixed` currently retains only the final substep's begin/end contacts.
   - Accumulate/de-duplicate events in deterministic order for the whole public call, including begin+end within the same frame.
4. Dispatch Lua callbacks consistently. `LWorld:step` fires begin/end callbacks; `LWorld:stepFixed` calls the core helper and fires none. Share one post-step callback dispatcher and define callback error behavior.
5. Protect callback reentrancy. Continue releasing world borrows before Lua calls; snapshot event payloads first, bound callback count, and document whether callbacks may mutate/destroy bodies safely for the next step.
6. Test determinism at multiple render-delta sequences, fixed step sizes, max-step saturation, sleeping/CCD bodies, zones, flows, altitude, and ballistic sidecars.

### P0 - Numeric, geometry, and query safety

1. Validate all Lua-facing floats before core mutation: forces, impulses, velocity, angles, damping, meter scale, solver settings, wrap bounds, materials, joints, query geometry, normals, zones, flows, terrain/liquid options, and altitude data.
   - `setMeter` currently accepts zero, negative, NaN, or infinity and can corrupt conversions.
   - Core helpers such as `apply_force` should have strict variants; silent `record_invalid_operation` wrappers are compatibility-only.
2. Replace remaining unchecked casts from Lua numbers to `usize`/IDs. For example, optional `excludeBody` accepts non-negative f64 and casts directly; require integral values within `usize` and active-ID policy.
3. Standardize strict/fallible API pairs. Public Lua must return named errors for invalid body/joint/fixture references where mutation was requested; reserve `nil` for query-style absence, not silent failed writes.
4. Remove slice `unwrap()` calls in terrain/liquid deserialization even where preceding length checks currently make them safe. Use fixed-array readers so audit output and future format changes cannot reintroduce panics.
5. Audit shape and query degeneracy: zero-length rays/normals, collinear chains, duplicate/self-intersecting polygons, extreme coordinates, invalid mass/density, thick beam requests, wrap bounds with zero extent, and filter bit truncation.
6. Ensure query ordering is deterministic and documented: closest-hit tie breaks, all-hit sort, deduplication across fixtures, beam reflection ties, and stable IDs after slot reuse.

### P0 - Terrain/liquid resource and serialization safety

1. Keep checked terrain/liquid cell products, but extend budgets to serialized input bytes, output bytes, layer/component counts, dirty chunks, component result cells, debris outputs, and total collider rows per flush.
2. Make `TerrainMap::flush_with_limit` deterministic. Draining a `HashSet` gives unspecified chunk order; sort the selected dirty chunks before spending a partial budget so repeated runs rebuild the same region first.
3. Make collider rebuild failures explicit.
   - The current row-run loop skips `Body::try_new` errors and calls the unbounded `world.add_body`.
   - Preflight maximum generated bodies, propagate errors, and either commit a whole chunk or restore its previous colliders.
4. Bound `find_components` outputs as well as scanned cells. A million one-cell components/cell vectors can allocate heavily even under the scan ceiling.
5. Version terrain and liquid byte formats with exact forward/backward policy, checked length arithmetic, finite cell size, trailing-byte behavior, and transactional `load` semantics.
6. Preserve liquid volume within an explicit epsilon and deterministic iteration order. Add worst-case active-cell tests and ensure terrain-linked stepping rejects incompatible maps before cloning/mutating state.

### P1 - Binding and internal code quality

1. Split `physics_api.rs` by private concern while keeping one generated public namespace: world/step, bodies/fixtures/materials, queries/beams, joints, altitude/ballistics, zones/flows, terrain, liquids, and adapters.
2. Move business logic from the reported large closures into core strict helpers. Binding files should parse/validate/convert/register only.
3. Replace repeated validation and table parsing with typed option structs. Cap table entries and string lengths before collection, and include the full failing `lurek.physics.*` name in errors.
4. Replace generic/generated file-level docs in `world/*.rs`, `limits.rs`, `flow.rs`, and other flagged files with concrete owned state, invariants, failure behavior, and boundary statements.
5. Clarify diagnostics: active vs lifetime counts, clamped/skipped steps, rebuild/query work, emitted/dropped events, and limit rejections. Counters must not wrap silently.
6. Keep physics debug rendering narrow: core creates bounded geometry/snapshots; `render` owns queued commands and pixels. Do not move general visualization into physics.

### P1 - Tests and proof

1. Expand Rust tests for:
   - every declared limit and every creation route;
   - active/lifetime slot reuse and stale generation-safe IDs;
   - transactional batches/adapters/chunk rebuilds;
   - strict finite/range validation for all public setter families;
   - fixed-step consumed/remainder time and full-call event accumulation;
   - callback parity between `step` and `stepFixed`;
   - deterministic query/contact ordering and fixture deduplication;
   - terrain partial flush order, component/output limits, serialization corruption/version drift;
   - liquid conservation, active-cell limit, incompatible terrain, and corrupt bytes;
   - flow/zone/altitude/ballistic cleanup when bodies are destroyed or IDs reused.
2. Replace the reported exact float assertions with epsilon checks where solver/arithmetic results are involved.
3. Add `tests/lua/security/test_physics_security.lua`: huge batches, exhausted bodies/joints/zones/fixtures, non-finite values, extreme IDs/casts, huge `maxSteps`, solver/CCD requests, malformed filters/options/byte strings, corrupt terrain/liquid blobs, excessive query outputs, stale/cross-type userdata, and callback reentrancy.
4. Extend stress coverage with bounded dense/sparse bodies, many tombstone cycles, fixture-heavy bodies, joints, CCD, query-all, reflection bounces, terrain dirty flush budgets, component scans, liquids, flows/zones, altitude, and callback storms. Record limits and release timings.
5. Add integration tests for tilefield conversion, scene activation, image alpha-shape inference, and render debug snapshots. Do not count those as core owner unit coverage.
6. Keep visual evidence for debug overlays, terrain/liquid state, query paths, and joints; assertions must still prove numerical/state invariants.

### P1 - Docs, API, specs, examples, and file docs

1. Investigate the 150+ annotation warnings. Fix actual missing `@param`, `@return`, and nested `@field` source annotations; fix the audit parser if it misclassifies material/option field docs.
2. Add structured fields/variants for every reported physics type. Prioritize `PhysicsLimits`, diagnostics/stats, query/filter/hit types, materials, terrain/liquid options/results, altitude, zones, flows, and joints.
3. Update `docs/specs/manual/physics.md` with exact limits, strict/clamped step behavior, event aggregation/callback parity, ID lifetime, query ordering, serialization compatibility, and transaction rules.
4. Document the difference among body CCD, circle casts, thin beams, ballistic altitude, and gameplay projectiles in one decision table.
5. Review all 326 example owners for assertions-free but meaningful usage. Avoid teaching unbounded solver/substep values or legacy silent wrappers.
6. Regenerate specs/API docs from source; never edit generated `docs/specs/physics.md` or `docs/api/*` directly.

### P2 - Useful non-duplicating feature gaps

Implement only after limits and ownership are stable:

1. Thick beam/capsule cast implemented by the canonical shape-sweep/query machinery, replacing the current explicit `thickness > 0` rejection without a parallel algorithm.
2. Explicit friction/restitution combine rules on materials/fixtures, mapped directly to Rapier policy and documented.
3. Batched spatial queries that reuse one query-pipeline update and bounded output buffers.
4. Smoother terrain contour colliders behind a selectable strategy; retain row-runs as the fast deterministic default.
5. Immutable physics snapshots/diffs for render, pathfind, and tooling consumers, with generation IDs and no mutable cross-module state.

Reject: pathfinding, weapon damage, particle-only fluids/SPH, visual tilemaps, scene scheduling, image decoding, or GPU rendering.

## Performance plan

- Add release baselines for body create/destroy/slot reuse, step and fixed catch-up, contacts, fixtures, joints, CCD, each query family, flow/zone sampling, altitude/ballistics, terrain edits/partial flush/component scan, and liquid steps/body forces.
- Record active and backing slot counts, colliders, joints, contacts, query candidates/hits, substeps, dirty chunks, created/destroyed terrain bodies, active liquid cells, allocations, and elapsed time.
- Prove sparse updates are proportional to dirty/active state rather than full configured capacity.
- Add thresholds for max-control inputs so solver iterations, CCD substeps, callbacks, and query outputs cannot bypass the gate.
- Add physics-specific scenarios to the perf gate; a global stress percentage is not sufficient evidence.

## CAG and contract updates to include with implementation

1. Update `review-all` minimally to require hostile-input suites, declared-limit enforcement audits, finite/cast review, event/callback semantics, compatibility parity, and parser/serialization budgets for every applicable module.
2. Extend `review-performance` beyond grids to solver/substep knobs, callbacks, query output size, tombstone growth, and nested workload multipliers.
3. Extend `review-tests` so 100% marker coverage cannot hide missing security suites or cross-substep behavioral gaps.
4. Fix `tools/AGENTS.md` to show positional `audit_module.py physics`, matching the actual parser.
5. Update `src/physics/AGENTS.md` compactly (target 18-28 lines): enforce every `PhysicsLimits` ceiling, strict finite inputs, fixed-step event/callback contract, generation-safe lifetimes, transactional bulk/serialization paths, and named Rust/Lua security/stress gates.
6. Add reciprocal boundary lines to tilefield/render/image/scene contracts only when their adapter behavior changes. Do not duplicate the physics design in root `AGENTS.md`.

## Implementation owners and sequence

1. `architect`: approve ID reuse, step/event semantics, terrain/liquid boundaries, and compatibility policy.
2. `developer`: strict core APIs, limit enforcement, slot lifecycle, event aggregation, serialization and deterministic terrain work.
3. `lua_designer`: split bindings, strict options/casts/errors, callbacks, and canonical adapter parity.
4. `tester`: Rust gaps, Lua security/stress, cross-module integration, evidence, and perf baselines.
5. `content`: revise examples after API generation stabilizes.
6. `doc_writer`: file docs, manual spec, generated API/spec docs.
7. `cag_architect`: compact review-skill and contract changes.
8. `reviewer`: repeat audits and verify no new ownership/performance regression.

## Verification

```powershell
tools\python.cmd tools\audit\audit_module.py physics --docs-quality
tools\python.cmd tools\audit\thin_wrapper_audit.py --scope physics --format text
tools\python.cmd tools\audit\docstring_audit.py --file src\lua_api\physics_api.rs --check
tools\python.cmd tools\audit\example_coverage.py --module physics --report --no-stubs --no-partials --lint
tools\python.cmd tools\audit\unit_test_api_coverage.py --module physics --threshold 100
tools\python.cmd tools\audit\lua_spec_coverage.py --module physics --threshold 100
tools\python.cmd tools\audit\lua_nonunit_test_coverage.py --path tests\lua\stress\test_physics_stress.lua --heuristic-body-check
tools\python.cmd tools\audit\lua_nonunit_test_coverage.py --path tests\lua\security\test_physics_security.lua --heuristic-body-check
tools\python.cmd tools\audit\lua_evidence_golden_contract_audit.py
cargo test --test physics_tests
cargo test --test lua_tests
tools\python.cmd tools\audit\perf_regression_gate.py
cargo clippy -- -D warnings
tools\python.cmd tools\validate\cag_validate.py
tools\python.cmd tools\audit\cag_link_check.py --strict
```

## Done definition

- Every declared physics limit is enforced through every Rust/Lua creation and work path.
- Fixed stepping consumes/reports time deterministically and preserves full-call events/callback parity.
- IDs, stale handles, batch failure, terrain rebuild, and serialization have explicit transactional semantics.
- Physics remains the sole simulator/query owner without absorbing rendering, tile storage, navigation, or gameplay policy.
- Rust, Lua unit, security, stress, integration, examples, specs, docstrings, file docs, and module-specific performance evidence all pass.
