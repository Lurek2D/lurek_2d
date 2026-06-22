# cursor manual spec overlay

## TL;DR

- Manages contextual custom cursors, motion trails, and magnifiers.

## Summary

- The `cursor` module is the pointer-behavior surface for users who want the cursor to feel like part of the game UX rather than a fixed OS artifact.
- System cursors, custom RGBA cursors, animated states, and context-driven switching work together so interaction modes can communicate themselves visually without extra UI explanation.
- Trail effects, zoom-lens support, locking, visibility control, and mode-aware switching extend the same module into readability, precision work, and tool-oriented pointer behavior.
- That makes the module especially useful for menus, editors, strategy controls, drag-and-drop flows, and inspection-heavy screens where the cursor is a major part of the interaction language.
- Read `cursor` as the owner of cursor presentation and cursor-state policy. Other systems decide which interaction mode is active, but `cursor` decides how that mode is expressed to the user.

This module is mostly self-contained inside the `Edge/Integration` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
