# Image

## Summary

The foundational type is `ImageData`, which manages raw RGBA8 pixel buffers along with their dimensions. It supports a wide array of image processing operations including filling, nearest-neighbor and bilinear resizing, flipping, rotation, cropping, and primitive drawing (lines, circles, rectangles, and compact bitmap text). Crucially, it provides a comprehensive set of pixel-level effects—such as brightness, contrast, saturation, gamma correction, tinting, grayscale, sepia, inversion, thresholding, and separable box blurs—many of which are highly optimized using parallel processing (Rayon) for large images.

Beyond flat buffers, the module implements a sophisticated `LayeredImage` system. This allows developers to construct complex images from ordered stacks of `ImageLayer`s, featuring adjustable opacity, visibility flags, and support for Porter-Duff alpha blending to merge the final composite. For asset management, the module decodes compressed texture formats (DDS BC1–BC7) and supports standard image encoding/decoding (PNG, QOI, BMP). It also includes a `TextureAtlas` packer that combines multiple sprites into a single large texture using a shelf-based bin-packing algorithm, complete with nine-slice inset metadata for scalable UI components.

The `image` module features specialized systems for game development, most notably the `ProvinceGrid`. This system performs high-speed flood-fill analysis on color-coded PNG maps to generate optimized spatial indexes, identifying distinct provinces, calculating adjacencies, tracing polygonal borders, and exporting compressed shape data for Geoscape-style games. Additionally, `PaletteLUT` provides hardware-accelerated color remapping for retro palette-swapping effects. The module also contains an extensive set of debug visualization renderers for animation, audio, camera bounds, easing curves, and procedural generation (Voronoi, noise, cellular automata). The entire API, including CPU-to-GPU texture upload helpers, is fully exposed to Lua via the `lurek.image.*` namespace.

## Spec File Descriptions

_Poniższe opisy plików pochodzą bezpośrednio ze specyfikacji modułu (`docs/specs/<module>.md`)._

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

## Functions

### `lurek.image.fromScreen`

Returns a completed screen capture image or requests one for a future call.

```lua
lurek.image.fromScreen()
```

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata-handle) | nil | `[LImageData](#limagedata-handle)` when capture data is ready, or nil after requesting capture. |

**Example**

```lua
do
    local capture = lurek.image.fromScreen()
    local status = capture and (capture:getWidth() .. "x" .. capture:getHeight()) or "not ready yet"
    print("screen capture " .. status)
end
```

---

### `lurek.image.isCompressed`

Returns whether a GameFS image file begins with DDS compressed image magic bytes.

```lua
lurek.image.isCompressed(filename)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `filename` | string | GameFS path to inspect. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the file appears to be DDS compressed data. |

**Example**

```lua
do
    local dds = lurek.image.isCompressed("content/examples/assets/images/sample_normal.dds")
    print("is compressed = " .. tostring(dds))
end
```

---

### `lurek.image.loadImage`

Loads and decodes image data from GameFS.

```lua
lurek.image.loadImage(filename)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `filename` | string | GameFS path to an encoded image. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata-handle) | Loaded image data handle. |

**Example**

```lua
do
    local src = lurek.image.newImageData(8, 8)
    src:fill(255, 0, 0, 255)
    lurek.image.saveImage(src, "save/sample_image.limg")
    local img = lurek.image.loadImage("save/sample_image.limg")
    print("loaded image " .. img:getWidth() .. "x" .. img:getHeight())
end
```

---

### `lurek.image.loadLayered`

Loads a serialized layered image stack from GameFS.

```lua
lurek.image.loadLayered(filename)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `filename` | string | GameFS path to the layered image file. |

**Returns**

| Type | Description |
|------|-------------|
| [LLayeredImage](#llayeredimage-handle) | Loaded layered image handle. |

**Example**

```lua
do
    local layered = lurek.image.newLayeredImage(8, 8)
    layered:addLayer("base")
    layered:save("save/sample_layered.limg")
    local loaded = lurek.image.loadLayered("save/sample_layered.limg")
    print("loaded layered = " .. tostring(loaded ~= nil))
    print("loaded layers = " .. loaded:layerCount())
end
```

---

### `lurek.image.newCompressedData`

Loads DDS compressed image data from GameFS.

```lua
lurek.image.newCompressedData(filename)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `filename` | string | GameFS path to a DDS file. |

**Returns**

| Type | Description |
|------|-------------|
| [LCompressedImageData](#lcompressedimagedata-handle) | New compressed image data handle. |

**Example**

```lua
do
    local cdata = lurek.image.newCompressedData("content/examples/assets/images/sample_normal.dds")
    print("compressed " .. cdata:getWidth() .. "x" .. cdata:getHeight())
    print("format = " .. cdata:getFormat())
    print("mipmaps = " .. cdata:getMipmapCount())
end
```

---

### `lurek.image.newImageData`

Creates empty image data from dimensions or decodes image data from a GameFS filename.

```lua
lurek.image.newImageData(width_or_filename, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width_or_filename` | number|string | Width in pixels for a blank canvas, or a GameFS filename string to load from disk. |
| `height?` | number | Height in pixels; required when the first argument is a width integer. Omit when loading from filename. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata-handle) | New image data handle. |

**Example**

```lua
do
    local img = lurek.image.newImageData(128, 64)
    print("image " .. img:getWidth() .. "x" .. img:getHeight())
end
```

---

### `lurek.image.newImageDataFromBytes`

Creates image data from raw RGBA bytes and explicit dimensions.

```lua
lurek.image.newImageDataFromBytes(w, h, bytes)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Width in pixels. |
| `h` | number | Height in pixels. |
| `bytes` | string | Raw RGBA byte string. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata-handle) | New image data handle. |

**Example**

```lua
do
    local bytes = string.rep("\255\0\0\255", 4)
    local img = lurek.image.newImageDataFromBytes(2, 2, bytes)
    print("from bytes " .. img:getWidth() .. "x" .. img:getHeight())
end
```

---

### `lurek.image.newLayeredImage`

Creates a layered image stack with one or more blank layers.

```lua
lurek.image.newLayeredImage(width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Width in pixels. |
| `height` | number | Height in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| [LLayeredImage](#llayeredimage-handle) | New layered image handle. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(256, 256)
    print("layered " .. li:getWidth() .. "x" .. li:getHeight())
    print("layers = " .. li:layerCount())
end
```

---

### `lurek.image.newPaletteLut`

Creates an empty palette lookup table.

```lua
lurek.image.newPaletteLut()
```

**Returns**

| Type | Description |
|------|-------------|
| [LPaletteLUT](#lpalettelut-handle) | New palette lookup table handle. |

**Example**

```lua
do
    local lut = lurek.image.newPaletteLut()
    print("palette LUT colors = " .. lut:getColorCount())
end
```

---

### `lurek.image.newProvinceGrid`

Loads a province id grid from an image file under the current game directory.

```lua
lurek.image.newProvinceGrid(filename)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `filename` | string | Province map image filename relative to game directory. |

**Returns**

| Type | Description |
|------|-------------|
| [LProvinceGrid](#lprovincegrid-handle) | New province grid handle. |

**Example**

```lua
do
    local grid = lurek.image.newProvinceGrid("assets/textures/province_map.png")
    print("grid " .. grid:getWidth() .. "x" .. grid:getHeight())
    print("provinces = " .. grid:provinceCount())
end
```

---

### `lurek.image.saveImage`

Saves an image data object to a path under the current game directory.

```lua
lurek.image.saveImage(img_ud, filename)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `img_ud` | [LImageData](#limagedata-handle) | Image data handle to save. |
| `filename` | string | Output filename relative to game directory. |

**Example**

```lua
do
    local img = lurek.image.newImageData(32, 32)
    img:fill(255, 0, 0, 255)
    lurek.image.saveImage(img, "save/red_square.limg")
    print("saved image")
end
```

---

### `lurek.image.savePNG`

Encodes image data as PNG and writes it under the current game directory.

```lua
lurek.image.savePNG(img_ud, filename)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `img_ud` | [LImageData](#limagedata-handle) | Image data handle to encode. |
| `filename` | string | Output filename relative to game directory. |

**Example**

```lua
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(0, 255, 0, 255)
    lurek.image.savePNG(img, "save/green_square.png")
    print("saved PNG")
end
```

---

## Module Fields

*No module-level fields documented.*

## Types

- [LCompressedImageData Handle](#lcompressedimagedata-handle)
- [LImageData Handle](#limagedata-handle)
- [LLayeredImage Handle](#llayeredimage-handle)
- [LPaletteLUT Handle](#lpalettelut-handle)
- [LProvinceGrid Handle](#lprovincegrid-handle)

## Callbacks

*No callback parameters documented in this module.*

## Enums

*No module-specific enums documented.*

## LCompressedImageData Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LCompressedImageData:getDimensions`

Returns compressed image dimensions.

```lua
LCompressedImageData:getDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width in pixels. |
| number | Height in pixels. |

**Example**

```lua
do
    local cdata = lurek.image.newCompressedData("content/examples/assets/images/sample_normal.dds")
    local w, h = cdata:getDimensions()
    print("compressed = " .. w .. "x" .. h)
end
```

---

#### `LCompressedImageData:getFormat`

Returns the compressed image format name.

```lua
LCompressedImageData:getFormat()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Format name. |

**Example**

```lua
do
    local cdata = lurek.image.newCompressedData("content/examples/assets/images/sample_normal.dds")
    print("format = " .. cdata:getFormat())
end
```

---

#### `LCompressedImageData:getHeight`

Returns compressed image height. This method is available to Lua scripts.

```lua
LCompressedImageData:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Height in pixels. |

**Example**

```lua
do
    local cd = lurek.image.newCompressedData("content/examples/assets/images/sample_normal.dds")
    local w = cd:getWidth()
    local h = cd:getHeight()
    local mips = cd:getMipmapCount()
    print("compressed w=" .. w .. " h=" .. h .. " mips=" .. mips)
end
```

---

#### `LCompressedImageData:getMipmapCount`

Returns the number of mipmap levels in this compressed image.

```lua
LCompressedImageData:getMipmapCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Mipmap level count. |

**Example**

```lua
do
    local cdata = lurek.image.newCompressedData("content/examples/assets/images/sample_normal.dds")
    print("mipmaps = " .. cdata:getMipmapCount())
end
```

---

#### `LCompressedImageData:getWidth`

Returns compressed image width. This method is available to Lua scripts.

```lua
LCompressedImageData:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width in pixels. |

**Example**

```lua
do
    local cd = lurek.image.newCompressedData("content/examples/assets/images/sample_normal.dds")
    local w = cd:getWidth()
    local h = cd:getHeight()
    local mips = cd:getMipmapCount()
    print("compressed w=" .. w .. " h=" .. h .. " mips=" .. mips)
end
```

---

#### `LCompressedImageData:type`

Returns the Lua-visible type name for this compressed image handle.

```lua
LCompressedImageData:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LCompressedImageData](#lcompressedimagedata-handle)`. |

**Example**

```lua
do
    local cdata = lurek.image.newCompressedData("content/examples/assets/images/sample_normal.dds")
    print("type = " .. cdata:type())
    print("is CompressedImageData = " .. tostring(cdata:typeOf("LCompressedImageData")))
end
```

---

#### `LCompressedImageData:typeOf`

Returns whether this compressed image handle matches a supported type name.

```lua
LCompressedImageData:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LCompressedImageData](#lcompressedimagedata-handle)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local cdata = lurek.image.newCompressedData("content/examples/assets/images/sample_normal.dds")
    print("type = " .. cdata:type())
    print("is CompressedImageData = " .. tostring(cdata:typeOf("LCompressedImageData")))
end
```

---

## LImageData Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LImageData:alphaMask`

Multiplies this image alpha channel by a factor in place.

```lua
LImageData:alphaMask(factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `factor` | number | Alpha multiplier. |

**Example**

```lua
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(255, 0, 0, 255)
    img:alphaMask(0.5)
    local _, _, _, a = img:getPixel(0, 0)
    print("alpha = " .. a)
end
```

---

#### `LImageData:applyPaletteLut`

Applies a palette lookup table to this image in place.

```lua
LImageData:applyPaletteLut(lut_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `lut_ud` | [LPaletteLUT](#lpalettelut-handle) | Palette lookup table handle. |

**Example**

```lua
do
    local img = lurek.image.newImageData(16, 16)
    local lut = lurek.image.newPaletteLut()
    img:fill(255, 0, 0, 255)
    lut:setColor(255, 0, 0, 255, 0, 255, 0, 255)
    img:applyPaletteLut(lut)
    print("palette LUT applied")
end
```

---

#### `LImageData:blit`

Copies a source image into this image at a destination coordinate.

```lua
LImageData:blit(src_ud, dst_x, dst_y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `src_ud` | [LImageData](#limagedata-handle) | Source image data handle. |
| `dst_x` | number | Destination x coordinate. |
| `dst_y` | number | Destination y coordinate. |

**Example**

```lua
do
    local dst = lurek.image.newImageData(64, 64)
    local src = lurek.image.newImageData(16, 16)
    src:fill(255, 255, 0, 255)
    dst:blit(src, 10, 10)
    print("blitted")
end
```

---

#### `LImageData:blur`

Returns a blurred copy of this image.

```lua
LImageData:blur(radius)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `radius` | number | Blur radius. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata-handle) | Blurred image data handle. |

**Example**

```lua
do
    local img = lurek.image.newImageData(64, 64)
    img:fill(255, 0, 0, 255)
    local blurred = img:blur(3)
    print("blurred " .. blurred:getWidth() .. "x" .. blurred:getHeight())
end
```

---

#### `LImageData:brightness`

Applies a brightness factor to this image in place.

```lua
LImageData:brightness(factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `factor` | number | Brightness multiplier or adjustment factor. |

**Example**

```lua
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(128, 128, 128, 255)
    img:brightness(1.5)
    print("brightness increased by 1.5x")
end
```

---

#### `LImageData:contrast`

Applies a contrast factor to this image in place.

```lua
LImageData:contrast(factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `factor` | number | Contrast factor. |

**Example**

```lua
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(102, 153, 128, 255)
    img:contrast(2.0)
    print("contrast doubled")
end
```

---

#### `LImageData:convolve`

Applies a convolution kernel and returns the filtered image.

```lua
LImageData:convolve(kernel_t, ksize)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `kernel_t` | table | Array table of numeric kernel weights. |
| `ksize` | number | Kernel width and height. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata-handle) | Convolved image data handle. |

**Example**

```lua
do
    local img = lurek.image.newImageData(32, 32)
    local kernel = {0, -1, 0, -1, 5, -1, 0, -1, 0}
    local result = img:convolve(kernel, 3)
    print("convolved " .. result:getWidth() .. "x" .. result:getHeight())
end
```

---

#### `LImageData:crop`

Returns a cropped image region. This method is available to Lua scripts.

```lua
LImageData:crop(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Source x coordinate. |
| `y` | number | Source y coordinate. |
| `w` | number | Crop width. |
| `h` | number | Crop height. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata-handle) | Cropped image data handle. |

**Example**

```lua
do
    local img = lurek.image.newImageData(100, 100)
    local cropped = img:crop(10, 10, 50, 50)
    print("cropped " .. cropped:getWidth() .. "x" .. cropped:getHeight())
end
```

---

#### `LImageData:diff`

Computes a difference metric against another image.

```lua
LImageData:diff(other_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other_ud` | [LImageData](#limagedata-handle) | Image data handle to compare with this image. |

**Returns**

| Type | Description |
|------|-------------|
| number | Difference score. |

**Example**

```lua
do
    local a = lurek.image.newImageData(8, 8)
    local b = lurek.image.newImageData(8, 8)
    b:setPixel(0, 0, 1, 0, 0, 1)
    local score = a:diff(b)
    print("diff score = " .. score)
end
```

---

#### `LImageData:drawCircle`

Draws a filled circle into this image.

```lua
LImageData:drawCircle(cx, cy, radius, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | number | Circle center x coordinate. |
| `cy` | number | Circle center y coordinate. |
| `radius` | number | Circle radius. |
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a` | number | Alpha channel. |

**Example**

```lua
do
    local img = lurek.image.newImageData(64, 64)
    img:drawCircle(32, 32, 16, 255, 0, 0, 255)
    print("circle drawn")
end
```

---

#### `LImageData:drawLine`

Draws a line into this image. This method is available to Lua scripts.

```lua
LImageData:drawLine(x0, y0, x1, y1, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x0` | number | Start x coordinate. |
| `y0` | number | Start y coordinate. |
| `x1` | number | End x coordinate. |
| `y1` | number | End y coordinate. |
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a` | number | Alpha channel. |

**Example**

```lua
do
    local img = lurek.image.newImageData(32, 32)
    img:drawLine(0, 0, 31, 31, 255, 255, 0, 255)
    print("line drawn")
end
```

---

#### `LImageData:drawNineSlice`

Draws a nine-slice region from a source image into this image.

```lua
LImageData:drawNineSlice(src_ud, src_x, src_y, src_w, src_h, dst_x, dst_y, dst_w, dst_h, inset_left, inset_right, inset_top, inset_bottom)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `src_ud` | [LImageData](#limagedata-handle) | Source image data handle. |
| `src_x` | number | Source region x coordinate. |
| `src_y` | number | Source region y coordinate. |
| `src_w` | number | Source region width. |
| `src_h` | number | Source region height. |
| `dst_x` | number | Destination x coordinate. |
| `dst_y` | number | Destination y coordinate. |
| `dst_w` | number | Destination width. |
| `dst_h` | number | Destination height. |
| `inset_left` | number | Left inset width. |
| `inset_right` | number | Right inset width. |
| `inset_top` | number | Top inset height. |
| `inset_bottom` | number | Bottom inset height. |

**Example**

```lua
do
    local dst = lurek.image.newImageData(64, 64)
    local src = lurek.image.newImageData(32, 32)
    src:fill(128, 128, 128, 255)
    dst:drawNineSlice(src, 0, 0, 32, 32, 0, 0, 64, 64, 8, 8, 8, 8)
    print("nine-slice drawn")
end
```

---

#### `LImageData:drawRect`

Draws a filled rectangle into this image.

```lua
LImageData:drawRect(x, y, w, h, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Rectangle x coordinate. |
| `y` | number | Rectangle y coordinate. |
| `w` | number | Rectangle width. |
| `h` | number | Rectangle height. |
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a` | number | Alpha channel. |

**Example**

```lua
do
    local img = lurek.image.newImageData(32, 32)
    img:drawRect(4, 4, 24, 24, 0, 255, 0, 255)
    print("rect drawn")
end
```

---

#### `LImageData:encode`

Encodes image data in a supported format.

```lua
LImageData:encode(format)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `format` | string | Format name; currently `png`. |

**Returns**

| Type | Description |
|------|-------------|
| string | Encoded image bytes. |

**Example**

```lua
do
    local img = lurek.image.newImageData(4, 4)
    img:fill(255, 0, 0, 255)
    local bytes = img:encode("png")
    print("encoded " .. #bytes .. " bytes")
end
```

---

#### `LImageData:fill`

Fills the whole image with one RGBA color.

```lua
LImageData:fill(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a` | number | Alpha channel. |

**Example**

```lua
do
    local img = lurek.image.newImageData(8, 8)
    img:fill(0, 0, 255, 255)
    print("filled blue")
end
```

---

#### `LImageData:flipHorizontal`

Flips this image horizontally in place.

```lua
LImageData:flipHorizontal()
```

**Example**

```lua
do
    local img = lurek.image.newImageData(16, 16)
    img:setPixel(0, 0, 255, 0, 0, 255)
    img:flipHorizontal()
    local r, _, _, _ = img:getPixel(15, 0)
    print("flipped h, corner r = " .. r)
end
```

---

#### `LImageData:flipVertical`

Flips this image vertically in place.

```lua
LImageData:flipVertical()
```

**Example**

```lua
do
    local img = lurek.image.newImageData(16, 16)
    img:setPixel(0, 0, 0, 255, 0, 255)
    img:flipVertical()
    local _, g, _, _ = img:getPixel(0, 15)
    print("flipped v, corner g = " .. g)
end
```

---

#### `LImageData:gamma`

Applies gamma correction to this image in place.

```lua
LImageData:gamma(gamma)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `gamma` | number | Gamma value. |

**Example**

```lua
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(128, 128, 128, 255)
    img:gamma(2.2)
    print("gamma 2.2 applied")
end
```

---

#### `LImageData:getDimensions`

Returns image dimensions. This method is available to Lua scripts.

```lua
LImageData:getDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width in pixels. |
| number | Height in pixels. |

**Example**

```lua
do
    local img = lurek.image.newImageData(100, 50)
    local w, h = img:getDimensions()
    print("dimensions = " .. w .. "x" .. h)
end
```

---

#### `LImageData:getHeight`

Returns image height. This method is available to Lua scripts.

```lua
LImageData:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Height in pixels. |

**Example**

```lua
do
    local img = lurek.image.newImageData(80, 40)
    print("height = " .. img:getHeight())
end
```

---

#### `LImageData:getPixel`

Returns RGBA channels at a pixel coordinate.

```lua
LImageData:getPixel(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Red channel. |
| number | Green channel. |
| number | Blue channel. |
| number | Alpha channel. |

**Example**

```lua
do
    local img = lurek.image.newImageData(10, 10)
    img:fill(255, 128, 0, 255)
    local r, g, b, a = img:getPixel(5, 5)
    print("pixel = " .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

#### `LImageData:getRawBytes`

Returns raw image bytes as a Lua string.

```lua
LImageData:getRawBytes()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Raw image byte string. |

**Example**

```lua
do
    local img = lurek.image.newImageData(2, 2)
    local raw = img:getRawBytes()
    print("raw bytes = " .. #raw)
end
```

---

#### `LImageData:getRegion`

Returns an image region when the requested rectangle is inside bounds.

```lua
LImageData:getRegion(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Region x coordinate. |
| `y` | number | Region y coordinate. |
| `w` | number | Region width. |
| `h` | number | Region height. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata-handle) | nil | `[LImageData](#limagedata-handle)` handle, or nil when the region is out of bounds. |

**Example**

```lua
do
    local img = lurek.image.newImageData(64, 64)
    local region = img:getRegion(0, 0, 32, 32)
    if region then
        print("region " .. region:getWidth() .. "x" .. region:getHeight())
    end
end
```

---

#### `LImageData:getString`

Returns raw image bytes as a Lua string.

```lua
LImageData:getString()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Raw image byte string. |

**Example**

```lua
do
    local img = lurek.image.newImageData(2, 2)
    local str = img:getString()
    print("string bytes = " .. #str)
end
```

---

#### `LImageData:getWidth`

Returns image width. This method is available to Lua scripts.

```lua
LImageData:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width in pixels. |

**Example**

```lua
do
    local img = lurek.image.newImageData(80, 40)
    print("width = " .. img:getWidth())
end
```

---

#### `LImageData:grayscale`

Converts this image to grayscale in place.

```lua
LImageData:grayscale()
```

**Example**

```lua
do
    local img = lurek.image.newImageData(32, 32)
    img:fill(255, 0, 0, 255)
    img:grayscale()
    local r, g, b, a = img:getPixel(0, 0)
    print("gray r=" .. r .. " g=" .. g .. " b=" .. b)
end
```

---

#### `LImageData:invert`

Inverts image color channels in place.

```lua
LImageData:invert()
```

**Example**

```lua
do
    local img = lurek.image.newImageData(8, 8)
    img:fill(255, 0, 0, 255)
    img:invert()
    local r, g, b, a = img:getPixel(0, 0)
    print("inverted r=" .. r .. " g=" .. g .. " b=" .. b)
end
```

---

#### `LImageData:mapPixel`

Applies a Lua callback to every pixel and replaces each pixel with returned RGBA values.

```lua
LImageData:mapPixel(func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `func` | function | Callback receiving `(x, y, r, g, b, a)` and returning replacement channels. |

**Example**

```lua
do
    local img = lurek.image.newImageData(8, 8)
    img:fill(255, 255, 255, 255)
    img:mapPixel(function(_, _, r, g, b, a)
        return math.floor(r * 0.5), math.floor(g * 0.5), math.floor(b * 0.5), a
    end)
    print("mapped pixels to half brightness")
end
```

---

#### `LImageData:mapPixels`

Applies a Lua callback to every pixel and replaces each pixel with returned RGBA values.

```lua
LImageData:mapPixels(func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `func` | function | Callback receiving `(x, y, r, g, b, a)` and returning replacement channels. |

**Example**

```lua
do
    local img = lurek.image.newImageData(8, 8)
    img:mapPixels(function(x, y)
        return x * 32, y * 32, 0, 255
    end)
    print("gradient mapped")
end
```

---

#### `LImageData:noise`

Adds noise to this image in place. This method is available to Lua scripts.

```lua
LImageData:noise(amount)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `amount` | number | Noise amount. |

**Example**

```lua
do
    local img = lurek.image.newImageData(32, 32)
    img:fill(128, 128, 128, 255)
    img:noise(16)
    print("noise added")
end
```

---

#### `LImageData:paste`

Pastes a source image into this image at unsigned destination coordinates.

```lua
LImageData:paste(src_ud, dx, dy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `src_ud` | [LImageData](#limagedata-handle) | Source image data handle. |
| `dx` | number | Destination x coordinate. |
| `dy` | number | Destination y coordinate. |

**Example**

```lua
do
    local dst = lurek.image.newImageData(64, 64)
    local src = lurek.image.newImageData(8, 8)
    src:fill(0, 255, 255, 255)
    dst:paste(src, 0, 0)
    print("pasted")
end
```

---

#### `LImageData:posterize`

Reduces image colors to a fixed number of levels in place.

```lua
LImageData:posterize(levels)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `levels` | number | Number of posterization levels. |

**Example**

```lua
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(179, 77, 128, 255)
    img:posterize(4)
    print("posterized to 4 levels")
end
```

---

#### `LImageData:resize`

Returns a resized image using an optional named filter.

```lua
LImageData:resize(width, height, filter)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Output width. |
| `height` | number | Output height. |
| `filter` | string | Optional filter name, defaulting to `bilinear`. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata-handle) | nil | Resized `[LImageData](#limagedata-handle)` handle, or nil when resizing fails. |

**Example**

```lua
do
    local img = lurek.image.newImageData(64, 64)
    local resized = img:resize(128, 128, "bilinear")
    print("resized = " .. resized:getWidth() .. "x" .. resized:getHeight())
end
```

---

#### `LImageData:resizeNearest`

Returns a resized image using nearest-neighbor sampling.

```lua
LImageData:resizeNearest(new_w, new_h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `new_w` | number | Output width. |
| `new_h` | number | Output height. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata-handle) | Resized image data handle. |

**Example**

```lua
do
    local img = lurek.image.newImageData(32, 32)
    local resized = img:resizeNearest(64, 64)
    print("nearest = " .. resized:getWidth() .. "x" .. resized:getHeight())
end
```

---

#### `LImageData:rotate90cw`

Returns a new image rotated ninety degrees clockwise.

```lua
LImageData:rotate90cw()
```

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata-handle) | Rotated image data handle. |

**Example**

```lua
do
    local img = lurek.image.newImageData(20, 40)
    local rotated = img:rotate90cw()
    print("rotated = " .. rotated:getWidth() .. "x" .. rotated:getHeight())
end
```

---

#### `LImageData:saturation`

Applies a saturation factor to this image in place.

```lua
LImageData:saturation(factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `factor` | number | Saturation factor. |

**Example**

```lua
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(255, 0, 0, 255)
    img:saturation(0.5)
    print("saturation halved")
end
```

---

#### `LImageData:sepia`

Applies a sepia filter to this image in place.

```lua
LImageData:sepia()
```

**Example**

```lua
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(128, 128, 128, 255)
    img:sepia()
    print("sepia applied")
end
```

---

#### `LImageData:setPixel`

Sets RGBA channels at a pixel coordinate.

```lua
LImageData:setPixel(x, y, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a` | number | Alpha channel. |

**Example**

```lua
do
    local img = lurek.image.newImageData(10, 10)
    img:setPixel(0, 0, 255, 255, 255, 255)
    local r, g, b, a = img:getPixel(0, 0)
    print("set pixel = " .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

#### `LImageData:setRawData`

Replaces the image byte buffer with raw bytes.

```lua
LImageData:setRawData(bytes)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bytes` | string | Raw byte string matching the image storage size. |

**Example**

```lua
do
    local img = lurek.image.newImageData(2, 2)
    local bytes = string.rep("\0\255\0\255", 4)
    img:setRawData(bytes)
    print("raw data set")
end
```

---

#### `LImageData:sharpen`

Returns a sharpened copy of this image.

```lua
LImageData:sharpen()
```

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata-handle) | Sharpened image data handle. |

**Example**

```lua
do
    local img = lurek.image.newImageData(64, 64)
    img:fill(128, 128, 128, 255)
    local sharp = img:sharpen()
    print("sharpened " .. sharp:getWidth() .. "x" .. sharp:getHeight())
end
```

---

#### `LImageData:threshold`

Applies a threshold filter to this image in place.

```lua
LImageData:threshold(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | number | Threshold channel value. |

**Example**

```lua
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(153, 153, 153, 255)
    img:threshold(128)
    print("thresholded at 128")
end
```

---

#### `LImageData:tint`

Blends this image toward a tint color in place.

```lua
LImageData:tint(tr, tg, tb, factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tr` | number | Tint red channel. |
| `tg` | number | Tint green channel. |
| `tb` | number | Tint blue channel. |
| `factor` | number | Tint blend factor. |

**Example**

```lua
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(255, 255, 255, 255)
    img:tint(255, 0, 0, 0.5)
    print("red tint applied at 50%")
end
```

---

#### `LImageData:type`

Returns the Lua-visible type name for this image data handle.

```lua
LImageData:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LImageData](#limagedata-handle)`. |

**Example**

```lua
do
    local img = lurek.image.newImageData(1, 1)
    print("type = " .. img:type())
end
```

---

#### `LImageData:typeOf`

Returns whether this image data handle matches the `[LImageData](#limagedata-handle)` type name.

```lua
LImageData:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LImageData](#limagedata-handle)` or `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches. |

**Example**

```lua
do
    local img = lurek.image.newImageData(1, 1)
    print("is ImageData = " .. tostring(img:typeOf("LImageData")))
end
```

---

## LLayeredImage Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LLayeredImage:addLayer`

Adds a blank layer with an optional name.

```lua
LLayeredImage:addLayer(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name?` | string | Optional layer name. |

**Returns**

| Type | Description |
|------|-------------|
| number | One-based index of the new layer. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(64, 64)
    local idx = li:addLayer("background")
    print("added layer at index " .. idx)
    print("layers = " .. li:layerCount())
end
```

---

#### `LLayeredImage:getHeight`

Returns the layered image height. This method is available to Lua scripts.

```lua
LLayeredImage:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Height in pixels. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(100, 50)
    print("layered size = " .. li:getWidth() .. "x" .. li:getHeight())
end
```

---

#### `LLayeredImage:getLayer`

Returns image data for a layer by one-based index.

```lua
LLayeredImage:getLayer(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | One-based layer index. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata-handle) | Layer image data handle. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(16, 16)
    li:addLayer("green")
    local data = li:getLayer(1)
    print("layer 1: " .. data:getWidth() .. "x" .. data:getHeight())
end
```

---

#### `LLayeredImage:getName`

Returns a layer name by one-based index.

```lua
LLayeredImage:getName(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | One-based layer index. |

**Returns**

| Type | Description |
|------|-------------|
| string | Layer name. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("background")
    local name = li:getName(1)
    print("layer name = " .. name)
end
```

---

#### `LLayeredImage:getOpacity`

Returns a layer opacity by one-based index.

```lua
LLayeredImage:getOpacity(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | One-based layer index. |

**Returns**

| Type | Description |
|------|-------------|
| number | Layer opacity. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("layer")
    print("opacity = " .. li:getOpacity(1))
end
```

---

#### `LLayeredImage:getWidth`

Returns the layered image width. This method is available to Lua scripts.

```lua
LLayeredImage:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width in pixels. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(100, 50)
    print("layered size = " .. li:getWidth() .. "x" .. li:getHeight())
end
```

---

#### `LLayeredImage:isVisible`

Returns layer visibility by one-based index.

```lua
LLayeredImage:isVisible(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | One-based layer index. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the layer is visible. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("vis")
    print("visible = " .. tostring(li:isVisible(1)))
end
```

---

#### `LLayeredImage:layerCount`

Returns the number of layers in the stack.

```lua
LLayeredImage:layerCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Layer count. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(8, 8)
    print("empty layers = " .. li:layerCount())
end
```

---

#### `LLayeredImage:merge`

Merges visible layers into a single image data object.

```lua
LLayeredImage:merge()
```

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata-handle) | Merged image data handle. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(32, 32)
    li:addLayer("base")
    local merged = li:merge()
    print("merged " .. merged:getWidth() .. "x" .. merged:getHeight())
end
```

---

#### `LLayeredImage:moveLayer`

Moves a layer from one one-based index to another.

```lua
LLayeredImage:moveLayer(from_idx, to_idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from_idx` | number | Source one-based layer index. |
| `to_idx` | number | Destination one-based layer index. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the move succeeds. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("first")
    li:addLayer("second")
    li:moveLayer(2, 1)
    print("moved: first is now " .. li:getName(1))
end
```

---

#### `LLayeredImage:removeLayer`

Removes a layer by one-based index.

```lua
LLayeredImage:removeLayer(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | One-based layer index. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a layer was removed. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(32, 32)
    li:addLayer("temp")
    li:removeLayer(1)
    print("layers after remove = " .. li:layerCount())
end
```

---

#### `LLayeredImage:save`

Saves the layered image stack to a file.

```lua
LLayeredImage:save(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Output path. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(16, 16)
    li:addLayer("only")
    li:save("save/layered_test.limg")
    print("layered image saved")
end
```

---

#### `LLayeredImage:setLayer`

Replaces a layer's image data by one-based index.

```lua
LLayeredImage:setLayer(index, img)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | One-based layer index. |
| `img` | [LImageData](#limagedata-handle) | Image data assigned to the layer. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the layer was replaced. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(16, 16)
    li:addLayer("slot")
    li:setLayer(1, lurek.image.newImageData(16, 16))
    print("layer replaced")
end
```

---

#### `LLayeredImage:setName`

Sets a layer name by one-based index.

```lua
LLayeredImage:setName(index, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | One-based layer index. |
| `name` | string | New layer name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the layer exists. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("old")
    li:setName(1, "renamed")
    print("new name = " .. li:getName(1))
end
```

---

#### `LLayeredImage:setOpacity`

Sets a layer opacity by one-based index.

```lua
LLayeredImage:setOpacity(index, opacity)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | One-based layer index. |
| `opacity` | number | New layer opacity. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the layer exists. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("layer")
    li:setOpacity(1, 0.5)
    print("opacity = " .. li:getOpacity(1))
end
```

---

#### `LLayeredImage:setVisible`

Sets layer visibility by one-based index.

```lua
LLayeredImage:setVisible(index, visible)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | One-based layer index. |
| `visible` | boolean | New visibility flag. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the layer exists. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("toggle")
    li:setVisible(1, false)
    print("visible = " .. tostring(li:isVisible(1)))
end
```

---

#### `LLayeredImage:swapLayers`

Swaps two layers by one-based indices.

```lua
LLayeredImage:swapLayers(a, b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | number | First one-based layer index. |
| `b` | number | Second one-based layer index. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when both layers exist. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("alpha")
    li:addLayer("beta")
    li:swapLayers(1, 2)
    print("after swap: 1=" .. li:getName(1) .. " 2=" .. li:getName(2))
end
```

---

#### `LLayeredImage:type`

Returns the Lua-visible type name for this layered image handle.

```lua
LLayeredImage:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LLayeredImage](#llayeredimage-handle)`. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(8, 8)
    print("type = " .. li:type())
    print("is LayeredImage = " .. tostring(li:typeOf("LLayeredImage")))
end
```

---

#### `LLayeredImage:typeOf`

Returns whether this layered image handle matches a supported type name.

```lua
LLayeredImage:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LLayeredImage](#llayeredimage-handle)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(8, 8)
    print("type = " .. li:type())
    print("is LayeredImage = " .. tostring(li:typeOf("LLayeredImage")))
end
```

---

## LPaletteLUT Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LPaletteLUT:clear`

Removes every color mapping from this palette lookup table.

```lua
LPaletteLUT:clear()
```

**Example**

```lua
do
    local lut = lurek.image.newPaletteLut()
    lut:setColor(255, 0, 0, 255, 0, 0, 255, 255)
    lut:clear()
    print("LUT cleared, colors = " .. lut:getColorCount())
end
```

---

#### `LPaletteLUT:cycle`

Cycles palette mappings by an offset.

```lua
LPaletteLUT:cycle(offset)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `offset` | number | Mapping offset. |

**Example**

```lua
do
    local lut = lurek.image.newPaletteLut()
    lut:setColor(255, 0, 0, 255, 0, 255, 0, 255)
    lut:setColor(0, 255, 0, 255, 0, 0, 255, 255)
    lut:cycle(1)
    print("palette cycled")
end
```

---

#### `LPaletteLUT:getColorCount`

Returns the number of color mappings in this palette lookup table.

```lua
LPaletteLUT:getColorCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Color mapping count. |

**Example**

```lua
do
    local lut = lurek.image.newPaletteLut()
    lut:setColor(255, 0, 0, 255, 128, 0, 0, 255)
    print("color count = " .. lut:getColorCount())
end
```

---

#### `LPaletteLUT:setColor`

Adds a color mapping from source RGBA channels to destination RGBA channels.

```lua
LPaletteLUT:setColor(fr, fg, fb, fa, tr, tg, tb, ta)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fr` | number | Source red channel. |
| `fg` | number | Source green channel. |
| `fb` | number | Source blue channel. |
| `fa` | number | Source alpha channel. |
| `tr` | number | Destination red channel. |
| `tg` | number | Destination green channel. |
| `tb` | number | Destination blue channel. |
| `ta` | number | Destination alpha channel. |

**Example**

```lua
do
    local lut = lurek.image.newPaletteLut()
    lut:setColor(255, 0, 0, 255, 0, 255, 0, 255)
    print("red → green mapping set")
end
```

---

#### `LPaletteLUT:type`

Returns the Lua-visible type name for this palette lookup table handle.

```lua
LPaletteLUT:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LPaletteLUT](#lpalettelut-handle)`. |

**Example**

```lua
do
    local lut = lurek.image.newPaletteLut()
    print("type = " .. lut:type())
    print("is PaletteLUT = " .. tostring(lut:typeOf("LPaletteLUT")))
end
```

---

#### `LPaletteLUT:typeOf`

Returns whether this palette lookup table handle matches a supported type name.

```lua
LPaletteLUT:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LPaletteLUT](#lpalettelut-handle)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local lut = lurek.image.newPaletteLut()
    print("type = " .. lut:type())
    print("is PaletteLUT = " .. tostring(lut:typeOf("LPaletteLUT")))
end
```

---

## LProvinceGrid Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LProvinceGrid:adjacencies`

Returns province adjacency records and shared border pixel counts.

```lua
LProvinceGrid:adjacencies()
```

**Returns**

| Type | Description |
|------|-------------|
| LProvinceGridAdjacenciesResult | Array table with `province_a`, `province_b`, and `border_pixels` fields. |

**Example**

```lua
do
    local grid = lurek.image.newProvinceGrid("assets/textures/province_map.png")
    local adj = grid:adjacencies()
    print("adjacency records = " .. #adj)
end
```

---

#### `LProvinceGrid:borderSegments`

Returns border line segments between neighboring provinces.

```lua
LProvinceGrid:borderSegments()
```

**Returns**

| Type | Description |
|------|-------------|
| LProvinceGridBorderSegmentsResult | Array table with province ids and segment coordinates. |

**Example**

```lua
do
    local grid = lurek.image.newProvinceGrid("assets/textures/province_map.png")
    local segs = grid:borderSegments()
    print("border segments = " .. #segs)
end
```

---

#### `LProvinceGrid:deserializeShapeData`

Decodes serialized province shape data into span and segment tables.

```lua
LProvinceGrid:deserializeShapeData(bytes)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bytes` | string | Serialized shape data bytes. |

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Table with `spans` and `segments`, or nil when decoding fails. |

**Example**

```lua
do
    local grid = lurek.image.newProvinceGrid("assets/textures/province_map.png")
    local data = grid:serializeShapeData()
    print("serialized " .. #data .. " bytes")
    grid:deserializeShapeData(data)
    print("deserialized")
end
```

---

#### `LProvinceGrid:drawShapes`

Queues filled polygon draw commands for province shapes, optionally culled to a viewport rect.

```lua
LProvinceGrid:drawShapes(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x?` | number | Viewport left edge (required if providing a viewport). |
| `y?` | number | Viewport top edge (required if providing a viewport). |
| `w?` | number | Viewport width (required if providing a viewport). |
| `h?` | number | Viewport height (required if providing a viewport). |

**Returns**

| Type | Description |
|------|-------------|
| number | Number of polygons emitted to the render command queue. |

**Example**

```lua
do
    local grid = lurek.image.newProvinceGrid("assets/textures/province_map.png")
    local count = grid:drawShapes(0, 0, 800, 600)
    print("drew " .. count .. " polygons")
end
```

---

#### `LProvinceGrid:getAt`

Returns the province id stored at grid coordinates.

```lua
LProvinceGrid:getAt(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Province id at the pixel. |

**Example**

```lua
do
    local grid = lurek.image.newProvinceGrid("assets/textures/province_map.png")
    local id = grid:getAt(10, 10)
    print("province at (10,10) = " .. id)
end
```

---

#### `LProvinceGrid:getHeight`

Returns the province grid height. This method is available to Lua scripts.

```lua
LProvinceGrid:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Grid height in pixels. |

**Example**

```lua
do
    local grid = lurek.image.newProvinceGrid("assets/textures/province_map.png")
    print("grid = " .. grid:getWidth() .. "x" .. grid:getHeight())
end
```

---

#### `LProvinceGrid:getPolygons`

Returns polygon rings for every province.

```lua
LProvinceGrid:getPolygons()
```

**Returns**

| Type | Description |
|------|-------------|
| LProvinceGridGetPolygonsResult | Array table of province polygon records with `province_id` and `rings` fields. |

**Example**

```lua
do
    local grid = lurek.image.newProvinceGrid("assets/textures/province_map.png")
    local polys = grid:getPolygons()
    print("polygon records = " .. #polys)
end
```

---

#### `LProvinceGrid:getPolygonsSimplified`

Returns simplified polygon rings for every province.

```lua
LProvinceGrid:getPolygonsSimplified()
```

**Returns**

| Type | Description |
|------|-------------|
| LProvinceGridGetPolygonsSimplifiedResult | Array table of simplified province polygon records with `province_id` and `rings` fields. |

**Example**

```lua
do
    local grid = lurek.image.newProvinceGrid("assets/textures/province_map.png")
    local polys = grid:getPolygonsSimplified()
    print("simplified records = " .. #polys)
end
```

---

#### `LProvinceGrid:getWidth`

Returns the province grid width. This method is available to Lua scripts.

```lua
LProvinceGrid:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Grid width in pixels. |

**Example**

```lua
do
    local grid = lurek.image.newProvinceGrid("assets/textures/province_map.png")
    print("grid = " .. grid:getWidth() .. "x" .. grid:getHeight())
end
```

---

#### `LProvinceGrid:provinceCount`

Returns the number of distinct provinces in the grid.

```lua
LProvinceGrid:provinceCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Province count. |

**Example**

```lua
do
    local grid = lurek.image.newProvinceGrid("assets/textures/province_map.png")
    print("provinces = " .. grid:provinceCount())
end
```

---

#### `LProvinceGrid:provinceSpans`

Returns horizontal province spans by row.

```lua
LProvinceGrid:provinceSpans()
```

**Returns**

| Type | Description |
|------|-------------|
| LProvinceGridProvinceSpansResult | Array table with `province_id`, `y`, `x0`, and `x1` fields. |

**Example**

```lua
do
    local grid = lurek.image.newProvinceGrid("assets/textures/province_map.png")
    local spans = grid:provinceSpans()
    print("total spans = " .. #spans)
end
```

---

#### `LProvinceGrid:serializeShapeData`

Serializes province span and border shape data into a binary Lua string.

```lua
LProvinceGrid:serializeShapeData()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Serialized shape data bytes. |

**Example**

```lua
do
    local grid = lurek.image.newProvinceGrid("assets/textures/province_map.png")
    local data = grid:serializeShapeData()
    print("serialized " .. #data .. " bytes")
    grid:deserializeShapeData(data)
    print("deserialized")
end
```

---

#### `LProvinceGrid:type`

Returns the Lua-visible type name for this province grid handle.

```lua
LProvinceGrid:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LProvinceGrid](#lprovincegrid-handle)`. |

**Example**

```lua
do
    local grid = lurek.image.newProvinceGrid("assets/textures/province_map.png")
    print("type = " .. grid:type())
    print("is ProvinceGrid = " .. tostring(grid:typeOf("LProvinceGrid")))
end
```

---

#### `LProvinceGrid:typeOf`

Returns whether this province grid handle matches a supported type name.

```lua
LProvinceGrid:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LProvinceGrid](#lprovincegrid-handle)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local grid = lurek.image.newProvinceGrid("assets/textures/province_map.png")
    print("type = " .. grid:type())
    print("is ProvinceGrid = " .. tostring(grid:typeOf("LProvinceGrid")))
end
```

---
