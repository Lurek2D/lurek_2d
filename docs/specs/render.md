<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/render.md or source docstrings instead. -->

# render

## TL;DR

- Orchestrates the engine's visual backend using a device-facing wgpu renderer.
- Supports shapes, batched textures, off-screen canvases, and dynamic font rasterization.
- Enables custom WGSL shaders, chained post-processing filters, and stencil portal masks.
- Projects 3D Wavefront models into 2D vertex meshes with software screenshot readbacks.

## General Info

- Module group: `Platform Services`
- Source path: `src/render`
- Binding: `src/lua_api/render_api.rs`
- Namespace: `lurek.render`
- Lua API surface: `123` functions, `14` types, `92` methods
- User-facing: `true`
- Plugin tier: `not_evaluated`

## Summary

- The `render` module is the engine's central visual execution layer, responsible for turning high-level drawing intent from many other systems into concrete frame output on GPU-backed and software-backed paths.
- Its most important user-facing role is normalization. Different modules can describe sprites, shapes, text, overlays, tiles, provinces, lights, effects, or custom geometry in their own terms while still relying on one shared renderer to decide how those requests become final pixels.
- This makes `render` less like one feature among many and more like the final translation authority for visual state. Other modules decide what should exist visually, but `render` decides how that existence is encoded, ordered, shaded, and emitted.
- The module spans several rendering families at once: sprite and texture drawing, text output, shape drawing, mesh and geometry support, canvas-like targets, shader pipelines, post-processing, lighting, shadows, decals, screenshots, and software-render evidence paths.
- GPU resource ownership is a core part of that responsibility. Buffers, textures, samplers, shader modules, bind groups, pipelines, intermediate targets, typed GPU-side records, and staging resources live here so the rest of the engine does not fragment backend management.
- Resource inputs are validated before backend allocation or shader-source generation: texture and canvas dimensions must be non-zero and within device limits, RGBA uploads must match exact byte length, dynamic font atlases are bounded, OBJ material paths must stay under their base directory, and shader uniform names must be valid non-reserved WGSL identifiers.
- Centralizing those resources matters because otherwise each visual feature would invent its own backend conventions, lifetime rules, and upload paths. `render` provides one stable home for those concerns and reduces backend duplication.
- Rendering commands and pipeline structures give the engine a common language between feature modules and execution code. This shared command vocabulary is what allows gameplay-facing APIs to remain expressive while still mapping onto a disciplined backend.
- The module is broader than simple 2D quad drawing. Mesh support, OBJ loading, tessellation, decals, shape batching, and specialized pipelines show that it can represent both standard 2D workflows and richer geometric or stylized visual features without leaving the engine's main render authority.
- Text and font integration are part of the same visual surface, not a parallel universe. Menus, labels, debug overlays, editor tools, and evidence images all need text rendering that cooperates with layers, transforms, clipping, and final composition.
- Post-processing support matters after scene composition has already happened. Once a view exists, users often want bloom-like treatments, color transforms, blur-like effects, or custom shader passes, and `render` provides the controlled place where those frame-wide or target-specific effects belong.
- Lighting and shadow support connect scene-level illumination data to actual frame execution. Neighboring modules define lights, occluders, and light-world state, but `render` owns how those concepts become shaded images, masks, and composited outputs.
- Camera-aware and viewport-aware composition are part of the same boundary. Data coming from tilemaps, particles, raycasters, provinces, overlays, and UI all eventually has to agree on transforms, clipping regions, target sizes, and layer order, and `render` is where that agreement is enforced.
- Software-render and capture paths are a major practical capability, not an afterthought. They make it possible to generate deterministic screenshots, evidence images, docs artifacts, test outputs, and headless previews without relying on an interactive GPU session.
- The module therefore serves both runtime presentation and development workflow needs. It is equally relevant when the goal is shipping a frame to the screen and when the goal is extracting a reproducible image for debugging or documentation.
- Render-target management matters for the same reason, because complex scenes often need offscreen surfaces, intermediate passes, and controlled composition order to stay inspectable and stable.
- The renderer is therefore not just a drawer of primitives, but the arbiter of when and where visual work becomes final output.
- That backend discipline is what lets several higher-level modules share one frame pipeline without each inventing its own incompatible render lifecycle.
- For users, the important boundary is that `render` does not usually define domain meaning. It does not decide enemy AI, tile adjacency, or UI layout policy. Instead, it owns the visual execution model that allows those domains to appear consistently.
- Read `render` as the final visual translation layer of the engine. Feature modules describe visual state and intent, and `render` turns that intent into frames, captures, shadows, text, effects, and finished composited output for a shared frame contract.

This module primarily collaborates with `font`, `image`, `light`, `math`, `runtime`, `sprite`. Its responsibility should stay inside the Platform Services group rather than absorb behavior owned by those neighbors.

### Render Input Invariants

- Texture uploads require non-zero width and height, exact RGBA8 byte length, checked pixel arithmetic, and dimensions no larger than the active wgpu device limit.
- Canvas GPU allocations require non-zero width and height within the same 2D texture dimension limit; changing a canvas size under the same key recreates its GPU backing texture.
- Dynamic font creation clamps very small point sizes upward and rejects non-finite, oversized, zero-dimension, or oversized atlas allocations before CPU buffer growth.
- Mesh upload and Lua-facing mesh construction reject non-finite vertex fields, out-of-range indices, and incomplete triangle-list topology before static geometry is synchronized.
- OBJ face indices are bounded after 1-based or negative-index normalization, index zero is invalid, and material-library paths must stay under the supplied base directory.
- Shader uniform names must be valid, non-reserved WGSL identifiers before they can participate in wrapper-source generation.
- Render commands and registered compound shapes pass through a central input sanitizer before backend work; non-finite floats, invalid sizes, out-of-range colors, excessive segments, and malformed point arrays are rejected and counted.
- Arc tessellation clamps zero segment counts to a safe minimum before vertex generation.
- Draw-layer ordering uses total floating-point ordering and callback ID tie-breaks, so NaN and equal depths flush deterministically.
- `RenderDiagnostics` records skipped render commands, missing GPU or shape resources, invalid uploads, invalid meshes, GPU buffer growth, and shader or pipeline cache fallback events without turning the frame into a hard error.
- Frame-local color, texture, draw, instance, merge, and command scratch buffers clear between frames without shrinking; hot flat-color primitives tessellate directly into shared frame buffers and textured paths reuse scratch buffers instead of allocating per command.
- Shadow edge collection filters disabled, masked-out, and out-of-radius occluders before GPU upload, reuses per-occluder world-space edge caches for shadow lights in the same frame, and records rendered shadow rows plus collected and culled edge counts.
- `SoftwareCaptureDiagnostics` records unsupported capture commands and bounded polygon fill behavior; software capture is evidence-oriented and does not promise pixel parity for GPU-only texture, shader, post-fx, layer, batch, or registered-resource commands.

## Ownership

- Canonical source: `src/render`
- Owning tier: `Platform Services`
- Plugin tier: `not_evaluated`
- Lua binding owner: `src/lua_api/render_api.rs`
- Referenced engine modules: `font`, `image`, `light`, `math`, `province`, `runtime`, `sprite`

## Imports

- `font`: Imports or references `src/font/`. Dependency stays inside `Platform Services` and should remain acyclic.
- `image`: Imports or references `src/image/`. Dependency stays inside `Platform Services` and should remain acyclic.
- `light`: Imports or references `src/light/`. Dependency stays inside `Platform Services` and should remain acyclic.
- `math`: Imports or references `src/math/`. Cross-group dependency from `Platform Services` into `Foundations`.
- `province`: Imports or references `src/province/`. Cross-group dependency from `Platform Services` into `Feature Systems`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Platform Services` into `Core Runtime`.
- `sprite`: Imports or references `src/sprite/`. Cross-group dependency from `Platform Services` into `Feature Systems`.

## Source Files

### canvas.rs

- This file owns `Canvas`, the minimal metadata record for fixed-size off-screen render targets.
- It stores only pixel dimensions and logs creation, leaving GPU allocation and rendering behavior to larger owners.
- Open this file when canvas identity changes; renderer pipelines and image effects remain in sibling modules.

### decal_surface.rs

- Defines the metadata record for persistent decal draw surfaces that later become GPU-backed paint targets.
- Stores durable width and height only, leaving allocation and rendering behavior to heavier renderer owners.
- Open this file when decal surface identity or dimensions change rather than GPU upload or paint logic.

### draw_layer.rs

- Owns the draw layer model for the render subsystem and keeps its rules local to this file.
- Centers the implementation around LayerEntry, DrawLayerError, fmt, with helpers kept close to their invariants.
- Defines how draw layer data is validated, transformed, or stored before neighboring systems use it.
- Owns render behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on draw layer behavior while Lua registration stays elsewhere.

### extracted_blocks.rs

- Implements CPU-side geometry generation for primitive 2D shapes before vertices and indices reach GPU buffers.
- Builds triangles for arcs, circles, ellipses, sectors, rounded rectangles, and other reusable draw primitives.
- Expands thick strokes into quads so line width and outline visuals stay explicit instead of shader-implied.
- Translates abstract blend requests into concrete wgpu state descriptors used by the higher renderer pipeline.
- Uses adaptive step counts for curves so smoothness scales with shape size without exploding segment counts.
- Supports solid, wireframe, and textured geometry builders instead of forcing one tessellation path for all.
- Keeps shape-construction policy separate from GPU orchestration so render passes can stay focused on dispatch.
- Acts as the geometry boundary between high-level draw commands and raw vertex/index streams.
- Open this file when primitive tessellation, stroke expansion, or curve segmentation produces wrong geometry.

### gpu_canvas_pass.rs

- Owns the gpu canvas pass owner for the render subsystem and keeps its rules local to this file.
- Keeps render data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
- Defines how gpu canvas pass data is validated, transformed, or stored before neighboring systems use it.
- Owns render behavior with explicit state, validation, and crate-local integration boundaries.

### gpu_draw_encode.rs

- Owns the gpu draw encode owner for the render subsystem and keeps its rules local to this file.
- Keeps render data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
- Defines how gpu draw encode data is validated, transformed, or stored before neighboring systems use it.
- Owns render behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on gpu draw encode behavior while Lua registration stays elsewhere.
- Documents the boundary where render code accepts inputs, reports errors, or updates state.
- Use this file when changing gpu draw encode defaults, lifecycle handling, validation, or data ownership.

### gpu_frame_builder.rs

- Owns the gpu frame builder owner for the render subsystem and keeps its rules local to this file.
- Keeps render data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
- Defines how gpu frame builder data is validated, transformed, or stored before neighboring systems use it.
- Owns render behavior with explicit state, validation, and crate-local integration boundaries.

### gpu_light.rs

- Defines GPU-side light pass limits and layouts that keep deferred lighting and shadow memory bounded.
- Holds the light-state contract used by the renderer to size additive passes and shadow-related resources.
- Keeps light-capacity and layout policy separate from the frame loop that consumes those resources.
- Open this file when light buffer limits or deferred-light layout assumptions need coordinated changes.

### gpu_pipeline.rs

- Builds and caches wgpu render pipelines so repeated material and geometry combinations compile only once.
- Keys pipelines by geometry kind, blend state, stencil mode, and custom shader selection inputs.
- Chooses built-in shader paths when callers do not supply overrides, keeping fallback behavior centralized.
- Generates helper WGSL fragments and uniform declarations needed by custom color and texture pipelines.
- Standardizes alpha, additive, multiplicative, and replace blend policies for the whole render subsystem.
- Configures depth and stencil state mapping so pipeline creation reflects the front-end render command model.
- Acts as the pipeline-construction boundary rather than the owner of per-frame draw traversal.
- Open this file when render state caching, blend mapping, or custom shader pipeline assembly is incorrect.

### gpu_renderer.rs

- Owns the main hardware renderer that turns front-end render commands into concrete wgpu draw submission.
- Manages device, queue, swapchain, canvases, textures, and persistent GPU state under one frame orchestrator.
- Drives multi-pass flow for scene color, shadows, decals, text, province maps, and post-processing output.
- Coalesces compatible draw calls so repeated materials and textures do not force unnecessary pipeline churn.
- Uploads and reuses static geometry to bypass repeated tessellation and reduce CPU-side frame overhead.
- Supports GPU instancing for repeated sprites, particles, and grid-like content that share one draw shape.
- Delegates text glyph replay to a focused owner while batching the resulting draw work with the frame.
- Maintains offscreen canvases as render targets so composite views and multi-surface workflows stay possible.
- Handles resize, viewport updates, and target-dimension logic that keep swapchain-backed output coherent.
- Owns readback orchestration for surfaces when screenshots or software-visible capture need GPU results.
- Bridges lighting, shadows, geometry, and resource owners instead of embedding their detailed policies here.
- Acts as the runtime boundary between the engine's render command language and low-level wgpu execution.
- Concentrates helper routines near state so render-frame changes remain auditable despite subsystem breadth.
- Open this file when full-frame GPU output is wrong and the fault is not isolated to one narrow helper owner.
- It is the right owner for render orchestration bugs because most GPU passes and resource handoffs converge here.

### gpu_resources.rs

- Owns the gpu resources owner for the render subsystem and keeps its rules local to this file.
- Keeps render data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
- Defines how gpu resources data is validated, transformed, or stored before neighboring systems use it.
- Owns render behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on gpu resources behavior while Lua registration stays elsewhere.
- Documents the boundary where render code accepts inputs, reports errors, or updates state.
- Use this file when changing gpu resources defaults, lifecycle handling, validation, or data ownership.
- Keeps failure paths and edge cases near the render state that can explain them while keeping call sites explicit.
- Preserves deterministic behavior by keeping gpu resources calculations explicit at their owner boundary.

### gpu_screenshot_readback.rs

- Owns the gpu screenshot readback owner for the render subsystem and keeps its rules local to this file.
- Keeps render data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
- Defines how gpu screenshot readback data is validated, transformed, or stored before neighboring systems use it.
- Owns render behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on gpu screenshot readback behavior while Lua registration stays elsewhere.

### gpu_shader_cache.rs

- Owns the gpu shader cache owner for the render subsystem and keeps its rules local to this file.
- Keeps render data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
- Defines how gpu shader cache data is validated, transformed, or stored before neighboring systems use it.
- Owns render behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on gpu shader cache behavior while Lua registration stays elsewhere.
- Documents the boundary where render code accepts inputs, reports errors, or updates state.

### gpu_shaders.rs

- Defines the GPU shader data structures that store compiled WGSL artifacts and uniform-kind metadata.
- Maps runtime uniform value classes onto the raw buffer layout variants expected by the render backend.
- Keeps compiled shader and pipeline cache state local so higher layers can treat shaders as reusable assets.
- Open this file when shader uniform typing or cached compiled shader state stops matching render needs.

### gpu_shadows.rs

- Owns GPU shadow-map preparation, light culling, edge extraction, and compute dispatch for dynamic shadows.
- Collects occluder edge geometry and uploads it into GPU buffers consumed by shadow compute passes.
- Dispatches one-dimensional shadow map work per visible light source so light distance fields stay current.
- Performs viewport and radius culling before queueing shadow work, reducing unnecessary compute load.
- Manages the bind groups, buffers, and pipelines that connect light data to the shadow atlas workflow.
- Filters occluders by light masks so only relevant blocking geometry contributes to a given light pass.
- Reuses per-occluder world-space edge lists across shadow lights until occluder geometry generation changes.
- Acts as the shadow-runtime boundary rather than the owner of general draw command interpretation.
- Open this file when shadow edges, light culling, or compute-driven shadow atlas updates behave incorrectly.

### gpu_shape_replay.rs

- Owns the gpu shape replay owner for the render subsystem and keeps its rules local to this file.
- Centers the implementation around replay_compound_shape, with helpers kept close to their invariants.
- Defines how gpu shape replay data is validated, transformed, or stored before neighboring systems use it.
- Owns render behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on gpu shape replay behavior while Lua registration stays elsewhere.
- Documents the boundary where render code accepts inputs, reports errors, or updates state.

### gpu_state.rs

- Owns render behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps render data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
- Defines how gpu state data is validated, transformed, or stored before neighboring systems use it.
- Owns render behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on gpu state behavior while Lua registration stays elsewhere.
- Documents the boundary where render code accepts inputs, reports errors, or updates state.

### gpu_tess.rs

- Converts high-level 2D draw shapes into GPU-ready vertices and indices for the hardware renderer pipeline.
- Tessellates rectangles, circles, arcs, glyph quads, sprites, and meshes under one geometry conversion owner.
- Adapts curve segment counts to screen-space radius so curved shapes stay smooth across different zoom levels.
- Builds stroked lines as quads with explicit widths, supporting borders, outlines, and dashed style variants.
- Packs position, uv, tint, and transform data into ColorVertex and TexVertex streams expected by GPU code.
- Applies local transforms per vertex so nested coordinate systems do not need pre-flattened geometry upstream.
- Computes scissor rectangles and culls out-of-bounds geometry to reduce wasted GPU work and visual artifacts.
- Acts as the GPU tessellation boundary between front-end draw intent and raw vertex buffer contents.
- Open this file when hardware path geometry, scissor math, or shape triangulation behaves incorrectly.

### gpu_text_replay.rs

- Owns the gpu text replay owner for the render subsystem and keeps its rules local to this file.
- Keeps render data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
- Defines how gpu text replay data is validated, transformed, or stored before neighboring systems use it.
- Owns render behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on gpu text replay behavior while Lua registration stays elsewhere.
- Documents the boundary where render code accepts inputs, reports errors, or updates state.
- Use this file when changing gpu text replay defaults, lifecycle handling, validation, or data ownership.

### gpu_types.rs

- Defines the bytemuck-safe raw GPU structs used for vertices, uniforms, shadow edges, and draw batching.
- Packs positions, colors, uv data, normals, and instance transforms into layouts copied directly to buffers.
- Keeps binary layout contracts centralized so renderer, shader, and upload code agree on memory shape.
- Stores batching metadata that later passes use to coalesce draw dispatches with compatible GPU state.
- Acts as the binary-ABI boundary between Rust-side render state and WGSL-visible buffer contents.
- Open this file when GPU struct layout, bytemuck compatibility, or instance data packing is incorrect.

### image_effect.rs

- Defines the compact post-processing effect descriptor used to name and parameterize one shader-based step.
- Keeps effect identity and lightweight setup separate from the heavier postfx pipeline that executes it.
- Open this file when per-effect descriptor shape changes rather than full post-processing runtime behavior.

### input_validation.rs

- Owns the input validation owner for the render subsystem and keeps its rules local to this file.
- Keeps render data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
- Defines how input validation data is validated, transformed, or stored before neighboring systems use it.
- Owns render behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on input validation behavior while Lua registration stays elsewhere.
- Documents the boundary where render code accepts inputs, reports errors, or updates state.
- Use this file when changing input validation defaults, lifecycle handling, validation, or data ownership.
- Keeps failure paths and edge cases near the render state that can explain them while keeping call sites explicit.
- Preserves deterministic behavior by keeping input validation calculations explicit at their owner boundary.
- Provides the local adaptation layer that lets callers avoid duplicating render rules while keeping call sites explicit.

### mesh.rs

- Owns the mesh owner for the render subsystem and keeps its rules local to this file while keeping call sites explicit.
- Centers the implementation around MeshDrawMode, MeshVertex, default, with helpers kept close to their invariants.
- Defines how mesh data is validated, transformed, or stored before neighboring systems use it.
- Owns render behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on mesh behavior while Lua registration stays elsewhere.
- Documents the boundary where render code accepts inputs, reports errors, or updates state.

### mod.rs

- Exports the render subsystem surface that groups canvases, GPU owners, shapes, shaders, and pipelines.
- Acts as the render ownership index so callers can map a rendering concern to its concrete Rust owner file.
- Centralizes module visibility and re-exports instead of storing live frame state or issuing draw work itself.
- Connects front-end draw commands, geometry assets, shader tools, and GPU execution modules into one stack.
- Provides the first navigation point when tracing whether a render issue belongs to shaders, resources, or passes.
- Keeps the public render surface coherent while allowing narrow files like mesh or image_effect to stay focused.
- Open this file first when adding a render owner or changing shared render API re-export policy.
- Use it to locate the right implementation file before editing orchestration, resources, geometry, or shaders.

### obj_loader.rs

- Loads Wavefront OBJ and MTL data into reusable mesh structures and CPU-projected renderable geometry.
- Parses faces, materials, vertices, normals, and texture coordinates while normalizing OBJ indexing rules.
- Projects source geometry into viewport-friendly coordinates using simple camera-style transforms.
- Computes normals and back-face filtering so software preview and shading logic can make stable decisions.
- Resolves diffuse colors and texture paths from materials without forcing those rules into generic mesh owners.
- Includes CPU raster-style support used for thumbnailing, validation, or headless geometry inspection.
- Keeps OBJ-specific parsing and error handling separate from runtime GPU pipeline or tilemap import paths.
- Acts as the model-import boundary between external Wavefront assets and internal 2D mesh representations.
- Open this file when OBJ parsing, index normalization, material mapping, or projection output is incorrect.
- Read this owner before general mesh changes when the bug is limited to imported model content.

### offline_image_shader.rs

- Runs target-aware WGSL image shaders against `ImageData` through a temporary headless wgpu device.
- Keeps offline bitmap processing inside the render subsystem so image and Lua APIs never own `wgpu`.
- Uploads source RGBA bytes, renders a fullscreen pass into an offscreen RGBA8 texture, and reads pixels back.
- Uses the same fullscreen wrapper contract as post-processing shaders, preserving target validation semantics.
- Open this file when `ImageData:applyShader` or `lurek.image.requestShader` output differs from WGSL intent.

### postfx_pipeline.rs

- Owns post-processing pipeline setup and execution for screen-space shader passes over offscreen textures.
- Connects canvas textures, samplers, and effect uniforms to fullscreen draw operations executed after scene render.
- Groups effect parameters and swap textures so multi-pass blur, CRT, or color-correction chains stay organized.
- Configures pipeline states, write masks, and fallback shaders needed by default and custom postfx passes.
- Minimizes allocation churn by reusing descriptors and intermediate textures sized to current output targets.
- Stores custom post-processing registrations separately from the frame renderer so effect catalogs stay modular.
- Acts as the screen-pass boundary between a finished scene texture and final composited presentation output.
- Keeps shader-source and uniform conversion concerns local instead of spreading them across the main renderer.
- Open this file when post-processing order, texture swaps, or effect application behavior is incorrect.
- Use this owner for postfx bugs before changing the broader GPU renderer orchestration path.

### province_map_pipeline.rs

- Defines the specialized GPU pipeline used to render detailed province-map views with dedicated shader inputs.
- Binds region ids, border data, height-like fields, and viewport parameters needed by province-focused passes.
- Packages uniforms for zoom, map size, viewport range, and time so province visuals update coherently.
- Keeps province-specific bind groups and pipeline layout separate from the general-purpose render backend.
- Acts as the province-map boundary between geographic data textures and shader-driven fullscreen presentation.
- Open this file when province shader inputs, uniforms, or fullscreen province-map output behaves incorrectly.

### render_diagnostics.rs

- Owns the render diagnostics owner for the render subsystem and keeps its rules local to this file.
- Keeps render data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
- Defines how render diagnostics data is validated, transformed, or stored before neighboring systems use it.
- Owns render behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on render diagnostics behavior while Lua registration stays elsewhere.

### renderer.rs

- Owns render behavior with explicit state, validation, and crate-local integration boundaries.
- Centers the implementation around CompareMode, StencilAction, StencilMode, with helpers kept close to their invariants.
- Defines how renderer data is validated, transformed, or stored before neighboring systems use it.
- Owns render behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on renderer behavior while Lua registration stays elsewhere.
- Documents the boundary where render code accepts inputs, reports errors, or updates state.
- Use this file when changing renderer defaults, lifecycle handling, validation, or data ownership.
- Keeps failure paths and edge cases near the render state that can explain them while keeping call sites explicit.
- Preserves deterministic behavior by keeping renderer calculations explicit at their owner boundary.
- Provides the local adaptation layer that lets callers avoid duplicating render rules while keeping call sites explicit.

### shader.rs

- Owns user-facing shader parsing, validation, and uniform bookkeeping for custom WGSL-driven render effects.
- Wraps incoming WGSL source into renderer-ready templates so fragment entry points match engine expectations.
- Inspects fragment inputs and uniform declarations to reject unsupported bindings before runtime use.
- Represents uniform values in typed forms that later upload code can preserve in stable buffer order.
- Keeps wrapper generation and ordered-uniform logic local instead of scattering shader policy through backends.
- Acts as the custom-shader boundary between authored WGSL text and engine-managed pipeline integration.
- Open this file when shader source validation, wrapper rewriting, or uniform ordering behaves incorrectly.

### shape.rs

- Defines reusable vector shape assets as replayable command sequences with fill and stroke information.
- Packages path-like draw commands into named compound shapes that UI and gameplay code can reuse cheaply.
- Keeps shape recording separate from later tessellation so the same asset can feed multiple render paths.
- Acts as the vector-shape asset boundary rather than the owner of GPU conversion or final draw dispatch.
- Open this file when reusable shape definitions, command storage, or outline attributes behave incorrectly.

### software_capture.rs

- Owns the software capture owner for the render subsystem and keeps its rules local to this file.
- Keeps render data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
- Defines how software capture data is validated, transformed, or stored before neighboring systems use it.
- Owns render behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on software capture behavior while Lua registration stays elsewhere.
- Documents the boundary where render code accepts inputs, reports errors, or updates state.
- Use this file when changing software capture defaults, lifecycle handling, validation, or data ownership.
- Keeps failure paths and edge cases near the render state that can explain them while keeping call sites explicit.
- Preserves deterministic behavior by keeping software capture calculations explicit at their owner boundary.
- Provides the local adaptation layer that lets callers avoid duplicating render rules while keeping call sites explicit.



## Lua API Ref

### Functions

- `lurek.render.applyShaderToCanvas(canvas, shader, opts?) -> LCanvas`: Queues a postfx shader pass that mutates a canvas render target after queued canvas draws in the current frame.
- `lurek.render.applyTransform(mat) -> nil`: Multiplies the current transformation matrix by a 3x3 matrix (9 values in row-major order).
- `lurek.render.arc(mode, x, y, radius, angle1, angle2, segments?) -> nil`: Draws a filled or outlined circular arc segment.
- `lurek.render.beginSortGroup(id) -> nil`: Begins a depth-sorted rendering group. Draw calls within this group are sorted by pushSortKey values.
- `lurek.render.captureScreenshot(callback) -> nil`: Captures the queued 2D render commands into an ImageData fallback and passes it to a callback.
- `lurek.render.circle(mode, x, y, radius) -> nil`: Draws a filled or outlined circle at the given position.
- `lurek.render.clear(r?, g?, b?) -> nil`: Clears all queued render commands for the current frame.
- `lurek.render.clearStencil() -> nil`: Resets the stencil state to defaults (no stencil operations).
- `lurek.render.currentLayer() -> string`: Returns the name of the currently active rendering layer.
- `lurek.render.draw(drawable, x?, y?, r?, sx?, sy?, ox?, oy?) -> nil`: Draws a drawable object (Image, Canvas, SpriteBatch, or Mesh) at the given position with optional transform.
- `lurek.render.drawBatch(batch) -> nil`: Draws a SpriteBatch using the same queued DrawBatch command as lurek.render.draw(batch).
- `lurek.render.drawBevelRect(x, y, w, h, bevelW?, style?, opts?) -> nil`: Draws a beveled rectangle with highlight, shadow, and fill colors for 3D-style UI elements.
- `lurek.render.drawColoredPolygon(vertices, colors, mode?) -> nil`: Draws a polygon with per-vertex colors.
- `lurek.render.drawCubicBezier(x1, y1, cx1, cy1, cx2, cy2, x2, y2, segments?) -> nil`: Draws a cubic Bezier curve through start, two control points, and end.
- `lurek.render.drawGradientRect(x, y, w, h, c1, c2, dir?) -> nil`: Draws a rectangle with a two-color gradient fill.
- `lurek.render.drawHexTile(cx, cy, size, orientation?, mode?) -> nil`: Draws a regular hexagonal tile at the given center position.
- `lurek.render.drawIsoCubeTile(sx, sy, halfW, halfH, opts?) -> nil`: Draws an isometric cube tile with configurable face colors and optional textures.
- `lurek.render.drawMany(list) -> nil`: Batch-draws multiple images in one call. Each entry is a table: {image, x, y, r, sx, sy, ox, oy}.
- `lurek.render.drawNineSlice(slice, x, y, w, h) -> nil`: Draws a 9-slice image stretched to fill the given rectangle, keeping borders unscaled.
- `lurek.render.drawPath(path, mode?, close?) -> nil`: Draws a vector path composed of moveTo, lineTo, quadTo, and cubicTo segments.
- `lurek.render.drawQuadBezier(x1, y1, cx, cy, x2, y2, segments?) -> nil`: Draws a quadratic Bezier curve through start, control, and end points.
- `lurek.render.drawText(text, x, y, rotation?, sx?, sy?, ox?, oy?) -> nil`: Draws text using the active font with image-like transform parameters on the GPU.
- `lurek.render.drawTextWithFont(font, text, x, y, rotation?, sx?, sy?, ox?, oy?) -> nil`: Draws text using a specific font with image-like transform parameters on the GPU.
- `lurek.render.drawq(image, quad, x?, y?, r?, sx?, sy?, ox?, oy?) -> nil`: Draws a sub-region of an image defined by a Quad, with optional transform.
- `lurek.render.ellipse(mode, x, y, rx, ry) -> nil`: Draws a filled or outlined ellipse at the given position.
- `lurek.render.flushSortGroup(id) -> nil`: Ends a sort group and emits all accumulated draw calls in sorted order.
- `lurek.render.getBackgroundColor() -> number, number, number, number`: Returns the current background clear color.
- `lurek.render.getBlendMode() -> string`: Returns the current blend mode name.
- `lurek.render.getBuiltInFontNames() -> string[]`: Returns all stable built-in font names.
- `lurek.render.getCanvas() -> LCanvas`: Returns the currently active canvas, or nil if drawing to the screen.
- `lurek.render.getCanvasSize(canvas) -> number, number`: Returns the pixel dimensions of a canvas.
- `lurek.render.getColor() -> number, number, number, number`: Returns the current drawing color.
- `lurek.render.getColorMask() -> boolean, boolean, boolean, boolean`: Returns the current color write mask.
- `lurek.render.getDebugShader() -> LShader?`: Returns the active debug visualization shader, or nil if debug draws use the normal/default render shader path.
- `lurek.render.getDefaultFilter() -> string, string, number`: Returns the current default texture filtering settings.
- `lurek.render.getDefaultFont(pointSize?, bold?) -> LFont`: Returns a built-in default font at the nearest available bundled point size.
- `lurek.render.getDepthMode() -> string, boolean`: Returns the current depth comparison mode and write-enable flag.
- `lurek.render.getDimensions() -> number, number`: Returns the current window width and height.
- `lurek.render.getFont() -> LFont`: Returns the currently active font, or nil if none is set.
- `lurek.render.getFontAscent(font) -> number`: Returns the ascent (pixels above baseline) of the given font.
- `lurek.render.getFontCellWidth(font) -> number`: Returns the fixed cell width of a bitmap font.
- `lurek.render.getFontDescent(font) -> number`: Returns the descent (pixels below baseline) of the given font.
- `lurek.render.getFontHeight(font) -> number`: Returns the line height of the given font.
- `lurek.render.getFontLineHeight(font) -> number`: Returns the line spacing of the given font.
- `lurek.render.getFontSizes() -> number[]`: Returns all available built-in point sizes.
- `lurek.render.getFontWidth(font, text) -> number`: Measures the pixel width of text using the given font.
- `lurek.render.getFontWrap(text, limit) -> LuaValue, number`: Word-wraps text using the active font and returns the resulting lines and widest line width.
- `lurek.render.getHeight() -> number`: Returns the current window height in pixels.
- `lurek.render.getLayerZOrder(name) -> number`: Returns the z-order value of a named rendering layer.
- `lurek.render.getLineWidth() -> number`: Returns the current line width used for line-mode drawing.
- `lurek.render.getPointSize() -> number`: Returns the current point diameter used for point drawing.
- `lurek.render.getScissor() -> number, number, number, number`: Returns the current scissor rectangle, or nothing if no scissor is set.
- `lurek.render.getShader() -> LShader`: Returns the currently active shader, or nil if using the default.
- `lurek.render.getStats() -> table`: Returns a table of rendering statistics for the current frame.
- `lurek.render.getStencilMode() -> string, string, number`: Returns the current stencil action, compare mode, and reference value.
- `lurek.render.getTextShader() -> LShader?`: Returns the active text shader, or nil if font-atlas text uses the default/fallback shader path.
- `lurek.render.getWidth() -> number`: Returns the current window width in pixels.
- `lurek.render.intersectScissor(x, y, w, h) -> nil`: Intersects the given rectangle with the current scissor, narrowing the drawable region.
- `lurek.render.isBold() -> boolean`: Returns true if the current default font selection uses the bold variant.
- `lurek.render.isLayerVisible(name) -> boolean`: Returns whether a named rendering layer is currently visible.
- `lurek.render.isWireframe() -> boolean`: Returns whether wireframe rendering is currently active.
- `lurek.render.line(...) -> nil`: Draws a line between two points, or a polyline through multiple points.
- `lurek.render.loadModel(path) -> LObjModel`: Loads a 3D model file (OBJ format) and returns a handle for 2D projection and sprite rendering.
- `lurek.render.loadObj(path) -> LObjModel`: Loads a Wavefront OBJ model file and returns a model handle for projection and rendering.
- `lurek.render.newCanvas(width, height) -> LCanvas`: Creates a new off-screen render target with the given dimensions.
- `lurek.render.newDepthSorter() -> LDepthSorter`: Registers the depth-sorted drawing helper constructor in the render module.
- `lurek.render.newDrawLayer() -> LDrawLayer`: Creates a new z-ordered draw layer for sorting draw callbacks by depth.
- `lurek.render.newFont(pathOrSize, size?) -> LFont`: Creates a font from a built-in font name, a font file path, or a numeric built-in point-size selector.
- `lurek.render.newImage(pathOrData, colorSpace?) -> LImage`: Loads a texture from a file path or creates one from an ImageData object.
- `lurek.render.newLayer(name, zOrder?) -> nil`: Creates a named rendering layer with an optional z-order for draw call organization.
- `lurek.render.newMesh(verts, mode?) -> LMesh`: Creates a custom vertex mesh from an array of vertex data tables.
- `lurek.render.newQuad(x, y, w, h, sw, sh) -> LQuad`: Creates a Quad defining a rectangular sub-region of a texture for sprite-sheet rendering.
- `lurek.render.newShader(code, opts?) -> LShader`: Compiles a target-aware WGSL fragment shader through the render module and returns a shader handle.
- `lurek.render.newShape() -> LShape`: Creates a new retained compound shape for accumulating draw commands.
- `lurek.render.newSpriteBatch(image, max?) -> LSpriteBatch`: Creates a batched sprite renderer for efficiently drawing many copies of the same texture.
- `lurek.render.origin() -> nil`: Resets the current transformation matrix to the identity (no transform).
- `lurek.render.points(...) -> nil`: Draws one or more points. Accepts either a table of {x,y} pairs or flat x,y coordinate values.
- `lurek.render.polygon(mode, ...) -> nil`: Draws a polygon from a flat list of x,y vertex coordinates.
- `lurek.render.pop() -> nil`: Pops the top transformation matrix from the transform stack, restoring the previous one.
- `lurek.render.popLayer(id) -> nil`: Ends a compositing layer and composites it with the previous content.
- `lurek.render.print(text, x?, y?, scale?) -> nil`: Draws text using the active font at the given position.
- `lurek.render.printRich(spans, x, y, rotation?, sx?, sy?, ox?, oy?) -> nil`: Draws rich text composed of individually styled spans at the given position.
- `lurek.render.printRichWithFont(font, spans, x, y, rotation?, sx?, sy?, ox?, oy?) -> nil`: Draws rich text using a specific font without changing the global active font.
- `lurek.render.printRotated(text, x, y, angle, scale?) -> nil`: Draws text centered and rotated around its midpoint.
- `lurek.render.printRotatedWithFont(font, text, x, y, angle, scale?) -> nil`: Draws text centered and rotated around its midpoint using a specific font without changing the global active font.
- `lurek.render.printWithFont(font, text, x?, y?, scale?) -> nil`: Draws text using a specific font without changing the global active font.
- `lurek.render.printf(text, x, y, limit, align?) -> nil`: Draws word-wrapped and aligned text within a pixel-width limit.
- `lurek.render.printfWithFont(font, text, x, y, limit, align?) -> nil`: Draws word-wrapped and aligned text with a specific font without changing the global active font.
- `lurek.render.push() -> nil`: Pushes the current transformation matrix onto the transform stack.
- `lurek.render.pushLayer(id, alpha?, blendMode?) -> nil`: Begins a compositing layer with the given alpha and blend mode. Must be paired with popLayer.
- `lurek.render.pushSortKey(depth) -> nil`: Sets the depth sort key for subsequent draw calls within the current sort group.
- `lurek.render.rectangle(mode, x, y, w, h, rx?, ry?) -> nil`: Draws a rectangle. If rx is provided, draws a rounded rectangle.
- `lurek.render.resetCanvas(canvas) -> nil`: Marks a canvas as needing a full clear before its next render pass. Use before re-rendering to avoid content accumulation.
- `lurek.render.rotate(angle) -> nil`: Applies a rotation to the current transformation matrix.
- `lurek.render.saveScreenshot(path) -> nil`: Saves a screenshot of the current frame to a file under the save/ directory.
- `lurek.render.scale(sx, sy?) -> nil`: Applies scaling to the current transformation matrix.
- `lurek.render.setBackgroundColor(r, g, b) -> nil`: Sets the background clear color used at the start of each frame.
- `lurek.render.setBlendMode(mode) -> nil`: Sets the blend mode for subsequent draw operations.
- `lurek.render.setBold(bold) -> nil`: Sets whether subsequent font size lookups use the bold Courier New variant.
- `lurek.render.setCanvas(canvas?) -> nil`: Redirects all subsequent drawing to the given canvas. Pass nil to draw to the screen again.
- `lurek.render.setColor(r, g, b, a?) -> nil`: Sets the active drawing color for all subsequent draw operations.
- `lurek.render.setColorMask(r?, g?, b?, a?) -> nil`: Sets which color channels are written during draw calls. Call with no args to enable all.
- `lurek.render.setDebugShader(shader?) -> nil`: Activates a debugviz-target WGSL shader for subsequent diagnostic/debug draw commands. Pass nil to restore the normal draw shader state.
- `lurek.render.setDefaultFilter(min, mag, anisotropy?) -> nil`: Sets the default texture filtering mode for newly created images.
- `lurek.render.setDefaultFont(pointSize?, bold?) -> LFont`: Selects a built-in default font by bundled point size and makes it the active render font.
- `lurek.render.setDepthMode(mode, write?) -> nil`: Sets the depth comparison mode and whether depth writes are enabled.
- `lurek.render.setFont(font) -> nil`: Sets the active font used by print, printf, and other text rendering calls.
- `lurek.render.setFontLineHeight(font, lh) -> nil`: Sets the line height override for a font (currently a no-op stub).
- `lurek.render.setLayer(name) -> nil`: Sets the active rendering layer by name. Creates the layer if it does not exist.
- `lurek.render.setLayerVisible(name, visible) -> nil`: Sets whether a named rendering layer is visible.
- `lurek.render.setLayerZOrder(name, z) -> nil`: Sets the z-order value of a named rendering layer.
- `lurek.render.setLineWidth(w) -> nil`: Sets the line width for subsequent line-mode draw calls.
- `lurek.render.setPointSize(size) -> nil`: Sets the point size for subsequent point draw calls.
- `lurek.render.setScissor(x?, y?, w?, h?) -> nil`: Sets or clears the scissor rectangle. Only pixels inside this region are drawn. Call with no args to clear.
- `lurek.render.setShader(shader?) -> nil`: Activates a shader for subsequent draw calls. Pass nil to restore the default shader.
- `lurek.render.setStencilMode(action, compare?, value?) -> nil`: Sets the stencil write action, compare function, and reference value at once.
- `lurek.render.setStencilTest(compare?, value?) -> nil`: Configures the stencil comparison test for subsequent draws. Pass nil to disable.
- `lurek.render.setTextShader(shader?) -> nil`: Activates a text-target WGSL shader for subsequent font-atlas text draws. Pass nil to restore default text rendering.
- `lurek.render.setWireframe(enabled) -> nil`: Enables or disables wireframe rendering mode.
- `lurek.render.shear(kx, ky) -> nil`: Applies a shear (skew) to the current transformation matrix.
- `lurek.render.stencil(action?, value?) -> nil`: Begins a stencil write pass with the given action and reference value.
- `lurek.render.translate(x, y) -> nil`: Applies a translation to the current transformation matrix.
- `lurek.render.triangle(mode, x1, y1, x2, y2, x3, y3) -> nil`: Draws a triangle from three vertex positions.

### Callbacks

- `LDrawLayer:queue` param `f` (`function`): Callback to invoke during flush.
- `LImageData:mapPixels` param `callback` (`function`): Called as callback(x, y, r, g, b, a) â†’ (r, g, b, a) for each pixel. Invocation: `callback(x, y, r, g, b, a)`.
- `lurek.render.captureScreenshot` param `callback` (`function`): Called with an LImageData argument.

### Enums

- No documented module-level enums/constants.

### Types

#### LCanvas Type

- Off-screen render target that can be drawn to and then composited onto the screen.

##### Fields

- No documented fields.

##### Methods

- `LCanvas:applyShader(shader, opts?) -> LCanvas`: Queues a postfx shader pass that mutates this canvas render target after queued canvas draws in the current frame.
- `LCanvas:getDimensions() -> number, number`: Returns both width and height of this canvas.
- `LCanvas:getHeight() -> number`: Returns the height of this canvas in pixels.
- `LCanvas:getWidth() -> number`: Returns the width of this canvas in pixels.
- `LCanvas:release() -> boolean`: Releases the canvas GPU resource. If this canvas is currently active, drawing reverts to the screen.
- `LCanvas:type() -> string`: Returns the type name string for this canvas object.
- `LCanvas:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LDrawLayer Type

- Z-ordered draw callback layer for sorting draw calls by depth before flushing.

##### Fields

- No documented fields.

##### Methods

- `LDrawLayer:clear() -> nil`: Discards all queued callbacks without executing them.
- `LDrawLayer:flush() -> nil`: Sorts all queued callbacks by z-depth and executes them in order, then empties the layer.
- `LDrawLayer:getCount() -> number`: Returns the number of callbacks currently queued.
- `LDrawLayer:queue(z, f) -> nil`: Enqueues a draw callback at the given z-depth. Callbacks execute when flush() is called.
- `LDrawLayer:type() -> string`: Returns the type name string for this draw layer.
- `LDrawLayer:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LFont Type

- Bitmap font handle for measuring and rendering text.

##### Fields

- No documented fields.

##### Methods

- `LFont:getAscent() -> number`: Returns the ascent (pixels above the baseline) of this font.
- `LFont:getDescent() -> number`: Returns the descent (pixels below the baseline) of this font.
- `LFont:getHeight() -> number`: Returns the line height of this font in pixels.
- `LFont:getLineHeight() -> number`: Returns the spacing between consecutive lines of text.
- `LFont:getWidth(text) -> number`: Measures the pixel width of a string when rendered with this font.
- `LFont:getWrap(text, limit) -> table, number`: Word-wraps text to fit within a pixel width limit and returns the resulting lines.
- `LFont:release() -> boolean`: Releases the font resource. The handle becomes invalid after this call.
- `LFont:setLineHeight(height) -> nil`: Overrides the line height used for multi-line text rendering.
- `LFont:type() -> string`: Returns the type name string for this font object.
- `LFont:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LImage Type

- GPU-backed texture handle used for drawing images to screen.

##### Fields

- No documented fields.

##### Methods

- `LImage:getDimensions() -> number, number`: Returns both width and height of this image.
- `LImage:getHeight() -> number`: Returns the height of this image in pixels.
- `LImage:getId() -> number`: Returns the internal numeric handle ID for this image.
- `LImage:getWidth() -> number`: Returns the width of this image in pixels.
- `LImage:release() -> boolean`: Releases the GPU memory for this image. The handle becomes invalid after this call.
- `LImage:type() -> string`: Returns the type name string for this image object.
- `LImage:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LImageData Type

- Raw pixel buffer for CPU-side image manipulation before uploading to a GPU texture.

##### Fields

- No documented fields.

##### Methods

- `LImageData:blit(source, dstX, dstY) -> nil`: Copies pixel data from another ImageData onto this one at the specified position.
- `LImageData:diff(other) -> number`: Computes a numeric difference score between this image and another of the same size.
- `LImageData:getHeight() -> number`: Returns the height of this image data in pixels.
- `LImageData:getRegion(x, y, w, h) -> LImageData`: Extracts a rectangular sub-region as a new ImageData.
- `LImageData:getWidth() -> number`: Returns the width of this image data in pixels.
- `LImageData:mapPixels(callback) -> nil`: Iterates over every pixel and replaces its color with the return value of the callback.
- `LImageData:resize(w, h) -> LImageData`: Creates a new ImageData resized to the given dimensions using bilinear sampling.
- `LImageData:type() -> string`: Returns the type name of this object.
- `LImageData:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LMesh Type

- Custom vertex mesh for advanced 2D geometry rendering with per-vertex color and UV data.

##### Fields

- No documented fields.

##### Methods

- `LMesh:getVertex(index) -> number, number, number, number, number, number, number, number`: Returns the data for a single vertex by 1-based index.
- `LMesh:getVertexCount() -> number`: Returns the number of vertices in this mesh.
- `LMesh:release() -> boolean`: Releases the mesh GPU resource and invalidates the handle.
- `LMesh:setTexture(image?) -> nil`: Assigns or removes a texture for this mesh. Pass nil to clear the texture.
- `LMesh:setVertex(index, data) -> nil`: Updates a single vertex by 1-based index. Table format: {x, y, u, v, r, g, b, a}.
- `LMesh:type() -> string`: Returns the type name string for this mesh object.
- `LMesh:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LNineSlice Type

- Texture with defined border insets for scalable 9-slice rendering (e.g., UI panels, buttons).

##### Fields

- No documented fields.

##### Methods

- `LNineSlice:getInsets() -> number, number, number, number`: Returns the border insets (top, right, bottom, left) that define the stretchable regions.
- `LNineSlice:getTextureSize() -> number, number`: Returns the pixel dimensions of the underlying source texture.
- `LNineSlice:type() -> string`: Returns the type name of this object.
- `LNineSlice:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LObjModel Type

- Loaded OBJ 3D model handle for CPU-side projection to 2D meshes and sprite rendering.

##### Fields

- No documented fields.

##### Methods

- `LObjModel:getFaceCount() -> number`: Returns the number of faces (triangles) in this OBJ model.
- `LObjModel:getNormalCount() -> number`: Returns the number of vertex normals in this OBJ model.
- `LObjModel:getUvCount() -> number`: Returns the number of UV texture coordinates in this OBJ model.
- `LObjModel:getVertexCount() -> number`: Returns the number of vertices in this OBJ model.
- `LObjModel:projectToMesh(camera, screenW, screenH) -> table`: Projects the OBJ model into 2D vertex data using a virtual camera, returning a table of vertex rows.
- `LObjModel:renderToImage(width, height, rotation?) -> LImage`: Renders the OBJ model to a GPU texture at the given resolution with optional 90-degree rotation.

#### LObjModelProjectToMeshResult Type

- Generated result shape from @field tags.

##### Fields

- `a` (`number`): A.
- `b` (`number`): B.
- `g` (`number`): G.
- `r` (`number`): R.
- `u` (`number`): U.
- `v` (`number`): V.
- `x` (`number`): X.
- `y` (`number`): Y.

##### Methods

- No documented methods.

#### LQuad Type

- Rectangular sub-region of a texture, used for sprite sheets and atlas-based rendering.

##### Fields

- No documented fields.

##### Methods

- `LQuad:getTextureDimensions() -> number, number`: Returns the full dimensions of the source texture this quad references.
- `LQuad:getViewport() -> number, number, number, number`: Returns the quad's viewport rectangle within the source texture.
- `LQuad:setViewport(x, y, w, h) -> nil`: Updates the quad's viewport rectangle.
- `LQuad:type() -> string`: Returns the type name string for this quad object.
- `LQuad:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LRenderGetStatsResult Type

- Generated result shape from @field tags.

##### Fields

- `batched_draws` (`integer`): Batched draw count.
- `canvas_switches` (`integer`): Canvas switch count.
- `canvases` (`integer`): Active canvas count.
- `cpu_render_ms` (`number`): CPU render time in milliseconds.
- `drawcalls` (`integer`): Total draw call count.
- `fonts` (`integer`): Loaded font count.
- `gpu_draw_calls` (`integer`): GPU-side draw call count.
- `shader_switches` (`integer`): Shader switch count.
- `texture_memory` (`integer`): Texture memory in bytes.
- `texture_switches` (`integer`): Texture switch count.
- `textures` (`integer`): Loaded texture count.

##### Methods

- No documented methods.

#### LShader Type

- GPU shader program for custom rendering effects (post-processing, distortion, etc.).

##### Fields

- No documented fields.

##### Methods

- `LShader:getDiagnostics() -> table`: Returns shader validation diagnostics.
- `LShader:getId() -> number`: Returns the internal numeric handle ID for this shader.
- `LShader:getTarget() -> string`: Returns the target this shader was validated for.
- `LShader:hasUniform(name) -> boolean`: Checks whether this shader declares a uniform with the given name.
- `LShader:release() -> boolean`: Releases the shader resource. If active, the default shader is restored.
- `LShader:send(name, value) -> nil`: Sends a uniform value to this shader by name. Supported types: number, boolean, or table (vec2/vec3/vec4).
- `LShader:type() -> string`: Returns the type name string for this shader object.
- `LShader:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LShape Type

- Retained compound shape that accumulates drawing commands and can be rendered in one call.

##### Fields

- No documented fields.

##### Methods

- `LShape:arc(mode, x, y, r, astart, aend, segments?) -> nil`: Adds a filled or outlined arc command to the shape.
- `LShape:circle(mode, x, y, r) -> nil`: Adds a filled or outlined circle command to the shape.
- `LShape:clear() -> nil`: Removes all drawing commands from this shape, making it empty.
- `LShape:draw(x, y, rotation?, sx?, sy?, ox?, oy?) -> nil`: Renders the accumulated shape commands to the screen with optional transform.
- `LShape:ellipse(mode, x, y, rx, ry) -> nil`: Adds an ellipse command to the shape.
- `LShape:getCommandCount() -> number`: Returns the number of drawing commands accumulated in this shape.
- `LShape:line(x1, y1, x2, y2) -> nil`: Adds a line segment command to the shape.
- `LShape:polygon(mode, ...) -> nil`: Adds a polygon command to the shape from a flat list of x,y coordinate pairs.
- `LShape:polyline(...) -> nil`: Adds a connected polyline command to the shape from a flat list of x,y coordinate pairs.
- `LShape:rectangle(mode, x, y, w, h) -> nil`: Adds a rectangle command to the shape.
- `LShape:roundedRectangle(mode, x, y, w, h, rx, ry?) -> nil`: Adds a rounded rectangle command to the shape.
- `LShape:setColor(r, g, b, a?) -> nil`: Sets the drawing color for subsequent shape commands.
- `LShape:setLineWidth(w) -> nil`: Sets the line width for subsequent line-mode shape commands.
- `LShape:triangle(mode, x1, y1, x2, y2, x3, y3) -> nil`: Adds a triangle command to the shape.
- `LShape:type() -> string`: Returns the type name string for this shape object.
- `LShape:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LSpriteBatch Type

- Batched sprite renderer for efficiently drawing many copies of the same texture.

##### Fields

- No documented fields.

##### Methods

- `LSpriteBatch:add(x, y, r?, sx?, sy?, ox?, oy?) -> number`: Adds a sprite entry to the batch at the given position with optional transform.
- `LSpriteBatch:clear() -> nil`: Removes all entries from the sprite batch.
- `LSpriteBatch:getBufferSize() -> number`: Returns the maximum number of entries this batch can hold.
- `LSpriteBatch:getCount() -> number`: Returns the number of sprite entries currently in the batch.
- `LSpriteBatch:release() -> boolean`: Releases the sprite batch resource.
- `LSpriteBatch:type() -> string`: Returns the type name string for this sprite batch.
- `LSpriteBatch:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

## Examples

- `content/examples/render.lua` (present)

## Tests

- Lua unit: `tests/lua/unit/test_render_unit.lua` (present)
- Rust: `src/render/render_diagnostics.rs`
- Rust: `tests/rust/unit/effect_render_tests.rs`
- Rust: `tests/rust/unit/render_tests.rs`

## Evidence / Golden

| Kind | Path |
|---|---|
| Evidence test | `tests/lua/evidence/test_render_evidence.lua` |
| Evidence test | `tests/lua/evidence/test_render_shader_evidence.lua` |
| Golden test | `tests/lua/golden/test_render_golden.lua` |
| Current artifact | `tests/artifacts/current/render/render_advanced_vector_scene.png` |
| Current artifact | `tests/artifacts/current/render/render_blend_alpha_scene.png` |
| Current artifact | `tests/artifacts/current/render/render_canvas_composite_scene.png` |
| Current artifact | `tests/artifacts/current/render/render_canvas_shader_pass_contract.txt` |
| Current artifact | `tests/artifacts/current/render/render_layers_sort_group_scene.png` |
| Current artifact | `tests/artifacts/current/render/render_mesh_custom_geometry.png` |
| Current artifact | `tests/artifacts/current/render/render_obj_model_preview.png` |
| Current artifact | `tests/artifacts/current/render/render_primitive_family_scene.png` |
| Current artifact | `tests/artifacts/current/render/render_retained_shape_instances.png` |
| Current artifact | `tests/artifacts/current/render/render_scissor_nested_clip.png` |
| Current artifact | `tests/artifacts/current/render/render_shader_contract.txt` |
| Current artifact | `tests/artifacts/current/render/render_shader_debugviz_contract.txt` |
| Current artifact | `tests/artifacts/current/render/render_shader_draw_contract.txt` |
| Current artifact | `tests/artifacts/current/render/render_shader_image_contract.txt` |
| Current artifact | `tests/artifacts/current/render/render_shader_light_contract.txt` |
| Current artifact | `tests/artifacts/current/render/render_shader_mapviz_contract.txt` |
| Current artifact | `tests/artifacts/current/render/render_shader_overlay_contract.txt` |
| Current artifact | `tests/artifacts/current/render/render_shader_particle_contract.txt` |
| Current artifact | `tests/artifacts/current/render/render_shader_postfx_contract.txt` |
| Current artifact | `tests/artifacts/current/render/render_shader_sprite_contract.txt` |
| Current artifact | `tests/artifacts/current/render/render_shader_text_contract.txt` |
| Current artifact | `tests/artifacts/current/render/render_shader_tilemap_contract.txt` |
| Current artifact | `tests/artifacts/current/render/render_shader_ui_contract.txt` |
| Current artifact | `tests/artifacts/current/render/render_shader_uniform_scene.png` |
| Current artifact | `tests/artifacts/current/render/render_spritebatch_grid_scene.png` |
| Current artifact | `tests/artifacts/current/render/render_stencil_portal_scene.png` |
| Current artifact | `tests/artifacts/current/render/render_text_font_layout.png` |
| Current artifact | `tests/artifacts/current/render/render_texture_quad_nineslice_scene.png` |
| Current artifact | `tests/artifacts/current/render/render_transform_hierarchy_scene.png` |
| Baseline artifact | `tests/artifacts/baselines/render/render_advanced_vector_scene.png` |
| Baseline artifact | `tests/artifacts/baselines/render/render_blend_alpha_scene.png` |
| Baseline artifact | `tests/artifacts/baselines/render/render_canvas_composite_scene.png` |
| Baseline artifact | `tests/artifacts/baselines/render/render_layers_sort_group_scene.png` |
| Baseline artifact | `tests/artifacts/baselines/render/render_mesh_custom_geometry.png` |
| Baseline artifact | `tests/artifacts/baselines/render/render_obj_model_preview.png` |
| Baseline artifact | `tests/artifacts/baselines/render/render_primitive_family_scene.png` |
| Baseline artifact | `tests/artifacts/baselines/render/render_retained_shape_instances.png` |
| Baseline artifact | `tests/artifacts/baselines/render/render_scissor_nested_clip.png` |
| Baseline artifact | `tests/artifacts/baselines/render/render_shader_uniform_scene.png` |
| Baseline artifact | `tests/artifacts/baselines/render/render_spritebatch_grid_scene.png` |
| Baseline artifact | `tests/artifacts/baselines/render/render_stencil_portal_scene.png` |
| Baseline artifact | `tests/artifacts/baselines/render/render_text_font_layout.png` |
| Baseline artifact | `tests/artifacts/baselines/render/render_texture_quad_nineslice_scene.png` |
| Baseline artifact | `tests/artifacts/baselines/render/render_transform_hierarchy_scene.png` |

## Architecture Links

- Intentionally empty.

## Notes

- Public `lurek.render` behavior is Lua-first and should keep canonical coverage in `tests/lua/unit/`.
- `src/render/mod.rs` stays export-only; implementation logic belongs in peer files.
- Renderer reliability changes should prefer recoverable errors or skipped invalid draws over panics in frame submission.
- Shader API:
  `lurek.render.newShader(code, opts?)` is the canonical public constructor for WGSL fragment shaders. `opts.target` defaults to `draw` and may be `draw`, `postfx`, `image`, `overlay`, `particle`, `light`, `sprite`, `tilemap`, `mapviz`, `text`, `ui`, or `debugviz`. There is no public `lurek.shader` module; shaders are render resources bound by other modules through `LShader` handles.
- Shader target contracts:
  Fullscreen targets (`postfx`, `image`, `overlay`) share source color, uv, pixel position, resolution, and texel-size inputs; this is the intended contract for palette/LUT grading, heat haze and water distortion, CRT/retro passes, screen transitions such as wipe/dissolve/fade masks, and offline bitmap filters. `image` executes off-screen over RGBA8 `ImageData` and reads back a new `ImageData`. `particle` forwards color, uv, local/world position, velocity, normalized age, lifetime, seed, and sampled texture color. `light` forwards world/light position, normal-map contribution hint, normalized distance, radius, intensity, shadow factor, ambient color, and direction/spot data. `sprite` is a textured material target for sprite recolor, palette swap, team color, damage flash, and dissolve-style fragment effects. `tilemap` is a tile-visual material target for biome tinting, animated water/lava color, fog overlays, and atlas-tile recolor; its current contract exposes tile draw color and uv, with uv set to zero for debug-color primitives. `mapviz` is a command-render visualization target for province and minimap maps; it accepts color, uv, local/pixel position, screen resolution, and texel-size inputs, but province-id or minimap-cell semantic data is still module-owned and not yet forwarded as shader inputs. `text` is a font-atlas target for glyph color/alpha effects, gradient text, glow, outline-like tinting, scanline text, terminal CRT text, and SDF-like experiments; it is activated through `lurek.render.setTextShader` and affects render text commands without changing generic image/sprite draws. `ui` is a terminal/widget surface target for command groups such as `LTerminal:render` and retained widgets emitted by `lurek.ui.draw`; it accepts color, uv, local/pixel position, screen resolution, and texel-size inputs and is intended for CRT terminals, hover/highlight panels, masked UI surfaces, and full-surface UI tinting. `debugviz` is a diagnostic render-command target for non-gameplay overlays such as pathfinding cost fields, physics heatmaps, AI influence maps, flow fields, and runtime inspection layers; it uses the same color/uv/pixel/resolution/texel contract and is activated through `lurek.render.setDebugShader`. Runtime custom shaders are fragment-only; arbitrary user vertex and compute shaders are outside this API.
- Canvas shader passes:
  `LCanvas:applyShader(shader, opts?)` and `lurek.render.applyShaderToCanvas(canvas, shader, opts?)` accept `postfx` shaders and queue a render-owned GPU pass that mutates the canvas render target after its queued draws. The postfx contract is reused because canvas passes operate over a source texture; no separate `canvas` shader target exists until canvas-specific semantic inputs are required.
- Shader ownership:
  Feature modules such as `image`, `effect`, `overlay`, `particle`, `light`, `sprite`, `tilemap`, `province`, `minimap`, `terminal`, `ui`, `parallax`, `raycaster`, and `globe` may store shader handles and semantic binding choices, but WGSL validation, GPU modules, bind groups, pipeline selection, fallback, and frame execution stay in `render`.
