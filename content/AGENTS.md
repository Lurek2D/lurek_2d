# Content Contract

This file adds local rules for work under `content/`.

## Mission
- Own Lua-based games, demos, examples, and config-side content.
- Make content runnable and easy to validate.

## Scope
- `content/games/`, `content/examples/`, and related content files.
- Demo registrations and content-side config templates.
- Example quality and user-facing content flow.

## Local map
- `examples/` should stay small and API-teaching focused.
- `games/` holds runnable multi-file projects and is the right home for richer play loops.
- `layouts/` contains UI or scene layout data; keep it aligned with the actual runtime loaders and validation tools.
- `snippets/` is source material for editor snippets; if snippet markers change, sync the generator path under `tools/snippets/`.
- `zips/` is packaged output territory, not source authoring territory.

## Local rules
- Use real `lurek.*` calls, not placeholders.
- Keep demos runnable and scoped to one teaching goal.
- Sync content registrations and validation when content structure changes.
- Treat engine Rust work as out of scope from this folder.
- Prefer small, legible content slices over giant stitched examples.
- Ensure content uses the same public API shape that docs describe.

## Workflow
- Read the nearest API docs and examples before changing content.
- Load `lua-scripting`, `demo-creation`, or `examples-management` depending on the task.
- Keep README, registration, and runnable entry points in sync.
- Validate the content path with the narrowest runnable check available.

## Expected outputs
- Runnable content changes with validation proof.
- Updated registration or config files when needed.
- Notes if a user-facing example intentionally leaves a dependency unresolved.

## Anti-patterns
- Use placeholder code that does not exercise the real API.
- Mix demo-only and library-only concerns in the same file.
- Leave registration or harness metadata stale.

## References
- `library/`
- `docs/specs/`
- `tests/lua/`
