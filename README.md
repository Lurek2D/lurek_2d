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
- **Details:** the full project reference now lives in [wiki/Project-Reference.md](wiki/Project-Reference.md).

## Lurek Is...

| Value | What it means |
|---|---|
| 🧩 **Simple** | Write `main.lua`, call `lurek.*`, and keep gameplay logic in Lua. |
| 🛠️ **Feature rich** | Rendering, audio, input, physics, scene, tilemap, sprite, tween, save, networking, tooling, and more. |
| ⚡ **Fast** | Rust core, queued GPU rendering, and desktop-focused runtime architecture. |
| 🆓 **Free** | MIT-licensed engine, examples, libraries, docs, and tools. |
| 📦 **Portable** | Single-binary runtime, runnable examples, reference games, and optional VS Code tooling in one repo. |
| 🔌 **Extensible** | Pure-Lua libraries, mod hooks, plugins, and AI-assisted workflows. |
| 🌍 **CrossPlatform** | Cross-platform desktop targets with separate engine/runtime and tooling layers. |

## Start Here

| Topic | Link |
|---|---|
| Wiki home | [wiki/Home.md](wiki/Home.md) |
| Detailed project reference | [wiki/Project-Reference.md](wiki/Project-Reference.md) |
| Lua API reference | [docs/api/lurek.md](docs/api/lurek.md) |
| Rust API reference | [docs/api/rust.md](docs/api/rust.md) |
| Library API reference | [docs/api/library.md](docs/api/library.md) |
| Architecture docs | [docs/architecture/README.md](docs/architecture/README.md) |
| Module specs | [docs/specs/README.md](docs/specs/README.md) |
| Contributor handbook | [docs/handbook.md](docs/handbook.md) |
| Changelog | [docs/CHANGELOG.md](docs/CHANGELOG.md) |

## Repository Areas

| Area | Link | Purpose |
|---|---|---|
| Engine source | [src/README.md](src/README.md) | Rust runtime modules and engine code. |
| Examples | [content/examples/](content/examples/) | Single-file API examples. |
| Reference games | [content/games/README.md](content/games/README.md) | Playable multi-file demos and games. |
| Lua libraries | [library/README.md](library/README.md) | Reusable pure-Lua gameplay modules. |
| VS Code extension | [extensions/vscode/README.md](extensions/vscode/README.md) | IntelliSense, MCP tooling, and AI workflow support. |
| Tests | [tests/](tests/) | Rust and Lua coverage. |
| Tools | [tools/](tools/) | Generators, validators, audits, and dev scripts. |
| CAG system | [docs/architecture/cag-system.md](docs/architecture/cag-system.md) | Agent, skill, and prompt workflow design. |

## Detailed Project Topics

| Topic | Link |
|---|---|
| Architecture overview | [wiki/Project-Reference.md#architecture-overview](wiki/Project-Reference.md#architecture-overview) |
| Runtime modules | [wiki/Project-Reference.md#runtime-modules-described](wiki/Project-Reference.md#runtime-modules-described) |
| Full Lua API surface | [wiki/Project-Reference.md#full-lua-api-surface](wiki/Project-Reference.md#full-lua-api-surface) |
| Example games categories | [wiki/Project-Reference.md#example-games-categories](wiki/Project-Reference.md#example-games-categories) |
| Use cases | [wiki/Project-Reference.md#use-cases-where-to-use-lurek2d](wiki/Project-Reference.md#use-cases-where-to-use-lurek2d) |
| AI-first engineering | [wiki/Project-Reference.md#ai-first-engineering-how-ai-is-used](wiki/Project-Reference.md#ai-first-engineering-how-ai-is-used) |
| What ships | [wiki/Project-Reference.md#what-ships](wiki/Project-Reference.md#what-ships) |
| Tech stack | [wiki/Project-Reference.md#tech-stack](wiki/Project-Reference.md#tech-stack) |
| Project identity | [wiki/Project-Reference.md#project-identity](wiki/Project-Reference.md#project-identity) |
| License and dependency licenses | [wiki/Project-Reference.md#license](wiki/Project-Reference.md#license) |

---

[Contributing](CONTRIBUTING.md) - [Security](SECURITY.md) - [License](LICENSE)



