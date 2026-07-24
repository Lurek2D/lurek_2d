---
name: create-test-stress
description: "Load this skill when creating or modifying stress tests, ceilings, or heavy-load validation for a module. Skip it for normal unit tests, integration tests, or benchmark-free code reviews."
---

# create-test-stress

## Mission
- Create or modify stress coverage that records realistic load ceilings and failure behavior.
- Keep canonical `tests/lua/stress/test_<module>_stress.lua` ownership exact: `1 API = 1 @stress marker = 1 it()`.

## Domain Knowledge
- Lua stress tests live under `tests/lua/stress/`.
- One module uses one canonical `test_<module>_stress.lua` file.
- One stress owner uses one adjacent `-- @stress` marker and `it()`.
- A stress test names an exact API and exact workload.
- A ceiling may use items, bytes, dimensions, depth, frames, or allocations.
- At-limit and over-limit cases are separate inputs.
- Valid outcomes are success, bounded rejection, or documented degradation.
- Timeout, OOM, and regression are separate failure classes.
- Timing comparisons use release mode.
- Debug mode is for correctness only.
- Dense and sparse inputs are separate workload shapes.
- Negative coordinates and empty regions are valid stress dimensions when supported.
- Fixture generation cost is separate from engine operation cost.
- Over-limit failure must not leave partial state.
- A small valid operation must work after rejection.
- `stress_report.py` consumes stable report fields.
- Stress files use the same plain header and `-- @describe` grammar as other BDD Lua tests.
- One stressed API has one `@stress` family marker and one owning `it()`.
- Hostile-input families use the separate `@security` layer and marker.
- Legacy `@tests`, `@description`, and `@category` markers are invalid in stress files.
- A runnable stress file ends with one bare `test_summary()` line.
- Stress and profiling reports are valid only from release-mode execution.

## Workflow
1. Read the tests, Lua tests, and audit contracts.
2. Select the exact API owner.
3. Define the workload shape and metric.
4. Define the documented or proposed ceiling.
5. Define at-limit and over-limit inputs.
6. Define success, rejection, timeout, OOM, and regression outcomes.
7. Capture the current release baseline.
8. Add one canonical marker and `it()` block.
9. Keep fixture generation bounded and deterministic.
10. Run the narrow case in release mode.
11. Record setup cost and engine-operation cost separately.
12. Run a small valid operation after the over-limit case.
13. Run the non-unit ownership audit.
14. Run `stress_report.py`.
15. Compare with the baseline.
16. Keep only stable thresholds.

## References
- `contracts: AGENTS.md, tests/AGENTS.md, tests/lua/AGENTS.md, tools/audit/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "stress tests performance ceilings" --profile engine --limit 10, tools/python.cmd tools/audit/lua_nonunit_test_coverage.py --category stress, tools/python.cmd tools/audit/stress_report.py`
- `agent: tester`
- RAG: `stress tests <module> performance ceiling workload`; inspect the canonical stress owner, documented budget, `stress_report.py`, prior baseline, and suspected Rust hot path.
