# render

## General Info

- Module group: `Platform Services`
- Source path: `src/render/`
- Binding: `src/lua_api/render_api.rs`
- Namespace: `lurek.render`
- Lua API surface: `130` functions, `14` types, `88` methods
- Rust test path(s): src/render/ (inline #[cfg(test)] in canvas, decal_surface, draw_layer, font, image_effect, mesh, shader, shape), src/render/renderer_tests.rs, src/render/postfx_pipeline_tests.rs
- Lua test path(s): none found in the workspace

## Summary

This module serves as the primary visual execution backend for Lurek2D, orchestrating all deferred draw operations to produce final frame outputs. It establishes a robust 2D rendering pipeline that supports basic vector shapes, dynamically rasterized text, custom vertex meshes, and complex fullscreen post-processing layers. By acting as a central gateway, it unifies diverse presentation requests from scripting and internal systems into a single frame lifecycle.

At the mechanical heart of this pipeline is a device-facing wgpu renderer. This backend translates the engine's high-level command vocabulary into encoded GPU commands, managing pipelines, buffers, and shader attachments. It tessellates shapes like circles, arcs, and rounded rectangles on demand, and maintains separate flat and textured render paths to ensure that color-only operations do not incur unwanted texture overhead.

For structured and high-frequency rendering, the toolkit supports both retained-mode shapes and instanced batches. Retained compound shapes package multiple vector strokes into named assets for fast replay. Sprite batches collect massive sets of identical texture references to draw thousands of particles or tiles in a single draw call. Additionally, off-screen canvases and splat surfaces facilitate layered compositions.

The typography engine bridges raw text assets with GPU-rendered quads. It handles bundled bitmap atlases alongside custom font files dynamically rasterized at runtime. The system tracks precise glyph metrics, atlas placements, and text wraps, ensuring that multi-line formatting remains visually stable. It also supports terminal-style retro symbols and character lookups to accommodate classic user interface grids.

Advanced graphic styling is achieved through custom shader programs. Developers can compile user-authored fragment programs, sending typed parameters such as vectors or textures directly to the GPU. The engine automatically inspects shader inputs to ensure coordinate compatibility, and ordered uniform uploads at the start of each frame, providing a safe, script-driven environment for custom visual filters.

Chained visual finishes are managed by a dedicated post-processing pipeline. By utilizing fullscreen geometry and ping-pong render targets, it applies multi-pass effects like bloom, blur, depth-of-field, color grading, and screen distortion. The pipeline automatically feeds dynamic time, frame count, and resolution variables into the active fragment shaders, degrading gracefully to a direct copy when no treatments are enabled.

For intricate scene layouts, the subsystem exposes fine-grained layering and stencil controls. Z-depth sorted groups schedule draw callbacks in priority order, preventing visual conflicts when enqueuing overlays. The stencil engine configures comparison tests, masks, and write actions, allowing developers to implement circular portals, clipping boundaries, and masked user interface frames with hardware-accelerated precision.

Finally, the module provides a specialized Wavefront OBJ 3D model adapter. This utility projects 3D mesh coordinates through a virtual camera into 2D triangles, drawing detailed silhouettes and animated mesh structures without requiring a full 3D pipeline. It also supports CPU-side software rasterization stubs, allowing tools to generate thumbnails, save screenshots, and gather rendering stats in headless environments.

## Files

### [canvas.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/render/canvas.rs)

- This file defines the lightweight canvas handle that describes an off-screen render target by size and identity.
- It is metadata for the renderer rather than a GPU allocation, so higher layers can reason about canvas ownership cheaply.
- The type exists to keep canvas-facing APIs stable while the renderer manages the actual backing resources elsewhere.

### [decal_surface.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/render/decal_surface.rs)

- This file defines the persistent decal surface descriptor used when the engine needs a paintable texture space for marks and splats.
- It keeps only the durable dimensions and identity needed for later GPU allocation and reuse across frames.
- The descriptor stays intentionally small because the renderer owns the heavy texture lifecycle and attachment details.

### [draw_layer.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/render/draw_layer.rs)

- This file stores deferred draw-layer callbacks that should execute in a chosen depth order later in the frame.
- Entries carry ordering intent without forcing immediate GPU work, which lets gameplay and UI enqueue layered drawing cheaply.
- Sorting is centralized here so every queued callback follows the same layering rule before the renderer flushes it.
- The result is a narrow scheduling buffer between scripting-time draw requests and render-time command emission.

### [font.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/render/font.rs)

- This file handles the text asset side of rendering, from bundled bitmap atlases to dynamically rasterized font faces.
- It keeps glyph metrics, atlas placement, and lookup behavior close together so layout and draw code share one text model.
- Built-in faces give the engine predictable default text coverage even before user fonts are loaded from content.
- Runtime rasterization feeds custom font files into the same practical atlas-oriented representation used by bundled resources.
- Measurement helpers live here as well, which keeps wrapping, alignment, and cursor math consistent with the actual glyph data.
- Character lookup includes compatibility behavior for terminal-style symbols and legacy code ranges that show up in retro UI work.
- The file therefore sits between raw font assets and renderer-facing text quads, preserving both readability and runtime flexibility.
- In effect it is the typography utility layer for every screen, HUD, console, and debug overlay that needs stable text metrics.

### [gpu_renderer.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/render/gpu_renderer.rs)

- This file is the concrete wgpu renderer that turns the engine command vocabulary into encoded GPU work and presented frames.
- It owns device-facing state such as pipelines, bind groups, buffers, samplers, and the transient attachments needed during a frame.
- Incoming draw commands are interpreted here into flat-color, textured, mesh, font, light, and post-effect passes that share one frame lifecycle.
- Geometry for common 2D shapes is tessellated on demand so higher layers can speak in circles, lines, rounded boxes, and polygons instead of vertices.
- Vertex and index buffers are resized as frame demand grows, which keeps command recording simple while still adapting to heavy scenes.
- Textured drawing and flat drawing travel through separate but coordinated paths so color-only work does not inherit texture overhead by accident.
- Off-screen canvas targets are managed beside the swapchain path, allowing the same renderer core to feed composition layers and final output.
- Depth and stencil attachments are created only where needed, which keeps specialty passes available without forcing that cost onto every target.
- User shaders can be compiled, cached, and driven with typed uniform values so scripted visual experiments fit into the same backend.
- Post-processing hooks are integrated at the frame level instead of bolted on after presentation, enabling chained full-screen effects over rendered scenes.
- Lighting support includes additive point contributions and shadow-related data preparation that enrich 2D scenes without leaving the renderer.
- Screenshot readback and statistics gathering also happen here because this file has the authoritative picture of what the GPU just processed.
- Font atlas uploads, texture writes, and canvas surface reuse are coordinated in one place so resource churn stays observable and bounded.
- Visibility pruning happens before expensive draw expansion where possible, which helps large scenes skip obviously off-camera work.
- Circle and ellipse draw commands use deterministic adaptive tessellation based on visual extent, clamped to stable minimum and maximum segment counts.
- Blend, stencil, and depth modes are translated here into the exact pipeline variants the backend needs for compositing correctness.
- The file also contains the glue that keeps meshes, particles, Spine output, and generic primitives flowing through one renderer abstraction.
- Low-level vertex formats live here because they are backend contracts rather than reusable engine-domain types.
- A large part of the file is practical translation work between ergonomic engine commands and the stricter shapes demanded by wgpu.
- Frame setup and teardown logic are colocated with pass encoding so lifetime ordering for temporary GPU objects remains explicit.
- Canvas rendering, main-surface rendering, and readback all depend on the same shared resource maps keyed by engine handles.
- When a command sequence mixes text, textures, shapes, and custom shaders, this file is what turns that mixture into a coherent render graph.
- It therefore serves as the mechanical heart of visual output rather than a thin wrapper around API calls.
- Most engine rendering features eventually pass through this file, even when their public APIs live elsewhere.
- The design favors one rich backend with many translation helpers over scattering GPU details across the rest of the codebase.
- That centralization keeps GPU policy, caching, and pass ordering inspectable when rendering bugs appear.
- It also makes new draw features cheaper to add because they can target an existing command pipeline instead of inventing a second renderer.
- From the outside this file seems like a renderer implementation.
- From the inside it is the point where command semantics, resource ownership, and frame orchestration are kept in sync.
- It is the place where the engine decides how abstract 2D drawing intent becomes actual pixels on hardware.
- Everything else in the render module exists largely to feed or shape the work that this backend executes.

### [image_effect.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/render/image_effect.rs)

- This file defines the compact descriptor for one post-processing step in a larger image-effect chain.
- Each record carries effect identity, parameter values, and enable state so pipelines can be configured without custom structs per effect.
- The type is the small control surface between high-level effect selection and the GPU post-processing backend.

### [mesh.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/render/mesh.rs)

- This file defines reusable 2D mesh data for renderable geometry that is richer than the engine's immediate-mode shape commands.
- It keeps positions, UVs, colors, and topology choices together so imported content and generated geometry share one draw-ready format.
- Indexed and non-indexed paths are both represented, which gives callers flexibility without forcing a single authoring style.
- Triangulation helpers bridge higher-level topology choices into the triangles the backend ultimately needs.
- The file is therefore the geometry interchange layer between content generation, importers, and the renderer.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/render/mod.rs)

- This module provides the engine render stack, from command definitions and asset-side helpers to the concrete GPU backend.
- It covers shapes, text, textures, meshes, decals, canvas targets, shaders, and full-screen image effects under one rendering vocabulary.
- At the highest level it is the subsystem that turns frame-local draw intent into ordered, composited visual output.

### [obj_loader.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/render/obj_loader.rs)

- This file imports Wavefront OBJ content and converts it into forms that make sense inside a 2D engine rather than a full 3D renderer.
- Parsed models can be projected into engine mesh data for GPU drawing or rasterized in software for previews and tooling images.
- Material parsing keeps basic diffuse color and texture references close to the mesh data so projected results still carry authored surface intent.
- Local vector and camera utilities are included here because the conversion work needs lightweight 3D math without spreading that concern across the engine.
- Face handling normalizes OBJ indexing quirks such as relative references and mixed attribute indices into stable internal structures.
- CPU rasterization gives the module a no-GPU path for thumbnails, validation, and other inspection-oriented workflows.
- Projection support is tuned for systems like the raycaster and globe views that want 3D-authored silhouettes in a 2D presentation model.
- The file is feature-gated because model import is useful but not fundamental to every game built on the runtime.
- In design terms this is an adapter from common 3D content formats to the engine's 2D rendering language.
- It preserves enough material and geometric structure to stay expressive without promising a general-purpose 3D pipeline.
- That boundary is the point: authored 3D assets may inform a scene, but final display still obeys the engine's 2D rendering architecture.
- This file is where that translation is made concrete and reusable.

### [postfx_pipeline.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/render/postfx_pipeline.rs)

- This file manages the full-screen post-processing chain that runs after ordinary scene drawing has produced a source image.
- Pipeline-layout and render-pipeline construction are centralized in shared helpers so built-in and custom effects use one consistent GPU setup path.
- Built-in effects cover blur, bloom, stylization, damage, distortion, and screen-surface treatments without requiring custom game shaders.
- Custom fragment programs can also be registered so advanced projects can extend the effect catalog while staying inside the same pipeline shape.
- Effect parameters are packed into a fixed uniform layout that is simple to feed from scripting and stable for GPU execution.
- Shared fullscreen geometry and ping-pong render targets keep multi-pass execution practical without rebuilding the whole frame graph each time.
- Disabled chains degrade gracefully to a plain copy, which keeps the backend simple when no visual treatment is active.
- Time, frame count, and resolution are injected centrally so effect authors can rely on common runtime signals.
- Pass order follows the configured chain order, making visual stacking explicit rather than implicit.
- The file therefore acts as the image-finishing stage of the renderer, where an already rendered frame can be polished or stylized.
- It is not about drawing scene geometry.
- It is about transforming one finished image into another with controlled GPU shader passes.
- In practice this is the renderer's color-grading room, distortion rack, and screen-material toolbox.

### [province_map_pipeline.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/render/province_map_pipeline.rs)

- This file provides the specialized GPU pipeline used to render province-map views that need more than generic sprite or mesh drawing.
- It binds province identity, borders, and distance-related data together so the shader can reason about map regions instead of plain pixels.
- Viewport mapping and mode-dependent behavior are configured here because that logic belongs to this strategic map presentation path.
- The pipeline is intentionally dedicated, reflecting that province rendering has distinct data needs from ordinary scene rendering.
- It turns map-analysis textures and buffers into a coherent fullscreen visual layer.
- This is the render-side home for province-specific screen synthesis.

### [renderer.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/render/renderer.rs)

- This file defines the renderer command language that the rest of the engine speaks when it wants something visual to happen this frame.
- It gathers draw operations, state changes, auxiliary descriptors, and shared render-side enums into one canonical vocabulary.
- Shapes, text, textures, particles, Spine output, layered sorting, stencil control, and depth behavior all meet here as data instead of immediate API calls.
- The command set is broad because many subsystems submit visual intent before the GPU backend ever becomes involved.
- Shared enums for alignment, blend, compare, and draw styles live beside the commands so callers agree on meaning without backend coupling.
- Higher-level rendering helpers can build rich features simply by emitting combinations of these records.
- Post-processing descriptors and upload payloads also sit here because they are part of the same frame command stream.
- In practice this file is the renderer's grammar, not its execution engine.
- It explains what can be said to the backend, in what shapes, and with what supporting metadata.
- Keeping that grammar centralized is what lets Lua, gameplay systems, and specialized modules target one render pipeline.
- The file therefore stabilizes render intent across the codebase even as the backend implementation grows more complex.
- Almost every visible feature eventually passes through the types defined here.

### [shader.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/render/shader.rs)

- This file handles user-facing shader ingestion so custom WGSL fragments can plug into the renderer without exposing raw backend setup everywhere.
- Source code is parsed, constrained, and rewritten into the wrapper shape the engine expects for controlled pipeline generation.
- Fragment inputs are inspected so only supported coordinate and color channels enter the custom shader path.
- Uniform values are represented in typed form here, which keeps script-driven shader parameters explicit and serializable enough for per-frame upload.
- Ordered uniform iteration matters because GPU buffer layout must stay stable once a shader is accepted.
- Attribute markers are also normalized here so author-facing shader syntax can remain a little friendlier than raw internal conventions.
- The file is therefore the contract layer between flexible user shader text and a renderer that still needs predictable pipeline inputs.

### [shape.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/render/shape.rs)

- This file stores reusable vector shape definitions as replayable command sequences instead of immediate one-off draw calls.
- A shape can therefore package many primitive strokes and fills into one named asset-like unit for later reuse.
- Drawing state such as color and line width travels with the sequence so replays preserve intended appearance.
- The file is useful wherever authored UI motifs or gameplay markers should be drawn repeatedly without rebuilding command lists.
- It acts as a small retained-mode layer inside the otherwise command-driven renderer.
