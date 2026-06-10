---
name: review-docstrings
description: "Load this skill when auditing and fixing Rust and Lua API docstrings, file docs, generated doc expectations, and stale descriptions. Skip it for general docs prose unrelated to source docstrings."
---
# review-docstrings

## Mission
- Audit and fix source docstrings so generated docs match callable behavior.

## When To Load
- Auditing and fixing Rust and Lua API docstrings, file docs, generated doc expectations, and stale descriptions.

## When To Skip
- General docs prose unrelated to source docstrings.

## Domain Knowledge
- Read root `AGENTS.md`, then every listed contract nearest to the reviewed path.
- Run the listed RAG query and audit/report tools before broad manual inspection.
- Prefer MCP server `lurek_tools` and repo CLI/audit tools before ad hoc scripts.
- Produce findings first with severity, affected files, and evidence.
- If the active profile is read-only, stop after findings and hand off fixes to the owner profile; otherwise fix requested findings and rerun the same audits.
- Treat review as audit-first, fix-second: findings must be grounded in tool output or direct file inspection.

## Workflow
- Run docstring audit for the selected module or surface.
- Compare source docstrings with generated docs and actual signatures.
- Report missing, stale, or malformed docstrings first.
- If edit-capable, fix source docstrings and regenerate affected docs.
- If read-only, hand off to `doc_writer` with exact symbols and expected wording issues.
- Finish by reporting changed files and validation evidence.

## Success Criteria
- Audit output was collected before fixes or handoff.
- Findings are either fixed and revalidated, or handed off with an explicit owner profile and blocker.
- Listed validation tools complete successfully, or any remaining failure is reported with exact output and next owner.

## Stop Conditions
- Required user intent, target module, or validation threshold is missing and cannot be inferred from repo context.
- A referenced owner path or tool is absent after checking the repository.
- Fixing a finding would require changing unrelated user work or widening scope beyond the requested surface.

## Companion File Index
- Contracts: `AGENTS.md`, `src/AGENTS.md`, `src/lua_api/AGENTS.md`, `docs/AGENTS.md`
- Primary tools: `tools/python.cmd tools/rag/query.py "docstring audit Rust lua_api generated docs" --profile engine --limit 10`, `tools/python.cmd tools/audit/docstring_audit.py`, `tools/python.cmd tools/docs/gen_rust_docstrings.py`, `tools/python.cmd tools/gen_all_docs.py`
- Owner profile: `doc_writer`

## Common RAG Queries
- Use when locating source-owned docs before prose edits:
  - `docstring audit Rust lua_api generated docs`
  - `/// lua api docs example`
  - `module docs comment generated`
- Common areas to inspect after top hits:
  - `src/`
  - `library/`
  - generated docs in `docs/`
  - examples proving behavior

## References
- `contracts: AGENTS.md, src/AGENTS.md, src/lua_api/AGENTS.md, docs/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "docstring audit Rust lua_api generated docs" --profile engine --limit 10, tools/python.cmd tools/audit/docstring_audit.py, tools/python.cmd tools/docs/gen_rust_docstrings.py, tools/python.cmd tools/gen_all_docs.py`
- `agent: doc_writer`
