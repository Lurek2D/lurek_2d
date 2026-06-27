---
name: review-examples
description: "Load this skill when auditing and fixing example coverage, example correctness, and content/examples conventions. Skip it for full demos, snippets, or internal tests."
---
# review-examples

## Mission
- Audit and fix API example coverage and example quality.
- Enforce one public API = one example owner block in `content/examples/`.

## When To Load
- Auditing and fixing example coverage, example correctness, and content/examples conventions.

## When To Skip
- Full demos, snippets, or internal tests.

## Domain Knowledge
- Read root `AGENTS.md`, then every listed contract nearest to the reviewed path.
- Run the listed RAG query and audit/report tools before broad manual inspection.
- Prefer MCP server `lurek_tools` and repo CLI/audit tools before ad hoc scripts.
- Produce findings first with severity, affected files, and evidence.
- If the active profile is read-only, stop after findings and hand off fixes to the owner profile; otherwise fix requested findings and rerun the same audits.
- Treat review as audit-first, fix-second: findings must be grounded in tool output or direct file inspection.

## Workflow
- Run example coverage for the selected scope.
- Inspect uncovered or thin APIs and existing example owners before editing.
- Enforce exact parser shape: `--@api:` or temporary `--@api-stub:` followed immediately by `do`, no top-level setup, no duplicate markers, and at least 5 non-comment code lines for real examples.
- Report missing, TODO, or PART example blocks first.
- If edit-capable, add or modify examples and rerun coverage plus validation.
- If read-only, hand off to `content` with target API methods.
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
- Contracts: `AGENTS.md`, `content/AGENTS.md`, `content/examples/AGENTS.md`, `docs/AGENTS.md`
- Primary tools: `tools/python.cmd tools/rag/query.py "example coverage content examples API" --profile game --limit 10`, `tools/python.cmd tools/audit/example_coverage.py --module <module>`, `tools/python.cmd tools/validate/validate_example_coverage.py`
- Owner profile: `content`

## Common RAG Queries
- Use when locating example owners and similar samples:
  - `example coverage content examples API`
  - `content examples lua sample feature`
  - `docs example usage snippet`
- Common areas to inspect after top hits:
  - `content/examples/`
  - `docs/`
  - `library/`
  - feature-owning modules in `src/`

## References
- `contracts: AGENTS.md, content/AGENTS.md, content/examples/AGENTS.md, docs/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "example coverage content examples API" --profile game --limit 10, tools/python.cmd tools/audit/example_coverage.py --module <module>, tools/python.cmd tools/validate/validate_example_coverage.py`
- `agent: content`
