# render

## TL;DR

- The `render` module is a core Platform Services tier subsystem that powers the entire visual output of Lurek2D.

## General Info

- Module group: `Platform Services`
- Source path: `src/render/`
- Lua API path(s): `src/lua_api/render_api.rs`
- Primary Lua namespace: `lurek.render`
- Rust test path(s): src/render/ (inline #[cfg(test)] in canvas, decal_surface, draw_layer, font, image_effect, mesh, shader, shape), src/render/renderer_tests.rs, src/render/postfx_pipeline_tests.rs
- Lua test path(s): none found in the workspace

## Summary

Backed by `wgpu 22`, it utilizes a deferred `RenderCommand` queue architecture. Rather than executing GPU commands immediately during game logic, Lua scripts emit draw commands (for rectangles, circles, lines, polygons, text, textures, and meshes) into a frame-local buffer. At the end of the frame, the `GpuRenderer` sorts these commands by z-order using the `DrawLayer` system, batches compatible operations to minimize state changes, and encodes highly optimized wgpu render passes. This deferred approach ensures that no heavy GPU work stalls the Lua execution thread.

The module supports an extensive array of rendering primitives and techniques. It handles both flat-color and textured geometry, advanced compositing via blend modes and stencil write/test operations, and complex nested draw layers. The `Font` system provides built-in Courier New bitmap atlases alongside dynamic TTF/OTF rasterization (via `fontdue`), complete with rich-text styling, word wrapping, and alignment controls. For 3D workflows, the `ObjLoader` seamlessly parses Wavefront OBJ models and MTL materials, projecting them into 2D `Mesh` geometry with back-face culling and Z-buffering. Rendering can target the main window swapchain or off-screen `Canvas` textures, which are essential for layered compositing and UI workflows.

A standout feature of the `render` module is its robust `PostFxPipeline`. This full-screen post-processing system supports over 20 built-in WGSL fragment shaders (including bloom, blur, vignette, CRT scanlines, chromatic aberration, pixelation, and depth-of-field). Developers can effortlessly chain these effects using cached ping-pong intermediate textures and even compile and register custom WGSL shaders at runtime via the `Shader` manager, with automatic uniform injection for time and resolution. All GPU resource lifecycles—textures, geometry buffers, and pipelines—are managed automatically and garbage-collected by the engine. The comprehensive `lurek.render.*` Lua API gives script developers complete control over this high-performance rendering pipeline, from simple shapes to complex post-processing stacks.

## Files

### canvas.rs

- Fixed-size render canvas carrying pixel dimensions for the GPU surface.
- Logs creation at debug level via the CV01 message code.
- Owned by `GpuRenderer`; does not hold GPU resources itself.

### decal_surface.rs

- Persistent paint-target surface for world-space decals.
- Stores pixel dimensions used by the renderer to allocate backing textures.
- Lightweight data struct with no GPU resources of its own.

### draw_layer.rs

- Z-ordered draw-callback queue flushed once per frame by the render loop.
- Entries hold a depth key and an opaque callback ID returned to Lua.
- Sorted at flush time so draw callbacks execute in front-to-back order.

### font.rs

- Bitmap font atlas loading and runtime font rasterisation.
- This module provides:
- Bundled Courier New bitmap atlases in regular and bold variants.
- Latin-1 coverage for 0x20..=0xFF.
- Terminal-symbol aliases for 0x80..=0x9F and direct Unicode lookups.
- Runtime rasterisation of TTF/OTF fonts into the same atlas format.
- Glyph metrics, text measurement, and word wrapping.

### gpu_renderer.rs

- wgpu-based GPU renderer: vertex batching, draw-call encoding, pipeline caching, and frame presentation.
- Flat-color and textured geometry paths with per-frame vertex/index buffer management.
- User WGSL shader compilation, uniform upload, and per-pipeline-key caching.
- Off-screen canvas render targets with lazy depth/stencil attachment creation.
- Additive point-light accumulation pass with 1-D shadow-map atlas and composite blend.
- Post-processing pipeline integration, screenshot readback, and per-frame render statistics.
- Tessellation helpers for rectangles, rounded rects, ellipses, arcs, triangles, and polygons.
- Stencil write/test pipeline variants with configurable compare and operation modes.
- Bitmap font fallback renderer and thick-line geometry generation utilities.
- Frustum culling via 2-D AABB visibility test against the camera transform.
- Automatic geometry buffer growth when frame vertex/index demand exceeds current capacity.
- Texture upload, font atlas rebuild, and canvas lifecycle tied to slot-map resource pruning.

### image_effect.rs

- Descriptor for a single named shader pass in a post-processing chain.
- Carries float uniform parameters and an enable flag per pass.
- Used by the render pipeline to build configurable multi-pass effects.

### mesh.rs

- 2D mesh geometry: vertices with position, UV, and RGBA color.
- Triangle topology modes: independent triangles, fan, and strip.
- Index-buffer support and topology-agnostic triangulation.

### mod.rs

- GPU rendering pipeline: wgpu device, passes, command encoding, and post-fx chain.
- Draw primitives: sprites, shapes, meshes, text, decals, and canvas pixel ops.
- Font rasterisation, shader management, and image-effect descriptors.
- Draw-layer ordering and blend/stencil/depth state per command.

### obj_loader.rs

- OBJ model loader for 2D projection.
- Loads Wavefront .obj files and projects 3D geometry into 2D for use with
- the raycaster and globe rendering systems. This is NOT a 3D rendering
- pipeline — models are reduced to 2D projections (orthographic or perspective)
- for display in the 2D engine.
- ## Feature Gate
- This module is gated behind the `obj-loader` feature (enabled by default).
- Disable it to reduce binary size if your game doesn't use 3D model loading:
- ```toml
- [dependencies]
- lurek2d = { version = "...", default-features = false, features = [...] }
- ```
- ## Capabilities
- Wavefront OBJ and MTL file loading via a built-in hand parser.
- Triangulated face model with per-vertex position, UV, and normal indices.
- Named materials carrying diffuse colour and optional texture path.
- CPU software rasteriser producing `ImageData` thumbnails with back-face culling, Z-buffer, and key lighting.
- Perspective projection of OBJ models into engine `Mesh` geometry for GPU rendering.
- Instance projection with Y-axis rotation, uniform scale, and depth output for scene sorting.
- Local `Vec3`/`Vec2` types for self-contained 3-D math without engine-wide dependencies.
- `ObjCamera` helper packing position, lookat target, and FOV for projection calls.
- `ObjLoader` stateless parser facade with both file-based and in-memory entry points.
- MTL parsing extracting `newmtl`, `Kd`, and `map_Kd` into a flat material list.
- OBJ face-vertex index resolver handling 1-based and negative (relative) indices.
- Edge-function barycentric rasterisation for the CPU renderer path.

### postfx_pipeline.rs

- Full-screen post-processing pipeline: compile, cache, and execute GPU shader passes.
- 20+ built-in WGSL fragment shaders: bloom, blur, vignette, noise, grayscale, sepia, invert, CRT, chromatic aberration, scanlines, pixelate, hue-shift, edge-detect, god-rays, water-distort, sharpen, dither, outline, depth-of-field, motion-blur.
- Shared fullscreen-triangle vertex shader emitted once and reused by all effects.
- Ping-pong intermediate textures for multi-pass compositing without extra allocations.
- Named parameter map → 16-float uniform packing for effect configuration.
- Runtime registration of custom WGSL fragment shaders under user-chosen names.
- Auto-uniform injection of time, frame count, and resolution into the last four slots.
- Identity copy pass used as fallback when no effects are enabled.
- Pass sequencing respects insertion order; final result written directly to the surface target.

### province_map_pipeline.rs

- Dedicated fullscreen province-map GPU pipeline.
- Binds province id texture, border index texture, distance field texture, and storage buffers.
- Owns uniforms for viewport mapping and strategic/tactical mode selection.

### renderer.rs

- Defines the `RenderCommand` enum — the complete vocabulary of draw, state, and control operations submitted each frame.
- Provides blend, stencil, and depth mode enums for compositing and test configuration.
- Contains text alignment and draw-mode enums shared across shape, font, and path rendering.
- Houses post-processing pass descriptors and rich-text span types.
- Declares particle instance and render-shape types for the particle system pipeline.
- Includes physics debug shape and config records for collider overlay rendering.
- Provides path-segment, gradient, hex, bevel, and nine-slice draw primitives.
- Defines Spine slot draw records, sort-group markers, and compositing layer commands.
- Supplies `TextureData` for CPU-to-GPU texture uploads and `DrawableKind` for generic draw utilities.

### shader.rs

- Parse and validate user-supplied WGSL fragment shaders via naga.
- Rewrite fragment entry points into plain helper functions for wrapper-pipeline injection.
- Extract `@location` input slots (color, UV) and enforce vec type constraints.
- Manage typed uniform values (`float`, `vec2`–`vec4`, `int`, `bool`) for per-frame GPU upload.
- Provide deterministic ordered-uniform iteration for stable buffer layout.
- Strip and consume WGSL `@attribute(...)` tokens during header rewriting.

### shape.rs

- Compound shape storage: named, replayable sequences of vector-drawing commands.
- Shape commands: rectangles, circles, ellipses, arcs, polygons, lines, and polylines.
- State tracking: per-shape color and line-width carried across replays.

## Lua API Ref

- Binding: `src/lua_api/render_api.rs`
- Namespace: `lurek.render`

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

### Enums

- No documented module-level enums/constants.

### Types


#### LCanvas Type


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


##### Fields

- No documented fields.

##### Methods

- `LNineSlice:getInsets`: Returns the border insets (top, right, bottom, left) that define the stretchable regions.
- `LNineSlice:getTextureSize`: Returns the pixel dimensions of the underlying source texture.
- `LNineSlice:type`: Returns the type name of this object.
- `LNineSlice:typeOf`: Checks whether this object matches the given type name.


#### LObjModel Type


##### Fields

- No documented fields.

##### Methods

- `LObjModel:getFaceCount`: Returns the number of faces (triangles) in this OBJ model.
- `LObjModel:getNormalCount`: Returns the number of vertex normals in this OBJ model.
- `LObjModel:getUvCount`: Returns the number of UV texture coordinates in this OBJ model.
- `LObjModel:getVertexCount`: Returns the number of vertices in this OBJ model.
- `LObjModel:projectToMesh`: Projects the OBJ model into 2D vertex data using a virtual camera, returning a table of vertex rows.
- `LObjModel:renderToImage`: Renders the OBJ model to a GPU texture at the given resolution with optional 90-degree rotation.


#### LQuad Type


##### Fields

- No documented fields.

##### Methods

- `LQuad:getTextureDimensions`: Returns the full dimensions of the source texture this quad references.
- `LQuad:getViewport`: Returns the quad's viewport rectangle within the source texture.
- `LQuad:setViewport`: Updates the quad's viewport rectangle.
- `LQuad:type`: Returns the type name string for this quad object.
- `LQuad:typeOf`: Checks whether this object matches the given type name.


#### LShader Type


##### Fields

- No documented fields.

##### Methods

- `LShader:hasUniform`: Checks whether this shader declares a uniform with the given name.
- `LShader:release`: Releases the shader resource. If active, the default shader is restored.
- `LShader:send`: Sends a uniform value to this shader by name. Supported types: number, boolean, or table (vec2/vec3/vec4).
- `LShader:type`: Returns the type name string for this shader object.
- `LShader:typeOf`: Checks whether this object matches the given type name.


#### LShape Type


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

## References

- `font`: Imports or references `src/font/`. Cross-group dependency from `Platform Services` into `Edge/Integration`.
- `image`: Imports or references `src/image/`. Dependency stays inside `Platform Services` and should remain acyclic.
- `light`: Imports or references `light` from `src/light/`.
- `math`: Imports or references `math` from `src/math/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.
- `sprite`: Imports or references `sprite` from `src/sprite/`.
