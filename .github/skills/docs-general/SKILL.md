---
name: docs-general
description: "Load this skill when writing or updating docs, READMEs, tutorials, API reference, or code comments. Skip it for code changes."
---
# docs-general

## Mission
- Own doc style, source checks, generated-doc rules, and user-facing clarity.

## When To Load
- Update docs/.
- Update README.md or CONTRIBUTING.md.
- Write tutorials or API docs.
- Add code comments for complex logic.

## When To Skip
- Engine code changes.
- CAG file work.
- API design decisions.

## Domain Knowledge
- `docs/api/lurek.md` and `docs/api/lurek.lua` are generated â€” never hand-edit them. Fix errors in `src/lua_api/<module>_api.rs` Rust docstrings, then regenerate: `tools/python.cmd tools/docs/gen_lua_api_data.py` then `tools/python.cmd tools/docs/gen_luadoc.py`.
- Docs have a clear hierarchy: `docs/specs/<module>.md` is the canonical module contract. `wiki/` pages are task-oriented guides for game authors.
- `docs/specs/README.md` lists all existing spec files. When adding a new module spec, add a row.
- Write for one audience per section: game authors need what a function does, what arguments it accepts, and what happens on error. Engine contributors need ownership, constraints, and architectural intent.
- When code changes affect user-visible behavior, cross-artifact sync is required in the same commit: spec, wiki, and examples. A code change with no doc update is not complete.
- Keep examples in docs runnable. If an example calls `lurek.sprite.draw(...)`, that call must work in the current engine version.
- `docs/architecture/` files are the source of truth for system-level decisions. Do not write architecture decisions in specs or wikis â€” write them in `docs/architecture/`, then reference from specs.
- `CONTRIBUTING.md` and `docs/architecture/developer-workflow.md` cover contributor workflow, build steps, and quality gates. When onboarding steps or quality gates change, update both.
- Run `tools/python.cmd tools/audit/doc_coverage.py` after significant spec or doc changes to confirm coverage did not regress. The tool reports which modules have missing or thin spec files.
## Companion File Index
- None.

## References
- docs/specs/
- docs/specs/lua-api-file-standard.md
- docs/api/lurek.md
- tools/docs/gen_lua_api_data.py
- tools/docs/gen_luadoc.py
