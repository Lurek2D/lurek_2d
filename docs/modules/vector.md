# Vector

## Purpose

Provides dynamic SVG vector parsing, hit-testing, state read-back, hierarchy navigation, and GPU-cached rendering.

## When To Use

- It keeps vector parsing, scene representation, and runtime conversion behavior together so vector assets can live inside the normal content flow instead of being forced into a separate external pipeline.
- This is useful for UI artwork that should survive scaling without raster duplication.
- Read it as the point where scalable art becomes usable in the rest of the engine while staying distinct from raster-first asset workflows.

## Minimal Example

See `content/examples/vector.lua` for runnable examples when this module has public examples.

## Common Patterns

- Check the module summary and related examples before using lower-level details.

## API Reference

- This page is the generated API reference for this module.
- Runnable example owner: `content/examples/vector.lua`

## Summary

- The `vector` module is the engine surface for scalable vector artwork, aimed at users who want SVG-style content to stay editable and resolution-independent for as long as possible.
- It keeps vector parsing, scene representation, and runtime conversion behavior together so vector assets can live inside the normal content flow instead of being forced into a separate external pipeline.
- This is useful for UI artwork that should survive scaling without raster duplication.
- Read it as the point where scalable art becomes usable in the rest of the engine while staying distinct from raster-first asset workflows.

This module primarily collaborates with `math`, `render`, `runtime`. Its responsibility should stay inside the `Edge/Integration` group rather than absorb behavior owned by those neighbors.

*No public API documented yet.*