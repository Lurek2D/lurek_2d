---
name: create-example
description: Create new example or update example for specific module.
---

# GOAL
- Create a clear, concise example script in `content/examples/` illustrating a specific module's API.

# INPUTS REQUIRED
- Target module
- API function or concept to demonstrate
= User must specify which part of the API needs an example
- Agent must collect the exact API signatures from `docs/api/lurek.lua`

# STEPS TO DO
1. Load skills: examples-management, lua-scripting.
2. Execute `python tools/audit/example_coverage.py --module <target>` to confirm which API signatures are currently un-exampled.
3. Write a self-contained Lua script in `content/examples/` that sets up and invokes the targeted API cleanly.
4. Execute `python tools/validate/validate_example_coverage.py`. If it fails or shows unlinked examples, fix the registration metadata in the script.
5. Execute `python tools/audit/example_coverage.py --module <target>`. If the target API coverage is still <100%, return to step 3 and ensure the example properly hits the missing methods.

# OUTPUTS PROVIDED
- New or modified example script
- Example coverage report

# SUCCESS CRITERIA
- `python tools/validate/validate_example_coverage.py` exits with code 0.
- `python tools/audit/example_coverage.py` reports exactly 100% example coverage for the targeted API method.

# ANIT PATTERNS
- Writing overly complex examples that obscure the actual API being demonstrated.
- Failing to document the code with clear comments.

# REFERENCES
- skills: examples-management, lua-scripting, docs-general
- tools: python tools/audit/example_coverage.py, python tools/validate/validate_example_coverage.py
- agent: Content-Maker
