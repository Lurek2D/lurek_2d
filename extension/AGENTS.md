# Extension Contract

This file adds local rules for work under `extension/`.

## Mission
- Own the VS Code extension and editor-facing TypeScript integration.
- Keep editor UX aligned with the engine and the generated data model.

## Scope
- `extension/vscode/` TypeScript source and extension packaging.
- `package.json` contributions, commands, and UI integration.
- Generated data consumers, activation flow, and extension validation.

## Local map
- `vscode/` is the real extension workspace; check its own `package.json`, `src/`, `tools/`, `docs/`, `data/`, and `cag/` directories before making assumptions.
- Build and packaging files such as `esbuild.config.mjs`, `tsconfig.json`, `.vscodeignore`, and the extension-local `README.md` shape the shipped artifact.
- `language-configuration.json` and generated snippet or data files are contract surfaces for editor behavior; keep them aligned with the runtime and docs generators.
- Treat committed `.vsix` artifacts as release outputs, not the primary source of truth.

## Local rules
- Keep the extension thin and delegate heavy logic to checked-in scripts or generated data.
- Keep `package.json` contributions aligned with implemented commands and UI.
- Do not move engine or packaging logic into extension code.
- Validate extension build or activation flow after meaningful changes.
- Keep editor-facing labels, menus, and commands explicit.

## Workflow
- Read the extension entry points, package manifest, and nearby generated data first.
- Load `vscode-extension`, `ui-html`, and `ui-layout` when editing editor UX.
- Refresh generated data before checking the extension build if the source contract changed.
- Validate the narrowest extension path that touches the change.

## Expected outputs
- Extension source changes with command and packaging alignment.
- Build or activation validation proof for the touched path.

## Anti-patterns
- Add hidden commands without a manifest entry.
- Reimplement engine logic in the extension layer.
- Let generated data or package metadata drift.

## References
- `extension/vscode/`
- `package.json`
- `tools/`
