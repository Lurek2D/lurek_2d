---
name: create-module
description: "Create or update module in src, perform all needed steps to make it work, including tests, examples, specs."
---
# create-module

## Goal
- End-to-end creation of a new Rust engine module, including API bindings, docs-general, and tests.

## Required inputs
- Module name and group (Foundations, Core, Platform, Feature, Edge)
- Core functionality description
- User must provide the architectural purpose of the module
- Agent must collect project constraints regarding cyclic dependencies

## Profile hint
- `developer`

## Load these skills
- `module-architecture`
- `rust-coding`
- `lua-rust-bridge`
- `docs-general`

## Steps
- Load skills: module-architecture, rust-coding, lua-rust-bridge.
- Create `docs/specs/<module>.md` defining boundaries.
- Implement internal logic in `src/<module>/` and expose the thin Lua wrapper in `src/lua_api/<module>_api.rs`.
- Execute `python tools/gen_all_docs.py` to sync bindings into `docs/api/`. If generation throws an error, fix the API wrapper docstrings.
- Write Lua unit tests and run `cargo test` and `cargo clippy -- -D warnings`. If tests <100% pass rate or clippy >0 warnings, fix the code.
- Execute `python tools/validate/cag_validate.py`. If exit code is >0, resolve architectural cyclic dependencies and repeat step 6.

## Outputs
- `src/<module>/` code
- `src/lua_api/<module>_api.rs`
- `docs/specs/<module>.md`
- Updated API docs-general and tests

## Success criteria
- [ ] `cargo test` exits with code 0 (100% test pass rate).
- [ ] `cargo clippy -- -D warnings` exits with code 0 (0 warnings).
- [ ] `python tools/validate/cag_validate.py` exits with code 0 (0 cyclic dependencies).

## Stop conditions
- Putting business logic inside the `lua_api` wrapper instead of the domain module.
- Forgetting to register the module in the global `mod.rs`.

## References
- `skills: module-architecture, rust-coding, lua-rust-bridge, docs-general`
- `tools: python tools/validate/cag_validate.py, python tools/gen_all_docs.py, cargo test`
- `agent: Developer`

## Invocation rules
- This is a user-invoked workflow. Do not auto-load it as a generic background skill.
- Start only after the user explicitly requests this named workflow or a clearly equivalent task.

