---
name: create-build
description: "Load this skill when creating or modifying Cargo profiles, release/debug/dist settings, packaging scripts, or build automation. Skip it for runtime feature work, docs-only changes, or pure test authoring."
---

# Goal
- Create or modify build, release, debug, dist, and packaging behavior while preserving local Windows-first tooling.

# Inputs
- User request, target artifact/module/path, and expected outcome.
- Relevant constraints from root and nested AGENTS files.
- Baseline output from the listed RAG query and audit/validation tools.

# Steps
1. Load the active `.codex/skills/create-build/SKILL.md` workflow as the source of truth.
2. Read root `AGENTS.md`, listed contracts, and relevant owner files before editing or reviewing.
3. Run the listed RAG query before broad file reads.
4. Inspect existing `Cargo.toml` profiles and `tools/dist/` scripts before adding new knobs.
5. Choose modify when a matching profile, script, or package path already exists; create only when there is no owner.
6. Measure the baseline size or compile time before changing flags.
7. Update the smallest build profile or packaging script that owns the requested behavior.
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
- User: Use `create-build` for the requested scope.
- Agent: Loads `.codex/skills/create-build/SKILL.md`, follows the workflow, and reports validation evidence.

# References
- skills: `.codex/skills/create-build/SKILL.md`
- contracts: AGENTS.md, tools/AGENTS.md
- tools: tools/python.cmd tools/rag/query.py "build profiles Cargo.toml dist tools" --profile engine --limit 10, cargo build --profile <profile>, cargo clippy -- -D warnings, tools/python.cmd tools/validate/cag_validate.py
- agent: builder

