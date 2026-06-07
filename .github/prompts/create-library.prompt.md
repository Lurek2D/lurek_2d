---
name: create-library
description: Create or update new lua pure library part of lureksome.
---

# GOAL
- Develop a pure Lua library module under the `library/` folder, including its docs and tests.

# INPUTS REQUIRED
- Library name
- Functionality description
= User must provide the library purpose and interface requirements
- Agent must collect existing library conventions

# STEPS TO DO
1. Load skills: library-authoring, lua-scripting.
2. Execute `python tools/audit/library_coverage.py` to identify missing test/doc dependencies for existing libraries as a reference point.
3. Create `library/<name>/init.lua`. Write standard, highly optimized Lua code relying strictly on the `lurek.*` API.
4. Add `tests/lua/test_library_<name>.lua` and `library/<name>/README.md` containing usage documentation.
5. Execute `python tools/validate/validate_library.py --lib <name>`. If it fails, fix the structure.
6. Execute `python tools/audit/library_coverage.py`. If coverage is <100%, write additional tests and docs in step 4 until the script reports 100%.

# OUTPUTS PROVIDED
- The new `init.lua` library file
- Library documentation and tests
- Coverage report

# SUCCESS CRITERIA
- `python tools/validate/validate_library.py` exits with code 0.
- `python tools/audit/library_coverage.py` reports exactly 100% coverage for the new library.

# ANIT PATTERNS
- Introducing global variables into the Lua environment.
- Using non-standard Lua paradigms that clash with LuaJIT performance.

# REFERENCES
- skills: library-authoring, lua-scripting
- tools: python tools/audit/library_coverage.py, python tools/validate/validate_library.py
- agent: Content-Maker
