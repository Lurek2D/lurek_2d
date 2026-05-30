# minimap

## TL;DR

- The `minimap` module is a robust Feature Systems tier component that implements a highly configurable, grid-based minimap and radar system for Lurek2D.

## General Info

- Module group: `Feature Systems`
- Source path: `src/minimap/`
- Binding: `src/lua_api/minimap_api.rs`
- Namespace: `lurek.minimap`
- Lua API surface: `1` functions, `1` types, `86` methods
- Rust test path(s): tests/rust/game/minimap_tests.rs
- Lua test path(s): tests/lua/unit/test_minimap.lua, tests/lua/evidence/test_evidence_minimap.lua

## Summary

It manages an independent grid of terrain cells, allowing games to display a scaled-down representation of the world entirely distinct from the main rendering pipeline. The core `Minimap` struct maintains multi-layered cellular data encompassing terrain types, associated colors, and a sophisticated three-state fog-of-war system (Hidden, Explored, Visible) that dynamically restricts player vision and modifies rendered cell colors based on discovery status.

Beyond basic terrain visualization, the minimap acts as a comprehensive strategic display. It tracks active game entities via `MinimapObject`s, which project world positions onto the grid and render as typed, owner-colored dots or assigned texture icons. To support mission and location tracking, it provides a `MinimapMarker` system for persistent or timed points of interest, featuring built-in animation states like blinking, pulsing, or rotating crosshairs. For strategic feedback, the module supports dynamic `OverlayShape`s (lines, rectangles, named polyline paths) and temporary animated `MinimapPing` alerts to draw player attention to specific map coordinates.

The module also features a robust rendering pipeline that composites these layers—terrain, fog, overlays, objects, markers, and pings—into an optimized `ImageData` buffer or directly generates an ordered list of `RenderCommand`s. It fully supports configurable display resolutions, zoom levels, panning, and automatic camera-tracking viewports that overlay the player's active screen bounds. To support diverse game genres, it offers multiple color modes, such as switching between standard terrain-colored views and political owner-colored strategic modes. Bridging seamlessly with other systems like the `province` registry, this entire feature set is exposed to Lua scripts via the `lurek.minimap.*` API, enabling developers to build complex, interactive UI maps with minimal engine overhead.

## Imports

- `camera`: Imports or references `src/camera/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `image`: Imports or references `image` from `src/image/`.
- `province`: Imports or references `src/province/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `raycaster`: Imports or references `src/raycaster/`. Dependency stays inside `Feature Systems` and should remain acyclic.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### minimap.rs

- Grid-based minimap model with configurable terrain colors and fog-of-war.
- Tracks world cells, visible state, and overlay layers in one structure.
- Stores object markers, pings, and path shapes for live HUD feedback.
- Supports terrain and political color modes for strategic presentation.
- Manages zoom, pan, camera tracking, and viewport framing.
- Projects screen and grid coordinates in both directions for interaction.
- Renders CPU-side image buffers for export and preview use cases.
- Includes timed animation behaviors for pings and persistent markers.
- Separates layer data so the minimap can stack multiple map representations.
- Keeps hover and hit information available for UI and debug tools.
- Balances compact runtime state with flexible overlay composition.
- Provides the main data source for both generic and raycaster-style minimaps.

### mod.rs

- Minimap subsystem for terrain layers, fog, markers, overlays, and export rendering.
- Connects the grid model with renderer output, province data, and raycaster-specific views.
- Keeps all minimap-facing state under one runtime namespace.

### province_adapter.rs

- Bridge between province world data and the minimap grid.
- Copies terrain, fog, and palette state into a minimap representation.
- Clips to the smaller grid so size mismatches stay safe.
- Lets world-region data feed the minimap without custom glue code.

### raycaster_overlay.rs

- Raycaster-specific minimap overlay renderer for tile-based visibility views.
- Builds a pixel-grid minimap from wall, floor, and lighting information.
- Uses line-of-sight and Bresenham traversal to reveal reachable cells.
- Fills raw RGBA buffers for fast image output and preview rendering.
- Draws the player indicator as a compact orientation cue on top of the map.
- Serves as the specialised bridge between raycasting state and minimap output.

### render.rs

- Converts minimap state into an ordered render command stream.
- Draws terrain, fog, overlays, objects, pings, markers, and viewport guides.
- Projects grid coordinates through the minimap transform into screen space.
- Keeps the drawing order stable so HUD elements stack predictably.
- Supports zoom-dependent and animated presentation without mutating the world model.
- Acts as the generic renderer path for the minimap subsystem.

### types.rs

- Shared minimap data types for colors, fog, overlays, and live markers.
- Defines the small enums and structs that other minimap files reuse.
- Carries per-object and per-path state for animated overlays.
- Separates raw layer bytes from higher-level minimap behavior.
- Provides the data vocabulary for the whole minimap subsystem.

## Lua API Ref

### Functions

- `lurek.minimap.newMinimap`: Creates a minimap with grid dimensions and optional display size.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LMinimap Type

- Lua-side wrapper for a minimap instance and access to render command state.

##### Fields

- No documented fields.

##### Methods

- `LMinimap:addMarker`: Adds a world-space marker and returns its unique id.
- `LMinimap:addObjectType`: Adds an object type and returns its one-based index.
- `LMinimap:addPing`: Adds a timed ping effect at a minimap world position.
- `LMinimap:clearMarkerAnimation`: Clears the animation assigned to a marker by id.
- `LMinimap:clearMarkerTexture`: Clears image texture from a marker.
- `LMinimap:clearObjectTypeTexture`: Clears image texture for an object type.
- `LMinimap:clearObjects`: Clears all objects from the minimap.
- `LMinimap:clearOverlay`: Clears all minimap overlay shapes.
- `LMinimap:clearPath`: Clears one path by id or all paths when no id is provided.
- `LMinimap:clearViewportRect`: Clears the minimap viewport rectangle overlay.
- `LMinimap:drawLine`: Adds an overlay line between two world-space points.
- `LMinimap:drawRect`: Adds an overlay rectangle at a world-space position.
- `LMinimap:drawToImage`: Draws the minimap into image data at a pixel size.
- `LMinimap:getCellCount`: Returns the total number of grid cells.
- `LMinimap:getCenter`: Returns the current minimap world-space center position.
- `LMinimap:getCenterX`: Returns minimap world center x coordinate.
- `LMinimap:getCenterY`: Returns minimap world center y coordinate.
- `LMinimap:getColorMode`: Returns the current minimap color mode.
- `LMinimap:getDisplayHeight`: Returns the minimap display height.
- `LMinimap:getDisplaySize`: Returns the minimap display width and height in pixels.
- `LMinimap:getDisplayWidth`: Returns the minimap display width.
- `LMinimap:getFogColor`: Returns the current RGBA fog overlay color.
- `LMinimap:getFogLevel`: Returns fog level for a one-based grid cell.
- `LMinimap:getGridHeight`: Returns the height of the minimap grid in cells.
- `LMinimap:getGridSize`: Returns the minimap grid width and height in cells.
- `LMinimap:getGridWidth`: Returns the width of the minimap grid in cells.
- `LMinimap:getHoverInfo`: Returns hover text for a screen position when available.
- `LMinimap:getLayer`: Returns the active minimap display layer index.
- `LMinimap:getLayerCount`: Returns the number of minimap layers.
- `LMinimap:getLayerData`: Returns raw cell data for a minimap layer.
- `LMinimap:getMarkerCount`: Returns the total number of minimap markers.
- `LMinimap:getMarkerDescription`: Returns a marker description by id.
- `LMinimap:getObjectCount`: Returns the number of objects on the minimap.
- `LMinimap:getObjectTypeCount`: Returns the number of object types.
- `LMinimap:getOverlayShapeCount`: Returns the number of overlay shapes.
- `LMinimap:getOwnerColor`: Returns the current RGBA color for an owner id.
- `LMinimap:getPathCount`: Returns the number of active path overlays.
- `LMinimap:getPingCount`: Returns the number of active pings.
- `LMinimap:getTerrain`: Returns terrain type for a one-based grid cell.
- `LMinimap:getTerrainColor`: Returns RGBA color for a terrain type.
- `LMinimap:getTileDescription`: Returns text description for a tile type.
- `LMinimap:getViewportColor`: Returns the viewport rectangle color.
- `LMinimap:getViewportRect`: Returns the viewport rectangle when one is set.
- `LMinimap:getZoom`: Returns the current minimap zoom magnification level.
- `LMinimap:gridToScreen`: Converts grid coordinates to screen coordinates.
- `LMinimap:hasMarker`: Returns whether a marker id exists.
- `LMinimap:isAntiAlias`: Returns whether anti-aliasing is enabled.
- `LMinimap:isClickable`: Returns whether minimap click handling is enabled.
- `LMinimap:isFogEnabled`: Returns whether fog display is enabled.
- `LMinimap:isObjectTypeVisible`: Returns visibility for an object type by one-based index.
- `LMinimap:isViewportVisible`: Returns whether the viewport rectangle is visible.
- `LMinimap:removeMarker`: Removes a minimap marker by its unique id.
- `LMinimap:removeObject`: Removes a minimap object by its unique id.
- `LMinimap:render`: Enqueues minimap render commands at an optional screen position.
- `LMinimap:revealRadius`: Reveals fog inside a world-space radius.
- `LMinimap:screenToGrid`: Converts a screen position to grid coordinates.
- `LMinimap:setAntiAlias`: Enables or disables minimap anti-aliasing.
- `LMinimap:setCenter`: Sets the minimap world-space center position.
- `LMinimap:setClickable`: Enables or disables minimap click handling.
- `LMinimap:setColorMode`: Sets the minimap color mode to terrain or political.
- `LMinimap:setDisplaySize`: Sets the minimap display width and height in pixels.
- `LMinimap:setFogColor`: Sets the RGBA fog overlay color for covered cells.
- `LMinimap:setFogData`: Replaces fog data from a flat array table.
- `LMinimap:setFogEnabled`: Enables or disables the minimap fog display.
- `LMinimap:setFogLevel`: Sets fog level for a one-based grid cell.
- `LMinimap:setLayer`: Sets the active minimap display layer index.
- `LMinimap:setLayerData`: Sets raw cell data for a minimap layer.
- `LMinimap:setMarkerAnimation`: Sets marker animation by type name.
- `LMinimap:setMarkerTexture`: Assigns an image texture to a marker.
- `LMinimap:setObject`: Adds or updates an object on the minimap.
- `LMinimap:setObjectTypeTexture`: Assigns an image texture to an object type.
- `LMinimap:setObjectTypeVisible`: Sets visibility for an object type by one-based index.
- `LMinimap:setOwnerColor`: Sets the RGBA display color for an owner id.
- `LMinimap:setTerrain`: Sets terrain type for a one-based grid cell.
- `LMinimap:setTerrainColor`: Sets the RGBA display color for a terrain type.
- `LMinimap:setTerrainData`: Replaces terrain data from a flat array table.
- `LMinimap:setTileDescription`: Sets text description for a tile type.
- `LMinimap:setViewportColor`: Sets the viewport rectangle color.
- `LMinimap:setViewportRect`: Sets the visible viewport rectangle shown on the minimap.
- `LMinimap:setViewportVisible`: Sets whether the viewport rectangle is visible.
- `LMinimap:setZoom`: Sets the minimap zoom magnification level.
- `LMinimap:showPath`: Adds a colored path overlay and returns its id.
- `LMinimap:trackCamera`: Centers the minimap and viewport rectangle from a camera handle.
- `LMinimap:type`: Returns the Lua-visible type name for this minimap handle.
- `LMinimap:typeOf`: Returns whether this minimap handle matches a supported type name.
- `LMinimap:update`: Advances minimap animations and timers.
