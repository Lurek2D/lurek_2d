# province

## TL;DR

- The module now also includes a local-only province economy domain model in `economy.rs`.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/province/`
- Lua API path(s): `src/lua_api/province_api.rs`
- Primary Lua namespace: `lurek.province`
- Rust test path(s): tests/rust/unit/province_tests.rs and tests/rust/unit/province_economy_tests.rs
- Lua test path(s): None found in the workspace

## Summary

The `province` module is an advanced Edge/Integration tier subsystem that provides a complete, engine-native province map runtime, tailor-made for grand strategy and map-painting games in Lurek2D. Operating independently of tilemaps, it manages irregular, pixel-perfect regions using a `ProvinceRegistry`. This registry acts as the central source of truth, storing metadata for each province—including ownership, terrain type, border styles, capital coordinates, label anchors, and arbitrary string attributes. At its core, the registry maintains a `ProvinceGraph` that tracks undirected adjacencies, allowing for rapid topological queries (e.g., neighbor enumeration) and sophisticated border classification (e.g., distinguishing land-land borders from coastlines or sea-sea boundaries).

### `economy.rs`
- Province economy state model with local stockpiles for population, food, and gold.
- Monthly tick helpers for food demand, tax generation, growth, happiness pressure, and migration pressure.
- Local-only monthly resolution that consumes and spends only provincial stockpiles.
- Daily logistics planning for upstream gold and downstream food using adjacency shortest paths.
- In-transit shipment model with day-by-day delivery to destination stockpiles.

A standout feature of the module is its highly optimized rendering pipeline. To avoid the overhead of per-pixel evaluation at runtime, a `ProvinceGeometryCache` pre-computes horizontal cell spans, bounding boxes, and border line segments. These structures are packed into a `ProvinceGpuRecord` (a std430-friendly 32-byte payload) for direct GPU upload. Rendering is driven by customizable `ProvinceMapMode`s (such as Political, Terrain, or Visibility), mapping a `ProvinceStyle` to specific fill colors. The module handles viewport culling, screen-to-map transformations, and zoom-to-anchor logic, seamlessly generating render commands for solid fills, border strokes, capital icons, and shadowed text labels.

### Economy Loop Contract

- `population`, `food_stockpile`, and `gold_stockpile` are province-local state.
- Monthly economy resolution and daily shipment transport are separate operations.
- Upkeep and construction spending consume only local gold.
- Food consumption consumes only local food.
- Shipment launch is valid only when the origin node physically holds the requested cargo.
- Gold flow is planned upstream (province/hub -> parent), food flow downstream (parent -> province in deficit).
- No empire-wide shared hidden pool is used by the economy model.

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
- Classify shared borders between adjacent provinces by terrain type.
- Map land/water combinations to discrete border classes (land-land, coast, sea-sea).
- Provide a single pure function with no side effects for pipeline integration.

### `cache.rs`
- Serialisable geometry cache for province spans and border segments.
- Binary encode/decode with versioned little-endian format.
- Built from a ProvinceRegistry snapshot for fast load without re-scanning.

### `distance_field.rs`
- Distance-from-border precompute for province pixels.
- Multi-source BFS seeded from border pixels where neighboring province ids differ.
- Produces a compact u8 field used by later shading or LOD passes.

### `economy.rs`
- Province economy domain model with local-only stockpiles (population, food, gold).
- Monthly economy tick: food consumption, local upkeep, growth, happiness pressure, and tax.
- Daily logistics planning: upstream gold, downstream food, and physical shipment movement.
- No hidden empire-wide pool; all launches require cargo present at the origin node.

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

### `map_modes.rs`
- Map-mode enum selecting which province style field drives fill colour.
- Colour resolution logic mapping political, terrain, and visibility modes to RGBA.
- String round-trip helpers for mode serialisation and Lua interop.

### `mod.rs`
- Province map system: registry, geometry cache, GPU bridge, and rendering.
- Imports colour-map PNG + CSV/TOML metadata into an authoritative ProvinceRegistry.
- Generates RenderCommands for fills, borders, capitals, and text labels.
- Provides view-transform helpers for camera fitting and screen-to-map projection.

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
- Border rendering with colour classification (land-land, coast, sea-sea, special).
- Capital dot markers and text labels with shadow offset.
- Hover and selection highlight outlines for interactive feedback.

### `topology.rs`
- Undirected adjacency graph storing sorted neighbour lists per province.
- Rebuild from raw id pairs with dedup and self-loop filtering.
- Binary-search-based neighbour lookup and adjacency queries.
- Extraction of all province ids and unique adjacency pairs.

### `types.rs`
- Core type definitions for the province map system.
- ProvinceId alias, BorderClass enum for adjacency classification, and ProvinceStyle for per-province visuals.
- ProvinceSnapshot provides an immutable point-in-time view of province state.

### `view_transform.rs`
- Camera fitting, zoom-at-anchor, and coordinate conversion between screen, map, and cell space.
- Screen-to-map and map-to-cell transforms with safe clamping for zero-size or non-finite inputs.
- All functions are pure (no state); denominators clamped to avoid division by zero.

## Types

- `ProvinceBorderIndex` (`struct`, `border_index.rs`): Dense per-pixel border pair index map.
- `ProvinceGeometryCache` (`struct`, `cache.rs`): Cache blob of precomputed province geometry.
- `ProvinceDistanceField` (`struct`, `distance_field.rs`): Per-pixel distance to nearest province border, clamped to `max_distance`.
- `ShipmentResource` (`enum`, `economy.rs`): Resource kind moved by logistics shipments.
- `LogisticsRole` (`enum`, `economy.rs`): Logistics role of a province node.
- `ProvinceEconomyState` (`struct`, `economy.rs`): Local economy state for one province.
- `MonthlyEconomyConfig` (`struct`, `economy.rs`): Tunable constants for monthly economy resolution.
- `LogisticsConfig` (`struct`, `economy.rs`): Tunable constants for daily logistics planning.
- `MonthlyEconomyReport` (`struct`, `economy.rs`): Output of one monthly province resolution.
- `ShipmentOrder` (`struct`, `economy.rs`): Shipment launch order created by daily planner.
- `ActiveShipment` (`struct`, `economy.rs`): In-transit shipment that carries real cargo until delivery.
- `ProvinceChange` (`enum`, `events.rs`): Fine-grained field updates emitted by the province registry.
- `ProvinceEvent` (`enum`, `events.rs`): High-level province events for subscribers.
- `ProvinceGpuRecord` (`struct`, `gpu_bridge.rs`): GPU packed province row (std430-friendly 32-byte payload).
- `BorderStyleGpuRecord` (`struct`, `gpu_bridge.rs`): Per-border-pair GPU style record laid out for direct storage-buffer upload.
- `ProvinceGpuTextures` (`struct`, `gpu_upload.rs`): GPU texture bundle used by the province map renderer.
- `MarkerSanitizeOptions` (`struct`, `import.rs`): Thresholds for detecting capital and label marker pixels in a marker PNG.
- `MarkerSanitizeSummary` (`struct`, `import.rs`): Result counters returned by sanitize_marked_png.
- `ProvinceMetadataImportOptions` (`struct`, `import.rs`): Options for the full metadata import pipeline run by import_metadata_from_files.
- `ProvinceMetadataImportSummary` (`struct`, `import.rs`): Result counters returned by import_metadata_from_files.
- `ProvinceMapMode` (`enum`, `map_modes.rs`): Built-in map modes supported by the province engine.
- `ProvinceRecord` (`struct`, `registry.rs`): Runtime state for one province row.
- `ProvinceRegistry` (`struct`, `registry.rs`): Full province dataset with revisioned change history.
- `ProvinceZoomMode` (`enum`, `render.rs`): Strategic/tactical map rendering mode.
- `ProvinceRenderOptions` (`struct`, `render.rs`): Render options for one province map pass.
- `ProvinceGraph` (`struct`, `topology.rs`): Undirected adjacency graph between provinces.
- `ProvinceId` (`type`, `types.rs`): Province identifier used across province/globe/minimap modules.
- `BorderClass` (`enum`, `types.rs`): Visual/semantic class for borders between two provinces.
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
- `classify_border` (`borders.rs`): Classifies border class from two province styles.
- `ProvinceGeometryCache::from_registry` (`cache.rs`): Build a cache by copying spans and border_segments from the given registry.
- `ProvinceGeometryCache::encode` (`cache.rs`): Serialise to a versioned little-endian byte buffer; always succeeds.
- `ProvinceGeometryCache::decode` (`cache.rs`): Deserialise from a byte buffer produced by encode; return None on magic mismatch or truncation.
- `ProvinceDistanceField::at` (`distance_field.rs`): Return field value at (x, y), or None when out of bounds.
- `compute_distance_field` (`distance_field.rs`): Compute distance-to-border field from a raw province id grid.
- `compute_distance_field_from_registry` (`distance_field.rs`): Build a distance field directly from the current registry pixel grid.
- `ProvinceEconomyState::new` (`economy.rs`): Create a basic province economy state with conservative defaults.
- `population_food_need` (`economy.rs`): Returns monthly food need generated by population only.
- `monthly_food_need` (`economy.rs`): Returns full monthly food need including army demand.
- `base_tax_gold` (`economy.rs`): Returns base tax output using 10 population => 1 gold.
- `happiness_productivity_multiplier` (`economy.rs`): Returns happiness-driven productivity multiplier.
- `effective_tax_gold` (`economy.rs`): Returns monthly effective tax gold from local multipliers.
- `computed_population_cap` (`economy.rs`): Returns cap from base + housing.
- `natural_growth` (`economy.rs`): Returns natural monthly growth without starvation/emigration penalties.
- `migration_pressure` (`economy.rs`): Returns migration pressure score from local instability.
- `dispatchable_gold` (`economy.rs`): Returns dispatchable upstream gold after keeping mandatory local reserve.
- `food_deficit` (`economy.rs`): Returns local food deficit to hit target reserve months.
- `resolve_monthly_tick` (`economy.rs`): Resolve one monthly local-economy tick for a single province.
- `resolve_monthly_for_all` (`economy.rs`): Resolve one monthly tick for all provinces, sorted by province id.
- `assign_logistics_parents` (`economy.rs`): Assign nearest logistics parent for province/hub nodes using adjacency shortest-path distance.
- `launch_daily_shipments` (`economy.rs`): Plan and launch daily shipments; deduct origin cargo immediately and return launched orders.
- `to_active_shipments` (`economy.rs`): Convert launch orders into in-transit shipments.
- `advance_shipments_one_day` (`economy.rs`): Advance all active shipments by one day and deliver arrived cargo to destination stockpiles.
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
- `ProvinceMapMode::as_str` (`map_modes.rs`): Return the canonical lowercase string token for this mode.
- `ProvinceMapMode::parse_str` (`map_modes.rs`): Parse a string token to a variant; return None on unknown input.
- `resolve_color` (`map_modes.rs`): Resolves output color for one province style in selected map mode.
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
- `ProvinceRegistry::set_border_class` (`registry.rs`): Set the border class for the (a, b) pair and record a BorderClass change.
- `ProvinceRegistry::get_border_class` (`registry.rs`): Return the stored border class for the (a, b) pair, or None if not explicitly set.
- `ProvinceRegistry::set_border_pair_style` (`registry.rs`): Set the border pair style for (a, b) and record a BorderPairStyle change.
- `ProvinceRegistry::get_border_pair_style` (`registry.rs`): Return the stored border pair style for (a, b), or None if not explicitly set.
- `ProvinceRegistry::set_attr` (`registry.rs`): Insert a key-value string attribute for id; return false if id is unknown.
- `generate_render_commands` (`render.rs`): Generates render commands for one province map frame.
- `ProvinceGraph::new` (`topology.rs`): Return a new empty graph.
- `ProvinceGraph::rebuild_from_pairs` (`topology.rs`): Rebuild the graph from a slice of adjacent id pairs; clears previous data.
- `ProvinceGraph::neighbors_of` (`topology.rs`): Return the sorted neighbour slice for id; returns an empty slice if id has no entry.
- `ProvinceGraph::is_adjacent` (`topology.rs`): Return true if a and b share a border in the graph.
- `ProvinceGraph::province_ids` (`topology.rs`): Return all province ids present in the graph, sorted ascending.
- `ProvinceGraph::adjacency_pairs` (`topology.rs`): Return all unique adjacency pairs (a < b) sorted ascending.
- `BorderPairFlags::empty` (`types.rs`): Create an empty flag set.
- `BorderPairFlags::bits` (`types.rs`): Return the raw bit pattern.
- `BorderPairFlags::from_bits` (`types.rs`): Build a flag set from raw bits.
- `BorderPairFlags::insert_bits` (`types.rs`): Insert a raw flag mask.
- `BorderPairFlags::contains_bits` (`types.rs`): Return true if all bits from mask are present.
- `BorderPairFlags::parse_token` (`types.rs`): Parse a single canonical flag token.
- `BorderPairFlags::to_tokens` (`types.rs`): Return canonical tokens for all set bits.
- `BorderClass::as_str` (`types.rs`): Return the canonical string token used in TOML and CSV exports.
- `BorderClass::parse_str` (`types.rs`): Parse a string token back to a variant; return None on unknown input.
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
- `LProvinceRegistry:getBorderClass`: Returns the border classification string between two adjacent provinces (e.g. "river", "mountain", "sea"), or nil if no class is set.
- `LProvinceRegistry:setBorderClass`: Sets the border classification between two adjacent provinces. Used to control border rendering style (e.g. rivers drawn as blue lines).
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
