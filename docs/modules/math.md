# Math

## Purpose

Provides vectors, matrices, spatial indexes (AABB tree and spatial hash), and polygon geometry.

## When To Use

- Its primary role is standardization. When rendering, physics, pathfinding, camera logic, UI layout, procedural generation, and gameplay helpers all rely on the same vector, matrix, angle, and shape vocabulary, the rest of the engine can cooperate without hidden conversions or drifting assumptions.
- Core vector and matrix types provide the base language for position, direction, orientation, scale, projection, and composition. They are the primitives that let modules talk about where something is, how it is rotated, how it moves, and how one space maps into another.
- Geometry helpers extend the module beyond raw numbers into practical spatial entities such as rectangles, circles, polygons, bounds, overlap tests, distance checks, clipping helpers, and containment queries used across collision, UI, culling, and selection.

## Minimal Example

Example block: `lurek.math.pi`

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("pi = " .. lurek.math.pi)
    example_print_log("pi * 2 = " .. lurek.math.pi * 2)
    example_print_log("half turn = " .. lurek.math.pi)
    local quarter_turn = lurek.math.pi / 2
    example_print_log("quarter turn = " .. quarter_turn)
end
```

## Common Patterns

- Start with `lurek.math.Vec2` when exploring this module.
- Start with `lurek.math.Vec3` when exploring this module.
- Start with `lurek.math.aabbTree` when exploring this module.
- Start with `lurek.math.abs` when exploring this module.
- Start with `lurek.math.acos` when exploring this module.

## API Reference

- This page is the generated API reference for this module.

## Summary

- The `math` module is the engine's shared numerical and geometric foundation for users who need consistent rules for coordinates, shapes, transforms, interpolation, sampling, and spatial reasoning across many feature areas.
- Its primary role is standardization. When rendering, physics, pathfinding, camera logic, UI layout, procedural generation, and gameplay helpers all rely on the same vector, matrix, angle, and shape vocabulary, the rest of the engine can cooperate without hidden conversions or drifting assumptions.
- Core vector and matrix types provide the base language for position, direction, orientation, scale, projection, and composition. They are the primitives that let modules talk about where something is, how it is rotated, how it moves, and how one space maps into another.
- Geometry helpers extend the module beyond raw numbers into practical spatial entities such as rectangles, circles, polygons, bounds, overlap tests, distance checks, clipping helpers, and containment queries used across collision, UI, culling, and selection.
- Transform logic is another major category. Translation, rotation, scale, matrix composition, inversion, and coordinate-space conversion allow scripts and subsystems to move between local, world, map, and screen representations without ambiguous manual math.
- Curve, easing, interpolation, and value-shaping helpers matter because motion paths, camera rails, UI transitions, scripted effects, and numeric blending all depend on shared progression rules rather than bespoke formulas.
- Spatial indexing and applied algorithms broaden the module from calculation into organization, giving larger systems reusable structures and geometric building blocks for broad phases, region construction, and procedural workflows.
- That common layer is important because spatial bugs usually come from disagreement, not from missing arithmetic. If one system treats a rectangle as inclusive, another applies a different rotation convention, and a third projects coordinates with a slightly different transform order, the engine becomes hard to trust even when each local feature appears reasonable in isolation.
- The module therefore acts as an agreement surface as much as a utility library. It gives neighboring systems one place to inherit conventions for handedness, angle normalization, interpolation behavior, projection rules, and coordinate conversion semantics.
- For rendering-oriented code this means predictable transforms and projection helpers. For physics-adjacent code it means stable distances and shape math. For UI and tooling code it means reliable hit testing and viewport conversion.
- Curve support broadens the module from rigid geometry into authored motion and data shaping. Bézier curves, splines, and similar helpers give camera paths, animation support systems, road generation, region shaping, and tool previews a common language for smooth trajectories and contours.
- Broad-phase and indexing helpers give the module a structural role too. Large feature sets often need partitioning, bucketing, or neighborhood lookup before they can do more expensive per-object reasoning, and those patterns are easier to keep correct when they reuse engine-level math primitives and bounds semantics.
- Determinism is another reason the module matters. Tests, replays, serialized tools, and visual evidence workflows depend on math behavior that is reproducible enough to compare, inspect, and trust across runs.
- Sampling and value-shaping helpers belong here for the same reason: even small operations such as remapping, clamping, wrapping, and parameter evaluation become more reliable when they reuse one engine-wide numeric vocabulary.
- World generation and simulation tools also lean on this layer because geometric construction rarely stays confined to one subsystem. Voronoi-like helpers, region assembly, contour processing, and transform composition often need to interoperate with render views, province maps, physics queries, or camera framing.
- The module therefore acts as a substrate for both high-level and low-level work, and it gives tools and tests a deterministic numerical layer they can trust.
- Read `math` as the place where the engine standardizes numeric and geometric reasoning across the rest of the project for code, tools, and tests alike.

This module primarily collaborates with `globe`, `image`. Its responsibility should stay inside the Foundations group rather than absorb behavior owned by those neighbors.

## Functions

### `lurek.math.Vec2`

Creates a 2D vector. This function is exposed to Lua scripts.

```lua
lurek.math.Vec2(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X component. |
| `y` | number | Y component. |

**Returns**

| Type | Description |
|------|-------------|
| [LVec2](#lvec2) | New vector handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.Vec2(3, 4)
    example_print_log("vec2 = " .. v.x .. "," .. v.y)
    example_print_log("heading = " .. v:angle())
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalized().x)
end
```

---

### `lurek.math.Vec3`

Creates a 3D vector. This function is exposed to Lua scripts.

```lua
lurek.math.Vec3(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X component. |
| `y` | number | Y component. |
| `z` | number | Z component. |

**Returns**

| Type | Description |
|------|-------------|
| [LVec3](#lvec3) | New vector handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.Vec3(1, 2, 3)
    example_print_log("vec3 = " .. v.x .. "," .. v.y .. "," .. v.z)
    example_print_log("lengthSquared = " .. v:lengthSquared())
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalize().x)
end
```

---

### `lurek.math.aabbTree`

Creates an empty AABB tree. This function is exposed to Lua scripts.

```lua
lurek.math.aabbTree()
```

**Returns**

| Type | Description |
|------|-------------|
| [LAabbTree](#laabbtree) | New AABB tree handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 10, 10)
    tree:insert(2, 5, 5, 15, 15)
    example_print_log("len = " .. tree:len())
    example_print_log("empty = " .. tostring(tree:isEmpty()))
end
```

---

### `lurek.math.abs`

Returns absolute value. This function is exposed to Lua scripts.

```lua
lurek.math.abs(x)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Absolute value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("abs(-5) = " .. lurek.math.abs(-5))
    example_print_log("abs(3) = " .. lurek.math.abs(3))
    example_print_log("abs(-12) keeps motion positive = " .. lurek.math.abs(-12))
    local knockback = lurek.math.abs(-12)
    example_print_log("knockback magnitude = " .. knockback)
end
```

---

### `lurek.math.acos`

Returns arccosine of a value. This function is exposed to Lua scripts.

```lua
lurek.math.acos(x)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Angle in radians. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("acos(1) = " .. lurek.math.acos(1))
    example_print_log("acos(0) = " .. lurek.math.acos(0))
    example_print_log("acos(0.5) = " .. lurek.math.acos(0.5))
    local cone_edge = lurek.math.acos(0.5)
    example_print_log("vision cone edge = " .. cone_edge)
end
```

---

### `lurek.math.angleBetween`

Returns the angle between two points.

```lua
lurek.math.angleBetween(x1, y1, x2, y2)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | number | First point x coordinate. |
| `y1` | number | First point y coordinate. |
| `x2` | number | Second point x coordinate. |
| `y2` | number | Second point y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Angle between points. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = lurek.math.angleBetween(0, 0, 1, 0)
    example_print_log("angle to right = " .. a)
    local b = lurek.math.angleBetween(0, 0, 0, 1)
    example_print_log("angle down = " .. b)
    local turn_delta = b - a
end
```

---

### `lurek.math.applyEasing`

Applies a named easing function to a normalized value.

```lua
lurek.math.applyEasing(name, t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Easing function name. |
| `t` | number | Normalized input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Eased value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local linear = lurek.math.applyEasing("linear", 0.5)
    local eased = lurek.math.applyEasing("inOutCubic", 0.5)
    example_print_log("linear = " .. linear)
    example_print_log("inOutCubic = " .. eased)
    local finish = lurek.math.applyEasing("inOutCubic", 1.0)
end
```

---

### `lurek.math.asin`

Returns arcsine of a value. This function is exposed to Lua scripts.

```lua
lurek.math.asin(x)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Angle in radians. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("asin(1) = " .. lurek.math.asin(1))
    example_print_log("asin(0) = " .. lurek.math.asin(0))
    example_print_log("asin(0.5) = " .. lurek.math.asin(0.5))
    local half_arc = lurek.math.asin(0.5)
    example_print_log("half arc = " .. half_arc)
end
```

---

### `lurek.math.atan`

Returns arctangent or two-argument arctangent.

```lua
lurek.math.atan(y, x)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `y` | number | Input value or y coordinate. |
| `x?` | number | X coordinate for atan2 behavior. |

**Returns**

| Type | Description |
|------|-------------|
| number | Angle in radians. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("atan(1) = " .. lurek.math.atan(1))
    example_print_log("atan(1, 1) = " .. lurek.math.atan(1, 1))
    example_print_log("atan(0.25) = " .. lurek.math.atan(0.25))
    local aim_pitch = lurek.math.atan(0.5)
    example_print_log("aim pitch = " .. aim_pitch)
end
```

---

### `lurek.math.atan2`

Returns two-argument arctangent.

```lua
lurek.math.atan2(y, x)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `y` | number | Y coordinate. |
| `x` | number | X coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Angle in radians. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("atan2(1, 0) = " .. lurek.math.atan2(1, 0))
    example_print_log("atan2(0, 1) = " .. lurek.math.atan2(0, 1))
    example_print_log("heading to top-right = " .. lurek.math.atan2(-1, 1))
    local diagonal_heading = lurek.math.atan2(10, 10)
    example_print_log("diagonal heading = " .. diagonal_heading)
end
```

---

### `lurek.math.bresenham`

Returns integer grid points along a Bresenham line.

```lua
lurek.math.bresenham(x1, y1, x2, y2)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | number | Start x coordinate. |
| `y1` | number | Start y coordinate. |
| `x2` | number | End x coordinate. |
| `y2` | number | End y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| LMathBresenhamResult | Array table of `{x, y}` point tables. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pts = lurek.math.bresenham(0, 0, 5, 3)
    example_print_log("bresenham points = " .. #pts)
    for _, p in ipairs(pts) do
        example_print_log("  " .. p.x .. "," .. p.y)
    end
end
```

---

### `lurek.math.catmullRom`

Creates a Catmull-Rom spline from point tables.

```lua
lurek.math.catmullRom(points)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `points` | table | Array table of points with `x`/`y` fields or numeric indices. |

**Returns**

| Type | Description |
|------|-------------|
| [LCatmullRom](#lcatmullrom) | New spline handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local spline = lurek.math.catmullRom({{x = 0, y = 0}, {x = 50, y = 80}, {x = 100, y = 20}, {x = 150, y = 60}})
    example_print_log("points = " .. spline:len())
    local x, y = spline:sample(0.5)
    example_print_log("mid = " .. x .. "," .. y)
    example_print_log("spline points = " .. spline:len())
end
```

---

### `lurek.math.ceil`

Returns ceiling of a value. This function is exposed to Lua scripts.

```lua
lurek.math.ceil(x)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Ceiling value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("ceil(2.3) = " .. lurek.math.ceil(2.3))
    example_print_log("ceil(-1.7) = " .. lurek.math.ceil(-1.7))
    example_print_log("ceil keeps partial row = " .. lurek.math.ceil(2.01))
    local rows = lurek.math.ceil(13 / 5)
    example_print_log("rows for 13 items in 5 columns = " .. rows)
end
```

---

### `lurek.math.circleContainsPoint`

Returns whether a circle contains a point.

```lua
lurek.math.circleContainsPoint(cx, cy, r, px, py)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | number | Circle center x coordinate. |
| `cy` | number | Circle center y coordinate. |
| `r` | number | Circle radius. |
| `px` | number | Point x coordinate. |
| `py` | number | Point y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the point is inside the circle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local inside = lurek.math.circleContainsPoint(5, 5, 10, 6, 6)
    example_print_log("inside = " .. tostring(inside))
    example_print_log("outside = " .. tostring(lurek.math.circleContainsPoint(5, 5, 10, 20, 20)))
    local border = lurek.math.circleContainsPoint(5, 5, 10, 15, 5)
    example_print_log("border point = " .. tostring(border))
end
```

---

### `lurek.math.circleIntersectsCircle`

Returns whether two circles intersect.

```lua
lurek.math.circleIntersectsCircle(x1, y1, r1, x2, y2, r2)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | number | First circle center x coordinate. |
| `y1` | number | First circle center y coordinate. |
| `r1` | number | First circle radius. |
| `x2` | number | Second circle center x coordinate. |
| `y2` | number | Second circle center y coordinate. |
| `r2` | number | Second circle radius. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the circles intersect. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local hit = lurek.math.circleIntersectsCircle(0, 0, 5, 8, 0, 5)
    example_print_log("circles overlap = " .. tostring(hit))
    example_print_log("touching circles overlap = " .. tostring(lurek.math.circleIntersectsCircle(0, 0, 5, 10, 0, 5)))
    local separated_overlap = lurek.math.circleIntersectsCircle(0, 0, 5, 20, 0, 5)
    example_print_log("separated overlap = " .. tostring(separated_overlap))
end
```

---

### `lurek.math.circleIntersectsLine`

Returns circle-line intersection state and hit points when present.

```lua
lurek.math.circleIntersectsLine(cx, cy, r, lx1, ly1, lx2, ly2)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | number | Circle center x coordinate. |
| `cy` | number | Circle center y coordinate. |
| `r` | number | Circle radius. |
| `lx1` | number | Line start x coordinate. |
| `ly1` | number | Line start y coordinate. |
| `lx2` | number | Line end x coordinate. |
| `ly2` | number | Line end y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the line intersects the circle. |
| number | First hit x coordinate; or nil. |
| number | First hit y coordinate; or nil. |
| number | Second hit x coordinate; or nil. |
| number | Second hit y coordinate; or nil. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local hit, hx1, hy1, hx2, hy2 = lurek.math.circleIntersectsLine(5, 5, 3, 0, 5, 10, 5)
    example_print_log("circle/line hit = " .. tostring(hit))
    if hx1 then example_print_log("  hit1 = " .. hx1 .. "," .. hy1) end
    if hx2 then example_print_log("  hit2 = " .. hx2 .. "," .. hy2) end
    local two_hits = hx2 ~= nil and hy2 ~= nil
end
```

---

### `lurek.math.circleIntersectsSegment`

Returns circle-segment intersection state and hit points when present.

```lua
lurek.math.circleIntersectsSegment(cx, cy, r, sx1, sy1, sx2, sy2)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | number | Circle center x coordinate. |
| `cy` | number | Circle center y coordinate. |
| `r` | number | Circle radius. |
| `sx1` | number | Segment start x coordinate. |
| `sy1` | number | Segment start y coordinate. |
| `sx2` | number | Segment end x coordinate. |
| `sy2` | number | Segment end y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the segment intersects the circle. |
| number | First hit x coordinate; or nil. |
| number | First hit y coordinate; or nil. |
| number | Second hit x coordinate; or nil. |
| number | Second hit y coordinate; or nil. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local hit, hx1, hy1, hx2, hy2 = lurek.math.circleIntersectsSegment(5, 5, 3, 0, 5, 10, 5)
    example_print_log("circle/seg hit = " .. tostring(hit))
    if hx1 then example_print_log("  seg hit1 = " .. hx1 .. "," .. hy1) end
    _ = hx2
    _ = hy2
end
```

---

### `lurek.math.clamp`

Clamps a value to a range. This function is exposed to Lua scripts.

```lua
lurek.math.clamp(v, min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Input value. |
| `min` | number | Minimum value. |
| `max` | number | Maximum value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Clamped value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("clamp(15, 0, 10) = " .. lurek.math.clamp(15, 0, 10))
    example_print_log("clamp(-3, 0, 10) = " .. lurek.math.clamp(-3, 0, 10))
    example_print_log("clamp(5, 0, 10) = " .. lurek.math.clamp(5, 0, 10))
    local health = lurek.math.clamp(118, 0, 100)
    example_print_log("health cap = " .. health)
end
```

---

### `lurek.math.closestPointOnSegment`

Returns the closest point on a segment to an input point.

```lua
lurek.math.closestPointOnSegment(px, py, x1, y1, x2, y2)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `px` | number | Point x coordinate. |
| `py` | number | Point y coordinate. |
| `x1` | number | Segment start x coordinate. |
| `y1` | number | Segment start y coordinate. |
| `x2` | number | Segment end x coordinate. |
| `y2` | number | Segment end y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Closest point x coordinate. |
| number | Closest point y coordinate. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local cx, cy = lurek.math.closestPointOnSegment(5, 5, 0, 0, 10, 0)
    example_print_log("closest on segment = " .. cx .. "," .. cy)
    example_print_log("value types = " .. type(cx) .. "," .. type(cy))
    local snap_distance = lurek.math.distance(5, 5, cx, cy)
    example_print_log("snap distance = " .. snap_distance)
end
```

---

### `lurek.math.convexHull`

Computes the convex hull for a flat point table.

```lua
lurek.math.convexHull(pts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pts` | table | Flat numeric point table. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Flat numeric hull point table (x1,y1,x2,y2,...). |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pts = {0, 0, 5, 5, 10, 0, 3, 2, 7, 2, 5, 10}
    local hull = lurek.math.convexHull(pts)
    example_print_log("hull vertices = " .. #hull / 2)
    local input_points = #pts / 2
    example_print_log("input points = " .. input_points)
end
```

---

### `lurek.math.cos`

Returns cosine of an angle. This function is exposed to Lua scripts.

```lua
lurek.math.cos(x)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Angle in radians. |

**Returns**

| Type | Description |
|------|-------------|
| number | Cosine value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("cos(0) = " .. lurek.math.cos(0))
    example_print_log("cos(pi) = " .. lurek.math.cos(lurek.math.pi))
    example_print_log("cos facing up = " .. lurek.math.cos(lurek.math.rad(90)))
    local facing_x = lurek.math.cos(lurek.math.rad(60))
    example_print_log("facing x = " .. facing_x)
end
```

---

### `lurek.math.cubicBezier`

Computes the CSS cubic-bezier Y value at input t (0..1).

```lua
lurek.math.cubicBezier(p1x, p1y, p2x, p2y, t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `p1x` | number | First control point X. | |
| `p1y` | number | First control point Y. | |
| `p2x` | number | Second control point X. | |
| `p2y` | number | Second control point Y. | |
| `t` | number | Input time (0..1). | |

**Returns**

| Type | Description |
|------|-------------|
| number | The eased Y value. | |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local y = lurek.math.cubicBezier(0.25, 0.1, 0.25, 1.0, 0.5)
    example_print_log("cubicBezier(0.5) = " .. y)
    example_print_log("ease sample at 0.2 = " .. lurek.math.cubicBezier(0.42, 0.0, 0.58, 1.0, 0.2))
    local late_curve = lurek.math.cubicBezier(0.42, 0.0, 0.58, 1.0, 0.8)
    example_print_log("ease in-out at 0.8 = " .. late_curve)
end
```

---

### `lurek.math.deg`

Converts radians to degrees. This function is exposed to Lua scripts.

```lua
lurek.math.deg(rad)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `rad` | number | Angle in radians. |

**Returns**

| Type | Description |
|------|-------------|
| number | Angle in degrees. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("deg(pi) = " .. lurek.math.deg(lurek.math.pi))
    example_print_log("deg(pi/2) = " .. lurek.math.deg(lurek.math.pi / 2))
    example_print_log("45deg from rad = " .. lurek.math.deg(lurek.math.rad(45)))
    local ui_angle = lurek.math.deg(lurek.math.pi / 3)
    example_print_log("ui angle = " .. ui_angle)
end
```

---

### `lurek.math.delaunayTriangulate`

Computes Delaunay triangles for a flat point table.

```lua
lurek.math.delaunayTriangulate(pts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pts` | table | Flat numeric point table. |

**Returns**

| Type | Description |
|------|-------------|
| LMathDelaunayTriangulateResult | Array of triangle index tables; each entry is `{i1, i2, i3}` (1-based vertex indices). |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pts = {0, 0, 10, 0, 5, 10, 3, 5, 7, 5}
    local tris = lurek.math.delaunayTriangulate(pts)
    example_print_log("delaunay triangles = " .. #tris)
    local input_vertices = #pts / 2
    example_print_log("input vertices = " .. input_vertices)
end
```

---

### `lurek.math.distance`

Returns Euclidean distance between two points.

```lua
lurek.math.distance(x1, y1, x2, y2)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | number | First point x coordinate. |
| `y1` | number | First point y coordinate. |
| `x2` | number | Second point x coordinate. |
| `y2` | number | Second point y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Distance. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local d = lurek.math.distance(0, 0, 3, 4)
    example_print_log("distance = " .. d)
    example_print_log("distance to 6,8 = " .. lurek.math.distance(0, 0, 6, 8))
    local tiles_apart = d / 5
    example_print_log("5-unit tiles apart = " .. tiles_apart)
end
```

---

### `lurek.math.distanceSq`

Returns squared Euclidean distance between two points.

```lua
lurek.math.distanceSq(x1, y1, x2, y2)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | number | First point x coordinate. |
| `y1` | number | First point y coordinate. |
| `x2` | number | Second point x coordinate. |
| `y2` | number | Second point y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Squared distance. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local d2 = lurek.math.distanceSq(0, 0, 3, 4)
    example_print_log("distanceSq = " .. d2)
    example_print_log("distanceSq to 6,8 = " .. lurek.math.distanceSq(0, 0, 6, 8))
    local exact_distance = lurek.math.sqrt(d2)
    example_print_log("distance from sq = " .. exact_distance)
end
```

---

### `lurek.math.easingNames`

Returns an array of all built-in easing function names.

```lua
lurek.math.easingNames()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | List of easing names. | |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local names = lurek.math.easingNames()
    example_print_log("easing count = " .. #names)
    example_print_log("contains linear = " .. tostring(names[1] ~= nil))
    local first_name = names[1] or "none"
    example_print_log("first easing = " .. first_name)
end
```

---

### `lurek.math.exp`

Returns exponential of a value. This function is exposed to Lua scripts.

```lua
lurek.math.exp(x)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Exponential value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("exp(1) = " .. lurek.math.exp(1))
    example_print_log("exp(0) = " .. lurek.math.exp(0))
    example_print_log("growth step for 2 = " .. lurek.math.exp(2))
    local growth_factor = lurek.math.exp(2)
    example_print_log("growth factor = " .. growth_factor)
end
```

---

### `lurek.math.floor`

Returns floor of a value. This function is exposed to Lua scripts.

```lua
lurek.math.floor(x)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Floored value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("floor(2.9) = " .. lurek.math.floor(2.9))
    example_print_log("floor(-1.1) = " .. lurek.math.floor(-1.1))
    example_print_log("floor drops partial tile = " .. lurek.math.floor(2.99))
    local full_tiles = lurek.math.floor(13 / 5)
    example_print_log("full tiles = " .. full_tiles)
end
```

---

### `lurek.math.fmod`

Returns floating-point remainder.

```lua
lurek.math.fmod(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Dividend. |
| `y` | number | Divisor. |

**Returns**

| Type | Description |
|------|-------------|
| number | Remainder. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("fmod(7, 3) = " .. lurek.math.fmod(7, 3))
    example_print_log("fmod(10.5, 3) = " .. lurek.math.fmod(10.5, 3))
    example_print_log("looped timer = " .. lurek.math.fmod(9.75, 2.0))
    local animation_phase = lurek.math.fmod(13.5, 2.0)
    example_print_log("animation phase = " .. animation_phase)
end
```

---

### `lurek.math.hermite`

Creates a Hermite spline from endpoints and tangents.

```lua
lurek.math.hermite(p0x, p0y, p1x, p1y, m0x, m0y, m1x, m1y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `p0x` | number | Start point x coordinate. |
| `p0y` | number | Start point y coordinate. |
| `p1x` | number | End point x coordinate. |
| `p1y` | number | End point y coordinate. |
| `m0x` | number | Start tangent x component. |
| `m0y` | number | Start tangent y component. |
| `m1x` | number | End tangent x component. |
| `m1y` | number | End tangent y component. |

**Returns**

| Type | Description |
|------|-------------|
| [LHermite](#lhermite) | New Hermite spline handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local spline = lurek.math.hermite(0, 0, 100, 0, 50, 100, 50, -100)
    local x0, y0 = spline:sample(0)
    local xm, ym = spline:sample(0.5)
    local x1, y1 = spline:sample(1)
    example_print_log("start = " .. x0 .. "," .. y0)
    example_print_log("mid = " .. xm .. "," .. ym)
    example_print_log("end = " .. x1 .. "," .. y1)
end
```

---

### `lurek.math.inBack`

Applies back ease-in. This function is exposed to Lua scripts.

```lua
lurek.math.inBack(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | Normalized input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Eased value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.inBack(0.25))
    example_print_log("t=0.75 = " .. lurek.math.inBack(0.75))
    example_print_log("finish = " .. lurek.math.inBack(1.0))
    local ease_start = lurek.math.inBack(0.0)
    example_print_log("start = " .. ease_start)
end
```

---

### `lurek.math.inBounce`

Applies bounce ease-in. This function is exposed to Lua scripts.

```lua
lurek.math.inBounce(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | Normalized input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Eased value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.inBounce(0.25))
    example_print_log("t=0.75 = " .. lurek.math.inBounce(0.75))
    example_print_log("finish = " .. lurek.math.inBounce(1.0))
    local ease_start = lurek.math.inBounce(0.0)
    example_print_log("start = " .. ease_start)
end
```

---

### `lurek.math.inCubic`

Applies cubic ease-in. This function is exposed to Lua scripts.

```lua
lurek.math.inCubic(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | Normalized input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Eased value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.inCubic(0.25))
    example_print_log("t=0.75 = " .. lurek.math.inCubic(0.75))
    example_print_log("finish = " .. lurek.math.inCubic(1.0))
    local ease_start = lurek.math.inCubic(0.0)
    example_print_log("start = " .. ease_start)
end
```

---

### `lurek.math.inElastic`

Applies elastic ease-in. This function is exposed to Lua scripts.

```lua
lurek.math.inElastic(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | Normalized input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Eased value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.inElastic(0.25))
    example_print_log("t=0.75 = " .. lurek.math.inElastic(0.75))
    example_print_log("finish = " .. lurek.math.inElastic(1.0))
    local ease_start = lurek.math.inElastic(0.0)
    example_print_log("start = " .. ease_start)
end
```

---

### `lurek.math.inExpo`

Applies exponential ease-in. This function is exposed to Lua scripts.

```lua
lurek.math.inExpo(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | Normalized input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Eased value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.inExpo(0.25))
    example_print_log("t=0.75 = " .. lurek.math.inExpo(0.75))
    example_print_log("finish = " .. lurek.math.inExpo(1.0))
    local ease_start = lurek.math.inExpo(0.0)
    example_print_log("start = " .. ease_start)
end
```

---

### `lurek.math.inOutBack`

Applies back ease-in-out. This function is exposed to Lua scripts.

```lua
lurek.math.inOutBack(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | Normalized input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Eased value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.inOutBack(0.25))
    example_print_log("t=0.75 = " .. lurek.math.inOutBack(0.75))
    example_print_log("finish = " .. lurek.math.inOutBack(1.0))
    local ease_start = lurek.math.inOutBack(0.0)
    example_print_log("start = " .. ease_start)
end
```

---

### `lurek.math.inOutBounce`

Applies bounce ease-in-out. This function is exposed to Lua scripts.

```lua
lurek.math.inOutBounce(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | Normalized input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Eased value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.inOutBounce(0.25))
    example_print_log("t=0.75 = " .. lurek.math.inOutBounce(0.75))
    example_print_log("finish = " .. lurek.math.inOutBounce(1.0))
    local ease_start = lurek.math.inOutBounce(0.0)
    example_print_log("start = " .. ease_start)
end
```

---

### `lurek.math.inOutCubic`

Applies cubic ease-in-out. This function is exposed to Lua scripts.

```lua
lurek.math.inOutCubic(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | Normalized input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Eased value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.inOutCubic(0.25))
    example_print_log("t=0.75 = " .. lurek.math.inOutCubic(0.75))
    example_print_log("finish = " .. lurek.math.inOutCubic(1.0))
    local ease_start = lurek.math.inOutCubic(0.0)
    example_print_log("start = " .. ease_start)
end
```

---

### `lurek.math.inOutElastic`

Applies elastic ease-in-out. This function is exposed to Lua scripts.

```lua
lurek.math.inOutElastic(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | Normalized input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Eased value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.inOutElastic(0.25))
    example_print_log("t=0.75 = " .. lurek.math.inOutElastic(0.75))
    example_print_log("finish = " .. lurek.math.inOutElastic(1.0))
    local ease_start = lurek.math.inOutElastic(0.0)
    example_print_log("start = " .. ease_start)
end
```

---

### `lurek.math.inOutExpo`

Applies exponential ease-in-out.

```lua
lurek.math.inOutExpo(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | Normalized input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Eased value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.inOutExpo(0.25))
    example_print_log("t=0.75 = " .. lurek.math.inOutExpo(0.75))
    example_print_log("finish = " .. lurek.math.inOutExpo(1.0))
    local ease_start = lurek.math.inOutExpo(0.0)
    example_print_log("start = " .. ease_start)
end
```

---

### `lurek.math.inOutQuad`

Applies quadratic ease-in-out. This function is exposed to Lua scripts.

```lua
lurek.math.inOutQuad(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | Normalized input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Eased value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.inOutQuad(0.25))
    example_print_log("t=0.75 = " .. lurek.math.inOutQuad(0.75))
    example_print_log("finish = " .. lurek.math.inOutQuad(1.0))
    local ease_start = lurek.math.inOutQuad(0.0)
    example_print_log("start = " .. ease_start)
end
```

---

### `lurek.math.inOutQuart`

Applies quartic ease-in-out. This function is exposed to Lua scripts.

```lua
lurek.math.inOutQuart(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | Normalized input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Eased value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.inOutQuart(0.25))
    example_print_log("t=0.75 = " .. lurek.math.inOutQuart(0.75))
    example_print_log("finish = " .. lurek.math.inOutQuart(1.0))
    local ease_start = lurek.math.inOutQuart(0.0)
    example_print_log("start = " .. ease_start)
end
```

---

### `lurek.math.inOutSine`

Applies sine ease-in-out. This function is exposed to Lua scripts.

```lua
lurek.math.inOutSine(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | Normalized input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Eased value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.inOutSine(0.25))
    example_print_log("t=0.75 = " .. lurek.math.inOutSine(0.75))
    example_print_log("finish = " .. lurek.math.inOutSine(1.0))
    local ease_start = lurek.math.inOutSine(0.0)
    example_print_log("start = " .. ease_start)
end
```

---

### `lurek.math.inQuad`

Applies quadratic ease-in. This function is exposed to Lua scripts.

```lua
lurek.math.inQuad(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | Normalized input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Eased value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.inQuad(0.25))
    example_print_log("t=0.75 = " .. lurek.math.inQuad(0.75))
    example_print_log("finish = " .. lurek.math.inQuad(1.0))
    local ease_start = lurek.math.inQuad(0.0)
    example_print_log("start = " .. ease_start)
end
```

---

### `lurek.math.inQuart`

Applies quartic ease-in. This function is exposed to Lua scripts.

```lua
lurek.math.inQuart(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | Normalized input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Eased value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.inQuart(0.25))
    example_print_log("t=0.75 = " .. lurek.math.inQuart(0.75))
    example_print_log("finish = " .. lurek.math.inQuart(1.0))
    local ease_start = lurek.math.inQuart(0.0)
    example_print_log("start = " .. ease_start)
end
```

---

### `lurek.math.inSine`

Applies sine ease-in. This function is exposed to Lua scripts.

```lua
lurek.math.inSine(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | Normalized input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Eased value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.inSine(0.25))
    example_print_log("t=0.75 = " .. lurek.math.inSine(0.75))
    example_print_log("finish = " .. lurek.math.inSine(1.0))
    local ease_start = lurek.math.inSine(0.0)
    example_print_log("start = " .. ease_start)
end
```

---

### `lurek.math.inverseLerp`

Returns the interpolation factor of a value between two bounds.

```lua
lurek.math.inverseLerp(a, b, v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | number | Start value. |
| `b` | number | End value. |
| `v` | number | Input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Interpolation factor. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("inverseLerp(0, 100, 50) = " .. lurek.math.inverseLerp(0, 100, 50))
    example_print_log("inverseLerp(10, 20, 15) = " .. lurek.math.inverseLerp(10, 20, 15))
    example_print_log("progress at 75/100 = " .. lurek.math.inverseLerp(0, 100, 75))
    local charge_fill = lurek.math.inverseLerp(0, 3, 1.5)
    example_print_log("charge fill = " .. charge_fill)
end
```

---

### `lurek.math.isConvex`

Returns whether a flat polygon point table is convex.

```lua
lurek.math.isConvex(pts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pts` | table | Flat numeric table `{x1, y1, x2, y2, ...}`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the polygon is convex. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local square = {0, 0, 10, 0, 10, 10, 0, 10}
    example_print_log("square convex = " .. tostring(lurek.math.isConvex(square)))
    local concave = {0, 0, 5, 3, 10, 0, 10, 10, 0, 10}
    example_print_log("concave = " .. tostring(lurek.math.isConvex(concave)))
    local triangle = {0, 0, 6, 0, 3, 5}
end
```

---

### `lurek.math.lerp`

Linearly interpolates between two values.

```lua
lurek.math.lerp(a, b, t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | number | Start value. |
| `b` | number | End value. |
| `t` | number | Interpolation factor. |

**Returns**

| Type | Description |
|------|-------------|
| number | Interpolated value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("lerp(0, 100, 0.5) = " .. lurek.math.lerp(0, 100, 0.5))
    example_print_log("lerp(10, 20, 0.25) = " .. lurek.math.lerp(10, 20, 0.25))
    example_print_log("enemy moves 75% across = " .. lurek.math.lerp(0, 100, 0.75))
    local ui_fade = lurek.math.lerp(0, 1, 0.3)
    example_print_log("ui fade alpha = " .. ui_fade)
end
```

---

### `lurek.math.lineIntersect`

Returns intersection point for two infinite lines when present.

```lua
lurek.math.lineIntersect(x1, y1, x2, y2, x3, y3, x4, y4)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | number | First line start x coordinate. |
| `y1` | number | First line start y coordinate. |
| `x2` | number | First line end x coordinate. |
| `y2` | number | First line end y coordinate. |
| `x3` | number | Second line start x coordinate. |
| `y3` | number | Second line start y coordinate. |
| `x4` | number | Second line end x coordinate. |
| `y4` | number | Second line end y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Intersection x coordinate; or nil. |
| number | Intersection y coordinate; or nil. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ix, iy = lurek.math.lineIntersect(0, 0, 10, 10, 0, 10, 10, 0)
    if ix then example_print_log("lines cross at " .. ix .. "," .. iy) else example_print_log("lines are parallel") end
    example_print_log("value types = " .. type(ix) .. "," .. type(iy))
    local crossed = ix ~= nil and iy ~= nil
    example_print_log("crossed = " .. tostring(crossed))
end
```

---

### `lurek.math.linear`

Applies linear easing. This function is exposed to Lua scripts.

```lua
lurek.math.linear(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | Normalized input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Eased value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.linear(0.25))
    example_print_log("t=0.75 = " .. lurek.math.linear(0.75))
    example_print_log("finish = " .. lurek.math.linear(1.0))
    local ease_start = lurek.math.linear(0.0)
    example_print_log("start = " .. ease_start)
end
```

---

### `lurek.math.log`

Returns natural logarithm or logarithm with a supplied base.

```lua
lurek.math.log(x, b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Input value. |
| `b?` | number | Logarithm base. |

**Returns**

| Type | Description |
|------|-------------|
| number | Logarithm value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("log(e) = " .. lurek.math.log(lurek.math.exp(1)))
    example_print_log("log(100, 10) = " .. lurek.math.log(100, 10))
    example_print_log("log2(8) = " .. lurek.math.log(8, 2))
    local digits_scale = lurek.math.log(1000, 10)
    example_print_log("digits scale = " .. digits_scale)
end
```

---

### `lurek.math.lootFromList`

Creates a loot table from a Lua list of entry tables.

```lua
lurek.math.lootFromList(entries)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `entries` | table | Array of `{ id=string, weight=number, meta=table? }`. |

**Returns**

| Type | Description |
|------|-------------|
| [LLootTable](#lloottable) | New loot table handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local loot = lurek.math.lootFromList({
        { id = "gold", weight = 20.0, meta = { kind = "currency" } },
        { id = "gem", weight = 2.0, meta = { kind = "currency" } },
    })
    example_print_log("fromList count = " .. loot:entryCount())
end
```

---

### `lurek.math.lootFromToml`

Loads a loot table from a TOML file path.

```lua
lurek.math.lootFromToml(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | TOML file path. |

**Returns**

| Type | Description |
|------|-------------|
| [LLootTable](#lloottable) | New loot table handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.math.lootFromToml("save/loot_table_unit_test.toml")
    example_print_log("lootFromToml entries = " .. tostring(tbl:entryCount()))
    example_print_log("sample preview = " .. tostring(tbl:sample()))
    example_print_log("entries = " .. tostring(tbl:entryCount()))
    example_print_log("sample now = " .. tostring(tbl:sample()))
end
```

---

### `lurek.math.max`

Returns the largest supplied value.

```lua
lurek.math.max(...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| — | — | @param ... number One or more numeric values. |

**Returns**

| Type | Description |
|------|-------------|
| number | Maximum value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("max(3, 7, 1, 9) = " .. lurek.math.max(3, 7, 1, 9))
    example_print_log("max(0, -5) = " .. lurek.math.max(0, -5))
    example_print_log("highest cooldown = " .. lurek.math.max(0.8, 1.1, 0.6))
    local fastest_speed = lurek.math.max(8, 5, 12)
    example_print_log("fastest speed = " .. fastest_speed)
end
```

---

### `lurek.math.min`

Returns the smallest supplied value.

```lua
lurek.math.min(...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| — | — | @param ... number One or more numeric values. |

**Returns**

| Type | Description |
|------|-------------|
| number | Minimum value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("min(3, 7, 1, 9) = " .. lurek.math.min(3, 7, 1, 9))
    example_print_log("min(0, -5) = " .. lurek.math.min(0, -5))
    example_print_log("lowest cooldown = " .. lurek.math.min(0.8, 1.1, 0.6))
    local slowest_speed = lurek.math.min(8, 5, 12)
    example_print_log("slowest speed = " .. slowest_speed)
end
```

---

### `lurek.math.newBezierCurve`

Creates a Bezier curve from a flat point table.

```lua
lurek.math.newBezierCurve(points)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `points` | table | Flat numeric table `{x1, y1, x2, y2, ...}` with at least two points. |

**Returns**

| Type | Description |
|------|-------------|
| [LBezierCurve](#lbeziercurve) | New Bezier curve handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local curve = lurek.math.newBezierCurve({0, 0, 30, 60, 70, 60, 100, 0})
    example_print_log("control points = " .. curve:getControlPointCount())
    local x, y = curve:evaluate(0.5)
    example_print_log("mid = " .. x .. "," .. y)
    example_print_log("curve points = " .. curve:getControlPointCount())
end
```

---

### `lurek.math.newCircle`

Creates a circle primitive. This function is exposed to Lua scripts.

```lua
lurek.math.newCircle(x, y, radius)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Center x coordinate. |
| `y` | number | Center y coordinate. |
| `radius` | number | Circle radius. |

**Returns**

| Type | Description |
|------|-------------|
| [LCircle](#lcircle) | New circle handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local c = lurek.math.newCircle(50, 50, 25)
    example_print_log("circle at " .. c:x() .. "," .. c:y() .. " r=" .. c:radius())
    example_print_log("area = " .. c:area())
    example_print_log("radius = " .. c:radius())
    example_print_log("center x = " .. c:x())
end
```

---

### `lurek.math.newLootTable`

Creates a Walker-Vose alias-method loot table for O(1) weighted random sampling.

```lua
lurek.math.newLootTable(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | any | Optional nil, non-negative seed number, or options table `{ seed = integer }`. |

**Returns**

| Type | Description |
|------|-------------|
| [LLootTable](#lloottable) | New loot table handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local loot = lurek.math.newLootTable({ seed = 42 })
    loot:add("common", 10.0, { tier = "c" })
    loot:add("rare", 1.0, { tier = "r" })
    loot:build()
    local pick = loot:sample()
    example_print_log("loot pick = " .. tostring(pick and pick.id))
end
```

---

### `lurek.math.newPityTracker`

Creates a pity tracker that primes after `threshold` consecutive misses of `target_id`.

```lua
lurek.math.newPityTracker(target_id, threshold)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target_id` | string | Item id that resets the miss counter on a hit. |
| `threshold` | number | Number of consecutive misses before the tracker primes. |

**Returns**

| Type | Description |
|------|-------------|
| [LPityTracker](#lpitytracker) | New pity tracker handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local loot = lurek.math.newLootTable(7)
    loot:add("common", 100.0)
    loot:add("rare", 0.0, { tier = "r" })
    loot:build()

    local pity = lurek.math.newPityTracker("rare", 2)
    pity:notice("common")
    pity:notice("common")
    local id = lurek.math.sampleWithPity(loot, pity)
    example_print_log("pity sample = " .. tostring(id))
end
```

---

### `lurek.math.newRandomGenerator`

Creates a deterministic random generator with an optional seed.

```lua
lurek.math.newRandomGenerator(seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `seed?` | number | Seed value. |

**Returns**

| Type | Description |
|------|-------------|
| [LRandomGenerator](#lrandomgenerator) | New random generator handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(42)
    example_print_log("seed = " .. rng:getSeed())
    example_print_log("seed = " .. rng:getSeed())
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
end
```

---

### `lurek.math.newRectPacker`

Creates a rectangle packer. This function is exposed to Lua scripts.

```lua
lurek.math.newRectPacker(width, height, padding)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Packer width. |
| `height` | number | Packer height. |
| `padding?` | number | Padding between rectangles (default 0). |

**Returns**

| Type | Description |
|------|-------------|
| [LRectPacker](#lrectpacker) | New rectangle packer handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rp = lurek.math.newRectPacker(256, 256, 1)
    local x, y = rp:pack(32, 32, "icon1")
    example_print_log("icon1 = " .. tostring(x) .. "," .. tostring(y))
    example_print_log("occupancy = " .. rp:occupancy())
    example_print_log("occupancy = " .. rp:occupancy())
end
```

---

### `lurek.math.newSpatialHash`

Creates a spatial hash index with a cell size.

```lua
lurek.math.newSpatialHash(cell_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cell_size` | number | Spatial hash cell size. |

**Returns**

| Type | Description |
|------|-------------|
| [LSpatialHash](#lspatialhash) | New spatial hash handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sh = lurek.math.newSpatialHash(32)
    sh:insert("a", 10, 10, 20, 20)
    sh:insert("b", 50, 50, 30, 30)
    example_print_log("cell size = " .. sh:getCellSize() .. " items = " .. sh:getItemCount())
    example_print_log("cell size = " .. sh:getCellSize())
end
```

---

### `lurek.math.newTransform`

Creates a 2D transform. All components are optional; omitting all returns an identity transform.

```lua
lurek.math.newTransform(x, y, angle, sx, sy, ox, oy, kx, ky)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x?` | number | X translation (default 0). |
| `y?` | number | Y translation (default 0). |
| `angle?` | number | Rotation angle in radians (default 0). |
| `sx?` | number | X scale factor (default 1). |
| `sy?` | number | Y scale factor (defaults to `sx`). |
| `ox?` | number | X origin offset for rotation/scale (default 0). |
| `oy?` | number | Y origin offset for rotation/scale (default 0). |
| `kx?` | number | X shear factor (default 0). |
| `ky?` | number | Y shear factor (default 0). |

**Returns**

| Type | Description |
|------|-------------|
| [LTransform](#ltransform) | New transform handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local t = lurek.math.newTransform(100, 200, lurek.math.pi / 4, 2, 2)
    local x, y = t:transformPoint(0, 0)
    example_print_log("origin transformed = " .. x .. "," .. y)
    example_print_log("origin x = " .. select(1, t:transformPoint(0, 0)))
    example_print_log("origin y = " .. select(2, t:transformPoint(0, 0)))
end
```

---

### `lurek.math.newTween`

Creates a tween with a duration and optional easing name.

```lua
lurek.math.newTween(duration, easing_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `duration` | number | Tween duration in seconds. |
| `easing_name?` | string | Easing name (default `linear`). |

**Returns**

| Type | Description |
|------|-------------|
| [LTween](#ltween) | New tween handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tw = lurek.math.newTween(2.0, "inOutCubic")
    example_print_log("duration = " .. tw:getDuration())
    example_print_log("easing = " .. tw:getEasingName())
    example_print_log("tween time = " .. tw:getTime())
    example_print_log("value count = " .. tw:getValueCount())
end
```

---

### `lurek.math.outBack`

Applies back ease-out. This function is exposed to Lua scripts.

```lua
lurek.math.outBack(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | Normalized input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Eased value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.outBack(0.25))
    example_print_log("t=0.75 = " .. lurek.math.outBack(0.75))
    example_print_log("finish = " .. lurek.math.outBack(1.0))
    local ease_start = lurek.math.outBack(0.0)
    example_print_log("start = " .. ease_start)
end
```

---

### `lurek.math.outBounce`

Applies bounce ease-out. This function is exposed to Lua scripts.

```lua
lurek.math.outBounce(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | Normalized input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Eased value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.outBounce(0.25))
    example_print_log("t=0.75 = " .. lurek.math.outBounce(0.75))
    example_print_log("finish = " .. lurek.math.outBounce(1.0))
    local ease_start = lurek.math.outBounce(0.0)
    example_print_log("start = " .. ease_start)
end
```

---

### `lurek.math.outCubic`

Applies cubic ease-out. This function is exposed to Lua scripts.

```lua
lurek.math.outCubic(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | Normalized input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Eased value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.outCubic(0.25))
    example_print_log("t=0.75 = " .. lurek.math.outCubic(0.75))
    example_print_log("finish = " .. lurek.math.outCubic(1.0))
    local ease_start = lurek.math.outCubic(0.0)
    example_print_log("start = " .. ease_start)
end
```

---

### `lurek.math.outElastic`

Applies elastic ease-out. This function is exposed to Lua scripts.

```lua
lurek.math.outElastic(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | Normalized input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Eased value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.outElastic(0.25))
    example_print_log("t=0.75 = " .. lurek.math.outElastic(0.75))
    example_print_log("finish = " .. lurek.math.outElastic(1.0))
    local ease_start = lurek.math.outElastic(0.0)
    example_print_log("start = " .. ease_start)
end
```

---

### `lurek.math.outExpo`

Applies exponential ease-out. This function is exposed to Lua scripts.

```lua
lurek.math.outExpo(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | Normalized input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Eased value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.outExpo(0.25))
    example_print_log("t=0.75 = " .. lurek.math.outExpo(0.75))
    example_print_log("finish = " .. lurek.math.outExpo(1.0))
    local ease_start = lurek.math.outExpo(0.0)
    example_print_log("start = " .. ease_start)
end
```

---

### `lurek.math.outQuad`

Applies quadratic ease-out. This function is exposed to Lua scripts.

```lua
lurek.math.outQuad(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | Normalized input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Eased value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.outQuad(0.25))
    example_print_log("t=0.75 = " .. lurek.math.outQuad(0.75))
    example_print_log("finish = " .. lurek.math.outQuad(1.0))
    local ease_start = lurek.math.outQuad(0.0)
    example_print_log("start = " .. ease_start)
end
```

---

### `lurek.math.outQuart`

Applies quartic ease-out. This function is exposed to Lua scripts.

```lua
lurek.math.outQuart(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | Normalized input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Eased value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.outQuart(0.25))
    example_print_log("t=0.75 = " .. lurek.math.outQuart(0.75))
    example_print_log("finish = " .. lurek.math.outQuart(1.0))
    local ease_start = lurek.math.outQuart(0.0)
    example_print_log("start = " .. ease_start)
end
```

---

### `lurek.math.outSine`

Applies sine ease-out. This function is exposed to Lua scripts.

```lua
lurek.math.outSine(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | Normalized input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Eased value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("t=0.25 = " .. lurek.math.outSine(0.25))
    example_print_log("t=0.75 = " .. lurek.math.outSine(0.75))
    example_print_log("finish = " .. lurek.math.outSine(1.0))
    local ease_start = lurek.math.outSine(0.0)
    example_print_log("start = " .. ease_start)
end
```

---

### `lurek.math.pointInPolygon`

Returns whether a point lies inside a polygon.

```lua
lurek.math.pointInPolygon(pts, px, py)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pts` | table | Flat numeric polygon point table. |
| `px` | number | Point x coordinate. |
| `py` | number | Point y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the point is inside the polygon. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pts = {0, 0, 10, 0, 10, 10, 0, 10}
    local inside = lurek.math.pointInPolygon(pts, 5, 5)
    local outside = lurek.math.pointInPolygon(pts, 15, 5)
    example_print_log("inside = " .. tostring(inside) .. " outside = " .. tostring(outside))
    local edge = lurek.math.pointInPolygon(pts, 0, 5)
end
```

---

### `lurek.math.polygonArea`

Computes signed area for a flat polygon point table.

```lua
lurek.math.polygonArea(pts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pts` | table | Flat numeric polygon point table. |

**Returns**

| Type | Description |
|------|-------------|
| number | Polygon area. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pts = {0, 0, 10, 0, 10, 10, 0, 10}
    local area = lurek.math.polygonArea(pts)
    example_print_log("area = " .. area)
    local triangle_area = lurek.math.polygonArea({0, 0, 8, 0, 0, 8})
    example_print_log("triangle area = " .. triangle_area)
end
```

---

### `lurek.math.polygonCentroid`

Computes the centroid for a flat polygon point table.

```lua
lurek.math.polygonCentroid(pts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pts` | table | Flat numeric polygon point table. |

**Returns**

| Type | Description |
|------|-------------|
| number | Centroid x coordinate. |
| number | Centroid y coordinate. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pts = {0, 0, 10, 0, 10, 10, 0, 10}
    local cx, cy = lurek.math.polygonCentroid(pts)
    example_print_log("centroid = " .. cx .. "," .. cy)
    local cx2, cy2 = lurek.math.polygonCentroid({0, 0, 8, 0, 8, 8, 0, 8})
    example_print_log("square center = " .. cx2 .. "," .. cy2)
end
```

---

### `lurek.math.polygonClip`

Clips a flat polygon point table against a plane.

```lua
lurek.math.polygonClip(pts, nx, ny, d)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pts` | table | Flat numeric polygon point table. |
| `nx` | number | Plane normal x component. |
| `ny` | number | Plane normal y component. |
| `d` | number | Plane distance from origin. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Flat numeric clipped polygon point table (x1,y1,x2,y2,...). |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pts = {0, 0, 10, 0, 10, 10, 0, 10}
    local clipped = lurek.math.polygonClip(pts, 1, 0, -5)
    example_print_log("clipped vertices = " .. #clipped / 2)
    local original_points = #pts / 2
    example_print_log("original points = " .. original_points)
end
```

---

### `lurek.math.polygonDifference`

Returns polygon difference points for two polygon tables.

```lua
lurek.math.polygonDifference(a, b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | table | First polygon table of `{x, y}` points. |
| `b` | table | Second polygon table of `{x, y}` points. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Flat array of polygon difference result points (x1,y1,x2,y2,...). |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = {{x=0,y=0}, {x=10,y=0}, {x=10,y=10}, {x=0,y=10}}
    local b = {{x=5,y=5}, {x=15,y=5}, {x=15,y=15}, {x=5,y=15}}
    local result = lurek.math.polygonDifference(a, b)
    example_print_log("difference vertices = " .. #result)
    example_print_log("source polygons = " .. #a .. " + " .. #b)
end
```

---

### `lurek.math.polygonIntersection`

Returns polygon intersection points for two polygon tables.

```lua
lurek.math.polygonIntersection(a, b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | table | First polygon table of `{x, y}` points. |
| `b` | table | Second polygon table of `{x, y}` points. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Flat array of polygon intersection result points (x1,y1,x2,y2,...). |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = {{x=0,y=0}, {x=10,y=0}, {x=10,y=10}, {x=0,y=10}}
    local b = {{x=5,y=5}, {x=15,y=5}, {x=15,y=15}, {x=5,y=15}}
    local result = lurek.math.polygonIntersection(a, b)
    example_print_log("intersection vertices = " .. #result)
    example_print_log("source polygons = " .. #a .. " + " .. #b)
end
```

---

### `lurek.math.polygonUnion`

Returns polygon union points for two polygon tables.

```lua
lurek.math.polygonUnion(a, b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | table | First polygon table of `{x, y}` points. |
| `b` | table | Second polygon table of `{x, y}` points. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Flat array of polygon union result points (x1,y1,x2,y2,...). |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = {{x=0,y=0}, {x=10,y=0}, {x=10,y=10}, {x=0,y=10}}
    local b = {{x=5,y=5}, {x=15,y=5}, {x=15,y=15}, {x=5,y=15}}
    local result = lurek.math.polygonUnion(a, b)
    example_print_log("union vertices = " .. #result)
    example_print_log("source polygons = " .. #a .. " + " .. #b)
end
```

---

### `lurek.math.pow`

Raises a value to a power. This function is exposed to Lua scripts.

```lua
lurek.math.pow(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Base value. |
| `y` | number | Exponent value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Power result. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("pow(2, 10) = " .. lurek.math.pow(2, 10))
    example_print_log("pow(3, 3) = " .. lurek.math.pow(3, 3))
    example_print_log("crit multiplier tier 4 = " .. lurek.math.pow(1.25, 4))
    local stacked_multiplier = lurek.math.pow(1.1, 5)
    example_print_log("stacked multiplier = " .. stacked_multiplier)
end
```

---

### `lurek.math.rad`

Converts degrees to radians. This function is exposed to Lua scripts.

```lua
lurek.math.rad(deg)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `deg` | number | Angle in degrees. |

**Returns**

| Type | Description |
|------|-------------|
| number | Angle in radians. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("rad(180) = " .. lurek.math.rad(180))
    example_print_log("rad(90) = " .. lurek.math.rad(90))
    example_print_log("30deg in radians = " .. lurek.math.rad(30))
    local turret_turn = lurek.math.rad(45)
    example_print_log("turret turn = " .. turret_turn)
end
```

---

### `lurek.math.random`

Returns a Lua math random value, optionally scaled to one or two bounds.

```lua
lurek.math.random(a, b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a?` | number | Upper bound, or lower bound when `b` is given. |
| `b?` | number | Upper bound. |

**Returns**

| Type | Description |
|------|-------------|
| number | Random value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local r1 = lurek.math.random()
    local r2 = lurek.math.random(10)
    local r3 = lurek.math.random(5, 15)
    example_print_log("random = " .. r1 .. ", " .. r2 .. ", " .. r3)
    local loot_roll = lurek.math.random(100)
end
```

---

### `lurek.math.randomInt`

Returns a Lua math random integer in an inclusive range.

```lua
lurek.math.randomInt(lo, hi)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `lo` | number | Lower bound. |
| `hi` | number | Upper bound. |

**Returns**

| Type | Description |
|------|-------------|
| number | Random integer. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local r = lurek.math.randomInt(1, 6)
    example_print_log("randomInt(1,6) = " .. r)
    example_print_log("second die = " .. lurek.math.randomInt(1, 6))
    local reroll = lurek.math.randomInt(1, 6)
    example_print_log("reroll = " .. reroll)
end
```

---

### `lurek.math.rectFromCenter`

Creates a rectangle tuple from center coordinates and size.

```lua
lurek.math.rectFromCenter(cx, cy, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | number | Center x coordinate. |
| `cy` | number | Center y coordinate. |
| `w` | number | Rectangle width. |
| `h` | number | Rectangle height. |

**Returns**

| Type | Description |
|------|-------------|
| number | Rectangle x coordinate. |
| number | Rectangle y coordinate. |
| number | Rectangle width. |
| number | Rectangle height. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local x, y, w, h = lurek.math.rectFromCenter(50, 50, 20, 10)
    example_print_log("rect = " .. x .. "," .. y .. " " .. w .. "x" .. h)
    example_print_log("value types = " .. type(x) .. "," .. type(y) .. "," .. type(w) .. "," .. type(h))
    local center_x = x + w / 2
    example_print_log("center x = " .. center_x)
end
```

---

### `lurek.math.rectUnion`

Returns the union rectangle for two rectangles.

```lua
lurek.math.rectUnion(x1, y1, w1, h1, x2, y2, w2, h2)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | number | First rectangle x coordinate. |
| `y1` | number | First rectangle y coordinate. |
| `w1` | number | First rectangle width. |
| `h1` | number | First rectangle height. |
| `x2` | number | Second rectangle x coordinate. |
| `y2` | number | Second rectangle y coordinate. |
| `w2` | number | Second rectangle width. |
| `h2` | number | Second rectangle height. |

**Returns**

| Type | Description |
|------|-------------|
| number | Union x coordinate. |
| number | Union y coordinate. |
| number | Union width. |
| number | Union height. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local x, y, w, h = lurek.math.rectUnion(0, 0, 10, 10, 5, 5, 10, 10)
    example_print_log("union rect = " .. x .. "," .. y .. " " .. w .. "x" .. h)
    example_print_log("value types = " .. type(x) .. "," .. type(y) .. "," .. type(w) .. "," .. type(h))
    local union_area = w * h
    example_print_log("union area = " .. union_area)
end
```

---

### `lurek.math.remap`

Remaps a value from one range to another.

```lua
lurek.math.remap(v, in_min, in_max, out_min, out_max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Input value. |
| `in_min` | number | Input range minimum. |
| `in_max` | number | Input range maximum. |
| `out_min` | number | Output range minimum. |
| `out_max` | number | Output range maximum. |

**Returns**

| Type | Description |
|------|-------------|
| number | Remapped value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.remap(5, 0, 10, 0, 100)
    example_print_log("remap(5, 0-10 -> 0-100) = " .. v)
    example_print_log("thumbstick 0.25 -> percent = " .. lurek.math.remap(0.25, 0, 1, 0, 100))
    local volume_percent = lurek.math.remap(0.75, 0, 1, 0, 100)
    example_print_log("volume percent = " .. volume_percent)
end
```

---

### `lurek.math.round`

Returns rounded value. This function is exposed to Lua scripts.

```lua
lurek.math.round(x)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Rounded value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("round(2.4) = " .. lurek.math.round(2.4))
    example_print_log("round(2.5) = " .. lurek.math.round(2.5))
    example_print_log("round snaps grid coord = " .. lurek.math.round(6.51))
    local snapped = lurek.math.round(12.6)
    example_print_log("snapped tile = " .. snapped)
end
```

---

### `lurek.math.sampleWithPity`

Samples loot table with pity behavior: forced target when tracker is primed.

```lua
lurek.math.sampleWithPity(loot_table, pity)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `loot_table` | [LLootTable](#lloottable) | Loot table handle. |
| `pity` | [LPityTracker](#lpitytracker) | Pity tracker handle. |

**Returns**

| Type | Description |
|------|-------------|
| string | Selected item id when present; nil when table is empty. |
| table | Selected metadata table when present; nil when table is empty. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local loot = lurek.math.newLootTable(9)
    loot:add("a", 1.0)
    loot:build()
    local pity = lurek.math.newPityTracker("a", 1)
    local id = lurek.math.sampleWithPity(loot, pity)
    example_print_log("sampleWithPity = " .. tostring(id))
end
```

---

### `lurek.math.segmentIntersectsSegment`

Returns whether two segments intersect and their intersection point when present.

```lua
lurek.math.segmentIntersectsSegment(x1, y1, x2, y2, x3, y3, x4, y4)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | number | First segment start x coordinate. |
| `y1` | number | First segment start y coordinate. |
| `x2` | number | First segment end x coordinate. |
| `y2` | number | First segment end y coordinate. |
| `x3` | number | Second segment start x coordinate. |
| `y3` | number | Second segment start y coordinate. |
| `x4` | number | Second segment end x coordinate. |
| `y4` | number | Second segment end y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the segments intersect. |
| number | Intersection x coordinate; or nil. |
| number | Intersection y coordinate; or nil. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local hit, ix, iy = lurek.math.segmentIntersectsSegment( 0, 0, 10, 10, 0, 10, 10, 0 )
    if hit and ix then example_print_log("segments cross at " .. ix .. "," .. iy) else example_print_log("segments do not cross") end
    example_print_log("value types = " .. type(hit) .. "," .. type(ix) .. "," .. type(iy))
    local crossed = hit and ix ~= nil
    example_print_log("crossed = " .. tostring(crossed))
end
```

---

### `lurek.math.sign`

Returns the sign of a value. This function is exposed to Lua scripts.

```lua
lurek.math.sign(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Sign value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("sign(-7) = " .. lurek.math.sign(-7))
    example_print_log("sign(0) = " .. lurek.math.sign(0))
    example_print_log("sign(3) = " .. lurek.math.sign(3))
    local input_x = -42
    example_print_log("input x direction = " .. lurek.math.sign(input_x))
end
```

---

### `lurek.math.sin`

Returns sine of an angle. This function is exposed to Lua scripts.

```lua
lurek.math.sin(x)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Angle in radians. |

**Returns**

| Type | Description |
|------|-------------|
| number | Sine value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("sin(0) = " .. lurek.math.sin(0))
    example_print_log("sin(pi/2) = " .. lurek.math.sin(lurek.math.pi / 2))
    example_print_log("sine wave at pi = " .. lurek.math.sin(lurek.math.pi))
    local jump_arc = lurek.math.sin(lurek.math.pi / 6)
    example_print_log("jump arc = " .. jump_arc)
end
```

---

### `lurek.math.smoothstep`

Applies smoothstep interpolation between two edges.

```lua
lurek.math.smoothstep(edge0, edge1, x)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `edge0` | number | Lower edge. |
| `edge1` | number | Upper edge. |
| `x` | number | Input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Smoothstep value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("smoothstep(0, 1, 0.5) = " .. lurek.math.smoothstep(0, 1, 0.5))
    example_print_log("smoothstep(0, 1, 0.0) = " .. lurek.math.smoothstep(0, 1, 0.0))
    example_print_log("smoothstep(0, 1, 1.0) = " .. lurek.math.smoothstep(0, 1, 1.0))
    local fade_distance = lurek.math.smoothstep(0, 10, 3)
    example_print_log("fade at distance 3 = " .. fade_distance)
end
```

---

### `lurek.math.sqrt`

Returns square root of a value. This function is exposed to Lua scripts.

```lua
lurek.math.sqrt(x)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Input value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Square root. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("sqrt(144) = " .. lurek.math.sqrt(144))
    example_print_log("sqrt(2) = " .. lurek.math.sqrt(2))
    example_print_log("speed from sq length 25 = " .. lurek.math.sqrt(25))
    local tile_diagonal = lurek.math.sqrt(25)
    example_print_log("tile diagonal = " .. tile_diagonal)
end
```

---

### `lurek.math.tan`

Returns tangent of an angle. This function is exposed to Lua scripts.

```lua
lurek.math.tan(x)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Angle in radians. |

**Returns**

| Type | Description |
|------|-------------|
| number | Tangent value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    example_print_log("tan(0) = " .. lurek.math.tan(0))
    example_print_log("tan(pi/4) = " .. lurek.math.tan(lurek.math.pi / 4))
    example_print_log("tan aiming slope = " .. lurek.math.tan(lurek.math.rad(15)))
    local camera_slope = lurek.math.tan(lurek.math.rad(30))
    example_print_log("camera slope = " .. camera_slope)
end
```

---

### `lurek.math.triangulate`

Triangulates a flat polygon point table.

```lua
lurek.math.triangulate(pts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pts` | table | Flat numeric table `{x1, y1, x2, y2, ...}` with at least three points. |

**Returns**

| Type | Description |
|------|-------------|
| LMathTriangulateResult | Array table of flat triangle point tables; each entry is `{x1,y1,x2,y2,x3,y3}`. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pts = {0, 0, 10, 0, 10, 10, 0, 10}
    local tris = lurek.math.triangulate(pts)
    example_print_log("triangles = " .. #tris)
    local source_vertices = #pts / 2
    example_print_log("source vertices = " .. source_vertices)
end
```

---

### `lurek.math.vec2`

Creates a 2D vector. This function is exposed to Lua scripts.

```lua
lurek.math.vec2(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X component. |
| `y` | number | Y component. |

**Returns**

| Type | Description |
|------|-------------|
| [LVec2](#lvec2) | New vector handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.vec2(3, 4)
    example_print_log("vec2 = " .. v.x .. "," .. v.y)
    example_print_log("heading = " .. v:angle())
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalized().x)
end
```

---

### `lurek.math.vec3`

Creates a 3D vector. This function is exposed to Lua scripts.

```lua
lurek.math.vec3(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X component. |
| `y` | number | Y component. |
| `z` | number | Z component. |

**Returns**

| Type | Description |
|------|-------------|
| [LVec3](#lvec3) | New vector handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.vec3(1, 2, 3)
    example_print_log("vec3 = " .. v.x .. "," .. v.y .. "," .. v.z)
    example_print_log("lengthSquared = " .. v:lengthSquared())
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalize().x)
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LAabbTree](#laabbtree)
- [LBezierCurve](#lbeziercurve)
- [LCatmullRom](#lcatmullrom)
- [LCircle](#lcircle)
- [LHermite](#lhermite)
- [LLootTable](#lloottable)
- [LPityTracker](#lpitytracker)
- [LRandomGenerator](#lrandomgenerator)
- [LRectPacker](#lrectpacker)
- [LSpatialHash](#lspatialhash)
- [LTransform](#ltransform)
- [LTween](#ltween)
- [LVec2](#lvec2)
- [LVec3](#lvec3)

## LAabbTree

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LAabbTree:clear`

Clears all items from the tree. This method is available to Lua scripts.

```lua
LAabbTree:clear()
```

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 50, 50)
    tree:clear()
    example_print_log("empty = " .. tostring(tree:isEmpty()))
    example_print_log("tree len = " .. tree:len())
end
```

---

#### `LAabbTree:contains`

Returns whether the tree contains an id.

```lua
LAabbTree:contains(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Item id. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the id exists. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 10, 10)
    example_print_log("contains 1 = " .. tostring(tree:contains(1)))
    example_print_log("tree len = " .. tree:len())
    example_print_log("tree empty = " .. tostring(tree:isEmpty()))
end
```

---

#### `LAabbTree:insert`

Inserts an AABB by id. This method is available to Lua scripts.

```lua
LAabbTree:insert(id, min_x, min_y, max_x, max_y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Item id. |
| `min_x` | number | Minimum x coordinate. |
| `min_y` | number | Minimum y coordinate. |
| `max_x` | number | Maximum x coordinate. |
| `max_y` | number | Maximum y coordinate. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 50, 50)
    example_print_log("len = " .. tree:len())
    example_print_log("tree len = " .. tree:len())
    example_print_log("tree empty = " .. tostring(tree:isEmpty()))
end
```

---

#### `LAabbTree:isEmpty`

Returns whether the tree has no items.

```lua
LAabbTree:isEmpty()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when empty. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tree = lurek.math.aabbTree()
    example_print_log("empty = " .. tostring(tree:isEmpty()))
    example_print_log("tree len = " .. tree:len())
    example_print_log("tree empty = " .. tostring(tree:isEmpty()))
    example_print_log("query origin hits = " .. #tree:query(0, 0, 1, 1))
end
```

---

#### `LAabbTree:len`

Returns the number of items in the tree.

```lua
LAabbTree:len()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Item count. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 50, 50)
    tree:insert(2, 30, 30, 80, 80)
    example_print_log("len = " .. tree:len())
    example_print_log("tree len = " .. tree:len())
end
```

---

#### `LAabbTree:query`

Queries ids intersecting an AABB. This method is available to Lua scripts.

```lua
LAabbTree:query(min_x, min_y, max_x, max_y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min_x` | number | Minimum x coordinate. |
| `min_y` | number | Minimum y coordinate. |
| `max_x` | number | Maximum x coordinate. |
| `max_y` | number | Maximum y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Item ids. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 10, 10)
    tree:insert(2, 5, 5, 15, 15)
    local hits = tree:query(4, 4, 6, 6)
    example_print_log("query hits = " .. #hits)
end
```

---

#### `LAabbTree:queryPoint`

Queries ids containing a point. This method is available to Lua scripts.

```lua
LAabbTree:queryPoint(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Point x coordinate. |
| `y` | number | Point y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Item ids. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 10, 10)
    tree:insert(2, 5, 5, 15, 15)
    local hits = tree:queryPoint(7, 7)
    example_print_log("point hits = " .. #hits)
end
```

---

#### `LAabbTree:remove`

Removes an AABB by id. This method is available to Lua scripts.

```lua
LAabbTree:remove(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Item id. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the item existed. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 10, 10)
    tree:insert(2, 5, 5, 15, 15)
    tree:remove(2)
    example_print_log("len = " .. tree:len())
end
```

---

#### `LAabbTree:type`

Returns the Lua-visible type name for this AABB tree handle.

```lua
LAabbTree:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LAabbTree](#laabbtree)`. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tree = lurek.math.aabbTree()
    example_print_log(tree:type())
    example_print_log("tree len = " .. tree:len())
    example_print_log("tree empty = " .. tostring(tree:isEmpty()))
    example_print_log("query origin hits = " .. #tree:query(0, 0, 1, 1))
end
```

---

#### `LAabbTree:typeOf`

Returns whether this AABB tree handle matches a supported type name.

```lua
LAabbTree:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LAabbTree](#laabbtree)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tree = lurek.math.aabbTree()
    example_print_log(tostring(tree:typeOf("LAabbTree")))
    example_print_log("type = " .. tostring(tree:type()))
    example_print_log("tree len = " .. tree:len())
    example_print_log("tree empty = " .. tostring(tree:isEmpty()))
end
```

---

#### `LAabbTree:update`

Updates an AABB by id. This method is available to Lua scripts.

```lua
LAabbTree:update(id, min_x, min_y, max_x, max_y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Item id. |
| `min_x` | number | Minimum x coordinate. |
| `min_y` | number | Minimum y coordinate. |
| `max_x` | number | Maximum x coordinate. |
| `max_y` | number | Maximum y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the item existed. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tree = lurek.math.aabbTree()
    tree:insert(1, 0, 0, 10, 10)
    tree:update(1, 20, 20, 30, 30)
    local hits = tree:query(19, 19, 21, 21)
    example_print_log("query hits = " .. #hits)
end
```

---

## LBezierCurve

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LBezierCurve:evaluate`

Evaluates this curve at normalized parameter `t`.

```lua
LBezierCurve:evaluate(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | Normalized curve parameter. |

**Returns**

| Type | Description |
|------|-------------|
| number | Point x coordinate. |
| number | Point y coordinate. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local curve = lurek.math.newBezierCurve({0, 0, 50, 100, 100, 0})
    local x, y = curve:evaluate(0.25)
    example_print_log("t=0.25 = " .. x .. "," .. y)
    example_print_log("curve points = " .. curve:getControlPointCount())
    example_print_log("curve length = " .. curve:length())
end
```

---

#### `LBezierCurve:evaluateAtDistance`

Evaluates this curve at an approximate distance along the curve.

```lua
LBezierCurve:evaluateAtDistance(distance, samples)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `distance` | number | Distance along the curve. |
| `samples?` | number | Sample count (default 128). |

**Returns**

| Type | Description |
|------|-------------|
| number | Point x coordinate. |
| number | Point y coordinate. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local curve = lurek.math.newBezierCurve({0, 0, 50, 100, 100, 0})
    local length = curve:length()
    local x, y = curve:evaluateAtDistance(length * 0.5, 32)
    example_print_log("length = " .. length)
    example_print_log("halfway = " .. x .. "," .. y)
end
```

---

#### `LBezierCurve:getControlPoint`

Returns a control point by one-based index.

```lua
LBezierCurve:getControlPoint(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | One-based control point index. |

**Returns**

| Type | Description |
|------|-------------|
| number | X coordinate; or nil when out of range. |
| number | Y coordinate; or nil when out of range. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local curve = lurek.math.newBezierCurve({0, 0, 50, 50, 100, 0})
    local x, y = curve:getControlPoint(2)
    example_print_log("cp2 = " .. x .. "," .. y)
    example_print_log("curve points = " .. curve:getControlPointCount())
    example_print_log("curve length = " .. curve:length())
end
```

---

#### `LBezierCurve:getControlPointCount`

Returns the number of control points in this curve.

```lua
LBezierCurve:getControlPointCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Control point count. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local curve = lurek.math.newBezierCurve({0, 0, 100, 50, 200, 0})
    example_print_log("count = " .. curve:getControlPointCount())
    example_print_log("curve points = " .. curve:getControlPointCount())
    example_print_log("curve length = " .. curve:length())
    example_print_log("curve midpoint x = " .. select(1, curve:evaluate(0.5)))
end
```

---

#### `LBezierCurve:getDerivative`

Returns the derivative curve for this Bezier curve.

```lua
LBezierCurve:getDerivative()
```

**Returns**

| Type | Description |
|------|-------------|
| [LBezierCurve](#lbeziercurve) | Derivative curve handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local curve = lurek.math.newBezierCurve({0, 0, 50, 100, 100, 0})
    local derivative = curve:getDerivative()
    local x, y = derivative:evaluate(0.5)
    example_print_log("derivative control points = " .. derivative:getControlPointCount())
    example_print_log("tangent = " .. x .. "," .. y)
end
```

---

#### `LBezierCurve:insertControlPoint`

Inserts a control point, optionally before a one-based index.

```lua
LBezierCurve:insertControlPoint(x, y, index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Point x coordinate. |
| `y` | number | Point y coordinate. |
| `index?` | number | One-based insertion index. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local curve = lurek.math.newBezierCurve({0, 0, 100, 0})
    example_print_log("count before = " .. curve:getControlPointCount())
    curve:insertControlPoint(50, 50, 2)
    local x, y = curve:getControlPoint(2)
    example_print_log("inserted = " .. x .. "," .. y)
    example_print_log("count after = " .. curve:getControlPointCount())
end
```

---

#### `LBezierCurve:length`

Returns the approximate curve length.

```lua
LBezierCurve:length()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Curve length. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local curve = lurek.math.newBezierCurve({0, 0, 100, 0})
    example_print_log("length = " .. curve:length())
    example_print_log("curve points = " .. curve:getControlPointCount())
    example_print_log("curve length = " .. curve:length())
    example_print_log("curve midpoint x = " .. select(1, curve:evaluate(0.5)))
end
```

---

#### `LBezierCurve:removeControlPoint`

Removes a control point by one-based index.

```lua
LBezierCurve:removeControlPoint(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | One-based control point index. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a control point was removed. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local curve = lurek.math.newBezierCurve({0, 0, 50, 50, 100, 0})
    example_print_log("count before = " .. curve:getControlPointCount())
    curve:removeControlPoint(2)
    example_print_log("count after = " .. curve:getControlPointCount())
    example_print_log("curve points = " .. curve:getControlPointCount())
end
```

---

#### `LBezierCurve:render`

Returns sampled points along this curve.

```lua
LBezierCurve:render(segments)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `segments` | number | Number of curve segments to sample. |

**Returns**

| Type | Description |
|------|-------------|
| LBezierCurveRenderResult | Array table of `{x, y}` point arrays. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local curve = lurek.math.newBezierCurve({0, 0, 50, 80, 100, 0})
    local points = curve:render(4)
    local sample = points[3]
    example_print_log("samples = " .. #points)
    example_print_log("sample 3 = " .. sample[1] .. "," .. sample[2])
end
```

---

#### `LBezierCurve:rotate`

Rotates all control points around an origin.

```lua
LBezierCurve:rotate(angle, ox, oy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `angle` | number | Rotation angle. |
| `ox` | number | Origin x coordinate. |
| `oy` | number | Origin y coordinate. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local curve = lurek.math.newBezierCurve({0, 0, 100, 0})
    curve:rotate(lurek.math.pi / 2, 0, 0)
    local x, y = curve:getControlPoint(2)
    example_print_log("end point = " .. x .. "," .. y)
    example_print_log("curve points = " .. curve:getControlPointCount())
end
```

---

#### `LBezierCurve:scale`

Scales all control points around an origin.

```lua
LBezierCurve:scale(s, ox, oy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `s` | number | Scale factor. |
| `ox` | number | Origin x coordinate. |
| `oy` | number | Origin y coordinate. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local curve = lurek.math.newBezierCurve({0, 0, 100, 0})
    curve:scale(2, 0, 0)
    local x, y = curve:getControlPoint(2)
    example_print_log("end point = " .. x .. "," .. y)
    example_print_log("curve points = " .. curve:getControlPointCount())
end
```

---

#### `LBezierCurve:setControlPoint`

Sets a control point by one-based index.

```lua
LBezierCurve:setControlPoint(index, x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | One-based control point index. |
| `x` | number | New x coordinate. |
| `y` | number | New y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the control point exists. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local curve = lurek.math.newBezierCurve({0, 0, 50, 50, 100, 0})
    local beforeX, beforeY = curve:getControlPoint(2)
    curve:setControlPoint(2, 50, 80)
    local afterX, afterY = curve:getControlPoint(2)
    example_print_log("before = " .. beforeX .. "," .. beforeY)
    example_print_log("after = " .. afterX .. "," .. afterY)
end
```

---

#### `LBezierCurve:translate`

Translates all control points. This method is available to Lua scripts.

```lua
LBezierCurve:translate(dx, dy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dx` | number | X translation. |
| `dy` | number | Y translation. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local curve = lurek.math.newBezierCurve({0, 0, 50, 50, 100, 0})
    local beforeX, beforeY = curve:evaluate(0)
    curve:translate(10, 20)
    local afterX, afterY = curve:evaluate(0)
    example_print_log("before = " .. beforeX .. "," .. beforeY)
    example_print_log("after = " .. afterX .. "," .. afterY)
end
```

---

#### `LBezierCurve:type`

Returns the Lua-visible type name for this Bezier curve handle.

```lua
LBezierCurve:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LBezierCurve](#lbeziercurve)`. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local curve = lurek.math.newBezierCurve({0, 0, 100, 50, 200, 0})
    example_print_log(curve:type())
    example_print_log("curve points = " .. curve:getControlPointCount())
    example_print_log("curve length = " .. curve:length())
    example_print_log("curve midpoint x = " .. select(1, curve:evaluate(0.5)))
end
```

---

#### `LBezierCurve:typeOf`

Returns whether this Bezier curve handle matches a supported type name.

```lua
LBezierCurve:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LBezierCurve](#lbeziercurve)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local curve = lurek.math.newBezierCurve({0, 0, 100, 50, 200, 0})
    example_print_log(tostring(curve:typeOf("LBezierCurve")))
    example_print_log("type = " .. tostring(curve:type()))
    example_print_log("curve points = " .. curve:getControlPointCount())
    example_print_log("curve length = " .. curve:length())
end
```

---

## LCatmullRom

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LCatmullRom:addPoint`

Adds a point to the spline. This method is available to Lua scripts.

```lua
LCatmullRom:addPoint(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Point x coordinate. |
| `y` | number | Point y coordinate. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local spline = lurek.math.catmullRom({{x = 0, y = 0}, {x = 50, y = 80}, {x = 100, y = 20}})
    example_print_log("before = " .. spline:len())
    spline:addPoint(150, 60)
    example_print_log("after = " .. spline:len())
    example_print_log("spline points = " .. spline:len())
end
```

---

#### `LCatmullRom:len`

Returns the number of points in the spline.

```lua
LCatmullRom:len()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Point count. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local spline = lurek.math.catmullRom({{x = 0, y = 0}, {x = 50, y = 100}, {x = 150, y = 100}, {x = 200, y = 0}})
    example_print_log("len = " .. spline:len())
    example_print_log("spline points = " .. spline:len())
    example_print_log("sample x at 0.5 = " .. select(1, spline:sample(0.5)))
    example_print_log("sample y at 0.5 = " .. select(2, spline:sample(0.5)))
end
```

---

#### `LCatmullRom:removePoint`

Removes a point by zero-based index and returns its coordinates.

```lua
LCatmullRom:removePoint(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Zero-based point index. |

**Returns**

| Type | Description |
|------|-------------|
| number | Removed point x coordinate. |
| number | Removed point y coordinate. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local spline = lurek.math.catmullRom({{x = 0, y = 0}, {x = 50, y = 80}, {x = 100, y = 20}, {x = 150, y = 60}})
    local x, y = spline:removePoint(1)
    example_print_log("removed = " .. x .. "," .. y)
    example_print_log("after = " .. spline:len())
    example_print_log("spline points = " .. spline:len())
end
```

---

#### `LCatmullRom:sample`

Samples the spline at normalized parameter `t`.

```lua
LCatmullRom:sample(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | Normalized spline parameter. |

**Returns**

| Type | Description |
|------|-------------|
| number | Sample x coordinate. |
| number | Sample y coordinate. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local spline = lurek.math.catmullRom({{x = 0, y = 0}, {x = 50, y = 80}, {x = 100, y = 20}, {x = 150, y = 60}})
    local x, y = spline:sample(0.25)
    example_print_log("t=0.25 = " .. x .. "," .. y)
    example_print_log("spline points = " .. spline:len())
    example_print_log("sample x at 0.5 = " .. select(1, spline:sample(0.5)))
end
```

---

#### `LCatmullRom:sampleSegment`

Samples one spline segment at local parameter `t`.

```lua
LCatmullRom:sampleSegment(seg, t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `seg` | number | Zero-based segment index. |
| `t` | number | Segment-local parameter. |

**Returns**

| Type | Description |
|------|-------------|
| number | Sample x coordinate. |
| number | Sample y coordinate. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local spline = lurek.math.catmullRom({{x = 0, y = 0}, {x = 50, y = 80}, {x = 100, y = 20}, {x = 150, y = 60}})
    local x, y = spline:sampleSegment(1, 0.5)
    example_print_log("segment 1 = " .. x .. "," .. y)
    example_print_log("spline points = " .. spline:len())
    example_print_log("sample x at 0.5 = " .. select(1, spline:sample(0.5)))
end
```

---

#### `LCatmullRom:type`

Returns the Lua-visible type name for this spline handle.

```lua
LCatmullRom:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LCatmullRom](#lcatmullrom)`. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local spline = lurek.math.catmullRom({{x = 0, y = 0}, {x = 50, y = 100}, {x = 150, y = 100}, {x = 200, y = 0}})
    example_print_log(spline:type())
    example_print_log("spline points = " .. spline:len())
    example_print_log("sample x at 0.5 = " .. select(1, spline:sample(0.5)))
    example_print_log("sample y at 0.5 = " .. select(2, spline:sample(0.5)))
end
```

---

#### `LCatmullRom:typeOf`

Returns whether this spline handle matches a supported type name.

```lua
LCatmullRom:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LCatmullRom](#lcatmullrom)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local spline = lurek.math.catmullRom({{x = 0, y = 0}, {x = 50, y = 100}, {x = 150, y = 100}, {x = 200, y = 0}})
    example_print_log(tostring(spline:typeOf("LCatmullRom")))
    example_print_log("type = " .. tostring(spline:type()))
    example_print_log("spline points = " .. spline:len())
    example_print_log("sample x at 0.5 = " .. select(1, spline:sample(0.5)))
end
```

---

## LCircle

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LCircle:aabb`

Returns this circle axis-aligned bounding box.

```lua
LCircle:aabb()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Minimum x coordinate. |
| number | Minimum y coordinate. |
| number | Maximum x coordinate. |
| number | Maximum y coordinate. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local c1 = lurek.math.newCircle(0, 0, 10)
    local minx, miny, maxx, maxy = c1:aabb()
    example_print_log("aabb = " .. minx .. "," .. miny .. " " .. maxx .. "," .. maxy)
    example_print_log("radius = " .. c1:radius())
    example_print_log("center x = " .. c1:x())
end
```

---

#### `LCircle:area`

Returns this circle area. This method is available to Lua scripts.

```lua
LCircle:area()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Circle area. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local c = lurek.math.newCircle(100, 100, 50)
    example_print_log("area = " .. c:area())
    example_print_log("radius = " .. c:radius())
    example_print_log("center x = " .. c:x())
    example_print_log("center y = " .. c:y())
end
```

---

#### `LCircle:contains`

Returns whether this circle contains a point.

```lua
LCircle:contains(px, py)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `px` | number | Point x coordinate. |
| `py` | number | Point y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the point is inside the circle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local circle = lurek.math.newCircle(0, 0, 10)
    example_print_log("contains = " .. tostring(circle:contains(5, 5)))
    example_print_log("radius = " .. circle:radius())
    example_print_log("center x = " .. circle:x())
    example_print_log("center y = " .. circle:y())
end
```

---

#### `LCircle:intersects`

Returns whether this circle intersects another circle.

```lua
LCircle:intersects(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LCircle](#lcircle) | Other circle handle. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the circles intersect. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = lurek.math.newCircle(0, 0, 10)
    local b = lurek.math.newCircle(15, 0, 10)
    example_print_log("intersects = " .. tostring(a:intersects(b)))
    example_print_log("radius = " .. a:radius())
    example_print_log("center x = " .. a:x())
end
```

---

#### `LCircle:perimeter`

Returns this circle perimeter. This method is available to Lua scripts.

```lua
LCircle:perimeter()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Circle perimeter. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local c = lurek.math.newCircle(100, 100, 50)
    example_print_log("perimeter = " .. c:perimeter())
    example_print_log("radius = " .. c:radius())
    example_print_log("center x = " .. c:x())
    example_print_log("center y = " .. c:y())
end
```

---

#### `LCircle:radius`

Returns this circle radius. This method is available to Lua scripts.

```lua
LCircle:radius()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Radius. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local c = lurek.math.newCircle(100, 100, 50)
    example_print_log("radius = " .. c:radius())
    example_print_log("radius = " .. c:radius())
    example_print_log("center x = " .. c:x())
    example_print_log("center y = " .. c:y())
end
```

---

#### `LCircle:type`

Returns the Lua-visible type name for this circle handle.

```lua
LCircle:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LCircle](#lcircle)`. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local c = lurek.math.newCircle(100, 100, 50)
    example_print_log(c:type())
    example_print_log("radius = " .. c:radius())
    example_print_log("center x = " .. c:x())
    example_print_log("center y = " .. c:y())
end
```

---

#### `LCircle:typeOf`

Returns whether this circle handle matches a supported type name.

```lua
LCircle:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LCircle](#lcircle)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local c = lurek.math.newCircle(100, 100, 50)
    example_print_log(tostring(c:typeOf("LCircle")))
    example_print_log("type = " .. tostring(c:type()))
    example_print_log("radius = " .. c:radius())
    example_print_log("center x = " .. c:x())
end
```

---

#### `LCircle:x`

Returns this circle center x coordinate.

```lua
LCircle:x()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Center x coordinate. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local c = lurek.math.newCircle(100, 100, 50)
    example_print_log("x = " .. c:x())
    example_print_log("radius = " .. c:radius())
    example_print_log("center x = " .. c:x())
    example_print_log("center y = " .. c:y())
end
```

---

#### `LCircle:y`

Returns this circle center y coordinate.

```lua
LCircle:y()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Center y coordinate. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local c = lurek.math.newCircle(100, 100, 50)
    example_print_log("y = " .. c:y())
    example_print_log("radius = " .. c:radius())
    example_print_log("center x = " .. c:x())
    example_print_log("center y = " .. c:y())
end
```

---

## LHermite

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LHermite:sample`

Samples the spline at normalized parameter `t`.

```lua
LHermite:sample(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | Normalized spline parameter. |

**Returns**

| Type | Description |
|------|-------------|
| number | Sample x coordinate. |
| number | Sample y coordinate. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local h = lurek.math.hermite(0, 0, 200, 0, 1, 2, -1, 2)
    local x, y = h:sample(0.5)
    example_print_log("sample = " .. x .. "," .. y)
    example_print_log("sample x at 0.25 = " .. select(1, h:sample(0.25)))
    example_print_log("sample y at 0.25 = " .. select(2, h:sample(0.25)))
end
```

---

#### `LHermite:type`

Returns the Lua-visible type name for this spline handle.

```lua
LHermite:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LHermite](#lhermite)`. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local h = lurek.math.hermite(0, 0, 200, 0, 1, 2, -1, 2)
    example_print_log(h:type())
    example_print_log("sample x at 0.25 = " .. select(1, h:sample(0.25)))
    example_print_log("sample y at 0.25 = " .. select(2, h:sample(0.25)))
    example_print_log("sample x at 0.75 = " .. select(1, h:sample(0.75)))
end
```

---

#### `LHermite:typeOf`

Returns whether this spline handle matches a supported type name.

```lua
LHermite:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LHermite](#lhermite)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local h = lurek.math.hermite(0, 0, 200, 0, 1, 2, -1, 2)
    example_print_log(tostring(h:typeOf("LHermite")))
    example_print_log("type = " .. tostring(h:type()))
    example_print_log("sample x at 0.25 = " .. select(1, h:sample(0.25)))
    example_print_log("sample y at 0.25 = " .. select(2, h:sample(0.25)))
end
```

---

## LLootTable

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LLootTable:add`

Adds an entry to the table. Re-build is required before the next sample.

```lua
LLootTable:add(id, weight, meta)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Unique item identifier. |
| `weight` | number | Relative drop weight (positive). |
| `meta?` | table | Optional key-value metadata table. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.math.newLootTable(1)
    tbl:add("wood", 1.0)
    example_print_log("add ok")
    example_print_log("entries = " .. tostring(tbl:entryCount()))
    example_print_log("sample now = " .. tostring(tbl:sample()))
end
```

---

#### `LLootTable:build`

Rebuilds the alias table after mutations. Call before sampling.

```lua
LLootTable:build()
```

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.math.newLootTable(1)
    tbl:add("wood", 1.0)
    tbl:build()
    example_print_log("build ok")
    example_print_log("entries = " .. tostring(tbl:entryCount()))
end
```

---

#### `LLootTable:entryCount`

Returns the number of entries in the table.

```lua
LLootTable:entryCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Entry count. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.math.newLootTable(1)
    tbl:add("wood", 1.0)
    example_print_log("entryCount = " .. tostring(tbl:entryCount()))
    example_print_log("entries = " .. tostring(tbl:entryCount()))
    example_print_log("sample now = " .. tostring(tbl:sample()))
end
```

---

#### `LLootTable:merge`

Merges entries from another loot table into this one.

```lua
LLootTable:merge(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LLootTable](#lloottable) | Source loot table. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = lurek.math.newLootTable(9)
    local b = lurek.math.newLootTable(10)
    a:add("a", 1.0)
    b:add("b", 1.0)
    a:merge(b)
    a:build()
    example_print_log("merged entries = " .. tostring(a:entryCount()))
end
```

---

#### `LLootTable:remove`

Removes an entry by id. Returns true when found.

```lua
LLootTable:remove(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Item identifier. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when removed. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.math.newLootTable(1)
    tbl:add("wood", 1.0)
    tbl:remove("wood")
    example_print_log("remove ok")
    example_print_log("entries = " .. tostring(tbl:entryCount()))
end
```

---

#### `LLootTable:restore`

Restores loot table state from a blob produced by `save`.

```lua
LLootTable:restore(blob)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `blob` | string | Binary blob. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = lurek.math.newLootTable(9)
    a:add("a", 1.0)
    a:build()
    local blob = a:save()
    local restored = lurek.math.newLootTable()
    restored:restore(blob)
    example_print_log("restore count = " .. tostring(restored:entryCount()))
end
```

---

#### `LLootTable:sample`

Samples one entry in O(1), returning nil instead of a table when empty.

```lua
LLootTable:sample()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Table with `id` (string) and `weight` (number) fields when present. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.math.newLootTable(1)
    tbl:add("wood", 1.0)
    tbl:build()
    example_print_log("sample = " .. tostring(tbl:sample()))
    example_print_log("entries = " .. tostring(tbl:entryCount()))
end
```

---

#### `LLootTable:sampleN`

Samples n entries with replacement. Returns an array table.

```lua
LLootTable:sampleN(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | number | Number of samples. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of entry tables. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.math.newLootTable(1)
    tbl:add("wood", 1.0)
    tbl:add("stone", 1.0)
    tbl:build()
    local picks = tbl:sampleN(2)
    example_print_log("sampleN = " .. tostring(#picks))
end
```

---

#### `LLootTable:sampleUnique`

Samples up to n unique entries (by id). Returns an array table.

```lua
LLootTable:sampleUnique(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | number | Maximum number of unique entries. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of unique entry tables. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.math.newLootTable(1)
    tbl:add("wood", 1.0)
    tbl:add("stone", 1.0)
    tbl:build()
    local picks = tbl:sampleUnique(2)
    example_print_log("sampleUnique = " .. tostring(#picks))
end
```

---

#### `LLootTable:save`

Serialises loot table state to a binary blob.

```lua
LLootTable:save()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Binary blob. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = lurek.math.newLootTable(9)
    a:add("a", 1.0)
    a:build()
    local blob = a:save()
    example_print_log("save blob bytes = " .. tostring(#blob))
end
```

---

#### `LLootTable:setSeed`

Sets the RNG seed. The alias table remains valid.

```lua
LLootTable:setSeed(seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `seed` | number | New seed value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.math.newLootTable(1)
    tbl:setSeed(7)
    example_print_log("setSeed ok")
    example_print_log("entries = " .. tostring(tbl:entryCount()))
    example_print_log("sample now = " .. tostring(tbl:sample()))
end
```

---

#### `LLootTable:setWeight`

Updates the weight of an existing entry. Returns true when found.

```lua
LLootTable:setWeight(id, weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Item identifier. |
| `weight` | number | New weight. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when found. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.math.newLootTable(1)
    tbl:add("wood", 1.0)
    tbl:setWeight("wood", 2.0)
    example_print_log("setWeight ok")
    example_print_log("entries = " .. tostring(tbl:entryCount()))
end
```

---

#### `LLootTable:type`

Returns the Lua-visible type name.

```lua
LLootTable:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LLootTable](#lloottable)`. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.math.newLootTable(1)
    example_print_log("type = " .. tostring(tbl:type()))
    example_print_log("entries = " .. tostring(tbl:entryCount()))
    example_print_log("sample now = " .. tostring(tbl:sample()))
    example_print_log("save blob exists = " .. tostring(tbl:save() ~= nil))
end
```

---

#### `LLootTable:typeOf`

Returns whether this handle matches the given type name.

```lua
LLootTable:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when matched. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tbl = lurek.math.newLootTable(1)
    example_print_log("typeOf = " .. tostring(tbl:typeOf("LLootTable")))
    example_print_log("type = " .. tostring(tbl:type()))
    example_print_log("entries = " .. tostring(tbl:entryCount()))
    example_print_log("sample now = " .. tostring(tbl:sample()))
end
```

---

## LPityTracker

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LPityTracker:counter`

Returns the current miss counter used by pity-prime progression logic.

```lua
LPityTracker:counter()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current miss count. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pity = lurek.math.newPityTracker("rare", 2)
    example_print_log("counter = " .. tostring(pity:counter()))
    example_print_log("counter = " .. tostring(pity:counter()))
    example_print_log("primed = " .. tostring(pity:isPrimed()))
    example_print_log("export exists = " .. tostring(pity:export() ~= nil))
end
```

---

#### `LPityTracker:export`

Compatibility alias for `save` that exports the same binary payload.

```lua
LPityTracker:export()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Binary blob. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pity = lurek.math.newPityTracker("rare", 2)
    local snapshot = pity:export()
    example_print_log("export ok = " .. tostring(snapshot ~= nil))
    example_print_log("counter = " .. tostring(pity:counter()))
    example_print_log("primed = " .. tostring(pity:isPrimed()))
end
```

---

#### `LPityTracker:import`

Compatibility alias for `restore`.

```lua
LPityTracker:import(blob)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `blob` | string | Binary blob. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pity = lurek.math.newPityTracker("rare", 2)
    local snapshot = pity:export()
    pity:import(snapshot)
    example_print_log("import ok")
    example_print_log("counter = " .. tostring(pity:counter()))
end
```

---

#### `LPityTracker:isPrimed`

Returns true when the guaranteed drop is due.

```lua
LPityTracker:isPrimed()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when primed. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pity = lurek.math.newPityTracker("rare", 1)
    pity:notice("common")
    example_print_log("isPrimed = " .. tostring(pity:isPrimed()))
    example_print_log("counter = " .. tostring(pity:counter()))
    example_print_log("primed = " .. tostring(pity:isPrimed()))
end
```

---

#### `LPityTracker:notice`

Notifies the tracker of a sample result id.

```lua
LPityTracker:notice(result_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `result_id` | string | The item id that was sampled. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when just primed. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pity = lurek.math.newPityTracker("rare", 2)
    pity:notice("common")
    example_print_log("notice ok")
    example_print_log("counter = " .. tostring(pity:counter()))
    example_print_log("primed = " .. tostring(pity:isPrimed()))
end
```

---

#### `LPityTracker:reset`

Resets the miss counter and clears primed guaranteed-drop state.

```lua
LPityTracker:reset()
```

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pity = lurek.math.newPityTracker("rare", 2)
    pity:notice("common")
    pity:reset()
    example_print_log("reset counter = " .. tostring(pity:counter()))
    example_print_log("counter = " .. tostring(pity:counter()))
end
```

---

#### `LPityTracker:restore`

Restores pity state from a blob produced by `save`.

```lua
LPityTracker:restore(blob)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `blob` | string | Binary blob. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pity = lurek.math.newPityTracker("b", 1)
    local pity_blob = pity:save()
    pity:restore(pity_blob)
    example_print_log("pity restore ok")
    example_print_log("counter = " .. tostring(pity:counter()))
end
```

---

#### `LPityTracker:save`

Serialises pity state to a binary blob.

```lua
LPityTracker:save()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Binary blob. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pity = lurek.math.newPityTracker("b", 1)
    local pity_blob = pity:save()
    example_print_log("pity save blob = " .. tostring(pity_blob))
    example_print_log("counter = " .. tostring(pity:counter()))
    example_print_log("primed = " .. tostring(pity:isPrimed()))
end
```

---

#### `LPityTracker:type`

Returns the Lua-visible type name.

```lua
LPityTracker:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LPityTracker](#lpitytracker)`. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pity = lurek.math.newPityTracker("rare", 2)
    example_print_log("type = " .. tostring(pity:type()))
    example_print_log("counter = " .. tostring(pity:counter()))
    example_print_log("primed = " .. tostring(pity:isPrimed()))
    example_print_log("export exists = " .. tostring(pity:export() ~= nil))
end
```

---

#### `LPityTracker:typeOf`

Returns whether this handle matches the given type name.

```lua
LPityTracker:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when matched. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pity = lurek.math.newPityTracker("rare", 2)
    example_print_log("typeOf = " .. tostring(pity:typeOf("LPityTracker")))
    example_print_log("type = " .. tostring(pity:type()))
    example_print_log("counter = " .. tostring(pity:counter()))
    example_print_log("primed = " .. tostring(pity:isPrimed()))
end
```

---

## LRandomGenerator

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LRandomGenerator:chance`

Returns true with the given probability (0.0 = never, 1.0 = always).

```lua
LRandomGenerator:chance(probability)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `probability` | number | Probability in range [0.0, 1.0]. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the random check passes. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(10)
    local crit = rng:chance(0.05)
    example_print_log("critical hit (5%) = " .. tostring(crit))
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
end
```

---

#### `LRandomGenerator:countSuccesses`

Rolls N dice and counts how many results are >= the target number.

```lua
LRandomGenerator:countSuccesses(count, sides, target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | number | Number of dice to roll. |
| `sides` | number | Number of sides per die. |
| `target` | number | Minimum value to count as a success. |

**Returns**

| Type | Description |
|------|-------------|
| number | Number of successful dice. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(9)
    local hits = rng:countSuccesses(5, 10, 7)
    example_print_log("5d10 successes (7+) = " .. hits)
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
end
```

---

#### `LRandomGenerator:getSeed`

Returns this generator seed. This method is available to Lua scripts.

```lua
LRandomGenerator:getSeed()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Seed value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(77)
    example_print_log("seed = " .. rng:getSeed())
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
    example_print_log("state token exists = " .. tostring(rng:getState() ~= nil))
end
```

---

#### `LRandomGenerator:getState`

Returns this generator serialized state string.

```lua
LRandomGenerator:getState()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Generator state. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(999)
    example_print_log("state = " .. rng:getState())
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
    example_print_log("state token exists = " .. tostring(rng:getState() ~= nil))
end
```

---

#### `LRandomGenerator:random`

Returns a random floating-point value from the generator.

```lua
LRandomGenerator:random()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Random value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(100)
    example_print_log("random = " .. rng:random())
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
    example_print_log("state token exists = " .. tostring(rng:getState() ~= nil))
end
```

---

#### `LRandomGenerator:randomFloat`

Returns a random floating-point value in a range.

```lua
LRandomGenerator:randomFloat(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min` | number | Minimum value. |
| `max` | number | Maximum value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Random value in range. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(100)
    example_print_log("float = " .. rng:randomFloat(1.0, 5.0))
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
    example_print_log("state token exists = " .. tostring(rng:getState() ~= nil))
end
```

---

#### `LRandomGenerator:randomInt`

Returns a random integer in a range.

```lua
LRandomGenerator:randomInt(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min` | number | Minimum value. |
| `max` | number | Maximum value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Random integer in range. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(100)
    example_print_log("int = " .. rng:randomInt(1, 100))
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
    example_print_log("state token exists = " .. tostring(rng:getState() ~= nil))
end
```

---

#### `LRandomGenerator:randomNormal`

Returns a normally distributed random value.

```lua
LRandomGenerator:randomNormal(stddev, mean)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `stddev?` | number | Standard deviation (default 1.0). |
| `mean?` | number | Mean value (default 0.0). |

**Returns**

| Type | Description |
|------|-------------|
| number | Random normal value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(100)
    example_print_log("normal = " .. rng:randomNormal(1.0, 0.0))
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
    example_print_log("state token exists = " .. tostring(rng:getState() ~= nil))
end
```

---

#### `LRandomGenerator:roll`

Rolls a single die with the given number of sides.

```lua
LRandomGenerator:roll(sides)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sides` | number | Number of sides (minimum 1). |

**Returns**

| Type | Description |
|------|-------------|
| number | Result in range [1, sides]. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(1)
    local d20 = rng:roll(20)
    example_print_log("d20 = " .. d20)
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
end
```

---

#### `LRandomGenerator:rollAdvantage`

Rolls two dice and returns the higher result (advantage mechanic).

```lua
LRandomGenerator:rollAdvantage(sides)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sides` | number | Number of sides per die. |

**Returns**

| Type | Description |
|------|-------------|
| number | Higher of the two rolls. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(6)
    local adv = rng:rollAdvantage(20)
    example_print_log("d20 advantage = " .. adv)
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
end
```

---

#### `LRandomGenerator:rollDisadvantage`

Rolls two dice and returns the lower result (disadvantage mechanic).

```lua
LRandomGenerator:rollDisadvantage(sides)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sides` | number | Number of sides per die. |

**Returns**

| Type | Description |
|------|-------------|
| number | Lower of the two rolls. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(7)
    local dis = rng:rollDisadvantage(20)
    example_print_log("d20 disadvantage = " .. dis)
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
end
```

---

#### `LRandomGenerator:rollExploding`

Rolls N exploding dice: when a die shows its maximum value, roll again and add.

```lua
LRandomGenerator:rollExploding(count, sides)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | number | Number of dice to roll. |
| `sides` | number | Number of sides per die. |

**Returns**

| Type | Description |
|------|-------------|
| number | Total sum including all explosion rerolls. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(8)
    local ex = rng:rollExploding(3, 6)
    example_print_log("3d6 exploding = " .. ex)
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
end
```

---

#### `LRandomGenerator:rollKeepHighest`

Rolls N dice and returns the sum of the highest K results.

```lua
LRandomGenerator:rollKeepHighest(count, sides, keep)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | number | Number of dice to roll. |
| `sides` | number | Number of sides per die. |
| `keep` | number | How many highest results to sum. |

**Returns**

| Type | Description |
|------|-------------|
| number | Sum of the highest keep results. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(4)
    local stat = rng:rollKeepHighest(4, 6, 3)
    example_print_log("4d6 keep 3 highest = " .. stat)
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
end
```

---

#### `LRandomGenerator:rollKeepLowest`

Rolls N dice and returns the sum of the lowest K results.

```lua
LRandomGenerator:rollKeepLowest(count, sides, keep)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | number | Number of dice to roll. |
| `sides` | number | Number of sides per die. |
| `keep` | number | How many lowest results to sum. |

**Returns**

| Type | Description |
|------|-------------|
| number | Sum of the lowest keep results. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(5)
    local penalty = rng:rollKeepLowest(4, 6, 3)
    example_print_log("4d6 keep 3 lowest = " .. penalty)
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
end
```

---

#### `LRandomGenerator:rollN`

Rolls N dice with the given number of sides and returns all results.

```lua
LRandomGenerator:rollN(count, sides)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | number | Number of dice (clamped to [1, 1000]). |
| `sides` | number | Number of sides per die (minimum 1). |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array of individual die results. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(2)
    local dice = rng:rollN(3, 6)
    example_print_log("3d6 = " .. dice[1] .. ", " .. dice[2] .. ", " .. dice[3])
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
end
```

---

#### `LRandomGenerator:rollSum`

Rolls N dice and returns the sum of all results.

```lua
LRandomGenerator:rollSum(count, sides)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | number | Number of dice (clamped to [1, 1000]). |
| `sides` | number | Number of sides per die (minimum 1). |

**Returns**

| Type | Description |
|------|-------------|
| number | Sum of all die results. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(3)
    local total = rng:rollSum(4, 6)
    example_print_log("4d6 sum = " .. total)
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
end
```

---

#### `LRandomGenerator:setSeed`

Resets this generator to a seed value.

```lua
LRandomGenerator:setSeed(seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `seed` | number | Seed value. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(1)
    rng:setSeed(999)
    example_print_log("seed = " .. rng:getSeed())
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
end
```

---

#### `LRandomGenerator:setState`

Restores this generator from a serialized state string.

```lua
LRandomGenerator:setState(state)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `state` | string | Generator state string. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(1)
    local first = rng:random()
    local state = rng:getState()
    local skipped = rng:random()
    rng:setState(state)
    local restored = rng:random()
    example_print_log("restored = " .. tostring(skipped == restored))
    example_print_log("first = " .. first)
end
```

---

#### `LRandomGenerator:type`

Returns the Lua-visible type name for this random generator handle.

```lua
LRandomGenerator:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LRandomGenerator](#lrandomgenerator)`. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(77)
    example_print_log("type = " .. rng:type())
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
    example_print_log("state token exists = " .. tostring(rng:getState() ~= nil))
end
```

---

#### `LRandomGenerator:typeOf`

Returns whether this random generator handle matches a supported type name.

```lua
LRandomGenerator:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LRandomGenerator](#lrandomgenerator)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rng = lurek.math.newRandomGenerator(77)
    example_print_log("typeOf = " .. tostring(rng:typeOf("LRandomGenerator")))
    example_print_log("type = " .. tostring(rng:type()))
    example_print_log("d6 preview = " .. rng:randomInt(1, 6))
    example_print_log("coin flip = " .. tostring(rng:chance(0.5)))
end
```

---

## LRectPacker

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LRectPacker:clear`

Clears packed rectangles from this packer.

```lua
LRectPacker:clear()
```

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rp = lurek.math.newRectPacker(512, 512, 2)
    rp:pack(64, 64, "box")
    rp:clear()
    example_print_log("packed = " .. #rp:getPacked())
    example_print_log("occupancy = " .. rp:occupancy())
end
```

---

#### `LRectPacker:getPacked`

Returns packed rectangle records.

```lua
LRectPacker:getPacked()
```

**Returns**

| Type | Description |
|------|-------------|
| LRectPackerGetPackedResult | Array table with `x`, `y`, `w`, `h`, and optional `id` fields. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rp = lurek.math.newRectPacker(512, 512, 2)
    rp:pack(64, 64, "box")
    local packed = rp:getPacked()
    example_print_log("packed = " .. #packed)
    example_print_log("occupancy = " .. rp:occupancy())
end
```

---

#### `LRectPacker:occupancy`

Returns occupied area ratio. This method is available to Lua scripts.

```lua
LRectPacker:occupancy()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Occupancy ratio. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rp = lurek.math.newRectPacker(512, 512, 2)
    rp:pack(64, 64, "box")
    example_print_log("occupancy = " .. rp:occupancy())
    example_print_log("occupancy = " .. rp:occupancy())
    example_print_log("packed count = " .. #rp:getPacked())
end
```

---

#### `LRectPacker:pack`

Attempts to pack a rectangle and returns its placement coordinates.

```lua
LRectPacker:pack(w, h, id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Rectangle width. |
| `h` | number | Rectangle height. |
| `id?` | string | Rectangle id. |

**Returns**

| Type | Description |
|------|-------------|
| number | X coordinate; or nil when packing fails. |
| number | Y coordinate; or nil when packing fails. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local rp = lurek.math.newRectPacker(512, 512, 2)
    local x, y = rp:pack(64, 64, "box")
    example_print_log("pack = " .. tostring(x) .. "," .. tostring(y))
    example_print_log("occupancy = " .. rp:occupancy())
    example_print_log("packed count = " .. #rp:getPacked())
end
```

---

## LSpatialHash

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSpatialHash:clear`

Clears all items from the spatial hash.

```lua
LSpatialHash:clear()
```

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sh = lurek.math.newSpatialHash(32)
    sh:insert("a", 50, 50, 10, 10)
    sh:clear()
    example_print_log("count = " .. sh:getItemCount())
    example_print_log("cell size = " .. sh:getCellSize())
end
```

---

#### `LSpatialHash:getCellSize`

Returns the spatial hash cell size.

```lua
LSpatialHash:getCellSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Cell size. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sh = lurek.math.newSpatialHash(32)
    example_print_log("cell size = " .. sh:getCellSize())
    example_print_log("cell size = " .. sh:getCellSize())
    example_print_log("item count = " .. sh:getItemCount())
    example_print_log("origin hits = " .. #sh:queryRect(0, 0, 1, 1))
end
```

---

#### `LSpatialHash:getItemCount`

Returns the number of items in the spatial hash.

```lua
LSpatialHash:getItemCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Item count. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sh = lurek.math.newSpatialHash(32)
    sh:insert("a", 50, 50, 10, 10)
    example_print_log("items = " .. sh:getItemCount())
    example_print_log("cell size = " .. sh:getCellSize())
    example_print_log("item count = " .. sh:getItemCount())
end
```

---

#### `LSpatialHash:insert`

Inserts an item rectangle into the spatial hash.

```lua
LSpatialHash:insert(id, x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Item id. |
| `x` | number | Rectangle x coordinate. |
| `y` | number | Rectangle y coordinate. |
| `w` | number | Rectangle width. |
| `h` | number | Rectangle height. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sh = lurek.math.newSpatialHash(32)
    sh:insert("a", 50, 50, 10, 10)
    example_print_log("items = " .. sh:getItemCount())
    example_print_log("cell size = " .. sh:getCellSize())
    example_print_log("item count = " .. sh:getItemCount())
end
```

---

#### `LSpatialHash:queryCircle`

Returns ids intersecting a query circle.

```lua
LSpatialHash:queryCircle(cx, cy, radius)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | number | Circle center x coordinate. |
| `cy` | number | Circle center y coordinate. |
| `radius` | number | Circle radius. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Item ids. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sh = lurek.math.newSpatialHash(16)
    sh:insert("a", 0, 0, 10, 10)
    sh:insert("b", 5, 5, 10, 10)
    local hits = sh:queryCircle(5, 5, 10)
    example_print_log("circle hits = " .. #hits)
end
```

---

#### `LSpatialHash:queryRect`

Returns ids intersecting a query rectangle.

```lua
LSpatialHash:queryRect(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Query x coordinate. |
| `y` | number | Query y coordinate. |
| `w` | number | Query width. |
| `h` | number | Query height. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Item ids. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sh = lurek.math.newSpatialHash(16)
    sh:insert("a", 0, 0, 10, 10)
    sh:insert("b", 5, 5, 10, 10)
    local hits = sh:queryRect(0, 0, 12, 12)
    example_print_log("rect hits = " .. #hits)
end
```

---

#### `LSpatialHash:querySegment`

Returns ids intersecting a query line segment.

```lua
LSpatialHash:querySegment(x1, y1, x2, y2)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | number | Segment start x coordinate. |
| `y1` | number | Segment start y coordinate. |
| `x2` | number | Segment end x coordinate. |
| `y2` | number | Segment end y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Item ids. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sh = lurek.math.newSpatialHash(16)
    sh:insert("a", 0, 0, 10, 10)
    sh:insert("b", 5, 5, 10, 10)
    local hits = sh:querySegment(0, 0, 50, 50)
    example_print_log("segment hits = " .. #hits)
end
```

---

#### `LSpatialHash:remove`

Removes an item from the spatial hash.

```lua
LSpatialHash:remove(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Item id. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sh = lurek.math.newSpatialHash(16)
    sh:insert("a", 0, 0, 10, 10)
    sh:insert("b", 5, 5, 10, 10)
    sh:remove("b")
    example_print_log("items = " .. sh:getItemCount())
end
```

---

#### `LSpatialHash:type`

Returns the Lua-visible type name for this spatial hash handle.

```lua
LSpatialHash:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LSpatialHash](#lspatialhash)`. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sh = lurek.math.newSpatialHash(32)
    example_print_log(sh:type())
    example_print_log("cell size = " .. sh:getCellSize())
    example_print_log("item count = " .. sh:getItemCount())
    example_print_log("origin hits = " .. #sh:queryRect(0, 0, 1, 1))
end
```

---

#### `LSpatialHash:typeOf`

Returns whether this spatial hash handle matches a supported type name.

```lua
LSpatialHash:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LSpatialHash](#lspatialhash)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sh = lurek.math.newSpatialHash(32)
    example_print_log(tostring(sh:typeOf("LSpatialHash")))
    example_print_log("type = " .. tostring(sh:type()))
    example_print_log("cell size = " .. sh:getCellSize())
    example_print_log("item count = " .. sh:getItemCount())
end
```

---

#### `LSpatialHash:update`

Updates an item rectangle in the spatial hash.

```lua
LSpatialHash:update(id, x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Item id. |
| `x` | number | Rectangle x coordinate. |
| `y` | number | Rectangle y coordinate. |
| `w` | number | Rectangle width. |
| `h` | number | Rectangle height. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sh = lurek.math.newSpatialHash(16)
    sh:insert("a", 0, 0, 10, 10)
    sh:update("a", 200, 200, 10, 10)
    local hits = sh:queryRect(190, 190, 20, 20)
    example_print_log("rect hits = " .. #hits)
end
```

---

## LTransform

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTransform:clone`

Returns a copy of this transform. This method is available to Lua scripts.

```lua
LTransform:clone()
```

**Returns**

| Type | Description |
|------|-------------|
| [LTransform](#ltransform) | Cloned transform handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local t = lurek.math.newTransform(10, 20, 0.5)
    local clone = t:clone()
    local x, y = clone:transformPoint(0, 0)
    example_print_log("clone point = " .. x .. "," .. y)
    example_print_log("origin x = " .. select(1, t:transformPoint(0, 0)))
end
```

---

#### `LTransform:decompose`

Decomposes this transform into component values.

```lua
LTransform:decompose()
```

**Returns**

| Type | Description |
|------|-------------|
| number | X translation. |
| number | Y translation. |
| number | Rotation angle in radians. |
| number | X scale. |
| number | Y scale. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local t = lurek.math.newTransform(10, 20, 1.5, 3, 4)
    local x, y, angle, sx, sy = t:decompose()
    example_print_log("pos=" .. x .. "," .. y .. " angle=" .. angle .. " scale=" .. sx .. "," .. sy)
    example_print_log("origin x = " .. select(1, t:transformPoint(0, 0)))
    example_print_log("origin y = " .. select(2, t:transformPoint(0, 0)))
end
```

---

#### `LTransform:getMatrix`

Returns this transform matrix as a flat array table.

```lua
LTransform:getMatrix()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Flat matrix values in row-major order. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local t = lurek.math.newTransform(5, 10)
    local m = t:getMatrix()
    example_print_log("matrix elements = " .. #m)
    example_print_log("first row = " .. m[1] .. "," .. m[2] .. "," .. m[3])
    example_print_log("origin x = " .. select(1, t:transformPoint(0, 0)))
end
```

---

#### `LTransform:inverse`

Returns this transform's inverse.

```lua
LTransform:inverse()
```

**Returns**

| Type | Description |
|------|-------------|
| [LTransform](#ltransform) | Inverse transform handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local t = lurek.math.newTransform(10, 20, 0.5)
    local inv = t:inverse()
    local x, y = t:transformPoint(5, 0)
    local rx, ry = inv:transformPoint(x, y)
    example_print_log("roundtrip = " .. rx .. "," .. ry)
end
```

---

#### `LTransform:inverseTransformPoint`

Transforms a point by this transform's inverse.

```lua
LTransform:inverseTransformPoint(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Input x coordinate. |
| `y` | number | Input y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Inverse-transformed x coordinate. |
| number | Inverse-transformed y coordinate. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local t = lurek.math.newTransform(100, 0, 0, 2, 2)
    local fx, fy = t:transformPoint(5, 0)
    local ix, iy = t:inverseTransformPoint(fx, fy)
    example_print_log("forward = " .. fx .. "," .. fy)
    example_print_log("inverse = " .. ix .. "," .. iy)
end
```

---

#### `LTransform:reset`

Resets this transform to identity.

```lua
LTransform:reset()
```

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local t = lurek.math.newTransform(50, 50, 1.0, 2, 2)
    t:reset()
    local x, y = t:transformPoint(10, 10)
    example_print_log("after reset = " .. x .. "," .. y)
    example_print_log("origin x = " .. select(1, t:transformPoint(0, 0)))
end
```

---

#### `LTransform:rotate`

Applies a rotation to this transform.

```lua
LTransform:rotate(angle)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `angle` | number | Rotation angle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local t = lurek.math.newTransform()
    t:rotate(lurek.math.pi / 2)
    local x, y = t:transformPoint(10, 0)
    example_print_log("point = " .. x .. "," .. y)
    example_print_log("origin x = " .. select(1, t:transformPoint(0, 0)))
end
```

---

#### `LTransform:scale`

Applies scale to this transform. This method is available to Lua scripts.

```lua
LTransform:scale(sx, sy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | number | X scale. |
| `sy?` | number | Y scale (defaults to `sx`). |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local t = lurek.math.newTransform()
    t:scale(2, 3)
    local x, y = t:transformPoint(10, 5)
    example_print_log("point = " .. x .. "," .. y)
    example_print_log("origin x = " .. select(1, t:transformPoint(0, 0)))
end
```

---

#### `LTransform:setTransformation`

Replaces this transform from position, rotation, scale, origin, and shear components.

```lua
LTransform:setTransformation(x, y, angle, sx, sy, ox, oy, kx, ky)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X translation. |
| `y` | number | Y translation. |
| `angle?` | number | Rotation angle (default 0). |
| `sx?` | number | X scale (default 1). |
| `sy?` | number | Y scale (defaults to `sx`). |
| `ox?` | number | Origin x offset (default 0). |
| `oy?` | number | Origin y offset (default 0). |
| `kx?` | number | X shear (default 0). |
| `ky?` | number | Y shear (default 0). |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local t = lurek.math.newTransform()
    t:setTransformation(0, 0, lurek.math.pi, 1, 1)
    local x, y = t:transformPoint(10, 0)
    example_print_log("after set = " .. x .. "," .. y)
    example_print_log("origin x = " .. select(1, t:transformPoint(0, 0)))
end
```

---

#### `LTransform:shear`

Applies shear to this transform. This method is available to Lua scripts.

```lua
LTransform:shear(kx, ky)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `kx` | number | X shear. |
| `ky` | number | Y shear. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local t = lurek.math.newTransform()
    t:shear(0.25, 0)
    local x, y = t:transformPoint(10, 10)
    example_print_log("point = " .. x .. "," .. y)
    example_print_log("origin x = " .. select(1, t:transformPoint(0, 0)))
end
```

---

#### `LTransform:transformPoint`

Transforms a point by this transform.

```lua
LTransform:transformPoint(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Input x coordinate. |
| `y` | number | Input y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Transformed x coordinate. |
| number | Transformed y coordinate. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local t = lurek.math.newTransform(100, 0, 0, 2, 2)
    local fx, fy = t:transformPoint(5, 0)
    local ix, iy = t:inverseTransformPoint(fx, fy)
    example_print_log("forward = " .. fx .. "," .. fy)
    example_print_log("inverse = " .. ix .. "," .. iy)
end
```

---

#### `LTransform:translate`

Applies a translation to this transform.

```lua
LTransform:translate(dx, dy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dx` | number | X translation. |
| `dy` | number | Y translation. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local t = lurek.math.newTransform()
    t:translate(50, 50)
    local x, y = t:transformPoint(0, 0)
    example_print_log("point = " .. x .. "," .. y)
    example_print_log("origin x = " .. select(1, t:transformPoint(0, 0)))
end
```

---

#### `LTransform:type`

Returns the Lua-visible type name for this transform handle.

```lua
LTransform:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LTransform](#ltransform)`. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tf = lurek.math.newTransform()
    example_print_log(tf:type())
    example_print_log("origin x = " .. select(1, tf:transformPoint(0, 0)))
    example_print_log("origin y = " .. select(2, tf:transformPoint(0, 0)))
    example_print_log("unit x after transform = " .. select(1, tf:transformPoint(1, 0)))
end
```

---

#### `LTransform:typeOf`

Returns whether this transform handle matches a supported type name.

```lua
LTransform:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LTransform](#ltransform)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tf = lurek.math.newTransform()
    example_print_log(tostring(tf:typeOf("LTransform")))
    example_print_log("type = " .. tostring(tf:type()))
    example_print_log("origin x = " .. select(1, tf:transformPoint(0, 0)))
    example_print_log("origin y = " .. select(2, tf:transformPoint(0, 0)))
end
```

---

## LTween

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTween:addValue`

Adds a value track to this tween. This method is available to Lua scripts.

```lua
LTween:addValue(start, target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `start` | number | Start value. |
| `target` | number | Target value. |

**Returns**

| Type | Description |
|------|-------------|
| number | One-based index of the new value track. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tw = lurek.math.newTween(1.0, "linear")
    local index = tw:addValue(0, 100)
    example_print_log("index = " .. index)
    example_print_log("channels = " .. tw:getValueCount())
    example_print_log("tween time = " .. tw:getTime())
end
```

---

#### `LTween:await`

Yields the current coroutine until this tween completes or is cancelled. Must be called from inside a coroutine.

```lua
LTween:await()
```

---

#### `LTween:cancel`

Cancels this tween immediately, fires the onCancel callback if set, and resumes any coroutines waiting on it.

```lua
LTween:cancel()
```

---

#### `LTween:getAllValues`

Returns all current tween values. This method is available to Lua scripts.

```lua
LTween:getAllValues()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Numeric tween values. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tw = lurek.math.newTween(1.0, "linear")
    tw:addValue(0, 100)
    tw:addValue(50, 200)
    tw:setTime(0.5)
    local values = tw:getAllValues()
    example_print_log("count = " .. #values)
    example_print_log("first = " .. values[1])
end
```

---

#### `LTween:getClock`

Returns this tween clock time. This method is available to Lua scripts.

```lua
LTween:getClock()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current time in seconds. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tw = lurek.math.newTween(2.0)
    tw:addValue(0, 100)
    tw:setTime(1.0)
    example_print_log("clock = " .. tw:getClock())
    example_print_log("tween time = " .. tw:getTime())
end
```

---

#### `LTween:getDuration`

Returns this tween duration. This method is available to Lua scripts.

```lua
LTween:getDuration()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Duration in seconds. |

---

#### `LTween:getEasingName`

Returns this tween easing function name.

```lua
LTween:getEasingName()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Easing function name. |

---

#### `LTween:getElapsed`

Returns the number of seconds that have elapsed since the tween started.

```lua
LTween:getElapsed()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Elapsed time in seconds. |

---

#### `LTween:getFields`

Returns an array of field names being tweened on the target table.

```lua
LTween:getFields()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Field name strings. |

---

#### `LTween:getProgress`

Returns the eased progress of this tween as a value from 0.0 to 1.0.

```lua
LTween:getProgress()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Eased progress ratio. |

---

#### `LTween:getRemaining`

Returns the number of seconds remaining until this tween completes.

```lua
LTween:getRemaining()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Remaining time in seconds. |

---

#### `LTween:getTime`

Returns this tween clock time. This method is available to Lua scripts.

```lua
LTween:getTime()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current time in seconds. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tw = lurek.math.newTween(2.0)
    tw:addValue(0, 100)
    tw:setTime(1.0)
    example_print_log("time = " .. tw:getTime())
    example_print_log("tween time = " .. tw:getTime())
end
```

---

#### `LTween:getValue`

Returns one tween value by one-based index or all values when no index is provided.

```lua
LTween:getValue(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index?` | number | One-based value index; omit to return all values as a table. |

**Returns**

| Type | Description |
|------|-------------|
| number | Tween value at the given index, or a table of all values when index is omitted. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tw = lurek.math.newTween(1.0, "linear")
    local index = tw:addValue(0, 100)
    tw:setTime(0.5)
    example_print_log("value = " .. tw:getValue(index))
    example_print_log("tween time = " .. tw:getTime())
end
```

---

#### `LTween:getValueCount`

Returns the number of values animated by this tween.

```lua
LTween:getValueCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Tween value count. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tw = lurek.math.newTween(1.0, "linear")
    tw:addValue(0, 100)
    tw:addValue(50, 200)
    example_print_log("channels = " .. tw:getValueCount())
    example_print_log("tween time = " .. tw:getTime())
end
```

---

#### `LTween:isActive`

Returns whether this tween is still running (not cancelled or completed).

```lua
LTween:isActive()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if the tween is active. |

---

#### `LTween:isComplete`

Returns whether this tween is complete.

```lua
LTween:isComplete()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when complete. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tw = lurek.math.newTween(1.0, "outBounce")
    tw:addValue(0, 10)
    tw:update(1.1)
    example_print_log("complete = " .. tostring(tw:isComplete()))
    example_print_log("tween time = " .. tw:getTime())
end
```

---

#### `LTween:onCancel`

Sets a callback to fire when the tween is cancelled. Returns the tween for chaining.

```lua
LTween:onCancel(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | function | Callback fired when the tween is cancelled. |

**Returns**

| Type | Description |
|------|-------------|
| [LTween](#ltween) | The same tween handle for chaining. |

---

#### `LTween:onComplete`

Sets a callback to fire when the tween completes. Returns the tween for chaining.

```lua
LTween:onComplete(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | function | Callback fired when the tween finishes. |

**Returns**

| Type | Description |
|------|-------------|
| [LTween](#ltween) | The same tween handle for chaining. |

---

#### `LTween:onUpdate`

Sets a callback to fire every frame while the tween is active. Returns the tween for chaining.

```lua
LTween:onUpdate(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | function | Callback fired each frame with the current progress `t` (0..1). |

**Returns**

| Type | Description |
|------|-------------|
| [LTween](#ltween) | The same tween handle for chaining. |

---

#### `LTween:pause`

Pauses this tween so it stops advancing until resumed.

```lua
LTween:pause()
```

---

#### `LTween:relative`

Chainable version of `setRelative`. Returns the tween for fluent API usage.

```lua
LTween:relative(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | boolean | `true` for relative mode, `false` for absolute. |

**Returns**

| Type | Description |
|------|-------------|
| [LTween](#ltween) | The same tween handle for chaining. |

---

#### `LTween:reset`

Resets the tween clock to the beginning.

```lua
LTween:reset()
```

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tw = lurek.math.newTween(1.0, "outBounce")
    tw:addValue(0, 10)
    tw:update(0.5)
    tw:reset()
    example_print_log("clock = " .. tw:getClock())
end
```

---

#### `LTween:resume`

Resumes a paused tween so it continues advancing.

```lua
LTween:resume()
```

---

#### `LTween:set`

Sets this tween clock time. This method is available to Lua scripts.

```lua
LTween:set(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | New time in seconds. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tw = lurek.math.newTween(2.0)
    tw:addValue(0, 100)
    tw:set(0.75)
    example_print_log("value = " .. tw:getValue(1))
    example_print_log("tween time = " .. tw:getTime())
end
```

---

#### `LTween:setRelative`

Sets whether the tween end values are relative to the start values instead of absolute.

```lua
LTween:setRelative(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | boolean | `true` for relative mode, `false` for absolute. |

---

#### `LTween:setRepeat`

Sets how many times the tween should repeat after the first play. Use -1 for infinite repeat.

```lua
LTween:setRepeat(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | number | Number of additional repeats (0 = play once, -1 = infinite). |

---

#### `LTween:setTime`

Sets this tween clock time. This method is available to Lua scripts.

```lua
LTween:setTime(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | New time in seconds. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tw = lurek.math.newTween(2.0)
    tw:addValue(0, 100)
    tw:setTime(1.0)
    example_print_log("time = " .. tw:getTime())
    example_print_log("tween time = " .. tw:getTime())
end
```

---

#### `LTween:setYoyo`

Enables or disables yoyo mode, which reverses the tween direction on each repeat cycle.

```lua
LTween:setYoyo(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | boolean | `true` to enable yoyo, `false` to disable. |

---

#### `LTween:type`

Returns the Lua-visible type name for this tween handle.

```lua
LTween:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LTween](#ltween)`. |

---

#### `LTween:typeOf`

Returns whether this tween handle matches a supported type name.

```lua
LTween:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LTween](#ltween)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

---

#### `LTween:update`

Advances the tween clock and returns whether it is complete.

```lua
LTween:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the tween is complete. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tw = lurek.math.newTween(1.0, "outBounce")
    tw:addValue(0, 10)
    local done = tw:update(0.5)
    example_print_log("done = " .. tostring(done))
    example_print_log("value = " .. tw:getValue(1))
end
```

---

## LVec2

### Type Fields

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |

### Type Methods

#### `LVec2:angle`

Returns this vector angle. This method is available to Lua scripts.

```lua
LVec2:angle()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Angle in radians. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.vec2(1, 1)
    example_print_log("angle = " .. v:angle())
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalized().x)
    example_print_log("unit y = " .. v:normalized().y)
end
```

---

#### `LVec2:cross`

Returns the scalar 2D cross product with another vector.

```lua
LVec2:cross(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LVec2](#lvec2) | Other vector handle. |

**Returns**

| Type | Description |
|------|-------------|
| number | Cross product. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = lurek.math.vec2(1, 0)
    local b = lurek.math.vec2(0, 1)
    example_print_log("cross = " .. a:cross(b))
    example_print_log("vector length = " .. a:length())
    example_print_log("unit x = " .. a:normalized().x)
end
```

---

#### `LVec2:distance`

Returns distance to another vector.

```lua
LVec2:distance(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LVec2](#lvec2) | Other vector handle. |

**Returns**

| Type | Description |
|------|-------------|
| number | Distance. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = lurek.math.vec2(0, 0)
    local b = lurek.math.vec2(3, 4)
    example_print_log("distance = " .. a:distance(b))
    example_print_log("vector length = " .. a:length())
    example_print_log("unit x = " .. a:normalized().x)
end
```

---

#### `LVec2:dot`

Returns the dot product with another vector.

```lua
LVec2:dot(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LVec2](#lvec2) | Other vector handle. |

**Returns**

| Type | Description |
|------|-------------|
| number | Dot product. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = lurek.math.vec2(1, 0)
    local b = lurek.math.vec2(0, 1)
    example_print_log("dot = " .. a:dot(b))
    example_print_log("vector length = " .. a:length())
    example_print_log("unit x = " .. a:normalized().x)
end
```

---

#### `LVec2:fromAngle`

Creates a unit vector from an angle.

```lua
LVec2:fromAngle(radians)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `radians` | number | Angle in radians. |

**Returns**

| Type | Description |
|------|-------------|
| [LVec2](#lvec2) | New vector handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.vec2(0, 0)
    local unit = v:fromAngle(lurek.math.pi / 4)
    example_print_log("fromAngle(pi/4) = " .. unit.x .. "," .. unit.y)
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalized().x)
end
```

---

#### `LVec2:length`

Returns this vector length. This method is available to Lua scripts.

```lua
LVec2:length()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Vector length. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.Vec2(3, 4)
    example_print_log("length = " .. v:length())
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalized().x)
    example_print_log("unit y = " .. v:normalized().y)
end
```

---

#### `LVec2:lengthSquared`

Returns this vector squared length.

```lua
LVec2:lengthSquared()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Squared vector length. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.Vec2(3, 4)
    example_print_log("lengthSq = " .. v:lengthSquared())
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalized().x)
    example_print_log("unit y = " .. v:normalized().y)
end
```

---

#### `LVec2:lerp`

Returns a vector interpolated toward another vector.

```lua
LVec2:lerp(other, t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LVec2](#lvec2) | Target vector handle. |
| `t` | number | Interpolation factor. |

**Returns**

| Type | Description |
|------|-------------|
| [LVec2](#lvec2) | Interpolated vector handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = lurek.math.vec2(0, 0)
    local b = lurek.math.vec2(10, 20)
    local mid = a:lerp(b, 0.5)
    example_print_log("lerp = " .. mid.x .. "," .. mid.y)
    example_print_log("vector length = " .. a:length())
end
```

---

#### `LVec2:normalize`

Returns a normalized copy of this vector.

```lua
LVec2:normalize()
```

**Returns**

| Type | Description |
|------|-------------|
| [LVec2](#lvec2) | Normalized vector handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.vec2(3, 4)
    local n = v:normalize()
    example_print_log("normalized = " .. n.x .. "," .. n.y)
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalized().x)
end
```

---

#### `LVec2:normalized`

Returns a normalized copy of this vector.

```lua
LVec2:normalized()
```

**Returns**

| Type | Description |
|------|-------------|
| [LVec2](#lvec2) | Normalized vector handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.vec2(3, 4)
    local n = v:normalized()
    example_print_log("normalized = " .. n.x .. "," .. n.y)
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalized().x)
end
```

---

#### `LVec2:perpendicular`

Returns a perpendicular vector. This method is available to Lua scripts.

```lua
LVec2:perpendicular()
```

**Returns**

| Type | Description |
|------|-------------|
| [LVec2](#lvec2) | Perpendicular vector handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.vec2(3, 4)
    local p = v:perpendicular()
    example_print_log("perp = " .. p.x .. "," .. p.y)
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalized().x)
end
```

---

#### `LVec2:reflect`

Returns this vector reflected around a normal vector.

```lua
LVec2:reflect(normal)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `normal` | [LVec2](#lvec2) | Normal vector handle. |

**Returns**

| Type | Description |
|------|-------------|
| [LVec2](#lvec2) | Reflected vector handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.vec2(1, -1)
    local n = lurek.math.vec2(0, 1)
    local ref = v:reflect(n)
    example_print_log("reflected = " .. ref.x .. "," .. ref.y)
    example_print_log("vector length = " .. v:length())
end
```

---

#### `LVec2:rotate`

Returns this vector rotated by an angle.

```lua
LVec2:rotate(angle)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `angle` | number | Rotation angle in radians. |

**Returns**

| Type | Description |
|------|-------------|
| [LVec2](#lvec2) | Rotated vector handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.vec2(1, 0)
    local r = v:rotate(lurek.math.pi / 2)
    example_print_log("rotated = " .. r.x .. "," .. r.y)
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalized().x)
end
```

---

#### `LVec2:type`

Returns the Lua-visible type name for this vector handle.

```lua
LVec2:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LVec2](#lvec2)`. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.Vec2(3, 4)
    example_print_log(v:type())
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalized().x)
    example_print_log("unit y = " .. v:normalized().y)
end
```

---

#### `LVec2:typeOf`

Returns whether this vector handle matches a supported type name.

```lua
LVec2:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LVec2](#lvec2)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.Vec2(3, 4)
    example_print_log(v:typeOf("LVec2"))
    example_print_log("type = " .. tostring(v:type()))
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalized().x)
end
```

---

#### `LVec2:x`

Returns this vector x component. This method is available to Lua scripts.

```lua
LVec2:x()
```

**Returns**

| Type | Description |
|------|-------------|
| number | X component. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.Vec2(3, 4)
    example_print_log("x=" .. v.x)
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalized().x)
    example_print_log("unit y = " .. v:normalized().y)
end
```

---

#### `LVec2:y`

Returns this vector y component. This method is available to Lua scripts.

```lua
LVec2:y()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Y component. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.Vec2(3, 4)
    example_print_log("y=" .. v.y)
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalized().x)
    example_print_log("unit y = " .. v:normalized().y)
end
```

---

## LVec3

### Type Fields

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z` | any |  |

### Type Methods

#### `LVec3:add`

Returns the sum with another vector.

```lua
LVec3:add(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LVec3](#lvec3) | Other vector handle. |

**Returns**

| Type | Description |
|------|-------------|
| [LVec3](#lvec3) | Sum vector handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = lurek.math.vec3(1, 2, 3)
    local b = lurek.math.vec3(4, 5, 6)
    local sum = a:add(b)
    example_print_log("add = " .. sum.x .. "," .. sum.y .. "," .. sum.z)
    example_print_log("vector length = " .. a:length())
end
```

---

#### `LVec3:cross`

Returns the 3D cross product with another vector.

```lua
LVec3:cross(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LVec3](#lvec3) | Other vector handle. |

**Returns**

| Type | Description |
|------|-------------|
| [LVec3](#lvec3) | Cross product vector handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = lurek.math.vec3(1, 0, 0)
    local b = lurek.math.vec3(0, 1, 0)
    local c = a:cross(b)
    example_print_log("cross = " .. c.x .. "," .. c.y .. "," .. c.z)
    example_print_log("vector length = " .. a:length())
end
```

---

#### `LVec3:distance`

Returns distance to another vector.

```lua
LVec3:distance(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LVec3](#lvec3) | Other vector handle. |

**Returns**

| Type | Description |
|------|-------------|
| number | Distance. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = lurek.math.vec3(0, 0, 0)
    local b = lurek.math.vec3(3, 4, 0)
    example_print_log("distance = " .. a:distance(b))
    example_print_log("vector length = " .. a:length())
    example_print_log("unit x = " .. a:normalize().x)
end
```

---

#### `LVec3:dot`

Returns the dot product with another vector.

```lua
LVec3:dot(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LVec3](#lvec3) | Other vector handle. |

**Returns**

| Type | Description |
|------|-------------|
| number | Dot product. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = lurek.math.vec3(1, 0, 0)
    local b = lurek.math.vec3(0, 1, 0)
    example_print_log("dot = " .. a:dot(b))
    example_print_log("vector length = " .. a:length())
    example_print_log("unit x = " .. a:normalize().x)
end
```

---

#### `LVec3:length`

Returns this vector length. This method is available to Lua scripts.

```lua
LVec3:length()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Vector length. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.Vec3(1, 2, 2)
    example_print_log("length = " .. v:length())
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalize().x)
    example_print_log("unit z = " .. v:normalize().z)
end
```

---

#### `LVec3:lengthSquared`

Returns this vector squared length.

```lua
LVec3:lengthSquared()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Squared vector length. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.Vec3(1, 2, 2)
    example_print_log("lengthSq = " .. v:lengthSquared())
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalize().x)
    example_print_log("unit z = " .. v:normalize().z)
end
```

---

#### `LVec3:lerp`

Returns a vector interpolated toward another vector.

```lua
LVec3:lerp(other, t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LVec3](#lvec3) | Target vector handle. |
| `t` | number | Interpolation factor. |

**Returns**

| Type | Description |
|------|-------------|
| [LVec3](#lvec3) | Interpolated vector handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = lurek.math.vec3(0, 0, 0)
    local b = lurek.math.vec3(3, 4, 0)
    local mid = a:lerp(b, 0.5)
    example_print_log("lerp = " .. mid.x .. "," .. mid.y .. "," .. mid.z)
    example_print_log("vector length = " .. a:length())
end
```

---

#### `LVec3:normalize`

Returns a normalized copy of this vector.

```lua
LVec3:normalize()
```

**Returns**

| Type | Description |
|------|-------------|
| [LVec3](#lvec3) | Normalized vector handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.vec3(3, 0, 4)
    local n = v:normalize()
    example_print_log("normalized = " .. n.x .. "," .. n.y .. "," .. n.z)
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalize().x)
end
```

---

#### `LVec3:scale`

Returns this vector multiplied by a scalar.

```lua
LVec3:scale(s)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `s` | number | Scale factor. |

**Returns**

| Type | Description |
|------|-------------|
| [LVec3](#lvec3) | Scaled vector handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.vec3(1, 2, 3)
    local scaled = v:scale(2)
    example_print_log("scale = " .. scaled.x .. "," .. scaled.y .. "," .. scaled.z)
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalize().x)
end
```

---

#### `LVec3:splat`

Creates a vector with all components set to one value.

```lua
LVec3:splat(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Component value. |

**Returns**

| Type | Description |
|------|-------------|
| [LVec3](#lvec3) | New vector handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.vec3(0, 0, 0)
    local s = v:splat(5)
    example_print_log("splat = " .. s.x .. "," .. s.y .. "," .. s.z)
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalize().x)
end
```

---

#### `LVec3:sub`

Returns the difference from another vector.

```lua
LVec3:sub(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LVec3](#lvec3) | Other vector handle. |

**Returns**

| Type | Description |
|------|-------------|
| [LVec3](#lvec3) | Difference vector handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = lurek.math.vec3(1, 2, 3)
    local b = lurek.math.vec3(4, 5, 6)
    local diff = a:sub(b)
    example_print_log("sub = " .. diff.x .. "," .. diff.y .. "," .. diff.z)
    example_print_log("vector length = " .. a:length())
end
```

---

#### `LVec3:type`

Returns the Lua-visible type name for this vector handle.

```lua
LVec3:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LVec3](#lvec3)`. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.Vec3(1, 2, 3)
    example_print_log(v:type())
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalize().x)
    example_print_log("unit z = " .. v:normalize().z)
end
```

---

#### `LVec3:typeOf`

Returns whether this vector handle matches a supported type name.

```lua
LVec3:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LVec3](#lvec3)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local v = lurek.math.Vec3(1, 2, 3)
    example_print_log(tostring(v:typeOf("LVec3")))
    example_print_log("type = " .. tostring(v:type()))
    example_print_log("vector length = " .. v:length())
    example_print_log("unit x = " .. v:normalize().x)
end
```

---
