<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/province.md or source docstrings instead. -->

# province

## TL;DR

- Simulates region maps decoded from color-coded PNG cartographic assets.
- Imports capitals, angled labels, and terrain metadata, compiling adjacencies.
- Supports horizontal span runs, binary geometry caches, and map modes.
- Exposes province-specific routing and picking adapters while shared path search and camera math stay in their owner modules.

## General Info

- Module group: `Feature Systems`
- Source path: `src/province`
- Binding: `src/lua_api/province_api.rs`
- Namespace: `lurek.province`
- Lua API surface: `15` functions, `8` types, `49` methods
- User-facing: `true`
- Plugin tier: `core_keep`

## Summary

- The `province` module is the engine's territory-region system for users who want named areas, borders, ownership, routing, and province-like gameplay state to behave as one native feature.
- Topology, registries, imports, labels, caches, property layers, render bridges, and view adapters matter because a province map is more than a color fill; it is a structured graph of regions with state and presentation rules.
- Province identity is central from the user perspective. Scripts need to ask which region an area belongs to, how regions connect, what properties they carry, and how those answers change over time.
- Ownership, labels, borders, and view helpers make the module useful for strategy maps, campaign layers, regional simulations, and UI-heavy territory systems where territory data must be both playable and readable.
- Adjacency behavior extends the feature from passive map metadata into active game logic, because movement, logistics, diplomacy, and campaign progression often depend on region-to-region relationships. Reusable route search belongs to `pathfind`; `province` adapts registry topology into that navigation layer.
- Property layers, events, and interaction helpers make the module useful both as a gameplay authority for territory logic and as a map-facing surface for highlighting, picking, overlays, and editor-style inspection.
- Import and cache support matter because province-heavy projects often operate on large authored maps where region definitions, border relationships, and property tables must be reused efficiently at runtime instead of reparsed or recomputed ad hoc.
- Region properties broaden the feature beyond simple ownership maps. Provinces often carry economy, culture, terrain, danger, visibility, supply, or event flags, and the module gives those layers one shared place to live and change over time.
- That shared province identity is what keeps strategy logic, labels, overlays, and player interaction pointed at the same region model instead of drifting apart.
- Picking and view-transform adapters are especially important for strategy interfaces and editors, where the province system must translate user interaction into stable region identity while generic viewport, zoom, and world/screen math remain owned by `camera`.
- This is why `province` works well for campaign maps, strategy regions, and territory editors.
- It also gives simulation and map UI one shared authority for ownership and adjacency.
- Read `province` as the territory authority of the engine. Other systems may navigate, draw, or summarize provinces, but this module decides how provinces are represented, connected, labeled, updated, and queried with one stable region model.

This module primarily collaborates with `camera`, `image`, `pathfind`, `render`, `runtime`. Its responsibility should stay inside the `Edge/Integration` group rather than absorb behavior owned by those neighbors.

## Ownership

- Canonical source: `src/province`
- Owning tier: `Feature Systems`
- Plugin tier: `core_keep`
- Lua binding owner: `src/lua_api/province_api.rs`
- Referenced engine modules: `camera`, `image`, `math`, `pathfind`, `render`, `runtime`

## Imports

- `camera`: Imports or references `src/camera/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `image`: Imports or references `src/image/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `math`: Imports or references `src/math/`. Cross-group dependency from `Feature Systems` into `Foundations`.
- `pathfind`: Imports or references `src/pathfind/`. Dependency stays inside `Feature Systems` and should remain acyclic.
- `render`: Imports or references `src/render/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Feature Systems` into `Core Runtime`.

## Source Files

### border_index.rs

- Builds a province-pair lookup from the ownership grid so render and gameplay systems can query shared borders quickly.
- Owns ProvinceBorderIndex storage, pair-id assignment, and the dilation pass that widens border pixels by style hints.
- Provides the boundary between raw province occupancy data and later GPU or renderer code that needs stable border IDs.
- This file is the right owner when border pairing, style-aware expansion, or pair lookup invariants need adjustment.
- Neighboring changes usually involve ProvinceGrid extraction, registry border styles, and GPU bridge packing formats.

### cache.rs

- Persists compact province geometry blobs so expensive span and border extraction can be reused across repeated loads.
- Owns ProvinceGeometryCache records plus binary encode and decode helpers for span lists and border segment payloads.
- Provides a storage boundary between derived province shapes and callers that want fast startup without recomputation.
- Open this file when cache schema, geometry serialization, or compatibility rules for saved province artifacts change.

### distance_field.rs

- Builds per-pixel distance maps from province borders so map overlays can reason about interior depth and edge falloff.
- Owns ProvinceDistanceField dimensions, flat cell storage, and the multi-source BFS that propagates border distances.
- Exposes constructors from raw province grids and registries, plus direct sampling helpers for downstream render logic.
- This file marks the boundary between discrete province ownership data and continuous-looking distance queries.
- Change this owner when border seed rules, traversal neighborhoods, or distance consumers in rendering need revision.

### events.rs

- Defines province change payloads that describe what part of registry state moved so observers can react precisely.
- Owns ProvinceChange variants and ProvinceEvent records carrying revision numbers for incremental update consumers.
- Provides a narrow contract between registry mutation code and systems that mirror styles, labels, or border state.
- Read this file when adding new observable province mutations or tightening the meaning of emitted change reasons.

### gpu_bridge.rs

- Maps province registry data into flat GPU-friendly records that shaders and upload code can consume without Rust state.
- Owns ProvinceGpuRecord and BorderStyleGpuRecord layouts plus builders that normalize colors, flags, and style bits.
- Provides the translation boundary between rich province metadata and tightly packed buffers for renderer-side lookup.
- Use this file when GPU record shape, packing rules, or registry fields required by province shaders are changing.

### gpu_upload.rs

- Creates province-related GPU textures so shaders can sample ownership, pair IDs, and distance fields by map pixel.
- Owns upload helpers for R32Uint, R16Uint, and R8Unorm texture creation plus byte-packing for integer cell arrays.
- Provides the renderer-facing resource boundary between CPU province structures and wgpu texture initialization calls.
- This file is where texture dimensions, formats, and upload staging logic for province data are coordinated together.
- Neighboring edits usually come from ProvinceGrid, ProvinceBorderIndex, or ProvinceDistanceField layout adjustments.
- Open this owner when a shader needs new province lookup textures or existing upload formats stop matching consumers.

### import.rs

- Implements the province metadata import pipeline that turns marker art, CSV tables, and TOML into registry state.
- Owns marker sanitization rules, metadata import options, and summaries describing skipped rows or inferred values.
- Parses RGB to game-id mappings, province property tables, and label or capital hints before mutating the registry.
- Derives political colors and province attributes from imported records so gameplay data attaches to painted regions.
- Provides the ingestion boundary between external authoring assets and the authoritative ProvinceRegistry contents.
- This file is the right place for changes to import validation, marker cleanup, or asset-to-registry field mapping.
- Neighboring systems include image loading, registry mutators, and province labels that consume imported metadata.
- Open this owner when province authoring files change format or when import diagnostics need more exact coverage.

### labels.rs

- This file owns centroid calculation for province span data so label anchors come from occupied pixels.
- It accumulates weighted x and y sums per province id and ignores empty or zero-width spans during reduction.
- Open this file when province label anchor math changes; rendering and routing logic live in sibling owners.

### map_modes.rs

- Stores province map-mode definitions that decide how fills are colored when the renderer asks for thematic overlays.
- Owns MapModeConfig and MapModeRegistry data, including fill-color lookup rules and fallback behavior per province.
- Provides the styling boundary between raw province attributes and render-time color selection for alternate views.
- This file matters when new map modes, fallback color semantics, or province-style integration rules are added.
- Neighboring changes usually involve ProvinceStyle fields, registry storage, and renderer mode selection logic.

### mod.rs

- Exports the province subsystem surface that groups grid extraction, registry state, rendering, import, and helpers.
- Acts as the navigation entry for province ownership, borders, labels, map modes, and GPU support modules below.
- Keeps the module boundary explicit so callers can find whether a province concern belongs to data, import, or draw.
- Open this file when adding or retiring province submodules or when the public organization of province code shifts.
- Neighboring work usually spans ProvinceRegistry, ProvinceGrid, render generation, and metadata import pipelines.
- The exported set here defines which province owners are considered part of the supported internal engine surface.
- Agents should start here when tracing province features because it reveals the authoritative file split by concern.
- This file stays thin by contract, so substantive province behavior belongs in the concrete owners it re-exports.

### properties.rs

- Stores extensible per-province metadata so gameplay and rendering code can attach numeric, text, and flag values.
- Owns ProvinceProperties maps for numbers, strings, and booleans plus typed setters and lookups for those stores.
- Provides a lightweight attribute boundary between fixed registry fields and project-specific province annotations.
- Open this file when province property typing, persistence expectations, or attribute access patterns need changes.

### province_grid.rs

- Extracts province ownership from color images and derives spans, adjacencies, borders, and polygon outlines.
- Owns ProvinceGrid cell storage, color-to-id mappings, adjacency tracking, and cached geometric shape products.
- Provides constructors from images and files, direct cell lookup, province counts, and color recovery helpers.
- Builds province spans and border segments that later feed registries, caches, render generation, and labels.
- Traces polygon loops from directed border edges, then simplifies them for downstream consumers that need shapes.
- This file is the algorithmic owner for converting painted province maps into structured topology and geometry.
- Neighboring changes usually involve import image assumptions, border indexing, registry hydration, and caching.
- Open this owner when province extraction correctness, polygon quality, or adjacency detection needs adjustment.
- It is the right file for shape cache invariants because no sibling module owns the raw pixel-to-province pass.

### registry.rs

- Owns the authoritative mutable province model that centralizes ids, geometry, styles, labels, and change tracking.
- Stores province records, border style tables, map modes, adjacency data, and per-province spans or bounds together.
- Builds registry state from ProvinceGrid inputs and then exposes lookup, mutation, and revision-aware event helpers.
- Provides the subsystem boundary where imported metadata and gameplay edits become durable province state changes.
- Tracks capitals, label placement, fog, terrain, ownership colors, custom attrs, and border presentation settings.
- Emits change log entries so renderers or tooling can react incrementally instead of rescanning the whole registry.
- Neighboring systems include import, rendering, routing, map modes, and GPU bridges that consume registry records.
- Open this file whenever province state semantics, mutation APIs, or revision contracts need coordinated updates.

### render.rs

- Generates province render commands from registry state so the map can draw fills, borders, labels, and overlays.
- Owns ProvinceRenderOptions, zoom-mode interpretation, viewport culling, and helper rules for visible border output.
- Converts province spans, styles, capitals, roads, labels, and selection state into ordered RenderCommand batches.
- Provides the presentation boundary between authoritative province data and the lower renderer command stream.
- Encodes how fog, visibility, hover, border types, and level-of-detail choices alter what the province map emits.
- Neighboring changes usually involve ProvinceRegistry fields, map mode colors, and render command capabilities.
- Open this owner when visual province behavior changes, especially if command ordering or LOD rules need revision.
- This file is where province-specific drawing policy lives instead of the generic renderer or data registry layers.

### routing.rs

- Adapts province registry data to pathfinding-owned graph traversal helpers.
- Keeps province-specific owner and attribute aggregation near the registry-facing module.
- Path search, Dijkstra, connectivity, and component traversal live in `pathfind::graph_path`.
- Open this file when province-specific routing adapters or owner-attribute analytics need revision.

### topology.rs

- Normalizes province adjacency pairs into a stable undirected graph so higher-level systems can traverse neighbors.
- Owns ProvinceGraph storage and the rebuild pass that sorts, deduplicates, and mirrors province connections safely.
- Provides the low-level topology boundary between raw adjacency detection and consumers that need graph queries.
- Read this owner when graph invariants, pair normalization, or neighbor list construction rules are changing.

### types.rs

- Defines shared province value types used across registry, rendering, routing, and import code paths together.
- Owns identifiers, border configuration structs, style payloads, and lightweight province snapshot structures.
- Provides the data contract boundary for province styling and border-pair semantics that many files depend on.
- This file is the right owner for shape-independent province schema changes that should stay reusable everywhere.
- Neighboring work often touches registry mutation APIs, renderer color logic, and border indexing expectations.

### view_transform.rs

- Adapts generic camera viewport math to province-grid map coordinates and cell picking.
- Owns province-specific conversion from floating map positions into bounded province cell coordinates.
- Generic fit, screen/content conversion, and zoom-anchor math live in `camera::viewport`.
- Open this file when province map interaction needs a different grid-space adapter.



## Lua API Ref

### Functions

- `lurek.province.clearProperties(id) -> nil`: Removes all properties, attributes, and flags for a province.
- `lurek.province.exists(name) -> boolean`: Checks whether a province registry with the given name exists.
- `lurek.province.get(name) -> LProvinceRegistry`: Retrieves an existing province registry by name. Returns nil if no registry with that name has been created.
- `lurek.province.getActive() -> LProvinceRegistry`: Returns the currently active province registry, or nil if none is set.
- `lurek.province.getAttr(id, key) -> string`: Gets a string attribute from a province. Returns nil if not set.
- `lurek.province.getProperty(id, key) -> number`: Gets a numeric property from a province. Returns nil if not set.
- `lurek.province.hasFlag(id, bit) -> boolean`: Checks whether a flag bit is set on a province.
- `lurek.province.newFromPng(name, png_path) -> LProvinceRegistry`: Creates a new province registry by loading a color-coded PNG where each unique color represents a distinct province. The PNG is parsed into a grid and adjacencies are computed automatically.
- `lurek.province.remove(name) -> boolean`: Removes a province registry by name and clears the active registry if it was the one removed. Returns true if a registry was actually removed.
- `lurek.province.sanitizeMarkedPng(input_png, output_png, opts?) -> table`: Pre-processes a marker PNG by replacing capital and label marker pixels with the surrounding province color. Outputs a cleaned PNG suitable for `newFromPng`. Returns a summary of pixel replacements.
- `lurek.province.setActive(name) -> boolean`: Sets the named registry as the active province registry. Returns false if no registry with that name exists.
- `lurek.province.setAttr(id, key, value) -> nil`: Sets a string attribute on a province.
- `lurek.province.setFlag(id, bit, value) -> nil`: Sets a single flag bit (0â€“63) on a province.
- `lurek.province.setProperty(id, key, value) -> nil`: Sets a numeric property on a province. Game logic defines the semantics of each key.
- `lurek.province.zoomCameraAt(anchor_x, anchor_y, cam_x, cam_y, old_zoom, new_zoom) -> number, number`: Computes new camera position after zooming centered on an anchor point. Keeps the anchor point visually stationary on screen while the zoom level changes.

### Callbacks

- `LProvinceRegistry:findRoute` param `cost_fn` (`function?`): Optional cost callback `fn(from_id, to_id) -> number`.
- `LProvinceRegistry:findRoutes` param `cost_fn` (`function?`): Optional cost callback `fn(from_id, to_id) -> number?`.

### Enums

- No documented module-level enums/constants.

### Types

#### LProvinceRegistry Type

- Handle to a named province registry, exposing spatial queries, style mutations, rendering, and change tracking to Lua scripts.

##### Fields

- No documented fields.

##### Methods

- `LProvinceRegistry:adjacencies() -> table`: Returns all adjacency pairs in the registry. Each entry has `province_a` and `province_b` fields representing two neighboring provinces.
- `LProvinceRegistry:borderSegments() -> table`: Returns all border line segments between adjacent provinces. Each segment is a line from (x0,y0) to (x1,y1) separating province_a from province_b.
- `LProvinceRegistry:drawCapitalPath(route, opts?) -> integer`: Emits render commands for a route by connecting consecutive province capitals. Pass the route table returned by `findRoute`; pathfinding itself stays in the routing helpers. Options: mode ("line"|"bezier"), color ({r,g,b,a?} in 0..1), width, pixel_size, curve_offset, and segments.
- `LProvinceRegistry:findIsolatedProvinces(owner_attr) -> integer[]`: Returns provinces that have no adjacent province with the same owner attribute.
- `LProvinceRegistry:findRoute(from_id, to_id, cost_fn?) -> table`: Finds a route between two provinces by adapting registry adjacency to pathfind graph routing. Uses BFS by default or Dijkstra when `cost_fn` is supplied.
- `LProvinceRegistry:findRoutes(pairs, cost_fn?) -> table`: Finds routes for a batch of `{from, to}` pairs by adapting registry adjacency to pathfind graph routing.
- `LProvinceRegistry:fitCamera(screen_w, screen_h, pixel_size?) -> number, number, number`: Computes camera position and zoom so the entire province map fits within the given screen dimensions.
- `LProvinceRegistry:getAt(x, y) -> integer`: Returns the province ID at the given grid cell coordinates. Returns 0 if the cell is unowned (sea, wasteland, etc.).
- `LProvinceRegistry:getBorderClass(a, b) -> integer`: Backward-compatible alias for getBorderType. Returns the border type ID.
- `LProvinceRegistry:getBorderPairStyle(a, b) -> table`: Returns the style override for a specific adjacency pair, or nil when unset.
- `LProvinceRegistry:getBorderType(a, b) -> integer`: Returns the border type ID (0-255) between two adjacent provinces, or nil if not set.
- `LProvinceRegistry:getChangesSince(revision) -> table`: Returns all province changes that occurred after the given revision. Each entry contains the revision number and a change record describing what was modified (political_color, terrain_type, border_style, fog_state, visibility_state, or border_class).
- `LProvinceRegistry:getConnectedComponents() -> table`: Returns connected components in the province adjacency graph via pathfind graph traversal.
- `LProvinceRegistry:getHeight() -> integer`: Returns the height of the province grid in cells (pixels of the source PNG).
- `LProvinceRegistry:getMapMode() -> string`: Returns the name of the currently active map mode.
- `LProvinceRegistry:getName() -> string`: Returns the string name used to identify this registry in the province system.
- `LProvinceRegistry:getNeighbors(id) -> integer[]`: Returns a table of province IDs that share a border with the given province.
- `LProvinceRegistry:getProvince(id) -> table`: Returns a snapshot table describing a single province: its ID, revision, style (political_color, terrain_type, border_style, fog_state, visibility_state), centroid, and custom attributes.
- `LProvinceRegistry:getRevision() -> integer`: Returns the current change revision counter. Incremented on every mutation (color, terrain, border, fog changes). Use with `getChangesSince` for incremental updates.
- `LProvinceRegistry:getShader() -> LShader?`: Returns the currently bound command-render province shader, or nil.
- `LProvinceRegistry:getWidth() -> integer`: Returns the width of the province grid in cells (pixels of the source PNG).
- `LProvinceRegistry:importMetadataFromFiles(opts) -> table`: Bulk-imports province metadata (colors, capitals, labels, terrain) from external files (PNG color map, CSV color table, TOML province definitions, marker PNG). Returns a summary of how many provinces were mapped.
- `LProvinceRegistry:isConnected(from_id, to_id) -> boolean`: Returns true when there is at least one pathfind graph route between two provinces.
- `LProvinceRegistry:provinceCount() -> integer`: Returns the total number of distinct provinces in this registry (excluding ID 0).
- `LProvinceRegistry:provinceIds() -> integer[]`: Returns a sequential table of all province IDs in this registry.
- `LProvinceRegistry:provinceSpans() -> table`: Returns the raw span data for all provinces. Each span is a horizontal run of cells belonging to one province, useful for custom rendering or spatial analysis.
- `LProvinceRegistry:registerBorderType(type_id, config) -> nil`: Registers a border type config by ID. Defines visual appearance for borders of this type.
- `LProvinceRegistry:registerMapMode(name, config) -> nil`: Registers a named map mode with display configuration. Overwrites if name exists.
- `LProvinceRegistry:render(opts?) -> nil`: Renders the province map to the screen using the current camera and style settings. Generates draw commands for fills, borders, labels, and capitals based on the provided options. Optional `tint` multiplies all province fill colours for this render only, while `province_tints` supplies render-time fill colour overrides keyed by province id without mutating the registry.
- `LProvinceRegistry:screenToMap(screen_x, screen_y, cam_x, cam_y, zoom, pixel_size?) -> number, number`: Converts screen-space pixel coordinates to map-space floating-point coordinates using the current camera transform.
- `LProvinceRegistry:screenToProvince(screen_x, screen_y, cam_x, cam_y, zoom, pixel_size?) -> integer`: Converts screen-space coordinates directly to a province ID. Returns nil if the cursor is outside the map or over an unowned cell.
- `LProvinceRegistry:setAttr(id, key, value) -> boolean`: Sets a custom string attribute on a province. Attributes are returned in the `attrs` table of `getProvince` and can store arbitrary game metadata.
- `LProvinceRegistry:setBorderClass(a, b, border_type) -> nil`: Backward-compatible alias for setBorderType. Sets the border type ID.
- `LProvinceRegistry:setBorderPairStyle(a, b, style) -> boolean`: Sets the style override for a specific adjacency pair, including optional color, thickness, and semantic flags.
- `LProvinceRegistry:setBorderStyle(id, border_style) -> boolean`: Sets the border rendering style index for a province. Controls line thickness, color, or pattern when borders are drawn.
- `LProvinceRegistry:setBorderType(a, b, border_type) -> nil`: Sets the border type ID between two adjacent provinces. Register types first with registerBorderType.
- `LProvinceRegistry:setCapital(id, x, y) -> boolean`: Sets the capital marker position for a province. The capital is drawn as a small icon during `render` when `draw_capitals` is enabled.
- `LProvinceRegistry:setFogState(id, fog_state) -> boolean`: Sets a fog-of-war byte for a province. This value is game-defined metadata and can be used by scripts/map modes.
- `LProvinceRegistry:setLabelLine(id, ax, ay, bx, by) -> boolean`: Sets the label baseline for a province. The label text is rendered along the line from (ax,ay) to (bx,by), allowing curved or angled province names.
- `LProvinceRegistry:setLabelText(id, text) -> boolean`: Sets the display name text for a province. Rendered on the map when `draw_labels` is enabled in `render` options.
- `LProvinceRegistry:setMapMode(name) -> boolean`: Switches the active map mode to a previously registered mode name.
- `LProvinceRegistry:setPoliticalColor(id, r, g, b, a?) -> boolean`: Sets the political map color for a province. Used in political map mode rendering and change tracking.
- `LProvinceRegistry:setShader(shader?) -> nil`: Binds or clears a `mapviz` shader for command-rendered province visualization.
- `LProvinceRegistry:setTerrainType(id, terrain_type) -> boolean`: Sets the terrain type index for a province. Terrain type controls which fill color or texture is used in terrain map mode.
- `LProvinceRegistry:setVisibilityState(id, visibility_state) -> boolean`: Sets the render visibility state for a province. `0` = hidden (no fill/border/capital/label), `1` = discovered (gray fill only), `2+` = fully visible.
- `LProvinceRegistry:totalAttrForOwner(owner_attr, owner_val, sum_attr) -> number`: Sums a numeric attribute for all provinces with matching owner value.
- `LProvinceRegistry:type() -> string`: Returns the type name string for this userdata object.
- `LProvinceRegistry:typeOf(name) -> boolean`: Checks whether this object matches the given type name. Returns true for "LProvinceRegistry" and "Object".
- `LProvinceRegistry:viewportRect(opts?) -> table`: Computes the province-space viewport rectangle used by province rendering and culling. The returned table can be passed to minimap:setViewportRect(rect.x, rect.y, rect.w, rect.h).

#### LProvinceRegistryAdjacenciesResult Type

- Generated result shape from @field tags.

##### Fields

- `province_a` (`integer`): First province id.
- `province_b` (`integer`): Second province id.

##### Methods

- No documented methods.

#### LProvinceRegistryBorderSegmentsResult Type

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

#### LProvinceRegistryGetChangesSinceResult Type

- Generated result shape from @field tags.

##### Fields

- `kind` (`string`): Change kind (political_color, terrain_type, etc.).
- `province_id` (`integer?`): Province id when applicable.
- `revision` (`integer`): Change revision number.

##### Methods

- No documented methods.

#### LProvinceRegistryGetProvinceResult Type

- Generated result shape from @field tags.

##### Fields

- `attrs` (`table`): Custom attributes table.
- `centroid` (`table`): Centroid position table.
- `province_id` (`integer`): Province id.
- `revision` (`integer`): Revision number.
- `style` (`table`): Style table with terrain_type, fog_state, etc.

##### Methods

- No documented methods.

#### LProvinceRegistryImportMetadataFromFilesResult Type

- Generated result shape from @field tags.

##### Fields

- `capitals_set` (`integer`): Capitals set count.
- `label_lines_set` (`integer`): Label lines set count.
- `labels_set` (`integer`): Labels set count.
- `mapped_provinces` (`integer`): Mapped provinces count.

##### Methods

- No documented methods.

#### LProvinceRegistryProvinceSpansResult Type

- Generated result shape from @field tags.

##### Fields

- `province_id` (`integer`): Province id.
- `x0` (`number`): Start x coordinate.
- `x1` (`number`): End x coordinate.
- `y` (`number`): Scanline y coordinate.

##### Methods

- No documented methods.

#### LProvinceSanitizeMarkedPngResult Type

- Generated result shape from @field tags.

##### Fields

- `replaced_pixels` (`integer`): Replaced pixel count.
- `unresolved_pixels` (`integer`): Unresolved pixel count.

##### Methods

- No documented methods.

## Examples

- `content/examples/province.lua` (present)

## Tests

- Lua unit: `tests/lua/unit/test_province_unit.lua` (present)
- Rust: `src/province/province_grid.rs`
- Rust: `tests/rust/unit/province_tests.rs`

## Evidence / Golden

| Kind | Path |
|---|---|
| Evidence test | `tests/lua/evidence/test_province_evidence.lua` |
| Golden test | `tests/lua/golden/test_province_golden.lua` |
| Current artifact | `tests/artifacts/current/province/_fixture/province_color_map.png` |
| Current artifact | `tests/artifacts/current/province/_fixture/province_colors.csv` |
| Current artifact | `tests/artifacts/current/province/_fixture/province_data.toml` |
| Current artifact | `tests/artifacts/current/province/_fixture/province_marked_map.png` |
| Current artifact | `tests/artifacts/current/province/province_border_segments.png` |
| Current artifact | `tests/artifacts/current/province/province_capitals_centroids.png` |
| Current artifact | `tests/artifacts/current/province/province_capitals_labels_centroids.png` |
| Current artifact | `tests/artifacts/current/province/province_economy_properties_trace.txt` |
| Current artifact | `tests/artifacts/current/province/province_registry_topology_trace.txt` |
| Current artifact | `tests/artifacts/current/province/province_render_plan_overlay.png` |
| Current artifact | `tests/artifacts/current/province/province_revision_timeline.gif` |
| Current artifact | `tests/artifacts/current/province/province_route_trace.png` |
| Current artifact | `tests/artifacts/current/province/province_sanitized_map.png` |
| Current artifact | `tests/artifacts/current/province/province_shader_binding_contract.txt` |
| Current artifact | `tests/artifacts/current/province/province_span_runs.png` |
| Current artifact | `tests/artifacts/current/province/province_strategy_modes.png` |
| Current artifact | `tests/artifacts/current/province/province_zoom_pick_view.png` |
| Baseline artifact | `tests/artifacts/baselines/province/province_border_segments.png` |
| Baseline artifact | `tests/artifacts/baselines/province/province_capitals_labels_centroids.png` |
| Baseline artifact | `tests/artifacts/baselines/province/province_revision_timeline.gif` |
| Baseline artifact | `tests/artifacts/baselines/province/province_route_trace.png` |
| Baseline artifact | `tests/artifacts/baselines/province/province_sanitized_map.png` |
| Baseline artifact | `tests/artifacts/baselines/province/province_span_runs.png` |
| Baseline artifact | `tests/artifacts/baselines/province/province_strategy_modes.png` |
| Baseline artifact | `tests/artifacts/baselines/province/province_zoom_pick_view.png` |

## Architecture Links

- Intentionally empty.

## Notes

- `province` owns conversion from painted province maps into province ids, spans, borders, polygons, and registry state. `image` owns generic pixel buffers and keeps `newProvinceGrid` as a compatibility ingest facade.
- `province` owns topology as territory data, but `pathfind` owns reusable path search, weighted traversal, connectivity traversal, movement budgets, and reachability over that topology. Province route methods should stay thin adapters over pathfind graph traversal.
- Flow simulation over graph nodes, items, queues, capacity, and supply/demand belongs to `flownet`/`lurek.graph`; province adjacency can feed it but should not implement transport semantics.
- `province` may expose `fitCamera`, `screenToProvince`, and `zoomCameraAt` for strategy-map ergonomics, but generic viewport and zoom-anchor math belongs to `camera`.
- `LProvinceRegistry:setShader(shaderOrNil)` accepts only `mapviz` shaders created by `lurek.render.newShader`. The registry stores the semantic shader binding, then the command backend wraps generated render commands in render-owned shader state. The specialized `backend = "gpu"` province map pipeline and segment raster cache do not yet execute custom user shaders; richer province-id and heatmap inputs belong in a later render-owned `DrawProvinceMap` shader contract.
