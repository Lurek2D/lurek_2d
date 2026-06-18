# vector

## TL;DR

- Provides dynamic SVG vector parsing, hit-testing, state read-back, hierarchy navigation, and GPU-cached rendering.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/vector/`
- Binding: None direct
- Namespace: `lurek.svg`
- Lua API surface: `1` functions, `1` types, `24` methods
- Rust test path(s): None
- Lua test path(s): tests/lua/unit/test_svg_unit.lua

## Summary

- The `vector` module is the engine surface for scalable vector artwork, aimed at users who want SVG-style content to stay editable and resolution-independent for as long as possible.
- It keeps vector parsing, scene representation, and runtime conversion behavior together so vector assets can live inside the normal content flow instead of being forced into a separate external pipeline.
- This is useful for UI artwork that should survive scaling without raster duplication.
- Read it as the point where scalable art becomes usable in the rest of the engine while staying distinct from raster-first asset workflows.

## Imports

- `math`: Imports or references `src/math/`. Cross-group dependency from `Edge/Integration` into `Foundations`.
- `render`: Imports or references `src/render/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Edge/Integration` into `Core Runtime`.

## Files

### mod.rs

- `src/vector/mod.rs` is the vector module index, exposing SVG document types and loading surfaces for runtime rendering.
- It reexports `SvgElement`, `SvgImage`, and `SvgPath` so callers reach vector scene data through one stable boundary.
- No parsed vector state lives here; this file defines visibility while parsing logic stays in `svg_image.rs`.
- Read this index when wiring vector features, because it shows which SVG-facing contracts are public and shared.
- Changes here alter the vector boundary, since reexports decide what runtime systems and bindings may import directly.
- This module keeps scene representation and vector loading separate from higher-level render and Lua binding layers.

### svg_image.rs

- `src/vector/svg_image.rs` owns SVG parsing, normalized scene representation, and runtime rendering for vector content.
- It defines `SvgPath`, `SvgElement`, and `SvgImage`, keeping geometry, hierarchy state, and canvas handles together.
- Raw SVG bytes are parsed here into a tree of groups and paths, then normalized into engine-owned element maps and IDs.
- Element transforms, visibility, color overrides, and cached subtree canvases are managed here as runtime vector state.
- Render submission also lives here, so parsed vector data emits `RenderCommand` sequences without a separate adapter.
- Hierarchy queries, point flattening, bounds extraction, and adjacency detection are handled here for gameplay and tools.
- Open this file when SVG parse policy, element state semantics, canvas caching, or vector rendering must change.
- Neighboring systems matter here mainly at the math, render, and runtime boundaries that supply transforms and commands.
- This file is the owner boundary for vector scene behavior; higher layers should treat it as the source of SVG state.



## Lua API Ref

### Functions

- `lurek.svg.load(path) -> nil`: Load and parse an SVG file from the game directory.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LSvgImage Type

- Represents the Lua-visible LSvgImage object.

##### Fields

- No documented fields.

##### Methods

- `LSvgImage:cacheToCanvas(id, w, h) -> nil`: Rasterizes a specific SVG element/group onto an off-screen GPU Canvas.
- `LSvgImage:draw(x, y, rotation?, sx?, sy?, ox?, oy?) -> nil`: Renders the SVG document at the given position and transform overrides.
- `LSvgImage:getAdjacencies(prefix, epsilon?) -> table`: Detects neighboring provinces using point-to-point proximity.
- `LSvgImage:getCanvas(id) -> LCanvas`: Returns the cached canvas handle for an element.
- `LSvgImage:getCanvasKey(id) -> LCanvas`: Returns the LCanvas handle for a previously cached element/group.
- `LSvgImage:getDimensions() -> number, number`: Returns both the document width and height as two values: `width, height`.
- `LSvgImage:getElementBounds(id) -> table`: Returns the axis-aligned bounding box `{min_x, min_y, max_x, max_y}` of the element.
- `LSvgImage:getElementChildren(id) -> table`: Returns a sequential table of direct child element IDs for the given group element.
- `LSvgImage:getElementColor(id) -> table`: Returns the current RGBA color override `{r, g, b, a}` table for the element.
- `LSvgImage:getElementCount() -> integer`: Returns the total number of parsed elements (paths and groups) in this SVG document.
- `LSvgImage:getElementIds() -> table`: Returns a list of all parsed element and group IDs.
- `LSvgImage:getElementParent(id) -> string`: Returns the parent element ID string, or `nil` when the element is the root or not found.
- `LSvgImage:getElementPoints(id, step_size?) -> table`: Flattens the element path into a polygon array of LVec2 userdata.
- `LSvgImage:getElementTransform(id) -> table`: Returns the current dynamic TRS state of the element as a table `{tx, ty, rotation, sx, sy}`.
- `LSvgImage:getElementVisible(id) -> boolean`: Returns the current visibility flag for the element.
- `LSvgImage:getHeight() -> number`: Returns the document height in points/pixels.
- `LSvgImage:getWidth() -> number`: Returns the document width in points/pixels.
- `LSvgImage:resetElementColor(id) -> nil`: Clears the color override on the element, restoring original SVG path colors.
- `LSvgImage:resetElementTransform(id) -> nil`: Resets the runtime translation, rotation, and scale of the element to identity.
- `LSvgImage:setElementColor(id, r, g, b, a) -> nil`: Overrides the fill/stroke color of a specific element/group by ID.
- `LSvgImage:setElementTransform(id, tx, ty, rotation, sx, sy) -> nil`: Dynamically transforms a specific element/group by ID.
- `LSvgImage:setElementVisible(id, visible) -> nil`: Toggles the visibility of a specific element/group by ID.
- `LSvgImage:type() -> string`: Returns the fixed type name for this userdata.
- `LSvgImage:typeOf(name) -> boolean`: Check whether this object matches a given type name.

## References

- `math`: Imports or references `src/math/`. Cross-group dependency from `Edge/Integration` into `Foundations`.
- `render`: Imports or references `src/render/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Edge/Integration` into `Core Runtime`.

## Notes

- No additional module-specific notes.
