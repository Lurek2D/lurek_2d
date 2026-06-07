---
name: create-engine-feature
description: End to end workflow to new new feature to engine of lurek in rust, should run set of other prompts.
---

# GOAL
- Orchestrate the creation of a major engine feature, driving Rust implementation, API exposure, and validation.

# INPUTS REQUIRED
- Feature description and constraints
- Affected subsystems
= User must provide the high-level goal
- Agent must collect architecture guidelines and relevant prompt references

# STEPS TO DO
1. Load skills: rust-coding, lua-api-design, testing-ecosystem.
2. Delegate to `create-module` or write Rust logic. Execute `cargo test`. If <100% pass, fix Rust logic.
3. Delegate to `create-api-function` to wrap the code in `lua_api`.
4. Delegate to `create-test-lua` and `create-example` to prove the feature works end-to-end.
5. Execute `cargo clippy -- -D warnings` and `python tools/validate/cag_validate.py`. If either tool exits with code >0, fix the warnings or architectural violations and repeat this step.

# OUTPUTS PROVIDED
- Rust source code modifications
- Lua API wrappers
- Tests, examples, and docs-general updates

# SUCCESS CRITERIA
- `cargo test` exits with code 0 (100% pass rate).
- `cargo clippy -- -D warnings` exits with code 0 (exactly 0 warnings).
- `python tools/validate/cag_validate.py` exits with code 0 (0 architectural violations).

# ANIT PATTERNS
- Implementing massive features in a single commit without breaking them down.
- Skipping the Lua API design phase before implementing Rust code.

# REFERENCES
- skills: rust-coding, lua-api-design, testing-ecosystem, docs-general
- tools: cargo test, python tools/validate/cag_validate.py, cargo clippy
- agent: Manager
