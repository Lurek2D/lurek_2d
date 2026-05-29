# image

## TL;DR

- The `image` module is an extensive Platform Services tier component responsible for CPU-side pixel buffer operations, providing a robust suite of tools for loading, manipulating, and exporting image data.

## General Info

- Module group: `Platform Services`
- Source path: `src/image/`
- Lua API path(s): `src/lua_api/image_api.rs`
- Primary Lua namespace: `lurek.image`
- Rust test path(s): tests/rust/unit/image_tests.rs, tests/rust/stress/image_stress_tests.rs
- Lua test path(s): tests/lua/unit/test_image_core_unit.lua, tests/lua/unit/test_image.lua, tests/lua/unit/test_image_effect.lua, tests/lua/unit/test_render_core_unit.lua, tests/lua/stress/test_image_stress.lua, tests/lua/evidence/test_evidence_image_drawing.lua, tests/lua/evidence/test_evidence_imagedata.lua, tests/lua/evidence/test_evidence_image_effects.lua, tests/lua/evidence/test_evidence_imagedata_effects.lua

## Summary

The foundational type is `ImageData`, which manages raw RGBA8 pixel buffers along with their dimensions. It supports a wide array of image processing operations including filling, nearest-neighbor and bilinear resizing, flipping, rotation, cropping, and primitive drawing (lines, circles, rectangles, and compact bitmap text). Crucially, it provides a comprehensive set of pixel-level effects—such as brightness, contrast, saturation, gamma correction, tinting, grayscale, sepia, inversion, thresholding, and separable box blurs—many of which are highly optimized using parallel processing (Rayon) for large images.

Beyond flat buffers, the module implements a sophisticated `LayeredImage` system. This allows developers to construct complex images from ordered stacks of `ImageLayer`s, featuring adjustable opacity, visibility flags, and support for Porter-Duff alpha blending to merge the final composite. For asset management, the module decodes compressed texture formats (DDS BC1–BC7) and supports standard image encoding/decoding (PNG, QOI, BMP). It also includes a `TextureAtlas` packer that combines multiple sprites into a single large texture using a shelf-based bin-packing algorithm, complete with nine-slice inset metadata for scalable UI components.

The `image` module features specialized systems for game development, most notably the `ProvinceGrid`. This system performs high-speed flood-fill analysis on color-coded PNG maps to generate optimized spatial indexes, identifying distinct provinces, calculating adjacencies, tracing polygonal borders, and exporting compressed shape data for Geoscape-style games. Additionally, `PaletteLUT` provides hardware-accelerated color remapping for retro palette-swapping effects. The module also contains an extensive set of debug visualization renderers for animation, audio, camera bounds, easing curves, and procedural generation (Voronoi, noise, cellular automata). The entire API, including CPU-to-GPU texture upload helpers, is fully exposed to Lua via the `lurek.image.*` namespace.

## Files

### compressed.rs

- DDS compressed-texture parsing: header validation, mipmap extraction, format detection.
- Recognized block-compression families: BC1–BC7 (desktop) and ETC1/ETC2 (mobile).
- Dual detection path: DXGI format field for DX10+ files, D3DFormat for legacy DDS.
- File-level helpers for magic-byte checks and full-file decode via GameFS or std I/O.
- Data carrier (`CompressedImageData`) holding dimensions, format tag, and raw mip payloads.

### effects.rs

- Pixel-level color adjustments: brightness, contrast, saturation, gamma, tint, grayscale, sepia, invert, threshold, and posterize applied via parallel pixel mapping.
- Alpha channel masking and deterministic per-pixel noise injection with repeatable seed.
- Geometric transforms: horizontal and vertical flip, 90-degree clockwise rotation, and rectangular crop with bounds validation.
- Resize operations using nearest-neighbor sampling, bilinear interpolation, and Lanczos3 windowed-sinc filtering.
- Separable box blur with configurable radius and 3x3 unsharp-mask sharpening kernel.
- General-purpose NxN kernel convolution with clamped-edge boundary handling and validation of odd kernel dimensions.
- Compositing via alpha-blended blit with fast-path for fully opaque sources and nine-slice stretch drawing.
- Bytewise image difference scoring across same-sized and differently-sized images for test comparison.
- `ResizeFilter` enum for selecting resampling kernels via string parsing at the Lua boundary.

### image_data.rs

- Mutable RGBA pixel buffer for creation, loading, and manipulation of 2D images.
- Constructors from file path, encoded memory bytes, or raw RGBA byte vectors.
- Per-pixel read/write, paste composition, and bulk map transforms (serial and parallel).
- Primitive drawing: filled rectangles, circles, Bresenham lines, and bitmap text labels.
- PNG encoding for serialization and export.

### layers.rs

- Named image layers with opacity, visibility, and RGBA pixel data.
- Layered image stack that composites layers front-to-back with alpha blending.
- Layer manipulation: add, remove, reorder, swap, rename, set opacity/visibility.
- Final merge produces a single `ImageData` using standard Porter-Duff over compositing.

### mod.rs

- RGBA image storage, pixel manipulation, and CPU-side drawing helpers.
- Compressed format decoding (PNG, QOI, BMP, TGA, WebP) and texture upload.
- Layered compositing, palette remapping, and image-space effects.
- Texture atlas packing, nine-slice metadata, and province-grid extraction.

### palette_lut.rs

- Source-to-target color remapping via indexed palette lookup tables.
- Hash-accelerated pixel matching for large palettes, linear scan for small ones.
- In-place image rewrite and cyclic rotation of replacement colors.

### rect_packing.rs

- Shelf-first rectangle packing for texture atlas layout.
- Configurable atlas dimensions and uniform pixel padding between rects.
- Tracks occupancy ratio and returns placement coordinates in insertion order.

### render.rs

- Convert an image buffer into GPU render commands for on-screen display.
- Provide cloning helpers to snapshot pixel data as standalone values.
- Bridge between ImageData and the engine's RenderCommand pipeline.

### serial.rs

- Serialize and deserialize flat and layered images in the LIMG binary format.
- Provide zlib compression and decompression for pixel payloads.
- Validate headers, version tags, and type flags on load.
- Encode layer metadata (name, opacity, visibility) alongside pixel data.
- Expose both file-path and raw-byte entry points for flexible I/O.

### texture.rs

- CPU-side texture loading, decoding, and storage into the SlotMap pool.
- Premultiplied-alpha conversion for correct blending on the GPU.
- Color-space tagging (sRGB vs linear) carried alongside pixel data.
- Construction from file paths or raw RGBA byte buffers.
- Dimension validation for caller-supplied pixel buffers.

### texture_atlas.rs

- Shelf-based rectangle packing for combining multiple images into a single atlas texture.
- Nine-slice inset metadata attached per region for scalable UI sprites.
- Name-keyed region lookup, clearing, and dimension queries.

### visualization/animation.rs

- Frame grid rendering for animation debug overlays.
- Playback timeline preview with active frame highlighting.
- Playback control state visualization with run, idle, pause, and resume.
- Default cell-dimension wrapper for quick animation preview.
- Color-coded frame indicators for current vs inactive frames.

### visualization/audio.rs

- Mono waveform preview with axis grid and peak normalization.
- Stereo waveform rendering with channel separation.
- Zoomed waveform with interpolated sample detail.
- Labeled waveform strip with custom color mapping.
- Shared peak normalization and column-based rendering.

### visualization/camera.rs

- Camera debug overlay with viewport rectangle and position crosshair.
- Zoom level comparison panel across multiple scale factors.
- Rotation preview grid with world-to-screen coordinate transforms.
- Camera bounds display with labeled position list.
- Follow and dead-zone trail visualization.
- Shake displacement trail with center and moved-position markers.
- Full-size camera debug wrapper for quick usage.
- HSV color helpers for hue-based visual differentiation.

### visualization/easing.rs

- Easing curve gallery rendered in a labeled grid layout.
- Overlaid easing comparison chart with colored traces.
- Bézier curve rendering with control-point markers.
- Advanced Bézier demo with derivatives, segments, and edit operations.
- Grid background and axis rendering for chart context.

### visualization/facade.rs

- HSV to RGB conversion for visualization color mapping.
- Hue-based palette generation for chart and graph elements.
- Shared color utility used across all visualization submodules.

### visualization/geometry.rs

- Polygon gallery with regular shapes of varying side counts.
- Archimedes spiral rendering with HSV ring colors.
- Filled primitive samples: rectangles, circles, brightness grid.
- Convex hull computation and overlay drawing.
- Point-in-polygon, centroid, and area visualization.
- Bresenham line rasterization proof.
- Segment-segment and circle-line intersection tests.
- Circle-segment and line intersection proof rendering.

### visualization/graph.rs

- Node-edge graph rendering with labels and colored vertices.
- Removed-edge overlay with dimmed styling.
- Item-flow graph with directional arrows and node items.
- Stats text and title label placement.
- Circle node rendering with adjacency-list edges.

### visualization/image_ops.rs

- Side-by-side labeled image comparison composite.
- Pixel transform grid: original, inverted, grayscale, sepia columns.
- HSV color wheel rendering from angle and distance.
- Slot-based layout with automatic scaling and padding.
- Label placement beneath each comparison slot.

### visualization/mod.rs

- Submodule declarations for all visualization categories.
- Wildcard re-exports providing a flat public API.
- Shared facade helpers scoped to crate visibility.

### visualization/noise.rs

- Noise function rendering as scaled grayscale.
- Raw noise mapping without range normalization.
- Terrain biome coloring from noise elevation bands.
- Heightmap slice visualization with elevation gradient.
- Noise comparison strip with multiple tiles side by side.

### visualization/procgen.rs

- Cellular automata grid rendering with alive and dead colors.
- Voronoi region visualization from seed partitions.
- Point sample rendering as colored dots or circles.
- Dungeon grid display with wall and floor tile scaling.
- Delaunay triangulation overlay with triangle edges and vertices.

### visualization/ui.rs

- Settings panel layout with controls, sliders, and buttons.
- HUD bar rendering for health, mana, stamina, and XP.
- Skill cooldown arcs with radial fill indicators.
- Color swatch palette with selection highlight.
- Progress bars and percentage label formatting.

## Lua API Ref

- Binding: `src/lua_api/image_api.rs`
- Namespace: `lurek.image`

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

### Enums

- No documented module-level enums/constants.

### Types


#### LCompressedImageData Type


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

## References

- `animation`: Imports or references `animation` from `src/animation/`.
- `camera`: Imports or references `camera` from `src/camera/`.
- `color`: Imports or references `src/color/`. Cross-group dependency from `Platform Services` into `Edge/Integration`.
- `math`: Imports or references `math` from `src/math/`.
- `province`: Imports or references `src/province/`. Cross-group dependency from `Platform Services` into `Edge/Integration`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.
