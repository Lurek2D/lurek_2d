# Tools Contract

## Mission & Scope
- Own repo scripts, generators, formatters, validators, audit tools, and packaging logic.
- Keep automation local, repeatable, and safe on Windows.

## Files
- `audit/`: Link, docstring, example, and quality checks.
- `validate/`: Schema and CAG validators.
- `rag/`: Workspace search index and query tools.
- `gen_all_docs.py`: Full docs build entry point.

## Rules
- Tools must run locally on Windows; avoid CI-only flows.
- Keep dependencies minimal and explicitly documented.
- Code generators must write relative paths inside the workspace.
- Run light syntax and link checks before heavy Cargo compiles.

## Workflow
- Read the nearest nested tools contract or README before tool-family edits.
- Run the matching generator, audit, or validator before broad checks.
- If shared contracts, generators, or CAG metadata change, run `tools/python.cmd tools/validate/cag_validate.py`.
