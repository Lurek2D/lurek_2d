# globe

## TL;DR

- Manages spherical map registries, orbit projections, picking hit tests, and split views.
- Supports layers, day-night cycles, LOD annotations, fog-of-war masks, and region routing.

## General Info

- Module group: `Feature Systems`
- Source path: `src/globe/`
- Binding: `src/lua_api/globe_api.rs`
- Namespace: `lurek.globe`
- Lua API surface: `12` functions, `4` types, `92` methods
- Rust test path(s): tests/rust/unit/globe_tests.rs
- Lua test path(s): tests/lua/unit/test_globe_unit.lua

## Summary

- This module gives users an interactive globe runtime for strategy maps, world overviews, and geospatial gameplay systems.
- It models regions on a sphere and exposes camera controls tuned for planetary navigation.
- Screen interactions can be translated into latitude/longitude space for picking and map actions.
- Region topology support enables adjacency-aware mechanics such as routing, influence spread, and traversal rules.
- Layer systems let teams overlay thematic data like ownership, heatmaps, and tactical signals.
- Dynamic lighting supports day-night visualization cues that improve world readability.
- Atmosphere, borders, and style controls make globe presentation customizable for different game aesthetics.
- Marker and label tools allow rich annotation of cities, missions, routes, and points of interest.
- LOD-aware overlay behavior helps keep dense maps readable across zoom levels.
- Fog-of-war masks support per-viewer visibility, which is useful for multiplayer and asymmetric information gameplay.
- Reachability and pathfinding helpers support strategic route planning across region graphs.
- Province adapter support keeps political ownership systems synchronized with globe visuals.
- Multi-view composition allows side-by-side map views for compare, split command, or overview panels.
- Ingestion from TOML, image data, and generated seeds supports diverse authoring pipelines.
- Voronoi generation workflows enable procedural world partitioning directly in runtime tools.
- Export helpers let users move geometry out for offline editing or analysis.
- Sync utilities support cross-thread and system-to-system globe state updates.
- This module is useful for grand strategy, campaign maps, simulation dashboards, and educational geo interfaces.
- For users, it unifies rendering, interaction, topology, and overlays in one coherent spherical map system.
- It reduces custom math and glue code required to build globe-centric gameplay.
- The practical value is faster iteration on map mechanics and map presentation together.
- It also improves observability by exposing map state and interactions through script-friendly APIs.
- Overall, users get a complete planetary map feature stack rather than isolated rendering primitives.
- That makes globe-driven experiences feasible without external GIS-style toolchains.

This module primarily collaborates with `math`, `pathfind`, `province`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Imports

- `math`: Imports or references `src/math/`. Cross-group dependency from `Edge/Integration` into `Foundations`.
- `pathfind`: Imports or references `src/pathfind/`. Cross-group dependency from `Edge/Integration` into `Feature Systems`.
- `province`: Imports or references `src/province/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `render`: Imports or references `src/render/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Edge/Integration` into `Core Runtime`.

## Files

### composition.rs

- Provides split-view globe composition that merges multiple named views into one render batch. `globe/composition` delivers the composition implementation for the globe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Applies per-entry viewport centers while preserving each globe's camera-relative projection behavior. The file owns or coordinates data contracts including `SplitViewport`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Delivers multi-panel frame assembly for comparative or tactical map presentation. Public callable behavior is centered on `emit_split_frame`, while method-level behavior such as no named public items stays attached to the local data model and invariants.

### draw.rs

- Provides full globe frame emission that converts world map state into ordered render commands. `globe/draw` delivers the draw implementation for the globe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Draws projected regions with fog, lighting, overlays, and optional texture contribution. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Renders borders, atmosphere, and arcs to preserve geographic structure and visual depth cues. Public callable behavior is centered on `emit_globe_frame`, `project_arc`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Integrates marker and label drawing with animation and LOD-aware visibility rules. Runtime integration reaches sibling engine areas through crate modules `globe`, `math`, `render`, `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Applies camera projection and world parameters consistently across all rendered primitives. External integration uses `super`, `slotmap`, `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Supports layered heat and style effects so thematic map signals remain legible. The file boundary separates globe implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.

### export.rs

- Provides globe geometry export helpers that convert region polygons into portable mesh text output. `globe/export` delivers the export implementation for the globe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Emits flat OBJ data with deterministic region object grouping for downstream tooling. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Delivers a simple export path for inspection, conversion, and offline map processing workflows. Public callable behavior is centered on `export_regions_to_obj`, `export_provinces_to_obj`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- `globe/export` delivers the export implementation for the globe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.

### fog.rs

- Fog-of-war state storage with per-region two-bit visibility tiers (Hidden, Explored, Visible) enabling strategic information gating and map knowledge.
- Maintains per-viewer FogMask instances so different observers independently track map revelation, supporting multiplayer scenarios and split-screen views.
- Provides reveal(), hide(), explore(), and toggle() operations for direct gameplay events plus batch reveal for efficient region updates.
- Encodes fog state as base64-packed two-bit values enabling compact save-file persistence and safe transmission across network boundaries.
- Exposes visibility and explored subset queries returning region IDs for UI rendering, camera targeting, and game logic decision systems.

### label.rs

- Provides id-keyed globe label storage for map annotations positioned by latitude and longitude. `globe/label` delivers the label implementation for the globe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Supports add, remove, update, and visibility operations for dynamic labeling workflows. The file owns or coordinates data contracts including `LabelStore`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Applies LOD-aware filtering so text density scales with camera detail level. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `add`, `remove`, `get`, `get_mut`, `set_visible`, and 6 more stays attached to the local data model and invariants.
- Maintains stable iteration outputs used by rendering and debugging interfaces. Runtime integration reaches sibling engine areas through crate modules `globe`, which explains the subsystem dependencies an agent should inspect before changing behavior.

### layer.rs

- Provides named globe layer storage that overlays per-region color and visibility modifications. `globe/layer` delivers the layer implementation for the globe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Supports insert, remove, lookup, and alpha control for composable thematic map styling. The file owns or coordinates data contracts including `LayerStore`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Resolves effective colors in z-order so stacked overlays produce deterministic final output. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `add`, `remove`, `get`, `get_mut`, `set_province_color`, and 7 more stays attached to the local data model and invariants.
- Delivers the overlay-composition layer used by draw logic and gameplay visualization. Runtime integration reaches sibling engine areas through crate modules `globe`, which explains the subsystem dependencies an agent should inspect before changing behavior.

### lighting.rs

- Provides globe lighting helpers that derive sun direction and regional light intensity over time. `globe/lighting` delivers the lighting implementation for the globe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Computes diffuse contribution with ambient floors to keep night-side visuals readable. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Supports batch intensity and terminator blending calculations for smooth day-night transitions. Public callable behavior is centered on `sun_direction`, `province_intensity`, `compute_intensities`, `terminator_alpha`, while method-level behavior such as no named public items stays attached to the local data model and invariants.

### loader.rs

- Provides globe region-loading workflows from TOML, raster grids, and generated Voronoi seed sources. `globe/loader` delivers the asset or data loading path for the globe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Parses lightweight structured input into normalized region records with geometry and adjacency data. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Converts intermediate builder state into shared globe region types used across the subsystem. Public callable behavior is centered on `load_from_toml_str`, `load_from_toml_file`, `load_from_png_file`, `load_from_province_grid`, `generate_voronoi_provinces`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Extracts bounds and neighbor hints from image-driven province maps for quick content bootstrapping. Runtime integration reaches sibling engine areas through crate modules `globe`, `math`, `province`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Handles primitive parsing and validation to keep load-time failures explicit and actionable. External integration uses `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Supports both in-memory string input and file-based ingestion paths for tooling flexibility. The file boundary separates globe implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.

### marker.rs

- Provides stable-id globe marker storage for pins and point annotations on planetary surfaces. `globe/marker` delivers the marker implementation for the globe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Supports marker insertion, removal, movement, and lookup by id or classification type. The file owns or coordinates data contracts including `MarkerStore`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Manages marker visibility and custom attributes for flexible runtime presentation. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `add`, `remove`, `get`, `get_mut`, `move_to`, and 8 more stays attached to the local data model and invariants.
- Keeps marker collections deterministic for rendering and interaction queries. Runtime integration reaches sibling engine areas through crate modules `globe`, which explains the subsystem dependencies an agent should inspect before changing behavior.

### mod.rs

- Provides the high-level globe module boundary for region topology, projection, and visual overlay orchestration. `globe/mod` is the globe module index, declaring `composition`, `draw`, `export`, `fog`, `label`, and 12 more so agents can identify which files own each feature slice before opening implementation code.
- Connects rendering, fog state, markers, labels, layers, and picking into one map-runtime surface. `src/globe/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `fog::{FogMask, FogStore}`, `picking::PickResult`, `projection::OrbitCamera`, `registry::{Globe, GlobeRegistry}`, and 7 more centralized for the globe subsystem.
- Supports synchronization and loading flows so globe state can be updated from external game systems. The file documents how globe submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.
- Delivers a cohesive planetary-view feature set for strategic map presentation and interaction. Agents should read this index to choose the narrow owner file first, because it maps names such as `composition`, `draw`, `export`, `fog`, `label`, and 12 more to concrete implementation responsibilities.
- `globe/mod` is the globe module index, declaring `composition`, `draw`, `export`, `fog`, `label`, and 12 more so agents can identify which files own each feature slice before opening implementation code.
- `src/globe/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `fog::{FogMask, FogStore}`, `picking::PickResult`, `projection::OrbitCamera`, `registry::{Globe, GlobeRegistry}`, and 7 more centralized for the globe subsystem.

### picking.rs

- Provides globe picking helpers that translate screen-space clicks into front-hemisphere surface hits. `globe/picking` delivers the picking implementation for the globe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Converts pointer coordinates into spherical latitude and longitude using the current orbit camera. The file owns or coordinates data contracts including `SurfaceHit`, `PickResult`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Applies geographic point-in-polygon tests so province and region queries share one hit surface. Public callable behavior is centered on `point_in_geo_polygon`, `point_in_geo_region`, `screen_to_surface`, `pick`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Exposes marker and region selection results consumed by rendering, UI, and gameplay layers. Runtime integration reaches sibling engine areas through crate modules `globe`, `math`, which explains the subsystem dependencies an agent should inspect before changing behavior.

### projection.rs

- Provides globe projection math driven by an orbit camera with latitude, longitude, and zoom control. `globe/projection` delivers the projection implementation for the globe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Builds view transforms from globe rotation, axial tilt, and camera orientation inputs. The file owns or coordinates data contracts including `OrbitCamera`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Projects points and regions from spherical coordinates into screen-space render geometry. Public callable behavior is centered on `build_view_matrix`, `project_point`, `project_region`, `project_geo_loop`, `project_province`, and 3 more, while method-level behavior such as `clamp`, `pan`, `zoom_by`, `lod` stays attached to the local data model and invariants.
- Applies facing checks and depth culling to reject back-hemisphere geometry during projection. Runtime integration reaches sibling engine areas through crate modules `globe`, `math`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Delivers camera and projection utilities used by drawing, picking, and interaction code paths. External integration uses `super`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### province_adapter.rs

- Provides a bridge that applies province-registry ownership and visibility state onto globe regions. `globe/province_adapter` delivers the province adapter implementation for the globe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

### registry.rs

- Provides mutable globe state that aggregates topology, camera, fog, overlays, and interaction data. `globe/registry` delivers the lookup registry and handle ownership for the globe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Owns region storage operations together with markers, labels, layers, arcs, and heat visual layers. The file owns or coordinates data contracts including `Globe`, `GlobeRegistry`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Integrates camera projection and picking paths so selection and rendering share one state container. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `add_region`, `remove_region`, `get_region`, `get_region_mut`, `region_count`, and 33 more stays attached to the local data model and invariants.
- Emits full-frame render commands from current globe state for deterministic map visualization. Runtime integration reaches sibling engine areas through crate modules `globe`, `render`, `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Caches sector and reachability information to support strategic lookup and path-cost workflows. External integration uses `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### sphere.rs

- Provides spherical geometry helpers for converting between latitude-longitude and unit-vector space. `globe/sphere` delivers the sphere implementation for the globe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Computes great-circle distance and interpolation for geodesic path and arc construction. The file owns or coordinates data contracts including `Mat3x3`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Supplies ray-sphere intersection tests used by projection and picking style calculations. Public callable behavior is centered on `lat_lon_to_unit`, `unit_to_lat_lon`, `great_circle_distance`, `great_circle_path`, `ray_sphere_intersect`, and 3 more, while method-level behavior such as `identity`, `from_cols`, `mul_vec`, `mul_mat`, `transpose` stays attached to the local data model and invariants.
- Defines lightweight 3x3 rotation matrices and multiplication helpers for globe transforms. Runtime integration reaches sibling engine areas through crate modules `math`, which explains the subsystem dependencies an agent should inspect before changing behavior.

### sync.rs

- Provides globe snapshot transfer structures for cross-thread synchronization and state exchange. `globe/sync` delivers the sync implementation for the globe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Defines channel wrappers and snapshot payload shapes used to move globe state safely. The file owns or coordinates data contracts including `GlobeSyncSnapshot`, `GlobeSyncChannel`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Supports building and applying snapshots to keep remote and local globe views aligned. Public callable behavior is centered on `build_snapshot`, `apply_snapshot`, while method-level behavior such as `new` stays attached to the local data model and invariants.
- Delivers the synchronization utility layer for background simulation integration. Runtime integration reaches sibling engine areas through crate modules `globe`, which explains the subsystem dependencies an agent should inspect before changing behavior.

### topology.rs

- Provides region-topology graph storage with cached adjacency, centroids, and tagged border edges. `globe/topology` delivers the topology implementation for the globe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Supports insertion, removal, and mutation workflows while keeping lookup caches coherent. The file owns or coordinates data contracts including `RegionGraph`, `ProvinceGraph`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Integrates pathfinding-friendly queries for route, cost, and reachability evaluation across regions. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `insert`, `remove`, `get`, `get_mut`, `iter`, and 12 more stays attached to the local data model and invariants.
- Exposes neighbor and region iteration helpers used by rendering and gameplay systems. Runtime integration reaches sibling engine areas through crate modules `globe`, `pathfind`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Delivers the structural map-graph backbone that powers globe connectivity logic. External integration uses `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### types.rs

- Provides the shared globe data model defining regions, overlays, markers, labels, arcs, and view artifacts. `globe/types` delivers the shared type definitions and data contracts for the globe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Encodes geographic geometry with centroids, adjacency, edge tags, and per-region render attributes. The file owns or coordinates data contracts including `RegionId`, `RegionPart`, `Region`, `FogState`, `HeatLayer`, and 14 more, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Defines globe specification parameters that drive atmosphere, lighting, rotation, and border behavior. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `raw`, `with_data`, `with_parts_data`, `from_parts`, `primary_vertices`, and 2 more stays attached to the local data model and invariants.
- Supplies layer and heat-overlay structures used to blend thematic map information at runtime. Runtime integration reaches sibling engine areas through crate modules `globe`, `math`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Models marker and label style data with visibility, pulse, and level-of-detail controls. External integration uses `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Includes projection result types for screen-space rendering and interaction pipelines. The file boundary separates globe implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.



## Lua API Ref

### Functions

- `lurek.globe.generateVoronoi(name, seeds_tbl, spec_tbl?) -> LGlobe`: Creates a globe and populates provinces from latitude-longitude seed points.
- `lurek.globe.get(name) -> LGlobe`: Returns a globe from the module registry by name.
- `lurek.globe.greatCircleDistance(la, lo, lb, lo2) -> number`: Computes great-circle distance between two latitude-longitude points.
- `lurek.globe.greatCirclePath(la, lo, lb, lo2, n) -> table`: Computes sampled latitude-longitude points along a great-circle path.
- `lurek.globe.latLonToUnit(lat, lon) -> table`: Converts latitude and longitude to a unit-sphere 3D vector table.
- `lurek.globe.loadFromPNG(name, png_path, spec_tbl?) -> LGlobe`: Creates a globe and populates provinces from a PNG file.
- `lurek.globe.loadFromTOML(name, toml_src, spec_tbl?) -> LGlobe`: Creates a globe and populates provinces from TOML source text.
- `lurek.globe.loadFromTOMLFile(name, path, spec_tbl?) -> LGlobe`: Creates a globe and populates provinces from a TOML file path.
- `lurek.globe.new(name, spec_tbl?) -> LGlobe`: Creates a named globe with optional specification fields in the module registry.
- `lurek.globe.newRegistry() -> LGlobeRegistry`: Creates an empty globe registry handle independent from the module registry.
- `lurek.globe.raySphereIntersect(ox, oy, oz, dx, dy, dz, radius) -> number`: Intersects a 3D ray with a sphere and returns the nearest positive hit distance.
- `lurek.globe.remove(name) -> boolean`: Removes a globe from the registry by name.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LGlobe Type

- Lua-side handle for a named globe stored inside a shared registry.

##### Fields

- No documented fields.

##### Methods

- `LGlobe:addArc(lat1, lon1, lat2, lon2, steps?) -> integer`: Adds a visible route arc between two latitude and longitude points.
- `LGlobe:addLabel(ltype, lat, lon, text) -> integer`: Adds a text label at latitude and longitude.
- `LGlobe:addLayer(name, z_order?) -> nil`: Adds a render layer with optional z-order.
- `LGlobe:addMarker(mtype, lat, lon, label?) -> integer`: Adds a marker at latitude and longitude with an optional label.
- `LGlobe:addProvince(p) -> boolean`: Adds a province described by id, centroid, polygon vertices or multipart geometry, neighbors, and optional base color.
- `LGlobe:addRegion(p) -> boolean`: Adds a region described by id, centroid, polygon vertices or multipart geometry, neighbors, and optional base color.
- `LGlobe:applyMouseDrag(start_x, start_y, end_x, end_y) -> nil`: Applies a pointer drag to the globe camera using screen-space deltas.
- `LGlobe:applyWheelZoom(delta) -> nil`: Applies a wheel delta using an exponential zoom scale.
- `LGlobe:cacheReachability(faction, start_id, max_cost) -> nil`: Caches default-cost reachability for a named faction.
- `LGlobe:clearProvinceTexture(id) -> boolean`: Removes texture metadata from a province.
- `LGlobe:decodeFogBase64(viewer, payload) -> boolean`: Loads one viewer's fog state from a base64 string.
- `LGlobe:distanceBetweenMarkers(a, b) -> number`: Computes great-circle distance between two markers on the unit sphere.
- `LGlobe:draw(opts?) -> nil`: Emits the globe's render commands into the shared renderer command queue.
- `LGlobe:encodeFogBase64(viewer) -> string`: Serializes one viewer's fog state to a base64 string.
- `LGlobe:exportProvinceMeshOBJ() -> string`: Exports province geometry as Wavefront OBJ text, preserving multipart boundaries and hole loops.
- `LGlobe:findPath(from_id, to_id) -> integer[]`: Finds a default-cost province path between two province ids.
- `LGlobe:findPathWithCosts(from_id, to_id, opts?) -> table`: Finds a province path using caller-supplied traversal costs, blocked ids, and edge-tag surcharges.
- `LGlobe:getCachedReachability(faction) -> table`: Returns cached reachability costs for a faction.
- `LGlobe:getCamera() -> number`: Returns camera latitude, longitude, and zoom.
- `LGlobe:getEdgeTags(a, b) -> string[]`: Returns the sorted tag strings stored on a province edge.
- `LGlobe:getFogState(viewer, id) -> string`: Returns fog-of-war state for one viewer and province.
- `LGlobe:getLod() -> string`: Returns the camera-derived level-of-detail tier name.
- `LGlobe:getMarkerAttr(id, key) -> string`: Reads a string attribute from a marker.
- `LGlobe:getName() -> string`: Returns the registry name of this globe.
- `LGlobe:getNeighbors(id) -> integer[]`: Returns neighboring province ids for a province.
- `LGlobe:getProvinceAttr(id, key) -> string`: Reads a string attribute from a province.
- `LGlobe:getProvinceSector(id) -> string`: Returns the sector name assigned to a province.
- `LGlobe:getRegionAttr(id, key) -> string`: Reads a string attribute from a semantic region.
- `LGlobe:getSectorProvinces(sector) -> integer[]`: Returns province ids assigned to a sector.
- `LGlobe:getTimeOfDay() -> number`: Returns globe time of day. This method is available to Lua scripts.
- `LGlobe:hideProvince(viewer, id) -> nil`: Hides a province for one fog-of-war viewer.
- `LGlobe:isVisible(viewer, id) -> boolean`: Returns whether a province is visible for one fog-of-war viewer.
- `LGlobe:moveMarker(id, lat, lon) -> boolean`: Moves a marker to latitude and longitude coordinates.
- `LGlobe:pan(dlat, dlon) -> nil`: Pans the globe camera by latitude and longitude deltas.
- `LGlobe:pick(sx, sy) -> integer`: Picks a province at screen coordinates.
- `LGlobe:pickLatLon(sx, sy) -> number`: Picks at screen coordinates and returns the hit surface latitude and longitude.
- `LGlobe:pickMarker(sx, sy, radius?) -> integer`: Returns the nearest visible marker at a screen position within an optional pixel radius.
- `LGlobe:pickRaycast(sx, sy, steps?) -> integer`: Samples along the screen-space line from the globe center to the target and returns the first hit province.
- `LGlobe:pickRegions(sx, sy) -> integer[]`: Returns semantic region ids under a screen-space hit.
- `LGlobe:pickSurface(sx, sy, marker_radius?) -> table`: Resolves a screen-space hit into globe surface data plus province, marker, and semantic-region hits.
- `LGlobe:provinceCount() -> integer`: Returns the number of rendered provinces in this globe.
- `LGlobe:reachable(start_id, max_cost) -> table`: Returns provinces reachable from a start province within a cost budget.
- `LGlobe:reachableWithCosts(start_id, max_cost, opts?) -> table`: Returns provinces reachable under caller-supplied traversal costs, blocked ids, and edge-tag surcharges.
- `LGlobe:regionCount() -> integer`: Returns the number of stored semantic regions in this globe.
- `LGlobe:regionsAtLatLon(lat, lon) -> integer[]`: Returns semantic region ids containing a latitude-longitude point.
- `LGlobe:removeArc(id) -> boolean`: Removes an arc by id. This method is available to Lua scripts.
- `LGlobe:removeHeatLayer(name) -> boolean`: Removes a heat layer by name. This method is available to Lua scripts.
- `LGlobe:removeLabel(id) -> boolean`: Removes a label by id. This method is available to Lua scripts.
- `LGlobe:removeLayer(name) -> boolean`: Removes a render layer by name. This method is available to Lua scripts.
- `LGlobe:removeMarker(id) -> boolean`: Removes a marker by id. This method is available to Lua scripts.
- `LGlobe:removeProvince(id) -> boolean`: Removes a region by id. This method is available to Lua scripts.
- `LGlobe:removeRegion(id) -> boolean`: Removes a region by id. This method is available to Lua scripts.
- `LGlobe:revealAll(viewer) -> nil`: Reveals every province for one fog-of-war viewer.
- `LGlobe:revealProvince(viewer, id) -> nil`: Reveals a province for one fog-of-war viewer.
- `LGlobe:screenDeltaToPan(dx, dy) -> number`: Converts a screen-space drag delta into latitude and longitude pan deltas.
- `LGlobe:screenToLatLon(sx, sy) -> number`: Converts a visible screen position into globe latitude, longitude, and unit-sphere coordinates.
- `LGlobe:setActiveViewer(viewer?) -> nil`: Sets the active fog-of-war viewer name or clears it.
- `LGlobe:setAutoRotationSpeed(dps) -> nil`: Sets automatic globe rotation speed.
- `LGlobe:setBorders(show) -> nil`: Enables or disables province border rendering.
- `LGlobe:setCamera(lat, lon, z) -> nil`: Sets camera latitude, longitude, and zoom.
- `LGlobe:setEdgeTags(a, b, tags) -> boolean`: Replaces the tag set stored on an existing province edge.
- `LGlobe:setFogState(viewer, id, state) -> nil`: Sets fog-of-war state for one viewer and province.
- `LGlobe:setHeatLayer(name, attr_key, min, max, alpha) -> nil`: Creates or replaces a heat layer that maps province attributes into colors.
- `LGlobe:setLabelText(id, text) -> boolean`: Changes text for an existing label.
- `LGlobe:setLabelVisible(id, vis) -> boolean`: Shows or hides a label. This method is available to Lua scripts.
- `LGlobe:setLayerAlpha(name, alpha) -> boolean`: Sets render layer alpha. This method is available to Lua scripts.
- `LGlobe:setLayerColor(layer, id, r, g, b, a) -> boolean`: Sets a province color override inside a render layer.
- `LGlobe:setLayerVisible(name, vis) -> boolean`: Shows or hides a render layer. This method is available to Lua scripts.
- `LGlobe:setMarkerAttr(id, key, val) -> boolean`: Sets a string attribute on a marker.
- `LGlobe:setMarkerColor(id, r, g, b, a?) -> boolean`: Sets marker tint color.
- `LGlobe:setMarkerIconTexture(id, tex_raw?) -> boolean`: Assigns or clears a raw texture handle for a marker icon.
- `LGlobe:setMarkerPulse(id, hz, amp) -> boolean`: Sets marker pulse frequency and amplitude.
- `LGlobe:setMarkerRotation(id, dps) -> boolean`: Sets marker rotation speed. This method is available to Lua scripts.
- `LGlobe:setMarkerShape(id, shape) -> boolean`: Sets the vector fallback shape used by a marker.
- `LGlobe:setMarkerSize(id, size) -> boolean`: Sets marker size in screen units.
- `LGlobe:setMarkerVisible(id, vis) -> boolean`: Shows or hides a marker. This method is available to Lua scripts.
- `LGlobe:setProvinceAttr(id, key, val) -> boolean`: Sets a string attribute on a province.
- `LGlobe:setProvinceSector(id, sector) -> boolean`: Assigns a province to a named sector.
- `LGlobe:setProvinceTexture(id, tex_raw, u0, v0, u1, v1) -> boolean`: Assigns a raw texture handle and UV rectangle to a province.
- `LGlobe:setRegionAttr(id, key, val) -> boolean`: Sets a string attribute on a semantic region.
- `LGlobe:setRotation(deg) -> nil`: Sets globe rotation angle. This method is available to Lua scripts.
- `LGlobe:setTimeOfDay(t) -> nil`: Sets globe time of day modulo 24 hours.
- `LGlobe:type() -> string`: Returns the Lua-visible type name for this globe handle.
- `LGlobe:typeOf(name) -> boolean`: Returns whether this globe handle matches a supported type name.
- `LGlobe:update(dt) -> nil`: Advances globe simulation timers and animated state.
- `LGlobe:zoom(factor) -> nil`: Multiplies the globe camera zoom by a factor.

#### LGlobeGreatCirclePathResult Type

- Generated result shape from @field tags.

##### Fields

- `lat` (`number`): Lat.
- `lon` (`number`): Lon.

##### Methods

- No documented methods.

#### LGlobeLatLonToUnitResult Type

- Generated result shape from @field tags.

##### Fields

- `x` (`number`): X.
- `y` (`number`): Y.
- `z` (`number`): Z.

##### Methods

- No documented methods.

#### LGlobeRegistry Type

- Lua-side handle for creating and locating named globes in one registry.

##### Fields

- No documented fields.

##### Methods

- `LGlobeRegistry:get(name) -> LGlobe`: Returns a globe handle by registry name.
- `LGlobeRegistry:names() -> string[]`: Returns all globe names currently stored in this registry.
- `LGlobeRegistry:new(name, spec_tbl?) -> LGlobe`: Creates a named globe with optional specification fields.
- `LGlobeRegistry:remove(name) -> boolean`: Removes a globe from the registry by name.
- `LGlobeRegistry:type() -> string`: Returns the Lua-visible type name for this globe registry handle.
- `LGlobeRegistry:typeOf(name) -> boolean`: Returns whether this registry handle matches a supported type name.

## References

- `math`: Imports or references `src/math/`. Cross-group dependency from `Edge/Integration` into `Foundations`.
- `pathfind`: Imports or references `src/pathfind/`. Cross-group dependency from `Edge/Integration` into `Feature Systems`.
- `province`: Imports or references `src/province/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `render`: Imports or references `src/render/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Edge/Integration` into `Core Runtime`.

## Notes

- No additional module-specific notes.
