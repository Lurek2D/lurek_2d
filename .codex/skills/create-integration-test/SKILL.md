---
name: create-integration-test
description: "Load this skill when creating or modifying Lua integration tests that prove interactions between two or more modules. Skip it for single-module unit tests, Rust-only internal tests, or performance stress tests."
---

# create-integration-test

## Mission
- Create or modify integration tests that verify cross-module public Lua behavior.
- Keep one canonical `test_<modules>_integration.lua` file per module-pair or module-set, and keep `@integration` markers aligned with the APIs each scenario actually exercises.

## Domain Knowledge
- Integration ownership is the smallest stable module pair or set under `tests/lua/integration/`, not whichever subsystem happens to trigger the scenario first.
- A real integration test proves that state produced through one public `lurek.*` surface is consumed, transformed, or observed through another; merely calling two namespaces is not sufficient.
- `-- @integration` markers inventory APIs actually participating in the scenario, so stale or aspirational markers corrupt cross-module coverage.
- Deterministic orchestration needs explicit setup order, bounded frame/time advancement, and assertions at the consumer boundary.
- Harness registration in `tests/lua_tests.rs` is part of ownership; an unregistered Lua file provides no executable coverage.
- Cross-module timing must name the propagation contract: immediate mutation, next process step, next draw snapshot, queued callback, or eventual async completion. Assertions at the wrong phase can accidentally bless stale state.
- Integration fixtures should use the smallest public objects that cross the boundary; importing a full game or broad helper can add unrelated module dependencies and make ownership audits misleading.
- Cleanup is part of the interaction proof when modules register listeners, callbacks, physics bodies, audio, or renderer resources; a passing first scenario can hide contamination that breaks the next scenario.

## Workflow
- Use coverage output and involved specs to identify the boundary and canonical owner; state the producer condition, consumer observation, and failure a unit test would miss.
- Build deterministic setup through public APIs, advance only required frames/timers, assert producer precondition and consumer result, and mark only calls that materially participate in the boundary.
- Modify the existing pair/set owner or create and register `test_<modules>_integration.lua` when the semantic combination is new, preserving a narrow filterable scenario name.
- Run the filtered harness and integration audit, then perturb input or timing to prove the assertion is sensitive to the interaction rather than default state; finish by clearing marker mismatches and duplicate ownership.
- Run the scenario twice in one harness process where lifecycle state permits, proving teardown and re-registration do not create duplicate notifications, retained handles, or order-dependent results.
- Check the scenario against both involved unit suites: retain assertions that specifically prove propagation or shared semantics, and move standalone validation back to the single-module owner instead of growing an integration catch-all.

## References
- `contracts: tests/AGENTS.md, tests/lua/AGENTS.md, content/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "Lua integration tests module interaction" --profile game --limit 10, tools/python.cmd tools/audit/integration_coverage.py, tools/python.cmd tools/audit/lua_nonunit_test_coverage.py --category integration, cargo test --test lua_tests`
- `agent: tester`
- RAG: Use when finding existing multi-module test patterns; `Lua integration tests module interaction`; `tests lua integration scene input physics`; `assert helper fixture register`; `tests/lua/`; `tests/lua/harness/`; `library/`; touched modules in `src/` or `content/`
