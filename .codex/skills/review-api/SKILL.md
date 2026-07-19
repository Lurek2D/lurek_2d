---
name: review-api
description: "Load this skill when auditing and fixing Rust-to-Lua API coverage, thin wrappers, signatures, docs, and specs. Skip it for internal Rust-only tests or docs reviews without Lua API impact."
---
# review-api

## Mission
- Audit and fix Lua API parity between Rust modules, `src/lua_api/`, specs, and generated docs.
- Flag public namespace closures that perform runtime work owned by another module, even when a generic thin-wrapper heuristic passes.

## When To Load
- Auditing and fixing Rust-to-Lua API coverage, thin wrappers, signatures, docs, and specs.

## When To Skip
- Internal Rust-only tests or docs reviews without Lua API impact.

## Domain Knowledge
- Read root `AGENTS.md`, then every listed contract nearest to the reviewed path.
- Run the listed RAG query and audit/report tools before broad manual inspection.
- Prefer MCP server `lurek_tools` and repo CLI/audit tools before ad hoc scripts.
- Produce findings first with severity, affected files, and evidence.
- If the active profile is read-only, stop after findings and hand off fixes to the owner profile; otherwise fix requested findings and rerun the same audits.
- Treat review as audit-first, fix-second: findings must be grounded in tool output or direct file inspection.

## Workflow
- Run API coverage and thin-wrapper audits for the selected module.
- Compare Rust public methods, Lua wrappers, generated docs, and specs.
- Check that cross-module conversion workflows have one canonical consumer owner and explicit compatibility aliases.
- For tilemap, verify one-based Lua indices, typed option-table limits, finite/positive numeric validation, importer error tables, diagnostics fields, and the distinction between authoritative maps and renderer snapshots.
- For tileset, verify nested provider table limits, finite/positive animation and archetype fields, fallible quad queries, canonical namespace ownership, and compatibility-alias error parity.
- Compare compatibility aliases, nested table-field annotations, fallible/legacy method pairs, and documented numeric ceilings when reviewing the public surface.
- Record findings first with file paths and missing signatures.
- If edit-capable, fix wrappers/specs/docs and rerun the same audits.
- If read-only, hand off fixes to `lua_designer` or `developer`.
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
- Contracts: `AGENTS.md`, `src/lua_api/AGENTS.md`, `docs/specs/AGENTS.md`
- Primary tools: `tools/python.cmd tools/rag/query.py "Lua API wrapper coverage thin wrapper" --profile engine --limit 10`, `tools/python.cmd tools/audit/lua_covers_lurek_api_audit.py`, `tools/python.cmd tools/audit/thin_wrapper_audit.py`, `tools/python.cmd tools/gen_all_docs.py`
- Owner profile: `lua_designer`

## Common RAG Queries
- Start with: `Lua API wrapper coverage thin wrapper`, `Rust engine module lua_api docs specs`, `src lua_api AGENTS thin wrappers registration only`
- Focus areas first: `src/lua_api/`, `src/`, `docs/specs/`, `tests/lua/`, `tools/audit/`
- Append the API path or module name such as `lurek.input`, `lurek.render`, `math`, `scene`

## References
- `contracts: AGENTS.md, src/lua_api/AGENTS.md, docs/specs/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "Lua API wrapper coverage thin wrapper" --profile engine --limit 10, tools/python.cmd tools/audit/lua_covers_lurek_api_audit.py, tools/python.cmd tools/audit/thin_wrapper_audit.py, tools/python.cmd tools/gen_all_docs.py`
- `agent: lua_designer`
