# Content Contract

Covers work under `content/`.

## Mission
- Own Lua-based games, demos, examples, and config-side content.
- Keep content runnable and easy to validate.

## Scope
- `content/games/`, `content/examples/`, `content/layouts/`, and `content/snippets/`.
- Demo registrations and content-side config templates.

## Local map
- `examples/` should stay small and API-teaching focused.
- `games/` holds runnable multi-file projects.
- `layouts/` contains UI or scene layout data.
- `snippets/` is source material for editor snippets.
- `zips/` is packaged output, not source authoring.

## Rules
- Use real `lurek.*` calls, not placeholders.
- Keep demos runnable and scoped to one teaching goal.
- Sync registrations and validation when content structure changes.
- Treat engine Rust work as out of scope.
- Prefer small, legible content slices over giant stitched examples.
- Keep content aligned with the public API shape docs describe.
- Multiply frame-based movement, timers, and tweens by `dt`.
- Keep gameplay state in locals or explicit tables.
- Use forward-slash asset paths.
- Prefer `lurek.log.*` or `lurek.log.event(...)` over `print()` when output should be filterable.
- For HTML UI content, keep structure and visual rules in HTML or CSS and state transitions in Lua.
- Do not rebuild full HTML documents every frame when a smaller update is enough.
- Check the supported HTML and CSS subset before using uncommon tags or layout features.

## Workflow
- Read the nearest API docs and examples before changing content.
- Use the nearest nested contracts under `content/` plus the current API docs as the source of truth.
- Keep README, registration, and runnable entry points in sync.
- Validate the content path with the narrowest runnable check available.

## References
- `library/`
- `docs/specs/`
- `tests/lua/`
