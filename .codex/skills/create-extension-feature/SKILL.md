---
name: create-extension-feature
description: "End to end workflow to add new feature to extension for lurek, MS VS Code."
---
# create-extension-feature

## Goal
- Develop a new feature for the Lurek2D VS Code extension (e.g., language features, commands, panels).

## Required inputs
- Feature description (e.g., new autocomplete, custom webview panel)
- User must define the extension's functional requirement
- Agent must collect the extension's current API usage and generated stub definitions

## Profile hint
- `extension`

## Read these contracts
- `extension/AGENTS.md`
- `extension/vscode/AGENTS.md`

## Steps
- Read the listed contracts before editing the extension.
- Edit `package.json` in the extension root to define new commands or keybindings.
- Write the feature code (TypeScript/JS) in the extension `src/` directory.
- Execute `npm run compile`. If it exits with code >0, fix the syntax errors.
- Execute `npm run test` (or the extension's integration test suite). If tests pass rate is <100%, fix the broken logic and repeat step 4.

## Outputs
- Modified VS Code extension source code
- Updated `package.json`
- Test results

## Success criteria
- [ ] `npm run compile` exits with code 0 (0 compilation errors).
- [ ] `npm run test` exits with code 0 (100% tests pass).

## Stop conditions
- Breaking backwards compatibility with older Lurek2D projects.
- Ignoring standard VS Code UI/UX guidelines.

## References
- `contracts: extension/AGENTS.md, extension/vscode/AGENTS.md`
- `tools: npm run compile, npm run test`
- `agent: Extension-Engineer`


