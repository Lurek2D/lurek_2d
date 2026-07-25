# Documentation System

## Decision

GitHub Pages is the single public documentation surface. The root `README.md` is the repository landing page; durable prose and generator inputs remain in this workspace.

## Ownership

| Surface | Owner | Audience |
|---|---|---|
| `docs/guides/` | Hand-written user guidance | Lua users |
| `docs/api/` | Generated from Rust and Lua binding documentation | Users, editors, tooling |
| `docs/specs/` | Generated facts plus manual overlays | Contributors and agents |
| `docs/architecture/` | Durable boundaries and accepted decisions | Maintainers |
| `docs/contributing/` | Contributor workflows and policies | Contributors |
| `docs/meta/modules.toml` | Module names, paths, tiers, examples, and tests | Generators and audits |
| `docs/templates/` | Copyable CAG and spec-overlay scaffolds | Contributors |

`docs/assets/` contains the logo and CSS consumed by `mkdocs.yml`. It is site input, not general media storage.

## Source Flow

```text
Rust docs + Lua binding docs + examples + tests + modules.toml + manual overlays
    -> generated data
    -> specs, API references, module pages
    -> MkDocs staging
    -> lurek_2d_pages/
```

Generated API and spec files are never edited directly. Wrong signatures or descriptions are fixed in source documentation; wrong module intent is fixed in `docs/specs/manual/`; wrong ownership metadata is fixed in `docs/meta/modules.toml`.

## Publication Rules

- Pages navigation follows `Start -> First Game -> Lua API -> Module Guides -> Examples`.
- Guides link to the canonical API instead of copying signatures.
- Architecture documents contain current facts; proposed changes live under `proposals/`.
- Generators must be deterministic and a second run must produce no diff.
- Structural changes require strict local-link, UTF-8, freshness, and MkDocs checks.

## Failure And Recovery

- A generator failure leaves its source inputs authoritative; partial output is not published.
- A stale generated page is repaired through its upstream owner and regenerated.
- A broken route is treated as a public contract regression.
- Deployment output under `lurek_2d_pages/` can be rebuilt from workspace sources and must not become the only copy of durable prose.
