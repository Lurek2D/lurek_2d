# Filesystem Contract

Covers work under `src/filesystem/`.

## Mission
- Own GameFS boundaries, path normalization, mount rules, and asset-facing filesystem safety.

## Scope
- `src/filesystem/` access control, normalization, and mount logic.

## Local map
- GameFS is the asset access boundary.
- `save/` is runtime state, not a content root.
- `mods/` is a lower-priority content root unless a mount overrides it.
- `src/image/` and `src/audio/source.rs` own downstream format decoding.

## Rules
- Resolve asset loads through GameFS semantics.
- Normalize asset paths before cache keys: forward slashes, collapsed `.` and `..`, canonical extension casing.
- Keep sandboxing and access control in `src/filesystem/`.
- Missing or unsupported assets must surface as clear runtime errors.
- Hot-reload or watch hooks must stay safe to disable in release or dist builds.
- Keep cache invalidation aligned with mount and explicit cache-clear behavior.

## Workflow
- Read the matching filesystem or loader spec before changing normalization, mount order, or cache semantics.
- Validate the narrowest loader path that proves the rule you changed.

## References
- `docs/specs/filesystem.md`
- `src/image/`
- `src/audio/source.rs`
