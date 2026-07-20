# Render Plan 4 of 4: Tests, Evidence, CAG Updates, and Implementation Sequence

## Purpose

Supply the semantic, adversarial, visual, performance, and recovery proof needed for Render Plans 1–3, and update compact repository guidance so future module reviews detect the same classes of defect automatically.

## Baseline and gaps

- Focused Rust tests pass 132/132; clippy is clean.
- Lua unit/spec tools report 217/217 while examples report 208 and module audit reports 124 bindings.
- Existing render stress covers only `arc`, `circle`, `line`, `rectangle`, and `setColor`, mainly at command-generation level.
- Existing `test_render_security.lua` has 34 tests but only four render APIs; it is a cross-module grab-bag containing physics, ECS, data, graph, image, tilemap, and other concerns.
- There is no module-owned adversarial coverage for shaders, OBJ/MTL, texture/canvas/mesh allocation, stack balance, stale resources, aggregate frame budgets, pipeline churn, readback, or GPU recovery.
- The global performance gate is not a render-specific GPU proof.
- File-doc audit fails 2/37 render files and the module audit reports 90+ structured-doc gaps, thin-wrapper hotspots, exact-float assertions, and an unwrap.

## Test ownership matrix

| Behavior | Primary proof | Secondary proof |
|---|---|---|
| Pure validation/budget arithmetic | Rust unit/property | Lua invalid-input tests |
| GPU resource/pipeline lifecycle | Rust integration on available backend | Lua integration/smoke |
| Public API signatures/errors | Lua unit | examples/spec |
| Command/state interactions | backend-independent integration | GPU/software parity |
| Files/shaders/hostile sizes | render-owned security | fuzz corpus |
| Surface/device recovery | injected Rust state-machine tests | backend smoke |
| Visual command correctness | deterministic golden/evidence | GPU screenshot tolerance |
| CPU/GPU/memory performance | release perf/stress | telemetry thresholds |

## P0 — Expand Rust tests at private risk seams

Add or strengthen tests for:

- `RenderBudget` cumulative accounting, exact-limit acceptance, one-over rejection, saturation, reset, and persistent-resource totals;
- checked byte/count/alignment/row-pitch/capacity calculations and device-limit clamping;
- resource publication rollback and generational stale/foreign handle rejection;
- balanced/unbalanced state stacks and randomized command sequences;
- shader source/layout/uniform validation, normalized keys, cache limits/eviction, and negative caching;
- OBJ/MTL parsing limits, checked triangulation/index normalization, finite values, and resolver confinement;
- diagnostics partitioning with no double-counting or normal-activity faults;
- surface/device recovery transitions, OOM terminal behavior, timeout policy, and zero-size suspension;
- readback request state transitions, cancellation, timeout, device loss, row padding, and staging-byte limits;
- province neutral snapshots and versioned incremental uploads;
- software replay validation and GPU/software command parity;
- removal of unwrap/expect sites flagged in renderer frame/resource code.

Use approximate float assertions only for computed floating-point output; document tolerance derivation.

## P0 — Make Lua unit tests semantic

- Preserve exactly one owner marker per canonical API while asserting observable command/resource/diagnostic behavior.
- Cover nil/wrong type, unknown option keys, NaN/infinity, negative/extreme sizes, oversized strings/tables, invalid enum values, released/stale/foreign resources, and unsupported capabilities.
- Verify setters influence emitted commands/pipeline state and getters/diagnostics, not merely that calls return.
- Verify canonical constructors and compatibility aliases share results/errors/lifecycle.
- Cover balanced scopes and error behavior for canvas, transform, scissor, stencil, shader, blend, and postfx stacks.
- Cover asynchronous request poll/cancel/result and repeated/dropped-handle behavior.
- Verify healthy shadows affect activity stats without setting faults.

## P0 — Replace the misowned security suite

- Split non-render tests out of `tests/lua/security/test_render_security.lua` into their owning module suites without losing coverage.
- Keep the render file focused on render and cross-module trust boundaries explicitly owned by render.
- Respect the security-suite structure contract; move top-level helper logic into tests or approved harness helpers.

The new render security matrix must include:

- per-command and cumulative budget overflow for every command/resource family;
- integer overflow, short buffers with large declared sizes, nonfinite geometry/matrices/colors/depth, and invalid indices/topology;
- texture/canvas dimensions, bytes, formats, samples, mips, regions, feedback hazards, and resource exhaustion;
- shader source/token/binding/uniform/pipeline-key bombs and repeated invalid compilation;
- OBJ/MTL traversal, absolute/link escape, input/line/name/count bombs, malformed indices, numeric extremes, and material-reference confinement;
- stale/released/foreign resource handles and generation reuse;
- unbalanced/deep state stacks;
- readback dimension/concurrency/staging limits, cancellation, timeout, and recovery;
- surface/device error injection and OOM controlled termination;
- diagnostic message/rate-limit bounds.

Every rejection must be bounded, deterministic, non-panicking, and leave renderer state usable unless the specified terminal OOM path occurs.

## P0 — Replace command-only stress with real render workloads

- Execute actual validated frame preparation and GPU submission where a test adapter is available; use software replay only for deterministic fallback, not as proof of GPU limits.
- Cover all major families listed in Render Plan 2 at warm and cold states.
- Run at, below, and one above each effective budget. Confirm work is rejected before excess allocation/compilation.
- Exercise repeated resource churn/release, pipeline combinations, shader failures, resize/reconfigure, screenshot queues, and device recovery.
- Measure CPU encode, GPU time when supported, allocations, upload/live/retained bytes, draw/pass/pipeline counts, cache metrics, buffer growth, and frame p50/p95/p99.
- Run release builds with declared backend/adapter metadata and store comparable reports.
- Integrate stable ceilings into the performance regression gate; quarantine hardware-sensitive thresholds behind clearly labeled profiles rather than omitting them.

## P1 — Build deterministic evidence and golden coverage

- Golden images for primitives, curves, textures/color spaces, text/rich text, meshes/OBJ materials, canvas clipping/stencil, blend modes, transforms, postfx, shaders, particles, lights/shadows, and province maps.
- Structural snapshots for validated frame packets, pass/state transitions, resource accounting, cache decisions, diagnostics, and recovery transitions.
- GPU/software comparisons with per-feature tolerance and unsupported-feature diagnostics.
- Cold versus warm performance reports and memory residency snapshots.
- Recovery evidence showing resources recreated or invalidated according to their public contract.
- Keep artifacts bounded, reproducible, and registered with the existing evidence/golden tooling.

## P0 — Repair coverage and quality tooling

- Implement the canonical API inventory from Render Plan 3 and make every audit fail on denominator disagreement.
- Teach `audit_module` to include userdata methods, aliases, and generated entries rather than raw `set` counts.
- Distinguish API ownership coverage, semantic-test quality, security-family coverage, stress-family coverage, and backend execution.
- Add checks that flag a module security/stress suite whose API/body ownership is predominantly unrelated modules.
- Add render-specific audit categories for aggregate budget coverage, GPU/resource lifecycle, shader/asset trust, recovery, readback blocking, cache ceilings, and normal-activity/fault separation.
- Make generated report commands use `tools/python.cmd`, actual parser syntax, and correct paths.
- Add parser/self-test fixtures before making the repaired checks blocking.

## P0 — Update compact repository guidance

### `src/render/AGENTS.md`

Rewrite it after the refactor, keeping it compact (target roughly 18–28 lines). It must:

- remove stale nonexistent owners such as `context.rs`, `pipeline.rs`, `texture.rs`, `commands.rs`, `geometry.rs`, and `text.rs`;
- name real current facade, validation, frame, resource, pipeline/cache, capture/readback, shader/postfx, and software replay owners;
- state cumulative budgets, checked device limits, generational resources, GameFS/decoder boundaries, shader trust, recovery, and diagnostic separation;
- state the neutral province snapshot and UI command boundaries;
- list focused `render_tests` plus registered Lua security/stress/evidence/perf commands;
- route full details to specs/architecture/skills instead of duplicating them.

### Other contracts

- Update province/app/image/font/sprite/UI local contracts only where their owner boundary actually changes.
- Update tests security/stress/evidence contracts if needed to enforce module ownership and backend metadata.
- Keep root `AGENTS.md` unchanged unless the new rule is genuinely repository-wide.

## P0 — Update review skills for durable coverage

- `review-all`: require canonical inventory parity, aggregate budgets, hostile parser/shader/file checks, device recovery/readback, no-op features, and verified dependency direction.
- `review-api`: verify resource generations/lifecycle, namespace owner, aliases, async/blocking behavior, options/limits/errors, and capability exposure.
- `review-tests`: require module-owned security/stress suites, real backend execution where applicable, lifecycle/recovery semantics, and no callability-only proof.
- `review-performance`: require cold/warm render baselines, p95/p99, GPU/CPU/memory/upload/cache metrics, cumulative ceilings, and adapter/backend metadata.
- `review-architecture`: compare `wgpu`/domain imports and public constructors to documented owner invariants.
- `review-docstrings`: require qualitative file docs and units/lifetime/errors/performance details.
- `review-examples`/`review-specs`: use canonical inventory and verify limits, lifecycle, aliases, trust, and recovery are represented.

Keep checks general enough for other GPU/resource modules. Avoid embedding current render filenames except in optional examples.

## Ordered implementation waves for Luna GPT 5.6

### Wave 0 — Decisions and trustworthy inventory

1. Freeze focused baseline reports and representative golden outputs.
2. Approve shader trust, budget/rejection, surface ownership/recovery, resource retention, and namespace decisions.
3. Repair canonical API inventory and test ownership reports.

### Wave 1 — Validation and safety foundation

1. Add cumulative frame/persistent `RenderBudget` and checked allocation helpers.
2. Harden handles, stacks, resource publication, diagnostics, shaders, OBJ/assets, and paths.
3. Implement recovery state machine and async bounded readback.
4. Build Rust/Lua security/property tests alongside each seam.

### Wave 2 — Architecture and performance

1. Introduce province neutral snapshots and remove the dependency cycle.
2. Consolidate software replay and UI capture.
3. Add real GPU/software release benchmarks and measured ceilings.
4. Optimize uploads, buffers, batching, caches, prewarm, and frame packets only from evidence.

### Wave 3 — Public API and useful features

1. Add capability/limits, accurate diagnostics, async capture, and bounded prewarm APIs.
2. Move font/image/sprite/depth-sort ownership to canonical namespaces with compatibility aliases.
3. Complete semantic Lua tests and examples for every inventory entry.

### Wave 4 — Documentation and CAG closure

1. Update source docs, file docs, spec, architecture, examples, and narrative guides.
2. Update compact `AGENTS.md` files and review skills.
3. Regenerate derived artifacts and run the full gate.

Keep waves reviewable; do not combine renderer safety, architecture, API migration, and documentation regeneration in a single patch.

## Final verification gate

At minimum run:

```text
cargo test --test render_tests
cargo test
cargo clippy -- -D warnings
tools/python.cmd tools/audit/unit_test_api_coverage.py --module render --json
tools/python.cmd tools/audit/lua_test_structure_audit.py --module render
tools/python.cmd tools/audit/lua_nonunit_test_audit.py --module render --heuristic-body-check
tools/python.cmd tools/audit/example_coverage.py render
tools/python.cmd tools/audit/example_lint.py content/examples/render.lua
tools/python.cmd tools/audit/spec_api_coverage.py --module render
tools/python.cmd tools/audit/docstring_audit.py src/lua_api/render_api.rs
tools/python.cmd tools/audit/module_docstring_audit.py --src src/render --check
tools/python.cmd tools/audit/audit_module.py render
tools/python.cmd tools/audit/perf_regression_gate.py
tools/python.cmd tools/validate/cag_validate.py
tools/python.cmd tools/audit/cag_link_check.py --strict
```

Also run the new backend/security/stress/recovery/evidence commands. Record unrelated pre-existing strict-link failures separately, but do not waive new render-owned failures.

## Definition of done

- Render Plans 1–3 P0/P1 work is implemented or explicitly dispositioned with an owner and technical rationale.
- API counts agree across every tool and every stable API has semantic unit/example/spec/doc coverage.
- Render-owned security and stress suites cover all resource/command families and execute real validation/backend paths.
- Measured performance, memory, upload, cache, and recovery gates pass.
- Architecture imports and public namespaces match documented ownership.
- `src/render/AGENTS.md` and review skills capture durable checks in compact form.
- No unrelated user change is reverted or absorbed into implementation commits.

