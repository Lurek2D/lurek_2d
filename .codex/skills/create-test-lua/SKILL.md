---
name: create-test-lua
description: "Load this skill when creating or modifying Lua tests for public lurek APIs under tests/lua. Skip it for Rust-only internals, integration-only coverage, or visual evidence tests."
---

# create-test-lua

## Mission
- Create or modify Lua tests that are canonical coverage for public `lurek.*` APIs.
- Keep unit ownership exact: `1 generated API = 1 unit it() = 1 directly-adjacent -- @covers`; integration, evidence, golden, stress, and security retain separate proof roles.

## Domain Knowledge
- Lua unit tests live under `tests/lua/unit/`.
- One module uses one canonical `test_<module>_unit.lua` file.
- Generated Lua API names are the coverage keys.
- One public API has one canonical `it()` owner.
- One canonical `it()` has one directly adjacent `-- @covers` marker.
- One `it()` contains the full contract for its API.
- Namespace functions appear before userdata methods.
- Test files are registered in `tests/lua_tests.rs`.
- File presence does not prove harness registration.
- Typed `expect_*` helpers are preferred over raw `assert`.
- Float checks use a domain-specific epsilon.
- Error checks include the public `lurek.<module>.<method>` context.
- Error checks do not freeze incidental Rust wording.
- Callback tests cover registration, arguments, replacement, removal, and failure.
- Frame-driven tests state when a result becomes visible.
- Integration, evidence, golden, stress, and security are separate test layers.
- Public Lua unit ownership is required to reach 100%.
- A unit file starts with a plain prose header comment.
- Every `describe()` has a directly preceding `-- @describe`.
- Legacy `@tests`, `@description`, and `@category` markers are invalid.
- Helper-only `it()` blocks do not belong in the unit layer.
- Userdata coverage markers use the generated `lua_name`, such as `LType:method`.
- One bare `test_summary()` is the last non-empty line of the file.

## Workflow
1. Read the tests and Lua tests contracts.
2. Run unit API ownership coverage.
3. Select one missing, duplicate, or changed generated API.
4. Read its binding, spec, example, and current unit owner.
5. Separate marker errors from behavior errors.
6. Keep one canonical `it()` for the API.
7. Put the exact marker directly above the block.
8. Create minimal deterministic setup inside the block.
9. Test the normal return value or state change.
10. Test relevant empty, boundary, wrong-type, and invalid-value cases.
11. Test cleanup or stale handles when the API owns resources.
12. Use typed expectations and an explicit float epsilon.
13. Register a new module file in `tests/lua_tests.rs`.
14. Run the narrow test filter.
15. Run the structure audit.
16. Run unit ownership coverage again.
17. Run `cargo test --test lua_tests`.

## References
- `contracts: tests/AGENTS.md, tests/lua/AGENTS.md, content/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "Lua unit tests public API coverage" --profile game --limit 10, tools/python.cmd tools/audit/unit_test_api_coverage.py, tools/python.cmd tools/audit/lua_test_structure_audit.py --path tests/lua/unit, cargo test --test lua_tests`
- `agent: tester`
- RAG: `Lua unit tests <API> public coverage`; inspect the generated API entry, binding/spec/example, canonical unit file, and `tests/lua_tests.rs` registration.
