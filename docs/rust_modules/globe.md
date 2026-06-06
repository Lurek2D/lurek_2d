# globe

## General Info

- Module group: `Feature Systems`
- Source path: `src/globe/`
- Binding: `src/lua_api/globe_api.rs`
- Namespace: `lurek.globe`
- Lua API surface: `11` functions, `4` types, `72` methods
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

This module represents the interactive planetary globe simulation and rendering subsystem, providing rich interfaces to model and display spherical world maps. It operates on region topologies representing territories, provinces, or coordinates mapped onto a unit sphere. By combining coordinate math and orbital projections, it manages interactive camera controls like panning, panning bounds, and variable zooms, translating screen inputs into latitude and longitude coordinates.

Visual styling and presentation are managed through a layered rendering system. The module draws projected regions with configurable lighting, borders, atmosphere, and visual overlays like thematic heatmaps. Illumination calculations determine local day-night cycles and terminator lines dynamically. Additionally, the system supports multi-view compositions, allowing developers to present side-by-side or comparative map screens under unified camera matrices.

To display tactical information, the system includes marker and label managers. Pins, labels, and routes are placed directly onto the globe surface using spherical coordinates. The drawing pipeline manages these overlays dynamically, applying level-of-detail visibility gates that scale annotation densities based on camera zoom. This prevents text overlap, keeping text annotations and indicators readable when viewing large geographic spans.

Strategic gameplay is supported by customizable fog-of-war masks and topological pathfinding. Fog states track visibility tiers like explored or hidden, allowing different viewers to maintain separate maps. The underlying topology graph links region centroids with adjacency lists, exposing reachability matrices and routes across regions. Finally, adapter adapters translate political ownership into colored visual boundaries in real-time.

Ingestion and export pathways allow developers to seed and extract map data easily. Globes can be built from TOML descriptors, PNG images, or generated procedurally from Voronoi seed coordinates. Geometry export tools serialize region shapes directly into standard mesh formats for inspection or offline editing. This bridges design tooling with the active runtime world, ensuring maps remain fully customizable.

## Files

### [composition.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/globe/composition.rs)

- Provides split-view globe composition that merges multiple named views into one render batch.
- Applies per-entry viewport centers while preserving each globe's camera-relative projection behavior.
- Delivers multi-panel frame assembly for comparative or tactical map presentation.

### [draw.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/globe/draw.rs)

- Provides full globe frame emission that converts world map state into ordered render commands.
- Draws projected regions with fog, lighting, overlays, and optional texture contribution.
- Renders borders, atmosphere, and arcs to preserve geographic structure and visual depth cues.
- Integrates marker and label drawing with animation and LOD-aware visibility rules.
- Applies camera projection and world parameters consistently across all rendered primitives.
- Supports layered heat and style effects so thematic map signals remain legible.
- Delivers the end-to-end draw pipeline for globe visualization in runtime frames.

### [export.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/globe/export.rs)

- Provides globe geometry export helpers that convert region polygons into portable mesh text output.
- Emits flat OBJ data with deterministic region object grouping for downstream tooling.
- Delivers a simple export path for inspection, conversion, and offline map processing workflows.

### [fog.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/globe/fog.rs)

- Provides compact per-region fog state storage with hidden, explored, and visible visibility tiers.
- Supports per-viewer mask ownership so different observers can maintain independent map knowledge.
- Exposes reveal, hide, explore, and toggle operations for direct gameplay-state updates.
- Includes serialization-friendly encoding to persist fog state across save and restore cycles.
- Supplies query helpers that report visible and explored subsets for UI and logic consumers.
- Delivers the fog-of-war backbone used by globe rendering and strategic information gating.

### [label.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/globe/label.rs)

- Provides id-keyed globe label storage for map annotations positioned by latitude and longitude.
- Supports add, remove, update, and visibility operations for dynamic labeling workflows.
- Applies LOD-aware filtering so text density scales with camera detail level.
- Maintains stable iteration outputs used by rendering and debugging interfaces.
- Delivers the label-management layer for readable and controllable geographic annotation.

### [layer.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/globe/layer.rs)

- Provides named globe layer storage that overlays per-region color and visibility modifications.
- Supports insert, remove, lookup, and alpha control for composable thematic map styling.
- Resolves effective colors in z-order so stacked overlays produce deterministic final output.
- Delivers the overlay-composition layer used by draw logic and gameplay visualization.

### [lighting.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/globe/lighting.rs)

- Provides globe lighting helpers that derive sun direction and regional light intensity over time.
- Computes diffuse contribution with ambient floors to keep night-side visuals readable.
- Supports batch intensity and terminator blending calculations for smooth day-night transitions.
- Delivers reusable illumination math consumed by globe rendering passes.

### [loader.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/globe/loader.rs)

- Provides globe region-loading workflows from TOML, raster grids, and generated Voronoi seed sources.
- Parses lightweight structured input into normalized region records with geometry and adjacency data.
- Converts intermediate builder state into shared globe region types used across the subsystem.
- Extracts bounds and neighbor hints from image-driven province maps for quick content bootstrapping.
- Handles primitive parsing and validation to keep load-time failures explicit and actionable.
- Supports both in-memory string input and file-based ingestion paths for tooling flexibility.
- Delivers the map-ingestion layer that seeds topology and rendering state for globe runtime use.

### [marker.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/globe/marker.rs)

- Provides stable-id globe marker storage for pins and point annotations on planetary surfaces.
- Supports marker insertion, removal, movement, and lookup by id or classification type.
- Manages marker visibility and custom attributes for flexible runtime presentation.
- Keeps marker collections deterministic for rendering and interaction queries.
- Delivers the marker-management layer used by tactical and informational map overlays.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/globe/mod.rs)

- Provides the high-level globe module boundary for region topology, projection, and visual overlay orchestration.
- Connects rendering, fog state, markers, labels, layers, and picking into one map-runtime surface.
- Supports synchronization and loading flows so globe state can be updated from external game systems.
- Delivers a cohesive planetary-view feature set for strategic map presentation and interaction.

### [picking.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/globe/picking.rs)

- Provides screen-space globe picking that identifies visible regions under pointer coordinates.
- Projects region geometry into 2D and applies point-in-polygon hit testing for selection.
- Chooses the front-most valid candidate using camera-facing depth information.
- Delivers interaction picking results consumed by UI and gameplay selection flows.

### [projection.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/globe/projection.rs)

- Provides globe projection math driven by an orbit camera with latitude, longitude, and zoom control.
- Builds view transforms from globe rotation, axial tilt, and camera orientation inputs.
- Projects points and regions from spherical coordinates into screen-space render geometry.
- Applies facing checks and depth culling to reject back-hemisphere geometry during projection.
- Delivers camera and projection utilities used by drawing, picking, and interaction code paths.

### [province_adapter.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/globe/province_adapter.rs)

- Provides a bridge that applies province-registry ownership and visibility state onto globe regions.
- Synchronizes political coloring so map visuals reflect current simulation authority data.
- Delivers adapter logic that keeps province gameplay state aligned with globe presentation.

### [registry.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/globe/registry.rs)

- Provides mutable globe state that aggregates topology, camera, fog, overlays, and interaction data.
- Owns region storage operations together with markers, labels, layers, arcs, and heat visual layers.
- Integrates camera projection and picking paths so selection and rendering share one state container.
- Emits full-frame render commands from current globe state for deterministic map visualization.
- Caches sector and reachability information to support strategic lookup and path-cost workflows.
- Delivers named registry management for handling multiple independent globe instances.

### [sphere.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/globe/sphere.rs)

- Provides spherical geometry helpers for converting between latitude-longitude and unit-vector space.
- Computes great-circle distance and interpolation for geodesic path and arc construction.
- Supplies ray-sphere intersection tests used by projection and picking style calculations.
- Defines lightweight 3x3 rotation matrices and multiplication helpers for globe transforms.
- Delivers foundational math primitives shared across lighting, projection, and topology tools.

### [sync.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/globe/sync.rs)

- Provides globe snapshot transfer structures for cross-thread synchronization and state exchange.
- Defines channel wrappers and snapshot payload shapes used to move globe state safely.
- Supports building and applying snapshots to keep remote and local globe views aligned.
- Delivers the synchronization utility layer for background simulation integration.

### [topology.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/globe/topology.rs)

- Provides region-topology graph storage with cached adjacency, centroids, and tagged border edges.
- Supports insertion, removal, and mutation workflows while keeping lookup caches coherent.
- Integrates pathfinding-friendly queries for route, cost, and reachability evaluation across regions.
- Exposes neighbor and region iteration helpers used by rendering and gameplay systems.
- Delivers the structural map-graph backbone that powers globe connectivity logic.

### [types.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/globe/types.rs)

- Provides the shared globe data model defining regions, overlays, markers, labels, arcs, and view artifacts.
- Encodes geographic geometry with centroids, adjacency, edge tags, and per-region render attributes.
- Defines globe specification parameters that drive atmosphere, lighting, rotation, and border behavior.
- Supplies layer and heat-overlay structures used to blend thematic map information at runtime.
- Models marker and label style data with visibility, pulse, and level-of-detail controls.
- Includes projection result types for screen-space rendering and interaction pipelines.
- Declares subsystem error variants for loading, lookup, and path-related failure handling.
- Delivers the canonical type contract consumed by all globe modules and integration surfaces.
