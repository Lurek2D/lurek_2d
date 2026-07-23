# Tilelight module audit and fix plan

## Goal

Make `tilelight` a bounded, deterministic, incremental owner of tile-level environment lighting computed from `tilefield` inputs. Preserve a sharp separation from player knowledge (`awareness`), world/render lights (`light`), visual map storage (`tilemap`), and GPU rendering (`render`).

## Current evidence

- Canonical code is `src/tilelight/{color,map,source}.rs`; Lua edge is `src/lua_api/tilelight_api.rs`.
- Focused audits report 100% Lua unit ownership, 100% example coverage (28/28), 100% Lua spec coverage (28/28), clean unit structure, clean source Lua docstrings, and no unknown `@covers`.
- Module quality still fails on structured Rust docs, one 24-line binding closure, and only one Rust test attributed to `tilelight`.
- Six substantive tilelight propagation tests are misplaced in `tests/rust/unit/tilefield_tests.rs`.
- Evidence/golden coverage exists for square, hex, blockers, and multilevel light. There is no tilelight stress or security owner.
- The global perf gate passes, but current algorithms include full-volume clears and source-radius work that are not isolated by a tilelight baseline.

## Required ownership boundary

| Concern | Owner | Tilelight rule |
|---|---|---|
| Tile-cell light source lifecycle, ambient/sun settings, propagation, RGB/luma output | `tilelight` | Keep here. |
| Environmental blockers, transmission/filter categories, sun occlusion, topology | `tilefield` | Read only; do not duplicate state. |
| Per-player visibility/exploration/action masks | `awareness` | Never infer or store here. |
| World/screen render lights, occluders, shadows, GPU passes | `light` / `render` | Tilelight exports passive data only. |
| Visual tile ids, layers, map projection | `tilemap` | No visual storage in tilelight. |
| Minimap/raycaster visualization | `minimap` / `raycaster` | Consume exported layers/volumes. |

Tilefield may carry authored light-emitter defaults, but `TileLightMap` owns runtime source ids, source updates/removal, modulation, computed values, and propagation. Consolidate any duplicate runtime source lifecycle into tilelight.

## Findings and work order

### P0 - Prevent denial-of-service work and allocation

1. Introduce `TileLightLimits` in `src/tilelight/limits.rs`.
   - Maximum volume cells, point/line/area sources, line cells, radius, area dimensions, affected cells per source, output cells, and compute work budget.
   - Check limits before allocation and before nested loops.
2. Cap radii. Current finite positive radii are converted with `ceil() as i32`; a huge finite value can saturate to `i32::MAX` and drive effectively unbounded nested loops.
3. Bound line length and line-radius product. Avoid iterating every line source cell times every radius cell and then scanning the full line again for each target.
4. Bound area rectangle plus halo and use checked additions. Preserve existing validation but add configured work ceilings.
5. Add a maximum source count and compact removed slots. `Vec<Option<...>>` grows forever across repeated add/remove cycles.
6. Make volume creation allocation-safe. Checked multiplication prevents integer overflow but not an enormous valid allocation; enforce a practical cell ceiling before `vec!`.
7. Bound `exportLayer`/`exportVolume` and document their copy cost. Offer a borrowed/internal view for engine adapters.

Acceptance: no Lua-reachable dimension, source count, radius, line, rectangle, or export can cause unbounded memory/work; limit failures include the exact `lurek.tilelight.<method>` name.

### P0 - Stable ids and numeric correctness

1. Fix `next_light_id` exhaustion. Saturating at `u32::MAX` produces duplicate ids after the maximum is reached.
   - Use checked increment and return an exhaustion error, or switch to a generation/index handle with documented stability.
   - Test reuse/compaction semantics and stale ids.
2. Validate all colors, intensities, time, and modulation parameters as finite.
   - `f32::clamp` does not turn NaN into a meaningful value; reject NaN/inf before clamping.
   - Validate flicker/pulse frequency, phase, amplitude, and color modulation in `source.rs`.
   - `set_sun_light` currently applies `max(0.0)` but needs a finite check.
3. Define intensity zero, radius boundary, falloff at exactly radius, ambient override, negative/non-finite time, and channel saturation semantics.
4. Ensure updates are transactional: validate a complete patch before mutating any field.
5. Define source ordering and floating-point determinism. If additive saturation makes source order observable, either guarantee stable order or accumulate in a higher-range buffer then clamp once.
6. Verify blockers/filters on origin, target, intermediate cells, and top/directional sun paths. Document whether target-cell blocking affects incoming light.

### P0 - Correctness and cache invalidation

1. Track which tilefield version the computed output represents.
   - Reject or mark stale output when field inputs change after compute.
   - Expose diagnostics such as computed field version, source version, dirty status, and last affected-cell count if useful.
2. Add a tilelight dirty model.
   - Source add/update/remove and ambient/sun changes mark bounded affected regions or full-volume dirty as appropriate.
   - Consume tilefield dirty/version data without making tilefield depend on tilelight.
3. Preserve a full recompute fallback for correctness and compare incremental output against it in tests.
4. Eliminate hidden duplication between tilefield emitter metadata and tilelight source lists. Materialize authored emitters explicitly and define whether later field changes resync automatically.
5. Audit directional sun complexity and semantics for large volumes; use sweep/dynamic programming rather than tracing from every target when equivalent.

### P1 - Algorithm and binding quality

1. Move domain work from the closure near `src/lua_api/tilelight_api.rs:816` into tilelight helpers. Keep Lua closures to conversion/calls/userdata.
2. Replace repeated cloning of all active source records during compute with a borrow-safe iteration strategy or reusable scratch buffer.
3. Replace line-light algorithmic duplication:
   - rasterize the source line once;
   - derive a bounded influence region;
   - compute nearest source distance without scanning every line cell per candidate;
   - avoid applying the same target repeatedly from each source cell.
4. Cache or incrementally update occlusion/transmission work where profiling proves it is dominant. Invalidate from tilefield dirty data.
5. Preallocate bounded scratch buffers and reuse them across computes.
6. Consider a `ComputeOptions` domain struct so Lua option parsing and Rust calls share one validated contract.

### P1 - Tests and proof

1. Move point blocker, partial transmission, radial distance, colored addition, top-light attenuation, and dusk/night color tests from `tilefield_tests.rs` to `tilelight_tests.rs`.
2. Expand Rust coverage for:
   - every limits boundary and volume overflow/ceiling;
   - id exhaustion, removal, compaction, stale ids, and clear behavior;
   - add/update/remove for point, line, and area/rect aliases;
   - finite/range validation for all source/modulation/sun/ambient/time fields;
   - square4/square8/iso/hex distance/line behavior;
   - origin/target/intermediate blocker and RGB filter semantics;
   - directional and top sun across multiple levels;
   - incremental result byte/epsilon equivalence with full recompute;
   - field-version staleness and dimension/topology mismatch;
   - deterministic output independent of removed-slot history.
3. Add `tests/lua/security/test_tilelight_security.lua`: huge radius, huge source counts, huge field volume, NaN/inf colors/intensity/time/modulation, oversized lines/areas, repeated churn, invalid ids, wrong userdata, and stale field changes.
4. Add `tests/lua/stress/test_tilelight_stress.lua` with separate API owners for many bounded point lights, long lines, large areas, multilevel sun, repeated incremental edits, and exports.
5. Preserve square/hex/multilevel evidence and goldens. Add a directional-sun artifact only if it makes correctness visually legible.
6. Use epsilon comparisons for computed floats and exact comparisons only for defined zero/clamp cases.

### P1 - Docs, docstrings, specs, and examples

1. Replace generic file docs with precise state/invariant/algorithm boundaries in `map.rs`, `source.rs`, and `color.rs`.
2. Add structured `# Fields` / `# Variants` sections for `LightColor`, `TileLightMap`, modulation/source/update records, sun modes/settings, and all D-03 findings.
3. Document units, finite/range bounds, default options, errors, side effects, source-id lifetime, compute complexity, stale-output behavior, and copy costs for exports.
4. Update `docs/specs/manual/tilelight.md` with:
   - source and cell/work limits;
   - full versus incremental compute contract;
   - tilefield version/dirty integration;
   - target blocker/filter semantics;
   - runtime source ownership versus authored tilefield emitter metadata;
   - explicit separation from `lurek.light` and `awareness`.
5. Review all 28 example blocks for meaningful use and ensure options mention area-light inclusion where relevant. Examples should not teach unlimited radii or per-frame full-volume recompute.
6. Regenerate docs and specs from source; do not edit generated outputs directly.

### P2 - Useful non-duplicating feature gaps

Implement only after correctness and profiling:

1. Incremental `computeDirty` or automatic dirty compute with a full-recompute verification mode.
2. Read-only light-layer views and a versioned diff export for minimap/render/raycaster consumers.
3. Source enable/disable and batched source updates, avoiding delete/recreate churn.
4. Diagnostics: active source counts, dirty cells, rays/transfer queries, compute mode, and last compute work.
5. Optional attenuation curve enum owned by tilelight, provided it remains tile-grid propagation and does not duplicate `lurek.light` render falloff.
6. Explicit materialization of authored tilefield emitters into runtime sources with snapshot/live-sync modes.

Reject: per-player fog/knowledge, world-space shadow geometry, GPU light passes, tilemap rendering, or pathfinding visibility.

## Performance plan

- Establish release baselines by volume, topology, source type/count/radius, blocker density, levels, and dirty fraction.
- Record cells visited, transfer rays, scratch allocations, and output cells in addition to wall time.
- Target incremental cost proportional to changed influence regions; retain full fallback.
- Optimize line lights and directional sun first because their current nested/scanned work has the highest asymptotic risk.
- Add tilelight to `stress_report.py`/perf baselines before enforcing thresholds.
- Keep scratch reports in `work/tilelight-review/` only.

## CAG and contract updates to include with implementation

1. Extend `review-all` with security, hostile numeric input, bugs, feature gaps, module overlap, file docs, and algorithmic complexity checks.
2. Extend `review-performance` to require complexity/work counters and module-specific worst-case source shapes.
3. Extend `review-tests` to detect misplaced module tests and require security/stress coverage for allocation-heavy APIs.
4. Extend `review-api` to audit nested option fields, NaN/inf handling, stable-id exhaustion, and stale-handle semantics.
5. Add `src/tilelight/AGENTS.md` in the same compact size/style as tilefield/tilemap contracts:
   - owns computed tile lighting and runtime sources;
   - consumes tilefield without reverse dependency;
   - all compute/allocation paths use limits;
   - incremental output must match full recompute;
   - focused test/perf commands.
6. Add only reciprocal short boundary wording to `src/tilefield/AGENTS.md`. Do not add tilelight detail to root `AGENTS.md`.

## Implementation owners and sequence

1. `architect`: approve runtime emitter ownership and incremental contract.
2. `developer`: limits, id/numeric fixes, dirty/version model, algorithms.
3. `lua_designer`: thin options/bindings, errors, annotations.
4. `tester`: relocate/expand Rust tests, add security/stress, verify goldens.
5. `content`: improve examples after API stabilizes.
6. `doc_writer`: manual spec and generated docs.
7. `cag_architect`: skills and nearest contracts.
8. `reviewer`: complexity/performance and cross-module acceptance.

## Verification

```powershell
tools\python.cmd tools\audit\audit_module.py tilelight --docs-quality
tools\python.cmd tools\audit\thin_wrapper_audit.py --scope tilelight --format text
tools\python.cmd tools\audit\docstring_audit.py --file src\lua_api\tilelight_api.rs --check
tools\python.cmd tools\audit\example_coverage.py --module tilelight --report --no-stubs --no-partials
tools\python.cmd tools\audit\unit_test_api_coverage.py --module tilelight --threshold 100
tools\python.cmd tools\audit\lua_spec_coverage.py --module tilelight --threshold 100
tools\python.cmd tools\audit\lua_nonunit_test_coverage.py --path tests\lua\stress\test_tilelight_stress.lua --heuristic-body-check
tools\python.cmd tools\audit\lua_evidence_golden_contract_audit.py
cargo test --test tilelight_tests
cargo test --test lua_tests
tools\python.cmd tools\audit\perf_regression_gate.py
cargo clippy -- -D warnings
tools\python.cmd tools\validate\cag_validate.py
tools\python.cmd tools\audit\cag_link_check.py --strict
```

## Done definition

- Volume/source/radius/line/area/export work is bounded before iteration or allocation.
- Stable ids cannot collide or silently exhaust.
- NaN/inf cannot enter light state or output.
- Incremental and full compute are equivalent within documented epsilon.
- Tests live under correct owners; security/stress/evidence coverage is meaningful.
- Module quality and module-specific performance gates pass while public API/example/spec ownership stays 100%.
