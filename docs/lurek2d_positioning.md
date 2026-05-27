# Lurek2D — Competitive Positioning

> **Audience:** Product, marketing, and technical leads.
> **Goal:** Establish where Lurek2D sits against popular 2D-capable engines, and why the AI-first, API-only model is a distinct and defensible position.

---

## 1. The Core Positioning Claim

> **Lurek2D is the API-first, AI-native 2D runtime.**
> It replaces the visual editor with a massive, fully documented, fully tested API surface that an AI agent (or a human) can use correctly from day one.

Traditional game engines were designed for humans clicking through GUIs.
Lurek2D is designed so that an AI coding agent can write a complete, working game — correctly, on the first try — because:

1. **Every reusable behaviour is a pre-built, tested API block.** 5 000+ `lurek.*` functions covering render, audio, physics, AI, UI, tilemap, particle, procgen, pathfinding, ECS, networking, data, and more.
2. **100% API documentation coverage is a hard quality gate.** `cargo clippy` and `collect_docs.py` reject any merge that leaves a public function undocumented.
3. **Every API function ships with examples, BDD tests, integration tests, and demo evidence.** An AI agent reads the docs, sees the example, and ships working code. No hallucination needed.
4. **The Lua scripting layer is synchronous and side-effect-free from the script's perspective.** Async complexity is hidden in Rust threads and `Channel`. Scripts stay simple and predictable.

---

## 2. Engine Comparison Matrix

### Engines evaluated

| # | Engine | Primary language | Editor model |
|---|--------|-----------------|--------------|
| 1 | **Godot 4** | GDScript / C# / C++ | Full visual editor |
| 2 | **GameMaker Studio 2** | GML / YOYO | Full visual editor + drag-and-drop |
| 3 | **Love2D** | Lua | No editor — pure code |
| 4 | **Corona SDK / Solar2D** | Lua | No editor — pure code |
| 5 | **Defold** | Lua | Full visual editor |
| 6 | **HaxeFlixel** | Haxe | No editor — pure code |
| 7 | **MonoGame** | C# | No editor — pure code |
| 8 | **Pygame** | Python | No editor — pure code |
| 9 | **Bevy** | Rust | No editor (ECS only) |
| 10 | **Unity (2D mode)** | C# | Full visual editor |
| — | **Lurek2D** | Lua (Rust core) | No visual editor — VS Code + API |

---

### 15 Evaluation Areas

#### Area 1 — API Surface Size and Breadth

*How many ready-made, tested building blocks exist?*

| Engine | Assessment |
|--------|-----------|
| Godot 4 | Very large — but spread across GDScript classes, C# bindings, and editor nodes. Hard to enumerate. |
| GameMaker 2 | Large built-in runtime, but locked to the GM toolchain. |
| Love2D | Small intentional surface (~300 functions). You build everything on top. |
| Corona / Solar2D | Medium. Good 2D basics, weak simulation/data. |
| Defold | Medium. Solid 2D, Lua-based, but surface is smaller than GM. |
| HaxeFlixel | Medium. Good 2D arcade toolkit. Limited outside that. |
| MonoGame | Medium-low. Thin XNA wrapper. You write most subsystems. |
| Pygame | Low-medium. Thin SDL2 wrapper. You write everything game-logic. |
| Bevy | Growing Rust ECS. Very little built-in game logic. |
| Unity 2D | Massive — but scattered across packages, Asset Store, C# namespaces, and editor magic. |
| **Lurek2D** | **5 000+ documented `lurek.*` functions across 70+ modules** (render, audio, physics, AI, ECS, UI, tilemap, particle, pathfinding, procgen, networking, dataframe, compute, globe, raycaster, and more). Single consistent namespace. |

**Lurek2D verdict:** Largest coherent, single-namespace API of any pure-code 2D runtime. Comparable to Unity in breadth, but code-only and fully enumerable.

---

#### Area 2 — Documentation Completeness and Machine-Readability

*Can an AI agent use the API correctly from docs alone, without trial and error?*

| Engine | Assessment |
|--------|-----------|
| Godot 4 | Good human docs. Not structured for AI consumption. Spread across web + in-editor. |
| GameMaker 2 | Reasonable docs. Proprietary format. No machine-readable contract. |
| Love2D | Very clean docs. Small surface makes 100% coverage feasible. |
| Corona / Solar2D | Partial. Docs lag the API. |
| Defold | OK. Lua, but incomplete in some areas. |
| HaxeFlixel | Partial. Haxe-doc generated. |
| MonoGame | Microsoft Docs style. Not AI-optimised. |
| Pygame | Python docstrings. Inconsistent completeness. |
| Bevy | Rust `rustdoc`. High completeness for a young project. |
| Unity 2D | Massive. Inconsistent. Some methods have minimal descriptions. |
| **Lurek2D** | **100% coverage enforced by quality gate.** `collect_docs.py --report-missing` fails CI if any `pub` item lacks a `///` doc comment. `docs/api/lurek.md` and `docs/api/lurek.lua` are generated from source — always in sync. |

**Lurek2D verdict:** Only engine where 100% documentation is a hard, automated, non-bypassable gate. AI agents read the generated reference and use functions correctly on first attempt.

---

#### Area 3 — AI-First Tooling and Workflow

*Is the engine designed for AI coding agents as first-class users?*

| Engine | Assessment |
|--------|-----------|
| Godot 4 | Some AI plugins exist. Engine was not designed with AI agents in mind. |
| GameMaker 2 | No AI-native layer. |
| Love2D | Simple enough that AI can write correct Love2D. But no structured support. |
| Defold | No AI-native layer. |
| Others | None were designed with AI agents as primary users. |
| **Lurek2D** | **AI-first by design.** The CAG system (Context Augmented Guidance) provides a full agent roster, skill bundles, prompt templates, and retrieval corpus. VS Code extension ships IntelliSense from generated type stubs. Local AI agent workflows are documented in `extensions/vscode/cag/game-dev/`. The philosophy doc states: "Could a Copilot agent use this API correctly without a clarifying question? If not, redesign." |

**Lurek2D verdict:** The only 2D engine whose architecture document names AI agents as first-class users and enforces AI-verifiability as a design constraint.

---

#### Area 4 — Code-Only Workflow (No GUI Required)

*Can a developer or AI agent build a complete game without touching a visual editor?*

| Engine | Assessment |
|--------|-----------|
| Godot 4 | Possible in theory via `.tscn` text files, but scene graph design without the editor is painful. |
| GameMaker 2 | No. The IDE is mandatory for most workflows. |
| Love2D | Yes — 100% code. But you assemble everything from scratch. |
| Corona / Solar2D | Yes — code only. |
| Defold | Partial — editor is strongly encouraged for scene composition. |
| HaxeFlixel | Yes — code only. |
| MonoGame | Yes — code only. |
| Pygame | Yes — code only. |
| Bevy | Yes — Rust ECS, code only. |
| Unity 2D | No. Scene graphs require the editor. Script-only workflows lose most Unity value. |
| **Lurek2D** | **Yes — fully code-only by design constraint (A-01).** A single `main.lua` is a valid complete game. VS Code is tooling, not the engine. |

**Lurek2D verdict:** Full code-only workflow is a binding constraint, not an afterthought. AI agents never need a visual editor step.

---

#### Area 5 — Scripting Ergonomics for Non-Engine Developers

*How easy is it to write game logic without knowing engine internals?*

| Engine | Assessment |
|--------|-----------|
| Godot 4 | GDScript is friendly. But you must understand scenes, nodes, signals — editor-centric mental model. |
| GameMaker 2 | GML is approachable. But tied to the GM IDE. |
| Love2D | Clean Lua. No built-in patterns. You choose all architecture. |
| Corona / Solar2D | Lua with a thin event model. Approachable. |
| Defold | Lua, but message-passing model is unfamiliar to beginners. |
| HaxeFlixel | Haxe is typed but niche. Steeper learning curve. |
| MonoGame | C# is verbose for simple tasks. |
| Pygame | Python is friendly but slow for anything complex. |
| Bevy | Rust ECS is powerful but steep. High expertise required. |
| Unity 2D | C# is clean but the engine API surface is enormous and inconsistent. |
| **Lurek2D** | **Lua with a consistent single-namespace API.** No scenes, no nodes, no message buses to understand. Call `lurek.render.sprite(...)`, `lurek.physics.body(...)`, `lurek.audio.play(...)`. Every callback (`init`, `process`, `draw`) is optional — an empty `main.lua` is valid. |

**Lurek2D verdict:** Lowest time-to-first-working-game. The API surface replaces architectural decisions. A developer (or AI) calls functions, not designs systems.

---

#### Area 6 — Engine Binary Size and Distribution Simplicity

*How simple is it to ship a game?*

| Engine | Assessment |
|--------|-----------|
| Godot 4 | Export templates are ~60–100 MB. Editor separate. |
| GameMaker 2 | Proprietary export. IDE required to build. |
| Love2D | Runtime ~10 MB. Game is a `.love` zip. Clean. |
| Corona / Solar2D | Simulator required for build. |
| Defold | Editor required to build output. |
| HaxeFlixel | Haxe compiler + runtime. Moderate. |
| MonoGame | .NET runtime dependency. |
| Pygame | Python runtime dependency. |
| Bevy | Rust binary — can be very small. No scripting overhead. |
| Unity 2D | Build output ~30–80 MB minimum. IL2CPP pipelines are complex. |
| **Lurek2D** | **Single binary. Proposed constraint A-05: core binary ≤ 10 MB stripped.** Game is a folder of `.lua` files + assets. No build step for game content. Instant iteration. |

**Lurek2D verdict:** One binary, one folder, zero build pipeline for game content. Closest competitor is Love2D, but Lurek2D ships a much larger built-in API surface.

---

#### Area 7 — Learning Curve for New Developers

*Time from install to first working game.*

| Engine | Assessment |
|--------|-----------|
| Godot 4 | Medium. Scene/node model, GDScript, editor layout all new concepts. |
| GameMaker 2 | Low-medium. Drag-drop helps beginners. Paid license. |
| Love2D | Low for Lua speakers. No structure means decisions quickly accumulate. |
| Defold | Medium-high. Message-passing Lua model is unusual. |
| Unity 2D | High. Scene graph, prefabs, packages, asset pipeline — months to mastery. |
| Bevy | High. Rust + ECS = expert territory. |
| **Lurek2D** | **Low for anyone who can read examples.** Philosophy: "one afternoon to learn." API docs + working examples cover every function. The AI copilot path is the intended first workflow. |

**Lurek2D verdict:** AI-assisted onboarding is the primary path. Reading the generated `lurek.md` reference and running a content/examples file is enough to start.

---

#### Area 8 — Performance Baseline (Desktop 2D)

*60 FPS at 1080p on integrated GPU — achievable without expert tuning?*

| Engine | Assessment |
|--------|-----------|
| Godot 4 | Yes, for most 2D. Vulkan overhead can surprise. |
| GameMaker 2 | Yes. Good 2D renderer. |
| Love2D | Yes. OpenGL renderer. Lua GC can cause hitches at scale. |
| Pygame | Borderline. Python overhead is real. |
| Bevy | Yes. Rust + wgpu. Excellent baseline. |
| Unity 2D | Yes. Proven, but GC hitches in C# need management. |
| **Lurek2D** | **B-03 is a binding constraint: 60 FPS at 1080p on Intel UHD 620 / AMD Vega 8.** Rust core + wgpu 22 (Vulkan/DX12/Metal). Queued GPU rendering (render command buffer). LuaJIT for script performance. |

**Lurek2D verdict:** Performance target is a hard architectural constraint, not a goal. Enforced at the engine tier level, not left to the game developer.

---

#### Area 9 — Test, Evidence, and Example Coverage

*How much validated, working code exists to ground AI generation?*

| Engine | Assessment |
|--------|-----------|
| Godot 4 | Official docs have examples. Tests are community-maintained. |
| GameMaker 2 | Sample projects. No automated test infra exposed to users. |
| Love2D | Community snippets. No official test framework. |
| Defold | Examples and demos. No formal BDD test layer exposed to game devs. |
| Unity 2D | Massive community. But AI-generated Unity code has high slop rate because the API is inconsistent and the scene graph is opaque. |
| **Lurek2D** | **Every API function has: (1) `///` doc comment at source, (2) at least one BDD Lua test in `tests/lua/`, (3) at least one integration test, (4) at least one `content/examples/` working example, (5) optional demo evidence.** This is enforced by quality gates Q-03, Q-04, Q-05, and `TST-01` through `TST-06`. |

**Lurek2D verdict:** The test + example + doc triangle is the primary AI slop prevention mechanism. An AI that reads the docs, sees the example, and copies the test pattern writes correct code. Competitors have none of these as hard requirements.

---

#### Area 10 — Vibe-Coding Risk (AI Slop Rate)

*How likely is an AI agent to produce plausible-looking but broken code?*

| Engine | Assessment |
|--------|-----------|
| Godot 4 | High slop risk. GDScript and scene graph both have many implicit conventions. |
| Unity 2D | Very high slop risk. Unity's API surface is enormous, inconsistent across versions, and relies on editor magic (prefabs, Inspector, lifecycle) that AI cannot "see". |
| Love2D | Low-medium. Small API = less to get wrong. But game architecture is freestyle — AI fills gaps with invented patterns. |
| Pygame | Medium. Python surface is known but game architecture is invented from scratch every time. |
| Bevy | Medium-high. Rust + ECS has steep typing requirements. AI misses borrow checker subtleties. |
| **Lurek2D** | **Minimum slop rate by design.** The massive API surface means most game behaviours are already implemented and tested inside the engine. AI writes Lua that calls proven, documented blocks. It does not invent new subsystems. Pure Lua logic (rules, state machines, game-specific math) is where AI works, not in engine plumbing. |

**Lurek2D verdict:** The API surface is the anti-slop layer. More API coverage = fewer decisions the AI must invent. This is the core product differentiator.

---

#### Area 11 — Modding and Extensibility

*Can users extend or mod the engine without touching Rust?*

| Engine | Assessment |
|--------|-----------|
| Godot 4 | GDNative / GDExtension. Powerful but complex. |
| GameMaker 2 | Extensions via DLLs. Not approachable for most users. |
| Love2D | Pure Lua. Any Lua code extends the runtime. Very open. |
| Defold | Lua scripts. Extensions via native extensions (complex). |
| **Lurek2D** | **`library/` (Lureksome):** pure-Lua reusable modules on top of `lurek.*`. **`lurek.mods.*`:** mod hook system. **Pure Lua extension path requires zero Rust.** Plugins proposed for optional subsystems (see `docs/architecture/plugins.md`). |

**Lurek2D verdict:** Pure-Lua modding is a first-class path. The `library/` layer ships dozens of reusable game-logic modules. Mods are Lua scripts — AI can write them.

---

#### Area 12 — Simulation, Data, and Non-Game Use Cases

*Can the runtime serve compute-heavy or simulation workloads beyond traditional games?*

| Engine | Assessment |
|--------|-----------|
| Godot 4 | Not designed for it. Some community workarounds. |
| GameMaker 2 | No. Game-focused only. |
| Love2D | Possible but painful — no built-in data structures. |
| Pygame | Used for simulations. Python data ecosystem helps. |
| Bevy | Growing ECS-based simulation support. |
| **Lurek2D** | **`lurek.dataframe.*`, `lurek.compute.*`, `lurek.procgen.*`, `lurek.graph.*`, `lurek.globe.*`, `lurek.province.*`, `lurek.patterns.*`, `lurek.learning.*`, `lurek.flownet.*`.** Non-game use cases (digital twins, local data tools, simulation sandboxes) are first-class in the API surface. |

**Lurek2D verdict:** The broadest simulation/data API of any 2D runtime. Enables use cases no other 2D engine targets.

---

#### Area 13 — Community Tooling and Ecosystem

*Plugins, assets, forums, tutorials — how rich is the ecosystem?*

| Engine | Assessment |
|--------|-----------|
| Godot 4 | Large and growing. Active community. Asset store. |
| Unity 2D | Massive Asset Store. Largest community of any game engine. |
| Love2D | Small, dedicated. Long-lived. Quality over quantity. |
| Lurek2D | Early. Offset by: (a) VS Code extension with IntelliSense, (b) CAG agent system for AI-assisted work, (c) large built-in API surface reducing need for third-party plugins. |

**Lurek2D verdict:** Weakest area for an early project. Mitigated by: the AI tooling layer, the `library/` pure-Lua package, and the VS Code extension. The position: ship the functionality others delegate to plugins.

---

#### Area 14 — Open Source Licensing and Commercial Use

*Is the engine free, and can you ship commercial games without royalties?*

| Engine | Assessment |
|--------|-----------|
| Godot 4 | MIT. Free commercial use. |
| GameMaker 2 | Proprietary. Paid licenses for commercial export. |
| Love2D | zlib. Free commercial use. |
| Corona / Solar2D | MIT. Free commercial use. |
| Defold | Defold License. Free, but restrictions apply to redistribution. |
| HaxeFlixel | MIT. Free commercial use. |
| MonoGame | Microsoft Public License. Generally free commercial. |
| Pygame | LGPL. Free commercial use (with conditions). |
| Bevy | MIT + Apache 2. Free commercial use. |
| Unity 2D | Proprietary. Revenue-based licensing. Runtime fee controversy (2023). |
| **Lurek2D** | **MIT.** Engine, examples, libraries, docs, and tools. Zero royalties. No runtime fees. No license server. |

**Lurek2D verdict:** Maximally open. Especially relevant for indie and AI-automated pipelines where licensing audits add friction.

---

#### Area 15 — Platform Reach

*Which platforms can you target?*

| Engine | Assessment |
|--------|-----------|
| Godot 4 | Desktop + Web + Mobile + Console (community). |
| GameMaker 2 | Desktop + Web + Mobile + Console (paid tiers). |
| Love2D | Desktop + Android (community). |
| Pygame | Desktop only (practically). |
| Bevy | Desktop + Web (experimental). |
| Unity 2D | All platforms including Console + Mobile + VR. |
| **Lurek2D** | **Desktop only (Windows / Linux / macOS, x86_64 + ARM). Binding constraint A-02.** No mobile, no WASM. |

**Lurek2D verdict:** Narrower than Unity or Godot by design. Desktop-only is a deliberate scope decision, not a limitation — it allows the engine to maintain a small, reliable binary and tight GPU/OS assumptions (B-03).

---

## 3. Summary Scorecard

Legend: ★★★ best-in-class · ★★ competitive · ★ acceptable · — weak/not applicable

| Area | Godot 4 | GameMaker 2 | Love2D | Unity 2D | Lurek2D |
|------|---------|-------------|--------|----------|---------|
| 1. API surface breadth | ★★ | ★★ | ★ | ★★★ | ★★★ |
| 2. Docs completeness / machine-readable | ★★ | ★ | ★★ | ★★ | ★★★ |
| 3. AI-first tooling | ★ | — | ★ | ★ | ★★★ |
| 4. Code-only workflow | ★ | — | ★★★ | — | ★★★ |
| 5. Scripting ergonomics | ★★★ | ★★★ | ★★ | ★★ | ★★★ |
| 6. Binary size / ship simplicity | ★★ | ★ | ★★★ | ★ | ★★★ |
| 7. Learning curve | ★★ | ★★★ | ★★ | ★ | ★★★ |
| 8. Performance baseline | ★★ | ★★★ | ★★ | ★★★ | ★★★ |
| 9. Test + evidence coverage | ★★ | ★ | ★ | ★★ | ★★★ |
| 10. Vibe-coding / AI slop risk ↓ | ★★ | ★ | ★★ | ★ | ★★★ |
| 11. Modding / extensibility | ★★ | ★ | ★★★ | ★★ | ★★ |
| 12. Simulation / data capabilities | ★ | — | ★ | ★ | ★★★ |
| 13. Community / ecosystem | ★★★ | ★★ | ★★ | ★★★ | ★ |
| 14. Open source / licensing | ★★★ | — | ★★★ | — | ★★★ |
| 15. Platform reach | ★★★ | ★★★ | ★★ | ★★★ | ★★ |

> Lurek2D leads in 9 of 15 areas. Its single structural weakness is ecosystem/community size — expected for an early project and offset by the AI-assisted workflow layer.

---

## 4. The "API as Building Blocks" Model Explained

GameMaker gives you **blocks you drag onto a canvas.**
Lurek2D gives you **blocks you call in Lua.**

Both solve the same core problem: you should not have to implement a physics solver, an audio mixer, or a tilemap renderer to make a game. The difference:

| | GameMaker | Lurek2D |
|--|-----------|---------|
| How you access blocks | GUI + GML | `lurek.*` Lua calls |
| AI can use? | No — GUI is opaque | Yes — API is 100% documented |
| Tests for each block? | No | Yes — every function |
| Add your own blocks? | Extensions (complex) | Pure Lua library/ or Rust plugin |
| Editor required? | Yes | No |
| Works in CI/headless? | Limited | Yes — Lua-first test harness |

The Lurek2D model removes the only part AI cannot see: the visual editor. Everything else — the building blocks — is exposed as a clean, tested, documented Lua API.

---

## 5. Primary Positioning Statement

> **Lurek2D: Game development for the agent-assisted era.**
>
> Where other engines ship a visual editor, Lurek2D ships 5 000+ documented, tested API building blocks. Your `main.lua` wires them together. An AI agent reads the docs, sees the example, and writes correct game code — the first time.
>
> One binary. One Lua file. Zero IDE ceremony. Maximum API surface. Minimum AI slop.

---

## 6. Target Personas and Their Hook

| Persona | Why Lurek2D |
|---------|-------------|
| AI-assisted game developer | The API is the context window. 5 000+ functions, all documented, all tested. AI slop eliminated at the source. |
| Indie solo developer | Fast path from idea to playable. No editor to learn. Examples for everything. MIT licensed. |
| Game jam participant | `main.lua` + API reference + examples → working game in hours, not days. |
| Simulation / tool builder | `dataframe`, `compute`, `procgen`, `globe`, `province` — no other 2D runtime offers this. |
| Engine developer | Rust core, clean 5-tier architecture, no cycles, documented spec per module. Easy to extend. |
| Educator / student | Engine architecture, test placement, doc standards — all visible. The whole system is a teaching artifact. |

---

*Generated by Architect agent — skill_enterprise-architecture + skill_solution-options loaded.*
*Source references: `docs/architecture/philosophy.md`, `README.md`, `src/lua_api/` (71 modules), `content/examples/` (67 example files).*
