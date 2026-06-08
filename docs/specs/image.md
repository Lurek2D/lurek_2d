# image

## TL;DR

- Manages CPU image buffers, compressed textures, layered stacks, palette remapping, and atlases.
- Supports pixel-level effects, nine-slices, province grids, and graphical debug visualizations.

## General Info

- Module group: `Platform Services`
- Source path: `src/image/`
- Binding: `src/lua_api/image_api.rs`
- Namespace: `lurek.image`
- Lua API surface: `12` functions, `10` types, `90` methods
- Rust test path(s): tests/rust/unit/image_tests.rs, tests/rust/stress/image_stress_tests.rs
- Lua test path(s): tests/lua/unit/test_image_core_unit.lua, tests/lua/unit/test_image.lua, tests/lua/unit/test_image_effect.lua, tests/lua/unit/test_render_core_unit.lua, tests/lua/stress/test_image_stress.lua, tests/lua/evidence/test_evidence_image_drawing.lua, tests/lua/evidence/test_evidence_imagedata.lua, tests/lua/evidence/test_evidence_image_effects.lua, tests/lua/evidence/test_evidence_imagedata_effects.lua

## Summary

- This module gives users a full CPU-side image pipeline for loading, editing, analyzing, and exporting pixel data.
- It supports mutable RGBA buffers for per-pixel operations used by tooling and gameplay systems.
- Compressed texture decode support helps validate and prepare assets before GPU upload.
- Color and tone effects cover common grading workflows such as brightness, contrast, saturation, and gamma adjustments.
- Filter operations like blur, sharpen, and custom kernels support image enhancement and stylization tasks.
- Geometric transforms include crop, flip, rotate, and resize for practical content preparation.
- Composition helpers support alpha blits and nine-slice workflows useful for UI asset assembly.
- Layer stacks enable non-destructive edits with visibility and opacity control.
- Palette remap utilities support theme variants and palette-cycling style effects.
- Atlas packing tools help fit many sprites into efficient texture sheets.
- Serialization paths support image persistence and reproducible content pipelines.
- Difference and compare helpers are useful for screenshot regression tests.
- Diagnostic visualization utilities convert runtime data into inspectable images.
- Built-in visualizers cover domains like audio, camera, easing, noise, and graph-style debug output.
- Province/grid extraction features bridge image-authored maps into gameplay topology data.
- This is useful for strategy and territory workflows where art and logic must stay aligned.
- The module supports both quick script prototypes and larger toolchain-style operations.
- It reduces dependence on external image preprocessors for many common tasks.
- For users, this means faster iteration on assets and better observability of visual data.
- It also keeps processing deterministic, which helps testing and CI reproducibility.
- The practical value is one consistent image API across content prep, runtime effects, and debug tooling.
- Teams can share reusable image workflows instead of duplicating custom utility scripts.
- Overall, users get a broad image toolkit that integrates naturally with engine rendering flows.
- It turns pixel manipulation into a first-class runtime capability rather than a side utility.
- This supports advanced content pipelines without leaving the project environment.
- It also helps close the loop between visual design intent and runtime verification.
- In short, the module is the engine's central surface for script-driven image operations.
- That makes it foundational for UI, VFX prep, map pipelines, and visual diagnostics.

## Imports

- `animation`: Imports or references `animation` from `src/animation/`.
- `camera`: Imports or references `camera` from `src/camera/`.
- `color`: Imports or references `src/color/`. Cross-group dependency from `Platform Services` into `Edge/Integration`.
- `math`: Imports or references `math` from `src/math/`.
- `province`: Imports or references `src/province/`. Cross-group dependency from `Platform Services` into `Edge/Integration`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### compressed.rs

- Decodes DDS-style compressed textures into structured payloads used by higher-level image loading.
- Validates headers and extracts dimensions, mip blocks, and metadata needed for downstream upload.
- Detects desktop and mobile block-compression families from DXGI and legacy format descriptors.
- Exposes file and byte entry points so callers can probe and decode assets from multiple pipelines.
- Returns stable data carriers containing format tags and raw compressed mip chains.

### effects.rs

- Provides the main CPU image effect toolkit for color grading, filtering, resampling, and compositing.
- Applies brightness, contrast, saturation, gamma, tint, threshold, and stylization transforms per pixel.
- Supports deterministic noise injection and alpha-aware operations for repeatable visual post-processing.
- Implements geometric edits like crop, flip, and rotation for texture preparation and UI workflows.
- Includes nearest, bilinear, and Lanczos resize paths to balance speed and quality by caller choice.
- Runs blur, sharpen, and generic kernel convolution with safe boundary handling on edge samples.
- Offers alpha-blended blit and nine-slice stretching for practical sprite and panel assembly tasks.
- Computes byte-level difference scores for test assertions and regression image comparisons.
- Normalizes effect behavior around mutable `ImageData` buffers without hidden global state.
- Exposes filter-selection enums parsed from textual inputs used at scripting boundaries.

### image_data.rs

- Defines the central mutable RGBA buffer used across rendering, tooling, and image-side gameplay logic.
- Creates images from dimensions, files, encoded bytes, or direct raw pixel payloads.
- Provides pixel access, region copy, and whole-buffer transform flows in serial and parallel variants.
- Implements primitive raster drawing for lines, rectangles, circles, labels, and debug overlays.
- Supports blending and paste semantics that keep alpha composition behavior explicit and predictable.
- Carries width, height, and packed bytes in a compact row-major memory representation.
- Encodes images back to portable formats for persistence, export, and diagnostics.
- Includes comparison and utility helpers used by tests and content validation steps.
- Serves as the common interchange type between image operations and render-facing code paths.
- Keeps all mutation local to the instance to avoid hidden shared-state side effects.

### layers.rs

- Implements layered image editing with per-layer visibility, opacity, naming, and pixel ownership.
- Maintains ordered stacks so compositing results stay deterministic during insert and reorder actions.
- Supports add, remove, rename, swap, and move operations for non-destructive content workflows.
- Merges the stack into flat output using alpha-over compositing compatible with engine image buffers.
- Provides practical layer primitives for editors, tooling pipelines, and scripted content generation.

### mod.rs

- High-level image module that unifies pixel buffers, effects, serialization, and atlas-oriented helpers.
- Re-exports core image types and decoding utilities used across runtime systems and content pipelines.
- Defines the integration boundary between CPU image manipulation and render-upload preparation.

### palette_lut.rs

- Provides palette lookup remapping that transforms source colors into target colors across images.
- Stores parallel source and destination palettes to express deterministic recolor tables.
- Applies in-place remap passes optimized by direct scan or hash-assisted lookup by palette size.
- Supports rotation-style remap workflows for palette cycling and stylized animation effects.
- Supplies reusable color-map primitives for procedural art and runtime theme variation.

### rect_packing.rs

- Implements shelf-based rectangle packing used to place sprites into compact atlas layouts.
- Accepts caller-defined atlas bounds and padding to preserve sampling safety between regions.
- Places rectangles in insertion order while tracking shelf growth and remaining horizontal space.
- Returns deterministic packed coordinates that map back to source asset identities.
- Reports occupancy metrics useful for tuning atlas size and packing efficiency.

### render.rs

- Thin bridge layer converting ImageData buffers into render command payloads that reference texture resources and screen placement coordinates.
- Generates DrawImage commands containing texture key, position, and optional effects for pipeline consumption without copying pixel data.
- Provides snapshot utility creating standalone ImageData clones where value semantics are required by higher-level drawing systems.

### serial.rs

- Implements LIMG binary serialization for flat and layered images with versioned format guards.
- Encodes and decodes pixel payloads with compression to reduce storage and transfer overhead.
- Validates magic headers, version bytes, and payload type tags before accepting input data.
- Preserves layer metadata such as names, opacity, and visibility across save-load round trips.
- Exposes both in-memory byte APIs and filesystem helpers for flexible integration contexts.
- Keeps format handling deterministic so tooling and runtime produce consistent binary artifacts.

### texture.rs

- Manages CPU texture ingestion and staging before GPU-side renderer upload and sampling.
- Decodes files and raw buffers into validated RGBA payloads keyed in slot-map storage.
- Applies premultiplied-alpha conversion paths to align blending behavior with render expectations.
- Tracks texture color-space intent so pipelines can distinguish sRGB and linear content.
- Supplies safe construction and validation helpers used by asset loading and runtime creation flows.

### texture_atlas.rs

- Builds and maintains texture atlases that group many named regions inside one packed image.
- Uses shelf-style placement to allocate rectangles while preserving padding and bounds guarantees.
- Attaches optional nine-slice inset metadata so UI sprites can scale without corner distortion.
- Supports name-based lookup, mutation, and reset operations for dynamic atlas management.
- Exposes region geometry and atlas dimensions needed by render and layout call sites.

### visualization/animation.rs

- Renders animation timelines and frame grids into debug images for rapid visual inspection.
- Highlights current playback position against surrounding frames to expose timing behavior.
- Draws state-oriented overlays for running, paused, and resumed playback diagnostics.
- Provides quick wrappers with sensible cell sizing for tool and test screenshot generation.
- Uses consistent color accents so active and inactive frame regions are instantly readable.

### visualization/audio.rs

- Converts audio sample streams into waveform images suitable for tooling and in-engine diagnostics.
- Renders mono and stereo views with channel separation and baseline guides for quick interpretation.
- Supports zoom-oriented sampling views to inspect transient detail in dense signal regions.
- Adds labels and configurable color accents so waveform panels fit different UI styles.
- Normalizes peak ranges to keep amplitude visualization stable across varying source loudness.
- Shares column-based raster logic to keep waveform output deterministic and lightweight.

### visualization/camera.rs

- Produces camera-debug imagery that visualizes framing, motion, and transform behavior in world space.
- Draws viewport boxes, crosshairs, and coordinate guides for position and anchor verification.
- Compares multiple zoom factors to reveal scale-dependent composition and clipping effects.
- Renders rotation-aware grids that expose world-to-screen mapping under angular transforms.
- Displays bounds and follow trails to inspect dead-zone tuning and target-tracking responses.
- Visualizes shake offsets against center references for temporal stability checks.
- Provides wrapper entry points for fast full-panel generation in tests and tooling flows.
- Uses hue-based color differentiation to keep layered debug signals visually distinct.

### visualization/easing.rs

- Renders easing and curve diagnostics as image charts for motion-tuning and teaching workflows.
- Produces labeled curve galleries arranged in grids for side-by-side behavior comparison.
- Draws overlay traces that contrast multiple easing functions on shared coordinate axes.
- Includes Bezier-focused views with control-point and segment cues for shape inspection.
- Supplies advanced Bezier visualization for derivative and edit-oriented debugging scenarios.
- Uses chart backgrounds and guides that preserve readability across dense trace overlays.

### visualization/facade.rs

- Provides shared visualization color conversion from HSV space into RGB byte tuples.
- Centralizes hue-driven palette logic used by charts, graphs, and debug overlays.
- Keeps color mapping behavior consistent across all image visualization submodules.

### visualization/geometry.rs

- Generates geometry-focused debug images that visualize shape algorithms and spatial relationships.
- Renders polygon galleries, primitive fills, and line rasterization examples for correctness checks.
- Shows convex hull and centroid style outputs to inspect geometric post-processing behavior.
- Illustrates intersection outcomes between segments, circles, and lines with clear overlays.
- Draws spiral and ring patterns to stress sampling consistency and color-mapping utilities.
- Provides rich visual evidence for math and geometry routines used by higher-level systems.

### visualization/graph.rs

- Renders graph structures into diagnostic images with nodes, edges, labels, and status overlays.
- Visualizes active and removed connections using distinct styling for topology change analysis.
- Supports item-flow style arrows and annotation text for simulation and logic debugging.
- Places titles and stats summaries to contextualize rendered graph snapshots.
- Uses circle-node layouts and adjacency-driven links for readable relationship visualization.

### visualization/image_ops.rs

- Composes side-by-side image operation previews for fast visual comparison of processing outputs.
- Builds slot-based layouts with scaling and padding so varied source sizes stay presentable.
- Labels each panel to make transform deltas clear during review and regression analysis.
- Includes color-wheel and transform showcase helpers for broad image-operation demonstrations.
- Keeps composite rendering deterministic for repeatable screenshot-based validation.

### visualization/mod.rs

- High-level visualization module wiring that groups image-debug renderers by domain.
- Re-exports category entry points to provide one flat surface for visualization consumers.
- Shares internal facade utilities while keeping submodule responsibilities clearly separated.

### visualization/noise.rs

- Turns scalar noise functions into image outputs for terrain tuning and generator diagnostics.
- Renders normalized and raw grayscale maps to compare contrast handling across noise sources.
- Provides biome and elevation band coloring to inspect threshold-driven terrain classification.
- Supports sliced and tiled comparison views for spotting artifacts across parameter variations.
- Keeps sampling and raster paths deterministic for stable test and documentation visuals.

### visualization/procgen.rs

- Visualizes procedural-generation data structures as images for analysis and tuning loops.
- Renders cellular grids, dungeon maps, and occupancy states with configurable color semantics.
- Draws Voronoi and Delaunay style outputs to inspect spatial partition behavior.
- Displays point samples and topology overlays for algorithm-step debugging.
- Provides compact visual proof artifacts for procgen experimentation and regression checks.

### visualization/ui.rs

- Renders UI-oriented mockups into images to preview panel composition and widget styling.
- Draws settings-style panels with controls, sliders, and button affordances for layout checks.
- Produces HUD bars and cooldown visuals used to validate gameplay HUD readability.
- Includes swatches and progress widgets for color and status presentation experiments.
- Supplies deterministic UI snapshots useful in examples, tests, and design iteration loops.

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
