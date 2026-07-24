# `docs/specs/` Module Specs

## TL;DR

- `docs/specs/*.md` files are generated output.
- Manual module intent lives in `docs/specs/manual/<module>.md`.
- Module metadata lives in `docs/meta/modules.toml`.
- Source API prose lives in Rust docstrings under `src/` and `src/lua_api/`.
- The full documentation flow is defined in [docs-system.md](../architecture/docs-system.md).

## How specs are produced

The docs flow is one-way:

```text
canonical sources -> generated data -> manual overlays -> generated presentation -> reports/gates
```

Editable inputs:

- `src/**/*.rs`
- `src/lua_api/**/*.rs`
- `content/examples/*.lua`
- `tests/**/*.lua`
- `tests/**/*.rs`
- `docs/meta/modules.toml`
- `docs/specs/manual/*.md`
- `docs/architecture/*.md`

Generated outputs:

- `docs/specs/*.md`
- `lurek_2d_pages/.source/modules/*.md` (temporary Pages build input)
- `docs/api/*.md`
- `docs/api/*.lua`
- `docs/wiki/*.md`
- `build/docs-data/**`
- `logs/data/**`
- `logs/reports/**`

Do not copy generated spec prose back into Rust docstrings. If API docs are wrong, fix source docstrings. If high-level module intent is wrong, fix the matching manual overlay.

## Commands

- `tools/python.cmd tools/docs/module_registry.py list` lists modules from `docs/meta/modules.toml`.
- `tools/python.cmd tools/docs/gen_module_specs.py` regenerates specs from source facts and overlays.
- `tools/python.cmd tools/gen_all_docs.py` regenerates the full docs pipeline.
- `tools/python.cmd tools/docs/check_freshness.py` fails when generated docs are stale.
- `tools/python.cmd tools/audit/docs_quality.py` checks generated headers, overlays, orphan specs, coverage data, and dead architecture links.

## Manual Overlay Format

Each overlay may contain:

```md
# render manual spec overlay

## TL;DR

- Short durable points.

## Summary

High-level intent and boundaries.

## Notes

- Durable notes only.

## Architecture Links

- docs/architecture/render-pipeline.md
```

Keep API lists, parameters, examples, tests, and file inventories out of overlays. Those sections are generated.
