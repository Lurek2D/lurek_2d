---
name: vscode-extension
description: "Load this skill when building, debugging, or extending the Luna2D VS Code extension in vscode-extension/. Use for: adding IntelliSense completions, MCP server endpoints, webview panels, new commands, extension configuration, or publishing. Skip it for engine Rust code, game scripting, or documentation outside the extension."
---

# VS Code Extension — Luna2D

## Load When

- Adding IntelliSense completions for `luna.*` API functions
- Implementing new MCP server endpoints or tools
- Creating or modifying webview panels
- Adding VS Code commands (`luna2d.*`)
- Debugging extension activation or provider errors
- Publishing the extension or updating the manifest

## Owns

- VS Code extension activation and command registration
- IntelliSense provider architecture (`completionProvider`, `hoverProvider`, `luacatsProvider`)
- MCP server implementation (`vscode-extension/src/mcp/server.ts`)
- Extension packaging, testing, and publishing workflow

## Extension Layout

```
vscode-extension/
├── package.json           — manifest: commands, contributes, activationEvents
├── src/
│   ├── extension.ts       — activate() entry point
│   ├── mcp/server.ts      — MCP server (methods, responses)
│   ├── services/
│   │   └── apiData.ts     — loads api_data.json / lua_api_reference_generated.md
│   └── providers/
│       ├── completionProvider.ts   — luna.* completions
│       ├── hoverProvider.ts        — hover docs
│       ├── luacatsProvider.ts      — LuaCATS ---@class / ---@param parsing
│       └── diagnosticsProvider.ts — inline errors
├── assets/                — extension icons, media
└── out/                   — compiled JS (git-ignored)
```

## IntelliSense Architecture

- **User-defined class completions**: parsed from LuaCATS annotations (`---@class`, `---@param`, `---@return`, `---@field`) in game Lua files via `luacatsProvider.ts`

## Development Loop

```powershell
cd vscode-extension
npm install           # install dependencies
npm run compile       # TypeScript → JS (out/)
# Press F5 in VS Code to launch Extension Development Host
# Make changes → Ctrl+Shift+P → "Developer: Reload Window" to apply
```

## Build and Package

```powershell
cd vscode-extension
npm run package       # creates .vsix file for manual install
# or
vsce publish          # publish to VS Code Marketplace (requires auth token)
```

## MCP Server

The MCP server exposes Luna2D engine capabilities to AI agents:

- Defined in `vscode-extension/src/mcp/server.ts`
- Methods follow JSON-RPC 2.0 over stdio
- Add new MCP tools by registering handler functions in `vscode-extension/src/mcp/server.ts`
- Reference `docs/API/` and `docs/API/lua_api_data.json` for available API surface

## Adding a New Command

1. Register in `package.json` under `contributes.commands`
2. Add activation in `activationEvents` if needed
3. Implement handler in `extension.ts` — `vscode.commands.registerCommand("luna2d.yourCmd", () => { ... })`
4. Test in Extension Development Host (F5)

## Adding a New Completion Source

1. Parse source data in `services/apiData.ts`
2. Return `vscode.CompletionItem[]` from `completionProvider.ts`
3. Register the provider in `extension.ts` with correct trigger characters and language selector (`lua`)

## Testing the Extension

```powershell
npm run test          # runs vscode test runner (headless, separate process)
```

- Tests run via `npm run test` (vscode test runner)
- Use `@vscode/test-electron` for integration tests against real VS Code API

## Anti-Patterns

- **Hard-coding luna.* lists**: Always derive completions from `docs/API/lua_api_data.json` — never maintain a hand-written list alongside the generated source
- **Blocking the main thread**: Use `async/await` for file I/O in providers — VS Code providers are called synchronously but can return `Promise`
- **Skipping activation guards**: Check `context.subscriptions` and dispose providers on deactivation to prevent memory leaks
