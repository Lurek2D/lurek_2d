---
inclusion: manual
---

# documentation

## Mission
Own doc style, source checks, generated-doc rules, and user-facing clarity.

## When To Use
- Update `docs/`, README.md, or `CONTRIBUTING.md`.
- Write tutorials or API docs.
- Add code comments for complex logic.

## When To Skip
- Engine code changes, CAG file work, API design decisions.

## Rules

### Generated Files — Never Hand-Edit
`docs/api/lurek.md` and `docs/api/lurek.lua` are generated. Fix errors in `src/lua_api/<module>_api.rs` Rust docstrings, then regenerate:
- `python tools/docs/gen_lua_api_data.py`
- `python tools/docs/gen_luadoc.py`
- Full pipeline: `python tools/gen_all_docs.py`

### Docs Hierarchy
- `docs/specs/<module>.md` — canonical module contract.
- `wiki/` — task-oriented guides for game authors.
- `docs/handbook.md` — contributor workflow.
- `docs/architecture/` — high-level system design.
Never duplicate content across tiers — link instead.

### docs/specs/README.md
Lists all existing spec files. Add a row when adding a new module spec. Update the row when removing or renaming. A spec file with no row is an orphan.

### Audience Separation
Game authors need what a function does, what arguments it accepts, and what happens on error. Engine contributors need ownership, constraints, and architectural intent. Do not mix both in the same paragraph.

### Changelog Entries
Must follow commit type prefix: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`. Every commit adds or extends the current version block in `docs/CHANGELOG.md`. MAJOR and MINOR bumps also update `Cargo.toml`.

### Keep Examples Runnable
If an example calls `lurek.sprite.draw(...)`, that call must work in the current engine version. Stale examples are worse than no examples.

### Cross-Artifact Sync
When code changes affect user-visible behavior, update spec, wiki, examples, and changelog in the same commit. A code change with no doc update is not complete.

### Architecture Decisions
Write them in `docs/architecture/`, then reference from specs. Do not write architecture decisions in specs or wikis.

### After Significant Changes
Run `python tools/audit/doc_coverage.py` to confirm coverage did not regress.

## References
- `docs/specs/`
- `docs/specs/lua-api-file-standard.md`
- `docs/api/lurek.md`
- `tools/docs/gen_lua_api_data.py`
- `tools/docs/gen_luadoc.py`
