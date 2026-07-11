---
name: route-prompt
description: "Load this skill when choosing the best active Codex skill and owner profile for a user request. Skip it for executing the selected workflow or doing implementation directly."
---
# route-prompt

## Mission
- Route user requests to the narrowest active Codex skill and an existing owner profile.

## When To Load
- Choosing the best active Codex skill and owner profile for a user request.

## When To Skip
- Executing the selected workflow or doing implementation directly.

## Domain Knowledge
- Read root `AGENTS.md` and `.codex/AGENTS.md` before routing.
- Use RAG and filesystem metadata to avoid guessing available skills or prompts.

## Workflow
- Read `.codex/AGENTS.md`, root `AGENTS.md`, active agent TOMLs, and relevant skill metadata.
- Search `.codex/skills` first because it is the active Codex surface.
- Choose one primary skill and one owner profile; mention supporting skills only when needed.
- Use only owner profiles that are actually registered under `.codex/agents/`.
- Do not invent new agent names in routing output.
- Return a concrete invocation or handoff with no invented filenames.
- Finish by reporting changed files and validation evidence.

## Success Criteria
- Output names exactly one primary active skill and one existing owner profile unless no active skill fits.
- Listed validation tools complete successfully, or any remaining failure is reported with exact output and next owner.

## Stop Conditions
- Required user intent, target module, or validation threshold is missing and cannot be inferred from repo context.
- A referenced owner path or tool is absent after checking the repository.
- Fixing a finding would require changing unrelated user work or widening scope beyond the requested surface.

## Companion File Index
- Contracts: `.codex/AGENTS.md`, `AGENTS.md`
- Primary tools: `tools/python.cmd tools/rag/query.py "codex skills agents routing" --profile all --limit 10`, `filesystem reads of .codex/skills and .codex/agents`
- Owner profile: `manager`

## Common RAG Queries
- Start with: `codex skills agents routing`, `Codex AGENTS skills agents routing`, `codex CAG skills agents prompts`
- Focus areas first: `.codex/skills/`, `.codex/agents/`, `.codex/AGENTS.md`, root `AGENTS.md`
- If the request names a surface, append it directly: `tests`, `pages`, `tool`, `module`, `extension`, `rag`

## References
- `contracts: .codex/AGENTS.md, AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "codex skills agents routing" --profile all --limit 10, filesystem reads of .codex/skills and .codex/agents`
- `agent: manager`
