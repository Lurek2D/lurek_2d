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
- Root `*.rs`: Lua harness and content/workbench smoke targets.

## Rules
- Test public `lurek.*` behavior in Lua. Use Rust for private helpers, internal logic, and Lua-unreachable glue.
- Examples teach use. Unit tests prove behavior. Evidence creates artifacts. Golden tests compare them.
- Keep tests deterministic; use epsilon ranges for floats.
- Register new Lua suites through `tests/lua_tests.rs`.
- Use explicit state assertions, not only side-effect checks.
- Write fresh evidence only under `tests/artifacts/current/`.
- Store committed Lua golden baselines only under `tests/artifacts/baselines/`.
- Do not create parallel roots such as `tests/output/`, `tests/samples/`, or `save/golden_text/`.
- Lua artifact tools use `tests/artifacts/.lua_artifacts.lock`.
- Follow the nearest child `AGENTS.md` for file names, markers, and layer rules.

## Workflow
- Run `cargo test`.
- Run `tools/python.cmd -m unittest discover -s tests/python -p "test_*.py" -q` after Python tool changes.
- Run the focused audit named by the nearest test contract.
