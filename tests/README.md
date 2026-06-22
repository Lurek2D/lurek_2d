# Lurek2D Test Suite Overview

Lurek2D uses two main test layers:

- Rust tests in `tests/rust/` for internal engine behavior.
- Lua BDD tests in `tests/lua/` for the public `lurek.*` API.

This file is the contributor guide for test ownership. The lifecycle source of truth is [../docs/architecture/quality-assurance.md](../docs/architecture/quality-assurance.md), and documentation ownership is defined in [../docs/architecture/docs-system.md](../docs/architecture/docs-system.md).

## Quick Commands

| Goal | Command |
|---|---|
| Full quality gate | `tools/python.cmd tools/dev/parallel_cargo.py fmt check ; tools/python.cmd tools/dev/parallel_cargo.py clippy --deny-warnings ; tools/python.cmd tools/dev/parallel_cargo.py test rust ; tools/python.cmd tools/dev/parallel_cargo.py test lua` |
| Run Rust tests only | `tools/python.cmd tools/dev/parallel_cargo.py test rust` |
| Run Lua tests only | `tools/python.cmd tools/dev/parallel_cargo.py test lua` |
| Example coverage gate | `tools/python.cmd tools/validate/validate_example_coverage.py` |
| Lua unit API coverage | `tools/python.cmd tools/audit/unit_test_api_coverage.py` |
| Lua non-unit audit | `tools/python.cmd tools/audit/lua_nonunit_test_coverage.py` |
| Lua structure audit | `tools/python.cmd tools/audit/lua_test_structure_audit.py --path tests/lua/unit` |
| Evidence/golden contract audit | `tools/python.cmd tools/audit/lua_evidence_golden_contract_audit.py` |
| Analytics JSON | `tools/python.cmd tools/audit/test_analytics.py --json` |
| Analytics HTML | `tools/python.cmd tools/audit/test_analytics.py --html` |
| Colocated game tests | `cargo test --test lua_tests lua_demo_colocated_games -- --test-threads=1` |
| Python tool self-tests | `python -m unittest discover -s tests/python -p "test_*.py" -q` |

## Directory Layout

- `tests/rust/unit/`: per-module Rust unit tests for private/internal logic.
- `tests/lua/unit/`: one file per public module for Lua API contracts.
- `tests/lua/library/`: one file per pure-Lua library.
- `tests/lua/integration/`: tests touching at least two modules.
- `tests/lua/stress/`: high-iteration Lua load tests.
- `tests/lua/security/`: hostile input and safety behavior.
- `tests/lua/evidence/`: runtime artifact production.
- `tests/lua/golden/`: deterministic comparison against baselines.
- `content/games/**/test.lua`: colocated headless game tests discovered by the Lua harness.
- `tests/artifacts/current/`: current generated evidence artifacts.
- `tests/artifacts/baselines/`: committed golden baselines used for comparison.

## Ownership Order

This repo uses a strict public-content chain:

1. API docs define the public surface.
2. `content/examples/` shows one concrete usage block for every public API.
3. `tests/lua/unit/` proves every public API works.
4. `tests/lua/evidence/` generates selected artifacts that show behavior in a legible way.
5. `tests/lua/golden/` compares those artifacts against reviewed baselines.
6. `content/games/` packages APIs into complete games or mini games.

Each layer has a different job. Do not collapse them into one folder.

## Marker Rules

Folder marker mapping is strict:

- `tests/lua/unit/` -> `@covers`
- `tests/lua/security/` -> `@security`
- `tests/lua/integration/` -> `@integration`
- `tests/lua/stress/` -> `@stress`
- `tests/lua/evidence/` -> prose rationale comments above each `it()`

Rules:

- Markers must be directly above the `it()` they annotate.
- In `tests/lua/unit/`, every `it()` must have exactly one directly-adjacent `@covers`.
- In `tests/lua/unit/`, every public Lua API should own exactly one `it()` across the full unit suite.
- In `tests/lua/unit/`, one `it()` may contain many assertions if they all prove the same API.
- File-level `@covers` are forbidden in evidence files.

## Evidence and Golden

Use a two-step flow:

1. Evidence tests create artifacts from runtime behavior.
2. Golden tests compare output to committed baselines.
3. Refresh committed baselines from fresh evidence with `tools/python.cmd tools/audit/reseed_lua_artifacts.py --clean`.

Do not mix production and comparison in one `it()` case.

Evidence artifacts must be purposeful:

- Keep one module-owned evidence file when the owner is known.
- Write module-owned artifacts under `tests/artifacts/current/<module>/`.
- Put a short rationale block above every evidence `it()` with:
  - `-- Does:`
  - `-- Shows:`
  - `-- Artifact:`
  - `-- Why:`
- If the artifact does not make clear what it proves, it is a bad evidence artifact even if it renders correctly.

## Current Cleanup Focus

- Fix example ownership and 100% example coverage.
- Fix Lua unit ownership and remove public API duplication from Rust tests.
- Eliminate stale evidence files that generate artifacts with no clear review purpose.
- Move feature showcases and mechanic scraps out of `content/games/`.
- Keep generated baselines in sync only with evidence that still has a clear owner and purpose.

## Notes

- Never edit generated API docs manually.
- Keep tests deterministic: fixed seeds, fixed dt, no wall-clock assumptions.
- Use `expect_near` for float comparisons in Lua tests.
