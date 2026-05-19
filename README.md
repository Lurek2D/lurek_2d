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

## Start Here

- [Wiki home](https://github.com/LurekDude/lurek_2d/wiki) — GitHub wiki landing page from the separate wiki repository.
- [Getting started wiki](https://github.com/LurekDude/lurek_2d/wiki/Getting-Started) — first steps, orientation, and initial commands.
- [Lurek API reference](docs/api/lurek.md) — full public `lurek.*` API surface.
- [Rust API reference](docs/api/rust.md) — engine internals for contributors.
- [Library API reference](docs/api/library.md) — generated reference for the pure-Lua libraries.
- [Philosophy](docs/architecture/philosophy.md) — core rules, constraints, and design assumptions.
- [Architecture index](docs/architecture/README.md) — navigation across all architecture files.
- [Module specs index](docs/specs/README.md) — canonical per-module contract index.
- [Contributor handbook](docs/handbook.md) — onboarding, build/run flow, docs workflow, and quality gates.
- [Changelog](docs/CHANGELOG.md) — current project history.

## Project Guides

- [Examples guide](content/examples/README.md) — how to use the single-file API examples under `content/examples/`.
- [GitHub wiki modules](https://github.com/LurekDude/lurek_2d/wiki/Modules) — generated module navigation in the separate wiki repository.
- [Library API reference](docs/api/library.md) — public surface of the bundled pure-Lua libraries.
- [Test suite overview](tests/README.md) — Rust/Lua test layout, commands, and coverage rules.
- [VS Code toolkit](extensions/vscode/README.md) — extension features, installation, and editor workflow.
- [CAG system](docs/architecture/cag-system.md) — agent, skill, prompt, and validator model for AI-assisted work.

## Architecture Files

- [Architecture index](docs/architecture/README.md) — reading order and cross-links for the architecture set.
- [Philosophy](docs/architecture/philosophy.md) — constraints, design doctrine, and source-of-truth rules.
- [Engine architecture](docs/architecture/engine-architecture.md) — module groups, runtime composition, boot, and frame model.
- [Render command architecture](docs/architecture/render-command-architecture.md) — draw-command flow and renderer structure.
- [Test framework](docs/architecture/test-framework.md) — Lua-first test strategy and test placement rules.
- [VS Code architecture](docs/architecture/vscode-architecture.md) — extension services, debug bridge, and MCP integration.
- [CAG system](docs/architecture/cag-system.md) — agent graph file types, routing, and validator rules.
- [Lua API file standard](docs/architecture/lua-api-file-standard.md) — conventions for `src/lua_api/*_api.rs`.
- [Plugins](docs/architecture/plugins.md) — plugin boundary and future split strategy.
- [TOGAF mapping](docs/architecture/togaf.md) — TOGAF-oriented architecture view of the repo.

---

[Contributing](CONTRIBUTING.md) - [Security](SECURITY.md) - [License](LICENSE)



