# render

## TL;DR

- The `render` module is the engine's visual backend, translating deferred draw commands into GPU work for shapes, text, textures, meshes, canvases, shaders, and post-effects.

## General Info

- Module group: `Platform Services`
- Source path: `src/render/`
- Binding: `src/lua_api/render_api.rs`
- Namespace: `lurek.render`
- Lua API surface: `130` functions, `14` types, `88` methods
- Rust test path(s): src/render/ (inline #[cfg(test)] in canvas, decal_surface, draw_layer, font, image_effect, mesh, shader, shape), src/render/renderer_tests.rs, src/render/postfx_pipeline_tests.rs
- Lua test path(s): none found in the workspace

## Summary

The `render` module is the engine's visual execution backbone. It receives drawing intent from scripts and systems, keeps that intent in a frame command model, and turns it into ordered GPU work that produces the final image.

Its core contract is deferred rendering through one shared command vocabulary. Gameplay code can describe what to draw without issuing low-level GPU operations directly. Later, the backend resolves ordering, batching, state transitions, and pass structure in a single coordinated stage.

This separation is functionally important: feature modules can focus on intent, while render policy stays centralized. As a result, many systems can submit visual output in parallel development flows without each re-implementing buffer policy, blend behavior, or pass sequencing.

The module supports broad visual scope under one API family. Basic primitives, textured draws, mesh content, text rendering, layer-aware ordering, blend and stencil behavior, and depth-related controls are all represented in compatible command forms.

Typography is part of the same contract, not a separate subsystem. Font management, glyph raster paths, and measurement behavior allow UI, debug overlays, and in-world labels to share stable text rules and avoid divergent text pipelines.

Off-screen rendering is integrated through canvas-style targets, which enables composition workflows such as UI staging, intermediate pass rendering, and reusable render surfaces for complex visual assembly.

Post-processing is also built in as a first-class finishing stage. Full-screen effect chains can apply visual style and screen-space treatments after scene draw completion, with built-in and custom shader paths living in one controlled pipeline.

Resource lifecycle is centralized to keep visual execution stable over long sessions. Texture uploads, transient buffers, pipeline variants, and attachment reuse are managed in one backend authority, reducing duplication and state mismatch across modules.

The module is also designed as a shared integration boundary for many feature systems. UI, particles, map renderers, raycaster output, text overlays, and debug tools can all target the same draw grammar and rely on the same backend timing. This matters functionally because visual interoperability is not left to chance; layers from different domains can coexist inside one frame model with predictable ordering and composition.

Another practical benefit is portability of visual workflows. Since command creation is separated from backend execution details, gameplay-side rendering logic can stay stable while backend internals evolve for performance, new effects, or platform maintenance. Teams can improve rendering quality and throughput without rewriting all feature-level drawing code.

This module also supports iterative production work. Artists and developers can tune blend behavior, effect stacks, text presentation, and off-screen composition in stages, while keeping output deterministic enough for debugging and regression checks. The same command stream can be inspected, replayed, and reasoned about as a coherent frame narrative.

Because command grammar and backend execution are unified, debugging and extension are more predictable. New features can target existing render primitives and pass rules instead of adding isolated rendering stacks.

In practice, `lurek.render` is the module that turns frame intent into presented pixels: collect commands, organize passes, manage GPU state, apply composition and effects, and expose one stable rendering surface for the rest of the engine.

## Imports

- `font`: Imports or references `src/font/`. Cross-group dependency from `Platform Services` into `Edge/Integration`.
- `image`: Imports or references `src/image/`. Dependency stays inside `Platform Services` and should remain acyclic.
- `light`: Imports or references `light` from `src/light/`.
- `math`: Imports or references `math` from `src/math/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.
- `sprite`: Imports or references `sprite` from `src/sprite/`.

## Files

### canvas.rs

- This file defines the lightweight canvas handle that describes an off-screen render target by size and identity.
- It is metadata for the renderer rather than a GPU allocation, so higher layers can reason about canvas ownership cheaply.
- The type exists to keep canvas-facing APIs stable while the renderer manages the actual backing resources elsewhere.

### decal_surface.rs

- This file defines the persistent decal surface descriptor used when the engine needs a paintable texture space for marks and splats.
- It keeps only the durable dimensions and identity needed for later GPU allocation and reuse across frames.
- The descriptor stays intentionally small because the renderer owns the heavy texture lifecycle and attachment details.

### draw_layer.rs

- This file stores deferred draw-layer callbacks that should execute in a chosen depth order later in the frame.
- Entries carry ordering intent without forcing immediate GPU work, which lets gameplay and UI enqueue layered drawing cheaply.
- Sorting is centralized here so every queued callback follows the same layering rule before the renderer flushes it.
- The result is a narrow scheduling buffer between scripting-time draw requests and render-time command emission.

### font.rs

- This file handles the text asset side of rendering, from bundled bitmap atlases to dynamically rasterized font faces.
- It keeps glyph metrics, atlas placement, and lookup behavior close together so layout and draw code share one text model.
- Built-in faces give the engine predictable default text coverage even before user fonts are loaded from content.
- Runtime rasterization feeds custom font files into the same practical atlas-oriented representation used by bundled resources.
- Measurement helpers live here as well, which keeps wrapping, alignment, and cursor math consistent with the actual glyph data.
- Character lookup includes compatibility behavior for terminal-style symbols and legacy code ranges that show up in retro UI work.
- The file therefore sits between raw font assets and renderer-facing text quads, preserving both readability and runtime flexibility.
- In effect it is the typography utility layer for every screen, HUD, console, and debug overlay that needs stable text metrics.

### gpu_renderer.rs

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

### image_effect.rs

- This file defines the compact descriptor for one post-processing step in a larger image-effect chain.
- Each record carries effect identity, parameter values, and enable state so pipelines can be configured without custom structs per effect.
- The type is the small control surface between high-level effect selection and the GPU post-processing backend.

### mesh.rs

- This file defines reusable 2D mesh data for renderable geometry that is richer than the engine's immediate-mode shape commands.
- It keeps positions, UVs, colors, and topology choices together so imported content and generated geometry share one draw-ready format.
- Indexed and non-indexed paths are both represented, which gives callers flexibility without forcing a single authoring style.
- Triangulation helpers bridge higher-level topology choices into the triangles the backend ultimately needs.
- The file is therefore the geometry interchange layer between content generation, importers, and the renderer.

### mod.rs

- This module provides the engine render stack, from command definitions and asset-side helpers to the concrete GPU backend.
- It covers shapes, text, textures, meshes, decals, canvas targets, shaders, and full-screen image effects under one rendering vocabulary.
- At the highest level it is the subsystem that turns frame-local draw intent into ordered, composited visual output.

### obj_loader.rs

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

### postfx_pipeline.rs

- This file manages the full-screen post-processing chain that runs after ordinary scene drawing has produced a source image.
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

### province_map_pipeline.rs

- This file provides the specialized GPU pipeline used to render province-map views that need more than generic sprite or mesh drawing.
- It binds province identity, borders, and distance-related data together so the shader can reason about map regions instead of plain pixels.
- Viewport mapping and mode-dependent behavior are configured here because that logic belongs to this strategic map presentation path.
- The pipeline is intentionally dedicated, reflecting that province rendering has distinct data needs from ordinary scene rendering.
- It turns map-analysis textures and buffers into a coherent fullscreen visual layer.
- This is the render-side home for province-specific screen synthesis.

### renderer.rs

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

### shader.rs

- This file handles user-facing shader ingestion so custom WGSL fragments can plug into the renderer without exposing raw backend setup everywhere.
- Source code is parsed, constrained, and rewritten into the wrapper shape the engine expects for controlled pipeline generation.
- Fragment inputs are inspected so only supported coordinate and color channels enter the custom shader path.
- Uniform values are represented in typed form here, which keeps script-driven shader parameters explicit and serializable enough for per-frame upload.
- Ordered uniform iteration matters because GPU buffer layout must stay stable once a shader is accepted.
- Attribute markers are also normalized here so author-facing shader syntax can remain a little friendlier than raw internal conventions.
- The file is therefore the contract layer between flexible user shader text and a renderer that still needs predictable pipeline inputs.

### shape.rs

- This file stores reusable vector shape definitions as replayable command sequences instead of immediate one-off draw calls.
- A shape can therefore package many primitive strokes and fills into one named asset-like unit for later reuse.
- Drawing state such as color and line width travels with the sequence so replays preserve intended appearance.
- The file is useful wherever authored UI motifs or gameplay markers should be drawn repeatedly without rebuilding command lists.
- It acts as a small retained-mode layer inside the otherwise command-driven renderer.

## Lua API Ref

### Functions

- `lurek.render.applyTransform`: Multiplies the current transformation matrix by a 3x3 matrix (9 values in row-major order).
- `lurek.render.arc`: Draws a filled or outlined circular arc segment.
- `lurek.render.beginSortGroup`: Begins a depth-sorted rendering group. Draw calls within this group are sorted by pushSortKey values.
- `lurek.render.beginSortGroup`: Begins a depth-sorted rendering group. Draw calls within this group are sorted by pushSortKey values.
- `lurek.render.captureScreenshot`: Captures a screenshot as ImageData and passes it to a callback (stub: returns 1x1 placeholder).
- `lurek.render.circle`: Draws a filled or outlined circle at the given position.
- `lurek.render.clear`: Clears all queued render commands for the current frame.
- `lurek.render.clearStencil`: Resets the stencil state to defaults (no stencil operations).
- `lurek.render.currentLayer`: Returns the name of the currently active rendering layer.
- `lurek.render.draw`: Draws a drawable object (Image, Canvas, SpriteBatch, or Mesh) at the given position with optional transform.
- `lurek.render.drawBatch`: Draws a SpriteBatch using the same queued DrawBatch command as lurek.render.draw(batch).
- `lurek.render.drawBevelRect`: Draws a beveled rectangle with highlight, shadow, and fill colors for 3D-style UI elements.
- `lurek.render.drawBevelRect`: Draws a beveled rectangle with highlight, shadow, and fill colors for 3D-style UI elements.
- `lurek.render.drawColoredPolygon`: Draws a polygon with per-vertex colors.
- `lurek.render.drawColoredPolygon`: Draws a polygon with per-vertex colors.
- `lurek.render.drawCubicBezier`: Draws a cubic Bezier curve through start, two control points, and end.
- `lurek.render.drawCubicBezier`: Draws a cubic Bezier curve through start, two control points, and end.
- `lurek.render.drawGradientRect`: Draws a rectangle with a two-color gradient fill.
- `lurek.render.drawGradientRect`: Draws a rectangle with a two-color gradient fill.
- `lurek.render.drawHexTile`: Draws a regular hexagonal tile at the given center position.
- `lurek.render.drawHexTile`: Draws a regular hexagonal tile at the given center position.
- `lurek.render.drawIsoCubeTile`: Draws an isometric cube tile with configurable face colors and optional textures.
- `lurek.render.drawIsoCubeTile`: Draws an isometric cube tile with configurable face colors and optional textures.
- `lurek.render.drawMany`: Batch-draws multiple images in one call. Each entry is a table: {image, x, y, r, sx, sy, ox, oy}.
- `lurek.render.drawNineSlice`: Draws a 9-slice image stretched to fill the given rectangle, keeping borders unscaled.
- `lurek.render.drawPath`: Draws a vector path composed of moveTo, lineTo, quadTo, and cubicTo segments.
- `lurek.render.drawPath`: Draws a vector path composed of moveTo, lineTo, quadTo, and cubicTo segments.
- `lurek.render.drawQuadBezier`: Draws a quadratic Bezier curve through start, control, and end points.
- `lurek.render.drawQuadBezier`: Draws a quadratic Bezier curve through start, control, and end points.
- `lurek.render.drawq`: Draws a sub-region of an image defined by a Quad, with optional transform.
- `lurek.render.ellipse`: Draws a filled or outlined ellipse at the given position.
- `lurek.render.flushSortGroup`: Ends a sort group and emits all accumulated draw calls in sorted order.
- `lurek.render.flushSortGroup`: Ends a sort group and emits all accumulated draw calls in sorted order.
- `lurek.render.getBackgroundColor`: Returns the current background clear color.
- `lurek.render.getBlendMode`: Returns the current blend mode name.
- `lurek.render.getBuiltInFontNames`: Returns all stable built-in font names.
- `lurek.render.getCanvas`: Returns the currently active canvas, or nil if drawing to the screen.
- `lurek.render.getCanvasSize`: Returns the pixel dimensions of a canvas.
- `lurek.render.getColor`: Returns the current drawing color.
- `lurek.render.getColorMask`: Returns the current color write mask.
- `lurek.render.getDefaultFilter`: Returns the current default texture filtering settings.
- `lurek.render.getDefaultFont`: Returns a built-in default font at the nearest available bundled point size.
- `lurek.render.getDepthMode`: Returns the current depth comparison mode and write-enable flag.
- `lurek.render.getDimensions`: Returns the current window width and height.
- `lurek.render.getFont`: Returns the currently active font, or nil if none is set.
- `lurek.render.getFontAscent`: Returns the ascent (pixels above baseline) of the given font.
- `lurek.render.getFontCellWidth`: Returns the fixed cell width of a bitmap font.
- `lurek.render.getFontDescent`: Returns the descent (pixels below baseline) of the given font.
- `lurek.render.getFontHeight`: Returns the line height of the given font.
- `lurek.render.getFontLineHeight`: Returns the line spacing of the given font.
- `lurek.render.getFontSizes`: Returns all available built-in point sizes.
- `lurek.render.getFontWidth`: Measures the pixel width of text using the given font.
- `lurek.render.getFontWrap`: Word-wraps text using the active font and returns the resulting lines and widest line width.
- `lurek.render.getHeight`: Returns the current window height in pixels.
- `lurek.render.getLayerZOrder`: Returns the z-order value of a named rendering layer.
- `lurek.render.getLineWidth`: Returns the current line width used for line-mode drawing.
- `lurek.render.getPointSize`: Returns the current point diameter used for point drawing.
- `lurek.render.getScissor`: Returns the current scissor rectangle, or nothing if no scissor is set.
- `lurek.render.getShader`: Returns the currently active shader, or nil if using the default.
- `lurek.render.getStats`: Returns a table of rendering statistics for the current frame.
- `lurek.render.getStencilMode`: Returns the current stencil action, compare mode, and reference value.
- `lurek.render.getWidth`: Returns the current window width in pixels.
- `lurek.render.intersectScissor`: Intersects the given rectangle with the current scissor, narrowing the drawable region.
- `lurek.render.isBold`: Returns true if the current default font selection uses the bold variant.
- `lurek.render.isLayerVisible`: Returns whether a named rendering layer is currently visible.
- `lurek.render.isWireframe`: Returns whether wireframe rendering is currently active.
- `lurek.render.line`: Draws a line between two points, or a polyline through multiple points.
- `lurek.render.loadModel`: Loads a 3D model file (OBJ format) and returns a handle for 2D projection and sprite rendering.
- `lurek.render.loadObj`: Loads a Wavefront OBJ model file and returns a model handle for projection and rendering.
- `lurek.render.newCanvas`: Creates a new off-screen render target with the given dimensions.
- `lurek.render.newDepthSorter`: Registers the depth-sorted drawing helper constructor in the render module.
- `lurek.render.newDrawLayer`: Creates a new z-ordered draw layer for sorting draw callbacks by depth.
- `lurek.render.newFont`: Creates a font from a built-in font name, a font file path, or a numeric built-in point-size selector.
- `lurek.render.newImage`: Loads a texture from a file path or creates one from an ImageData object.
- `lurek.render.newLayer`: Creates a named rendering layer with an optional z-order for draw call organization.
- `lurek.render.newMesh`: Creates a custom vertex mesh from an array of vertex data tables.
- `lurek.render.newNineSlice`: Creates a 9-slice definition from an image and four border insets for scalable UI rendering.
- `lurek.render.newQuad`: Creates a Quad defining a rectangular sub-region of a texture for sprite-sheet rendering.
- `lurek.render.newShader`: Compiles a WGSL shader program from source code and returns a handle.
- `lurek.render.newShape`: Creates a new retained compound shape for accumulating draw commands.
- `lurek.render.newSpriteBatch`: Creates a batched sprite renderer for efficiently drawing many copies of the same texture.
- `lurek.render.origin`: Resets the current transformation matrix to the identity (no transform).
- `lurek.render.points`: Draws one or more points. Accepts either a table of {x,y} pairs or flat x,y coordinate values.
- `lurek.render.polygon`: Draws a polygon from a flat list of x,y vertex coordinates.
- `lurek.render.pop`: Pops the top transformation matrix from the transform stack, restoring the previous one.
- `lurek.render.popLayer`: Ends a compositing layer and composites it with the previous content.
- `lurek.render.popLayer`: Ends a compositing layer and composites it with the previous content.
- `lurek.render.print`: Draws text using the active font at the given position.
- `lurek.render.printRich`: Draws rich text composed of individually styled spans at the given position.
- `lurek.render.printRichWithFont`: Draws rich text using a specific font without changing the global active font.
- `lurek.render.printRotated`: Draws text centered and rotated around its midpoint.
- `lurek.render.printRotatedWithFont`: Draws text centered and rotated around its midpoint using a specific font without changing the global active font.
- `lurek.render.printWithFont`: Draws text using a specific font without changing the global active font.
- `lurek.render.printf`: Draws word-wrapped and aligned text within a pixel-width limit.
- `lurek.render.printfWithFont`: Draws word-wrapped and aligned text with a specific font without changing the global active font.
- `lurek.render.push`: Pushes the current transformation matrix onto the transform stack.
- `lurek.render.pushLayer`: Begins a compositing layer with the given alpha and blend mode. Must be paired with popLayer.
- `lurek.render.pushLayer`: Begins a compositing layer with the given alpha and blend mode. Must be paired with popLayer.
- `lurek.render.pushSortKey`: Sets the depth sort key for subsequent draw calls within the current sort group.
- `lurek.render.pushSortKey`: Sets the depth sort key for subsequent draw calls within the current sort group.
- `lurek.render.rectangle`: Draws a rectangle. If rx is provided, draws a rounded rectangle.
- `lurek.render.resetCanvas`: Marks a canvas as needing a full clear before its next render pass. Use before re-rendering to avoid content accumulation.
- `lurek.render.rotate`: Applies a rotation to the current transformation matrix.
- `lurek.render.saveScreenshot`: Saves a screenshot of the current frame to a file under the save/ directory.
- `lurek.render.scale`: Applies scaling to the current transformation matrix.
- `lurek.render.setBackgroundColor`: Sets the background clear color used at the start of each frame.
- `lurek.render.setBlendMode`: Sets the blend mode for subsequent draw operations.
- `lurek.render.setBold`: Sets whether subsequent font size lookups use the bold Courier New variant.
- `lurek.render.setCanvas`: Redirects all subsequent drawing to the given canvas. Pass nil to draw to the screen again.
- `lurek.render.setColor`: Sets the active drawing color for all subsequent draw operations.
- `lurek.render.setColorMask`: Sets which color channels are written during draw calls. Call with no args to enable all.
- `lurek.render.setDefaultFilter`: Sets the default texture filtering mode for newly created images.
- `lurek.render.setDefaultFont`: Selects a built-in default font by bundled point size and makes it the active render font.
- `lurek.render.setDepthMode`: Sets the depth comparison mode and whether depth writes are enabled.
- `lurek.render.setFont`: Sets the active font used by print, printf, and other text rendering calls.
- `lurek.render.setFontLineHeight`: Sets the line height override for a font (currently a no-op stub).
- `lurek.render.setLayer`: Sets the active rendering layer by name. Creates the layer if it does not exist.
- `lurek.render.setLayerVisible`: Sets whether a named rendering layer is visible.
- `lurek.render.setLayerZOrder`: Sets the z-order value of a named rendering layer.
- `lurek.render.setLineWidth`: Sets the line width for subsequent line-mode draw calls.
- `lurek.render.setPointSize`: Sets the point size for subsequent point draw calls.
- `lurek.render.setScissor`: Sets or clears the scissor rectangle. Only pixels inside this region are drawn. Call with no args to clear.
- `lurek.render.setShader`: Activates a shader for subsequent draw calls. Pass nil to restore the default shader.
- `lurek.render.setStencilMode`: Sets the stencil write action, compare function, and reference value at once.
- `lurek.render.setStencilTest`: Configures the stencil comparison test for subsequent draws. Pass nil to disable.
- `lurek.render.setWireframe`: Enables or disables wireframe rendering mode.
- `lurek.render.shear`: Applies a shear (skew) to the current transformation matrix.
- `lurek.render.stencil`: Begins a stencil write pass with the given action and reference value.
- `lurek.render.translate`: Applies a translation to the current transformation matrix.
- `lurek.render.triangle`: Draws a triangle from three vertex positions.

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

- `LCanvas:getDimensions`: Returns both width and height of this canvas.
- `LCanvas:getHeight`: Returns the height of this canvas in pixels.
- `LCanvas:getWidth`: Returns the width of this canvas in pixels.
- `LCanvas:release`: Releases the canvas GPU resource. If this canvas is currently active, drawing reverts to the screen.
- `LCanvas:type`: Returns the type name string for this canvas object.
- `LCanvas:typeOf`: Checks whether this object matches the given type name.

#### LDrawLayer Type

- Z-ordered draw callback layer for sorting draw calls by depth before flushing.

##### Fields

- No documented fields.

##### Methods

- `LDrawLayer:clear`: Discards all queued callbacks without executing them.
- `LDrawLayer:flush`: Sorts all queued callbacks by z-depth and executes them in order, then empties the layer.
- `LDrawLayer:getCount`: Returns the number of callbacks currently queued.
- `LDrawLayer:queue`: Enqueues a draw callback at the given z-depth. Callbacks execute when flush() is called.
- `LDrawLayer:type`: Returns the type name string for this draw layer.
- `LDrawLayer:typeOf`: Checks whether this object matches the given type name.

#### LFont Type

- Bitmap font handle for measuring and rendering text.

##### Fields

- No documented fields.

##### Methods

- `LFont:getAscent`: Returns the ascent (pixels above the baseline) of this font.
- `LFont:getDescent`: Returns the descent (pixels below the baseline) of this font.
- `LFont:getHeight`: Returns the line height of this font in pixels.
- `LFont:getLineHeight`: Returns the spacing between consecutive lines of text.
- `LFont:getWidth`: Measures the pixel width of a string when rendered with this font.
- `LFont:getWrap`: Word-wraps text to fit within a pixel width limit and returns the resulting lines.
- `LFont:release`: Releases the font resource. The handle becomes invalid after this call.
- `LFont:setLineHeight`: Overrides the line height used for multi-line text rendering.
- `LFont:type`: Returns the type name string for this font object.
- `LFont:typeOf`: Checks whether this object matches the given type name.

#### LImage Type

- GPU-backed texture handle used for drawing images to screen.

##### Fields

- No documented fields.

##### Methods

- `LImage:getDimensions`: Returns both width and height of this image.
- `LImage:getHeight`: Returns the height of this image in pixels.
- `LImage:getId`: Returns the internal numeric handle ID for this image.
- `LImage:getWidth`: Returns the width of this image in pixels.
- `LImage:release`: Releases the GPU memory for this image. The handle becomes invalid after this call.
- `LImage:type`: Returns the type name string for this image object.
- `LImage:typeOf`: Checks whether this object matches the given type name.

#### LImageData Type

- Raw pixel buffer for CPU-side image manipulation before uploading to a GPU texture.

##### Fields

- No documented fields.

##### Methods

- `LImageData:blit`: Copies pixel data from another ImageData onto this one at the specified position.
- `LImageData:diff`: Computes a numeric difference score between this image and another of the same size.
- `LImageData:getHeight`: Returns the height of this image data in pixels.
- `LImageData:getRegion`: Extracts a rectangular sub-region as a new ImageData.
- `LImageData:getWidth`: Returns the width of this image data in pixels.
- `LImageData:mapPixels`: Iterates over every pixel and replaces its color with the return value of the callback.
- `LImageData:resize`: Creates a new ImageData resized to the given dimensions using bilinear sampling.
- `LImageData:type`: Returns the type name of this object.
- `LImageData:typeOf`: Checks whether this object matches the given type name.

#### LMesh Type

- Custom vertex mesh for advanced 2D geometry rendering with per-vertex color and UV data.

##### Fields

- No documented fields.

##### Methods

- `LMesh:getVertex`: Returns the data for a single vertex by 1-based index.
- `LMesh:getVertexCount`: Returns the number of vertices in this mesh.
- `LMesh:release`: Releases the mesh GPU resource and invalidates the handle.
- `LMesh:setTexture`: Assigns or removes a texture for this mesh. Pass nil to clear the texture.
- `LMesh:setVertex`: Updates a single vertex by 1-based index. Table format: {x, y, u, v, r, g, b, a}.
- `LMesh:type`: Returns the type name string for this mesh object.
- `LMesh:typeOf`: Checks whether this object matches the given type name.

#### LNineSlice Type

- Texture with defined border insets for scalable 9-slice rendering (e.g., UI panels, buttons).

##### Fields

- No documented fields.

##### Methods

- `LNineSlice:getInsets`: Returns the border insets (top, right, bottom, left) that define the stretchable regions.
- `LNineSlice:getTextureSize`: Returns the pixel dimensions of the underlying source texture.
- `LNineSlice:type`: Returns the type name of this object.
- `LNineSlice:typeOf`: Checks whether this object matches the given type name.

#### LObjModel Type

- Loaded OBJ 3D model handle for CPU-side projection to 2D meshes and sprite rendering.

##### Fields

- No documented fields.

##### Methods

- `LObjModel:getFaceCount`: Returns the number of faces (triangles) in this OBJ model.
- `LObjModel:getNormalCount`: Returns the number of vertex normals in this OBJ model.
- `LObjModel:getUvCount`: Returns the number of UV texture coordinates in this OBJ model.
- `LObjModel:getVertexCount`: Returns the number of vertices in this OBJ model.
- `LObjModel:projectToMesh`: Projects the OBJ model into 2D vertex data using a virtual camera, returning a table of vertex rows.
- `LObjModel:renderToImage`: Renders the OBJ model to a GPU texture at the given resolution with optional 90-degree rotation.

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

- `LQuad:getTextureDimensions`: Returns the full dimensions of the source texture this quad references.
- `LQuad:getViewport`: Returns the quad's viewport rectangle within the source texture.
- `LQuad:setViewport`: Updates the quad's viewport rectangle.
- `LQuad:type`: Returns the type name string for this quad object.
- `LQuad:typeOf`: Checks whether this object matches the given type name.

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

- `LShader:hasUniform`: Checks whether this shader declares a uniform with the given name.
- `LShader:release`: Releases the shader resource. If active, the default shader is restored.
- `LShader:send`: Sends a uniform value to this shader by name. Supported types: number, boolean, or table (vec2/vec3/vec4).
- `LShader:type`: Returns the type name string for this shader object.
- `LShader:typeOf`: Checks whether this object matches the given type name.

#### LShape Type

- Retained compound shape that accumulates drawing commands and can be rendered in one call.

##### Fields

- No documented fields.

##### Methods

- `LShape:arc`: Adds a filled or outlined arc command to the shape.
- `LShape:circle`: Adds a filled or outlined circle command to the shape.
- `LShape:clear`: Removes all drawing commands from this shape, making it empty.
- `LShape:draw`: Renders the accumulated shape commands to the screen with optional transform.
- `LShape:ellipse`: Adds an ellipse command to the shape.
- `LShape:getCommandCount`: Returns the number of drawing commands accumulated in this shape.
- `LShape:line`: Adds a line segment command to the shape.
- `LShape:polygon`: Adds a polygon command to the shape from a flat list of x,y coordinate pairs.
- `LShape:polyline`: Adds a connected polyline command to the shape from a flat list of x,y coordinate pairs.
- `LShape:rectangle`: Adds a rectangle command to the shape.
- `LShape:roundedRectangle`: Adds a rounded rectangle command to the shape.
- `LShape:setColor`: Sets the drawing color for subsequent shape commands.
- `LShape:setLineWidth`: Sets the line width for subsequent line-mode shape commands.
- `LShape:triangle`: Adds a triangle command to the shape.
- `LShape:type`: Returns the type name string for this shape object.
- `LShape:typeOf`: Checks whether this object matches the given type name.

#### LSpriteBatch Type

- Batched sprite renderer for efficiently drawing many copies of the same texture.

##### Fields

- No documented fields.

##### Methods

- `LSpriteBatch:add`: Adds a sprite entry to the batch at the given position with optional transform.
- `LSpriteBatch:clear`: Removes all entries from the sprite batch.
- `LSpriteBatch:getBufferSize`: Returns the maximum number of entries this batch can hold.
- `LSpriteBatch:getCount`: Returns the number of sprite entries currently in the batch.
- `LSpriteBatch:release`: Releases the sprite batch resource.
- `LSpriteBatch:type`: Returns the type name string for this sprite batch.
- `LSpriteBatch:typeOf`: Checks whether this object matches the given type name.
