# image

## General Info

- Module group: `Platform Services`
- Source path: `src/image/`
- Binding: `src/lua_api/image_api.rs`
- Namespace: `lurek.image`
- Lua API surface: `12` functions, `10` types, `90` methods
- Rust test path(s): tests/rust/unit/image_tests.rs, tests/rust/stress/image_stress_tests.rs
- Lua test path(s): tests/lua/unit/test_image_core_unit.lua, tests/lua/unit/test_image.lua, tests/lua/unit/test_image_effect.lua, tests/lua/unit/test_render_core_unit.lua, tests/lua/stress/test_image_stress.lua, tests/lua/evidence/test_evidence_image_drawing.lua, tests/lua/evidence/test_evidence_imagedata.lua, tests/lua/evidence/test_evidence_image_effects.lua, tests/lua/evidence/test_evidence_imagedata_effects.lua

## Summary

The foundational type is `ImageData`, which manages raw RGBA8 pixel buffers along with their dimensions. It supports a wide array of image processing operations including filling, nearest-neighbor and bilinear resizing, flipping, rotation, cropping, and primitive drawing (lines, circles, rectangles, and compact bitmap text). Crucially, it provides a comprehensive set of pixel-level effects—such as brightness, contrast, saturation, gamma correction, tinting, grayscale, sepia, inversion, thresholding, and separable box blurs—many of which are highly optimized using parallel processing (Rayon) for large images.

Beyond flat buffers, the module implements a sophisticated `LayeredImage` system. This allows developers to construct complex images from ordered stacks of `ImageLayer`s, featuring adjustable opacity, visibility flags, and support for Porter-Duff alpha blending to merge the final composite. For asset management, the module decodes compressed texture formats (DDS BC1–BC7) and supports standard image encoding/decoding (PNG, QOI, BMP). It also includes a `TextureAtlas` packer that combines multiple sprites into a single large texture using a shelf-based bin-packing algorithm, complete with nine-slice inset metadata for scalable UI components.

The `image` module features specialized systems for game development, most notably the `ProvinceGrid`. This system performs high-speed flood-fill analysis on color-coded PNG maps to generate optimized spatial indexes, identifying distinct provinces, calculating adjacencies, tracing polygonal borders, and exporting compressed shape data for Geoscape-style games. Additionally, `PaletteLUT` provides hardware-accelerated color remapping for retro palette-swapping effects. The module also contains an extensive set of debug visualization renderers for animation, audio, camera bounds, easing curves, and procedural generation (Voronoi, noise, cellular automata). The entire API, including CPU-to-GPU texture upload helpers, is fully exposed to Lua via the `lurek.image.*` namespace.

## Files

### [compressed.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/image/compressed.rs)

- Decodes DDS-style compressed textures into structured payloads used by higher-level image loading.
- Validates headers and extracts dimensions, mip blocks, and metadata needed for downstream upload.
- Detects desktop and mobile block-compression families from DXGI and legacy format descriptors.
- Exposes file and byte entry points so callers can probe and decode assets from multiple pipelines.
- Returns stable data carriers containing format tags and raw compressed mip chains.

### [effects.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/image/effects.rs)

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

### [image_data.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/image/image_data.rs)

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

### [layers.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/image/layers.rs)

- Implements layered image editing with per-layer visibility, opacity, naming, and pixel ownership.
- Maintains ordered stacks so compositing results stay deterministic during insert and reorder actions.
- Supports add, remove, rename, swap, and move operations for non-destructive content workflows.
- Merges the stack into flat output using alpha-over compositing compatible with engine image buffers.
- Provides practical layer primitives for editors, tooling pipelines, and scripted content generation.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/image/mod.rs)

- High-level image module that unifies pixel buffers, effects, serialization, and atlas-oriented helpers.
- Re-exports core image types and decoding utilities used across runtime systems and content pipelines.
- Defines the integration boundary between CPU image manipulation and render-upload preparation.

### [palette_lut.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/image/palette_lut.rs)

- Provides palette lookup remapping that transforms source colors into target colors across images.
- Stores parallel source and destination palettes to express deterministic recolor tables.
- Applies in-place remap passes optimized by direct scan or hash-assisted lookup by palette size.
- Supports rotation-style remap workflows for palette cycling and stylized animation effects.
- Supplies reusable color-map primitives for procedural art and runtime theme variation.

### [rect_packing.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/image/rect_packing.rs)

- Implements shelf-based rectangle packing used to place sprites into compact atlas layouts.
- Accepts caller-defined atlas bounds and padding to preserve sampling safety between regions.
- Places rectangles in insertion order while tracking shelf growth and remaining horizontal space.
- Returns deterministic packed coordinates that map back to source asset identities.
- Reports occupancy metrics useful for tuning atlas size and packing efficiency.

### [render.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/image/render.rs)

- Bridges CPU `ImageData` content into render-command payloads consumed by the draw pipeline.
- Provides lightweight conversion helpers that reference texture keys and screen placement.
- Includes image snapshot utilities used where value-copy semantics are required.

### [serial.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/image/serial.rs)

- Implements LIMG binary serialization for flat and layered images with versioned format guards.
- Encodes and decodes pixel payloads with compression to reduce storage and transfer overhead.
- Validates magic headers, version bytes, and payload type tags before accepting input data.
- Preserves layer metadata such as names, opacity, and visibility across save-load round trips.
- Exposes both in-memory byte APIs and filesystem helpers for flexible integration contexts.
- Keeps format handling deterministic so tooling and runtime produce consistent binary artifacts.

### [texture.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/image/texture.rs)

- Manages CPU texture ingestion and staging before GPU-side renderer upload and sampling.
- Decodes files and raw buffers into validated RGBA payloads keyed in slot-map storage.
- Applies premultiplied-alpha conversion paths to align blending behavior with render expectations.
- Tracks texture color-space intent so pipelines can distinguish sRGB and linear content.
- Supplies safe construction and validation helpers used by asset loading and runtime creation flows.

### [texture_atlas.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/image/texture_atlas.rs)

- Builds and maintains texture atlases that group many named regions inside one packed image.
- Uses shelf-style placement to allocate rectangles while preserving padding and bounds guarantees.
- Attaches optional nine-slice inset metadata so UI sprites can scale without corner distortion.
- Supports name-based lookup, mutation, and reset operations for dynamic atlas management.
- Exposes region geometry and atlas dimensions needed by render and layout call sites.

### [visualization/animation.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/image/visualization/animation.rs)

- Renders animation timelines and frame grids into debug images for rapid visual inspection.
- Highlights current playback position against surrounding frames to expose timing behavior.
- Draws state-oriented overlays for running, paused, and resumed playback diagnostics.
- Provides quick wrappers with sensible cell sizing for tool and test screenshot generation.
- Uses consistent color accents so active and inactive frame regions are instantly readable.

### [visualization/audio.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/image/visualization/audio.rs)

- Converts audio sample streams into waveform images suitable for tooling and in-engine diagnostics.
- Renders mono and stereo views with channel separation and baseline guides for quick interpretation.
- Supports zoom-oriented sampling views to inspect transient detail in dense signal regions.
- Adds labels and configurable color accents so waveform panels fit different UI styles.
- Normalizes peak ranges to keep amplitude visualization stable across varying source loudness.
- Shares column-based raster logic to keep waveform output deterministic and lightweight.

### [visualization/camera.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/image/visualization/camera.rs)

- Produces camera-debug imagery that visualizes framing, motion, and transform behavior in world space.
- Draws viewport boxes, crosshairs, and coordinate guides for position and anchor verification.
- Compares multiple zoom factors to reveal scale-dependent composition and clipping effects.
- Renders rotation-aware grids that expose world-to-screen mapping under angular transforms.
- Displays bounds and follow trails to inspect dead-zone tuning and target-tracking responses.
- Visualizes shake offsets against center references for temporal stability checks.
- Provides wrapper entry points for fast full-panel generation in tests and tooling flows.
- Uses hue-based color differentiation to keep layered debug signals visually distinct.

### [visualization/easing.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/image/visualization/easing.rs)

- Renders easing and curve diagnostics as image charts for motion-tuning and teaching workflows.
- Produces labeled curve galleries arranged in grids for side-by-side behavior comparison.
- Draws overlay traces that contrast multiple easing functions on shared coordinate axes.
- Includes Bezier-focused views with control-point and segment cues for shape inspection.
- Supplies advanced Bezier visualization for derivative and edit-oriented debugging scenarios.
- Uses chart backgrounds and guides that preserve readability across dense trace overlays.

### [visualization/facade.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/image/visualization/facade.rs)

- Provides shared visualization color conversion from HSV space into RGB byte tuples.
- Centralizes hue-driven palette logic used by charts, graphs, and debug overlays.
- Keeps color mapping behavior consistent across all image visualization submodules.

### [visualization/geometry.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/image/visualization/geometry.rs)

- Generates geometry-focused debug images that visualize shape algorithms and spatial relationships.
- Renders polygon galleries, primitive fills, and line rasterization examples for correctness checks.
- Shows convex hull and centroid style outputs to inspect geometric post-processing behavior.
- Illustrates intersection outcomes between segments, circles, and lines with clear overlays.
- Draws spiral and ring patterns to stress sampling consistency and color-mapping utilities.
- Provides rich visual evidence for math and geometry routines used by higher-level systems.

### [visualization/graph.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/image/visualization/graph.rs)

- Renders graph structures into diagnostic images with nodes, edges, labels, and status overlays.
- Visualizes active and removed connections using distinct styling for topology change analysis.
- Supports item-flow style arrows and annotation text for simulation and logic debugging.
- Places titles and stats summaries to contextualize rendered graph snapshots.
- Uses circle-node layouts and adjacency-driven links for readable relationship visualization.

### [visualization/image_ops.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/image/visualization/image_ops.rs)

- Composes side-by-side image operation previews for fast visual comparison of processing outputs.
- Builds slot-based layouts with scaling and padding so varied source sizes stay presentable.
- Labels each panel to make transform deltas clear during review and regression analysis.
- Includes color-wheel and transform showcase helpers for broad image-operation demonstrations.
- Keeps composite rendering deterministic for repeatable screenshot-based validation.

### [visualization/mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/image/visualization/mod.rs)

- High-level visualization module wiring that groups image-debug renderers by domain.
- Re-exports category entry points to provide one flat surface for visualization consumers.
- Shares internal facade utilities while keeping submodule responsibilities clearly separated.

### [visualization/noise.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/image/visualization/noise.rs)

- Turns scalar noise functions into image outputs for terrain tuning and generator diagnostics.
- Renders normalized and raw grayscale maps to compare contrast handling across noise sources.
- Provides biome and elevation band coloring to inspect threshold-driven terrain classification.
- Supports sliced and tiled comparison views for spotting artifacts across parameter variations.
- Keeps sampling and raster paths deterministic for stable test and documentation visuals.

### [visualization/procgen.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/image/visualization/procgen.rs)

- Visualizes procedural-generation data structures as images for analysis and tuning loops.
- Renders cellular grids, dungeon maps, and occupancy states with configurable color semantics.
- Draws Voronoi and Delaunay style outputs to inspect spatial partition behavior.
- Displays point samples and topology overlays for algorithm-step debugging.
- Provides compact visual proof artifacts for procgen experimentation and regression checks.

### [visualization/ui.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/image/visualization/ui.rs)

- Renders UI-oriented mockups into images to preview panel composition and widget styling.
- Draws settings-style panels with controls, sliders, and button affordances for layout checks.
- Produces HUD bars and cooldown visuals used to validate gameplay HUD readability.
- Includes swatches and progress widgets for color and status presentation experiments.
- Supplies deterministic UI snapshots useful in examples, tests, and design iteration loops.
