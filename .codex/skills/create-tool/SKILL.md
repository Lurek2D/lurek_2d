---
name: create-tool
description: "Load this skill when creating or modifying tools under tools, audit scripts, validators, generators, or CLI registry entries. Skip it for product runtime changes or one-off local scripts that should stay in work/."
---
# create-tool

## Mission
- Create or modify repo tools so they are discoverable, documented, locally runnable, and registered.

## When To Load
- Creating or modifying tools under tools, audit scripts, validators, generators, or CLI registry entries.

## When To Skip
- Product runtime changes or one-off local scripts that should stay in work/.

## Domain Knowledge
- Read root `AGENTS.md`, then every listed contract nearest to the target path.
- Run the listed RAG query before broad file reads and start from top hits.
- Prefer MCP server `lurek_tools` and repo CLI/audit tools before ad hoc scripts.
- Check whether the target artifact already exists; modify existing content unless a new owner is clearly required.
- Read the nearest source, spec, test, doc, or config before editing.
- Treat create skills as create-or-modify workflows; existing artifacts are the default owner when present.

## Workflow
- Inspect existing tool family, `tools/agent_cli_reference.md`, and nearest `AGENTS.md` before editing.
- Modify an existing tool when it owns the behavior; create a new script only for a new reusable command.
- Implement `--help`, deterministic output, and Windows-local execution.
- Register changed tools in `tools/agent_cli_reference.md`.
- Run the tool directly, then `tool_registry_audit.py` and CAG validation if shared contracts changed.
- Finish by reporting changed files and validation evidence.

## Success Criteria
- The target artifact was created or modified in the narrowest owning location.
- Existing content was preserved and updated when it already owned the behavior.
- Listed validation tools complete successfully, or any remaining failure is reported with exact output and next owner.

## Stop Conditions
- Required user intent, target module, or validation threshold is missing and cannot be inferred from repo context.
- A referenced owner path or tool is absent after checking the repository.
- Fixing a finding would require changing unrelated user work or widening scope beyond the requested surface.

## Companion File Index
- Contracts: `tools/AGENTS.md`, `tools/audit/AGENTS.md`
- Primary tools: `tools/python.cmd tools/rag/query.py "tools audit validator CLI registry" --profile engine --limit 10`, `tools/python.cmd tools/audit/tool_registry_audit.py`, `tools/python.cmd tools/validate/cag_validate.py`
- Owner profile: `builder`

## Common RAG Queries
- Start with: `tools audit validator CLI registry`, `tool registry audit agent cli reference`, `cag validate baseline prompts skills agents`
- Focus areas first: `tools/`, `tools/audit/`, `tools/validate/`, `tools/tests/`, root `AGENTS.md`
- Append the tool family or script name such as `rag`, `audit`, `validate`, `mcp`, `snippets`

## References
- `contracts: tools/AGENTS.md, tools/audit/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "tools audit validator CLI registry" --profile engine --limit 10, tools/python.cmd tools/audit/tool_registry_audit.py, tools/python.cmd tools/validate/cag_validate.py`
- `agent: builder`
