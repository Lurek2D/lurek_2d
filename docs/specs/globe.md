<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/globe.md or source docstrings instead. -->

# globe

## TL;DR

- Manages spherical map registries, orbit projections, picking hit tests, and split views.
- Supports layers, day-night cycles, LOD annotations, fog-of-war masks, and region routing.

## General Info

- Module group: `Foundations`
- Source path: `src/globe`
- Binding: `src/lua_api/globe_api.rs`
- Namespace: `lurek.globe`
- Lua API surface: `12` functions, `4` types, `102` methods
- User-facing: `true`
- Plugin tier: `not_evaluated`

## Summary

- The `globe` module is the planetary-map surface for users who want a world-scale spherical view to behave as a full gameplay and tooling system instead of a decorative background.
- It combines region topology, spherical navigation, camera movement, picking, overlays, labels, markers, fog, lighting, and style control so the globe can serve as a strategic layer, simulation view, or inspectable data surface.
- The module owns both interaction and presentation: users can navigate the sphere, click into it, convert screen interactions into geographic meaning, and layer game-specific information on top.
- Region adjacency and route helpers matter because many globe-driven games treat the world as a graph of territories, paths, logistics, or influence rather than as a sphere to admire.
- Layer support keeps ownership, heatmaps, tactical overlays, visibility, and markers in one annotation surface, while lighting and atmosphere improve readability as well as mood.
- Province and world-state adapters keep the globe synchronized with larger simulation systems, and import or generation helpers make it practical across authored, procedural, and tool-facing workflows.
- Region topology is equally central. The globe often acts as a graph of territories, travel arcs, or influence zones, so adjacency, routing, and territory-aware lookup must remain queryable rather than being flattened away into generic mesh behavior.
- Overlay and marker support keep several kinds of information visible at once: ownership, danger, weather, heat, logistics, missions, visibility, faction presence, or educational annotation can coexist without each feature reinventing map decoration rules.
- Province adapters and world-state synchronization keep the planetary view grounded in the rest of the simulation. A campaign map is only useful when ownership, events, region metadata, and larger systems can flow into the same world representation.
- Spherical picking and camera movement remain especially important because a globe becomes strategically useful only when users can navigate it, inspect regions, and turn screen-space interaction into stable geographic meaning.
- The result is a world-view layer that supports strategy, geoscape-style play, simulation inspection, and data-driven presentation without forcing projects to collapse planetary logic into a flat approximation too early.
- Read `globe` as the owner of planetary interaction, topology, and visualization. Rendering shows the result, but this module decides how a spherical world is represented, navigated, annotated, and synchronized.

This module primarily collaborates with `math`, `pathfind`, `province`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Ownership

- Canonical source: `src/globe`
- Owning tier: `Foundations`
- Plugin tier: `not_evaluated`
- Lua binding owner: `src/lua_api/globe_api.rs`
- Referenced engine modules: `math`, `pathfind`, `province`, `render`, `runtime`

## Imports

- `math`: Imports or references `src/math/`. Dependency stays inside `Foundations` and should remain acyclic.
- `pathfind`: Imports or references `src/pathfind/`. Cross-group dependency from `Foundations` into `Feature Systems`.
- `province`: Imports or references `src/province/`. Cross-group dependency from `Foundations` into `Feature Systems`.
- `render`: Imports or references `src/render/`. Cross-group dependency from `Foundations` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Foundations` into `Core Runtime`.

## Source Files

### composition.rs

- Composes several named globe views into one render batch by overriding each globe camera's screen center.
- Owns SplitViewport and the frame assembly loop that clones camera pivots and reuses normal globe frame emission.
- Provides the layout boundary between GlobeRegistry state and split-screen style globe presentation workflows.

### draw.rs

- Generates the full globe render command stream from topology, camera, overlays, fog, markers, labels, and arcs.
- Owns the projected-region draw policy that blends lighting, atmosphere, borders, heat layers, textures, and fog.
- Projects region geometry and arcs through the current orbit camera so every primitive shares one spatial frame.
- Also renders markers and labels with LOD checks, pulse effects, and optional icon textures for strategic views.
- Provides the presentation boundary between globe state stores and the generic renderer command vocabulary.
- This file is where thematic overlays, marker glyphs, night shading, and atmospheric effects are coordinated.
- Neighboring changes usually involve projection math, fog semantics, resource keys, and region style contracts.
- Open this owner when the globe looks wrong even though source data is correct and available to the renderer.
- It is the right file for draw ordering bugs because no sibling module owns the final command assembly pipeline.

### export.rs

- Exports globe region geometry as portable OBJ text so maps can be inspected, converted, or processed offline.
- Owns region-loop traversal, hole stitching, polygon triangulation, and deterministic object and group naming.
- Writes both boundary line loops and optional filled meshes, preserving multipart regions and hole structure.
- Provides the outbound boundary between in-memory globe geometry and tool-friendly mesh text representations.
- This file is the right owner when export fidelity, triangulation choices, or naming conventions need revision.
- Neighboring edits usually involve RegionPart geometry, polygon utilities, and downstream content tool contracts.
- Open this owner when external mesh consumers fail even though the globe renders correctly inside the engine.

### fog.rs

- Owns globe fog-of-war masks that store Hidden, Explored, and Visible state for every supported region id.
- Maintains per-viewer FogMask instances so different observers can carry independent revelation and visibility sets.
- Provides reveal, hide, explore, toggle, batch update, and subset query helpers used by gameplay and UI logic.
- Encodes masks to and from packed base64 strings, making persistence and transport compact and deterministic.
- Acts as the state boundary between visibility gameplay rules and globe renderers that only need fog answers.
- Open this owner when viewer-specific fog semantics or serialized fog payloads need exact behavioral changes.

### label.rs

- Stores globe labels with stable ids so annotation text can be updated, moved, filtered, and rendered consistently.
- Owns label visibility, text mutation, geographic placement, and minimum LOD filtering for clutter control.
- Provides the state boundary between authored label semantics and draw code that only needs visible label records.
- Keeps iteration and id assignment deterministic so render and sync layers observe stable label identity.
- Open this owner when label lifecycle, text edits, or LOD gating behavior changes across the globe UI.

### layer.rs

- Stores named globe overlay layers that apply ordered region color overrides on top of each region's base style.
- Owns layer insertion, removal, visibility, alpha, region-color mutation, and z-order sorted resolution helpers.
- Provides the overlay state boundary between gameplay thematic maps and draw code that asks for effective colors.
- Open this owner when layer stacking, alpha policy, or region color override semantics need to be revised.

### lighting.rs

- Computes globe lighting helpers from time of day and axial tilt so day-night shading stays consistent everywhere.
- Owns sun direction, per-region diffuse intensity, batch intensity generation, and terminator alpha calculations.
- Provides the shading boundary between shared globe spec inputs and render code that only needs light coefficients.
- Open this owner when day-night balance, ambient floor behavior, or terminator blending needs direct adjustment.

### loader.rs

- Loads globe regions from TOML, PNG-derived province grids, and generated Voronoi seeds into shared region data.
- Owns TOML parsing helpers, intermediate record normalization, validation messages, and region conversion logic.
- Converts input geometry into Region and RegionPart values with centroids, neighbors, colors, textures, and attrs.
- Also bootstraps approximate globe regions from ProvinceGrid contours so content can start from painted province maps.
- Provides the ingestion boundary between authoring assets and the normalized globe structures used at runtime.
- This file is where parse errors, shape normalization, and asset-to-region field mapping are coordinated together.
- Neighboring changes usually involve ProvinceGrid polygon output, Voronoi generation, and shared globe type contracts.
- Open this owner when content formats change or when load-time diagnostics need more exact, source-level coverage.

### marker.rs

- Stores globe markers with stable ids so pins and point annotations can be added, moved, filtered, and rendered.
- Owns marker lookup, visibility, arbitrary string attrs, and typed grouping by marker classification name.
- Provides the state boundary between gameplay marker semantics and draw or picking code that consumes marker data.
- Keeps iteration and id assignment deterministic so UI, render, and sync systems see stable marker identity.
- Open this owner when marker lifecycle, filtering, or per-marker metadata behavior needs adjustment.

### mod.rs

- Exports the globe subsystem surface that groups topology, projection, loading, rendering, overlays, and syncing.
- Acts as the navigation index for globe drawing, fog, labels, markers, picking, registry state, and type owners.
- Keeps the module boundary explicit so callers can find whether a globe concern belongs to storage, math, or draw.
- Open this file when adding or retiring globe submodules or when re-export policy for shared globe APIs changes.
- The exported set here connects runtime state, geographic math, import paths, visual overlays, and sync helpers.
- Agents should start here when tracing globe behavior because it reveals the authoritative file split by concern.
- This index owns visibility and compatibility re-exports rather than camera state, topology caches, or draw code.
- Neighboring work usually spans Globe, RegionGraph, OrbitCamera, fog state, and frame emission helpers below.

### picking.rs

- Turns screen-space globe clicks into front-hemisphere surface hits and region selections under the active camera.
- Owns hit payload types, geographic point-in-polygon tests, screen-to-surface conversion, and depth-based picking.
- Provides the interaction boundary between projection math and higher-level UI or gameplay selection workflows.
- Also resolves centroid screen positions for picked regions, keeping interaction outputs close to hit computation.
- Open this owner when picking misses, hit ordering, or geo containment logic stops matching visible globe regions.

### projection.rs

- Owns globe projection math driven by OrbitCamera, axial tilt, and planet rotation into screen-space geometry.
- Builds view matrices, projects points and region loops, clips hidden hemisphere geometry, and computes screen pans.
- Also defines camera clamping, panning, zooming, and zoom-derived LOD selection used by draw and interaction code.
- Provides the math boundary between spherical globe coordinates and the 2D screen positions used by rendering.
- This file matters when back-hemisphere culling, camera feel, or projected vertex placement stops being correct.
- Open this owner before draw or picking when the root bug is in globe transforms rather than visual policy.

### province_adapter.rs

- Bridges ProvinceRegistry state into Globe data so political color and visibility can drive the strategic globe view.
- Copies province political colors into matching globe provinces, keeping style mirroring outside core globe storage.
- Also maps province visibility state into a viewer fog mask so globe fog can reflect province-driven discovery rules.

### registry.rs

- Owns the mutable globe runtime state that aggregates topology, semantic regions, fog, overlays, camera, and arcs.
- Stores markers, labels, layers, heat layers, sectors, viewer selection, and reachability cache beside globe spec.
- Provides mutation and lookup APIs for regions and provinces, plus picking, dragging, marker queries, and frame emit.
- Acts as the integration boundary where projection, picking, draw emission, and gameplay-facing globe state meet.
- Also advances simulation time and auto-rotation, keeping temporal globe behavior close to the authoritative store.
- This file matters when globe state semantics, sector grouping, or cached reachability rules need coordinated edits.
- Open this owner when multiple globe features drift together, because it is the main state hub for the subsystem.

### sphere.rs

- Provides the spherical geometry toolkit used by globe projection, picking, lighting, and arc construction code.
- Owns lat-lon to unit-vector conversion, great-circle distance and interpolation, and ray-sphere intersection math.
- Also defines the lightweight 3x3 rotation matrix helpers used to compose camera, tilt, and spin transforms.
- Acts as the math boundary between generic vector utilities and globe-specific spherical coordinate operations.
- Open this owner when globe coordinate conversion or geodesic path behavior changes independently of rendering.

### sync.rs

- Defines snapshot payloads and channel helpers used to transfer full globe state safely across thread boundaries.
- Owns GlobeSyncSnapshot contents, channel creation, and the copy rules that build and apply globe state snapshots.
- Clones terrain, topology, fog, overlays, labels, markers, arcs, sectors, and timing so remote views can stay aligned.
- Provides the sync boundary between live Globe instances and background systems that exchange complete state images.
- Open this owner when snapshot completeness, sync transport shape, or restore semantics need to change together.

### topology.rs

- Owns the region topology graph that stores regions, cached neighbors, centroids, and tagged region border edges.
- Provides insert, remove, mutation, and cache rebuild flows so topology lookups stay coherent after region edits.
- Delegates route and reachability queries to province graph pathfinding while translating results back to RegionId.
- Acts as the structural boundary between region geometry records and graph-style traversal used by globe gameplay.
- Also exposes region attrs and edge tags, keeping topology metadata near the adjacency data it qualifies.
- Open this owner when connectivity, border tags, or region path queries change without altering render policy.

### types.rs

- Defines the shared globe data model for regions, overlays, markers, labels, arcs, specs, and projected outputs.
- Owns stable identifiers, multipart geographic geometry, edge tags, base styling, and screen-space result types.
- Encodes the parameters that drive rotation, lighting, atmosphere, borders, and thematic overlay composition.
- Provides the schema boundary that every globe owner depends on, from loaders and registries to draw and picking.
- Also models fog state, label and marker styles, heat layers, and level-of-detail tiers used across rendering.
- This file matters when globe shape data, overlay contracts, or style fields need to stay reusable everywhere.
- Neighboring edits usually involve loader parsing, projection outputs, registry state, and draw-time expectations.
- Open this owner for shape-independent globe schema changes before touching behavior-specific sibling modules.



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
- `LGlobe:addTerrainPatch(p) -> boolean`: Adds a base terrain polygon patch described by id, centroid, polygon vertices or multipart geometry, optional attrs, and optional base color.
- `LGlobe:applyMouseDrag(start_x, start_y, end_x, end_y) -> nil`: Applies a pointer drag to the globe camera using screen-space deltas.
- `LGlobe:applyWheelZoom(delta) -> nil`: Applies a wheel delta using an exponential zoom scale.
- `LGlobe:cacheReachability(faction, start_id, max_cost) -> nil`: Caches default-cost reachability for a named faction.
- `LGlobe:clearProvinceTexture(id) -> boolean`: Removes texture metadata from a province.
- `LGlobe:clearTerrainPatchTexture(id) -> boolean`: Removes texture metadata from a terrain patch.
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
- `LGlobe:getTerrainPatchAttr(id, key) -> string`: Reads a string attribute from a terrain patch.
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
- `LGlobe:removeTerrainPatch(id) -> boolean`: Removes a terrain patch by id.
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
- `LGlobe:setMarkerColor(id, r, g, b, a?) -> boolean`: Sets the RGBA tint color used to render a marker.
- `LGlobe:setMarkerIconTexture(id, tex_raw?) -> boolean`: Assigns or clears a raw texture handle for a marker icon.
- `LGlobe:setMarkerPulse(id, hz, amp) -> boolean`: Sets marker pulse frequency and amplitude.
- `LGlobe:setMarkerRotation(id, dps) -> boolean`: Sets marker rotation speed. This method is available to Lua scripts.
- `LGlobe:setMarkerShape(id, shape) -> boolean`: Sets the vector fallback shape used by a marker.
- `LGlobe:setMarkerSize(id, size) -> boolean`: Sets the marker size in screen units for rendering.
- `LGlobe:setMarkerVisible(id, vis) -> boolean`: Shows or hides a marker. This method is available to Lua scripts.
- `LGlobe:setProvinceAttr(id, key, val) -> boolean`: Sets a string attribute on a province.
- `LGlobe:setProvinceSector(id, sector) -> boolean`: Assigns a province to a named sector.
- `LGlobe:setProvinceTexture(id, tex_raw, u0, v0, u1, v1) -> boolean`: Assigns a raw texture handle and UV rectangle to a province.
- `LGlobe:setRegionAttr(id, key, val) -> boolean`: Sets a string attribute on a semantic region.
- `LGlobe:setRegionColor(id, r, g, b, a) -> boolean`: Sets the RGBA color used to render a semantic region overlay.
- `LGlobe:setRegionVisible(id, visible) -> boolean`: Shows or hides a semantic region overlay and its picking participation.
- `LGlobe:setRotation(deg) -> nil`: Sets globe rotation angle. This method is available to Lua scripts.
- `LGlobe:setTerrainPatchAttr(id, key, val) -> boolean`: Sets a string attribute on a terrain patch.
- `LGlobe:setTerrainPatchTexture(id, tex_raw, u0, v0, u1, v1) -> boolean`: Assigns a raw texture handle and UV rectangle to a terrain patch.
- `LGlobe:setTimeOfDay(t) -> nil`: Sets globe time of day modulo 24 hours.
- `LGlobe:terrainPatchCount() -> integer`: Returns the number of stored base terrain patches.
- `LGlobe:type() -> string`: Returns the Lua-visible type name for this globe handle.
- `LGlobe:typeOf(name) -> boolean`: Returns whether this globe handle matches a supported type name.
- `LGlobe:update(dt) -> nil`: Advances globe simulation timers and animated state.
- `LGlobe:validateTerrainCoverage(opts?) -> table`: Samples terrain coverage over equirectangular latitude-longitude space.
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

## Examples

- `content/examples/globe.lua` (present)

## Tests

- Lua unit: `tests/lua/unit/test_globe_unit.lua` (present)
- Rust: `tests/rust/unit/globe_tests.rs`

## Evidence / Golden

| Kind | Path |
|---|---|
| Evidence test | `tests/lua/evidence/test_globe_evidence.lua` |
| Golden test | `tests/lua/golden/test_globe_golden.lua` |
| Current artifact | `tests/artifacts/current/globe/globe_camera_fog_registry_trace.txt` |
| Current artifact | `tests/artifacts/current/globe/globe_camera_lod_panels.png` |
| Current artifact | `tests/artifacts/current/globe/globe_great_circle_metrics.txt` |
| Current artifact | `tests/artifacts/current/globe/globe_great_circle_route.png` |
| Current artifact | `tests/artifacts/current/globe/globe_layer_heat_fog_composite.png` |
| Current artifact | `tests/artifacts/current/globe/globe_marker_pick_surface.png` |
| Current artifact | `tests/artifacts/current/globe/globe_province_projection.png` |
| Current artifact | `tests/artifacts/current/globe/globe_region_trace.txt` |
| Current artifact | `tests/artifacts/current/globe/globe_semantic_region_holes.png` |
| Current artifact | `tests/artifacts/current/globe/globe_terrain_region_overlay.png` |
| Current artifact | `tests/artifacts/current/globe/globe_terrain_rotation.gif` |
| Current artifact | `tests/artifacts/current/globe/globe_topology_cost_route.png` |
| Baseline artifact | `tests/artifacts/baselines/globe/globe_camera_fog_registry_trace.txt` |
| Baseline artifact | `tests/artifacts/baselines/globe/globe_camera_lod_panels.png` |
| Baseline artifact | `tests/artifacts/baselines/globe/globe_great_circle_metrics.txt` |
| Baseline artifact | `tests/artifacts/baselines/globe/globe_great_circle_route.png` |
| Baseline artifact | `tests/artifacts/baselines/globe/globe_layer_heat_fog_composite.png` |
| Baseline artifact | `tests/artifacts/baselines/globe/globe_marker_pick_surface.png` |
| Baseline artifact | `tests/artifacts/baselines/globe/globe_province_projection.png` |
| Baseline artifact | `tests/artifacts/baselines/globe/globe_region_trace.txt` |
| Baseline artifact | `tests/artifacts/baselines/globe/globe_semantic_region_holes.png` |
| Baseline artifact | `tests/artifacts/baselines/globe/globe_terrain_region_overlay.png` |
| Baseline artifact | `tests/artifacts/baselines/globe/globe_terrain_rotation.gif` |
| Baseline artifact | `tests/artifacts/baselines/globe/globe_topology_cost_route.png` |

## Architecture Links

- Intentionally empty.

## Notes

- No additional module-specific notes.
