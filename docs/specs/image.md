# image

## TL;DR

- Manages CPU image buffers, compressed textures, layered stacks, palette remapping, and atlases.
- Supports pixel-level effects, nine-slices, province grids, and graphical debug visualizations.

## General Info

- Module group: `Platform Services`
- Source path: `src/image/`
- Binding: `src/lua_api/image_api.rs`
- Namespace: `lurek.image`
- Lua API surface: `13` functions, `10` types, `90` methods
- Rust test path(s): tests/rust/unit/image_tests.rs, tests/rust/stress/image_stress_tests.rs
- Lua test path(s): tests/lua/unit/test_image_core_unit.lua, tests/lua/unit/test_image.lua, tests/lua/unit/test_image_effect.lua, tests/lua/unit/test_render_core_unit.lua, tests/lua/stress/test_image_stress.lua, tests/lua/evidence/test_evidence_image_drawing.lua, tests/lua/evidence/test_evidence_imagedata.lua, tests/lua/evidence/test_evidence_image_effects.lua, tests/lua/evidence/test_evidence_imagedata_effects.lua

## Summary

- The `image` module is the engine's CPU-side image workbench for users who need pixel data to be loaded, transformed, composed, inspected, compared, and exported under one coherent API.
- Its role is broader than ordinary file loading. Raw buffers, filters, resizing, layers, palettes, atlas packing, drawing helpers, visualization output, and serialization all live here because real image workflows usually chain several of those operations together.
- This breadth matters because many projects need to do image work inside the engine, not only before runtime in an external editor. Asset preparation, theme variation, generated visuals, screenshots, comparison tests, and data extraction can all depend on image processing.
- Layer support is especially important for tooling and content workflows where staged or partially non-destructive composition is useful.
- Color and tone operations expand the module into style control, while filter kernels and geometric transforms make it practical for more technical pixel-space workflows such as resampling, blur-like effects, and rotation.
- Atlas and texture-preparation helpers are critical from a runtime perspective because many images become packed regions, sprite sources, UI textures, or render-ready assets rather than staying as isolated files.
- This makes the module a bridge between authored content and render consumption. `render` eventually uses the resulting textures, but `image` owns the CPU-side transformations that prepare and validate them.
- Comparison and diff-style helpers turn the module into a testing and evidence surface, and visualization support makes it useful for diagnostics as well as assets.
- Visualization support is one of the most distinctive capabilities. Audio analysis, graph structures, easing curves, procedural outputs, camera data, and other runtime information can all be turned into inspectable images, making the module useful for debugging as well as for asset work.
- Province and grid extraction features show that image data can also be a source of gameplay structure. A picture may become region data, mask data, or map guidance rather than only something to display.
- That two-way relationship is important: `image` is useful both after a visual asset exists and when visual data is being used as input to another system.
- Serialization and format conversion keep the module connected to the outside world. The same subsystem can move between files, generated runtime state, debugging artifacts, and exported outputs without pushing those conversions into ad hoc helpers.
- That flexibility also makes the module useful for tool-driven inspection as well as asset preparation.
- This makes the module useful across the whole asset lifecycle: load, inspect, transform, compare, pack, export, and sometimes reinterpret as data for another system.
- `render` consumes prepared results, but `image` owns pixel-domain manipulation, inspection, packing, and export before or outside final rendering.
- Read `image` as the engine's pixel-domain authority for asset prep and tooling.

## Imports

- `animation`: Imports or references `animation` from `src/animation/`.
- `camera`: Imports or references `camera` from `src/camera/`.
- `color`: Imports or references `src/color/`. Cross-group dependency from `Platform Services` into `Edge/Integration`.
- `math`: Imports or references `math` from `src/math/`.
- `province`: Imports or references `src/province/`. Cross-group dependency from `Platform Services` into `Edge/Integration`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### animated_gif.rs

- Encodes a sequence of RGBA frames into animated GIF output and owns the save path used by image exports.
- Defines repeat and timing options that validate frame delays and playback speed before bytes are emitted.
- Builds per-frame palette data from ImageData snapshots so tooling can export simple preview animations.
- Handles quantization and encoder setup in one owner instead of spreading GIF policy across render code.
- Open this file when looping policy, frame timing, or GIF export failures affect generated image sequences.

### compressed.rs

- Loads DDS-backed compressed textures and stores format, dimensions, and mip levels without CPU decompression.
- Maps DXGI and legacy D3D format markers into Lurek enums so renderer upload code sees stable texture tags.
- Validates file signatures and header fields before exposing width, height, mip count, and format metadata.
- Keeps compressed-image parsing separate from ordinary RGBA image loading and PNG style content workflows.
- Open this owner when DDS detection, format mapping, or compressed texture metadata looks incorrect at load.

### effects.rs

- Implements the main CPU image-effects surface for color correction, transforms, filtering, and composition.
- Applies brightness, contrast, saturation, gamma, tint, grayscale, sepia, invert, threshold, and posterize.
- Adds deterministic RGB noise and alpha scaling so tests and tooling can reproduce visual post-processing.
- Owns crop, region copy, horizontal flip, vertical flip, and ninety-degree rotation for image editing flows.
- Provides nearest, bilinear, and Lanczos resize paths through ResizeFilter so callers can choose quality.
- Runs blur, sharpen, and generic square-kernel convolution while clamping edges and preserving source alpha.
- Blends source images with alpha-aware blit semantics and a fast opaque-copy path for large image overlays.
- Draws nine-slice patches by extracting source regions, resizing them, and composing them into a target UI.
- Open this file when visual output drift comes from pixel math rather than loading, storage, or GPU upload.

### image_data.rs

- Defines the core mutable RGBA buffer used by image tooling, debug rendering, and software-side transforms.
- Constructs buffers from dimensions, files, encoded bytes, or exact RGBA payloads with strict size checks.
- Exposes width, height, dimensions, and raw-byte access so higher layers can move image data efficiently.
- Provides per-pixel read, write, paste, and map operations for subsystems that mutate images in memory.
- Draws rectangles, circles, lines, bitmap labels, and font-atlas text directly into the packed pixel buffer.
- Encodes PNG bytes for export while keeping raw storage row-major and local to the Rust image subsystem.
- Uses a parallel pixel-mapping path above a threshold so large transforms can scale across worker threads.
- Logs image-load and byte-mismatch diagnostics here, making this the owner for CPU-side buffer integrity.
- Open this file when image bytes, dimensions, drawing, or in-memory mutation semantics behave incorrectly.

### layers.rs

- Defines named image layers with visibility, opacity, and embedded ImageData for simple layered art editing.
- Stores ordered layer stacks in LayeredImage so import, serialization, and merge flows share one data shape.
- Adds and removes layers while preserving author-facing metadata instead of flattening every edit eagerly.
- Merges layers through alpha compositing into one ImageData output for downstream save and preview features.
- Open this owner when layer ordering, visibility, opacity, or flattening output does not match expectations.

### mod.rs

- Exports the image subsystem surface that groups buffers, effects, formats, atlases, layers, and visuals.
- Acts as the navigation index for CPU image ownership, showing where loading, edits, packing, and specs live.
- Re-exports ImageData, compressed assets, palette LUTs, layered images, GIF helpers, and atlas structures.
- Keeps compatibility exports such as ProvinceGrid local to the module boundary instead of scattered in users.
- Open this file first when tracing which image feature belongs to storage, processing, serialization, or UI.
- This owner defines image-module visibility and composition, not the pixel algorithms implemented below it.

### palette_lut.rs

- Owns palette remapping tables that convert source colors into replacement colors across a whole image pass.
- Stores paired from and to colors, lets callers edit entries, and reports the active mapping count directly.
- Applies remaps with either direct scanning or a hashed lookup path so large palettes stay practical to use.
- Supports cyclic shifting of destination colors, making palette animation possible without touching pixels.
- Open this file when indexed recoloring, palette cycling, or LUT entry management behaves incorrectly.

### rect_packing.rs

- Implements a shelf-based rectangle packer used to place many sprites or regions into bounded atlas space.
- Tracks padding, packed outputs, and shelf cursor state so callers can inspect occupancy after each insert.
- Returns PackedRect placements only when width and height fit the configured container without overlap.
- Resets internal shelves and placements on clear, making this the owner for packer lifecycle semantics.
- Open this file when atlas occupancy, placement order, or padding handling produces wasted or invalid space.

### render.rs

- This file owns the thin `ImageData` rendering bridge that turns image buffers into renderer commands.
- It emits `DrawImage` command payloads with texture keys and screen placement, and can clone buffers as images.
- Open this file when image-to-render command translation changes; pixel storage and effects live in siblings.

### serial.rs

- Owns the custom LIMG binary format for saving and loading flat images and layered image documents.
- Writes file headers, version tags, and type markers so loaders can reject incompatible or corrupt payloads.
- Compresses and decompresses image bytes with zlib while keeping format checks local to one serialization owner.
- Supports both path-based and in-memory decode flows for tests, tools, and runtime asset import pipelines.
- Persists layered images with names, visibility flags, opacity values, and embedded RGBA layer payloads.
- Open this file when LIMG compatibility, compression, or layered-image round trips fail or drift in shape.

### texture.rs

- Loads CPU-side texture data from files or raw RGBA bytes before the renderer turns them into GPU resources.
- Stores width, height, color space, and pixel bytes together so upload code can stay thin and predictable.
- Parses sRGB and linear color-space labels, rejecting unknown tags before they leak into renderer behavior.
- Provides alpha premultiplication on RGBA8 bytes for pipelines that expect premultiplied blend semantics.
- Open this file when texture ingest, color-space tagging, or premultiply handling causes visual mismatches.

### texture_atlas.rs

- Implements a named texture atlas that packs image regions and records their placement inside one sheet.
- Stores atlas dimensions, padding, shelf state, and region metadata so sprite lookup stays data driven.
- Supports optional nine-slice insets per region, making UI skin assets travel with their packing metadata.
- Exposes region counts, atlas size, and immutable region views for tools that inspect generated sprite maps.
- Open this file when atlas packing, region lookup, or nine-slice metadata does not match authored assets.

### visualization/animation.rs

- Renders animation state into debug images that show frame grids, playback steps, and control-state panels.
- Highlights the current frame inside generated grids so asset review can spot sequencing mistakes quickly.
- Builds timeline strips from snapshot indices, making playback history visible without a live renderer.
- Draws run, idle, pause, resume, and summary labels so screenshot-based tests can verify animation states.
- Open this file when animation debug imagery is wrong even though the underlying Animation data is correct.

### visualization/audio.rs

- Turns mono and stereo sample arrays into waveform images for debugging audio content and UI visualizers.
- Normalizes peak amplitude per render so quiet and loud sources stay readable on the same plotting surface.
- Draws baseline guides, channel separators, and bounds frames to make timing and clipping easy to inspect.
- Supports a zoomed waveform mode that interpolates early samples for transient-focused signal inspection.
- Provides a labeled colored strip renderer for HUD or tool previews that need lightweight waveform graphics.
- Open this owner when waveform scaling, channel layout, or sample-to-pixel mapping looks visually wrong.

### visualization/camera.rs

- Produces camera-debug images that visualize viewport framing, zoom, follow logic, rotation, and shake.
- Draws world grids, viewport rectangles, and center markers so camera position and scale stay inspectable.
- Builds zoom-comparison panels that reveal how viewport size changes across multiple authored zoom values.
- Renders rotated point sets through Camera2D transforms to expose world-to-screen mapping behavior clearly.
- Shows bounds lists, follow trails, targets, dead zones, and shake traces inside standalone image reports.
- Includes wrapper helpers that package the same camera diagnostics under alternative call shapes for tests.
- Depends on Camera2D and ImageData only, keeping these visual probes separate from runtime scene rendering.
- Open this file when camera visualization is misleading or when movement diagnostics need new image evidence.

### visualization/easing.rs

- Renders easing and Bezier diagnostics into charts so motion curves can be inspected without live playback.
- Builds multi-panel galleries and shared comparison graphs for side-by-side evaluation of easing behavior.
- Plots arbitrary curve callbacks onto raster images, making this the owner for sampled chart generation.
- Visualizes Bezier control points, segments, derivatives, and edits using the math Bezier runtime directly.
- Supports advanced screenshots that show interpolation angle and length for curve-editing regression checks.
- Open this file when motion-curve images are wrong or when new charting views are needed for animation work.

### visualization/facade.rs

- Provides the shared HSV-to-RGB helper used by visualization modules that need stable debug color palettes.
- Keeps hue conversion local to the image-visualization layer so callers do not duplicate color-wheel math.
- Open this tiny owner when visualization colors drift or when a new debug view needs HSV-based swatches.

### visualization/geometry.rs

- Renders geometry demonstrations into images for validating rasterized shapes and math helper behavior.
- Draws polygon galleries, spirals, and filled primitive samples so tool output can prove drawing basics.
- Uses math helpers like convex hull, centroids, Bresenham lines, and angles to create visual test fixtures.
- Shows segment, circle, and line intersections with explicit markers so spatial edge cases stay inspectable.
- Keeps geometry visualization separate from math implementations, making screenshots a consumer not an owner.
- Open this file when geometry proof images are wrong even though lower-level math functions may still pass.

### visualization/graph.rs

- Renders graph and flow diagrams into images with nodes, edges, labels, and summary text overlays.
- Shows active and removed edges separately so topology edits or diff states remain visible in one snapshot.
- Draws item-flow arrows and moving payload markers for logic demos that need graph-like status imagery.
- Keeps graph visualization lightweight by consuming plain positions, colors, and labels instead of graph types.
- Open this owner when graph screenshots need layout or styling fixes without changing the source simulation.

### visualization/image_ops.rs

- Builds composite images that compare source variants, transform grids, and color-wheel style references.
- Places labeled inputs side by side so image-processing deltas can be checked in one exported frame.
- Generates a four-column transform grid showing original, inverted, grayscale, and tinted sample outputs.
- Renders an HSV wheel directly into pixels, making this a general visualization helper for color debugging.
- Open this file when comparison layouts or operation showcase images need changes for docs or regression art.

### visualization/mod.rs

- Exports the image-visualization surface that groups debug renderers for animation, audio, camera, and UI.
- Acts as the index for raster helpers that turn engine data into screenshots and proof images for tooling.
- Re-exports the facade helper internally so sibling visualization files can share one HSV color conversion.
- Points readers to geometry, graph, image-op, noise, and procgen views instead of mixing those concerns here.
- Keeps visualization module visibility centralized, which makes spec generation and ownership tracing simpler.
- Open this file first when adding a new debug image module or when public visualization exports must change.
- This index owns composition of visualization helpers rather than the sampled drawing logic inside each file.
- Use it to see the complete visualization feature set before editing a specific owner like camera or audio.

### visualization/noise.rs

- Turns scalar noise functions and cached height arrays into grayscale or terrain-colored diagnostic images.
- Supports normalized and raw grayscale views so callers can compare clamped terrain input against source data.
- Applies biome-style color bands for water, shore, land, and snow to make threshold decisions immediately visible.
- Builds side-by-side comparison strips from multiple maps, which is useful for tuning frequency and persistence.
- Open this file when noise previews, elevation coloring, or map-to-pixel conversion look inconsistent.

### visualization/procgen.rs

- Visualizes procedural-generation structures such as cellular grids, dungeons, Voronoi cells, and Delaunay meshes.
- Renders occupancy grids with caller-supplied colors so automata and map-carving stages stay easy to inspect.
- Draws point clouds and colored samples without extra graph types, keeping procgen debug output lightweight.
- Uses HSV-derived edge colors for triangulation views so adjacent triangles remain readable in dense outputs.
- Open this file when procgen screenshots are wrong or when a new generator needs a quick image proof helper.

### visualization/ui.rs

- Renders UI mockups and HUD previews into images for layout checks, screenshots, and documentation examples.
- Builds a settings-style panel with labels, toggles, sliders, progress bars, swatches, and action buttons.
- Draws gameplay HUD bars for health, mana, stamina, experience, and cooldown states with readable labels.
- Keeps presentation experiments local to image tooling so UI visuals can evolve without touching runtime widgets.
- Open this file when mock panel composition or HUD status imagery needs adjustment for tests or docs.



## Lua API Ref

### Functions

- `lurek.image.fromScreen() -> LImageData|nil`: Returns a completed screen capture image or requests one for a future call.
- `lurek.image.isCompressed(filename) -> boolean`: Returns whether a GameFS image file begins with DDS compressed image magic bytes.
- `lurek.image.loadImage(filename) -> LImageData`: Loads and decodes image data from GameFS.
- `lurek.image.loadLayered(filename) -> LLayeredImage`: Loads a serialized layered image stack from GameFS.
- `lurek.image.newCompressedData(filename) -> LCompressedImageData`: Loads DDS compressed image data from GameFS.
- `lurek.image.newImageData(width_or_filename, height?) -> LImageData`: Creates empty image data from dimensions or decodes image data from a GameFS filename.
- `lurek.image.newImageDataFromBytes(w, h, bytes) -> LImageData`: Creates image data from raw RGBA bytes and explicit dimensions.
- `lurek.image.newLayeredImage(width, height) -> LLayeredImage`: Creates a layered image stack with one or more blank layers.
- `lurek.image.newPaletteLut() -> LPaletteLUT`: Creates an empty palette lookup table.
- `lurek.image.newProvinceGrid(filename) -> LProvinceGrid`: Loads a province id grid from an image file under the current game directory.
- `lurek.image.saveGIF(frames, filename, opts?) -> nil`: Encodes a sequence of equally sized image frames as an animated GIF.
- `lurek.image.saveImage(img_ud, filename) -> nil`: Saves an image data object to a path under the current game directory.
- `lurek.image.savePNG(img_ud, filename) -> nil`: Encodes image data as PNG and writes it under the current game directory.

### Callbacks

- `LImageData:mapPixel` param `func` (`function`): Callback receiving `(x, y, r, g, b, a)` and returning replacement channels.
- `LImageData:mapPixels` param `func` (`function`): Callback receiving `(x, y, r, g, b, a)` and returning replacement channels.

### Enums

- No documented module-level enums/constants.

### Types

#### LCompressedImageData Type

- Lua-side handle for compressed DDS image metadata and mipmap data.

##### Fields

- No documented fields.

##### Methods

- `LCompressedImageData:getDimensions() -> integer`: Returns compressed image dimensions.
- `LCompressedImageData:getFormat() -> string`: Returns the compressed image format name.
- `LCompressedImageData:getHeight() -> integer`: Returns compressed image height. This method is available to Lua scripts.
- `LCompressedImageData:getMipmapCount() -> integer`: Returns the number of mipmap levels in this compressed image.
- `LCompressedImageData:getWidth() -> integer`: Returns compressed image width. This method is available to Lua scripts.
- `LCompressedImageData:type() -> string`: Returns the Lua-visible type name for this compressed image handle.
- `LCompressedImageData:typeOf(name) -> boolean`: Returns whether this compressed image handle matches a supported type name.

#### LImageData Type

- Provides Lua methods for reading, editing, filtering, drawing, and encoding image data.

##### Fields

- No documented fields.

##### Methods

- `LImageData:alphaMask(factor) -> nil`: Multiplies this image alpha channel by a factor in place.
- `LImageData:applyPaletteLut(lut_ud) -> nil`: Applies a palette lookup table to this image in place.
- `LImageData:blit(src_ud, dst_x, dst_y) -> nil`: Copies a source image into this image at a destination coordinate.
- `LImageData:blur(radius) -> LImageData`: Returns a blurred copy of this image.
- `LImageData:brightness(factor) -> nil`: Applies a brightness factor to this image in place.
- `LImageData:contrast(factor) -> nil`: Applies a contrast factor to this image in place.
- `LImageData:convolve(kernel_t, ksize) -> LImageData`: Applies a convolution kernel and returns the filtered image.
- `LImageData:crop(x, y, w, h) -> LImageData`: Returns a cropped image region. This method is available to Lua scripts.
- `LImageData:diff(other_ud) -> number`: Computes a difference metric against another image.
- `LImageData:drawCircle(cx, cy, radius, r, g, b, a) -> nil`: Draws a filled circle into this image.
- `LImageData:drawLine(x0, y0, x1, y1, r, g, b, a) -> nil`: Draws a line into this image. This method is available to Lua scripts.
- `LImageData:drawNineSlice(src_ud, src_x, src_y, src_w, src_h, dst_x, dst_y, dst_w, dst_h, inset_left, inset_right, inset_top, inset_bottom) -> nil`: Draws a nine-slice region from a source image into this image.
- `LImageData:drawRect(x, y, w, h, r, g, b, a) -> nil`: Draws a filled rectangle into this image.
- `LImageData:encode(format) -> string`: Encodes image data in a supported format.
- `LImageData:fill(r, g, b, a) -> nil`: Fills the whole image with one RGBA color.
- `LImageData:flipHorizontal() -> nil`: Flips this image horizontally in place.
- `LImageData:flipVertical() -> nil`: Flips this image vertically in place.
- `LImageData:gamma(gamma) -> nil`: Applies gamma correction to this image in place.
- `LImageData:getDimensions() -> integer`: Returns image dimensions. This method is available to Lua scripts.
- `LImageData:getHeight() -> integer`: Returns image height. This method is available to Lua scripts.
- `LImageData:getPixel(x, y) -> integer`: Returns RGBA channels at a pixel coordinate.
- `LImageData:getRawBytes() -> string`: Returns raw image bytes as a Lua string.
- `LImageData:getRegion(x, y, w, h) -> LImageData|nil`: Returns an image region when the requested rectangle is inside bounds.
- `LImageData:getString() -> string`: Returns raw image bytes as a Lua string.
- `LImageData:getWidth() -> integer`: Returns image width. This method is available to Lua scripts.
- `LImageData:grayscale() -> nil`: Converts this image to grayscale in place.
- `LImageData:invert() -> nil`: Inverts image color channels in place.
- `LImageData:mapPixel(func) -> nil`: Applies a Lua callback to every pixel and replaces each pixel with returned RGBA values.
- `LImageData:mapPixels(func) -> nil`: Applies a Lua callback to every pixel and replaces each pixel with returned RGBA values.
- `LImageData:noise(amount) -> nil`: Adds noise to this image in place. This method is available to Lua scripts.
- `LImageData:paste(src_ud, dx, dy) -> nil`: Pastes a source image into this image at unsigned destination coordinates.
- `LImageData:posterize(levels) -> nil`: Reduces image colors to a fixed number of levels in place.
- `LImageData:resize(width, height, filter) -> LImageData|nil`: Returns a resized image using an optional named filter.
- `LImageData:resizeNearest(new_w, new_h) -> LImageData`: Returns a resized image using nearest-neighbor sampling.
- `LImageData:rotate90cw() -> LImageData`: Returns a new image rotated ninety degrees clockwise.
- `LImageData:saturation(factor) -> nil`: Applies a saturation factor to this image in place.
- `LImageData:sepia() -> nil`: Applies a sepia filter to this image in place.
- `LImageData:setPixel(x, y, r, g, b, a) -> nil`: Sets RGBA channels at a pixel coordinate.
- `LImageData:setRawData(bytes) -> nil`: Replaces the image byte buffer with raw bytes.
- `LImageData:sharpen() -> LImageData`: Returns a sharpened copy of this image.
- `LImageData:threshold(value) -> nil`: Applies a threshold filter to this image in place.
- `LImageData:tint(tr, tg, tb, factor) -> nil`: Blends this image toward a tint color in place.
- `LImageData:type() -> string`: Returns the Lua-visible type name for this image data handle.
- `LImageData:typeOf(name) -> boolean`: Returns whether this image data handle matches the `LImageData` type name.

#### LLayeredImage Type

- Lua-side handle for multiple image layers with visibility, opacity, and ordering.

##### Fields

- No documented fields.

##### Methods

- `LLayeredImage:addLayer(name?) -> integer`: Adds a blank layer with an optional name.
- `LLayeredImage:getHeight() -> integer`: Returns the layered image height. This method is available to Lua scripts.
- `LLayeredImage:getLayer(index) -> LImageData`: Returns image data for a layer by one-based index.
- `LLayeredImage:getName(index) -> string`: Returns a layer name by one-based index.
- `LLayeredImage:getOpacity(index) -> number`: Returns a layer opacity by one-based index.
- `LLayeredImage:getWidth() -> integer`: Returns the layered image width. This method is available to Lua scripts.
- `LLayeredImage:isVisible(index) -> boolean`: Returns layer visibility by one-based index.
- `LLayeredImage:layerCount() -> integer`: Returns the number of layers in the stack.
- `LLayeredImage:merge() -> LImageData`: Merges visible layers into a single image data object.
- `LLayeredImage:moveLayer(from_idx, to_idx) -> boolean`: Moves a layer from one one-based index to another.
- `LLayeredImage:removeLayer(index) -> boolean`: Removes a layer by one-based index.
- `LLayeredImage:save(path) -> nil`: Saves the layered image stack to a file.
- `LLayeredImage:setLayer(index, img) -> boolean`: Replaces a layer's image data by one-based index.
- `LLayeredImage:setName(index, name) -> boolean`: Sets a layer name by one-based index.
- `LLayeredImage:setOpacity(index, opacity) -> boolean`: Sets a layer opacity by one-based index.
- `LLayeredImage:setVisible(index, visible) -> boolean`: Sets layer visibility by one-based index.
- `LLayeredImage:swapLayers(a, b) -> boolean`: Swaps two layers by one-based indices.
- `LLayeredImage:type() -> string`: Returns the Lua-visible type name for this layered image handle.
- `LLayeredImage:typeOf(name) -> boolean`: Returns whether this layered image handle matches a supported type name.

#### LPaletteLUT Type

- Lua-side handle for palette color remapping.

##### Fields

- No documented fields.

##### Methods

- `LPaletteLUT:clear() -> nil`: Removes every color mapping from this palette lookup table.
- `LPaletteLUT:cycle(offset) -> nil`: Cycles palette mappings by an offset.
- `LPaletteLUT:getColorCount() -> integer`: Returns the number of color mappings in this palette lookup table.
- `LPaletteLUT:setColor(fr, fg, fb, fa, tr, tg, tb, ta) -> nil`: Adds a color mapping from source RGBA channels to destination RGBA channels.
- `LPaletteLUT:type() -> string`: Returns the Lua-visible type name for this palette lookup table handle.
- `LPaletteLUT:typeOf(name) -> boolean`: Returns whether this palette lookup table handle matches a supported type name.

#### LProvinceGrid Type

- Lua-side handle for a province id grid decoded from an image.

##### Fields

- No documented fields.

##### Methods

- `LProvinceGrid:adjacencies() -> table`: Returns province adjacency records and shared border pixel counts.
- `LProvinceGrid:borderSegments() -> table`: Returns border line segments between neighboring provinces.
- `LProvinceGrid:deserializeShapeData(bytes) -> LuaValue`: Decodes serialized province shape data into span and segment tables.
- `LProvinceGrid:drawShapes(x?, y?, w?, h?) -> integer`: Queues filled polygon draw commands for province shapes, optionally culled to a viewport rect.
- `LProvinceGrid:getAt(x, y) -> integer`: Returns the province id stored at grid coordinates.
- `LProvinceGrid:getHeight() -> integer`: Returns the province grid height. This method is available to Lua scripts.
- `LProvinceGrid:getPolygons() -> table`: Returns polygon rings for every province.
- `LProvinceGrid:getPolygonsSimplified() -> table`: Returns simplified polygon rings for every province.
- `LProvinceGrid:getWidth() -> integer`: Returns the province grid width. This method is available to Lua scripts.
- `LProvinceGrid:provinceCount() -> integer`: Returns the number of distinct provinces in the grid.
- `LProvinceGrid:provinceSpans() -> table`: Returns horizontal province spans by row.
- `LProvinceGrid:serializeShapeData() -> string`: Serializes province span and border shape data into a binary Lua string.
- `LProvinceGrid:type() -> string`: Returns the Lua-visible type name for this province grid handle.
- `LProvinceGrid:typeOf(name) -> boolean`: Returns whether this province grid handle matches a supported type name.

#### LProvinceGridAdjacenciesResult Type

- Generated result shape from @field tags.

##### Fields

- `border_pixels` (`integer`): Number of shared border pixels.
- `province_a` (`integer`): First province id.
- `province_b` (`integer`): Second province id.

##### Methods

- No documented methods.

#### LProvinceGridBorderSegmentsResult Type

- Generated result shape from @field tags.

##### Fields

- `province_a` (`integer`): First province id.
- `province_b` (`integer`): Second province id.
- `x0` (`number`): Segment start x.
- `x1` (`number`): Segment end x.
- `y0` (`number`): Segment start y.
- `y1` (`number`): Segment end y.

##### Methods

- No documented methods.

#### LProvinceGridGetPolygonsResult Type

- Generated result shape from @field tags.

##### Fields

- `province_id` (`integer`): Province id.
- `rings` (`table`): Array of rings; each ring is an array of [x, y] pairs.

##### Methods

- No documented methods.

#### LProvinceGridGetPolygonsSimplifiedResult Type

- Generated result shape from @field tags.

##### Fields

- `province_id` (`integer`): Province id.
- `rings` (`table`): Array of simplified rings; each ring is an array of [x, y] pairs.

##### Methods

- No documented methods.

#### LProvinceGridProvinceSpansResult Type

- Generated result shape from @field tags.

##### Fields

- `province_id` (`integer`): Province id.
- `x0` (`integer`): Start x coordinate.
- `x1` (`integer`): End x coordinate.
- `y` (`integer`): Scanline y coordinate.

##### Methods

- No documented methods.

## References

- `animation`: Imports or references `animation` from `src/animation/`.
- `camera`: Imports or references `camera` from `src/camera/`.
- `color`: Imports or references `src/color/`. Cross-group dependency from `Platform Services` into `Edge/Integration`.
- `math`: Imports or references `math` from `src/math/`.
- `province`: Imports or references `src/province/`. Cross-group dependency from `Platform Services` into `Edge/Integration`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- No additional module-specific notes.
