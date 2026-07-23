# Light module audit and fix plan

## Goal

Harden `light` as the renderer-facing authority for 2D light definitions, occluders, shadow semantics, per-light animation state, and the shared scene light world. Keep GPU execution in `render`, tile propagation in `tilelight`, authored tile facts in `tilefield`, and bitmap ownership in `image`.

## Current evidence

- Canonical domain code is `src/light/*.rs`; the public binding is `src/lua_api/light_api.rs` (1,914 lines). The module currently has no nested `src/light/AGENTS.md`.
- Focused audits report 104/104 Lua APIs in generated specs, 104/104 exact Lua unit owners, no unknown `@covers`, structurally clean examples, and all 23 namespace functions represented in the example file.
- `cargo test --test light_tests` passes 16/16. The Rust audit still reports only 16 tests for 99 public Rust methods, exact float assertions at `tests/rust/unit/light_tests.rs:141-142`, and no hostile-input security suite.
- Non-unit coverage has three light stress owners and valid evidence/golden contracts, but `tests/lua/security/test_light_security.lua` does not exist.
- `audit_module.py light` flags missing structured docs for at least 13 types, missing binding section separators, large registration closures near `light_api.rs:1575` and `1844`, and one source docstring missing a description. The dedicated thin-wrapper audit reports clean, so the implementation must reconcile the disagreement rather than blindly follow either result.
- The global perf gate passes at 38.57%, but there is no light-specific baseline or ceiling for lights, occluders, shadow samples, preview dimensions, hint export, or per-frame allocation.
- Current Rust tests pass, but they do not cover the ownership and hostile-input defects below.

## Required ownership boundary

| Concern | Canonical owner | Light rule |
|---|---|---|
| Point/spot/directional light state, groups, masks, falloff, flicker, transitions, occluders | `light` | Keep authoritative runtime state here. |
| GPU pipelines, shader compilation/validation, texture sampling, command submission | `render` | Light stores validated resource keys and render-ready snapshots only. |
| CPU pixel buffers and image codecs | `image` | Light may emit bounded debug images but must not become an image-processing owner. |
| Tile blockers/transmission/authored emitter metadata | `tilefield` | Consume through explicit adapters; do not copy field state into light core. |
| Computed grid illumination and tile-light source lifecycle | `tilelight` | Do not implement propagation or gameplay visibility in `light`. |
| Visibility/FOV/remembered knowledge | `awareness` | Light can provide visual inputs, never gameplay truth. |
| Tilefield-to-render-light creation | `light` | `lurek.light.createLightsFromTilefield` is canonical; the tilefield API is a forwarding compatibility alias only. |

`light` should own resource references such as cookie and normal-map keys only after asset/render validation. Raw path resolution belongs to the asset/GameFS boundary, and the renderer owns actual texture binding.

## Findings and work order

### P0 - Bound memory, CPU work, and hostile inputs

1. Add `src/light/limits.rs` with a compact `LightLimits` used by both Rust and Lua paths.
   - Bound registered lights, registered occluders, vertices per occluder, total occluder vertices, group/hint export count, debug preview pixels, and debug preview work units.
   - Define a work estimate for `draw_to_image`: `pixels * active_lights * shadow_samples * relevant_occluder_edges`. Reject or explicitly truncate before allocation/iteration when it exceeds the configured ceiling.
   - Keep `max_lights` as a renderer selection limit, not a substitute for a storage ceiling. Enforce both and document their different meanings.
2. Replace public Rust panics in `Occluder::new` and `set_vertices` with strict `try_new` / `try_set_vertices` results. Keep any legacy infallible wrappers crate-private or clearly deprecated; no Lua-reachable path may panic.
3. Validate every vertex coordinate and position as finite before storing it. Reject NaN/inf in flat coordinate tables, option patches, group changes, attenuation coefficients, angles, transition targets, flicker state, shadow settings, and normal strengths.
4. Replace `angle_delta`'s repeated `while` normalization with constant-time `rem_euclid` normalization. Extremely large finite angles must not cause proportional loops.
5. Cap and preallocate hint tables. `directional_light_hints` and `normal_map_light_hints` currently allocate fresh vectors, and normal-map hints clone every path; provide bounded snapshot writers or reusable scratch buffers for the renderer-facing hot path.
6. Add explicit semantics for limit exhaustion: constructors return a named `lurek.light.*` error, adapters fail transactionally, and no partial lights/occluders remain after a rejected bulk conversion.

Acceptance: hostile Lua cannot create unbounded scene state or force an unbounded CPU preview; non-finite geometry never reaches shadow math; limit failures leave world counts and handles unchanged.

### P0 - Correctness and lifecycle invariants

1. Fix `LightWorld::clear` and removal lifecycle.
   - Decide whether `clear()` disables the world. Its current implementation removes all state but leaves `enabled` unchanged, while construction starts disabled and `add_light` auto-enables.
   - Define whether removing the last light auto-disables, and test manual `setEnabled(false)` followed by `newLight` so explicit user intent is not unexpectedly overwritten.
   - Update docstrings/specs to state the chosen rule exactly.
2. Move cookie state out of `LuaLight.cookie_path` or remove the misleading feature.
   - `setCookie`, `getCookie`, and `clearCookie` currently mutate only the wrapper-local `RefCell`; no `Light2D` field or renderer code consumes it.
   - Preferred fix: store a validated texture/resource key in `Light2D`, expose it in the render snapshot, and have `render` sample it. If cookie rendering is not being implemented, deprecate/remove the API instead of claiming functional light cookies.
   - Test alias handles so all wrappers observe one authoritative value.
3. Resolve transition ownership. `LightTransition` is wrapper-local and advances only when `LLight:updateTransition(dt)` is called, unlike world-owned flicker.
   - Either move transition state into `Light2D` and advance it through one bounded world update, or explicitly document it as a handle-local helper that is not automatic.
   - Prefer world-owned state so compatibility adapters and multiple handles cannot diverge.
4. Validate and normalize spot cone invariants as one operation: finite angles, non-negative inner/outer values, `inner <= outer`, and a documented maximum canonical range. Do not silently repair invalid state differently in draw and renderer paths.
5. Define attenuation policy. Reject negative/non-finite coefficients or document supported artistic negative curves; `Attenuation::factor` currently converts any non-positive denominator to full intensity, which can hide malformed curves.
6. Define stable selection when active lights exceed `max_lights`. Slot-map iteration order must not become accidental visual priority. Add explicit priority plus stable key/order tie-breaking, or document insertion-order selection and test remove/reinsert behavior.
7. Audit shadow geometry edge cases: repeated vertices, zero-area polygons, non-convex/self-intersecting inputs despite the type claiming convexity, collinear segments, light/point on edges, masks, and opacity. Reject invalid polygons or rename/document the accepted geometry model.
8. Make generation rollover explicit. `Occluder.edge_generation` wraps silently; use checked epoch semantics or prove rollover is harmless to every cache consumer.

### P0 - Lua API and adapter reliability

1. Extract option parsing and the large `newLight`, hint-export, and tilefield-adapter closures from `src/lua_api/light_api.rs` into tested `src/light` or private binding helpers. Registration must remain a flat name-to-wrapper map.
2. Convert f64/integer Lua values to f32 only after range checking. Helpers such as `optional_f32_field` currently cast first; finite f64 values larger than `f32::MAX` become infinity and rely on later callers to notice.
3. Require exact option schemas where practical. Reject unknown fields in strict constructors, cap strings, reject empty cookie/normal-map paths, and include the full failing public method in every error.
4. Make `createLightsFromTilefield` a thin consumer-owned adapter with:
   - checked input counts and total vertices;
   - prevalidation of every metadata record;
   - deterministic output ordering;
   - transactional creation/rollback;
   - the same error shape through the tilefield compatibility alias.
5. Review `setMaxLights`: distinguish invalid types/ranges from clamping. Prefer rejecting `0` and values above the documented ceiling rather than silently changing caller intent.

### P1 - Code quality and performance

1. Split debug rasterization from scene state. Keep a bounded `light::debug_image` helper or evidence-only renderer so `light_world.rs` is not simultaneously collection owner, shadow solver, rasterizer, and hint exporter.
2. Cache transformed occluder edges using `edge_generation`; `draw_to_image` currently rebuilds a `Vec<Vec2>` for every enabled occluder on each call. Share the same immutable edge snapshot with CPU preview and renderer where valid.
3. Avoid allocating a full `Vec<RenderLight>` and cloned occluder polygons for every preview. Reuse scratch capacity or stream bounded snapshots.
4. Replace group-wide full scans only if profiling proves a problem. If group mutation is frequent, maintain a generation-safe group index; otherwise keep the simpler scan and record its ceiling.
5. Remove stale/generic file docs and add factual structured sections for every flagged enum/struct. `mod.rs` must say that `light_world` stores scene data and snapshots; it does not itself submit GPU commands.
6. Resolve the audit disagreement: update `audit_module.py` or `thin_wrapper_audit.py` so both apply the same definition of business logic and report the exact closure/symbol, not anonymous line-only closures.

### P1 - Tests and proof

1. Expand `tests/rust/unit/light_tests.rs` for:
   - all constructor/limit ceilings and transactional failures;
   - clear/enable/remove-last lifecycle;
   - stable `max_lights` selection;
   - cookie/normal-map/transition authoritative ownership;
   - cone and attenuation validation;
   - degenerate, non-convex, self-intersecting, repeated, and non-finite occluders;
   - constant-time angle normalization for huge inputs;
   - generation/cache invalidation and rollover policy;
   - masks, opacity, all filters, all blend modes, and directional-light behavior.
2. Replace float `assert_eq!` at the reported lines with epsilon helpers where arithmetic is involved.
3. Add `tests/lua/security/test_light_security.lua` with one family owner per API: excessive lights/occluders/vertices, non-finite values, huge angles, malformed option tables, invalid shader target/userdata, stale handles, huge preview dimensions, oversized tilefield conversions, and long/invalid asset paths.
4. Extend `tests/lua/stress/test_light_stress.lua` with bounded sparse/dense scenes, max-light truncation/priority, repeated add/remove/reindex, many groups, high shadow-filter cost, and hint exports. Record dataset sizes and active limits.
5. Add integration proof for `tilefield -> light -> render` canonical ownership and exact error parity through the compatibility alias. Keep tile propagation in tilelight tests.
6. Add evidence/golden artifacts only for visual semantics that assertions cannot explain: priority clipping, cookie projection if implemented, cone boundary, masks, and soft-shadow filter changes.

### P1 - Docs, docstrings, specs, and examples

1. Fix the one missing binding description and add parser-recognized separators without hand-editing generated docs.
2. Add `# Fields` / `# Variants` sections for all D-03 findings, including attenuation, blend/falloff modes, flicker, option patches, light types, shadow filters, transition state, world snapshot types, and occluders.
3. Update `docs/specs/manual/light.md` with exact ceilings, world enable/clear semantics, stable over-limit selection, polygon validity, transition advancement, resource-path policy, and cookie support status.
4. Document the boundary among `light`, `tilelight`, `tilefield`, `render`, and `awareness` in one concise ownership table. Add an architecture link only if a durable render-resource contract changes.
5. Review all 104 example owner blocks for meaningful standalone behavior, not only markers. Do not teach wrapper-local cookies as rendered output until the renderer consumes them.
6. Regenerate module specs and API reference from source after API/docstring changes.

### P2 - Useful non-duplicating feature gaps

Implement only after P0/P1 and an owner decision:

1. Explicit light priority/culling diagnostics: selected count, rejected count, reason, and stable priority. This belongs in `light`; camera culling policy may be supplied by `render` without moving ownership.
2. Bounded bulk creation/update APIs for tools and tile adapters, reusing the same validation and rollback path.
3. Renderer-consumed cookie textures, only if asset resolution and shader contract are fully implemented.
4. Immutable/revisioned light snapshots for tooling and render threading, without exposing render internals to Lua.
5. Optional spatial indexing for occluders/lights only after benchmarks show CPU shadow queries need it.

Reject: tile-light propagation, FOV/stealth truth, generic image filters, shader compilation, texture loading, or physics visibility geometry.

## Performance plan

- Add release baselines for add/remove, group mutation, flicker advance, transitions, hint export, snapshot creation, tilefield conversion, and CPU preview at fixed scene sizes.
- Record light count, selected count, occluder count, total edges, preview pixels, filter sample count, allocations, and elapsed time.
- Set regression thresholds separately for no-shadow, hard-shadow, PCF5, and PCF13 scenarios.
- Prove work stops at configured limits and that sparse scenes do not pay dense-scene costs.
- Add a light-specific scenario to the perf/stress gate; the current global score is not light evidence.

## CAG and contract updates to include with implementation

1. Update `review-all` minimally to require, for every public module: hostile-input suite presence or an explicit exemption, finite-number checks, allocation/iteration ceilings, compatibility-alias parity, and direct-filesystem policy review.
2. Update `review-performance` so its ceiling checklist applies to scene graphs, parsers/codecs, callbacks, and nested loops, not only stateful grids.
3. Update `review-tests` to distinguish 100% marker ownership from semantic assertion/security coverage.
4. Fix `tools/AGENTS.md`: the documented `audit_module.py --module <name>` syntax is stale; the parser accepts the module positionally.
5. Add a compact `src/light/AGENTS.md` matching neighboring module contracts (target 15-25 lines, never a second design document): ownership, finite/limit rules, authoritative cookie/transition state, stable selection, and required Rust/Lua security/stress validation.
6. Add reciprocal one-line boundaries to `src/render/AGENTS.md`, `src/tilelight/AGENTS.md`, or `src/tilefield/AGENTS.md` only if implementation changes their contract. Do not enlarge root `AGENTS.md`.

## Implementation owners and sequence

1. `architect`: approve light/render/resource ownership, enable semantics, and over-limit selection.
2. `developer`: limits, strict constructors, lifecycle fixes, snapshots/caches, and core cookie/transition state.
3. `lua_designer`: thin wrappers, option validation, compatibility parity, and API migration.
4. `tester`: Rust security/stress/integration/evidence coverage and performance scenarios.
5. `content`: update examples after the generated surface is stable.
6. `doc_writer`: source docs, manual overlay, regenerated specs/API docs.
7. `cag_architect`: compact skill and contract updates.
8. `reviewer`: rerun the same audits and accept ownership/performance evidence.

## Verification

```powershell
tools\python.cmd tools\audit\audit_module.py light --docs-quality
tools\python.cmd tools\audit\thin_wrapper_audit.py --scope light --format text
tools\python.cmd tools\audit\docstring_audit.py --file src\lua_api\light_api.rs --check
tools\python.cmd tools\audit\example_coverage.py --module light --report --no-stubs --no-partials --lint
tools\python.cmd tools\audit\unit_test_api_coverage.py --module light --threshold 100
tools\python.cmd tools\audit\lua_spec_coverage.py --module light --threshold 100
tools\python.cmd tools\audit\lua_nonunit_test_coverage.py --path tests\lua\stress\test_light_stress.lua --heuristic-body-check
tools\python.cmd tools\audit\lua_nonunit_test_coverage.py --path tests\lua\security\test_light_security.lua --heuristic-body-check
tools\python.cmd tools\audit\lua_evidence_golden_contract_audit.py
cargo test --test light_tests
cargo test --test lua_tests
tools\python.cmd tools\audit\perf_regression_gate.py
cargo clippy -- -D warnings
tools\python.cmd tools\validate\cag_validate.py
tools\python.cmd tools\audit\cag_link_check.py --strict
```

## Done definition

- Light and occluder state, debug work, exports, and adapters are bounded before allocation/iteration.
- No non-finite geometry or public Rust panic reaches shadow/render logic.
- Clear/enable/removal, priority selection, transition, cookie, and normal-map ownership are explicit and tested.
- `light`, `tilelight`, `tilefield`, `render`, and `awareness` have non-overlapping contracts.
- Rust, Lua unit, security, stress, integration, examples, specs, docstrings, file docs, and module-specific performance evidence all pass.
