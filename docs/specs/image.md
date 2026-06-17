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

This module primarily collaborates with `animation`, `camera`, `color`, `math`, `province`, `render`, `runtime`. Its responsibility should stay inside the Platform Services group rather than absorb behavior owned by those neighbors.

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

- Encodes frame sequences of `ImageData` into animated GIF files for evidence and export flows. `image/animated_gif` delivers the animated gif implementation for the image subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Validates frame dimensions and timing up front so Lua-facing callers get deterministic failures. The file owns or coordinates data contracts including `AnimatedGifRepeat`, `AnimatedGifOptions`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Uses per-frame quantization from RGBA buffers to keep the API simple for software-rendered captures. Public callable behavior is centered on `encode_gif`, `save_gif`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- `image/animated_gif` delivers the animated gif implementation for the image subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

### compressed.rs

- Decodes DDS-style compressed textures into structured payloads used by higher-level image loading. `image/compressed` delivers the compressed implementation for the image subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Validates headers and extracts dimensions, mip blocks, and metadata needed for downstream upload. The file owns or coordinates data contracts including `CompressedFormat`, `CompressedImageData`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Detects desktop and mobile block-compression families from DXGI and legacy format descriptors. Public callable behavior is centered on no named public items, while method-level behavior such as `as_str`, `from_dds`, `get_dimensions`, `get_mipmap_count`, `get_format`, `is_dds_magic`, and 2 more stays attached to the local data model and invariants.
- Exposes file and byte entry points so callers can probe and decode assets from multiple pipelines. Runtime integration reaches sibling engine areas through crate modules `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.

### effects.rs

- Provides the main CPU image effect toolkit for color grading, filtering, resampling, and compositing. `image/effects` delivers the effects implementation for the image subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Applies brightness, contrast, saturation, gamma, tint, threshold, and stylization transforms per pixel. The file owns or coordinates data contracts including `ResizeFilter`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Supports deterministic noise injection and alpha-aware operations for repeatable visual post-processing. Public callable behavior is centered on no named public items, while method-level behavior such as `parse`, `brightness`, `contrast`, `saturation`, `gamma`, `tint`, and 22 more stays attached to the local data model and invariants.
- Implements geometric edits like crop, flip, and rotation for texture preparation and UI workflows. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Includes nearest, bilinear, and Lanczos resize paths to balance speed and quality by caller choice. External integration uses `super`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Runs blur, sharpen, and generic kernel convolution with safe boundary handling on edge samples. The file boundary separates image implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.

### image_data.rs

- Defines the central mutable RGBA buffer used across rendering, tooling, and image-side gameplay logic. `image/image_data` delivers the image data implementation for the image subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Creates images from dimensions, files, encoded bytes, or direct raw pixel payloads. The file owns or coordinates data contracts including `ImageData`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Provides pixel access, region copy, and whole-buffer transform flows in serial and parallel variants. Public callable behavior is centered on no named public items, while method-level behavior such as `rgba_byte_len`, `try_new`, `new`, `from_file`, `from_encoded_bytes`, `from_bytes`, and 18 more stays attached to the local data model and invariants.
- Implements primitive raster drawing for lines, rectangles, circles, labels, and debug overlays. Runtime integration reaches sibling engine areas through crate modules `log_msg`, `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Supports blending and paste semantics that keep alpha composition behavior explicit and predictable. External integration uses no named public items, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Carries width, height, and packed bytes in a compact row-major memory representation. The file boundary separates image implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.

### layers.rs

- Implements layered image editing with per-layer visibility, opacity, naming, and pixel ownership. `image/layers` delivers the layers implementation for the image subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Maintains ordered stacks so compositing results stay deterministic during insert and reorder actions. The file owns or coordinates data contracts including `ImageLayer`, `LayeredImage`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Supports add, remove, rename, swap, and move operations for non-destructive content workflows. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `width`, `height`, `layer_count`, `add_layer`, `remove_layer`, and 9 more stays attached to the local data model and invariants.
- Merges the stack into flat output using alpha-over compositing compatible with engine image buffers. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### mod.rs

- High-level image module that unifies pixel buffers, effects, serialization, and atlas-oriented helpers. `image/mod` is the image module index, declaring `image_data`, `compressed`, `effects`, `palette_lut`, `layers`, and 7 more so agents can identify which files own each feature slice before opening implementation code.
- Re-exports core image types and decoding utilities used across runtime systems and content pipelines. `src/image/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `image_data::ImageData`, `compressed::{CompressedFormat, CompressedImageData}`, `palette_lut::PaletteLUT`, `layers::{ImageLayer, LayeredImage}`, and 5 more centralized for the image subsystem.
- Defines the integration boundary between CPU image manipulation and render-upload preparation. The file documents how image submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.
- `image/mod` is the image module index, declaring `image_data`, `compressed`, `effects`, `palette_lut`, `layers`, and 7 more so agents can identify which files own each feature slice before opening implementation code.
- `src/image/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `image_data::ImageData`, `compressed::{CompressedFormat, CompressedImageData}`, `palette_lut::PaletteLUT`, `layers::{ImageLayer, LayeredImage}`, and 5 more centralized for the image subsystem.
- The file documents how image submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.

### palette_lut.rs

- Provides palette lookup remapping that transforms source colors into target colors across images. `image/palette_lut` delivers the palette lut implementation for the image subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Stores parallel source and destination palettes to express deterministic recolor tables. The file owns or coordinates data contracts including `PaletteLUT`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Applies in-place remap passes optimized by direct scan or hash-assisted lookup by palette size. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `get_color_count`, `set_color`, `get_from_color`, `get_to_color`, `clear`, and 2 more stays attached to the local data model and invariants.
- Supports rotation-style remap workflows for palette cycling and stylized animation effects. Runtime integration reaches sibling engine areas through crate modules `color`, which explains the subsystem dependencies an agent should inspect before changing behavior.

### rect_packing.rs

- Implements shelf-based rectangle packing used to place sprites into compact atlas layouts. `image/rect_packing` delivers the rect packing implementation for the image subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Accepts caller-defined atlas bounds and padding to preserve sampling safety between regions. The file owns or coordinates data contracts including `PackedRect`, `RectPacker`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Places rectangles in insertion order while tracking shelf growth and remaining horizontal space. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `pack`, `clear`, `packed_rects`, `occupancy`, `size`, and 1 more stays attached to the local data model and invariants.
- Returns deterministic packed coordinates that map back to source asset identities. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### render.rs

- Thin bridge layer converting ImageData buffers into render command payloads that reference texture resources and screen placement coordinates.

### serial.rs

- Implements LIMG binary serialization for flat and layered images with versioned format guards. `image/serial` delivers the serial implementation for the image subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Encodes and decodes pixel payloads with compression to reduce storage and transfer overhead. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Validates magic headers, version bytes, and payload type tags before accepting input data. Public callable behavior is centered on `save_image`, `load_image`, `load_image_from_bytes`, `save_layered`, `load_layered`, and 4 more, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Preserves layer metadata such as names, opacity, and visibility across save-load round trips. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Exposes both in-memory byte APIs and filesystem helpers for flexible integration contexts. External integration uses `super`, `flate2`, `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### texture.rs

- Manages CPU texture ingestion and staging before GPU-side renderer upload and sampling. `image/texture` delivers the texture implementation for the image subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Decodes files and raw buffers into validated RGBA payloads keyed in slot-map storage. The file owns or coordinates data contracts including `TextureColorSpace`, `Texture`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Applies premultiplied-alpha conversion paths to align blending behavior with render expectations. Public callable behavior is centered on `premultiply_alpha_rgba8_in_place`, while method-level behavior such as `parse_color_space`, `load`, `load_with_color_space`, `from_rgba`, `from_rgba_with_color_space` stays attached to the local data model and invariants.
- Tracks texture color-space intent so pipelines can distinguish sRGB and linear content. Runtime integration reaches sibling engine areas through crate modules `log_msg`, `render`, `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.

### texture_atlas.rs

- Builds and maintains texture atlases that group many named regions inside one packed image. `image/texture_atlas` delivers the texture atlas implementation for the image subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Uses shelf-style placement to allocate rectangles while preserving padding and bounds guarantees. The file owns or coordinates data contracts including `NineSliceInsets`, `AtlasRegion`, `TextureAtlas`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Attaches optional nine-slice inset metadata so UI sprites can scale without corner distortion. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `pack`, `pack_with_nine_slice`, `set_nine_slice`, `get_region`, `get_region_count`, and 3 more stays attached to the local data model and invariants.
- Supports name-based lookup, mutation, and reset operations for dynamic atlas management. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### visualization/animation.rs

- Renders animation timelines and frame grids into debug images for rapid visual inspection. `image/visualization/animation` delivers the animation implementation for the image subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Highlights current playback position against surrounding frames to expose timing behavior. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Draws state-oriented overlays for running, paused, and resumed playback diagnostics. Public callable behavior is centered on `draw_animation_frame_grid_to_image`, `draw_animation_playback_to_image`, `animation_playback_control_to_image`, `draw_animation_to_image`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Provides quick wrappers with sensible cell sizing for tool and test screenshot generation. Runtime integration reaches sibling engine areas through crate modules `animation`, `image`, which explains the subsystem dependencies an agent should inspect before changing behavior.

### visualization/audio.rs

- Converts audio sample streams into waveform images suitable for tooling and in-engine diagnostics. `image/visualization/audio` delivers the audio implementation for the image subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Renders mono and stereo views with channel separation and baseline guides for quick interpretation. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Supports zoom-oriented sampling views to inspect transient detail in dense signal regions. Public callable behavior is centered on `waveform_to_image`, `waveform_stereo_to_image`, `waveform_zoomed_to_image`, `draw_sound_waveform_to_image`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Adds labels and configurable color accents so waveform panels fit different UI styles. Runtime integration reaches sibling engine areas through crate modules `image`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Normalizes peak ranges to keep amplitude visualization stable across varying source loudness. External integration uses no named public items, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### visualization/camera.rs

- Produces camera-debug imagery that visualizes framing, motion, and transform behavior in world space. `image/visualization/camera` delivers the camera implementation for the image subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Draws viewport boxes, crosshairs, and coordinate guides for position and anchor verification. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Compares multiple zoom factors to reveal scale-dependent composition and clipping effects. Public callable behavior is centered on `draw_camera_debug_to_image`, `draw_camera_zoom_comparison_to_image`, `camera_rotation_to_image`, `camera_bounds_to_image`, `camera_follow_to_image`, and 6 more, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Renders rotation-aware grids that expose world-to-screen mapping under angular transforms. Runtime integration reaches sibling engine areas through crate modules `camera`, `image`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Displays bounds and follow trails to inspect dead-zone tuning and target-tracking responses. External integration uses `super`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Visualizes shake offsets against center references for temporal stability checks. The file boundary separates image implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.

### visualization/easing.rs

- Renders easing and curve diagnostics as image charts for motion-tuning and teaching workflows. `image/visualization/easing` delivers the easing implementation for the image subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Produces labeled curve galleries arranged in grids for side-by-side behavior comparison. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Draws overlay traces that contrast multiple easing functions on shared coordinate axes. Public callable behavior is centered on `easing_gallery_to_image`, `easing_comparison_to_image`, `bezier_curves_to_image`, `draw_bezier_advanced_to_image`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Includes Bezier-focused views with control-point and segment cues for shape inspection. Runtime integration reaches sibling engine areas through crate modules `image`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Supplies advanced Bezier visualization for derivative and edit-oriented debugging scenarios. External integration uses no named public items, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### visualization/facade.rs

- Provides shared visualization color conversion from HSV space into RGB byte tuples. `image/visualization/facade` delivers the public facade over lower-level subsystem helpers for the image subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

### visualization/geometry.rs

- Generates geometry-focused debug images that visualize shape algorithms and spatial relationships. `image/visualization/geometry` delivers the geometry implementation for the image subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Renders polygon galleries, primitive fills, and line rasterization examples for correctness checks. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Shows convex hull and centroid style outputs to inspect geometric post-processing behavior. Public callable behavior is centered on `polygon_gallery_to_image`, `spiral_to_image`, `filled_primitives_to_image`, `draw_geometry_shapes_to_image`, `draw_geometry_intersections_to_image`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Illustrates intersection outcomes between segments, circles, and lines with clear overlays. Runtime integration reaches sibling engine areas through crate modules `image`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Draws spiral and ring patterns to stress sampling consistency and color-mapping utilities. External integration uses `super`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### visualization/graph.rs

- Renders graph structures into diagnostic images with nodes, edges, labels, and status overlays. `image/visualization/graph` delivers the graph implementation for the image subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Visualizes active and removed connections using distinct styling for topology change analysis. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Supports item-flow style arrows and annotation text for simulation and logic debugging. Public callable behavior is centered on `draw_graph_operations_to_image`, `draw_graph_item_flow_to_image`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Places titles and stats summaries to contextualize rendered graph snapshots. Runtime integration reaches sibling engine areas through crate modules `image`, which explains the subsystem dependencies an agent should inspect before changing behavior.

### visualization/image_ops.rs

- Composes side-by-side image operation previews for fast visual comparison of processing outputs. `image/visualization/image_ops` delivers the image ops implementation for the image subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Builds slot-based layouts with scaling and padding so varied source sizes stay presentable. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Labels each panel to make transform deltas clear during review and regression analysis. Public callable behavior is centered on `draw_image_comparison_to_image`, `draw_pixel_transform_grid_to_image`, `draw_color_wheel_to_image`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Includes color-wheel and transform showcase helpers for broad image-operation demonstrations. Runtime integration reaches sibling engine areas through crate modules `image`, which explains the subsystem dependencies an agent should inspect before changing behavior.

### visualization/mod.rs

- High-level visualization module wiring that groups image-debug renderers by domain. `image/visualization/mod` is the image module index, declaring `animation`, `audio`, `camera`, `easing`, `facade`, and 6 more so agents can identify which files own each feature slice before opening implementation code.
- Re-exports category entry points to provide one flat surface for visualization consumers. `src/image/visualization/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `animation::*`, `audio::*`, `camera::*`, `easing::*`, and 6 more centralized for the image subsystem.
- Shares internal facade utilities while keeping submodule responsibilities clearly separated. The file documents how image submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.
- `image/visualization/mod` is the image module index, declaring `animation`, `audio`, `camera`, `easing`, `facade`, and 6 more so agents can identify which files own each feature slice before opening implementation code.
- `src/image/visualization/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `animation::*`, `audio::*`, `camera::*`, `easing::*`, and 6 more centralized for the image subsystem.
- The file documents how image submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.

### visualization/noise.rs

- Turns scalar noise functions into image outputs for terrain tuning and generator diagnostics. `image/visualization/noise` delivers the noise implementation for the image subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Renders normalized and raw grayscale maps to compare contrast handling across noise sources. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Provides biome and elevation band coloring to inspect threshold-driven terrain classification. Public callable behavior is centered on `noise_to_image`, `noise_raw_to_image`, `noise_terrain_to_image`, `heightmap_to_image`, `terrain_elevation_to_image`, and 2 more, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Supports sliced and tiled comparison views for spotting artifacts across parameter variations. Runtime integration reaches sibling engine areas through crate modules `image`, which explains the subsystem dependencies an agent should inspect before changing behavior.

### visualization/procgen.rs

- Visualizes procedural-generation data structures as images for analysis and tuning loops. `image/visualization/procgen` delivers the procgen implementation for the image subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Renders cellular grids, dungeon maps, and occupancy states with configurable color semantics. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Draws Voronoi and Delaunay style outputs to inspect spatial partition behavior. Public callable behavior is centered on `cellular_grid_to_image`, `voronoi_to_image`, `points_to_image`, `dungeon_grid_to_image`, `colored_points_to_image`, and 1 more, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Displays point samples and topology overlays for algorithm-step debugging. Runtime integration reaches sibling engine areas through crate modules `image`, which explains the subsystem dependencies an agent should inspect before changing behavior.

### visualization/ui.rs

- Renders UI-oriented mockups into images to preview panel composition and widget styling. `image/visualization/ui` delivers the ui implementation for the image subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Draws settings-style panels with controls, sliders, and button affordances for layout checks. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Produces HUD bars and cooldown visuals used to validate gameplay HUD readability. Public callable behavior is centered on `panel_layout_to_image`, `hud_bars_to_image`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Includes swatches and progress widgets for color and status presentation experiments. Runtime integration reaches sibling engine areas through crate modules `image`, which explains the subsystem dependencies an agent should inspect before changing behavior.



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
