---
inclusion: manual
---

# vscode-extension

## Mission
Own extension-side commands, data flow, and editor integration behavior.

## When To Use
- Add extension commands.
- Change completion or language features.
- Build a webview or extension UI feature.
- Debug extension behavior.

## When To Skip
- Engine Rust code, game scripts, docs outside the extension scope.

## Rules

### Layer Ownership in extension/vscode/src/
- `commands/` — VS Code command registration and entry points.
- `providers/` — language providers (completion, hover, diagnostics).
- `editors/` — custom editors and webviews.
- `services/` — extension-side business logic and state.
- `generated/` — files produced by engine-side generators. Never hand-edit.
- `mcp/` — MCP server integration.

Do not mix responsibilities across layers.

### package.json Is the Contract
Every command, view, editor type, activation event, and contribution point must be declared in `package.json`. Code that registers a command not in `package.json` is invisible to users.

### Build and Test Commands
Run from `extension/vscode/`:
- `npm run build` — esbuild bundle.
- `npm run watch` — incremental build.
- `npm test` — extension test harness.

The root `tools/dev/parallel_cargo.py` does not manage the extension.

### Generated Data
Under `extension/vscode/src/generated/` comes from `python tools/docs/gen_extension_api.py`. Never hand-edit generated files. If generated data seems stale, regenerate and commit both.

### MCP Integration
`mcp/` expects specific message shapes defined in `src/debugbridge/`. Changes to debugbridge message types require synchronized updates to the MCP handler. Check `docs/specs/debugbridge.md` for the wire format before changing either side.

### Activation Cost Rule
Extension must activate lazily. Prefer `onCommand:` activation events. `*` activation (activate on any VS Code start) is a performance defect.

### Webview Security
All webview HTML must include a CSP `<meta>` tag. No inline scripts. No external resource loads. Use `vscode-resource:` URIs for local assets. A webview without a CSP header is a security defect.

### Extension-Rust Boundary
The extension communicates with the engine exclusively through the debug bridge protocol over stdio or a local socket. Never import Rust types directly into TypeScript or vice versa.

### Before Committing
Run `vsce package` to validate the manifest schema and confirm the extension packages without errors.

### A-01 Applies
The extension is a developer-experience layer, not part of the engine binary. Engine behavior must not depend on extension presence.

## References
- `extension/vscode/src/`
- `extension/vscode/package.json`
- `extension/vscode/esbuild.config.mjs`
- `tools/docs/gen_extension_api.py`
