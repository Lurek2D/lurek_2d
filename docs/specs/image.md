# image

## TL;DR

- The `image` module is the engine's CPU image workspace for loading, editing, layering, packing, and exporting pixel data used by runtime and tools.

## General Info

- Module group: `Platform Services`
- Source path: `src/image/`
- Binding: `src/lua_api/image_api.rs`
- Namespace: `lurek.image`
- Lua API surface: `12` functions, `10` types, `90` methods
- Rust test path(s): tests/rust/unit/image_tests.rs, tests/rust/stress/image_stress_tests.rs
- Lua test path(s): tests/lua/unit/test_image_core_unit.lua, tests/lua/unit/test_image.lua, tests/lua/unit/test_image_effect.lua, tests/lua/unit/test_render_core_unit.lua, tests/lua/stress/test_image_stress.lua, tests/lua/evidence/test_evidence_image_drawing.lua, tests/lua/evidence/test_evidence_imagedata.lua, tests/lua/evidence/test_evidence_image_effects.lua, tests/lua/evidence/test_evidence_imagedata_effects.lua

## Summary

The `image` module is the engine's CPU-side image workspace. It gives one stable model for mutable RGBA buffers and one consistent API for loading files, creating buffers, applying edits, and exporting results.

Its day-to-day value is workflow coverage. Teams can resize, crop, rotate, flip, draw primitives, blit regions, compare outputs, and serialize images without jumping between unrelated helper modules.

Color and filter operations are integrated into the same surface. Brightness, contrast, saturation, gamma, tinting, thresholding, blurs, and kernel-based passes can be chained in predictable ways for runtime effects and tooling pipelines.

Layered composition support enables non-destructive image authoring at runtime. Layers can be stacked, reordered, hidden, renamed, and merged with explicit opacity and blend behavior, which is practical for editor features and generated UI assets.

Asset pipeline features are included, not externalized. Standard format decode and encode paths, compressed texture handling, and atlas packing allow content to move from source files to render-ready forms through one module boundary.

The module also supports data-oriented uses of imagery. Region extraction, palette remapping, and visualization helpers let image buffers act as structured inputs for map workflows, diagnostics, and evidence output, not only as final on-screen pictures.

Because the behavior is deterministic and scriptable, the same operations can be reused for gameplay content, CI validation, and developer tooling. In practice, `lurek.image` provides a complete pixel-data contract: ingest, transform, compose, package, and export image state with predictable results.

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

- Bridges CPU `ImageData` content into render-command payloads consumed by the draw pipeline.
- Provides lightweight conversion helpers that reference texture keys and screen placement.
- Includes image snapshot utilities used where value-copy semantics are required.

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

- `lurek.image.fromScreen`: Returns a completed screen capture image or requests one for a future call.
- `lurek.image.isCompressed`: Returns whether a GameFS image file begins with DDS compressed image magic bytes.
- `lurek.image.loadImage`: Loads and decodes image data from GameFS.
- `lurek.image.loadLayered`: Loads a serialized layered image stack from GameFS.
- `lurek.image.newCompressedData`: Loads DDS compressed image data from GameFS.
- `lurek.image.newImageData`: Creates empty image data from dimensions or decodes image data from a GameFS filename.
- `lurek.image.newImageDataFromBytes`: Creates image data from raw RGBA bytes and explicit dimensions.
- `lurek.image.newLayeredImage`: Creates a layered image stack with one or more blank layers.
- `lurek.image.newPaletteLut`: Creates an empty palette lookup table.
- `lurek.image.newProvinceGrid`: Loads a province id grid from an image file under the current game directory.
- `lurek.image.saveImage`: Saves an image data object to a path under the current game directory.
- `lurek.image.savePNG`: Encodes image data as PNG and writes it under the current game directory.

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

- `LCompressedImageData:getDimensions`: Returns compressed image dimensions.
- `LCompressedImageData:getFormat`: Returns the compressed image format name.
- `LCompressedImageData:getHeight`: Returns compressed image height. This method is available to Lua scripts.
- `LCompressedImageData:getMipmapCount`: Returns the number of mipmap levels in this compressed image.
- `LCompressedImageData:getWidth`: Returns compressed image width. This method is available to Lua scripts.
- `LCompressedImageData:type`: Returns the Lua-visible type name for this compressed image handle.
- `LCompressedImageData:typeOf`: Returns whether this compressed image handle matches a supported type name.

#### LImageData Type

- Provides Lua methods for reading, editing, filtering, drawing, and encoding image data.

##### Fields

- No documented fields.

##### Methods

- `LImageData:alphaMask`: Multiplies this image alpha channel by a factor in place.
- `LImageData:applyPaletteLut`: Applies a palette lookup table to this image in place.
- `LImageData:blit`: Copies a source image into this image at a destination coordinate.
- `LImageData:blur`: Returns a blurred copy of this image.
- `LImageData:brightness`: Applies a brightness factor to this image in place.
- `LImageData:contrast`: Applies a contrast factor to this image in place.
- `LImageData:convolve`: Applies a convolution kernel and returns the filtered image.
- `LImageData:crop`: Returns a cropped image region. This method is available to Lua scripts.
- `LImageData:diff`: Computes a difference metric against another image.
- `LImageData:drawCircle`: Draws a filled circle into this image.
- `LImageData:drawLine`: Draws a line into this image. This method is available to Lua scripts.
- `LImageData:drawNineSlice`: Draws a nine-slice region from a source image into this image.
- `LImageData:drawRect`: Draws a filled rectangle into this image.
- `LImageData:encode`: Encodes image data in a supported format.
- `LImageData:fill`: Fills the whole image with one RGBA color.
- `LImageData:flipHorizontal`: Flips this image horizontally in place.
- `LImageData:flipVertical`: Flips this image vertically in place.
- `LImageData:gamma`: Applies gamma correction to this image in place.
- `LImageData:getDimensions`: Returns image dimensions. This method is available to Lua scripts.
- `LImageData:getHeight`: Returns image height. This method is available to Lua scripts.
- `LImageData:getPixel`: Returns RGBA channels at a pixel coordinate.
- `LImageData:getRawBytes`: Returns raw image bytes as a Lua string.
- `LImageData:getRegion`: Returns an image region when the requested rectangle is inside bounds.
- `LImageData:getString`: Returns raw image bytes as a Lua string.
- `LImageData:getWidth`: Returns image width. This method is available to Lua scripts.
- `LImageData:grayscale`: Converts this image to grayscale in place.
- `LImageData:invert`: Inverts image color channels in place.
- `LImageData:mapPixel`: Applies a Lua callback to every pixel and replaces each pixel with returned RGBA values.
- `LImageData:mapPixels`: Applies a Lua callback to every pixel and replaces each pixel with returned RGBA values.
- `LImageData:noise`: Adds noise to this image in place. This method is available to Lua scripts.
- `LImageData:paste`: Pastes a source image into this image at unsigned destination coordinates.
- `LImageData:posterize`: Reduces image colors to a fixed number of levels in place.
- `LImageData:resize`: Returns a resized image using an optional named filter.
- `LImageData:resizeNearest`: Returns a resized image using nearest-neighbor sampling.
- `LImageData:rotate90cw`: Returns a new image rotated ninety degrees clockwise.
- `LImageData:saturation`: Applies a saturation factor to this image in place.
- `LImageData:sepia`: Applies a sepia filter to this image in place.
- `LImageData:setPixel`: Sets RGBA channels at a pixel coordinate.
- `LImageData:setRawData`: Replaces the image byte buffer with raw bytes.
- `LImageData:sharpen`: Returns a sharpened copy of this image.
- `LImageData:threshold`: Applies a threshold filter to this image in place.
- `LImageData:tint`: Blends this image toward a tint color in place.
- `LImageData:type`: Returns the Lua-visible type name for this image data handle.
- `LImageData:typeOf`: Returns whether this image data handle matches the `LImageData` type name.

#### LLayeredImage Type

- Lua-side handle for multiple image layers with visibility, opacity, and ordering.

##### Fields

- No documented fields.

##### Methods

- `LLayeredImage:addLayer`: Adds a blank layer with an optional name.
- `LLayeredImage:getHeight`: Returns the layered image height. This method is available to Lua scripts.
- `LLayeredImage:getLayer`: Returns image data for a layer by one-based index.
- `LLayeredImage:getName`: Returns a layer name by one-based index.
- `LLayeredImage:getOpacity`: Returns a layer opacity by one-based index.
- `LLayeredImage:getWidth`: Returns the layered image width. This method is available to Lua scripts.
- `LLayeredImage:isVisible`: Returns layer visibility by one-based index.
- `LLayeredImage:layerCount`: Returns the number of layers in the stack.
- `LLayeredImage:merge`: Merges visible layers into a single image data object.
- `LLayeredImage:moveLayer`: Moves a layer from one one-based index to another.
- `LLayeredImage:removeLayer`: Removes a layer by one-based index.
- `LLayeredImage:save`: Saves the layered image stack to a file.
- `LLayeredImage:setLayer`: Replaces a layer's image data by one-based index.
- `LLayeredImage:setName`: Sets a layer name by one-based index.
- `LLayeredImage:setOpacity`: Sets a layer opacity by one-based index.
- `LLayeredImage:setVisible`: Sets layer visibility by one-based index.
- `LLayeredImage:swapLayers`: Swaps two layers by one-based indices.
- `LLayeredImage:type`: Returns the Lua-visible type name for this layered image handle.
- `LLayeredImage:typeOf`: Returns whether this layered image handle matches a supported type name.

#### LPaletteLUT Type

- Lua-side handle for palette color remapping.

##### Fields

- No documented fields.

##### Methods

- `LPaletteLUT:clear`: Removes every color mapping from this palette lookup table.
- `LPaletteLUT:cycle`: Cycles palette mappings by an offset.
- `LPaletteLUT:getColorCount`: Returns the number of color mappings in this palette lookup table.
- `LPaletteLUT:setColor`: Adds a color mapping from source RGBA channels to destination RGBA channels.
- `LPaletteLUT:type`: Returns the Lua-visible type name for this palette lookup table handle.
- `LPaletteLUT:typeOf`: Returns whether this palette lookup table handle matches a supported type name.

#### LProvinceGrid Type

- Lua-side handle for a province id grid decoded from an image.

##### Fields

- No documented fields.

##### Methods

- `LProvinceGrid:adjacencies`: Returns province adjacency records and shared border pixel counts.
- `LProvinceGrid:borderSegments`: Returns border line segments between neighboring provinces.
- `LProvinceGrid:deserializeShapeData`: Decodes serialized province shape data into span and segment tables.
- `LProvinceGrid:drawShapes`: Queues filled polygon draw commands for province shapes, optionally culled to a viewport rect.
- `LProvinceGrid:getAt`: Returns the province id stored at grid coordinates.
- `LProvinceGrid:getHeight`: Returns the province grid height. This method is available to Lua scripts.
- `LProvinceGrid:getPolygons`: Returns polygon rings for every province.
- `LProvinceGrid:getPolygonsSimplified`: Returns simplified polygon rings for every province.
- `LProvinceGrid:getWidth`: Returns the province grid width. This method is available to Lua scripts.
- `LProvinceGrid:provinceCount`: Returns the number of distinct provinces in the grid.
- `LProvinceGrid:provinceSpans`: Returns horizontal province spans by row.
- `LProvinceGrid:serializeShapeData`: Serializes province span and border shape data into a binary Lua string.
- `LProvinceGrid:type`: Returns the Lua-visible type name for this province grid handle.
- `LProvinceGrid:typeOf`: Returns whether this province grid handle matches a supported type name.

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
