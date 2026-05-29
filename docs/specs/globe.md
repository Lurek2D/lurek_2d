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

- Compose multiple globe views into a single frame via split viewports.
- Emit render commands for each named globe with per-entry screen center overrides.
- Iterate the registry, clone camera state, and collect draw output into one batch.

### draw.rs

- Emit a complete globe frame as a list of render commands.
- Draw regions with fog-of-war, lighting, heat-layer blending, and texture mapping.
- Render borders with optional polyline smoothing passes.
- Project and draw great-circle arcs between coordinate pairs.
- Display animated markers with pulse, rotation, and labels.
- Emit atmosphere halo circles and LOD-gated text labels.

### export.rs

- Export globe region geometry to standard mesh formats.
- Generate flat OBJ output with one named object per region polygon.
- Vertex data uses (lon, lat) mapping onto a 2D plane at z=0.

### fog.rs

- Compact per-region fog mask storing hidden, explored, and visible states.
- Bit-packed base64 serialization for save/load round-trips.
- Per-viewer fog store keyed by viewer name with automatic mask creation.
- Reveal, hide, explore, and toggle operations on individual or batched regions.
- Query helpers for visible/explored id lists and region counts.

### label.rs

- Id-keyed label storage for globe map annotations.
- Insert, remove, move, and toggle visibility of positioned text labels.
- LOD-aware iteration filters labels by minimum detail tier.

### layer.rs

- Named layer storage keyed by string, with insert, remove, and lookup.
- Per-region color overrides, visibility toggling, and alpha clamping.
- Z-order–aware color resolution across all visible layers.

### lighting.rs

- Globe day/night lighting: sun direction from rotation and time-of-day.
- Per-region diffuse intensity with ambient floor.
- Batch intensity computation for region centroid sequences.
- Terminator-band alpha for smooth day/night transition rendering.

### loader.rs

- Load regions from TOML strings or files using a lightweight inline parser.
- Load regions from PNG province-grid images with bounding-box extraction and adjacency detection.
- Generate approximate region geometry from Voronoi seed points.
- Convert between internal builder representations and the shared `Region` type.
- Parse TOML primitives: u32 literals, float pairs, float-4 arrays, string key-value lines.

### marker.rs

- Stable-id marker collection for globe pin management.
- Insert, remove, move, and query markers by id or type.
- Per-marker visibility toggle and arbitrary string attributes.

### mod.rs

- Globe rendering with orbit camera projection and LOD tiers.
- Region registry, fog-of-war masks, and picking queries.
- Label, marker, and layer management for map overlays.
- Synchronization channels for background globe updates.

### picking.rs

- Screen-space region picking via ray-polygon intersection.
- Projects region polygons from 3D globe to 2D screen for hit testing.
- Selects the front-most visible region under a pointer position.

### projection.rs

- Orbit camera with latitude, longitude, zoom, and level-of-detail selection.
- View-matrix construction from globe rotation, axial tilt, and camera angles.
- Single-point and polygon projection from lat/lon to screen space.
- Back-face culling via z-depth test for hidden-hemisphere rejection.
- Screen-drag-to-pan conversion and vector normalization helpers.

### province_adapter.rs

- Sync political colors and fog visibility from the province registry into the globe.
- Bridge between province game-state and globe rendering data.
- Copies color and fog state from `ProvinceRegistry` into matching `Globe` region entries.

### registry.rs

- Mutable globe state combining topology, fog, markers, labels, layers, and arcs.
- Region add/remove/get and sector grouping operations.
- Heat-layer and arc overlay management with add/replace/remove.
- Orbit camera integration and screen-space region picking.
- Frame emission producing render commands for the full globe state.
- Named globe registry for storing and retrieving multiple globes by name.
- Reachability caching per faction for path-cost queries.

### sphere.rs

- Sphere-surface coordinate helpers: latitude/longitude ↔ unit-sphere Vec3 conversion.
- Great-circle distance (Haversine) and arc interpolation between two geo-points.
- Ray-sphere intersection returning the nearest positive hit distance.
- Column-major 3×3 rotation matrices (axis-aligned X/Y/Z plus axial-tilt convenience).
- Matrix-vector and matrix-matrix multiplication for globe-view transforms.

### sync.rs

- Snapshot serialization of globe state for cross-thread transfer.
- Channel pair for sending and receiving globe snapshots.
- Build and apply helpers to capture or restore globe state.

### topology.rs

- Region graph structure with adjacency caching, centroid lookup, and edge tags.
- Pathfinding integration via cost functions and reachability queries.
- Region attribute storage and neighbor-list access.
- Cache rebuild for bulk topology mutations.
- Default-cost convenience wrappers for quick path and range checks.

### types.rs

- Core data types for the globe subsystem: regions, markers, labels, arcs, and layers.
- Region geometry with polygon vertices, centroids, adjacency, and per-edge tags.
- Render parameters via GlobeSpec: lighting, atmosphere, borders, rotation.
- Overlay and heat-map layers with per-region color overrides.
- Marker and label types with style, LOD gating, and pulse animation.
- Projection output types for screen-space rendering of regions and arcs.
- Globe-level error enum for load, lookup, and pathfinding failures.

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


#### LGlobeRegistry Type


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
