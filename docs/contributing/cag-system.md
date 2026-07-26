# Codex CAG System Guide

Lurek2D's active CAG layer is `.codex/` plus root and nested `AGENTS.md` contracts.

## Ownership

- `AGENTS.md` owns path-local invariants.
- `.codex/agents/*.toml` owns registered role runtime settings.
- `.codex/skills/*/SKILL.md` owns reusable workflows and routing predicates.
- `.codex/coverage.toml` owns the required domain matrix.

## Validation

- `cag_validate.py` enforces structure, limits, role registry parity, skill references, and domain assignment.
- `cag_link_check.py` verifies structured References across skills and contracts.
- `cag_coverage.py --require-workspace` proves every required domain is present in the full multi-repository workspace.

The retired `.github` Copilot prompt, prompt catalog, and agent Markdown files are not CAG sources.
