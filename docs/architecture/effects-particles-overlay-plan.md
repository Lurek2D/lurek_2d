# Lurek2D - Effects, Particles, Image, and Overlay Plan

## TL;DR

- `particle` owns transient spawned simulation and exports render-ready particle snapshots.
- `image` owns CPU pixel buffers, file formats, packing, export, diffs, and CPU image effects.
- `effect` owns post-processing descriptors, shader-pass catalogs, stack ordering, capture/apply orchestration, and image-scoped post-fx chains.
- `overlay` owns scene-wide screen presentation policy: weather, ambient tint, flashes, fades, shake, accessibility, layer ordering, and orchestration.
- `render` is the only owner of wgpu resources, GPU execution, post-fx pipelines, particle GPU pipelines, and final submit.

Companion documents: [engine-core.md](engine-core.md), [render-pipeline.md](render-pipeline.md), [module-scope-boundaries.md](module-scope-boundaries.md)

---

## Current State

### Particle

Implemented now:

- CPU pooled emitters with bounded `ParticleLimits`.
- Gravity as `gravity_x` / `gravity_y`, linear acceleration, radial/tangential acceleration, damping, drag, turbulence, orbit, attractors, and area/emission-shape sampling.
- Axis-aligned bounce bounds and a Rapier world collision probe bridge through `physics_collision.rs`.
- Shape vocabulary, sprite-sheet quads, alpha/size/color keyframes, sub-emitters, trails, preview images, Lua unit/stress/evidence coverage, and render batching through `DrawParticleSystem`.

Missing or incomplete:

- GPU simulation path for high-volume particles.
- Tilemap collision adapter for particles bouncing against map solids without requiring a Rapier collider per tile.
- Explicit sorting/depth policy for particles in isometric and multi-layer tilemap scenes.
- Authoring presets that describe "CPU exact", "GPU visual", and "physics-aware" intent separately.

### Image

Implemented now:

- `ImageData` CPU RGBA buffer, load/save/encode, layers, palette LUT, GIF, compressed DDS metadata, atlas helpers, debug visualizations, and CPU image effects.
- Named `applyEffect` / `applyEffects`, region effects, map callbacks, resize filters, blur/sharpen/convolve, composition, diff, and evidence artifacts.
- Parallel CPU pixel mapping for large image operations.

Missing or incomplete:

- GPU image-processing job API for reusable shader effects over an `ImageData` source.
- Explicit async readback policy for GPU image results.
- Clear Lua split between CPU-destructive image edits and GPU post-fx previews.

### Effect

Implemented now:

- `PostFxEffectType` catalog with bloom, blur, CRT, scanlines, pixelate, chromatic, water distortion, dither, outline, motion blur, custom passes, and parameter schemas.
- `PostFxStack` and renderer `BeginPostFx` / `EndPostFx` / `ApplyPostFx` command planning.
- Presets, diagnostics, custom shader id validation, auto uniform contract, image-scoped `ImageEffect` pass chains, and GPU execution in `render::postfx_pipeline`.

Risk:

- Legacy compatibility aliases and re-exports can make `effect` look like it owns overlay concepts. The contract is that these are compatibility edges only; new APIs must use `lurek.overlay` for screen-policy state.

### Overlay

Implemented now:

- Timed screen flash, fade, shake, lightning, accessibility policy, render plan diagnostics, weather simulation, fog/cloud/heat-haze/vignette/film-grain/water state, and debug/evidence image output.
- `build_render_commands` directly emits only simple full-screen layers: flash, fade, lightning, and the current simple vignette approximation.
- Weather, clouds, fog, heat haze, film grain, water, ambient, and custom shader are reported as `externally_handled` by `getRenderPlan`.

Missing or incomplete:

- A production overlay compositor that turns `externally_handled` layers into ordered render/post-fx work.
- Shader-backed screen layers for cloud shadows, heat haze, water, film grain, and retro/pixel upscale/downscale looks.
- Formal bridge from overlay state into `effect` stack descriptors without moving effect-stack ownership into overlay.

---

## Ownership Contract

| Concern | Owner | Reason |
|---|---|---|
| CPU particle lifecycle, spawn policy, forces, bounds, trails, death emitters | `particle` | These are emitter simulation semantics. |
| GPU particle buffers, compute dispatch, instanced draw pipeline | `render` | Only render may own wgpu resources and dispatch. `particle` provides descriptors/snapshots. |
| Particle/world collision probes | `particle` adapter over `physics`/`tilemap` snapshots | Particle owns bounce policy; physics/tilemap own world data. |
| CPU pixel effects and destructive image edits | `image` | Image owns `ImageData` memory and file/export workflow. |
| GPU image effects | `effect` descriptors + `render` execution, with `image` source/readback adapters | Effect owns pass semantics; render owns GPU work; image owns CPU result buffers. |
| Full-screen post-processing, retro shaders, pixelate/upscale/downscale | `effect` + `render` | These are final-frame pass chains, not weather/state policy. |
| Weather, snow, wind, cloud-shadow timing, damage flash, hit vignette, shake, ambient mood | `overlay` | These are scene-wide temporal presentation policies. |
| Layer order among screen presentation effects | `overlay` render plan | Overlay decides requested order; render/effect execute via commands or pass descriptors. |
| Camera position, zoom, rotation, viewport, screen shake transform | `camera` for view transform, `overlay` may request shake offset | Overlay must not own camera projection or viewport math. |
| Scene lifecycle and overlay scenes | `scene` | Scene stack decides process/render participation; overlay module is visual state only. |
| Isometric/tilemap draw ordering | `tilemap` and scene/depth sorter | Overlay is screen-space after the world; object/world particles must enter normal depth order. |

---

## Target Architecture

### Particle Execution Modes

1. CPU exact mode:
   - Current `ParticleSystem` remains canonical for deterministic tests, physics-aware particles, custom Lua callbacks, sub-emitters, and small/medium counts.
   - Renderer receives `DrawParticleSystem { particles }` snapshots.

2. GPU visual mode:
   - Add a `ParticleGpuDescriptor` in `src/particle` with only serializable, GPU-friendly fields.
   - Add `RenderCommand::DrawGpuParticleSystem { descriptor_id, sort_policy, target_space }` or an equivalent structured render input.
   - Implement compute/update and instanced draw in `src/render`, behind runtime capability checks.
   - Keep readback optional and diagnostic-only.

3. Hybrid physics mode:
   - CPU owns collision events and control particles.
   - GPU owns high-volume visual debris that does not need per-particle gameplay callbacks.
   - A tilemap/physics collision snapshot can be uploaded as coarse masks or SDFs later; do not bind GPU particles directly to Rapier internals.

### Overlay Compositor

Add an overlay-to-render bridge that produces an ordered plan:

1. CPU overlay commands:
   - flash, fade, simple color wash, debug-safe fallback layers.

2. Post-fx requests:
   - vignette, heat haze, film grain, water distortion, cloud shadows, pixelate, CRT, scanlines, damage desaturation/red tint.

3. Procedural screen particles:
   - snow/rain/leaves can remain overlay-owned weather policy but should use `particle`-style descriptors or a GPU overlay particle descriptor rather than duplicating emitter complexity.

4. Diagnostics:
   - `getRenderPlan` must show rendered, postfx, procedural, and unsupported/fallback layers separately.

### Image GPU Effects

Add a GPU image-effects API only after the post-fx pipeline can run off-screen with readback:

- `lurek.image.applyGpuEffect(image, effect_or_stack, opts) -> pending/result`
- `lurek.image.requestGpuEffect(...) -> handle`
- `lurek.image.pollGpuEffect(handle) -> LImageData|nil`

CPU image effects remain synchronous and deterministic. GPU effects must document async timing, color-space assumptions, and fallback behavior.

---

## Camera, Viewport, Scene, and Tilemap Rules

- World particles are transformed by camera like sprites. They belong in world draw order.
- Screen-space overlay effects ignore world camera transform but obey viewport/pixel-perfect scaling.
- Screen shake should be a camera transform request or a renderer wrapper, not a world-object mutation.
- Damage red tint, hit edge vignette, wind/snow on the visible screen, and transition wipes belong to `overlay`.
- Bloom, CRT, pixelate, downscale/upscale, palette/dither, water distortion shader, and global color grading belong to `effect`.
- Isometric particles that must pass behind walls or over floor tiles must be submitted through scene/tilemap depth sorting. Overlay snow/rain that is "on the camera glass" remains screen-space and draws after world rendering.
- Scene overlay scenes are lifecycle/UI composition. They are not the same as `lurek.overlay`; they may own menus/HUDs that call `lurek.overlay` or `lurek.effect`.

---

## Implementation Phases

### Phase 1 - Contract Cleanup

- Remove stale docs that describe `effect` as owning overlay systems.
- Mark `lurek.effect.newOverlay` and `lurek.effect.newTransition` as legacy compatibility aliases in docs/examples, with canonical usage under `lurek.overlay`.
- Add tests or audits that catch future architecture drift for `overlay` vs `effect` ownership language.

### Phase 2 - Overlay Render Plan

- Extend `OverlayRenderPlan` with categories: direct commands, postfx passes, procedural particles, unsupported fallback.
- Add `Overlay::build_postfx_requests()` returning neutral effect request descriptors, not a `PostFxStack`.
- Add Lua coverage for render-plan categorization.
- Add evidence showing each overlay layer category and final ordering.

### Phase 3 - Shader-Based Overlay Features

- Map overlay state to effect pass descriptors for vignette, heat haze, film grain, cloud shadows, water, and custom shader layers.
- Add explicit ordering controls: `setLayerOrder`, `moveLayerBefore`, `moveLayerAfter`, `setLayerEnabled`.
- Add accessibility gates for flashes, shake, grain, strobe-like lightning, and high-contrast effects.

### Phase 4 - Particle Performance and GPU Path

- Add particle performance baselines for CPU pool update, render extraction, and high-count batching.
- Add `ParticleExecutionMode::{Cpu, Gpu, Auto}` and a capability diagnostic.
- Implement GPU particle update/draw in `render` using storage buffers and compute when available.
- Add fallback to CPU when GPU particle features are disabled or unsupported.
- Add tilemap collision snapshot experiments after CPU/GPU mode separation is stable.

### Phase 5 - Image GPU Effects

- Add off-screen post-fx execution and readback infrastructure.
- Add async Lua API and stress tests for request lifecycle, cancellation, size limits, and unsupported GPU fallback.
- Keep existing CPU `ImageData` effects as the deterministic golden path.

---

## Test and Evidence Plan

- Rust unit tests:
  - `effect`: pass planning, invalid shader ids, duplicate stack policy, pixelate/CRT/dither schema validation.
  - `overlay`: render-plan categories, layer ordering, accessibility clamps, unsupported shader diagnostics.
  - `particle`: CPU/GPU descriptor validation, bounds, attractors, tilemap collision snapshots, render-budget counters.
  - `image`: CPU/GPU parity tolerances for simple effects, readback limits.

- Lua unit tests:
  - One `@covers` test per new public API.
  - Canonical alias tests should state that `lurek.effect.newOverlay` is compatibility only.

- Integration tests:
  - `overlay + effect + camera`: screen-space hit flash and post-fx stack do not mutate camera state.
  - `particle + physics`: particles bounce against physics bodies with explicit probe radius/restitution.
  - `particle + tilemap + scene`: isometric depth sort uses scene/tilemap order for world particles.
  - `image + effect`: GPU image request returns equivalent dimensions and bounded color tolerance.

- Evidence:
  - Overlay compositor atlas: direct layers, post-fx layers, procedural weather, final order.
  - Particle performance report: CPU exact vs GPU visual vs hybrid counts.
  - Pixel-art shader proof: downscale/upscale, CRT/scanline/pixelate chain.
  - Image effect parity atlas: CPU vs GPU for simple transforms.

---

## Open Decisions

- Whether GPU particles should be exposed as a separate `LParticleGpuSystem` or as `LParticleSystem:setExecutionMode("gpu")`.
- Whether overlay weather should consume `particle` descriptors directly or use an overlay-specific procedural particle descriptor.
- Whether image GPU effects should be immediate with frame-stall readback for small images or always async.
- How much tilemap collision data should be uploaded to GPU: bitmask, SDF, signed tile field, or physics-derived broadphase snapshot.
