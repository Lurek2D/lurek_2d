# UI Plan 4 of 4: Tests, Evidence, CAG Updates, and Implementation Sequence

## Purpose

Provide the proof and repository guidance required to implement UI Plans 1–3 safely. This plan turns the audit findings into a staged execution backlog with owners, regression artifacts, skill updates, and compact `AGENTS.md` corrections.

## Baseline to preserve and distrust appropriately

- `cargo test --test ui_tests` passes 2/2.
- `cargo clippy -- -D warnings` passes.
- Lua unit marker structure reports 507/507 exact owners and no duplicates.
- UI examples/specs report 507/507.
- The quality dashboard passes globally, but the UI module audit reports only 2 Rust tests for a large public surface, 80+ structured-doc gaps, thin-wrapper hotspots, exact-float assertions, and an `unwrap` in `focus.rs`.
- The file-doc audit fails 5/19 UI files.
- The global performance gate passes without a UI-owned benchmark/ceiling.
- No dedicated UI stress or security suite establishes hostile-input and lifecycle behavior.

The implementation must not use the marker percentages as a substitute for semantic evidence.

## Test ownership matrix

| Risk/behavior | Primary proof | Secondary proof |
|---|---|---|
| Arena generations and cleanup | Rust unit/property tests | Lua lifecycle tests |
| Public argument/error semantics | Lua unit tests | API/doc examples |
| Widget tree/layout/event interactions | Lua integration tests | Rust invariant tests |
| GameFS/path/output boundaries | Lua security tests | Rust filesystem-policy tests |
| Layout transaction rollback | Rust + Lua integration | fuzz corpus |
| GPU/software capture parity | evidence/golden tests | command-structure assertions |
| UI scale, dirty caching, queues | release stress/perf | telemetry assertions |
| Docs/spec/examples | audit tools | generated artifact diff |

## P0 — Strengthen Rust tests around private seams

Add focused tests under the existing Rust test ownership pattern for:

- generational store insertion/removal/reuse and cross-context rejection;
- root preservation and full cleanup after subtree destruction/clear;
- tree invariants under reparent, detach, cycle attempts, invalid handles, and randomized mutation sequences;
- dirty-generation propagation and equivalence to forced full layout/render recomputation;
- bounded event queues, callback registry cleanup, and reentrant mutation journal behavior;
- transactional layout construction and rollback after failure at every stage;
- finite/range validation and checked allocation calculations;
- iterative/depth-limited traversals;
- UI-to-render command lowering independent of Lua registration;
- removal of the `focus.rs` unwrap and proof of its former invariant.

Replace exact float equality where calculations are non-integral with documented tolerances. Keep exact assertions for deliberately exact state.

## P0 — Upgrade Lua unit tests from ownership to semantics

- Preserve exactly one owning marker per API, but make the owning test assert observable behavior.
- Add table-driven invalid cases for nil, wrong type, NaN/infinity, negative/out-of-range values, unknown option keys, oversized strings/collections, stale handles, wrong widget types, and released resources.
- Require all formerly inert APIs to produce visible state/layout/render changes or a documented deprecation error.
- Add callback tests for order, arguments, replacement/removal, error isolation, reentrancy, destruction during callback, and registry cleanup.
- Add layout tests for GameFS, bindings, duplicate IDs, cycles, limits, rollback, and source diagnostics.
- Add screenshot/capture tests for both supported calling forms during deprecation, dimension limits, output policy, failure atomicity, and render-software delegation.
- Test all compatibility aliases against the canonical API, including identical errors and side effects.

Do not use “does not crash,” `tostring`, or “is callable” as the only assertion for feature-shaped APIs.

## P0 — Add UI-owned integration, security, and stress suites

### Integration

- Build a UI through Lua, inject normalized input, update, collect render commands, and verify callbacks plus visual state.
- Cover focus/modal/capture/drag/drop across nested widgets.
- Cover declarative load, binding update, theme/DPI change, and dynamic subtree reconciliation.
- Cover entity anchor snapshots without importing ECS internals into UI.
- Cover UI capture through render software replay and image encoding as a cross-module test with explicit owners.

### Security

Create a UI-owned security file containing only UI/file-boundary scenarios:

- forged/stale/cross-context handles;
- traversal/absolute/link/device/reserved output paths;
- malformed and oversized TOML/Lua tables;
- excessive depth, widgets, rows, strings, events, callbacks, commands, and screenshot dimensions;
- NaN/infinity/extreme numeric values;
- callback reentrancy/error loops and destruction races;
- atomic rollback/write behavior.

Every case must assert a bounded rejection, stable error category, and preserved state. Do not mix unrelated module tests into this file.

### Stress/performance

- Run release-mode scenarios at and immediately beyond each `UiLimits` boundary.
- Execute real layout, input routing, command generation, and software capture rather than only enqueueing calls.
- Record time, allocations, queue/capacity high-water marks, nodes visited, commands, and cache hits.
- Add repeated create/destroy/clear cycles to catch registry or retained-capacity leaks.
- Establish reproducible reference baselines and regression thresholds.

## P1 — Create evidence and golden artifacts

- Golden UI captures for representative widget families, nested clipping, text, images, theme inheritance, DPI, modal overlays, scrolling, and error/disabled/focus states.
- Structural snapshots of widget tree, computed layout, focus order, semantic/accessibility tree, and emitted command list.
- Parity evidence comparing full versus incremental recomputation and GPU versus software capture.
- Transaction evidence proving failed loads leave no new widgets/callbacks/events.
- Keep artifacts small, deterministic, versioned, and generated through registered repository tooling.

## P0 — Repair test and coverage tooling before gating

- Introduce the canonical API inventory described in UI Plan 3.
- Make `unit_test_api_coverage`, `example_coverage`, `spec_api_coverage`, `audit_module`, and quality reports fail on inventory disagreement.
- Report canonical entries, aliases, userdata methods, namespace functions, missing semantic category, and shallow-test warnings separately.
- Add a feature-no-op audit that flags public functions whose body intentionally discards parameters, contains “reserved for future,” or only returns success without state/output. Use it as a review prompt, not an unsound automatic proof.
- Add module-owned nonunit checks that reject a security/stress file dominated by other module APIs.
- Make audit commands and help text consistently use `tools/python.cmd`, actual positional/flag syntax, and the real report path.
- Add fixtures/self-tests for every parser before trusting repaired counts.

## P0 — Update compact repository guidance

### `src/ui/AGENTS.md`

Rewrite it after the architecture decisions, keeping it in the same compact size range (target roughly 18–28 lines). It must:

- name real current owners (`context.rs` and its submodules, `widget.rs`, `controls.rs`, `extras.rs`, `theme.rs`, `layout_loader.rs`, render lowering files);
- remove stale nonexistent `layout.rs`, `dialog.rs`, and `events.rs` claims;
- replace the nonexistent `gui_tests` target with `ui_tests` and add relevant Lua/security/perf commands;
- state opaque generational handles, cleanup, limits, GameFS, layout transaction, and UI-to-render boundary;
- route full details to specs/skills instead of expanding the contract.

### Other contracts

- Update only the nearest `tests/lua/*/AGENTS.md` if a new registered UI security/stress/evidence path needs an ownership rule.
- Update architecture/docs contracts only if their current routing cannot express the new owner boundary.
- Keep root `AGENTS.md` unchanged unless a genuinely repository-wide rule is missing.

## P0 — Update review skills so the next audit catches these gaps

Edit the smallest relevant local skills, preserving their validation and owner routing:

- `review-all`: require canonical inventory parity before accepting coverage; scan lifecycle identity, no-op APIs, aggregate budgets, path/trust boundaries, cross-module dependency direction, and module-owned security/stress evidence.
- `review-api`: check forgeable/raw identities, stale handles, alias ownership, inert feature-shaped APIs, and authoritative namespace placement.
- `review-tests`: require semantic assertions, adversarial limit tests, callback/resource lifecycle tests, and reject cross-module contamination in nonunit suites.
- `review-performance`: require module-specific release baselines, cumulative work budgets, retained-capacity checks, and incremental/full equivalence evidence.
- `review-docstrings`: require qualitative file-doc review against `rust_file_docstring_guidelines.md`, not merely `//!` existence/length.
- `review-architecture`: verify source dependency direction and public API ownership rather than trusting architecture prose.
- `review-examples` and `review-specs`: consume the canonical inventory and flag callable no-ops or mismatched feature status.

Keep skill additions general enough to benefit other stateful modules; do not hard-code UI filenames except as optional examples. Run CAG validation and strict link checking afterward.

## Ordered implementation waves for Luna GPT 5.6

### Wave 0 — Freeze evidence and decisions

1. Record current command outputs and golden fixtures under `work/{task}/` as temporary evidence.
2. Approve the handle, destruction, callback-error, path/output, and module-boundary decisions.
3. Repair canonical API inventory tooling so later percentages are trustworthy.

### Wave 1 — Correctness foundation

1. Implement generational `WidgetId` and checked Lua extraction.
2. Implement destruction/clear cleanup and lifecycle tests.
3. Add `UiLimits`, finite validation, bounded queues/traversal, and security tests.
4. Make layout loading and image output transactional/sandboxed.

### Wave 2 — Rendering and performance boundary

1. Consolidate software capture into render.
2. Add dirty generations/caches and equivalence tests.
3. Measure, then optimize hit testing and retained allocation.
4. Add UI release performance baselines and ceilings.

### Wave 3 — Feature/API completion

1. Implement or deprecate entity attachment, section widgets, separators, and spacers.
2. Add virtualization, declarative reconciliation, accessibility semantics, and viewport inputs only in the scoped forms from UI Plan 2.
3. Complete compatibility aliases and migration warnings.

### Wave 4 — Documentation and CAG closure

1. Update source docstrings, file docs, spec, architecture, examples, and narrative docs.
2. Update compact `AGENTS.md` and review skills.
3. Regenerate artifacts and run every gate.

Do not combine all waves into one unreviewable patch. Each wave should end with a green focused suite and an evidence note.

## Final verification gate

At minimum run:

```text
cargo test --test ui_tests
cargo test
cargo clippy -- -D warnings
tools/python.cmd tools/audit/unit_test_api_coverage.py --module ui --json
tools/python.cmd tools/audit/lua_test_structure_audit.py --module ui
tools/python.cmd tools/audit/lua_nonunit_test_audit.py --module ui --heuristic-body-check
tools/python.cmd tools/audit/example_coverage.py ui
tools/python.cmd tools/audit/example_lint.py content/examples/ui.lua
tools/python.cmd tools/audit/spec_api_coverage.py --module ui
tools/python.cmd tools/audit/docstring_audit.py src/lua_api/ui_api.rs
tools/python.cmd tools/audit/module_docstring_audit.py --src src/ui --check
tools/python.cmd tools/audit/audit_module.py ui
tools/python.cmd tools/audit/perf_regression_gate.py
tools/python.cmd tools/validate/cag_validate.py
tools/python.cmd tools/audit/cag_link_check.py --strict
```

Also run the new UI integration/security/stress/evidence commands registered by the implementation. Treat unrelated pre-existing strict-link failures as an explicitly tracked repository blocker, not as permission to ignore new UI failures.

## Definition of done

- All UI plans’ P0/P1 items are implemented or explicitly dispositioned with owner and rationale.
- Canonical inventory counts agree across API, unit, example, spec, docs, and quality tools.
- Semantic unit/integration/security/stress/evidence suites prove lifecycle, limits, atomicity, boundaries, and performance.
- Documentation and examples match behavior and contain no inert or stale claims.
- `src/ui/AGENTS.md` and relevant skills capture the durable review rules without growing into duplicate specifications.
- No unrelated user change is reverted or folded into the implementation commits.

