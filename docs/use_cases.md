# Lurek2D — Use Case Catalogue

> **Audience:** Product, strategy, engine contributors, potential adopters.
> **Goal:** Document every realistic and aspirational use case for Lurek2D, including the build variant required, the specific module combination that enables it, competitive position, constraints, and complexity level.
> **Source ground truth:** `README.md`, `docs/lurek2d_positioning.md`, `docs/architecture/engine-architecture.md`, `Cargo.toml`, `src/agent/`, `ideas/`, `content/games/`, `content/examples/`, `library/`.

---

## 0. Engine Identity — What Makes Lurek2D Distinct

Before enumerating use cases it is important to understand the engine's core identity, because it shapes which use cases are realistic:

| Property | Constraint | Implication |
|----------|-----------|-------------|
| Single binary | Core binary ≤ ~10 MB stripped + UPX | Trivial deployment; no installer |
| Desktop-only | Windows / Linux / macOS; no mobile, no WASM | Rules out consumer mobile games |
| 2D only | No 3D scene graph | Correct scope for 2D-native problems |
| Lua scripting + Rust core | LuaJIT primary, Lua 5.4 CI fallback | Fast iteration + production-grade performance |
| AI-first | Local LLM integration via `lurek.agent.*` + Ollama | First-class LLM workflow, not an afterthought |
| Code-only | No visual editor; VS Code extension = DX layer | AI agents can use the full API without GUI |
| 5 000+ `lurek.*` functions | 70+ modules; 100% doc coverage enforced | High-coverage API reduces AI slop to near zero |
| MIT license | Zero royalties, no runtime fees | Safe for commercial, research, military, education |
| Headless + CLI + REPL | Can run without a window (`--headless`); REPL mode | Enables CI, scripting pipelines, batch jobs |
| ARM64 support | `lua54` feature flag for platforms where LuaJIT is unavailable | Raspberry Pi, Apple Silicon, ARM servers |

---

## Use Case Index

### Games — Classic & Genre

| # | Name | Status | Build variant |
|---|------|--------|---------------|
| UC-01 | Indie 2D Desktop Game | Current | `release` / `dist` |
| UC-02 | Game Jam / Rapid Prototype | Current | `dev` / `release` |
| UC-16 | Retro Arcade Clone / Education Game | Current | `dev` / `release` |
| UC-17 | Visual Novel / Interactive Fiction | Current | `release` |
| UC-18 | Sports & Physics Arcade | Current | `release` |
| UC-19 | Music Sequencer & Creative Tool | Current | `release` |
| UC-20 | Terminal / Hacking Game | Current | `release` |

### Education & Research

| # | Name | Status | Build variant |
|---|------|--------|---------------|
| UC-03 | Education — Programming & Architecture | Current | `dev` |
| UC-21 | Hackathon Teaching Platform | Current | `dev` |
| UC-15 | Teaching Instrument for AI/ML Research | Near-future | `release` headless |

### Simulation & Strategy

| # | Name | Status | Build variant |
|---|------|--------|---------------|
| UC-05 | Simulation Sandbox & Strategy Research | Current | `release` |
| UC-06 | Digital Twin Visualiser | Near-future | `release` headless + windowed |
| UC-12 | Wargame / Military Decision-Support Tool | Future | `dist` headless |
| UC-22 | Supply Chain & Logistics Optimiser | Near-future | `release` |

### Creative & Visual

| # | Name | Status | Build variant |
|---|------|--------|---------------|
| UC-04 | Demo Scene / Interactive Visual Art | Current | `release` |
| UC-23 | Network Graph Visualiser | Current | `release` |

### Data Science & Analytics

| # | Name | Status | Build variant |
|---|------|--------|---------------|
| UC-24 | Personal Finance & Budget Dashboard | Current | `release` |
| UC-25 | Stock & Market Data Dashboard | Near-future | `release` |
| UC-26 | Data Visualisation Studio | Current | `release` |
| UC-27 | Image Processing Workbench | Near-future | `release` |
| UC-08 | Headless Batch Compute & Data Pipeline | Current | `release --headless` |
| UC-28 | Data Integration Hub | Near-future | `release --headless` |

### Operations & Monitoring

| # | Name | Status | Build variant |
|---|------|--------|---------------|
| UC-29 | Infrastructure Monitoring Dashboard | Near-future | `release` |
| UC-30 | Log Analysis & Anomaly Detection | Near-future | `release --headless` |
| UC-31 | CI / Test Automation Harness | Current | `release --headless` |
| UC-39 | Headless Game Regression Framework | Current | `release --headless` |
| UC-42 | Data Quality Validator & Schema Checker | Near-future | `release --headless` |
| UC-45 | Linux Headless Daemon / Background Service | Current | `release --headless` |

### AI & LLM

| # | Name | Status | Build variant |
|---|------|--------|---------------|
| UC-07 | Local AI-Driven NPC / Game Logic | Current | `release` |
| UC-32 | LLM Inference Server with GUI | Near-future | `release` |
| UC-33 | Multi-Agent Game Design Tool | Near-future | `release` |
| UC-34 | Procedural Content Factory | Current | `release --headless` |
| UC-38 | Dialogue-Driven NPC System (Standalone / Library) | Current | `release` / library |
| UC-41 | AI Skill-Injection Chatbot (LAISystem) | Near-future | `release` |
| UC-47 | Agent `evalCode` Sandbox | Near-future | `release` |

### Platform & Tooling

| # | Name | Status | Build variant |
|---|------|--------|---------------|
| UC-09 | Internal Studio Tool / Level Editor | Near-future | `release` |
| UC-10 | Modding Platform / Scripted App Host | Current | `release` |
| UC-11 | Physical AI & Robotics Visualiser | Future | `dist` ARM64 |
| UC-13 | Audio / Video Processing Pipeline | Future | `dist` headless |
| UC-14 | ARM64 Edge Device Dashboard | Near-future | `lua54` ARM64 |
| UC-35 | DAG Workflow Orchestrator | Current | `release --headless` |
| UC-43 | Lurek2D as Lua Scripting Library | Current | `--headless` lib |
| UC-44 | Windows System Tray Application | Current | `dist` |
| UC-46 | Cross-Platform Configuration & Settings GUI | Current | `dist` / `release` |
| UC-49 | Multi-Platform Game Launcher & Updater | Near-future | `dist` / `release` |

### DSP & Audio Tools

| # | Name | Status | Build variant |
|---|------|--------|---------------|
| UC-36 | Offline DSP Audio Processing Pipeline | Current | `release --headless` |
| UC-37 | Audio Analysis & Fingerprinting Tool | Current | `release` |
| UC-48 | Real-Time Audio Spectrogram Visualiser | Current | `release` |

### Scientific & Compute

| # | Name | Status | Build variant |
|---|------|--------|---------------|
| UC-40 | Scientific Computing Workbench | Current | `release` |

---

## UC-01 — Indie 2D Desktop Game

### Description

A solo developer or small team builds a 2D desktop game in Lua and ships it on Steam, itch.io, or similar. Genres include puzzle, platformer, roguelike, deck-builder (Balatro-style), strategy map, dungeon crawler, rhythm game, idle/tycoon.

### Realistic Scale

- One person or two-person team.
- 6–24 months development.
- Steam price: $5–$15.
- Expected sales: 0–50 000 copies (99 % of games sell fewer than 1 000).

### Build Variant

| Target | Command | Output |
|--------|---------|--------|
| Windows (primary) | `cargo build --profile dist` + `dist.ps1` | `lurek2d.exe` stripped + UPX ≈ 8–9 MB |
| Linux | `bash tools/dist/dist.sh` → `tar.xz` / AppImage | portable folder |
| macOS | `bash tools/dist/dist.sh` | binary + folder |

Static CRT on Windows (`-C target-feature=+crt-static`) → zero runtime DLL requirements.

### Module Combination

**Core game loop:** `render` · `audio` · `physics` · `input` · `window` · `timer` · `scene` · `sprite` · `animation` · `tween` · `tilemap` · `ui` · `save` · `camera`

**Genre extras:**
- Roguelike: + `procgen` · `pathfind` · `ecs` · `minimap` · `patterns`
- Deck-builder: + `cardgame` (library) · `patterns` · `tween`
- Strategy map: + `province` · `globe` · `pathfind` · `dataframe`
- Rhythm: + `dsp` · `midi` · `timer`
- Idle/tycoon: + `economy` (library) · `dataframe` · `automation`

### Benefits

- Zero IDE ceremony; `main.lua` + assets is the full game.
- MIT license: no royalties.
- LuaJIT scripting: 2–5× faster than Love2D Lua 5.4.
- 5 000+ documented `lurek.*` functions reduce architecture decisions to function calls.
- AI copilot (GitHub Copilot / Antigravity) can generate correct code on first attempt because every function is documented and tested.

### Constraints

- Desktop only. No mobile, no console, no browser.
- No visual node editor — developer must be comfortable reading API docs or using VS Code IntelliSense.
- No built-in asset store or community plugin ecosystem (early project).
- FLAC and MP3 disabled by default (add `flac`/`mp3` features to re-enable).

### Competition

| Engine | Lurek advantage |
|--------|----------------|
| Love2D | Larger built-in API; AI-first tooling; single namespace |
| Godot 4 | No editor required; smaller binary; faster AI-assisted iteration |
| GameMaker 2 | MIT license; no subscription; code-only = AI-friendly |
| Unity 2D | Smaller binary; no DLL dependency; no royalties |
| Defold | Much larger API surface; VS Code IntelliSense built-in |

### Complexity Level

⭐⭐ (moderate) — main.lua + Lua is approachable in one afternoon; engine systems are pre-built.

---

## UC-02 — Game Jam / Rapid Prototype

### Description

A developer has 24–72 hours to build a playable game. Lurek2D provides a ready-to-run binary, 67+ working example scripts, Lua REPL for interactive testing, and VS Code IntelliSense.

### Build Variant

`dev` build for iteration speed; `release` for submission.

### Module Combination

Minimal: `render` · `input` · `timer` · `audio` (optional) · `ui` (optional).

Any example from `content/examples/` can be copied and modified as a jam starting point.

### Benefits

- `main.lua` is a valid game — empty file compiles and runs.
- All callbacks optional — add only what the game needs.
- REPL (`lurek2d --repl`) enables live Lua evaluation without restarting.
- 67 content examples cover every common pattern.
- AI-assisted workflow: describe the mechanic, get working Lua from the agent.

### Constraints

- Jam submissions requiring WebGL or mobile runner cannot use Lurek2D.
- No drag-and-drop layout builder.

### Competition

Love2D is the dominant jam engine for Lua developers. Lurek2D's advantage is richer built-in API (no need to `require` third-party libraries) and AI-assisted generation.

### Complexity Level

⭐ (low) — `main.lua` + examples library → playable prototype in hours.

---

## UC-03 — Education — Programming & Architecture

### Description

A university course or bootcamp teaches programming through game development. Instructors show: Lua as a scripting language; Rust as a systems language; engine architecture; test placement rules; API design; documentation standards.

The entire engine source is a teaching artefact: 5-tier module architecture, DAG dependency graph, test placement rules (TST-01 through TST-06), doc enforcement (Q-05), and the CAG agent system.

### Build Variant

`dev` — fastest recompile; full debug info.

### Module Combination

Students only touch `lurek.*` Lua API. Instructors optionally explore `src/` Rust modules, `tests/lua/`, `tests/rust/`, `docs/specs/`.

### Benefits

- Lua is approachable; Rust under the hood is "serious".
- The test framework teaches BDD and unit test placement from day one.
- CAG agent system teaches AI-assisted development as a discipline, not a hack.
- 100% documented API: students read docs, not source, to understand functions.
- MIT license: zero cost for institutions.

### Constraints

- Non-commercial use case; revenue impact is indirect (talent pipeline, reputation).
- Requires instructor preparation to teach both Lua and Rust side.

### Competition

| Alternative | Lurek advantage |
|-------------|----------------|
| Scratch / Pico-8 | Full professional toolchain; Rust internals visible |
| Love2D | Architecture, tests, docs, and AI workflow all present; larger API |
| Godot 4 | No editor magic; every behaviour is a code call; testable |
| Unity | No subscription; full source; smaller cognitive surface |

### Complexity Level

⭐⭐ (for students learning Lua) — ⭐⭐⭐⭐ (for instructors teaching Rust architecture).

---

## UC-04 — Demo Scene / Interactive Visual Art

### Description

A demo artist or creative coder builds a visually impressive interactive piece: generative art, particle systems, post-processing effects, raycaster scenes, procedural worlds, 2.5D environments, or music visualisers.

### Build Variant

`release` or `dist` for distribution.

### Module Combination

`render` · `effect` (postfx: bloom, blur, CRT, distortion, palette swap) · `particle` · `raycaster` · `procgen` · `light` · `camera` · `parallax` · `dsp` · `compute` · `math`

### Benefits

- `raycaster` module provides Wolfenstein/Doom-style 2.5D rendering out of the box.
- `procgen` covers noise, Voronoi, and L-systems for generative content.
- Post-FX stack (bloom, blur, CRT, distortion) is accessible via `lurek.effect.*`.
- GPU rendering via wgpu (Vulkan/DX12/Metal) → native performance on integrated GPUs.
- `compute` module enables CPU-side numerical computation for generative algorithms.

### Constraints

- No 3D scene graph.
- No video output (export to MP4/GIF is not built-in; requires external capture).

### Complexity Level

⭐⭐⭐ — visual effects are available but require understanding of render and effect APIs.

---

## UC-05 — Simulation Sandbox & Strategy Research

### Description

A researcher, analyst, or solo developer builds a systems-heavy simulation: economic models, province-level strategy (EU-style), demographic simulations, political models, supply chain simulators, or ecology games.

This is where Lurek2D differentiates from Love2D and Godot: the `province`, `globe`, `dataframe`, `graph`, `procgen`, `pathfind`, `flownet`, and `compute` modules exist specifically for this use case.

### Examples Already in Repo

- `content/games/simulation/province_economy_demo/` — province economy loop
- `content/games/strategy/eu2/` — EU-style strategy map
- `content/games/strategy/hex_strategy/` — hex grid strategy
- `content/games/strategy/wargame/` — wargame decision layer
- `ideas/IDEA.txt` — full digital twin / supply chain simulator design

### Build Variant

`release` — windowed for interactive exploration; `release --headless` for batch runs.

### Module Combination

**Core simulation:** `province` · `globe` · `dataframe` · `graph` · `pathfind` · `procgen` · `patterns` · `flownet` · `compute`

**Visualisation layer:** `render` · `minimap` · `camera` · `ui` · `charts` · `light`

**AI-driven agent layer:** `agent` · `ai` · `learning`

**Data in/out:** `serial` · `filesystem` · `network` · `save`

### Benefits

- `dataframe` provides SQL-like tabular queries — rare in a 2D game engine.
- `province` and `globe` are built-in modules with polygon maps and geographic data.
- `flownet` enables flow-network simulation (supply chains, electricity grids, logistics).
- `pathfind` (A\*, HPA\*) handles agent movement across maps.
- `graph` provides traversal algorithms for dependency trees and event chains.
- Lua scripting makes model rules readable and modifiable without recompiling.
- `agent` module connects to local Ollama LLM for AI-driven agents inside the simulation.

### Constraints

- Not a GIS system; geographic precision is simulation-grade, not cartography-grade.
- No SQL database backend (dataframe is in-memory).
- Single-machine compute only; no distributed simulation.

### Competition

| Tool | Lurek advantage |
|------|----------------|
| Python + Pygame | Faster rendering; typed MPMC channels for parallel agents; LuaJIT speed |
| AnyLogic | Free and open source; code-only; Lua is faster to prototype |
| NetLogo | Much richer rendering; GPU acceleration; Lua scripting |
| Unreal/CityEngine | Desktop-only is fine; 1/100th of the setup cost |

### Complexity Level

⭐⭐⭐ — simulation logic is pure Lua; visualisation requires render API knowledge.

---

## UC-06 — Digital Twin Visualiser

### Description

An engineering or operations team builds a visual representation of a real-world system: a factory floor, a logistics network, a data centre, or a city infrastructure layer. The visualiser receives real-time data (via HTTP, WebSocket, or CSV) and renders the current state of the physical system.

This is the most commercially interesting non-game use case. Lurek2D's `globe`, `province`, `flownet`, `dataframe`, `network`, `agent`, and `render` modules compose naturally for this.

### Full Design (from `ideas/IDEA.txt`)

The repo already contains a detailed design for a digital twin simulator with:
- Globe layer: world map with polygon regions, cities, and site markers
- Site layer: 2D grid of facilities with capacity, services, and process pipelines
- Craft layer: vehicles moving between sites along pathfind routes
- Process / Pipeline / Trigger system: event-driven task scheduling
- Operator model: workers and robots with skills
- Asset model: items, data, and global resources
- Technology tree: unlock new facility types and processes
- Market, Build, Hire mechanics
- Anomaly events and monitoring statistics

### Build Variant

`release` windowed for operator UI; `release --headless` for data-only backend mode.

### Module Combination

`globe` · `province` · `flownet` · `pathfind` · `dataframe` · `network` (WebSocket / HTTP) · `agent` (LLM-driven anomaly detection) · `render` · `ui` · `charts` · `minimap` · `timer` · `save` · `serial` · `automation`

### Benefits

- Single binary deployment to operator workstation — no Docker, no Python runtime.
- Real-time data ingestion via `lurek.network.*` (HTTP + WebSocket).
- LLM-driven anomaly detection via `lurek.agent.*` + local Ollama.
- Lua scripts define the domain model — the operations team can modify rules without Rust knowledge.
- `dataframe` enables live KPI aggregation in-process.
- MIT license — usable in internal enterprise tools without licensing audits.

### Constraints

- Not a web dashboard — requires the desktop runtime on every operator machine.
- Real-time data volume is limited by single-machine LuaJIT throughput.
- No built-in connector to industrial protocols (OPC-UA, MQTT) — requires HTTP/WebSocket bridge.

### Competition

| Tool | Lurek advantage |
|------|----------------|
| Grafana / Kibana | Native 2D interactive visualisation; not just charts; Lua-customisable |
| Unity Reflect | MIT license; no SLA; smaller runtime; code-only |
| Unreal Digital Twins | 200× smaller; no 3D needed; Lua accessible |
| Custom web app | Single binary; offline-capable; GPU-accelerated rendering |

### Complexity Level

⭐⭐⭐⭐ — requires network integration, domain model design, and LLM agent configuration.

---

## UC-07 — Local AI-Driven NPC / Game Logic

### Description

A game uses `lurek.agent.*` to run local LLM inference (via Ollama) for NPC dialogue, procedural quest generation, dynamic difficulty adjustment, or in-game AI companions that respond to player context.

The `lurek.agent.*` module is a native Rust HTTP client for the Ollama API with:
- Background thread dispatch (non-blocking from Lua's perspective)
- `AgentManager` for parallel multi-agent runs
- System prompt + skills + instructions prompt builder
- JSON / CSV / tabular forced output format
- Retry with exponential back-off

### Build Variant

`release` — requires local Ollama instance on the player's machine.

### Module Combination

`agent` · `ai` (FSM/BT for game AI state) · `learning` · `patterns` · `event` · `thread` (worker VMs for background processing) · `dataframe` (agent context/memory storage) · `save` (persistent agent memory)

### Benefits

- Fully local — no API keys, no cloud dependency, no privacy concerns.
- Non-blocking: LLM response arrives asynchronously; game loop never stalls.
- `AgentManager` runs multiple agents in parallel (e.g., narrator + enemy AI + advisor).
- Prompt builder separates system persona, domain skills, and per-frame instructions.
- Agent output can be JSON-structured for reliable parsing.

### Constraints

- Requires Ollama installed on the end-user machine — non-trivial for consumer games.
- LLM inference latency (0.5–5 s per response) is acceptable for dialogue but not for real-time combat AI.
- Local model quality depends on what the player has downloaded (7B vs 70B models).

### Competition

No other 2D game engine ships a native local LLM client as a first-class built-in module. This is a unique differentiator.

### Complexity Level

⭐⭐⭐ — agent configuration is straightforward; integrating responses into game logic requires design.

---

## UC-08 — Headless Batch Compute & Data Pipeline

### Description

Lurek2D runs without a window (`--headless` mode) to execute Lua scripts that process data, run simulations, generate content, or perform analysis. The runtime provides: `dataframe`, `compute`, `procgen`, `graph`, `serial`, `filesystem`, `network`, `thread`, and `agent` — all without a GPU or display.

Use cases:
- Generate 10 000 procedural dungeon maps and save them as JSON.
- Run Monte Carlo simulations of an economy model and output CSV results.
- Batch-process game replay logs with `dataframe` queries.
- Call a local LLM agent to classify or annotate content.
- Run CI tests in headless mode (already used by the test harness).

### Build Variant

`release --headless` or `dist` for server/CI deployment.
On ARM64 server: `--features lua54 --no-default-features` (LuaJIT not available on all ARM targets).

### Module Combination

`compute` · `dataframe` · `procgen` · `graph` · `patterns` · `serial` · `filesystem` · `network` · `thread` · `agent` · `math` · `log`

GPU modules (`render`, `audio`, `physics`) are disabled in headless mode.

### Benefits

- Trivial deployment: copy one binary + Lua scripts to any server.
- LuaJIT makes batch Lua scripts run at C-comparable speed.
- `dataframe` provides pandas-like in-memory data processing without Python.
- `thread` enables parallel worker VMs for embarrassingly parallel jobs.
- `agent` connects to local Ollama for LLM-augmented pipelines.
- Existing test harness (`tests/lua/harness.rs`) demonstrates the headless pattern.

### Constraints

- No GPU acceleration for compute (compute module is CPU-only).
- Not a distributed compute framework — single machine only.
- No native columnar file format (Parquet/Arrow); use CSV or JSON.

### Competition

| Tool | Lurek advantage |
|------|----------------|
| Python + pandas | LuaJIT speed; single binary; native LLM client |
| Node.js | Strongly typed engine; no npm dependency hell |
| Rust binary (custom) | Lua scripting = no recompile for logic changes |
| Deno | Lua is simpler; binary is smaller; no V8 overhead |

### Complexity Level

⭐⭐ — Lua scripting is approachable; headless mode requires only CLI invocation.

---

## UC-09 — Internal Studio Tool / Level Editor

### Description

A game studio uses Lurek2D to build internal tools: a level editor for their own game, a balance spreadsheet with live visualisation, an animation preview tool, or a narrative graph editor.

The tool runs on developer machines; the `ui`, `tilemap`, `render`, `filesystem`, `dialog`, `devtools`, and `overlay` modules provide the GUI layer.

### Build Variant

`release` — internal distribution via shared drive or simple installer.

### Module Combination

`ui` · `tilemap` · `render` · `filesystem` · `dialog` · `devtools` · `overlay` · `camera` · `input` · `serial` · `save` · `automation`

### Benefits

- Build a custom tool in Lua in days, not weeks.
- `tilemap` has TMX (Tiled) format support out of the box.
- `filesystem` and `dialog` provide file open/save panels.
- `automation` enables scripted test sequences for the tool itself.
- MIT license — no licensing questions from legal.

### Constraints

- Requires engine maturity — internal tool use requires stable API surface.
- No widget theming system (all rendering is programmatic).
- Not a general-purpose GUI framework (desktop-application-grade widget library is not planned).

### Complexity Level

⭐⭐⭐ — UI module is large; building a usable editor requires significant design effort.

---

## UC-10 — Modding Platform / Scripted App Host

### Description

A game built on Lurek2D exposes modding via `lurek.mods.*`. Players write Lua scripts that add content, modify rules, or create new game modes. The host game enforces the sandbox; the mod system loads and executes trusted scripts.

Alternatively: Lurek2D acts as a Lua application host. A company ships a business tool where the core UI and data logic is Lua, allowing rapid updates without redeployment of the binary.

### Build Variant

`release` — the host binary is distributed; mods are plain `.lua` files.

### Module Combination

`mods` · `filesystem` (sandboxed GameFS) · `event` · `patterns` · `serial` · `save` · `lua_api` (full public surface available to mod scripts)

### Benefits

- Lua mods require no compilation — players can write and share them instantly.
- `GameFS` sandbox prevents path traversal — mod scripts cannot escape the game directory.
- `lurek.mods.*` provides manifest loading, sandboxed VM execution, and version checking.
- Pure-Lua `library/` modules (`economy`, `crafting`, `inventory`, etc.) can be included in mods.

### Constraints

- Mod scripts run in the same LuaJIT VM as the game (no additional sandboxing beyond GameFS).
- No mod marketplace or update mechanism built in.

### Complexity Level

⭐⭐⭐ — exposing a clean mod API requires disciplined game design.

---

## UC-11 — Physical AI & Robotics Visualiser (ARM64 Edge)

### Description

A research or engineering team runs Lurek2D on an ARM64 device (Raspberry Pi 5, NVIDIA Jetson, Apple Silicon server) to visualise the state of a physical AI system in real time. The runtime consumes sensor data over HTTP/WebSocket, runs a local Ollama model (quantised 7B) for decision narration, and renders a live 2D map of the physical environment.

Physical AI examples:
- A robot navigating a warehouse floor — rendered as a 2D top-down map.
- A drone swarm position tracker — rendered as a 2D globe with agent trails.
- A CNC machine monitoring dashboard — facility grid + process pipeline view.

### Build Variant

`--features lua54 --no-default-features` → ARM64-compatible binary (LuaJIT unavailable on some ARM targets).

```toml
[target.aarch64-unknown-linux-gnu]
rustflags = ["-C", "target-cpu=native"]
```

For Raspberry Pi: cross-compile from Linux x86_64 using `cross` with the `aarch64-unknown-linux-gnu` target.

### Module Combination

`network` · `agent` · `dataframe` · `render` · `globe` · `pathfind` · `minimap` · `ui` · `timer` · `thread` · `serial` · `automation`

### Benefits

- Runs on ARM64 edge hardware without a desktop GPU (wgpu supports software rendering fallback).
- `lua54` feature drops the LuaJIT requirement — works on ARM where LuaJIT is unsupported.
- Local Ollama on Jetson (via CUDA) provides on-device LLM inference.
- `network` module provides WebSocket ingestion of sensor streams.
- Single binary — no Python, no Docker, no heavy ML runtime on the edge device.

### Constraints

- `lua54` is significantly slower than LuaJIT for compute-intensive Lua logic.
- wgpu on ARM requires Vulkan driver — not available on all ARM devices (Raspberry Pi 4/5 need additional setup).
- LLM inference on Raspberry Pi is slow without hardware acceleration.
- This is a future/aspirational use case — ARM64 CI is not yet configured.

### Dependencies Needed

- Vulkan driver for the target ARM device.
- Ollama ARM64 build (available for Apple Silicon and Jetson; experimental on Pi).
- Cross-compilation toolchain for aarch64.

### Competition

No direct 2D-engine competitor targets this use case. Python + OpenCV is the dominant choice; Lurek2D's advantage is the single-binary deployment model and the native LLM client.

### Complexity Level

⭐⭐⭐⭐⭐ — requires cross-compilation, Vulkan setup on ARM, and LLM configuration.

---

## UC-12 — Wargame / Military Decision-Support Tool

### Description

A defence organisation, think tank, or academic group builds a scenario modelling tool: a map-based wargame where analysts test courses of action, model resource allocation, or run red team/blue team exercises. The visualisation is 2D (strategic map level); the logic is Lua-scripted.

The `ideas/simulation/` folder already contains detailed designs for this pattern (ANALYTICS-GUIDE.md, ANOMALY-MECHANICS.md, DOMAIN-BLUEPRINTS.md).

### Build Variant

`dist` — air-gapped deployment possible (no cloud dependencies); headless mode for automated scenario runs.

### Module Combination

`province` · `globe` · `pathfind` · `dataframe` · `graph` · `patterns` · `agent` (local LLM for decision narration) · `flownet` · `render` · `minimap` · `ui` · `save` · `serial` · `automation` (scripted scenario replay)

### Benefits

- MIT license — no SLA, no vendor lock-in for government procurement.
- Air-gap compatible: local Ollama + Lurek2D binary + Lua scripts = zero internet dependency.
- Lua scripts define scenario rules — analysts can modify without programmer involvement.
- `automation` module enables scripted replay of historical scenarios.
- `agent` module provides LLM-assisted after-action review.
- Single binary — runs on analyst laptop, no infrastructure.

### Constraints

- Not a real GIS system — province/globe data is game-grade.
- No integration with classified data systems out of the box.
- No multi-player network layer for distributed wargaming (requires `network` + custom protocol).

### Complexity Level

⭐⭐⭐⭐ — domain model is complex; requires significant scenario design effort.

---

## UC-13 — Audio / Video Processing Pipeline

### Description

Lurek2D's `audio`, `dsp`, `midi`, `compute`, and `thread` modules combine into a headless audio processing pipeline. A music tool, game replay analyser, or educational audio DSP tool is built entirely in Lua.

Examples:
- Generate procedural music from a Lua grammar and export WAV.
- Analyse game replay audio for balance issues (e.g. SFX overload detection).
- Build an interactive music visualiser with FFT spectrum display.
- Run a batch audio normalisation job across 500 sound files.

**Note:** Video decoding/encoding is not currently a built-in capability. Video processing would require piping frame data through `compute` and `image` modules — possible but not ergonomic today.

### Build Variant

`release` (windowed for interactive visualiser) or `release --headless` (batch processing).

### Module Combination

`audio` · `dsp` · `midi` · `compute` · `thread` · `filesystem` · `serial` · `math` · `timer` + `render` · `charts` (for visualiser mode)

### Benefits

- `dsp` module provides DSP primitives (filters, FFT, envelope) usable from Lua.
- `midi` module parses MIDI files for procedural music systems.
- `rodio` backend (OGG + WAV) handles decode and playback.
- `thread` enables parallel audio processing across worker VMs.
- Headless mode removes the window requirement for batch jobs.

### Constraints

- No video decode/encode pipeline (future capability).
- No real-time audio plugin (VST/AU) format support.
- `rodio` supports WAV and OGG only by default (FLAC/MP3 are feature-flagged).
- DSP pipeline is CPU-only — no GPU audio compute.

### Competition

Python (librosa, pydub) is the dominant choice; Lurek2D's advantage is the single-binary model and LuaJIT speed.

### Complexity Level

⭐⭐⭐ — DSP API exists but requires audio domain knowledge.

---

## UC-14 — ARM64 Edge Device Dashboard

### Description

A field technician or site manager runs a Lurek2D dashboard on a portable ARM64 device (Raspberry Pi, industrial tablet, Jetson Nano). The dashboard displays live sensor readings, process status, or logistics state without cloud connectivity.

This is a simpler version of UC-11 (no LLM requirement) focused purely on the visualisation and data ingestion.

### Build Variant

`--features lua54` ARM64 cross-compile. Headless data mode + windowed display mode in the same binary.

### Module Combination

`network` (HTTP/WebSocket data ingestion) · `dataframe` · `ui` · `charts` · `render` · `timer` · `serial` · `save` · `filesystem`

### Benefits

- Single binary on the device — no Node.js, no Python, no heavy web stack.
- `lua54` works on ARM where LuaJIT is unavailable.
- `network` handles REST polling or WebSocket streams.
- `dataframe` aggregates and queries sensor data in-process.
- `save` persists state between power cycles.
- `charts` renders bar, line, and scatter plots natively.

### Constraints

- Requires Vulkan driver on the ARM device for GPU rendering.
- `lua54` performance may be insufficient for high-frequency data (>10 kHz).
- ARM64 is not yet a first-class CI target.

### Complexity Level

⭐⭐⭐ — data ingestion is straightforward; UI layout requires design effort.

---

## UC-15 — Teaching Instrument for AI/ML Research

### Description

An AI researcher uses Lurek2D as a fast-iteration environment for:
- Training environment for RL agents (headless simulation + Lua reward function).
- Multi-agent scenario (multiple `lurek.agent.*` VMs communicating via `Channel`).
- Visualiser for ML model outputs (e.g., render a policy heatmap on a `province` map).
- LLM evaluation harness: run 1 000 prompts through a local Ollama model and collect structured responses in `dataframe`.

### Build Variant

`release --headless` for training/evaluation; `release` windowed for visualisation.

### Module Combination

`agent` · `thread` · `dataframe` · `learning` · `compute` · `patterns` · `serial` · `automation` · `render` · `charts` · `province` · `globe`

### Benefits

- `lurek.learning.*` provides ML primitives (neural network layers, training loop helpers) accessible from Lua.
- `agent` module provides a production-ready Ollama client with AgentManager for batch evaluation.
- `thread` enables parallel scenario workers — each worker VM runs an independent agent.
- `automation` scripted test sequences = repeatable experiment protocols.
- Headless mode removes GPU requirement for pure compute experiments.
- MIT license — results can be published without IP concerns.

### Constraints

- `learning` module is not a full ML framework (not PyTorch).
- No GPU-accelerated tensor compute — all ML is CPU-only.
- Suitable for small-scale research, not production training of large models.

### Competition

Python (Gymnasium, PyTorch) is the standard. Lurek2D's advantage: single binary, Lua is fast to prototype, and the `agent` + `dataframe` combination makes LLM evaluation pipelines trivial to set up.

### Complexity Level

⭐⭐⭐⭐ — requires understanding of both the simulation domain and ML fundamentals.

---

---

## UC-16 — Retro Arcade Clone / Education Game

### Description

A developer rebuilds a classic arcade game (Pong, Tetris, Pac-Man, Space Invaders, Asteroids, Boulder Dash, Donkey Kong, Galaga, Snake) as a teaching exercise or portfolio piece, or creates an original 2D game inspired by the classics.

The repo includes reference implementations in `content/games/arcade/` (11 titles) and `content/games/retro/` (12 titles including raycaster FPS, Lemmings, and Sensible Soccer). These serve as starting points and teaching artefacts.

### Build Variant

`dev` for learning; `release` for distribution; `dist` for shipping.

### Module Combination

**Minimal arcade:** `render` · `input` · `timer` · `physics` (optional)

**Richer games:** + `audio` · `particle` · `tween` · `scene` · `ui`

**Retro raycaster:** + `raycaster` · `tilemap` · `effect` (CRT post-FX)

### Benefits

- 23 reference implementations already in the repo — clone, study, modify.
- Physics-based games (Pong, Breakout, pinball) use `rapier2d` without manual collision math.
- CRT post-FX (scanlines, bloom, vignette) via `effect` module for authentic retro look.
- `i18n` module for multi-language releases.
- Perfect first project: small scope, well-defined behaviour, no external data dependencies.

### Constraints

- Desktop only — no mobile arcade feel.
- Multiplayer requires `network` module; local co-op is input-only.

### Competition

Pico-8 and TIC-80 are popular for retro games but have artificial constraints (128×128, limited colours). Lurek2D has no such limits and ships modern rendering.

### Complexity Level

⭐ — Pong in 100 lines. ⭐⭐⭐ — full Pac-Man with AI ghosts and tilemap.

---

## UC-17 — Visual Novel / Interactive Fiction

### Description

A writer or small studio builds a dialogue-driven game: visual novel, courtroom drama, social deduction game, or narrative adventure. The repo includes reference implementations in `content/games/rpg/` (visual_novel, courtroom, dialog_demo, social_deduction, adventure).

The `library/dialog` and `library/narrative` Lureksome modules provide pre-built conversation graph and story state management.

### Build Variant

`release` / `dist`.

### Module Combination

`render` · `ui` · `audio` · `tween` · `save` · `input` · `scene` · `i18n` + `dialog` (library) · `narrative` (library) + `agent` (optional: LLM-generated dialogue)

### Benefits

- `library/dialog` provides conversation graph, branching choices, and state tracking out of the box.
- `library/narrative` handles story flags, chapter progression, and conditional scenes.
- `lurek.html.*` renders rich HTML+CSS dialogue boxes and UI screens (demonstrated in `showcase/html-dialog`, `showcase/html-settings`, `showcase/html-inventory`).
- `agent` module enables dynamic LLM dialogue — characters respond to player history.
- `tween` handles smooth sprite slide-in, text fade, and background transitions.
- `i18n` supports localisation of all dialogue text from a single string table.
- `audio` provides voice line playback and ambient soundtrack with named bus control.

### Constraints

- No built-in visual novel authoring GUI (Ren'Py style) — all logic is Lua code.
- LLM dialogue requires Ollama on the player's machine.

### Competition

| Tool | Lurek advantage |
|------|----------------|
| Ren'Py | Full code control; Rust performance; LLM-ready |
| Godot | Smaller binary; no editor needed; MIT |
| TyranoBuilder | Free; code-first; testable |

### Complexity Level

⭐⭐ — basic branching dialogue. ⭐⭐⭐⭐ — LLM-driven responsive characters.

---

## UC-18 — Sports & Physics Arcade

### Description

Physics-heavy sports or arcade games: golf, pinball, billiards, bowling, drift racing, ski jump, trajectory-based sports, boxing, tennis. The repo includes `content/games/sports/` (12 titles).

The `rapier2d` physics backend handles rigid bodies, joints, and collision detection; the Lua API wraps this cleanly via `lurek.physics.*`.

### Build Variant

`release` / `dist`.

### Module Combination

`physics` · `render` · `input` · `audio` · `camera` · `tween` · `particle` · `ui` · `save` (high scores)

### Benefits

- `rapier2d` with `parallel` feature — physics solver uses Rayon for multi-core stepping.
- Joints (revolute, prismatic, spring) enable pinball flippers, car suspensions, ragdolls.
- `lurek.physics.raycast()` enables line-of-sight checks and golf club aim assist.
- Vehicle physics: wheel joints + torque application → drift racing out of the box.
- `particle` module adds visual feedback: sparks, smoke, ball trails.

### Constraints

- 2D physics only — no 3D rigid body simulation.
- Multiplayer requires `network` module.

### Complexity Level

⭐⭐ — simple projectile. ⭐⭐⭐⭐ — pinball machine with multi-ball and tilt detection.

---

## UC-19 — Music Sequencer & Creative Tool

### Description

An interactive creative application built with Lurek2D: a piano roll sequencer, a step sequencer, a generative music tool, or a music visualiser. The repo includes `content/games/showcase/music_composer/` as a working reference (32-beat × 24-note grid with BPM control, preset patterns, and per-track mute).

### Build Variant

`release`.

### Module Combination

`audio` · `dsp` · `midi` · `render` · `input` · `tween` · `particle` · `timer` · `serial` (project save/load)

### Benefits

- `lurek.dsp.*` provides filters, envelope generators, and FFT for visualiser mode.
- `lurek.midi.*` parses MIDI files for import into the sequencer.
- `rodio` backend plays notes via PCM synthesis or sample playback.
- `tween` animates the playback cursor and note highlights.
- `particle` adds sparkle on note placement and beat pulse.
- Fully offline — no cloud sync, no subscription.

### Constraints

- No MIDI export (playback-only; export requires custom file writing via `filesystem`).
- Sample quality depends on bundled audio files.
- Not a DAW — no VST plugin hosting.

### Complexity Level

⭐⭐⭐ — step sequencer. ⭐⭐⭐⭐ — real-time generative music with DSP.

---

## UC-20 — Terminal / Hacking Game

### Description

A CLI-aesthetic game rendered as a text terminal inside the Lurek2D window: hacking simulators, command-line puzzles, retro-terminal adventures, or cyberpunk narrative games. The repo includes `content/games/showcase/hacking_game/` — a full hacking game with CRT aesthetics, matrix-rain title screen, animated boot sequence, password cracking, and file download missions.

### Build Variant

`release` / `dist`.

### Module Combination

`terminal` · `render` · `input` · `tween` · `particle` · `timer` · `event` · `effect` (CRT post-FX)

### Benefits

- `lurek.terminal.*` provides an 80×25 character grid with coloured text, scrollback, and command parsing.
- CRT scanline + vignette + flicker via `effect` post-FX creates authentic terminal aesthetics.
- `particle` adds matrix-rain, download sparkle, and trace alert pulse.
- `tween` animates boot sequence and cursor blink.
- The game logic is entirely Lua — no engine changes needed for new missions.

### Constraints

- Text rendering is grid-based; proportional fonts require `render.drawText()` instead.
- No true VT100/ANSI terminal emulation.

### Complexity Level

⭐⭐ — basic text-input game. ⭐⭐⭐⭐ — full hacking sim with network topology.

---

## UC-21 — Hackathon Teaching Platform

### Description

A hackathon organiser or bootcamp uses Lurek2D as the common platform for all participants. Each team gets the binary + docs + examples; they compete by extending a common `main.lua` template. The platform provides: working physics, audio, UI, and save system from day one — teams focus on creative design, not engine plumbing.

Compared to UC-02 (personal jam), this is an organised multi-team event with a shared starting point and a judging framework.

### Build Variant

`dev` during the event; `release` for submissions.

### Module Combination

Template provided by organiser; teams may add any `lurek.*` module.

### Benefits

- Single binary distributed to all participants — zero install friction.
- VS Code extension provides IntelliSense for all `lurek.*` functions — no documentation hunting.
- AI copilot (Antigravity + CAG system) helps participants generate correct code fast.
- REPL mode enables live Lua evaluation for quick experiments.
- 67 examples cover every common pattern — teams copy and modify.
- `automation` module enables scripted test cases for judging.

### Constraints

- Teams must know Lua or be willing to learn in 24–48 hours.
- Windows is the primary supported platform for events; Linux/macOS possible but requires build setup.

### Complexity Level

⭐ (entry) — ⭐⭐⭐ (winning entries use advanced modules).

---

## UC-22 — Supply Chain & Logistics Optimiser

### Description

An operations researcher or logistics analyst builds a visual supply chain model: factories, warehouses, transport routes, and demand nodes. The `flownet` and `graph` modules model material flow; `pathfind` routes vehicles; `dataframe` aggregates KPIs; `agent` runs LLM-driven scenario analysis.

This is a specialised sub-case of UC-05 focused on the `flownet` module's supply/demand/conversion/queue system.

### Build Variant

`release` windowed for interactive modelling; `release --headless` for batch scenario runs.

### Module Combination

`flownet` · `graph` · `pathfind` · `dataframe` · `agent` · `render` · `ui` · `charts` · `minimap` · `serial` · `save` · `automation`

### Key `flownet` Capabilities Used

- `LGraphNode:addSupply` / `addDemand` — model mines, factories, consumers.
- `LGraphNode:setConversion` — smelter converts 2 iron_ore → 1 iron_bar.
- `LGraphNode:setFlowMode` — push vs pull routing logic.
- `LGraphNode:setQueueEnabled` — buffer nodes with capacity limits.
- `LGraph:tickParallel` — Rayon-backed parallel simulation step.
- `LGraph:sendItem` — route cargo along edges.
- `LGraph:on("itemEnter", ...)` — event callback when cargo arrives.

### Benefits

- Flow network model maps directly to real supply chains.
- Parallel simulation tick (`tickParallel`) enables large networks without lag.
- `dataframe` aggregates throughput, bottleneck, and on-time-delivery KPIs.
- `agent` generates natural-language scenario summaries and what-if analysis.
- Lua rules = domain experts can modify logic without Rust knowledge.

### Constraints

- Flow simulation is discrete-event, not continuous differential equations.
- No geospatial coordinate system — positions are logical, not GPS.
- No built-in optimisation solver (LP/MIP) — heuristic only via Lua.

### Complexity Level

⭐⭐⭐ — basic flow model. ⭐⭐⭐⭐⭐ — full multi-echelon supply chain with LLM analysis.

---

## UC-23 — Network Graph Visualiser

### Description

A developer or researcher builds an interactive visualisation of a graph: network topology, social network, dependency tree, knowledge graph, or financial flow diagram. Nodes and edges are rendered as 2D objects; `graph` module provides traversal, cycle detection, MST, and colouring algorithms.

### Build Variant

`release`.

### Module Combination

`graph` · `render` · `input` · `camera` (pan/zoom) · `ui` · `dataframe` · `serial` · `math` · `tween` (animated layout transitions)

### Key `graph` Capabilities

- `g:findPath()`, `g:astar()` — highlight shortest paths interactively.
- `g:mst()` — visualise minimum spanning tree.
- `g:colorGraph()` — colour-code node groups.
- `g:getComponents()` — highlight connected components.
- `g:topologicalSort()` — visualise dependency order.
- `g:hasCycle()` — detect cycles in dependency graphs.

### Benefits

- GPU-accelerated rendering → smooth pan/zoom on graphs with thousands of nodes.
- `camera` module provides pixel-perfect zoom and smooth follow.
- `tween` animates node positions during force-directed layout updates.
- Export via `serial.toJson()` for use in other tools.

### Constraints

- No built-in force-directed layout algorithm — must implement in Lua.
- Large graphs (>10 000 nodes) may hit rendering performance limits.

### Complexity Level

⭐⭐⭐ — static visualiser. ⭐⭐⭐⭐ — interactive real-time layout with algorithm animation.

---

## UC-24 — Personal Finance & Budget Dashboard

### Description

A desktop application for personal finance management: budget tracking, expense categorisation, multi-year trend analysis, anomaly detection, and KPI dashboards. The repo includes a working reference implementation: `content/games/apps/household_finance_lab/` — a complete 5-person household finance dashboard with:

- Deterministic CSV generation (5 years, 2021–2025, multiple transaction types)
- In-memory SQL database (`LDatabase`) with parameterised queries from external `.sql` files
- `LDataFrame` operations: z-score, outlier detection, rolling mean/sum, % change, runway months
- Database caching via `LDatabase:save` / `lurek.dataframe.loadDatabase`
- TOML-driven UI layout (`content/layouts/`) with tabs, sliders, combo boxes, tables
- SQL debounce filter — sliders don't query on every micro-movement

### Build Variant

`release` / `dist` — runs on the user's desktop machine.

### Module Combination

`dataframe` · `ui` · `charts` · `render` · `serial` · `save` · `filesystem` · `timer` · `math` · `window`

### Benefits

- `dataframe` provides SQL-like in-memory queries without a database server.
- `LDatabase` supports parameterised SQL stored in external files — clean separation of data and logic.
- Rolling statistics (rolling mean, z-score, outlier detection) are built-in operations.
- `LGuiTable` renders data directly from a DataFrame — no manual row rendering.
- TOML UI layouts (`content/layouts/`) separate UI structure from Lua logic.
- Single binary — no Python, no Electron, no Node.js.
- Fully offline — financial data never leaves the machine.

### Constraints

- In-memory only — no persistent database server (SQLite-style persistence requires manual save/load).
- No charting library for SVG/PDF export (renders to texture only).
- No CSV import wizard — parsing is Lua-scripted.

### Competition

| Tool | Lurek advantage |
|------|----------------|
| Excel / Google Sheets | Single binary; programmable in Lua; offline; no subscription |
| Tableau / PowerBI | Free; MIT; code-first; no cloud required |
| Python + pandas | Single binary; GPU-accelerated charts; no Python install |
| YNAB | Fully local; no recurring fee; Lua-customisable |

### Complexity Level

⭐⭐⭐ — basic budget tracker. ⭐⭐⭐⭐⭐ — full multi-year analytics with SQL and anomaly detection.

---

## UC-25 — Stock & Market Data Dashboard

### Description

A trader or analyst builds a real-time stock tracking dashboard: candlestick charts, technical indicators (SMA, EMA, RSI, Bollinger Bands), portfolio performance, watchlists, and price alerts. Data arrives via HTTP polling or WebSocket from a market data API (or a local mock).

The `content/games/apps/README.md` explicitly documents "Stock Market Dashboard" as a target application.

### Build Variant

`release`.

### Module Combination

`network` (HTTP/WebSocket) · `dataframe` · `charts` · `render` · `ui` · `timer` · `serial` · `save` (watchlists, alerts) · `agent` (optional: LLM market commentary)

### Benefits

- `lurek.network.*` polls REST APIs or streams WebSocket tick data.
- `dataframe` computes rolling indicators (SMA, EMA, RSI) in-process.
- `charts` renders candlestick, bar, and line charts natively.
- `agent` can summarise daily market moves in natural language via local LLM.
- `save` persists watchlists and alert thresholds between sessions.

### Constraints

- No direct broker API integration — requires HTTP bridge to market data.
- Tick rate limited by LuaJIT thread throughput (sufficient for 1 s candles, not HFT).
- No backtesting framework — historical analysis requires custom Lua.

### Complexity Level

⭐⭐⭐ — price display. ⭐⭐⭐⭐⭐ — full technical analysis dashboard with LLM commentary.

---

## UC-26 — Data Visualisation Studio

### Description

An analyst or scientist builds an interactive data exploration tool: upload CSV/JSON, select chart type (bar, line, scatter, pie, heatmap), apply filters, zoom/pan, export. The `content/games/apps/README.md` documents "Data Visualization Studio" as a target application.

### Build Variant

`release`.

### Module Combination

`dataframe` · `charts` · `render` · `ui` · `camera` · `input` · `serial` · `filesystem` · `dialog` (file picker) · `image` (export)

### Benefits

- `dataframe.fromCSVFileAsync` loads large CSV files asynchronously — UI stays responsive.
- SQL-like queries filter and aggregate data before plotting.
- `charts` renders multiple chart types with GPU acceleration.
- `camera` enables zoom/pan on large charts.
- `dialog` provides a native file picker for CSV/JSON import.
- Single binary — share the tool as one executable.

### Constraints

- No 3D chart types.
- PNG-only export (JPEG requires enabling the feature flag).
- Chart types limited to those implemented in `charts` module.

### Complexity Level

⭐⭐⭐ — fixed chart from CSV. ⭐⭐⭐⭐ — interactive filter/explore UI.

---

## UC-27 — Image Processing Workbench

### Description

An artist or developer builds a CPU-side image processing tool: apply filters (blur, sharpen, colour correction, edge detection), layer blending, pixel-level manipulation, batch processing across hundreds of files. The `content/games/apps/README.md` documents "Image Processing Workbench" as a target application.

### Build Variant

`release` (interactive) or `release --headless` (batch processing).

### Module Combination

`image` · `render` · `ui` · `input` · `filesystem` · `dialog` · `serial` · `thread` (parallel batch) · `compute` (filter kernels)

### Key `image` Capabilities

- `lurek.image.*` provides CPU-side pixel operations, texture atlases, and DDS format support.
- `render.newCanvas()` enables off-screen GPU compositing.
- Custom WGSL shaders via `render.newShader()` for GPU-accelerated filters.

### Benefits

- GPU-accelerated filter preview via canvas + custom shaders.
- `thread` enables parallel batch processing across worker VMs.
- `filesystem` handles directory traversal for batch jobs.
- Single binary — no ImageMagick, no Python PIL install.

### Constraints

- No SVG/vector format support.
- No RAW camera format decode.
- CPU filter pipeline is simpler than GPU compute shaders.

### Complexity Level

⭐⭐⭐ — basic filter application. ⭐⭐⭐⭐ — GPU-accelerated batch pipeline.

---

## UC-28 — Data Integration Hub

### Description

A developer builds a lightweight data integration tool in Lua: poll multiple REST APIs, normalise the responses with `dataframe`, apply transformation rules, and push results to another endpoint or write to CSV/JSON. This is an ETL (Extract-Transform-Load) tool implemented as a headless Lua script.

Example pipelines:
- Pull weather API → normalise → append to `dataframe` → write CSV daily.
- Poll internal microservice health endpoints → aggregate → push summary to Slack webhook.
- Merge two CSV exports from different tools → deduplicate → write unified report.

### Build Variant

`release --headless` — runs as a scheduled task or cron job.

### Module Combination

`network` · `dataframe` · `serial` · `filesystem` · `thread` · `timer` · `log` · `automation`

### Benefits

- Zero-dependency deployment — one binary + one Lua script.
- `network` handles REST polling, basic auth, and JSON parsing.
- `dataframe` provides SQL-like joins, groupby, and column transforms.
- `thread` enables parallel API polling across worker VMs.
- `automation` enables scripted test scenarios for the pipeline logic.
- `serial.toJson` / `fromJson` handles API response parsing.

### Constraints

- No streaming protocol support (Kafka, AMQP) — HTTP/WebSocket only.
- No built-in schema validation (use `lurek.validator.*` for basic checks).
- In-memory only — no persistent database.

### Complexity Level

⭐⭐ — simple poll-and-write. ⭐⭐⭐⭐ — multi-source ETL with parallel fetch and transformation.

---

## UC-29 — Infrastructure Monitoring Dashboard

### Description

An operations team builds a live infrastructure monitoring dashboard: server health, CPU/memory/disk metrics, network latency, service uptime. Data arrives via HTTP polling of a metrics API (Prometheus, Datadog, or custom). The dashboard renders status grids, sparkline charts, and alert panels.

### Build Variant

`release` — runs on a NOC workstation or wall display.

### Module Combination

`network` · `dataframe` · `charts` · `ui` · `render` · `timer` · `serial` · `save` (alert thresholds) · `agent` (LLM anomaly narration) · `overlay` (alert popups)

### Benefits

- `timer` drives periodic metric polling without blocking the UI.
- `dataframe` aggregates time-series data and detects threshold violations.
- `charts` renders sparklines and status bars with GPU acceleration.
- `overlay` module shows alert banners over the main view.
- `agent` narrates anomalies: "CPU spike on server-03 started 14:32, correlates with deploy #447".
- Single binary — runs on any Windows/Linux NOC workstation.

### Constraints

- No native Prometheus scrape protocol — requires HTTP/REST adapter.
- No alert routing (PagerDuty, OpsGenie) built in — add via `network` POST.
- Data retention is in-memory only.

### Competition

| Tool | Lurek advantage |
|------|----------------|
| Grafana | Desktop-native; single binary; LLM narration; Lua-customisable |
| Datadog | Free; no agent required; offline-capable |
| Custom web app | No browser dependency; GPU rendering; LuaJIT speed |

### Complexity Level

⭐⭐⭐ — basic status grid. ⭐⭐⭐⭐ — full anomaly detection with LLM narration.

---

## UC-30 — Log Analysis & Anomaly Detection

### Description

A developer or SRE uses Lurek2D in headless mode to parse, filter, and analyse application logs: find error patterns, detect latency spikes, aggregate by time bucket, and generate a summary report. The `agent` module sends anomalous log windows to a local LLM for natural-language root cause hypotheses.

Workflow:
1. Read log files from `filesystem`.
2. Parse with `grep` module (regex search) or `serial.fromJson`.
3. Load into `dataframe` for aggregation and anomaly scoring.
4. Send anomalous rows to `agent` for LLM analysis.
5. Write report to JSON/CSV via `serial`.

### Build Variant

`release --headless` — runs as a cron job or CI step.

### Module Combination

`grep` · `filesystem` · `dataframe` · `serial` · `agent` · `log` · `thread` · `timer`

### Benefits

- `grep` module enables regex search across log files from Lua.
- `dataframe` aggregates log entries by time bucket, severity, and source.
- Rolling z-score flags anomalous error rate spikes.
- `agent` generates root cause hypotheses in plain English from log windows.
- `thread` enables parallel log file processing.
- Single binary — no ELK stack, no Python install.

### Constraints

- No persistent index (re-reads files each run — suitable for daily batch, not live tail).
- Regex via `grep` module; complex parser logic requires Lua string patterns.
- LLM context window limits how much log text can be sent to the agent.

### Complexity Level

⭐⭐ — simple error count. ⭐⭐⭐⭐ — anomaly detection + LLM root cause analysis.

---

## UC-31 — CI / Test Automation Harness

### Description

Lurek2D already ships a headless Lua test harness (`tests/lua/harness.rs`) used by its own CI. The same pattern can be adopted by external projects: run Lua scripts headlessly to test game logic, simulate player input, validate save/load round-trips, or benchmark frame time.

The `automation` module (`lurek.automation.*`) records and replays input sequences — enabling regression tests that verify pixel-accurate game behaviour.

### Build Variant

`release --headless` for pure logic tests; `release` windowed for screenshot-based regression tests.

### Module Combination

`automation` · `serial` · `filesystem` · `timer` · `log` · `dataframe` (test result aggregation) + all modules under test

### Key `automation` Capabilities (from `showcase/automation_demo`)

- Full input recording: keystrokes, mouse clicks, mouse movement with timestamps.
- Faithful playback with adjustable speed (0.5×, 1×, 2×).
- Built-in auto-test sequences for repeatable geometric patterns.
- Event timeline with per-event markers.

### Benefits

- Headless mode removes GPU requirement for logic tests.
- `automation` replay enables "record once, test forever" patterns.
- `timer.getFPS()` in tests detects performance regressions.
- Test results written to JSON/CSV via `serial` for CI report parsing.
- The engine's own quality gates (TST-01 through TST-06) demonstrate the pattern.

### Constraints

- Screenshot regression tests require a display or virtual framebuffer.
- No built-in diff of rendered frames — requires external image comparison.

### Complexity Level

⭐⭐ — headless logic tests. ⭐⭐⭐⭐ — screenshot regression with input replay.

---

## UC-32 — LLM Inference Server with GUI

### Description

A developer builds a local LLM front-end application: a chat interface, a prompt testing tool, or a structured prompt builder. Lurek2D renders the UI; `lurek.agent.*` manages Ollama lifecycle (start, stop, pull models, list models) and dispatches prompts.

This is the Lurek2D equivalent of an Ollama GUI client — built in ~200 lines of Lua.

### Build Variant

`release`.

### Module Combination

`agent` · `ui` · `render` · `input` · `terminal` · `serial` · `save` (conversation history) · `filesystem`

### Key `agent` Capabilities for This Use Case

- `lurek.agent.newOllama()` — manage the local Ollama process.
- `ollama:isRunning()`, `ollama:listModels()`, `ollama:pullModel()`, `ollama:start()` / `stop()`.
- `agent:promptBatch()` — run multiple prompts in parallel.
- `LAISystem` — multi-agent system with shared skills and instructions.
- `agent:setFormat("json")` — enforce structured output.
- `agent:evalCode()` — execute LLM-generated Lua code in a sandboxed VM.

### Benefits

- Manage the full Ollama lifecycle from Lua — no shell scripts needed.
- `terminal` module renders a scrollable chat window with monospace text.
- `agent:evalCode()` enables "AI writes code, engine runs it" workflows.
- `AgentManager:runAll()` enables parallel multi-model comparison.
- Single binary — distribute the LLM GUI as one executable.

### Constraints

- Requires Ollama installed on the same machine.
- Streaming response (token-by-token) is not yet supported — full response arrives at once.
- Context window management is manual (not automatic sliding window).

### Complexity Level

⭐⭐ — basic chat UI. ⭐⭐⭐⭐ — multi-agent system with model comparison and code execution.

---

## UC-33 — Multi-Agent Game Design Tool

### Description

A game designer uses Lurek2D as a local AI-assisted game design workbench: multiple LLM agents collaborate on game design tasks — one writes lore, another designs mechanics, a third reviews for consistency. The `LAISystem` orchestrates the agent roster; the UI displays agent outputs and lets the designer provide feedback.

This is a direct application of the `LAISystem` + `AgentManager` pattern from `content/examples/agent.lua`.

### Build Variant

`release`.

### Module Combination

`agent` · `ui` · `render` · `input` · `terminal` · `dataframe` (agent output storage) · `save` · `serial`

### Key Patterns

- `lurek.agent.newSystem()` with multiple agents: `writer`, `designer`, `reviewer`.
- `system:addSkill()` with keyword triggers — auto-inject domain rules into prompts.
- `system:addInstruction()` — shared constraints (art style, tone, target platform).
- `system:runAll()` — dispatch all agents in parallel, collect results.
- `system:buildContext()` — preview the full prompt before sending.

### Benefits

- All LLM inference is local — no API cost, no privacy risk for proprietary game ideas.
- `AgentManager` runs writer + designer + reviewer simultaneously in parallel threads.
- `dataframe` stores and queries design output for consistency checking.
- `save` persists the full agent session for later continuation.
- The prompt builder (system prompt + skills + instructions) maps directly to professional prompt engineering.

### Constraints

- Requires Ollama + at least one capable model (≥7B parameters recommended).
- Multi-agent coherence is a Lua design problem — agents do not share a context window.
- No visual design canvas — text output only.

### Complexity Level

⭐⭐⭐ — two-agent collaboration. ⭐⭐⭐⭐⭐ — full multi-agent system with skill injection and review loop.

---

## UC-34 — Procedural Content Factory

### Description

A game studio or solo developer runs Lurek2D headlessly to generate large volumes of game content: dungeon maps, quest texts, item descriptions, NPC backstories, planet names, quest chains, or dialogue trees. The output is JSON/CSV consumed by the main game.

This pattern separates content generation (offline, headless, LLM-assisted) from the game runtime (real-time, windowed).

Examples:
- Generate 10 000 dungeon layouts with `procgen` and save as JSON.
- Batch-generate NPC backstories via `agent:promptBatch()` with 50 parallel requests.
- Create a dialogue tree for 500 NPCs using `LAISystem` with writer + consistency-checker agents.
- Generate a planet name database with `procgen.grammar()` rules.

### Build Variant

`release --headless` — runs as a build step in the game's asset pipeline.

### Module Combination

`procgen` · `agent` · `thread` · `dataframe` · `serial` · `filesystem` · `patterns` · `math` · `log`

### Benefits

- `procgen` (noise, Voronoi, L-systems, grammars) generates structured content deterministically.
- `agent:promptBatch()` sends 50 parallel LLM requests — generates 50 descriptions simultaneously.
- `AgentManager:runAll()` orchestrates multi-step pipelines (generate → review → format).
- `thread` enables parallel content generation across worker VMs.
- `dataframe` validates and deduplicates generated content before export.
- Output is JSON/CSV — consumed by any game engine, not just Lurek2D.
- MIT license — generated content is fully owned by the developer.

### Constraints

- LLM batch speed depends on Ollama model size and hardware.
- Deterministic generation (`procgen`) is fast; LLM generation is slow (0.5–5 s per item).
- No content quality gate built in — validation logic is Lua-scripted.

### Complexity Level

⭐⭐ — `procgen` map batch. ⭐⭐⭐⭐ — full LLM-assisted content pipeline with multi-agent review.

---

---

## UC-35 — DAG Workflow Orchestrator

### Description

A developer or data engineer uses Lurek2D headlessly as a general-purpose task orchestration engine: define a pipeline of named steps with explicit dependency edges, retry logic, conditional branching, and timeout enforcement. The `pipeline` module provides a production-grade DAG scheduler with topological sort, parallel-tier detection, and sub-pipeline composition.

Example pipelines:
- Asset build pipeline: `fetch_assets → validate → compress → upload`. Parallel compression of independent assets.
- Data processing: `load_csv → [clean, validate] → aggregate → report`. Validation and cleaning run concurrently.
- Game boot sequence: `load_config → [load_audio, load_tileset] → init_world → start`.

### Build Variant

`release --headless` for CI pipelines; `release` windowed for interactive progress display.

### Module Combination

`pipeline` · `serial` · `filesystem` · `log` · `timer` · `thread` · `dataframe` (result aggregation) · `render` + `ui` (optional: progress UI)

### Key `pipeline` Capabilities Used

- `lurek.pipeline.fromTable` — declare the entire DAG as a Lua table (name, deps, delay, retryCount, retryDelay, async, optional, fn).
- `LPipeline:getParallelGroups()` — inspect which steps can run concurrently.
- `LPipeline:runAsync()` + `update(dt)` — non-blocking async execution that yields between frames.
- `LPipeline:addBranch(pred, then_fn, else_fn)` — conditional execution inside the DAG.
- `LPipeline:addSubPipeline(sub, alias, outer_deps)` — embed reusable sub-pipelines under a namespace prefix.
- `LPipeline:toAscii()` — render the dependency graph as ASCII art for debugging.
- `LPipeline:setOnStepComplete` / `setOnStepError` — step-level event callbacks.
- Step-level `setTimeout`, `setRetryCount`, `setOptional` — fine-grained fault tolerance.

### Benefits

- Full DAG with cycle detection and Kahn topological sort — no silent ordering bugs.
- Parallel-tier scheduling: independent steps run concurrently, cutting total time.
- Retry + backoff per step: transient failures (network, disk) are handled automatically.
- `optional` steps: non-critical steps don’t abort the whole pipeline.
- Sub-pipeline composition: reuse workflows across projects with namespace isolation.
- Single binary — no Airflow, no Celery, no Docker.
- LuaJIT speed: orchestrating 10 000 steps per second is routine.

### As a Library

Lurek2D can be compiled as a Rust library crate. The `pipeline` module can be embedded into another Rust project, driven by its own Lua scripts, using the engine headlessly as a workflow scheduler component.

### Constraints

- All step functions are Lua callbacks — CPU-bound heavy work must be dispatched to `thread` workers.
- No distributed execution — single-machine only.
- No persistent pipeline state across binary restarts (re-run from scratch).

### Complexity Level

⭐⭐ — linear 3-step pipeline. ⭐⭐⭐⭐ — complex DAG with branching, sub-pipelines, and retry.

---

## UC-36 — Offline DSP Audio Processing Pipeline

### Description

A sound designer, podcast producer, or game audio engineer uses Lurek2D headlessly to batch-process audio files: apply effect chains (lowpass, reverb, compressor, normalise), convert formats, and generate visualisations (waveform PNG, spectrogram PNG). The `dsp` module handles all signal processing without a DAW.

Example workflows:
- Normalise 500 game sound effects to −23 dBFS and save.
- Apply lowpass + reverb chain to all `sfx/indoor/*.wav`.
- Generate waveform overview PNGs for all voice lines (for a DAW-style editor preview).
- Batch-convert 44.1 kHz stereo to 22 kHz mono for mobile-quality export.

### Build Variant

`release --headless` — runs as a build step in the game’s asset pipeline.

### Module Combination

`dsp` · `audio` · `filesystem` · `thread` (parallel batch) · `pipeline` (DAG ordering) · `serial` · `log`

### Key `dsp` Capabilities Used

- `lurek.dsp.processOffline(input, effects, output)` — apply an effect chain to a WAV file.
- `lurek.dsp.normalize(input, target_level, output)` — peak-normalise a file.
- `lurek.dsp.waveformToPng(wav, png, width, height)` — render waveform overview image.
- `lurek.dsp.spectrogramToPng(wav, png, width, height)` — render Hann-windowed spectrogram heatmap.
- `lurek.dsp.newEffectParams(type, p1, p2, p3)` — declare an effect for offline processing.
- Effect types: `lowpass`, `highpass`, `reverb`, `delay`, `chorus`, `compressor`, `limiter`, `distortion`, `bitcrush`.

### Benefits

- `processOffline` is file-to-file: no playback thread, no GPU, no window.
- `thread` runs parallel processing across 8+ files simultaneously.
- `pipeline` ensures correct ordering: normalise before reverb, reverb before visualise.
- `waveformToPng` and `spectrogramToPng` generate editor-quality preview images headlessly.
- Single binary — no SoX, no FFmpeg, no Python librosa.
- MIT — integrate into any game build system.

### Constraints

- WAV input/output only (PCM 16-bit). MP3/OGG require pre-conversion.
- No pitch shifting or time-stretching built in.
- CPU-only DSP — not real-time GPU processing.

### Complexity Level

⭐⭐ — single-file normalise. ⭐⭐⭐⭐ — full DAG pipeline with parallel batch, effect chains, and PNG output.

---

## UC-37 — Audio Analysis & Fingerprinting Tool

### Description

A developer or music researcher builds a desktop tool to analyse audio files: measure RMS and peak levels, detect clipping, generate frequency spectra (FFT), perform cross-correlation to find repeated patterns, and export analysis results as CSV/JSON. The `dsp` and `compute` modules handle all analysis; the `charts` module renders the results.

### Build Variant

`release` windowed for interactive analysis; `release --headless` for batch analysis.

### Module Combination

`dsp` · `compute` · `audio` · `charts` · `render` · `ui` · `filesystem` · `dialog` · `serial` · `dataframe`

### Key API Combinations

- `lurek.dsp.analyzeRms(sound)` / `analyzePeak(sound)` / `analyzeFft(sound, bins)` — per-buffer level detection.
- `lurek.dsp.newLevelDetector()` + `detector:process(sound)` — incremental level accumulation.
- `lurek.dsp.newSpectrumAnalyzer(bins)` + `analyzer:analyze(sound)` — frequency bin output.
- `lurek.compute.fftMagnitude(samples)` — raw FFT from a sample array.
- `lurek.compute.correlate1d(signal, template)` — sliding cross-correlation for pattern search.
- `lurek.compute.pearsonCorr(a, b)` — similarity score between two frequency profiles.
- `dataframe` aggregates per-file results; `charts` renders spectrum bar charts.

### Benefits

- `LLevelDetector` provides sample-accurate RMS, peak, and clipping detection.
- FFT + `correlate1d` enables basic audio fingerprinting (find duplicate sound effects).
- `spectrogramToPng` renders publication-quality heatmaps for research output.
- `dialog` provides native file-picker for WAV import.
- Single binary — no Python librosa, no MATLAB, no Audacity plugin.

### Constraints

- WAV input only (no MP3/OGG decode built in).
- No commercial-grade fingerprinting database (Shazam-style) — local comparison only.
- FFT window size limited to powers of 2 (radix-2 implementation).

### Complexity Level

⭐⭐ — simple RMS display. ⭐⭐⭐⭐ — full spectrum analyser with cross-correlation fingerprinting.

---

## UC-38 — Dialogue-Driven NPC System (Standalone / Library)

### Description

A game developer integrates Lurek2D’s `dialog` module as a dialogue engine for NPCs: weighted topic selection, gated branches (FSM state, behaviour-tree status, utility scores), speaker registry, per-conversation variable tracking, and mid-conversation save/restore.

The `dialog` module was designed to be used both inside a Lurek2D game and as an **embedded library** — another Rust project can link against the Lurek2D crate and drive `DialogueAI` directly from Rust.

### Build Variant

`release` (windowed game) · `release --headless` (server-side NPC logic) · **library crate** (embedded in another engine).

### Module Combination

`dialog` · `ai` (FSM + behaviour tree state as gate context) · `agent` (LLM fallback for unmatched topics) · `save` (mid-conversation checkpoint) · `serial` · `audio` (voice line trigger)

### Key `dialog` Capabilities Used

- `lurek.dialog.newAI()` — create a dialogue selector per NPC type.
- `LDialogueAI:addTopic(id, opts)` — register topics with FSM/BT/utility gate requirements.
- `LDialogueAI:addBranch(topic, id, opts)` — register weighted branches within a topic.
- `LDialogueAI:setFSMState(state)` / `setBTStatus(status)` — inject current game state as selection context.
- `LDialogueAI:setUtilityScore(key, value)` — drive topic priority from game utility values (hunger, relationship, danger).
- `LDialogueAI:selectTopic()` / `selectBranch(topic)` — contextually select the best dialogue path.
- `lurek.dialog.newState()` — per-conversation state: current node, visited history, variable bindings.
- `LDialogueState:setVariable` / `getVariable` — store quest flags, relationship scores, discovered secrets.
- `lurek.dialog.newSpeakerRegistry()` — map speaker IDs to display name, portrait, and voice bank.

### Benefits

- Utility scoring + FSM/BT gating = NPCs speak differently based on game state, not just random pick.
- `visited` history prevents re-entering non-repeatable nodes (no dialogue loops).
- `DialogueState` is serialisable — save mid-conversation and restore exactly.
- `agent` fallback: if no topic matches, send a prompt to a local LLM for dynamic dialogue.
- `SpeakerRegistry` centralises character metadata — one source of truth for portrait + voice.

### As a Library

The `dialog` module exposes pure Rust types (`DialogueAI`, `DialogueState`, `SpeakerRegistry`) with no mandatory render or window dependency. It can be compiled into another project as a dialogue runtime without the full Lurek2D window stack.

### Constraints

- No built-in dialogue authoring GUI — all dialogue trees are defined in Lua code or TOML.
- LLM fallback requires Ollama on the host machine.

### Complexity Level

⭐⭐ — simple linear dialogue. ⭐⭐⭐⭐ — full utility-gated adaptive NPC with save/restore and LLM fallback.

---

## UC-39 — Headless Game Regression Framework

### Description

A QA engineer or solo developer builds a comprehensive regression test suite for a Lurek2D game using the `automation` module’s full feature set: TOML-scripted input sequences, conditional assertions, visual frame comparison (`VisualAssert`), macro composition, and boolean condition evaluation.

This is a step beyond UC-31 (basic CI harness) — it targets the full `automation` feature surface for complex multi-step game regression.

### Build Variant

`release --headless` for logic regression; `release` windowed for visual regression (with `VisualAssert`).

### Module Combination

`automation` · `timer` · `serial` · `filesystem` · `log` · `dataframe` (test result aggregation) · `pipeline` (test orchestration DAG) · `render` (frame capture for visual asserts)

### Key `automation` Capabilities Used

- `lurek.automation.loadFromToml(text)` — TOML-authored scripts: `keydown`, `mouseclick`, `wait`, `repeat`, `callmacro`, `assert`, `visualassert`.
- `lurek.automation.setCondition(name, val)` — set named boolean flags evaluated by `when` and `assert` expressions.
- `assert` steps with boolean expressions: `!flag`, `flag1 && flag2`, `(a || b) && c`.
- `visualassert` steps: compare a baseline PNG against the actual rendered frame with configurable `maxDiff` tolerance.
- `lurek.automation.saveMacro(name)` — register reusable input macros inlined by `callmacro` steps.
- `lurek.automation.setPlaybackSpeed(n)` — run tests at 10× speed in headless CI.
- `lurek.automation.waitUntil(pred, timeout)` — wait for async game state before asserting.
- `pipeline` orchestrates test suites: `[load_level, run_smoke, run_regression, collect_results]`.

### Benefits

- TOML scripts are version-controlled: test scenarios are human-readable and diffable.
- `visualassert` catches rendering regressions that pure logic tests miss.
- `callmacro` composes complex input sequences from reusable building blocks.
- Boolean condition evaluation in `assert` enables state-machine-aware test scripts.
- `pipeline` runs test suites as a DAG: independent test groups run in parallel.
- Single binary — no Selenium, no pytest, no test runner install.

### Constraints

- Visual regression tests require a display or virtual framebuffer on Linux CI.
- `maxDiff` tolerance is pixel-count based, not perceptual (SSIM).
- Replay fidelity depends on deterministic game logic (physics seed, random seed).

### Complexity Level

⭐⭐ — simple TOML replay. ⭐⭐⭐⭐⭐ — full visual regression suite with macro composition, condition expressions, and pipeline orchestration.

---

## UC-40 — Scientific Computing Workbench

### Description

A physicist, engineer, or data scientist uses Lurek2D as an interactive scientific computing environment: define N-dimensional arrays, apply linear algebra (LU decomposition, eigenvalue estimation, linear system solving), run FFT analysis, apply spatial filters (Gaussian, Sobel, morphology), and visualise results in real time.

This is the Lurek2D equivalent of a NumPy + Matplotlib notebook — without Python.

### Build Variant

`release` windowed for interactive exploration; `release --headless` for batch computation.

### Module Combination

`compute` · `charts` · `render` · `ui` · `input` · `filesystem` · `serial` · `dataframe` (tabular result export) · `terminal` (expression REPL)

### Key `compute` Capabilities

- `lurek.compute.zeros/ones/range/fromTable` — array construction.
- `LArray:matmul`, `dot`, `transpose`, `reshape` — linear algebra building blocks.
- `LArray:linsolve(b)` — solve A·x = b via Gaussian elimination with partial pivoting.
- `LArray:luDecompose()` — P·A = L·U with row permutation.
- `LArray:eigenPower()` — dominant eigenvalue + eigenvector via power iteration.
- `lurek.compute.fftMagnitude(samples)` — frequency domain analysis.
- `LArray:convolve2D(kernel)` — 2D convolution with zero padding.
- `LArray:sobel()` — edge detection on 2D float arrays.
- `LArray:dilate(r)` / `erode(r)` — morphological operations for image processing.
- `LArray:zscore()` / `normalizeRange()` / `pearsonCorr()` / `histogram()` — statistics.
- `LArray:map(fn)` / `eval(expr)` / `reduce(fn)` / `scan(fn)` — custom element-wise operations.
- Rayon parallel dispatch above configurable threshold (default 10 000 elements).

### Benefits

- Full linear algebra (LU, eigenvalue, Sobel) without NumPy or MATLAB.
- Rayon parallel execution for large arrays — uses all CPU cores.
- `LArray:eval("x^2 + 1")` — define array transformations as expression strings.
- `charts` renders histogram, scatter, and line plots from `NdArray` data.
- `terminal` provides a REPL for interactive array exploration.
- Single binary — no Python, no Julia, no R install.

### As a Library

The `compute` module is in the Foundations tier with no render or window dependency. It can be compiled as a standalone Rust library and linked into another project for CPU numerical computation.

### Constraints

- Float32/Float64/Int32 dtypes only — no complex number native type.
- GPU acceleration not available (CPU-only by design, constraint in `advanced-feature-surfaces.md`).
- Power iteration eigenvalue: dominant eigenpair only, not full decomposition.

### Complexity Level

⭐⭐ — array arithmetic. ⭐⭐⭐⭐ — full numerical simulation with FFT, linear solvers, and morphology.

---

## UC-41 — AI Skill-Injection Chatbot (LAISystem)

### Description

A developer builds a production-quality local chatbot application where the `LAISystem` orchestrates multiple specialist agents: each agent has a named role (support, coding, creative), shared system instructions, and keyword-gated skills that are automatically injected into prompts when relevant keywords appear. The chatbot routes user messages to the most appropriate agent.

This is the full `LAISystem` pattern — beyond the basic `LAgent` chat (UC-32).

### Build Variant

`release`.

### Module Combination

`agent` · `ui` · `render` · `terminal` · `save` (conversation history per agent) · `serial` · `dataframe` (response metadata logging)

### Key `agent` Capabilities (LAISystem)

- `lurek.agent.newSystem({ system_prompt = "You are a helpful assistant." })`.
- `system:addAgent("coding", agent)` — register specialist agents.
- `system:addInstruction("safety_rules", text)` — named instruction blocks included per-call.
- `system:addSkill("sql_expert", {"sql", "query", "database"}, prompt)` — auto-injected when user message contains those keywords.
- `system:prompt("coding", user_message, callback, { instructions = {"safety_rules"} })` — route to specialist with context.
- `system:runAll(tasks, callback)` — dispatch multiple agents in parallel for comparison.
- `system:buildContext(instruction, { agent = "coding" })` — preview the full assembled prompt before sending.
- Context assembly order: `system_prompt → auto-matched skills → explicit instructions → agent description → agent skills`.

### Benefits

- Auto-skill injection: typing "write an SQL query" automatically adds SQL expertise to the prompt — no manual routing.
- `buildContext` lets the developer inspect the full prompt before it fires.
- `runAll` enables A/B testing: send same query to two models, compare responses.
- All inference is local — no API key, no data leaves the machine.
- `dataframe` logs response latency, token count, and model used per conversation turn.

### Constraints

- Requires Ollama + at least one model (7B+ recommended for skill-gated quality).
- Keyword matching is string-overlap only — not semantic (no embedding lookup).
- No automatic agent selection — routing is explicit in `system:prompt(agent_name, ...)`.

### Complexity Level

⭐⭐⭐ — single-agent with one skill. ⭐⭐⭐⭐⭐ — multi-agent system with skill gating, instruction blocks, and A/B comparison.

---

## UC-42 — Data Quality Validator & Schema Checker

### Description

A data engineer or analyst uses Lurek2D headlessly to validate data quality: check column types, value ranges, null counts, uniqueness constraints, referential integrity, and statistical outliers across large CSV/JSON datasets. The `validator` and `dataframe` modules power the checks; the `agent` module generates a natural-language summary of quality issues.

### Build Variant

`release --headless` — runs as a CI step or scheduled data quality job.

### Module Combination

`validator` · `dataframe` · `compute` (z-score outlier detection) · `serial` · `filesystem` · `agent` (LLM quality summary) · `log` · `pipeline` (validation DAG: load → validate → report)

### Key Capabilities

- `lurek.validator.*` — validate values, types, ranges, and string patterns from Lua.
- `LDataFrame:query(sql)` — SQL `WHERE` filters to find null, out-of-range, or duplicate rows.
- `LDataFrame:zscore()` from `compute` — flag statistical outliers (|z| > 3).
- `LDataFrame:groupBy` + `count` — detect cardinality violations.
- `lurek.dataframe.fromCSVFileAsync` — async load of large files without blocking.
- `agent:setFormat("json")` + `prompt` — structured quality report as JSON from an LLM.
- `pipeline:fromTable` — orchestrate: `[load, type_check, range_check, outlier_check, report]` with per-step retry.

### Benefits

- SQL-style queries in `dataframe` find invalid rows without writing Rust.
- `pipeline` DAG ensures validation steps run in dependency order with retry on load failure.
- `agent` generates a plain-English summary: "Column `age` has 3.2% values above 120. Likely data entry errors."
- Zero external dependency: no Great Expectations, no dbt, no Python.
- Output is JSON/CSV — integrates with any reporting system.

### Constraints

- `validator` module provides structural checks; statistical analysis requires `compute`.
- No schema definition language (like JSON Schema) — rules are Lua functions.
- In-memory only: datasets larger than available RAM require streaming (not yet supported).

### Complexity Level

⭐⭐ — basic null check. ⭐⭐⭐⭐ — full multi-layer validation pipeline with LLM summary.

---

## UC-43 — Lurek2D as a Lua Scripting Library (Embedded Runtime)

### Description

A Rust developer embeds the Lurek2D runtime as a **library crate** inside their own application: the host application owns the window, the event loop, and the render surface; Lurek2D provides the Lua VM, module bindings (`dataframe`, `compute`, `agent`, `serial`, `pipeline`, `automation`), and the scripting infrastructure. Game scripts are loaded and executed by the host on demand.

This is the **library use case** — Lurek2D is not the top-level binary; it is a dependency.

### Build Variant

`--headless` library mode: no window, no wgpu surface. Only Lua VM + modules that have no render/window dependency.

### Applicable Modules (headless-safe)

`dataframe` · `compute` · `agent` · `serial` · `pipeline` · `automation` · `validator` · `grep` · `filesystem` · `math` · `patterns` · `thread` · `log` · `timer` · `dialog` (no render dep) · `graph` · `flownet`

### Benefits

- Host app controls the lifecycle — Lurek2D provides Lua scripting without imposing a window.
- `dataframe` + `compute` + `agent` are all Foundations/Core tier with no render coupling.
- `pipeline` provides DAG orchestration for the host’s task scheduler.
- `automation` provides input replay for the host’s own test infrastructure.
- MIT license — embed in commercial products without royalties.
- Single Rust crate — add to `Cargo.toml` as a dependency.

### Example Host Applications

- A Bevy game embeds Lurek2D for Lua modding support: mods script gameplay logic, Bevy owns rendering.
- A desktop app embeds Lurek2D for a user-facing scripting REPL (like a macro language).
- A simulation platform uses Lurek2D’s `dataframe` + `agent` + `pipeline` as its analytics and LLM layer.
- A CLI tool uses Lurek2D as its embedded Lua runtime for configuration and automation.

### Constraints

- Render-dependent modules (`render`, `audio`, `physics`, `ui`) require the window stack and cannot be embedded headlessly.
- Library API is not yet formally stabilised — semver guarantees follow Cargo.toml versioning.
- LuaJIT is not available on all ARM targets — use `--features lua54` for portability.

### Complexity Level

⭐⭐⭐ — scripting host with `dataframe` only. ⭐⭐⭐⭐⭐ — full embedded runtime with `agent` + `pipeline` + `automation`.

---

## UC-44 — Windows System Tray Application

### Description

A developer builds a minimal-footprint Windows desktop tool that lives in the system tray: shows a status icon, renders a compact popup window on click, polls data (network API, filesystem, local metrics), and displays results. Lurek2D’s `window` module supports borderless, transparent, and always-on-top windows — suitable for tray-style UIs.

### Build Variant

`dist` — smallest possible binary (~8–9 MB stripped + UPX). Static CRT link for zero VCRUNTIME dependency (`+crt-static`).

### Module Combination

`window` · `render` · `ui` · `input` · `timer` · `network` (data polling) · `dataframe` (lightweight aggregation) · `tween` (popup animation) · `save` (user preferences)

### Benefits

- `window` supports borderless and transparent window modes for floating HUD-style UI.
- `dist` profile + UPX: 8–9 MB executable, no installer needed — copy and run.
- Static CRT: no VCRUNTIME DLL requirement — works on any Windows 10/11 machine.
- `timer` drives background polling without a separate thread.
- `tween` animates slide-in/slide-out for the popup panel.
- Single Lua script — the entire app is one `main.lua`.

### Constraints

- No native Windows tray icon API — Lurek2D window is a regular desktop window, not a Shell_NotifyIcon tray entry. The “tray-style” behaviour is achieved via borderless + always-on-top window positioning.
- Windows-only in practice (Linux/macOS windowing works differently).

### Complexity Level

⭐⭐ — static popup window. ⭐⭐⭐ — animated popup with live data polling.

---

## UC-45 — Linux Headless Daemon / Background Service

### Description

A developer runs Lurek2D as a persistent headless background service on Linux: a scheduled data collector, a webhook listener, a game server companion process, or a monitoring agent. The `--headless` flag disables the window and GPU stack; the binary runs indefinitely, processing data and responding to events.

### Build Variant

`release --headless` · ARM64 cross-compile with `lua54` for Raspberry Pi / server ARM.

### Module Combination

`network` · `timer` · `dataframe` · `filesystem` · `serial` · `log` · `thread` · `pipeline` · `agent` (optional: LLM anomaly detection)

### Benefits

- `--headless` binary has no wgpu, no winit, no audio dependency: minimal memory footprint.
- `timer` drives periodic tasks (poll every 60 s, report every 1 h).
- `thread` runs parallel worker VMs for concurrent data collection.
- `pipeline` orchestrates multi-step daemon workflows with retry and error policy.
- `lua54` build runs on ARM Linux (Raspberry Pi, Jetson, server ARM) where LuaJIT is unavailable.
- `log` writes structured log output compatible with systemd journal and syslog.
- Single binary — deploy with `scp` and run as a systemd unit. No package manager needed.

### Constraints

- No signal handler for SIGTERM — graceful shutdown requires Lua-side loop exit logic.
- `lua54` is slower than LuaJIT on x86_64 — use LuaJIT build on x86_64 servers.
- No built-in daemon fork / PID file management — use systemd `Type=simple`.

### Complexity Level

⭐⭐ — simple polling loop. ⭐⭐⭐⭐ — multi-worker daemon with pipeline orchestration and LLM anomaly detection.

---

## UC-46 — Cross-Platform Configuration & Settings GUI

### Description

A developer builds a cross-platform desktop configuration GUI for another application: file path pickers, toggle switches, sliders, combo-box dropdowns, and text inputs — all rendered with Lurek2D’s native `ui` system and TOML-driven layouts. Settings are saved to TOML and read by the target application.

This is a practical use case for teams that need a small standalone settings editor without shipping Electron or a web app.

### Build Variant

`dist` (Windows static CRT) · `release` (Linux/macOS). Single binary, no installer.

### Module Combination

`ui` · `render` · `input` · `window` · `dialog` (file pickers) · `serial` (TOML read/write) · `save` · `filesystem` · `i18n` (optional: multi-language UI)

### Key `ui` Capabilities

- `LGuiSlider`, `LGuiCheckbox`, `LGuiComboBox`, `LGuiTextInput`, `LGuiButton` — all standard form controls.
- TOML layout files in `content/layouts/` — UI structure is data, not code.
- `LGuiTab` / `LGuiPanel` — multi-section settings pages.
- `dialog` — native OS file picker dialog for path selection.
- `serial.fromToml` / `toToml` — read and write TOML config files directly.

### Benefits

- TOML layouts: UI structure defined in data files, not hardcoded Lua — easy to modify.
- `dialog` provides native file picker dialogs (no custom file browser needed).
- `serial.toToml` writes human-readable TOML that the target app can parse with any TOML library.
- `dist` binary is 8–9 MB — ships alongside the target app without bloat.
- Works on Windows, Linux, and macOS with the same binary source.
- `i18n` enables multi-language settings UI for international distributions.

### Constraints

- No OS-native widget rendering (not a Win32/GTK/Cocoa GUI) — uses Lurek2D’s own renderer.
- Accessibility (screen readers, high-contrast) is not yet supported.

### Complexity Level

⭐⭐ — simple TOML key-value form. ⭐⭐⭐ — full tabbed settings GUI with file pickers and live preview.

---

## UC-47 — Agent `evalCode` Sandbox (LLM-Driven Code Execution)

### Description

A developer builds a tool where a local LLM writes Lua code and the engine immediately executes it in a sandboxed VM: the `agent:evalCode()` API evaluates LLM-generated Lua strings inside the active Lurek2D VM. This enables "AI writes code, engine runs it" workflows for data transformation, game logic prototyping, or interactive scripting assistants.

Example applications:
- A data transformation assistant: user describes a transformation in plain English, the LLM writes `dataframe` Lua code, `evalCode` runs it.
- A game level generator: user describes a level in text, LLM writes `tilemap` + `procgen` Lua code, `evalCode` populates the world.
- A debugging assistant: LLM diagnoses a runtime issue and writes a Lua fix, `evalCode` hot-patches it.

### Build Variant

`release`.

### Module Combination

`agent` · `terminal` (input/output display) · `ui` · `render` · `dataframe` (common target for generated code) · `serial` · `save` (session history)

### Key `agent` Capability

- `LAgent:evalCode(lua_string)` — executes a Lua string in the active VM; returns `true` or raises.
- `LAgent:setFormat("text")` — receive raw Lua code output from the model.
- `LAgent:addSkill("lua_style", prompt)` — inject Lua coding conventions into the model’s context.
- `LAISystem:addSkill("dataframe_api", keywords, api_docs)` — auto-inject the `dataframe` API reference when the user mentions "table" or "data".
- `agent:setOption("temperature", 0.1)` — low temperature for deterministic code generation.

### Benefits

- `evalCode` closes the loop: LLM generates code, engine runs it, results display immediately.
- `addSkill` with API documentation teaches the model the correct `lurek.*` API surface.
- Low temperature + JSON format = structured, reliable code output.
- `terminal` renders the code and output side by side for a REPL-like experience.
- Works fully offline with Ollama — no external API, no token cost.

### Constraints

- `evalCode` executes in the main VM: malformed code can raise a Lua error; wrap in `pcall` at the Lua boundary.
- The LLM may hallucinate API names — skill injection of correct API docs mitigates this.
- No sandboxed subprocess: generated code has full access to the Lua VM’s global scope.

### Complexity Level

⭐⭐ — simple eval loop. ⭐⭐⭐⭐ — full AI coding assistant with skill injection, format control, and error recovery.

---

## UC-48 — Real-Time Audio Spectrogram Visualiser

### Description

A musician, sound designer, or researcher builds a real-time audio analysis tool: capture or load audio, compute FFT spectra, and display a live scrolling spectrogram, RMS meter, and peak hold graph. The `dsp` module provides all analysis; `compute` handles FFT and correlation; `charts` and `render` display the results.

### Build Variant

`release` — real-time interactive tool. `release --headless` for batch spectrogram export.

### Module Combination

`dsp` · `audio` · `compute` · `render` · `charts` · `ui` · `input` · `filesystem` · `serial` (export) · `tween` (meter animation)

### Key API Combination

- `lurek.dsp.newSpectrumAnalyzer(bins)` + `analyzer:analyze(sound)` — per-frame FFT bins.
- `lurek.dsp.newLevelDetector()` + `detector:process(sound)` + `detector:get_rms()` — RMS meter.
- `lurek.dsp.newLevelDetector():to_db(rms)` — convert to dBFS for meter display.
- `lurek.compute.fftMagnitude(samples)` — raw magnitude spectrum from a sample buffer.
- `lurek.compute.correlate1d(a, b)` — cross-correlation between two frequency frames.
- `lurek.dsp.spectrogramToPng(wav, png)` — headless batch export of spectrogram images.
- Real-time render: each audio frame → FFT → draw vertical colour bar → scroll left.
- `lurek.dsp.addEffectToBus` / `setEffectParam` — apply real-time DSP and visualise the effect.

### Benefits

- `newSpectrumAnalyzer` is designed for per-frame analysis — 60 FPS spectrogram is the intended use case.
- Heat-colour mapping is built into `spectrogramToPng` — no custom shader needed for export.
- `compute.correlate1d` enables real-time beat detection and onset detection.
- `charts` renders bar graphs for per-band EQ display alongside the spectrogram.
- Single binary — no Python librosa, no Audacity, no MATLAB.

### Constraints

- Real-time audio capture requires OS audio input; Lurek2D’s `audio` module is playback-oriented — microphone input requires a `SoundData` buffer sourced externally or via a future capture API.
- 60 FPS spectrogram at 512 bins requires LuaJIT (not `lua54`) for sufficient throughput.

### Complexity Level

⭐⭐⭐ — scrolling FFT display. ⭐⭐⭐⭐⭐ — real-time spectrogram + RMS meter + DSP effect visualiser.

---

## UC-49 — Multi-Platform Game Launcher & Updater

### Description

A game studio builds a Lurek2D-based game launcher: display game list, check for updates via HTTP, download and unpack new versions, show changelogs, and launch the selected game binary. The launcher runs on Windows, Linux, and macOS from a single Lua script.

### Build Variant

`dist` (Windows) · `release` (Linux/macOS). Cross-platform binary, no installer.

### Module Combination

`ui` · `render` · `network` · `filesystem` · `serial` · `save` · `input` · `tween` · `image` · `dialog` · `pipeline` (download → verify → unpack → launch DAG) · `agent` (optional: changelog summary)

### Benefits

- `network` downloads update archives via HTTP with progress callbacks.
- `filesystem` handles extraction, path resolution, and launch of child processes.
- `pipeline` orchestrates the update flow: `[check_version, download, verify_checksum, unpack, launch]` with retry on download failure.
- `ui` renders a polished game grid with cover images, progress bars, and status badges.
- `image` loads cover art from disk and the download cache.
- `tween` animates download progress bars and panel transitions.
- `agent` summarises the changelog in plain English: "Version 1.4 fixes the cave boss and adds 3 new levels."
- Single binary — distributes as `launcher.exe` or `launcher` without dependencies.

### Constraints

- No code signing built in — Windows SmartScreen may warn on first run for unsigned executables.
- No delta-patch updates — full-file download only.
- Child process launch via `filesystem` module; the launched game runs independently.

### Complexity Level

⭐⭐⭐ — static game list with manual update. ⭐⭐⭐⭐ — full auto-update pipeline with LLM changelog summary.

---


## Build Variant Reference

| Profile | Command | Binary size | Use when |
|---------|---------|------------|----------|
| `dev` | `cargo build` | ~80–150 MB (unstripped) | Development, fast recompile |
| `release` | `cargo build --release` | ~30–40 MB (stripped=false) | Testing, QA |
| `dist` | `cargo build --profile dist` + UPX | ~8–9 MB | Shipping to end users |
| `lua54` | `--no-default-features --features lua54` | Similar to release | ARM64 / platforms without LuaJIT |
| `headless` | Runtime flag `--headless` | Same binary | CI, batch compute, server |

### ARM64 Cross-Compile

```toml
# .cargo/config.toml
[target.aarch64-unknown-linux-gnu]
linker = "aarch64-linux-gnu-gcc"
rustflags = ["-C", "target-cpu=native"]
```

```powershell
# From Windows via WSL2 or cross tool
cargo build --release --target aarch64-unknown-linux-gnu --no-default-features --features lua54
```

### Windows Static CRT

```powershell
$env:RUSTFLAGS="-C target-feature=+crt-static"
cargo build --profile dist
```

Produces a fully self-contained `.exe` with no VCRUNTIME dependency.

---

## What Lurek2D Does Not Do

These use cases are explicitly out of scope by architectural constraint:

| Non-use-case | Reason | Alternative |
|-------------|--------|-------------|
| Mobile game (iOS/Android) | Constraint A-02: desktop only | Love2D mobile fork, Godot, Defold |
| Browser/WASM game | Constraint A-02: no WASM target | Love2D WASM, Godot HTML5 |
| 3D game | Constraint A-03: 2D only | Godot, Bevy, Unity |
| MMO / massively multi-player | Single-machine runtime; no server infrastructure | Custom Rust server + protocol |
| Console (Switch, PS5, Xbox) | No platform SDK; constraint A-04 | Unreal, Unity (licensed), Godot |
| Visual editor / node graph IDE | Constraint A-01: no embedded editor | Godot, Unity, GameMaker |
| GPU tensor compute (ML training) | Compute module is CPU-only | PyTorch, JAX |
| Real-time audio plugin (VST/AU) | Not a plugin host/target | JUCE, Rust audio crates |
| Distributed simulation | Single-machine architecture | Custom cluster + Lua RPC |

---

## The Core Differentiator

> **Lurek2D solves the problem that other tools solve only partially:**
> a single portable binary, scriptable in Lua, with 5 000+ documented APIs, a native local LLM client, headless mode, and a code-only workflow that AI agents can use correctly on the first attempt.

Love2D is simpler but has 300 functions and no AI module.
Godot has an editor and can target mobile but requires GUI interaction.
Python + pandas is data-rich but requires a runtime and has no GPU renderer.
Bevy is Rust-native but has no Lua scripting and no simulation data modules.

**No single tool in 2026 combines:** desktop 2D rendering + physics + audio + dataframe + globe + province + flownet + local LLM + headless + single binary + MIT + code-only + VS Code IntelliSense + AI-first CAG system.

That combination is Lurek2D's defensible position.

---

*Document generated 2026-05-28. Sources: README.md, docs/lurek2d_positioning.md, docs/architecture/engine-architecture.md, Cargo.toml, src/agent/, ideas/, content/games/, content/examples/, library/.*
*Update this file when a new module is added or a new use case is validated with a working demo.*
