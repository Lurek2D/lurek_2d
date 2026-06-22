# color manual spec overlay

## TL;DR

- Manages color spaces, blends, and retro palettes.

## Summary

- The `color` module is the shared toolbox for defining, converting, and reusing runtime color values across the engine.
- It combines low-level color math with practical authoring workflows, so scripts can move between RGB, HSL, HSV, hex, blending, and interpolation without custom conversion helpers.
- That makes it useful for themes, fades, highlights, palette work, and effect tuning.
- Read it as the common color language for the engine: other systems decide where color is used, but `color` keeps conversion, composition, and palette logic consistent.

This module is mostly self-contained inside the `Foundations` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
