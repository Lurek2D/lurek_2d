# globe

## General Info

- Module group: `Feature Systems`
- Source path: `src/globe/`
- Lua API path(s): `src/lua_api/globe_api.rs`
- Primary Lua namespace: `lurek.globe`
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

The `globe` module, situated in the Feature Systems tier, provides a comprehensive framework for rendering and interacting with an XCOM-style Geoscape. At its core is the `Globe` structure, which oversees a highly optimized, province-based spherical map. It utilizes an orbit camera with latitude and longitude positioning, supporting smooth interpolation, variable zoom levels, and automatic Level-of-Detail (LOD) adjustments. A key architectural decision is that all rendering output consists of 2D draw commands (such as convex fans, polylines, and circles) projected from spherical coordinates, intentionally avoiding the complexity of a full 3D pipeline.

The module manages complex geographical topologies via the `ProvinceGraph`, which caches adjacency data and enables rapid pathfinding and reachability queries. Province geometry can be constructed in multiple ways: parsed from TOML descriptions, extracted from color-indexed PNG maps, or generated dynamically from Voronoi seed points. For visual presentation, the module implements advanced lighting models, including a day/night terminator band, per-province diffuse intensity, and atmospheric halos. 

To support gameplay mechanics, the `globe` module features a robust `FogMask` system for fog-of-war. This system uses compact bit-packed representations to track hidden, explored, and visible states per province, per viewer, allowing for efficient serialization and multi-faction scenarios. Data visualization is handled through `MarkerStore` and `LabelStore`, which manage the placement of animated icons and text annotations directly onto the sphere's surface. Additionally, `LayerStore` allows for color-coded data overlays (heat maps), and arcs can be drawn to visualize great-circle routes. Screen-space province picking is implemented via ray-polygon intersection, ensuring precise user interaction. The entire suite of features, including multi-globe support via the `GlobeRegistry`, is fully scriptable via the `lurek.globe.*` Lua API.

## Source Documentation

### `composition.rs`
- Compose multiple globe views into a single frame via split viewports.
- Emit render commands for each named globe with per-entry screen center overrides.
- Iterate the registry, clone camera state, and collect draw output into one batch.

### `draw.rs`
- Emit a complete globe frame as a list of render commands.
- Draw provinces with fog-of-war, lighting, heat-layer blending, and texture mapping.
- Render borders with optional polyline smoothing passes.
- Project and draw great-circle arcs between coordinate pairs.
- Display animated markers with pulse, rotation, and labels.
- Emit atmosphere halo circles and LOD-gated text labels.

### `export.rs`
- Export globe province geometry to standard mesh formats.
- Generate flat OBJ output with one named object per province polygon.
- Vertex data uses (lon, lat) mapping onto a 2D plane at z=0.

### `fog.rs`
- Compact per-province fog mask storing hidden, explored, and visible states.
- Bit-packed base64 serialization for save/load round-trips.
- Per-viewer fog store keyed by viewer name with automatic mask creation.
- Reveal, hide, explore, and toggle operations on individual or batched provinces.
- Query helpers for visible/explored id lists and province counts.

### `label.rs`
- Id-keyed label storage for globe map annotations.
- Insert, remove, move, and toggle visibility of positioned text labels.
- LOD-aware iteration filters labels by minimum detail tier.

### `layer.rs`
- Named layer storage keyed by string, with insert, remove, and lookup.
- Per-province color overrides, visibility toggling, and alpha clamping.
- Z-order–aware color resolution across all visible layers.

### `lighting.rs`
- Globe day/night lighting: sun direction from rotation and time-of-day.
- Per-province diffuse intensity with ambient floor.
- Batch intensity computation for province centroid sequences.
- Terminator-band alpha for smooth day/night transition rendering.

### `loader.rs`
- Load provinces from TOML strings or files using a lightweight inline parser.
- Load provinces from PNG province-grid images with bounding-box extraction and adjacency detection.
- Generate approximate province geometry from Voronoi seed points.
- Convert between internal builder representations and the shared `Province` type.
- Parse TOML primitives: u32 literals, float pairs, float-4 arrays, string key-value lines.

### `marker.rs`
- Stable-id marker collection for globe pin management.
- Insert, remove, move, and query markers by id or type.
- Per-marker visibility toggle and arbitrary string attributes.

### `mod.rs`
- Globe rendering with orbit camera projection and LOD tiers.
- Province registry, fog-of-war masks, and picking queries.
- Label, marker, and layer management for map overlays.
- Synchronization channels for background globe updates.

### `picking.rs`
- Screen-space province picking via ray-polygon intersection.
- Projects province polygons from 3D globe to 2D screen for hit testing.
- Selects the front-most visible province under a pointer position.

### `projection.rs`
- Orbit camera with latitude, longitude, zoom, and level-of-detail selection.
- View-matrix construction from globe rotation, axial tilt, and camera angles.
- Single-point and polygon projection from lat/lon to screen space.
- Back-face culling via z-depth test for hidden-hemisphere rejection.
- Screen-drag-to-pan conversion and vector normalization helpers.

### `province_adapter.rs`
- Sync political colors and fog visibility from the province registry into the globe.
- Bridge between province game-state and globe rendering data.

### `registry.rs`
- Mutable globe state combining topology, fog, markers, labels, layers, and arcs.
- Province add/remove/get and sector grouping operations.
- Heat-layer and arc overlay management with add/replace/remove.
- Orbit camera integration and screen-space province picking.
- Frame emission producing render commands for the full globe state.
- Named globe registry for storing and retrieving multiple globes by name.
- Reachability caching per faction for path-cost queries.

### `sync.rs`
- Snapshot serialization of globe state for cross-thread transfer.
- Channel pair for sending and receiving globe snapshots.
- Build and apply helpers to capture or restore globe state.

### `topology.rs`
- Province graph structure with adjacency caching, centroid lookup, and edge tags.
- Pathfinding integration via cost functions and reachability queries.
- Province attribute storage and neighbor-list access.
- Cache rebuild for bulk topology mutations.
- Default-cost convenience wrappers for quick path and range checks.

### `types.rs`
- Core data types for the globe subsystem: provinces, markers, labels, arcs, and layers.
- Province geometry with polygon vertices, centroids, adjacency, and per-edge tags.
- Render parameters via GlobeSpec: lighting, atmosphere, borders, rotation.
- Overlay and heat-map layers with per-province color overrides.
- Marker and label types with style, LOD gating, and pulse animation.
- Projection output types for screen-space rendering of provinces and arcs.
- Globe-level error enum for load, lookup, and pathfinding failures.

## Types

- `SplitViewport` (`struct`, `composition.rs`): Screen center override for one split viewport.
- `FogMask` (`struct`, `fog.rs`): Per-faction visibility bit-vector.
- `FogStore` (`struct`, `fog.rs`): Store of fog masks keyed by viewer ID.
- `LabelStore` (`struct`, `label.rs`): Store and lifecycle manager for globe labels.
- `LayerStore` (`struct`, `layer.rs`): Registry and lifecycle manager for globe layers.
- `MarkerStore` (`struct`, `marker.rs`): Store and lifecycle manager for globe markers.
- `PickResult` (`struct`, `picking.rs`): Result of a successful province pick operation.
- `OrbitCamera` (`struct`, `projection.rs`): Orbit camera controlling the viewpoint onto the globe.
- `Globe` (`struct`, `registry.rs`): Owns all domain stores for one named globe simulation.
- `GlobeRegistry` (`struct`, `registry.rs`): Named multi-globe manager.
- `GlobeSyncSnapshot` (`struct`, `sync.rs`): Serializable globe state used for snapshot transfer.
- `GlobeSyncChannel` (`struct`, `sync.rs`): Channel pair used to send and receive globe snapshots.
- `ProvinceGraph` (`struct`, `topology.rs`): Complete province topology for one globe instance.
- `ProvinceId` (`type`, `types.rs`): Unique identifier for a province within a single globe instance.
- `Province` (`struct`, `types.rs`): A convex (or near-convex) polygon on the unit sphere, representing a province or region.
- `FogState` (`enum`, `types.rs`): Fog-of-war state for a province.
- `HeatLayer` (`struct`, `types.rs`): Heat overlay parameters used by globe color mapping.
- `GlobeSpec` (`struct`, `types.rs`): Top-level configuration for one globe instance.
- `Marker` (`struct`, `types.rs`): A point of interest placed on the globe at a specific latitude/longitude.
- `MarkerStyle` (`struct`, `types.rs`): Visual style for a [`Marker`].
- `MarkerShape` (`enum`, `types.rs`): Primitive fallback shape for an icon-less marker.
- `Label` (`struct`, `types.rs`): A text annotation placed on the globe.
- `LabelStyle` (`struct`, `types.rs`): Visual style for a [`Label`].
- `Layer` (`struct`, `types.rs`): A named rendering layer that sits above the base province map.
- `LodTier` (`enum`, `types.rs`): Level-of-detail tier, selected based on camera zoom.
- `ProjectedProvince` (`struct`, `types.rs`): A province projected to screen space, ready for draw calls.
- `Arc` (`struct`, `types.rs`): A great-circle travel arc, projected to screen space.
- `GlobeError` (`enum`, `types.rs`): Errors returned by globe operations.

## Functions

- `emit_split_frame` (`composition.rs`): Emit render commands for several globes with per-entry viewport centers.
- `emit_globe_frame` (`draw.rs`): Emit all render commands for one globe frame.
- `project_arc` (`draw.rs`): Pre-project a great-circle arc into a flat screenspace point list.
- `export_provinces_to_obj` (`export.rs`): Export province polygons as a flat OBJ string with one object per province.
- `FogMask::all_hidden` (`fog.rs`): Create a mask with every province hidden.
- `FogMask::all_visible` (`fog.rs`): Create a mask with every province visible.
- `FogMask::is_visible` (`fog.rs`): Return true when the province is visible.
- `FogMask::state` (`fog.rs`): Return the stored fog state for a province id.
- `FogMask::set_state` (`fog.rs`): Set the fog state for a province id when it is in range.
- `FogMask::reveal` (`fog.rs`): Mark a province as visible.
- `FogMask::hide` (`fog.rs`): Mark a province as hidden.
- `FogMask::explore` (`fog.rs`): Mark a province as explored.
- `FogMask::toggle` (`fog.rs`): Toggle a province between visible and hidden.
- `FogMask::reveal_batch` (`fog.rs`): Reveal every province in the supplied iterator.
- `FogMask::visible_ids` (`fog.rs`): Return all visible province ids in ascending order.
- `FogMask::explored_ids` (`fog.rs`): Return all explored province ids in ascending order.
- `FogMask::from_visible_ids` (`fog.rs`): Build a mask that reveals the supplied province ids.
- `FogMask::count_visible` (`fog.rs`): Count visible provinces in the mask.
- `FogMask::count_explored` (`fog.rs`): Count explored provinces in the mask.
- `FogMask::to_base64` (`fog.rs`): Encode the fog mask as base64 packed two-bit states.
- `FogMask::from_base64` (`fog.rs`): Decode a base64 encoded fog mask or return an error on invalid input.
- `FogStore::new` (`fog.rs`): Create an empty fog store.
- `FogStore::get_or_insert` (`fog.rs`): Return the mask for a viewer, inserting a hidden mask when absent.
- `FogStore::get` (`fog.rs`): Return the mask for a viewer when it exists.
- `FogStore::is_visible` (`fog.rs`): Return true when the viewer can see the province.
- `FogStore::reveal` (`fog.rs`): Reveal a province for a viewer.
- `FogStore::explore` (`fog.rs`): Mark a province as explored for a viewer.
- `FogStore::hide` (`fog.rs`): Hide a province for a viewer.
- `FogStore::visible_ids` (`fog.rs`): Return the visible province ids for a viewer when the viewer exists.
- `FogStore::explored_ids` (`fog.rs`): Return the explored province ids for a viewer when the viewer exists.
- `FogStore::state` (`fog.rs`): Return the state for a viewer or visible when the viewer has no mask.
- `FogStore::set_state` (`fog.rs`): Set the fog state for a viewer and province.
- `FogStore::to_base64` (`fog.rs`): Serialize a viewer mask to base64 when it exists.
- `FogStore::load_base64` (`fog.rs`): Load a viewer mask from base64 or return an error on invalid input.
- `FogStore::load` (`fog.rs`): Replace a viewer mask with one built from visible province ids.
- `FogStore::remove` (`fog.rs`): Remove the viewer mask if it exists.
- `FogStore::viewers` (`fog.rs`): Return all viewer names in arbitrary order.
- `LabelStore::new` (`label.rs`): Create an empty label store.
- `LabelStore::add` (`label.rs`): Insert a label and return its assigned id.
- `LabelStore::remove` (`label.rs`): Remove a label by id and return it when found.
- `LabelStore::get` (`label.rs`): Return a shared label reference when the id exists.
- `LabelStore::get_mut` (`label.rs`): Return a mutable label reference when the id exists.
- `LabelStore::set_visible` (`label.rs`): Set label visibility and return true when the id exists.
- `LabelStore::set_text` (`label.rs`): Replace label text and return true when the id exists.
- `LabelStore::move_to` (`label.rs`): Move a label to a new latitude and longitude and return true when it exists.
- `LabelStore::iter` (`label.rs`): Iterate over all stored labels.
- `LabelStore::iter_visible` (`label.rs`): Iterate over visible labels whose minimum LOD fits the supplied tier.
- `LabelStore::len` (`label.rs`): Return the number of stored labels.
- `LabelStore::is_empty` (`label.rs`): Return true when no labels are stored.
- `LayerStore::new` (`layer.rs`): Create an empty layer store.
- `LayerStore::add` (`layer.rs`): Insert a layer and return true when a layer with the same name was replaced.
- `LayerStore::remove` (`layer.rs`): Remove a layer by name and return it when found.
- `LayerStore::get` (`layer.rs`): Return a shared layer reference when the name exists.
- `LayerStore::get_mut` (`layer.rs`): Return a mutable layer reference when the name exists.
- `LayerStore::set_province_color` (`layer.rs`): Set a province color override for a layer and return true when the layer exists.
- `LayerStore::clear_province_colors` (`layer.rs`): Clear all province color overrides from a layer.
- `LayerStore::set_visible` (`layer.rs`): Set layer visibility and return true when the layer exists.
- `LayerStore::set_alpha` (`layer.rs`): Set layer alpha and clamp it to the 0..=1 range.
- `LayerStore::effective_color` (`layer.rs`): Resolve the effective province color by applying visible layers in z-order.
- `LayerStore::visible_sorted` (`layer.rs`): Return visible layers sorted by z-order.
- `LayerStore::len` (`layer.rs`): Return the number of stored layers.
- `LayerStore::is_empty` (`layer.rs`): Return true when no layers are stored.
- `sun_direction` (`lighting.rs`): Compute the sun direction as a world-space unit vector.
- `province_intensity` (`lighting.rs`): Compute the lighting intensity for a province centroid.
- `compute_intensities` (`lighting.rs`): Batch-compute light intensities for all provinces.
- `terminator_alpha` (`lighting.rs`): Compute a day/night terminator alpha for a province for a soft edge.
- `load_from_toml_str` (`loader.rs`): Parse a TOML province file from a string.
- `load_from_toml_file` (`loader.rs`): Load province data from the filesystem (synchronous).
- `load_from_png_file` (`loader.rs`): Load provinces from a color-indexed PNG.
- `generate_voronoi_provinces` (`loader.rs`): Generate approximate provinces from Voronoi input points.
- `MarkerStore::new` (`marker.rs`): Create an empty marker store.
- `MarkerStore::add` (`marker.rs`): Insert a marker and return its assigned id.
- `MarkerStore::remove` (`marker.rs`): Remove a marker by id and return it when found.
- `MarkerStore::get` (`marker.rs`): Return a shared marker reference when the id exists.
- `MarkerStore::get_mut` (`marker.rs`): Return a mutable marker reference when the id exists.
- `MarkerStore::move_to` (`marker.rs`): Move a marker and return true when the id exists.
- `MarkerStore::set_visible` (`marker.rs`): Set marker visibility and return true when the id exists.
- `MarkerStore::set_attr` (`marker.rs`): Set a string attribute and return true when the id exists.
- `MarkerStore::get_attr` (`marker.rs`): Return a string attribute for a marker when it exists.
- `MarkerStore::iter` (`marker.rs`): Iterate over all stored markers.
- `MarkerStore::iter_visible` (`marker.rs`): Iterate over visible markers only.
- `MarkerStore::by_type` (`marker.rs`): Return all markers whose type matches the supplied string.
- `MarkerStore::len` (`marker.rs`): Return the number of stored markers.
- `MarkerStore::is_empty` (`marker.rs`): Return true when no markers are stored.
- `pick` (`picking.rs`): Pick the province at screen coordinate `(sx, sy)`.
- `OrbitCamera::clamp` (`projection.rs`): Clamp camera latitude, longitude, and zoom into the supported range.
- `OrbitCamera::pan` (`projection.rs`): Pan the camera by latitude and longitude deltas.
- `OrbitCamera::zoom_by` (`projection.rs`): Multiply zoom by a factor and clamp the result.
- `OrbitCamera::lod` (`projection.rs`): Return the current level-of-detail tier for the zoom level.
- `build_view_matrix` (`projection.rs`): Build the composite rotation matrix for a frame.
- `project_point` (`projection.rs`): Project a single unit-sphere point through the view matrix to screen space.
- `project_province` (`projection.rs`): Project a province's boundary vertices.
- `project_point_with_z` (`projection.rs`): Project a lat/lon point to screen and also return the camera-space Z (for picking).
- `screen_delta_to_pan` (`projection.rs`): Convert a screen delta `(dx, dy)` in pixels to a globe pan `(delta_lat, delta_lon)`.
- `normalize_v3` (`projection.rs`): Normalize a `Vec3` (returns zero vector if near-zero length).
- `apply_political_colors` (`province_adapter.rs`): Applies political colors from a province registry onto matching globe provinces.
- `apply_visibility_to_viewer` (`province_adapter.rs`): Applies fog visibility from province registry to one globe viewer mask.
- `Globe::new` (`registry.rs`): Create a globe with the supplied name and spec.
- `Globe::add_province` (`registry.rs`): Insert a province or return TooManyProvinces when the graph is full.
- `Globe::remove_province` (`registry.rs`): Remove a province by id and return it when present.
- `Globe::get_province` (`registry.rs`): Return a shared province reference when the id exists.
- `Globe::get_province_mut` (`registry.rs`): Return a mutable province reference when the id exists.
- `Globe::province_count` (`registry.rs`): Return the number of stored provinces.
- `Globe::add_arc` (`registry.rs`): Insert an arc and return its assigned id.
- `Globe::remove_arc` (`registry.rs`): Remove an arc by id and return true when it existed.
- `Globe::update` (`registry.rs`): Advance simulation time and update the globe clock and rotation.
- `Globe::pick_screen` (`registry.rs`): Pick a province at screen coordinates or return None when no province matches.
- `Globe::emit_frame` (`registry.rs`): Emit render commands for the current globe state.
- `Globe::set_heat_layer` (`registry.rs`): Add or replace a heat layer by name.
- `Globe::remove_heat_layer` (`registry.rs`): Remove a heat layer by name and return true when one was removed.
- `Globe::set_province_sector` (`registry.rs`): Assign a province to a named sector.
- `Globe::province_sector` (`registry.rs`): Return the sector name that contains a province when one exists.
- `Globe::sector_provinces` (`registry.rs`): Return all province ids for a named sector.
- `Globe::cache_reachability_default` (`registry.rs`): Cache default reachability for a faction name.
- `Globe::cached_reachability` (`registry.rs`): Return cached reachability for a faction when present.
- `GlobeRegistry::new` (`registry.rs`): Create an empty globe registry.
- `GlobeRegistry::create` (`registry.rs`): Create or replace a globe and return a mutable reference to it.
- `GlobeRegistry::get` (`registry.rs`): Return a shared globe reference when the name exists.
- `GlobeRegistry::get_mut` (`registry.rs`): Return a mutable globe reference when the name exists.
- `GlobeRegistry::remove` (`registry.rs`): Remove a globe by name and return it when found.
- `GlobeRegistry::names` (`registry.rs`): Return all globe names in arbitrary order.
- `GlobeRegistry::len` (`registry.rs`): Return the number of stored globes.
- `GlobeRegistry::is_empty` (`registry.rs`): Return true when no globes are stored.
- `GlobeSyncChannel::new` (`sync.rs`): Create a new snapshot channel pair.
- `build_snapshot` (`sync.rs`): Build a snapshot from the current globe state.
- `apply_snapshot` (`sync.rs`): Apply a snapshot to a mutable globe instance.
- `ProvinceGraph::new` (`topology.rs`): Create an empty province graph.
- `ProvinceGraph::insert` (`topology.rs`): Insert a province and update the cached adjacency data.
- `ProvinceGraph::remove` (`topology.rs`): Remove a province and its cached data, returning the removed province when present.
- `ProvinceGraph::get` (`topology.rs`): Return a shared province reference when the id exists.
- `ProvinceGraph::get_mut` (`topology.rs`): Return a mutable province reference when the id exists.
- `ProvinceGraph::iter` (`topology.rs`): Iterate over all stored provinces.
- `ProvinceGraph::len` (`topology.rs`): Return the number of stored provinces.
- `ProvinceGraph::is_empty` (`topology.rs`): Return true when no provinces are stored.
- `ProvinceGraph::find_path` (`topology.rs`): Find a province path or return NoPath when no route exists.
- `ProvinceGraph::reachable` (`topology.rs`): Return provinces reachable within the supplied maximum cost.
- `ProvinceGraph::neighbors_of` (`topology.rs`): Return the cached neighbor slice for a province or an empty slice when missing.
- `ProvinceGraph::set_attr` (`topology.rs`): Set a province attribute or return ProvinceNotFound when the id is missing.
- `ProvinceGraph::get_attr` (`topology.rs`): Return a province attribute as a string slice when it exists.
- `ProvinceGraph::find_path_default` (`topology.rs`): Find a province path with the default cost function.
- `ProvinceGraph::reachable_default` (`topology.rs`): Return reachable provinces with the default cost function.
- `ProvinceGraph::rebuild_caches` (`topology.rs`): Rebuild all cached adjacency and edge-tag data from the stored provinces.
- `Province::new` (`types.rs`): Create a province from vertices and derive a centroid from them.
- `Province::with_data` (`types.rs`): Create a province from explicit cached data.
- `Layer::new` (`types.rs`): Create a visible overlay layer with the supplied name, kind, and z-order.

## Lua API Reference

- Binding path(s): `src/lua_api/globe_api.rs`
- Namespace: `lurek.globe`

### Module Functions
- `lurek.globe.new`: Creates a named globe with optional specification fields in the module registry.
- `lurek.globe.get`: Returns a globe from the module registry by name.
- `lurek.globe.loadFromTOML`: Creates a globe and populates provinces from TOML source text.
- `lurek.globe.loadFromPNG`: Creates a globe and populates provinces from a PNG file.
- `lurek.globe.generateVoronoi`: Creates a globe and populates provinces from latitude-longitude seed points.
- `lurek.globe.greatCircleDistance`: Computes great-circle distance between two latitude-longitude points.
- `lurek.globe.greatCirclePath`: Computes sampled latitude-longitude points along a great-circle path.
- `lurek.globe.latLonToUnit`: Converts latitude and longitude to a unit-sphere 3D vector table.

### `LGlobe` Methods
- `LGlobe:addProvince`: Adds a province described by id, centroid, vertices, neighbors, and optional base color.
- `LGlobe:removeProvince`: Removes a province by id. This method is available to Lua scripts.
- `LGlobe:provinceCount`: Returns the number of provinces in this globe.
- `LGlobe:getNeighbors`: Returns neighboring province ids for a province.
- `LGlobe:setProvinceAttr`: Sets a string attribute on a province.
- `LGlobe:getProvinceAttr`: Reads a string attribute from a province.
- `LGlobe:setProvinceTexture`: Assigns a raw texture handle and UV rectangle to a province.
- `LGlobe:clearProvinceTexture`: Removes texture metadata from a province.
- `LGlobe:setProvinceSector`: Assigns a province to a named sector.
- `LGlobe:getProvinceSector`: Returns the sector name assigned to a province.
- `LGlobe:getSectorProvinces`: Returns province ids assigned to a sector.
- `LGlobe:setHeatLayer`: Creates or replaces a heat layer that maps province attributes into colors.
- `LGlobe:removeHeatLayer`: Removes a heat layer by name. This method is available to Lua scripts.
- `LGlobe:pan`: Pans the globe camera by latitude and longitude deltas.
- `LGlobe:zoom`: Multiplies the globe camera zoom by a factor.
- `LGlobe:setCamera`: Sets camera latitude, longitude, and zoom.
- `LGlobe:getCamera`: Returns camera latitude, longitude, and zoom.
- `LGlobe:getLod`: Returns the camera-derived level-of-detail tier name.
- `LGlobe:pick`: Picks a province at screen coordinates.
- `LGlobe:pickRaycast`: Samples along a screen ray from the camera center and returns the first hit province.
- `LGlobe:pickLatLon`: Picks at screen coordinates and returns the hit province centroid screen coordinates.
- `LGlobe:setActiveViewer`: Sets the active fog-of-war viewer name or clears it.
- `LGlobe:setFogState`: Sets fog-of-war state for one viewer and province.
- `LGlobe:getFogState`: Returns fog-of-war state for one viewer and province.
- `LGlobe:encodeFogBase64`: Serializes one viewer's fog state to a base64 string.
- `LGlobe:decodeFogBase64`: Loads one viewer's fog state from a base64 string.
- `LGlobe:revealProvince`: Reveals a province for one fog-of-war viewer.
- `LGlobe:hideProvince`: Hides a province for one fog-of-war viewer.
- `LGlobe:isVisible`: Returns whether a province is visible for one fog-of-war viewer.
- `LGlobe:revealAll`: Reveals every province for one fog-of-war viewer.
- `LGlobe:addMarker`: Adds a marker at latitude and longitude with an optional label.
- `LGlobe:removeMarker`: Removes a marker by id. This method is available to Lua scripts.
- `LGlobe:moveMarker`: Moves a marker to latitude and longitude coordinates.
- `LGlobe:setMarkerVisible`: Shows or hides a marker. This method is available to Lua scripts.
- `LGlobe:setMarkerPulse`: Sets marker pulse frequency and amplitude.
- `LGlobe:setMarkerRotation`: Sets marker rotation speed. This method is available to Lua scripts.
- `LGlobe:setMarkerAttr`: Sets a string attribute on a marker.
- `LGlobe:getMarkerAttr`: Reads a string attribute from a marker.
- `LGlobe:addLabel`: Adds a text label at latitude and longitude.
- `LGlobe:setLabelText`: Changes text for an existing label.
- `LGlobe:setLabelVisible`: Shows or hides a label. This method is available to Lua scripts.
- `LGlobe:removeLabel`: Removes a label by id. This method is available to Lua scripts.
- `LGlobe:addLayer`: Adds a render layer with optional z-order.
- `LGlobe:removeLayer`: Removes a render layer by name. This method is available to Lua scripts.
- `LGlobe:setLayerColor`: Sets a province color override inside a render layer.
- `LGlobe:setLayerVisible`: Shows or hides a render layer. This method is available to Lua scripts.
- `LGlobe:setLayerAlpha`: Sets render layer alpha. This method is available to Lua scripts.
- `LGlobe:setTimeOfDay`: Sets globe time of day modulo 24 hours.
- `LGlobe:getTimeOfDay`: Returns globe time of day. This method is available to Lua scripts.
- `LGlobe:setRotation`: Sets globe rotation angle. This method is available to Lua scripts.
- `LGlobe:setAutoRotationSpeed`: Sets automatic globe rotation speed.
- `LGlobe:update`: Advances globe simulation timers and animated state.
- `LGlobe:setBorders`: Enables or disables province border rendering.
- `LGlobe:findPath`: Finds a default-cost province path between two province ids.
- `LGlobe:reachable`: Returns provinces reachable from a start province within a cost budget.
- `LGlobe:cacheReachability`: Caches default-cost reachability for a named faction.
- `LGlobe:getCachedReachability`: Returns cached reachability costs for a faction.
- `LGlobe:exportProvinceMeshOBJ`: Exports province geometry as Wavefront OBJ text.
- `LGlobe:addArc`: Adds a visible route arc between two latitude and longitude points.
- `LGlobe:removeArc`: Removes an arc by id. This method is available to Lua scripts.
- `LGlobe:getName`: Returns the registry name of this globe.
- `LGlobe:type`: Returns the Lua-visible type name for this globe handle.
- `LGlobe:typeOf`: Returns whether this globe handle matches a supported type name.

### `LGlobeRegistry` Methods
- `LGlobeRegistry:new`: Creates a named globe with optional specification fields.
- `LGlobeRegistry:get`: Returns a globe handle by registry name.
- `LGlobeRegistry:remove`: Removes a globe from the registry by name.
- `LGlobeRegistry:names`: Returns all globe names currently stored in this registry.
- `LGlobeRegistry:type`: Returns the Lua-visible type name for this globe registry handle.
- `LGlobeRegistry:typeOf`: Returns whether this registry handle matches a supported type name.

## References

- `image`: Imports or references `src/image/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `math`: Imports or references `src/math/`. Cross-group dependency from `Edge/Integration` into `Foundations`.
- `pathfind`: Imports or references `src/pathfind/`. Cross-group dependency from `Edge/Integration` into `Feature Systems`.
- `province`: Imports or references `src/province/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `render`: Imports or references `src/render/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Edge/Integration` into `Core Runtime`.

## Notes

- **A-03**: All rendering is 2D. `DrawConvexFan` + `Polyline` + `Circle`. No new wgpu pipeline.
- **B-05**: Province maps use TOML (`[[province]]` arrays). JSON is acceptable for external map-editor interop.
- **MAX_PROVINCES = 8192**: Soft cap. Increase `FogMask::WORD_COUNT` and `MAX_PROVINCES` together.
- **Fog serialization**: `FogMask::visible_ids()` + `from_visible_ids()` pair is the recommended pattern for `lurek.save.*` integration.
- **Multi-globe**: `GlobeRegistry` stores `HashMap<String, Globe>`. Multiple globes are independent.
- **Font keys**: `emit_frame(default_font)` requires a `FontKey` from the engine's resource cache. Pass `None` to suppress all text.
