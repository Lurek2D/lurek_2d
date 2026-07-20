---
name: create-test-stress
description: "Load this skill when creating or modifying stress tests, ceilings, or heavy-load validation for a module. Skip it for normal unit tests, integration tests, or benchmark-free code reviews."
---

# create-test-stress

## Mission
- Create or modify stress coverage that records realistic load ceilings and failure behavior.
- Keep canonical `tests/lua/stress/test_<module>_stress.lua` ownership exact: `1 API = 1 @stress marker = 1 it()`.

## Domain Knowledge
- A stress test proves a declared ceiling—items, bytes, dimensions, recursion, frames, allocations, or elapsed work—and the engine's behavior at and beyond that ceiling; “run a lot of data” is not a stable contract.
- Canonical Lua stress ownership remains one generated API per adjacent `-- @stress` marker and `it()`, while `stress_report.py` aggregates workload evidence; multi-API load stories belong in a separate scenario only when ownership stays unambiguous.
- Dense and sparse representations need different datasets because identical logical size can imply radically different allocation and traversal cost; negative coordinates, empty regions, dirty updates, and serialization often define the real worst case.
- Stress output must distinguish bounded rejection, graceful degradation, timeout, OOM, and performance regression. A caught error can be the correct outcome when it proves a documented budget.
- Release-mode measurements and recorded environment/scenario parameters are required for comparisons; debug timings are useful for correctness only.
- Cleanup and recovery after rejection are stress properties: an over-limit call must not leave partial allocations, dirty indexes, callbacks, or a module that fails the next valid operation.
- Workload construction should remain cheaper and more predictable than the operation under test; precompute fixtures or use compact generators so setup does not dominate the reported ceiling.
- Thresholds tied to memory or serialized input should use checked arithmetic in the test generator too, otherwise the fixture can overflow or allocate catastrophically before the engine boundary is exercised.

## Workflow
- Define the budget and failure oracle first: exact API owner, workload shape, at-limit and over-limit inputs, expected rejection/degradation, release environment, timeout, and metrics; capture an existing baseline before changing the stress case.
- Extend the canonical module stress file with one deterministic adjacent-marker block, generating dense/sparse or adversarial shapes that target the implementation rather than simply maximizing counts; keep temporary raw reports under the task's `work/` folder.
- Run the narrow case in release mode with bounded resources, classify its outcome as pass/rejection/regression/timeout/OOM, and inspect allocation/work behavior around the threshold to catch off-by-one budgets or cleanup leaks.
- Rerun non-unit ownership and stress reports, compare against the recorded baseline and documented ceiling, and keep the threshold only when it is stable enough to detect regression without depending on one workstation's incidental timing.
- Follow every over-limit or timed scenario with a small valid operation and explicit state check, proving bounded failure and cleanup rather than merely surviving the invocation.
- Record dataset-generation cost separately from engine-operation cost and keep report fields stable enough for `stress_report.py` and historical parsers to compare results.

## References
- `contracts: tests/AGENTS.md, tests/lua/AGENTS.md, tools/audit/AGENTS.md, work/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "stress tests performance ceilings" --profile engine --limit 10, tools/python.cmd tools/audit/lua_nonunit_test_coverage.py --category stress, tools/python.cmd tools/audit/stress_report.py`
- `agent: tester`
- RAG: Use when locating load tests and perf ceilings; `stress tests performance ceilings`; `benchmark stress report threshold`; `perf regression scenario workload`; `tests/`; `tools/audit/`; `work/` reports; suspect hot paths in `src/`
