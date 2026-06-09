# Library Contract

This file adds local rules for work under `library/`.

## Mission
- Own reusable Lua modules and module-package style content.
- Keep modules easy to import, document, and test.

## Scope
- `library/*/init.lua` modules.
- Supporting examples, docs, and test artifacts for reusable modules.
- Module-level registration or packaging files.

## Local map
- Each top-level folder is a reusable library package domain such as `combat`, `inventory`, `quest`, `roguelike`, or `tilemap_minimap`.
- `README.md` is the local index and should stay aligned with the available modules.
- Favor one obvious package entrypoint per module directory, usually `init.lua`.
- If a behavior is demo-specific, keep it under `content/` and let `library/` hold only the reusable extraction.

## Local rules
- Keep `init.lua`, examples, docs, and tests aligned.
- Prefer reusable Lua patterns over demo-only scripts.
- Keep library modules grounded in accepted `lurek.*` contracts.
- Sync docs and validation artifacts when a library API changes.
- Keep package entry points small and obvious.
- Avoid adding library-specific hacks that only work in one demo.
- Each library module should keep the fixed trio: `init.lua`, `example.lua`, and `README.md`.
- Library code stays pure Lua; it may call `lurek.*` but should not depend on Rust internals or ad hoc engine-only hooks.
- Regenerate `docs/api/lureksome.md` and `docs/api/lureksome.lua` with `python tools/docs/gen_lib_docs.py` after public library API changes.
- Update the module, example, tests, and generated docs in the same task when the public library surface changes.

## Workflow
- Read the public API shape and nearest examples before editing a module.
- Use this file, the matching example, and the nearest Lua test or example contracts as the source of truth.
- Update the module, its example, and the docs together.
- Validate with the narrowest runnable proof that exercises the module contract.

## Expected outputs
- Runnable library module updates with synced examples and docs.
- Clear import and usage guidance for consumers.

## Anti-patterns
- Ship library changes without an example or usage update.
- Hide import-time behavior in unrelated demo files.
- Let package entry points drift from actual exported behavior.

## References
- `content/examples/`
- `tests/lua/`
- `docs/specs/`
