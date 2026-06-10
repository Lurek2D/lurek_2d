---
name: create-cag-artifact
description: "Load this skill when creating or modifying Codex CAG artifacts such as local skills, agents, prompts, routing guidance, or legacy prompt mirrors. Skip it for product code, docs content unrelated to Codex behavior, or broad repo audits."
---
# create-cag-artifact

## Mission
- Create or modify active Codex CAG artifacts and keep validation, routing, and legacy mirrors coherent.

## When To Load
- Creating or modifying Codex CAG artifacts such as local skills, agents, prompts, routing guidance, or legacy prompt mirrors.

## When To Skip
- Product code, docs content unrelated to Codex behavior, or broad repo audits.

## Domain Knowledge
- Read root `AGENTS.md`, then every listed contract nearest to the target path.
- Run the listed RAG query before broad file reads and start from top hits.
- Prefer MCP server `lurek_tools` and repo CLI/audit tools before ad hoc scripts.
- Check whether the target artifact already exists; modify existing content unless a new owner is clearly required.
- Read the nearest source, spec, test, doc, or config before editing.
- Treat create skills as create-or-modify workflows; existing artifacts are the default owner when present.

## Workflow
- Identify the active surface first: `.codex/agents/`, `.codex/skills/`, or `.github/prompts/` legacy mirror.
- Read validator rules before editing; skill frontmatter requires only `name` and `description`.
- Use `## CAG Metadata` only where the validator or artifact type needs body metadata such as related skills; do not require it for every skill.
- For same-name legacy prompt mirrors, sync only the parts that would otherwise conflict with the active `.codex` artifact.
- Run CAG validation and strict link checking after edits.
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
- Contracts: `AGENTS.md`, `.codex/AGENTS.md`
- Primary tools: `tools/python.cmd tools/rag/query.py "codex CAG skills agents prompts" --profile engine --limit 10`, `tools/python.cmd tools/validate/cag_validate.py`, `tools/python.cmd tools/audit/cag_link_check.py --strict`
- Owner profile: `cag_architect`

## Common RAG Queries
- Use when locating current Codex guidance before editing:
  - `codex CAG skills agents prompts`
  - `AGENTS.md SKILL.md prompt routing`
  - `.codex skills agents vendor_imports`
- Common areas to inspect after top hits:
  - `.codex/`
  - `.agents/`
  - root `AGENTS.md`
  - nested `AGENTS.md`

## References
- `contracts: AGENTS.md, .codex/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "codex CAG skills agents prompts" --profile engine --limit 10, tools/python.cmd tools/validate/cag_validate.py, tools/python.cmd tools/audit/cag_link_check.py --strict`
- `agent: cag_architect`
