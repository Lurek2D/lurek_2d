# Contributor Docs

Contributor docs explain how the Rust core, Lua API, generated docs, tests, and CAG workflow stay aligned. They are not the beginner path for users writing Lua games or tools.

## Technical Sources Of Truth

| Area | Source | Role |
|---|---|---|
| Architecture | [docs/architecture/](https://github.com/Lurek2D/lurek_2d/tree/main/docs/architecture) | High-level design, constraints, positioning, and docs strategy. |
| Specs | [docs/specs/README.md](https://github.com/Lurek2D/lurek_2d/blob/main/docs/specs/README.md) | Generated module contracts and public API ownership. |
| API generation | [docs/architecture/docs-system.md](https://github.com/Lurek2D/lurek_2d/blob/main/docs/architecture/docs-system.md) | Editable sources versus generated outputs. |
| Examples | [content/examples/README.md](https://github.com/Lurek2D/lurek_2d/blob/main/content/examples/README.md) | Runnable public API example ownership. |
| Tests | [tests/README.md](https://github.com/Lurek2D/lurek_2d/blob/main/tests/README.md) | Rust and Lua test placement. |

## Generated Outputs

Do not edit generated API, module, wiki, spec, or Pages output by hand. Update the owning source:

- Rust and Lua API doc comments for API facts.
- `docs/specs/manual/<module>.md` for module intent overlays.
- `content/examples/<module>.lua` for runnable examples.
- `docs/meta/modules.toml` for module metadata.
- `tools/docs/*` when generated page structure changes.

Then regenerate docs with the repo tools.
