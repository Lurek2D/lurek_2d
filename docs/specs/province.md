# province

## TL;DR

- Province is a GENERIC rendering/property system. Economy logic lives in `library/province_economy/`.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/province/`
- Lua API path(s): `src/lua_api/province_api.rs`
- Primary Lua namespace: `lurek.province`
- Rust test path(s): tests/rust/unit/province_tests.rs
- Lua test path(s): None found in the workspace

## Summary

The `province` module is an advanced Edge/Integration tier subsystem that provides a complete, engine-native province map runtime, tailor-made for grand strategy and map-painting games in Lurek2D. Operating independently of tilemaps, it manages irregular, pixel-perfect regions using a `ProvinceRegistry`. This registry acts as the central source of truth, storing metadata for each province—including ownership, terrain type, border styles, capital coordinates, label anchors, and arbitrary string attributes. At its core, the registry maintains a `ProvinceGraph` that tracks undirected adjacencies, allowing for rapid topological queries (e.g., neighbor enumeration) and game-defined border types registered from Lua (e.g., land, coast, river — defined per-game rather than hardcoded).

A standout feature of the module is its highly optimized rendering pipeline. To avoid the overhead of per-pixel evaluation at runtime, a `ProvinceGeometryCache` pre-computes horizontal cell spans, bounding boxes, and border line segments. These structures are packed into a `ProvinceGpuRecord` (a std430-friendly 32-byte payload) for direct GPU upload. Rendering is driven by customizable `ProvinceMapMode`s (such as Political, Terrain, or Visibility), mapping a `ProvinceStyle` to specific fill colors. The module handles viewport culling, screen-to-map transformations, and zoom-to-anchor logic, seamlessly generating render commands for solid fills, border strokes, capital icons, and shadowed text labels.

Border rendering also supports per-adjacency overrides through `setBorderPairStyle(a, b, style)`. A style can define an optional RGBA override color, a custom line thickness, and semantic flags (`country`, `alliance`, `war`, `truce`). Strategic view can filter to coastlines and country-marked borders, while tactical view draws full detail. Tactical mode can also emit road segments between capitals of visible adjacent provinces.

The import pipeline is equally robust, automatically converting color-coded PNG maps and RGB CSV metadata into structured registry data. It includes a marker sanitization step that strips out capital (near-white) and label (magenta) pixels, reassigning them to the correct province while computing optimal label line vectors via expanding-ring neighbor searches. To support game logic, the registry employs a monotonic revision counter and change-stream (`get_changes_since`), emitting fine-grained deltas whenever a province's color, terrain, or fog state mutates. Exposed entirely through the `lurek.province.*` API, this module provides the complex topological, visual, and event-driven infrastructure required for high-performance interactive cartography.

### Visibility Rendering Contract

- `visibility_state = 0`: hidden. The renderer skips province fill, border, capital marker, and label.
- `visibility_state = 1`: discovered. The renderer emits only a gray fill (no border, capital, or label).
- `visibility_state >= 2`: fully visible. The renderer emits normal map-mode fill and full details.
- Border segments render only when both adjacent provinces are fully visible (`>= 2`).

## Source Documentation

### `border_index.rs`
- Precompute border-pair index map from province id grid.
- Assigns a stable u16 pair id for each detected border pixel.
- Optional dilation expands border coverage for thick styled borders.

### `borders.rs`
- Province border geometry: border index map, dilation, and edge detection.
- `build_border_index` converts a raw province-ID grid into a border pixel mask.
- `dilate_border_index_with_styles` expands border pixels by per-pair style thickness.
- `build_border_index_from_registry` reads the current registry pixel buffer directly.
- Output is an `R16Uint` texture uploaded via `province::gpu_upload`.

### `cache.rs`
- Serialisable geometry cache for province spans and border segments.
- Binary encode/decode with versioned little-endian format.
- Built from a ProvinceRegistry snapshot for fast load without re-scanning.

### `distance_field.rs`
- Distance-from-border precompute for province pixels.
- Multi-source BFS seeded from border pixels where neighboring province ids differ.
- Produces a compact u8 field used by later shading or LOD passes.

### `events.rs`
- Change-log entries for single-field province mutations (colour, terrain, border, fog, visibility).
- High-level map events emitted to Lua callbacks after batched province updates.
- Typed signals for map-mode switches, palette replacements, and fog overlays.

### `gpu_bridge.rs`
- GPU-uploadable province data bridge between registry and render pipeline.
- Packs province style fields into a repr(C) record for direct buffer upload.
- Builds sorted record arrays from the province registry for deterministic GPU ordering.

### `gpu_upload.rs`
- Province GPU upload helpers for id, border-index, and distance-field textures.
- Consistent texture descriptors for `R32Uint`, `R16Uint`, and `R8Unorm` data.
- Byte packing utilities used by upload paths and unit tests.

### `import.rs`
- Province metadata import pipeline: colour-map PNG + RGB CSV + optional TOML → registry.
- Marker PNG sanitization: replace capital and label marker pixels with nearest non-marker neighbour.
- RGB colour CSV parsing mapping packed (R,G,B) tuples to numeric game_id values.
- TOML province info parsing for display name and terrain token fields.
- Pixel-level marker detection with configurable thresholds for capital (near-white) and label (magenta) markers.
- Expanding-ring neighbour search to resolve marker pixel ownership from surrounding province colours.
- Deterministic political colour derivation from game_id with fixed sea-blue for water provinces.
- Label line extraction: find longest-distance pair from label marker point clusters per province.
- Full import pipeline wiring terrain type, political colour, attributes, capitals, and label lines into the registry.

### `labels.rs`
- Compute pixel-weighted centroids from province span data.
- Map province IDs to their geometric center for label placement.
- Accumulates pixel-weighted x/y sums across span rows and normalises per province area.

### `map_modes.rs`
- Config-driven map mode system for the province renderer.
- Map modes are registered from Lua at runtime with per-mode display settings.
- Color resolution uses the color_property field from the active map mode config.

### `mod.rs`
- Province map system: registry, geometry cache, GPU bridge, and rendering.
- Imports colour-map PNG + CSV/TOML metadata into an authoritative ProvinceRegistry.
- Generates RenderCommands for fills, borders, capitals, and text labels.
- Provides view-transform helpers for camera fitting and screen-to-map projection.

### `properties.rs`
- Province property storage: per-province key-value metadata and stat tables.
- `ProvinceProperties` maps `ProvinceId → HashMap<String, PropertyValue>`.
- `PropertyValue` is an enum covering `Int`, `Float`, `Bool`, and `Text` variants.
- Properties are set from Lua via `lurek.province.set_property(id, key, value)`.
- Serialized into the save file as a flat list for fast round-trip loading.

### `province_grid.rs`
- Province grid construction from color-mapped images, assigning unique ids per distinct RGB color.
- Pixel-level province id lookup and reverse color retrieval by id.
- Adjacency detection between neighboring provinces with shared-border-pixel counts.
- Horizontal span extraction for contiguous province row segments.
- Border segment detection returning line segments between differing province regions.
- Polygon tracing from directed cell edges into closed point loops per province.
- Polygon simplification removing collinear vertices and 45-degree staircase patterns.
- Binary serialization and deserialization of span and border segment shape data.
- Adjacency pair struct exposing province relationships for map graph queries.

### `registry.rs`
- Central province registry: owns pixel grid, span runs, adjacency graph, and per-province records.
- Builds from a ProvinceGrid or PNG colour-map; computes spans, bounding boxes, and centroids.
- Provides fast lookup by pixel coordinate, province id, or bounding box.
- Manages mutable province style (political colour, terrain, fog, visibility, border style).
- Stores capital positions, label anchor lines, and label text per province.
- Tracks adjacency via ProvinceGraph and exposes neighbour and pair queries.
- Maintains a monotonic revision counter and ordered change log for incremental sync.
- Supports border class overrides keyed by normalised province pair.
- Stores arbitrary string key-value attributes per province via set_attr.

### `render.rs`
- Province map rendering: convert registry data into a flat RenderCommand list.
- Viewport culling based on screen bounds and zoom/pan transform.
- Fill rendering via per-province span rectangles coloured by the active map mode.
- Border rendering with config-based color from registered border types.
- Capital dot markers and text labels with shadow offset.
- Hover and selection highlight outlines for interactive feedback.

### `topology.rs`
- Undirected adjacency graph storing sorted neighbour lists per province.
- Rebuild from raw id pairs with dedup and self-loop filtering.
- Binary-search-based neighbour lookup and adjacency queries.
- Extraction of all province ids and unique adjacency pairs.

### `types.rs`
- Core type definitions for the province map system.
- ProvinceId newtype, BorderType (u8) for game-defined adjacency classification, and ProvinceStyle for per-province visuals.
- ProvinceSnapshot provides an immutable point-in-time view of province state.

### `view_transform.rs`
- Camera fitting, zoom-at-anchor, and coordinate conversion between screen, map, and cell space.
- Screen-to-map and map-to-cell transforms with safe clamping for zero-size or non-finite inputs.
- All functions are pure (no state); denominators clamped to avoid division by zero.

## Types

- `ProvinceBorderIndex` (`struct`, `border_index.rs`): Dense per-pixel border pair index map.
- `ProvinceGeometryCache` (`struct`, `cache.rs`): Cache blob of precomputed province geometry.
- `ProvinceDistanceField` (`struct`, `distance_field.rs`): Per-pixel distance to nearest province border, clamped to `max_distance`.
- `ProvinceChange` (`enum`, `events.rs`): Fine-grained field updates emitted by the province registry.
- `ProvinceEvent` (`enum`, `events.rs`): High-level province events for subscribers.
- `ProvinceGpuRecord` (`struct`, `gpu_bridge.rs`): GPU packed province row (std430-friendly 32-byte payload).
- `BorderStyleGpuRecord` (`struct`, `gpu_bridge.rs`): Per-border-pair GPU style record laid out for direct storage-buffer upload.
- `ProvinceGpuTextures` (`struct`, `gpu_upload.rs`): GPU texture bundle used by the province map renderer.
- `MarkerSanitizeOptions` (`struct`, `import.rs`): Thresholds for detecting capital and label marker pixels in a marker PNG.
- `MarkerSanitizeSummary` (`struct`, `import.rs`): Result counters returned by sanitize_marked_png.
- `ProvinceMetadataImportOptions` (`struct`, `import.rs`): Options for the full metadata import pipeline run by import_metadata_from_files.
- `ProvinceMetadataImportSummary` (`struct`, `import.rs`): Result counters returned by import_metadata_from_files.
- `MapModeConfig` (`struct`, `map_modes.rs`): Configuration for a named map display mode, registered from Lua.
- `MapModeRegistry` (`struct`, `map_modes.rs`): Registry of map modes, keyed by name string.
- `ProvinceProperties` (`struct`, `properties.rs`): Generic per-province key-value property store (numeric, string, flags).
- `AdjacencyPair` (`struct`, `province_grid.rs`): Adjacency summary for two provinces and the number of shared border pixels.
- `ProvinceShapeCacheEntry` (`struct`, `province_grid.rs`): Cached province polygon draw data with color, bounds, and flattened vertices.
- `ProvinceGrid` (`struct`, `province_grid.rs`): Province id grid derived from image colors and cached geometry.
- `ProvinceRecord` (`struct`, `registry.rs`): Runtime state for one province row.
- `ProvinceRegistry` (`struct`, `registry.rs`): Full province dataset with revisioned change history.
- `ProvinceZoomMode` (`enum`, `render.rs`): Strategic/tactical map rendering mode.
- `ProvinceRenderOptions` (`struct`, `render.rs`): Render options for one province map pass.
- `ProvinceGraph` (`struct`, `topology.rs`): Undirected adjacency graph between provinces.
- `ProvinceId` (`struct`, `types.rs`): Province identifier used across province/globe/minimap modules.
- `BorderType` (`type`, `types.rs`): Game-defined border type identifier (u8). Registered via `registerBorderType` from Lua.
- `BorderTypeConfig` (`struct`, `types.rs`): Per border-type visual config (name, color, thickness, draw_priority).
- `BorderPairFlags` (`struct`, `types.rs`): Bit-flag set controlling semantic styling of a border pair override.
- `BorderPairStyle` (`struct`, `types.rs`): Per-adjacency border style override keyed by ordered province pair.
- `ProvinceStyle` (`struct`, `types.rs`): Mutable style/state attached to one province.
- `ProvinceSnapshot` (`struct`, `types.rs`): Immutable read model consumed by other modules.

## Functions

- `ProvinceBorderIndex::at` (`border_index.rs`): Return pair id at (x, y), or None when out of bounds.
- `ProvinceBorderIndex::pair_count` (`border_index.rs`): Return number of unique province pairs referenced by this index.
- `build_border_index` (`border_index.rs`): Build border index map from raw province id grid.
- `dilate_border_index_with_styles` (`border_index.rs`): Expand border pixels by radius per pair style thickness.
- `build_border_index_from_registry` (`border_index.rs`): Build border index map directly from current registry pixel grid.
- `ProvinceGeometryCache::from_registry` (`cache.rs`): Build a cache by copying spans and border_segments from the given registry.
- `ProvinceGeometryCache::encode` (`cache.rs`): Serialise to a versioned little-endian byte buffer; always succeeds.
- `ProvinceGeometryCache::decode` (`cache.rs`): Deserialise from a byte buffer produced by encode; return None on magic mismatch or truncation.
- `ProvinceDistanceField::at` (`distance_field.rs`): Return field value at (x, y), or None when out of bounds.
- `compute_distance_field` (`distance_field.rs`): Compute distance-to-border field from a raw province id grid.
- `compute_distance_field_from_registry` (`distance_field.rs`): Build a distance field directly from the current registry pixel grid.
- `build_gpu_records` (`gpu_bridge.rs`): Builds a sorted GPU record table from registry contents.
- `build_border_style_gpu_records` (`gpu_bridge.rs`): Build border style GPU records aligned to `ProvinceBorderIndex::id_to_pair`.
- `pack_u32_pixels_le` (`gpu_upload.rs`): Pack `u32` row-major pixels into little-endian bytes for `R32Uint` uploads.
- `pack_u16_pixels_le` (`gpu_upload.rs`): Pack `u16` row-major pixels into little-endian bytes for `R16Uint` uploads.
- `create_province_id_texture` (`gpu_upload.rs`): Create and upload province id map texture (`R32Uint`).
- `create_border_index_texture` (`gpu_upload.rs`): Create and upload border index texture (`R16Uint`).
- `create_distance_field_texture` (`gpu_upload.rs`): Create and upload distance field texture (`R8Unorm`).
- `create_province_gpu_textures` (`gpu_upload.rs`): Create all core province textures in one call.
- `sanitize_marked_png` (`import.rs`): Replace capital and label marker pixels with their nearest non-marker neighbour and write the result to output_png_path; return pixel counts or an error string.
- `import_metadata_from_files` (`import.rs`): Import province metadata from colour-map PNG, RGB CSV, and optional TOML/marker files into registry; return counts or an error string.
- `centroids_from_spans` (`labels.rs`): Computes centroid candidates from fill spans.
- `MapModeRegistry::new` (`map_modes.rs`): Create a new registry with a default "political" mode.
- `MapModeRegistry::register` (`map_modes.rs`): Register a named map mode config.
- `MapModeRegistry::set_active` (`map_modes.rs`): Set the active map mode by name.
- `MapModeRegistry::active_name` (`map_modes.rs`): Get the currently active map mode name.
- `MapModeRegistry::active_config` (`map_modes.rs`): Get the active map mode config.
- `MapModeRegistry::get_config` (`map_modes.rs`): Get config for a named map mode.
- `MapModeRegistry::mode_names` (`map_modes.rs`): List all registered mode names.
- `resolve_color_fallback` (`map_modes.rs`): Resolve fill colour for a province given the active mode's config and the province style.
- `ProvinceProperties::new` (`properties.rs`): Create a new empty property store with no province data.
- `ProvinceProperties::set_numeric` (`properties.rs`): Set a named numeric value for the given province.
- `ProvinceProperties::get_numeric` (`properties.rs`): Get the named numeric value for a province, or `None` if not set.
- `ProvinceProperties::set_string` (`properties.rs`): Set a named string attribute for the given province.
- `ProvinceProperties::get_string` (`properties.rs`): Get the named string attribute for a province, or `None` if not set.
- `ProvinceProperties::set_flag` (`properties.rs`): Set or clear a bitfield flag (0-63) for the given province.
- `ProvinceProperties::has_flag` (`properties.rs`): Return `true` if the specified bitfield flag is set for the given province.
- `ProvinceProperties::clear_province` (`properties.rs`): Remove all numeric, string, and flag data stored for the given province.
- `ProvinceProperties::province_ids` (`properties.rs`): Return a sorted list of all province IDs that have any stored properties.
- `ProvinceGrid::from_image` (`province_grid.rs`): Build a province grid from an image where non-black pixels define province ids.
- `ProvinceGrid::from_file` (`province_grid.rs`): Load an image from disk and derive province ids from it.
- `ProvinceGrid::width` (`province_grid.rs`): Return the grid width in pixels.
- `ProvinceGrid::height` (`province_grid.rs`): Return the grid height in pixels.
- `ProvinceGrid::get_at` (`province_grid.rs`): Return the province id at a coordinate, or `0` when out of bounds.
- `ProvinceGrid::province_count` (`province_grid.rs`): Return the highest province id present in the grid.
- `ProvinceGrid::province_color` (`province_grid.rs`): Return the RGB color associated with a province id, or `None` for id 0.
- `ProvinceGrid::adjacencies` (`province_grid.rs`): Return cached adjacency triples for the grid.
- `ProvinceGrid::province_spans` (`province_grid.rs`): Return horizontal spans for each province row segment.
- `ProvinceGrid::border_segments` (`province_grid.rs`): Return contiguous border segments between differing provinces.
- `ProvinceGrid::province_polygons` (`province_grid.rs`): Trace province polygons as ordered point loops.
- `ProvinceGrid::province_polygons_simplified` (`province_grid.rs`): Return simplified province polygons with redundant vertices removed.
- `ProvinceGrid::build_shape_cache` (`province_grid.rs`): Build a simplified polygon shape cache for efficient drawing.
- `ProvinceGrid::serialize_shape_data` (`province_grid.rs`): Serialize spans and border segments into a compact binary blob.
- `ProvinceGrid::deserialize_shape_data` (`province_grid.rs`): Decode serialized spans and border segments from a shape-data blob.
- `ProvinceRegistry::new` (`registry.rs`): Return a new empty registry with zero dimensions and no provinces.
- `ProvinceRegistry::from_grid` (`registry.rs`): Build a registry from a pre-parsed ProvinceGrid, computing spans, adjacency, and centroids.
- `ProvinceRegistry::from_png` (`registry.rs`): Build a registry by loading a province colour-map PNG from path; return error on I/O or decode failure.
- `ProvinceRegistry::width` (`registry.rs`): Return the width of the source map in pixels.
- `ProvinceRegistry::height` (`registry.rs`): Return the height of the source map in pixels.
- `ProvinceRegistry::get_at` (`registry.rs`): Return the province id at pixel (x, y); returns 0 if coordinates are out of bounds.
- `ProvinceRegistry::revision` (`registry.rs`): Return the current revision counter; increases by one on each mutation.
- `ProvinceRegistry::province_ids` (`registry.rs`): Return all known province ids sorted ascending.
- `ProvinceRegistry::province_count` (`registry.rs`): Return the number of provinces currently in the registry.
- `ProvinceRegistry::get_province` (`registry.rs`): Return a snapshot of the province's style and metadata, or None if id is unknown.
- `ProvinceRegistry::get_neighbors` (`registry.rs`): Return the sorted neighbour list for id as a Vec; returns empty Vec if id has no adjacencies.
- `ProvinceRegistry::adjacency_pairs` (`registry.rs`): Return all unique adjacency pairs (a < b) sorted ascending.
- `ProvinceRegistry::spans` (`registry.rs`): Return all span runs as a slice: (id, row_y, x_start, x_end_exclusive).
- `ProvinceRegistry::border_segments` (`registry.rs`): Return all border segments as a slice: (id_a, id_b, x0, y0, x1, y1).
- `ProvinceRegistry::spans_for` (`registry.rs`): Return the span runs for a single province as (row_y, x_start, x_end_exclusive), or None if unknown.
- `ProvinceRegistry::bbox_for` (`registry.rs`): Return the axis-aligned bounding box (min_x, min_y, max_x, max_y) for id, or None if unknown.
- `ProvinceRegistry::style_for` (`registry.rs`): Return a reference to the style for id, or None if id is unknown.
- `ProvinceRegistry::set_capital` (`registry.rs`): Set the capital position for id; return false if id is unknown.
- `ProvinceRegistry::capital_for` (`registry.rs`): Return the capital position for id, or None if not set or id is unknown.
- `ProvinceRegistry::set_label_line` (`registry.rs`): Set the label anchor line for id from (ax, ay) to (bx, by); return false if id is unknown.
- `ProvinceRegistry::label_line_for` (`registry.rs`): Return the label line for id as ((x0,y0),(x1,y1)), or None if not set or id is unknown.
- `ProvinceRegistry::set_label_text` (`registry.rs`): Set the display label text for id; return false if id is unknown.
- `ProvinceRegistry::label_text_for` (`registry.rs`): Return the label text for id as a str slice, or None if not set or id is unknown.
- `ProvinceRegistry::get_changes_since` (`registry.rs`): Return all change log entries with revision > since_revision.
- `ProvinceRegistry::set_political_color` (`registry.rs`): Set the political fill colour for id and record a PoliticalColor change; return false if id is unknown.
- `ProvinceRegistry::set_terrain_type` (`registry.rs`): Set the terrain type index for id and record a TerrainType change; return false if id is unknown.
- `ProvinceRegistry::set_border_style` (`registry.rs`): Set the border style index for id and record a BorderStyle change; return false if id is unknown.
- `ProvinceRegistry::set_fog_state` (`registry.rs`): Set the fog state byte for id and record a FogState change; return false if id is unknown.
- `ProvinceRegistry::set_visibility_state` (`registry.rs`): Set the visibility state byte for id and record a VisibilityState change; return false if id is unknown.
- `ProvinceRegistry::set_border_type` (`registry.rs`): Set the border type for the (a, b) pair and record a BorderType change.
- `ProvinceRegistry::get_border_type` (`registry.rs`): Return the stored border type for the (a, b) pair, or None if not explicitly set.
- `ProvinceRegistry::register_border_type` (`registry.rs`): Register a border type config by ID.
- `ProvinceRegistry::get_border_type_config` (`registry.rs`): Return the config for a border type ID, or None if not registered.
- `ProvinceRegistry::set_border_pair_style` (`registry.rs`): Set the border pair style for (a, b) and record a BorderPairStyle change.
- `ProvinceRegistry::get_border_pair_style` (`registry.rs`): Return the stored border pair style for (a, b), or None if not explicitly set.
- `ProvinceRegistry::set_attr` (`registry.rs`): Insert a key-value string attribute for id; return false if id is unknown.
- `ProvinceRegistry::register_map_mode` (`registry.rs`): Register a named map mode config.
- `ProvinceRegistry::set_map_mode` (`registry.rs`): Set the active map mode by name.
- `ProvinceRegistry::active_map_mode` (`registry.rs`): Get the currently active map mode name.
- `ProvinceRegistry::map_mode_config` (`registry.rs`): Get the active map mode config.
- `ProvinceRegistry::get_map_mode_config` (`registry.rs`): Get config for a named map mode.
- `generate_render_commands` (`render.rs`): Generates render commands for one province map frame.
- `ProvinceGraph::new` (`topology.rs`): Return a new empty graph.
- `ProvinceGraph::rebuild_from_pairs` (`topology.rs`): Rebuild the graph from a slice of adjacent id pairs; clears previous data.
- `ProvinceGraph::neighbors_of` (`topology.rs`): Return the sorted neighbour slice for id; returns an empty slice if id has no entry.
- `ProvinceGraph::is_adjacent` (`topology.rs`): Return true if a and b share a border in the graph.
- `ProvinceGraph::province_ids` (`topology.rs`): Return all province ids present in the graph, sorted ascending.
- `ProvinceGraph::adjacency_pairs` (`topology.rs`): Return all unique adjacency pairs (a < b) sorted ascending.
- `ProvinceId::new` (`types.rs`): Creates a new ProvinceId from a raw u32.
- `ProvinceId::raw` (`types.rs`): Returns the raw u32 underlying value.
- `BorderPairFlags::empty` (`types.rs`): Create a new empty border flag set.
- `BorderPairFlags::bits` (`types.rs`): Return the raw flag bit pattern.
- `BorderPairFlags::from_bits` (`types.rs`): Build a flag set from raw bits.
- `BorderPairFlags::insert_bits` (`types.rs`): Insert a raw flag bitmask into this set.
- `BorderPairFlags::contains_bits` (`types.rs`): Return true if all bits from mask are present.
- `BorderPairFlags::parse_token` (`types.rs`): Parse a single canonical flag token.
- `BorderPairFlags::to_tokens` (`types.rs`): Return canonical tokens for all set bits.
- `fit_camera_to_screen` (`view_transform.rs`): Computes camera transform that fits the full province map inside the screen.
- `screen_to_map` (`view_transform.rs`): Converts a screen-space position to map-space pixel coordinates.
- `map_to_cell` (`view_transform.rs`): Converts map-space coordinates to a 0-based integer cell when inside bounds.
- `zoom_camera_at` (`view_transform.rs`): Recomputes camera origin so zooming keeps a screen anchor fixed.

## Lua API Reference

- Binding path(s): `src/lua_api/province_api.rs`
- Namespace: `lurek.province`

### Module Functions
- `lurek.province.newFromPng`: Creates a new province registry by loading a color-coded PNG where each unique color represents a distinct province. The PNG is parsed into a grid and adjacencies are computed automatically.
- `lurek.province.sanitizeMarkedPng`: Pre-processes a marker PNG by replacing capital and label marker pixels with the surrounding province color. Outputs a cleaned PNG suitable for `newFromPng`. Returns a summary of pixel replacements.
- `lurek.province.get`: Retrieves an existing province registry by name. Returns nil if no registry with that name has been created.
- `lurek.province.exists`: Checks whether a province registry with the given name exists.
- `lurek.province.remove`: Removes a province registry by name and clears the active registry if it was the one removed. Returns true if a registry was actually removed.
- `lurek.province.setActive`: Sets the named registry as the active province registry. Returns false if no registry with that name exists.
- `lurek.province.getActive`: Returns the currently active province registry, or nil if none is set.
- `lurek.province.zoomCameraAt`: Computes new camera position after zooming centered on an anchor point. Keeps the anchor point visually stationary on screen while the zoom level changes.
- `lurek.province.setProperty`: Sets a numeric property on a province. Game logic defines the semantics of each key.
- `lurek.province.getProperty`: Gets a numeric property from a province. Returns nil if not set.
- `lurek.province.setAttr`: Sets a string attribute on a province.
- `lurek.province.getAttr`: Gets a string attribute from a province. Returns nil if not set.
- `lurek.province.setFlag`: Sets a single flag bit (0–63) on a province.
- `lurek.province.hasFlag`: Checks whether a flag bit is set on a province.
- `lurek.province.clearProperties`: Removes all properties, attributes, and flags for a province.

### `LProvinceRegistry` Methods
- `LProvinceRegistry:getName`: Returns the string name used to identify this registry in the province system.
- `LProvinceRegistry:getWidth`: Returns the width of the province grid in cells (pixels of the source PNG).
- `LProvinceRegistry:getHeight`: Returns the height of the province grid in cells (pixels of the source PNG).
- `LProvinceRegistry:getAt`: Returns the province ID at the given grid cell coordinates. Returns 0 if the cell is unowned (sea, wasteland, etc.).
- `LProvinceRegistry:fitCamera`: Computes camera position and zoom so the entire province map fits within the given screen dimensions.
- `LProvinceRegistry:screenToMap`: Converts screen-space pixel coordinates to map-space floating-point coordinates using the current camera transform.
- `LProvinceRegistry:screenToProvince`: Converts screen-space coordinates directly to a province ID. Returns nil if the cursor is outside the map or over an unowned cell.
- `LProvinceRegistry:provinceCount`: Returns the total number of distinct provinces in this registry (excluding ID 0).
- `LProvinceRegistry:provinceIds`: Returns a sequential table of all province IDs in this registry.
- `LProvinceRegistry:adjacencies`: Returns all adjacency pairs in the registry. Each entry has `province_a` and `province_b` fields representing two neighboring provinces.
- `LProvinceRegistry:provinceSpans`: Returns the raw span data for all provinces. Each span is a horizontal run of cells belonging to one province, useful for custom rendering or spatial analysis.
- `LProvinceRegistry:borderSegments`: Returns all border line segments between adjacent provinces. Each segment is a line from (x0,y0) to (x1,y1) separating province_a from province_b.
- `LProvinceRegistry:getRevision`: Returns the current change revision counter. Incremented on every mutation (color, terrain, border, fog changes). Use with `getChangesSince` for incremental updates.
- `LProvinceRegistry:getProvince`: Returns a snapshot table describing a single province: its ID, revision, style (political_color, terrain_type, border_style, fog_state, visibility_state), centroid, and custom attributes.
- `LProvinceRegistry:getNeighbors`: Returns a table of province IDs that share a border with the given province.
- `LProvinceRegistry:getBorderType`: Returns the border type ID (0-255) between two adjacent provinces, or nil if not set.
- `LProvinceRegistry:setBorderType`: Sets the border type ID between two adjacent provinces. Register types first with registerBorderType.
- `LProvinceRegistry:getBorderClass`: Backward-compatible alias for getBorderType. Returns the border type ID.
- `LProvinceRegistry:setBorderClass`: Backward-compatible alias for setBorderType. Sets the border type ID.
- `LProvinceRegistry:registerBorderType`: Registers a border type config by ID. Defines visual appearance for borders of this type.
- `LProvinceRegistry:setBorderPairStyle`: Sets the style override for a specific adjacency pair, including optional color, thickness, and semantic flags.
- `LProvinceRegistry:getBorderPairStyle`: Returns the style override for a specific adjacency pair, or nil when unset.
- `LProvinceRegistry:setPoliticalColor`: Sets the political map color for a province. Used in political map mode rendering and change tracking.
- `LProvinceRegistry:setTerrainType`: Sets the terrain type index for a province. Terrain type controls which fill color or texture is used in terrain map mode.
- `LProvinceRegistry:setBorderStyle`: Sets the border rendering style index for a province. Controls line thickness, color, or pattern when borders are drawn.
- `LProvinceRegistry:setFogState`: Sets a fog-of-war byte for a province. This value is game-defined metadata and can be used by scripts/map modes.
- `LProvinceRegistry:setVisibilityState`: Sets the render visibility state for a province. `0` = hidden (no fill/border/capital/label), `1` = discovered (gray fill only), `2+` = fully visible.
- `LProvinceRegistry:setAttr`: Sets a custom string attribute on a province. Attributes are returned in the `attrs` table of `getProvince` and can store arbitrary game metadata.
- `LProvinceRegistry:setCapital`: Sets the capital marker position for a province. The capital is drawn as a small icon during `render` when `draw_capitals` is enabled.
- `LProvinceRegistry:setLabelLine`: Sets the label baseline for a province. The label text is rendered along the line from (ax,ay) to (bx,by), allowing curved or angled province names.
- `LProvinceRegistry:setLabelText`: Sets the display name text for a province. Rendered on the map when `draw_labels` is enabled in `render` options.
- `LProvinceRegistry:importMetadataFromFiles`: Bulk-imports province metadata (colors, capitals, labels, terrain) from external files (PNG color map, CSV color table, TOML province definitions, marker PNG). Returns a summary of how many provinces were mapped.
- `LProvinceRegistry:render`: Renders the province map to the screen using the current camera and style settings. Generates draw commands for fills, borders, labels, and capitals based on the provided options.
- `LProvinceRegistry:getChangesSince`: Returns all province changes that occurred after the given revision. Each entry contains the revision number and a change record describing what was modified (political_color, terrain_type, border_style, fog_state, visibility_state, or border_class).
- `LProvinceRegistry:registerMapMode`: Registers a named map mode with display configuration. Overwrites if name exists.
- `LProvinceRegistry:setMapMode`: Switches the active map mode to a previously registered mode name.
- `LProvinceRegistry:getMapMode`: Returns the name of the currently active map mode.
- `LProvinceRegistry:type`: Returns the type name string for this userdata object.
- `LProvinceRegistry:typeOf`: Checks whether this object matches the given type name. Returns true for "LProvinceRegistry" and "Object".

## References

- `image`: Imports or references `src/image/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.
- `render`: Imports or references `src/render/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Edge/Integration` into `Core Runtime`.

## Notes

- `library/province_map/init.lua` uses engine-backed mode through `lurek.province`
  when available and falls back to `lurek.image.newProvinceGrid` otherwise.
- The module is prepared for GPU compositing pipelines via `province::gpu_bridge`.
- `province::render` generates `RenderCommand` batches in Rust (fills, borders,
  capitals, labels, hover/selection outlines) so Lua does not need per-pixel
  or per-span render loops.
