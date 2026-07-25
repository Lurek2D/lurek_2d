# Tools Contract

## Mission & Scope
- Own repo scripts, generators, formatters, validators, audit tools, and packaging logic.
- Keep automation local, repeatable, and safe on Windows.

## Files
- `audit/`, `validate/`: Read-only checks and contract validators.
- `docs/`, `snippets/`, `ui/`: Generators for docs and content data.
- `demos/`, `dist/`: Content smoke tools and package builders.
- `dev/`, `fix/`: Developer helpers and source fixers.
- `rag/`: Workspace search index and query tools.
- `gen_all_docs.py`: Full docs build entry point.

## Rules
- Tools must run locally on Windows; avoid CI-only flows.
- Keep dependencies minimal and explicitly documented.
- Code generators must write relative paths inside the workspace.
- If a tool encodes canonical markers, paths, registry fields, or filename patterns, update the owning `AGENTS.md` and skill guidance in the same change.
- Run light syntax and link checks before heavy Cargo compiles.

## Workflow
- Run the matching generator, audit, or validator before broad checks.
- Invoke module audits positionally (for example, `tools/python.cmd tools/audit/audit_module.py image`), matching the parser contract.
- If shared contracts, generators, or CAG metadata change, run `tools/python.cmd tools/validate/cag_validate.py`.
