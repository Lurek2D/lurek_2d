# province

## TL;DR

- Simulates region maps decoded from color-coded PNG cartographic assets.
- Imports capitals, angled labels, and terrain metadata, compiling adjacencies.
- Supports horizontal span runs, binary geometry caches, and map modes.
- Calculates depth distance fields, strategic routing, and revision logs.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/province/`
- Binding: `src/lua_api/province_api.rs`
- Namespace: `lurek.province`
- Lua API surface: `15` functions, `8` types, `45` methods
- Rust test path(s): tests/rust/unit/province_tests.rs
- Lua test path(s): None found in the workspace

## Summary

This module provides a province-based cartography and region simulation subsystem that manages irregular region maps as semantic gameplay entities. Unlike cell-based tilemaps, provinces represent cohesive territories parsed from color-coded map graphics. The system maintains an authoritative registry that decodes raster pixels into stable province identities, establishing an adjacency network that acts as the topological foundation for map-wide routing and borders.

To ingest custom worlds, the module implements an asset import pipeline. It parses color-coded PNG files, sanitizes capital markers, and extracts label baselines. A neighbor-searching algorithm resolves capital and label hint pixels to surrounding provinces by checking local context, bridging the gap between graphical assets and active game registries. Extracted regions are mapped to CSV color tables and TOML definitions.

To keep large strategic maps running efficiently, the engine optimizes and caches region geometry. It decodes irregular shapes into horizontal cell runs that are highly efficient for rendering and bounds testing. Traced border contours are simplified to remove staircase pixel artifacts, and the resulting structures are stored in a binary geometry cache, letting imported maps load almost instantly without expensive pixel rescans.

Visual presentation is driven by extensible styles and map modes. The rendering system can draw political overlays, terrain fills, and visibility layers over the same province geometry. Each province tracks styling parameters, including political colors, terrain indices, and fog-of-war bytes. Specific borders between neighboring provinces can be customized with distinct thicknesses, colors, and relationship styles.

Spatial reasoning is supported through precomputed depth and positioning metrics. The system generates multi-source inward-depth distance fields to measure how far any coordinate lies from its regional boundary, providing visual shading signals. Centroid calculators find actual geometric centers for label placement, and transform maps allow interactive mouse picks, anchors, and zooms.

Strategic pathfinding is handled by routing tools that operate over the adjacency graph. The module provides unweighted neighbor search and cost-aware Dijkstra algorithms, allowing agents to plot optimal paths across strategic regions. The routing engine checks map connectivity, detects isolated province clusters, and returns topological groupings without cluttering the central registry.

Finally, the registry implements change-tracking mechanics. Monotonic revision counters increment on every styling, visibility, or political update, generating detailed chronological change logs. This incrementally observable database lets Lua scripts and external shaders sync state efficiently, driving reactive user interfaces and tactical map updates without expensive map diff calculations.

## Imports

- `image`: Imports or references `src/image/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.
- `render`: Imports or references `src/render/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Edge/Integration` into `Core Runtime`.

## Files

### border_index.rs

- Border-pair indexing layer that turns neighboring province relationships into a stable per-pixel border identifier map.
- The file scans province ownership changes across the grid and assigns compact ids that higher rendering paths can treat as semantic border channels instead of raw color differences.
- Stable pair ids matter because styled borders need consistent addressing across shading, upload, and change-driven rebuilds.
- Optional dilation broadens those indexed borders so thick outlines can be expressed without re-deriving topology at draw time.
- Functionally this file delivers the border-id texture logic behind efficient province border styling.

### cache.rs

- Geometry cache for province maps that would otherwise need expensive pixel rescans every time spans and border segments are needed again.
- The file captures a registry snapshot into a portable binary form so precomputed geometry can survive reloads and avoid repeating extraction work.
- Versioned encoding keeps the cache format explicit and safe to evolve alongside the runtime representation.
- Functionally this file delivers fast reloadable province geometry persistence for large map workflows.

### distance_field.rs

- Border-distance precompute for province pixels so later rendering and analysis code can reason about how deep a location sits inside its owning region.
- The file starts from boundary cells and spreads inward with a multi-source traversal, producing a compact measure of interior distance without per-frame recomputation.
- Keeping the result as a small field makes it practical for shading, stylization, and level-of-detail style logic.
- The computation is map-wide and structural, which means it belongs here rather than in ad hoc rendering code.
- Functionally this file delivers the inward-depth signal used for province-edge-aware visuals and spatial heuristics.

### events.rs

- Province change and event vocabulary for describing what shifted in map state without forcing listeners to diff whole registry snapshots.
- The file models fine-grained mutation records and higher-level events so Lua and engine code can react to province updates in a deliberate typed way.
- It keeps visual state changes, style changes, and map-mode level notifications under one shared event language.
- Functionally this file delivers the signaling surface for incremental province sync and reactive map behavior.

### gpu_bridge.rs

- GPU bridge for translating rich province registry state into tightly packed records suitable for direct shader consumption.
- The file strips province visuals down to a deterministic binary layout so rendering can upload stable arrays rather than reinterpret high-level Rust structures on the fly.
- Sorted record building keeps province ordering predictable across runs, which matters for synchronization and debugging.
- Functionally this file delivers the structured handoff from province data ownership to GPU-ready style buffers.

### gpu_upload.rs

- Province texture upload layer for moving grid-derived ids, border indices, and auxiliary fields from CPU memory into GPU-friendly texture resources.
- The file standardizes texture shapes and formats so every upload path speaks the same low-level contract for province data.
- Packing helpers keep byte layout rules centralized, which reduces the chance of subtle mismatches between generation code, upload code, and tests.
- This is not generic rendering infrastructure but province-specific transfer logic shaped around the module's data products.
- Keeping the upload details here lets registry and renderer code stay focused on map meaning instead of texture plumbing.
- Functionally this file delivers the last CPU-to-GPU step for province id maps, border textures, and distance data.

### import.rs

- Province import pipeline for turning external cartography assets into live engine-native registry data without manual per-province construction.
- The file reads color maps, metadata tables, and optional structured definitions as one coordinated ingestion process instead of a loose collection of converters.
- Marker sanitization is part of that process because capital and label hint pixels must be interpreted semantically and then repaired back into ordinary province ownership.
- Neighbor search logic resolves ambiguous marker ownership from surrounding color context, which is essential for real authored maps that encode helper pixels inside regions.
- CSV and TOML parsing bind visual source data to game ids, names, terrain, and other metadata expected by the runtime registry.
- Deterministic color derivation and label extraction keep imported provinces visually usable even when the source assets provide only partial semantic structure.
- By the time this pipeline finishes, capitals, label baselines, style seeds, and attributes are already wired into the same authoritative province model.
- Functionally this file delivers the map-ingestion machinery that converts external province assets into a ready-to-render and ready-to-query province runtime.

### labels.rs

- Label-anchor helper for finding meaningful province centers from span geometry rather than relying on arbitrary bounding-box guesses.
- The file accumulates pixel-weighted position data so each province can receive a center point tied to its actual occupied shape.
- Functionally this file delivers the geometric core used for stable province label placement.

### map_modes.rs

- Map-mode configuration layer for province rendering where the same geometry must support multiple semantic views such as political, terrain, or visibility overlays.
- The file treats each mode as authored data registered at runtime, allowing game code to decide which province property should drive visible color and presentation.
- That indirection keeps the renderer generic while still letting projects define radically different strategic lenses over the same province set.
- Mode lookup and color resolution live here so rendering code can ask for final style intent instead of interpreting per-mode config itself.
- Functionally this file delivers the policy surface that tells the province renderer how to translate province state into view-specific color meaning.

### mod.rs

- Province runtime module for irregular region maps that need authoritative state, import tooling, geometry extraction, GPU preparation, and on-screen rendering in one connected system.
- It treats provinces as semantic map entities rather than tilemap cells, combining topology, styling, labels, capitals, and change tracking into a single map stack.
- The module also owns the bridges that move province data from imported assets through cached geometry and into renderable outputs.
- Functionally this file is the high-level entry point for province-based cartography, visualization, and region-centric gameplay support.

### properties.rs

- Per-province property store for game-defined metadata that should live beside map identity without hard-coding economy or strategy logic into the engine core.
- The file gives each province a flexible typed key-value table so scripts can attach stats, ownership signals, or gameplay annotations while keeping storage centralized.
- Serialization support means those values can round-trip through save flows without custom glue for every separate property family.
- Functionally this file delivers the extensible metadata layer that makes the province runtime useful beyond pure rendering.

### province_grid.rs

- Province-grid extraction engine for converting color-coded map imagery into discrete province ids and the geometric structures that later systems depend on.
- The file begins at pixel level, assigning ownership by unique source colors and preserving reverse lookup between ids and their originating map colors.
- From that raw ownership grid it derives adjacency relationships, which are the topological backbone for province routing and border semantics.
- Span extraction turns irregular filled regions into horizontal runs that are much cheaper to render and analyze than full per-pixel scans.
- Border segment generation and polygon tracing add shape-aware outputs suitable for outlines, hit testing, and geometry-oriented tooling.
- Simplification keeps traced contours readable and compact instead of mirroring every staircase artifact from the raster source.
- Binary persistence support makes those derived structures reusable across loads, which matters for large province maps.
- This file therefore serves as the structural decoder that turns painted cartographic data into engine-native region geometry.
- It is lower-level than the registry but richer than a raw image loader because it extracts the real spatial relationships embedded in the province map.
- Functionally this file delivers the pixel-to-province geometry foundation for the entire province subsystem.

### registry.rs

- Authoritative province registry that holds the full living state of a province map, from region identity and geometry to style, labels, and incremental change history.
- The file is the module's main source of truth, joining pixel-derived structure with higher-level metadata such as political color, terrain, fog, visibility, and custom attributes.
- Fast lookup paths matter here because gameplay, rendering, and tools all need to move quickly between coordinates, province ids, and region records.
- Adjacency ownership is stored as first-class topology rather than recomputed on demand, which keeps neighborhood and border reasoning efficient and consistent.
- Capital markers, label baselines, and province text live alongside style so visual presentation remains attached to the same province identity that game logic uses.
- Monotonic revisions and ordered change logs make the registry incrementally observable, which is important for sync, UI refresh, and Lua-facing event delivery.
- Pair-specific border overrides give the map a place to express relationship semantics like coast, alliance, or war at the edge between provinces instead of only per province.
- Functionally this file delivers the central province runtime database that every other province feature reads from or writes to.

### render.rs

- Province renderer for turning abstract registry state into concrete draw commands that express political regions, labels, capitals, and border semantics on screen.
- The file works from cached province geometry and active map-mode policy so the same province data can be projected into different strategic views without rebuilding the map model.
- Viewport culling keeps large maps practical by limiting work to the currently visible window instead of brute-forcing every province each frame.
- Fill generation based on span geometry gives irregular regions a raster-efficient rendering path that still respects per-province styling.
- Border drawing layers additional meaning through type configs and pair-specific overrides, making the edges between provinces visually informative rather than decorative only.
- Capitals and labels add orientation and identity, keeping the renderer tied to map readability as well as raw color fill.
- Interaction-oriented highlights ensure the same rendering path can surface hover and selection feedback for tools or gameplay UI.
- Functionally this file delivers the visible province map assembled from registry state, view transforms, and style policy.

### routing.rs

- Province-routing helper layer for asking strategic map questions about reachability, shortest paths, and isolated clusters across province adjacencies.
- The file offers both unweighted and weighted traversal styles so games can move from simple neighbor hops to cost-aware movement without swapping data models.
- Connectivity and component helpers make the map graph useful for analysis, not just for single-route requests.
- These routines stay separate from the core registry so graph algorithms do not crowd the state store itself.
- Functionally this file delivers travel and connectivity reasoning over the province adjacency network.

### topology.rs

- Province adjacency graph for representing which regions touch each other once the raster map has been decoded into province ids.
- The file keeps neighbor lists sorted and deduplicated so adjacency queries remain compact, deterministic, and cheap to inspect.
- Rebuild logic turns raw province pairs into a clean undirected graph while filtering out meaningless self-links.
- Functionally this file delivers the topological skeleton that route search, border logic, and province relationship queries depend on.

### types.rs

- Core province domain types for expressing identity, border semantics, style, and snapshot state with names that match the map system's real concepts.
- The file gives province ids stronger meaning than plain integers while also defining the compact style and border structures that other province layers share.
- Snapshot forms matter because callers often need a stable read-only view of province state without borrowing the full mutable registry.
- By concentrating these definitions here, the module keeps shared province vocabulary consistent across import, rendering, routing, and Lua exposure.
- Functionally this file delivers the common type language that holds the province subsystem together.

### view_transform.rs

- Pure view-transform helpers for moving between screen space, map space, and province-cell space without tying camera math to registry ownership.
- The file handles fitting, anchored zoom, and coordinate conversion in a way that stays numerically safe even when dimensions or inputs are degenerate.
- Keeping these transforms pure makes them easy to reuse from rendering, picking, and tooling without hidden mutable state.
- Functionally this file delivers the camera and projection math that lets province maps be viewed, fitted, and queried interactively.

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
- `LProvinceRegistry:findIsolatedProvinces(owner_attr) -> integer[]`: Returns provinces that have no adjacent province with the same owner attribute.
- `LProvinceRegistry:findRoute(from_id, to_id, cost_fn?) -> table`: Finds a route between two provinces using BFS or Dijkstra when `cost_fn` is supplied.
- `LProvinceRegistry:findRoutes(pairs, cost_fn?) -> table`: Finds routes for a batch of `{from, to}` pairs.
- `LProvinceRegistry:fitCamera(screen_w, screen_h, pixel_size?) -> number, number, number`: Computes camera position and zoom so the entire province map fits within the given screen dimensions.
- `LProvinceRegistry:getAt(x, y) -> integer`: Returns the province ID at the given grid cell coordinates. Returns 0 if the cell is unowned (sea, wasteland, etc.).
- `LProvinceRegistry:getBorderClass(a, b) -> integer`: Backward-compatible alias for getBorderType. Returns the border type ID.
- `LProvinceRegistry:getBorderPairStyle(a, b) -> table`: Returns the style override for a specific adjacency pair, or nil when unset.
- `LProvinceRegistry:getBorderType(a, b) -> integer`: Returns the border type ID (0-255) between two adjacent provinces, or nil if not set.
- `LProvinceRegistry:getChangesSince(revision) -> table`: Returns all province changes that occurred after the given revision. Each entry contains the revision number and a change record describing what was modified (political_color, terrain_type, border_style, fog_state, visibility_state, or border_class).
- `LProvinceRegistry:getConnectedComponents() -> table`: Returns connected components in the province adjacency graph.
- `LProvinceRegistry:getHeight() -> integer`: Returns the height of the province grid in cells (pixels of the source PNG).
- `LProvinceRegistry:getMapMode() -> string`: Returns the name of the currently active map mode.
- `LProvinceRegistry:getName() -> string`: Returns the string name used to identify this registry in the province system.
- `LProvinceRegistry:getNeighbors(id) -> integer[]`: Returns a table of province IDs that share a border with the given province.
- `LProvinceRegistry:getProvince(id) -> table`: Returns a snapshot table describing a single province: its ID, revision, style (political_color, terrain_type, border_style, fog_state, visibility_state), centroid, and custom attributes.
- `LProvinceRegistry:getRevision() -> integer`: Returns the current change revision counter. Incremented on every mutation (color, terrain, border, fog changes). Use with `getChangesSince` for incremental updates.
- `LProvinceRegistry:getWidth() -> integer`: Returns the width of the province grid in cells (pixels of the source PNG).
- `LProvinceRegistry:importMetadataFromFiles(opts) -> table`: Bulk-imports province metadata (colors, capitals, labels, terrain) from external files (PNG color map, CSV color table, TOML province definitions, marker PNG). Returns a summary of how many provinces were mapped.
- `LProvinceRegistry:isConnected(from_id, to_id) -> boolean`: Returns true when there is at least one route between two provinces.
- `LProvinceRegistry:provinceCount() -> integer`: Returns the total number of distinct provinces in this registry (excluding ID 0).
- `LProvinceRegistry:provinceIds() -> integer[]`: Returns a sequential table of all province IDs in this registry.
- `LProvinceRegistry:provinceSpans() -> table`: Returns the raw span data for all provinces. Each span is a horizontal run of cells belonging to one province, useful for custom rendering or spatial analysis.
- `LProvinceRegistry:registerBorderType(type_id, config) -> nil`: Registers a border type config by ID. Defines visual appearance for borders of this type.
- `LProvinceRegistry:registerMapMode(name, config) -> nil`: Registers a named map mode with display configuration. Overwrites if name exists.
- `LProvinceRegistry:render(opts?) -> nil`: Renders the province map to the screen using the current camera and style settings. Generates draw commands for fills, borders, labels, and capitals based on the provided options.
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
- `LProvinceRegistry:setTerrainType(id, terrain_type) -> boolean`: Sets the terrain type index for a province. Terrain type controls which fill color or texture is used in terrain map mode.
- `LProvinceRegistry:setVisibilityState(id, visibility_state) -> boolean`: Sets the render visibility state for a province. `0` = hidden (no fill/border/capital/label), `1` = discovered (gray fill only), `2+` = fully visible.
- `LProvinceRegistry:totalAttrForOwner(owner_attr, owner_val, sum_attr) -> number`: Sums a numeric attribute for all provinces with matching owner value.
- `LProvinceRegistry:type() -> string`: Returns the type name string for this userdata object.
- `LProvinceRegistry:typeOf(name) -> boolean`: Checks whether this object matches the given type name. Returns true for "LProvinceRegistry" and "Object".

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
