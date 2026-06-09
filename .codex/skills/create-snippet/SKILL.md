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
- `doc_writer`

## Read these contracts
- `content/snippets/AGENTS.md`
- `docs/AGENTS.md`

## Steps
- Read the listed contracts, then keep snippet wording aligned with the current API docs and snippet coverage rules.
- Execute `python tools/audit/snippet_coverage.py` to identify missing snippets for highly used public methods.
- Write or update a Lua snippet in `content/snippets/`, following the `_template.lua` marker order and the existing library naming conventions.
- Execute `python tools/snippets/gen_vscode_snippets.py` to regenerate the extension snippet output when snippet inventory changes.
- Execute `python tools/validate/validate_snippets.py`. If it returns exit code >0, fix the snippet structure and rerun the validation.
- Execute `python tools/audit/snippet_coverage.py` again. If the target API coverage is still below 100%, add the missing coverage and rerun the audit.

## Outputs
- Formatted snippet source in `content/snippets/`
- Snippet coverage validation

## Success criteria
- [ ] `python tools/validate/validate_snippets.py` exits with code 0.
- [ ] `python tools/audit/snippet_coverage.py` reports exactly 100% coverage for the targeted snippet scope.

## Stop conditions
- Creating snippets that use deprecated APIs.
- Writing overly long snippets that should be full examples instead.

## References
- `contracts: content/snippets/AGENTS.md, docs/AGENTS.md`
- `tools: python tools/audit/snippet_coverage.py, python tools/validate/validate_snippets.py, python tools/snippets/gen_vscode_snippets.py`
- `agent: doc_writer`


