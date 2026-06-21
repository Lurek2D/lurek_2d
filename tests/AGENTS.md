# Tests Contract

## Mission & Scope
- Own test strategy, harnesses, coverage rules, smoke tests, and artifacts.
- Keep the public content lifecycle ordered and non-overlapping: API docs -> examples -> Lua unit tests -> evidence artifacts -> golden comparisons -> games.
- Keep public API coverage Lua-first and internal seams Rust-tested.

## Files
- `lua/`: Canonical Lua tests for public `lurek.*`.
- `rust/`: Rust tests for private engine logic and wrapper glue.
- `python/`: Stdlib `unittest` self-tests for repo audit and validation tools.
- `fixtures/`: Deterministic test assets.
- `artifacts/current/`: Fresh evidence output.
- `artifacts/baselines/`: Committed golden baselines.
- `demo_smoke_tests.rs`, `games_load_test.rs`: Demo load and screenshot smoke tests.

## Rules
- Public `lurek.*` behavior is Lua-first. Put canonical ownership in `tests/lua/unit/`.
- Use Rust tests only for private seams, helpers, internal logic, and Lua-unreachable wrapper glue.
- Examples show usage. Lua unit tests prove behavior. Evidence emits artifacts. Golden compares artifacts. Games package behavior into complete user-facing projects.
- Keep one test file per module per layer: `test_<module>_<layer>.lua`.
- Keep tests deterministic; use epsilon ranges for floats.
- Register new Lua suites through `tests/lua_tests.rs`.
- Put headless demo tests next to the demo as `content/games/**/test.lua`.
- Use explicit state assertions, not only side-effect checks.
- Keep one Lua artifact root: `tests/artifacts/`.
- Write fresh evidence only under `tests/artifacts/current/`.
- Prefer module-owned evidence dirs and descriptive artifact names.
- Evidence files should stay module-owned, without top-level `@covers`, and should describe what the artifact does, shows, writes, and why it is meaningful.
- Store committed Lua golden baselines only under `tests/artifacts/baselines/`.
- Do not create parallel roots such as `tests/output/`, `tests/samples/`, or `save/golden_text/`.
- Treat audit counts for missing, exact, and duplicate API owners as source of truth.
- Lua artifact scripts use `tests/artifacts/.lua_artifacts.lock`; prefer canonical scripts.

## Workflow
- Run `cargo test`.
- Run `python -m unittest discover -s tests/python -p "test_*.py" -q` when changing Python audit or validation tools.
- Audit example and Lua ownership before broad cleanup with `tools/python.cmd tools/audit/example_coverage.py --report --no-stubs --no-partials`, `tools/python.cmd tools/audit/unit_test_api_coverage.py`, `tools/python.cmd tools/audit/lua_nonunit_test_coverage.py`, and `tools/python.cmd tools/audit/lua_test_structure_audit.py --path tests/lua/unit`.
- Audit evidence/golden contract drift with `tools/python.cmd tools/audit/lua_evidence_golden_contract_audit.py`, and reseed baselines with `tools/python.cmd tools/audit/reseed_lua_artifacts.py --clean` only after evidence output is intentionally refreshed.
