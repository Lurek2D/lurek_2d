---
name: create-shader
description: "Load this skill when creating or modifying WGSL shaders or renderer shader-loader integration. Skip it for non-shader rendering logic, UI layouts, or visual asset edits only."
---

# Goal
- Create or modify WGSL shader code and integrate it with the existing renderer pipeline.

# Inputs
- User request, target artifact/module/path, and expected outcome.
- Relevant constraints from root and nested AGENTS files.
- Baseline output from the listed RAG query and audit/validation tools.

# Steps
1. Load the active `.codex/skills/create-shader/SKILL.md` workflow as the source of truth.
2. Read root `AGENTS.md`, listed contracts, and relevant owner files before editing or reviewing.
3. Run the listed RAG query before broad file reads.
4. Read `src/AGENTS.md`, inspect `assets/shaders/`, and inspect relevant `src/render/` loader/pipeline files.
5. Modify an existing shader when it owns the effect; create a new `.wgsl` file only for a new effect.
6. Keep shader names, bind groups, uniforms, and renderer loader wiring aligned.
7. Run `cargo check` for WGSL/rust validation and `cargo test` for render pipeline coverage.
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
- User: Use `create-shader` for the requested scope.
- Agent: Loads `.codex/skills/create-shader/SKILL.md`, follows the workflow, and reports validation evidence.

# References
- skills: `.codex/skills/create-shader/SKILL.md`
- contracts: src/AGENTS.md
- tools: tools/python.cmd tools/rag/query.py "WGSL shader src render pipeline" --profile engine --limit 10, cargo check, cargo test
- agent: developer

