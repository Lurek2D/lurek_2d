---
name: create-test-lua
description: "Load this skill when creating or modifying Lua tests for public lurek APIs under tests/lua. Skip it for Rust-only internals, integration-only coverage, or visual evidence tests."
---

# create-test-lua

## Mission
- Create or modify Lua tests that are canonical coverage for public `lurek.*` APIs.
- Keep canonical unit owners in `tests/lua/unit/` with `1 API = 1 unit it() = 1 directly-adjacent @covers`.
- Keep non-unit suites separated by purpose: integration for scenarios, evidence for artifact generation, golden for artifact comparison.

## Domain Knowledge
- Generated Lua API names are the coverage key: each callable has exactly one canonical `-- @covers` owner in the matching `tests/lua/unit/test_<module>_unit.lua`, independent of how many integration or evidence scenarios also use it.
- One `it()` owns one API contract and contains all success, invalid-input, boundary, and side-effect assertions needed for that callable; splitting the same API across blocks creates duplicate ownership rather than better coverage.
- Namespace functions precede userdata/object methods because constructors and shared state establish the fixtures later method tests consume conceptually, even though each block remains isolated.
- The Rust `lua_tests` target embeds the runtime and registers Lua files in `tests/lua_tests.rs`; file existence, marker correctness, and harness reachability are separate gates.
- Typed `expect_*` helpers communicate Lua values and tolerate domain-appropriate float comparisons better than raw assertions or string-only checks.
- Constructor and userdata tests must distinguish ownership of the namespace function from ownership of returned-object methods; the generated API name, not the Rust type or convenient fixture location, decides the canonical block.
- Error tests should verify the public method context and stable category or key detail without freezing incidental Rust formatting that can change while the Lua contract remains intact.
- Callback APIs need tests for registration, invocation arguments, replacement or removal, registry lifetime, and failure propagation at the correct runtime phase rather than only successful callback creation.

## Workflow
- Run unit ownership coverage first and select one missing, duplicate, or changed generated API name; inspect its binding/spec/example plus canonical module test, distinguishing a behavior gap from a marker/parser gap before editing.
- Consolidate the callable into one adjacent-marker `it()` and build its complete contract there: realistic setup, returned value/type, mutation/side effect, boundary and invalid-input behavior, and cleanup, using typed expectations and deterministic fixtures.
- Preserve the canonical file grammar and module-before-userdata ordering; create a file only for a new module owner and register it in `tests/lua_tests.rs`, then run a narrow harness filter to prove the block executes rather than merely satisfying the parser.
- Rerun structure and unit coverage audits until the API moves to exactly-one-owner status, then run the full Lua target and relevant non-unit audit when shared fixtures or behavior affect integration, stress, security, evidence, or golden suites.
- Derive the assertion matrix from the binding and spec: default call, representative success, lower/upper or empty boundaries, wrong type/enum/range, return shape, state mutation, and cleanup. Omit inapplicable dimensions rather than copying a template mechanically.
- For userdata methods, create a fresh minimal object inside the owner block unless construction is itself the API under test; verify stale or invalid handle behavior when teardown/removal exists.
- For frame-dependent behavior, advance the narrowest deterministic runtime step and assert pre-step and post-step state so the test proves when the change becomes observable.
- Run the single `it()` filter, module describe, and complete Lua target in order; this separates local assertion failures, fixture/order contamination, and harness-wide lifecycle leaks.
- Deliberately invert one key input during development to confirm the assertion fails for the intended reason, then restore it; marker coverage without sensitivity is not proof.

## References
- `contracts: tests/AGENTS.md, tests/lua/AGENTS.md, content/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "Lua unit tests public API coverage" --profile game --limit 10, tools/python.cmd tools/audit/unit_test_api_coverage.py, tools/python.cmd tools/audit/lua_test_structure_audit.py --path tests/lua/unit, cargo test --test lua_tests, tools/python.cmd tools/validate/cag_validate.py`
- `agent: tester`
- RAG: Start with: `Lua unit tests public API coverage`, `Lua test coverage structure harness public API`, `tests contract Lua API coverage harness`; Focus areas first: `tests/lua/unit/`, `tests/lua/`, `content/examples/`, `docs/specs/`; Append the target API or module name such as `input`, `render`, `physics`, `scene`
