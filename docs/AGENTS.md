# Docs Contract

This file adds local rules for work under `docs/`.

## Mission
- Own repository docs, specs, contributor docs, and generated-doc policy.
- Keep the written contract aligned with the code contract.

## Scope
- `docs/specs/` module contracts and spec indexes.
- Contributor docs, how-tos, and architecture notes.
- Generated docs policy and drift resolution.

## Local map
- `specs/` is the main contract layer for module behavior.
- `architecture/` holds design doctrine, migration notes, and CAG system writeups.
- `api/` contains generated API artifacts; prefer changing generators or source docstrings instead of editing outputs.
- `templates/` contains the starter files for repo-local `AGENTS.md`, skills, prompts, specs, and system guidance.
- `modules/` and `wiki/` are documentation surfaces that often depend on generated inputs.
- `templates/` is for repeatable doc structure; reuse it before inventing a new prose shape.
- Root docs such as `callbacks.md`, `rust-api.md`, `snippets.md`, and `CHANGELOG.md` are topic indexes and reference surfaces, not replacements for per-module specs.

## Local rules
- Treat `docs/specs/` as canonical for documented contracts.
- Detect and resolve spec drift against code before expanding prose.
- Do not hand-edit generated API outputs.
- Keep docs concise, current, and tied to actual code behavior.
- Update indexes and contributor-facing docs when structure or workflow changes.
- Prefer specific file references over generic prose when describing behavior.
- Keep generated docs generation steps explicit.
- Keep one audience per section: contract and behavior detail for users, ownership and constraints for contributors.
- When Lua API docs drift, fix `src/lua_api/` docstrings and regenerate with `python tools/docs/gen_lua_api_data.py` and `python tools/docs/gen_luadoc.py`.
- When user-visible behavior changes, keep the spec, dependent docs, and runnable examples in sync in the same task.

## Workflow
- Read the production code and any affected spec before editing docs.
- Use the nearest nested docs contract and the relevant production source as the primary authority.
- Update the spec, then the index, then any user-facing docs that depend on it.
- If the change lands in `docs/specs/`, preserve the manual `Summary` and regenerate the structural sections instead of hand-patching them.
- Run the relevant doc or coverage check if the doc set has a validator.
- Run `python tools/audit/doc_coverage.py` after significant spec or documentation reshaping.

## Expected outputs
- Updated docs with drift resolved.
- Generator commands or coverage checks when relevant.
- Short, evidence-backed notes for anything still intentionally unresolved.

## Anti-patterns
- Write docs without verifying the code path first.
- Leave generated artifacts hand-edited.
- Expand prose when a spec update is the real fix.

## References
- `docs/specs/`
- `CONTRIBUTING.md`
- `README.md`
