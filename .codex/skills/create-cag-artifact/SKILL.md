---
name: create-cag-artifact
description: "Create or update new prompt, agent, skill or update them, revalidate CAG after it."
---
# create-cag-artifact

## Goal
- Author or modify Context Augmented Guidance (CAG) artifacts in the active `.codex/` layer and keep the legacy `.github/` mirrors in sync when the migration surface still matters.

## Required inputs
- Artifact type: agent, skill, or prompt
- Desired behavioral change or definition
- User must define what the CAG system needs to learn or adjust
- Agent must collect the current CAG validation rules before editing

## Profile hint
- `cag_architect`

## Read these contracts
- `AGENTS.md`
- `.codex/AGENTS.md`

## Steps
- Read the listed contracts before editing CAG artifacts.
- Identify the active target surface first: `.codex/agents/` or `.codex/skills/`; use `.github/agents/`, `.github/skills/`, or `.github/prompts/` only when you are explicitly syncing a legacy mirror.
- Edit or create the Markdown file with strict YAML formatting and a mandatory metadata block.
- Execute `python tools/validate/cag_validate.py`. If it exits with code >0, fix the YAML metadata or naming conventions and repeat this step.
- Execute `python tools/audit/cag_link_check.py --strict`. If it reports >0 broken links, fix the file references and repeat.

## Outputs
- Updated CAG artifact files (`.md`)
- Clean validation output

## Success criteria
- [ ] `python tools/validate/cag_validate.py` exits with code 0 (exactly 0 validation errors).
- [ ] `python tools/audit/cag_link_check.py --strict` exits with code 0 (exactly 0 broken links).

## Stop conditions
- Creating overlapping skills or agents that confuse the routing logic.
- Failing to include the mandatory `CAG Metadata` block.

## References
- `contracts: AGENTS.md, .codex/AGENTS.md`
- `tools: python tools/validate/cag_validate.py, python tools/audit/cag_link_check.py`
- `agent: cag_architect`


