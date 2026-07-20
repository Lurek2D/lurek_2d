---
name: create-engine-feature
description: "Load this skill when creating or modifying Rust engine features that may touch modules, Lua API, specs, examples, and tests end to end. Skip it for docs-only reviews, content-only demos, or VS Code extension work."
---

# create-engine-feature

## Mission
- Deliver engine feature changes end to end while keeping public Lua contracts, specs, examples, and tests in sync.

## Domain Knowledge
- Engine behavior belongs in `src/<module>/`; `src/lua_api/` is the conversion, validation, userdata, and registration edge rather than a second domain implementation.
- Public changes propagate through generated Lua API data before marker-owned examples and Lua unit tests can reliably name them; `docs/meta/modules.toml` connects source, namespace, spec, example, and test owners.
- Lifecycle placement matters as much as type placement: initialization, frame processing, rendering, resize, teardown, and callback registry ownership must align with `src/app/` and `src/runtime/` orchestration.
- Lua tables, numeric casts, enum-like strings, sizes, and callbacks must be validated before mutation and fail with callable `lurek.<module>.<method>` context rather than panic or partial state.
- Private seams belong in Rust tests, callable `lurek.*` behavior in Lua unit tests, and behavior depending on another public module in integration tests.
- Shared handles and callbacks introduce lifetime obligations across mlua frames: registry keys, `UserData` borrowing, engine teardown, and reload behavior must be designed before adding convenience wrappers that retain Lua values.
- Serialization or snapshot changes are public behavior when Lua can save, restore, export, or observe derived renderer state; compatibility and bounded input handling must be reviewed even if method signatures do not change.
- Feature flags and optional subsystem state should fail predictably at the Lua boundary, without registering a namespace that advertises operations the runtime cannot support in the active configuration.

## Workflow
- Trace the feature end to end: owning Rust state, runtime lifecycle hook, Lua namespace/conversion boundary, metadata/spec source, example owner, and narrow Rust/Lua tests; use `create-module` only when no module can own the behavior coherently.
- Implement domain invariants first, then lifecycle integration and a thin Lua edge with validation and contextual errors; add private seam tests before exposure so binding failures remain distinguishable from engine failures.
- For callable changes, update binding docstrings and metadata, regenerate Lua API data, then edit the exact example and `@covers` owners from generated names; add integration coverage only for genuine cross-module behavior.
- Run narrow Rust and Lua targets while iterating, regenerate specs/API docs, validate example/test ownership, then finish with `cargo test` and clippy when shared runtime or public bindings changed.
- Exercise creation, steady-state use, teardown, and recreation of the feature in one process when it owns resources or callbacks; verify no stale registry handles, duplicated runtime registration, or derived-state leakage survives restart.
- Review the final diff by ownership layer, ensuring every Rust-domain change has direct proof, every binding-only change stays conversion-focused, and generated/spec/example/test changes are consequences of the actual public delta rather than ceremonial churn.

## References
- `contracts: src/AGENTS.md, src/lua_api/AGENTS.md, tests/AGENTS.md, content/examples/AGENTS.md, docs/specs/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "engine feature src lua_api specs tests" --profile engine --limit 10, cargo test, cargo clippy -- -D warnings, tools/python.cmd tools/gen_all_docs.py, tools/python.cmd tools/validate/cag_validate.py`
- `agent: developer`
- RAG: Start with: `engine feature src lua_api specs tests`, `Rust engine module lua_api docs specs`, `review audits quality performance specs tests`; Focus areas first: `src/`, `src/lua_api/`, `tests/`, `content/examples/`, `docs/specs/`; For a behavior change, append the feature or module name before broad reads
