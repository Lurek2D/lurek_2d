---
name: create-example
description: "Create new example or update example for specific module."
---
# create-example

## Goal
- Create a clear, concise example script in `content/examples/` illustrating a specific module's API.

## Required inputs
- Target module
- API function or concept to demonstrate
- User must specify which part of the API needs an example
- Agent must collect the exact API signatures from `docs/api/lurek.lua`

## Profile hint
- `content`

## Load these skills
- `examples-management`
- `lua-scripting`
- `docs-general`

## Steps
- Load skills: examples-management, lua-scripting.
- Execute `python tools/audit/example_coverage.py --module <target>` to confirm which API signatures are currently un-exampled.
- Write a self-contained Lua script in `content/examples/` that sets up and invokes the targeted API cleanly.
- Execute `python tools/validate/validate_example_coverage.py`. If it fails or shows unlinked examples, fix the registration metadata in the script.
- Execute `python tools/audit/example_coverage.py --module <target>`. If the target API coverage is still <100%, return to step 3 and ensure the example properly hits the missing methods.

## Outputs
- New or modified example script
- Example coverage report

## Success criteria
- [ ] `python tools/validate/validate_example_coverage.py` exits with code 0.
- [ ] `python tools/audit/example_coverage.py` reports exactly 100% example coverage for the targeted API method.

## Stop conditions
- Writing overly complex examples that obscure the actual API being demonstrated.
- Failing to document the code with clear comments.

## References
- `skills: examples-management, lua-scripting, docs-general`
- `tools: python tools/audit/example_coverage.py, python tools/validate/validate_example_coverage.py`
- `agent: Content-Maker`

## Invocation rules
- This is a user-invoked workflow. Do not auto-load it as a generic background skill.
- Start only after the user explicitly requests this named workflow or a clearly equivalent task.

