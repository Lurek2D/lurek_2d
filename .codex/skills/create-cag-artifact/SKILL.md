---
name: create-cag-artifact
description: "Load this skill when creating or modifying Codex CAG artifacts such as local skills, agents, and routing guidance. Skip it for product code, docs content unrelated to Codex behavior, or broad repo audits."
---

# create-cag-artifact

## Mission
- Create or modify active Codex CAG artifacts and keep validation and routing coherent.

## Domain Knowledge
- `AGENTS.md` stores rules for a directory tree.
- `.codex/agents/*.toml` stores role settings.
- `.codex/skills/*/SKILL.md` stores reusable task instructions.
- `.codex/config.toml` registers active agent profiles.
- `.codex/coverage.toml` maps repo domains to contracts and skills.
- A skill description is the routing rule. It must say when to load and when to skip.
- A skill body has four required sections: Mission, Domain Knowledge, Workflow, and References.
- Domain Knowledge contains repo facts. It does not contain advice or process steps.
- Workflow contains ordered actions. It does not repeat repo facts.
- Agent names in References must exist in `.codex/agents/`.
- `cag_validate.py` checks names, frontmatter, sections, owners, and size.
- `cag_link_check.py --strict` checks referenced repo paths.
- One `SKILL.md` may use at most 5000 normalized characters.
- The `.codex/skills` catalog should average 3000-4000 characters per skill.
- Creation, review, and routing skills must have different boundaries.
- A skill folder name must match its frontmatter `name`.
- The description must contain the literal routing clauses `Load this skill when` and `Skip it for`.
- Mission, Domain Knowledge, Workflow, and References must each appear exactly once.
- References require `contracts`, `tools`, one registered `agent`, and one `RAG:` line.
- Every active skill must be assigned to at least one domain in `.codex/coverage.toml`.
- Root `AGENTS.md` has a 4000-character cap; nested contracts have a 2500-character cap.
- `.codex/migration/` stores old-to-new mapping notes and does not override active skills.

## Workflow
1. Read the root contract and the nearest contract for the target path.
2. Classify each change as a contract rule, agent setting, skill instruction, or config entry.
3. Find the current owner. Do not create a second owner for the same rule.
4. Read the two closest skills and compare their descriptions.
5. Write a precise load rule and skip rule in frontmatter.
6. Write only repo facts in Domain Knowledge.
7. Write the normal task sequence as numbered Workflow steps.
8. Use only existing paths, commands, profiles, and parser names.
9. Update coverage or profile references when a skill name or owner changes.
10. Run `cag_validate.py`.
11. Run `cag_link_check.py --strict`.
12. Rebuild the RAG index.
13. Run recall queries for the edited skill and its closest neighbor.
14. Check size, duplicate facts, and routing conflicts before finishing.

## References
- `contracts: AGENTS.md, .codex/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "codex CAG skills agents prompts" --profile engine --limit 10, tools/python.cmd tools/validate/cag_validate.py, tools/python.cmd tools/audit/cag_link_check.py --strict`
- `agent: cag_architect`
- RAG: `codex CAG skills agents routing`; inspect `.codex/`, the nearest `AGENTS.md`, enforcing validator, and adjacent skills.
