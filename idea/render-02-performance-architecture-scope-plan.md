# Render Plan 2 of 4: Performance, Architecture, Scope, and Feature Gaps

## Purpose

Measure and improve render throughput and frame stability while untangling ownership with province, app, image, font, sprite, scene, and UI. Add only render-native capabilities that do not duplicate neighboring modules.

## Current evidence

- The global performance gate passes (`stress_pct` 38.57%, quality score 6.20), but there is no render-specific GPU/release baseline proving frame time, allocation, pipeline compilation, upload, or readback ceilings.
- `tests/lua/stress/test_render_stress.lua` exercises only five primitive APIs and mainly generates commands; it does not render a real GPU frame or assert time/allocation/draw-call thresholds.
- Large render seams include postfx, frame dispatch, renderer/resource/pipeline/tessellation/shadow/software-capture files ranging from roughly 700 to 1,370 lines, plus a very large Lua registration file.
- Pipeline and resource maps can grow through state/source combinations; shader compilation and resource upload can hitch the frame.
- Render imports province registry/domain behavior, while province also imports `wgpu`, contradicting the documented one-way rendering boundary.
- UI owns a duplicate CPU raster path even though render owns software command capture.
- Public constructors overlap canonical domains: `render.newFont`, ambiguous `render.newImage`, `render.newSpriteBatch`, and depth-sorter aliases.

## Authoritative module boundary

| Concern | Owner | Render contract |
|---|---|---|
| Device/queue/pipelines/buffers/textures/canvases/command encoding | `render` | Full ownership of GPU resources and execution. |
| Window/event-loop/process lifecycle | `app` | Calls a narrow render surface/device facade; no duplicate recovery policy. |
| Surface bootstrap | choose and document | Prefer render-owned initialization/configuration with app supplying window handles; if app remains an edge exception, architecture tooling must encode it. |
| CPU image data and codecs | `image` | Render accepts bounded upload descriptors and returns readback `ImageData`. |
| Font loading/shaping/glyph semantics | `font` | Render uploads/renders glyph artifacts through an explicit bridge. |
| Sprite data/animation/batch semantics | `sprite` | Render consumes a bounded batch snapshot; no second sprite model. |
| Scene/world order and camera projection | `scene`/camera | Render consumes final transforms/order/camera uniforms. Generic painter sorting may remain render-owned only if domain-neutral. |
| Province IDs, adjacency, borders, semantic maps | `province` | Render consumes a versioned neutral upload snapshot; it never owns `ProvinceRegistry`. |
| Widget semantics/layout | `ui` | Render executes UI-emitted commands and owns software/GPU replay. |
| Filesystem/path policy and asset resolution | GameFS/file owner | Render never directly resolves user paths. |

## P0 — Break the province/render dependency cycle

- Define a CPU-only, bounded, versioned `ProvinceRenderSnapshot` or neutral upload descriptors outside GPU implementation details.
- Province owns registry access, semantic ID mapping, adjacency/border extraction, and version/change tracking.
- Render owns buffer/texture creation, formats, sampling, pipelines, and residency from that snapshot.
- Remove `ProvinceRegistry` and province semantic algorithms from `GpuRenderer` and render pipelines.
- Remove direct `wgpu` usage from `src/province/gpu_upload.rs`; replace it with neutral data preparation or move GPU-only implementation behind render.
- Update only changed regions when snapshot versions indicate province data/style/borders changed.
- Add dependency checks that fail if render imports province registries or province imports `wgpu` after migration.
- Benchmark upload size/time and incremental update behavior on representative maps.

## P0 — Consolidate all software replay in render

- Make `src/render/software_capture.rs` the sole backend-independent replay/capture owner for supported `RenderCommand` variants.
- Migrate UI capture to emit commands and call this service; delete duplicate UI pixel algorithms after parity evidence.
- Define supported/unsupported command parity, color-space/blending/clip rules, font/image sourcing, and deterministic rounding.
- Use the software backend for command-validator integration tests and deterministic golden evidence, not as a separate semantic renderer.

## P0 — Establish a real render performance suite

Measure release builds on a declared adapter/backend and a deterministic headless/software fallback. Scenarios must include:

- primitive-heavy color geometry;
- texture/sprite batches and instance buffers;
- text and rich text with cache hits/misses;
- meshes, shapes, OBJ upload, and static geometry reuse;
- canvases, scissor/stencil/transform stacks, postfx chains, custom shaders, and pipeline-key churn;
- particles, lights/shadows, province snapshots, and large command streams;
- texture/mesh/shader resource creation, release, and recreation;
- screenshot/readback concurrency and row sizes;
- warm steady-state, first-frame cold compilation, resize/reconfigure, and device recovery.

Record CPU build/encode time, GPU time where supported, allocations, upload bytes, draw/pass/pipeline counts, vertices/indices/instances/glyphs, cache hit/miss/eviction, buffer growth, retained/live GPU bytes, and p50/p95/p99 frame time. Establish measured ceilings and regression tolerances; do not rely on the current global score alone.

## P1 — Eliminate avoidable frame hitches

- Prevalidate and queue resource uploads at a defined frame boundary with a byte/time budget.
- Add bounded shader/pipeline prewarm APIs for known materials/effects. They may return a request handle and progress through the same compilation budget.
- Cache pipelines by a minimal normalized key; eliminate accidental key dimensions and cap/evict cold entries.
- Batch compatible draws and state transitions without changing stable command order where blending/order matters.
- Reuse frame scratch buffers and staging belts with capped retained capacity.
- Avoid cloning large command/text/mesh data into multiple frame phases; use validated views or owned frame packets with explicit lifetime.
- Cache static tessellation/geometry by resource generation, but cap cache bytes and invalidate precisely.
- Update province/light/shadow resources only when versioned source data changes.
- Make screenshot/readback asynchronous so interactive frames never use `Maintain::Wait`.

## P1 — Refactor implementation seams around ownership

- Split `src/lua_api/render_api.rs` into resource/primitive/state/text/canvas/shader/mesh/diagnostics registration modules with shared conversion and error helpers. Keep GPU/business logic in `src/render`.
- Replace broad frame files with command-family encoders behind a single validated frame packet and explicit state machine.
- Separate resource lifecycle/accounting from draw encoding and from pipeline cache creation.
- Keep module registration flat and avoid a facade that simply moves the same giant match without clarifying ownership.
- Every refactor requires command/output equivalence tests and release benchmark comparison.

## P1 — Resolve public namespace overlaps

### Fonts

- Make `lurek.font.load`/font-owned constructors canonical.
- Render should accept font handles and own only GPU glyph residency/draw execution.
- Keep `lurek.render.newFont` as a time-bounded alias with identical GameFS/error behavior, then remove it.

### Images/textures

- Rename the GPU resource concept to `LTexture` with canonical `lurek.render.newTexture`/`uploadTexture` semantics.
- Path-based convenience must compose GameFS + image decode + render upload; do not duplicate codecs.
- Keep `LImageData` in image and document color-space conversion ownership.
- Deprecate ambiguous `render.newImage` after migration.

### Sprite batches

- Sprite owns batch item semantics and lifetime; expose a canonical sprite constructor if that is the established module model.
- Render owns the upload/instancing backend and consumes a sprite batch snapshot/handle.
- Do not create two batch types. Keep `render.newSpriteBatch` only as a compatibility alias if necessary.

### Depth sorting

- If `DepthSorter` is a domain-neutral painter-order helper over render items, keep one canonical render implementation and make scene’s name an alias.
- If it relies on scene entities/cameras, move semantic construction to scene and let render consume the final ordered commands.
- Document stable ordering, NaN handling, and complexity either way.

## P1 — Add useful render-owned capabilities

1. **Capability query**
   - Expose a stable, read-only subset of adapter/device limits, supported formats/features, shader trust mode, and effective `RenderBudget`.
   - Avoid leaking raw `wgpu` types or backend-specific unstable strings.

2. **Accurate frame/resource diagnostics**
   - Expose last-frame/cumulative activity and fault snapshots, live resource counts/bytes, cache behavior, budget use, and recovery state.
   - Keep developer diagnostics bounded and cheap.

3. **Asynchronous capture/readback**
   - Provide poll/cancel/timeout/result requests as designed in Render Plan 1; image handles encoding.

4. **Bounded prewarm**
   - Allow games/tools to declare expected shader/pipeline/mesh resources before the first critical frame, under normal budgets.

5. **Deterministic headless replay**
   - Support the documented command subset for tests, server tooling, and evidence. This remains command execution, not a competing UI/image system.

Features not added to render because another owner exists:

- file lookup/sandbox, image/font codecs, sprite animation, ECS/world queries, province topology, UI layout, scene serialization, or a second data/asset cache.
- A general render graph is deferred unless concrete postfx/canvas limitations demonstrate need; it must not duplicate existing effect/canvas APIs.
- Texture streaming/atlasing policy belongs to asset/image/sprite owners; render may provide residency/upload primitives only.

## P2 — Device-aware memory residency and eviction

- Track live/retained bytes by resource kind, owners, last use, and reconstructibility.
- Set soft/hard budgets from configured policy and adapter limits.
- Evict only reconstructible caches (pipelines where safe, static tessellation, transient targets, glyph/texture residency under owner policy); never silently destroy a live public resource.
- Provide pressure diagnostics and deterministic fallback/rejection at the hard limit.
- Test churn, eviction order, stale handles, reconstruction, and device recovery.

## Verification matrix

- Dependency: province has no `wgpu`; render has no `ProvinceRegistry`, image codecs, font decoder, sprite animation, UI widget, or direct user-path ownership.
- Equivalence: refactored encoders and cache changes produce the same validated command behavior and golden output.
- Performance: warm p95/p99, cold compilation, allocation, upload, and cache limits pass module-specific thresholds.
- Memory: persistent/transient budgets and eviction are observable and never exceed configured/device bounds.
- API: canonical owner namespaces and aliases behave identically during migration.
- Recovery: resize/loss/reconfigure does not leak resources or invalidate owner handles unexpectedly.

## Exit criteria

- The architecture dependency direction matches source imports and public namespaces.
- Render has measured CPU/GPU/memory/cache baselines and regression gates.
- First-frame compilation, uploads, and readback are bounded and schedulable.
- Province and UI rendering duplication/cycles are removed.
- New features are render-native primitives and reuse owner data/codecs instead of duplicating them.
- Public alias migrations have owners, deadlines, tests, and documentation.

