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

| # | Name | Status | Build variant |
|---|------|--------|---------------|
| UC-01 | Indie 2D Desktop Game | Current | `release` / `dist` |
| UC-02 | Game Jam / Rapid Prototype | Current | `dev` / `release` |
| UC-03 | Education — Programming & Architecture | Current | `dev` |
| UC-04 | Demo Scene / Interactive Visual Art | Current | `release` |
| UC-05 | Simulation Sandbox & Strategy Research | Current | `release` |
| UC-06 | Digital Twin Visualiser | Near-future | `release` headless + windowed |
| UC-07 | Local AI-Driven NPC / Game Logic | Current | `release` (Ollama required) |
| UC-08 | Headless Batch Compute & Data Pipeline | Current | `release --headless` |
| UC-09 | Internal Studio Tool / Level Editor | Near-future | `release` |
| UC-10 | Modding Platform / Scripted App Host | Current | `release` |
| UC-11 | Physical AI & Robotics Visualiser | Future | `dist` ARM64 |
| UC-12 | Wargame / Military Decision-Support Tool | Future | `dist` headless |
| UC-13 | Audio / Video Processing Pipeline | Future | `dist` headless |
| UC-14 | ARM64 Edge Device Dashboard | Near-future | `lua54` ARM64 |
| UC-15 | Teaching Instrument for AI/ML Research | Near-future | `release` headless |

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

## Module × Use Case Matrix

The table below maps each major Lurek2D module to the use cases it primarily enables.

| Module | UC-01 | UC-02 | UC-03 | UC-04 | UC-05 | UC-06 | UC-07 | UC-08 | UC-09 | UC-10 | UC-11 | UC-12 | UC-13 | UC-14 | UC-15 |
|--------|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|
| `render` | ● | ● | ● | ● | ● | ● | | | ● | | ● | ● | ◌ | ● | ◌ |
| `audio` | ● | ● | | | | | | | | | | | ● | | |
| `physics` | ● | ● | ● | | | | | | | | | | | | |
| `input` | ● | ● | ● | ● | ● | ● | | | ● | ● | | | | | |
| `ui` | ● | | | | ● | ● | | | ● | ● | ● | ● | | ● | |
| `tilemap` | ● | ● | | | | | | | ● | | | | | | |
| `scene` | ● | ● | ● | | | | | | | | | | | | |
| `agent` | | | | | ● | ● | ● | ● | | | ● | ● | | | ● |
| `dataframe` | | | | | ● | ● | ◌ | ● | | | ● | ● | ◌ | ● | ● |
| `compute` | | | | ● | ● | | | ● | | | | | ● | | ● |
| `procgen` | ● | ● | | ● | ● | | | ● | | | | | | | |
| `province` | ◌ | | | | ● | ● | | | | | | ● | | | ● |
| `globe` | ◌ | | | | ● | ● | | | | | ● | ● | | | |
| `pathfind` | ● | | | | ● | ● | | | | | ● | ● | | | |
| `flownet` | | | | | ● | ● | | | | | | ● | | | |
| `graph` | | | | | ● | ● | | ● | | | | ● | | | |
| `patterns` | ● | | ● | | ● | | | | | | | | | | ● |
| `network` | ◌ | | | | | ● | | ◌ | | | ● | ◌ | | ● | |
| `thread` | ◌ | | | | ◌ | | ● | ● | | | ● | | ● | | ● |
| `dsp` | ◌ | | | ● | | | | | | | | | ● | | |
| `learning` | | | | | | | ◌ | | | | | | | | ● |
| `save` | ● | | | | ● | | ◌ | | ● | | | ● | | ● | |
| `automation` | | | | | | ◌ | | ● | ◌ | | | ● | | | ● |
| `charts` | | | | | ● | ● | | ● | | | | | ◌ | ● | ● |
| `minimap` | ● | | | | ● | ● | | | | | ● | ● | | | |
| `ecs` | ● | ● | ● | | | | | | | | | | | | |
| `ai` | ● | | | | ● | | ● | | | | | | | | ● |
| `mods` | ◌ | | | | | | | | | ● | | | | | |
| `i18n` | ● | | | | | | | | | | | | | | |
| `serial` | ● | | | | ● | ● | | ● | ● | | ● | ● | | ● | ● |

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
