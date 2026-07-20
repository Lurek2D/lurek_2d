---
name: create-module
description: "Load this skill when creating or modifying Rust engine modules in src with Lua API, specs, examples, and tests. Skip it for small docs-only updates, pure Lua content, or VS Code extension work."
---

# create-module

## Mission
- Create or modify Rust engine modules while keeping public Lua API, specs, examples, and tests aligned.

## Domain Knowledge
- A top-level `src/<module>/` is an ownership boundary for state and algorithms, not merely a namespace. New modules incur catalog, lifecycle, documentation, binding, example, and test obligations that an extension to an existing owner avoids.
- `docs/meta/modules.toml` is the join table that connects Rust source, Lua binding path and namespace, generated spec, example file, Lua unit owner, visibility, tier, and plugin metadata.
- `mod.rs` should expose the module shape while implementation files separate state, algorithms, serialization, and runtime integration; cyclic calls through unrelated modules signal a misplaced owner.
- Public Lua naming must be settled before generating docs and coverage markers because examples and unit tests consume generated names rather than inventing their own aliases.
- Registration in `src/lib.rs`/runtime and `src/lua_api/mod.rs` are separate concerns: engine availability does not automatically make a module callable from Lua.
- Module initialization order must follow dependency direction and runtime ownership. A new owner that reaches into an already-initialized peer through global state creates hidden boot ordering that will surface during reload, tests, or headless execution.
- Resource-owning modules need explicit teardown and reset semantics, especially when handles are exposed as Lua userdata or derived state is cached by rendering, physics, audio, or runtime orchestration.
- Public module granularity should match a coherent scripting concept. A namespace that merely forwards unrelated peer operations is usually a catalog/ownership smell rather than a useful top-level module.

## Workflow
- Prove a new owner is necessary by mapping requested state, dependencies, lifecycle, and public namespace against existing `src/` modules; define the module boundary and dependency direction before creating files.
- Build the Rust owner first with export-only `mod.rs`, explicit lifecycle integration, documented invariants, contextual error behavior, and private seam tests; wire a thin Lua module only after the domain API is stable.
- Add the complete `docs/meta/modules.toml` record, binding registration, and source docstrings, generate Lua API/spec data, then create exact example and Lua unit owners from generated names rather than guessed signatures.
- Run the module-specific Rust target, generated coverage/spec validators, example and Lua tests, then cargo/clippy and CAG/link checks; verify the new namespace boots in a minimal Lua script before declaring catalog integration complete.
- Test initialization and teardown in dependency order, including a second creation cycle and failure during partial setup; confirm registration does not leave a half-visible Lua namespace or retain resources after an error.
- Run the module coverage tools against the new metadata record and inspect every derived path they report, correcting the metadata/source owner rather than patching missing generated files one by one.

## References
- `contracts: src/AGENTS.md, src/lua_api/AGENTS.md, docs/architecture/AGENTS.md, docs/specs/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "Rust engine module lua_api docs specs" --profile engine --limit 10, tools/python.cmd tools/gen_all_docs.py, cargo test, cargo clippy -- -D warnings, tools/python.cmd tools/validate/cag_validate.py`
- `agent: developer`
- RAG: Start with: `Rust engine module lua_api docs specs`, `engine feature src lua_api specs tests`, `input module spec keyboard mouse gamepad touch`; Focus areas first: `src/`, `src/lua_api/`, `docs/specs/`, `docs/modules/`, `tests/`; If the task is module-specific, append the module name or public API path such as `render`, `input`, `lurek.render`, `lurek.input`
