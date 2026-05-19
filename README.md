<p align="center">
  <img src="assets/splash.png" alt="Lurek2D" width="720" />
</p>

<p align="center">
        <strong>A small desktop 2D runtime for Lua games.</strong> Rust core - Lua scripting - GPU rendering - AI-first tooling.
</p>

---

## Is this repo for you?

- **Yes, if** you want to build 2D desktop games in **Lua** and have the heavy systems (render/audio/physics/IO) handled by **Rust**.
- **Yes, if** you value fast prototyping, moddability, and a clean API under `lurek.*`.
- **Yes, if** you want docs, tests, examples, reference games, and AI workflow tooling in one repo.
- **Probably not**, if you need a mobile/web-first engine or an all-in-one closed editor.

## TL;DR

- **What it is:** a desktop 2D runtime for Lua games.
- **Model:** Rust owns systems, Lua owns game logic.
- **Scope:** rendering, audio, input, physics, scene/tilemap/sprite/tween, save, networking, tooling.
- **Repo contents:** engine + API docs + examples + reference games + Lua libraries + extension tooling.
- **Details:** the GitHub wiki overview lives at [Lurek2D Wiki](https://github.com/LurekDude/lurek_2d/wiki).

## Lurek Is...

| Value | What it means |
|---|---|
| 🧩 **Simple** | Write `main.lua`, call `lurek.*`, and keep gameplay logic in Lua. |
| 🛠️ **Feature rich** | Rendering, audio, input, physics, scene, tilemap, sprite, tween, save, networking, tooling, and more. |
| ⚡ **Fast** | Rust core, queued GPU rendering, and desktop-focused runtime architecture. |
| 🆓 **Free** | MIT-licensed engine, examples, libraries, docs, and tools. |
| 📦 **Portable** | Single-binary runtime, runnable examples, reference games, and optional VS Code tooling in one repo. |
| 🔌 **Extensible** | Pure-Lua libraries, mod hooks, plugins, and AI-assisted workflows. |
| 🌍 **Cross Platform** | Cross-platform desktop targets with separate engine/runtime and tooling layers. |

## For Engine Developers

These links are for people extending the Rust engine, bindings, tooling, docs, tests, and release flow.

| Area | Link | Why it matters |
|---|---|---|
| Philosophy and constraints | [docs/architecture/philosophy.md](docs/architecture/philosophy.md) | Source of truth for architecture rules, platform scope, and binding constraints. |
| Engine architecture | [docs/architecture/engine-architecture.md](docs/architecture/engine-architecture.md) | Module groups, runtime composition, boot flow, and dependency direction. |
| CAG and AI workflow | [docs/architecture/cag-system.md](docs/architecture/cag-system.md) | How AI-assisted engine work is structured in the main repository. |
| VS Code extension architecture | [docs/architecture/vscode-architecture.md](docs/architecture/vscode-architecture.md) | How the extension, debug bridge, MCP, and webview tooling fit together. |
| Rust API reference | [docs/api/rust.md](docs/api/rust.md) | Generated contributor-facing Rust API surface. |
| Specs index | [docs/specs/README.md](docs/specs/README.md) | Canonical module-by-module contract list. |
| Build, onboarding, and contribution | [docs/handbook.md](docs/handbook.md) · [CONTRIBUTING.md](CONTRIBUTING.md) | First setup, quality gates, contribution rules, and engine workflow. |
| Tests and quality gates | [tests/README.md](tests/README.md) · [docs/architecture/test-framework.md](docs/architecture/test-framework.md) | Rust/Lua test model and the Lua-first placement rules. |
| AI-assisted engine work in practice | [extensions/vscode/README.md](extensions/vscode/README.md) · [.github/agents/README.md](.github/agents/README.md) | Extension capabilities, local AI workflow, and the engine-side agent roster. |

## For Game Developers

These links are for people making Lua games with Lurek, not changing engine internals.

| Area | Link | Why it matters |
|---|---|---|
| GitHub wiki home | [Lurek2D Wiki](https://github.com/LurekDude/lurek_2d/wiki) | Main game-dev landing page in the GitHub wiki. |
| Getting started | [Getting Started](https://github.com/LurekDude/lurek_2d/wiki/Getting-Started) | Fast orientation from an empty folder to a runnable game. |
| First game | [First Game](https://github.com/LurekDude/lurek_2d/wiki/First-Game) | Minimal `main.lua` example and next steps. |
| Lua API reference | [docs/api/lurek.md](docs/api/lurek.md) | Full public `lurek.*` API surface. |
| Modules map | [Modules](https://github.com/LurekDude/lurek_2d/wiki/Modules) | Browse the engine surface by module and namespace. |
| Examples | [content/examples/README.md](content/examples/README.md) · [Examples wiki](https://github.com/LurekDude/lurek_2d/wiki/Examples) | Single-file examples and example-browser view. |
| Reference games and demos | [content/games/README.md](content/games/README.md) · [Reference Games wiki](https://github.com/LurekDude/lurek_2d/wiki/Reference-Games) | Larger playable projects and demo-style samples. |
| Pure-Lua libraries | [docs/api/lureksome.lua](docs/api/lureksome.lua) · [Lureksome wiki](https://github.com/LurekDude/lurek_2d/wiki/Lureksome) | Reusable pure-Lua gameplay modules built on top of `lurek.*`. |
| VS Code + IntelliSense | [extensions/vscode/README.md](extensions/vscode/README.md) | IntelliSense, run/debug flow, asset helpers, and extension-side tooling. |
| AI-assisted game development | [extensions/vscode/cag/game-dev/README.md](extensions/vscode/cag/game-dev/README.md) | Local AI workflow layer for people making games with Lurek. |

## Ways To Work With Lurek

Lurek does not force one workflow. You can mix engine work, Lua game work, VS Code tooling, local AI, and pure-Lua libraries.

| Workflow | What it looks like | Main links |
|---|---|---|
| Engine only | Rust + Cargo + docs, no extension required | [docs/handbook.md](docs/handbook.md) · [docs/architecture/engine-architecture.md](docs/architecture/engine-architecture.md) |
| Engine + VS Code | Engine work with tasks, debug bridge, editor tooling, and extension integration | [extensions/vscode/README.md](extensions/vscode/README.md) · [docs/architecture/vscode-architecture.md](docs/architecture/vscode-architecture.md) |
| Engine + local AI | Main repo CAG, local agents, prompts, validators, and MCP-assisted workflow | [docs/architecture/cag-system.md](docs/architecture/cag-system.md) · [.github/agents/README.md](.github/agents/README.md) |
| Lua game scripts only | `main.lua`, `conf.lua`, `assets/`, examples, and the public `lurek.*` API | [docs/api/lurek.md](docs/api/lurek.md) · [Getting Started](https://github.com/LurekDude/lurek_2d/wiki/Getting-Started) |
| Lua game scripts + VS Code IntelliSense | Lua authoring with hover docs, completions, commands, and debug flow | [extensions/vscode/README.md](extensions/vscode/README.md) |
| Lua game scripts + local AI | Game-dev CAG layer for agents, prompts, templates, and task workflows | [extensions/vscode/cag/game-dev/README.md](extensions/vscode/cag/game-dev/README.md) |
| Built-in editors and tools | Tilemap, particle, audio, UI, preview, and other extension webviews | [extensions/vscode/README.md](extensions/vscode/README.md) |
| Pure-Lua libraries (Lureksome) | Reusable Lua modules in `library/`, built without touching engine Rust code | [docs/api/lureksome.lua](docs/api/lureksome.lua) · [tests/lua/library/README.md](tests/lua/library/README.md) |

## Use Cases

Lurek fits best where a 2D desktop runtime, Lua scripting, and AI-assisted workflow matter more than a monolithic editor.

| Use case | Why Lurek fits |
|---|---|
| Education | Good for teaching Lua gameplay code, engine boundaries, tests, and architecture in one repo. |
| Game jams | Fast path from empty folder to `main.lua`, examples, templates, and playable demos. |
| Indie 2D desktop games | Rendering, audio, input, physics, save, UI, and tooling are already present. |
| Hackathons and prototypes | Short setup path, lots of examples, and Lua-first iteration speed. |
| Demo scene and experiments | Rendering, postfx, raycaster, globe, light, and compute modules support visual showcases. |
| Small local tools and apps | UI, HTML, serialisation, filesystem, and runtime scripting support utility-style apps. |
| Simulation and strategy sandboxes | Province, globe, procgen, graph, dataframe, and AI modules support systems-heavy work. |
| Local compute-heavy experiments | `compute`, `dataframe`, `serial`, `procgen`, and visualisation modules work well for local runs. |
| Moddable Lua systems | Public `lurek.*` API plus pure-Lua libraries make it natural to expose systems to scripts. |

## Ideas And Future Directions

The [ideas tree](https://github.com/LurekDude/lurek_2d/tree/main/ideas) is where future directions, experiments, and longer-horizon plans already live.

| Area | Link | Why it matters |
|---|---|---|
| Ideas root | [ideas/](https://github.com/LurekDude/lurek_2d/tree/main/ideas) | Central backlog of experiments, architecture notes, and future directions. |
| Runtime modes | [ideas/runtime-modes-plan.md](ideas/runtime-modes-plan.md) | Shows how runtime variants can evolve beyond the current flow. |
| Province economy loop | [ideas/province-economy-loop.md](ideas/province-economy-loop.md) | Good example of systems-heavy game design direction inside the repo. |
| Linux build and distribution | [ideas/linux-build-and-distribution-guide.md](ideas/linux-build-and-distribution-guide.md) | Platform packaging direction beyond the current default Windows flow. |
| Rust ideas | [ideas/rust/](https://github.com/LurekDude/lurek_2d/tree/main/ideas/rust) | Engine-facing ideas and implementation notes. |
| Simulation ideas | [ideas/simulation/](https://github.com/LurekDude/lurek_2d/tree/main/ideas/simulation) | Simulation-heavy directions and subsystem sketches. |
| Plugin and extension ideas | [ideas/plugins/](https://github.com/LurekDude/lurek_2d/tree/main/ideas/plugins) · [ideas/extension/](https://github.com/LurekDude/lurek_2d/tree/main/ideas/extension) | Future plugin and editor/tooling directions. |

If you want to contribute to the future shape of Lurek, start from an idea, turn it into a spec, example, demo, test, or implementation slice, then follow [docs/handbook.md](docs/handbook.md) and [CONTRIBUTING.md](CONTRIBUTING.md).

---

[Contributing](CONTRIBUTING.md) - [Security](SECURITY.md) - [License](LICENSE)



