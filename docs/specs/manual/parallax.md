# parallax manual spec overlay

## TL;DR

- Manages layered scroll depth, autoscrolling, and tiling.
- Adds motion blur.

## Summary

- The `parallax` module is the layered-background surface for projects that want depth and atmospheric motion without full 3D simulation.
- Layer definitions, presets, tiling behavior, and render helpers let several planes move at different camera-relative rates and create a stronger sense of scene depth.
- Drawing support and image export matter because parallax content may be used both in live rendering and in tooling or preview workflows.
- The module is useful for skies, distant scenery, decorative world layers, and motion-rich menu or transition backdrops that should stay cheaper and simpler than full interactive geometry.
- Camera-relative speed policy matters because background depth reads differently across scenes.
- It also keeps background motion readable across scene scales and camera styles.
- Read it as the place where depth-illusion backgrounds become reusable scene content instead of a one-off renderer trick.

This module primarily collaborates with `image`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
