# Lurek2D Test Suite Overview

Lurek2D uses a two-layer test system executed through cargo:

- Rust tests in tests/rust/ for engine internals.
- Lua BDD tests in tests/lua/ for lurek.* behavior.

This file is a short contributor guide. The architecture source of truth is docs/architecture/test-framework.md.

## Quick Commands

| Goal | Command |
|---|---|
| Full quality gate | python tools/dev/parallel_cargo.py fmt check ; python tools/dev/parallel_cargo.py clippy --deny-warnings ; python tools/dev/parallel_cargo.py test rust ; python tools/dev/parallel_cargo.py test lua |
| Run Rust tests only | python tools/dev/parallel_cargo.py test rust |
| Run Lua tests only | python tools/dev/parallel_cargo.py test lua |
| Strict Lua API coverage | python tools/audit/unit_test_api_coverage.py --threshold 50 |
| Describe gate | python tools/audit/lua_api_test_coverage.py --strict --describe-threshold <N> |
| Analytics JSON | python tools/audit/test_analytics.py --json |
| Analytics HTML | python tools/audit/test_analytics.py --html |
| Perf Regression Gate | python tools/audit/perf_regression_gate.py --min-stress-pct 35 |
| Generate Contract Tests | python tools/audit/gen_lua_contract_tests.py |
| Mutation Report | python tools/audit/mutation_report.py |
| Colocated game tests | cargo test --test lua_tests lua_demo_colocated_games -- --test-threads=1 |
| Python tool self-tests | python -m unittest discover -s tests/python -p "test_*.py" -q |

## Directory Layout

- tests/rust/unit/: per-module Rust unit tests for private/internal logic.
- tests/rust/stress/: Rust load and throughput checks.
- tests/rust/golden/: deterministic Rust golden checks.
- tests/rust/config/: configuration tests.
- tests/rust/security/: sandbox and path safety tests.
- tests/rust/ext/: cross-module Rust smoke tests.
- tests/lua_tests.rs: explicit registration of Lua test files.
- tests/lua_harness_template.rs: manual scaffold for regenerating the Lua harness; not a Cargo test target.
- tests/python/: stdlib `unittest` self-tests for repo audit and validation tools.
- tests/lua/unit/: one file per module for lurek.* API contracts.
- tests/lua/library/: canonical one file per pure-Lua library.
- tests/lua/integration/: tests touching at least 2 modules.
- tests/lua/stress/: high iteration Lua load tests.
- tests/lua/security/: hostile input and safety behavior.
- tests/lua/evidence/: runtime evidence production.
- tests/lua/golden/: deterministic comparison against baselines.
- tests/lua/config/: Lua config tests.
- content/games/**/test.lua: colocated headless demo/game tests discovered by the Lua harness.
- tests/lua/fixtures/: shared helpers (e.g. world_helpers.lua via dofile).
- tests/artifacts/current/: current generated evidence artifacts.
- tests/artifacts/baselines/: committed golden baselines used for comparison.

## Artifact Contract

- `tests/artifacts/` is the only top-level folder for Lua evidence and golden artifacts.
- `tests/artifacts/current/` stores fresh generated evidence artifacts.
- `tests/artifacts/baselines/` stores committed golden/reference baselines.
- Do not create parallel artifact folders such as `tests/output/`, `tests/samples/`, or `save/golden_text/`.

## Marker Rules

Folder marker mapping is strict:

- tests/lua/unit/ -> @covers
- tests/lua/security/ -> @security
- tests/lua/integration/ -> @integration
- tests/lua/stress/ -> @stress
- tests/lua/evidence/ -> prose rationale comments above each `it()`

Rules:

- Markers must be directly above the it() they annotate.
- Marker indentation must match that it() block.
- @covers entries must be assertion-backed in the same it().
- In `tests/lua/unit/`, every `it()` must have exactly one directly-adjacent `@covers`.
- In `tests/lua/unit/`, every public Lua API should own exactly one `it()` across the full unit suite.
- @tests is forbidden.

## Evidence and Golden

Use a two-step flow:

1. Evidence tests create artifacts from runtime behavior.
2. Golden tests compare output to committed baselines.
3. Refresh committed baselines from fresh evidence with `python tools/audit/reseed_lua_artifacts.py --clean`.

Do not mix production and comparison in one it() case.

Evidence naming contract:

- Keep one canonical evidence file per public module: `test_<module>_evidence.lua`.
- Write module-owned artifacts under `tests/artifacts/current/<module>/`.
- Prefer descriptive artifact names such as `layout_dashboard_desktop_1280x720.png` or `procgen_cellular_cave_map.png`.
- Avoid vague folder names like `combined`, `advanced`, `misc`, or category-only roots when the owning `lurek.*` module is known.
- Do not put file-level `@covers` markers in evidence files.
- Keep one module-owned evidence file: `test_math_evidence.lua` should demonstrate `lurek.math.*` and math-owned userdata only, not helper sinks like `lurek.image.savePNG`.
- Put a short rationale block above every evidence `it()` with:
  `-- Does:`
  `-- Shows:`
  `-- Artifact:`
  `-- Why:`
- The artifact should visualize or export results computed from the target API. Do not add draw helpers to unrelated Lurek modules only to make evidence easier.

## Harness and Registration

Most Lua suites use explicit `#[test]` entries in `tests/lua_tests.rs`. Exception:

- `lua_demo_colocated_games` — runs every `content/games/**/test.lua`.

All other new Lua files need a harness entry or they will not run under `cargo test`.

## Roadmap gaps (ideas/tests)

Still open after the demo scaffold:

- Describe-coverage gate and orphaned `@covers` cleanup (batch per `testing-ecosystem` skill).
- Phase 3: dedicated error-handling blocks, nil-argument audit, float `expect_near` sweep.
- Full `content/games/**` demo coverage (27 headless tests today; ~100+ game folders remain).
- Visual regression pipeline and evidence CI minimum gate.

## CI and Artifacts

Workflow .github/workflows/test-analytics.yml runs on Windows and Linux and publishes:

- logs/data/lua_api_test_coverage.json
- logs/reports/lua_api_test_coverage.md
- logs/data/test_analytics.json
- logs/reports/test_analytics.html

## Notes

- Never edit generated API docs manually.
- Keep tests deterministic: fixed seeds, fixed dt, no wall-clock assumptions.
- Use expect_near for float comparisons in Lua tests.
