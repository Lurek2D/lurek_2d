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

## Read these contracts
- `src/AGENTS.md`
- `src/lua_api/AGENTS.md`
- `docs/architecture/AGENTS.md`
- `docs/specs/AGENTS.md`

## Steps
- Read the listed contracts before editing module boundaries or bindings.
- Create the module spec under `docs/specs/` using the same module name and describe the public contract before implementation.
- Implement the internal logic in a new module directory under `src/` and expose it through the matching thin Lua wrapper in `src/lua_api/`.
- Execute `python tools/gen_all_docs.py` to sync bindings into `docs/api/`. If generation throws an error, fix the API wrapper docstrings.
- Write Lua unit tests for the new behavior, then run `cargo test` and `cargo clippy -- -D warnings`. If tests fail or clippy reports warnings, fix the code and rerun the checks.
- Execute `python tools/validate/cag_validate.py`. If it reports cycles, resolve the dependency issue and rerun the validator.

## Outputs
- Module implementation code under `src/`
- Matching Lua API wrapper under `src/lua_api/`
- Module spec under `docs/specs/`
- Updated API docs and tests

## Success criteria
- [ ] `cargo test` exits with code 0 (100% test pass rate).
- [ ] `cargo clippy -- -D warnings` exits with code 0 (0 warnings).
- [ ] `python tools/validate/cag_validate.py` exits with code 0 (0 cyclic dependencies).

## Stop conditions
- Putting business logic inside the `lua_api` wrapper instead of the domain module.
- Forgetting to register the module in the relevant `mod.rs` files.

## References
- `contracts: src/AGENTS.md, src/lua_api/AGENTS.md, docs/architecture/AGENTS.md, docs/specs/AGENTS.md`
- `tools: python tools/validate/cag_validate.py, python tools/gen_all_docs.py, cargo test`
- `agent: Developer`


