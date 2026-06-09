---
name: create-library
description: "Create or update new lua pure library part of lureksome."
---
# create-library

## Goal
- Develop a pure Lua library module under the `library/` folder, including its docs and tests.

## Required inputs
- Library name
- Functionality description
- User must provide the library purpose and interface requirements
- Agent must collect existing library conventions

## Profile hint
- `content`

## Read these contracts
- `library/AGENTS.md`
- `tests/lua/AGENTS.md`
- `content/AGENTS.md`

## Steps
- Read the listed contracts before editing the library module.
- Execute `python tools/audit/library_coverage.py` to identify missing test/doc dependencies for existing libraries as a reference point.
- Create `library/<name>/init.lua`. Write standard, highly optimized Lua code relying strictly on the `lurek.*` API.
- Add `tests/lua/test_library_<name>.lua` and `library/<name>/README.md` containing usage docs-general.
- Execute `python tools/validate/validate_library.py --lib <name>`. If it fails, fix the structure.
- Execute `python tools/audit/library_coverage.py`. If coverage is <100%, write additional tests and docs in step 4 until the script reports 100%.

## Outputs
- The new `init.lua` library file
- Library docs-general and tests
- Coverage report

## Success criteria
- [ ] `python tools/validate/validate_library.py` exits with code 0.
- [ ] `python tools/audit/library_coverage.py` reports exactly 100% coverage for the new library.

## Stop conditions
- Introducing global variables into the Lua environment.
- Using non-standard Lua paradigms that clash with LuaJIT performance.

## References
- `contracts: library/AGENTS.md, tests/lua/AGENTS.md, content/AGENTS.md`
- `tools: python tools/audit/library_coverage.py, python tools/validate/validate_library.py`
- `agent: Content-Maker`


