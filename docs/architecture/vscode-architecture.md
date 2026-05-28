# Lurek2D â€” VS Code Extension Architecture

## TL;DR

The VS Code extension in `extension/vscode/` is the optional developer-experience layer for Lurek2D. It is not part of the engine binary. It provides Lua tooling, build/run/test commands, debug bridge integration, AI/MCP tools, and 41 interactive visual editor panels.

## Identity and activation

| Field | Value |
|---|---|
| Package name | `lurek2d-toolkit` |
| Display name | Lurek2D Toolkit |
| Version | `1.0.0` |
| VS Code engine | `^1.90.0` |
| Active entry point | `extension/vscode/src/extension.ts` |
| Bundle output | `extension/vscode/dist/extension.js` |

Activation remains lazy:

- `workspaceContains:**/main.lua`
- `workspaceContains:Cargo.toml`

The extension must not use `*` activation.

## Source layout

| Path | Responsibility |
|---|---|
| `src/extension.ts` | Composition root. Registers services, providers, commands, debug adapter, MCP server, and editor commands. |
| `src/commands/` | VS Code command handlers. |
| `src/providers/` | Language providers, sidebar views, diagnostics, monitors, and explorer providers. |
| `src/services/` | Extension-side business services such as API data, process launch, debug bridge, and status bar. |
| `src/editors/` | Active editor panel implementations and shared panel platform. Every panel has a concrete `*Editor.ts` file. |
| `src/test/` | VS Code test host and unit/integration tests. |
| `data/` | Generated extension data copied from engine docs/snippets. |

## Visual editor architecture

The editor system has concrete implementation files for every panel and a shared aggregator/host layer. The `*Editor.ts` files are the metadata source of truth and active command targets; the catalog only aggregates those local specs.

| File | Responsibility |
|---|---|
| `src/editors/types.ts` | Shared TypeScript contracts for editor specs, actions, tools, fields, exports, and state. |
| `src/editors/catalog.ts` | Aggregates all 41 local `*EditorSpec` constants and validates uniqueness/required fields. |
| `src/editors/panelHost.ts` | Webview panel lifecycle, CSP-safe HTML generation, interactive feature-action runtime, workspace drawing/state mutation, message handling, export, clipboard, insert-to-editor, and state persistence. |
| `src/editors/*Editor.ts` | Concrete active implementation file for each panel. Each file owns guide-derived metadata (`reference`, `useCase`, `vision`, eight `featureList` bullets, toolbar, tools, inspector, bottom panel, and export settings), exports an editor class, and opens its local spec. |
| `src/editors/implementations.ts` | Imports all 41 editor classes and exposes `EDITOR_IMPLEMENTATIONS` for runtime command registration. |
| `src/commands/editors.ts` | Registers `lurek.editor.*` commands from `EDITOR_IMPLEMENTATIONS`. |
| `src/providers/sidebar.ts` | Builds the Editors sidebar from `EDITOR_CATALOG`. |

Each panel follows the same spatial contract:

1. Top action toolbar.
2. Left tool picker.
3. Central workspace or canvas.
4. Right inspector.
5. Optional bottom output panel.
6. Status bar.

Every generated webview includes a Content Security Policy meta tag. External resource loads are not allowed.

Every editor spec also exposes eight typed feature actions. `src/editors/editorFactory.ts` derives those actions from the guide feature list, while `src/editors/panelHost.ts` renders them as clickable `data-feature-action` controls. A click must mutate live state, redraw the central workspace, update the inspector/log/export preview, and persist state through VS Code workspace storage.

Workspace-specific runtime behavior:

- `grid` â€” editable cell maps for tile maps, tilesets, navmeshes, voxel slices, provinces, and other spatial tools.
- `node` â€” stateful visual graphs with nodes, links, grouping, validation, simulation, and arrangement actions.
- `table` â€” editable data grids with rows, columns, filters, formulas, metrics, and validation actions.
- `timeline` â€” tracks, keyframes, playhead, easing, event markers, and play/pause state.
- `preview` â€” generated samples, overlays, sliders, simulation state, metrics, and snapshots.
- `document` â€” editable generated source with search, copy, insert, validation, style, and export actions.

## Editor catalog and local specs

The catalog contains exactly 41 panels grouped by workflow, but it does not own seed data. Local `src/editors/*Editor.ts` files export the specs. `src/editors/catalog.ts` imports those constants and exposes `EDITOR_CATALOG`, `EDITOR_COUNT`, `getEditorSpec`, `getEditorCommandIds`, and `validateEditorCatalog`.

### Map and world tools

- Tile Map Editor
- Tileset Editor
- Tilemap Script Editor
- World Map Editor
- Province Editor
- Globe Editor
- Procedural Map Generator
- NavMesh Editor

### Node and graph tools

- Scene Flow Editor
- Dialog Editor
- Quest Tree Editor
- AI Behavior Tree Editor
- Graph Editor
- Sound DSP Panel
- Visual Shader Editor
- Network Topology Editor

### Asset and visual tools

- Pixel Art Editor
- Particle Designer
- Sprite Animation Editor
- Shader Preview
- Voxel Editor
- Skeleton Rigging Editor
- Lighting Environment Editor
- PostFX Overlay Designer
- Color Palette Editor
- Font Preview Editor

### UI, data, and system tools

- GUI Widget Editor
- GUI Theme Editor
- Database Editor
- Input Mapper
- Localization Editor
- Physics Materials Editor
- Audio Mixer
- Global Autoload Editor
- Asset Manifest Editor
- Performance Profiler
- Project Export Editor
- Test Runner
- API Reference

## Command and manifest contract

`package.json` contributes every `lurek.editor.*` command from `EDITOR_CATALOG`. `src/commands/editors.ts` registers the concrete class list from `EDITOR_IMPLEMENTATIONS` at activation. `src/test/unit/editorCatalog.test.ts` verifies all directions:

- every catalog command is contributed in `package.json`,
- every contributed `lurek.editor.*` command exists in the catalog,
- every catalog editor has a concrete active `src/editors/<id>Editor.ts` file with `defineEditorSpec`, `featureList`, and `openEditorSpec`,
- every concrete implementation has a catalog entry,
- the sidebar exposes every catalog editor.

The task intentionally keeps the existing sidebar/command launch model. File-based `contributes.customEditors` is not the editor-panel architecture for this feature.

## Tests and validation

Extension-side checks:

- `npm run build` â€” regenerates extension data and bundles `dist/extension.js`.
- `npm test` â€” launches the VS Code test host and runs test suites.
- `npm run package` â€” validates manifest/package shape with VSCE.

Editor-specific tests verify:

- catalog uniqueness and required fields,
- 41 editor count,
- manifest synchronization,
- sidebar synchronization,
- webview CSP and required layout regions,
- eight clickable feature actions per editor,
- behavior-profile coverage for all 41 editor IDs,
- runtime handlers for grid/node/table/timeline/preview/document mutations,
- export wiring for feature actions, action history, and serialized editor state,
- no `src/editors_legacy/` directory and no active imports from a legacy editor backup.

## Boundaries

- The extension is optional. Engine runtime behavior must not depend on it.
- Extension code must not import Rust types.
- Generated API/snippet data must be regenerated through the configured scripts, not hand-edited.

