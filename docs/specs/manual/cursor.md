# cursor manual spec overlay

## TL;DR

- Manages contextual custom cursors, motion trails, and magnifiers.

## Summary

- The `cursor` module is the pointer-behavior surface for users who want the cursor to feel like part of the game UX rather than a fixed OS artifact.
- System cursors, custom RGBA cursors, animated states, and context-driven switching work together so interaction modes can communicate themselves visually without extra UI explanation.
- The runtime now treats cursor behavior as one shared active controller rather than isolated per-manager state, which lets hover, click, wheel, trails, bursts, and zoom resolve against one authoritative pointer state each frame.
- State switching is no longer just a manual `if` chain in Lua. `defineState`, `defineEffect`, `addRule`, and `addSource` let projects describe cursor policy declaratively and feed semantic hover hits into the same resolver.
- Trail effects, zoom-lens support, locking, visibility control, click bursts, and mode-aware switching extend the same module into readability, precision work, and tool-oriented pointer behavior.
- That makes the module especially useful for menus, editors, strategy controls, drag-and-drop flows, and inspection-heavy screens where the cursor is a major part of the interaction language.
- Read `cursor` as the owner of cursor presentation and cursor-state policy. Other systems decide which interaction mode is active, but `cursor` decides how that mode is expressed to the user.

This module is mostly self-contained inside the `Edge/Integration` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Notes

- `lurek.cursor.newManager()` now returns a handle to the shared runtime cursor. Multiple Lua handles intentionally operate on the same active pointer state.
- `LCursorManager:defineState(name, spec)` is the high-level state registry. A state can select a system cursor or a custom/animated overlay cursor and optionally bundle trail or zoom behavior with that state.
- `LCursorManager:defineEffect(name, spec)` stores reusable hover or click burst presets, while `LCursorManager:addRule({...})` resolves context, hover target, click, release, or wheel events into states and effects with priorities.
- `LCursorManager:addSource(source)` is the semantic hover input side of the system. `globe`, `raycaster_last`, and callback sources all normalize into the same hit payload: `module`, `kind`, `surface`, `id`, `attrs`, `context`.
- Overlay rendering is now a runtime decision. Pure system-cursor states prefer the native OS cursor, while custom cursors, animated cursors, trails, bursts, and zoom lens behavior render through the engine overlay pass.
- Trail modes now cover point, line, ribbon, and stamp-style behavior. Zoom is a live lens effect intended for precision work and game-like inspection instead of a CPU screenshot readback path.

## Architecture Links

- Intentionally empty.
