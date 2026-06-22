# App

## Purpose

Drives the main winit/wgpu frame loop and Lua VM execution.

## When To Use

- It owns startup, frame progression, host-window lifecycle, and guarded callback dispatch, so update, draw, input, and lifecycle hooks reach game code in a stable order instead of through scattered platform calls.
- Splash screens, error screens, and debug overlays belong here because they are part of the user-facing execution shell rather than any one gameplay feature.
- This central shell also makes recovery possible when startup, callback, or shutdown errors occur.

## Minimal Example

See `content/examples/app.lua` for runnable examples when this module has public examples.

## Common Patterns

- Check the module summary and related examples before using lower-level details.

## API Reference

- This page is the generated API reference for this module.
- Runnable example owner: `content/examples/app.lua`

## Summary

- The `app` module is the top-level runtime shell that turns the engine from a set of subsystems into one running desktop application.
- It owns startup, frame progression, host-window lifecycle, and guarded callback dispatch, so update, draw, input, and lifecycle hooks reach game code in a stable order instead of through scattered platform calls.
- Splash screens, error screens, and debug overlays belong here because they are part of the user-facing execution shell rather than any one gameplay feature.
- This central shell also makes recovery possible when startup, callback, or shutdown errors occur.
- It turns platform hosting into one stable application loop.
- Read this module as the final integration boundary where rendering, input, windowing, and Lua execution are coordinated into one recoverable runtime loop.

This module primarily collaborates with `event`, `filesystem`, `image`, `input`, `light`, `lua_api`, `math`, `parallax`, and adjacent engine modules. Its responsibility should stay inside the Edge/Integration group rather than absorb behavior owned by those neighbors.

*No public API documented yet.*