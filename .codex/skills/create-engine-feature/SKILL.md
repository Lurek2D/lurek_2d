---
name: create-engine-feature
description: "End to end workflow to new new feature to engine of lurek in rust, should run set of other prompts."
---
# create-engine-feature

## Goal
- Orchestrate the creation of a major engine feature, driving Rust implementation, API exposure, and validation.

## Required inputs
- Feature description and constraints
- Affected subsystems
- User must provide the high-level goal
- Agent must collect architecture guidelines and relevant prompt references

## Profile hint
- `developer`

## Read these contracts
- `src/AGENTS.md`
- `src/lua_api/AGENTS.md`
- `tests/AGENTS.md`
- `content/examples/AGENTS.md`
- `docs/specs/AGENTS.md`

## Steps
- Read the listed contracts before implementation.
- Delegate to `create-module` or write Rust logic. Execute `cargo test`. If <100% pass, fix Rust logic.
- Delegate to `create-api-function` to wrap the code in `lua_api`.
- Delegate to `create-test-lua` and `create-example` to prove the feature works end-to-end.
- Execute `cargo clippy -- -D warnings` and `python tools/validate/cag_validate.py`. If either tool exits with code >0, fix the warnings or architectural violations and repeat this step.

## Outputs
- Rust source code modifications
- Lua API wrappers
- Tests, examples, and docs-general updates

## Success criteria
- [ ] `cargo test` exits with code 0 (100% pass rate).
- [ ] `cargo clippy -- -D warnings` exits with code 0 (exactly 0 warnings).
- [ ] `python tools/validate/cag_validate.py` exits with code 0 (0 architectural violations).

## Stop conditions
- Implementing massive features in a single commit without breaking them down.
- Skipping the Lua API design phase before implementing Rust code.

## References
- `contracts: src/AGENTS.md, src/lua_api/AGENTS.md, tests/AGENTS.md, content/examples/AGENTS.md, docs/specs/AGENTS.md`
- `tools: cargo test, python tools/validate/cag_validate.py, cargo clippy`
- `agent: manager`


