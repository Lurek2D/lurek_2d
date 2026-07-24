---
name: create-test-integration
description: "Load this skill when creating or modifying cross-module Lua scenarios under tests/lua/integration. Skip it for single-module unit ownership, Rust-only seams, evidence artifacts, or performance ceilings."
---

# create-test-integration

## Mission
- Create or modify integration tests that verify cross-module public Lua behavior.
- Keep one canonical `test_<modules>_integration.lua` file per module-pair or module-set, and keep `@integration` markers aligned with the APIs each scenario actually exercises.

## Domain Knowledge
- Lua integration tests live under `tests/lua/integration/`.
- One file owns one stable module pair or module set.
- File names use `test_<modules>_integration.lua`.
- Integration tests use public `lurek.*` APIs.
- A test must prove data or behavior crossing a module boundary.
- Calling two namespaces is not enough.
- `-- @integration` markers list APIs used by the scenario.
- Marker indentation matches the owning `it()` block.
- Integration files are registered in `tests/lua_tests.rs`.
- An unregistered file is not executable coverage.
- The scenario defines when the result becomes visible.
- Visibility may be immediate, next update, next draw, callback, or async completion.
- Setup order and frame advancement are deterministic.
- Assertions are placed at the consumer boundary.
- Cleanup covers callbacks, bodies, audio, and renderer resources.
- Unit-only behavior stays in module unit tests.
- Every BDD integration file starts with a plain prose header comment.
- Each `describe()` has a directly preceding `-- @describe` marker.
- A describe docstring contains only its `@describe` text.
- Integration blocks use `@integration`, not `@covers` or legacy `@tests` markers.
- The marker lists the public APIs whose interaction is proved by that scenario.
- A runnable integration file ends with one bare `test_summary()` line.

## Workflow
1. Read the tests and Lua tests contracts.
2. Name the producer module and consumer module.
3. State the result that a unit test cannot prove.
4. Find the existing pair or set owner.
5. Create a new file only for a new stable boundary.
6. Register a new file in `tests/lua_tests.rs`.
7. Build minimal setup with public APIs.
8. Assert the producer precondition.
9. Advance only the required frames or timers.
10. Assert the result at the consumer boundary.
11. Add markers only for participating APIs.
12. Run the narrow harness filter.
13. Change one input or timing value and confirm the test fails.
14. Run the integration coverage audit.
15. Run the scenario twice in one process.
16. Remove unit-only assertions from the integration test.

## References
- `contracts: tests/AGENTS.md, tests/lua/AGENTS.md, content/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "Lua integration tests module interaction" --profile game --limit 10, tools/python.cmd tools/audit/integration_coverage.py, tools/python.cmd tools/audit/lua_nonunit_test_coverage.py --category integration, cargo test --test lua_tests`
- `agent: tester`
- RAG: `Lua integration tests <producer> <consumer> propagation`; inspect `tests/lua/integration/`, both unit owners, involved specs, and harness registration.
