# Extension Contract

Covers work under `extension/`.

## Mission
- Own the VS Code extension and editor-facing TypeScript integration.
- Keep editor UX aligned with the engine and generated data model.

## Scope
- `extension/vscode/` TypeScript source and packaging.
- `package.json` contributions, commands, and UI integration.

## Local map
- `vscode/` is the real extension workspace.
- `esbuild.config.mjs`, `tsconfig.json`, `.vscodeignore`, and the extension-local `README.md` shape the shipped artifact.
- `language-configuration.json` and generated snippet or data files are contract surfaces.
- Committed `.vsix` artifacts are release outputs, not source.

## Rules
- Keep the extension thin and delegate heavy logic to checked-in scripts or generated data.
- Keep `package.json` contributions aligned with implemented commands and UI.
- Do not move engine or packaging logic into extension code.
- Validate extension build or activation flow after meaningful changes.
- Keep editor-facing labels, menus, and commands explicit.
- Treat `extension/vscode/data/` and `extension/vscode/src/generated/` as generated-consumer surfaces.
- Keep debugbridge protocol changes synchronized with `src/debugbridge/`.

## Workflow
- Read the extension entry points, package manifest, and nearby generated data first.
- Use this file and `extension/vscode/AGENTS.md` as the source of truth for extension UX work.
- Refresh generated data before checking the extension build if the source contract changed.
- Validate the narrowest extension path that touches the change.

## References
- `extension/vscode/`
- `package.json`
- `tools/`
