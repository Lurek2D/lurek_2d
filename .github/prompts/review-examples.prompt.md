---
name: review-examples
description: Review example coverage and fix all the gaps, ensure all practices are followed.
---

# GOAL
- Audit `content/examples/` to ensure every public Lua API is demonstrated correctly.

# INPUTS REQUIRED
- Target module or full codebase
= User defines the scope of the example review
- Agent must collect output from `example_coverage.py`

# STEPS TO DO
1. Load skills: examples-management, lua-scripting.
2. Execute `python tools/audit/example_coverage.py` to capture the current coverage percentage.
3. Write new focused scripts under `content/examples/` to cover the undocumented APIs.
4. Execute `python tools/validate/validate_example_coverage.py`. If it fails (exit code >0), fix structural errors.
5. Execute `python tools/audit/example_coverage.py` again. If the coverage is <100%, return to step 3 and write more examples.

# OUTPUTS PROVIDED
- New/updated scripts in `content/examples/`
- Updated coverage report

# SUCCESS CRITERIA
- `python tools/validate/validate_example_coverage.py` exits with code 0.
- `python tools/audit/example_coverage.py` reports exactly 100% example coverage.

# ANIT PATTERNS
- Copy-pasting the same generic example for different API endpoints.
- Writing examples that depend on external, unprovided assets.

# REFERENCES
- skills: examples-management, documentation, lua-scripting
- tools: python tools/audit/example_coverage.py, python tools/validate/validate_example_coverage.py
- agent: Content-Maker
