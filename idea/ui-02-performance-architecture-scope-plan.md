# UI Plan 2 of 4: Performance, Architecture, Scope, and Feature Completion

## Purpose

After the handle/lifecycle work in UI Plan 1, reduce avoidable per-event and per-frame work, establish a crisp boundary with `render`, `input`, `layout`, `image`, `font`, `scene`, and data modules, and close useful UI feature gaps without creating competing implementations.

## Current performance and architecture evidence

- `src/ui/context/input.rs` is 2,168 lines and repeatedly calls `ensure_input_layout`; hit testing and modal/descendant queries scan or sort widget collections.
- `src/ui/render.rs` is 2,042 lines and `src/ui/render/cpu.rs` is 1,454 lines. UI both lowers widgets to `RenderCommand` and owns a second software rasterization path.
- `src/render/software_capture.rs` already owns software replay/capture of render commands, creating overlapping rasterization responsibility.
- Layout and render traversals allocate vectors, clone style/text data, and recompute tree/depth/order information that can be retained behind dirty generations.
- The global performance gate passes, but it has no UI-specific release timing, allocation, or maximum-work baseline; therefore it does not prove UI scalability.
- Feature-shaped APIs are present but inert: entity attachment is stored but not consumed, `LStatusBar:setSectionWidget` is a no-op, and toolbar separator/spacer insertion is a no-op.

## Authoritative module boundary

| Concern | Owning module | UI responsibility |
|---|---|---|
| OS/raw keyboard, pointer, wheel, touch, IME events | `input` / app edge | Consume normalized events and own widget routing, focus, capture, gestures, and accessibility intent. |
| Widget tree, box/grid/container layout, styles, interaction state | `ui` | Full ownership. |
| Generic graph/diagram/algorithm layouts | top-level `layout` | No competing solver; UI may consume computed positions through an adapter. |
| Widget-to-draw-command lowering | `ui` | Emit bounded, deterministic `RenderCommand` streams. |
| GPU execution, command replay, scissor/stencil/canvas, software pixel capture | `render` | No GPU/WGSL types and no second rasterizer. |
| Font loading, shaping, glyph metrics/cache | `font` | Request measurement/glyph services and cache only UI-derived layout. |
| CPU image decode/encode and `ImageData` | `image` | Hold image handles and request capture/encoding through owners. |
| Entity lifetime, transforms, cameras, world projection | `scene`/entity/camera owners | Consume a versioned screen-space anchor snapshot; never own ECS state. |
| DataFrame/query/storage | data modules | Own view state, sorting requests, selection, virtualization window, and adapters only. |

Document this table in the architecture source and module spec. Any exception must name the owner, data direction, lifetime, and reason.

## P0 — Consolidate UI rendering around `RenderCommand`

- Keep semantic widget measurement/layout and widget-to-command lowering in UI.
- Move or replace the pixel algorithms in `src/ui/render/cpu.rs` and related helpers with `src/render/software_capture.rs` command replay.
- Define one supported command subset for headless capture. Unsupported commands must return diagnostics, not render silently differently.
- Build parity fixtures that feed the same UI command list to GPU and software paths and compare structure plus tolerant golden images for text, clipping, transforms, gradients, images, and nested containers.
- Remove duplicate blending, clipping, shape, text, and image sampling logic only after parity is proven.
- Ensure UI has no direct `wgpu` imports and render has no widget-type imports.

## P0 — Introduce dirty generations and incremental recomputation

Track distinct generations rather than one broad dirty flag:

- tree topology;
- intrinsic measurement/text;
- style/theme;
- layout geometry;
- input/hit regions and z order;
- visual commands;
- viewport/DPI/safe area.

Required behavior:

- A mutation marks the smallest affected subtree and propagates only the dependencies that need recomputation.
- `ensure_input_layout` becomes a cheap generation check; pointer movement over a clean tree performs no layout pass.
- Cache parent/depth/order metadata and invalidate it on topology changes rather than recalculating it during every query.
- Cache per-widget command chunks and rebuild only dirty chunks. Compose them in deterministic order into the bounded render stream.
- Cache text measurement by font handle/generation, content, wrap width, scale, and relevant style. Invalidate on font release or DPI/theme change.
- Reuse scratch vectors and command buffers with capped retained capacity so a single extreme frame does not permanently bloat memory.

## P0 — Establish measurable UI performance budgets

Create release-mode benchmarks/stress scenarios for:

- clean-frame update/render with 100, 1,000, and the configured maximum widgets;
- pointer move, click hit test, focus traversal, modal routing, and drag/drop on wide and deep trees;
- one-leaf style/text mutation versus full-theme and viewport invalidation;
- large virtualized list/table/tree scrolling;
- layout load/validation and headless capture at supported limits;
- callback-heavy event dispatch and widget churn.

Record median/p95 time, allocations, peak retained capacity, commands generated, nodes measured, nodes laid out, nodes hit-tested, and cache hit rates. Set initial ceilings from a reproducible baseline on the supported reference environment; do not invent thresholds without measurements. Wire a stable subset into `perf_regression_gate.py`.

## P1 — Optimize hit testing and focus routing from evidence

- First remove redundant layout/sort work and cache stable z/depth/parent metadata.
- Maintain a flat, ordered list of interactive visible widgets for focus and common hit tests.
- Add a spatial index only if the benchmark still shows linear hit testing as material. If added, UI owns it, rebuilds affected regions incrementally, and validates results against the canonical rectangle/clip traversal in randomized tests.
- Cache active modal membership and focus rings by tree generation.
- Coalesce pointer-move and hover transitions safely while preserving press/release/click ordering.
- Keep deterministic tie-breaking for equal z/order values.

## P1 — Complete or remove inert public features

### Entity attachment

- Decide the public contract before implementation. Recommended: scene/camera code publishes a versioned, read-only screen anchor containing position, visibility, optional depth, and viewport identity; UI consumes it during layout.
- Define missing entity, off-screen, behind-camera, camera-change, destroyed entity, and multi-viewport behavior.
- Do not let UI query or mutate ECS/world state directly.
- If the bridge cannot be made coherent, deprecate and remove `attachToEntity` instead of leaving stored inert state.

### Status-bar section widgets

- Implement section content as a validated `WidgetId` with ownership/reparenting rules, layout measurement, clipping, input routing, destruction cleanup, and cycle prevention.
- If text-only sections are the intended scope, deprecate `setSectionWidget` and remove the no-op. A callable no-op is not API coverage.

### Toolbar separators and spacers

- Represent separators/spacers as explicit toolbar items or child widgets so they affect measurement, layout, rendering, hit testing, serialization, and accessibility consistently.
- Define fixed/flexible spacer behavior and minimum/maximum sizing.
- Remove any methods that cannot be given visible semantics.

## P1 — Add high-value, non-duplicating UI capabilities

Only begin after identity, limits, and performance foundations are complete.

1. **Virtualized collection views**
   - UI owns visible-range calculation, recycled row widgets, scrolling, selection, keyboard navigation, and accessibility positions.
   - Data modules retain storage/query/sort/filter ownership through a pull adapter.
   - Support lists, tables, and trees through one virtualization primitive rather than three independent caches.

2. **Declarative layout diagnostics and reconciliation**
   - Provide schema/version validation and source-located diagnostics.
   - Reconcile a changed layout by stable declarative IDs while preserving compatible focus/scroll/state.
   - Do not add a competing general scene serializer or graph layout engine.

3. **Accessibility semantics**
   - Add role, label, value, description, disabled/expanded/selected states, focus order, and activation actions at the UI semantic layer.
   - Platform accessibility bridging belongs at the app/window edge; UI exports a bounded semantic tree snapshot.

4. **Viewport, DPI, and safe-area inputs**
   - Window/app owns physical scale and safe-area discovery; UI consumes normalized values and invalidates the affected generations.
   - Avoid a second window/display API inside UI.

Features deliberately excluded from UI ownership:

- font shaping/rasterization, image codecs, GPU shaders, texture atlases, ECS storage, camera projection, raw device polling, filesystem sandboxing, generic graph layout algorithms, and data query engines.

## P1 — Refactor oversized implementation seams

Refactor only behind passing behavior tests and without changing the public API accidentally.

- Split `src/lua_api/ui_api.rs` registration into widget-family registration modules plus shared checked handle/conversion helpers. Keep engine behavior in `src/ui`, not in registration closures.
- Split `src/ui/context/input.rs` by routing concern: hit testing/focus, pointer capture/drag, keyboard/text/IME, complex-widget interaction, and event production.
- Split `src/ui/render.rs` into measurement/lowering/cache orchestration; remove software raster ownership as described above.
- Split broad widget definition files by stable widget families only when imports and ownership become clearer.
- Require each new file to have a concrete file-level `//!` contract and no circular module dependencies.

## P2 — Provide bounded telemetry and diagnostics

- Add last-frame and cumulative UI stats: live widgets, dirty/recomputed widgets, layout depth, commands, hit-test candidates, event queue high-water mark, callback failures, capture time, and limit rejections.
- Separate faults from normal activity. A healthy frame must not report an error merely because work occurred.
- Expose a read-only Lua diagnostics snapshot suitable for development builds; cap stored messages and avoid exposing internal pointers/paths.
- Make telemetry cheap or disabled in release builds where appropriate, while keeping safety counters active.

## Verification matrix

- Structural parity: cached/incremental output equals a forced full recomputation for randomized trees.
- Visual parity: GPU and software capture fixtures remain within defined tolerances.
- Performance: clean pointer movement does not trigger layout; a leaf mutation visits only the expected dependency region.
- Memory: capacities remain within limits after an extreme rejected request and shrink/reset according to policy.
- Scope: dependency checks show UI does not import `wgpu`, ECS registries, direct host filesystem code, font raster internals, or image codecs.
- Features: entity attachment, section widgets, separators, and spacers either have end-to-end semantic tests or are explicitly deprecated/removed.

## Exit criteria

- UI owns one retained widget system and one lowering path; render owns all command execution and pixel replay.
- Module boundaries are documented and enforceable with dependency checks.
- UI-specific release benchmarks and ceilings exist and pass.
- Incremental results are proven equivalent to full recomputation.
- No public feature remains an inert stored field or deliberate no-op.
- New capabilities reuse owner-module services instead of duplicating them.

