# Render Pipeline Architecture

## Purpose

The renderer converts validated commands and snapshots into GPU work. It owns GPU resources, render-target lifetime, submission, surface recovery, and presentation. Domain modules own the data and policies that produce render-ready input.

## Data Flow

```text
Lua calls
  -> Lua API conversion and validation
  -> domain state or RenderCommand creation
  -> frame command collection
  -> renderer pass planning
  -> wgpu encoding and submission
  -> surface presentation
```

Every arrow is a call, command buffer, handle lookup, or immutable snapshot. Domain state is not shared as mutable GPU state.

## Ownership

- `src/render/` owns `wgpu` device/queue/surface objects, pipelines, bind groups, textures, canvases, command execution, and final submit.
- Image/font/sprite/tile/light/effect/particle/UI modules own their domain state and emit handles, descriptors, geometry, or snapshots.
- The application owns window events and tells the renderer when surface size or lifecycle changes.
- Lua bindings validate public arguments and translate them into calls on existing owners.

Some modules may import rendering types or `wgpu` adapters for integration. The durable rule is ownership: they must not create a second device, queue, surface, or submission authority.

## Resource Handles

1. A resource owner validates external input and creates Rust-owned resource state.
2. Lua receives an opaque handle or userdata, not a borrow of GPU memory.
3. Draw commands carry the handle plus frame-local parameters.
4. The renderer validates the handle before encoding.
5. Release or eviction invalidates the handle and derived cache entries.

Stale or wrong-kind handles return structured errors. Serialized handle values are not valid resource restoration; restore recreates resources from validated source data.

## Pass Order

A frame may include off-screen targets, scene/world drawing, lighting/effects, UI, and final presentation. Exact passes are renderer implementation details, but these constraints are durable:

- off-screen targets are resolved before consumers sample them;
- post-processing consumes a completed input target and writes to a distinct output or controlled ping-pong target;
- UI layout remains UI-owned; the renderer consumes resolved draw data;
- final submission occurs once per presented frame;
- frame-local commands and transient allocations are cleared after submit.

## Domain Boundaries

- `image` owns CPU pixel data, import/export, and CPU transformations; render owns uploaded textures.
- `particle` owns particle simulation; render owns GPU execution of particle draw data.
- `effect` owns effect descriptors and chain policy; render owns shaders, targets, and execution.
- `overlay` owns scene-wide presentation orchestration; it delegates drawing and post-processing.
- `light` owns light and occluder data; render owns GPU shadow/light passes.
- `ui` owns widgets, layout, focus, and interaction; render owns drawing resolved UI output.

See [Effects, Particles, Image, And Overlay Boundaries](effects-particles-overlay-plan.md) for the canonical cross-module contract.

## Resize, Loss, And Failure

- Resize updates surface configuration and surface-dependent derived resources.
- A zero-sized/minimized surface skips presentation until a usable size returns.
- Recoverable surface loss recreates renderer-owned surface state.
- Invalid shaders, resources, or command payloads fail at validation/creation boundaries and report actionable diagnostics.
- A failed frame must not transfer resource ownership or leave domain state believing it presented successfully.

## Testing Boundary

- Domain command generation is testable without presenting a surface where the owner supports it.
- Renderer-private logic uses Rust tests around validation and planning seams.
- Public rendering behavior uses Lua tests and visual/evidence artifacts.
- Architecture claims are checked against real imports and calls; absence of a direct import alone does not prove independence.
