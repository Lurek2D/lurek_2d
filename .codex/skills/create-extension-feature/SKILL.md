---
name: create-extension-feature
description: "Load this skill when creating or modifying VS Code extension commands, providers, webviews, snippets integration, or package wiring. Skip it for engine runtime changes, Lua demos, or generated API data without extension behavior changes."
---
# create-extension-feature

## Mission
- Create or modify VS Code extension features while preserving package wiring, generated API usage, and webview safety.

## When To Load
- Creating or modifying VS Code extension commands, providers, webviews, snippets integration, or package wiring.

## When To Skip
- Engine runtime changes, Lua demos, or generated API data without extension behavior changes.

## Domain Knowledge
- Read root `AGENTS.md`, then every listed contract nearest to the target path.
- Run the listed RAG query before broad file reads and start from top hits.
- Prefer MCP server `lurek_tools` and repo CLI/audit tools before ad hoc scripts.
- Check whether the target artifact already exists; modify existing content unless a new owner is clearly required.
- Read the nearest source, spec, test, doc, or config before editing.
- Treat create skills as create-or-modify workflows; existing artifacts are the default owner when present.

## Workflow
- Read `extension/vscode/AGENTS.md` and inspect `extension/vscode/package.json` plus relevant `src/` owner files.
- Modify existing command, provider, editor, or webview code when ownership already exists; create a new owner only when necessary.
- Declare every user-facing command, activation hook, setting, and menu contribution in `package.json`.
- Keep heavy logic out of activation and use generated API descriptors instead of ad hoc schemas.
- Run `npm run build` from `extension/vscode/`, then `npm run test` when behavior changed.
- Finish by reporting changed files and validation evidence.

## Success Criteria
- The target artifact was created or modified in the narrowest owning location.
- Existing content was preserved and updated when it already owned the behavior.
- Listed validation tools complete successfully, or any remaining failure is reported with exact output and next owner.

## Stop Conditions
- Required user intent, target module, or validation threshold is missing and cannot be inferred from repo context.
- A referenced owner path or tool is absent after checking the repository.
- Fixing a finding would require changing unrelated user work or widening scope beyond the requested surface.

## Companion File Index
- Contracts: `extension/vscode/AGENTS.md`
- Primary tools: `tools/python.cmd tools/rag/query.py "VS Code extension package.json webview commands" --profile engine --limit 10`, `npm run build`, `npm run test`
- Owner profile: `extension`

## Common RAG Queries
- Use when locating current VS Code extension ownership:
  - `VS Code extension package.json webview commands`
  - `package.json contributes commands views`
  - `hover completion tree view snippet`
- Common areas to inspect after top hits:
  - `extension/src/`
  - `extension/package.json`
  - `extension/webviews/`
  - `docs/` extension references

## References
- `contracts: extension/vscode/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "VS Code extension package.json webview commands" --profile engine --limit 10, npm run build, npm run test`
- `agent: extension`
