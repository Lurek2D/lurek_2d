# Effects, Particles, Image, And Overlay Boundaries

## Status

Active boundary contract. The optional refactor proposal is tracked separately in [RFC: Effects Pipeline Consolidation](proposals/effects-pipeline-consolidation.md).

## Ownership

- `particle` owns emitter configuration, simulation state, spawning, lifetime, and render-ready particle snapshots.
- `image` owns CPU pixel buffers, file formats, packing, export, diffs, and CPU image transformations.
- `effect` owns post-processing descriptors, effect-stack ordering, and image/scene effect policy.
- `overlay` owns scene-wide presentation orchestration such as fades, flashes, weather, tint, shake, accessibility, and layer policy.
- `render` owns GPU resources, shaders, render targets, particle/effect execution, compositing, submission, and presentation.

## Data Flow

```text
particle simulation -> particle snapshot -> render
image bytes -> validated CPU image -> render upload
effect descriptors -> ordered effect plan -> render passes
overlay policy -> effect/draw requests -> render
```

Snapshots and descriptors are derived data. Their production does not transfer primary state authority.

## Constraints

- Domain modules do not create a second device, queue, surface, or submit path.
- CPU image operations do not silently mutate uploaded GPU textures; an explicit upload/update crosses the boundary.
- Overlay orchestration may call effect and render APIs but does not own effect pipelines.
- Effect chains validate input/output targets and avoid sampling from the same target being written unless the renderer implements a controlled strategy.
- Public fallbacks are explicit when a GPU capability or optional effect is unavailable.

## Failure And Restore

- Invalid particle/effect descriptors fail before render encoding.
- Missing source images or stale handles produce structured errors.
- Renderer recovery rebuilds GPU-derived state from owner-held descriptors or source data.
- Serialization stores configuration and domain state, not live GPU objects.
