# font manual spec overlay

## TL;DR

- Manages font loading, metrics caching, and text wrapping.

## Summary

- The `font` module is the typography layer for users who need predictable text behavior in UI, HUDs, overlays, or retro-style screens.
- It covers loading and registering fonts, so scripts can reuse named font resources instead of rebuilding text setup at every draw site.
- Measurement and shaping are just as important as loading here: glyph metrics, wrapping, line sizing, and text geometry helpers let layout code make reliable decisions before anything is rendered.
- Read this module as the place where text data becomes stable and reusable. Rendering and UI systems still decide where text appears, but `font` keeps measurement consistent.

This module is mostly self-contained inside the `Platform Services` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
