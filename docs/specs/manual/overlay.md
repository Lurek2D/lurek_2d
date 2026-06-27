# overlay manual spec overlay

## TL;DR

- Manages screen-space weather, fog, camera shakes, and screen flashes.
- Supports wave distortion and transition wipes.

## Summary

- The `overlay` module is the engine's screen-layer presentation surface for users who want weather, atmosphere, transitions, and other scene-wide visual treatments to behave as one coherent system.
- It groups full-screen and near-full-screen effects that are too global to belong to an individual sprite but too specialized to live as loose render hacks.
- This matters for fog washes, rain veils, damage flashes, atmospheric tinting, transition masks, and similar treatments that need their own timing and configuration rules.
- Weather, ambient mood, distortion-style effects, and transition controllers all belong here because they usually evolve over time rather than acting like static post-process toggles.
- That temporal behavior is the key reason the module exists: these effects are often stateful and orchestrated, not just one-frame visual filters.
- The same subsystem can therefore own persistent environmental treatment and short-lived screen transitions without burying either concern inside unrelated render code.
- Layer-wide control is important because these treatments often need coordinated fade-in, fade-out, stacking, and override rules when several moods or transitions compete for the screen at once.
- The module is useful whenever a project needs stronger screen-space presentation than a local sprite effect but does not need a full scene rewrite.
- `render` still draws the final image, but `overlay` owns the grouping, configuration, temporal behavior, accessibility policy, and diagnostics for these large-scale scene treatments.
- Read `overlay` as the orchestration layer for scene-wide atmospheric and transitional effects.

This module primarily collaborates with `color`, `image`, `render`, `runtime`. Its responsibility should stay inside the `Edge/Integration` group rather than absorb behavior owned by those neighbors.

## Notes

- Ownership boundary:
  `overlay` owns scene-wide screen presentation policy and temporal orchestration: weather, ambient tint, flash, fade, shake, lightning, accessibility, layer ordering, and diagnostics. It may request post-fx work through explicit descriptors, but it must not own shader catalogs, post-fx stack ordering, or capture lifecycle; those belong to `effect` and `render`.
- Render boundary:
  Direct overlay commands are suitable for simple color/shape layers. Shader-backed treatments such as heat haze, water distortion, film grain, cloud shadows, CRT, pixelate, upscale/downscale, or full-frame grading should route through post-fx descriptors and renderer execution.
- World boundary:
  Overlay is screen-space after the world. World-space effects such as sparks behind an isometric wall, dust at a tile collision, or object-local trails belong to `particle`/`scene`/`tilemap` depth ordering, not overlay.

## Architecture Links

- `docs/architecture/module-scope-boundaries.md`
- `docs/architecture/effects-particles-overlay-plan.md`
