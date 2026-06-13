# Tests Contract

## Mission & Scope
- Own test strategy, harnesses, coverage rules, smoke tests, and artifacts.
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
- Audit Lua ownership and structure with `python tools/audit/unit_test_api_coverage.py`, `python tools/audit/lua_nonunit_test_coverage.py`, and `python tools/audit/lua_test_structure_audit.py --path tests/lua/unit`.
- Reseed Lua baselines with `python tools/audit/reseed_lua_artifacts.py --clean` when evidence or golden paths change.
