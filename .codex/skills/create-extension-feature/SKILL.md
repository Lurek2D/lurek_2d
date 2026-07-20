---
name: create-extension-feature
description: "Load this skill when creating or modifying VS Code extension commands, providers, webviews, snippets integration, or package wiring. Skip it for engine runtime changes, Lua demos, or generated API data without extension behavior changes."
---

# create-extension-feature

## Mission
- Create or modify VS Code extension features while preserving package wiring, generated API usage, and webview safety.

## Domain Knowledge
- Extension ownership is divided among `extension/vscode/src/commands`, `providers`, `editors`, `panels`, and `services`; `extension/vscode/package.json` is the declarative counterpart that makes commands, views, menus, settings, and activation reachable.
- Generated engine/API descriptors under extension data/generated paths originate in repository generators; consumers may change, but parallel handwritten schemas will drift.
- Webviews cross a trust boundary: the extension host owns filesystem/process access, while pages use typed messages, strict CSP, explicit state restoration, and disposal-aware lifecycle.
- Providers and completion/hover features run on editor-critical paths, so indexing, engine invocation, and filesystem scans belong in services/background work rather than activation or synchronous UI callbacks.
- Command identifiers form a three-way contract among registration code, manifest contributions, and menus/keybindings.
- Workspace trust, remote workspaces, untitled documents, and multi-root folders affect filesystem and process features; commands must derive scope from VS Code URIs and active workspace state rather than assuming a local single-root path.
- Webview protocol changes need versioned or backward-tolerant message handling when panels can restore after extension reload, and every listener, watcher, terminal, and panel resource must join the extension disposal lifecycle.
- User-facing errors should distinguish unavailable engine/tooling, invalid project content, cancellation, and extension defects so commands do not collapse actionable conditions into a generic notification.

## Workflow
- Map the user journey from manifest contribution to registration, service/provider owner, and webview channel; inspect generated data provenance before deciding whether TypeScript, manifest, generator, or several layers must change.
- Implement in the smallest owner with lazy activation, disposable registrations, cancellation for long work, URI-safe workspace access, and typed host/webview messages with CSP-compatible assets.
- Wire exact identifiers through `package.json`, registration, views/menus/settings, and tests; regenerate engine-derived data with `tools/docs/gen_extension_api.py` instead of patching emitted JSON.
- Build and test from `extension/vscode/`, exercise UI in an Extension Development Host, and verify reload/disposal plus empty-workspace and missing-engine paths before packaging.
- Trace telemetry/logging and output-channel behavior for the new flow, keeping user data and workspace contents out of diagnostics unless explicitly required while still preserving commands and paths needed for reproduction.
- Verify command enablement and visibility contexts against supported editor/file/workspace states so the feature is neither unreachable in valid Lurek projects nor offered where it can only fail.

## References
- `contracts: extension/vscode/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "VS Code extension package.json webview commands" --profile engine --limit 10, npm run build, npm run test`
- `agent: extension`
- RAG: `VS Code extension package.json webview commands`; `package.json contributes commands views`; `hover completion tree view snippet`; `extension/src/`; `extension/package.json`; `extension/webviews/`; `docs/` extension references
