# Extension Feature Reference

## Navigation

[Home](Home) | [Modules](Modules) | [API](API) | [Examples](Examples) | [Reference Games](Reference-Games) | [Lureksome](Lureksome)

## Table of Contents

- [Language Intelligence (Providers)](#language-intelligence-providers)
- [Visual Editors (41 Panels)](#visual-editors-41-panels)
- [Commands by Category](#commands-by-category)
- [Services](#services)
- [MCP Server](#mcp-server)
- [Debug Adapter (DAP)](#debug-adapter-dap)
- [Game-Dev CAG Layer](#game-dev-cag-layer)
- [Configuration](#configuration)
- [Keybindings](#keybindings)

This is a feature reference for the **Lurek2D Toolkit** VS Code extension (`lurek2d-toolkit`). The extension complements [sumneko.lua](https://github.com/LuaLS/lua-language-server) — it focuses only on Lurek-unique features.

---

## Language Intelligence (Providers)

26 providers deliver Lurek-specific IntelliSense for `.lua` files.

| Provider | Description |
|----------|-------------|
| **Completion** | Context-aware completions for 4000+ `lurek.*` API items (functions, methods, types, constants) |
| **Hover** | Inline documentation with signatures, parameter types, return values, and links to wiki |
| **Diagnostics** | 13 Lurek-specific rules (see below) |
| **Definition** | Go-to-definition for `lurek.*` APIs → Rust source (`src/lua_api/`) |
| **InlayHints** | Parameter name and type hints for `lurek.*` calls |
| **CodeActions** | Quick-fix actions for diagnostic issues (add require, replace deprecated API, fix asset path) |
| **SemanticTokens** | Namespace/callback/deprecation coloring for `lurek.*` calls |
| **TypeInference** | Tracks factory return types (`Body`, `Image`, `Entity`, `Source`, etc.) for method completion |
| **RequireGraph** | Module dependency analysis, cycle detection, orphan detection |
| **CodeLens** | Callback markers, test detection, library references, demo links |
| **AssetPath** | File path completion inside asset-loading functions (`lurek.image.load`, `lurek.audio.newSource`) |
| **Color** | Color picker integration for `lurek.color.*` values and hex literals |
| **LuaJIT Hints** | LuaJIT-specific performance warnings (table alloc in hot path, string concat in loops) |
| **LuaCATS** | Integration with `@class`/`@field`/`@param` annotations from `docs/api/lurek.lua` |
| **Folding** | Custom folding regions for Lurek callbacks and scene blocks |
| **Formatting** | Deferred to StyLua/sumneko.lua; toggleable via `lurek.formatting.enabled` |
| **Signature** | Deferred to sumneko.lua |
| **Symbols** | Deferred to sumneko.lua |
| **References** | Deferred to sumneko.lua |
| **Rename** | Deferred to sumneko.lua |
| **PerfDashboard** | Live FPS/memory/draw-call webview panel (command: `lurek.perf.openDashboard`) |
| **SystemMonitor** | CPU/RAM/disk/network stats panel (command: `lurek.runtime.openMonitor`) |
| **DebugWatchers** | Live variable inspector during debug sessions (command: `lurek.debug.openWatchers`) |
| **ApiUsage** | API coverage report — which `lurek.*` functions your project uses (command: `lurek.api.usageReport`) |
| **AssetExplorer** | Tree view for game assets with insert-path and find-missing actions |
| **Sidebar** | 5 views: Project, Dev Tools, Editors, Assets, AI & Copilot |

### Diagnostic Rules (13)

| Rule | Detects |
|------|---------|
| `deprecated` | Calls to deprecated `lurek.*` functions |
| `colorRange` | Color values outside valid 0–1 or 0–255 range |
| `unusedRequire` | `require()` statements whose return value is never used |
| `assetNotFound` | Asset paths that don't resolve to a file in `assets/` |
| `threadSafety` | `lurek.*` calls unsafe to use from worker threads |
| `callbacks` | Misspelled or non-existent callback function names |
| `enumValues` | Invalid enum string arguments (blend modes, filter modes, etc.) |
| `unknownFunction` | Calls to non-existent `lurek.*` functions |
| `confLua` | Invalid or deprecated keys in `conf.lua` |
| `perFrameAllocation` | Table/closure allocations inside draw/process callbacks |
| `missingLoad` | Assets used before `lurek.load()` callback completes |
| `entityNilAccess` | Method calls on potentially nil entity references |
| `luajitHints` | LuaJIT-specific performance anti-patterns |

---

## Visual Editors (41 Panels)

All editors open as webview panels via `lurek.editor.*` commands.

### Level Design

| Editor | Command | Description |
|--------|---------|-------------|
| Tile Map | `lurek.editor.tileMap` | Visual tile placement with layer management |
| Tilemap Script | `lurek.editor.tilemapScript` | Script-driven tilemap generation editor |
| Tileset | `lurek.editor.tileset` | Tileset import, slicing, and collision shape editor |
| Procedural Map | `lurek.editor.procMap` | Procedural generation with live preview |
| World Map | `lurek.editor.worldMap` | Large-scale world map overview and zone linking |
| NavMesh | `lurek.editor.navMesh` | Navigation mesh editing for pathfinding |
| Province | `lurek.editor.province` | Province/region map editor for strategy games |

### Graphics

| Editor | Command | Description |
|--------|---------|-------------|
| Pixel Art | `lurek.editor.pixelArt` | In-editor pixel art drawing tool |
| Sprite Animation | `lurek.editor.spriteAnim` | Sprite sheet frame sequencing and preview |
| Color Palette | `lurek.editor.colorPalette` | Color palette creation and management |
| Shader Preview | `lurek.editor.shaderPreview` | Live WGSL shader editing with instant preview |
| Font Preview | `lurek.editor.fontPreview` | Bitmap and TTF font preview with glyph inspection |
| PostFX Overlay | `lurek.editor.postfxOverlay` | Post-processing effect chain designer |
| Lighting Environment | `lurek.editor.lightingEnvironment` | 2D lighting setup and shadow configuration |
| Visual Shader | `lurek.editor.visualShader` | Node-based shader graph editor |

### Audio

| Editor | Command | Description |
|--------|---------|-------------|
| Audio Mixer | `lurek.editor.audioMixer` | Channel mixing with volume, pan, and bus routing |
| Sound DSP | `lurek.editor.soundDsp` | DSP effect chain editor (reverb, delay, filter) |

### Game Design

| Editor | Command | Description |
|--------|---------|-------------|
| Entity | `lurek.editor.entity` | Entity component designer with live preview |
| Scene Flow | `lurek.editor.sceneFlow` | Visual scene transition graph |
| AI Behavior | `lurek.editor.aiBehavior` | Behavior tree / FSM editor |
| Animation State | `lurek.editor.spriteAnim` | Animation state machine connections |
| Quest Tree | `lurek.editor.questTree` | Quest dependency tree with condition nodes |
| Dialog | `lurek.editor.dialog` | Branching dialog tree editor |
| Timeline | `lurek.editor.timeline` | Cutscene timeline with tracks for actions/camera/audio |
| Database | `lurek.editor.database` | Game data browser (items, enemies, stats) |
| Particle | `lurek.editor.particle` | Particle system designer with live emitter preview |

### Physics

| Editor | Command | Description |
|--------|---------|-------------|
| Physics Materials | `lurek.editor.physicsMaterials` | Friction, restitution, and density presets |
| Voxel | `lurek.editor.voxel` | Voxel/height-map editor for terrain |

### UI

| Editor | Command | Description |
|--------|---------|-------------|
| GUI Widget | `lurek.editor.guiWidget` | TOML-based UI widget layout editor |
| GUI Theme | `lurek.editor.guiTheme` | Theme colors, fonts, and spacing presets |
| Localization | `lurek.editor.localization` | Translation string table management |
| Input Mapper | `lurek.editor.inputMapper` | Key/gamepad binding visual mapper |

### Infrastructure

| Editor | Command | Description |
|--------|---------|-------------|
| Test Runner | `lurek.editor.testRunner` | Visual test browser and result viewer |
| API Reference | `lurek.editor.apiReference` | Searchable API documentation browser |
| Performance Profiler | `lurek.editor.performanceProfiler` | Frame time flamegraph and allocation tracker |
| Asset Manifest | `lurek.editor.assetManifest` | Project asset inventory and validation |
| Project Export | `lurek.editor.projectExport` | Package configuration for distribution |
| Global Autoload | `lurek.editor.globalAutoload` | Global script load-order configuration |
| Network Topology | `lurek.editor.networkTopology` | Multiplayer network topology visualizer |
| Globe | `lurek.editor.globe` | 3D globe/map projection editor |
| Graph | `lurek.editor.graph` | Generic node-graph editor |
| Skeleton Rigging | `lurek.editor.skeletonRigging` | 2D skeletal animation bone/weight editor |

---

## Commands by Category

### Run & Stop (4)

| Command | ID | Keybinding |
|---------|----|------------|
| Run Game | `lurek.runGame` | `Alt+L` |
| Stop Game | `lurek.stopGame` | `Shift+Alt+L` |
| Run Game with Arguments | `lurek.runWithArgs` | — |
| Run Example | `lurek.runExample` | — |

### Build (4)

| Command | ID |
|---------|----|
| Build: Debug | `lurek.build.debug` |
| Build: Release | `lurek.build.release` |
| Build: Dist | `lurek.build.dist` |
| Build: Check (type-check only) | `lurek.build.check` |

### Run Profiles (4)

| Command | ID |
|---------|----|
| Run: Debug (no rebuild) | `lurek.run.debugNoRebuild` |
| Run: Release (no rebuild) | `lurek.run.releaseNoRebuild` |
| Run: Debug — pick demo | `lurek.run.debugPickDemo` |
| Run: Release — pick demo | `lurek.run.releasePickDemo` |

### Testing (8)

| Command | ID | Keybinding |
|---------|----|------------|
| Run All Tests | `lurek.test.all` | `Ctrl+Shift+T` |
| Run Lua Tests | `lurek.test.lua.all` | — |
| Run Golden Tests | `lurek.test.lua.golden` | — |
| Generate Tests for File | `lurek.test.generateForFile` | — |
| Run Rust Tests | `lurek.test.rust.all` | — |
| Run Parallel Cargo Tests | `lurek.test.rust.parallel` | — |
| Test: Math | `lurek.test.target.math` | — |
| Test: Physics / Graphics / Audio / Input | `lurek.test.target.*` | — |

### Scaffolding (7)

| Command | ID |
|---------|----|
| Create New Project | `lurek.scaffold.project` |
| Create New File | `lurek.scaffold.file` |
| Create New Mod from Template | `lurek.scaffold.mod` |
| Game Jam Quick Start | `lurek.gameJam.quickStart` |
| Add Game Jam Module | `lurek.gameJam.addModule` |
| Game Jam Quick Build | `lurek.jam.quickBuild` |
| Open Submission Checklist | `lurek.jam.checklist` |

### Packaging (7)

| Command | ID |
|---------|----|
| Package Zip | `lurek.package.zip` |
| Package for Windows | `lurek.package.windows` |
| Package for Linux | `lurek.package.linux` |
| Dist: Repackage (skip build) | `lurek.dist.repackage` |
| Dist: Install Windows | `lurek.dist.installWindows` |
| Open Game Jam Timer | `lurek.gameJam.timer` |
| Open Project Export Editor | `lurek.editor.projectExport` |

### Debug Bridge (10)

| Command | ID |
|---------|----|
| Debug Run and Connect | `lurek.debug.runAndConnect` |
| Debug Connect | `lurek.debug.connect` |
| Debug Disconnect | `lurek.debug.disconnect` |
| Debug Evaluate Lua | `lurek.debug.evaluate` |
| Open Watchers Panel | `lurek.debug.openWatchers` |
| Open Variable Inspector | `lurek.debug.openInspector` |
| Open Call Stack | `lurek.debug.openCallStack` |
| Open Live Performance | `lurek.debug.performance` |
| Take Debug Screenshot | `lurek.debug.screenshot` |
| Show Debug Status | `lurek.debug.status` |

### Editors (41)

All listed in [Visual Editors](#visual-editors-41-panels) above. Each opens via `lurek.editor.<name>`.

### Reference & Docs (8)

| Command | ID |
|---------|----|
| Browse API | `lurek.browseApi` |
| Open API Docs | `lurek.openApiDocs` |
| Open Wiki | `lurek.openWiki` |
| Open Dependency Graph | `lurek.depGraph` |
| Open Dependency List | `lurek.depList` |
| Run API Coverage | `lurek.apiCoverage` |
| Docs: Full Pipeline | `lurek.docs.fullPipeline` |
| Docs: Library API | `lurek.docs.libraryApi` |

### Quality & Audit (12)

| Command | ID |
|---------|----|
| Quality: Gate (full pre-push) | `lurek.quality.gate` |
| Quality: Clippy (strict) | `lurek.quality.clippy` |
| Quality: Format Apply | `lurek.quality.fmtApply` |
| Quality: Format Check | `lurek.quality.fmtCheck` |
| Audit: Quality Report | `lurek.audit.qualityReport` |
| Audit: Test Coverage | `lurek.audit.testCoverage` |
| Audit: Doc Coverage | `lurek.audit.docCoverage` |
| Audit: Example Coverage | `lurek.audit.exampleCoverage` |
| Audit: Lua API Test Coverage | `lurek.audit.luaTestCoverage` |
| Audit: Lua Spec Coverage | `lurek.audit.luaSpecCoverage` |
| Audit: CAG Link Check (strict) | `lurek.audit.cagLinkCheck` |
| Scan Lua Workspace for Errors | `lurek2d.scanAllGames` |

### Validate (6)

| Command | ID |
|---------|----|
| Validate: Lua API | `lurek.validate.luaApi` |
| Validate: Library | `lurek.validate.library` |
| Validate: Changelog | `lurek.validate.changelog` |
| Validate: Module Coverage | `lurek.validate.moduleCoverage` |
| Validate: Callbacks | `lurek.validate.callbacks` |
| Validate: CAG Files | `lurek.validate.cag` |

### Assets & Dependencies (7)

| Command | ID |
|---------|----|
| Refresh Assets | `lurek.assets.refresh` |
| Open Asset Explorer | `lurek.assets.openPanel` |
| Find Missing Assets | `lurek.assets.findMissing` |
| Insert Asset Path | `lurek.assets.insertPath` |
| Show Module Graph | `lurek.deps.showGraph` |
| Find Circular Dependencies | `lurek.deps.findCircular` |
| Show Orphan Modules | `lurek.deps.findOrphans` |

### Library & Patterns (3)

| Command | ID |
|---------|----|
| Browse Pattern Library | `lurek.library.browse` |
| Insert Pattern Library Snippet | `lurek.library.insertSnippet` |
| Save Selection as Pattern | `lurek.library.newPattern` |

### AI & CAG (5)

| Command | ID |
|---------|----|
| Install AI Config | `lurek.cag.install` |
| Select Agent | `lurek.cag.selectAgent` |
| Select Skill | `lurek.cag.selectSkill` |
| Select Prompt | `lurek.cag.selectPrompt` |
| Update AI Config Files | `lurek.cag.update` |

### MCP (2)

| Command | ID |
|---------|----|
| Install MCP Server | `lurek.mcp.install` |
| Show MCP Server Status | `lurek.mcp.status` |

### Performance & Monitoring (4)

| Command | ID |
|---------|----|
| Open Performance Dashboard | `lurek.perf.openDashboard` |
| Open System Monitor | `lurek.runtime.openMonitor` |
| Open Hot Reload History | `lurek.perf.openHotReload` |
| Clear Performance History | `lurek.perf.clearHistory` |

### UI Tools (2)

| Command | ID |
|---------|----|
| Snap TOML UI to Grid | `lurek.ui.snapToGrid` |
| Fix TOML UI Layouts | `lurek.ui.fixLayouts` |

---

## Services

9 internal services power the extension features.

| Service | File | Responsibility |
|---------|------|----------------|
| **ApiDataService** | `apiData.ts` | Loads `lurek-api.json` at activation; provides function/type lookup for all providers |
| **DebugBridge** | `debugBridge.ts` | TCP connection to a running Lurek2D game (port configurable, default 19740) |
| **LuaParser** | `luaParser.ts` | Parses Lua files for structure analysis: functions, requires, globals, callbacks |
| **LurekProcess** | `lurekProcess.ts` | Spawns and manages the engine process for run/debug workflows |
| **StatusBar** | `statusBar.ts` | VS Code status bar items: build status, game running indicator, debug state |
| **SymbolIndex** | `symbolIndex.ts` | Workspace-wide symbol indexing for cross-file navigation and reference search |
| **ParallelCargo** | `parallelCargo.ts` | Constructs and executes parallel cargo build commands |
| **RAG** | `rag.ts` | Retrieval-augmented generation index for AI agent knowledge base queries |
| **ApiDocs** | `apiDocs.ts` | API documentation search and lookup from generated reference files |

---

## MCP Server

The extension bundles a Model Context Protocol (MCP) server that AI agents can use to interact with the Lurek2D project. Install via `lurek.mcp.install`.

### Tools (10)

| Tool | Description |
|------|-------------|
| `lurek2d.runExample` | Build and run a named example, returning its output |
| `lurek2d.getApiDoc` | Search the Lua API documentation for a query string |
| `lurek2d.listExamples` | List all available example directories |
| `lurek2d.runLuaTest` | Run a Lua test file against a debug build |
| `lurek2d.checkBuild` | Run cargo check and return compiler diagnostics |
| `lurek2d.getLogs` | Return the last N lines of engine log output |
| `lurek2d.ragSearch` | Search the local RAG index for API examples, specs, and best practices |
| `lurek2d.ragBuildIndex` | Trigger an on-demand rebuild of the RAG index |
| `lurek2d.getModuleInfo` | Get metadata about an engine module (tier, files, dependencies, API surface) |
| `lurek2d.inspectLuaFile` | Parse a Lua file and return its structure (functions, requires, globals, callbacks) |
| `lurek2d.getTestCoverage` | Get test coverage summary, optionally filtered by module |
| `lurek2d.getProjectStructure` | Scan the workspace and return a categorized file tree |

---

## Debug Adapter (DAP)

The extension registers a `lurek` debug type for VS Code's built-in debugger.

### Launch Configuration

```jsonc
{
  "type": "lurek",
  "request": "launch",
  "name": "Lurek2D: Debug Game",
  "program": "${workspaceFolder}",
  "stopOnEntry": false,
  "luaVersion": "luajit",
  "debugPort": 8172,
  "args": []
}
```

### Attach Configuration

```jsonc
{
  "type": "lurek",
  "request": "attach",
  "name": "Lurek2D: Attach",
  "debugPort": 8172
}
```

### Capabilities

- **Breakpoints** — set in any `.lua` file
- **Call stack** — full Lua stack frames with source location
- **Variable inspection** — locals, upvalues, and globals
- **Evaluate** — run Lua expressions against the live game state
- **Port** — TCP port 8172 (configurable via `lurek.debugger.port`)

---

## Game-Dev CAG Layer

The extension ships a game-developer-focused CAG (Copilot Agent) layer that can be installed into any Lurek2D project via `lurek.cag.install`.

### Agents (11)

| Agent | Focus |
|-------|-------|
| `animator` | Sprite animations, state machines, frame timing |
| `audio-designer` | Sound effects, music, mixing, DSP chains |
| `game-architect` | Project structure, module design, scene organization |
| `game-tester` | Test strategy, coverage, edge cases |
| `gameplay-designer` | Mechanics, balance, progression systems |
| `level-designer` | Maps, spawns, triggers, environment layout |
| `lua-scripter` | Lua code patterns, lurek.* API usage |
| `narrative-writer` | Dialog, quests, story branching |
| `optimizer` | Performance profiling, memory, draw call reduction |
| `ui-designer` | HUD, menus, TOML layouts, themes |
| `visual-artist` | Pixel art, palette, VFX, shaders |

### Skills (26)

Organized by domain: `animation-state-machine`, `audio-manager`, `camera-system`, `collision-response`, `combat-system`, `crafting-system`, `debug-console`, `dialogue-system`, `event-bus`, `game-states`, `input-handling`, `inventory-system`, `leaderboard`, `object-pool`, `particle-juice`, `pathfinding-ai`, `platformer-movement`, `procedural-gen`, `quest-tracker`, `save-load`, `scene-management`, `tilemap-world`, `top-down-movement`, `tween-easing`, `ui-hud`, `weather-vfx`.

### Prompts (15)

| Prompt | Creates |
|--------|---------|
| `add-animation` | Sprite animation setup and state machine |
| `add-audio` | Sound playback, music manager, DSP |
| `add-dialog` | Branching dialog tree |
| `add-enemy` | Enemy entity with AI behavior |
| `add-level` | New level/map with spawn points |
| `add-localization` | i18n string table and language switching |
| `add-player` | Player entity with movement and input |
| `add-quest` | Quest definition with objectives |
| `add-save` | Save/load system with serialization |
| `add-ui` | HUD or menu screen |
| `game-jam-kickstart` | Full game scaffold for a jam theme |
| `new-game` | Complete project from scratch |
| `optimize-performance` | Performance audit and fixes |
| `post-mortem` | Game jam post-mortem template |
| `write-readme` | Project README with screenshots |

---

## Configuration

All settings live under the `lurek.*` namespace in VS Code settings.

| Setting | Default | Description |
|---------|---------|-------------|
| `lurek.lurekPath` | `""` | Path to lurek2d executable |
| `lurek.srcDir` | `""` | Game source subdirectory |
| `lurek.saveOnRun` | `true` | Save files before running |
| `lurek.luaVersion` | `"luajit"` | Lua runtime version for IntelliSense |
| `lurek.diagnostics.enabled` | `true` | Enable Lurek-specific diagnostics |
| `lurek.diagnostics.deprecationWarnings` | `true` | Show deprecated API warnings |
| `lurek.diagnostics.commonMistakes` | `true` | Detect common Lurek2D mistakes |
| `lurek.diagnostics.unusedRequires` | `true` | Flag unused require statements |
| `lurek.diagnostics.assetValidation` | `true` | Validate asset file paths |
| `lurek.inlayHints.enabled` | `true` | Show parameter hints inline |
| `lurek.inlayHints.parameterNames` | `true` | Show parameter name hints |
| `lurek.formatting.enabled` | `true` | Enable Lua code formatting |
| `lurek.intellisense.luaStdlib` | `true` | Include Lua stdlib in completions |
| `lurek.intellisense.luajitHints` | `true` | LuaJIT optimization hints |
| `lurek.intellisense.patternLibrary` | `true` | Offer pattern library snippets |
| `lurek.intellisense.keyNameCompletion` | `true` | Key name completions in input APIs |
| `lurek.intellisense.easingHoverChart` | `true` | Easing curve chart on hover |
| `lurek.intellisense.typeInference` | `true` | Factory return type tracking |
| `lurek.intellisense.globalWarnings` | `true` | Warn on implicit global writes |
| `lurek.intellisense.unusedAssets` | `false` | Detect unreferenced asset files |
| `lurek.intellisense.classPatternDetection` | `true` | Detect OOP class patterns |
| `lurek.debugBridge.port` | `19740` | Debug bridge TCP port |
| `lurek.debugBridge.autoConnect` | `true` | Auto-connect on debug run |
| `lurek.debugger.port` | `8172` | DAP TCP port |
| `lurek.test.testDir` | `"tests"` | Test directory path |
| `lurek.test.luaTestDir` | `"tests/lua"` | Lua test directory |
| `lurek.package.outputDir` | `"dist"` | Build output directory |
| `lurek.cag.installOnScaffold` | `true` | Auto-install AI config on scaffold |

---

## Keybindings

| Key | Command | When |
|-----|---------|------|
| `Alt+L` | Run Game | Editor focused, Lua file |
| `Shift+Alt+L` | Stop Game | Game running |
| `F2` | Open Wiki | Editor focused, Lua file |
| `Ctrl+Shift+T` | Run All Tests | Workspace open |

---

## Activation

The extension activates when:
- The workspace contains a `main.lua` file (`workspaceContains:**/main.lua`)
- The workspace contains a `Cargo.toml` file (`workspaceContains:Cargo.toml`)

## Requirements

- VS Code 1.90+
- Recommended: [sumneko.lua](https://marketplace.visualstudio.com/items?itemName=sumneko.lua) for base Lua language support
- Lurek2D engine binary (for run/debug features)
