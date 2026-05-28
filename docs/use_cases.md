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

### AI & LLM

| # | Name | Status | Build variant |
|---|------|--------|---------------|
| UC-07 | Local AI-Driven NPC / Game Logic | Current | `release` |
| UC-32 | LLM Inference Server with GUI | Near-future | `release` |
| UC-33 | Multi-Agent Game Design Tool | Near-future | `release` |
| UC-34 | Procedural Content Factory | Current | `release --headless` |

### Platform & Tooling

| # | Name | Status | Build variant |
|---|------|--------|---------------|
| UC-09 | Internal Studio Tool / Level Editor | Near-future | `release` |
| UC-10 | Modding Platform / Scripted App Host | Current | `release` |
| UC-11 | Physical AI & Robotics Visualiser | Future | `dist` ARM64 |
| UC-13 | Audio / Video Processing Pipeline | Future | `dist` headless |
| UC-14 | ARM64 Edge Device Dashboard | Near-future | `lua54` ARM64 |

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

## Module × Use Case Matrix

The table below maps each major module to the use cases where it plays a primary (●) or secondary (◌) role. New UCs are abbreviated as numbers.

| Module | 01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24 | 25 | 26 | 27 | 28 | 29 | 30 | 31 | 32 | 33 | 34 |
|--------|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| `render` | ● | ● | ● | ● | ● | ● | | | ● | | ● | ● | ◌ | ● | ◌ | ● | ● | ● | ● | ● | ● | ● | ● | ● | ● | ● | ● | | ● | | ◌ | ◌ | ● | |
| `audio` | ● | ● | | | | | | | | | | | ● | | | ● | ● | ● | ● | ◌ | ● | | | | | | | | | | | | | |
| `physics` | ● | ● | ● | | | | | | | | | | | | | ● | | ● | | | ● | | | | | | | | | | | | | |
| `input` | ● | ● | ● | ● | ● | ● | | | ● | ● | | | | | | ● | ● | ● | ● | ● | ● | | ● | ● | ◌ | ● | ● | | | | | ● | ◌ | |
| `ui` | ● | | | | ● | ● | | | ● | ● | ● | ● | | ● | | ◌ | ● | ◌ | ◌ | ◌ | | ● | ● | ● | ● | ● | ● | | ● | | | ● | ● | |
| `tilemap` | ● | ● | | | | | | | ● | | | | | | | ◌ | | | | | | | | | | | | | | | | | | |
| `scene` | ● | ● | ● | | | | | | | | | | | | | ● | ● | ◌ | | | ● | | | | | | | | | | | | | |
| `agent` | | | | | ● | ● | ● | ● | | | ● | ● | | | ● | | ◌ | | | | | ◌ | | | ◌ | | | | ◌ | ● | | ● | ● | ● |
| `dataframe` | | | | | ● | ● | ◌ | ● | | | ● | ● | ◌ | ● | ● | | | | | | | ● | ◌ | ● | ● | ● | ◌ | ● | ● | ● | ◌ | | ● | ◌ |
| `compute` | | | | ● | ● | | | ● | | | | | ● | | ● | | | | | | | | | | | | ● | | | | | | | |
| `procgen` | ● | ● | | ● | ● | | | ● | | | | | | | | ◌ | | | | | | | | | | | | | | | | | | ● |
| `province` | ◌ | | | | ● | ● | | | | | | ● | | | ● | | | | | | | ◌ | | | | | | | | | | | | |
| `globe` | ◌ | | | | ● | ● | | | | | ● | ● | | | | | | | | | | | | | | | | | | | | | | |
| `pathfind` | ● | | | | ● | ● | | | | | ● | ● | | | | | | | | | | ● | | | | | | | | | | | | |
| `flownet` | | | | | ● | ● | | | | | | ● | | | | | | | | | | ● | | | | | | | | | | | | |
| `graph` | | | | | ● | ● | | ● | | | | ● | | | | | | | | | | ● | ● | | | | | | | | | | | |
| `patterns` | ● | | ● | | ● | | | | | | | | | | ● | | | | | | | | | | | | | | | | | | | |
| `network` | ◌ | | | | | ● | | ◌ | | | ● | ◌ | | ● | | | | | | | | | | | ● | | | ● | ● | ◌ | | | | |
| `thread` | ◌ | | | | ◌ | | ● | ● | | | ● | | ● | | ● | | | | | | | | | | | | ● | ● | | ● | | | ◌ | ● |
| `dsp` | ◌ | | | ● | | | | | | | | | ● | | | | | | ● | | | | | | | | | | | | | | | |
| `midi` | | | | | | | | | | | | | ● | | | | | | ● | | | | | | | | | | | | | | | |
| `learning` | | | | | | | ◌ | | | | | | | | ● | | | | | | | | | | | | | | | | | | | |
| `save` | ● | | | | ● | | ◌ | | ● | | | ● | | ● | | | ● | ◌ | ● | | | | | ● | ● | ◌ | | | ◌ | | | ● | ● | |
| `automation` | | | | | | ◌ | | ● | ◌ | | | ● | | | ● | | | | | | | | | | | | | ◌ | | | ● | | | |
| `charts` | | | | | ● | ● | | ● | | | | | ◌ | ● | ● | | | | ◌ | | | ◌ | ◌ | ● | ● | ● | | | ● | | | | | |
| `minimap` | ● | | | | ● | ● | | | | | ● | ● | | | | | | | | | | ◌ | | | | | | | | | | | | |
| `ecs` | ● | ● | ● | | | | | | | | | | | | | ● | | ◌ | | | ● | | | | | | | | | | | | | |
| `ai` | ● | | | | ● | | ● | | | | | | | | ● | ● | | | | | | | | | | | | | | | | | | |
| `mods` | ◌ | | | | | | | | | ● | | | | | | | | | | | | | | | | | | | | | | | | |
| `i18n` | ● | | | | | | | | | | | | | | | ● | ● | | | | | | | | | | | | | | | | | |
| `serial` | ● | | | | ● | ● | | ● | ● | | ● | ● | | ● | ● | | ◌ | | ◌ | | | ● | ● | ● | ● | ● | ● | ● | ● | ● | ● | ● | ● | ● |
| `terminal` | | | | | | | | | | | | | | | | | | | | ● | | | | | | | | | | | | ● | ● | |
| `grep` | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | ● | | | | |
| `filesystem` | ◌ | | | | | ◌ | | ● | ● | ● | | | | | | | | | | | | | | ● | | ● | ● | ● | | ● | ● | ● | | ◌ |
| `overlay` | | | | | | | | | | | | | | | | | | | | | | | | | | | | | ● | | | | | |
| `dialog` | | | | | | | | | ◌ | | | | | | | | | | | | | | | | | ● | ◌ | | | | | | | |
| `effect` | | | | ● | | | | | | | | | | | | ● | | | | ● | | | | | | | | | | | | | | |
| `raycaster` | | | | ● | | | | | | | | | | | | ● | | | | | | | | | | | | | | | | | | |
| `parallax` | ◌ | | | ● | | | | | | | | | | | | ◌ | | | | | | | | | | | | | | | | | | |
| `tween` | ● | ● | | ◌ | | | | | | | | | | | | ● | ● | ● | ● | ● | ● | | ● | ◌ | | ◌ | | | | | | | | |
| `timer` | ● | ● | | | | | | | | | | | | | | ● | ● | ● | ● | ● | ● | | | ● | ● | | | | ● | | | | | |
| `particle` | ● | ◌ | | ● | | | | | | | | | | | | ● | ◌ | ● | ● | ● | ◌ | | | | | | | | | | | | | |
| `camera` | ● | ● | | ● | | | | | ● | | | | | | | ● | ● | ● | | | | | ● | | | ● | | | | | | | | |
| `light` | ◌ | | | ● | ● | | | | | | | | | | | ◌ | | | | | | | | | | | | | | | | | | |
| `spine` | ◌ | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |
| `html` | | | | | | | | | | | | | | | | | ● | | | | | | | ● | | ◌ | | | | | | | | |
| `window` | ● | ● | | | | | | | ● | | | | | | | ● | ● | ● | ● | ● | ● | | | ● | ● | ● | ● | | ● | | | ● | | |
| `log` | | | | | | | | ● | | | | | | | | | | | | | | | | | | | | ● | | ● | ● | | | ● |
| `validator` | | | | | | | | ◌ | | | | | | | | | | | | | | | | | | | | ◌ | | | | | | |

● = primary use   ◌ = secondary / optional

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
