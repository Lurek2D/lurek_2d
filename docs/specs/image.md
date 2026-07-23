<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/image.md or source docstrings instead. -->

# image

## TL;DR

- Manages CPU image buffers, PNG texture loading, layered stacks, palette remapping, and atlases.
- Supports bounded pixel-level effects, layers, palette mapping, CPU-side atlas preparation, and encoded-byte export.

## General Info

- Module group: `Platform Services`
- Source path: `src/image`
- Binding: `src/lua_api/image_api.rs`
- Namespace: `lurek.image`
- Lua API surface: `15` functions, `12` types, `106` methods
- User-facing: `true`
- Plugin tier: `not_evaluated`

## Summary

- The `image` module is the engine's CPU-side image workbench for users who need pixel data to be loaded, transformed, composed, inspected, compared, and exported under one coherent API.
- Its role is broader than ordinary file loading. Raw buffers, filters, resizing, layers, palettes, atlas packing, drawing helpers, and serialization all live here because real image workflows usually chain several of those operations together.
- This breadth matters because many projects need to do image work inside the engine, not only before runtime in an external editor. Asset preparation, theme variation, generated visuals, screenshots, comparison tests, and data extraction can all depend on image processing.
- Layer support is especially important for tooling and content workflows where staged or partially non-destructive composition is useful.
- Color and tone operations expand the module into style control, while filter kernels and geometric transforms make it practical for more technical pixel-space workflows such as resampling, blur-like effects, and rotation.
- Atlas and texture-preparation helpers are critical from a runtime perspective because many images become packed regions, sprite sources, UI textures, or render-ready assets rather than staying as isolated files.
- This makes the module a bridge between authored content and render consumption. `render` eventually uses the resulting textures, but `image` owns the CPU-side transformations that prepare and validate them.
- Comparison and diff-style helpers turn the module into a testing and evidence surface without making image the owner of cross-domain diagnostics.
- Image-only drawing and diagnostic output remain useful for debugging, but camera, audio, animation, UI, graph, and procedural domain diagnostics belong to their respective owners.
- Image data can be a source of gameplay structure, but `image` owns the pixel-domain side of that pipeline. Province-specific id extraction, topology, spans, and polygons are owned by `province`.
- That two-way relationship is important: `image` is useful both after a visual asset exists and when visual data is being used as input to another system.
- Serialization and format conversion keep the module connected to the outside world. The same subsystem can move between files, generated runtime state, debugging artifacts, and exported outputs without pushing those conversions into ad hoc helpers.
- That flexibility also makes the module useful for tool-driven inspection as well as asset preparation.
- This makes the module useful across the whole asset lifecycle: load, inspect, transform, compare, pack, export, and sometimes reinterpret as data for another system.
- `render` consumes prepared results, but `image` owns pixel-domain manipulation, inspection, packing, and export before or outside final rendering.
- Read `image` as the engine's pixel-domain authority for asset prep and tooling.

This module primarily collaborates with `color`, `math`, `province`, `render`, and `runtime`. Its responsibility should stay inside the Platform Services group rather than absorb behavior owned by those neighbors.

## Ownership

- Canonical source: `src/image`
- Owning tier: `Platform Services`
- Plugin tier: `not_evaluated`
- Lua binding owner: `src/lua_api/image_api.rs`
- Referenced engine modules: `color`, `font`, `render`, `runtime`

## Imports

- `color`: Imports or references `src/color/`. Cross-group dependency from `Platform Services` into `Foundations`.
- `font`: Imports or references `src/font/`. Dependency stays inside `Platform Services` and should remain acyclic.
- `render`: Imports or references `src/render/`. Dependency stays inside `Platform Services` and should remain acyclic.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Platform Services` into `Core Runtime`.

## Source Files

### animated_gif.rs

- Owns the image animated gif implementation for the image subsystem and keeps related runtime rules local here.
- Keeps image data, encoded assets, and effect helpers ownership so helpers stay close to invariants this file updates.
- Defines how image animated gif data is validated, transformed, or stored before neighboring systems consume it.
- Separates image animated gif behavior from Lua bindings, tests, and sibling owners so integration stays readable.
- Documents the boundary where image code accepts inputs, reports errors, allocates state, or emits outputs.
- Use this file when changing image animated gif defaults, lifecycle handling, validation, or data ownership rules.

### compressed.rs

- Provides bounded compatibility diagnostics for legacy DDS texture assets.
- This runtime deliberately has no DDS decode/upload path: PNG-backed `ImageData` is the
- supported image interchange format. The types below remain only so callers can recognize a
- DDS magic header and receive a clear migration error. They never expose a usable compressed
- texture or grant Lua code direct filesystem authority.

### effects.rs

- Owns the image effects implementation for the image subsystem and keeps related runtime rules local here.
- Keeps image data, encoded assets, and effect helpers ownership so helpers stay close to invariants this file updates.
- Defines how image effects data is validated, transformed, or stored before neighboring systems consume it.
- Separates image effects behavior from Lua bindings, tests, and sibling owners so integration stays readable.
- Documents the boundary where image code accepts inputs, reports errors, allocates state, or emits outputs.
- Use this file when changing image effects defaults, lifecycle handling, validation, or data ownership rules.
- Keeps failure paths and edge cases near the image effects state that explains them instead of spreading rules outward.
- Preserves deterministic behavior by keeping image effects calculations explicit at their owning subsystem boundary.
- Provides the local adaptation layer that lets callers reuse image effects rules without duplicating engine decisions.
- Open this owner before sibling files when a regression centers on image effects state, helpers, or integration rules.
- Works with neighboring image owners while keeping the main image effects responsibility anchored in one file.

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

### limits.rs

- Defines the resource ceilings shared by CPU image allocation, codecs, and pixel-domain work.
- Lua-facing image operations always use these conservative defaults; tools may supply explicit limits.

### mod.rs

- Exports the image subsystem surface for CPU bitmaps, effects, formats, layers, palettes, and visual helpers.
- Acts as the navigation index for single-bitmap ownership, showing where loading, editing, and specs live.
- Re-exports `ImageData`, compressed assets, palette LUTs, layered images, GIF helpers, and compatibility types.
- Keeps atlas, nine-slice, and sprite-sheet concepts outside image so sprite remains the texture-region owner.
- Open this file when tracing which image feature belongs to storage, processing, serialization, or UI support.
- This index owns image visibility and composition, not the pixel algorithms implemented in child modules.

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



## Lua API Ref

### Functions

- `lurek.image.fromScreen() -> LImageData|nil`: Returns a completed screen capture image or requests one for a future call.
- `lurek.image.isCompressed(filename) -> boolean`: Returns whether a GameFS image file begins with DDS compressed image magic bytes.
- `lurek.image.loadAnimated(source) -> LAnimatedImage`: Loads an animated GIF from GameFS path or decodes animated GIF bytes.
- `lurek.image.loadImage(filename) -> LImageData`: Loads and decodes image data from GameFS.
- `lurek.image.loadLayered(filename) -> LLayeredImage`: Loads a serialized layered image stack from GameFS.
- `lurek.image.newCompressedData(filename) -> LCompressedImageData`: Attempts to load DDS compressed image data from GameFS.
- `lurek.image.newImageData(width_or_filename, height?) -> LImageData`: Creates empty image data from dimensions or decodes image data from a GameFS filename.
- `lurek.image.newImageDataFromBytes(w, h, bytes) -> LImageData`: Creates image data from raw RGBA bytes and explicit dimensions.
- `lurek.image.newLayeredImage(width, height) -> LLayeredImage`: Creates a layered image stack with one or more blank layers.
- `lurek.image.newPaletteLut() -> LPaletteLUT`: Creates an empty palette lookup table.
- `lurek.image.newProvinceGrid(filename) -> LProvinceGrid`: Loads a province id grid from an image file under the current game directory. This is a compatibility facade over the province subsystem.
- `lurek.image.requestShader(image, shader, opts?) -> LImageShaderJob`: Starts an offline image shader request and returns a completed job handle.
- `lurek.image.saveGIF(frames, filename, opts?) -> nil`: Encodes a sequence of equally sized image frames as an animated GIF.
- `lurek.image.saveImage(img_ud, filename) -> nil`: Saves an image data object to a path under the current game directory.
- `lurek.image.savePNG(img_ud, filename) -> nil`: Encodes image data as PNG and writes it under the current game directory.

### Callbacks

- `LImageData:mapPixel` param `func` (`function`): Callback receiving `(x, y, r, g, b, a)` and returning replacement channels.
- `LImageData:mapPixels` param `func` (`function`): Callback receiving `(x, y, r, g, b, a)` and returning replacement channels.

### Enums

- No documented module-level enums/constants.

### Types

#### LAnimatedImage Type

- Lua-side decoded animated image containing frame images and durations.

##### Fields

- No documented fields.

##### Methods

- `LAnimatedImage:frameCount() -> integer`: Returns the number of decoded frames.
- `LAnimatedImage:getDuration(index) -> integer`: Returns a frame duration in milliseconds by one-based index.
- `LAnimatedImage:getDurations() -> table`: Returns all frame durations in milliseconds.
- `LAnimatedImage:getFrame(index) -> LImageData`: Returns a decoded frame by one-based index.
- `LAnimatedImage:getFrames() -> table`: Returns all decoded frame images as an array.
- `LAnimatedImage:type() -> string`: Returns the Lua-visible type name.
- `LAnimatedImage:typeOf(name) -> boolean`: Returns whether this handle matches a supported type name.

#### LCompressedImageData Type

- Lua-side handle for legacy compressed DDS metadata.

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
- `LImageData:applyEffect(name, opts?) -> LImageData|nil`: Applies a named image effect in place, or returns a new image when the effect changes size.
- `LImageData:applyEffects(effects, opts?) -> LImageData|nil`: Applies a sequence of named effects in order.
- `LImageData:applyMask(mask) -> nil`: Multiplies this image alpha by another image's alpha channel.
- `LImageData:applyPaletteLut(lut_ud) -> nil`: Applies a palette lookup table to this image in place.
- `LImageData:applyShader(shader, opts?) -> LImageData`: Applies an offline image shader and returns the processed image.
- `LImageData:blit(src_ud, dst_x, dst_y) -> nil`: Copies a source image into this image at a destination coordinate.
- `LImageData:blur(radius) -> LImageData`: Returns a blurred copy of this image.
- `LImageData:brightness(factor) -> nil`: Applies a brightness factor to this image in place.
- `LImageData:clone() -> LImageData`: Returns a deep copy of this image data.
- `LImageData:contrast(factor) -> nil`: Applies a contrast factor to this image in place.
- `LImageData:convolve(kernel_t, ksize) -> LImageData`: Applies a convolution kernel and returns the filtered image.
- `LImageData:copyRegion(x, y, w, h) -> LImageData`: Copies a rectangular region into a new image.
- `LImageData:crop(x, y, w, h) -> LImageData`: Returns a cropped image region. This method is available to Lua scripts.
- `LImageData:diff(other_ud) -> number`: Computes a difference metric against another image.
- `LImageData:drawCircle(cx, cy, radius, r, g, b, a) -> nil`: Draws a filled circle into this image.
- `LImageData:drawLine(x0, y0, x1, y1, r, g, b, a) -> nil`: Draws a line into this image. This method is available to Lua scripts.
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
- `LImageData:transform(opts?) -> LImageData`: Returns a transformed image, currently supporting high-quality resize through `width`, `height`, and `filter`.
- `LImageData:type() -> string`: Returns the Lua-visible type name for this image data handle.
- `LImageData:typeOf(name) -> boolean`: Returns whether this image data handle matches the `LImageData` type name.

#### LImageShaderJob Type

- Lua handle for an offline image shader request.

##### Fields

- No documented fields.

##### Methods

- `LImageShaderJob:cancel() -> nil`: Cancels this pending offline image shader job.
- `LImageShaderJob:poll() -> LImageData`: Returns the shader output image when the job has completed, or nil if pending/cancelled.
- `LImageShaderJob:wait(timeoutMs?) -> LImageData`: Waits for the offline image shader job and returns its output image.

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

- Lua-side compatibility handle for a province id grid decoded by the province subsystem.

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

## Examples

- `content/examples/image.lua` (present)

## Architecture Links

- Intentionally empty.

## Notes

- `lurek.province.newGrid` is the canonical GameFS-backed constructor for province id grids. `lurek.image.newProvinceGrid` remains a compatibility facade for image-origin content and delegates to the same bounded province adapter; migrate new code to `lurek.province.newGrid`.
- Lua image construction, codecs, callbacks, frames, layers, and byte exports use `ImageLimits`; oversized dimensions, encoded input, decompression output, aggregate state, or pixel work fail before allocation or iteration.
- Lua save operations encode bounded bytes and write through GameFS atomically. Normal output is restricted to `save/`; the engine's approved `tests/artifacts/current/` evidence root is available to test runs through the same checked atomic writer. Host paths, traversal, and direct filesystem writes are not image responsibilities.
- Callback pixel mapping is transactional: if a callback fails, the original image remains unchanged. Image bytes are straight RGBA; callers own any color-space or premultiplied-alpha conversion policy.
- DDS compressed texture decode is intentionally not part of this runtime build. `isCompressed` can still detect DDS headers for migration/diagnostics, but game textures should load through PNG-backed `newImageData`. Legacy DDS diagnostics enforce the same encoded-byte ceiling before reading or returning the unsupported-format error.
- `ImageData:applyShader` and `lurek.image.requestShader` accept `target = "image"` WGSL shaders and run an off-screen render-owned GPU pass that reads RGBA8 pixels back into `ImageData`.
