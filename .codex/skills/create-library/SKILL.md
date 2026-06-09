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
- Execute `python tools/audit/library_coverage.py` to identify missing test or documentation dependencies for the current library set.
- Create a new subdirectory under `library/` with an `init.lua` entry point and a `README.md` usage guide.
- Add the corresponding Lua test under `tests/lua/library/` using the established `test_library_*.lua` naming convention.
- Execute `python tools/validate/validate_library.py --lib <name>`. If it fails, fix the structure.
- Execute `python tools/audit/library_coverage.py`. If coverage is below 100%, add the missing tests and docs and rerun the audit.

## Outputs
- The new library folder with `init.lua`
- Library documentation and tests
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
- `agent: content`


