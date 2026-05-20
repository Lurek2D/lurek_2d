# AI Ecosystem

Lurek supports an agentic workflow that spans local AI models, VS Code tooling, the Headless CLI, the engine runtime, packaged apps, and ready-made 1-file builds.

The diagram below shows how all those pieces connect.

<p align="center">
  <img src="https://raw.githubusercontent.com/LurekDude/lurek_2d/main/assets/lurek-ai-ecosystem.svg"
       alt="Lurek AI Ecosystem diagram" width="100%"/>
</p>

## How It Works

| Block | Role |
|---|---|
| **AI Models** | Local (Bielik AI, Ollama) or cloud (OpenAI, Anthropic) models drive agent reasoning. |
| **MS VS Code** | Hosts the Lurek Extension (IntelliSense, tasks) and the Workspace CAG (agents, skills). Acts as MCP Server Host. |
| **Lurek CLI — Headless Mode** | Used by agents via the VS Code MCP Bridge to run headless queries, asset builds, doc generation, and CI tasks. |
| **Lurek 1-File Builds** | Ready-made single-binary distributions: `Lurek Game` (GPU + audio), `Lurek Data` (headless pipeline), `Lurek Full` (all modules). |
| **Lurek App** | An app package (`.lurek` archive) wrapping scripts, assets, and data. App-Level CAG lets every feature be a mod. |
| **Lurek Engine** | The Rust + LuaJIT core. Handles rendering, audio, physics, networking, and 50+ API modules across Win / Linux / Mac. |
| **Use Cases** | Education 4 Kids · Digital Twin · Games · Demo Scena · Data Apps · Automation · Productivity |

## Arrow Flow

```
AI Models ──► VS Code ──► CLI (Headless)
                │               │
                ▼               ▼
           1-File Builds ──► Lurek App ──► Use Cases
                                │
                                ▼
                          Lurek Engine
```

- **VS Code → Builds**: VS Code tasks trigger 1-file build compilation.
- **CLI → Engine**: The agent invokes the engine directly for headless runs and API queries.
- **Builds → App**: Build artifacts are packaged into the `.lurek` app format.
- **App → Use Cases**: Shipped apps serve the targeted use-case audiences.

## Related Pages

- [Getting Started](Getting-Started)
- [Runtime Model](Runtime-Model)
- [Modules](Modules)
- [Reference Games](Reference-Games)
