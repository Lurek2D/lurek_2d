---
name: create-extension-feature
description: End to end workflow to add new feature to extension for lurek, MS VS Code.
---

# GOAL
- Develop a new feature for the Lurek2D VS Code extension (e.g., language features, commands, panels).

# INPUTS REQUIRED
- Feature description (e.g., new autocomplete, custom webview panel)
= User must define the extension's functional requirement
- Agent must collect the extension's current API usage and generated stub definitions

# STEPS TO DO
1. Load skills: vscode-extension.
2. Edit `package.json` in the extension root to define new commands or keybindings.
3. Write the feature code (TypeScript/JS) in the extension `src/` directory.
4. Execute `npm run compile`. If it exits with code >0, fix the syntax errors.
5. Execute `npm run test` (or the extension's integration test suite). If tests pass rate is <100%, fix the broken logic and repeat step 4.

# OUTPUTS PROVIDED
- Modified VS Code extension source code
- Updated `package.json`
- Test results

# SUCCESS CRITERIA
- `npm run compile` exits with code 0 (0 compilation errors).
- `npm run test` exits with code 0 (100% tests pass).

# ANIT PATTERNS
- Breaking backwards compatibility with older Lurek2D projects.
- Ignoring standard VS Code UI/UX guidelines.

# REFERENCES
- skills: vscode-extension
- tools: npm run compile, npm run test
- agent: Extension-Engineer
