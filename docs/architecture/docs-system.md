# Documentation System

## Canonical editable sources

- `src/**/*.rs`
- `src/lua_api/**/*.rs`
- `content/examples/*.lua`
- `tests/**/*.lua`
- `tests/**/*.rs`
- `docs/meta/modules.toml`
- `docs/specs/manual/*.md`
- `docs/architecture/*.md`

## Surface roles

- `README.md` is the first-contact landing page and repository map.
- GitHub Pages is the official public documentation for users.
- `docs/api/` contains generated API artifacts for Pages, editors, agents, and tooling.
- GitHub Pages contains generated human-readable module guides plus callable details.
- `docs/specs/` contains contributor-facing generated module contracts.
- `docs/architecture/` contains contributor-facing design constraints, strategy, positioning, and durable decisions.
- `docs/wiki/` is a generated cookbook/onboarding layer, not a second full API reference.

## Generated outputs

- `docs/specs/*.md`
- `docs/api/*.md`
- `docs/api/*.lua`
- `lurek_2d_pages/.source/modules/*.md` (temporary Pages build input)
- `docs/wiki/*.md`
- `pages/**`
- `build/docs-data/**`
- `logs/data/**`
- `logs/reports/**`

## Rules

- Do not edit generated outputs directly.
- Fix source docstrings if API docs are wrong.
- Fix `docs/specs/manual/<module>.md` if high-level module intent is wrong.
- Fix examples in `content/examples/` if example coverage or snippets are wrong.
- Fix tests if coverage or proof status is wrong.
- Never copy generated spec prose back into source docstrings.
