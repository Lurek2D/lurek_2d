---
name: review-tests
description: "Load this skill when auditing and fixing Lua unit test coverage, structure, harness registration, and public API test gaps. Skip it for Rust-only internal tests or non-test code reviews."
---

# review-tests

## Mission
- Audit and fix Lua test coverage and structure for public `lurek.*` APIs.
- Audit test ownership by module so propagation, rendering, physics, and other consumer tests are not counted as core data-module coverage.
- Enforce canonical ownership in `tests/lua/unit/`: `1 API = 1 unit it() = 1 directly-adjacent @covers`.
- For canonical non-unit suites, enforce:
  - `stress/security`: `1 API = 1 family marker = 1 it()`
  - `evidence`: module-owned files should use prose rationale comments above each `it()` and produce artifacts that genuinely demonstrate the owner module
  - `golden`: compare current artifacts to stored baselines and fail on unacceptable drift
  - `integration`: markers should match the APIs actually exercised by each scenario

## Domain Knowledge
- Test layers have distinct proof obligations: Lua unit owns each public API once, integration proves module boundaries, stress/security owns bounded or hostile families, evidence produces legible artifacts, golden compares reviewed baselines, and Rust targets private seams.
- Coverage counts are ownership metadata, not execution proof. A marker can be exact while its block never runs, asserts defaults, or tests a helper instead of the named API.
- Canonical module ownership prevents consumer-propagation scenarios from inflating producer coverage; render, physics, or serialization tests using a data module do not replace that module's own contract tests.
- Harness registration, filter names, BDD grammar, marker adjacency/indentation, and final `test_summary()` are executable structure; each can fail independently of assertion quality.
- Evidence rationale and artifact legibility, golden provenance, deterministic fixtures, and typed/epsilon assertions require semantic inspection beyond coverage audits.
- Duplicate public API owners are defects because they divide the canonical contract; richer coverage belongs inside the one owner or in a correctly classified non-unit layer.
- Mutation testing or deliberate assertion perturbation is especially valuable for blocks that only inspect types, non-nil handles, or default state; these tests can pass even when the named operation does nothing.
- Float, randomized, frame-driven, and concurrent tests need an explicit stability strategy—epsilon, seed, bounded step count, deterministic scheduling seam, or release-only threshold—rather than repeated retries.
- Test fixture ownership should mirror subsystem boundaries. Shared helpers may construct common context, but they must not perform the named operation or assertion invisibly because coverage then attributes behavior to the wrong block.

## Workflow
- Run unit ownership, Lua structure, non-unit, and evidence/golden contract audits first; build a module-by-layer matrix of missing/exact/duplicate owners, registration, execution target, artifacts, and affected generated API names.
- Inspect a risk-weighted sample plus every flagged block for assertion sensitivity, correct owner, boundary/error coverage, deterministic setup, cleanup, and category semantics; verify registered filters actually execute the file and that evidence/golden output proves its stated behavior.
- Report structural metadata defects separately from weak assertions, missing behavior, misclassified layers, orphan targets, consumer-owned duplication, and stale baselines, always including the narrow command and expected result that would close the finding.
- If editable, use the matching test-creation skill to consolidate or add canonical owners, rerun focused harness filters and all relevant audits, then `cargo test --test lua_tests` or exact Rust targets; otherwise hand off exact files/APIs/artifacts to `tester`.
- Reconcile every Lua unit API name against the generated inventory and inspect duplicate owners before missing owners, because consolidating duplicates may reveal the correct canonical block without adding new tests.
- Run representative filters from each non-unit category and confirm harness output names the expected file/describe/it, catching registered-but-unfilterable suites and filters that accidentally execute a different owner.
- Trace shared fixtures and helper calls used by flagged tests, identifying hidden assertions, state mutation, ambient globals, artifact paths, and cleanup that can make tests pass in suite order but fail alone.
- Review negative-path sensitivity by changing one input across a valid boundary or forcing one callback/error path; ensure the test fails on the intended assertion and leaves later cases clean.
- For evidence, open artifacts and compare rationale to visible content; for golden, verify baseline provenance and current-output generation; for stress/security, confirm declared ceilings or hostile families rather than merely large input counts.
- For Rust targets, match every file to `Cargo.toml`, check public-Lua duplication, and separate deterministic unit/golden seams from device/runtime extension tests that require different execution conditions.
- After fixes, run isolated block, module/category suite, full Lua/Rust target, and structure/coverage/artifact audits in increasing breadth, recording residual flaky or environment-bound cases separately from contract gaps.

## References
- `contracts: AGENTS.md, tests/AGENTS.md, tests/lua/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "Lua test coverage structure harness public API" --profile game --limit 10, tools/python.cmd tools/audit/unit_test_api_coverage.py, tools/python.cmd tools/audit/lua_nonunit_test_coverage.py, tools/python.cmd tools/audit/lua_test_structure_audit.py --path tests/lua/unit, cargo test --test lua_tests`
- `agent: tester`
- RAG: Start with: `Lua test coverage structure harness public API`, `Lua unit tests public API coverage`, `tests contract Lua API coverage harness`; Focus areas first: `tests/lua/unit/`, `tests/lua/`, `tests/`, `content/examples/`, `docs/specs/`; Append the target module, API path, or failing test file before broad reads
