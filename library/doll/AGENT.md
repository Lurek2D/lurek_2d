# `doll` - Agent Reference

| Property | Value |
| --- | --- |
| Tier | Tier 3 - Lureksome (pure Lua) |
| Source | `library/doll/init.lua` |
| Lua tests | `tests/lua/library/test_doll_library.lua` |
| Status | full |
| Optional bindings | caller-side `lurek.render`, caller-side `lurek.image` |

## Purpose

Socket-based 2D visual composition for layered characters, equipment, vehicles,
and other modular visuals.

## Current shape

- `newPart()` creates a visual part with texture, quad, offsets, color, scale,
  flips, origin, and metadata.
- `newTemplate(name)` defines sockets via `addSocket(...)`.
- `newDoll(template)` attaches parts to sockets and emits `getDrawList()`.

## Engine integration

- Rendering is caller-owned. The library does not drive render APIs directly.
- `Doll:draw()` is deprecated and intentionally a no-op with a warning.
- Games should iterate `getDrawList()` and dispatch those entries to
  `lurek.render` or another renderer.

## Notes

- Preserve `getDrawList()` as the primary rendering contract.
- Do not reintroduce direct rendering inside the library.
