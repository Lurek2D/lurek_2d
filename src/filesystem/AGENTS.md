# Filesystem Contract

This file adds local rules for work under `src/filesystem/`.

## Mission
- Own GameFS access boundaries, path normalization, mount rules, and asset-facing filesystem safety.

## Local rules
- GameFS is the asset access boundary. Asset loads should resolve through GameFS semantics rather than bypassing them with direct host-path reads.
- Normalize asset paths before building cache keys: use forward slashes, collapse `.` and `..`, and canonicalize the extension casing.
- Keep sandboxing and access-control logic in `src/filesystem/`; keep format decoding in the downstream subsystem that owns it.
- `save/` is runtime state, not a content root. Do not make game asset resolution fall through to save data.
- `mods/` is a lower-priority content root unless an explicit mount activates an override.
- Missing or unsupported assets must surface as clear runtime errors, not panics, silent fallbacks, or invisible blank defaults.
- Hot-reload or watch hooks must stay safe to disable in release or dist builds.
- Cache invalidation rules must stay aligned with mount and explicit cache-clear behavior; do not leave stale normalized keys alive after root changes.

## Workflow
- Read the matching filesystem or loader spec before changing normalization, mount order, or cache semantics.
- Validate the narrowest loader path that proves the normalization or access rule you changed.

## References
- `docs/specs/filesystem.md`
- `src/image/`
- `src/audio/source.rs`
