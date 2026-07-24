---
name: create-engine-feature
description: "Load this skill when creating or modifying Rust engine features that may touch modules, Lua API, specs, examples, and tests end to end. Skip it for docs-only reviews, content-only demos, or VS Code extension work."
---

# create-engine-feature

## Mission
- Deliver engine feature changes end to end while keeping public Lua contracts, specs, examples, and tests in sync.

## Domain Knowledge
- Engine state and algorithms live under `src/`.
- `src/lua_api/` owns Lua registration, conversion, validation, userdata, and errors.
- Lua bindings do not own engine algorithms.
- `src/app/` and `src/runtime/` own lifecycle orchestration.
- Lifecycle phases include init, process, draw, resize, and teardown.
- `docs/meta/modules.toml` maps source, namespace, spec, example, and test owners.
- Generated Lua API data is the naming source for examples and tests.
- Lua tables, numeric casts, enums, sizes, and callbacks are validated before mutation.
- Lua-facing failures return `mlua::Result`.
- Lua errors include the public `lurek.<module>.<method>` name.
- Private engine seams use Rust tests.
- Public `lurek.*` behavior uses Lua unit tests.
- Cross-module public behavior uses Lua integration tests.
- Lua callbacks use registry values.
- Mutable userdata borrows do not cross Lua callbacks or yielding frames.
- Resource owners define teardown and recreation behavior.
- Lua-observable serialization and snapshots are public behavior.
- Feature-gated behavior fails clearly when unavailable.
- Every changed Rust source file needs `//!` docs for purpose, owned state, and boundary.
- Public Rust items and Lua-facing helpers need factual `///` docs.
- Tests do not live in inline `#[cfg(test)]` modules under `src/`.
- A `pub(crate)` test seam must name the invariant it exposes.
- Every `unsafe` block requires a local `// SAFETY:` explanation.
- Lua bindings use Rust `any` for intentionally loose Lua values instead of pretending a cast exists.

## Workflow
1. Read the source, Lua API, tests, examples, and specs contracts.
2. Query RAG for the target module and behavior.
3. Identify the Rust state owner.
4. Identify the runtime lifecycle hook.
5. Identify the Lua namespace and metadata owner.
6. Use `create-module` only when no existing module can own the feature.
7. Implement Rust invariants first.
8. Add lifecycle integration.
9. Add private Rust tests.
10. Add a thin Lua binding with input validation.
11. Add public method context to every Lua error.
12. Update binding docstrings and module metadata.
13. Regenerate Lua API data and specs.
14. Update the exact example owner.
15. Update the exact Lua unit owner.
16. Add integration coverage only for a real module boundary.
17. Test creation, use, teardown, and recreation.
18. Run focused tests, `cargo test`, and clippy.

## References
- `contracts: src/AGENTS.md, src/lua_api/AGENTS.md, tests/AGENTS.md, content/examples/AGENTS.md, docs/specs/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "engine feature src lua_api specs tests" --profile engine --limit 10, cargo test, cargo clippy -- -D warnings, tools/python.cmd tools/gen_all_docs.py`
- `agent: developer`
- RAG: `engine feature <module> src lua_api specs tests`; inspect the owning Rust module, binding, metadata, generated inventory, and exact example/test owners.
