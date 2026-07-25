# Contributor Docs

Contributor docs explain how the Rust core, Lua API, generated docs, examples, tests, and CAG workflow stay aligned. They are not the beginner path for users writing Lua games or local tools.

## Technical Sources Of Truth

| Area | Source | Role |
|---|---|---|
| Architecture | [../architecture/](../architecture/) | High-level design, lifecycle, state ownership, and durable constraints. |
| Specs | [../specs/README.md](../specs/README.md) | Generated module contracts and public API ownership. |
| API generation | [../architecture/docs-system.md](../architecture/docs-system.md) | Editable sources versus generated outputs. |
| Examples | [content/examples/README.md](https://github.com/Lurek2D/lurek_2d/blob/main/content/examples/README.md) | Runnable public API example ownership. |
| Tests | [tests/README.md](https://github.com/Lurek2D/lurek_2d/blob/main/tests/README.md) | Rust and Lua test placement. |

## Generated Outputs

Do not edit generated API, module, spec, or Pages output by hand. Update the owning source instead:

- Rust and Lua API doc comments for API facts.
- `docs/specs/manual/<module>.md` for module intent overlays.
- `content/examples/<module>.lua` for runnable examples.
- `docs/meta/modules.toml` for module metadata.
- `tools/docs/*` when generated page structure changes.

Then regenerate docs with the repository tools.

## Contributor Workflow Entry Points

- [Build and Distribution](build-and-distribution.md) for platform packaging, Linux delivery, and release-shape decisions.
- [Rust File Docstrings](rust-file-docstrings.md) for `//!` file-level documentation rules under `src/`.
- [CONTRIBUTING.md](https://github.com/Lurek2D/lurek_2d/blob/main/CONTRIBUTING.md) for repository-wide setup, quality gates, and pull request expectations.

## Project Layout For Contributors

| Path | Owner and purpose |
|---|---|
| `src/` | Rust engine modules and the Lua binding registration layer under `src/lua_api/`. |
| `content/` | Engine-owned Lua examples, layouts, and snippet sources; `content/examples/` owns one runnable example per public API. |
| `tests/` | Lua and Rust unit, integration, smoke, golden, and evidence tests. |
| `docs/` | Editable engine documentation: architecture, guides, contributor material, metadata, templates, specs, and generated API inputs. |
| `tools/` | Repository generators, validators, audit scripts, and developer automation. |
| `lurek_2d_content/` | Separate repository for finished Lua games, reusable Lua libraries, and game-design references. |
| `lurek_2d_extension/` | Separate repository for the VS Code extension. Do not create a root `extension/` folder. |
| `lurek_2d_pages/` | Separate repository for generated documentation pages. Do not edit generated output or create a root `pages/` folder. |
| `lurek_2d_workbench/` | Separate repository for the native Lurek Workbench application. |
| `work/` | Disposable local notes, reproductions, and validation evidence; never a durable source of truth. |
| `.codex/` | Local Codex agents, skills, routing, and CAG configuration. |

The root `AGENTS.md` is the concise repository contract. This table is the
human-facing map: use the owning directory's `AGENTS.md` before editing within
that area.

If you are trying to build your first Lurek2D project rather than contribute to the engine, start from [Guides](../guides/index.md).
