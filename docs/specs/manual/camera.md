# camera manual spec overlay

## TL;DR

- Tracks targets smoothly via customizable presets, dead-zones, and bounds.
- Controls screen shake, zoom pulses, sways, and multi-camera rigs.

## Summary

- The `camera` module is the engine's shared view-control surface for users who need world motion to become readable player-facing framing.
- Follow logic, dead zones, damping, bounds, zoom, rotation, path motion, and viewport policy all live here so projects can define how scene focus becomes visible framing.
- This matters because camera behavior shapes feel and readability just as much as raw world state does.
- Follow and constraint logic are central because a useful camera is rarely just a position; it must decide how tightly to track a target, how much to lag, and what world bounds or dead zones should still preserve readability.
- Screen shake, sway, breathing, zoom pulses, and scripted paths extend the module from neutral viewing into gameplay feedback and cinematic presentation.
- Screen-to-world and world-to-screen conversion are equally important because overlays, minimaps, targeting, and editor tools depend on the same view contract.
- Split views, subviews, and viewport-aware framing broaden the feature beyond one player camera into inspection tools and multi-panel presentation workflows.
- Scripted path motion also makes the feature useful for guided pans, flyovers, tutorials, and tool previews where the point is not only to follow a target, but to author how attention moves through space.
- That same contract helps previews and gameplay stay visually aligned.
- This shared framing policy is what keeps several view-dependent systems aligned instead of each inventing its own screen-space math.
- `render` shows the result and world systems choose what to focus, but `camera` owns how that focus is followed, constrained, and transformed into visible space.
- Generic fit-to-screen, screen/content conversion, viewport scaling, and zoom-anchor math belong here. Domain modules such as `province` may expose adapters for their own coordinate systems, but they should delegate shared camera math to this module.
- Read `camera` as the authority for framing policy and coordinate conversion between world and screen.

This module primarily collaborates with `math`, `render`, `tilemap`. Its responsibility should stay inside the Platform Services group rather than absorb behavior owned by those neighbors.

## Notes

- Domain modules can keep ergonomic helpers such as province picking, but shared viewport and zoom behavior should remain reusable through `camera`.

## Architecture Links

- Intentionally empty.
