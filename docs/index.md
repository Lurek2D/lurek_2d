# Lurek2D Docs

Lurek2D documentation is split between user guides, generated API reference, and contributor-facing technical docs.

## Start Here

- [Guides](guides/index.md) for onboarding, first projects, examples, and recipes.
- [Module Guides](module-guides.md) for generated per-module overviews and API combinations.
- [Lua API Overview](lua-api.md) for how to navigate the generated `lurek.*` reference.
- [Contributing](contributing/index.md) for build, docs, specs, and contributor workflow entry points.

## Documentation Layers

| Layer | Use it for |
|---|---|
| [Guides](guides/index.md) | Learning the runtime, building a first project, and finding runnable examples. |
| [Module Guides](module-guides.md) | Choosing the right `lurek.*` namespace by capability. |
| [Full Lua API Reference](api/lurek.md) | Exact signatures, parameters, returns, and generated examples. |
| [Runtime callbacks](api/callbacks.md) | Entry points such as `lurek.init()`, `lurek.process(dt)`, and `lurek.draw()`. |
| [Contributor docs](contributing/index.md) | Build, docs flow, specs, testing, and source-of-truth ownership. |

## Source Of Truth

- Generated API and module pages should not be edited by hand.
- Fix user-facing API facts in `src/lua_api/`, regenerate docs, and update examples when behavior changes.
- Fix guide and contributor prose in `docs/`.
