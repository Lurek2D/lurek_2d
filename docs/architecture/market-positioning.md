# Market Positioning

## Positioning Statement

Lurek2D is a Lua-first 2D runtime and toolkit for games, simulations, visual tools, and interactive desktop apps.

It is powered by a Rust core and exposed through a broad public `lurek.*` API. The project is code-first, desktop-focused, AI-assisted, and agent-friendly, but it is not an AI-only product and it is not positioned as a generative-AI wrapper.

## Short Copy

Use this as the default public description:

> Lurek2D is a Lua-first 2D runtime and toolkit for games, simulations, visual tools, and interactive desktop apps, powered by a Rust core and a broad `lurek.*` API.

Short variants:

- A Rust-powered Lua runtime for 2D games, simulations, and tools.
- A code-first 2D runtime with a broad `lurek.*` API.
- A programmable Lua/Rust runtime for interactive 2D systems.
- A code-first alternative between Love2D and editor-heavy engines.

Avoid these as primary claims:

- undefined AI headlines
- Unity replacement
- Godot replacement
- narrow "just another 2D engine" framing
- AI game engine without a clear definition

## Core Pillars

### Code-first

The primary workflow is:

```text
write Lua -> call lurek.* -> run the runtime -> iterate
```

There is no embedded visual editor in the engine binary. The VS Code extension and generated docs are tooling layers, not the runtime itself.

### Rust core plus Lua surface

Rust owns performance-critical systems: rendering, audio, input, physics, filesystem access, runtime services, data processing, and integration boundaries. Lua owns game, simulation, tool, and app logic through the public API.

### Broad built-in API

Lurek is differentiated by the breadth of `lurek.*`, not by editor workflow. The API covers classic game systems and broader runtime needs: UI, data, compute, procedural generation, automation, AI/game behavior, graphs, pipelines, and simulation-oriented modules.

### Games plus simulations plus tools

Games remain a major use case, but Lurek should not be described only as a game engine. The same runtime is intended for strategy sandboxes, education projects, procedural worlds, local visual tools, data-heavy dashboards, and interactive desktop apps.

### AI-assisted and agent-friendly

The project is designed to work well with human developers and coding agents:

- generated Markdown API reference
- generated LuaCATS stubs
- module specs
- examples for public APIs
- tests and smoke checks
- repeatable repository structure
- CAG skills, agents, and docs for implementation workflows

Runtime AI modules are a separate capability. They support gameplay behavior, simulations, local agents, automation, and learning experiments. They do not make the whole project an AI-only engine.

## Audience

| Audience | Message |
|---|---|
| Lua game developers | Build 2D desktop games in Lua with a broader built-in API than a minimal framework. |
| Simulation and strategy developers | Build procedural worlds, province maps, agent systems, pathfinding experiments, and visual simulations. |
| Tool builders | Use Lua plus rendering, UI, filesystem, data, graph, pipeline, and automation APIs for local interactive tools. |
| Education and hackathons | Use a simple scripting surface over a broad runtime for experiments, demos, and teaching. |
| AI-assisted workflows | Use generated API docs, stubs, specs, examples, and tests as reliable context for coding agents. |

## Competitive Frame

Lurek is closest to a programmable runtime between Love2D and editor-heavy engines.

| Compared with | Lurek difference |
|---|---|
| Love2D | Broader built-in API, generated stubs, specs, examples, and Rust-managed systems. |
| Godot or Unity | Code-first workflow, smaller mental model, no required visual editor. |
| GameMaker | API blocks are called from Lua instead of arranged through an IDE. |
| Pygame | Rust core, GPU rendering, Lua scripting, and a broader integrated runtime. |
| Bevy | Lua-first scripting surface over a Rust core instead of requiring Rust game code. |

## Strategic Decision

Use this mental model:

```text
Lurek = Rust runtime core + Lua API surface + generated docs + examples + specs + tooling
```

Use this information structure:

```text
README         -> first contact and project map
GitHub Pages   -> official public docs and API entry point
docs/api       -> generated API artifacts
docs/specs     -> contributor-facing technical contracts
docs/architecture -> design, strategy, positioning, and durable decisions
docs/wiki      -> generated cookbook, quick guides, and FAQ-style onboarding
content/examples -> runnable API examples
lurek_2d_content/games    -> larger reference games
```
