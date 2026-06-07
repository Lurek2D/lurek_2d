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

The `vector` module implements loading, parsing, hierarchy walking, rendering, and GPU caching for SVG vector graphics. It supports dynamic modifications of SVG elements (color overrides, visibility toggles, local transformations), precomputes adjacency graphs for province mapping, and allows caching complex vector subtrees to off-screen GPU canvases to optimize frame rendering.

The module is designed as the vector-graphics analogue to the `image` module: it provides the same read-back and reset patterns so Lua scripts can query current state and restore defaults without reloading the document.

This module primarily collaborates with `math`, `render`, `runtime`. Its responsibility should stay inside the Edge/Integration group rather than absorb behavior owned by those neighbors.

## Imports

- `math`: Imports or references `src/math/`. Cross-group dependency from `Edge/Integration` into `Foundations`.
- `render`: Imports or references `src/render/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Edge/Integration` into `Core Runtime`.

## Files

### mod.rs

- High-level vector graphics module that implements SVG loading, parsing, state management, and GP-accelerated rendering.
- Bridges parsed XML vector trees and Lurek2D's RenderCommand drawing pipeline.

### svg_image.rs

- Implements the main SVG document parser, layout representation, and rendering bridge.
- Traverses the usvg tree, flattens it, and manages per-element runtime state.
- Provides hierarchy queries (parent, children, count), bounding box extraction,
- color/visibility/transform reads and resets, and GPU canvas caching for vector subtrees.
- All mutation methods follow the same error contract: return `Err` when the element ID is absent.

## Lua API Ref

### Functions

- `lurek.svg.load(path) -> nil`: Lua-facing function documented in the binding source.

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
- `LSvgImage:getAdjacencies(prefix, epsilon?) -> nil`: Detects neighboring provinces using point-to-point proximity.
- `LSvgImage:getCanvas(id) -> nil`: Alias for getCanvasKey.
- `LSvgImage:getCanvasKey(id) -> nil`: Returns the LCanvas handle for a previously cached element/group.
- `LSvgImage:getDimensions() -> nil`: Returns both the document width and height as two values: `width, height`.
- `LSvgImage:getElementBounds(id) -> nil`: Returns the axis-aligned bounding box `{min_x, min_y, max_x, max_y}` of the element.
- `LSvgImage:getElementChildren(id) -> nil`: Returns a sequential table of direct child element IDs for the given group element.
- `LSvgImage:getElementColor(id) -> nil`: Returns the current RGBA color override `{r, g, b, a}` table for the element.
- `LSvgImage:getElementCount() -> nil`: Returns the total number of parsed elements (paths and groups) in this SVG document.
- `LSvgImage:getElementIds() -> nil`: Returns a list of all parsed element and group IDs.
- `LSvgImage:getElementParent(id) -> nil`: Returns the parent element ID string, or `nil` when the element is the root or not found.
- `LSvgImage:getElementPoints(id, step_size?) -> nil`: Flattens the element path into a polygon array of LVec2 userdata.
- `LSvgImage:getElementTransform(id) -> nil`: Returns the current dynamic TRS state of the element as a table `{tx, ty, rotation, sx, sy}`.
- `LSvgImage:getElementVisible(id) -> nil`: Returns the current visibility flag for the element.
- `LSvgImage:getHeight() -> nil`: Returns the document height in points/pixels.
- `LSvgImage:getWidth() -> nil`: Returns the document width in points/pixels.
- `LSvgImage:resetElementColor(id) -> nil`: Clears the color override on the element, restoring original SVG path colors.
- `LSvgImage:resetElementTransform(id) -> nil`: Resets the runtime translation, rotation, and scale of the element to identity.
- `LSvgImage:setElementColor(id, r, g, b, a) -> nil`: Overrides the fill/stroke color of a specific element/group by ID.
- `LSvgImage:setElementTransform(id, tx, ty, rotation, sx, sy) -> nil`: Dynamically transforms a specific element/group by ID.
- `LSvgImage:setElementVisible(id, visible) -> nil`: Toggles the visibility of a specific element/group by ID.
- `LSvgImage:type() -> nil`: Lua-visible method.
- `LSvgImage:typeOf(name) -> nil`: Lua-visible method.
