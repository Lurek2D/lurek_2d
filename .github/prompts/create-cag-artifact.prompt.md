---
name: create-cag-artifact
description: "Load this skill when creating or modifying Codex CAG artifacts such as local skills, agents, prompts, routing guidance, or legacy prompt mirrors. Skip it for product code, docs content unrelated to Codex behavior, or broad repo audits."
---

# Goal
- Create or modify active Codex CAG artifacts and keep validation, routing, and legacy mirrors coherent.

# Inputs
- User request, target artifact/module/path, and expected outcome.
- Relevant constraints from root and nested AGENTS files.
- Baseline output from the listed RAG query and audit/validation tools.

# Steps
1. Load the active `.codex/skills/create-cag-artifact/SKILL.md` workflow as the source of truth.
2. Read root `AGENTS.md`, listed contracts, and relevant owner files before editing or reviewing.
3. Run the listed RAG query before broad file reads.
4. Identify the active surface first: `.codex/agents/`, `.codex/skills/`, or `.github/prompts/` legacy mirror.
5. Read validator rules before editing; skill frontmatter requires only `name` and `description`.
6. Use `## CAG Metadata` only where the validator or artifact type needs body metadata such as related skills; do not require it for every skill.
7. For same-name legacy prompt mirrors, sync only the parts that would otherwise conflict with the active `.codex` artifact.
8. Report changed files, findings, validation output, and unresolved blockers.

# Success Criteria
- [ ] The active `.codex/skills` workflow and this legacy prompt do not conflict.
- [ ] Required validation commands are run or explicitly reported as blocked.
- [ ] Output includes concrete files, tools, and owner profile.

# Anti-patterns
- Using `.github/skills` as the active source when `.codex/skills` has a same-name skill.
- Skipping RAG, AGENTS contracts, or repo audit tools before broad manual inspection.
- Creating new artifacts when an existing owner should be modified.

# Example Invocation
- User: Use `create-cag-artifact` for the requested scope.
- Agent: Loads `.codex/skills/create-cag-artifact/SKILL.md`, follows the workflow, and reports validation evidence.

# References
- skills: `.codex/skills/create-cag-artifact/SKILL.md`
- contracts: AGENTS.md, .codex/AGENTS.md
- tools: tools/python.cmd tools/rag/query.py "codex CAG skills agents prompts" --profile engine --limit 10, tools/python.cmd tools/validate/cag_validate.py, tools/python.cmd tools/audit/cag_link_check.py --strict
- agent: cag_architect

