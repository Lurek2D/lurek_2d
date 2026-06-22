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

## Generated outputs

- `docs/specs/*.md`
- `docs/api/*.md`
- `docs/api/*.lua`
- `docs/modules/*.md`
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
