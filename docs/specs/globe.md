# globe

## TL;DR

- The `globe` module, situated in the Feature Systems tier, provides a comprehensive framework for rendering and interacting with an XCOM-style Geoscape.

## General Info

- Module group: `Feature Systems`
- Source path: `src/globe/`
- Lua API path(s): `src/lua_api/globe_api.rs`
- Primary Lua namespace: `lurek.globe`
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

At its core is the `Globe` structure, which oversees a highly optimized, region-based spherical map. It utilizes an orbit camera with latitude and longitude positioning, supporting smooth interpolation, variable zoom levels, and automatic Level-of-Detail (LOD) adjustments. A key architectural decision is that all rendering output consists of 2D draw commands (such as convex fans, polylines, and circles) projected from spherical coordinates, intentionally avoiding the complexity of a full 3D pipeline.

The module manages complex geographical topologies via the `RegionGraph` (aliased as `ProvinceGraph` for backward compatibility), which caches adjacency data and enables rapid pathfinding and reachability queries. Region geometry can be constructed in multiple ways: parsed from TOML descriptions, extracted from color-indexed PNG maps, or generated dynamically from Voronoi seed points. For visual presentation, the module implements advanced lighting models, including a day/night terminator band, per-region diffuse intensity, and atmospheric halos.

To support gameplay mechanics, the `globe` module features a robust `FogMask` system for fog-of-war. This system uses compact bit-packed representations to track hidden, explored, and visible states per region, per viewer, allowing for efficient serialization and multi-faction scenarios. Data visualization is handled through `MarkerStore` and `LabelStore`, which manage the placement of animated icons and text annotations directly onto the sphere's surface. Additionally, `LayerStore` allows for color-coded data overlays (heat maps), and arcs can be drawn to visualize great-circle routes. Screen-space region picking is implemented via ray-polygon intersection, ensuring precise user interaction. The entire suite of features, including multi-globe support via the `GlobeRegistry`, is fully scriptable via the `lurek.globe.*` Lua API.

> **Note on naming:** Globe internally uses "Region" as the primary type name (e.g., `Region`, `RegionId`, `RegionGraph`) to avoid confusion with the separate `crate::province` 2D province-map module. Backward-compatible aliases (`Province`, `ProvinceId`, `ProvinceGraph`) are provided. The Lua API exposes both `addProvince`/`addRegion` etc. for scripts.

## Files

### composition.rs

- Provides split-view globe composition that merges multiple named views into one render batch.
- Applies per-entry viewport centers while preserving each globe's camera-relative projection behavior.
- Delivers multi-panel frame assembly for comparative or tactical map presentation.

### draw.rs

- Provides full globe frame emission that converts world map state into ordered render commands.
- Draws projected regions with fog, lighting, overlays, and optional texture contribution.
- Renders borders, atmosphere, and arcs to preserve geographic structure and visual depth cues.
- Integrates marker and label drawing with animation and LOD-aware visibility rules.
- Applies camera projection and world parameters consistently across all rendered primitives.
- Supports layered heat and style effects so thematic map signals remain legible.
- Delivers the end-to-end draw pipeline for globe visualization in runtime frames.

### export.rs

- Provides globe geometry export helpers that convert region polygons into portable mesh text output.
- Emits flat OBJ data with deterministic region object grouping for downstream tooling.
- Delivers a simple export path for inspection, conversion, and offline map processing workflows.

### fog.rs

- Provides compact per-region fog state storage with hidden, explored, and visible visibility tiers.
- Supports per-viewer mask ownership so different observers can maintain independent map knowledge.
- Exposes reveal, hide, explore, and toggle operations for direct gameplay-state updates.
- Includes serialization-friendly encoding to persist fog state across save and restore cycles.
- Supplies query helpers that report visible and explored subsets for UI and logic consumers.
- Delivers the fog-of-war backbone used by globe rendering and strategic information gating.

### label.rs

- Provides id-keyed globe label storage for map annotations positioned by latitude and longitude.
- Supports add, remove, update, and visibility operations for dynamic labeling workflows.
- Applies LOD-aware filtering so text density scales with camera detail level.
- Maintains stable iteration outputs used by rendering and debugging interfaces.
- Delivers the label-management layer for readable and controllable geographic annotation.

### layer.rs

- Provides named globe layer storage that overlays per-region color and visibility modifications.
- Supports insert, remove, lookup, and alpha control for composable thematic map styling.
- Resolves effective colors in z-order so stacked overlays produce deterministic final output.
- Delivers the overlay-composition layer used by draw logic and gameplay visualization.

### lighting.rs

- Provides globe lighting helpers that derive sun direction and regional light intensity over time.
- Computes diffuse contribution with ambient floors to keep night-side visuals readable.
- Supports batch intensity and terminator blending calculations for smooth day-night transitions.
- Delivers reusable illumination math consumed by globe rendering passes.

### loader.rs

- Provides globe region-loading workflows from TOML, raster grids, and generated Voronoi seed sources.
- Parses lightweight structured input into normalized region records with geometry and adjacency data.
- Converts intermediate builder state into shared globe region types used across the subsystem.
- Extracts bounds and neighbor hints from image-driven province maps for quick content bootstrapping.
- Handles primitive parsing and validation to keep load-time failures explicit and actionable.
- Supports both in-memory string input and file-based ingestion paths for tooling flexibility.
- Delivers the map-ingestion layer that seeds topology and rendering state for globe runtime use.

### marker.rs

- Provides stable-id globe marker storage for pins and point annotations on planetary surfaces.
- Supports marker insertion, removal, movement, and lookup by id or classification type.
- Manages marker visibility and custom attributes for flexible runtime presentation.
- Keeps marker collections deterministic for rendering and interaction queries.
- Delivers the marker-management layer used by tactical and informational map overlays.

### mod.rs

- Provides the high-level globe module boundary for region topology, projection, and visual overlay orchestration.
- Connects rendering, fog state, markers, labels, layers, and picking into one map-runtime surface.
- Supports synchronization and loading flows so globe state can be updated from external game systems.
- Delivers a cohesive planetary-view feature set for strategic map presentation and interaction.

### picking.rs

- Provides screen-space globe picking that identifies visible regions under pointer coordinates.
- Projects region geometry into 2D and applies point-in-polygon hit testing for selection.
- Chooses the front-most valid candidate using camera-facing depth information.
- Delivers interaction picking results consumed by UI and gameplay selection flows.

### projection.rs

- Provides globe projection math driven by an orbit camera with latitude, longitude, and zoom control.
- Builds view transforms from globe rotation, axial tilt, and camera orientation inputs.
- Projects points and regions from spherical coordinates into screen-space render geometry.
- Applies facing checks and depth culling to reject back-hemisphere geometry during projection.
- Delivers camera and projection utilities used by drawing, picking, and interaction code paths.

### province_adapter.rs

- Provides a bridge that applies province-registry ownership and visibility state onto globe regions.
- Synchronizes political coloring so map visuals reflect current simulation authority data.
- Delivers adapter logic that keeps province gameplay state aligned with globe presentation.

### registry.rs

- Provides mutable globe state that aggregates topology, camera, fog, overlays, and interaction data.
- Owns region storage operations together with markers, labels, layers, arcs, and heat visual layers.
- Integrates camera projection and picking paths so selection and rendering share one state container.
- Emits full-frame render commands from current globe state for deterministic map visualization.
- Caches sector and reachability information to support strategic lookup and path-cost workflows.
- Delivers named registry management for handling multiple independent globe instances.

### sphere.rs

- Provides spherical geometry helpers for converting between latitude-longitude and unit-vector space.
- Computes great-circle distance and interpolation for geodesic path and arc construction.
- Supplies ray-sphere intersection tests used by projection and picking style calculations.
- Defines lightweight 3x3 rotation matrices and multiplication helpers for globe transforms.
- Delivers foundational math primitives shared across lighting, projection, and topology tools.

### sync.rs

- Provides globe snapshot transfer structures for cross-thread synchronization and state exchange.
- Defines channel wrappers and snapshot payload shapes used to move globe state safely.
- Supports building and applying snapshots to keep remote and local globe views aligned.
- Delivers the synchronization utility layer for background simulation integration.

### topology.rs

- Provides region-topology graph storage with cached adjacency, centroids, and tagged border edges.
- Supports insertion, removal, and mutation workflows while keeping lookup caches coherent.
- Integrates pathfinding-friendly queries for route, cost, and reachability evaluation across regions.
- Exposes neighbor and region iteration helpers used by rendering and gameplay systems.
- Delivers the structural map-graph backbone that powers globe connectivity logic.

### types.rs

- Provides the shared globe data model defining regions, overlays, markers, labels, arcs, and view artifacts.
- Encodes geographic geometry with centroids, adjacency, edge tags, and per-region render attributes.
- Defines globe specification parameters that drive atmosphere, lighting, rotation, and border behavior.
- Supplies layer and heat-overlay structures used to blend thematic map information at runtime.
- Models marker and label style data with visibility, pulse, and level-of-detail controls.
- Includes projection result types for screen-space rendering and interaction pipelines.
- Declares subsystem error variants for loading, lookup, and path-related failure handling.
- Delivers the canonical type contract consumed by all globe modules and integration surfaces.

## Lua API Ref

- Binding: `src/lua_api/globe_api.rs`
- Namespace: `lurek.globe`

### Functions

- `lurek.globe.generateVoronoi`: Creates a globe and populates provinces from latitude-longitude seed points.
- `lurek.globe.get`: Returns a globe from the module registry by name.
- `lurek.globe.greatCircleDistance`: Computes great-circle distance between two latitude-longitude points.
- `lurek.globe.greatCirclePath`: Computes sampled latitude-longitude points along a great-circle path.
- `lurek.globe.latLonToUnit`: Converts latitude and longitude to a unit-sphere 3D vector table.
- `lurek.globe.loadFromPNG`: Creates a globe and populates provinces from a PNG file.
- `lurek.globe.loadFromTOML`: Creates a globe and populates provinces from TOML source text.
- `lurek.globe.loadFromTOMLFile`: Creates a globe and populates provinces from a TOML file path.
- `lurek.globe.new`: Creates a named globe with optional specification fields in the module registry.
- `lurek.globe.raySphereIntersect`: Intersects a 3D ray with a sphere and returns the nearest positive hit distance.
- `lurek.globe.remove`: Removes a globe from the registry by name.

### Enums

- No documented module-level enums/constants.

### Types

#### LGlobe Type

- Lua-side handle for a named globe stored inside a shared registry.

##### Fields

- No documented fields.

##### Methods

- `LGlobe:addArc`: Adds a visible route arc between two latitude and longitude points.
- `LGlobe:addLabel`: Adds a text label at latitude and longitude.
- `LGlobe:addLayer`: Adds a render layer with optional z-order.
- `LGlobe:addMarker`: Adds a marker at latitude and longitude with an optional label.
- `LGlobe:addProvince`: Adds a province described by id, centroid, vertices, neighbors, and optional base color.
- `LGlobe:addRegion`: Adds a region described by id, centroid, vertices, neighbors, and optional base color.
- `LGlobe:cacheReachability`: Caches default-cost reachability for a named faction.
- `LGlobe:clearProvinceTexture`: Removes texture metadata from a province.
- `LGlobe:decodeFogBase64`: Loads one viewer's fog state from a base64 string.
- `LGlobe:encodeFogBase64`: Serializes one viewer's fog state to a base64 string.
- `LGlobe:exportProvinceMeshOBJ`: Exports province geometry as Wavefront OBJ text.
- `LGlobe:findPath`: Finds a default-cost province path between two province ids.
- `LGlobe:getCachedReachability`: Returns cached reachability costs for a faction.
- `LGlobe:getCamera`: Returns camera latitude, longitude, and zoom.
- `LGlobe:getFogState`: Returns fog-of-war state for one viewer and province.
- `LGlobe:getLod`: Returns the camera-derived level-of-detail tier name.
- `LGlobe:getMarkerAttr`: Reads a string attribute from a marker.
- `LGlobe:getName`: Returns the registry name of this globe.
- `LGlobe:getNeighbors`: Returns neighboring province ids for a province.
- `LGlobe:getProvinceAttr`: Reads a string attribute from a province.
- `LGlobe:getProvinceSector`: Returns the sector name assigned to a province.
- `LGlobe:getSectorProvinces`: Returns province ids assigned to a sector.
- `LGlobe:getTimeOfDay`: Returns globe time of day. This method is available to Lua scripts.
- `LGlobe:hideProvince`: Hides a province for one fog-of-war viewer.
- `LGlobe:isVisible`: Returns whether a province is visible for one fog-of-war viewer.
- `LGlobe:moveMarker`: Moves a marker to latitude and longitude coordinates.
- `LGlobe:pan`: Pans the globe camera by latitude and longitude deltas.
- `LGlobe:pick`: Picks a province at screen coordinates.
- `LGlobe:pickLatLon`: Picks at screen coordinates and returns the hit province centroid screen coordinates.
- `LGlobe:pickRaycast`: Samples along a screen ray from the camera center and returns the first hit province.
- `LGlobe:provinceCount`: Returns the number of regions in this globe.
- `LGlobe:reachable`: Returns provinces reachable from a start province within a cost budget.
- `LGlobe:regionCount`: Returns the number of regions in this globe.
- `LGlobe:removeArc`: Removes an arc by id. This method is available to Lua scripts.
- `LGlobe:removeHeatLayer`: Removes a heat layer by name. This method is available to Lua scripts.
- `LGlobe:removeLabel`: Removes a label by id. This method is available to Lua scripts.
- `LGlobe:removeLayer`: Removes a render layer by name. This method is available to Lua scripts.
- `LGlobe:removeMarker`: Removes a marker by id. This method is available to Lua scripts.
- `LGlobe:removeProvince`: Removes a region by id. This method is available to Lua scripts.
- `LGlobe:removeRegion`: Removes a region by id. This method is available to Lua scripts.
- `LGlobe:revealAll`: Reveals every province for one fog-of-war viewer.
- `LGlobe:revealProvince`: Reveals a province for one fog-of-war viewer.
- `LGlobe:setActiveViewer`: Sets the active fog-of-war viewer name or clears it.
- `LGlobe:setAutoRotationSpeed`: Sets automatic globe rotation speed.
- `LGlobe:setBorders`: Enables or disables province border rendering.
- `LGlobe:setCamera`: Sets camera latitude, longitude, and zoom.
- `LGlobe:setFogState`: Sets fog-of-war state for one viewer and province.
- `LGlobe:setHeatLayer`: Creates or replaces a heat layer that maps province attributes into colors.
- `LGlobe:setLabelText`: Changes text for an existing label.
- `LGlobe:setLabelVisible`: Shows or hides a label. This method is available to Lua scripts.
- `LGlobe:setLayerAlpha`: Sets render layer alpha. This method is available to Lua scripts.
- `LGlobe:setLayerColor`: Sets a province color override inside a render layer.
- `LGlobe:setLayerVisible`: Shows or hides a render layer. This method is available to Lua scripts.
- `LGlobe:setMarkerAttr`: Sets a string attribute on a marker.
- `LGlobe:setMarkerPulse`: Sets marker pulse frequency and amplitude.
- `LGlobe:setMarkerRotation`: Sets marker rotation speed. This method is available to Lua scripts.
- `LGlobe:setMarkerVisible`: Shows or hides a marker. This method is available to Lua scripts.
- `LGlobe:setProvinceAttr`: Sets a string attribute on a province.
- `LGlobe:setProvinceSector`: Assigns a province to a named sector.
- `LGlobe:setProvinceTexture`: Assigns a raw texture handle and UV rectangle to a province.
- `LGlobe:setRotation`: Sets globe rotation angle. This method is available to Lua scripts.
- `LGlobe:setTimeOfDay`: Sets globe time of day modulo 24 hours.
- `LGlobe:type`: Returns the Lua-visible type name for this globe handle.
- `LGlobe:typeOf`: Returns whether this globe handle matches a supported type name.
- `LGlobe:update`: Advances globe simulation timers and animated state.
- `LGlobe:zoom`: Multiplies the globe camera zoom by a factor.

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

- `LGlobeRegistry:get`: Returns a globe handle by registry name.
- `LGlobeRegistry:names`: Returns all globe names currently stored in this registry.
- `LGlobeRegistry:new`: Creates a named globe with optional specification fields.
- `LGlobeRegistry:remove`: Removes a globe from the registry by name.
- `LGlobeRegistry:type`: Returns the Lua-visible type name for this globe registry handle.
- `LGlobeRegistry:typeOf`: Returns whether this registry handle matches a supported type name.

## References

- `math`: Imports or references `src/math/`. Cross-group dependency from `Edge/Integration` into `Foundations`.
- `pathfind`: Imports or references `src/pathfind/`. Cross-group dependency from `Edge/Integration` into `Feature Systems`.
- `province`: Imports or references `src/province/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `render`: Imports or references `src/render/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Edge/Integration` into `Core Runtime`.
