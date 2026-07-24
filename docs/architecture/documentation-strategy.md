# Documentation Strategy

## Decision

Lurek2D uses one public documentation path and several repo-owned technical sources of truth.

GitHub Pages is the official public documentation for users. The root README is a landing page and map. The generated Wiki is a cookbook and onboarding layer. `docs/api`, `docs/specs`, and `docs/architecture` keep their existing source-of-truth roles.

## Roles

| Surface | Role | Audience | Source of truth |
|---|---|---|---|
| `README.md` | First contact and repository map | New visitors, users, contributors | Hand-written root document |
| GitHub Pages | Main public docs | Lua users building games, simulations, tools, and apps | `docs/` source plus generated API/module pages |
| `docs/api/` | Generated API artifacts | Users, editors, agents, tooling | Source binding annotations and docs generators |
| `docs/modules/` | Generated module guides and callable details | Users choosing and applying modules | `docs/specs`, `docs/api/lurek.lua`, and `content/examples` |
| `docs/specs/` | Technical module contracts | Contributors and AI/tooling workflows | Generated from source facts plus manual overlays |
| `docs/architecture/` | Design constraints, strategy, and positioning | Contributors and maintainers | Hand-written architecture docs |
| `docs/wiki/` | Generated cookbook, quick guides, FAQ-style onboarding | Users who prefer Wiki-style navigation | `tools/docs/gen_wiki.py` and generated docs data |
| `content/examples/` | Runnable API examples | Users, tests, docs, agents | Example files and coverage audit |
| `lurek_2d_content/games/` | Larger playable demos | Users evaluating complete projects | Game folders and generated catalog |

## Rules

- README should answer what Lurek is, who it is for, where to start, and where the source-of-truth docs live.
- Pages should provide the path `Getting Started -> First Game -> Lua API -> Examples`.
- Full `lurek.*` API reference belongs in generated API docs and Pages, not the Wiki.
- Wiki should remain friendly and lightweight: cookbook, quick guide, FAQ, examples, and troubleshooting.
- Specs and architecture are contributor-facing. Link them from user docs, but do not make them the beginner path.
- Generated outputs should not be edited by hand.

## User Path

```text
README
  -> GitHub Pages
      -> Getting Started
      -> First Game
      -> Lua API Overview
      -> Full Lua API Reference
      -> Examples
      -> Module Guides
```

## Contributor Path

```text
README
  -> Contributor Docs
      -> docs/architecture
      -> docs/specs
      -> docs/meta/modules.toml
      -> tools/docs
      -> tests and validation tools
```

## API Publication

The official API entry is GitHub Pages -> Lua API.

The generated artifacts are:

- `docs/api/lurek.md` for the full Markdown reference
- `docs/api/lurek.lua` for editor and tooling stubs
- `docs/api/callbacks.md` for runtime callbacks
- `docs/api/lureksome.md` and `docs/api/lureksome.lua` for pure-Lua libraries

`docs/api/rust.md` is contributor-facing and should not be the first API link for Lua users.

## Wiki Policy

The Wiki may contain:

- Home
- Getting Started
- First Game
- Project Structure
- Common recipes
- Examples and reference-game links
- FAQ and troubleshooting
- Project philosophy summary

The Wiki must not contain:

- a copied full `docs/api/lurek.md`
- a second full callable reference
- copied `docs/specs` content
- hand-maintained API text that must stay perfectly synchronized with generated docs

## Positioning Language

Use:

- Lua-first 2D runtime and toolkit
- programmable 2D runtime for games, simulations, and tools
- Rust-powered Lua runtime
- AI-assisted
- agent-friendly
- AI/tooling-friendly

Avoid:

- undefined AI headlines
- AI game engine as the main product promise
- Unity replacement
- Godot replacement
- narrow "just another 2D engine" framing
