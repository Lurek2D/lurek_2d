---
name: skill-name
description: "Use this skill when the task clearly matches this domain. Skip it for adjacent work owned by another skill."
---
# skill-name

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
- Path to the main source file, folder, or tool.

## Template Notes
- Copy this file to `.codex/skills/<skill-name>/SKILL.md`.
- Put load/skip routing in frontmatter and folder-local invariants in the nearest `AGENTS.md`.
