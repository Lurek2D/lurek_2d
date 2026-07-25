---
# Copy to `.codex/skills/<skill-name>/SKILL.md`.
# Keep the folder name and `name` value identical.
# The description must contain both literal routing clauses:
# `Load this skill when ...` and `Skip it for ...`.
name: skill-name
description: "Load this skill when the task clearly matches this domain. Skip it for adjacent work owned by another skill."
---
# skill-name

<!-- Validator notes: keep one H1, exactly these four H2 sections, no fenced code blocks, and a registered agent reference. -->

## Mission
- Own one narrow knowledge area.

## Domain Knowledge
- High-value repo-specific rules.
- Current file or tool anchors.
- Constraints, sync rules, and failure modes.
- Keep this section concrete, unique, and concise.

## Workflow
- Read the owning files and primary specs first.
- Run the narrowest relevant validation before closing.
- Report touched files, proof, and residual risk.

## References
- `contracts: AGENTS.md, path/to/AGENTS.md`
- `tools: tools/python.cmd path/to/check.py`
- `agent: registered_role`
- RAG: `representative retrieval phrase`; `canonical/path/`
