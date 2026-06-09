# VS Code Contract

Covers work under `extension/vscode/`.

## Mission
- Own the shipped VS Code extension workspace.
- Keep manifest, generated data, tests, and webview security aligned.

## Scope
- `extension/vscode/package.json`, `extension/vscode/src/`, and extension-local tools, data, tests, and docs.

## Local map
- `src/commands/` owns command entry points.
- `src/providers/` owns providers and sidebar integrations.
- `src/editors/` owns local editor specs plus the shared panel host and factory.
- `src/services/` owns extension-side logic and repo-tool wrappers.
- `data/` and `src/generated/` consume generated data.

## Rules
- Declare every command, activation trigger, view, and contribution point in `package.json`.
- Keep generated API data flowing from `python tools/docs/gen_extension_api.py` into `extension/vscode/data/` and then `extension/vscode/src/generated/`.
- Webviews must include a `Content-Security-Policy` meta tag.
- Keep editor panel responsibilities split between the concrete editor file, `panelHost.ts`, and `editorFactory.ts`.
- If a change touches debugbridge message shapes, update the engine-side protocol contract in the same task.

## Workflow
- Run `npm run build` after meaningful TypeScript or manifest changes.
- Run `npm test` when touching extension behavior covered by unit tests.
- Run `npx @vscode/vsce package --no-dependencies --allow-missing-repository` after changing contribution points or packaging metadata.

## References
- `extension/vscode/package.json`
- `extension/vscode/README.md`
- `extension/vscode/docs/vscode-extension.md`
- `tools/docs/gen_extension_api.py`
