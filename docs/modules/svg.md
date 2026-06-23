# Svg

## Purpose

Provides dynamic SVG parsing, hit-testing, state read-back, hierarchy navigation, and GPU-cached rendering.

## When To Use

- It keeps SVG parsing, scene representation, and runtime conversion behavior together so SVG assets can live inside the normal content flow instead of being forced into a separate external pipeline.
- This is useful for UI artwork that should survive scaling without raster duplication.
- Read it as the point where scalable art becomes usable in the rest of the engine while staying distinct from raster-first asset workflows.

## Minimal Example

Example block: `lurek.svg.load`

```lua
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    local width, height = svg:getDimensions()
    local count = svg:getElementCount()
    local ids = svg:getElementIds()
    svg_log("loaded map svg type=" .. svg:type() .. " size=" .. width .. "x" .. height .. " elements=" .. count .. " first=" .. tostring(ids[1]))
end
```

## Common Patterns

- Start with `lurek.svg.load` when exploring this module.

## API Reference

- This page is the generated API reference for this module.

## Summary

- The `svg` module is the engine surface for scalable SVG artwork, aimed at users who want SVG-style content to stay editable and resolution-independent for as long as possible.
- It keeps SVG parsing, scene representation, and runtime conversion behavior together so SVG assets can live inside the normal content flow instead of being forced into a separate external pipeline.
- This is useful for UI artwork that should survive scaling without raster duplication.
- Read it as the point where scalable art becomes usable in the rest of the engine while staying distinct from raster-first asset workflows.

This module primarily collaborates with `math`, `render`, `runtime`. Its responsibility should stay inside the `Edge/Integration` group rather than absorb behavior owned by those neighbors.

## Functions

### `lurek.svg.load`

Load and parse an SVG file from the game directory.

```lua
lurek.svg.load(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Relative path to an SVG file. |

**Example**

```lua
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    local width, height = svg:getDimensions()
    local count = svg:getElementCount()
    local ids = svg:getElementIds()
    svg_log("loaded map svg type=" .. svg:type() .. " size=" .. width .. "x" .. height .. " elements=" .. count .. " first=" .. tostring(ids[1]))
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LSvgImage](#lsvgimage)

## LSvgImage

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSvgImage:cacheToCanvas`

Rasterizes a specific SVG element/group onto an off-screen GPU Canvas.

```lua
LSvgImage:cacheToCanvas(id, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Element or group ID. |
| `w` | number | Target canvas width in pixels. |
| `h` | number | Target canvas height in pixels. |

**Example**

```lua
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    svg:cacheToCanvas("group1", 100, 100)
    local key = svg:getCanvasKey("group1")
    local canvas = svg:getCanvas("group1")
    svg_log("cacheToCanvas key_ready=" .. tostring(key ~= nil) .. " canvas_ready=" .. tostring(canvas ~= nil))
end
```

---

#### `LSvgImage:draw`

Renders the SVG document at the given position and transform overrides.

```lua
LSvgImage:draw(x, y, rotation, sx, sy, ox, oy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | World X position. |
| `y` | number | World Y position. |
| `rotation?` | number | Rotation in radians. Defaults to 0. |
| `sx?` | number | Scale on X axis. Defaults to 1. |
| `sy?` | number | Scale on Y axis. Defaults to `sx`. |
| `ox?` | number | Origin X offset. Defaults to 0. |
| `oy?` | number | Origin Y offset. Defaults to 0. |

**Example**

```lua
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    svg:setElementVisible("prov_2", false)
    svg:setElementColor("prov_1", 1.0, 0.3, 0.3, 1.0)
    svg:draw(24, 32, 0.0, 1.0, 1.0, 0, 0)
    svg_log("draw issued for highlighted prov_1 with prov_2 hidden")
end
```

---

#### `LSvgImage:getAdjacencies`

Detects neighboring provinces using point-to-point proximity.

```lua
LSvgImage:getAdjacencies(prefix, epsilon)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `prefix` | string | ID prefix used to filter candidate elements. |
| `epsilon?` | number | Distance tolerance for adjacency detection. |

**Returns**

| Type | Description |
|------|-------------|
| table | Map table: element ID -> sequential neighbor ID list. |

**Example**

```lua
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    local adjacency = svg:getAdjacencies("prov_", 5.0)
    local p1 = adjacency["prov_1"] or {}
    local p2 = adjacency["prov_2"] or {}
    svg_log("adjacency prov_1=" .. table.concat(p1, ",") .. " prov_2=" .. table.concat(p2, ","))
end
```

---

#### `LSvgImage:getCanvas`

Returns the cached canvas handle for an element.

```lua
LSvgImage:getCanvas(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Element or group ID. |

**Returns**

| Type | Description |
|------|-------------|
| [LCanvas](render.md#lcanvas) | Cached canvas handle, or `nil` if not cached. |

**Example**

```lua
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    svg:cacheToCanvas("group1", 100, 100)
    local canvas = svg:getCanvas("group1")
    local key = svg:getCanvasKey("group1")
    svg_log("getCanvas canvas_ready=" .. tostring(canvas ~= nil) .. " key_ready=" .. tostring(key ~= nil))
end
```

---

#### `LSvgImage:getCanvasKey`

Returns the [LCanvas](render.md#lcanvas) handle for a previously cached element/group.

```lua
LSvgImage:getCanvasKey(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Element or group ID. |

**Returns**

| Type | Description |
|------|-------------|
| [LCanvas](render.md#lcanvas) | Cached canvas handle, or `nil` if not cached. |

**Example**

```lua
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    svg:cacheToCanvas("group1", 100, 100)
    local key = svg:getCanvasKey("group1")
    local alias = svg:getCanvas("group1")
    svg_log("getCanvasKey has_key=" .. tostring(key ~= nil) .. " alias_ready=" .. tostring(alias ~= nil))
end
```

---

#### `LSvgImage:getDimensions`

Returns both the document width and height as two values: `width, height`.

```lua
LSvgImage:getDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width and height values. (value 1). |
| number | Width and height values. (value 2). |

**Example**

```lua
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    local width, height = svg:getDimensions()
    local count = svg:getElementCount()
    local ids = svg:getElementIds()
    svg_log("svg dimensions=" .. width .. "x" .. height .. " ids=" .. #ids .. " elements=" .. count)
end
```

---

#### `LSvgImage:getElementBounds`

Returns the axis-aligned bounding box `{min_x, min_y, max_x, max_y}` of the element.

```lua
LSvgImage:getElementBounds(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Element or group ID. |

**Returns**

| Type | Description |
|------|-------------|
| table | Bounds table with keys `min_x`, `min_y`, `max_x`, `max_y`, or `nil`. |

**Example**

```lua
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    local bounds = svg:getElementBounds("prov_1")
    local width = bounds.max_x - bounds.min_x
    local height = bounds.max_y - bounds.min_y
    svg_log("prov_1 bounds min=" .. bounds.min_x .. "," .. bounds.min_y .. " size=" .. width .. "x" .. height)
end
```

---

#### `LSvgImage:getElementChildren`

Returns a sequential table of direct child element IDs for the given group element.

```lua
LSvgImage:getElementChildren(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Element or group ID. |

**Returns**

| Type | Description |
|------|-------------|
| table | Sequential table of child IDs, or `nil`. |

**Example**

```lua
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    local children = svg:getElementChildren("group1")
    local first = children[1] or "none"
    local count = #children
    svg_log("group1 children=" .. count .. " first=" .. tostring(first))
end
```

---

#### `LSvgImage:getElementColor`

Returns the current RGBA color override `{r, g, b, a}` table for the element.

```lua
LSvgImage:getElementColor(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Element or group ID. |

**Returns**

| Type | Description |
|------|-------------|
| table | RGBA array table, or `nil`. |

**Example**

```lua
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    local before = svg:getElementColor("prov_1")
    svg:setElementColor("prov_1", 0.5, 0.25, 0.0, 1.0)
    local after = svg:getElementColor("prov_1")
    svg_log("getElementColor before=" .. color_text(before) .. " after=" .. color_text(after))
end
```

---

#### `LSvgImage:getElementCount`

Returns the total number of parsed elements (paths and groups) in this SVG document.

```lua
LSvgImage:getElementCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Total parsed element count. |

**Example**

```lua
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    local count = svg:getElementCount()
    local ids = svg:getElementIds()
    local width, height = svg:getDimensions()
    svg_log("element count=" .. count .. " ids_listed=" .. #ids .. " size=" .. width .. "x" .. height)
end
```

---

#### `LSvgImage:getElementIds`

Returns a list of all parsed element and group IDs.

```lua
LSvgImage:getElementIds()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Sequential table of element ID strings. |

**Example**

```lua
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    local ids = svg:getElementIds()
    table.sort(ids)
    local joined = table.concat(ids, ", ")
    svg_log("element ids=" .. joined)
end
```

---

#### `LSvgImage:getElementParent`

Returns the parent element ID string, or `nil` when the element is the root or not found.

```lua
LSvgImage:getElementParent(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Element or group ID. |

**Returns**

| Type | Description |
|------|-------------|
| string | Parent ID, or `nil`. |

**Example**

```lua
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    local parent = svg:getElementParent("prov_1")
    local siblings = parent and svg:getElementChildren(parent) or {}
    local count = siblings and #siblings or 0
    svg_log("prov_1 parent=" .. tostring(parent) .. " sibling_count=" .. count)
end
```

---

#### `LSvgImage:getElementPoints`

Flattens the element path into a polygon array of [LVec2](math.md#lvec2) userdata.

```lua
LSvgImage:getElementPoints(id, step_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Element or group ID. |
| `step_size?` | number | Optional curve sampling step. Lower values increase point density. |

**Returns**

| Type | Description |
|------|-------------|
| table | Sequential table of `[LVec2](math.md#lvec2)` points, or `nil`. |

**Example**

```lua
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    local points = svg:getElementPoints("prov_1", 10.0)
    local first = points[1]
    local last = points[#points]
    svg_log("prov_1 points=" .. #points .. " first=" .. first.x .. "," .. first.y .. " last=" .. last.x .. "," .. last.y)
end
```

---

#### `LSvgImage:getElementTransform`

Returns the current dynamic TRS state of the element as a table `{tx, ty, rotation, sx, sy}`.

```lua
LSvgImage:getElementTransform(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Element or group ID. |

**Returns**

| Type | Description |
|------|-------------|
| table | Transform table `{tx, ty, rotation, sx, sy}`, or `nil`. |

**Example**

```lua
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    local initial = svg:getElementTransform("prov_1")
    svg:setElementTransform("prov_1", 10, 20, 0.5, 2.0, 3.0)
    local updated = svg:getElementTransform("prov_1")
    svg_log("getElementTransform initial=" .. transform_text(initial) .. " updated=" .. transform_text(updated))
end
```

---

#### `LSvgImage:getElementVisible`

Returns the current visibility flag for the element.

```lua
LSvgImage:getElementVisible(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Element or group ID. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | Visibility flag, or `nil` when ID is unknown. |

**Example**

```lua
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    local before = svg:getElementVisible("prov_1")
    svg:setElementVisible("prov_1", false)
    local after = svg:getElementVisible("prov_1")
    svg_log("getElementVisible before=" .. tostring(before) .. " after_hide=" .. tostring(after))
end
```

---

#### `LSvgImage:getHeight`

Returns the document height in points/pixels.

```lua
LSvgImage:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | SVG viewport height. |

**Example**

```lua
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    local height = svg:getHeight()
    local width = svg:getWidth()
    local aspect = width / height
    svg_log("svg height=" .. height .. " width=" .. width .. " aspect=" .. aspect)
end
```

---

#### `LSvgImage:getWidth`

Returns the document width in points/pixels.

```lua
LSvgImage:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | SVG viewport width. |

**Example**

```lua
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    local width = svg:getWidth()
    local height = svg:getHeight()
    local aspect = width / height
    svg_log("svg width=" .. width .. " height=" .. height .. " aspect=" .. aspect)
end
```

---

#### `LSvgImage:resetElementColor`

Clears the color override on the element, restoring original SVG path colors.

```lua
LSvgImage:resetElementColor(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Element or group ID. |

**Example**

```lua
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    svg:setElementColor("prov_1", 1.0, 0.1, 0.1, 1.0)
    local before = svg:getElementColor("prov_1")
    svg:resetElementColor("prov_1")
    svg_log("resetElementColor before=" .. color_text(before) .. " after=" .. color_text(svg:getElementColor("prov_1")))
end
```

---

#### `LSvgImage:resetElementTransform`

Resets the runtime translation, rotation, and scale of the element to identity.

```lua
LSvgImage:resetElementTransform(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Element or group ID. |

**Example**

```lua
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    svg:setElementTransform("prov_1", 100, 200, 1.0, 3.0, 3.0)
    local before = svg:getElementTransform("prov_1")
    svg:resetElementTransform("prov_1")
    svg_log("resetElementTransform before=" .. transform_text(before) .. " after=" .. transform_text(svg:getElementTransform("prov_1")))
end
```

---

#### `LSvgImage:setElementColor`

Overrides the fill/stroke color of a specific element/group by ID.

```lua
LSvgImage:setElementColor(id, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Element or group ID. |
| `r` | number | Red channel in range 0..1. |
| `g` | number | Green channel in range 0..1. |
| `b` | number | Blue channel in range 0..1. |
| `a` | number | Alpha channel in range 0..1. |

**Example**

```lua
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    svg:setElementColor("prov_1", 1.0, 0.0, 0.0, 1.0)
    local color = svg:getElementColor("prov_1")
    local visible = svg:getElementVisible("prov_1")
    svg_log("setElementColor prov_1=" .. color_text(color) .. " visible=" .. tostring(visible))
end
```

---

#### `LSvgImage:setElementTransform`

Dynamically transforms a specific element/group by ID.

```lua
LSvgImage:setElementTransform(id, tx, ty, rotation, sx, sy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Element or group ID. |
| `tx` | number | Translation on X axis. |
| `ty` | number | Translation on Y axis. |
| `rotation` | number | Rotation in radians. |
| `sx` | number | Scale on X axis. |
| `sy` | number | Scale on Y axis. |

**Example**

```lua
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    svg:setElementTransform("prov_1", 5, 10, 0.2, 1.5, 1.5)
    local transform = svg:getElementTransform("prov_1")
    local bounds = svg:getElementBounds("prov_1")
    svg_log("setElementTransform prov_1=" .. transform_text(transform) .. " bounds_min=" .. bounds.min_x .. "," .. bounds.min_y)
end
```

---

#### `LSvgImage:setElementVisible`

Toggles the visibility of a specific element/group by ID.

```lua
LSvgImage:setElementVisible(id, visible)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Element or group ID. |
| `visible` | boolean | New visibility state. |

**Example**

```lua
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    svg:setElementVisible("prov_1", false)
    local hidden = svg:getElementVisible("prov_1")
    svg:setElementVisible("prov_1", true)
    svg_log("setElementVisible hidden=" .. tostring(hidden) .. " restored=" .. tostring(svg:getElementVisible("prov_1")))
end
```

---

#### `LSvgImage:type`

Returns the fixed type name for this userdata.

```lua
LSvgImage:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The literal `"[LSvgImage](#lsvgimage)"`. |

**Example**

```lua
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    local kind = svg:type()
    local width, height = svg:getDimensions()
    local count = svg:getElementCount()
    svg_log("type kind=" .. kind .. " size=" .. width .. "x" .. height .. " elements=" .. count)
end
```

---

#### `LSvgImage:typeOf`

Check whether this object matches a given type name.

```lua
LSvgImage:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when `name` is `"[LSvgImage](#lsvgimage)"` or `"LObject"`. |

**Example**

```lua
do
    local function svg_log(message)
        lurek.log.info("[svg] " .. message)
    end
    local function load_example_svg()
        return lurek.svg.load("content/examples/assets/test.svg")
    end
    local function color_text(color)
        if not color then
            return "nil"
        end
        return table.concat({
            tostring(color[1]),
            tostring(color[2]),
            tostring(color[3]),
            tostring(color[4]),
        }, ",")
    end
    local function transform_text(transform)
        if not transform then
            return "nil"
        end
        return table.concat({
            tostring(transform[1]),
            tostring(transform[2]),
            tostring(transform[3]),
            tostring(transform[4]),
            tostring(transform[5]),
        }, ",")
    end

    local svg = load_example_svg()
    local is_svg = svg:typeOf("LSvgImage")
    local is_object = svg:typeOf("LObject")
    local ids = svg:getElementIds()
    svg_log("typeOf svg=" .. tostring(is_svg) .. " object=" .. tostring(is_object) .. " ids=" .. #ids)
end
```

---
