# Lua API Overview

The public scripting surface lives under `lurek.*`. Generated docs and stubs are the source of truth for user-facing signatures and examples.

## Official API Entry Points

| Artifact | Purpose |
|---|---|
| [Full Lua API Reference](api/lurek.md) | Complete generated Markdown reference for `lurek.*`. |
| [Runtime callbacks](api/callbacks.md) | Functions the runtime calls, such as `lurek.process(dt)` and `lurek.draw()`. |
| [LuaCATS stub](https://github.com/Lurek2D/lurek_2d/blob/main/docs/api/lurek.lua) | Editor and tooling declarations for completions, hover text, and agents. |
| [Lureksome API](api/lureksome.md) | Generated docs for pure-Lua libraries under `lurek_2d_content/library/`. |

## How To Read The API

- Start with [Guides](guides/index.md) if you are new to the runtime.
- Use [Module Guides](module-guides.md) to choose a namespace.
- Use [Full Lua API Reference](api/lurek.md) for exact signatures and return values.
- Use [Examples](guides/examples.md) when you want runnable code first.
- Use `docs/api/lurek.lua` in your editor for IntelliSense.

## Editor Stub

`docs/api/lurek.lua` is generated from the same API data as the Markdown reference. Add that file to your Lua language server workspace library so your editor sees the `lurek.*` namespace.

Do not edit the generated stub directly. If documentation or signatures are wrong, fix the source binding annotations and regenerate docs.

## User-Facing And Contributor-Facing API

- User-facing Lua APIs are documented here and in the generated GitHub Pages module guides.
- Rust internals and module contracts belong to [Contributor Docs](contributing/index.md), `docs/specs/`, and `docs/architecture/`.
