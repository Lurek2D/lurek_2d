# Documentation System

## Purpose

Lurek2D has one public documentation surface: GitHub Pages. Repository documentation is split by ownership so generated facts, durable engineering decisions, and tutorials do not compete as sources of truth.

## Canonical editable sources

| Source | Owns |
|---|---|
| `src/**/*.rs` and `src/lua_api/**/*.rs` | Rust and Lua API facts, callable descriptions, and binding behavior. |
| `content/examples/*.lua` | Runnable examples and example ownership. |
| `tests/**/*.rs` and `tests/**/*.lua` | Proof and coverage facts. |
| `docs/meta/modules.toml` | Module paths, namespaces, tiers, examples, and test ownership. |
| `docs/specs/manual/*.md` | Hand-written module intent overlays. |
| `docs/architecture/*.md` | Current cross-module boundaries and durable constraints. |
| `docs/guides/*.md` and `docs/contributing/*.md` | Hand-written user and maintainer guidance. |

## Surface roles

- `README.md` is the repository landing page and first route into documentation.
- GitHub Pages publishes user guides, generated module guides, and generated API references.
- `docs/guides/` explains how to use Lurek2D without duplicating signatures.
- `docs/contributing/` explains build, quality, CAG, and authoring workflows.
- `docs/architecture/` records current system-level ownership and dependency constraints.
- `docs/specs/` is the contributor-facing generated contract layer.
- `docs/api/` contains generated Markdown and LuaCATS artifacts for users, editors, agents, and tooling.
- `docs/templates/` contains scaffolds for CAG artifacts and manual spec overlays; it is not public site content.
- `docs/assets/` and `docs/meta/modules.toml` are build inputs, not prose sections.

## Generated outputs

- `docs/specs/*.md`
- `docs/api/*.md` and `docs/api/*.lua`
- `docs/guides/module-guides.md`
- `lurek_2d_pages/.source/modules/*.md` and `.source/module-guides.md`
- `lurek_2d_pages/**` static site output
- `build/docs-data/**`, `logs/data/**`, and `logs/reports/**`

The repository does not maintain a separate Wiki export. Do not add a second hand-maintained API or onboarding surface.

## Change rules

1. Fix API facts in source docstrings, not generated reference files.
2. Fix module intent in `docs/specs/manual/`, not generated specs.
3. Fix examples and tests in their owning files, not in prose copies.
4. Keep architecture to current durable facts; use specs for per-module details and contributor guides for workflow.
5. When a route or generator changes, update MkDocs navigation, generator outputs, link checks, and source contracts together.

## Validation

- `tools/python.cmd tools/docs/gen_module_pages.py` regenerates the public module-guide indexes and pages.
- `tools/python.cmd tools/audit/docs_quality.py` validates document ownership, generated routes, and text links.
- `tools/python.cmd tools/audit/cag_link_check.py --strict` validates contracts and CAG references.
