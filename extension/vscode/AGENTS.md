# VS Code Contract

This file adds local rules for work under `extension/vscode/`.

## Mission
- Own the shipped VS Code extension workspace.
- Keep manifest, generated data, tests, and webview security aligned.

## Scope
- `extension/vscode/package.json`
- `extension/vscode/src/`
- `extension/vscode/tools/`, `data/`, and extension-local tests and docs.

## Local map
- `src/commands/` owns command entry points.
- `src/providers/` owns providers and sidebar integrations.
- `src/editors/` owns local editor specs plus the shared panel host and factory.
- `src/services/` owns extension-side logic and wrappers around repo tools.
- `data/` and `src/generated/` are generated-data consumers, not the primary source of truth.

## Local rules
- Every command, activation trigger, view, and contribution point must be declared in `package.json`.
- Keep generated API data flowing from `python tools/docs/gen_extension_api.py` into `extension/vscode/data/` and then `extension/vscode/src/generated/`; do not patch generated outputs by hand.
- Webviews must include a `Content-Security-Policy` meta tag and should prefer nonce-scoped scripts and styles where the host path already supports it.
- Keep editor panel responsibilities split: local editor spec in the concrete editor file, shared runtime in `panelHost.ts`, shared spec helpers in `editorFactory.ts`.
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
