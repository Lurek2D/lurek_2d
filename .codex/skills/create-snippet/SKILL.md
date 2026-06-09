---
name: create-snippet
description: "Create or update new snippet code for specific module with API."
---
# create-snippet

## Goal
- Author reusable code snippets for common tasks related to a specific module API.

## Required inputs
- Target module
- Common task description
- User must provide the specific use case requiring a snippet
- Agent must collect the most idiomatic API usage patterns

## Profile hint
- `developer`

## Read these contracts
- `content/snippets/AGENTS.md`

## Read these contracts
- `content/snippets/AGENTS.md`
- `docs/AGENTS.md`

## Steps
- Read the listed contracts, then keep snippet wording aligned with the current API docs and snippet coverage rules.
- Execute `python tools/audit/snippet_coverage.py` to identify missing snippets for highly-used public methods.
- Write a fast, optimized VS Code-compatible snippet in the `tools/snippets/` folder. Ensure variables are correctly tokenized (e.g., `$1`, `$2`).
- Execute `python tools/validate/validate_snippets.py`. If it returns exit code >0, fix the JSON structure of your snippet.
- Execute `python tools/audit/snippet_coverage.py`. If the target API coverage is still <100%, return to step 3 to add missing methods.

## Outputs
- Formatted code snippet file
- Snippet coverage validation

## Success criteria
- [ ] `python tools/validate/validate_snippets.py` exits with code 0.
- [ ] `python tools/audit/snippet_coverage.py` reports exactly 100% coverage for the targeted snippet scope.

## Stop conditions
- Creating snippets that use deprecated APIs.
- Writing overly long snippets that should be full examples instead.

## References
- `contracts: content/snippets/AGENTS.md, docs/AGENTS.md`
- `tools: python tools/audit/snippet_coverage.py, python tools/validate/validate_snippets.py`
- `agent: Doc-Writer`


