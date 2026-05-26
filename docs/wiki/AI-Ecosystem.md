# Lurek AI Ecosystem: Deep Dive

The Lurek AI Ecosystem is an end-to-end agentic workflow combining local AI models, VS Code editor tooling, headless CLI automation, and modular app distribution.

<p align="center">
  <img src="https://raw.githubusercontent.com/LurekDude/lurek_2d/main/assets/lurek-ai-ecosystem.svg"
       alt="Lurek AI Ecosystem vertical diagram" width="100%"/>
</p>

---

## 1. AI Models (The Brain)
Instead of forcing a single AI provider, Lurek's ecosystem is built on the Model Context Protocol (MCP) allowing you to seamlessly swap between **Local AI** and **Cloud AI**.

* **Local AI (Bielik AI, Ollama):** For entirely offline, private execution. Perfect when proprietary mechanics or NDA-protected game scripts cannot be shared, leaving your hardware untouched by the cloud.
* **Cloud AI (OpenAI, Anthropic):** Used for heavy lifting, complex logic refactoring, or initial fast prototyping when raw reasoning power is needed.
* **Example:** You use Ollama running locally. The agent queries your Lurek workspace and writes a pathfinding script using `lurek.pathfind` directly inside your files without pinging the internet.

## 2. MS VS Code (The Hub)
The **Lurek Extension** turns VS Code into an intelligent **MCP Server Host**. The **Workspace CAG** (Context-Aware Generation) defines what the agent knows how to do.

* **Lurek Extension:** Provides rich IntelliSense, Snippets, and Workspace Tasks.
* **Workspace CAG:** Contains carefully crafted Agents and Skills in the `.github/` folder, dictating the "Lurek Way" of building. It strictly limits what logic an agent applies.
* **Example:** You tell the Copilot chat: *"Fix my collision response"*. The agent loads the `physics-debugging` skill from the Workspace CAG and generates a proper `lurek.physics` callback structure. It doesn't guess APIs—it reads the exact workspace rules.

## 3. Lurek CLI — Headless Mode (The Bridge)
Agents cannot easily test graphical outputs, so the **Lurek CLI** acts as a programmatic bridge between the AI logic and the engine's compilation execution.

* **Headless Actions:** Allows the Agent to invoke the engine programmatically for `queries`, `assets`, `docs`, and `builds`.
* **Example:** An agent writes a new sprite batch module, then automatically runs `lurek.exe --headless tests/test_sprite_batch.lua`. The CLI captures the `stdout/stderr` output and sends it back to the agent so it can verify the fix _before_ presenting it to you.

## 4. Lurek 1-File Builds (The Runtime)
No messy dependencies or heavy IDE plugin folders. Lurek distributes logic using minimal, ready-made executables.

* **Lurek Game:** The standard build with full GPU rendering and Audio capabilities.
* **Lurek Data:** A pure headless build for processing heavy JSON/CSV pipelines.
* **Lurek Full:** Contains all edge/feature modules compiled maximally.
* **Example:** When development is done, the automated agent workflow packages the game into `lurek_game.exe` (under 5MB). The end user double-clicks the file and it immediately boots the runtime.

## 5. Lurek App & Mod / CAG Config (The Content)
Lurek adheres to the philosophy that **"Everything is a mod"**.

* **App Package:** A zipped `.lurek` archive containing base scripts, assets, and overarching data.
* **App Autonomy:** The core layer exposes APIs cleanly so any outside script can hook into it.
* **Mod / CAG Config:** Lua Playbooks and CAG Agents load dynamically. Rather than compiling logic into the core engine, behavior lives in Mod configuration files.
* **Example:** You have an App Package acting as a base "Fantasy RPG Engine". You then write a "Sci-Fi Mod Config" loaded via Lua Playbooks, completely overriding assets and behaviors without touching the compiled base App.

## 6. Use Cases & Templates (The Target)
The separation of App and Mod Config perfectly targets distinct domain verticals using predefined **Mod Templates**.

* **Education 4 Kids:** Loads the *Edu Mod template*. It simplifies the API, sets up a visual sandbox, and surfaces only kid-friendly error formatting.
* **Digital Twin:** Loads the *Twin Mod template*. Focuses on headless REST/MQTT pipelines and heavy mathematical data loops via `lurek.dataframe`.
* **Games / Demo Scena / Data Apps / Automation / Productivity:** Each template acts as a structured starting point containing pre-written Lua logic mapped precisely to the required Lurek Engine mode.
* **Example:** Creating an automated daily report generator? You boot the *Productivity Mod template*. The agent recognizes this and uses only UI, styling, and JSON formatting scripts—entirely skipping rendering/audio logic.

## 7. Lurek Engine (The Foundation)
Underneath all the AI tools, playbooks, and templates runs the highly optimized **Portable Powerhouse** Engine.

* **Rust + LuaJIT:** Blazing fast execution spanning 50+ engine modules (Physics, Graphics, Audio, Network).
* **Multi-modal:** Runs identically in GUI mode, Headless CLI, or DOS-style Text User Interface (TUI).
* **Memory Access:** Provides safe live Virtual Machine interaction via the DevBridge API.
* **Example:** The *Games Mod* tells the system to spawn 50,000 animated particles. The Lurek Engine intercepts this request, queues it on its internal multithreaded render pipeline, and dispatches native graphics instructions directly to the GPU using `wgpu` backend, keeping Lua logic fast.

## Related Pages

- [Getting Started](Getting-Started)
- [Runtime Model](Runtime-Model)
- [Modules](Modules)
- [Reference Games](Reference-Games)
