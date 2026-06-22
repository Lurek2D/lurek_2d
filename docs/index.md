# Lurek2D Documentation

Lurek2D is a Lua-first 2D runtime and toolkit for games, simulations, visual tools, and interactive desktop apps.

Use these docs when you want to write Lua that calls the public `lurek.*` API. Contributor-facing contracts, specs, and architecture notes still live in the repository, but this site is the main public entry point.

## Start Here

1. [Getting Started](getting-started.md) - install, run, and understand the project shape.
2. [First Game](first-game.md) - create a minimal `main.lua`.
3. [Lua API Overview](lua-api.md) - learn how the generated API docs and stubs work.
4. [Examples](examples.md) - find runnable examples by API area.
5. [Module Guides](module-guides.md) - choose the right `lurek.*` module.

## Main Documentation

| Area | Go here when you need |
|---|---|
| [Getting Started](getting-started.md) | First commands and folder structure. |
| [First Game](first-game.md) | A small working Lua script. |
| [Lua API Overview](lua-api.md) | The map for generated API docs and editor stubs. |
| [Full Lua API Reference](api/lurek.md) | Complete signatures, parameters, returns, and examples. |
| [Module Guides](module-guides.md) | Purpose, common use cases, and examples for key modules. |
| [Examples](examples.md) | Runnable one-file API examples. |
| [Reference Games](reference-games.md) | Larger playable projects. |
| [Recipes](recipes.md) | Short task-oriented paths through the docs. |
| [Contributor Docs](contributors.md) | Architecture, specs, and docs-system links for engine work. |

## What Lurek Is

- Code-first: write Lua, call `lurek.*`, run the runtime.
- Rust-powered: rendering, audio, input, physics, files, and runtime services live in the Rust core.
- Broad by design: games are a major use case, but the same runtime also supports simulations, visual tools, automation, data views, and educational apps.
- AI-assisted and agent-friendly: generated docs, stubs, examples, tests, and specs make the API easier to use from human and coding-agent workflows.

## Documentation Roles

- GitHub Pages is the official public documentation.
- `docs/api/` contains generated API artifacts.
- `docs/modules/` contains generated module pages.
- `docs/specs/` and `docs/architecture/` are contributor-facing technical sources of truth.
- The generated Wiki is a cookbook and onboarding layer, not a second API reference.
