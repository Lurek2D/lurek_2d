---
name: create-module
description: Create or update module in src, perform all needed steps to make it work, including tests, examples, specs.
---

# GOAL
- End-to-end creation of a new Rust engine module, including API bindings, docs-general, and tests.

# INPUTS REQUIRED
- Module name and group (Foundations, Core, Platform, Feature, Edge)
- Core functionality description
= User must provide the architectural purpose of the module
- Agent must collect project constraints regarding cyclic dependencies

# STEPS TO DO
1. Load skills: module-architecture, rust-coding, lua-rust-bridge.
2. Create `docs/specs/<module>.md` defining boundaries.
3. Implement internal logic in `src/<module>/` and expose the thin Lua wrapper in `src/lua_api/<module>_api.rs`.
4. Execute `python tools/gen_all_docs.py` to sync bindings into `docs/api/`. If generation throws an error, fix the API wrapper docstrings.
5. Write Lua unit tests and run `cargo test` and `cargo clippy -- -D warnings`. If tests <100% pass rate or clippy >0 warnings, fix the code.
6. Execute `python tools/validate/cag_validate.py`. If exit code is >0, resolve architectural cyclic dependencies and repeat step 6.

# OUTPUTS PROVIDED
- `src/<module>/` code
- `src/lua_api/<module>_api.rs`
- `docs/specs/<module>.md`
- Updated API docs-general and tests

# SUCCESS CRITERIA
- [ ] `cargo test` exits with code 0 (100% test pass rate).
- [ ] `cargo clippy -- -D warnings` exits with code 0 (0 warnings).
- [ ] `python tools/validate/cag_validate.py` exits with code 0 (0 cyclic dependencies).

# ANTI-PATTERNS
- Putting business logic inside the `lua_api` wrapper instead of the domain module.
- Forgetting to register the module in the global `mod.rs`.

# EXAMPLE INVOCATION
- User: "request for this prompt"
- Agent: Runs this prompt workflow with provided constraints and reports changed files plus validation evidence.

# REFERENCES
- skills: module-architecture, rust-coding, lua-rust-bridge, docs-general
- tools: python tools/validate/cag_validate.py, python tools/gen_all_docs.py, cargo test
- agent: Developer


