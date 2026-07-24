---
name: create-module
description: "Load this skill when creating or modifying Rust engine modules in src with Lua API, specs, examples, and tests. Skip it for small docs-only updates, pure Lua content, or VS Code extension work."
---

# create-module

## Mission
- Create or modify Rust engine modules while keeping public Lua API, specs, examples, and tests aligned.

## Domain Knowledge
- Rust engine modules live under `src/`.
- A new top-level module uses `src/<module>/`.
- A module owns one coherent state and algorithm boundary.
- `mod.rs` is export-only.
- Implementation files separate state, algorithms, serialization, and runtime code.
- `docs/meta/modules.toml` registers source, binding, namespace, spec, example, and test owners.
- Engine registration and Lua registration are separate steps.
- Engine registration uses the crate and runtime owners.
- Lua registration uses `src/lua_api/mod.rs`.
- Public Lua names are fixed before examples and test markers are written.
- Generated Lua API data is the source for public callable names.
- Initialization order follows dependency direction.
- Modules do not depend on peer global state.
- Resource-owning modules define reset and teardown.
- Lua handles use userdata.
- New public modules need a spec, example, and Lua unit owner.
- Internal modules need an explicit metadata exclusion when tools require it.
- `src/lib.rs` is the engine subsystem entry point; `src/main.rs` is the standalone app boot path.
- Every module source file has `//!` docs that state purpose, state ownership, and its boundary.
- Public structs, enums, fields, methods, and Lua-facing helpers have `///` docs.
- Rust source modules do not contain inline test modules or fixtures.
- Private seams are exposed narrowly with documented `pub(crate)` items.
- New unsafe code is invalid without a nearby `// SAFETY:` invariant.

## Workflow
1. Read source, Lua API, specs, examples, and tests contracts.
2. Query RAG for existing owners of the requested state.
3. Prove that no current module can own the behavior.
4. Define module state, dependencies, lifecycle, and public namespace.
5. Create `src/<module>/` with export-only `mod.rs`.
6. Implement Rust state and algorithms.
7. Add file docs and public Rust docs.
8. Add private Rust tests.
9. Register the module in engine lifecycle code.
10. Add a thin Lua binding and Lua registration.
11. Add the complete `docs/meta/modules.toml` record.
12. Regenerate Lua API data and specs.
13. Create exact example owners from generated names.
14. Create exact Lua unit owners from generated names.
15. Test init, use, teardown, second init, and partial failure.
16. Run module coverage validation.
17. Run focused tests, full Cargo tests, and clippy.
18. Boot the namespace from a minimal Lua script.

## References
- `contracts: src/AGENTS.md, src/lua_api/AGENTS.md, docs/architecture/AGENTS.md, docs/specs/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "Rust engine module lua_api docs specs" --profile engine --limit 10, tools/python.cmd tools/gen_all_docs.py, tools/python.cmd tools/validate/validate_module_coverage.py, cargo test, cargo clippy -- -D warnings`
- `agent: developer`
- RAG: `Rust engine module <name> lua_api docs specs`; inspect existing `src/` owners, `docs/meta/modules.toml`, binding registration, and derived example/test paths.
