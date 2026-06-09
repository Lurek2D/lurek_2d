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

## Read these contracts
- `content/AGENTS.md`
- `content/examples/AGENTS.md`
- `docs/AGENTS.md`

## Steps
- Read the listed contracts before authoring the example.
- Execute `python tools/audit/example_coverage.py --module <module>` for the target module to confirm which API signatures are currently un-exampled.
- Write a self-contained Lua script in `content/examples/` that sets up and invokes the targeted API cleanly.
- Execute `python tools/validate/validate_example_coverage.py`. If it fails or shows unlinked examples, fix the registration metadata in the script.
- Execute `python tools/audit/example_coverage.py --module <module>` again. If the target API coverage is still below 100%, return to the example and cover the missing methods.

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
- `contracts: content/AGENTS.md, content/examples/AGENTS.md, docs/AGENTS.md`
- `tools: python tools/audit/example_coverage.py, python tools/validate/validate_example_coverage.py`
- `agent: content`


