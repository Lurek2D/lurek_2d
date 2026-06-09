# Library Contract

Covers work under `library/`.

## Mission
- Own reusable Lua modules and module-package style content.
- Keep modules easy to import, document, and test.

## Scope
- `library/*/init.lua` modules.
- Supporting examples, docs, tests, and packaging files.

## Local map
- Each top-level folder is a reusable package domain.
- `README.md` is the local index.
- `init.lua` is usually the package entrypoint.
- Demo-specific behavior belongs under `content/`.

## Rules
- Keep `init.lua`, examples, docs, and tests aligned.
- Prefer reusable Lua patterns over demo-only scripts.
- Keep library modules grounded in accepted `lurek.*` contracts.
- Keep package entry points small and obvious.
- Avoid hacks that only work in one demo.
- Each library module should keep `init.lua`, `example.lua`, and `README.md`.
- Library code stays pure Lua.
- After public library API changes, regenerate `docs/api/lureksome.md` and `docs/api/lureksome.lua` with `python tools/docs/gen_lib_docs.py`.

## Workflow
- Read the public API shape and nearest examples before editing a module.
- Use this file, the matching example, and the nearest Lua test or example contract as the source of truth.
- Update the module, its example, and the docs together.
- Validate with the narrowest runnable proof that exercises the module contract.

## References
- `content/examples/`
- `tests/lua/`
- `docs/specs/`
