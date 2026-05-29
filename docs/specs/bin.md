# bin

## Summary
Command-line helper binaries grouped under src/bin for diagnostics, maintenance, and local tooling tasks.

## General Info
This module contains standalone executable entry points compiled as separate binaries. These binaries are not part of the runtime Lua API and are intended for developer workflows.

## Files
- src/bin/

## Types
- None documented at module level.

## Functions
- Binary-specific main functions only.

## Lua API Reference
- None. This module does not expose lurek.* bindings.

## Notes
- Keep binaries focused on one task each.
- Prefer reusing shared engine code from src/ modules instead of duplicating logic.

## References
- docs/specs/README.md
- src/bin/
