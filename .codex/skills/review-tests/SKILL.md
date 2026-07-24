---
name: review-tests
description: "Load this skill when auditing and fixing Lua unit test coverage, structure, harness registration, and public API test gaps. Skip it for Rust-only internal tests or non-test code reviews."
---

# review-tests

## Mission
- Audit and fix Lua test coverage and structure for public `lurek.*` APIs.

## Domain Knowledge
- Lua unit tests own public `lurek.*` APIs.
- Each generated public API entry has one canonical Lua unit owner.
- Integration tests prove behavior across module boundaries.
- Stress and security tests prove limits and hostile-input families.
- Evidence tests produce artifacts for human review.
- Golden tests compare current output with reviewed baselines.
- Rust tests own private engine seams and internal behavior.
- A coverage marker proves ownership metadata, not test execution or assertion quality.
- A test that only checks function type or callability is shallow.
- A canonical test proves visible state, return value, output, error category, or lifecycle.
- A consumer module using an API does not replace the producer module's unit owner.
- Duplicate unit owners split the public contract and are defects.
- Harness registration and filter names determine whether a file runs.
- BDD grammar, marker adjacency, indentation, and final `test_summary()` are executable structure.
- Float tests need an epsilon when exact equality is not the contract.
- Random tests need a fixed seed.
- Frame tests need bounded steps.
- Concurrent behavior needs a scheduling seam or deterministic coordination.
- Retrying a flaky test is not deterministic control.
- Evidence rationale and artifact legibility need manual inspection.
- Golden baselines need known provenance.
- `unit_test_api_coverage.py` checks unit ownership.
- `lua_nonunit_test_coverage.py` checks non-unit layers.
- `lua_test_structure_audit.py` checks Lua test file structure.
- `cargo test --test lua_tests` runs the Lua harness target.
- Heuristic API references found inside `it()` blocks do not count as explicit unit ownership.
- Unit coverage reports distinguish unique owners, duplicated owners, missing owners, and heuristic-only references.
- `--strict` is retained for compatibility; explicit `@covers` ownership is always the primary metric.
- Saved unit coverage data lives in `logs/data/unit_test_coverage.json` and `logs/reports/unit_test_coverage.md`.
- A Lua BDD file requires a plain header, directly preceding `@describe`, category markers, and final bare `test_summary()`.
- Legacy `@tests`, `@description`, and `@category` markers are structural failures.
- Demo headless tests live beside games as `lurek_2d_content/games/**/test.lua`.

## Workflow
1. Read root, test, and Lua test contracts.
2. Generate or inspect the public API inventory.
3. Run unit ownership coverage.
4. Run Lua unit structure audit.
5. Run non-unit coverage and evidence or golden contract audits.
6. Build a module table with API owner, layer, registration, target, and artifact.
7. Inspect every missing, duplicate, malformed, or misclassified owner.
8. Verify the harness filter executes the expected file and block.
9. Check assertion sensitivity by changing or tracing the exercised result.
10. Check normal, boundary, invalid, and lifecycle behavior where relevant.
11. Check seed, epsilon, frame bound, scheduling, and cleanup.
12. Open evidence artifacts and compare them with their rationale.
13. Verify golden baseline provenance and current-output generation.
14. Separate structure defects, weak assertions, missing behavior, wrong layer, and stale baseline.
15. Record exact file, API, evidence, narrow command, and expected result.
16. Use the matching test-creation skill when fixes are requested.
17. Consolidate duplicate unit owners into one canonical owner.
18. Run the isolated block.
19. Run the module or category suite.
20. Run `cargo test --test lua_tests`.
21. Rerun structure, coverage, and artifact audits.
22. Record environment failures separately from repository contract failures.

## References
- `contracts: AGENTS.md, tests/AGENTS.md, tests/lua/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "Lua test coverage structure harness public API" --profile game --limit 10, tools/python.cmd tools/audit/unit_test_api_coverage.py, tools/python.cmd tools/audit/lua_nonunit_test_coverage.py, tools/python.cmd tools/audit/lua_test_structure_audit.py --path tests/lua/unit, cargo test --test lua_tests`
- `agent: tester`
- RAG: `Lua test coverage structure harness <module>`; inspect generated API ownership, canonical layer/file, harness registration, audit output, and related artifacts.
