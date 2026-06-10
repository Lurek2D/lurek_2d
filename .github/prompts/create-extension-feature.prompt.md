---
name: create-extension-feature
description: "Load this skill when creating or modifying VS Code extension commands, providers, webviews, snippets integration, or package wiring. Skip it for engine runtime changes, Lua demos, or generated API data without extension behavior changes."
---

# Goal
- Create or modify VS Code extension features while preserving package wiring, generated API usage, and webview safety.

# Inputs
- User request, target artifact/module/path, and expected outcome.
- Relevant constraints from root and nested AGENTS files.
- Baseline output from the listed RAG query and audit/validation tools.

# Steps
1. Load the active `.codex/skills/create-extension-feature/SKILL.md` workflow as the source of truth.
2. Read root `AGENTS.md`, listed contracts, and relevant owner files before editing or reviewing.
3. Run the listed RAG query before broad file reads.
4. Read `extension/vscode/AGENTS.md` and inspect `extension/vscode/package.json` plus relevant `src/` owner files.
5. Modify existing command, provider, editor, or webview code when ownership already exists; create a new owner only when necessary.
6. Declare every user-facing command, activation hook, setting, and menu contribution in `package.json`.
7. Keep heavy logic out of activation and use generated API descriptors instead of ad hoc schemas.
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
- User: Use `create-extension-feature` for the requested scope.
- Agent: Loads `.codex/skills/create-extension-feature/SKILL.md`, follows the workflow, and reports validation evidence.

# References
- skills: `.codex/skills/create-extension-feature/SKILL.md`
- contracts: extension/vscode/AGENTS.md
- tools: tools/python.cmd tools/rag/query.py "VS Code extension package.json webview commands" --profile engine --limit 10, npm run build, npm run test
- agent: extension

