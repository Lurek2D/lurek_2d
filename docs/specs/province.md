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

## Files

### border_index.rs

- Precompute border-pair index map from province id grid.
- Assigns a stable u16 pair id for each detected border pixel.
- Optional dilation expands border coverage for thick styled borders.

### borders.rs

- Province border geometry: border index map, dilation, and edge detection.
- `build_border_index` converts a raw province-ID grid into a border pixel mask.
- `dilate_border_index_with_styles` expands border pixels by per-pair style thickness.
- `build_border_index_from_registry` reads the current registry pixel buffer directly.
- Output is an `R16Uint` texture uploaded via `province::gpu_upload`.

### cache.rs

- Serialisable geometry cache for province spans and border segments.
- Binary encode/decode with versioned little-endian format.
- Built from a ProvinceRegistry snapshot for fast load without re-scanning.

### distance_field.rs

- Distance-from-border precompute for province pixels.
- Multi-source BFS seeded from border pixels where neighboring province ids differ.
- Produces a compact u8 field used by later shading or LOD passes.

### events.rs

- Change-log entries for single-field province mutations (colour, terrain, border, fog, visibility).
- High-level map events emitted to Lua callbacks after batched province updates.
- Typed signals for map-mode switches, palette replacements, and fog overlays.

### gpu_bridge.rs

- GPU-uploadable province data bridge between registry and render pipeline.
- Packs province style fields into a repr(C) record for direct buffer upload.
- Builds sorted record arrays from the province registry for deterministic GPU ordering.

### gpu_upload.rs

- Province GPU upload helpers for id, border-index, and distance-field textures.
- Consistent texture descriptors for `R32Uint`, `R16Uint`, and `R8Unorm` data.
- Byte packing utilities used by upload paths and unit tests.

### import.rs

- Province metadata import pipeline: colour-map PNG + RGB CSV + optional TOML → registry.
- Marker PNG sanitization: replace capital and label marker pixels with nearest non-marker neighbour.
- RGB colour CSV parsing mapping packed (R,G,B) tuples to numeric game_id values.
- TOML province info parsing for display name and terrain token fields.
- Pixel-level marker detection with configurable thresholds for capital (near-white) and label (magenta) markers.
- Expanding-ring neighbour search to resolve marker pixel ownership from surrounding province colours.
- Deterministic political colour derivation from game_id with fixed sea-blue for water provinces.
- Label line extraction: find longest-distance pair from label marker point clusters per province.
- Full import pipeline wiring terrain type, political colour, attributes, capitals, and label lines into the registry.

### labels.rs

- Compute pixel-weighted centroids from province span data.
- Map province IDs to their geometric center for label placement.
- Accumulates pixel-weighted x/y sums across span rows and normalises per province area.

### map_modes.rs

- Config-driven map mode system for the province renderer.
- Map modes are registered from Lua at runtime with per-mode display settings.
- Color resolution uses the color_property field from the active map mode config.

### mod.rs

- Province map system: registry, geometry cache, GPU bridge, and rendering.
- Imports colour-map PNG + CSV/TOML metadata into an authoritative ProvinceRegistry.
- Generates RenderCommands for fills, borders, capitals, and text labels.
- Provides view-transform helpers for camera fitting and screen-to-map projection.

### properties.rs

- Province property storage: per-province key-value metadata and stat tables.
- `ProvinceProperties` maps `ProvinceId → HashMap<String, PropertyValue>`.
- `PropertyValue` is an enum covering `Int`, `Float`, `Bool`, and `Text` variants.
- Properties are set from Lua via `lurek.province.set_property(id, key, value)`.
- Serialized into the save file as a flat list for fast round-trip loading.

### province_grid.rs

- Province grid construction from color-mapped images, assigning unique ids per distinct RGB color.
- Pixel-level province id lookup and reverse color retrieval by id.
- Adjacency detection between neighboring provinces with shared-border-pixel counts.
- Horizontal span extraction for contiguous province row segments.
- Border segment detection returning line segments between differing province regions.
- Polygon tracing from directed cell edges into closed point loops per province.
- Polygon simplification removing collinear vertices and 45-degree staircase patterns.
- Binary serialization and deserialization of span and border segment shape data.
- Adjacency pair struct exposing province relationships for map graph queries.

### registry.rs

- Central province registry: owns pixel grid, span runs, adjacency graph, and per-province records.
- Builds from a ProvinceGrid or PNG colour-map; computes spans, bounding boxes, and centroids.
- Provides fast lookup by pixel coordinate, province id, or bounding box.
- Manages mutable province style (political colour, terrain, fog, visibility, border style).
- Stores capital positions, label anchor lines, and label text per province.
- Tracks adjacency via ProvinceGraph and exposes neighbour and pair queries.
- Maintains a monotonic revision counter and ordered change log for incremental sync.
- Supports border class overrides keyed by normalised province pair.
- Stores arbitrary string key-value attributes per province via set_attr.

### render.rs

- Province map rendering: convert registry data into a flat RenderCommand list.
- Viewport culling based on screen bounds and zoom/pan transform.
- Fill rendering via per-province span rectangles coloured by the active map mode.
- Border rendering with config-based color from registered border types.
- Capital dot markers and text labels with shadow offset.
- Hover and selection highlight outlines for interactive feedback.

### routing.rs

- Province graph routing and connectivity analysis helpers.
- BFS route search for unweighted maps.
- Dijkstra route search for weighted edge costs.
- Connected-components and isolation helpers for strategy gameplay queries.

### topology.rs

- Undirected adjacency graph storing sorted neighbour lists per province.
- Rebuild from raw id pairs with dedup and self-loop filtering.
- Binary-search-based neighbour lookup and adjacency queries.
- Extraction of all province ids and unique adjacency pairs.

### types.rs

- Core type definitions for the province map system.
- ProvinceId newtype, BorderType (u8) for game-defined adjacency classification, and ProvinceStyle for per-province visuals.
- ProvinceSnapshot provides an immutable point-in-time view of province state.

### view_transform.rs

- Camera fitting, zoom-at-anchor, and coordinate conversion between screen, map, and cell space.
- Screen-to-map and map-to-cell transforms with safe clamping for zero-size or non-finite inputs.
- All functions are pure (no state); denominators clamped to avoid division by zero.

## Lua API Ref

- Binding: `src/lua_api/province_api.rs`
- Namespace: `lurek.province`

### Functions

- `lurek.province.clearProperties`: Removes all properties, attributes, and flags for a province.
- `lurek.province.exists`: Checks whether a province registry with the given name exists.
- `lurek.province.get`: Retrieves an existing province registry by name. Returns nil if no registry with that name has been created.
- `lurek.province.getActive`: Returns the currently active province registry, or nil if none is set.
- `lurek.province.getAttr`: Gets a string attribute from a province. Returns nil if not set.
- `lurek.province.getProperty`: Gets a numeric property from a province. Returns nil if not set.
- `lurek.province.hasFlag`: Checks whether a flag bit is set on a province.
- `lurek.province.newFromPng`: Creates a new province registry by loading a color-coded PNG where each unique color represents a distinct province. The PNG is parsed into a grid and adjacencies are computed automatically.
- `lurek.province.remove`: Removes a province registry by name and clears the active registry if it was the one removed. Returns true if a registry was actually removed.
- `lurek.province.sanitizeMarkedPng`: Pre-processes a marker PNG by replacing capital and label marker pixels with the surrounding province color. Outputs a cleaned PNG suitable for `newFromPng`. Returns a summary of pixel replacements.
- `lurek.province.setActive`: Sets the named registry as the active province registry. Returns false if no registry with that name exists.
- `lurek.province.setAttr`: Sets a string attribute on a province.
- `lurek.province.setFlag`: Sets a single flag bit (0–63) on a province.
- `lurek.province.setProperty`: Sets a numeric property on a province. Game logic defines the semantics of each key.
- `lurek.province.zoomCameraAt`: Computes new camera position after zooming centered on an anchor point. Keeps the anchor point visually stationary on screen while the zoom level changes.

### Enums

- No documented module-level enums/constants.

### Types


#### LProvinceRegistry Type


##### Fields

- No documented fields.

##### Methods

- `LProvinceRegistry:adjacencies`: Returns all adjacency pairs in the registry. Each entry has `province_a` and `province_b` fields representing two neighboring provinces.
- `LProvinceRegistry:borderSegments`: Returns all border line segments between adjacent provinces. Each segment is a line from (x0,y0) to (x1,y1) separating province_a from province_b.
- `LProvinceRegistry:findIsolatedProvinces`: Returns provinces that have no adjacent province with the same owner attribute.
- `LProvinceRegistry:findRoute`: Finds a route between two provinces using BFS or Dijkstra when `cost_fn` is supplied.
- `LProvinceRegistry:findRoutes`: Finds routes for a batch of `{from, to}` pairs.
- `LProvinceRegistry:fitCamera`: Computes camera position and zoom so the entire province map fits within the given screen dimensions.
- `LProvinceRegistry:getAt`: Returns the province ID at the given grid cell coordinates. Returns 0 if the cell is unowned (sea, wasteland, etc.).
- `LProvinceRegistry:getBorderClass`: Backward-compatible alias for getBorderType. Returns the border type ID.
- `LProvinceRegistry:getBorderPairStyle`: Returns the style override for a specific adjacency pair, or nil when unset.
- `LProvinceRegistry:getBorderType`: Returns the border type ID (0-255) between two adjacent provinces, or nil if not set.
- `LProvinceRegistry:getChangesSince`: Returns all province changes that occurred after the given revision. Each entry contains the revision number and a change record describing what was modified (political_color, terrain_type, border_style, fog_state, visibility_state, or border_class).
- `LProvinceRegistry:getConnectedComponents`: Returns connected components in the province adjacency graph.
- `LProvinceRegistry:getHeight`: Returns the height of the province grid in cells (pixels of the source PNG).
- `LProvinceRegistry:getMapMode`: Returns the name of the currently active map mode.
- `LProvinceRegistry:getName`: Returns the string name used to identify this registry in the province system.
- `LProvinceRegistry:getNeighbors`: Returns a table of province IDs that share a border with the given province.
- `LProvinceRegistry:getProvince`: Returns a snapshot table describing a single province: its ID, revision, style (political_color, terrain_type, border_style, fog_state, visibility_state), centroid, and custom attributes.
- `LProvinceRegistry:getRevision`: Returns the current change revision counter. Incremented on every mutation (color, terrain, border, fog changes). Use with `getChangesSince` for incremental updates.
- `LProvinceRegistry:getWidth`: Returns the width of the province grid in cells (pixels of the source PNG).
- `LProvinceRegistry:importMetadataFromFiles`: Bulk-imports province metadata (colors, capitals, labels, terrain) from external files (PNG color map, CSV color table, TOML province definitions, marker PNG). Returns a summary of how many provinces were mapped.
- `LProvinceRegistry:isConnected`: Returns true when there is at least one route between two provinces.
- `LProvinceRegistry:provinceCount`: Returns the total number of distinct provinces in this registry (excluding ID 0).
- `LProvinceRegistry:provinceIds`: Returns a sequential table of all province IDs in this registry.
- `LProvinceRegistry:provinceSpans`: Returns the raw span data for all provinces. Each span is a horizontal run of cells belonging to one province, useful for custom rendering or spatial analysis.
- `LProvinceRegistry:registerBorderType`: Registers a border type config by ID. Defines visual appearance for borders of this type.
- `LProvinceRegistry:registerMapMode`: Registers a named map mode with display configuration. Overwrites if name exists.
- `LProvinceRegistry:render`: Renders the province map to the screen using the current camera and style settings. Generates draw commands for fills, borders, labels, and capitals based on the provided options.
- `LProvinceRegistry:screenToMap`: Converts screen-space pixel coordinates to map-space floating-point coordinates using the current camera transform.
- `LProvinceRegistry:screenToProvince`: Converts screen-space coordinates directly to a province ID. Returns nil if the cursor is outside the map or over an unowned cell.
- `LProvinceRegistry:setAttr`: Sets a custom string attribute on a province. Attributes are returned in the `attrs` table of `getProvince` and can store arbitrary game metadata.
- `LProvinceRegistry:setBorderClass`: Backward-compatible alias for setBorderType. Sets the border type ID.
- `LProvinceRegistry:setBorderPairStyle`: Sets the style override for a specific adjacency pair, including optional color, thickness, and semantic flags.
- `LProvinceRegistry:setBorderStyle`: Sets the border rendering style index for a province. Controls line thickness, color, or pattern when borders are drawn.
- `LProvinceRegistry:setBorderType`: Sets the border type ID between two adjacent provinces. Register types first with registerBorderType.
- `LProvinceRegistry:setCapital`: Sets the capital marker position for a province. The capital is drawn as a small icon during `render` when `draw_capitals` is enabled.
- `LProvinceRegistry:setFogState`: Sets a fog-of-war byte for a province. This value is game-defined metadata and can be used by scripts/map modes.
- `LProvinceRegistry:setLabelLine`: Sets the label baseline for a province. The label text is rendered along the line from (ax,ay) to (bx,by), allowing curved or angled province names.
- `LProvinceRegistry:setLabelText`: Sets the display name text for a province. Rendered on the map when `draw_labels` is enabled in `render` options.
- `LProvinceRegistry:setMapMode`: Switches the active map mode to a previously registered mode name.
- `LProvinceRegistry:setPoliticalColor`: Sets the political map color for a province. Used in political map mode rendering and change tracking.
- `LProvinceRegistry:setTerrainType`: Sets the terrain type index for a province. Terrain type controls which fill color or texture is used in terrain map mode.
- `LProvinceRegistry:setVisibilityState`: Sets the render visibility state for a province. `0` = hidden (no fill/border/capital/label), `1` = discovered (gray fill only), `2+` = fully visible.
- `LProvinceRegistry:totalAttrForOwner`: Sums a numeric attribute for all provinces with matching owner value.
- `LProvinceRegistry:type`: Returns the type name string for this userdata object.
- `LProvinceRegistry:typeOf`: Checks whether this object matches the given type name. Returns true for "LProvinceRegistry" and "Object".

## References

- `image`: Imports or references `src/image/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.
- `render`: Imports or references `src/render/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Edge/Integration` into `Core Runtime`.
